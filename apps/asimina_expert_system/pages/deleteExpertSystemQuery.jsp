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
	String queryId = parseNull(request.getParameter("query_id"));

	int r=  0;
	String resp = "";

	if(!queryId.equals(""))
	{
		Etn.executeCmd("delete from expert_system_queries where id = " + escape.cote(queryId));
		Etn.executeCmd("delete from expert_system_query_params where query_id = " + escape.cote(queryId));
		resp = "SUCCESS";
	}
%>
{"RESPONSE":"<%=resp%>"}
