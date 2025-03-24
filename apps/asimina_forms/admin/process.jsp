<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.ActivityLog"%>
<%@ page import="com.etn.asimina.beans.Language"%>
<%@ page import="com.etn.asimina.util.UrlHelper"%>
<%@ include file="../common2.jsp"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%!

    void deleteForm(com.etn.beans.Contexte Etn,String id,String siteId){
		Set deleteProcessRs = Etn.execute("SELECT table_name, process_name, site_id FROM "+GlobalParm.getParm("FORMS_DB")+
			".process_forms_unpublished_tbl WHERE form_id = " + 
			escape.cote(id) + " and site_id = " + escape.cote(siteId));

		if(deleteProcessRs.next()) {

			String tblName = parseNull(deleteProcessRs.value("table_name"));		

			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".coordinates where process = " + escape.cote(tblName));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".rules WHERE start_proc = " + escape.cote(tblName) + 
				" AND next_proc = " + escape.cote(tblName));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".phases WHERE process = " + escape.cote(tblName));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".has_action WHERE start_proc = " + escape.cote(tblName));

			Etn.executeCmd("DELETE m FROM "+GlobalParm.getParm("FORMS_DB")+".mails_unpublished m INNER JOIN "+
				GlobalParm.getParm("FORMS_DB")+".mail_config_unpublished mc ON m.id = mc.id "+
				"INNER JOIN "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl pf ON mc.ordertype = pf.table_name WHERE pf.form_id = " + 
					escape.cote(id));

			Etn.executeCmd("DELETE mc FROM "+GlobalParm.getParm("FORMS_DB")+".mail_config_unpublished mc INNER JOIN "+
				GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl pf ON mc.ordertype = pf.table_name "+
				"WHERE pf.form_id = " + escape.cote(id));

			Etn.executeCmd("DELETE fr FROM "+GlobalParm.getParm("FORMS_DB")+".freq_rules_unpublished fr INNER JOIN "+
				GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl pf ON fr.form_id = pf.form_id "+
				"WHERE pf.form_id = " + escape.cote(id));

			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_form_field_descriptions_unpublished WHERE form_id = " + escape.cote(id));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_form_fields_unpublished WHERE form_id = " + escape.cote(id));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_form_lines_unpublished WHERE form_id = " + escape.cote(id));
			Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_form_fields_unpublished WHERE form_id = " + escape.cote(id));

			Set rsExists = Etn.execute("SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = "+
				escape.cote(GlobalParm.getParm("FORMS_DB"))+" AND TABLE_TYPE LIKE 'BASE TABLE' AND TABLE_NAME = "+ escape.cote(tblName));

			if(rsExists.next()){
				long millis = System.currentTimeMillis();

				Etn.execute("Alter table "+GlobalParm.getParm("FORMS_DB")+"."+tblName+" rename to "+GlobalParm.getParm("FORMS_DB")+".del_"+millis);

				Etn.executeCmd("insert into "+GlobalParm.getParm("FORMS_DB")+".original_forms_names (site_id, table_name,table_new_name) values("+escape.cote(siteId)+", "+escape.cote(tblName)+","+escape.cote("del_"+millis)+")");
			}else{
				Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl WHERE form_id = " + escape.cote(id));
			}
		}
	}

    String getFomPublishStatus(com.etn.beans.Contexte Etn, String formId)
    {
        String status = "NOT_PUBLISHED";
        Set rs = Etn.execute("select * from process_forms where form_id = " + escape.cote(formId));
        if(rs.rs.Rows == 0)
        {
            return status;
        }
        status = "PUBLISHED";

        rs = Etn.execute("select case when pfp.version = pf.version then '1' else '0' end from process_forms_unpublished pfp, process_forms pf where pfp.form_id = pf.form_id and pfp.form_id = " + escape.cote(formId));
        rs.next();
        if(rs.value(0).equals("0"))
        {
            status = "NEEDS_PUBLISH";
        }
        return status;
    }
%>

<%

    String selectedSiteId = getSelectedSiteId(session);
    List<Language> langsList = getLangs(Etn,selectedSiteId);
    String isSave = parseNull(request.getParameter("is_save"));
    String deleteUploads = parseNull(request.getParameter("delete-uploads"));
    String isEdit = parseNull(request.getParameter("is_edit"));
    String deleteIds = parseNull(request.getParameter("delete_id"));
    String formId = parseNull(request.getParameter("form_id"));
    String processName = parseNull(request.getParameter("process_name"));
	
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
    String formJs = parseNull(request.getParameter("form_js"));
    String formCss = parseNull(request.getParameter("form_css"));
    String PAGES_DB = parseNull(GlobalParm.getParm("PAGES_DB"));

    if(deleteUploads.length()>0) deleteUploads = "1";
    else deleteUploads = "0";
    String logedInUserId = parseNull(Integer.toString(Etn.getId()));

    String errorMsg = "";

    if(formJs.length() > 0){

        formJs = formJs.replaceAll("\"", "&quot;");
    }

    Language defaultLanguage = langsList.get(0);
    
    if(isSave.length() > 0 && isSave.equals("1") && formId.length() == 0 ){
		
		String tableName = parseNull(request.getParameter("table_name")).replaceAll(" ", "_").replaceAll("[^a-zA-Z0-9_]", "").toLowerCase();
		//remove accents from tablename
		tableName = com.etn.asimina.util.UrlHelper.removeAccents(tableName)+"_"+selectedSiteId;
			
		if(tableName.length() <= 50)
		{
			formId = UUID.randomUUID().toString();
			String columnQuery = "";

			String query = "INSERT INTO process_forms_unpublished (form_id, process_name, table_name, site_id, variant, template, meta_description, meta_keywords, redirect_url, btn_align, html_form_id, form_class, form_method, form_enctype, form_autocomplete, label_display, form_width, form_js, form_css, delete_uploads) VALUES (" + escape.cote(formId) + "," + escape.cote(processName) + "," + escape.cote(tableName) + "," + escape.cote(selectedSiteId) + "," + escape.cote(variant) + "," + escape.cote(template) + "," + escape.cote(metaDescription) + "," + escape.cote(metaKeywords) + "," + escape.cote(redirectUrl) + "," + escape.cote(formButtonAlign) + "," + escape.cote(htmlFormId) + "," + escape.cote(formClass) + "," + escape.cote(formMethod) + "," + escape.cote(formEnctype) + "," + escape.cote(formAutoComplete) + "," + escape.cote(formDisplayLabel) + "," + escape.cote(formWidth) + "," + escapeCote2(formJs) + "," + escapeCote2(formCss) + "," + escape.cote(deleteUploads) + ")";

			int rid = Etn.executeCmd(query);

			if(rid > 0){

				ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"CREATED","Form",processName,selectedSiteId);

				String formSuccessMsg = "";
				String formTitle = "";
				String formSubmitBtnLbl = "";
				String formCancelBtnLbl = "";

				for(Language lang : langsList)
				{
					formSuccessMsg = parseNull(request.getParameter("success_msg_" + lang.getLanguageId()));
					formTitle = parseNull(request.getParameter("title_" + lang.getLanguageId()));
					formSubmitBtnLbl = parseNull(request.getParameter("submit_btn_lbl_" + lang.getLanguageId()));
					formCancelBtnLbl = parseNull(request.getParameter("cancel_btn_lbl_" + lang.getLanguageId()));

					if(formSuccessMsg.length() == 0)
						formSuccessMsg = parseNull(request.getParameter("success_msg_" + defaultLanguage.getLanguageId()));

					if(formSuccessMsg.length() > 0)
						formSuccessMsg = formSuccessMsg.replaceAll("\"", "&quot;");

					if(formTitle.length() == 0)
						formTitle = parseNull(request.getParameter("title_" + defaultLanguage.getLanguageId()));

					if(formSubmitBtnLbl.length() == 0)
						formSubmitBtnLbl = parseNull(request.getParameter("submit_btn_lbl_" + defaultLanguage.getLanguageId()));

					if(formCancelBtnLbl.length() == 0)
						formCancelBtnLbl = parseNull(request.getParameter("cancel_btn_lbl_" + defaultLanguage.getLanguageId()));

					Etn.executeCmd("insert into process_form_descriptions_unpublished (form_id, langue_id, title, success_msg, submit_btn_lbl, cancel_btn_lbl) values (" + escape.cote(formId) + ", " + escape.cote(lang.getLanguageId()) + ", " + escape.cote(formTitle) + ", " + escape.cote(formSuccessMsg) + ", " + escape.cote(formSubmitBtnLbl) + ", " + escape.cote(formCancelBtnLbl) + ") ");
				}
			}
		}
		else {
			errorMsg = "Table name cannot be more than 50 characters";
		}

    } else if (isEdit.length() > 0 && isEdit.equals("1") && formId.length() > 0) {
        Etn.execute("UPDATE process_forms_unpublished SET variant = " + escape.cote(variant) + ", template = " + escape.cote(template) + ", meta_description = " + escape.cote(metaDescription) + ", meta_keywords = " + escape.cote(metaKeywords) + ", redirect_url = " + escape.cote(redirectUrl) + ", btn_align = " + escape.cote(formButtonAlign) + ", html_form_id = " + escape.cote(htmlFormId) + ", form_class = " + escape.cote(formClass) + ", form_method = " + escape.cote(formMethod) + ", form_enctype = " + escape.cote(formEnctype) + ", form_autocomplete = " + escape.cote(formAutoComplete) + ", label_display = " + escape.cote(formDisplayLabel) + ", form_width = " + escape.cote(formWidth) + ", form_js = " + escapeCote2(formJs) + ", form_css = " + escapeCote2(formCss) +", updated_on = now(), updated_by = "+escape.cote(String.valueOf(Etn.getId()))+", delete_uploads = " + escape.cote(deleteUploads) +" WHERE form_id = " + escape.cote(formId));

        updateVersionForm(Etn, formId);

        Set rs_form_process = Etn.execute("SELECT  process_name FROM process_forms_unpublished WHERE form_id = " + escape.cote(formId) + " and site_id = " + escape.cote(selectedSiteId));
        rs_form_process.next();
        ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),formId,"UPDATED","Form",parseNull(rs_form_process.value("process_name")),selectedSiteId);

        Set pagePathRs = null;
        String formSuccessMsg = "";
        String formTitle = "";
        String formSubmitBtnLbl = "";
        String formCancelBtnLbl = "";

        for(Language lang : langsList)
        {
            formSuccessMsg = parseNull(request.getParameter("success_msg_" + lang.getLanguageId()));
            formTitle = parseNull(request.getParameter("title_" + lang.getLanguageId()));
            formSubmitBtnLbl = parseNull(request.getParameter("submit_btn_lbl_" + lang.getLanguageId()));
            formCancelBtnLbl = parseNull(request.getParameter("cancel_btn_lbl_" + lang.getLanguageId()));

            if(formSuccessMsg.length() > 0)
                formSuccessMsg = formSuccessMsg.replaceAll("\"", "&quot;");

            pagePathRs = Etn.execute("SELECT * FROM process_form_descriptions_unpublished WHERE langue_id = " + escape.cote(lang.getLanguageId()) + " AND form_id = " + escape.cote(formId));

            if(pagePathRs.rs.Rows > 0){

                Etn.executeCmd("UPDATE process_form_descriptions_unpublished SET title = " + escape.cote(formTitle) + ", success_msg = " + escape.cote(formSuccessMsg) + ", submit_btn_lbl = " + escape.cote(formSubmitBtnLbl) + ", cancel_btn_lbl = " + escape.cote(formCancelBtnLbl) + " WHERE langue_id = " + escape.cote(lang.getLanguageId()) + " AND form_id = " + escape.cote(formId));

            } else {

                if(formSuccessMsg.length() == 0)
                    formSuccessMsg = parseNull(request.getParameter("success_msg_" + defaultLanguage.getLanguageId()));

                if(formTitle.length() == 0)
                    formTitle = parseNull(request.getParameter("title_" + defaultLanguage.getLanguageId()));

                if(formSubmitBtnLbl.length() == 0)
                    formSubmitBtnLbl = parseNull(request.getParameter("submit_btn_lbl_" + defaultLanguage.getLanguageId()));

                if(formCancelBtnLbl.length() == 0)
                    formCancelBtnLbl = parseNull(request.getParameter("cancel_btn_lbl_" + defaultLanguage.getLanguageId()));

                Etn.executeCmd("INSERT INTO process_form_descriptions_unpublished (form_id, langue_id, title, success_msg, submit_btn_lbl, cancel_btn_lbl) VALUES (" + escape.cote(formId) + ", " + escape.cote(lang.getLanguageId()) + "," + escape.cote(formTitle) + "," + escape.cote(formSuccessMsg) + "," + escape.cote(formSubmitBtnLbl) + "," + escape.cote(formCancelBtnLbl) + ") ");

            }
        }
        Etn.executeCmd("update "+PAGES_DB+".freemarker_pages set updated_ts=now() where id in (select parent_page_id from "+PAGES_DB+".pages where id in "+
            "(select page_id from "+PAGES_DB+".pages_forms where form_id="+escape.cote(formId)+" and type='freemarker') group by parent_page_id)");
        Etn.executeCmd("update "+PAGES_DB+".structured_contents set updated_ts=now() where id in (select parent_page_id from "+PAGES_DB+".pages where id in "+
            "(select page_id from "+PAGES_DB+".pages_forms where form_id="+escape.cote(formId)+" and type='structured') group by parent_page_id)");
        
        callPagesUpdateFormAPI(formId, Etn.getId());
    }

    for(int i=0;i<deleteIds.split(",").length;i++){

        String deleteId=deleteIds.split(",")[i];
        if(deleteId.length() > 0){

            Set rsForm =Etn.execute("select process_name from process_forms_unpublished where form_id="+escape.cote(deleteId));
            rsForm.next();
            
            String pagesDb = GlobalParm.getParm("PAGES_DB");
            Set formPagesRs =  Etn.execute("SELECT p.name, 'freemarker' as typ FROM "+pagesDb+".parent_pages_forms pf INNER JOIN "+pagesDb+".freemarker_pages p ON pf.page_id = p.id and pf.type = 'freemarker' WHERE pf.form_id = "+escape.cote(deleteId)+
                                        " union SELECT p.name, 'structured' as typ FROM "+pagesDb+".parent_pages_forms pf INNER JOIN "+pagesDb+".structured_contents p ON p.type='page' and pf.page_id = p.id and pf.type = 'structured' WHERE pf.form_id = "+escape.cote(deleteId));
            if(formPagesRs.rs.Rows>0){
                errorMsg  += "=> "+parseNull(rsForm.value("process_name"))+" is being used in ";
                if(formPagesRs.rs.Rows>1) errorMsg += "pages ";
                else errorMsg += "page ";
                while(formPagesRs.next()){
                    errorMsg += formPagesRs.value("name")+" ("+formPagesRs.value("typ")+" page), ";
                }
                errorMsg=errorMsg.substring(0, errorMsg.length() - 2);
                errorMsg+=".\n";
            }else{
                
                Set deleteProcessRs = Etn.execute("SELECT table_name, process_name FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl WHERE form_id = " + 
                    escape.cote(deleteId) + " and site_id = " + escape.cote(selectedSiteId));
                String tblName = "";

                if(deleteProcessRs.next()) {

                    tblName = parseNull(deleteProcessRs.value("table_name"));
                }

                Set rsCheckTrash= Etn.execute("SELECT f1.process_name as 'name1',f1.is_deleted,f2.process_name as 'name2', f2.is_deleted,f2.form_id as 'id' "+
                    "FROM process_forms_unpublished_tbl f1 left JOIN process_forms_unpublished_tbl f2 ON f1.process_name=f2.process_name "+
                    "AND f1.form_id != f2.form_id AND f1.site_id=f2.site_id "+
                    "WHERE f1.form_id="+escape.cote(deleteId)+" AND f1.site_id = " + escape.cote(selectedSiteId));
                rsCheckTrash.next();
                if(!rsCheckTrash.value("id").equals("")){
                    deleteForm(Etn,rsCheckTrash.value("id"),selectedSiteId);
                }
                Etn.executeCmd("UPDATE process_forms_unpublished_tbl SET is_deleted='1',updated_on=NOW(),updated_by="+escape.cote(logedInUserId)+
                    " WHERE form_id = "+escape.cote(deleteId));

                ActivityLog.addLog(Etn,request,parseNull((String)session.getAttribute("LOGIN")),deleteId,"DELETED","Form",parseNull(deleteProcessRs.value("process_name")),selectedSiteId);
            }
        }
    }

    String processQ = "SELECT uf.form_id, uf.process_name, uf.table_name, uf.type, "
    +" uf.updated_on,l1.name as updated_by, "
    +" COALESCE(pf.to_publish_ts,'') as last_publish, l2.name as last_publish_by, "
    +" CASE WHEN uf.to_publish = 1 "
    +"      THEN Concat( 'Publish on', ' ', uf.to_publish_ts , ' by ', l3.name)  "
    +" WHEN uf.to_unpublish = 1 "
    +"      THEN Concat( 'Un-publish on', ' ', uf.to_unpublish_ts, ' by ', l4.name ) "
    +" ELSE '' END as next_publish, case when coalesce(gm.id,'') = '' then '0' else '1' end as game_form "
    +" FROM process_forms_unpublished uf "
    +" LEFT join process_forms pf on pf.form_id = uf.form_id "
    +" LEFT JOIN login l1 on l1.pid = uf.updated_by "
    +" LEFT JOIN login l2 on l2.pid = pf.to_publish_by "
    +" LEFT JOIN login l3 on l3.pid = uf.to_publish_by "
    +" LEFT JOIN login l4 on l4.pid = uf.to_unpublish_by "
    +" LEFT JOIN games_unpublished gm on gm.form_id = uf.form_id "
    +" WHERE uf.site_id = " + escape.cote(selectedSiteId) ;
    Set processRs = Etn.execute(processQ);

    Set formFilterRs = Etn.execute("SELECT form_id FROM "+GlobalParm.getParm("CATALOG_DB")+".person_forms pf inner join profilperson pp on pp.person_id = pf.person_id inner join profil p on p.profil_id = pp.profil_id where p.assign_site='1' and pf.person_id="+escape.cote(""+Etn.getId()));
    List<String> formIds = new ArrayList<String>();

    while(formFilterRs.next())
    {
        formIds.add(parseNull(formFilterRs.value("form_id")));
    }

%>

<!DOCTYPE html>

<html>
<head>
    <title>Forms</title>

    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>

    <!-- ace editor -->
    <script src="<%=request.getContextPath()%>/js/ace/ace.js" ></script>
    <!-- ace modes -->
    <script src="<%=request.getContextPath()%>/js/ace/mode-freemarker.js" ></script>
    <script src="<%=request.getContextPath()%>/js/ace/mode-javascript.js" ></script>

    <script src="<%=request.getContextPath()%>/js/ckeditor/adapters/jquery.js"></script>
    <script>
        CKEDITOR.timestamp = "" + parseInt(Math.random()*100000000);
    </script>

    <style type="text/css">
        .ace_editor {
            border: 1px solid lightgray;
            min-height: 500px;
            font-family: monospace;
            font-size: 14px;
            /*margin: auto;*/
            /*width: 80%;*/
        }

        .list-group-item{
            display: list-item !important;
        }
    </style>

</head>

<%	
breadcrumbs.add(new String[]{"Content", ""});
breadcrumbs.add(new String[]{"Forms", ""});
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
    <!-- title -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
        <div>
            <h1 class="h2">Forms</h1>
            <p class="lead"></p>
        </div>

        <!-- buttons bar -->
        <div class="btn-toolbar mb-2 mb-md-0">
            
            <button type="button" class="btn btn-danger d-none d-md-block mr-2" onclick="deleteSelected()">Delete</button>
            <button type="button" class="btn btn-primary d-none d-md-block mr-1" onclick="downloadBtn()" id="formfilesdownload" title="Form Attachments download">Attachments Download</button>
            
            
            <div class="btn-group mr-2 d-none d-md-block" role="group" aria-label="...">
                <button type="button" class="btn btn-primary" onclick="onPublishUnpublish('publish')" id="publishtoprodbtn">Publish</button>
                <button type="button" class="btn btn-danger" onclick="onPublishUnpublish('unpublish')" id="unpublishtoprodbtn">Unpublish</button>
            </div>

            <div class="btn-group mr-2" role="group" aria-label="...">
                <button type="button" class="btn btn-success add_new_form" data-toggle="modal" data-target="#add_new_form">New Form</button>
            </div>

            <div class="btn-group mr-2" role="group" aria-label="...">
                <a href='../../<%=GlobalParm.getParm("CATALOG_DB")%>/admin/gestion.jsp' class="btn btn-primary" >Back</a>
            </div>

            <div class="btn-group mr-2 d-block d-md-none">
                <button class="btn btn-danger dropdown-toggle" type="button" id="dropdownActionBtn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Actions</button>
                <div class="dropdown-menu">
                    <a class="dropdown-item" onclick="onPublishUnpublish('publish')" href="#">Publish</a>
                    <a class="dropdown-item" onclick="onPublishUnpublish('unpublish')" href="#">Unpublish</a>
                    <div class="dropdown-divider"></div>
                    <a class="dropdown-item" onclick="deleteSelected()" href="#">Delete</a>
                    <div class="dropdown-divider"></div>
                    <a class="dropdown-item" onclick="downloadBtn()" href="#">Attachments Download</a>
                </div>
            </div>

            <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Forms')" title="Add to shortcuts">
                <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
            </button>
            
        </div>
        <!-- /buttons bar -->
    </div><!-- /d-flex -->
    <!-- /title -->

    <!-- container -->
    <div class="animated fadeIn">
    <div>
    <form name='frm' id='frm' method='post' action='process.jsp' >
        <input type="hidden" name="delete_id" value="" />
        <input type="hidden" id="appcontext" value="<%=request.getContextPath()%>/" />
        <table class="table table-hover m-t-20" id="resultsdata" style="width: 100%">
            <thead class="thead-dark">
                <th scope="col"><input type='checkbox' class='d-none d-sm-block' id='sltall' value='1' onchange="onChangeCheckAll(this)" /></th>
                <th scope="col">Name</th>
                <th scope="col">Type</th>
                <th scope="col">Replies</th>
                <th scope="col">Last changes</th>
                <th scope="col">Actions</th>
            </thead>

            <tbody class="sortable">
            <%
                String formName = "";
                String tbName = "";
                formId = "";
                String formType = "";
                int i = 0;
                int noOfReplies = 0;
                Set tbNameRs = null;
                String rowColor = "";
                String portalDB = GlobalParm.getParm("PROD_PORTAL_DB");
				

                while(processRs.next()){
					boolean isGameForm = "1".equals(processRs.value("game_form"));
					if(formIds.size() > 0 && !formIds.contains(parseNull(processRs.value("form_id")))) continue;
                    formName = parseNull(processRs.value("process_name"));
                    tbName = parseNull(processRs.value("table_name"));

                    formId = parseNull(processRs.value("form_id"));
                    formType = parseNull(processRs.value("type"));
					
                    noOfReplies = 0;

                    String clr = "";

                    String formPublishStatus = getFomPublishStatus(Etn, formId);

                    if("NOT_PUBLISHED".equals(formPublishStatus)) rowColor = "danger"; //red
                    else if("NEEDS_PUBLISH".equals(formPublishStatus)) rowColor = "warning"; //orange
                    else rowColor = "success"; //green

                    if(tbName.length() > 0){

						
                        tbNameRs = Etn.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = " + escape.cote(GlobalParm.getParm("FORM_DB")) + " AND table_name = " + escape.cote(tbName));

                        if(tbNameRs.rs.Rows > 0){
							//for all tables we should just get the no of rows in it for prod site .. this is true for signup and forgot password form as well
							tbNameRs = Etn.executeWithCount("SELECT * FROM " + tbName + " WHERE COALESCE(portalurl,'prod_user') NOT LIKE '%\\_portal/' AND form_id = " + escape.cote(formId)+" ");
                            if(tbNameRs.next())
                                noOfReplies = Etn.UpdateCount;
							
                        }
						
                    }

                    if(i++ % 2 != 0) clr = "background-color:#eee";

                    String toolTipText = "";
                    String lastpublish = processRs.value("last_publish");
                    String lastpublishBy = processRs.value("last_publish_by");
                    String nextpublish = processRs.value("next_publish");
                    String updatedOn = processRs.value("updated_on");
                    String updatedBy = processRs.value("updated_by");


                    if(updatedOn.length() > 0 )
                    {
                        toolTipText = "Last change: ";
                        if(updatedBy.length() >0){
                            toolTipText += " by "+updatedBy;
                        }
                    }

                    if(lastpublish.length() >0){
                        toolTipText +="<br>Last publication: "+ lastpublish;
                        if(lastpublishBy.length() >0){
                            toolTipText += " by "+lastpublishBy;
                        }
                    }

                    if(nextpublish.length() >0){
                        toolTipText +="<br>Next publication: "+ nextpublish;
                    }
                %>

                    <tr class="table-<%=rowColor%>" style="cursor: move;">
                        <td style='text-align:center' >
                            <input type='checkbox' class='slt_option d-none d-sm-block idCheck' value='<%=escapeCoteValue(formId)%>' />
                            <input type='hidden' name='id' value='<%=escapeCoteValue(formId)%>'  />
                        </td>
                        <td><%=escapeCoteValue(formName)%></td>
                        <td><%
								if(formType.equals("sign_up")) out.write("Signup");
								else if(formType.equals("forgot_password")) out.write("Forgot Password");
								else if(isGameForm) out.write("Game");
								else out.write("Simple");
							%>
						</td>
                        <td style="text-align: center;">
                <%
                            if(noOfReplies > 0){
                %>
                                <a href='<%= GlobalParm.getParm("FORMS_WEB_APP")%>admin/search.jsp?___fid=<%= formId%>'>
                                    <span class="badge badge-secondary"><%=noOfReplies%></span>
                                </a>
                <%
                            } else {
                %>
                                <a href='#'>
                                    <span class="badge badge-danger">0</span>
                                </a>
                <%
                            }
                %>
                        </td>
                        <td>
                            <%=updatedOn%>
                            <a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="<%=toolTipText%>">
                                <i data-feather="info"></i>
                            </a>        
                        </td>

                        <td class="dt-body-right text-nowrap" nowrap>

                            <a id="<%=formId%>" class="btn btn-primary btn-sm" role="button" aria-pressed="true" href='#' data-toggle="modal" data-placement="top" title="View fields" onclick='javascript:window.location="editProcess.jsp?form_id=<%=formId%>";'> <i data-feather="edit"></i></a>
                        <% if(isGameForm == false) { %>
                            <a id="<%=formId%>" class="btn btn-primary btn-sm edit_form" role="button" aria-pressed="true" href="#" data-toggle="modal" data-placement="top" title="Edit form" data-target="#edit_form"> <i data-feather="settings"></i></a>

                            <a href="javascript:copyModal('<%=formId%>')" class="btn btn-primary btn-sm" data-toggle="tooltip" data-placement="top" title="Duplicate form parameters of : <%=escapeCoteValue(formName)%>"><i data-feather="copy"></i></a>
                            <%}%>
<!--

                            <a class="btn btn-primary btn-sm" role="button" aria-pressed="true" href='#' onclick='javascript:window.location=$("#form_translation").val()+"&fname=<%=formName%>&fid=<%= formId%>";' data-toggle="tooltip" data-placement="top" title="Translation"> <i data-feather="globe"></i></a>
-->
                            <a class="btn btn-primary btn-sm" role="button" aria-pressed="true" href='<%= GlobalParm.getParm("FORMS_WEB_APP")%>admin/search.jsp?___fid=<%= formId%>' data-toggle="tooltip" data-placement="top" title="Form replies"> <i data-feather="file-text"></i></a>
                <%
                        if(formType.equalsIgnoreCase("sign_up") || formType.equalsIgnoreCase("forgot_password")){
                %>
                            <a href="#" style="opacity: 0.5; cursor: default;" class="btn btn-danger btn-sm" ><i data-feather="trash-2"></i></a>
                <%
                        } else if(isGameForm == false) {
                            if("NOT_PUBLISHED".equals(formPublishStatus)) {
                %>
                                <a href="javascript:ondelete('<%=formId%>')" class="btn btn-danger btn-sm" ><i data-feather="trash-2"></i></a>
                <%
                            } else {
                %>
                                <button type="button" class="btn btn-danger btn-sm" onclick="onUnpublish('<%=formId%>','unpublish')" id='unpublishtoprodbtn'><i data-feather="x"></i></button>
                <%
                            }
                        }
                %>
                        </td>
                    </tr>
                <%
                    }//while
                %>

            </tbody>
        </table>

        <input type="hidden" id="html_form_page" value="<%=request.getContextPath()%>/admin/htmlFormPage.jsp">
        <input type="hidden" id="edit_html_form_page" value="<%=request.getContextPath()%>/admin/htmlFormPage.jsp">
        <input type="hidden" id="form_translation" value='<%=GlobalParm.getParm("CATALOG_URL")%>admin/libmsgs.jsp?reqtype=pform'>
        <input type="hidden" id="form_add_rule" value='<%= request.getContextPath()%>/admin/formaddrule.jsp'>
        <input type="hidden" id="image_browser" value='<%=GlobalParm.getParm("PAGES_URL")%>admin/imageBrowser.jsp?popup=1'>

    </form>
    </div>
    <div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
    </div>
    <br>

    <!-- Modal add new form -->
    <div class="modal fade" id="add_new_form" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Add new form" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add a new form</h5>

                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div id="add_new_form_content" class="modal-body">

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

   
    <div class="modal fade" id='copyFormDialog' tabindex="-1" role="dialog" >
        <div class="modal-dialog" role="document">
            <div class="modal-content" >
                <form class="formPublishPages" action="" onSubmit="return false" novalidate="">
                    <div class="modal-header">
                        Copy New Form
                    </div>
                    <div class="modal-body">
                        <form>
                        <input type="hidden" name="newform" id="copyFormId" value=""/>
                        <div class="form-group">
                            <label for="copyFormNewName">New Form Name</label>
                            <input type="text" maxlength="50" class="form-control"  name="formNewName" id="copyFormNewName" >
                            
                        </div>
                        <div class="form-group">
                            <label for="copyTableNewName">New Table Name</label>
                            <input type="text" maxlength="50" class="form-control" name="tableNewName" id="copyTableNewName">
                        </div>
                        <span class="infoMsg" style="color:blue;"></span>
                        <span class="errorMsg" style="color:red;"></span>
                        <button type="button" class="btn btn-primary" onclick="copyForm()" >Copy New Form</button>
                        <button type="button" class="btn btn-secondary" onclick="$('#copyFormDialog').modal('hide');">Cancel</button>

                        </form>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <div class="modal fade" id="modalPublishForms" tabindex="-1" role="dialog" >
        <div class="modal-dialog" role="document">
            <div class="modal-content" >
                <form class="formPublishPages" action="" onSubmit="return false" novalidate="">
                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="form-group row">
                                <div class="col publishMessage">

                                </div>
                                <div class="col-1">
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label  class="col-sm-3 col-form-label">
                                    <span class="text-capitalize actionName">Publish</span>
                                </label>
                                <div class="col-sm-9">
                                    <button type="button" class="btn btn-primary publishNowBtn">Now</button>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label  class="col-sm-3 col-form-label">
                                    <span class="text-capitalize actionName">Publish</span> on
                                </label>
                                <div class="col-sm-9">
                                    <div class="input-group">
                                        <input type="text" class="form-control textdatetime" name="publishTime" value="">
                                        <div class="input-group-append">
                                            <button class="btn btn-primary  rounded-right publishOnBtn" type="button">OK</button>
                                        </div>
                                        <div class="invalid-feedback">Please specify date and time</div>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <!-- Button trigger modal -->
<!-- Message Modal -->
<div class="modal fade" id="messageModal" tabindex="-1" role="dialog" aria-labelledby="messageModal" >
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="title">Unpublish Forms</h5>
      </div>
      <div class="modal-body">
        <div class="d-block text-success mb-3"  id="successMessage"></div>
        <div id="failedMessage"></div>
        <div><p id="failedFormsList" class="mt-2 text-danger" style="white-space: pre-wrap;"></p></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>
<!-- Message Modal -->
</main>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>
<%@ include file="ajax/checkPublishLogin.jsp"%>

<script>

    var $ch = {}; //for globals

    jQuery(document).ready(function()
    {
        $('.custom-tooltip').tooltip({
            placement : 'bottom',
            trigger: 'manual',
            html:true,
            animation:false
        }).on("mouseenter", function () {
                var _this = this;
                $(this).tooltip("show");
                $(".tooltip").on("mouseleave", function () {
                    $(_this).tooltip('hide');
                });
            }).on("mouseleave", function () {
                var _this = this;
                setTimeout(function () {
                    if (!$(".tooltip:hover").length) {
                        $(_this).tooltip("hide");
                    }
                }, 300);
        });

        <%if(errorMsg.length()>0){%>
            alert(`<%=errorMsg%>`);
        <%}%>
        refreshscreen=function()
        {
            window.location = window.location
        };

        var aceCommonOptions = {
            minLines: 20,
            showPrintMargin : false,
            autoScrollEditorIntoView: true,
        };

        $('input#copyTableNewName').on("input",function(e){
            onDbLetterKeyup(this);
        });

        $('#resultsdata').DataTable({
            "language": {
                "emptyTable": "No form available under selected site."
            },
            "order" : [1,'asc'],
            "responsive": true,
            "columnDefs": [
                { targets : [0, 4] , searchable : false},
                { targets : [0, 4] , orderable : false}
            ],
            "scrollX": true,
            "pageLength": 50,
            "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
        });

        $(".add_new_form").on("click", function(){

            $.ajax({

                url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxNewForm.jsp',
                type: 'POST',
                dataType: 'HTML',
                data: {
                    "formid": $(this).prop("id"),
                    "target": "process"
                },
                success : function(response)
                {
                    $("#edit_form_content").html("");
                    $("#add_new_form_content").html(response);

                    $('input#table_name').on("input",function(e){
                        onDbLetterKeyup(this);
                    });

                    $("input#process_name").on("change",function(e){

                        $("#title_1").val($("#process_name").val());
                    });

                    $("#add_new_form").on('shown.bs.modal', function() {

                        $(".add_new_form").modal("show");

                        $(".ckeditor_success_msg").ckeditor({
                            filebrowserImageBrowseUrl : $("#image_browser").val(),
                            extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
							colorButton_enableMore : true,
							colorButton_enableAutomatic : false,
                            allowedContent: true,
                            contentsCss: '<%=request.getContextPath()%>/css/bootstrap.min.css',
							colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
                        }, onFieldCkeditorReady);

                        var javascriptOpts = $.extend({ mode: "ace/mode/javascript"}, aceCommonOptions);
                        $ch.jsEditor = ace.edit("js_code_editor", javascriptOpts);

                        var cssOpts = $.extend({ mode: "ace/mode/css"}, aceCommonOptions);
                        $ch.cssEditor = ace.edit("css_code_editor", cssOpts);

                        $('.add_new_form').toggle('hide');
                        $('.add_new_form').css('display','inline-block');

                    });

                    $("#add_new_form").on('hidden.bs.modal', function() {

                        $('.add_new_form').modal('hide');
                        $('.add_new_form').css('display','inline-block');
                    });


                    //    var freemarkerOpts = $.extend({ mode: "ace/mode/freemarker"}, aceCommonOptions);
                      //  $ch.templateEditor = ace.edit("template_code_editor", freemarkerOpts)
                        // setEditorBeautify($ch.templateEditor);

                    //        var cssOpts = $.extend({ mode: "ace/mode/css"}, aceCommonOptions);
                    //      $ch.cssEditor = ace.edit("css_code_editor",cssOpts);


                        // removed beautify , after adding template variable support to JS/CSS section
                        // var beautifyFunc = ace.require("ace/ext/beautify").beautify;
                        // var beautifyCommand = {
                        //     name: 'Beautify',
                        //     bindKey: {win: 'Ctrl-Alt-B',  mac: 'Command-Alt-B'},
                        //     exec: function(editor) {
                        //         beautifyFunc(editor.session);
                        //     }
                        // };
                        // var beautifyEditor = function(editor){
                        //     editor.execCommand('Beautify');
                        // };
                        // var setEditorBeautify = function(editor){
                        //     editor.commands.addCommand(beautifyCommand);
                        //     editor.on('focus',function(){
                        //         beautifyEditor(editor);
                        //     });
                        //     editor.on('blur',function(){
                        //         beautifyEditor(editor);
                        //     });
                        // };
                        //
                        // setEditorBeautify($ch.cssEditor);//removed after tempate variables added
                        // setEditorBeautify($ch.jsEditor);//removed after tempate variables added
                }
            });

        });

        onPathKeyup = function(input){

            var val = $(input).val();

            val = val.trimLeft()
                        .replace(" ","-")
                        .replace(/[^a-zA-Z0-9\/-]/g,'')
                        .replace('/-','/');
            if(val.startsWith("-")){
                val = val.substring(1);
            }
            $(input).val(val.toLowerCase());
        }

        onDbLetterKeyup = function(input){
            var val = $(input).val();
            val = val.trimLeft()
                        .replace(/\s/g, '_')
                        .replace(/[^a-zA-Z0-9\/_]/g,'')
            $(input).val(val.toLowerCase());
        }

        onPathBlur = function(input){

            var val = $(input).val();

            if(val.endsWith("/")){
                val = val.substring(0,val.length-1);
            }
            $(input).val(val);
        }

        $(".edit_form").on("click", function(){

            $.ajax({

                url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxNewForm.jsp',
                type: 'POST',
                dataType: 'HTML',
                data: {
                    "formid": $(this).prop("id"),
                    "target": "process"
                },
                success : function(response)
                {
                    $("#add_new_form_content").html("");

                    $("#edit_form_content").html(response);
                    $("#edit_process_name").html("Edit form: "+$("#process_name").val());

                    $('input.page_path').on("input",function(e){
                        onPathKeyup(this);
                    })
                    .on("blur",function(e){
                        onPathBlur(this);
                    });

                    $("#edit_form").on('shown.bs.modal', function() {

                        $('.edit_form').modal('show');

                        $(".ckeditor_success_msg").ckeditor({
                            filebrowserImageBrowseUrl : $("#image_browser").val(),
                            extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
							colorButton_enableMore : true,
							colorButton_enableAutomatic : false,
                            allowedContent: true,
                            contentsCss: '<%=request.getContextPath()%>/css/bootstrap.min.css',
							colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
                        }, onFieldCkeditorReady);

                        var javascriptOpts = $.extend({ mode: "ace/mode/javascript"}, aceCommonOptions);
                        $ch.jsEditor = ace.edit("js_code_editor", javascriptOpts);
                        $ch.jsEditor.getSession().setValue($("#form_js").val());

                        var cssOpts = $.extend({ mode: "ace/mode/css"}, aceCommonOptions);
                        $ch.cssEditor = ace.edit("css_code_editor", cssOpts);
                        $ch.cssEditor.getSession().setValue($("#form_css").val());

                        $('.edit_form').modal('hide');
                        $('.edit_form').css('display','inline-block');

                    });

                }
            });

        });


        copyForm = function(){
            var dialogDiv = $('#copyFormDialog');
            var formNewName = $('#copyFormNewName').val().trim();
            var tableNewName = $("#copyTableNewName").val().trim();

            //validations
            if(formNewName === ""){
                alert("Error: form name cannot be empty.");
                $("#copyFormNewName").focus();
                return false;
            }

            if(tableNewName === ""){
                alert("Error: table name cannot be empty.");
                $("#copyTableNewName").focus();
                return false;
            }

            if(!confirm("Are you sure to copy?")){
                return false;
            }

            var errorMsg = dialogDiv.find('.errorMsg');
            var infoMsg = dialogDiv.find('.infoMsg');

            errorMsg.html("");
            infoMsg.html("");

            //call recursive function
            var formId = $('#copyFormId').val();

            var params = {
                    formId : formId,
                    formNewName : formNewName,
                    tableNewName : tableNewName
            };

            $.ajax({
                url : $("#appcontext").val()+'admin/ajax/backendAjaxEditForm.jsp',
                type: 'POST',
                dataType: 'JSON',
                data: {
                    action: "checktablenameuniqueness",
                    tablename: $("#copyTableNewName").val()
                },
                success : function(response) {

                    if(response.status == 0){

                        $(errorMsg).css("display","none");

                        $.ajax({
                            type :  'POST',
                            url :   '<%=request.getContextPath()%>/admin/ajax/backendAjaxCopyForm.jsp',
                            data :  params,
                            dataType : "json",
                            cache : false,
                            success:function(response){

                                if(response["status"] !== "ERROR"){
                                    window.location.href = window.location.href;
                                }
                            }
                        });

                    } else {

                        $(errorMsg).html(response.msg);
                        $(errorMsg).css("display","block");
                        return false;
                    }
                }
            });
        }

        copyModal = function(sid) {
            if(!$("#copyFormDialog").is(":visible"))
                openCopyDialog(sid);
        }

        openCopyDialog = function(sid){

            var copyDialog = $('#copyFormDialog');

            $('#copyFormId').val(sid);
            $('#copyFormNewName').val("");
            $('#copyTableNewName').val("");

            copyDialog.find('.infoMsg').html("");
            copyDialog.find('.errorMsg').html("");

            copyDialog.modal("show");

        }

        onKeyOrderSeq = function(event){
            
            var input = $(event.target);
            allowNumberOnly(input);
            if(event.which == 13 ){
                //enter pressed
                var val = parseInt(input.val());
                if( !isNaN(val) && val >= 0 ){
                    var tr = input.parents("tr:first");
                    var maxNum = tr.siblings().length + 1;

                    if(val > maxNum){
                        val = maxNum;
                    }

                    if(val <= 1){
                        tr.insertBefore(tr.siblings(':eq(0)'));
                    }
                    else{
                        tr.insertAfter(tr.siblings(':eq('+(val-2)+')'));
                    }

                    setRowOrder();
                    // input.focus();
                }
            }
        };

        setRowOrder = function(){

            $('#resultsdata tbody tr').each(function(i,tr){
                $(tr).find('.order_seq')
                // .prop('readonly',false)
                .val(i+1);
                // .prop('readonly',true);
            });
        };

        Sortable.create(document.querySelector('#resultsdata tbody.sortable'), {
            direction: 'vertical',
            scroll: true,
            scrollSensitivity: 100,
            scrollSpeed: 30,
            forcePlaceholderSize: true,
            animation: 50,
            helper: function (event, element) {
                var clone = element.cloneNode(true);
                var origTdList = element.querySelectorAll('>td');
                var cloneTdList = clone.querySelectorAll('>td');
                for (var i = 0; i < cloneTdList.length; i++) {
                    cloneTdList[i].style.width = origTdList[i].offsetWidth + 'px';
                }
                return clone;
            },
            onEnd: function (event) {
                setRowOrder();
                orderingchanged = true;
            }
        });


        $('#resultsdata tbody tr input.order_seq')
            .keyup(onKeyOrderSeq)
            .blur(setRowOrder);

        selecttab = function(tab, id, element) {

            if(tab !== "lang1show") {

                $("div.multilingual-section").find('input,select').attr('disabled','disabled');
                $("div.multilingual-section").find('.page_path').removeAttr('disabled');
            }
            else{

                if($(element).attr("is-new-form") === "1"){

                    $("div.multilingual-section").find('input,select').removeAttr('disabled');

                } else if($(element).attr("is-new-form") === "0"){

                    $("div.multilingual-section").find('input,select').removeAttr('disabled');
                    $("div.multilingual-section").find('#process_name').attr('disabled','disabled');
                    $("div.multilingual-section").find('#table_name').attr('disabled','disabled');
                }
            }

            $(".lang1show").hide();
            $(".lang2show").hide();
            $(".lang3show").hide();
            $(".lang4show").hide();
            $(".lang5show").hide();

            $("."+tab).show();
            $("#process_name").attr("data-language-id", id);
        };

        onPublishUnpublish = function(action,isLogin){

            if ($(".slt_option:checked").length > 0) {

                var ids = "";
                var fcount = 0;
                $(".slt_option").each(function(){

                    if($(this).is(":checked") == true) {

                        fcount++;
                        ids += $(this).val() + ",";
                    }
                });

                if(typeof isLogin == 'undefined' || !isLogin){
                    checkPublishLogin(action);
                }
                else{

                    var msg = "" + fcount + " form(s) selected.\n";
                    msg += "Are you sure you want to "+action+" these form(s)?";

                    showPublishFormsModal(msg, action, function(publishTime){

                        publishUnpublishForms(ids, action, publishTime);
                    });

                }

            } else {

                bootNotify("No form selected");
            }
        }

        onChangeCheckAll = function(checkAll) {
            var isChecked = $(checkAll).prop('checked');
            $(".slt_option").prop("checked", isChecked);
        }

        deleteSelected = function(){

            if ($(".slt_option:checked").length > 0) {
                
                var ids = "";
                var fcount = 0;
                $(".slt_option").each(function(){

                    if($(this).is(":checked") == true) {

                        fcount++;
                        if(ids.length>0){
                            ids +=  ","+$(this).val();
                        }else{
                            ids += $(this).val();
                        }
                    }
                });

                ondelete(ids);

            } else {

                bootNotify("No form selected");
            }
        }

        onUnpublish = function(formId, action,isLogin){

            if(typeof isLogin == 'undefined' || !isLogin){

                checkUnPublishLogin(formId, action);
            }
            else{

                var msg = "Are you sure you want to "+action+" this form?";

                showPublishFormsModal(msg, action, function(publishTime){

                    unpublishForms(formId, action, publishTime);
                });

            }
        }

        setRowOrder();
        
    });

    $(function() {

        var publishTimeField = $('#modalPublishForms input[name=publishTime]');
        const picker = flatpickr(publishTimeField, {
            dateformat: 'd/m/Y H:i',
        });

        publishTimeField.on('change',function(){
            if($(this).val().trim().length > 0){
                $(this).removeClass('is-invalid');
            }
        });

    });

    function showPublishFormsModal(message, action, callback){
        var modal = $('#modalPublishForms');

        modal.find('.actionName').text(action);

        modal.find('.publishMessage').text(message);

        modal.find(".publishNowBtn").off('click')
        .click(function(){
            var publishTime = "now";
            modal.modal('hide');
            callback(publishTime);
        });

        var publishTimeField = modal.find('input[name=publishTime]');
        publishTimeField.val("");

        modal.find(".publishOnBtn").off('click')
        .click(function(){
            var publishTime = publishTimeField.val().trim();

            if(publishTime.length === 0){
                publishTimeField.addClass('is-invalid');
                return false;
            }

            modal.modal('hide');
            callback(publishTime);
        });

        modal.modal('show');
    }

    function publishUnpublishForms(ids, action, publishTime){

        showLoader();
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/ajax/publishAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : action + 'Forms',
                ids : ids,
                publishTime : publishTime
            },
        })
        .done(function(resp) {

            if(resp.status === 1){
                if(resp.unpublishedPagesForms.length>0){
                    $('#messageModal').find('#successMessage').addClass('text-success').removeClass('text-danger');
                    $('#messageModal').find('#successMessage').html(resp.message);
                    $('#messageModal').find('#failedMessage').html("Following form(s) are not unpublished because they are being used in pages");
                    $('#messageModal').find('#failedFormsList').text(resp.unpublishedPagesForms);
                    $('#messageModal').modal("show");
                    $('#messageModal').find(".btn").click(function(event) {
                       $('#frm').submit();
                    });
                }else{
                    bootNotify(resp.message);
                    $('#frm').submit();
                }
            }
            else{
                if(resp.unpublishedPagesForms.length>0){
                    $('#messageModal').find('#successMessage').addClass('text-danger').removeClass('text-success');
                    $('#messageModal').find('#successMessage').html(resp.message);
                    $('#messageModal').find('#failedMessage').html("Following form(s) are not unpublished because they are being used in pages.");
                    $('#messageModal').find('#failedFormsList').text(resp.unpublishedPagesForms);
                    $('#messageModal').modal("show");
                    $('#messageModal').find(".btn").prop("onclick", 'null');
                }else{
                    bootNotifyError(resp.message);
                }
            }

        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function unpublishForms(ids, action, publishTime){

        showLoader();
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/ajax/publishAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : action + 'Forms',
                ids : ids,
                publishTime : publishTime
            },
        })
        .done(function(resp) {

            if(resp.status === 1){
                if(resp.unpublishedPagesForms.length>0){
                    $('#messageModal').find('#successMessage').addClass('text-success').removeClass('text-danger');
                    $('#messageModal').find('#successMessage').html(resp.message);
                    $('#messageModal').find('#failedMessage').html("This form is being used in the pages.");
                    $('#messageModal').find('#failedFormsList').text(resp.unpublishedPagesForms);
                    $('#messageModal').modal("show");
                    $('#messageModal').find(".btn").click(function(event) {
                       $('#frm').submit();
                    });
                }else{
                    bootNotify(resp.message);
                    $('#frm').submit();
                }
            }
            else{
                if(resp.unpublishedPagesForms.length>0){
                    $('#messageModal').find('#successMessage').addClass('text-danger').removeClass('text-success');
                    $('#messageModal').find('#successMessage').html(resp.message);
                    $('#messageModal').find('#failedMessage').html("This form is being used in the pages.");
                    $('#messageModal').find('#failedFormsList').text(resp.unpublishedPagesForms);
                    $('#messageModal').modal("show");
                    $('#messageModal').find(".btn").prop("onclick", 'null');
                }else{
                    bootNotifyError(resp.message);
                }
            }

        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function ondelete(tid)
    {
        let msg="Are you sure to delete ";
        if(tid.split(",").length>1){
            msg+="these forms?";
        }else{
            msg+="this form?";
        }

        if(confirm(msg))
        {
            document.frm.delete_id.value = tid;
            document.frm.submit();
        }
    }
    function search()
    {
        document.frm.issave.value = "0";
        document.frm.submit();
    }

    downloadFormFiles = function(ids)
    {
        console.log(ids);
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/ajax/downloadFormFilesInZip.jsp', type: 'POST', dataType: 'json',
            data: {
                ids: ids
            },
        })
        .always(function( data ) {
            if(data.url)
                window.location.href=data.url;
            else
                bootNotifyError(data.message);
        });
    }

    function downloadBtn()
    {
        if ($(".slt_option:checked").length > 0) {

            var ids = "";
            var fcount = 0;
            $(".slt_option").each(function(){

                if($(this).is(":checked") == true) {

                    fcount++;
                    ids += $(this).val() + ",";
                }
            });
            
            downloadFormFiles(ids);
        } else {
            bootNotifyError("No form selected");
        }   
    }
</script>
</body>
</html>