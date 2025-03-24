<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>
<%
    String id = parseNull(request.getParameter("id"));
    
    String updateParameters="updated_by = "+escapeCote("" + Etn.getId())+", updated_on = now(), version = version + 1 ";
    Map<String, String[]> parameters = request.getParameterMap();
        for(String parameter : parameters.keySet()) 
         {			 
            if(parameter.equals("id")) continue;
            if(!updateParameters.equals("")) updateParameters += ",";
            updateParameters += parameter + " = " + escapeCote(parseNull(request.getParameter(parameter)));
                
        }
        
    String updateQry =  "UPDATE query_settings SET "+updateParameters+" WHERE qs_uuid = "+ escapeCote(id);

    Etn.executeCmd(updateQry);
    
    JSONObject querySettings = new JSONObject();
    
    out.write(querySettings.toString());
    
    
%>