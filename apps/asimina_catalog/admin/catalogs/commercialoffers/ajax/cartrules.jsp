<%
  response.setCharacterEncoding("utf-8");
  request.setCharacterEncoding("utf-8");
%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>
<%@page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="java.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%@ include file="/admin/common.jsp" %>

<%!

    String buildDateFr(String date){

        if(date.length() > 0){
            
            String token[] = date.split(" ");
            String innerToken[] = token[0].split("/");
            return innerToken[2] + "/" + innerToken[1] + "/" + innerToken[0] + " " + token[1];
        }

        return "";
    }


%>

<%

    String action = parseNull(request.getParameter("action"));
    String STATUS_SUCCESS = "SUCCESS", STATUS_ERROR = "ERROR";
    String message = "";
    String status = STATUS_ERROR;
    StringBuffer data = new StringBuffer();
    String selectedsiteid = parseNull(getSelectedSiteId(session)); 

    if(action.equals("get_generated_cc")){

        String promotionId = parseNull(request.getParameter("promotion_id"));

        Set rs = Etn.execute("SELECT * FROM cart_promotion_coupon WHERE cp_id = " + escape.cote(promotionId));

        if(rs.rs.Rows > 0) data.append("<div class=\"container\"> <ul class=\"list-group\">");

        while(rs.next()){

            data.append("<li style=\"text-align: center;\" class=\"list-group-item\">");
            data.append(parseNull(rs.value("coupon_code")));
            data.append("</li>");
        }

        if(rs.rs.Rows > 0) data.append("</ul> </div>");

        out.write(data.toString());

    } else if(action.equals("order_cartrule")){

        try{

            String promoIds = parseNull(request.getParameter("promoIds"));
            String SeqOrder = parseNull(request.getParameter("seq_order"));

            String promoIdList[] = promoIds.split(",");
            String SqOrderFlag[] = SeqOrder.split(",");

            if( promoIdList.length == 0 ){
                    throw new Exception("");
            }

            String q = "";
            for(int i=0; i<promoIdList.length; i++){

                if(SqOrderFlag[i].equals("true"))
                    q = "UPDATE cart_promotion SET order_seq = " + (i+1) + ", version = version + 1 WHERE id = " + escape.cote(promoIdList[i]);
                else
                    q = "UPDATE cart_promotion SET order_seq = " + (i+1) + " WHERE id = " + escape.cote(promoIdList[i]);

                Etn.executeCmd(q);
            }

            status = STATUS_SUCCESS;
            message = "";

            if(data.length() == 0){
                data.append("\"\"");
            }

            response.setContentType("application/json");
            out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\",\"data\":"+data+"}");
        }
        catch(Exception ex){
                status = STATUS_ERROR;
        }

    } else if(action.equals("cart_rules")){

        LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
        feedbackDDValues.put("all","All Users");
        feedbackDDValues.put("logged","Logged-in Users");

        LinkedHashMap<String, String> couponCodeValues = new LinkedHashMap<String, String>();
        couponCodeValues.put("0","No");
        couponCodeValues.put("1","Yes");

        LinkedHashMap<String, String> ruleField = new LinkedHashMap<String, String>();
        ruleField.put("0","Not applying");
        ruleField.put("1","Applying");

        LinkedHashMap<String, String> ruleTypeValues = new LinkedHashMap<String, String>();
        ruleTypeValues.put("","No condition");
        ruleTypeValues.put("cart_attribute","Cart attribute");
        ruleTypeValues.put("cart_product","Product(s) found in the cart");

        LinkedHashMap<String, String> verifiedConditionValues = new LinkedHashMap<String, String>();
        verifiedConditionValues.put("delivery_method","Delivery method");
        verifiedConditionValues.put("payment_method","Payment method");
        verifiedConditionValues.put("total_quantity","Total quantity");
        verifiedConditionValues.put("total_amount","Total amount");

        LinkedHashMap<String, String> priceDiffAppliedValues = new LinkedHashMap<String, String>();
        priceDiffAppliedValues.put("fixed","\"-\" fixed amount of original price");
        priceDiffAppliedValues.put("percentage","% (-) of original price");

        LinkedHashMap<String, String> onValues = new LinkedHashMap<String, String>();
        onValues.put("cart_total","Cart total");
        onValues.put("shipping_fee","Shipping fees");
        onValues.put("product","Product");
        onValues.put("sku","SKU");

        LinkedHashMap<String, String> ruleConditionValues = new LinkedHashMap<String, String>();
        ruleConditionValues.put("is","Is");

        String id = parseNull(request.getParameter("id"));;

        Set rs = null;
        Set rsCoupon = null;
        Set rsElementsOn = null;

        if(id.length() > 0)
        {
            rs = Etn.execute("SELECT * FROM cart_promotion WHERE id =  " + escape.cote(id));
            rs.next();

            rsCoupon = Etn.execute("SELECT * FROM cart_promotion_coupon WHERE cp_id = " + escape.cote(id));
            if(rsCoupon != null) rsCoupon.next();

            rsElementsOn = Etn.execute("SELECT * FROM cart_promotion_on_elements WHERE cart_promo_id = " + escape.cote(id));
        }

        String startDate = getRsValue(rs, "start_date");
        String endDate = getRsValue(rs, "end_date");

        if(startDate.length() > 0) startDate = buildDateFr(startDate);
        if(endDate.length() > 0) endDate = buildDateFr(endDate);

%>

        <!-- cart rule -->
        <form name='cartrulefrm' id='cartrulefrm' method='post' action='savepromotion.jsp' >

        <%
            if(id.length() > 0){
        %>
                <input type='hidden' name='id' id="promotion_id" value='<%=getValue(rs, "id")%>' />
        <%
            }
        %>

            <!-- Global information -->
            <div class="card mb-2">
                <div class="card-header bg-secondary" data-toggle="collapse" href="#general_info_coupon" role="button" aria-expanded="true" 
                    aria-controls="general_info_coupon">
                    <strong>General information</strong>
                </div>
                <div class="collapse show p-3" id="general_info_coupon">
                    <div class="card-body">
                        <div class="form-group row ">
                            <label for="name" class='col-md-3 control-label is-required'>Cart rule name:</label>
                            <div class='col-md-9'>
                                <input type="text" id="name" name="name" value="<%=getRsValue(rs, "name")%>" class="form-control" />
                                <div class="invalid-feedback">Rule name is mandatory.</div>
                            </div>
                        </div>
                        <div class="form-group row ">
                            <label for="description" class='col-md-3 control-label'>Description: </label>
                            <div class='col-md-9'>
                                <textarea id="description" name="description" class="form-control"><%=getRsValue(rs, "description")%></textarea>
                            </div>
                        </div>
                        <div class="form-group row ">
                            <label for="visible_to" class='col-md-3 control-label'>Applicable to: </label>
                            <div class='col-md-9'>
                                <%
                                        ArrayList arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "visible_to"));
                                %>
                                <%=addSelectControl("visible_to", "visible_to", feedbackDDValues, arr, "custom-select", "", false)%>
                            </div>
                        </div>
                        <div class="form-group row ">
                            <label for="start_date" class='col-md-3 control-label'>Start / End: </label>
                            <div class='col-md-9 input-group'>
                                <input type="text" id="start_date" placeholder="Start date" name="start_date" value="<%=startDate%>" class="form-control" />
                                <input type="text" id="end_date" placeholder="End date" name="end_date" value="<%=endDate%>" class="form-control" />
                                <div class="input-group-append">
                                    <button type="button" name="ignore" class="btn btn-warning pull-right" onclick="$('#start_date').val('');$('#end_date').val('');"  style="max-height:35px"><span class="oi oi-delete" aria-hidden="true"></span></button>&nbsp;
                                </div>
                            </div>
                            
                        </div>
                    </div>
                </div>
            </div>
            <!-- /Global information -->
            
            <!-- Coupon -->
            <div class="card mb-2">
                <div class="card-header bg-secondary" data-toggle="collapse" href="#auto_generate_coupon" role="button" aria-expanded="true" 
                    aria-controls="auto_generate_coupon">
                    <strong>Coupon</strong>
                </div>
                <div class="collapse show p-3" id="auto_generate_coupon">
                    <div class="card-body">
                        <div class="form-group row ">
                            <label for="auto_generate_cc" class='col-md-3 control-label'>Auto-generated coupon: </label>
                            <div class='col-md-9'>
                                <%
                                    String script = " onchange='change_ag_cc(this)' ";
                                    arr = new ArrayList<String>();
                                    arr.add(getRsValue(rs, "auto_generate_cc"));
                                    if(rsCoupon != null && rsCoupon.rs.Rows > 0) script = " disabled ";
                                %>
                                <%=addSelectControl("auto_generate_cc", "auto_generate_cc", couponCodeValues, arr, "custom-select", script, false)%>
                                <%
                                    if(rsCoupon != null && rsCoupon.rs.Rows > 0) {
                                %>
                                        <input type="hidden" name="auto_generate_cc" value="<%= getRsValue(rs, "auto_generate_cc")%>" />
                                <%
                                    }
                                %>
                            </div>
                        </div>
                        <div class="form-group row ">
                            <label for="coupon_code" class='col-md-3 control-label'>Coupon code: </label>
                            <div class='col-md-9'>
                                <input type="text" id="coupon_code" name="coupon_code" class="form-control" <% if(getRsValue(rs, "auto_generate_cc").equals("1") ){ %> readonly="true" <% } else if(getRsValue(rs, "auto_generate_cc").equals("0") ) { %> value="<%=getRsValue(rsCoupon, "coupon_code")%>" <% } if(rsCoupon != null && rsCoupon.rs.Rows > 0){ %> readonly="true" <%} %> />
                            </div>
                        </div>
                        <div class="form-group row ">
                            <label for="uses_per_coupon" class='col-md-3 control-label'>Uses per: </label>
                            <div class='col-md-9 input-group'>
                                <input placeholder="number" type="text" id="uses_per_coupon" name="uses_per_coupon" value="<%=getRsValue(rs, "uses_per_coupon")%>" class="form-control" <% if(rsCoupon != null && rsCoupon.rs.Rows > 0){ %> readonly="true" <% } %> />
                                <input placeholder="customer" type="text" id="uses_per_customer" name="uses_per_customer" value="<%=getRsValue(rs, "uses_per_customer")%>" class="form-control" <% if(rsCoupon != null && rsCoupon.rs.Rows > 0){ %> readonly="true" <% } %> />
                            </div>
                        </div>
                        <div class="form-group row " <% if(getRsValue(rs, "auto_generate_cc").equals("0") || getRsValue(rs, "auto_generate_cc").length() == 0){ %> style="display:none;" <% } %>>
                            <label for="coupon_quantity" class='col-md-3 control-label'>Coupon quantity: </label>
                            <div class='col-md-9'>
                                <input type="text" id="coupon_quantity" name="coupon_quantity" value="<%=getRsValue(rs, "coupon_quantity")%>" class="form-control" <% if(rsCoupon != null && rsCoupon.rs.Rows > 0){ %> readonly="true" <% } %> />
                            </div>
                        </div>
                        <div class="form-group row " <% if(getRsValue(rs, "auto_generate_cc").equals("0") || getRsValue(rs, "auto_generate_cc").length() == 0){ %> style="display:none;" <% } %>>
                            <label for="coupon_code_length" class='col-md-3 control-label'>Coupon code length: </label>
                            <div class='col-md-9'>
                                <input type="text" id="coupon_code_length" name="coupon_code_length" value="<%=getRsValue(rs, "cc_length")%>" class="form-control" <% if(rsCoupon != null && rsCoupon.rs.Rows > 0){ %> readonly="true" <% } %> />
                            </div>
                        </div>
                        <div class="form-group row " <% if(getRsValue(rs, "auto_generate_cc").equals("0") || getRsValue(rs, "auto_generate_cc").length() == 0){ %> style="display:none;" <% } %>>
                            <label for="coupon_code_prefix" class='col-md-3 control-label'>Coupon code prefix: </label>
                            <div class='col-md-9'>
                                <input type="text" id="coupon_code_prefix" name="coupon_code_prefix" value="<%=getRsValue(rs, "cc_prefix")%>" class="form-control" <% if(rsCoupon != null && rsCoupon.rs.Rows > 0){ %> readonly="true" <% } %> />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- /Coupon -->
            
            <!-- Rules -->
            <div class="card mb-2">
                <div class="card-header bg-secondary" data-toggle="collapse" href="#rule_coupon" role="button" aria-expanded="true" aria-controls="rule_coupon">
                    <strong>Rules</strong>
                </div>
                <div class="collapse show p-3" id="rule_coupon">
                    <div class="card-body">
                        <div class="form-group row ">
                            <label for="rule_type" class='col-md-3 control-label'>Applying if: </label>
                            <div class='col-md-9'>
                                <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "rule_type"));                                
                                %>
                                <%=addSelectControl("rule_type", "rule_type", ruleTypeValues, arr, "custom-select", "onchange=change_rule_if(this,'cartrulefrm')", false)%>
                            </div>
                        </div>
                        <div class="form-group row ">
                            <label for="verify_condition" class='col-md-3 control-label'>Verifies condition:  </label>
                            <div class='col-md-9 input-group-append'>
                                <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "verify_condition"));

                                        if(getRsValue(rs, "rule_type").equals("cart_product")){
                                            
                                            verifiedConditionValues.clear();
                                            verifiedConditionValues.put("sku","SKU");
                                            verifiedConditionValues.put("product","Product");
                                            verifiedConditionValues.put("product_type","Product Type");
                                            verifiedConditionValues.put("catalog","Catalog");
                                            verifiedConditionValues.put("manufacturer","Manufacturer");
                                            verifiedConditionValues.put("tag","Tag");

                                        } else if(getRsValue(rs, "rule_type").equals("cart_attribute")){

                                            verifiedConditionValues.clear();
                                            verifiedConditionValues.put("delivery_method","Delivery method");
                                            verifiedConditionValues.put("payment_method","Payment method");
                                            verifiedConditionValues.put("total_quantity","Total quantity");
                                            verifiedConditionValues.put("total_amount","Total amount");
                                        }

                                        if(getRsValue(rs, "verify_condition").equals("total_quantity") || getRsValue(rs, "verify_condition").equals("total_amount")){

                                            ruleConditionValues.put("greater_than", "Greater than");
                                            ruleConditionValues.put("less_than", "Less than");
                                        }
                                %>
                                <%=addSelectControl("verify_condition", "verify_condition", verifiedConditionValues, arr, "custom-select", "onchange='rule_method_condition(this)'", false)%>

                                <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "rule_condition"));
                                        String dropdownClass = "custom-select ";

                                        if(getRsValue(rs, "rule_type").equals("cart_product")) dropdownClass += "d-none";

                                %> 
                                <%=addSelectControl("rule_condition", "rule_condition", ruleConditionValues, arr, dropdownClass, "", false)%>

                                <%
                                    if(id.length() == 0){
                                %>
                                        <div class="position-relative w-100 <% if(getRsValue(rs, "rule_type").equals("cart_attribute")){ %>d-block<%} else { %>d-none<% } %>">
                                            <input type="text" class="form-control rule_value_cart_attr" <% if(getRsValue(rs, "rule_type").equals("cart_attribute")){ %> style="display:block" id="rule_condition_value" value="<%= getRsValue(rs, "rule_condition_value")%>" <%} else { %> style="display:none" <% } %> <% if(getRsValue(rs, "verify_condition").equals("total_quantity") || getRsValue(rs, "verify_condition").equals("total_amount")){ %> name="rule_condition_value" <% } %> />
                                        </div>
                                        <div class="position-relative w-100 <% if(getRsValue(rs, "rule_type").equals("cart_product")){ System.out.println("rule_type===>"+getRsValue(rs, "rule_type"));%>d-block<%} else { %>d-none<% } %>">
                                            <input type="text" class="form-control rule_value_prod_cart rule_element_value"  <% if(getRsValue(rs, "rule_type").equals("cart_product")){ %> style="display:block" id="rule_condition_value" value="<%= getRsValue(rs, "rule_condition_value")%>" <%} else { %> style="display:none" <% } %> />
                                        </div>

                                <%
                                        if(getRsValue(rs, "verify_condition").equals("delivery_method") || getRsValue(rs, "verify_condition").equals("payment_method")){
                                %>
                                            <input type="hidden" id="rule_condition_key" name="rule_condition_value" value='<%= getRsValue(rs, "rule_condition_value")%>' />
                                <%
                                        }
                                    }


                            if( rs != null ) rs.moveFirst();
                            while(rs != null && rs.next()){

                                String label = getRsValue(rs, "rule_condition_value");
                                String type = getRsValue(rs, "verify_condition");
                                String value = getRsValue(rs, "rule_condition_value");

                                Set rsValue = null;

                                if(type.equals("product")){
                                    rsValue = Etn.execute("SELECT lang_1_name FROM products WHERE id = "+escape.cote(value));
                                    if(rsValue.next()){
                                        label = rsValue.value(0);
                                    }
                                }
                                else if(type.equals("catalog")){
                                    rsValue = Etn.execute("SELECT name FROM catalogs WHERE id = "+escape.cote(value));
                                    if(rsValue.next()){
                                        label = rsValue.value(0);
                                    }
                                }
                                else if(type.equals("product_type")){
                                    rsValue = Etn.execute("SELECT name FROM product_types WHERE value = "+escape.cote(value));
                                    if(rsValue.next()){
                                        label = rsValue.value(0);
                                    }
                                }
                                else if(type.equals("sku")){
                                    rsValue = Etn.execute("SELECT sku FROM product_variants WHERE sku = "+escape.cote(value));
                                    if(rsValue.next()){
                                        label = rsValue.value(0);
                                    }
                                }
                                else if(type.equals("delivery_method")){
                                    
                                    rsValue = Etn.execute("SELECT displayName FROM delivery_methods WHERE site_id = " + escape.cote(selectedsiteid) + " and method = "+escape.cote(value));

                                    if(rsValue.next()){
                                        label = rsValue.value(0);
                                    }
                                }
                                else if(type.equals("payment_method")){
                                    
                                    rsValue = Etn.execute("SELECT displayName FROM payment_methods WHERE site_id = " + escape.cote(selectedsiteid) + " and method = "+escape.cote(value));
                                    
                                    if(rsValue.next()){
                                        label = rsValue.value(0);
                                    }
                                }

                            %>
                                <div class="position-relative w-100 <% if(getRsValue(rs, "rule_type").equals("cart_attribute")){ %>d-block<%} else { %>d-none<% } %>">
                                    <input type="text" class="form-control rule_value_cart_attr" <% if(getRsValue(rs, "rule_type").equals("cart_attribute")){ %> style="display:block" id="rule_condition_value" value="<%= escapeCoteValue(label)%>" <%} else { %> style="display:none" <% } %> />
                                </div>
                                <div class="position-relative w-100 <% if(getRsValue(rs, "rule_type").equals("cart_product")){ %>d-block<%} else { %>d-none<% } %>">
                                    <input type="text" class="form-control rule_value_prod_cart rule_element_value"  <% if(getRsValue(rs, "rule_type").equals("cart_product")){ %> style="display:block" id="rule_condition_value" value="<%= escapeCoteValue(label)%>" <%} else { %> style="display:none" <% } %> />
                                </div>
                                <input type="hidden" id="rule_condition_key" name="rule_condition_value" value='<%= escapeCoteValue(value)%>' />
                            <%
                            }
                            %>

                            </div>
                        </div>


                        <div class="form-group row ">
                            <label for="discount_type" class='col-md-3 control-label is-required'>Price diff applied:  </label>
                            <div class='col-md-9 input-group'>
                                <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "discount_type"));
                                %>
                                <%=addSelectControl("discount_type", "discount_type", priceDiffAppliedValues, arr, "custom-select", "", false)%>
                                <input type="text" id="discount_value" name="discount_value" value="<%=getRsValue(rs, "discount_value")%>" class="form-control" />
                                <div class="invalid-feedback">Amount is mandatory.</div>
                            </div>
                        </div>

                        <div class="form-group row ">
                            <label for="rule_field" class='col-md-3 control-label'>Applying other rules:</label>
                            <div class='col-md-9'>
                                <%
                                        arr = new ArrayList<String>();
                                        arr.add(getRsValue(rs, "rule_field"));
                                %>
                                <%=addSelectControl("rule_field", "rule_field", ruleField, arr, "custom-select", "", false)%>
                            </div>
                        </div>

                        <div class="form-group row ">
                            <label for="slct_element_on" class='col-md-3 control-label is-required'>On: </label>
								<div class='col-md-9 input-group-append'>
									<%
											arr = new ArrayList<String>();
											String eon = getRsValue(rs, "element_on");
											if(eon.equals("list")) eon = "product";
											if(null != rsElementsOn)
											{
												rsElementsOn.moveFirst();
												if(rsElementsOn.next())
												{
													eon = rsElementsOn.value("element_on");
												}
											}
											
											arr.add(eon);
									%>
									<%=addSelectControl("slct_element_on", "slct_element_on", onValues, arr, "custom-select", "onchange=checkElementOn()", false)%>
									<div class="position-relative w-100">
										<input id="slct_element_on_label" type="text" class="form-control" />
									</div>
									<button type="button" class="btn btn-primary" onclick="add_selected_element()">Add</button>
								</div>
						</div>
						<div class="form-group row ">
							<div class="col-md-3"> </div>
							<div id="elements_on_container" class="col-md-9 row">
							<%
								if(null != rsElementsOn){
									rsElementsOn.moveFirst();
									while(rsElementsOn.next()){

										String label = "";
										String type = parseNull(rsElementsOn.value("element_on"));
										String value = parseNull(rsElementsOn.value("element_on_value"));

										if(type.equals("product")){
											System.out.println("select lang_1_name from products where id = "+escape.cote(value));
											Set rsValue = Etn.execute("select lang_1_name from products where id = "+escape.cote(value));
											if(rsValue.next()){
												label = rsValue.value(0);
											}
										}
										else if(type.equals("sku")){
											label = value;
										}
										else
										{
											label = "";
											value = "";
										}
										
							%>
										<div style="margin-left: 20px; margin-top: 10px;">
											<button class="btn btn-pill btn-block btn-secondary" type="button">
												<strong onclick="delete_selected_on(this)" style="color:#f16e00; cursor: pointer;">X</strong>
												<%= escapeCoteValue(label)%>
											</button>
											<input type="hidden" name="element_on" value='<%= escapeCoteValue(type)%>' />
											<input type="hidden" name="element_on_value" value='<%= escapeCoteValue(value)%>' />

										</div>
							<%
									}//while
								}//if 
							%>
							</div>
						</div>
                    </div>
                </div>
            </div>
            <!-- /Rules -->
        </form>
        <!-- /Cart rules -->
<%
    } else if(action.equals("copyCartRulePromotion")){

        String promotionId = parseNull(request.getParameter("promotionId"));
        String promotionName = parseNull(request.getParameter("promotionNewName"));
        String query = "";
        status = STATUS_SUCCESS;

        try{

            query = "INSERT INTO cart_promotion (site_id, version, created_by, description, visible_to, start_date, end_date, auto_generate_cc, uses_per_coupon, uses_per_customer, coupon_quantity, cc_length, cc_prefix, rule_field, rule_type, verify_condition, rule_condition, rule_condition_value, discount_type, discount_value, element_on) SELECT site_id, version, "+escape.cote(""+Etn.getId())+", description, visible_to, start_date, end_date, auto_generate_cc, uses_per_coupon, uses_per_customer, coupon_quantity, cc_length, cc_prefix, rule_field, rule_type, verify_condition, rule_condition, rule_condition_value, discount_type, discount_value, element_on FROM cart_promotion WHERE id = " + escape.cote(promotionId);

            int rowId = Etn.executeCmd(query);

            if(rowId > 0){

                query = "UPDATE cart_promotion SET name = " + escape.cote(promotionName) + " WHERE id = " + escape.cote(rowId+"");
                Etn.executeCmd(query);

            }

            query = "INSERT INTO cart_promotion_coupon (cp_id, coupon_code) SELECT '" + rowId + "', coupon_code FROM cart_promotion_coupon WHERE cp_id = " + escape.cote(promotionId);

            Etn.executeCmd(query);

        } catch(Exception e){

            status = STATUS_ERROR;
            message = e.getMessage();
        }

        out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\"}");

    }
%>
