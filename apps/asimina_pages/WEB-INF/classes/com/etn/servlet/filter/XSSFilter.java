/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.servlet.filter;

import com.etn.lang.ResultSet.Set;
import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import com.etn.request.RequestWrapper;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

/**
 *
 * @author umair
 */
public class XSSFilter implements Filter
{
    private FilterConfig filterConfig;
    private Map<String, List<String>> ignoreUrlFields;

    public void init(FilterConfig filterConfig)
    {
        this.filterConfig = filterConfig;
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException
    {
		if(((HttpServletRequest)request).getSession().getAttribute("Etn") == null)
		{
			((HttpServletRequest)request).getSession().setAttribute("Etn", new com.etn.beans.Contexte());
		}
		com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)((HttpServletRequest)request).getSession().getAttribute("Etn");
		
		load(Etn);

        chain.doFilter(new RequestWrapper((HttpServletRequest)request, ignoreUrlFields),  response);
    }

    public void destroy()
    {
        this.filterConfig = null;
    }

    private void load(com.etn.beans.Contexte etn)
    {
        if(ignoreUrlFields == null || ignoreUrlFields.isEmpty())
        {
			ignoreUrlFields = new HashMap<String, List<String>>();
			
            Set rs = etn.execute("select * from ignore_xss_fields ");
            while(rs !=null && rs.next())
            {
				if(ignoreUrlFields.get(rs.value("url")) == null)
				{
					ignoreUrlFields.put(rs.value("url"), new ArrayList<String>());
				}
				List<String> ifields = ignoreUrlFields.get(rs.value("url"));
				ifields.add(rs.value("field"));
            }
        }
    }
}