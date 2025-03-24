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
import org.json.*;


public class APIV2SiteCheck implements Filter {

    private FilterConfig filterConfig;

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

    public void doFilter(ServletRequest _request, ServletResponse _response, FilterChain chain) throws IOException, ServletException
    {
        HttpServletRequest request = (HttpServletRequest)_request;
        HttpServletResponse response = (HttpServletResponse)_response;
        Map<String, String> headerInfo = getHeadersInfo(request);

        String siteUuid = headerInfo.get("site-uuid");
        JSONObject respJson = new JSONObject();
        PrintWriter out = response.getWriter();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        
        if(siteUuid != null && siteUuid.length()>0)
        {
            if(request.getSession().getAttribute("Etn") == null)
                request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());

            com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");
            Set rs = Etn.execute("select * from sites where suid="+escape.cote(siteUuid));
            
            if(rs!=null && rs.rs.Rows > 0)
            {
                System.out.println("success");
                response.setStatus(200);
            } 
            else
            {
                try{
                    respJson.put("status",31);
                    respJson.put("err_code","INVALID_SITE_ID");
                    respJson.put("err_msg","Site ID is not valid");
                    respJson.put("siteuuid",siteUuid);
                    out.print(respJson.toString());
                    out.flush();
                    response.setStatus(400);
                }
                catch(JSONException e)
                {
                    response.setStatus(500);
                    throw new ServletException("JSON Exception occurred",e);
                }
                return;
            }
        }
        else{
            try{
                respJson.put("status",30);
                respJson.put("err_code","SITE_ID_MISSING");
                respJson.put("err_msg","Site ID is missing");
                out.print(respJson.toString());
                out.flush();
                response.setStatus(400);
            }
            catch(JSONException e)
            {
                response.setStatus(500);
                throw new ServletException("JSON Exception occurred",e);
            }
            return;
        }
        chain.doFilter(_request, _response);
    }

    public void destroy()
    {
        this.filterConfig = null;
    }
}
