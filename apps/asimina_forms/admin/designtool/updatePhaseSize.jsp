<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.sql.escape"%>

<%@ include file="common.jsp" %>


<%
	String width = parseNull(request.getParameter("width"));  
	String height = parseNull(request.getParameter("height"));
	String phase = parseNull(request.getParameter("phase"));
	String process = parseNull(request.getParameter("process"));
	String targetProcess = parseNull(request.getParameter("targetProcess"));
	String isExternalPhase = parseNull(request.getParameter("isExternalPhase"));
	if(isExternalPhase.equals("")) isExternalPhase = "0";
	
	int rows =0;	
	if(isExternalPhase.equals("1"))//update coordinates in external_phases table
	{
		String qry = "update external_phases set width = " + escape.cote(width) + ", height = " + escape.cote(height) + " where start_proc = " + escape.cote(process) + " and next_proc = "+escape.cote(targetProcess)+" and next_phase = " + escape.cote(phase)+ "";
		rows = Etn.executeCmd(qry);		
	}
	else
	{
		String qry= "update phases set width = " + escape.cote(width) + ", height = " + escape.cote(height) + " where process =" + replaceQoute(process) + " and phase = " + replaceQoute(phase) + " ";
		rows = Etn.executeCmd(qry);
	}
	
	if (rows > 0)
	{%>
		SUCCESS
	<%
	} 
	else
	{%>
		ERROR
	<%
	}
		
	
%>