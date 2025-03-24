<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, com.etn.asimina.util.ActivityLog"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language" %>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%
	String site_id = getSelectedSiteId(session);

	String partoo_activated = parseNull(request.getParameter("partoo_activated"));
	String partoo_api_key = parseNull(request.getParameter("partoo_api_key"));
	String partoo_org_id = parseNull(request.getParameter("partoo_org_id"));
	String partoo_country_code = parseNull(request.getParameter("partoo_country_code"));
	String partoo_main_group = parseNull(request.getParameter("partoo_main_group"));
	String partoo_language_id = parseNull(request.getParameter("partoo_language_id"));

	String idCheckActivated = parseNull(request.getParameter("idcheck-activated"));
	
	String idcheckBloc = parseNull(request.getParameter("idcheck-bloc"));

	Etn.executeCmd("update "+GlobalParm.getParm("PORTAL_DB")+".sites set partoo_language_id = "+escape.cote(partoo_language_id)+", partoo_activated = "+escape.cote(partoo_activated)+" , partoo_organization_id = "+escape.cote(partoo_org_id)+" , partoo_country_code = "+escape.cote(partoo_country_code)+", partoo_main_group = "+escape.cote(partoo_main_group)+", partoo_api_key = "+escape.cote(partoo_api_key)+" where id="+escape.cote(site_id));	
	
	//algolia fields
	String activated = parseNull(request.getParameter("activated"));
	String application_id = parseNull(request.getParameter("application_id"));
	String search_api_key = parseNull(request.getParameter("search_api_key"));
	String write_api_key = parseNull(request.getParameter("write_api_key"));
	String exclude_noindex = parseNull(request.getParameter("exclude_noindex"));
	String test_application_id = parseNull(request.getParameter("test_application_id"));
	String test_search_api_key = parseNull(request.getParameter("test_search_api_key"));
	String test_write_api_key = parseNull(request.getParameter("test_write_api_key"));

	HashMap<String, List<String>> indexNamesList = new HashMap<String, List<String>>();
	List<Language> langsList = getLangs(Etn, site_id);

	for(Language _lng : langsList)
	{
		indexNamesList.put(_lng.getLanguageId(), new ArrayList<String>());
		String[] index_names = request.getParameterValues("lang_"+_lng.getLanguageId()+"_index_name");
		if(index_names != null)
		{
			for(int i=0;i<index_names.length;i++)
			{
				String idn = parseNull(index_names[i]);				
				System.out.println("idn : "+idn);
				if(idn.length() == 0) continue;
				if(indexNamesList.get(_lng.getLanguageId()).contains(idn))
				{
					out.write("{\"success\":20, \"errmsg\":\"Duplicate index names\"}");
					return;
				}
				indexNamesList.get(_lng.getLanguageId()).add(idn);
			}
		}
	}

	for(Language _lng : langsList)
	{
		String[] rules_indexes = request.getParameterValues("lang_"+_lng.getLanguageId()+"_rules_index");
		if(rules_indexes != null)
		{
			for(int i=0;i<rules_indexes.length;i++)
			{
				if(parseNull(rules_indexes[i]).length() == 0) continue;
				if(indexNamesList.get(_lng.getLanguageId()).contains(parseNull(rules_indexes[i])) == false)
				{
					out.write("{\"success\":10, \"errmsg\":\"Index used in rules does not exists\"}");
					return;
				}
			}
		}
	}

	for(Language _lng : langsList)
	{
		String[] index_types = request.getParameterValues("lang_"+_lng.getLanguageId()+"_index_type");
		String[] index_names = request.getParameterValues("lang_"+_lng.getLanguageId()+"_index_name");
		String[] algolia_indexes = request.getParameterValues("lang_"+_lng.getLanguageId()+"_algolia_index");

		if(index_types != null)
		{
			for(int i=0; i<index_types.length; i++)
			{
				if(parseNull(index_types[i]).length() == 0 && parseNull(index_names[i]).length() > 0)
				{
					out.write("{\"success\":10, \"errmsg\":\"Index type not selected for some rows\"}");
					return;
				}
			}
		}
	}

	String qry = " insert into algolia_settings (site_id, activated, application_id, search_api_key, write_api_key, exclude_noindex, created_by, test_application_id, test_search_api_key, test_write_api_key) " +
			" values ( "+escape.cote(site_id)+", "+escape.cote(activated)+", "+escape.cote(application_id)+", "+escape.cote(search_api_key)+", "+escape.cote(write_api_key)+
			", "+escape.cote(exclude_noindex)+", "+escape.cote(""+Etn.getId())+
			", "+escape.cote(test_application_id)+", "+escape.cote(test_search_api_key)+", "+escape.cote(test_write_api_key)+" ) " +
			" on duplicate key update version = version + 1, updated_by = "+escape.cote(""+Etn.getId())+", updated_on = now(), activated = "+escape.cote(activated)+", application_id = "+escape.cote(application_id)+
			", search_api_key = "+escape.cote(search_api_key)+", write_api_key = "+escape.cote(write_api_key)+", exclude_noindex = "+escape.cote(exclude_noindex)+
			", test_application_id="+escape.cote(test_application_id)+", test_search_api_key="+escape.cote(test_search_api_key)+", test_write_api_key="+escape.cote(test_write_api_key);

	Etn.executeCmd(qry);

	Etn.executeCmd("delete from algolia_default_index where site_id = " + escape.cote(site_id));
	for(Language _lng : langsList)
	{
		String[] default_indexes = request.getParameterValues("lang_"+_lng.getLanguageId()+"_default_index");
		if(default_indexes != null)
		{
			for(int i=0; i<default_indexes.length; i++)
			{
				if(parseNull(default_indexes[i]).length() == 0) continue;
				Etn.executeCmd("insert into algolia_default_index (site_id, langue_id, index_name) values ("+escape.cote(site_id)+", "+escape.cote(_lng.getLanguageId())+", "+escape.cote(parseNull(default_indexes[i]))+") ");
			}
		}
	}

	Etn.executeCmd("delete from algolia_indexes where site_id = " + escape.cote(site_id));

	for(Language _lng : langsList)
	{
		String[] index_types = request.getParameterValues("lang_"+_lng.getLanguageId()+"_index_type");
		String[] index_names = request.getParameterValues("lang_"+_lng.getLanguageId()+"_index_name");
		String[] algolia_indexes = request.getParameterValues("lang_"+_lng.getLanguageId()+"_algolia_index");
		String[] test_algolia_indexes = request.getParameterValues("lang_"+_lng.getLanguageId()+"_test_algolia_index");

		if(index_types != null)
		{
			for(int i=0; i<index_types.length; i++)
			{
				if(parseNull(index_types[i]).length() > 0)
				{
					Etn.executeCmd("insert into algolia_indexes (langue_id, order_seq, site_id, index_type, index_name, algolia_index ,test_algolia_index) values ("+escape.cote(_lng.getLanguageId())+", "+i+", "+escape.cote(site_id)+","+escape.cote(parseNull(index_types[i]))+","+escape.cote(parseNull(index_names[i]))+", "+escape.cote(parseNull(algolia_indexes[i]))+","+escape.cote(parseNull(test_algolia_indexes[i]))+") ");
				}
			}
		}
	}


	Etn.executeCmd("delete from algolia_rules where site_id = " + escape.cote(site_id));
	for(Language _lng : langsList)
	{
		String[] rules_element_types = request.getParameterValues("lang_"+_lng.getLanguageId()+"_rules_element_type");
		String[] rules_criterias = request.getParameterValues("lang_"+_lng.getLanguageId()+"_rules_criteria");
		String[] rules_criteria_values = request.getParameterValues("lang_"+_lng.getLanguageId()+"_rules_criteria_value");
		String[] rules_indexes = request.getParameterValues("lang_"+_lng.getLanguageId()+"_rules_index");
		String[] exclude_from_defaults = request.getParameterValues("lang_"+_lng.getLanguageId()+"_exclude_from_default");

		if(rules_element_types != null)
		{
			for(int i=0; i<rules_element_types.length; i++)
			{
				System.out.println("---------- "+parseNull(rules_element_types[i])+ " : " + parseNull(rules_criterias[i]) + " : " + parseNull(rules_criteria_values[i]) + " : "+ parseNull(rules_indexes[i]));
				if(parseNull(rules_element_types[i]).length() == 0 || parseNull(rules_criterias[i]).length() == 0 || parseNull(rules_criteria_values[i]).length() == 0 || parseNull(rules_indexes[i]).length() == 0) continue;

				Etn.executeCmd("insert into algolia_rules (langue_id, order_seq, site_id, rule_type, rule_criteria, rule_value, index_name, exclude_from_default) values ("+escape.cote(_lng.getLanguageId())+", "+i+", "+escape.cote(site_id)+", "+escape.cote(parseNull(rules_element_types[i]))+", "+escape.cote(parseNull(rules_criterias[i]))+", "+escape.cote(parseNull(rules_criteria_values[i]))+", "+escape.cote(parseNull(rules_indexes[i]))+", "+escape.cote(parseNull(exclude_from_defaults[i]))+") ");
			}
		}

	}

	if(idCheckActivated.equals("1"))
	{
		Etn.executeCmd("update  " + GlobalParm.getParm("PORTAL_DB") + ".idcheck_configurations set is_active=1 where site_id="+escape.cote(site_id));
	}
	else{
		Etn.executeCmd("update  " + GlobalParm.getParm("PORTAL_DB") + ".idcheck_configurations set is_active=0 where site_id="+escape.cote(site_id));
	}
	String idCheckCode = parseNull(request.getParameter("code"));
	String idcheckEmail = parseNull(request.getParameter("idcheck-email"));
	String idcheckPassword = parseNull(request.getParameter("idcheck-password"));
	String idcheckPathName = parseNull(request.getParameter("path-name"));
	String idcheckSupportEmail = parseNull(request.getParameter("support-email"));
	String idcheckLinkValidity = parseNull(request.getParameter("link-validity"));
	String idcheckBlockUpload = (parseNull(request.getParameter("block-upload")).equalsIgnoreCase("on"))? "1":"0";
	String idcheckCaptureModeDesktop = parseNull(request.getParameter("idcheck-capture-mode-desktop"));
	String idcheckCaptureModeMobile = parseNull(request.getParameter("idcheck-capture-mode-mobile"));
	String idcheckUploadPromptOnMobile = (parseNull(request.getParameter("prompt-on-mobile")).equalsIgnoreCase("on"))? "1":"0";
	String idcheckDisableImageBlackWhiteChecks = (parseNull(request.getParameter("disable-image-black-white-checks")).equalsIgnoreCase("on"))? "1":"0";
	String idcheckDisableImageQualityChecks = (parseNull(request.getParameter("disable-image-quality-checks")).equalsIgnoreCase("on"))? "1":"0";
	String idcheckEmailSenderName = parseNull(request.getParameter("email-sender-name"));
	String idCheckLogo = parseNull(request.getParameter("image_value"));
	String idcheckTitleTxtColor = parseNull(request.getParameter("title-txt-color"));
	String idcheckHeaderBgColor = parseNull(request.getParameter("header-bg-color"));
	String idcheckBtnBgColor = parseNull(request.getParameter("btn-bg-color"));
	String idcheckBtnHoverBgColor = parseNull(request.getParameter("btn-hover-bg-color"));
	String idcheckBtnTxtColor = parseNull(request.getParameter("btn-txt-color"));
	String idcheckHideHeaderBorder = (parseNull(request.getParameter("hide-header-border")).equalsIgnoreCase("on"))? "1":"0";
	String idcheckHeaderLogoAlign = parseNull(request.getParameter("header-logo-align"));
	String idcheckBtnBorderRadius = parseNull(request.getParameter("btn-border-radius"));

	qry = "INSERT INTO "+GlobalParm.getParm("PORTAL_DB")+".idcheck_configurations(code,email,password,site_id,is_active,path_name,support_email,link_validity,email_sender_name,block_upload,capture_desktop,capture_mobile,prompt_mobile,image_blk_whe_chk,image_qty_chk,logo,title_txt_color,header_bg_color,btn_bg_color,btn_hover_bg_color,btn_txt_color,btn_border_rad,hide_head_border,head_logo_align,bloc_uuid) VALUES ("+escape.cote(idCheckCode)+","+escape.cote(idcheckEmail)+","+escape.cote(idcheckPassword)+","+escape.cote(site_id)+","+escape.cote(idCheckActivated)+","+escape.cote(idcheckPathName)+","+escape.cote(idcheckSupportEmail)+","+escape.cote(idcheckLinkValidity)+","+escape.cote(idcheckEmailSenderName)+","+escape.cote(idcheckBlockUpload)+","+escape.cote(idcheckCaptureModeDesktop)+","+escape.cote(idcheckCaptureModeMobile)+","+escape.cote(idcheckUploadPromptOnMobile)+","+escape.cote(idcheckDisableImageBlackWhiteChecks)+","+escape.cote(idcheckDisableImageQualityChecks)+","+escape.cote(idCheckLogo)+","+escape.cote(idcheckTitleTxtColor)+","+escape.cote(idcheckHeaderBgColor)+","+escape.cote(idcheckBtnBgColor)+","+escape.cote(idcheckBtnHoverBgColor)+","+escape.cote(idcheckBtnTxtColor)+","+escape.cote(idcheckBtnBorderRadius)+","+escape.cote(idcheckHideHeaderBorder)+","+escape.cote(idcheckHeaderLogoAlign)+","+escape.cote(idcheckBloc)+") ";
	qry += "ON DUPLICATE KEY UPDATE ";
	qry += "code = VALUES(code),";
	qry += "email = VALUES(email),";
	qry += "password = VALUES(password),";
	qry += "site_id = VALUES(site_id),";
	qry += "is_active = VALUES(is_active),";
	qry += "path_name = VALUES(path_name),";
	qry += "support_email = VALUES(support_email),";
	qry += "link_validity = VALUES(link_validity),";
	qry += "email_sender_name = VALUES(email_sender_name),";
	qry += "block_upload = VALUES(block_upload),";
	qry += "capture_desktop = VALUES(capture_desktop),";
	qry += "capture_mobile = VALUES(capture_mobile),";
	qry += "prompt_mobile = VALUES(prompt_mobile),";
	qry += "image_blk_whe_chk = VALUES(image_blk_whe_chk),";
	qry += "image_qty_chk = VALUES(image_qty_chk),";
	qry += "logo = VALUES(logo),";
	qry += "title_txt_color = VALUES(title_txt_color),";
	qry += "header_bg_color = VALUES(header_bg_color),";
	qry += "btn_bg_color = VALUES(btn_bg_color),";
	qry += "btn_hover_bg_color = VALUES(btn_hover_bg_color),";
	qry += "btn_txt_color = VALUES(btn_txt_color),";
	qry += "btn_border_rad = VALUES(btn_border_rad),";
	qry += "hide_head_border = VALUES(hide_head_border),";
	qry += "head_logo_align = VALUES(head_logo_align), ";
	qry += "bloc_uuid = VALUES(bloc_uuid);";

	int id = Etn.executeCmd(qry);
		
	String [] idcheckHomeTitle = request.getParameterValues("home-title");
	String [] idcheckHomeMsg = request.getParameterValues("idcheck-home-msg");
	String [] idcheckAuthentInputMsg = request.getParameterValues("authent-input-msg");
	String [] idcheckAuthentHelpMsg = request.getParameterValues("authent-help-msg");
	String [] idcheckErrMsg = request.getParameterValues("err_msg");
	String [] idcheckOnboardingEndMsg = request.getParameterValues("onboarding-end-msg");
	String [] idcheckExpiredMsg = request.getParameterValues("expired-msg");
	String [] idcheckLinkEmailSubject = request.getParameterValues("link-email-subject");
	String [] idcheckLinkEmailMsg = request.getParameterValues("link-email-msg");
	String [] idcheckLinkEmailSignature = request.getParameterValues("link-email-signature");
	String [] idcheckLinkSmsMsg = request.getParameterValues("link-sms-msg");
	String [] idcheckLanguage = request.getParameterValues("language");
	
	String config_id = parseNull(id+"");
	Set configRs = Etn.execute("SELECT id FROM " + GlobalParm.getParm("PORTAL_DB") + ".idcheck_configurations WHERE site_id="+escape.cote(site_id));
	configRs.next();
	config_id = parseNull(configRs.value("id"));

	for(int i=0; i<idcheckLanguage.length; i++)
	{
		String query = "INSERT INTO " + GlobalParm.getParm("PORTAL_DB") + ".idcheck_config_wordings (config_id, home_title, home_msg, auth_input_msg, auth_help_msg, error_msg, onboarding_end_msg, expired_msg, link_email_subject, link_email_msg, link_email_signat, link_sms_msg, langue_code) " +
			"VALUES (" + escape.cote(config_id) + "," + escape.cote(parseNull(idcheckHomeTitle[i])) + "," + escape.cote(parseNull(idcheckHomeMsg[i])) + "," +
			escape.cote(parseNull(idcheckAuthentInputMsg[i])) + "," + escape.cote(parseNull(idcheckAuthentHelpMsg[i])) + "," + escape.cote(parseNull(idcheckErrMsg[i])) + "," +
			escape.cote(parseNull(idcheckOnboardingEndMsg[i])) + "," + escape.cote(parseNull(idcheckExpiredMsg[i])) + "," + escape.cote(parseNull(idcheckLinkEmailSubject[i])) + "," +
			escape.cote(parseNull(idcheckLinkEmailMsg[i])) + "," + escape.cote(parseNull(idcheckLinkEmailSignature[i])) + "," + escape.cote(parseNull(idcheckLinkSmsMsg[i])) + "," +
			escape.cote(parseNull(idcheckLanguage[i])) + ") " +
				"ON DUPLICATE KEY UPDATE " +
				"home_title = VALUES(home_title), " +
				"home_msg = VALUES(home_msg), " +
				"auth_input_msg = VALUES(auth_input_msg), " +
				"auth_help_msg = VALUES(auth_help_msg), " +
				"error_msg = VALUES(error_msg), " +
				"onboarding_end_msg = VALUES(onboarding_end_msg), " +
				"expired_msg = VALUES(expired_msg), " +
				"link_email_subject = VALUES(link_email_subject), " +
				"link_email_msg = VALUES(link_email_msg), " +
				"link_email_signat = VALUES(link_email_signat), " +
				"link_sms_msg = VALUES(link_sms_msg), " +
				"langue_code = VALUES(langue_code) " ;

		Etn.executeCmd(query);
	}

	String successRedirectUrl = parseNull(request.getParameter("success-redirect-url"));
	String errorRedirectUrl = parseNull(request.getParameter("error-redirect-url"));
	String autoRedirect = (parseNull(request.getParameter("auto-redirect")).equalsIgnoreCase("on"))? "1":"0";
	String notificationType = parseNull(request.getParameter("notify-type"));
	String notificationValue = parseNull(request.getParameter("notify-type-value"));
	String realm = parseNull(request.getParameter("cisconf-realm"));
	String fileLaunchCheck = (parseNull(request.getParameter("file-launch-check")).equalsIgnoreCase("on"))? "1":"0";
	String fileCheckWait = (parseNull(request.getParameter("file-check-wait")).equalsIgnoreCase("on"))? "1":"0";
	String fileTags = parseNull(request.getParameter("cisconf-filetags"));
	String identificationCode = parseNull(request.getParameter("identification-code"));
	String iframeDisplay = (parseNull(request.getParameter("iframe-display")).equalsIgnoreCase("on"))? "1":"0";
	String iframeRedirectParent = (parseNull(request.getParameter("iframe-redirect-parent")).equalsIgnoreCase("on"))? "1":"0";
	String biometricConsent = (parseNull(request.getParameter("biometric-consent")).equalsIgnoreCase("on"))? "1":"0";
	String legalHideLink = (parseNull(request.getParameter("hide-link")).equalsIgnoreCase("on"))? "1":"0";
	String legalExternalLink = parseNull(request.getParameter("legal-external-link"));
	String iframeCaptModeDesktop = parseNull(request.getParameter("iframe-capture-mode-desktop"));
	String iframeCaptModeMobile = parseNull(request.getParameter("iframe-capture-mode-mobile"));
	
	
	qry = "INSERT INTO " + GlobalParm.getParm("PORTAL_DB") + ".idcheck_iframe_conf (site_id, success_redirect_url, error_redirect_url, auto_redirect, notification_type, notification_value, realm, fileUid, file_launch_check, file_check_wait, file_tags, ident_code, iframe_display, iframe_redirect_parent, biometric_consent, legal_hide_link, legal_external_link, iframe_capt_mode_desk, iframe_capt_mode_mob) ";
	String valuesPart = "VALUES (" + escape.cote(site_id) + ", " + escape.cote(successRedirectUrl) + ", " + escape.cote(errorRedirectUrl) + ", " + escape.cote(autoRedirect) + ", " + escape.cote(notificationType) + ", " + escape.cote(notificationValue) + ", " + escape.cote(realm) + ", CONCAT("+ escape.cote(realm) +", replace(REPLACE(NOW(), ' ', 'T'),':','')), " + escape.cote(fileLaunchCheck) + ", " + escape.cote(fileCheckWait) + ", " + escape.cote(fileTags) + ", " + escape.cote(identificationCode) + ", " + escape.cote(iframeDisplay) + ", " + escape.cote(iframeRedirectParent) + ", " + escape.cote(biometricConsent) + ", " + escape.cote(legalHideLink) + ", " + escape.cote(legalExternalLink) + ", " + escape.cote(iframeCaptModeDesktop) + ", " + escape.cote(iframeCaptModeMobile) + ")";
	String duplicatePart = " ON DUPLICATE KEY UPDATE"
		+ " success_redirect_url = VALUES(success_redirect_url),"
		+ " error_redirect_url = VALUES(error_redirect_url),"
		+ " auto_redirect = VALUES(auto_redirect),"
		+ " notification_type = VALUES(notification_type),"
		+ " notification_value = VALUES(notification_value),"
		+ " realm = VALUES(realm),"
		+ " fileUid = VALUES(fileUid),"
		+ " file_launch_check = VALUES(file_launch_check),"
		+ " file_check_wait = VALUES(file_check_wait),"
		+ " file_tags = VALUES(file_tags),"
		+ " ident_code = VALUES(ident_code),"
		+ " iframe_display = VALUES(iframe_display),"
		+ " iframe_redirect_parent = VALUES(iframe_redirect_parent),"
		+ " biometric_consent = VALUES(biometric_consent),"
		+ " legal_hide_link = VALUES(legal_hide_link),"
		+ " legal_external_link = VALUES(legal_external_link),"
		+ " iframe_capt_mode_desk = VALUES(iframe_capt_mode_desk),"
		+ " iframe_capt_mode_mob = VALUES(iframe_capt_mode_mob);";

	
	qry = qry + valuesPart + duplicatePart;

	id = Etn.executeCmd(qry);
	config_id=parseNull(id+"");
	
	configRs = Etn.execute("SELECT id FROM " + GlobalParm.getParm("PORTAL_DB") + ".idcheck_iframe_conf WHERE site_id="+escape.cote(site_id));
	configRs.next();
	config_id = parseNull(configRs.value("id"));
	
	
	Etn.executeCmd("DELETE FROM " + GlobalParm.getParm("PORTAL_DB") + ".idcheck_doc_capture_conf where idcheck_iframe_conf_id="+escape.cote(config_id));

	String [] idcheckDocToCaptCode = request.getParameterValues("doc-to-capt-code");
	String [] idcheckDocToCaptType = request.getParameterValues("doc-to-capt-type");
	String [] docCaptOptional = request.getParameterValues("doc-capt-optional");
	String [] versoHandling=request.getParameterValues("verso-handling");
	String [] livenessRefLocation = request.getParameterValues("liveness-ref-location");
	String [] livenessRefValue = request.getParameterValues("liveness-ref-value");
	String [] withDocLiveness=request.getParameterValues("doc-capt-with-liveness");
	String [] livenessLabel = request.getParameterValues("doc-to-capt-label");
	String [] livenessDescription = request.getParameterValues("doc-to-capt-descript");
	try{
		System.out.println("idcheckDocToCaptType: " + idcheckDocToCaptType.length);
		for(int i=0; i<idcheckDocToCaptCode.length; i++)
		{
			if(idcheckDocToCaptCode[i].length()==0) continue;

			String docCaptOptionalCheckBox="0";
			try{
				docCaptOptionalCheckBox = (parseNull(docCaptOptional[i]).equalsIgnoreCase("on"))? "1":"0";
			}catch(Exception e){
				docCaptOptionalCheckBox="0";
			}
			String withDocLivenessCheckBox="0";
			try{
				withDocLivenessCheckBox = (parseNull(withDocLiveness[i]).equalsIgnoreCase("on"))? "1":"0";
			}catch(Exception e){
				withDocLivenessCheckBox = "0";
			}
		
			String dataConfQuery = "INSERT INTO " + GlobalParm.getParm("PORTAL_DB") + ".idcheck_doc_capture_conf (idcheck_iframe_conf_id, capture_code, doc_type, optional, verso_handling, liveness_ref_location, liveness_ref_value, with_doc_liveness, liveness_label, liveness_description) ";
			String dataConfValuesPart = "VALUES ("+escape.cote(config_id)+", " + escape.cote(parseNull(idcheckDocToCaptCode[i])) + ", " + escape.cote(parseNull(idcheckDocToCaptType[i])) + ", " + escape.cote(docCaptOptionalCheckBox) + ", " + escape.cote(parseNull(versoHandling[i])) + ", " + escape.cote(parseNull(livenessRefLocation[i])) + ", " + escape.cote(parseNull(livenessRefValue[i])) + ", " + escape.cote(parseNull(withDocLivenessCheckBox)) + ", " + escape.cote(parseNull(livenessLabel[i])) + ", " + escape.cote(parseNull(livenessDescription[i])) + ")";

			qry = dataConfQuery + dataConfValuesPart;
			if(Etn.executeCmd(qry)>0)
				System.out.println("Row inserted");
			else
				System.out.println("Row not inserted");
			}
	}catch(Exception e){
		if(idCheckActivated.equals("1")){
			out.write("{\"success\":10, \"errmsg\":\"There should be Atleast One Document To Capture\"}");
			return;
		}
	}


	
    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"","UPDATED","Module Parameters","",site_id);
	out.write("{\"success\":0}");
%>
