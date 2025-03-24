<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="common.jsp"%>

<%
	String isprod = parseNull(request.getParameter("pr"));

	if("1".equals(isprod) && (session.getAttribute("CACHE_LOGIN") == null || (Boolean)session.getAttribute("CACHE_LOGIN") == false)) 
	{
		response.sendRedirect("prodcachemanagement.jsp");
		return;
	}


	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB")+"."; //"prod_portal.";

	String id = parseNull(request.getParameter("id"));
	Set rs = Etn.execute("select * from "+dbname+"menu_apply_to where id = " + escape.cote(id));
	rs.next();
	if("url".equals(rs.value("apply_to"))) 
	{
		Etn.executeCmd("update "+dbname+"cached_pages set refresh_now = cached, cached = 0  where is_url_active = 1 and menu_id = "+parseNull(rs.value("menu_id"))+" and url = " + escape.cote("http://" + parseNull(rs.value("apply_to"))) + " or url = " + escape.cote("https://" + parseNull(rs.value("apply_to")) ));
	}
	else
		Etn.executeCmd("update "+dbname+"cached_pages set refresh_now = cached, cached = 0  where is_url_active = 1 and menu_id = "+parseNull(rs.value("menu_id"))+" and url like " + escape.cote("http://" + parseNull(rs.value("apply_to")) + "%") + " or url like " + escape.cote("https://" + parseNull(rs.value("apply_to")) + "%"));
	out.write("{\"response\":\"success\"}");

	Etn.execute("select semfree('"+com.etn.beans.app.GlobalParm.getParm("SEMAPHORE")+"') ");

%>

