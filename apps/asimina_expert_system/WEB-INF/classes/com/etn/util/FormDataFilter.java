package com.etn.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.FilterInputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;


/**
* Filtre form-data.
* <pre>
* Filtre un Stream de type MultiPart
* envoyé par le navigateur au cas put ou post
* et encoding enctype='multipart/form-data' 
*
* Chaque field de la form est encapsulé dans un header
*
* un header consiste en:
* un marqueur ----XXX
* le header Content-Disposition:
* d'autres headers non obligatoires
* Nota:
* Le separateur de ligne est CR/LF (13/10) suivant RFC
*
*
* Pour recuperer les données envoyées
* on boucle sur getField
* puis si le type du field est octet-stream
* methode isStream() true 
* on appelle les methodes read pour lire les datas
* voir exemple main
* </pre>
*/


public class FormDataFilter extends FilterInputStream {

byte buf[];
int count;
int pos;
OutputStream debug = null;
/**
* state : 0 indefini
*         1 in header field (un marker a ete lu)
*         2 in value  field
*/
int state;
byte marker[];
int markPos;
/**
* retourne une ligne de longueur < 512 cars
* dont le separateur est CR/LF ou LF
* Si EOF ou ligne > 512 retourne null
* Si ligne Vide retourne Sring(0) ""
*/
private String gets()
{
  try
  {
  byte b[] = new byte[512] ;
  int c;

  for( int i = 0 ; i < b.length ; i++ )
  { if( ( c  = _read() ) == -1 ) return(null );
    if( c == 13 || c == 10 ) 
    { if( c == 13 ) _read(); 
      return( new String( b , 0 , i ,"UTF-8") );
    }
    b[i] = (byte)c ;
  }

 return( null);
 }
 catch (Exception e) { return( null); } 
}
/**
* retourne la valeur d'un control jusqu'au l'apercu du marqueur ----XXX
*/
private String getValue()
{
  try
  {
        int i;  
          String val="";
  while( ( i = read() ) != -1 )
  { val += String.valueOf((char)i);
    for( i = pos ; i < count ; i++ )
       if( buf[i] == 13 ) break;
        val += new String(buf , pos , i - pos,"UTF-8");
        pos = i;
  } 
  return(val);
 }
 catch (Exception e) { return( null); } 
}
/**
* Initialise la paire keyval de l'argument (name value)
* et le state courant 
* return 1 si value est de type Stream
* 0 si value n'est pas  de type Stream
* -1 sur EOF , erreur ou state != 0
*
* un header consiste en:
* un marqueur ----XXX
* le header Content-Disposition:
* d'autres headers non obligatoires
* Nota:
* Le separateur de ligne est CR/LF (13/10) suivant RFC
*
* la cle est le nom du control et le content type 
* la valeur est la value du control
* au cas file le nom du fichier ( filename )
* renvoit true si le reader est de type octet-stream
* false sinon
* 
*/
public int getFieldStream( String keyval[] )
{
 int i;
 String head ;

  if( state != 0 ) return( -1 );

  System.out.println("skip:"+new String( buf , pos , 62) );
  if( skipMarker() != 1 ) return( -1 );
  System.out.println("skip retour:true"+new String( buf , pos , 62) );
  
  state = 1;
  head = gets();
 

  if( head == null ) return( -1);
  if( ( i = head.indexOf("name=\"") ) == -1 )
     return(-1);

  String nom = head.substring(i+6,head.indexOf('"',i+6) );
  String val = null;
  String cType ;
 i = head.indexOf("filename=\"");
 if( i != -1 )
    {  val = head.substring(i+10,head.indexOf('"',i+10) );
           // get content type
           cType =gets();
          if (cType != null && cType.length() > 0 && cType.indexOf("Content-Type:") > 0 )
           cType = cType.substring(cType.indexOf("Content-Type:")+13,cType.length() );
          
       while( gets().length() != 0 );
       if( val.length() != 0 )
          state = 2;
       else { gets(); state = 0; }
     
     }
  else
      { while( gets().length() != 0 );
        val = getValue();
                cType = "form-data";
        state = 0;
      }

  keyval[0] = nom;
  keyval[1] = val;
  keyval[2] = cType;
  return(state);
}
/**
* retourne une paire key/val
* si la cle est du type inputStream 
* il faut appeler immediatement les methodes reads
* pour avoir les datas.
*/
public String[] getField()
{ String a[] = new String[3];
  if(getFieldStream( a ) != -1  ) 
      return(a);
  return( null );
}

private void iniMarker()
{
  int i ;

  for( i = 0 ; i < count && buf[i] > 31 ; i++ );
  marker = new byte[i] ; 
  System.arraycopy( buf , 0 , marker , 0 , i );
  
  state = 0;
}
private void fill(int start)
         throws IOException
{
   int c = in.available();
   if( c <= 0 )
   { c = in.read();
     if( c != -1 )
       buf[start++] = (byte)c;
   }
   if( c != -1 )
    count  = in.read ( buf , start , buf.length - start);
   else 
    count = -1;

  
   pos = 0;
   if( start != 0 )
     if( count == -1 ) count = start;
       else
         count += start;

   if( debug != null )
    debug.write( buf,0,count>0?count:0);

  
 
}

private boolean checkMarker()
         throws IOException
{
  int lg = count - pos ;

  if( lg > 0 && buf[pos] != 13 ) return( false );

  if( lg < ( marker.length + 2 )  )
  { if( pos != 0 )
    System.arraycopy( buf , pos , buf , 0 , lg );
    fill(lg);
    if( count <( marker.length + 2 ) ) return(false);
  }
  lg = pos + 2;
  for( int i = 0 ; i < marker.length ; i++ )
   if( buf[lg+i] != marker[i] )
      return(false);

  
  state = 0;
  pos += 2; // CRLF
  return(true);
}
private int _read()
         throws IOException
{

  if( count == -1 ) return(-1);
  if( pos == count )
   {  fill(0); 
      if( count <= 0 ) return(-1);
   }

  return( 255 &  buf[pos++] );
}

public int read()
         throws IOException
{
 
  if( checkMarker() ) return(-1);
  return( _read() );
}


public int  read( byte b[],int start , int lg)
         throws IOException
{ 
  int c;
  for( int i = 0 ; i < lg  ; i++ )
   {
     if( ( c = read() ) == -1 ) return( i);
     b[i+start] = (byte)c;
   }
  return(lg);
}
public int  read( byte b[])
         throws IOException
{ return( read( b , 0 , b.length ) ); }

/**
* Le OutputStream doit etre BufferedOutputStream
* pour perfs
*/
public void writeTo( OutputStream out )
         throws IOException
{ int i;

  while( ( i = read() ) != -1 )
  { out.write(i);
    for( i = pos ; i < count ; i++ )
       if( buf[i] == 13 ) break;
    out.write( buf , pos , i - pos );
    pos = i;
  } 
}
/**
* retourne:
* 0 pas marker
* 1 marker
* -1 eof
**/
private int skipMarker()
{ 
 try {
  
  for( int i = 0 ; i < marker.length ; i++ )
   if( _read()  != marker[i] ) return(0);
  
  int c, z = 0;
  while ( (c =_read() ) != 10 && c !=-1 ) 
    if( c == '-') z++;;
  
  return(z==0?1:-1);
 } catch ( IOException e ) { return( -1 ); }
}

private boolean skip( int n )
         throws IOException
{
  int i = count - pos ;


  while ( i < n ) 
   { n -= i ;
     fill(0);
     if( count <= 0 ) return( false);
     i = count;
   }
     
  pos += n ;    
  return( true );   
}

public FormDataFilter( InputStream in )
         throws IOException
{
  super(in);
  debug = null;
  buf = new byte[4096];
  fill(0);
  iniMarker();
  state = 0; 
}

public FormDataFilter( InputStream in , byte buffer[] , int lus, OutputStream dbg )
         throws IOException
{
  super(in);
 
  debug = dbg;
  buf = buffer;
  if( lus == 0 ) 
     fill(0);
  else
    { count = lus;
      pos = 0;
    }
  iniMarker();
  state = 0;
}


public FormDataFilter( InputStream in ,OutputStream debug)
         throws IOException
{

  super(in);
  this.debug = debug;

  buf = new byte[4096];
  fill(0);
  iniMarker();
  state = 0; 
}



public boolean isStream() { return( state == 2); }

/************** Exemple
public static void main( String a[] )
         throws IOException
{
  FormDataFilter frm = new FormDataFilter( System.in );
  
  String f[] ;
  int z = 0;

  while( ( f = frm.getField() ) != null ) 
  {
    System.out.println("\n******\nField:"+f[0] +"->"+f[1]+
      "\n******");
    if( frm.isStream() )
    {
      String fil = f[1];
      if(fil.length() == 0 )
         fil = "a"+z;
      
      FileOutputStream out = 
        new FileOutputStream("/tmp/jkl/"+fil );
      frm.writeTo( out);
      out.close();
    }
  }


}
*************************************************/
}

