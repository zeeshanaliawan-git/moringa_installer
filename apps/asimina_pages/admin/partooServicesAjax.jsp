<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,java.util.ArrayList, java.util.*,com.etn.pages.*,org.json.JSONObject" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp"%>

<%
    JSONObject obj = new JSONObject();
    String status = "true";
    String message = "";
    String siteId=parseNull(session.getAttribute("SELECTED_SITE_ID"));
    String requestType = parseNull(request.getParameter("requestType"));


    try{
        
        if(requestType.equalsIgnoreCase("autocomplete")){
    		String catalogDb = parseNull(GlobalParm.getParm("CATALOG_DB"));
            String value = parseNull(request.getParameter("value"));
            JSONArray respArray = new JSONArray();
            Set rs = Etn.execute("select * from "+catalogDb+".tags where site_id="+escape.cote(siteId)+" and label like "+escape.cote('%'+value+'%')+" and label like '%gcid:%'");
            while(rs.next()){
                if(parseNull(rs.value("id")).substring(0,4).equalsIgnoreCase("gcid")){

                    JSONObject respObj = new JSONObject();
                    respObj.put("id",rs.value("id"));
                    respObj.put("site_id",rs.value("site_id"));
                    respObj.put("label",rs.value("label"));

                    respArray.put(respObj);
                }
            }
            obj.put("data",respArray);
        }
        else if(requestType.equalsIgnoreCase("removeService")){

            String id = parseNull(request.getParameter("id"));
            Etn.executeCmd("Update partoo_services set to_delete=1 WHERE id="+escape.cote(id));
            Etn.execute("SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("PARTOO_SEMAPHORE"))) + ")");
            message = "Deleted successfully.";
        }
        else{
            status = "false";
            message = "Invalid request type.";
        }

    }catch(Exception e){
        status = "false";
        message = e.getMessage();
    }
    obj.put("status",status);
    obj.put("message",message);

    out.write(obj.toString());
%>
