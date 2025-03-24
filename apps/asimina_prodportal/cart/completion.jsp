<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*, org.json.*"%>

<%@ include file="common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>


<%
    int stepNumber = 4;
    boolean isCart = false;
    boolean isRecap = false;
    boolean isCompletion = true;
	String _error_msg = "Some error occurred while processing cart";

	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "cart";

	String ___muuid = CartHelper.getCartMenuUuid(request);
	String session_id = CartHelper.getCartSessionId(request);

%>
<%@ include file="../logofooter.jsp"%>
<%
	String dbSessionToken = CartHelper.getSessionToken(Etn, session_id, ___loadedsiteid);
    if(!parseNull(request.getParameter("session_token")).equals(dbSessionToken)){

        response.sendRedirect("cart.jsp?muid="+___muuid);
      	return;
    }
	
	LanguageHelper languageHelper = LanguageHelper.getInstance();
 
	boolean logged = com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request);
	
	Cart cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid);

	Map<String, String> cartResp = CartHelper.insertOrder(Etn, request, cart, PortalHelper.parseNull(request.getParameter("parentId")), PortalHelper.parseNull(request.getParameter("transaction_code")), null);
	int _status = parseNullInt(cartResp.get("status"));
	if(_status > 0)
	{
		response.sendRedirect(cartResp.get("returnUrl"));
		return;
	}

	//if the order was inserted from some other screen this flag will be false here
	boolean newInserted = "true".equalsIgnoreCase(cartResp.get("newInserted"));
	com.etn.util.Logger.info("completion.jsp", "newInserted::"+newInserted);
	
	String orderId = cartResp.get("orderId");
	Set rsOrder = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".orders where id = "+escape.cote(orderId));
	rsOrder.next();
	String clientId = rsOrder.value("client_id");
	String orderRef = rsOrder.value("orderRef");
	//load the client associated to order
	Set rsClient = Etn.execute("select * from clients where id = "+escape.cote(clientId));
	String client_uuid = "";
	if(rsClient.next())
	{
		client_uuid = rsClient.value("client_uuid");
	}
	
	boolean needPaymentVerification = false;
	if(rsOrder.value("spaymentmean").equalsIgnoreCase("paypal") && rsOrder.value("payment_status").equalsIgnoreCase("verify_payment")) needPaymentVerification = true;

    JSONArray recapDatalayerProducts = new JSONArray();

	int totalQuantity = 0;
    for(CartItem item : cart.getItems())
	{
		boolean stock_error = false;//always setting to false as completion will not happen if there is stock error
        JSONObject recapDatalayerProduct = new JSONObject();
		ProductVariant pVariant = item.getVariant();
		        
        int qty = parseNullInt(item.getProperty("quantity"));
		totalQuantity += qty;

		recapDatalayerProduct.put("name", pVariant.getProductName());
		recapDatalayerProduct.put("brand",languageHelper.getTranslation(Etn,parseNull(pVariant.getBrandName())));
		recapDatalayerProduct.put("id", pVariant.getSku());
		recapDatalayerProduct.put("price", pVariant.getUnitPrice());
		recapDatalayerProduct.put("category", pVariant.getProductType());
		recapDatalayerProduct.put("variant", pVariant.getVariantName());
		recapDatalayerProduct.put("position", recapDatalayerProducts.length()+1);
		recapDatalayerProduct.put("quantity", qty);
		recapDatalayerProduct.put("stock",(stock_error?"no":"yes"));
		recapDatalayerProduct.put("stock_number", pVariant.getVariantStock());
		recapDatalayerProduct.put("product_id", pVariant.getProductId());
		recapDatalayerProducts.put(recapDatalayerProduct);		
    }
	
	boolean showamountwithtax = cart.isShowAmountWithTax();
	String priceformatter = cart.getPriceFormatter();
	String roundto = cart.getRoundTo();
	String showdecimals = cart.getShowDecimals();
	String defaultcurrency = cart.getDefaultCurrency();
	
    Set rsDomain = Etn.execute("Select domain from sites where id = " + escape.cote(_menuRs.value("site_id")));
    rsDomain.next();
    Map<String, String> gtmScriptCode = getGtmScriptCodeForCart(Etn, _menuRs.value("id"), rsDomain.value(0)+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"cart/completion.jsp", "completion", "", "", "",client_uuid,"","",(logged?"yes":"no"), "");
	
	
	String _titleText = (newInserted?"Votre commande est confirmée":"Votre commande est confirmée");	
	String _emailText = (newInserted?"Un email récapitulant votre commande vous a été envoyé.":"Un email récapitulant votre commande vous a été envoyé.");
	
	if(needPaymentVerification)
	{
		_titleText = "Votre commande est terminée mais nécessite une vérification de paiement.";
		_emailText = "Un email résumant vos articles vous sera envoyé dès que le paiement sera vérifié.";
	}

	//delete the cart from db
	CartHelper.cleanup(Etn, cart);
        	
%>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
  <head>
      <%=parseNull(gtmScriptCode.get("SCRIPT_SNIPPET"))%>
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css">
<%=_headhtml%>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/bootstrap.js"></script>
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

<div id="fb-root"></div>
<script async defer crossorigin="anonymous" src="https://connect.facebook.net/fr_FR/sdk.js#xfbml=1&version=v5.0"></script>

<div class="MainOverlay"></div>

<article class="container-lg TunnelNotice">
    <div class="TunnelNotice-titleContainer">
        <span class="TunnelNotice-icon" data-svg="/src/assets/icons/icon-valid.svg"></span>
        <h3 class="TunnelNotice-title"><%=languageHelper.getTranslation(Etn, _titleText)%></h3>
    </div>

    <div class="TunnelNotice-bodyContainer">
        <img class="TunnelNotice-image" alt="" src="/src/assets/images/placeholder-success.png"/>

        <div class="TunnelNotice-contentContainer">
            <p class="TunnelNotice-textBold">
                <%=languageHelper.getTranslation(Etn, _emailText)%>
                <%=languageHelper.getTranslation(Etn, (newInserted?"Vérifiez vos spams":"Vérifiez vos spams"))%>
            </p>
            <p class="TunnelNotice-textBold"><%=languageHelper.getTranslation(Etn, "Numéro de la commande")%> : <%=orderRef%></p>

            <p class="TunnelNotice-text"><%=languageHelper.getTranslation(Etn, "Redirection automatiquement vers la page d’accueil de notre site dans 30 secondes.")%></p>

            <a href="#" class="btn btn-primary isFullWidthMobile TunnelNotice-button" onclick="__gotoPortalHome();"><%=languageHelper.getTranslation(Etn, "Retourner sur la page d'accueil")%></a>
        </div>
    </div>
</article>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bundle.js"></script>
    <%=_footerHtml%>

    <%=_endscriptshtml%>    
    <script>
        var datalayerCommonVariables = {
            product_sold: <%=totalQuantity%>,
            revenue: '<%=PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotal()+"", true)%>',
            currency_code: '<%=defaultcurrency%>',
            order_id: '<%=orderRef%>',
            tax: '<%=PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getTotalTax()+"", true)%>',
            shipping_cost: '<%=PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getShippingFees()+"", true)%>',
            shipping_type: '<%=cart.getDeliveryDisplayName()%>',
            funnel_name: 'funnel',
            funnel_step: 'Purchase',
            funnel_step_name: 'Order Confirmation',
            product_line: 'n/a',
            order_type: 'Acquisition',
            acquisition_retention_type: 'n/a'
        };
        var recapDatalayerProducts = <%=recapDatalayerProducts.toString()%>;
        $(document).ready(function(){
            document.title = "<%=languageHelper.getTranslation(Etn, "Commande confirmée")%> | "+document.title;
            pageTrackingWithProducts();
            //deleteCookie('<%=com.etn.beans.app.GlobalParm.getParm("CART_COOKIE")%>');
            setTimeout(function(){ __gotoPortalHome(); }, 30000);
            //if(opener!=null) opener.refreshCalendar();
        });						

        function pageTrackingWithProducts()
		{
            if(typeof dataLayer !== 'undefined' && dataLayer != null) 
            {
                var newDlObj = cloneObject(_etn_dl_obj);
                var tempObject = {
                    page_name: 'order_confirmation'
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

                tempObject = {
                            event_action: "",
                            event_category: "",
                            event_label: "",
                            "ecommerce": {"purchase": {
                                "actionField": {
                                    step: 5, 
                                    option: "Order Confirmation",
                                    id: '<%=orderRef%>',
                                    revenue: '<%=PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotal()+"", true)%>',
                                    tax: '<%=PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getTotalTax()+"", true)%>',
                                    shipping: '<%=PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getShippingFees()+"", true)%>',
                                    coupon: '<%=(cart.isPromoApplied()?cart.getProperty("promo_code"):"")%>',
                                    shipping_type: '<%=cart.getDeliveryDisplayName()%>',
                                    product_sold: <%=totalQuantity%>,
                                    currency_code: '<%=defaultcurrency%>',
                                    funnel_name: 'funnel',
                                    funnel_step: 'Purchase',
                                    funnel_step_name: 'Order Confirmation',
                                    product_line: 'n/a',
                                    order_type: 'Acquisition',
                                    acquisition_retention_type: 'n/a'
                                }, "products": recapDatalayerProducts}}};; // ecommerce tracking
            
                dataLayer.push(tempObject);   
            }
        }
        
        function tunnelExitInit(){ // just to avoid error as it is called from logofooter
            
        }

    </script>
  </body>
</html>
