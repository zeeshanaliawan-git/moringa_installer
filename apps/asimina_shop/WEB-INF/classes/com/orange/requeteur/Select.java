
package com.orange.requeteur;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;

/**
* Source pour jdk 1.5...
* Sinon supprimer <...>
*/

import java.util.Vector;
import java.util.HashMap;


public class Select {

Qry qy;
boolean hasWhereDate = false;

String setFrom(  Atom a[] )
{
  MyArray p = new MyArray();
  String db , table;
  int id;

  db = table = null;


  for( int i = 0 ; i < a.length ; i++ )
  if( a[i].type == Types.LNOM )
  {
    table = a[i].table;
    db =  a[i].db;
    id = a[i].con;

   // System.out.println( "id="+id+",table="+table+",db="+db );

    String t[] = table.split("\t");
    for( int x = 0 ; x < t.length ; x++ )
    {
      if( ! Conteneur.getRef( id , db+"."+t[x]) )
          {
             qy.setErr( "Select@setFrom:REFERENCE INCONNUE "+ db+"."+t[x] );
             return(null );
          }

      String dl =  p.get(id);

      if( dl  == null )
         p.set(id,db+"."+t[x]+",");
        else if( dl.indexOf( db+"."+t[x]+"," ) == -1 )
           p.set(id ,dl+db+"."+t[x]+",") ;
     }
  }

  

  if( p.count() == 0 )
   {
     qy.setErr("Aucune table Sélectionnée ???");
     return( null ); //???
   }



 Join join = new Join(qy);

/**
* Jointure Simple ( sur un meme serveur ).
*/

 String from = null;

 //System.out.println("max:"+ p.max());

 for( int i = 0 ; i <= p.max() ; i++ )
  {
    String s ;
    if( ( s = p.get(i))  != null )
    {
     if( from == null )
     { 
    	 /*String f = join.setJoin( i, s);
    	 if(f==null) f = "";
    	 if( "".equals(f) ){
    		 qy.setErr("Aucune table/jointure trouvée !");
    		// return null;
    	 }else{*/
    		 from = join.setJoin( i, s);
    	 /*}*/
     
     }
      else
       // non Implemente ...
        {  qy.setErr("Multi serveur NON IMPLEMENTE");
           return null;
       }
    }
  }




 return(from);

}

String appendAtom(  Atom z )
{
     if( (z.type & Types.NOP) == 0 || z.type == ( Types.ESCAPE | Types.NOP) )
       switch( z.type ) {
       /*case Types.PSDATE :
          System.out.println(""+z.champ+" "+z.champ+" tb:"+z.table);*/
       case Types.LNOM :  return( z.table+"."+z.champ );

       case Types.FONCTION : return(  z.val );
       default : return( z.val );
       }

   return( null );
}

boolean getGroup(  int bornes[] , Atom a[] , int index )
{
   Atom cur = a[index] ;
   int fct = cur.fct;
   int grp = cur.group;
   int i;

   for( i = index ; i < a.length ; i++ )
     if( a[i].fct != fct || a[i].group != grp )
       break;
   bornes[1] = i -1 ;
   for(  i = index ; i >= 0 ; i--)
    if( a[i].fct != fct || a[i].group != grp )
       break;
   bornes[0] = i;

   return(  bornes[0] <  bornes[1] );
}

boolean setTemps( Atom a[],int index,int cpt)
{


	hasWhereDate = false;
	if(cpt==0){

  int bornes[] = new int[2];
  StringBuffer tps = new StringBuffer();

  for( int i = index ; i < a.length && a[i].fct == Types.WHEREABLE ; i++)
  { if( a[i].type == Types.PSDATE  && getGroup( bornes, a , i) )
    {
      hasWhereDate = true;
      for( int j = bornes[0] ; j <= bornes[1] ; j++ )
       if( ( a[j].type & Types.NOP) == 0  &&  a[j].type != Types.ESCAPE  && a[j].type != Types.AS )
       {
    	 //System.out.println("-->"+a[j].val);
    	 	 String v =  a[j].val;
    	 	// v = v.replaceAll("psdate","`"+qy.psdate+"`");
    		 tps.append(  v );

         a[j].type |= Types.NOP ;
       }
      i = bornes[1];
    }
  }
  
  //System.out.println("setTemps-->"+tps.toString());
  String tps2 = tps.toString();
  tps2 = tps2.trim();
  if( tps2.startsWith("and")  ){
	  tps2 = tps2.substring(3);
  }
  if( tps2.endsWith("and")  ){
	  tps2 = tps2.substring(0,tps2.length()-3);
  }
  
  
  System.out.println("hasWhereDate-->"+hasWhereDate+"tps.toString()==>'"+tps2+"'");

 if( hasWhereDate )
   qy.whereDate = tps2;
 else qy.whereDate = null;
	}

 return(hasWhereDate);
}


boolean setEspaceTemps(Atom a[],int index,int cpt)
{
  if(1==1) return( setTemps( a , index,cpt) );

  // Desactive
  Atom cur = a[index] ;

  for( int i = index ; i < a.length ; i++ )
  {
    if( a[i].fct != Types.WHEREABLE )
       break;
    else if( a[i].type == Types.PSDATE )
    { // on remonte le groupe a gauche
      int g = a[i].group;
      int j = i;
      int k=i;

      //System.out.println("group="+g+"-->"+a[i].group+"");

      while( j > 0 && a[j-1].group == g ) j--;

      while( k < a.length && a[k+1].group <= g )
       {

          if( a[k].val.indexOf("between") != -1 )
              {
                 g++;
              }
          k++;
       }

      String result = "";


      if( a[j-1].type == Types.OPLOG )
        {
          a[j-1].type |= Types.NOP ;
        }


      for(  ; j <= k ; j++ )
      { if( ( a[j].type & Types.NOP) == 0  &&  a[j].type != Types.ESCAPE )
    	  ///System.out.println(a[j].type+"la valeur = "+a[j].val);
    	  result += a[j].val;
        a[j].type |= Types.NOP ;
      }


      
      qy.whereDate = result;
     // System.out.println("qy.whereDate="+qy.whereDate);

      return(hasWhereDate = true);
    }

  }
  return(hasWhereDate=false);
}

void specialAppend( StringBuffer sql, Atom z )
{

  switch( z.val.charAt(0) ) {
  case 'm' :
             if( z.val.equals("minute") )
             	sql.append("date_format("+z.champ+",'%d/%m/%Y %H:%i:00') as minute");
             else // mois
              sql.append( "date_format("+z.champ+",'%Y/%m') as mois");
              //     "date_format(tpl.psdate, '%m/%Y') as mois");
              break;
  case 'h' :
	  				sql.append("date_format("+z.champ+",'%d/%m/%Y %H:00:00') as heure");
                  // "date_format(tpl.dt, '%d/%m/%Y %H') as heure");
                    break;
  case 'j' :
                   //sql.append(");
	  				//sql.append(z.champ + " as jour");
	  				sql.append("date_format("+z.champ+",'%d/%m/%Y') as jour");
                    break;

  case 's' :
                   sql.append("concat(year("+z.champ + "),'/', lpad(week("+z.champ +"),2,0)) as semaine");
                    break;

  case 'a' :
                    sql.append("year("+z.champ+") as annee");
                    break;
  }


}

String getSimple( )
{
  int cpt=0;
  int cpt2=0;
  StringBuffer sql  = new StringBuffer(1024);
  int cur = 0;
  int curlevel=0;
  int curgrp = 0;
  Atom z;
  boolean fg = false;

  Atom a[] = qy.atoms;

  for( int i = 0 ; i < a.length ; i++ )
  { z = a[i] ;

  //System.out.println("lg:"+a.length+" cur:"+i+"z="+(z.champ==null?"":z.champ));

    switch( z.fct )
   {
    case Types.SELECTABLE :
      { if( cur > Types.SELECTABLE )
        { qy.setErr("Aucun champ dans la sélection ?");
          return( null );
        }

        if( cur == 0 )
          {  sql.append( "select ");
             cur = Types.SELECTABLE;
          }

        if(  z.type == Types.LNOM  )
              sql.append(  z.table+"."+z.champ);
          else  if(  z.type == Types.PSDATE )
           {

        	  // System.out.println("z.champ="+z.val);
        	  //sql.append(" "+z.table+"."+z.champ+ " ");
        	  // specialAppend( sql,z );
              // sql.append ( z.champ.substring(z.champ.indexOf("\t")+1) );

           }
          else

            if(  z.type == Types.INTERNE )
            {
            	specialAppend( sql,z );
              curgrp = z.group;
              while( i < a.length && a[i].group == curgrp )
                   i++;
               i -= 2;

            }
          else

              sql.append ( z.val );


      }

      break;

    case  Types.WHEREABLE :
       if( cur != Types.WHEREABLE )
         {
           if( cur != Types.SELECTABLE )
            { qy.setErr("Ordre requete incorrect");
              return( null );
            }

           	//System.out.println("aa="+i);
            // Periode , granularite
           	//fg = setEspaceTemps(a,i,cpt);
            //System.out.println("setEspaceTemps:"+qy.whereDate);
           	//System.out.println("cpt="+cpt);

            String fr = setFrom( a );

            if( fr == null ){
            	System.out.println("sql="+sql);
            	qy.setErr("Manque table/jointure trouvée !");
            	 
            	return( null);
            }else{
            	sql.append(" from ");
            }
                
            sql.append(  " "+fr  + " where ");
            cur =  Types.WHEREABLE;
              //fg = dateJoin(sql , a);

            fg = false; curlevel=-1; curgrp = z.group;


         }

         String sv = appendAtom(z);

       //  System.out.println("sv="+sv+"==============="+"fg="+fg+"==>z.group="+z.group+"==>group==>"+curgrp);

     /*    if( sv!=null && sv.trim().length() != 0 && z.group != curgrp )
         {
          cpt2++;
       	 if(  curlevel != z.level  )
            { if( !fg  )
              { 
            	sql.append(sv);
//           		 sql.append(  " where " );
           	 
           	
           	fg = true; 
              }
             else
           	 
           	  sql.append( " and " +  sv );
	             
             curlevel = z.level;
            }

         
          
          //	sv = sv.replace("psdate",qy.psdate);

           sql.append( sv) ;




         }*/
         
         sql.append( sv) ;
         	if(cpt==0)
       		if(qy.whereDate!=null &&  !qy.whereDate.equals("")){
   		  		sql.append(" "+(cpt2==0?" where ":"  ")+" "+qy.whereDate.replaceAll("psdate", qy.psdate));
   	  		}
         cpt++;
       break;

    case  Types.GROUPABLE :

      if(  cur != Types.GROUPABLE )
        { if( cur != Types.WHEREABLE )
               return( null );

          sql.append(  " group by " );

          cur =  Types.GROUPABLE;
        }


       if( (z.type & Types.NOP) == 0 )
       switch( z.type ) {
       case Types.LNOM :  sql.append( z.table+"."+z.champ ); break;
       case Types.INTERNE : sql.append( z.val);
                            curgrp = z.group;
                            while( i< a.length && a[i].group == curgrp )
                               i++;
                            if( i == a.length ) i--;
                            else i -= 2;
                            break;
       case Types.PSDATE :
           //sql.append( z.champ.substring(z.champ.lastIndexOf("\t")+1));
           sql.append("tpl.psdate");
           break;
       case Types.FONCTION : sql.append(  z.val ); break;
       default : sql.append( z.val ); break;
       }

      break;



     }

  }
  
  HashMap p = qy.ctx;
  String having = p.get("having")==null?"":(String) p.get("having");
  String psdate = "";
  System.out.println(qy.ctx+"==having="+having);
  
  if(!having.equals("")){
  	sql.append(" "+ having);
  }
  
  //////////////////////////////////////////////////////////
  // Au cas un GROUPABLE passthrough on l'ajoute ici
  // peut etre si il est prioritaire, il faudrait l'ajouter
  // au dessus dans le commentaire if( qy.EXTRAGROUP != nuul)
  //////////////////////////////////////////////////////////
/****
  if( qy.EXTRAGROUP != null )
  // Cas passthrough
  {
    if( cur ==  Types.GROUPABLE )
      // group by deja ecrit
      sql.append(",");
    else
      sql.append(" group  by "); //pas deja

    sql.append(  qy.EXTRAGROUP );
  }
***/




  return(sql.toString() );

}

boolean simple()
{ qy.qSql = getSimple();
  return( qy.qSql == null ? false : true );
}

boolean complex()
{
  qy.setErr("Non Implémenté");
  return( false );
}
public boolean get( Qry query )
{
  qy = query;
  return( qy.multiple ? complex() : simple() );
}

}
