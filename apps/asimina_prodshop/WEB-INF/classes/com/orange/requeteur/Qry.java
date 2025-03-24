package com.orange.requeteur;

/**
* Nota:Source pour jdk 1.5...
*/

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.io.ByteArrayOutputStream;
import java.util.StringTokenizer;
import java.util.HashMap;

import com.etn.Client.Impl.*;
import com.etn.lang.ResultSet.Set;
import com.etn.lang.ResultSet.Encoding;

/**
* Classe Main d'une tequete requeteur.
*/
public class Qry {

/**
* Le tableau des elements de la requete.
*/
Atom atoms[];
/**
* Un hash sur les tables concernées
* clef : numero_serveur[0-9] database . table
* Detail infos dans valeur de type TableInfo.
*/
HashMap <String,TableInfo>tinf ;

HashMap ctx;
/**
* une Connection Etn sur le repository local requeteur.
*/
ClientSql con;

/**
* La requete originale
*/
String qry[];


boolean relax = false;  // Continuer sur erreurs
boolean debug = true;   // Emettre des messages


String qSql=null;          // La requete a emmetre
boolean multiple = false;   // multiple serveur


String errString = null;    // Dernier message d'erreur
int errCode = 0;            // A quel niveau une erreur s'est produite.
int errNiv = 1;             // Niveau de la Query en cours


protected String URM = null;             // URM choisie
protected String CONSTRUCTEUR = null;    // Constructeur
protected String TECHNO = null;          // 2G etc..
protected boolean PSDSTRICT = true;      // Type de jointure date
protected int serveur = 0;
protected PsDate psd = null;
protected String whereDate;
protected String type = "";
protected String psdate = "";

protected String req_catalog;

protected int granularite = 0;
protected int nivEqp = 0;

protected void setErr( String error )
{ errString = error;
  errCode = errNiv;
}

public int getErrCode()
{ return( errCode );
}

public String getErr()
{ if( errCode == 0 ) return("");
  return( errString );
}

public void setMap(HashMap ctx ) { this.ctx = ctx; }

public int granul()
{
  int gran = 0;
  for( int i = 0 ; i < atoms.length ; i++ )
    if( atoms[i].type == Types.FONCTION || atoms[i].type == Types.INTERNE )
        { if( "hour".equals(atoms[i].val ) || "heure".equals(atoms[i].val )||
           "minute".equals(atoms[i].val ) )
            gran |= Types.G_HEURE;
          else if( atoms[i].val.startsWith("day")||
                "jour".equals( atoms[i].val) )
            gran |= Types.G_JOUR;
          else if( atoms[i].val.startsWith("week") ||
               "semaine".equals( atoms[i].val))
            gran |= Types.G_SEMAINE;
          else if( atoms[i].val.startsWith("month")||
              "mois".equals( atoms[i].val) )
            gran |= Types.G_MOIS;
        }
      //else if(  atoms[i].type == Types.CONST )
      // avoir


  return( granularite = gran);

}

protected int granEqp(String eqp)
{
  nivEqp = 0;
  Set rs = con.execute(
    "SELECT coalesce(max(niveau),0) FROM toptour where eqp ="+eqp );
  rs.next();
  return(nivEqp = Integer.parseInt(rs.value(0)));

}

public boolean needTime()
{
  return( Types.isGranTime( granul() ) );

}
public boolean checkRelax(  String req[] )
{

  relax = false;
  if(checkIn( req) == false )
    return( relax = false );

  if( ! ( new Parse().getAtoms(this) ) )
     return(relax = false);

  relax = false;

  if(! new Catalog( this ).set() )
    return( false);

  return( true);

}

public String[] colNames(boolean maj)
{

   if( atoms == null )
     return( null);

   String sb = "";
    String as = null;
    ArrayList <String>v = new ArrayList<String>();

    Atom at[] = atoms;

    for( int i = 0 ; i < at.length && at[i].fct == 1 ; i++ )
    {
      if(  at[i].level == 0 &&  at[i].type == Types.AS )
          as = at[i].val.substring(3);
      else
      if( at[i].type == Types.PUNCT && at[i].level == 0 && at[i].val.equals(",") )
      { if(maj)
         v.add( as == null ? sb.trim().toUpperCase() : as.trim().toUpperCase() );
        else
          v.add( as == null ? sb.trim() : as.trim() );
        sb = "";
        as = null;
      }
      else
        sb += at[i].val;
    }

    if( sb.length() > 0 )
      v.add(sb);

   String t[] = new String[v.size()];
   return( v.toArray(t) );

}

byte []getCols()
{

  if( atoms == null )
     return( null);

  try
  {

  ByteArrayOutputStream o = new ByteArrayOutputStream(1024);

   String sb = "";
   String as = null;

    Atom at[] = atoms;

    for( int i = 0 ; i < at.length && at[i].fct == 1 ; i++ )
    {
      if(  at[i].level == 0 &&  at[i].type == Types.AS )
       { as = at[i].val.substring(3).trim().toUpperCase();
      // System.out.println("1.as-->'"+as+"'");
       	if( as.startsWith("\"" ) )
           as = as.substring(1,as.length() - 1 );
       	//	System.out.println("2.as-->'"+as+"'");
       }
      else
      if( at[i].type == Types.PUNCT && at[i].level == 0 && at[i].val.equals(",") )
      {

    	  //System.out.println("-->"+at[i].val);


    	  o.write( ( as == null ? 
              Encoding.getBytes(sb.trim().toUpperCase()) : 
              Encoding.getBytes(as.trim().toUpperCase() ) ) );
        o.write(9);
        sb = "";
        as = null;


      }
      else
        sb += at[i].val;
    }

    if( sb.length() > 0 )
      o.write( ( as == null ? Encoding.getBytes(sb.trim().toUpperCase()) : 
         Encoding.getBytes(as.trim().toUpperCase() ) ));

    // Cas Passthrough : vraiment tres simple
    // separaeur aujourdh'hui ',' donc pas de truc avec des virgules
/***
    String token = ", \t\n\r" ;
    if( EXTRASELECT != null )
    { StringTokenizer st = new StringTokenizer( EXTRASELECT , token );
      while( st.hasMoreTokens() )  // On croit ou assume que tout n'est pas extra
      { o.write(9);  // nouvelle colonne
        o.write( Encoding.getBytes(st.nextToken(token)));
      }
    }
**/

    o.write(10); // fin colonne


    return( o.toByteArray() );
   }
   catch( Exception aa) { return(null); }

}



/**
* Contole cohérence entrée
*/
boolean checkIn( String req[] )
{ int i ;
  qry = new String[3];

  for( i = 0 ; i  < req.length && req[i] != null ; i++ )
  {
    qry[i] = req[i].trim();
    if(  qry[i].length() == 0 && !relax )
      break;
  }

  if( i < 2 && !relax)
   { setErr(  "Requete inconsistante: Parametre "+i+" manquant");
     return( false);
   }

 return( true);
}

/**
* Renseigne le where techno
* marque a NOP les atoms du groupe concerne
*/
void setTechnoWhere( int cur , int tech )
{

  int group = atoms[cur].group;
  int i = cur;
  while( atoms[i-1].group == group ) i--;
  if( i > 0 && atoms[i-1].type == Types.OPLOG )
      atoms[i-1].type |= Types.NOP;
  for(  ; i < atoms.length && atoms[i].group == group ; i++ )
    { if( atoms[i].type == Types.CONST )
         switch( tech ) {
          case 1 : URM = atoms[i].val ; break;
          case 2 : CONSTRUCTEUR = atoms[i].val ; break;
          case 3 : TECHNO = atoms[i].val; break;
          case 4 :
                   PSDSTRICT = atoms[i].val.equalsIgnoreCase("'relax'")==false;
                   break;
          case 5:  granEqp( atoms[i].val) ; break;
         }

     atoms[i].type |= Types.NOP;
    }
}

/**
* Renseigne techno
*
*/
boolean setTechno()

{
 int i;

  CONSTRUCTEUR = TECHNO = URM = null;
  PSDSTRICT=true;
  nivEqp = 0;

  for(  i = 0 ; i < atoms.length ; i++ )
    if( atoms[i].fct == Types.WHEREABLE )
       break;

  while(  i < atoms.length && atoms[i].fct == Types.WHEREABLE  )
  { if( atoms[i].type == Types.LNOM )
      { if( atoms[i].val.equalsIgnoreCase("ur") )
          setTechnoWhere(  i , 1 );
        else if(  atoms[i].val.equalsIgnoreCase("constructeur") )
          setTechnoWhere(  i , 2 );
        else if(  atoms[i].val.equalsIgnoreCase("techno") )
          setTechnoWhere(  i , 3 );
        else if(  atoms[i].val.equalsIgnoreCase("psdjoin") )
           setTechnoWhere(  i , 4 );
        else if(  atoms[i].val.equalsIgnoreCase("type_elt") )
           setTechnoWhere(  i , 5 );

      }
    i++;
   }

  if( TECHNO == null ) TECHNO = "0";
  //return( CONSTRUCTEUR != null && URM != null );
return(true);
}

/**
* Retourne la traduction sql
*/
public String getSql()
{
  return( multiple ? null : qSql );

}


public Qry( ClientSql con )
{
 this.con = con;

}

public Qry()
{
  this( (ClientSql) new ClientSpooled() );

}

public boolean parse( String req[] )
{
  //TOPOLOGIE = null;
  //EXTRAGROUP=null;
  //EXTRASELECT=null;
  debug=true;
  if(debug)
  { System.out.println("Qry@parse:");
    for( int j = 0 ; j < req.length ; j++ )
      System.out.println( req[j]==null?"null":req[j] );
  }

  errNiv = 1;
  if( !checkIn(req)) return( false);
  errNiv++;

  if( ! ( new Parse().getAtoms(this) ) )
     return(false);

  errNiv++;

 /*if( !setTechno() )
  {
   setErr( "Parametre inconsistant: UR="+URM+" constructeur="+CONSTRUCTEUR+
           " techno="+TECHNO+"\nparam="+req[1] );
   return( true) ;
  }*/

// System.out.println("TECHNO:"+TECHNO+" CONSTRUCTEUR:"+CONSTRUCTEUR+  " URM:"+URM+" PSDSTRICT:"+PSDSTRICT);

 if(! new Catalog( this ).set() || errCode != 0)
    return( false);

  errNiv++;

  return( new Select().get( this) );
}

public boolean parse( String sel , String wh , String grp )
{ String rq[] = new String[3];
  rq[0] = sel ; rq[1] = wh ; rq[2] = grp;
  return( parse(rq) );
}

public int execute()
{
  if( errCode != 0 ) return(0);
  if( multiple ) return(0);
  try {
  ThrQry tq = new ThrQry( this);
  new Thread(tq).start();
  Thread.currentThread().yield();
  return( tq.getRId() );
  }
  catch( Exception a )
  { return(0);
  }
}

public int execute( String sel , String wh , String grp )
{
  if( !parse( sel , wh , grp ) )
    return( 0 );

  return( execute() );
}
public int execute( String z[] )
{
  if( !parse( z ) )
    return( 0 );

  return( execute() );
}


public void list(boolean tout)
{
  for( int i = 0 ; i < atoms.length ; i++ )
   { Atom a = atoms[i];
     System.out.print( "nom("+i+") -> "+a.val+ "\ttype -> "+
     Types.getName(a)+
           "\tniv:"+a.level+"\tgrp:"+a.group );
     if( a.type == Types.LNOM || tout )
     System.out.println(
       "\tchamp -> "+a.champ+
      "\ttable -> "+a.table+
      "\tbase -> "+a.db+
      "\tserveur -> "+a.con+
      "\tval-> "+(a.val==null?"null":a.val)+
      "\tti-> "+(a.ti==null?"null":a.ti) );
     else
      System.out.println();

   }
}

public void listInfos()
{
  for( Iterator<String> it = tinf.keySet().iterator() ; it.hasNext() ; )
  {
   String s = it.next();
   TableInfo ti = tinf.get(s);
   System.out.println(
   s+
   "\t"+ti.granularite+"\t"+ti.jTopo+"\t"+ti.minutes+"\t"+
   ti.jDate);
   }
}

public Atom[] getAtom() {  return( atoms ); }



}
