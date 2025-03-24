<%@ page import="java.lang.reflect.*"%>
<%!
	public JSONObject newJsonObject()
	{
		JSONObject jsonObject = new JSONObject() {
		@Override
			public JSONObject put(String key, Object value) throws JSONException {
				try {
					Field map = JSONObject.class.getDeclaredField("map");
					map.setAccessible(true);
					Object mapValue = map.get(this);
					if (!(mapValue instanceof LinkedHashMap)) {
						map.set(this, new LinkedHashMap<>());
					}
				} catch (NoSuchFieldException | IllegalAccessException e) {
					throw new RuntimeException(e);
				}
				return super.put(key, value);
			}
		};
		return jsonObject;
	}

    public Map<String, String> getMinimumMarketingDeliveryFee(Contexte Etn, javax.servlet.http.HttpServletRequest request, String siteId, String variant_id, String catalogdb) throws Exception
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
				resp.put("fee", PortalHelper.parseNull(rsDeliveryFee.value("fee")));
			}

			if(PortalHelper.parseNullDouble(rsDeliveryFee.value("fee")) > 0)
			{
				flag = "1";
				break;
			}
			counter++;
		}
		resp.put("flag", flag);
        return resp;
    }

    public Map<String, String>  getMinimumDeliveryMethodFee(Contexte Etn, String siteId, String catalogdb) throws Exception
	{

        Set rsDeliveryMethods = Etn.execute("select method, subType, min(price+0.0) as price, displayName, count(price) as price_count from "+catalogdb+".delivery_methods where site_id = " + escape.cote(siteId)+ " and enable=1 group by method order by price;");
        String flag = "0";
        int counter = 0;
		Map<String, String> resp = new HashMap<String, String>();
		while(rsDeliveryMethods.next())
		{
			if(counter == 0)
			{
				resp.put("fee", PortalHelper.parseNull(rsDeliveryMethods.value("price")));
			}
			if(PortalHelper.parseNullDouble(rsDeliveryMethods.value("price")) > 0)
			{
				flag = "1";
				break;
			}
			counter++;
		}
		resp.put("flag", flag);
        return resp;
    }

	public JSONObject getProductDetails(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String productuuid, String siteid, String lang, String clientid)  throws Exception
	{
		String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
		
		String menuid = "";
		Set rsMenu = Etn.execute("Select id from site_menus where site_id = "+escape.cote(siteid)+ " and lang = "+escape.cote(lang));
		if(rsMenu.next())
		{
			menuid = PortalHelper.parseNull(rsMenu.value(0));
		}
			
		String menuPath = PortalHelper.getMenuPath(Etn, menuid);

		String langid = "";
		//if incoming lang was empty or not found in the language table, we will get the first language by default
		Set __rs1 = Etn.execute("select '0' as _a, langue_code, langue_id from "+catalogdb+".language where langue_code = " + escape.cote(lang) + " union select '1' as _a, langue_code, langue_id from "+catalogdb+".language order by _a, langue_id ");
		if(__rs1.next())
		{
			lang = PortalHelper.parseNull(__rs1.value("langue_code"));
			langid = PortalHelper.parseNull(__rs1.value("langue_id"));
		}

		LanguageHelper.getInstance().set_lang(Etn, lang);	
		
		String prefix = LanguageHelper.getInstance().getProductColumnsPrefix(Etn, lang);

		Set rs = Etn.execute("select *, date_format(created_on, '%Y-%m-%dT%h:%i:%s') created_on_iso, date_format(updated_on, '%Y-%m-%dT%h:%i:%s') updated_on_iso from "+catalogdb+".products where product_uuid="+ escape.cote(productuuid));
		rs.next();
		
		Set rscat = Etn.execute("select * from "+catalogdb+".catalogs where id = " + escape.cote(rs.value("catalog_id")));
		rscat.next();
		
		boolean isOffer = "offer".equals(rscat.value("catalog_type"));

		boolean pricetaxincluded = ("1".equals(PortalHelper.parseNull(rscat.value("price_tax_included")))?true:false);
		boolean showamountwithtax = ("1".equals(PortalHelper.parseNull(rscat.value("show_amount_tax_included")))?true:false);
		TaxPercentage taxpercentage = new TaxPercentage();
		taxpercentage.tax = PortalHelper.parseNullDouble(rscat.value("tax_percentage"));
		taxpercentage.input_with_tax = pricetaxincluded;
		taxpercentage.output_with_tax = showamountwithtax;
		taxpercentage.tax_exclusive = !showamountwithtax;
		
		Set rsshop = Etn.execute("select * from "+catalogdb+".shop_parameters where site_id = " + escape.cote(rscat.value("site_id")) );
		rsshop.next();
		String priceformatter = PortalHelper.parseNull(rsshop.value(prefix + "price_formatter"));
		String deliveroutsidedepartment = PortalHelper.parseNull(rsshop.value("deliver_outside_dep"));//changed
		String roundto = PortalHelper.parseNull(rsshop.value(prefix + "round_to_decimals"));
		String showdecimals = PortalHelper.parseNull(rsshop.value(prefix + "show_decimals"));

		boolean bIsProd = "1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV"));
		String imagesBaseUrl = com.etn.beans.app.GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteid;
		if(menuid.length() > 0 && bIsProd)
		{
			imagesBaseUrl = com.etn.asimina.util.PortalHelper.getCachedResourcesUrl(Etn, menuid);
		}
		imagesBaseUrl = imagesBaseUrl + "/img/";

		JSONObject jProduct = newJsonObject();
		JSONObject jInfo = newJsonObject();
		jProduct.put("info", jInfo);
		String productCategory = rscat.value("catalog_type");
		if(PortalHelper.parseNull(rs.value("device_type")).length() > 0) productCategory = PortalHelper.parseNull(rs.value("device_type"));
		jInfo.put("type", rs.value("product_type"));
		jInfo.put("category", productCategory);
		jInfo.put("id", PortalHelper.parseNull(rs.value("product_uuid")));
		jInfo.put("name", PortalHelper.parseNull(rs.value(prefix+"name")));
		if(isOffer == false) jInfo.put("brand", PortalHelper.parseNull(rs.value("brand_name")));
		jInfo.put("variant", PortalHelper.parseNull(rs.value("html_variant")));
		jInfo.put("variant_selection_by", PortalHelper.parseNull(rs.value("select_variant_by")));
		jInfo.put("created_on", PortalHelper.parseNull(rs.value("created_on_iso")));
		jInfo.put("updated_on", PortalHelper.parseNull(rs.value("updated_on_iso")));
		
		String sortvariant = "custom";
		if(PortalHelper.parseNull(rs.value("sort_variant")).equals("cda")) sortvariant = "created_date_ascending";
		else if(PortalHelper.parseNull(rs.value("sort_variant")).equals("cdd")) sortvariant = "created_date_descending";
		else if(PortalHelper.parseNull(rs.value("sort_variant")).equals("pd")) sortvariant = "price_descending";
		else if(PortalHelper.parseNull(rs.value("sort_variant")).equals("pa")) sortvariant = "price_ascending";
		jInfo.put("variant_sort_by", sortvariant);
		
		JSONArray jTags = new JSONArray();
		Set rsTags = Etn.execute("select pt.tag_id, t.label from "+catalogdb+".product_tags pt inner join "+catalogdb+".tags t on t.id = pt.tag_id and t.site_id = "+escape.cote(siteid)+" where pt.product_id ="+escape.cote(rs.value("id")));
		while(rsTags.next())
		{
			JSONObject jTag = newJsonObject();
			jTag.put("id", rsTags.value("tag_id"));
			jTag.put("label", rsTags.value("label"));
			jTags.put(jTag);
		}
		jProduct.put("tags", jTags);
		
		
		JSONObject jProductShopParameters = newJsonObject();
		jProductShopParameters.put("show_basket", "1".equals(PortalHelper.parseNull(rs.value("show_basket"))));
		jProductShopParameters.put("is_new", "1".equals(PortalHelper.parseNull(rs.value("is_new"))));
		jProductShopParameters.put("show_quickbuy", "1".equals(PortalHelper.parseNull(rs.value("show_quickbuy"))));
		jProductShopParameters.put("payment_online", "1".equals(PortalHelper.parseNull(rs.value("payment_online"))));
		jProductShopParameters.put("payment_cash_on_delivery", "1".equals(PortalHelper.parseNull(rs.value("payment_cash_on_delivery"))));
		jProductShopParameters.put("allow_ratings", "1".equals(PortalHelper.parseNull(rs.value("allow_ratings"))));
		jProductShopParameters.put("allow_comments", "1".equals(PortalHelper.parseNull(rs.value("allow_comments"))));
		jProductShopParameters.put("allow_complaints", "1".equals(PortalHelper.parseNull(rs.value("allow_complaints"))));
		jProductShopParameters.put("allow_questions", "1".equals(PortalHelper.parseNull(rs.value("allow_questions"))));
		jProduct.put("shop_parameters", jProductShopParameters);

		JSONObject jSeo = newJsonObject();
		jProduct.put("seo", jSeo);
		JSONObject jDescriptions = newJsonObject();
		jProduct.put("description", jDescriptions);
		
		Set rsProdDesc = Etn.execute("Select * from "+catalogdb+".product_descriptions where product_id = "+escape.cote(rs.value("id")) + " and langue_id = "+escape.cote(langid));		
		if(rsProdDesc.next())
		{			
			jSeo.put("description",PortalHelper.parseNull(rsProdDesc.value("seo")));
			jDescriptions.put("summary",PortalHelper.parseNull(rsProdDesc.value("summary")));
			jDescriptions.put("main_features",PortalHelper.parseNull(rsProdDesc.value("main_features")));
			jDescriptions.put("video_url",PortalHelper.parseNull(rsProdDesc.value("video_url")));
			jDescriptions.put("essentials_alignment",PortalHelper.parseNull(rsProdDesc.value("essentials_alignment")));
			jSeo.put("title",PortalHelper.parseNull(rsProdDesc.value("seo_title")));
			String cUrl = PortalHelper.parseNull(rsProdDesc.value("seo_canonical_url"));
			if(cUrl.length() > 0) cUrl = menuPath + cUrl + ".html";
			jSeo.put("canonical_url", cUrl);

			String cPath = PortalHelper.parseNull(rsProdDesc.value("page_path"));
			if(cPath.length() > 0) cPath = menuPath + cPath + ".html";
			jSeo.put("path", cPath);
		}
		
		JSONArray jEssentials = new JSONArray();
		Set rsProdEss = Etn.execute("select * from "+catalogdb+".product_essential_blocks where product_id = "+escape.cote(rs.value("id")) + " and langue_id = "+escape.cote(langid) + " order by order_seq");		
		while(rsProdEss.next())
		{
			JSONObject jEssential = newJsonObject();
			jEssential.put("block_text",PortalHelper.parseNull(rsProdEss.value("block_text")));
			
			if(PortalHelper.parseNull(rsProdEss.value("file_name")).length() > 0)
			{
				JSONObject image = newJsonObject();
				image.put("label",PortalHelper.parseNull(rsProdEss.value("image_label")));				
				image.put("thumb", imagesBaseUrl + "thumb/" + (rsProdEss.value("file_name")));
				image.put("4x3", imagesBaseUrl + "4x3/" + (rsProdEss.value("file_name")));
				image.put("raw", imagesBaseUrl + (rsProdEss.value("file_name")));
				jEssential.put("image", image);
			}			
			jEssential.put("order_seq",PortalHelper.parseNull(rsProdEss.value("order_seq")));
			jEssentials.put(jEssential);
		}
		jProduct.put("essentials", jEssentials);
		
		JSONArray jTabs = new JSONArray();
		Set rsProdTabs = Etn.execute("select * from "+catalogdb+".product_tabs where product_id = "+escape.cote(rs.value("id")) + " and langue_id = "+escape.cote(langid) + " order by order_seq");		
		while(rsProdTabs.next())
		{
			JSONObject jTab = newJsonObject();
			jTab.put("name",PortalHelper.parseNull(rsProdTabs.value("name")));
			jTab.put("content",PortalHelper.parseNull(rsProdTabs.value("content")));
			jTab.put("order_seq",PortalHelper.parseNull(rsProdTabs.value("order_seq")));
			
			jTabs.put(jTab);
		}
		jProduct.put("tabs", jTabs);

		JSONArray jSpecs = new JSONArray();
		Set rsSpecs = Etn.execute("select p.*, ca.name, ca.visible_to, ca.sort_order, ca.detail_only, ca.is_searchable, ca.value_type from "+catalogdb
			+".product_attribute_values p inner join "+catalogdb
			+".catalog_attributes ca on ca.type = 'specs' and ca.cat_attrib_id = p.cat_attrib_id where p.product_id = "+escape.cote(rs.value("id"))+" order by ca.sort_order");

		while(rsSpecs.next()){
			JSONObject attribute = newJsonObject();
			attribute.put("name",rsSpecs.value("name"));
			attribute.put("visible_to",rsSpecs.value("visible_to"));
			attribute.put("value",rsSpecs.value("attribute_value"));
			attribute.put("is_searchable",rsSpecs.value("is_searchable"));
			attribute.put("sort_order",rsSpecs.value("sort_order"));
			jSpecs.put(attribute);
		}
		jProduct.put("specifications", jSpecs);
		
		//these images are only for offers		
		if(isOffer)
		{
			Set rsI = Etn.execute("Select * from "+catalogdb+".product_images where product_id = "+escape.cote(rs.value("id")) + " and langue_id = "+escape.cote(langid));
			JSONArray images = new JSONArray();
			while(rsI.next())
			{
				JSONObject image = newJsonObject();
				image.put("thumb", imagesBaseUrl + "thumb/" + (rsI.value("image_file_name")));
				image.put("4x3", imagesBaseUrl + "4x3/" + (rsI.value("image_file_name")));
				image.put("raw", imagesBaseUrl + (rsI.value("image_file_name")));
				images.put(image);
			}
			jProduct.put("images",images);
			
		}

		ProductImageHelper imageHelper = new ProductImageHelper(rs.value("id"));

		Set rsVariants = Etn.execute("select pv.*, date_format(pv.created_on, '%Y-%m-%dT%h:%i:%s') created_on_iso, date_format(pv.updated_on, '%Y-%m-%dT%h:%i:%s') updated_on_iso, pvd.* from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id = pv.product_id inner join "+catalogdb+".product_variant_details pvd on pv.id = pvd.product_variant_id and pvd.langue_id="+escape.cote(langid)+" where p.product_uuid = "+escape.cote(productuuid)+" order by pv.is_default desc");

		String minPrice = "";
		String maxPrice = "";
		String minOldPrice = "";
		String maxOldPrice = "";
		JSONObject priorityPromotion = newJsonObject();
		String prioritySticker = "";
		boolean priorityInStock = false;
		String priorityActionButtonDesktop = "";
		String priorityActionButtonMobile = "";
		boolean priorityIsShowPrice = false;

		JSONArray jVariants = new JSONArray();
		jProduct.put("variants", jVariants);
		while(rsVariants.next())
		{
			String minimumDeliveryFee = "";
			String minimumDeliveryFeeText = "";
			JSONObject jo = newJsonObject();

			jo.put("created_on", PortalHelper.parseNull(rsVariants.value("created_on_iso")));
			jo.put("updated_on", PortalHelper.parseNull(rsVariants.value("updated_on_iso")));
			jo.put("sku", PortalHelper.parseNull(rsVariants.value("sku")));
			jo.put("name", PortalHelper.parseNull(rsVariants.value("name")));
			jo.put("id",rsVariants.value("uuid"));
			jo.put("main_features", PortalHelper.parseNull(rsVariants.value("main_features")));
			jo.put("is_default", "1".equals(rsVariants.value("is_default")));
			jo.put("is_active", "1".equals(rsVariants.value("is_active")));
								
			String sticker = rsVariants.value("sticker");
			jo.put("sticker",sticker);
			Set stickerRs = Etn.execute("select color, display_name_" + langid + " as display_name from " + catalogdb + ".stickers where site_id = " + escape.cote(rscat.value("site_id")) + " and sname = " + escape.cote(sticker));
			String stickerColor = "";
			String stickerDisplayName = "";
			if(stickerRs.next()){

				stickerColor = PortalHelper.parseNull(stickerRs.value("color"));
				stickerDisplayName = PortalHelper.parseNull(stickerRs.value("display_name"));
			}
			JSONObject jSticker = newJsonObject();
			jSticker.put("sticker",sticker);
			jSticker.put("color",stickerColor);
			jSticker.put("display_name",stickerDisplayName);
			jo.put("sticker", jSticker);

			JSONObject jActionButton = newJsonObject();
			String is_show_price = rsVariants.value("is_show_price");
			jActionButton.put("button_desktop",rsVariants.value("action_button_desktop"));
			jActionButton.put("button_mobile",rsVariants.value("action_button_mobile"));
			jActionButton.put("desktop_url",rsVariants.value("action_button_desktop_url"));
			jActionButton.put("mobile_url",rsVariants.value("action_button_mobile_url"));
			jo.put("action_button", jActionButton);

			if(rsVariants.value("is_default").equals("1") && rsVariants.value("action_button_desktop").length() > 0 || priorityActionButtonDesktop.equals("")) priorityActionButtonDesktop = rsVariants.value("action_button_desktop");
			if(rsVariants.value("is_default").equals("1") && rsVariants.value("action_button_mobile").length() > 0 || priorityActionButtonMobile.equals("")) priorityActionButtonMobile = rsVariants.value("action_button_mobile");

			boolean inStock = (PortalHelper.parseNullInt(rsVariants.value("stock"))>0?true:false);
			if(inStock) priorityInStock = true;
			if(isOffer == false) 
			{
				jo.put("in_stock",inStock);
				jo.put("stock",PortalHelper.parseNullInt(rsVariants.value("stock")));				
			}


			if(isOffer == false && rsshop.value("show_product_detail_delivery_fee").equals("1"))
			{
				if("1".equals(deliveroutsidedepartment))
				{
				   Map<String, String> marketingfeeData = getMinimumMarketingDeliveryFee(Etn, request, rscat.value("site_id"), PortalHelper.parseNull(rsVariants.value("id")),catalogdb);
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
					{
						minimumDeliveryFeeText = LanguageHelper.getInstance().getTranslation(Etn, "Livraison gratuite"); //free deliver
						minimumDeliveryFee = "";
					}
					else if(deliveryFeeFlag.equals("0") && deliveryMethodFeeFlag.equals("0")) // means no delivery fee is greater than zero
					{
						minimumDeliveryFeeText = LanguageHelper.getInstance().getTranslation(Etn, "Livraison gratuite");
						minimumDeliveryFee = "";
					}
					else
					{
						minimumDeliveryFeeText = LanguageHelper.getInstance().getTranslation(Etn, "Frais de livraison à partir de")+" "+ PortalHelper.parseNull(PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), PortalHelper.parseNullInt(langid), PortalHelper.formatPrice(priceformatter, roundto, showdecimals, fee), ""));
						minimumDeliveryFee = fee;
					}
				}
				else
				{
					Map<String, String> marketingfeeData = getMinimumMarketingDeliveryFee(Etn, request, rscat.value("site_id"),PortalHelper.parseNull(rsVariants.value("id")),catalogdb);
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
					{
						minimumDeliveryFeeText = LanguageHelper.getInstance().getTranslation(Etn, "Livraison gratuite");
						minimumDeliveryFee = "";
					}
					else
					{
						minimumDeliveryFeeText = LanguageHelper.getInstance().getTranslation(Etn, "Frais de livraison à partir de")+" "+PortalHelper.parseNull(PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), PortalHelper.parseNullInt(langid), PortalHelper.formatPrice(priceformatter, roundto, showdecimals, fee), ""));
						minimumDeliveryFee = fee;
					}
				}
				JSONObject jDeliveryFee = newJsonObject();
				jDeliveryFee.put("fee", minimumDeliveryFee);
				jDeliveryFee.put("fee_formatted", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, minimumDeliveryFee));
				jDeliveryFee.put("text", minimumDeliveryFeeText);
				jo.put("delivery_fee", jDeliveryFee);
			}

			JSONObject extraProductImpressionAttrs = newJsonObject();
			if(isOffer == false) 
			{
				extraProductImpressionAttrs.put("pi_in_stock", (inStock==true)?"yes":"no");
				extraProductImpressionAttrs.put("pi_stock", PortalHelper.parseNullInt(rsVariants.value("stock")));
			}

			jo.put("extra_impression_attributes", extraProductImpressionAttrs);


			String newPrice = com.etn.asimina.cart.CommonPrice.getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, clientid);
			String oldPrice = com.etn.asimina.cart.CommonPrice.getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, false, clientid);
			String minSubsidizedPriceId = null;
			String minSubsidizedPrice = null;
			String minSubsidizedUrl = null;
			String formattedNewPrice = "";
			String formattedOldPrice = "";
			String dataLayerNewPrice = "";
			String formattedSubsidizedPrice = "";			

			JSONArray subsidies = com.etn.asimina.cart.CommonPrice.getSubsidiesOnVariant(Etn, request, rsVariants.value("id"));
			for(int i=0; i<subsidies.length(); i++)
			{
				String subsidizedPrice = com.etn.asimina.cart.CommonPrice.getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, clientid, subsidies.getJSONObject(i).optString("subsidy_id"));
				if(minSubsidizedPrice==null || PortalHelper.parseNullDouble(subsidizedPrice)<PortalHelper.parseNullDouble(minSubsidizedPrice)){
					minSubsidizedPriceId = subsidies.getJSONObject(i).optString("subsidy_id");
					minSubsidizedPrice = subsidizedPrice;
					minSubsidizedUrl = subsidies.getJSONObject(i).optString("url");
				}
			}
			
			JSONArray jSubsidies = new JSONArray();
			for(int i=0; i<subsidies.length(); i++)
			{
				boolean isMinPrice = false;

				if(subsidies.getJSONObject(i).optString("subsidy_id").equals(minSubsidizedPriceId)) isMinPrice = true;
				
				JSONObject jSubsidy = newJsonObject();
				jSubsidy.put("is_minimum_price", isMinPrice);
				
				String subsidizedPrice = com.etn.asimina.cart.CommonPrice.getPrice(Etn, rsVariants.value("id"), taxpercentage, 1, true, clientid, subsidies.getJSONObject(i).optString("subsidy_id"));				
				jSubsidy.put("price", PortalHelper.parseNullDouble(subsidizedPrice));
				jSubsidy.put("price_formatted", PortalHelper.parseNull(PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), PortalHelper.parseNullInt(langid), PortalHelper.formatPrice(priceformatter, roundto, showdecimals, subsidizedPrice), "")));
				
				String _url = PortalHelper.parseNull(subsidies.getJSONObject(i).optString("url"));
				if(_url.length() > 0) _url = menuPath + _url;
				jSubsidy.put("url", _url);
				jSubsidy.put("name", PortalHelper.parseNull(subsidies.getJSONObject(i).optString("name")));
				jSubsidy.put("description", PortalHelper.parseNull(subsidies.getJSONObject(i).optString(prefix + "description")));
				jSubsidy.put("discount_type", PortalHelper.parseNull(subsidies.getJSONObject(i).optString("discount_type")));
				jSubsidy.put("discount_value", PortalHelper.parseNull(subsidies.getJSONObject(i).optString("discount_value")));
				
				jSubsidies.put(jSubsidy);
			}
			jo.put("subsidies", jSubsidies);
			
			JSONObject jPrice = newJsonObject();
			jo.put("price", jPrice);
			jPrice.put("show", "1".equals(is_show_price));
						
			dataLayerNewPrice = PortalHelper.formatPrice(priceformatter, roundto, showdecimals, newPrice, true);
			formattedNewPrice = PortalHelper.parseNull(PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), PortalHelper.parseNullInt(langid), PortalHelper.formatPrice(priceformatter, roundto, showdecimals, newPrice), ""));
			formattedOldPrice = PortalHelper.parseNull(PortalHelper.getCurrencyPosition(Etn, request, rscat.value("site_id"), PortalHelper.parseNullInt(langid), PortalHelper.formatPrice(priceformatter, roundto, showdecimals, oldPrice), ""));

			JSONObject jBasePrice = newJsonObject();
			jPrice.put("base", jBasePrice);
			jBasePrice.put("price", PortalHelper.parseNullDouble(oldPrice));
			jBasePrice.put("price_formatted", formattedOldPrice);

			JSONObject jApplicablePrice = newJsonObject();
			jPrice.put("applicable", jApplicablePrice);
			jApplicablePrice.put("price", PortalHelper.parseNullDouble(newPrice));
			jApplicablePrice.put("price_formatted", formattedNewPrice);

			if("1".equals(is_show_price))
			{
				priorityIsShowPrice = true;
				if("".equals(minPrice))
				{
					maxPrice = minPrice = newPrice;
					maxOldPrice = minOldPrice = oldPrice;
				}
				else
				{
					if(PortalHelper.parseNullDouble(newPrice)<PortalHelper.parseNullDouble(minPrice)) minPrice = newPrice;
					if(PortalHelper.parseNullDouble(newPrice)>PortalHelper.parseNullDouble(maxPrice)) maxPrice = newPrice;
					if(PortalHelper.parseNullDouble(oldPrice)<PortalHelper.parseNullDouble(minOldPrice)) minOldPrice = oldPrice;
					if(PortalHelper.parseNullDouble(oldPrice)>PortalHelper.parseNullDouble(maxOldPrice)) maxOldPrice = oldPrice;
				}
			}
			
			JSONArray additionalFee = com.etn.asimina.cart.CommonPrice.getAdditionalFee(Etn, request, rsVariants.value("id"), prefix, oldPrice,1);
			JSONObject promotion = com.etn.asimina.cart.CommonPrice.getPromotion(Etn, request, rsVariants.value("id"), prefix);
			JSONArray comewith = com.etn.asimina.cart.CommonPrice.getComewith(Etn, request, rsVariants.value("id"), prefix, langid, "", false, menuid);
			if(promotion.length()!=0){
				promotion.put("discount_amount",PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (PortalHelper.parseNullDouble(oldPrice)-PortalHelper.parseNullDouble(newPrice))+""));
			}
			jo.put("additional_fee",additionalFee);
			jo.put("promotion",promotion);
			jo.put("comewith",comewith);

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
			Set rsVariantAttributes = Etn.execute("select pvr.*, ca.name, ca.visible_to, ca.sort_order, ca.detail_only, ca.is_searchable, ca.value_type, cav.attribute_value, cav.small_text, cav.color from "+catalogdb
				+".product_variant_ref pvr inner join "+catalogdb
				+".catalog_attributes ca on ca.type = 'selection' and ca.cat_attrib_id = pvr.cat_attrib_id left join "+catalogdb+".catalog_attribute_values cav on cav.id = pvr.catalog_attribute_value_id where pvr.product_variant_id = "+escape.cote(rsVariants.value("id"))+" order by ca.sort_order");


			while(rsVariantAttributes.next()){
				JSONObject attribute = newJsonObject();
				attribute.put("name",rsVariantAttributes.value("name"));
				attribute.put("id",rsVariantAttributes.value("cat_attrib_id"));				
				attribute.put("detail_only", "1".equals(rsVariantAttributes.value("detail_only")));
				attribute.put("is_searchable", "1".equals(rsVariantAttributes.value("is_searchable")));
				attribute.put("type",rsVariantAttributes.value("value_type"));
				attribute.put("value_id",rsVariantAttributes.value("catalog_attribute_value_id"));
				attribute.put("value",rsVariantAttributes.value("attribute_value"));
				attribute.put("small_text",rsVariantAttributes.value("small_text"));
				attribute.put("color",rsVariantAttributes.value("color"));
				attribute.put("sort_order",rsVariantAttributes.value("sort_order"));
				attributes.put(attribute);
			}
			
			jo.put("attributes", attributes);						
											
			//these images are not for offers
			if(isOffer == false)
			{
				JSONArray images = new JSONArray();
				Set rsVariantImages = Etn.execute("select pvr.* from "+catalogdb+".product_variant_resources pvr inner join "+catalogdb+".product_variants pv on pvr.product_variant_id = pv.id where product_variant_id = "+escape.cote(rsVariants.value("id"))+" and type='image' and langue_id="+escape.cote(langid)+" order by pv.is_default, pvr.sort_order;");
				while(rsVariantImages.next())
				{
					JSONObject image = newJsonObject();
					image.put("thumb", imagesBaseUrl + "thumb/" + (rsVariantImages.value("path")));
					image.put("4x3", imagesBaseUrl + "4x3/" + (rsVariantImages.value("path")));
					image.put("raw", imagesBaseUrl + (rsVariantImages.value("path")));
					image.put("sort_order", rsVariantImages.value("sort_order"));
					images.put(image);
				}
				jo.put("images",images);
			}

			jVariants.put(jo);
		}

		Set priorityStickerRs = Etn.execute("select color, display_name_" + langid + " as display_name from " + catalogdb + ".stickers where site_id = " + escape.cote(rscat.value("site_id")) + " and sname = " + escape.cote(prioritySticker));

		String priorityStickerColor = "";
		String priorityStickerDisplayName = "";

		if(priorityStickerRs.next()){

			priorityStickerColor = PortalHelper.parseNull(priorityStickerRs.value("color"));
			priorityStickerDisplayName = PortalHelper.parseNull(priorityStickerRs.value("display_name"));
		}

		jInfo.put("show_amount_with_tax",showamountwithtax);
		
		JSONObject jPriority = newJsonObject();
		jProduct.put("priority", jPriority);
		
		JSONObject jSticker = newJsonObject();
		jSticker.put("sticker", prioritySticker);
		jSticker.put("color", priorityStickerColor);		
		jSticker.put("display_name",priorityStickerDisplayName);
		jPriority.put("sticker", jSticker);
		
		if(isOffer == false) jInfo.put("in_stock",priorityInStock);
		
		JSONObject jActionButton = newJsonObject();
		jActionButton.put("button_desktop",priorityActionButtonDesktop);
		jActionButton.put("button_mobile",priorityActionButtonMobile);
		jActionButton.put("desktop_url","javascript:void(0)");
		jActionButton.put("mobile_url","javascript:void(0)");
		jPriority.put("action_button", jActionButton);
		
		boolean priceIsRange = false;
		if(minPrice != maxPrice) priceIsRange = true;
		JSONObject jPrice = newJsonObject();
		jPrice.put("show", priorityIsShowPrice);
		jPrice.put("is_range", priceIsRange);
		jProduct.put("price", jPrice);
		
		JSONObject jMinPrice = newJsonObject();
		jPrice.put("minimum", jMinPrice);
		JSONObject jApplicablePrice = newJsonObject();
		jMinPrice.put("applicable", jApplicablePrice);
		jApplicablePrice.put("price", PortalHelper.parseNullDouble(minPrice));
		jApplicablePrice.put("price_formatted", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, minPrice));
		JSONObject jBasePrice = newJsonObject();
		jMinPrice.put("base", jBasePrice);
		jBasePrice.put("price", PortalHelper.parseNullDouble(minOldPrice));
		jBasePrice.put("price_formatted", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, minOldPrice));
		
		JSONObject jMaxPrice = newJsonObject();
		jPrice.put("maximum", jMaxPrice);
		jApplicablePrice = newJsonObject();
		jMaxPrice.put("applicable", jApplicablePrice);
		jApplicablePrice.put("price", PortalHelper.parseNullDouble(maxPrice));
		jApplicablePrice.put("price_formatted", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, maxPrice));
		jBasePrice = newJsonObject();
		jMaxPrice.put("base", jBasePrice);
		jBasePrice.put("price", PortalHelper.parseNullDouble(maxOldPrice));
		jBasePrice.put("price_formatted", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, maxOldPrice));
				
		
		jPriority.put("promotion",priorityPromotion);

		JSONObject countrySpecificDLAttrs = newJsonObject();
		countrySpecificDLAttrs.put("dimensionX", "");
		countrySpecificDLAttrs.put("dimensionXX", "data-extra_pi_in_stock");
		countrySpecificDLAttrs.put("metricXX", "data-extra_pi_stock");
		jProduct.put("extra_product_impression_attrs", countrySpecificDLAttrs);

		return jProduct;
	}
	
	public JSONObject getShopParameters(com.etn.beans.Contexte Etn, String siteid, String langId) throws Exception
	{
		String prefix = "lang_" + langId;

		Set rsshop = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id = " + escape.cote(siteid) );
		rsshop.next();
		String defaultcurrency = PortalHelper.parseNull(rsshop.value(prefix + "_currency"));	
		String defaultcurrencylabel = LanguageHelper.getInstance().getTranslation(Etn, defaultcurrency);
		
		JSONObject jShopParameters = newJsonObject();
		jShopParameters.put("deliver_outside_dep_error", PortalHelper.parseNull(rsshop.value(prefix + "_deliver_outside_dep_error")));
		jShopParameters.put("coming_soon_button", PortalHelper.parseNull(rsshop.value(prefix + "_coming_soon_button")));
		jShopParameters.put("stock_alert_text", PortalHelper.parseNull(rsshop.value(prefix + "_stock_alert_text")));
		jShopParameters.put("no_price_display_label", PortalHelper.parseNull(rsshop.value(prefix + "_no_price_display_label")));
		jShopParameters.put("continue_shop_url", PortalHelper.parseNull(rsshop.value(prefix + "_continue_shop_url")));
		jShopParameters.put("stock_alert_button", PortalHelper.parseNull(rsshop.value(prefix + "_stock_alert_button")));
		jShopParameters.put("price_formatter", PortalHelper.parseNull(rsshop.value(prefix + "_price_formatter")));
		jShopParameters.put("round_to_decimals", PortalHelper.parseNull(rsshop.value(prefix + "_round_to_decimals")));
		jShopParameters.put("show_decimals", PortalHelper.parseNull(rsshop.value(prefix + "_show_decimals")));
		
		JSONObject jCurrency = newJsonObject();
		jShopParameters.put("currency", jCurrency);	
		jCurrency.put("position", PortalHelper.parseNull(rsshop.value(prefix + "_currency_position")));
		jCurrency.put("code", defaultcurrency);
		jCurrency.put("label", defaultcurrencylabel);			
		
		return jShopParameters;
	}
	
%>
