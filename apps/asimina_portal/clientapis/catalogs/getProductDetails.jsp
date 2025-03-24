<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.beans.Contexte, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.*, com.etn.asimina.beans.*"%>
<%@ include file="../../lib_msg.jsp"%>
<%@ include file="../../cart/commonprice.jsp"%>
<%@ include file="../../cart/common.jsp"%>
<%@ include file="../../common.jsp"%>
<%@ include file="../../common2.jsp"%>
<%@ include file="../../cart/priceformatter.jsp"%>
<%@ include file="../errorTypes.jsp"%>
<%!
    public Map<String, String> getMinimumMarketingDeliveryFee(Contexte Etn, javax.servlet.http.HttpServletRequest request, String siteId, String variant_id, String catalogdb)
	{
        boolean logged = com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request);

        Set rsDeliveryVariant = Etn.execute("select pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id where pv.id="+escape.cote(variant_id));
        rsDeliveryVariant.next();

        String deliveryFeeQuery = "select d.fee  from "+catalogdb+".deliveryfees d inner join "+catalogdb+".deliveryfees_rules dr on d.id=dr.deliveryfee_id";
        deliveryFeeQuery += " and ((dr.applied_to_type='product' and dr.applied_to_value="+escape.cote(rsDeliveryVariant.value("product_id"))+")";
        deliveryFeeQuery += " or (dr.applied_to_type='catalog' and dr.applied_to_value="+escape.cote(rsDeliveryVariant.value("catalog_id"))+")";
        deliveryFeeQuery += " or (dr.applied_to_type='sku' and dr.applied_to_value="+escape.cote(rsDeliveryVariant.value("sku"))+")";
        deliveryFeeQuery += " or (dr.applied_to_type='product_type' and dr.applied_to_value="+escape.cote(rsDeliveryVariant.value("catalog_type"))+")";
        deliveryFeeQuery += " or (dr.applied_to_type='manufacturer' and dr.applied_to_value="+escape.cote(rsDeliveryVariant.value("brand_name"))+")";
        deliveryFeeQuery += " or (dr.applied_to_type='tag' and dr.applied_to_value=" + escape.cote(rsDeliveryVariant.value("tag_id")) + ") or dr.applied_to_type='all')";
        deliveryFeeQuery += " where d.site_id = "+escape.cote(siteId);
		deliveryFeeQuery += " and coalesce(d.fee,'') <> '' ";

		if(logged == false) deliveryFeeQuery += " and d.visible_to <> 'logged' ";

		deliveryFeeQuery += " group by dr.deliveryfee_id order by CAST(d.fee AS INTEGER)";

        Set rsDeliveryFee  =  Etn.execute(deliveryFeeQuery);
        String flag = "0";
        int counter = 0;

		Map<String, String> resp = new HashMap<String, String>();
		while(rsDeliveryFee.next())
		{
			if(counter == 0)
			{
				resp.put("fee", parseNull(rsDeliveryFee.value("fee")));
			}

			if(parseNullDouble(rsDeliveryFee.value("fee")) > 0)
			{
				flag = "1";
				break;
			}
			counter++;
		}
		resp.put("flag", flag);
        return resp;
    }

    public Map<String, String>  getMinimumDeliveryMethodFee(Contexte Etn, String siteId, String catalogdb)
	{

        Set rsDeliveryMethods = Etn.execute("select method, subType, min(price+0.0) as price, displayName, count(price) as price_count from "+catalogdb+".delivery_methods where site_id = " + escape.cote(siteId)+ " and enable=1 group by method order by price;");
        String flag = "0";
        int counter = 0;
		Map<String, String> resp = new HashMap<String, String>();
		while(rsDeliveryMethods.next())
		{
			if(counter == 0)
			{
				resp.put("fee", parseNull(rsDeliveryMethods.value("price")));
			}
			if(parseNullDouble(rsDeliveryMethods.value("price")) > 0)
			{
				flag = "1";
				break;
			}
			counter++;
		}
		resp.put("flag", flag);
        return resp;
    }
	
	String isShowPrice(Contexte Etn, String variantId, String catalogdb)
	{

        String isShowPrice = "";
        Set rs = Etn.execute("select is_show_price from " + catalogdb + ".product_variants where id = " + escape.cote(variantId));

        if(rs != null && rs.next()){

            isShowPrice = parseNull(rs.value("is_show_price"));
        }

        return isShowPrice;
    }
	
	String getVariantStickerColor(Contexte Etn, String siteId, String sticker, String catalogdb)
	{

        Set rs = Etn.execute("select color from " + catalogdb + ".stickers where site_id = " + escape.cote(siteId) + " and sname = " + escape.cote(sticker));

        if(rs.next()) {

            return parseNull(rs.value("color"));
        }

        return "";
    }
	
	public String getOfferJSON(Contexte Etn,HttpServletRequest request,Set rscat,Set rsProduct,String prefix,String catalogdb,String langue_id,String productUUID,String client_id,String catalogType,String menuPath,String menuid) throws Exception
	{
		String langColPrefix = "lang_" + langue_id + "_";
		String langJSONPrefix = "lang" + langue_id;

		JSONArray variants = new JSONArray();
		JSONObject langRef = new JSONObject();
		//added additional check of catalog as on dev there were two products with the same uuid. 		
		Set rs = Etn.execute("select p."+langColPrefix+"name as product_name, p.brand_name, p.product_type, p.product_uuid, pv.uuid variant_uuid,pv.*, pvd.name as variant_name from " + catalogdb + ".products p, " + catalogdb + ".product_variants pv, " + catalogdb + ".product_variant_details pvd where pvd.langue_id = "+escape.cote(langue_id)+" and pvd.product_variant_id = pv.id and p.id = pv.product_id and p.product_uuid = " + escape.cote(productUUID) + " and p.catalog_id = " + escape.cote(rscat.value("id")) + "and pv.is_active = 1 order by pv.is_default desc");


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
		String defaultcurrencylabel = libelle_msg(Etn, request, defaultcurrency);
		String showDecimal = "0";
		String currencyPosition = parseNull(rsshop.value(prefix + "currency_position"));		

		if(parseNull(rsshop.value(prefix+"show_decimals")).length() > 0)
			showDecimal = parseNull(rsshop.value(prefix+"show_decimals"));

		String priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
		String roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
		String priceDisplayLabel = parseNull(rsshop.value(prefix+"no_price_display_label"));

		Set stickerRs = Etn.execute("select sname, display_name_" + langue_id + " as display_name from " + catalogdb + ".stickers where site_id = " + escape.cote(rscat.value("site_id")));

		JSONObject results = new JSONObject();
		String productType = "";
		if(rs != null)
		{
			while(rs.next())
			{
				JSONObject variant = toJSONObject(rs);
				productType = parseNull(rs.value("product_type"));
				String variantId = parseNull(rs.value("id"));
				String sticker = parseNull(rs.value("sticker"));

				String minPrice = formatPrice(priceformatter, roundto, showDecimal, getPrice(Etn, variantId, taxpercentage, 1, true));
				String minDlPrice = formatPrice(priceformatter, roundto, showDecimal, getPrice(Etn, variantId, taxpercentage, 1, true), true);
				String originalPrice = formatPrice(priceformatter, roundto, showDecimal, getPrice(Etn, variantId, taxpercentage, 1, false));
				
				String newPriceWithCurrency = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), minPrice, defaultcurrencylabel);
				String newPriceUnformatted = formatPrice(priceformatter, roundto, showDecimal, getPrice(Etn, variantId, taxpercentage, 1, true), true);
				String oldPriceWithCurrency = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), originalPrice, defaultcurrencylabel);
				String oldPriceUnformatted = formatPrice(priceformatter, roundto, showDecimal, getPrice(Etn, variantId, taxpercentage, 1, false), true);

				if(minPrice.equals("0")) {

					minPrice = libelle_msg(Etn, request, "Gratuit");
					newPriceWithCurrency = minPrice;
				}
				else if(minPrice.equals(originalPrice)) minPrice = originalPrice;

				if(originalPrice.equals("0")){

					originalPrice = libelle_msg(Etn, request, "Gratuit");
					oldPriceWithCurrency = originalPrice;
				}

				JSONObject promotionObject = getPromotion(Etn, request, variantId, prefix);

				String stickerColor = getVariantStickerColor(Etn, rscat.value("site_id"), sticker, catalogdb);

				variant.put("variantUUID",parseNull(rs.value("variant_uuid")));
				variant.put("variantStickerColor", stickerColor);
				variant.put("minPriceFrom",minPrice);
				variant.put("minDlPrice",minDlPrice);
				variant.put("originalPriceFrom",originalPrice);
				
				JSONObject jNewPrice = new JSONObject();
				variant.put("newPrice", jNewPrice);
				jNewPrice.put("price", minPrice);
				jNewPrice.put("displayPrice", newPriceWithCurrency);
				jNewPrice.put("priceUnformatted", newPriceUnformatted);

				JSONObject jOldPrice = new JSONObject();
				variant.put("oldPrice", jOldPrice);
				jOldPrice.put("price", originalPrice);
				jOldPrice.put("displayPrice", oldPriceWithCurrency);
				jOldPrice.put("priceUnformatted", oldPriceUnformatted);
				
				variant.put("isShowPrice", isShowPrice(Etn, variantId, catalogdb));
				variant.put("additionalFee", getAdditionalFee(Etn, request, variantId, prefix, getPrice(Etn, variantId, taxpercentage, 1, false),1));
				variant.put("comewith", getComewith(Etn, request, variantId, prefix, langue_id, "", false, menuid));
				variant.put("promotion", promotionObject);
				variant.put("tax_exclusive", taxpercentage.tax_exclusive);
				variant.put("is_default", parseNull(rs.value("is_default")).equals("1"));

				if(promotionObject.length() > 0)
					results.put("flashSaleQuantity_"+variantId, libelle_msg(Etn, request, "Plus que <qty> articles").replace("<qty>",promotionObject.getString("flash_sale_quantity")));

				JSONObject extraProductImpressionAttrs = new JSONObject();
				extraProductImpressionAttrs.put("pi_in_stock", "yes");
				extraProductImpressionAttrs.put("pi_stock", "");
				variant.put("productImpressionCategory", "offer");


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
		langRef.put("no_price_label", priceDisplayLabel);
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
		results.put("currencyPosition",currencyPosition);
		results.put("currency",defaultcurrency);
		results.put("currencylabel",defaultcurrencylabel);
		results.put("showAmountWithTax",showamountwithtax);
		results.put("noOfDecimals",showDecimal);
		results.put("roundTo",roundto);
		results.put("priceFormatter",priceformatter);
		results.put("productType", productType);
		results.put("langJSONPrefix", langJSONPrefix);

		JSONObject countrySpecificDLAttrs = new JSONObject();
		countrySpecificDLAttrs.put("dimensionX", "");
		countrySpecificDLAttrs.put("dimensionXX", "data-extra_pi_in_stock");
		countrySpecificDLAttrs.put("metricXX", "data-extra_pi_stock");

		results.put("extra_product_impression_attrs", countrySpecificDLAttrs);
		return results.toString();
	}
	
	public String getProductJSON(Contexte Etn,HttpServletRequest request,Set rscat,Set rsProduct,String prefix,String catalogdb,String langue_id,String productUUID,String client_id,String catalogType,String menuPath,String menuid) throws Exception
	{
		boolean pricetaxincluded = ("1".equals(parseNull(rscat.value("price_tax_included")))?true:false);
		boolean showamountwithtax = ("1".equals(parseNull(rscat.value("show_amount_tax_included")))?true:false);
		TaxPercentage taxpercentage = new TaxPercentage();
		taxpercentage.tax = parseNullDouble(rscat.value("tax_percentage"));
		taxpercentage.input_with_tax = pricetaxincluded;
		taxpercentage.output_with_tax = showamountwithtax;
		taxpercentage.tax_exclusive = !showamountwithtax;

		Set rsshop = Etn.execute("select * from "+catalogdb+".shop_parameters where site_id = " + escape.cote(rscat.value("site_id")) );
		rsshop.next();
		String priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
		String deliveroutsidedepartment = parseNull(rsshop.value("deliver_outside_dep"));//changed
		String currencyPosition = parseNull(rsshop.value(prefix + "currency_position"));

		String roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
		String showdecimals = parseNull(rsshop.value(prefix + "show_decimals"));
		String defaultcurrency = parseNull(rsshop.value(prefix + "currency"));
		String defaultcurrencylabel = libelle_msg(Etn, request, parseNull(rsshop.value(prefix + "currency")));

		ProductImageHelper imageHelper = new ProductImageHelper(rsProduct.value("id"));

		Set rsVariants = Etn.execute("select p.device_type as deviceType, p.product_uuid as productUuid, p."+prefix+"name as productName, p.brand_name as productBrand, pv.*, pvd.* from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id = pv.product_id inner join "+catalogdb+".product_variant_details pvd on pv.id = pvd.product_variant_id and pvd.langue_id="+escape.cote(langue_id)+" where pv.is_active=1 and p.product_uuid = "+escape.cote(productUUID)+" order by pv.is_default desc");

		String minPrice = "";
		String maxPrice = "";
		String minOldPrice = "";
		String maxOldPrice = "";
		JSONObject priorityPromotion = new JSONObject();
		String prioritySticker = "";
		boolean priorityInStock = false;
		String priorityActionButtonDesktop = "";
		String priorityActionButtonMobile = "";
		String priorityIsShowPrice = "0";
		String stickerColor = "";
		String stickerDisplayName = "";
		JSONArray json = new JSONArray();

		String productCategory = "";
		String productUuid = "";
		String productName = "";
		String productBrand = "";
		while(rsVariants.next())
		{
			String minimumDeliveryFee = "";
			JSONObject jo = new JSONObject();

			productCategory = catalogType;
			if(parseNull(rsVariants.value("deviceType")).length() > 0) productCategory = parseNull(rsVariants.value("deviceType"));
			productUuid = rsVariants.value("productUuid");
			productName = rsVariants.value("productName");
			productBrand = rsVariants.value("productBrand");
			
			jo.put("variantUUID",parseNull(rsVariants.value("uuid")));
			jo.put("sku", parseNull(rsVariants.value("sku")));			
			jo.put("variantName", parseNull(rsVariants.value("name")));
			jo.put("id",rsVariants.value("id"));
			jo.put("is_default",rsVariants.value("is_default"));
			String sticker = rsVariants.value("sticker");
			jo.put("sticker",sticker);

			Set stickerRs = Etn.execute("select color, display_name_" + langue_id + " as display_name from " + catalogdb + ".stickers where site_id = " + escape.cote(rscat.value("site_id")) + " and sname = " + escape.cote(sticker));

			stickerColor = "";
			stickerDisplayName = "";

			if(stickerRs.next()){

				stickerColor = parseNull(stickerRs.value("color"));
				stickerDisplayName = parseNull(stickerRs.value("display_name"));
			}

			jo.put("stickerColor",stickerColor);
			jo.put("stickerDisplayName",stickerDisplayName);

			String is_show_price = rsVariants.value("is_show_price");
			//jo.put("is_show_price",is_show_price);
			jo.put("actionButtonDesktop",rsVariants.value("action_button_desktop"));
			jo.put("actionButtonMobile",rsVariants.value("action_button_mobile"));
			jo.put("actionButtonDesktopUrl",rsVariants.value("action_button_desktop_url"));
			jo.put("actionButtonMobileUrl",rsVariants.value("action_button_mobile_url"));

			if(rsVariants.value("is_default").equals("1") && rsVariants.value("action_button_desktop").length() > 0 || priorityActionButtonDesktop.equals("")) priorityActionButtonDesktop = rsVariants.value("action_button_desktop");
			if(rsVariants.value("is_default").equals("1") && rsVariants.value("action_button_mobile").length() > 0 || priorityActionButtonMobile.equals("")) priorityActionButtonMobile = rsVariants.value("action_button_mobile");

			boolean inStock = (parseNullInt(rsVariants.value("stock"))>0?true:false);
			if(inStock) priorityInStock = true;
			jo.put("inStock",inStock);


			if(rsshop.value("show_product_detail_delivery_fee").equals("1"))
			{
				if("1".equals(deliveroutsidedepartment))
				{
				   Map<String, String> marketingfeeData = getMinimumMarketingDeliveryFee(Etn, request, rscat.value("site_id"),parseNull(rsVariants.value("id")),catalogdb);
				   Map<String, String> methodFeeData = getMinimumDeliveryMethodFee(Etn, rscat.value("site_id"),catalogdb);

				   String  deliveryMethodFee = PortalHelper.parseNull(methodFeeData.get("fee"));
				   String  deliveryFee = PortalHelper.parseNull(marketingfeeData.get("fee"));

				   String  deliveryMethodFeeFlag = PortalHelper.parseNull(methodFeeData.get("flag"));
				   String  deliveryFeeFlag = PortalHelper.parseNull(marketingfeeData.get("flag"));

				   String fee  = "";
				   if(deliveryFee.equals("") && deliveryMethodFee.equals(""))
						fee = "";
					else if(deliveryFee.equals(""))
					   fee = deliveryMethodFee;
					else if (deliveryMethodFee.equals(""))
					   fee = deliveryFee;
					else if(PortalHelper.parseNullDouble(deliveryMethodFee) <= PortalHelper.parseNullDouble(deliveryFee))
					   fee = deliveryMethodFee;
					else
					   fee = deliveryFee;

					if(fee.equals(""))
						minimumDeliveryFee = libelle_msg(Etn, request, "Livraison gratuite"); //free deliver
					else if(deliveryFeeFlag.equals("0") && deliveryMethodFeeFlag.equals("0")) // means no delivery fee is greater than zero
						minimumDeliveryFee = libelle_msg(Etn, request, "Livraison gratuite");
					else
						minimumDeliveryFee = libelle_msg(Etn, request, "Frais de livraison à partir de")+" "+ PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, fee), defaultcurrencylabel);
				}
				else
				{
					Map<String, String> marketingfeeData = getMinimumMarketingDeliveryFee(Etn, request, rscat.value("site_id"),parseNull(rsVariants.value("id")),catalogdb);
					String  deliveryFee = PortalHelper.parseNull(marketingfeeData.get("fee"));
					String  deliveryFeeFlag = PortalHelper.parseNull(marketingfeeData.get("flag"));
					String fee  = "";

					if(deliveryFee.equals(""))
					{
						Map<String, String> methodFeeData = getMinimumDeliveryMethodFee(Etn, rscat.value("site_id"),catalogdb);
						String  deliveryMethodFee = methodFeeData.get("fee");
						String  deliveryMethodFeeFlag = methodFeeData.get("flag");
						if(deliveryMethodFee.equals(""))
							fee =  "";
						else{
							if(deliveryMethodFeeFlag.equals("0")) //means no fees is greater than zero
								fee = "";
							else
								fee = deliveryMethodFee;
						}
				   }else{
						if(deliveryFeeFlag.equals("0")) //means no fees is greater than zero
							fee = "";
						else
							fee = deliveryFee;
					}
					if(fee.equals(""))
						minimumDeliveryFee = libelle_msg(Etn, request, "Livraison gratuite");
					else
						minimumDeliveryFee = libelle_msg(Etn, request, "Frais de livraison à partir de")+" "+PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, fee), defaultcurrencylabel);
				}
				jo.put("deliveryFee",minimumDeliveryFee );
			}

			JSONObject extraProductImpressionAttrs = new JSONObject();
			extraProductImpressionAttrs.put("pi_in_stock", (inStock==true)?"yes":"no");
			extraProductImpressionAttrs.put("pi_stock", parseNullInt(rsVariants.value("stock")));

			jo.put("extraImpressionAttrs", extraProductImpressionAttrs);


			String newPrice = getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, client_id);
			String oldPrice = getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, false, client_id);
			String minSubsidizedPrice = null;
			String minSubsidizedUrl = null;
			String formattedNewPrice = "";
			String formattedNewPriceDisplay = "";
			String formattedOldPrice = "";
			String formattedOldPriceDisplay = "";
			String dataLayerNewPrice = "";
			String formattedSubsidizedPrice = "";
			String formattedSubsidizedPriceDisplay = "";

			JSONArray subsidies = getSubsidiesOnVariant(Etn, request, rsVariants.value("id"));
			for(int i=0; i<subsidies.length(); i++)
			{
				String subsidizedPrice = getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, client_id, subsidies.getJSONObject(i).optString("subsidy_id"));
				if(minSubsidizedPrice==null || parseNullDouble(subsidizedPrice)<parseNullDouble(minSubsidizedPrice))
				{
					minSubsidizedPrice = subsidizedPrice;
					minSubsidizedUrl = subsidies.getJSONObject(i).optString("url");
					//System.out.println(subsidies.getJSONObject(i).optString("url")+getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, client_id, subsidies.getJSONObject(i).optString("subsidy_id")));
				}

			}


			if(!is_show_price.equals("0"))
			{
				priorityIsShowPrice = is_show_price;
				dataLayerNewPrice = formatPrice(priceformatter, roundto, showdecimals, newPrice, true);
				formattedNewPrice = formatPrice(priceformatter, roundto, showdecimals, newPrice);
				formattedNewPriceDisplay = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formattedNewPrice, defaultcurrencylabel);
				formattedOldPrice = formatPrice(priceformatter, roundto, showdecimals, oldPrice);
				formattedOldPriceDisplay = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formattedOldPrice, defaultcurrencylabel);

				if(minSubsidizedPrice!=null) 
				{
					formattedSubsidizedPrice =  formatPrice(priceformatter, roundto, showdecimals, minSubsidizedPrice);
					formattedSubsidizedPriceDisplay =  PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formattedSubsidizedPrice, defaultcurrencylabel);
				}

				if("".equals(minPrice))
				{
					maxPrice = minPrice = newPrice;
					maxOldPrice = minOldPrice = oldPrice;
				}
				else
				{
					if(parseNullDouble(newPrice)<parseNullDouble(minPrice)) minPrice = newPrice;
					if(parseNullDouble(newPrice)>parseNullDouble(maxPrice)) maxPrice = newPrice;
					if(parseNullDouble(oldPrice)<parseNullDouble(minOldPrice)) minOldPrice = oldPrice;
					if(parseNullDouble(oldPrice)>parseNullDouble(maxOldPrice)) maxOldPrice = oldPrice;
				}
			}
			else
			{
				formattedNewPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
				formattedNewPriceDisplay = parseNull(rsshop.value(prefix + "no_price_display_label"));
				formattedOldPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
				formattedOldPriceDisplay = parseNull(rsshop.value(prefix + "no_price_display_label"));
				dataLayerNewPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
			}

			if(minSubsidizedPrice != null)
			{
				JSONObject jSubsidizedPrice = new JSONObject();
				jSubsidizedPrice.put("priceUnformatted", formatPrice(priceformatter, roundto, showdecimals, minSubsidizedPrice, true));
				jSubsidizedPrice.put("price",formattedSubsidizedPrice);
				jSubsidizedPrice.put("displayPrice",formattedSubsidizedPriceDisplay);
				jSubsidizedPrice.put("url",menuPath+minSubsidizedUrl);
				jo.put("subsidizedPrice", jSubsidizedPrice);
			}

			jo.put("dlNewPrice",dataLayerNewPrice);
		
			JSONObject jNewPrice = new JSONObject();
			jNewPrice.put("price",formattedNewPrice);
			jNewPrice.put("displayPrice",formattedNewPriceDisplay);
			jNewPrice.put("priceUnformatted", formatPrice(priceformatter, roundto, showdecimals, newPrice, true));
			jo.put("newPrice", jNewPrice);

			JSONObject jOldPrice = new JSONObject();
			jOldPrice.put("price",formattedOldPrice);
			jOldPrice.put("displayPrice",formattedOldPriceDisplay);
			jOldPrice.put("priceUnformatted", formatPrice(priceformatter, roundto, showdecimals, oldPrice, true));			
			jo.put("oldPrice", jOldPrice);

			JSONArray additionalFee = getAdditionalFee(Etn, request, rsVariants.value("id"), prefix, oldPrice,1);
			JSONObject promotion = getPromotion(Etn, request, rsVariants.value("id"), prefix);
			JSONArray comewith = getComewith(Etn, request, rsVariants.value("id"), prefix, langue_id, "", false, menuid);
			if(promotion.length()!=0)
			{
				promotion.put("discountAmount",formatPrice(priceformatter, roundto, showdecimals, (parseNullDouble(oldPrice)-parseNullDouble(newPrice))+""));
			}
			//additionalFee.put("title",libelle_msg(Etn, request, "Avance à payer :"));
			//additionalFee.put("content",libelle_msg(Etn, request, "Minimun 400 GNF à la commande selon le choix du paiement"));
			jo.put("additionalFee",additionalFee);
			jo.put("promotion",promotion);
			jo.put("comewith",comewith);
			//if(promotion!=null && promotion.has("flash_sale")) System.out.println(promotion.get("flash_sale")+">>>>>>>>>>>>>");

			if(promotion!=null && promotion.has("flash_sale")){
				if(!priorityPromotion.has("flash_sale")) priorityPromotion = promotion;
				else if(promotion.get("flash_sale").equals("time")) priorityPromotion = promotion;
				else if(promotion.get("flash_sale").equals("quantity") && !priorityPromotion.get("flash_sale").equals("time")) priorityPromotion = promotion;
				else if(!priorityPromotion.get("flash_sale").equals("time") && !priorityPromotion.get("flash_sale").equals("quantity")) priorityPromotion = promotion;
			}

			if(prioritySticker.equals("")||prioritySticker.equals("none")) prioritySticker = sticker;
			else if(sticker.equals("web")) prioritySticker = sticker;
			else if(!prioritySticker.equals("web") && sticker.equals("orange")) prioritySticker = sticker;
			else if(!prioritySticker.equals("web") && !prioritySticker.equals("orange")) prioritySticker = sticker;

			JSONArray attributes = new JSONArray();
			JSONObject attributesObject = new JSONObject();
			Set rsVariantAttributes = Etn.execute("select pvr.* from "+catalogdb
				+".product_variant_ref pvr inner join "+catalogdb
				+".catalog_attributes ca on ca.cat_attrib_id = pvr.cat_attrib_id where pvr.product_variant_id = "+escape.cote(rsVariants.value("id"))+" order by ca.sort_order");


			while(rsVariantAttributes.next()){
				JSONObject attribute = new JSONObject();
				attribute.put("attribute",rsVariantAttributes.value("cat_attrib_id"));
				attribute.put("value",rsVariantAttributes.value("catalog_attribute_value_id"));
				attributes.put(attribute);
				attributesObject.put("attribute_"+rsVariantAttributes.value("cat_attrib_id"),rsVariantAttributes.value("cat_attrib_id")+"_"+rsVariantAttributes.value("catalog_attribute_value_id"));
	//                if(rsVariantAttributes.value("value_type").equals("color")){
	//                    jo.put("color",rsVariantAttributes.value("id"));
	//                    jo.put("colorName",rsVariantAttributes.value("attribute_value"));
	//                }
	//                else{
	//                    jo.put("storageCapacity",rsVariantAttributes.value("id"));
	//                }
			}
			jo.put("attributes", attributes);
			jo.put("attributesObject", attributesObject);
			/*JSONArray images = new JSONArray();
			String previousId = "";
			Set rsVariantImages = Etn.execute("select pvr.* from "+catalogdb+".product_variant_resources pvr inner join "+catalogdb+".product_variants pv on pvr.product_variant_id = pv.id where (pv.is_default=0 and product_variant_id = "+escape.cote(rsVariants.value("id"))+" or pv.is_default=1) and type='image' and langue_id="+escape.cote(langue_id)+" order by pv.is_default, pvr.sort_order;");
			//System.out.println("select pvr.* from "+catalogdb+".product_variant_resources pvr inner join "+catalogdb+".product_variants pv on pvr.product_variant_id = pv.id where (pv.is_default=0 and product_variant_id = "+escape.cote(rsVariants.value("id"))+" or pv.is_default=1) and type='image' and langue_id="+escape.cote(langue_id)+" order by pv.is_default, pvr.sort_order;");
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

		Set priorityStickerRs = Etn.execute("select color, display_name_" + langue_id + " as display_name from " + catalogdb + ".stickers where site_id = " + escape.cote(rscat.value("site_id")) + " and sname = " + escape.cote(prioritySticker));

		String priorityStickerColor = "";
		String priorityStickerDisplayName = "";

		if(priorityStickerRs.next()){

			priorityStickerColor = parseNull(priorityStickerRs.value("color"));
			priorityStickerDisplayName = parseNull(priorityStickerRs.value("display_name"));
		}

		JSONObject productDetails = new JSONObject();		
		productDetails.put("deliverOutsideDepartment", "1".equals(deliveroutsidedepartment));
		productDetails.put("category", productCategory);
		productDetails.put("uuid", productUuid);			
		productDetails.put("name", productName);
		productDetails.put("brand", productBrand);

		productDetails.put("currency",defaultcurrency);		
		productDetails.put("currencylabel",defaultcurrencylabel);		
		productDetails.put("roundTo",roundto);
		productDetails.put("priceFormatter",priceformatter);
		productDetails.put("noOfDecimals",showdecimals);
		productDetails.put("showAmountWithTax",showamountwithtax);
		productDetails.put("defaultSticker",prioritySticker);
		productDetails.put("defaultStickerColor",priorityStickerColor);
		productDetails.put("defaultStickerDisplayName",priorityStickerDisplayName);
		productDetails.put("inStock",priorityInStock);
		productDetails.put("defaultActionButtonDesktop",priorityActionButtonDesktop);
		productDetails.put("defaultActionButtonMobile",priorityActionButtonMobile);		
		productDetails.put("defaultPromotion",priorityPromotion);		
		productDetails.put("currencyPosition",currencyPosition);		

		String newPriceRange = formatPrice(priceformatter, roundto, showdecimals, minPrice);
		if(!minPrice.equals(maxPrice)) newPriceRange+=" - "+formatPrice(priceformatter, roundto, showdecimals, maxPrice);

		String oldPriceRange = formatPrice(priceformatter, roundto, showdecimals, minOldPrice);
		if(!minOldPrice.equals(maxOldPrice)) oldPriceRange+=" - "+formatPrice(priceformatter, roundto, showdecimals, maxOldPrice);

		String formattedNewPrice = "";
		String formattedOldPrice = "";

		if(!priorityIsShowPrice.equals("0")){
			formattedOldPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), oldPriceRange, defaultcurrencylabel);
			formattedNewPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), newPriceRange, defaultcurrencylabel);
		}
		else{
				formattedNewPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
				formattedOldPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
		}
								
		JSONObject jNewPrice = new JSONObject();
		productDetails.put("newPrice", jNewPrice);
		jNewPrice.put("displayMinPrice", PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, minPrice), defaultcurrencylabel));
		jNewPrice.put("minPrice", formatPrice(priceformatter, roundto, showdecimals, minPrice));
		jNewPrice.put("minPriceUnformatted", formatPrice(priceformatter, roundto, showdecimals, minPrice, true));
		jNewPrice.put("maxPrice", formatPrice(priceformatter, roundto, showdecimals, maxPrice));
		jNewPrice.put("displayMaxPrice", PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, maxPrice), defaultcurrencylabel));
		jNewPrice.put("maxPriceUnformatted", formatPrice(priceformatter, roundto, showdecimals, maxPrice, true));

		JSONObject jOldPrice = new JSONObject();
		productDetails.put("oldPrice", jOldPrice);
		jOldPrice.put("minPriceUnformatted", formatPrice(priceformatter, roundto, showdecimals, minOldPrice, true));
		jOldPrice.put("displayMinPrice", PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, minOldPrice), defaultcurrencylabel));
		jOldPrice.put("minPrice", formatPrice(priceformatter, roundto, showdecimals, minOldPrice));
		jOldPrice.put("maxPriceUnformatted", formatPrice(priceformatter, roundto, showdecimals, maxOldPrice, true));
		jOldPrice.put("maxPrice", formatPrice(priceformatter, roundto, showdecimals, maxOldPrice));
		jOldPrice.put("displayMaxPrice", PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, maxOldPrice), defaultcurrencylabel));

		productDetails.put("variants", json);

		JSONObject countrySpecificDLAttrs = new JSONObject();
		countrySpecificDLAttrs.put("dimensionX", "");
		countrySpecificDLAttrs.put("dimensionXX", "data-extra_pi_in_stock");
		countrySpecificDLAttrs.put("metricXX", "data-extra_pi_stock");

		JSONObject jTranslations = new JSONObject();
		jTranslations.put("promotion", libelle_msg(Etn, request, "Promotion"));
		jTranslations.put("flash_sale", libelle_msg(Etn, request, "Vente flash"));
		jTranslations.put("out_of_stock", libelle_msg(Etn, request, "Indisponible"));
		jTranslations.put("promo", libelle_msg(Etn, request, "Promo"));
		jTranslations.put("start_date", libelle_msg(Etn, request, "à partir du <start_date>"));
		jTranslations.put("end_date", libelle_msg(Etn, request, "jusqu'au <end_date>"));
		jTranslations.put("include", libelle_msg(Etn, request, "Inclus"));		
		jTranslations.put("starting_from",libelle_msg(Etn, request, "À partir de"));

		JSONObject results = new JSONObject();
		results.put("extra_product_impression_attrs", countrySpecificDLAttrs);
		results.put("product", productDetails);
		results.put("translations", jTranslations);
		results.put("error",false);
		results.put("status",0);
		return results.toString();
		
	}

%>
<%
	try
	{
		String productUUID = parseNull(request.getParameter("productId"));
		String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
		String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
		String muid = parseNull(request.getParameter("muid"));
		String menuid = "";
		Set rsMenu = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(muid));
		if(muid.length() > 0 && rsMenu !=null && rsMenu.next())
		{
			String lang = rsMenu.value("lang");
			Language language = LanguageFactory.instance.getLanguage(lang);
			if(language == null)
			{
				out.write("{\"error\":true,\"status\":ErrorTypes.INVALID_LANG,\"message\":\"" + ErrorMessages.INVALID_LANG + "\"}");
			}
			else
			{
				set_lang(lang, request, Etn);
				menuid = parseNull(rsMenu.value("id"));
				String menuPath = getMenuPath(Etn, menuid);

				String langue_id = language.getLanguageId();
				
				String prefix = getProductColumnsPrefix(Etn, request, lang);
				System.out.println("select * from "+catalogdb+".products where product_uuid="+ escape.cote(productUUID));
				Set rsProduct = Etn.execute("select * from "+catalogdb+".products where product_uuid="+ escape.cote(productUUID));
				if(productUUID.length() > 0 && rsProduct != null && rsProduct.next())
				{
					Set rscat = Etn.execute("select * from "+catalogdb+".catalogs where id = " + escape.cote(rsProduct.value("catalog_id")));
					if( rscat != null && rscat.next())
					{

						String catalogType = rscat.value("catalog_type");
						if("offer".equals(catalogType))
						{
							out.write(getOfferJSON(Etn,request,rscat,rsProduct,prefix,catalogdb,langue_id,productUUID,client_id,catalogType,menuPath,menuid));
						}
						else
						{	
							out.write(getProductJSON(Etn,request,rscat,rsProduct,prefix,catalogdb,langue_id,productUUID,client_id,catalogType,menuPath,menuid));
						}		
						
					}
					else
					{
						out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_CATALOG_ID + ",\"message\":\"" + ErrorTypes.INVALID_CATALOG_ID + "\"}");
					}
				}
				else
				{
					out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_PRODUCT_ID + ",\"message\":\"" + ErrorMessages.INVALID_PRODUCT_ID + "\"}");
				}
			}
		}
		else
		{
			out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_MENU_ID + ",\"message\":\"" + ErrorMessages.INVALID_MENU_ID +"\"}");
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