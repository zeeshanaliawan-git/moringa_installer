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
	String slot_discount_type = parseNull(request.getParameter("slot_discount_type"));
	double slot_discount_value = parseNullDouble(request.getParameter("slot_discount_value"));
        
	String client_id = "";
	boolean logged = false;
	com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	if(client != null)
	{
		logged = true;
		client_id = client.getProperty("id");
	}
		
	String strquantity = parseNull(request.getParameter("quantity"));
	int quantity = 1;
	if (strquantity.length() > 0) quantity = Integer.parseInt(strquantity);

	String[] attributes = request.getParameterValues("attributes");

	Set rs = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where product_uuid="+ escape.cote(product_uuid));
	rs.next();

	ProfilDiscount pdiscount = new ProfilDiscount();

	if(logged)
	{
		Set rsClient = Etn.execute("select profil from clients where id="+escape.cote(client_id));
		rsClient.next();
		String profil = rsClient.value(0);
		if(!profil.equals(""))
		{
			pdiscount = CartHelper.getApplicableProfilDiscount(Etn, profil, rs.value("catalog_id"), rs.value("id"));
		}
	}

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

        Set rsshop = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id = " + escape.cote(rscat.value("site_id"))  );
	rsshop.next();
	priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
        roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
        showdecimals = parseNull(rsshop.value(prefix + "show_decimals"));
	defaultcurrency = parseNull(rsshop.value(prefix + "currency"));

	String _currencyfreq = libelle_msg(Etn, request, parseNull(rs.value("currency_frequency")));

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

        Gson gson = new Gson();
        Type type = new TypeToken<List<Object>>(){}.getType();

        if(!rs.value("combo_prices").equals("")){
            List<Object> list = gson.fromJson(rs.value("combo_prices"), type);
            //String price = "";
            for(int i=0;i<list.size();i++){
                Map<String,String> map = (Map)list.get(i);
                
                    //out.write(parseNull(map.get("priceDiff")));
                    price_diff = new String[1];
                    price_diff[0] = parseNull(map.get("priceDiff"));
                
            }
        }

        /*if(price_diff==null&&!attrib_keys.equals("")){
            price_diff = new String[attributes.length];
            //System.out.println("select price_diff from product_attribute_values where id IN ("+attrib_keys+")");
            Set attrib_rs = Etn.execute("select price_diff from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_attribute_values where id IN ("+attrib_keys+")");
            int count = 0;
            while(attrib_rs.next()){
                price_diff[count] = attrib_rs.value("price_diff");
                count++;
            }
        }*/

        String stock_query = "";
        if(rs.value("link_id").equals("")){
            stock_query = "select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_stocks where product_id ="+escape.cote(rs.value("id"))+" and attribute_values=''";
        }
        else {
            stock_query = "select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_link where id ="+escape.cote(rs.value("link_id"));
        }
        Set stock_rs = Etn.execute(stock_query);
        String stock ="0";
        if(stock_rs.next()) stock = stock_rs.value("stock");

        String price_value = getPrice(price, taxpercentage,price_diff,quantity, rs.value("bundle_prices"), logged, pdiscount.getProductDiscount(), pdiscount.getProductDiscountType(), pdiscount.getCatalogDiscount(), pdiscount.getCatalogDiscountType(), slot_discount_value, slot_discount_type, pdiscount.getOverallDiscount(), pdiscount.getOverallDiscountType());
        String promo_price_value = getPrice(promo_price, taxpercentage,price_diff,quantity, rs.value("bundle_prices"), logged, pdiscount.getProductDiscount(), pdiscount.getProductDiscountType(), pdiscount.getCatalogDiscount(), pdiscount.getCatalogDiscountType(), slot_discount_value, slot_discount_type, pdiscount.getOverallDiscount(), pdiscount.getOverallDiscountType());

        String formatted_price = "";
        if(!price_value.equals("")) formatted_price = (parseNullDouble(price_value)<=0?libelle_msg(Etn, request, "gratuit"):formatPrice(priceformatter, roundto, showdecimals, price_value));
        String formatted_promo_price = "";
        if(!promo_price_value.equals("")) formatted_promo_price = (parseNullDouble(promo_price_value)<=0?libelle_msg(Etn, request, "gratuit"):formatPrice(priceformatter, roundto, showdecimals, promo_price_value));
        out.write("{\"stock\":\""+stock+"\",\"price\":\""+formatted_price+"\",\"promo_price\":\""+formatted_promo_price+"\",\"currency_frequency\":\""+currency_frequency+"\"}");
%>