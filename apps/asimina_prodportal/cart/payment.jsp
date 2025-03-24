<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*"%>

<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>
<%
    int stepNumber = 3;
    

    boolean isCart = false;
    boolean isRecap = true;
    boolean isCompletion = false;
	String _error_msg = "Some error occurred while processing cart";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "funnel";
	
	String ___muuid = CartHelper.getCartMenuUuid(request);
	String session_id = CartHelper.getCartSessionId(request);

%>
<%@ include file="../logofooter.jsp"%>
<%
	String sessionToken = parseNull(request.getParameter("session_token"));
        

	String dbSessionToken = CartHelper.getSessionToken(Etn, session_id, ___loadedsiteid);
	if(!sessionToken.equals(dbSessionToken))
	{
		response.sendRedirect("cart.jsp?muid="+___muuid);
		return;
	}
	    
	String client_id = "";
	boolean logged = false;
	String client_uuid = "";	

	Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	if(client != null)
	{
		logged = true;
		client_id = client.getProperty("id");
		client_uuid = client.getProperty("client_uuid");
	}
    
	Cart cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid, true, true);

    String isIdnow = cart.getProperty("idnow_uuid");

    if(isIdnow.length()>0)
    {
        boolean iskycrequired = CartHelper.isKycRequired(Etn, ___loadedsiteid);
        if(iskycrequired) stepNumber = 4;

        if(!iskycrequired && CartHelper.isKycCompleted(Etn,cart.getProperty("id")))
        {
            response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"cart.jsp?muid="+___muuid);
            return;
        }
    }
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
	
	com.etn.util.Logger.info("payment.jsp","Cart total = " + cart.getGrandTotal());
	// total price to pay is zero so skip this step
    if(cart.getGrandTotal() == 0)
	{ 
		//reset session token in db for next screen
		String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);
		String html = "<html><body><form name='paymentForm' method='post' action='completion.jsp'><input type='hidden' name='session_token' value='"+escapeCoteValue(uuidSessionToken)+"'></form><script>document.forms[0].submit();</script></body></html>";
		out.write(html);
        return;
    }
	
	String payment_error = parseNull(request.getParameter("payment_error"));

	HashMap<String, String> paymentImages = new HashMap<String, String>();
	paymentImages.put("credit_card","/src/assets/icons/payment-method/Visa.png");
	paymentImages.put("cash_on_delivery","/src/assets/icons/payment-method/ic_Currency_money.png");
	paymentImages.put("cash_on_pickup","/src/assets/icons/payment-method/ic_Currency_money.png");
	paymentImages.put("orange_money","/src/assets/icons/payment-method/Orangemoney.png");
	paymentImages.put("paypal","/src/assets/icons/payment-method/Paypal.png");
	paymentImages.put("orange_money_obf","/src/assets/icons/payment-method/Orangemoney.png");

	String defaultcurrency = cart.getDefaultCurrency();
	String priceformatter = cart.getPriceFormatter();
	String roundto = cart.getRoundTo();
	String showdecimals = cart.getShowDecimals();        
        
	Set rsDomain = Etn.execute("Select domain from sites where id = " + escape.cote(_menuRs.value("site_id")));
	rsDomain.next();
	Map<String, String> gtmScriptCode = getGtmScriptCodeForCart(Etn, _menuRs.value("id"), rsDomain.value(0)+com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"payment.jsp", "funnel", "", "", "",client_uuid,"","",(logged?"yes":"no"), "");
		
	String __cartmenuid = _menuRs.value("id");		
	
	//reset session token in db for next screen
    String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);
	
	//set the step name here as it is required for further verifications
	Etn.executeCmd("update cart set cart_step = "+escape.cote(CartHelper.Steps.PAYMENT)+" where id = "+escape.cote(cart.getProperty("id")));
	
%>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<%=parseNull(gtmScriptCode.get("SCRIPT_SNIPPET"))%>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css">
	<%=_headhtml%>
	<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/search-bundle.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cart.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cookie.js"></script>


	<script src="https://www.paypalobjects.com/api/checkout.min.js" async></script>

    <style>
 .js-focus-visible body{
          height:auto;
      }
      
      .etnhf-gray-footer{
          display: none;
      }
	  
.loading2{
	  overflow: hidden;
	  position: relative;
  }
  
.loading2::after{
	  content: "";
	  overflow: hidden;
	  display : block;
	  position:   absolute;
	  z-index:    99999;
	  top:        0;
	  left:       0;
	  height:     100%;
	  width:      100%;
	  background: rgba( 255, 255, 255, .8 )
				  url('../img/spinner.gif')
				  50% 50%
				  no-repeat;
  
}
  
body.loading2::after{
	position: fixed;
}
  
.loading2 > .loading2msg{
	  position: absolute;
	  top : 55%;
	  width : 100%;
	  text-align: center;
	  z-index: 9999999;
}
body.loading2 > .loading2msg{
	position: fixed;
}		  
     </style>
</head>
<body class="etn-orange-portal-- isWithoutMenu">
<%=parseNull(gtmScriptCode.get("NOSCRIPT_SNIPPET"))%>
<%=_headerHtml%>

<%@ include file="stepbar.jsp"%>

<%-- Content start --%>
<div class="container-lg TunnelPayment">
  <h2 class="TunnelMainTitle"><%=libelle_msg(Etn, request, "Mode de paiement")%></h2>

  <div class="row">
    <div class="col-12 col-lg-8">

      <form id="paymentForm" method="POST" class="TunnelForm PaymentMethod">
          
        <input type="hidden" name="session_token" value="<%=escapeCoteValue(uuidSessionToken)%>">
        <input type="hidden" name="hostUrl" id="hostUrl" value="">
        <input type="hidden" name="grandTotal" id="grandTotal" value=''>
        <div class="radio-container PaymentMethod-container">
            <%

        Set rsPaymentMethods = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".payment_methods where site_id = " + escape.cote(___loadedsiteid) + " and enable=1 order by orderSeq;");
        int count = 0;
        
        
        Set rsLang =Etn.execute("select * from language where langue_code="+escape.cote(_lang));
        rsLang.next();
        Set rsShop =Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id="+escape.cote(___loadedsiteid));
        rsShop.next();
        
        while(rsPaymentMethods.next()){
            //if(rsPaymentMethods.value("method").equals("cash_on_delivery") && is_jeune) continue;
        %>
        <div class="custom-control custom-radio mb-3 d-flex align-items-end radio-label-icon">
          <input type="radio" id="radio-paiement-<%=count%>" name="payment_method" value="<%=escapeCoteValue(rsPaymentMethods.value("method"))%>" data-price="<%=escapeCoteValue((parseNullDouble(rsPaymentMethods.value("price"))<=0?"0":formatPrice(priceformatter, roundto, showdecimals, rsPaymentMethods.value("price"), true)))%>" class="custom-control-input isPristine" required <%=(count==0?"checked":"")%>>
          <label class="d-flex flex-column custom-control-label" for="radio-paiement-<%=count%>">
            <img class="PaymentMethod-img" src="<%=escapeCoteValue(parseNull(paymentImages.get(rsPaymentMethods.value("method"))))%>" alt="">
            <%=libelle_msg(Etn, request, rsPaymentMethods.value("displayName"))%>
          </label>
          <span class="text-primary font-weight-bold ml-auto"><%=escapeCoteValue((parseNullDouble(rsPaymentMethods.value("price"))<=0?parseNull(rsShop.value("lang_"+ parseNull(rsLang.value("langue_id"))+"_free_payment_method")):formatPrice(priceformatter, roundto, showdecimals, rsPaymentMethods.value("price"))+" "+defaultcurrency))%></span>
        </div>
        <%
            count++;
        }
        %>

        </div>

        <div class="PaymentMethod-asterisk">* <%=libelle_msg(Etn, request, "Frais de paiement estimé")%></div>

          <button type="button" class="btn btn-primary mt-4 d-none d-lg-flex buyall">
              <%=libelle_msg(Etn, request, "Aller au paiement")%>
          </button>
          <button type="button" class="btn btn-primary mt-4 full-btn-mobile d-lg-none buyall">
              <%=libelle_msg(Etn, request, "Aller au paiement")%>
          </button>
      </form>

    </div>
    <div class="StickySidebar col-12 col-lg-4" data-sticky-options='{"startTrigger": 20}'>
      <div class="StickySidebar-content OrderSummary">
                <jsp:include page="../calls/getRecap.jsp">
                    <jsp:param name="site_id" value="<%=escapeCoteValue(___loadedsiteid)%>"/>
                    <jsp:param name="lang" value="<%=escapeCoteValue(_lang)%>"/>
                    <jsp:param name="menu_id" value="<%=escapeCoteValue(__cartmenuid)%>"/>					
                </jsp:include>
            </div>
    </div>
  </div>


</div>
              
              <!-- Modal -->
<div class="BasketModal modal fade" id="paymentError" tabindex="-1" role="dialog" aria-labelledby="errorServerTitle"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <div class="BasketModal-title" id="errorServerTitle">
                    <span class="BasketModal-iconTitle"
                          data-svg="/src/assets/icons/icon-alert.svg"></span>
                    <span class="BasketModal-titleWrapper h2"><%=libelle_msg(Etn, request, "Votre paiement n'a pu aboutir, veuillez renouveler votre paiement")%></span>
                </div>

                <div class="BasketModal-section">
                    <p><%=libelle_msg(Etn, request, "Merci de sélectionner un autre mode de paiement.")%></p>
                    <p><%=libelle_msg(Etn, request, "Si vous rencontrez à nouveau le même problème, merci de contacter le service client")%>
                    </p>
                </div>

                <div class="BasketModal-actions BasketModal-section">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="trackReturnToPaymentClick()"><%=libelle_msg(Etn, request, "Revenir au paiement")%></button>
                </div>
            </div>
        </div>
    </div>
</div>
<%-- Content ends --%>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js" ></script>
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
<script src='<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/js/popper.min.js'></script>
<script src='<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/js/boosted.min.js'></script>
<%=_footerHtml%>

<%=_endscriptshtml%>
<script>
    var datalayerCommonVariables = {
        funnel_name: 'funnel',
        funnel_step: 'Step 4',
        funnel_step_name: 'Payment Information',
        product_line: 'n/a',
        order_type: 'Acquisition'
    };
    $(document).ready(function(){
        if($('#deliveryError').val()!=""){            
            alert($('#deliveryError').val());
            $('#paymentForm').attr('action', 'deliv.jsp');
            $('#paymentForm').submit();
        }
        document.title = "<%=libelle_msg(Etn, request, "Mode de paiement")%> | "+document.title;
        pageTrackingWithProducts();
    	var hostUrl = window.location.protocol + '//' + window.location.host;
    	$('#hostUrl').val(hostUrl);
        
        $('.buyall').on('click touch',function(){
            trackConfirmOrderClick();
            
            var paymentMethodField = $('input[name=payment_method]:checked');
            if(paymentMethodField.length==0){
                $(document).scrollTop(0);
                return;
            }
            else if(paymentMethodField.val()=="credit_card"){
                $('#paymentForm').attr('action', 'paymentPageCredit.jsp');
                //$("#recapForm").submit();
            }
            else if(paymentMethodField.val()=="orange_money"){
                $('#paymentForm').attr('action', 'paymentPage.jsp');
                //$("#recapForm").submit();
            }
            else if(paymentMethodField.val()=="orange_money_obf"){
                $('#paymentForm').attr('action', 'paymentPageOrange.jsp');
                //$("#recapForm").submit();
            }
            else if(paymentMethodField.val()=="paypal"){
                $('#paymentForm').attr('action', 'paymentPagePaypal.jsp');
                //$("#recapForm").submit();
            }
            else $('#paymentForm').attr('action', 'completion.jsp');
            updateCheckout();
        });
        
        $('input[name=payment_method]').change(function() {
            if(typeof dataLayer !== 'undefined' && dataLayer != null) 
            {
                var newDlObj = cloneObject(_etn_dl_obj);

                var tempObject = {
                    event: "standard_click",
                    event_action: "button_click",
                    event_category: "payment_method",
                    event_label: $(this).val()}; // event tracking

                for(var key in tempObject){
                    newDlObj[key] = tempObject[key];
                }

                dataLayer.push(newDlObj);     
            }
        });
        
    <%if(payment_error.equals("1")){%>
        $("#paymentError").modal("toggle");
        trackErrorPopupLoad();        
    <%}%>
    });
    
    function trackConfirmOrderClick(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);

            var tempObject = {
                event: "standard_click",
                event_action: "choice_click",
                event_category: "payment_method",
                event_label: "confirm_order"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);     
        }
    }

    function pageTrackingWithProducts(){        
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                page_name: 'payment',
                shipping_type: deliveryDisplayName
            }; // page tracking 
            
            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }
            
            for(var key in datalayerCommonVariables){
                newDlObj[key] = datalayerCommonVariables[key];
            }
            
            var productsObject = objectFromArray(refitKeysArray(recapDatalayerProducts));
            for(var key in productsObject){
                newDlObj[key] = productsObject[key];
            }
            dataLayer.push(newDlObj);           
            
            tempObject = {"event": "checkout",
                            event_action: "",
                            event_category: "",
                            event_label: "", "shipping_type": deliveryDisplayName,"ecommerce": {"checkout": {"actionField": {"step": 4, "option": "Payment Information"}, "products": recapDatalayerProducts}}};; // ecommerce tracking
            
            for(var key in datalayerCommonVariables){
                tempObject[key] = datalayerCommonVariables[key];
            }
            dataLayer.push(tempObject);   
        }
    }
    
    function updateCheckout(){
        var form = $('#paymentForm');
        var formData = new FormData(form.get(0));
		showLoader();
        $.ajax({
            type :  'POST',
            url :   '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>calls/updatecheckout.jsp',
            data :  formData,
            dataType : "json",
            cache : false,
            contentType: false,
            processData: false
        })
        .done(function(resp) {
            if(resp.status == 1){
                $('#paymentForm').submit();
            }
            else{
                alert(resp.message);
            }
        })
        .fail(function(resp) {			
             alert("Error in contacting server.Please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }
    
    function trackErrorPopupLoad(){        
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);

            var tempObject = {
                page_name: 'popin_technical_error'
            }; // page tracking 

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            for(var key in datalayerCommonVariables){
                newDlObj[key] = datalayerCommonVariables[key];
            }
            dataLayer.push(newDlObj);       

            tempObject = {"event": "popupTechnicalError",
                            event_action: "",
                            event_category: "",
                            event_label: "","ecommerce": {"popup": {"products": recapDatalayerProducts}}};; // ecommerce tracking

            for(var key in datalayerCommonVariables){
                tempObject[key] = datalayerCommonVariables[key];
            }
            dataLayer.push(tempObject); 
        }
    }
    
    function trackReturnToPaymentClick(){        
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);

            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: "popin_technical_error",
                event_label: "back_payment"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);     
        }
    }

	function showLoader(msg, ele){

		if(typeof ele === "undefined") ele = $('body');

		ele.addClass('loading2');

		$(ele).find('div.loading2msg').remove();
		var msgEle = $('<div>').addClass('loading2msg');
		$(ele).append(msgEle);

		if(typeof msg !== 'undefined'){
			msgEle.html(msg);
		}
		else{
			msgEle.html("");
		}

	}

	function hideLoader(){
		$('.loading2').removeClass('loading2');
	}

</script>
</body>
</html>
