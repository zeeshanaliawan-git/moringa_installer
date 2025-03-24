<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="../common.jsp" %>

<%
	String username = request.getParameter("username");
	String rowNum = request.getParameter("rowNum");
	
	Set rs = Etn.execute("select count(0) c from login where name = " + escape.cote(username));
	rs.next();
	int count = Integer.parseInt(rs.value("c"));
	
	if(count == 0)
	{
%>
{
	"STATUS":"SUCCESS",
	"ROWNUM":"<%=rowNum%>"
}
<% } else { %>
{
	"STATUS":"ERROR",
	"ROWNUM":"<%=rowNum%>"
}
<% } %>
