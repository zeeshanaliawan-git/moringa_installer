<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="common.jsp"%>

<%
	String isprod = request.getParameter("isprod");
	if(isprod == null || isprod.trim().length() == 0) isprod = "0";

	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
	Set rs = Etn.execute("select * from "+dbname+"contact_us order by created_on desc ");
%>

<html>
<head>
	<title>Portal</title>
	<link type="text/css" rel="stylesheet" href="../css/portal.css" />
	<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/menu.css">
	<link type="text/css" rel="stylesheet" href="../css/jquery_1_10_4/smoothness/jquery-ui-1.10.4.custom.min.css" />
	<script type="text/javascript" src="../js/jquery.min.js"></script>
</head>
<body>
	<%@ include file="/WEB-INF/include/menu.jsp"%>

	<center>
		<%if(!"1".equals(isprod)){%>		
			<h2>Preprod Contact Us</h2>
		<%}else{%>
			<h2 style='color:red'>Production Contact Us</h2>
		<%}%>
	</center>

<div style='margin-top:20px;'>
	<center>
	<div>
	<table cellpadding=0 cellspacing=0 border=1 width='75%'>
		<thead>
			<th>Date</th>
			<th>Name</th>
			<th>Surname</th>
			<th>Cellphone</th>
			<th>Alternate number</th>
			<th>Email</th>
			<th>Type of request</th>
			<th>Service</th>
			<th>Type of complaint</th>
			<th>Message</th>
		</thead>
		<% while(rs.next()){%>
			<tr>
				<td><%=rs.value("created_on")%></td>
				<td><%=rs.value("name")%></td>
				<td><%=rs.value("surname")%></td>
				<td><%=rs.value("cellphone")%></td>
				<td><%=rs.value("alternate_number")%></td>
				<td><%=rs.value("email")%></td>
				<td><%=rs.value("type_of_request")%></td>
				<td><%=rs.value("service")%></td>
				<td><%=rs.value("type_of_complaint")%></td>
				<td><%=rs.value("message")%></td>
			</tr>
		<%}%>
	</table>
	</div>
	</center>
</div>
</body>
</html>