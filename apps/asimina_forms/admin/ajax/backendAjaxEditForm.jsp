<%-- Reviewed By Awais --%>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ page import="java.io.File"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language" %>
<%@ include file="../../common2.jsp"%>

<%

    String action = parseNull(request.getParameter("action"));

    if(action.equals("editFormParameter")){

        String formId = parseNull(request.getParameter("formid"));
        String langId = parseNull(request.getParameter("langid"));
        Set rs = null;

        if(formId.length() > 0){

            rs = Etn.execute("SELECT html_form_id, form_class, form_method, form_enctype, form_autocomplete, label_display FROM process_forms WHERE form_id = " + escape.cote(formId));

            rs.next();
        }

        LinkedHashMap<String, String> formMethodValues = new LinkedHashMap<String, String>();
        formMethodValues.put("post","Post");
        formMethodValues.put("get","Get");

        LinkedHashMap<String, String> formAutoCompleteValues = new LinkedHashMap<String, String>();
        formAutoCompleteValues.put("off","Off");
        formAutoCompleteValues.put("on","On");

        LinkedHashMap<String, String> formLabelDisplayValues = new LinkedHashMap<String, String>();
        formLabelDisplayValues.put("tal","Top aligned");
        formLabelDisplayValues.put("lal","Left aligned");
%>

       <div class="col-sm-12" style="padding-bottom: 10px;">
            <button id="selectionSave" type="button" class="btn btn-primary" style="max-height:44.25px; z-index: 1000;" onclick='onEditFormParameter()'>Save</button>               
       </div>

        <form name='editfrmparam' id='editfrmparam' method='post' action='editProcess.jsp?form_id=<%=escapeCoteValue(formId)%>' >

            <input type="hidden" name="isEditFormParameter" value="1">
            <input type="hidden" name="lang_id" value="<%=escapeCoteValue(langId)%>">

            <div class="collapse show p-3">

                <div class="form-group row">
                    <label for="html_form_id" class='col-md-3 control-label'>ID:</label>
                    <div class='col-md-9'>
                        <div class="input-group">
                            <input type="text" id="html_form_id" name="html_form_id" placeholder="id" value='<%=escapeCoteValue(getRsValue(rs, "html_form_id"))%>' class="form-control"/>
                        </div>
                    </div>
                </div>

                <div class="form-group row">
                    <label for="form_class" class='col-md-3 control-label'>Class:</label>
                    <div class='col-md-9'>
                        <div class="input-group">
                            <input type="text" id="form_class" name="form_class" placeholder="class" value='<%=escapeCoteValue(getRsValue(rs, "form_class"))%>' class="form-control"/>
                        </div>
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="form_method" class='col-md-3 control-label'>Method: </label>
                    <div class='col-md-9'>
                        <%
                                ArrayList arr = new ArrayList<String>();
                                arr.add(getRsValue(rs, "form_method"));
                        %>
                        <%=addSelectControl("form_method", "form_method", formMethodValues, arr, "custom-select", "", false)%>
                    </div>
                </div>

                <div class="form-group row">
                    <label for="form_enctype" class='col-md-3 control-label'>Enctype:</label>
                    <div class='col-md-9'>
                        <div class="input-group">
                            <input type="text" id="form_enctype" name="form_enctype" placeholder="enctype" value='<%=escapeCoteValue(getRsValue(rs, "form_enctype"))%>' class="form-control"/>
                        </div>
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="form_autocomplete" class='col-md-3 control-label'>Autocomplete: </label>
                    <div class='col-md-9'>
                        <%
                                arr = new ArrayList<String>();
                                arr.add(getRsValue(rs, "form_autocomplete"));
                        %>
                        <%=addSelectControl("form_autocomplete", "form_autocomplete", formAutoCompleteValues, arr, "custom-select", "", false)%>
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="label_display" class='col-md-3 control-label'>Label display: </label>
                    <div class='col-md-9'>
                        <%
                                arr = new ArrayList<String>();
                                arr.add(getRsValue(rs, "label_display"));
                        %>
                        <%=addSelectControl("label_display", "label_display", formLabelDisplayValues, arr, "custom-select", "", false)%>
                    </div>
                </div>
            </div>
        </form>

<%
    } else if(action.equals("updateLineSeq")){

        String formId = parseNull(request.getParameter("formid"));
        String lineId = parseNull(request.getParameter("lineid"));
        String lineSeq = parseNull(request.getParameter("lineSeq"));

        String[] lineIdList = lineId.split(",");
        String[] lineSeqList = lineSeq.split(",");

        for(int i=0; i < lineIdList.length && lineIdList.length == lineSeqList.length; i++){

            Etn.execute("UPDATE process_form_lines_unpublished SET line_seq = " + escape.cote(lineSeqList[i]) + " WHERE form_id = " + escape.cote(formId) + " AND id = " + escape.cote(lineIdList[i]));
        }

        callPagesUpdateFormAPI(formId, Etn.getId());
        updateVersionForm(Etn, formId);

    } else if(action.equals("update_user_status")){

        String username = parseNull(request.getParameter("username"));
        String isUserActive = parseNull(request.getParameter("is_user_active"));
        String portaldb = parseNull(request.getParameter("portaldb"));
        String client_key = parseNull(request.getParameter("c_key"));
        String siteId = getSelectedSiteId(session);
        String status = "";
        System.out.println("c_key::"+client_key);
        if(isUserActive.length() > 0){
			AsiminaAuthenticationHelper asiminaAuthenticationHelper = new AsiminaAuthenticationHelper(Etn,siteId,portaldb,GlobalParm.getParm("CLIENT_PASS_SALT"));
			AsiminaAuthentication asiminaAuthentication = asiminaAuthenticationHelper.getAuthenticationObject();
            if(isUserActive.equals("0"))
				asiminaAuthentication.activate(username);
            else if(isUserActive.equals("1"))
                asiminaAuthentication.deactivate(username);
        }

        //Etn.execute("UPDATE " + portaldb + ".clients SET is_active = " + escape.cote(status) + " WHERE email = " + escape.cote(email) + " AND site_id = " + escape.cote(siteId));

        out.write("{\"resp\":\"success\"}");

    } else if(action.equals("addLineParameter")){

        String formId = parseNull(request.getParameter("formid"));
        String lineUuid = UUID.randomUUID().toString();

        String lineId = "line";
        String lineSeq = parseNull(request.getParameter("line_seq"));
        int defaultLineId = 0;

        Set rs = Etn.execute("SELECT count(id) as line_count, max(line_seq) as line_seq FROM process_form_lines_unpublished WHERE form_id = " + escape.cote(formId));

        if(rs.next()){

            lineId += (parseNullInt(rs.value("line_count"))+1)+"";

            if(lineSeq.length() > 0) {

                Etn.execute("UPDATE process_form_lines_unpublished SET line_seq = line_seq + 1 WHERE form_id = " + escape.cote(formId) + " AND line_seq > " + escape.cote(lineSeq));//change

                lineSeq = (parseNullInt(lineSeq)+1)+"";
            }
            else lineSeq = (parseNullInt(rs.value("line_seq"))+1)+"";
        }

        Etn.executeCmd("INSERT INTO process_form_lines_unpublished (id, form_id, line_id, line_width, line_seq) VALUES (" + escape.cote(lineUuid) + ", " + escape.cote(formId) + ", " + escape.cote(lineId) + ", " + escape.cote("12") + ", " + escape.cote(lineSeq) + ")");

        updateVersionForm(Etn, formId);        

        out.write(lineUuid);

    } else if(action.equals("editLineParameter")){

        String formId = parseNull(request.getParameter("formid"));

        String lineuuid = parseNull(request.getParameter("lineuuid"));
        String lineSeq = parseNull(request.getParameter("lineSeq"));
        String lineId = "";
        int defaultLineId = 0;
        Set rs = null;

        if(formId.length() > 0){

            rs = Etn.execute("SELECT max(line_seq) as line_seq FROM process_form_lines_unpublished WHERE form_id = " + escape.cote(formId));

            if(rs.next()){

                if(lineSeq.length() == 0)
                    lineSeq = (parseNullInt(rs.value("line_seq")))+"";
            }        

            rs = Etn.execute("SELECT line_id, line_class, line_width FROM process_form_lines_unpublished WHERE form_id = " + escape.cote(formId) + " AND id = " + escape.cote(lineuuid));

            rs.next();

            if(getRsValue(rs, "line_id").length() > 0) lineId = getRsValue(rs, "line_id");
        }

        LinkedHashMap<String, String> lineWidthValues = new LinkedHashMap<String, String>();
        lineWidthValues.put("12","12 columns");
        lineWidthValues.put("10","10 columns");
        lineWidthValues.put("8","8 columns");
        lineWidthValues.put("6","6 columns");
        lineWidthValues.put("4","4 columns");
        lineWidthValues.put("2","2 columns");
%>

       <div class="col-sm-12 text-right" style="padding-bottom: 10px;">
            <button id="selectionSave" type="button" class="btn btn-primary" style="max-height:44.25px; z-index: 1000;" onclick='onEditLineParameter()'>Save</button>               
       </div>

        <form name='editlineparam' id='editlineparam' method='post' action='editProcess.jsp?form_id=<%=escapeCoteValue(formId)%>' >

            <input type="hidden" name="isEditLineParameter" value="1">
            <input type="hidden" name="line_uuid" value="<%=escapeCoteValue(lineuuid)%>">
            <input type="hidden" name="line_seq" value="<%=escapeCoteValue(lineSeq)%>">

            <div class="collapse show p-3">

                <div class="form-group row">
                    <label for="line_id" class='col-md-3 control-label'>ID:</label>
                    <div class='col-md-9'>
                        <div class="input-group">
                            <input type="text" id="line_id" name="line_id" placeholder="id" value='<%=escapeCoteValue(lineId)%>' class="form-control"/>
                        </div>
                    </div>
                </div>

                <div class="form-group row">
                    <label for="line_class" class='col-md-3 control-label'>Class:</label>
                    <div class='col-md-9'>
                        <div class="input-group">
                            <input type="text" id="line_class" name="line_class" placeholder="class" value='<%=escapeCoteValue(getRsValue(rs, "line_class"))%>' class="form-control"/>
                        </div>
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="line_width"  class='col-md-3 control-label'>Width: </label>
                    <div class='col-md-9'>
                        <%
                                ArrayList arr = new ArrayList<String>();
                                arr.add(getRsValue(rs, "line_width"));
                        %>
                        <%=addSelectControl("line_width", "line_width", lineWidthValues, arr, "custom-select", "", false)%>
                    </div>
                </div>
            </div>
        </form>

<%
    } else if(action.equals("formAddRule")){

        String formId = parseNull(request.getParameter("fid"));
        String langId = parseNull(request.getParameter("langId"));

        Set processRs = Etn.execute("SELECT pff.field_id, case when coalesce(pffd.label,'') = '' then pff.db_column_name else pffd.label end as label FROM process_form_fields_unpublished pff, process_form_field_descriptions_unpublished pffd "+
						" WHERE pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pff.form_id = " + escape.cote(formId) + 
						" AND pffd.langue_id = "+escape.cote(langId)+
						" AND pff.type NOT IN ( " + escape.cote("label") + "," + escape.cote("noneditablefield") + "," + escape.cote("hr_line") + "," + escape.cote("multextfield") + "," + escape.cote("emptyblock") + "," + escape.cote("hyperlink") + "," + escape.cote("imgupload") + "," + escape.cote("button") + "," + escape.cote("fileupload") + "," + escape.cote("range") + "," + escape.cote("textrecaptcha") + ")");

        Set freqRuleRs = Etn.execute("SELECT fr.* FROM freq_rules_unpublished fr LEFT OUTER JOIN process_form_fields_unpublished pff ON fr.form_id = pff.form_id AND fr.field_id = pff.field_id WHERE fr.form_id = " + escape.cote(formId));

        LinkedHashMap<String, String> fieldValues = new LinkedHashMap<String, String>();
        fieldValues.put("", "-- fields --");
        fieldValues.put("ip", "Ip");

        while(processRs.next()){
            fieldValues.put(parseNull(processRs.value("field_id")), parseNull(processRs.value("label")));
        }

        LinkedHashMap<String, String> periodValues = new LinkedHashMap<String, String>();
        periodValues.put("", "-- period --");
        periodValues.put("daily", "Daily");
        periodValues.put("weekly", "Weekly");
        periodValues.put("monthly", "Monthly");
%>

        <div class="form-group row d-none rule_clone">
            <label for="rules" class='col-md-3 control-label'>Rules:</label>
            <div class='col-md-9'>
                <div class="input-group">
                    <%
                        ArrayList arr = new ArrayList<String>();
                        arr.add("");
                    %>
                    <%=addSelectControl("field_id", "field_id", fieldValues, arr, "custom-select", "", false)%>
                    <input type="text" id="frequency" name="frequency" placeholder="frequency" value='' class="form-control"/>
                    <%
                        arr = new ArrayList<String>();
                        arr.add("");
                    %>
                    <%=addSelectControl("period", "period", periodValues, arr, "custom-select", "", false)%>
                    <div class="input-group-append" onclick="remove_rule('', this, '<%=escapeCoteValue(formId)%>')">
                        <button class="btn btn-danger" type="button">X</button>
                    </div>
                </div>
            </div>
        </div>

        <form name='addrulefrm' id='addrulefrm' method='post' action='editProcess.jsp?form_id=<%=escapeCoteValue(formId)%>' >

            <input type="hidden" name="isSaveFormRule" value="1">
            <input type="hidden" name="lang_id" value="<%=escapeCoteValue(langId)%>">            

            <div class="mb-2 text-right">
                <button type="button" class="btn btn-primary" onclick="formRuleSave()">Save</button>
            </div>

            <div class="btn-group col-12" style="padding-left:0px; padding-right:0px" role="group" aria-label="Basic example">
                <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#global_information" role="button" aria-expanded="false" aria-controls="global_information">Global information</button>                         
            </div>

            <!-- Global information -->
            <div class="collapse show p-3" id="global_information">

                <%
                    String fieldId = "";
                    String id = "";
                    while(freqRuleRs.next()){
                        
                        fieldId = parseNull(freqRuleRs.value("field_id"));
                        id = parseNull(freqRuleRs.value("id"));
                %>
                        <div class="form-group row defined_rules">
                            <label for="rules" class='col-md-3 control-label'>Rules:</label>
                            <div class='col-md-9'>
                                <div class="input-group">
                                    <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(freqRuleRs, "field_id"));
                                    %>
                                    <%=addSelectControl("field_id", "field_id", fieldValues, arr, "custom-select", "", false)%>
                                    <input type="text" id="frequency" name="frequency" placeholder="frequency" value='<%=escapeCoteValue(getRsValue(freqRuleRs, "frequency"))%>' class="form-control"/>
                                    <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(freqRuleRs, "period"));
                                    %>
                                    <%=addSelectControl("period", "period", periodValues, arr, "custom-select", "", false)%>
                                    <div class="input-group-append" onclick="remove_rule('<%=escapeCoteValue(id)%>', this, '<%=escapeCoteValue(formId)%>')">
                                        <button class="btn btn-danger" type="button">X</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                <%
                    }
                %>

                <div class="col-sm-12">
                    <button type="button" class="btn btn-default btn-success text-right" onclick="add_rule_field();">+ Add More</button>
                </div>
            </div>
            <!-- /Global information -->                                

        </form>
    
<%
    } else if(action.equals("deleteLineParameter")){

        String formId = parseNull(request.getParameter("formid"));
        String lineuuid = parseNull(request.getParameter("lineuuid"));
        String formType = parseNull(request.getParameter("form_type"));

        String tableName = "";
        String dbColumnName = "";

        Set rs = Etn.execute("SELECT table_name FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId));
        
        if(rs.next())
            tableName = parseNull(rs.value("table_name"));

        Etn.execute("DELETE FROM process_form_field_descriptions_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id IN ( select field_id from process_form_fields_unpublished where form_id = " + escape.cote(formId) + " and line_id = " + escape.cote(lineuuid) + " )" );
        Etn.execute("DELETE FROM process_form_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND line_id = " + escape.cote(lineuuid));
        Etn.execute("DELETE FROM process_form_lines_unpublished WHERE form_id = " + escape.cote(formId) + " AND id = " + escape.cote(lineuuid));

        updateVersionForm(Etn, formId);
    } else if(action.equals("deleteElement")){

        String formId = parseNull(request.getParameter("formid"));
        String lineId = parseNull(request.getParameter("lineid"));
        String fieldId = parseNull(request.getParameter("fieldid"));
        String columnName = parseNull(request.getParameter("column"));

        Etn.execute("DELETE FROM process_form_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND line_id = " + escape.cote(lineId) + " AND field_id = " + escape.cote(fieldId));

        Etn.execute("DELETE FROM process_form_field_descriptions_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));
		updateVersionForm(Etn, formId);

        String pagesDb = parseNull(GlobalParm.getParm("PAGES_DB"));
        
        Etn.executeCmd("update "+pagesDb+".freemarker_pages set updated_ts=now() where id in (select parent_page_id from "+pagesDb+".pages where id in "+
            "(select page_id from "+pagesDb+".pages_forms where form_id="+escape.cote(formId)+" and type='freemarker') group by parent_page_id)");
        Etn.executeCmd("update "+pagesDb+".structured_contents set updated_ts=now() where id in (select parent_page_id from "+pagesDb+".pages where id in "+
            "(select page_id from "+pagesDb+".pages_forms where form_id="+escape.cote(formId)+" and type='structured') group by parent_page_id)");
    } else if(action.equals("add_field_type")){

        String siteId = getSelectedSiteId(session);
        String formid = parseNull(request.getParameter("formid"));
        String lineid = parseNull(request.getParameter("lineid"));
        String langid = parseNull(request.getParameter("langid"));
        String formType = "";

        Set rs = Etn.execute("select pff.db_column_name, pf.type from process_forms_unpublished pf, process_form_fields_unpublished pff where pf.form_id = pff.form_id and pff.form_id = " + escape.cote(formid) + " and site_id = " + escape.cote(parseNull(siteId)));

        List<String> fieldList = new ArrayList<String>();

        if(rs.next()){

            formType = parseNull(rs.value("type"));
            fieldList.add(parseNull(rs.value("db_column_name")));
        }

        while(rs.next()){

            fieldList.add(parseNull(rs.value("db_column_name")));
        }

%>
 
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">

                    <ul class="px-0" style="list-style: none;">
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="autocomplete" field-type-label="Autocomplete" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Autocomplete
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                                        
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="button" field-type-label="Button" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Button
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="checkbox" field-type-label="Checkbox" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Checkbox
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="dropdown" field-type-label="Select" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Select
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="textdate" field-type-label="Date" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Date
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="textdatetime" field-type-label="Datetime" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Datetime
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="email" field-type-label="Email" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Email
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
<!--                     
                        <li class="btn border-0 w-100 mb-1" style="background-color: #CCC;">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Empty block
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
 -->                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="fileupload" field-type-label="File upload" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    File
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="texthidden" field-type-label="Hidden" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Hidden
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="hyperlink" field-type-label="Hyperlink" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Hyperlink
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="imgupload" field-type-label="Image upload" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Image
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
<!--                     
                        <li class="btn border-0 w-100 mb-1" style="background-color: #CCC;">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Insert line
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
 -->                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="label" field-type-label="Label" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Label
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
<!--                     
                        <li class="btn border-0 w-100 mb-1" style="background-color: #CCC;">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Multiple textfield
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
 -->                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="number" field-type-label="Number" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Number
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="radio" field-type-label="Radio" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Radio
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>

                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="textrecaptcha" field-type-label="Re-captcha" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Re-captcha
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="range" field-type-label="Slider" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Slider
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>

                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="tel" field-type-label="Telephone" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Telephone
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="textfield" field-type-label="Textfield" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Textfield
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    
                        <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="texttextarea" field-type-label="Textarea" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                            <div class="row">
                                <div class="col text-left text-capitalize font-weight-bold">
                                    Textarea
                                </div>
                                <div class="col text-right">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    </ul>

                    <%
                        if(formType.equalsIgnoreCase("sign_up")){

                    %>
                        <hr/>

                        <ul class="px-0" style="list-style: none;">
                    <%

                        if(!fieldList.contains("_etn_login")){
                    %>
                            <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="textfield" field-type-label="Login" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" special-field="1" db-column-name="login" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                                <div class="row">
                                    <div class="col text-left text-capitalize font-weight-bold">
                                        Login
                                    </div>
                                    <div class="col text-right">
                                        <i data-feather="plus-circle"></i>
                                    </div>
                                </div>
                            </li>
                    <%
                        }

                        if(!fieldList.contains("_etn_landline_phone")){
                    %>
                            <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="tel" field-type-label="Fixe phone" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" special-field="1" db-column-name="landline_phone" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                                <div class="row">
                                    <div class="col text-left text-capitalize font-weight-bold">
                                        Fixe phone
                                    </div>
                                    <div class="col text-right">
                                        <i data-feather="plus-circle"></i>
                                    </div>
                                </div>
                            </li>
                    <%
                        }

                        if(!fieldList.contains("_etn_birthdate")){
                    %>
                            <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="textdate" field-type-label="Birthdate" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" special-field="1" db-column-name="birthdate" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                                <div class="row">
                                    <div class="col text-left text-capitalize font-weight-bold">
                                        Birthdate
                                    </div>
                                    <div class="col text-right">
                                        <i data-feather="plus-circle"></i>
                                    </div>
                                </div>
                            </li>
                    <%
                        }

                        if(!fieldList.contains("_etn_lang")){
                    %>
                            <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="dropdown" field-type-label="Language" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" special-field="1" db-column-name="lang" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                                <div class="row">
                                    <div class="col text-left text-capitalize font-weight-bold">
                                        Language
                                    </div>
                                    <div class="col text-right">
                                        <i data-feather="plus-circle"></i>
                                    </div>
                                </div>
                            </li>
                    <%
                        }

                        if(!fieldList.contains("_etn_time_zone")){
                    %>
                            <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="dropdown" field-type-label="Timezone" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" special-field="1" db-column-name="time_zone" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                                <div class="row">
                                    <div class="col text-left text-capitalize font-weight-bold">
                                        Timezone
                                    </div>
                                    <div class="col text-right">
                                        <i data-feather="plus-circle"></i>
                                    </div>
                                </div>
                            </li>
                    <%
                        }

                        if(!fieldList.contains("_etn_gender")){
                    %>
                            <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="radio" field-type-label="Gender" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" special-field="1" db-column-name="gender" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                                <div class="row">
                                    <div class="col text-left text-capitalize font-weight-bold">
                                        Gender
                                    </div>
                                    <div class="col text-right">
                                        <i data-feather="plus-circle"></i>
                                    </div>
                                </div> 
                            </li>
                    <%
                        }

                        if(!fieldList.contains("_etn_password")){
                    %>
                            <li class="btn border-0 w-100 mb-1 btn-modal add_field_to_form" field-type="password" field-type-label="Password" line-form-id="<%=escapeCoteValue(formid)%>" line-id="<%=escapeCoteValue(lineid)%>" lang-id="<%=escapeCoteValue(langid)%>" special-field="1" db-column-name="password" style="background-color: #CCC;" data-toggle="modal" data-target="#add_field_to_form">
                                <div class="row">
                                    <div class="col text-left text-capitalize font-weight-bold">
                                        Password
                                    </div>
                                    <div class="col text-right">
                                        <i data-feather="plus-circle"></i>
                                    </div>
                                </div> 
                            </li>
                    <%
                        }
                    %>                                                                            
                            </ul>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
<%
    } else if(action.equals("configure_field")){

        Language defaultLanguage = getLangs(Etn,session).get(0);

        String formId = parseNull(request.getParameter("formid"));
        String lineId = parseNull(request.getParameter("lineid"));
        String fieldId = parseNull(request.getParameter("fieldid"));
        String langId = parseNull(request.getParameter("langid"));
        String fieldType = parseNull(request.getParameter("field_type"));
        String fieldTypeLabel = parseNull(request.getParameter("field_type_label"));
        String target = parseNull(request.getParameter("target"));
        String defaultLangId = defaultLanguage.getLanguageId();
        String specialField = parseNull(request.getParameter("special_field"));
        String dbColumnNameSp = parseNull(request.getParameter("dbcolumnname_sp"));

        LinkedHashMap<String, String> fieldTypeValues = new LinkedHashMap<String, String>();
//        fieldTypeValues.put(""," ---select--- ");
//        fieldTypeValues.put("hs","Header section");
//        fieldTypeValues.put("fts","Footer section");
        fieldTypeValues.put("fs","Form section");
//        fieldTypeValues.put("rs","Rule section");

        LinkedHashMap<String, String> fontWeightValues = new LinkedHashMap<String, String>();
        fontWeightValues.put("-1"," ---select--- ");
        fontWeightValues.put("100","100");
        fontWeightValues.put("200","200");
        fontWeightValues.put("300","300");
        fontWeightValues.put("400","400");
        fontWeightValues.put("500","500");
        fontWeightValues.put("600","600");
        fontWeightValues.put("700","700");
        fontWeightValues.put("800","800");
        fontWeightValues.put("900","900");

        LinkedHashMap<String, String> elementTriggerValues = new LinkedHashMap<String, String>();
        elementTriggerValues.put(""," ---select--- ");
        elementTriggerValues.put("onblur","onBlur");
        elementTriggerValues.put("onchange","onChange");
        elementTriggerValues.put("onclick","onClick");
        elementTriggerValues.put("onkeydown","onKeyDown");
        elementTriggerValues.put("onkeypress","onKeyPress");
        elementTriggerValues.put("onkeyup","onKeyUp");

        LinkedHashMap<String, String> buttonTypeValues = new LinkedHashMap<String, String>();
        buttonTypeValues.put("button","Button");

        LinkedHashMap<String, String> hrefTargetValues = new LinkedHashMap<String, String>();
        hrefTargetValues.put("_blank","Next");
        hrefTargetValues.put("_self","Self"); 

        LinkedHashMap<String, String> dateFormatValues = new LinkedHashMap<String, String>();
        dateFormatValues.put("d/m/Y","DD/MM/YYYY");
        dateFormatValues.put("m/d/Y","MM/DD/YYYY"); 

        ArrayList arr = new ArrayList<String>();

        Set rs = null;
        Set searchFilterRs = null;
        Set resultFilterRs = null;
        String useToSearch = "";
        String isUseToSearch = "0";
        String formReplies = "";
        String isFormReplies = "0";
        String disabledDbColumnName = "";

        if(formId.length() > 0 && lineId.length() > 0 && fieldId.length() > 0){
            
            rs = Etn.execute("SELECT * FROM process_form_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND line_id = " + escape.cote(lineId) + " AND field_id = " + escape.cote(fieldId));

            if(rs.rs.Rows > 0)
                rs.next();

            searchFilterRs = Etn.execute("SELECT * FROM form_search_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));

            if(searchFilterRs.rs.Rows > 0){

                useToSearch = "checked='true'";
                isUseToSearch = "1";
            }

            resultFilterRs = Etn.execute("SELECT * FROM form_result_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));

            if(resultFilterRs.rs.Rows > 0){

                formReplies = "checked='true'";
                isFormReplies = "1";
            }
        }

        Set formFieldDescriptionRs = Etn.execute("SELECT * FROM process_form_field_descriptions_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));

        Map<String, Map<String, String>> formFieldDescriptionMap = new HashMap<String, Map<String, String>>();
        Map<String, String> fieldMap = null;

        String fieldLabel = "";
        String fieldPlaceholder = "";
        String fieldErrorMessage = "";
        String fieldValue = "";
        String fieldOptions = "";
        String fieldOptionQuery = "";
        String fieldLangId = "";

        while(formFieldDescriptionRs.next()){

            fieldLabel = parseNull(formFieldDescriptionRs.value("label"));
            fieldPlaceholder = parseNull(formFieldDescriptionRs.value("placeholder"));
            fieldErrorMessage = parseNull(formFieldDescriptionRs.value("err_msg"));
            fieldValue = parseNull(formFieldDescriptionRs.value("value"));
            fieldOptions = parseNull(formFieldDescriptionRs.value("options"));
            fieldOptionQuery = parseNull(formFieldDescriptionRs.value("option_query"));
            fieldLangId = parseNull(formFieldDescriptionRs.value("langue_id"));

            fieldMap = new HashMap<String, String>();

            fieldMap.put("label", fieldLabel);
            fieldMap.put("placeholder", fieldPlaceholder);
            fieldMap.put("err_msg", fieldErrorMessage);
            fieldMap.put("value", fieldValue);
            fieldMap.put("options", fieldOptions);
            fieldMap.put("option_query", fieldOptionQuery);

            formFieldDescriptionMap.put(formId + "_" + fieldId + "_" + fieldLangId, fieldMap);
        }

        List<Language> languages = getLangs(Etn,session);
        int lc = 0;
        String clc = "";
        String ckcls = "";

        String otherLanguageAttr = "";
        String otherLanguageValueAttr = "";
        if(!defaultLangId.equalsIgnoreCase(langId) && langId.length() > 0){

            otherLanguageAttr = "disabled";
            otherLanguageValueAttr = "readonly";
        }
%>
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <form name='addfrmfield' id='addfrmfield' method='post' action='editProcess.jsp?form_id=<%=escapeCoteValue(formId)%>'>
					<input type="hidden" name="lang_id" value="<%=escapeCoteValue(langId)%>">
                <div class="col-12">
                    <div class="mb-2 text-right">
                        <input class="btn btn-primary" type="button" onclick="saveFormFields()" value="Save">
                    </div>
                    <!-- /Button zone -->

                    
                        <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapseExample" role="button" aria-expanded="false" aria-controls="collapseExample">Global information</button>                          
                        <div class="collapse show p-2" id="collapseExample">

                            <input type="hidden" name="add_form_fields" value="1" />
                            <input type="hidden" name="lineid" value="<%=escapeCoteValue(lineId)%>" />
                            <input type="hidden" name="fieldid" value="<%=escapeCoteValue(fieldId)%>">
                            <input type="hidden" name="langid" value="<%=escapeCoteValue(langId)%>">
                            <input type="hidden" name="type" id="ftype" value="<%=escapeCoteValue(fieldType)%>" />

                        <%
                            if(fieldId.length() > 0){
                                disabledDbColumnName = " disabled ";
                        %>
                                <input type="hidden" name="is_update_field" value="1" />
                        <%
                            }

                            if(!fieldType.equals("button") && !fieldType.equals("label")){
                        %>

                            <div class="form-group row">
                                <label for="element_type" class='col-md-3 control-label'>Element type:</label>
                                <div class='col-md-9'>
                                    <div class="input-group">
                                        <input type="text" id="element_type" name="element_type" value='<%=escapeCoteValue(fieldTypeLabel)%>' class="form-control" disabled />
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row ">
                                <label for="field_section" class='col-md-3 control-label'>Field section: </label>
                                <div class='col-md-9'>
                                    <%

                                            if(getRsValue(rs, "field_type").length() > 0)
                                                arr.add(getRsValue(rs, "field_type"));
                                            else
                                                arr.add("fs");
                                    %>
                                    <%=addSelectControl("field_type", "field_type", fieldTypeValues, arr, "custom-select", otherLanguageAttr, false)%>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label for="always_visible" class='col-md-3 control-label'>Always visible?:</label>
                                <div class='col-md-3'>
                                    <%
                                        String alwaysVisible = getRsValue(rs, "always_visible");
                                        String isAlwaysVisible = "1";

                                        if(alwaysVisible.length() == 0 || alwaysVisible.equals("1")) alwaysVisible = "checked='true'";
                                        else {

                                            alwaysVisible = "";
                                            isAlwaysVisible = "0";
                                        }

                                        if(fieldType.equals("textrecaptcha")) alwaysVisible += " disabled ";

                                        String required = getRsValue(rs, "required");
                                        String isRequired = required;

                                        if(required.equals("1")) required = "checked='true'";

                                        if(fieldType.equals("textrecaptcha")) required += " checked='true' disabled ";
                                    %>
                                    <input type="checkbox" id="always_visible" value='<%=isAlwaysVisible%>' class="form-check-input ml-1" onclick="elementChecked(this)" <%=alwaysVisible%> <%=otherLanguageAttr%>/>
                                    <input type="hidden" name="always_visible" value="<%=isAlwaysVisible%>" />
                                </div>
                                <label for="required" class='col-md-3 control-label'>Required?:</label>
                                <div class='col-md-3'>
                                    <input type="checkbox" id="required" value='<%=escapeCoteValue(getRsValue(rs, "required"))%>' class="form-check-input ml-1" onclick="elementChecked(this)" <%=required%> <%=otherLanguageAttr%>/>
                                    <input type="hidden" name="required" value="<%=isRequired%>" />
                                </div>
                            </div>

                        <%
                            }

                            String hiddenField = getRsValue(rs, "hidden");
                            String isHiddenField = hiddenField;

                            if(hiddenField.equals("1")) hiddenField = "checked='true'";
                            
                            if(fieldType.equals("textrecaptcha") || fieldType.equals("button") || fieldType.equals("label")){


                        %>
                                    <div class="form-group row">

                                        <label for="hidden" class='col-md-3 control-label'>Field hidden?:</label>
                                        <div class='col-md-3'>
                                            <input type="checkbox" id="hidden_field" value='' class="form-check-input ml-1" onclick="elementChecked(this)"  <%=hiddenField%> <%=otherLanguageAttr%> />
                                            <input type="hidden" name="hidden_field" value="<%=isHiddenField%>" />
                                        </div>
                                    </div>
                        <%
                            }

                            if(!fieldType.equals("textrecaptcha")) {

                                if(!fieldType.equals("button") && !fieldType.equals("label")){
                        %>
                                    <div class="form-group row">
                                        <label for="rule_field" class='col-md-3 control-label'>Rule field?:</label>
                                        <div class='col-md-3'>
                                            <%
                                                String ruleField = getRsValue(rs, "rule_field");
                                                String isRuleField = ruleField;

                                                if(ruleField.equals("1")) ruleField = "checked='true'";
                                            %>
                                            <input type="checkbox" id="rule_field" value='<%=escapeCoteValue(getRsValue(rs, "rule_field"))%>' class="form-check-input ml-1" onclick="elementChecked(this)" <%=ruleField%> <%=otherLanguageAttr%>/>
                                            <input type="hidden" name="rule_field" value="<%=isRuleField%>" />
                                        </div>
                                        <label for="use_to_search" class='col-md-3 control-label'>Use to search?:</label>
                                        <div class='col-md-3'>
                                            <input type="checkbox" id="use_to_search" value='' class="form-check-input ml-1" onclick="elementChecked(this)" <%=useToSearch%> <%=otherLanguageAttr%> />
                                            <input type="hidden" name="use_to_search" value="<%=escapeCoteValue(isUseToSearch)%>" />
                                        </div>
                                    </div>

                                    <div class="form-group row">
                                        <label for="form_replies" class='col-md-3 control-label'>Display in form replies?:</label>
                                        <div class='col-md-3'>
                                            <input type="checkbox" id="form_replies" value='' class="form-check-input ml-1" onclick="elementChecked(this)"  <%=formReplies%> <%=otherLanguageAttr%> />
                                            <input type="hidden" name="form_replies" value="<%=escapeCoteValue(isFormReplies)%>" />
                                        </div>

                                        <label for="hidden" class='col-md-3 control-label'>Field hidden?:</label>
                                        <div class='col-md-3'>
                                            <input type="checkbox" id="hidden_field" value='' class="form-check-input ml-1" onclick="elementChecked(this)"  <%=hiddenField%> <%=otherLanguageAttr%> />
                                            <input type="hidden" name="hidden_field" value="<%=isHiddenField%>" />
                                        </div>
                                    </div>

                                    <div class="form-group row">

                        <%
                                    if(fieldType.equals("checkbox") || fieldType.equals("radio")){
                        %>
                                        <label for="element_option_class" class='col-md-3 control-label'>Display Inline:</label>
                                        <div class='col-md-3'>
                        <%
                                        String elementOptionClass = getRsValue(rs, "element_option_class");
                                        String isOptionClass = elementOptionClass;

                                        if(elementOptionClass.length() > 0) elementOptionClass = "checked='true'";
                        %>
                                            <input type="checkbox" onclick="updateOptionClass(this)" class="form-check-input ml-1" <%=elementOptionClass%> <%=otherLanguageAttr%> />
                                            <input type="hidden" id="element_option_class" name="element_option_class" value="<%=escapeCoteValue(isOptionClass)%>">
                                        </div>

                                        <label for="element_option_others" class='col-md-3 control-label'>Enable "Other":</label>
                                        <div class='col-md-3'>
                                            <%
                                                String elementOptionOthers = getRsValue(rs, "element_option_others");
                                                String isOptionOthers = elementOptionOthers;

                                                if(elementOptionOthers.equals("1")) elementOptionOthers = "checked='true'";
                                                if(isOptionOthers.length() == 0) isOptionOthers = "0";
                                            %>
                                            <input type="checkbox" id="element_option_others" value='<%=escapeCoteValue(getRsValue(rs, "element_option_others"))%>' class="form-check-input ml-1" onclick="elementChecked(this)" <%=elementOptionOthers%> />
                                            <input type="hidden" name="element_option_others" value="<%=isOptionOthers%>" />
                                        </div>

                        <%
                                    } else if(fieldType.equals("hyperlink")){
                        %>
                                        <label for="href_chckbx" class='col-md-3 control-label'>Checkbox?:</label>
                                        <div class='col-md-3'>
                        <%
                                        String hrefCheckbox = getRsValue(rs, "href_chckbx");
                                        String isHrefCheckbox = hrefCheckbox;

                                        if(hrefCheckbox.length() == 0) hrefCheckbox = "checked='true'";
                                        else if(hrefCheckbox.equals("1")) hrefCheckbox = "checked='true'";

                                        if(isHrefCheckbox.length() == 0) isHrefCheckbox = "1";
                        %>
                                            <input type="checkbox" id="href_chckbx" value='' class="form-check-input ml-1" onclick="elementChecked(this)" <%=hrefCheckbox%> <%=otherLanguageAttr%>/>
                                            <input type="hidden" name="href_chckbx" value="<%=isHrefCheckbox%>" />
                                        </div>
                        <%
                                    }
                        %>
                                        </div>
                        <%
                                }

                                if(!fieldType.equals("imgupload") && !fieldType.equals("button")){
                        %>

                                    <div class="form-group row">
                                        <label for="label" class='col-md-3 col-form-label'>Label:</label>
                                            <div class='col-md-9' >
                        <%
                                if(target.equalsIgnoreCase("process")){

                                    lc = 0;
                                    clc = "";
                                    ckcls = "";
                                    fieldLabel = "";

                                    for(Language lang : languages){

                                        if(lc++ == 0){

                                            clc = "multilingual=\"true\"";
                                            ckcls = "ckeditor_label";

                                        } else {

                                            clc = "style=\"display: none;\"";
                                            ckcls = "";
                                        }


                                        if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()))
                                            fieldLabel = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()).get("label");

                                        if(fieldType.equals("label")){
                        %>
                                            <textarea class="form-control <%=ckcls%> ignore_xss" rows="5" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" name="label_<%=lang.getLanguageId()%>" id="label_<%=lang.getLanguageId()%>" <%=clc%>><%=escapeCoteValue(fieldLabel)%></textarea>    
                        <%
                                        } else {
                        %>    
                                            <input type="text" class="form-control ignore_xss" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="label_<%=lang.getLanguageId()%>" name="label_<%=lang.getLanguageId()%>" value='<%=escapeCoteValue(fieldLabel)%>' <%=clc%> />
                        <%
                                        }
    
                                    }
                                } else if(target.equalsIgnoreCase("editProcess")){

                                    if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId))
                                        fieldLabel = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId).get("label");

                             
										if(fieldType.equals("label")){
                        %>
										<textarea class="form-control ckeditor_label ignore_xss" rows="5" data-language-id="<%=langId%>" name="label_<%=langId%>" id="label_<%=langId%>"><%=escapeCoteValue(fieldLabel)%></textarea>
                        <%                         
                                    } else {
                        %>
                                        <input type="text" class="form-control ignore_xss" data-language-id="<%=langId%>" id="label_<%=langId%>" name="label_<%=langId%>" value="<%=escapeCoteValue(fieldLabel)%>" <%=clc%> />
                        <%
                                    }
                                }
                        %>
                                            </div>
                                        </div>
                        <%
                                }

                                if(!fieldType.equals("button")){

                                    String dbcname = getRsValue(rs, "db_column_name");
                                    if(specialField.equals("1") && dbColumnNameSp.length() > 0 && dbcname.length() == 0){

                                        dbcname = dbColumnNameSp;
                                        disabledDbColumnName = " readonly ";
                                    }
                        %>
                                        <div class="form-group row">
                                            <label for="db_column_name" class='col-md-3 col-form-label is-required'>DB column name:</label>
                                            <div class='col-md-9'>
                                                <input type="text" id="db_column_name" name="db_column_name" value='<%=escapeCoteValue(dbcname)%>' class="form-control" <%=otherLanguageAttr%> <%=disabledDbColumnName%>/>
                                                <div class="invalid-feedback">Db column name is mandatory.</div>
                                            </div>
                                        </div>
                        <%
                            if(!fieldType.equals("button") && !fieldType.equals("hyperlink") && !fieldType.equals("label") && !fieldType.equals("imgupload") && !fieldType.equals("range")){
                        %>

                                <div class="form-group row">
                                    <label for="err_msg" class='col-md-3 col-form-label'>Error message:</label>
                                    <div class='col-md-9'>


                        <%
                                    if(target.equalsIgnoreCase("process")){

                                        lc = 0;
                                        clc = "";
                                        fieldErrorMessage = "";

                                        for(Language lang : languages){

                                            if(lc++ == 0){

                                                clc = "multilingual=\"true\"";

                                            } else {

                                                clc = "style=\"display: none;\"";
                                            }

                                            if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()))
                                                fieldErrorMessage = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()).get("err_msg");
                        %>
                                            <input type="text" class="form-control" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="err_msg_<%=lang.getLanguageId()%>" name="err_msg_<%=lang.getLanguageId()%>" value='<%=escapeCoteValue(fieldErrorMessage)%>' <%=clc%> />
                        <%
                                        }

                                    } else if(target.equalsIgnoreCase("editprocess")){

                                        if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId))
                                            fieldErrorMessage = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId).get("err_msg");
                        %>
                                        <input type="text" class="form-control" data-language-id="<%=langId%>" id="err_msg_<%=langId%>" name="err_msg_<%=langId%>" value="<%=escapeCoteValue(fieldErrorMessage)%>" <%=clc%> />
                        <%
                                    }
                        %>
                                    </div>
                                </div>
                        <%
                            }

                                if(fieldType.equals("textdate") || fieldType.equals("textdatetime")){
                        %>
                                        <div class="form-group row">
                                            <label for="date_format" class='col-md-3 col-form-label'>Date format:</label>
                                            <div class='col-md-9'>
                                                <%
                                                    arr.add(getRsValue(rs, "date_format"));
                                                %>
                                                <%=addSelectControl("date_format", "date_format", dateFormatValues, arr, "custom-select", otherLanguageAttr, false)%>
                                            </div>
                                        </div>
                        <%
                                }

                                    if(fieldType.equals("fileupload")){

                                        Set filesRs = Etn.execute("SELECT * FROM supported_files;");
                        %>                                        
                                        <div class="form-group row">
                                            <label for="file_extension" class='col-md-3 col-form-label is-required'>File type:</label>
                                            <div class='col-md-9'>
                                                <div class="col-sm-12  form-check-inline">
                                                    
                        <%
                                        String checkedExtension = "";
                                        while(filesRs.next()){

                                            if(getRsValue(rs, "file_extension").contains(parseNull(filesRs.value("extension")))){

                                                checkedExtension = "checked";
    
                                            } else {

                                                checkedExtension = "";

                                            }

                        %>
                                            <div class="mt-2 ml-2">
                                                <label class="js-focus-visible custom-control custom-checkbox">
                                                    <input type="checkbox" id="file_extension" name="file_extension" value='<%=escapeCoteValue(parseNull(filesRs.value("extension")))%>' class="custom-control-input" <%=otherLanguageAttr%> <%=checkedExtension%> />
                                                    <span class="custom-control-label"><%=parseNull(filesRs.value("extension"))%></span>
                                                </label>
                                            </div>
                        <%
                                        }
                        %>
                                                </div>
                                                <div class="invalid-feedback">File type is mandatory.</div>

                                            </div>
                                        </div>
                        <%
                                    } 

                                    if(fieldType.equals("hyperlink")){
                        %>
                                        <div class="form-group row">
                                            <label for="img_href_url" class='col-md-3 col-form-label'>Url:</label>
                                            <div class='col-md-9'>
                                                <input type="text" id="img_href_url" name="img_href_url" value='<%=escapeCoteValue(getRsValue(rs, "img_href_url"))%>' class="form-control" <%=otherLanguageAttr%>/> 
                                            </div>
                                        </div>

                                        <div class="form-group row ">
                                            <label for="href_target" class='col-md-3 control-label'>Target: </label>
                                            <div class='col-md-9'>
                                                <%
                                                    arr.add(getRsValue(rs, "href_target"));
                                                %>
                                                <%=addSelectControl("href_target", "href_target", hrefTargetValues, arr, "custom-select", otherLanguageAttr, false)%>
                                            </div>
                                        </div>
                        <%
                                    }

                                    if(fieldType.equals("tel")){

                                        LinkedHashMap<String, String> defaultCountryValues = new LinkedHashMap<String, String>();
                                        defaultCountryValues.put("","---select---");
                                        defaultCountryValues.put("af","Afghanistan (‫افغانستان‬‎)");
                                        defaultCountryValues.put("al","Albania (Shqipëri)");
                                        defaultCountryValues.put("dz","Algeria (‫الجزائر‬‎)");
                                        defaultCountryValues.put("as","American Samoa");
                                        defaultCountryValues.put("ad","Andorra");
                                        defaultCountryValues.put("ao","Angola");
                                        defaultCountryValues.put("ai","Anguilla");
                                        defaultCountryValues.put("ag","Antigua and Barbuda");
                                        defaultCountryValues.put("ar","Argentina");
                                        defaultCountryValues.put("am","Armenia (Հայաստան)");
                                        defaultCountryValues.put("aw","Aruba");
                                        defaultCountryValues.put("au","Australia");
                                        defaultCountryValues.put("at","Austria (Österreich)");
                                        defaultCountryValues.put("az","Azerbaijan (Azərbaycan)");
                                        defaultCountryValues.put("bs","Bahamas");
                                        defaultCountryValues.put("bh","Bahrain (‫البحرين‬‎)");
                                        defaultCountryValues.put("bd","Bangladesh (বাংলাদেশ)");
                                        defaultCountryValues.put("bb","Barbados");
                                        defaultCountryValues.put("by","Belarus (Беларусь)");
                                        defaultCountryValues.put("be","Belgium (België)");
                                        defaultCountryValues.put("bz","Belize");
                                        defaultCountryValues.put("bj","Benin (Bénin)");
                                        defaultCountryValues.put("bm","Bermuda");
                                        defaultCountryValues.put("bt","Bhutan (འབྲུག)");
                                        defaultCountryValues.put("bo","Bolivia");
                                        defaultCountryValues.put("ba","Bosnia and Herzegovina (Босна и Херцеговина)");
                                        defaultCountryValues.put("bw","Botswana");
                                        defaultCountryValues.put("br","Brazil (Brasil)");
                                        defaultCountryValues.put("io","British Indian Ocean Territory");
                                        defaultCountryValues.put("vg","British Virgin Islands");
                                        defaultCountryValues.put("bn","Brunei");
                                        defaultCountryValues.put("bg","Bulgaria (България)");
                                        defaultCountryValues.put("bf","Burkina Faso");
                                        defaultCountryValues.put("bi","Burundi (Uburundi)");
                                        defaultCountryValues.put("kh","Cambodia (កម្ពុជា)");
                                        defaultCountryValues.put("cm","Cameroon (Cameroun)");
                                        defaultCountryValues.put("ca","Canada");
                                        defaultCountryValues.put("cv","Cape Verde (Kabu Verdi)");
                                        defaultCountryValues.put("bq","Caribbean Netherlands");
                                        defaultCountryValues.put("ky","Cayman Islands");
                                        defaultCountryValues.put("cf","Central African Republic (République centrafricaine)");
                                        defaultCountryValues.put("td","Chad (Tchad)");
                                        defaultCountryValues.put("cl","Chile");
                                        defaultCountryValues.put("cn","China (中国)");
                                        defaultCountryValues.put("cx","Christmas Island");
                                        defaultCountryValues.put("cc","Cocos (Keeling) Islands");
                                        defaultCountryValues.put("co","Colombia");
                                        defaultCountryValues.put("km","Comoros (‫جزر القمر‬‎)");
                                        defaultCountryValues.put("cd","Congo (DRC) (Jamhuri ya Kidemokrasia ya Kongo)");
                                        defaultCountryValues.put("cg","Congo (Republic) (Congo-Brazzaville)");
                                        defaultCountryValues.put("ck","Cook Islands");
                                        defaultCountryValues.put("cr","Costa Rica");
                                        defaultCountryValues.put("ci","Côte d’Ivoire");
                                        defaultCountryValues.put("hr","Croatia (Hrvatska)");
                                        defaultCountryValues.put("cu","Cuba");
                                        defaultCountryValues.put("cw","Curaçao");
                                        defaultCountryValues.put("cy","Cyprus (Κύπρος)");
                                        defaultCountryValues.put("cz","Czech Republic (Česká republika)");
                                        defaultCountryValues.put("dk","Denmark (Danmark)");
                                        defaultCountryValues.put("dj","Djibouti");
                                        defaultCountryValues.put("dm","Dominica");
                                        defaultCountryValues.put("do","Dominican Republic (República Dominicana)");
                                        defaultCountryValues.put("ec","Ecuador");
                                        defaultCountryValues.put("eg","Egypt (‫مصر‬‎)");
                                        defaultCountryValues.put("sv","El Salvador");
                                        defaultCountryValues.put("gq","Equatorial Guinea (Guinea Ecuatorial)");
                                        defaultCountryValues.put("er","Eritrea");
                                        defaultCountryValues.put("ee","Estonia (Eesti)");
                                        defaultCountryValues.put("et","Ethiopia");
                                        defaultCountryValues.put("fk","Falkland Islands (Islas Malvinas)");
                                        defaultCountryValues.put("fo","Faroe Islands (Føroyar)");
                                        defaultCountryValues.put("fj","Fiji");
                                        defaultCountryValues.put("fi","Finland (Suomi)");
                                        defaultCountryValues.put("fr","France");
                                        defaultCountryValues.put("gf","French Guiana (Guyane française)");
                                        defaultCountryValues.put("pf","French Polynesia (Polynésie française)");
                                        defaultCountryValues.put("ga","Gabon");
                                        defaultCountryValues.put("gm","Gambia");
                                        defaultCountryValues.put("ge","Georgia (საქართველო)");
                                        defaultCountryValues.put("de","Germany (Deutschland)");
                                        defaultCountryValues.put("gh","Ghana (Gaana)");
                                        defaultCountryValues.put("gi","Gibraltar");
                                        defaultCountryValues.put("gr","Greece (Ελλάδα)");
                                        defaultCountryValues.put("gl","Greenland (Kalaallit Nunaat)");
                                        defaultCountryValues.put("gd","Grenada");
                                        defaultCountryValues.put("gp","Guadeloupe");
                                        defaultCountryValues.put("gu","Guam");
                                        defaultCountryValues.put("gt","Guatemala");
                                        defaultCountryValues.put("gg","Guernsey");
                                        defaultCountryValues.put("gn","Guinea (Guinée)");
                                        defaultCountryValues.put("gw","Guinea-Bissau (Guiné Bissau)");
                                        defaultCountryValues.put("gy","Guyana");
                                        defaultCountryValues.put("ht","Haiti");
                                        defaultCountryValues.put("hn","Honduras");
                                        defaultCountryValues.put("hk","Hong Kong (香港)");
                                        defaultCountryValues.put("hu","Hungary (Magyarország)");
                                        defaultCountryValues.put("is","Iceland (Ísland)");
                                        defaultCountryValues.put("in","India (भारत)");
                                        defaultCountryValues.put("id","Indonesia");
                                        defaultCountryValues.put("ir","Iran (‫ایران‬‎)");
                                        defaultCountryValues.put("iq","Iraq (‫العراق‬‎)");
                                        defaultCountryValues.put("ie","Ireland");
                                        defaultCountryValues.put("im","Isle of Man");
                                        defaultCountryValues.put("il","Israel (‫ישראל‬‎)");
                                        defaultCountryValues.put("it","Italy (Italia)");
                                        defaultCountryValues.put("jm","Jamaica");
                                        defaultCountryValues.put("jp","Japan (日本)");
                                        defaultCountryValues.put("je","Jersey");
                                        defaultCountryValues.put("jo","Jordan (‫الأردن‬‎)");
                                        defaultCountryValues.put("kz","Kazakhstan (Казахстан)");
                                        defaultCountryValues.put("ke","Kenya");
                                        defaultCountryValues.put("ki","Kiribati");
                                        defaultCountryValues.put("xk","Kosovo");
                                        defaultCountryValues.put("kw","Kuwait (‫الكويت‬‎)");
                                        defaultCountryValues.put("kg","Kyrgyzstan (Кыргызстан)");
                                        defaultCountryValues.put("la","Laos (ລາວ)");
                                        defaultCountryValues.put("lv","Latvia (Latvija)");
                                        defaultCountryValues.put("lb","Lebanon (‫لبنان‬‎)");
                                        defaultCountryValues.put("ls","Lesotho");
                                        defaultCountryValues.put("lr","Liberia");
                                        defaultCountryValues.put("ly","Libya (‫ليبيا‬‎)");
                                        defaultCountryValues.put("li","Liechtenstein");
                                        defaultCountryValues.put("lt","Lithuania (Lietuva)");
                                        defaultCountryValues.put("lu","Luxembourg");
                                        defaultCountryValues.put("mo","Macau (澳門)");
                                        defaultCountryValues.put("mk","Macedonia (FYROM) (Македонија)");
                                        defaultCountryValues.put("mg","Madagascar (Madagasikara)");
                                        defaultCountryValues.put("mw","Malawi");
                                        defaultCountryValues.put("my","Malaysia");
                                        defaultCountryValues.put("mv","Maldives");
                                        defaultCountryValues.put("ml","Mali");
                                        defaultCountryValues.put("mt","Malta");
                                        defaultCountryValues.put("mh","Marshall Islands");
                                        defaultCountryValues.put("mq","Martinique");
                                        defaultCountryValues.put("mr","Mauritania (‫موريتانيا‬‎)");
                                        defaultCountryValues.put("mu","Mauritius (Moris)");
                                        defaultCountryValues.put("yt","Mayotte");
                                        defaultCountryValues.put("mx","Mexico (México)");
                                        defaultCountryValues.put("fm","Micronesia");
                                        defaultCountryValues.put("md","Moldova (Republica Moldova)");
                                        defaultCountryValues.put("mc","Monaco");
                                        defaultCountryValues.put("mn","Mongolia (Монгол)");
                                        defaultCountryValues.put("me","Montenegro (Crna Gora)");
                                        defaultCountryValues.put("ms","Montserrat");
                                        defaultCountryValues.put("ma","Morocco (‫المغرب‬‎)");
                                        defaultCountryValues.put("mz","Mozambique (Moçambique)");
                                        defaultCountryValues.put("mm","Myanmar (Burma) (မြန်မာ)");
                                        defaultCountryValues.put("na","Namibia (Namibië)");
                                        defaultCountryValues.put("nr","Nauru");
                                        defaultCountryValues.put("np","Nepal (नेपाल)");
                                        defaultCountryValues.put("nl","Netherlands (Nederland)");
                                        defaultCountryValues.put("nc","New Caledonia (Nouvelle-Calédonie)");
                                        defaultCountryValues.put("nz","New Zealand");
                                        defaultCountryValues.put("ni","Nicaragua");
                                        defaultCountryValues.put("ne","Niger (Nijar)");
                                        defaultCountryValues.put("ng","Nigeria");
                                        defaultCountryValues.put("nu","Niue");
                                        defaultCountryValues.put("nf","Norfolk Island");
                                        defaultCountryValues.put("kp","North Korea (조선 민주주의 인민 공화국)");
                                        defaultCountryValues.put("mp","Northern Mariana Islands");
                                        defaultCountryValues.put("no","Norway (Norge)");
                                        defaultCountryValues.put("om","Oman (‫عُمان‬‎)");
                                        defaultCountryValues.put("pk","Pakistan (‫پاکستان‬‎)");
                                        defaultCountryValues.put("pw","Palau");
                                        defaultCountryValues.put("ps","Palestine (‫فلسطين‬‎)");
                                        defaultCountryValues.put("pa","Panama (Panamá)");
                                        defaultCountryValues.put("pg","Papua New Guinea");
                                        defaultCountryValues.put("py","Paraguay");
                                        defaultCountryValues.put("pe","Peru (Perú)");
                                        defaultCountryValues.put("ph","Philippines");
                                        defaultCountryValues.put("pl","Poland (Polska)");
                                        defaultCountryValues.put("pt","Portugal");
                                        defaultCountryValues.put("pr","Puerto Rico");
                                        defaultCountryValues.put("qa","Qatar (‫قطر‬‎)");
                                        defaultCountryValues.put("re","Réunion (La Réunion)");
                                        defaultCountryValues.put("ro","Romania (România)");
                                        defaultCountryValues.put("ru","Russia (Россия)");
                                        defaultCountryValues.put("rw","Rwanda");
                                        defaultCountryValues.put("bl","Saint Barthélemy");
                                        defaultCountryValues.put("sh","Saint Helena");
                                        defaultCountryValues.put("kn","Saint Kitts and Nevis");
                                        defaultCountryValues.put("lc","Saint Lucia");
                                        defaultCountryValues.put("mf","Saint Martin (Saint-Martin (partie française))");
                                        defaultCountryValues.put("pm","Saint Pierre and Miquelon (Saint-Pierre-et-Miquelon)");
                                        defaultCountryValues.put("vc","Saint Vincent and the Grenadines");
                                        defaultCountryValues.put("ws","Samoa");
                                        defaultCountryValues.put("sm","San Marino");
                                        defaultCountryValues.put("st","São Tomé and Príncipe (São Tomé e Príncipe)");
                                        defaultCountryValues.put("sa","Saudi Arabia (‫المملكة العربية السعودية‬‎)");
                                        defaultCountryValues.put("sn","Senegal (Sénégal)");
                                        defaultCountryValues.put("rs","Serbia (Србија)");
                                        defaultCountryValues.put("sc","Seychelles");
                                        defaultCountryValues.put("sl","Sierra Leone");
                                        defaultCountryValues.put("sg","Singapore");
                                        defaultCountryValues.put("sx","Sint Maarten");
                                        defaultCountryValues.put("sk","Slovakia (Slovensko)");
                                        defaultCountryValues.put("si","Slovenia (Slovenija)");
                                        defaultCountryValues.put("sb","Solomon Islands");
                                        defaultCountryValues.put("so","Somalia (Soomaaliya)");
                                        defaultCountryValues.put("za","South Africa");
                                        defaultCountryValues.put("kr","South Korea (대한민국)");
                                        defaultCountryValues.put("ss","South Sudan (‫جنوب السودان‬‎)");
                                        defaultCountryValues.put("es","Spain (España)");
                                        defaultCountryValues.put("lk","Sri Lanka (ශ්‍රී ලංකාව)");
                                        defaultCountryValues.put("sd","Sudan (‫السودان‬‎)");
                                        defaultCountryValues.put("sr","Suriname");
                                        defaultCountryValues.put("sj","Svalbard and Jan Mayen");
                                        defaultCountryValues.put("sz","Swaziland");
                                        defaultCountryValues.put("se","Sweden (Sverige)");
                                        defaultCountryValues.put("ch","Switzerland (Schweiz)");
                                        defaultCountryValues.put("sy","Syria (‫سوريا‬‎)");
                                        defaultCountryValues.put("tw","Taiwan (台灣)");
                                        defaultCountryValues.put("tj","Tajikistan");
                                        defaultCountryValues.put("tz","Tanzania");
                                        defaultCountryValues.put("th","Thailand (ไทย)");
                                        defaultCountryValues.put("tl","Timor-Leste");
                                        defaultCountryValues.put("tg","Togo");
                                        defaultCountryValues.put("tk","Tokelau");
                                        defaultCountryValues.put("to","Tonga");
                                        defaultCountryValues.put("tt","Trinidad and Tobago");
                                        defaultCountryValues.put("tn","Tunisia (‫تونس‬‎)");
                                        defaultCountryValues.put("tr","Turkey (Türkiye)");
                                        defaultCountryValues.put("tm","Turkmenistan");
                                        defaultCountryValues.put("tc","Turks and Caicos Islands");
                                        defaultCountryValues.put("tv","Tuvalu");
                                        defaultCountryValues.put("vi","U.S. Virgin Islands");
                                        defaultCountryValues.put("ug","Uganda");
                                        defaultCountryValues.put("ua","Ukraine (Україна)");
                                        defaultCountryValues.put("ae","United Arab Emirates (‫الإمارات العربية المتحدة‬‎)");
                                        defaultCountryValues.put("gb","United Kingdom");
                                        defaultCountryValues.put("us","United States");
                                        defaultCountryValues.put("uy","Uruguay");
                                        defaultCountryValues.put("uz","Uzbekistan (Oʻzbekiston)");
                                        defaultCountryValues.put("vu","Vanuatu");
                                        defaultCountryValues.put("va","Vatican City (Città del Vaticano)");
                                        defaultCountryValues.put("ve","Venezuela");
                                        defaultCountryValues.put("vn","Vietnam (Việt Nam)");
                                        defaultCountryValues.put("wf","Wallis and Futuna (Wallis-et-Futuna)");
                                        defaultCountryValues.put("eh","Western Sahara (‫الصحراء الغربية‬‎)");
                                        defaultCountryValues.put("ye","Yemen (‫اليمن‬‎)");
                                        defaultCountryValues.put("zm","Zambia");
                                        defaultCountryValues.put("zw","Zimbabwe");
                                        defaultCountryValues.put("ax","Åland Islands");
                        %>
                                        <div class="form-group row">
                                            <label for="default_country_code" class='col-md-3 col-form-label'>Default country:</label>
                                            <div class='col-md-9'>
                                                <%
                                                    arr.add(getRsValue(rs, "default_country_code"));
                                                %>
                                                <%=addSelectControl("default_country_code", "default_country_code", defaultCountryValues, arr, "custom-select", otherLanguageAttr, false)%>
                                            </div>
                                        </div>

                                        <div class="form-group row">
                                            <label for="allow_country_code" class='col-md-3 col-form-label'>Allow only country code:</label>
                                            <div class='col-md-9'>
                                                <input type="text" id="allow_country_code" name="allow_country_code" value='<%=escapeCoteValue(getRsValue(rs, "allow_country_code"))%>'  class="form-control" placeholder="Ex: FR, BW, CM.." <%=otherLanguageAttr%>/>
                                            </div>
                                        </div>

                                        <div class="form-group row">
                                            <label for="allow_national_mode" class='col-md-3 col-form-label'>Allow national mode:</label>
                                            <div class='col-md-3'>
                                                <%
                                                    String allowNationalMode = getRsValue(rs, "allow_national_mode");
                                                    String isAllowNationalMode = "1";

                                                    if(allowNationalMode.length() == 0 || allowNationalMode.equals("1")) {

                                                        allowNationalMode = "checked='true'";
                                                    
                                                    } else {

                                                        allowNationalMode = "";
                                                        isAllowNationalMode = "0";
                                                    }

                                                    String localCountryName = getRsValue(rs, "local_country_name");
                                                    String isLocalCountryName = localCountryName;

                                                    if(localCountryName.equals("1")) localCountryName = "checked='true'";

                                                %>
                                                <input type="checkbox" id="allow_national_mode" value='<%=isAllowNationalMode%>' class="form-check-input ml-1" onclick="elementChecked(this)" <%=allowNationalMode%> <%=otherLanguageAttr%>/>
                                                <input type="hidden" name="allow_national_mode" value="<%=isAllowNationalMode%>" />
                                            </div>

                                            <label for="local_country_name" class='col-md-3 col-form-label'>Localised country name only?:</label>
                                            <div class='col-md-3'>
                                                <input type="checkbox" id="local_country_name" value='<%=escapeCoteValue(getRsValue(rs, "local_country_name"))%>' class="form-check-input ml-1" onclick="elementChecked(this)" <%=localCountryName%> <%=otherLanguageAttr%>/>
                                                <input type="hidden" name="local_country_name" value="<%=isLocalCountryName%>" />

                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label for="auto_format_tel_number" class='col-md-3 col-form-label'>Format number on input:</label>
                                            <div class='col-md-9'>
												<input type="checkbox" id="auto_format_tel_number" name="auto_format_tel_number" value='1' <%="1".equals(getRsValue(rs, "auto_format_tel_number"))?"checked":""%> class="form-check-input ml-1" onclick="elementChecked(this)" />
                                            </div>
                                        </div>

                        <%
                                    }

                                    if(fieldType.equals("fileupload")){
                        %>

                                        <div class="form-group row">
                                            <label for="file_browser_val" class='col-md-3 col-form-label'>Browser Value:</label>
                                            <div class='col-md-9'>
                                                <input type="text" id="file_browser_val" name="file_browser_val" value='<%=escapeCoteValue(getRsValue(rs, "file_browser_val"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                            </div>
                                        </div>

                        <%
                                    }

                                    if(!fieldType.equals("checkbox") && !fieldType.equals("dropdown") && !fieldType.equals("hyperlink") && !fieldType.equals("label") && !fieldType.equals("radio") && !fieldType.equals("range")){
                        %>

                                        <div class="form-group row">
                                            <label for="placeholder" class='col-md-3 col-form-label'>Placeholder:</label>
                                            <div class='col-md-9'>
                        <%
                                            if(target.equalsIgnoreCase("process")){

                                                lc = 0;
                                                clc = "";
                                                fieldPlaceholder = "";

                                                for(Language lang : languages){

                                                    if(lc++ == 0){

                                                        clc = "multilingual=\"true\"";

                                                    } else {

                                                        clc = "style=\"display: none;\"";
                                                    }

                                                    if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()))
                                                        fieldPlaceholder = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()).get("placeholder");
                        %>
                                                        <input type="text" class="form-control" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="placeholder_<%=lang.getLanguageId()%>" name="placeholder_<%=lang.getLanguageId()%>" value='<%=escapeCoteValue(fieldPlaceholder)%>' <%=clc%> />
                        <%
                                                }

                                            } else if(target.equalsIgnoreCase("editprocess")){

                                                if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId))
                                                    fieldPlaceholder = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId).get("placeholder");
                        %>
                                                <input type="text" class="form-control placeholder" data-language-id="<%=langId%>" id="placeholder_<%=langId%>" name="placeholder_<%=langId%>" value="<%=escapeCoteValue(fieldPlaceholder)%>" <%=clc%> />
                        <%
                                            }
                        %>
                                            </div>
                                        </div>
                        <%
                                    }
                                }

                                if(fieldType.equals("button")){
                        %>
                                    <div class="form-group row">
                                        <label for="btn_id" class='col-md-3 col-form-label'>Id:</label>
                                        <div class='col-md-9'>
                                            <input type="text" id="btn_id" name="btn_id" value='<%=escapeCoteValue(getRsValue(rs, "btn_id"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                        </div>
                                    </div>

                                    <div class="form-group row">
                                        <label for="name" class='col-md-3 col-form-label'>Name:</label>
                                        <div class='col-md-9'>
                                            <input type="text" id="name" name="name" value='<%=escapeCoteValue(getRsValue(rs, "name"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                        </div>
                                    </div>
                        <%
                                }

                                if(!fieldType.equals("checkbox") && !fieldType.equals("dropdown") && !fieldType.equals("label") && !fieldType.equals("radio") && !fieldType.equals("imgupload") && !fieldType.equals("fileupload")){
                        %>

                                    <div class="form-group row">
                                        <label for="value" class='col-md-3 col-form-label'>Value:</label>
                                        <div class='col-md-9'>

                        <%
                                            if(target.equalsIgnoreCase("process")){

                                                lc = 0;
                                                clc = "";
                                                fieldValue = "";

                                                for(Language lang : languages){

                                                    if(lc++ == 0){

                                                        clc = "multilingual=\"true\"";

                                                    } else {

                                                        clc = "style=\"display: none;\"";
                                                    }

                                                    if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()))
                                                        fieldValue = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()).get("value");
                        %>
                                                        <input type="text" class="form-control ignore_xss" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="value_<%=lang.getLanguageId()%>" name="value_<%=lang.getLanguageId()%>" value='<%=escapeCoteValue(fieldValue)%>' <%=clc%> />
                        <%
                                                }

                                            } else if(target.equalsIgnoreCase("editprocess")){

                                                if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId))
                                                    fieldValue = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId).get("value");
                        %>
                                                <input type="text" class="form-control value ignore_xss" data-language-id="<%=langId%>" id="value_<%=langId%>" name="value_<%=langId%>" value="<%=escapeCoteValue(fieldValue)%>" <%=clc%> />
                        <%
                                            }
                        %>
                                        </div>
                                    </div>
                        <%
                                }

                                if(fieldType.equals("button")){
                        %>
                                    <div class="form-group row ">
                                        <label for="type" class='col-md-3 control-label'>Type: </label>
                                        <div class='col-md-9'>
                                            <%
                                                arr = new ArrayList<String>();
                                                arr.add(getRsValue(rs, "type"));
                                            %>
                                            <%=addSelectControl("type", "type", buttonTypeValues, arr, "custom-select", otherLanguageAttr, false)%>
                                        </div>
                                    </div>
                        <%
                                }
                            
                            }

                            if(fieldType.equals("textrecaptcha")){

                                LinkedHashMap<String, String> recaptchaThemeValues = new LinkedHashMap<String, String>();
                                recaptchaThemeValues.put("light","Light");
                                recaptchaThemeValues.put("dark","Dark");

                                LinkedHashMap<String, String> recaptchaSizeValues = new LinkedHashMap<String, String>();
                                recaptchaSizeValues.put("normal","Normal");
                                recaptchaSizeValues.put("compact","Compact");
                        %>
                                <div class="form-group row">
                                    <label for="site_key" class='col-md-3 col-form-label'>Site key:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="site_key" name="site_key" value='<%=escapeCoteValue(getRsValue(rs, "site_key"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>

                                <div class="form-group row ">
                                    <label for="theme" class='col-md-3 control-label'>Recaptcha theme: </label>
                                    <div class='col-md-9'>
                                        <%
                                                arr = new ArrayList<String>();
                                                arr.add(getRsValue(rs, "theme"));
                                        %>
                                        <%=addSelectControl("theme", "theme", recaptchaThemeValues, arr, "custom-select", otherLanguageAttr, false)%>
                                    </div>
                                </div>

                                <div class="form-group row ">
                                    <label for="recaptcha_data_size" class='col-md-3 control-label'>Recaptcha size: </label>
                                    <div class='col-md-9'>
                                        <%
                                                arr = new ArrayList<String>();
                                                arr.add(getRsValue(rs, "recaptcha_data_size"));
                                        %>
                                        <%=addSelectControl("recaptcha_data_size", "recaptcha_data_size", recaptchaSizeValues, arr, "custom-select", otherLanguageAttr, false)%>
                                    </div>
                                </div>
                        <%
                            }

                            if(fieldType.equals("range")){
                        %>
                                <div class="form-group row">
                                    <label for="min_range" class='col-md-3 col-form-label'>Min.:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="min_range" name="min_range" value='<%=escapeCoteValue(getRsValue(rs, "min_range"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label for="max_range" class='col-md-3 col-form-label'>Max.:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="max_range" name="max_range" value='<%=escapeCoteValue(getRsValue(rs, "max_range"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label for="step_range" class='col-md-3 col-form-label'>Step:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="step_range" name="step_range" value='<%=escapeCoteValue(getRsValue(rs, "step_range"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                        <%
                            }

                            if(fieldType.equals("checkbox") || fieldType.equals("radio") || fieldType.equals("dropdown")){
                        %>
                                <div class="form-group row">
                                    <label for="autocomplete_char_after" class='col-md-3 col-form-label'>Options:</label>
                                    <div class='col-md-9'>
                        <%              
                                        String optionQuery = getRsValue(rs, "element_option_query");
                                        String iSOptionQuery = optionQuery;
                                        String optionClass = "";
                                        String optionQueryClass = "";

                                        if(optionQuery.length() > 0 && optionQuery.equals("1")) {

                                            optionQuery = "checked='true'";
                                            optionClass = " d-none ";
                                        } else {

                                            optionQueryClass = " d-none ";
                                        }
                                        
                                        if(iSOptionQuery.length() == 0) iSOptionQuery = "0";

                        %>
                                        <label>For writing query / pair value?</label>
                                        <input type="checkbox" id="option_query" onclick="forWritingQuery(this)" <%=optionQuery%>/>
                                        <input type="hidden" id="element_option_query" name="element_option_query" value='<%=escapeCoteValue(iSOptionQuery)%>'>
                                        <div class="bloc_edit_buttons">
                                            <span id="" class="mr-2" style="cursor:pointer;"> <i data-feather="x-square"></i> </span>
                                        </div>                                       
                                    </div>
                                </div>
                        <%
                                JSONObject optionsObject = null;
                                JSONArray optionValArray = null;
                                JSONArray optionTxtArray = null;
                                String options = "";

                                try{

                                    if(target.equalsIgnoreCase("process")){

                                        lc = 0;
                                        clc = "";
                                        fieldPlaceholder = "";

                                        for(Language lang : languages){

                                            if(lc++ == 0){

                                                clc = "multilingual=\"true\"";

                                            } else {

                                                clc = "style=\"display: none;\"";
                                            }

                                            if(formFieldDescriptionMap.size() > 0 
                                                    && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId())){

                                                options = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()).get("options");
                                            }
        
                                            if(options.length() > 0){

                                                optionsObject = new JSONObject(options);
                                                optionValArray = optionsObject.getJSONArray("val");
                                                optionTxtArray = optionsObject.getJSONArray("txt");

                                                for(int i=0; i < optionValArray.length(); i++) {
                        %>
                                                    <div class='form-group row field_options <%=optionClass%>'>
                                                        <span class="col-md-3"></span>
                                                        <div class="col-md-9">

                                                            <input type="text" class="form-control" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="option_text_<%=lang.getLanguageId()%>" name="option_text_<%=lang.getLanguageId()%>" value='<%=escapeCoteValue(optionValArray.get(i).toString())%>' <%=clc%> <%=otherLanguageValueAttr%> />

                                                            <input type="text" class="form-control mt-2" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="option_value_<%=lang.getLanguageId()%>" name="option_value_<%=lang.getLanguageId()%>" value='<%=escapeCoteValue(optionTxtArray.get(i).toString())%>' <%=clc%> />


                                                        </div>
                                                    </div>
                        <%                
                                                }
                                            }
                                        }

                                    } else if(target.equalsIgnoreCase("editprocess")){


                                        if(formFieldDescriptionMap.size() > 0 
                                                && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId)){

                                            options = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId).get("options");
                                        }


                                        if(options.length() > 0){

                                            optionsObject = new JSONObject(options);
                                            optionValArray = optionsObject.getJSONArray("val");
                                            optionTxtArray = optionsObject.getJSONArray("txt");

                                            for(int i=0; i < optionValArray.length(); i++) {
                        %>
                                                <div class='form-group row field_options <%=optionClass%>'>
                                                    <span class="col-md-3"></span>
                                                    <div class="col-md-9">

                                                        <input type="text" class="form-control" data-language-id="<%=langId%>" id="option_value_<%=langId%>" name="option_value_<%=langId%>" placeholder="Text" value='<%=escapeCoteValue(optionTxtArray.get(i).toString())%>' <%=clc%> />

                                                        <input type="text" class="form-control mt-2" data-language-id="<%=langId%>" id="option_text_<%=langId%>" name="option_text_<%=langId%>" placeholder="Value" value='<%=escapeCoteValue(optionValArray.get(i).toString())%>'  <%=clc%> <%=otherLanguageValueAttr%> />

                                                    </div>
                                                </div>
                        <%                
                                            }
                                        }
                                    }

                                } catch (JSONException je){
                                    je.printStackTrace();
                                }

                                if(null == optionValArray || optionValArray.length() == 0 || optionTxtArray.length() == 0){
                        %>
                                    <div class='form-group row field_options <%=optionClass%>'>
                                        <span class="col-md-3"></span>
                                        <div class="col-md-9">
                        <%
                                            if(target.equalsIgnoreCase("process")){

                                                lc = 0;
                                                clc = "";

                                                for(Language lang : languages){

                                                    if(lc++ == 0){

                                                        clc = "multilingual=\"true\"";

                                                    } else {

                                                        clc = "style=\"display: none;\"";
                                                    }
                        %>
                                                        <input type="text" class="form-control" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="option_value_<%=lang.getLanguageId()%>" name="option_value_<%=lang.getLanguageId()%>" placeholder="Text" value='' <%=clc%> />

                                                        <input type="text" class="form-control mt-2" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="option_text_<%=lang.getLanguageId()%>" name="option_text_<%=lang.getLanguageId()%>" placeholder="Value" value='' <%=clc%> />
                        <%
                                                }

                                            } else if(target.equalsIgnoreCase("editprocess")){
                        %>
                                                <input type="text" class="form-control" data-language-id="<%=langId%>" id="option_value_<%=langId%>" name="option_value_<%=langId%>" value='' placeholder="Text" <%=clc%> />

                                                <input type="text" class="form-control mt-2" data-language-id="<%=langId%>" id="option_text_<%=langId%>" name="option_text_<%=langId%>" value='' placeholder="Value" <%=clc%> />
                        <%
                                            }
                        %>
                                        </div>
                                    </div>
                        <%
                                }
                        %>
                                <div class='form-group row add_more_options <%=optionClass%>'>
                                    <span class="col-md-3"></span>
                                    <div class="col-md-9">
                                        <div>
                                            <a href="#" onclick="addMoreFieldOptions()" class="add add-opt" >Add</a>
                                        </div>
                                        <div>
                                            <a href="#" onclick="removeFieldOptions()" class="d-none remove remove-opt" >Remove</a>
                                        </div>
                                    </div> 
                                    <div class="col-md-9">                                    
                                    </div>
                                </div>

                                <div class='form-group row write_query_option <%=optionQueryClass %>'>
                                    <span class="col-md-3"></span>
                                    <div class="col-md-9">                                    


                        <%
                                    if(target.equalsIgnoreCase("process")){

                                        lc = 0;
                                        clc = "";
                                        fieldOptionQuery = "";

                                        for(Language lang : languages){

                                            if(lc++ == 0){

                                                clc = "multilingual=\"true\"";

                                            } else {

                                                clc = "style=\"display: none;\"";
                                            }

                                            if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()))
                                                fieldOptionQuery = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+lang.getLanguageId()).get("option_query");
                        %>    
                                            <textarea class="form-control" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="option_query_<%=lang.getLanguageId()%>" name="option_query_value_<%=lang.getLanguageId()%>" rows="3" <%=clc%>><%=escapeCoteValue(fieldOptionQuery)%></textarea>
                        <%
                                        }

                                    } else if(target.equalsIgnoreCase("editprocess")){

                                        if(formFieldDescriptionMap.size() > 0 && null != formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId))
                                            fieldOptionQuery = formFieldDescriptionMap.get(formId+"_"+fieldId+"_"+langId).get("option_query");
                        %>
                                        <textarea class="form-control" data-language-id="<%=langId%>" id="option_query_value_<%=langId%>" name="option_query_value_<%=langId%>" rows="3" <%=clc%>><%=escapeCoteValue(fieldOptionQuery)%></textarea>
                        <%
                                    }
                        %>


                                    </div>
                                </div>
                        <%
                            }

                            if(fieldType.equals("imgupload")){
                        %>
                                <div class="form-group row">
                                    <label for="img_url" class='col-md-3 col-form-label'>Image desktop:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="img_url" name="img_url" value='<%=escapeCoteValue(getRsValue(rs, "img_url"))%>' readonly class="form-control" <%=otherLanguageAttr%>/>
                                        <button id="openUploadGalleryImageButton" type="button" class="attribute_value_image btn btn-default btn-primary"  onclick="openUploadGalleryImageDialog(this);" <%=otherLanguageAttr%>>upload / select</button>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label for="img_murl" class='col-md-3 col-form-label'>Image mobile:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="img_murl" name="img_murl" value='<%=escapeCoteValue(getRsValue(rs, "img_murl"))%>' readonly class="form-control" <%=otherLanguageAttr%>/>
                                        <button id="openUploadGalleryImageButton" type="button" class="attribute_value_image btn btn-default btn-primary"  onclick="openUploadGalleryImageDialog(this);" <%=otherLanguageAttr%>>upload / select</button>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label for="img_width" class='col-md-3 col-form-label'>Width:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="img_width" name="img_width" value='<%=escapeCoteValue(getRsValue(rs, "img_width"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label for="img_height" class='col-md-3 col-form-label'>Height:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="img_height" name="img_height" value='<%=escapeCoteValue(getRsValue(rs, "img_height"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label for="img_alt" class='col-md-3 col-form-label'>Alt:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="img_alt" name="img_alt" value='<%=escapeCoteValue(getRsValue(rs, "img_alt"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label for="img_href_url" class='col-md-3 col-form-label'>Url:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="img_href_url" name="img_href_url" value='<%=escapeCoteValue(getRsValue(rs, "img_href_url"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>

                                <div class="form-group row ">
                                    <label for="href_target" class='col-md-3 control-label'>Target: </label>
                                    <div class='col-md-9'>
                                        <%
                                                arr = new ArrayList<String>();
                                                arr.add(getRsValue(rs, "href_target"));
                                        %>
                                        <%=addSelectControl("href_target", "href_target", hrefTargetValues, arr, "custom-select", otherLanguageAttr, false)%>
                                    </div>
                                </div>
                        <%
                            }
                        %>                            

                        <div class="form-group row field_options_clone d-none">
                            <span class="col-md-3"></span>
                            <div class="col-md-9">

                        <%
                                            if(target.equalsIgnoreCase("process")){

                                                lc = 0;
                                                clc = "";

                                                for(Language lang : languages){

                                                    if(lc++ == 0){

                                                        clc = "multilingual=\"true\"";

                                                    } else {

                                                        clc = "style=\"display: none;\"";
                                                    }
                        %>
                                                        <input type="text" class="form-control" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="option_value_<%=lang.getLanguageId()%>" name="option_value_<%=lang.getLanguageId()%>" placeholder="Text" value='' <%=clc%> />

                                                        <input type="text" class="form-control mt-2" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" placeholder="Value" id="option_text_<%=lang.getLanguageId()%>" name="option_text_<%=lang.getLanguageId()%>" value='' <%=clc%> />
                        <%
                                                }

                                            } else if(target.equalsIgnoreCase("editprocess")){
                        %>
                                                <input type="text" class="form-control" data-language-id="<%=langId%>" id="option_value_<%=langId%>" name="option_value_<%=langId%>" placeholder="Text" value='' <%=clc%> />

                                                <input type="text" class="form-control mt-2" data-language-id="<%=langId%>" id="option_text_<%=langId%>" name="option_text_<%=langId%>" placeholder="Value" value='' <%=clc%> />
                        <%
                                            }
                        %>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12">
                    <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapseStyle" role="button" aria-expanded="false" aria-controls="collapseStyle">Style</button>                          
                    <div class="collapse p-2" id="collapseStyle">

                        <%
                            if(!fieldType.equals("dropdown") && !fieldType.equals("range") && !fieldType.equals("label") && !fieldType.equals("button") && !fieldType.equals("fileupload")){
                        %>
                                <div class="form-group row ">
                                    <label for="font_weight" class='col-md-3 control-label'>Font weight: </label>
                                    <div class='col-md-9'>
                                        <%
                                                arr = new ArrayList<String>();

                                                if(getRsValue(rs, "font_weight").length() > 0)
                                                    arr.add(getRsValue(rs, "font_weight"));
                                        %>
                                        <%=addSelectControl("font_weight", "font_weight", fontWeightValues, arr, "custom-select", otherLanguageAttr, false)%>
                                    </div>
                                </div>
                                
                                <div class="form-group row">
                                    <label for="font_size" class='col-md-3 col-form-label'>Font size:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="font_size" name="font_size" value='<%=escapeCoteValue(getRsValue(rs, "font_size"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                                
                                <div class="form-group row">
                                    <label for="color" class='col-md-3 col-form-label'>Color:</label>
                                    <div class='col-md-9'>
                                        <%
                                            String color = getRsValue(rs, "color");
                                            if(color.length() == 0) color = "#333333";
                                        %>
                                        <input type="text" id="color" name="color" value='<%=escapeCoteValue(color)%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                        <%
                            }

                            if(!fieldType.equals("button") && !fieldType.equals("checkbox") && !fieldType.equals("dropdown") && !fieldType.equals("hyperlink") && !fieldType.equals("label") && !fieldType.equals("radio") && !fieldType.equals("imgupload") && !fieldType.equals("range") && !fieldType.equals("fileupload")){
                        %>
                                <div class="form-group row">
                                    <label for="maxlength" class='col-md-3 col-form-label'>Max length:</label>
                                    <div class='col-md-9'>
                                        <input type="number" id="maxlength" name="maxlength" min="0" value='<%=escapeCoteValue(getRsValue(rs, "maxlength"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                        <%
                            }


                            if(fieldType.equals("button") || fieldType.equals("label")){
                        %>

                                <div class="form-group row">
                                    <label for="container_bkcolor" class='col-md-3 col-form-label'>Container color:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="container_bkcolor" name="container_bkcolor" value='<%=escapeCoteValue(getRsValue(rs, "container_bkcolor"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                        <%
                            }

                            if(fieldType.equals("imgupload")){
                        %>

                                <div class="form-group row">
                                    <label for="color" class='col-md-3 col-form-label'>Background color:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="color" name="color" value='<%=escapeCoteValue(getRsValue(rs, "color"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                        <%
                            }
                        %>
                            <div class="form-group row">
                                <label for="custom_classes" class='col-md-3 col-form-label'>Custom classes:</label>
                                <div class='col-md-9'>
                                    <input type="text" id="custom_classes" name="custom_classes" value='<%=escapeCoteValue(getRsValue(rs, "custom_classes"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label for="custom_css" class='col-md-3 col-form-label'>Custom css:</label>
                                <div class='col-md-9'>
                                    <div id="custom_css_code_editor"></div>
                                    <input type='hidden' id='custom_css' name='custom_css' value='<%=escapeCoteValue(getRsValue(rs, "custom_css"))%>'>
                                </div>
                            </div>
                    </div>                    
                </div>

                <%

                    if(!fieldType.equals("texthidden") && !fieldType.equals("hyperlink") && !fieldType.equals("imgupload") && !fieldType.equals("label")){
                %>
                        <div class="col-12">
                            <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapseAdvanced" role="button" aria-expanded="false" aria-controls="collapseAdvanced">Advanced</button>                          
                            <div class="collapse p-2" id="collapseAdvanced">

                        <%
                            if(fieldType.equals("textfield")){
                        %>
                                <div class="form-group row">
                                    <label for="regular_expression" class='col-md-3 col-form-label'>Regular expression:</label>
                                    <div class='col-md-9'>
                                        <input type="text" id="regular_expression" name="regular_expression" value='<%=escapeCoteValue(getRsValue(rs, "regx_exp"))%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                        <%
                            }

                            if(!fieldType.equals("textrecaptcha") && !fieldType.equals("hyperlink") && !fieldType.equals("label") && !fieldType.equals("imgupload") && !fieldType.equals("texthidden")){
                        %>
                                <div class="form-group row ">
                                    <label for="element_trigger" class='col-md-3 control-label'>Element trigger: </label>
                                    <div class='col-md-9'>
                                        <%
                                            String elementTrigger = getRsValue(rs, "element_trigger");
                                            String elementTriggerEvent = "";
                                            String elementTriggerQuery = "";
                                            String elementTriggerJs = "";

                                            if(elementTrigger.length() > 0){
                                              
                                              JSONObject elementTriggerObject = null;
                                              JSONArray elementTriggerQueryArray = null;
                                              JSONArray elementTriggerJsArray = null;
                                              JSONArray elementTriggerEventArray = null;
                                              elementTriggerEvent = "";
                                              elementTriggerQuery = "";
                                              elementTriggerJs = "";

                                              elementTriggerObject = new JSONObject(elementTrigger);
                                              
                                              elementTriggerEventArray = elementTriggerObject.getJSONArray("event");
                                              elementTriggerQueryArray = elementTriggerObject.getJSONArray("query");
                                              elementTriggerJsArray = elementTriggerObject.getJSONArray("js");

                                              try{

                                                for(int i=0; i < elementTriggerEventArray.length(); i++){
                                                  
                                                  elementTriggerEvent += elementTriggerEventArray.get(i).toString();

                                                  if(elementTriggerQueryArray.length() > 0) 
                                                    elementTriggerQuery += elementTriggerQueryArray.get(i).toString();
                                                  
                                                  if(elementTriggerJsArray.length() > 0) {

                                                    elementTriggerJs += elementTriggerJsArray.get(i).toString();
                                                    elementTriggerJs = elementTriggerJs.replaceAll("##ENTER##","\n").replace("##ENTERr##","\r");
                                                  }

                                                    arr = new ArrayList<String>();
                                                    arr.add(elementTriggerEvent);
                        %>
                                                    <%=addSelectControl("element_trigger", "element_trigger", elementTriggerValues, arr, "custom-select", "onchange=\"writeQueryOfTriggerEvent(this)\" " + otherLanguageAttr, false)%>
                
                                                    <div class="form-group row">
                                                        <div class='col-md-12'>
                                                            <label class='col-md-3' style="font-weight: 700">Write query: </label>
                                                            <textarea class="form-control" name="element_trigger_value" rows="3" <%=otherLanguageAttr%>><%=elementTriggerQuery%></textarea>
                                                        </div>

                                                        <div class='col-md-12'>
                                                            <label class='col-md-3' style="font-weight: 700">Write JS: </label>
                                                            <div id="element_trigger_js_code_editor"></div>
                                                            <input type='hidden' id='element_trigger_js' name='element_trigger_js' value="<%=escapeCoteValue(elementTriggerJs)%>">
                                                        </div>
                        <%
                                                        if(i == (elementTriggerEventArray.length()-1)){
                        %>
                                                            <div class='col-md-12 d-none'>
                                                                <a href="#" name="element_trigger_more" onclick="addMoreEventTrigger(this)" class="btn <%=otherLanguageAttr%>">Add more +</a>
                                                            </div>
                        <%
                                                        }
                        %>
                                                    </div>
                        <%
                                                }

                                              }catch(JSONException je){
                                                je.printStackTrace();
                                              }

                                            } else {

                                                arr = new ArrayList<String>();
                                                arr.add(elementTriggerEvent);
                        %>
                                                <%=addSelectControl("element_trigger", "element_trigger", elementTriggerValues, arr, "custom-select", "onchange=\"writeQueryOfTriggerEvent(this)\" " + otherLanguageAttr, false)%>

                                                <div class="form-group row">
                                                    <div class='col-md-12'>
                                                        <label class='col-md-3' style="font-weight: 700">Write query: </label>
                                                        <textarea class="form-control" name="element_trigger_value" rows="3" <%=otherLanguageAttr%>><%=elementTriggerQuery%></textarea>
                                                    </div>

                                                    <div class='col-md-12'>
                                                        <label class='col-md-3' style="font-weight: 700">Write JS: </label>
                                                        <div id="element_trigger_js_code_editor"></div>
                                                        <input type='hidden' id='element_trigger_js' name='element_trigger_js' value="<%=escapeCoteValue(elementTriggerJs)%>">
                                                    </div>

                                                    <div class='col-md-12 d-none'>
                                                        <a href="#" name="element_trigger_more" onclick="addMoreEventTrigger(this)" class="btn <%=otherLanguageAttr%>">Add more +</a>
                                                    </div>
                                                </div>
                        <%
                                            }
                        %>
                                    </div>
                                </div>
                        <%
                            }

                            if(fieldType.equals("autocomplete")){
                        %>
                                <div class="form-group row">
                                    <label for="autocomplete_char_after" class='col-md-3 col-form-label'>Trigger after:</label>
                                    <div class='col-md-9'>
                                        <%
                                            String triggerAfter = getRsValue(rs, "autocomplete_char_after");
                                            if(triggerAfter.length() == 0) triggerAfter = "2";
                                        %>
                                        <input type="number" id="autocomplete_char_after" name="autocomplete_char_after" min="0" value='<%=escapeCoteValue(triggerAfter)%>'  class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                                
                                <div class="form-group row">
                                    <label for="element_autocomplete_query" class='col-md-3 col-form-label'>Autocomplete query:</label>
                                    <div class='col-md-9'>
                                        <textarea class="form-control" id="element_autocomplete_query" name="element_autocomplete_query" rows="3" <%=otherLanguageAttr%>><%=getRsValue(rs, "element_autocomplete_query")%></textarea>
                                    </div>
                                </div>
                        <%
                            }
                        %>
                            </div>                    
                        </div>
                <%
                    }
                %>

                </form>
            </div>
            </div>
        </div>
<%
    } else if(action.equals("delete_reply")){

        String id = parseNull(request.getParameter("id"));
        String formid = parseNull(request.getParameter("formid"));
        String portaldb = parseNull(request.getParameter("portaldb"));
        String siteId = parseNull(request.getParameter("site_id"));
        String clientUuid = parseNull(request.getParameter("uuid"));
        
		Set rsf = Etn.execute("select * from process_forms_unpublished where form_id = "+escape.cote(formid));
		rsf.next();
		String tableName = rsf.value("table_name");
		
        int rid = Etn.executeCmd("DELETE FROM " + tableName + " WHERE " + tableName + "_id = " + escape.cote(id));
        int resId=0;
        System.out.println("rid::"+rid);
        if(clientUuid.length() > 0) {
            String deleteQry= "DELETE FROM " + portaldb + ".clients WHERE client_uuid = "+escape.cote(clientUuid)+" AND site_id = " + escape.cote(siteId);
            if(id.length()>0)
                deleteQry += " AND form_row_id = " + escape.cote(id);
            resId = Etn.executeCmd(deleteQry);
        }
        if(rid>0 || resId>0)
            out.write("{\"resp\":\"success\"}");
        else
            out.write("{\"resp\":\"error\"}");


    } else if(action.equals("checktablenameuniqueness")){

		String tablename = parseNull(request.getParameter("tablename")).replaceAll(" ", "_").toLowerCase();
		//remove accents from tablename
		tablename = com.etn.asimina.util.UrlHelper.removeAccents(tablename);
		
		if(tablename.length() > 50)
		{
			out.write("{\"status\":\"1\",\"msg\":\"" + libelle_msg(Etn, request, "Table name cannot be more than 50 characters long") + "\"}");
		}
		else
		{
			String msg = "";

			Set rs = Etn.execute("SELECT * FROM process_forms_unpublished WHERE table_name = " + escape.cote(tablename));

			if(rs.rs.Rows > 0)
				out.write("{\"status\":\"1\",\"msg\":\"" + libelle_msg(Etn, request, "Table name should be unique across all sites.") + "\"}");
			else
				out.write("{\"status\":\"0\",\"msg\":\"\"}");
		}
    } else if(action.equals("reply_back")){

        String formId = parseNull(request.getParameter("form_id"));
        String tableId = parseNull(request.getParameter("table_id"));
%>
        <div class="m-b-20 text-right">
            <button class="btn btn-primary mr-2" onclick="replyBack()">Send</button>
            <button class="btn btn-danger" onclick="hideModal('1')">Abort</button>
        </div>
        <hr>

        <form id="reply_back_frm" method="post" action="search.jsp?___fid=<%=escapeCoteValue(formId)%>">
            <input type="hidden" name="reply_back" value="1">        
            <input type="hidden" name="table_id" value="<%=escapeCoteValue(tableId)%>">        
            <div class="form-group row">
                <label for="email" class="col-sm-3 col-form-label">To</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" id="email">
                </div>
            </div>
            <div class="form-group row">
                <label for="emailcc" class="col-sm-3 col-form-label">CC</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" id="emailcc" value="">
                </div>
            </div>
            <div class="form-group row">
                <label for="emailci" class="col-sm-3 col-form-label">CI</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" id="emailci" value="">
                </div>
            </div>

            <div class="form-group row">
                <label for="message" class="col-sm-3 col-form-label">Message</label>
                <div class="col-sm-9">
                    <textarea class="form-control" rows="3" id="message" aria-labelledby="Message"></textarea>
                </div>
            </div>
        </form>
<%
    } else if(action.equals("is_dbcolumn_exists")){

        String formId = parseNull(request.getParameter("formid"));
        String dbColumnName = com.etn.asimina.util.UrlHelper.removeAccents(parseNull(request.getParameter("dbcolumn")));
        dbColumnName = dbColumnName.replaceAll(" ", "_").replaceAll("[^a-zA-Z0-9_]", "");

        Set rs = Etn.execute("SELECT db_column_name FROM process_form_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND (db_column_name = " + escape.cote(dbColumnName) + " || db_column_name = " + escape.cote("_etn_" + dbColumnName) + ")");

        if(rs.rs.Rows > 0)
            out.write("{\"status\":\"1\",\"msg\":\"" + libelle_msg(Etn, request, "Column already exists.") + "\"}");
        else
            out.write("{\"status\":\"0\",\"msg\":\"\"}");

    }
%>