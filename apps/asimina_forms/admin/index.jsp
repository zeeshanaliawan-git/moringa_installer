<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ include file="../common2.jsp"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<!DOCTYPE html>
<html>
<head>

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/menu.css" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/general.css" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/jquery.min.css" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/bootstrap.min.css" />

<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/jquery.dataTables.min.css" />
<!-- CSS reset -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css" />


	<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>

	<title>Forms</title>
</head>
<body>
	
  <%@include file="/WEB-INF/include/menu.jsp"%>

	<div style="margin-bottom: 2rem; background-color: #e9ecef; border-radius: .3rem; margin: 30px; padding: 50px; min-height: 200px; width: 75%; margin-left: 168px;">
		<h1 style="font-size:63px; color: #4c4c4c;">Welcome to Dev forms </h1>	
	</div>
</body>
</html>
