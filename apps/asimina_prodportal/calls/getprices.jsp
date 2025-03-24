<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.Contexte, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*, com.etn.util.Base64"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>
<%@ page import="com.etn.asimina.beans.*"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.ProductImageHelper, com.etn.asimina.util.PortalHelper"%>
<%@ include file="../lib_msg.jsp"%>
<%@ include file="../cart/commonprice.jsp"%>
<%@ include file="../cart/common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../cart/imager.jsp"%>
<%@ include file="../cart/priceformatter.jsp"%>

<%!

    public boolean isNumeric(String str) {
        return str.matches("-?\\d+(\\.\\d+)?");  //match a number with optional '-' and decimal.
    }

    public double getDouble(String str){

        if(isNumeric(str)){
            return Double.parseDouble(str);
        }
        return 0;
    }

    public int getInt(String str){

        if(isNumeric(str)){
            return (int)Double.parseDouble(str);
        }
        return 0;
    }

    String getStickerClass(String sticker){
        return "Tab-orange";
    }

    JSONObject getPromotionObject(Contexte Etn, TaxPercentage taxpercentage, String productId, String catalogdb, boolean flag, javax.servlet.http.HttpServletRequest request, String prefix, String minVariantId)
	{
        return getPromotion(Etn, request, minVariantId, prefix);
    }

    String getVariantSticker(Contexte Etn, TaxPercentage taxpercentage, String productId, String catalogdb, boolean flag, javax.servlet.http.HttpServletRequest request){

        Set rs = Etn.execute("select sticker from " + catalogdb + ".product_variants, " + catalogdb + ".stickers where sticker = sname and product_id = " + escape.cote(productId) + " and sticker is not null and sticker not in ('','none') order by priority");

        String sticker = "";

        if(rs.next()) {

            return parseNull(rs.value("sticker"));
        }

        return "";
    }

    String getVariantStickerColor(Contexte Etn, String siteId, String sticker, String catalogdb){

        Set rs = Etn.execute("select color from " + catalogdb + ".stickers where site_id = " + escape.cote(siteId) + " and sname = " + escape.cote(sticker));

        if(rs.next()) {

            return parseNull(rs.value("color"));
        }

        return "";
    }

    JSONObject getMaxPriceVariant(Contexte Etn, HttpServletRequest request, String siteId, Language language, TaxPercentage taxpercentage, String productId, String catalogdb, String client_id, 
				String priceformatter, String roundto, String showDecimal, String currency_frequency, String prefix) throws Exception
	{
		java.util.Map<String, String> map = getVariantByPrice(Etn, taxpercentage, productId, catalogdb, client_id, false);
		JSONObject jMaxVariant = new JSONObject();
		jMaxVariant.put("id", map.get("id"));

		if(parseNull(map.get("id")).length() > 0)
		{
			Set rsPV = Etn.execute("select * from "+catalogdb+".product_variant_details where langue_id= "+escape.cote(""+language.getLanguageId())+" and product_variant_id ="+escape.cote(parseNull(map.get("id"))));
			if(rsPV.next())
			{
				jMaxVariant.put("name", parseNull(rsPV.value("name")));
			}
		}
		
		String price = formatPrice(priceformatter, roundto, showDecimal, parseNull(map.get("promoPrice")));
		String originalPrice = formatPrice(priceformatter, roundto, showDecimal, parseNull(map.get("originalPrice")));
		String priceUnformated = formatPrice(priceformatter, roundto, showDecimal, parseNull(map.get("promoPrice")), true);
		String originalPriceUnformated = formatPrice(priceformatter, roundto, showDecimal, parseNull(map.get("originalPrice")), true);

		if(price.equals(originalPrice)) price = originalPrice;

		String dlPrice = priceUnformated;
		if(price.equals("0")) {

			priceUnformated = "";
			price = libelle_msg(Etn, request, "Gratuit");
		}
		else if(price.length() > 0) {
			price = PortalHelper.getCurrencyPosition(Etn, request, siteId,  Integer.parseInt(language.getLanguageId()), price, currency_frequency);
		}

		if(originalPrice.equals("0")){

			originalPrice = libelle_msg(Etn, request, "Gratuit");

		} else if(originalPrice.length() > 0) {
			originalPrice = PortalHelper.getCurrencyPosition(Etn, request, siteId,  Integer.parseInt(language.getLanguageId()), originalPrice, currency_frequency);
		}
		
		jMaxVariant.put("price", price);
		jMaxVariant.put("price_unformatted", priceUnformated);
		jMaxVariant.put("original_price", originalPrice);
		jMaxVariant.put("original_price_unformatted", originalPriceUnformated);
		jMaxVariant.put("promo", getPromotionObject(Etn, taxpercentage, productId, catalogdb, true, request, prefix, parseNull(map.get("id"))));
		
		return jMaxVariant;
	}
	
    java.util.Map<String, String> getMinPriceVariant(Contexte Etn, TaxPercentage taxpercentage, String productId, String catalogdb, String client_id)
	{
		return getVariantByPrice(Etn, taxpercentage, productId, catalogdb, client_id, true);
	}
	
    java.util.Map<String, String> getVariantByPrice(Contexte Etn, TaxPercentage taxpercentage, String productId, String catalogdb, String client_id, boolean minimum)
	{
        String  isVariantPricesDiffer = "0";
        Set rs = Etn.execute("select pv.id, pv.is_show_price from " + catalogdb + ".product_variants pv, " + catalogdb + ".products p where p.id = pv.product_id and p.id = " + escape.cote(productId) + " and pv.is_active = 1 order by pv.id");
        String variantId = "";
        String isShowPrice = "";
        String price = "";
        String mPrice = "0.00";
        String mVariantId = "";
        String variantPrice = "0.00";

		java.util.Map<String, String> results = new java.util.HashMap<String, String>();

        if(rs.next())
		{
            variantId = rs.value("id");
            isShowPrice = parseNull(rs.value("is_show_price"));

            if(isShowPrice.equals("1"))
			{
                mPrice = getPrice(Etn, variantId, taxpercentage, 1, true, client_id);//applyPromo
				variantPrice = getPrice(Etn, variantId, taxpercentage, 1, false, client_id);//not applyPromo
				mVariantId = variantId;
			}
        }

        rs.moveFirst();
        ArrayList<Double> variantPrices = new ArrayList();
        while(rs.next()){

            variantId = rs.value("id");
            isShowPrice = parseNull(rs.value("is_show_price"));
            if(isShowPrice.equals("1")){

                price = getPrice(Etn, variantId, taxpercentage, 1, true, client_id);//applyPromo
                variantPrices.add(getDouble(price));
                if(minimum && getDouble(price) < getDouble(mPrice) )
				{
					mPrice = price;
					variantPrice = getPrice(Etn, variantId, taxpercentage, 1, false, client_id);//not applyPromo
					mVariantId = variantId;
				}
                else if(minimum == false && getDouble(price) > getDouble(mPrice) )
				{
					mPrice = price;
					variantPrice = getPrice(Etn, variantId, taxpercentage, 1, false, client_id);//not applyPromo
					mVariantId = variantId;
				}
            }
        }
        if(variantPrices.size()>1){
            if(new HashSet<Double>(variantPrices).size() >1){
                isVariantPricesDiffer = "1";
            }
        }
		results.put("id", mVariantId);
		results.put("promoPrice", mPrice);
		results.put("originalPrice", variantPrice);
        results.put("isVariantPricesDiffer", isVariantPricesDiffer);


        return results;
    }

/*    boolean checkVariantStock(Contexte Etn, String productId, String catalogdb){

        Set rs = Etn.execute("SELECT SUM(stock) as stock FROM " + catalogdb + ".product_variants WHERE product_id = " + escape.cote(productId));

        if(rs.next()){

            if(getInt(rs.value("stock")) > 0) return true;

            return false;
        }

        return false;
    }*/

    int getProductStock(Contexte Etn, String productId, String catalogdb)
	{
		if(parseNull(productId).length() == 0) return 0;
        Set rs = Etn.execute("SELECT SUM(stock) as stock FROM " + catalogdb + ".product_variants WHERE product_id = " + escape.cote(productId));

		int stock = 0;
        if(rs.next())
		{
			try{
				stock = Integer.parseInt(rs.value("stock"));
			}
			catch(Exception e){
				stock = 0;
			}
        }
		return stock;
    }

    JSONObject getProductAttributeValues(Contexte Etn, String catalogId, String productId, String catalogdb){

        JSONObject values = new JSONObject();
        String key = "";

        try{

            String query = "" +
                            " select name, GROUP_CONCAT(attribute_value) attribute_values " +
                            "   from " + catalogdb + ".catalog_attributes c " +
                            "   left join " + catalogdb + ".product_attribute_values v on c.cat_attrib_id = v.cat_attrib_id and product_id = " + escape.cote(productId) +
                            "  where catalog_id = " + escape.cote(catalogId) +
                            "  group by name; ";
            Set rs = Etn.execute(query);

            if(rs != null){
                while(rs.next()){

                    key = parseNull(rs.value("name")).replaceAll("\\s+","").toLowerCase();
                    values.put(key,rs.value("attribute_values").split(","));
                }
            }
        }catch(JSONException ex){

            System.out.println(ex.toString());
        }

        return values;
    }

    boolean isShowPrice(Contexte Etn, String productId, String catalogdb){

        Set rs = Etn.execute("select is_show_price from " + catalogdb + ".product_variants where product_id = " + escape.cote(productId) + " and is_show_price = '1' group by is_show_price");

        if(rs != null && rs.next()){

            return true;
        }

        return false;
    }

%>

<%
	String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
    String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
    String lang = parseNull(request.getParameter("lang"));
    String catalogId = parseNull(request.getParameter("catalog_id"));
    String prefix = getProductColumnsPrefix(Etn, request, lang);
    String productUpdatedMinPrice = "";
    String productUpdatedMaxPrice = "";
    int count = 0;

    set_lang(lang, request, Etn);

    Language language = LanguageFactory.instance.getLanguage(lang);
    if(language == null){
        out.write("<div style='color:red;font-weight:bold'>Invalid language provided</div>");
        return;
    }

    String langColPrefix  = "lang_" + language.getLanguageId() + "_" ;
    String langJSONPrefix = "lang" + language.getLanguageId();

    JSONArray products = new JSONArray();
    JSONObject product = new JSONObject();
    JSONObject langRef = new JSONObject();
    JSONObject promotionObject = new JSONObject();

    String productId = "";
    String summary = "";
    String mainFeatures = "";
    // adding product variants join because to get the newly created variants
    Set rs = Etn.execute("select p.* from " + catalogdb + ".products p, " + catalogdb + ".product_variants pv where p.id = pv.product_id and catalog_id = " + escape.cote(catalogId) + " group by p.id order by COALESCE(max(p.first_publish_on), max(pv.created_on)) desc, order_seq, p.id;");

    String _currencyfreq = "";
    String currency_frequency = "";
    Set rscat = Etn.execute("select * from "+catalogdb+".catalogs where id = " + escape.cote(catalogId));
    rscat.next();

	String catalogType = rscat.value("catalog_type");

    boolean pricetaxincluded = ("1".equals(parseNull(rscat.value("price_tax_included")))?true:false);
    boolean showamountwithtax = ("1".equals(parseNull(rscat.value("show_amount_tax_included")))?true:false);

    TaxPercentage taxpercentage = new TaxPercentage();
    taxpercentage.tax = parseNullDouble(rscat.value("tax_percentage"));
    taxpercentage.input_with_tax = pricetaxincluded;
    taxpercentage.output_with_tax = showamountwithtax;
    taxpercentage.tax_exclusive = !showamountwithtax;

    Set rsshop = Etn.execute("select * from "+catalogdb+".shop_parameters where site_id = " + escape.cote(rscat.value("site_id")) );
    rsshop.next();

    String defaultcurrency = parseNull(rsshop.value(prefix + "currency"));
    String showDecimal = "0";

    if(parseNull(rsshop.value(langColPrefix+"show_decimals")).length() > 0)
        showDecimal = parseNull(rsshop.value(langColPrefix+"show_decimals"));

    String priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
    String roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
    String priceDisplayLabel = parseNull(rsshop.value(langColPrefix+"no_price_display_label"));
    double priceDifferencePercentage = 0.00;

    Set stickerRs = Etn.execute("select sname, display_name_" + language.getLanguageId() + " as display_name from " + catalogdb + ".stickers where site_id = " + escape.cote(rscat.value("site_id")));

	JSONObject results = new JSONObject();

    if(rs != null){

        while(rs.next())
		{

            priceDifferencePercentage = 0.00;

            product = toJSONObject(rs);
            productId = parseNull(rs.value("id"));

            _currencyfreq = libelle_msg(Etn, request, parseNull(rs.value("currency_frequency")));
            currency_frequency = getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq);

			java.util.Map<String, String> minProductVariant = getMinPriceVariant(Etn, taxpercentage, productId, catalogdb, client_id);					

            String minPrice = formatPrice(priceformatter, roundto, showDecimal, parseNull(minProductVariant.get("promoPrice")));
			String originalPrice = formatPrice(priceformatter, roundto, showDecimal, parseNull(minProductVariant.get("originalPrice")));
			String minPriceUnformated = formatPrice(priceformatter, roundto, showDecimal, parseNull(minProductVariant.get("promoPrice")), true);
			String originalPriceUnformated = formatPrice(priceformatter, roundto, showDecimal, parseNull(minProductVariant.get("originalPrice")), true);

            if(minPrice.equals(originalPrice)) minPrice = originalPrice;

			String minDlPrice = minPriceUnformated;//minPrice;
            if(minPrice.equals("0")) {

                minPriceUnformated = "";
                minPrice = libelle_msg(Etn, request, "Gratuit");
                //minDlPrice = libelle_msg(Etn, request, "Gratuit");
            }
            else if(minPrice.length() > 0) {
                minPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"),  Integer.parseInt(language.getLanguageId()), minPrice, currency_frequency);
            }

            if(originalPrice.equals("0")){

                originalPrice = libelle_msg(Etn, request, "Gratuit");

            } else if(originalPrice.length() > 0) {
                originalPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"),  Integer.parseInt(language.getLanguageId()), originalPrice, currency_frequency);
            }


            promotionObject = getPromotionObject(Etn, taxpercentage, productId, catalogdb, true, request, prefix, parseNull(minProductVariant.get("id")));

            if(count++ == 0){

                productUpdatedMinPrice = minPriceUnformated;
                productUpdatedMaxPrice = originalPriceUnformated;
            }

            if(getDouble(minPriceUnformated) < getDouble(productUpdatedMinPrice))
                productUpdatedMinPrice = minPriceUnformated;

            if(getDouble(originalPriceUnformated) > getDouble(productUpdatedMaxPrice))
                productUpdatedMaxPrice = originalPriceUnformated;

            priceDifferencePercentage = parseNullDouble(originalPriceUnformated) - parseNullDouble(minPriceUnformated);

            if(priceDifferencePercentage > 0){
                priceDifferencePercentage /= parseNullDouble(originalPriceUnformated);
                priceDifferencePercentage *= 100;
            }

			int minPriceVariantStock = getProductStock(Etn, productId, catalogdb);
			String sticker = getVariantSticker(Etn, taxpercentage, productId, catalogdb, true, request);

            String stickerColor = getVariantStickerColor(Etn, rscat.value("site_id"), sticker, catalogdb);
			
            product.put("variantSticker", sticker);
            product.put("variantStickerColor", stickerColor);
            product.put("minDlPrice", minDlPrice);
            product.put("minPriceFrom", minPrice);
            product.put("originalPriceFrom", originalPrice);
            product.put("minPriceFromUnformatted", minPriceUnformated);
            product.put("originalPriceFromUnformatted", originalPriceUnformated);
            product.put("isShowPrice", isShowPrice(Etn, productId, catalogdb));
            //product.put("inStock", checkVariantStock(Etn, productId, catalogdb));
            product.put("inStock", minPriceVariantStock > 0);
            product.put("promotionPercentage", priceDifferencePercentage);
            product.put("promotion", promotionObject);
            product.put("minPriceVariantId", parseNull(minProductVariant.get("id")));

			String variantName = "";
			if(parseNull(minProductVariant.get("id")).length() > 0)
			{
				Set rsPV = Etn.execute("select * from "+catalogdb+".product_variant_details where langue_id= "+escape.cote(""+language.getLanguageId())+" and product_variant_id ="+escape.cote(parseNull(minProductVariant.get("id"))));
				if(rsPV.next())
				{
					variantName = parseNull(rsPV.value("name"));
				}
			}
            product.put("minPriceVariantName", variantName);


            if(promotionObject.length() > 0)
                results.put("flashSaleQuantity_"+productId, libelle_msg(Etn, request, "Plus que <qty> articles").replace("<qty>",promotionObject.getString("flash_sale_quantity")));

            JSONObject attributeValues = getProductAttributeValues(Etn, catalogId, productId, catalogdb);

            product.put("attributeValues",attributeValues);
			product.put("tax_exclusive",taxpercentage.tax_exclusive);


			JSONObject extraProductImpressionAttrs = new JSONObject();
			if(catalogType.equalsIgnoreCase("offer"))
			{
				extraProductImpressionAttrs.put("pi_in_stock", "yes");
				extraProductImpressionAttrs.put("pi_stock", "");
				extraProductImpressionAttrs.put("pi_currency", defaultcurrency);
				product.put("productImpressionCategory", "offer");
			}
			else
			{

				extraProductImpressionAttrs.put("pi_in_stock", (minPriceVariantStock>0)?"yes":"no");
				extraProductImpressionAttrs.put("pi_stock", minPriceVariantStock);
				extraProductImpressionAttrs.put("pi_currency", defaultcurrency);
				String _productCategory = "product";
				if(parseNull(rs.value("device_type")).length() > 0) _productCategory = parseNull(rs.value("device_type"));
				product.put("productImpressionCategory", _productCategory);
                product.put("comeswith", getComewith(Etn, request, parseNull(minProductVariant.get("id")), prefix, language.getLanguageId(), "", false));
			}

			product.put("extraImpressionAttrs", extraProductImpressionAttrs);
            product.put("isVariantPricesDiffer",minProductVariant.get("isVariantPricesDiffer"));
			
			JSONObject jMinVariant = new JSONObject();
			jMinVariant.put("id", product.get("minPriceVariantId"));
			jMinVariant.put("name", product.get("minPriceVariantName"));
			jMinVariant.put("price", product.get("minPriceFrom"));
			jMinVariant.put("price_unformatted", product.get("minPriceFromUnformatted"));
			jMinVariant.put("original_price", product.get("originalPriceFrom"));
			jMinVariant.put("original_price_unformatted", product.get("originalPriceFromUnformatted"));
			jMinVariant.put("promo", product.get("promotion"));
			
			product.put("min_variant", jMinVariant);
			product.put("max_variant", getMaxPriceVariant(Etn, request, rscat.value("site_id"), language, taxpercentage, productId, catalogdb, client_id, 
															priceformatter, roundto, showDecimal, currency_frequency, prefix));
						
			
            products.put(product);
        }
    }

    langRef.put("commitment", libelle_msg(Etn, request, "Avec engagement"));
    langRef.put("month", libelle_msg(Etn, request, "mois"));
    langRef.put("months", libelle_msg(Etn, request, "mois(s)"));
    langRef.put("without_engagement", libelle_msg(Etn, request, "Sans engagement"));
    langRef.put("then", libelle_msg(Etn, request, "puis"));
    langRef.put("instead_of", libelle_msg(Etn, request, "au lieu de"));
    langRef.put("price_display_label", priceDisplayLabel);
    langRef.put("promotion", libelle_msg(Etn, request, "Promotion"));
    langRef.put("flash_sale", libelle_msg(Etn, request, "Vente flash"));
    langRef.put("out_of_stock", libelle_msg(Etn, request, "Indisponible"));
    langRef.put("price_only", libelle_msg(Etn, request, "Prix seul"));
    langRef.put("starting_from", libelle_msg(Etn, request, "A partir de"));

    while(stickerRs.next()){

        langRef.put(parseNull(stickerRs.value("sname")), parseNull(stickerRs.value("display_name")));
    }

    results.put("productUpdatedMinPrice",productUpdatedMinPrice);
    results.put("productUpdatedMaxPrice",productUpdatedMaxPrice);

	results.put("products", products);
	results.put("translations", langRef);
    results.put("defaultcurrency",defaultcurrency);
	results.put("langJSONPrefix", langJSONPrefix);

	JSONObject countrySpecificDLAttrs = new JSONObject();
    countrySpecificDLAttrs.put("dimensionX", "");
    countrySpecificDLAttrs.put("dimensionXX", "data-extra_pi_in_stock");
    countrySpecificDLAttrs.put("metricXX", "data-extra_pi_stock");

	results.put("extra_product_impression_attrs", countrySpecificDLAttrs);


	String json = "{\"products\":"+products.toString();
	json += ", \"translations\":"+langRef.toString();
	json += "}";
    out.write(results.toString());
%>

