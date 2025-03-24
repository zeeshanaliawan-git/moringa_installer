<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.util.Base64, com.etn.beans.Contexte"%>
<%@ page import="java.io.FileOutputStream"%>
<%@include file="common.jsp"%>

<%!
	/**
	* This class is responsible to check if the cached page is loaded yesterday or before then we just 
	* mark it as cached 0 so that next hit to that page will reload it
	**/
	public class CacheChecker implements java.lang.Runnable
	{
		private String domain;
		private List<String> failedurls;
		private String eurl;
		private Contexte Etn;
		private String menuid;
		private HttpServletRequest request;

		public CacheChecker(String domain, String url, Contexte e, List<String> failedurls, String menuid, HttpServletRequest request)
		{
			this.domain = domain;
			this.eurl = url;
			this.Etn = e;
			this.failedurls = failedurls;
			this.menuid = menuid;
			this.request = request;
		}

		@Override
		public void run()  
		{
			String delfurls = "";

			for(String furl : failedurls)
			{
				Set _fu = Etn.execute("select * from failed_urls where menu_id = "+escape.cote(menuid)+" and failed_url = "+escape.cote(furl)+" and domain = "+escape.cote(domain)+" and encoded_url = " + escape.cote(eurl));
				if(_fu.rs.Rows > 0) Etn.executeCmd("update failed_urls set attempt = attempt + 1 where menu_id = "+escape.cote(menuid)+" and failed_url = "+escape.cote(furl)+" and domain = "+escape.cote(domain)+" and encoded_url = " + escape.cote(eurl));
				else Etn.executeCmd("insert into failed_urls (domain, encoded_url, failed_url, menu_id) values ("+escape.cote(domain)+","+escape.cote(eurl)+","+escape.cote(furl)+","+escape.cote(menuid)+")");
				if(delfurls.length() > 0) delfurls += " and ";
				delfurls += " failed_url <> " + escape.cote(furl);
			}
			if(delfurls.length() > 0)
			{
				Etn.executeCmd("delete from failed_urls where menu_id = "+escape.cote(menuid)+" and domain = "+escape.cote(domain)+" and encoded_url = "+escape.cote(eurl)+" and " + delfurls);
			}	

	
		}		
	}

	/**
	* This class is responsible to save the page contents on disk and then check if we need to cache it or no
	*
	**/
	public class Cacher 
	{
		private String eurl;
		private String contents;
		private Contexte Etn;
		private String basedir;
		private String contenttype;
		private List<String> failedurls;
		private String domain;
		private List<String> recacheurls;
		private String menuidapplied;
		private String menuruleid;
		private String filename;
		private boolean ishtml;

		private HttpServletRequest request;
		private boolean dynamicPage ;
		private boolean usefilename;
		private boolean internalcall;
		private String relativecachedpath;//relative to sites folder	
		private String cachedpageid;	
		private String cachedpageuuid;	
		private String sub_page_type_level3 = "";
		private String resourceFileExtension = "";
		private boolean useWebmasterUrl = false;
		private String filePath = "";
		private String menuExternalPath = "";
		private String cacheFolder = "";

		private void init(String domain, String eurl, Contexte Etn, String basedir, String contenttype, List<String> failedurls, List<String> recacheurls, String menuidapplied, String menuruleid, String filename, boolean ishtml, HttpServletRequest request, boolean dynamicPage, boolean usefilename, boolean internalcall, String relativecachedpath, String sub_page_type_level3, String resourceFileExtension, boolean useWebmasterUrl, String filePath, String menuExternalPath, String cacheFolder)
		{
			this.domain = domain;
			this.eurl = eurl;
			this.Etn = Etn;
			this.basedir = basedir;
			this.contenttype = contenttype;
			this.failedurls = failedurls;
			this.recacheurls = recacheurls;
			this.menuidapplied = menuidapplied;
			this.menuruleid = menuruleid;
			this.filename = filename;
			this.ishtml = ishtml;
			this.request = request;
			this.dynamicPage = dynamicPage;
			this.usefilename = usefilename;
			this.internalcall = internalcall;
			this.relativecachedpath = relativecachedpath;
			this.sub_page_type_level3 = sub_page_type_level3;
			this.resourceFileExtension = resourceFileExtension;
			this.useWebmasterUrl = useWebmasterUrl;
			this.filePath = filePath;
			this.menuExternalPath = menuExternalPath;
			this.cacheFolder = cacheFolder;
		}

		public Cacher(String domain, String eurl, Contexte Etn, String basedir, String contenttype, List<String> failedurls, List<String> recacheurls, String menuidapplied, String menuruleid, String filename, boolean ishtml, HttpServletRequest request, boolean dynamicPage, boolean usefilename, boolean internalcall, String relativecachedpath, String sub_page_type_level3, boolean useWebmasterUrl, String filePath, String menuExternalPath, String cacheFolder)
		{
			init(domain, eurl, Etn, basedir, contenttype, failedurls, recacheurls, menuidapplied, menuruleid, filename, ishtml, request, dynamicPage, usefilename, internalcall, relativecachedpath, sub_page_type_level3, "", useWebmasterUrl, filePath, menuExternalPath, cacheFolder);
		}

		public Cacher(String domain, String eurl, Contexte Etn, String basedir, String contenttype, List<String> failedurls, List<String> recacheurls, String menuidapplied, String menuruleid, String filename, boolean ishtml, HttpServletRequest request, boolean dynamicPage, boolean usefilename, boolean internalcall, String relativecachedpath, String sub_page_type_level3, String resourceFileExtension, String filePath, String menuExternalPath, String cacheFolder)
		{
			init(domain, eurl, Etn, basedir, contenttype, failedurls, recacheurls, menuidapplied, menuruleid, filename, ishtml, request, dynamicPage, usefilename, internalcall, relativecachedpath, sub_page_type_level3, resourceFileExtension, false, filePath, menuExternalPath, cacheFolder);
		}

		public String cache()  
		{
			String ret = "";
			try
			{
				if(recacheurls != null && menuidapplied.length() > 0 && !"-1".equals(menuidapplied))
				{
					for(String ru : recacheurls)
					{
//						Etn.executeCmd("update cached_pages set cached = 0  where coalesce(filename, '') = '' and encoded_url = " + escape.cote(ru) + " and menu_id = "+escape.cote(menuidapplied)+" ");
//						Etn.executeCmd("update cached_pages set cached = 0  where coalesce(filename, '') = '' and hex_eurl = hex(sha(" + escape.cote(ru) + ")) and menu_id = "+escape.cote(menuidapplied)+" ");
					}
				}

				//insert into db
				String durl = "";
				try
				{
					String anyparams = "";
					if(eurl.indexOf("?") > -1) 
					{
						anyparams = eurl.substring(eurl.indexOf("?"));
						eurl = eurl.substring(0, eurl.indexOf("?"));
					}
					durl = new String(Base64.decode(eurl));
					if(parseNull(anyparams).length() > 0) 
					{
						eurl = eurl + anyparams;		
						durl = durl + anyparams;					
					}
				}
				catch(Exception e) 
				{
					e.printStackTrace();		
				} 		

				String cache = "1";
				String siteid = "1";
				String menuversion = "v1";
				//check global cache
				Set rscc = Etn.execute("select m.menu_version, s.id as site_id from sites s, site_menus m where s.id = m.site_id and m.id = "+escape.cote(menuidapplied));
				if(rscc.next()) 
				{
					menuversion = parseNull(rscc.value("menu_version"));
				}

				if(menuidapplied.length() == 0 || "-1".equals(menuidapplied)) 
				{
					cache = "0";//as we didnt find any applicable menu we are not going to cache the pages
				}

				if("1".equals(cache))//check further rules for this url
				{
					String qry = "select a.* from menu_apply_to a where id = " + escape.cote(menuruleid);
					if("V2".equalsIgnoreCase(menuversion)) qry = "select a.* from sites_apply_to a where id = " + escape.cote(menuruleid);
					Set menurules = Etn.execute(qry);
					if(menurules.next()) 
					{
						cache = parseNull(menurules.value("cache"));
					}
					if(cache.length() == 0) cache = "0";
				}

				int crawledattempts = 0;
				String crawledattemptsql = "";
				if(internalcall) 
				{
					crawledattempts = 1;	
					crawledattemptsql = " crawled_attempts = (crawled_attempts + 1), ";
				}
				

				int r = Etn.executeCmd("insert into cached_pages (ptitle, is_url_active, crawled_attempts, encoded_url, url, cached, last_loaded_on, content_type, menu_id, hex_eurl) values ("+escape.cote(sub_page_type_level3)+",1, "+crawledattempts+","+escape.cote(eurl)+","+escape.cote(durl)+","+escape.cote(cache)+",now(), "+escape.cote(contenttype)+", "+escape.cote(menuidapplied)+",hex(sha("+escape.cote(eurl)+")) ) " +
					" on duplicate key update "+crawledattemptsql+" ptitle = "+escape.cote(sub_page_type_level3)+", is_url_active = 1, refresh_now = 0, cached = "+escape.cote(cache)+",  last_loaded_on = now(), content_type = "+escape.cote(contenttype)+" ");

				Etn.executeCmd("delete from failed_urls where menu_id = "+escape.cote(menuidapplied)+" and domain = "+escape.cote(domain)+" and encoded_url = " + escape.cote(eurl));

				for(String furl : failedurls)
				{
					Etn.executeCmd("insert into failed_urls (domain, encoded_url, failed_url, menu_id) values ("+escape.cote(domain)+","+escape.cote(eurl)+","+escape.cote(furl)+", "+escape.cote(menuidapplied)+")");
				}

				Set __rs = Etn.execute("select * from cached_pages where menu_id = "+escape.cote(menuidapplied)+" and hex_eurl = hex(sha(" + escape.cote(eurl) + ")) ");
				if(__rs.next())
				{
					//insert/update path in new table ... we have separate table as we will be updating the paths at times so dont want to block the cache table
					String finalUrl = menuExternalPath + relativecachedpath.replace(cacheFolder,"");
					Etn.executeCmd("insert into cached_pages_path (id, file_path, file_url) values ("+escape.cote(__rs.value("id"))+","+escape.cote(relativecachedpath)+","+escape.cote(finalUrl)+") on duplicate key update file_url = "+escape.cote(finalUrl)+", file_path = "+escape.cote(relativecachedpath));

					String urlfileid = __rs.value("id");
					cachedpageid = __rs.value("id");
					cachedpageuuid = __rs.value("cache_uuid");
			
					if(ishtml) 
					{
						if(useWebmasterUrl)
						{
							Etn.executeCmd("update cached_pages set filename = "+escape.cote(filename)+" where id = " + escape.cote(__rs.value("id")));
							urlfileid = filename;
						}
						else if(parseNull(__rs.value("filename")).length() == 0) 			
						{
							if(filename.length() > 0) urlfileid = filename.replace(" ","-") + "-" + urlfileid;
							urlfileid = urlfileid + ".html";
							urlfileid = urlfileid.toLowerCase();
							com.etn.util.Logger.debug("cache.jsp"," Filename in db is empty. New file name is " + urlfileid );
							//for same encoded url we dont want to change the filename otherwise there will be multiple files physically 
							//on disk for same html.
							Etn.executeCmd("update cached_pages set filename = "+escape.cote(urlfileid)+" where id = " + escape.cote(__rs.value("id")));
						}
						else urlfileid = parseNull(__rs.value("filename")).toLowerCase();

						if(!request.getMethod().equalsIgnoreCase("GET") || dynamicPage)
						{
							//dynamic requests as post must be saved with a unique name everytime							
							int i1 = Etn.executeCmd("insert ignore into dynamic_pages(cached_page_id) values("+escape.cote(__rs.value("id"))+")");
							Etn.executeCmd("update cached_pages set cached = 0 where id = " + __rs.value("id"));
							urlfileid = urlfileid.substring(0, urlfileid.indexOf(".html")) + "-" + i1 + ".html";

							this.dynamicPage = true;
						}

						//we are going to set the menu language in session
						Set ___r1 = Etn.execute("select coalesce(l.langue_id,'1') as lang from site_menus s left outer join language l on l.langue_code = s.lang where s.id = " + escape.cote(menuidapplied));
						if(___r1.next())
						{
							Etn.lang = (byte)Integer.parseInt(___r1.value("lang"));
						}

					}
					else 
					{
						if(usefilename)
						{
							com.etn.util.Logger.debug("cache.jsp","---- " + filename);
							Etn.executeCmd("update cached_pages set filename = "+escape.cote(filename)+" where id = " + escape.cote(__rs.value("id")));
						}
						else Etn.executeCmd("update cached_pages set filename = null, res_file_extension = "+escape.cote(resourceFileExtension)+" where id = " + escape.cote(__rs.value("id")));
					}

					ret = urlfileid;
				}
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
			return ret;
		}		

		public String getCachedPageId()
		{
			return this.cachedpageid;
		}		

		public String getCachedPageUuid()
		{
			return this.cachedpageuuid;
		}		

		public void saveFileToDisk(String contents, String urlfileid) 
		{
			FileOutputStream fout = null;
			try
			{
				String durl = "";
				try
				{
					String anyparams = "";
					if(eurl.indexOf("?") > -1) 
					{
						anyparams = eurl.substring(eurl.indexOf("?"));
						eurl = eurl.substring(0, eurl.indexOf("?"));
					}
					durl = new String(Base64.decode(eurl));
					if(parseNull(anyparams).length() > 0) 
					{
						eurl = eurl + anyparams;		
						durl = durl + anyparams;					
					}
				}
				catch(Exception e) 
				{
					e.printStackTrace();		
				} 		

				if(this.resourceFileExtension != null || this.resourceFileExtension.length() > 0) urlfileid = urlfileid + this.resourceFileExtension;


				com.etn.util.Logger.debug("cache.jsp","Saving cached file to disk ");
				com.etn.util.Logger.debug("cache.jsp","UseWebmasterUrl : " + useWebmasterUrl);
				com.etn.util.Logger.debug("cache.jsp","BaseDir : " + basedir);
				com.etn.util.Logger.debug("cache.jsp","File : " + filePath + urlfileid);

//				String localpath = getLocalPath(Etn, durl);
//				if(!localpath.endsWith("/")) localpath = localpath + "/";					


				com.etn.util.Logger.debug("cache.jsp","----------- url : " + durl + " path : " + filePath);
				File dfile = new File(basedir + filePath);
				if(!dfile.exists()) createDirectories(basedir, filePath);		
				String fpath = basedir + filePath;

				if(this.dynamicPage) Etn.executeCmd("insert into purge_pages (page_path) values ("+escape.cote(fpath + urlfileid)+") "); 

				fout = new FileOutputStream (fpath + urlfileid);

				String charset =  "UTF-8";
				if(contenttype.indexOf("charset=") > -1)
				{
					charset = contenttype.substring(contenttype.indexOf("charset=") + 8);
					if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
				}			
				fout.write(contents.getBytes(charset));
				fout.flush();	
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
			finally
			{
				if(fout != null) try { fout.close(); } catch (Exception e) {}
			}
		}
	}
%>