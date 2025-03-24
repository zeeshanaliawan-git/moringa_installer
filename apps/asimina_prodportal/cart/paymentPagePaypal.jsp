<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm,  javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64,org.json.*"%>
<%@ page import="com.etn.asimina.util.*, com.etn.asimina.cart.*, com.etn.asimina.beans.*, java.text.SimpleDateFormat"%>

<%@ include file="lib_msg.jsp"%>

<%@ include file="common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="paypalUtils.jsp"%>
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
	String hostUrl = parseNull(request.getParameter("hostUrl")); //hostUrl , format requirement http[s]://www.example.com  , no slash at end
	String cartUrl = parseNull(request.getParameter("cartUrl"));
	String returnUrl = parseNull(request.getParameter("returnUrl"));
	String cancelUrl = parseNull(request.getParameter("cancelUrl"));

	String dbSessionToken = CartHelper.getSessionToken(Etn, session_id, ___loadedsiteid);
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

	//reset session token in db for next screen
    String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);
	
	if(payment_method.length() == 0)
	{
		out.print("Payment method not specified"); 
		return;
	}
	
	if("paypal".equals(payment_method) == false)
	{
		out.print("Invalid Payment method");
		return;
	}

	String completeCancelUrl = "payment.jsp";
	if(cancelUrl.length() > 0)
	{
		completeCancelUrl = cancelUrl;
	}

	//get paypal configs
	HashMap<String,String> paypalHM = new HashMap<String,String>();
	Set ppRs = Etn.execute("SELECT * FROM sites_config WHERE site_id = "+escape.cote(___loadedsiteid)+" and code LIKE 'paypal_%'");
	while(ppRs.next()){
		String code = ppRs.value("code");
		String val = parseNull(ppRs.value("val"));
		paypalHM.put(code, val);
	}

	String totalPrice = PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), cart.getGrandTotal()+"", true);

	boolean isError = false;
	SimpleDateFormat orderformat = new SimpleDateFormat("yyMMddHHmmssS");
	String paymentId = "ORDPP"+orderformat.format(new Date())+"_"+(Math.random()+"").substring(2,6);

	String paymentRefId = "";
	try{

		if(hostUrl.length() == 0){
			throw new Exception("Error: Invalid credentials.");
		}

		double orderAmount = parseNullDouble(totalPrice);
		if( orderAmount <= 0.0 ){
			throw new Exception("Error: Order price invalid.");
		}

		PaymentsRef pref = CartHelper.initiatePayment(Etn, request, cart, payment_method, paymentId, hostUrl, returnUrl, cancelUrl);
		com.etn.util.Logger.info("paymentPagePaypal.jsp", "Payment ref id : " + pref.getProperty("id"));
		com.etn.util.Logger.info("paymentPagePaypal.jsp", "Payment id : " + pref.getProperty("payment_id"));
		paymentRefId = pref.getProperty("id");
		
	}
	catch(Exception ex){
		isError = true;
		ex.printStackTrace();
	}

  %>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css">
	<%=_headhtml%>
	<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js" ></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cart.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cookie.js"></script>
    <!-- paypal -->
    <script src="https://www.paypalobjects.com/api/checkout.js"></script>

    <style>
    html{
      /* font-size: 100% !important; */
      line-height: 100% !important;
      overflow-x: hidden;
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
<body class="etn-orange-portal-- isWithoutMenu">
<%=_headerHtml%>

<div class="portal-cart container">
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

	@media(max-width:767px){
		/* body{
		padding: 0 !important;
		} */
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
	<h1 class="o-center recap-heading"><%=libelle_msg(Etn, request, "PayPal")%>
	</h1>
	<form name="myform" id='myform' class="o-form-horizontal" action="completion.jsp" method="post">
		<input type="hidden" name="lang" value="<%=_lang%>" >
		<input type="hidden" name="session_token" value="<%=escapeCoteValue(uuidSessionToken)%>">
		<input type='hidden' id='paymentMethod' name='ignore' value="<%=escapeCoteValue(payment_method)%>"/>
		<input type="hidden" id="paymentRefId" name="payment_ref_id" value="<%=escapeCoteValue(paymentRefId)%>">
		<input type='hidden' id='paymentId' name='ignore' value="<%=escapeCoteValue(paymentId)%>" />
		<input type='hidden' id='totalPrice' name='ignore' value="<%=escapeCoteValue(totalPrice)%>" />



		<div class="o-row">
			<div class="o-col-xs-8 o-col-sm-6 o-text-left">
				<strong class="o-f20"><%=libelle_msg(Etn, request, "Total de la commande")%></strong></div>
			<div class="o-col-xs-4 o-col-sm-6">
				<strong class="o-color-orange"><%=totalPrice%>&nbsp;<%=paypalHM.get("paypal_currency")%></strong>
			</div>
		</div>
		<div class="o-row">
			<div class="o-col-xs-8 o-col-sm-6 ">
				&nbsp;
			</div>
			<div class="o-col-xs-4 o-col-sm-6 paypal-parent" >
				<div id="paypal-button-container"></div>
			</div>
		</div>
		<div class="o-form-group">
		  <div class="o-col-sm-12">
			<button type="button" class="btn" onclick="cancelPayment();">
			  <%=libelle_msg(Etn, request, "Annuler")%>
			</button>
		  </div>
		</div>
	</form>
</div>
<script>
    $(document).ready(function(){
        <% if(isError){ %>
            cancelPayment();
        <% } %>

        initPayPal('#paypal-button-container');
    });

    function cancelPayment(){
		//alert('<%=completeCancelUrl%>');
        $('#myform').attr('action', '<%=completeCancelUrl%>');
        $("#myform").submit();
    }

    function initPayPal(buttonContainerSelector){

        var ppConfig = {
            // Set your environment
            env: '<%=paypalHM.get("paypal_env")%>',

            // Specify the style of the button
            style: {
                label : 'pay',
                layout: 'vertical',  // horizontal | vertical
                size:   'medium',    // small, medium | large | responsive
                shape:  'rect',      // pill | rect
                color:  'gold'       // gold | blue | silver | white | black
            },

            // Specify allowed and disallowed funding sources
            //
            // Options:
            // - paypal.FUNDING.CARD
            // - paypal.FUNDING.CREDIT
            // - paypal.FUNDING.ELV
            funding: {
              allowed: [
              ],
              disallowed: [
                paypal.FUNDING.CARD,
                paypal.FUNDING.CREDIT,
              ]
            },

            client: {
                <%=paypalHM.get("paypal_env")%> : '<%=paypalHM.get("paypal_client_key")%>'
            },

            payment: paypalPayment,

            onAuthorize: paypalOnAuthorize,

            // onCancel : paypalOnCancel,

            // onError : paypalOnError,
        };

        // Render the PayPal button
        paypal.Button.render(ppConfig, buttonContainerSelector);
    }

    function paypalPayment(data, actions) {
        //TODO debug remove all console.log
        //console.log("payment callback");

        paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
            "payment callback", "", "", JSON.stringify(data));

        var pCurrency = '<%=paypalHM.get("paypal_currency")%>';

        var totalPrice = $('#totalPrice').val();
        var invoiceNumber = $('#paymentId').val();

        var  paymentObj = {
            //https://developer.paypal.com/docs/api/payments/v1/#definition-application_context
            application_context : {
                // brand_name : ''//override merchant paypal name
                // locale : '', //e.g. US, FR, etc
                shipping_preference : 'NO_SHIPPING'
            },
            transactions: [{
                amount: {
                    total: totalPrice,
                    currency: pCurrency,
                },
                description: 'Order # '+invoiceNumber,
                invoice_number: invoiceNumber,
                payment_options: {
                    allowed_payment_method: 'INSTANT_FUNDING_SOURCE'
                },
                item_list: {
                    items: [
                    {
                        name: '-',
                        // description: 'Black handbag.',
                        quantity: '1',
                        price: totalPrice,
                        // tax: '0.02',
                        // sku: 'product34',
                        currency: pCurrency
                    }],
                }
            }],
        };

        paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
            "create payment request", "", JSON.stringify(paymentObj),"");
        return actions.payment.create(paymentObj)
            .then(function(response){
                //console.log("create payment response");
                //console.log(response);

                paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                    "create payment response success", "", "", JSON.stringify(paymentObj));

                var paypalTxnId = response;
                $.ajax({
                        url: 'paypalAjax.jsp',
                        type: 'POST',
                        dataType: 'json',
                        data: {
                            requestType : 'updateTxnId',
                            id : $('#paymentRefId').val(),
                            paymentId : $('#paymentId').val(),
                            txnId : paypalTxnId
                        },
                    })
                    .done(function(json) {
                        //console.log("Update Txn Id | "+ json.status);
                        if(json.status == "SUCCESS"){
                            //
                        }
                        else{
                            //
                        }
                    })
                    .fail(function() {
                        console.log("Update Txn Id | server error");
                    });
                //do something before rendering paypal
                return response;
            })
            .catch(function(err){
                paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                    "create payment response error", "", "", JSON.stringify(err));
                //throw error to onError callback
                console.log("ERROR in create payment ");
                console.log(err);
                throw err;
            });
    }//end paypalPayment func

    function paypalOnAuthorize(data, actions) {
        //console.log("callback onAuthorize");
        //console.log("paypalOnAuthorise: data: "+ JSON.stringify(data));
        //console.log(data);
//alert(data);
        paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
            "onAuthorize callback", "", "", JSON.stringify(data));


        return actions.payment.get().then(function(paymentData){

            var paymentId   = paymentData.transactions[0].invoice_number;
            var txnId       = paymentData.id;
            var totalPrice  = paymentData.transactions[0].amount.total;
			var orderId 	= paymentData.cart;
			
            paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                "payment get response", "", "", JSON.stringify(paymentData));

//            console.log("callback payment.get() :" + JSON.stringify(paymentData));
            //console.log(paymentData);
            var verifyParams = {
                    requestType : 'verifyAuth',
                    id : $('#paymentRefId').val(),
                    paymentId : paymentId,
                    txnId : txnId,
                    totalPrice : totalPrice,
					orderId : orderId,
                };
            $.ajax({
                url: 'paypalAjax.jsp',
                type: 'POST',
                dataType: 'json',
                data: verifyParams,
            })
            .done(function(json) {
                //console.log("Update Txn Id | "+ json.status);
                paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                "internal verify auth", "paypalAjax.jsp", JSON.stringify(verifyParams), JSON.stringify(json));
                if(json.status == "SUCCESS"){
                    actions.payment.execute()
                        .then(function (eData) {

                            paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                            "paypal payment success response", "", "", JSON.stringify(eData));

                            console.log("Payment execute | Success")
                            confirmPayment(eData);//debug
                        })
                        .catch(function(err){
                            paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                            "paypal payment error response", "", "", JSON.stringify(err));

                            console.log("Payment execute | ERROR !! ")
                            console.log(err);
                            //error in payment execution
                            cancelPayment(); //debug
                        });
                }
                else{
                    cancelPayment(); //debug
                }
            })
            .fail(function() {
                 cancelPayment(); //debug
            });


        })
        .catch(function(err){
            //throw error to onError callback
            console.log("ERROR in create payment ");
            console.log(err);
            throw err;
        });
    }

    function confirmPayment(paymentData){
        var txnId       = paymentData.id;
        var paymentId   = paymentData.transactions[0].invoice_number;
        var totalPrice  = paymentData.transactions[0].amount.total;
        var paymentState = paymentData.state;
        var orderId = paymentData.cart;

        var confirmPaymentParams = {
                requestType : 'confirmPayment',
                id : $('#paymentRefId').val(),
                paymentId : paymentId,
                txnId : txnId,
                totalPrice : totalPrice,
                paymentState : paymentState,
                orderId : orderId,
            };

        paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
        "internal confirm payment", "",JSON.stringify(confirmPaymentParams), "");

        $.ajax({
            url: 'paypalAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: confirmPaymentParams,
        })
        .done(function(json) {

            if(json.status == "SUCCESS"){

                paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                "internal confirm payment success", "paypalAjax.jsp",JSON.stringify(confirmPaymentParams), JSON.stringify(json));

                $('#myform').attr('action', 'completion.jsp');
                $("#myform").submit();
            }
            else{
                paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                "internal confirm payment error", "paypalAjax.jsp",JSON.stringify(confirmPaymentParams), JSON.stringify(json));

                alert("Error: payment data invalid.");
                cancelPayment();//debug
            }
        })
        .fail(function() {
                paymentLogger($('#paymentRefId').val(), $('#paymentMethod').val(),
                "internal confirm payment error", "paypalAjax.jsp",JSON.stringify(confirmPaymentParams), "");
                cancelPayment(); //debug
        });
    }


    function paymentLogger(paymentRefId, paymentMethod, action, url,
        request, response){

        var reqParams = {
            paymentRefId : paymentRefId,
            paymentMethod : paymentMethod,
            action : action,
            url : url,
            request : request,
            response : response,
        };

        $.ajax({
            url: 'paymentLoggerAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: reqParams,
        })
        .done(function(resp) {
            if(resp.status !== 'SUCCESS'){
                console.log("Error in payment logger: " + resp.message);
            }
        })
        .fail(function() {
            console.log("Error in accessing payment logger");
        });
    }

</script>
    
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/focus-visible.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/popper.min.js" ></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/jquery.tablesorter.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/swiper.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/boosted.js" ></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bs-custom-file-input.min.js"></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/TweenMax.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/nouislider.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/algoliasearch.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/mobile-detect.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/sticky-sidebar.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/ResizeSensor.min.js"></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bundle.js"></script>
<%=_footerHtml%>

<%=_endscriptshtml%>

    
<script>
$(document).ready(function(){
	document.title = "<%=libelle_msg(Etn, request, "PayPal")%> | "+document.title;
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
