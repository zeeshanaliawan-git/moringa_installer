<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ include file="common.jsp" %>


<%

	String actionName = parseNull(request.getParameter("actionName"));
	if(!actionName.equals("") && !actionName.equals("#"))
	{
		Set rs = Etn.execute("select * from actions where name = "+escape.cote(actionName)+" ");
		rs.next();
		String tableName = rs.value("paramTableName");
		String primaryKeyCol = rs.value("paramTableIdColumn");
		
		Set paramsRs = Etn.execute("select * from " + tableName );
		Map<String, String> params = new LinkedHashMap<String, String>();
		params.put("#","-- Param --");		
		while(paramsRs.next())
		{
			String val = "";
			for(int i=0;i<paramsRs.ColName.length;i++)
			{
				val += paramsRs.value(paramsRs.ColName[i]) + " | ";
			}
			params.put(paramsRs.value(primaryKeyCol), val);
		}				
%>
<%=addSelectControl("newConnActionParam","newConnActionParam", params, false, 0)%>
<%		
	}
%>