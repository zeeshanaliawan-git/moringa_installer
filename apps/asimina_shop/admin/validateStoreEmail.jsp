<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="../common.jsp" %>

<%
	String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));
	String name = parseNull(request.getParameter("name"));
	String rowNum = parseNull(request.getParameter("rowNum"));
	
	Set rs = Etn.execute("select count(0) c from store_emails where name = " + escape.cote(name)+" and site_id="+escape.cote(siteId));
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
