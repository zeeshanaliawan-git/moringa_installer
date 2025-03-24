<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape"%>

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
	
	String typ = parseNull(request.getParameter("typ"));
	String isfavicon = parseNull(request.getParameter("isfavicon"));
	
	String q = "";
	if("1".equals(isfavicon)) q = "update site_menus set version = version + 1, updated_by = "+escape.cote(""+Etn.getId())+", updated_on = now(), favicon = '' where id = " + escape.cote(menuid);
	else if("s".equalsIgnoreCase(typ)) q = "update site_menus set version = version + 1, updated_by = "+escape.cote(""+Etn.getId())+", updated_on = now(), small_logo_file = '' where id = " + escape.cote(menuid);
	else q = "update site_menus set version = version + 1, updated_by = "+escape.cote(""+Etn.getId())+", updated_on = now(), logo_file = '' where id = " + escape.cote(menuid);

	int id = Etn.executeCmd(q);

	if(id > 0) 
	{
		out.write("{\"response\":\"success\"}");
	}
	else out.write("{\"response\":\"error\"}");
%>
