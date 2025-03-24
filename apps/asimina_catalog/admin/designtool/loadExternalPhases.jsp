<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%
	String process = request.getParameter("process");
	String targetProcess = request.getParameter("targetProcess");
	String sql = " select distinct displayName, phase from phases ph where process = "+escape.cote(targetProcess)+" and phase not in (select next_phase from rules where start_proc = "+escape.cote(process)+" and next_proc = "+escape.cote(targetProcess)+"  ) " ;
	sql += " order by displayName, phase ";	
	Set rs = Etn.execute(sql);	
	int index = 0;
%>
{"PHASES":[
<%
	while(rs.next())
	{
%>
	<% if(index > 0) { %>
	,
	<% } %>
	{"PHASE":
		{
			"NAME":"<%=rs.value("phase")%>",
			"DISPLAYNAME":"<%=rs.value("displayName")%>"
		}
	}
<% 	index++;
	}
%>
]}