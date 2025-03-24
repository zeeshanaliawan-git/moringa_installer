package com.etn.moringa;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.Client.Impl.ClientDedie;

import java.util.*;

public class CacheCleanup
{
	private ClientSql Etn;
	private Properties env;
	private boolean isprod;
	private boolean debug;
	private String dbname = "";

	public CacheCleanup(ClientSql Etn, Properties env, boolean isprod, boolean debug) throws Exception
	{
		this.Etn = Etn;
		this.env = env;
		this.isprod = isprod;
		this.debug = debug;
		if(isprod)
		{
			dbname = env.getProperty("PROD_DB") + ".";
		}
	}

	private void log(String m)
	{
		if(!debug) return;		
		logE(m);
	}

	private void logE(String m)
	{
		if(isprod) m = "CacheCleanup::" + m;
		else m = "Preprod CacheCleanup::" + m;
		System.out.println(m);
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public void start(String menuid) 
	{
		start(menuid, null);
	}
	
	public void start(String menuid, List<String> targetCachedPageIds) 
	{
		log("GOING TO CHECK INACTIVE URLS FOR MENU ID : " + menuid);
	
		try
		{
			CacheUtil cacheUtil = new CacheUtil(env, isprod, debug);

			String basedir = parseNull(env.getProperty("CACHE_FOLDER"));

			if(isprod)
			{
				basedir = parseNull(env.getProperty("PROD_CACHE_FOLDER"));
			}

			String menuCacheFolder = cacheUtil.getMenuCacheFolder(Etn, menuid);

			List<String> allActivePages = new ArrayList<String>();
			Set rs = Etn.execute("select c.*, cp.file_path from "+dbname+"cached_pages c, "+dbname+"cached_pages_path cp where cp.id = c.id and c.is_url_active = 1 and coalesce(c.filename,'') <> '' and c.menu_id = " + menuid );				
			while(rs.next())
			{
//				log("page is active : " + rs.value("file_path") + rs.value("filename"));
				allActivePages.add(rs.value("file_path") + rs.value("filename"));
			}

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

			//as the webmaster can give the paths for cached page, there can be cases where two different cached url has same out put path			
			//this will be null when complete site is being cached and only in then case we should look in db for urls which are no more active and rename those

			//ideally this is not possible but due to our old versions where catalog urls has many parameters like bt, lang etc this can occurr in some production
			//sites in which such urls still exists ... this means that dev_prodcatalog/product.jsp?id=1 will be cached at same path as dev_prodcatalog/product.jsp?id=1&bt=b2c
			//as they both are exactly same content ... so we have to handle these cases for which we fill-up allActivePages and before deleting non-active pages we check
			//if any other url has same output path

			//here we check for urls which were active last time but not active any more so we will delete those pages
			String qry = "select c.*, cp.file_path from "+dbname+"cached_pages c, "+dbname+"cached_pages_path cp where cp.id = c.id and c.menu_id = " + menuid + " and c.last_time_url_active = 1 and c.is_url_active = 0 and coalesce(c.filename,'') <> '' ";
			if(parseNull(inClause).length() > 0)//check for individual items being cached
			{
				qry += " and c.id in ("+inClause+") ";
			}
			log("qry1:"+qry);

			Set rsrm = Etn.execute(qry);
			while(rsrm.next())
			{
				String inactivePath = rsrm.value("file_path") + rsrm.value("filename");	
				renamePage(basedir, allActivePages, inactivePath, menuid);
			}

			//here we are going to check if webmaster changes the final url of a page, then we have to rename the old one as it still exists on the disk
			qry = "select c.*, cp.file_path, cp.file_url, cp.published_url, cp.published_menu_path from "+dbname+"cached_pages c, "+dbname+"cached_pages_path cp where cp.id = c.id and coalesce(c.filename,'') <> '' and c.menu_id = " + escape.cote(menuid) + " and c.is_url_active = 1 ";
			if(parseNull(inClause).length() > 0)//check for individual items being cached
			{
				qry += " and c.id in ("+inClause+") ";
			}
			log("qry2:"+qry);
			Set rs2 = Etn.execute(qry);
			while(rs2.next())
			{
				String oldMenuPath = parseNull(rs2.value("published_menu_path"));
				String oldurl = parseNull(rs2.value("published_url"));
				String newurl = parseNull(rs2.value("file_url")) + parseNull(rs2.value("filename"));

				//urls are different so we must delete the old page from cache
				if(isprod && newurl.length() > 0 && oldurl.length() > 0 && !newurl.equals(oldurl))
				{
					log("Old and new urls are different " + oldurl + " to " + newurl);
					//replacing menupath will give the relative path of page in cache folder
					oldurl = oldurl.replace(oldMenuPath,"");
					String inactivePath = menuCacheFolder + oldurl;
					renamePage(basedir, allActivePages, inactivePath, menuid);
				}				
			}

			try
			{
				//after renaming not used .html files to .html_inactive we delete them
				String cmd = env.getProperty("DELETE_INACTIVE_HTML_FILES_SCRIPT") + " " + basedir ;
				Process proc = Runtime.getRuntime().exec(cmd);
				int r = proc.waitFor();					
			}	
			catch(Exception e)
			{
				Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheCleanup::Error deleting inactive files') ");
				e.printStackTrace();
			}
			log("Cache cleanup done");
		}
		catch(Exception e)
		{
			logE("Error in cache cleanup");
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheCleanup::Error while cleanup cache') ");
			e.printStackTrace();
		}

	}	

	private void renamePage(String basedir, List<String> allActivePages, String inactivePath, String menuid)
	{
		log("Path is inactive : " + inactivePath);
		if(!allActivePages.contains(inactivePath))
		{
			String _path = basedir + inactivePath;
			String _newpath = _path + "_inactive";
			log("renaming file " + _path + " to " + _newpath);
						
			try
			{	
				String cmd = env.getProperty("RENAME_FILE_SCRIPT") + " " + _path + " " + _newpath;
				Process proc = Runtime.getRuntime().exec(cmd);
				int r = proc.waitFor();					
				log("result :" + r + " for " + cmd);
			}	
			catch(Exception e)
			{
				logE("Error renmaing page");
				Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'CacheCleanup::Error while cleanup cache') ");				
				e.printStackTrace();
			}
		}
		else
		{
			log("Path is still in used by another cached url");
		}
	}
}