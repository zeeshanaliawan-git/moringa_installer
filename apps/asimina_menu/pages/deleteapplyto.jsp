<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="common.jsp"%>

<%
	String id = parseNull(request.getParameter("id"));
	String menuid = parseNull(request.getParameter("menuid"));

	int r = Etn.executeCmd("delete from menu_apply_to where id =  " + escape.cote(id));
	if(r > 0) 
	{
		Etn.executeCmd("update site_menus set version = version + 1, updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+" where id = " + escape.cote(menuid));

		out.write("{\"response\":\"success\"}");
	}
	else out.write("{\"response\":\"error\"}");
%>