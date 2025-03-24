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
 * @author umair
 */
public class AccessRights implements Filter
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

        String path = request.getServletPath();
//	 System.out.println("--------- AccessRights : " + request.getContextPath() + path);
        if(!path.equals("/unauthorized.jsp"))
        {
            com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");
//System.out.println("PATH::::::::" + path);
            load(Etn);

            //in case of requeteur request, we let requeteur handle it. We are not sure what pages
            //we need to check rights on. Whereas in eshop we just check rights on pages which are there
            if(checkRights(path, request.getContextPath()))
            {
                if(!isAuthorized(Integer.parseInt((String)request.getSession().getAttribute("PROFIL_ID")), path, Etn, request.getContextPath()))
		  {
                    response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
		      return;
		  }
            }
            //propagate to next element in the filter chain, ultimately JSP/ servlet gets executed
        }
        chain.doFilter(request, response);
    }

    public void destroy()
    {
        this.filterConfig = null;
    }

    private boolean checkRights(String path, String contextpath)
    {
        for(String s : checkRightsOn)
        {
			if(s == null || s.trim().length() == 0) continue;
            if(path.startsWith(s) || (contextpath + path).startsWith(s)) return true;
        }
        return false;
    }

    private void load(ClientSql etn)
    {
        if(pagesRules.isEmpty())
        {
            String query="select * from page_profil order by profil_id ";
            Set res=etn.execute(query);
            List<String> rules=new ArrayList<String>();
            while(res!=null && res.next())
            {
			List<String> lt = pagesRules.get(Integer.parseInt(res.value("profil_id")));
			if(lt == null) pagesRules.put(Integer.parseInt(res.value("profil_id")), new ArrayList<String>());
			lt = pagesRules.get(Integer.parseInt(res.value("profil_id")));
			lt.add(res.value("url"));

            }
		//get sub urls and add to list of urls
		res = etn.execute("select s.sub_url, p.profil_id from page_sub_urls s, page_profil p where p.url = s.url order by p.profil_id ");
		while(res != null && res.next())
		{
			List<String> lt = pagesRules.get(Integer.parseInt(res.value("profil_id")));
			if(lt == null) pagesRules.put(Integer.parseInt(res.value("profil_id")), new ArrayList<String>());
			lt = pagesRules.get(Integer.parseInt(res.value("profil_id")));
			lt.add(res.value("sub_url"));
		}
        }
        if(checkRightsOn.isEmpty())
        {
            Set rs = etn.execute("select distinct url from page where url not like 'http://%' and url not like 'https://%' ");
            while(rs.next()) checkRightsOn.add(rs.value("url"));
		rs = etn.execute("select distinct sub_url from page_sub_urls ");
            while(rs.next()) checkRightsOn.add(rs.value("sub_url"));
        }
    }

    private boolean isAuthorized(Integer pid, String page, ClientSql etn, String contextpath)
    {
        Map<String,Boolean> pages=pagesRight.get(pid);
        Boolean ok=null;
        if(pages!=null) ok=pages.get(page);
        else
        {
            pages=new HashMap<String, Boolean>();
            pagesRight.put(pid, pages);
        }
        if(ok==null)
        {
            List<String> patterns=pagesRules.get(pid);
            if(patterns==null) load(etn);
            patterns=pagesRules.get(pid);
            if(patterns != null)//this check is to avoid case of reloading pages from page_profil and still no page is there for that particular profil_id
            {
                for(String s : patterns)
                {
                    if(page.startsWith(s) || (contextpath + page).startsWith(s) ){
                        ok=new Boolean(true);
                        break;
                    }
                }
            }
            if(ok==null) ok=new Boolean(false);
            pages.put(page,ok);
        }
        return ok.booleanValue();
    }


}