package com.etn.moringa;

import java.util.List;
import java.util.ArrayList;

public class Node
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
    List<Node> parents;
	String breadcrumbJson;
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

