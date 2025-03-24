<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.Contexte, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*, com.etn.util.Base64"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>
<%@ page import="com.etn.asimina.beans.*"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.ProductImageHelper"%>
<%@ page import="java.text.DecimalFormat"%>
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

    String isShowPrice(Contexte Etn, String variantId, String catalogdb){

        String isShowPrice = "";
        Set rs = Etn.execute("select is_show_price from " + catalogdb + ".product_variants where id = " + escape.cote(variantId));

        if(rs != null && rs.next()){

            isShowPrice = parseNull(rs.value("is_show_price"));
        }

        return isShowPrice;
    }

    String getVariantStickerColor(Contexte Etn, String siteId, String sticker, String catalogdb){

        Set rs = Etn.execute("select color from " + catalogdb + ".stickers where site_id = " + escape.cote(siteId) + " and sname = " + escape.cote(sticker));

        if(rs.next()) {

            return parseNull(rs.value("color"));
        }

        return "";
    }
%>

<%
    String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
    String lang = parseNull(request.getParameter("lang"));
    String catalogId = parseNull(request.getParameter("catalog_id"));
    String productId = parseNull(request.getParameter("product_id"));
    String prefix = getProductColumnsPrefix(Etn, request, lang);
    String menu_uuid = parseNull(request.getParameter("menu_uuid"));
    String menuid = "";
    Set rsMenu = Etn.execute("select id from site_menus where menu_uuid = " + escape.cote(menu_uuid));
    if(rsMenu.next())
    {
        menuid = parseNull(rsMenu.value(0));
    }

    set_lang(lang, request, Etn);

    Language language = LanguageFactory.instance.getLanguage(lang);
    if(language == null){
        out.write("<div style='color:red;font-weight:bold'>Invalid language provided</div>");
        return;
    }

    String langColPrefix = "lang_" + language.getLanguageId() + "_";
    String langJSONPrefix = "lang" + language.getLanguageId();

    JSONArray variants = new JSONArray();
    JSONObject langRef = new JSONObject();

    Set rs = Etn.execute("select p."+langColPrefix+"name as product_name, p.brand_name, p.product_type, p.product_uuid, pv.*, pvd.name as variant_name from " + catalogdb + ".products p, " + catalogdb + ".product_variants pv, " + catalogdb + ".product_variant_details pvd where pvd.langue_id = "+escape.cote(language.getLanguageId()+"")+" and pvd.product_variant_id = pv.id and p.id = pv.product_id and p.id = " + escape.cote(productId) + " and pv.is_active = 1 order by pv.is_default desc");


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

    if(parseNull(rsshop.value(prefix+"show_decimals")).length() > 0)
        showDecimal = parseNull(rsshop.value(prefix+"show_decimals"));

    String priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
    String roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
    String priceDisplayLabel = parseNull(rsshop.value(prefix+"no_price_display_label"));

    Set stickerRs = Etn.execute("select sname, display_name_" + language.getLanguageId() + " as display_name from " + catalogdb + ".stickers where site_id = " + escape.cote(rscat.value("site_id")));

	JSONObject results = new JSONObject();

    if(rs != null)
	{
        while(rs.next())
		{
            JSONObject variant = toJSONObject(rs);
            String variantId = parseNull(rs.value("id"));
            String sticker = parseNull(rs.value("sticker"));

            _currencyfreq = libelle_msg(Etn, request, parseNull(rs.value("currency_frequency")));
            currency_frequency = getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq);

            String minPrice = formatPrice(priceformatter, roundto, showDecimal, getPrice(Etn, variantId, taxpercentage, 1, true));
            String minDlPrice = formatPrice(priceformatter, roundto, showDecimal, getPrice(Etn, variantId, taxpercentage, 1, true), true);
            String originalPrice = formatPrice(priceformatter, roundto, showDecimal, getPrice(Etn, variantId, taxpercentage, 1, false));

            if(minPrice.equals("0")) {

                minPrice = libelle_msg(Etn, request, "Gratuit");
            }
            else if(minPrice.equals(originalPrice)) minPrice = originalPrice;

            if(originalPrice.equals("0")){

                originalPrice = libelle_msg(Etn, request, "Gratuit");
            }

            JSONObject promotionObject = getPromotion(Etn, request, variantId, prefix);

            String stickerColor = getVariantStickerColor(Etn, rscat.value("site_id"), sticker, catalogdb);

            variant.put("variantStickerColor", stickerColor);
            variant.put("minPriceFrom",minPrice);
            variant.put("minDlPrice",minDlPrice);
            variant.put("originalPriceFrom",originalPrice);
            variant.put("currency_frequency",currency_frequency);
            variant.put("currencyPosition", rsshop.value(langColPrefix+"currency_position"));
            variant.put("isShowPrice", isShowPrice(Etn, variantId, catalogdb));
            variant.put("additionalFee", getAdditionalFee(Etn, request, variantId, prefix, getPrice(Etn, variantId, taxpercentage, 1, false),1));
            variant.put("comewith", getComewith(Etn, request, variantId, prefix, language.getLanguageId(), "", false, menuid));
            variant.put("promotion", promotionObject);
            variant.put("tax_exclusive", taxpercentage.tax_exclusive);
            variant.put("is_default", parseNull(rs.value("is_default")).equals("1"));

            if(promotionObject.length() > 0)
                results.put("flashSaleQuantity_"+variantId, libelle_msg(Etn, request, "Plus que <qty> articles").replace("<qty>",promotionObject.getString("flash_sale_quantity")));

			JSONObject extraProductImpressionAttrs = new JSONObject();
			//this jsp is just for offers
//			if(catalogType.equalsIgnoreCase("offer"))
	//		{
				extraProductImpressionAttrs.put("pi_in_stock", "yes");
				extraProductImpressionAttrs.put("pi_stock", "");
				extraProductImpressionAttrs.put("pi_currency", defaultcurrency);
				variant.put("productImpressionCategory", "offer");
/*			}
			else
			{
				int variantStock = parseNullInt(rs.value("stock"));

				extraProductImpressionAttrs.put("pi_in_stock", (variantStock>0)?"yes":"no");
				extraProductImpressionAttrs.put("pi_stock", variantStock);
				extraProductImpressionAttrs.put("pi_currency", defaultcurrency);
				String _productCategory = "product";
				if(parseNull(rs.value("device_type")).length() > 0) _productCategory = parseNull(rs.value("device_type"));
				variant.put("productImpressionCategory", _productCategory);
			}*/

			variant.put("extraImpressionAttrs", extraProductImpressionAttrs);
            variants.put(variant);
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
    langRef.put("promo", libelle_msg(Etn, request, "Promo"));
    langRef.put("start_date", libelle_msg(Etn, request, "à partir du <start_date>"));
    langRef.put("end_date", libelle_msg(Etn, request, "jusqu'au <end_date>"));
    langRef.put("include", libelle_msg(Etn, request, "Inclus"));
    langRef.put("offer", libelle_msg(Etn, request, "Offert"));

    while(stickerRs.next()){

        langRef.put(parseNull(stickerRs.value("sname")), parseNull(stickerRs.value("display_name")));
    }

	results.put("variants", variants);
	results.put("translations", langRef);
    results.put("defaultcurrency",defaultcurrency);
	results.put("langJSONPrefix", langJSONPrefix);

	JSONObject countrySpecificDLAttrs = new JSONObject();
    countrySpecificDLAttrs.put("dimensionX", "");
    countrySpecificDLAttrs.put("dimensionXX", "data-extra_pi_in_stock");
    countrySpecificDLAttrs.put("metricXX", "data-extra_pi_stock");

	results.put("extra_product_impression_attrs", countrySpecificDLAttrs);

    out.write(results.toString());
%>

