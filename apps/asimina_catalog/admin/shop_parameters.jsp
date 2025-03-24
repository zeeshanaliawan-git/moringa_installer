<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, java.util.List, org.apache.commons.lang3.text.WordUtils"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%@ include file="../../urlcreator.jsp"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>

<%!
	String capitalizeFirstChar(String input) {
        if (input == null || input.isEmpty()) {
            return input;
        }
        input = input.substring(0, 1).toUpperCase() + input.substring(1);
		input=input.replace("_"," ");
		return input;
    }

%>
<%
	String selectedsiteid = getSelectedSiteId(session);
	String errorMessage = parseNull(request.getParameter("errorMessage"));
	List<Language> langsList = getLangs(Etn,selectedsiteid);
	Language firstLanguage = langsList.get(0);

	boolean ecommerceEnabled = isEcommerceEnabled(Etn, selectedsiteid);

	if(!ecommerceEnabled)
	{
		response.sendRedirect("portal_parameters.jsp");
		return;
	}

	String isprod = parseNull(request.getParameter("isprod"));
	boolean bisprod = false;
	if("1".equals(isprod)) bisprod = true;

	String dbname = "";
	if(bisprod) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
	String catapulteDB = com.etn.beans.app.GlobalParm.getParm("CATAPULTE_DB");

	boolean rowFound = false;
	Set rs = Etn.execute("select * from "+dbname+"shop_parameters where site_id = "+escape.cote(selectedsiteid));
	if(rs.next()) rowFound =  true;

	if(!bisprod) copyPaymentAndDeliveryMethods(Etn, selectedsiteid);	//copy all payment methods

	Set rs_lang = Etn.execute("select * from "+dbname+"langue_msg where LANGUE_REF="+escape.cote(getRsValue(rs, "lang_"+firstLanguage.getLanguageId()+"_currency")));
	rs_lang.next();

	LinkedHashMap<String, String> priceformatters = new LinkedHashMap<String, String>();
	priceformatters.put("","---- select ----");
	priceformatters.put("french","French");
	priceformatters.put("german","German");
	priceformatters.put("us","US");

	LinkedHashMap<String, String> currencies = new LinkedHashMap<String, String>();
	currencies.put("","---- select ----");
	currencies.put("FRA","FRA");
	currencies.put("USD","USD");
	currencies.put("EUR","EUR");
	currencies.put("XOF","XOF");
	currencies.put("XAF","XAF");
	currencies.put("BWP","BWP");
	currencies.put("PKR","PKR");



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

	LinkedHashMap<String, String> delivery_methods = new LinkedHashMap<String, String>();
	Set rsAllDeliveryMethods = Etn.execute("select * from "+dbname+"all_delivery_methods;");
	while(rsAllDeliveryMethods.next())
	{
		delivery_methods.put(rsAllDeliveryMethods.value("method"),WordUtils.capitalizeFully(rsAllDeliveryMethods.value("method").replaceAll("_"," ")));
	}


	int nlangs = langsList.size();
	int widthlangcol = 16;
	if(nlangs > 0) widthlangcol = 85/nlangs;

    LinkedHashMap<String, String> prodShopEmails = new LinkedHashMap<String, String>();
    LinkedHashMap<String, String> devShopEmails = new LinkedHashMap<String, String>();

    devShopEmails.put("0","---- select ----");
    prodShopEmails.put("0","---- select ----");

    Set devShopEmailsRs = Etn.execute("SELECT id, sujet as subject from "+GlobalParm.getParm("SHOP_DB")+".mails ORDER BY id");
    Set prodShopEmailsRs = Etn.execute("SELECT id, sujet as subject from "+GlobalParm.getParm("PROD_SHOP_DB")+".mails ORDER BY id");
    while(devShopEmailsRs.next())
    {
        devShopEmails.put(devShopEmailsRs.value("id"),devShopEmailsRs.value("subject"));
    }

    while(prodShopEmailsRs.next())
    {
        prodShopEmails.put(prodShopEmailsRs.value("id"),prodShopEmailsRs.value("subject"));
    }

	Set inventoryRs = Etn.execute("SELECT * FROM "+GlobalParm.getParm("COMMONS_DB")+".inventory_mail where site_id="+escape.cote(selectedsiteid));
	ArrayList arr = new ArrayList<String>();

	Set rsDeliveryMethods = Etn.execute("select * from delivery_methods where site_id = "+escape.cote(selectedsiteid)+" order by orderSeq;");
	Set rsPaymentMethods = Etn.execute("select * from payment_methods where site_id = "+escape.cote(selectedsiteid)+" order by orderSeq;");
	 
	// Home Delivery Slots 
	 // Week Days
	String[] daysOfWeeks = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};

        // Json object to carry array for every week day
	   JSONObject weekDays = new JSONObject();
       for (int i = 0; i < 7; i++) {
			weekDays.put(String.valueOf(i), new JSONArray());
		}
		Set  rsDeliverySlots = Etn.execute("SELECT * FROM " + GlobalParm.getParm("COMMONS_DB") + ".delivery_slots WHERE site_id=" + escape.cote(selectedsiteid) + " ORDER BY n_day ASC");
		while (rsDeliverySlots.next()) {
			 JSONObject individualDay = new JSONObject();
                          individualDay.put("nDay", parseNull(rsDeliverySlots.value("n_day")));
						  individualDay.put("startHour", parseNull(rsDeliverySlots.value("start_hour")));
						  individualDay.put("startMinute", parseNull(rsDeliverySlots.value("start_min")));
						  individualDay.put("endHour", parseNull(rsDeliverySlots.value("end_hour")));
						  individualDay.put("endMinute", parseNull(rsDeliverySlots.value("end_min")));
							
			weekDays.getJSONArray(parseNull(rsDeliverySlots.value("n_day"))).put(individualDay);
			
		}
 // Home Delivery Slots End 

%>
<%! 
    public String generateHourOptions(Integer selectedHour) {
        StringBuilder options = new StringBuilder();
        for (int hour = 0; hour < 24; hour++) {
            options.append("<option  value=\"")
                   .append(hour)
                   .append("\"")
                   .append((selectedHour != null && selectedHour == hour) ? "selected" : "--")
                   .append(">")
                   .append(String.format("%02d", hour))
                   .append("</option>");
        }
        return options.toString();
    }
	public String generateMinuteOptions(Integer selectedMinute) {
        StringBuilder options = new StringBuilder();
        for (int minute = 0; minute < 60; minute += 15) {
            options.append("<option value=\"")
                   .append(minute)
                   .append("\"")
                   .append((selectedMinute != null && selectedMinute == minute) ? " selected" : "--")
                   .append(">")
                   .append(String.format("%02d", minute))
                   .append("</option>");
        }
        return options.toString();
    }
%>
<!DOCTYPE html>

<html>
<head>
	<title>Shop Parameters</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%
breadcrumbs.add(new String[]{"System", ""});	
breadcrumbs.add(new String[]{"Shop Parameters", ""});
%>

	<style>
		.lang1show,.lang2show,.lang3show,.lang4show,.lang5show
		{
			display:none;
		}

		.delivery-method-row:hover{
			background:#eee;
		}

		.bg-section-dark{
			background-color:#4F5D73;
			color:#ffffff;
		}
		#time_input,
		input {
		border-radius: 8px;
		font-size: 16px;
		}
		.separator {
			border-top: 1px solid #ccc;
			margin-top: 20px; 
			margin-bottom: 20px; 
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
		<h1 class="h2">Shop Parameters</h1>
		<p class="lead"></p>
		</div>
		<% if(!bisprod) { %>
		<div class="btn-toolbar mb-2 mb-md-0">
			<div class="btn-group mr-2" role="group" aria-label="...">
				<button type="button" class="btn btn-success" onclick='onsave()'>Save</button>
			</div>
			<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Shop Parameters');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>
		</div>
		<%}%>
	</div><!-- /d-flex -->

	<!-- /container -->


	<!-- container -->
	<div class="animated fadeIn">
		<% if(!bisprod) { %>
		<!-- messages zone  -->
		<div class='m-b-20'>
		</div>
		<!-- messages zone  -->
		<% } %>

		<form name='frm' id='frm' method='post' action='save_shop_parameters.jsp' >
		<input type="hidden" name="id" value="<%=selectedsiteid%>" />


		<ul class="nav nav-tabs" id="myTab1" role="tablist">
		<% int count = 0; 
			for(Language lang : langsList){
				
		%>
			<li class="nav-item">
				<a class="nav-link <%=(count == 0)? "active":""%>" id="<%=lang.getLanguage()%>-tab" data-toggle="tab" href="#<%=lang.getLanguage()%>" role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%></a>
			</li>
		<%
			count+=1;
		}%>
		</ul>

		<div class="tab-content p-3" id="myTabContent1">
		<% 	
			count = 0; 
			for(Language lang : langsList){
				rsDeliveryMethods.moveFirst();
				rsPaymentMethods.moveFirst();
				inventoryRs.moveFirst();
				inventoryRs.next();
		%>
		
		<div class="tab-pane fade show <%=(count == 0)? "active":""%>" id="<%=lang.getLanguage()%>" role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
		
			<!-- General informations -->
			<div class="card mb-2">
				<div class="card-header bg-section-dark d-flex" data-toggle="collapse" href="#collapseGeneralInfo" role="button" aria-expanded="true" aria-controls="collapseGeneralInfo">
					<strong>General Information</strong>
					<div href="#" class="ml-2" data-toggle="tooltip" title="" data-original-title="Default tooltip">
						<svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
					</div>
				</div>
				<div id="collapseGeneralInfo" class="collapse" style="border:none; margin-bottom:none;">
					<div class="card-body">
						<div class="form-horizontal">
								<div class="form-group row">
									<label for="checkout_login" class='col-sm-3 col-form-label font-weight-bold'>Checkout Login</label>
									<div class='col-sm-9'>
										<select name="checkout_login" id="checkout_login" class="form-control" <%= (count!=0)? "disabled": "" %> >
											<option <%=(getRsValue(rs, "checkout_login").equals("1")?"selected":"")%> value="1">Yes</option>
											<option <%=(getRsValue(rs, "checkout_login").equals("0")?"selected":"")%> value="0">No</option>
										</select>
									</div>
								</div>
								

								<% if(!"1".equals(parseNull(GlobalParm.getParm("IS_ORANGE_APP")))) { %>
							
								<div class="form-group row">
									<label for="service_params" class='col-sm-3 col-form-label font-weight-bold'>Show Service Schedule Only?</label>
									<div class='col-sm-9'>
										<select name="service_params" id="service_params" class="form-control" <%= (count!=0)? "disabled": "" %>>
												<option <%=(getRsValue(rs, "service_params").equals("1")?"selected":"")%> value="1">No</option>
												<option <%=(getRsValue(rs, "service_params").equals("0")?"selected":"")%> value="0">Yes</option>
										</select>
									</div>
								</div>
							
								<% } %>
								<div class="form-group row">
									<label for="deliver_outside_dep" class='col-sm-3 col-form-label font-weight-bold'>Deliver Outside Department?</label>
									<div class='col-sm-9'>
										<select name="deliver_outside_dep" id="deliver_outside_dep" class="form-control" <%= (count!=0)? "disabled": "" %>>
											<option <%=(getRsValue(rs, "deliver_outside_dep").equals("1")?"selected":"")%> value="1">Yes</option>
											<option <%=(getRsValue(rs, "deliver_outside_dep").equals("0")?"selected":"")%> value="0">No</option>
										</select>
									</div>
								</div>
								<div class="form-group row">
									<label for="multiple_catalogs_checkout" class='col-sm-3 col-form-label font-weight-bold'>Multiple Catalogs Checkout?</label>
									<div class='col-md-9'>
										<select name="multiple_catalogs_checkout" id="multiple_catalogs_checkout" class="form-control" <%= (count!=0)? "disabled": "" %>>
											<option <%=(getRsValue(rs, "multiple_catalogs_checkout").equals("1")?"selected":"")%> value="1">Yes</option>
											<option <%=(getRsValue(rs, "multiple_catalogs_checkout").equals("0")?"selected":"")%> value="0">No</option>
										</select>
									</div>
								</div>
								<div class="form-group row">
									<label for="show_product_detail_delivery_fee" class='col-sm-3 col-form-label font-weight-bold'>Show Product Detail Delivery Fee?</label>
									<div class='col-sm-9'>
										<select name="show_product_detail_delivery_fee" id="show_product_detail_delivery_fee" class="form-control" <%= (count!=0)? "disabled": "" %>>
											<option <%=(getRsValue(rs, "show_product_detail_delivery_fee").equals("1")?"selected":"")%> value="1">Yes</option>
											<option <%=(getRsValue(rs, "show_product_detail_delivery_fee").equals("0")?"selected":"")%> value="0">No</option>
										</select>
									</div>
								</div>

								<div class="form-group row ">
									<label for="inputUniverse" class='col-sm-3 col-form-label font-weight-bold'>Installment Duration Units</label>
									<div class='col-sm-9'>
									<%
										String[] installment_duration_units_array = getRsValue(rs, "installment_duration_units").split(",");
										for(String unit : installment_duration_units_array) arr.add(unit);
									%>
									<%=addSelectControl("installment_duration_units", "installment_duration_units", installment_duration_units, arr, "custom-select", "",true,count != 0)%>
									</div>
								</div>

								<div class="form-group row">
									<label for='lang_<%=lang.getLanguageId()%>_continue_shop_url' class='col-sm-3 col-form-label font-weight-bold'>Continue Shopping URL</label>
									<div class='col-sm-9'>
										<input type='text' name='lang_<%=lang.getLanguageId()%>_continue_shop_url' id='lang_<%=lang.getLanguageId()%>_continue_shop_url' class="form-control continue_shopping_url" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_continue_shop_url")%>'/>
									</div>
								</div>
						</div>
					</div>
				</div>
			</div>
			<div class="card mb-2">
				<div class="card-header bg-section-dark d-flex" href="#collapseShopDetails" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="collapseShopDetails" >
					<strong>Shop Details</strong>
					<div href="#" class="ml-2" data-toggle="tooltip" title="" data-original-title="Default tooltip">
						<svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
					</div>
				</div>
				<div id="collapseShopDetails" class="collapse" style="border:none; margin-bottom:none;">
					<div class="card-body">
						<div class="form-horizontal">
							<div class="form-group row">
								<label for="lang_<%=lang.getLanguageId()%>_terms" class='col-sm-3 col-form-label font-weight-bold'>Terms & Conditions</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_terms' id='lang_<%=lang.getLanguageId()%>_terms' class="form-control"  value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_terms")%>'>
								</div>
							</div>

							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_terms_error' class='col-sm-3 col-form-label font-weight-bold'>Terms Error</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_terms_error' id='lang_<%=lang.getLanguageId()%>_terms_error' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_terms_error")%>'>
								</div>
							</div>

							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_cart_message' class='col-sm-3 col-form-label font-weight-bold'>Cart Proceed Message</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_cart_message' id='lang_<%=lang.getLanguageId()%>_cart_message' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_cart_message")%>'>
								</div>
							</div>


							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_save_cart_text' class='col-sm-3 col-form-label font-weight-bold'>Save Cart Text</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_save_cart_text' id='lang_<%=lang.getLanguageId()%>_save_cart_text' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_save_cart_text")%>'>
								</div>
							</div>

							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_stock_alert_text' class='col-sm-3 col-form-label font-weight-bold'>Stock Alert Text</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_stock_alert_text' id='lang_<%=lang.getLanguageId()%>_stock_alert_text' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_stock_alert_text")%>'>
								</div>
							</div>

							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_stock_alert_button' class='col-sm-3 col-form-label font-weight-bold'>Stock Alert Button</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_stock_alert_button' id='lang_<%=lang.getLanguageId()%>_stock_alert_button' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_stock_alert_button")%>' >
								</div>
							</div>

							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_empty_cart_url' class='col-sm-3 col-form-label font-weight-bold'>Empty Cart URL</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_empty_cart_url' id='lang_<%=lang.getLanguageId()%>_empty_cart_url' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_empty_cart_url")%>'/>
								</div>
							</div>

							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_deliver_outside_dep_error' class='col-sm-3 col-form-label font-weight-bold'>Deliver Outside Department Error</label>
								<div class='col-sm-9'>
								 <input type='text' name='lang_<%=lang.getLanguageId()%>_deliver_outside_dep_error' id='lang_<%=lang.getLanguageId()%>_deliver_outside_dep_error' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_deliver_outside_dep_error")%>' >
								</div>
							</div>

							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_free_payment_method' class='col-sm-3 col-form-label font-weight-bold'>Free Payment Method Text</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_free_payment_method' id='lang_<%=lang.getLanguageId()%>_free_payment_method' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_free_payment_method")%>'/>
								</div>
							</div>

							<div class="form-group row">
								<label for='lang_<%=lang.getLanguageId()%>_free_delivery_method' class='col-sm-3 col-form-label font-weight-bold'>Free Delivery Method Text</label>
								<div class='col-sm-9'>
									<input type='text' name='lang_<%=lang.getLanguageId()%>_free_delivery_method' id='lang_<%=lang.getLanguageId()%>_free_delivery_method' class="form-control" value='<%=getValue(rs, "lang_"+lang.getLanguageId()+"_free_delivery_method")%>'/>
								</div>
							</div>

							</div>
						</div>
					</div>
			</div>
				
			<div class="card mb-2">
				<div class="card-header bg-section-dark d-flex" href="#collapsePaymentMethods" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="collapsePaymentMethods" >
					<strong>Payment Methods</strong>
					<div href="#" class="ml-2" data-toggle="tooltip" title="" data-original-title="Default tooltip">
						<svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
					</div>
				</div>
				<div id="collapsePaymentMethods" class="collapse" style="border:none; margin-bottom:none;">
					<div class="card-body">
						<div class="form-horizontal">
								<%
										
								int payment_method_count = 0;
								while(rsPaymentMethods.next()){
									payment_method_count++;
								%>
								<div class="card mb-2">
									<div class="card-header bg-<%=rsPaymentMethods.value("enable").equals("1")? "success":"danger"%>" data-toggle="collapse" href="#collapsePaymentMethod<%=payment_method_count%>" role="button" aria-expanded="true" aria-controls="collapsePaymentMethod<%=payment_method_count%>">
										<strong><%=escapeCoteValue(WordUtils.capitalizeFully(rsPaymentMethods.value("method").replaceAll("_"," ")))%></strong>
									</div>
										<div class="collapse" id="collapsePaymentMethod<%=payment_method_count%>" style="border: medium;">
											<div class="card-body">
												<input name="payment_method" type="hidden" value="<%=escapeCoteValue(rsPaymentMethods.value("method"))%>" <%= (count != 0)? "disabled":"" %>/>
												<input class="payment_method_order" disabled name="payment_method_order" type="hidden" value="<%=payment_method_count%>" <%= (count != 0)? "disabled":"" %> />

												<div class="form-group row">
													<label for='payment_method_order-<%=payment_method_count%>' class='col-sm-3 col-form-label font-weight-bold'>Seq.</label>
													<div class='col-sm-9'>
														<input type='text' name="payment_method_order" id="payment_method_order-<%=payment_method_count%>" class="form-control" <%= (count!=0)? "disabled": "" %> value="<%=escapeCoteValue(""+payment_method_count)%>" size="2"/>
													</div>
												</div>

												<div class="form-group row">
													<label for='payment-method-enable-<%=payment_method_count%>' class='col-sm-3 col-form-label font-weight-bold'>Enable?</label>
													<div class='col-sm-9'>
														<select name="payment_method_enable" id='payment-method-enable-<%=payment_method_count%>' class="form-control" <%= (count!=0)? "disabled": "" %> >
															<option value="0" <%=(rsPaymentMethods.value("enable").equals("0")?"selected":"")%>>No</option>
															<option value="1" <%=(rsPaymentMethods.value("enable").equals("1")?"selected":"")%>>Yes</option>
														</select>
													</div>
												</div>

												<div class="form-group row">
													<label for='payment_method_displayName-<%=payment_method_count%>' class='col-sm-3 col-form-label font-weight-bold'>Display Name</label>
													<div class='col-sm-9'>
														<input type='text' name="payment_method_displayName" id="payment_method_displayName-<%=payment_method_count%>" <%= (count!=0)? "disabled": "" %> class="form-control" value='<%=escapeCoteValue(rsPaymentMethods.value("displayName"))%>'/>
													</div>
												</div>

												<div class="form-group row">
													<label for='payment_method_helpText-<%=payment_method_count%>' class='col-sm-3 col-form-label font-weight-bold'>Help text</label>
													<div class='col-sm-9'>
														<textarea rows='6' type='text' name='payment_method_helpText' id='payment_method_helpText-<%=payment_method_count%>' <%= (count!=0)? "disabled": "" %> class="form-control" ><%=escapeCoteValue(rsPaymentMethods.value("helpText"))%></textarea>
													</div>
												</div>

												<div class="form-group row">
													<label for='payment_method_subText-<%=payment_method_count%>' class='col-sm-3 col-form-label font-weight-bold'>Sub text</label>
													<div class='col-sm-9'>
														<textarea rows='6' type='text' name='payment_method_subText' id='payment_method_subText-<%=payment_method_count%>' <%= (count!=0)? "disabled": "" %> class="form-control" ><%=escapeCoteValue(rsPaymentMethods.value("subText"))%></textarea>
													</div>
												</div>

												<div class="form-group row">
													<label for='payment_method_price-<%=payment_method_count%>' class='col-sm-3 col-form-label font-weight-bold'>Price</label>
													<div class='col-sm-9'>
														<input type='text' name="payment_method_price" id="payment_method_price-<%=payment_method_count%>" class="form-control" <%= (count!=0)? "disabled": "" %> value='<%=escapeCoteValue(rsPaymentMethods.value("price"))%>'/>
													</div>
												</div>
												
												<div class="form-group row">
													<label for='payment_method_excludedProduct-<%=payment_method_count%>' class='col-sm-3 col-form-label font-weight-bold'>Excluded products</label>
													<div class="col-sm-9" id="payment_method_excludedProduct-<%=payment_method_count%>">
														<div class="input-group">
															<div class="d-flex w-100 mb-2">
																<input name="payment_method_unique_id" type="hidden" value="<%=escapeCoteValue(rsPaymentMethods.value("method"))%>" <%= (count != 0)? "disabled":"" %>/>
																<select class="custom-select col-sm-3" <%=(count!=0)?"disabled":""%> name="payment_method_excludedType" 
																	id="payment_method_excludedType-<%=payment_method_count%>" aria-label="" onchange="clearSiblingInput(this)">
																	<option value="folder">Catalog</option>
																	<option value="sku">SKU</option>
																	<option value="product_name">Product name</option>
																	<option value="product_type">Product Type</option>
																	<option value="manufacturer">Manufacturer</option>
																	<option value="tag">Tag</option>
																</select>
												
																<div class="position-relative w-100">
																	<input type="text" class="form-control tagsInput" placeholder="search and add (by clicking return)" 
																		<%= (count != 0) ? "disabled" : "" %> name="payment_method_excludedItem" 
																		value='<%= (count != 0) ? "Please see the primary language" : "" %>'>
																</div>
															</div>
															<div class="tagsDiv row">
																<%
																	if(count==0){
																		Set rsExcludedItems = Etn.execute("select * from payment_n_delivery_method_excluded_items where method_type='payment' and method="+
																			escape.cote(rsPaymentMethods.value("method"))+" and site_id="+escape.cote(selectedsiteid)+" order by id");
																		int countExcludedPills = 0;
																		while(rsExcludedItems.next()){
																			String excludedType = rsExcludedItems.value("item_type");
																			String excludedItemId = rsExcludedItems.value("item_id");
																			String excludedPaymentMethod = rsExcludedItems.value("method");
																%>
																			<span class="badge badge-pill badge-dark badge-tag mb-2 mr-2" data-tag_pillid="_tagpill<%=escapeCoteValue(""+countExcludedPills)%>">	
																					<span class="badge-folder pr-1">&nbsp;<%=capitalizeFirstChar(escapeCoteValue(excludedType))+"->"%></span>
																					<%
																						if(excludedType.equals("tag")){
																							Set rsName = Etn.execute("select label from tags where id="+escape.cote(excludedItemId)+" and site_id="+escape.cote(selectedsiteid));
																							if(rsName.next()){
																					%>
																								<%=escapeCoteValue(rsName.value("label"))%>
																					<%
																							}
																						}else if(excludedType.equals("product_type")){
																							Set rsName = Etn.execute("select type_name from product_types_v2 where id="+escape.cote(excludedItemId));
																							if(rsName.next()){
																					%>
																								<%=escapeCoteValue(rsName.value("type_name"))%>
																					<%
																							}
																						}else if(excludedType.equals("folder")){
																							Set rsName = Etn.execute("select name from products_folders where id="+escape.cote(excludedItemId));
																							if(rsName.next()){
																					%>
																								<%=escapeCoteValue(rsName.value("name"))%>
																					<%
																							}
																						}else{
																					%>
																							<%=escapeCoteValue(excludedItemId)%>
																					<%
																						}
																					%>
																				<a type="button" class="badge badge-pill badge-white ml-2">
																					<i data-feather="x" style="color:#f16e00"></i>
																				<input type="hidden" class="tagValue" name="excluded_product_type" value="<%=escapeCoteValue(excludedType)%>">
																				<input type="hidden" class="tagValue" name="excluded_product_value" value="<%=escapeCoteValue(excludedItemId)%>">
																				<input type="hidden" class="tagValue" name="excluded_payment_method" value="<%=escapeCoteValue(excludedPaymentMethod)%>">
																				</a>
																			</span>
																<%
																			countExcludedPills++;
																		}
																	}
																%>
															</div>
														</div>
													</div>
												</div>
											</div>
										</div>
									</div>
								<%}%>
						</div>
					</div>
				</div>
			</div>
			<div class="card mb-2">
				<div class="card-header bg-section-dark d-flex" href="#collapseDeliveryMethods" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="collapseDeliveryMethods" >
					<strong>Delivery Methods</strong>
					<div href="#" class="ml-2" data-toggle="tooltip" title="" data-original-title="Default tooltip">
						<svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
					</div>
				</div>
				<div id="collapseDeliveryMethods" class="collapse" style="border:none; margin-bottom:none;">
					<div id="deliveryMethodsContainer" class="card-body">
						<datalist id="subTypes">
							<%
							Set rsSubTypes = Etn.execute("select distinct subType from delivery_methods where site_id = "+escape.cote(selectedsiteid)+" and coalesce(subType,'')!='' order by method,id;");
							while(rsSubTypes.next()){
							%>
							<option value="<%=escapeCoteValue(rsSubTypes.value("subType"))%>">
							<%}%>
						</datalist>

						<%
							int deliveryMethodCount=0;								
							while(rsDeliveryMethods.next()){
								deliveryMethodCount+=1;
						%>
						
						<div class="card mb-2">
							<div class="card-header bg-<%=rsDeliveryMethods.value("enable").equals("1")? "success":"danger"%>" data-toggle="collapse" href="#collapseDeliveryMethod<%=deliveryMethodCount%>" role="button" aria-expanded="true" aria-controls="collapseDeliveryMethod<%=deliveryMethodCount%>">
								<strong><%=escapeCoteValue(WordUtils.capitalizeFully(rsDeliveryMethods.value("displayName")))%> | <%=escapeCoteValue(WordUtils.capitalizeFully(rsDeliveryMethods.value("subType")))%> </strong>
							</div>

							<div class="collapse" id="collapseDeliveryMethod<%=deliveryMethodCount%>" style="border: medium;">
								<div class="card-body">
									<input name="delivery_method_order" value="<%=escapeCoteValue(rsDeliveryMethods.value("orderSeq"))%>" size="2" class="form-control" disabled type="hidden" />
									
									<div class="form-horizontal">
										
										<div class="form-group row">
											<label for='delivery_method_order-<%=deliveryMethodCount%>' class='col-sm-3 col-form-label font-weight-bold'>Seq.</label>
											<div class='col-sm-9'>
												<input type='text' name="delivery_method_order" id="delivery_method_order-<%=deliveryMethodCount%>" class="form-control" <%= (count!=0)? "disabled": "" %> value="<%=escapeCoteValue(""+deliveryMethodCount)%>" size="2"/>
											</div>
										</div>
										
										<div class="form-group row">
											<label for='delivery_method_enable-<%=deliveryMethodCount%>' class='col-sm-3 col-form-label font-weight-bold'>Enable?</label>
											<div class='col-sm-9'>
												<select name="delivery_method_enable" id='delivery_method_enable-<%=deliveryMethodCount%>' class="form-control" <%= (count!=0)? "disabled": "" %>>
													<option value="0" <%=(rsDeliveryMethods.value("enable").equals("0")?"selected":"")%>>No</option>
													<option value="1" <%=(rsDeliveryMethods.value("enable").equals("1")?"selected":"")%>>Yes</option>
												</select>
											</div>
										</div>

										<div class="form-group row">
											<label for='delivery_method_displayName-<%=deliveryMethodCount%>' class='col-sm-3 col-form-label font-weight-bold'>Display Name</label>
											<div class='col-sm-9'>
												<input type='text' name="delivery_method_displayName" id="delivery_method_displayName-<%=deliveryMethodCount%>" <%= (count!=0)? "disabled": "" %> size="10" class="form-control" value='<%=escapeCoteValue(rsDeliveryMethods.value("displayName"))%>'/>
											</div>
										</div>

										<div class="form-group row">
											<label for='delivery_method-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Delivery Method</label>
											<div class='col-sm-9'>
												<%
													arr.clear();
													arr.add(escapeCoteValue(rsDeliveryMethods.value("method")));
												%>
												<%=addSelectControl("delivery_method-"+lang.getLanguageId(), "delivery_method", delivery_methods, arr, "custom-select delivery-method", "",false,count != 0)%>
											</div>
										</div>

										<div class="form-group row">
											<label for='delivery_method_subType-<%=deliveryMethodCount%>' class='col-sm-3 col-form-label font-weight-bold'>Type</label>
											<div class='col-sm-9'>
												<input type='text' list="subTypes" name="delivery_method_subType" id="delivery_method_subType-<%=deliveryMethodCount%>" <%= (count!=0)? "disabled": "" %> autocomplete="off" size="10" class="form-control" oninput="onChangeBrandName(this)" value="<%=escapeCoteValue(rsDeliveryMethods.value("subType"))%>"/>
											</div>
										</div>

										<div class="form-group row">
											<label for='delivery_method_price-<%=deliveryMethodCount%>' class='col-sm-3 col-form-label font-weight-bold'>Price</label>
											<div class='col-sm-9'>
												<input type='text' name="delivery_method_price" id="delivery_method_price-<%=deliveryMethodCount%>" class="form-control" <%= (count!=0)? "disabled": "" %> value="<%=escapeCoteValue(rsDeliveryMethods.value("price"))%>" size="10"/>
											</div>
										</div>

										<div class="form-group row">
											<label for='delivery_method_mapsDisplay-<%=deliveryMethodCount%>' class='col-sm-3 col-form-label font-weight-bold'>Map Display?</label>
											<div class='col-sm-9'>
												<select name="delivery_method_mapsDisplay" id='delivery_method_mapsDisplay-<%=deliveryMethodCount%>' class="form-control" <%= (count!=0)? "disabled": "" %>>
													<option value="0" <%=(rsDeliveryMethods.value("mapsDisplay").equals("0")?"selected":"")%>>No</option>
													<option value="1" <%=(rsDeliveryMethods.value("mapsDisplay").equals("1")?"selected":"")%>>Yes</option>
												</select>
											</div>
										</div>

										<div class="form-group row">
											<label for='delivery_method_helpText-<%=deliveryMethodCount%>' class='col-sm-3 col-form-label font-weight-bold'>Help Text</label>
											<div class='col-sm-9'>
												<textarea name="delivery_method_helpText" id="delivery_method_helpText-<%=deliveryMethodCount%>" type='text' <%= (count!=0)? "disabled": "" %> class="form-control" placeholder="Help Text"><%=escapeCoteValue(rsDeliveryMethods.value("helpText"))%></textarea>
											</div>
										</div>

										<div class="form-group row">
											<label for='delivery_method_excludedProduct-<%=deliveryMethodCount%>' class='col-sm-3 col-form-label font-weight-bold'>Excluded products</label>
											<div class="col-sm-9" id="delivery_method_excludedProduct-<%=deliveryMethodCount%>">
												<div class="input-group">
													<div class="d-flex w-100 mb-2">
														<input name="delivery_method_unique_id" type="hidden" value="<%=escapeCoteValue(rsDeliveryMethods.value("method"))%>" <%= (count != 0)? "disabled":"" %>/>
														<input name="delivery_method_unique_id_type" type="hidden" value="<%=escapeCoteValue(rsDeliveryMethods.value("subType"))%>" <%= (count != 0)? "disabled":"" %>/>
														<select class="custom-select col-sm-3" <%=(count!=0)?"disabled":""%> name="delivery_method_excludedType" 
															id="delivery_method_excludedType-<%=deliveryMethodCount%>" aria-label="" onchange="clearSiblingInput(this)">
															<option value="folder">Catalog</option>
															<option value="sku">SKU</option>
															<option value="product_name">Product name</option>
															<option value="product_type">Product Type</option>
															<option value="manufacturer">Manufacturer</option>
															<option value="tag">Tag</option>
														</select>
										
														<div class="position-relative w-100">
															<input type="text" class="form-control tagsInput" placeholder="search and add (by clicking return)" 
																<%= (count != 0) ? "disabled" : "" %> name="delivery_method_excludedItem" 
																value='<%= (count != 0) ? "Please see the primary language" : "" %>'>
														</div>
													</div>
													<div class="tagsDiv row">
														<%
															if(count==0){
																Set rsExcludedItems = Etn.execute("select * from payment_n_delivery_method_excluded_items where method_type='delivery' and method="+
																	escape.cote(rsDeliveryMethods.value("method"))+" and method_sub_type="+escape.cote(rsDeliveryMethods.value("subType"))+
																	" and site_id="+escape.cote(selectedsiteid)+" order by id");
																int countExcludedPills = 0;
																while(rsExcludedItems.next()){
																	String excludedType = rsExcludedItems.value("item_type");
																	String excludedItemId = rsExcludedItems.value("item_id");
																	String excludeddeliveryMethod = rsExcludedItems.value("method");
																	String excludeddeliveryMethodSub = rsExcludedItems.value("method_sub_type");
														%>
																	<span class="badge badge-pill badge-dark badge-tag mb-2 mr-2" data-tag_pillid="_tagpill<%=escapeCoteValue(""+countExcludedPills)%>">
																		
																		<span class="badge-folder pr-1">&nbsp;<%=capitalizeFirstChar(escapeCoteValue(excludedType))+"->"%></span>
																			<%
																				if(excludedType.equals("tag")){
																					Set rsName = Etn.execute("select label from tags where id="+escape.cote(excludedItemId)+" and site_id="+escape.cote(selectedsiteid));
																					if(rsName.next()){
																			%>
																						<%=escapeCoteValue(rsName.value("label"))%>
																			<%
																					}
																				}else if(excludedType.equals("product_type")){
																					Set rsName = Etn.execute("select type_name from product_types_v2 where id="+escape.cote(excludedItemId));
																					if(rsName.next()){
																			%>
																						<%=escapeCoteValue(rsName.value("type_name"))%>
																			<%
																					}
																				}else if(excludedType.equals("folder")){
																					Set rsName = Etn.execute("select name from products_folders where id="+escape.cote(excludedItemId));
																					if(rsName.next()){
																			%>
																						<%=escapeCoteValue(rsName.value("name"))%>
																			<%
																					}
																				}else{
																			%>
																					<%=escapeCoteValue(excludedItemId)%>
																			<%
																				}
																			%>
																		<a type="button" class="badge badge-pill badge-white ml-2">
																			<i data-feather="x" style="color:#f16e00"></i>
																		<input type="hidden" class="tagValue" name="delivery_excluded_product_type" value="<%=escapeCoteValue(excludedType)%>">
																		<input type="hidden" class="tagValue" name="delivery_excluded_product_value" value="<%=escapeCoteValue(excludedItemId)%>">
																		<input type="hidden" class="tagValue" name="excluded_delivery_method" value="<%=escapeCoteValue(excludeddeliveryMethod)%>">
																		<input type="hidden" class="tagValue" name="excluded_delivery_method_sub" value="<%=escapeCoteValue(excludeddeliveryMethodSub)%>">
																		</a>																		
																	</span>
														<%
																	countExcludedPills++;
																}
															}
														%>
													</div>
												</div>
											</div>
										</div>
										<div class="clearfix">
											<%
												if(count == 0){
											%>
													<button type='button' class="btn btn-danger btn-sm float-right delete-delivery-method" >
														<i data-feather="trash-2"></i>
													</button>
											<%
												}
											%>
										</div>
									</div>
								</div>
							</div>
						</div>
						<%
						}
						%>

						<div class="row mt-2 delete-btn <%= (count!=0)? "d-none": "" %>" >
							<div class="col">
								<button type="button" class="btn btn-success float-right add-delivery-method" style="cursor:pointer">
									<span class="fa fa-plus"></span>
									Add Method
								</button>
							</div>
						</div>

					</div>
				</div>
			</div>
			<div class="card mb-2">
				<div class="card-header bg-section-dark d-flex" href="#collapseFraudRules" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="collapseFraudRules">
					<strong>Fraud Rules</strong>
					<div href="#" class="ml-2" data-toggle="tooltip" title="" data-original-title="Default tooltip">
						<svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
					</div>
				</div>
				<div id="collapseFraudRules" class="collapse" style="border:none; margin-bottom:none;">
					<div class="card-body">
						<div class="form-horizontal">
							
							<div class="form-group row">
								<label for='topup_max_amount-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Max TopUp Amount</label>
								<div class='col-sm-9'>
									<input type='text' name="topup_max_amount" id="topup_max_amount-<%=lang.getLanguageId()%>" class="form-control" <%= (count!=0)? "disabled": "" %> value="<%=escapeCoteValue(rs.value("topup_max_amount"))%>" size="10"/>
								</div>
							</div>

							<div class="form-group row">
								<label for='card2wallet_max_amount-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Max card to wallet amount</label>
								<div class='col-sm-9'>
									<input type='text' name="card2wallet_max_amount" id="card2wallet_max_amount-<%=lang.getLanguageId()%>" class="form-control" <%= (count!=0)? "disabled": "" %> value="<%=escapeCoteValue(rs.value("card2wallet_max_amount"))%>" size="10"/>
								</div>
							</div> 
							
							<% Set rsFraudRules = Etn.execute("select f.*, r.display_name as column_display_name from fraud_rules f join "+GlobalParm.getParm("COMMONS_DB")+".fraud_rules_columns r on r.name = f.column "+														
															" where f.site_id = "+escape.cote(selectedsiteid)+" order by f.cart_type, f.column, f.days "); 
								
							int rule_count = 0;
							while(rsFraudRules.next()){
								String period = rsFraudRules.value("days");
								if(period.equals("1")) period = "Daily";
								else if(period.equals("7")) period = "Weekly";
								else if(period.equals("30")) period = "Monthly";
								else period = "Yearly";

								String fCartType = rsFraudRules.value("cart_type");
								if(fCartType.equals("normal")) fCartType = "Normal";
								else if(fCartType.equals("topup")) fCartType = "Topup";
								else if(fCartType.equals("card2wallet")) fCartType = "Card to wallet";
								else fCartType = "Unknown";
							%>

								<div class="card mb-2 fraudRulesDiv_<%=lang.getLanguageId()%>">
									<div class="card-header bg-<%=rsFraudRules.value("enable").equals("1")? "success":"danger"%>" data-toggle="collapse" href="#collapseFraudRule<%=rule_count%>" role="button" aria-expanded="true" aria-controls="collapseFraudRule<%=rule_count%>">
										<strong><%=escapeCoteValue(WordUtils.capitalizeFully(rsFraudRules.value("column_display_name"))) %> | <%= escapeCoteValue(WordUtils.capitalizeFully(rsFraudRules.value("cart_type"))) %> | <%= escapeCoteValue(WordUtils.capitalizeFully(period) )%></strong>
									</div>
								</div>

								<div id="collapseFraudRule<%=rule_count%>" class="collapse" style="border:none; margin-bottom:none;">
									<div class="card-body">
										<div class="form-horizontal">
											
											<div class="form-group row">
												<label for='fraud_rule_enable-<%=rule_count%>' class='col-sm-3 col-form-label font-weight-bold'>Enable?</label>
												<div class='col-sm-9'>
													<select name="fraud_rule_enable" class="form-control" <%= (count!=0)? "disabled": "" %> >
														<option value="0" <%=(rsFraudRules.value("enable").equals("0")?"selected":"")%>>No</option>
														<option value="1" <%=(rsFraudRules.value("enable").equals("1")?"selected":"")%>>Yes</option>
													</select>
												</div>
											</div>

											<div class="form-group row">
												<label for='fraud_rule_cart_type-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Cart Type</label>
												<div class='col-sm-9'>
													<input type='text' name="fraud_rule_cart_type" id="fraud_rule_cart_type-<%=lang.getLanguageId()%>" class="form-control" <%= (count!=0)? "disabled": "" %> value="<%=escapeCoteValue(WordUtils.capitalizeFully(rsFraudRules.value("cart_type")))%>" readonly/>
												</div>
											</div>

											<div class="form-group row">
												<label for='fraud_rule_column-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Column Name</label>
												<div class='col-sm-9'>
												    <input type="hidden"  name="fraud_rule_column" id="fraud_rule_column-<%=lang.getLanguageId()%>" class="form-control" <%= (count!=0)? "disabled": "" %> value="<%=escapeCoteValue(WordUtils.capitalizeFully(rsFraudRules.value("column")))%>" >
													<input type='text'   class="form-control" <%= (count!=0)? "disabled": "" %>  value="<%=escapeCoteValue(WordUtils.capitalizeFully(rsFraudRules.value("column_display_name")))%>" readonly/>
												</div>
											</div>

											<div class="form-group row">
												<label for='fraud_rule_day-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Period</label>
												<div class='col-sm-9'>
												<input type="hidden" name="fraud_rule_day" value="<%= period.equals("Daily") ? "1" : period.equals("Weekly") ? "7" : "30" %>">
													<select name="fraud_rule_day" class="form-control" disabled>
														<option value="1" <%=(period.equals("Daily")?"selected":"")%>>Daily</option>
														<option value="7" <%=(period.equals("Weekly")?"selected":"")%>>Weekly</option>
														<option value="30" <%=(period.equals("Monthly")?"selected":"")%>>Monthly</option>
													</select>
												</div>
											</div>
											
											<div class="form-group row">
												<label for='fraud_rule_limit-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Limit</label>
												<div class='col-sm-9'>
													<input type='text' name="fraud_rule_limit" id="fraud_rule_limit-<%=lang.getLanguageId()%>" class="form-control" <%= (count!=0)? "disabled": "" %> size="10" value="<%=escapeCoteValue(rsFraudRules.value("limit"))%>"/>
												</div>
											</div>
												<%
													if(count == 0){
												%>
														<div class="clearfix">
															<input id="fraud_rule_delete_<%=rule_count%>" name="fraud_rule_delete" type="hidden" value="0"/>
															<button type='button' class="btn btn-danger btn-sm float-right delete-fraud-rule" onclick="delete_fraud_rule('<%=rule_count%>');" >
																<i data-feather="trash-2"></i>
															</button>
														</div>
												<%
													}
												%>
										</div>
									</div>
								</div>	
								<%
								rule_count++;
								}%>

							<div class="row mt-2 delete-btn <%= (count!=0)? "d-none": "" %>" >
							
							</div>
						
						</div>

							<%
								if(count == 0){
							%>
									<div class="col">
										<button type="button" class="btn btn-success float-right add-fraud-rule" onclick="addFraudRule('<%=lang.getLanguageId()%>',<%=rule_count%>)" style="cursor:pointer">
											<span class="fa fa-plus"></span>
											Add Rule
										</button>
									</div>
							<%
								}
							%>
						</div>
					</div>
				</div>
			<%-- </div> --%>

			<div class="card mb-2">
				<div class="card-header bg-section-dark d-flex" href="#collapseEmails" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="collapseEmails">
					<strong>Emails</strong>
					<div href="#" class="ml-2" data-toggle="tooltip" title="Emails" data-original-title="Default tooltip" style="text-decoration: none">
						<svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
					</div>
				</div>
				<div id="collapseEmails" class="collapse" style="border:none; margin-bottom:none;">
					<div class="card-body">
						<div class="form-horizontal">
							<div class="form-group row">
								<label for='save_cart_email_id_test-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Save Cart Test site</label>
								<div class='col-sm-9'>
									<%
										arr.clear();
										arr.add(getRsValue(rs, "save_cart_email_id_test"));
									%>
									<%=addSelectControl("save_cart_email_id_test-"+lang.getLanguageId(), "save_cart_email_id_test", devShopEmails, arr, "custom-select", "",false,count != 0)%>
								</div>
							</div>

							<div class="form-group row">
								<label for='save_cart_email_id_prod-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Save Cart Prod site</label>
								<div class='col-sm-9'>
									<%
										arr.clear();
										arr.add(getRsValue(rs, "save_cart_email_id_prod"));
									%>
									<%=addSelectControl("save_cart_email_id_prod-"+lang.getLanguageId(), "save_cart_email_id_prod", prodShopEmails, arr, "custom-select", "",false,count != 0)%>
								</div>
							</div>

							<div class="form-group row">
								<label for='stock_alert_email_id_test-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Stock Alert Test site</label>
								<div class='col-sm-9'>
									<%
										arr.clear();
										arr.add(getRsValue(rs, "stock_alert_email_id_test"));
									%>
									<%=addSelectControl("stock_alert_email_id_test-"+lang.getLanguageId(), "stock_alert_email_id_test", devShopEmails, arr, "custom-select", "",false,count != 0)%>
								</div>
							</div>

							<div class="form-group row">
								<label for='stock_alert_email_id_prod-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Stock Alert Prod site</label>
								<div class='col-sm-9'>
									<%
										arr.clear();
										arr.add(getRsValue(rs, "stock_alert_email_id_prod"));
									%>
									<%=addSelectControl("stock_alert_email_id_prod-"+lang.getLanguageId(), "stock_alert_email_id_prod", prodShopEmails, arr, "custom-select", "",false,count != 0)%>
								</div>
							</div>

							<div class="form-group row">
								<label for='inventory_email_test-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Inventory Test Site</label>
								<div class='col-sm-9'>
									<input type='text' name="inventory_email_test" placeholder="abc@gmail.com" id="inventory_email_test-<%=lang.getLanguageId()%>" <%= (count!=0)? "disabled": "" %> class="form-control" value='<%=parseNull(inventoryRs.value("email_test"))%>'/>
								</div>
							</div> 

							 <div class="form-group row">
								<label for='inventory_email_prod-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Inventory Prod Site</label>
								<div class='col-sm-9'>
									<input type='text' name="inventory_email_prod" placeholder="abc@gmail.com" id="inventory_email_prod-<%=lang.getLanguageId()%>" <%= (count!=0)? "disabled": "" %> class="form-control" value='<%=parseNull(inventoryRs.value("email_prod"))%>'/>
								</div>
							</div> -

							<div class="form-group row">
								<label for='incomplete_cart_email_id_test-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Incomplete Cart Prod site</label>
								<div class='col-sm-9'>
									<%
										arr.clear();
										arr.add(getRsValue(rs, "incomplete_cart_email_id_test"));
									%>
									<%=addSelectControl("incomplete_cart_email_id_test-"+lang.getLanguageId(), "incomplete_cart_email_id_test", devShopEmails, arr, "custom-select", "",false,count != 0)%>
								</div>
							</div>

							<div class="form-group row">
								<label for='incomplete_cart_email_id_prod-<%=lang.getLanguageId()%>' class='col-sm-3 col-form-label font-weight-bold'>Incomplete Cart Prod site</label>
								<div class='col-sm-9'>
									<%
										arr.clear();
										arr.add(getRsValue(rs, "incomplete_cart_email_id_prod"));
									%>
									<%=addSelectControl("incomplete_cart_email_id_prod-"+lang.getLanguageId(), "incomplete_cart_email_id_prod", prodShopEmails, arr, "custom-select", "",false,count != 0)%>
								</div>
							</div>							
						</div>
					</div>
				</div>
			</div>
             
			 <div class="card mb-2">
				<div class="card-header bg-section-dark d-flex" href="#collapseHolidays" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="collapseHolidays">
					<strong>Local Holidays</strong>
					<div href="#" class="ml-2" data-toggle="tooltip" title="Emails" data-original-title="Default tooltip" style="text-decoration: none">
						<svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
					</div>
				</div>
				<div id="collapseHolidays" class="collapse" style="border:none; margin-bottom:none;">
					<div class="card-body">
					<% 
					   Set  rsLocalHolidays = Etn.execute("SELECT holiday_name, DATE_FORMAT(MIN(h_date), '%Y-%m-%d') AS start_date, DATE_FORMAT(MAX(h_date), '%Y-%m-%d') AS end_date  FROM " + GlobalParm.getParm("COMMONS_DB") + ".local_holidays GROUP BY holiday_name order by start_date");
							%>
						<div class="form-horizontal" id="holiday-row">
						<% while (rsLocalHolidays.next()) {
							
							%>
							<div class="form-group row" >
							     
									<label for='local_holiday' class='col-sm-3 col-form-label font-weight-bold'><%= (parseNull(rsLocalHolidays.value("holiday_name")).length() > 0?rsLocalHolidays.value("holiday_name") : "No name for holiday") %></label>
									<div class='col-sm-9'>
									<input type="hidden" name="holiday_name" value="<%= rsLocalHolidays.value("holiday_name")%>" <%= (count!=0)? "disabled": "" %> >
										<div class="holiday-row" >
										  <label for="start_date" class="font-weight-bold"> Start Date
												<input type="date" name="start_date" value="<%= rsLocalHolidays.value("start_date")%>" <%= (count!=0)? "disabled": "" %>  class="form-control" >
											</label>
											<label for="end_date" class="font-weight-bold"> End Date
												<input type="date" name="end_date" value="<%= rsLocalHolidays.value("end_date")%>" <%= (count!=0)? "disabled": "" %>  class="form-control" >
											</label>
											<%
												if(count == 0){
											%>
													<button type="button" class="btn btn-danger btn-sm  delete-local-holiday" style="margin-left:15px;">
														<i data-feather="trash-2"></i>
													</button>
											<%
												}
											%>
										</div>
								</div>
							</div>		
							<% } %>			
						</div>
					<div>
						<%
							if(count == 0){
						%>
								<button type="button" class="btn btn-success  float-right add-local-holiday" style="cursor:pointer" onclick="addHoliday()" >
									<span class="fa fa-plus"></span>
									Add Holiday
								</button>
						<%
							}
						%>
					</div>
					</div>
				</div>
			 </div>

			<div class="card mb-2">
				<div class="card-header bg-section-dark collapsed" data-toggle="collapse" href="#collapseDeliverySlots" onclick="setLastOpenedSection('collapseDeliverySlots') role="button" aria-expanded="false" aria-controls="collapseDeliverySlots">
					<strong>
						Home Delivery Slots
						<a href="#" class="ml-2" data-toggle="tooltip" title="" data-original-title="Default tooltip"></a>
						<svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1">
							<circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line>
						</svg>
					</strong>
				</div>
					<div class="collapse" id="collapseDeliverySlots" style="border: none;">
					
						<div class="card-body">
					     <% for (int i = 0; i < daysOfWeeks.length; i++) { %>
								<div class="form-group row">
									<label for="" class="col-sm-3 col-form-label font-weight-bold"><%= daysOfWeeks[i] %></label>
									<div class="col-sm-9">
										<div id="time_input_<%=i%>">
										<input type="hidden" name="language_id" value="<%=lang.getLanguageId()%>">

										<% JSONArray dayArray = weekDays.getJSONArray(String.valueOf(i)); %>
										<% if (dayArray.length() > 0) { %>
										<% for (int j = 0; j < dayArray.length(); j++) { %>
										<% JSONObject obj = dayArray.getJSONObject(j); %>
										<div class="delivery-slot-row">
											<label for="start_hour_<%=i%>_<%=lang.getLanguageId()%>">
										<select name="start_hour_<%=i%>_<%=lang.getLanguageId()%>" class="form-control" <%= (count != 0) ? "disabled" : "" %> style="font-size: 16px; padding: 10px; height: auto;width: 129px;">
													<% 
														String startHourStr = obj.optString("startHour", "--");
														Integer selectedstartHour = "--".equals(startHourStr) ? null : Integer.parseInt(startHourStr);
														out.print(generateHourOptions(selectedstartHour));
													%>
												</select>
											</label>
											<span>:</span>
											<label for="start_minutes">
												<select name="start_minutes_<%=i%>_<%=lang.getLanguageId()%>" class="form-control" <%= (count != 0) ? "disabled" : "" %> style="font-size: 16px; padding: 10px; height: auto;width: 129px;">
													<% 
														String startMinuteStr = obj.optString("startMinute", "--");
														Integer selectedstartMinute = "--".equals(startMinuteStr) ? null : Integer.parseInt(startMinuteStr);
														out.print(generateMinuteOptions(selectedstartMinute));
													%>
												</select>
											</label>
											<span>-</span>
											<label for="end_hour">
												<select name="end_hour_<%=i%>_<%=lang.getLanguageId()%>" class="form-control" <%= (count != 0) ? "disabled" : "" %> style="font-size: 16px; padding: 10px; height: auto;width: 129px;">
														<% 
															String endHourStr = obj.optString("endHour", "--");
															Integer selectedendHour = "--".equals(endHourStr) ? null : Integer.parseInt(endHourStr);
															out.print(generateHourOptions(selectedendHour));
														%>
												</select>
											</label>
											<span>:</span>
											<label for="end_minutes">
											   <select name="end_minutes_<%=i%>_<%=lang.getLanguageId()%>" class="form-control" <%= (count != 0) ? "disabled" : "" %> style="font-size: 16px; padding: 10px; height: auto;width: 129px;">
													<% 
														String endMinuteStr = obj.optString("endMinute", "--");
														Integer selectedendMinute = "--".equals(endMinuteStr) ? null : Integer.parseInt(endMinuteStr);
														out.print(generateMinuteOptions(selectedendMinute));
													%>
												</select>
											</label>
											<%
												if(count == 0){
											%>
													<button type='button' class="btn btn-danger btn-sm float-right delete-delivery-slot" >
														<i data-feather="trash-2"></i>
													</button>
											<%
												}
											%>
										</div>
											<% }//end for (int j = 0; j < dayArray.length(); j++) %>
										<% }  %>
                                          
										</div>
										<div>
											<%
												if(count == 0){
											%>
													<button type="button" class="btn btn-success  float-right add-time-slot" style="cursor:pointer" onclick="addSlot(<%=i%> ,<%=lang.getLanguageId()%>)" >
														<span class="fa fa-plus"></span>
														Add Slot
													</button>
											<%
												}
											%>
										</div>
										
								  </div>
							    </div>
								<div class="separator"></div>
								<% } %>
						</div>

					</div>
				</div>

			</div>

			<% 
				count+=1;
			}%>
		</div>

	</form>

	<template id="deliveryMethodsTemplate">
		<div class="card mb-2">
			<div class="card-header bg-danger d-flex" role="button" data-toggle="collapse" aria-expanded="false">
				<strong>&nbsp;</strong>
			</div>

			<div class="collapse" style="border: medium;">
				<div class="card-body">
					<input name="delivery_method_order" size="2" class="form-control" type="hidden" />
					<div class="form-horizontal">
					<div class="form-group row">
					    <label for='delivery_method_order' class='col-sm-3 col-form-label font-weight-bold'>Seq.</label>
						<div class='col-sm-9'>
							<input type='text' name="delivery_method_order" id="delivery_method_order" class="form-control"  value="0" size="2"/>
						</div>
					</div>
						<div class="form-group row">
							<label for='delivery_method_enable' class='col-sm-3 col-form-label font-weight-bold'>Enable?</label>
							<div class='col-sm-9'>
								<select name="delivery_method_enable" id='delivery_method_enable' class="form-control">
									<option value="0">No</option>
									<option value="1">Yes</option>
								</select>
							</div>
						</div>

						<div class="form-group row">
							<label for='delivery_method_displayName' class='col-sm-3 col-form-label font-weight-bold'>Display Name</label>
							<div class='col-sm-9'>
								<input type='text' name="delivery_method_displayName" id="delivery_method_displayName"  size="10" class="deliv-method form-control" />
							</div>
						</div>

						<div class="form-group row">
							<label for='delivery_method' class='col-sm-3 col-form-label font-weight-bold'>Delivery Method</label>
							<div class='col-sm-9'>
								<select name="delivery_method" class="custom-select delivery-method">
									<option selected="selected" value="home_delivery">Home Delivery</option>
									<option value="pick_up_in_store">Pick Up In Store</option>
									<option value="pick_up_in_package_point">pick Up In Package Point</option>
								</select>
							</div>
						</div>

						<div class="form-group row">
							<label for='delivery_method_subType' class='col-sm-3 col-form-label font-weight-bold'>Type</label>
							<div class='col-sm-9'>
								<input type='text' list="subTypes" name="delivery_method_subType" id="delivery_method_subType" autocomplete="off" size="10" class="form-control" oninput="onChangeBrandName(this)"/>
							</div>
						</div>

						<div class="form-group row">
							<label for='delivery_method_price' class='col-sm-3 col-form-label font-weight-bold'>Price</label>
							<div class='col-sm-9'>
								<input type='text' name="delivery_method_price" id="delivery_method_price" class="form-control" size="10"/>
							</div>
						</div>

						<div class="form-group row">
							<label for='delivery_method_mapsDisplay' class='col-sm-3 col-form-label font-weight-bold'>Map Display?</label>
							<div class='col-sm-9'>
								<select name="delivery_method_mapsDisplay" id='delivery_method_mapsDisplay' class="form-control">
									<option value="0">No</option>
									<option value="1">Yes</option>
								</select>
							</div>
						</div>

						<div class="form-group row">
							<label for='delivery_method_helpText' class='col-sm-3 col-form-label font-weight-bold'>Help Text</label>
							<div class='col-sm-9'>
								<textarea name="delivery_method_helpText" id="delivery_method_helpText" type='text' class="form-control" placeholder="Help Text"></textarea>
							</div>
						</div>
						<div class="clearfix">
							<button type='button' class="btn btn-danger btn-sm float-right delete-delivery-method" >
								<i data-feather="trash-2"></i>
							</button>
						</div>
					</div>
				</div>
			</div>
		</div>
	</template>
	<template id="FraudRulesTemplate">		
		<div class="card mb-2">
			<div class="card-header bg-danger" data-toggle="collapse" href="#collapseFraudRule" role="button" aria-expanded="true" aria-controls="collapseFraudRule">
				<strong>&nbsp;</strong>
			</div>
		</div>
		<div id="collapseFraudRule" class="collapse" style="border:none; margin-bottom:none;">
			<div class="card-body">
				<div class="form-horizontal">
					<div class="form-group row">
						<label for='fraud_rule_enable_new' class='col-sm-3 col-form-label font-weight-bold'>Enable?</label>
						<div class='col-sm-9'>
							<select name="fraud_rule_enable_new" class="form-control">
								<option value="0" >No</option>
								<option value="1" >Yes</option>
							</select>
						</div>
					</div>

					<div class="form-group row">
						<label for='fraud_rule_cart_type_new' class='col-sm-3 col-form-label font-weight-bold'>Cart Type</label>
						<div class='col-sm-9'>
							<select name="fraud_rule_cart_type_new" class="form-control">
								<option value="normal" selected>Normal</option>
								<option value="topup">Topup</option>
								<option value="card2wallet">Card to wallet</option>
							</select>
						</div>
					</div>
                          <%
						   Set rsRulesColumns = Etn.execute("select * from "+GlobalParm.getParm("COMMONS_DB")+".fraud_rules_columns order by display_name ");

						   %>
					<div class="form-group row">
						<label for='fraud_rule_column_new' class='col-sm-3 col-form-label font-weight-bold'>Column Name</label>
						<div class='col-sm-9'>
							<select name="fraud_rule_column_new" class="form-control">
								<option value="">--</option>
								<% rsRulesColumns.moveFirst();
								while(rsRulesColumns.next()){
									out.write("<option value='"+rsRulesColumns.value("name")+"'>"+rsRulesColumns.value("display_name")+"</option>");
								}
								%>
							</select>
						</div>
					</div>

					<div class="form-group row">
						<label for='fraud_rule_day_new' class='col-sm-3 col-form-label font-weight-bold'>Period</label>
						<div class='col-sm-9'>
							<select name="fraud_rule_day_new" class="form-control">
								<option value="1" >Daily</option>
								<option value="7" >Weekly</option>
								<option value="30" >Monthly</option>
							</select>
						</div>
					</div>
					
					<div class="form-group row">
						<label for='fraud_rule_limit_new' class='col-sm-3 col-form-label font-weight-bold'>Limit</label>
						<div class='col-sm-9'>
							<input type='text' name="fraud_rule_limit_new" id="fraud_rule_limit_new" class="form-control"  size="10" value=""/>
						</div>
					</div>
					<div class="clearfix">
						<input id="fraud_rule_delete" name="fraud_rule_delete" type="hidden" value="0"/>
						<button type='button' class="btn btn-danger btn-sm float-right delete-fraud-rule" onclick="delete_fraud_rule();" >
							<i data-feather="trash-2"></i>
						</button>
					</div>
				</div>
			</div>
		</div>	
	</template>
	<template id="deliverySlotTemplate">
	 <div class="delivery-slot-row">
        <label for="start_hour">
            <select name="start_hour_TEMPLATE_LANG" class="form-control" style="font-size: 16px; padding: 10px; height: auto;width: 129px;">
                <%= generateHourOptions(null) %>
            </select>
        </label>
        <span>:</span>
        <label for="start_minutes">
            <select name="start_minutes_TEMPLATE_LANG" class="form-control" style="font-size: 16px; padding: 10px; height: auto;width: 129px;">
                <%= generateMinuteOptions(null) %>
            </select>
        </label>
        <span>-</span>
        <label for="end_hour">
            <select name="end_hour_TEMPLATE_LANG" class="form-control" style="font-size: 16px; padding: 10px; height: auto;width: 129px;">
                <%= generateHourOptions(null) %>
            </select>
        </label>
        <span>:</span>
        <label for="end_minutes">
            <select name="end_minutes_TEMPLATE_LANG" class="form-control" style="font-size: 16px; padding: 10px; height: auto;width: 129px;">
                <%= generateMinuteOptions(null) %>
            </select>
        </label>
        <button type='button' class="btn btn-danger btn-sm float-right delete-delivery-slot">
            <i data-feather="trash-2"></i>
        </button>
    </div>
	</template>

	<br>
	<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	<br>
</main>


<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>
<script type="text/javascript" src='<%=GlobalParm.getParm("URL_GEN_JS_URL")%>'></script>
<script>

	let typingTimer;
	$(document).ready(function() {
		if ("<%=errorMessage%>".length > 0) {
			bootNotifyError(decodeURIComponent("<%=escapeCoteValue(errorMessage)%>"));
			var url = new URL(window.location.href);
			url.searchParams.delete('errorMessage');
			window.history.replaceState({}, document.title, url.toString());
		}

		document.querySelectorAll('.removePill').forEach(function(element) {
			element.addEventListener('click', function(event) {
				event.preventDefault();
				var parentDiv = element.parentElement.parentElement;
				if (parentDiv) parentDiv.remove();
			});
		});

		document.querySelectorAll('input[name="delivery_method_excludedItem"]').forEach(function(input) {
			input.addEventListener('input', function(event) {
				var inputValue = event.target.value;

				var parentDiv = input.parentElement.parentElement;
				var siblingSelect = parentDiv.querySelector('select[name="delivery_method_excludedType"]');
				var deliveryMethod = parentDiv.querySelector('input[name="delivery_method_unique_id"]');
				var deliveryMethodSub = parentDiv.querySelector('input[name="delivery_method_unique_id_type"]');
				if (siblingSelect && inputValue.length>1) {
					var selectValue = siblingSelect.value;
					var deliveryMethodId = deliveryMethod.value;
					var deliveryMethodSubVal = deliveryMethodSub.value;

					clearTimeout(typingTimer);
					typingTimer = setTimeout(function() {
						$.ajax({
							url:"save_shop_parameters.jsp", type:"post", dataType:"json",
							data:{
								requestType: "searchData",
								selectValue:selectValue,
								inputValue:inputValue,
							},
						}).done(function (resp){
							if(resp.status==1){
								showAutocompleteList(resp.data,input,event,resp.data,true,selectValue,deliveryMethodId,deliveryMethodSubVal,true);
							}
						});
					}, 500);
				}
			});
		});

		document.querySelectorAll('input[name="payment_method_excludedItem"]').forEach(function(input) {
			input.addEventListener('input', function(event) {
				var inputValue = event.target.value;

				var parentDiv = input.parentElement.parentElement;
				var siblingSelect = parentDiv.querySelector('select[name="payment_method_excludedType"]');
				var paymentMethod = parentDiv.querySelector('input[name="payment_method_unique_id"]');
				if (siblingSelect && inputValue.length>1) {
					var selectValue = siblingSelect.value;
					var paymentMethodId = paymentMethod.value;

					clearTimeout(typingTimer);
					typingTimer = setTimeout(function() {
						$.ajax({
							url:"save_shop_parameters.jsp", type:"post", dataType:"json",
							data:{
								requestType: "searchData",
								selectValue:selectValue,
								inputValue:inputValue,
							},
						}).done(function (resp){
							if(resp.status==1){
								showAutocompleteList(resp.data,input,event,resp.data,true,selectValue,paymentMethodId);
							}
						});
					}, 500);
				}
			});
		});

	});

	function clearSiblingInput(select){
		let selectSiblingInput = select.closest('div').querySelector('input[name="payment_method_excludedItem"]');
		if(selectSiblingInput) selectSiblingInput.value="";
		else{
			selectSiblingInput = select.closest('div').querySelector('input[name="delivery_method_excludedItem"]');
			if(selectSiblingInput) selectSiblingInput.value="";
		}
	}

    document.addEventListener("DOMContentLoaded", function () {
    	const saveCollapseState = id => localStorage.setItem('openCollapseId', id);
		const restoreCollapseState = () => {
			const id = localStorage.getItem('openCollapseId');
			if (id){
				document.getElementById(id)?.classList.add('show');
				document.getElementById(id)?.parentElement.closest(".collapse")?.classList.add('show');
			}

		};
		restoreCollapseState();
		document.querySelectorAll('[data-toggle="collapse"]').forEach(btn => {
			btn.addEventListener('click', function () {
				const id = this.getAttribute('href').substring(1);
				setTimeout(() => {
					const div = document.getElementById(id);
					div.classList.contains('show') ? saveCollapseState(id) : localStorage.removeItem('openCollapseId');
				}, 400);
			});
		});
	});

	

</script>

<script type="text/javascript">
    window.URL_GEN_AJAX_URL = '<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>';

	jQuery(document).ready(function() {
		$('body').on('click','.delete-delivery-method',function(){
			$(this).closest('.card').remove();
		});

		$('body').on('click','.delete-delivery-slot',function(){
			$(this).closest('.delivery-slot-row').remove();
		});

		$('body').on('click','.delete-local-holiday',function(){
			$(this).closest('.form-group').remove();
		});

		$('body').on('change','.delivery-method',function(){
			let val = $(this).val();
			if(val == "home_delivery") 
				$(this).closest(".form-horizontal").find("[name='delivery_method_subType']").attr("disabled",false);
			else
				$(this).closest(".form-horizontal").find("[name='delivery_method_subType']").attr("disabled",true);
		});
		
		$('body').on('click','.add-delivery-method',function(){
			let len = $("#collapseDeliveryMethods").find(".collapse").length;
			let delivMethod = $($("#deliveryMethodsTemplate").html());
			delivMethod.find("input[name='delivery_method_order']").val(len+1);
			delivMethod.find(".card-header").attr("href","#collapseDeliveryMethod"+(len+1)).attr("aria-controls","collapseDeliveryMethod"+(len+1));
			delivMethod.find(".collapse").attr("id","collapseDeliveryMethod"+(len+1));
			$(delivMethod).insertBefore($(this)); 
			feather.replace();
		});
	  

		$('body').on('input','.deliv-method',function(){
			let val = $(this).val();
			if(val.length == 0 ) $(this).closest(".card").find(".card-header > strong").html(`&nbsp;`);
			else $(this).closest(".card").find(".card-header > strong").text(val.replaceAll("_"," ")) 
		});

		<% for(Language lang:langsList){ %>
			$(".lang<%=lang.getLanguageId()%>show").css("display", "table-cell");
		<% } %>

		var urlGenAjaxUrl = window.URL_GEN_AJAX_URL;
		$('.continue_shopping_url').each(function(){
			var urlInputRefOrSelector = $(this);
			var urlGenOptions = { showOpenType : false};
			var urlGen2 = etn.initUrlGenerator(urlInputRefOrSelector, urlGenAjaxUrl, urlGenOptions);			
		});


		onsave=function()
		{
			if($("#sb_platform_ios_str").is(':checked')) $("#sb_platform_ios").val('1');
			else $("#sb_platform_ios").val('0');

			if($("#sb_platform_android_str").is(':checked')) $("#sb_platform_android").val('1');
			else $("#sb_platform_android").val('0');

			$("#frm").submit();
		};

		addFraudRule = function(langId,rule_count) {

			var template = document.getElementById("FraudRulesTemplate").content.cloneNode(true);

			template.firstElementChild.classList.add("fraudRulesDiv_"+rule_count);
			var divs = document.getElementsByClassName('fraudRulesDiv_'+langId);
			
			document.getElementById("collapseFraudRules").querySelector(".form-horizontal").appendChild(template);
			feather.replace();
		}
        
		addSlot =  function(index,langid){
			var template = document.getElementById('deliverySlotTemplate').innerHTML;
			template = template.replace(/TEMPLATE_LANG/g, index + '_' + langid);
			var newSlot = document.createElement('div');
			newSlot.innerHTML = template;
			newSlot = newSlot.firstElementChild;
			var divId = 'time_input_' + index;
			var timeDiv = document.getElementById(divId);
			timeDiv.appendChild(newSlot);
			feather.replace();

		}

		delete_fraud_rule = function(row)
		{
			if(!confirm("Are you sure to delete the Fraud Rule?")) return false;
			$("#fraud_rule_delete_"+row).val("1");
			$("#frm").submit();
		}

        setRowOrder = function(method_type){

            $('#'+method_type+'_methods tbody tr').each(function(i,tr){
                $(tr).find('.'+method_type+'_method_order')
                .prop('readonly',false)
                .val(i+1)
                .prop('readonly',true);
            });
        };
		
		Sortable.create(document.querySelector('#payment_methods tbody'), {
			axis: 'y',
			forcePlaceholderSize: true,
			helper: function(event, element) {
				var clone = element.cloneNode(true);
				var origTdList = element.querySelectorAll('>td');
				var cloneTdList = clone.querySelectorAll('>td');

				for (var i = 0; i < cloneTdList.length; i++) {
				cloneTdList[i].style.width = origTdList[i].offsetWidth + 'px';
				}

				return clone;
			},
			onUpdate: function(event) {
				setRowOrder('payment');
			}
		});
	});

	function addHoliday(){
		var html = '<div class="form-group row" >'+
						'<label for="local_holiday" class="col-sm-3 col-form-label font-weight-bold">'+
							'<label for="holiday_name" class="font-weight-bold"> Holiday Name:' +
								'<input type="text" name="holiday_name" value=""  class="form-control">' +
							'</label>' +
						'</label>'+
						'<div class="col-sm-9">'+
							'<div class="holiday-row" >'+
								'<label for="start_date" class="font-weight-bold"> Start Date' +
									'<input type="date" name="start_date" value=""  class="form-control">' +
								'</label> ' +
								'<label for="end_date" class="font-weight-bold"> End Date' +
									'<input type="date" name="end_date" value=""  class="form-control">' +
								'</label> ' +
								'<button type="button" class="btn btn-danger btn-sm  delete-local-holiday" style="margin-left:15px;">'+
									'<i data-feather="trash-2"></i>'+
								'</button>'+
							'</div>'+
						'</div>'+
					'</div>';

		var timeDive = document.getElementById("holiday-row");
		timeDive.insertAdjacentHTML('beforeend', html);
		feather.replace();
	}
	

	function onChangeBrandName(input){
		var val = $(input).val();
		var properCase = [];
		$.each(val.split(" "),function(index, val) {
			val = val.trim();
			//if(val.length > 0){
				properCase.push(val.charAt(0).toUpperCase()
					+ val.substr(1));
			//}
		});
		var newVal = properCase.join(" ");
		// if(val.endS)
		$(input).val(newVal);
	};
	
</script>


</body>
</html>
