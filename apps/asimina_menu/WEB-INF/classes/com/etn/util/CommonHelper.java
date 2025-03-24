package com.etn.util;

import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.util.Logger;

/**
 * This class provides some helper functions to get the prefix for URLs where the content will be cached eventually
 * Any changes to this class means it must be copied in all webapps
 */
public class CommonHelper {

    public static String parseNull(Object o) {
        if (o == null) return ("");
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }

    public static String escapeCoteValue(String str){

		if(str != null && str.length() > 0 ){
			return str.replace("&", "&amp;").replace("'", "&#39;").replace("\"", "&#34;").replace("<", "&lt;").replace(">", "&gt;").replace("/", "&#x2F;").replace("`", "&#x60;").replace("=", "&#x3D;").replace("\\","&#92;");
		}
		else{
			return str;
		}
	}

	final static int UC16Latin1ToAscii7[] = {
	'A','A','A','A','A','A','A','C',
	'E','E','E','E','I','I','I','I',
	'D','N','O','O','O','O','O','X',
	'0','U','U','U','U','Y','S','Y',
	'a','a','a','a','a','a','a','c',
	'e','e','e','e','i','i','i','i',
	'o','n','o','o','o','o','o','/',
	'0','u','u','u','u','y','s','y' };

	private static int toAscii7( int c )
	{ if( c < 0xc0 || c > 0xff )
		 return(c);
	  return( UC16Latin1ToAscii7[ c - 0xc0 ] );
	}

	public static String ascii7( String  s )
	{
	  char c[] = s.toCharArray();
	  for( int i = 0 ; i < c.length ; i++ )
	   if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
	  return( new String( c ) );
	}

	private static int compAscii7( String a , String b )
	{ if( a==null) return( b==null?0:1);
	  if( b == null ) return(-1);
	  return(  ascii7(a).compareTo( ascii7(b) ) );
	}

	public static boolean equals7( String a , String b )
	{ return( compAscii7( a ,b ) == 0 ); }

	public static String removeAccents(String src)
	{
		if(src == null) return "";
		src = src.trim();
		return ascii7(src);
	}

    public static String removeSpecialCharacters(String s) {
        if (s == null) return "";
        //on UI we replace space by -
        s = s.replace(" ", "-");
        //on UI we are only allowing - in file name/path so we do here
        //return s.replaceAll("[^A-Za-z0-9-]", "");
        return s.replaceAll("[^\\p{IsAlphabetic}\\p{Digit}-]", "");
    }

}
