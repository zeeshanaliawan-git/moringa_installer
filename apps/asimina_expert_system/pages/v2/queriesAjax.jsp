<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map,org.json.JSONObject,org.json.JSONArray"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ include file="/common.jsp" %>

<%
    String queryTypeName = parseNull(request.getParameter("queryTypeName"));
    String queryTypeId = parseNull(request.getParameter("queryTypeId"));
    String siteid = getSelectedSiteId(session);

    Set rsQuerySubTypes = null;
    JSONObject rsp = new JSONObject();
    if(queryTypeName.equals("forms")){
        rsQuerySubTypes = Etn.execute("select distinct pf.form_id as id, process_name as name from " + 
            com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms pf, " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + 
            ".process_form_fields pff where pf.form_id = pff.form_id and site_id = " + escape.cote(siteid));

    } else if(queryTypeName.equals("structured_page") || queryTypeName.equals("structured_content") || queryTypeName.equals("stores")){

        String str = queryTypeName.endsWith("s") ? queryTypeName.substring(0, queryTypeName.length() - 1) : queryTypeName;
        rsQuerySubTypes = Etn.execute("select s.id, s.name from " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + 
            ".bloc_templates s where s.type = "+escape.cote(str)+" and s.site_id = "+escape.cote(siteid));

    } else if (queryTypeName.equals("products")) {

        rsQuerySubTypes = Etn.execute("select distinct catalog_type as id, catalog_type as name from "+
            com.etn.beans.app.GlobalParm.getParm("PREPROD_CATALOG_DB")+".catalogs where site_id = "+escape.cote(siteid));

    } else if (queryTypeName.equals("blocs")) {

        rsQuerySubTypes = Etn.execute("select distinct id, name from "+com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+
            ".bloc_templates where site_id = "+escape.cote(siteid));

    }
    else if (queryTypeName.equals("subsidies")) {

        rsQuerySubTypes = Etn.execute("select distinct id, name from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+
            ".subsidies where site_id = "+escape.cote(siteid));

    }
    else if (queryTypeName.equals("deliveryfees")) {

        rsQuerySubTypes = Etn.execute("select distinct id, name from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+
            ".deliveryfees where site_id = "+escape.cote(siteid));

    }
    else {
        rsQuerySubTypes = Etn.execute("select name as id,name from es_queries where query_type_id="+escape.cote(queryTypeId));
    }

    if(rsQuerySubTypes!=null){
        JSONArray dataArray = new JSONArray();
        while(rsQuerySubTypes.next()){
            JSONObject dataObj = new JSONObject();
            dataObj.put("name", rsQuerySubTypes.value("name"));
            dataObj.put("id", rsQuerySubTypes.value("id"));

            dataArray.put(dataObj);
        }
        rsp.put("data",dataArray);
        rsp.put("status",0);
    }else{
        rsp.put("status",1);
    }
    out.write(rsp.toString());
%>