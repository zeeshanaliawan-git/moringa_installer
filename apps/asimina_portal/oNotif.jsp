<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.beans.Contexte,com.etn.lang.ResultSet.Set,com.etn.sql.escape,com.etn.beans.app.GlobalParm, java.util.*, java.text.*, org.json.*, com.etn.asimina.util.*,com.etn.asimina.beans.*,com.etn.asimina.cart.CartHelper"%>
<%!
	
	class PaymentRef{
		String cartId;
		String menuUUID;
	}
	
	class CartDetails{
		String cartSessionId;
		String siteId;
	}
	
	String extractPostRequestBody(HttpServletRequest request) {
	    if ("POST".equalsIgnoreCase(request.getMethod())) {
	        java.util.Scanner s = null;
	        try {
	            s = new java.util.Scanner(request.getInputStream(), "UTF-8").useDelimiter("\\A");
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	        return s.hasNext() ? s.next() : "";
	    }
	    return "";
	}
	
	PaymentRef getPaymentRef(Contexte Etn,String SHOP_DB, String paymentRefId, String notifToken){
		Set rs = Etn.execute("select cart_id,menu_uuid from "+SHOP_DB+".payments_ref WHERE id=" + escape.cote(paymentRefId)
							+ " AND payment_notif_token=" + escape.cote(notifToken));
		if(rs != null && rs.next()){
			PaymentRef ref = new PaymentRef();
			ref.cartId = PortalHelper.parseNull(rs.value("cart_id"));
			ref.menuUUID = PortalHelper.parseNull(rs.value("menu_uuid"));
			return ref;
		}
		return null;
	}
	
	CartDetails getCartDetails(Contexte Etn,String cartId){
		Set rs = Etn.execute("select session_id,site_id from cart where id = " + escape.cote(cartId));
		if(rs != null && rs.next()){
			CartDetails cartDetails = new CartDetails();
			cartDetails.cartSessionId = PortalHelper.parseNull(rs.value("session_id"));
			cartDetails.siteId = PortalHelper.parseNull(rs.value("site_id"));
			return cartDetails;
		}
		return null;
	}
%>
<%
	//Page sent as "notif_url" to Orange Web Payment API
	//
	// Sample POST body sent by orange server, json
	// {
	//    "status":"SUCCESS", // or FAILURE or EXPIRED
	//    "notif_token":"dd497bda3b250e53618ddc0663f32f40",
	//    "txnid": "MP150709.1341.B00000"
	// }
	System.out.println("**************************************************************");
	System.out.println("|                                                            |");
	System.out.println("|                     IN oNotif.jsp                          |");
	System.out.println("|                                                            |");
	System.out.println("**************************************************************");
	String requestBody = "";
	if("POST".equalsIgnoreCase(request.getMethod())){
		requestBody = extractPostRequestBody(request);
		System.out.println("-------------------oNotif called:" + requestBody);
		
		org.json.JSONObject jObj = null;
		try{
			jObj = new org.json.JSONObject(requestBody);
		}
		catch(Exception ex){
			jObj = null;
		}

		if(jObj != null && !jObj.isNull("status") && !jObj.isNull("notif_token") && !jObj.isNull("txnid") ){
			String SHOP_DB = GlobalParm.getParm("SHOP_DB");
			String paymentRefId = request.getParameter("payment_ref_id");
			String status = jObj.getString("status");
			String notifToken = jObj.getString("notif_token");
			
			PaymentRef ref = getPaymentRef(Etn,SHOP_DB,paymentRefId,notifToken);
			if(ref != null){//means record is there in database against this payment_ref and notiftoken
			
				System.out.println("ORDERREF ID :"+paymentRefId+"|");
				System.out.println(jObj.toString());

				String isSuccess = "0";
				if("success".equalsIgnoreCase(status)) isSuccess = "1";

				String query = "UPDATE "+SHOP_DB+".payments_ref SET payment_status = " + escape.cote(status)
								+ " ,is_success = "+escape.cote(isSuccess)+", payment_txn_id = " + escape.cote(jObj.getString("txnid"))
								+ " WHERE id=" + escape.cote(paymentRefId)
								+ " AND payment_notif_token=" + escape.cote(notifToken);
				//out.write(query);
				Etn.executeCmd(query);
				
				if("SUCCESS".equalsIgnoreCase(status)){
					CartDetails cartDetails = getCartDetails(Etn,ref.cartId);
					if(cartDetails != null){						
						Cart cart = CartHelper.loadCart(Etn,request,cartDetails.cartSessionId,cartDetails.siteId,ref.menuUUID);
						java.util.Map<String,String> order = com.etn.asimina.cart.CartHelper.insertOrder(Etn,request,cart,"",null,null);
						String orderUUID = PortalHelper.parseNull(order.get("orderUuid"));
						if(orderUUID.length() > 0){
							Etn.execute("update cart set order_uuid = " + escape.cote(orderUUID) + " where id = " + escape.cote(ref.cartId));
						}
					}
				}
			}
		}
 		out.write("");
	}
%>