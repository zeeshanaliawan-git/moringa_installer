<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type"%>
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
        int quantity = 1;

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

        

	Set rscat = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".catalogs where id = " + rs.value("catalog_id"));
	rscat.next();

        Set rsshop = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id = " + escape.cote(rscat.value("site_id"))  );
	rsshop.next();
	priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
        roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
        showdecimals = parseNull(rsshop.value(prefix + "show_decimals"));
	defaultcurrency = parseNull(rsshop.value(prefix + "currency"));

	String _currencyfreq = "";

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
        if(attributes!=null){
            for(String s : attributes) {
                if(!combo_key.equals("")) combo_key+="_";
                combo_key+=s;

                if(!attrib_keys.equals("")) attrib_keys+=",";
                attrib_keys+=escape.cote(s.substring(s.indexOf("_")+1));
            }
        }

        if(price_diff==null&&!attrib_keys.equals("")){
            price_diff = new String[attributes.length];
            //System.out.println("select price_diff from product_attribute_values where id IN ("+attrib_keys+")");
            Set attrib_rs = Etn.execute("select price_diff from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_attribute_values where id IN ("+attrib_keys+")");
            int count = 0;
            while(attrib_rs.next()){
                price_diff[count] = attrib_rs.value("price_diff");
                count++;
            }
        }

        Set stock_rs = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_stocks where product_id ="+escape.cote(rs.value("id"))+" and attribute_values="+escape.cote(combo_key));
        String stock ="0";
        if(stock_rs.next()) stock = stock_rs.value("stock");

        String recurring_price = "";
        String duration_unit = "";
        int duration = 0;
        String discount_recurring_price = "";
        int discount_duration = 0;
        double price_before_tax = 0;
        double promo_price_before_tax = 0;

        
            Gson gson = new Gson();
            Type type = new TypeToken<List<Object>>(){}.getType();
            List<Object> list = gson.fromJson(rs.value("installment_options"), type);
            int itemCount = list.size();
            for(int i=0;i<list.size();i++){
                Map<String,String> map = (Map)list.get(i);
                    recurring_price = map.get("installmentAmount");
                    price_before_tax = parseNullDouble(recurring_price);
                    duration_unit = map.get("durationUnit");
                    duration = parseNullInt(map.get("durationValue"));
                    discount_recurring_price = parseNull(map.get("discountInstallmentAmount"));
                    promo_price_before_tax = parseNullDouble(discount_recurring_price);
                    discount_duration = parseNullInt(map.get("discountDurationValue"));
                    double advance_amount = parseNullDouble(map.get("depositAmount"));
                    String advance_label = parseNull(map.get("depositLabel"));
                    String promo = (parseNullDouble(discount_recurring_price) - parseNullDouble(recurring_price))+"";
                    //int total_duration = duration/* + discount_duration*/; // discount duration is now subset of duration

                    boolean discounted = false;
                    boolean show_discount_conditions = false;
                    

                    String startDateString = parseNull(map.get("discountStartDate"));
                    String endDateString = parseNull(map.get("discountEndDate"));                    

                    DateFormat df = new SimpleDateFormat("yyyy-MM-dd"); 
                    DateFormat df_display = new SimpleDateFormat("dd/MM/yyyy"); 
                    Date startDate = new Date();
                    Date endDate = new Date();
                    Date currentDate = new Date();
                    try {
                        if(startDateString.length()!=0) startDate = df.parse(startDateString);
                        if(endDateString.length()!=0) endDate = df.parse(endDateString);
                        //String newDateString = df.format(startDate);
                        //if(discount_duration>0 && !endDate.before(currentDate)) show_discount_conditions = true; // commented as we dont show the conditions right now for upcoming discounts
                        if(discount_duration>0 && !(currentDate.before(startDate) || currentDate.after(endDate))){
                            show_discount_conditions = true;
                            discounted = true;
                        }
                        else{
                            discounted = false;
                        } 
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
    %>
                <div class="<%=(itemCount==1?"":"custom-control custom-radio")%>" style="padding-left: 1.875rem;margin-bottom: 15px;">
                    <input type="radio" name="installment_plan" id="installment_<%=map.get("id")%>" class="custom-control-input" <%=(i==0?"checked":"")%> value="<%=map.get("id")%>" >
                    <label class="<%=(itemCount==1?"":"custom-control-label")%> text-right" for="installment_<%=map.get("id")%>" style="display:block">
                        <strong class="text-primary"><%=formatPrice(priceformatter, roundto, showdecimals, getSimplePrice((discounted?discount_recurring_price:recurring_price), taxpercentage,quantity))%> <%=currency_frequency%></strong><strong>/<%=libelle_msg(Etn, request, duration_unit)%></strong>
                    </label>
                        <p class="text-right" style="<%=(discounted?"":"display:none;")%>"><%=libelle_msg(Etn, request, "pendant")%> <%=discount_duration%> <%=libelle_msg(Etn, request, duration_unit)%> <%=libelle_msg(Etn, request, "puis")%> <%=formatPrice(priceformatter, roundto, showdecimals, getSimplePrice(recurring_price, taxpercentage,quantity))%> <%=currency_frequency%>/<%=libelle_msg(Etn, request, duration_unit)%> </p>                    
                    <%
                    if(advance_amount>0){
                    %>
                    <p class="text-right"><strong>(<%=advance_label%> : <%=formatPrice(priceformatter, roundto, showdecimals, getSimplePrice(advance_amount+"", taxpercentage,quantity))%> <%=currency_frequency%>) </strong></p>
                    
                    <%
                    }
                    
                    if(duration==0){
                    %>
                    <p class="text-right"><strong><%=libelle_msg(Etn, request, "Sans engagement")%></strong></p>
                    <%
                    }
                    else{
                    %>
                    <p class="text-right"><strong><%=duration%> <%=libelle_msg(Etn, request, duration_unit)%> <%=libelle_msg(Etn, request, "d'engagement")%> </strong></p>
                    <%
                    }
                    if(show_discount_conditions||!parseNull(map.get("infoText")).equals("")){
                        String info_title = ((show_discount_conditions&&!parseNull(map.get("discountInfoText")).equals("")?parseNull(map.get("discountInfoTitle")):parseNull(map.get("infoTitle"))));
                        if(info_title.equals("")) info_title = libelle_msg(Etn, request, "Voir conditions");
                        String info_text = (show_discount_conditions&&!parseNull(map.get("discountInfoText")).equals("")?parseNull(map.get("discountInfoText")):parseNull(map.get("infoText")))
                            .replaceAll("<discountStartDate>",df_display.format(startDate))
                            .replaceAll("<discountEndDate>",df_display.format(endDate))
                            .replaceAll("<offerName>",rs.value(prefix + "name"))
                            .replaceAll("<durationUnit>",libelle_msg(Etn, request, duration_unit))
                            .replaceAll("<discountDuration>",discount_duration+"")
                            .replaceAll("<amount>",formatPrice(priceformatter, roundto, showdecimals, getSimplePrice(recurring_price, taxpercentage,quantity)))
                            .replaceAll("<duration>",duration+"")
                            .replaceAll("<totalDuration>",duration+"")
                            .replaceAll("<discountAmount>",formatPrice(priceformatter, roundto, showdecimals, getSimplePrice(discount_recurring_price, taxpercentage,quantity)));
                    %>
                    <div id="conditions_<%=map.get("id")%>" class="o-well bg-light <%=(itemCount==1?"":"voir_conditions")%>" style="<%=(itemCount==1?"":"display:none;")%>">
                        <p><strong class="text-primary" style="<%=(discounted?"":"display:none;")%>"><%=libelle_msg(Etn, request, "Promo")%> <%=formatPrice(priceformatter, roundto, showdecimals, getSimplePrice(promo, taxpercentage,quantity))%> <%=currency_frequency%>/<%=libelle_msg(Etn, request, duration_unit)%> <%=libelle_msg(Etn, request, "pendant")%> <%=discount_duration%> <%=libelle_msg(Etn, request, duration_unit)%> </strong></p>
                      <a href="#" class="toggleInfo" style="<%=(info_text.equals("")?"display:none;":"")%>"><%=info_title%> <span class="o-glyphicon o-glyphicon-triangle-bottom"></span></a>
                      <p style="display:none;"><%=info_text%> </p>
                    </div>
                    <%
                    }
                    %>
                </div>
                <!--<option value="<%=map.get("id")%>"><%=libelle_msg(Etn, request, parseNull(map.get("name")))%></option>-->
    <%          
            }
    %>