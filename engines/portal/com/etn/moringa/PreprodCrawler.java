package com.etn.moringa;

import java.io.*;
import java.net.*;

import java.security.*;
import java.security.cert.*;

import javax.net.ssl.*;
import java.util.*;

import com.etn.util.ItsDate;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.net.HttpURLConnection;
import java.net.URL;
import com.etn.util.Base64;
import org.jsoup.*;
import java.lang.Process;
import com.etn.moringa.BreadCrumbs;

public class PreprodCrawler
{ 
	boolean isprod = false;
	boolean debug = true;

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
	
	public void crawl(String menuid) throws Exception
	{
		if(parseNull(menuid).length() == 0)
		{
			System.out.println("ERROR::PreprodCrawler::Menu id passed is empty");
			return;
		}
		System.out.println("Preprod crawler menu id ::" + menuid);
				
		Properties env = new Properties();
		env.load( getClass().getResourceAsStream("Crawler.conf") );
		
		ClientSql Etn = new ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );

		com.etn.moringa.Util.loadProperties(Etn, env);
		
		String qry = " select m.*, s.name as sitename, s.domain as sitedomain from site_menus m, sites s where s.id = m.site_id ";
		qry += " and m.is_active = 1 and m.id = " + escape.cote(parseNull(menuid));
		
		Set mainrs = Etn.execute(qry);
		if(mainrs == null || mainrs.rs.Rows == 0) 
		{
			System.out.println("ERROR::No menu found for menuid : " + menuid);
			return;
		}		
		

		CacheUtil cacheUtil = new CacheUtil(env, isprod, debug);//isprod = false
		
		//we must mark these flags otherwise in test site old urls which are no more active are left there
		Etn.executeCmd("update cached_pages set refresh_now = 0, cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where menu_id =  " + escape.cote(menuid));
		
		CacheAllContent c = new CacheAllContent(Etn, env, isprod, debug);//isprod = false

		String menuCacheFolder = cacheUtil.getMenuCacheFolder(Etn, menuid);
		String menuPath = cacheUtil.getMenuPath(Etn, menuid);

		String sitedomain = parseNull(mainrs.value("sitedomain"));
		if(!sitedomain.endsWith("/")) sitedomain = sitedomain + "/";

		Algolia algolia = new Algolia(menuid, Etn, env, isprod, debug, menuPath, sitedomain);	//isprod = false		

		c.cache(menuid, algolia);
		c.updateCachedPagesUrl(menuid);
		
				
		Set rs = Etn.execute("Select * from site_menus where id = " + escape.cote(menuid));
		rs.next();
		
		String hpUrl = parseNull(rs.value("homepage_url"));
		if(hpUrl.startsWith("http://") || hpUrl.startsWith("https://"))
		{
			Set rs2 = Etn.execute("select cp.* from cached_pages c, cached_pages_path cp where c.id = cp.id and c.menu_id = " + escape.cote(menuid) + " and c.hex_eurl = hex(sha("+escape.cote(Base64.encode(hpUrl.getBytes("UTF-8")))+"))");
			if(rs2.next())
			{
				Etn.executeCmd("update site_menus set published_home_url = "+escape.cote(rs2.value("published_url"))+", published_hp_cached_id = "+escape.cote(rs2.value("id"))+" where id = " + escape.cote(menuid));
			}
		}
		else
		{
			Set rs2 = Etn.execute("select cp.* from cached_pages c, cached_pages_path cp where c.id = cp.id and c.menu_id = " + escape.cote(menuid) + " and cp.published_url ="+escape.cote(menuPath + hpUrl));
			if(rs2.next())
			{
				Etn.executeCmd("update site_menus set published_home_url = "+escape.cote(rs2.value("published_url"))+", published_hp_cached_id = "+escape.cote(rs2.value("id"))+" where id = " + escape.cote(menuid));
			}			
		}		

		String errUrl = parseNull(rs.value("404_url"));
		if(errUrl.startsWith("http://") || errUrl.startsWith("https://"))
		{
			Set rs2 = Etn.execute("select cp.* from cached_pages c, cached_pages_path cp where c.id = cp.id and c.menu_id = " + escape.cote(menuid) + " and c.hex_eurl = hex(sha("+escape.cote(Base64.encode(errUrl.getBytes("UTF-8")))+"))");
			if(rs2.next())
			{
				Etn.executeCmd("update site_menus set published_404_url = "+escape.cote(rs2.value("published_url"))+", published_404_cached_id = "+escape.cote(rs2.value("id"))+" where id = " + escape.cote(menuid));
			}
		}
		else
		{
			Set rs2 = Etn.execute("select cp.* from cached_pages c, cached_pages_path cp where c.id = cp.id and c.menu_id = " + escape.cote(menuid) + " and cp.published_url ="+escape.cote(menuPath + errUrl));
			if(rs2.next())
			{
				Etn.executeCmd("update site_menus set published_404_url = "+escape.cote(rs2.value("published_url"))+", published_404_cached_id = "+escape.cote(rs2.value("id"))+" where id = " + escape.cote(menuid));
			}			
		}		
		
		algolia.startIndexation();
	}	

	public static void main(String[] a)
	{		
		try
		{
			PreprodCrawler pc = new PreprodCrawler();
			pc.crawl(a[0]);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return;
	}
}
