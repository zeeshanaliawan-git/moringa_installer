<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="java.security.MessageDigest,java.security.NoSuchAlgorithmException" %>


<%@ include file="lib_msg.jsp"%>
<%@ include file="commonprice.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>
<%!
    
%>
<%    
   
%>
  <!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    </head>
      <body>

<%
        String id = parseNull(request.getParameter("id"));
        String orderId = parseNull(request.getParameter("orderId"));
        String email = parseNull(request.getParameter("email"));
        String query = "";

        if(id.equals("")){
            query = "select * from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders where orderRef="+escape.cote(orderId)+" and email="+escape.cote(email);
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
            Set rsPaymentMethod = Etn.execute("select displayName from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".payment_methods where site_id = " + escape.cote(rsOrder.value("site_id")) + " and method="+escape.cote(payment_method));
            if(rsPaymentMethod.next()) paymentDisplayName = rsPaymentMethod.value(0);
            Set rsDeliveryMethod = Etn.execute("select displayName from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".delivery_methods where site_id = " + escape.cote(rsOrder.value("site_id")) + " and method="+escape.cote(delivery_method));
            if(rsDeliveryMethod.next()) deliveryDisplayName = rsDeliveryMethod.value(0);
            

            String transaction_code = rsOrder.value("transaction_code");

%>

<table align="center" style="width:700px; border:none">
	<tbody>
		<tr>
			<td style="text-align:left">
				<p>
					<img src="/src/assets/icons/master-logo.gif" style="height:50px; width:50px">
				</p>
			</td>
			<td style="text-align:right; font-size:11pt; font-family:Arial">
				<p>
					<strong>FACTURE</strong>
				<br>
					<%=rsOrder.value("creationDate").substring(0,10)%>
				<br>
					#FAOBF2020/<%=rsOrder.value("orderRef")%>
				</p>
			</td>
		</tr>
	</tbody>
</table>
<p style="text-align:right">&nbsp;</p>

<table align="center" style="width:700px; border:none">
	<tbody>
		<tr>
			<td style="width:350px; text-align:left; font-size:11pt; font-family:Arial">
				<strong>Adresse de livraison</strong>
			</td>
			<td style="width:350px; text-align:left; font-size:11pt; font-family:Arial">
				<strong>Adresse de de facturation</strong>
			</td>
		</tr>
		<tr>
			<td style="text-align:left; font-size:10pt; font-family:Arial; width:350px">
				<p>
					<%=!delivery_method.startsWith("pick_up_in_")?rsOrder.value("salutation")+" "+rsOrder.value("surnames")+" "+rsOrder.value("name")+"<br> ":""%> 
					<%=rsOrder.value("daline1")%>
				<br>
					<%=rsOrder.value("daline2")%>
				<br>
					<%=rsOrder.value("dapostalCode")%> <%=rsOrder.value("datowncity")%>
				<br>
					<%=rsOrder.value("country").equals("")?"":rsOrder.value("country")+"<br>"%>
				</p>
			</td>
			<td style="text-align:left; font-size:10pt; font-family:Arial; width:350px">
				<p>
					<%=rsOrder.value("salutation")%> <%=rsOrder.value("surnames")%> <%=rsOrder.value("name")%>
				<br>
					<%=rsOrder.value("baline1")%>
				<br>
					<%=rsOrder.value("baline2")%>
				<br>
					<%=rsOrder.value("bapostalCode")%> <%=rsOrder.value("batowncity")%>
				<br>					
					<%=rsOrder.value("country").equals("")?"":rsOrder.value("country")+"<br>"%>
					<%=rsOrder.value("contactPhoneNumber1")%>
				</p>
			</td>
		</tr>
	</tbody>
</table>

<p>&nbsp;</p>

<table align="center" style="width:700px; border:none">
	<tbody>
		<tr>
			<td style="background-color:#f2f2f2; width:25%; text-align:left; font-size:11pt; font-family:Arial">
				<strong>Num&eacute;ro de facture</strong>
			</td>
			<td style="background-color:#f2f2f2; width:25%; text-align:left; font-size:11pt; font-family:Arial">
				<strong>Date de facturation</strong>
			</td>
			<td style="background-color:#f2f2f2; width:25%; text-align:left; font-size:11pt; font-family:Arial">
				<strong>R&eacute;f. de commande</strong>
			</td>
			<td style="background-color:#f2f2f2; width:25%; text-align:left; font-size:11pt; font-family:Arial">
				<strong>Date de commande</strong>
			</td>
		</tr>
		<tr>
			<td style="width:25%; text-align:left; font-size:10pt; font-family:Arial">
				#FA0BF2020/<%=rsOrder.value("orderRef")%>
			</td>
			<td style="width:25%; text-align:left; font-size:10pt; font-family:Arial">
				<%=rsOrder.value("creationDate").substring(0,10)%>
			</td>
			<td style="width:25%; text-align:left; font-size:10pt; font-family:Arial">
				<%=rsOrder.value("orderRef")%>
			</td>
			<td style="width:25%; text-align:left; font-size:10pt; font-family:Arial">
				<%=rsOrder.value("creationDate").substring(0,10)%>
			</td>
		</tr>
	</tbody>
</table>

<p>&nbsp;</p>

<table align="center" style="width:700px; border:none">
	<tbody>
		<tr>
			<td style="background-color:#f2f2f2; width:65.8pt; text-align:left; font-size:11pt; font-family:Arial"><strong>Produit</strong></td>
			<td style="background-color:#f2f2f2; width:65.8pt; text-align:left; font-size:11pt; font-family:Arial"><strong>Prix de base (TTC)</strong></td>
			<td style="background-color:#f2f2f2; width:65.8pt; text-align:left; font-size:11pt; font-family:Arial"><strong>Prix unitaire net (TTC)</strong></td>
			<td style="background-color:#f2f2f2; width:65.8pt; text-align:left; font-size:11pt; font-family:Arial"><strong>Quantit&eacute;</strong></td>
			<td style="background-color:#f2f2f2; width:65.8pt; text-align:left; font-size:11pt; font-family:Arial"><strong>Montant (TTC)</strong></td>
		</tr>
		
				                <%
                double itemsTotal = 0;
                double itemsOldTotal = 0;
                DecimalFormat df = new DecimalFormat("#.##");
                Set rsOrderItems = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items where parent_id="+escape.cote(rsOrder.value("parent_uuid")));
                
                while(rsOrderItems.next()){       
                    JSONArray additionalFee = new JSONArray(rsOrderItems.value("additionalfees"));
                    double totalAdditionalFee = 0;
                    for(int i=0; i<additionalFee.length(); i++){
                        totalAdditionalFee += parseNullDouble(additionalFee.getJSONObject(i).getString("price"));
                    }                                      
                    double totalAmount = parseNullDouble(rsOrderItems.value("price_value"))+totalAdditionalFee;
                    itemsTotal += totalAmount; 
                    itemsOldTotal += parseNullDouble(rsOrderItems.value("price_old_value"))+totalAdditionalFee;
                %>  
		
		<tr>
			<td style="border-bottom:1.0pt solid windowtext; border-left:none; border-right:none; border-top:none; width:65.8pt; text-align:left; font-size:10pt; font-family:Arial">
				<strong><%=rsOrderItems.value("product_full_name")%></strong>
			</td>
			</td>
			<td style="border-bottom:1.0pt solid windowtext; border-left:none; border-right:none; border-top:none; width:65.8pt; text-align:right; font-size:10pt; font-family:Arial">
				<strong><%=df.format((parseNullDouble(rsOrderItems.value("price_old_value"))+totalAdditionalFee)/parseNullDouble(rsOrderItems.value("quantity")))%> <%=rsOrder.value("currency")%></strong>
			</td>
			<td style="border-bottom:1.0pt solid windowtext; border-left:none; border-right:none; border-top:none; width:65.8pt; text-align:right; font-size:10pt; font-family:Arial">
				<strong><%=df.format((parseNullDouble(rsOrderItems.value("price_value"))+totalAdditionalFee)/parseNullDouble(rsOrderItems.value("quantity")))%> <%=rsOrder.value("currency")%></strong>
			</td>
			<td style="border-bottom:1.0pt solid windowtext; border-left:none; border-right:none; border-top:none; width:65.8pt; text-align:right; font-size:10pt; font-family:Arial">
				<strong><%=rsOrderItems.value("quantity")%></strong>
			</td>
			<td style="border-bottom:1.0pt solid windowtext; border-left:none; border-right:none; border-top:none; width:65.8pt; text-align:right; font-size:10pt; font-family:Arial">
				<strong><%=totalAmount%> <%=rsOrder.value("currency")%></strong>
			</td>
		</tr>
		
				<%
                }
            %>
			
	</tbody>
</table>

<p>&nbsp;</p>

<table align="center" style="width:700px; border:none">
	<tbody>
		<tr>
			<td style="background-color:#f2f2f2; width:97.0pt; text-align:left; font-size:11pt; font-family:Arial"><strong>Moyen de paiement</strong></td>
			<td style="width:71.45pt; text-align:left; font-size:10pt; font-family:Arial"><%=paymentDisplayName%></td>
			<td style="width:77.75pt; text-align:left; font-size:10pt; font-family:Arial"><%=rsOrder.value("total_price")%> <%=rsOrder.value("currency")%></td>
			<td style="width:30.8pt; text-align:left; font-size:10pt; font-family:Arial">&nbsp;</td>
			<td style="background-color:#f2f2f2; width:95pt; text-align:left; font-size:11pt; font-family:Arial">Total TTC avant remise</td>
			<td style="width:79.65pt; text-align:right; font-size:10pt; font-family:Arial"><%=df.format(itemsTotal)%> <%=rsOrder.value("currency")%></td>
		</tr>
                <%                
                    JSONArray calculatedCartDiscounts = orderSnapshot.getJSONArray("calculatedCartDiscounts");
                    for(int i=0; i<calculatedCartDiscounts.length(); i++){
                        //totalToPay -= parseNullDouble(calculatedCartDiscounts.getJSONObject(i).getString("discountValue"));
                %>
		<tr>
			<td colspan="3" style="width:168.45pt; text-align:left; font-size:10pt; font-family:Arial">&nbsp;</td>
			<td style="width:30.8pt; text-align:left; font-size:10pt; font-family:Arial">&nbsp;</td>
			<td style="background-color:#f2f2f2; width:95pt; text-align:left; font-size:11pt; font-family:Arial"><%=(calculatedCartDiscounts.getJSONObject(i).getString("couponCode").length()>0?"Remise code promo \""+calculatedCartDiscounts.getJSONObject(i).getString("couponCode")+"\"":"Remise panier")%></td>
			<td style="width:79.65pt; text-align:right; font-size:10pt; font-family:Arial">-<%=calculatedCartDiscounts.getJSONObject(i).getString("discountValue")%> <%=rsOrder.value("currency")%></td>
		</tr>
                <%
                    }
                %>
		<tr>
			<td colspan="3" style="width:246.2pt;text-align:left; font-size:10pt; font-family:Arial">&nbsp;</td>
			<td style="width:30.8pt;text-align:left; font-size:10pt; font-family:Arial">&nbsp;</td>
			<td style="background-color:#f2f2f2;width:95pt;text-align:left; font-size:11pt; font-family:Arial">Frais de livraison</td>
			<td style="width:79.65pt; text-align:right; font-size:10pt; font-family:Arial"><%=parseNullDouble(rsOrder.value("delivery_fees"))==0?"Livraison gratuite":rsOrder.value("delivery_fees")+" "+rsOrder.value("currency")%></td>
		</tr>
                <%if(parseNullDouble(orderSnapshot.get("grandTotalRecurring"))>0){%>
		<tr>
			<td colspan="3" style="width:246.2pt;text-align:left; font-size:10pt; font-family:Arial">&nbsp;</td>
			<td style="width:30.8pt;text-align:left; font-size:10pt; font-family:Arial">&nbsp;</td>
			<td style="background-color:#f2f2f2;width:95pt;text-align:left; font-size:11pt; font-family:Arial">A payer chaque mois</td>
			<td style="width:79.65pt; text-align:right; font-size:10pt; font-family:Arial"><%=orderSnapshot.get("grandTotalRecurring")%> <%=rsOrder.value("currency")%>/<%=libelle_msg(Etn, request, "mois")%></td>
		</tr>
                <%}%>
		<tr>
			<td colspan="3" style="width:246.2pt;text-align:left; font-size:10pt; font-family:Arial">Si vous souhaitez faire identifier votre num&eacute;ro, veuillez nous faire parvenir une copie de votre CNIB ou passeport &agrave; l&rsquo;adresse info.obf@orange.com</td>
			<td style="width:30.8pt;">&nbsp;</td>
			<td style="background-color:#f2f2f2;width:95pt;text-align:left; font-size:12pt; font-family:Arial"><strong>Total pay&eacute;</strong></td>
			<td style="width:79.65pt; text-align:right; font-size:12pt; font-family:Arial"><strong><%=rsOrder.value("total_price")%> <%=rsOrder.value("currency")%></strong></td>
		</tr>
	</tbody>
</table>

<p>&nbsp;</p>
<p>&nbsp;</p>


<table align="center" style="margin-bottom: 30px; width:700px; border:none">
	<tbody>
		<tr>
			<td style="text-align:center; font-size:9pt; font-family:Arial">
				<p>
					Boutique Orange - 771, Avenue du Pr&eacute;sident Aboubacar Sangoul&eacute; LAMIZANA - Ouagadougou - Kadiogo&nbsp; Burkina Faso
<br>
					Pour toute assistance, merci de nous contacter :
<br>
					T&eacute;l. : +2267550505
<br>
					Orange Burkina Faso
				</p>
			</td>
		</tr>
	</tbody>
</table>
<%
}
%>

  </body>
</html>
