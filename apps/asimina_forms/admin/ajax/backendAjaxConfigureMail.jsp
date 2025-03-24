<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.io.FileReader"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.io.File"%>

<%@ include file="../../common2.jsp"%>


<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>


<!DOCTYPE html>

<html>
<head>

	<style type="text/css">
		
		.lang1show
		{
			display:none;
		}
		.lang2show
		{
			display:none;
		}
		.lang3show
		{
			display:none;
		}
		.lang4show
		{
			display:none;
		}
		.lang5show
		{
			display:none;
		}

	</style>

</head>
<body>

<%
	String filePath = com.etn.beans.app.GlobalParm.getParm("MAIL_UPLOAD_PATH") + "unpublished_mail";
	String formId = parseNull(request.getParameter("fid"));
	String isSaveMailConfigure = parseNull(request.getParameter("isSaveMailConfigure"));
	String formName = "";
	String tableName = "";
	String isUpdateMailConfigure = parseNull(request.getParameter("isUpdateMailConfigure"));
	String configurationExists = "";
	String langId = parseNull(request.getParameter("langId"));
	List<Language> langsList = getLangs(Etn,session);
	Language firstLanguage = langsList.get(0);
	if(langId.length() == 0) langId = langsList.get(0).getLanguageId();

	String isCustomerEmail = parseNull(request.getParameter("config_cust_email"));
	String isBackOfficeEmail = parseNull(request.getParameter("config_bk_ofc_email"));
	String backOfficeEmail = parseNull(request.getParameter("lang_email"));
	String backOfficeTemplateType = parseNull(request.getParameter("bk_ofc_tt"));
	String config_sms = parseNull(request.getParameter("customer_sms_config"));
	
	String backOfficeEmailCc = "";
	String backOfficeEmailCi = "";

	if(backOfficeEmail.length() > 0) {

		backOfficeEmail = backOfficeEmail.replaceAll(";", ":");
		backOfficeEmail = backOfficeEmail.replaceAll(",", ":");
		backOfficeEmail = "nomail," + backOfficeEmail;
	} 
	
	HashMap<String, String> customerEmailParam = new HashMap<String, String>();
	HashMap<String, String> backOfficeEmailParam = new HashMap<String, String>();
	

	for(Language lang: langsList){
		String suffix = "_lang_"+lang.getLanguageId();
		String prefix = "lang_"+lang.getLanguageId()+"_";
		if(lang.getLanguageId().equals("1")){
			suffix="";
			prefix="";
		}
		customerEmailParam.put("sujet"+suffix,parseNull(request.getParameter("lang_"+lang.getLanguageId()+"_subj")));
		customerEmailParam.put(prefix+"texte",parseNull(request.getParameter("lang_"+lang.getLanguageId()+"_texte")));
	}
	customerEmailParam.put("nom",parseNull(request.getParameter("nom")));
	customerEmailParam.put("cust_ofc_tt",parseNull(request.getParameter("cust_ofc_tt")));

	String lang_tab = parseNull(request.getParameter("lang_tab"));
	
	if(lang_tab.length() == 0){
		lang_tab = "lang"+firstLanguage.getLanguageId()+"show";
	} 

	Set formRs = Etn.execute("SELECT * FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId));
	boolean isGame=false;
	if(formRs.next()) {

		formName = parseNull(formRs.value("process_name"));
		tableName = parseNull(formRs.value("table_name"));
		if(tableName.contains("game_"))
			isGame = true;
	}

	String query = "";
	String values = "";
	int customerMailId = 0;
	int backofficeMailId = 0;
	int cust_sms_id=0;

	if(isCustomerEmail.length() == 0) isCustomerEmail = "1";
	else{

		if(isCustomerEmail.equals("on")) isCustomerEmail = "1";
		else isCustomerEmail = "0";
	}

	if(isBackOfficeEmail.length() == 0) isBackOfficeEmail = "1";
	else{

		if(isBackOfficeEmail.equals("on")) isBackOfficeEmail = "1";
		else isBackOfficeEmail = "0";
	}

	formRs.moveFirst();
	if(formRs.next()){
		
		customerMailId = parseNullInt(formRs.value("cust_eid"));
		backofficeMailId = parseNullInt(formRs.value("bk_ofc_eid"));
	}

	Set updateConfigRs = Etn.execute("SELECT * FROM mails_unpublished WHERE id IN (" + escape.cote(""+customerMailId) + "," + escape.cote(""+backofficeMailId) + ") ");

	if(updateConfigRs.rs.Rows > 0) configurationExists = "yes";

	boolean flag = false;
	
	formRs.moveFirst();
	if(formRs.next()){
		
		isCustomerEmail = parseNull(formRs.value("is_email_cust"));
		isBackOfficeEmail = parseNull(formRs.value("is_email_bk_ofc"));
		customerMailId = parseNullInt(formRs.value("cust_eid"));
		backofficeMailId = parseNullInt(formRs.value("bk_ofc_eid"));
		cust_sms_id = parseNullInt(formRs.value("cust_sms_id"));
		
		if(cust_sms_id>0)
			config_sms = "1";

	}

	Set smsRs = Etn.execute("SELECT * FROM sms_unpublished WHERE sms_id = " + escape.cote(""+cust_sms_id));
	if(smsRs.next()){
		customerEmailParam.put("nom",parseNull(smsRs.value("nom")));
		for(Language lang: langsList){
			String prefix = "lang_"+lang.getLanguageId()+"_";
			if(lang.getLanguageId().equals("1")){
				prefix="";
			}
			customerEmailParam.put(prefix+"texte",parseNull(smsRs.value(prefix+"texte")));
		}
	}

	Set mailsRs = Etn.execute("SELECT * FROM mails_unpublished m WHERE id = " + escape.cote(""+customerMailId));
	if(mailsRs.next()){
		for(Language lang: langsList){
			String suffix = "_lang_"+lang.getLanguageId();
			if(lang.getLanguageId().equals("1")){
				suffix="";
			}
			customerEmailParam.put("sujet"+suffix,parseNull(mailsRs.value("sujet"+suffix)));
		}
		customerEmailParam.put("template_type",parseNull(mailsRs.value("template_type")));
	}

	Set mailConfgRs = Etn.execute("SELECT * FROM mails_unpublished m, mail_config_unpublished mc WHERE m.id = mc.id AND m.id = " + escape.cote(backofficeMailId+""));
	if(mailConfgRs.next()){
		
		backOfficeEmail = parseNull(mailConfgRs.value("email_to"));
		backOfficeEmailCc = parseNull(mailConfgRs.value("email_cc"));
		backOfficeEmailCi = parseNull(mailConfgRs.value("email_ci"));

		if(backOfficeEmail.length() > 7) backOfficeEmail = backOfficeEmail.substring(7, backOfficeEmail.length());
		if(backOfficeEmailCc.length() > 7) backOfficeEmailCc = backOfficeEmailCc.substring(7, backOfficeEmailCc.length());
		if(backOfficeEmailCi.length() > 7) backOfficeEmailCi = backOfficeEmailCi.substring(7, backOfficeEmailCi.length());
		for(Language lang: langsList){
			String suffix = "_lang_"+lang.getLanguageId();
			if(lang.getLanguageId().equals("1")){
				suffix="";
			}
			backOfficeEmailParam.put("sujet"+suffix,parseNull(mailConfgRs.value("sujet"+suffix)));
		}
		backOfficeEmailParam.put("template_type",parseNull(mailConfgRs.value("template_type")));
	}
	for(Language lang: langsList){
		String suffix="_"+lang.getCode();
		if(lang.getLanguageId().equals("1"))
			suffix="";
		
		customerEmailParam.put("customerTemplate"+lang.getLanguageId(),readDataFromFile(filePath+customerMailId+suffix, tableName));
		customerEmailParam.put("customerTemplateFreemarker"+lang.getLanguageId(),readDataFromFile(filePath+customerMailId+suffix+".ftl", tableName));
		backOfficeEmailParam.put("backOfficeTemplate"+lang.getLanguageId(),readDataFromFile(filePath+backofficeMailId+suffix, tableName));
		backOfficeEmailParam.put("backOfficeTemplateFreemarker"+lang.getLanguageId(),readDataFromFile(filePath+backofficeMailId+suffix+".ftl", tableName));

	}
	updateConfigRs = Etn.execute("SELECT * FROM mails_unpublished WHERE id IN (" + escape.cote(""+customerMailId) + "," + escape.cote(""+backofficeMailId) + ") ");

	if(updateConfigRs.rs.Rows > 0) configurationExists = "yes";


	Set ffrs = Etn.execute("SELECT * FROM process_form_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND type = " + escape.cote("email"));	
	Set formFieldsRs = Etn.execute("SELECT pff.db_column_name, pffd.label FROM process_form_fields_unpublished pff, process_form_field_descriptions_unpublished pffd WHERE pffd.langue_id = "+escape.cote(langId)+" and pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pff.form_id = " + escape.cote(formId) + " AND pff.db_column_name IS NOT NULL AND pff.db_column_name != '' AND type != " + escape.cote("label") + " ORDER BY label;");

    LinkedHashMap<String, String> templateValues = new LinkedHashMap<String, String>();
    templateValues.put("1","Basic orange email");
    templateValues.put("2","Customer service email");
    templateValues.put("3","RDV confirmation");


    LinkedHashMap<String, String> templateTypeValues = new LinkedHashMap<String, String>();
    templateTypeValues.put("text","Enrich text");
    templateTypeValues.put("freemarker","Encoded template");

    LinkedHashMap<String, String> formFieldValues = new LinkedHashMap<String, String>();
    LinkedHashMap<String, String> formFieldFreemarkerValues = new LinkedHashMap<String, String>();

	while(formFieldsRs.next()){

		formFieldValues.put("db"+parseNull(formFieldsRs.value("db_column_name")), "[" + parseNull(formFieldsRs.value("label")) + " : db" + parseNull(formFieldsRs.value("db_column_name")) + "]");

		formFieldFreemarkerValues.put("${"+parseNull(formFieldsRs.value("db_column_name"))+"}", "[" + parseNull(formFieldsRs.value("label")) + " : ${" + parseNull(formFieldsRs.value("db_column_name")) + "}]");
	}

    ArrayList arr = new ArrayList<String>();
%>

	<!-- buttons bar -->
	<div class="btn-toolbar mb-2 mb-md-0 float-right">
		<div class="btn-group mr-2 mb-2" role="group" aria-label="...">
			<button type="button" class="btn btn-primary" id="saveBtn" onclick='onsave();'>Save</button>
		</div>
	</div>
	<!-- /buttons bar -->

	<!-- container -->

	<div>
		<form id="config_email_frm" name="config_email_frm" enctype="application/x-www-form-urlencoded" method="post" action="editProcess.jsp?form_id=<%=formId%>">

			<div class="d-none" style='font-weight:bold; font-size:16px; margin-top:25px'>

				<div class="col-sm-12" style="margin-top: 50px; margin-bottom: 30px;">
					<table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
						<tr>
							<%	
								for(Language lang:langsList){
							%>
								<td><a id='tab_lang<%=lang.getLanguageId()%>show' href='javascript:selecttab("lang<%=lang.getLanguageId()%>show")' style='text-decoration:none; color: #3170A6;border: 1px solid #BCE8F1;padding: 10px;padding-left: 60px;padding-right: 60px;'><%=lang.getLanguage()%></a><input type="hidden" name="lang_<%=lang.getLanguageId()%>_code" value="<%= lang.getCode()%>" /></td>
							<%}%>
						</tr>
					</table>
				</div>
			</div>
			<% if(isGame) {%>
			<!-- Configure Customer SMS -->
			<div class="btn-group col-12" style="padding-left:0px; padding-right:0px" role="group" aria-label="Basic example">
                <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#configure_backoffice_sms" role="button" aria-expanded="false" aria-controls="configure_customer_sms">Configure customer SMS</button>
				<div class="btn-group" role="group">
					<button value='<% if( config_sms.equals("1") ){ %> Yes <% } else { %> No <% } %>' type="button" class="btn btn-secondary dropdown-toggle mb-2" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><% if( config_sms.equals("1") ){ %> Yes <% } else { %> No <% } %></button>
					<div class="dropdown-menu" aria-labelledby="customer_sms_config" x-placement="bottom-start" style="position: absolute; will-change: transform; top: 0px; left: 0px; transform: translate3d(-88px, 44px, 0px);">
						<a class="dropdown-item" onclick="configSms(this, 'customer_sms_config')">Yes</a>
						<a class="dropdown-item" onclick="configSms(this, 'customer_sms_config')">No</a>
						<input type="hidden" id="customer_sms_config" name="customer_sms_config" value="<%=config_sms%>">
					</div>
				</div>
            </div>

			<div class="collapse show p-3" id="configure_customer_sms">
				<div class="form-group row ">
					<label for="nom" class='col-md-3 control-label is-required'>Name :</label>
					<div class='col-md-9'>
						<input class="form-control" type='text' name='nom' id='nom' value='<%= parseNull(customerEmailParam.get("nom"))%>' maxlength='255'/>
						<div class="invalid-feedback">Name to is mandatory.</div>
					</div>
				</div>

				<div class="form-group row ">
					<label for="customer_sms_available_fields" class='col-md-3 control-label'>Available fields:</label>
					<div class='col-md-8 pr-0'>
						<%
							arr = new ArrayList<String>();
							arr.add("");
						%>
						<%=addSelectControl("customer_sms_available_fields", "customer_sms_available_fields", formFieldValues, arr, "custom-select", "", false)%>
					</div>
					<div class="col-md-1 pl-0">
						<button class="btn btn-success" id="customer_sms_copy_available_fields" type="button" ck-editor-customer-sms-id="">Copy</button>
					</div>
				</div>

				<div class="form-group row ">
					<label for="sms-texte" class='col-md-3 control-label is-required'>Text :</label>
					<div class='col-md-9'>
							<%	
								for(Language lang:langsList){
									String prefix = "lang_"+lang.getLanguageId()+"_";
									if(lang.getLanguageId().equals("1")){
										prefix="";
									}
							%>
								<textarea class="lang<%=lang.getLanguageId()%>show form-control"  name='lang_<%=lang.getLanguageId()%>_texte' id='lang_<%=lang.getLanguageId()%>_texte' row="3" ><%= parseNull(customerEmailParam.get(prefix+"texte"))%></textarea>
							<%}%>
						<div class="invalid-feedback">Texte to is mandatory.</div>
					</div>
				</div>
			</div>      
			<!-- Configure Customer SMS -->
			<%}%>

                <div class="btn-group col-12" style="padding-left:0px; padding-right:0px" role="group" aria-label="Basic example">
                    <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#configure_customer_email" role="button" aria-expanded="false" aria-controls="configure_customer_email">Configure customer email</button>


					<div class="btn-group" role="group">

						<button value='<% if( isCustomerEmail.equals("1") ){ %> Yes <% } else { %> No <% } %>' type="button" class="btn btn-secondary dropdown-toggle mb-2" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><% if( isCustomerEmail.equals("1") ){ %> Yes <% } else { %> No <% } %></button>

						<div class="dropdown-menu" aria-labelledby="config_cust_email" x-placement="bottom-start" style="position: absolute; will-change: transform; top: 0px; left: 0px; transform: translate3d(-88px, 44px, 0px);" >
								<a class="dropdown-item" onclick="configMail(this, 'config_cust_email')">Yes</a>
								<a class="dropdown-item" onclick="configMail(this, 'config_cust_email')">No</a>
								<input type="hidden" id="config_cust_email" name="config_cust_email" value="<%=isCustomerEmail%>">
						</div>
					</div>

					<div>
						<button class="btn btn-success" style="min-height: 45px;" data-size="lg" type="button" onclick="window.open('emailPreview.jsp?id=<%=customerMailId%>&form_id=<%=formId%>&table_name=<%=tableName%>&type=<%=customerEmailParam.get("cust_ofc_tt")%>&lang=<%=langId%>','mail<%=customerMailId%>')" <%if(customerMailId == 0){%>disabled<%}%> >preview</button>
					</div>
                </div>

                <!-- Configure customer email -->
                <div class="collapse show p-3" id="configure_customer_email">
                    <div class="form-group row ">
                        <label for="customer_template" class='col-md-3 control-label is-required'>Template:</label>
                        <div class='col-md-9'>
                            <%
                                arr = new ArrayList<String>();
                                arr.add("2");
                            %>
                            <%=addSelectControl("customer_template", "customer_template", templateValues, arr, "custom-select", "", false)%>

                            <div class="invalid-feedback">Customer template is mandatory.</div>
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="subject" class='col-md-3 control-label is-required'>Subject:</label>
                        <div class='col-md-9'>
							<%	
								for(Language lang:langsList){
									String suffix="_lang_"+lang.getLanguageId();
									if(lang.getLanguageId().equals("1"))
										suffix="";
							%>
								<input class="lang<%=lang.getLanguageId()%>show form-control" type='text' name='lang_<%=lang.getLanguageId()%>_subj' id='lang_<%=lang.getLanguageId()%>_subj' value='<%= parseNull(customerEmailParam.get("sujet"+suffix))%>' maxlength='255'/>
							<%}%>
                            <div class="invalid-feedback">Customer subject is mandatory.</div>
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="subject" class='col-md-3 control-label'>Template type:</label>
                        <div class='col-md-9'>
                            <%
                                arr = new ArrayList<String>();
                                arr.add(customerEmailParam.get("cust_ofc_tt"));
                            %>
                            <%=addSelectControl("cust_ofc_tt", "cust_ofc_tt", templateTypeValues, arr, "custom-select", "onchange=update_template_type(this)", false)%>
                        </div>
                    </div>

                    <div class="form-group row ">
                        <label for="customer_available_fields" class='col-md-3 control-label'>Available fields:</label>
                        <div class='col-md-8 pr-0'>                        	
                            <%
                                arr = new ArrayList<String>();
                                arr.add("");
                            %>
                            <%=addSelectControl("customer_available_fields", "customer_available_fields", formFieldValues, arr, "custom-select d-none", "", false)%>
                            <%=addSelectControl("customer_available_fields_fm", "customer_available_fields_fm", formFieldFreemarkerValues, arr, "custom-select d-none", "", false)%>
                        </div>
                        <div class="col-md-1 pl-0">
                            <button class="btn btn-success" id="customer_copy_avaiable_fields" type="button" ck-editor-customer-id="">Copy</button>
                        </div>
                    </div>

                    <div class="form-group row d-none cust_ofc_ta_template">
                        <label for="email" class='col-md-3 control-label is-required'>Email:</label>
                        <div class='col-md-9'>
							<%	
								for(Language lang:langsList){
							%>
							<div class="lang<%=lang.getLanguageId()%>showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" id="lang_<%=lang.getLanguageId()%>_template"><%= parseNull(customerEmailParam.get("customerTemplate"+lang.getLanguageId()))%></textarea>
								<input type="hidden" name="xss_lang_<%=lang.getLanguageId()%>_template" id="xss_lang_<%=lang.getLanguageId()%>_template" value="">
							</div>
							<%}%>
                            <div class="invalid-feedback">Customer email is mandatory.</div>
                        </div>
                    </div>

	                <div class="form-group row d-none cust_ofc_fm_template">
	                    <label for="email" class='col-md-3 control-label is-required'>Email:</label>
	                    <div class='col-md-9'>
							<%	
								for(Language lang:langsList){
							%>
							<div class="lang<%=lang.getLanguageId()%>showta" style="display: none;">
								<div class="freemarker_customeroffice_field"></div>
								<textarea class="d-none" id="lang_<%=lang.getLanguageId()%>_template_fm"><%= parseNull(customerEmailParam.get("customerTemplateFreemarker"+lang.getLanguageId()))%></textarea>
								<input type="hidden" name="xss_lang_<%=lang.getLanguageId()%>_template_fm" id="xss_lang_<%=lang.getLanguageId()%>_template_fm" value="">
							</div>
							<%}%>
	                        <div class="invalid-feedback">Customer email is mandatory.</div>
	                    </div>
	                </div>
                </div>
                <!-- Configure customer email -->                                

			

            <div class="btn-group col-12" style="padding-left:0px; padding-right:0px" role="group" aria-label="Basic example">
			
                <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#configure_backoffice_email" role="button" aria-expanded="false" aria-controls="configure_customer_email">Configure backoffice email</button>

				<div class="btn-group" role="group">

					<button value='<% if( isBackOfficeEmail.equals("1") ){ %> Yes <% } else { %> No <% } %>' type="button" class="btn btn-secondary dropdown-toggle mb-2" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><% if( isBackOfficeEmail.equals("1") ){ %> Yes <% } else { %> No <% } %></button>

					<div class="dropdown-menu" aria-labelledby="config_bk_ofc_email" x-placement="bottom-start" style="position: absolute; will-change: transform; top: 0px; left: 0px; transform: translate3d(-88px, 44px, 0px);">
							<a class="dropdown-item" onclick="configMail(this, 'config_bk_ofc_email')">Yes</a>
							<a class="dropdown-item" onclick="configMail(this, 'config_bk_ofc_email')">No</a>
							<input type="hidden" id="config_bk_ofc_email" name="config_bk_ofc_email" value="<%=isBackOfficeEmail%>">
					</div>
				</div>

				<div>
					<button class="btn btn-success" style="min-height: 45px;" data-size="lg" type="button" onclick="window.open('emailPreview.jsp?id=<%=backofficeMailId%>&form_id=<%=formId%>&table_name=<%=tableName%>&type=<%=backOfficeTemplateType%>&lang=<%=langId%>','mail<%=backofficeMailId%>')" <%if(backofficeMailId == 0){%>disabled<%}%>>preview</button>
				</div>
            </div>

            <!-- Configure backoffice email -->
            <div class="collapse show p-3" id="configure_backoffice_email"> <div class="form-group row "> <label for="backoffice_template" class='col-md-3 control-label is-required'>Template:</label> <div class='col-md-9'> <%
                            arr = new ArrayList<String>();
                            arr.add("2");
                        %>
                        <%=addSelectControl("backoffice_template", "backoffice_template", templateValues, arr, "custom-select", "", false)%>
                        <div class="invalid-feedback">Backoffice template is mandatory.</div>
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="lang_email" class='col-md-3 control-label is-required'>To:</label>
                    <div class='col-md-9'>
                        <input type="text" id="lang_email" name="lang_email" class="form-control" value='<%=backOfficeEmail%>' />
                        <div class="invalid-feedback">Backoffice email to is mandatory.</div>
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="email_cc" class='col-md-3 control-label'>CC:</label>
                    <div class='col-md-9'>
                        <input type="text" id="email_cc" name="email_cc" value='<%=backOfficeEmailCc%>' class="form-control" />
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="email_ci" class='col-md-3 control-label'>CI:</label>
                    <div class='col-md-9'>
                        <input type="text" id="email_ci" name="email_ci" value='<%=backOfficeEmailCi%>' class="form-control" />
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="subject" class='col-md-3 control-label is-required'>Subject:</label>
                    <div class='col-md-9'>
						<%	
							for(Language lang:langsList){
								String suffix = "_lang_"+lang.getLanguageId();
								if(lang.getLanguageId().equals("1"))
								suffix="";
						%>
						<input class="lang<%=lang.getLanguageId()%>show form-control" type='text' name='lang_<%=lang.getLanguageId()%>_back_office_subj' id='lang_<%=lang.getLanguageId()%>_back_office_subj' value='<%= parseNull(backOfficeEmailParam.get("sujet"+suffix))%>' maxlength='255'/>
						<%}%>
                        <div class="invalid-feedback">Backoffice subject is mandatory.</div>
                    </div>
                </div>

                <div class="form-group row ">
                    <label for="subject" class='col-md-3 control-label'>Template type:</label>
                    <div class='col-md-9'>
                            <%
                                arr = new ArrayList<String>();
                                arr.add(backOfficeEmailParam.get("bk_ofc_tt"));
                            %>
                        <%=addSelectControl("bk_ofc_tt", "bk_ofc_tt", templateTypeValues, arr, "custom-select", "onchange=update_template_type(this)", false)%>
                        </div>
                </div>

                <div class="form-group row ">
                    <label for="backoffice_available_fields" class='col-md-3 control-label'>Available fields:</label>
                    <div class='col-md-8 pr-0'>
                        <%
                            arr = new ArrayList<String>();
                            arr.add("");
                        %>
                        <%=addSelectControl("backoffice_available_fields", "backoffice_available_fields", formFieldValues, arr, "custom-select d-none", "", false)%>
                        <%=addSelectControl("backoffice_available_fields_fm", "backoffice_available_fields_fm", formFieldFreemarkerValues, arr, "custom-select d-none", "", false)%>
                    </div>
                    <div class="col-md-1 pl-0">
                        <button class="btn btn-success" id="backoffice_copy_avaiable_fields" type="button" ck-editor-backoffice-id="">Copy</button>
                    </div>
                </div>

                <div class="form-group row bk_ofc_ta_template">
                    <label for="email" class='col-md-3 control-label is-required'>Email:</label>
                    <div class='col-md-9'>
						<%	
							for(Language lang:langsList){
						%>
						<div class="lang<%=lang.getLanguageId()%>showta" style="display: none;">
							<textarea class="ckeditor_field" style="height: 350px;" rows="5" id="lang_<%=lang.getLanguageId()%>_back_office_template"><%= parseNull(backOfficeEmailParam.get("backOfficeTemplate"+lang.getLanguageId()))%></textarea>
							<input type="hidden" name="xss_lang_<%=lang.getLanguageId()%>_back_office_template" id="xss_lang_<%=lang.getLanguageId()%>_back_office_template" value="">
						</div>
						<%}%>
						
                        <div class="invalid-feedback">Backoffice email is mandatory.</div>
                    </div>
                </div>

                <div class="form-group row d-none bk_ofc_fm_template">
                    <label for="email" class='col-md-3 control-label is-required'>Email:</label>
                    <div class='col-md-9'>
						<%	
							for(Language lang:langsList){
						%>
						<div class="lang<%=lang.getLanguageId()%>showta" style="display: none;">
							<div class="freemarker_backoffice_field"></div>
							<textarea class="d-none" id="lang_<%=lang.getLanguageId()%>_back_office_template_fm"><%= parseNull(backOfficeEmailParam.get("backOfficeTemplateFreemarker"+lang.getLanguageId()))%></textarea>
							<input type="hidden" name="xss_lang_<%=lang.getLanguageId()%>_back_office_template_fm" id="xss_lang_<%=lang.getLanguageId()%>_back_office_template_fm" value="">
						</div>
						<%}%>
                        <div class="invalid-feedback">Backoffice email is mandatory.</div>
                    </div>
                </div>
            </div>
            <!-- Configure backoffice email -->      

			
			<%
				if(configurationExists.length() > 0 && configurationExists.equals("yes")){
			%>
					<input type="hidden" name="isUpdateMailConfigure" value="update" />
			<%
				} else {
			%>
					<input type="hidden" name="isSaveMailConfigure" value="save" />
			<%
				}
			%>
			<input type="hidden" id="is_email_field_exists" value="<%= ffrs.rs.Rows%>">
			<input type="hidden" name="isConfigureMail" value="1">
			<input type="hidden" id="lang_id" name="lang_id" value="<%=langId%>">
			<input type="hidden" id="form_id" name="form_id" value="<%=formId%>">
			<input type="hidden" id="image_browser" value='<%=GlobalParm.getParm("PAGES_URL")%>admin/imageBrowser.jsp?popup=1'>
		</form>
	</div>
	<br>
</div>

</body>
</html>