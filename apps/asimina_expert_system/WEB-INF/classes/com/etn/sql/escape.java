package com.etn.sql;

public class escape {
/**
 * Ignore les \
 * Double les ' si présent
*/
public static String sql( String in )
{
  if( in == null ) return(in);
  int i,j;
  int l = in.length();
  char n[] = new char[l+l]; // au plus 2 len
  char c;
  boolean subs=false;

  for( j = i = 0 ; i < l ; i++ )
  { 
    c = in.charAt(i);
    if( c == '\\' )
     subs = true;
    else
     { if( c == '\'' )
         n[j++] = c ;
        n[j++] = c;
     }
     
   }
  
  if( j != i || subs)
    return( new String( n , 0 , j) );
		
  return(in);
}

public static String cote( String in )
{
  if(in == null ) return( "null");
  return("'"+sql(in)+"'");
}

static int decodeHtml( char b[] , int start , int end )
{
   int c = (int) b[start];
   if( c == '#' )
     return( Integer.parseInt( new String( b, start + 1, end - start - 1 ) ));
    else
    { String s = new String( b,start , end - start );
      System.out.println(s);
      
      if( "amp".equals(s) ) return('&');
      if( "lt".equals(s) ) return('<');
      if( "gt".equals(s) ) return('>');
      return(0);
     }   


} 
public static String html( String in )
{
  if( in == null ) return(in);
  int l = in.length();
  char buf[] = new char[l];
  int i,j;
  int c;
  int esc = 0,escp=0;
  
  
 for( j = i = 0 ; i < l ; i++ )
  { c = in.charAt(i) ;
    if( esc != 0)
    { 
      if( c == ';')
        { c = decodeHtml( buf,escp + 1, j) ;
          if( c != -1 ) 
           { buf[escp] = (char)c;
             j = escp + 1;
           }
          else buf[j++] = ';';

          esc =  0;
          continue;
        }
      if( c == '&' ){  escp = j; esc = 0 ; }
      buf[j++] = (char)c;
      if( ++esc > 10 ) esc = 0;
    } 
    else
    { if( c == '&' ) { esc = 1; escp = j; }
      buf[j++] = (char)c ;
     }        
  }

  if( j != i )
    return( new String( buf , 0 , j) );
  return(in);
}



}
