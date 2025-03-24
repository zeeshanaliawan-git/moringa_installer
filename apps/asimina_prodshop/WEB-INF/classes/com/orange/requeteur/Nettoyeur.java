package com.orange.requeteur;

import java.sql.*;
import java.io.File;
import java.util.Properties;
import java.util.ArrayList;

/**
* Nettoyage des connections excedants le timeout paramÃ©rÃ©
* dans le fichier Nettoyeur.conf
* Algo:
* Chaque Threads emettant une requete appelle la methode put.
* Ceci ayant pour effet d'ajouter a la liste chainee head le
* "ThrInfo" correspondant.
* Le Thread Nettoyeur perquisitionne cette liste periodiquement
* et ote les entrees terminees ( thread non isalive ), emet un kill
* sql de la requete si le temps est excede.
*/
public class Nettoyeur extends Thread {

class ThrInfo
{ Thread tid;
  int id;
  int sqlid;
  //String nom;
  long fini;
  int serveur;
  ThrInfo next;
}


ArrayList<ThrInfo> queue;
long maxTm = 10000L;

void add( ThrInfo t )
{
  t.fini = System.currentTimeMillis() + maxTm ;
  synchronized( queue) {
  queue.add(t);
  System.out.println( "Nettoyeur queue("+queue.size()+") add:"+t.id+"  sqlid:"+t.sqlid);
  }

}

void del( ThrInfo t )
{  synchronized( queue) {
   queue.remove( t);
  System.out.println( "Nettoyeur queue("+queue.size()+") remove:"+t.id+"  sqlid:"+t.sqlid);
   }
}


public boolean doKill( int serveur , int sqlId )
{

 Connection con = null;

  try
  {
     con =  Conteneur.getConnecteur( serveur ).admConnection();
     Statement st = con.createStatement();
     int result = st.executeUpdate("kill "+sqlId);
     System.out.println("doKill: pour serveur:"+serveur+" id="+sqlId);
     st.close();
     con.close();
     con = null;
     return( true);
   }

 catch( Exception a )
 { a.printStackTrace();
   return( false);
 }


 finally
 { if( con != null )
    try {  con.close(); } catch( Exception gonfle ) {}
 }

}

boolean alive( ThrInfo t)
{
  //if( t.tid.isAlive() ) return( true);
  boolean cur =  new File(Cache.cacheDir+"/_"+t.id+".lck").exists() ;
  boolean lck =  Cache.isLock( t.id );
  if(cur == false)
    { System.out.println(
       "Fin "+t.id+" lck:"+lck+" thr:"+ t.tid.isAlive() );
      return(false);
    }

   System.out.println(
       "En cours "+t.id+" lck:"+lck+" thr:"+ t.tid.isAlive() );

  return(true);
}

long doClean()
{
  long now = System.currentTimeMillis();
  long nextTm = maxTm;
  long diff;
  ThrInfo toscan[];

  synchronized( queue )
   { toscan = queue.toArray( new ThrInfo[ queue.size() ] ); }



  for( int i = 0 ; i < toscan.length ; i++ )
  { ThrInfo t = toscan[i];
    if( !alive(t) ) del(t);
    else
    {
      diff = t.fini - now;
      if( diff < 0 )
       { if( doKill( t.serveur,t.sqlid) )
          { try { t.tid.join(1000); }
            catch( Exception ze ) {}
            del(t);
          }
         // echec ???
       }
      else   // timeout non atteind
       if( diff < nextTm )
         nextTm = diff;
    }
  }

  return( nextTm );

}

public void put( Thread th , int id , int sqlId, int serveur )
{
   ThrInfo t = new ThrInfo();
   t.tid = th.currentThread();
   t.id = id;
   t.sqlid = sqlId;
   t.serveur = serveur;
   add( t);
}


public void run()
{
  long curTm = maxTm;
  System.out.println("Nettoyeur:"+Thread.currentThread().getName());
  try {
  while( true )
  {
    System.out.println( "Nettoyeur: Attente pour "+
      (curTm / 1000L)+" secs");


    try { sleep(curTm); }
    catch(Exception e) {
     e.printStackTrace();
     break;
    }


    long l = System.currentTimeMillis();
    curTm = doClean() -
      System.currentTimeMillis() + l;
    if( curTm < 1000L ) curTm = 10000L;
  }

  }
  catch( Exception ae)
  { ae.printStackTrace(); }

  finaly:
  {
  System.out.println(
  "#####################################\n"+
  "Killer  FINI ????:"+
     Thread.currentThread().getName()
  +"\n####################################");
  }


}

protected Nettoyeur()
throws Exception
{

  Properties p = new Properties();
  p.load( getClass().getResource("Nettoyeur.conf").openStream() );
  int i = Integer.parseInt(  (String) p.get("timeout_minutes") );
  maxTm = (60000L * (long) i);
  queue = new ArrayList<ThrInfo>();
  System.out.println("Nettoyeur démarré pour maxTime : "+i+" minutes");
  p = null;

}



}
