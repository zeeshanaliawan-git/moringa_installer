<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, java.io.*"%>
<%@ page import="com.etn.beans.Contexte"%>
<%@include file="../common.jsp"%>
<%@include file="urlcommons.jsp"%>

<%
	String isprod = parseNull(request.getParameter("isprod"));
	String cid = parseNull(request.getParameter("cid"));
	String mins = parseNull(request.getParameter("mins"));


	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";

	int r = Etn.executeCmd("update "+dbname+"cached_pages set refresh_minutes = " + escape.cote(mins) + " where id = " + escape.cote(cid));
	out.write("{\"response\":\"success\",\"msg\":\"success\"}");
%>

