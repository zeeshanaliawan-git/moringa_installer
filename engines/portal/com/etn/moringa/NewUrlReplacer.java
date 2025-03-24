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
import java.io.*;
import org.jsoup.*;

public class NewUrlReplacer 
{ 

	private Properties env;
	private ClientSql Etn;
	private boolean isprod;
	private boolean debug;
	private String dbname = "";
	private CacheUtil cacheutil; 

	private void init(ClientSql Etn, Properties env, boolean isprod, boolean debug) throws Exception
	{
		this.Etn = Etn;
		this.env = env;
		this.isprod = isprod;
		this.debug = debug;	
		
		dbname = "";
		if(isprod) dbname = env.getProperty("PROD_DB") + ".";

		Etn.setSeparateur(2, '\001', '\002');
		
		cacheutil = new CacheUtil(env, isprod, debug);
	}

	public NewUrlReplacer(ClientSql Etn, Properties env, boolean isprod, boolean debug) throws Exception
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
		if(isprod) m = "Prod NewUrlReplacer::" + m;
		else m = "Preprod NewUrlReplacer::" + m;
		System.out.println(m);
	}

	private void getHtmlFilesList(String folder, List<String> files, String menuid)
	{
		try
		{
//			log("going to find .html files in folder : " + folder);

			File dir = new File(folder);
			File[] list = dir.listFiles();
			if(list != null) 
			{
				for(File f : list)
				{
					if(f.isDirectory()) 
					{
						getHtmlFilesList(f.getAbsolutePath(), files, menuid);
					}
					else if(f.getAbsolutePath().toLowerCase().endsWith(".html"))
					{
						files.add(f.getAbsolutePath());
					}
				}
			}
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'NewUrlReplacer::Error getting list of html files') ");
			logE("Error while getting list of files");
			e.printStackTrace();
		}
	}

	public void start(String menuid) throws Exception
	{
		log("--------- NewUrlReplacer started : " + new Date());
		
		String cacheBaseFolder = env.getProperty("PUBLISHER_BASE_DIR") + env.getProperty("PUBLISHER_DOWNLOAD_PAGES_FOLDER");		


		String publisherUrl = env.getProperty("PUBLISHER_SEND_REDIRECT_LINK");
		String colprefix = "";
		if(isprod) 
		{			
			cacheBaseFolder = env.getProperty("PUBLISHER_PROD_BASE_DIR") + env.getProperty("PUBLISHER_PROD_DOWNLOAD_PAGES_FOLDER");
			colprefix = "prod_";

			publisherUrl = env.getProperty("PROD_PUBLISHER_SEND_REDIRECT_LINK");
		}

		//replace urls is required because for external website we dont have to replace urls with .html urls even if the pages are cached
		//this is because they can mark those pages to be recached at some interval and putting .html urls means we never get the updated content
		//like if a url from our page goes to www.starafrica.com and we let it be process.jsp url so that everytime it picks the latest page cached 

		Map<String, List<String>> htmlFiles = new HashMap<String, List<String>>();		
		if(htmlFiles.get(menuid) == null)
		{
			String menuCacheFolder = cacheutil.getMenuCacheFolder(Etn, menuid);
			String replaceinfolder = cacheBaseFolder + menuCacheFolder;

			log("get list of html files for menu : " + menuid + " in folder : " +replaceinfolder);
			List<String> htmlFilesList = new ArrayList<String>();
			getHtmlFilesList(replaceinfolder, htmlFilesList, menuid);
			htmlFiles.put(menuid, htmlFilesList);
//				log("Html files list");
//				for(String s : htmlFilesList ) log(s);
		}

		HashMap<String, String> menuids = new HashMap<String, String>();

		String webappurl = parseNull(env.getProperty("EXTERNAL_LINK"));
		String internalcalllink = parseNull(env.getProperty("INTERNAL_CALL_LINK"));
		if(isprod) 
		{
			webappurl = parseNull(env.getProperty("PROD_EXTERNAL_LINK"));
		}

		for(String mid : htmlFiles.keySet())
		{
			log("Get cached pages list for menu : "+ mid);
			
			String currentMenuPath = cacheutil.getMenuPath(Etn, mid);
			String menuCacheFolder = cacheutil.getMenuCacheFolder(Etn, mid);

			if(menuids.get(mid) == null) 
			{				
				int auditid = Etn.executeCmd("insert into "+dbname+"crawler_audit (menu_id, start_time, status, action) values ("+escape.cote(mid)+",now(),1, 'Replacing URLs') ");
				menuids.put(mid, ""+auditid);
			}
			
			String qry = " select c.*, s.name as sitename, cpp.file_path as file_path, cpp.file_url as file_url  "+
					" from "+dbname+"cached_pages as c, "+dbname+"site_menus m, "+dbname+"sites s, "+dbname+"cached_pages_path cpp "+
					" where cpp.id = c.id and c.cached = 1 and m.site_id = s.id and m.id = c.menu_id "+
					" and (coalesce(c.filename,'') <> '' or coalesce(c.res_file_extension,'') <> '') "+
					" and c.id not in ( select cached_page_id from "+dbname+"dynamic_pages ) "+			
					" and c.menu_id = " + escape.cote(mid) ;
			//adding this order by just to make sure the longest url is replaced first
			//just doing this to avoid any short encoded url which could be the starting part of a larger encoded url so replacing short first will mean part of longer one will be replaced and later longer one will not be replaced
			//also our replace url script actually works on like rather than exact match so have to add order by
			qry += " order by length(c.encoded_url) desc ";

			Set rs = Etn.execute(qry);
			if(rs == null || rs.rs.Rows == 0) 
			{
				//no file is cached so we just move header_html to header_html_1 and also the footer as _1 columns are used by process.jsp when called from browser
				String _q2 = " update "+dbname+"site_menu_htmls set header_html_1 = header_html, footer_html_1 = footer_html ";
				_q2 += " where menu_id = " + escape.cote(mid);
				Etn.executeCmd(_q2);
				//log(_q2);
				logE("No site/menu found for url replacing");
			}
			else
			{
				Map<String, String> replaceUrlsForMenu = new HashMap<String, String>();
				while(rs.next())
				{
					if(parseNull(rs.value("filename")).length() > 0)
					{
						replaceUrlsForMenu.put(Base64.encode(rs.value("url").getBytes("UTF-8")), parseNull(rs.value("file_url")) + java.net.URLEncoder.encode(rs.value("filename"), "utf-8") );
					}
					else
					{
						replaceUrlsForMenu.put(Base64.encode(rs.value("url").getBytes("UTF-8")), parseNull(rs.value("file_url")) + rs.value("id")  + rs.value("res_file_extension") );
					}
				}

				for(String htmlFile : htmlFiles.get(mid))
				{	
					log("Replace urls in file : " + htmlFile);
					org.jsoup.nodes.Document doc = Jsoup.parse(new File(htmlFile), "UTF-8");

					org.jsoup.select.Elements eles = doc.select("a[href]");
					for(org.jsoup.nodes.Element ele : eles)
					{
						//special case of image gallery added in products screen where href has image url so we dont have to crawl that as its already downloaded by cache
						if(parseNull(ele.className()).contains("etn_portal_gallery")) continue;

						//for new menu we have the login bar integrated in the menu so it has links which must not be crawled
/*						if(parseNull(ele.className()).contains("moringa-no-crawl"))
						{
//							log("found login links ... not updating it");
							continue;
						}
*/		
						if(parseNull(ele.className()).contains("___languagelink")) 
						{
//							log("found a language ... not updating it");
							continue;
						}
			
						String _r = parseNull(ele.attr("href"));
				
						if(_r.toLowerCase().startsWith("javascript:")) continue;
						else if(_r.toLowerCase().startsWith("tel:")) continue;
						else if(_r.equals("#")) continue;
						else if(_r.startsWith("#")) continue;
						else if(_r.length() == 0 || _r.equals("/")) continue;

						//a new case where we append publisher path with URL which are .html urls in original page and does not start with /
						//so we have to replace the publisher path with the menu path
						if(_r.startsWith(publisherUrl))
						{
							//log("Replace relative URL : " + _r);
							_r = _r.replace(publisherUrl + menuCacheFolder, currentMenuPath);
							//log("Change it with : " + _r);
							ele.attr("href", _r);
						}
						else if(_r.startsWith(webappurl + "process.jsp") || _r.startsWith(internalcalllink + webappurl + "process.jsp") )
						{
							//log("Replace process.jsp URL : " + _r);
							String _encodedUrl = getEncodedUrlFrom(_r);
							if(_encodedUrl != null && _encodedUrl.length() > 0 && replaceUrlsForMenu.get(_encodedUrl) != null)
							{
								ele.attr("href", replaceUrlsForMenu.get(_encodedUrl));
							}
						}						
					}//for elements href	
		
					eles = doc.select("link[href]");
					for(org.jsoup.nodes.Element ele : eles)
					{
						String _r = ele.attr("href");
						//some resource need to go through cache so we will crawl it to refresh its cache
						if(_r.startsWith(webappurl + "process.jsp") || _r.startsWith(internalcalllink + webappurl + "process.jsp"))
						{
							String _encodedUrl = getEncodedUrlFrom(_r);
							if(_encodedUrl != null && _encodedUrl.length() > 0 && replaceUrlsForMenu.get(_encodedUrl) != null)
							{
								String _finalurl = replaceUrlsForMenu.get(_encodedUrl);
								if(_finalurl.length() > 0)
								{
									if(_finalurl.indexOf("?") > -1) _finalurl = _finalurl + "&__v=" + parseNull(env.getProperty("CSS_JS_VERSION"));
									else _finalurl = _finalurl + "?__v=" + parseNull(env.getProperty("CSS_JS_VERSION"));																	
								}								
								ele.attr("href", _finalurl);
							}
						}
					}

					eles = doc.select("script[src]");
					for(org.jsoup.nodes.Element ele : eles)
					{
						String _r = ele.attr("src");
						//some resource need to go through cache so we will crawl it to refresh its cache
						if(_r.startsWith(webappurl + "process.jsp") || _r.startsWith(internalcalllink + webappurl + "process.jsp"))
						{
							String _encodedUrl = getEncodedUrlFrom(_r);
							if(_encodedUrl != null && _encodedUrl.length() > 0 && replaceUrlsForMenu.get(_encodedUrl) != null)
							{
								String _finalurl = replaceUrlsForMenu.get(_encodedUrl);
								if(_finalurl.length() > 0)
								{
									if(_finalurl.indexOf("?") > -1) _finalurl = _finalurl + "&__v=" + parseNull(env.getProperty("CSS_JS_VERSION"));
									else _finalurl = _finalurl + "?__v=" + parseNull(env.getProperty("CSS_JS_VERSION"));																	
								}								
								ele.attr("src", _finalurl);
							}
						}
					}
				
					eles = doc.select("iframe[src]");
					for(org.jsoup.nodes.Element ele : eles)
					{
						String _r = ele.attr("src");
						//a new case where we append publisher path with URL which are .html urls in original page and does not start with /
						//so we have to replace the publisher path with the menu path
						if(_r.startsWith(publisherUrl))
						{
							//log("Replace relative URL : " + _r);
							_r = _r.replace(publisherUrl + menuCacheFolder, currentMenuPath);
							//log("Change it with : " + _r);
							ele.attr("src", _r);
						}						
						else if(_r.startsWith(webappurl + "process.jsp") || _r.startsWith(internalcalllink + webappurl + "process.jsp"))
						{
							String _encodedUrl = getEncodedUrlFrom(_r);
							if(_encodedUrl != null && _encodedUrl.length() > 0 && replaceUrlsForMenu.get(_encodedUrl) != null)
							{
								ele.attr("src", replaceUrlsForMenu.get(_encodedUrl));
							}
						}
					}

					eles = doc.select("form[action]");
					for(org.jsoup.nodes.Element ele : eles)
					{
						String _r = ele.attr("action");					
						//a new case where we append publisher path with URL which are .html urls in original page and does not start with /
						//so we have to replace the publisher path with the menu path
						if(_r.startsWith(publisherUrl))
						{
							//log("Replace relative URL : " + _r);
							_r = _r.replace(publisherUrl + menuCacheFolder, currentMenuPath);
							//log("Change it with : " + _r);
							ele.attr("action", _r);
						}						
						else if(_r.startsWith(webappurl + "process.jsp") || _r.startsWith(internalcalllink + webappurl + "process.jsp"))
						{
							String _encodedUrl = getEncodedUrlFrom(_r);							
							if(_encodedUrl != null && _encodedUrl.length() > 0 && replaceUrlsForMenu.get(_encodedUrl) != null)
							{
								ele.attr("action", replaceUrlsForMenu.get(_encodedUrl));
							}
						}
					}

					//in process.jsp we change data-uri to action
					eles = doc.select("*[data-uri]");
					for(org.jsoup.nodes.Element ele : eles)
					{
						String _r = ele.attr("data-uri");
						//a new case where we append publisher path with URL which are .html urls in original page and does not start with /
						//so we have to replace the publisher path with the menu path
						if(_r.startsWith(publisherUrl))
						{
							//log("Replace relative URL : " + _r);
							_r = _r.replace(publisherUrl + menuCacheFolder, currentMenuPath);
							//log("Change it with : " + _r);
							ele.attr("action", _r);
						}						
						else if(_r.startsWith(webappurl + "process.jsp") || _r.startsWith(internalcalllink + webappurl + "process.jsp"))
						{
							String _encodedUrl = getEncodedUrlFrom(_r);
							if(_encodedUrl != null && _encodedUrl.length() > 0 && replaceUrlsForMenu.get(_encodedUrl) != null)
							{
								ele.attr("action", replaceUrlsForMenu.get(_encodedUrl));
							}
						}
					}

					eles = doc.select("input[src]");
					for(org.jsoup.nodes.Element ele : eles)
					{
						String _r = ele.attr("src");
						//a new case where we append publisher path with URL which are .html urls in original page and does not start with /
						//so we have to replace the publisher path with the menu path
						if(_r.startsWith(publisherUrl))
						{
							//log("Replace relative URL : " + _r);
							_r = _r.replace(publisherUrl + menuCacheFolder, currentMenuPath);
							//log("Change it with : " + _r);
							ele.attr("src", _r);
						}						
						else if(_r.startsWith(webappurl + "process.jsp") || _r.startsWith(internalcalllink + webappurl + "process.jsp"))
						{
							String _encodedUrl = getEncodedUrlFrom(_r);
							if(_encodedUrl != null && _encodedUrl.length() > 0 && replaceUrlsForMenu.get(_encodedUrl) != null)
							{
								ele.attr("src", replaceUrlsForMenu.get(_encodedUrl));
							}
						}
					}

					saveFileToDisk(doc.outerHtml(), htmlFile, menuid);
				}
			}
		}


		if(!menuids.isEmpty())
		{
			for(String mid : menuids.keySet())
			{
				String menuSendRedirect = cacheutil.getMenuPath(Etn, mid);

				String colname = "homepage_url";
				if(isprod) colname = "prod_homepage_url";

				Set rs = Etn.execute("select c.*,s.name as sitename, s.id as siteid, cp.file_url from "+dbname+"site_menus m,"+dbname+"cached_pages c, "+dbname+"cached_pages_path cp, "+dbname+"sites s where cp.id = c.id and s.id = m.site_id and m.id = " + escape.cote(mid) + " and c.menu_id = m.id and c.url = m."+colname+" ");
				log("rs.rs.Rows = "+rs.rs.Rows);
				rs.next();
				String siteid = rs.value("siteid");
				String cachedResourcesFolder = cacheutil.getCachedResourcesUrl(Etn, menuid);

				String menuCacheFolder = cacheutil.getMenuCacheFolder(Etn, mid);
				String replaceinfolder = cacheBaseFolder + menuCacheFolder;
//				log("-------------------------------- replaceinfolder : " + replaceinfolder);

	
				String replacestr = "window.location=\'"+webappurl+"process.jsp?___pt=\'+______pt+\'&___mc=\'+______mc+\'&___mid=\'+______mid+\'&___mu="+Base64.encode(rs.value("url").getBytes("UTF-8"))+"\';";
				String replacewith = "window.location=\'"+ rs.value("file_url") + java.net.URLEncoder.encode(rs.value("filename"), "utf-8")+"\';";
	
				String cmd = env.getProperty("URL_REPLACE_SCRIPT") + " " + replacestr.replace("/","\\/") + " " + replacewith.replace("/","\\/") + " " + replaceinfolder + "";
	
				Process proc = Runtime.getRuntime().exec(cmd);
				int r = proc.waitFor();					
				log("result :" + r + " for " + cmd);

				Etn.executeCmd("update "+dbname+"crawler_audit set end_time = now(), status = 2 where id = " + escape.cote(menuids.get(mid))); 

				//have to update process.jsp urls in db as well so that cart.jsp should show .html urls as well
				rs = Etn.execute("select m.* from "+dbname+"site_menus m where m.id = " + escape.cote(mid));
				rs.next();
				
				replaceInHtml(parseNull(rs.value(colprefix+"homepage_url")), webappurl, mid, "", mid, siteid, cachedResourcesFolder);

				if("1".equals(parseNull(rs.value("show_find_a_store"))))
				{
					replaceInHtml(parseNull(rs.value(colprefix+"find_a_store_url")), webappurl, mid, parseNull(rs.value("find_a_store_open_as")), mid, siteid, cachedResourcesFolder);
				}
				if("1".equals(parseNull(rs.value("show_contact_us"))))
				{
					replaceInHtml(parseNull(rs.value(colprefix+"contact_us_url")), webappurl, mid, parseNull(rs.value("contact_us_open_as")), mid, siteid, cachedResourcesFolder);
				}

				Set rsm = Etn.execute("select * from "+dbname+"menu_items where menu_id = " + escape.cote(mid) + " and menu_item_id = -30 order by coalesce(order_seq, 999999), id ");
				while(rsm.next())
				{
					String mclick = parseNull(rsm.value("display_name"));
					if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));
					replaceInHtml(parseNull(rsm.value(colprefix+"url")), webappurl, mid, parseNull(rsm.value("open_as")), mid, siteid, cachedResourcesFolder) ;
				}

				//second level menu		
				rsm = Etn.execute("select  * from "+dbname+"menu_items where menu_id = " + escape.cote(mid) + " and menu_item_id = -20 order by coalesce(order_seq, 999999), id " );
				while(rsm.next())
				{
					String mclick = parseNull(rsm.value("display_name"));
					if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));
					String pagetype = mclick;

					replaceInHtml(parseNull(rsm.value(colprefix+"url")), webappurl, mid, parseNull(rsm.value("open_as")), mid, siteid, cachedResourcesFolder);

					String itemid = parseNull(rsm.value("id"));
					Set rsm1 = Etn.execute("select  * from "+dbname+"menu_items where menu_id = " + escape.cote(mid) + " and menu_item_id = "+escape.cote(itemid)+" order by coalesce(order_seq, 999999), id " );
					while(rsm1.next())
					{
						mclick = parseNull(rsm1.value("display_name"));
						if(mclick.length() == 0) mclick = parseNull(rsm1.value("name"));

						replaceInHtml(parseNull(rsm1.value(colprefix+"url")), webappurl, mid, parseNull(rsm1.value("open_as")), mid, siteid, cachedResourcesFolder);

						String itemid1 = parseNull(rsm1.value("id"));
						Set rsm2 = Etn.execute("select  * from "+dbname+"menu_items where menu_id = " + escape.cote(mid) + " and menu_item_id = "+escape.cote(itemid1)+" order by coalesce(order_seq, 999999), id " );
						while(rsm2.next())
						{
							mclick = parseNull(rsm2.value("display_name"));
							if(mclick.length() == 0) mclick = parseNull(rsm2.value("name"));
							replaceInHtml(parseNull(rsm2.value(colprefix+"url")), webappurl, mid, parseNull(rsm2.value("open_as")), mid, siteid, cachedResourcesFolder);
						}
					}
				}

				Set rsl = Etn.execute("select * from "+dbname+"additional_menu_items where menu_id = " + escape.cote(mid) + " and link_type = 'language' ");
				while(rsl.next())
				{
					String tomenuid = parseNull(rsl.value("to_menu_id"));
					String tourl = "";
					if(tomenuid.length() > 0)
					{
						Set tomenurs = Etn.execute("select m.*, s.name as sitename from "+dbname+"site_menus m, "+dbname+"sites s where s.id = m.site_id and m.id = " + escape.cote(tomenuid));
						if(tomenurs.next()) 
						{
							tourl = parseNull(tomenurs.value(colprefix+"homepage_url"));
						}
					}
					if(tourl.length() > 0) 
					{
						log("language replace ");

						Set rs33 = Etn.execute("select c.*, cp.file_url, cp.published_url from "+dbname+"cached_pages c, "+dbname+"cached_pages_path cp where c.id = cp.id and c.menu_id = "+escape.cote(tomenuid)+" and c.hex_eurl = hex(sha(" + escape.cote(Base64.encode(tourl.getBytes("UTF-8"))) + ")) ");
						if(rs33.next())
						{	
							String toMenuPath = cacheutil.getMenuPath(Etn, tomenuid);
							replacestr = parseNull(cacheutil.getExternalLink(tourl, tomenuid, Etn, toMenuPath, true, siteid, cachedResourcesFolder));
							
							if(replacestr.contains("process.jsp?"))
							{
								replacewith = rs33.value("published_url");
								cmd = env.getProperty("URL_REPLACE_SCRIPT") + " " + replacestr.replace("/","\\/") + " " + replacewith.replace("/","\\/") + " " + replaceinfolder + "";

								proc = Runtime.getRuntime().exec(cmd);
								r = proc.waitFor();					
								log("result :" + r + " for " + cmd);
							}
						}			

						replaceInHtml(tourl, webappurl, tomenuid, "", mid, siteid, cachedResourcesFolder);
					}
				}

				Etn.executeCmd("update "+dbname+"site_menu_htmls set header_html_1 = tmp_header_html, footer_html_1 = tmp_footer_html, tmp_footer_html = '', tmp_header_html = '' where menu_id = " + escape.cote(mid));
 			}
		}

		log("--------- NewUrlReplacer end : " + new Date());
	}

	private void replaceInHtml(String url, String webappurl, String menuid, String openas, String origmenuid, String siteid, String cachedResourcesFolder) 
	{
		try
		{
			String menuPublishPath = parseNull(env.getProperty("PROD_PUBLISHER_SEND_REDIRECT_LINK")) + cacheutil.getMenuCacheFolder(Etn, menuid);		
			
			Map<String, String> fixedUrls = cacheutil.fixOldFormatUrls(url);
			if(fixedUrls != null && fixedUrls.get("url") != null) url = fixedUrls.get("url");
			
			String replacestr = parseNull(cacheutil.getExternalLink(url, menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder));
			if(replacestr.contains("process.jsp?"))
			{
				String b64 = Base64.encode(url.getBytes("UTF-8"));
				Set rs = Etn.execute("select c.*, cp.file_url from "+dbname+"cached_pages c,"+dbname+"cached_pages_path cp where cp.id = c.id and c.menu_id = "+escape.cote(menuid)+" and c.hex_eurl = hex(sha(" + escape.cote(b64) + ")) ");
				if(rs.next())
				{	
					String replacewith = rs.value("file_url") + java.net.URLEncoder.encode(rs.value("filename"), "utf-8");
					Etn.executeCmd("update "+dbname+"site_menu_htmls set tmp_header_html = replace((case coalesce(tmp_header_html,'') when '' then header_html else tmp_header_html end), "+escape.cote(replacestr)+","+escape.cote(replacewith)+"), tmp_footer_html = replace((case coalesce(tmp_footer_html,'') when '' then footer_html else tmp_footer_html end), "+escape.cote(replacestr)+","+escape.cote(replacewith)+") where menu_id = " + escape.cote(origmenuid));
				}			
			}
			else if(replacestr.startsWith(menuPublishPath))
			{ 
				String currentMenuPath = cacheutil.getMenuPath(Etn, menuid);
				
				String replacewith = replacestr;
				replacewith = replacewith.replace(menuPublishPath, currentMenuPath);
				Etn.executeCmd("update "+dbname+"site_menu_htmls set tmp_header_html = replace((case coalesce(tmp_header_html,'') when '' then header_html else tmp_header_html end), "+escape.cote(replacestr)+","+escape.cote(replacewith)+"), tmp_footer_html = replace((case coalesce(tmp_footer_html,'') when '' then footer_html else tmp_footer_html end), "+escape.cote(replacestr)+","+escape.cote(replacewith)+") where menu_id = " + escape.cote(origmenuid));				
			}
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(origmenuid)+",'NewUrlReplacer::Error updating url in db') ");
			logE("Exception in replaceInHtml");
			e.printStackTrace();
		}
	}

	public static void main( String a[] ) throws Exception
	{
		if(a==null || a.length == 0) 
		{
			System.out.println("usage:: java NewUrlReplacer true/false");
			System.out.println("where true means crawl production site(s) and false means to crawl preprod site(s)");	
		}
		else
		{
			boolean isprod = Boolean.parseBoolean(a[0]);
//			new NewUrlReplacer(isprod, true, false).start();
		}
	}

	private void saveFileToDisk(String contents, String filepath, String menuid) 
	{
		FileOutputStream fout = null;
		try
		{
			log("Saving html file to disk " + filepath);

			fout = new FileOutputStream (filepath);

			String charset =  "UTF-8";
			fout.write(contents.getBytes(charset));
			fout.flush();	
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'NewUrlReplacer::Error saving file') ");
			e.printStackTrace();
		}
		finally
		{
			if(fout != null) try { fout.close(); } catch (Exception e) {}
		}
	}

	private String getEncodedUrlFrom(String u) throws Exception
	{
		if(u.indexOf("?") < 0) return u;

		String internalcalllink = parseNull(env.getProperty("INTERNAL_CALL_LINK"));

		if(!u.toLowerCase().startsWith("http://")) u = internalcalllink + u;

		Map<String, String> queryParams = new LinkedHashMap<String, String>();
		URL url = new URL(u);
		String query = url.getQuery();
		String[] pairs = query.split("&");		
		for (String pair : pairs) 
		{
			int idx = pair.indexOf("=");
			queryParams.put(URLDecoder.decode(pair.substring(0, idx), "UTF-8"), URLDecoder.decode(pair.substring(idx + 1), "UTF-8"));
		}

		if(queryParams.get("___mu") == null) return "";		
		return parseNull(queryParams.get("___mu"));
	}

}

