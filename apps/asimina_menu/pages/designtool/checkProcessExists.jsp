<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ include file="common.jsp" %>

<%

	String process = parseNull(request.getParameter("process"));
	
	String qry = "select count(0) c from phases where process = '"+replaceQoute(process)+"' ";
	Set rs = Etn.execute(qry);
	rs.next();
	if(Integer.parseInt(rs.value("c")) > 0)
	{
%>
		Process with given name already exists
<%	
	}
	else
	{
%>
		SUCCESS
<%
	} 
%>
