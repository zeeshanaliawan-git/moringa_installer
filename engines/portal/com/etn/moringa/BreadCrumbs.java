package com.etn.moringa;

import java.io.*;
import java.net.*;

import java.util.*;

import com.etn.util.ItsDate;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.jsoup.*;
import com.etn.moringa.Node;

public class BreadCrumbs 
{ 

	private Properties env;
	private ClientSql Etn;
	private boolean isprod;
	private boolean debug;

	private boolean isPublishing = false;
	String dbname = "";

	private void init(ClientSql Etn, Properties env, boolean isprod, boolean debug) throws Exception
	{
		this.Etn = Etn;
		this.env = env;
		this.debug = debug;		
		this.isprod = isprod;

		if(this.isprod) dbname = env.getProperty("PROD_DB") + ".";
	}	

	public BreadCrumbs(ClientSql Etn, Properties env, boolean isprod, boolean debug) throws Exception
	{
		init(Etn, env, isprod, debug);
	}

	public BreadCrumbs(ClientSql Etn, Properties env, boolean isprod, boolean debug, boolean isPublishing) throws Exception
	{
		init(Etn, env, isprod, debug);
		this.isPublishing = isPublishing;
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
		if(isprod) m = "Prod BreadCrumbs::" + m;
		else m = "Preprod BreadCrumbs::" + m;
		System.out.println(m);
	}

	private boolean hasHomepage(String path)
	{
		if(path == null || path.length() == 0 || !path.contains(",")) return false;
		String[] nodeids = path.split(",");
		for(String nid : nodeids)
		{
			if("0".equals(nid)) return true;
		}
		return false;
	}

	private int countCommas(String str)
	{		
		char comma = ',';
		int count = 0; 
		
		for (int i = 0; i < str.length(); i++) 
		{
			if (str.charAt(i) == comma) count++;
		}
		return count;
	}

	private void setParents(Map<String, Node> nodes, String hppageid)
	{
		//we have cases where a node has its parent but the parent does not have its parent
		//this can only occur where a page A is linked only from 404 page in which case page A will not
		//have record in crawler_paths table but page B has only 1 parent which is page A and page B has record
		//in crawler_paths. So in thise case page A is not there in nodes map so we will add it at runtime
		Map<String, Node> extraNodes = new HashMap<String, Node>();		
		for(String nodeid : nodes.keySet())
		{
			Node node = nodes.get(nodeid);
			if(node.ishomepage)
			{
				node.parents = null;
			}
			else if(node.is404)
			{
				node.parents = null;
			}			
			else 
			{
				node.parents = new ArrayList<Node>();
				if(node.ismenulink)
				{
					node.parents.add(nodes.get(hppageid));
				}
				if(!node.parentpageids.isEmpty())
				{
					for(int i=0; i<node.parentpageids.size(); i++)
					{
						if(node.ismenulink && (node.ispagelinks.get(i)).booleanValue() == false) continue;
						String ppid = node.parentpageids.get(i);
						if(node.ismenulink && ppid.equals(hppageid)) continue;//we have already added homepage explicity for menu links
						if(nodes.get(ppid) != null) node.parents.add(nodes.get(ppid));
						else if(extraNodes.get(ppid) != null) node.parents.add(extraNodes.get(ppid));
						else
						{
							Node newNode = new Node();
							newNode.pageid = ppid;
							newNode.extraNode = true;
							newNode.parents = new ArrayList<Node>();
							newNode.parentpageids = new ArrayList<String>();
							node.parents.add(newNode);
							extraNodes.put(ppid, newNode);							
						}						
					}					
				}
			}
		}
		for(String pid : extraNodes.keySet())
		{
			if(nodes.get(pid) == null) nodes.put(pid, extraNodes.get(pid));
		}
		
	}

	private void traverse(List<List<String>> paths, Node currentNode, Node homepageNode, List<String> alreadyTraversed, int level, List<String> origNodeParents)
	{
//		log("Traverse : " + currentNode.pageid);
//		for(String s : alreadyTraversed) log(s);
		//for deep pages we just go upto 5 links and then add the homepage in path
		if(level > 4)
		{
			alreadyTraversed.add(homepageNode.pageid);
			List<String> path = new ArrayList<String>();
			for(String s : alreadyTraversed)
			{
				path.add(s);
			}
			//path must have more than 1 nodes otherwise it means its just node of that page itself
			if(path != null && path.size() > 1) paths.add(path);		
		}
		else
		{
			alreadyTraversed.add(currentNode.pageid);

			if(currentNode.parents != null && !currentNode.parents.isEmpty())
			{
				//new check where we make sure if the current node is already in list of direct parent of original node
				//then we ignore this path to avoid too many paths 
				if(level > 1 && origNodeParents != null && origNodeParents.contains(currentNode.pageid)) return;

				level++;
				for(Node parentNode : currentNode.parents)
				{
					if(!alreadyTraversed.contains(parentNode.pageid))
					{
						traverse(paths, parentNode, homepageNode, alreadyTraversed, level, origNodeParents);
						alreadyTraversed.remove(alreadyTraversed.size() - 1);
					}				
				}
			}
			else
			{
				List<String> path = new ArrayList<String>();
				for(String s : alreadyTraversed)
				{
					path.add(s);
				}
				//path must have more than 1 nodes otherwise it means its just node of that page itself
				if(path != null && path.size() > 1) paths.add(path);
			}
		}
	}

	private List<List<String>> getPaths(Map<String, Node> nodes, Node node, String hppageid)
	{
		if(node == null) return null;

		List<List<String>> paths = new ArrayList<List<String>>();
		List<String> alreadyTraversed = new ArrayList<String>();

//		log(node.pageid);
		traverse(paths, node, nodes.get(hppageid), alreadyTraversed,0, node.getParentIds());
		return paths;
	}

	//this function will generate default breadcrumbs for the pages which are active and have no breadcrumbs set in the db yet
	//it will then update the shortest breadcrumb in the db for those pages
	@SuppressWarnings("unchecked")
	public boolean generate(String menuid) 
	{
		int auditid = 0;
		try
		{
			log("--------- "+new Date()+" start generating for menu id : " + menuid);

			auditid = Etn.executeCmd("insert into "+dbname+"crawler_audit (menu_id, start_time, status, action) values ("+escape.cote(menuid)+",now(),1, 'Generating breadcrumbs') ");

			Map<String, Node> nodes = new LinkedHashMap<String, Node>();
			String hppageid = "";
			
			Set rs1 = Etn.execute("Select * from "+dbname+"site_menus where id = " + escape.cote(menuid));
			rs1.next();
			String published404CachedId = parseNull(rs1.value("published_404_cached_id"));

			Set rs = Etn.execute("select distinct crp.page_id, cp.ptitle, cp.filename, cpp.breadcrumb, cpp.published_url, cpp.breadcrumb_changed, max(crp.is_menu_link) is_menu_link, min(crp.page_level) page_level, max(crp.is_404) is_404 from "+dbname+"crawler_paths crp, "+dbname+"cached_pages cp, "+dbname+"cached_pages_path cpp where crp.menu_id = cp.menu_id and crp.page_id = cp.id and cpp.id = cp.id and crp.menu_id = "+escape.cote(menuid)+" group by crp.page_id, cp.ptitle, cp.filename, cpp.breadcrumb, cpp.published_url, cpp.breadcrumb_changed order by is_404, page_level, is_menu_link desc, crp.page_id");
			while(rs.next())
			{
				Node node = new Node();
				node.pageid = parseNull(rs.value("page_id"));
				//a bad condition where a page is homepage and also a link from menu ... will never happen in reality but lets handle it ... so preference of homepage is more
				if("0".equals(rs.value("page_level"))) node.ishomepage = true;
				else if("1".equals(rs.value("is_menu_link"))) node.ismenulink = true;

				if(node.ishomepage) 
				{
					hppageid = node.pageid;
					node.ptitle = "Home";
				}
				else node.ptitle = parseNull(rs.value("ptitle"));


				node.is404 = "1".equals(rs.value("is_404"));
				node.pagelevel = parseNull(rs.value("page_level"));
				node.breadcrumbJson = parseNull(rs.value("breadcrumb"));
				
				node.parentpageids = new ArrayList<String>();
				node.ispagelinks = new ArrayList<Boolean>();

				Set rs2 = Etn.execute("select case when crp.page_level = 0 then 0 when crp.is_404 = 1 then 0 else crp.parent_page_id end parent_page_id " + 
						", crp.is_page_link from "+dbname+"crawler_paths crp where crp.page_id = " + parseNull(rs.value("page_id")));

				while(rs2.next())
				{
					String ppid = parseNull(rs2.value("parent_page_id"));
					
					if(!"0".equals(ppid) && !node.parentpageids.contains(ppid) && !ppid.equals(published404CachedId)) 
					{						
						node.parentpageids.add(ppid);
						String ispl = parseNull(rs2.value("is_page_link"));
						if(ispl.equals("1")) node.ispagelinks.add(new Boolean(true)); 
						else node.ispagelinks.add(new Boolean(false)); 
					}
				}
				
	//			log(node.pageid + " : " + parentpageids + " : " + ispagelinks);
	//			log("putting : " + node.pageid);
				nodes.put(node.pageid, node);
				
				//a new case where a page was a menu link before and later made homepage
				//the breadcrumb due to previous crawl existed so it was showing on when the page was changed to homepage
				//so we must always clear breadcrumb of homepage and 404 node
				if(node.ishomepage || node.is404)
				{
					Etn.executeCmd("update "+dbname+"cached_pages_path set breadcrumb ='' where id = " + node.pageid );
				}
			}

			setParents(nodes, hppageid);
			
			for(String pageid : nodes.keySet()) 
			{
				Node node = nodes.get(pageid);
				//we are not going to set default breadcrumb for homepage/404 page
				if(node.ishomepage || node.is404 || node.extraNode) continue;

				List<List<String>> paths = getPaths(nodes, node, hppageid);
				if(paths != null)
				{
					List<String> allPossiblePaths = new ArrayList<String>();
					log("--------------- Path for node : " + node.pageid + "------------------");
					for(List<String> currentPath : paths)
					{
						if(currentPath == null || currentPath.isEmpty()) continue;
						String newPath = "";
						
						for(int j=(currentPath.size() - 1); j>=0; j--)
						{
							Node cnode = nodes.get(currentPath.get(j));
							if(cnode.ishomepage) newPath += "0,";
							else newPath += currentPath.get(j)+ ",";
						}
						allPossiblePaths.add(newPath);
//						log(newPath);
					}

					boolean pathFound = false;
					//check if last selected path exists or not .. if not reset the breadcrumb 
					if(node.breadcrumbJson.length() > 0)
					{
						System.out.println("Node : " + pageid + " : " + node.breadcrumbJson);
						try
						{
							List<Object> br = new com.google.gson.Gson().fromJson(node.breadcrumbJson, ArrayList.class);
							String lastBrString = "";
							for(int j=0; j<br.size(); j++)
							{
								Map<String, String> map = (Map<String, String>)br.get(j);
								if(map.get("ishome").equals("1")) lastBrString += "0,";
								else lastBrString += map.get("pageid") + ",";
							}	
							log("Old breadcrumb path : " + lastBrString);						
	
							for(String newPath : allPossiblePaths)
							{
								if(newPath.equals(lastBrString)) 
								{
									log("Path still active");
									pathFound = true;
									break;
								}
							}			
						}
						catch(Exception e )
						{
							Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'BreadCrumbs::Error reading breadcrumb json') ");
							logE("ERROR:: node " + pageid + " : " + parseNull(node.breadcrumbJson));
							logE(e.getMessage());
							e.printStackTrace();
						}
					}
					if(!pathFound)//last path not active anymore or there was none set before
					{
						String bestPath = null;
						for(String newPath : allPossiblePaths)
						{
							if(bestPath == null) bestPath = newPath;
							//if newpath has homepage link in it then preference will be given to it irrespective of its size
							else if(!hasHomepage(bestPath) && hasHomepage(newPath)) bestPath = newPath;
							//newpath is short and has homepage in it so preferablely we use this path
							else if(countCommas(bestPath) > countCommas(newPath) && hasHomepage(newPath)) bestPath = newPath;
							//newpath is short and previous path and new path both dont have homepage in it so we use new path 
							else if(countCommas(bestPath) > countCommas(newPath) && !hasHomepage(bestPath) && !hasHomepage(newPath)) bestPath = newPath;
						}
						if(bestPath != null)
						{
							String[] bestPathNodeIds = bestPath.split(",");
							String json = "[";
							
							for(int i=0; i < bestPathNodeIds.length; i++) 
							{
								if(i != 0) json += ",";
								
								if("0".equals(bestPathNodeIds[i])) json += "{\"ishome\":\"1\",\"selected\":\"1\"}";
								else
								{
									Node pathnode = nodes.get(bestPathNodeIds[i]);
									if(pageid.equals(pathnode.pageid)) json += "{\"ishome\":\"0\",\"pageid\":\""+pageid+"\",\"selected\":\"1\",\"destpage\":\"1\"}";
									else json += "{\"ishome\":\"0\",\"pageid\":\""+pathnode.pageid+"\",\"selected\":\"1\"}";
								}
							}
							json += "]";
							log("Use default path : " + json);
							Etn.executeCmd("update "+dbname+"cached_pages_path set breadcrumb = "+escape.cote(json)+" where id = " + escape.cote(pageid));
						}
					}//if !pathfound

				}
			}

			log("--------- "+new Date()+" BreadCrumbs end generate defaults for menu id : " + menuid);
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'BreadCrumbs::Error generating breadcrumbs') ");
			logE("ERROR::BR::generate::"+e.getMessage());
			e.printStackTrace();
			return false;
		}
		finally
		{
			if(auditid > 0) Etn.executeCmd("update "+dbname+"crawler_audit set end_time = now(), status = 2 where id = " + auditid); 			
		}
		return true;
	}

	public boolean updateHtmls(String menuid)
	{
		int auditid = 0;

		try
		{
			auditid = Etn.executeCmd("insert into "+dbname+"crawler_audit (menu_id, start_time, status, action) values ("+escape.cote(menuid)+",now(),1, 'Updating breadcrumbs') ");
			
			//table crawler_paths is always cleared before publish so will always have active pages in it
			String q = " select distinct crp.page_id, cpp.breadcrumb, cp.menu_id " + 
				" from "+dbname+"cached_pages cp, "+dbname+"cached_pages_path cpp, "+dbname+"crawler_paths crp " + 
				" where cpp.id = cp.id and crp.page_id = cp.id and crp.menu_id = cp.menu_id and cp.menu_id = "+escape.cote(menuid);
	
			//isPublishing will be false when someone changes breadcrumb from admin screen and clicks for publish breadcrumbs
			//isPublishing true means the complete menu is being published
			if(!this.isPublishing)
			{
				//we only pick those pages for which the br is updated from screen
				q += " and breadcrumb_changed = 1 ";
			}
			
			Set rs = Etn.execute(q);
	
			List<String> pages = new ArrayList<String>();

			while(rs.next())
			{
				pages.add(rs.value("page_id"));
			}
			this.updateHtmls(menuid, pages);
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'BreadCrumbs::Error updating htmls') ");
			logE("ERROR::BR::updateHtmls::"+e.getMessage());
			e.printStackTrace();
			return false;
		}
		finally
		{
			if(auditid > 0) Etn.executeCmd("update "+dbname+"crawler_audit set end_time = now(), status = 2 where id = " + auditid); 			
		}
		return true;
	}

	@SuppressWarnings("unchecked")
	public void updateHtmls(String menuid, List<String> pageids) throws Exception
	{
		if(pageids == null) return;

		CacheUtil cacheutil = new CacheUtil(env, isprod, debug);

		String basedir = parseNull(env.getProperty("CACHE_FOLDER"));
		String menuresourcesurl = env.getProperty("PREPROD_MENU_RESOURCES_URL");

		if(isPublishing) basedir = parseNull(env.getProperty("PUBLISHER_BASE_DIR")) + parseNull(env.getProperty("PUBLISHER_DOWNLOAD_PAGES_FOLDER"));

		if(this.isprod) 
		{
			menuresourcesurl = env.getProperty("PROD_MENU_RESOURCES_URL");

			basedir = parseNull(env.getProperty("PROD_CACHE_FOLDER"));
			if(isPublishing) basedir = parseNull(env.getProperty("PUBLISHER_PROD_BASE_DIR")) + parseNull(env.getProperty("PUBLISHER_PROD_DOWNLOAD_PAGES_FOLDER"));
		}

		//System.out.println("isProd : " + isprod + ", isPublishing : " + isPublishing + ", Basedir is = " + basedir);
		
		Set rsm = Etn.execute("select m.menu_version, m.enable_breadcrumbs, s.name as sitename, m.lang as mlang, s.datalayer_moringa_perimeter, s.country_code, s.datalayer_domain, s.datalayer_brand, s.datalayer_market, s.datalayer_asset_type, s.datalayer_orange_zone from "+dbname+"site_menus m, "+dbname+"sites s where m.id = "+escape.cote(menuid)+" and m.site_id = s.id ");
		rsm.next();
		String sitefolder = Util.getSiteFolderName(parseNull(rsm.value("sitename")));
		String mlang = parseNull(rsm.value("mlang"));
		String datalayerBrand = parseNull(rsm.value("datalayer_brand"));
		String datalayerDomain = parseNull(rsm.value("datalayer_domain"));
		String datalayerMarket = parseNull(rsm.value("datalayer_market"));
		String countrycode = parseNull(rsm.value("country_code"));
		String datalayerAssetType = parseNull(rsm.value("datalayer_asset_type"));
		String datalayerOrangeZone = parseNull(rsm.value("datalayer_orange_zone"));
		String enableBreadcrumbs = parseNull(rsm.value("enable_breadcrumbs"));
		String mversion = parseNull(rsm.value("menu_version"));
		String datalayerMoringaPerimeter = parseNull(rsm.value("datalayer_moringa_perimeter"));
		
		if("v2".equalsIgnoreCase(mversion))	log("Its a block system menu so we will only add gtm if required and will not add breadcrumbs in html files");
		
		//get translation of word Home
		String home = "Homepage";
		Set rst = Etn.execute("select concat('langue_', langue_id) from "+dbname+"language where langue_code = " + escape.cote(mlang));		
		if(rst.next())
		{
			rst = Etn.execute("select " + rst.value(0) + " from "+dbname+"langue_msg where LANGUE_REF = 'home' ");
			if(rst.next() && parseNull(rst.value(0)).length() > 0) home = parseNull(rst.value(0));
		}

//		System.out.println(pageids.size());

		for(String pageid : pageids)
		{
			Set rs = Etn.execute("select cp.*, cpp.file_path, cpp.breadcrumb from "+dbname+"cached_pages cp, "+dbname+"cached_pages_path cpp "+
						" where cpp.id = cp.id and cp.id = " + escape.cote(pageid));

			if(rs.next())
			{
				String pagetype = parseNull(rs.value("pagetype"));
				String subLevel1 = parseNull(rs.value("sub_level_1"));
				String subLevel2 = parseNull(rs.value("sub_level_2"));
				String subLevel3 = parseNull(rs.value("ptitle"));							
				
				try
				{
					String breadcrumbjson = parseNull(rs.value("breadcrumb"));					
					org.jsoup.nodes.Document doc = Jsoup.parse(new File(basedir + rs.value("file_path") + rs.value("filename")), "UTF-8");
					boolean saveFile = false;
					//v2 menus are block system based in which we will not add the breadcrumbs in the html files
					//breadcrumbs will be a block included by webmaster
					if(breadcrumbjson.length() > 0 && "1".equals(enableBreadcrumbs) && "v1".equalsIgnoreCase(mversion))
					{
						log("Going to update page : " + pageid + " bc : " + breadcrumbjson);
						org.jsoup.select.Elements eles = doc.select("#etn_breadcrumb");
						String lastBcItem = "", lastBcItemPath = "";
						if(eles != null && eles.size() > 0)
						{
							String breadcrumb = "<div class='etnhf-container'><nav aria-label='breadcrumb'><ol class='etnhf-breadcrumb'>";
							
							try
							{
								List<Object> br = new com.google.gson.Gson().fromJson(breadcrumbjson, ArrayList.class);
								int i=0;
								for(Object obj : br)
								{
									Map<String, String> map = (Map<String, String>)obj;
									//we save complete path and have selected flag if that item is to be shown in breadcrumb
									if(map.get("selected").equals("1"))
									{
										if(map.get("ishome").equals("1")) 
										{
											org.jsoup.nodes.Element logo = doc.select("#___portalhomepagelink").first();
											breadcrumb += "<li class='etnhf-breadcrumb-item'><a href='"+logo.attr("href")+"'>" + home + "</a></li>";
											lastBcItemPath = logo.attr("href");
											lastBcItem = home;
										}										
										else
										{
											//make sure we have title for the selected breadcrumb page and also the url is still active after publishing
											Set brrs = Etn.execute("select cp.id, cp.filename, cp.ptitle, cpp.file_path, cpp.file_url from "+dbname+"cached_pages cp left outer join "+dbname+"cached_pages_path cpp on cpp.id = cp.id where coalesce(cp.ptitle,'') <> '' and cp.is_url_active = 1 and cp.id = " + escape.cote(map.get("pageid")));
											if(brrs.next())
											{
												breadcrumb += "<li class='etnhf-breadcrumb-item'>";

												String _path = parseNull(brrs.value("file_url")) + parseNull(brrs.value("filename"));
												//the current page itself
												if(map.get("destpage") != null && map.get("destpage").equals("1")) 
												{
													_path = "javascript:void(0)";
													breadcrumb += parseNull(brrs.value("ptitle"));
												}
												else if(_path.length() > 0) 
												{
													_path = parseNull(brrs.value("file_url")) + parseNull(brrs.value("filename"));
													breadcrumb += "<a href='"+_path+"'>" + parseNull(brrs.value("ptitle")) + "</a>";
												}
												else 
												{
													_path = "javascript:void(0)";
													breadcrumb += "<a href='"+_path+"'>" + parseNull(brrs.value("ptitle")) + "</a>";
												}
			
												breadcrumb += "</li>";
												
												//breadcrumb json has the destination page added to it. We are not going to use that as last breadcrumb item. 
												if(map.get("destpage") == null || map.get("destpage").equals("0"))
												{
													lastBcItemPath = _path;
													lastBcItem = parseNull(brrs.value("ptitle"));
												}
											}				
										}
										i++;
									}
								}
							}
							catch(Exception e)
							{
								Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'BreadCrumbs::Error reading breadcrumb json') ");
								logE("ERROR::updating htmls::pageid  :: " +pageid );
								logE(e.getMessage());
								e.printStackTrace();
							}
							breadcrumb += "</ol></nav>";
							//adding second last item from breadcrumb for mobile view breadcrumb
							breadcrumb += "<a class='etnhf-PageTitle-backBtn etnhf-d-md-none' id='etnlastbcitem' href='"+lastBcItemPath+"'><span data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-left.svg'></span>"+lastBcItem+"</a>";
							breadcrumb += "</div>";
							doc.select("#etn_breadcrumb").first().html(breadcrumb);
							saveFile = true;
						}
					}
					
					if(doc.select("#etn_datalayer") != null && doc.select("#etn_datalayer").size() > 0)
					{
						//these 3 variables for datalayer can be overwritten using pages module ... so preference will be given to values coming from pages module
						String dlPageType = "";
						org.jsoup.select.Elements h1s = doc.select("meta[name=etn:dl_page_type]");
						if(h1s != null && h1s.size() > 0) dlPageType = parseNull(h1s.first().attr("content"));
						if(dlPageType.length() > 0) pagetype = dlPageType;
						
						String dlSubLevel1 = "";
						h1s = doc.select("meta[name=etn:dl_sub_level_1]");
						if(h1s != null && h1s.size() > 0) dlSubLevel1 = parseNull(h1s.first().attr("content"));
						if(dlSubLevel1.length() > 0) subLevel1 = dlSubLevel1;
						
						String dlSubLevel2 = "";
						h1s = doc.select("meta[name=etn:dl_sub_level_2]");
						if(h1s != null && h1s.size() > 0) dlSubLevel2 = parseNull(h1s.first().attr("content"));
						if(dlSubLevel2.length() > 0) subLevel2 = dlSubLevel2;
						
						//also update datalayer script tag
						String datalayerPagename = "";
						if(pagetype.length() > 0) datalayerPagename = "{{"+pagetype.replace("'","\\'")+"}}";
						datalayerPagename += "/"; 
						if(subLevel1.length() > 0) datalayerPagename += "{{"+subLevel1.replace("'","\\'")+"}}";
						datalayerPagename += "/"; 
						if(subLevel2.length() > 0) datalayerPagename += "{{"+subLevel2.replace("'","\\'")+"}}";
						datalayerPagename += "/"; 
						if(subLevel3.length() > 0) datalayerPagename += "{{"+subLevel3.replace("'","\\'")+"}}";

						String dlStr = "{'cookie_consent':'','platform':__platform(),'asset_type':'"+datalayerAssetType.replace("'","\\'")+"','orange_zone':'"+datalayerOrangeZone.replace("'","\\'")+"','moringa_perimeter':'"+datalayerMoringaPerimeter.replace("'","\\'")+"','brand':'"+datalayerBrand.replace("'","\\'")+"','section':'"+datalayerDomain.replace("'","\\'")+"','country':'"+countrycode.replace("'","\\'")+"','market_type':'"+datalayerMarket.replace("'","\\'")+"','language':'"+mlang+"','page_type':'"+parseNull(pagetype).replace("'","\\'")+"','page_name':'"+datalayerPagename+"','page_hostname':window.location.hostname,'page_url':window.location.href,'referrer_url':document.referrer,'sub_page_type_level1':'"+subLevel1.replace("'","\\'")+"','sub_page_type_level2':'"+subLevel2.replace("'","\\'")+"','sub_page_type_level3':'"+subLevel3.replace("'","\\'")+"','orange_client_id':'','client_type':'','contract_type':'','user_logged':'no','event_category':'','event_action':'','event_label':'','search_query':'','search_results':'','search_section':'','search_clicked_link':'','product_name':'','product_brand':'','product_id':'','product_price':'','product_category':'','product_variant':'','product_position':'','product_quantity':'','product_stock':'','product_stock_number':'','product_sold':'','revenue':'','currency_code':'','order_id':'','tax':'','shipping_cost':'','shipping_type':'','funnel_name':'','funnel_step':'','funnel_step_name':'','product_line':'','order_type':'','acquisition_retention_type':''}";
						
						org.jsoup.nodes.Element etnDl = doc.select("#etn_datalayer").first().addClass("___deldl");
						org.jsoup.nodes.Element etnDlObj = doc.select("#etn_datalayer_obj").first().addClass("___deldl");

						etnDl.after("<script id='etn_datalayer' >dataLayer = ["+dlStr+"]</script>");
						etnDlObj.after("<script id='etn_datalayer_obj' >var _etn_dl_obj = "+dlStr+"</script>");
						
						doc.select(".___deldl").remove();

						saveFile = true;
					}

					if(saveFile) saveFileToDisk(doc.outerHtml(), basedir + rs.value("file_path") + rs.value("filename"), menuid);
					
					Etn.executeCmd("update "+dbname+"cached_pages_path set breadcrumb_changed = 0 where id = " + escape.cote(pageid));
				}
				catch(Exception e)
				{
					Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'BreadCrumbs::Error updating breadcrumbs and datalayer') ");
					e.printStackTrace();
				}
			}
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
			Etn.executeCmd("insert into "+dbname+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'BreadCrumbs::Error saving file') ");
			e.printStackTrace();
		}
		finally
		{
			if(fout != null) try { fout.close(); } catch (Exception e) {}
		}
	}

	public static void main(String[] aa) throws Exception
	{		
//		BreadCrumbs br = new BreadCrumbs(true, true);
		//br.generate("68");
	}	

}

