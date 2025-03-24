<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.util.Logger"%>

<%
	/*
	* This jsp is called from portal engine Publish.java
	*/

	String ip = com.etn.asimina.util.ActivityLog.getIP(request);
	
	if("127.0.0.1".equals(ip) || "localhost".equalsIgnoreCase(ip))
	{
		request.getRequestDispatcher("/admin/menuJsAjax.jsp").forward(request,response);	
	}
	else 
	{
		Logger.error("publishMenuJs.jsp","This page cannot be access from external IP");
		response.setStatus( 403 );
		out.write("{}");
	}
%>