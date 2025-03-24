<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="com.etn.asimina.cart.*, com.etn.asimina.beans.*, cart.etn.asimina.util.*, com.etn.asimina.util.PortalHelper"%>

<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>
<%!
    String libelle_msg_escape(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String lib){
        return escapeCoteValue(libelle_msg(Etn, req, lib));
    }
%>
<%

    int stepNumber = 2;

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
    if(!sessionToken.equals(dbSessionToken)){

        response.sendRedirect("cart.jsp?muid="+___muuid);
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

    String isIdnow = cart.getProperty("idnow_uuid");
    
    if(isIdnow.length()>0){
        boolean iskycrequired = CartHelper.isKycRequired(Etn, ___loadedsiteid);
        String kycStatus = CartHelper.getKycStatus(Etn,cart.getProperty("id"));
        if(iskycrequired) stepNumber = 3;
        
        if(iskycrequired && !kycStatus.equalsIgnoreCase("success"))
        {
            response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"cart.jsp?muid="+___muuid);
            return;
        }
    }

	String cartExtUrl = parseNull(GlobalParm.getParm("CART_EXTERNAL_LINK"));
	if(cartExtUrl.endsWith("/") == false) cartExtUrl += "/";

    boolean hasProduct = CartHelper.cartHasProduct(Etn, request, cart);    
	// no delivery method if there is no product in cart. same session token forwarded.
    if( !hasProduct )
	{ 
		String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);
		String html = "<html><body><form name='paymentForm' method='post' action='"+cartExtUrl+"payment.jsp'><input type='hidden' name='session_token' value='"+escapeCoteValue(uuidSessionToken)+"'></form><script>document.forms[0].submit();</script></body></html>";
		out.write(html);
        return;
    }
	//calculate the delivery fee depending on billing address if delivery address is not yet filled
	String _datowncity = parseNull(cart.getProperty("datowncity")).length()==0?parseNull(cart.getProperty("batowncity")):parseNull(cart.getProperty("datowncity"));
	String _dapostcode = parseNull(cart.getProperty("dapostalCode")).length()==0?parseNull(cart.getProperty("bapostalCode")):parseNull(cart.getProperty("dapostalCode"));
	String _daline1 = parseNull(cart.getProperty("daline1")).length()==0?parseNull(cart.getProperty("baline1")):parseNull(cart.getProperty("daline1"));
	String _daline2 = parseNull(cart.getProperty("daline2")).length()==0?parseNull(cart.getProperty("baline2")):parseNull(cart.getProperty("daline2"));
	String _deliveryType = parseNull(cart.getProperty("delivery_type"));
	double applicableHomeDeliveryShippingFees = CartHelper.getDeliveryFee(Etn, request, cart.getItems(), cart.getProperty("site_id"), "home_delivery", _deliveryType, _datowncity, _dapostcode, _daline1, _daline2);

    Set rssite = Etn.execute("select * from sites where id = " + escape.cote(___loadedsiteid) );    
    rssite.next();      
	System.out.println("********************************* load_map " + rssite.value("load_map"));

	Map<String, String> algoliaSettings = PortalHelper.loadAlgoliaSettings(Etn, ___loadedsiteid);

    String defaultcurrency = parseNull(cart.getDefaultCurrency());
    String priceformatter  = parseNull(cart.getPriceFormatter());
    String roundto = parseNull(cart.getRoundTo());
    String showdecimals = parseNull(cart.getShowDecimals());
    
    String geoCodingAddress = parseNull(cart.getProperty("baline1"));
    if(parseNull(cart.getProperty("baline2")).length()>0) geoCodingAddress += ", "+parseNull(cart.getProperty("baline2"));
    if(parseNull(cart.getProperty("bapostalCode")).length()>0) geoCodingAddress += ", "+parseNull(cart.getProperty("bapostalCode"));
    if(parseNull(cart.getProperty("batowncity")).length()>0) geoCodingAddress += ", "+parseNull(cart.getProperty("batowncity"));
    if(parseNull(cart.getProperty("country")).length()>0) geoCodingAddress += ", "+parseNull(cart.getProperty("country"));

	//reset session token in db for next screen
    String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);
	
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

    Set rsDomain = Etn.execute("Select domain from sites where id = " + escape.cote(_menuRs.value("site_id")));
    rsDomain.next();
    Map<String, String> gtmScriptCode = getGtmScriptCodeForCart(Etn, _menuRs.value("id"), rsDomain.value(0)+GlobalParm.getParm("CART_EXTERNAL_LINK")+"deliv.jsp", "funnel", "", "", "",client_uuid,"","",(logged?"yes":"no"), "");
	
	String __cartmenuid = _menuRs.value("id");	

	//set the step name here as it is required for further verifications
	Etn.executeCmd("update cart set cart_step = "+escape.cote(CartHelper.Steps.DELIVERY)+" where id = "+escape.cote(cart.getProperty("id")));
    String delivQry = "Select distinct(delivery_type) from "+GlobalParm.getParm("CATALOG_DB")+".deliveryfees where site_id="+escape.cote(_menuRs.value("site_id"))+" AND (";
    if(_datowncity.length()>0) delivQry+="(dep_type='city' AND dep_value="+escape.cote(_datowncity)+") OR ";
    if(_dapostcode.length()>0) delivQry+="(dep_type='postal' AND dep_value="+escape.cote(_dapostcode)+") OR ";
    if(_daline2.length()>0) delivQry+="(dep_type='daline2' AND dep_value="+escape.cote(_daline2)+") OR ";
    delivQry = delivQry.substring(0,delivQry.length()-3);
    delivQry +=")";
	Set delivRs=Etn.execute(delivQry);
%>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<%=parseNull(gtmScriptCode.get("SCRIPT_SNIPPET"))%>
<head>
    <link rel="stylesheet" href="<%=GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>">
    <link rel="stylesheet" href="<%=GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>">
	<link rel='stylesheet' href='<%=GlobalParm.getParm("EXTERNAL_LINK")%>css/newui/v2/swiper.min.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>'>
<%=_headhtml%>

    <script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/cart.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/cookie.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
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
<body data-uri="/src/" class="etn-orange-portal-- isWithoutMenu">
<input type='hidden' id='textVoirPlus' value='<%=libelle_msg(Etn, request, "Voir plus")%>'>
<input type='hidden' id='textVoirMoins' value='<%=libelle_msg(Etn, request, "Voir moins")%>'>
<%=parseNull(gtmScriptCode.get("NOSCRIPT_SNIPPET"))%>
<%=_headerHtml%>
<div id="fb-root"></div>
<script async defer crossorigin="anonymous" src="https://connect.facebook.net/fr_FR/sdk.js#xfbml=1&version=v5.0"></script>

<div class="MainOverlay"></div>
<%@ include file="stepbar.jsp"%>
        
<!-- geoCodingAddress can be set to false to disable this functionnality -->
<div class="TunnelDelivery container-lg tunnel-step-2"
     data-mapsConfig='{
     "radius": 1000000000,
     "defaultMapCenter": {
        "lat": 30.12,
        "lng": 30.15
     },
     "geoCodingAddress": "<%=escapeCoteValue(geoCodingAddress.replaceAll("[\\t\\n\\r]+"," "))%>",
     "autoLoadMap": <%=rssite.value("load_map").equals("1")%>,
     "limit": "200",
     "boutiqueLocationType": <%=rssite.value("shop_location_type").equals("")?"[]":escapeCoteValue(rssite.value("shop_location_type")).replaceAll("&#34;","\"")%>,
     "relayPointLocationType": <%=rssite.value("package_point_location_type").equals("")?"[]":escapeCoteValue(rssite.value("package_point_location_type")).replaceAll("&#34;","\"")%>,
     "markersIconsUrl": {
        "normal": "/src/assets/icons/location-pin.png",
        "hover": "/src/assets/icons/location-pin-hover.png",
        "selected": "/src/assets/icons/location-pin-shop.png"
     },
     "errors": {
        "geolocalisationFailed":"<%=libelle_msg_escape(Etn, request, "Sorry, geolocalisation is not supported by your device.")%>",
        "mapLoadingFailed":"<%=libelle_msg_escape(Etn, request, "Sorry, maps are unavailable.")%>",
        "bridgeApiLoadingFailed": "<%=libelle_msg_escape(Etn, request, "Boutique directory are not available for the moment. Please choose address method or retry later.")%>"
     },
     "api": {
        "googleGeocoding": {
            "baseUrl": "https://maps.googleapis.com/maps/api/geocode/json",
            "key": "<%=escapeCoteValue(rssite.value("geocoding_api"))%>"
        },
        "googleMap": {
            "baseUrl": "https://maps.googleapis.com/maps/api/js",
            "key": "<%=escapeCoteValue(rssite.value("googlemap_api"))%>"
        },
		"algoliaBridge": {
            "index": "<%=escapeCoteValue(rssite.value("algolia_stores_index"))%>",
            "appId": "<%=algoliaSettings.get("app_id")%>",
            "apiKey": "<%=algoliaSettings.get("search_key")%>"
        }
	  }
     }'>
    <h2 class="TunnelMainTitle"><%=libelle_msg(Etn, request, "Mode de livraison")%></h2>

    <div class="row">
        <div class="col-12 col-lg-6">

            <div class="JS-DeliverySelector DeliverySelector">
        <%
		boolean anyMapEnabled = false;

        Set rsDeliveryMethods = Etn.execute("select method, subType, min(price+0.0) as price, displayName, count(price) as price_count from "+GlobalParm.getParm("CATALOG_DB")+".delivery_methods where site_id = " + escape.cote(___loadedsiteid) + " and enable=1 group by method order by orderSeq;");
        int count = 0;

        Set rsLang =Etn.execute("select * from language where langue_code="+escape.cote(_lang));
        rsLang.next();
        Set rsShop =Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id="+escape.cote(___loadedsiteid));
        rsShop.next();
        while(rsDeliveryMethods.next()){
			double delvMethodFee = parseNullDouble(rsDeliveryMethods.value("price"));
			if(rsDeliveryMethods.value("method").equals("home_delivery") && applicableHomeDeliveryShippingFees > 0) delvMethodFee = applicableHomeDeliveryShippingFees;
			
			if("1".equals(rsDeliveryMethods.value("mapsDisplay"))) anyMapEnabled = true;
			
			//promo code applicable on shipping fee must be applied on the delivery amounts to keep things consistent on ui
			double discountValue = 0;
			if(PortalHelper.parseNull(cart.getProperty("promo_code")).length() > 0 && cart.hasPromoError() == false)
			{
				Set rsP = Etn.execute("select cp.discount_type, cp.discount_value "+
					" from "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion_coupon cpc "+
					" join "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion cp on cp.id = cpc.cp_id and cp.site_id = "+escape.cote(cart.getProperty("site_id"))+" and cp.element_on = 'shipping_fee' "+
					" where cpc.coupon_code = "+escape.cote(PortalHelper.parseNull(cart.getProperty("promo_code"))));
				if(rsP.next())
				{
					if("fixed".equals(rsP.value("discount_type")))
					{
						discountValue = PortalHelper.parseNullDouble(rsP.value("discount_value"));
					}
					else
					{
						discountValue = (applicableHomeDeliveryShippingFees * PortalHelper.parseNullDouble(rsP.value("discount_value"))/100);
					}
					discountValue = PortalHelper.parseNullDouble(PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), discountValue+"", true));
					
					delvMethodFee = delvMethodFee - discountValue;
					if(delvMethodFee < 0) delvMethodFee = 0;
				}		
			}


        %>
                <div class="custom-control custom-radio DeliverySelector-row">
                    <input type="radio" id="radio-delivery-<%=count%>" name="radio-delivery" class="custom-control-input isPristine" value="<%=rsDeliveryMethods.value("method")%>" <%=(count==0?"checked":"")%> required >
                    <label class="custom-control-label" for="radio-delivery-<%=count%>"><%=libelle_msg(Etn, request, rsDeliveryMethods.value("displayName"))%></label>
                    <p class="m-0 ml-auto delv-method-fee" data-method-id="<%=rsDeliveryMethods.value("method")%>">
                    <span class="txt-starting-from"><%=(parseNullInt(rsDeliveryMethods.value("price_count"))>1?libelle_msg(Etn, request, "A partir de"):"")%></span> <span class="text-primary ml-auto delv-fee-amnt"><%=(delvMethodFee<=0?parseNull(rsShop.value("lang_"+ parseNull(rsLang.value("langue_id"))+"_free_delivery_method")):formatPrice(priceformatter, roundto, showdecimals, ""+delvMethodFee))%>
                            <span style="<%=(delvMethodFee<=0?"display: none;":"")%>"> <%=libelle_msg(Etn, request, defaultcurrency)%></span></span>
                    </p>
                </div>
        
        <%
        count++;
        }

        %>
            </div>

			<% if(rssite.value("load_map").equals("1")) {%>
            <div class="DeliveryMapSection">
                <div class="TunnelDelivery-noBoutiqueText">
                    <p class="d-flex font-weight-bold">
  <span class="d-inline-block mr-2" data-svg="/src/assets/icons/icon-info-3.svg"></span>
  <%=libelle_msg(Etn, request, "Aucune boutique n’est géolocalisée à proximité. Veuillez lancer une nouvelle recherche ou activer la géocalisation.")%>
</p>                    <p>
                        <a href="#"
                           class="d-flex justify-content-end align-items-center font-weight-bold mb-2 JS-TunnelDelivery-selectShop etn-data-layer-event"
                    data-dl_event='standard_click' data-dl_event_category='delivery' data-dl_event_action='button_click' data-dl_event_label='search_shop'>
                            <span class="d-inline-block mr-1"
                                  data-svg="/src/assets/icons/icon-shop.svg"></span>
                            <%=libelle_msg(Etn, request, "Rechercher une boutique")%>
                        </a>
                    </p>
                </div>
                <div class="TunnelDelivery-noRelayPointText">
                    <p class="d-flex font-weight-bold">
    <span class="d-inline-block mr-2" data-svg="/src/assets/icons/icon-info-3.svg"></span>
    <%=libelle_msg(Etn, request, "Aucun point relais n’est géolocalisé à proximité. Veuillez lancer une nouvelle recherche ou activer la géocalisation.")%>
</p>                    <p>
                        <a href="#"
                           class="d-flex justify-content-end align-items-center font-weight-bold mb-2 JS-TunnelDelivery-selectRelayPoint etn-data-layer-event"
                    data-dl_event='standard_click' data-dl_event_category='delivery' data-dl_event_action='button_click' data-dl_event_label='search_shop'>
                            <span class="d-inline-block mr-1"
                                  data-svg="/src/assets/icons/icon-shop.svg"></span>
                            <%=libelle_msg(Etn, request, "Rechercher un point relais")%>
                        </a>
                    </p>
                </div>

                <div class="DeliveryMap">
                    <div class="MapComponent MapComponentMain">
                        <div class="JS-ShopSearch-toggleMap ShopSearch-toggleMap btn">
                            <span>
                                <img src="/src/assets/icons/icon-location-on-map-large.svg"
                                     alt="">
                            </span>
                            <span><%=libelle_msg(Etn, request, "Voir la carte")%></span>
                        </div>
                        <div class="Loading">
                            <img src="/src/assets/icons/icon-reload-white.svg"
                                 alt="Loading">
                        </div>
                    </div>
                </div>
            </div>
			<%}%>
			
            <form class="FormValidator" method="post" data-messages='{"required":"<%=libelle_msg_escape(Etn, request, "Ce champ est requis.")%>", "regex":"<%=libelle_msg_escape(Etn, request, "Ce champ est non valide.")%>", "confirm":"<%=libelle_msg_escape(Etn, request, "Veuillez saisir deux fois la même valeur.")%>"}'>
                <input type="hidden" name="session_token" value="<%=uuidSessionToken%>">
                <div class="DeliveryShopSection JS-isLoadingVue" data-section="pick_up_in_store" id="DeliveryShopSection">

                    <div v-show='selectedBoutique' class="TunnelDelivery-shopForm">

                        <h3 v-if='selectedBoutique' class="TunnelDelivery-title">
                        <input type="hidden" name="daline1" :value="selectedBoutique.name">
                        <input type="hidden" name="daline2" :value="selectedBoutique.localisation.address1">
                        <input type="hidden" name="datowncity" :value="selectedBoutique.city">
                        <input type="hidden" name="dapostalCode" value="">
                        <input type="hidden" name="country" :value="selectedBoutique.localisation.countryName">
                            <span v-show="selectedBoutique.name">{{ selectedBoutique.name }}</span>
                            <span v-show="selectedBoutique.name && selectedBoutique.distance"> - </span>
                            <span v-show="selectedBoutique.distance">{{ Math.round(selectedBoutique.distance / 100) / 10 }}&nbsp;km</span>
                        </h3>

                        <p><%=libelle_msg(Etn, request, "Retrait sous 48h")%></p>

                        <div class="JS-deliveryShowToggleSection DeliveryShopInformations" v-if="selectedBoutique">

                            <p class="DeliveryShopInformations-description" v-show='selectedBoutique.localisation.address1'>{{ selectedBoutique.localisation.address1 }}</p>
                            <p class="DeliveryShopInformations-description" v-show='selectedBoutique.localisation.address2'>{{ selectedBoutique.localisation.address2 }}</p>

                            <p class="font-weight-bold" v-show='selectedBoutique.city'>
                                <span class="d-inline-block DeliveryShopInformations-icon isPin">
                                    <img src="/src/assets/icons/icon-location-pin.svg" alt=""/>
                                </span>
                                {{ selectedBoutique.city | capitalize}}
                            </p>

                            <h3 class="TunnelDelivery-title" v-if='selectedBoutique.openingHours'><%=libelle_msg(Etn, request, "Horaires d'ouverture")%></h3>

                            <div class="DeliverySchedules" v-if='selectedBoutique.openingHours'>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Lundi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.monday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.monday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.monday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Mardi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.tuesday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.tuesday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.tuesday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Mercredi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.wednesday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.wednesday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.wednesday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Jeudi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.thursday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.thursday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.thursday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Vendredi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.friday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.friday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.friday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Samedi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.saturday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.saturday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.saturday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Dimanche")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.sunday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.sunday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.sunday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                            </div>            </div>

                        <div class="d-flex justify-content-between mb-4 DeliveryShopInformations-btnWrapper"
                             v-show='selectedBoutique'>
                            <div style="text-decoration: underline; cursor: pointer;"
                                 class="font-weight-bold JS-deliveryShowToggleBtn"
                                 data-bs-target=".DeliveryShopInformations"
                    data-dl_event='standard_click' data-dl_event_category='delivery_pick_up' data-dl_event_action='button_click' data-dl_event_label='more_details'>
                                <%=libelle_msg(Etn, request, "Voir plus")%>
                            </div>
                            <div style="text-decoration: underline; cursor: pointer;"
                                 class="d-flex align-items-center font-weight-bold JS-change-shop etn-data-layer-event"
                    data-dl_event='standard_click' data-dl_event_category='delivery_pick_up' data-dl_event_action='button_click' data-dl_event_label='change_shop'>
                                <img class="d-inline-block mr-1"
                                     src="/src/assets/icons/icon-reload.svg" alt="change">
                                <%=libelle_msg(Etn, request, "Changer")%>
                            </div>
                        </div>

                        <calendar-picker v-if="selectedBoutique" :opening-hours="selectedBoutique.openingHours"></calendar-picker>

                        <!-- You can construct your own form with hidden value and use selectedBoutique variable (Vue.js) -->
                        <input type="hidden" required name="selected_boutique" :value="encodeURIComponent(JSON.stringify(selectedBoutique))">
                        <input type="hidden" name="delivery_method" value="pick_up_in_store">
                        <input type="hidden" name="delivery_type" value="">

                        <button type="button" onclick="updateCheckout(this)" class="btn btn-primary full-btn-mobile DeliveryPointInformations-nextButton JS-FormValidator-submit">
                            <%=libelle_msg(Etn, request, "Suivant")%>
                        </button>

                    </div>

                </div>
            </form>            
            <form class="FormValidator" method="post" data-messages='{"required":"<%=libelle_msg_escape(Etn, request, "Ce champ est requis.")%>", "regex":"<%=libelle_msg_escape(Etn, request, "Ce champ est non valide.")%>", "confirm":"<%=libelle_msg_escape(Etn, request, "Veuillez saisir deux fois la même valeur.")%>"}'>
                <input type="hidden" name="session_token" value="<%=escapeCoteValue(uuidSessionToken)%>">
                <div class="DeliveryPointSection" data-section="pick_up_in_package_point" id="DeliveryRelaySection">
                    <div v-show='selectedBoutique'>
                        <h3 v-if='selectedBoutique' class="TunnelDelivery-title">
                        <input type="hidden" name="daline1" :value="selectedBoutique.name">
                        <input type="hidden" name="daline2" :value="selectedBoutique.localisation.address1">
                        <input type="hidden" name="datowncity" :value="selectedBoutique.city">
                        <input type="hidden" name="dapostalCode" value="">
                        <input type="hidden" name="country" :value="selectedBoutique.localisation.countryName">
                            <span v-show="selectedBoutique.name">{{ selectedBoutique.name }}</span>
                            <span v-show="selectedBoutique.name && selectedBoutique.distance"> - </span>
                            <span v-show="selectedBoutique.distance">{{ Math.round(selectedBoutique.distance / 100) / 10 }}&nbsp;km</span>
                        </h3>
                        <p><%=libelle_msg(Etn, request, "Retrait sous 48h")%></p>

                        <div class="JS-deliveryShowToggleSection DeliveryPointInformations" v-if="selectedBoutique">
                            <p class="DeliveryPointInformations-description" v-show='selectedBoutique.localisation.address1'>{{ selectedBoutique.localisation.address1 }}</p>
                            <p class="DeliveryPointInformations-description" v-show='selectedBoutique.localisation.address2'>{{ selectedBoutique.localisation.address2 }}</p>
                            <p class="font-weight-bold" v-show='selectedBoutique.city'>
                                <span class="d-inline-block DeliveryPointInformations-icon isPin">
                                    <img src="/src/assets/icons/icon-location-pin.svg" alt=""/>
                                </span>
                                {{ selectedBoutique.city | capitalize}}
                            </p>

                            <h3 class="TunnelDelivery-title" v-if='selectedBoutique.openingHours'><%=libelle_msg(Etn, request, "Horaires d'ouverture")%></h3>

                            <div class="DeliverySchedules" v-if='selectedBoutique.openingHours'>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Lundi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.monday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.monday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.monday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Mardi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.tuesday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.tuesday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.tuesday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Mercredi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.wednesday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.wednesday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.wednesday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Jeudi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.thursday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.thursday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.thursday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Vendredi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.friday.periods.length > 0">
                                            <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.friday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                                                <%=libelle_msg(Etn, request, "24h/24")%>
                                            </div>
                                            <div v-else v-for="(period, index) in selectedBoutique.openingHours.friday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                                            </div>
                                        </div>
                                        <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
                                    </div>
                                </div>
                                <div class="DeliverySchedules-row">
                                    <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Samedi")%></div>
                                    <div class="DeliverySchedules-hours">
                                        <div v-if="selectedBoutique.openingHours.saturday.periods.length > 0">
                <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.saturday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                    <%=libelle_msg(Etn, request, "24h/24")%>
                </div>
                <div v-else v-for="(period, index) in selectedBoutique.openingHours.saturday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                </div>
            </div>
            <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
        </div>
    </div>
    <div class="DeliverySchedules-row">
        <div class="DeliverySchedules-day"><%=libelle_msg(Etn, request, "Dimanche")%></div>
        <div class="DeliverySchedules-hours">
            <div v-if="selectedBoutique.openingHours.sunday.periods.length > 0">
                <div v-if="isSameOpenCloseTime(selectedBoutique.openingHours.sunday.periods)"><%=libelle_msg(Etn, request, "Ouvert")%>
                    <%=libelle_msg(Etn, request, "24h/24")%>
                </div>
                <div v-else v-for="(period, index) in selectedBoutique.openingHours.sunday.periods">{{
                    period.openTime }} - {{ period.closeTime }}
                </div>
            </div>
            <div v-else><%=libelle_msg(Etn, request, "Fermé")%></div>
        </div>
    </div>
</div>            </div>

	<div class="d-flex justify-content-between mb-4 DeliveryPointInformations-btnWrapper"
		 v-show='selectedBoutique'>
		<div style="text-decoration: underline; cursor: pointer;"
			 class="font-weight-bold JS-deliveryShowToggleBtn etn-data-layer-event"
			 data-bs-target=".DeliveryPointInformations"
			data-dl_event='standard_click' data-dl_event_category='delivery_pick_up' data-dl_event_action='button_click' data-dl_event_label='more_details'>
			<%=libelle_msg(Etn, request, "Voir plus")%>
		</div>
		<div style="text-decoration: underline; cursor: pointer;"
			 class="d-flex align-items-center font-weight-bold JS-change-shop etn-data-layer-event"
			data-dl_event='standard_click' data-dl_event_category='delivery_pick_up' data-dl_event_action='button_click' data-dl_event_label='change_shop'>
			<img class="d-inline-block mr-1"
				 src="/src/assets/icons/icon-reload.svg" alt="change">
			<%=libelle_msg(Etn, request, "Changer")%>
		</div>
	</div>

	<!-- You can construct your own form with hidden value and use selectedBoutique variable (Vue.js) -->
	<input type="hidden" required name="selected_boutique" :value="encodeURIComponent(JSON.stringify(selectedBoutique))">
	<input type="hidden" name="delivery_method" value="pick_up_in_package_point">
	<input type="hidden" name="delivery_type" value="">

	<button type="button" onclick="updateCheckout(this)" class="btn btn-primary full-btn-mobile DeliveryPointInformations-nextButton JS-FormValidator-submit">
	<%=libelle_msg(Etn, request, "Suivant")%>
	</button>

	</div>

	</div>
</form>            
	<div class="DeliveryAddressSection" data-section="home_delivery">
    <form class="FormValidator DeliveryAddressForm" method="post" data-messages='{"required":"<%=libelle_msg_escape(Etn, request, "Ce champ est requis.")%>", "regex":"<%=libelle_msg_escape(Etn, request, "Ce champ est non valide.")%>", "confirm":"<%=libelle_msg_escape(Etn, request, "Veuillez saisir deux fois la même valeur.")%>"}'>
        <input type="hidden" name="session_token" value="<%=escapeCoteValue(uuidSessionToken)%>">
        <input type="hidden" name="selected_boutique" value="">
        <input type="hidden" name="rdv_boutique" value="">
        <input type="hidden" name="rdv_date" value="">
        <div class="DeliveryAddressSection-preview">

            <h3 class="TunnelDelivery-title JS-deliveryNamePreview"></h3>
            <div class="DeliveryAddressSection-previewAddress">
                <div class="JS-deliveryAddressPreview"></div>
                <div style="text-decoration: underline; cursor: pointer;" class="d-flex align-items-center font-weight-bold JS-change-address etn-data-layer-event"
                    data-dl_event='standard_click' data-dl_event_category='delivery_adress' data-dl_event_action='button_click' data-dl_event_label='change_adress'>
                    <span class="d-inline-block mr-1" data-svg="/src/assets/icons/icon-reload.svg"></span>
                    <%=libelle_msg(Etn, request, "Changer")%>
                </div>
            </div>
                <%
                    String qry = "";
                    if(delivRs.rs.Rows!=0){
                        qry = "select subType, price from "+GlobalParm.getParm("CATALOG_DB")+".delivery_methods where site_id = " + escape.cote(___loadedsiteid) + " and enable=1 and method='home_delivery' and ( ";
                        while(delivRs.next()){
                            qry+=" subType="+escape.cote(parseNull(delivRs.value("delivery_type")))+" OR ";
                        }
                        qry = qry.substring(0,qry.length()-3)+" ) ";                       
                        qry+=" order by price, orderSeq";
                    }
                    else
                        qry = "select subType, price from "+GlobalParm.getParm("CATALOG_DB")+".delivery_methods where site_id = " + escape.cote(___loadedsiteid) + " and enable=1 and method='home_delivery' order by price, orderSeq";
                    Set rsDeliveryMethodSubTypes = Etn.execute(qry);
                %>
            <div id="deliveryTypeContainer" class="form-group">
                <label for="delivery_type" class="is-required">
                    <%=libelle_msg(Etn, request, "Type de livraison")%> :
                </label><br>
                <select class="custom-select isPristine col-md-6" id="delivery_type" name="delivery_type">
                    <%      
                    boolean isFirst = true;
                    while(rsDeliveryMethodSubTypes.next()){
					String _slct = "";
					if(_deliveryType.length() > 0 && _deliveryType.equals(rsDeliveryMethodSubTypes.value("subType"))) _slct = "selected";
					else if(_deliveryType.length() == 0 && isFirst) _slct = "selected";
                    %>
                    <option <%=_slct%> value="<%=escapeCoteValue(rsDeliveryMethodSubTypes.value("subType"))%>"><%=rsDeliveryMethodSubTypes.value("subType")%></option>
                    <%
                        if(rsDeliveryMethodSubTypes.value("subType").length()>0) isFirst = false;
                    }
                    %>
                </select>
                <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Type non valide")%></div>
            </div>
            <button type="button" onclick="updateCheckout(this)" class="btn btn-primary full-btn-mobile DeliveryAddressSection-nextButton JS-FormValidator-submit"><%=libelle_msg(Etn, request, "Suivant")%></button>
        </div>

        <div class="DeliveryAddressSection-form FormValidator-step">
            <div class="form-row">
                <div class="form-group col-12 col-lg-6">
                    <label for="name" class="is-required"><%=libelle_msg(Etn, request, "Nom")%></label>
                    <input type="text" class="form-control isPristine DeliveryAddressSection-formName" id="surnames" name="surnames" placeholder="<%=escapeCoteValue(parseNull(cart.getProperty("surnames")))%>" required data-required-error="<%=libelle_msg_escape(Etn, request, "Le nom est requis.")%>" value="<%=escapeCoteValue(parseNull(cart.getProperty("surnames")))%>">
                    <div class="invalid-feedback"></div>
                </div>
                <div class="form-group col-12 col-lg-6">
                    <label for="surnames" class="is-required"><%=libelle_msg(Etn, request, "Prénom")%></label>
                    <input type="text" class="form-control isPristine DeliveryAddressSection-formFirstName" id="name" name="name" placeholder="<%=escapeCoteValue(parseNull(cart.getProperty("name")))%>" required data-required-error="<%=libelle_msg_escape(Etn, request, "Le prénom est requis.")%>" value="<%=escapeCoteValue(parseNull(cart.getProperty("name")))%>">
                    <div class="invalid-feedback"></div>
                </div>
            </div>
            <div class="form-group">
                <label for="baline1" class="is-required"><%=libelle_msg(Etn, request, "Adresse")%></label>
                <textarea class="form-control isPristine DeliveryAddressSection-formAddress" id="baline1" name="daline1" placeholder="<%=escapeCoteValue(parseNull(cart.getProperty("baline1")))%>" required data-required-error="<%=libelle_msg_escape(Etn, request, "L'adresse est requise.")%>"><%=escapeCoteValue((parseNull(cart.getProperty("daline1")).length()>0?parseNull(cart.getProperty("daline1")):parseNull(cart.getProperty("baline1"))))%></textarea>
                <div class="invalid-feedback"></div>
            </div>
            <div class="form-group">
                <label for="baline2"><%=libelle_msg(Etn, request, "Complément d'adresse")%></label>
                <input type="text" class="form-control isPristine DeliveryAddressSection-formAddressComplement" id="baline2" name="daline2" placeholder="<%=escapeCoteValue(parseNull(cart.getProperty("baline2")))%>" value="<%=escapeCoteValue((parseNull(cart.getProperty("daline2")).length()>0?parseNull(cart.getProperty("daline2")):parseNull(cart.getProperty("baline2"))))%>">
                <div class="invalid-feedback"></div>
            </div>
            <div class="form-group">
                <label for="bapostalCode" class="is-required"><%=libelle_msg(Etn, request, "Code postal")%></label>
                <input type="text" class="form-control isPristine DeliveryAddressSection-formPostalCode" id="bapostalCode" name="dapostalCode" placeholder="<%=escapeCoteValue(parseNull(cart.getProperty("bapostalCode")))%>" required data-required-error="<%=libelle_msg_escape(Etn, request, "Le code postal est requis.")%>" value="<%=escapeCoteValue((parseNull(cart.getProperty("dapostalCode")).length()>0?parseNull(cart.getProperty("dapostalCode")):parseNull(cart.getProperty("bapostalCode"))))%>">
                <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Code postal non valide")%></div>
            </div>
            <div class="form-group">
                <label for="batowncity" class="is-required"><%=libelle_msg(Etn, request, "Ville")%></label>
                <input type="text" class="form-control isPristine DeliveryAddressSection-formCity" id="batowncity" name="datowncity" placeholder="<%=escapeCoteValue(parseNull(cart.getProperty("batowncity")))%>" required data-required-error="<%=libelle_msg_escape(Etn, request, "La ville est requise.")%>" value="<%=escapeCoteValue((parseNull(cart.getProperty("datowncity")).length()>0?parseNull(cart.getProperty("datowncity")):parseNull(cart.getProperty("batowncity"))))%>">
                <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Ville non valide")%></div>
            </div>
            <input type="hidden" name="delivery_method" value="home_delivery">
            <div class="DeliveryAddressForm-buttons">
                <button type="button" class="btn btn-secondary JS-TunnelAddressSectionReturn etn-data-layer-event"
                    data-dl_event='standard_click' data-dl_event_category='delivery_adress' data-dl_event_action='button_click' data-dl_event_label='back'><%=libelle_msg(Etn, request, "Retour")%></button>
                <button type="button" class="btn btn-primary JS-TunnelAddressSectionValidate JS-FormValidator-stepSubmit etn-data-layer-event"
                    data-dl_event='standard_click' data-dl_event_category='delivery_adress' data-dl_event_action='button_click' data-dl_event_label='confirm'><%=libelle_msg(Etn, request, "Confirmer")%></button>
            </div>
        </div>
    </form>
</div>

<section class="ShopSearch isHidden">
  <div class="ShopSearch-content p-2" style="height: 100%;">
    <button type="button" class="ShopSearch-backBtn btn btn-link d-flex align-items-center mb-2 p-0 w-100 JS-shop-search-close">
      <span class="d-inline-block" data-svg="/src/assets/icons/icon-angle-left-small.svg"></span>
      <%=libelle_msg(Etn, request, "Mode de livraison")%>
    </button>
    <div class="d-flex">
      <div class="form-group w-100">
        <label for="lastname" class="is-required sr-only"><%=libelle_msg(Etn, request, "Rechercher une boutique")%></label>
        <div class="ShopSearch-inputWrapper">
          <input type="search" class="ShopSearch-input JS-ShopSearch-input form-control" id="shop-search" name="shop-search">
          <span class="ShopSearch-localisationBtn JS-geolocalisationSearchButton" data-svg="/src/assets/icons/icon-target-localisation.svg"></span>
            <div class="ShopSearch-autocompleteContainer JS-autocompleteHidden">
                <div class="ShopSearch-autocomplete" id="ShopSearch-autocomplete" v-show="displayedCities.length > 0">
                    <div @click="autocompleteClicked(city.original)" class="ShopSearch-autocompleteItem JS-autocompleteSelection" v-for="city in displayedCities" v-html="city.bold"></div>
                </div>
            </div>
        </div>
        <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Nom non valide")%></div>
      </div>
      <button type="submit" class="ShopSearch-submit btn btn-primary flex-shrink-0 ml-2 p-0 JS-searchBoutiqueButton">
        <span class="d-inline-block" data-svg="/src/assets/icons/icon-search-white.svg"></span>
      </button>
    </div>
    <div class="TunnelDelivery-noBoutiqueText">
      <p class="d-flex font-weight-bold">
  <span class="d-inline-block mr-2" data-svg="/src/assets/icons/icon-info-3.svg"></span>
  <%=libelle_msg(Etn, request, "Aucune boutique n’est géolocalisée à proximité. Veuillez lancer une nouvelle recherche ou activer la géocalisation.")%>
</p>    </div>
      <div class="TunnelDelivery-noRelayPointText">
          <p class="d-flex font-weight-bold">
    <span class="d-inline-block mr-2" data-svg="/src/assets/icons/icon-info-3.svg"></span>
    <%=libelle_msg(Etn, request, "Aucun point relais n’est géolocalisé à proximité. Veuillez lancer une nouvelle recherche ou activer la géocalisation.")%>
</p>      </div>
      <div class="ShopSearchTabs JS-ShopSearchTabs">
  <div class="ShopSearchTabsPanel d-flex border-bottom border-light" role="tablist" aria-label="Boutiques">
      <button type="button" role="tab" class="JS-tabBoutiqueList active" onclick="trackListHeader()">
    <span class="d-inline-block mr-1" data-svg="/src/assets/icons/icon-list.svg"></span>
      Liste
    </button>
    <button type="button" role="tab" class="JS-tabShopMap" onclick="trackMapHeader()">
    <span class="d-inline-block mr-1" data-svg="/src/assets/icons/icon-location-on-map.svg"></span>
      Carte
    </button>
  </div>
  <div role="tabpanel" class="JS-tabContentBoutiqueList">
      <div v-show="boutiques.length > 0" class="ShopSearch-results" id="boutiqueList">

    <div v-if="getLocationType() === 'boutique'">
        <div v-if="searchType() === 'list'">
            <p v-if="boutiques.length === 1" class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "boutique disponible")%>
            </p>
            <p v-else class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "boutiques disponibles")%>
            </p>
        </div>
        <div v-else-if="searchType() === 'geolocation'">
            <p v-if="boutiques.length === 1" class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "boutique à proximité")%>
            </p>
            <p v-else class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "boutiques à proximité")%>
            </p>
        </div>
        <div v-else-if="searchType() === 'search'">
            <p v-if="boutiques.length === 1" class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "boutique pour la recherche")%>
                «&nbsp;<span class="text-primary">{{ query | capitalize }}</span>&nbsp;»
            </p>
            <p v-else class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "boutiques pour la recherche")%>
                «&nbsp;<span class="text-primary">{{ query | capitalize }}</span>&nbsp;»
            </p>
        </div>
    </div>


    <div v-else-if="getLocationType() === 'relayPoint'">
        <div v-if="searchType() === 'list'">
            <p v-if="boutiques.length === 1" class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "point relais disponible")%>
            </p>
            <p v-else class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "points relais disponibles")%>
            </p>
        </div>
        <div v-else-if="searchType() === 'geolocation'">
            <p v-if="boutiques.length === 1" class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "point relais à proximité")%>
            </p>
            <p v-else class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "points relais à proximité")%>
            </p>
        </div>
        <div v-else-if="searchType === 'search'">
            <p v-if="boutiques.length === 1" class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "point relais pour la recherche")%>
                «&nbsp;<span class="text-primary">{{ query | capitalize }}</span>&nbsp;»
            </p>
            <p v-else class="font-weight-bold mb-2">
                <span class="text-primary">{{ boutiques.length }}</span> <%=libelle_msg(Etn, request, "points relais pour la recherche")%>
                «&nbsp;<span class="text-primary">{{ query | capitalize }}</span>&nbsp;»
            </p>
        </div>
    </div>


    <ul>
        <li @click="focusBoutique(boutique, $event)" @mouseenter="highlightMarker(boutique, true)"
            @mouseleave="highlightMarker(boutique, false)" v-for="boutique in boutiques" class="ShopResult"
            :class="getShopResultClasses(boutique)">
            <h3 class="ShopResult-title mb-1">{{ boutique.name }} <span v-show="boutique.distance">- {{ Math.round(boutique.distance / 100) / 10 }}&nbsp;km</span>
            </h3>
            <div class="ShopResult-content">
                <div><%=libelle_msg(Etn, request, "Retrait sous 48h")%></div>
                <button type="button" class="ShopResult-selectButton btn btn-primary btn-inverse btn-sm"
                        @click="selectBoutique(boutique)">
                    <template v-if="isSelected(boutique)"><%=libelle_msg(Etn, request, "Sélectionné")%></template>
                    <template v-else><%=libelle_msg(Etn, request, "Sélectionner")%></template>
                </button>
            </div>
        </li>
    </ul>
</div>
  </div>
</div>
  </div>
  <div class="ShopSearch-map MapComponent MapComponentBig JS-tabContentShopMap JS-tabContentShopMap-hide">
    <div class="JS-ShopSearch-toggleMap ShopSearch-toggleMap btn">
      <span class="d-inline-block" data-svg="/src/assets/icons/icon-location-on-map-large.svg"></span>
      <span><%=libelle_msg(Etn, request, "Voir la carte")%></span>
    </div>
  </div>
</section>

        </div>
        <div class="StickySidebar col-12 col-lg-4 offset-lg-2" data-sticky-options='{"startTrigger": 20}'>
            <div class="StickySidebar-content OrderSummary">
                <jsp:include page="../calls/getRecap.jsp">
                    <jsp:param name="site_id" value="<%=___loadedsiteid%>"/>
                    <jsp:param name="lang" value="<%=_lang%>"/>
                    <jsp:param name="menu_id" value="<%=escapeCoteValue(__cartmenuid)%>"/>					
                    <jsp:param name="___loadedlangid" value='<%=parseNull(rsShop.value("lang_"+ parseNull(rsLang.value("langue_id"))+"_free_delivery_method"))%>'/>					
                </jsp:include>
            </div>
        </div>
    </div>

</div>

<div class="Modal modal fade DeliveryCostAlert" id="deliveryCostAlertModal" tabindex="-1" role="dialog"
     aria-labelledby="deliveryCostAlertLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <form class="modal-content">
            <h5 class="modal-title DeliveryCostAlert-title"><%=libelle_msg(Etn, request, "Afficher sur une carte")%></h5>
            <p class="DeliveryCostAlert-paragraph"><%=libelle_msg(Etn, request, "Lorsque vous affichez sur la carte, des données mobiles")%>
                <%=libelle_msg(Etn, request, "supplémentaires sont nécessaires, un surcoût sera consommé sur votre forfait.")%></p>
            <div class="custom-control custom-checkbox">
                <input type="checkbox" class="custom-control-input" id="stopWarning">
                <label class="custom-control-label" for="stopWarning"><%=libelle_msg(Etn, request, "Ne plus m'avertir")%></label>
            </div>
            <div class="modal-footer DeliveryCostAlert-footer">
                <button type="button" class="btn btn-secondary etn-data-layer-event" data-dismiss="modal"
                    data-dl_event='standard_click' data-dl_event_category='popin_show_in_map' data-dl_event_action='button_click' data-dl_event_label='cancel'><%=libelle_msg(Etn, request, "Annuler")%></button>
                <button type="button" class="btn btn-primary JS-loadButton etn-data-layer-event"
                    data-dl_event='standard_click' data-dl_event_category='popin_show_in_map' data-dl_event_action='button_click' data-dl_event_label='display'><%=libelle_msg(Etn, request, "Afficher")%></button>
            </div>
        </form>
    </div>
</div>


<template id="calendarPickerTemplate">
    <div class="CalendarPicker">

        <div class="form-group">
            <div class="d-block font-weight-bold mb-3">
                <%=libelle_msg(Etn, request, "Souhaitez-vous prendre rendez-vous en boutique ?")%>
            </div>
            <div class="custom-control custom-radio custom-control-inline">
                <input type="radio" id="rdv-boutique-oui"
                       name="rdv_boutique"
                       v-model="rendezVous"
                       :value="true"
                       class="custom-control-input JS-FormValidator-ignore">
                <label for="rdv-boutique-oui" class="custom-control-label">
                    <%=libelle_msg(Etn, request, "Oui")%>
                </label>
            </div>
            <div class="custom-control custom-radio custom-control-inline">
                <input type="radio" id="rdv-boutique-non"
                       name="rdv_boutique"
                       v-model="rendezVous"
                       :value="false"
                       class="custom-control-input JS-FormValidator-ignore">
                <label for="rdv-boutique-non" class="custom-control-label">
                    <%=libelle_msg(Etn, request, "Non")%>
                </label>
            </div>
            <div class="invalid-feedback mt-1 mb-3"><%=libelle_msg(Etn, request, "Veuillez choisir une civilité")%></div>
        </div>

        <div v-show="rendezVous" class="CalendarPicker-form form-row">
            <div class="CalendarPicker-calendarWidget form-group col-12 col-lg-6">
                <label for="calendar-picker-date" class="is-required"><%=libelle_msg(Etn, request, "Date")%></label>
                <input type="text"
                       id="calendar-picker-date"
                       @focus="openDate"
                       @keyup.enter="checkDateInput"
                       @keydown.enter.prevent
                       @focusout="checkDateInput"
                       :readonly="isMobile"
                       :placeholder="dateContext.format('YYYY-MM-DD')"
                       class="form-control JS-FormValidator-ignore etn-data-layer-event"
                       :class="{'is-invalid': !dateIsValid }"
                       v-model="displayDate"
                    data-dl_event='standard_click' data-dl_event_category='delivery_pick_up' data-dl_event_action='button_click' data-dl_event_label='change_date'>
                <div class="CalendarPicker-wrapper" v-if="dateIsVisible" @click="closeDate($event)">
                    <div class="CalendarWidget" :class="{'isDark':isDark}">
                        <div class="CalendarWidget-header">
                            <div class="CalendarWidget-title h4 mb-0">{{ currentMonth }}</div>
                            <div class="CalendarWidget-navigation">
                                <div class="CalendarWidget-prev" @click="subtractMonth">
                                    <img v-if="!isDark" src="/src/assets/icons/icon-angle-left.svg" alt="">
                                    <img v-else-if="isDark" src="/src/assets/icons/icon-angle-left-dark.svg" alt="">
                                </div>
                                <div class="CalendarWidget-next" @click="addMonth">
                                    <img v-if="!isDark" src="/src/assets/icons/icon-angle-right.svg" alt="">
                                    <img v-else-if="isDark" src="/src/assets/icons/icon-angle-right-dark.svg" alt="">
                                </div>
                            </div>
                        </div>
                        <ul class="CalendarWidget-weekdays">
                            <li class="CalendarWidget-date isWeekDay" v-for="day in days">{{ day }}</li>
                        </ul>
                        <ul class="CalendarWidget-dates">
                            <li class="CalendarWidget-date isEmpty" v-for="blank in firstDayOfMonth"></li>
                            <li v-for="day in daysInMonth"
                                class="CalendarWidget-date"
                                :class="getDateClasses(day)"
                                @click="selectDate(day)">
                                <div :class="getDateClasses(day)"
                                     class="CalendarWidget-layer isDate">
                                    {{day}}
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="CalendarPicker-hourWidget form-group col-12 col-lg-6">
                <label for="calendar-picker-hour" class="is-required"><%=libelle_msg(Etn, request, "Heure")%></label>
                <input type="text"
                       id="calendar-picker-hour"
                       @focus="openHour"
                       @keyup.enter="checkHourInput"
                       @keydown.enter.prevent
                       @focusout="checkHourInput"
                       :readonly="isMobile"
                       :placeholder="dateContext.format('LT')"
                       :disabled="!selectedMoment"
                       class="form-control JS-FormValidator-ignore etn-data-layer-event"
                       :class="{'is-invalid': !hourIsValid }"
                       v-model="displayHour"
                    data-dl_event='standard_click' data-dl_event_category='delivery_pick_up' data-dl_event_action='button_click' data-dl_event_label='change_time'>
                <div class="CalendarPicker-wrapper" v-if="hourIsVisible" @click="closeHour($event)">
                    <div class="HourWidget">
                        <div class="HourWidget-hours">
                            <div class="HourWidget-more" @click="addHour">
                                <img v-if="!isDark" src="/src/assets/icons/icon-angle-right.svg" alt="">
                                <img v-else-if="isDark" src="/src/assets/icons/icon-angle-right-dark.svg" alt="">
                            </div>
                            <div class="HourWidget-value">{{ selectedHour }}</div>
                            <div class="HourWidget-less" @click="removeHour">
                                <img v-if="!isDark" src="/src/assets/icons/icon-angle-right.svg" alt="">
                                <img v-else-if="isDark" src="/src/assets/icons/icon-angle-right-dark.svg" alt="">
                            </div>
                        </div>
                        <div class="HourWidget-minutes">
                            <div class="HourWidget-more" @click="addMinute">
                                <img v-if="!isDark" src="/src/assets/icons/icon-angle-right.svg" alt="">
                                <img v-else-if="isDark" src="/src/assets/icons/icon-angle-right-dark.svg" alt="">
                            </div>
                            <div class="HourWidget-value">{{ selectedMinute }}</div>
                            <div class="HourWidget-less" @click="removeMinute">
                                <img v-if="!isDark" src="/src/assets/icons/icon-angle-right.svg" alt="">
                                <img v-else-if="isDark" src="/src/assets/icons/icon-angle-right-dark.svg" alt="">
                            </div>
                        </div>
                        <div class="HourWidget-meridiem" v-if="hasMeridiem">
                            <div class="HourWidget-more" @click="addMeridiem">
                                <img v-if="!isDark" src="/src/assets/icons/icon-angle-right.svg" alt="">
                                <img v-else-if="isDark" src="/src/assets/icons/icon-angle-right-dark.svg" alt="">
                            </div>
                            <div class="HourWidget-value">{{ selectedPeriod }}</div>
                            <div class="HourWidget-less" @click="removeMeridiem">
                                <img v-if="!isDark" src="/src/assets/icons/icon-angle-right.svg" alt="">
                                <img v-else-if="isDark" src="/src/assets/icons/icon-angle-right-dark.svg" alt="">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <input ref="input" readonly type="hidden" :required="rendezVous" :name="name" v-model="rawDate">

        </div>

    </div>
</template>

<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/jquery-min.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/moment-7-5.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/jquery.tablesorter.min.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/swiper.min.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/boosted.bundle.min.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/bs-custom-file-input.min.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/vue-7-5.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/vendors-7-5.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/tunnel-7-5.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/form-validator-7-5.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/search-7-5.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

<script type="text/javascript" src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/algoliasearch.min.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

<script type="text/javascript">
    console.log('init var');
    accessibilitytoolbar_custom = {
        idContainer: "containerConfortPlus",

        // MANDATORY : ID of the target container which will include the link. If not null, activate the display in link mode. The link will be added as the last element of the target container. 
        //idLinkModeContainer : "containerOrangeConfortPlus",

        // OPTIONAL (put it as comments if useless) CSS class applied on the link to unify its appearance with the site.
        //cssLinkModeClassName : "position-absolute fixed-top",
        
        // OPTIONAL (put it as comments if useless) When the service is displayed as a link in the page, a skip link is automatically added at the top of the page. If you already have a group of skip links, you can specify the target container where the skip link will be added. The link will be added as the last element of the target container. 
        //idSkipLinkIdLinkMode : "containerOrangeConfortPlus", 

        // OPTIONAL (put it as comments if useless) CSS class applied on the skip link
        //cssSkipLinkClassName : "position-absolute fixed-top" 
    };
</script>

<script>
  if (!window.OrangeLibrary) {
    window.OrangeLibrary = new Map()
  }
  if (!window.OrangeLibrary.PopinMarker) {
    window.OrangeLibrary.PopinMarker = new Map()
  }
  /*window.OrangeLibrary.PopinMarker.set('displayTitle', function (boutique) { // You can override Popin Marker title display
    var content = "";
    if (boutique.name) {
      content += boutique.name;
    }
    if (boutique.name && boutique.distance) {
      content += ' - ';
    }
    if (boutique.distance) {
      content += Math.round(boutique.distance / 100) / 10 + ' km';
    }
    return content;
  });*/
  window.OrangeLibrary.PopinMarker.set('displayContent', function (boutique) {
    return "<%=libelle_msg(Etn, request, "Retrait sous 48h")%>";
  });
</script>

<template id="popinMarkerTemplate">
    <div class="PopinMarker">
        <div class="PopinMarker-title"></div>
        <div class="PopinMarker-content"></div>
        <div class="btn btn btn-primary btn-sm PopinMarker-button"><%=libelle_msg(Etn, request, "Sélectionner")%></div>
    </div>
</template>

<!-- Modal -->
<div class="modal fade" id="navSearchModal" tabindex="-1" role="dialog" aria-labelledby="navSearchModalTitle"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">

            <div class="navSearchModal-back" data-dismiss="modal">
                <span data-svg="/src/assets/icons/icon-angle-left.svg"></span>
                Retour
            </div>

            <!---->

            <div class="NavSearch isModal" aria-expanded="false">
                <div class="container-lg">

                    <form class="SearchForm" action="">
    <div class="SearchForm-inputWrapper">
        <input type="text" class="SearchForm-input" />
        <div class="SearchForm-inputButton">
            <span class="SearchForm-inputClear"
                  data-svg="/src/assets/icons/icon-close.svg"></span>
            <span class="SearchForm-inputMicro"
                  data-svg="/src/assets/icons/icon-microphone.svg"></span>
        </div>
    </div>
    <button type="submit" class="SearchForm-submit btn btn-primary">
        <span data-svg="/src/assets/icons/icon-search.svg"></span>
        Rechercher
    </button>
</form>

                    <div class="TopTendances">
                        <h2 class="TopTendances-title-big">Top tendances</h2>
                        <div class="TopTendances-date">28 janvier 2019</div>
                        <ul class="TopTendances-items Autosearch-items"></ul>
                    </div>

                    <div class="SearchSuggest">
                        <div class="SearchSuggest-title">Suggestions</div>
                        <ul class="SearchSuggest-items"></ul>
                    </div>

                    <div class="NavSearch-resultsContainer">
                        <div class="Results">

                            <div class="Results-mobile swiper-container">
                                <div class="swiper-wrapper">

                                    <div class="NavSearch-ProduitsServices swiper-slide"
                                         id="block-products-services-mobile">
                                        <div class="Results-header">
                                            <span data-svg="/src/assets/icons/icon-sim.svg"></span>
                                            <div class="Results-titleWrapper">
                                                <h3 class="Results-title">
                                                    Produits et services
                                                </h3>
                                                <span class="Results-number"></span>
                                            </div>
                                        </div>
                                        <div class="NavSearch-productsResultsWrapper JS-NavSearch-greyFrame">
                                            <ul class="Results-items SearchProduct-wrapper resultProductsWrapper"></ul>
                                            <ul class="Results-items SearchService-wrapper resultServicesWrapper"></ul>
                                                                                            <a href="/dist/page-search.html"
                                                   class="btn btn-secondary NavSearch-showMoreResults">Voir
                                                    tous les résultats</a>
                                                                                    </div>
                                    </div>

                                    <div class="NavSearch-Assistance swiper-slide" id="block-assistance-mobile">
                                        <div class="Results-header">
                                            <span data-svg="/src/assets/icons/icon-customer-service.svg"></span>
                                            <div class="Results-titleWrapper">
                                                <h3 class="Results-title">
                                                    Assistance
                                                </h3>
                                                <span class="Results-number"></span>
                                            </div>
                                        </div>
                                        <div class="NavSearch-assistanceResultsWrapper JS-NavSearch-greyFrame">
                                            <ul class="Results-items resultAssistanceWrapper"></ul>
                                                                                            <a href="/dist/page-search.html"
                                                   class="btn btn-secondary NavSearch-showMoreResults">Voir
                                                    tous les résultats</a>
                                                                                    </div>
                                    </div>


                                    <div class="NavSearch-Videos swiper-slide" id="block-videos-mobile">
                                        <div class="Results-header">
                                            <span data-svg="/src/assets/icons/icon-playB.svg"></span>
                                            <div class="Results-titleWrapper">
                                                <h3 class="Results-title">
                                                    Vidéos
                                                </h3>
                                                <span class="Results-number"></span>
                                            </div>
                                        </div>
                                        <div class="NavSearch-videosResultsWrapper JS-NavSearch-greyFrame">
                                            <ul class="Results-items resultVideosWrapper isRow"></ul>
                                                                                            <a href="/dist/page-search.html"
                                                   class="btn btn-secondary NavSearch-showMoreResults">Voir
                                                    tous les résultats</a>
                                                                                    </div>
                                    </div>


                                    <div class="NavSearch-Magazine swiper-slide" id="block-magazine-mobile">
                                        <div class="Results-header">
                                            <span data-svg="/src/assets/icons/icon-mag.svg"></span>
                                            <div class="Results-titleWrapper">
                                                <h3 class="Results-title">
                                                    Le magazine
                                                </h3>
                                                <span class="Results-number"></span>
                                            </div>
                                        </div>
                                        <div class="NavSearch-magazineResultsWrapper JS-NavSearch-greyFrame">
                                            <ul class="Results-items resultMagazineWrapper"></ul>
                                                                                            <a href="/dist/page-search.html"
                                                   class="btn btn-secondary NavSearch-showMoreResults">Voir
                                                    tous les résultats</a>
                                                                                    </div>
                                    </div>


                                    <div class="NavSearch-Marques swiper-slide" id="block-brands-mobile">
                                        <div class="Results-header">
                                            <span data-svg="/src/assets/icons/icon-smartphone.svg"></span>
                                            <div class="Results-titleWrapper">
                                                <h3 class="Results-title">
                                                    Les marques
                                                </h3>
                                                <span class="Results-number"></span>
                                            </div>
                                        </div>
                                        <ul class="Results-items resultBrandsWrapper JS-NavSearch-greyFrame"></ul>
                                    </div>
                                </div><!-- /.swiper-wrapper -->
                            </div><!-- /.swiper-container -->

                        </div><!-- /.Results -->
                    </div><!-- /.NavSearch-resultsContainer -->

                </div>

                        <div class="NoResultBlock">
            <div class="container-lg">
                <span class="NoResultBlock-title">Oups !!! Aucun résultat ne correspond à votre recherche.</span>
                          </div>
            <div class="NoResultBlock-yellowSection">
                <div class="container-lg">
                    <div class="NoResultBlock-yellowSection-title">
                        Certains liens, ci-dessous, peuvent vous aider dans votre recherche&nbsp;:
                    </div>

                    <ul class="NoResultBlock-yellowSection-items">
                        <li>
                            <a href="#">
                                <span data-svg="/src/assets/icons/icon-sim.svg"></span>
                                <span class="NoResultBlock-item">Les offres Orange</span>
                            </a>
                        </li>
                        <li>
                            <a href="#">
                                <span data-svg="/src/assets/icons/icon-smartphone.svg"></span>
                                <span class="NoResultBlock-item">Les mobiles</span>
                            </a>
                        </li>
                        <li>
                            <a href="#">
                                <span data-svg="/src/assets/icons/icon-customer-service.svg"></span>
                                <span class="NoResultBlock-item">L’assistance</span>
                            </a>
                        </li>
                        <li>
                            <a href="#">
                                <span data-svg="/src/assets/icons/icon-mag.svg"></span>
                                <span class="NoResultBlock-item">Le magazine</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        
            </div>

            <div class="hr-line"></div>
        </div>
    </div>
</div>

<template id="resultProductsTemplate">
    <li class="SearchProduct">
        <a target="_blank">
            <div class="SearchProduct-imgWrapper">
                <img src="/src/assets/examples/image-smartphone.png" alt="">
            </div>
            <div class="SearchProduct-textWrapper">
                <div class="SearchProduct-title"></div>
                <div class="SearchProduct-subtitle">
                    <div class="SearchProduct-price"></div>
                </div>
                <div class="SearchProduct-content"></div>
            </div>
        </a>
    </li>
</template>

<template id="resultServicesTemplate">
    <li class="SearchResult">
        <a target="_blank">
            <div class="SearchResult-title"></div>
            <div class="SearchResult-price" data-from="À partir de" data-monthly="/mois"></div>
            <div class="SearchResult-content"></div>
        </a>
    </li>
</template>

<template id="resultAssistanceTemplate">
    <li class="SearchResult">
        <a target="_blank">
            <div class="SearchResult-title"></div>
            <div class="SearchResult-content"></div>
        </a>
    </li>
</template>

<template id="resultMagazineTemplate">
    <li class="SearchResult">
        <a target="_blank">
            <div class="SearchResult-title"></div>
            <div class="SearchResult-content">
            </div>
        </a>
    </li>
</template>

<template id="resultVideosTemplate">
    <li class="SearchVideo">
        <a target="_blank">
            <div class="SearchVideo-imgWrapper">
                <img class="SearchVideo-img" src="/src/assets/examples/rectangle-1.png"
                     alt="">
                <img class="SearchVideo-play" src="/src/assets/icons/icon-playB.svg"
                     alt="">
            </div>
            <div class="SearchVideo-textWrapper">
                <div class="SearchVideo-title"></div>
                <div class="SearchVideo-content"></div>
            </div>
        </a>
    </li>
</template>

<template id="resultBrandsTemplate">
    <li class="SearchBrand">
        <a target="_blank">
            <div class="SearchBrand-imgWrapper">
                <img class="SearchBrand-img" src="" alt="">
            </div>
            <div class="SearchBrand-content">
                AppleX
            </div>
        </a>
    </li>
</template>

<template id="resultSuggestTemplate">
    <li></li>
</template>


<template id="resultCountPlural">
    <div>
        <span class="SearchDetails-count"></span> résultats pour «&nbsp;<span class="SearchDetails-keyword"></span>&nbsp;»
    </div>
</template>

<template id="resultCountSingular">
    <div>
        <span class="SearchDetails-count">'</span> résultats pour «&nbsp;<span class="SearchDetails-keyword"></span>&nbsp;»
    </div>
</template>

<template id="resultCountNull">
    <div>
        Aucun résultat pour «&nbsp;<span class="SearchDetails-keyword"></span>&nbsp;»
    </div>
</template>

<template id="modalResultCountPlural">
    <div>
        (<span class="Results-showHits"></span> sur <span class="Results-totalHits"></span>)
    </div>
</template>

<template id="modalResultCountSingular">
    <div>
        1 résultat
    </div>
</template>

<template id="modalResultCountNull">
    <div>
        Aucun résultat
    </div>
</template>

<div class="BasketModal modal fade" id="deliveryErrorModal" tabindex="-1" role="dialog" aria-labelledby="errorDeliveryTitle"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <div class="BasketModal-title" id="errorDeliveryTitle">
                    <span class="BasketModal-iconTitle"
                          data-svg="/src/assets/icons/icon-alert.svg"></span>
                    <span class="BasketModal-titleWrapper h2"><%=libelle_msg(Etn, request, "Désolé, la commande ne peut être poursuivie")%></span>
                </div>

                <div class="BasketModal-section">
                    <p id="deliveryErrorMessage"></p>
                </div>

                <div class="BasketModal-actions BasketModal-section">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal" onclick="$('#deliveryErrorModal').modal('toggle')"><%=libelle_msg(Etn, request, "Revenir à la livraison")%></button>
                </div>
            </div>
        </div>
    </div>
</div>



<!-- TODO : @Lilian Permet de personnaliser la fonction de conversion des prix en string vers float selon les pays -->
<script>
  window.orange_customFormatPrice = {
    products: function (item) { // Use  window.searchAlgoliaConfig.indices keys to define specific price format
      return item.prix + " Euros"; // Use real aglgolia properties index to format price
    }
  }
</script>
    <script>
      window.searchAlgoliaConfig = {
        algolia: {
          applicationId: '<%=algoliaSettings.get("app_id")%>',
          apiKey: '<%=algoliaSettings.get("search_key")%>',
        },
        imageFallback: "/src/assets/examples/smartphone-big.png",
        indices: {
          products: {
            indiceKey: 'orange_numendo_product',
            $templateWrapper: $('.resultProductsWrapper'),
            $component: $('#PageSearch-block-products'),
            $dropdown: $('.NavSearch-ProduitsServices'),
            $template: $("#resultProductsTemplate"),
            templateAttributes: { // For #resultProductsTemplate
              url: 'detail', // Set to false to remove element from template
              price: 'prix',
              imageUrl: 'pictureURL',
              title: 'title',
              titleMaxWords: 6,
              description: 'description',
              descriptionMaxWords: 13
            },
            response: {},
            blockToShow: {
              page: 6,
              dropdown: 3,
			  mobileDropdown: 2
            }
          },
          services: {
            indiceKey: "orange_numendo_service",
            $templateWrapper: $('.resultServicesWrapper'),
            $component: $('#PageSearch-block-services'),
            $dropdown: $('.NavSearch-ProduitsServices'),
            $template: $("#resultServicesTemplate"),
            templateAttributes: { // For #resultServicesTemplate
              url: 'url',
              price1: 'price1',
              price2: 'price2',
              price3: 'price3',
              monthly: 'monthly',
              commitment: 'commitment',
              title: 'name',
              titleMaxWords: 6,
              description: 'content',
              descriptionMaxWords: 15
            },
            response: {},
            blockToShow: {
              page: 6,
              dropdown: 3
            }
          },
          assistance: {
            indiceKey: "orange_numendo_assistance",
            $templateWrapper: $('.resultAssistanceWrapper'),
            $component: $('.PageSearch-searchAssistance'),
            $dropdown: $('.NavSearch-Assistance'),
            $template: $("#resultAssistanceTemplate"),
            templateAttributes: { // For #resultAssistanceTemplate
              url: 'objectID',
              title: 'title',
              titleMaxWords: 6,
              description: 'content',
              descriptionMaxWords: 13
            },
            response: {},
            blockToShow: {
              page: 6,
              dropdown: 2
            }
          },
          magazine: {
            indiceKey: "orange_numendo_magazine",
            $templateWrapper: $('.resultMagazineWrapper'),
            $component: $('.PageSearch-searchMagazine'),
            $dropdown: $('.NavSearch-Magazine'),
            $template: $("#resultMagazineTemplate"),
            templateAttributes: { // For #resultMagazineTemplate
              url: 'objectID',
              title: 'title',
              titleMaxWords: 6,
              description: 'content',
              descriptionMaxWords: 13
            },
            response: {},
            blockToShow: {
              page: 6,
              dropdown: 2
            }
          },
          videos: {
            indiceKey: "orange_numendo_video",
            $templateWrapper: $('.resultVideosWrapper'),
            $component: $('.PageSearch-searchVideos'),
            $dropdown: $('.NavSearch-Videos'),
            $template: $("#resultVideosTemplate"),
            templateAttributes: { // For #resultVideosTemplate
              url: 'videoUrl',
              title: 'title',
              titleMaxWords: 4,
              description: 'content',
              descriptionMaxWords: 10,
              imageUrl: 'img_medium'
            },
            response: {},
            blockToShow: {
              page: 6,
              dropdown: 2
            }
          },
          brands: {
            indiceKey: "orange_numendo_brand",
            $templateWrapper: $('.resultBrandsWrapper'),
            $component: $('.PageSearch-searchBrands'),
            $dropdown: $('.NavSearch-Marques'),
            $template: $("#resultBrandsTemplate"),
            templateAttributes: { // For #resultBrandsTemplate
              url: '',
              title: 'brand',
              imageUrl: 'image'
            },
            response: {},
            blockToShow: {
              page: 6,
              dropdown: 3
            }
          },
          suggest: {
            indiceKey: "orange_numendo_product_suggestion",
            $templateWrapper: $('.SearchSuggest-items'),
            $component: $('.SearchSuggest'),
            $dropdown: $('.NavSearch-Suggest'),
            $template: $("#resultSuggestTemplate"),
            templateAttributes: { // For #resultSuggestTemplate
              query: 'query'
            },
            response: {},
            blockToShow: {
              page: 6,
              dropdown: 6
            }
          }
        }
      };
      window.searchTabsConfig = {
        productsServices: {
          indexes: ['products', 'services'],
          $tab: $('#searchtab-products-services'),
          $target: $(".PageSearch-searchProducts")
        },
        assistance: {
          indexes: ['assistance'],
          $tab: $('#searchtab-assistance'),
          $target: $(".PageSearch-searchAssistance")
        },
        magazine: {
          indexes: ['magazine'],
          $tab: $('#searchtab-magazine'),
          $target: $(".PageSearch-searchMagazine")
        },
        videos: {
          indexes: ['videos'],
          $tab: $('#searchtab-videos'),
          $target: $(".PageSearch-searchVideos")
        },
        brands: {
          indexes: ['brands'],
          $tab: $('#searchtab-brands'),
          $target: $(".PageSearch-searchBrands")
        },
      };
    </script>

    <%=_footerHtml%>
    <%=_endscriptshtml%>
<script>    
    var datalayerCommonVariables = {
        funnel_name: 'funnel',
        funnel_step: 'Step 3',
        funnel_step_name: 'Delivery Information',
        product_line: 'n/a',
        order_type: 'Acquisition'
    };
    $(document).ready(function(){
        document.title = "<%=libelle_msg(Etn, request, "Mode de livraison")%> | "+document.title;
        if($('#delivery_type').val()=="") $('#deliveryTypeContainer').hide(); 
        pageTrackingWithProducts();
        bindEvents();

        applicableDeliveryCal($('#delivery_type').val(),$("input[name=radio-delivery]:checked").val(), "<%=parseNull(cart.getProperty("batowncity"))%>","<%=parseNull(cart.getProperty("bapostalCode"))%>","<%=parseNull(cart.getProperty("baline1"))%>","<%=parseNull(cart.getProperty("baline2"))%>");
        
        
        $('input[name=radio-delivery]').change(function() {
            document.querySelector(".deliveryFeeText").innerHTML="";
            if(typeof dataLayer !== 'undefined' && dataLayer != null) 
            {
                var newDlObj = cloneObject(_etn_dl_obj);

                var tempObject = {
                    event: "standard_click",
                    event_action: "choice_click",
                    event_category: "delivery",
                    event_label: $(this).val()}; // event tracking

                for(var key in tempObject){
                    newDlObj[key] = tempObject[key];
                }

                dataLayer.push(newDlObj);     
                
                if($(this).val()=="home_delivery"){ // for loading address in case of home delivery
                    newDlObj = cloneObject(_etn_dl_obj);

                    var tempObject = {
                        event: "standard_click",
                        event_action: "load",
                        event_category: "delivery_adress",
                        event_label: "adresse"}; // event tracking

                    for(var key in tempObject){
                        newDlObj[key] = tempObject[key];
                    }

                    dataLayer.push(newDlObj);  
                    
                }
            }
            applicableDelivery();
        });
    });

    function bindEvents(){
        $("#deliveryCostAlertModal").on("shown.bs.modal", function (e) {
            if(typeof dataLayer !== "undefined" && dataLayer != null) 
            {
                var newDlObj = cloneObject(_etn_dl_obj);
                var tempObject = {
                    page_name: ($("input[name=radio-delivery]:checked").val()=="pick_up_in_store"?"popin_show_shop_in_map":"popin_show_relay_shop_in_map")
                }; // page tracking 

                for(var key in tempObject){
                    newDlObj[key] = tempObject[key];
                }

                for(var key in datalayerCommonVariables){
                    newDlObj[key] = datalayerCommonVariables[key];
                }
                dataLayer.push(newDlObj);
            }
        });
        
        $(document).on("click touch",".ShopResult",function()
		{
            if(typeof dataLayer !== 'undefined' && dataLayer != null) 
            {
                var newDlObj = cloneObject(_etn_dl_obj);            

                var tempObject = {
                    event: "standard_click",
                    event_action: "button_click",
                    event_category: ($('input[name=radio-delivery]:checked').val()=="pick_up_in_store"?'delivery_pick_up_select_shop':'relay_shop_pick_up_select_shop'),
                    event_label: "select_shop"}; // event tracking

                for(var key in tempObject){
                    newDlObj[key] = tempObject[key];
                }

                dataLayer.push(newDlObj);
            }
		});
        
        $(document).on("click touch",".gm-fullscreen-control",function()
		{
            if(typeof dataLayer !== 'undefined' && dataLayer != null) 
            {
                var newDlObj = cloneObject(_etn_dl_obj);            

                var tempObject = {
                    event: "standard_click",
                    event_action: "button_click",
                    event_category: "delivery_pick_up",
                    event_label: (isFullScreenMap()?"close_full_screen":"open_full_screen")}; // event tracking

                for(var key in tempObject){
                    newDlObj[key] = tempObject[key];
                }

                dataLayer.push(newDlObj);
            }
	});
        
    }
    function pageTrackingWithProducts(){        
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                page_name: 'delivery',
                shipping_type: $("input[name='radio-delivery']:checked").next('label').text()
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
                            event_label: "", "shipping_type": $("input[name='radio-delivery']:checked").next('label').text(),"ecommerce": {"checkout": {"actionField": {"step": 3, "option": "Delivery Information"}, "products": recapDatalayerProducts}}};; // ecommerce tracking
            
            for(var key in datalayerCommonVariables){
                tempObject[key] = datalayerCommonVariables[key];
            }
            dataLayer.push(tempObject);   
        }
    }
    
    
  // Custom Tunnel Delivery Error Managment
  jQuery(function ($) {
    var geolocalisationFailed = false;
    $('.TunnelDelivery').on('error', function (e, detail) {
      switch (detail.code) {
        case 'geolocalisationFailed':
          if (!geolocalisationFailed) {
            alert(detail.message);
            geolocalisationFailed = true;
          }
          break;
      }
    });

    $('.MapComponent').on('error', function (e, detail) {
      switch (detail.code) {
        case 'mapLoadingFailed':
          console.log(detail.message);
          // Do What You Want, Map fail to load, but user can either select boutique
          break;
        case 'bridgeApiLoadingFailed':
          console.log(detail.message);
          // Do What You Want, invite user to use Address section
          break;
      }
    });
  });
  
  function applicableDelivery()
  {
    applicableDeliveryCal($("#delivery_type").val(),$("input[name=radio-delivery]:checked").val(),$("#batowncity").val(),$("#bapostalCode").val(),$("#baline1").val(),$("#baline2").val());
  }

  function applicableDeliveryCal(deliveryType,deliveryMethod, daTownCity,daPostalCode,daline1,daline2){
        showLoader();
        var tmp = document.querySelector("select#delivery_type").value;
        $.ajax({
            type: "POST",
            url: "<%=GlobalParm.getParm("EXTERNAL_LINK")%>calls/applicableDeliveryFee.jsp",
            dataType : "json",
            data: {
                "site_id": "<%=___loadedsiteid%>",				
                "delivery_type": deliveryType,
                "delivery_method":deliveryMethod,
                "_datowncity": daTownCity,
                "_dapostcode": daPostalCode, 
                "_daline1": daline1,
                "_daline2":  daline2
            }
        }).done( function(resp){
            tmp.innerHTML="";
            if($("input[name=radio-delivery]").val() == "home_delivery"){
                if(resp.deliv_types.length>0){
                    document.querySelector("select#delivery_type").innerHTML="";
                    resp.deliv_types.forEach(function(ele){
                        let option = document.createElement('option');
                        option.value=ele;
                        option.textContent=ele;
                        document.querySelector("select#delivery_type").append(option);
                        if(ele==tmp)
                            document.querySelector("select#delivery_type").options[resp.deliv_types.indexOf(tmp)].selected = true;
                    });
                }
            }
            $(".deliveryFeeText").html($(`<div class="OrderSummary-subtitle">\${resp.display_name}</div>
                    <span class="textOrangeBiggest">\${resp.delivery_fee}</span>`));
			
			$(".delv-method-fee[data-method-id="+resp.method+"]").find(".txt-starting-from").html("");
			$(".delv-method-fee[data-method-id="+resp.method+"]").find(".delv-fee-amnt").html(resp.delivery_fee);
			
			if(resp.discount_value > 0)
			{
				$(".recap-promo-code-txt").addClass("d-none");
				$(".recap-promo-code-amnt").html("-"+resp.discount_value_fmt);
				$(".recap-promo-code-amnt").removeClass("d-none");
				$(".recap-promo-code-currency").removeClass("d-none");
			}
        }).always(function(){
            hideLoader();
        });

  }

    $(".JS-TunnelAddressSectionValidate").on("click", function(e){ 
        applicableDelivery();
    });

    $("#delivery_type").on("change", function(e){
        applicableDelivery();
    });
    
    function updateCheckout(button){
        trackNextButtonClick();
        var form = $(button).closest("form");
        //alert(form.serialize());
        var formData = new FormData(form.get(0));
		showLoader();
        $.ajax({
            type :  "POST",
            url :   "<%=GlobalParm.getParm("EXTERNAL_LINK")%>calls/updatecheckout.jsp",
            data :  formData,
            dataType : "json",
            cache : false,
            contentType: false,
            processData: false
        })
        .done(function(resp) {
            if(resp.status == 1)
			{
				let hasDelivErr = false;
				let delivErrMSg = "";
				if(resp.cart_errors)
				{
					for(let j=0; j<resp.cart_errors.length; j++)
					{
						if(resp.cart_errors[j].err_type == "DELIVERY_ERROR")
						{
							hasDelivErr = true;
							delivErrMSg = resp.cart_errors[j].err_msg;
						}
					}
				}
				if(hasDelivErr == false)
				{
					form.attr("action", "payment.jsp");
					form.submit();
				}
				else{                        
					$("#deliveryErrorMessage").html(delivErrMSg);
					$("#deliveryErrorModal").modal("toggle");
				}
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
    
    function trackNextButtonClick(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            newDlObj.event = "standard_click";
            newDlObj.event_category = "delivery";
            newDlObj.event_action = "button_click";
            newDlObj.event_label = "next";

            dataLayer.push(newDlObj);   

            var tempObject = {"event": "nextButton",
                                event_action: "",
                                event_category: "",
                                event_label: "","ecommerce": {"next": {"products": recapDatalayerProducts}}};; // ecommerce tracking

            for(var key in datalayerCommonVariables){
                tempObject[key] = datalayerCommonVariables[key];
            }
            dataLayer.push(tempObject); 
        }
    }
    
    function trackListPageLoad(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                page_name: ($('input[name=radio-delivery]:checked').val()=="pick_up_in_store"?'delivery_new_shop':'delivery_new_relay_shop')
            }; // page tracking 

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            for(var key in datalayerCommonVariables){
                newDlObj[key] = datalayerCommonVariables[key];
            }
            dataLayer.push(newDlObj);
        }
    }
    
    function trackMapLoad(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);            

            var tempObject = {
                event: "standard_click",
                event_action: "load",
                event_category: "delivery_pick_up",
                event_label: "map"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);
        }
    }
    
    function trackNoShopLocated(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);            

            var tempObject = {
                event: "standard_click",
                event_action: "load",
                event_category: "delivery",
                event_label: "no_shop"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);
        }
    }
    
    function trackSelectShop(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);            

            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: ($('input[name=radio-delivery]:checked').val()=="pick_up_in_store"?'delivery_pick_up':'relay_shop_pick_up_select_shop'),
                event_label: "select_shop"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);
        }
    }
    
    function trackPinShop(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);            

            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: ($('input[name=radio-delivery]:checked').val()=="pick_up_in_store"?'delivery_pick_up':'relay_shop_pick_up_select_shop'),
                event_label: "pin_shop"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);
        }
    }
    
    function trackListHeader(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);            

            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: ($('input[name=radio-delivery]:checked').val()=="pick_up_in_store"?'delivery_pick_up_select_shop':'relay_shop_pick_up_select_shop'),
                event_label: "list"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);
        }
    }
    
    function trackMapHeader(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);            

            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: ($('input[name=radio-delivery]:checked').val()=="pick_up_in_store"?'delivery_pick_up_select_shop':'relay_shop_pick_up_select_shop'),
                event_label: "map"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);
        }
    }
    
    function trackGeolocate(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);            

            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: ($('input[name=radio-delivery]:checked').val()=="pick_up_in_store"?'delivery_pick_up':'relay_shop_pick_up_select_shop'),
                event_label: "geolocate"}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);
        }
    }
    
    function trackMoreDetailsButton(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);            

            var tempObject = {
                event: "standard_click",
                event_action: "button_click",
                event_category: "delivery_pick_up",
                event_label: ($(".DeliveryShopInformations").hasClass('open')?"more_details":"less_details")}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

            dataLayer.push(newDlObj);
        }
    }
    
    function isFullScreenMap() {
        if ( $('.MapComponentMain').children().eq(0).height() == window.innerHeight && $('.MapComponentMain').children().eq(0).width()  == window.innerWidth || $('.MapComponentBig').children().eq(0).height() == window.innerHeight && $('.MapComponentBig').children().eq(0).width()  == window.innerWidth ) {
            return true;
        }
        else {
            return false;
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
<script src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/v2/bundle-7-5.js?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
</body>
</html>
