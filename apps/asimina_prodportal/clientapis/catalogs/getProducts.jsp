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
<%@ include file="../../lib_msg.jsp"%>
<%@ include file="../../cart/commonprice.jsp"%>
<%@ include file="../../cart/common.jsp"%>
<%@ include file="../../common.jsp"%>
<%@ include file="../../common2.jsp"%>
<%@ include file="../../cart/imager.jsp"%>
<%@ include file="../../cart/priceformatter.jsp"%>
<%@ include file="../errorTypes.jsp"%>

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

    java.util.Map<String, String> getMinPriceVariant(Contexte Etn, TaxPercentage taxpercentage, String productId, String catalogdb, String client_id)
	{
        String  isVariantPricesDiffer = "0";
        Set rs = Etn.execute("select pv.id, pv.is_show_price from " + catalogdb + ".product_variants pv, " + catalogdb + ".products p where p.id = pv.product_id and p.id = " + escape.cote(productId) + " and pv.is_active = 1 order by pv.id");
        String variantId = "";
        String isShowPrice = "";
        String price = "";
        String minPrice = "0.00";
        String minVariantId = "";
        String variantPrice = "0.00";

		java.util.Map<String, String> results = new java.util.HashMap<String, String>();

        if(rs.next())
		{
            variantId = rs.value("id");
            isShowPrice = parseNull(rs.value("is_show_price"));

            if(isShowPrice.equals("1"))
			{
                minPrice = getPrice(Etn, variantId, taxpercentage, 1, true, client_id);//applyPromo
				variantPrice = getPrice(Etn, variantId, taxpercentage, 1, false, client_id);//not applyPromo
				minVariantId = variantId;
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
                if(getDouble(price) < getDouble(minPrice) )
				{
					minPrice = price;
					variantPrice = getPrice(Etn, variantId, taxpercentage, 1, false, client_id);//not applyPromo
					minVariantId = variantId;
				}
            }
        }
        if(variantPrices.size()>1){
            if(new HashSet<Double>(variantPrices).size() >1){
                isVariantPricesDiffer = "1";
            }
        }
		results.put("id", minVariantId);
		results.put("promoPrice", minPrice);
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
	try
	{
		String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
		String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
		String muid = parseNull(request.getParameter("muid"));
		String catalogUUID = parseNull(request.getParameter("catalogId"));
		
		Set rsMenu = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(muid));
		if(muid.length() > 0 && rsMenu != null && rsMenu.next())
		{	
			String lang = rsMenu.value("lang");
			set_lang(lang, request, Etn);
			String siteid = rsMenu.value("site_id");
			Language language = LanguageFactory.instance.getLanguage(lang);
			if(language == null)
			{
				out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_LANG + ",\"message\":\"" + ErrorMessages.INVALID_LANG + "\"}");
			}
			else
			{
				//important :: catalog_uuid is unique across a site so we must put check of site_id here
				Set rscat = Etn.execute("select * from "+catalogdb+".catalogs where site_id = "+escape.cote(siteid)+" and catalog_uuid = " + escape.cote(catalogUUID));
				if(rscat != null && rscat.next())
				{
					String catalogId = rscat.value("id");
					String prefix = getProductColumnsPrefix(Etn, request, lang);
					String productUpdatedMinPrice = "";
					String productUpdatedMaxPrice = "";
					int count = 0;
					String langColPrefix  = "lang_" + language.getLanguageId() + "_" ;
					String langJSONPrefix = "lang" + language.getLanguageId();

					JSONArray products = new JSONArray();
					JSONObject product = new JSONObject();
					JSONObject stickers = new JSONObject();
					JSONObject promotionObject = new JSONObject();

					String productId = "";
					String summary = "";
					String mainFeatures = "";
					// adding product variants join because to get the newly created variants
					// adding join with catalogs as we get cataloguuid from request
					//important :: we must put check on c.id .. if we have to put check on c.catalog_uuid then we must add site_id in where clause as well
					String query = "select p.* from " + catalogdb + ".catalogs c," + catalogdb + ".products p, " + catalogdb + ".product_variants pv where c.id = p.catalog_id and p.id = pv.product_id and c.id = " + escape.cote(catalogId) + " group by p.id order by COALESCE(max(p.first_publish_on), max(pv.created_on)) desc, order_seq, p.id;";
					System.out.println("....query:" + query);
					Set rs = Etn.execute(query);


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
					//System.out.println("defaultcurrency:"+defaultcurrency);
					String defaultcurrencylabel = libelle_msg(Etn, request, defaultcurrency);
					//System.out.println("defaultcurrencylabel:"+defaultcurrencylabel);
					String showDecimal = "0";

					if(parseNull(rsshop.value(langColPrefix+"show_decimals")).length() > 0)
						showDecimal = parseNull(rsshop.value(langColPrefix+"show_decimals"));

					String priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
					String roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
					String priceDisplayLabel = parseNull(rsshop.value(langColPrefix+"no_price_display_label"));
					double priceDifferencePercentage = 0.00;

					JSONObject results = new JSONObject();
					results.put("showAmountWithTax",showamountwithtax);
					results.put("noOfDecimals",showDecimal);
					results.put("roundTo",roundto);
					results.put("priceFormatter",priceformatter);
					results.put("currency",defaultcurrency);
					results.put("currencylabel",defaultcurrencylabel);

					Set stickerRs = Etn.execute("select sname, display_name_" + language.getLanguageId() + " as display_name from " + catalogdb + ".stickers where site_id = " + escape.cote(rscat.value("site_id")));

					if(rs != null)
					{

						while(rs.next())
						{

							priceDifferencePercentage = 0.00;

							product = com.etn.asimina.util.PortalHelper.toJSONObject(rs,true);
							product.put("productUUID",rs.value("product_uuid"));
							product.put("name",rs.value(langColPrefix + "name"));
							product.put("summary",rs.value(langColPrefix + "summary"));
							product.put("features",rs.value(langColPrefix + "features"));
							product.put("listingTab",rs.value(langColPrefix + "listing_tab"));
							product.put("metaKeywords",rs.value(langColPrefix + "meta_keywords"));
							product.put("metaDescription",rs.value(langColPrefix + "meta_description"));
							product.put("currency",rs.value(langColPrefix + "currency"));
							product.put("currencyFreq",rs.value(langColPrefix + "currency_freq"));
							product.put("pricesent",rs.value(langColPrefix + "pricesent"));
							productId = parseNull(rs.value("id"));

							java.util.Map<String, String> productVariant = getMinPriceVariant(Etn, taxpercentage, productId, catalogdb, client_id);

							String minPrice = formatPrice(priceformatter, roundto, showDecimal, parseNull(productVariant.get("promoPrice")));
							String originalPrice = formatPrice(priceformatter, roundto, showDecimal, parseNull(productVariant.get("originalPrice")));
							String minPriceUnformated = formatPrice(priceformatter, roundto, showDecimal, parseNull(productVariant.get("promoPrice")), true);
							String originalPriceUnformated = formatPrice(priceformatter, roundto, showDecimal, parseNull(productVariant.get("originalPrice")), true);

							if(minPrice.equals(originalPrice)) minPrice = originalPrice;

							String minDlPrice = minPriceUnformated;//minPrice;
							if(minPrice.equals("0")) {

								minPrice = libelle_msg(Etn, request, "Gratuit");
							}
							else if(minPrice.length() > 0) {
								minPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"),  Integer.parseInt(language.getLanguageId()), minPrice, defaultcurrencylabel);
							}

							if(originalPrice.equals("0")){
								originalPrice = libelle_msg(Etn, request, "Gratuit");

							} else if(originalPrice.length() > 0) {
								originalPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"),  Integer.parseInt(language.getLanguageId()), originalPrice, defaultcurrencylabel);
							}

							promotionObject = getPromotionObject(Etn, taxpercentage, productId, catalogdb, true, request, prefix, parseNull(productVariant.get("id")));

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
							product.put("inStock", minPriceVariantStock > 0);
							product.put("promotionPercentage", priceDifferencePercentage);
							product.put("promotion", promotionObject);
							product.put("minPriceVariantId", parseNull(productVariant.get("id")));

							String variantName = "";
							if(parseNull(productVariant.get("id")).length() > 0)
							{
								Set rsPV = Etn.execute("select * from "+catalogdb+".product_variant_details where langue_id= "+escape.cote(""+language.getLanguageId())+" and product_variant_id ="+escape.cote(parseNull(productVariant.get("id"))));
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
								product.put("productImpressionCategory", "offer");
							}
							else
							{

								extraProductImpressionAttrs.put("pi_in_stock", (minPriceVariantStock>0)?"yes":"no");
								extraProductImpressionAttrs.put("pi_stock", minPriceVariantStock);
								String _productCategory = "product";
								if(parseNull(rs.value("device_type")).length() > 0) _productCategory = parseNull(rs.value("device_type"));
								product.put("productImpressionCategory", _productCategory);
								product.put("comeswith", getComewith(Etn, request, parseNull(productVariant.get("id")), prefix, language.getLanguageId(), "", false));
							}

							product.put("extraImpressionAttrs", extraProductImpressionAttrs);
							product.put("isVariantPricesDiffer",productVariant.get("isVariantPricesDiffer"));
							products.put(product);
						}
					}

					while(stickerRs.next()){

						stickers.put(parseNull(stickerRs.value("sname")), parseNull(stickerRs.value("display_name")));
					}

					results.put("minPriceUnformatted",productUpdatedMinPrice);
					results.put("maxPriceUnformatted",productUpdatedMaxPrice);

					results.put("products", products);
					results.put("stickers", stickers);
					
					JSONObject countrySpecificDLAttrs = new JSONObject();
					countrySpecificDLAttrs.put("dimensionX", "");
					countrySpecificDLAttrs.put("dimensionXX", "data-extra_pi_in_stock");
					countrySpecificDLAttrs.put("metricXX", "data-extra_pi_stock");

					results.put("extra_product_impression_attrs", countrySpecificDLAttrs);
					
					results.put("error",false);
					results.put("status",0);

					out.write(results.toString());
				}
				else
				{
					out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_CATALOG_ID + ",\"message\":\"" + ErrorMessages.INVALID_CATALOG_ID + "\"}");
				}
			}
		}
		else
		{
			out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_MENU_ID + ",\"message\":\"" + ErrorMessages.INVALID_MENU_ID + "\"}");
		}
	}
	catch(Exception ex)
	{
		ex.printStackTrace();
		JSONObject error = new JSONObject();
		error.put("error",true);
		error.put("status",ErrorTypes.SOME_EXCEPTION);
		error.put("message",ex.toString());
		error.put("stackTrace",getStackTrace(ex));
		out.write(error.toString());
	}
%>

