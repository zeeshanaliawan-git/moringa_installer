<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>
<%
    String updateParameters="created_by = "+escape.cote("" + Etn.getId())+", created_on = now(), qs_uuid = UUID()";
    Map<String, String[]> parameters = request.getParameterMap();
    for(String parameter : parameters.keySet()) 
    {
        if(parameter.equals("id")) continue;

        if(parameter.equals("access") && parseNull(request.getParameter(parameter)).equals("private")) 
            updateParameters += ",query_key = UUID()";

        if(!updateParameters.equals("")) updateParameters += ",";
        updateParameters += parameter + " = " + escape.cote(parseNull(request.getParameter(parameter)));
            
    }

    String updateQry =  "INSERT into query_settings SET "+updateParameters;
    Etn.executeCmd(updateQry);
    
    JSONObject querySettings = new JSONObject();
    
    out.write(querySettings.toString());
    
    
%>