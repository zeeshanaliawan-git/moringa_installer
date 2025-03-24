<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape"%>
<%@ include file="common.jsp" %>

<%
	String jsonid = parseNull(request.getParameter("jsonid"));

	int r=  0;
	if(!jsonid.equals(""))
	{
		Etn.executeCmd("delete from expert_system_conditions where rule_id in (select id from expert_system_rules where json_id = "+escape.cote(jsonid)+") ");
		Etn.executeCmd("delete from expert_system_rules where json_id = "+escape.cote(jsonid));
		Etn.executeCmd("delete from expert_system_html where json_id = "+escape.cote(jsonid));
		Etn.executeCmd("delete from expert_system_script where json_id = "+escape.cote(jsonid));
		r = Etn.executeCmd("delete from expert_system_json where id = "+escape.cote(jsonid));
	}
	String resp = "SUCCESS";
	if(r == 0) resp = "ERROR";
%>
{"RESPONSE":"<%=resp%>"}
