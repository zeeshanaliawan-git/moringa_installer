<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.UUID"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape"%>

<%@ include file="common.jsp" %>
<%
	String siteid = getSelectedSiteId(session);

	String json = parseNull(request.getParameter("json"));
	String url = parseNull(request.getParameter("url"));
	String screen = parseNull(request.getParameter("screen"));
	String jsonid = parseNull(request.getParameter("jsonid"));


	int r=  0;
	if(jsonid.equals(""))
	{

		r = Etn.executeCmd("insert into expert_system_json (site_id, screen_name, json, url, json_uuid) values ("+escape.cote(siteid)+","+escape.cote(screen)+","+escape.cote(json)+","+escape.cote(url)+","+escape.cote(UUID.randomUUID().toString())+") ");
	}
	else
	{
		r = Etn.executeCmd("update expert_system_json set url = "+escape.cote(url)+", json = "+escape.cote(json)+" where id = " + escape.cote(jsonid));
	}

	String resp = "SUCCESS";
	if(r == 0) resp = "ERROR";
%>
{"RESPONSE":"<%=resp%>"}
