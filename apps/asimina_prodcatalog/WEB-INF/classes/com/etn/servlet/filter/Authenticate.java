/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.servlet.filter;

import com.etn.lang.ResultSet.Set;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.StringTokenizer;
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
public class Authenticate implements Filter
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

        if(request.getSession().getAttribute("Etn") == null)
        {
            //System.out.println("##################### Etn is null");
            request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
        }

        com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");
        //System.out.println("##################### Etn found");
        if(Etn.getId() == 0)
        {
            String __n = null;
            String __p = null;
            boolean md5 = false;
                String __auth = request.getHeader("Authorization");

                if(__auth == null )
                {
                //nbr1++;
        //        request.getSession().setAttribute("nbr1",""+nbr1);

                    response.setStatus(401);
                    response.setHeader("Pragma","No-cache");
                    response.setHeader("Cache-Control","no-cache");
                    response.setHeader("Expires",new java.util.Date(System.currentTimeMillis()+60000).toString());
                    response.setHeader("WWW-Authenticate","Basic realm=\""+"Portal"+"\"");

                    return;
                }

                StringTokenizer __st = new StringTokenizer(__auth);
                String mode = __st.nextToken();

                java.io.ByteArrayOutputStream __b = new java.io.ByteArrayOutputStream();
                com.etn.util.Decode64 __d = new com.etn.util.Decode64(__b,__st.nextToken());

                __st = new StringTokenizer(__b.toString(),":");

                if(__st.hasMoreElements() ) __n = __st.nextToken();
                if(__st.hasMoreElements() ) __p = __st.nextToken();
                
                md5 = true;
            if( __n!= null && __p != null )
            {
                if( Etn.getId() == 0 );
                //GlobalParm.init(session.getServletContext().getInitParameter("etnconf")  );
                else Etn.close();
                if( __n.length() < 64 && __p.length() < 64 )
                {
                    __n = com.etn.sql.escape.sql(__n.trim());
                    __p = com.etn.sql.escape.sql(__p.trim());
                    if(md5)
                    {
                        try
                        {
                            __p = MD5(__p);
                        }
                        catch(NoSuchAlgorithmException e)
                        {
                            e.printStackTrace();
                            throw new ServletException(e.getMessage());
                        }
                    }
                    if( __n.length() > 0 && __p.length() > 0 ) Etn.setContexte(__n,__p) ;
                }
            }
            else Etn.close();

            if( Etn.getId() == 0 )
            {
            //nbr1++;
            //session.setAttribute("nbr1",""+nbr1);
                response.setStatus(401);
                response.setHeader("Pragma","No-cache");
                response.setHeader("WWW-Authenticate","Basic realm=\""+"Portal"+"\"");
                return;
            }
        }
        
	if(request.getSession().getAttribute("LOGIN") == null)
	{
            String req_login_1= "Select pr.profil, l.name,l.pid, p.first_name, p.Last_name,pp.profil_id from login l left join person p on p.person_id=l.pid left join profilperson pp on pp.person_id=l.pid left join profil pr on pr.profil_id = pp.profil_id where l.pid='"+Etn.getId()+"' ";
            Set res_1=Etn.execute(req_login_1);
            if(res_1.next())
            {
                request.getSession().setAttribute("LOGIN",res_1.value("name"));
                request.getSession().setAttribute("FIRST_NAME",res_1.value("first_name"));
                request.getSession().setAttribute("PROFIL_ID",res_1.value("profil_id"));
                request.getSession().setAttribute("PROFIL",res_1.value("profil"));
            }
	}

//        if (!isAuth()) {
//        resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
//        return; //break filter chain, requested JSP/servlet will not be executed
//        }
//
        //propagate to next element in the filter chain, ultimately JSP/ servlet gets executed
        chain.doFilter(request, response);
    }

    public void destroy()
    {
        this.filterConfig = null;
    }

    private String convertToHex(byte[] data) 
    { 
        StringBuffer buf = new StringBuffer();
        for (int i = 0; i < data.length; i++) { 
            int halfbyte = (data[i] >>> 4) & 0x0F;
            int two_halfs = 0;
            do { 
                if ((0 <= halfbyte) && (halfbyte <= 9)) 
                    buf.append((char) ('0' + halfbyte));
                else 
                    buf.append((char) ('a' + (halfbyte - 10)));
                halfbyte = data[i] & 0x0F;
            } while(two_halfs++ < 1);
        } 
        return buf.toString();
    } 
 
    private String MD5(String text) throws NoSuchAlgorithmException, UnsupportedEncodingException  
    { 
        MessageDigest md;
        md = MessageDigest.getInstance("MD5");
        byte[] md5hash = new byte[32];
        md.update(text.getBytes("utf8"), 0, text.length());
        md5hash = md.digest();
        return convertToHex(md5hash);
    } 


}