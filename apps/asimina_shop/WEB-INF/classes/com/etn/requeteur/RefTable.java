package com.etn.requeteur;

import java.util.HashMap;
import java.util.ArrayList;
import com.etn.lang.ResultSet.Set;

public class RefTable {

ArrayList<String> alias;
String values[];
HashMap<String,String>idx;
boolean direct;

public String toString( String id )
{
  return( direct ? 
     values[Integer.parseInt(id)] :
     idx.get(id) );
}

/**
 * @param rs:  rs est de la forme id,lib et ordonné par id desc
 * @param alias: noms des colonnes a mapper.
*/
public RefTable( Set rs  )
{
  alias = new ArrayList<String>();

  // Doit on utiliser une indirection ?
  // Oui si ((maxid - nrow) / nrow ) > 0
  int r = rs.rs.Rows;
  rs.next();
  int max = Integer.parseInt(rs.value(0));

  System.out.println("Rows:"+r+ " max:"+max); 
  if( ( ( max - r ) / r  ) == 0 )
   { direct = true;
     values = new String[max + 1];
     values[max] = rs.value(1);
     while( rs.next() )
       values[Integer.parseInt(rs.value(0))] = rs.value(1);
   }
  else
   { direct = false;
     idx = new HashMap<String,String>(r+1);
     do
      idx.put( rs.value(0),rs.value(1));
     while(rs.next());
 
   }
     
}

public RefTable( Set rs ,String nalias )
{ this(rs); addAlias(nalias); }

public boolean hasAlias( String nom)
{ 
  return( alias.contains(nom) );
}

public void addAlias(String nom) { alias.add(nom); }

public boolean mode() { return( direct); }
public int size() { return( direct ? values.length : idx.size()  ); }


public static void main( String a[] )
throws Exception
{
  com.etn.Client.Impl.ClientSpooled etn = 
    new com.etn.Client.Impl.ClientSpooled( );

  Set rs = etn.execute(
  "select idAppli,nameAppli  from Appli order by 1 desc" );

  RefTable rf = new RefTable( rs , "toto,tata"  );

  System.out.println( rf.hasAlias("ToTo"));
  System.out.println( "size:"+rf.size()+" mode:"+rf.mode()+" -> "+rf.toString("4") );
  System.out.println( rf.toString("0") );

  rs = etn.execute(
  "select distinct mfs, nidt from topologie order by 1 desc" );

  rf = new RefTable( rs ,  "toto,tata"  );

  System.out.println( "size:"+rf.size()+" mode:"+rf.mode()+" -> "+rf.toString("709") );

  rs = etn.execute(
  "select distinct mfs, mfs from topologie where (mfs & 511) != 0 order by 1 desc" );

  rf = new RefTable( rs ,  "toto" );

  System.out.println( "size:"+rf.size()+" mode:"+rf.mode()+" -> "+rf.toString("709") );


}

}
