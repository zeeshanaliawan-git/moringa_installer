<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="common.jsp"%>

<%
	String menuid = parseNull(request.getParameter("menuid"));
//	Etn.executeCmd("delete from additional_menu_items where menu_id = " + escape.cote(menuid));
//	Etn.executeCmd("delete from menu_apply_to where menu_id = " + escape.cote(menuid));
//	Etn.executeCmd("delete from menu_items where menu_id = " + escape.cote(menuid));
//	Etn.executeCmd("delete from site_menus where id = " + escape.cote(menuid));
//	Etn.executeCmd("delete from cached_pages where menu_id = " + escape.cote(menuid));

	//people delete menus by mistake so lets not deleted it and just mark it in-active so that its not shown in drop down lists plus is not used by cache system
	//and mark it deleted = 1 
	Etn.executeCmd("update site_menus set version = version + 1, updated_by = "+escape.cote(""+Etn.getId())+", updated_on = now(), is_active = 0, deleted = 1 where id = " + escape.cote(menuid));

	out.write("{\"response\":\"success\"}");
%>
