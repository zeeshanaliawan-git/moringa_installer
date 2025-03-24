<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm,java.time.*,java.io.*, com.etn.asimina.beans.*"%>
<%@ page import="org.json.*, java.util.*,java.util.regex.Pattern,java.util.regex.Matcher, com.etn.asimina.util.PortalHelper, com.etn.util.*" %>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*, org.apache.tika.*, com.etn.util.Logger"%>


<%!
	/*
	* One script
	* changes in portalhelper.java and new class additionalinfofield added
	* shop/com/etn/eshop/Payment.java changed
	*/

	JSONObject getOrderSnapshot(com.etn.beans.Contexte Etn, String siteid, JSONObject jRequest, String paymentMethodName, String deliveryMethodName, double paymentFee, double deliveryFee, String priceformatter, String roundto, String showdecimals) throws Exception
	{
		LinkedHashSet<String> taxHS=new LinkedHashSet<String>();
		String paymentMethod = PortalHelper.parseNull(jRequest.optString("payment_method"));
		String promoCode = PortalHelper.parseNull(jRequest.optString("promo_code"));
		
		double totalCartDiscount = 0;
		double promoValue = jRequest.optDouble("promo_discount_value",0);		
		double orderDiscounts = jRequest.optDouble("order_discounts",0);
		double shippingDiscounts = jRequest.optDouble("delivery_fee_discount", 0);

		double totalAmount = jRequest.getDouble("total_amount");
		double totalWithoutTax = totalAmount;
		if(jRequest.has("total_amount_without_tax")) totalWithoutTax = jRequest.getDouble("total_amount_without_tax");
		double taxAmount = totalAmount - totalWithoutTax;
		
		JSONArray jOrderDiscounts = new JSONArray();
		if(promoCode.length() > 0)
		{
			JSONObject jDiscount = new JSONObject();
			jDiscount.put("originalRuleValue", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, promoValue+"", true));
			jDiscount.put("rulesCount", 1);
			jDiscount.put("discountType", "fixed");
			jDiscount.put("elementOn", "cart_total");
			jDiscount.put("couponCode", promoCode);
			jDiscount.put("discountValue", promoValue);
			jDiscount.put("ruleAppliedOn", "");
			jOrderDiscounts.put(jDiscount);
		}
		if(orderDiscounts > 0)
		{
			JSONObject jDiscount = new JSONObject();
			jDiscount.put("originalRuleValue", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, orderDiscounts+"", true));
			jDiscount.put("rulesCount", 1);
			jDiscount.put("discountType", "fixed");
			jDiscount.put("elementOn", "cart_total");
			jDiscount.put("couponCode", "");
			jDiscount.put("discountValue", orderDiscounts);
			jDiscount.put("ruleAppliedOn", "");
			jOrderDiscounts.put(jDiscount);
		}
		
		
		JSONObject order_snapshot = new JSONObject();
		order_snapshot.put("deliveryDisplayName", deliveryMethodName);
		order_snapshot.put("paymentDisplayName", paymentMethodName);
		order_snapshot.put("payer",((paymentMethod.equals("cash_on_delivery")||paymentMethod.equals("cash_on_pickup"))?"To pay":"Paid"));
		order_snapshot.put("promoValue", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, promoValue+"", true));
		order_snapshot.put("promoApplied", (promoCode.length()>0?true:false));
		order_snapshot.put("calculatedCartDiscounts", jOrderDiscounts);
		order_snapshot.put("promoAppliedType", "");
		order_snapshot.put("grandTotal", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, totalAmount+"", true));
		order_snapshot.put("grandTotalWT", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, totalWithoutTax+"", true));
		order_snapshot.put("grandTotalRecurring", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, jRequest.optDouble("total_recurring_amount",0)+"", true));
		order_snapshot.put("grandTotalRecurringWT", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, jRequest.optDouble("total_recurring_amount_without_tax",0)+"", true));
		order_snapshot.put("totalTax", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, taxAmount+"", true));
		order_snapshot.put("paymentFees", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, paymentFee+"", true));
		order_snapshot.put("shippingFees", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, deliveryFee+"", true));
		order_snapshot.put("totalCartDiscount", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (promoValue+orderDiscounts)+"", true));
		order_snapshot.put("totalShippingDiscount", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, shippingDiscounts+"", true));

		return order_snapshot;
	}
	
    boolean isValidEmailAddress(String emailAddress)
	{  
		String  expression="^[\\w\\-]([\\.\\w])+[\\w]+@([\\w\\-]+\\.)+[A-Z]{2,4}$";  
		CharSequence inputStr = emailAddress;  
		Pattern pattern = Pattern.compile(expression,Pattern.CASE_INSENSITIVE);  
		Matcher matcher = pattern.matcher(inputStr);  
		return matcher.matches();    
	}
	
	boolean isValidDateTime(String tm)
	{
		//verify date format
		if(tm.contains("T") == false)
		{
			return false;
		}
		if(tm.length() != 19)
		{
			return false;
		}
		String tmDate = tm.substring(0, tm.indexOf("T")).replace("-","");
		if(tmDate.length() != 8)
		{
			return false;
		}
		String tmTime = tm.substring(tm.indexOf("T")).replace("T","").replace(":","");
		if(tmTime.length() != 6)
		{
			return false;
		}
		return true;
	}
	
	String getErrorResponse(com.etn.beans.Contexte Etn, int logId, int status, String errCode, String errMsg) throws Exception	
	{
		JSONObject json = new JSONObject();
		json.put("status", status);
        json.put("err_code", errCode);
        json.put("err_msg", errMsg);
		
		String str = json.toString();
		Etn.executeCmd("update "+GlobalParm.getParm("SHOP_DB")+".external_orders_logs set resp = "+PortalHelper.escapeCote2(str)+" where id = "+escape.cote(""+logId));
		
		return str;
	}
	
	void rollback(com.etn.beans.Contexte Etn, int orderId, String orderUuid)
	{
		String shopdb = GlobalParm.getParm("SHOP_DB");
		Logger.error("apiv2/orders/insert.jsp","Rollback order : "+orderUuid);
		Etn.executeCmd("delete from "+shopdb+".order_items where parent_id = "+escape.cote(orderUuid));
		Etn.executeCmd("delete from "+shopdb+".post_work where client_key = "+escape.cote(orderId+""));
		Etn.executeCmd("delete from "+shopdb+".orders where id = "+escape.cote(orderId+""));		
	}
	
	String getTranslation(com.etn.beans.Contexte Etn, String langId, String w)
	{
		String translation = "";
		Set rs = Etn.execute("select LANGUE_"+langId+" as translation "+
			" from langue_msg where langue_ref = "+escape.cote(w));
		if(rs.next())
		{
			translation = PortalHelper.parseNull(rs.value("translation"));
		}
		if(translation.length() == 0) translation = w;
		Logger.info("apiv2/orders/insert.jsp","Translation for "+w+" : " + translation);
		return translation;
	}
	
	JSONArray getComeWiths(com.etn.beans.Contexte Etn, String siteId, JSONArray jReqComeWiths, String langId, int quantity, String cachedResourcesUrl, String origProdVariantId) throws Exception
	{
		String catalogdb = GlobalParm.getParm("CATALOG_DB");
		
		JSONArray jComeWiths = new JSONArray();
		for(int i=0;i<jReqComeWiths.length();i++)
		{
			String sku = PortalHelper.parseNull(jReqComeWiths.getJSONObject(i).optString("sku"));
			boolean isLabel = false;
			if(jReqComeWiths.getJSONObject(i).has("is_label"))
			{
				isLabel = jReqComeWiths.getJSONObject(i).getBoolean("is_label");
			}
			
			JSONArray selectableVariants = new JSONArray();
			JSONObject variant = new JSONObject();

			Set rsProduct = Etn.execute("select p.*, pv.id as product_variant_id, pv.stock as variant_stock,pv.frequency,pv.commitment, "+
					" c.price_tax_included, c.show_amount_tax_included, c.tax_percentage, "+
					" (select name from "+catalogdb+".product_variant_details pvd "+
					" where pvd.product_variant_id = pv.id and langue_id = " + escape.cote(langId) + ") as name "+
					" from "+catalogdb+".products p "+
					" inner join "+catalogdb+".catalogs ct on ct.id = p.catalog_id and ct.site_id = "+escape.cote(siteId)+
					" inner join "+catalogdb+".product_variants pv on p.id=pv.product_id "+
					" inner join "+catalogdb+".catalogs c on p.catalog_id = c.id where pv.is_active=1 and pv.sku = "+escape.cote(sku));

			String variantId = "";
			String variantName = "";
			String productName = "";
			String productId = "";
			String imageUrl = "";
			while(rsProduct.next())
			{
				variantId = PortalHelper.parseNull(rsProduct.value("product_variant_id"));
				variantName = PortalHelper.parseNull(rsProduct.value("name"));

				variant = new JSONObject();
				variant = PortalHelper.toJSONObject(rsProduct);

				boolean pricetaxincluded = ("1".equals(PortalHelper.parseNull(rsProduct.value("price_tax_included")))?true:false);
				boolean showamountwithtax = ("1".equals(PortalHelper.parseNull(rsProduct.value("show_amount_tax_included")))?true:false);

				TaxPercentage taxpercentage = new TaxPercentage();
				TaxPercentage taxpercentageWT = new TaxPercentage(); // to output without tax
				taxpercentage.tax = PortalHelper.parseNullDouble(rsProduct.value("tax_percentage"));
				taxpercentageWT.tax = taxpercentage.tax;
				taxpercentage.input_with_tax = pricetaxincluded;
				taxpercentageWT.input_with_tax = pricetaxincluded;
				taxpercentage.output_with_tax = showamountwithtax;
				taxpercentageWT.output_with_tax = showamountwithtax;
				taxpercentage.tax_exclusive = false;
				taxpercentageWT.tax_exclusive = true;

				//new rule is we must apply promotion on comewith as well if any applicable
				variant.put("price", com.etn.asimina.cart.CommonPrice.getPrice(Etn, variantId, taxpercentage, quantity, false, ""));
				variant.put("priceWT", com.etn.asimina.cart.CommonPrice.getPrice(Etn, variantId, taxpercentageWT, quantity, false, ""));

				productName = rsProduct.value("lang_"+langId+"_name");
				productId = rsProduct.value("id");
				if(rsProduct.value("product_type").startsWith("offer_"))
				{
					Set rsImages = Etn.execute("select image_file_name from "+catalogdb+".product_images where product_id="+escape.cote(productId)+" and langue_id="+escape.cote(langId));

					if(rsImages.next()) imageUrl = rsImages.value("image_file_name");
				}
				else
				{
					Set rsVariantImages = Etn.execute("select path from "+catalogdb+".product_variant_resources where type='image' and product_variant_id="+escape.cote(variantId)+" and langue_id="+escape.cote(langId)+" order by sort_order");

					if(rsVariantImages.next()) imageUrl = rsVariantImages.value("path");
				}

				if(imageUrl.length()>0)
				{
					String imagePathPrefix = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + ("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))?"":siteId+"/") + "img/4x3/";
					String imageUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + ("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))?"":siteId+"/");
					if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV")))
					{
						imageUrlPrefix = cachedResourcesUrl;
					}
					imageUrlPrefix = imageUrlPrefix + "img/thumb/";
					String imagePath = imagePathPrefix + imageUrl;
					String _version = PortalHelper.getImageUrlVersion(imagePath);
					imageUrl = imageUrlPrefix + imageUrl + _version;
				}
				
				JSONObject selectableVariant = new JSONObject();
				selectableVariant.put("product_type", rsProduct.value("product_type"));
				selectableVariant.put("variantName", rsProduct.value("name"));
				selectableVariant.put("imageUrl", imageUrl);
				selectableVariant.put("variant_id", variantId);
				selectableVariant.put("stock", rsProduct.value("variant_stock"));
				selectableVariants.put(selectableVariant);
			}


			JSONObject comewith = new JSONObject();
			comewith.put("id", "");
			comewith.put("comewith", (isLabel?"label":"product"));
			comewith.put("type", "sku");
			comewith.put("title", "");
			comewith.put("description", "");
			comewith.put("productName", productName);
			comewith.put("imageUrl", imageUrl);
			comewith.put("variant_id", variantId);
			comewith.put("variantName", variantName);
			comewith.put("variant", variant);
			comewith.put("selectableVariants", selectableVariants);
			comewith.put("applied_to_type", "product");
			comewith.put("applied_to_value", "");
			comewith.put("associated_to_type", "product");
			comewith.put("associated_to_value", origProdVariantId);
			comewith.put("variant_type", "select");

			jComeWiths.put(comewith);
		}
		return jComeWiths;
	}
%>

<%
	final String API_NAME = "order_insert";
    int status = 0;
    String message = "";
    String err_code = "";
    JSONObject json = new JSONObject();
    JSONObject data = new JSONObject();
	
	String catalogdb = GlobalParm.getParm("CATALOG_DB");
	String shopdb = GlobalParm.getParm("SHOP_DB");
	String commonsdb = GlobalParm.getParm("COMMONS_DB");

    final String method = PortalHelper.parseNull(request.getMethod());
	String orderUuid = "";
	int newOrderId = 0;
	
	int logId = 0;

	if("post".equalsIgnoreCase(method) == false)
	{
		json.put("status", 10);
        json.put("err_code", "method_not_supported");
        json.put("err_msg", "Method not supported");
		out.write(json.toString());
		return;
	}

	try
	{	
		String UPLOAD_DIR = GlobalParm.getParm("funnel_documents_base_dir");	
		File dir = new File(UPLOAD_DIR);
		if (!dir.exists()) {
			dir.mkdir();
		}
		if(UPLOAD_DIR.endsWith("/") == false) UPLOAD_DIR += "/";

		//note:cart_documents is also hardcoded in dev_shop/customerEdit.jsp
		String identityPhotoDir = UPLOAD_DIR + "cart_documents/";
		dir = new File(identityPhotoDir);
		if (!dir.exists()) {
			dir.mkdir();
		}
	
		Map<String, String> headerInfo = PortalHelper.getHeadersInfo(request);
		String siteUuid = headerInfo.get("site-uuid");
		Set rsSite = Etn.execute("Select * from sites where suid = "+escape.cote(siteUuid));
		rsSite.next();
		String siteId = rsSite.value("id");
	
		Map<String, AdditionalInfoField> additionalFieldsMetaData = new HashMap<String, AdditionalInfoField>();
		Set rsAddFields = Etn.execute("select f.*, s.name as section_name, s.display_name as section_display_name from checkout_add_info_fields f inner join checkout_add_info_sections s on s.id = f.section_id and s.site_id = "+escape.cote(siteId));
		while(rsAddFields.next())
		{
			AdditionalInfoField aif = new AdditionalInfoField();
			aif.name = PortalHelper.parseNull(rsAddFields.value("name"));
			aif.displayName = PortalHelper.parseNull(rsAddFields.value("display_name"));
			aif.sectionName = PortalHelper.parseNull(rsAddFields.value("section_name"));
			aif.sectionDisplayName = PortalHelper.parseNull(rsAddFields.value("section_display_name"));
			aif.ftype = PortalHelper.parseNull(rsAddFields.value("ftype"));
			if(PortalHelper.parseNull(rsAddFields.value("file_allowed_types")).length() > 0)
			{
				aif.allowedTypes = new ArrayList<String>(Arrays.asList(PortalHelper.parseNull(rsAddFields.value("file_allowed_types")).split(";")));
			}		
			additionalFieldsMetaData.put(aif.name, aif);
		}
	
		FileItemFactory factory = new DiskFileItemFactory();
		ServletFileUpload upload = new ServletFileUpload(factory);

		List items = null;

		try
		{
			upload.setHeaderEncoding("UTF-8");
			items = upload.parseRequest(request);
		}
		catch (FileUploadException e)
		{
			e.printStackTrace();
		}
		Iterator itr = items.iterator();
		Map<String, List<FileItem>> filesMap = new HashMap<String, List<FileItem>>();
		Map<String, List<FileItem>> additionalInfoFilesMap = new HashMap<String, List<FileItem>>();
		
		
		JSONObject jLogRequest = new JSONObject();
		
		String jData = "";
		JSONObject jLogReqFiles = new JSONObject();
		while (itr.hasNext())
		{
			FileItem item = (FileItem)(itr.next());

			if (item.isFormField() && item.getFieldName().equals("data"))
			{
				jData = XSSHandler.clean(item.getString("UTF-8"));
			}
			else if(item.isFormField() == false)
			{
				String field = item.getFieldName();
				jLogReqFiles.put(field, item.getName());
				if(additionalFieldsMetaData.get(field) == null)
				{
					if(filesMap.containsKey(field) == false)
					{
						filesMap.put(field, new ArrayList<FileItem>());
					}
					filesMap.get(field).add(item);
				}
				else
				{
					if(additionalInfoFilesMap.containsKey(field) == false)
					{
						additionalInfoFilesMap.put(field, new ArrayList<FileItem>());
					}
					additionalInfoFilesMap.get(field).add(item);					
				}
			}
		}
		
		if(jData.length() == 0) jData = "{}";
		jLogRequest.put("data", new JSONObject(jData));
		jLogRequest.put("files", jLogReqFiles);

		
		String apiKeyId = PortalHelper.parseNull(session.getAttribute("api_token_key_id"));
		logId = Etn.executeCmd("insert into "+shopdb+".external_orders_logs (api_key_id, req) value ("+escape.cote(apiKeyId)+","+PortalHelper.escapeCote2(jLogRequest.toString())+")");
		
		if(jData.equals("{}"))
		{
			out.write(getErrorResponse(Etn, logId, 15, "data_json_missing", "data json is missing"));
			return;
		}
			
		ArrayList<String> identityPhotoFileTypes = new ArrayList<>();
		identityPhotoFileTypes.add("image/jpeg");
		identityPhotoFileTypes.add("image/png");
		identityPhotoFileTypes.add("image/gif");
		identityPhotoFileTypes.add("image/svg+xml");
		identityPhotoFileTypes.add("image/bmp");
		identityPhotoFileTypes.add("image/tiff");
		identityPhotoFileTypes.add("application/pdf");
		
		FileItem identityPhotoFile = null;
		if(filesMap.get("identity_photo") != null && filesMap.get("identity_photo").size() > 0)
		{
			Logger.info("apiv2/orders/insert.jsp", "identity_photo found");
			identityPhotoFile = filesMap.get("identity_photo").get(0);
		}		
		if(identityPhotoFile != null && identityPhotoFile.getName().length() > 0)
		{
			String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(identityPhotoFile.getInputStream()));

			if (identityPhotoFileTypes.contains(_type) == false) 
			{
				out.write(getErrorResponse(Etn, logId, 15, "invalid_file_format", "identity_photo is not of valid format"));
				return;
			}			
		}
		//verify all uploaded files first
		if(additionalInfoFilesMap != null)
		{
			for(String field : additionalInfoFilesMap.keySet())
			{
				AdditionalInfoField aif = additionalFieldsMetaData.get(field);
				if(aif != null)
				{
					boolean isValid = PortalHelper.isAdditionalFileValid(aif, additionalInfoFilesMap.get(field));
					if(isValid == false)
					{
						out.write(getErrorResponse(Etn, logId, 15, "invalid_file_format", field+" is not of valid format"));
						return;
					}
				}
			}
		}
		
		JSONObject jRequest = new JSONObject(jData);
		
		String orderRef = PortalHelper.parseNull(jRequest.optString("order_ref"));
		if(orderRef.length() == 0)
		{
			out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", "order_ref must be provided"));
			return;
		}
		String lang = PortalHelper.parseNull(jRequest.optString("lang"));
		String langId = "";
		if(lang.length() > 0)
		{
			Set rsL = Etn.execute("select l.* from language l "+
					" join "+commonsdb+".sites_langs sl on sl.site_id = "+escape.cote(siteId)+" and sl.langue_id = l.langue_id "+
					" where l.langue_code = "+escape.cote(lang));
			if(!rsL.next())
			{
				out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "invalid value provided for field lang"));
				return;
			}
			langId = rsL.value("langue_id");
		}
		else
		{
			Logger.info("apiv2/orders/insert.jsp","Use default language for the site");
			
			Set rsL = Etn.execute("select l.* from language l "+
					" join "+commonsdb+".sites_langs sl on sl.site_id = "+escape.cote(siteId)+" and sl.langue_id = l.langue_id "+
					" order by l.langue_id ");
			rsL.next();
			lang = rsL.value("langue_code");
			langId = rsL.value("langue_id");
		}
		
		String orderTs = PortalHelper.parseNull(jRequest.optString("order_ts"));
		if(orderTs.length() == 0)
		{
			out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", "order_ts must be provided"));
			return;
		}
		if(isValidDateTime(orderTs) == false)
		{
			out.write(getErrorResponse(Etn, logId, 15, "invalid_datetime_format", "order_ts must be of format yyyy-mm-ddThh:mm:ss"));
			return;
		}

		if(PortalHelper.parseNull(jRequest.optString("first_name")).length() == 0)
		{
			out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", "Customer first name must be provided"));
			return;
		}
		if(PortalHelper.parseNull(jRequest.optString("last_name")).length() == 0)
		{
			out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", "Customer last name must be provided"));
			return;
		}
		
		String email = PortalHelper.parseNull(jRequest.optString("email"));
		if(email.length() > 0 && isValidEmailAddress(email) == false)
		{
			out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "invalid value provided for field email"));
			return;
		}
		
		String orderType = PortalHelper.parseNull(jRequest.optString("order_type")).toLowerCase();
		if(orderType.length() == 0) orderType = "normal";
		if(orderType.equals("normal") == false && orderType.equals("topup") == false && orderType.equals("card2wallet") == false)
		{
			out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "invalid value provided for field order_type"));
			return;
		}

		Set rsOrder = Etn.execute("select * from "+shopdb+".orders where orderRef = "+escape.cote(orderRef));
		if(rsOrder.next())
		{
			out.write(getErrorResponse(Etn, logId, 15, "order_already_exists", orderRef + " already exists"));
			return;			
		}
				
		if(jRequest.has("total_amount") == false)
		{
			out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", "total_amount must be provided"));
			return;			
		}
		double totalAmount = 0;
		try {
			totalAmount = jRequest.getDouble("total_amount");
		} catch(Exception e) {
			out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "total_amount must be double value"));
			return;			
		}			
		
		double deliveryFee = 0;
		if(jRequest.has("delivery_fee"))
		{
			try {
				deliveryFee = jRequest.getDouble("delivery_fee");
			} catch(Exception e) {
				out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "delivery_fee must be double value"));
				return;				
			}
		}
		
		double paymentFee = 0;
		if(jRequest.has("payment_fee"))
		{
			try {
				paymentFee = jRequest.getDouble("payment_fee");
			} catch(Exception e) {
				out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "payment_fee must be double value"));
				return;				
			}
		}
		
		String deliveryMethodName = "";
		String deliveryMethod = PortalHelper.parseNull(jRequest.optString("delivery_method")).toLowerCase();
		String deliveryType = PortalHelper.parseNull(jRequest.optString("delivery_type"));		
		if(deliveryMethod.length() > 0)
		{
			Set rs = Etn.execute("Select * from "+catalogdb+".delivery_methods where site_id = "+escape.cote(siteId) + " and method = "+escape.cote(deliveryMethod));
			if(!rs.next())
			{
				out.write(getErrorResponse(Etn, logId, 15, "invalid_delivery_method", "delivery method provided is not supported for this site"));
				return;				
			}
			deliveryMethodName = rs.value("displayName");
		}
		if(deliveryType.length() > 0)
		{
			Set rs = Etn.execute("Select * from "+catalogdb+".delivery_methods "+
					" where site_id = "+escape.cote(siteId) + " and method = "+escape.cote(deliveryMethod) + " and subType = "+escape.cote(deliveryType));
			if(!rs.next())
			{
				out.write(getErrorResponse(Etn, logId, 15, "invalid_delivery_type", "delivery type provided is not supported for this site"));
				return;				
			}
		}
		
		String paymentMethod = PortalHelper.parseNull(jRequest.optString("payment_method")).toLowerCase();
		String paymentMethodName = "";
		String paymentStatus = "";
		String paymentTransactionCode = "";
		String externalSystemPaymentId = "";
		if(paymentMethod.length() > 0)
		{
			Set rs = Etn.execute("Select * from "+catalogdb+".payment_methods where site_id = "+escape.cote(siteId) + " and method = "+escape.cote(paymentMethod));
			if(!rs.next())
			{
				out.write(getErrorResponse(Etn, logId, 15, "invalid_payment_method", "payment method provided is not supported for this site"));
				return;				
			}
			paymentMethodName = rs.value("displayName");
			if("cash_on_pickup".equals(paymentMethod) == false && "cash_on_delivery".equals(paymentMethod) == false)
			{
				externalSystemPaymentId = PortalHelper.parseNull(jRequest.optString("payment_id")); 
				paymentTransactionCode = PortalHelper.parseNull(jRequest.optString("payment_txn_reference")); 
				if(paymentTransactionCode.length() > 0)
				{
					paymentStatus = "SUCCESS";
				}
			}
		}
		
		String kycTs = PortalHelper.parseNull(jRequest.optString("kyc_ts"));
		if(kycTs.length() > 0 && isValidDateTime(kycTs) == false)
		{
			out.write(getErrorResponse(Etn, logId, 15, "invalid_datetime_format", "kyc_ts must be of format yyyy-mm-ddThh:mm:ss"));
			return;
		}
		
		if(jRequest.has("products") == false || jRequest.getJSONArray("products").length() == 0)
		{
			out.write(getErrorResponse(Etn, logId, 15, "missing_products", "products array is missing"));
			return;			
		}				
		
		com.etn.asimina.cart.OrderInsertExtraDataImpl oifImplementation = null;
		//for some countries we have vouchers data coming in the json which can be different depending on country so we will implement a class to handle all extra data
		Set rsC = Etn.execute("select * from sites_config where site_id = "+escape.cote(siteId)+" and code = 'ORDER_INSERT_API_EXTRA_PROCESSING_CLS'");
		if(rsC.next() && PortalHelper.parseNull(rsC.value("val")).length() > 0)
		{
			com.etn.asimina.cart.OrderInsertExtraDataFactory oif = new com.etn.asimina.cart.OrderInsertExtraDataFactory(PortalHelper.parseNull(rsC.value("val")));
			oifImplementation = oif.getImplementationClass();			
		}
		
		if(oifImplementation != null)
		{
			String err = oifImplementation.verify(Etn, siteId, jRequest, filesMap);
			if(PortalHelper.parseNull(err).length() > 0)
			{
				out.write(getErrorResponse(Etn, logId, 45, "data_error", err));
				return;				
			}
		}
				
		Map<String, String> variantIds = new HashMap<>();
		JSONArray jProducts = jRequest.getJSONArray("products");
		for(int i=0;i<jProducts.length();i++)
		{
			JSONObject jProduct = jProducts.getJSONObject(i);
			
			if(jProduct.has("sku") == false || jProduct.has("quantity") == false || jProduct.has("price") == false)
			{
				out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", "sku/quantity/price are required for products"));
				return;								
			}
			
			String sku = PortalHelper.parseNull(jProduct.optString("sku"));
			
			Set rsV = Etn.execute("select v.id "+
						" from "+catalogdb+".product_variants v "+
						" join "+catalogdb+".products p on v.product_id = p.id "+
						" join "+catalogdb+".catalogs c on c.id = p.catalog_id "+
						" where c.site_id = "+escape.cote(siteId)+
						" and v.sku = "+escape.cote(sku));
			
			if(rsV.next())
			{
				variantIds.put(sku, rsV.value("id"));
			}
			else
			{
				out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "No product found against sku : "+sku));
				return;								
			}					
			
			int qty = jProduct.getInt("quantity");
			if(qty <= 0)
			{
				out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "product quantity must be greater than 0"));
				return;								
			}
			
			if(jProduct.has("additional_fees"))
			{
				for(int k=0;k<jProduct.getJSONArray("additional_fees").length();k++)
				{
					JSONObject jProductAddFee = jProduct.getJSONArray("additional_fees").getJSONObject(k);					
					String additionaFeeType = PortalHelper.parseNull(jProductAddFee.optString("type"));										
					if("deposit".equals(additionaFeeType) == false && "adv_amt".equals(additionaFeeType) == false && "adv_mnth".equals(additionaFeeType) == false)
					{
						out.write(getErrorResponse(Etn, logId, 15, "invalid_value", "possible values for product additional_fees are deposit/adv_amt/adv_mnth"));
						return;								
					}
					if(jProductAddFee.has("fee") == false || jProductAddFee.has("label") == false)
					{
						out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", "fee and label are required fields for additional_fees object"));
						return;								
					}
				}
			}
			if(jProduct.has("come_withs"))
			{
				for(int k=0;k<jProduct.getJSONArray("come_withs").length();k++)
				{
					if(jProduct.getJSONArray("come_withs").getJSONObject(k).has("sku") == false)
					{
						out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", "sku is required for come_withs object"));
						return;								
					}
				}
			}
			
		}
		
		boolean hasStoreAppointment = false;
		String storeAppointmentTs = PortalHelper.parseNull(jRequest.optString("store_appointment_ts"));
		if(storeAppointmentTs.length() > 0)
		{
			hasStoreAppointment = true;
			if(isValidDateTime(storeAppointmentTs) == false)
			{
				out.write(getErrorResponse(Etn, logId, 15, "invalid_datetime_format", "store_appointment_ts must be of format yyyy-mm-ddThh:mm:ss"));
				return;
			}
		}
				
		Set rsFieldSettings = Etn.execute("select * from api_fields_settings where api_name = "+escape.cote(API_NAME)+" and is_required = 1");
		while(rsFieldSettings.next())
		{
			String mandatoryField = PortalHelper.parseNull(rsFieldSettings.value("field_name"));
			String fType = PortalHelper.parseNull(rsFieldSettings.value("field_type"));
			if(fType.equalsIgnoreCase("string") && PortalHelper.parseNull(jRequest.optString(mandatoryField)).length() == 0)
			{
				out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", mandatoryField + " must be provided"));
				return;
			}
			else if(jRequest.has(mandatoryField) == false)
			{
				out.write(getErrorResponse(Etn, logId, 15, "required_field_missing", mandatoryField + " must be provided"));
				return;
			}
		}		
				
		//all validations passed .. now we can insert order
		
		orderUuid = UUID.randomUUID().toString();
		
		String strAddInfo = "";
		if(additionalFieldsMetaData.size() > 0)
		{
			JSONObject jAddInfo = PortalHelper.LinkedJSONObject("{}");
			if(jRequest.has("additional_info"))
			{
				JSONObject jReqAddInfo = jRequest.getJSONObject("additional_info");
				for(String field : additionalFieldsMetaData.keySet())
				{
					if(jReqAddInfo.has(field))
					{
						jAddInfo = PortalHelper.addAdditionalInfoField(jAddInfo, additionalFieldsMetaData.get(field), jReqAddInfo.getJSONArray(field));					
					}
				}			
			}
			
			//note:cart_additional_info is also hardcoded in dev_shop/customerEdit.jsp
			String additionalInfoUploadFolder = UPLOAD_DIR;
			additionalInfoUploadFolder += "cart_additional_info/";
			dir = new File(additionalInfoUploadFolder);
			if (!dir.exists()) {
				dir.mkdir();
			}
			additionalInfoUploadFolder += orderUuid + "/";
			dir = new File(additionalInfoUploadFolder);
			if (!dir.exists()) {
				dir.mkdir();
			}
			
			String additionalInfoBaseUrl = GlobalParm.getParm("funnel_documents_base_url");
			if(additionalInfoBaseUrl.endsWith("/") == false) additionalInfoBaseUrl += "/";
			additionalInfoBaseUrl += "cart_additional_info/"+orderUuid+"/";
			
			for(String field : additionalInfoFilesMap.keySet())
			{
				AdditionalInfoField aif = additionalFieldsMetaData.get(field);
				JSONArray jValues = PortalHelper.saveAdditionalFileToDisk(additionalInfoUploadFolder, additionalInfoBaseUrl, aif, additionalInfoFilesMap.get(field));
				if(jValues != null) jAddInfo = PortalHelper.addAdditionalInfoField(jAddInfo, aif, jValues);				
			}

			strAddInfo = jAddInfo.toString();
		}		
				
		Set rsM = Etn.execute("select * from site_menus where site_id = "+escape.cote(siteId) + " and lang = " + escape.cote(lang));
		rsM.next();
		String menuUuid = rsM.value("menu_uuid");
		String menuId = rsM.value("id");
		
		String cachedResourcesUrl = PortalHelper.getCachedResourcesUrl(Etn, menuId);
		String cachedResourcesFolder = PortalHelper.getMenuResourcesFolder(Etn, menuId);

		String imageFolder = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + siteId;
		String imageBaseUrl = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId;
		
		if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV")))
		{
			imageFolder = cachedResourcesFolder;
			imageBaseUrl = cachedResourcesUrl;					
		}
		
		if(imageFolder.endsWith("/") == false) imageFolder += "/";
		if(imageBaseUrl.endsWith("/") == false) imageBaseUrl += "/";
		
		String imageUrlPrefix = imageBaseUrl + "img/4x3/";
		String thumbnailUrlPrefix = imageBaseUrl + "img/thumb/";
		
		String imagePathPrefix = imageFolder + "img/4x3/";
		String thumbnailPathPrefix = imageFolder + "img/thumb/";		
		
		Set rsSp = Etn.execute("select * from "+catalogdb+".shop_parameters where site_id = "+escape.cote(siteId));
		rsSp.next();
		String currenyCode = rsSp.value("lang_"+langId+"_currency");
		String priceformatter = rsSp.value("lang_"+langId+"_price_formatter");
		String roundto = PortalHelper.parseNull(rsSp.value("lang_"+langId+"_round_to_decimals"));
		if(roundto.length() == 0) roundto = "0";
		String showdecimals = PortalHelper.parseNull(rsSp.value("lang_"+langId+"_show_decimals"));
		if(showdecimals.length() == 0) showdecimals = "0";
		
		/*String _currency = currenyCode;
		Set rsT = Etn.execute("select LANGUE_"+langId+" from langue_msg where langue_ref = "+escape.cote(currenyCode));
		if(rsT.next())
		{
			_currency = rsT.value("LANGUE_"+langId);
		}*/
		String _currency = getTranslation(Etn, langId, currenyCode);
		Logger.info("apiv2/orders/insert.jsp","Currency code:"+currenyCode+ " currency:"+_currency);
		
		String customername = PortalHelper.parseNull(jRequest.optString("first_name"));
		String customersurname = PortalHelper.parseNull(jRequest.optString("last_name"));
		String clientId = "";
		if(email.length() > 0)
		{
			//check if this email already exists then get that client_uuid
			Set rs = Etn.execute("select * from clients where site_id = "+escape.cote(siteId)+" and email="+escape.cote(email));
			if(rs.next())
			{			
				clientId = rs.value("id");
			}
			else//otherwise insert the client
			{
				Logger.info("apiv2/orders/insert.jsp","Insert new client for email : " + email);
				String client_profil_id = "";
				Set rsClientProfil = Etn.execute("select id from client_profils where is_default=1;");
				if(rsClientProfil.next()) client_profil_id = rsClientProfil.value("id");
				int new_id = Etn.executeCmd("insert into clients (site_id, client_uuid, username, email, pass, name, surname, client_profil_id, signup_menu_uuid) "+
						" values ("+escape.cote(siteId)+", uuid(), "+escape.cote(email)+", "+escape.cote(email)+",'',"+escape.cote(customername)+","+escape.cote(customersurname)+","+escape.cote(client_profil_id)+","+escape.cote(menuUuid)+") ");
				if(new_id>0) 
				{
					clientId = new_id+"";
				}
			}		
		}
				
		Set rsSc = Etn.execute("select * from site_config_process where action = 'confirmation' and site_id = "+escape.cote(siteId));
		rsSc.next();
		String orderPhase = rsSc.value("phase");
		String orderProcess = rsSc.value("process");

		String identityPhotoFileUuid = "";
		if(identityPhotoFile != null && identityPhotoFile.getName().length() > 0)
		{
			String fileName = identityPhotoFile.getName();
			String fileExtension = "";
			int dotIndex = fileName.lastIndexOf(".");
			if (dotIndex > 0 && (dotIndex + 1) < fileName.length()) {
				fileExtension = PortalHelper.parseNull(fileName.substring(dotIndex + 1));
			}                

			identityPhotoFileUuid = java.util.UUID.randomUUID().toString();
			int fileId = Etn.executeCmd("insert into files set file_name="+escape.cote(identityPhotoFile.getName())+" , file_uuid="+escape.cote(identityPhotoFileUuid)+" , file_extension="+escape.cote(fileExtension));
			if(fileId>0){
				File destFile = new File(identityPhotoDir + identityPhotoFileUuid+"."+fileExtension);
				identityPhotoFile.write(destFile);
			}
		}
		
		Logger.info("apiv2/orders/insert.jsp","Inserting order : "+orderUuid);
						
		newOrderId = Etn.executeCmd("insert into "+shopdb+".orders set "+
			" parent_uuid = "+escape.cote(orderUuid)+
			", identityId = "+escape.cote(PortalHelper.parseNull(jRequest.optString("identity_id")))+
			", name = "+escape.cote(customername)+
			", surnames = "+escape.cote(customersurname)+
			", contactPhoneNumber1 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("contact_number")))+
			", nationality = "+escape.cote(PortalHelper.parseNull(jRequest.optString("nationality")))+
			", email = "+escape.cote(email)+
			", identityType = "+escape.cote(PortalHelper.parseNull(jRequest.optString("identity_type")))+
			", total_price = "+escape.cote(totalAmount+"")+
			", tm = "+escape.cote(orderTs)+
			", baline1 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("billing_addr_1")))+
			", baline2 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("billing_addr_2")))+
			", batowncity = "+escape.cote(PortalHelper.parseNull(jRequest.optString("billing_town_city")))+
			", bapostalCode = "+escape.cote(PortalHelper.parseNull(jRequest.optString("billing_postal_code")))+
			", salutation = "+escape.cote(PortalHelper.parseNull(jRequest.optString("civility")))+
			", client_id = "+escape.cote(clientId)+
			", creationDate = "+escape.cote(orderTs)+
			", orderRef = "+escape.cote(orderRef)+
			", lang = "+escape.cote(lang)+
			", order_snapshot = "+PortalHelper.escapeCote2(getOrderSnapshot(Etn, siteId, jRequest, paymentMethodName, deliveryMethodName, paymentFee, deliveryFee, priceformatter, roundto, showdecimals).toString())+
			", daline1 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("delivery_addr_1")))+
			", daline2 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("delivery_addr_2")))+
			", datowncity = "+escape.cote(PortalHelper.parseNull(jRequest.optString("delivery_town_city")))+
			", dapostalCode = "+escape.cote(PortalHelper.parseNull(jRequest.optString("delivery_postal_code")))+
			", menu_uuid = "+escape.cote(menuUuid)+
			", currency = "+escape.cote(_currency)+
			", ip = "+escape.cote(PortalHelper.parseNull(jRequest.optString("ip")))+
			", spaymentmean = "+escape.cote(paymentMethod)+
			", shipping_method_id = "+escape.cote(deliveryMethod)+
			", payment_id = "+escape.cote(externalSystemPaymentId)+
			", payment_status = "+escape.cote(paymentStatus)+
			", payment_txn_id = "+escape.cote(paymentTransactionCode)+
			", payment_fees = "+escape.cote(""+paymentFee)+
			", delivery_fees = "+escape.cote(""+deliveryFee)+
			", orderType = "+escape.cote("Order")+
			", transaction_code = "+escape.cote(paymentTransactionCode)+
			", promo_code = "+escape.cote(PortalHelper.parseNull(jRequest.optString("promo_code")))+
			", identityPhoto = "+escape.cote(identityPhotoFileUuid)+
			", newPhoneNumber = "+escape.cote(PortalHelper.parseNull(jRequest.optString("payment_msisdn")))+
			", selected_boutique = "+PortalHelper.escapeCote2(PortalHelper.parseNull(jRequest.optString("selected_boutique")))+
			", rdv_boutique = "+escape.cote((hasStoreAppointment?"true":"false"))+
			", rdv_date = "+escape.cote(storeAppointmentTs)+
			", delivery_type = "+escape.cote(deliveryType)+
			", site_id = "+escape.cote(siteId)+
			", country = "+escape.cote(PortalHelper.parseNull(jRequest.optString("country")))+
			", currency_code = "+escape.cote(currenyCode)+
			", user_agent = "+escape.cote(PortalHelper.parseNull(request.getHeader("user-agent")))+
			", payment_ref_total_amount = "+escape.cote(totalAmount+"")+
			", cart_type = "+escape.cote(orderType)+
			", payment_is_success = "+escape.cote("SUCCESS".equalsIgnoreCase(paymentStatus)?"1":"0")+
			", additional_info = "+PortalHelper.escapeCote2(strAddInfo)+
			", extra_field_1 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("extra_field_1")))+
			", extra_field_2 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("extra_field_2")))+
			", extra_field_3 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("extra_field_3")))+
			", extra_field_4 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("extra_field_4")))+
			", extra_field_5 = "+escape.cote(PortalHelper.parseNull(jRequest.optString("extra_field_5")))+
			", is_external = "+escape.cote("1"));
			
		//insert order items
		if(newOrderId > 0)
		{
			//insert kyc info if provided
			if(PortalHelper.parseNull(jRequest.optString("kyc_id")).length() > 0)
			{
				Logger.info("apiv2/orders/insert.jsp","Insert kyc info for order id : " + newOrderId);
				Etn.executeCmd("insert into "+shopdb+".order_kyc_info set "+
					" order_id = "+escape.cote(""+newOrderId)+
					", kyc_uid = "+escape.cote(PortalHelper.parseNull(jRequest.optString("kyc_id")))+
					", kyc_resp = "+PortalHelper.escapeCote2(PortalHelper.parseNull(jRequest.optString("kyc_resp")))+
					", kyc_status = "+PortalHelper.escapeCote2(PortalHelper.parseNull(jRequest.optString("kyc_status")))+
					", kyc_ts = "+escape.cote(kycTs));
			}
			
			Logger.info("apiv2/orders/insert.jsp","Order inserted");
			for(int i=0;i<jProducts.length();i++)
			{
				JSONObject jProduct = jProducts.getJSONObject(i);
				
				String sku = PortalHelper.parseNull(jProduct.optString("sku"));				
				String variantId = variantIds.get(sku);
				
				Set rsP = Etn.execute("select p.*, c.name as catalog_name, v.price as variant_price, c.tax_percentage, vd.name as variant_name "+
					" from "+catalogdb+".product_variants v "+
					" left join "+catalogdb+".product_variant_details vd on vd.langue_id = "+escape.cote(langId)+" and vd.product_variant_id = v.id "+
					" join "+catalogdb+".products p on p.id = v.product_id "+
					" join "+catalogdb+".catalogs c on c.id = p.catalog_id "+
					" where v.id = "+escape.cote(variantId));
				rsP.next();				
				
				String catalogName = PortalHelper.parseNull(rsP.value("catalog_name"));
				String productId = PortalHelper.parseNull(rsP.value("id"));
				String productType = PortalHelper.parseNull(rsP.value("product_type"));
				String taxPercentage = PortalHelper.parseNull(rsP.value("tax_percentage"));
				String brandName = PortalHelper.parseNull(rsP.value("brand_name"));
				String productName = PortalHelper.parseNull(rsP.value("lang_"+langId+"_name"));
				String productFullname = productName;
				if(brandName.length() > 0)
				{
					productFullname = PortalHelper.parseNull(getTranslation(Etn, langId, brandName) + " " + productName);
				}
				
				String thumbnailPath = "";
				String thumbnailUrl = "";
				String imageName = "";
				String query = "";
				if(productType.startsWith("offer_"))
				{
					query = " select image_file_name as path, image_label as label from "+catalogdb+".product_images where product_id = " + escape.cote(productId) + " and langue_id = " + escape.cote(langId) + " order by sort_order limit 1; ";
				}
				else
				{
					query = "select * from "+GlobalParm.getParm("CATALOG_DB")+".product_variant_resources where type='image' and product_variant_id="+escape.cote(variantId)+" and langue_id="+escape.cote(langId)+" order by sort_order limit 1";
				}
				
				Set rsVariantImage = Etn.execute(query);
				if(rsVariantImage.next())
				{
					imageName = rsVariantImage.value("path");
					String _version = PortalHelper.getImageUrlVersion(imagePathPrefix + imageName);

					thumbnailPath = thumbnailPathPrefix + imageName;
					thumbnailUrl = thumbnailUrlPrefix + imageName+_version;
				}
				
				Set rsAttributes = Etn.execute(" select ca.name, cav.attribute_value from "+catalogdb+".product_variants pv "+
						" inner join "+catalogdb+".product_variant_ref pvr on pv.id = pvr.product_variant_id "+
						" inner join "+catalogdb+".catalog_attributes ca on pvr.cat_attrib_id = ca.cat_attrib_id "+
						" inner join "+catalogdb+".catalog_attribute_values cav on pvr.catalog_attribute_value_id = cav.id "+
						" where pv.id ="+escape.cote(variantId));
						
				JSONArray attributes = new JSONArray();
				while(rsAttributes.next()){
					JSONObject _attribute = new JSONObject();
					_attribute.put("name", rsAttributes.value(0));
					_attribute.put("value", rsAttributes.value(1));
					attributes.put(_attribute);
				}	
				
				int qty = jProduct.optInt("quantity",0);
				double price = jProduct.optDouble("price",0);
				double priceB4Discount = jProduct.optDouble("price_before_discount",0);
				if(jProduct.has("price_before_discount") == false) priceB4Discount = price;
				
				JSONArray jAdditionalFees = new JSONArray();
				if(jProduct.has("additional_fees"))
				{
					
					for(int k=0;k<jProduct.getJSONArray("additional_fees").length();k++)
					{
						JSONObject jProductAddFee = jProduct.getJSONArray("additional_fees").getJSONObject(k);
						double additionalFee = jProductAddFee.optDouble("fee",0);
						String additionaFeeType = PortalHelper.parseNull(jProductAddFee.optString("type"));
						String additionaFeeName = PortalHelper.parseNull(jProductAddFee.optString("label"));
						
						JSONObject jAddFee = new JSONObject();
						jAddFee.put("price", additionalFee);
						jAddFee.put("rule_apply", additionaFeeType);
						jAddFee.put("name", additionaFeeName);
						jAddFee.put("description", additionaFeeName);
						jAddFee.put("actual_name", additionaFeeName);
						jAdditionalFees.put(jAddFee);
					}
				}
				
				//they wont send any promotions
				JSONObject jPromotions = new JSONObject();
				
				JSONArray jComeWiths = null;
				if(jProduct.has("come_withs"))
				{
					jComeWiths = getComeWiths(Etn, siteId, jProduct.getJSONArray("come_withs"), langId, qty, cachedResourcesUrl, variantId);
				}
				if(jComeWiths == null) jComeWiths = new JSONArray();
				
				
				int commitment = jProduct.optInt("commitment", 0);
				double delvFee = jProduct.optDouble("delivery_fee",0);
				
				JSONObject productSnapshot = new JSONObject();
				productSnapshot.put("price", price+"");
				productSnapshot.put("variantName", PortalHelper.parseNull(rsP.value("variant_name")));
				productSnapshot.put("sku", sku);
				productSnapshot.put("comewithExcluded", "");
				productSnapshot.put("deliveryFeePerItem", delvFee+"");
				productSnapshot.put("attributes", attributes);
				productSnapshot.put("duration", commitment);
				productSnapshot.put("image_name", imageName);
				productSnapshot.put("original_image_path", thumbnailPath);
				productSnapshot.put("original_image_url", thumbnailUrl);				
				
				query = "INSERT INTO "+shopdb+".order_items SET "+
					" product_ref="+escape.cote(PortalHelper.parseNull(variantId))+
					",brand_name="+escape.cote(brandName)+
					",product_full_name="+escape.cote(productFullname)+
					",quantity="+escape.cote(qty+"")+
					",product_name="+escape.cote(PortalHelper.parseNull(rsP.value("lang_"+langId+"_name")))+
					",product_snapshot="+PortalHelper.escapeCote2(productSnapshot.toString())+
					",price="+escape.cote(PortalHelper.formatPrice(priceformatter, roundto, showdecimals, price+"", false))+
					",product_type="+PortalHelper.escapeCote2(productType)+
					",price_value="+escape.cote(price+"")+
					",price_old_value="+escape.cote(priceB4Discount+"")+
					",tax_percentage="+escape.cote(taxPercentage+"")+
					",attributes="+PortalHelper.escapeCote2(attributes.toString())+
					",comewiths="+PortalHelper.escapeCote2(jComeWiths.toString())+
					",additionalfees="+PortalHelper.escapeCote2(jAdditionalFees.toString())+
					",promotion="+PortalHelper.escapeCote2(jPromotions.toString())+
					",parent_id="+escape.cote(orderUuid)+
					",catalog_name="+escape.cote(catalogName);
				
				int oi = Etn.executeCmd(query);
				if(oi > 0)
				{
					Logger.info("apiv2/orders/insert.jsp","SKU : " +sku + " inserted ");
				}
				else
				{
					throw new Exception("Unable to insert product sku : " + sku);
				}
			}

			data.put("order_id", orderUuid);
			
			if(oifImplementation != null)
			{
				boolean bool = oifImplementation.process(Etn, siteId, orderUuid, jRequest, filesMap);
			}
						
			Etn.executeCmd("update "+shopdb+".external_orders_logs set order_uuid = "+escape.cote(orderUuid)+ " where id = "+escape.cote(logId+""));
			
			//we will always insert this order into confirmed phase as we do not have to check for payments at our end
			//payment verification is external system responsibility
			int pwId = Etn.executeCmd("INSERT INTO "+shopdb+".post_work SET client_key="+escape.cote(newOrderId+"")+
						", proces="+escape.cote(orderProcess)+", phase="+escape.cote(orderPhase)+
						", status=0, errCode=0, priority=NOW(), insertion_date=NOW();");
			if(pwId > 0)
			{
				Etn.executeCmd("SELECT semfree("+escape.cote(GlobalParm.getParm("SHOP_SEMAPHORE"))+");");		
			}
			else
			{
				throw new Exception("Unable to insert row in post_work");
			}
		}
	}
	catch(Exception e)
	{
		//lets rollback
		if(newOrderId > 0)
		{
			rollback(Etn, newOrderId, orderUuid);
		}
		
		e.printStackTrace();
		status = 30;
		err_code = "error_executing_request";
		message = e.getMessage();
	}
    
    json.put("status",status);

    if(err_code.length() > 0 && status > 0)
    {
        json.put("err_code",err_code);
        json.put("err_msg",message);
    }
	else
	{
        json.put("data",data);
    }
	
	Etn.executeCmd("update "+GlobalParm.getParm("SHOP_DB")+".external_orders_logs set resp = "+PortalHelper.escapeCote2(json.toString())+" where id = "+escape.cote(""+logId));

    out.write(json.toString());
%>