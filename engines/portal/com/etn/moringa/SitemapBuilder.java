package com.etn.moringa;

import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.util.Base64;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.List;
import java.util.Date;
import java.util.ArrayList;
import java.util.Properties;
import java.text.SimpleDateFormat;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.FileOutputStream;

import org.jsoup.*;
/**
* This class will generate the sitemap for the production sites
* This class should not be called for Test sites
*
*
*/

public class SitemapBuilder
{
	private Properties env;
	private ClientSql Etn;
	private boolean debug;

	private SimpleDateFormat dateformat = null;

	private CacheUtil cacheutil = null;
	private CacheCleanup cacheCleanup = null;

	private String internalcalllink;
	private String sitemapCallLink;
	private String webappurl;
	private String dbname = "";

	private String sitemappath;
			
	public SitemapBuilder(ClientSql Etn, Properties env, boolean debug) throws Exception
	{
		this.debug = debug;		
		log("in init");
		this.Etn = Etn;
		this.env = env;

		dateformat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

		cacheutil = new CacheUtil(env, true, debug);
		cacheCleanup = new CacheCleanup(Etn, env, true, debug);
		
		internalcalllink = parseNull(env.getProperty("INTERNAL_CALL_LINK"));
		sitemapCallLink = parseNull(env.getProperty("PROD_SITEMAP_CALL_LINK"));
		if(!sitemapCallLink.endsWith("/")) sitemapCallLink += "/";
		
		webappurl = parseNull(env.getProperty("PROD_EXTERNAL_LINK"));

		dbname = env.getProperty("PROD_DB") + ".";
		sitemappath = env.getProperty("PROD_SITEMAP_XML_PATH");
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
		logE(m);
	}

	private void logE(String m)
	{
		m = "Prod SitemapBuilder::" + m;
		System.out.println(m);
	}
	
	public void generate(String menuid) 
	{
		log("menuid : " + menuid);
		//fetch the domain for this menu and we will generate sitemap for that domain
		Set rs = Etn.execute("select s.* from "+dbname+"site_menus m, "+dbname+"sites s where s.id = m.site_id and m.id = "+escape.cote(menuid));
		if(rs.next())
		{
			String domain = parseNull(rs.value("domain"));
			if(domain.length() > 0)
			{
				int auditid = Etn.executeCmd("insert into "+dbname+"crawler_audit (menu_id, start_time, status, action) values ("+escape.cote(menuid)+",now(),1, "+escape.cote("Generating sitemap for " + domain)+") ");
				try
				{
					generateFor(domain);	
				}
				catch(Exception e)
				{
					Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'SitemapBuilder::Error generating sitemap') ");
					e.printStackTrace();
				}
				Etn.executeCmd("update "+dbname+"crawler_audit set end_time = now(), status = 2 where id = " + auditid); 
			}
			else logE("Domain is not defined for the menu : " + menuid + ". Cannot proceed with sitemap generation");
		}
		else logE("Menu id passed does not exists");
	}
	
	private void generateFor(String domain) throws Exception
	{
		log("Start generating xml for domain : " + domain);
		//fetch all sites and their menus for this domain
		
		Map<String, String> sitemapUrls = new LinkedHashMap<String, String>();
		String odomain = domain.toLowerCase();
		odomain = odomain.replace("http://","").replace("https://","");
		Set rs = Etn.execute("select * from "+dbname+"sites where domain = "+escape.cote("https://"+odomain)+" or domain = "+escape.cote("http://"+odomain));
		while(rs.next())
		{
			generateFor(rs.value("id"), domain , sitemapUrls);
		}
		
		String xml = "";
		
		if(sitemapUrls.get(domain) == null)
		{
			xml += "<url><loc>"+domain+"</loc></url>";
		}
				
		for(String surl : sitemapUrls.keySet())
		{
			xml += "<url><loc>"+surl.replace("\"","&quot;").replace("'","&apos;").replace("<","&lt;").replace(">","&gt;").replace("&","&amp;")+"</loc>";
			if(parseNull(sitemapUrls.get(surl)).length() > 0) xml += "<lastmod>"+parseNull(sitemapUrls.get(surl))+"</lastmod>";
			xml += "</url>";
		}
		
		FileOutputStream fout = null;

		try
		{
			if(parseNull(xml).length() > 0)
			{
				xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
						"<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd\">" 
						+ xml + "</urlset>";

				String sitemapfile = domain.toLowerCase();
				if(sitemapfile.endsWith("/")) sitemapfile = sitemapfile.substring(0, sitemapfile.length() - 1);
				if(sitemapfile.startsWith("http://")) sitemapfile = sitemapfile.substring(7);
				else if(sitemapfile.startsWith("https://")) sitemapfile = sitemapfile.substring(8);
				sitemapfile = sitemapfile.replace(".","-").replace("/","-");

				sitemapfile = sitemapfile + "-sitemap.xml";
				fout = new FileOutputStream (sitemappath + sitemapfile);

				fout.write(xml.getBytes("UTF-8"));
				fout.flush();					
			}
		}
		finally
		{
			if(fout != null) try { fout.close(); } catch (Exception e) {}
		}		
		
	}
	
	private void generateFor(String siteid, String domain, Map<String, String> sitemapUrls) throws Exception
	{		
		//fetch all active menus for the site
		Set rs = Etn.execute("select * from "+dbname+"site_menus where is_active = 1 and site_id = " + escape.cote(siteid));
		if(rs.rs.Rows == 0)
		{
			logE("No active menu found for site id " + siteid);
			return;
		}
		while(rs.next())
		{
			String menuid = parseNull(rs.value("id"));
			String menupath = cacheutil.getMenuPath(Etn, menuid);
			String logoUrl = parseNull(rs.value("logo_url"));
			log("Start generating xml for menuid : " + menuid + " siteid : " + siteid + " domain : " + domain);			
				
			String menucachedfolder = cacheutil.getMenuCacheFolder(Etn, menuid);
			log("Menu id : " + menuid + " Menu path : " + menupath + " Menu cached folder : " + menucachedfolder);

			List<String> processedUrls = new ArrayList<String>();
				
			String hp = parseNull(rs.value("published_home_url"));
			if(hp.length() > 0)//menu is published
			{
				hp = internalcalllink + hp;
				log("Menu id : " + rs.value("id") + " hp : " + hp);	
				SmUrl smUrl = callUrl(hp, menupath, menucachedfolder);
				processContent(smUrl, menuid, domain, menupath, menucachedfolder, processedUrls, true, logoUrl, sitemapUrls);
			}	

			//now check if any of cached content is not crawled for building sitemap we will explicity add that to sitemap
			//we will ignore forms as a form might be already used in some page
			Set rsc = Etn.execute(" select cc.*, date_format(cp.last_loaded_on, '%Y-%m-%d %H:%i:%s') as last_loaded_on from "+dbname+"cached_content cc, "+dbname+"cached_pages cp "+
								" where cc.content_type <> 'form' and cc.cached_page_id = cp.id and cp.menu_id = " + escape.cote(menuid));
			while(rsc.next())
			{
				String surl = domain + rsc.value("published_url");
				if(sitemapUrls.get(surl) == null)
				{
					log("URL : " + surl + " is not crawlable so adding in sitemap");
					sitemapUrls.put(surl, parseNull(rsc.value("last_loaded_on")).replace(" ","T") + "Z");
				}
			}
		}
	}
	private void processContent(SmUrl smUrl, String menuid, String domain, String menupath, String menucachedfolder, List<String> processedUrls, boolean isHomepage, Map<String, String> sitemapUrls)
	{
		processContent(smUrl, menuid, domain, menupath, menucachedfolder, processedUrls, isHomepage, "", sitemapUrls);
	}
	private void processContent(SmUrl smUrl, String menuid, String domain, String menupath, String menucachedfolder, List<String> processedUrls, boolean isHomepage, String logoUrl, Map<String, String> sitemapUrls)
	{
		if(smUrl == null || smUrl.content == null || smUrl.content.toString().length() == 0) return;

		if(!smUrl.processFurther) return;
				
		try
		{
			log("Processing page : " + smUrl.originalUrl);
			
			if(isHomepage)
			{				
				String _u = "";
				if(parseNull(logoUrl).length() > 0) _u = parseNull(logoUrl);
				else 
				{
					String surl = smUrl.originalUrl;
					surl = surl.replace(internalcalllink, "");
					surl = domain + surl;
					_u = surl;
				}
				if(sitemapUrls.get(_u) == null)
				{
					sitemapUrls.put(_u, parseNull(smUrl.lastModifiedDate));
				}
			}
			else
			{
				String surl = smUrl.originalUrl;
				surl = surl.replace(internalcalllink, "");
				surl = domain + surl;

				if(sitemapUrls.get(surl) == null)
				{
					sitemapUrls.put(surl, parseNull(smUrl.lastModifiedDate));
				}
			}
			
			processedUrls.add(smUrl.originalUrl);
			org.jsoup.nodes.Document doc = Jsoup.parse(smUrl.content.toString(), smUrl.calledUrl);

			org.jsoup.select.Elements eles = doc.select("a[href]");
			for(org.jsoup.nodes.Element ele : eles)
			{	
				if(!cacheutil.isValidForCrawl(ele, menuid, internalcalllink, webappurl)) continue;
								
				String _r = ele.absUrl("href");			
			
				if(!processedUrls.contains(_r))
				{
					SmUrl cSmUrl = callUrl(_r, menupath, menucachedfolder);
					processContent(cSmUrl, menuid, domain, menupath, menucachedfolder, processedUrls, false, sitemapUrls);					
				}
			}
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'SitemapBuilder::Error in processing content') ");
			e.printStackTrace();
		}
	}
	
	/**
	* This function is expecting relative url of cached site and will convert the url to local url
	*/
	private SmUrl callUrl(String u, String menupath, String menucachedfolder) throws Exception
	{		
		HttpURLConnection con = null;
		SmUrl smUrl = null;
		try 
	    {	
			if(u.startsWith(internalcalllink + webappurl + "process.jsp") || u.startsWith(webappurl + "process.jsp")) return null;//dont crawl process.jsp urls for sitemap
			
			String originalUrl = u;			
			
			u = u.replace(internalcalllink, "");//remvoe http://127.0.0.1 from the link
			if(u.startsWith(menupath)) u = u.substring(menupath.length());//remove menu path from link as that could be an alias not actual path for local server access
			u = internalcalllink + sitemapCallLink + menucachedfolder + u;

			String userPassword = parseNull(env.getProperty("PROD_AUTH_USER")) + ":" + parseNull(env.getProperty("PROD_AUTH_PASSWD"));		

			String encoding = Base64.encode(userPassword.getBytes("UTF-8"));
		
			URL url = new URL(u);
			con = (HttpURLConnection)url.openConnection();
			con.setRequestProperty("Authorization", "Basic " + encoding);	
			con.setRequestProperty("User-Agent", "Mozilla/5.0");	

			int responseCode = con.getResponseCode();
			log("Url called : " + u);
			log(" resp code : " + responseCode + " : " + u);	
//			log(" content type " + con.getContentType());
//			log(" redirect url " + con.getURL());
//			log(" content type " + con.getContentType());
//			log(" location " + parseNull(con.getHeaderField("Location")));
//			log(" last modified date " + con.getLastModified());

			String lastModifiedDate = "";
			if(con.getLastModified() > 0)
			{
				lastModifiedDate = dateformat.format(new Date(con.getLastModified())).replace(" ","T") + "Z";
			}
			smUrl = new SmUrl();
			smUrl.originalUrl = originalUrl;
			smUrl.calledUrl = u;
			smUrl.responseCode = responseCode;
			smUrl.lastModifiedDate = lastModifiedDate;

			String contentType = con.getContentType();
			
			if (con.getResponseCode() == HttpURLConnection.HTTP_MOVED_PERM || con.getResponseCode() == HttpURLConnection.HTTP_MOVED_TEMP) 
			{
	       		String redirectUrl = con.getHeaderField("Location");
				return callUrl(redirectUrl, menupath, menucachedfolder);
			}
			else if(responseCode >= 300) 
			{
				smUrl.processFurther = false;
				return smUrl;
			}
			if(!parseNull(contentType).contains("text/html"))
			{		
				smUrl.processFurther = true;
				return smUrl;
			}

			String charset = cacheutil.getCharset(contentType);

			StringBuffer sbuffer = new StringBuffer();	
			BufferedReader reader = new BufferedReader(new InputStreamReader(con.getInputStream(), charset));
			String inputLine;
			while ((inputLine = reader.readLine()) != null) {
				sbuffer.append(inputLine + "\n");
			}
			reader.close();

			smUrl.content = sbuffer;
		}
		catch(Exception e)
		{
			logE("Exception calling : " + u);
			throw e;
		}
		finally
		{
			if(con != null) con.disconnect();
		}
		return smUrl;
	}
	
	private class SmUrl
	{		
		String originalUrl;
		String calledUrl;
		int responseCode;
		String lastModifiedDate;
		StringBuffer content; 
		boolean processFurther = true;		
	}
	
	public static void main(String[] a) throws Exception
	{
		if(a==null || a.length == 0) 
		{
			System.out.println("usage:: java SitemapBuilder true/false");
			System.out.println("where true/false is debug on or off ");	
		}
		else
		{
			Properties env = new Properties();
			env.load( SitemapBuilder.class.getResourceAsStream("Crawler.conf") );
			
			ClientSql Etn = new ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );

			com.etn.moringa.Util.loadProperties(Etn, env);
			boolean isdebug = Boolean.parseBoolean(a[0]);
			SitemapBuilder sb = new SitemapBuilder(Etn, env, isdebug);
//			sb.generateAll();
		}
	}	
}