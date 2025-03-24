package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import java.util.*;

public class Dictionary 
{
	private Map<String, Map<String, String>> dictionary = null;	
	private String defaultLanguage;

	private ClientSql etn;
	private Properties env;

	private final int lib_UC16Latin1ToAscii7[] = {
	'A','A','A','A','A','A','A','C',
	'E','E','E','E','I','I','I','I',
	'D','N','O','O','O','O','O','X',
	'0','U','U','U','U','Y','S','Y',
	'a','a','a','a','a','a','a','c',
	'e','e','e','e','i','i','i','i',
	'o','n','o','o','o','o','o','/',
	'0','u','u','u','u','y','s','y' };

	private String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public Dictionary( ClientSql etn , Properties conf ) throws Exception
	{ 
		this.etn = etn; 
		this.env = conf;
		initDictionary();
	}

	private void initDictionary()
	{
		Set rslang = etn.execute("select * from language order by langue_id ");
		dictionary = new HashMap<String, Map<String, String>>();
		while(rslang.next())
		{			
			if(rslang.value("langue_id").equals("1")) defaultLanguage = rslang.value("langue_code");

			Map<String, String> langMap = new HashMap<String, String>();
			dictionary.put(rslang.value("langue_code"), langMap);
			Set rs = etn.execute("select LANGUE_REF,LANGUE_"+(rslang.value("langue_id")) + " as LANGUE from langue_msg");			
			while(rs.next())
			{
				langMap.put(lib_removeAccents(rs.value("LANGUE_REF")).toUpperCase(),rs.value("LANGUE"));
			}
		}
	}

	private int lib_toAscii7( int c )
	{ 
		if( c < 0xc0 || c > 0xff ) return(c);
		return( lib_UC16Latin1ToAscii7[ c - 0xc0 ] );
	}

	private String lib_ascii7( String  s )
	{
		char c[] = s.toCharArray();
		for( int i = 0 ; i < c.length ; i++ ) if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)lib_toAscii7( c[i] );
		return( new String( c ) );
	}

	public String lib_removeAccents(String a)
	{
		if(a == null) return "";
		a = a.trim();
		a = lib_ascii7(a);
		return a;
	}

	String getTranslation(String lang, String lib)
	{ 
		if(parseNull(lib).length() == 0) return "";

		if(parseNull(lang).length() == 0) lang = defaultLanguage;

		if(dictionary.get(lang) == null || (dictionary.get(lang)).size() == 0) return lib;

		Map<String, String> translations = dictionary.get(lang);
		String translation = parseNull(translations.get(lib_removeAccents(lib).toUpperCase().trim()));
		if(translation.length() == 0) 
		{
			etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values("+ com.etn.sql.escape.cote(lib.trim())+")");
			return lib;
		}
		return translation;
	}
}