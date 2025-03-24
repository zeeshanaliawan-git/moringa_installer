/**
 * http://bl.ocks.org/mbostock/4063530
*/

package com.etn.util;

import java.io.Writer;
import java.io.OutputStreamWriter;
import com.etn.lang.ResultSet.ArraySet;

/**
 * Mise en forme hiérarchique pour 3djs d'un ArraySet 
 * trié par Cols 0..n-2 ou la colonne n-1 est numérique.
 * nota : On respecte les préfixes hardcodés 3djs name et children
 * et la syntaxe 3djs où la dernière valeur de droite est un entier
 * ne necessitant donc pas de protection par ""
*/


public class ArJson {

final boolean debug ;
// Pour debug : On fait une identation pour lisibilité du resultat 
final String indents = "\t\t\t\t\t\t\t\t\t\t\t" ;
final ArraySet ar;  
int lastCol;
String keys[] ;
int y = 0, x = 0;
int niv=0;
// Le dernier car significatif ecrit est '}'
boolean  needVirgule = false;

Writer out;
boolean ioErr = false;

void print( int c ) 
{ try { out.write(c); } catch(Exception e){ioErr=true;} }

void print( String s ) 
{ try { out.write(s); } catch(Exception e){ioErr=true;} }



/**
 * indent.
 * en debug : on rend lisible
*/
void indent(int niv )
{ 
  if( debug)
    print("\n"+indents.substring(0,niv));

}
  
/**
 * writeK.
 * Ecriture d'une nouvelle clef.
 * Important : si le dernier caractere écrit est '}' on ajoute une virgule avant l'écriture.
*/
void writeK( String cle )
{
  indent(niv);
  if( needVirgule ) 
   { print(',');
     indent(niv);
   }
  print("{");
  indent(niv);print("\"name\": \""+cle+"\",");
  indent(niv);print("\"children\": [" );
  needVirgule=false;
}

/**
 * Ecriture de la valeur dernière clef de droite.
 * soit  name = val[x]  , size : number  ( name et size pour 3dJs ).
*/
void appendVal( ) 
{ 
  indent(niv);
  if( needVirgule ) print( ',' );
  print( "{ \"name\": \""+ar.value(y,x)+"\" ");
  print(", \"size\": "+ar.value(y,x+1)+" }" );
  needVirgule=true ;
}

/**
 * depile
 * @param to : index de gauche devenant courant.
*/
void depile( int to)
{ 
  while( niv != to ) 
  { indent(niv);
    print("]");
    niv--;
    indent(niv);
    print("}" );
    needVirgule=true;
  }
}

/**
 * parseEq.
 * Rend la position de gauche du row cur.
 * @param cur : un nouveau row.
 * @return index col.
*/

int pereEq( int cur) 
{
  int i;
  
  for( i = 0 ; i < cur ; i++ )
   if( !keys[i].equals( ar.value(y,i) ) )
     return(i);
  
  return(i);
}

/**
 * build.
 * Construction du json resultat via appel récursif.
 * Les globales de la classe ont été initialisées.
*/
void build()
{

 while( x < lastCol  ) 
  { keys[x] = ar.value(y,x);
    writeK( keys[x] );
    niv++;
    x++;
  }
  
 if( ioErr ) return;  
 appendVal();   

 int n=0;
 while( y  < ar.Rows ) 
 { y++;
   if( (n=pereEq( x )) == (x) ) 
     appendVal();
   else
    break;
 }
     
 
 if( y >= ar.Rows )
 { depile(0);
   return;
 }

 depile(n+1);
 x = n;

 if( ioErr) return;
 build();

}

/**
 * ArJson.
 * @param ar : Un ArraySet trié col 0..lastCol.
 * @param lastCol : Avant derniere colonne.
 * @param out : Le flux de sortie.
 * @param debug : Indentation si true
*/
public ArJson ( ArraySet ar , int lastCol , Writer o, boolean debug )
{ 
  this.ar = ar;
  this.keys = new String[lastCol] ;
  this.lastCol = lastCol - 1 ;
  this.out = o;
  this.debug=debug;
  writeK("debut");
  niv++;
  build();
  if( ioErr ) System.err.println( "OutputStream erreur" );
}

public ArJson ( ArraySet ar , Writer o, boolean debug )
{ this( ar , ar.Cols - 1 , o , debug ); }

public ArJson ( ArraySet ar , Writer o )
{ this( ar , ar.Cols - 1 , o , false ); }

public ArJson ( ArraySet ar )
{ this( ar , ar.Cols - 1 , new OutputStreamWriter(System.out) , false ); }

public ArJson ( ArraySet ar, boolean debug )
{ this( ar , ar.Cols - 1 , new OutputStreamWriter(System.out) , debug ); }


public static void main( String a[] )
throws Exception
{
   String qy = 
    "select SQL_BIG_RESULT hotspot.`dr`,hotspot.`groupe`,hotspot.`enseigne`,hotspot.`nom_de_site`,hotspot.`nb_de_ch_total`/* ,hotspot.`nb_de_ch_couvertes` */  "+
    " from hotwifi.hotspot where 1=1 and (((hotspot.`nb_de_ch_total`>'0') and (hotspot.`dr` like '%' ) and "+
    " (hotspot.`groupe` like '%' )  "+
    //" and (hotspot.`enseigne` in ('ibis','formule 1','Balladins','Comfort Hotel','Novotel','La poste','Mac donald''s','Quick')) "+
    ")) "+
    " group by hotspot.`dr`,hotspot.`groupe`,hotspot.`enseigne`,hotspot.`nom_de_site` LIMIT 10000; " ;

com.etn.Client.Impl.ClientDedie Etn = 
  new com.etn.Client.Impl.ClientDedie( 
   "MySql",
   "com.mysql.jdbc.Driver",
   "jdbc:mysql://127.0.0.1:3506/reqv3_hotwifi?user=root&password=" );

 ArraySet ar =  new ArraySet( Etn.execute(qy) ) ;
 ArJson z = new ArJson( ar, false );
 
}

}

