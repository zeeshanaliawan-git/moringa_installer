<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>
<%
    String id = parseNull(request.getParameter("id"));
    String copyQueryName = parseNull(request.getParameter("name"));
    String copyQueryId = parseNull(request.getParameter("query_id"));
    String copyPath = parseNull(request.getParameter("path"));
    String copyAccess = parseNull(request.getParameter("access"));
    String copyQueryFormat = parseNull(request.getParameter("query_format"));
    String copyPaginate = parseNull(request.getParameter("paginate"));
    String copyItemPerPage = parseNull(request.getParameter("items_per_page"));
        
    String copyQuery =  "INSERT INTO query_settings(qs_uuid, name, query_id, site_id, path, access, query_format, paginate, items_per_page, query_type_id, query_sub_type_id, created_by, created_on, selected_columns, filter_settings, sorting_settings, column_settings) SELECT UUID(), " + escape.cote(copyQueryName) + ", " + escape.cote(copyQueryId) + ", site_id, " + escape.cote(copyPath) + ", " + escape.cote(copyAccess) + ", " + escape.cote(copyQueryFormat) + ", " + escape.cote(copyPaginate) + ", " + escape.cote(copyItemPerPage) + ", query_type_id, query_sub_type_id, " + Etn.getId() + ", NOW(), selected_columns, filter_settings, sorting_settings, column_settings FROM query_settings WHERE qs_uuid = " + escape.cote(id);

    Etn.executeCmd(copyQuery);  
    
%>