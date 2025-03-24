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
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;

import org.json.JSONObject;

/**
 * This class provides some helper functions to get the prefix for URLs where
 * the content will be cached eventually Any changes to this class means it must
 * be copied in all webapps
 */
public class WebSession {
	
	protected String webCookieName;
	
	public String init(Contexte Etn, HttpServletRequest request, HttpServletResponse response)
	{		
		Logger.info("WebSession","init initializing new session "+ webCookieName);
		String sessionId = UUID.randomUUID().toString();
		while(true)
		{
			int _j = Etn.executeCmd("insert into web_sessions (id, access_time) values ("+escape.cote(sessionId)+", now())");
			if(_j == 0)
			{
				sessionId = UUID.randomUUID().toString();
			}
			else break;
		}
		
		Cookie _cookie = new Cookie(webCookieName, sessionId);
		//_cookie.setMaxAge(24*7*60*60);

		//cookie must be set to appropriate path which in production will always be / in portal_link
		_cookie.setPath(GlobalParm.getParm("PORTAL_LINK"));

		response.addCookie(_cookie);

		//This websession cookie is added to response which means if its the very first request to our site the cookie in request will not be available
		//and when we add parameters to websession in a jsp, it will initialize websession first time and add cookie to response but if same jsp 
		//adds another parameter in same request, it will initialize the websession again because cookies added to response are not yet available in request unless
		//the first request is completed and new request comes from browser. This leads us into multiple websessions created in very first call and sometimes 
		//some parameters set will not behave as expected as they might have been to added to websession which was created first which was overwritten in same request by
		//another websession init
		//so to solve this, very first time init is called we will add the websession id to tomcat session as well so that in first request as cookie wont be available
		//then we use the tomcat session's websession value so that multiple websessions are not created by one jsp
		request.getSession().setAttribute(webCookieName, sessionId);
		return sessionId;		
	}
	
	public String getId(Contexte Etn, HttpServletRequest request)
	{
		String webSessionId = "";
		Cookie[] cookies = request.getCookies();
		if(cookies != null)
		{
			for (int i = 0; i < cookies.length; i++) 
			{
				if(webCookieName.equals(PortalHelper.parseNull(cookies[i].getName()))) 
				{
					Logger.info("***** web session ID found in cookie");
					webSessionId = PortalHelper.parseNull(cookies[i].getValue());
					if(request.getSession().getAttribute(webCookieName) != null)
					{
						Logger.info("***** WE found websession cookie so lets delete attribute "+webCookieName+" from tomcat session in case its set");				
						request.getSession().removeAttribute(webCookieName);
					}					
					break;
				}
			}
		}
		
		if(webSessionId.length() == 0 && PortalHelper.parseNull(request.getSession().getAttribute(webCookieName)).length() > 0)
		{
			//maybe this call is from
			Logger.info("web session is already initialized so we use "+webCookieName+" from the tomcat session");
			webSessionId = PortalHelper.parseNull(request.getSession().getAttribute(webCookieName));
			
		}
		
		webSessionId = PortalHelper.parseNull(webSessionId);
		if(webSessionId.length() > 0)
		{
			String timeout = PortalHelper.parseNull(GlobalParm.getParm("SHOP_SESSION_TIMEOUT_MINS"));
			if(timeout.length() == 0) timeout = "60"; //mins

			Set rs = Etn.execute("select *, TIMESTAMPDIFF(MINUTE, access_time, now()) as _diff from web_sessions where id = "+escape.cote(webSessionId));
			if(rs.next())
			{
				if(PortalHelper.parseNullInt(rs.value("_diff")) > PortalHelper.parseNullInt(timeout))
				{
					Logger.info("WebSession","getId session is expired");
					webSessionId = "";
				}				
				else Etn.executeCmd("update web_sessions set access_time = now() where id = "+escape.cote(webSessionId));
			}
			else webSessionId = "";
				
		}
		return webSessionId;
	}

	/*
	* We maintain our sessions throw cookies. If the session was not intialized and we do addParameter and in same jsp we need the session Id,
	* we cannot get it using getId function because it reads from cookies which are not initialized yet. So we return the session ID from here
	* in which we added the parameters
	*/
	public String addParameter(Contexte Etn, HttpServletRequest request, HttpServletResponse response, String paramName, String paramVal)
	{
		String sessionId = getId(Etn, request);
		if(sessionId.length() == 0)
		{
			sessionId = init(Etn, request, response);
		}
		addParameter(Etn, sessionId, paramName, paramVal);
		return sessionId;
	}
	
	/*
	* We maintain our sessions throw cookies. If the session was not intialized and we do addParameter and in same jsp we need the session Id,
	* we cannot get it using getId function because it reads from cookies which are not initialized yet. So we return the session ID from here
	* in which we added the parameters
	*/
	public String addParameter(Contexte Etn, HttpServletRequest request, HttpServletResponse response, Map<String, String> params)
	{
		String sessionId = getId(Etn, request);
		if(sessionId.length() == 0)
		{
			sessionId = init(Etn, request, response);
		}
		for(String paramName : params.keySet())
		{
			addParameter(Etn, sessionId, paramName, params.get(paramName));
		}
		
		return sessionId;
	}
	
	protected void addParameter(Contexte Etn, String webSessionId, String paramName, String paramVal)
	{
		webSessionId = PortalHelper.parseNull(webSessionId);
		if(webSessionId.length() == 0)
		{
			Logger.error("WebSession","Error:: addParameter called where webSessionId is empty");
			return;
		}
		
		Set rs = Etn.execute("select * from web_sessions where id = "+escape.cote(webSessionId));
		if(rs.next())
		{
			try
			{
				JSONObject jparams = null;
				if(rs.value("params").length() > 0)
				{
					jparams = new JSONObject(rs.value("params"));
				}
				else jparams = new JSONObject();
				
				if(jparams.has(paramName) == true) jparams.remove(paramName);
				jparams.put(paramName, paramVal);
				
				Etn.executeCmd("update web_sessions set access_time = now(), params = "+PortalHelper.escapeCote2(jparams.toString())+" where id = "+escape.cote(webSessionId));
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}			
		}
	}

	public void removeParameter(Contexte Etn, HttpServletRequest request, String paramName)
	{
		String sessionId = getId(Etn, request);
		if(sessionId.length() > 0) removeParameter(Etn, sessionId, paramName);
	}
	
	protected void removeParameter(Contexte Etn, String webSessionId, String paramName)
	{
		webSessionId = PortalHelper.parseNull(webSessionId);
		if(webSessionId.length() == 0)
		{
			Logger.error("WebSession","Error:: removeParameter called where webSessionId is empty");
			return;
		}
		
		Set rs = Etn.execute("select * from web_sessions where id = "+escape.cote(webSessionId));
		if(rs.next())
		{
			try
			{
				JSONObject jparams = null;
				if(rs.value("params").length() > 0)
				{
					jparams = new JSONObject(rs.value("params"));
				}
				else jparams = new JSONObject();
				
				if(jparams.has(paramName) == true) jparams.remove(paramName);
				
				Etn.executeCmd("update web_sessions set access_time = now(), params = "+PortalHelper.escapeCote2(jparams.toString())+" where id = "+escape.cote(webSessionId));
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}			
		}
	}

	public String getParameter(Contexte Etn, HttpServletRequest request, String paramName)
	{
		String sessionId = getId(Etn, request);
		if(sessionId.length() > 0)
		{
			return getParameter(Etn, sessionId, paramName);
		}
		return null;		
	}

	protected String getParameter(Contexte Etn, String webSessionId, String paramName)
	{
		webSessionId = PortalHelper.parseNull(webSessionId);
		if(webSessionId.length() == 0)
		{
			Logger.error("WebSession","Error:: removeWebSessionParam called where webSessionId is empty");
			return null;
		}
		
		String timeout = PortalHelper.parseNull(GlobalParm.getParm("SHOP_SESSION_TIMEOUT_MINS"));
		if(timeout.length() == 0) timeout = "60"; //mins

		String _val = null;		
		Set rs = Etn.execute("select *, TIMESTAMPDIFF(MINUTE, access_time, now()) as _diff from web_sessions where id = "+escape.cote(webSessionId));
		if(rs.next())
		{
			if(PortalHelper.parseNullInt(rs.value("_diff")) > PortalHelper.parseNullInt(timeout))
			{
				Logger.info("WebSession","getParameter : "+paramName+" session is expired");
				return null;
			}
			try
			{
				JSONObject jparams = null;
				if(rs.value("params").length() > 0)
				{
					jparams = new JSONObject(rs.value("params"));
				}
				
				if(jparams != null && jparams.has(paramName) == true) _val = PortalHelper.parseNull(jparams.optString(paramName));
				
				Etn.executeCmd("update web_sessions set access_time = now() where id = "+escape.cote(webSessionId));
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}			
		}
		return _val;
	}
	
}