package com.etn.eshop;

import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;


import java.util.Properties;
import java.util.Map;
import java.io.*;
import java.net.*;
import java.lang.reflect.Type;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;



class Sso
{

	private ClientSql Etn;
	private Properties env;

	public boolean debug = true; //set to false //debug

	public Sso(ClientSql etn, Properties conf) throws Exception
	{
       	this.Etn = etn;
		this.env = conf;
	}

	protected void systemLog(Object obj)
	{
		if(debug) System.out.println(obj);
	}

	private String parseNull(Object o)
	{
       	if( o == null ) return("");
       	String s = o.toString();
       	if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public int signup(int wkid, String clid)
	{
		if("1".equals(parseNull(env.get("POST_WORK_SPLIT_ITEMS"))))
		{
			HttpURLConnection c = null;
			int sid = 0;
			String catalogdb = env.get("CATALOG_DB") + ".";
			String ssodb = env.get("SSO_DB") + ".";
			String portaldb = env.get("PORTAL_DB") + ".";
			try
			{
				Set rs = Etn.execute("select a.app_id, a.signup_url, c.client_uuid, c.name, c.email from "+catalogdb+"products p, order_items oi, orders o, "+ssodb+"apps a, "+portaldb+"clients c where o.client_id = c.id and o.parent_uuid = oi.parent_id and p.app_id = a.app_id and oi.id = " + escape.cote(clid) + " and oi.product_ref = p.product_uuid ");
				if(rs.next())
				{
					if("0".equals(rs.value("is_sso_enabled")))
					{
						systemLog("SSO is not enabled for this app so we just return 0 and move to next phase");
						Etn.executeCmd("update post_work set errCode = 0, errMessage = "+escape.cote("SSO is not enabled for this app so we just return 0 and move to next phase")+" where id = " + wkid);
						((Scheduler)env.get("sched")).endJob( wkid , clid );
						return 0;
					}

					String ssoenv = "test";
					if("1".equals(env.get("IS_PROD_SHOP")))	ssoenv = "prod";

					sid = Etn.executeCmd("insert into "+ssodb+"logins (env, app_id, client_id, sso_id, is_active) values ("+escape.cote(ssoenv)+","+escape.cote(rs.value("app_id"))+","+escape.cote(rs.value("client_uuid"))+",UUID(),1) ");
					if(sid <= 0)
					{
						systemLog("Some error while inserting into sso logins");
						Etn.executeCmd("update post_work set errCode = '500', errMessage = "+escape.cote("Some error while inserting into sso logins")+" where id = " + wkid);
						return -1;
					}
					Set rssso = Etn.execute("select * from "+ssodb+"logins where id = " + escape.cote(""+sid));
					rssso.next();
					String ssoid = rssso.value("sso_id");

					String signupurl = parseNull(rs.value("signup_url"));

					String email = rs.value("email");
					if("test".equals(ssoenv)) email = "test_" + email; //we append test_ for test environment users otherwise in other app same user in test and prod could create conflict

					if(signupurl.contains("?")) signupurl = signupurl + "&";
					else signupurl = signupurl + "?";
					signupurl = signupurl + "name="+rs.value("name")+"&email="+email+"&ssoid="+ssoid;
					System.out.println("Signup URL " + signupurl );
					URL u = new URL(signupurl);
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
					System.out.println("Returned json " + jsonresponse);
					String ssouuid = "";
					Gson gson = new Gson();

					Type listType = new TypeToken<Map<String,String>>(){}.getType();
					Map<String,String> map = gson.fromJson(jsonresponse, listType);
					String ssomsg = "";
					if("success".equals(map.get("resp")))
					{
						Etn.executeCmd("update post_work set errCode = '0', errMessage = "+escape.cote("success")+" where id = " + wkid);
						((Scheduler)env.get("sched")).endJob( wkid , clid );
						return 0;
					}
					else
					{
						//some error occurred on the other end so we just delete the login created in sso
						if(sid > 0) Etn.executeCmd("delete from "+ssodb+"logins where id = " + sid);
						Etn.executeCmd("update post_work set errCode = '503', errMessage = "+escape.cote(map.get("msg"))+" where id = " + wkid);
						return -1;
					}
				}
				else
				{
					systemLog("No sso info found for order item");
					Etn.executeCmd("update post_work set errCode = '501', errMessage = "+escape.cote("No sso info found for order item")+" where id = " + wkid);
					return -1;
				}
			}//try
			catch(Exception e)
			{
				e.printStackTrace();

				if(sid > 0) Etn.executeCmd("delete from "+ssodb+"logins where id = " + sid);

				((Scheduler)env.get("sched")).retry( wkid , clid, 502, "Some exception occurred " );

				return -1;
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
		}
		else
		{
			System.out.println("WARNING::sso signup is only implemented for split order items");
			Etn.executeCmd("update post_work set errCode = '503', errMessage = "+escape.cote("WARNING::sso signup is only implemented for split order items")+" where id = " + wkid);
			return -1;
		}
	}

	public static void main(String a[]) throws Exception
	{

		System.out.println("### main start");
		Properties p = new Properties();
		p.load(Sso.class.getResourceAsStream("Scheduler.conf"));

        //System.out.println(p);

		com.etn.Client.Impl.ClientDedie etn = new com.etn.Client.Impl.ClientDedie("MySql","com.mysql.jdbc.Driver",p.getProperty("CONNECT"));



		Sso sc = new Sso(etn, p);
		System.out.println(sc.signup(1,"1"));

	       System.out.println("### main end");
       	System.exit(0);

	}

}