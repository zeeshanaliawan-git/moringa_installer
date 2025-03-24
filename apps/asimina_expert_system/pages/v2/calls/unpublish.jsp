<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>
<% 
    String uuids = parseNull(request.getParameter("uuid"));
    String uuid[] = null;

    if(uuids.length() > 0)
    	uuid = uuids.split(",");

    for(String id : uuid)
	{
		Etn.executeCmd("delete from query_settings_published where qs_uuid = " + escape.cote(id));
	}
%>