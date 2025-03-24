<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.Contexte"%>

<%@include file="../common.jsp"%>

<%
	String menuid = parseNull(request.getParameter("menuid"));

	String status = "-1";
	System.out.println("select * from post_work where client_key = "+escape.cote(menuid)+" and proces = 'breadcrumbs' and phase = 'publish' order by id desc limit 1");
	Set rs = Etn.execute("select * from post_work where client_key = "+escape.cote(menuid)+" and proces = 'breadcrumbs' and phase = 'publish' order by id desc limit 1");
	if(rs.next())
	{
		status = rs.value("status");
	}

	out.write("{\"statusCode\":\""+status+"\"}");
%>
