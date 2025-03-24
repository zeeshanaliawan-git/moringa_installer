package com.etn.moringa;


import java.lang.Process;
import java.util.Properties;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.util.*;
import java.net.URL;
import java.io.File;
import java.net.*;
import com.etn.util.Base64;

public class CacheUtil
{
	private Properties env;
	private boolean isprod;
	private boolean debug;
	
	public CacheUtil(Properties env, boolean isprod, boolean debug)  throws Exception
	{	
		this.env = env;
		this.debug = debug;
		this.isprod = isprod;
	}

	private void log(String m)
	{
		if(!debug) return;		
		logE(m);
	}

	private void logE(String m)
	{
		if(isprod) m = "Prod CacheUtil::" + m;
		else m = "Preprod CacheUtil::" + m;
		System.out.println(m);
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public void prepareForCache() throws Exception
	{
		log("In Preparing cache");
		String publisherbasedir = parseNull(env.getProperty("PUBLISHER_BASE_DIR")) ;
		String publishersitesfolder = parseNull(env.getProperty("PUBLISHER_DOWNLOAD_PAGES_FOLDER")) ;
		if(isprod)
		{
			publisherbasedir = parseNull(env.getProperty("PUBLISHER_PROD_BASE_DIR")) ;
			publishersitesfolder = parseNull(env.getProperty("PUBLISHER_PROD_DOWNLOAD_PAGES_FOLDER")) ;
		}

		log("Clearing folder " + publisherbasedir + publishersitesfolder);
		String cmd = "rm -r " + publisherbasedir + publishersitesfolder;
		Process proc = Runtime.getRuntime().exec(cmd);
		int r = proc.waitFor();

		log("Creating folder " + publisherbasedir + publishersitesfolder);
		cmd = "mkdir " + publisherbasedir + publishersitesfolder;
		proc = Runtime.getRuntime().exec(cmd);
		r = proc.waitFor();			
	}

	public void moveCache(ClientSql Etn, String dbname, String mid) throws Exception
	{
		log("In moveCache");
		Set rs = Etn.execute("select s.name as sitename from "+dbname+"site_menus m, "+dbname+"sites s where s.id = m.site_id and m.id = " + escape.cote(mid));
		rs.next();
		//cache always go to sitename as the parent folder
		String sitefolder = Util.getSiteFolderName(parseNull(rs.value("sitename"))); 
		moveSiteCache(Etn, dbname, sitefolder);
	}
	
	public void moveSiteCache(ClientSql Etn, String dbname, String sitefolder) throws Exception
	{
		log("In moveSiteCache");

		log("Site Cache Folder : " + sitefolder);

		String basedir = parseNull(env.getProperty("CACHE_FOLDER")) ;
		String publisherbasedir = parseNull(env.getProperty("PUBLISHER_BASE_DIR")) ;
		String publishersitesfolder = parseNull(env.getProperty("PUBLISHER_DOWNLOAD_PAGES_FOLDER")) ;
		if(isprod)
		{
			basedir = parseNull(env.getProperty("PROD_CACHE_FOLDER")) ;
			publisherbasedir = parseNull(env.getProperty("PUBLISHER_PROD_BASE_DIR")) ;
			publishersitesfolder = parseNull(env.getProperty("PUBLISHER_PROD_DOWNLOAD_PAGES_FOLDER")) ;
		}

		log("cp -r " + " " + publisherbasedir + publishersitesfolder  + sitefolder + " " +  basedir);
		String cmd = "cp -r " + " " + publisherbasedir + publishersitesfolder  + sitefolder + " " +  basedir;
		Process proc = Runtime.getRuntime().exec(cmd);
		int r = proc.waitFor();

		log("cp -r " + " " + publisherbasedir + publishersitesfolder  + "0 " +  basedir);
		cmd = "cp -r " + " " + publisherbasedir + publishersitesfolder  + "0 " +  basedir;
		proc = Runtime.getRuntime().exec(cmd);
		r = proc.waitFor();

		cmd = "rm -r " + publisherbasedir + publishersitesfolder;
		proc = Runtime.getRuntime().exec(cmd);
		r = proc.waitFor();
	}

	public void copyLocalResources(ClientSql Etn, String dbname, String siteid) throws Exception
	{  
		log("In copyLocalResources");
		String basedir = parseNull(env.getProperty("CACHE_FOLDER")) ;
		if(isprod)
		{
			basedir = parseNull(env.getProperty("PROD_CACHE_FOLDER")) ;
		}
		if(basedir.endsWith("/") == false) basedir += "/";
		
		Set rs = Etn.execute("select * from "+dbname+"sites where id = " + escape.cote(siteid));
		rs.next();
		String sitename = Util.getSiteFolderName(parseNull(rs.value("name")));

		String sourcesResourcesPath = parseNull(env.getProperty("COMMON_RESOURCES_PATH"));
		if(sourcesResourcesPath.endsWith("/") == false) sourcesResourcesPath += "/";
		sourcesResourcesPath += siteid + "/";

		String targetPath = basedir + sitename + "/";
		String targetFolder = "resources";
		
		String publishResourcesScript = parseNull(env.getProperty("PUBLISH_RESOURCES_FOLDER_SCRIPT"));
		
		log(publishResourcesScript + " " + sourcesResourcesPath + " " +  targetPath + " " + targetFolder);
				
		String cmd = publishResourcesScript + " " + sourcesResourcesPath + " " +  targetPath + " " + targetFolder;
		Process proc = Runtime.getRuntime().exec(cmd);
		int r = proc.waitFor();
		log("copyLocalResources r : " + r);
	}		
	
	/**
	* The script called by this function uses rsync command to make things fast
	*/ 
	public void syncLocalResources(ClientSql Etn, String dbname, String siteid) throws Exception
	{  
		log("In syncLocalResources");
		String basedir = parseNull(env.getProperty("CACHE_FOLDER")) ;
		if(isprod)
		{
			basedir = parseNull(env.getProperty("PROD_CACHE_FOLDER")) ;
		}
		if(basedir.endsWith("/") == false) basedir += "/";
		
		Set rs = Etn.execute("select * from "+dbname+"sites where id = " + escape.cote(siteid));
		rs.next();
		String sitename = Util.getSiteFolderName(parseNull(rs.value("name")));

		String sourcesResourcesPath = parseNull(env.getProperty("COMMON_RESOURCES_PATH"));
		if(sourcesResourcesPath.endsWith("/") == false) sourcesResourcesPath += "/";
		sourcesResourcesPath += siteid + "/";

		String targetPath = basedir + sitename + "/";
		String targetFolder = "resources";
		
		String publishResourcesScript = parseNull(env.getProperty("SYNC_RESOURCES_FOLDER_SCRIPT"));
		
		log(publishResourcesScript + " " + sourcesResourcesPath + " " +  targetPath + " " + targetFolder);
				
		String cmd = publishResourcesScript + " " + sourcesResourcesPath + " " +  targetPath + " " + targetFolder;
		Process proc = Runtime.getRuntime().exec(cmd);
		int r = proc.waitFor();
		log("syncLocalResources r : " + r);
	}	
	
	private void createDirectories(String basedir, String fpath)  throws Exception
	{
		String[] ds = fpath.split("/");
		String path = "";
		for(String d : ds)
		{
			if(path.length() == 0) path = d;
			else path += "/" + d;
			File f = new File(basedir + path);
			
			if(!f.exists()) f.mkdir();			
		}
	}	
		
	public String getMenuPath(ClientSql Etn, String menuid)
	{
		String sendredirectlink  = parseNull(env.getProperty("SEND_REDIRECT_LINK"));
		String dbname = "";
		if(isprod) 
		{
			sendredirectlink = parseNull(env.getProperty("PROD_SEND_REDIRECT_LINK"));
			dbname = parseNull(env.getProperty("PROD_DB")) + ".";
		}
		
		if(!sendredirectlink.endsWith("/")) sendredirectlink += "/";
		
		String url = sendredirectlink;
		
		Set rs = Etn.execute("Select m.*, s.name as sitename from "+dbname+"site_menus m, "+dbname+"sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();

		if(isprod && parseNull(rs.value("production_path")).length() > 0) 
		{
			url += parseNull(rs.value("production_path"));
		}
		else
		{
			url += getMenuCacheFolder(Etn, menuid);
		}		
		return url;			
	}

	public String getMenuCacheFolder(ClientSql Etn, String menuid)
	{	
		String dbname = "";
		if(isprod) 
		{
			dbname = parseNull(env.getProperty("PROD_DB")) + ".";
		}
	
		Set rs = Etn.execute("Select m.*, s.name as sitename from "+dbname+"site_menus m, "+dbname+"sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();

		String path = Util.getSiteFolderName(parseNull(rs.value("sitename"))) + "/";
		path += parseNull(rs.value("lang")).toLowerCase() + "/";

		return path;
	}

	public String getActualUrl(String u) throws Exception
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

		if(queryParams.get("___mu") == null) return "";		
		return parseNull(new String(Base64.decode(queryParams.get("___mu"))));
	}

	public String getCharset(String contentType)
	{
		String charset = "UTF-8";//default value
		if(contentType.indexOf("charset=") > -1)
		{
			charset = contentType.substring(contentType.indexOf("charset=") + 8);
			if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
		}
//		log("Response charset::"+charset);
		return charset;		
	}

	public boolean isValidForCrawl(org.jsoup.nodes.Element ele, String menuid, String internalcalllink, String webappurl) throws Exception
	{
		//special case of image gallery added in products screen where href has image url so we dont have to crawl that as its already downloaded by cache
		if(parseNull(ele.className()).contains("etn_portal_gallery")) return false;

		//for new menu we have the login bar integrated in the menu so it has links which must not be crawled
		if(parseNull(ele.className()).contains("moringa-no-crawl"))
		{
			//log("found login links ... not crawling it");
			return false;
		}

		//we start crawling from homepage so ignore this as it leads to homepage again
		if(parseNull(ele.className()).contains("___portalhomepagelink")) return false;

		//special case where site is multi-lingual and we dont want other menu to be crawled from this menu
		if(parseNull(ele.className()).contains("___languagelink")) 
		{
			//log("found a language ... not crawling it");
			return false;
		}	
		if(parseNull(ele.className()).contains("____portal_rule_applied"))
		{
			return false;
		}

		String _r = parseNull(ele.attr("href"));
	
		if(_r.toLowerCase().startsWith("javascript:")) return false;
		if(_r.toLowerCase().startsWith("tel:")) return false;
		if(_r.equals("#")) return false;
		if(_r.startsWith("#")) return false;
		if(_r.length() == 0 || _r.equals("/")) return false;
		
		_r = parseNull(ele.absUrl("href"));
		if(_r.startsWith(internalcalllink))
		{
			//here we are checking call to process.jsp is for same menu for which we are building cache 
			//possibility of getting a different menu's page is for case of 404 pages where main menus page might be returned so we skip those urls
			if(_r.startsWith(internalcalllink + webappurl + "process.jsp"))
			{
				if(_r.contains("___mid=" + Base64.encode(menuid.getBytes("UTF-8")))) 
				{
//					log(_r + " is valid for crawling");
					return true;
				}
				else
				{
//					log(_r + " is NOT valid for crawling");	
					return false;
				}
			}
			else 
			{
//				log(_r + " is valid for crawling");
				return true;
			}
		}
		else 
		{
//			log(_r + " is NOT valid for crawling");
			return false;
		}
	}	

	private boolean isInRules(ClientSql Etn, String menuid, String href)
	{
		String proddb = env.getProperty("PROD_DB") + ".";
		
		boolean isinrules = false;
		Set rs = Etn.execute("select * from "+proddb+"menu_apply_to where menu_id = " + escape.cote(menuid));
		while(rs.next())
		{
			if(href.toLowerCase().startsWith(("http://" + parseNull(rs.value("prod_apply_to"))).toLowerCase()) || href.toLowerCase().startsWith(("https://" + parseNull(rs.value("prod_apply_to"))).toLowerCase()) )
			{
				isinrules = true;
				break;			
			}
		}
		return isinrules;
	}	 

	public String getExternalLink(String u, String menuid, ClientSql Etn, String pathprefix, String siteid, String cachedResourcesFolder) throws Exception
	{
		return getExternalLink(u, menuid, Etn, pathprefix, false, siteid, cachedResourcesFolder);
	}

	public String getExternalLink(String u, String menuid, ClientSql Etn, String pathprefix, boolean htmlEscaped, String siteid, String cachedResourcesFolder) throws Exception
	{
		u = parseNull(u);
		if(u.length() == 0) return "javascript:void(0)";
		
		String amp = "&";
		if(htmlEscaped) amp = "&amp;";
		
		if((u.toLowerCase().startsWith("http:") || u.toLowerCase().startsWith("https:")) && isInRules(Etn, menuid, u))
		{
			Map<String, String> fixedUrls = fixOldFormatUrls(u);
			if(fixedUrls != null)
			{
				log("Url before fix : " + u);
				if(fixedUrls.get("url") != null) u = fixedUrls.get("url");
				log("Url after fix : " + u);
			}			
			return env.getProperty("PROD_EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+amp+"___mu=" + Base64.encode(u.getBytes("UTF-8"));
		}
		else if(u.toLowerCase().startsWith("http:") == false && u.toLowerCase().startsWith("https:") == false)
		{			
			String finalResourcesUrl = parseNull(env.getProperty("COMMON_RESOURCES_URL"));
			if(finalResourcesUrl.endsWith("/") == false) finalResourcesUrl += "/";
			finalResourcesUrl += siteid + "/";
			
			if(isLocalResource(u))
			{
				return u.replace("http://127.0.0.1","").replace("http://localhost","").replace(finalResourcesUrl, cachedResourcesFolder);
			}
			
			return pathprefix + u;
		}
		return u;		
	}

	public String getCachedResourcesUrl(ClientSql Etn, String menuid)
	{
		String url = parseNull(env.getProperty("PROD_SEND_REDIRECT_LINK"));
		if(!url.endsWith("/")) url += "/";
		
		String proddb = env.getProperty("PROD_DB");
		
		Set rs = Etn.execute("select s.* from "+proddb+".sites s, "+proddb+".site_menus m where m.site_id = s.id and m.id = " + escape.cote(menuid));
		rs.next();
		
		url += Util.getSiteFolderName(parseNull(rs.value("name"))) + "/resources/";
		return url;
	}	

	private boolean isLocalResource(String url)
	{		
		if(parseNull(url).length() == 0) return false;
		
		String localResourcesUrl = parseNull(env.getProperty("COMMON_RESOURCES_URL"));
		if(localResourcesUrl.length() == 0) return false;//path not configured
		
		//incoming url can be an absolute or relative url
		if(url.startsWith("http://127.0.0.1" + localResourcesUrl) 
			|| url.startsWith("http://localhost" + localResourcesUrl)
			|| url.startsWith(localResourcesUrl)) return true;
		return false;
	}

	public Map<String, String> fixOldFormatUrls(String url)
	{
		try
		{
			if(parseNull(url).length() == 0 ) return null;
			
			Map<String, String> mp = null;
			if(url.toLowerCase().startsWith("http://127.0.0.1/") || url.toLowerCase().startsWith("http://localhost/"))
			{
				log("fixOldFormatUrls::Internal url : "+url);
				if(url.contains("_catalog/listproducts.jsp") || url.contains("_prodcatalog/listproducts.jsp"))
				{
					log("Its a listing screen url");
					if(url.indexOf("?") > -1)
					{
						Map<String, List<String>> mParams = getQueryParams(url);
						if(mParams != null && mParams.get("cat") != null && mParams.get("cat").isEmpty() == false)
						{
							url = url.substring(0, url.indexOf("?"));
							url += "?";
							url += "cat=" + mParams.get("cat").get(0);
							
							mp = new HashMap<String, String>();
							mp.put("url", url);
						}
					}				
				}			
				else if(url.contains("_catalog/product.jsp") || url.contains("_prodcatalog/product.jsp"))
				{
					log("Its a detail screen url");
					if(url.indexOf("?") > -1)
					{
						Map<String, List<String>> mParams = getQueryParams(url);
						if(mParams != null && mParams.get("id") != null && mParams.get("id").isEmpty() == false)
						{
							url = url.substring(0, url.indexOf("?"));
							url += "?";
							url += "id=" + mParams.get("id").get(0);
							
							mp = new HashMap<String, String>();
							mp.put("url", url);
						}
					}
				}			
			}
			
			return mp;
		}
		catch(Exception e)
		{
			log("Error in fixOldFormatUrls");
			e.printStackTrace();
			return null;
		}
	}	
	
	private Map<String, List<String>> getQueryParams(String url)
	{
		url = parseNull(url);
		if(url.length() == 0 ) return null;
		
		if(url.indexOf("?") < 0 ) return null;
		
		Map<String, List<String>> mParams = null;
		
		String u2 = url.substring(url.indexOf("?"));
			
		if(u2.trim().length() > 1)//u2 will always have ? in it so minimum length of u2 is 1
		{
			mParams = new HashMap<String, List<String>>();
			
			u2 = u2.substring(1);//first character is always ?

			String[] ps = u2.split("&");
			u2 = "";
			for(int i=0; i<ps.length; i++)
			{
				if(i > 0) u2 += "&";
				if(ps[i].indexOf("=") < 0) u2 += ps[i];
				else
				{
					String _pr = ps[i].substring(0, ps[i].indexOf("="));
					String _prv = "";
					if(ps[i].indexOf("=") == (ps[i].length()-1)) _prv = "";
					else _prv = ps[i].substring(ps[i].indexOf("=") + 1);

					if(mParams.get(_pr) == null) mParams.put(_pr, new ArrayList<String>());					
					mParams.get(_pr).add(_prv);
				}
			}
			
			return mParams;
		}
		else return null;
	}		
	
}