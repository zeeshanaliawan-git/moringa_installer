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

//System.out.println("delete from "+dbname+"redirects where menu_type = "+escape.cote(menu_type)+" and one_to_one = "+escape.cote(onetoone)+" and old_url = "+escape.cote(oldurl)+" and new_url = "+escape.cote(newurl));
	int i = Etn.executeCmd("delete from "+dbname+"redirects where menu_type = "+escape.cote(menu_type)+" and one_to_one = "+escape.cote(onetoone)+" and old_url = "+escape.cote(oldurl)+" and new_url = "+escape.cote(newurl));

	if(i > 0) 
	{
		Etn.executeCmd("insert into "+dbname+"sitemap_audit (created_by, action, success) values ("+escape.cote(""+Etn.getId())+","+escape.cote("Redirection removed. <br>Old url : "+oldurl+"<br>New url : "+newurl+"<br>One-to-one : "+onetoone)+","+escape.cote("1")+") ");
		out.write("{\"response\":\"success\",\"msg\":\"success\"}");
	}
	else 
	{
		out.write("{\"response\":\"error\",\"msg\":\"Error while removing redirection\"}");
	}
%>
