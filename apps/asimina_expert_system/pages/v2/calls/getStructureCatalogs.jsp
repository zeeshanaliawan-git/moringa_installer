<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>
<%
    String type = parseNull(request.getParameter("type"));

    JSONArray structureCatalogNames = new JSONArray();
    JSONObject structureCatalogObject = new JSONObject();

    Set rsStructureCatalog = Etn.execute("select uuid, name from " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".structured_catalogs where type = " +escape.cote(type));

    structureCatalogObject.put("key", "All");
    structureCatalogObject.put("val", "All");

    while(rsStructureCatalog.next()){

        structureCatalogObject = new JSONObject();
        
        structureCatalogObject.put("key", rsStructureCatalog.value("uuid"));                
        structureCatalogObject.put("val", rsStructureCatalog.value("name"));                

        structureCatalogNames.put(structureCatalogObject);
    }

    out.write(structureCatalogNames.toString());    
%>