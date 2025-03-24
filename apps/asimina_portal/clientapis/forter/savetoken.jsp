<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="com.etn.asimina.session.ClientSession"%>
<%
	String token = request.getParameter("t");
	if(token != null && token.length() > 0)
	{
		ClientSession.getInstance().addParameter(Etn, request, response, "forter_token", token);	
	}
	
	out.write("{\"status\":0}");
%>