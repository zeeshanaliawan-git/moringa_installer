/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.servlet.filter;

import com.etn.Client.Impl.ClientSql;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author ahsan
 */
public class CheckSiteSelection implements Filter
{
    private FilterConfig filterConfig;
    public static Map<Integer,Map<String,Boolean>> pagesRight=new HashMap<Integer,Map<String,Boolean>>();//cache des pages autorises (index par l'url)
    public static Map<Integer,List<String>> pagesRules=new HashMap<Integer,List<String>>();//cache des pages autorises (indexpar l'url)
    public static List<String> checkRightsOn=new ArrayList<String>();

    public void init(FilterConfig filterConfig)
    {
        this.filterConfig = filterConfig;
    }

    public void doFilter(ServletRequest _request, ServletResponse _response, FilterChain chain) throws IOException, ServletException
    {
        HttpServletRequest request = (HttpServletRequest)_request;
        HttpServletResponse response = (HttpServletResponse)_response;

        String selectedsiteid = "";
        selectedsiteid = (String)request.getSession().getAttribute("SELECTED_SITE_ID");
        if(selectedsiteid==null || selectedsiteid.length() == 0)
        {
            response.sendRedirect(request.getContextPath() + "/admin/gestion.jsp?err=1");
            return;
        }

        chain.doFilter(request, response);
    }

    public void destroy()
    {
        this.filterConfig = null;
    }
}