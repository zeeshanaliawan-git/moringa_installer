<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64, org.json.*"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*"%>


<%@ include file="common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>

<%
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "cart";

    boolean isCart = true;
    boolean isRecap = false;
    boolean isCompletion = false;
	String _error_msg = "Some error occurred while processing cart";

	String cartCookieName = com.etn.beans.app.GlobalParm.getParm("CART_COOKIE");

	String session_id = parseNull(request.getParameter("sid"));

	if(session_id.length()>0)
	{
		Cookie __cartCookie = new javax.servlet.http.Cookie(cartCookieName, session_id);
		__cartCookie.setMaxAge(24*7*60*60);
		__cartCookie.setPath(com.etn.beans.app.GlobalParm.getParm("PORTAL_LINK"));
		response.addCookie(__cartCookie);
	}
	else
	{
		session_id = CartHelper.getCartSessionId(request);
	}

%>
<%@ include file="../headerfooter.jsp"%>
<%
	Set rsDomain = Etn.execute("Select domain, enable_ecommerce from sites where id = " + escape.cote(___loadedsiteid));
	rsDomain.next();
	String _domain = parseNull(rsDomain.value("domain"));
	if("1".equals(rsDomain.value("enable_ecommerce")) == false)
	{
		response.sendRedirect("ecommerceerror.jsp?muid="+___muuid);
		return;
	}

	LanguageHelper languageHelper = LanguageHelper.getInstance();

	Set rsSp = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id = "+escape.cote(___loadedsiteid));
	rsSp.next();

	String langId = "1";
	Set rsL = Etn.execute("select * from language where langue_code = "+escape.cote(_lang));
	if(rsL.next()) langId = rsL.value("langue_id");
	String saveCartText = parseNull(rsSp.value("lang_"+langId+"_save_cart_text"));
	if(saveCartText.length() == 0)
	{
		saveCartText = languageHelper.getTranslation(Etn, "Vos coordonnées seront exclusivement utilisées dans le cadre du service « sauvegarder votre panier » par Orange et ne seront pas utilisées à d’autres fins.");
	}

	String cachedResourcesFolder = getCachedResourcesUrl(Etn, _menuRs.value("id"));
	String __cartcommonmenuid = _menuRs.value("id");

	String removeItem = parseNull(request.getParameter("removeItem"));
	String updateItem = parseNull(request.getParameter("updateItem"));
	String updateType = parseNull(request.getParameter("updateType"));


	if(removeItem.length() > 0) 
	{
		CartHelper.removeItem(Etn, removeItem);
	}
	if(updateItem.length() > 0)
	{
		CartHelper.updateItem(Etn, updateItem, updateType, PortalHelper.parseNullInt(updateType));
	}

	//generate a token and put in session to compare on next login attempt
	String logintoken = java.util.UUID.randomUUID().toString();
	com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "logintoken2", logintoken);

	String client_id = "";
	boolean logged = false;
	String client_uuid = "";
	boolean isSuperUser = false;
	Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	if(client != null)
	{
		logged = true;
		client_id = client.getProperty("id");
		client_uuid = client.getProperty("client_uuid");
		isSuperUser = "1".equals(client.getProperty("is_super_user"));
	}

	//only if promo code is coming in request
	if(request.getParameter("promoCode") != null)
	{
		String promoCode = parseNull(request.getParameter("promoCode"));
		//this value will be used later by CartHelper
		Etn.executeCmd("update cart set promo_code = "+escape.cote(promoCode) + " where session_id = "+escape.cote(session_id)+" and site_id = " +escape.cote(___loadedsiteid));
	}

	//reset delivery_method, delivery_type and payment_method whenever user comes back to cart.jsp
	//otherwise they effect the calculations
	//we this is causing some bug in which case delivery/payment methods in orders table is empty
//	Etn.executeCmd("update cart set delivery_type = '', delivery_method = '', payment_method = '' where session_id = "+escape.cote(session_id)+" and site_id = " +escape.cote(___loadedsiteid));
	
	//first false is not to delete low stock .. second true is to reload voucher from external api if required
	Cart cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid, false, true);

	//we have a case where the orange money payment was done which sets the order_uuid in cart table
	//and the user did not go back to completion.jsp which actually cleansup the completed cart
	//this lead to a bug where same cart was used by the user next time and after the next payment new 
	//order was not inserted as the cart table already had order_uuid filled and the CartHelper class checks
	//if order_uuid already exists in cart then not to insert new order which is a valid case
	//so we are going to cleanup the cart here in case order_uuid is already filled which in ideal conditions should not happen
	//and we will also do same in load cart ajax call
	if(parseNull(cart.getProperty("order_uuid")).length() > 0)
	{
		com.etn.util.Logger.error("****************************************************************************************");
		com.etn.util.Logger.error("cart.jsp","Order uuid is already filled for cart which means this cart was successfully checked-out but user did not go back to completion page after making payment on external site. We must cleanup the cart now");
		com.etn.util.Logger.error("****************************************************************************************");
		CartHelper.cleanup(Etn, cart);
		cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid);
	}

	if(cart.isEmpty())
	{
		response.sendRedirect(cart.getError(CartError.EMPTY_CART).getReturnUrl());
		return;
	}
	
	if(cart.hasError() && cart.getError(CartError.DELIVERY_ERROR) != null)
	{
		//its a delivery error, we must clear the delivery related fields otherwise we cannot proceed further as load cart will remove delivery error on next step
		Etn.executeCmd("update cart set delivery_type = '', delivery_method = '' where id = "+escape.cote(cart.getProperty("id")));
		//reload cart to be on safe side
		cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid, false, true);
	}
		
	Etn.executeCmd("update cart set visited_cart_page = 1, ip = "+escape.cote(PortalHelper.getIP(request))+" where id = "+cart.getProperty("id"));

	Map<String, String> gtmScriptCode = getGtmScriptCodeForCart(Etn, _menuRs.value("id"), _domain+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"cart/cart.jsp", "cart", "", "", "",client_uuid,"","",(logged?"yes":"no"), "");


	String checkoutPage = "checkout.jsp";

    String currecyPosition = PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid, langId);


	boolean promoCodeApplicableOnShipping = false;
	if(PortalHelper.parseNull(cart.getProperty("promo_code")).length() > 0 && cart.hasPromoError() == false)
	{		
		//if coupon code is applicable on delivery fee we have to show the message to customer
		Set rsP = Etn.execute("select cp.discount_type, cp.discount_value "+
						" from "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion_coupon cpc "+
						" join "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion cp on cp.id = cpc.cp_id and cp.site_id = "+escape.cote(cart.getProperty("site_id"))+" and cp.element_on = 'shipping_fee' "+
						" where cpc.coupon_code = "+escape.cote(PortalHelper.parseNull(cart.getProperty("promo_code"))));
		if(rsP.next())
		{
			promoCodeApplicableOnShipping = true;
		}
	}

%>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
  <head>
      <%=parseNull(gtmScriptCode.get("SCRIPT_SNIPPET"))%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>">
            <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>">
<%=_headhtml%>

    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/search-bundle.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cart.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cookie.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
    <style>
      .js-focus-visible body{
          height:auto;
      }

      .etnhf-gray-footer{
          display: none;
      }

    </style>
    </head>
      <body class="etn-orange-portal--">
          <%=parseNull(gtmScriptCode.get("NOSCRIPT_SNIPPET"))%>
          <div class="overlay terms guest guest-confirm"></div>
          <%=_headerHtml%>
		  <div class="BasketPage">

          <div class="PageTitle isShortHeight">
              <div class="PageTitle-container container-lg">
                  <a class="PageTitle-backBtn d-md-none" href="javascript:__gotoPortalHome();">
                      <span data-svg="/src/assets/icons/icon-angle-left.svg"></span>
                      <%=languageHelper.getTranslation(Etn, "Continuez vos achats")%>
                  </a>

                  <h1 class="display-2"><%=languageHelper.getTranslation(Etn, "Panier")%></h1>
              </div>
      </div>

        <div class="container">
          <form id="cartForm" action="" method="POST" class="FormValidator">
            <input type="hidden" name="lang" value="<%=_lang%>" >
        <p class="font-weight-bold m-0"><%=cart.getArticlesCount()%> <%=languageHelper.getTranslation(Etn, "article(s)")%></p>

        <div class="row justify-content-between">
            <div class="col-12 col-lg-6">
                <section class="mt-5">
              <%

        JSONArray products = new JSONArray();
        JSONArray onlyUnavailableProducts = new JSONArray();
        JSONArray onlyOffers = new JSONArray();
        JSONArray onlyProducts = new JSONArray();

		//we dont have to show payment fee included yet ... this can happen when user selected payment type before
		//and come back to this step again
		double grandTotal = cart.getGrandTotal()-cart.getShippingFees()-cart.getPaymentFees();
		double grandTotalWT = cart.getGrandTotalWT()-cart.getShippingFees()-cart.getPaymentFees();

		for(CartItem cartItem : cart.getItems())
		{
			String cartItemId = cartItem.getProperty("id");			
			int qty = PortalHelper.parseNullInt(cartItem.getProperty("quantity"));

			ProductVariant pVariant = cartItem.getVariant();

			JSONObject product = new JSONObject();
			product.put("name",pVariant.getProductName());
			product.put("brand", languageHelper.getTranslation(Etn, PortalHelper.parseNull(pVariant.getBrandName())));
			product.put("id",pVariant.getSku());
			product.put("price",pVariant.getUnitPrice()); // this price is with quantity 1, and can be with or without tax depending on flag.
			product.put("category",pVariant.getProductType());
			product.put("variant",pVariant.getVariantName());
			product.put("position", cartItem.getPosition() + 1);//we start position with 0 but gtm takes starting from 1
			product.put("quantity", qty);
			product.put("stock",cartItem.isAvailable()?"yes":"no");
			product.put("stock_number",pVariant.getVariantStock());
			product.put("product_id", pVariant.getProductId());
			products.put(product);

			String productName = languageHelper.getTranslation(Etn, PortalHelper.parseNull(pVariant.getBrandName())) + " " + pVariant.getProductName();

if(cartItem.isAvailable())
{
	if(PortalHelper.isOffer(pVariant.getProductType()))
	{
		onlyOffers.put(product);
	}
	else
	{
		onlyProducts.put(product);
	}
%>
<article class="ProductItem font-weight-bold flex-wrap pb-4 mb-2">
    <div class="d-flex align-items-start">
        <div class="ProductItem-imageWrapper">
            <div class="Image-ratio43">
                <div class="Image-wrapper">
                    <img class="d-block mb-3" src='<%=escapeCoteValue(pVariant.getImageUrl())%>' alt='<%=escapeCoteValue(pVariant.getImageAlt())%>'>
                </div>
            </div>
        </div>
        <div class="ProductItem-content pl-2 pl-lg-3 w-100">
            <div class="row">
                <header class="ProductItem-header col-12 col-lg-6">
                    <h3 class="ProductItem-title font-weight-bold mb-2">
                         <input type="hidden" name="id" value="<%=escapeCoteValue(pVariant.getVariantId())%>" >
                         <a href="<%=pVariant.getProductUrl()%>" style="text-decoration: underline"><%=productName%> <sup class="ProductItem-legals"><%=(cart.getTaxNumbers().containsKey(pVariant.getTaxPercentage().tax+"")?" ("+cart.getTaxNumbers().get(pVariant.getTaxPercentage().tax+"")+")":"")%></sup></a>
                    </h3>
                        <%
                        if(cartItem.hasFrequency()){
                        %>
                    <p class="mb-2">
                        <%
                        if(pVariant.getDuration() == 0){
                    %>
                    <%=languageHelper.getTranslation(Etn, "Sans engagement")%>
                    <%
                    }
                    else{
                    %>
                    <%=languageHelper.getTranslation(Etn, "Engagement")+" "+pVariant.getDuration()+" "+pVariant.getCurrencyFreq()%>
                    <%
                    }
                    %>
                        </p>
                        <%}
                        %>
                    <p class="mb-2 font-weight-normal">
                    <%
                    for(int i=0; i<pVariant.getAttributes().length(); i++){
						String _attribName = pVariant.getAttributes().getJSONObject(i).optString("name", "");
						if(_attribName.equalsIgnoreCase("Commitment")) continue; // we not show commitment as part of attributes list as we already showing that in the price info
						String _attribValue = pVariant.getAttributes().getJSONObject(i).optString("label", "");
						if(_attribValue.length() == 0) _attribValue = pVariant.getAttributes().getJSONObject(i).getString("value");
                    %>
                    <span class="d-block font-weight-normal"><%=languageHelper.getTranslation(Etn, _attribValue)%></span>
                    <%}%>
                    </p>
                </header>
                <div class="col-12 col-lg-6">
                    <%
                    if(pVariant.getProductType().equals("offer_postpaid") == false && pVariant.getFrequency().length() == 0){
                    %>
                    <p class="mb-2">
                             <%if(!pVariant.getFormattedOldPrice().equals(pVariant.getFormattedPrice())) {%>
                             <s><%=pVariant.getFormattedOldPrice()%></s>
                            <%}%>
                        <span class="d-block text-primary">
                            <%=PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid , parseNullInt(langId), pVariant.getFormattedPrice(), cart.getDefaultCurrency())%>
                        </span>
                    </p>
                    <%}
                    else{
                    %>
                    <p class="mb-2">
                        <span class="d-block text-primary">
                            <%=PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid , parseNullInt(langId), pVariant.getFormattedPrice(), cart.getDefaultCurrency()+"/"+pVariant.getCurrencyFreq())%>
                        </span>

                        <%if(!pVariant.getFormattedOldPrice().equals(pVariant.getFormattedPrice())&& pVariant.getDiscountDuration()>0) {%>
                             <span class="d-block font-weight-normal"><%=languageHelper.getTranslation(Etn, "Pendant")%> <%=pVariant.getDiscountDuration()%> <%=pVariant.getCurrencyFreq()%></span>
                             <%if(currecyPosition.equals("before")){%>
                                <span class="d-block font-weight-normal">
                                    <%=languageHelper.getTranslation(Etn, "Puis")%> <%=cart.getDefaultCurrency()%>/<%=pVariant.getCurrencyFreq()%>
                                </span>
                                 <span class="d-block font-weight-normal">
                                    <%=pVariant.getFormattedOldPrice()%>
                                </span>
                            <%}%>
                            <%if(currecyPosition.equals("after")){%>
                                <span class="d-block font-weight-normal">
                                    <%=languageHelper.getTranslation(Etn, "Puis")%> <%=pVariant.getFormattedOldPrice()%>
                                </span>
                                <span class="d-block font-weight-normal">
                                    <%=cart.getDefaultCurrency()%>/<%=pVariant.getCurrencyFreq()%>
                                </span>
                            <%}%>
                        <%}%>
                    </p>
                    <%
                    }
                    %>


                    <%
                    JSONArray tempAdditionalFee;
                    if(pVariant.isShowAmountWithTax()) tempAdditionalFee = pVariant.getAdditionalFee();
                    else tempAdditionalFee = pVariant.getAdditionalFeeWT();
                    for(int i=0; i<tempAdditionalFee.length(); i++){
                        if(parseNullDouble(tempAdditionalFee.getJSONObject(i).getString("price"))==0) continue;
                    %>
                    <p class="mb-2">
                        <%=tempAdditionalFee.getJSONObject(i).getString("name")%>
                        <span class="d-block font-weight-normal">
                            <%= tempAdditionalFee.getJSONObject(i).getString("price_prefix")+PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid , parseNullInt(langId),PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), tempAdditionalFee.getJSONObject(i).getString("price")), cart.getDefaultCurrency())%></span>
                    </p>
                    <%}%>
                </div>
            </div>
            <%
            if(pVariant.getComewith().length()>0)
			{
				for(int i=0; i<pVariant.getComewith().length(); i++)
				{
					JSONObject _comewith = pVariant.getComewith().getJSONObject(i);
					String priceLabel = "";
					if(!_comewith.getString("comewith").equals("label")){
						boolean comewithShowAmountWithTax = _comewith.getBoolean("show_amount_with_tax");
						if(parseNullDouble(_comewith.getJSONObject("variant").optString("price"))<=0)
                            priceLabel = "("+languageHelper.getTranslation(Etn, "gratuit")+")";
						else
						{
							double _priceNoPromo = PortalHelper.parseNullDouble((comewithShowAmountWithTax?_comewith.getJSONObject("variant").optString("original_price"):_comewith.getJSONObject("variant").optString("original_priceWT")));
							double _price = PortalHelper.parseNullDouble((comewithShowAmountWithTax?_comewith.getJSONObject("variant").optString("price"):_comewith.getJSONObject("variant").optString("priceWT")));
							
                            String _formattedPrice =  PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), ""+_price);
							
							String nopromopricelabel = "";
							if(_priceNoPromo != _price)
							{		
								String _formattedNoPromoPrice = PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), ""+_priceNoPromo);
								nopromopricelabel = "<s>"+PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid , parseNullInt(langId), _formattedNoPromoPrice, cart.getDefaultCurrency()) + "</s>"; 
							}
							
                            priceLabel = PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid , parseNullInt(langId), _formattedPrice, cart.getDefaultCurrency()); 
							
							String frequency = "";
							if("offer_postpaid".equals(_comewith.getJSONObject("variant").optString("productType","")) || _comewith.getJSONObject("variant").optString("frequency","").length() > 0)
							{
								frequency = "/" + languageHelper.getTranslation(Etn, _comewith.getJSONObject("variant").optString("frequency",""));
							}
							
							priceLabel = "("+nopromopricelabel+" " + priceLabel + frequency + ")";
                        }
					}
                    %>
					
					<p class="mb-2"><%=_comewith.getString("comewith").equals("gift")?languageHelper.getTranslation(Etn, "Offert"):languageHelper.getTranslation(Etn, "Inclus")%></p>
					<ul class="ProductItem-inclusiveList font-weight-normal">
                            <li><%=(_comewith.getString("comewith").equals("label")?_comewith.getString("title"):_comewith.getString("variantName"))%> <%=priceLabel%>
                            <span onclick="removeComewith('<%=escapeCoteValue(cartItemId)%>', '<%=escapeCoteValue(_comewith.getString("id"))%>')"  aria-label="Supprimer <%=escapeCoteValue(_comewith.getString("title"))%>" class="ProductItem-inclusiveDelete <%=_comewith.getString("type").equals("mandatory")?"d-none":""%>" data-svg="/src/assets/icons/icon-close-btn.svg" >
                    </span></li>
					</ul>
                    <%}%>

            <%}%>

        </div>
    </div>
    <footer class="ProductItem-footer d-flex justify-content-between border-top border-bottom border-light py-1 w-100">
        <button type="button" class="ProductItem-delete btn p-0 funnel-data-layer" aria-label="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Supprimer")+" "+productName+" "+languageHelper.getTranslation(Etn, "du panier"))%>" data-toggle="modal" data-target="#deleteModal" onclick='openDeletionModal("<%=escapeCoteValue(productName, "\"")%>", "<%=escapeCoteValue(cartItemId)%>", <%=escapeCoteValue(product.toString())%>);'
            data-dl_event='standard_click' data-dl_event_category='<%=(pVariant.getProductType().startsWith("offer")?"cart_w_offers":"cart_w_products")%>' data-dl_event_action='button_click' data-dl_event_label='<%=(pVariant.getProductType().startsWith("offer")?"delete":"delete_products")%>'
            data-dl_products='[<%=escapeCoteValue(product.toString())%>]'>
            <span class="d-inline-block ml-1" data-svg="/src/assets/icons/icon-trash.svg"></span>
        </button>
        <div class="QuantityControl" style="<%=((PortalHelper.isOffer(pVariant.getProductType()))?"display:none":"")%>">
            <button type="button" data-id='<%=escapeCoteValue(cartItemId)%>' <%=qty==1?"disabled":""%> class="QuantityControl-removeButton btn p-0 funnel-data-layer" aria-label="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Supprimer une unité de")+" "+productName)%>"
                data-dl_event='standard_click' data-dl_event_category='cart_w_products' data-dl_event_action='button_click' data-dl_event_label='less_quantity'
                data-dl_products='[<%=escapeCoteValue(product.toString())%>]'>
                <span class="d-inline-block" data-svg="/src/assets/icons/icon-remove.svg"></span>
            </button>

            <input type="text" class="product-quantity form-control d-inline-block text-center form-control-plaintext" value="<%=qty%>" data-id='<%=escapeCoteValue(cartItemId)%>' data-limit="<%=CommonPrice.getQuantityLimit(Etn, pVariant.getVariantId(), pVariant.getComewith())%>" aria-describedby="button-addon2" style="width:42px">

            <button type="button" data-id='<%=escapeCoteValue(cartItemId)%>' <%=qty==CommonPrice.getQuantityLimit(Etn, pVariant.getVariantId(), pVariant.getComewith())?"disabled":""%> class="QuantityControl-addButton btn p-0 funnel-data-layer" aria-label="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Ajouter une unité de")+" "+productName)%>"
                data-dl_event='standard_click' data-dl_event_category='cart_w_products' data-dl_event_action='button_click' data-dl_event_label='more_quantity'
                data-dl_products='[<%=escapeCoteValue(product.toString())%>]'>
                <span class="d-inline-block" data-svg="/src/assets/icons/icon-add-2.svg"></span>
            </button>
        </div>
    </footer>
</article>
<%} else {
    onlyUnavailableProducts.put(product);
%>
<div class="d-none outOfStock">
<article class="ProductItem d-flex align-items-start flex-wrap pb-4 mb-2">
  <div class="ProductItem-imageWrapper">
    <div class="Image-ratio43 mb-3">
      <div class="Image-wrapper">
        <img class="d-block" width="68" src="<%=escapeCoteValue(pVariant.getImageUrl())%>" alt="<%=escapeCoteValue(pVariant.getImageAlt())%>">
      </div>
    </div>
  </div>
  <div class="ProductItem-content pl-2 pl-lg-3 mb-2">
    <h3 class="ProductItem-title mb-2">
      <a href="javascript:void(0)" style="text-decoration: underline"><%=productName%></a>
    </h3>
      <%
        for(int i=0; i<pVariant.getAttributes().length(); i++){
			String _attribValue = pVariant.getAttributes().getJSONObject(i).optString("label", "");
			if(_attribValue.length() == 0) _attribValue = pVariant.getAttributes().getJSONObject(i).getString("value");

        %>
        <p class="mb-0"><%=languageHelper.getTranslation(Etn, _attribValue)%></p>
        <%}%>

            <%
            if(pVariant.getComewith().length()>0)
			{
				for(int i=0; i<pVariant.getComewith().length(); i++)
				{
					JSONObject _comewith = pVariant.getComewith().getJSONObject(i);
					String priceLabel = "";
					if(!_comewith.getString("comewith").equals("label")){
						if(parseNullDouble(_comewith.getJSONObject("variant").optString("price"))<=0)
                            priceLabel = "("+languageHelper.getTranslation(Etn, "gratuit")+")";
						else{
                            String _formattedPrice =  PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), (pVariant.isShowAmountWithTax()?_comewith.getJSONObject("variant").optString("price"):_comewith.getJSONObject("variant").optString("priceWT")));

                            priceLabel = "("+ PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid , parseNullInt(langId), _formattedPrice, cart.getDefaultCurrency())+")";
                        }
					}
                    %>
					<p class="mb-2"><%=_comewith.getString("comewith").equals("gift")?languageHelper.getTranslation(Etn, "Offert"):languageHelper.getTranslation(Etn, "Inclus")%></p>
					<ul class="ProductItem-inclusiveList font-weight-normal">
						<li><%=(_comewith.getString("comewith").equals("label")?_comewith.getString("title"):_comewith.getString("variantName"))%> <%=priceLabel%>
						<span onclick="removeComewith('<%=escapeCoteValue(cartItemId)%>', '<%=escapeCoteValue(_comewith.getString("id"))%>')"  aria-label="Supprimer <%=escapeCoteValue(_comewith.getString("title"))%>" class="ProductItem-inclusiveDelete <%=_comewith.getString("type").equals("mandatory")?"d-none":""%>" data-svg="/src/assets/icons/icon-close-btn.svg" >
						</span></li>
					</ul>
                    <%}%>
            <%}%>
  </div>

  <footer class="ProductItem-footer d-flex justify-content-between border-top border-bottom border-light py-1 w-100">
    <button type="button" class="ProductItem-delete btn p-0 funnel-data-layer" aria-label="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Supprimer")+" "+productName+" "+languageHelper.getTranslation(Etn, "du panier"))%>" data-toggle="modal" data-target="#deleteModal" onclick='openDeletionModal("<%=escapeCoteValue(productName, "\"")%>", "<%=cartItemId%>", <%=escapeCoteValue(product.toString())%>);'
            data-dl_event='standard_click' data-dl_event_category='cart_w_products_unavailable' data-dl_event_action='button_click' data-dl_event_label='delete'
            data-dl_products='[<%=escapeCoteValue(product.toString())%>]'>
      <span class="d-inline-block ml-1" data-svg="/src/assets/icons/icon-trash.svg"></span>
    </button>
      <button type="button" class="ProductItem-change btn p-0 funnel-data-layer" aria-label="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Changer")+" "+productName+" "+languageHelper.getTranslation(Etn, "du panier pour un autre produit en stock"))%>"
            data-dl_event='standard_click' data-dl_event_category='cart_w_products_unavailable' data-dl_event_action='button_click' data-dl_event_label='change'
            data-dl_products='[<%=escapeCoteValue(product.toString())%>]'>
      <span class="d-inline-block ml-1" data-svg="/src/assets/icons/icon-reload.svg"></span>
      <u>Changer</u>
    </button>
  </footer>
</article>
</div>
<%}%>
                  <%

              }//end for loop

            %>
                </section>
                <div class="mx-n2 m-lg-0 <%=(cart.hasStockError()==false?"d-none":"")%>">
                    <section id="outOfStockSection" class="bg-x-light w-100 pt-5 pt-lg-4 px-2 px-lg-3">
                        <h3 class="title-2 mb-4"><%=languageHelper.getTranslation(Etn, "Actuellement indisponible")%></h3>
					</section>
                </div>
            </div>
            <div class="StickySidebar col-12 col-lg-4" data-sticky-options='{"startTrigger": 90}'>

           <!-- <div class="col-lg-6"></div> -->
            <%if(cart != null)
			{
            %>
				<div class="BasketSummary StickySidebar-content" style="transform: matrix(1, 0, 0, 1, 0, 39);">
					<div class="BasketSummary-totalPrice d-flex align-items-end">
						<div class="BasketSummary-promoFieldGroup custom-control p-0 pr-1 m-0 w-100">
							<label for="coupon_code" class="w-100">
								<span class="d-inline-block" data-svg="/src/assets/icons/icon-tag-advertising.svg"></span>
								<%=languageHelper.getTranslation(Etn, "Code promo")%>
							</label>
							<input type="text" class="form-control <%=cart.hasPromoError()?"is-invalid":""%>" id="coupon_code" name="promoCode" placeholder="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Entrez votre code"))%>" aria-label="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Entrez votre code"))%>" value="<%=escapeCoteValue(cart.getProperty("promo_code"))%>">

						</div>
						<button id='addPromo' type="button" class="btn btn-secondary funnel-data-layer" data-dl_event='standard_click' data-dl_event_category='cart_w_products' data-dl_event_action='button_click' data-dl_event_label='validate' ><%=languageHelper.getTranslation(Etn, "Valider")%></button>
					</div>
					<%if(cart.hasPromoError()){%>
					<div class="invalid-feedback" id="promoError" style="display:block;">
						<%=cart.getError(CartError.PROMO_ERROR).getMessage()%>
					</div>
					<%}%>
<div class="BasketSummary-totalGroup border-bottom border-dark pb-2 mt-4">
  <div class="TotalPrice">
    <span class="TotalPrice-label"><%=languageHelper.getTranslation(Etn, "Total")%></span><span class="TotalPrice-value"><%=PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), ((cart.isShowAmountWithTax()?grandTotal:grandTotalWT)+cart.getTotalCartDiscount())+"")%></span>
  </div>
  <%
      for(int i=0; i<cart.getCalculatedCartDiscounts().length(); i++)
	  {		 
		  if(cart.getCalculatedCartDiscounts().getJSONObject(i).optString("elementOn","").equals("shipping_fee")) continue;
  %>
  <div class="TotalPrice">
    <span class="TotalPrice-label"><%=(cart.getCalculatedCartDiscounts().getJSONObject(i).getString("couponCode").length()>0?languageHelper.getTranslation(Etn, "Remise code promo")+" « "+cart.getCalculatedCartDiscounts().getJSONObject(i).getString("couponCode")+" »":languageHelper.getTranslation(Etn, "Remise panier"))%></span><span class="TotalPrice-value <%=(!cart.getCalculatedCartDiscounts().getJSONObject(i).getString("elementOn").equals("shipping_fee")?"":"d-none")%>">-<%=PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), cart.getCalculatedCartDiscounts().getJSONObject(i).getString("discountValue"))%></span>
  </div>
  <%}%>
  <%
      if(promoCodeApplicableOnShipping)
	  {		 
  %>
  <div class="">
    <span class="TotalPrice-label"><%=languageHelper.getTranslation(Etn, "Remise code promo")+" « "+cart.getProperty("promo_code")+" »"%></span>
  </div>
  <div style='font-size:0.875rem'><%=languageHelper.getTranslation(Etn, "Applicable on delivery fee")%></div>
  <%}%>
</div>
                        <div class="BasketSummary-toPay py-3 d-flex justify-content-between font-weight-bold">
    <p class="d-flex flex-column m-0">
        <span><%=languageHelper.getTranslation(Etn, "Montant à payer")%>*</span><span>(<%=languageHelper.getTranslation(Etn, (cart.isShowAmountWithTax()?"Taxe incluse":"Hors-taxe"))%>)</span>
    </p>
    <p class="d-flex flex-column text-primary text-right m-0">
        <%if(currecyPosition.equals("before")){%>
            <%=cart.getDefaultCurrency()%>
        <%}%>
        <span class="lead font-weight-bold">
            <%=PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), (cart.isShowAmountWithTax()?grandTotal:grandTotalWT)+"")%>
        </span>
        <%if(currecyPosition.equals("after")){%>
            <%=cart.getDefaultCurrency()%>
        <%}%>
    </p>
</div>
    <%
    if(cart.getGrandTotalRecurringMap() != null)
	{
		for(String _frequency : cart.getGrandTotalRecurringMap().keySet())
		{
			double grandTotalRecurring = cart.getGrandTotalRecurringMap().get(_frequency);
			double grandTotalRecurringWT = cart.getGrandTotalRecurringWTMap().get(_frequency);
			
			if((cart.isShowAmountWithTax()?grandTotalRecurring:grandTotalRecurringWT) <= 0) continue;
    %>
<div class="PaymentForm-hr"></div>
<div class="BasketSummary-toPay mt-3 pb-3 d-flex justify-content-between font-weight-bold">
    <p class="d-flex flex-column m-0">
        <span><%=languageHelper.getTranslation(Etn, "À payer")%></span><span>(<%=languageHelper.getTranslation(Etn, (cart.isShowAmountWithTax()?"Taxe incluse":"Hors-taxe"))%>)</span>
    </p>
    <p class="d-flex flex-column m-0 text-primary text-right">
        <%if(currecyPosition.equals("before")){%>
            <%=cart.getDefaultCurrency()%>/<%=languageHelper.getTranslation(Etn, _frequency)%>
        <%}%>
        <span class="lead font-weight-bold">
            <%=PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), (cart.isShowAmountWithTax()?grandTotalRecurring:grandTotalRecurringWT)+"")%>
        </span>
        <%if(currecyPosition.equals("after")){%>
            <%=cart.getDefaultCurrency()%>/<%=languageHelper.getTranslation(Etn, _frequency)%>
        <%}%>
    </p>
</div>
		<%}
}
%>
<p class="mb-4"><%=cart.getCartMessage()%></p>
                        <div class="BasketSummary-legalsGroupForm custom-control custom-checkbox my-4">
                            <input type="checkbox" class="custom-control-input isPristine" id="conditions-vente" required data-required-error="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Vous devez acceptez les termes et conditions."))%>">
                            <label class="custom-control-label" for="conditions-vente">
                                <%=languageHelper.getTranslation(Etn, "J'accepte les")%> <span class="Form-checkboxInnerLink" id="labelLegalsModal" data-toggle="modal" data-target="#terms"><%=languageHelper.getTranslation(Etn, "termes et conditions de vente")%>.</span>
                            </label>
                            <div id="termsError" class="invalid-feedback"><%=escapeCoteValue(languageHelper.getTranslation(Etn, "Vous devez acceptez les termes et conditions."))%></div>
                        </div>
                        <div class="BasketSummary-actions">
                            <button id="buyall" type="button" class="BasketSummary-commandButton btn btn-primary btn-block mb-2 JS-FormValidator-submit funnel-data-layer" disabled
                                    data-dl_event='standard_click' data-dl_event_category='cart_w_products' data-dl_event_action='button_click' data-dl_event_label='order' data-dl_products='<%=escapeCoteValue(products.toString())%>'>
                                <%=languageHelper.getTranslation(Etn, "Commander")%>
                            </button>
                            <button type="button" class="BasketSummary-saveQuitButton btn btn-secondary btn-block funnel-data-layer" data-toggle="modal" data-target="#saveModal" onclick="openSaveModal()"
                                    data-dl_event='standard_click' data-dl_event_category='cart_w_products' data-dl_event_action='button_click' data-dl_event_label='save' >
                                <%=languageHelper.getTranslation(Etn, "Sauvegarder le panier")%>
                            </button>
                        </div>

            </div>
              <%}%>
        </div>
    </div>
	<% out.write(___cartFooter); %>
    </form>
</div>

<div class="modal fade" id="terms" tabindex="-1" role="dialog" aria-labelledby="labelLegalsModal" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="close"></button>
            </div>
            <div class="modal-body">
                <div class="card">
                    <div class="card-icon">
                        <span class="svg-warning-circle"></span>
                    </div>
                    <div class="card-body">
                        <h3 id="myModalLabel2" class="card-title"><%=languageHelper.getTranslation(Etn, "Termes et Conditions")%></h3>
                        <div class="card-text"><%=cart.getTerms()%>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-dismiss="modal"><%=languageHelper.getTranslation(Etn, "Fermer")%></button>
            </div>
        </div>
    </div>
</div>

<!-- Modal -->
<div class="BasketModal modal fade" id="deleteModal" tabindex="-1" role="dialog" aria-labelledby="deleteModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <div class="BasketModal-title h2" id="deleteModalTitle"><%=languageHelper.getTranslation(Etn, "Retirer l'article du panier")%></div>
                <p>
                    <strong><%=languageHelper.getTranslation(Etn, "Êtes-vous sûr de vouloir retirer le produit")%> «&nbsp;<span id="removeProductNameSpan"></span>&nbsp;» <%=languageHelper.getTranslation(Etn, "de votre panier ?")%></strong>
                </p>
                <div class="BasketModal-actions BasketModal-section">
                    <button type="button" class="btn btn-secondary" onclick="cancelRemoveItem();" data-dismiss="modal"><%=languageHelper.getTranslation(Etn, "Annuler")%></button>
                    <button type="button" class="btn btn-primary" onclick="removeItem(removeItemIndex)"><%=languageHelper.getTranslation(Etn, "Retirer")%></button>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal -->
<div class="ModalValidator BasketModal modal fade" id="saveModal" tabindex="-1" role="dialog" aria-labelledby="saveModalTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <form class="ModalValidator-form modal-content" data-messages='{"required":"<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Ce champ est requis."))%>", "regex":"<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Ce champ est non valide."))%>", "confirm":"<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Veuillez saisir deux fois la même valeur."))%>"}'>
            <div class="modal-body">
                <div class="BasketModal-title h2" id="saveModalTitle"><%=languageHelper.getTranslation(Etn, "Sauvegarder le panier")%></div>
                <div class="form-group" data-children-count="1">
                    <label for="keepEmail" class="is-required"><%=languageHelper.getTranslation(Etn, "Email")%></label>
                    <input type="email" data-regex="/^[a-z0-9._-]+@[a-z0-9._-]+\.[a-z]{2,6}$/" data-regex-error="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "L'email n'est pas valide."))%>" class="form-control" id="keepEmail" name="keepEmail" required="" data-kwimpalastatus="alive" data-kwimpalaid="1584366068290-9">
                    <input type="hidden" name="sendKeepEmail" value="1" />
                    <input type="hidden" name="keepEmailMuid" value="<%=escapeCoteValue(___muuid)%>" />
                    <div class="invalid-feedback"></div>
                </div>
                <div class="BasketModal-actions BasketModal-section">
                    <button type="button" class="btn btn-secondary funnel-data-layer" data-dismiss="modal"
                            data-dl_event='standard_click' data-dl_event_category='popin_save_cart' data-dl_event_action='button_click' data-dl_event_label='cancel' ><%=languageHelper.getTranslation(Etn, "Annuler")%></button>
                    <button type="button" class="ModalValidator-confirmButton btn btn-primary funnel-data-layer" disabled="disabled" onclick="saveKeepEmail(this)"
                            data-dl_event='standard_click' data-dl_event_category='popin_save_cart' data-dl_event_action='button_click' data-dl_event_label='save' ><%=languageHelper.getTranslation(Etn, "Sauvegarder")%></button>
                </div>
                <div class="BasketModal-section">
                    <p>
                        <%=saveCartText%>
                    </p>
                </div>
            </div>
        </form>
    </div>
</div>
<div class="modal fade " id="login-popup" tabindex="-1" role="dialog" aria-labelledby="labelLegalsModal" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="close"></button>
            </div>
            <div class="modal-body">
                <div class="card">
                    <div class="card-body">
                        <div >
                            <form id="loginForm">
                        <input type="hidden" name="logintoken" value="<%=escapeCoteValue(logintoken)%>" />
                        <input type="hidden" name="formtype" value="popuplogin" />
                        <input type="hidden" name="muid" value="<%=escapeCoteValue(___muuid)%>" />
                            <div class="form-group">
                                <label for="loginEmail"><%=languageHelper.getTranslation(Etn, "Username")%></label>
                                <input type="text" name="username" class="form-control" id="loginEmail" placeholder="<%=languageHelper.getTranslation(Etn, "Email")%>">
                            </div>
                            <div class="form-group">
                                <label for="loginPassword"><%=languageHelper.getTranslation(Etn, "Password")%></label>
                                <input type="password" name="password" class="form-control" id="loginPassword" placeholder="<%=languageHelper.getTranslation(Etn, "Password")%>">
                            </div>

                            <p class="cb" style="padding: 10px 0;">
                                <a href="<%=escapeCoteValue(com.etn.beans.app.GlobalParm.getParm("PORTAL_CONTEXTPATH")+"pages/forgotpassword.jsp?muid="+___muuid)%>"><%=languageHelper.getTranslation(Etn, "Forgot Password?")%></a>
                            </p>
                            <input type="button" class="btn btn-primary " value="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Login"))%>" id="login"/>
                            <p class="cb" style="padding: 10px 0;">
                                <a id="loginSignup" href="<%=escapeCoteValue(com.etn.beans.app.GlobalParm.getParm("PORTAL_CONTEXTPATH")+"pages/signup.jsp?muid="+___muuid+"&r="+com.etn.beans.app.GlobalParm.getParm("CART_URL")+"cart/cart.jsp?muid="+___muuid)%>"  >
                                <%=languageHelper.getTranslation(Etn, "Not a member? Register here!")%></a>
                            </p>
                            </form>
                        </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="guest" tabindex="-1" role="dialog" aria-labelledby="guestLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="guestLabel"><%=languageHelper.getTranslation(Etn, "Panier mis à jour")%></h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Fermer"))%>">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <%=languageHelper.getTranslation(Etn, "Cannot checkout as 'Guest', please select a User from the dropdown.")%>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal"><%=languageHelper.getTranslation(Etn, "Fermer")%></button>
      </div>
    </div>
  </div>
</div>
<div class="modal fade" id="guest-confirm" tabindex="-1" role="dialog" aria-labelledby="guest-confirmLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="guest-confirmLabel"><%=languageHelper.getTranslation(Etn, "Panier mis à jour")%></h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="<%=escapeCoteValue(languageHelper.getTranslation(Etn, "Fermer"))%>">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <%=languageHelper.getTranslation(Etn, "Are you sure you want to checkout as 'Guest'?")%>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal"><%=languageHelper.getTranslation(Etn, "Fermer")%></button>
        <button type="button" class="btn btn-primary" onclick="$('#cartForm').submit();"><%=languageHelper.getTranslation(Etn, "Oui")%></button>
      </div>
    </div>
  </div>
</div>

    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>" ></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/focus-visible.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/popper.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>" ></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/jquery.tablesorter.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/swiper.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/boosted.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>" ></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bs-custom-file-input.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/TweenMax.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/nouislider.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/algoliasearch.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/mobile-detect.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/sticky-sidebar.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/ResizeSensor.min.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bundle.js?__v=<%=parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))%>"></script>
     <%=_footerHtml%>

    <%=_endscriptshtml%>
    <script>
    var removeItemIndex = 0;
    var removeItemJson = ""; // for datalayer
    var dataLayerAssociatedProduct = ""; // for datalayer, not used for now.
    var productsJson = <%=products.toString()%>; // for datalayer
    var pageTrackingJsons = {
        cart_w_products: <%=onlyProducts.toString()%>,
        cart_w_offers: <%=onlyOffers.toString()%>,
        cart_w_products_unavailable: <%=onlyUnavailableProducts.toString()%>
    }
    $(document).ready(function(){
        document.title = "<%=languageHelper.getTranslation(Etn, "Panier")%> | "+document.title;
        $('#cartForm').attr('action', '<%=checkoutPage%>');
        $("#conditions-vente.isPristine").addClass("is-invalid");

        $('#close-login-popup').on('click touch',function(e){
            e.preventDefault();
            e.stopPropagation();

            $('#login-popup').removeClass('active');
        });
        $('input.product-quantity').on('blur',function(e){
            if($(this).val()>$(this).data('limit')) $(this).val($(this).data('limit'));
            updateQuantity($(this).data('id'),$(this).val());
        });

        $('input.product-quantity').on("keyup", function(e){
            if(e.which == 13){
                if($(this).val()>$(this).data('limit')) $(this).val($(this).data('limit'));
                updateQuantity($(this).data('id'),$(this).val());
            }
        });
        $('#login').on('click touch',function(e){
            e.preventDefault();
            doLogin('<%=com.etn.beans.app.GlobalParm.getParm("PORTAL_CONTEXTPATH")%>');
        });

        bindEvents(); // for binding in sequence so that datalayer functions are executed before redirection.

        $('.outOfStock').each(function() {
            $('#outOfStockSection').append($(this).html());
         });
        $(window).keydown(function(event){
            if(event.keyCode == 13) {
                event.preventDefault();
                return false;
            }
        });
        //setCookieJSON(,______muid,1);

        setMenuCookie();

        //pageTrackingWithProducts('cart_w_products');
        <%=(onlyProducts.length()>0?"pageTrackingWithProducts('cart_w_products');":"")%>
        <%=(onlyOffers.length()>0?"pageTrackingWithProducts('cart_w_offers');":"")%>
        <%=(onlyUnavailableProducts.length()>0?"pageTrackingWithProducts('cart_w_products_unavailable');":"")%>

        ecommerceTrackingOnLoad();
    });

    function ecommerceTrackingOnLoad(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null)
        {
            var tempObject = {"event": "checkout",
                            event_action: "",
                            event_category: "",
                            event_label: "","ecommerce": {"checkout": {"actionField": {"step": 1, "option": "Cart page (summary)"}, "products": productsJson}}};; // ecommerce tracking
            dataLayer.push(tempObject);
        }
    }

    function pageTrackingWithProducts(pageName){

        if(typeof dataLayer !== 'undefined' && dataLayer != null)
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                page_name: pageName
            }; // page tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            var productsObject = objectFromArray(refitKeysArray(pageTrackingJsons[pageName]));
            for(var key in productsObject){
                newDlObj[key] = productsObject[key];
            }
            dataLayer.push(newDlObj);
        }
    }

    function bindEvents(){
        $(document).on("click",".funnel-data-layer",function(){

            if(typeof dataLayer !== 'undefined' && dataLayer != null)
            {
                //var __dlcontent = new Object();
                var newDlObj = cloneObject(_etn_dl_obj);
                if(this.dataset.dl_event) newDlObj.event = this.dataset.dl_event;
                if(this.dataset.dl_event_category) newDlObj.event_category = this.dataset.dl_event_category;
                if(this.dataset.dl_event_action) newDlObj.event_action = this.dataset.dl_event_action;
                if(this.dataset.dl_event_label) newDlObj.event_label = this.dataset.dl_event_label;
    //            if(this.dataset.dl_product_name) __dlcontent.product_name = this.dataset.dl_product_name;
    //            if(this.dataset.dl_product_brand) __dlcontent.product_brand = this.dataset.dl_product_brand;
    //            if(this.dataset.dl_product_id) __dlcontent.product_id = this.dataset.dl_product_id;
    //            if(this.dataset.dl_product_price) __dlcontent.product_price = this.dataset.dl_product_price;
    //            if(this.dataset.dl_product_category) __dlcontent.product_category = this.dataset.dl_product_category;
    //            if(this.dataset.dl_product_variant) __dlcontent.product_variant = this.dataset.dl_product_variant;
    //            if(this.dataset.dl_product_position) __dlcontent.product_position = this.dataset.dl_product_position;
    //            if(this.dataset.dl_product_quantity) __dlcontent.product_quantity = this.dataset.dl_product_quantity;
    //            if(this.dataset.dl_product_stock) __dlcontent.product_stock = this.dataset.dl_product_stock;
    //            if(this.dataset.dl_product_stocknumber) __dlcontent.product_stocknumber = this.dataset.dl_product_stocknumber;
    //            if(this.dataset.dl_purchase_productsold) __dlcontent.purchase_productsold = this.dataset.dl_purchase_productsold;
    //            if(this.dataset.dl_purchase_revenue) __dlcontent.purchase_revenue = this.dataset.dl_purchase_revenue;
    //            if(this.dataset.dl_purchase_currency) __dlcontent.purchase_currency = this.dataset.dl_purchase_currency;
    //            if(this.dataset.dl_purchase_id) __dlcontent.purchase_id = this.dataset.dl_purchase_id;
    //            if(this.dataset.dl_purchase_tax) __dlcontent.purchase_tax = this.dataset.dl_purchase_tax;
    //            if(this.dataset.dl_purchase_shippingcost) __dlcontent.purchase_shippingcost = this.dataset.dl_purchase_shippingcost;
    //            if(this.dataset.dl_purchase_shippingtype) __dlcontent.purchase_shippingtype = this.dataset.dl_purchase_shippingtype;

                if(this.dataset.dl_products){
                    var productsObject = objectFromArray(refitKeysArray(eval('('+this.dataset.dl_products+')')));
                    for(var key in productsObject){
                        newDlObj[key] = productsObject[key];
                    }
                }
                dataLayer.push(newDlObj);
            }

        });

        $('#buyall').on('click touch',function(){
            if(typeof dataLayer !== 'undefined' && dataLayer != null)
            {
                var tempObject = {"event": "validateFunnel",
                                    event_action: "",
                                    event_category: "",
                                    event_label: "","ecommerce": {"order": {"products": productsJson}}};; // ecommerce tracking
                dataLayer.push(tempObject);
            }

            <%
            if(isSuperUser){
                if(logged) out.write("$('#cartForm').submit();");
                else if(cart.isCheckoutRequireLogin()){
            %>
                $('#guest').modal('toggle');
            <%
                }
                else {
            %>
                $('#guest-confirm').modal('toggle');
            <%
                }
            }
            else{
            %>
            <%=(cart.isCheckoutRequireLogin()?"checkLogin('"+escapeCoteValue(___muuid)+"');":"$('#cartForm').submit();")%>
            <%
            }
            %>
        });

        $(document).on("click",".QuantityControl-removeButton",function(){
            updateQuantity(this.dataset.id,'dec');
        });

        $(document).on("click",".QuantityControl-addButton",function(){
            updateQuantity(this.dataset.id,'inc');
        });

        $(document).on("click","#addPromo",function(){
            addPromo();
        });

        $('#conditions-vente').change(function() {
            if(this.checked){
                if(typeof dataLayer !== 'undefined' && dataLayer != null)
                {
                    var newDlObj = cloneObject(_etn_dl_obj);
                    var tempObject = {
                        event: "standard_click",
                        event_action: "button_click",
                        event_category: "cart_w_products",
                        event_label: "terms_conditions"}; // event tracking

                    for(var key in tempObject){
                        newDlObj[key] = tempObject[key];
                    }
                    dataLayer.push(newDlObj);
                }
            }
        });

    }

    function setMenuCookie(){
        var d = new Date();
        d.setTime(d.getTime() + (1*24*60*60*1000));
        var expires = "expires="+d.toUTCString();

        document.cookie = '<%=com.etn.beans.app.GlobalParm.getParm("CART_COOKIE").replaceAll("CartItems","")+"MenuUuid"%>' + "=" + ______muid + ";" + expires+"; path="+______portalurl2;
    }

    function addPromo()
	{
        $('<form method="POST" action="cart.jsp?muid='+______muid+'"><input type="hidden" name="promoCode" value="'+$('#coupon_code').val()+'" ></form>').appendTo('body').submit();
    }

    function removeItem(index){
        if(typeof dataLayer !== 'undefined' && dataLayer != null)
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: "popin_delete_products",
                event_label: "delete"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            var productsObject = objectFromArray(refitKeysArray([removeItemJson]));
            for(var key in productsObject){
                newDlObj[key] = productsObject[key];
            }
            dataLayer.push(newDlObj);

            tempObject = {"event": "removeFromCart",
                            event_action: "",
                            event_category: "",
                            event_label: "","ecommerce": {"remove": {"products": [removeItemJson]}}}; // ecommerce tracking
            dataLayer.push(tempObject);

        }
        $('<form method="POST" action="cart.jsp?muid='+______muid+'"><input type="hidden" name="removeItem" value="'+index+'" ><input type="hidden" name="promoCode" value="'+$('#coupon_code').val()+'" ></form>').appendTo('body').submit();
    }

    function cancelRemoveItem(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null)
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: "popin_delete_products",
                event_label: "cancel"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            var productsObject = objectFromArray(refitKeysArray([removeItemJson]));
            for(var key in productsObject){
                newDlObj[key] = productsObject[key];
            }
            dataLayer.push(newDlObj);
        }
    }

    function removeComewith(index, comewith){
        $.ajax({
            url : '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>calls/removeComewith.jsp',
            type: 'post',
            data: { cart_item_id: index, comewith_id: comewith},
            success : function(json)
            {
                $('<form method="POST" action="cart.jsp?muid='+______muid+'"><input type="hidden" name="promoCode" value="'+$('#coupon_code').val()+'" ></form>').appendTo('body').submit();
            },
            error : function()
            {
				alert("Error while communicating with the server");
            }
        });
    }

    function updateQuantity(index,type){
        $('<form method="POST" action="cart.jsp?muid='+______muid+'"><input type="hidden" name="updateItem" value="'+index+'" ><input type="hidden" name="updateType" value="'+type+'" ><input type="hidden" name="promoCode" value="'+$('#coupon_code').val()+'" ></form>').appendTo('body').submit();
    }

    function saveKeepEmail(button){

        if(typeof dataLayer !== 'undefined' && dataLayer != null)
        {
            var tempObject = {"event": "saveYourCartPopin",
                    event_action: "",
                    event_category: "",
                    event_label: "","ecommerce": {"saveYourCartPopin": {"products": productsJson}}};; // ecommerce tracking
            dataLayer.push(tempObject);
        }
        var form = $(button).closest('form');
        //alert(form.serialize());
        var formData = new FormData(form.get(0));
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
                $("#saveModal").modal('toggle');
            }
            else{
                alert(resp.message);
            }
        })
        .fail(function(resp) {
             alert("Error in contacting server.Please try again.");
        })
        .always(function() {
            //hideLoader();
        });
    }

    function openDeletionModal(productName, cartItemId, cartItemJson){
        $("#removeProductNameSpan").html(productName);
        removeItemIndex = cartItemId;
        removeItemJson = cartItemJson;

        if(typeof dataLayer !== 'undefined' && dataLayer != null)
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                page_name: "popin_delete_products"}; // page tracking
            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }
            dataLayer.push(newDlObj);
        }
    }

    function openSaveModal(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null)
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                page_name: "popin_save_cart"}; // page tracking
            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }
            dataLayer.push(newDlObj);

            var tempObject = {"event": "saveYourCart",
                                event_action: "",
                                event_category: "",
                                event_label: "","ecommerce": {"saveYourCart": {"products": productsJson}}};; // ecommerce tracking
            dataLayer.push(tempObject);
        }
    }
    </script>
  </body>
</html>