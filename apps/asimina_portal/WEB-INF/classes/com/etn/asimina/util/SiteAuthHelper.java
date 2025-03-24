package com.etn.asimina.util;

import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.asimina.util.PortalHelper;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import java.util.Map;
import java.util.LinkedHashMap;
import java.util.HashMap;

import org.json.JSONObject;

public class SiteAuthHelper
{
	private static final SiteAuthHelper apt = new SiteAuthHelper();
	//using map so that just in case 2 different threads call the load function the map key overwrites ... if we use list then list size can increase
	private Map<String, Map<String, String>> menus = new LinkedHashMap<String, Map<String, String>>();
	private Map<String, String> menuUuids = new LinkedHashMap<String, String>();
	
	private SiteAuthHelper(){}
	
	public static SiteAuthHelper getInstance()
	{
		return apt;
	}
	
	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
	
	public void reloadAll()
	{
		menus.clear();
		menuUuids.clear();
	}
	
	private void load(com.etn.beans.Contexte Etn)
	{
		//for test site we always load the info ... for prod we will not load unless a site is published and the reloadAll
		//function is called
		if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV")) == false) 
		{
			menus.clear();
			menuUuids.clear();
		}
		
		if(menus == null || menus.isEmpty())
		{
			menus = new LinkedHashMap<String, Map<String, String>>();
			menuUuids = new LinkedHashMap<String, String>();
			//order by is very important here .... we will match the first path of uri to menu path so we keep longest path on top
			Set rs = Etn.execute("select m.*, l.langue_id, sd.login_page_url from site_menus m "+
								" left join language l on l.langue_code = m.lang "+
								" left join sites_details sd on sd.site_id = m.site_id and sd.langue_id = l.langue_id "+
								" order by length(m.production_path) desc");
			while(rs.next())
			{
				String currentMenuPath = PortalHelper.getMenuPath(Etn, rs.value("id"));
				Map<String, String> menu = new HashMap<String, String>();
				menu.put("id",rs.value("id"));
				menu.put("menu_uuid",rs.value("menu_uuid"));
				menu.put("menu_version",rs.value("menu_version"));
				
				String loginPageUrl = rs.value("login_page_url"); 
				//if no login form is defined we will just take to the homepage of that menu
				if(loginPageUrl.length() == 0) loginPageUrl = rs.value("homepage_url");
				
				if(loginPageUrl.toLowerCase().startsWith("http:") == false && loginPageUrl.toLowerCase().startsWith("https:") == false &&
					loginPageUrl.toLowerCase().startsWith("/") == false) loginPageUrl = currentMenuPath + loginPageUrl;
				
				menu.put("login_page_url", loginPageUrl);
				menu.put("site_id",rs.value("site_id"));
				menu.put("menu_path", currentMenuPath);
				menu.put("lang", rs.value("lang"));
				menu.put("lang_id", rs.value("langue_id"));
				
				Logger.debug("SiteAuthHelper", menu.get("id") + " : " + menu.get("menu_path") + " : " + menu.get("login_page_url")+ " : " + menu.get("lang"));
				
				menus.put(rs.value("id"), menu);
				menuUuids.put(rs.value("menu_uuid"), rs.value("id"));
			}
		}		
	}

	public String getLoginUrl(com.etn.beans.Contexte Etn, String uri)
	{		
		Logger.debug("SiteAuthHelper","In getLoginUrl");
		load(Etn);
		for(String menuid : menus.keySet())
		{
			if(uri.startsWith(menus.get(menuid).get("menu_path")))
			{
				Logger.debug("SiteAuthHelper", "Applicable site id : " + menus.get(menuid).get("site_id") + " menu : " + menus.get(menuid).get("id") + "  lang  :  " + menus.get(menuid).get("lang"));
				return menus.get(menuid).get("login_page_url");
			}
		}
		return GlobalParm.getParm("EXTERNAL_LINK") + "errorconfig.html";
	}

	public String getLoginUrlForMenu(com.etn.beans.Contexte Etn, String muid)
	{		
		Logger.debug("SiteAuthHelper","In getLoginUrlForMenu");
		load(Etn);
		String menuid = parseNull(menuUuids.get(muid));
		if(menuid.length() > 0)
		{
			Logger.debug("SiteAuthHelper", "Applicable site id : " + menus.get(menuid).get("site_id") + " menu : " + menus.get(menuid).get("id") + "  lang  :  " + menus.get(menuid).get("lang"));
			return menus.get(menuid).get("login_page_url");			
		}
		return GlobalParm.getParm("EXTERNAL_LINK") + "errorconfig.html";
	}

	public String getApplicableMenu(com.etn.beans.Contexte Etn, String uri)
	{
		Logger.debug("SiteAuthHelper","In getApplicableMenu");
		load(Etn);
		for(String menuid : menus.keySet())
		{
			if(uri.startsWith(menus.get(menuid).get("menu_path")))
			{
				Logger.debug("SiteAuthHelper", "Applicable site id : " + menus.get(menuid).get("site_id") + " menu : " + menus.get(menuid).get("id") + "  lang  :  " + menus.get(menuid).get("lang"));
				return menus.get(menuid).get("menu_uuid");
			}
		}
		return "";
	}

}