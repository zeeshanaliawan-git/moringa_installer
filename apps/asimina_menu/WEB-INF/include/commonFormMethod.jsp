<%@ page import="java.util.UUID, java.util.Map, java.util.HashMap, java.util.List, java.util.ArrayList, org.json.*"%>

<%!

	public String elementTriggerCote(String paramString) {

		if (paramString == null) {
		  return paramString;
		}

		int i = paramString.length();
		char[] arrayOfChar = new char[i + i];
		int j;
		int k;
		for (k = j = 0; j < i; j++)
		{
		  arrayOfChar[(k++)] = (char)paramString.charAt(j);
		}

		if (k != j) {
		  return new String(arrayOfChar, 0, k);
		}

		return "'" + paramString.replaceAll("'","''") + "'";
	}

	Map<String, String> getFieldMap(String dbColumnName, String name, String label, String value, String valueOtherLang, String type, String fileExtension, String allowNationalMode, String options, String optionOtherLang, String hrefCheckbox, String isDeletable, String useToSearch, String displayReplyForm, String displayOrderOfFields, String required){

		Map<String, String> fieldsMap = new HashMap<String, String>();
		
		fieldsMap.put("db_column_name", dbColumnName);
		fieldsMap.put("name", name);
		fieldsMap.put("label", label);
		fieldsMap.put("value", value);
		fieldsMap.put("value_other_lang", valueOtherLang);
		fieldsMap.put("type", type);
		fieldsMap.put("file_extension", fileExtension);
		fieldsMap.put("allow_national_mode", allowNationalMode);
		fieldsMap.put("options", options);
		fieldsMap.put("options_other_lang", optionOtherLang);
		fieldsMap.put("href_chckbx", hrefCheckbox);
		fieldsMap.put("is_deletable", isDeletable);
		fieldsMap.put("use_to_search", useToSearch);
		fieldsMap.put("display_reply_form", displayReplyForm);
		fieldsMap.put("display_order", displayOrderOfFields);
		fieldsMap.put("required", required);

		return fieldsMap;
	}

	int insertProcessForm(com.etn.beans.Contexte etn, String formId, String name, String tableName, String id, String formType){

		String query = "INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished (form_id, process_name, table_name, site_id, variant, template, form_method, form_autocomplete, form_width, type) VALUES (" + escape.cote(formId) + "," + escape.cote(name) + "," + escape.cote(tableName) + "," + escape.cote(id+"") + "," + escape.cote("all") + "," + escape.cote("0") + "," + escape.cote("post") + "," + escape.cote("off") + "," + escape.cote("12") + "," + escape.cote(formType) + ")";

		return etn.executeCmd(query);
	}

	void insertProcessFormDescription(com.etn.beans.Contexte etn, String formId, String name, String id, String langId, String title){

		etn.executeCmd("insert into " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_descriptions_unpublished (form_id, langue_id, title, page_path) values (" + escape.cote(formId) + ", " + escape.cote(langId) + ", " + escape.cote(title) + ", " + escape.cote("forms/"+name) + ") on duplicate key update page_path = " + escape.cote("forms/"+name));
	}

	void insertProcessFormField(List<Map<String, String>> fieldsList, Set langRs, String formId, com.etn.beans.Contexte etn) throws JSONException {

        String lineUuid = "";
        String fieldUuid = "";
		String fieldQuery = "";
		String fieldDespQuery = "";
		String fieldValue = "";
		String fieldOptions = "";

		JSONObject elementTriggerObject = new JSONObject();
		JSONArray elementTriggerValueArray = new JSONArray();
		JSONArray elementTriggerJSArray = new JSONArray();
		JSONArray elementTriggerEventArray = new JSONArray();

		for(int i=0; i < fieldsList.size(); i++){

	        lineUuid = UUID.randomUUID().toString();
	        fieldUuid = UUID.randomUUID().toString();

	        etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_lines_unpublished (id, form_id, line_id, line_width, line_seq) VALUES (" + escape.cote(lineUuid) + ", " + escape.cote(formId) + ", " + escape.cote("line"+(i+1)) + ", " + escape.cote("12") + ", " + escape.cote((i+1)+"") + ")");

	        elementTriggerEventArray.put("");
	        elementTriggerValueArray.put("");
	        elementTriggerJSArray.put("");

			elementTriggerObject.put("event",elementTriggerEventArray);
			elementTriggerObject.put("query",elementTriggerValueArray);
			elementTriggerObject.put("js",elementTriggerJSArray);

	        fieldQuery = "INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_fields_unpublished( form_id, line_id, field_id, field_type, db_column_name, font_weight, color, name, autocomplete_char_after, element_trigger, type, file_extension, allow_national_mode, href_chckbx, is_deletable, required) VALUES (" + escape.cote(formId) + "," + escape.cote(lineUuid) + "," + escape.cote(fieldUuid) + "," + escape.cote("fs") + "," + escape.cote(fieldsList.get(i).get("db_column_name")) + "," + escape.cote("-1") + "," + escape.cote("#333333") + "," + escape.cote(fieldsList.get(i).get("name")) + "," + escape.cote("2") + "," + elementTriggerCote(elementTriggerObject.toString()) + "," + escape.cote(fieldsList.get(i).get("type")) + "," + escape.cote(fieldsList.get(i).get("file_extension")) + "," + escape.cote(fieldsList.get(i).get("allow_national_mode")) + "," + escape.cote(fieldsList.get(i).get("href_chckbx")) + "," + escape.cote(fieldsList.get(i).get("is_deletable")) + "," + escape.cote(fieldsList.get(i).get("required")) + ")";

	        int rid = etn.executeCmd(fieldQuery);

	        if(rid > 0){

		        langRs.moveFirst();
		        while(langRs.next()){

		        	if(langRs.value("langue_id").equals("1")){

		        		fieldValue = fieldsList.get(i).get("value");
		        		fieldOptions = fieldsList.get(i).get("options");

			        } else {

		        		fieldValue = fieldsList.get(i).get("value_other_lang");
		        		fieldOptions = fieldsList.get(i).get("options_other_lang");
				    }

		        	fieldDespQuery = "INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_field_descriptions_unpublished(form_id, field_id, langue_id, label, value, options) VALUES(" + escape.cote(formId) + "," + escape.cote(fieldUuid) + "," + escape.cote(langRs.value("langue_id")) + "," + escape.cote(fieldsList.get(i).get("label")) + "," + escape.cote(fieldValue) + "," + escape.cote(fieldOptions) + ")";

		        	etn.executeCmd(fieldDespQuery);
			    }

			    if(fieldsList.get(i).get("use_to_search").equals("1")){

				    etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".form_search_fields_unpublished(form_id, field_id, display_order) VALUES (" + escape.cote(formId) + "," + escape.cote(fieldUuid) + "," + escape.cote(fieldsList.get(i).get("display_order")) + ")");
				}

			    if(fieldsList.get(i).get("display_reply_form").equals("1")){

				    etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".form_result_fields_unpublished(form_id, field_id, display_order) VALUES (" + escape.cote(formId) + "," + escape.cote(fieldUuid) + "," + escape.cote(fieldsList.get(i).get("display_order")) + ")");
				}				
		    }
		}
	}

	void createSignUpForm(String id, String name, com.etn.beans.Contexte etn) throws JSONException 
	{
		Set rs = etn.execute("SELECT * FROM " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished WHERE type = " + escape.cote("sign_up") + " AND site_id = " + escape.cote(id) + " AND table_name = " + escape.cote("sign_up_site_"+id));

		if(rs.rs.Rows == 0)
		{
			System.out.println("createing signup form for site id :: "+id);
			String formId = UUID.randomUUID().toString();

			// creation signup forms...
			int rid = insertProcessForm(etn, formId, "Signup", "sign_up_site_"+id, id, "sign_up");
			
			if(rid > 0){

				Set langRs = etn.execute("select * from language order by langue_id;");
				while(langRs.next())
				{
					insertProcessFormDescription(etn, formId, "signup", id, parseNull(langRs.value("langue_id")), "Signup");
				}

				List<Map<String, String>> fieldsList = new ArrayList<Map<String, String>>();
				
				fieldsList.add(getFieldMap("_etn_login", "login", "Login", "", "", "textfield", "", "", "{}", "{}", "0", "1", "1", "1", "6", "1"));
				fieldsList.add(getFieldMap("_etn_avatar", "avatar", "Avatar", "", "", "fileupload", "png, jpg", "", "{}", "{}", "0", "0", "0", "1", "1", "0"));
				fieldsList.add(getFieldMap("_etn_civility", "civility", "Civility", "", "", "dropdown", "", "", "{\"val\":[\"Mr.\",\"Mrs.\"],\"txt\":[\"Mr.\",\"Mrs.\"]}", "{\"val\":[],\"txt\":[]}", "0", "0", "1", "1", "2", "0"));
				fieldsList.add(getFieldMap("_etn_first_name", "first_name", "First name", "", "", "textfield", "", "", "{}", "{}", "0", "0", "1", "1", "3", "0"));
				fieldsList.add(getFieldMap("_etn_last_name", "last_name", "Last name", "", "", "textfield", "", "", "{}", "{}", "0", "0", "1", "1", "4", "0"));
				fieldsList.add(getFieldMap("_etn_email", "email", "Email", "", "", "email", "", "", "{}", "{}", "0", "0", "1", "1", "5", "0"));
				fieldsList.add(getFieldMap("_etn_mobile_phone", "mobile_phone", "Mobile phone", "", "", "tel", "", "1", "{}", "{}", "0", "0", "0", "0", "7", "0"));
				fieldsList.add(getFieldMap("_etn_landline_phone", "landline_phone", "Fixe phone", "", "", "tel", "", "1", "{}", "{}", "0", "1", "0", "0", "8", "0"));
				fieldsList.add(getFieldMap("_etn_birthdate", "birthdate", "Birthdate", "", "", "textdate", "", "", "{}", "{}", "0", "1", "0", "0", "9", "0"));
				fieldsList.add(getFieldMap("_etn_agreement", "agreement", "Agreement", "Agreement Value", "", "hyperlink", "", "", "{}", "{}", "1", "0", "0", "0", "10", "0"));
				fieldsList.add(getFieldMap("_etn_confirmation_link", "confirmation_link", "Confirmation Link", "", "", "texthidden", "", "", "{}", "{}", "1", "0", "0", "0", "11", "0"));

				// creation signup fields
				insertProcessFormField(fieldsList, langRs, formId, etn);
			}
		}
	}

	void createForgotPasswordForm(String id, String name, com.etn.beans.Contexte etn) throws JSONException {

		Set rs = etn.execute("SELECT * FROM " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished WHERE type = " + escape.cote("forgot_password") + " AND site_id = " + escape.cote(id) + " AND table_name = " + escape.cote("forgot_password_site_"+id));

		if(rs.rs.Rows == 0){

			System.out.println("creating forgot password form for site id :: "+id);
			String formId = UUID.randomUUID().toString();
			// creation forgot password forms...
			int rid = insertProcessForm(etn, formId, "Forgot password", "forgot_password_site_"+id, id, "forgot_password");

			if(rid > 0){

				Set langRs = etn.execute("select * from language order by langue_id;");
				while(langRs.next()){

					insertProcessFormDescription(etn, formId, "forgotpassword", id, parseNull(langRs.value("langue_id")), "Forgot password");
				}


				List<Map<String, String>> fieldsList = new ArrayList<Map<String, String>>();

				fieldsList.add(getFieldMap("_etn_login", "login", "Login", "", "", "textfield", "", "", "{}", "{}", "0", "1", "1", "1", "1", "1"));
				fieldsList.add(getFieldMap("_etn_email", "email", "Email", "", "", "email", "", "", "{}", "{}", "0", "1", "1", "1", "2", "0"));
				fieldsList.add(getFieldMap("_etn_forgotpassword_link", "forgotpassword_link", "Forgot password Link", "", "", "texthidden", "", "", "{}", "{}", "1", "0", "0", "0", "3", "0"));

				// creation forgot password fields
				insertProcessFormField(fieldsList, langRs, formId, etn);
			}
		}
	}

%>