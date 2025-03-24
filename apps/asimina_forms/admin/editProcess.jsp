<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%--<%@ page import="admin.ajax.Translations"%>--%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.io.PrintWriter, java.io.File"%>
<%@ page import="com.etn.util.Base64, com.etn.asimina.util.ActivityLog"%>
<%@ page import="com.etn.asimina.beans.Language" %>
<%@ include file="../common2.jsp"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%!

	void writeDataInFile(String path, String data, String formName){

		PrintWriter pw = null;

		try{

			String html = "Content-Type: multipart/alternative;\n boundary=\"------------010101080201020804090106\"\n\nThis is a multi-part message in MIME format.\n--------------010101080201020804090106\nContent-Type: text/html; charset=utf-8\nContent-Transfer-Encoding: 7bit\n\n\n";
			html += "<div id='" + formName + "_template_div'>\n"+data+"\n</div>";
			html += "\n--------------010101080201020804090106--";

			pw = new PrintWriter(new File(path.replaceAll("../", "")));
			pw.write(html);
			pw.flush();

		}catch(Exception e){

			e.printStackTrace();
		}finally{

			if(pw != null) pw.close();
		}
	}

	String makeOptions(String optionText[], String optionValue[]) throws JSONException, Exception{

		String optionVal = "";
		String optionTxt = "";

		JSONObject elementOptions = new JSONObject();
		JSONArray elementOptionText = new JSONArray();
		JSONArray elementOptionValue = new JSONArray();

		if(null != optionText && null != optionValue) {

			for(int i=0; i < optionText.length; i++) {

				if(optionText[i].length() > 0 && optionValue[i].length() > 0){

					optionTxt = optionText[i];
					optionTxt = optionTxt.replaceAll("\"", "&quot;");
					optionTxt = optionTxt.replaceAll("\n", " ");

					optionVal = optionValue[i];
					optionVal = optionVal.replaceAll("\"", "&quot;");
					optionVal = optionVal.replaceAll("\n", " ");

					elementOptionText.put(optionTxt);
					elementOptionValue.put(optionVal);
				}
			}

			if(optionText.length > 0){

				elementOptions.put("val", elementOptionText);
				elementOptions.put("txt", elementOptionValue);
			}
		}

		return elementOptions.toString();
	}
	    String decodeCKEditorValue(String str){
        if(str != null){
            return str.replace("_etnipt_=","src=").replace("_etnhrf_=","href=").replace("_etnstl_=","style=");
        }
        else{
            return str;
        }
    }

	void updateFormPage(com.etn.beans.Contexte Etn,String pagesDb, String formId){
		try{
			Etn.executeCmd("update "+pagesDb+".freemarker_pages set updated_ts=now() where id in (select parent_page_id from "+pagesDb+".pages where id in "+
				"(select page_id from "+pagesDb+".pages_forms where form_id="+escape.cote(formId)+" and type='freemarker') group by parent_page_id)");
			Etn.executeCmd("update "+pagesDb+".structured_contents set updated_ts=now() where id in (select parent_page_id from "+pagesDb+".pages where id in "+
				"(select page_id from "+pagesDb+".pages_forms where form_id="+escape.cote(formId)+" and type='structured') group by parent_page_id)");
		}catch(Exception e){
			e.printStackTrace();
		}
	}
%>
<%
	Set formFilterRs = Etn.execute("SELECT form_id FROM "+GlobalParm.getParm("CATALOG_DB")+".person_forms pf inner join profilperson pp on pp.person_id = pf.person_id inner join profil p on p.profil_id = pp.profil_id where p.assign_site='1' and pf.person_id="+escape.cote(""+Etn.getId()));
    List<String> formIds = new ArrayList<String>();

    while(formFilterRs.next())
    {
        formIds.add(parseNull(formFilterRs.value("form_id")));
    }

	String selectedSiteId = getSelectedSiteId(session);
	List<Language> langsList = getLangs(Etn,selectedSiteId);
    Language defaultLanguage = langsList.get(0);
	String formId = parseNull(request.getParameter("form_id"));
	String openTempModal = parseNull(request.getParameter("openTempModal"));
    String pid =  parseNull(String.valueOf(Etn.getId()));
	String langId = defaultLanguage.getLanguageId();
	String formName = "";
	String tableName = "";
	int customerMailId = 0;
	int backofficeMailId = 0;
	String PAGES_DB = parseNull(GlobalParm.getParm("PAGES_DB"));

	Set rs = Etn.execute("SELECT * FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId) + " and site_id = " + escape.cote(selectedSiteId));
	if(rs.rs.Rows == 0 || (formIds.size() >0  && !formIds.contains(formId)))
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
	}
	
	boolean isGame = false;
	Set rsG = Etn.execute("select * from games_unpublished where form_id = "+escape.cote(formId));
	if(rsG.rs.Rows > 0) isGame = true;

	String isSaveFormRule = parseNull(request.getParameter("isSaveFormRule"));

	if(isSaveFormRule.length() > 0 && isSaveFormRule.equals("1")){
		String fieldId[] = request.getParameterValues("field_id");
		String frequency[] = request.getParameterValues("frequency");
		String period[] = request.getParameterValues("period");
		langId = parseNull(request.getParameter("lang_id"));
		
        Etn.execute("Update process_forms_unpublished set updated_on = now(), updated_by = "+escape.cote(pid)+" where form_id = "+escape.cote(formId));
		Etn.execute("DELETE FROM freq_rules_unpublished WHERE form_id = " + escape.cote(formId));

		updateFormPage(Etn,PAGES_DB,formId);

        String insertQuery = "INSERT INTO freq_rules_unpublished (form_id, field_id, frequency, period) VALUES (";

        if(null != fieldId){

			for(int i=0; i < fieldId.length; i++){

				if(fieldId[i].length() > 0 && frequency[i].length() > 0 && period[i].length() > 0){

					Etn.executeCmd(insertQuery + escape.cote(formId) + "," + escape.cote(fieldId[i]) + "," + escape.cote(frequency[i]) + "," + escape.cote(period[i]) + ")");
				}
			}

			updateVersionForm(Etn, formId);
	    }

        Set rs_name =  Etn.execute("SELECT process_name FROM process_forms_unpublished WHERE form_id = "+escape.cote(formId));
        rs_name.next();
        ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"UPDATED","Form Rules",parseNull(rs_name.value(0)),selectedSiteId);
	}

	String isEditFormParameter = parseNull(request.getParameter(";"));

	if(isEditFormParameter.length() > 0 && isEditFormParameter.equals("1")){
		String htmlFormId = parseNull(request.getParameter("html_form_id"));
		String formClass = parseNull(request.getParameter("form_class"));
		String formMethod = parseNull(request.getParameter("form_method"));
		String formEnctype = parseNull(request.getParameter("form_enctype"));
		String formAutoComplete = parseNull(request.getParameter("form_autocomplete"));
		String formDisplayLabel = parseNull(request.getParameter("label_display"));
		
		langId = parseNull(request.getParameter("lang_id"));

		String formJs = parseNull(request.getParameter("form_js"));
		String formCss = parseNull(request.getParameter("form_css"));

		if(formJs.length() > 0){

			formJs = formJs.replaceAll("\"", "&quot;");
		}

		if(formCss.length() > 0){

			formCss = formCss.replaceAll("\"", "&quot;");
		}

		if(defaultLanguage.getLanguageId().equals(langId)){

			Etn.execute("UPDATE process_forms_unpublished SET html_form_id = " + escape.cote(htmlFormId) + ", form_class = " + escape.cote(formClass) + ", form_method = " + escape.cote(formMethod) + ", form_enctype = " + escape.cote(formEnctype) + ", form_autocomplete = " + escape.cote(formAutoComplete) + ", label_display = " + escape.cote(formDisplayLabel) + ", form_js = " + escapeCote2(formJs) + ", form_css = " + escapeCote2(formCss) +", updated_on = now(), updated_by = "+escape.cote(pid)+  " WHERE form_id = " + escape.cote(formId));

			updateVersionForm(Etn, formId);
			callPagesUpdateFormAPI(formId, Etn.getId());

            Set rs_name =  Etn.execute("SELECT process_name FROM process_forms_unpublished WHERE form_id = "+escape.cote(formId));
            rs_name.next();
            ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"UPDATED","Form Parameter",parseNull(rs_name.value(0)),selectedSiteId);

			updateFormPage(Etn,PAGES_DB,formId);
		}
	}

	String isEditLineParameter = parseNull(request.getParameter("isEditLineParameter"));

	if(isEditLineParameter.length() > 0 && isEditLineParameter.equals("1")){

		String lineUuid = parseNull(request.getParameter("line_uuid"));
		String lineId = parseNull(request.getParameter("line_id"));
		String lineClass = parseNull(request.getParameter("line_class"));
		String lineWidth = parseNull(request.getParameter("line_width"));
		String lineSeq = parseNull(request.getParameter("line_seq"));

		if(lineUuid.length() > 0){

			Etn.executeCmd("UPDATE process_form_lines_unpublished SET line_id = " + escape.cote(lineId) + ", line_class = " + escape.cote(lineClass) + ", line_width = " + escape.cote(lineWidth) + ", line_seq = " + escape.cote(lineSeq) + " WHERE form_id = " + escape.cote(formId) + " and id = " + escape.cote(lineUuid));

			callPagesUpdateFormAPI(formId, Etn.getId());
			updateVersionForm(Etn, formId);
            Etn.execute("Update process_forms_unpublished set updated_on = now(), updated_by = "+escape.cote(pid)+" where form_id = "+escape.cote(formId));

            Set rs_name =  Etn.execute("SELECT process_name FROM process_forms_unpublished WHERE form_id = "+escape.cote(formId));
            rs_name.next();
            ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"UPDATED","Form Line Parameter",parseNull(rs_name.value(0)),selectedSiteId);

			updateFormPage(Etn,PAGES_DB,formId);
		}
	}


	String isAddFormField = parseNull(request.getParameter("add_form_fields"));

	if(isAddFormField.length() > 0 && isAddFormField.equals("1")){

        String query = "INSERT INTO process_form_fields_unpublished( form_id, line_id, field_id, field_type, db_column_name, font_weight, font_size, color, name, maxlength, required, rule_field, add_no_of_days, start_time, end_time, time_slice, default_time_value, autocomplete_char_after, element_autocomplete_query, regx_exp, group_of_fields, element_trigger, element_id, type, element_option_class, element_option_others, element_option_query, resizable_col_class, always_visible, file_extension, img_width, img_height, img_alt, img_murl, href_chckbx, href_target, img_href_url, btn_id, container_bkcolor, text_align, text_border, site_key, theme, recaptcha_data_size, custom_css, min_range, max_range, step_range, img_url, default_country_code, allow_country_code, allow_national_mode, local_country_name, hidden, custom_classes, date_format, file_browser_val, auto_format_tel_number ) VALUES ";

        String columnQuery = "";
        String fieldId = parseNull(request.getParameter("fieldid"));
        String lineId = parseNull(request.getParameter("lineid"));
        String fieldType = parseNull(request.getParameter("field_type"));
		String dbColumnName = parseNull(request.getParameter("db_column_name"));
		String fontWeight = parseNull(request.getParameter("font_weight"));
		String fontSize = parseNull(request.getParameter("font_size"));
		String color = parseNull(request.getParameter("color"));
        langId = parseNull(request.getParameter("langid"));

		String name = parseNull(request.getParameter("name"));

		if(name.length() == 0) name = dbColumnName;
		if(dbColumnName.length() > 0) dbColumnName = "_etn_" + dbColumnName;
		
		dbColumnName = dbColumnName.replaceAll(" ", "_").replaceAll("[^a-zA-Z0-9_]", "");
		dbColumnName = com.etn.asimina.util.UrlHelper.removeAccents(dbColumnName);		

		String type = parseNull(request.getParameter("type"));
		String alwaysVisible = parseNull(request.getParameter("always_visible"));

		if(type.equalsIgnoreCase("label") || type.equalsIgnoreCase("button"))
			alwaysVisible = "1";

		String maxLength = parseNull(request.getParameter("maxlength"));
		String byDefaultField = parseNull(request.getParameter("by_default_field"));
		String[] allowFileExtension = request.getParameterValues("file_extension");
		String required = parseNull(request.getParameter("required"));
		String ruleField = parseNull(request.getParameter("rule_field"));
		String hyperlinkCheckbox = parseNull(request.getParameter("href_chckbx"));
		String addNoOfDays = parseNull(request.getParameter("add_no_of_days"));
		String startTime = parseNull(request.getParameter("start_time"));
		String endTime = parseNull(request.getParameter("end_time"));
		String timeSlice = parseNull(request.getParameter("time_slice"));
		String defaultTimeValue = parseNull(request.getParameter("default_time_value"));
		String autocompleteCharAfter = parseNull(request.getParameter("autocomplete_char_after"));
		String autocompleteQuery = parseNull(request.getParameter("element_autocomplete_query"));
		String regularExpression = parseNull(request.getParameter("regular_expression"));
		String groupOfFields = parseNull(request.getParameter("group_of_fields"));
		String trigger[] = request.getParameterValues("element_trigger");
		String triggerValue[] = request.getParameterValues("element_trigger_value");
		String triggerJs[] = request.getParameterValues("element_trigger_js");
		String id = parseNull(request.getParameter("id"));

		String optionClass = parseNull(request.getParameter("element_option_class"));
		String optionOthers = parseNull(request.getParameter("element_option_others"));
		String optionQuery = parseNull(request.getParameter("element_option_query"));
		String resizableColClass = parseNull(request.getParameter("resizable_col_class"));
		String imageWidth = parseNull(request.getParameter("img_width"));
		String imageHeight = parseNull(request.getParameter("img_height"));
		String imageAlt = parseNull(request.getParameter("img_alt"));
		String imageMobileUrl = parseNull(request.getParameter("img_murl"));
		String hyperlinkTarget = parseNull(request.getParameter("href_target"));
		String imgHrefUrl = parseNull(request.getParameter("img_href_url"));
		String buttonId = parseNull(request.getParameter("btn_id"));
		String containerBkColor = parseNull(request.getParameter("container_bkcolor"));
		String textAlign = parseNull(request.getParameter("text_align"));
		String textBorder = parseNull(request.getParameter("text_border"));
		String siteKey = parseNull(request.getParameter("site_key"));
		String theme = parseNull(request.getParameter("theme"));
		String recaptchaDataSize = parseNull(request.getParameter("recaptcha_data_size"));
		String customCss = parseNull(request.getParameter("custom_css"));
		String useToSearch = parseNull(request.getParameter("use_to_search"));
		String formReplies = parseNull(request.getParameter("form_replies"));
		int minRange = parseNullInt(request.getParameter("min_range"));
		int maxRange = parseNullInt(request.getParameter("max_range"));
		int stepRange = parseNullInt(request.getParameter("step_range"));
		String imgUrl = parseNull(request.getParameter("img_url"));
		String defaultCountryCode = parseNull(request.getParameter("default_country_code"));
		String allowCountryCode = parseNull(request.getParameter("allow_country_code"));
		String allowNationalMode = parseNull(request.getParameter("allow_national_mode"));
		String localCountryName = parseNull(request.getParameter("local_country_name"));
		String auto_format_tel_number = parseNull(request.getParameter("auto_format_tel_number"));
		if(auto_format_tel_number.length() == 0) auto_format_tel_number = "0";
		String hiddenField = parseNull(request.getParameter("hidden_field"));
		String customClasses = parseNull(request.getParameter("custom_classes"));
		String dateFormat = parseNull(request.getParameter("date_format"));
		String fileBrowserValue = parseNull(request.getParameter("file_browser_val"));


		JSONObject elementTriggerObject = new JSONObject();
		JSONArray elementTriggerValueArray = new JSONArray();
		JSONArray elementTriggerJSArray = new JSONArray();
		JSONArray elementTriggerEventArray = new JSONArray();
		String triggerVal = "";
		String fileExtension = "";

		if(null != allowFileExtension){

			for(int i=0; i<allowFileExtension.length; i++){

				fileExtension += allowFileExtension[i];
				if(i!=allowFileExtension.length-1)
					fileExtension += ", ";
			}
		}

		if(null != trigger && null != triggerValue && null != triggerJs){

			for(int i=0; i < trigger.length; i++){

				elementTriggerEventArray.put(trigger[i]);

				triggerVal = triggerValue[i];
				triggerVal = triggerVal.replaceAll("\"", "&quot;");
				triggerVal = triggerVal.replace("\n", " ").replace("\r","");

				elementTriggerValueArray.put(triggerVal);

				triggerVal = triggerJs[i];
				triggerVal = triggerVal.replaceAll("\"", "&quot;");
				triggerVal = triggerVal.replace("\n", "##ENTER##").replace("\r","##ENTERr##");

				elementTriggerJSArray.put(triggerVal);
			}

			if(trigger.length > 0){

				elementTriggerObject.put("event",elementTriggerEventArray);
				elementTriggerObject.put("query",elementTriggerValueArray);
				elementTriggerObject.put("js",elementTriggerJSArray);
			}
		}

		if(fieldId.length() > 0){

			if(defaultLanguage.getLanguageId().equals(langId)){

				query = "UPDATE process_form_fields_unpublished SET auto_format_tel_number = " + escape.cote(auto_format_tel_number) + ", field_type = " + escape.cote(fieldType) + ", font_weight = " + escape.cote(fontWeight) + ", font_size = " + escape.cote(fontSize) + ", color = " + escape.cote(color) + ", maxlength = " + escape.cote(maxLength) + ", required = " + escape.cote(required) + ", rule_field = " + escape.cote(ruleField) + ", add_no_of_days = " + escape.cote(addNoOfDays) + ", start_time = " + escape.cote(startTime) + ", end_time = " + escape.cote(endTime) + ", time_slice = " + escape.cote(timeSlice) + ", default_time_value = " + escape.cote(defaultTimeValue) + ", autocomplete_char_after = " + escape.cote(autocompleteCharAfter) + ", element_autocomplete_query = " + escape.cote(autocompleteQuery) + ", regx_exp = " + escape.cote(regularExpression) + ", group_of_fields = " + escape.cote(groupOfFields) + ", element_trigger = " + elementTriggerCote(elementTriggerObject.toString()) + ", element_id = " + escape.cote(id) + ", type = " + escape.cote(type) + ", element_option_class = " + escape.cote(optionClass) + ", element_option_others = " + escape.cote(optionOthers) + ", element_option_query = " + escape.cote(optionQuery) + ", resizable_col_class = " + escape.cote(resizableColClass) + ", always_visible = " + escape.cote(alwaysVisible) + ", file_extension = " + escape.cote(fileExtension) + ", img_width = " + escape.cote(imageWidth) + ", img_height = " + escape.cote(imageHeight) + ", img_alt = " + escape.cote(imageAlt) + ", img_murl = " + escape.cote(imageMobileUrl) + ", href_chckbx = " + escape.cote(hyperlinkCheckbox) + ", href_target = " + escape.cote(hyperlinkTarget) + ", img_href_url = " + escape.cote(imgHrefUrl) + ", btn_id = " + escape.cote(buttonId) + ", container_bkcolor = " + escape.cote(containerBkColor) + ", text_align = " + escape.cote(textAlign) + ", text_border = " + escape.cote(textBorder) + ", site_key = " + escape.cote(siteKey) + ", theme = " + escape.cote(theme) + ", recaptcha_data_size = " + escape.cote(recaptchaDataSize) + ", custom_css = " +  escape.cote(customCss) + ", min_range = " + minRange + ", max_range = " + maxRange + ", step_range = " + stepRange + ", img_url = " + escape.cote(imgUrl) + ", default_country_code = " + escape.cote(defaultCountryCode) + ", allow_country_code = " + escape.cote(allowCountryCode) + ", allow_national_mode = " + escape.cote(allowNationalMode) + ", local_country_name = " + escape.cote(localCountryName) + ", hidden = " + escape.cote(hiddenField) + ", custom_classes = " + escape.cote(customClasses) + ", date_format = " + escape.cote(dateFormat) + ", file_browser_val = " + escape.cote(fileBrowserValue) + " WHERE form_id = " + escape.cote(formId) + " AND line_id = " + escape.cote(lineId) + " AND field_id = " +  escape.cote(fieldId);

				Etn.execute(query);
			}

			String label = parseNull(request.getParameter("label_" + langId));
			String placeholder = parseNull(request.getParameter("placeholder_" + langId));
			String errMsg = parseNull(request.getParameter("err_msg_" + langId));
			String value = parseNull(request.getParameter("value_" + langId));
			String elementOptions = "";
			String optionsQuery = parseNull(request.getParameter("option_query_value_" + langId));

			try{

				elementOptions = makeOptions(request.getParameterValues("option_text_" + langId), request.getParameterValues("option_value_" + langId));

			} catch(JSONException jex){

				jex.printStackTrace();
			} catch(Exception e){

				e.printStackTrace();
			}

			Etn.execute("UPDATE process_form_field_descriptions_unpublished SET label = " + decodeCKEditorValue(escape.cote(label)) + ", placeholder = " + escape.cote(placeholder) + ", err_msg = " + escape.cote(errMsg) + ", value = " + decodeCKEditorValue(escape.cote(value)) + ", options = " + elementTriggerCote(elementOptions) + ", option_query = " + escape.cote(optionsQuery) + " WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId) + " AND langue_id = " + escape.cote(langId));

			callPagesUpdateFormAPI(formId, Etn.getId());
            Etn.execute("Update process_forms_unpublished set updated_on = now(), updated_by = "+escape.cote(pid)+" where form_id = "+escape.cote(formId));

            Set rs_name =  Etn.execute("SELECT process_name FROM process_forms_unpublished WHERE form_id = "+escape.cote(formId));
            rs_name.next();
            ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"UPDATED","Form Fields",parseNull(rs_name.value(0)),selectedSiteId);

		} else {

			if(fieldId.length() == 0) fieldId = UUID.randomUUID().toString();

			query += "(" + escape.cote(formId) + "," + escape.cote(lineId) + "," + escape.cote(fieldId) + "," + escape.cote(fieldType) + "," + escape.cote(dbColumnName) + "," + escape.cote(fontWeight) + "," + escape.cote(fontSize) + "," + escape.cote(color) + "," + escape.cote(name) + "," + escape.cote(maxLength) + "," + escape.cote(required) + "," + escape.cote(ruleField) + "," + escape.cote(addNoOfDays) + "," + escape.cote(startTime) + "," + escape.cote(endTime) + "," + escape.cote(timeSlice) + "," + escape.cote(defaultTimeValue) + "," + escape.cote(autocompleteCharAfter) + "," + elementTriggerCote(autocompleteQuery) + "," + escape.cote(regularExpression) + "," + escape.cote(groupOfFields) + "," + elementTriggerCote(elementTriggerObject.toString()) + "," + escape.cote(id) + "," + escape.cote(type) + "," + escape.cote(optionClass) + "," + escape.cote(optionOthers) + "," + escape.cote(optionQuery) + "," + escape.cote(resizableColClass) + "," + escape.cote(alwaysVisible) + "," + escape.cote(fileExtension) + "," + escape.cote(imageWidth) + "," + escape.cote(imageHeight) + "," + escape.cote(imageAlt) + "," + escape.cote(imageMobileUrl) + "," + escape.cote(hyperlinkCheckbox) + "," + escape.cote(hyperlinkTarget) + "," + escape.cote(imgHrefUrl) + "," + escape.cote(buttonId) + "," + escape.cote(containerBkColor) + "," + escape.cote(textAlign) + "," + escape.cote(textBorder) + "," + escape.cote(siteKey) + "," + escape.cote(theme) + "," + escape.cote(recaptchaDataSize) + "," + escape.cote(customCss) + "," + minRange + "," + maxRange + "," + stepRange + "," + escape.cote(imgUrl) + "," + escape.cote(defaultCountryCode) + "," + escape.cote(allowCountryCode) + "," + escape.cote(allowNationalMode) + "," + escape.cote(localCountryName) + "," + escape.cote(hiddenField) + "," + escape.cote(customClasses) + "," + escape.cote(dateFormat) + "," + escape.cote(fileBrowserValue) + "," + escape.cote(auto_format_tel_number) +")";

			int rid = Etn.executeCmd(query);

			if(rid > 0){

				String label = "";
				String placeholder = "";
				String errMsg = "";
				String value = "";
				String elementOptions = "";
				String optionsQuery = "";

				for(Language lang : langsList) {
					label = parseNull(request.getParameter("label_" + lang.getLanguageId()));
					placeholder = parseNull(request.getParameter("placeholder_" + lang.getLanguageId()));
					errMsg = parseNull(request.getParameter("err_msg_" + lang.getLanguageId()));
					value = parseNull(request.getParameter("value_" + lang.getLanguageId()));
					optionsQuery = parseNull(request.getParameter("option_query_value_" + lang.getLanguageId()));

					try{

						elementOptions = makeOptions(request.getParameterValues("option_text_" + lang.getLanguageId()), request.getParameterValues("option_value_" + lang.getLanguageId()));

					} catch(JSONException jex){

						jex.printStackTrace();
					} catch(Exception e){

						e.printStackTrace();
					}

					if(label.length() == 0)
						label = parseNull(request.getParameter("label_" + defaultLanguage.getLanguageId()));

					if(placeholder.length() == 0)
						placeholder = parseNull(request.getParameter("placeholder_" + defaultLanguage.getLanguageId()));

					if(errMsg.length() == 0)
						errMsg = parseNull(request.getParameter("err_msg_" + defaultLanguage.getLanguageId()));

					if(value.length() == 0)
						value = parseNull(request.getParameter("value_" + defaultLanguage.getLanguageId()));

					if(elementOptions.length() == 19){

						try{

							elementOptions = makeOptions(request.getParameterValues("option_text_" + defaultLanguage.getLanguageId()), request.getParameterValues("option_value_" + defaultLanguage.getLanguageId()));

						} catch(JSONException jex){

							jex.printStackTrace();
						} catch(Exception e){

							e.printStackTrace();
						}

					}

					if(optionsQuery.length() == 0)
						optionsQuery = parseNull(request.getParameter("option_query_value_" + defaultLanguage.getLanguageId()));

					Etn.executeCmd("insert into process_form_field_descriptions_unpublished (form_id, field_id, langue_id, label, placeholder, err_msg, value, options, option_query) values (" + escape.cote(formId) + ", " + escape.cote(fieldId) + ", " + escape.cote(lang.getLanguageId()) + ", " + decodeCKEditorValue(escape.cote(label)) + ", " + escape.cote(placeholder) + ", " + escape.cote(errMsg) + ", " + decodeCKEditorValue(escape.cote(value)) + ", " + elementTriggerCote(elementOptions) + ", " + elementTriggerCote(optionsQuery) + ")");
				}

/*
				if(type.equals("textdate"))
					columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN " + dbColumnName + " date DEFAULT NULL;";
				else if(type.equals("textdatetime"))
					columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN " + dbColumnName + " datetime DEFAULT NULL;";
				else if(type.equals("email"))
					columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN " + dbColumnName + " VARCHAR(255) DEFAULT NULL;";
				else if(!(type.equals("hr_line") || type.equals("label") || type.equals("button")))
					columnQuery = "ALTER TABLE " + tableName + " ADD COLUMN " + dbColumnName + " TEXT DEFAULT NULL;";

				if(columnQuery.length() > 0)
					Etn.execute(columnQuery);
*/
                Etn.execute("Update process_forms_unpublished set updated_on = now(), updated_by = "+escape.cote(pid)+" where form_id = "+escape.cote(formId));
			}
            Set rs_name =  Etn.execute("SELECT process_name FROM process_forms_unpublished WHERE form_id = "+escape.cote(formId));
            rs_name.next();
            ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"UPDATED","Form Fields",parseNull(rs_name.value(0)),selectedSiteId);
		}

		if(useToSearch.length() > 0){

			if(useToSearch.equals("1")){

				Set searchFilterRs = Etn.execute("SELECT id FROM form_search_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));

				if(searchFilterRs.rs.Rows == 0) {

					searchFilterRs = Etn.execute("SELECT coalesce(display_order,0) as display_order FROM form_search_fields_unpublished WHERE form_id = " + escape.cote(formId) + " ORDER BY coalesce(display_order,0) DESC LIMIT 1");

					int maxSearchOrder = 0;
					if(searchFilterRs.next()) maxSearchOrder = Integer.parseInt(searchFilterRs.value("display_order"));

					Etn.executeCmd("INSERT INTO form_search_fields_unpublished(form_id, field_id, display_order) VALUES (" + escape.cote(formId) + "," + escape.cote(fieldId) + "," + escape.cote("" + (++maxSearchOrder)) + ") ");
				}

			} else if(useToSearch.equals("0")){

				Etn.executeCmd("DELETE FROM form_search_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));
			}
		}

		if(formReplies.length() > 0){

			if(formReplies.equals("1")){

				Set resultFilterRs = Etn.execute("SELECT id FROM form_result_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));

				if(resultFilterRs.rs.Rows == 0){

					resultFilterRs = Etn.execute("SELECT coalesce(display_order,0) as display_order FROM form_result_fields_unpublished WHERE form_id = " + escape.cote(formId) + " ORDER BY coalesce(display_order,0) DESC LIMIT 1");

					int maxResultOrder = 0;
					if(resultFilterRs.next()) maxResultOrder = Integer.parseInt(resultFilterRs.value("display_order"));

					Etn.executeCmd("INSERT INTO form_result_fields_unpublished(form_id, field_id, display_order) VALUES (" + escape.cote(formId) + "," + escape.cote(fieldId) + "," + escape.cote("" + (++maxResultOrder)) + ") ");
				}

			} else if(formReplies.equals("0")){

				Etn.executeCmd("DELETE FROM form_result_fields_unpublished WHERE form_id = " + escape.cote(formId) + " AND field_id = " + escape.cote(fieldId));
			}
		}

		updateFormPage(Etn,PAGES_DB,formId);
		updateVersionForm(Etn, formId);
	}


	String isConfigureMail = parseNull(request.getParameter("isConfigureMail"));

	if(isConfigureMail.length() > 0 && isConfigureMail.equals("1")){

		String queryMailConfig = "";

		String isSaveMailConfigure = parseNull(request.getParameter("isSaveMailConfigure"));
		String isUpdateMailConfigure = parseNull(request.getParameter("isUpdateMailConfigure"));
		String filePath = com.etn.beans.app.GlobalParm.getParm("MAIL_UPLOAD_PATH") + "mail";

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

		HashMap<String,String> customerEmailParam = new HashMap<String,String>();
		HashMap<String,String> backOfficeEmailParam = new HashMap<String,String>();

		for(Language lang:langsList){
			customerEmailParam.put("lang_"+lang.getLanguageId()+"_subj",parseNull(request.getParameter("lang_"+lang.getLanguageId()+"_subj")));
			customerEmailParam.put("lang_"+lang.getLanguageId()+"_template",parseNull(request.getParameter("lang_"+lang.getLanguageId()+"_template")));
			customerEmailParam.put("lang_"+lang.getLanguageId()+"_template_fm",parseNull(request.getParameter("lang_"+lang.getLanguageId()+"_template_fm")));

			backOfficeEmailParam.put("lang_"+lang.getLanguageId()+"_back_office_subj",parseNull(request.getParameter("lang_"+lang.getLanguageId()+"_back_office_subj")));
			backOfficeEmailParam.put("lang_"+lang.getLanguageId()+"_back_office_template",parseNull(request.getParameter("lang_"+lang.getLanguageId()+"_back_office_template")));
			backOfficeEmailParam.put("lang_"+lang.getLanguageId()+"_back_office_template_fm",parseNull(request.getParameter("lang_"+lang.getLanguageId()+"_back_office_template_fm")));
		}
		customerEmailParam.put("cust_ofc_tt",parseNull(request.getParameter("cust_ofc_tt")));
		backOfficeEmailParam.put("bk_ofc_tt",parseNull(request.getParameter("bk_ofc_tt")));

		String lang_tab = parseNull(request.getParameter("lang_tab"));

		if(lang_tab.length() == 0){

			lang_tab = "lang"+langsList.get(0).getLanguageId()+"show";
		}

		String formType = "";
		Set formRs = Etn.execute("SELECT * from process_forms_unpublished WHERE form_id = " + escape.cote(formId));
		if(formRs.next()){

			formType = parseNull(formRs.value("type"));
		}

		if(isUpdateMailConfigure.length() > 0 && isUpdateMailConfigure.equals("update")){

			queryMailConfig = "UPDATE mails_unpublished SET ";
			for(Language lang:langsList){
				queryMailConfig += "sujet_lang_"+lang.getLanguageId()+" = " + escape.cote(customerEmailParam.get("lang_"+lang.getLanguageId()+"_subj")) + ", ";
			}	 
			queryMailConfig += "template_type = " + escape.cote(customerEmailParam.get("cust_ofc_tt")) + " WHERE id = " + escape.cote(""+customerMailId);

			Etn.executeCmd(queryMailConfig);

			queryMailConfig = "UPDATE mails_unpublished SET ";
			for(Language lang:langsList){
				queryMailConfig +="sujet_lang_"+lang.getLanguageId()+" = " + escape.cote(backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_subj")) + ", ";
			}
			queryMailConfig +="template_type = " + escape.cote(backOfficeEmailParam.get("bk_ofc_tt")) + " WHERE id = " + escape.cote(""+backofficeMailId);

			Etn.executeCmd(queryMailConfig);

			queryMailConfig = "UPDATE mail_config_unpublished SET email_to = " + escape.cote(backOfficeEmail) + ", email_cc = " + escape.cote(backOfficeEmailCc) + ", email_ci = " + escape.cote(backOfficeEmailCi) + " WHERE id = " + escape.cote(""+backofficeMailId);

			Etn.executeCmd(queryMailConfig);

			queryMailConfig = "UPDATE process_forms_unpublished SET is_email_cust = " + escape.cote(isCustomerEmail) + ", is_email_bk_ofc = " + escape.cote(isBackOfficeEmail) + " WHERE form_id = " + escape.cote(formId);

			Etn.executeCmd(queryMailConfig);

			String actionConfig = "";

			if(isCustomerEmail.equals("1") && formType.equalsIgnoreCase("simple")) actionConfig = "mail:" + customerMailId;

			if(isBackOfficeEmail.equals("1")) {

				if(actionConfig.length() > 0)
					actionConfig += ",mail:" + backofficeMailId;
				else
					actionConfig = "mail:" + backofficeMailId;
			}

			if(actionConfig.length() > 0) actionConfig += ",sql:processNow";


			if(formType.equalsIgnoreCase("sign_up")){

				Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("EmailSentForm"));

				Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("EmailSentForm") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote("Done"));

			} else {

				String startPhase = "";
				String nextPhase = "";

				if(formType.equals("forgot_password")){

					startPhase = "CustomerEmail";
					nextPhase = "Done";
				} else {

					startPhase = "FormSubmitted";
					nextPhase = "EmailSent";
				}

				Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase));

				Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase) + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote(nextPhase));
			}


			if(customerMailId > 0) {
				for(Language lang:langsList){
					String suffix = "_"+lang.getCode();
					if(customerEmailParam.get("lang_"+lang.getLanguageId()+"_template").length()>0 || customerEmailParam.get("lang_"+lang.getLanguageId()+"_template_fm").length() > 0){
						if(lang.getLanguageId().equals("1"))
							suffix="";
						
						if(customerEmailParam.get("cust_ofc_tt").equalsIgnoreCase("text"))
							writeDataInFile(filePath+customerMailId+suffix, customerEmailParam.get("lang_"+lang.getLanguageId()+"_template"), formName);
						else if(customerEmailParam.get("cust_ofc_tt").equalsIgnoreCase("freemarker"))
							writeDataInFile(filePath+customerMailId+suffix+".ftl", customerEmailParam.get("lang_"+lang.getLanguageId()+"_template_fm"), formName);
					}
				}
			}

			if(backofficeMailId > 0){
				for(Language lang:langsList){
					String suffix = "_"+lang.getCode();
					if(backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_template").length()>0 || backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_template_fm").length() > 0){
						if(lang.getLanguageId().equals("1"))
							suffix="";
						
						if(backOfficeEmailParam.get("bk_ofc_tt").equalsIgnoreCase("text"))
							writeDataInFile(filePath+backofficeMailId+suffix, backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_template"), formName);
						else if(backOfficeEmailParam.get("bk_ofc_tt").equalsIgnoreCase("freemarker"))
							writeDataInFile(filePath+backofficeMailId+suffix+".ftl", backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_template_fm"), formName);
					}
				}
			}

			callPagesUpdateFormAPI(formId, Etn.getId());

		} else if(isSaveMailConfigure.length() > 0 && isSaveMailConfigure.equals("save")) {

			langId = parseNull(request.getParameter("lang_id"));
			customerMailId = 0;
			backofficeMailId = 0;

			queryMailConfig = "INSERT INTO mails_unpublished(";
			for(Language lang:langsList){
				queryMailConfig+="sujet_lang_"+lang.getLanguageId()+",";
			}
			queryMailConfig = queryMailConfig.substring(0, queryMailConfig.length() - 1); 
			queryMailConfig+=") VALUES (";
			String argsValues ="";
			for(Language lang:langsList){
				argsValues+=escape.cote(customerEmailParam.get("lang_"+lang.getLanguageId()+"_subj"))+",";
			}
			argsValues = argsValues.substring(0, argsValues.length() - 1); 
			System.out.println("final query for mail config customer = "+queryMailConfig+argsValues+")");

			customerMailId = Etn.executeCmd(queryMailConfig+argsValues+")");

			argsValues ="";
			for(Language lang:langsList){
				argsValues+=escape.cote(backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_subj"))+",";
			}
			argsValues = argsValues.substring(0, argsValues.length() - 1); 

			System.out.println("final query for mail config backOffice = "+queryMailConfig+argsValues+")");
			backofficeMailId = Etn.executeCmd(queryMailConfig + argsValues+ ")");

			if(customerMailId > 0){

				Etn.executeCmd("UPDATE process_forms_unpublished SET is_email_cust = " + escape.cote(isCustomerEmail) + ", is_email_bk_ofc = " + escape.cote(isBackOfficeEmail) + ", cust_eid = " + escape.cote(""+customerMailId) + ", bk_ofc_eid = " + escape.cote(""+backofficeMailId) +", updated_on = now(), updated_by = "+escape.cote(pid)+ " WHERE form_id = " + escape.cote(formId));

				for(Language lang:langsList){
					String suffix = "_"+lang.getCode();
					if(customerEmailParam.get("lang_"+lang.getLanguageId()+"_template").length()>0 || customerEmailParam.get("lang_"+lang.getLanguageId()+"_template_fm").length() > 0){
						if(lang.getLanguageId().equals("1"))
							suffix="";
						
						if(customerEmailParam.get("cust_ofc_tt").equalsIgnoreCase("text"))
							writeDataInFile(filePath+customerMailId+suffix, customerEmailParam.get("lang_"+lang.getLanguageId()+"_template"), formName);
						else if(customerEmailParam.get("cust_ofc_tt").equalsIgnoreCase("freemarker"))
							writeDataInFile(filePath+customerMailId+suffix+".ftl", customerEmailParam.get("lang_"+lang.getLanguageId()+"_template_fm"), formName);
					}
				}
			}

			if(backofficeMailId > 0){

				Etn.executeCmd("INSERT INTO mail_config_unpublished(id, ordertype, email_to, attach, email_cc, email_ci) VALUES (" + escape.cote(""+backofficeMailId) + ", " + escape.cote(tableName) + ", " + escape.cote(backOfficeEmail) + "," + escape.cote("upload_mail") + "," + escape.cote(backOfficeEmailCc) + "," + escape.cote(backOfficeEmailCi) + ")");

				for(Language lang:langsList){
					String suffix = "_"+lang.getCode();
					if(backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_template").length()>0 || backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_template_fm").length() > 0){
						if(lang.getLanguageId().equals("1"))
							suffix="";
						
						if(backOfficeEmailParam.get("bk_ofc_tt").equalsIgnoreCase("text"))
							writeDataInFile(filePath+backofficeMailId+suffix, backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_template"), formName);
						else if(backOfficeEmailParam.get("bk_ofc_tt").equalsIgnoreCase("freemarker"))
							writeDataInFile(filePath+backofficeMailId+suffix+".ftl", backOfficeEmailParam.get("lang_"+lang.getLanguageId()+"_back_office_template_fm"), formName);
					}
				}
			}

			Set rulesRs = Etn.execute("SELECT cle FROM rules WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("FormSubmitted") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote("EmailSent"));

			String cleId = "";

			if(rulesRs.next()) cleId = parseNull(rulesRs.value("cle"));

			String actionConfig = "";

			if(isCustomerEmail.equals("1") && formType.equalsIgnoreCase("simple")) actionConfig = "mail:" + customerMailId;

			if(isBackOfficeEmail.equals("1")) {

				if(actionConfig.length() > 0)
					actionConfig += ",mail:" + backofficeMailId;
				else
					actionConfig = "mail:" + backofficeMailId;
			}

			if(actionConfig.length() > 0) actionConfig += ",sql:processNow";

			String startPhase = "";
			String nextPhase = "";

 			if (formType.equalsIgnoreCase("forgot_password")){

 				startPhase = "CustomerEmail";
 				nextPhase = "Done";
			} else {

 				startPhase = "FormSubmitted";
 				nextPhase = "EmailSent";
			}

			Etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES(" + escape.cote(tableName) + "," + escape.cote(startPhase) + "," + escape.cote(cleId) + "," + escape.cote(actionConfig) + ")");

			Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote(startPhase) + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote(nextPhase));
		}

		updateVersionForm(Etn, formId);

        Set rs_name =  Etn.execute("SELECT process_name FROM process_forms_unpublished WHERE form_id = "+escape.cote(formId));
        rs_name.next();
        ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"UPDATED","Form Temlate Email",parseNull(rs_name.value(0)),selectedSiteId);

		updateFormPage(Etn,PAGES_DB,formId);
	}

	String isEdit = parseNull(request.getParameter("is_edit"));

 	if (isEdit.length() > 0 && isEdit.equals("1") && formId.length() > 0) {

		String variant = parseNull(request.getParameter("variant"));
		String template = parseNull(request.getParameter("template"));
		String metaDescription = parseNull(request.getParameter("meta_description"));
		String metaKeywords = parseNull(request.getParameter("meta_keywords"));
		String redirectUrl = parseNull(request.getParameter("redirect_url"));
		String formButtonAlign = parseNull(request.getParameter("btn_align"));
		String htmlFormId = parseNull(request.getParameter("html_form_id"));
		String formClass = parseNull(request.getParameter("form_class"));
		String formMethod = parseNull(request.getParameter("form_method"));
		String formEnctype = parseNull(request.getParameter("form_enctype"));
		String formAutoComplete = parseNull(request.getParameter("form_autocomplete"));
		String formDisplayLabel = parseNull(request.getParameter("label_display"));
		String formWidth = parseNull(request.getParameter("form_width"));
		String deleteUploads = parseNull(request.getParameter("delete-uploads"));

		langId = parseNull(request.getParameter("lang_id"));

		String formJs = parseNull(request.getParameter("form_js"));
		String formCss = parseNull(request.getParameter("form_css"));

		if(deleteUploads.length()>0) deleteUploads = "1";
		else deleteUploads = "0";

		System.out.println("deleteUploads == > "+deleteUploads);

		if(formJs.length() > 0){

			formJs = formJs.replaceAll("\"", "&quot;");
		}

		if(formCss.length() > 0){

			formCss = formCss.replaceAll("\"", "&quot;");
		}

		if(defaultLanguage.getLanguageId().equals(langId)){

			Etn.execute("UPDATE process_forms_unpublished SET variant = " + escape.cote(variant) + ", template = " + escape.cote(template) + ", meta_description = " + escape.cote(metaDescription) + ", meta_keywords = " + escape.cote(metaKeywords) + ", redirect_url = " + escape.cote(redirectUrl) + ", btn_align = " + escape.cote(formButtonAlign) + ", html_form_id = " + escape.cote(htmlFormId) + ", form_class = " + escape.cote(formClass) + ", form_method = " + escape.cote(formMethod) + ", form_enctype = " + escape.cote(formEnctype) + ", form_autocomplete = " + escape.cote(formAutoComplete) + ", label_display = " + escape.cote(formDisplayLabel) + ", form_width = " + escape.cote(formWidth) + ", form_js = " + escapeCote2(formJs) + ", form_css = " + escapeCote2(formCss) + " , delete_uploads = " + escape.cote(deleteUploads) + ", updated_on = now(), updated_by = "+escape.cote(pid)+ " WHERE form_id = " + escape.cote(formId));
		}

		String formSuccessMsg = parseNull(request.getParameter("success_msg_" + langId));
		String formTitle = parseNull(request.getParameter("title_" + langId));
		String formSubmitBtnLbl = parseNull(request.getParameter("submit_btn_lbl_" + langId));
		String formCancelBtnLbl = parseNull(request.getParameter("cancel_btn_lbl_" + langId));

		if(formSuccessMsg.length() > 0)
		{
			formSuccessMsg = decodeCKEditorValue(formSuccessMsg);
			formSuccessMsg = formSuccessMsg.replaceAll("\"", "&quot;");
		}

		Etn.execute("UPDATE process_form_descriptions_unpublished SET success_msg = " + escape.cote(formSuccessMsg) + ", title = " + escape.cote(formTitle) + ", submit_btn_lbl = " + escape.cote(formSubmitBtnLbl) + ", cancel_btn_lbl = " + escape.cote(formCancelBtnLbl) + " WHERE form_id = " + escape.cote(formId) + " AND langue_id = " + escape.cote(langId));

		callPagesUpdateFormAPI(formId, Etn.getId());
		updateVersionForm(Etn, formId);

        Set rs_name =  Etn.execute("SELECT process_name FROM process_forms_unpublished WHERE form_id = "+escape.cote(formId));
        rs_name.next();
        ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"UPDATED","Form",parseNull(rs_name.value(0)),selectedSiteId);

		updateFormPage(Etn,PAGES_DB,formId);
	}

	Set lineRs = Etn.execute("SELECT pfl.*, pf.type as type FROM process_form_lines_unpublished pfl, process_forms_unpublished pf WHERE pfl.form_id = pf.form_id and pfl.form_id = " + escape.cote(formId) + " ORDER BY CAST(line_seq as UNSIGNED) ");


	Set rsV = Etn.execute("select case when coalesce(p.version,-1) = -1 then 0 when pu.version = p.version then 1 else 2 end as _status from process_forms_unpublished pu left join process_forms p on p.form_id = pu.form_id where pu.form_id = "+escape.cote(formId));
	rsV.next();
	String vStatusColor = "danger";
	if("1".equals(rsV.value("_status"))) vStatusColor = "success";
	else if("2".equals(rsV.value("_status"))) vStatusColor = "warning";
	
%>

<!DOCTYPE html>

<html lang="<%=parseNull(defaultLanguage.getCode())%>">
<head>
	<title><%=formName%></title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

    <!-- ace editor -->
    <script src="<%=request.getContextPath()%>/js/ace/ace.js" ></script>
    <!-- ace modes -->
    <script src="<%=request.getContextPath()%>/js/ace/mode-freemarker.js" ></script>
    <script src="<%=request.getContextPath()%>/js/ace/mode-javascript.js" ></script>
    <script src="<%=request.getContextPath()%>/js/ace/mode-css.js" ></script>

    <script src="https://www.google.com/recaptcha/api.js?hl=<%=defaultLanguage.getCode()%>" ></script>

    <script src="<%=request.getContextPath()%>/js/ckeditor/adapters/jquery.js"></script>
	
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("CATALOG_URL")%>js/urlgen/etn.urlgenerator.js"></script>
    <script type="text/javascript">
        window.URL_GEN_AJAX_URL = "<%=com.etn.beans.app.GlobalParm.getParm("CATALOG_URL")%>js/urlgen/urlgeneratorAjax.jsp";

        // for media library
        window.PAGES_APP_URL = '<%=parseNull(com.etn.beans.app.GlobalParm.getParm("PAGES_APP_URL"))%>';
        window.MEDIA_LIBRARY_UPLOADS_URL = '<%=parseNull(com.etn.beans.app.GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL"))+selectedSiteId+"/"%>';
        window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = window.MEDIA_LIBRARY_UPLOADS_URL + 'img/';
    </script>
	
    <script>
        CKEDITOR.timestamp = "" + parseInt(Math.random()*100000000);
    </script>

    <style type="text/css">
        .ace_editor {
            border: 1px solid lightgray;
            min-height: 500px;
            font-family: monospace;
            font-size: 14px;
        }

        .list-group-item{
            display: list-item !important;
        }
    </style>
</head>

<%	
breadcrumbs.add(new String[]{"Content", ""});
if(isGame) breadcrumbs.add(new String[]{"Games", "games.jsp"});
else breadcrumbs.add(new String[]{"Forms", "process.jsp"});
breadcrumbs.add(new String[]{formName, ""});
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>

<div class="c-wrapper c-fixed-components" id="hideOnLoad">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
			<!-- title -->
			<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
				<div>
					<h1 class="h2"><%=formName%><span style="height: 25px; width: 25px; border-radius: 50%; border: 1px solid rgb(221, 221, 221); display: inline-block; vertical-align: middle; margin-left: 15px; user-select: auto;" class="bg-<%=vStatusColor%>"></span></h1>
					<p class="lead"></p>
				</div>

				<!-- buttons bar -->
				

				<div class="btn-toolbar mb-2 mb-md-0">
					<div class="btn-group" role="group" aria-label="...">						
						<a href="<% if(openTempModal.equals("1")|| isGame){%>games.jsp<%} else {%>process.jsp<%}%>" class="btn btn-primary" >Back</a>
					</div>
				</div>

				<!-- /buttons bar -->
			</div>
			<!-- /title -->

			

			<!-- container -->
			<div class="animated fadeIn">

				<ul class="nav nav-tabs m-0 p-0" id="languages" role="tablist">
					<%
					int lc = 0;
					String clc = "";
					String bcls = "";
					for(Language lang : langsList){

						if(lc == 0)
							bcls = "success";
						else if(lc == 1)
							bcls = "warning";
						else if(lc == 2)
							bcls = "danger";

						if(langId.length() > 0 && lang.getLanguageId().equals(langId))
							clc = "active";
						else
							clc = "";
							lc++;
					%>
						<li class="nav-item">
							<a class="nav-link <%=clc%>" id="<%=lang.getCode()%>-tab" data-toggle="tab" href="#<%=lang.getCode()%>" role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%>
								<!-- 								<span style="height:15px;width:15px;border-radius:50%; border:1px solid #ddd;display: inline-block;vertical-align:middle; margin-left:5px" class="bg-<%=bcls%>">&nbsp;&nbsp;&nbsp;&nbsp;</span>
								this is for publish form status.... -->
							</a>
						</li>
					<% } %>
				</ul>

				<div id="parent_line_block" class="ui-sortable" style="cursor: auto;">
					<div class="tab-content p-3">
						<%
							lc = 0;
							clc = "";
							String luuid = "";
							int lneSeq = 0;
							Set formFieldRs = null;

							for(Language lang : langsList){
								if(langId.length() > 0 && lang.getLanguageId().equals(langId))
								clc = "active show";
								else
								clc = "";

						%>
							<div class="tab-pane p-0 fade <%=clc%>" id="<%=lang.getCode()%>" role="tabpanel" aria-labelledby="<%=lang.getCode()%>-tab">
								<div class="drag-drop-zone mt-4 ">
									<div class="connected-sortable droppable-area">
										<ul class="connected-sortable droppable-area p-0 m-0">
											<li style="margin-bottom:20px">
												<div class="card" style="min-height: 400px;">
													<div class="card-header" style="position: relative;">
														<div class="row">
															<p class="card-title font-weight-bold col-8 bloc_edit_buttons mb-0" > Form </p>
															<div class="card-title col-4 text-right mb-0">
																<a  class="btn btn-primary btn-modal form-api-instruction" role="button" aria-pressed="true" href="javascript:showApiInstructions('<%=lang.getLanguageId()%>')"><i data-feather="info"></i></a>
																<a id="<%=formId%>" class="btn btn-primary btn-modal edit_form" lang-id="<%=lang.getLanguageId()%>" role="button" aria-pressed="true" href="#" data-toggle="modal" data-placement="top" title="Edit form" data-target="#edit_form"> <i data-feather="settings"></i></a>
																<a id="<%=formId%>" class="btn btn-primary btn-modal edit_email" lang-id="<%=lang.getLanguageId()%>" role="button" aria-pressed="true" href="#" data-toggle="modal" data-placement="top" title="Edit mail parameter" data-target="#edit_email"> <i data-feather="mail"></i></a>
															<% if(!tableName.contains("gm_") && !tableName.contains("game_")) { %>
																<a id="<%=formId%>" class="btn btn-primary btn-modal edit_rule" lang-id="<%=lang.getLanguageId()%>" role="button" aria-pressed="true" href="#" data-toggle="modal" data-placement="top" title="Edit rules" data-target="#edit_rule"> <i data-feather="command"></i></a>
															<%}%>
																<div class="btn-group">
																	<button type="button" class="btn btn-success" onclick="window.open('pagePreview.jsp?id=<%=formId%>&lang=<%=lang.getCode()%>','<%=formId%>')">Preview</button>
																</div>
															</div>
														</div>
													</div>

													<div class="card-body">
														<ul class="m-0 p-0" style="list-style-type: none;" id="form-section">
															<%
																luuid = "";
																lneSeq = 0;
																formFieldRs = null;
																lineRs.moveFirst();
																while(lineRs.next()){

																	luuid = parseNull(lineRs.value("id"));
																	lneSeq = parseNullInt(lineRs.value("line_seq"));

																	formFieldRs = Etn.execute("SELECT pff.id as _etn_id, pffd.langue_id as langid, pff.field_id as _etn_field_id, pff.label_id as _etn_label_id, pff.form_id as _etn_form_id, pff.field_type as _etn_field_type, db_column_name as _etn_db_column_name, file_extension as _etn_file_extension, pffd.label as _etn_label, font_weight as _etn_font_weight, font_size as _etn_font_size, color as _etn_color, pffd.placeholder as _etn_placeholder, name as _etn_field_name, pffd.value as _etn_value, maxlength as _etn_maxlength, regx_exp as _etn_regx_exp, pff.required as _etn_required, rule_field as _etn_rule_field, pff.add_no_of_days as _etn_add_no_of_days, pff.start_time as _etn_start_time, pff.end_time as _etn_end_time, pff.time_slice as _etn_time_slice, pff.default_time_value as _etn_default_time_value, autocomplete_char_after as _etn_autocomplete_char_after, element_autocomplete_query as _etn_element_autocomplete_query, pff.element_trigger as _etn_element_trigger, pffd.label as _etn_label_name, element_option_class as _etn_element_option_class, element_option_others as _etn_element_option_others, pff.element_option_query as _etn_element_option_query, pffd.option_query as _etn_element_option_query_value, pff.group_of_fields as _etn_group_of_fields, pff.type as _etn_type, resizable_col_class as _etn_resizable_col_class, pffd.options as _etn_options, pff.img_width as _etn_img_width, pff.img_height as _etn_img_height, pff.img_alt as _etn_img_alt, pff.img_murl as _etn_img_murl, pff.href_chckbx as _etn_href_chckbx, pffd.err_msg as _etn_err_msg, pff.href_target as _etn_href_target, pff.img_href_url as _etn_img_href_url, pff.site_key as _etn_site_key, pff.theme as _etn_theme, pff.recaptcha_data_size as _etn_recaptcha_data_size, btn_id as _etn_btn_id, container_bkcolor as _etn_container_bkcolor, text_align as _etn_text_align, text_border as _etn_text_border, custom_css as _etn_custom_css, min_range as _etn_min_range, max_range as _etn_max_range, step_range as _etn_step_range, pff.img_url as _etn_img_url, default_country_code as _etn_default_country_code, allow_country_code as _etn_allow_country_code, allow_national_mode as _etn_allow_national_mode, local_country_name as _etn_local_country_name, auto_format_tel_number as _etn_auto_format_tel_number, pff.date_format as _etn_date_format, pff.custom_classes as _etn_custom_classes, pff.is_deletable as _etn_is_deletable, (SELECT type FROM process_forms_unpublished pf WHERE pf.form_id = pff.form_id) as _etn_form_type FROM process_form_fields_unpublished pff, process_form_field_descriptions_unpublished pffd WHERE pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pff.form_id = " + escape.cote(formId) + " AND line_id = " + escape.cote(luuid) + " AND pff.field_type IN (" + escape.cote("fs") + ", \"\") AND pffd.langue_id = " + escape.cote(lang.getLanguageId()) + " GROUP BY 1, 2 ORDER BY pff.seq_order, pff.id;");
															%>
																<li class="border-0 form-section-li-<%=lang.getLanguageId()%>" id="lineid_<%=luuid%>" line-id="<%=luuid%>" style="cursor: move;">
																	<div class="card m-2 card-line">
																		<div class="card-body">
																			<div class="row">
																				<div class="card-title font-weight-bold col-10" style="margin-bottom:0">
																					<div class="row">
																						<%
																							out.write(loadDynamicsSection(Etn, request, formFieldRs, null, null, null, "", "1", formId, "", "backendcall", luuid, lang.getLanguageId()));
																							if(formFieldRs.rs.Rows == 1 && lang.getLanguageId().equals(langId)){
																						%>

																							<div class="col activeField" style="margin-bottom:0">
																								<div class="field-edit row">
																									<button line-id="<%=luuid%>" lang-id="<%=lang.getLanguageId()%>" type="button" class="btn btn-success btn-modal add_field_type float-right" title="Add a field">Add a field</button>
																								</div>
																								<div class="field-edit-bgnd"> &nbsp; </div>
																							</div>
																						<% }
																							if(formFieldRs.rs.Rows == 0 && lang.getLanguageId().equals(langId)){
																						%>
																							<div class="col activeField" style="min-height:65px">
																								<div class="field-edit">
																									<button line-id="<%=luuid%>" lang-id="<%=lang.getLanguageId()%>" type="button" class="btn btn-success btn-modal add_field_type float-right" title="Add a field">Add a field</button>
																								</div>
																								<div class="field-edit-bgnd">&nbsp;</div>
																							</div>
																						<% } %>
																					</div>
																				</div>
																				<% if(lang.getLanguageId().equals(langId)){ %>
																					<div class="card-title line-edit col-2 text-right mt-3" style="margin-bottom:0">
																						<% if(parseNull(lineRs.value("type")).equalsIgnoreCase("simple")){ %>
																							<span ui-sortable-handlean id="<%=luuid%>" line-id="<%=luuid%>" class="btn btn-xs btn-danger mr-1 float-right delete_line_parameter" title="Delete line parameter" style="cursor:pointer;"><i data-feather="x"></i></span>
																						<% } %>
																						<span id="<%=luuid%>" line-id="<%=luuid%>" line-seq='<%=lneSeq%>' class="btn btn-xs btn-primary mr-1 float-right edit_line_parameter" title="Edit line parameter" style="cursor:pointer;"> <i data-feather="settings"></i> </span>
																						<span id="<%=luuid%>" line-id="<%=luuid%>" line-seq='<%=lneSeq%>' class="btn btn-xs btn-success mr-1 float-right add_line" title="Add a line" style="cursor:pointer;"> <i data-feather="plus"></i> </span>
																					</div>
																				<% } %>
																			</div>
																		</div>
																	</div>
																</li>
															<% } %>
														</ul>
													</div>

													<div class="card-footer text-center" style="border-top-style:dashed;border-top-width:2px"> <button id="add_line" type="button" class="btn btn-success btn-sm" >Add a line</button> </div>
												</div>
											</li>
										</ul>
									</div>
								</div>
							</div>

						<% } %>

						<input type="hidden" id="appcontext" value="<%=request.getContextPath()%>/" />
						<input type="hidden" id="image_browser" value='<%=GlobalParm.getParm("PAGES_URL")%>admin/imageBrowser.jsp?popup=1'>

					</div>
				</div>




				<div class="add_line_block_clone d-none">
					<li>
					<div class="card card-line mb-1">
						<div class="card-body">
							<div class="row">
								<div class="card-title font-weight-bold col-10" style="margin-bottom:0; ">
									<div class="row">
										<div class="col activeField" style="min-height:65px">
											<div class="field-edit">
												<button line-id="__genlineid__" lang-id="<%=defaultLanguage.getLanguageId()%>" type="button" class="btn btn-success btn-modal add_field_type float-right" title="Add a field">Add a field</button>
											</div>
											<div class="field-edit-bgnd" style="height:100%; width:100%;  position:absolute; left:0; top:0"> &nbsp; </div>
											<div class="form-group  row " style="margin-bottom:0"> &nbsp; </div>
										</div>
									</div>
								</div>
								<div class="card-title line-edit col-2 text-right" style="margin-bottom:0">
									<span line-seq="<%=(lneSeq+1)%>" line-id="__genlineid__" class="btn btn-xs btn-success mr-1 add_line" title="Add a line" style="cursor:pointer;"> <i data-feather="plus"></i> </span>
									<span line-seq="<%=(lneSeq+1)%>" line-id="__genlineid__" class="btn btn-xs btn-primary mr-1 edit_line_parameter" title="Edit line parameter" style="cursor:pointer;"> <i data-feather="settings"></i> </span>
									<span line-id="__genlineid__" line-id="__genlineid__" class="btn btn-xs btn-danger mr-1 delete_line_parameter" title="Delete line parameter" style="cursor:pointer;"><i data-feather="x"></i></span>
								</div>
							</div>
						</div>
					</div>
					</li>
				</div>

				<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
			</div>

	<!-- Modal edit line parameter -->

		</main>
	</div>

	<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<div id="form-api-instruction" class="modal fade" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="form api instruction" aria-hidden="true">
	<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
		<div class="modal-content h-100" autofocus="false">
			<div class="modal-header">
				<h5 class="modal-title">API Instructions</h5>

				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>

			<div class="container overflow-auto">
				<div class="my-3">
					<h2>API Instructions</h2>
					<p>Webmaster is responsible for creating the HTML for the form and adding all fields to it.</p>
					<p>To enable the api for your form, you must add the class <strong>asm-cf-form</strong> on the submit button.</p>
					<p>On your form html element, you must add the data attribute <strong>data-formid="<%=formId%>"</strong></p>
					<p>
					You can also add a callback function on your form html element. This callback function must take a json as parameter.
					This callback function if provided will be called by the system in case of success or error once the form is submitted.
					If the callback function is not provided, then error/success response will be shown as an alert.					
					</p>
					<p>Callback function data attribute name is <strong>data-callback</strong></p>
					<p>
					Adding fields to your form, you must provide data attribute named <strong>data-noe-fname</strong>.
					<br>
					You must use the DB Column name of each field as the value for <strong>data-noe-fname</strong>.
					<br>
					To make any field required, you can provide the required attribute with the html field.
					</p>
					<p>Following are the formats of JSON which system will pass to your callback function</p>
					<h5 class="font-weight-bold">SUCCESS RESPONSE JSON</h5>
					<pre id="success-json"></pre>
					<script>
						var tmpResp = { "response" : "success" , 
									    "msg" : "Success" , 
									    "rd" : "row_id",
									    "fd" : "form_id" 
									 };
						tmpResp = JSON.stringify(tmpResp,null,2);
						document.getElementById("success-json").innerHTML = tmpResp;
					</script>
					<h5 class="mt-4 font-weight-bold">ERROR RESPONSE JSON</h5>
					<pre id="error-json-1"></pre>
					<script>
						tmpResp = { "response" : "error", 
								    "msg" : "Error in fields", 
									"fields" : {
										"name" : ["Required Field missing"],
										"email" : ["Invalid email address"] 
									}
								  }
						tmpResp = JSON.stringify(tmpResp,null,2);
						document.getElementById("error-json-1").innerHTML = tmpResp;
					</script>
					<p class="my-2"> OR </p>
					<pre id="error-json-2"></pre>
					<script>
						tmpResp = { "response" : "error" , 
									"msg" : "Some Error Message",
									"fd" : "form_id"
								  }
						tmpResp = JSON.stringify(tmpResp,null,2);
						document.getElementById("error-json-2").innerHTML = tmpResp;
					</script>
					<div class="mt-3">
						<textarea id="form-html-code" class="form-control mb-3 d-none" style="min-height:100px;max-height:400px"></textarea>
					</div>
					<h5 class="mt-4 font-weight-bold">You may use the following HTML structure</h5>
					<div><textarea id='apiformhtml' class='form-control' rows='10'></textarea></div>
				</div>			
			</div>

			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>

<!-- Modal add field type -->
		<div id="add_field_type" class="modal fade" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Add a field type" aria-hidden="true">
			<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
				<div class="modal-content" autofocus="false">
					<div class="modal-header">
						<h5 class="modal-title">Add a field to the form</h5>

						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>

					<div id="add_field_type_content" class="modal-body">

					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>

		<!-- Modal add field type -->
		<div id="add_field_to_form" class="modal fade" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Add a field" aria-hidden="true">
			<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title">Add a new field</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>
					<div id="add_field_to_form_content" class="modal-body">
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>

		<div class="modal fade" id="edit_line_parameter" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit line parameter" aria-hidden="true">
				<div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
					<div class="modal-content">
						<div class="modal-header">
							<h5 class="modal-title">Edit line parameter</h5>

							<button type="button" class="close" data-dismiss="modal" aria-label="Close">
								<span aria-hidden="true">&times;</span>
							</button>
						</div>

						<div id="edit_line_parameter_content" class="modal-body">

						</div>

						<div class="modal-footer">
							<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
						</div>
					</div>
				</div>
			</div>

		<!-- Modal edit form -->
		<div class="modal fade" id="edit_form" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit form" aria-hidden="true">
			<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="edit_process_name"></h5>

						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>

					<div id="edit_form_content" class="modal-body">

					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>

		<!-- Modal edit email -->
		<div class="modal fade" id="edit_email" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit email" aria-hidden="true">
			<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title">Define template email</h5>

						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>

					<div id="edit_email_content" class="modal-body">
					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>

		<!-- Modal edit rule -->
		<div class="modal fade" id="edit_rule" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit rule" aria-hidden="true">
			<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title">Edit form rules</h5>

						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>

					<div id="edit_rule_content" class="modal-body">

					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>

		<!-- Modal edit form parameter -->
		<div class="modal fade" id="edit_form_parameter" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit form parameter" aria-hidden="true">
			<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title">Edit form parameter</h5>

						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>

					<div id="edit_form_parameter_content" class="modal-body">

					</div>

					<div class="modal-footer">
						<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>

		<div class="modal fade" style='text-align:center; display:none; clear:both;' id='uploadProductImageDialog' >
			<div class="modal-dialog" role="document" style="margin-right: 40%">
				<div class="modal-content" style="height: 650px; overflow-y: scroll; overflow-x: hidden; width: 150%;">
					<div class="modal-header" style='text-align:left'>
						<h5 class="modal-title">Upload Image Gallery</h5>
							<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
							</button>
					</div>
					<div class="modal-body text-left">
						<div>
							<form id="imageFileFrm" name="imageFileFrm" method='post' enctype='multipart/form-data' onsubmit="return false;">
								<div class="form-group row">
									<label class='col-sm-4'>File</label>
									<div class='col-sm-8'><input type='file' name='imageFile' class="imageFile" value='' accept="image/jpeg, image/png, image/gif"/></div>
								</div>
								<input type="hidden" id="imgUploadSelectedElement" value="" />
							</form>
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-success" onclick='uploadGalleryImage()'>Upload</button>
					</div>
					<div class="row">
						<div style='text-align:left; margin-left: 30px;'>
							<h5 class="modal-title">Image Gallery</h5>
						</div>
						<div class="col-xs-11 col-sm-11 col-md-11 col-lg-11" style="border: 1px solid #eae3e3; margin-left: 40px; margin-bottom: 15px; margin-top: 10px;">
							<ul id="imageGalleryList" style="width: 100%; padding: 0px; list-style: none;">
							<%
								try{

									String path = GlobalParm.getParm("UPLOAD_IMG_PATH");
									String imagePath = GlobalParm.getParm("FORM_UPLOADS_PATH") + "images/";
									String fileName = "";

									File imageFolder = new File(path);
									File[] listOfFiles = imageFolder.listFiles();

									if(null != listOfFiles){

										if(listOfFiles.length == 0){
							%>
											<center><span>No image found.</span></center>
							<%
										}

										for (int i = 0; i < listOfFiles.length; i++) {
											if (listOfFiles[i].isFile()) {
												fileName = listOfFiles[i].getName();
							%>

											<li onclick="update_selected_image(this)" style="height: 284px; width: 27%; float: left; margin: 15px; padding: 15px; border: 1px dotted silver; cursor: pointer;">
												<center>
													<span style="font-weight: bold; word-break: break-word;"><%= fileName%></span>
													<input type="hidden" value="<%= fileName%>">
												</center>
												<br>
												<center>
													<img src='<%= imagePath+fileName%>' style="max-height: 169px;">
												</center>

											</li>
							<%
											}
										}
									}


								}catch(Exception e){
									e.printStackTrace();
								}

							%>
							</ul>
						</div>
					</div>
				</div><!-- /.modal-content -->
			</div><!-- /.modal-dialog -->
		</div>
<script>

    var $ch = {}; //for globals
    var defaultLanguage = '<%=defaultLanguage.getLanguageId()%>';
	var openTempModal='<%=openTempModal%>';


function showApiInstructions(langid)
{	
	$.ajax({
		url : "<%=request.getContextPath()%>/admin/ajax/getapihtml.jsp",
		method : "post",
		data : {id : "<%=formId%>", langid : langid},
		success : function(html){
			$("#apiformhtml").text($.trim(html));
			$('#form-api-instruction').modal("show");
		},
		error : function(){
			console.log("Error contacting server");
		}
	});
	
}

	jQuery(document).ready(function()
	{
		
			
		var secondModal = false;
		var thirdModal = false;
        var aceCommonOptions = {
            minLines: 20,
            showPrintMargin : false,
            autoScrollEditorIntoView: true,
            // maxLines: 30,
            // theme : "ace/theme/github",
        };
		

		refreshscreen=function()
		{
			window.location = window.location
		};

		$(document).on('click', '.edit_line_parameter', function () {
			let lineuuid = $(this).attr("line-id");
			console.log(lineuuid);
			$("#edit_line_parameter_content").html("");

			$.ajax({

				url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
				type: 'POST',
				dataType: 'HTML',
				data: {
					"action": "editLineParameter",
					"formid": "<%=formId%>",
					"lineuuid": lineuuid,
					"lineSeq": $(this).attr("line-seq")
				},
				success : function(response)
				{
					$("#edit_line_parameter_content").html(response);
					$("#edit_line_parameter").modal("show");
				}
			});		
		});

		$(document).on('click', '.delete_line_parameter', function () {
			let lineuuid = $(this).attr("line-id");
			console.log(lineuuid);
			if(confirm("Are you sure to delete this line?"))
			{
				var fid = "<%=formId%>";
				$.ajax({

					url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
					type: 'POST',
					dataType: 'HTML',
					data: {
						"action": "deleteLineParameter",
						"formid": fid,
						"lineuuid": lineuuid
					},
					success : function(response)
					{
						window.location="editProcess.jsp?form_id=" + fid;
					}
				});			
			}			
		});

		$(".edit_form_parameter").on("click", function(){

		    $.ajax({

		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": "editFormParameter",
		        	"formid": $(this).prop("id")
		        },
		        success : function(response)
		        {
		        	$("#edit_form_parameter_content").html(response);
		        }
		    });
		});

		$(".edit_form").on("click", function(){

			var lid = $(this).attr("lang-id");
		    $.ajax({

		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxNewForm.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"formid": $(this).prop("id"),
		        	"lang_id": $(this).attr("lang-id"),
		        	"target": "editprocess"
		        },
		        success : function(response)
		        {
		        	$("#edit_form_content").html(response);
					$("#edit_process_name").html("Edit form: "+$("#process_name").val());

					$("#edit_form").on('shown.bs.modal', function() {

						$('.edit_form').modal('show');
						

				        $(".ckeditor_success_msg").ckeditor({
							filebrowserImageBrowseUrl: $("#image_browser").val(),
							extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
							colorButton_enableMore: true,
							colorButton_enableAutomatic: false,
							allowedContent: true,
							colorButton_colors: '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
						}, onFieldCkeditorReady);

					    var javascriptOpts = $.extend({ mode: "ace/mode/javascript"}, aceCommonOptions);
					    $ch.jsEditor = ace.edit("js_code_editor", javascriptOpts);
		          		$ch.jsEditor.getSession().setValue($("#form_js").val());

					    var cssOpts = $.extend({ mode: "ace/mode/css"}, aceCommonOptions);
					    $ch.cssEditor = ace.edit("css_code_editor", cssOpts);
		          		$ch.cssEditor.getSession().setValue($("#form_css").val());

		          		if(defaultLanguage !== lid){
		          			$("#js_code_editor").css({"pointer-events":"none","background-color":"#cccccc"});
		          			$("#css_code_editor").css({"pointer-events":"none","background-color":"#cccccc"});
		          		} else {
		          			$("#js_code_editor").css({"pointer-events":"","background-color":""});
		          			$("#css_code_editor").css({"pointer-events":"","background-color":""});
		          		}

						$('.edit_form').toggle('hide');
						$('.edit_form').css('display','inline-block');
					});

					$("#edit_form").on('hidden.bs.modal', function() {

						$('.edit_form').modal('hide');
						$('.edit_form').css('display','inline-block');
					});
		        }
		    });
		});

		

		$(".edit_email").on("click", function(){

        	var lid = $(this).attr("lang-id");

		    $.ajax({

		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxConfigureMail.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"fid": $(this).prop("id"),
		        	"langId": lid
		        },
		        success : function(response)
		        {
		        	$("#edit_email_content").html(response);
		        	selecttab("lang" + lid + "show");

					$("#edit_email").on('shown.bs.modal', function() {

						$('.edit_email').modal('show');

				        $(".ckeditor_field").ckeditor({
				            filebrowserImageBrowseUrl : $("#image_browser").val(),
							extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
							colorButton_enableMore : true,
							colorButton_enableAutomatic : false,
							allowedContent: true,
							colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
				        }, onFieldCkeditorReady);

						$(".ckeditor_field").each(function(){
							var _id = $(this).attr('id');
							var vl = CKEDITOR.instances[_id].getData();

							if(vl.indexOf("src='") > -1)
							{
								vl = vl.replace(/src='/gi,"_etnipt_='");
							}

							if(vl.indexOf("src=\"") > -1)
							{
								vl = vl.replace(/src="/gi,"_etnipt_=\"");
							}
							if(vl.indexOf("href='") > -1)
							{
								vl = vl.replace(/href='/gi,"_etnhrf_='");
							}
							if(vl.indexOf("href=\"") > -1)
							{
								vl = vl.replace(/href="/gi,"_etnhrf_=\"");
							}
							if(vl.indexOf("style=") > -1)
							{
								vl = vl.replace(/style=/gi,"_etnstl_=");
							}
							if(vl.indexOf("style=") > -1)
							{
								vl = vl.replace(/style=/gi,"_etnstl_=");
							}

							$("#" + _id + "_ipt").val(vl);
						});

					    var freemarkerOpts = $.extend({ mode: "ace/mode/freemarker"}, aceCommonOptions);
					    $(".freemarker_customeroffice_field").each(function(){

							if($(this).parent().css("display") == "block"){

							    $ch.templateCustomerofficeEditor = ace.edit(this, freemarkerOpts);
				          		$ch.templateCustomerofficeEditor.getSession().setValue($("#lang_" + lid + "_template_fm").val());
							    return false;
							}
					    });

					    $(".freemarker_backoffice_field").each(function(){

							if($(this).parent().css("display") == "block"){
							    $ch.templateBackofficeEditor = ace.edit(this, freemarkerOpts);
				          		$ch.templateBackofficeEditor.getSession().setValue($("#lang_" + lid + "_back_office_template_fm").val());
							    return false;
							}
					    });

						$("#customer_sms_copy_available_fields").on("click", function(){
							
							var value = '<input value="' + $("#customer_sms_available_fields").val() + '" id="copyclipboard" />';
							$(value).insertAfter('#customer_sms_available_fields');
							$("#copyclipboard").select();
							document.execCommand("Copy");
							$('body').find("#copyclipboard").remove();
						});

						$("#customer_copy_avaiable_fields").on("click", function(){

							var caf = "";

							if($("#cust_ofc_tt").val() == "text")
								caf = $("#customer_available_fields").val();
							else if($("#cust_ofc_tt").val() == "freemarker")
								caf = $("#customer_available_fields_fm").val();

							var value = '<input value="' + caf + '" id="copyclipboard" />';
							$(value).insertAfter('#customer_available_fields');
							$("#copyclipboard").select();
							document.execCommand("Copy");
							$('body').find("#copyclipboard").remove();
						});

						$("#backoffice_copy_avaiable_fields").on("click", function(){

							var baf = "";

							if($("#bk_ofc_tt").val() == "text")
								baf = $("#backoffice_available_fields").val();
							else if($("#bk_ofc_tt").val() == "freemarker")
								baf = $("#backoffice_available_fields_fm").val();

							var value = '<input value="' + baf + '" id="backofficecopyclipboard" />';
							$(value).insertAfter('#backoffice_available_fields');
							$("#backofficecopyclipboard").select();
							document.execCommand("Copy");
							$('body').find("#backofficecopyclipboard").remove();

						});

						$('.edit_email').toggle('hide');
						$('.edit_email').css('display','inline-block');
					});

					$("#edit_email").on('hidden.bs.modal', function() {

						$('.edit_email').modal('hide');
						$('.edit_email').css('display','inline-block');
					});

		        }
		    });

		});

		$(".edit_rule").on("click", function(){

		    $.ajax({

		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": "formAddRule",
		        	"fid": $(this).prop("id"),
		        	"langId": $(this).attr("lang-id")
		        },
		        success : function(response)
		        {
		        	$("#edit_rule_content").html(response);
		        }
		    });

		});

		$(document).on('click', '.add_line', function () {
			if($("#parent_line_block").find(".card-body").first().html().length == 0)
				$("#parent_line_block").find(".card-body").first().remove();


			var lineBlockClone = $(".add_line_block_clone").clone();
			$(lineBlockClone).removeClass("d-none");
			$(lineBlockClone).removeClass("add_line_block_clone");

			//$(this).parents('li').append(lineBlockClone)
			var lineSeqs = $(this).attr("line-seq");

			add_new_line($(this).closest('li'), lineSeqs, lineBlockClone.html());

		});

		$("#add_line").on("click", function(){

			if($("#parent_line_block").find(".card-body").first().html().length == 0)
				$("#parent_line_block").find(".card-body").first().remove();


			var lineBlockClone = $(".add_line_block_clone").clone();
			$(lineBlockClone).removeClass("d-none");
			$(lineBlockClone).removeClass("add_line_block_clone");

			//$("#parent_line_block").find("#form-section").append(lineBlockClone);
			add_new_line($("#parent_line_block").find("#form-section"), "", lineBlockClone.html());

		});

		add_new_line = function(obj, lineSeqs, htm, appendAtEnd){

		    $.ajax({

		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": "addLineParameter",
		        	"line_seq": lineSeqs,
		        	"formid": "<%=formId%>"
		        },
		        success : function(lineuuid)
		        {
					htm = htm.replace(/__genlineid__/g, $.trim(lineuuid));
					$(obj).append(htm);
		        }
		    });
		}

		$(document).on('click', '.add_field_type', function () {
			secondModal = false;
		    $.ajax({
		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": "add_field_type",
		        	"formid": "<%=formId%>",
		        	"lineid": $(this).attr("line-id"),
		        	"langid": $(this).attr("lang-id")
		        },
		        success : function(response)
		        {
		        	$("#add_field_type_content").html(response);
		        	feather.replace();
					$("#add_field_type").modal("show")
		        }
		    });
		});

		saveFormFields = function(){

			showLoader();
			var flagProcessForm = false;
			if($("#db_column_name").val() == ""){

	        	$("#db_column_name").parent().find(".is_dbcolumn_exists").remove();
				$("#db_column_name").next().css("display","block");
				flagProcessForm = true;
			}
			else if($("#db_column_name").val() && $("#db_column_name").val().length >= 45)
			{
				$("#db_column_name").next().css("display","block").text("DB Column Name should be less than 45 characters");
				return;
			}
			else $("#db_column_name").next().css("display","none");

			if($("#element_trigger_js").length > 0 && $ch.jsEditor!=undefined){

	      		$("#element_trigger_js").val($ch.jsEditor.getSession().getValue());
			}

			if($("#custom_css").length > 0 && $ch.cssEditor!=undefined){

	      		$("#custom_css").val($ch.cssEditor.getSession().getValue());
			}

			if($("#file_extension").length > 0 && $("#file_extension:checked").length == 0){

				$("#file_extension").parent().parent().parent().next().css("display","block");
				flagProcessForm = true;
			}
			else $("#file_extension").parent().parent().parent().next().css("display","none");

			if(flagProcessForm) {
				hideLoader();
				return false;
			}

			if($("#db_column_name").prop("disabled") || ($("#ftype").val() == "textrecaptcha" || $("#ftype").val() == "button")){

				replaceXssAttributes();
				$("#addfrmfield").submit();

			}else{

			    $.ajax({

			        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
			        type: 'POST',
			        dataType: 'JSON',
			        data: {
			        	"action": "is_dbcolumn_exists",
			        	"formid": "<%=formId%>",
			        	"dbcolumn": $("#db_column_name").val()
			        },
			        success : function(response)
			        {

			        	$("#db_column_name").parent().find(".is_dbcolumn_exists").remove();
			        	if(response.status == 1){

			        		$("#db_column_name").parent().append('<div class="invalid-feedback is_dbcolumn_exists" style="display: block;">' + response.msg + '</div>')

			        	} else {

							replaceXssAttributes();
			        		$("#db_column_name").parent().find(".is_dbcolumn_exists").remove();
							$("#addfrmfield").submit();
			        	}
			        }
			    });
			}
			hideLoader();
		};
		
		copyText = function(e)
		{
			navigator.clipboard.writeText(e.innerHTML);
		}

		replaceXssAttributes=function()
		{
			$(".ignore_xss").each(function(){
				let _id = $(this).attr('id');

				let vl = "";
				if($(this).hasClass("ckeditor_label")) vl = CKEDITOR.instances[_id].getData();
				else vl = $(this).val();
				
				console.log(_id + " " + vl);
				if(vl.indexOf("src='") > -1)
				{
					vl = vl.replace(/src='/gi,"_etnipt_='");
				}
				if(vl.indexOf("src=\"") > -1)
				{
					vl = vl.replace(/src="/gi,"_etnipt_=\"");
				}
				if(vl.indexOf("href='") > -1)
				{
					vl = vl.replace(/href='/gi,"_etnhrf_='");
				}
				if(vl.indexOf("href=\"") > -1)
				{
					vl = vl.replace(/href="/gi,"_etnhrf_=\"");
				}
				if(vl.indexOf("style=") > -1)
				{
					vl = vl.replace(/style=/gi,"_etnstl_=");
				}
				if(vl.indexOf("style=") > -1)
				{
					vl = vl.replace(/style=/gi,"_etnstl_=");
				}

				$("#" + _id).val(vl);
				
			});
		}

		deleteElement = function(element){
			if(confirm("Are you sure to delete this field?"))
			{
				$.ajax({

					url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
					type: 'POST',
					dataType: 'HTML',
					data: {
						"action": "deleteElement",
						"formid": "<%=formId%>",
						"lineid": $(element).attr("line-id"),
						"fieldid": $(element).attr("line-field-id"),
						"column": $(element).attr("line-col-name")
					},
					success : function(response)
					{
						window.location="editProcess.jsp?form_id=<%=formId%>";
					}
				});
			}
		};

		$(document).on('click', '.add_field_to_form', function () {
			var lngid = $(this).attr("lang-id");
			var fieldType = $(this).attr("field-type");

		    $.ajax({

		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": "configure_field",
		        	"formid": "<%=formId%>",
		        	"lineid": $(this).attr("line-id"),
		        	"fieldid": $(this).attr("line-field-id"),
		        	"langid": lngid,
		        	"field_type": $(this).attr("field-type"),
		        	"field_type_label": $(this).attr("field-label"),
		        	"target": "editprocess"
		        },
		        success : function(response)
		        {
		        	$("#add_field_to_form").find(".modal-title").html("Edit " + fieldType + " field");
		        	$("#add_field_to_form_content").html(response);

					$("#add_field_to_form").on('shown.bs.modal', function() {
						
						$('.add_field_to_form').modal('show');
						$('.add_field_to_form').modal('hide');
						$('.add_field_to_form').css('display','inline-block');


						$('input#db_column_name').on("input",function(e){
							onDbLetterKeyup(this);
						});

						if($('#label_'+lngid).length > 0)
						{						
							let label = $('#label_'+lngid);
							let length = $(label).val().length;
							label.focus();
							label[0].setSelectionRange(length, length);
						}

						$("#add_field_to_form").find(".ckeditor_label").ckeditor({
							filebrowserImageBrowseUrl : $("#image_browser").val(),
							extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
							colorButton_enableMore : true,
							colorButton_enableAutomatic : false,
							allowedContent: true,
							colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
						}, onFieldCkeditorReady);

						var javascriptOpts = $.extend({ mode: "ace/mode/javascript"}, aceCommonOptions);

						if($("#element_trigger_js_code_editor").length > 0){

							$ch.jsEditor = ace.edit("element_trigger_js_code_editor", javascriptOpts);
							$ch.jsEditor.getSession().setValue($("#element_trigger_js").val());
						}

						var cssOpts = $.extend({ mode: "ace/mode/css"}, aceCommonOptions);
						if($("#custom_css_code_editor").length > 0){

							$ch.cssEditor = ace.edit("custom_css_code_editor",cssOpts);
							$ch.cssEditor.getSession().setValue($("#custom_css").val());
						}

						if(defaultLanguage !== lngid){
							$("#element_trigger_js_code_editor").css({"pointer-events":"none","background-color":"#cccccc"});
							$("#custom_css_code_editor").css({"pointer-events":"none","background-color":"#cccccc"});
						} else {
							$("#element_trigger_js_code_editor").css({"pointer-events":"","background-color":""});
							$("#custom_css_code_editor").css({"pointer-events":"","background-color":""});
						}

						if($(".field_options").length>1)
						$(".remove.remove-opt").removeClass("d-none");

					});
					//$('#add_field_type').modal('hide');

					$("#add_field_to_form").on('hidden.bs.modal', function() {
						$('.add_field_to_form').modal('hide');
						$('.add_field_to_form').css('display','inline-block');
					});
					
	        	}
		    });

		});
	

		elementChecked = function(element){

			if($(element).prop("checked"))
				$(element).next().val("1");
			else
				$(element).next().val("0");

		};

		writeQueryOfTriggerEvent = function(element){

			if($(element).val().length > 0){

				$(element).next().find("textarea,a[name^='element_trigger_']").parent().removeClass("d-none");

			}else{

				$(element).next().find("textarea,a[name^='element_trigger_']").parent().addClass("d-none");
			}

		};

		addMoreEventTrigger = function(element){

			var copyElement = $(element).parent().parent().parent().clone();
			copyElement = "<span class=\"col-md-3\"></span><div class=\"col-md-9\">" + copyElement.html() + "</div>";

			$(element).parent().parent().parent().parent().append(copyElement);
			$(element).parent().remove();
		};

		addMoreFieldOptions = function(){

			var options = $(".field_options_clone").clone();
			$(options).removeClass("d-none field_options_clone");
			$(options).addClass("field_options");

			$(".field_options").last().after(options);
			if($(".field_options").length>1)
				$(".remove.remove-opt").removeClass("d-none");
		};

		removeFieldOptions = function()
		{
			var options = $(".field_options");
			if(options.length<=1)
				return
			
			options.last().remove();
			options = $(".field_options");
			if(options.length<=1)
				$(".remove.remove-opt").addClass("d-none");
		}

		forWritingQuery = function(element){

			$("#option_query_value").val("");

			if($(element).is(":checked")) {

				if(!confirm("Are you sure to write the query?\nWarning: options will be lost."))
					return false;

				$(".field_options").addClass("d-none");
				$(".field_options").html("");
				$(".add_more_options").addClass("d-none");
				$(".write_query_option").removeClass("d-none");

				$("#element_option_query").val("1");

			} else {

				addMoreFieldOptions();

				$(".add_more_options").removeClass("d-none");
				$(".write_query_option").addClass("d-none");
				$(".field_options").not(":last").remove();

				$("#element_option_query").val("0");
			}
		};

		updateOptionClass = function(element){

			if($(element).is(":checked"))
				$("#element_option_class").val("form-check-inline");
			else
				$("#element_option_class").val("");

		}

		configMail = function(element, id){

			var val = $(element).html();
			$(element).parent().prev().html(val);
			if(val === "Yes")
				$("#"+id).val("1");
			else if(val === "No")
				$("#"+id).val("0");
		}

		configSms = function(element, id){
			var val = $(element).html();
			$(element).parent().prev().html(val);
			if(val === "Yes")
				$("#"+id).val("1");
			else if(val === "No")
				$("#"+id).val("0");
		}

		update_template_type = function(elementTemplate){

			var template = $(elementTemplate).val();
			var section = $(elementTemplate).attr("id");

			if(template == "text"){

				if(section == "cust_ofc_tt"){

					$("#customer_available_fields").removeClass("d-none");
					$("#customer_available_fields_fm").addClass("d-none");

					$(".cust_ofc_ta_template").removeClass("d-none");
					$(".cust_ofc_fm_template").addClass("d-none");

				} else if(section = "bk_ofc_tt"){

					$("#backoffice_available_fields").removeClass("d-none");
					$("#backoffice_available_fields_fm").addClass("d-none");

					$(".bk_ofc_ta_template").removeClass("d-none");
					$(".bk_ofc_fm_template").addClass("d-none");
				}


			} else if( template == "freemarker"){

				if(section == "cust_ofc_tt"){

					$("#customer_available_fields_fm").removeClass("d-none");
					$("#customer_available_fields").addClass("d-none");

					$(".cust_ofc_fm_template").removeClass("d-none");
					$(".cust_ofc_ta_template").addClass("d-none");


				} else if(section = "bk_ofc_tt"){

					$("#backoffice_available_fields_fm").removeClass("d-none");
					$("#backoffice_available_fields").addClass("d-none");

					$(".bk_ofc_fm_template").removeClass("d-none");
					$(".bk_ofc_ta_template").addClass("d-none");
				}

			}
		}

		openUploadGalleryImageDialog = function(currentElement){

			selectImageField = currentElement;
			var dialogDiv = $('#uploadProductImageDialog');

			dialogDiv.find('form')[0].reset();

			dialogDiv.modal('show');

			thirdModal = true;
		}

		uploadGalleryImage = function() {

			$("#uploadProductImageDialogalert>span").html("");
			$("#uploadProductImageDialogalert").hide();

			var dialogDiv = $('#uploadProductImageDialog');
			var form = dialogDiv.find('form:first');

			var fileField = form.find('input.imageFile:first');

			if(fileField.val() =='')
			{
				alert("Please select an image")
//				$("#uploadProductImageDialogalert>span").text("Please select an image");
//				$("#uploadProductImageDialogalert").show();
//				$("#uploadProductImageDialogalert").addClass('show');
				return;
			}
			var ok= isvalidimage(fileField.val());

			if(!ok)
			{
				alert("Not a valid image file.")
//				$("#uploadProductImageDialogalert>span").text("Not a valid image file.");
//				$("#uploadProductImageDialogalert").show();
//				$("#uploadProductImageDialogalert").addClass('show');
				return;
			}

			//showLoader();
			var formData = new FormData(form[0]);

			$.ajax({
				url: $("#appcontext").val()+"admin/ajax/uploadImage.jsp",
				type: 'POST',
				dataType: 'json',
				data: formData,

				cache : false,
				processData: false,  // tell jQuery not to process the data
		  		contentType: false,  // tell jQuery not to set contentType
			})
			.done(function(resp) {

				if(resp.status == "SUCCESS"){

					$("#meta_info_value").val(resp.imageFileName);
					$('#uploadProductImageDialog').modal('hide');
					$("#imageGalleryList").html(resp.image_html);

					if($("#imgUploadSelectedElement").val().length > 0){

						$("#"+$("#imgUploadSelectedElement").val()).next().find("img").prop("src", $("#appcontext").val()+"uploads/images/"+resp.imageFileName);

					}
				}
			})
			.fail(function() {
				alert("Error in contacting server.");
			})
		}

		$(".dynamic_fields").each(function(){

		    if($(this).find(".bloc_field_edit").length > 1)
		    	$(this).parent().find(".add_field_type").css("display","none");
		});

		Sortable.create(document.getElementById('form-section'), {
			animation:100,
			onEnd: function(event) {
				updateLineSeq();
			}
		});


		updateLineSeq = function(){

			var lineId = [];
			var lineSeq = [];

			$(".form-section-li-<%=defaultLanguage.getLanguageId()%>").each(function(i){

				lineId.push($(this).attr("line-id"));
				lineSeq.push((i+1))
			});

		    $.ajax({

		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: {
		        	"action": "updateLineSeq",
		        	"formid": "<%=formId%>",
		        	"lineid": lineId.join(","),
		        	"lineSeq": lineSeq.join(",")
		        },
		        success : function(response)
		        {

		        }
		    });

		}

	    $(".tel").each(function(i){

		    window.intlTelInput(this, {

				utilsScript: '<%=GlobalParm.getParm("FORMS_WEB_APP")%>js/utils.js',
				initialCountry: $(this).attr("default-country-code"),

		    });
	    });

		
	    formLineMove = function(btn, direction){

	        var btn = $(btn);
	        var lid = btn.attr("lang-id")
	        var line = btn.parents('.form-section-li-' + lid + ':first');

	        if(direction == 'down'){
	            var nextEle = line.next();

	            if(nextEle.hasClass('form-section-li-' + lid)){
	                line.insertAfter(nextEle);
	            }
	        }
	        else if(direction == 'up'){
	            var prevEle = line.prev();

	            if(prevEle.hasClass('form-section-li-' + lid)){
	                line.insertBefore(prevEle);
	            }
	        }

	        updateLineSeq();
	    }

	    onDbLetterKeyup = function(input){

	        var val = $(input).val();

	        val = val.trimLeft()
	                    .replace(" ","_")
	                    .replace(/[^a-zA-Z0-9\/_]/g,'')

	        $(input).val(val.toLowerCase());
	    }

		onsave = function(){
			var lid = $("#lang_id").val();

			if($("#config_bk_ofc_email").is(":checked") && $("#lang_email").val().length == 0){
				alert("Kindly provide backoffce email");
				$("#lang_email").focus();
				return false;
			}

			if($("#cust_ofc_tt").val() == "freemarker")
				$("#lang_" + lid + "_template_fm").val($ch.templateCustomerofficeEditor.getSession().getValue());

			if($("#bk_ofc_tt").val() == "freemarker")
				$("#lang_" + lid + "_back_office_template_fm").val($ch.templateBackofficeEditor.getSession().getValue());


			//as cross site is enabled we will fill the templates into the xss_ fields respectively and replace href and src in them
			if($("#lang_1_template").val() !== undefined) $("#xss_lang_1_template").val($("#lang_1_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_2_template").val() !== undefined) $("#xss_lang_2_template").val($("#lang_2_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_3_template").val() !== undefined) $("#xss_lang_3_template").val($("#lang_3_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_4_template").val() !== undefined) $("#xss_lang_4_template").val($("#lang_4_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_5_template").val() !== undefined) $("#xss_lang_5_template").val($("#lang_5_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			
			if($("#lang_1_template_fm").val() !== undefined) $("#xss_lang_1_template_fm").val($("#lang_1_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_2_template_fm").val() !== undefined) $("#xss_lang_2_template_fm").val($("#lang_2_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_3_template_fm").val() !== undefined) $("#xss_lang_3_template_fm").val($("#lang_3_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_4_template_fm").val() !== undefined) $("#xss_lang_4_template_fm").val($("#lang_4_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_5_template_fm").val() !== undefined) $("#xss_lang_5_template_fm").val($("#lang_5_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			
			if($("#lang_1_back_office_template").val() !== undefined) $("#xss_lang_1_back_office_template").val($("#lang_1_back_office_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_2_back_office_template").val() !== undefined) $("#xss_lang_2_back_office_template").val($("#lang_2_back_office_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_3_back_office_template").val() !== undefined) $("#xss_lang_3_back_office_template").val($("#lang_3_back_office_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_4_back_office_template").val() !== undefined) $("#xss_lang_4_back_office_template").val($("#lang_4_back_office_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_5_back_office_template").val() !== undefined) $("#xss_lang_5_back_office_template").val($("#lang_5_back_office_template").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			
			if($("#lang_1_back_office_template_fm").val() !== undefined) $("#xss_lang_1_back_office_template_fm").val($("#lang_1_back_office_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_2_back_office_template_fm").val() !== undefined) $("#xss_lang_2_back_office_template_fm").val($("#lang_2_back_office_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_3_back_office_template_fm").val() !== undefined) $("#xss_lang_3_back_office_template_fm").val($("#lang_3_back_office_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_4_back_office_template_fm").val() !== undefined) $("#xss_lang_4_back_office_template_fm").val($("#lang_4_back_office_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));
			if($("#lang_5_back_office_template_fm").val() !== undefined) $("#xss_lang_5_back_office_template_fm").val($("#lang_5_back_office_template_fm").val().replace(/src=/gi,"_etnipt_=").replace(/href=/gi,"_etnhrf_=").replace(/style=/gi,"_etnstl_="));

		    $.ajax({
				
		        url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxMailHandler.jsp',
		        type: 'POST',
		        dataType: 'JSON',
		        data: $("#config_email_frm").serialize(),
		        success : function(response)
		        {
		        	if(response.hasOwnProperty("cusofc") && response.cusofc[lid].status == "error"){

			        	$(".bk_ofc_fm_template").find(".invalid-feedback").html("");
			        	$(".bk_ofc_fm_template").find(".invalid-feedback").css("display", "none");

			        	$(".cust_ofc_fm_template").find(".invalid-feedback").html(response.cusofc[lid].message);
			        	$(".cust_ofc_fm_template").find(".invalid-feedback").css("display", "block");

		        	} else if(response.hasOwnProperty("bkofc") && response.bkofc[lid].status == "error"){

			        	$(".cust_ofc_fm_template").find(".invalid-feedback").html("");
			        	$(".cust_ofc_fm_template").find(".invalid-feedback").css("display", "none");

			        	$(".bk_ofc_fm_template").find(".invalid-feedback").html(response.bkofc[lid].message);
			        	$(".bk_ofc_fm_template").find(".invalid-feedback").css("display", "block");

		        	} else {

 						window.location = window.location.href.replace("&openTempModal=1","");
		        	}
		        }
		    });
		}

		goback = function(){

			window.location = "process.jsp";
		}

		

		selecttab=function(tab) {

			$(".lang1show, .lang2show, .lang3show, .lang4show, .lang5show").hide();
			
			$("#tab_lang1show, #tab_lang2show, #tab_lang3show, #tab_lang4show, #tab_lang5show").css("background", "");

			$(".lang1showta, .lang2showta, .lang3showta, .lang4showta, .lang5showta").css("display", "none");

			$("."+tab).show();
			$("."+tab+"ta").css("display", "block");
			$("#tab_" + tab).css("background","#D9EDF7");

			if($("#cust_ofc_tt").val() == "text"){

				$(".cust_ofc_ta_template").removeClass("d-none");
				$(".cust_ofc_fm_template").addClass("d-none");

				$("#customer_available_fields").removeClass("d-none");
				$("#customer_available_fields_fm").addClass("d-none");

			} else if($("#cust_ofc_tt").val() == "freemarker"){

				$(".cust_ofc_fm_template").removeClass("d-none");
				$(".cust_ofc_ta_template").addClass("d-none");

				$("#customer_available_fields_fm").removeClass("d-none");
				$("#customer_available_fields").addClass("d-none");

			}

			if($("#bk_ofc_tt").val() == "text"){

				$(".bk_ofc_ta_template").removeClass("d-none");
				$(".bk_ofc_fm_template").addClass("d-none");

				$("#backoffice_available_fields").removeClass("d-none");
				$("#backoffice_available_fields_fm").addClass("d-none");

			} else if($("#bk_ofc_tt").val() == "freemarker"){

				$(".bk_ofc_fm_template").removeClass("d-none");
				$(".bk_ofc_ta_template").addClass("d-none");

				$("#backoffice_available_fields_fm").removeClass("d-none");
				$("#backoffice_available_fields").addClass("d-none");

			}

			var selectedLang = tab.substring(0, tab.length-4);
			var ckEditorCustomerId = "";
			var ckEditorBackofficeId = "";

			if(selectedLang === "lang1"){

				ckEditorCustomerId = "lang_1_template";
				ckEditorBackofficeId = "lang_1_back_office_template"
			}
			else if(selectedLang === "lang2"){

				ckEditorCustomerId = "lang_2_template";
				ckEditorBackofficeId = "lang_2_back_office_template"
			}
			else if(selectedLang === "lang3"){

				ckEditorCustomerId = "lang_3_template";
				ckEditorBackofficeId = "lang_3_back_office_template"
			}
			else if(selectedLang === "lang4"){

				ckEditorCustomerId = "lang_4_template";
				ckEditorBackofficeId = "lang_4_back_office_template"
			}
			else if(selectedLang === "lang5"){

				ckEditorCustomerId = "lang_5_template";
				ckEditorBackofficeId = "lang_5_back_office_template"
			}

			$("#customer_copy_avaiable_fields").attr("ck-editor-customer-id", ckEditorCustomerId);
			$("#backoffice_copy_avaiable_fields").attr("ck-editor-backoffice-id", ckEditorBackofficeId);
		};

		translateFormData=function(form_id){
			showLoader();
			$.ajax({
					url : '<%=request.getContextPath()%>/admin/ajax/translateForm.jsp?form_id='+form_id,
					type: 'GET',
					success : function(response)
					{
						hideLoader();
						if(response.status){
							location.reload();
						}else{
							alert ( "Error Occured while translating the form" );
						}
						
					}
			});
			
		};
		if(openTempModal==="1"){
			$($(".edit_email")[0]).trigger( "click" );
			<% openTempModal="0"; %>
			openTempModal='<%= openTempModal%>';
		}
	});
	
</script>
</body>
</html>