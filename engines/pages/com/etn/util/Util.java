package com.etn.util;

import com.etn.beans.Etn;

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
	private static final int ESC_CHAR = (int) '\\';
    private static final String ESC_STR = "\\\\";
    private static final String ESC_PLCHOLDR = "#SLS#";

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
		return parseNullInt(o, 0);
	}
	
	public static int parseNullInt(Object o, int defaultValue)
	{
		if (o == null) return defaultValue;
		String s = o.toString();
		if (s.equals("null")) return defaultValue;
		if (s.equals("")) return defaultValue;

		int v = defaultValue;
		try {
			v = Integer.parseInt(s);
		} catch (Exception e) {}
		
		return v;
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

    public static String escapeCote3(String str) 
	{
        if (str == null || str.trim().length() == 0) {
            return escape.cote(str);
        }
        else if (str.indexOf(ESC_CHAR) >= 0) {
            //only do the extra replaces if needed, atleast one \ character is present
            String retStr = escape.cote(str.replaceAll(ESC_STR, ESC_PLCHOLDR));
            retStr = retStr.replaceAll(ESC_PLCHOLDR, ESC_STR + ESC_STR);
            return retStr;
        }
        else {
            return escape.cote(str);
        }
    }

    public static String decodeJSONStringDB(String str)
	{
        return str.replaceAll("#slash#","\\\\");
    }

	public static String getSiteFolderName(String name)
	{
		//return com.etn.asimina.util.UrlHelper.removeAccents(parseNull(name)).replaceAll("[^A-Za-z0-9]", "-").toLowerCase();
		return com.etn.asimina.util.UrlHelper.removeAccents(parseNull(name)).replaceAll("[^\\p{IsAlphabetic}\\p{Digit}]", "-").toLowerCase();
	}

}

