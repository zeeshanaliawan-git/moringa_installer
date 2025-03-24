<%@ page import="org.json.JSONObject" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="json/application; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ include file="../common.jsp" %>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape" %>
<%@ page import="com.etn.sql.escape, java.io.BufferedReader,java.io.InputStreamReader,java.net.URL,javax.net.ssl.HttpsURLConnection, java.io.DataOutputStream, java.nio.charset.StandardCharsets, java.sql.*,org.json.*,java.util.regex.Pattern,java.util.regex.Matcher, java.util.*, com.etn.beans.app.GlobalParm" %>


<%
    String cartId = parseNull( request.getParameter("cartId"));
	
	Set rsLang = Etn.execute("Select * from language order by langue_id limit 1");
	String defaultLangId = "1";
	if(rsLang.next()) defaultLangId = rsLang.value("langue_id");

    Set rsCartInfo = Etn.execute("SELECT DISTINCT crt.*, dm.displayName as deliverymethodname "
							 + " FROM " + GlobalParm.getParm("PORTAL_DB") + ".cart crt "
							 + " LEFT JOIN " + GlobalParm.getParm("CATALOG_DB") + ".delivery_methods dm ON dm.site_id = crt.site_id AND dm.method = crt.delivery_method "
							 + " WHERE crt.id="+escape.cote(cartId));
							 
    Set rsCartItemInfo = Etn.execute("SELECT crt_itms.*,prod_var.*, prd.name as variant_name FROM " + GlobalParm.getParm("PORTAL_DB") + ".cart_items crt_itms "
					+ " JOIN " + GlobalParm.getParm("CATALOG_DB") + ".product_variants prod_var ON prod_var.id=crt_itms.variant_id "
					+ " JOIN " + GlobalParm.getParm("CATALOG_DB") + ".product_variant_details prd on prd.langue_id = "+escape.cote(defaultLangId)+" and prd.product_variant_id = prod_var.id WHERE crt_itms.cart_id="+escape.cote(cartId));
	
    Set rsPaymentRefInfo = Etn.execute("SELECT p.*,pm.displayName as paymentmethodname FROM payments_ref p join " + GlobalParm.getParm("PORTAL_DB") + ".cart c on c.id = p.cart_id "
							 + " LEFT JOIN "+ GlobalParm.getParm("CATALOG_DB") + ".payment_methods pm ON pm.site_id = c.site_id AND pm.method = p.payment_method "
							+" WHERE p.cart_id="+escape.cote(cartId)+ " order by created_ts desc");

    JSONObject responseObj = new JSONObject();
    JSONObject customerInfoObj = new JSONObject();
    JSONObject orderInfoObj = new JSONObject();
    JSONObject deliveryInfoObj = new JSONObject();
    JSONObject billingInfoObj = new JSONObject();


    List<JSONObject> cartItemList = new ArrayList<>();
    List<JSONObject> paymentRefList = new ArrayList<>();

    List<String> cartAttrList = Arrays.asList(new String[]{"name","surnames","newphonenumber","email","country"});
    List<String> deliverAttrList = Arrays.asList(new String[]{"deliverymethodname","daline1","daline2","datowncity","dapostalcode"});
    List<String> billingAttrList = Arrays.asList(new String[]{"baline1","baline2","batowncity","bapostalcode"});
    List<String> itemsAttrList = Arrays.asList(new String[]{"quantity","sku","variant_name"});
    List<String> paymentAttrList = Arrays.asList(new String[]{"paymentmethodname","payment_status","total_price"});

    rsCartInfo.next();
    for (String column : rsCartInfo.ColName) {
        if(cartAttrList.contains(column.toLowerCase())){
            try {
                customerInfoObj.put(column.toLowerCase(), parseNull(rsCartInfo.value(column)));
            }
            catch (JSONException e) {
                System.out.println("error:"+e);
            }
        }
        else if(deliverAttrList.contains(column.toLowerCase())){
            try {
                deliveryInfoObj.put(column.toLowerCase(), parseNull(rsCartInfo.value(column)));
            }
            catch (JSONException e) {
                System.out.println("error:"+e);
            }
        }
        else if(billingAttrList.contains(column.toLowerCase())){
            try {
                billingInfoObj.put(column.toLowerCase(), parseNull(rsCartInfo.value(column)));
            }
            catch (JSONException e) {
                System.out.println("error:"+e);
            }
        }else{
        }
    }

    while(rsCartItemInfo.next()){
        JSONObject cartItemsObj = new JSONObject();
        for (String column : rsCartItemInfo.ColName) {
            if(itemsAttrList.contains(column.toLowerCase())){
                try {
                    cartItemsObj.put(column.toLowerCase(), parseNull(rsCartItemInfo.value(column)));
                }
                catch (JSONException e) {
                    System.out.println("error:"+e);
                }
            }
        }

        cartItemList.add(cartItemsObj);
    }

    while(rsPaymentRefInfo.next()){
        JSONObject paymentInfoObj = new JSONObject();
        for (String column : rsPaymentRefInfo.ColName) {
            if(paymentAttrList.contains(column.toLowerCase())) {
                try {
                    paymentInfoObj.put(column.toLowerCase(), parseNull(rsPaymentRefInfo.value(column)));
                }
                catch (JSONException e) {
                    System.out.println("error:" + e);
                }
            }
        }
        paymentRefList.add(paymentInfoObj);
    }


    try {
        orderInfoObj.put("deliveryInfo", deliveryInfoObj);
        orderInfoObj.put("billingInfo", billingInfoObj);
        orderInfoObj.put("cartItems", cartItemList);
        orderInfoObj.put("paymentRefs", paymentRefList);


        responseObj.put("orderInfo", orderInfoObj);
        responseObj.put("customerInfo", customerInfoObj);
    }
    catch (JSONException e) {
        System.out.println("error:"+e);
    }

    out.write(responseObj.toString());
%>