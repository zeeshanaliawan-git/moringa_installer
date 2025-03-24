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
import java.security.SecureRandom;
import java.util.Random;
import java.util.Map;
import java.io.*;
import java.net.*;
import java.lang.reflect.Type;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;

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

	private String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
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

		String realM = GlobalParm.getParm("basic_auth_realm");

        if(Etn.getId() == 0)
        {
			String ssoauthid = request.getParameter("__authid");
			if(ssoauthid == null) ssoauthid = "";
			
			if(ssoauthid.length() > 0)//sso authentication
			{
				String ssoappid = "";
				Set rsconfig = Etn.execute("select * from config where code = 'sso_app_id' ");
				if(rsconfig.next()) ssoappid = rsconfig.value("val");

				String verifyurl = GlobalParm.getParm("SSO_APP_VERIFY_URL");
				if(verifyurl == null) verifyurl = "";
		
				if(verifyurl.length() == 0 || ssoappid.length() == 0)
				{
					System.out.println("PORTAL::Authentication::SSO not configured");
				}
				else
				{
					HttpURLConnection c = null;
					try
					{
						URL u = new URL(verifyurl + "?appid="+ssoappid+"&auth="+ssoauthid);
						c = (HttpURLConnection) u.openConnection();
						c.setRequestMethod("GET");
						c.setRequestProperty("Content-length", "0");
						c.setUseCaches(false);
						c.setAllowUserInteraction(false);
						c.connect();
						int status = c.getResponseCode();
						
						String jsonresponse = "";
	
						switch (status) 
						{
							case 200:
							case 201:
								BufferedReader br = new BufferedReader(new InputStreamReader(c.getInputStream()));
								StringBuilder sb = new StringBuilder();
								String line;
								while ((line = br.readLine()) != null) 
								{
									sb.append(line+"\n");
								}
								br.close();
								jsonresponse = sb.toString();
						}
//						System.out.println("Returned json " + jsonresponse);
						String ssouuid = "";
						Gson gson = new Gson();

						Type listType = new TypeToken<Map<String,String>>(){}.getType();
						Map<String,String> map = gson.fromJson(jsonresponse, listType);
						String ssomsg = "";
						if(map.get("resp").equals("success"))
						{
							ssouuid = map.get("sso_id");
							System.out.println(ssouuid);
						}
						else if(map.get("msg") != null)
						{
							ssomsg = map.get("msg");
							System.out.println("PORTAL::Authentication::SSO error::" + ssomsg);
						}
						
						if(ssouuid.length() > 0)
						{
							Set rs = Etn.execute("select * from login where sso_id = " +  escape.cote(ssouuid)  );
							if(rs.next())
							{
								Etn.setContexte(rs.value("name"),rs.value("pass"));
							}
							else
							{
								System.out.println("PORTAL::Authentication::Invalid sso id");
							}
						}	
					}//end try
					catch(Exception e) 
					{
						e.printStackTrace();
					}
					finally
					{
						if(c != null) 
						{
							try 
							{
								c.disconnect();
							}
							catch (Exception e) {}
						}	
					}
				}//end else
			}//end if ssoauthid
			else
			{
		
				String __n = null;
				String __p = null;
				String __auth = request.getHeader("Authorization");

				if(__auth == null )
				{
					response.setStatus(401);
					response.setHeader("Pragma","No-cache");
					response.setHeader("Cache-Control","no-cache");
					response.setHeader("Expires",new java.util.Date(System.currentTimeMillis()+60000).toString());
					response.setHeader("WWW-Authenticate","Basic realm=\""+realM+"\"");

					return;
				}

				StringTokenizer __st = new StringTokenizer(__auth);
				String mode = __st.nextToken();

				java.io.ByteArrayOutputStream __b = new java.io.ByteArrayOutputStream();
				com.etn.util.Decode64 __d = new com.etn.util.Decode64(__b,__st.nextToken());

				__st = new StringTokenizer(__b.toString(),":");

				if(__st.hasMoreElements() ) __n = parseNull(__st.nextToken());
				if(__st.hasMoreElements() ) __p = parseNull(__st.nextToken());
                
				if( __n.length() > 0 && __p.length() > 0 )
				{
					if( Etn.getId() == 0 );
					//GlobalParm.init(session.getServletContext().getInitParameter("etnconf")  );
					else Etn.close();
					
					String hashPass = "";
					Set _rsPass = Etn.execute("select sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(__p)+",':',puid),256) from login where name = "+escape.cote(__n));
					if(_rsPass.next())
					{					
						hashPass = parseNull(_rsPass.value(0));
					}
					if( __n.length() > 0 && hashPass.length() > 0 ) Etn.setContexte(__n, hashPass) ;
				}//end if( __n!= null && __p != null )
				else Etn.close();			
			}
		}//end if etn.getid == 0
		
        if(Etn.getId() > 0)//means logged in
        {        
			Set rs = Etn.execute("select pr.* from profilperson p, profil pr where pr.profil_id = p.profil_id and p.person_id = " + Etn.getId());
			boolean ok=false;
			if(rs.next())
			{
				if("PROD_SITE_ACCESS".equalsIgnoreCase(rs.value("profil"))) ok = true;
			}
			if(!ok)
			{
				System.out.println("Prod-site-access by invalid profil");
				Etn.close();
			}
		}	

        if( Etn.getId() == 0 )
        {
		response.setStatus(401);
		response.setHeader("Pragma","No-cache");
		response.setHeader("Cache-Control","no-cache");
		response.setHeader("Expires",new java.util.Date(System.currentTimeMillis()+60000).toString());
		response.setHeader("WWW-Authenticate","Basic realm=\""+realM+"\"");
		return;
        }
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