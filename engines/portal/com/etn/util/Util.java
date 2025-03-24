package com.etn.util;

import java.util.Properties;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import org.json.*;


public class Util
{
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

	public static String removeAccents( String  s )
	{
	  char c[] = s.toCharArray();
	  for( int i = 0 ; i < c.length ; i++ )
	   if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
	  return( new String( c ) );
	}

	public static String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
 
	public static int parseNullInt(Object o)
	{
		if (o == null) return 0;
		String s = o.toString();
		if (s.equals("null")) return 0;
		if (s.equals("")) return 0;
		return Integer.parseInt(s);
	}
	
	public static double parseNullDouble(Object o)
	{
		if (o == null) return 0;
		String s = o.toString();
		if (s.equals("null")) return 0;
		if (s.equals("")) return 0;
		return Double.parseDouble(s);
	}
	
	public static String getCharset(String contentType)
	{
		String charset = "UTF-8";//default value
		if(contentType.indexOf("charset=") > -1)
		{
			charset = contentType.substring(contentType.indexOf("charset=") + 8);
			if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
		}
		return charset;		
	}
}

