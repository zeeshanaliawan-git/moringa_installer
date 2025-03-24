<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%
	//generate UUID and return as csfr token	

	String token = java.util.UUID.randomUUID().toString();
	session.setAttribute("form_token", token);

	out.write("{\"token\":\""+token+"\"}");
%>