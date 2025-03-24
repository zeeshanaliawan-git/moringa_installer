<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="java.security.MessageDigest,java.security.NoSuchAlgorithmException" %>
<%@ page import="com.etn.asimina.util.*, com.etn.asimina.cart.*, com.etn.asimina.beans.*, java.text.SimpleDateFormat" %>


<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>

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

	String dbSessionToken = CartHelper.getSessionToken(Etn, session_id, ___loadedsiteid);
	if(!sessionToken.equals(dbSessionToken))
	{
		response.sendRedirect("cart.jsp?muid="+___muuid);
		return;
	}
	
	Cart cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid, true);
	if(cart.isEmpty())
	{		
		response.sendRedirect(cart.getError(CartError.EMPTY_CART).getReturnUrl());
		return;
	}
	
	String identityId = parseNull(cart.getProperty("identityId"));
	String email  = parseNull(cart.getProperty("email"));

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
	
	//as are handling near to impossible case where client id was in session but was not found in db so we can land here again after client_id.length() > 0 if
	if(client_id.length() == 0)
	{
		Set rsClient = Etn.execute("select * from clients where site_id = "+escape.cote(___loadedsiteid)+" and email="+escape.cote(email));
		if(rsClient.next())
		{
			client_id = rsClient.value("id");
			client_uuid = rsClient.value("client_uuid");
		}
	}

	CartError cErr = CartHelper.checkFraud(Etn, ___loadedsiteid, ___muuid, client_id, cart.getProperty("cart_type"), CartHelper.loadFraudRuleColumns(Etn, request, cart));
	if(cErr != null)//fraud detected and logged in db
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"error_fraud.jsp?muid="+___muuid+"&_tm="+System.currentTimeMillis());
		return;		
	}

	SimpleDateFormat orderf = new SimpleDateFormat("yyMM");
	Date date = new Date();

	String transRef = orderf.format(date)+(Math.random()+"").substring(2,10);

	String orderid = "";
	String paymentType = "credit_card";
	String KEY = "a6f41314c7a3482836268cf504b066e08216e40f";
	String phrase = orderid + paymentType + "OK" + KEY;
	String calculatedHash = PortalHelper.hashMe(phrase);

	String successUrl = "";
	String failureUrl = "";
	String cancelUrl = "";
	String genericUrl = "";
	/*while(rs.next()){
		if(rs.value("id").equals("credit_card_successUrl")) successUrl = rs.value("url")+orderid;
		else if(rs.value("id").equals("credit_card_failureUrl")) failureUrl = rs.value("url")+orderid;
		else if(rs.value("id").equals("credit_card_cancelUrl")) cancelUrl = rs.value("url");
		else if(rs.value("id").equals("credit_card_genericUrl")) genericUrl = rs.value("url");
	}*/
	
	Set rsDomain = Etn.execute("Select domain from sites where id = " + escape.cote(_menuRs.value("site_id")));
	rsDomain.next();
	Map<String, String> gtmScriptCode = getGtmScriptCodeForCart(Etn, _menuRs.value("id"), rsDomain.value(0)+com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"paymentPageCredit.jsp", "funnel", "", "", "",client_uuid,"","",(logged?"yes":"no"), "");
	
	String __cartmenuid = _menuRs.value("id");				
	
	//reset session token in db for next screen
    String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);
	
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
    <style>
 .js-focus-visible body{
          height:auto;
      }
      
      .etnhf-gray-footer{
          display: none;
      }
     </style>
</head>
<body class="isWithoutMenu">
<%=parseNull(gtmScriptCode.get("NOSCRIPT_SNIPPET"))%>
<%=_headerHtml%>

<%@ include file="stepbar.jsp"%>

        
<div class="container-lg TunnelPayment">
    <h2 class="TunnelMainTitle"><%=libelle_msg(Etn, request, "Carte bancaire")%></h2>

    <div class="row">
        <div class="col-12">

            <form name="myform" id='myform' action="completion.jsp" method="post" class="FormValidator PaymentForm row justify-content-between"
                  data-messages='{"required":"<%=escapeCoteValue(libelle_msg(Etn, request, "Ce champ est requis."))%>", "regex":"<%=escapeCoteValue(libelle_msg(Etn, request, "Ce champ est non valide."))%>", "confirm":"<%=escapeCoteValue(libelle_msg(Etn, request, "Veuillez saisir deux fois la même valeur."))%>"}'>
            <input type="hidden" name="session_token" value="<%=escapeCoteValue(uuidSessionToken)%>">
            <input type='hidden' name='transaction_code' value="<%=escapeCoteValue(transRef)%>" />
                <div class="col-lg-5">
                    <div class="form-group">
                        <label for="paiement-cb-nom-carte" class="is-required"><%=libelle_msg(Etn, request, "Nom de la carte")%></label>
                        <input type="text" class="form-control isPristine" id="paiement-cb-nom-carte"
                               name="paiement-cb-nom-carte" required data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le nom est requis."))%>">
                        <div class="invalid-feedback"></div>
                    </div>

                    <div class="form-group">
                        <label for="paiement-cb-num-carte" class="is-required"><%=libelle_msg(Etn, request, "Numéro de la carte")%></label>
                        <input type="tel" class="form-control isPristine" id="paiement-cb-num-carte"
                               name="paiement-cb-num-carte" maxlength="16" placeholder="1234123412341234" required
                               data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro est requis."))%>" data-regex="/^\d{4}?\d{4}?\d{4}?\d{4}$/"
                               data-regex-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro n'est pas valide."))%>">
                        <div class="invalid-feedback"></div>
                    </div>

                    <div class="row">

                        <div class="form-group col-8">
                          <label for="paiement-cb-expire-date" class="is-required"><%=libelle_msg(Etn, request, "Date d'expiration")%></label>
                          <div class="row no-gutters">
                              <div class="col-6">
                                  <input type="tel" class="form-control isPristine" id="paiement-cb-expire-date" name="paiement-cb-expire-date" maxlength="2" required data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "La date est requise."))%>" data-regex="/^(0[1-9]|1[0-2])$/"
                                         data-regex-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro n'est pas valide."))%>" placeholder="<%=escapeCoteValue(libelle_msg(Etn, request, "MM"))%>">
                          <div class="invalid-feedback"></div>
                              </div>
                              <div class="col-6">
                                  <input type="tel" class="form-control isPristine" id="paiement-cb-expire-date2" name="paiement-cb-expire-date2" maxlength="2" required data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "La date est requise."))%>" data-regex="/^\d{2}$/"
                                         data-regex-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro n'est pas valide."))%>" placeholder="<%=escapeCoteValue(libelle_msg(Etn, request, "AA"))%>">
                          <div class="invalid-feedback"></div>
                                  
                              </div>
                          </div>
                        </div>

                        <div class="form-group col-4">
                            <label for="paiement-cb-cvc" class="is-required"><%=libelle_msg(Etn, request, "CVC / CVV")%></label>
                            <div class="input-group mb-3">
                                <input type="tel" class="PaymentForm-ccv form-control isPristine" id="paiement-cb-cvc" name="paiement-cb-cvc" placeholder="123" maxlength="3" required data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro est requis."))%>" data-regex="/^[0-9]{3}$/" data-regex-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro n'est pas valide."))%>">
                                <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Numéro CVC / CVV non valide")%></div>
                            </div>
                        </div>

                    </div>
                </div>


                <div class="StickySidebar col-lg-4" data-sticky-options='{"startTrigger": 20}'>
                    <div class="StickySidebar-content BasketSummary">                    
                        <jsp:include page="../calls/getRecap.jsp">
                            <jsp:param name="site_id" value="<%=escapeCoteValue(___loadedsiteid)%>"/>
                            <jsp:param name="lang" value="<%=escapeCoteValue(_lang)%>"/>
                            <jsp:param name="summaryType" value="basket"/>
							<jsp:param name="menu_id" value="<%=escapeCoteValue(__cartmenuid)%>"/>							
                        </jsp:include>
                        <button type="button" onclick="acceptPayment();" class="btn btn-primary full-btn-mobile JS-FormValidator-submit">
                            <%=libelle_msg(Etn, request, "Valider le paiement")%>
                        </button>
                    </div>
                </div>

            </form>

        </div>
    </div>


</div>

<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="star_sprite">
    <symbol id="icon-star" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.ast0{fill-rule:evenodd;clip-rule:evenodd;fill:#f16e00}</style><path
            id="aFill-1" class="ast0" d="M15 3l-3.8 8L2 12.6l6.9 6.1L6.6 28l8.4-4.6 8.4 4.6-2.3-9.3 6.9-6.1-9.2-1.6z"/></symbol>
    <symbol id="icon-star-empty" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.bst0{fill-rule:evenodd;clip-rule:evenodd;fill:#ccc}</style>
        <path id="bFill-1" class="bst0"
              d="M15 3l-3.8 8L2 12.6l6.9 6.1L6.6 28l8.4-4.6 8.4 4.6-2.3-9.3 6.9-6.1-9.2-1.6z"/></symbol>
    <symbol id="icon-star-half" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.cst0,.cst1{fill-rule:evenodd;clip-rule:evenodd;fill:#ccc}.cst1{fill:#f16e00}</style>
        <path class="cst0" d="M28 12.6L18.8 11 15 3v20.4l8.4 4.6-2.3-9.3z"/>
        <path class="cst1" d="M15 23.4V3l-3.8 8L2 12.6l6.9 6.1L6.6 28z"/></symbol>
</svg>
<script>
    
</script>
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
<%=_footerHtml%>

<%=_endscriptshtml%>

<script>
    var datalayerCommonVariables = {
        funnel_name: 'funnel',
        funnel_step: 'Step 3',
        funnel_step_name: 'Payment Information',
        product_line: 'n/a',
        order_type: 'Acquisition'
    };
    
    jQuery(document).ready(function(){
        document.title = "<%=libelle_msg(Etn, request, "Carte bancaire")%> | "+document.title;
        jQuery('#paiement-cb-num-carte').on('input',function(){
            onNumberInput(this);
        });
        jQuery('#paiement-cb-expire-date').on('input',function(){
            onNumberInput(this);
        });
        jQuery('#paiement-cb-expire-date2').on('input',function(){
            onNumberInput(this);
        });
        jQuery('#paiement-cb-cvc').on('input',function(){
            onNumberInput(this);
        });
    });
    
    function trackConfirmOrderClick(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);

            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: "payment_method",
                event_label: "validate_order"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);           

            tempObject = {"event": "validatePayment",
                            event_action: "",
                            event_category: "",
                            event_label: "","ecommerce": {"validate": {"products": recapDatalayerProducts}}};; // ecommerce tracking

            for(var key in datalayerCommonVariables){
                tempObject[key] = datalayerCommonVariables[key];
            }
            dataLayer.push(tempObject);   
        }
    }

    function acceptPayment(){
        trackConfirmOrderClick();
        
        if(jQuery("input[name=paiement-cb-num-carte]").val()=="0000000000001234"){
            $("#myform").submit();
        }
        else{
            $('#myform').attr('action', 'error_server.jsp');
            $("#myform").submit();
        }
    }

    function cancelPayment(){
        $('#myform').attr('action', 'payment.jsp');
        $("#myform").submit();
    }
    
    function onNumberInput(input){
        input = $(input);

        var start = input.get(0).selectionStart;
        var end = input.get(0).selectionEnd;

        var val = input.val();
        var initLength = val.length;
        val = val.trimLeft()
                     .replace(/[^0-9]/g,'');
        input.val(val);
        //preserving cursor position
        var curLength = input.val().length;
        if(curLength != initLength){
            var lengthDiff = initLength - curLength;
            input.get(0).setSelectionRange(start -lengthDiff, end-lengthDiff);
        }
        else{
            input.get(0).setSelectionRange(start, end);
        }
    }
    </script>
</body>
</html>
