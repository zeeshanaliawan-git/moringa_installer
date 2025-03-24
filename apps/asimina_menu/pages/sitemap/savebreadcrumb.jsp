<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.Contexte, java.util.*"%>
<%@include file="../common.jsp"%>
<%@include file="../lib_msg.jsp"%>
<%@include file="urlcommons.jsp"%>


<%
	String selectedSiteId = getSiteId(session);
	
	String isprod = parseNull(request.getParameter("isprod"));
	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";

	String pageid = parseNull(request.getParameter("pageid"));
	String json = parseNull(request.getParameter("json"));
	
	Set rs = Etn.execute("Select c.id from "+dbname+"cached_pages c, "+dbname+"site_menus m where m.id = c.menu_id and m.site_id = "+escape.cote(selectedSiteId)+" and c.id = " + escape.cote(pageid) );
	if(rs.rs.Rows == 0)
	{
		com.etn.util.Logger.error("savebreadcrumb.jsp","SEVERE :: User is trying to manipulate request parameters. User : "+ Etn.getId() );
		out.write("{\"response\":\"error\",\"msg\":\"Unable to save the changes\"}");
		return;
	}


	int i = Etn.executeCmd("update "+dbname+"cached_pages_path set breadcrumb_changed = 1, breadcrumb = "+escape.cote(json)+" where id = " + escape.cote(pageid));
	if(i > 0) out.write("{\"response\":\"success\"}");
	else out.write("{\"response\":\"error\",\"msg\":\"Unable to save the changes\"}");
%>
