<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="common.jsp"%>
<%@ include file="menugenerator.jsp"%>

<%
	String menuid = parseNull(request.getParameter("menuid"));
	String ispreview = parseNull(request.getParameter("ispreview"));
	if(ispreview.length() == 0) ispreview = "0";
	
	String isprod = parseNull(request.getParameter("isprod"));

	String m = "";
	if("1".equals(isprod)) m = generateFooter(Etn, menuid, ispreview, request.getContextPath(), true);
	else  m = generateFooter(Etn, menuid, ispreview, request.getContextPath());
	
	out.write(m);
%>