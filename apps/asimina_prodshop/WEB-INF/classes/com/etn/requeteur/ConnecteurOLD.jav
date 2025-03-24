package com.etn.requeteur;

import java.sql.*;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.regex.Pattern;

/**
* Conteneur connexions a un MySql
*/

public class Connecteur {

String host;
String cred;
int timeout;
final String opDbg = "connectTimeout=0";
//&dumpQueriesOnException=true"+
//    "&profileSQL=true&explainSlowQueries=true&logSlowQueries=true&slowQueryThresholdMillis=10000";



String listDb[];
Connection ct[];
long mask = 0L;


synchronized int lockM( int set )
{ if( set == -1 )
  { for( int i = 0 ; i < ct.length ; i++ )
    if( ( (1L<<i) & mask ) == 0 )
    { mask |= 1L << i;
      return( i );
    }
    return(-1);
  }

 mask &= ~( 1L << set) ;
 return(0);
}

synchronized int getAConnection()
{
 while(true)
 { int n = lockM(-1);
   if( n != -1 )
     return( n );

   try { wait() ; }
   catch( Exception e ) {}
 }
}

int getConnection()
{
  int n = getAConnection();

  if( testCon( n ) != 0 )
     return( n);


  freeConnection( n );
  return(  -1 );
}
/**
* @param sqlId : Array dimmension1 pour connectionId si succes.
* @return >= 0 si success
*/
int getConnection(int sqlId[])
{
  int n = getAConnection();
  int sid;

  if( ( sqlId[0] = testCon( n ) ) != 0 )
      return( n);


  freeConnection( n );
  return(  -1 );
}


synchronized void freeConnection( int n )
{
  lockM(n);
  notify();

}

synchronized void refreshListDbs( Connection cx )
throws Exception
{
  ArrayList<String>li = new ArrayList<String>();
  ResultSet rs = cx.getMetaData().getCatalogs();
  while( rs.next() )
    { String s = rs.getString(1);
      if( !s.equalsIgnoreCase("test") &&
          !s.equalsIgnoreCase("mysql") )
      li.add( s );
    }

   listDb = li.toArray( new String[ li.size()] );
   li = null;
}

Connection makeConnection()
throws Exception
{
  return(  DriverManager.getConnection(
   "jdbc:mysql://"+host+ "?"+cred+"&"+opDbg ) );
}


void init()
throws Exception
{

 Class.forName("com.mysql.jdbc.Driver").newInstance();
 Connection cx = makeConnection();

 refreshListDbs( cx );
 ct[0] = cx;
 for( int i = 1 ; i < ct.length ; i++ )
  ct[i] = makeConnection();


}

/**
*  Existence Db ( case sensitif )
*/
public boolean hasDb( String db)
{
  if( db == null || db.length() == 0 )
    return( false);

  for( int i = 0 ; i < listDb.length ; i++ )
    if( db.equals( listDb[i] ) )
       return( true);

  if( listDb.length <= 0 )
  {
    Connection adm = null;
    try
     { adm = admConnection();
       if( adm == null ) return( false);
       refreshListDbs( adm);
       for( int i = 0 ; i < listDb.length ; i++ )
         if( db.equals( listDb[i] ) )
            return( true);
       return( false);
     }

    catch( Exception e )
    { e.printStackTrace();
      return( false );
    }

    finally { if( adm != null )
              { try { adm.close(); }
                catch( Exception bb ) {}
              }
           }

   }

  return( false );

}


/**
* Existence Objet ( db ou db.table )
*/
public boolean hasRef( String obj )
{
  boolean ok = false;

  if( obj.indexOf('.') == -1 )
    return( hasDb( obj ) );

  int n = -1;
  try {
  n = getConnection();
  Statement st = ct[n].createStatement();
  ok = st.execute( "select '"+obj+"' from "+obj+" limit 1" );
  st.close();
  }

  finally {
   if( n != -1 ) freeConnection(n);
   return(ok);
  }

}
/**
* Retourne la liste des databases visibles par ce connecteur
* hors mysql et test.
*/
public String[] getDbs()
{
  return( listDb );

}
/**
* Retourne la liste de tables de cette database filtrée
* par les patterns exclus.
* @param db la database
* @param exclus un array de Pattern précompilées.
* @return la liste.<pre>
* ou null si :
* Appel incorrect : db inconnue , exclus null.
* ou Connection problème sur impossible d'acquérir
* une coonection a cet serveur.
*/
public String[] getTables( String db , Pattern exclus[] )
{
  if( !hasDb( db ) || exclus == null )  // ?
     return( null );

  int n = -1;
  try {

  ArrayList<String> ar = new ArrayList<String>();
  n = getConnection();
  ResultSet rs  = ct[n].getMetaData().getTables(db,null,"%",null);

  while(rs.next() )
   { String s = rs.getString("table_name");
     boolean toadd = true;
     for( int i = 0 ; i < exclus.length ; i++ )
       if( exclus[i].matcher(s).matches() )
         { toadd = false ; break; }

     if( toadd ) ar.add( s);
   }

  rs.close();
  freeConnection(n); n = -1;
  return( ar.toArray( new String[ar.size()] ) );
  }

  catch( Exception e )
  { if( n != -1 ) freeConnection(n);
    e.printStackTrace();
    return(null);
  }
}

int testCon( int index)
{
  int conId = -1;
  for( int i = 0 ; i < 2 ; i++ )
  {
    Connection c = ct[index];
    try
     {
        Statement st = c.createStatement();
        ResultSet rs = st.executeQuery("select connection_id()");
        rs.next();
        conId = rs.getInt(1);
        rs.close();
        st.close();
        return(conId);
     }
    catch( Exception e )
     { System.out.println("Reconnect");
       try {
             ct[index] = makeConnection();
             refreshListDbs(  ct[index] );
           }
       catch( Exception e2 )
          { e2.printStackTrace();
            return(0);
          }
     }
  }

  return(0);
}
public Connection getCon()
{
  int index = getConnection();

  return( index == -1 ? null : ct[index] );
}

public Connection getCon(int sqlId[])
{
  int index = getConnection(sqlId);

  return( index == -1 ? null : ct[index] );
}


public void free( Connection con )
{
  for( int i = 0 ; i < ct.length ; i++ )
   if( con.equals( ct[i] ) )
   {
     freeConnection( i );
     return;
   }
}

public Connection admConnection()
{
  try { return(   makeConnection() );
      }
  catch( Exception e )
  { e.printStackTrace();
    System.err.println("admConnect return null suite a + haut");
    return(null);
  }
}

/**
* retourne le nombre de connection concurrente a l'instant.
*/
public int getConcur()
{
 int n = 0;
 for( int i = 0 ; i < ct.length ; i++ )
   if(  ( mask & (1L << i) ) != 0 ) n++;
 return(n);
}


public Connecteur( String host , String cred , String opts, int maxcon , int timeout )
throws Exception
{
  this.host = host;
  this.cred = cred;
  this.timeout = timeout;
  ct = new Connection[maxcon];
  init();

}

/*****
public static void main( String a[] )
throws Exception
{

  Connecteur con = new Connecteur( "127.0.0.1:3306/pivot","user=sa&%password=1-mysql-2%",null,5,-1);

}
***/

}

