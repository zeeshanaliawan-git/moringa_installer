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
	
	String siteid = getSiteId(session);	
	Set rss = Etn.execute("select * from site_menus where site_id = "+escape.cote(siteid)+" and id = " + escape.cote(menuid));		
	//checking if the menu id provided was of same site as user can temper the url
	if(rss.rs.Rows == 0) 
	{		
		out.write("{\"response\":\"error\",\"msg\":\"Invalid menu provided\"}");
		return;
	}
	
	String applytype = parseNull(request.getParameter("applytype"));
	String replacetags = parseNull(request.getParameter("replacetags"));

	String applyto = parseNull(request.getParameter("apply_to_" + applytype));

	if(applyto.toLowerCase().startsWith("https://")) applyto = applyto.substring(8);
	else if(applyto.toLowerCase().startsWith("http://")) applyto = applyto.substring(7);
	applyto = applyto.trim();
	if(applyto.endsWith("/")) applyto = applyto.substring(0, applyto.lastIndexOf("/"));


	int r = Etn.executeCmd("insert into menu_apply_to (menu_id, apply_type, apply_to, replace_tags) values ("+escape.cote(menuid)+","+escape.cote(applytype)+","+escape.cote(applyto)+", "+escape.cote(replacetags)+") ");

	if(r > 0) 
	{
		Etn.executeCmd("update site_menus set version = version + 1, updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+" where id = " + escape.cote(menuid));
		out.write("{\"response\":\"success\"}");
	}
	else out.write("{\"response\":\"error\"}");

%>
