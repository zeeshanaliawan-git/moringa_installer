package com.orange.requeteur;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Collection;
import java.util.Iterator;
import java.util.StringTokenizer;
import java.sql.*;
import com.etn.lang.Xdr;
import com.etn.lang.ResultSet.*;




public class Join {

Qry qy;

/*
class Ajoin {
String t1;
String t2;
String clause;
String typej;
int ordre = 0;
int flag;
};
*/
public class Ajoin implements Comparable{
	String t1;
	String t2;
	String clause;
	String typej;
	int ordre = 0;
	int flag;

	 public int compareTo(Object other) {
         int nombre1 = ((Ajoin) other).ordre;
      int nombre2 = this.ordre;
if (nombre1 < nombre2)  return 1;
      else if(nombre1 == nombre2) return 0;
      else return -1;
   }

		
}



/**
* ajout d'une jointure
* a la liste des jointures
* retoutr false si non resolu.
*/
boolean addJoin( ArrayList<Ajoin> ajs , Set rs , String t1 , String t2  )
{
  for( int i = 0 ; i < ajs.size() ; i++ )
  { Ajoin a = ajs.get(i);
    if( ( t1.equals( a.t1 ) && t2.equals( a.t2 ) ) ||
        ( t1.equals( a.t2 ) && t2.equals( a.t1 ) ) )
      return(true);  // resolu
  }

  Ajoin a = new Ajoin();
  a.t1 = t1 ; a.t2 = t2;

   rs.moveFirst();
   String sql = null;
   while( rs.next() )
   {
     if( ( rs.value(0).equals(t1) && rs.value(1).equals(t2) ) ||
         ( rs.value(0).equals(t2) && rs.value(1).equals(t1) ) )
     {
       a.t1 = rs.value(0); a.t2 = rs.value(1);
       a.clause = rs.value(2).replace("table1",a.t1).
             replace("table2",a.t2);
       a.typej = " " + rs.value(3) + " ";
       a.ordre = Integer.parseInt(rs.value(4),10);
       ajs.add( a);
     //  System.out.println("addJoin="+ a.clause);
       return(true);
     }
   }


  return(false);
}

void sameAlias( StringBuffer s , String tbl ,  Ajoin aj[] )
{
   for( int i = 0 ; i < aj.length ; i++ )
   { Ajoin a = aj[i];
     if( a.flag  == 0 )
     if( a.t1.equals(tbl) )
      { s.append(a.typej+" "+a.t2+" on "+a.clause);
        a.flag = 1;
      }
     else if( a.t2.equals(tbl) )
     { s.append(a.typej+" "+a.t1+" on "+a.clause);
        a.flag = 2;
      }

    }

}



void list( StringBuffer s ,  ArrayList<Ajoin> join ,int t)
{
	java.util.Collections.sort(join);
	if(t==1){
		list2(s,join);
	}else{

Ajoin aj[] = new Ajoin[join.size()];
  join.toArray( aj);

  for( int i = 0 ; i < aj.length ; i++ )
  {
    Ajoin a = aj[i];
   // System.out.println("table "+a.t1+"==>"+a.ordre);
    if( a.flag == 0 )
     { int k,l;
       k =  s.indexOf( a.t1 );
       l =   s.indexOf( a.t2 );
       if( k == -1 && l == -1 )
       {
         if( s.length() > 0 ) s.append(",\n");
         s.append( a.t1 +  a.typej + " " + a.t2+" on "+a.clause );
       }
       else if( l == -1 )
         s.append( a.typej + " " +a.t2+" on "+a.clause );
       else if( k == -1 )
         s.append( a.typej + " "+a.t1+" on "+a.clause );
       else  s.append( a.clause );

       a.flag = 4;

       if( k == -1 )
         sameAlias( s , a.t1 , aj);
       if( l == -1 )
         sameAlias( s,  a.t2 , aj);
     }
  }

	}
}

void list2( StringBuffer s ,  ArrayList<Ajoin> join )
{

  Ajoin aj[] = new Ajoin[join.size()];
  join.toArray( aj);

  for( int i = 0 ; i < aj.length ; i++ )
  {
    Ajoin a = aj[i];
    //System.out.println("i="+aj[i].clause);
    s.append( a.clause+"\n");
  }


}


int existe_table( ArrayList<String> ar , String nom )
{ for( int i = 0 ; i < ar.size() ; i++ )
  {
   if( ar.get(i).equals(nom) )
   return(  i );
  }
  //System.out.println("NON TROUVE:"+nom);
  return(-1);
}

String []getTables( String list )
{
  StringTokenizer st = new StringTokenizer( list , ", \r\n\t" );
  ArrayList<String> ar = new ArrayList<String>();
  ArrayList<String> ar2 = new ArrayList<String>();

  while( st.hasMoreTokens() )
   { String s = st.nextToken();
     if( !ar.contains(s) )
        ar.add( s);
     	//System.out.println("s="+s);
   }

  Set rs = qy.con.execute( qy.req_catalog);
  while( rs.next() ){
	  String nom = rs.value("dbnom")+"."+rs.value("dbtable");
	  if( !ar2.contains(nom) ){
		  ar2.add(nom);
	  }
  }
  String t[] = ar.toArray( new String[ar.size()] );
  for(int i=0;i<t.length;i++){
	  
	  int i2 = existe_table(ar2,t[i]);
	 // System.out.println("table =====>"+t[i]+"===>"+i2);
	  if( i2==-1){
		  int i3 = existe_table(ar,t[i]);
		 // System.out.println("table 2 =====>"+t[i]+"===>"+i3);
		  ar.remove(i3);
	  }
  }
	   
  String t2[] = ar.toArray( new String[ar.size()] );


  return(t2);
}

boolean set( StringBuffer buf , int id , String list ,int recurs )
{
  String t[] = getTables(list);
  //System.out.println("getTables="+t.length);

  StringBuffer buf2 = new StringBuffer(4096);



  // Cas appel inconsistant
  if(t.length == 0 ) return( false);




  // Assurer buffer vide
  buf.delete(0, buf.length() );

//  boolean b =PsDate.joinDate(  buf , qy );
//  System.out.println("------------------------------>joinDate="+b);

  // Cas Tempologie
/***
  if( qy.psd != null )
    {
      qy.psd.join( buf );
    }
**/


  // Maintenant topologie
  //setTopo( buf, t, id );
  



  /**
  * Nota la table jointure est obsolète
  */

  buf2.append( ("select distinct concat(base1,'.',table1)," +
          "concat(base2,'.',table2 ),\n"+
          "clause,typej,ordre \n"+
          "from jointure where db1 = "+id+" and db2 ="+id+
          "\n and ( \n concat(base1,'.',table1) in(\n ")) ;

  for( int i = 0 ; i < t.length ; i++ )
	  buf2.append("'"+t[i]+"',");

  buf2.deleteCharAt(buf2.length()-1);
  buf2.append("\n) or concat(base2,'.',table2) in(\n");
  for( int i = 0 ; i < t.length ; i++ )
	  buf2.append("'"+t[i]+"',");

  buf2.deleteCharAt(buf2.length()-1);
  buf2.append("\n))");
  buf2.append(" order by ordre");
 // System.out.println("jointure="+buf2.toString());
  
  Set rs = qy.con.execute( buf2.toString() );
  //System.out.println("rs="+rs.rs.Rows);
  /**
  * Contitution de la liste des jointures
  * en eliminant les doublons
  */

  ArrayList<Ajoin> ajs = new ArrayList<Ajoin>(t.length);
  //System.out.println("t="+t.length);
  if(t.length==1){
	  Ajoin a = new Ajoin();
	  a.t1 = t[0] ;
	  a.t2 = t[0];
	  a.clause = t[0];
	  ajs.add(a);
  }

 
  
  byte nojoin[] = new byte[t.length+1];
  int nojtcount = 0;

  if(t.length>1){

	  if( rs.rs.Rows == 0 ){
		  qy.setErr("Aucune jointure possibles !");
		  return(false);
	  }
	  
	  
  for( int i = 0 ; i <  t.length  ; i++ )
   {
    boolean resolu = false ;
    for( int j = 0 ; j < t.length ; j++ )
     if( j != i && addJoin( ajs , rs , t[i] , t[j] ) )
       { resolu = true; break; }

    if(!resolu)
        nojoin[nojtcount++] = (byte)i;
   }

  }


  // System.out.println("N Joints "+ajs.size()+" nojt:"+nojtcount);

  /**
  * certaines jointures ne sont pas résolues..
  */
  if( nojtcount > 0 )
  {
    // essai une récursivité ( level 1 ) sur tables de jointure.
    // on recherche dans jointures les occurrences de(s) jointure pblm
    // et de la liste des tables actuelles.
    // Algo bourrin : on ajoute simplement les tables ayant une réference de
    // joint a l'array t.
    // d'ou
	  
	 if( recurs < 2 )
    {
      rs.moveFirst();
      while( rs.next() )
        list += "," +rs.value(1);
      return( set( buf , id , list , ++recurs) );
    }
    else // Echec
    {
    	
    	
    	String err="";
        buf.delete(0,buf.length());
        for( int i = 0 ; i < nojtcount ; i++ )
          buf.append("ERREUR: Pas de jointure simple pour:"+t[nojoin[i]]+"\n");
        return(false); //modif
        
    	//return(true);

    }
  }

 // buf.delete(0,buf.length());
  //System.out.println("------------------------------>ICI");
 // list( buf , ajs);
  
  
  
  
/**
  if( qy.psd != null )
    {
      qy.psd.join( buf );
    }
**/


  //if(!b){

	  list( buf , ajs,t.length);
  //}

	 

  return(true);
}


public Join( Qry qy) { this.qy = qy ; }

/**
* Jointure Simple ( sur un meme serveur ).
*/
public String setJoin( int id , String list )
{
  StringBuffer buf = new StringBuffer( 1024 );

  if( set( buf, id, list, 0 ) == false )
  { qy.setErr( buf.toString() );
    return(null);
  }
    
  return( buf.toString() );
}

public Explain explain( int id , String list)
{
  String from = setJoin( id , list );
  if( from == null ) return( null);
  String sql = "explain select * from "+from;
  Connecteur con = Conteneur.getConnecteur( id );
  Connection ct = null;
  try
  {
     ct = con.admConnection();
     Statement st = ct.createStatement();
     java.sql.ResultSet jrs = st.executeQuery(sql);

     Xdr xs = new Xdr();

     CodeXdrSql.encode( xs ,jrs , 0 , 8 /* mysql */ );
     jrs.close();
     return( new Explain( sql , new ItsResult( xs)  ));
  }
  catch( Exception e )
  { e.printStackTrace();
    return(null);
  }

  finally {
  if( ct != null )
    { try { ct.close(); }
      catch( Exception gonfle) {}
    }

  }

}

}



