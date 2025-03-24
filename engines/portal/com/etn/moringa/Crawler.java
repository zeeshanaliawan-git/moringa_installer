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
import com.etn.util.Base64;
import org.jsoup.*;
import java.lang.Process;
import com.etn.moringa.BreadCrumbs;

public class Crawler 
{ 
	private Properties env;
	private ClientSql Etn;
	private boolean isprod;
	private boolean debug;

	private Map<String, Integer> depthConstraints;

	private CacheUtil cacheutil = null;
	private CacheCleanup cacheCleanup = null;

	private String internalcalllink;
	private String webappurl;
	private String separatefoldercacheredirecturl;
	private String publishersitesfolder;
	private String redirecturl;
	private String dbname = "";
	private String basedir;
	private String publisherbasedir;
	private String cachefolder;
	private String publisherUrl;
	private Map<String, String> resources = null;
	private List<String> crossSiteAppsUrl = null;
	private String pagesWebappUrl;
	private String catalogWebappUrl;
	private String formsWebappUrl;
	private String pagesDb;
	
	private void init(ClientSql Etn, Properties env, boolean isprod, boolean debug) throws Exception
	{
		this.debug = debug;		
		log("in init");
		this.Etn = Etn;
		this.env = env;		
		this.isprod = isprod;

		depthConstraints = new HashMap<String, Integer>();
		if(parseNull(env.getProperty("DEPTH_CONSTRAINT")).length()  > 0)
		{
			String[] aa = parseNull(env.getProperty("DEPTH_CONSTRAINT")).split(";");
			if(aa != null)
			{
				for(String _a : aa) 
				{
					String[] bb = _a.split(",");	
					log(bb[0] + " - " + bb[1]);				
					depthConstraints.put(bb[1], Integer.parseInt(bb[0]));
				}
			}
		}

		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		cacheutil = new CacheUtil(env, isprod, debug);
		cacheCleanup = new CacheCleanup(Etn, env, isprod, debug);
		
		internalcalllink = parseNull(env.getProperty("INTERNAL_CALL_LINK"));
		webappurl = parseNull(env.getProperty("EXTERNAL_LINK"));
		separatefoldercacheredirecturl = parseNull(env.getProperty("SEPARATE_FOLDER_CACHE_REDIRECT_URL"));
		publishersitesfolder = parseNull(env.getProperty("PUBLISHER_DOWNLOAD_PAGES_FOLDER")) ;
		redirecturl = parseNull(env.getProperty("CACHE_REDIRECT_URL"));
		basedir = parseNull(env.getProperty("CACHE_FOLDER")) ;

		publisherbasedir = parseNull(env.getProperty("PUBLISHER_BASE_DIR")) ;
		cachefolder = parseNull(env.getProperty("DOWNLOAD_PAGES_FOLDER"));
		publisherUrl = env.getProperty("PUBLISHER_SEND_REDIRECT_LINK");	
		
		dbname = "";

		pagesWebappUrl = env.getProperty("PAGES_WEBAPP_URL");
		catalogWebappUrl  = env.getProperty("CATALOG_WEBAPP_URL");
		pagesDb = env.getProperty("PAGES_DB");
		
		if(isprod) 
		{
			webappurl = parseNull(env.getProperty("PROD_EXTERNAL_LINK"));
			publishersitesfolder = parseNull(env.getProperty("PUBLISHER_PROD_DOWNLOAD_PAGES_FOLDER")) ;
			separatefoldercacheredirecturl = parseNull(env.getProperty("PROD_SEPARATE_FOLDER_CACHE_REDIRECT_URL"));
			redirecturl = parseNull(env.getProperty("PROD_CACHE_REDIRECT_URL"));
			dbname = env.getProperty("PROD_DB") + ".";
			basedir = parseNull(env.getProperty("PROD_CACHE_FOLDER")) ;
			
			publisherbasedir = parseNull(env.getProperty("PUBLISHER_PROD_BASE_DIR")) ;			
			cachefolder = parseNull(env.getProperty("PROD_DOWNLOAD_PAGES_FOLDER"));
			publisherUrl = env.getProperty("PROD_PUBLISHER_SEND_REDIRECT_LINK");			
			
			catalogWebappUrl  = env.getProperty("PROD_CATALOG_WEBAPP_URL");
		}

		if(parseNull(env.getProperty("CROSS_SITE_APPS_URL")).length() > 0)
		{
			String[] ss = parseNull(env.getProperty("CROSS_SITE_APPS_URL")).split(";");
			if(ss != null)
			{
				crossSiteAppsUrl = new ArrayList<String>();
				for(String csa : ss) crossSiteAppsUrl.add(csa);
			}
		}
		
	}	

	public Crawler(ClientSql Etn, Properties env, boolean isprod, boolean debug) throws Exception
	{
		init(Etn, env, isprod, debug);
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
		if(isprod) m = "Prod Crawler::" + m;
		else m = "Preprod Crawler::" + m;
		System.out.println(m);
	}

	private boolean isCrossSiteAppUrl(String url)
	{
		if(crossSiteAppsUrl != null && crossSiteAppsUrl.size() > 0)
		{
			for(String s : crossSiteAppsUrl)
			{
				if(url.startsWith(internalcalllink + s)) return true;
			}
		}
		return false;	
	}
	
	private String getMenuId(String siteId, String lang, String langId)
	{
		if(isprod) return getProdSiteMenuId(siteId, lang, langId);
		return getTestSiteMenuId(siteId, lang, langId);
	}
	
    private String getProdPortalLink()
    {
        com.etn.lang.ResultSet.Set rs = Etn.execute("Select * from "+env.getProperty("PROD_DB")+".config where code = 'SEND_REDIRECT_LINK' ");
        rs.next();
        String v = parseNull(rs.value("val"));
        if(!v.endsWith("/")) v = v + "/";
        return v;
    }
	
	private String getTestSiteMenuId(String siteId, String lang, String langId)
	{		
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		Set rs = Etn.execute("Select * from site_menus where is_active = 1 and site_id = "+escape.cote(siteId)+" and lang = "+escape.cote(lang));
		if(rs.next())
		{
			return rs.value("id");
		}
		else
		{
			String productionPath = "";

			Set rsSd = Etn.execute("select sd.*, s.name as site_name from sites_details sd inner join sites s on s.id = sd.site_id where sd.site_id = "+escape.cote(siteId) + " and sd.langue_id = "+escape.cote(langId));
			if(rsSd.next())
			{
				productionPath = parseNull(rsSd.value("production_path"));
			}
			else
			{
				rsSd = Etn.execute("select name from sites where id = "+escape.cote(siteId));
				rsSd.next();
				productionPath = Util.getSiteFolderName(parseNull(rsSd.value("name"))) + "/"+ lang + "/";
				//System.out.println("---- productionPath:"+productionPath);
				Etn.executeCmd("insert into sites_details (site_id, langue_id, production_path) values ("+escape.cote(siteId)+", "+escape.cote(langId)+", "+escape.cote(productionPath)+")");
			}
			
			log("getTestSiteMenuId:No menu found");
			int i = Etn.executeCmd("insert into site_menus (site_id, name, created_by, is_active, lang, menu_uuid, version, production_path, menu_version) "+
				" values ("+escape.cote(siteId)+", "+escape.cote("Menu "+lang)+", 1, 1, "+escape.cote(lang)+", uuid(), 1, "+escape.cote(productionPath)+", 'V2') ");
			if(i > 0)
			{
				Etn.executeCmd("insert ignore into sites_apply_to (site_id, apply_type, apply_to, cache, add_gtm_script) values ("+escape.cote(siteId)+", 'url_starting_with', '127.0.0.1', 1, 1) ");
				return ""+i;					
			}				
		}
		return null;
	}
	
	private String getProdSiteMenuId(String siteId, String lang, String langId)
	{		
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		Set rs = Etn.execute("Select * from "+dbname+"site_menus where is_active = 1 and site_id = "+escape.cote(siteId)+" and lang = "+escape.cote(lang));
		if(rs.next())
		{
			return rs.value("id");
		}
		else
		{
			log("getProdSiteMenuId:No menu found");
			String testSiteMenuId = parseNull(getTestSiteMenuId(siteId, lang, langId));
			
			rs = Etn.execute("select * from sites where id = " + escape.cote(siteId));
			int rows = Util.insertUpdate(Etn, rs, "sites", env);
			
			rs = Etn.execute("Select * from site_menus where id = " + escape.cote(testSiteMenuId));
			rows += Util.insertUpdate(Etn, rs, "site_menus", env);

			rs = Etn.execute("Select * from sites_details where site_id = " + escape.cote(siteId) + " and langue_id = "+escape.cote(langId));
			rows += Util.insertUpdate(Etn, rs, "sites_details", env);

			rs = Etn.execute("select * from sites_apply_to where site_id = " + escape.cote(siteId));
			rows += Util.insertUpdate(Etn, rs, "sites_apply_to", env);

			rows += Util.publishShopParameters(Etn, siteId, env);
			rows += Util.publishStickers(Etn, siteId, env);
			rows += Util.publishAlgoliaSettings(Etn, siteId, langId, env);			

			rs = Etn.execute("Select * from "+dbname+"site_menus where site_id = "+escape.cote(siteId)+" and lang = "+escape.cote(lang));
			if(rs != null && rs.next())
			{
				return rs.value("id");
			}			
		}
		return null;
	}
	
	public boolean unpublishItem(String siteId, String contentType, String contentId)
	{
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		try
		{
			log("unpublishItem site ID : "+siteId+" ID : "+contentId + " type : "+contentType);
			
			if(contentType.equals("freemarker") || contentType.equals("structured"))
			{
				String qry = "select p.id, cc.cached_page_id as cached_page_id, m.id as menu_id from "+pagesDb+".pages p inner join "+dbname+"site_menus m on m.is_active = 1 and m.site_id = p.site_id and m.lang = p.langue_code "+
						" inner join "+dbname+"cached_pages cp on cp.menu_id = m.id "+
						" inner join "+dbname+"cached_content cc on cp.id = cc.cached_page_id and cc.content_type = 'page' and cc.content_id = p.id "+
						" where p.type = "+escape.cote(contentType)+" and p.parent_page_id ="+escape.cote(contentId);

				Set rs = Etn.execute(qry);
				log("pages rows : " + rs.rs.Rows);
				while(rs.next())
				{
					String currentMenuId = rs.value("menu_id");
					List<String> cachedPageIds = new ArrayList<>();
					String cachedPageId = rs.value("cached_page_id");
					cachedPageIds.add(cachedPageId);
					Etn.executeCmd("update "+dbname+"cached_pages set refresh_now = 0, cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where id = "+escape.cote(cachedPageId));
					cacheCleanup.start(currentMenuId, cachedPageIds);
					//pass last two parameters as empty as we are just deleting index from algolia so we do not need values for last two parameters
					Algolia algolia = new Algolia(currentMenuId, Etn, env, isprod, debug, "", "");
					algolia.deleteIndividualIndex(cachedPageId);
				}				
			}

			if(contentType.equals("catalog"))
			{
				String ourl = internalcalllink + catalogWebappUrl + "listproducts.jsp?cat=" + contentId;
				String qry = "select c.id as cached_page_id, m.id as menu_id from "+dbname+"cached_pages c inner join "+dbname+"site_menus m on c.menu_id = m.id and m.site_id = "+escape.cote(siteId)+" and m.is_active = 1 "+
							" where c.url = "+escape.cote(ourl);

				Set rs = Etn.execute(qry);
				log("catalog rows : " + rs.rs.Rows);
				while(rs.next())
				{
					String currentMenuId = rs.value("menu_id");
					List<String> cachedPageIds = new ArrayList<>();
					String cachedPageId = rs.value("cached_page_id");
					cachedPageIds.add(cachedPageId);
					Etn.executeCmd("update "+dbname+"cached_pages set refresh_now = 0, cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where id = "+escape.cote(cachedPageId));
					cacheCleanup.start(currentMenuId, cachedPageIds);
				}				
			}
						
			if(contentType.equals("product"))
			{
				String ourl = internalcalllink + catalogWebappUrl + "product.jsp?id=" + contentId;
				String qry = "select c.id as cached_page_id, m.id as menu_id from "+dbname+"cached_pages c inner join "+dbname+"site_menus m on c.menu_id = m.id and m.site_id = "+escape.cote(siteId)+" and m.is_active = 1 "+
							" where c.url = "+escape.cote(ourl);

				Set rs = Etn.execute(qry);
				log("products rows : " + rs.rs.Rows);
				while(rs.next())
				{
					String currentMenuId = rs.value("menu_id");
					List<String> cachedPageIds = new ArrayList<>();
					String cachedPageId = rs.value("cached_page_id");
					cachedPageIds.add(cachedPageId);
					Etn.executeCmd("update "+dbname+"cached_pages set refresh_now = 0, cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where id = "+escape.cote(cachedPageId));
					cacheCleanup.start(currentMenuId, cachedPageIds);
					//pass last two parameters as empty as we are just deleting index from algolia so we do not need values for last two parameters
					Algolia algolia = new Algolia(currentMenuId, Etn, env, isprod, debug, "", "");
					algolia.deleteIndividualIndex(cachedPageId);
				}				
			}
			else if(contentType.equals("form"))//forms are directly cached only for legacy menus not for block system so we unpublish for legacy menus only
			{
				String ourl = internalcalllink + formsWebappUrl + "forms.jsp?form_id=" + contentId;
				String qry = "select c.id as cached_page_id, m.id as menu_id from "+dbname+"cached_pages c inner join "+dbname+"site_menus m on c.menu_id = m.id and m.site_id = "+escape.cote(siteId)+" and m.is_active = 1 "+
							" where m.menu_version = 'v1' and c.url = "+escape.cote(ourl);

				Set rs = Etn.execute(qry);
				log("forms rows : " + rs.rs.Rows);
				while(rs.next())
				{
					String currentMenuId = rs.value("menu_id");
					List<String> cachedPageIds = new ArrayList<>();
					String cachedPageId = rs.value("cached_page_id");
					cachedPageIds.add(cachedPageId);
					Etn.executeCmd("update "+dbname+"cached_pages set refresh_now = 0, cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where id = "+escape.cote(cachedPageId));
					cacheCleanup.start(currentMenuId, cachedPageIds);
				}				
			}

			if("1".equals(parseNull(env.getProperty("SYNC_SECOND_SERVER"))))
			{
				Etn.executeCmd("update cache_tasks set status = 9 where site_id = "+escape.cote(siteId)+" and content_type = 'cachesync' and task = 'publish' and status = 0");
				Etn.executeCmd("insert into cache_tasks (site_id, content_type, content_id, task) values ("+escape.cote(siteId)+", 'cachesync', "+escape.cote(siteId)+", 'publish') ");
			}				

			return true;
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return false;
	}
	
	public boolean cacheItem(String siteId, String contentType, String contentId)
	{		
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		try
		{				
			boolean processFurther = false;
			BreadCrumbs br = null;
			NewUrlReplacer urlReplacer = null;
			Set rsLangs = Etn.execute("select l.* from "+env.getProperty("COMMONS_DB")+".sites_langs sl inner join language l on l.langue_id = sl.langue_id where sl.site_id = "+escape.cote(siteId));
			while(rsLangs.next())
			{
				log("Start cache Item : " + contentType + " ID : "+contentId + " site : "+siteId + " lang : "+ rsLangs.value("langue_code"));			
				String currentMenuId = getMenuId(siteId, rsLangs.value("langue_code"), rsLangs.value("langue_id"));
				if(parseNull(currentMenuId).length() == 0)
				{
					logE("Unable to find/create menu for site : "+siteId + " lang : "+ rsLangs.value("langue_code"));
					return false;
				}			
				
				String qry = " select m.*, s.name as sitename, s.domain as sitedomain from "+dbname+"site_menus m, "+dbname+"sites s where s.id = m.site_id ";
				qry += " and m.is_active = 1 and m.id = " + escape.cote(parseNull(currentMenuId));
				
				Set mainrs = Etn.execute(qry);
				if(mainrs == null || mainrs.rs.Rows == 0) 
				{
					logE("No active menu found for crawling menuid : " + currentMenuId);
					return false;
				}
				mainrs.next();				
			
				String mlang = mainrs.value("lang");
				String mversion = mainrs.value("menu_version");
			
				CacheAllContent cacheAllContent = new CacheAllContent(Etn, env, isprod, debug);

				String menuCacheFolder = cacheutil.getMenuCacheFolder(Etn, currentMenuId);
				String currentMenuPath = cacheutil.getMenuPath(Etn, currentMenuId);

				String sitedomain = parseNull(mainrs.value("sitedomain"));
				if(!sitedomain.endsWith("/")) sitedomain = sitedomain + "/";

				Algolia algolia = new Algolia(currentMenuId, Etn, env, isprod, debug, currentMenuPath, sitedomain);			

				List<PathNode> paths = new ArrayList<PathNode>();

				Map<String, String> pageIds = new HashMap<String, String>();
				Map<String, String> crawledUrls = new HashMap<String, String>();
				Map<String, Node> crawledNodes = new HashMap<String, Node>();

				//if we are publishing menu means we have to publish it in a separate folder 
				//so we clear that folder first and recreate it
				cacheutil.prepareForCache();

				List<String> cachedPageIds = new ArrayList<>();				

				Map<String, String> resources = new HashMap<String, String>();
				
				boolean indexAlgolia = false;
				if(contentType.equals("product"))
				{
					String cpid = cacheAllContent.processTypeProduct(currentMenuId, contentId, resources, null, null, null, algolia, true);
					if(parseNull(cpid).length() > 0) 
					{
						cachedPageIds.add(cpid);
						processFurther = true;
						indexAlgolia = true;
					}
				}
				else if(contentType.equals("catalog"))
				{
					String cpid = cacheAllContent.processTypeCatalog(currentMenuId, contentId, resources, null, null, null, algolia, true);
					if(parseNull(cpid).length() > 0) 
					{
						cachedPageIds.add(cpid);
						processFurther = true;
					}
				}
				else if(contentType.equals("freemarker"))
				{
					qry = "select * from "+env.getProperty("PAGES_DB")+".pages where parent_page_id = "+escape.cote(contentId)+" and type = "+escape.cote(contentType)+" and langue_code = "+escape.cote(mlang)+" and site_id = " + escape.cote(siteId);
					if(isprod) qry += " and publish_status = 'published' ";//for prod site we just pick published pages
					Set rsPages = Etn.execute(qry);
					if(rsPages.next())
					{
						String path = rsPages.value("published_html_file_path");
						//for Test site we must cache the generated pages and not the published pages otherwise user has to publish the page to even see in Test site which is wrong
						if(isprod == false)
						{
							path = rsPages.value("html_file_path");
						}					
						String cpid = cacheAllContent.processTypePage(currentMenuId, rsPages.value("id"), path, resources, null, null, null, algolia, true);
						if(parseNull(cpid).length() > 0) cachedPageIds.add(cpid);
					}
					if(cachedPageIds.size() > 0)
					{	
						processFurther = true;
						indexAlgolia = true;
					}
				}
				else if(contentType.equals("structured"))
				{
					qry = "select * from "+env.getProperty("PAGES_DB")+".pages where parent_page_id = "+escape.cote(contentId)+" and type = "+escape.cote(contentType)+" and langue_code = "+escape.cote(mlang)+" and site_id = " + escape.cote(siteId);
					if(isprod) qry += " and publish_status = 'published' ";//for prod site we just pick published pages
					Set rsPages = Etn.execute(qry);
					if(rsPages.next())
					{
						String path = rsPages.value("published_html_file_path");
						//for Test site we must cache the generated pages and not the published pages otherwise user has to publish the page to even see in Test site which is wrong
						if(isprod == false)
						{
							path = rsPages.value("html_file_path");
						}					
						String cpid = cacheAllContent.processTypePage(currentMenuId, rsPages.value("id"), path, resources, null, null, null, algolia, true);
						if(parseNull(cpid).length() > 0) cachedPageIds.add(cpid);
					}
					if(cachedPageIds.size() > 0)
					{
						processFurther = true;
						indexAlgolia = true;
					}
				}
				else if("v1".equalsIgnoreCase(mversion) && contentType.equals("form"))//forms are directly cached only for legacy menus not for block system
				{
					String cpid = cacheAllContent.processTypeForm(currentMenuId, contentId, resources, null, null, null, algolia, true);
					if(parseNull(cpid).length() > 0) cachedPageIds.add(cpid);
					processFurther = true;
				}
				
				if(processFurther)
				{
					if(resources != null && !resources.isEmpty())
					{
						for(String key : resources.keySet())
						{
							String rsc = resources.get(key);
							log("Need to recache resource : " + rsc);
							getFinalUrl(rsc, isprod, menuCacheFolder, currentMenuId);
						}
					}

					if(urlReplacer == null) urlReplacer = new NewUrlReplacer(Etn, env, isprod, debug);
					try 
					{
						log("going to call url replacer for menu id = " + parseNull(currentMenuId));						
						urlReplacer.start(parseNull(currentMenuId));
					}
					catch(Exception e)
					{
						Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(currentMenuId)+",'Crawler::Error replacing urls') ");
						e.printStackTrace();
					}

					if(br == null) br = new BreadCrumbs(Etn, env, debug, isprod, true);
					br.updateHtmls(currentMenuId, cachedPageIds);

					cacheutil.moveCache(Etn, dbname, currentMenuId);
					//call cleanup to remove pages in case some pages urls are changed by webmaster
					cacheCleanup.start(currentMenuId, cachedPageIds);
					//update the Published url in db and also add redirections
					cacheAllContent.updateCachedPagesUrl(currentMenuId, cachedPageIds);	

					if(indexAlgolia) algolia.startIndexation(cachedPageIds);
				}
			}
			
			if(isprod && processFurther)
			{
				//for production publish, we must recache all resources as a task so that its not repeated
				Etn.executeCmd("update cache_tasks set status = 9 where site_id = "+escape.cote(siteId)+" and content_type = 'resources' and task = 'publish' and status = 0");
				Etn.executeCmd("insert into cache_tasks (site_id, content_type, content_id, task) values ("+escape.cote(siteId)+", 'resources', "+escape.cote(siteId)+", 'publish') ");
				
				if("1".equals(parseNull(env.getProperty("SYNC_SECOND_SERVER"))))
				{
					Etn.executeCmd("update cache_tasks set status = 9 where site_id = "+escape.cote(siteId)+" and content_type = 'cachesync' and task = 'publish' and status = 0");
					Etn.executeCmd("insert into cache_tasks (site_id, content_type, content_id, task) values ("+escape.cote(siteId)+", 'cachesync', "+escape.cote(siteId)+", 'publish') ");
				}				
			}
			
			return true;
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean generateItem(String siteId, String contentType, String contentId)
	{		
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		try
		{				
			BreadCrumbs br = null;
			NewUrlReplacer urlReplacer = null;
			
			Set rsLangs = Etn.execute("select l.* from "+env.getProperty("COMMONS_DB")+".sites_langs sl inner join language l on l.langue_id = sl.langue_id where sl.site_id = "+escape.cote(siteId));
			while(rsLangs.next())
			{
				log("Start generate Item : " + contentType + " ID : "+contentId + " site : "+siteId + " lang : "+ rsLangs.value("langue_code"));			
				String currentMenuId = getTestSiteMenuId(siteId, rsLangs.value("langue_code"), rsLangs.value("langue_id"));
				if(parseNull(currentMenuId).length() == 0)
				{
					logE("Unable to find/create menu for site : "+siteId + " lang : "+ rsLangs.value("langue_code"));
					return false;
				}			
				
				String qry = " select m.*, s.name as sitename, s.domain as sitedomain from "+dbname+"site_menus m, "+dbname+"sites s where s.id = m.site_id ";
				qry += " and m.is_active = 1 and m.id = " + escape.cote(parseNull(currentMenuId));
				
				Set mainrs = Etn.execute(qry);
				if(mainrs == null || mainrs.rs.Rows == 0) 
				{
					logE("No active menu found for crawling menuid : " + currentMenuId);
					return false;
				}
				mainrs.next();				
			
				String mlang = mainrs.value("lang");
				String mversion = mainrs.value("menu_version");
			
				CacheAllContent cacheAllContent = new CacheAllContent(Etn, env, isprod, debug);

				String menuCacheFolder = cacheutil.getMenuCacheFolder(Etn, currentMenuId);
				String currentMenuPath = cacheutil.getMenuPath(Etn, currentMenuId);

				String sitedomain = parseNull(mainrs.value("sitedomain"));
				if(!sitedomain.endsWith("/")) sitedomain = sitedomain + "/";

				Algolia algolia = new Algolia(currentMenuId, Etn, env, isprod, debug, currentMenuPath, sitedomain);

				List<PathNode> paths = new ArrayList<PathNode>();

				Map<String, String> pageIds = new HashMap<String, String>();
				Map<String, String> crawledUrls = new HashMap<String, String>();
				Map<String, Node> crawledNodes = new HashMap<String, Node>();

				List<String> cachedPageIds = new ArrayList<>();				

				Map<String, String> resources = new HashMap<String, String>();
				
				boolean indexAlgolia = false;
				if(contentType.equals("product"))
				{
					String cpid = cacheAllContent.processTypeProduct(currentMenuId, contentId, resources, null, null, null, algolia, true);
					if(parseNull(cpid).length() > 0) 
					{
						cachedPageIds.add(cpid);
						indexAlgolia = true;
					}
				}
				else if(contentType.equals("catalog"))
				{
					String cpid = cacheAllContent.processTypeCatalog(currentMenuId, contentId, resources, null, null, null, algolia, true);
					if(parseNull(cpid).length() > 0) 
					{
						cachedPageIds.add(cpid);
					}
				}
				else if(contentType.equals("freemarker"))
				{
					qry = "select * from "+env.getProperty("PAGES_DB")+".pages where parent_page_id = "+escape.cote(contentId)+" and type = "+escape.cote(contentType)+" and langue_code = "+escape.cote(mlang)+" and site_id = " + escape.cote(siteId);
					if(isprod) qry += " and publish_status = 'published' ";//for prod site we just pick published pages
					Set rsPages = Etn.execute(qry);
					if(rsPages.next())
					{
						String path = rsPages.value("published_html_file_path");
						//for Test site we must cache the generated pages and not the published pages otherwise user has to publish the page to even see in Test site which is wrong
						if(isprod == false)
						{
							path = rsPages.value("html_file_path");
						}					
						String cpid = cacheAllContent.processTypePage(currentMenuId, rsPages.value("id"), path, resources, null, null, null, algolia, true);
						if(parseNull(cpid).length() > 0) cachedPageIds.add(cpid);
					}
					if(cachedPageIds.size() > 0)
					{
						indexAlgolia = true;
					}
				}
				else if(contentType.equals("structured"))
				{
					qry = "select * from "+env.getProperty("PAGES_DB")+".pages where parent_page_id = "+escape.cote(contentId)+" and type = "+escape.cote(contentType)+" and langue_code = "+escape.cote(mlang)+" and site_id = " + escape.cote(siteId);
					if(isprod) qry += " and publish_status = 'published' ";//for prod site we just pick published pages
					Set rsPages = Etn.execute(qry);
					if(rsPages.next())
					{
						String path = rsPages.value("published_html_file_path");
						//for Test site we must cache the generated pages and not the published pages otherwise user has to publish the page to even see in Test site which is wrong
						if(isprod == false)
						{
							path = rsPages.value("html_file_path");
						}					
						String cpid = cacheAllContent.processTypePage(currentMenuId, rsPages.value("id"), path, resources, null, null, null, algolia, true);
						if(parseNull(cpid).length() > 0) cachedPageIds.add(cpid);
					}
					if(cachedPageIds.size() > 0)
					{
						indexAlgolia = true;
					}
				}
				else if("v1".equalsIgnoreCase(mversion) && contentType.equals("form"))//forms are directly cached only for legacy menus not for block system
				{
					String cpid = cacheAllContent.processTypeForm(currentMenuId, contentId, resources, null, null, null, algolia, true);
					if(parseNull(cpid).length() > 0) cachedPageIds.add(cpid);
				}
				
				if(indexAlgolia) algolia.startIndexation(cachedPageIds);
			}
			
			
			return true;
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean syncResources(String siteId)
	{
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		try
		{
			cacheutil.syncLocalResources(Etn, dbname, siteId);
			return true;
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return false;
	}
	
	//Map must contain menu id as key and pages list
	public void crawlPages(Map<String, List<String>> menupages) throws Exception
	{
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		log("--------- Crawler Page Started : " + new Date());
		//we never had a case of same folder caching so just removing this code from v1.5 .. we always do separate folder caching
		
		for(String _mid : menupages.keySet())
		{	
			log("-------------------------------------------------------------------");
			log("CrawlPages starting for menu : " + _mid);
			cacheutil.prepareForCache();							
			
			String menuCacheFolder = cacheutil.getMenuCacheFolder(Etn, _mid);
			log("menuCacheFolder : " + menuCacheFolder);
			
			boolean replaceurls = false;
			List<String> cachedpageids = menupages.get(_mid);

			for(String cachedpageid : cachedpageids)
			{
				try
				{
					Set rs = Etn.execute("select c.*, cp.published_url, cp.published_menu_path, s.name as sitename from "+dbname+"cached_pages c, "+dbname+"cached_pages_path cp, "+dbname+"site_menus m, "+dbname+"sites s where cp.id = c.id and c.menu_id = m.id and m.site_id = s.id and c.id = " + escape.cote(cachedpageid));
					if(rs.next())
					{			
						String cachePageId = rs.value("id");
						String currentMenuId = parseNull(rs.value("menu_id"));
						log("Cache id : " + cachePageId + " menu id : " + currentMenuId);
						
						//we are going to confirm the webmaster has not changed the url of page
						//if that is changed and we recache that single page that will create a mess in cache
						//assumption of recaching a page only is that webmaster should not change the url
						if(!continueCaching(parseNull(rs.value("url")), parseNull(rs.value("published_url")), parseNull(rs.value("published_menu_path")), currentMenuId)) continue;
			
						//update row to cached = 0 so that its recached by process.jsp
						Etn.executeCmd("update "+dbname+"cached_pages set cached = 0 where id = " + cachePageId);							
		
						String url = internalcalllink + webappurl + "process.jsp?";
						url += "___mid=" + Base64.encode(currentMenuId.getBytes("UTF-8")) ; 
						url += "&___mu=" + Base64.encode(parseNull(rs.value("url")).getBytes("UTF-8"));
			
						MyUrl myurl = getFinalUrl(url, isprod, menuCacheFolder, currentMenuId);

//						if(!myurl.processFurther && (myurl.responseCode == 503 || myurl.responseCode == 502))
//						{
//							for(int _try=0; _try<2; _try++)
//							{
//								log("retry url : " + url);
//								myurl = getFinalUrl(url, isprod, menuCacheFolder, currentMenuId);
//								if(myurl.processFurther) break;
//							}
//						}

						//even after retries page is not responding
						if(!myurl.processFurther) 
						{
							//page was marked uncached by scheduler so if we are not able to recache it due to any reason we marked it cached so that next time scheduler runs it again tries to cache it
							Etn.executeCmd("update "+dbname+"cached_pages set cached = 1 where id = " + escape.cote(cachedpageid));
						}
						else
						{
							String contents = myurl.resp.toString().trim();
							org.jsoup.nodes.Document doc = Jsoup.parse(contents, url);
		
							//here we are going to check if any URL in page is new which is not previously crawled we just put # in place of that			
							org.jsoup.select.Elements eles = doc.select("a[href]");
							for(org.jsoup.nodes.Element ele : eles)
							{
								if(!cacheutil.isValidForCrawl(ele, _mid, internalcalllink, webappurl)) continue;
								
								String _r = ele.absUrl("href");
								log("Going to check for : " + _r);
								if(_r.startsWith(internalcalllink + webappurl + "process.jsp?")) 
								{
									String encodedUrl = getUrlParam(_r, "___mu");

									String decodedUrl = new String(Base64.decode(encodedUrl));
									log("encoded url : " + encodedUrl + " decoded url : " + decodedUrl);

									if(decodedUrl.startsWith("http://127.0.0.1/") || decodedUrl.startsWith("http://localhost/"))
									{
										Set checkpagers = Etn.execute("select * from "+dbname+"cached_pages where menu_id = "+escape.cote(currentMenuId)+" and hex_eurl = hex(sha("+escape.cote(encodedUrl)+ ")) ");
										if(checkpagers.rs.Rows == 0)//means this url is not crawled before so we just remove it from the page
										{
											ele.attr("href","#");
										}
									}
									else log("Seems external link so not going to remove it if not cached before");
								}	
							}

							//this will re-cache css resources
							eles = doc.select("link[href]");
							for(org.jsoup.nodes.Element ele : eles)
							{
								String _r = ele.attr("href");
								if(_r.toLowerCase().startsWith("javascript:")) continue;

								_r = ele.absUrl("href");
								//some resource need to go through cache so we will crawl it to refresh its cache
								if(_r.startsWith(internalcalllink + webappurl + "process.jsp")) getFinalUrl(_r, isprod, menuCacheFolder, currentMenuId);
							}

							//this will re-cache js resources
							eles = doc.select("script[src]");
							for(org.jsoup.nodes.Element ele : eles)
							{
								String _r = ele.absUrl("src");
								//some resource need to go through cache so we will crawl it to refresh its cache
								if(_r.startsWith(internalcalllink + webappurl + "process.jsp")) getFinalUrl(_r, isprod, menuCacheFolder, currentMenuId);
							}
		
					
							//write contents back to the disk
							String pagediskpath = publisherbasedir + publishersitesfolder;
							cachefolder = publishersitesfolder;							
				
							log("crawlPage:: cachefolder = " + cachefolder);
							log("crawlPage:: pagediskpath = " + pagediskpath);

							Set rsC = Etn.execute("select c.*, cp.file_path, cp.file_url, cp.published_url from "+dbname+"cached_pages c, "+dbname+"cached_pages_path cp where cp.id = c.id and c.id = " + escape.cote(cachePageId));
							rsC.next();

							//Dont add redirection here, dont remove old file if new path is changed and dont updated the published_url in db otherwise next time redirection will 
							//not be added. This cache is for selected pages to be refreshed after selected time interval and ideally for it the webmaster should not
							//change the url otherwise they have to publish whole menu so that the page linked in other pages the url should be updated as well
							String htmlfilename = rsC.value("filename");
							String htmlfilepath = rsC.value("file_path");//this is always relative to publish sites folder
		
							//save contents to the disk
							log("crawlPage:: htmlfilename = " + pagediskpath + htmlfilepath + htmlfilename );		
							saveFileToDisk(doc.outerHtml(), pagediskpath + htmlfilepath + htmlfilename, myurl.responseCharset, currentMenuId);

							replaceurls = true;

						}//end else 
					}//end if rs.next
				}
				catch(Exception e)
				{	
					Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(_mid)+",'Crawler::Error processing page') ");
					e.printStackTrace();
				}
			}//end for cachedpageids

			if(replaceurls)
			{
				log("Replace URLs for menu : " + _mid);
				NewUrlReplacer urlReplacer = new NewUrlReplacer(Etn, env, isprod, debug);
				try 
				{
					log("crawlPage::going to call url replacer for menu id = " + _mid);						
					urlReplacer.start(_mid);
				}
				catch(Exception e)
				{
					Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(_mid)+",'Crawler::Error replacing urls') ");
					e.printStackTrace();
				}
	
				if("1".equals(parseNull(env.getProperty("SYNC_SECOND_SERVER")))) 
				{
					String _copyfromfolder = publishersitesfolder;
					
					log("Going to sync the second server with auto refresh contents ");
					String cmd = env.getProperty("AUTO_REFRESH_SYNC_SCRIPT")  + " " + _copyfromfolder;
					log(cmd);
					Process proc = Runtime.getRuntime().exec(cmd);
					int r = proc.waitFor();					
					log("result :" + r + " for " + cmd);						
				}
				//if we are publishing menu means we have to publish it in a separate folder 
				//we move the final cached pages to actual location
				//when pages are being cached individually we are not going to copy the common resources
				cacheutil.moveCache(Etn, dbname, _mid);
			}
			
		}//end for String _mid  
		log("--------- Crawler Page Ended : " + new Date());
	}
	
	/*
	* This function will check if the webmaster has changed the url for the cached page. 
	* If changed we cannot continue to re-cache this page individually as that can create 
	* mess in cache and with the url of this page in other pages.
	* If no webmaster url is found we are safe to continue to recache as the cached page url wont change
	*/
	private boolean continueCaching(String u, String publishedUrl, String publishedMenuPath, String menuid)
	{
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		HttpURLConnection con = null;
		try
		{			
			//user adds simple urls which are later changed to process.jsp
			//in this function we are expecting simple urls 
			//in any case the incoming url is of process.jsp we are going to ignore it
			if(u.contains("/process.jsp"))
			{				
				logE("ERROR::Its a process.jsp url and that should not be recached automatically");
				return false;
			}
			if(!u.startsWith("http://127.0.0.1") && !u.startsWith("http://localhost"))
			{
				//for external pages we never have etn:eleurl in them so webmaster cannot change the url for cached page
				logE("not an internal url so can recache");
				return true;
			}
			if(u.startsWith("http://127.0.0.1/drupal/") || u.startsWith("http://127.0.0.1/drupal8/"))
			{
				//for drupal pages we never have etn:eleurl in them so webmaster cannot change the url for cached page
				logE("its a drupal url so can recache");
				return true;
			}

			URL url = new URL(u);
			con = (HttpURLConnection)url.openConnection();
			con.setRequestProperty("User-Agent", "Mozilla/5.0");		
			int responseCode = con.getResponseCode();
			log(" resp code : " + responseCode );	
//			log(" content type " + con.getContentType());
//			log(" redirect url " + con.getURL());
//			log(" content type " + con.getContentType());
//			log(" location " + parseNull(con.getHeaderField("Location")));
//			log(" last modified date " + con.getLastModified());

			//something went wrong and we cannot verify the webmaster url 
			if(responseCode >= 300) 
			{
				return false;			
			}
			String responseCharset = cacheutil.getCharset(parseNull(con.getContentType()));
			
			StringBuffer sb = new StringBuffer();	
			BufferedReader reader = new BufferedReader(new InputStreamReader(con.getInputStream(), responseCharset));
			String inputLine;
			while ((inputLine = reader.readLine()) != null) {
				sb.append(inputLine + "\n");
			}
			reader.close();
			
			org.jsoup.nodes.Document doc = Jsoup.parse(sb.toString(), u);
			
			org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleurl]");
			if(eles != null && eles.size() > 0)
			{						
				String webmasterUrl = parseNull(eles.first().attr("content")).toLowerCase();
				log("Old url : " + publishedUrl);
				log("New url : " + (publishedMenuPath + webmasterUrl));
				if(webmasterUrl.length() > 0 && (publishedMenuPath + webmasterUrl).equals(publishedUrl))//urls are same
				{
					log("old and new urls match so we can recache page safely");
					return true;
				}
			}				
			logE("Webmaster url is either changed or not available ... cannot proceed");
			return false;
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'Crawler::Error reading page contents') ");
			logE("Exception in continueCaching");
			e.printStackTrace();
			return false;
		}
		finally
		{
			if(con != null) con.disconnect();
		}
	}


	private void semfreePages()
	{
			Set rsPconfig = Etn.execute("Select * from "+env.getProperty("PAGES_DB")+".config where code = 'SEMAPHORE'");
			if(rsPconfig.next())
			{
					Etn.execute("select semfree("+escape.cote(rsPconfig.value("val"))+")");
					Etn.execute("select semfree("+escape.cote(rsPconfig.value("val"))+")");
			}
	}

	public void start(String currentMenuId) throws Exception
	{
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		log("--------- Crawler started : " + new Date());

		if(parseNull(currentMenuId).length() == 0)
		{
			logE("ERROR::Menu id not provided for crawling");
			return;
		}
			
		log("Isprod : " + isprod + " crawl menuid : " + currentMenuId);

		//change 05-nov-2019 ... new change where header and footer both can be empty
		String qry = " select m.*, s.name as sitename, s.domain as sitedomain from "+dbname+"site_menus m, "+dbname+"sites s where s.id = m.site_id ";
		qry += " and m.is_active = 1 and m.id = " + escape.cote(parseNull(currentMenuId));
		
		Set mainrs = Etn.execute(qry);
		if(mainrs == null || mainrs.rs.Rows == 0) 
		{
			logE("No active menu found for crawling menuid : " + currentMenuId);
			return;
		}
		mainrs.next();				
		
		//catch all exceptions in crawlurl or fileoutputstream and log it ... and then still call replaceurl
		try
		{							
			String mversion = mainrs.value("menu_version");
			boolean enablebreadcrumbs = "1".equals(parseNull(mainrs.value("enable_breadcrumbs")));
			
			//for v2 menus, we have another flag named generate_breadcrumbs in site parameters screen
			//if its disabled we will save time generating breadcrumbs .. generating breadcrumbs means generating all possible paths to a page
			if("v2".equalsIgnoreCase(mversion)) 
			{
				Set _rsG = Etn.execute("select * from "+dbname+"sites where id = "+escape.cote(mainrs.value("site_id")));
				if(_rsG.next())
				{
					enablebreadcrumbs = "1".equals(_rsG.value("generate_breadcrumbs"));
				}
			}
			log("mversion:"+mversion + " enable breadcrumbs:"+enablebreadcrumbs);
		
			CacheAllContent cacheAllContent = new CacheAllContent(Etn, env, isprod, debug);

			String menuCacheFolder = cacheutil.getMenuCacheFolder(Etn, currentMenuId);
			String currentMenuPath = cacheutil.getMenuPath(Etn, currentMenuId);

			String sitedomain = parseNull(mainrs.value("sitedomain"));
			String siteId = parseNull(mainrs.value("site_id"));
			if(!sitedomain.endsWith("/")) sitedomain = sitedomain + "/";

			Algolia algolia = new Algolia(currentMenuId, Etn, env, isprod, debug, currentMenuPath, sitedomain);			

			List<PathNode> paths = new ArrayList<PathNode>();

			Map<String, String> pageIds = new HashMap<String, String>();
			Map<String, String> crawledUrls = new HashMap<String, String>();
			Map<String, Node> crawledNodes = new HashMap<String, Node>();

			log("menu id : " + currentMenuId);
			
			int auditid = Etn.executeCmd("insert into "+dbname+"crawler_audit (menu_id, start_time, status, action) values ("+escape.cote(currentMenuId)+",now(),1, 'Crawling') ");

			//if we are publishing menu means we have to publish it in a separate folder 
			//so we clear that folder first and recreate it
			cacheutil.prepareForCache();							

			//cache all content for a menu here
			Map<String, String> extraUrlsToCrawl = new HashMap<String, String>();
			//this list will contain the page ids which are cached by CacheAllContent
			List<String> allCachedPageIds = new ArrayList<String>();
			List<String> allCachedPageUrls = new ArrayList<String>();
			resources = cacheAllContent.cache(currentMenuId, extraUrlsToCrawl, allCachedPageIds, allCachedPageUrls, algolia);
			if(resources == null) resources = new HashMap<String, String>();
		
			log("Going to crawl site : '" + parseNull(mainrs.value("sitename")) + "' and menu : '" + parseNull(mainrs.value("name")) + "'" );
			String homepageurl = parseNull(mainrs.value("homepage_url"));


			if(isprod) 
			{
				homepageurl = parseNull(mainrs.value("prod_homepage_url"));
			}

			String url = "";
			if(homepageurl.toLowerCase().startsWith("http:") == false && homepageurl.toLowerCase().startsWith("https:") == false)
			{
				url = separatefoldercacheredirecturl + menuCacheFolder + homepageurl;
			}
			else
			{
				url = internalcalllink + webappurl + "process.jsp?";
				url += "___mid=" + Base64.encode(parseNull(currentMenuId).getBytes("UTF-8"));
				url += "&___mu=" + Base64.encode(homepageurl.getBytes("UTF-8"));				
			}				
		
			Node hpNode = new Node();
			hpNode.url = url;
			hpNode.level = 0;
			hpNode.isHomepageLink = true;
			hpNode.pageType = "Homepage";
			MyUrl hpUrl = processUrl(currentMenuId, menuCacheFolder, hpNode, null, crawledNodes, crawledUrls, allCachedPageUrls);

			//crawl the 404 page for this menu
			String url404 = parseNull(mainrs.value("404_url"));
			if(isprod) url404 = parseNull(mainrs.value("prod_404_url"));

			MyUrl errorUrl = null;
			Node errorNode = new Node();
			errorNode.level = 1;
			errorNode.is404 = true;
			errorNode.pageType = "404";
			if(url404.length() > 0)
			{				
				log("Found the 404 url set as : " + url404);
				if(url404.toLowerCase().startsWith("http:") == false && url404.toLowerCase().startsWith("https:") == false)
				{
					url = separatefoldercacheredirecturl + menuCacheFolder + url404;
				}
				else
				{	
					url = internalcalllink + webappurl + "process.jsp?";
					url += "___mid=" + Base64.encode(currentMenuId.getBytes("UTF-8"));
					url += "&___mu=" + Base64.encode(url404.getBytes("UTF-8"));				
//					Etn.executeCmd("update "+dbname+"cached_pages set crawled_attempts = (coalesce(crawled_attempts,0) + 1), is_url_active = 1 where menu_id = "+escape.cote(currentMenuId)+" and hex_eurl = hex(sha("+escape.cote(Base64.encode(url404.getBytes("UTF-8")))+"))");
				}
				
				errorNode.url = url;					
				errorUrl = processUrl(currentMenuId, menuCacheFolder, errorNode, null, crawledNodes, crawledUrls, allCachedPageUrls);
			}
			else
			{
				String default404Url = internalcalllink + webappurl + "countryspecific/404.jsp";
				url = internalcalllink + webappurl + "process.jsp?";
				url += "___mid=" + Base64.encode(currentMenuId.getBytes("UTF-8"));
				url += "&___mu=" + Base64.encode(default404Url.getBytes("UTF-8"));

				errorNode.url = url;
				errorUrl = processUrl(currentMenuId, menuCacheFolder, errorNode, null, crawledNodes, crawledUrls, allCachedPageUrls);
				
//				Etn.executeCmd("update "+dbname+"cached_pages set crawled_attempts = (coalesce(crawled_attempts,0) + 1), is_url_active = 1 where menu_id = "+escape.cote(currentMenuId)+" and hex_eurl = hex(sha("+escape.cote(Base64.encode(default404Url.getBytes("UTF-8")))+"))");
			}

			//crawl the user profil homepages
			Set rsUserHomepages = Etn.execute("select * from "+dbname+"client_profils where menu_id = " + escape.cote(currentMenuId));
			while(rsUserHomepages.next())
			{
				String userHPUrl = parseNull(rsUserHomepages.value("homepage"));
				if(userHPUrl.length() == 0) continue;

				log("Found profil defined homepage for menu : " + userHPUrl);
				url = internalcalllink + webappurl + "process.jsp?";
				url += "___mid=" + Base64.encode(parseNull(currentMenuId).getBytes("UTF-8"));
				url += "&___mu=" + Base64.encode(userHPUrl.getBytes("UTF-8"));				

				Node userHpNode = new Node();
				userHpNode.url = url;
				userHpNode.level = 1;
				userHpNode.isUserHomepage = true;
				userHpNode.pageType = "Homepage";
				processUrl(currentMenuId, menuCacheFolder, userHpNode, null, crawledNodes, crawledUrls, allCachedPageUrls);
									
				Etn.executeCmd("update "+dbname+"cached_pages set crawled_attempts = (coalesce(crawled_attempts,0) + 1), is_url_active = 1 where menu_id = "+escape.cote(currentMenuId)+" and hex_eurl = hex(sha("+escape.cote(Base64.encode(userHPUrl.getBytes("UTF-8")))+"))");
			}
			
			if(extraUrlsToCrawl.size() > 0)
			{
				log("Number of extra urls : " + extraUrlsToCrawl.size());
				for(String _r : extraUrlsToCrawl.keySet())
				{
					String parentPageId = extraUrlsToCrawl.get(_r);
					//extra url was not crawled during the site crawling so we should crawl it
					if(crawledUrls.get(_r) == null)
					{
						log("Crawl extra url : " + cacheutil.getActualUrl(_r));
						
						Node extraNode = new Node();
						extraNode.url = _r;
						extraNode.level = 1;
												
						MyUrl exUrl = processUrl(currentMenuId, menuCacheFolder, extraNode, null, crawledNodes, crawledUrls, allCachedPageUrls);
						//for extra urls which were not not reachable anywhere in the website, we will check if its parent node is crawled in the website
						//we will add the path .. chances are its parent was also not crawled in the website so we are going to add the path still
						Node exNode = crawledNodes.get(parseNull(exUrl.cachedPageId));
						if(exNode != null && (exNode.paths == null || exNode.paths.size() == 0))//there was no path added to it while crawling
						{
							if(exNode.paths == null) exNode.paths = new HashMap<String, PathNode>();
							Node parentNode = crawledNodes.get(parentPageId);
							if(parentNode == null)//case where parent node was also not reachable in the site .. in this case extra url is at level 2
							{
								exNode.paths.put(parentPageId, new PathNode(parentPageId, 2, true));
							}
							else if(parentNode != null)
							{
								exNode.paths.put(parentPageId, new PathNode(parentPageId, parentNode.level + 1, true));
							}
						}
					}
				}
			}

			if(resources != null && !resources.isEmpty())
			{
				for(String key : resources.keySet())
				{
					String rsc = resources.get(key);
					log("Need to recache resource : " + rsc);
					getFinalUrl(rsc, isprod, menuCacheFolder, currentMenuId);
				}
			}

			Etn.executeCmd("update "+dbname+"crawler_audit set end_time = now(), status = 2 where id = " + auditid); 

			NewUrlReplacer urlReplacer = new NewUrlReplacer(Etn, env, isprod, debug);
			try 
			{
				log("going to call url replacer for menu id = " + parseNull(currentMenuId));						
				urlReplacer.start(parseNull(currentMenuId));
			}
			catch(Exception e)
			{
				Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(currentMenuId)+",'Crawler::Error replacing urls') ");
				e.printStackTrace();
			}

			if(crawledNodes != null && crawledNodes.size() > 0)
			{
				auditid = Etn.executeCmd("insert into "+dbname+"crawler_audit (menu_id, start_time, status, action) values ("+escape.cote(currentMenuId)+",now(),1, 'Updating paths') ");
				
				//here we going to check if the page ids returned by CacheAllContent were not crawled during actually crawling
				//means they are missing from crawledNodes and won't be added to crawler_paths table. So we explicity add those nodes 
				//with their parent set as homepage. If we don't set these nodes some pages crawled through extraUrlsToCrawl will fail creating breadcrumbs
				for(String cpid : allCachedPageIds)
				{
					if(crawledNodes.get(cpid) == null)
					{
						Node cnode = new Node();
						cnode.pageId = cpid;
						cnode.level = 1;
						cnode.is404 = false;
						cnode.isHomepageLink = false;
						cnode.isMenuLink = false;
						cnode.isUserHomepage = false;
						cnode.paths = new HashMap<String, PathNode>();
						cnode.paths.put(hpNode.pageId, new PathNode(hpNode.pageId, 1, true));
						crawledNodes.put(cpid, cnode);
					}
				}
				
				log("going to update crawler_paths");					
				Etn.executeCmd("delete from "+dbname+"crawler_paths where menu_id = " + escape.cote(currentMenuId));
				for(String cpageid : crawledNodes.keySet())
				{
					Node node = crawledNodes.get(cpageid);
					Etn.executeCmd("update "+dbname+"cached_pages set pagetype = "+escape.cote(parseNull(node.pageType))+", sub_level_1 = "+escape.cote(parseNull(node.subLevel1))+", sub_level_2 = "+escape.cote(parseNull(node.subLevel2))+" where id = " + escape.cote(cpageid));

					if(node.isHomepageLink)
					{
						Etn.executeCmd("insert ignore into "+dbname+"crawler_paths (menu_id, parent_page_id, page_id, is_menu_link, is_homepage_link, is_404, page_level, react_page_id, is_user_homepage) " + 
								" values ("+escape.cote(currentMenuId)+",'0',"+escape.cote(cpageid)+",0,1,0,0,"+escape.cote(""+node.reactPageId)+",0) ");
						continue;
					}							
					if(node.is404)
					{								
						Etn.executeCmd("insert ignore into "+dbname+"crawler_paths (menu_id, parent_page_id, page_id, is_menu_link, is_homepage_link, is_404, page_level, react_page_id, is_user_homepage) " + 
								" values ("+escape.cote(currentMenuId)+",'0',"+escape.cote(cpageid)+",0,0,1,"+escape.cote(""+node.level)+","+escape.cote(""+node.reactPageId)+",0) ");
						continue;
					}
					if(node.isUserHomepage)
					{
						Etn.executeCmd("insert ignore into "+dbname+"crawler_paths (menu_id, parent_page_id, page_id, is_menu_link, is_homepage_link, is_404, page_level, react_page_id, is_user_homepage) " + 
								" values ("+escape.cote(currentMenuId)+",'0',"+escape.cote(cpageid)+",0,0,0,"+escape.cote(""+node.level)+","+escape.cote(""+node.reactPageId)+",1) ");
						continue;
					}
					
					if(node.paths == null) continue;
					
					for(String ppid : node.paths.keySet())
					{
						PathNode _pn = node.paths.get(ppid);
						//there be a case when the page has its own link inside the content .. its rare but if it occurs we ignore that path or it creates cyclic path
						if(ppid.equals(cpageid)) continue;

						Etn.executeCmd("insert ignore into "+dbname+"crawler_paths (menu_id, parent_page_id, page_id, is_menu_link, is_homepage_link, is_404, page_level, react_page_id, is_user_homepage, is_page_link) " + 
									" values ("+escape.cote(currentMenuId)+","+escape.cote(ppid)+","+escape.cote(cpageid)+","+escape.cote(""+node.getIsMenuLink())+",0,0,"+escape.cote(""+_pn.level)+","+escape.cote(""+node.reactPageId)+",0, "+escape.cote(""+_pn.getIsPageLink())+") ");
					}
				}
				Etn.executeCmd("update "+dbname+"crawler_audit set end_time = now(), status = 2 where id = " + auditid); 
			}

			BreadCrumbs br = new BreadCrumbs(Etn, env, debug, isprod, true);
			if(enablebreadcrumbs) br.generate(currentMenuId);
			//this also updated datalayer so we do call this function even if breadcrumbs are not enabled				
			br.updateHtmls(currentMenuId);

			auditid = Etn.executeCmd("insert into "+dbname+"crawler_audit (menu_id, start_time, status, action) values ("+escape.cote(currentMenuId)+",now(),1, 'Updating cache') ");

			//if we are publishing menu means we have to publish it in a separate folder 
			//we move the final cached pages to actual location
			//copy all local resources to site cache folder
			cacheutil.copyLocalResources(Etn, dbname, siteId);
			cacheutil.moveCache(Etn, dbname, currentMenuId);

			//update the URLs in db as we have already moved the cache to actual cache folder
			String publishedHpUrl = "";
			String published404Url = "";
			String publishedHpCachedPageId = "";
			String published404CachedPageId = "";

			if(hpUrl != null) 
			{
				publishedHpUrl = parseNull(hpUrl.url);
				publishedHpCachedPageId = parseNull(hpUrl.cachedPageId);
				if(publishedHpUrl.startsWith(internalcalllink + publisherUrl)) publishedHpUrl = publishedHpUrl.replace(internalcalllink + publisherUrl + menuCacheFolder, currentMenuPath);
			}
			if(errorUrl != null) 
			{
				published404Url = parseNull(errorUrl.url);
				published404CachedPageId = parseNull(errorUrl.cachedPageId);
				if(published404Url.startsWith(internalcalllink + publisherUrl)) published404Url = published404Url.replace(internalcalllink + publisherUrl + menuCacheFolder, currentMenuPath);
			}
			Etn.executeCmd("update "+dbname+"site_menus set published_404_cached_id = "+escape.cote(published404CachedPageId)+", published_hp_cached_id = "+escape.cote(publishedHpCachedPageId)+", published_home_url = "+escape.cote(publishedHpUrl)+", published_404_url = "+escape.cote(published404Url)+" where id = " +escape.cote(currentMenuId));

			//once the publishing of menu is complete and cache is moved from temp folder to actual folder
			//We check which urls were active last time and no more active so we remove those .html files
			//also check if webmaster has changed a cached url so we have to remove the old page as well
			log("Going to remove unused pages");								
			cacheCleanup.start(currentMenuId);

			//update the Published url in db and also add redirections
			cacheAllContent.updateCachedPagesUrl(currentMenuId);

			Etn.executeCmd("update "+dbname+"crawler_audit set end_time = now(), status = 2 where id = " + auditid); 
			
			SitemapBuilder stBuilder = new SitemapBuilder(Etn, env, debug);
			stBuilder.generate(currentMenuId);	

			if("1".equals(parseNull(env.getProperty("SYNC_SECOND_SERVER"))))
			{
				try
				{
					String cmd = env.getProperty("SYNC_TRIGGER_SCRIPT");
					Process proc = Runtime.getRuntime().exec(cmd);
					int r = proc.waitFor();					
					log("result :" + r + " for " + cmd);						
				}
				catch(Exception e)
				{
					Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(currentMenuId)+",'Crawler::Error syncing second server') ");
					e.printStackTrace();
				}
			}
			
			algolia.startIndexation();
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(currentMenuId)+",'Crawler::Error crawling site') ");
			e.printStackTrace();			
		}

		log("--------- Crawler end : " + new Date());
	}

	private int getDepthLevel(String url)
	{
		for(String a : depthConstraints.keySet())
		{
			if(url.toLowerCase().startsWith(a)) return depthConstraints.get(a);
		}
		return -1;
	}

	private String getUrlParam(String u, String param) throws Exception
	{
		if(u.indexOf("?") < 0) return u;
		Map<String, String> queryParams = new LinkedHashMap<String, String>();
		URL url = new URL(u);
		String query = url.getQuery();
		String[] pairs = query.split("&");		
		for (String pair : pairs) 
		{
			int idx = pair.indexOf("=");
			queryParams.put(URLDecoder.decode(pair.substring(0, idx), "UTF-8"), URLDecoder.decode(pair.substring(idx + 1), "UTF-8"));
		}

		if(queryParams.get(param) == null) return "";		
		return parseNull(queryParams.get(param));
	}

	private MyUrl getFinalUrl(String u, boolean isprod, String menuCacheFolder, String menuid) throws Exception
	{		
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		HttpURLConnection con = null;
		MyUrl myurl = null;
		try 
		{	
			String userPassword = parseNull(env.getProperty("PREPROD_AUTH_USER")) + ":" + parseNull(env.getProperty("PREPROD_AUTH_PASSWD"));
			if(isprod) 
			{	
				userPassword = parseNull(env.getProperty("PROD_AUTH_USER")) + ":" + parseNull(env.getProperty("PROD_AUTH_PASSWD"));
			}

			String encoding = Base64.encode(userPassword.getBytes("UTF-8"));

			
			//checking if its a process.jsp url then we add new parameter ___rf=1 to it
			if(u.startsWith(internalcalllink + webappurl + "process.jsp"))
			{
				String _actualUrl = cacheutil.getActualUrl(u); 
				
				log("going to call _actualUrl " + _actualUrl);
				if(_actualUrl.equalsIgnoreCase("http://127.0.0.1") || _actualUrl.equalsIgnoreCase("http://127.0.0.1/") 
					|| _actualUrl.equalsIgnoreCase("http://localhost") || _actualUrl.equalsIgnoreCase("http://localhost/") || 
					_actualUrl.startsWith(internalcalllink + webappurl + "process.jsp"))
				{
					//root of site is normally configured to be the homepage which is already cached .. caching it again means cyclic cache will occur
					log("ERROR::process.jsp url is going to " + _actualUrl + " which can lead to cyclic caching");
					myurl = new MyUrl();
					myurl.processFurther = false;
					logE("No further crawling for " + u);
					return myurl;				
				}
				
				String u1 = u.substring(0, u.indexOf("process.jsp?") + "process.jsp?".length());
				String u2 = u.substring(u.indexOf("process.jsp?") + "process.jsp?".length());
				u = u1 + "___rf=1&" + u2;
				log("Call url : " + u);
			}
		
		
			URL url = new URL(u);
			con = (HttpURLConnection)url.openConnection();
			con.setRequestProperty("Authorization", "Basic " + encoding);	
			con.setRequestProperty("User-Agent", "Mozilla/5.0");		
			int responseCode = con.getResponseCode();
			log(" resp code : " + responseCode );	
			log(" content type " + con.getContentType());
			log(" redirect url " + con.getURL());
			log(" content type " + con.getContentType());
			log(" location " + parseNull(con.getHeaderField("Location")));
			log(" last modified date " + con.getLastModified());
			
			if (con.getResponseCode() == HttpURLConnection.HTTP_MOVED_PERM || con.getResponseCode() == HttpURLConnection.HTTP_MOVED_TEMP) 
			{
				return getFinalUrl(con.getHeaderField("Location"), isprod, menuCacheFolder, menuid);
			}
			else if(responseCode >= 300) 
			{
				myurl = new MyUrl();
				myurl.responseCode = responseCode;
				myurl.processFurther = false;
				myurl.isError = true;
				logE("No further crawling for " + u);				
				return myurl;
			}
			if(!parseNull(con.getContentType()).contains("text/html"))
			{		
				myurl = new MyUrl();
				myurl.responseCode = responseCode;
				myurl.processFurther = false;
				logE("No further crawling for " + u);
				return myurl;
			}


			myurl = new MyUrl();
			myurl.url = parseNull("" + con.getURL());
			myurl.contentType = con.getContentType();
			myurl.responseCode = responseCode;
			myurl.processFurther = true;
			myurl.responseCharset = cacheutil.getCharset(parseNull(con.getContentType()));

			//if separate folder cache is enabled we crawl only those pages which were cached in separate folder
			//incase of any 404 normal cache homepage or 404 .html urls can be returned so we ignore them as they already be having .html urls in them so no need to crawl them
			//when separate folder is enabled we need to check url should start with cote_portal/publishsites/ or cote_portal/process.jsp
			if(!myurl.url.startsWith(separatefoldercacheredirecturl + menuCacheFolder))
			{
				logE("Ignore url for further crawling : " + myurl.url);
				myurl.processFurther = false;				
			}

			myurl.resp = new StringBuffer();	
			BufferedReader reader = new BufferedReader(new InputStreamReader(con.getInputStream(), myurl.responseCharset));
			String inputLine;
			while ((inputLine = reader.readLine()) != null) {
				myurl.resp.append(inputLine + "\n");
			}
			reader.close();
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'Crawler::Error processing url') ");
			e.printStackTrace();
			logE("Exception getFinalURL :: " + e.getMessage());
			myurl = null;
		}
		finally
		{
			if(con != null) con.disconnect();
		}
		return myurl;
	}
	
	private MyUrl processUrl(String menuid, String menuCacheFolder, Node thisNode, Node parentNode, Map<String, Node> crawledNodes, Map<String, String> crawledUrls, List<String> allCachedPageUrls)
	{
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		MyUrl myurl = null;
		try 
		{			
			//we cache js/css files only in case we are caching the page ... if the page itself is an .html link then we dont have to recache resources
			boolean cacheresources = false;
			log("In processUrl :: url : " + parseNull(thisNode.url) + " pageType : " + parseNull(thisNode.pageType) + ", sb1 : " + parseNull(thisNode.subLevel1)  + ", sb2 : " + parseNull(thisNode.subLevel2));
			if(thisNode.url.startsWith(internalcalllink + webappurl + "process.jsp")) 
			{
				cacheresources = true;
				String actualUrl = cacheutil.getActualUrl(thisNode.url);		
				int depthLevel = getDepthLevel(actualUrl);
				if(depthLevel > -1)
				{
					int level = 0;
					if(parentNode != null) 
					{
						log(parentNode.url + " " + parentNode.level);
						level = parentNode.level + 1;
					}

					if(level >= depthLevel) 
					{
						log("Reached max depth level for url : " + actualUrl);
						return null;
					}
				}
			}					
			
			log("calling url : " + thisNode.url);
			if(parentNode != null) log("parent url : " + parentNode.url+ " pageType : " + parseNull(parentNode.pageType) + ", sb1 : " + parseNull(parentNode.subLevel1)  + ", sb2 : " + parseNull(parentNode.subLevel2));
			if(crawledUrls.get(thisNode.url) != null)
			{
				log("URL is already crawled so dont crawl again");
				String cachedPageId = parseNull(crawledUrls.get(thisNode.url));
				if(cachedPageId.length() > 0)
				{
					//a page will always have its own url inside it as well so in that case parentpageid = currentpageid and we have to ignore it
					//also a path leading from 404 we ignore that
					if(parentNode != null && parseNull(parentNode.pageId).length() > 0 
					&& Long.parseLong(parseNull(parentNode.pageId)) != Long.parseLong(cachedPageId) && !parentNode.is404) 
					{
						Node cachedNode = crawledNodes.get(cachedPageId);
						if(cachedNode.paths == null) cachedNode.paths = new HashMap<String, PathNode>();
						if(cachedNode.paths.get(parentNode.pageId) == null) 
						{
							log("CurrentPageId : " + cachedPageId + " .. ParentPageId : " + parentNode.pageId + " .. Adding path ... ismenulink : " + thisNode.isMenuLink);
							cachedNode.paths.put(parentNode.pageId, new PathNode(parentNode.pageId, thisNode.level, thisNode.isPageLink));
						}
					}
					
				}
				return null;
			}

			//allCachedPageUrls contains the urls which are cached by CacheAllContent which just caches the 
			//content of the current site being crawled
			String _actualUrl = cacheutil.getActualUrl(thisNode.url);
			if(isCrossSiteAppUrl(_actualUrl) && !allCachedPageUrls.contains(_actualUrl))
			{
				String _parentActualUrl = "";
				if(parentNode != null)
				{
					_parentActualUrl = cacheutil.getActualUrl(parentNode.url);
					if(_parentActualUrl.length() == 0) _parentActualUrl = parentNode.url;
				}
				String errmsg = "Error URL : " + _actualUrl + " in Parent Url : " + _parentActualUrl + ". Possibly cross site url or test site url";
				logE("ERROR::"+errmsg);
				Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+","+escape.cote(errmsg)+") ");
			}

			myurl = getFinalUrl(thisNode.url, isprod, menuCacheFolder, menuid);

			//some times external pages are not responding or too slow to download their resources .. in that case our cache system will return 503 as its still processing
			//and apache has a request time out so we get 503. In that case we try the url again
/*			if(!myurl.processFurther && (myurl.responseCode == 503 || myurl.responseCode == 502))
			{
				for(int _try=0; _try<2; _try++)
				{
					log("retry url : " + actualUrl);
					myurl = getFinalUrl(u, isprod, menuCacheFolder, menuid);
					if(myurl.processFurther) break;
				}
			}
*/
			if(!myurl.processFurther)
			{
				//mark url as crawled .. here we dont know the cached page id so we just put empty string
				//so that next time same url is not called and will save time
				crawledUrls.put(thisNode.url, "");
				log("Crawled URL : " + thisNode.url);

				//isError == true for urls not reachable otherwise processFurther == false even for urls where contenttype is not html
				//like caching images or pdfs etc in which case its not an error to be reported
				if(myurl.isError)
				{
					_actualUrl = thisNode.url;
					if(_actualUrl.startsWith(internalcalllink + webappurl + "process.jsp")) _actualUrl = cacheutil.getActualUrl(_actualUrl);
					
					String _parentactualurl = "";
					if(parentNode != null)
					{
						_parentactualurl = parentNode.url;
						if(_parentactualurl.startsWith(internalcalllink + webappurl + "process.jsp")) _parentactualurl = cacheutil.getActualUrl(_parentactualurl);
					}
				
					String errmsg = "RespCode:"+myurl.responseCode + " for url : " + _actualUrl;
					if(parseNull(_parentactualurl).length() > 0) errmsg += " in Parent Url : " + _parentactualurl;
					Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+","+escape.cote(errmsg)+") ");
				}			
				return myurl;
			}

			String contents = myurl.resp.toString().trim();
			org.jsoup.nodes.Document doc = Jsoup.parse(contents, thisNode.url);

			String reactPageId = "";
			org.jsoup.select.Elements eles = doc.select("meta[name=asimina-dynamic-page-id]");
			if(eles != null && !eles.isEmpty()) 
			{
				reactPageId = eles.first().attr("content");
				log("Found a react page id : " + reactPageId);
			}
			thisNode.reactPageId = reactPageId;	
						
			org.jsoup.nodes.Element cidele = doc.select("meta[name=pr:cid]").first();
			String pageid = null;
			if(cidele != null) 
			{
				pageid = cidele.attr("content");
			}
			pageid = parseNull(pageid);
			crawledUrls.put(thisNode.url, pageid);
			log("Crawled URL : " + thisNode.url +" cachedPageId : " +parseNull(pageid));
			
			if(parseNull(pageid).length() > 0) 
			{
				myurl.cachedPageId = pageid;
				thisNode.pageId = pageid;				
				
				if(crawledNodes.get(pageid) == null)
				{
					crawledNodes.put(pageid, thisNode);															
				}
				addPathToNode(parentNode, crawledNodes.get(pageid), thisNode.level, thisNode.isPageLink);			
			}
			
			int nextLevel = thisNode.level + 1;
			
			eles = doc.select("link[href]");
			for(org.jsoup.nodes.Element ele : eles)
			{
				String _r = ele.attr("href");
				if(_r.toLowerCase().startsWith("javascript:")) continue;

				String _rel = parseNull(ele.attr("rel"));
				if(_rel.equalsIgnoreCase("canonical") || _rel.equalsIgnoreCase("shortlink")) continue;				
				
				_r = ele.absUrl("href");
				//some resource need to go through cache so we will crawl it to refresh its cache
				if(cacheresources && _r.startsWith(internalcalllink + webappurl + "process.jsp") && resources.get(cacheutil.getActualUrl(_r)) == null ) resources.put(cacheutil.getActualUrl(_r), _r);
			}

			eles = doc.select("script[src]");
			for(org.jsoup.nodes.Element ele : eles)
			{
				String _r = ele.absUrl("src");
				//some resource need to go through cache so we will crawl it to refresh its cache
				if(cacheresources && _r.startsWith(internalcalllink + webappurl + "process.jsp") && resources.get(cacheutil.getActualUrl(_r)) == null) resources.put(cacheutil.getActualUrl(_r), _r);
			}
			
			Map<String, Node> listOfNodesToCrawl = new LinkedHashMap<String, Node>();
			//first check if there are any menus in the page
			eles = doc.select(".__crawl__menu");
			if(eles != null && eles.size() > 0)
			{
				log("Found " + eles.size() + " menus");
				//find the order in which menus must be crawled ... order is defined in css class __menu_
				String[] menuClasses = new String[eles.size()];
				for(org.jsoup.nodes.Element ele : eles)
				{
					for(String cssCls : ele.classNames())
					{
						if(parseNull(cssCls).startsWith("__menu_"))
						{
							String cs = parseNull(cssCls).replace("__menu_","");
							if(cs.length() > 0)
							{
								try
								{
									int menuOrder = Integer.parseInt(cs);
									menuClasses[menuOrder] = parseNull(cssCls);
									break;
								}
								catch(Exception ne)
								{
									Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'Crawler::Error crawling menus in the page') ");
									ne.printStackTrace();
								}
							}
						}
					}
				}
				for(String menuClass : menuClasses)
				{
					log("menuClass "  + parseNull(menuClass));
					//we have a valid class on the particular index
					if(parseNull(menuClass).length() > 0)
					{
						log("Get urls for menu : " + menuClass);
						findAllUrlsForMenus(doc.select("." + menuClass), thisNode.url, nextLevel, listOfNodesToCrawl, menuid);
					}
				}
				//now there might be the case that there is no ___menu_ order class added to any of menus ... so now we just load all href
				//from all __crawl__menu
				findAllUrlsForMenus(eles, thisNode.url, nextLevel, listOfNodesToCrawl, menuid);
			}

			//now get all hrefs from the page and add to list to be crawled
			eles = doc.select("a[href]");
			for(org.jsoup.nodes.Element ele : eles)
			{
				if(!cacheutil.isValidForCrawl(ele, menuid, internalcalllink, webappurl)) continue;
				
				String _r = parseNull(ele.absUrl("href"));				
				if(listOfNodesToCrawl.get(_r) == null)
				{
					Node crawlNode = new Node();
					crawlNode.level = nextLevel ;
					crawlNode.url = _r;
					crawlNode.pageType = thisNode.pageType;
					crawlNode.subLevel1 = thisNode.subLevel1;
					crawlNode.subLevel2 = thisNode.subLevel2;
					crawlNode.isPageLink = true;
					log("processUrl::Add href Node : " + crawlNode.url + " " + crawlNode.pageType + " " + crawlNode.subLevel1 + " " + crawlNode.subLevel2 + " " + crawlNode.isPageLink);
					listOfNodesToCrawl.put(_r, crawlNode);					
				}//if url is not added in list already
				else if( !ele.className().contains("___portalmenulink") )// a[href] will also return the links in menu so we check the specific class to make sure its not a menu link
				{
					//this will be the case when a link is already added in listOfNodesToCrawl from the menus hrefs
					//or same link is repeated twice in the page ... in both cases the isPageLink is true 
					//as a link in menu can also be a link in page
					listOfNodesToCrawl.get(_r).isPageLink = true;
				}
			}//for href

			for(String _r : listOfNodesToCrawl.keySet())
			{
				Node node = listOfNodesToCrawl.get(_r);
				processUrl(menuid, menuCacheFolder, node, thisNode, crawledNodes, crawledUrls, allCachedPageUrls);
			}
			
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'Crawler::Error processing url') ");
			e.printStackTrace();
		}
		return myurl;		
	}	
	
	private void addPathToNode(Node parentNode, Node currentNode, int pageLevel, boolean isPageLink)
	{
		if(parentNode != null && parseNull(parentNode.pageId).length() > 0 && Long.parseLong(parseNull(parentNode.pageId)) != Long.parseLong(currentNode.pageId) && !parentNode.is404) 
		{
			log("addPathToNode :: CurrentPageId : " + currentNode.pageId + " .. ParentPageId : " + parentNode.pageId + " .. Adding path ... ismenulink : " + currentNode.isMenuLink);										
			if(currentNode.paths == null) currentNode.paths = new HashMap<String, PathNode>();
			if(currentNode.paths.get(parentNode.pageId) == null)
			{
				currentNode.paths.put(parentNode.pageId, new PathNode(parentNode.pageId, pageLevel, isPageLink));
			}	
			//if a url is in menu as well in the page content itself and urls are same in both places, then the isPageLink is already set to true 
			//but there can be a case where the menu has absolute url and the page content is a relative url or vice versa. In that case the ispagelink wont be set to true
			//when we are fetching all urls in a page. In that case we will end-up in this else if and we will simply update the paths level and isPageLink
			//as isPageLink true has more preference so that breadcrumbs can show multiple paths
			else if(isPageLink)
			{
				currentNode.paths.get(parentNode.pageId).level = pageLevel;
				currentNode.paths.get(parentNode.pageId).isPageLink = isPageLink;
			}
		}		
	}
	
	private void findAllUrlsForMenus(org.jsoup.select.Elements menuEles, String url, int level, Map<String, Node> listOfNodesToCrawl, String menuid)
	{
		if (env != null) //this means its running from engine 
		{
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
		}

		try
		{
			if(menuEles == null) return;
			//we expect list of menu elements because they might give same order css class to two different menus
			for(org.jsoup.nodes.Element menuElement : menuEles)
			{
				org.jsoup.nodes.Document doc = Jsoup.parse(menuElement.html(), url);
				//get all menu sub level 2
				org.jsoup.select.Elements subLevel2Elements = doc.select(".__menu_sb2");
				for(org.jsoup.nodes.Element subLevel2Ele : subLevel2Elements)
				{					
					String pageType = "";
					String subLevel1 = "";					
					String subLevel2 = subLevel2Ele.ownText();
					if("a".equalsIgnoreCase(subLevel2Ele.tagName()) && cacheutil.isValidForCrawl(subLevel2Ele, menuid, internalcalllink, webappurl))
					{		
						String _r = parseNull(subLevel2Ele.absUrl("href"));	

						if(listOfNodesToCrawl.get(_r) == null)
						{
							for(String subLevel2CssCls : subLevel2Ele.classNames())
							{
								if(subLevel2CssCls.startsWith("__menu_sb1_"))
								{
									org.jsoup.select.Elements subLevel1Eles = doc.select(".__menu_sb1" + "." + subLevel2CssCls);								
									if(subLevel1Eles != null && subLevel1Eles.size() > 0)
									{
										org.jsoup.nodes.Element subLevel1Ele = subLevel1Eles.first();
										subLevel1 = subLevel1Ele.ownText();	
										for(String subLevel1CssCls : subLevel1Ele.classNames())
										{
											if(subLevel1CssCls.startsWith("__page_type_"))
											{
												org.jsoup.select.Elements pageTypeEles = doc.select(".__page_type" + "." + subLevel1CssCls);											
												if(pageTypeEles != null && pageTypeEles.size() > 0)
												{
													org.jsoup.nodes.Element pageTypeEle = pageTypeEles.first();
													pageType = pageTypeEle.ownText();												
												}
												break;
											}
										}
									}	
									break;								
								}
							}
							Node node = new Node();
							node.url = _r;
							node.level = level;
							node.isMenuLink = true;
							node.pageType = pageType;
							node.subLevel1 = subLevel1;
							node.subLevel2 = subLevel2;	
							log("findAllUrlsForMenus::Add Sub level 2 Node : " + node.url + " " + node.pageType + " " + node.subLevel1 + " " + node.subLevel2 + " " + node.isMenuLink);
							listOfNodesToCrawl.put(_r, node);							
						}
					}
				}

				//get all menu sub level 1
				org.jsoup.select.Elements subLevel1Elements = doc.select(".__menu_sb1");
				for(org.jsoup.nodes.Element subLevel1Ele : subLevel1Elements)
				{					
					String pageType = "";
					String subLevel1 = subLevel1Ele.ownText();	
					if("a".equalsIgnoreCase(subLevel1Ele.tagName()) && cacheutil.isValidForCrawl(subLevel1Ele, menuid, internalcalllink, webappurl))
					{		
						String _r = parseNull(subLevel1Ele.absUrl("href"));				
						
						if(listOfNodesToCrawl.get(_r) == null)
						{
							for(String subLevel1CssCls : subLevel1Ele.classNames())
							{
								if(subLevel1CssCls.startsWith("__page_type_"))
								{
									org.jsoup.select.Elements pageTypeEles = doc.select(".__page_type" + "." + subLevel1CssCls);											
									if(pageTypeEles != null && pageTypeEles.size() > 0)
									{
										org.jsoup.nodes.Element pageTypeEle = pageTypeEles.first();
										pageType = pageTypeEle.ownText();												
									}
									break;
								}
							}
							
							Node node = new Node();
							node.url = _r;
							node.level = level;
							node.isMenuLink = true;
							node.pageType = pageType;
							node.subLevel1 = subLevel1;
							log("findAllUrlsForMenus::Add Sub level 1 Node : " + node.url + " " + node.pageType + " " + node.subLevel1 + " " + node.subLevel2 + " " + node.isMenuLink);
							listOfNodesToCrawl.put(_r, node);
						}
					}
				}

				//get all page type tags
				org.jsoup.select.Elements pageTypeElements = doc.select(".__page_type");
				for(org.jsoup.nodes.Element pageTypeEle : pageTypeElements)
				{					
					String pageType = pageTypeEle.ownText();
					if("a".equalsIgnoreCase(pageTypeEle.tagName()) && cacheutil.isValidForCrawl(pageTypeEle, menuid, internalcalllink, webappurl))
					{		
						String _r = parseNull(pageTypeEle.absUrl("href"));				

						if(listOfNodesToCrawl.get(_r) == null)
						{
							Node node = new Node();
							node.url = _r;
							node.level = level;
							node.isMenuLink = true;
							node.pageType = pageType;
							log("findAllUrlsForMenus::Add page type Node : " + node.url + " " + node.pageType + " " + node.subLevel1 + " " + node.subLevel2 + " " + node.isMenuLink);
							listOfNodesToCrawl.put(_r, node);
						}
					}
				}
				
				//any other urls which are not in proper hierarchy of menu
				org.jsoup.select.Elements eles = doc.select("a[href]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(!cacheutil.isValidForCrawl(ele, menuid, internalcalllink, webappurl)) continue;
				
					String _r = parseNull(ele.absUrl("href"));					
					
					if(listOfNodesToCrawl.get(_r) == null)
					{
						Node node = new Node();
						node.level = level;
						node.url = _r;
						node.isMenuLink = true;
						log("findAllUrlsForMenus::Add other Node : " + node.url + " " + node.isMenuLink);
						listOfNodesToCrawl.put(_r, node);
					}
				}
			}
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'Crawler::Error crawling menu links') ");
			e.printStackTrace();
		}
	}
	
	private class Node
	{
		String url = "";
		String pageId = "";
		int level;
		Map<String, PathNode> paths;
		boolean is404 = false;
		boolean isMenuLink = false;
		boolean isHomepageLink = false;
		boolean isUserHomepage = false;
		boolean isPageLink = false;
		String reactPageId = "";		
		String pageType = "";
		String subLevel1 = "";
		String subLevel2 = "";

		public String getIsMenuLink()
		{
			if(isMenuLink) return "1";
			return "0";
		}
	}

	private class PathNode
	{
		String parentpageid;
		int level;
		boolean isPageLink = false;

		public PathNode (String parentpageid, int level, boolean isPageLink)
		{
			this.parentpageid = parentpageid;
			this.level = level;
			this.isPageLink = isPageLink;
		}

		public String getIsPageLink()
		{
			if(isPageLink) return "1";
			return "0";
		}
	}

	private class MyUrl
	{
		String url;
		int responseCode;
		String contentType;
		StringBuffer resp;
		boolean processFurther = true;
		String responseCharset = "";
		String cachedPageId;
		boolean isError = false;
	}

	public void saveFileToDisk(String contents, String filepath, String charset, String menuid) 
	{
		FileOutputStream fout = null;
		try
		{
			log("Saving html file to disk " + filepath);

			fout = new FileOutputStream (filepath);

			fout.write(contents.getBytes(charset));
			fout.flush();	
		}
		catch(Exception e)
		{
			logE("Error saving file to disk");
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'Crawler::Error saving file') ");
			e.printStackTrace();
		}
		finally
		{
			if(fout != null) try { fout.close(); } catch (Exception e) {}
		}
	}

	public static void main(String[] aa) throws Exception
	{		
//		Crawler c = new Crawler(true, true, true);
		Map<String, List<String>> p = new HashMap<String, List<String>>();
		List<String> ps = new ArrayList<String>();
		ps.add("412");
		ps.add("413");

		p.put("5", ps);

		ps = new ArrayList<String>();
		ps.add("456");
		p.put("18", ps);
		
//		c.crawlPages(p);

/*		Crawler c = new Crawler(Boolean.parseBoolean(aa[0]), true, true);
		log("Going to crawl page id : " + aa[1]);
		c.crawlPage(aa[1]);

		if(a==null || a.length == 0) 
		{
			System.out.println("usage:: java Crawler true/false");
			System.out.println("where true means crawl production site(s) and false means to crawl preprod site(s)");	
		}
		else
		{
			boolean isprod = Boolean.parseBoolean(a[0]);
			new Crawler(isprod, true).start();
		}
*/
	}	

}

