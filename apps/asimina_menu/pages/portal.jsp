<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="common.jsp"%>

<%!
	String getSiteStatus(com.etn.beans.Contexte Etn, String siteid)
	{
		String proddb = com.etn.beans.app.GlobalParm.getParm("PROD_DB");
		String status = "NOT_PUBLISHED";
		Set rs = Etn.execute("select * from "+proddb+".sites where id = " + escape.cote(siteid));
		if(rs.rs.Rows == 0)
		{
			return status;
		}
		status = "PUBLISHED";
		rs = Etn.execute("select case when s1.version = s2.version then '1' else '0' end from sites s1, "+proddb+".sites s2 where s1.id = s2.id and s1.id = " + escape.cote(siteid));
		rs.next();
		if(rs.value(0).equals("0"))
		{
			status = "NEEDS_PUBLISH";
			return status;
		}
		rs = Etn.execute("select * from site_menus where is_active = 1  and deleted = 0 and site_id = " + escape.cote(siteid));
		while(rs.next())
		{
			Set rs1 = Etn.execute("select * from "+proddb+".site_menus where id = " + escape.cote(rs.value("id")));
			if(rs1.next() && !parseNull(rs.value("version")).equals(parseNull(rs1.value("version"))) )
			{
				status = "NEEDS_PUBLISH";
				break;
			}
		}
		return status;
	}
%>

<%
	String selectedSiteId = getSiteId(session);
	if(selectedSiteId.length() > 0)
	{
		response.sendRedirect("site.jsp");
		return;
	}

	String addnewsite = parseNull(request.getParameter("addnewsite"));
	String sitename = parseNull(request.getParameter("sitename"));
	String siteurl = parseNull(request.getParameter("siteurl"));

	if("1".equals(addnewsite))
	{
		String portalurl = "/portal/process.jsp?___mu=" + Base64.encode(siteurl.getBytes("utf8"));

		Etn.executeCmd("insert into sites (name, url, portal_url, created_by) values ("+escape.cote(sitename)+","+escape.cote(siteurl)+","+escape.cote(portalurl)+","+Etn.getId()+")" );
	}
	String u = request.getRequestURL().toString();
	u = u.substring(0, u.indexOf(request.getContextPath()));

%>

<html>
<head>
	<title>List of sites</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>


</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- breadcrumb -->
	<nav aria-label="breadcrumb">
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a href="<%=com.etn.beans.app.GlobalParm.getParm("GESTION_URL")%>">Home</a></li>
			<li class="breadcrumb-item active" aria-current="page">List of sites</li>
		</ol>
	</nav>
	<!-- /breadcrumb -->
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">List of sites</h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group" role="group" aria-label="...">
					<input type='button' value='New Site' id='newsitebtn' class="btn btn-default btn-primary" />
				</div>
			</div>
			<!-- /buttons bar -->
		</div><!-- /d-flex -->
	</div>
	<!-- /title -->

<!-- container -->
<div class="container-fluid">
<div class="animated fadeIn">
	<table class="table table-hover table-bordered m-t-20">
	<thead class="thead-dark">
			<tr>
			<th>Sites</th>
			<th>URL</th>
			<th style="text-align: center;">Actions</th>
		</tr>
	</thead>
		<% Set rs = Etn.execute("select * from sites order by name ");
			while(rs.next()) { 
				String rowColor = "";
				String sitestatus = getSiteStatus(Etn, rs.value("id"));
				if("NOT_PUBLISHED".equals(sitestatus)) rowColor = "unpublished"; //red					
				else if("NEEDS_PUBLISH".equals(sitestatus)) rowColor = "changed"; //orange
				else rowColor = "published"; //green

			%>
				<tr class='bg-<%=rowColor%>'>
					<td ><a href='site.jsp' class="simplelink"><%=escapeCoteValue(parseNull(rs.value("name")))%></a></td>
					<td><%=escapeCoteValue(parseNull(rs.value("url")))%></td>
					<td style="text-align: center;">
					<a class="btn btn-primary btn-sm" href="site.jsp"><span class="oi oi-eye" aria-hidden="true"></span></a>
					<a class="btn btn-primary btn-sm" href="siteparameters.jsp"><span class="oi oi-cog" aria-hidden="true"></span></a>
					</td>
				</tr>
		<% } %>
	</table>
</div>
</div><!-- /container -->
</main>
</div>
<%@ include file="/WEB-INF/include/footer.jsp" %>
<script type="text/javascript">
	jQuery(document).ready(function() {

		$("#newsitebtn").click(function(){
			window.location = "<%=request.getContextPath()%>/admin/newsite.jsp";
		});
	});
</script>
</body>
</html>
