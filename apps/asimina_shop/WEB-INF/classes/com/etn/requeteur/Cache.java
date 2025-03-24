package com.etn.requeteur;

import java.io.*;
import com.etn.lang.Xdr;
import com.etn.lang.ResultSet.Set;
import com.etn.lang.ResultSet.ItsResult;
import com.etn.lang.ResultSet.OpSet;
import com.etn.lang.ResultSet.Union;
import java.util.concurrent.locks.ReentrantLock;
import java.util.HashMap;


public class Cache {

public static final String cacheDir = com.etn.beans.app.GlobalParm.getParm("CACHE_REQUETEUR");

private final int N_LOCK = 32;
private final int slots[];
//private final ReentrantLock lock ;
//private final Condition waiting;
private static Cache cache;
private static RandomAccessFile sfile;

private static int idQ = 0;

public static synchronized int nextVal()
{  ++idQ ; 
   try { 
    sfile.seek(0);
    sfile.writeInt(idQ);
  }
  catch( Exception e) { e.printStackTrace(); }
  return(idQ);

}



/******************************************
* Remplacé par fichier _seq dans le repertoire du cache....
* attention fichier binaire : utiliser rwseq out lire ou ecrire ce fichier.
**
class delOld implements FileFilter {
public boolean accept(File pathname)
{ if(pathname.getName().startsWith("_"))
     pathname.delete();
  return(false);
}
}

class MaxId implements FileFilter {
public boolean accept(File pathname)
{
  String s;
  if( (s = pathname.getName()).startsWith("_"))
    { try { int i = Integer.parseInt( s.substring(1) );
            if( i > idQ ) idQ = i ;
          }
      catch( Exception o) {}
    }

  return(false);
}
}

***********************************/



private Cache()
{
 try {
 File f = new File(  cacheDir+"/_seq" );
 boolean exist = f.exists();
 sfile = new RandomAccessFile( f , "rwd" );
 
 if( exist )
  idQ = sfile.readInt();
 else idQ = 0;
 }
 catch( Exception e ) { e.printStackTrace(); }

 slots = new int[N_LOCK];

 System.out.println("Path cache_requeteur :"+cacheDir);

}

/**
* lockOp:
* @param id : Id concerné.
* @param op :<ul>
* <li>Si op == 1 (put)      : pose un lock identifié par id.</li>
* <li>Si op == 2 (remove)   : efface un lock identifié par id.</li>
* <li>Si op == 0 (test)     : test si l'id est locké.</li>
* </ul>
* @return :<ul>
* <li>Si op == 1 (put)      : true si OK, false si pas de slot libre</li>
* <li>Si op == 2 (remove)   : true</li>
* <li>Si op == 0 (test)     : true si une lock existe pour l'id.</li>
* </ul>

*/
boolean lockOp( int id , int set )
{
  //lock.lock();
  synchronized ( slots ) {

  try {
  for( int i = 0 ; i < slots.length ; i++ )
     if( slots[i] == id )
      { if( set == 2 )
         {  // Remove
           slots[i] = 0 ;
           slots.notifyAll();
         }
        return(true);
      }
  if( set != 1 )
      return( false);

  // put
  for( int i = 0 ; i < slots.length ; i++ )
     if( slots[i] == 0 )
       { slots[i] = id ; return( true); }


  System.err.println(
      "Cache: nommbre de slots excessifs:"+slots.length+
      "\nAugmenter dimension Cache.slots");
    return(false);
  }

  catch ( Exception e )
  { e.printStackTrace();
    return(false);
  }

 }

 // finally { lock.unlock(); }
}


void waitFree ( int id )
{
  synchronized( slots )
  {
    while( true )
     {
/***
      System.out.println( "Waiting....pour "+id+" -> "+
         Thread.currentThread().getName()+
         " tm= "+System.currentTimeMillis() );
**/

      if( !isLock( id ) )
        return;
       try { slots.wait();
/***
             System.out.println( "Waiting.... EVENT...."+
                  Thread.currentThread().getName()+
                 " tm= "+System.currentTimeMillis() );
***/
           }
       catch( Exception a)
        {
          a.printStackTrace();
          return;
        }
     }
  }
}



static {
cache = new Cache();
}

public static void unLock( int id )
{
  boolean lk = cache.lockOp( id , 2 );
  //System.out.println("UnLock -> "+id+ "  result="+lk);

}

public static boolean putLock( int id )
{ boolean lk = cache.lockOp( id , 1 );
  //System.out.println("Lock -> "+id+" result="+lk);
  return(lk);
}

public static boolean isLock( int id )
{ boolean lk = cache.lockOp( id , 0 ) ;
  //System.out.println("IsLock :"+id+" -> "+lk);
  return(lk);
}

public static void waitLock ( int id )
{ cache.waitFree(id); }

public static Set getResultSet( int id )
{
  try
  {
    waitLock(id);
    ObjectInputStream o = new ObjectInputStream(
      new FileInputStream(cacheDir+"/_"+id) );
    Set rs = new ItsResult( (Xdr) o.readObject() );
    o.close();
    return(rs);
  }

  catch( Exception a )
  { a.printStackTrace();
    return( null);
  }

}

public static HashMap getMap( int id )
{
  String inf = cacheDir+"/_"+id+"_infos" ;
  if( ! new File( inf ).exists() )
     return( null );

   try
  {
    ObjectInputStream o =  new ObjectInputStream(
      new FileInputStream(inf) );
    HashMap p = ( (HashMap) o.readObject() );
    o.close();
    return(p);
  }

  catch( Exception a )
  { a.printStackTrace();
    return( null);
  }

}

public static String getErrText( int id )
{
  String inf = cacheDir+"/_"+id+"_erreur" ;
  if( ! new File( inf ).exists() )
     return( null );

   try
  {
    InputStream o =  new FileInputStream(inf) ;
    int a = o.available();
    byte b[] = new byte[a];
    a = o.read(b);
    o.close();
    return( new String( b , 0 , a) );
  }

  catch( Exception a )
  { a.printStackTrace();
    return( null);
  }

}


static boolean replayQys( int ids[] )
{
  return( false );

}
/*
public static Set getMultiSet( int ids[], boolean replay )
{

  if( replay )
   if( ! replayQys( ids ) )
       return( null);

  Set rs[] = new Set[ ids.length ];
  int ncols = 0;

  for( int i = 0 ; i < ids.length ; i++ )
    if( ( rs[i] = getResultSet( ids[i] ) ) == null )
        return(null);
    else if( rs[i].Cols > ncols )
        ncols = i;

  if( ncols != 0 )
   { Set tmp = rs[0];
     rs[0] = rs[ncols];
     rs[ncols] = tmp;
   }

 return( new OpSet( new  Union(rs , Union.SIMPLE) , OpSet.CUMUL ) );


}
*/
public static Set getMultiSet( int ids[], boolean replay )
{

  if( replay )
   if( ! replayQys( ids ) )
       return( null);

  Set rs[] = new Set[ ids.length ];
  
  /**
  * Reconstitution des Sets à partir des fichiers.
  * On choisit pour nom et nombre de colonnes ,
  * le Set dont le nb cols est le + grand.
  */
  int maxCols = 0; // max cols
  int index = 0 ;  // Le Set choisi
  for( int i = 0 ; i < ids.length ; i++ )
    if( ( rs[i] = getResultSet( ids[i] ) ) == null )
        return(null);
    else if( rs[i].Cols > maxCols )
     { maxCols = rs[i].Cols ; index = i; }

  if( index != 0 )
   { Set tmp = rs[0];
     rs[0] = rs[index];
     rs[index] = tmp;
   }

 System.out.println("AVANT.......");
 Union un = new Union(rs , Union.SIMPLE);
 System.out.println("APRES......."+un);

 if( un != null )
   return( (Set) un);

 return(null);

// return( new OpSet( new  Union(rs , Union.SIMPLE) , OpSet.CUMUL ) );


}


/**
public static String[] colNames( int id )
{
  try
  {
    ObjectInputStream o = new ObjectInputStream(
      new FileInputStream(cacheDir+"/_"+id+"_cols") );
    String a[] = ( (String []) o.readObject() );
    o.close();
    return(a);
  }

  catch( Exception ab )
  { ab.printStackTrace();
    return( null);
  }

}
***/


}
