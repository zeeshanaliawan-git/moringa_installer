<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.io.PrintWriter, java.io.File, java.io.StringWriter, java.io.IOException"%>
<%@ page import="com.etn.util.Base64"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language" %>
<%@ page import="freemarker.template.Configuration, freemarker.template.Template, freemarker.cache.*, freemarker.template.TemplateException" %>

<%@ include file="../../common2.jsp"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%!
    String decodeCKEditorValue(String str){
        if(str != null){
            return str.replace("_etnipt_=","src=").replace("_etnhrf_=","href=").replace("_etnstl_=","style=");
        }
        else{
            return str;
        }
    }

	void writeDataInFile(String path, String data, String tableName){

		PrintWriter pw = null;

		try{

			String html = "Content-Type: multipart/alternative;\n boundary=\"------------010101080201020804090106\"\n\nThis is a multi-part message in MIME format.\n--------------010101080201020804090106\nContent-Type: text/html; charset=utf-8\nContent-Transfer-Encoding: 7bit\n\n\n";
			html += "<div id='" + tableName + "_template_div'>\n"+data+"\n</div>";
			html += "\n--------------010101080201020804090106--";

			pw = new PrintWriter(new File(path));
			pw.write(html);
			pw.flush();

		}catch(Exception e){

			e.printStackTrace();
		}finally{

			if(pw != null) pw.close();
		}
	}

	void writeDataInTempFile(String path, String content){

		PrintWriter pw = null;

		try{

			pw = new PrintWriter(new File(path.replaceAll("../", "")));
			pw.write(content);
			pw.flush();

		}catch(Exception e){

			e.printStackTrace();
		}finally{

			if(pw != null) pw.close();
		}
	}

	JSONObject writeDataFreemarkerTemplate(String fileName, String templateContent, String fileId, String lang, String tableName, Map<String, String> formFieldFreemarkerValues) throws Exception {

		writeDataInTempFile(fileName + "_tmp.ftl", templateContent);

		String templateName = com.etn.beans.app.GlobalParm.getParm("MAIL_REPOSITORY") + "/unpublished_mail" + (fileId.replaceAll("/", "").replaceAll("\\\\", ""));

		File ftemplate = new File(templateName + "_tmp.ftl");

		if(lang.length() > 0)
			templateName += "_" + lang.replaceAll("/", "").replaceAll("\\\\", "");


		if(!ftemplate.exists() || ftemplate.length() == 0)
			templateName = com.etn.beans.app.GlobalParm.getParm("MAIL_REPOSITORY") + "/unpublished_mail" + (fileId.replaceAll("/", "").replaceAll("\\\\", ""));

		JSONObject json = validateFreemarkerTemplate("/unpublished_mail" + fileId, formFieldFreemarkerValues);

		if(json.get("status").equals("success")){

			File tempTemplate = new File(com.etn.beans.app.GlobalParm.getParm("MAIL_REPOSITORY") + "/unpublished_mail" + (fileId.replaceAll("/", "").replaceAll("\\\\", "")) + "_tmp.ftl");

			if(tempTemplate.exists() || tempTemplate.length() != 0)
				tempTemplate.delete();

			writeDataInFile(templateName + ".ftl", templateContent, tableName);
		}

		return json;
	}

    private JSONObject validateFreemarkerTemplate(String templateName, Map<String, String> map) throws JSONException{

		JSONObject json = new JSONObject();

    	try{

	        Configuration cfg = getFreemarkerConfig(com.etn.beans.app.GlobalParm.getParm("MAIL_REPOSITORY"));

	        Template template = cfg.getTemplate(templateName+"_tmp.ftl");

	        StringWriter html = new StringWriter();

	        template.process(map, html);

	        json.put("status","success");
	        json.put("message","");

	    } catch(IOException ioe){

	    	json.put("status","error");
	        json.put("message",ioe.getMessage());

		} catch(TemplateException te){

	    	json.put("status","error");
	        json.put("message",te.getMessage());
		}

		return json;
    }
%>
<%
	String isConfigureMail = parseNull(request.getParameter("isConfigureMail"));
	JSONObject responseJson = new JSONObject();

	if(isConfigureMail.length() > 0 && isConfigureMail.equals("1")){

		String queryMailConfig = "";
		String langId = "";
		String formName = "";
		String tableName = "";

		int customerMailId = 0;
		int backofficeMailId = 0;
		int cust_sms_id=0;

		String selectedSiteId = getSelectedSiteId(session);
		String formId = parseNull(request.getParameter("form_id"));

		Set rs = Etn.execute("SELECT * FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId) + " and site_id = " + escape.cote(selectedSiteId));
		Set formFieldsRs = Etn.execute("SELECT pff.db_column_name, pff.type, now() as _datetime, curdate() as _date FROM process_form_fields_unpublished pff, process_form_field_descriptions_unpublished pffd WHERE pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pff.form_id = " + escape.cote(formId) + " AND pff.db_column_name IS NOT NULL AND pff.db_column_name != '';");


		if(rs.rs.Rows == 0)
		{
		    response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
	       	response.setHeader("Location", "process.jsp?msg=Form not found");
			return;
		}

		if(rs.next()){

			formName = parseNull(rs.value("process_name"));
			tableName = parseNull(rs.value("table_name"));
			customerMailId = parseNullInt(rs.value("cust_eid"));
			backofficeMailId = parseNullInt(rs.value("bk_ofc_eid"));
			cust_sms_id = parseNullInt(rs.value("cust_sms_id"));
		}

		Map<String, String> formFieldFreemarkerValues = new HashMap<String, String>();

		while(formFieldsRs.next()){

			if(parseNull(formFieldsRs.value("type")).equals("textdate"))
				formFieldFreemarkerValues.put(parseNull(formFieldsRs.value("db_column_name")), parseNull(formFieldsRs.value("_date")));
			else if(parseNull(formFieldsRs.value("type")).equals("textdatetime"))
				formFieldFreemarkerValues.put(parseNull(formFieldsRs.value("db_column_name")), parseNull(formFieldsRs.value("_datetime")));
			else if(parseNull(formFieldsRs.value("type")).equals("number"))
				formFieldFreemarkerValues.put(parseNull(formFieldsRs.value("db_column_name")), "0");
			else
				formFieldFreemarkerValues.put(parseNull(formFieldsRs.value("db_column_name")), "");
		}

		String isSaveMailConfigure = parseNull(request.getParameter("isSaveMailConfigure"));
		String customerSmsConfig = parseNull(request.getParameter("customer_sms_config"));
		
		String isUpdateMailConfigure = parseNull(request.getParameter("isUpdateMailConfigure"));
		String filePath = com.etn.beans.app.GlobalParm.getParm("MAIL_UPLOAD_PATH") + "unpublished_mail";

		String isCustomerEmail = parseNull(request.getParameter("config_cust_email"));
		String isBackOfficeEmail = parseNull(request.getParameter("config_bk_ofc_email"));
		String backOfficeEmail = parseNull(request.getParameter("lang_email"));
		langId = parseNull(request.getParameter("lang_id"));

		if(backOfficeEmail.length() > 0) {

			backOfficeEmail = backOfficeEmail.replaceAll(";", ":");
			backOfficeEmail = backOfficeEmail.replaceAll(",", ":");
			backOfficeEmail = "nomail," + backOfficeEmail;
		}

		String backOfficeEmailCc = parseNull(request.getParameter("email_cc"));


		if(backOfficeEmailCc.length() > 0) {

			backOfficeEmailCc = backOfficeEmailCc.replaceAll(";", ":");
			backOfficeEmailCc = backOfficeEmailCc.replaceAll(",", ":");
			backOfficeEmailCc = "nomail," + backOfficeEmailCc;
		}

		String backOfficeEmailCi = parseNull(request.getParameter("email_ci"));


		if(backOfficeEmailCi.length() > 0) {

			backOfficeEmailCi = backOfficeEmailCi.replaceAll(";", ":");
			backOfficeEmailCi = backOfficeEmailCi.replaceAll(",", ":");
			backOfficeEmailCi = "nomail," + backOfficeEmailCi;
		}

		String customerEmailSubject1 = parseNull(request.getParameter("lang_1_subj"));
		String customerEmailSubject2 = parseNull(request.getParameter("lang_2_subj"));
		String customerEmailSubject3 = parseNull(request.getParameter("lang_3_subj"));
		String customerEmailSubject4 = parseNull(request.getParameter("lang_4_subj"));
		String customerEmailSubject5 = parseNull(request.getParameter("lang_5_subj"));

		String customerTexte1 = parseNull(request.getParameter("texte"));
		String customerTexte2 = parseNull(request.getParameter("lang_2_texte"));
		String customerTexte3 = parseNull(request.getParameter("lang_3_texte"));
		String customerTexte4 = parseNull(request.getParameter("lang_4_texte"));
		String customerTexte5 = parseNull(request.getParameter("lang_5_texte"));

		String customerTemplate1 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_1_template")));
		//System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>> "+customerTemplate1);
		String customerTemplate2 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_2_template")));
		String customerTemplate3 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_3_template")));
		String customerTemplate4 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_4_template")));
		String customerTemplate5 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_5_template")));

		String customerTemplateFreemarker1 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_1_template_fm")));
		//System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>> "+customerTemplateFreemarker1);
		String customerTemplateFreemarker2 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_2_template_fm")));
		String customerTemplateFreemarker3 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_3_template_fm")));
		String customerTemplateFreemarker4 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_4_template_fm")));
		String customerTemplateFreemarker5 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_5_template_fm")));

		String customerOfficeTemplateType = parseNull(request.getParameter("cust_ofc_tt"));

		String backOfficeEmailSubject1 = parseNull(request.getParameter("lang_1_back_office_subj"));
		String backOfficeEmailSubject2 = parseNull(request.getParameter("lang_2_back_office_subj"));
		String backOfficeEmailSubject3 = parseNull(request.getParameter("lang_3_back_office_subj"));
		String backOfficeEmailSubject4 = parseNull(request.getParameter("lang_4_back_office_subj"));
		String backOfficeEmailSubject5 = parseNull(request.getParameter("lang_5_back_office_subj"));

		String backOfficeTemplate1 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_1_back_office_template")));
		//System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>> "+backOfficeTemplate1);
		String backOfficeTemplate2 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_2_back_office_template")));
		String backOfficeTemplate3 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_3_back_office_template")));
		String backOfficeTemplate4 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_4_back_office_template")));
		String backOfficeTemplate5 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_5_back_office_template")));

		String backOfficeTemplateFreemarker1 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_1_back_office_template_fm")));
		String backOfficeTemplateFreemarker2 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_2_back_office_template_fm")));
		String backOfficeTemplateFreemarker3 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_3_back_office_template_fm")));
		String backOfficeTemplateFreemarker4 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_4_back_office_template_fm")));
		String backOfficeTemplateFreemarker5 = decodeCKEditorValue(parseNull(request.getParameter("xss_lang_5_back_office_template_fm")));

		String backOfficeTemplateType = parseNull(request.getParameter("bk_ofc_tt"));

		String lang_tab = parseNull(request.getParameter("lang_tab"));

		if(lang_tab.length() == 0){

			lang_tab = "lang1show";
		}

		Set rsl = Etn.execute("select * from language order by langue_id ");
		String lang_1 = "", lang_2 = "", lang_3= "", lang_4 = "", lang_5 = "";
		String lang_1_id = "", lang_2_id = "", lang_3_id = "", lang_4_id = "", lang_5_id = "";
		int _j = 0;

		while(rsl.next())
		{
			if(_j == 0)
			{
				lang_1 = parseNull(rsl.value("langue_code"));
				lang_1_id = parseNull(rsl.value("langue_id"));
			}
			else if(_j == 1)
			{
				lang_2 = parseNull(rsl.value("langue_code"));
				lang_2_id = parseNull(rsl.value("langue_id"));
			}
			else if(_j == 2)
			{
				lang_3 = parseNull(rsl.value("langue_code"));
				lang_3_id = parseNull(rsl.value("langue_id"));
			}
			else if(_j == 3)
			{
				lang_4 = parseNull(rsl.value("langue_code"));
				lang_4_id = parseNull(rsl.value("langue_id"));
			}
			else if(_j == 4)
			{
				lang_5 = parseNull(rsl.value("langue_code"));
				lang_5_id = parseNull(rsl.value("langue_id"));
			}
			_j++;
		}

		String formType = "";
		Set formRs = Etn.execute("SELECT * from process_forms_unpublished WHERE form_id = " + escape.cote(formId));
		if(formRs.next()){

			formType = parseNull(formRs.value("type"));
		}

		if(isUpdateMailConfigure.length() > 0 && isUpdateMailConfigure.equals("update")){

			queryMailConfig = "UPDATE mails_unpublished SET sujet = " + escape.cote(customerEmailSubject1) + ", sujet_lang_2 = " + escape.cote(customerEmailSubject2) + ", sujet_lang_3 = " + escape.cote(customerEmailSubject3) + ", sujet_lang_4 = " + escape.cote(customerEmailSubject4) + ", sujet_lang_5 = " + escape.cote(customerEmailSubject5) + ", template_type = " + escape.cote(customerOfficeTemplateType) + " WHERE id = " + escape.cote(""+customerMailId);

			Etn.executeCmd(queryMailConfig);

			queryMailConfig = "UPDATE mails_unpublished SET sujet = " + escape.cote(backOfficeEmailSubject1) + ", sujet_lang_2 = " + escape.cote(backOfficeEmailSubject2) + ", sujet_lang_3 = " + escape.cote(backOfficeEmailSubject3) + ", sujet_lang_4 = " + escape.cote(backOfficeEmailSubject4) + ", sujet_lang_5 = " + escape.cote(backOfficeEmailSubject5) + ", template_type = " + escape.cote(backOfficeTemplateType) + " WHERE id = " + escape.cote(""+backofficeMailId);

			Etn.executeCmd(queryMailConfig);

			queryMailConfig = "UPDATE mail_config_unpublished SET email_to = " + escape.cote(backOfficeEmail) + ", email_cc = " + escape.cote(backOfficeEmailCc) + ", email_ci = " + escape.cote(backOfficeEmailCi) + " WHERE id = " + escape.cote(""+backofficeMailId);

			Etn.executeCmd(queryMailConfig);

			queryMailConfig = "UPDATE process_forms_unpublished SET is_email_cust = " + escape.cote(isCustomerEmail) + ", is_email_bk_ofc = " + escape.cote(isBackOfficeEmail) +", updated_on = now(), updated_by = "+escape.cote(String.valueOf(Etn.getId()))+ " WHERE form_id = " + escape.cote(formId);

			Etn.executeCmd(queryMailConfig);

			if(formType.equalsIgnoreCase("sign_up")){

				String actionConfigCsOfc = "sql:processNow";
				String actionConfigBkOfc = "sql:processNow";

				if(isCustomerEmail.equals("1")) {

					actionConfigCsOfc = "mail:" + customerMailId + ",sql:processNow";
				}

				if(isBackOfficeEmail.equals("1")) {

					actionConfigBkOfc = "mail:" + backofficeMailId + ",sql:processNow";
				}

				Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfigBkOfc) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("BackOfficeEmail"));

				Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfigBkOfc) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("BackOfficeEmail") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote("CheckAutoAccept"));

				Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfigCsOfc) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("CustomerEmail"));

				Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfigCsOfc) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("CustomerEmail") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote("Done"));

			} else {

				String actionConfig = "";

				if(isCustomerEmail.equals("1")) actionConfig = "mail:" + customerMailId;

				if(isBackOfficeEmail.equals("1")) {

					if(actionConfig.length() > 0)
						actionConfig += ",mail:" + backofficeMailId;
					else
						actionConfig = "mail:" + backofficeMailId;
				}

				if(actionConfig.length() > 0) actionConfig += ",sql:processNow";

				String startPhase = "";
				String nextPhase = "";
				if(formType.equals("forgot_password")){

					startPhase = "CustomerEmail";
					nextPhase = "Done";

				} else {
					//default values
					startPhase = "FormSubmitted";
					nextPhase = "EmailSent";
					
					/*
					* There are different case for forms process configuration
					* 1. Not for every form we have to send the email. In that case the form entry stays in FormSubmitted phase
					* 2. We have emails configured in which case the form will go to EmailSent phase.
					* 3. We have to do some special processing on form record but no emails to be sent. So in this case we will manually add a phase after FormSubmitted and do whatever we want to do.
					*	 In this case we must not delete the EmailSent phase but remove its arrow from FormSubmitted and add the arrow with 0 error from the new phase we added to EmailSent. 
					*	 In case in future we want to send emails also, system will add the emails action on that new arrow we added manually rather than over writing anything.
					* 4. We have to send emails and also do some processing. This is easy where we can add our new processing phase after the EmailSent phase.
					*/
					Set rsP = Etn.execute("Select * from rules where errCode = 0 and start_proc = "+ escape.cote(tableName)+ " and next_phase = "+escape.cote(nextPhase));
					if(rsP.next())
					{
						startPhase = rsP.value("start_phase");
					}
					System.out.println("backendAjaxMailHandler.jsp::startPhase::"+startPhase);
				}

				Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase));

				Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase) + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote(nextPhase));
			}

			try{

				if(customerMailId > 0) {

					JSONObject templateJson = new JSONObject();
					JSONObject languageJson = new JSONObject();

					if(customerTemplate1.length() > 0 || customerTemplateFreemarker1.length() > 0){

						if(lang_1.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId, customerTemplate1, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){
								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker1, customerMailId+"", "", tableName, formFieldFreemarkerValues);

								languageJson.put(lang_1_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}

					if(customerTemplate2.length() > 0 || customerTemplateFreemarker2.length() > 0){

						if(lang_2.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text") && customerTemplate2.length() > 0)
								writeDataInFile(filePath+customerMailId+"_"+lang_2, customerTemplate2, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker") && customerTemplateFreemarker2.length() > 0){
								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker2, customerMailId+"", lang_2, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_2_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}

					if(customerTemplate3.length() > 0 || customerTemplateFreemarker3.length() > 0){

						if(lang_3.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId+"_"+lang_3, customerTemplate3, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker3, customerMailId+"", lang_3, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_3_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}

					if(customerTemplate4.length() > 0 || customerTemplateFreemarker4.length() > 0){

						if(lang_4.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId+"_"+lang_4, customerTemplate4, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker4, customerMailId+"", lang_4, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_4_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}

					if(customerTemplate5.length() > 0 || customerTemplateFreemarker5.length() > 0){

						if(lang_5.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId+"_"+lang_5, customerTemplate5, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker5, customerMailId+"", lang_5, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_5_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}
				}

				if(backofficeMailId > 0){

					JSONObject templateJson = new JSONObject();
					JSONObject languageJson = new JSONObject();

					if(backOfficeTemplate1.length() > 0 || backOfficeTemplateFreemarker1.length() > 0){

						if(lang_1.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId, backOfficeTemplate1, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){
								templateJson = writeDataFreemarkerTemplate(filePath+backofficeMailId, backOfficeTemplateFreemarker1, backofficeMailId+"", "", tableName, formFieldFreemarkerValues);

								languageJson.put(lang_1_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}

					if(backOfficeTemplate2.length() > 0 || backOfficeTemplateFreemarker2.length() > 0){

						if(lang_2.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId+"_"+lang_2, backOfficeTemplate2, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){
								templateJson = writeDataFreemarkerTemplate(filePath+backofficeMailId, backOfficeTemplateFreemarker2, backofficeMailId+"", lang_2, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_2_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}

					if(backOfficeTemplate3.length() > 0 || backOfficeTemplateFreemarker3.length() > 0){

						if(lang_3.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId+"_"+lang_3, backOfficeTemplate3, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){
								templateJson = writeDataFreemarkerTemplate(filePath+backofficeMailId, backOfficeTemplateFreemarker3, backofficeMailId+"", lang_3, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_3_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}

					if(backOfficeTemplate4.length() > 0 || backOfficeTemplateFreemarker4.length() > 0){

						if(lang_4.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId+"_"+lang_4, backOfficeTemplate4, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){
								templateJson = writeDataFreemarkerTemplate(filePath+backofficeMailId, backOfficeTemplateFreemarker4, backofficeMailId+"", lang_4, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_4_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}

					if(backOfficeTemplate5.length() > 0 || backOfficeTemplateFreemarker5.length() > 0){

						if(lang_5.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId+"_"+lang_5, backOfficeTemplate5, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){
								templateJson = writeDataFreemarkerTemplate(filePath+backofficeMailId, backOfficeTemplateFreemarker5, backofficeMailId+"", lang_5, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_5_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}
				}

			}catch(JSONException je){
				je.printStackTrace();
			}catch(Exception ex){
				ex.printStackTrace();
			}

			

			callPagesUpdateFormAPI(formId, Etn.getId());

		} else if(isSaveMailConfigure.length() > 0 && isSaveMailConfigure.equals("save")) {

			langId = parseNull(request.getParameter("lang_id"));
			customerMailId = 0;
			backofficeMailId = 0;

			queryMailConfig = "INSERT INTO mails_unpublished(sujet, sujet_lang_2, sujet_lang_3, sujet_lang_4, sujet_lang_5, template_type) VALUES";

			customerMailId = Etn.executeCmd(queryMailConfig + "(" + escape.cote(customerEmailSubject1) + "," + escape.cote(customerEmailSubject2) + "," + escape.cote(customerEmailSubject3) + "," + escape.cote(customerEmailSubject4) + "," + escape.cote(customerEmailSubject5) + "," + escape.cote(customerOfficeTemplateType) + ")");

			backofficeMailId = Etn.executeCmd(queryMailConfig + "(" + escape.cote(backOfficeEmailSubject1) + "," + escape.cote(backOfficeEmailSubject2) + "," + escape.cote(backOfficeEmailSubject3) + "," + escape.cote(backOfficeEmailSubject4) + "," + escape.cote(backOfficeEmailSubject5) + "," + escape.cote(backOfficeTemplateType) + ")");

			try{

				if(customerMailId > 0){

					JSONObject templateJson = new JSONObject();
					JSONObject languageJson = new JSONObject();

					Etn.executeCmd("UPDATE process_forms_unpublished SET is_email_cust = " + escape.cote(isCustomerEmail) + ", is_email_bk_ofc = " + escape.cote(isBackOfficeEmail) + ", cust_eid = " + escape.cote(""+customerMailId) + ", bk_ofc_eid = " + escape.cote(""+backofficeMailId) +", updated_on = now(), updated_by = "+escape.cote(String.valueOf(Etn.getId()))+ " WHERE form_id = " + escape.cote(formId));

					if(customerTemplate1.length() > 0 || customerTemplateFreemarker1.length() > 0){

						if(lang_1.length() > 0) {
							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId, customerTemplate1, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker1, customerMailId+"", "", tableName, formFieldFreemarkerValues);

								languageJson.put(lang_1_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}


					if(customerTemplate2.length() > 0 || customerTemplateFreemarker2.length() > 0){

						if(lang_2.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId+"_"+lang_2, customerTemplate2, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker2, customerMailId+"", lang_2,
								tableName, formFieldFreemarkerValues);

								languageJson.put(lang_2_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}

					if(customerTemplate3.length() > 0 || customerTemplateFreemarker3.length() > 0){

						if(lang_3.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId+"_"+lang_3, customerTemplate3, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker3, customerMailId+"", lang_3, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_3_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}

					if(customerTemplate4.length() > 0 || customerTemplateFreemarker4.length() > 0){

						if(lang_4.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId+"_"+lang_4, customerTemplate4, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker4, customerMailId+"", lang_4, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_4_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}

					if(customerTemplate5.length() > 0 || customerTemplateFreemarker5.length() > 0){

						if(lang_5.length() > 0) {

							if(customerOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+customerMailId+"_"+lang_5, customerTemplate5, tableName);
							else if(customerOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, customerTemplateFreemarker5, customerMailId+"", lang_5, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_5_id, templateJson);
								responseJson.put("cusofc", languageJson);
							}
						}
					}
				}

				if(backofficeMailId > 0){

					JSONObject templateJson = new JSONObject();
					JSONObject languageJson = new JSONObject();

					Etn.executeCmd("INSERT INTO mail_config_unpublished(id, ordertype, email_to, attach, email_cc, email_ci) VALUES (" + escape.cote(""+backofficeMailId) + ", " + escape.cote(tableName) + ", " + escape.cote(backOfficeEmail) + "," + escape.cote("upload_mail") + "," + escape.cote(backOfficeEmailCc) + "," + escape.cote(backOfficeEmailCi) + ")");

					if(backOfficeTemplate1.length() > 0 || backOfficeTemplateFreemarker1.length() > 0){

						if(lang_1.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId, backOfficeTemplate1, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, backOfficeTemplateFreemarker1, backofficeMailId+"", "", tableName, formFieldFreemarkerValues);

								languageJson.put(lang_1_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}

					if(backOfficeTemplate2.length() > 0 || backOfficeTemplateFreemarker2.length() > 0){

						if(lang_2.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId+"_"+lang_2, backOfficeTemplate2, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, backOfficeTemplateFreemarker2, backofficeMailId+"", lang_2, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_2_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}

					if(backOfficeTemplate3.length() > 0 || backOfficeTemplateFreemarker3.length() > 0){

						if(lang_3.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId+"_"+lang_3, backOfficeTemplate3, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, backOfficeTemplateFreemarker3, backofficeMailId+"", lang_3, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_3_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}

					if(backOfficeTemplate4.length() > 0 || backOfficeTemplateFreemarker4.length() > 0){

						if(lang_4.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId+"_"+lang_4, backOfficeTemplate4, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, backOfficeTemplateFreemarker4, backofficeMailId+"",
								lang_4, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_4_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}

					if(backOfficeTemplate5.length() > 0 || backOfficeTemplateFreemarker5.length() > 0){

						if(lang_5.length() > 0) {

							if(backOfficeTemplateType.equalsIgnoreCase("text"))
								writeDataInFile(filePath+backofficeMailId+"_"+lang_5, backOfficeTemplate5, tableName);
							else if(backOfficeTemplateType.equalsIgnoreCase("freemarker")){

								templateJson = writeDataFreemarkerTemplate(filePath+customerMailId, backOfficeTemplateFreemarker5, backofficeMailId+"", lang_5, tableName, formFieldFreemarkerValues);

								languageJson.put(lang_5_id, templateJson);
								responseJson.put("bkofc", languageJson);
							}
						}
					}
				}

				

			} catch(JSONException je){
				je.printStackTrace();
			} catch(Exception ex){
				ex.printStackTrace();
			}
		} 
		if(customerSmsConfig.length() > 0 && customerSmsConfig.equals("1"))
		{
			int id = 0;
			if(customerTexte1.length()>0){
				id = Etn.executeCmd("INSERT INTO sms_unpublished(nom, where_clause, texte) VALUES("+escape.cote(parseNull(request.getParameter("nom")))+","+escape.cote(parseNull(request.getParameter("customer_sms_available_fields")))+","+escape.cote(customerTexte1)+")");		
				responseJson.put("texte",customerTexte1);
			}
			else if(customerTexte2.length()>0){
				id=Etn.executeCmd("INSERT INTO sms_unpublished(nom, where_clause, lang_2_texte) VALUES("+escape.cote(parseNull(request.getParameter("nom")))+","+escape.cote(parseNull(request.getParameter("customer_sms_available_fields")))+","+escape.cote(customerTexte2)+")");
				responseJson.put("lang_2_texte",customerTexte2);
			}
			else if(customerTexte3.length()>0){
				id=Etn.executeCmd("INSERT INTO sms_unpublished(nom, where_clause, lang_3_texte) VALUES("+escape.cote(parseNull(request.getParameter("nom")))+","+escape.cote(parseNull(request.getParameter("customer_sms_available_fields")))+","+escape.cote(customerTexte3)+")");
				responseJson.put("lang_3_texte",customerTexte3);
			}
			else if(customerTexte4.length()>0){
				id=Etn.executeCmd("INSERT INTO sms_unpublished(nom, where_clause, lang_4_texte) VALUES("+escape.cote(parseNull(request.getParameter("nom")))+","+escape.cote(parseNull(request.getParameter("customer_sms_available_fields")))+","+escape.cote(customerTexte4)+")");
				responseJson.put("lang_4_texte",customerTexte4);
			}
			else if(customerTexte5.length()>0){
				id=Etn.executeCmd("INSERT INTO sms_unpublished(nom, where_clause, lang_5_texte) VALUES("+escape.cote(parseNull(request.getParameter("nom")))+","+escape.cote(parseNull(request.getParameter("customer_sms_available_fields")))+","+escape.cote(customerTexte5)+")");
				responseJson.put("lang_5_texte",customerTexte5);
			}
			if(id>0)
				Etn.executeCmd("UPDATE process_forms_unpublished SET is_sms=1, cust_sms_id="+escape.cote(""+id)+" WHERE form_id="+escape.cote(""+formId));
			responseJson.put("nom",parseNull(request.getParameter("nom")));
			responseJson.put("customer_sms_config",customerSmsConfig);
		}

		updateVersionForm(Etn, formId);


		out.write(responseJson.toString());
	}
%>