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
			h_msg.put(rsListe.value("LANGUE_REF").replaceAll("[����]","e").toUpperCase(),rsListe.value("LANGUE"));
		}
		session.setAttribute("libelle_msg",h_msg);
	}
}
String libelle_msg(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String lib)
{ 
	String msg="";
	boolean voir = false;

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
			String lib2 = lib.replaceAll("[����]","e").toUpperCase();
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
				Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values(TRIM("+ com.etn.sql.escape.cote(lib)+"))");
			}
		}
	}
	else
	{
		msg = lib;
	}
	return(msg);
}
void set_lang(String lang, javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn)
{
	javax.servlet.http.HttpSession session =  req.getSession(true);	
	loadLanguages(Etn, session);
	if(lang != null && lang.trim().length() > 0)
	{	
		boolean reloadmsgs = false;
		java.util.ArrayList<String> langs = (java.util.ArrayList)session.getAttribute("languages");

		boolean found = false;
		for(int i=0;i<langs.size(); i++)
		{
			if(langs.get(i).equalsIgnoreCase(lang.trim()))
			{
				found = true;
				if(Etn.lang != (i+1))
				{
					reloadmsgs = true;
					Etn.lang = (byte)(i+1);
				}
				break;
			}
		}		
		if(!found || langs.isEmpty()) //if no language found then set it to default 0
		{
			if(Etn.lang != 1)
			{
				reloadmsgs = true;
				Etn.lang = 1;//default we always use first language in language table
			}
		}
		System.out.println(" lang : " + lang + " etn lang : " + Etn.lang + " reload msgs : " + reloadmsgs);
		if(reloadmsgs) init_msg(req, Etn);	
	}
	else if(Etn.lang != 1)
	{
		System.out.println("--------- setting default to 1 ");
		Etn.lang = 1;//default we always use first language in language table
		init_msg(req, Etn);
	}
}
void loadLanguages(com.etn.beans.Contexte Etn,javax.servlet.http.HttpSession session)
{
	if(session.getAttribute("languages") == null)
	{
		java.util.ArrayList<String> langs = new java.util.ArrayList<String>();
		com.etn.lang.ResultSet.Set rs = Etn.execute("select * from language order by langue_id ");
		while(rs.next())
		{
			String _lc = rs.value("langue_code");
			if(_lc == null) _lc = "";
			if("null".equals(_lc.trim().toLowerCase())) _lc = "";
			_lc = _lc.trim();
			langs.add(_lc);
		}	
		session.setAttribute("languages", langs);
	}
}
String getTarifColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.ArrayList<String> langs = (java.util.ArrayList)session.getAttribute("languages");

	String prefix = "lang_1_";//by default we pick lang_1 columns
	for(int i=0;i<langs.size(); i++)
	{
		if(langs.get(i).equalsIgnoreCase(lang))
		{
			prefix = "lang_" + (i+1) + "_";
			break;
		}
	}	
	return prefix;
}
String getLangPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.ArrayList<String> langs = (java.util.ArrayList)session.getAttribute("languages");

	String prefix = "lang_1_";//by default we pick lang_1 columns
	for(int i=0;i<langs.size(); i++)
	{
		if(langs.get(i).equalsIgnoreCase(lang))
		{
			prefix = "lang_" + (i+1) + "_";
			break;
		}
	}	
	return prefix;
}

String getProductColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.ArrayList<String> langs = (java.util.ArrayList)session.getAttribute("languages");

	String prefix = "lang_1_";//by default we pick lang_1 columns
	for(int i=0;i<langs.size(); i++)
	{
		if(langs.get(i).equalsIgnoreCase(lang))
		{
			prefix = "lang_" + (i+1) + "_";
			break;
		}
	}	
	return prefix;
}

String getFaqColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.ArrayList<String> langs = (java.util.ArrayList)session.getAttribute("languages");

	String prefix = "lang_1_";//by default we pick lang_1 columns
	for(int i=0;i<langs.size(); i++)
	{
		if(langs.get(i).equalsIgnoreCase(lang))
		{
			prefix = "lang_" + (i+1) + "_";
			break;
		}
	}	
	return prefix;
}

String getMobileTableSuffix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.ArrayList<String> langs = (java.util.ArrayList)session.getAttribute("languages");

	String suffix = "lang_1";//by default we pick lang_1 columns
	for(int i=0; i < langs.size(); i++)
	{
		if(langs.get(i).equalsIgnoreCase(lang))
		{
			suffix = "lang_" + (i+1);
			break;
		}
	}	
	return suffix;
}
String getFamilieColumnsPrefix(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String lang)
{
	javax.servlet.http.HttpSession session =  request.getSession(true);	
	loadLanguages(Etn, session);
	java.util.ArrayList<String> langs = (java.util.ArrayList)session.getAttribute("languages");

	String prefix = "lang_1_";//by default we pick lang_1 columns
	for(int i=0;i<langs.size(); i++)
	{
		if(langs.get(i).equalsIgnoreCase(lang))
		{
			prefix = "lang_" + (i+1) + "_";
			break;
		}
	}	
	return prefix;
}

%>