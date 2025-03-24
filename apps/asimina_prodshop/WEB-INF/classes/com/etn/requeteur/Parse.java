package com.etn.requeteur;

/**
* Source pour jdk 1.5...
* Sinon supprimer <...>
*/

import java.util.ArrayList;
import java.util.HashMap;


public class Parse {

ArrayList<Atom> atoms;
Qry qy;
int fct;
int group = 0;


/**
* Utilites diverses : (ctypes ISO )
* Pas de la classe Character UTF : on ne parle pas chinois.
*/
int minus( int c ) { return( c|32) ; }
boolean ismath( int c)
{ return(
   c=='+' || c=='-' || c=='*' || c=='/' || c=='%' );
}
boolean iscomp( int c ) { return( c=='=' || c=='>' || c=='<' || c=='!' ) ; }

boolean special( int c ) { return( c=='('||c==')'||c==','); }
boolean isspace( int c)
{ return( c == ' ' || c == '\t' || c == '\r' || c== '\n' ); }
boolean isalpha( int car )
{ return( car == '_' ||
    ( car >= 'A' && car <= 'Z' ) ||
    ( car >= 'a' && car <= 'z' ) );
}
boolean isdigit( int c ) { return(  (c >= '0' && c <= '9') || c == '.' ); }
boolean isalnum( int c ) { return( isdigit(c) || isalpha(c) ); }
boolean ispunct( int c ) { return( c == ')' || c == '(' || c == ',' ); }
boolean ismyesc( int c ) { return( c == '`'); }

static final String mots = "/and/or/like/between/not/is/in/null/limit/interval/date_add/distinct/case/when/end/" ;

static final String interne = "/minute/heure/jour/semaine/mois/annee/";

boolean issql( String mot )
{
  return( mots.indexOf("/"+mot.toLowerCase()+"/") != -1 );
}

boolean isinterne( String mot )
{
  return( interne.indexOf("/"+mot.toLowerCase()+"/") != -1 );
}


String trimVirg( String s )
{ char c[] = s.toCharArray();
  int i , j ;
  for( i = 0 ; i < c.length && ( c[i] == ' ' || c[i] == ',' ) ; i++ );
  for( j = c.length - 1 ;  j >= 0 && ( c[j] == ' ' || c[j] == ',' ); j--);
  return( new String( c , i , j - i + 1) );
}

/**
* decode un atom
* renseigne type, val etc...
* retourne :
* position dernier car lu :
* 0 si plus rien a lire.
* -1 echec
*/
int getAtom( Atom a , char b[] , int pos , int len)
{
  int i;
  int c = 0 ;

  
  while( pos < len && isspace( c = b[pos])) pos++;
  if( pos == len ) return(0);

  if( c == '{' ) // SPECIAL
   { i = pos + 1;
     for( i =  pos + 1 ; i < len ; i++ )
      if( b[i] == '}' && b[i-1] != '\\' )
          break;

     if(i >= len ) return( Types.INCONNU);

     a.type = Types.ESCAPE ;

     switch( a.fct ) {
     case Types.WHEREABLE :
     // un ajout dans la jointure
     //a.val = /* qy.TOPOLOGIE= */

    a.val = " " +
    trimVirg(new String(b, pos+1 , i - pos - 1))+ " ";
     return(i+1);

     case  Types.GROUPABLE :
     // un ajout dans GROUPABLE
     a.val = " " +trimVirg(new String(b, pos+1 , i - pos - 1))
       + " ";
     return(i+1);

     case Types.SELECTABLE :
     a.val =  " "+
           trimVirg(new String(b, pos+1 , i - pos - 1))+ " ";

     return(i+1);

     
     case Types.SELECTABLE_GRAPH :
    	 
    	 a.val =  " "+
         trimVirg(new String(b, pos+1 , i - pos - 1))+ " ";
    	 //System.out.println("a.val ="+a.val );
   return(i+1);
   
  case Types.WHEREABLE_GRAPH :
    	 
    	 a.val =  " "+
         trimVirg(new String(b, pos+1 , i - pos - 1))+ " ";
    	 //System.out.println("a.val ="+a.val );
   return(i+1);

     default :
     return(-1);
     }

   }

  if( ismyesc( c) )
  {
    for( i = pos + 1 ; i < len && !ismyesc( b[i] ); i++ );
    a.val = new String( b  , pos + 1 , i - pos - 1).toLowerCase();
    a.type = Types.LNOM;
    return(i+1);
  }

  if( isalpha( c ) )
  { for( i = pos + 1 ; i < len && isalnum( b[i] ); i++ );
    a.val = new String( b , pos , i - pos ).toLowerCase();

    for( ;  i < len && isspace(b[i]) ; i++);

    if( a.fct == Types.WHEREABLE || a.fct == Types.SELECTABLE || a.fct == Types.WHEREABLE_GRAPH || a.fct == Types.SELECTABLE_GRAPH   ) // voir si OPLOGIQUE
     { if( issql( a.val ) )
       {  a.type = Types.OPLOG;
         
       if( a.val.equals("distinct") ){
    	   a.val = ""+a.val+" ";
       }else{
       		a.val = " "+a.val+" ";
       }
          
          return(i);
       }
     }


    if( i >= len ) a.type =  Types.LNOM ;
    else
    { if( b[i] == '(' )
      {
    	//System.out.println("isinterne="+isinterne(a.val)+"a.val-->"+a.val);
    	if(isinterne(a.val)) a.type = Types.INTERNE;
          else a.type = Types.FONCTION;
      }
      else  if( "as".equalsIgnoreCase(a.val) == false )
           a.type = Types.LNOM;
      else
       { a.type = Types.AS ;
         pos = i;
         for( ; i < len && isspace(b[i]); i++ ) ;
         if(  b[i] == '"' )
          { i++;
            while( i < len && (b[i]!='"' || b[i-1]=='\\') )
               i++;
            i++;
            a.val = " as " +new String( b , pos , i - pos );
          }
         else
         { for( ; i < len && isalnum(b[i])  ; i++);
           a.val = " as " +new String( b , pos , i - pos );
         }
       }
    }
    return( i );
  }

  if( ispunct(c) )
  {
    a.val = ""+(char)c ;
    a.type = Types.PUNCT;
    return( pos + 1 );
  }

  if( c == '\'' )
  {
    for( i = pos + 1 ; i < len  ; i++ )
      if( b[i] == '\'' &&  b[i-1] != '\\' )
        break;

    if( i== len )
     { qy.setErr("Manque fermeture par ': "+
          new String( b, pos , len - pos ) );
        return(-1);
     }
    i++;
    a.val = new String( b , pos , i - pos );
    a.type = Types.CONST;
    return( i );
  }

  if( isdigit(c) )
  {
    for( i = pos + 1 ; i < len && isdigit(b[i]) ; i++ );
    a.val =  new String( b , pos , i - pos );
    a.type = Types.CONST;
    return(i);
  }

 if( ismath(c) )
 { a.val = ""+(char)c;
   a.type = Types.ARITHM;
   return(pos+1);
 }

 if( iscomp(c) )
 { for( i=pos + 1; i < len && iscomp(b[i]); i++ );
   a.val = new String( b , pos , i - pos);
   a.type = Types.OPSQL ;
   return(i);
 }

 return( Types.INCONNU);

}

void setGroup()
{

  group++;
  for( int i = atoms.size() - 1 ; i >= 0 ; i-- )
  {
     Atom a = atoms.get(i) ;
     if(a.group == 0 ) a.group = group;
       else return;
  }

}


/**
* Constitution de la liste des atoms
* au cas false err est renseigne.
*/
boolean listAtoms(char buf[] , int pos , int len , int lev )
{
  int i;
  boolean between = false;


  while( pos < len )
  {
   Atom a = new Atom();
   a.fct = fct;
   a.level = lev;


   if( ( i = getAtom( a ,buf , pos , len ) ) <= 0 )
   {
    if( i == -1 )
     {
      qy.setErr( "? :"+new String( buf , pos , len - pos ) );
      return(false);
     }

    // eof array
    break; //return( true);
   }


   if( a.type == Types.NOATOM  )
   { pos = i;   continue; }

/*   if( a.type == Types.LNOM && a.val.equalsIgnoreCase("psdate") )
       a.type = Types.PSDATE;
*/

   atoms.add(a);
   if( a.type == Types.OPLOG && " between ".equals(a.val) )
   { between = true;
   }


   if( ( a.type == Types.PUNCT && a.val.charAt(0) == ',' ) ||
       ( fct == Types.WHEREABLE && a.type == Types.OPLOG && a.val.equals(" and ") ) )
     if( between ) between = false;
       else setGroup();

   pos = i;
   if( a.type == Types.FONCTION)
      { int c = 1;
        int j;

        for(  i = pos + 1; c > 0 && i < len ; i++ )
        {  if( buf[i] == '(' ) c++ ;
           else if(buf[i] == ')') c--;
        }

        if( c != 0 )
        { qy.setErr( "Manque ')':"+new String( buf , pos , len - pos) );
          return(false);
        }

        lev++;
        if(!listAtoms( buf , pos , i , lev ))
           return(false);
        lev--;

        pos = i;
     }

  }

 if(lev==0) setGroup();
 return(true);
}


boolean parse( String qry ,  int fct)
{ char buf[]  = qry.toCharArray();
  this.fct = fct;
  return( listAtoms( buf , 0 , buf.length , 0));
}


public boolean getAtoms( Qry qy )
{
  atoms = new ArrayList<Atom>();
  this.qy =  qy;
  group = 0;

 
  
  
  
  
  /*if( qy.relax == false )
    { if( !parse( qy.qry[0] ,  1 ) ||
          !parse( qy.qry[1] ,  2 ) ||
          !parse( qy.qry[2] ,  4 ) )
       return( false );
    }
   else
   {
     if( qy.qry[0] != null && parse( qy.qry[0] ,  1 ) == false )
        return(false);

     if( qy.qry[1] != null && parse( qy.qry[1] ,  2 ) == false )
        return(false);

     if( qy.qry[2] != null && parse( qy.qry[2] ,  4 ) == false )
        return(false);
     
    

   }*/
  
  HashMap p = qy.ctx;
  //System.out.println("parse graphTableSelectClause="+p.get("graphTableSelectClause"));
  if( p!=null ){
 	 makeSql m = new makeSql();
 	 	String tab[]= m.getGraphColumn(p);
 	 	String tab2[] = m.getGraphColumnAlias(p);
 	 	
 	 	String a = "";
 	 	if(tab!=null){
	 	 	for(int i =0;i<tab.length;i++){
	 	 		//a+=(a.equals("")?"":",")+"("+tab[i] + ") as " + tab2[i];
	 	 		//a+=(a.equals("")?"":",")+""+tab2[i];
	 	 		a+=(a.equals("")?"":",")+"("+tab2[i] + ") as " + tab2[i];
	 	 	}
 	 	}
 	 	
	  	//parse( ""+p.get("graphTableSelectClause") , Types.SELECTABLE_GRAPH );
 	 	if(!a.equals("")){
 	 		System.out.println("a===>'"+a+"'");
 	 		parse( a , Types.SELECTABLE_GRAPH );
 	 	}
 	 	
 	 	//System.out.println("graphTableWhereClause===>'"+p.get("graphTableWhereClause")+"'");
 	 	if(p.get("graphTableWhereClause")!=null){
 	 		parse(  ((""+p.get("graphTableWhereClause")).equals("")?"":" and ") + (""+p.get("graphTableWhereClause")) , Types.WHEREABLE_GRAPH ); //p.get("graphTableWhereClause")==null
 	 	}
 	 	
 	   /*String tab5[] = m.getGraphWhereColumn(p);
 	   
	 	a="";
  	   if(tab5!=null){
 		  for(int i=0;i<tab5.length;i++){
 			 a+=(a.equals("")?"":",")+tab5[i];
 		  }
 		 parse( a , Types.WHEREABLE_GRAPH );
  	   }*/
 	 	
 	 	
  }
  
  if( !qy.qry[0].equals("")) parse( qy.qry[0] ,  1 );
  if( !qy.qry[1].equals("")) parse( qy.qry[1] ,  2 );
  if( !qy.qry[2].equals("")) parse( qy.qry[2] ,  4 );
  

  
  

   qy.atoms  = new Atom[atoms.size()];
   atoms.toArray(qy.atoms) ;
   atoms = null;
   return(true);
}


}

