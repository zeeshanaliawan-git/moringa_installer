<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="org.json.JSONObject"%>

<%

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",0);
    jsonResponse.put("message","Success");
    out.write(jsonResponse.toString());
%>