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

	String titlePrefix = "Test Site";
	String dbname = "";
	String action = "breadcrumbs.jsp";
	if("1".equals(isprod))
	{
		dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
		action = "prodbreadcrumbs.jsp";
		titlePrefix = "Prod Site";
	}

	String menuid = parseNull(request.getParameter("menuid"));

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
	if(menuid.length() > 0)
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

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<title>Breadcrumbs</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>	
<%	
breadcrumbs.add(new String[]{titlePrefix, ""});
breadcrumbs.add(new String[]{"Breadcrumbs", ""});
%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
		<div>
			<h1 class="h2">Breadcrumbs</h1>
			<p class="lead"></p>
		</div>
		<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Breadcrumbs');" title="Add to shortcuts">
			<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
		</button>

		<!-- buttons bar -->
		<div class="btn-toolbar mb-2 mb-md-0">
			<% if(anyBreadcrumbFound) { 
				String nextpublish = "";
				String process = getProcess("breadcrumbs");
				Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(menuid) + " and proces = " + escape.cote(process));
				if(rspw.next()) nextpublish = parseNull(rspw.value(0));
			%>
			<% if(nextpublish.length() > 0) { 
				checkPublishStatus  = true; 
			%>
			<span style='color:red;margin-right:10px' id='publishstatus'>Waiting update</span>
			<div class="btn-group mr-2" role="group" aria-label="..." id='btnbarcancelpublish'>
				<button type="button" class="btn btn-warning" id='cancelpublishbtn' onclick='javascript:window.location="../cancelaction.jsp?type=breadcrumbs&id=<%=menuid%>&goto=sitemap/breadcrumbs.jsp?menuid=<%=menuid%>%26isprod=<%=isprod%>";'>Cancel update</button>
			</div>
			<% } %>
			<div class="btn-group" role="group" aria-label="...">
				<button type="button" class="btn btn-danger" id='prodpublishbtn'>Update HTMLs</button>
			</div>
			<% } %>
		</div>
		<!-- /buttons bar -->
	</div><!-- /d-flex -->
	<!-- /title -->



	<!-- container -->
	<div class="animated fadeIn">
		 <div class="m-b-20">
			 <form id='frm1' name='frm1' action='<%=action%>' method='post'>
			 <div>
			 <select name='menuid' onchange='reload()'  class="form-control col-4">
				<option value=''>- - - Select Menu - - -</option>
				<% while(rsm.next()) {%>
					<option <%if(menuid.equals(rsm.value("id"))){%>selected<%}%> value='<%=escapeCoteValue(rsm.value("id"))%>'><%=escapeCoteValue(rsm.value("site_name") + " : " + rsm.value("name"))%></option>
				<% } %>
			</select>
			</div>
			</form>
		</div>

		<% if(menuid.length() > 0 && !anyBreadcrumbFound) { 
			out.write("<div style='color:red'>Menu must be published to set default breadcrumbs</div>");
		} else if(menuid.length() > 0) { %>
		<div>
			<table class="table table-hover table-vam m-t-20" style="table-layout: fixed" id='table-breadcrumbs'>
			<thead class="thead-dark">
				<tr>
					<th>Page</th>
					<th width='5%'>Nb Paths</th>
					<th>Selected Path</th>
					<th width="3%">&nbsp;</th>
				</tr>
			</thead>
	
			<tbody>
			<% for(String pageid : nodes.keySet()) { 
			
				Node node = nodes.get(pageid);

				if(node.ishomepage || node.is404 || node.extraNode) continue;
				
				String ptype = "";
				if(node.ishomepage) ptype = "Homepage";
				if(node.is404) ptype = "404";
				if(node.ismenulink) ptype = "menu";
				String trCls = node.brChanged == true ? "table-danger" : "table-success";
				
				List<List<String>> paths = getPaths(nodes, node, hppageid);						
				int numberOfPaths = 0;
				if(paths != null) numberOfPaths = paths.size();
				
				String _nurl = getProdSitePath(Etn, sitedomain, menuid, menupath, node.url);
				
			%>
				<tr class='<%=trCls%>' id='<%=pageid%>_tr'>
					<td><a href='<%=_nurl%>' target='_blank'>
						<strong><%=escapeCoteValue(node.ptitle) + " (" + escapeCoteValue(node.filename) + ")"%></strong>
						</a></td>
					<td><span class="badge badge-pill badge-primary"><%=numberOfPaths%></span></td>
					<td>
					<%
						if(node.breadcrumbJson.length() > 0)
						{
							List<Object> br = new com.google.gson.Gson().fromJson(node.breadcrumbJson, ArrayList.class);

							String s = "";
							int j=0;
							for(Object obj : br)
							{
								Map<String, String> map = (Map<String, String>)obj;
								if(map.get("selected").equals("1"))
								{
									if(j++ > 0) s += " / ";
									if(map.get("ishome").equals("1"))
									{
										s += libelle_msg(Etn, request, "Home");
									}
									else
									{
										Node cnode = nodes.get(map.get("pageid"));
										if(cnode.extraNode && parseNull(cnode.ptitle).length() == 0)//this was not loaded in first query but was a parent so we added it later and we have to load its title
										{
											Set __rs1 = Etn.execute("select cp.ptitle, cp.filename, cpp.breadcrumb, cpp.published_url, cpp.breadcrumb_changed from "+dbname+"cached_pages cp, "+dbname+"cached_pages_path cpp where cpp.id = cp.id and cp.id = "+escape.cote(cnode.pageid));
											__rs1.next();
											cnode.ptitle = parseNull(__rs1.value("ptitle"));
										}
										s += cnode.ptitle;
									}
									
								}							
							}
							out.write(s);							
						}
					%>
					</td>
					<td class="text-right" style="max-width:120px">
						<% if(numberOfPaths > 0) { %>
						<button class="btn btn-sm btn-primary" onclick='javascript:showPaths("<%=node.pageid%>","<%=escapeCoteValue(node.ptitle)%>","<%=escapeCoteValue(node.filename)%>")' data-toggle="modal" data-target="#edit-breadcrumb"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-edit"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
						<% } %>
					</td>
				</tr>
			<% } %>
			</tbody>
			</table>
		</div>
		<%}%>
		<br>
		<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
</main>

<!-- .modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'></div>

<div class="modal right fade" tabindex="-1" role="dialog" data-backdrop="static" aria-hidden="true" id='edit-breadcrumb'>
	<div class="modal-dialog modal-lg modal-dialog-slideout modal-xl" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Breadcrumb : <span id='bcmodaltitlepage'></span></h5>

				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>

			<div id="breadcrumb_modal_content" class="modal-body">
				
			</div>

			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>
<!-- /.modal -->
<%
	String prodpushid = menuid;
	String prodpushtype = "breadcrumbs";
%>
<%@ include file="../prodpublishlogin.jsp"%>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /app-body -->
<script>
jQuery(document).ready(function()
{
	showPaths=function(pageid, ptitle, pfilename)
	{
		$("#breadcrumb_modal_content").html("<div style='color:red;font-size:16px'>Loading ....</div>");
		if(ptitle === '') $("#bcmodaltitlepage").html(pfilename);
		else $("#bcmodaltitlepage").html(ptitle);
		$.ajax({
			url : 'loadpagepaths.jsp',
			type: 'POST',
			data: {menuid : '<%=menuid%>', pageid : pageid, isprod : '<%=isprod%>'},
			success : function(htm)
			{
				$("#breadcrumb_modal_content").html(htm);
			},
			error : function()
			{
				console.log("Error while communicating with the server");
			}
		});		
	};
	
	reload=function()
	{
		$("#frm1").submit();
	};

	checkPublishStatus=function()
	{
		$.ajax({
			url : 'checkbcpublishstatus.jsp',
			type: 'POST',
			data: {menuid : '<%=menuid%>'},
			dataType : 'json',
			success : function(json)
			{
				if(json.statusCode == 0) $("#publishstatus").html("Waiting publish");				
				else if(json.statusCode == 1) 
				{
					$("#publishstatus").html("Publish in process");
					$("#btnbarcancelpublish").hide();
				}
				else 
				{
					$("#publishstatus").hide();
					$("#btnbarcancelpublish").hide();
					clearInterval(_interval);
				}
			},
			error : function()
			{
				console.log("Error while communicating with the server");
			}
		});		
	};

	var _interval = null;
	<% if(checkPublishStatus) { %>
		_interval = setInterval(checkPublishStatus, 5000);
	<% } %>
	
	refreshscreen=function()
	{
		window.location = "breadcrumbs.jsp?menuid=<%=menuid%>&isprod=<%=isprod%>";
	};

	$('#table-breadcrumbs').DataTable({
		"responsive": true,
		"pageLength": 100,
        "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
		 "order": [[ 0, "asc" ]]
	});
	$("#table-breadcrumbs_filter input").addClass('form-control');

	selectPath=function(obj, pageid, indx)
	{
		$(".node_" + pageid).each(function(){
			$(this).prop( "checked", false );
			$(this).prop( "disabled", true);
		});
		$(".node_" + pageid +  "_" + indx).each(function(){
			$(this).prop( "checked", true );
			$(this).prop( "disabled", false);
		});

		$("#"+pageid+"_selected_path").val($(obj).val());
	};

	changeNode=function(obj, pageid, pathpageid, pathnum, nodeIndex)
	{
		var jsn = JSON.parse($("#"+pageid+"_selected_path").val());	
		for(var i=0; i < jsn.length; i++)
		{
			if(i == nodeIndex) 
			{
				if(jsn[i].selected == '0') jsn[i].selected = '1';
				else jsn[i].selected = '0';
			}
		}
		$("#"+pageid+"_selected_path").val(JSON.stringify(jsn));
	};

	onSave=function(pageid)
	{
		$("#succ_br_node_" + pageid).hide();
		$.ajax({
			url : 'savebreadcrumb.jsp',
			type: 'POST',
			data: {pageid : pageid, json : $("#"+pageid+"_selected_path").val(), isprod : "<%=isprod%>"},
			dataType : 'json',
			success : function(json)
			{
				if(json.response == 'success')
				{
					$("#succ_br_node_" + pageid).fadeIn();
					setTimeout(function() { $("#succ_br_node_" + pageid).fadeOut(); }, 1500);
					$("#"+pageid+"_tr").removeClass("bg-published");
					$("#"+pageid+"_tr").addClass("bg-changed");
					$("#edit-breadcrumb").modal('hide');
				}
				else alert(json.msg);
			},
			error : function()
			{
				console.log("Error while communicating with the server");
			}
		});		
	};	
});
</script>

</body>
</html>
