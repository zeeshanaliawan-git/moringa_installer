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
import java.util.*;
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
import java.lang.reflect.Type;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import com.etn.util.Logger;

/**
 *
 * @author umair
 */
public class Authenticate implements Filter
{
    private FilterConfig filterConfig;

    boolean isloaded = false;
    ArrayList<String> containTypePublicUrls = new ArrayList<String>();
    ArrayList<String> endwithTypePublicUrls = new ArrayList<String>();
    public void init(FilterConfig filterConfig)
    {
        this.filterConfig = filterConfig;
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

    public void doFilter(ServletRequest _request, ServletResponse _response, FilterChain chain) throws IOException, ServletException
    {
        HttpServletRequest request = (HttpServletRequest)_request;
        HttpServletResponse response = (HttpServletResponse)_response;

        if(request.getSession().getAttribute("Etn") == null)
        {
            //System.out.println("##################### Etn is null");
            request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
        }

        com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");

		String logStr = "Shop";
		if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PROD_SHOP"))) logStr = "ProdShop";
		
		if(!isloaded) load(Etn);

		String uri = request.getRequestURI();
		if(Etn.getId() == 0 && isPublicUrl(uri))
		{
			chain.doFilter(request, response);
			return;
		}

		boolean isSuperAdminAuthenticated = false;
        if(Etn.getId() == 0)
        {
			String accessid = request.getParameter("__aid");
			if(accessid == null) accessid = "";

			String ssoauthid = request.getParameter("__authid");
			if(ssoauthid == null) ssoauthid = "";

			//System.out.println("Access id:" + accessid);
			if(accessid.length() > 0)
			{
				String timeout = com.etn.beans.app.GlobalParm.getParm("SESSION_TIMEOUT_MINS");
				if(timeout == null || timeout.trim().length() == 0) timeout = "60"; //mins
				Set rs = Etn.execute("select *,  TIMESTAMPDIFF(SECOND, access_time, now()) as _diff from login where access_id = " +  escape.cote(accessid)  );
				if(rs.next())
				{
					String timediff = rs.value("_diff");
					System.out.println("last access diff second : " + timediff);
					System.out.println("timeout mins : " + timeout);
					//check in seconds to be more accurate
					if(Integer.parseInt(timediff) > (Integer.parseInt(timeout) * 60))
					{
						System.out.println("PORTAL::Authentication::Session timeout");
					}
					else
					{
						Etn.setContexte(rs.value("name"),rs.value("pass"));
						isSuperAdminAuthenticated = true;
					}
				}
				else
				{
					System.out.println("PORTAL::Authentication::Invalid access id provided");
				}
			}
			else if(ssoauthid.length() > 0)//sso authentication
			{
				String ssoappid = "";
				Set rsconfig = Etn.execute("select * from config where code = 'sso_app_id' ");
				if(rsconfig.next()) ssoappid = rsconfig.value("val");

				String verifyurl = com.etn.beans.app.GlobalParm.getParm("SSO_APP_VERIFY_URL");
				if(verifyurl == null) verifyurl = "";

				if(verifyurl.length() == 0 || ssoappid.length() == 0)
				{
					System.out.println("PORTAL::Authentication::SSO not configured");
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
							System.out.println(ssouuid);
						}
						else if(map.get("msg") != null)
						{
							ssomsg = map.get("msg");
							System.out.println("PORTAL::Authentication::SSO error::" + ssomsg);
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
								System.out.println("PORTAL::Authentication::Invalid sso id");
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
//				response.sendRedirect(request.getContextPath() + "/login.jsp?errmsg=Your session is expired");
				return;
			}
        }
		else
		{
			isSuperAdminAuthenticated = true;
		}

	//user is authenticated check ip restrictions		
	if(Etn.getId() > 0 && uri.endsWith("/logout.jsp") == false && uri.endsWith("/unauthorized.jsp") == false)
	{
		boolean canContinue = true;
		Set rs = Etn.execute("Select allowed_ips from login where pid="+escape.cote(""+Etn.getId()));
		String ip =  com.etn.asimina.util.UIHelper.getIP(request);
		if(rs.next() && parseNull(rs.value("allowed_ips")).length() > 0)
		{
			canContinue = false;
			List<String> allowedIps = Arrays.asList(parseNull(rs.value("allowed_ips")).split(","));
			if(allowedIps.contains(ip)) canContinue = true;				
		}
		
		Logger.info(logStr+"::Authenticate.java","Etn.getId:"+Etn.getId()+" canContinue:"+canContinue+" IP:"+ip);
		
		if(canContinue == false)
		{
			response.sendRedirect(request.getContextPath() + "/unauthorized.jsp?c=1");
			return;
		}
		
	}

		if(request.getSession().getAttribute("LOGIN") == null)
		{
            String req_login_1= "Select pr.profil, l.name,l.pid, p.first_name, p.Last_name,pp.profil_id, case when l.pass_expiry < now() then 1 else 0 end as passexpired from login l left join person p on p.person_id=l.pid left join profilperson pp on pp.person_id=l.pid left join profil pr on pr.profil_id = pp.profil_id where l.pid="+escape.cote(""+Etn.getId());//change
            Set res_1=Etn.execute(req_login_1);
            if(res_1.next())
            {
                request.getSession().setAttribute("LOGIN",res_1.value("name"));
                request.getSession().setAttribute("FIRST_NAME",res_1.value("first_name"));
                request.getSession().setAttribute("PROFIL_ID",res_1.value("profil_id"));
                request.getSession().setAttribute("PROFIL",res_1.value("profil"));
				request.getSession().setAttribute("PASS_EXPIRED",res_1.value("passexpired"));

				String accessid = java.util.UUID.randomUUID().toString();
				Etn.executeCmd("update login set access_id = "+escape.cote(accessid)+" where pid =  " + escape.cote(""+Etn.getId()));//change
            }
		}

		Etn.executeCmd("update login set access_time = now() where pid =  " + escape.cote(""+Etn.getId()));//change

		uri = request.getRequestURI();
		if(Etn.getId() > 0 && !uri.endsWith("/logout.jsp") && !uri.endsWith("/changePassword.jsp") && !uri.endsWith("/changePasswordAjax.jsp"))
		{
			if("1".equals((String)request.getSession().getAttribute("PASS_EXPIRED")))
			{
				response.sendRedirect(request.getContextPath() + "/changePassword.jsp");
				return;
			}
		}

		//propagate to next element in the filter chain, ultimately JSP/ servlet gets executed
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
	private void  load(com.etn.beans.Contexte Etn){
		// run only once
		System.out.println("************Load()************");
		Set rs =  Etn.execute("select * from public_urls");
		while(rs.next()){
			if(rs.value("url_type").equals("endsWith"))
				endwithTypePublicUrls.add(rs.value("url"));
			else if(rs.value("url_type").equals("contains"))
				containTypePublicUrls.add(rs.value("url"));
		}
		isloaded = true;
	}
	private boolean isPublicUrl(String uri){
		for(String url : endwithTypePublicUrls){
			if(uri.endsWith(url)) {
				return true;
			}
		}
		for(String url : containTypePublicUrls){
			if(uri.contains(url)) {
				return true;
			}
		}
		return false;
	}
}