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
 * @author abj
 */
public class LoginSessionCheck implements Filter
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

        String sessionId = headerInfo.get("login-session-id");
		if(sessionId != null && sessionId.length() > 0){
			String catalogdb = GlobalParm.getParm("CATALOG_DB");
			if(request.getSession().getAttribute("Etn") == null)
            {
                request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
            }

            com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");
			String query = "select 1 from " + catalogdb + ".login_sessions where session_id =  " + escape.cote(sessionId) + " and now() < end_time";
			Set rsSession = Etn.execute(query);
			if(rsSession != null && rsSession.next()){
				Etn.executeCmd("update " + catalogdb + ".login_sessions set last_update_time = now(),end_time = date_add(now(),interval 60 minute) where session_id = " + escape.cote(sessionId));
				
			}else{
				response.setContentType("application/json");
				response.setCharacterEncoding("UTF-8");

				PrintWriter out = response.getWriter();
				out.print("{\"msg\":\"Invalid session id.\",\"status\":2,\"done\":false}");
				out.flush();

				response.setStatus(401);

				return;
			}
		}else{
			response.setContentType("application/json");
			response.setCharacterEncoding("UTF-8");

			PrintWriter out = response.getWriter();
			out.print("{\"msg\":\"Session id nor provided.\",\"status\":1,\"done\":false}");
			out.flush();

			response.setStatus(401);
			return;
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
