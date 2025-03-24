<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape, java.io.File, com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp" %>
<%
	String jsonId = parseNull(request.getParameter("jsonid"));
	String tag = parseNull(request.getParameter("tag"));

	String isremove = parseNull(request.getParameter("isremove"));
	String resp = "success";

	if(isremove.length() == 0)
	{
		int i = Etn.executeCmd("insert into expert_system_reuse_json (json_id, json_tag) values ("+escape.cote(jsonId)+","+escape.cote(tag)+") ");
		if(i==0) resp = "error";
	}
	else if(isremove.equals("1"))
	{
		String reuseid = tag.substring(tag.indexOf("___escp_") + 8);
		Etn.executeCmd("delete from expert_system_script where json_id = "+escape.cote(jsonId)+"  and parent_json_tag like " + escape.cote(tag + "%"));
		Etn.executeCmd("delete from expert_system_script where json_id = "+escape.cote(jsonId)+"  and json_tag = " + escape.cote(tag));
		Etn.executeCmd("delete from expert_system_reuse_json where json_id = "+escape.cote(jsonId)+"  and id = " + escape.cote(reuseid));
	}
%>
{"response":"<%=resp%>"}