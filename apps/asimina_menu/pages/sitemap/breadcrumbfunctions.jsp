<%!
	class Node
	{
		String pageid;
		boolean ismenulink;
		boolean ishomepage;
		boolean is404;
		String url;
		String pagelevel;
		String filename;
		String ptitle;
		List<String> parentpageids;
		List<Boolean> ispagelinks;
		String breadcrumbJson;
		boolean brChanged;
		List<Node> parents;
		//we have cases where a node has its parent but the parent does not have its parent
		//this can only occur where a page A is linked only from 404 page in which case page A will not
		//have record in crawler_paths table but page B has only 1 parent which is page A and page B has record
		//in crawler_paths. So in thise case page A is not there in nodes map so we will add it at runtime and for 
		//these extraNode will be true as we dont have to show them in the breadcrumbs list
		boolean extraNode = false;
		
		List<String> getParentIds()
		{
			if(parents == null) return null;
			List<String> pids = new ArrayList<String>();
			for(Node pn : parents)
			{
				pids.add(pn.pageid);
			}
			return pids;
		}		
	}
	
	String getProdSitePath(com.etn.beans.Contexte Etn, String domain, String menuid, String menupath, String url) throws Exception
	{
		if(parseNull(domain).length() == 0) return url;
		
		if(menupath.equals(getDefaultMenuPath(Etn, menuid))) 
		{
			return url;
		}
		
		domain = domain.toLowerCase();
		String htp = "http://";
		if(domain.startsWith("https://")) htp = "https://";
		domain = domain.replace("https://","").replace("http://","");
		
		if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));
		
		return htp + domain + url;
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
 		
		if(node.ishomepage || node.is404) return null;

		List<List<String>> paths = new ArrayList<List<String>>();
		List<String> alreadyTraversed = new ArrayList<String>();

		traverse(paths, node, nodes.get(hppageid), alreadyTraversed,0, node.getParentIds());
		return paths;
	}	
	
	/*
	* This function returns the last path used for breadcrumb
	*/
	String getBreadCrumbPath(String json)
	{
		if(parseNull(json).length() == 0) return "";
		List<Object> br = new com.google.gson.Gson().fromJson(json, ArrayList.class);

		String s = "";
		for(Object obj : br)
		{
			Map<String, String> map = (Map<String, String>)obj;
			if(map.get("ishome").equals("1")) 
			{
				s += "0,";
			}
			else
			{
				s += map.get("pageid") + ",";
			}
		}	
		return s;
	}

	/*
	* This function returns the last breadcrumb. Breadcrumb can have some nodes unselected from the path
	*/
	String getBreadCrumb(String json)
	{
		if(parseNull(json).length() == 0) return "";
		List<Object> br = new com.google.gson.Gson().fromJson(json, ArrayList.class);

		String s = "";
		for(Object obj : br)
		{
			Map<String, String> map = (Map<String, String>)obj;
			if(map.get("ishome").equals("1") && map.get("selected").equals("1")) 
			{
				s += "0,";
			}
			else if(map.get("selected").equals("1"))
			{
				s += map.get("pageid") + ",";
			}
		}
		return s;
	}

	String getPathString(Map<String, Node> nodes, List<String> path)
	{
		if(path == null || path.isEmpty()) return "";
		String s = "";
		for(int i=path.size(); i>0; i--) 
		{
			Node node = nodes.get(path.get(i-1));
			if(node.ishomepage) s += "0,";
			else s += node.pageid + ",";
		}
		return s;
	}

	String getPathJson(Map<String, Node> nodes, List<String> path, String destinationPageId)
	{
		String json = "[";
		for(int i= path.size(); i>0; i--) 
		{
			if(i != path.size()) json += ",";
			Node pathnode = nodes.get(path.get(i-1));
							
			if(pathnode.ishomepage) json += "{\"ishome\":\"1\",\"selected\":\"1\"}";
			else if(pathnode.pageid.equals(destinationPageId)) json += "{\"ishome\":\"0\",\"pageid\":\""+destinationPageId+"\",\"selected\":\"1\",\"destpage\":\"1\"}";
			else json += "{\"ishome\":\"0\",\"pageid\":\""+pathnode.pageid+"\",\"selected\":\"1\"}";
		}
		json += "]";

		return json;
	}


%>