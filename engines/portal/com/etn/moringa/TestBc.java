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

public class TestBc 
{ 

	private Properties env;
	private ClientSql Etn;
	private boolean isprod;
	private boolean debug;

	private boolean isPublishing = false;
	String dbname = "";

	private void init(ClientSql Etn, Properties env, boolean isprod, boolean debug, String prefix) throws Exception
	{
		this.Etn = Etn;
		this.env = env;
		this.debug = debug;		
		this.isprod = isprod;
		dbname = prefix + "_prod_portal.";
		//dbname = "dev_cote_prod_portal.";
	}	

	public TestBc(ClientSql Etn, Properties env, boolean isprod, boolean debug, String prefix) throws Exception
	{
		init(Etn, env, isprod, debug, prefix);
	}

	public TestBc(boolean isprod, boolean debug, String prefix) throws Exception
	{
   		Properties env2 = new Properties();
		env2.load( getClass().getResourceAsStream("Crawler.conf") );	
    
		ClientSql Etn2 = new ClientDedie(  "MySql", env2.getProperty("CONNECT_DRIVER"), env2.getProperty("CONNECT") );		
		init(Etn2, env2, isprod, debug, prefix);
	}

	public TestBc(ClientSql Etn, Properties env, boolean isprod, boolean debug, boolean isPublishing, String prefix) throws Exception
	{
		init(Etn, env, isprod, debug, prefix);
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
		if(isprod) m = "Prod TestBc::" + m;
		else m = "Preprod TestBc::" + m;
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

	//this function will generate default TestBc for the pages which are active and have no TestBc set in the db yet
	//it will then update the shortest breadcrumb in the db for those pages
	@SuppressWarnings("unchecked")
	public boolean generate(String menuid) 
	{
		int auditid = 0;
		try
		{
			log("--------- "+new Date()+" TestBc start generate defaults for menu id : " + menuid);

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
					log("pageid : " + node.pageid + " paths : " + paths.size() );
					List<String> allPossiblePaths = new ArrayList<String>();
					//log("--------------- Path for node : " + node.pageid + "------------------");
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
						//System.out.println("Node : " + pageid + " : " + node.breadcrumbJson);
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
							//log("Old breadcrumb path : " + lastBrString);						
	
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
						}
					}//if !pathfound

				}
			}

			log("--------- "+new Date()+" BreadCrumbs end generate defaults for menu id : " + menuid);
		}
		catch(Exception e)
		{
			logE("ERROR::BR::generate::"+e.getMessage());
			e.printStackTrace();
			return false;
		}
		finally
		{
		}
		return true;
	}

	public boolean updateHtmls(String menuid)
	{
		return true;
	}

	private void updateHtmls(String menuid, List<String> pageids) throws Exception
	{
		return;
	}

	private void saveFileToDisk(String contents, String filepath, String menuid) 
	{
		return;
	}

	public static void main(String[] aa) throws Exception
	{		
		TestBc br = new TestBc(true, true, aa[0]);
		br.generate(aa[1]);
	}	

}

