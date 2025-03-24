package com.orange.requeteur;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Collection;
import java.util.Iterator;
import java.util.StringTokenizer;


public class PsDate {


class Adate {
String db;
String table;
String champ;
String format;
int type=0;
public boolean equals( Adate autre)
{ if( autre == null ) return( false);
  if( autre == this ) return( true);
  if( db.equals(autre.db) && table.equals(autre.table) &&
      champ.equals( autre.champ) && type==autre.type &&
      format.equals(autre.format) )
  return(true);
  return( false);
}
}

/**
* perquisition table tempologie
* casts employés en sortie
*/
final String MOIS = "left(d,7)";
final String JOUR = "d" ;
final String HEURE = "left(dt,13)" ;
final String DMINUTE = "left(dt,15)" ;

final String FMTDATE[] = {null,  MOIS , JOUR , HEURE , DMINUTE };
int outfmt = 4;

String format = null;

Adate dates[];
int ndates ;
Qry qy;


boolean contains( Adate a )
{ for( int i = 0 ; i < ndates ; i++ )
    if( dates[i].equals(a) ) return(true);
  return( false);
}

public PsDate( Qry qy, int maxCount)
{ this.qy = qy ;
  dates = new Adate[maxCount];
  ndates = 0;
}

public void add( String db , String table ,
     String type, String champ , String fmt )
{
  Adate d = new Adate();
  System.out.println(  "db=db" + " tb:"+table +" nom:"+ champ );
  d.db = db; d.table = table; d.champ = champ;
  // a voir d.type = type;

  // format devrait etre unique pour une requete
  // donc global ... le premier renseigné définit
  // le format.
  if( fmt != null && fmt.trim().length() > 0 )
     format = fmt;
  if( ! contains( d) )
    dates[ndates++] = d;
}




public static boolean joinDate( StringBuffer buf , Qry qy )
{

	int i =0;
  HashMap<String,TableInfo> ti = qy.tinf;
  if( ti == null ) return(false);

  String typjoin = qy.PSDSTRICT ? " inner " : " left ";

  Iterator<String>it = ti.keySet().iterator();
  boolean tm = Types.isGranTime(qy.granularite);

 /* if( !tm )   // Resolution >= jour
  {*/
    buf.append(
         "\n(\nselect dt psdate,s from requeteur.tempologie_jour\n" );
        if( qy.whereDate != null )
            buf.append("where "+ qy.whereDate.replace("psdate","dt") );
   /*}
   else
   {
     buf.append(
         "\n(\nselect d psdate, h ,s, dt from requeteur.tempologie\n" );
     if( qy.whereDate != null )
         buf.append("where "+ qy.whereDate.replace("psdate","dt") );
   }*/

  buf.append("\n) as tpl \n") ;

  while( it.hasNext() )
  { String s = it.next();
    TableInfo a = ti.get(s);
    s = s.substring(1);
    i++;
    if(a.minutes>0){
    buf.append( typjoin+"join "+s );

   // System.out.println("TableInfo="+s);

   // if( tm == false ||  a.jDate.length == 1 )
       buf.append( " on ( tpl.psdate = "+s+"."+a.jDate[0]+")\n") ;
    /* else
       buf.append( " on ( tpl.psdate = "+s+"."+a.jDate[0]+
            " and  tpl.h = "+s+"."+a.jDate[1]+")\n") ;*/
  }
  }

  if(i==0){
	  return(false);
  }else{
	  return(true);
  }
}

}
