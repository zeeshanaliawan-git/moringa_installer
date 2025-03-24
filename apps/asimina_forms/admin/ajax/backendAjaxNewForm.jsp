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
<%@ page import="com.etn.asimina.beans.Language" %>
<%@ include file="../../common2.jsp"%>

<%

    List<Language> langsList = getLangs(Etn,session);
    Language defaultLanguage = langsList.get(0);
    String defaultLangId = defaultLanguage.getLanguageId();
    String langId = parseNull(request.getParameter("lang_id"));
    String formId = parseNull(request.getParameter("formid"));
    String target = parseNull(request.getParameter("target"));
    String targetRedirect = target;
    String isNew = "";

    if(targetRedirect.equalsIgnoreCase("process"))
        targetRedirect = "process.jsp";
    else if(targetRedirect.equalsIgnoreCase("editprocess"))
        targetRedirect = "editProcess.jsp?form_id=" + formId;

    LinkedHashMap<String, String> variantValues = new LinkedHashMap<String, String>();
    variantValues.put("all","All Users");
    variantValues.put("anonymous","Anonymous");
    variantValues.put("logged","Logged");

    LinkedHashMap<String, String> templateValues = new LinkedHashMap<String, String>();
    templateValues.put("0","Standard page");
    templateValues.put("0","Custom standard page");

    LinkedHashMap<String, String> buttonAlignmentValues = new LinkedHashMap<String, String>();
    buttonAlignmentValues.put("r","Right");
    buttonAlignmentValues.put("l","Left");
    buttonAlignmentValues.put("c","Center");

    LinkedHashMap<String, String> formMethodValues = new LinkedHashMap<String, String>();
    formMethodValues.put("post","Post");
    formMethodValues.put("get","Get");

    LinkedHashMap<String, String> formAutoCompleteValues = new LinkedHashMap<String, String>();
    formAutoCompleteValues.put("off","Off");
    formAutoCompleteValues.put("on","On");

    LinkedHashMap<String, String> formLabelDisplayValues = new LinkedHashMap<String, String>();
    formLabelDisplayValues.put("tal","Top aligned");
    formLabelDisplayValues.put("lal","Left aligned");

    LinkedHashMap<String, String> formWidthValues = new LinkedHashMap<String, String>();
    formWidthValues.put("12","12 columns");
    formWidthValues.put("10","10 columns");
    formWidthValues.put("8","8 columns");
    formWidthValues.put("6","6 columns");
    formWidthValues.put("4","4 columns");
    formWidthValues.put("2","2 columns");

    Set rs = null;

    if(formId.length() > 0)
    {
        rs = Etn.execute("SELECT * FROM process_forms_unpublished WHERE form_id =  " + escape.cote(formId));
        rs.next();
    }


    Set formDescriptionRs = Etn.execute("SELECT * FROM process_form_descriptions_unpublished WHERE form_id = " + escape.cote(formId));

    Map<String, Map<String, String>> formDescriptionMap = new HashMap<String, Map<String, String>>();
    Map<String, String> formMap = null;

    String formTitle = "";
    String formSuccessMsg = "";
    String formSubmitBtnLbl = "";
    String formCancelBtnLbl = "";
    String fieldLangId = "";

    while(formDescriptionRs.next()){

        formTitle = parseNull(formDescriptionRs.value("title"));
        formSuccessMsg = parseNull(formDescriptionRs.value("success_msg"));
        formSubmitBtnLbl = parseNull(formDescriptionRs.value("submit_btn_lbl"));
        formCancelBtnLbl = parseNull(formDescriptionRs.value("cancel_btn_lbl"));
        fieldLangId = parseNull(formDescriptionRs.value("langue_id"));

        formMap = new HashMap<String, String>();

        formMap.put("title", formTitle);
        formMap.put("success_msg", formSuccessMsg);
        formMap.put("submit_btn_lbl", formSubmitBtnLbl);
        formMap.put("cancel_btn_lbl", formCancelBtnLbl);

        formDescriptionMap.put(formId + "_" + fieldLangId, formMap);
    }
%>
<!-- additional fees -->
<form id='newformfrm' name='newformfrm' method='post' action='<%=targetRedirect%>'>
    <%
    if(formId.length() > 0){
        isNew = "is-new-form='0'";
    %>
        <input type='hidden' name='form_id' id="form_id" value='<%=getValue(rs, "form_id")%>' />
        <input type='hidden' name='process_name' id="process_name" value='<%=getValue(rs, "process_name")%>' />
        <input type='hidden' name='is_edit' id="is_edit" value='1' />
    <%
    } else {

        isNew = "is-new-form='1'";
    %>
        <input type='hidden' name='is_save' id="is_save" value='1' />
    <%
    }
    %>
    <input type="hidden" id="appcontext" value="<%=request.getContextPath()%>/" />
    <input type="hidden" name="lang_id" value="<%=langId%>">

    <div class="col-sm-12 multilingual-section">
        <table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
            <tr>
                <div class="mb-2 text-right">
                    <button id="selectionSave" type="button" class="btn btn-primary" style="z-index: 1000;" 
                    onclick='onFormValidation(this)' <%=isNew%>>Save</button>               
                </div>
                    <%
                    ArrayList arr = new ArrayList<String>();
                    %>
                <!-- Global information -->
                <div class="card mb-2">
                    <div class="card-header bg-secondary" data-toggle="collapse" href="#global_information" role="button" 
                    aria-expanded="true" aria-controls="global_information">
                        <strong>Global information</strong>
                    </div>
                    <div class="collapse show p-3" id="global_information">
                        <div class="card-body">
                            <div class="form-group row ">
                                <label for="process_name" class='col-md-3 control-label is-required'>Form name:</label>
                                <div class='col-md-9'>
                                    <input type="text" maxlength="50" id="process_name" name="process_name" data-language-id="1" value='<%=getRsValue(rs, "process_name")%>' class="form-control" <% if(formId.length() > 0 && getRsValue(rs, "process_name").length() > 0){ %> disabled <% } %> />
                                    <div class="invalid-feedback">Form name is mandatory.</div>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="table_name" class='col-md-3 control-label is-required'>Form table:</label>
                                <div class='col-md-9'>
                                    <input type="text" maxlength="45" id="table_name" name="table_name" value='<%=getRsValue(rs, "table_name")%>' class="form-control" <% if(formId.length() > 0 && getRsValue(rs, "table_name").length() > 0){ %> disabled <% } %> />
                                    <div class="invalid-feedback">Form table is mandatory.</div>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="success_msg" class='col-md-3 control-label'>Success msg.:</label>
                                <div class='col-md-9'>

                                <%
                                    
                                    int lc = 0;
                                    String clc = "";

                                    if(target.equalsIgnoreCase("process")){

                                        String ckcls = "";
                                        formSuccessMsg = "";

                                        for(Language lang : langsList){

                                            if(lc++ == 0){

                                                clc = "multilingual=\"true\"";
                                                ckcls = "ckeditor_success_msg";

                                            } else {

                                                clc = "style=\"display: none;\"";
                                                ckcls = "";
                                            }

                                            if(formDescriptionMap.size() > 0 && null != formDescriptionMap.get(formId+"_"+lang.getLanguageId()))
                                                formSuccessMsg = formDescriptionMap.get(formId+"_"+lang.getLanguageId()).get("success_msg");
                                %>
                                            <textarea class="form-control <%=ckcls%>" rows="5" data-language-id="<%=lang.getLanguageId()%>" 
                                            data-language-code="<%=lang.getCode()%>" name="success_msg_<%=lang.getLanguageId()%>" 
                                            id="success_msg_<%=lang.getLanguageId()%>" <%=clc%>><%=formSuccessMsg%></textarea>
                                <%
                                        }
                                    } else if(target.equalsIgnoreCase("editProcess")){

                                        if(formDescriptionMap.size() > 0 && null != formDescriptionMap.get(formId+"_"+langId))
                                            formSuccessMsg = formDescriptionMap.get(formId+"_"+langId).get("success_msg");
                                %>
                                        <textarea class="form-control ckeditor_success_msg" rows="5" data-language-id="<%=langId%>" name="success_msg_<%=langId%>" id="success_msg_<%=langId%>"><%=formSuccessMsg%></textarea>
                                <%
                                    }
                                %>
    
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="submit_btn_lbl" class='col-md-3 control-label'>Submit button label:</label>
                                <div class='col-md-9'>
                                    <%
                                    if(target.equalsIgnoreCase("process")){
        
                                        lc = 0;
                                        clc = "";
                                        formSubmitBtnLbl = "";

                                        for(Language lang : langsList){

                                            if(lc++ == 0){

                                                clc = "multilingual=\"true\"";

                                            } else {

                                                clc = "style=\"display: none;\"";
                                            }

                                            if(formDescriptionMap.size() > 0 && null != formDescriptionMap.get(formId+"_"+lang.getLanguageId()))
                                                formSubmitBtnLbl = formDescriptionMap.get(formId+"_"+lang.getLanguageId()).get("submit_btn_lbl");
                                    %>
                                        <input type="text" class="form-control" data-language-id="<%=lang.getLanguageId()%>" 
                                        data-language-code="<%=lang.getCode()%>" id="submit_btn_lbl_<%=lang.getLanguageId()%>" 
                                        name="submit_btn_lbl_<%=lang.getLanguageId()%>" value='<%=formSubmitBtnLbl%>' <%=clc%> />
                                    <%
                                        }
                                    } else if(target.equalsIgnoreCase("editProcess")){

                                        if(formDescriptionMap.size() > 0 && null != formDescriptionMap.get(formId+"_"+langId))
                                            formSubmitBtnLbl = formDescriptionMap.get(formId+"_"+langId).get("submit_btn_lbl");
                                    %>

                                        <input type="text" class="form-control" data-language-id="<%=langId%>" id="submit_btn_lbl_<%=langId%>" 
                                        name="submit_btn_lbl_<%=langId%>" value='<%=formSubmitBtnLbl%>' <%=clc%> />
                                    <%
                                        }
                                    %>

                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="cancel_btn_lbl" class='col-md-3 control-label'>Cancel button label:</label>
                                <div class='col-md-9'>
                                    <%
                                    if(target.equalsIgnoreCase("process")){

                                        lc = 0;
                                        clc = "";
                                        formCancelBtnLbl = "";

                                        for(Language lang : langsList){

                                            if(lc++ == 0){

                                                clc = "multilingual=\"true\"";

                                            } else {

                                                clc = "style=\"display: none;\"";
                                            }

                                            if(formDescriptionMap.size() > 0 && null != formDescriptionMap.get(formId+"_"+lang.getLanguageId()))
                                                formCancelBtnLbl = formDescriptionMap.get(formId+"_"+lang.getLanguageId()).get("cancel_btn_lbl");
                                    %>
                                        <input type="text" class="form-control" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="cancel_btn_lbl_<%=lang.getLanguageId()%>" name="cancel_btn_lbl_<%=lang.getLanguageId()%>" value='<%=formCancelBtnLbl%>' <%=clc%> />
                                    <%
                                        }
                                    } else if(target.equalsIgnoreCase("editProcess")){
                                        if(formDescriptionMap.size() > 0 && null != formDescriptionMap.get(formId+"_"+langId))
                                            formCancelBtnLbl = formDescriptionMap.get(formId+"_"+langId).get("cancel_btn_lbl");
                                    %>

                                        <input type="text" class="form-control" data-language-id="<%=langId%>" id="cancel_btn_lbl_<%=langId%>" 
                                        name="cancel_btn_lbl_<%=langId%>" value='<%=formCancelBtnLbl%>' <%=clc%> />
                                    <%
                                    }
                                    %>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="btn_align" class='col-md-3 control-label'>Button alignment:</label>
                                <div class='col-md-9'>
                                    <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "btn_align"));
                                        
                                        String otherLanguageAttr = "";
                                        if(!defaultLangId.equalsIgnoreCase(langId) && langId.length() > 0)
                                            otherLanguageAttr = "disabled";
                                    %>
                                    <%=addSelectControl("btn_align", "btn_align", buttonAlignmentValues, arr, "custom-select", otherLanguageAttr, false)%>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="redirect_url" class='col-md-3 control-label'>Redirect url:</label>
                                <div class='col-md-9'>
                                    <input type="text" id="redirect_url" name="redirect_url" value='<%=getRsValue(rs, "redirect_url")%>' class="form-control" <%=otherLanguageAttr%> />
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="variant" class='col-md-3 control-label'>Variant: </label>
                                <div class='col-md-9'>
                                    <%
                                            arr = new ArrayList<String>();
                                            arr.add(getRsValue(rs, "variant"));
                                    %>
                                    <%=addSelectControl("variant", "variant", variantValues, arr, "custom-select", otherLanguageAttr, false)%>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="template" class='col-md-3 control-label'>Template: </label>
                                <div class='col-md-9'>
                                    <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "template"));
                                    %>
                                    <%=addSelectControl("template", "template", templateValues, arr, "custom-select", otherLanguageAttr, false)%>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="delete-uploads" class='col-md-3 control-label'>Delete Uploads: </label>
                                <div class='col-md-9'>
                                    <input type="checkbox" class="form-check-inline" name="delete-uploads" id="delete-uploads" <%if(getRsValue(rs,"delete_uploads").equalsIgnoreCase("1")){%>checked<%}%> />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /Global information -->

                <!-- Options -->                                
                <div class="card mb-2">
                    <div class="card-header bg-secondary" data-toggle="collapse" href="#options" role="button" 
                    aria-expanded="true" aria-controls="options">
                        <strong>Options</strong>
                    </div>
                    <div class="collapse show p-3" id="options">
                        <div class="card-body">
                            <div class="form-group row">
                                <label for="html_form_id" class='col-md-3 control-label'>ID:</label>
                                <div class='col-md-9'>
                                    <div class="input-group">
                                        <input type="text" id="html_form_id" name="html_form_id" placeholder="id" value='<%=getRsValue(rs, "html_form_id")%>' class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label for="form_class" class='col-md-3 control-label'>Custom classes:</label>
                                <div class='col-md-9'>
                                    <div class="input-group">
                                        <input type="text" id="form_class" name="form_class" placeholder="class" value='<%=getRsValue(rs, "form_class")%>' class="form-control" <%=otherLanguageAttr%>/>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="form_method" class='col-md-3 control-label'>Method: </label>
                                <div class='col-md-9'>
                                    <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "form_method"));
                                    %>
                                    <%=addSelectControl("form_method", "form_method", formMethodValues, arr, "custom-select", otherLanguageAttr, false)%>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label for="form_enctype" class='col-md-3 control-label'>Enctype:</label>
                                <div class='col-md-9'>
                                    <div class="input-group">
                                        <input type="text" id="form_enctype" name="form_enctype" placeholder="enctype" value='<%=getRsValue(rs, "form_enctype")%>' class="form-control" <%=otherLanguageAttr%>/>
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
                                    <%=addSelectControl("form_autocomplete", "form_autocomplete", formAutoCompleteValues, arr, "custom-select", otherLanguageAttr, false)%>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="label_display" class='col-md-3 control-label'>Label display: </label>
                                <div class='col-md-9'>
                                    <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "label_display"));
                                    %>
                                    <%=addSelectControl("label_display", "label_display", formLabelDisplayValues, arr, "custom-select", otherLanguageAttr, false)%>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="form_width"  class='col-md-3 control-label'>Width: </label>
                                <div class='col-md-9'>
                                    <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "form_width"));
                                    %>
                                    <%=addSelectControl("form_width", "form_width", formWidthValues, arr, "custom-select", otherLanguageAttr, false)%>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /Options -->

                <!-- Meta tags -->
                <div class="card mb-2">
                    <div class="card-header bg-secondary" data-toggle="collapse" href="#meta_tags" role="button" 
                    aria-expanded="true" aria-controls="meta_tags">
                        <strong>Metatags</strong>
                    </div>
                    <div class="collapse show p-3" id="meta_tags">
                        <div class="card-body">
                            <div class="form-group row ">
                                <label for="title" class='col-md-3 control-label is-required'>Title:</label>
                                <div class='col-md-9'>

                                <%
                                if(target.equalsIgnoreCase("process")){

                                    lc = 0;
                                    clc = "";
                                    formTitle = "";

                                    for(Language lang : langsList){

                                        if(lc++ == 0){

                                            clc = "multilingual=\"true\"";

                                        } else {

                                            clc = "style=\"display: none;\"";
                                        }

                                        if(formDescriptionMap.size() > 0 && null != formDescriptionMap.get(formId+"_"+lang.getLanguageId()))
                                            formTitle = formDescriptionMap.get(formId+"_"+lang.getLanguageId()).get("title");
                                %>
                                        <input type="text" class="form-control title" data-language-id="<%=lang.getLanguageId()%>" data-language-code="<%=lang.getCode()%>" id="title_<%=lang.getLanguageId()%>" name="title_<%=lang.getLanguageId()%>" value='<%=formTitle%>' <%=clc%> />
                                <%
                                    }
                                } else if(target.equalsIgnoreCase("editprocess")){

                                    if(formDescriptionMap.size() > 0 && null != formDescriptionMap.get(formId+"_"+langId))
                                        formTitle = formDescriptionMap.get(formId+"_"+langId).get("title");
                                %>
                                    <input type="text" class="form-control title" data-language-id="<%=langId%>" id="title_<%=langId%>" name="title_<%=langId%>" value='<%=formTitle%>' <%=clc%> />
                                <%
                                }
                                %>
                                    <div class="invalid-feedback">Title is mandatory.</div>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="meta_description" class='col-md-3 control-label'>Meta description:</label>
                                <div class='col-md-9'>
                                    <input type="text" id="meta_description" name="meta_description" value='<%=getRsValue(rs, "meta_description")%>' class="form-control" <%=otherLanguageAttr%>/>
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="meta_keywords" class='col-md-3 control-label'>Meta keywords: </label>
                                <div class='col-md-9'>
                                    <input type="text" id="meta_keywords" name="meta_keywords" value='<%=getRsValue(rs, "meta_keywords")%>' class="form-control" <%=otherLanguageAttr%>/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /Meta Tags -->

                <!-- Advanced options -->                             
                <div class="card mb-2">
                    <div class="card-header bg-secondary" data-toggle="collapse" href="#advanced_option" role="button" 
                    aria-expanded="true" aria-controls="advanced_option">
                        <strong>Advanced options</strong>
                    </div>
                    <div class="collapse show p-3" id="advanced_option">
                        <div class="card-body">
                            <div class="form-group row ">
                                <label for="form_js" class='col-md-3 control-label'>Write JS: </label>
                                <div class='col-md-9'>
                                <%
                                String formJs = getRsValue(rs, "form_js");            
                                %>
                                    <div id="js_code_editor"></div>
                                    <input type='hidden' id='form_js' name='form_js' value="<%=formJs%>">
                                </div>
                            </div>
                            <div class="form-group row ">
                                <label for="form_css" class='col-md-3 control-label'>Write CSS: </label>
                                <div class='col-md-9'>
                                <%
                                String formCss = getRsValue(rs, "form_css");       
                                    
                                %>
                                    <div id="css_code_editor"></div>
                                    <input type='hidden' id='form_css' name='form_css' value="<%=formCss%>">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /Advanced options -->   
            </tr>
        </table>
    </div>
</form>
<!-- /additional fees --> 
        