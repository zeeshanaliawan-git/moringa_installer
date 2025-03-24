<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common2.jsp" %>


<%
	String process = request.getParameter("process");
	String targetProcess = request.getParameter("targetProcess");
	String targetPhase = request.getParameter("targetPhase");
	String x = parseNull(request.getParameter("topLeftX"));  
	String y = parseNull(request.getParameter("topLeftY"));
	String width = parseNull(request.getParameter("width"));
	String height = parseNull(request.getParameter("height"));
	
	
	Set rs = Etn.execute("select count(0) as c from external_phases where start_proc = "+escape.cote(process)+" and next_proc = "+escape.cote(targetProcess)+" and next_phase = "+escape.cote(targetPhase)+" ");
	rs.next();
	if(Integer.parseInt(rs.value("c")) > 0 )//already exists
	{
%>
	{"RESPONSE_TYPE":"ERROR","MESSAGE":"External phase already exists for this process"}
<%		
	}
	else
	{
		int rows = Etn.executeCmd("insert into external_phases (start_proc, next_proc, next_phase, width, height, topLeftX, topLeftY) values ("+escape.cote(process)+","+escape.cote(targetProcess)+","+escape.cote(targetPhase)+","+escape.cote(width)+","+escape.cote(height)+","+escape.cote(x)+","+escape.cote(y)+")");
		if(rows > 0)
		{
%>
			{"RESPONSE_TYPE":"SUCCESS","MESSAGE":"External phase added"}
<%  	} else { %>
			{"RESPONSE_TYPE":"ERROR","MESSAGE":"Some error occurred while adding external phase for this process"}
<%  	} 
	}
%>