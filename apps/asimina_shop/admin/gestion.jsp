<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.util.Map,java.util.*"%>
<%@ page import="java.util.LinkedHashMap"%>

<%@ include file="../common.jsp" %>

<%
	String siteId = parseNull(session.getAttribute("SELECTED_SITE_ID"));
	System.out.println("siteId::"+siteId);

	String err = parseNull(request.getParameter("err"));
	String errmsg = parseNull(request.getParameter("errmsg"));

	if("1".equals(err) || siteId==null || siteId.length()==0) {
		errmsg = "You must select a site to continue";
	}
	else if("2".equals(err)) errmsg = "You are not authorised to access this page";


%>
<!DOCTYPE html>
<html lang="en">
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

   	
	<link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery-ui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
</head>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
			<div class="container-fluid" style="padding-top:25px">
				<% if(errmsg.length() > 0) { %>
					<div class="alert alert-danger" role="alert" ><%=escapeHtml(errmsg)%></div>
				<% } %>	
				<div class="jumbotron">
					<h1 style="font-size:63px">
						<img src="<%=request.getContextPath()%>/img/logo.png" alt="" style="width: 50px; height: auto; margin-right: 30px;">
						<span>Welcome to <%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%> </span>
					</h1>
					
					<br></br>
					<p class="lead"><%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%> is a tool to manage your customer orders.</p>
					<p class="lead">To use this tool you must have been trained.</p>
				</div>
			</div>
		</main>
    </div>
    <%@ include file="../WEB-INF/include/footer.jsp" %>
</div>
</body>
</html>
