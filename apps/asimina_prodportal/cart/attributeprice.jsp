<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*"%>

<%@ include file="lib_msg.jsp"%>
<%@ include file="commonprice.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>
<%!
int parseNullInt(String s)
{
    if (s == null) return 0;
    if (s.equals("null")) return 0;
    if (s.equals("")) return 0;
    return Integer.parseInt(s);
}
%>
<%
        String product_uuid = parseNull(request.getParameter("product_uuid"));
        String lang = parseNull(request.getParameter("lang"));
        String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
        boolean logged = (client_id.equals("")?false:true);
        String installment_plan = (logged?parseNull(request.getParameter("installment_plan_logged")):parseNull(request.getParameter("installment_plan")));

        String strquantity = parseNull(request.getParameter("quantity"));
        int quantity = 1;
        if (strquantity.length() > 0) quantity = Integer.parseInt(strquantity);

        String[] attributes = request.getParameterValues("attributes");
//        System.out.println(lang+"lang");
        Set rs = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where product_uuid="+ escape.cote(product_uuid));
        rs.next();

        
        set_lang(lang, request, Etn);

        String prefix = getProductColumnsPrefix(Etn, request, lang);
	String priceformatter  = "";
	String roundto = "";
	String showdecimals = "";
        String defaultcurrency = "";

        String price = rs.value("price");
        String promo_price = rs.value("discount_prices");

        

	Set rscat = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".catalogs where id = " + rs.value("catalog_id"));
	rscat.next();

        Set rsshop = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id = " + escape.cote(rscat.value("site_id")) );
	rsshop.next();
	priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
        roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
        showdecimals = parseNull(rsshop.value(prefix + "show_decimals"));
	defaultcurrency = parseNull(rsshop.value(prefix + "currency"));

	String _currencyfreq = (installment_plan.equals("")?libelle_msg(Etn, request, parseNull(rs.value("currency_frequency"))):"");

        String currency_frequency = getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq);


       boolean pricetaxincluded = ("1".equals(parseNull(rscat.value("price_tax_included")))?true:false);
	boolean showamountwithtax = false;
	boolean anyamountshown = false;
       TaxPercentage taxpercentage = new TaxPercentage();
       taxpercentage.tax = parseNullDouble(rscat.value("tax_percentage"));
	if("1".equals(parseNull(rscat.value("show_amount_tax_included")))) showamountwithtax = true;
       taxpercentage.input_with_tax = pricetaxincluded;
       taxpercentage.output_with_tax = showamountwithtax;
        
        String[] price_diff =null;

        String combo_key = "";
        String attrib_keys = "";
        boolean attributes_selected = false; // true when all attributes are selected
        if(attributes!=null){
            attributes_selected = true; 
            for(String s : attributes) {
                if(!combo_key.equals("")) combo_key+="_";
                combo_key+=s;

                if(!attrib_keys.equals("")) attrib_keys+=",";
                String attrib_id = s.substring(s.indexOf("_")+1);
                if(!attrib_id.equals("0")) attrib_keys+=escape.cote(attrib_id);
                else attributes_selected = false;
            }
        }

        Gson gson = new Gson();
        Type type = new TypeToken<List<Object>>(){}.getType();
        //System.out.println(rs.value("combo_prices"));
        if(!rs.value("combo_prices").equals("")){
            List<Object> list = gson.fromJson(rs.value("combo_prices"), type);
            //String price = "";
            for(int i=0;i<list.size();i++){
                Map<String,String> map = (Map)list.get(i);
                if (combo_key.equals(parseNull(map.get("attribValues")))) {
                    //out.write(parseNull(map.get("priceDiff")));
                    price_diff = new String[1];
                    price_diff[0] = parseNull(map.get("priceDiff"));
                }
            }
        }

//        if(price_diff==null&&attributes_selected/*!attrib_keys.equals("")*/){
//            price_diff = new String[attributes.length];
//            //System.out.println("select price_diff from product_attribute_values where id IN ("+attrib_keys+")");
//            Set attrib_rs = Etn.execute("select price_diff from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_attribute_values where id IN ("+attrib_keys+")");
//            int count = 0;
//            while(attrib_rs.next()){
//                price_diff[count] = attrib_rs.value("price_diff");
//                count++;
//            }
//        }

        int stock=0;

        if(rs.value("product_type").equals("pack_prepaid")){
            List<Object> list = gson.fromJson(rs.value("pack_details"), type);
            boolean isFirst = true; // to find minimum stock among pack items
            for(int i=0;i<list.size();i++){                
                Map<String,String> map = (Map)list.get(i);
                Set item_rs = Etn.execute("select product_type from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where id ="+escape.cote(map.get("productId")));
                if(item_rs.next()){
                    if(item_rs.value(0).equals("offer_prepaid")||item_rs.value(0).equals("offer_postpaid")) continue;
                }
                Set stock_rs = Etn.execute("select stock from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_stocks where product_id ="+escape.cote(map.get("productId"))+" and attribute_values = "+escape.cote(map.get("attribValues")));
                if(stock_rs.next()){
                    int tempStock = parseNullInt(stock_rs.value(0));
                    if(tempStock == 0){
                        stock = 0;
                        break;
                    }
                    
                    if(isFirst){
                        stock = tempStock;
                        isFirst = false;
                    }
                    else if(tempStock < stock){
                        stock = tempStock;
                    }    
                }
                else{
                    stock = 0;
                    break;
                }
            }            
        }
        else{
            Set stock_rs = Etn.execute("select sum(stock) from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_stocks where stock > 0 and product_id ="+escape.cote(rs.value("id"))+" and attribute_values LIKE "+escape.cote(combo_key.replaceAll("_0","_%")) + " group by product_id");        
            if(stock_rs.next()) stock = parseNullInt(stock_rs.value(0));
        }
        

        String installment_price = "";
        String recurring_price = "";
        String duration_unit = "";
        String duration = "";
        String discount_recurring_price = "";
        String discount_duration = "";
        if(!installment_plan.equals("")){
            List<Object> list = gson.fromJson(rs.value("installment_options"), type);
            for(int i=0;i<list.size();i++){
                Map<String,String> map = (Map)list.get(i);
                if(map.get("id").equals(installment_plan)) {
                    installment_price = map.get("depositAmount");
                    recurring_price = map.get("installmentAmount");
                    duration_unit = map.get("durationUnit");
                    duration = map.get("durationValue");
                    discount_recurring_price = parseNull(map.get("discountInstallmentAmount"));
                    discount_duration = map.get("discountDurationValue");
                    
                }
            }
        }

        ProfilDiscount pdiscount = new ProfilDiscount();

        if(logged)
		{
            Set rsClient = Etn.execute("select profil from clients where id="+escape.cote(client_id));
            rsClient.next();
            String profil = rsClient.value(0);
            if(!profil.equals("")){
				pdiscount = CartHelper.getApplicableProfilDiscount(Etn, profil, rs.value("catalog_id"), rs.value("id"));
            }
        }

        String price_value = getPrice(price, taxpercentage,price_diff,quantity, rs.value("bundle_prices"), logged, pdiscount.getProductDiscount(), pdiscount.getProductDiscountType(), pdiscount.getCatalogDiscount(), pdiscount.getCatalogDiscountType(), pdiscount.getOverallDiscount(), pdiscount.getOverallDiscountType());
        String promo_price_value = getPrice(promo_price, taxpercentage,price_diff,quantity, rs.value("bundle_prices"), logged, pdiscount.getProductDiscount(), pdiscount.getProductDiscountType(), pdiscount.getCatalogDiscount(), pdiscount.getCatalogDiscountType(), pdiscount.getOverallDiscount(), pdiscount.getOverallDiscountType());

        String formatted_price = "";
        if(!price_value.equals("")) formatted_price = (parseNullDouble(price_value)<=0?libelle_msg(Etn, request, "gratuit"):formatPrice(priceformatter, roundto, showdecimals, price_value));
        String formatted_promo_price = "";
        if(!promo_price_value.equals("")) formatted_promo_price = (parseNullDouble(promo_price_value)<=0?libelle_msg(Etn, request, "gratuit"):formatPrice(priceformatter, roundto, showdecimals, promo_price_value));
        String formatted_installment_price = formatPrice(priceformatter, roundto, showdecimals, getSimplePrice(installment_price, taxpercentage,quantity));
        String formatted_recurring_price = formatPrice(priceformatter, roundto, showdecimals, getSimplePrice(recurring_price, taxpercentage,quantity));
        String formatted_discount_recurring_price = formatPrice(priceformatter, roundto, showdecimals, getSimplePrice(discount_recurring_price, taxpercentage,quantity));
        String recurring_string = "";

        //if(parseNullInt(discount_duration)>0) recurring_string = formatted_discount_recurring_price+" / "+libelle_msg(Etn, request, duration_unit)+"<br>"+libelle_msg(Etn, request, "Duration")+": "+discount_duration+" "+libelle_msg(Etn, request, duration_unit)+ "<br>" + libelle_msg(Etn, request, "puis") + " " + formatted_recurring_price+" / "+libelle_msg(Etn, request, duration_unit)+"<br> "+libelle_msg(Etn, request, "Duration")+": "+duration+" "+libelle_msg(Etn, request, duration_unit);
        //else recurring_string = formatted_recurring_price+" / "+libelle_msg(Etn, request, duration_unit)+"<br>"+libelle_msg(Etn, request, "Duration")+": "+duration+" "+libelle_msg(Etn, request, duration_unit);
        if(formatted_installment_price.length()>0){
            if(parseNullInt(discount_duration)>0){                                            
                discount_recurring_price = getSimplePrice(parseNull(discount_recurring_price), taxpercentage, quantity);

                recurring_price = getSimplePrice(parseNull(recurring_price), taxpercentage, quantity);

                recurring_string += "<p class='o-color-orange o-f20 o-ft25'>";

                if(parseNullDouble(discount_recurring_price) == 0){
                    recurring_string += "<strong>"+libelle_msg(Etn, request, "gratuit")+"</strong>";
                }
                else{
                    recurring_string += "<strong>"+formatPrice(priceformatter, roundto, showdecimals, discount_recurring_price)+ " "+ getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq) +"</strong>";
                }
                recurring_string += "</p>";
                recurring_string += "<p class='o-f12 o-ft25'>"+libelle_msg(Etn, request, "pendant")+" "+ discount_duration +" "+libelle_msg(Etn, request, duration_unit);
                recurring_string += "<br>"+libelle_msg(Etn, request, "puis") + " " + formatPrice(priceformatter, roundto, showdecimals, recurring_price) + " " + getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq) + " / " + libelle_msg(Etn, request, duration_unit);
                recurring_string += "<br>"+libelle_msg(Etn, request, "Engagement") + " " + duration + " " + libelle_msg(Etn, request, duration_unit);
                recurring_string += "</p>";
            }
            else{
                recurring_price = getSimplePrice(parseNull(recurring_price), taxpercentage, quantity);

                recurring_string += "<p class='o-color-orange o-f20 o-ft25'>";
                if(parseNullDouble(recurring_price) == 0){
                    recurring_string += "<strong>"+libelle_msg(Etn, request, "gratuit")+"</strong>";
                }
                else{
                    recurring_string += "<strong>"+formatPrice(priceformatter, roundto, showdecimals, recurring_price)+" "+getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq)+"</strong>";
                }
                recurring_string += "</p><p class='o-f12 o-ft25'>";
                recurring_string += "/ "+libelle_msg(Etn, request, duration_unit);
                recurring_string += "<br>"+libelle_msg(Etn, request, "Engagement") + " " + duration + " " + libelle_msg(Etn, request, duration_unit);
                recurring_string += "</p>";
            }
        }
        out.write("{\"stock\":\""+stock+"\",\"price\":\""+formatted_price+"\",\"promo_price\":\""+formatted_promo_price+"\",\"installment_price\":\""+formatted_installment_price+"\",\"recurring_price\":\""+recurring_string+"\",\"duration_unit\":\""+libelle_msg(Etn, request, duration_unit)+"\",\"duration\":\""+duration+"\",\"currency_frequency\":\""+currency_frequency+"\"}");
%>