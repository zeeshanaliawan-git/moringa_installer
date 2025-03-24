/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.servlet.filter;

import com.etn.Client.Impl.ClientSql;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Enumeration;
import java.util.Map;
import java.util.HashMap;
import java.io.PrintWriter;

/**
 *
 * @author umair
 */
public class ApiSiteCheck implements Filter
{
    private FilterConfig filterConfig;

    public void init(FilterConfig filterConfig)
    {
        this.filterConfig = filterConfig;
    }

    public void doFilter(ServletRequest _request, ServletResponse _response, FilterChain chain) throws IOException, ServletException
    {

        HttpServletRequest request = (HttpServletRequest)_request;
        HttpServletResponse response = (HttpServletResponse)_response;

        Map<String, String> headerInfo = getHeadersInfo(request);

        String path = request.getServletPath();
		if(!path.equals("/api/adm/userauth.jsp") && !path.equals("/api/adm/usersites.jsp") && !path.equals("/api/adm/authenticate.jsp") && !path.equals("/api/adm/verifysession.jsp"))
		{
			com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");
			
			String dbname = "";
			if(request.getSession().getAttribute("api_app_key_prod") != null && "1".equals((String)request.getSession().getAttribute("api_app_key_prod"))) dbname = GlobalParm.getParm("PROD_DB") +".";    

			String siteUuid = headerInfo.get("site-uid");
			if(siteUuid == null || siteUuid.length() == 0)
			{
				response.setContentType("application/json");
				response.setCharacterEncoding("UTF-8");

				PrintWriter out = response.getWriter();
				out.write("{\"msg\":\"Site uuid is missing in header\",\"status\":1}");		
				return;
			}
			Set siteRs = Etn.execute("select * from "+dbname+"sites where suid = " + escape.cote(siteUuid));
			if(siteRs.rs.Rows == 0)
			{
				response.setContentType("application/json");
				response.setCharacterEncoding("UTF-8");
				PrintWriter out = response.getWriter();
				out.write("{\"msg\":\"No site found against provided site uuid\",\"status\":1}");		
				return;
			}
			siteRs.next();
			String siteid = siteRs.value("id");
			//we dont have to set these to asimina web session because in case there are 2 servers
			//and next request comes to second one still these values will be set again in tomcat session
			request.getSession().setAttribute("api_site_id", siteid);
			request.getSession().setAttribute("api_site_uuid", siteUuid);
		}
		
        chain.doFilter(_request, _response);
    }

    public void destroy()
    {
        this.filterConfig = null;
    }
 
    public Map<String, String> getHeadersInfo(HttpServletRequest request) {

        Map<String, String> map = new HashMap<String, String>();

        Enumeration headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String key = (String) headerNames.nextElement();
            String value = request.getHeader(key);
            map.put(key, value);
        }

        return map;
    }
}