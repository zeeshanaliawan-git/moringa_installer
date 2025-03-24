<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.*"%>
<%@ include file="../lib_msg.jsp"%>
<%@ include file="../cart/commonprice.jsp"%>
<%@ include file="../cart/common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="../cart/priceformatter.jsp"%>
<%
	String product_uuid = parseNull(request.getParameter("product_uuid"));
	String lang = parseNull(request.getParameter("lang"));
	String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
        
	String langue_id = "1";
	//if incoming lang was empty or not found in the language table, we will get the first language by default
	Set __rs1 = Etn.execute("select '0' as _a, langue_code, langue_id from "+catalogdb+".language where langue_code = " + escape.cote(lang) + " union select '1' as _a, langue_code, langue_id from "+catalogdb+".language where langue_id = 1 order by _a ");
	if(__rs1.next())
	{ 
		lang = parseNull(__rs1.value("langue_code"));
		langue_id = parseNull(__rs1.value("langue_id"));
	}
        
	set_lang(lang, request, Etn);

	String prefix = getProductColumnsPrefix(Etn, request, lang);
	String priceformatter  = "";
	String roundto = "";
	String showdecimals = "";
	String defaultcurrency = "";

	Set rs = Etn.execute("select * from "+catalogdb+".products where product_uuid="+ escape.cote(product_uuid));
	rs.next();

	Set rscat = Etn.execute("select * from "+catalogdb+".catalogs where id = " + rs.value("catalog_id"));
	rscat.next();

	boolean pricetaxincluded = ("1".equals(parseNull(rscat.value("price_tax_included")))?true:false);
	boolean showamountwithtax = ("1".equals(parseNull(rscat.value("show_amount_tax_included")))?true:false);
	TaxPercentage taxpercentage = new TaxPercentage();
	//taxpercentage.tax = parseNullDouble(rscat.value("tax_percentage"));
	taxpercentage.input_with_tax = pricetaxincluded;
	taxpercentage.output_with_tax = showamountwithtax;

	Set rsshop = Etn.execute("select * from "+catalogdb+".shop_parameters where site_id = " + escape.cote(rscat.value("site_id")) );
	rsshop.next();
	priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
	roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
	showdecimals = parseNull(rsshop.value(prefix + "show_decimals"));
	defaultcurrency = parseNull(rsshop.value(prefix + "currency"));

	String _currencyfreq = libelle_msg(Etn, request, parseNull(rs.value("currency_frequency")));

	String currency_frequency = getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq);

	ProductImageHelper imageHelper = new ProductImageHelper(rs.value("id"));

	Set rsVariants = Etn.execute("select pv.* from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id = pv.product_id where p.product_uuid = "+escape.cote(product_uuid)+" and pv.is_active = 1 order by pv.is_default");
	//System.out.println("select pv.* from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id = pv.product_id where p.product_uuid = "+escape.cote(product_uuid)+" order by pv.id");
	JSONArray json = new JSONArray();
	while(rsVariants.next()){
		JSONObject jo = new JSONObject();
		jo.put("id",rsVariants.value("id"));
		jo.put("inStock",(parseNullInt(rsVariants.value("stock"))>0?true:false));
		JSONObject flatRate = new JSONObject();
		flatRate.put("text","À partir de");
		flatRate.put("newPrice",getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true)+" "+currency_frequency);
		flatRate.put("oldPrice",getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, false)+" "+currency_frequency);
		jo.put("flatRate", flatRate);

		JSONObject baseRate = new JSONObject();
		baseRate.put("text","À partir de");
		baseRate.put("newPrice",getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true)+" "+currency_frequency);
		baseRate.put("oldPrice",getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, false)+" "+currency_frequency);
		jo.put("baseRate", baseRate);

		jo.put("shipment","Expédié à partir du 01/01/2019");

		
		JSONObject warning = new JSONObject();
		warning.put("title","Avance à payer :");
		warning.put("content","Minimun 400 GNF à la commande selon le choix du paiement");
		jo.put("warning",warning);
		
		JSONArray attributes = new JSONArray();
		Set rsVariantAttributes = Etn.execute("select cav.*, ca.value_type from "+catalogdb+".catalog_attribute_values cav inner join "+catalogdb+".product_variant_ref pvr on cav.id = pvr.catalog_attribute_value_id inner join "+catalogdb+".catalog_attributes ca on ca.cat_attrib_id = cav.cat_attrib_id where pvr.product_variant_id = "+escape.cote(rsVariants.value("id"))+" order by ca.sort_order");
		
		
		while(rsVariantAttributes.next()){
			JSONObject attribute = new JSONObject();
			attribute.put("attribute",rsVariantAttributes.value("cat_attrib_id"));
			attribute.put("value",rsVariantAttributes.value("id"));
			attributes.put(attribute);
//                if(rsVariantAttributes.value("value_type").equals("color")){
//                    jo.put("color",rsVariantAttributes.value("id"));
//                    jo.put("colorName",rsVariantAttributes.value("attribute_value"));
//                }
//                else{
//                    jo.put("storageCapacity",rsVariantAttributes.value("id"));
//                }
		}
		jo.put("attributes", attributes);
		/*JSONArray images = new JSONArray();
		String previousId = "";
		Set rsVariantImages = Etn.execute("select pvr.* from "+catalogdb+".product_variant_resources pvr inner join "+catalogdb+".product_variants pv on pvr.product_variant_id = pv.id where (pv.is_default=0 and product_variant_id = "+escape.cote(rsVariants.value("id"))+" or pv.is_default=1) and type='image' and langue_id="+escape.cote(langue_id)+" order by pv.is_default, pvr.sort_order;");
		System.out.println("select pvr.* from "+catalogdb+".product_variant_resources pvr inner join "+catalogdb+".product_variants pv on pvr.product_variant_id = pv.id where (pv.is_default=0 and product_variant_id = "+escape.cote(rsVariants.value("id"))+" or pv.is_default=1) and type='image' and langue_id="+escape.cote(langue_id)+" order by pv.is_default, pvr.sort_order;");
		while(rsVariantImages.next()){
			JSONObject image = new JSONObject();
			if(previousId.equals("") || previousId.equals(rsVariantImages.value("product_variant_id"))){
				image.put("small",imageHelper.getBase64Image(rsVariantImages.value("path")));
				image.put("big",imageHelper.getBase64Image(rsVariantImages.value("path")));
			}
			else break;
			images.put(image);
			previousId = rsVariantImages.value("product_variant_id");
		}
		jo.put("images",images);*/
		json.put(jo);
	}
	out.write(json.toString());
        
%>