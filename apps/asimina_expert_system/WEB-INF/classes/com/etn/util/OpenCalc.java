package com.etn.util;

import java.io.*;
import java.util.zip.*;

/** 
 * OpenCalc.
 * Lecture d'un OpenDocument généré par excel format *.ods.
 * Sortie texte tabulé ( encoding de la source ).
 * 
*/
public class OpenCalc {

int sheet;   //  0:all , 1 sheet1 , 2 sheet2 ... 
InputStream in;
OutputStream out;
byte buf[];
int pos, lus, end ;
boolean ignore =false;
long rows;

/**
 * Parsing du fichier content.xml préalablement unzippé.
 */
public OpenCalc( OutputStream out, InputStream in , int bufLen, int sheet )
{ 
  this.sheet = sheet;
  this.in = in;
  this.out = out;
  buf = new byte[bufLen] ;
  rows = pos = lus = 0;
}

/**
 * Parsing du document OpenDoc ( *.ods ).
 */
public OpenCalc( OutputStream out , ZipInputStream zipStream , int sheet)
throws Exception
{ 
  ZipEntry entry;

  while( ( entry = zipStream.getNextEntry()) != null ) 
    if( entry.getName().endsWith("content.xml") ) 
       break;

  this.out = out;
  this.in = zipStream;
  buf = new byte[65536];
  rows = pos = lus = 0;
  this.sheet = sheet;

}

/**
 * fill.
 * Alimente buffer.
 */
int fill()
throws Exception
{ 
  int i;

  if( pos != 0 && lus > pos ) 
   { 
     lus -= pos;
     System.arraycopy( buf , pos , buf , 0 , lus );
   }

  i = in.read( buf , lus , buf.length  - lus );
  if( i > 0 )
    lus += i;
  
  pos = 0;
  return(i);
}

/**
 * atoi : Rend entier a partir position i de buf.
 * 0 sur non digit.
*/
int atoi( int i )
{ 
  int u = 0 ;
  int c;
  
  while( ( c = 255 & buf[i++]) >= '0' && c <= '9' ) 
   { u *= 10 ; u += c - '0' ; }

  return(u);
}

/** 
 * indexOfBuf.
 * Recherche dans buffer du byte c à partir postion from limite end.
 * retourne postion ou -1.
 */
int indexOfBuf( int from, int c ) 
{ 
   for( int i = from ; i < end ; i++ ) 
     if( buf[i] == c ) return( i  ) ;

   return(-1);
}

/**
 * indexOfBuf.
 * Recherche la première sequence de bytes = toSearch
 * à partir de from limite end.
 * retourne position ou -1.
 */

int indexOfBuf( int from , String toSearch )
{ 
   int i , j;
   byte quoi[] = toSearch.getBytes();
   int len = quoi.length;

   while( ( i = indexOfBuf( from , quoi[0] ) ) != -1 )
   { 
    if( (i+len ) > end ) return(-1);
    for( j = 1 ; j < len && buf[ i + j] == quoi[j]  ; j++) ;
    if( j == len ) return(  i ); 
    from = i+1;
   }

   return( -1 );
}
  
/**
 * Ecrit le text de la cellule si existe.
 */
void printText( int s )
throws Exception
{ 
  int p,q;
  
  p= indexOfBuf( s , "<text:p>" );
  if( p == -1 ) return;
  p += 8;
  //q = indexOfBuf( p , '<' );
  q = indexOfBuf( p , "</text:p" );
  if( q == -1 ) return;
  
//  out.write( buf , p , q - p );
  String _str = new String(buf, p, q-p);
  _str = _str.replaceAll("<text:s(.+?)?/>"," ");
  out.write( _str.getBytes()  );

}

void printIsoDate( int s )
throws Exception
{ 
	int p;	
        //sometimes the timestamp is missing from date so we checking the location of next double qoute
        //and will fetch string upto that. So p-s can be 10 or 19
	p = indexOfBuf(s, "\"");
        //System.out.println(s + " " + p);
	out.write( buf , s , p-s); 
}

/**
 * Parse une cellule.
 * Tiens compte du colspan si < 60
 */
int parseCell( int src )
throws Exception
{ 
   int p, q, r;
   int i;

   // Cellule 
   ignore = false;


   p = indexOfBuf(src, "<table:table-cel");
   if( p == -1 || ( q = indexOfBuf(p,'>')) == -1 ) return(-1);
   if( buf[q-1] == '/' ) 
   { 
     end = q;
    // Colspan ?
    if( ( p = indexOfBuf(p,"number-columns-repeated=" ) ) != -1 )
    { i = atoi( p + 25 );
      ignore = true;     
      if( i < 60 )
       while( i-- > 0  ) out.write(9);
    }
    return( q - src);
   }

   q++;
   // fin cellule
   if( ( end = indexOfBuf( q  ,  "</table:table-cel") ) == -1 ) 
    return( -2 );

   if( ( p =  indexOfBuf( p, "office:date-value=") ) != - 1 )
     printIsoDate( p + 19 );
   else
     printText( q );

   return( end + 10  - src  );
}
   


int printRow()
throws Exception
{ 

 int p , i;
 int endRow;
 

 end = lus;
 p = indexOfBuf( pos , "<table:table-row" ); 
 if( p == -1 ) return(-1);
 
 endRow = indexOfBuf( p , "</table:table-row>" );
 if( endRow == -1 ) return(-2);

 end = endRow ;

 // Ignore empty rows
 if( indexOfBuf( p ,"number-rows-repeated=") != -1  )
    return(  endRow + 17 - pos );
  
 rows++;

 p = indexOfBuf( p , '>' );
 p++;

 while( ( i = parseCell(p) ) > 0 )
 {
   p += i;
   if( ignore == false ) out.write(9);
   end = endRow;
 }

 out.write(10);


 return( endRow + 17 - pos );
}

public void run() 
throws Exception
{ 
  int i  ;
 

   while( fill() > 0 )
   { 
     while( ( i = printRow() ) > 0 )
      pos += i;
   }
}




public static void main(String a[])
throws Exception
{ 
 OpenCalc calc = null;
  

  if( a.length == 0 )
  { 
    calc = new OpenCalc( System.out , System.in , 120000,0 );
    calc.run();
    return;
  }

  ZipInputStream z = new ZipInputStream( 
       new FileInputStream( a[0] ) );

   calc = new OpenCalc( System.out ,z,0 );
   calc.run();
   z.close();


}

}

   

