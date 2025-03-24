<%!
void init_msg(javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn)
{
	javax.servlet.http.HttpSession session =  req.getSession(true);	
	
	if( Etn.lang != 0)
	{	
		com.etn.lang.ResultSet.Set rsListe = Etn.execute("select LANGUE_REF,LANGUE_"+(Etn.lang) + " as LANGUE from langue_msg");
	
		session.removeAttribute("libelle_msg");
	
		java.util.HashMap<String,String> h_msg = new java.util.HashMap<String,String>();
	
		while(rsListe.next())
		{
			h_msg.put(com.etn.asimina.util.UrlHelper.removeAccents(rsListe.value("LANGUE_REF")).toUpperCase(),rsListe.value("LANGUE"));
		}
		session.setAttribute("libelle_msg",h_msg);
	}
}
String libelle_msg(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String lib)
{ 
	return libelle_msg(Etn, req, lib, true);
}

String libelle_msg(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String lib, boolean addindictionary)
{ 
	String msg="";
	boolean voir = false;

	if(lib == null || lib.trim().length() == 0) return "";

	if( Etn.lang != 0)
	{
		javax.servlet.http.HttpSession session =  req.getSession(true);
		init_msg(req, Etn);
		if( session.getAttribute("libelle_msg")==null)//double check
		{
			msg = lib;
		}
		else
		{
			java.util.HashMap<String,String> h_msg = (java.util.HashMap <String,String>) session.getAttribute("libelle_msg");
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
	}
	else
	{
		msg = lib;
	}
	return(msg);
}

String getLangDirection(String lang, javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn)
{
	javax.servlet.http.HttpSession session =  req.getSession(true);	
	loadLanguages(Etn, session);
	if(lang != null && lang.trim().length() > 0)
	{
		java.util.Map<String, String> langDirections = (java.util.HashMap)session.getAttribute("lang_dir");		
		if(langDirections.get(lang) == null) return "";
		return langDirections.get(lang);
	}
	return "";
}

void set_lang(String lang, javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn)
{
	javax.servlet.http.HttpSession session =  req.getSession(true);	
	loadLanguages(Etn, session);
	Language firstLang = getLangs(Etn,session).get(0);
	if(lang != null && lang.trim().length() > 0)
	{	
		boolean reloadmsgs = false;
		java.util.List<Language> langs = getLangs(Etn,session);
		boolean found = false;

		for(Language langue:langs)
		{
			if(langue.getCode().equalsIgnoreCase(lang.trim()))
			{
				found = true;
				if(Etn.lang != (byte) Integer.parseInt(langue.getLanguageId()))
				{
					reloadmsgs = true;
					Etn.lang = (byte) Integer.parseInt(langue.getLanguageId());
				}
				break;
			}
		}		
		if(!found || langs.isEmpty()) //if no language found then set it to default 0
		{
			if(Etn.lang != (byte) Integer.parseInt(firstLang.getLanguageId()))
			{
				reloadmsgs = true;
				Etn.lang = (byte) Integer.parseInt(firstLang.getLanguageId());//default we always use first language in language table
			}
		}
		com.etn.util.Logger.debug("lib_msg.jsp"," lang : " + lang + " etn lang : " + Etn.lang + " reload msgs : " + reloadmsgs);
		if(reloadmsgs) init_msg(req, Etn);	
	}
	else if(Etn.lang != (byte)Integer.parseInt(firstLang.getLanguageId()))
	{
		com.etn.util.Logger.debug("lib_msg.jsp","--------- setting default to "+firstLang.getLanguageId());
		Etn.lang = (byte) Integer.parseInt(firstLang.getLanguageId());//default we always use first language in language table
		init_msg(req, Etn);
	}
	System.out.println(Etn.lang);
}

String getFormSiteId(com.etn.beans.Contexte Etn,String formId)
{
	Set rs = Etn.execute("select site_id from process_forms_unpublished where form_id="+escape.cote(formId));
	rs.next();
	return parseNull(rs.value("site_id"));
}

void set_lang(String lang, javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn,String formId)
{
	javax.servlet.http.HttpSession session =  req.getSession(true);	
	loadLanguages(Etn, session, getFormSiteId(Etn,formId));
	Language firstLang = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,getFormSiteId(Etn,formId)).get(0);
	if(lang != null && lang.trim().length() > 0)
	{	
		boolean reloadmsgs = false;
		java.util.List<Language> langs = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,getFormSiteId(Etn,formId));
		boolean found = false;

		for(Language langue:langs)
		{
			if(langue.getCode().equalsIgnoreCase(lang.trim()))
			{
				found = true;
				if(Etn.lang != (byte) Integer.parseInt(langue.getLanguageId()))
				{
					reloadmsgs = true;
					Etn.lang = (byte) Integer.parseInt(langue.getLanguageId());
				}
				break;
			}
		}		
		if(!found || langs.isEmpty()) //if no language found then set it to default 0
		{
			if(Etn.lang != (byte) Integer.parseInt(firstLang.getLanguageId()))
			{
				reloadmsgs = true;
				Etn.lang = (byte) Integer.parseInt(firstLang.getLanguageId());//default we always use first language in language table
			}
		}
		com.etn.util.Logger.debug("lib_msg.jsp"," lang : " + lang + " etn lang : " + Etn.lang + " reload msgs : " + reloadmsgs);
		if(reloadmsgs) init_msg(req, Etn);	
	}
	else if(Etn.lang != (byte)Integer.parseInt(firstLang.getLanguageId()))
	{
		com.etn.util.Logger.debug("lib_msg.jsp","--------- setting default to "+firstLang.getLanguageId());
		Etn.lang = (byte) Integer.parseInt(firstLang.getLanguageId());//default we always use first language in language table
		init_msg(req, Etn);
	}
	System.out.println(Etn.lang);
}

void loadLanguages(com.etn.beans.Contexte Etn,javax.servlet.http.HttpSession session)
{	
	
	if(session.getAttribute("languages") == null)
	{
		java.util.ArrayList<String> langs = new java.util.ArrayList<String>();
		java.util.Map<String, String> langdirections = new java.util.HashMap<String, String>();
		List<Language> langsList = getLangs(Etn,session);
		for(Language lang:langsList)
		{
			String _lc = lang.getCode();
			_lc = _lc.trim();
			langs.add(_lc);
			langdirections.put(parseNull(lang.getCode()), parseNull(lang.getDirection()));
		}	
		session.setAttribute("languages", langsList);
		session.setAttribute("site_langs", langsList);
		session.setAttribute("lang_dir", langdirections);
	}
}

void loadLanguages(com.etn.beans.Contexte Etn,javax.servlet.http.HttpSession session,String siteId)
{	
	if(session.getAttribute("languages") == null)
	{
		java.util.ArrayList<String> langs = new java.util.ArrayList<String>();
		java.util.Map<String, String> langdirections = new java.util.HashMap<String, String>();
		List<Language> langsList = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,siteId);
		for(Language lang:langsList)
		{
			String _lc = lang.getCode();
			_lc = _lc.trim();
			langs.add(_lc);
			langdirections.put(parseNull(lang.getCode()), parseNull(lang.getDirection()));
		}	
		session.setAttribute("languages", langsList);
		session.setAttribute("site_langs", langsList);
		session.setAttribute("lang_dir", langdirections);
	}
}

String getTarifColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.List<Language> langs = getLangs(Etn,session);
	Language firstLang = getLangs(Etn,session).get(0);
	String prefix = "lang_"+firstLang.getLanguageId()+"_"; //by default we pick from SiteHelper class 
	for(Language langue: langs)
	{
		if(langue.getLanguage().equalsIgnoreCase(lang))
			return "lang_" + langue.getLanguageId() + "_";
	}	
	return prefix;
}

String getLangPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.List<Language> langs = getLangs(Etn,session);
	Language firstLang = getLangs(Etn,session).get(0);
	String prefix = "lang_"+firstLang.getLanguageId()+"_";
	for(Language langue: langs)
	{
		if(langue.getLanguage().equalsIgnoreCase(lang))
			return "lang_" + langue.getLanguageId() + "_";
	}	
	return prefix;
}

String getProductColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.List<Language> langs = getLangs(Etn,session);
	Language firstLang = getLangs(Etn,session).get(0);
	String prefix = "lang_"+firstLang.getLanguageId()+"_";
	for(Language langue:langs)
	{
		if(langue.getLanguage().equalsIgnoreCase(lang))
			return "lang_" + langue.getLanguageId() + "_";
	}	
	return prefix;
}

String getFaqColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.List<Language> langs = getLangs(Etn,session);
	Language firstLang = getLangs(Etn,session).get(0);
	String prefix = "lang_"+firstLang.getLanguageId()+"_";//by default we pick lang_1 columns
	for(Language langue:langs)
	{
		if(langue.getLanguage().equalsIgnoreCase(lang))
			return "lang_" + langue.getLanguageId() + "_";
	}	
	return prefix;
}

String getMobileTableSuffix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.List<Language> langs = getLangs(Etn,session);
	Language firstLang = getLangs(Etn,session).get(0);
	String suffix = "lang_"+firstLang.getLanguageId();//by default we pick lang_1 columns
	for(Language langue:langs)
	{
		if(langue.getLanguage().equalsIgnoreCase(lang))
			return "lang_" + langue.getLanguage();
	}	
	return suffix;
}

String getFamilieColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.List<Language> langs = getLangs(Etn,session);
	Language firstLang = getLangs(Etn,session).get(0);
	String prefix = "lang_"+firstLang.getLanguageId()+"_";//by default we pick lang_1 columns
	for(Language langue:langs)
	{
		if(langue.getLanguage().equalsIgnoreCase(lang))
			return "lang_" + langue.getLanguageId() + "_";
	}	
	return prefix;
}

%>