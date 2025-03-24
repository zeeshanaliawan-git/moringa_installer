/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.servlet.filter;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Umair Aziz
 */
public class IPFiltering implements Filter
{
    private FilterConfig filterConfig;
    public static List<String> ips = new ArrayList<String>();//cache des pages autorises (index par l'url)    
    
    public void init(FilterConfig filterConfig)
    {
        this.filterConfig = filterConfig;
    }

    public void doFilter(ServletRequest _request, ServletResponse _response, FilterChain chain) throws IOException, ServletException
    {
        HttpServletRequest request = (HttpServletRequest)_request;
        HttpServletResponse response = (HttpServletResponse)_response;

        if(request.getSession().getAttribute("Etn") == null)
        {
//            System.out.println("##################### Etn is null");
            request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
        }

        com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");
        
        loadIps(Etn);
        
        boolean invalidIp = false;
        if(!ips.isEmpty())//check ip 
        {
            String ip = request.getRemoteAddr();
//            System.out.println("Accessed by " + ip);
            if(!ips.contains(ip))
            {
                System.out.println("ERROR:IPFiltering Application accessed by invalid IP : " + ip + " at " + (new Date()));
                response.sendRedirect(request.getContextPath() + "/forbidden.html");
                invalidIp = true;
            }
        }
        
        if(!invalidIp) chain.doFilter(request, response);
    }    
    
    private void loadIps(ClientSql etn)
    {
        ServletContext sc = this.filterConfig.getServletContext();                
        if(ips.isEmpty() || sc.getAttribute("RELOAD_IPS") != null)
        {
            System.out.println("INFO:IPFiltering Loading IPs list");
            ips.clear();
            sc.removeAttribute("RELOAD_IPS");
            Set rs = etn.execute(" select * from allowed_ips ");
            while(rs.next())
            {
                String fip = parseNull(rs.value("ip_from"));
                String tip = parseNull(rs.value("ip_to"));     
                if(tip.endsWith("*")) 
                {
                    System.out.println("ERROR:IPFiltering Not a valid ip " + fip + " to " + tip);
                    continue;
                }//this is invalid
                if(fip.endsWith("*"))//means its a complete range
                {
                    String st = fip.substring(0, fip.lastIndexOf("."));
                    for(int i=1; i<=255; i++)
                    {
                        ips.add(st+"."+i);                        
                    }
                }
                else if(!"".equals(fip) && !"".equals(tip))//its a range
                {
                    String fst = fip.substring(0, fip.lastIndexOf("."));
                    String tst = tip.substring(0, tip.lastIndexOf("."));
                    if(fst.equals(tst))//same ips
                    {
                        int flst = Integer.parseInt(fip.substring(fip.lastIndexOf(".") + 1));//last part of from ip
                        int tlst = Integer.parseInt(tip.substring(tip.lastIndexOf(".") + 1));//last part of to ip
                        for(int i=flst; i<=tlst; i++)
                        {
                            ips.add(fst+"."+i);
                        }
                    }
                    else System.out.println("ERROR:IPFiltering Not a valid ip range " + fip + " to " + tip);
                }
                else if(!"".equals(fip))
                {
                    ips.add(fip);
                }
            }
        }        
    }
    
    private String parseNull(Object o)
    {
        if( o == null ) return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase())) return("");
        else return(s.trim());
    }
    
    
    public void destroy()
    {
        this.filterConfig = null;
    }
    
}
