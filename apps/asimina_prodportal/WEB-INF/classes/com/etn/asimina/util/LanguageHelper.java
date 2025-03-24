package com.etn.asimina.util;

import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.asimina.util.PortalHelper;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.util.Logger;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import org.json.JSONObject;


public class LanguageHelper
{
	private static final LanguageHelper apt = new LanguageHelper();
	private Map<String, Map<String, String>> dictionary = null;	
	private List<String> langs = null;
	private Map<String, String> langDirections = null;
	
	private LanguageHelper(){
        try{
			Logger.info("LanguageHelper", "-------------- Creating LanguageHelper instance --------------");
			Contexte db = new Contexte();
			init(db);
        }catch(Exception ex){
            ex.printStackTrace();
        }		
	}
	
	private void init(Contexte db)
	{
		Logger.info("LanguageHelper", "in init");
		dictionary = new HashMap<String, Map<String, String>>();
		langs = new ArrayList<String>();
		langDirections = new HashMap<String, String>();
		
		Set rslang = db.execute("select * from language order by langue_id ");			
		while(rslang.next())
		{			
			Map<String, String> langMap = new HashMap<String, String>();
			dictionary.put(rslang.value("langue_id"), langMap);
			
			langs.add(rslang.value("langue_code"));
			langDirections.put(rslang.value("langue_code"), rslang.value("direction"));
			
			Set rs = db.execute("select LANGUE_REF,LANGUE_"+(rslang.value("langue_id")) + " as LANGUE from langue_msg");			
			while(rs.next())
			{
				langMap.put( com.etn.asimina.util.UrlHelper.removeAccents(rs.value("LANGUE_REF")).toUpperCase(),rs.value("LANGUE"));
			}
		}			
	}
	public void reloadAll(Contexte db)
	{
		init(db);
	}
	
	public static LanguageHelper getInstance()
	{
		Logger.debug("LanguageHelper", "in getInstance");
		if(apt == null) Logger.error("LanguageHelper", "impossible state ---- apt is null");
		return apt;
	}
	
	public String getTranslation(com.etn.beans.Contexte Etn, String lib)
	{ 
		return getTranslation(Etn, lib, true);
	}
	public String getTranslation(com.etn.beans.Contexte Etn, String lib, boolean addindictionary)
	{ 
		String msg="";
		boolean voir = false;
		Logger.debug("LanguageHelper","getTranslation " + Etn.lang);
		if(lib == null || lib.trim().length() == 0) return "";

		if( Etn.lang != 0 )
		{
			Map<String,String> h_msg = dictionary.get(Etn.lang + "");
			if(h_msg != null)
			{
				String lib2 = com.etn.asimina.util.UrlHelper.removeAccents(lib).toUpperCase().trim();
				if( h_msg.get(lib2)!=null)
				{
					if(! h_msg.get(lib2).toString().trim().equals(""))
					{
						msg = h_msg.get(lib2).toString();
					}
					else
					{
						msg =  lib;
					}
				}
				else
				{
					msg = lib;
					if(addindictionary) Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values("+ com.etn.sql.escape.cote(lib.trim())+")");
				}
			}
			else
			{
				msg = lib;
			}
		}
		else
		{
			msg = lib;
		}
		return(msg);
	}
	
	public String getLangDirection(com.etn.beans.Contexte Etn, String langCode)
	{
		if(langDirections.get(langCode) == null) return "";
		return langDirections.get(langCode);
	}
	
	public void set_lang(com.etn.beans.Contexte Etn, String lang)
	{
		Logger.info("LanguageHelper", "in set_lang");
		
		if(lang != null && lang.trim().length() > 0)
		{	
			Logger.info("LanguageHelper", lang);
			boolean found = false;
			for(int i=0;i<langs.size(); i++)
			{
				if(langs.get(i).equalsIgnoreCase(lang.trim()))
				{
					found = true;
					if(Etn.lang != (i+1))
					{
						Etn.lang = (byte)(i+1);
					}
					break;
				}
			}		
			if(!found || langs.isEmpty()) //if no language found then set it to default 0
			{
				if(Etn.lang != 1)
				{
					Etn.lang = 1;//default we always use first language in language table
				}
			}
			Logger.debug("LanguageHelper"," lang : " + lang + " etn lang : " + Etn.lang );
		}
		else if(Etn.lang != 1)
		{
			Logger.info("LanguageHelper", "in-coming lang is null or empty string so setting to default 1");
			Logger.debug("LanguageHelper","--------- setting default to 1 ");
			Etn.lang = 1;//default we always use first language in language table
		}
	}
	
	public String getLangPrefix(com.etn.beans.Contexte Etn, String lang)
	{
		Logger.info("LanguageHelper", "in getLangPrefix");
		if(langs != null) Logger.info("LanguageHelper", ""+langs.size());
		else Logger.error("LanguageHelper", "langs is null which is not possible");
		if(lang != null && lang.trim().length() > 0) Logger.info("LanguageHelper", lang);
		else Logger.error("LanguageHelper", "in-coming lang is null");

		String prefix = "lang_1_";//by default we pick lang_1 columns
		if(lang != null)
		{
			for(int i=0;i<langs.size(); i++)
			{
				if(langs.get(i).equalsIgnoreCase(lang))
				{
					prefix = "lang_" + (i+1) + "_";
					break;
				}
			}	
		}
		return prefix;
	}

	public String getProductColumnsPrefix(com.etn.beans.Contexte Etn, String lang)
	{
		Logger.info("LanguageHelper", "in getProductColumnsPrefix");
		if(langs != null) Logger.info("LanguageHelper", ""+langs.size());
		else Logger.error("LanguageHelper", "langs is null which is not possible");
		if(lang != null && lang.trim().length() > 0) Logger.info("LanguageHelper", lang);
		else Logger.error("LanguageHelper", "in-coming lang is null");
		
		String prefix = "lang_1_";//by default we pick lang_1 columns
		if(lang != null)
		{
			for(int i=0;i<langs.size(); i++)
			{
				if(langs.get(i).equalsIgnoreCase(lang))
				{
					prefix = "lang_" + (i+1) + "_";
					break;
				}
			}	
		}
		return prefix;
	}

}