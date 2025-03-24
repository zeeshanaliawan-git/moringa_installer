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


public class APIV2AccessToken implements Filter {

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

        String commonDb = com.etn.beans.app.GlobalParm.getParm("COMMONS_DB");
		final String authorization = request.getHeader("Authorization");
        String accessToken = "";

		if(authorization != null && authorization.startsWith("Bearer"))
		{
			accessToken  = authorization.substring("Bearer".length()).trim();
		}

        JSONObject respJson = new JSONObject();
        PrintWriter out = response.getWriter();

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if(accessToken != null && accessToken.length()>0)
        {
            if(request.getSession().getAttribute("Etn") == null)
                request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
            
            com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");

            Set rs = Etn.execute("select token, (NOW() > expiration) as expired, TIMESTAMPDIFF(second,expiration,NOW()) as remaining_seconds, api_id from " + commonDb + ".access_tokens where `token` = " + escape.cote(accessToken));
            if(rs.rs.Rows > 0)
            {   
                rs.next();
                String expired = parseNull(rs.value("expired"));
                if(expired.equals("1"))
                {
                    try{
                        respJson.put("status",5);
                        respJson.put("err_code","ACCESS_TOKEN_EXPIRED");
                        respJson.put("err_msg","Access token provided is already expired");
                        out.print(respJson.toString());
                        out.flush();
                        response.setStatus(401);
                    }catch(JSONException e)
                    {
                        response.setStatus(500);
                        throw new ServletException("JSON Exception occurred",e);
                    }
                    return;
                }
                else{
					request.getSession().setAttribute("api_token_key_id", rs.value("api_id"));
                    //response.setStatus(200);
                }
            } 
            else
            {
                try{
                    respJson.put("status",10);
                    respJson.put("err_code","INVALID_ACCESS_TOKEN");
                    respJson.put("err_msg","Access token is invalid");
                    out.print(respJson.toString());
                    out.flush();
                    response.setStatus(401);
                }catch(JSONException e)
                {
                    response.setStatus(500);
                    throw new ServletException("JSON Exception occurred",e);
                }
                return;
            }
            
        }
        else{
            try{
                respJson.put("status",20);
                respJson.put("err_code","ACCESS_TOKEN_MISSING");
                respJson.put("err_msg","Access token is missing");
                out.print(respJson.toString());
                out.flush();
                response.setStatus(401);
            }catch(JSONException e)
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
