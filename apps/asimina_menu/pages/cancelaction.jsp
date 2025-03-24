<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp"%>

<% 
	String ty = parseNull(request.getParameter("type"));
	String id = parseNull(request.getParameter("id"));
	String on = "-1";
	String _goto = parseNull(request.getParameter("goto"));
	
	String process = getProcess(ty);

	String phase = "cancel";
	boolean dosemfree = movephase(Etn, id, process, phase, on);

	if(dosemfree) Etn.execute("select semfree('"+GlobalParm.getParm("SEMAPHORE")+"') ");

	response.sendRedirect(_goto);
%>