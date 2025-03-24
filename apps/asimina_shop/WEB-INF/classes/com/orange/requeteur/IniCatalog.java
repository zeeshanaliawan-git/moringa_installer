package com.orange.requeteur;

import java.sql.*;
import java.io.*;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import com.etn.beans.Contexte;
import com.etn.sql.escape;




public class IniCatalog {
/*
class Champ {
String nom ;
int typ;
String tstr;
int idx;
int uniq;
String card;
String ix;
int filtrable;
};
*/

	int sysfiltre=2;
	int sysselect=1;
	int sysgroupe=4;

	int filtre=16;
	int select=8;
	int groupe=32;
	int sysval=64;


/***********************
  	CATALOG --> BASE

 ***********************/



int serveur = 0;

Champ getChamp( ArrayList<Champ> ar , String nom )
{ for( int i = 0 ; i < ar.size() ; i++ )
  {
   if( ar.get(i).nom.equalsIgnoreCase(nom) )
   return(  ar.get(i) );
  }
  //System.out.println("NON TROUVE:"+nom);
  return(null);
}


int getIndexChamp( ArrayList<Champ> ar , String nom )
{ for( int i = 0 ; i < ar.size() ; i++ )
  {
   if( ar.get(i).nom.equalsIgnoreCase(nom) )
   return(  i );
  }
  //System.out.println("NON TROUVE:"+nom);
  return(-1);
}


/*CONNEXION AU CATALOGUE*/

public IniCatalog( int serveur )
{ this.serveur = serveur;
}

public IniCatalog( String serveur )
{ this.serveur = Integer.parseInt(serveur);
}

/*Liste des bases*/
public String[] liste_db()
{
 return(  Conteneur.getConnecteur( serveur).getDbs() );
}

/*Liste des tables*/
public String[] liste_table(String nom)
{ return( Conteneur.getTables( serveur , nom ) );
}

public boolean construire( ClientSql etn, String db , String tbl ,boolean insert )
{

  Connecteur ct = null;
  Connection con = null;

  try {
  ct = Conteneur.getConnecteur( serveur );
  if( ct.hasRef( db ) == false ) return( false);

  ArrayList<Champ>ar = new ArrayList<Champ>();
  con = ct.getCon();
  DatabaseMetaData md = con.getMetaData();
  ResultSet rs = md.getColumns(db,"", tbl , "");
  while( rs.next() )
  {
    int typ = rs.getInt(5);
    //boolean numeric = ( typ >= 2 && typ <= 8 );

    ar.add ( new Champ (
                rs.getString(4),
                typ ,
                rs.getString(6),
                ( typ >= 2 && typ <= 8 ? 9 : 0 )
                ));
  }
  rs.close();


  getIndex(ar,md,db,tbl);
  ct.free(con); con = null ; ct = null;

  if( insert ) //
  {
    etn.execute(
      "delete from catalog where dbnom='"+db+"' and dbtable='"+tbl+
    "' and serveur="+serveur);
    System.out.println(
     "########################### DELETE");
  }
  else
  {
   Set zs = etn.execute(
   "select champ from catalog where dbnom='"+db+"' and dbtable='"+tbl+
    "' and serveur="+serveur);

   int ix ;
   while( zs.next() )
    { if( ( ix = getIndexChamp( ar , zs.value(0) ) ) != -1 )
         ar.remove( ar.get(ix) );
    }
  }

  if( ar.size() == 0 )
     return(true);

  // Insertion de l'ar
  StringBuffer buf = new StringBuffer( 4096 );
  buf.append( "insert into catalog (champ, dbtable, dbnom, serveur, filtrable, type, typeDB, nomlogique, idx, ix, uniq, stats)");
  buf.append(" values ");


  for( int i = 0 ; i < ar.size() ; i++ )
  { Champ c = ar.get(i);

    if( i != 0 ) buf.append(',');

	String nom_de_champ = "";
	/*if( "date".equalsIgnoreCase(c.tstr) || "datetime".equalsIgnoreCase(c.tstr) || "time".equalsIgnoreCase(c.tstr)){
		nom_de_champ = tbl+".";
	}*/
	nom_de_champ += c.nom;

    buf.append( "("+escape.cote(nom_de_champ)+","+escape.cote(tbl)+","+escape.cote(db)+","+
    		serveur+","+c.filtrable);
    buf.append( ","+c.typ+",'"+c.tstr+"',"+escape.cote(c.nom)+","+c.idx);
    buf.append( ","+escape.cote(c.ix)+","+c.uniq+","+c.card+")");
  }

System.out.println( buf.toString());
  return( etn.executeCmd( buf.toString()) >= 0 );
///  System.out.println( buf.toString());
//  return(true);

 }

 catch( Exception e )
  { e.printStackTrace();
    return(false);
  }

 finally
 { if( ct !=null )
    if( con != null )
       ct.free(con);
 }

}



void getIndex( ArrayList<Champ> ar,DatabaseMetaData md , String db ,String nom)
throws Exception
{

System.out.println("ajout index la sur table : "+ nom +" de la	base : " + db+ " dans le catalogue");


ResultSet rs = md.getIndexInfo(db,null,nom,false,false);
//System.out.println("rs=="+rs);
  while( rs.next() )
  {
   Champ c = getChamp( ar,rs.getString(9) );
    if( c == null )
    {
      //System.out.println("Table->"+nom+" chp:"+rs.getString(9) );
      continue;
    }
    c.idx = rs.getInt(8);



    c.uniq = rs.getBoolean(4)?1:0;
    c.card = rs.getString(11);
    c.ix = rs.getString(6);

    if( c.ix != null ){
    	c.filtrable = c.filtrable | sysgroupe;
    	c.filtrable = c.filtrable | groupe;
    }
    //  si user filtrable alors systeme selectable
    if( (c.filtrable & filtre)==filtre)  {
    	c.filtrable = c.filtrable | sysfiltre;
    }

  }

/** DEBUG
	  System.out.println("table\tuniq\tix_nom\tpos\tcol\tcard");

	  while( rs.next() )
	  { System.out.println(
	    rs.getString(3)+"\t"+
	    rs.getString(4)+"\t"+
	    rs.getString(6)+"\t"+
	    rs.getString(8)+"\t"+
	    rs.getString(9)+"\t"+
	    rs.getString(11));
	  }

**/
 rs.close();

}





public static void main( String a[] )
throws Exception
{

  Contexte etn = new Contexte();


  IniCatalog ini = new IniCatalog( 5 );

  System.out.println("res:"+ ini.construire( etn, "nortel_gsm_cpt","jour_mat_aOPCUP_PBK", true));



 }

}



