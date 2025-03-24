/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.servlet.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import com.etn.request.RequestWrapper;

/**
 *
 * @author umair
 */
public class XSSFilter implements Filter
{
    private FilterConfig filterConfig;

    public void init(FilterConfig filterConfig)
    {
        this.filterConfig = filterConfig;
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException
    {
        HttpServletRequest _request = (HttpServletRequest)request;
        
        String path = _request.getServletPath();
        
        if(path.startsWith("/expertSystem/"))//for expert system we don't have to apply xss filter as we will be saving javascript/html in db
            chain.doFilter(request,  response);
        else
            chain.doFilter(new RequestWrapper((HttpServletRequest)request),  response);
    }

    public void destroy()
    {
        this.filterConfig = null;
    }

}