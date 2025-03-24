<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>
<%
    String queryid = parseNull(request.getParameter("qid"));
	String siteid = getSelectedSiteId(session);
        
    Set rs = Etn.execute("select * from query_settings where site_id = "+escape.cote(siteid)+" and query_id = "+escape.cote(queryid));

    if(rs.rs.Rows > 0)
	{
		out.write("{\"status\":1}");		
	}
	else out.write("{\"status\":0}");    
%>