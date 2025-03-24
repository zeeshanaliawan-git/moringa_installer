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
public class ApiKeyAuthenticate implements Filter
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

        String commonDb = com.etn.beans.app.GlobalParm.getParm("COMMONS_DB");
        String apiKey = headerInfo.get("api-key");

        if(null != apiKey && apiKey.length() > 0){

            if(request.getSession().getAttribute("Etn") == null)
            {
                request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
            }

            com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");

            Set rs = Etn.execute("select * from " + commonDb + ".app_keys where `key` = " + escape.cote(apiKey));

            if(rs.rs.Rows > 0)
            {
                if(rs.next()){
                    
                    String status = rs.value("is_active");
                    if(status.equals("1")){

                        String id = rs.value("id");
						//we dont have to set these to asimina web session because in case there are 2 servers
						//and next request comes to second one still these values will be set again in tomcat session
                        request.getSession().setAttribute("api_app_key", rs.value("key"));
                        request.getSession().setAttribute("api_app_key_prod", rs.value("is_prod"));

                    } else {


                        response.setContentType("application/json");
                        response.setCharacterEncoding("UTF-8");

                        PrintWriter out = response.getWriter();
                        out.print("{\"msg\":\"Api key is not active.\",\"status\":1}");
                        out.flush();

                        response.setStatus(401);

                        return;
                    }
                }
            } 
            else
            {

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");

                PrintWriter out = response.getWriter();

                out.print("{\"msg\":\"Api key is not valid.\",\"status\":2}");
                out.flush();

                response.setStatus(401);

                return;
           }

        } else{

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            PrintWriter out = response.getWriter();

            out.print("{\"msg\":\"Api key is missing.\",\"status\":3}");
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