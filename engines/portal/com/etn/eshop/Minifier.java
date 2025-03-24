package com.etn.eshop;

import java.io.*;
import java.net.*;
import java.nio.file.*;

import java.security.*;
import java.security.cert.*;

import javax.net.ssl.*;
import java.util.*;

import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.net.*;
import com.etn.util.Base64;
import java.net.Authenticator;
import java.net.InetSocketAddress;
import java.net.PasswordAuthentication;
import java.net.Proxy;

/**
 * This class is responsible to minify all cached external js/css. The class will be called by cron every night.
 * It will only do this job for the production site and will ignore all js/css of our catalogs which are cached as we 
 * assume they will already be minified at time of deployment and we will keep it this way to save time as for big sites
 * cached js/css can increase. 
 */

public class Minifier 
{ 

	private Properties env;
	private ClientSql Etn;
	private boolean debug;
	private String cachedpageid = "";
	boolean writeFiles = false;

	private void init(boolean debug) throws Exception
	{
		System.out.println("Minifier::init");

   		env = new Properties();
		env.load( getClass().getResourceAsStream("Scheduler.conf") );
    
		Etn = new ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );

		com.etn.moringa.Util.loadProperties(Etn, env);
		
		this.debug = debug;	
	}

	public Minifier(boolean debug, boolean writeFiles, String cachedpageid) throws Exception
	{
		init(debug);
		this.writeFiles = writeFiles;
		this.cachedpageid = cachedpageid;
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	private void log(String m)
	{
		if(!debug) return;		
		m = "Minifier::" + m;
		System.out.println(m);
	}

	public void start() throws Exception
	{
		System.out.println("Minifier::--------- Minifier started : " + new Date());

		String dbname = env.getProperty("PROD_DB") + ".";
		String appprefix = env.getProperty("APP_PREFIX") ;

		String q = "select c.*, cp.file_path from "+dbname+"cached_pages c, "+dbname+"cached_pages_path cp where cp.id = c.id and c.cached = 1 and coalesce(res_file_extension,'') <> '' ";
		if(cachedpageid.length() > 0) q += " and c.id = " + escape.cote(cachedpageid);
		q += " order by c.menu_id, c.id  ";

		log(q);
		Set rs = Etn.execute(q);
		while(rs.next())
		{

			String api = "";
			//we are ignoring cached css/js from _prodcatalog as they are already minified
			if(rs.value("url").contains("/" + appprefix + "_catalog/") || rs.value("url").contains("/" + appprefix + "_prodcatalog/") || rs.value("url").contains("/menu_resources/")) continue;

			if(parseNull(rs.value("content_type")).toLowerCase().contains("javascript")) api = "https://www.toptal.com/developers/javascript-minifier/raw";
			else if(parseNull(rs.value("content_type")).toLowerCase().contains("css")) api = "https://www.toptal.com/developers/cssminifier/raw";
		
			if(api.length() > 0) 
			{
				String filepath = env.getProperty("PROD_CACHE_FOLDER") + rs.value("file_path") + "/" + rs.value("id") + rs.value("res_file_extension");
				log(filepath);
				log("api : "+ api);
				getMinifiedString(api, filepath);
			}
		}

		if(writeFiles && "1".equals(parseNull(env.getProperty("SYNC_SECOND_SERVER"))))
		{
			try
			{
				System.out.println("Need to sync cache to second server");
				String cmd = env.getProperty("SYNC_TRIGGER_SCRIPT");
				Process proc = Runtime.getRuntime().exec(cmd);
				int r = proc.waitFor();					
				log("result :" + r + " for " + cmd);						
			}
			catch(Exception e)
			{
				e.printStackTrace();
				log(e.getMessage());
			}
		}

		System.out.println("Minifier::--------- Minifier end : " + new Date());
	}

	public static void main( String a[] ) throws Exception
	{
		boolean writeFiles = false;
		boolean isdebug = true;
		String cachedpageid = "";
		if(a!=null && a.length > 0) 
		{
			isdebug = Boolean.parseBoolean(a[0]);
			if(a.length > 1) writeFiles = Boolean.parseBoolean(a[1]);
			if(a.length > 2) cachedpageid = a[2];
		}
		System.out.println("Minifier starting for isdebug : "+isdebug+", writeFiles : "+writeFiles+", cachedpageid : "+ cachedpageid);
		new Minifier(isdebug, writeFiles, cachedpageid).start();
	}

	public void getMinifiedString(String url, String filepath)
	{
		HttpsURLConnection c = null;

		try
		{
			byte[] bytes = Files.readAllBytes(Paths.get(filepath));

			StringBuilder data = new StringBuilder();
			data.append(URLEncoder.encode("input", "UTF-8"));
			data.append('=');
			data.append(URLEncoder.encode(new String(bytes), "UTF-8"));

			bytes = data.toString().getBytes("UTF-8");

			URL u = new URL(url);

			if(parseNull(env.getProperty("HTTP_PROXY_SERVER")).length() > 0)
			{			
				System.out.println("Use proxy to connect to internet");	
				Proxy proxy = null;
				if("1".equals(env.getProperty("HTTP_PROXY_AUTH")))
				{
					proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(env.getProperty("HTTP_PROXY_SERVER"), Integer.parseInt(env.getProperty("HTTP_PROXY_PORT"))));
					Authenticator authenticator = new Authenticator() {
						public PasswordAuthentication getPasswordAuthentication() {
							return (new PasswordAuthentication(env.getProperty("HTTP_PROXY_USER"), (env.getProperty("HTTP_PROXY_PASS")).toCharArray()));
						}
					};
					Authenticator.setDefault(authenticator);
				}
				else 
				{
					proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(env.getProperty("HTTP_PROXY_SERVER"), Integer.parseInt(env.getProperty("HTTP_PROXY_PORT"))));
				}
				c = (HttpsURLConnection) u.openConnection(proxy);
			}
			else
			{
				c = (HttpsURLConnection) u.openConnection();
			}
			c.setRequestMethod("POST");
			c.setRequestProperty("Content-length", ""+bytes.length);
			c.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			c.setRequestProperty("charset", "utf-8");
			c.setDoOutput(true);
			c.connect();

			try(OutputStream os = c.getOutputStream()) 
			{
			    os.write(bytes);
			}
	
			int status = c.getResponseCode();							

			log("http response : " + status);
	
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
					String str = sb.toString();
					if(str.startsWith("/* Error:") || str.startsWith("// Error :")) log("ERROR returned : " + str);
					else if(str.length() > 0) 
					{
						log("Success : " + filepath);
						if(writeFiles) Files.write(Paths.get(filepath), str.getBytes("UTF-8"));
					}
			}	
//			log("Returned json " + resp);
								
		}
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
	}
}


