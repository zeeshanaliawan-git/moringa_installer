<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape,com.etn.beans.app.GlobalParm, java.util.*, java.text.*, org.json.*"%>
<%@ include file="cart/lib_msg.jsp"%>
<%@ include file="cart/common.jsp"%>
<%@ include file="cart/orangeMoneyUtils.jsp"%>
<%
	
	System.out.println("**************************************************************");
	System.out.println("|                                                            |");
	System.out.println("|                    IN oCancel.jsp                          |");
	System.out.println("|                                                            |");
	System.out.println("**************************************************************");
	
	//keeping this bare minimum , not including any other helper util jsp
	String id = request.getParameter("payment_ref_id");
	
	System.out.println("................................I am here in oCancel payment_ref_id:" + id);
	String SHOP_DB = GlobalParm.getParm("SHOP_DB");
	Set rs = null;
	if(id == null){
		id = "";
	}
	if(id.length() > 0){
		String q = "SELECT * FROM "+SHOP_DB+".payments_ref WHERE id="+escape.cote(id);
		//add later ?? AND processed <1
		rs = Etn.execute(q);
	}

if(rs == null || rs.rs.Rows == 0){
	response.sendRedirect("unauthorized.html");
	return;
}

System.out.println("................................found:" + id);
if(rs != null && rs.next()){

	String cancelUrl = GlobalParm.getParm("payment_return_jsp");
	if(rs.value("cancel_url").length() > 0)
	{
		cancelUrl = rs.value("cancel_url");
	}
	System.out.println("................................cancelUrl:" + cancelUrl);

	String cartId = rs.value("cart_id");
	String paymentStatus = rs.value("payment_status");
	String sList[] = {"SUCCESS","FAILED","EXPIRED"};
	boolean found = false;
	for(String s : sList){
		if(s.equalsIgnoreCase(paymentStatus)){
			found = true;
			break;
		}
	}

	if(!found){
		try{
			paymentStatus = getAndUpdatePaymentStatus(Etn, id, SHOP_DB);

			if("INITIATED".equalsIgnoreCase(paymentStatus)){
				Etn.executeCmd("UPDATE "+SHOP_DB+".payments_ref "
								+ " SET payment_status='EXPIRED' "
								+ " WHERE id="+escape.cote(id));
				paymentStatus = "EXPIRED";
			}
		}
		catch(Exception ex){
			response.sendRedirect("error.jsp");
			return;
		}
	}
	System.out.println("ORANGE STATUS : " + paymentStatus);
	if(!"FAILED".equalsIgnoreCase(paymentStatus)
		&& !"EXPIRED".equalsIgnoreCase(paymentStatus)){
		response.sendRedirect("error.jsp");
		return;
	}

	String uuidSessionToken = "";
	String cartType = "";
	Set rsCart = Etn.execute("select * from cart where id = "+escape.cote(cartId));
	if(rsCart.next())
	{
		uuidSessionToken = com.etn.asimina.cart.CartHelper.setSessionToken(Etn, rsCart.value("session_id"), rsCart.value("site_id"));
		cartType = rsCart.value("cart_type");
	}        
%>
<!DOCTYPE html>
<html >
  	<head>
	    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
		<script>
			var onLoadSubmit = function() {
				document.myForm.submit();
			};
			window.onload = onLoadSubmit;
		</script>
	</head>
	<body>
		<form name="myForm" action="<%=cancelUrl%>" method="POST">
			<input type="hidden" name="session_token" value="<%=uuidSessionToken%>">
			<input type="hidden" name="payment_method" value='<%=rs.value("payment_method")%>'>
			<input type="hidden" name="delivery_method" value='<%=rs.value("delivery_method")%>'>
			<input type="hidden" name="store" value='<%=rs.value("store")%>'>
			<input type="hidden" name="cartType" value='<%=cartType%>'>
			<input type="hidden" name="muid" value='<%=rs.value("menu_uuid")%>'>
		</form>
	</body>
</html>

<%
} //if(rs)
%>