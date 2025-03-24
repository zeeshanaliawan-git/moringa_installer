<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.beans.Contexte, java.util.*"%>
<%@include file="../common.jsp"%>
<%@include file="../lib_msg.jsp"%>
<%@include file="urlcommons.jsp"%>
<%@include file="breadcrumbfunctions.jsp"%>



<%
	String selectedSiteId = getSiteId(session);

//	String isprod = parseNull(request.getParameter("isprod"));
	//breadcrumbs is something only be visible in production site as it requires crawling of pages so we set isprod flag to 1 always
	String isprod = "1";

	String titlePrefix = "Preprod";
	String dbname = "";
	String action = "breadcrumbs.jsp";
	if("1".equals(isprod))
	{
		dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
		action = "prodbreadcrumbs.jsp";
		titlePrefix = "Production";
	}

	String menuid = parseNull(request.getParameter("menuid"));
	String selectedpageid = parseNull(request.getParameter("pageid"));

	Set rsSite = Etn.execute("Select * from "+dbname+"sites where id = "  +escape.cote(selectedSiteId));
	rsSite.next();
	String sitedomain = parseNull(rsSite.value("domain"));
	String menupath = "";
	
	Set rsm = Etn.execute("select m.*, s.name as site_name from "+dbname+"sites s, "+dbname+"site_menus m where m.deleted = 0 and s.id = "+escape.cote(selectedSiteId)+" and m.site_id = s.id order by s.name, m.name ");

	Map<String, Node> nodes = new LinkedHashMap<String, Node>();
	String hppageid = "";
	String mlang = "";
	//flag to know if menu was published in production
	boolean anyBreadcrumbFound = false;
	Set rsPages = null;
	if(menuid.length() > 0)
	{
		rsPages = Etn.execute("Select distinct crp.page_id, cp.ptitle, cp.filename, cpp.published_url from "+dbname+"crawler_paths crp, "+dbname+"cached_pages cp, "+dbname+"cached_pages_path cpp where crp.menu_id = cp.menu_id and crp.page_id = cp.id and cpp.id = cp.id and crp.menu_id = "+escape.cote(menuid) + " order by cp.ptitle ");
		
	}
	if(menuid.length() > 0 && selectedpageid.length() > 0)
	{
		Set rs1 = Etn.execute("Select * from "+dbname+"site_menus where id = " + escape.cote(menuid));
		rs1.next();
		mlang = rs1.value("lang");
		menupath = parseNull(rs1.value("production_path"));
		set_lang(mlang, request, Etn);
		String published404CachedId = parseNull(rs1.value("published_404_cached_id"));
	
		Set rs = Etn.execute("select distinct crp.page_id, cp.ptitle, cp.filename, cpp.breadcrumb, cpp.published_url, cpp.breadcrumb_changed, max(crp.is_menu_link) is_menu_link, min(crp.page_level) page_level, max(crp.is_404) is_404 from "+dbname+"crawler_paths crp, "+dbname+"cached_pages cp, "+dbname+"cached_pages_path cpp where crp.menu_id = cp.menu_id and crp.page_id = cp.id and cpp.id = cp.id and crp.menu_id = "+escape.cote(menuid)+" group by crp.page_id, cp.ptitle, cp.filename, cpp.breadcrumb, cpp.published_url, cpp.breadcrumb_changed order by is_404, page_level, is_menu_link desc, crp.page_id");
		while(rs.next())
		{
			if(parseNull(rs.value("breadcrumb")).length() > 0) anyBreadcrumbFound = true;

			Node node = new Node();
			node.pageid = parseNull(rs.value("page_id"));

			//a bad condition where a page is homepage and also a link from menu ... will never happen in reality but lets handle it ... so preference of homepage is more
			if("0".equals(rs.value("page_level"))) node.ishomepage = true;
			else if("1".equals(rs.value("is_menu_link"))) node.ismenulink = true;

			if(node.ishomepage) 
			{
				hppageid = node.pageid;
				node.ptitle = libelle_msg(Etn, request, "Home");
			}
			else node.ptitle = parseNull(rs.value("ptitle"));


			node.is404 = "1".equals(rs.value("is_404"));
			node.url = parseNull(rs.value("published_url"));
			node.filename = parseNull(rs.value("filename"));
			node.pagelevel = parseNull(rs.value("page_level"));
			node.breadcrumbJson = parseNull(rs.value("breadcrumb"));
			node.brChanged = "1".equals(parseNull(rs.value("breadcrumb_changed")));
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

			nodes.put(node.pageid, node);
		}
		
		setParents(nodes, hppageid);
	}

	boolean checkPublishStatus = false;
%>
<div class="mb-3 text-right">
	<button type="button" class="btn btn-primary" onclick='javascript:onSave("<%=selectedpageid%>")'>save</button>
</div>
<hr>
<div class='row'>
	<%  Node node = nodes.get(selectedpageid);

		String trCls = node.brChanged == true ? "bg-changed" : "bg-published";
		
		String _nurl = getProdSitePath(Etn, sitedomain, menuid, menupath, node.url);
		
	%>
	<label class='col-md-1'>Paths</label>
	<div><%
				List<List<String>> paths = getPaths(nodes, node, hppageid);						
				
				if(paths != null)
				{
					String brPath = getBreadCrumbPath(node.breadcrumbJson);
					String brStr = getBreadCrumb(node.breadcrumbJson);

					int j=0;
					for(List<String> currentPath : paths)
					{
						String pathString = getPathString(nodes, currentPath);
						boolean pathSelected = false;
						if(brPath.equals(pathString)) pathSelected = true;
					
						String htm = "";
						if(j > 0) htm += "<br><br>";
						htm += "<input type='radio' id='"+node.pageid+"_path_"+j+"' name='"+node.pageid+"_pradio' onchange='selectPath(this,"+node.pageid+", "+j+")' value='"+escapeCoteValue(getPathJson(nodes, currentPath, node.pageid))+"' "+ (pathSelected == true ? "checked='checked'" : "" ) +" ><strong> path "+j+": </strong>";
						String disabled = "";
						if(!pathSelected) disabled = "disabled";
						int k=0;
						for(int i= currentPath.size(); i>0; i--) 
						{
							Node pathnode = nodes.get(currentPath.get(i-1));

							boolean nodeSelected = false;	
							if(pathSelected && pathnode.ishomepage && brStr.contains("0,")) nodeSelected = true;//for homepage we have hardcoded 0 id in the string
							else if(pathSelected && brStr.contains(pathnode.pageid + ",")) nodeSelected = true;

							if(pathnode.extraNode && parseNull(pathnode.ptitle).length() == 0)//this was not loaded in first query but was a parent so we added it later and we have to load its title
							{
								Set __rs1 = Etn.execute("select cp.ptitle, cp.filename, cpp.breadcrumb, cpp.published_url, cpp.breadcrumb_changed from "+dbname+"cached_pages cp, "+dbname+"cached_pages_path cpp where cpp.id = cp.id and cp.id = "+escape.cote(pathnode.pageid));
								__rs1.next();
								pathnode.ptitle = parseNull(__rs1.value("ptitle"));
							}
							
							if(k > 0) htm += "&nbsp;>&nbsp;";
							htm += "<input "+disabled+" "+((nodeSelected == true) ? "checked='checked'" : "")+" onchange='changeNode(this,"+node.pageid+","+pathnode.pageid+","+j+","+k+")' type='checkbox' class='node_"+node.pageid+" node_"+node.pageid+"_"+j+"' id='ckbx_"+j+"_"+node.pageid+"_"+pathnode.pageid+"'/>&nbsp;"+escapeCoteValue(pathnode.ptitle);
							k++;
						}

						htm += "<input type='hidden' value='"+(escapeCoteValue(node.breadcrumbJson))+"' id='"+node.pageid+"_selected_path' />";
						out.write(htm);
						j++;
					}
				}
			%>
	</div>
</div>
