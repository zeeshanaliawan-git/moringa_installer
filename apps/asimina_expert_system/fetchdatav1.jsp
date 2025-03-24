<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set"%>
<%@ include file="/common.jsp"%>
<%@ page import="com.etn.sql.escape, com.etn.util.ItsDate, com.etn.util.*, com.etn.beans.app.GlobalParm,com.etn.util.Base64"%>
<%@page import="java.io.*"%>

<%

    String jsonId = parseNull(request.getParameter("jsonId"));
    String isPreview = parseNull(request.getParameter("is_preview"));

    Set rs = Etn.execute("SELECT * FROM expert_system_json WHERE json_uuid = "+escape.cote(jsonId));
    String jid = "";

    if(rs.next()) jid = rs.value("id");

    if(jid.length() > 0){

        String fdPath = "generatedJsps/fetchdata_"+jid+".jsp";

        if(isPreview.length()>0){
    
            Set queryParamsRs = Etn.execute("SELECT param, default_value FROM expert_system_query_params WHERE json_id = "+escape.cote(jid)+" GROUP BY param;");

            String param = "";
            String value = "";
            String params = "";
            int count = 0;

            if(queryParamsRs.rs.Rows>0) fdPath += "?";

            while(queryParamsRs.next()){

                if(parseNull(request.getParameter(queryParamsRs.value("param"))).length() == 0){
                    param = parseNull(queryParamsRs.value("param"));
                    value = parseNull(queryParamsRs.value("default_value"));
                    
                    fdPath += param+"="+ java.net.URLEncoder.encode(value, "utf-8");
                    if((queryParamsRs.rs.Rows-1) >= ++count) fdPath += "&";
                }
            }
        }

	response.setContentType("application/json");

%>
        <jsp:include page="<%=fdPath%>" >  
            <jsp:param name="jsonId" value="<%=jid%>" />  
        </jsp:include> 
<%
    }
%>

