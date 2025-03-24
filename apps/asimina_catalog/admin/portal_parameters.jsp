<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, java.util.List"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%@ include file="../../urlcreator.jsp"%>
<%
	String selectedsiteid = getSelectedSiteId(session);
	List<Language> langsList = getLangs(Etn, selectedsiteid);
	Language firstLanguage = langsList.get(0);  

	String isprod = parseNull(request.getParameter("isprod"));
	boolean bisprod = false;
	if("1".equals(isprod)) bisprod = true;

	String dbname = "";
	if(bisprod) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
	String catapulteDb = com.etn.beans.app.GlobalParm.getParm("CATAPULTE_DB");

	boolean rowFound = false;

	Set rs = Etn.execute("select * from "+dbname+"shop_parameters  where site_id = " + escape.cote(selectedsiteid ));
	if(rs.next()) rowFound = true;

	if(!bisprod) copyPaymentAndDeliveryMethods(Etn, selectedsiteid);


       Set rs_lang = Etn.execute("select * from "+dbname+"langue_msg where LANGUE_REF="+escape.cote(getRsValue(rs, "lang_1_currency")));
       rs_lang.next();


	boolean isOrangeApp = "1".equals(parseNull(GlobalParm.getParm("IS_ORANGE_APP")));

	LinkedHashMap<String, String> currencyPositions = new LinkedHashMap<String, String>();
	currencyPositions.put("after","After");
	currencyPositions.put("before","Before");

	LinkedHashMap<String, String> priceformatters = new LinkedHashMap<String, String>();
	priceformatters.put("","---- select ----");
	priceformatters.put("french","French");
	priceformatters.put("german","German");
	priceformatters.put("us","US");

	LinkedHashMap<String, String> currencies = new LinkedHashMap<String, String>();
	currencies.put("","---- select ----");

	Set rsCurrencies = Etn.execute("select * from "+GlobalParm.getParm("COMMONS_DB")+".currencies order by currency_code ");
	while(rsCurrencies.next())
	{
		currencies.put(rsCurrencies.value("currency_code"),rsCurrencies.value("currency_code"));
	}

	LinkedHashMap<String, String> rountodecimals = new LinkedHashMap<String, String>();
	rountodecimals.put("","---");
	rountodecimals.put("0","0");
	rountodecimals.put("1","1");
	rountodecimals.put("2","2");
	rountodecimals.put("3","3");

	LinkedHashMap<String, String> showdecimals = new LinkedHashMap<String, String>();
	showdecimals.put("","---");
	showdecimals.put("0","0");
	showdecimals.put("1","1");
	showdecimals.put("2","2");
	showdecimals.put("3","3");

	LinkedHashMap<String, String> installment_duration_units = new LinkedHashMap<String, String>();
	installment_duration_units.put("Day","Day");
	installment_duration_units.put("Week","Week");
	installment_duration_units.put("Month","Month");
	installment_duration_units.put("Bi-Annual","Bi-Annual");
	installment_duration_units.put("Year","Year");

	LinkedHashMap<String, String> payment_methods = new LinkedHashMap<String, String>();
	installment_duration_units.put("Day","Day");
	installment_duration_units.put("Week","Week");
	installment_duration_units.put("Month","Month");
	installment_duration_units.put("Bi-Annual","Bi-Annual");
	installment_duration_units.put("Year","Year");

	int nlangs = langsList.size();
	int widthlangcol = 16;
	if(nlangs > 0) widthlangcol = 85/nlangs;


	Set stickerRs = Etn.execute("select * from stickers where site_id = " + escape.cote(selectedsiteid) + " order by priority;");

%>
<!DOCTYPE html>

<html>
<head>
	<title>Portal parameters</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

	<style>

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

	<link href="<%=request.getContextPath()%>/css/spectrum.min.css" type="text/css" rel="stylesheet">
	<script src="<%=request.getContextPath()%>/js/spectrum.js"></script>

</head>
<%
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Portal Parameters", ""});
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">

	<!-- container -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
			<h1 class="h2">Portal Parameters</h1>
			<p class="lead"></p>
			</div>
			<% if(!bisprod) { %>
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-success" onclick='onsave()'>Save</button>
				</div>
				<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Portal Parameters');" title="Add to shortcuts">
					<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
				</button>
			</div>
			<%}%>
		</div><!-- /container -->


	<div class="animated fadeIn">
		<% if(!bisprod) { %>
		<!-- messages zone  -->
		<div class='m-b-20'>
		</div>
		<!-- messages zone  -->
		<% } %>

		<form name='frm' id='frm' method='post' action='save_shop_parameters.jsp' >
		<input type='hidden' name='calledfrom' value='portal_parameters.jsp' />
		<input type='hidden' name='id' value='<%=selectedsiteid%>' />
		<br/>

		<!-- General informations -->
		<div class="card">
		<div class="card-header">General information</div>
  		<div class="card-body">
		<div class="form-horizontal">
			<div class="row">
				<div class="col-md-6">

					<div class="col-md-12">
						<div class="form-group row">
							<label for="inputUniverse" class='col-md-8 control-label'>Default Currency</label>
							<div class='col-md-4'>
							<%
								ArrayList arr = new ArrayList<String>();
								arr.add(getRsValue(rs, "lang_"+firstLanguage.getLanguageId()+"_currency"));
							%>
			                <%=addSelectControl("default_currency", "", currencies, arr, "form-control", "",false)%>
							<% for(Language lang:langsList){%>
			                	<input type='hidden' name='lang_<%=lang.getLanguageId()%>_currency' id='lang_<%=lang.getLanguageId()%>_currency' value='<%=getValue(rs, "lang_"+firstLanguage.getLanguageId()+"_currency")%>' />
							<%}%>
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-6">
					<% if(!isOrangeApp) { %>
					<div class="col-md-12">
						<div class="form-group row">
							<label for="inputUniverse" class='col-md-8 control-label'>Show Service Schedule Only?</label>
							<div class='col-md-4'><select name="service_params" id="service_params" class="form-control">
		                    <option <%=(getRsValue(rs, "service_params").equals("1")?"selected":"")%> value="1">No</option>
		                    <option <%=(getRsValue(rs, "service_params").equals("0")?"selected":"")%> value="0">Yes</option>
		                </select></div>
						</div>
					</div>
					<% } %>
				</div>
				<!-- edited by hamza -->
				<div class="col-md-6">
					<div class="col-md-12">
						<div class="form-group row">
							<label for="inputUniverse" class='col-md-8 control-label'>Currency Position</label>
							<div class='col-md-4'><select name="currencyPositions" id="currencyPositions" class="form-control">
									<option value="before" <%=(getRsValue(rs, "lang_1_currency_position").equals("before")?"selected":"")%>>Before</option>
									<option value="after" <%=(getRsValue(rs, "lang_1_currency_position").equals("after")?"selected":"")%>>After</option>
								</select>
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-6">
					<div class="col-md-12">
						<div class="form-group row">
							<label for="inputUniverse" class="col-md-8 control-label">Price formatter</label>
							<div class='col-md-4'><select name="priceformatters" id="priceformatters" class="form-control">
									<option value="">---- select ----</option>
									<option value="french" <%=(getRsValue(rs, "lang_1_price_formatter").equals("french")?"selected":"")%>>French</option>
									<option value="german" <%=(getRsValue(rs, "lang_1_price_formatter").equals("german")?"selected":"")%>>German</option>
									<option value="us" <%=(getRsValue(rs, "lang_1_price_formatter").equals("us")?"selected":"")%>>US</option>
								</select>
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-6">
					<div class="col-md-12">
						<div class="form-group row">
							<label for="inputUniverse" class="col-md-8 control-label">Round to Decimals</label>
							<div class='col-md-4'>
								<select id="rountodecimals" class="form-control">
									<option value="">---</option>
									<option value="0" <%=(getRsValue(rs, "lang_1_round_to_decimals").equals("0")?"selected":"")%>>0</option>
									<option value="1" <%=(getRsValue(rs, "lang_1_round_to_decimals").equals("1")?"selected":"")%>>1</option>
									<option value="2" <%=(getRsValue(rs, "lang_1_round_to_decimals").equals("2")?"selected":"")%>>2</option>
									<option value="3" <%=(getRsValue(rs, "lang_1_round_to_decimals").equals("3")?"selected":"")%>>3</option>
								</select>
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-6">
					<div class="col-md-12">
						<div class="form-group row">
							<label for="inputUniverse" class="col-md-8 control-label">Show Decimals</label>
							<div class='col-md-4'>
								<select id="showdecimals" class="form-control">
									<option value="">---</option>
									<option value="0" <%=(getRsValue(rs, "lang_1_show_decimals").equals("0")?"selected":"")%>>0</option>
									<option value="1" <%=(getRsValue(rs, "lang_1_show_decimals").equals("1")?"selected":"")%>>1</option>
									<option value="2" <%=(getRsValue(rs, "lang_1_show_decimals").equals("2")?"selected":"")%>>2</option>
									<option value="3" <%=(getRsValue(rs, "lang_1_show_decimals").equals("3")?"selected":"")%>>3</option>
								</select>
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-6">
					<div class="col-md-12">
						<div class="form-group row">
							<label for="inputUniverse" class="col-md-8 control-label">Test amount</label>
							<div class='col-md-4'>
								<div class="input-group"> <!-- Wrap the input and button in a div for spacing control -->
									<input type='text' onkeypress="return isdoublevalue(event)" id='testamnt' value='100215.568' size='15' class="form-control"/>
									<div class="input-group-append"> <!-- Use input-group-append to group the button -->
										<button type='button' class='btn btn-default btn-success' onclick='testamount()'>Test</button>
									</div>
							</div>
							<span id='testamntspan' style='font-weight:bold; color:green'></span>
							</div>
						</div>
					</div>
				</div>
				<!-- till here -->
			</div>
		</div>
		</div>
		<div class="card card-info">
			<div class="card-header" role="tab" id="heading1">
		  		<h5 class="mb-0">
		  			<button class="btn btn-link" data-target="#collapse1" type="button" data-toggle="collapse" >Shop Details</button>
				</h5>
			</div>
			<div id="collapse1" class="card-collapse collapse" role="tabcard" aria-labelledby="heading1">
		  		<div class="card-body">
					<div class="form-horizontal">
						<div  class="form-inline">
							<table cellpadding=0 cellspacing=0 border=0 class='table' width='99%'>
								<tr style="background: #D9EDF7;color: #31709B;border: 0px;">
									<th style='font-weight:bold;' ></th>
									<% for(Language lang: langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show' style='width:<%=widthlangcol%>%;text-transform: uppercase;font-weight: bold;font-size: 11pt;'><%=lang.getLanguage()%></td>
									<%}%>
								</tr>
								<tr>
									<th style='font-weight:bold;'>Currency Label</th>
									<% for(Language lang: langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='LANGUE_<%=lang.getLanguageId()%>' id='LANGUE_<%=lang.getLanguageId()%>' value='<%=getValue(rs_lang, "LANGUE_"+lang.getLanguageId())%>' size='10' maxlength='25' class="form-control"/></td>
									<%}%>
								</tr>
								<tr>
									<th style='font-weight:bold;'>No Price Display Label</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><textarea cols='30' rows='3' type='text' name='lang_<%=lang.getLanguageId()%>_no_price_display_label' id='lang_<%=lang.getLanguageId()%>_no_price_display_label' class="form-control" ><%=getValue(rs, "lang_"+lang.getLanguageId()+"_no_price_display_label")%></textarea></td>
									<%}%>
								</tr>
							</table>
							<!-- edited by hamza -->
							<% for(int i=1;i<= 5;i++){%>
								<input type='hidden' name='lang_<%=i%>_currency_position' id='lang_<%=i%>_currency_position' value='<%=getRsValue(rs, "lang_"+i+"_currency_position")%>'  class="form-control"/>
								<input type='hidden' name='lang_<%=i%>_price_formatter' id='lang_<%=i%>_price_formatter' value='<%=getRsValue(rs, "lang_"+i+"_price_formatter")%>'  class="form-control"/>
								<input type='hidden' name='lang_<%=i%>_round_to_decimals' id='lang_<%=i%>_round_to_decimals' value='<%=getRsValue(rs, "lang_"+i+"_round_to_decimals")%>'  class="form-control"/>
								<input type='hidden' name='lang_<%=i%>_show_decimals' id='lang_<%=i%>_show_decimals' value='<%=getRsValue(rs, "lang_"+i+"_show_decimals")%>'  class="form-control"/>
								<%}%>
							<!-- till here -->
							
						</div>
					</div>
				</div>
			</div>
		</div>
		<% if("1".equals(parseNull(GlobalParm.getParm("SHOW_SMART_BANNER_OPTION")))) { %>
		<div class="card card-info">
			<div class="card-header" role="tab" id="heading2">
		  		<h5 class="mb-0">
		  			<button class="btn btn-link" data-target="#collapse2" type="button" data-toggle="collapse" >Smart Banner</button>
				</h5>
			</div>
			<div id="collapse2" class="card-collapse collapse" role="tabcard" aria-labelledby="heading2">
		  		<div class="card-body">
					<div class="form-horizontal">
						<div  class="form-inline">
							<table cellpadding=0 cellspacing=0 border=0 class='table' width='99%'>
								<tr style="background: #D9EDF7;color: #31709B;border: 0px;">
									<th style='font-weight:bold;'></th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show' style='width:<%=widthlangcol%>%;text-transform: uppercase;font-weight: bold;font-size: 11pt;'><%=lang.getLanguage()%></td>
									<%}%>
								</tr>

								<tr>
									<th style='font-weight:bold;'>Title</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='lang_<%=lang.getLanguageId()%>_sb_title' id='lang_<%=lang.getLanguageId()%>_sb_title' value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_sb_title")%>' size='30' maxlength='255' class="form-control" /></td>
									<%}%>
								</tr>
								<tr>
									<th style='font-weight:bold;'>Author</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='lang_<%=lang.getLanguageId()%>_sb_author' id='lang_<%=lang.getLanguageId()%>_sb_author' value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_sb_author")%>' size='30' maxlength='255' class="form-control" /></td>
									<%}%>
								</tr>
								<tr>
									<th style='font-weight:bold;'>Price</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='lang_<%=lang.getLanguageId()%>_sb_price' id='lang_<%=lang.getLanguageId()%>_sb_price' value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_sb_price")%>' size='20' maxlength='75' class="form-control" /></td>
									<%}%>
								</tr>
								<tr>
									<th style='font-weight:bold;'>Button label</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='lang_<%=lang.getLanguageId()%>_sb_button_label' id='lang_<%=lang.getLanguageId()%>_sb_button_label' value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_sb_button_label")%>' size='30' maxlength='75' class="form-control" /></td>
									<%}%>
								</tr>

								<tr>
									<th style='font-weight:bold;'>Platforms</th>
									<td colspan='4'>
										<input type="hidden" name='sb_platform_ios' id='sb_platform_ios' value='<%=getValue(rs, "sb_platform_ios")%>' />
										<input type='checkbox' id='sb_platform_ios_str' value='1' <%if("1".equals(getRsValue(rs, "sb_platform_ios"))){%>checked<%}%> />&nbsp;&nbsp;<b>iOS</b>
										&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										<input type="hidden" name='sb_platform_android' id='sb_platform_android' value='<%=getValue(rs, "sb_platform_android")%>' />
										<input type='checkbox' id='sb_platform_android_str' value='1' <%if("1".equals(getRsValue(rs, "sb_platform_android"))){%>checked<%}%> />&nbsp;&nbsp;<b>Android</b>
									</td>
								</tr>
								<tr>
									<th style='font-weight:bold;'>iOS price suffix</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='lang_<%=lang.getLanguageId()%>_sb_ios_price_suffix' id='lang_<%=lang.getLanguageId()%>_sb_ios_price_suffix' value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_sb_ios_price_suffix")%>' size='30' maxlength='75' class="form-control"/></td>
									<%}%>
								</tr>
								<tr>
									<th style='font-weight:bold;'>iOS icon</th>
									<td colspan='5' >
										<%if(getRsValue(rs, "sb_ios_icon").length() > 0){%>
											<a href='<%=GlobalParm.getParm("SMART_BANNER_ICON_URL")+selectedsiteid+"/"+getRsValue(rs, "sb_ios_icon")+"?t="+System.currentTimeMillis()%>' target='_blank'><img width='50px' src='<%=GlobalParm.getParm("SMART_BANNER_ICON_URL")+selectedsiteid+"/"+getRsValue(rs, "sb_ios_icon")+"?t="+System.currentTimeMillis()%>' /></a>
										<%}%>
										&nbsp;
										&nbsp;
										<button class="btn" type="button" id='iosiconbtn' ><span class="oi oi-data-transfer-upload" aria-hidden="true"></span></button>

									</td>
								</tr>
								<tr>
									<th style='font-weight:bold;'>iOS button URL</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='lang_<%=lang.getLanguageId()%>_sb_ios_button_url' id='lang_<%=lang.getLanguageId()%>_sb_ios_button_url' value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_sb_ios_button_url")%>' size='30' maxlength='255' class="form-control" /></td>
									<%}%>
								</tr>
								<tr>
									<th style='font-weight:bold;'>Android price suffix</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='lang_<%=lang.getLanguageId()%>_sb_android_price_suffix' id='lang_<%=lang.getLanguageId()%>_sb_android_price_suffix' value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_sb_android_price_suffix")%>' size='30' maxlength='75' class="form-control" /></td>
									<%}%>
								</tr>
								<tr>
									<th style='font-weight:bold;'>Android icon<br></th>
									<td colspan='5'>

										<%if(getRsValue(rs, "sb_android_icon").length() > 0){%>
											<a href='<%=GlobalParm.getParm("SMART_BANNER_ICON_URL")+selectedsiteid+"/"+getRsValue(rs, "sb_android_icon")+"?t="+System.currentTimeMillis()%>' target='_blank'><img width='50px' src='<%=GlobalParm.getParm("SMART_BANNER_ICON_URL")+selectedsiteid+"/"+getRsValue(rs, "sb_android_icon")+"?t="+System.currentTimeMillis()%>' /></a>
										<%}%>
										&nbsp;
										&nbsp;
										<button class="btn" type="button"  id='androidiconbtn' >
											<span class="oi oi-data-transfer-upload" aria-hidden="true"></span>
										</button>




									</td>
								</tr>
								<tr>
									<th style='font-weight:bold;'>Android button URL</th>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='lang_<%=lang.getLanguageId()%>_sb_android_button_url' id='lang_<%=lang.getLanguageId()%>_sb_android_button_url' value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_sb_android_button_url")%>' size='30' maxlength='255' class="form-control" /></td>
									<%}%>
								</tr>
								<input type='hidden' name='sb_icon_type' id='sb_icon_type' value='' />
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>

		<!-- Stickers -->
		<div class="card card-info">
			<div class="card-header" role="tab" id="heading3">
		  		<h5 class="mb-0">
		  			<button class="btn btn-link" data-target="#collapse3" type="button" data-toggle="collapse" >Stickers</button>
				</h5>
			</div>
			<div id="collapse3" class="card-collapse collapse" role="tabcard" aria-labelledby="heading3">
		  		<div class="card-body">
					<div class="form-horizontal">
						<div  class="form-inline">
							<div><h6>Priority : 0 (high) ..... 10 (low)</h6></div>
							<table cellpadding=0 cellspacing=0 border=0 class='table list_stickers' width='99%'>
								<tr style="background: #D9EDF7;color: #31709B;border: 0px;">
									<td style='text-transform: uppercase;font-weight: bold;font-size: 11pt;'>Priority</td>
									<td style='text-transform: uppercase;font-weight: bold;font-size: 11pt;'>Nb use</td>
									<td style='text-transform: uppercase;font-weight: bold;font-size: 11pt;'>Name</td>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show' style='width:<%=widthlangcol%>%;text-transform: uppercase;font-weight: bold;font-size: 11pt;'><%=lang.getLanguage()%></td>
									<%}%>
									<td style='text-transform: uppercase;font-weight: bold;font-size: 11pt;'>Color</td>
								</tr>
						<%
							while(stickerRs.next()){

								Set stickerCountRs = Etn.execute("select count(*) as count from product_variants pv, products p, catalogs c WHERE p.id = pv.product_id and c.id = p.catalog_id and pv.sticker = " + escape.cote(getValue(stickerRs, "sname")) + " and site_id = " + escape.cote(selectedsiteid));

								stickerCountRs.next();

						%>
								<tr>
									<td class='lang<%=firstLanguage.getLanguageId()%>show'><input type='text' name='priority' id='priority' value='<%=getValue(stickerRs, "priority")%>' size='2' maxlength='25' class="form-control"/></td>

									<td>
										<a href="#"> <span class="badge badge-secondary"><%=stickerCountRs.value("count")%></span></a>
									</td>

									<td class='lang<%=firstLanguage.getLanguageId()%>show'><input type='text' name='sname' id='sname' value='<%=getValue(stickerRs, "sname")%>' size='8' maxlength='25' class="form-control" /></td>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='DISPLAY_NAME_<%=lang.getLanguageId()%>' id='DISPLAY_NAME_<%=lang.getLanguageId()%>' value='<%=getValue(stickerRs, "display_name_"+lang.getLanguageId())%>' size='18' maxlength='25' class="form-control"/></td>
									<%}%>
									<td class='lang<%=firstLanguage.getLanguageId()%>show attribute_color_span'>
										<input type='text' name='color' id='color' value='<%=getValue(stickerRs, "color")%>' size='10' maxlength='10' class="form-control attribute_color"/>
									</td>


								</tr>
						<%
							}
						%>

								<tr class="sticker_clone d-none">
									<td class='lang<%=firstLanguage.getLanguageId()%>show'><input type='text' name='priority' id='priority' value='' size='2' maxlength='25' class="form-control"/></td>

									<td>
										&nbsp;
									</td>

									<td class='lang<%=firstLanguage.getLanguageId()%>show'><input type='text' name='sname' id='sname' value='' size='10' maxlength='8' class="form-control"/></td>
									<% for(Language lang:langsList){%>
										<td class='lang<%=lang.getLanguageId()%>show'><input type='text' name='DISPLAY_NAME_<%=lang.getLanguageId()%>' id='DISPLAY_NAME_<%=lang.getLanguageId()%>' value='' size='18' maxlength='25' class="form-control"/></td>
									<%}%>
									<td class='lang<%=firstLanguage.getLanguageId()%>show'>
										<input type='text' name='color' id='color' value='' size='10' maxlength='10' class="form-control"/>
									</td>
								</tr>
							</table>
							<div>
								<button id="add_more_sticker" type="button" class="btn btn-success mb-2">Add more(+)</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>


		<% } %>

	</form>
	<br>
	<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	<br>
</main>

<!-- /.modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='uploaddialog'>
	<div class="modal-dialog modal-sm" role="document">
		<div class="modal-content">
			<div class="modal-header" style='text-align:left'>
				<h5 class="modal-title">Upload image</h5>
			       <button type="button" class="close" data-dismiss="modal" aria-label="Close">
			       <span aria-hidden="true">&times;</span>
			       </button>
			</div>
			<div class="modal-body">
				<div>
				<form id='uploadfrm' method='post' action='uploadsmartbannericon.jsp' enctype='multipart/form-data'>
					<input type='hidden' name='id' id='upld_id' value=''/>
					<input type='hidden' name='sb_icon_type' id='upld_typ' value=''/>
					<table cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td align='left'><input type='file' id='uploadfile' name='uploadfile' value=''/></td>
					</tr>
					</table>
				</form>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
				<button type="button" class="btn btn-success" onclick='okuploadbtnclick()'>Upload</button>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div>
<!-- /.modal -->
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>
<script>
	// edited by hamza
	jQuery(document).ready(function() {
		$("#currencyPositions").change(function(){
            var selectedValue = $(this).val();
            for (var i = 1; i <= 5; i++) {
                $("#lang_" + i + "_currency_position").val(selectedValue);

            }
        });
		// edited by hamza
		$("#default_currency").change(function(){

			var val = $(this).val();
			<% for(Language lang:langsList){%>
				$('#lang_<%=lang.getLanguageId()%>_currency').val(val);
			<% } %>
		});
		// edited by hamza
		$("#priceformatters").change(function() {
            var selectedPriceFormatter = $(this).val();
            for (var i = 1; i <= 5; i++) {
                $("#lang_" + i + "_price_formatter").val(selectedPriceFormatter);
            }
        });
		// edited by hamza
		$("#rountodecimals").change(function() {
            var selectedValue = $(this).val();
            
            // Loop through all language fields and set the selected value
            for (var i = 1; i <= 5; i++) {
                $("#lang_" + i + "_round_to_decimals").val(selectedValue);
            }
        });
		// edited by hamza
		$("#showdecimals").change(function() {
            var selectedValue = $(this).val();
            
            // Loop through all language fields and set the selected value
            for (var i = 1; i <= 5; i++) {
                $("#lang_" + i + "_show_decimals").val(selectedValue);
            }
        });
		// edited by hamza
		testamount=function()
        {
            $("#testamntspan").html("");
            var testValue = $("#testamnt").val();
            $.ajax({
                url : 'testpriceformatter.jsp',
                type: 'POST',
                data: {formatter: $("#priceformatters").val(), roundto: $("#rountodecimals").val(), decimals: $("#showdecimals").val(), amnt: testValue },
                dataType : 'json',
                success : function(json)
                {
                    $("#testamntspan").html(json.amnt);
                },
                error : function()
                {
                    alert("Error while communicating with the server");
                }
            });
        };
		// till here
		<% for(Language lang:langsList){ %>
			$(".lang<%=lang.getLanguageId()%>show").css("display", "table-cell");
		<% } %>

		okuploadbtnclick=function()
		{
			if($("#uploadfile").val() =='')
			{
				alert("Select an image");
				return;
			}
			var ok= isvalidimage($("#uploadfile").val());
			if(!ok)
			{
				alert("Not a valid image file");
				return;
			}
			$("#uploadfrm").submit();
		};

		onsave=function()
		{
			if($("#sb_platform_ios_str").is(':checked')) $("#sb_platform_ios").val('1');
			else $("#sb_platform_ios").val('0');

			if($("#sb_platform_android_str").is(':checked')) $("#sb_platform_android").val('1');
			else $("#sb_platform_android").val('0');

			$("#frm").submit();
		};

		$("#iosiconbtn").click(function()
		{
			<%if(!rowFound) { %>
				return;
			<%} else {%>
				$("#upld_id").val('<%=selectedsiteid%>');
				$("#upld_typ").val('ios');
				$("#uploaddialog").modal("show");
			<%}%>
		});

		$("#androidiconbtn").click(function()
		{
			<%if(!rowFound) { %>
				return;
			<%} else {%>
				$("#upld_id").val('<%=selectedsiteid%>');
				$("#upld_typ").val('android');
				$("#uploaddialog").modal("show");
			<%}%>
		});

		refreshscreen=function()
		{
			window.location = "portal_parameters.jsp";
		};


		$("#add_more_sticker").on("click", function(){

			$(".sticker_clone").find("#color").addClass("attribute_color");
			var cloneSticker = "<tr>"+$(".sticker_clone").html()+"</tr>";
			$(".list_stickers").append(cloneSticker)
			$(".sticker_clone").find("#color").removeClass("attribute_color");

	        var colorInput = $(".attribute_color");
	        colorInput.spectrum({
                preferredFormat : "hex",
                allowEmpty : true,
                showButtons : true,
                showInitial : true,
                showAlpha : true,
                showInput : true,
                // showPalette : true,
                // change: function(color) {
                //     console.log("on change");
                //     console.log(color.toHexString()); // #ff0000
                // },
                // beforeShow : function(color){
                //     console.log("on becore show " + $(this).val());
                //     $(this).spectrum("set",$(this).val());
                // }

            });

		});

        var colorInput = $(".attribute_color");
        colorInput.spectrum({
                preferredFormat : "hex",
                allowEmpty : true,
                showButtons : true,
                showInitial : true,
                showAlpha : true,
                showInput : true,
                // showPalette : true,
                // change: function(color) {
                //     console.log("on change");
                //     console.log(color.toHexString()); // #ff0000
                // },
                // beforeShow : function(color){
                //     console.log("on becore show " + $(this).val());
                //     $(this).spectrum("set",$(this).val());
                // }

            });
	});
</script>
</html>