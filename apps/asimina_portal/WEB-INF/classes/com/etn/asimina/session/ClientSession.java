package com.etn.asimina.session;

import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.asimina.beans.Client;
import com.etn.asimina.util.PortalHelper;
import com.etn.beans.Contexte;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;

import org.json.JSONObject;


/**
* This class will maintain all client related session values
*
*
*/ 
public class ClientSession extends WebSession {
		
	private static final ClientSession obj = new ClientSession();
	
	private ClientSession(){
		this.webCookieName = "__asm_cl_session_id";
	}
	
	public static ClientSession getInstance()
	{
		return obj;
	}
	
	public Client getLoggedInClient(Contexte Etn, HttpServletRequest request)
	{
		String webSessionId = getId(Etn, request);
		webSessionId = PortalHelper.parseNull(webSessionId);
		if(webSessionId.length() == 0) return null;//login cookie not found so not logged in
						
		Client client = null;		
		String clientId = PortalHelper.parseNull(getParameter(Etn, webSessionId, "client_id"));
		if(clientId.length() > 0)
		{
			Set rs = Etn.execute("select * from clients where id = " + escape.cote(clientId));
			if(rs.next())
			{
				client = new Client();
				for(int i=0; i<rs.ColName.length; i++)
				{
					String val = rs.value(i);
					if("client_profil_id".equals(rs.ColName[i].toLowerCase()) && val.length() == 0)
					{
						val = "logged_in_user";
					}
					client.addProperty(rs.ColName[i], val);
				}
			}
		}
		return client;
	}

	public String getLoginClientId(Contexte Etn, HttpServletRequest request)
	{
		Client client = getLoggedInClient(Etn, request);
		if(client == null) return "";
		return client.getProperty("id");
	}
	
	public boolean isClientLoggedIn(Contexte Etn, HttpServletRequest request)
	{
		Client client = getLoggedInClient(Etn, request);
		if(client == null) return false;
		return true;		
	}	

	//Following functions are commented for the time being as we are not supporting multiple logged-in sites on same domain
	//client info is checked from asimina session cookie and it will be shared on the domain if we have multiple auth sites running
	//we have to think if we allow such case or not ... so far we are not allowing it which means if 2 sites are on same domain
	//and user logins to one site the same user will be appearing as logged-in on second site
	
/*	public String getLoginClientId(Contexte Etn, HttpServletRequest request, String muid)
	{
		Client client = getLoggedInClient(Etn, request, muid);
		if(client == null) return "";
		return client.getProperty("id");
	}*/
	
/*	public boolean isClientLoggedIn(Contexte Etn, HttpServletRequest request, String muid)
	{
		Client client = getLoggedInClient(Etn, request, muid);
		if(client == null) return false;
		return true;		
	}*/
	
	/*
	* This function checks the logged in client is of same site ... ideally this should be called to check client login
	* but we are not yet sure if we have to provide multiple login sites on same domain
	* if that is not required then there is not much need to check for client's site id
	*/
/*	public Client getLoggedInClient(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String muid)
	{
		//we cannot find the site id so returning false
		if(PortalHelper.parseNull(muid).length() == 0) 
		{
			com.etn.util.Logger.error("WebSession","ERROR:::: menu uuid is empty so cannot find the site id hence returning false ");
			return null;
		}

		Client client = getLoggedInClient(Etn, request);
		if(client == null)
		{
			return null;
		}		

		//verify client is of same site
		String clientSiteId = client.getProperty("site_id");
		
		String menuSiteId = "";
		Set rs = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(PortalHelper.parseNull(muid)));
		if(rs.next())
		{
			menuSiteId = rs.value("site_id");
			Logger.info("WebSession","current menu site id : " + menuSiteId);
		}
		if(menuSiteId.equals(clientSiteId))
		{
			return client;
		}
		return null;
	}*/

	public void clear(HttpServletResponse response)
	{
		Cookie _cookie = new Cookie(webCookieName, "");
		_cookie.setMaxAge(0);
		_cookie.setPath(GlobalParm.getParm("PORTAL_LINK"));
		response.addCookie(_cookie);
	}	
	
	
}
