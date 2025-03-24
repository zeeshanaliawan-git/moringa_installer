<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape"%>
<%@ include file="common.jsp" %>

<%
	String ssite = parseNull(session.getAttribute("SELECTED_SITE_ID"));
	String process = parseNull(request.getParameter("process"));
	
	String qry = "select count(0) c from processes where display_name ="+escape.cote(process)+" and site_id="+escape.cote(ssite);
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
		Etn.executeCmd("insert ignore into processes (process_name,display_name,site_id) values ("+escape.cote(process+"-"+ssite)+","+escape.cote(process)+
		","+escape.cote(ssite)+")"); 
%>
		SUCCESS
<%
	} 
%>
