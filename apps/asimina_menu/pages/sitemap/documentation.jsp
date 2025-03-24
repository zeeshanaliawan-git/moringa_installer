<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.Contexte, java.io.*, java.util.ArrayList"%>
<%@include file="../common.jsp"%>

<%
	String selectedSiteId = getSiteId(session);

	String isprod = parseNull(request.getParameter("isprod"));

	String dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";

	Set rsm = Etn.execute("select m.*, s.name as site_name from "+dbname+"sites s, "+dbname+"site_menus m where m.deleted = 0 and s.id = "+escape.cote(selectedSiteId)+" and m.site_id = s.id order by s.name, m.name ");
	String menuid = parseNull(request.getParameter("menuid"));


%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<title>Documentation</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
	<%@ include file="/WEB-INF/include/header.jsp" %>
	<div class="c-body" >
		<main class="c-main" style="padding:0px 30px">
			<!-- breadcrumb -->
			<nav aria-label="breadcrumb">
				<ol class="breadcrumb">
					<li class="breadcrumb-item"><a href="<%=com.etn.beans.app.GlobalParm.getParm("GESTION_URL")%>">Home</a></li>
					<li class="breadcrumb-item active" aria-current="page">Documentation</li>
				</ol>
			</nav>
			<!-- /breadcrumb -->
			<!-- title -->
			<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
					<div>
						<h1 class="h2">Documentation</h1>
						<p class="lead"></p>
					</div>

					<!-- buttons bar -->
					<div class="btn-toolbar mb-2 mb-md-0">
						<% if(menuid.length() > 0) { %>
						<div class="btn-group mr-2" role="group" aria-label="...">
							<button type="button" class="btn btn-primary" onclick='getProfils()'>Profil List</button>
						</div>
						<div class="btn-group" role="group" aria-label="...">
							<button type="button" class="btn btn-success" onclick='getSitemap()'>Sitemap</button>
							<button type="button" class="btn btn-success" onclick='getPagesInfo()'>Pages Detail</button>
							<button type="button" class="btn btn-primary" onclick='getResources()'>Resources</button>
						</div>
						<% } %>
					</div>
					<!-- /buttons bar -->
			</div><!-- /d-flex -->
			<!-- /title -->
			<!-- container -->
			<div class="container-fluid">
				<div class="animated fadeIn">
					<div class="m-b-20">
						<form id='frm1' name='frm1' action='documentation.jsp' method='post'>
						<select name='menuid' onchange='reload()'  class="form-control col-4">
							<option value=''>- - - Select Menu - - -</option>
							<% while(rsm.next()) {%>
								<option <%if(menuid.equals(rsm.value("id"))){%>selected<%}%> value='<%=escapeCoteValue(rsm.value("id"))%>'><%=escapeCoteValue(rsm.value("site_name") + " : " + rsm.value("name"))%></option>
							<% } %>
						</select>
						</form>
					</div>
					<br>
				</div>
			</div>
			<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
		</main>
		<%@ include file="/WEB-INF/include/footer.jsp" %>
	</div><!-- /app-body -->
</div>
<script>
jQuery(document).ready(function()
{
	reload=function()
	{ 
		$("#frm1").submit();
	};

	getSitemap=function()
	{
		window.location = "generateDocumentation.jsp?menuid=<%=menuid%>&action=sitemap";
	};

	getProfils=function()
	{
		window.location = "generateDocumentation.jsp?menuid=<%=menuid%>&action=profils";
	};

	getPagesInfo=function()
	{
		window.location = "generateDocumentation.jsp?menuid=<%=menuid%>&action=pagesinfo";
	};

	getResources=function()
	{
		window.location = "generateDocumentation.jsp?menuid=<%=menuid%>&action=resources";
	};

});
</script>

</body>
</html>