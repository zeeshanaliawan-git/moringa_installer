<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64, org.json.*"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*"%>


<%@ include file="../cart/common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>

<%
	boolean showgrandtotal = "true".equalsIgnoreCase(parseNull(request.getParameter("showgrandtotal")));
	String cartmenuid = parseNull(request.getParameter("menu_id"));
	String cachedResourcesFolder = "";
	if(cartmenuid.length() > 0) cachedResourcesFolder = getCachedResourcesUrl(Etn, cartmenuid);

	String __cartcommonmenuid = cartmenuid;

	String cartCookieName = com.etn.beans.app.GlobalParm.getParm("CART_COOKIE");
	String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
	String cartSessionId = CartHelper.getCartSessionId(request);
	String ___loadedsiteid = parseNull(request.getParameter("site_id"));
	String _lang = parseNull(request.getParameter("lang"));
    String summaryType = parseNull(request.getParameter("summaryType"));
	
	Set rsLang = Etn.execute("Select * from language where langue_code = "+escape.cote(_lang));
	rsLang.next();
	String ___loadedlangid = rsLang.value("langue_id");

	Set rsM = Etn.execute("select * from site_menus where id = "+escape.cote(cartmenuid));
	rsM.next();

	String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
	Cart cart = CartHelper.loadCart(Etn, request, cartSessionId, ___loadedsiteid, rsM.value("menu_uuid"));

	String delivery_method = parseNull(cart.getProperty("delivery_method"));

	Set rsCart = Etn.execute("select ci.* from cart c inner join cart_items ci on c.id = ci.cart_id where session_id="+escape.cote(cartSessionId)+" and site_id="+escape.cote(___loadedsiteid) +" order by ci.id");

	double grandTotal = cart.getGrandTotal();
	double grandTotalWT = cart.getGrandTotalWT();

	String payment_method = parseNull(cart.getProperty("payment_method"));
	String delivery_type = parseNull(cart.getProperty("delivery_type"));
	boolean showamountwithtax = cart.isShowAmountWithTax();

	String priceformatter = cart.getPriceFormatter();
	String roundto = cart.getRoundTo();
	String showdecimals = cart.getShowDecimals();
	String defaultcurrency = cart.getDefaultCurrency();

	JSONArray recapDatalayerProducts = new JSONArray();

	String deliveryError = "";
	if(cart.hasDeliveryError())
	{
		deliveryError = cart.getError(CartError.DELIVERY_ERROR).getMessage();
	}

	String deliveryDisplayName = cart.getDeliveryDisplayName();
	double defaultShippingFees = cart.getDefaultShippingFees();
	double shippingFees = cart.getShippingFees();
	String _shippingFeeStr = cart.getShippingFeeStr();

	JSONArray calculatedCartDiscounts = cart.getCalculatedCartDiscounts();
	double paymentFees = cart.getPaymentFees();

	boolean stock_error = false;//always setting to false for recap screen

	LanguageHelper languageHelper = LanguageHelper.getInstance();

	for(CartItem cartItem : cart.getItems())
	{
		ProductVariant pVariant = cartItem.getVariant();
		int qty = PortalHelper.parseNullInt(cartItem.getProperty("quantity"));

		JSONObject recapDatalayerProduct = new JSONObject();
		recapDatalayerProduct.put("name",pVariant.getProductName());
		recapDatalayerProduct.put("brand",languageHelper.getTranslation(Etn, parseNull(pVariant.getBrandName())));
		recapDatalayerProduct.put("id",pVariant.getSku());
		recapDatalayerProduct.put("price",pVariant.getUnitPrice());// this price is with quantity 1
		recapDatalayerProduct.put("category",pVariant.getProductType());
		recapDatalayerProduct.put("variant",pVariant.getVariantName());
		recapDatalayerProduct.put("position",recapDatalayerProducts.length()+1);
		recapDatalayerProduct.put("quantity",qty);
		recapDatalayerProduct.put("stock",(stock_error?"no":"yes"));
		recapDatalayerProduct.put("stock_number",pVariant.getVariantStock());
		recapDatalayerProducts.put(recapDatalayerProduct);
	}//for loop

%>

<input id="deliveryError" type="hidden" value="<%=escapeCoteValue(deliveryError)%>" />
<%if(summaryType.equals("basket")){%>
<div class="BasketSummary-toPay pb-3 d-flex justify-content-between font-weight-bold">
    <p class="d-flex flex-column m-0">
        <span><%=languageHelper.getTranslation(Etn, "Montant à payer")%>*</span><span><%=languageHelper.getTranslation(Etn, "(TVA incluse)")%></span>
    </p>
    <p class="d-flex flex-column text-primary text-right m-0">
        <span class="lead font-weight-bold"><%=PortalHelper.formatPrice(priceformatter, roundto, showdecimals, grandTotal+"")%></span><%=defaultcurrency%>
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
        <span><%=languageHelper.getTranslation(Etn, "À payer")%></span><span><%=languageHelper.getTranslation(Etn, "(TVA incluse)")%></span>
    </p>
    <p class="d-flex flex-column m-0 text-primary text-right">
        <span class="lead font-weight-bold"><%=PortalHelper.formatPrice(priceformatter, roundto, showdecimals, grandTotalRecurring+"")%></span><%=defaultcurrency%>/<%=languageHelper.getTranslation(Etn, _frequency)%>
    </p>
</div>
    <%}%>

<p class="mb-4">* <%=languageHelper.getTranslation(Etn, "frais de livraison et de paiement inclus")%></p>
    <%
		}//for loop
    } else {
    %>
<div class="OrderSummary-title"><%=languageHelper.getTranslation(Etn, "Récapitulatif")%></div>
        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle"><%=languageHelper.getTranslation(Etn, "Montant à payer")%></div>
                <%=PortalHelper.getCurrencyPosition(
                    Etn,
                    request,
                    ___loadedsiteid,
                    _lang,
                     "<span class='textOrangeBiggest'>"
                    +   PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (showamountwithtax?(grandTotal-shippingFees-paymentFees):(grandTotalWT-shippingFees-paymentFees))+"")
                    + "</span>",
                    "<span class='textOrangeNormal'>"+defaultcurrency+"</span>")%>
        </div>
        <%
		boolean shippingCouponShown = false;
        for(int i=0; i<calculatedCartDiscounts.length(); i++){
			double _dDiscount = 0;
			try {
				_dDiscount = Double.parseDouble(calculatedCartDiscounts.getJSONObject(i).getString("discountValue"));
			} catch (Exception e) { _dDiscount = 0; }
			if(_dDiscount == 0) continue;
			
			if(calculatedCartDiscounts.getJSONObject(i).getString("elementOn").equals("shipping_fee") && calculatedCartDiscounts.getJSONObject(i).getString("couponCode").length()>0) shippingCouponShown = true;
        %>
        <div class="OrderSummary-section <%=(!calculatedCartDiscounts.getJSONObject(i).getString("elementOn").equals("shipping_fee")?"":"")%>">
            <div class="OrderSummary-subtitle"><%=(calculatedCartDiscounts.getJSONObject(i).getString("couponCode").length()>0?languageHelper.getTranslation(Etn, "Remise code promo")+" « "+escapeCoteValue(calculatedCartDiscounts.getJSONObject(i).getString("couponCode"))+" »":languageHelper.getTranslation(Etn, "Remise panier"))%></div>
            <%=PortalHelper.getCurrencyPosition(
                Etn,
                request,
                ___loadedsiteid,
                _lang,
                "<span class='textOrangeBiggest recap-promo-code-amnt'>-"+PortalHelper.formatPrice( priceformatter, roundto, showdecimals, calculatedCartDiscounts.getJSONObject(i).getString("discountValue"))+"</span>",
                "<span class='textOrangeNormal'>"+defaultcurrency+"</span>")%>
        </div>
        <%}
		if(shippingCouponShown == false && PortalHelper.parseNull(cart.getProperty("promo_code")).length() > 0 && cart.hasPromoError() == false)
		{		
			//if coupon code is applicable on delivery fee we have to show the message to customer
			Set rsP = Etn.execute("select cp.discount_type, cp.discount_value "+
							" from "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion_coupon cpc "+
							" join "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion cp on cp.id = cpc.cp_id and cp.site_id = "+escape.cote(cart.getProperty("site_id"))+" and cp.element_on = 'shipping_fee' "+
							" where cpc.coupon_code = "+escape.cote(PortalHelper.parseNull(cart.getProperty("promo_code"))));
			if(rsP.next())
			{%>
        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle"><%=languageHelper.getTranslation(Etn, "Remise code promo")+" « "+cart.getProperty("promo_code")+" »"%></div>
            <div class="recap-promo-code-txt" style="font-size:0.875rem"><%=languageHelper.getTranslation(Etn, "Applicable on delivery fee")%></div>
			<span class='textOrangeBiggest recap-promo-code-amnt d-none'></span>
			<span class='textOrangeNormal recap-promo-code-currency d-none'><%=defaultcurrency%></span>
        </div>
			<%}
		}//if

		%>
    <%
    if(cart.getGrandTotalRecurringMap() != null)
	{
		for(String _frequency : cart.getGrandTotalRecurringMap().keySet())
		{
			double grandTotalRecurring = cart.getGrandTotalRecurringMap().get(_frequency);
			double grandTotalRecurringWT = cart.getGrandTotalRecurringWTMap().get(_frequency);
			
			if((cart.isShowAmountWithTax()?grandTotalRecurring:grandTotalRecurringWT) <= 0) continue;
    %>
        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle"><%=languageHelper.getTranslation(Etn, "À payer")%></div>
                <%=PortalHelper.getCurrencyPosition(
                    Etn,
                    request,
                    ___loadedsiteid,
                    _lang,
                     "<span class='textOrangeBiggest'>"
                    +   PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (showamountwithtax?grandTotalRecurring:grandTotalRecurringWT)+"")
                    + "</span>",
                    "<span class='textOrangeNormal'>"+defaultcurrency+"/"+languageHelper.getTranslation(Etn, _frequency)+"</span>")%>
        </div>
<%		}//for loop
	}
%>

        <div class="OrderSummary-section deliveryFeeText">
<%
    if(delivery_method.length()>0){
%>
            <div class="OrderSummary-subtitle"><%=languageHelper.getTranslation(Etn, deliveryDisplayName)%></div>
            <span class="textOrangeBiggest">
				<% if(_shippingFeeStr.equals("no_show") == false) {
					Set rsShop = Etn.execute("select lang_"+___loadedlangid+"_free_delivery_method as _txt from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id="+escape.cote(___loadedsiteid));
					rsShop.next();
				%>
				<%=(shippingFees<=0?
                    rsShop.value("_txt")
                    :
                    PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid, _lang, PortalHelper.formatPrice(priceformatter, roundto, showdecimals, shippingFees+""), defaultcurrency))%>
				<%}%>
			</span>
	<%}%>			
        </div>

<%
    if(delivery_method.equals("pick_up_in_store") && parseNull(cart.getProperty("rdv_boutique")).equals("true")){
%>
        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle"><%=languageHelper.getTranslation(Etn, "Date du rendez-vous")%></div>
            <span class="textOrangeBiggest"><%=escapeCoteValue(parseNull(cart.getProperty("rdv_date")))%></span>
        </div>
<%}
    if(showgrandtotal){
%>
        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle"><%=languageHelper.getTranslation(Etn, "Somme finale")%></div>
             <%=PortalHelper.getCurrencyPosition(
                    Etn,
                    request,
                    ___loadedsiteid,
                    _lang,
                     "<span class='textOrangeBiggest'>"
                    +  PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (showamountwithtax?grandTotal:grandTotalWT)+"")
                    + "</span>",
                    "<span class='textOrangeNormal'>"+defaultcurrency+"</span>")%>
        </div>
<%}
    if(parseNull(cart.getProperty("surnames")).length()>0 && (parseNull(cart.getProperty("identityId")).length()>0 || parseNull(cart.getProperty("identityPhoto")).length()>0 )){
%>

        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle"><%=languageHelper.getTranslation(Etn, "Colis livré à")%> <%=escapeCoteValue(parseNull(cart.getProperty("salutation")))%>. <%=escapeCoteValue(parseNull(cart.getProperty("surnames")))%>*</div>
            * <%=languageHelper.getTranslation(Etn, "Une pièce d’identité vous sera demandée lors de la livraison")%>
        </div>
<%}

%>
        <div class="OrderSummary-section accordion">
            <div class="card-header">
                <button class="OrderSummary-seeDetails collapsed" type="button" data-toggle="collapse" data-target="#collapseExample" data-bs-toggle="collapse" data-bs-target="#collapseExample" aria-expanded="false" aria-controls="collapseExample">
                    <%=languageHelper.getTranslation(Etn, "Détails")%>
                </button>
            </div>
            <div class="collapse OrderSummary-detailList" id="collapseExample">
			<%
				JSONObject deliveryIndexes = CartHelper.getDeliveryFeeIndexes(Etn, request, cart, defaultShippingFees);

				Iterator<String> keys = deliveryIndexes.keys();
				while(keys.hasNext())
				{
					String key = keys.next();
					JSONObject tempObject = deliveryIndexes.getJSONObject(key);
					JSONArray tempArray = tempObject.getJSONArray("indexes");

					for(int k = 0; k < tempArray.length(); k++)
					{
						//when there are multiple items in cart and method is home_delivery only then we show the orange box with each item
						//showing total per item delivery for each item ... if only one item then it makes no sense to show it as the delivery fee above will be showing same number
						//and in case delivery is not home_delivery we dont show that orange box at all
						if(delivery_method.equals("home_delivery") == true && cart.getItems().size() > 1 && (tempObject.getString("applicable_per_item").equals("1") || k==0))
						{
							out.write("<div class=\"border border-light mb-3 pt-2 w-100\">");
						}
						CartItem cItem = cart.getItems().get(tempArray.getInt(k));
						ProductVariant pVariant = cItem.getVariant();
						String productName = languageHelper.getTranslation(Etn, parseNull(pVariant.getBrandName())) + " " + pVariant.getProductName();
						int qty = PortalHelper.parseNullInt(cItem.getProperty("quantity"));
				%>
					<div class="OrderSummaryDetail p-1 pb-0">
						<div class="row">
							<div class="col-4">
								<div class="OrderSummaryDetail-imgWrapper">
									<img src="<%=escapeCoteValue(pVariant.getImageUrl())%>" alt="<%=escapeCoteValue(pVariant.getImageAlt())%>">
								</div>
							</div>
							<div class="col-8">
								<div class="OrderSummaryDetail-title"><%=escapeCoteValue(productName)%> <sup><%=escapeCoteValue((cart.getTaxNumbers().containsKey(pVariant.getTaxPercentage().tax+"")?" ("+cart.getTaxNumbers().get(pVariant.getTaxPercentage().tax+"")+")":""))%></sup></div>
								<div class="OrderSummaryDetail-description">
									<%
									JSONArray attributes = pVariant.getAttributes();
									for(int j=0; j<attributes.length(); j++){
										String _attribName = attributes.getJSONObject(j).optString("name", "");
										if(_attribName.equalsIgnoreCase("Commitment")) continue; // we not show commitment as part of attributes list as we already showing that in the price info

										String _attribValue = attributes.getJSONObject(j).optString("label", "");
										if(_attribValue.length() == 0) _attribValue = attributes.getJSONObject(j).getString("value");
										
										if(j>0) out.write("<br>");
										out.write(languageHelper.getTranslation(Etn, _attribValue));
									}
									%>
								</div>
								<%
								if( PortalHelper.isOffer(pVariant.getProductType()) == false){
								%>
								<div class="OrderSummaryDetail-description">
									<%=escapeCoteValue(languageHelper.getTranslation(Etn,"Quantité"))%> : <%=qty%>
								</div>
								<%}%>
								<div class="OrderSummaryDetail-price">
								<%
									String formatted_old_price = pVariant.getFormattedOldPrice();
									String formatted_price = pVariant.getFormattedPrice();
									String product_type = pVariant.getProductType();
									int discount_duration = pVariant.getDiscountDuration();
									String _currencyfreq = pVariant.getCurrencyFreq();
									
								if( product_type.equals("offer_postpaid") == false && _currencyfreq.length() == 0 ){
								%>
								<%if(!formatted_old_price.equals(formatted_price)) {%>
									<span class="OrderSummaryDetail-pricePromotion"><%=escapeCoteValue(formatted_old_price)%></span>
								<%}%>
									<span class="OrderSummaryDetail-priceFinal">
                                         <%=PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid, _lang,formatted_price, defaultcurrency)%>
                                    </span>
								<%}
								else{
								%>
									<span class="OrderSummaryDetail-priceFinal">
                                         <%=PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid, _lang,formatted_price, defaultcurrency+"/"+_currencyfreq)%>
                                    </span>
									<%if(!formatted_old_price.equals(formatted_price)&& discount_duration>0) {%>
										 <span class="font-weight-normal"><%=escapeCoteValue(languageHelper.getTranslation(Etn,"Pendant"))%> <%=discount_duration%> <%=escapeCoteValue(_currencyfreq)%></span>
										 <span class="font-weight-normal">
                                            <%=escapeCoteValue(languageHelper.getTranslation(Etn,"Puis"))%> <%=escapeCoteValue(formatted_old_price)%>
                                         </span>
										 <span class="font-weight-normal">
                                            <%=escapeCoteValue(defaultcurrency)%>/<%=escapeCoteValue(_currencyfreq)%>
                                         </span>
										<%}%>
								<%
								}
								%>
								</div>

								<%
								JSONArray tempAdditionalFee;
								if(showamountwithtax) tempAdditionalFee = pVariant.getAdditionalFee();
								else tempAdditionalFee = pVariant.getAdditionalFeeWT();
								for(int j=0; j<tempAdditionalFee.length(); j++){
									if(parseNullDouble(tempAdditionalFee.getJSONObject(j).getString("price"))==0) continue;
								%>
									<div class="OrderSummaryDetail-inclusiveTitle"><%=escapeCoteValue(tempAdditionalFee.getJSONObject(j).getString("name"))%></div>
									<div class="OrderSummaryDetail-inclusiveContent">
                                        <%=escapeCoteValue(tempAdditionalFee.getJSONObject(j).getString("price_prefix"))+PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid, _lang, PortalHelper.formatPrice(priceformatter, roundto, showdecimals, tempAdditionalFee.getJSONObject(j).getString("price")), defaultcurrency)%>
                                    </div>

								<%}%>
								<%
								JSONArray comewith = pVariant.getComewith();
								if(comewith.length()>0)
								{
									for(int j=0; j<comewith.length(); j++)
									{
										String priceLabel = "";
										if(!comewith.getJSONObject(j).getString("comewith").equals("label")){
										if(parseNullDouble(comewith.getJSONObject(j).getJSONObject("variant").optString("price"))<=0) priceLabel = "("+languageHelper.getTranslation(Etn, "gratuit")+")";
										else priceLabel = "("+PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid, _lang, PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (showamountwithtax?comewith.getJSONObject(j).getJSONObject("variant").optString("price"):comewith.getJSONObject(j).getJSONObject("variant").optString("priceWT"))), defaultcurrency)+")";
									}
									%>
										<div class="OrderSummaryDetail-inclusiveTitle"><%=comewith.getJSONObject(j).getString("comewith").equals("gift")?escapeCoteValue(languageHelper.getTranslation(Etn,"Offert")):escapeCoteValue(languageHelper.getTranslation(Etn,"Inclus"))%></div>
										<% if("select".equals(parseNull(comewith.getJSONObject(j).getString("variant_type")))){%>
										<div class="OrderSummaryDetail-inclusiveContent"><%=escapeCoteValue(comewith.getJSONObject(j).getString("title"))%> <%=escapeCoteValue(comewith.getJSONObject(j).getString("variantName"))%> <%=escapeCoteValue(priceLabel)%></div>
										<%}else{%>
										<div class="OrderSummaryDetail-inclusiveContent"><%=escapeCoteValue(comewith.getJSONObject(j).getString("title"))%> <%=escapeCoteValue(priceLabel)%></div>
										<%}%>
								<%}
								}

							if(delivery_method.equals("home_delivery") && parseNullDouble(cItem.getProperty("delivery_fee_per_item"))>0){
							%>
							<div class="OrderSummaryDetail-inclusiveTitle"><%=escapeCoteValue(languageHelper.getTranslation(Etn,"Delivery fee per item"))%></div>
							<div class="OrderSummaryDetail-inclusiveContent">
                                <%=PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid, _lang, PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cItem.getProperty("delivery_fee_per_item")), defaultcurrency)%>

                            </div>
							<%}%>
							</div>
						</div>
					</div>

				<%
						//when there are multiple items in cart and method is home_delivery only then we show the orange box with each item
						//showing total per item delivery for each item ... if only one item then it makes no sense to show it as the delivery fee above will be showing same number
						//and in case delivery is not home_delivery we dont show that orange box at all
						if(delivery_method.equals("home_delivery") == true && cart.getItems().size() > 1 && (tempObject.getString("applicable_per_item").equals("1") || k==tempArray.length()-1))
						{
							double tempShipping = tempObject.getDouble("fee");

							if(tempObject.getString("applicable_per_item").equals("1")) tempShipping = tempShipping * qty;

							out.write("<div class=\"bg-primary font-weight-bold p-2\">"
                            + languageHelper.getTranslation(Etn, "Livraison")+" "
                            + PortalHelper.getCurrencyPosition(Etn, request, ___loadedsiteid, _lang, PortalHelper.formatPrice(priceformatter, roundto, showdecimals, tempShipping+""),defaultcurrency )+"</div>");
							out.write("</div>");
						}
					}
				}//while
			%>
            </div>
        </div>
    <%
    }
    %>
    <script>

    var recapDatalayerProducts = <%=recapDatalayerProducts.toString()%>;
    var deliveryDisplayName = "<%=deliveryDisplayName%>";


    </script>