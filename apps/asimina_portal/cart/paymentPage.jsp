<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm,  javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64,org.json.*"%>
<%@ page import="com.etn.asimina.cart.*, com.etn.asimina.util.*, com.etn.asimina.beans.*, org.json.JSONObject, java.text.SimpleDateFormat"%>

<%@ include file="lib_msg.jsp"%>

<%@ include file="common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="orangeMoneyUtils.jsp"%>

<%
    int stepNumber = 3;
	String _error_msg = "Some error occurred while processing cart";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "funnel";
	
	String ___muuid = CartHelper.getCartMenuUuid(request);
	String session_id = CartHelper.getCartSessionId(request);

%>
<%@ include file="../logofooter.jsp"%>
<%
	String sessionToken = parseNull(request.getParameter("session_token"));
	String payment_method = parseNull(request.getParameter("payment_method"));
	String hostUrl = parseNull(request.getParameter("hostUrl")); 
	String cartUrl = parseNull(request.getParameter("cartUrl"));
	String returnUrl = parseNull(request.getParameter("returnUrl"));
	String cancelUrl = parseNull(request.getParameter("cancelUrl"));
	
	System.out.println("..............................................................");
	System.out.println("sessionToken:" + sessionToken);
	System.out.println("payment_method:" + payment_method);
	System.out.println("hostUrl:" + hostUrl);
	System.out.println("cartUrl:" + cartUrl);
	System.out.println("returnUrl:" + returnUrl);
	System.out.println("cancelUrl:" + cancelUrl);
	System.out.println("session_id:" + session_id);
	System.out.println("___loadedsiteid:"+ ___loadedsiteid);
	
	String dbSessionToken = CartHelper.getSessionToken(Etn, session_id, ___loadedsiteid);
	System.out.println("dbSessionToken:" + dbSessionToken);
	if(!sessionToken.equals(dbSessionToken))
	{
		String url = "cart.jsp";
		if(cartUrl.length() > 0)
		{
			url = cartUrl;
		}
		url += "?muid="+___muuid;
		response.sendRedirect(url);
		return;
	}

	Cart cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid, true);
	if(cart.isEmpty())
	{		
		response.sendRedirect(cart.getError(CartError.EMPTY_CART).getReturnUrl());
		return;
	}
	if(cart.hasError())
	{		
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"cart.jsp?muid="+___muuid);
		return;
	}	
	
	if(hostUrl.length() == 0)
	{
		out.print("host url must be specified");
		return;
	}
	
	String identityId = parseNull(cart.getProperty("identityId"));
	String email  = parseNull(cart.getProperty("email"));

	String client_id = "";
	Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	if(client != null)
	{
		client_id = client.getProperty("id");
	}
	if(client_id.length() == 0)
	{
		Set rsClient = Etn.execute("select * from clients where site_id = "+escape.cote(___loadedsiteid)+" and email="+escape.cote(email));
		if(rsClient.next())
		{
			client_id = rsClient.value("id");
		}
	}

	CartError cErr = CartHelper.checkFraud(Etn, ___loadedsiteid, ___muuid, client_id, cart.getProperty("cart_type"), CartHelper.loadFraudRuleColumns(Etn, request, cart));
	if(cErr != null)//fraud detected and logged in db
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"error_fraud.jsp?muid="+___muuid+"&_tm="+System.currentTimeMillis());
		return;		
	}
	
	
	String SHOP_DB = com.etn.beans.app.GlobalParm.getParm("SHOP_DB");
	
	
	if(payment_method.length() == 0)
	{
		out.print("Payment method not specified"); 
		return;
	}
	
	if("orange_money".equals(payment_method) == false)
	{
		out.print("Invalid Payment method");
		return;
	}
	
	String totalPrice = PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), cart.getGrandTotal()+"", true);

	String status = "";
	String message = "";

	//reset session token in db for next screen
    String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);
	
	if("orange_money".equals(payment_method))
	{
		try{

			if(hostUrl.length() == 0){
				throw new Exception("Error: Invalid credentials.");
			}

			double orderAmount = parseNullDouble(totalPrice);
			if( orderAmount <= 0.0 ){
				throw new Exception("Error: Order price invalid.");
			}

			SimpleDateFormat orderformat = new SimpleDateFormat("yyMMddHHmmssS");
			String orderRefId = "ORD"+orderformat.format(new Date())
									+"_"+(Math.random()+"").substring(2,6);

			PaymentsRef pref = CartHelper.initiatePayment(Etn, request, cart, payment_method, orderRefId, hostUrl, returnUrl, cancelUrl);
			com.etn.util.Logger.info("paymentPage.jsp", "Payment ref id : " + pref.getProperty("id"));
			com.etn.util.Logger.info("paymentPage.jsp", "Payment id : " + pref.getProperty("payment_id"));
			String paymentRefId = pref.getProperty("id");

			//param payment_ref_id is important as its used later in oRet and oNotif
			String completeReturnUrl = hostUrl + GlobalParm.getParm("EXTERNAL_LINK")+ "oRet.jsp?payment_ref_id="+paymentRefId;
			
			String completeCancelUrl = hostUrl + GlobalParm.getParm("EXTERNAL_LINK")+ "oCancel.jsp?payment_ref_id="+paymentRefId;
			
			//needs to be public , called and sent transaction status by orange server
			String notifUrl  = hostUrl + GlobalParm.getParm("EXTERNAL_LINK")+ "oNotif.jsp?payment_ref_id="+paymentRefId;

			JSONObject retJson = initiateOrangeMoneyTransaction(Etn, orderRefId, orderAmount, completeReturnUrl, completeCancelUrl, notifUrl, _lang, ___loadedsiteid);

			String rStatus 		= retJson.getString("status");
			String rMessage 	= retJson.getString("message");
			String rPayToken 	= retJson.getString("pay_token");
			String rPaymentUrl 	= retJson.getString("payment_url");
			String rNotifToken 	= retJson.getString("notif_token");

			JSONObject jData = new JSONObject();

			if( rStatus.equals("201")
				&& rMessage.equalsIgnoreCase("ok")
				&& rPayToken.length() > 0
				&& rPaymentUrl.length() > 0
				&& rNotifToken.length() > 0
				){

				String query = "UPDATE "+SHOP_DB+".payments_ref "
								+ " SET payment_status='INITIATED' "
								+ " , payment_id=" + escape.cote(orderRefId)
								+ " , payment_token=" + escape.cote(rPayToken)
								+ " , payment_url=" + escape.cote(rPaymentUrl)
								+ " , payment_notif_token=" + escape.cote(rNotifToken)
								+ " WHERE id = " + escape.cote(paymentRefId);

				com.etn.util.Logger.info("paymentPage.jsp", query); //debug
				Etn.executeCmd(query);

				status = "SUCCESS";
				message = "";
									//System.out.println(rPaymentUrl);
				response.sendRedirect(rPaymentUrl);
				return;
			}
			else{
				status = "ERROR";
				message = "Error: Unexpected response from payment provider.";
			}
		}
		catch(Exception ex){
			message += "\n" + ex.getMessage();
			status = "ERROR";
			ex.printStackTrace();
		}
		//sendredirect
	}

	String formAction = GlobalParm.getParm("payment_return_jsp");

  %>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
<%=_headhtml%>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
<% if("rtl".equalsIgnoreCase(langDirection)) { %>
		<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/cart-rtl.css">
		<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
		<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeIcons.min.css">
	<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted-rtl.min.css">
<% } else { %>
		<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/cart.css">
		<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
		<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeIcons.min.css">
	<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
<% } %>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/bootstrap.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cart.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cookie.js"></script>
<style>
    html{
      /* font-size: 100% !important; */
      line-height: 100% !important;
      overflow-x: hidden;
    }
      body {
        margin: 0;
        font-family: HelvNeueOrange,"Helvetica Neue",Helvetica,Arial,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol";
        font-size: 1rem !important;
        font-weight: 400;
        line-height: 1.25;
        color: #000;
        text-align: left;
        background-color: #fff;
      }
      .portal-cart{
        font-size: 16px;
        line-height: 20px;
      }
      .etn-orange-portal-- .o-container h1{
        font-size: 4em;
        /* font-weight: bold; */
        margin-top: 30px;
        /* margin-bottom: 30px; */
        padding-bottom: 15px;
        /* border-bottom: 2px solid #ccc; */
      }
      .btn{
          padding: .5em 1.125em;
          font-size: 1em;
          font-weight: bold !important;
      }
      .btn.btn-primary{
          color: #fff;
      }
      .btn-primary:not(:disabled):not(.disabled).active, .btn-primary:not(:disabled):not(.disabled):active, .btn-warning:not(:disabled):not(.disabled).active, .btn-warning:not(:disabled):not(.disabled):active, .show > .btn-primary.dropdown-toggle, .show > .btn-warning.dropdown-toggle {
            color: #000 !important;
            border-color: #000 !important;

        }
      .o-orange_modal {
            position: fixed;
            z-index: 9001;
            display: none;
            height: 400px;
            left: 0;
            top: 140px;
            /*box-shadow: 0 0 20px 0 rgba(0,0,0,0.5);*/
            width: 100%;
          }
          .o-orange_modal>div{
            width: 100%;
            max-width: 900px;
            display: block;
            margin: 0 auto;
          }
          .o-orange_modal .o-header.o-black,
          .o-orange_modal .o-footer.o-black {
            height: auto;
            padding: 15px;
          }
          .o-orange_modal .o-content{
            background: white;
            padding: 15px;
            max-height: 300px;
            overflow: auto;
          }
        .o-overlay{
          display: none;
          position: fixed;
          left: 0;
          top: 0;
          z-index: 9000;
          width: 100%;
          height: 100%;
          overflow: hidden;
          background-color: rgba(0,0,0,0.5);
        }
        .o-overlay.o-active{
          display: block;
        }
        .o-orange_modal.o-active{
          display: block;
        }
        .custom-control {
          min-height: 1.25em !important;
          padding-left: 1.875em !important  ;
          margin-bottom: .625em !important;
        }
        .custom-control-label::before {
            width: 1.25em;
            height: 1.25em;
        }
        .custom-control-label::after {
            width: 1.25em;
            height: 1.25em;
            background-size: 1em;

        }


        .custom-control-inline {
            margin-right: 1.25rem !important;

        }
        .o-error .custom-control-label::before{
          border-color: red;
        }
        @media(max-width:786px){
          h1,h2{
            font-size: 50px !important;
          }
        }
</style>
</head>
<body class="etn-orange-portal-- isWithoutMenu d-none">
<%=_headerHtml%>

<div class="portal-cart o-container">
<style>
        .etn-orange-portal-- .o-form-horizontal .o-control-label{
            text-align: left;
        }
        .etn-orange-portal-- nav{
            width: auto !important;
            height: auto !important;
            float: none;
            margin: 0;
        }
        .o-control-label{
            font-weight: bold !important;
        }
        .btn{
            padding: .5em 1.125em;
            font-size: 1em;
            font-weight: bold !important;
        }
        .btn.btn-primary{
            color: #fff;
        }
        button.btn.btn-dark,
        a.btn.btn-dark{
            color: #fff ;
        }
        button.btn.btn-dark:hover{
            color: #000;
        }
        @media(max-width:767px){
            body{
            padding: 0 !important;
            }
        }
        .popover{
            /* font-size: 1em; */
            font-size: 16px;
            text-align: center;
            width: 400px;
        }

</style>
	<%@ include file="stepbar.jsp"%>
<div class="o-row">
</div>
<h1 class="o-center recap-heading"><%=libelle_msg(Etn, request, "Orange Money")%>
</h1>
<form name="myform" id='myform' class="o-form-horizontal" action="<%=escapeCoteValue(formAction)%>" method="post">
	<input type="hidden" name="lang" value="<%=escapeCoteValue(_lang)%>" >
	<input type="hidden" name="session_token" value="<%=escapeCoteValue(uuidSessionToken)%>">
	<input type='hidden' name='transaction_code' value="" />
<%if("ERROR".equals(status)){%>
	<input type='hidden' name='payment_error' value="1" />
<%}%>
</form>
</div>
<script>
    $(document).ready(function(){
    	$('#myform').submit();
    });
</script>
<script src='<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/js/popper.min.js'></script>
<script src='<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/js/boosted.min.js'></script>
<%=_footerHtml%>

<%=_endscriptshtml%>

<script>
$(document).ready(function(){
	$(window).keydown(function(event){
		if(event.keyCode == 13) {
			event.preventDefault();
			return false;
		}
	});
});
</script>
</body>
</html>
