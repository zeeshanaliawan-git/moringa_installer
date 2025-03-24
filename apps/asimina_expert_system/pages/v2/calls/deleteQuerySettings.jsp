<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*, com.etn.beans.app.GlobalParm"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>
<%
    String STATUS_SUCCESS = "SUCCESS", STATUS_ERROR = "ERROR";
	String message = "";
    String status = STATUS_ERROR;
    String requestType = request.getParameter("requestType");
    String id = parseNull(request.getParameter("id"));
	String logedInUserId = parseNull(Etn.getId());
    int rsp = 0;

    JSONObject rspObj = new JSONObject();
    
    if("deleteQuerySettings".equalsIgnoreCase(requestType)){
        Set rsDeleteQuery = Etn.execute("select qs2.* from "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs1 join "+
            GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl qs2 on qs1.site_id=qs2.site_id  "+
            " and qs1.query_id=qs2.query_id where qs2.is_deleted='1' AND qs1.qs_uuid="+escape.cote(id));
    
        if(rsDeleteQuery.next()) {
            rsp = 1;
            status = STATUS_ERROR;
            message = "Duplicate exist in trash. Do you want to force delete";
        }
        else{

            Etn.executeCmd("UPDATE query_settings_tbl SET is_deleted='1',updated_on=now()"+
                ",updated_by="+escape.cote(logedInUserId)+" WHERE qs_uuid = "+escape.cote(id));
            rsp = 2;
            status = STATUS_SUCCESS;
            message = "Successfully Deleted!";
        }
    }
    else if("forceDeleteQuerySettings".equalsIgnoreCase(requestType)){
        String query = "delete qs2.* from "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+
            ".query_settings_tbl qs1 join "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+
            ".query_settings_tbl qs2 on qs1.site_id=qs2.site_id and "+
            " qs1.query_id =qs2.query_id where qs2.is_deleted='1' AND qs1.qs_uuid="+escape.cote(id);
        Etn.executeCmd(query);

        Etn.executeCmd("UPDATE query_settings_tbl SET is_deleted='1',updated_on=now()"+
            ",updated_by="+escape.cote(logedInUserId)+" WHERE qs_uuid = "+escape.cote(id));

        status = STATUS_SUCCESS;
        message = "Successfully Deleted!";

    }
    rspObj.put("status",status);
    rspObj.put("message",message);
    rspObj.put("rsp",rsp);

    out.write(rspObj.toString());

%> 