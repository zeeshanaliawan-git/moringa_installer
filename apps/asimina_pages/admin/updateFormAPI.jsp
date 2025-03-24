<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,  org.json.JSONObject, org.json.JSONArray"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;
    int status = STATUS_ERROR;
    try{
        String formId = parseNull(request.getParameter("formId"));
        String pid = parseNull(request.getParameter("pid"));
        //TODO some kind of checksum param

        if(formId.length() > 0 && parseInt(pid) > 0){

            String q = " UPDATE pages p "
                + " JOIN pages_forms pf ON pf.page_id = p.id "
                + " SET p.to_generate = 1, p.to_generate_by = " + escape.cote(pid)
                + " WHERE pf.form_id = " + escape.cote(formId);

            int count = Etn.executeCmd(q);
            if(count > 0){
                q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("SEMAPHORE"))) + ");";
                Etn.execute(q);
            }
            status = STATUS_SUCCESS;
        }
    }
    catch(Exception ex){
        // message = ex.getMessage();
        ex.printStackTrace();
    }

    // JSONObject jsonResponse = new JSONObject();
    // jsonResponse.put("status",status);
    // out.write(jsonResponse.toString());

    //using string to make it efficient as its very simple reponse
    out.write("{ \"status\" : \""+status+"\"}");
%>