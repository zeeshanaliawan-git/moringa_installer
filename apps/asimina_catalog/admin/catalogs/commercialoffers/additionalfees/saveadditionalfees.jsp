 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*, com.etn.asimina.util.ActivityLog"%>
<%@ include file="../../../../WEB-INF/include/constants.jsp"%>
<%@ include file="../../../../WEB-INF/include/commonMethod.jsp"%>

<%

    String id = parseNull(request.getParameter("id"));
    int additionalFeeId = 0;

    String cols = "";
    String vals = "";
    String additionalFee = parseNull(request.getParameter("name"));
    String lang1description = parseNull(request.getParameter("lang_1_description"));
    String lang2description = parseNull(request.getParameter("lang_2_description"));
    String lang3description = parseNull(request.getParameter("lang_3_description"));
    String lang4description = parseNull(request.getParameter("lang_4_description"));
    String lang5description = parseNull(request.getParameter("lang_5_description"));
    String visibleTo = parseNull(request.getParameter("visible_to"));
    String startDate = parseNull(request.getParameter("start_date"));
    String endDate = parseNull(request.getParameter("end_date"));
    String selectedsiteid = parseNull(getSelectedSiteId(session));

    if(startDate.length() > 0){

        if(startDate.contains(" ")){

            String[] token = startDate.split(" ");
            startDate = convertDateToStandardFormat(token[0], "yyyy/MM/dd") + " " + token[1];

        }else{

            startDate = convertDateToStandardFormat(startDate, "yyyy/MM/dd");
        }

    }

    if(endDate.length() > 0){

        if(endDate.contains(" ")){

            String[] token = endDate.split(" ");
            endDate = convertDateToStandardFormat(token[0], "yyyy/MM/dd") + " " + token[1];

        }else{

            endDate = convertDateToStandardFormat(endDate, "yyyy/MM/dd");
        }

    }

    if(id.length() == 0)
    {

        if(lang2description.length() == 0) lang2description = lang1description;
        if(lang3description.length() == 0) lang3description = lang1description;
        if(lang4description.length() == 0) lang4description = lang1description;
        if(lang5description.length() == 0) lang5description = lang1description;

        cols = "site_id, created_by, additional_fee, lang_1_description, lang_2_description, lang_3_description, lang_4_description, lang_5_description, visible_to, start_date, end_date";

        vals = escape.cote(selectedsiteid) + "," + escape.cote(""+Etn.getId());

        if(additionalFee.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(additionalFee);

        if(lang1description.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(lang1description);

        if(lang2description.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(lang2description);

        if(lang3description.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(lang3description);

        if(lang4description.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(lang4description);

        if(lang5description.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(lang5description);

        if(visibleTo.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(visibleTo);

        if(startDate.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(startDate);

        if(endDate.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(endDate);

        additionalFeeId = Etn.executeCmd("INSERT INTO additionalfees(" + cols + ") VALUES (" + vals + ")");

        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),additionalFeeId+"","CREATED","Additional Fee",additionalFee,selectedsiteid);
    }
    else
    {
        String q = "update additionalfees set version = version + 1, updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());

        if(additionalFee.length() == 0) q += ", additional_fee = NULL";
        else q += ", additional_fee = " + escape.cote(additionalFee);

        if(lang1description.length() == 0) q += ", lang_1_description = NULL";
        else q += ", lang_1_description = " + escape.cote(lang1description);

        if(lang2description.length() == 0) q += ", lang_2_description = NULL";
        else q += ", lang_2_description = " + escape.cote(lang2description);

        if(lang3description.length() == 0) q += ", lang_3_description = NULL";
        else q += ", lang_3_description = " + escape.cote(lang3description);

        if(lang4description.length() == 0) q += ", lang_4_description = NULL";
        else q += ", lang_4_description = " + escape.cote(lang4description);

        if(lang5description.length() == 0) q += ", lang_5_description = NULL";
        else q += ", lang_5_description = " + escape.cote(lang5description);

        if(visibleTo.length() == 0) q += ", visible_to = NULL";
        else q += ", visible_to = " + escape.cote(visibleTo);

        if(startDate.length() == 0) q += ", start_date = NULL";
        else q += ", start_date = " + escape.cote(startDate);

        if(endDate.length() == 0) q += ", end_date = NULL";
        else q += ", end_date = " + escape.cote(endDate);

        q += " where id = " + escape.cote(id);

        Etn.executeCmd(q);
        System.out.println(q);
        additionalFeeId = parseInt(id);

        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"UPDATED","Additional Fee",additionalFee,selectedsiteid);

    }

    if(additionalFeeId > 0){

        String ruleApply = parseNull(request.getParameter("rule_apply"));
        String ruleApplyValue = parseNull(request.getParameter("rule_apply_value"));
        String[] elementType = request.getParameterValues("element_type");
        String[] elementTypeValue = request.getParameterValues("element_type_value");

        cols = "add_fee_id, rule_apply, rule_apply_value, element_type, element_type_value";
        vals = escape.cote(""+additionalFeeId) + "," + escape.cote(ruleApply) + "," + escape.cote(ruleApplyValue);

        Etn.executeCmd("DELETE FROM additionalfee_rules WHERE add_fee_id = "+escape.cote(""+additionalFeeId));

        for(int i = 0; i < elementType.length; i++){

            if(parseNull(elementType[i]).length() != 0 && parseNull(elementTypeValue[i]).length() != 0) {
                Etn.executeCmd("INSERT INTO additionalfee_rules(" + cols + ") VALUES (" + vals + "," + escape.cote(elementType[i]) + "," + escape.cote(elementTypeValue[i]) + ")");
            }
        }
    }

    String extUrl = parseNull(com.etn.beans.app.GlobalParm.getParm("CATALOG_EXTERNAL_URL"));
    String params = "?";

    if(id.length() == 0) params += "is_save=";
    else params += "is_edit=";

    if(additionalFeeId > 0) params += "1";

    if(extUrl.length() == 0) response.sendRedirect("additionalfees.jsp"+params);
    else response.sendRedirect(extUrl + "admin/catalogs/commercialoffers/additionalfees/additionalfees.jsp"+params);

%>