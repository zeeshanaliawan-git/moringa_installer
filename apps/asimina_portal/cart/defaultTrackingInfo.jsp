<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64, org.json.*"%>
<%@ page import="java.security.MessageDigest,java.security.NoSuchAlgorithmException" %>


<%@ include file="lib_msg.jsp"%>
<%@ include file="commonprice.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="priceformatter.jsp"%>
<%!
    
%>
<%    
	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";
	
%>
<%@ include file="../headerfooter.jsp"%>
<%
	String langue_id = "1";
	//if incoming lang was empty or not found in the language table, we will get the first language by default
	Set __rs1 = Etn.execute("select '0' as _a, langue_code, langue_id from language where langue_code = " + escape.cote(_lang) + " union select '1' as _a, langue_code, langue_id from language where langue_id = 1 order by _a ");
	if(__rs1.next()){
		_lang = parseNull(__rs1.value("langue_code"));
		langue_id = parseNull(__rs1.value("langue_id"));
	}
	String prefix = getProductColumnsPrefix(Etn, request, _lang);

  %>
  <!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
  <head>
<%=_headhtml%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css">

    <style>
 .js-focus-visible body{
          height:auto;
      }
     </style>
    </head>
      <body>
<%=_headerHtml%>

<%
        String id = parseNull(request.getParameter("id"));
        String orderId = parseNull(request.getParameter("orderId"));
        String email = parseNull(request.getParameter("email"));
        String query = "";

        if(id.equals("")){
            query = "select * from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders where orderRef="+escape.cote(orderId)+" and (email="+escape.cote(email)+" or contactPhoneNumber1="+escape.cote(email)+")";
        }
        else{
            query = "select * from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders where parent_uuid="+escape.cote(id);
        }


        String payment_method = "";
        String delivery_method = "";
        String paymentDisplayName = "";
        String deliveryDisplayName = "";
        Set rsOrder = Etn.execute(query);
        if(rsOrder.next()){
            JSONObject orderSnapshot = new JSONObject(rsOrder.value("order_snapshot"));
            payment_method = rsOrder.value("spaymentmean");
            delivery_method = rsOrder.value("shipping_method_id");
            Set rsPaymentMethod = Etn.execute("select displayName from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".payment_methods where site_id = " + escape.cote(___loadedsiteid) + " and method="+escape.cote(payment_method));
            if(rsPaymentMethod.next()) paymentDisplayName = rsPaymentMethod.value(0);
            Set rsDeliveryMethod = Etn.execute("select displayName from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".delivery_methods where site_id = " + escape.cote(___loadedsiteid) + " and method="+escape.cote(delivery_method));
            if(rsDeliveryMethod.next()) deliveryDisplayName = rsDeliveryMethod.value(0);
            

            String transaction_code = rsOrder.value("transaction_code");

%>
      <div class="PageTitle isShortHeight">
          <div class="PageTitle-container container-lg">            
              <h1 class="display-2"><%=libelle_msg(Etn, request, "Suivi de commande")%></h1>
          </div>
      </div>
    <div class="container-lg Reference">
    <h2 class="Reference-title"><%=libelle_msg(Etn, request, "Référence")%> : </h2>
    <p class="Reference-number"><%=rsOrder.value("orderRef")%></p>
</div>

<div class="HrLine"></div>

<div class="container-lg">
    <div class="TunnelOrderTracking">
        <div class="TunnelOrderTracking-statusHistory">
            <h3 class=TunnelOrderTracking-title><%=libelle_msg(Etn, request, "Historique du statut")%></h3>
            <%
            String client_key = rsOrder.value("id");
            int count = 0;
            //if(parseNull(com.etn.beans.app.GlobalParm.getParm("POST_WORK_SPLIT_ITEMS")).equals("")||parseNull(com.etn.beans.app.GlobalParm.getParm("POST_WORK_SPLIT_ITEMS")).equals("1")) client_key = rsOrderItems.value("id");
            Set rsHistorique = Etn.execute("select p.*, IF(COALESCE(displayName"+langue_id+",'')<>'',displayName"+langue_id+",displayName) as phaseDisplayName from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".post_work p inner join "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".phases ph on p.proces = ph.process and p.phase = ph.phase where ph.orderTrackVisible='1' and p.client_key="+escape.cote(client_key)+" and p.is_generic_form = 0 and p.status not in(0,9) order by p.insertion_date asc");
            if(rsHistorique.rs.Rows>0){
            %>
            <a  data-toggle="collapse" href="#toHide" class="TunnelOrderTracking-statusHistoryContainers isPast">
                <div class="TunnelOrderTracking-iconBox">
                    <img class="isNotCollapsed"
                          src="/src/assets/icons/icon-hide.svg" alt="" />
                    <img class="isCollapsed"
                          src="/src/assets/icons/icon-history.svg" alt=""/>
                    <div class="TunnelOrderTracking-fil"></div>
                </div>
                <div class="TunnelOrderTracking-link isCollapsed"><%=libelle_msg(Etn, request, "Afficher le détail des étapes précédentes")%></div>
                <div class="TunnelOrderTracking-link isNotCollapsed"><%=libelle_msg(Etn, request, "Masquer")%></div>
                <span class="TunnelOrderTracking-stepTransition"></span>
            </a>
            <%
            }
            %>
            <div class="collapse" id="toHide">            
            <%
            while(rsHistorique.next()){
                count++;
            %>
                <div class="TunnelOrderTracking-statusHistoryContainers isPast">
                    <div class="TunnelOrderTracking-iconBox">
                        <img class="TunnelOrderTracking-icon d-inline-block align-middle isValid"
                             src="/src/assets/icons/icon-valid.svg" alt="" />
                        <div class="TunnelOrderTracking-fil"></div>
                    </div>
                    <div class="TunnelOrderTracking-trackingItemContent">
                        <p href="#" class="TunnelOrderTracking-state"><%=rsHistorique.value("phaseDisplayName")%></p>
                        <p class="TunnelOrderTracking-date"><%=rsHistorique.value("insertion_date").substring(0,10)%></p>
                        <%=(rsHistorique.rs.Rows==count?"<div class=\"TunnelOrderTracking-stepEndLine\"></div>":"")%>
                    </div>
                </div>
            <%
            }
            %>            
            </div>
            <%
                rsHistorique = Etn.execute("select p.*, IF(COALESCE(displayName"+langue_id+",'')<>'',displayName"+langue_id+",displayName) as phaseDisplayName from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".post_work p inner join "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".phases ph on p.proces = ph.process and p.phase = ph.phase where ph.orderTrackVisible='1' and p.client_key="+escape.cote(client_key)+" and p.is_generic_form = 0 and p.status in(0,9) order by p.insertion_date asc");
                while(rsHistorique.next()){
            %>
            <div class="TunnelOrderTracking-statusHistoryContainers isCurrent">
                <div class="TunnelOrderTracking-iconBox">
                    <img class="TunnelOrderTracking-icon d-inline-block align-middle isValid"
                          src="/src/assets/icons/icon-valid.svg" alt="" />
                    <%=(parseNullDouble(rsOrder.value("total_price"))>0&&(payment_method.equals("cash_on_delivery")||payment_method.equals("cash_on_pickup"))?"<div class=\"TunnelOrderTracking-fil\"></div>":"")%>
                </div>
                <div class="TunnelOrderTracking-trackingItemContent">
                    <p href="#" class="TunnelOrderTracking-state"><%=rsHistorique.value("phaseDisplayName")%></p>
                    <p class="TunnelOrderTracking-date"><%=rsHistorique.value("insertion_date").substring(0,10)%></p>
                </div>
            </div>
            <%
                }
            %>
            <%if(parseNullDouble(rsOrder.value("total_price"))>0&&(payment_method.equals("cash_on_delivery")||payment_method.equals("cash_on_pickup"))){%>
            <div class="TunnelOrderTracking-statusHistoryContainers isPost">
                <div class="TunnelOrderTracking-iconBox">
                    <img class="TunnelOrderTracking-icon d-inline-block align-middle"
                          src="/src/assets/icons/icon-money.svg" alt=""/>
                </div>
                <div class="TunnelOrderTracking-trackingItemContent">
                    <p href="#" class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Reste à payer")%></p>
                    <p class="TunnelOrderTracking-price"><%=rsOrder.value("total_price")%> <%=rsOrder.value("currency")%></p>
                </div>
            </div>
                <%}%>
        </div>

        <div class="TunnelOrderTracking-summary">
            <h3 class="TunnelOrderTracking-title"><%=libelle_msg(Etn, request, "Récapitulatif")%></h3>
            <%
                Set rsOrderItems = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items where parent_id="+escape.cote(rsOrder.value("parent_uuid")));
                count = 0;
                while(rsOrderItems.next()){
                    count++;
                    System.out.println(rsOrderItems.value("product_snapshot"));
                    JSONObject productSnapshot = new JSONObject(rsOrderItems.value("product_snapshot"));
                    JSONObject promotion = new JSONObject(rsOrderItems.value("promotion"));
                    JSONArray attributes = new JSONArray(parseNull(productSnapshot.get("attributes")));
                %>              
            <div class="TunnelOrderTracking-summaryItem <%=(rsOrderItems.rs.Rows==count?"isLastSummaryItem":"")%>">
                <a href="#" class="TunnelOrderTracking-link"><%=rsOrderItems.value("product_full_name")%></a>
                <%if(payment_method.equals("cash_on_delivery")||payment_method.equals("cash_on_pickup")){%>
                <div class="TunnelOrderTracking-summaryItemLine d-none">
                    <p class="TunnelOrderTracking-bigText"><%=rsOrderItems.value("product_type").equals("offer_postpaid")?libelle_msg(Etn, request, "A payer chaque mois"):libelle_msg(Etn, request, "Reste à payer")%></p>
                    <p class="TunnelOrderTracking-price"><%=rsOrderItems.value("price_value")%> <%=rsOrder.value("currency")%><%=rsOrderItems.value("product_type").equals("offer_postpaid")?"/"+libelle_msg(Etn, request, "mois"):""%></p>
                </div>
                <%}%>
                <%
                if(!parseNull(com.etn.beans.app.GlobalParm.getParm("IS_ORANGE_APP")).equals("1")){
                    for(int i=0; i<attributes.length(); i++){
						String _attribValue = attributes.getJSONObject(i).optString("label", "");
						if(_attribValue.length() == 0) _attribValue = attributes.getJSONObject(i).getString("value");
                %>
                <p class="TunnelOrderTracking-text"><%=libelle_msg(Etn, request, attributes.getJSONObject(i).getString("name"))%> : <%=libelle_msg(Etn, request, _attribValue)%></p>
                <%}}%>
                <%=(!parseNull(com.etn.beans.app.GlobalParm.getParm("IS_ORANGE_APP")).equals("1") || parseNullInt(rsOrderItems.value("quantity"))>1?"<p class=\"TunnelOrderTracking-text\">"+libelle_msg(Etn, request, "Quantité")+" : "+rsOrderItems.value("quantity")+"</p>":"")%>
                <!--<p class="TunnelOrderTracking-text">Offre valable pendant 1 mois</p>-->
                
                <%if(rsOrderItems.value("product_type").equals("offer_postpaid")){
                    
                %>
                    <p class="TunnelOrderTracking-text"><%=parseNullInt(productSnapshot.get("duration"))==0?libelle_msg(Etn, request, "Sans engagement"):libelle_msg(Etn, request, "Engagement")+" "+productSnapshot.get("duration")+" "+libelle_msg(Etn, request, "mois")%></p>
                    <%=(promotion.has("duration")&&parseNullInt(promotion.get("duration"))>0?"<p class=\"TunnelOrderTracking-text\">"+libelle_msg(Etn, request, "Promotion pendant")+" "+promotion.get("duration")+" "+libelle_msg(Etn, request, "mois")+"</p>":"")%>
                    <%}%>
            </div>
            <%
                }
            %>
            <div class="TunnelOrderTracking-summaryPay">
                <%if(payment_method.equals("cash_on_delivery")||payment_method.equals("cash_on_pickup")){%>
                <%if(parseNullDouble(rsOrder.value("total_price"))>0){%>
                <div class="TunnelOrderTracking-summaryItemLine">
                    <p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Reste à payer")%></p>
                    <p class="TunnelOrderTracking-price"><%=rsOrder.value("total_price")%></p>
                </div>
                <p class="TunnelOrderTracking-currency"><%=rsOrder.value("currency")%></p>
                <%}%>
                <%if(parseNullDouble(orderSnapshot.get("grandTotalRecurring"))>0){%>
                <div class="TunnelOrderTracking-summaryItemLine">
                    <p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "A payer chaque mois")%></p>
                    <p class="TunnelOrderTracking-price"><%=orderSnapshot.get("grandTotalRecurring")%></p>
                </div>
                <p class="TunnelOrderTracking-currency"><%=rsOrder.value("currency")%>/<%=libelle_msg(Etn, request, "mois")%></p>
                <%}%>
                <%}%>                
                <%if(!payment_method.equals("cash_on_delivery")&&!payment_method.equals("cash_on_pickup")){%>
                <button type="button" onclick="window.location = 'downloadTrackingBill.jsp?id=<%=rsOrder.value("parent_uuid")%>&doc=<%=rsOrder.value("orderRef")%>'" class="btn btn-primary"><%=libelle_msg(Etn, request, "Consulter la facture")%></button>
                <%}%>         
            </div>
        </div>
        <div class="TunnelOrderTracking-additionalInformation">
            <h3 class="TunnelOrderTracking-title"><%=libelle_msg(Etn, request, "Informations annexes")%></h3>
            <div class="row">
				<% if(parseNull(rsOrder.value("courier_name")).length() > 0 || parseNull(rsOrder.value("tracking_number")).length() > 0) {%>
                <div class="col-12 col-lg-4">
					<% if(parseNull(rsOrder.value("courier_name")).length() > 0) { %>
						<p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Courrier")%> :</p>
						<p class="TunnelOrderTracking-additionalInformationText"><%=parseNull(rsOrder.value("courier_name"))%></p>
					<% } %>
					<% if(parseNull(rsOrder.value("tracking_number")).length() > 0) { %>
						<p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Numéro de suivi du courrier")%> :</p>
						<p class="TunnelOrderTracking-additionalInformationText"><%=parseNull(rsOrder.value("tracking_number"))%></p>
					<% } %>
                </div>
				<%}%>
                <div class="col-12 col-lg-4">
                    <p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Méthode de livraison")%> :</p>
                    <p class="TunnelOrderTracking-additionalInformationText"><%=libelle_msg(Etn, request, deliveryDisplayName)%></p>
                    <p class="TunnelOrderTracking-bigText <%=rsOrder.value("delivery_type").length()>0?"":"d-none"%>"><%=libelle_msg(Etn, request, "Type de livraison")%> :</p>
					<p class="TunnelOrderTracking-additionalInformationText <%=rsOrder.value("delivery_type").length()>0?"":"d-none"%>"><%=rsOrder.value("delivery_type")%></p>
                    <div class="TunnelOrderTracking-address">
                        <p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Adresse de livraison")%> :</p>
                        <p>
                            <%=delivery_method.equals("home_delivery")?rsOrder.value("salutation")+" "+rsOrder.value("surnames")+" "+rsOrder.value("name")+"<br> ":""%> 
							<% if(parseNull(rsOrder.value("daline1")).length() > 0){
								out.write(rsOrder.value("daline1") + "<br>");
							}%>
							<% if(parseNull(rsOrder.value("daline2")).length() > 0){
								out.write(rsOrder.value("daline2") + "<br>");
							}%>
							<% if(parseNull(rsOrder.value("dapostalCode")).length() > 0){
								out.write(rsOrder.value("dapostalCode") + "&nbsp;");
							}%>
							<% if(parseNull(rsOrder.value("datowncity")).length() > 0){
								out.write(rsOrder.value("datowncity"));
							}%>
                            <%if(delivery_method.equals("home_delivery")){%>
                            <br> <%=libelle_msg(Etn, request, "Téléphone")%> : <%=rsOrder.value("contactPhoneNumber1")%> <br> <%=libelle_msg(Etn, request, "Email")%> : <%=rsOrder.value("email")%>
                            <%}%>
                        </p>
                    </div>
                </div>
                <div class="col-12 col-lg-4">
                    <p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Date et heure de la commande")%> :</p>
                    <p class="TunnelOrderTracking-additionalInformationText"><%=rsOrder.value("creationDate").substring(0,10)%> - <%=rsOrder.value("creationDate").substring(11,16)%></p>
                    <p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Méthode de paiement")%> :</p>
                    <p class="TunnelOrderTracking-additionalInformationText"><%=libelle_msg(Etn, request, paymentDisplayName)%></p>
                    <%if(transaction_code.length()>0){%>
                    <p class="TunnelOrderTracking-bigText"><%=libelle_msg(Etn, request, "Référence de transaction")%> :</p>
                    <p class="TunnelOrderTracking-additionalInformationText"><%=transaction_code%></p>
                    <%}%>
                </div>
            </div>
        </div>
    </div>
</div>
<%
}
else{//no order found
%>
<div class="PageTitle isShortHeight">
	<div class="PageTitle-container container-lg">            
		<h1 class="display-2"><%=libelle_msg(Etn, request, "Suivi de commande")%></h1>
	</div>
</div>

<div class="container-lg mt-5 mb-5">
    <h2 style="color:red"><%=libelle_msg(Etn, request, "Aucune commande trouvée")%></h2>
</div>

<%	
}
%>
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

  </body>
    <script>

    jQuery(document).ready(function(){
        
    });
    </script>
</html>
