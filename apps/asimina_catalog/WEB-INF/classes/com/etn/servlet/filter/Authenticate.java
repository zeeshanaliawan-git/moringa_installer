/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.servlet.filter;

import com.etn.lang.ResultSet.Set;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.security.SecureRandom;
import com.etn.sql.escape;
import java.io.*;
import java.net.*;
import java.util.*;
import java.lang.reflect.Type;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import javax.servlet.http.Cookie;
import com.etn.sql.escape;
import com.etn.beans.app.GlobalParm;
import com.etn.util.Logger;

/**
 *
 * @author umair
 */
public class Authenticate implements Filter
{
    private FilterConfig filterConfig;

    public void init(FilterConfig filterConfig)
    {
        this.filterConfig = filterConfig;
    }

	private String getRandomInt(){
		Random random = new SecureRandom();
        int number = random.nextInt(1000);
		while(number < 100){
			number = random.nextInt(1000);
		}
		return String.valueOf(number);
	}

	private String getCode(){
		return getRandomInt() + "-" + getRandomInt();
	}

	private String getCookieSessionId(HttpServletRequest request)
	{
		Cookie[] theCookies = request.getCookies();
		if(theCookies != null) 
		{
			for (Cookie cookie : theCookies) 
			{				
				if(cookie.getName().equals("__asm_adm_sid")) 
				{
					return cookie.getValue();
				}
			}
		}
		return null;
	}

    private String parseNull(Object o) 
	{
        if (o == null) {
            return ("");
        }
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }
	
    public void doFilter(ServletRequest _request, ServletResponse _response, FilterChain chain) throws IOException, ServletException
    {

        HttpServletRequest request = (HttpServletRequest)_request;
        HttpServletResponse response = (HttpServletResponse)_response;
        //please remove debug outputs after your testing
		//System.out.println("##Authenticat.doFilter. Request from: " + request.getRemoteAddr());

        if(request.getSession().getAttribute("Etn") == null)
        {
            //System.out.println("##################### Etn is null");
            request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
        }

        com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");
        //System.out.println("##################### Etn found");

		String uri = request.getRequestURI();
		boolean isSuperAdminAuthenticated = false;
        if(Etn.getId() == 0)
        {
			String accessid = request.getParameter("__aid");
			if(accessid == null) accessid = "";

			String ssoauthid = request.getParameter("__authid");
			if(ssoauthid == null) ssoauthid = "";
			
			String cookieSessionId = getCookieSessionId(request);
			if(cookieSessionId == null) cookieSessionId = "";

			if(accessid.length() > 0)
			{
				String timeout = GlobalParm.getParm("SESSION_TIMEOUT_MINS");
				if(timeout == null || timeout.trim().length() == 0) timeout = "60"; //mins
				Set rs = Etn.execute("select *,  TIMESTAMPDIFF(SECOND, access_time, now()) as _diff from login where access_id = " +  escape.cote(accessid)  );
				if(rs.next())
				{
					String timediff = rs.value("_diff");
					Logger.info("Catalog::Authenticate.java","last access diff seconds : " + timediff);
					Logger.info("Catalog::Authenticate.java","timeout mins : " + timeout);
					//check in seconds to be more accurate
					if(Integer.parseInt(timediff) > (Integer.parseInt(timeout) * 60))
					{
						Logger.info("Catalog::Authenticate.java","PORTAL::Authentication::Session timeout");
					}
					else
					{
						Etn.setContexte(rs.value("name"),rs.value("pass"));
						isSuperAdminAuthenticated = true;
					}
				}
				else
				{
					Logger.info("Catalog::Authenticate.java","PORTAL::Authentication::Invalid access id provided");
				}
			}
			else if(cookieSessionId.length() > 0)
			{
				//we add session id to cookie to keep the session alive for authenticate.java in _catalog
				//this will help solve the case where user logins to asimina and then goes to some other webapp like pages or forms etc 
				//user is active there but in the meantime the _catalog session expires... so when user tries to switch to another webapp later
				//session in _catalog is expired and user is asked to login which is wrong as he was active in some other webapp
				Logger.info("Catalog::Authenticate.java","cookieSessionId::"+cookieSessionId);
				
				Set rs = Etn.execute("Select * from "+GlobalParm.getParm("COMMONS_DB")+".user_sessions where catalog_session_id = "+escape.cote(cookieSessionId));
				if(rs.next())
				{
					String pid = rs.value("pid");
					if(pid != null && pid.length() > 0)
					{
						String timeout = GlobalParm.getParm("SESSION_TIMEOUT_MINS");
						if(timeout == null || timeout.trim().length() == 0) timeout = "60"; //mins
						rs = Etn.execute("select *,  TIMESTAMPDIFF(SECOND, access_time, now()) as _diff from login where pid = " +  escape.cote(pid));
						if(rs.next())
						{
							String timediff = rs.value("_diff");
							Logger.info("Catalog::Authenticate.java","last access diff seconds : " + timediff);
							Logger.info("Catalog::Authenticate.java","timeout mins : " + timeout);
							//check in seconds to be more accurate
							if(Integer.parseInt(timediff) > (Integer.parseInt(timeout) * 60))
							{
								Logger.info("Catalog::Authenticate.java","CATALOG::Authentication::Session timeout");
							}
							else
							{
								Etn.setContexte(rs.value("name"),rs.value("pass"));
								if(Etn.getId() > 0)//authenticated successfully ... update cookie with latest session ID value
								{
									Set rsl = Etn.execute("select * from login where pid = " + escape.cote(""+Etn.getId()) );
									if(rsl.next())
									{
										String siteid = "";
										long lSiteId = 0;
										if(parseNull(rsl.value("last_site_id")).length() > 0) 
										{
											try {
												lSiteId = Long.parseLong(parseNull(rsl.value("last_site_id")));
											} catch(Exception e) {}
										}
										if(lSiteId > 0)
										{
											siteid = parseNull(rsl.value("last_site_id"));                                
										}
										else
										{
											Set rsP = Etn.execute("select * from person_sites where person_id = " + escape.cote(""+Etn.getId()));
											if(rsP.rs.Rows == 1)//only one site is assigned to this user so we select it by default
											{
												rsP.next();
												siteid = parseNull(rsP.value("site_id"));
												Etn.executeCmd("update login set last_site_id = "+escape.cote(siteid)+" where pid = " + escape.cote(""+Etn.getId()));
											}
										}
										Etn.executeCmd("insert into " + com.etn.beans.app.GlobalParm.getParm("COMMONS_DB") + ".user_sessions (pid, catalog_session_id, selected_site_id) values ("+escape.cote(""+Etn.getId())+","+escape.cote("" + request.getSession().getId())+","+escape.cote(siteid)+") on duplicate key update pid = "+escape.cote(""+Etn.getId())+", last_updated_on = now(), selected_site_id = " + escape.cote(siteid) );
										request.getSession().setAttribute("SELECTED_SITE_ID", siteid);
									}			
								}
							}
						}
						else
						{
							Logger.info("Catalog::Authenticate.java","PORTAL::Authentication::Invalid access id provided");
						}					
					}
				}
			}
			else if(ssoauthid.length() > 0)//sso authentication
			{
				String ssoappid = "";
				Set rsconfig = Etn.execute("select * from config where code = 'sso_app_id' ");
				if(rsconfig.next()) ssoappid = rsconfig.value("val");

				String verifyurl = GlobalParm.getParm("SSO_APP_VERIFY_URL");
				if(verifyurl == null) verifyurl = "";
		
				if(verifyurl.length() == 0 || ssoappid.length() == 0)
				{
					Logger.info("Catalog::Authenticate.java","PORTAL::Authentication::SSO not configured");
				}
				else
				{
					HttpURLConnection c = null;
					try
					{
						URL u = new URL(verifyurl + "?appid="+ssoappid+"&auth="+ssoauthid);
						c = (HttpURLConnection) u.openConnection();
						c.setRequestMethod("GET");
						c.setRequestProperty("Content-length", "0");
						c.setUseCaches(false);
						c.setAllowUserInteraction(false);
						c.connect();
						int status = c.getResponseCode();
						
						String jsonresponse = "";
	
						switch (status) 
						{
							case 200:
							case 201:
								BufferedReader br = new BufferedReader(new InputStreamReader(c.getInputStream()));
								StringBuilder sb = new StringBuilder();
								String line;
								while ((line = br.readLine()) != null) 
								{
									sb.append(line+"\n");
								}
								br.close();
								jsonresponse = sb.toString();
						}
//						System.out.println("Returned json " + jsonresponse);
						String ssouuid = "";
						Gson gson = new Gson();

						Type listType = new TypeToken<Map<String,String>>(){}.getType();
						Map<String,String> map = gson.fromJson(jsonresponse, listType);
						String ssomsg = "";
						if(map.get("resp").equals("success"))
						{
							ssouuid = map.get("sso_id");
							Logger.info("Catalog::Authenticate.java",ssouuid);
						}
						else if(map.get("msg") != null)
						{
							ssomsg = map.get("msg");
							Logger.info("Catalog::Authenticate.java","PORTAL::Authentication::SSO error::" + ssomsg);
						}
						
						if(ssouuid.length() > 0)
						{
							Set rs = Etn.execute("select * from login where sso_id = " +  escape.cote(ssouuid)  );
							if(rs.next())
							{
								Etn.setContexte(rs.value("name"),rs.value("pass"));
								if(Etn.getId() > 0) addusagelog(Etn, request, rs.value("name"), "SSO login success", null);
								else addusagelog(Etn, request, rs.value("name"), "SSO login failure", ssomsg);
							}
							else
							{
								Logger.info("Catalog::Authenticate.java","PORTAL::Authentication::Invalid sso id");
							}
						}	
					}
					catch(Exception e) 
					{
						e.printStackTrace();
					}
					finally
					{
						if(c != null) 
						{
							try 
							{
								c.disconnect();
							}
							catch (Exception e) {}
						}	
					}
				}//end else
			}
			if( Etn.getId() == 0 )
			{
				response.setStatus(401);
				Etn.close();

				String queryString = request.getQueryString();
				if(queryString == null) queryString = "";
				if(queryString.length() > 0) queryString = "?" + queryString;
				String requestedUrl = request.getRequestURI();
				requestedUrl += queryString;
				
				String redirectUrl = "/login.jsp?errmsg=Your session is expired";
				redirectUrl += "&_url="+ URLEncoder.encode(requestedUrl,"UTF-8");				
				
				javax.servlet.RequestDispatcher r = request.getRequestDispatcher(redirectUrl);
				r.forward(request,response);
				return;
			}
        } 
		else
		{
			isSuperAdminAuthenticated = true;
		}
		
		//user is authenticated check ip restrictions		
		if(Etn.getId() > 0 && uri.endsWith("/admin/logout.jsp") == false)
		{
			boolean canContinue = true;
			Set rs = Etn.execute("Select allowed_ips from login where pid="+escape.cote(""+Etn.getId()));
			String ip = com.etn.asimina.util.ActivityLog.getIP(request);
			if(rs.next() && parseNull(rs.value("allowed_ips")).length() > 0)
			{
				canContinue = false;
				List<String> allowedIps = Arrays.asList(parseNull(rs.value("allowed_ips")).split(","));
				if(allowedIps.contains(ip)) canContinue = true;				
			}
			
			Logger.info("Catalog::Authenticate.java","Etn.getId:"+Etn.getId()+" canContinue:"+canContinue+" IP:"+ip);
			
			if(canContinue == false)
			{
				response.sendRedirect(request.getContextPath() + "/unauthorized.jsp?c=1");
				return;
			}
			
		}

		//first time this will be empty
		if(request.getSession().getAttribute("LOGIN") == null)
		{			
			//we add session id to cookie to keep the session alive for authenticate.java in _catalog
			//this will help solve the case where user logins to asimina and then goes to some other webapp like pages or forms etc 
			//user is active there but in the meantime the _catalog session expires... so when user tries to switch to another webapp later
			//session in _catalog is expired and user is asked to login which is wrong as he was active in some other webapp
			Cookie __cartCookie = new Cookie("__asm_adm_sid", request.getSession().getId());
			response.addCookie(__cartCookie);
			
			String req_login_1= "Select pr.profil, l.name,l.pid, p.first_name, p.Last_name,pp.profil_id, case when l.pass_expiry < now() then 1 else 0 end as passexpired from login l left join person p on p.person_id=l.pid left join profilperson pp on pp.person_id=l.pid left join profil pr on pr.profil_id = pp.profil_id where l.pid="+escape.cote(""+Etn.getId());
			Set res_1=Etn.execute(req_login_1);
			if(res_1.next())
			{
				request.getSession().setAttribute("LOGIN",res_1.value("name"));
				request.getSession().setAttribute("FIRST_NAME",res_1.value("first_name"));
				request.getSession().setAttribute("PROFIL_ID",res_1.value("profil_id"));
				request.getSession().setAttribute("PROFIL",res_1.value("profil"));
				request.getSession().setAttribute("PASS_EXPIRED",res_1.value("passexpired"));

				String accessid = java.util.UUID.randomUUID().toString();
				Etn.executeCmd("update login set access_id = "+escape.cote(accessid)+" where pid =  " + escape.cote(""+Etn.getId()) );
			}
		}

		if(("TEST_SITE_ACCESS".equalsIgnoreCase(parseNull(request.getSession().getAttribute("PROFIL"))) || "PROD_SITE_ACCESS".equalsIgnoreCase(parseNull(request.getSession().getAttribute("PROFIL"))))
			&& uri.endsWith("/admin/logout.jsp") == false)
		{
			response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
			return;
		}
		if(request.getSession().getAttribute("PROFIL") != null)
		{
			String profile = (String)request.getSession().getAttribute("PROFIL");
			//System.out.println("### PRofile is: " + profile);
			//System.out.println("###isSuperAdminAuthenticated:" + isSuperAdminAuthenticated );
			if("SUPER_ADMIN".equals(profile) && isSuperAdminAuthenticated == false)
			{
				response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
				return;
			}
		}

		Etn.executeCmd("update login set access_time = now() where pid =  " + Etn.getId());
		//propagate to next element in the filter chain, ultimately JSP/ servlet gets executed
		
		if(Etn.getId() > 0 && !uri.endsWith("/admin/logout.jsp") && !uri.endsWith("/admin/changePassword.jsp") && !uri.endsWith("/admin/changePasswordAjax.jsp"))
		{
			if("1".equals((String)request.getSession().getAttribute("PASS_EXPIRED")))
			{
				response.sendRedirect(request.getContextPath() + "/admin/changePassword.jsp");
				return;				
			}
		}
		
		chain.doFilter(request, response);

    }

    public void destroy()
    {
        this.filterConfig = null;
    }

    private String convertToHex(byte[] data)
    {
        StringBuffer buf = new StringBuffer();
        for (int i = 0; i < data.length; i++) {
            int halfbyte = (data[i] >>> 4) & 0x0F;
            int two_halfs = 0;
            do {
                if ((0 <= halfbyte) && (halfbyte <= 9))
                    buf.append((char) ('0' + halfbyte));
                else
                    buf.append((char) ('a' + (halfbyte - 10)));
                halfbyte = data[i] & 0x0F;
            } while(two_halfs++ < 1);
        }
        return buf.toString();
    }

    private String MD5(String text) throws NoSuchAlgorithmException, UnsupportedEncodingException
    {
        MessageDigest md;
        md = MessageDigest.getInstance("MD5");
        byte[] md5hash = new byte[32];
        md.update(text.getBytes("utf8"), 0, text.length());
        md5hash = md.digest();
        return convertToHex(md5hash);
    }

	void addusagelog(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String login, String activity, String details)
	{
		String useragent = "";
		useragent = request.getHeader("User-Agent");
		if(useragent == null) useragent = "";
		String activityfrom = "web";
		if(useragent.toLowerCase().indexOf("android") != -1 || useragent.toLowerCase().indexOf("ipad") != -1 || useragent.toLowerCase().indexOf("iphone") != -1 || useragent.toLowerCase().indexOf("apache-httpclient/unavailable") != -1 ) activityfrom = "device";

		if(details == null) details = "";
	
		String ip = "";
		if(request.getHeader("x-forwarded-for") != null) ip = request.getHeader("x-forwarded-for");
		Etn.executeCmd("insert into usage_logs (login, activity, ip, activity_from, user_agent, details) values ("+escape.cote(login)+","+escape.cote(activity)+","+escape.cote(ip)+","+escape.cote(activityfrom)+", "+escape.cote(useragent)+", "+escape.cote(details)+")");		
	}


}