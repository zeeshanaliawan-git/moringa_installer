<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/common.jsp" %>

<%
    String querySubType = parseNull(request.getParameter("query_sub_type"));
    String queryType = parseNull(request.getParameter("query_type"));

    JSONArray columnNames = new JSONArray();

	List<String> columnList = null;
    if(queryType.equals("forms"))
	{
		columnList = getFormSelectableCols(Etn, querySubType);
	}
	else
	{
		columnList = getSelectableColumns(Etn, queryType,querySubType);
	}
	
	if(columnList != null)
	{
		columnNames.put("All");
		for(int i = 0; i<columnList.size(); i++)
		{ 
			columnNames.put(columnList.get(i).toLowerCase());
		}
	}

    out.write(columnNames.toString());    
%>