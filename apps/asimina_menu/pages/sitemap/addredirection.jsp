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
	String isprod = parseNull(request.getParameter("isprod"));

	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";


	String oldurl = parseNull(request.getParameter("oldurl"));
	String newurl = parseNull(request.getParameter("newurl"));
	String onetoone = parseNull(request.getParameter("onetoone"));
	String menu_type = parseNull(request.getParameter("menu_type"));

	int i = Etn.executeCmd("insert into "+dbname+"redirects (old_url, new_url, one_to_one, menu_type) values ("+escape.cote(oldurl)+","+escape.cote(newurl)+","+escape.cote(onetoone)+", "+escape.cote(menu_type)+") ");

	if(i > 0) 
	{
		Etn.executeCmd("insert into "+dbname+"sitemap_audit (created_by, action, success) values ("+escape.cote(""+Etn.getId())+","+escape.cote("Redirection added. <br>Old url : "+oldurl+"<br>New url : "+newurl+"<br>One-to-one : "+onetoone)+","+escape.cote("1")+") ");

		out.write("{\"response\":\"success\",\"msg\":\"success\"}");
	}
	else out.write("{\"response\":\"error\",\"msg\":\"Error inserting redirection\"}");
%>
