<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.beans.Contexte, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.*, com.etn.asimina.beans.*"%>
<%@ include file="../lib_msg.jsp"%>
<%@ include file="../cart/commonprice.jsp"%>
<%@ include file="../cart/common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../cart/priceformatter.jsp"%>
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

    public Map<String, String>  getMinimumDeliveryMethodFee(Contexte Etn, String siteId, String catalogdb){

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

%>
<%
	String product_uuid = parseNull(request.getParameter("product_uuid"));
	String lang = parseNull(request.getParameter("lang"));
	String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
	String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
	String menu_uuid = parseNull(request.getParameter("menu_uuid"));
        String menuid = "";
        Set rsMenu = Etn.execute("select id from site_menus where menu_uuid = " + escape.cote(menu_uuid));
	if(rsMenu.next())
	{
            menuid = parseNull(rsMenu.value(0));
	}
        String menuPath = getMenuPath(Etn, menuid);

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
    String deliveroutsidedepartment = "";
    String minimumDeliveryFee = "";

	Set rs = Etn.execute("select * from "+catalogdb+".products where product_uuid="+ escape.cote(product_uuid));
	rs.next();

	Set rscat = Etn.execute("select * from "+catalogdb+".catalogs where id = " + escape.cote(rs.value("catalog_id")));
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
	priceformatter = parseNull(rsshop.value(prefix + "price_formatter"));
    deliveroutsidedepartment = parseNull(rsshop.value("deliver_outside_dep"));//changed

	roundto = parseNull(rsshop.value(prefix + "round_to_decimals"));
	showdecimals = parseNull(rsshop.value(prefix + "show_decimals"));
	defaultcurrency = libelle_msg(Etn, request, parseNull(rsshop.value(prefix + "currency")));

	String _currencyfreq = libelle_msg(Etn, request, parseNull(rs.value("currency_frequency")));

	String currency_frequency = getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq);

	ProductImageHelper imageHelper = new ProductImageHelper(rs.value("id"));

	Set rsVariants = Etn.execute("select p.device_type as deviceType, p.product_uuid as productUuid, p."+prefix+"name as productName, p.brand_name as productBrand, pv.*, pvd.* from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id = pv.product_id inner join "+catalogdb+".product_variant_details pvd on pv.id = pvd.product_variant_id and pvd.langue_id="+escape.cote(langue_id)+" where pv.is_active=1 and p.product_uuid = "+escape.cote(product_uuid)+" order by pv.is_default desc");

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

	while(rsVariants.next())
	{
        minimumDeliveryFee = "";
		JSONObject jo = new JSONObject();

		String productCategory = catalogType;
		if(parseNull(rsVariants.value("deviceType")).length() > 0) productCategory = parseNull(rsVariants.value("deviceType"));
		jo.put("productCategory", productCategory);
		jo.put("productUuid", parseNull(rsVariants.value("productUuid")));
		jo.put("sku", parseNull(rsVariants.value("sku")));
		jo.put("productName", parseNull(rsVariants.value("productName")));
		jo.put("productBrand", parseNull(rsVariants.value("productBrand")));
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
                    minimumDeliveryFee = libelle_msg(Etn, request, "Frais de livraison à partir de")+" "+ PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, fee), currency_frequency);
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
                    minimumDeliveryFee = libelle_msg(Etn, request, "Frais de livraison à partir de")+" "+PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, fee), currency_frequency);
            }
            jo.put("deliveryFee",minimumDeliveryFee );
        }

		JSONObject extraProductImpressionAttrs = new JSONObject();
		//this jsp is just for products
/*			if(catalogType.equalsIgnoreCase("offer"))
		{
			extraProductImpressionAttrs.put("pi_in_stock", "yes");
			extraProductImpressionAttrs.put("pi_stock", "");
			extraProductImpressionAttrs.put("pi_currency", defaultcurrency);
		}
		else
		{*/
			extraProductImpressionAttrs.put("pi_in_stock", (inStock==true)?"yes":"no");
			extraProductImpressionAttrs.put("pi_stock", parseNullInt(rsVariants.value("stock")));
			extraProductImpressionAttrs.put("pi_currency", defaultcurrency);
//		}

		jo.put("extraImpressionAttrs", extraProductImpressionAttrs);


		String newPrice = getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, client_id);
		String oldPrice = getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, false, client_id);
                String minSubsidizedPrice = null;
                String minSubsidizedUrl = null;
		String formattedNewPrice = "";
		String formattedOldPrice = "";
		String dataLayerNewPrice = "";
		String formattedSubsidizedPrice = "";

                JSONArray subsidies = getSubsidiesOnVariant(Etn, request, rsVariants.value("id"));
                for(int i=0; i<subsidies.length(); i++){
                    String subsidizedPrice = getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, client_id, subsidies.getJSONObject(i).optString("subsidy_id"));
                    if(minSubsidizedPrice==null || parseNullDouble(subsidizedPrice)<parseNullDouble(minSubsidizedPrice)){
                        minSubsidizedPrice = subsidizedPrice;
                        minSubsidizedUrl = subsidies.getJSONObject(i).optString("url");
                        //System.out.println(subsidies.getJSONObject(i).optString("url")+getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, client_id, subsidies.getJSONObject(i).optString("subsidy_id")));
                    }

                }


		if(!is_show_price.equals("0")){
            priorityIsShowPrice = is_show_price;
			dataLayerNewPrice = formatPrice(priceformatter, roundto, showdecimals, newPrice, true);
			formattedNewPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, newPrice), currency_frequency);
			formattedOldPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, oldPrice), currency_frequency);

            if(minSubsidizedPrice!=null) formattedSubsidizedPrice =  PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), formatPrice(priceformatter, roundto, showdecimals, minSubsidizedPrice), currency_frequency);

            if("".equals(minPrice)){
				maxPrice = minPrice = newPrice;
				maxOldPrice = minOldPrice = oldPrice;
			}
			else{
				if(parseNullDouble(newPrice)<parseNullDouble(minPrice)) minPrice = newPrice;
				if(parseNullDouble(newPrice)>parseNullDouble(maxPrice)) maxPrice = newPrice;
				if(parseNullDouble(oldPrice)<parseNullDouble(minOldPrice)) minOldPrice = oldPrice;
				if(parseNullDouble(oldPrice)>parseNullDouble(maxOldPrice)) maxOldPrice = oldPrice;
			}
		}
		else{
			formattedNewPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
			formattedOldPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
			dataLayerNewPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
		}

		JSONObject flatRate = new JSONObject();
		flatRate.put("text",libelle_msg(Etn, request, "À partir de"));
		flatRate.put("newPrice",formattedSubsidizedPrice);
		flatRate.put("oldPrice",formattedOldPrice);
		flatRate.put("dlNewPrice",dataLayerNewPrice);
		flatRate.put("url",menuPath+minSubsidizedUrl);
		jo.put("flatRate", flatRate);

		JSONObject baseRate = new JSONObject();
		baseRate.put("text",libelle_msg(Etn, request, "À partir de"));
		baseRate.put("newPrice",formattedNewPrice);
		baseRate.put("oldPrice",formattedOldPrice);
		baseRate.put("dlNewPrice",dataLayerNewPrice);
		jo.put("baseRate", baseRate);



		jo.put("shipment",libelle_msg(Etn, request, "Expédié à partir du 01/01/2019"));


		JSONArray additionalFee = getAdditionalFee(Etn, request, rsVariants.value("id"), prefix, oldPrice,1);
		JSONObject promotion = getPromotion(Etn, request, rsVariants.value("id"), prefix);
		JSONArray comewith = getComewith(Etn, request, rsVariants.value("id"), prefix, langue_id, "", false, menuid);
		if(promotion.length()!=0){
			promotion.put("discountAmount",formatPrice(priceformatter, roundto, showdecimals, (parseNullDouble(oldPrice)-parseNullDouble(newPrice))+""));
			promotion.put("currency",currency_frequency);
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

	JSONObject jo = new JSONObject();
	jo.put("id","0");
	jo.put("is_default","0");
	jo.put("showamountwithtax",showamountwithtax);
	jo.put("sticker",prioritySticker);
	jo.put("stickerColor",priorityStickerColor);
	jo.put("stickerDisplayName",priorityStickerDisplayName);
	jo.put("inStock",priorityInStock);
	jo.put("actionButtonDesktop",priorityActionButtonDesktop);
	jo.put("actionButtonMobile",priorityActionButtonMobile);
	jo.put("actionButtonDesktopUrl","javascript:void(0)");
	jo.put("actionButtonMobileUrl","javascript:void(0)");
	JSONObject flatRate = new JSONObject();
	flatRate.put("text",libelle_msg(Etn, request, "À partir de"));
	String newPriceRange = formatPrice(priceformatter, roundto, showdecimals, minPrice);
	if(!minPrice.equals(maxPrice)) newPriceRange+=" - "+formatPrice(priceformatter, roundto, showdecimals, maxPrice);

	String oldPriceRange = formatPrice(priceformatter, roundto, showdecimals, minOldPrice);
	if(!minOldPrice.equals(maxOldPrice)) oldPriceRange+=" - "+formatPrice(priceformatter, roundto, showdecimals, maxOldPrice);

        String formattedNewPrice = "";
        String formattedOldPrice = "";

        if(!priorityIsShowPrice.equals("0")){
            formattedOldPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), oldPriceRange, currency_frequency);
            formattedNewPrice = PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), parseNullInt(langue_id), newPriceRange, currency_frequency);
        }
        else{
                formattedNewPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
                formattedOldPrice = parseNull(rsshop.value(prefix + "no_price_display_label"));
        }
	flatRate.put("newPrice",""/*formattedNewPrice*/);
	flatRate.put("oldPrice",formattedOldPrice);
	jo.put("flatRate", flatRate);

	JSONObject baseRate = new JSONObject();
	baseRate.put("text",libelle_msg(Etn, request, "À partir de"));
	baseRate.put("newPrice",formattedNewPrice);
	baseRate.put("oldPrice",formattedOldPrice);
	jo.put("baseRate", baseRate);

	jo.put("shipment",libelle_msg(Etn, request, "Expédié à partir du 01/01/2019"));

	JSONArray additionalFee = new JSONArray();
	jo.put("additionalFee",additionalFee);
	jo.put("promotion",priorityPromotion);
	jo.put("comewith",new JSONArray());
	json.put(jo);

	JSONObject countrySpecificDLAttrs = new JSONObject();
	countrySpecificDLAttrs.put("dimensionX", "");
	countrySpecificDLAttrs.put("dimensionXX", "data-extra_pi_in_stock");
	countrySpecificDLAttrs.put("metricXX", "data-extra_pi_stock");

	JSONObject results = new JSONObject();
	results.put("extra_product_impression_attrs", countrySpecificDLAttrs);
	results.put("variants", json);
	out.write(results.toString());

%>