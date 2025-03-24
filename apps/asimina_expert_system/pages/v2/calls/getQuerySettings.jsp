<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>
<%
    String id = parseNull(request.getParameter("id"));
    Set rsQuerySettings = Etn.execute("select name, query_id, access, query_key, query_format, paginate, items_per_page from query_settings where qs_uuid = "+escape.cote(id));
    rsQuerySettings.next();
    
    JSONObject querySettings = new JSONObject();
    
    for(int i = 0; i<rsQuerySettings.ColName.length; i++){
        querySettings.put(rsQuerySettings.ColName[i].toLowerCase(), rsQuerySettings.value(i));
    }
    
    out.write(querySettings.toString());
    
    
%>