/*
 * Special filter to check for auth enabled sites
 * 
 */

package com.etn.servlet.filter;

import com.etn.lang.ResultSet.Set;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.StringTokenizer;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.security.SecureRandom;
import java.util.Map;
import java.util.HashMap;
import java.io.PrintWriter;

import com.etn.asimina.authentication.*;
import org.json.JSONObject;
import org.json.JSONException;

import com.etn.asimina.session.ClientSession;

/**
 *
 * @author umair
 */
public class SiteAuthenticate implements Filter
{
	private FilterConfig filterConfig;
	private Map<String, MySite> sites = null;

	public void init(FilterConfig filterConfig)
    	{
       	this.filterConfig = filterConfig;
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    	public void doFilter(ServletRequest _request, ServletResponse _response, FilterChain chain) throws IOException, ServletException
    	{
       	HttpServletRequest request = (HttpServletRequest)_request;
       	HttpServletResponse response = (HttpServletResponse)_response;

       	if(request.getSession().getAttribute("Etn") == null)
		{
			request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
		}

		com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");

		String path = request.getServletPath();
		com.etn.util.Logger.info("SiteAuthenticate.java", "Request path : " + path);

		String sitesFolder = "/" + parseNull(GlobalParm.getParm("DOWNLOAD_PAGES_FOLDER"));
		com.etn.util.Logger.info("SiteAuthenticate.java", "sitesFolder:"+sitesFolder);

		String proxyPath = path.substring(path.indexOf(sitesFolder) + sitesFolder.length()); 
		com.etn.util.Logger.info("SiteAuthenticate.java", "proxyPath:"+proxyPath);
		String sitename = proxyPath;
		com.etn.util.Logger.info("SiteAuthenticate.java", "sitename : " + sitename);

		if(sitename.indexOf("/") > -1) sitename = sitename.substring(0, sitename.indexOf("/"));

		loadSites(Etn);

		MySite mySite = sites.get(sitename);
		String siteid = "";
		String loginfrm = "";
		if(mySite != null)
		{
			siteid = mySite.id;
			loginfrm = parseNull(mySite.loginForm);
		}
		com.etn.util.Logger.info("SiteAuthenticate.java", "PATH:"+path+"  sitename:"+sitename+"  siteid:"+siteid);
	 	
		if(siteid.length() == 0)
		{
			writeToResponse(_response, "<html><head><title>Error</title></head><body><span style='color:red;font-weight:bold;font-size:14px'>Error!!! Unable to identify site</span></body></html>");
			return;
		}

		boolean isLogin = false;
		if(parseNull(ClientSession.getInstance().getParameter(Etn, request, "client_site_id")).equals(siteid))
		{	
			isLogin = true;//is login for this particular site ... this login can be done from special login page configured at site level or can be done from menu login form
		}
		com.etn.util.Logger.info("SiteAuthenticate.java", "isLogin:"+isLogin);
		
		//not logged in for sitename
		if(!isLogin)
		{			
			String frmPath = parseNull(GlobalParm.getParm("SEND_REDIRECT_LINK")) + proxyPath;
			if(loginfrm.length() == 0)
			{
				//no user defined form found from db so show a simple login page
				loginfrm = "<html><head><title>"+sitename+"</title></head><body><div style='color:red'>##message##</div><form method='post' id='lgnfrm' name='lgnfrm' autocomplete='off' action='"+com.etn.asimina.util.PortalHelper.escapeCoteValue(frmPath)+"'><input type='hidden' name='islogin' value='1'>Username : <input type='text' name='login' value=''><br>Password : <input type='password' name='passwd' value=''><br><input type='button' value='Login' onclick='javascript:document.forms[0].submit()' ></form></body></html>";
			}
			else
			{
				loginfrm = loginfrm.replace("##frmPath##", com.etn.asimina.util.PortalHelper.escapeCoteValue(frmPath));//replace placeholder with path
			}

			if(request.getParameter("login") == null)//first time reaching here
			{
				com.etn.util.Logger.info("SiteAuthenticate.java", "first time open form");
				writeToResponse(_response, loginfrm.replace("##message##",""));
				return;
			}
			else
			{
				String login = parseNull(request.getParameter("login"));
				String passwd = parseNull(request.getParameter("passwd"));
				if(login.length() == 0 || passwd.length() == 0)
				{				
					writeToResponse(_response, loginfrm.replace("##message##","You must enter username and password"));
					return;					
				}
				
				
				AsiminaAuthenticationHelper asiminaAuthenticationHelper = new AsiminaAuthenticationHelper(Etn,siteid,com.etn.beans.app.GlobalParm.getParm("CLIENT_PASS_SALT"));
				if(asiminaAuthenticationHelper != null)
				{
					AsiminaAuthentication asiminaAuthentication = asiminaAuthenticationHelper.getAuthenticationObject();
					
					if(asiminaAuthentication != null)
					{
						//checking in 2 steps ... first we check username is registered for the site and then verify the pass
						AsiminaAuthenticationResponse authenticationResponse = asiminaAuthentication.authenticate(login,passwd);
						if(authenticationResponse.isDone() == false)
						{
							com.etn.util.Logger.info("SiteAuthenticate.java", "Message:"+authenticationResponse.getMessage());
							writeToResponse(_response, loginfrm.replace("##message##", authenticationResponse.getMessage()) );
							addusagelog(Etn, request, login, "Login failure", authenticationResponse.getMessage(), frmPath, siteid);
							return;												
						}
						AsiminaAuthenticationResponse getUserResponse = asiminaAuthentication.getUser(login);
						if(getUserResponse.isDone())
						{
							try
							{
								JSONObject user = getUserResponse.getHttpResponse();
								com.etn.util.Logger.info("SiteAuthenticate.java", "User/pass valid");
								Map<String, String> cParams = new HashMap<String, String>();
								cParams.put("login", user.getString("username"));
								cParams.put("login_email", user.getString("email"));
								cParams.put("client_id", user.getString("id"));
								cParams.put("client_site_id", siteid);
								cParams.put("client_uuid", user.getString("client_uuid"));
								
								ClientSession.getInstance().addParameter(Etn, request, response, cParams);
								addusagelog(Etn, request, login, "Login success", null, frmPath, siteid);
							}
							catch(JSONException jex)
							{
								jex.printStackTrace();
							}
						}
					}
					else
					{
						String message = "In correct site settings. Please contact administrator. Error code 102";
						com.etn.util.Logger.info("SiteAuthenticate.java", "message:"+message);
						writeToResponse(_response, loginfrm.replace("##message##", message) );
						return;
					}
				}
				else
				{
					String message = "In correct site settings. Please contact administrator. Error code 101";
					com.etn.util.Logger.info("SiteAuthenticate.java", "message:"+message);
					writeToResponse(_response, loginfrm.replace("##message##", message) );
					return;
				}
			}
		}

       	chain.doFilter(request, response);	
	}

	private void writeToResponse(ServletResponse response, String html) throws IOException
	{
		response.setContentType("text/html");
		PrintWriter out = response.getWriter();
		out.println(html);
		return;
	}

	private void loadSites(com.etn.beans.Contexte Etn)
	{
		if(sites == null || sites.isEmpty())
		{
			sites = new HashMap<String, MySite>();
			Set rs = Etn.execute("select * from sites");
			while(rs.next())
			{
				MySite mySite = new MySite();
				mySite.id = rs.value("id");
				mySite.loginForm = parseNull(rs.value("site_auth_login_page"));
				if(sites.get(getSiteFolderName(rs.value("name"))) == null) sites.put(getSiteFolderName(rs.value("name")), mySite);
			}
		}
	}

	public void destroy()
    	{
       	this.filterConfig = null;
    	}

	final static int UC16Latin1ToAscii7[] = {
		'A','A','A','A','A','A','A','C',
		'E','E','E','E','I','I','I','I',
		'D','N','O','O','O','O','O','X',
		'0','U','U','U','U','Y','S','Y',
		'a','a','a','a','a','a','a','c',
		'e','e','e','e','i','i','i','i',
		'o','n','o','o','o','o','o','/',
		'0','u','u','u','u','y','s','y' };

	int  toAscii7( int c )
	{ 
		if( c < 0xc0 || c > 0xff ) return(c);
		return( UC16Latin1ToAscii7[ c - 0xc0 ] );
	}

	String ascii7( String  s )
	{
		char c[] = s.toCharArray();
		for( int i = 0 ; i < c.length ; i++ )
			if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
				return( new String( c ) );
	}

	String getSiteFolderName(String name)
	{
		//return ((ascii7(name)).replaceAll("[^A-Za-z0-9]", "-")).trim().toLowerCase();
		return ((ascii7(name)).replaceAll("[^\\p{IsAlphabetic}\\p{Digit}]", "-")).trim().toLowerCase();
	}

	private class MySite
	{
		String id;
		String loginForm;
	}

	void addusagelog(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String login, String activity, String details, String url, String siteid)
	{
		String useragent = "";
		useragent = request.getHeader("User-Agent");
		if(useragent == null) useragent = "";
		String activityfrom = "web";
		if(useragent.toLowerCase().indexOf("android") != -1 || useragent.toLowerCase().indexOf("ipad") != -1 || useragent.toLowerCase().indexOf("iphone") != -1 || useragent.toLowerCase().indexOf("apache-httpclient/unavailable") != -1 ) activityfrom = "device";

		if(details == null) details = "";
		if(url == null) url = "";
	
		String ip = "";
		if(request.getHeader("x-forwarded-for") != null) ip = request.getHeader("x-forwarded-for");
		Etn.executeCmd("insert into client_usage_logs (login, activity, ip, activity_from, user_agent, details, url, site_id) values ("+com.etn.sql.escape.cote(login)+","+com.etn.sql.escape.cote(activity)+","+com.etn.sql.escape.cote(ip)+","+com.etn.sql.escape.cote(activityfrom)+", "+com.etn.sql.escape.cote(useragent)+", "+com.etn.sql.escape.cote(details)+", "+com.etn.sql.escape.cote(url)+", "+com.etn.sql.escape.cote(siteid)+")");
	}
	
}