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
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.io.File"%>
<%@ page import="com.etn.asimina.util.UIHelper"%>

<%@ include file="../common2.jsp"%>


<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>


<!DOCTYPE html>

<html>
<head>
	<title>Define Templates</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

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
<body class="c-app header-fixed sidebar-fixed sidebar-lg-show">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
<%@ include file="/WEB-INF/include/header.jsp" %>
<div class="c-body">

<%!
	String readDataFromFile(String path){

		StringBuffer outputFileData = new StringBuffer();
		String html = "";

		try{
			System.out.println(path);
			File f = new File(path);

			if(f.exists() && !f.isDirectory()){
	

				BufferedReader in = new BufferedReader(new FileReader(path));
				String data = in.readLine();

				while(data != null){
					
					outputFileData.append(data).append("\n");
					data = in.readLine();
				}

				html = outputFileData.toString();
				if(html.length() > 0){
					
					String startingBoundary = "Content-Type: multipart/alternative;\n boundary=\"------------010101080201020804090106\"\n\nThis is a multi-part message in MIME format.\n--------------010101080201020804090106\nContent-Type: text/html; charset=utf-8\nContent-Transfer-Encoding: 7bit\n\n\n";

					int startIndex = html.toString().indexOf(startingBoundary);
					int endIndex = html.toString().indexOf("--------------010101080201020804090106--");

					html = html.toString().substring(startIndex + startingBoundary.length(), endIndex);
				}
			}
		} catch(Exception e){
			
			e.printStackTrace();
		}
		
		if(html.length() > 0) return html;
		
		return "";
	}

	void writeDataInFile(String path, String data, String formName){

		PrintWriter pw = null;

		try{

			String html = "Content-Type: multipart/alternative;\n boundary=\"------------010101080201020804090106\"\n\nThis is a multi-part message in MIME format.\n--------------010101080201020804090106\nContent-Type: text/html; charset=utf-8\nContent-Transfer-Encoding: 7bit\n\n\n";
			html += "<div id=\"" + formName + "_template_div\">\n"+data+"\n</div>";
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
%>
<%
	String filePath = com.etn.beans.app.GlobalParm.getParm("MAIL_UPLOAD_PATH") + "mail";
	String formId = parseNull(request.getParameter("fid"));
	String isSave = parseNull(request.getParameter("isSave"));
	String formName = "";
	String tableName = "";
	String isUpdate = parseNull(request.getParameter("isUpdate"));
	String configurationExists = "";

	String isCustomerEmail = parseNull(request.getParameter("config_cust_email"));
	String isBackOfficeEmail = parseNull(request.getParameter("config_bk_ofc_email"));
	String backOfficeEmail = parseNull(request.getParameter("lang_email"));

	if(backOfficeEmail.length() > 0) {

		backOfficeEmail = backOfficeEmail.replaceAll(";", ":");
		backOfficeEmail = backOfficeEmail.replaceAll(",", ":");
		backOfficeEmail = "nomail," + backOfficeEmail;
	} 

	String langCode1 = parseNull(request.getParameter("lang_1_code"));
	String langCode2 = parseNull(request.getParameter("lang_2_code"));
	String langCode3 = parseNull(request.getParameter("lang_3_code"));
	String langCode4 = parseNull(request.getParameter("lang_4_code"));
	String langCode5 = parseNull(request.getParameter("lang_5_code"));

	String customerEmailSubject1 = parseNull(request.getParameter("lang_1_subj"));
	String customerEmailSubject2 = parseNull(request.getParameter("lang_2_subj"));
	String customerEmailSubject3 = parseNull(request.getParameter("lang_3_subj"));
	String customerEmailSubject4 = parseNull(request.getParameter("lang_4_subj"));
	String customerEmailSubject5 = parseNull(request.getParameter("lang_5_subj"));

	String customerTemplate1 = parseNull(request.getParameter("lang_1_template"));
	String customerTemplate2 = parseNull(request.getParameter("lang_2_template"));
	String customerTemplate3 = parseNull(request.getParameter("lang_3_template"));
	String customerTemplate4 = parseNull(request.getParameter("lang_4_template"));
	String customerTemplate5 = parseNull(request.getParameter("lang_5_template"));
	

	String backOfficeEmailSubject1 = parseNull(request.getParameter("lang_1_back_office_subj"));
	String backOfficeEmailSubject2 = parseNull(request.getParameter("lang_2_back_office_subj"));
	String backOfficeEmailSubject3 = parseNull(request.getParameter("lang_3_back_office_subj"));
	String backOfficeEmailSubject4 = parseNull(request.getParameter("lang_4_back_office_subj"));
	String backOfficeEmailSubject5 = parseNull(request.getParameter("lang_5_back_office_subj"));

	String backOfficeTemplate1 = parseNull(request.getParameter("lang_1_back_office_template"));
	String backOfficeTemplate2 = parseNull(request.getParameter("lang_2_back_office_template"));
	String backOfficeTemplate3 = parseNull(request.getParameter("lang_3_back_office_template"));
	String backOfficeTemplate4 = parseNull(request.getParameter("lang_4_back_office_template"));
	String backOfficeTemplate5 = parseNull(request.getParameter("lang_5_back_office_template"));

	String lang_tab = parseNull(request.getParameter("lang_tab"));
	
	if(lang_tab.length() == 0){
		
		lang_tab = "lang1show";
	} 

	Set rsl = Etn.execute("select * from language order by langue_id ");
	String lang_1 = "", lang_2 = "", lang_3= "", lang_4 = "", lang_5 = "";
	String lang_1_lbl = "", lang_2_lbl = "", lang_3_lbl= "", lang_4_lbl = "", lang_5_lbl = "";
	int _j = 0;

	while(rsl.next())
	{
		if(_j == 0)
		{
			lang_1 = parseNull(rsl.value("langue_code"));
			lang_1_lbl = parseNull(rsl.value("langue"));
		}
		else if(_j == 1)
		{
			lang_2 = parseNull(rsl.value("langue_code"));
			lang_2_lbl = parseNull(rsl.value("langue"));
		}
		else if(_j == 2)
		{
			lang_3 = parseNull(rsl.value("langue_code"));
			lang_3_lbl = parseNull(rsl.value("langue"));
		}
		else if(_j == 3)
		{
			lang_4 = parseNull(rsl.value("langue_code"));
			lang_4_lbl = parseNull(rsl.value("langue"));
		}
		else if(_j == 4)
		{
			lang_5 = parseNull(rsl.value("langue_code"));
			lang_5_lbl = parseNull(rsl.value("langue"));
		}
		_j++;
	}

	Set formRs = Etn.execute("SELECT * FROM process_forms WHERE form_id = " + escape.cote(formId));

	if(formRs.next()) {

		formName = parseNull(formRs.value("process_name"));
		tableName = parseNull(formRs.value("table_name"));
	}

	String query = "";
	String values = "";
	int customerMailId = 0;
	int backofficeMailId = 0;

	if(isCustomerEmail.equals("on")) isCustomerEmail = "1";
	else isCustomerEmail = "0";

	if(isBackOfficeEmail.equals("on")) isBackOfficeEmail = "1";
	else isBackOfficeEmail = "0";

	formRs.moveFirst();
	if(formRs.next()){
		
		customerMailId = parseNullInt(formRs.value("cust_eid"));
		backofficeMailId = parseNullInt(formRs.value("bk_ofc_eid"));
	}

	Set updateConfigRs = Etn.execute("SELECT * FROM mails WHERE id IN (" + escape.cote(""+customerMailId) + "," + escape.cote(""+backofficeMailId) + ") ");

	if(updateConfigRs.rs.Rows > 0) configurationExists = "yes";

	boolean flag = false;

	if(isUpdate.length() > 0 && isUpdate.equals("update")){

		query = "UPDATE mails SET sujet = " + escape.cote(customerEmailSubject1) + ", sujet_lang_2 = " + escape.cote(customerEmailSubject2) + ", sujet_lang_3 = " + escape.cote(customerEmailSubject3) + ", sujet_lang_4 = " + escape.cote(customerEmailSubject4) + ", sujet_lang_5 = " + escape.cote(customerEmailSubject5) + " WHERE id = " + escape.cote(""+customerMailId);

		Etn.executeCmd(query);

		query = "UPDATE mails SET sujet = " + escape.cote(backOfficeEmailSubject1) + ", sujet_lang_2 = " + escape.cote(backOfficeEmailSubject2) + ", sujet_lang_3 = " + escape.cote(backOfficeEmailSubject3) + ", sujet_lang_4 = " + escape.cote(backOfficeEmailSubject4) + ", sujet_lang_5 = " + escape.cote(backOfficeEmailSubject5) + " WHERE id = " + escape.cote(""+backofficeMailId);

		Etn.executeCmd(query);

		query = "UPDATE mail_config SET email_to = " + escape.cote(backOfficeEmail) + " WHERE id = " + escape.cote(""+backofficeMailId);

		Etn.executeCmd(query);

		query = "UPDATE process_forms SET is_email_cust = " + escape.cote(isCustomerEmail) + ", is_email_bk_ofc = " + escape.cote(isBackOfficeEmail) + " WHERE form_id = " + escape.cote(formId);

		Etn.executeCmd(query);

		String actionConfig = "";

		if(isCustomerEmail.equals("1")) actionConfig = "mail:" + customerMailId;

		if(isBackOfficeEmail.equals("1")) {

			if(actionConfig.length() > 0)
				actionConfig += ",mail:" + backofficeMailId;
			else
				actionConfig = "mail:" + backofficeMailId;
		}

		if(actionConfig.length() > 0) actionConfig += ",sql:processNow";

		Etn.executeCmd("UPDATE has_action SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName));

		Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("FormSubmitted") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote("EmailSent"));

		if(customerMailId > 0) {

			if(customerTemplate1.length() > 0){

				if(lang_1.length() > 0) 
					writeDataInFile(filePath+customerMailId, customerTemplate1, formName);
			}

			if(customerTemplate2.length() > 0){

				if(lang_2.length() > 0) 
					writeDataInFile(filePath+customerMailId+"_"+lang_2, customerTemplate2, formName);
			}
			
			if(customerTemplate3.length() > 0){

				if(lang_3.length() > 0) 
					writeDataInFile(filePath+customerMailId+"_"+lang_3, customerTemplate3, formName);
			}
			
			if(customerTemplate4.length() > 0){

				if(lang_4.length() > 0) 
					writeDataInFile(filePath+customerMailId+"_"+lang_4, customerTemplate4, formName);
			}
			
			if(customerTemplate5.length() > 0){

				if(lang_5.length() > 0) 
					writeDataInFile(filePath+customerMailId+"_"+lang_5, customerTemplate5, formName);
			}
		}

		if(backofficeMailId > 0){

System.out.println(backofficeMailId+":");
System.out.println(backOfficeTemplate1.length()+":");
System.out.println(lang_1.length()+":");

			if(backOfficeTemplate1.length() > 0){
				
				if(lang_1.length() > 0) 
					writeDataInFile(filePath+backofficeMailId, backOfficeTemplate1, formName);
			}
			
			if(backOfficeTemplate2.length() > 0){

				if(lang_2.length() > 0) 
					writeDataInFile(filePath+backofficeMailId+"_"+lang_2, backOfficeTemplate2, formName);

			}
			
			if(backOfficeTemplate3.length() > 0){

				if(lang_3.length() > 0) 
					writeDataInFile(filePath+backofficeMailId+"_"+lang_3, backOfficeTemplate3, formName);
			}
			
			if(backOfficeTemplate4.length() > 0){

				if(lang_4.length() > 0) 
					writeDataInFile(filePath+backofficeMailId+"_"+lang_4, backOfficeTemplate4, formName);
			}
			
			if(backOfficeTemplate5.length() > 0){

				if(lang_5.length() > 0) 
					writeDataInFile(filePath+backofficeMailId+"_"+lang_5, backOfficeTemplate5, formName);
			}
		}

	} else if(isSave.length() > 0 && isSave.equals("save")) {
		
		customerMailId = 0;
		backofficeMailId = 0;

		query = "INSERT INTO mails(sujet, sujet_lang_2, sujet_lang_3, sujet_lang_4, sujet_lang_5) VALUES";


		customerMailId = Etn.executeCmd(query + "(" + escape.cote(customerEmailSubject1) + "," + escape.cote(customerEmailSubject2) + "," + escape.cote(customerEmailSubject3) + "," + escape.cote(customerEmailSubject4) + "," + escape.cote(customerEmailSubject5) + ")");

		backofficeMailId = Etn.executeCmd(query + "(" + escape.cote(backOfficeEmailSubject1) + "," + escape.cote(backOfficeEmailSubject2) + "," + escape.cote(backOfficeEmailSubject3) + "," + escape.cote(backOfficeEmailSubject4) + "," + escape.cote(backOfficeEmailSubject5) + ")");

		if(customerMailId > 0){

			Etn.executeCmd("UPDATE process_forms SET is_email_cust = " + escape.cote(isCustomerEmail) + ", is_email_bk_ofc = " + escape.cote(isBackOfficeEmail) + ", cust_eid = " + escape.cote(""+customerMailId) + ", bk_ofc_eid = " + escape.cote(""+backofficeMailId) + " WHERE form_id = " + escape.cote(formId));

			if(customerTemplate1.length() > 0){

				if(lang_1.length() > 0) 
					writeDataInFile(filePath+customerMailId, customerTemplate1, formName);
			}
			
			
			if(customerTemplate2.length() > 0){

				if(lang_2.length() > 0) 
					writeDataInFile(filePath+customerMailId+"_"+lang_2, customerTemplate2, formName);
			}
			
			if(customerTemplate3.length() > 0){

				if(lang_3.length() > 0) 
					writeDataInFile(filePath+customerMailId+"_"+lang_3, customerTemplate3, formName);
			}
			
			if(customerTemplate4.length() > 0){

				if(lang_4.length() > 0) 
					writeDataInFile(filePath+customerMailId+"_"+lang_4, customerTemplate4, formName);
			}
			
			if(customerTemplate5.length() > 0){

				if(lang_5.length() > 0) 
					writeDataInFile(filePath+customerMailId+"_"+lang_5, customerTemplate5, formName);
			}
		}

		if(backofficeMailId > 0){
			
			Etn.executeCmd("INSERT INTO mail_config(id, ordertype, email_to, attach) VALUES (" + escape.cote(""+backofficeMailId) + ", " + escape.cote(tableName) + ", " + escape.cote(backOfficeEmail) + "," + escape.cote("upload_mail") + ")");
			
			if(backOfficeTemplate1.length() > 0){
				
				if(lang_1.length() > 0) 
					writeDataInFile(filePath+backofficeMailId, backOfficeTemplate1, formName);
			}
			
			if(backOfficeTemplate2.length() > 0){

				if(lang_2.length() > 0) 
					writeDataInFile(filePath+backofficeMailId+"_"+lang_2, backOfficeTemplate2, formName);

			}
			
			if(backOfficeTemplate3.length() > 0){

				if(lang_3.length() > 0) 
					writeDataInFile(filePath+backofficeMailId+"_"+lang_3, backOfficeTemplate3, formName);
			}
			
			if(backOfficeTemplate4.length() > 0){

				if(lang_4.length() > 0) 
					writeDataInFile(filePath+backofficeMailId+"_"+lang_4, backOfficeTemplate4, formName);
			}
			
			if(backOfficeTemplate5.length() > 0){

				if(lang_5.length() > 0) 
					writeDataInFile(filePath+backofficeMailId+"_"+lang_5, backOfficeTemplate5, formName);
			}
		}
		
		Set rulesRs = Etn.execute("SELECT cle FROM rules WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("FormSubmitted") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote("EmailSent"));
		
		String cleId = "";

		if(rulesRs.next()) cleId = parseNull(rulesRs.value("cle"));
		
		String actionConfig = "";

		if(isCustomerEmail.equals("1")) actionConfig = "mail:" + customerMailId;

		if(isBackOfficeEmail.equals("1")) {

			if(actionConfig.length() > 0)
				actionConfig += ",mail:" + backofficeMailId;
			else
				actionConfig = "mail:" + backofficeMailId;
		}

		if(actionConfig.length() > 0) actionConfig += ",sql:processNow";

		Etn.executeCmd("INSERT INTO has_action(start_proc, start_phase, cle, action) VALUES(" + escape.cote(tableName) + "," + escape.cote("FormSubmitted") + "," + escape.cote(cleId) + "," + escape.cote(actionConfig) + ")");

		Etn.executeCmd("UPDATE rules SET action = " + escape.cote(actionConfig) + " WHERE start_proc = " + escape.cote(tableName) + " AND start_phase = " + escape.cote("FormSubmitted") + " AND errCode = " + escape.cote("0") + " AND next_proc = " + escape.cote(tableName) + " AND next_phase = " + escape.cote("EmailSent"));
	}

	formRs = Etn.execute("SELECT * FROM process_forms WHERE form_id = " + escape.cote(formId));

	if(formRs.next()){
		
		isCustomerEmail = parseNull(formRs.value("is_email_cust"));
		isBackOfficeEmail = parseNull(formRs.value("is_email_bk_ofc"));
		customerMailId = parseNullInt(formRs.value("cust_eid"));
		backofficeMailId = parseNullInt(formRs.value("bk_ofc_eid"));
	}

	Set mailsRs = Etn.execute("SELECT * FROM mails m WHERE id = " + escape.cote(""+customerMailId));
	if(mailsRs.next()){
		
		customerEmailSubject1 = parseNull(mailsRs.value("sujet"));
		customerEmailSubject2 = parseNull(mailsRs.value("sujet_lang_2"));
		customerEmailSubject3 = parseNull(mailsRs.value("sujet_lang_3"));
		customerEmailSubject4 = parseNull(mailsRs.value("sujet_lang_4"));
		customerEmailSubject5 = parseNull(mailsRs.value("sujet_lang_5"));
	}

	Set mailConfgRs = Etn.execute("SELECT * FROM mails m, mail_config mc WHERE m.id = mc.id AND mc.ordertype = " + escape.cote(tableName));
	if(mailConfgRs.next()){
		
		backOfficeEmail = parseNull(mailConfgRs.value("email_to"));

		if(backOfficeEmail.length() > 7) backOfficeEmail = backOfficeEmail.substring(7, backOfficeEmail.length());

		backOfficeEmailSubject1 = parseNull(mailConfgRs.value("sujet"));
		backOfficeEmailSubject2 = parseNull(mailConfgRs.value("sujet_lang_2"));
		backOfficeEmailSubject3 = parseNull(mailConfgRs.value("sujet_lang_3"));
		backOfficeEmailSubject4 = parseNull(mailConfgRs.value("sujet_lang_4"));
		backOfficeEmailSubject5 = parseNull(mailConfgRs.value("sujet_lang_5"));
	}


	if(lang_1.length() > 0){
		
		customerTemplate1 = readDataFromFile(filePath+customerMailId);
		backOfficeTemplate1 = readDataFromFile(filePath+backofficeMailId);
	} 
	if(lang_2.length() > 0) {

		customerTemplate2 = readDataFromFile(filePath+customerMailId+"_"+lang_2);
		backOfficeTemplate2 = readDataFromFile(filePath+backofficeMailId+"_"+lang_2);
	}
	
	if(lang_3.length() > 0) {

		customerTemplate3 = readDataFromFile(filePath+customerMailId+"_"+lang_3);
		backOfficeTemplate3 = readDataFromFile(filePath+backofficeMailId+"_"+lang_3);
	}

	if(lang_4.length() > 0) {

		customerTemplate4 = readDataFromFile(filePath+customerMailId+"_"+lang_4);
		backOfficeTemplate4 = readDataFromFile(filePath+backofficeMailId+"_"+lang_4);
	}
	
	if(lang_5.length() > 0){
		
		customerTemplate5 = readDataFromFile(filePath+customerMailId+"_"+lang_5);
		backOfficeTemplate5 = readDataFromFile(filePath+backofficeMailId+"_"+lang_5);
	} 

	updateConfigRs = Etn.execute("SELECT * FROM mails WHERE id IN (" + escape.cote(""+customerMailId) + "," + escape.cote(""+backofficeMailId) + ") ");

	if(updateConfigRs.rs.Rows > 0) configurationExists = "yes";


	Set ffrs = Etn.execute("SELECT * FROM process_form_fields WHERE form_id = " + escape.cote(formId) + " AND type = " + escape.cote("email"));
	Set formFieldsRs = Etn.execute("SELECT db_column_name FROM process_form_fields WHERE form_id = " + escape.cote(formId) + " AND db_column_name IS NOT NULL AND db_column_name != '';");

%>

<main class="c-main" style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">Define Templates</h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-primary" id="saveBtn" onclick='goback();'>Back</button>
					<button type="button" class="btn btn-primary" id="saveBtn" onclick='onsave();'>Save</button>
				</div>
			</div>
			<!-- /buttons bar -->
		</div>
	<!-- /title -->

	<!-- container -->
	<div class="container-fluid">
		<div class="animated fadeIn">
			<div>
				<form id="config_email_frm" name="config_email_frm" enctype="application/x-www-form-urlencoded" method="post">

					<div style='font-weight:bold; font-size:16px; margin-top:25px'>
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" style="margin-top: 10px;">
							<input <% if( isCustomerEmail.equals("1") ){ %> checked="checked" <% } %> type="checkbox" id="config_cust_email" name="config_cust_email" style="width: 20px; margin-bottom: 5px;"> 
							<span>Configure customer email</span>
						</div>
						<div class="col-sm-12" style="margin-top: 50px; margin-bottom: 30px;">
							<table id="languagetable" cellpadding="0" cellspacing="0" border="0" style="margin-bottom: 10px;">
								<tr>
									<%if(lang_1.length() > 0){%><td><a id='tab_lang1show' href='javascript:selecttab("lang1show")' style='text-decoration:none; color: #3170A6;border: 1px solid #BCE8F1;padding: 10px;padding-left: 60px;padding-right: 60px;'><%=lang_1_lbl%></a><input type="hidden" name="lang_1_code" value="<%= lang_1%>" /></td><%}%>
									<%if(lang_2.length() > 0){%><td><a id='tab_lang2show' href='javascript:selecttab("lang2show")' style='text-decoration:none; color: #3170A6;border: 1px solid #BCE8F1;padding: 10px;padding-left: 60px;padding-right: 60px;'><%=lang_2_lbl%></a><input type="hidden" name="lang_2_code" value="<%= lang_2%>" /></td><%}%>
									<%if(lang_3.length() > 0){%><td><a id='tab_lang3show' href='javascript:selecttab("lang3show")' style='text-decoration:none; color: #3170A6;border: 1px solid #BCE8F1;padding: 10px;padding-left: 60px;padding-right: 60px;'><%=lang_3_lbl%></a><input type="hidden" name="lang_3_code" value="<%= lang_3%>" /></td><%}%>
									<%if(lang_4.length() > 0){%><td><a id='tab_lang4show' href='javascript:selecttab("lang4show")' style='text-decoration:none; color: #3170A6;border: 1px solid #BCE8F1;padding: 10px;padding-left: 60px;padding-right: 60px;'><%=lang_4_lbl%></a><input type="hidden" name="lang_4_code" value="<%= lang_4%>" /></td><%}%>
									<%if(lang_5.length() > 0){%><td><a id='tab_lang5show' href='javascript:selecttab("lang5show")' style='text-decoration:none; color: #3170A6;border: 1px solid #BCE8F1;padding: 10px;padding-left: 60px;padding-right: 60px;'><%=lang_5_lbl%></a><input type="hidden" name="lang_5_code" value="<%= lang_5%>" /></td><%}%>
								</tr>
							</table>
						</div>
					</div>

					<table cellpadding="0" cellspacing="0" border="0" width="100%">

						<tr>
							<td style="font-weight: bold;text-align: right;padding: 10px;width: 15%;">Subject</td>
							<td>
								<input class="lang1show form-control" type='text' name='lang_1_subj' id='lang_1_subj' value='<%= UIHelper.escapeCoteValue(customerEmailSubject1)%>' maxlength='255'/>
								<input class="lang2show form-control" type='text' name='lang_2_subj' id='lang_2_subj' value='<%= UIHelper.escapeCoteValue(customerEmailSubject2)%>' maxlength='255'/>
								<input class="lang3show form-control" type='text' name='lang_3_subj' id='lang_3_subj' value='<%= UIHelper.escapeCoteValue(customerEmailSubject3)%>' maxlength='255'/>
								<input class="lang4show form-control" type='text' name='lang_4_subj' id='lang_4_subj' value='<%= UIHelper.escapeCoteValue(customerEmailSubject4)%>' maxlength='255'/>
								<input class="lang5show form-control" type='text' name='lang_5_subj' id='lang_5_subj' value='<%= UIHelper.escapeCoteValue(customerEmailSubject5)%>' maxlength='255'/>
							</td>
						</tr>

						<tr>
							<td style="font-weight: bold;text-align: right;padding: 10px;width: 15%;">Template</td>
							<td class="lang1showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_1_template" id="lang_1_template"><%= UIHelper.escapeCoteValue(customerTemplate1)%></textarea>
							</td>
							<td class="lang2showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_2_template" id="lang_2_template"><%= UIHelper.escapeCoteValue(customerTemplate2)%></textarea>
							</td>
							<td class="lang3showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_3_template" id="lang_3_template"><%= UIHelper.escapeCoteValue(customerTemplate3)%></textarea>
							</td>
							<td class="lang4showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_4_template" id="lang_4_template"><%= UIHelper.escapeCoteValue(customerTemplate4)%></textarea>
							</td>
							<td class="lang5showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_5_template" id="lang_5_template"><%= UIHelper.escapeCoteValue(customerTemplate5)%></textarea>
							</td>
							<td style="padding-left: 50px; vertical-align: top;">
								<div style="width: 150px;">
									<label style="font-weight: bold; margin-bottom: 20px;">Created columns</label>
									<div style="width: 100%; height: 375px; list-style: none; overflow: scroll;">
							<%
								while(formFieldsRs.next()){
							%>
										<p style="margin-bottom: 1px;"> <%= formFieldsRs.value("db_column_name")%> </p>
							<%
								}
							%>
									</div>
								</div>
							</td>
						</tr>
					</table>

					<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" style="margin-top: 50px;">
						<input <% if( isBackOfficeEmail.equals("1") ){ %> checked="checked" <% } %> type="checkbox" id="config_bk_ofc_email" name="config_bk_ofc_email" style="width: 20px; margin-bottom: 5px;"> 
						<span style="font-weight: bold;">Configure back office email</span>
					</div>

					<table cellpadding="0" cellspacing="0" border="0" width="100%">

						<tr>
							<td style="font-weight: bold;text-align: right;padding: 10px;width: 15%;">
								Email
								<span id="lang_bkofc_email_span" style="color: red; visibility: hidden;">*</span>
							</td>
							<td>
								<input class="form-control" type='text' name='lang_email' id='lang_email' value='<%= UIHelper.escapeCoteValue(backOfficeEmail)%>' maxlength='255'/>
							</td>
						</tr>
						<tr>
							<td style="font-weight: bold;text-align: right;padding: 10px;width: 15%;">Subject</td>
							<td>
								<input class="lang1show form-control" type='text' name='lang_1_back_office_subj' id='lang_1_back_office_subj' value='<%= UIHelper.escapeCoteValue(backOfficeEmailSubject1)%>' maxlength='255'/>
								<input class="lang2show form-control" type='text' name='lang_2_back_office_subj' id='lang_2_back_office_subj' value='<%= UIHelper.escapeCoteValue(backOfficeEmailSubject2)%>' maxlength='255'/>
								<input class="lang3show form-control" type='text' name='lang_3_back_office_subj' id='lang_3_back_office_subj' value='<%= UIHelper.escapeCoteValue(backOfficeEmailSubject3)%>' maxlength='255'/>
								<input class="lang4show form-control" type='text' name='lang_4_back_office_subj' id='lang_4_back_office_subj' value='<%= UIHelper.escapeCoteValue(backOfficeEmailSubject4)%>' maxlength='255'/>
								<input class="lang5show form-control" type='text' name='lang_5_back_office_subj' id='lang_5_back_office_subj' value='<%= UIHelper.escapeCoteValue(backOfficeEmailSubject5)%>' maxlength='255'/>
							</td>
						</tr>
						<tr>
							<td style="font-weight: bold;text-align: right;padding: 10px;width: 15%;">Template</td>
							<td class="lang1showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_1_back_office_template" id="lang_1_back_office_template"><%= UIHelper.escapeCoteValue(backOfficeTemplate1)%></textarea>
							</td>
							<td class="lang2showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_2_back_office_template" id="lang_2_back_office_template"><%= UIHelper.escapeCoteValue(backOfficeTemplate2)%></textarea>
							</td>
							<td class="lang3showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_3_back_office_template" id="lang_3_back_office_template"><%= UIHelper.escapeCoteValue(backOfficeTemplate3)%></textarea>
							</td>
							<td class="lang4showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_4_back_office_template" id="lang_4_back_office_template"><%= UIHelper.escapeCoteValue(backOfficeTemplate4)%></textarea>
							</td>
							<td class="lang5showta" style="display: none;">
								<textarea class="ckeditor_field" style="height: 350px;" rows="5" name="lang_5_back_office_template" id="lang_5_back_office_template"><%= UIHelper.escapeCoteValue(backOfficeTemplate5)%></textarea>
							</td>
							<td style="padding-left: 50px; vertical-align: top;">
								<div style="width: 150px;">
									<label style="font-weight: bold; margin-bottom: 20px;">Created columns</label>
									<div style="width: 100%; height: 375px; list-style: none; overflow: scroll;">
							<%
								formFieldsRs.moveFirst();
								while(formFieldsRs.next()){
							%>
										<p style="margin-bottom: 1px;"> <%= formFieldsRs.value("db_column_name")%> </p>
							<%
								}
							%>
									</div>
								</div>
							</td>
						</tr>
					</table>

					<%
						if(configurationExists.length() > 0 && configurationExists.equals("yes")){
					%>
							<input type="hidden" name="isUpdate" value="update" />
					<%
						} else {
					%>
							<input type="hidden" name="isSave" value="save" />
					<%
						}
					%>
					<input type="hidden" id="is_email_field_exists" value="<%= ffrs.rs.Rows%>">
				</form>
			</div>
			<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
		</div>
	</div>
	<br>

</main>
</div>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

	<script type="text/javascript">
		
		jQuery(document).ready(function() {

			$("#config_cust_email").on("click", function(){

				var isEmailExists = $("#is_email_field_exists").val();
				if($(this).is(":checked") && isEmailExists.length > 0) {
					if(parseInt(isEmailExists) == 0){
						alert("Email won't be sent to client as no email field provided.");
					}
				}
			});

			$("#config_bk_ofc_email").on("click", function(){

				if($(this).is(":checked")) {
					$("#lang_bkofc_email_span").css("visibility", "visible");
				}else{
					$("#lang_bkofc_email_span").css("visibility", "hidden");					
				}
			});

			onsave = function(){

				if($("#config_bk_ofc_email").is(":checked") && $("#lang_email").val().length == 0){
					alert("Kindly provide backoffce email");
					$("#lang_email").focus();
					return false;
				}

				$("#config_email_frm").submit();
			}

			goback = function(){

				window.location = "process.jsp";
			}

			selecttab=function(tab) {

				$(".lang1show").hide();
				$(".lang2show").hide();
				$(".lang3show").hide();
				$(".lang4show").hide();
				$(".lang5show").hide();
	
				$("#tab_lang1show").css("background","");
				$("#tab_lang2show").css("background","");
				$("#tab_lang3show").css("background","");
				$("#tab_lang4show").css("background","");
				$("#tab_lang5show").css("background","");

				$(".lang1showta").css("display","none");
				$(".lang2showta").css("display","none");
				$(".lang3showta").css("display","none");
				$(".lang4showta").css("display","none");
				$(".lang5showta").css("display","none");

				$("."+tab).show();
				$("."+tab+"ta").css("display", "table-cell");
				$("#tab_" + tab).css("background","#D9EDF7");
			};

			selecttab('<%=UIHelper.escapeCoteValue(lang_tab)%>');
		});

		CKEDITOR.replaceAll('ckeditor_field');

		$(".ckeditor_field").each(function(){
			var _id = $(this).attr('id');
			var vl = CKEDITOR.instances[_id].getData();

			//alert(_id);

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


	</script>
</div>
</body>
</html>

