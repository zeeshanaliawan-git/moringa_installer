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
import java.text.SimpleDateFormat;
import java.lang.Process;
import com.etn.moringa.BreadCrumbs;


public class CacheAllContent
{
	private Properties env;
	private ClientSql Etn;
	private boolean isprod;
	private boolean debug;
	private CacheUtil cacheutil = null;

	private String internalcalllink;
	private String portalDb = "";
	private String catalogDb;
	private String formsDb;
	private String pagesDb;

	private String catalogWebappUrl;
	private String pagesWebappUrl;
	private String formsWebappUrl;
	private String webappurl;
	
	
	private void init(boolean isprod, boolean debug) throws Exception
	{
		this.debug = debug;		
//		log("in init");
		
		this.isprod = isprod;
		log("ISPROD::"+isprod);
		cacheutil = new CacheUtil(env, isprod, debug);	

		internalcalllink = parseNull(env.getProperty("INTERNAL_CALL_LINK"));
		catalogDb = env.getProperty("CATALOG_DB") + "."; 
		formsDb = env.getProperty("FORMS_DB") + ".";
		pagesDb = env.getProperty("PAGES_DB") + ".";

		catalogWebappUrl  = env.getProperty("CATALOG_WEBAPP_URL");
		pagesWebappUrl = env.getProperty("PAGES_WEBAPP_URL");
		formsWebappUrl = env.getProperty("FORMS_WEBAPP_URL");
		webappurl = parseNull(env.getProperty("EXTERNAL_LINK"));

		if(isprod) 
		{
			webappurl = parseNull(env.getProperty("PROD_EXTERNAL_LINK"));
			catalogDb = env.getProperty("PROD_CATALOG_DB") + ".";
			portalDb = env.getProperty("PROD_DB") + ".";
			catalogWebappUrl  = env.getProperty("PROD_CATALOG_WEBAPP_URL");
		}		
	}	

	public CacheAllContent(ClientSql Etn, Properties env, boolean isprod, boolean debug)  throws Exception
	{	
		this.Etn = Etn;
		this.env = env;
		init(isprod, debug);
	}

	private void log(String m)
	{
		if(!debug) return;		
		logE(m);
	}

	private void logE(String m)
	{
		if(isprod) m = "CacheAllContent::" + m;
		else m = "Preprod::CacheAllContent::" + m;
		System.out.println(m);
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public Map<String, String> cache(String menuid, Algolia algolia)
	{
		return cache(menuid, null, null, null, algolia);
	}
	
	/*
	* For individual item caching, we are not marking all cached_pages cached = 0 .. so in that case we must mark cached = 0 individually otherwise
	* process.jsp won't recache page and will return the previously cached page
	* In case of complete site being cached, then this flag is set by publish.java before calling the crawler
	*/
	private void resetCachedFlag(String menuid, String u) throws Exception
	{
		String encodedUrl = Base64.encode(u.getBytes("UTF-8"));
		String dbname = "";
		if(isprod) dbname = env.getProperty("PROD_DB") + ".";
		Etn.executeCmd("update "+dbname+"cached_pages set refresh_now = 0, cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where menu_id = "+escape.cote(menuid)+" and hex_eurl = hex(sha("+escape.cote(encodedUrl)+"))");
	}

	public String processTypePage(String menuid, String pageid, String pagepath, Map<String, String> resources, Map<String, String> extraUrls, List<String> allCachedPageIds, List<String> allCachedPageUrls, Algolia algolia, boolean resetCachedFlag)
	{
		String cachedPageId = "";
		try
		{
			log("processTypePage ID : "+pageid + " path : "+pagepath);
			log("Call regeneratepage.jsp so that latest page template is applied to previous content after which we will cache the page");
			String regenUrl = internalcalllink + pagesWebappUrl + "api/regeneratepage.jsp?pageid="+pageid;
			if(isprod) regenUrl += "&isprod=1";
			String regenStr = callUrl(regenUrl, menuid);
			log(regenStr);

			String ourl = internalcalllink + pagesWebappUrl + "pages/" + pagepath;
			//for Test site we must cache the generated pages and not the published pages otherwise user has to publish the page to even see in Test site which is wrong
			if(isprod == false)
			{
				ourl = internalcalllink + pagesWebappUrl + "admin/pages/" + pagepath;
			}
			log("calling page url "+ourl);
			if(resetCachedFlag) resetCachedFlag(menuid, ourl);
			String url = getProcessUrl(menuid, ourl);
			String content = callUrl(url, menuid);
			cachedPageId = processContent(url, content, resources, extraUrls, menuid, algolia);
			if(allCachedPageUrls != null) allCachedPageUrls.add(ourl);
			if(allCachedPageIds != null) allCachedPageIds.add(cachedPageId);
			Etn.executeCmd("update "+portalDb+"cached_pages_path set content_type = 'page', content_id = "+escape.cote(pageid)+" where id = " + escape.cote(cachedPageId));		
		}
		catch(Exception e)
		{
			logE("Error caching page ID : "+pageid);
			e.printStackTrace();
		}
		return cachedPageId;
	}

	public String processTypeCatalog(String menuid, String id, Map<String, String> resources, Map<String, String> extraUrls, List<String> allCachedPageIds, List<String> allCachedPageUrls, Algolia algolia, boolean resetCachedFlag)
	{
		String cachedPageId = "";
		try
		{
			log("processTypeCatalog ID : "+id);
			String ourl = internalcalllink + catalogWebappUrl + "listproducts.jsp?cat=" + id;
			if(resetCachedFlag) resetCachedFlag(menuid, ourl);
			String url = getProcessUrl(menuid, ourl);	
			String content = callUrl(url, menuid);
			cachedPageId = processContent(url, content, resources, extraUrls, menuid, algolia);
			if(allCachedPageUrls != null) allCachedPageUrls.add(ourl);
			if(allCachedPageIds != null) allCachedPageIds.add(cachedPageId);
			Etn.executeCmd("update "+portalDb+"cached_pages_path set content_type = 'catalog', content_id = "+escape.cote(id)+" where id = " + escape.cote(cachedPageId));
		}
		catch(Exception e)
		{
			logE("Error caching catalog ID : "+id);
			e.printStackTrace();
		}
		return cachedPageId;
	}

	public String processTypeProduct(String menuid, String id, Map<String, String> resources, Map<String, String> extraUrls, List<String> allCachedPageIds, List<String> allCachedPageUrls, Algolia algolia, boolean resetCachedFlag)
	{
		String cachedPageId = "";
		try
		{
			log("processTypeProduct ID : "+id);
			String ourl = internalcalllink + catalogWebappUrl + "product.jsp?id=" + id;
			if(resetCachedFlag) resetCachedFlag(menuid, ourl);
			String url = getProcessUrl(menuid, ourl);	
			String content = callUrl(url, menuid);
			cachedPageId = processContent(url, content, resources, extraUrls, menuid, algolia);
			if(allCachedPageUrls != null) allCachedPageUrls.add(ourl);
			if(allCachedPageIds != null) allCachedPageIds.add(cachedPageId);
			Etn.executeCmd("update "+portalDb+"cached_pages_path set content_type = 'product', content_id = "+escape.cote(id)+" where id = " + escape.cote(cachedPageId));
		}
		catch(Exception e)
		{
			logE("Error caching product ID : "+id);
			e.printStackTrace();
		}
		return cachedPageId;
	}

	public String processTypeForm(String menuid, String id, Map<String, String> resources, Map<String, String> extraUrls, List<String> allCachedPageIds, List<String> allCachedPageUrls, Algolia algolia, boolean resetCachedFlag)
	{
		String cachedPageId = "";
		try
		{
			log("processTypeForm ID : "+id);
			String ourl = internalcalllink + formsWebappUrl + "forms.jsp?form_id=" + id;
			if(resetCachedFlag) resetCachedFlag(menuid, ourl);
			String url = getProcessUrl(menuid, ourl);	
			String content = callUrl(url, menuid);
			//for forms we are passing null in algolia parameter because for forms we dont want to index those in case of forms 
			//they will mostly be added inside page not directly... in future versions we will remove auto caching of forms with assumption forms will be in pages
			cachedPageId = processContent(url, content, resources, extraUrls, menuid, null);
			if(allCachedPageUrls != null) allCachedPageUrls.add(ourl);
			if(allCachedPageIds != null) allCachedPageIds.add(cachedPageId);
			Etn.executeCmd("update "+portalDb+"cached_pages_path set content_type = 'form', content_id = "+escape.cote(id)+" where id = " + escape.cote(cachedPageId));
		}
		catch(Exception e)
		{
			logE("Error caching form ID : "+id);
			e.printStackTrace();
		}
		return cachedPageId;
	}

	//there might a case where lets say a page in pages module has a link to another app which is outside of asimina
	//and we want to cache that url as well. If that particular page is linked in the menu means it will be crawled and we are good
	//but if we use relative URLs which means even if that page is inside the site or menu it will not be called through process.jsp again and
	//any of external links in that page will not be cached. So here we will add all hrefs to extraUrls list so that crawler can check at the end
	//if any extra urls need to be crawled
	public Map<String, String> cache(String menuid, Map<String, String> extraUrls, List<String> allCachedPageIds, List<String> allCachedPageUrls, Algolia algolia)
	{
		//we will add all resources to be cached and return to Crawler.java so that it knows what resources need to be cached
		Map<String, String> resources = new HashMap<String, String>();

		try
		{
			int auditid = Etn.executeCmd("insert into "+portalDb+"crawler_audit (menu_id, start_time, status, action) values ("+escape.cote(menuid)+",now(),1, 'Caching all content') ");

			log("Start caching content for menuid : " + menuid);
			Set rs = Etn.execute("select * from "+portalDb+"site_menus where id = " + escape.cote(menuid));
			rs.next();
			String siteid = rs.value("site_id");
			String mlang = rs.value("lang");
			String mversion = rs.value("menu_version");
			
			log("Menu version is : "+ mversion);

			//get all pages
			log("Cache all pages");
			String qry = "select * from "+pagesDb+"pages where langue_code = "+escape.cote(mlang)+" and site_id = " + escape.cote(siteid);
			if(isprod) qry += " and publish_status = 'published' ";//for test site we just pick published pages
			//System.out.println(qry);
			rs = Etn.execute(qry);
			while(rs.next())
			{
				String path = rs.value("published_html_file_path");
				//for Test site we must cache the generated pages and not the published pages otherwise user has to publish the page to even see in Test site which is wrong
				if(isprod == false)
				{
					path = rs.value("html_file_path");
				}
				processTypePage(menuid, rs.value("id"), path, resources, extraUrls, allCachedPageIds, allCachedPageUrls, algolia, false);
			}
			
			log("Cache all listings");
			//get all commercial catalogs
			rs = Etn.execute("select id from "+catalogDb+"catalogs where site_id = " + escape.cote(siteid));
			while(rs.next())
			{
				processTypeCatalog(menuid, rs.value("id"), resources, extraUrls, allCachedPageIds, allCachedPageUrls, algolia, false);
			}

			log("Cache all product details");
			//get all products
			rs = Etn.execute("select p.id from "+catalogDb+"products p, "+catalogDb+"catalogs c where p.catalog_id = c.id and c.site_id = " + escape.cote(siteid));
			while(rs.next())
			{
				processTypeProduct(menuid, rs.value("id"), resources, extraUrls, allCachedPageIds, allCachedPageUrls, algolia, false);
			}

			//v2 menu is block system enabled so the forms must be added in pages and then used in website .. so we will not auto cache forms for v2 menus
			if("v1".equalsIgnoreCase(mversion))
			{
				log("Cache all forms");
				//get all forms
				rs = Etn.execute("select form_id from "+formsDb+"process_forms where site_id = " + escape.cote(siteid));
				while(rs.next())
				{
					processTypeForm(menuid, rs.value("form_id"), resources, extraUrls, allCachedPageIds, allCachedPageUrls, algolia, false);
				}		
			}

			Etn.executeCmd("update "+portalDb+"crawler_audit set end_time = now(), status = 2 where id = " + auditid); 
	
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+portalDb+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheAllContent::Error while caching content') ");
			e.printStackTrace();
		}
		return resources;
	}

	private String getProcessUrl(String menuid, String u) throws Exception
	{
		String url = internalcalllink + webappurl + "process.jsp?";
		//this flag is used for production publish to create cached files in separate folder ... this should not be passed to test site otherwise we have errors
		if(isprod) url += "___rf=1&";
		url += "___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(u.getBytes("UTF-8"));
		return url;
	}

	private String processContent(String url, String content, Map<String, String> resources, Map<String, String> extraUrls, String menuid, Algolia algolia)
	{		
		if(parseNull(content).length() == 0) return "0";

		String cachedPageId = "";		
		try
		{
			org.jsoup.nodes.Document doc = Jsoup.parse(content, url);
			
			org.jsoup.nodes.Element cele = doc.select("meta[name=pr:cid]").first();
			if(cele != null) cachedPageId = parseNull(cele.attr("content"));
			
			if(algolia != null && cachedPageId.length() > 0) algolia.setPageInfo(cachedPageId, doc);

			org.jsoup.select.Elements eles = doc.select("a[href]");
			for(org.jsoup.nodes.Element ele : eles)
			{			
				if(!cacheutil.isValidForCrawl(ele, menuid, internalcalllink, webappurl)) continue;
				
				String _r = ele.absUrl("href");			

				if(_r.startsWith(internalcalllink + webappurl + "process.jsp") && extraUrls != null) 
				{
					try
					{
						String actualUrl = (cacheutil.getActualUrl(_r)).toLowerCase();
						//check if the href is of any of asimina content which in case will be cached so ignore it
						if(actualUrl.startsWith((internalcalllink + pagesWebappUrl).toLowerCase()) || 
						   actualUrl.startsWith((internalcalllink + catalogWebappUrl).toLowerCase()) || 
						   actualUrl.startsWith((internalcalllink + formsWebappUrl).toLowerCase())) 
						{
							continue;
						}
						if(extraUrls.get(_r) == null && actualUrl.startsWith(internalcalllink)) 
						{
							log("Add extra : " + actualUrl + " for page id : " + cachedPageId);
							extraUrls.put(_r, cachedPageId);//cachedPageId is the parent of this extra url to create breadcrumb path
						}
					}
					catch(Exception e) 
					{ 
						Etn.executeCmd("insert into "+portalDb+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheAllContent::Error in processing content') ");
						e.printStackTrace(); 
					}
				}
			}

			eles = doc.select("link[href]");
			for(org.jsoup.nodes.Element ele : eles)
			{
				String _r = ele.attr("href");
				if(_r.toLowerCase().startsWith("javascript:")) continue;

				String _rel = parseNull(ele.attr("rel"));
				if(_rel.equalsIgnoreCase("canonical") || _rel.equalsIgnoreCase("shortlink")) continue;				

				_r = ele.absUrl("href");
				//some resource need to go through cache so we will crawl it to refresh its cache
				try
				{
					if(_r.startsWith(internalcalllink + webappurl + "process.jsp") && resources.get(cacheutil.getActualUrl(_r)) == null ) resources.put(cacheutil.getActualUrl(_r), _r);
				}
				catch(Exception e)
				{
					logE("Error while getting actual url from " + _r + " continue processing ");
					Etn.executeCmd("insert into "+portalDb+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheAllContent::Error in processing content') ");
					e.printStackTrace();
				}
			}

			eles = doc.select("script[src]");
			for(org.jsoup.nodes.Element ele : eles)
			{
				String _r = ele.absUrl("src");
				//some resource need to go through cache so we will crawl it to refresh its cache
				try
				{
					if(_r.startsWith(internalcalllink + webappurl + "process.jsp") && resources.get(cacheutil.getActualUrl(_r)) == null) resources.put(cacheutil.getActualUrl(_r), _r);
				}
				catch(Exception e)
				{
					logE("Error while getting actual url from " + _r + " continue processing ");
					Etn.executeCmd("insert into "+portalDb+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheAllContent::Error in processing content') ");
					e.printStackTrace();
				}
			}		
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+portalDb+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheAllContent::Error in processing content') ");
			e.printStackTrace();
		}
		return cachedPageId;
	}

	private String callUrl(String u, String menuid)
	{		
		HttpURLConnection con = null;
		try 
	       {	
			String userPassword = parseNull(env.getProperty("PREPROD_AUTH_USER")) + ":" + parseNull(env.getProperty("PREPROD_AUTH_PASSWD"));
			if(isprod) 
			{	
				userPassword = parseNull(env.getProperty("PROD_AUTH_USER")) + ":" + parseNull(env.getProperty("PROD_AUTH_PASSWD"));
			}

			String encoding = Base64.encode(userPassword.getBytes("UTF-8"));
		
			URL url = new URL(u);
			con = (HttpURLConnection)url.openConnection();
			con.setRequestProperty("Authorization", "Basic " + encoding);	
			con.setRequestProperty("User-Agent", "Mozilla/5.0");	

			int responseCode = con.getResponseCode();
			log(" resp code : " + responseCode + " : " + u);	
//			log(" content type " + con.getContentType());
//			log(" redirect url " + con.getURL());
//			log(" content type " + con.getContentType());
//			log(" location " + parseNull(con.getHeaderField("Location")));
//			log(" last modified date " + con.getLastModified());

			String contentType = con.getContentType();
			
			if (con.getResponseCode() == HttpURLConnection.HTTP_MOVED_PERM || con.getResponseCode() == HttpURLConnection.HTTP_MOVED_TEMP) 
			{
	       		String redirectUrl = con.getHeaderField("Location");
				return callUrl(redirectUrl, menuid);
			}
			else if(responseCode >= 300) 
			{
				return "";
			}
			if(!parseNull(contentType).contains("text/html"))
			{		
				return "";
			}

			String charset = cacheutil.getCharset(contentType);

			StringBuffer sbuffer = new StringBuffer();	
			BufferedReader reader = new BufferedReader(new InputStreamReader(con.getInputStream(), charset));
			String inputLine;
			while ((inputLine = reader.readLine()) != null) {
				sbuffer.append(inputLine + "\n");
			}
			reader.close();

			return sbuffer.toString();
		}
		catch(Exception e)
		{
			logE("Exception calling : " + u);
			Etn.executeCmd("insert into "+portalDb+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheAllContent::Error calling url') ");
			e.printStackTrace();
		}
		finally
		{
			if(con != null) con.disconnect();
		}
		return "";
	}

	public void updateCachedPagesUrl(String menuid)
	{
		updateCachedPagesUrl(menuid, null);
	}	
	
	public void updateCachedPagesUrl(String menuid, List<String> targetCachedPageIds) 
	{
		//this function will check if old and new url are different then it will add redirections for production site only
		//and then will update the published_url in cached_pages_path table

		log("In updateCachedPagesUrl");

		String currentMenuPath = cacheutil.getMenuPath(Etn, menuid);
		
		String inClause = "";
		if(targetCachedPageIds != null && targetCachedPageIds.size() > 0)
		{
			int i=0;
			for(String ii : targetCachedPageIds)
			{
				if(i++>0) inClause += ",";
				inClause += escape.cote(ii);
			}
		}
		
		//For pages, if webmaster changes the url of page, the encoded url to cache the page will change which means we have a new entry in cached pages
		//whereas the page itself is same. In such case as the cached page id changes we are not able to add redirection the way we add for catalogs/products/forms. 
		//For those the encoded url always remain same even if the webmaster changes the url of a catalog/product/form. But this is not the case for pages
		//so before deleting unwanted rows from cached_content table, we are going to pick all the pages cached id which were active last time but not active this time.	
		List<String> pagesCachedIds = new ArrayList<String>();
		String qry = "select c.id, cc.content_id from "+portalDb+"cached_content cc, "+portalDb+"cached_pages c where cc.content_type = 'page' and cc.cached_page_id = c.id and c.is_url_active = 0 and c.last_time_url_active = 1 and c.menu_id = "+ escape.cote(menuid);
		if(parseNull(inClause).length() > 0) qry += " and c.id in ("+inClause+") ";
		log("qry1:"+qry);
		Set rs = Etn.execute(qry);
		
		while(rs.next())
		{
			pagesCachedIds.add(rs.value("id")+":"+rs.value("content_id"));
		}
		
		//delete urls which are not active any more
		Etn.executeCmd("delete from "+portalDb+"cached_content where cached_page_id in (select cp.id from "+portalDb+"cached_pages cp where cp.menu_id = " + escape.cote(menuid) + " and cp.is_url_active = 0) ");
		
		//get all active urls and update their urls
		qry = "select c.*, cp.file_url, cp.published_url, cp.content_type as path_content_type, cp.content_id as path_content_id from "+portalDb+"cached_pages c, "+portalDb+"cached_pages_path cp where cp.id = c.id and c.menu_id = " + escape.cote(menuid) + " and c.is_url_active = 1 ";
		if(parseNull(inClause).length() > 0) qry += " and c.id in ("+inClause+") ";
		log("qry2:"+qry);		
		rs = Etn.execute(qry);
		while(rs.next())
		{
			String oldurl = parseNull(rs.value("published_url"));
			String newurl = "";
			boolean ishtml = false;

			if(parseNull(rs.value("filename")).length() > 0)
			{
				if(parseNull(rs.value("filename")).toLowerCase().endsWith(".html")) ishtml = true;
				newurl = parseNull(rs.value("file_url")) + parseNull(rs.value("filename"));
			}
			else if(parseNull(rs.value("res_file_extension")).length() > 0)
			{
				newurl = parseNull(rs.value("file_url")) + parseNull(rs.value("id")) + parseNull(rs.value("res_file_extension"));
			}

			//urls are different add redirections only for Prod site .... redirections are only required for .html files
			//ideally this case will only be for .html files as only for those the webmaster can change path or file name
			//but if the menu's public path is changed that means all urls including those of css/js will change but we dont want redirections for those
			if(isprod && ishtml && newurl.length() > 0 && oldurl.length() > 0 && !newurl.equals(oldurl))
			{
				log("Add redirection for " + oldurl + " to " + newurl);
				//check if there is any redirection for this oldurl one to one then remove it
				Etn.executeCmd("delete from "+portalDb+"redirects where old_url = "+escape.cote(oldurl)+" and one_to_one = 1 and menu_type = " + escape.cote(menuid));
				Etn.executeCmd("insert into "+portalDb+"redirects (old_url, new_url, one_to_one, menu_type) values ("+escape.cote(oldurl)+","+escape.cote(newurl)+",1,"+escape.cote(menuid)+") ");
			}
			
			Etn.executeCmd("update "+portalDb+"cached_pages_path set published_menu_path = "+escape.cote(currentMenuPath)+", published_url = " + escape.cote(newurl) + " where id = " + rs.value("id"));

			//insert/update it in cached_content if content_id is not empty
			if(parseNull(rs.value("path_content_id")).length() > 0)
			{
				Etn.executeCmd("insert into "+portalDb+"cached_content (cached_page_id, published_url, content_id, content_type, published_menu_path) values ("+escape.cote(rs.value("id"))+", "+escape.cote(newurl)+", "+escape.cote(rs.value("path_content_id"))+", "+escape.cote(rs.value("path_content_type"))+", "+escape.cote(currentMenuPath)+") " +
							" on duplicate key update published_url = "+escape.cote(newurl)+", content_id = "+escape.cote(rs.value("path_content_id"))+", content_type = "+escape.cote(rs.value("path_content_type"))+", published_menu_path = "+escape.cote(currentMenuPath));
			}
			
		}
		
		for(String pcid : pagesCachedIds)
		{
			String[] p = pcid.split(":");
			String _oldcachedpageid = parseNull(p[0]);
			String _pageid = parseNull(p[1]);
			
			rs = Etn.execute("select cc.* from "+portalDb+"cached_content cc, "+portalDb+"cached_pages c where c.id = cc.cached_page_id and cc.content_type = 'page' and cc.content_id = " + escape.cote(_pageid) + " and c.menu_id = " + escape.cote(menuid));
			if(rs.next())
			{
				String oldurl = "";
				String newurl = "";
				String _newcachedpageid = rs.value("cached_page_id");
				Set rs1 = Etn.execute("select * From "+portalDb+"cached_pages_path where id = " + escape.cote(_oldcachedpageid));
				if(rs1.next()) oldurl = rs1.value("published_url");
				rs1 = Etn.execute("select * From "+portalDb+"cached_pages_path where id = " + escape.cote(_newcachedpageid));
				if(rs1.next()) newurl = rs1.value("published_url");
				if(oldurl.length() > 0 && newurl.length() > 0 && !newurl.equals(oldurl))
				{
					log("Add redirection for pages " + oldurl + " to " + newurl);
					//check if there is any redirection for this oldurl one to one then remove it
					Etn.executeCmd("delete from "+portalDb+"redirects where old_url = "+escape.cote(oldurl)+" and one_to_one = 1 and menu_type = " + escape.cote(menuid));
					Etn.executeCmd("insert into "+portalDb+"redirects (old_url, new_url, one_to_one, menu_type) values ("+escape.cote(oldurl)+","+escape.cote(newurl)+",1,"+escape.cote(menuid)+") ");					
				}
			}			
		}
		
		//set content_id and content_type to null for pages which are no more active
		Etn.executeCmd("update "+portalDb+"cached_pages_path set content_id = null, content_type = null where id in (select cp.id from "+portalDb+"cached_pages cp where cp.menu_id = " + escape.cote(menuid) + " and cp.is_url_active = 0) ");
		

	}

	public static void main(String[] a) throws Exception
	{
//		CacheAllContent c = new CacheAllContent(false, true);
//		c.cache("14");
//		c.updateCachedPagesUrl("14");
	}

}