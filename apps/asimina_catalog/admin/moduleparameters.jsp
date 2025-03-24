<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.HashMap, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, java.util.List"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language,java.util.Arrays" %>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<%
	String selectedsiteid = getSelectedSiteId(session);

	int indexCnt = 0;

	String commonsDb = GlobalParm.getParm("COMMONS_DB");

	Set rsAlgolia = Etn.execute("select * from algolia_settings where site_id = " + escape.cote(selectedsiteid));
	Set rsPartoo = Etn.execute("select * from "+GlobalParm.getParm("PORTAL_DB")+".sites where id = " + escape.cote(selectedsiteid));
	Set rsIdcheck = Etn.execute("select * from "+GlobalParm.getParm("PORTAL_DB")+".idcheck_configurations where site_id = " + escape.cote(selectedsiteid));
	Set rsIdcheckIframeConf = Etn.execute("select * from "+GlobalParm.getParm("PORTAL_DB")+".idcheck_iframe_conf where site_id = " + escape.cote(selectedsiteid));

	String idcheckEmail="";
	String idcheckPassword="";
	String idcheckBloc="";
	String idcheckActivated = "0";
	String idcheckCode = "";
	String idcheckPathName = "";
	String idcheckSupportEmail = "";
	String idcheckLinkValidity = "";
	String idcheckBlockUpload = "";
	String idcheckCaptureModeDesktop = "";
	String idcheckCaptureModeMobile = "";
	String idcheckUploadPromptOnMobile = "";
	String idcheckDisableImageBlackWhiteChecks = "";
	String idcheckDisableImageQualityChecks = "";
	String idcheckTitleTxtColor="";
	String idcheckHeaderBgColor="";
	String idcheckBtnBgColor="";
	String idcheckBtnHoverBgColor="";
	String idcheckBtnTxtColor="";
	String idcheckHideHeaderBorder="";
	String idcheckHeaderLogoAlign = "";
	String idcheckBtnBorderRadius = "";
	String idcheckHomeTitle = "";
	String idcheckHomeMsg = "";
	String idcheckAuthentInputMsg = "";
	String idcheckAuthentHelpMsg = "";
	String idcheckErrMsg = "";
	String idcheckOnboardingErrMsg = "";
	String idcheckExpiredMsg = "";
	String idcheckLinkEmailSubject = "";
	String idcheckLinkEmailMsg = "";
	String idcheckLinkSmsMsg = "";
	String idcheckLinkEmailSignature = "";
	String idcheckLanguage = "";
	String idcheckEmailSenderName = "";
	String idcheckLogo = "";


	String idcheckDocToCaptCode = "";
	String idcheckDocToCaptType = "";
	String docCaptOptional = "";
	String versoHandling="";
	String livenessRefLocation = "";
	String livenessRefValue = "";
	String withDocLiveness="";
	String livenessLabel = "";
	String livenessDescription = "";
	String successRedirectUrl = "";
	String errorRedirectUrl = "";
	String autoRedirect = "";
	String notificationType="";
	String notificationValue="";
	String realm="";
	String fileLaunchCheck="";
	String fileCheckWait="";
	String fileTags="";
	String identificationCode="";
	String iframeDisplay="";
	String iframeRedirectParent="";
	String biometricConsent="";
	String legalHideLink="";
	String legalExternalLink="";
	String iframeCaptModeDesktop="";
	String iframeCaptModeMobile="";

	String configId="";
	String iframeConfId="";
	
	String partoo_api_key = "";
	String partoo_country_code = "";
	String partoo_org_id = "";
	String partoo_activated = "";
	String partoo_main_group = "";
	String partoo_language_id = "";

	if(rsPartoo.next())
	{
		partoo_api_key = parseNull(rsPartoo.value("partoo_api_key"));
		partoo_country_code = parseNull(rsPartoo.value("partoo_country_code"));
		partoo_org_id = parseNull(rsPartoo.value("partoo_organization_id"));
		partoo_activated = parseNull(rsPartoo.value("partoo_activated"));	
		partoo_main_group = parseNull(rsPartoo.value("partoo_main_group"));	
		partoo_language_id = parseNull(rsPartoo.value("partoo_language_id"));
	}

	String algoliaactivated = "0";
	String applicationid = "";
	String search_api_key = "";
	String write_api_key = "";
	String test_application_id = "";
	String test_search_api_key = "";
	String test_write_api_key = "";
	String excludenoindex = "";
	String algoliaversion = "";
	
	Set rsDefaultIndex = null;
	if(rsAlgolia.next())
	{
		rsDefaultIndex = Etn.execute("select * from algolia_default_index where site_id = "+escape.cote(selectedsiteid));
		
		algoliaactivated = parseNull(rsAlgolia.value("activated"));
		applicationid = parseNull(rsAlgolia.value("application_id"));
		search_api_key = parseNull(rsAlgolia.value("search_api_key"));	
		write_api_key = parseNull(rsAlgolia.value("write_api_key"));	
		test_application_id = parseNull(rsAlgolia.value("test_application_id"));
		test_search_api_key = parseNull(rsAlgolia.value("test_search_api_key"));	
		test_write_api_key = parseNull(rsAlgolia.value("test_write_api_key"));	
		excludenoindex = parseNull(rsAlgolia.value("exclude_noindex"));
		
		algoliaversion = parseNull(rsAlgolia.value("version"));
		
	}

	if(rsIdcheck.next())
	{
		idcheckEmail = parseNull(rsIdcheck.value("email"));
		idcheckPassword = parseNull(rsIdcheck.value("password"));
		idcheckBloc = parseNull(rsIdcheck.value("bloc_uuid"));
		idcheckActivated = parseNull(rsIdcheck.value("is_active"));
		idcheckCode = parseNull(rsIdcheck.value("code"));
		idcheckPathName = parseNull(rsIdcheck.value("path_name"));
		idcheckSupportEmail = parseNull(rsIdcheck.value("support_email"));
		idcheckLinkValidity = parseNull(rsIdcheck.value("link_validity"));
		idcheckBlockUpload = parseNull(rsIdcheck.value("block_upload"));
		idcheckCaptureModeDesktop = parseNull(rsIdcheck.value("capture_desktop"));
		idcheckCaptureModeMobile = parseNull(rsIdcheck.value("capture_mobile"));
		idcheckUploadPromptOnMobile = parseNull(rsIdcheck.value("prompt_mobile"));
		idcheckDisableImageBlackWhiteChecks = parseNull(rsIdcheck.value("image_blk_whe_chk"));
		idcheckDisableImageQualityChecks = parseNull(rsIdcheck.value("image_qty_chk"));
		idcheckTitleTxtColor = parseNull(rsIdcheck.value("title_txt_color"));
		idcheckHeaderBgColor = parseNull(rsIdcheck.value("header_bg_color"));
		idcheckBtnBgColor = parseNull(rsIdcheck.value("btn_bg_color"));
		idcheckBtnHoverBgColor = parseNull(rsIdcheck.value("btn_hover_bg_color"));
		idcheckBtnTxtColor = parseNull(rsIdcheck.value("btn_txt_color"));
		idcheckBtnBorderRadius = parseNull(rsIdcheck.value("btn_border_rad"));
		idcheckHideHeaderBorder = parseNull(rsIdcheck.value("hide_head_border"));
		idcheckHeaderLogoAlign = parseNull(rsIdcheck.value("head_logo_align"));
		idcheckEmailSenderName = parseNull(rsIdcheck.value("email_sender_name"));
		idcheckLogo = parseNull(rsIdcheck.value("logo"));
		configId = parseNull(rsIdcheck.value("id"));
	}

	if(rsIdcheckIframeConf.next())
	{
		iframeConfId = parseNull(rsIdcheckIframeConf.value("id"));
		successRedirectUrl = parseNull(rsIdcheckIframeConf.value("success_redirect_url"));
		errorRedirectUrl = parseNull(rsIdcheckIframeConf.value("error_redirect_url"));
		autoRedirect = parseNull(rsIdcheckIframeConf.value("auto_redirect"));
		notificationType = parseNull(rsIdcheckIframeConf.value("notification_type"));
		notificationValue = parseNull(rsIdcheckIframeConf.value("notification_value"));
		realm = parseNull(rsIdcheckIframeConf.value("realm"));
		fileLaunchCheck = parseNull(rsIdcheckIframeConf.value("file_launch_check"));
		fileCheckWait = parseNull(rsIdcheckIframeConf.value("file_check_wait"));
		fileTags = parseNull(rsIdcheckIframeConf.value("file_tags"));
		identificationCode = parseNull(rsIdcheckIframeConf.value("ident_code"));
		iframeDisplay = parseNull(rsIdcheckIframeConf.value("iframe_display"));
		iframeRedirectParent = parseNull(rsIdcheckIframeConf.value("iframe_redirect_parent"));
		biometricConsent = parseNull(rsIdcheckIframeConf.value("biometric_consent"));
		legalHideLink = parseNull(rsIdcheckIframeConf.value("legal_hide_link"));
		legalExternalLink = parseNull(rsIdcheckIframeConf.value("legal_external_link"));
		iframeCaptModeDesktop = parseNull(rsIdcheckIframeConf.value("iframe_capt_mode_desk"));
		iframeCaptModeMobile = parseNull(rsIdcheckIframeConf.value("iframe_capt_mode_mob"));
	}

	Map<String, List<String>> indexNames = new HashMap<String, List<String>>();

	Set rsAlgoliaIndexes = Etn.execute("select * from algolia_indexes where site_id = " + escape.cote(selectedsiteid) + " order by order_seq ");
	while(rsAlgoliaIndexes.next()) 
	{ 
		if(indexNames.get(rsAlgoliaIndexes.value("langue_id")) == null) indexNames.put(rsAlgoliaIndexes.value("langue_id"), new ArrayList<String>());
		indexNames.get(rsAlgoliaIndexes.value("langue_id")).add(parseNull(rsAlgoliaIndexes.value("index_name")));																				
	}
	
	Set rsAlgoliaRules = Etn.execute("select * from algolia_rules where site_id = " + escape.cote(selectedsiteid) + " order by order_seq ");

	int rowCnt=0;
	int rulesCount=0;

	Set rsProductTypes = Etn.execute("select * from product_types_v2 where site_id="+escape.cote(selectedsiteid)+" order by type_name");
	Set rsCatalogTypes = Etn.execute("select * from catalog_types order by name ");
	 
	Set rsStructPages = Etn.execute("SELECT id, name, custom_id FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates where site_id = "+escape.cote(selectedsiteid)+" and type = 'structured_page' order by name ");
	Set rsStructContents = Etn.execute("SELECT id, name, custom_id FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates where site_id = "+escape.cote(selectedsiteid)+" and type = 'structured_content' order by name ");
	Set rsStores = Etn.execute("SELECT id, name, custom_id FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates where site_id = "+escape.cote(selectedsiteid)+" and type = 'store' order by name ");
	Set rsForums =Etn.execute("select post_id as id, forum_topic as topic from "+GlobalParm.getParm("PORTAL_DB")+".client_reviews where site_id="+escape.cote(selectedsiteid)+" and type = 'forum' order by topic ");

	Map<String, String> indexTypes = new LinkedHashMap<String, String>();
	indexTypes.put("basic","Basic");
	indexTypes.put("products","Products");
	indexTypes.put("productv2","Products V2");
	indexTypes.put("productv3","Products V3");
	indexTypes.put("offers","Offers");
	indexTypes.put("customized","Customized");
	indexTypes.put("stores","Stores");
	indexTypes.put("forums","Forums");
 
	Map<String, String> elementTypes = new LinkedHashMap<String, String>();
	elementTypes.put("commercialcatalog", "Commercial Catalog");
	elementTypes.put("page", "Page");
	elementTypes.put("structuredpage", "Structured Page");
	elementTypes.put("structuredcontent", "Structured Content");
	elementTypes.put("store", "Store");
	elementTypes.put("forum", "Forum");
	elementTypes.put("new_product", "New Product");
	
	Map<String, Map<String, String>> elementsCriteria = new LinkedHashMap<String, Map<String, String>>();
	
	Map<String, String> criterias = new LinkedHashMap<String, String>();	
	criterias.put("name_contains", "Name (contains)");
	criterias.put("name_is", "Name (is)");
	criterias.put("type", "Type");
	elementsCriteria.put("commercialcatalog", criterias);

	criterias = new LinkedHashMap<String, String>();	
	criterias.put("name_contains", "Name (contains)");
	criterias.put("name_is", "Name (is)");
	criterias.put("type", "Product Type");
	elementsCriteria.put("new_product", criterias);

	criterias = new LinkedHashMap<String, String>();	
	criterias.put("name_contains", "Name (contains)");
	criterias.put("name_is", "Name (is)");
	criterias.put("tag", "Tag");
	criterias.put("url", "URL");
	elementsCriteria.put("page", criterias);
	
	criterias = new LinkedHashMap<String, String>();	
	criterias.put("topic_contains", "Topic (contains)");
	criterias.put("topic_is", "Topic (is)");
	criterias.put("category_contains", "Category (contains)");
	criterias.put("category_is", "Category (is)");
	elementsCriteria.put("forum", criterias);

	criterias = new LinkedHashMap<String, String>();	
	criterias.put("name_contains", "Name (contains)");
	criterias.put("name_is", "Name (is)");
	criterias.put("tag", "Tag");
	criterias.put("url", "URL");	
	criterias.put("type", "Type");
	elementsCriteria.put("structuredpage", criterias);
	
	criterias = new LinkedHashMap<String, String>();	
	criterias.put("name_contains", "Name (contains)");
	criterias.put("name_is", "Name (is)");
	criterias.put("type", "Type");
	elementsCriteria.put("structuredcontent", criterias);
	
	criterias = new LinkedHashMap<String, String>();	
	criterias.put("name_contains", "Name (contains)");
	criterias.put("name_is", "Name (is)");
	criterias.put("tag", "Tag");
	criterias.put("url", "URL");	
	criterias.put("type", "Type");
	elementsCriteria.put("store", criterias);
	
	Map<String, Integer> rulesShownPerLang = new HashMap<String, Integer>();
	List<Language> langsList = getLangs(Etn,selectedsiteid);
	for(Language _lng : langsList){
		rulesShownPerLang.put(_lng.getLanguageId(), 0);
	}	

	boolean setDisabled = false;
	Set rowRs = Etn.execute("SELECT site_id FROM "+GlobalParm.getParm("PAGES_DB")+".partoo_publish WHERE site_id = "+escape.cote(parseNull(rsPartoo.value("id")))+" UNION ALL SELECT site_id FROM "+GlobalParm.getParm("PAGES_DB")+".partoo_contents WHERE site_id = "+escape.cote(parseNull(rsPartoo.value("id"))));
	if(rowRs.rs.Rows > 0) setDisabled = true;
									
%>
<!DOCTYPE html>

<html>
<head>
<title>Module Parameters</title>

<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Module Parameters", ""});
%>

<script src="<%=request.getContextPath()%>/js/etn.asimina.js"></script>
<link href="<%=request.getContextPath()%>/css/bootstrap-colorpicker.min.css" rel="stylesheet">
<script src="<%=request.getContextPath()%>/js/bootstrap-colorpicker.min.js"></script>
<script type="text/javascript">
	window.PAGES_APP_URL = '<%=parseNull(GlobalParm.getParm("PAGES_APP_URL"))%>';
	window.MEDIA_LIBRARY_UPLOADS_URL = '<%=parseNull(GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL"))+selectedsiteid+"/"%>';
	window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = window.MEDIA_LIBRARY_UPLOADS_URL + 'img/';
</script>
<style>
.pill {
  display: inline-block;
  padding: 5px 10px;
  background-color: #ced2d8;
  color: #3c4b64;
  border-radius: 20px;
  margin-right: 5px;
  margin-bottom: 5px;
}
</style>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- container -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
		<div>
			<h1 class="h2">Module Parameters
			</h1>
			<p class="lead"></p>
		</div>
		<div class="btn-toolbar mb-2 mb-md-0">
			<div class="btn-group mr-2" role="group" aria-label="...">
				<button type="button" class="btn btn-success" onclick='onsave()'>Save</button>
				<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Module Parameters');" title="Add to shortcuts">
					<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
				</button>
			</div>
		</div>
	</div><!-- /d-flex -->

	<!-- /container -->


	<!-- container -->
	<div class="animated fadeIn">
		<!-- messages zone  -->
		<div class='m-b-20'>
			<div class="">
			<!-- info -->			
				<div id='infoBox' class="alert alert-success" role="alert" style='display:none'></div>
			<!-- /info -->
			<!-- error -->			
				<div id='errBox' class="alert alert-danger" role="alert" style='display:none'></div>
			<!-- /error -->
			</div>
		</div>
		<!-- messages zone  -->

		<!-- algolia parameters -->		
		<ul class="nav nav-tabs" role="tablist">
		<% 
		int zlng=0;
		for(Language _lng : langsList){	
			String _active = " active ";
			if(zlng++ > 0) _active = "";
		%>
			<li class="nav-item"><a class="nav-link <%=_active%>" id="home-tab-<%=_lng.getCode()%>" data-toggle="tab" href="#home" role="tab" aria-controls="home" aria-selected="true" data-index="<%=zlng%>" onclick="showMultiLang(this, '<%=_lng.getLanguageId()%>')"><%=_lng.getLanguage()%></a></li>
		<%}%>
		</ul>
		
		<div class="tab-content p-3">
		<div class="tab-pane fade show active">
			<form id='myfrm'>		
				<div class="card mb-2">
					<div class="card-header bg-secondary" data-toggle="collapse" href="#collapsePartooParams" role="button" aria-expanded="true" aria-controls="collapsePartooParams">
						<strong>Partoo</strong>
						<span style='margin-left:25px;font-size:11px'>(Partoo api will only be called for default language)</span>
					</div>
					<div class="collapse show p-3" id="collapsePartooParams" style="border: none;">
						<div class="card-body">
							<%
							//we cannot use UIHelper for these fields as in our case the indexes might not be filled for each language and these are dynamic rows
							zlng=0; 
							for(Language _lng : langsList)
							{	
								String dnone = "";
								if(zlng > 0) 
								{
									dnone = "display:none;";
								}
							%>
								<div style="<%=dnone%>" data-language-id="<%=_lng.getLanguageId()%>" class="langDiv">
									<div class="form-group row">
										<label for="partoo_activated" class="col-sm-3 col-form-label">Activated</label>
										<div class="col-sm-9">
											<select <%if(zlng==0){%>name='partoo_activated' onchange="duplicateField(this,'select', '_partoo_activated')"<%}else{%>disabled<%}%> id='partoo_activated_<%=_lng.getLanguageId()%>' class="custom-select _partoo_activated" aria-label="">
												<option <%if("0".equals(partoo_activated)) {%>selected<%}%> value="0">No</option>
												<option <%if("1".equals(partoo_activated)) {%>selected<%}%> value="1">Yes</option>
											</select>
										</div>
									</div>
									<div class="form-group row">
										<label for="partoo_api_key" class="col-sm-3 col-form-label">API KEY</label>
										<div class="col-sm-9">
											<input type="text"  <%if(zlng==0){%>name='partoo_api_key' onchange="duplicateField(this,'text', '_partoo_api_key')"<%}else{%>disabled<%}%> maxlength="255" class="form-control _partoo_api_key" id="partoo_api_key_<%=_lng.getLanguageId()%>" value="<%=partoo_api_key%>">
										</div>
									</div>
									<div class="form-group row">
										<label for="partoo_org_id" class="col-sm-3 col-form-label">Organization ID</label>
										<div class="col-sm-9">
											<input type="text"  <%if(zlng==0){%>name='partoo_org_id' onchange="duplicateField(this,'text', '_partoo_org_id')"<%}else{%>disabled<%}%> maxlength="255" class="form-control _partoo_org_id" id="partoo_org_id_<%=_lng.getLanguageId()%>" value="<%=partoo_org_id%>">
										</div>
									</div>
									<div class="form-group row">
										<label for="partoo_country_code" class="col-sm-3 col-form-label">Country Code<br><span style="font-size:11px">ISO 3166 alpha2 code</span></label>
										<div class="col-sm-9">
											<input type="text" <%if(setDisabled){%>readonly<%}%> <%if(zlng==0){%>name='partoo_country_code' onchange="duplicateField(this,'text', '_partoo_country_code')"<%}else{%>disabled<%}%> maxlength="2" class="form-control _partoo_country_code" id="partoo_country_code_<%=_lng.getLanguageId()%>" value="<%=partoo_country_code%>">
										</div>
									</div>
									<div class="form-group row">
										<label for="partoo_main_group" class="col-sm-3 col-form-label">Main Group</label>
										<div class="col-sm-9">
											<input type="text" <%if(setDisabled){%>readonly<%}%> <%if(zlng==0){%>name='partoo_main_group' onchange="duplicateField(this,'text', '_partoo_main_group')"<%}else{%>disabled<%}%> maxlength="255" class="form-control _partoo_main_group" id="partoo_main_group_<%=_lng.getLanguageId()%>" value="<%=partoo_main_group%>">
										</div>
									</div>
									<div class="form-group row">
										<label for="partoo_language_id" class="col-sm-3 col-form-label">Language</label>
										<div class="col-sm-9">
											<select <%if(zlng==0){%>name='partoo_language_id' onchange="duplicateField(this,'text', '_partoo_language_id')"<%}else{%>disabled<%}%> maxlength="255" class="form-control _partoo_language_id" id="partoo_language_id_<%=_lng.getLanguageId()%>">
											<% Set rsLg = Etn.execute("select * from language");
											while(rsLg.next()) {%>
											<option <%=(rsLg.value("langue_id").equals(partoo_language_id)?"selected":"")%> value="<%=rsLg.value("langue_id")%>"><%=rsLg.value("langue")%></option>
											<%}%>
											</select>
										</div>
									</div>
								</div><!-- lang div -->
							<%
								zlng++;
							}%>
						</div>
					</div>
				</div>

				<div class="card mb-2">
					<div class="card-header bg-secondary" data-toggle="collapse" href="#collapseGlobalParameters" role="button" aria-expanded="true" aria-controls="collapseGlobalParameters">
						<strong>Algolia</strong>
					</div>
					<div class="collapse p-3" id="collapseGlobalParameters" style="border: none;">
						<div class="card-body">
							<%
							//we cannot use UIHelper for these fields as in our case the indexes might not be filled for each language and these are dynamic rows
							zlng=0; 
							for(Language _lng : langsList)
							{	
								int indexRowsPerLang = 0;
								int rulesPerLang = 0;
								String dnone = "";
								if(zlng > 0) 
								{
									dnone = "display:none;";
								}
							%>
								<div style="<%=dnone%>" data-language-id="<%=_lng.getLanguageId()%>" class="langDiv">
									<div class="form-group row">
										<label for="activated" class="col-sm-3 col-form-label">Activated</label>
										<div class="col-sm-9">
											<select <%if(zlng==0){%>name='activated' onchange="duplicateField(this,'select', '_activated')"<%}else{%>disabled<%}%> id='activated_<%=_lng.getLanguageId()%>' class="custom-select _activated" aria-label="">
												<option <%if("0".equals(algoliaactivated)) {%>selected<%}%> value="0">No</option>
												<option <%if("1".equals(algoliaactivated)) {%>selected<%}%> value="1">Yes</option>
											</select>
										</div>
									</div>
									<div class="form-group row">
										<label for="" class="col-sm-3 col-form-label">&nbsp;</label>
										<div class="col-sm-9 row">
											<label for="" class="col-sm-6 col-form-label font-weight-bold">Test Site</label>
											<label for="" class="col-sm-6 col-form-label font-weight-bold">Prod Site</label>
										</div>
									</div>

									<div class="form-group row">
										<label for="application_id" class="col-sm-3 col-form-label">Application ID</label>
										<div class="col-sm-9 d-flex">
											<input type="text" <%if(zlng==0){%>name='test_application_id' onchange="duplicateField(this,'text', '_test_application_id')"<%}else{%>disabled<%}%> maxlength="255" class="col-sm-6 form-control _test_application_id" id="test_application_id_<%=_lng.getLanguageId()%>" value="<%=test_application_id%>">
											<input type="text" <%if(zlng==0){%>name='application_id' onchange="duplicateField(this,'text', '_application_id')"<%}else{%>disabled<%}%> maxlength="255" class="col-sm-6 form-control _application_id" id="application_id_<%=_lng.getLanguageId()%>" value="<%=applicationid%>">
										</div>
									</div>
									
									<div class="form-group row">
										<label for="search_api_key" class="col-sm-3 col-form-label">Search API KEY</label>
										<div class="col-sm-9 d-flex">
											<input type="text"  <%if(zlng==0){%>name='test_search_api_key' onchange="duplicateField(this,'text', '_test_search_api_key')"<%}else{%>disabled<%}%> maxlength="255" class="col-sm-6 form-control _test_search_api_key" id="test_search_api_key_<%=_lng.getLanguageId()%>" value="<%=test_search_api_key%>">
											<input type="text"  <%if(zlng==0){%>name='search_api_key' onchange="duplicateField(this,'text', '_search_api_key')"<%}else{%>disabled<%}%> maxlength="255" class="col-sm-6 form-control _search_api_key" id="search_api_key_<%=_lng.getLanguageId()%>" value="<%=search_api_key%>">
										</div>
									</div>
									<div class="form-group row">
										<label for="write_api_key" class="col-sm-3 col-form-label">Write API KEY</label>
										<div class="col-sm-9 d-flex">
											<input type="text"  <%if(zlng==0){%>name='test_write_api_key' onchange="duplicateField(this,'text', '_test_write_api_key')"<%}else{%>disabled<%}%> maxlength="255" class="col-sm-6 form-control _test_write_api_key" id="test_write_api_key_<%=_lng.getLanguageId()%>" value="<%=test_write_api_key%>">
											<input type="text"  <%if(zlng==0){%>name='write_api_key' onchange="duplicateField(this,'text', '_write_api_key')"<%}else{%>disabled<%}%> maxlength="255" class="col-sm-6 form-control _write_api_key" id="write_api_key_<%=_lng.getLanguageId()%>" value="<%=write_api_key%>">
										</div>
									</div>

									<div class="form-group row">
										<label for="api_key" class="col-sm-3 col-form-label">Exclude noindex</label>
										<div class="col-sm-1">
											<input type="checkbox" <%if(zlng==0){%>name='exclude_noindex' onchange="duplicateField(this,'chkbox', '_exclude_noindex')"<%}else{%>disabled<%}%> class="form-control _exclude_noindex" style="margin-left:0px !important" id="exclude_noindex_<%=_lng.getLanguageId()%>" <% if(excludenoindex.equals("1")) { %> checked <% } %> value="1">
										</div>
									</div>						
									<div class="form-group row">
										<label for="default_index_0" class="col-sm-3 col-form-label">Default index</label>
										<div class="col-sm-9">
											<% 
											String langDefaultIndex = "";
											if(rsDefaultIndex != null && rsDefaultIndex.rs.Rows > 0)
											{
												rsDefaultIndex.moveFirst();
												while(rsDefaultIndex.next())
												{
													if(rsDefaultIndex.value("langue_id").equals(_lng.getLanguageId()))
													{
														langDefaultIndex = parseNull(rsDefaultIndex.value("index_name"));
														break;
													}
												}
											}
											%>
											<select class="custom-select col-sm-2 default_index_list lang_<%=_lng.getLanguageId()%>_default_index" data-lang-code='<%=_lng.getCode()%>' data-lang-prefix='lang_<%=_lng.getLanguageId()%>' name='lang_<%=_lng.getLanguageId()%>_default_index' id='default_index_<%=zlng%>'>
												<option value="">-- Index --</option>										
												<% 
												if(indexNames.get(_lng.getLanguageId()) != null)
												{
													for(String k : indexNames.get(_lng.getLanguageId())) 
													{
														String selected = "";
														if(k.equals(langDefaultIndex)) selected = "selected";
														out.write("<option value='"+k+"' "+selected+">"+k+"</option>");
													}
												}
												%>
											</select>
										</div>
									</div>					
									
									<div class="form-group row">
										<div id='idxErr_<%=_lng.getLanguageId()%>' class="col-sm-12 alert alert-danger" role="alert" style='display:none'></div>
									</div>					
									
									<div id="indexes_<%=_lng.getLanguageId()%>">
									<%
										if(rsAlgoliaIndexes != null && rsAlgoliaIndexes.rs.Rows > 0) 
										{ 													
											rsAlgoliaIndexes.moveFirst();
											while(rsAlgoliaIndexes.next()) 
											{ 
												if(rsAlgoliaIndexes.value("langue_id").equals(_lng.getLanguageId()) == false) continue;
											%>
												<div class="form-group row">
													<label for="" class="col-sm-3 col-form-label"><%if(indexRowsPerLang == 0){%>Algolia index<%}else{%>&nbsp;<%}%></label>
													<div class="col-sm-9">
														<div class="input-group" >
															<select name='lang_<%=_lng.getLanguageId()%>_index_type' id='index_type_<%=rowCnt%>'  class='custom-select index_type'>
																<option value=''>-- Type --</option>
																<% for(String k : indexTypes.keySet()){
																	String selected = "";
																	if(parseNull(rsAlgoliaIndexes.value("index_type")).equals(k)) selected = " selected ";
																	
																	out.write("<option "+selected+" value='"+k+"'>"+indexTypes.get(k)+"</option>");
																}%>												
															</select>
															<input placeholder="Index name" type='text' onblur='checkerr(this)' data-row-cnt="<%=rowCnt%>" onkeyup="return forceLower(this);" onchange='indexNameChg(this,<%=_lng.getLanguageId()%>, <%=rowCnt%>)' class='form-control lang_<%=_lng.getLanguageId()%>_alg_index_name' id='index_name_<%=rowCnt%>' name='lang_<%=_lng.getLanguageId()%>_index_name' value='<%=parseNull(rsAlgoliaIndexes.value("index_name"))%>' >
															<input placeholder="Test Algolia index name" type='text' class='form-control algolia_index' id='test_algolia_index_<%=rowCnt%>' name='lang_<%=_lng.getLanguageId()%>_test_algolia_index' value='<%=parseNull(rsAlgoliaIndexes.value("test_algolia_index"))%>' >
															<input placeholder="Algolia index name" type='text' class='form-control algolia_index' id='algolia_index_<%=rowCnt%>' name='lang_<%=_lng.getLanguageId()%>_algolia_index' value='<%=parseNull(rsAlgoliaIndexes.value("algolia_index"))%>' >
														</div>
													</div>
												</div>
										<% 	
												rowCnt++;
												indexRowsPerLang++;
											}//while
										} //if
										int defaultRows = 3;
										defaultRows = defaultRows - indexRowsPerLang;
										if(defaultRows <= 0) defaultRows = 1;
										for(int i=0;i<defaultRows;i++) { %>
										<div class="form-group row" >
											<label for="" class="col-sm-3 col-form-label"><%if(indexRowsPerLang == 0){%>Algolia index<%}else{%>&nbsp;<%}%></label>
											<div class="col-sm-9">
												<div class="input-group">
													<select name='lang_<%=_lng.getLanguageId()%>_index_type' id='index_type_<%=rowCnt%>'  class='custom-select index_type' >
														<option value=''>-- Type --</option>
														<% for(String k : indexTypes.keySet()){
															out.write("<option value='"+k+"'>"+indexTypes.get(k)+"</option>");
														}%>												
													</select>
							
													<input type='text' placeholder="Index name"  onblur='checkerr(this)' data-row-cnt="<%=rowCnt%>" onkeyup="return forceLower(this);" onchange='indexNameChg(this,<%=_lng.getLanguageId()%>, <%=rowCnt%>)' class='form-control lang_<%=_lng.getLanguageId()%>_alg_index_name' id='index_name_<%=rowCnt%>' name='lang_<%=_lng.getLanguageId()%>_index_name' value='' >
													<input placeholder="Test Algolia index name" type='text' class='form-control algolia_index' id='test_algolia_index_<%=rowCnt%>' name='lang_<%=_lng.getLanguageId()%>_test_algolia_index' value='' >
													<input type='text' placeholder="Algolia index name"  class='form-control algolia_index' id='algolia_index_<%=rowCnt%>' name='lang_<%=_lng.getLanguageId()%>_algolia_index' value='' >
												</div>
											</div>
										</div>
										<% 
											rowCnt++;
											indexRowsPerLang++;
										}%>
									</div>					
									<div class="text-right mb-3"><button type="button" class="btn btn-success" onclick='addIndexRow("<%=_lng.getLanguageId()%>")'>Add an index</button></div>
									
									<div id="indexationRulesDiv_<%=_lng.getLanguageId()%>">
									<% 
									rsAlgoliaRules.moveFirst();
									while(rsAlgoliaRules.next()) 
									{ 						
										if(rsAlgoliaRules.value("langue_id").equals(_lng.getLanguageId()) == false) continue;
									
										int _ir = rulesShownPerLang.get(_lng.getLanguageId())+1;
										rulesShownPerLang.put(_lng.getLanguageId(), _ir);
										
										boolean showValDropDown = false;
										if((parseNull(rsAlgoliaRules.value("rule_type")).equals("commercialcatalog") || parseNull(rsAlgoliaRules.value("rule_type")).equals("new_product") || parseNull(rsAlgoliaRules.value("rule_type")).equals("structuredpage") || parseNull(rsAlgoliaRules.value("rule_type")).equals("structuredcontent") || parseNull(rsAlgoliaRules.value("rule_type")).equals("store")|| parseNull(rsAlgoliaRules.value("rule_type")).equals("forum"))
											&& parseNull(rsAlgoliaRules.value("rule_criteria")).equalsIgnoreCase("type")) showValDropDown = true;
									%>						
										<div class="form-group row" >
											<label for="" class="col-sm-3 col-form-label"><%if(rulesPerLang == 0) {%>Indexation rules<%} else {%>&nbsp;<%}%></label>
											<div class="col-sm-9">
												<div class="input-group">
													<select class="custom-select col-sm-3" name="lang_<%=_lng.getLanguageId()%>_rules_element_type" aria-label="" id='rulesEleType_<%=rulesCount%>' onchange="elementTypeChange(<%=_lng.getLanguageId()%>, <%=rulesCount%>)">
														<option value="">-- Type --</option>
														<% 
														for(String k : elementTypes.keySet())
														{	
															String selected=  "";
															if(k.equals(parseNull(rsAlgoliaRules.value("rule_type")))) selected = "selected";
															out.write("<option value='"+k+"' "+selected+">"+elementTypes.get(k)+"</option>");
														}
														%>
													</select>
													<select class="custom-select col-sm-3" name="lang_<%=_lng.getLanguageId()%>_rules_criteria" aria-label="" id='rulesCriteria_<%=rulesCount%>' onchange="elementCriteriaChange(<%=_lng.getLanguageId()%>, <%=rulesCount%>)">
														<option value="">-- Criteria --</option>
														<% 
														Map<String, String> criteriaMap = elementsCriteria.get(parseNull(rsAlgoliaRules.value("rule_type")));
														if(criteriaMap != null)
														{
															for(String k : criteriaMap.keySet())
															{
																String selected = "";
																if(k.equals(parseNull(rsAlgoliaRules.value("rule_criteria")))) selected = "selected";
																out.write("<option value='"+k+"' "+selected+">"+criteriaMap.get(k)+"</option>");
															}
														}
														%>
													</select>
													<span id='rulesEle_<%=rulesCount%>' class="col-sm-3">
													<%									
														if(showValDropDown)
														{
															out.write("<select class='custom-select rules_criteria_value' name='lang_"+_lng.getLanguageId()+"_rules_criteria_value'>");
															out.write("<option value=''>-- Type --</option>");
															if(parseNull(rsAlgoliaRules.value("rule_type")).equals("commercialcatalog"))
															{	
																rsCatalogTypes.moveFirst();
																while(rsCatalogTypes.next())
																{
																	String selected = "";
																	if(rsCatalogTypes.value("value").equals(parseNull(rsAlgoliaRules.value("rule_value")))) selected = "selected";
																	out.write("<option value='"+rsCatalogTypes.value("value")+"' "+selected+">"+rsCatalogTypes.value("name")+"</option>");
																}
															}
															else if(parseNull(rsAlgoliaRules.value("rule_type")).equals("new_product")) {
																rsProductTypes.moveFirst();
																while(rsProductTypes.next()) {
																	String selected = "";
																	if(rsProductTypes.value("id").equals(parseNull(rsAlgoliaRules.value("rule_value")))) selected = "selected";
																	out.write("<option value='"+rsProductTypes.value("id")+"' "+selected+">"+rsProductTypes.value("type_name")+"</option>");
																}
															}
															else if(parseNull(rsAlgoliaRules.value("rule_type")).equals("structuredpage"))
															{
																rsStructPages.moveFirst();
																while(rsStructPages.next())
																{
																	String selected = "";
																	if(rsStructPages.value("id").equals(parseNull(rsAlgoliaRules.value("rule_value")))) selected = "selected";
																	out.write("<option value='"+rsStructPages.value("id")+"' "+selected+">"+rsStructPages.value("name")+"</option>");
																}
															}								
															else if(parseNull(rsAlgoliaRules.value("rule_type")).equals("structuredcontent"))
															{
																rsStructContents.moveFirst();
																while(rsStructContents.next())
																{
																	String selected = "";
																	if(rsStructContents.value("id").equals(parseNull(rsAlgoliaRules.value("rule_value")))) selected = "selected";
																	out.write("<option value='"+rsStructContents.value("id")+"' "+selected+">"+rsStructContents.value("name")+"</option>");
																}
															}								
															else if(parseNull(rsAlgoliaRules.value("rule_type")).equals("store"))
															{
																rsStores.moveFirst();
																while(rsStores.next())
																{
																	String selected = "";
																	if(rsStores.value("id").equals(parseNull(rsAlgoliaRules.value("rule_value")))) selected = "selected";
																	out.write("<option value='"+rsStores.value("id")+"' "+selected+">"+rsStores.value("name")+"</option>");
																}
															}								
															else if(parseNull(rsAlgoliaRules.value("rule_type")).equals("forum"))
															{
																rsForums.moveFirst();
																while(rsForums.next())
																{
																	String selected = "";
																	if(rsForums.value("id").equals(parseNull(rsAlgoliaRules.value("rule_value")))) selected = "selected";
																	out.write("<option value='"+rsForums.value("id")+"' "+selected+">"+rsForums.value("topic")+"</option>");
																}
															}								
															out.write("</select>");
														}
														else 
														{
															out.write("<input type='text' class='form-control rules_criteria_value' placeholder='value' value='"+parseNull(rsAlgoliaRules.value("rule_value"))+"' name='lang_"+_lng.getLanguageId()+"_rules_criteria_value' >");
														}
													%>
													</span>
													<select class="custom-select col-sm-2 rules_index_list lang_<%=_lng.getLanguageId()%>_rules_index_list" name="lang_<%=_lng.getLanguageId()%>_rules_index" aria-label="" id='rulesIndex_<%=rulesCount%>'>
														<option value="">-- Index --</option>
														<%						
														if(indexNames.get(_lng.getLanguageId()) != null)
														{
															for(String k : indexNames.get(_lng.getLanguageId())) 
															{
																String selected = "";
																if(k.equals(parseNull(rsAlgoliaRules.value("index_name")))) selected = "selected";
																out.write("<option value='"+k+"' "+selected+">"+k+"</option>");
															}
														}
														%>
													</select>
													<select class="col-sm-1 custom-select lang_<%=_lng.getLanguageId()%>_exclude_from_default" name="lang_<%=_lng.getLanguageId()%>_exclude_from_default" data-toggle="tooltip" data-placement="top" title="Excluded of default index if YES">
														<option value="0">No</option>
														<option <%if("1".equals(parseNull(rsAlgoliaRules.value("exclude_from_default")))){%>selected<%}%> value="1">Yes</option>
													</select>
												</div>
											</div>
										</div>
									<% 
										rulesCount++;
										rulesPerLang++;
									} %>
									</div>	
									<div class="text-right mb-3"><button type="button" class="btn btn-success" onclick='addRuleLine("<%=_lng.getLanguageId()%>")'>Add a rule</button></div>							
								</div><!-- lang div -->
							<%
								zlng++;
							}%>
						</div>
					</div>
				</div>

				<div class="card mb-2">
					<div class="card-header bg-secondary" data-toggle="collapse" href="#collapseIDCheck" role="button" aria-expanded="true" aria-controls="collapseIDCheck">
						<strong>ID Check</strong>
					</div>
					<div class="collapse p-3" id="collapseIDCheck" style="border: none;">
						<div class="card-body">
							<%
							zlng=0; 
							for(Language _lng : langsList)
							{	
								
								Set rsWording = Etn.execute("SELECT * FROM "+GlobalParm.getParm("PORTAL_DB")+".idcheck_config_wordings where config_id="+escape.cote(configId)+" and langue_code="+escape.cote(_lng.getCode()));

								idcheckHomeTitle = "";
								idcheckHomeMsg = "";
								idcheckAuthentInputMsg = "";
								idcheckAuthentHelpMsg = "";
								idcheckErrMsg = "";
								idcheckOnboardingErrMsg = "";
								idcheckExpiredMsg = "";
								idcheckLinkEmailSubject = "";
								idcheckLinkEmailMsg = "";
								idcheckLinkEmailSignature = "";
								idcheckLinkSmsMsg = "";
								idcheckLanguage = "";
								

								if(rsWording != null && rsWording.next())
								{
									idcheckHomeTitle = parseNull(rsWording.value("home_title"));
									idcheckHomeMsg = parseNull(rsWording.value("home_msg"));
									idcheckAuthentInputMsg = parseNull(rsWording.value("auth_input_msg"));
									idcheckAuthentHelpMsg = parseNull(rsWording.value("auth_help_msg"));
									idcheckErrMsg = parseNull(rsWording.value("error_msg"));
									idcheckOnboardingErrMsg = parseNull(rsWording.value("onboarding_end_msg"));
									idcheckExpiredMsg = parseNull(rsWording.value("expired_msg"));
									idcheckLinkEmailSubject = parseNull(rsWording.value("link_email_subject"));
									idcheckLinkEmailMsg = parseNull(rsWording.value("link_email_msg"));
									idcheckLinkEmailSignature = parseNull(rsWording.value("link_email_signat"));
									idcheckLinkSmsMsg = parseNull(rsWording.value("link_sms_msg"));
									idcheckLanguage = parseNull(rsWording.value("langue_code"));
								}	

								String dnone = "";
								if(zlng > 0) 
								{
									dnone = "display:none;";
								}
							%>
							<div <% if(zlng!=0){ %>style="<%=dnone%>"<%}%> data-language-id="<%=_lng.getLanguageId()%>" class="langDiv">
								<div class="form-group row">
									<label for="idcheck-activated" class="col-sm-3 col-form-label">Activated</label>
									<div class="col-sm-9">
										<select <%if(zlng==0){%>name='idcheck-activated' onchange="duplicateField(this,'select', '_idcheck-activated')"<%}else{%>disabled<%}%> id='idcheck-activated_<%=_lng.getLanguageId()%>' class="custom-select _idcheck-activated" aria-label="">
											<option <%if("0".equals(idcheckActivated)) {%>selected<%}%> value="0">No</option>
											<option <%if("1".equals(idcheckActivated)) {%>selected<%}%> value="1">Yes</option>
										</select>
									</div>
								</div>

								<div class="form-group row">
									<label for="idcheck-email" class="col-sm-3 col-form-label">Email</label>
									<div class="col-sm-9">
										<input type="email"  <%if(zlng==0){%>name='idcheck-email' onchange="duplicateField(this,'text', '_idcheck-email')"<%}else{%>disabled<%}%> class="form-control _idcheck-email" value="<%=idcheckEmail%>">
									</div>
								</div>

								<div class="form-group row">
									<label for="idcheck-password" class="col-sm-3 col-form-label">Password</label>
									<div class="col-sm-9">
										<input type="password"  <%if(zlng==0){%>name='idcheck-password' onchange="duplicateField(this,'text', '_idcheck-password')"<%}else{%>disabled<%}%> class="form-control _idcheck-password" value="<%=idcheckPassword%>">
									</div>
								</div>

								<div class="form-group row">
									<label for="idcheck-bloc" class="col-sm-3 col-form-label">Bloc Name</label>
									<div class="col-sm-9">
										<select <%if(zlng==0){%>name='idcheck-bloc' onchange="duplicateField(this,'text', '_idcheck-bloc')"<%}else{%>disabled<%}%> class="form-control _idcheck-bloc">
											<option value="">--CHOOSE--</option>
											<%
												Set blocRs = Etn.execute("Select uuid,name from "+GlobalParm.getParm("PAGES_DB")+".blocs where site_id="+escape.cote(selectedsiteid));
												while(blocRs.next()){
											%>
												<option id="<%=blocRs.value("uuid")%>" value="<%=blocRs.value("uuid")%>" <%=(blocRs.value("uuid").equals(idcheckBloc))? "selected":""%> ><%=blocRs.value("name")%></option>
											<%}%>
										</select>
									</div>
								</div>

								<div class="card mb-2">
									<div class="card-header bg-secondary" data-toggle="collapse" href="#collapseIdcheckConfigurations" role="button" aria-expanded="true" aria-controls="collapseIdcheckConfigurations">
										<strong>Configurations</strong>
									</div>
									<div class="collapse show p-3" id="collapseIdcheckConfigurations" style="border: none;">
										<div class="card-body">
											<div class="form-group row">
												<label for="code" class="col-sm-3 col-form-label">Code</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='code' onchange="duplicateField(this,'text', '_code')"<%}else{%>disabled<%}%> class="form-control _code" value="<%=idcheckCode%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="path-name" class="col-sm-3 col-form-label">Path Name</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='path-name' onchange="duplicateField(this,'text', '_path-name')"<%}else{%>disabled<%}%> class="form-control _path-name" value="<%=idcheckPathName%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="email-sender-name" class="col-sm-3 col-form-label">Email Sender Name</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='email-sender-name' onchange="duplicateField(this,'text', '_email-sender-name')"<%}else{%>disabled<%}%> class="form-control _email-sender-name" value="<%=idcheckEmailSenderName%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="link-validity" class="col-sm-3 col-form-label">Link validity</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='link-validity' onchange="duplicateField(this,'text', '_link-validity')"<%}else{%>disabled<%}%> class="form-control _link-validity" value="<%=idcheckLinkValidity%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="support-email" class="col-sm-3 col-form-label">Support Email</label>
												<div class="col-sm-9">
													<input type="email"  <%if(zlng==0){%>name='support-email' onchange="duplicateField(this,'text', '_support-email')"<%}else{%>disabled<%}%> class="form-control _support-email" value="<%=idcheckSupportEmail%>">
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Block Upload</label>
												<div class="col-sm-1">
													<input type="checkbox" <%if(zlng==0){%>name='block-upload' onchange="duplicateField(this,'checkbox', '_block-upload')"<%}else{%>disabled<%}%> class="form-control _block-upload" <% if(idcheckBlockUpload.equalsIgnoreCase("1")){%>checked<%}%>>
												</div>
											</div>

											<div class="form-group row">
												<label for="idcheck-capture-mode-desktop" class="col-sm-3 col-form-label">Capture Mode On Desktop</label>
												<div class="col-sm-9">
													<select <%if(zlng==0){%>name='idcheck-capture-mode-desktop' onchange="duplicateField(this,'select', '_idcheck-capture-mode-desktop')"<%}else{%>disabled<%}%> id='idcheck-capture-mode-desktop-<%=_lng.getLanguageId()%>' class="custom-select _idcheck-capture-mode-desktop" aria-label="">
														<option value="">---CHOOSE---</option>
														<option <%if("CAMERA".equals(idcheckCaptureModeDesktop)) {%>selected<%}%> value="camera">Camera</option>
														<option <%if("UPLOAD".equals(idcheckCaptureModeDesktop)) {%>selected<%}%> value="upload">Upload</option>
														<option <%if("PROMPT".equals(idcheckCaptureModeDesktop)) {%>selected<%}%> value="prompt">Prompt</option>
													</select>
												</div>
											</div>

											<div class="form-group row">
												<label for="idcheck-capture-mode-mobile" class="col-sm-3 col-form-label">Capture Mode On Mobile</label>
												<div class="col-sm-9">
													<select <%if(zlng==0){%>name='idcheck-capture-mode-mobile' onchange="duplicateField(this,'select', '_idcheck-capture-mode-mobile')"<%}else{%>disabled<%}%> id='idcheck-capture-mode-mobile-<%=_lng.getLanguageId()%>' class="custom-select _idcheck-capture-mode-mobile" aria-label="">
														<option value="">---CHOOSE---</option>
														<option <%if("CAMERA".equals(idcheckCaptureModeMobile)) {%>selected<%}%> value="camera">Camera</option>
														<option <%if("UPLOAD".equals(idcheckCaptureModeMobile)) {%>selected<%}%> value="upload">Upload</option>
														<option <%if("PROMPT".equals(idcheckCaptureModeMobile)) {%>selected<%}%> value="prompt">Prompt</option>
													</select>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Upload Prompt On Mobile</label>
												<div class="col-sm-1">
													<input type="checkbox" <%if(zlng==0){%>name='prompt-on-mobile' onchange="duplicateField(this,'checkbox', '_prompt-on-mobile')"<%}else{%>disabled<%}%> class="form-control _prompt-on-mobile" <% if(idcheckUploadPromptOnMobile.equalsIgnoreCase("1")){%>checked<%}%>>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Disable Image Black And White Checks</label>
												<div class="col-sm-1">
													<input type="checkbox" <%if(zlng==0){%>name='disable-image-black-white-checks' onchange="duplicateField(this,'checkbox', '_disable-image-black-white-checks')"<%}else{%>disabled<%}%> class="form-control _disable-image-black-white-checks" <% if(idcheckDisableImageBlackWhiteChecks.equalsIgnoreCase("1")){%>checked<%}%>>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Disable Image Quality Checks</label>
												<div class="col-sm-1">
													<input type="checkbox" <%if(zlng==0){%>name='disable-image-quality-checks' onchange="duplicateField(this,'checkbox', '_disable-image-quality-checks')"<%}else{%>disabled<%}%> class="form-control _disable-image-quality-checks" <% if(idcheckDisableImageQualityChecks.equalsIgnoreCase("1")){%>checked<%}%>>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Logo <br><div class="d-flex"><div class="img-count"><%=(idcheckLogo.length() > 0)? "1":"0"%></div>&nbsp;/&nbsp;<div class="img-limit">1</div></div></label>
												<div class="col-sm-9">
													<div class="card image_card" data-img-limit="1">
														<div class="card-body"> 
															<%if(idcheckLogo.length()>0){%>
																<span class="ui-state-media-default" style="padding:0px;display: inline-block;">
																	<div class="bloc-edit-media">
																		<button type="button" class="btn btn-primary mx-1" style="margin-right: .10rem;" onclick='loadFieldImageV2(this,true)'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
																		<button type="button" class="btn btn-danger mx-1" style="margin-right: .1rem;" onclick='clearFieldImageV2(this)' ><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></button>
																	</div>
																	<div class="bloc-edit-media-bgnd" style="height:100%; width:100%; min-width:145px; min-height:145px; position:absolute; left:0; top:0">&nbsp;</div>
																	<input type="hidden" name="image_value" class="image_value" value="<%=idcheckLogo%>" />
																	<input type="hidden" name="image_alt" class="image_alt" value="<%=idcheckLogo%>" />
																	<img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="<%=parseNull(GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL"))+selectedsiteid+"/img/"+idcheckLogo%>">
																</span>	
															<%}%>
															<span class="ui-state-media-default" style="padding:0px;display: inline-block;">
																<div class="bloc-edit-media">
																	<button type="button" class="btn btn-success load-img" style="margin-right: .10rem;<%= idcheckLogo.length() > 0 ? "display:none":""%>" onclick="loadFieldImageV2(this,false)">Add a media</button>
																	<button type="button" class="btn btn-danger disabled no-img" style="margin-right: .10rem;<%= idcheckLogo.length() > 0 ? "":"display:none"%>">No more media</button>
																</div>
																<div class="bloc-edit-media-bgnd" style="height:100%; width:100%;min-width:145px;min-height:145px;  position:absolute; left:0; top:0">&nbsp;</div>
																<img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="<%=GlobalParm.getParm("EXTERNAL_CATALOG_LINK")%>img/add-picture-on.jpg">	
															</span>															
														</div>														
													</div>
												</div>
											</div>

											<div class="form-group row">
												<label for="title-txt-color" class="col-sm-3 col-form-label">Title Text Color</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='title-txt-color' onchange="duplicateField(this,'text', '_title-txt-color')"<%}else{%>disabled<%}%> class="form-control _title-txt-color color-picker" value="<%=idcheckTitleTxtColor%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="header-bg-color" class="col-sm-3 col-form-label">Header Background Color</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='header-bg-color' onchange="duplicateField(this,'text', '_header-bg-color')"<%}else{%>disabled<%}%> maxlength="255" class="form-control _header-bg-color color-picker" value="<%=idcheckHeaderBgColor%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="btn-bg-color" class="col-sm-3 col-form-label">Button Background Color</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='btn-bg-color' onchange="duplicateField(this,'text', '_btn-bg-color')"<%}else{%>disabled<%}%> maxlength="255" class="form-control _btn-bg-color color-picker" value="<%=idcheckBtnBgColor%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="btn-hover-bg-color" class="col-sm-3 col-form-label">Button Hover Background Color</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='btn-hover-bg-color' onchange="duplicateField(this,'text', '_btn-hover-bg-color')"<%}else{%>disabled<%}%> class="form-control _btn-hover-bg-color color-picker" value="<%=idcheckBtnHoverBgColor%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="btn-txt-color" class="col-sm-3 col-form-label">Button Text Color</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='btn-txt-color' onchange="duplicateField(this,'text', '_btn-txt-color')"<%}else{%>disabled<%}%> class="form-control _btn-txt-color color-picker" value="<%=idcheckBtnTxtColor%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="btn-border-radius" class="col-sm-3 col-form-label">Button Border Radius</label>
												<div class="col-sm-9">
													<input type="text"  <%if(zlng==0){%>name='btn-border-radius' onchange="duplicateField(this,'text', '_btn-border-radius')"<%}else{%>disabled<%}%> class="form-control _btn-border-radius" value="<%=idcheckBtnBorderRadius%>">
												</div>
											</div>

											<div class="form-group row">
												<label for="header-logo-align" class="col-sm-3 col-form-label">Header Logo Align</label>
												<div class="col-sm-9">
													<select <%if(zlng==0){%>name='header-logo-align' onchange="duplicateField(this,'text', '_header-logo-align')"<%}else{%>disabled<%}%> class="custom-select _header-logo-align">
															<option value="">---CHOOSE---</option>
															<option value="left" <%if(idcheckHeaderLogoAlign.equalsIgnoreCase("left")){%>selected<%}%>>Left</option>
															<option value="right"<%if(idcheckHeaderLogoAlign.equalsIgnoreCase("right")){%>selected<%}%>>Right</option>
															<option value="center" <%if(idcheckHeaderLogoAlign.equalsIgnoreCase("center")){%>selected<%}%>>Center</option>
													</select>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Hide Header Border</label>
												<div class="col-sm-1">
													<input type="checkbox" <%if(zlng==0){%>name='hide-header-border' onchange="duplicateField(this,'checkbox', '_hide-header-border')"<%}else{%>disabled<%}%> class="form-control _hide-header-border" <% if(idcheckHideHeaderBorder.equalsIgnoreCase("1")){%>checked<%}%>>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Home Title</label>
												<div class="col-sm-9">
													<input type="text" name='home-title' class="form-control" value="<%=idcheckHomeTitle%>">
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Home Message</label>
												<div class="col-sm-9">
													<textarea name='idcheck-home-msg' class="form-control" rows="3"><%=idcheckHomeMsg%></textarea>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Authenticated Input Message</label>
												<div class="col-sm-9">
													<textarea name='authent-input-msg' class="form-control" rows="3"><%=idcheckAuthentInputMsg%></textarea>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Authenticated Help Message</label>
												<div class="col-sm-9">
													<textarea name='authent-help-msg' class="form-control" rows="3"><%=idcheckAuthentHelpMsg%></textarea>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Error Message</label>
												<div class="col-sm-9">
													<textarea name='err_msg' class="form-control" rows="3"><%=idcheckErrMsg%></textarea>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">On Boarding End Message</label>
												<div class="col-sm-9">
													<textarea name='onboarding-end-msg' class="form-control" rows="3"><%=idcheckOnboardingErrMsg%></textarea>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Expired Message</label>
												<div class="col-sm-9">
													<textarea name='expired-msg' class="form-control" rows="3"><%=idcheckExpiredMsg%></textarea>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Link Email Subject</label>
												<div class="col-sm-9">
													<input type="text" name='link-email-subject' class="form-control" value="<%=idcheckLinkEmailSubject%>">
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Link Email Message</label>
												<div class="col-sm-9">
													<textarea name='link-email-msg' class="form-control" rows="3"><%=idcheckLinkEmailMsg%></textarea>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Link Email Signature</label>
												<div class="col-sm-9">
													<textarea name='link-email-signature' class="form-control" rows="3"><%=idcheckLinkEmailSignature%></textarea>
												</div>
											</div>

											<div class="form-group row">
												<label class="col-sm-3 col-form-label">Link Sms Message</label>
												<div class="col-sm-9">
													<textarea name='link-sms-msg' class="form-control" rows="3"><%=idcheckLinkSmsMsg%></textarea>
												</div>
											</div>
											<input type="hidden" name='language' class="form-control" id="language" value="<%=_lng.getCode()%>">
										</div>
									</div>
								</div>
								<div class="card mb-2">
									<div class="card-header bg-secondary" data-toggle="collapse" href="#collapseIdcheckIframeConfigurations" role="button" aria-expanded="true" aria-controls="collapseIdcheckIframeConfigurations">
										<strong>Iframe Configurations</strong>
									</div>
									<div class="collapse p-3" id="collapseIdcheckIframeConfigurations" style="border: none;">
										<div class="card-body">
											<%
												int count=0;
												Set rsDocToCapt = Etn.execute("SELECT * FROM "+GlobalParm.getParm("PORTAL_DB")+".idcheck_doc_capture_conf WHERE idcheck_iframe_conf_id="+escape.cote(iframeConfId)+" ORDER BY id");
												while(rsDocToCapt.next())
												{
													
													idcheckDocToCaptCode = parseNull(rsDocToCapt.value("capture_code"));
													idcheckDocToCaptType = parseNull(rsDocToCapt.value("doc_type"));
													docCaptOptional = parseNull(rsDocToCapt.value("optional"));
													versoHandling = parseNull(rsDocToCapt.value("verso_handling"));
													withDocLiveness = parseNull(rsDocToCapt.value("with_doc_liveness"));
													livenessLabel = parseNull(rsDocToCapt.value("liveness_label"));
													livenessDescription = parseNull(rsDocToCapt.value("liveness_description"));
													livenessRefLocation = parseNull(rsDocToCapt.value("liveness_ref_location"));
													livenessRefValue = parseNull(rsDocToCapt.value("liveness_ref_value"));
											%>
												<div class="doc-to-capture">
													<% if(count != 0){%><hr><%}%>
													<h4 class="mb-3">Document To Capture</h4>
													<div class="px-3">
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">Code</label>
															<div class="col-sm-9">
																<input name='doc-to-capt-code' <%if(zlng==0){%>name='doc-to-capt-code' onchange="duplicateField(this,'checkbox', '_doc-to-capt-code')"<%}else{%>disabled<%}%> class="form-control _doc-to-capt-code" value="<%=idcheckDocToCaptCode%>" >
															</div>
														</div>
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">Type</label>
															<div class="col-sm-9">
																<select <%if(zlng==0){%>onchange="duplicateField(this,'checkbox', '_doc-to-capt-type');handleSelectChange(this)"<%}else{%>disabled<%}%> class="form-control _doc-to-capt-type doc-type-select">
																	<option value="">---CHOOSE---</option>
																	<option value="ID">National ID card</option>
																	<option value="P">Passport</option>
																	<option value="V">Visa</option>
																	<option value="DL">Driving License</option>
																	<option value="HC">Health card</option>
																	<option value="RP">Residence permit</option>
																	<option value="SELFIE">User picture</option>
																	<option value="LIVENESS">Liveness Detection test</option>
																	<option value="CAR_REG">French Vehicle Registration</option>
																	<option value="KBIS">French Corporate certificate</option>
																	<option value="RIB">Bank details</option>
																	<option value="ADR_PROOF">French Proof of address</option>
																	<option value="PAY_SHEET">French Payslip</option>
																	<option value="TAX_SHEET">French Tax statement</option>
																	<option value="OTHER">Other type of document</option>
																</select>
																<input type="hidden" name='doc-to-capt-type' value="<%=idcheckDocToCaptType%>">
															</div>
															<div class="pill-container d-flex mt-2 col-sm-9">
															<%	for(String type : idcheckDocToCaptType.split(","))
																{%>
																	<span class="pill d-flex"><%=type%><div class="remove-button moringa-orange-color pl-1" onclick="removePill()" style="cursor: pointer;">&times;</div></span>
																<%}%>
															</div>
														</div>
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">Optional</label>
															<div class="col-sm-1">
																<input type="checkbox" <%if(zlng==0){%>name='doc-capt-optional' onchange="duplicateField(this,'checkbox', '_doc-capt-optional')"<%}else{%>disabled<%}%> class="form-control _doc-capt-optional" <% if(docCaptOptional.equalsIgnoreCase("1")){%>checked<%}%>>
															</div>
														</div>
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">Verso Handling</label>
															<div class="col-sm-9">
																<select class="form-control _verso-handling" <%if(zlng==0){%>name='verso-handling' onchange="duplicateField(this,'checkbox', '_verso-handling')"<%}else{%>disabled<%}%>>
																	<option value="">---CHOOSE---</option>
																	<option value="DEFAULT" <% if(versoHandling.equalsIgnoreCase("DEFAULT")){ %>selected<% } %>>Default</option>
																	<option value="MANDATORY" <% if(versoHandling.equalsIgnoreCase("MANDATORY")){ %>selected<% } %>>Mandatory</option>
																	<option value="OPTIONAL" <% if(versoHandling.equalsIgnoreCase("OPTIONAL")){ %>selected<% } %>>Optional</option>
																</select>
															</div>
														</div>
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">With Doc Liveness</label>
															<div class="col-sm-1">
																<input type="checkbox" <%if(zlng==0){%>name='doc-capt-with-liveness' onchange="duplicateField(this,'checkbox', '_doc-capt-with-liveness')"<%}else{%>disabled<%}%> class="form-control _doc-capt-with-liveness" <% if(withDocLiveness.equalsIgnoreCase("1")){%>checked<%}%>>
															</div>
														</div>
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">Label</label>
															<div class="col-sm-9">
																<input <%if(zlng==0){%>name='doc-to-capt-label' onchange="duplicateField(this,'checkbox', '_doc-to-capt-label')"<%}else{%>disabled<%}%> class="form-control _doc-to-capt-label" value="<%=livenessLabel%>" >
															</div>
														</div>
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">Description</label>
															<div class="col-sm-9">
																<textarea <%if(zlng==0){%>name='doc-to-capt-descript' onchange="duplicateField(this,'checkbox', '_doc-to-capt-descript')"<%}else{%>disabled<%}%> class="form-control _doc-to-capt-descript"><%=livenessDescription%></textarea>
															</div>
														</div>
													</div>

													<hr>
													<h4>Liveness Reference Document</h4>

													<div class="px-3">
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">Location</label>
															<div class="col-sm-9">
																<select <%if(zlng==0){%>name='liveness-ref-location' onchange="duplicateField(this,'checkbox', '_liveness-ref-location')"<%}else{%>disabled<%}%> class="form-control _liveness-ref-location">
																	<option value="">---CHOOSE---</option>
																	<option value="ONBOARDING" <% if(livenessRefLocation.equalsIgnoreCase("ONBOARDING")){ %>selected<% } %> >ONBOARDING</option>
																	<option value="CIS" <% if(livenessRefLocation.equalsIgnoreCase("CIS")){ %>selected<% } %> >CIS</option>
																</select>
															</div>
														</div>
														<div class="form-group row">
															<label class="col-sm-3 col-form-label">Liveness Reference Value</label>
															<div class="col-sm-9">
																<div class="w-100">
																	<input <%if(zlng==0){%>name='liveness-ref-value' onchange="duplicateField(this,'checkbox', '_liveness-ref-value')"<%}else{%>disabled<%}%> class="form-control _liveness-ref-value" value="<%=livenessRefValue%>" >
																</div>
																<div>
																	<small>The CIS ID or document code for reference document.</small>
																</div>
															</div>
														</div>
													</div>
												</div>
											<%
													count = count + 1;
												}
											%>
											<div class="<%if(zlng!=0){%>d-none<%}%>"> 
												<button type="button" class="btn btn-primary" onclick="addDocToCap(this)">Add Document To Capture</button>
												<button type="button" class="btn btn-danger <%if(count<=1){%>d-none<%}%>" onclick="removeDocToCap(this)">Remove Document To Capture</button>
											</div>

											<hr>
											<h4>Redirection Data</h4>

											<div class="px-3">
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Success Redirect URL</label>
													<div class="col-sm-9">
														<input <%if(zlng==0){%>name='success-redirect-url' onchange="duplicateField(this,'checkbox', '_success-redirect-url')"<%}else{%>disabled<%}%> class="form-control _success-redirect-url" value="<%=successRedirectUrl%>">
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Error Redirect URL</label>
													<div class="col-sm-9">
														<input <%if(zlng==0){%>name='error-redirect-url' onchange="duplicateField(this,'checkbox', '_error-redirect-url')"<%}else{%>disabled<%}%> class="form-control _error-redirect-url" value="<%=errorRedirectUrl%>">
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Auto Redirect</label>
													<div class="col-sm-1">
														<input type="checkbox" <%if(zlng==0){%>name='auto-redirect' onchange="duplicateField(this,'checkbox', '_auto-redirect')"<%}else{%>disabled<%}%> class="form-control _auto-redirect" <% if(autoRedirect.equalsIgnoreCase("1")){%>checked<%}%>>
													</div>
												</div>
											</div>

											<hr>
											<h4>Contact Data</h4>

											<div class="px-3">
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Notification Type</label>
													<div class="col-sm-9">
														<select <%if(zlng==0){%>name='notify-type' onchange="duplicateField(this,'checkbox', '_notify-type')"<%}else{%>disabled<%}%> class="form-control _notify-type">
															<option value="">---CHOOSE---</option>
															<option value="EMAIL" <% if(notificationType.equalsIgnoreCase("EMAIL")){ %>selected<% } %>>EMAIL</option>
															<option value="PHONE" <% if(notificationType.equalsIgnoreCase("PHONE")){ %>selected<% } %>>PHONE</option>
															<option value="NONE" <% if(notificationType.equalsIgnoreCase("NONE")){ %>selected<% } %>>NONE</option>
														</select>
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Notification Value</label>
													<div class="col-sm-9">
														<input <%if(zlng==0){%>name='notify-type-value' onchange="duplicateField(this,'checkbox', '_notify-type-value')"<%}else{%>disabled<%}%> class="form-control _notify-type-value" value="<%=notificationValue%>">
													</div>
												</div>
											</div>

											<hr>
											<h4>CIS Configurations</h4>

											<div class="px-3">
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Realm</label>
													<div class="col-sm-9">
														<input <%if(zlng==0){%>name='cisconf-realm' onchange="duplicateField(this,'checkbox', '_cisconf-realm')"<%}else{%>disabled<%}%> class="form-control _cisconf-realm" value="<%=realm%>">
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">File Launch Check</label>
													<div class="col-sm-1">
														<input type="checkbox" <%if(zlng==0){%>name='file-launch-check' onchange="duplicateField(this,'checkbox', '_file-launch-check')"<%}else{%>disabled<%}%> class="form-control _file-launch-check" <% if(fileLaunchCheck.equalsIgnoreCase("1")){%>checked<%}%>>
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">File Check Wait</label>
													<div class="col-sm-1">
														<input type="checkbox" <%if(zlng==0){%>name='file-check-wait' onchange="duplicateField(this,'checkbox', '_file-check-wait')"<%}else{%>disabled<%}%> class="form-control _file-check-wait" <% if(fileCheckWait.equalsIgnoreCase("1")){%>checked<%}%>>
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">File Tags</label>
													<div class="col-sm-9">
														<input <%if(zlng==0){%>name='cisconf-filetags' onchange="duplicateField(this,'checkbox', '_cisconf-filetags')"<%}else{%>disabled<%}%> class="form-control _cisconf-filetags" value="<%=fileTags%>">
													</div>
												</div>
											</div>

											<hr>
											<h4>Onboarding Options</h4>

											<div class="px-3">
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Identification Code</label>
													<div class="col-sm-9">
														<input <%if(zlng==0){%>name='identification-code' onchange="duplicateField(this,'checkbox', '_identification-code')"<%}else{%>disabled<%}%> class="form-control _identification-code" value="<%=identificationCode%>">
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Iframe Display</label>
													<div class="col-sm-1">
														<input type="checkbox" <%if(zlng==0){%>name='iframe-display' onchange="duplicateField(this,'checkbox', '_iframe-display')"<%}else{%>disabled<%}%> class="form-control _iframe-display" <% if(iframeDisplay.equalsIgnoreCase("1")){%>checked<%}%>>
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Iframe Redirect Parent</label>
													<div class="col-sm-1">
														<input type="checkbox" <%if(zlng==0){%>name='iframe-redirect-parent' onchange="duplicateField(this,'checkbox', '_iframe-redirect-parent')"<%}else{%>disabled<%}%> class="form-control _iframe-redirect-parent" <% if(iframeRedirectParent.equalsIgnoreCase("1")){%>checked<%}%>>
													</div>
												</div>
											</div>

											<hr>
											<h3>Consent</h3>

											<div class="px-3">
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Biometric Consent</label>
													<div class="col-sm-1">
														<input type="checkbox" <%if(zlng==0){%>name='biometric-consent' onchange="duplicateField(this,'checkbox', '_biometric-consent')"<%}else{%>disabled<%}%> class="form-control _biometric-consent" <% if(biometricConsent.equalsIgnoreCase("1")){%>checked<%}%>>
													</div>
												</div>
											</div>

											<hr>
											<h3>Legal Mentions</h3>

											<div class="px-3">
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Hide link</label>
													<div class="col-sm-1">
														<input type="checkbox" <%if(zlng==0){%>name='hide-link' onchange="duplicateField(this,'checkbox', '_hide-link')"<%}else{%>disabled<%}%> class="form-control _hide-link" <% if(legalHideLink.equalsIgnoreCase("1")){%>checked<%}%>>
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">External Link</label>
													<div class="col-sm-9">
														<input <%if(zlng==0){%>name='legal-external-link' onchange="duplicateField(this,'checkbox', '_legal-external-link')"<%}else{%>disabled<%}%> class="form-control _legal-external-link" value="<%=legalExternalLink%>">
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Capture Mode Desktop</label>
													<div class="col-sm-9">
														<select name='iframe-capture-mode-desktop' <%if(zlng==0){%>name='iframe-capture-mode-desktop' onchange="duplicateField(this,'checkbox', '_iframe-capture-mode-desktop')"<%}else{%>disabled<%}%> class="form-control _iframe-capture-mode-desktop">
															<option value="">---CHOOSE---</option>
															<option value="CAMERA" <% if(iframeCaptModeDesktop.equalsIgnoreCase("CAMERA")){ %>selected<% } %> >Camera</option>
															<option value="UPLOAD" <% if(iframeCaptModeDesktop.equalsIgnoreCase("UPLOAD")){ %>selected<% } %> >Upload</option>
															<option value="PROMPT" <% if(iframeCaptModeDesktop.equalsIgnoreCase("PROMPT")){ %>selected<% } %>>Prompt</option>
														</select>
													</div>
												</div>
												<div class="form-group row">
													<label class="col-sm-3 col-form-label">Capture Mode Mobile</label>
													<div class="col-sm-9">
														<select <%if(zlng==0){%>name='iframe-capture-mode-mobile' onchange="duplicateField(this,'checkbox', '_iframe-capture-mode-mobile')"<%}else{%>disabled<%}%> class="form-control _iframe-capture-mode-mobile">
															<option value="">---CHOOSE---</option>
															<option value="CAMERA" <% if(iframeCaptModeMobile.equalsIgnoreCase("CAMERA")){ %>selected<% } %> >Camera</option>
															<option value="UPLOAD" <% if(iframeCaptModeMobile.equalsIgnoreCase("UPLOAD")){ %>selected<% } %> >Upload</option>
															<option value="PROMPT" <% if(iframeCaptModeMobile.equalsIgnoreCase("PROMPT")){ %>selected<% } %> >Prompt</option>
														</select>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>

							<%
									zlng++;
								}
							%>
							
						</div>
					</div>
				</div>
			</form>	
			</div>		
		</div>
		</div><!-- tab-content -->
		<!-- algolia parameters -->
		<br>
		<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	<br>
</main>

<template class="add-doc-capt">
	<div class="doc-to-capture">
		<hr>
		<h4 class="mb-3">Document To Capture</h4>
		<div class="px-3">
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">Code</label>
				<div class="col-sm-9">
					<input name='doc-to-capt-code' name='doc-to-capt-code' onchange="duplicateField(this,'checkbox', '_doc-to-capt-code')" class="form-control _doc-to-capt-code" value="" >
				</div>
			</div>
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">Type</label>
				<div class="col-sm-9">
					<select  onchange="duplicateField(this,'checkbox', '_doc-to-capt-type');handleSelectChange(this)" class="form-control _doc-to-capt-type doc-type-select">
						<option value="">---CHOOSE---</option>
						<option value="ID">National ID card</option>
						<option value="P">Passport</option>
						<option value="V">Visa</option>
						<option value="DL">Driving License</option>
						<option value="HC">Health card</option>
						<option value="RP">Residence permit</option>
						<option value="SELFIE">User picture</option>
						<option value="LIVENESS">Liveness Detection test</option>
						<option value="CAR_REG">French Vehicle Registration</option>
						<option value="KBIS">French Corporate certificate</option>
						<option value="RIB">Bank details</option>
						<option value="ADR_PROOF">French Proof of address</option>
						<option value="PAY_SHEET">French Payslip</option>
						<option value="TAX_SHEET">French Tax statement</option>
						<option value="OTHER">Other type of document</option>
					</select>
					<input type="hidden" name='doc-to-capt-type' value="">
				</div>
				<div class="pill-container d-flex mt-2">
				</div>
			</div>
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">Optional</label>
				<div class="col-sm-1">
					<input type="checkbox" name='doc-capt-optional' onchange="duplicateField(this,'checkbox', '_doc-capt-optional')" class="form-control _doc-capt-optional" >
				</div>
			</div>
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">Verso Handling</label>
				<div class="col-sm-9">
					<select class="form-control _verso-handling" name='verso-handling' onchange="duplicateField(this,'checkbox', '_verso-handling')">
						<option value="">---CHOOSE---</option>
						<option value="DEFAULT">Default</option>
						<option value="MANDATORY">Mandatory</option>
						<option value="OPTIONAL">Optional</option>
					</select>
				</div>
			</div>
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">With Doc Liveness</label>
				<div class="col-sm-1">
					<input type="checkbox" name='doc-capt-with-liveness' onchange="duplicateField(this,'checkbox', '_doc-capt-with-liveness')" class="form-control _doc-capt-with-liveness">
				</div>
			</div>
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">Label</label>
				<div class="col-sm-9">
					<input name='doc-to-capt-label' onchange="duplicateField(this,'checkbox', '_doc-to-capt-label')" class="form-control _doc-to-capt-label" value="" >
				</div>
			</div>
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">Description</label>
				<div class="col-sm-9">
					<textarea name='doc-to-capt-descript' onchange="duplicateField(this,'checkbox', '_doc-to-capt-descript')" class="form-control _doc-to-capt-descript"></textarea>
				</div>
			</div>
		</div>

		<hr>
		<h4>Liveness Reference Document</h4>

		<div class="px-3">
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">Location</label>
				<div class="col-sm-9">
					<select name='liveness-ref-location' onchange="duplicateField(this,'checkbox', '_liveness-ref-location')" class="form-control _liveness-ref-location">
						<option value="">---CHOOSE---</option>
						<option value="ONBOARDING">ONBOARDING</option>
						<option value="CIS">CIS</option>
					</select>
				</div>
			</div>
			<div class="form-group row">
				<label class="col-sm-3 col-form-label">Liveness Reference Value</label>
				<div class="col-sm-9">
					<div class="w-100">
						<input name='liveness-ref-value' onchange="duplicateField(this,'checkbox', '_liveness-ref-value')" class="form-control _liveness-ref-value" value="" >
					</div>
					<div>
						<small>The CIS ID or document code for reference document.</small>
					</div>
				</div>
			</div>
		</div>
	</div>
</template>


<div style='display:none' id='indexTemplate'>
	<div class="form-group row" >
		<label for="" class="col-sm-3 col-form-label">&nbsp;</label>
		<div class="col-sm-9">
			<div class="input-group">
				<select name='lang_##langid##_index_type' id='index_type_##rowCnt##'  class='custom-select index_type' >
					<option value=''>-- Type --</option>
					<% for(String k : indexTypes.keySet()){
						out.write("<option value='"+k+"'>"+indexTypes.get(k)+"</option>");
					}%>												
				</select>
				<input type='text' placeholder="Index name"  onblur='checkerr(this)' data-row-cnt="##rowCnt##" onkeyup="return forceLower(this);" onchange='indexNameChg(this, ##langid##, ##rowCnt##)' class='form-control lang_##langid##_alg_index_name' id='index_name_##rowCnt##' name='lang_##langid##_index_name' value=''>
				<input placeholder="Test Algolia index name" type='text'   class='form-control algolia_index' id='test_algolia_index_##rowCnt##' name='lang_##langid##_test_algolia_index' value=''>
				<input type='text' placeholder="Algolia index name"  class='form-control algolia_index' id='algolia_index_##rowCnt##' name='lang_##langid##_algolia_index' value=''>
			</div>
		</div>
	</div>
</div>

<div style='display:none' id='rulesTemplate'>
	<div class="form-group row" >
		<label for="" class="col-sm-3 col-form-label">##ruleslabel##</label>
		<div class="col-sm-9">
			<div class="input-group">
				<select class="custom-select col-sm-3" name="lang_##langid##_rules_element_type" aria-label="" id='##idrules_element_type##' onchange="elementTypeChange(##langid##, ##rulescount##)">
					<option value="">-- Type --</option>
					<% for(String k : elementTypes.keySet())
						out.write("<option value='"+k+"'>"+elementTypes.get(k)+"</option>");
					%>
				</select>
				<select class="custom-select col-sm-3" name="lang_##langid##_rules_criteria" aria-label="" id='##idrules_criteria##' onchange="elementCriteriaChange(##langid##, ##rulescount##)">
					<option value="">-- Criteria --</option>
				</select>
				<span id='##idrules_element##' class="col-sm-3">
					<input type='text' class="form-control rules_criteria_value" placeholder="value" name="lang_##langid##_rules_criteria_value" >
				</span>
				<select class="custom-select col-sm-2 rules_index_list lang_##langid##_rules_index_list" name="lang_##langid##_rules_index" aria-label="" id='##idrules_index##' >
					<option value="">-- Index --</option>
				</select>					
				<select class="col-sm-1 custom-select lang_##langid##_exclude_from_default" name="lang_##langid##_exclude_from_default" data-toggle="tooltip" data-placement="top" title="Excluded of default index if YES">
					<option value="0">No</option>
					<option value="1">Yes</option>
				</select>						
			</div>
		</div>
	</div>
</div>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script>

	var rulesCount = <%=rulesCount%>;
	var rowCnt = <%=rowCnt%>;
	var isErr = false;
	

	var indexNames = [];	
	<%
		for(Language _lng : langsList){
		out.write("indexNames["+_lng.getLanguageId()+"] = [];\n");
	}
	
		rsAlgoliaIndexes.moveFirst();
	while(rsAlgoliaIndexes.next())
	{
		Set res = Etn.execute("SELECT * FROM language where langue_id = "+escape.cote(parseNull(rsAlgoliaIndexes.value("langue_id"))));
			res.next();
			Language lang =  LanguageFactory.instance.getLanguage(parseNull(res.value("langue_code")));
		if(lang != null)
			out.write("indexNames["+parseNull(rsAlgoliaIndexes.value("langue_id"))+"].push('"+parseNull(rsAlgoliaIndexes.value("index_name")).toLowerCase()+"');\n");
	}
	%>	
		var rulesShownPerLang = [];
	<% for(String s : rulesShownPerLang.keySet()) {
		out.write("rulesShownPerLang["+s+"] = "+rulesShownPerLang.get(s)+";\n");
	}%>
	
	function forceLower(strInput) 
	{
		strInput.value=strInput.value.toLowerCase();
	}
	
	function duplicateField(obj, typ, cls)
	{
		if(typ == "chkbox")
		{
			var isChecked = $(obj).is(":checked");
			$("."+cls).each(function(){
				if($(this).attr('id') != $(obj).attr('id'))
				{
					if(isChecked) $(this).prop('checked', true);
					else $(this).prop('checked', false);
				}
			});
			
		}
		else
		{
			$("."+cls).each(function(){
				if($(this).attr('id') != $(obj).attr('id'))
				{
					$(this).val($(obj).val());
				}
			});
		}
	}

	function removePill() {
		const pill = event.target;
		const selectField = pill.closest("div.row").querySelector("[name=doc-to-capt-type]");
		const currentValue = selectField.value;
		const pillsArray = currentValue.split(",");
		const updatedArray = pillsArray.filter(item => item !== pill.parentElement.textContent.slice(0, -1));
		selectField.value = updatedArray.join(",");
		pill.parentElement.remove();
	}

	function createPill(text) {
		const pill = document.createElement('span');
		pill.classList.add('pill','d-flex');
		pill.textContent = text;
		const removeBtn = document.createElement('div');
		removeBtn.classList.add('remove-button','moringa-orange-color','pl-1');
		removeBtn.innerHTML = '&times;';
		removeBtn.style.cursor = 'pointer';
		removeBtn.onclick = removePill;
		pill.appendChild(removeBtn);
		return pill;
	}

	function handleSelectChange(ele) {
		const selectedValue = ele.value;
		var inputfield = ele.nextElementSibling;
		var parent = ele.parentElement.parentElement;
		ele.firstElementChild.selected=true;

		if (!inputfield.value.split(",").includes(selectedValue)) 
		{
			if(inputfield.value.length>0){
				const values = inputfield.value.split(",");
				values.push(selectedValue);
				inputfield.value = values.join(",");
			}
			else inputfield.value = selectedValue;
		}else return;
		

		if (selectedValue !== "") {
			const pillContainer = parent.children[parent.childElementCount-1];
			const pill = createPill(selectedValue);
			pillContainer.appendChild(pill);
		}
	}

	function showMultiLang(obj, lngid)
	{
		if(isErr) return false;
		var idx = $(obj).data("index");		
		$(".langDiv").hide();
		$(".langDiv[data-language-id="+lngid+"]").show();
	}
	
	function checkerr(obj)
	{		
		if($(obj).attr("data-err") && $(obj).attr("data-err") == "1")
		{
			var that = obj;
			window.setTimeout(function () { $(that).focus();}, 10);						
		}		
	}
	function indexNameChg(obj, _lngid, _rowCnt)
	{
		$("#idxErr_"+_lngid).html("");
		$("#idxErr_"+_lngid).hide();
		
		var v = $.trim($(obj).val());
		var _lngIndexNames = indexNames[_lngid];
		
		isErr = false;
		if(v != "")
		{
			for(var i=0; i<_lngIndexNames.length;i++)
			{
				if(($.trim(v)).toLowerCase() == _lngIndexNames[i] && _rowCnt != i)
				{
					$("#idxErr_"+_lngid).html("Index name already exists");
					$("#idxErr_"+_lngid).show();					
					isErr = true;
					break;
				}
			}
		}
		
		if(isErr)
		{
			$(obj).attr("data-err","1");
			var that = obj;
			window.setTimeout(function () { $(that).focus();}, 10);						
			return false;
		}
		
		$(obj).attr("data-err","0");
		if(_lngIndexNames.length > 0) indexNames[_lngid].splice(0,_lngIndexNames.length);
		$(".lang_"+_lngid+"_alg_index_name").each(function(){
			var _v = $.trim($(this).val()).toLowerCase();
			if(_v != "") indexNames[_lngid].push(_v);
		});
		
		_lngIndexNames = indexNames[_lngid];
		$(".lang_"+_lngid+"_default_index").each(function(){
			var _ov = $(this).val();
			var _htm = "<option value=''>-- Index --</option>";
			for(var i=0;i<_lngIndexNames.length;i++)
			{
				let _selected = "";
				if(_ov == _lngIndexNames[i]) _selected = "selected";
				_htm += "<option "+_selected+" value='"+_lngIndexNames[i]+"'>"+_lngIndexNames[i]+"</option>";
			}
			
			$(this).find('option').remove().end().append(_htm);
		});

		$(".lang_"+_lngid+"_rules_index_list").each(function(){
			var _ov = $(this).val();
			var _htm = "<option value=''>-- Index --</option>";
			for(var i=0;i<_lngIndexNames.length;i++)
			{
				let _selected = "";
				if(_ov == _lngIndexNames[i]) _selected = "selected";
				_htm += "<option "+_selected+" value='"+_lngIndexNames[i]+"'>"+_lngIndexNames[i]+"</option>";
			}
			
			$(this).find('option').remove().end().append(_htm);
		});
	}

	function addIndexRow(lngid) 
	{
		var _html = $("#indexTemplate").html();
		_html = _html.replace(/##rowCnt##/g, rowCnt);
		_html = _html.replace(/##langid##/g, lngid);
		rowCnt++;
		$("#indexes_"+lngid).append(_html);
	};

	function addDocToCap(btn)
	{
		var parent = btn.parentElement;
		var template = document.querySelector("template.add-doc-capt");
		var divTag = document.createElement("div");
		divTag.innerHTML = template.innerHTML;
		parent.insertBefore(divTag.querySelector(".doc-to-capture"),btn);
		if(parent.querySelectorAll(".doc-to-capture").length>1) btn.nextElementSibling.classList.remove("d-none");
	}

	function removeDocToCap(btn)
	{
		var parent = btn.parentElement.parentElement;
		var elements = parent.querySelectorAll(".doc-to-capture");
		elements[elements.length-1].remove();
		if(parent.querySelectorAll(".doc-to-capture").length<=1) btn.classList.add("d-none");
	}

jQuery(document).ready(function() {

	var elementCriterias = [];
	$(".color-picker").colorpicker();
	<% 
	for(String eleType : elementsCriteria.keySet()) {
		out.write("\tvar _t = [];\n");
		for(String cri : elementsCriteria.get(eleType).keySet()) {
			out.write("\t_t.push({code:\""+cri+"\", val:\""+elementsCriteria.get(eleType).get(cri)+"\"});\n");
		}
		out.write("\telementCriterias.push({name:\""+eleType+"\", criteria : _t});\n");
	} 
	%>

	var catalogTypes = [];
	<% 
	rsCatalogTypes.moveFirst();
	while(rsCatalogTypes.next())
		out.write("\tcatalogTypes.push({name:\""+rsCatalogTypes.value("name")+"\", value:\""+rsCatalogTypes.value("value")+"\"});\n");
	%>

	var productTypes = [];
	<% 
		rsProductTypes.moveFirst();
		while(rsProductTypes.next())
			out.write("\tproductTypes.push({name:\""+rsProductTypes.value("type_name")+"\", value:\""+rsProductTypes.value("id")+"\"});\n");
	%>

	var structPages = [];
	<% 
	rsStructPages.moveFirst();
	while(rsStructPages.next())
		out.write("\tstructPages.push({custom_id:\""+rsStructPages.value("custom_id")+"\",name:\""+rsStructPages.value("name")+"\"});\n");
	%>

	var structContents = [];
	<% 
	rsStructContents.moveFirst();
	while(rsStructContents.next())
		out.write("\tstructContents.push({custom_id:\""+rsStructContents.value("custom_id")+"\",name:\""+rsStructContents.value("name")+"\"});\n");
	%>

	var stores = [];
	<% 
	rsStores.moveFirst();
	while(rsStores.next())
		out.write("\tstores.push({custom_id:\""+rsStores.value("custom_id")+"\",name:\""+rsStores.value("name")+"\"});\n");
	%>
	
	var forums = [];
	<% 
	rsForums.moveFirst();
	while(rsForums.next())
		out.write("\tforums.push({id:\""+rsForums.value("id")+"\",name:\""+rsForums.value("topic")+"\"});\n");
	%>

	addRuleLine=function(lngid)
	{
		var rcnt = 0;		
		if(rulesShownPerLang[lngid]) rcnt = rulesShownPerLang[lngid]; 
		//console.log(lngid + " " + rcnt)
		var htm = $("#rulesTemplate").html();
		if(rcnt == 0) 
		{
			htm = htm.replace("##ruleslabel##","Indexation rules");					
		}
		else htm = htm.replace("##ruleslabel##","");
		rulesShownPerLang[lngid] = (rcnt + 1); 
		
		htm = htm.replace("##idrules_element_type##","rulesEleType_" +rulesCount);
		htm = htm.replace("##idrules_criteria##","rulesCriteria_" +rulesCount);
		htm = htm.replace("##idrules_element##","rulesEle_" +rulesCount);
		htm = htm.replace("##idrules_index##","rulesIndex_" +rulesCount);
		htm = htm.replace(/##rulescount##/g, rulesCount);
		htm = htm.replace(/##langid##/g, lngid);
		$("#indexationRulesDiv_"+lngid).append(htm);
		
		var _lngIndexNames = indexNames[lngid];
		var _htm = "<option value=''>-- Index --</option>";
		for(var i=0;i<_lngIndexNames.length;i++)
		{
			_htm += "<option value='"+_lngIndexNames[i]+"'>"+_lngIndexNames[i]+"</option>";
		}
		
		$("#rulesIndex_" +rulesCount).find('option').remove().end().append(_htm);

		rulesCount++;
	};

	<%
	for(Language _lng : langsList){
		int defaultRows = 4;
		defaultRows = defaultRows - rulesShownPerLang.get(_lng.getLanguageId());
		if(defaultRows <= 0) defaultRows = 1;
		for(int j=0;j<defaultRows;j++){
			out.write("addRuleLine('"+_lng.getLanguageId()+"');");
		}
	}
	%>

	elementCriteriaChange=function(_lngid, _rowCnt)
	{
		var elementTypeObj = $("#rulesEleType_" + _rowCnt);

		var elementObj = $("#rulesEle_" + _rowCnt);
		if(elementTypeObj.val() == "commercialcatalog" && $("#rulesCriteria_"+ _rowCnt).val() == "type")
		{
			var hh = "<select class='custom-select rules_criteria_value' name='lang_"+_lngid+"_rules_criteria_value'>";
			hh += "<option value=''>-- Type --</option>";
			for(var i=0;i<catalogTypes.length;i++)
			{
				hh += '<option value="'+catalogTypes[i].value+'">'+catalogTypes[i].name+'</option>';
			}	
			hh += "</select>";
			elementObj.html(hh);
		}	
		else if(elementTypeObj.val() == "new_product" && $("#rulesCriteria_"+ _rowCnt).val() == "type") {
			var hh = "<select class='custom-select rules_criteria_value' name='lang_"+_lngid+"_rules_criteria_value'>";
			hh += "<option value=''>-- Type --</option>";
			for(var i=0;i<productTypes.length;i++) {
				hh += '<option value="'+productTypes[i].value+'">'+productTypes[i].name+'</option>';
			}	
			hh += "</select>";
			elementObj.html(hh);
		}	
		else if(elementTypeObj.val() == "structuredpage" && $("#rulesCriteria_"+ _rowCnt).val() == "type")
		{
			var hh = "<select class='custom-select rules_criteria_value' name='lang_"+_lngid+"_rules_criteria_value'>";
			hh += "<option value=''>-- Type --</option>";
			for(var i=0;i<structPages.length;i++)
			{
				hh += '<option value="'+structPages[i].custom_id+'">'+structPages[i].name+'</option>';
			}	
			hh += "</select>";
			elementObj.html(hh);
		}		
		else if(elementTypeObj.val() == "structuredcontent" && $("#rulesCriteria_"+ _rowCnt).val() == "type")
		{
			var hh = "<select class='custom-select rules_criteria_value' name='lang_"+_lngid+"_rules_criteria_value'>";
			hh += "<option value=''>-- Type --</option>";
			for(var i=0;i<structContents.length;i++)
			{
				hh += '<option value="'+structContents[i].custom_id+'">'+structContents[i].name+'</option>';
			}	
			hh += "</select>";
			elementObj.html(hh);
		}		
		else if(elementTypeObj.val() == "store" && $("#rulesCriteria_"+ _rowCnt).val() == "type")
		{
			var hh = "<select class='custom-select rules_criteria_value' name='lang_"+_lngid+"_rules_criteria_value'>";
			hh += "<option value=''>-- Type --</option>";
			for(var i=0;i<stores.length;i++)
			{
				hh += '<option value="'+stores[i].custom_id+'">'+stores[i].name+'</option>';
			}	
			hh += "</select>";
			elementObj.html(hh);
		}		
		else if(elementTypeObj.val() == "forum" && $("#rulesCriteria_"+ _rowCnt).val() == "type")
		{
			var hh = "<select class='custom-select rules_criteria_value' name='lang_"+_lngid+"_rules_criteria_value'>";
			hh += "<option value=''>-- Type --</option>";
			for(var i=0;i<forums.length;i++)
			{
				hh += '<option value="'+forums[i].custom_id+'">'+forums[i].name+'</option>';
			}	
			hh += "</select>";
			elementObj.html(hh);
		}		
		else
		{
			elementObj.html("<input type='text' class='form-control rules_criteria_value' placeholder='value' name='lang_"+_lngid+"_rules_criteria_value'>");
		}
	}
	
	elementTypeChange=function(_lngid, _rowCnt)
	{
		var criteriaObj = $("#rulesCriteria_"+_rowCnt);

		criteriaObj.find('option').remove();
		criteriaObj.append('<option value="">-- Criteria --</option>');
		for(var i=0; i<elementCriterias.length; i++)
		{
			if(elementCriterias[i].name == $("#rulesEleType_"+ _rowCnt).val())
			{
				for(var j=0; j<elementCriterias[i].criteria.length; j++)
				{
					criteriaObj.append('<option value="'+elementCriterias[i].criteria[j].code+'">'+elementCriterias[i].criteria[j].val+'</option>');
				}
				break;
			}
		}

		elementObj = $("#rulesEle_" + _rowCnt);
		elementObj.html("<input type='text' class='form-control rules_criteria_value' placeholder='value' name='lang_"+_lngid+"_rules_criteria_value'>");
		
	}

	onsave=function()
	{
		$("#infoBox").hide();
		$("#infoBox").html("");
		$("#errBox").hide();
		$("#errBox").html("");

		$.ajax({
			url : 'savemoduleparameters.jsp',
			type: 'POST',
			data: $("#myfrm").serialize(),
			dataType : 'json',
			success : function(resp)
			{
				if(resp.success == 0) 
				{
					$("#infoBox").html("Data saved successfully!!!");
					$("#infoBox").fadeIn();
					setTimeout(function(){refreshscreen();}, 70);
				}
				else
				{
					$("#errBox").html(resp.errmsg);
					$("#errBox").fadeIn();
				}
			},
			error : function()
			{
				console.log("Error while communicating with the server");
			}
		});		
	};

	refreshscreen=function()
	{
		window.location = "moduleparameters.jsp";
	};

});
</script>
</body>
</html>
