<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.Contexte, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.ProductImageHelper"%>
<%@ page import="java.text.DecimalFormat"%>
<%@ include file="../lib_msg.jsp"%>
<%@ include file="../cart/commonprice.jsp"%>
<%@ include file="../cart/common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="../cart/imager.jsp"%>

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

    String getStickerClass(String sticker){
        return "Tab-blue";
    }

    int getDefaultVariantId(Contexte Etn,String productId,Language language, String catalogdb){

        int variantId = getNumber(Etn,"select ifnull(min(id),0) from " + catalogdb + ".product_variants where product_id = " + escape.cote(productId) + " and is_default = '1' and is_active = 1");

        if(variantId == 0){

            variantId = getNumber(Etn,"select ifnull(min(v.id),0) from " + catalogdb + ".product_variants v join " + catalogdb + ".product_variant_resources r on v.id = r.product_variant_id and r.langue_id = " + escape.cote(language.getLanguageId()) + " and r.type = 'image' where v.is_active = 1 and product_id = " +  escape.cote(productId));

            if(variantId == 0) 
                variantId = getNumber(Etn,"select ifnull(min(id),0) from " + catalogdb + ".product_variants where is_active = 1 and product_id = " + escape.cote(productId));
        }

        return variantId;
    }

    String getVariantMinPrice(Contexte Etn, TaxPercentage taxpercentage, String productId, String catalogdb, boolean flag){
        
        Set rs = Etn.execute("select pv.id from " + catalogdb + ".product_variants pv, " + catalogdb + ".products p where p.id = pv.product_id and p.id = " + escape.cote(productId) + " and pv.is_active = 1 order by pv.id");

        String variantId = "";
        double price = 0;
        double minPrice = 0;

        if(rs.next()){

            variantId = rs.value("id");
            minPrice = getDouble(getPrice(Etn, variantId, taxpercentage, 1, flag));
        }

        rs.moveFirst();
        while(rs.next()){
            
            variantId = rs.value("id");
            price = getDouble(getPrice(Etn, variantId, taxpercentage, 1, flag));
           
            if(price < minPrice) 
                minPrice = price;

        }

        System.out.println(minPrice);

        return minPrice+"";
    }

    JSONArray getColors(Contexte Etn,String productId, String catalogdb){

        JSONArray colors = new JSONArray();

        Set rs = Etn.execute("select color from " + catalogdb + ".product_attribute_values pv join " + catalogdb + ".catalog_attributes ca on ca.cat_attrib_id = pv.cat_attrib_id and ca.value_type='color' where product_id =  " + escape.cote(productId));

        if(rs != null){

            while(rs.next()){

                colors.put(rs.value("color"));
            }
        }
        return colors;
    }

    JSONObject getProductAttributeValues(Contexte Etn,String catalogId,String productId, String catalogdb){

        JSONObject values = new JSONObject();
        String query = "" + 
                        " select c.cat_attrib_id,GROUP_CONCAT(attribute_value) attribute_values " + 
                        "   from " + catalogdb + ".catalog_attributes c " + 
                        "   left join " + catalogdb + ".product_attribute_values v on c.cat_attrib_id = v.cat_attrib_id and product_id = " + escape.cote(productId) + 
                        "  where catalog_id = " + escape.cote(catalogId) + 
                        "  group by c.cat_attrib_id  ";
        
        Set rs = Etn.execute(query);
        try{

            if(rs != null){
                while(rs.next()){
                    values.put(rs.value("cat_attrib_id"),rs.value("attribute_values").split(","));
                }
            }
        } catch(JSONException ex){
            
            System.out.println(ex.toString());
        }
        return values;
    }
%>

<%
	String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
	String lang = parseNull(request.getParameter("lang"));
	String catalogId = parseNull(request.getParameter("catalog_id"));
	String prefix = getProductColumnsPrefix(Etn, request, lang);

	Language language = LanguageFactory.instance.getLanguage(lang);
	if(language == null){
		out.write("<div style='color:red;font-weight:bold'>Invalid language provided</div>");
		return;
	}

	String langJSONPrefix = "lang" + language.getLanguageId();

	JSONArray products = new JSONArray();
	JSONObject product = new JSONObject();

	String productId = "";
	String summary = "";
	String mainFeatures = "";
	Set rs = Etn.execute("select * from " + catalogdb + ".products where catalog_id = " + escape.cote(catalogId));


	String _currencyfreq = "";
	String currency_frequency = "";
	Set rscat = Etn.execute("select * from "+catalogdb+".catalogs where id = " + escape.cote(catalogId));
	rscat.next();

	boolean pricetaxincluded = ("1".equals(parseNull(rscat.value("price_tax_included")))?true:false);
	boolean showamountwithtax = ("1".equals(parseNull(rscat.value("show_amount_tax_included")))?true:false);

	TaxPercentage taxpercentage = new TaxPercentage();
	taxpercentage.tax = 0;
	taxpercentage.input_with_tax = pricetaxincluded;
	taxpercentage.output_with_tax = showamountwithtax;

	Set rsshop = Etn.execute("select * from "+catalogdb+".shop_parameters where site_id = " + escape.cote(rscat.value("site_id")) );
	rsshop.next();

	String defaultcurrency = parseNull(rsshop.value(prefix + "currency"));

	if(rs != null){

		while(rs.next()){

			product = toJSONObject(rs);
			productId = parseNull(rs.value("id"));
   
			JSONArray images = new JSONArray();
			ProductImageHelper imageHelper = new ProductImageHelper(productId);
			
			if(imageHelper != null){                    

				int variantId = getDefaultVariantId(Etn,productId,language,catalogdb);

				if(variantId > 0){                        

					String query = " select path,label from " + catalogdb + ".product_variant_resources where product_variant_id = " + escape.cote(String.valueOf(variantId)) + " and langue_id = " + escape.cote(language.getLanguageId()) + " and type = 'image' order by sort_order ";
					Set rsImages = Etn.execute(query);
					if(rsImages != null){

						while(rsImages.next()){

							JSONObject image = new JSONObject();
							image.put("image",imageHelper.getBase64Image(getGridImageName(rsImages.value("path"))));
							image.put("label",rsImages.value("label"));
							images.put(image);
						}
					}
				}
			}

			product.put("images",images);

			if(images.length() > 0)
				product.put("image",images.get(0));
			
			product.put("colors",getColors(Etn,productId,catalogdb));

			_currencyfreq = libelle_msg(Etn, request, parseNull(rs.value("currency_frequency")));
			currency_frequency = getcurrencyfrequency(Etn, request, defaultcurrency, _currencyfreq);

			String minPrice = getVariantMinPrice(Etn, taxpercentage, productId, catalogdb, true) + " " + currency_frequency;
			product.put("minPrice",minPrice);

			String originalPrice = getVariantMinPrice(Etn, taxpercentage, productId, catalogdb, false) + " " + currency_frequency;
			product.put("originalPrice",originalPrice);

			double priceNumber = getDouble(minPrice);
			product.put("priceNumber",priceNumber);
			if(priceNumber < getDouble(minPrice)){
				minPrice = ""+priceNumber;
			}

			JSONObject attributeValues = getProductAttributeValues(Etn,catalogId,productId,catalogdb);

			product.put("attributeValues",attributeValues);
			product.put("psubtitle", langJSONPrefix);

			products.put(product);
		}
	}

	out.write(products.toString());
%>