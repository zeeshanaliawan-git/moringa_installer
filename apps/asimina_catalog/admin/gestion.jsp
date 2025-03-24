<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>


<%
	Etn.executeCmd("insert ignore into "+GlobalParm.getParm("COMMONS_DB")+".user_sessions (catalog_session_id) values ("+escape.cote(""+session.getId())+") ");

	String err = parseNull(request.getParameter("err"));
	String errmsg = parseNull(request.getParameter("errmsg"));
	if("1".equals(err)) errmsg = "You must select a site to continue";
	else if("2".equals(err)) errmsg = "You are not authorised to access this page";
%>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
	<title>Gestion</title>
	<style>
		.abutton
		{
			border-right:1px solid #ddd;
			border-bottom:1px solid #ddd;
			margin-bottom:5px; background-color:#eee;
			color:black;
			padding:5px 8px 5px 8px;
		}
		.alink
		{
			color:black;
		}
	</style>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- beginning of container -->
	<div class="pt-4 pt-md-11">
		<% if(errmsg.length() > 0) { %>
		<div class="alert alert-danger" role="alert" ><%=escapeCoteValue(errmsg)%></div>
		<% } %>	
		<!-- Main component for a primary marketing message or call to action -->
		<div class="jumbotron">
			<div class="row align-items-center">
				<div class="col-12 col-md-5 col-lg-6 order-md-2 text-center">
					<!-- Image -->
					<img src="../img/Cross-platform-software-amico.png" class="img-fluid" style="max-height:350px" alt="..." data-aos="fade-up" data-aos-delay="100">
				</div>
				<div class="col-12 col-md-7 col-lg-6 order-md-1 aos-init aos-animate" data-aos="fade-up">
					<!-- Heading -->
					<h1 class="display-4">Welcome to <%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%> </h1>
					<br><br>
					<!-- Text -->
					<p class="lead"><%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%> is a CMS tool which enable to manage all the navigation and catalogs of website. </p>
					<p class="lead">To use this CMS you must have been trained. Be careful using production one publication button, new content will be visible by anyone just after.</p>
				</div>
			</div> <!-- / .row -->
		</div>
	</div>
	<!-- /end of container -->
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>
</body>
</html>
