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
* This class will maintain all portal related session values
*
*
*/ 
public class PortalSession extends WebSession {
		
	private static final PortalSession obj = new PortalSession();
	
	private PortalSession(){
		this.webCookieName = "__asm_pt_session_id";
	}
	
	public static PortalSession getInstance()
	{
		return obj;
	}
	
	public void clear(HttpServletResponse response)
	{
		Cookie _cookie = new Cookie(webCookieName, "");
		_cookie.setMaxAge(0);
		_cookie.setPath(GlobalParm.getParm("PORTAL_LINK"));
		response.addCookie(_cookie);
	}	
	
	
}
