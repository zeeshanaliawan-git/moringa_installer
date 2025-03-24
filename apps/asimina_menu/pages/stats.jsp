<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, java.util.*"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="common.jsp"%>

<%
	String selectedSiteId = getSiteId(session);

	String titlePrefix = "Test Site";
	String isprod = parseNull(request.getParameter("isprod"));
	String dbname = "";
	if("1".equals(isprod)) 
	{
		dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";//"prod_portal.";
		titlePrefix = "Prod Site";
	}

	Set rsm = Etn.execute("select id, menu_uuid from "+dbname+"site_menus where site_id = " + escape.cote(selectedSiteId));
	String inclause = "(";
	int i = 0;
	while(rsm.next())
	{
		if(i++>0) inclause += ",";
		inclause += escape.cote(rsm.value("menu_uuid"));
	}
	inclause += ")";

	Set rs = Etn.execute("select url _url, count(0) as c from "+dbname+"stat_log where menu_uuid in "+inclause+" group by _url");

%>

<html>
<head>
	<title>Stats - <%=titlePrefix%></title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<%
breadcrumbs.add(new String[]{"Stats - "+ titlePrefix, ""});

%>
	<style>
		.results th
		{
			background: #808080;/*#ddd*/
			color: white;
			padding: 10px;
			vertical-align: top;
		}
	</style>
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
				<h1 class="h2">Stats - <%=titlePrefix%>
				</h1>
				<p class="lead"></p>
			</div>

			<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Stats');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>

			<!-- buttons bar -->
			<!-- /buttons bar -->
	</div>
	<!-- /title -->

	<!-- container -->
	<div class="animated fadeIn">
	<table class="table table-hover table-vam m-t-20" id="results">
		<thead class="thead-dark">
			<th style="text-align: left;">URL</th>
			<th style="text-align: center; ">Number of hits</th>
		</thead>
		<%
		if(rs == null || rs.rs.Rows == 0) 
		{
			out.write("<tr><td colspan='2' style='color:red; text-align:center'>No data available for the selected site</td></tr>");
		}
		else
		{
			int cnt = 0;
			while(rs.next())
			{
				String color = "";
				if(cnt % 2 != 0) color = "background:#eee";
		%>
			<tr >
				<td style='padding-right:10px; <%=color%>'><%=escapeCoteValue(parseNull(rs.value("_url")))%></td>
				<td style='text-align: center;<%=color%>'><%=escapeCoteValue(parseNull(rs.value("c")))%></td>
			</tr>
		<%
				cnt++;
			}
		}
		%>
	</table>	
	<br>
	<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	<br>&nbsp;
	</div>
	 <!-- /container -->
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>


<script type="text/javascript">
jQuery(document).ready(function() {
	$("#results").DataTable({
		"responsive": true,
		"lengthMenu": [[50, 100, -1], [50, 100, "All"]],
		"iDisplayLength": 50
	});
});
</script>
</body>
</html>
