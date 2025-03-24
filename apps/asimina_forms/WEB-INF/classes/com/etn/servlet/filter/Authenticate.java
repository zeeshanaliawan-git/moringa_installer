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
import java.net.URLEncoder;

import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.beans.app.GlobalParm;

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

		if(request.getSession().getAttribute("Etn") == null)
		{
			request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
		}
		com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");

		if(Etn.getId() == 0)
		{
			boolean gotogestion = true;
			String webappToken = request.getParameter("__wt");
			if(webappToken == null) webappToken = "";				
			
			Logger.info("Forms::Authenticate","Webapp token : "+webappToken);				
			if(webappToken.length() > 0)
			{
				Set rsW = Etn.execute("select * From "+GlobalParm.getParm("COMMONS_DB")+".webapps_auth_tokens where expiry >= now() and id = "+escape.cote(webappToken));
				if(rsW.next())
				{
					String accessid = rsW.value("access_id");
					Logger.info("Forms::Authenticate","accessid : "+accessid);
					String catalogsessionid = rsW.value("catalog_session_id");
					Logger.info("Forms::Authenticate","catalogsessionid : "+catalogsessionid);
					
					String timeout = GlobalParm.getParm("SESSION_TIMEOUT_MINS");
					if(timeout == null || timeout.trim().length() == 0) timeout = "60"; //mins
					// System.out.println("PORTAL::timeout :: "+ timeout);

					Set rs = Etn.execute("select *,  TIMESTAMPDIFF(SECOND, access_time, now()) as _diff from login where access_id = " +  escape.cote(accessid)  );
					if(rs.next())
					{
						String timediff = rs.value("_diff");
						// System.out.println("last access diff : " + timediff);
						//check in seconds to be more accurate
						if(Integer.parseInt(timediff) > (Integer.parseInt(timeout) * 60))
						{
							// System.out.println("PORTAL::Authentication::Session timeout");
							Logger.info("Forms::Authenticate", "Session timeout");
						}
						else
						{
							Etn.setContexte(rs.value("name"),rs.value("pass"));
							Etn.executeCmd("insert into "+GlobalParm.getParm("COMMONS_DB")+".user_sessions (catalog_session_id, forms_session_id) values ("+escape.cote(catalogsessionid)+","+escape.cote(""+request.getSession().getId())+") on duplicate key update last_updated_on = now(), forms_session_id = "+escape.cote(""+request.getSession().getId()));
							gotogestion = false;
						}
					}
					
					Etn.executeCmd("delete from "+GlobalParm.getParm("COMMONS_DB")+".webapps_auth_tokens where id = "+escape.cote(webappToken));
				}
				else
				{
					Logger.info("Forms::Authenticate", "Webapp token is expired");
				}
			}

			Logger.info("Forms::Authenticate","gotogestion : "+gotogestion);	


			if(gotogestion)
			{
				String queryString = request.getQueryString();
				if(queryString == null) queryString = "";
				if(queryString.length() > 0) queryString = "?" + queryString;
				String requestedUrl = request.getRequestURI();
				requestedUrl += queryString;
				String redirectUrl = GlobalParm.getParm("GOTO_FORMS_APP_URL");
				redirectUrl += redirectUrl.indexOf("?") > 0  ? "&" : "?";
				redirectUrl += "_url="+ URLEncoder.encode(requestedUrl,"UTF-8");
				response.sendRedirect(redirectUrl);
				return;
			}
		}

		//user is authenticated check ip restrictions		
		if(Etn.getId() > 0)
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
			
			Logger.info("Forms::Authenticate","Etn.getId:"+Etn.getId()+" canContinue:"+canContinue+" IP:"+ip);
			
			if(canContinue == false)
			{
				response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
				return;
			}
			
		}

		if(request.getSession().getAttribute("LOGIN") == null)
		{
			String req_login_1= "Select pr.profil, l.name,l.pid, p.first_name, p.Last_name,pp.profil_id, l.access_id from login l left join person p on p.person_id=l.pid left join profilperson pp on pp.person_id=l.pid left join profil pr on pr.profil_id = pp.profil_id where l.pid='"+Etn.getId()+"' ";
			Set res_1=Etn.execute(req_login_1);
			if(res_1.next())
			{
				request.getSession().setAttribute("LOGIN",res_1.value("name"));
				request.getSession().setAttribute("FIRST_NAME",res_1.value("first_name"));
				request.getSession().setAttribute("PROFIL_ID",res_1.value("profil_id"));
				request.getSession().setAttribute("PROFIL",res_1.value("profil"));
				request.getSession().setAttribute("LOGIN_ACCESS_ID",res_1.value("access_id"));
			}
		}

		if("TEST_SITE_ACCESS".equalsIgnoreCase(parseNull(request.getSession().getAttribute("PROFIL"))) || "PROD_SITE_ACCESS".equalsIgnoreCase(parseNull(request.getSession().getAttribute("PROFIL"))))
		{
			response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
			return;
		}

		String sAccessId = (String)request.getSession().getAttribute("LOGIN_ACCESS_ID");
		int _r = Etn.executeCmd("update login set access_time = now() where pid =  " + Etn.getId() + " and access_id = " + escape.cote(sAccessId));
		if(_r == 0)//no row updated means access id is invalid which is the case when we logout from _catalog webapp it resets access id so that this app session should be invalidated also
		{
			//we clear the session and go to gestion url in this case
			java.util.Enumeration e = (java.util.Enumeration) (request.getSession().getAttributeNames());

			Etn.close();
			while ( e.hasMoreElements())
			{
				String attr = (String)e.nextElement();
				request.getSession().removeAttribute(attr);
			}
			
			String queryString = request.getQueryString();
			if(queryString == null) queryString = "";
			if(queryString.length() > 0) queryString = "?" + queryString;
			String requestedUrl = request.getRequestURI();
			requestedUrl += queryString;
			String redirectUrl = GlobalParm.getParm("GOTO_FORMS_APP_URL");
			redirectUrl += redirectUrl.indexOf("?") > 0  ? "&" : "?";
			redirectUrl += "_url="+ URLEncoder.encode(requestedUrl,"UTF-8");

			request.getSession().invalidate();
			response.sendRedirect(redirectUrl);
			return;
		}

		// System.out.println("PORTAL::Authentication::Etn ID = "  + Etn.getId());

		//propagate to next element in the filter chain, ultimately JSP/ servlet gets executed
		chain.doFilter(request, response);
	}

	public void destroy()
	{
		this.filterConfig = null;
}

}