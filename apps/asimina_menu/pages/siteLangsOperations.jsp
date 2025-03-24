<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, org.json.JSONObject, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog, com.etn.asimina.util.SiteHelper"%>
<%@ include file="common.jsp"%>

<%!
    void updateSectionFieldsValue(com.etn.beans.Contexte Etn,String langId,String sectionId,String pagesDb){
        Set rsFields = Etn.execute("select id from "+pagesDb+"sections_fields where section_id="+escape.cote(sectionId));
        while(rsFields.next()){
            String fieldId = rsFields.value("id");
            Etn.executeCmd("delete from "+pagesDb+"sections_fields_details where field_id="+escape.cote(fieldId)+" and langue_id="+escape.cote(langId));
            Etn.executeCmd("insert into "+pagesDb+"sections_fields_details (field_id,langue_id,default_value,placeholder) select "+fieldId+","+langId+
                ",default_value,placeholder from "+pagesDb+"sections_fields_details where field_id="+escape.cote(fieldId)+" order by langue_id limit 1");
        }

        Set rsSections = Etn.execute("select id from "+pagesDb+"bloc_templates_sections where parent_section_id="+escape.cote(sectionId));
        while(rsSections.next()){
            updateSectionFieldsValue(Etn,langId,rsSections.value("id"),pagesDb);
        }
    }
%>
<%
    String langId = parseNull(request.getParameter("lang"));
    String siteId = getSiteId(session);
    String triggerFunction = parseNull(request.getParameter("trigger"));
    String pagesDb = parseNull(GlobalParm.getParm("PAGES_DB"))+".";
    int status = 0;
    JSONObject resp = new JSONObject();
    if("add".equalsIgnoreCase(triggerFunction))
    {
        try{
            Set rsSections = Etn.execute("select id from "+pagesDb+"bloc_templates_sections where bloc_template_id in (select id from "+pagesDb+"bloc_templates where site_id="+escape.cote(siteId)+")");
            while(rsSections.next()){
                updateSectionFieldsValue(Etn,langId,rsSections.value("id"),pagesDb);
            }

            SiteHelper.insertSiteLang(Etn,siteId,langId);
            resp.put("status",status);
            resp.put("msg","Added Successfully");
        }catch(Exception e){
            resp.put("status",1);
            resp.put("err_msg","Error Occured");
        }
    }
    else if("remove".equalsIgnoreCase(triggerFunction)){
        try{
            SiteHelper.removeSiteLangs(Etn,siteId,langId);
            resp.put("status",status);
            resp.put("msg","Remove Successfully");
        }
        catch(Exception e)
        {
            resp.put("status",1);
            resp.put("err_msg","Error Occured");
        }
    }
    else{
        resp.put("status",1);
        resp.put("err_msg","Invalid Function Triggered");
    }

    out.write(resp.toString());
%>
