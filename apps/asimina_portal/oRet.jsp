<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape,com.etn.beans.app.GlobalParm, java.util.*, java.text.*, org.json.*"%>
<%@ include file="cart/lib_msg.jsp"%>
<%@ include file="cart/common.jsp"%>
<%@ include file="cart/orangeMoneyUtils.jsp"%>

<%
	System.out.println("**************************************************************");
	System.out.println("|                                                            |");
	System.out.println("|                       IN oRet.jsp                          |");
	System.out.println("|                                                            |");
	System.out.println("**************************************************************");
	System.out.println(extractPostRequestBody(request));
    //keeping this bare minimum , not including any other helper util jsp
    String id = request.getParameter("payment_ref_id");
    String SHOP_DB = GlobalParm.getParm("SHOP_DB");
    Set rs = null;
    if(id == null){
        id = "";
    }
    if(id.length() > 0){
        String q = "SELECT * FROM "+SHOP_DB+".payments_ref WHERE id="+escape.cote(id);
		System.out.println(q);
        //add later ?? AND payment_status == 'INITIATED' or 'PENDING'
        rs = Etn.execute(q);
    }

if(rs == null || rs.rs.Rows == 0){
    response.sendRedirect("unauthorized.html");
    return;
}
if(rs != null && rs.next()){
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
        }
        catch(Exception ex){
            ex.printStackTrace();
            response.sendRedirect("error.jsp");
            return;
        }
    }

    //if(!"SUCCESS".equalsIgnoreCase(paymentStatus)){
    //  response.sendRedirect("error.jsp");
    //  return;
    //}

    boolean isSuccess = "SUCCESS".equalsIgnoreCase(paymentStatus);

    String formAction = "cart/completion.jsp";

    if(!isSuccess)
	{
        formAction = GlobalParm.getParm("payment_return_jsp");
		
		if(rs.value("return_url").length() > 0)
		{
			formAction = rs.value("return_url");
		}
		else if(rs.value("cancel_url").length() > 0)
		{
			formAction = rs.value("cancel_url");
		}
    }
	
	String uuidSessionToken = "";
	String cartType = "";
	Set rsCart = Etn.execute("select * from cart where id = "+escape.cote(cartId));
	if(rsCart.next())
	{
		uuidSessionToken = com.etn.asimina.cart.CartHelper.setSessionToken(Etn, rsCart.value("session_id"), rsCart.value("site_id"));
		cartType = rsCart.value("cart_type");
	} 

	com.etn.util.Logger.info("oRet.jsp","formAction:"+formAction);
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
        <form name="myForm" action="<%=formAction%>" method="POST">
            <input type="hidden" name="session_token" value="<%=uuidSessionToken%>">
            <input type="hidden" name="payment_method" value='<%=rs.value("payment_method")%>'>
            <input type="hidden" name="delivery_method" value='<%=rs.value("delivery_method")%>'>
            <input type="hidden" name="store" value='<%=rs.value("store")%>'>
			<input type="hidden" name="cartType" value='<%=cartType%>'>
			<input type="hidden" name="muid" value='<%=rs.value("menu_uuid")%>'>
			
            <%
                if(isSuccess){
            %>
                 <input type="hidden" name="payment_ref_id" value='<%=rs.value("id")%>'>
            <%
                }
            %>
        </form>
    </body>
</html>

<%
} //if(rs)
%>