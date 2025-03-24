package com.etn.requeteur;

import java.sql.*;
import java.util.Properties;
import java.util.ArrayList;
import java.util.regex.Pattern;
import com.etn.Client.Impl.ClientSpooled;
import com.etn.lang.ResultSet.Set;





/**
* Conteneur connexions aux serveurs
*/

public class Conteneur {

static Connecteur cnx[];
static byte ids[];
static Nettoyeur killer;

static {

try {

ClientSpooled con = new ClientSpooled();

Set rs =  con.execute(
		 "select id , host, aes_decrypt(unhex(credential),'requeteur') cred,"+
		    " options, maxcon, timeout "+
		    "from serveur order by id" );

cnx = new Connecteur[rs.rs.Rows];
ids = new byte[cnx.length+cnx.length];
  for( int j = 0 ; j < ids.length ; j++ ) ids[j] = (byte) -1 ;


int i = 0;
  while( rs.next() )
  {
    try {
    cnx[i] = new Connecteur( rs.value("host"),
               rs.value("cred"),
               rs.value("options"),
               Integer.parseInt(rs.value("maxcon")),
               Integer.parseInt(rs.value("timeout")) );

    ids[Integer.parseInt(rs.value("id"))] = (byte)i;
    System.out.println( "Connection a "+rs.value("id")+" par indice "+(i)+
       " concur="+ cnx[i].getConcur()  );
    }
    catch( Exception ae)
    { ae.printStackTrace();
      System.out.println( "Erreur au demarrage connecteur serveur:"+
         rs.value("host")+"\nOn continue" );
    }

    i++;

  }

 rs.close();

killer = new Nettoyeur();
killer.setDaemon( true);
killer.start();
}
catch( Exception e )
{ e.printStackTrace();
}

}
/**
* retourne true si l'objet ( db ou db.table ) existe
* pour cette connection.
*/
public static boolean getRef( int id , String Obj)
{
  try {

  if( id == 0 ) return(false);
  int n = 255 & ids[id] ;

  if( n > cnx.length ) return(false);

  return( cnx[n].hasRef(Obj) );
  }
  catch( Exception e )
  { e.printStackTrace();
    return(false);
  }
}

public static String[] getTables( int serveur , String db)
{
  if( serveur == 0 ) return(null);
  int n = 255 & ids[serveur] ;

  if( n > cnx.length ) return(null);

  Connection master = null;
  ArrayList<Pattern> ar = new ArrayList<Pattern>();
  try
  {
    master = cnx[0].getCon();
    Statement st = master.createStatement();
    ResultSet rs = st.executeQuery(
     "select expr from exclusion where serveur = "+serveur+
     " and db = '"+db+"' order by length(expr) desc ");
    while( rs.next() ) ar.add( Pattern.compile( rs.getString(1)) );
    rs.close(); st.close();
    cnx[0].free( master);
   }
   catch( Exception e)
   { cnx[0].free( master);
     e.printStackTrace();
   //  return(null );
   }

  return( cnx[n].getTables( db ,
     ar.toArray( new Pattern [ar.size()] ) ) );
}


public static Connecteur getConnecteur( int id )
{ if( id == 0 ) return(null);
  int n = 255 & ids[id] ;

  if( n > cnx.length ) return(null);

  return( cnx[n] );
}

public static Nettoyeur getKiller() { return killer ; }

}

