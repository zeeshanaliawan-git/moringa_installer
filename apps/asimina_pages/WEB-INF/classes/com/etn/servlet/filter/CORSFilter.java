package com.etn.servlet.filter;

import com.etn.lang.ResultSet.Set;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class CORSFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
		
	}

    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain) throws IOException, ServletException {
		HttpServletRequest request = (HttpServletRequest) servletRequest;
		HttpServletResponse resp = (HttpServletResponse) servletResponse;
		
		com.etn.util.Logger.info("CORSFilter.java","==========================================");
		com.etn.util.Logger.info("CORSFilter.java","Server name : " + request.getServerName());
		com.etn.util.Logger.info("CORSFilter.java","Strict CORS mode : " + ("1".equals(GlobalParm.getParm("STRICT_CORS"))));
		if("1".equals(GlobalParm.getParm("STRICT_CORS")))
		{			
			if(request.getSession().getAttribute("Etn") == null)
			{
				//System.out.println("##################### Etn is null");
				request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
			}

			com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");

			String domainsList = "";
			Set rs = Etn.execute("select * from "+GlobalParm.getParm("COMMONS_DB")+".cors_whitelist");
			while(rs.next())
			{
				if(domainsList.length() > 0) domainsList += " ";
				domainsList += rs.value("w_domain");
			}
			if(domainsList.length() > 0)
			{
				resp.addHeader("Access-Control-Allow-Origin", domainsList);
			}
		}
		else
		{
			resp.addHeader("Access-Control-Allow-Origin", "*");
		}
		
		resp.addHeader("Access-Control-Allow-Methods","GET,POST");
		resp.addHeader("Access-Control-Allow-Headers","Origin, X-Requested-With, Content-Type, Accept, Authorization, access-token");
		
		// Just ACCEPT and REPLY OK if OPTIONS
		if ( request.getMethod().equals("OPTIONS") ) {
			resp.setStatus(HttpServletResponse.SC_OK);
			return;
		}
		chain.doFilter(request, servletResponse);
	}

	@Override
	public void destroy() {
		
	}
}