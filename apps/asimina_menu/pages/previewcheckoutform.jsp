<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.Base64, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, java.net.*, java.util.*"%>
<%@ include file="common.jsp"%>
<%@ include file="lib_msg.jsp"%>

<!doctype html>
<html>

	<%
		String siteid = parseNull(request.getParameter("site_id"));
		String isProd = parseNull(request.getParameter("isProd"));
		String dbMetaDataHtmlElement = "";
		String dbElementHtml = "";
	    String checkoutMessage = "";
	    String checkoutOrderRefLabel = "Order Ref.";
	    String checkoutOrderDateLabel = "Order Date";
	    String checkoutTotalAmountLabel = "Total Amount";
	    String checkoutShowOrderDetail = "";
	    String dbName = "";
	    int dbElementCounter = 0;
	    int dbElementOptionCounter = 0;
	    List<Object> list = null;
	    Iterator itr = null;

		String sitename = "";
		Set rssite = Etn.execute("select * from sites where id = " + escape.cote(siteid));
	    	if(rssite.next()) sitename = rssite.value("name");

	    if(isProd.equalsIgnoreCase("1")) dbName = com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".";

		Set checkoutFormSettingRs = Etn.execute("SELECT * FROM " + dbName + "co_form_settings WHERE site_id = "+escape.cote(siteid));

		List<String> dbElementList = new ArrayList<String>();

		if(checkoutFormSettingRs.next())
		{
			
			checkoutShowOrderDetail = parseNull(checkoutFormSettingRs.value("co_show_order_detail"));
			Gson gson = new Gson();
			String json = parseNull(checkoutFormSettingRs.value("co_field_json"));
			String optionJson = "";
//		    json = "[{\"label_id\":\"element_label_1\",\"label\":\"Label\"},{\"label_id\":\"element_label_2\",\"label\":\"fn\"}]";
	        Type stringObjectMap = new TypeToken<List<Object>>(){}.getType();
    	    list = gson.fromJson(json, stringObjectMap);
		    itr = list.iterator();
		    
		    String dbLabelId = "";
		    String dbLabelName = "";
		    String dbLabelMetaDataName = "";
		    String dbElementName = "";
		    String dbElementDisplayName = "";
		    String dbElementId = "";
		    String dbLabelFontWeight = "";
		    String dbLabelFontSize = "";
		    String dbLabelFontColor = "";
		    String dbElementPlaceholder = "";
		    String dbElementRequired = "";
		    String dbElementShowReceipt = "";
		    String dbElementRequiredHtml = "";
		    String dbElementRequiredTag = "";
		    String dbElementShowReceiptTag = "";
		    String dbElementType = "";
		    String deleteSpanElement = "";
		    String elementOnClickTag = "";


		    checkoutMessage = parseNull(checkoutFormSettingRs.value("co_msg_receipt"));
		    checkoutTotalAmountLabel = parseNull(checkoutFormSettingRs.value("co_total_amount_label"));
		    checkoutOrderRefLabel = parseNull(checkoutFormSettingRs.value("co_order_ref_label"));
		    checkoutOrderDateLabel = parseNull(checkoutFormSettingRs.value("co_order_date_label"));

			if(checkoutTotalAmountLabel.length() == 0) checkoutTotalAmountLabel = "Total Amount";
			if(checkoutOrderRefLabel.length() == 0) checkoutOrderRefLabel = "Order Ref.";
			if(checkoutOrderDateLabel.length() == 0) checkoutOrderDateLabel = "Order Date";

		    	while(itr.hasNext()) 
			{
					
				dbElementCounter++;
				Map<String, Object> map = (Map) itr.next();

//				System.out.println(map.get("label_id"));
//				System.out.println(map.get("label"));

				dbLabelId = parseNull(map.get("label_id"));
				dbLabelMetaDataName = parseNull(map.get("label_name"));
				dbLabelName = parseNull(map.get("label"));
				dbElementName = parseNull(map.get("name"));
				dbElementDisplayName = parseNull(map.get("display_name"));
				dbElementId = parseNull(map.get("id"));
				dbLabelFontWeight = parseNull(map.get("font_weight"));
				dbLabelFontSize = parseNull(map.get("font_size"));
				dbLabelFontColor = parseNull(map.get("color"));
				dbElementPlaceholder = parseNull(map.get("placeholder"));
				dbElementRequired = parseNull(map.get("required"));
				dbElementShowReceipt = parseNull(map.get("show_receipt"));
				dbElementType = parseNull(map.get("type"));
				dbElementRequiredHtml = "";
				dbElementRequiredTag = "";
				dbElementShowReceiptTag = "";
				deleteSpanElement = "";
				elementOnClickTag = "";
				optionJson = "";
				
				if(null != map.get("options")){
					
					dbElementOptionCounter = 0;
					Map<String, String> mapOptions = (Map) map.get("options");

					if(dbElementType.equalsIgnoreCase("select")){

						for (Map.Entry<String, String> entry : mapOptions.entrySet()) {
							optionJson += " <option id=\"dropdown_option_" + dbElementCounter + "_" + dbElementOptionCounter + "\" value=\"" + escapeCoteValue(entry.getKey()) + "\"> " + entry.getValue() + " </option> ";
							dbElementOptionCounter++;						
						}

					} else if(dbElementType.equalsIgnoreCase("radio") || dbElementType.equalsIgnoreCase("checkbox")){

						for (Map.Entry<String, String> entry : mapOptions.entrySet()) {
							optionJson += "<input type=\"" + dbElementType + "\" name=\"dropdown_option_" + dbElementCounter + "_" + dbElementOptionCounter + "\" id=\"dropdown_option_" + dbElementCounter + "_" + dbElementOptionCounter + "\" value=\"" + escapeCoteValue(entry.getKey()) + "\" /> <span> " + entry.getValue() + " </span><br/>";
							dbElementOptionCounter++;						
						}

					}

				}		

				if(dbElementRequired.equalsIgnoreCase("required")){
				
					dbElementRequiredHtml = " <span style=\"color: red;\">*</span>";
					dbElementRequiredTag = "required=\"" + dbElementRequired + "\"";
				} 

				if(dbElementShowReceipt.equalsIgnoreCase("show_receipt")){
				
					dbElementShowReceiptTag = "show_receipt=\"" + dbElementShowReceipt + "\"";
				} 
				

				if(dbLabelMetaDataName.length() == 0){

					if(dbElementType.equalsIgnoreCase("text") || dbElementType.equalsIgnoreCase("email") || dbElementType.equalsIgnoreCase("tel")){

		 				dbElementHtml += "<div class=\"o-form-group o-dropped_element\"> <div class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12\" > <div class=\"o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element\" style=\"float: right;\"> " + deleteSpanElement + " </div> <div class=\"o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11\"> <p id=\"" + dbLabelId + "\" class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label\" style=\"text-align: left; padding: 2px; cursor: pointer; font-weight: " + dbLabelFontWeight + "; font-size: " + dbLabelFontSize + "; color: " + dbLabelFontColor + ";\" " + elementOnClickTag + "> " + dbLabelName + dbElementRequiredHtml + " </p> <p> <input id=\"" + dbElementId + "\" class=\"o-form-control\" type=\"text\" name=\"" + dbElementName + "\" placeholder=\"" + dbElementPlaceholder + "\"" + dbElementRequiredTag + dbElementShowReceiptTag + " autocomplete=\"false\" /> </p> </div>  </div> </div>";
					
					}else if(dbElementType.equalsIgnoreCase("select")){

						dbElementHtml += "<div class=\"o-form-group o-dropped_element\"> <div class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12\" > <div class=\"o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element\" style=\"float: right;\"> " + deleteSpanElement + " </div> <div class=\"o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11\"> <p id=\"" + dbLabelId + "\" class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label\" style=\"text-align: left; padding: 2px; cursor: pointer; font-weight: " + dbLabelFontWeight + "; font-size: " + dbLabelFontSize + "; color: " + dbLabelFontColor + ";\" " + elementOnClickTag + "> " + dbLabelName + dbElementRequiredHtml + " </p> <p style=\"text-align: left;\" ><select name=\"" + dbElementName +"\" "+ dbElementRequiredTag +" "+ dbElementShowReceiptTag + " class=\"o-form-control select\">" + optionJson + "</select></p></div> </div> </div>";

					} else if(dbElementType.equalsIgnoreCase("radio") || dbElementType.equalsIgnoreCase("checkbox")){

						dbElementHtml += "<div class=\"o-form-group o-dropped_element\"> <div class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12\" > <div class=\"o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element\" style=\"float: right;\"> " + deleteSpanElement + " </div> <div class=\"o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11\"> <p id=\"" + dbLabelId + "\" class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label\" style=\"text-align: left; padding: 2px; cursor: pointer; font-weight: " + dbLabelFontWeight + "; font-size: " + dbLabelFontSize + "; color: " + dbLabelFontColor + ";\" " + elementOnClickTag + "> " + dbLabelName + dbElementRequiredHtml + " </p> <p style=\"text-align: left;\" ><span type=\"" + dbElementType + "\" name=\"" + dbElementName +"\" "+ dbElementRequiredTag +" "+ dbElementShowReceiptTag + " class=\"" + dbElementType + "\">" + optionJson + "</span> </p></div> </div> </div>";
					}

	 				dbElementList.add(dbElementName);

				} else if(dbLabelMetaDataName.equalsIgnoreCase("label")){
					
					dbElementHtml += "<div class=\"o-form-group o-dropped_element\"> <div class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12\" > <div class=\"o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element\" style=\"float: right;\"> " + deleteSpanElement + " </div> <div class=\"o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11\"> <p id=\"" + dbLabelId + "\" name=\"" + dbLabelMetaDataName + "\" class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label labelElement\" style=\"text-align: left; padding: 2px; cursor: pointer; font-weight: " + dbLabelFontWeight + "; font-size: " + dbLabelFontSize + "; color: " + dbLabelFontColor + ";\" " + elementOnClickTag + "> " + dbLabelName + " </p> </div>  </div> </div>";
				} else if(dbLabelMetaDataName.equalsIgnoreCase("hr")){
					
					dbElementHtml += "<div class=\"o-form-group o-dropped_element\"> <div class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12\" > <div class=\"o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element\" style=\"float: right;\"> " + deleteSpanElement + " </div> <div class=\"o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11\"> <p id=\"" + dbLabelId + "\" name=\"" + dbLabelMetaDataName + "\" class=\"o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label hrElement\" style=\"text-align: left; padding: 2px; cursor: pointer;\"> <hr style=\"border-width: 1px; border-style: inset; clear: both;\" /> </p> </div>  </div> </div>";
				} 
		    }
    	}

    	dbElementHtml = dbElementHtml.replaceAll("'","\\\\'");
	%>

<head>
	<title>Checkout Form</title>
	<meta charset="UTF-8"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<link rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap__portal__.css">
	<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>

	

</head>
<body >
	
	<div class="o-page etn-orange-portal--">		
		<main id="mainFormDiv" class="o-container">
				<div class="o-container-fluid">
					<div style='margin-bottom:20px; margin-top:20px;'>
					<center>
					<%if("1".equals(isProd)){%>
						<h2 style="color:red">Prod Site : <%=sitename%></h2>
					<%}else{%>
						<h2>Test Site : <%=sitename%></h2>
					<%}%>
					</center>
					</div>
					<div class="o-row" id="editorRow">
						<div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12">
							<div class="o-form-horizontal">
								<%
									if(checkoutFormSettingRs.rs.Rows > 0 && parseNull(checkoutFormSettingRs.value("co_field_json")).length() > 2){
								%>

										<div class="o-row">
											<div style='text-align:center; background-color:#eee;margin-bottom:20px;'>
												<label>
													This is what your customers will see on checkout screen
												</label>
											</div>
											<div class="o-form-group" style="margin-left: auto; margin-right: auto;">										
												<form enctype="application/x-www-form-urlencoded" id="checkoutform" method="post" name="checkoutform" class="form_template_class" portalgenericform="" autocomplete="off">
													<div class="o-col-xs-10 o-col-sm-10 o-col-md-10 o-col-lg-10" id="form_template">
														<%=dbElementHtml%>
													</div>
												</form>
											</div>
										</div>
								<%
									}
								%>

								<div id="checkoutform_message" class="o-row">
									<div style='text-align:center; background-color:#eee; margin-top:30px;margin-bottom:20px;'>
										<label>
											This is what your customers will see as the receipt
										</label>
									</div>
									<div class="o-col-xs-10 o-col-sm-10 o-col-md-10 o-col-lg-10" > 
					                    <strong style="margin-bottom: 20px; display: inline-block; "><img src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/img/green-circle-check.png" alt="" style="display:inline-black;margin-right:20px;">
					                    <span><%=checkoutMessage%></span></strong>
                                        <p><%=libelle_msg(Etn, request, "Un mail incluant les informations de cette page et une facture vous a été envoyé à l'adresse xxxx@xxxx.xxxx")%></p>

						                <hr width="99%" size="1" color="grey" style="border-width: 1px; border-style: inset; clear: both;">
										<div class="o-col-xs-12">
											<strong style="font-weight: bold;font-size: 20px;"><%=libelle_msg(Etn, request, "Votre commande")%></strong>
										</div>
										
										<div class="o-col-xs-7">											
					                        <div style="font-size: 16px; margin-left: 5%;">
					                            <strong><%=checkoutOrderRefLabel%> : <span style="color:#f4791f; float:right;">xxxx</span></strong>
					                            <br>
					                            <strong><%=checkoutOrderDateLabel%> :</strong><span style="float:right;">xx/xx/xxxx xx:xx</span>
					                            <br>
					                            <strong><%=checkoutTotalAmountLabel%> :</strong><span style="float:right;">xxxx</span>
					                            <br>
					                            <%
					                            	itr = list.iterator();
					                                String dbElementShowReceipt = "";

					                                while(itr.hasNext()) {

					                                    Map<String, Object> map = (Map) itr.next();
					                                    dbElementShowReceipt = parseNull(map.get("show_receipt"));
					            
					                                    if(dbElementShowReceipt.equalsIgnoreCase("show_receipt")){
					                            %>
					                                        <strong><%=parseNull(map.get("label").toString())%> :</strong><span style="float:right;">xxxx</span>
					                                        <br/>
					                            <%
					                                    }
					                                }
					                            
					                            %>
					                        </div>
										</div>
									</div> 
								</div>

		                        <%
		                            if(checkoutShowOrderDetail.equalsIgnoreCase("true")){
		                        %>

		                            <div style="margin-top: 30px;">
		                                <strong style="font-weight: bold;font-size: 20px;">Order Details</strong>
		                                    <table class="o-table o-table-hover">
		                                        <thead>
		                                            <tr>
		                                                <th style="padding-left: 0;">Name</th>
		                                                <th>Qty</th>
		                                                <th>Price</th>
		                                                <th>Service Date</th>
		                                                <th>Service Time</th>
		                                            </tr>
		                                        </thead> 
	                                            <tr>
	                                                <td>xxxx</td>
	                                                <td>xx</td>
	                                                <td>xxxx</td>
	                                                <td>xx-xx-xxxx</td>
	                                                <td>xx:xx</td>
	                                            </tr>
	                                            <tr>
	                                                <td>xxxx</td>
	                                                <td>xx</td>
	                                                <td>xxxx</td>
	                                                <td>xx-xx-xxxx</td>
	                                                <td>xx:xx</td>
	                                            </tr>
		                                    </table>
		                            </div>
		                        <%
		                            }
		                        %>

							</div>
						</div>
					</div>
				</div>
			</main>


	</div>

</body>
</html>