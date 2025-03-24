<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.beans.Contexte"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>
<%@ page import="com.etn.asimina.util.UrlHelper"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.ProductImageHelper, com.etn.asimina.util.CatalogEssentialsImageHelper"%>

<%@ include file="WEB-INF/include/lib_msg.jsp"%>
<%@ include file="WEB-INF/include/imager.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="priceformatter.jsp"%>

<%!

    class ProductResponse{
        JSONArray products;
        JSONArray clientSideProducts;
        String minPrice;
        String maxPrice;
        ProductResponse(JSONArray products,JSONArray clientSideProducts,String minPrice, String maxPrice){
            this.products = products;
            this.clientSideProducts = clientSideProducts;
            this.minPrice = minPrice;
            this.maxPrice = maxPrice;
        }
    }
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
        return "Tab-orange";
    }

    int getDefaultVariantId(Contexte Etn,String productId,Language language){
        int variantId = getNumber(Etn,"select ifnull(min(id),0) from product_variants where product_id = " + escape.cote(productId) + " and is_active = '1' and is_default = '1' ");
        if(variantId == 0){
            variantId = getNumber(Etn,"select ifnull(min(v.id),0) from product_variants v join product_variant_resources r on v.id = r.product_variant_id and r.langue_id = " + escape.cote(language.getLanguageId()) + " and r.type = 'image' where is_active = '1' and product_id = " +  escape.cote(productId));
            if(variantId == 0){
                variantId = getNumber(Etn,"select ifnull(min(id),0) from product_variants where is_active = '1' and product_id = " + escape.cote(productId));
            }
        }
        return variantId;
    }

    JSONArray getColors(Contexte Etn, String catalogId, String productId){

        JSONArray colors = new JSONArray();
        String color = "";
        String catAttribId = "";

        Set attrRs = Etn.execute("SELECT cat_attrib_id FROM catalog_attributes WHERE catalog_id = " + escape.cote(catalogId) + " and value_type = 'color'");

        if(attrRs.next()){

            catAttribId = parseNull(attrRs.value("cat_attrib_id"));
        }

        String query = "SELECT color, catalog_attribute_value_id, pvr.cat_attrib_id FROM product_variants pv, product_variant_ref pvr  LEFT JOIN catalog_attribute_values cv ON cv.id = pvr.catalog_attribute_value_id AND cv.cat_attrib_id = pvr.cat_attrib_id WHERE pvr.product_variant_id = pv.id AND pv.is_active = '1' AND pvr.cat_attrib_id = " + escape.cote(catAttribId) + " AND pv.product_id = " + escape.cote(productId) + " GROUP BY catalog_attribute_value_id, color ORDER BY pv.id";

        Set rs = Etn.execute(query);

        if(rs != null){

            boolean flag = false;

            while(rs.next() && !flag){

                if(parseNull(rs.value("cat_attrib_id")).equalsIgnoreCase(catAttribId) && parseNull(rs.value("catalog_attribute_value_id")).equals("0"))
                    flag = true;
            }

            if(!flag){

                rs.moveFirst();

                while(rs.next()){
                    color = parseNull(rs.value("color"));
                    colors.put(color);
                }
            }
        }

        return colors;
    }

    String getProductSummary(Contexte Etn, String productId, String lang){

        String summary = "";
        Set rs = Etn.execute("select summary from product_descriptions where product_id = " + escape.cote(productId) + " and langue_id = " + escape.cote(lang));

        if(rs != null && rs.next()){
            summary = rs.value("summary");
        }
        return summary;
    }

    String getProductMainFeatures(Contexte Etn, String productId, String lang){

        String mainFeatures = "";
        Set rs = Etn.execute("select main_features from product_descriptions where product_id = " + escape.cote(productId) + " and langue_id = " + escape.cote(lang));

        if(rs != null && rs.next()){
            mainFeatures = rs.value("main_features");
        }
        return mainFeatures;
    }

    String getEnableProductAttributeValues(Contexte Etn, String productId, String catalogId){

        String values = "";
        String attrValues = "";
        String query = "" +
                        " select c.cat_attrib_id, attribute_value " +
                        " from catalog_attributes c  " +
                        " join product_attribute_values v on c.cat_attrib_id = v.cat_attrib_id and product_id = " + escape.cote(productId) +
                        " where type = 'specs' and catalog_id = " + escape.cote(catalogId) + " and is_searchable = 1 ";

        Set rs = Etn.execute(query);


        if(rs != null){

            while(rs.next()){

                attrValues = "";
                attrValues = parseNull(rs.value("attribute_value").toLowerCase());

                if(attrValues.length() > 0) attrValues = attrValues.substring(0, 1).toUpperCase() + attrValues.substring(1);

                values += "product-attr-val-" + rs.value("cat_attrib_id") + "-" + EscapeCoteJava(removeAccents(attrValues)) + " ";
            }
        }

        return values;
    }

    JSONObject getProductAttributeValues(Contexte Etn,String catalogId,String productId){

        JSONObject values = new JSONObject();
        String attrValues = "";
        String query = "" +
                        " select c.cat_attrib_id,GROUP_CONCAT(attribute_value) attribute_values " +
                        "   from catalog_attributes c " +
                        "   left join product_attribute_values v on c.cat_attrib_id = v.cat_attrib_id and product_id = " + escape.cote(productId) +
                        "  where catalog_id = " + escape.cote(catalogId) +
                        "  group by c.cat_attrib_id  ";
        Set rs = Etn.execute(query);

        if(rs != null){

            while(rs.next()){

                attrValues = "";
                attrValues = parseNull(rs.value("attribute_values").toLowerCase());

                if(attrValues.length() > 0) attrValues = attrValues.substring(0, 1).toUpperCase() + attrValues.substring(1);

                values.put(rs.value("cat_attrib_id"),attrValues.split(","));
            }
        }

        return values;
    }

    JSONArray getSpecs(Contexte Etn,String catalogId){
        JSONArray specs = new JSONArray();
        String attrValues = "";
        String query = "" +
            " select a.cat_attrib_id,name,v.attribute_value,count(0) num from catalog_attributes a " +
            "  join product_attribute_values v on a.cat_attrib_id = v.cat_attrib_id " +
            " where catalog_id = " + escape.cote(catalogId) + " and type = 'specs' and is_searchable = '1'" +
            " and v.attribute_value is not null and v.attribute_value != '' " +
            " group by cat_attrib_id,name,v.attribute_value " +
            " order by name, attribute_value ";

        Set rs = Etn.execute(query);
        if(rs != null){
            JSONObject spec = null;
            while(rs.next()){
                String catalogAttributeId = rs.value("cat_attrib_id");
                if(spec == null || !spec.getString("catalogAttributeId").equals(catalogAttributeId)){
                    spec = new JSONObject();
                    spec.put("catalogAttributeId",catalogAttributeId);
                    spec.put("name",rs.value("name"));
                    spec.put("values",new JSONArray());
                    spec.put("specTotalCount",0);
                    specs.put(spec);
                }
                JSONObject value = new JSONObject();

                attrValues = "";
                attrValues = parseNull(rs.value("attribute_value").toLowerCase());

                if(attrValues.length() > 0) attrValues = attrValues.substring(0, 1).toUpperCase() + attrValues.substring(1);

                value.put("value",attrValues);
                value.put("count",rs.value("num"));
                spec.put("specTotalCount",spec.getInt("specTotalCount") + Integer.parseInt(rs.value("num")));
                spec.getJSONArray("values").put(value);
            }
        }
        return specs;
    }

    String getMinPrice(Contexte Etn,String productId){
        String price = "";
        Set rs = Etn.execute("select ifnull(min(price),0) price from product_variants where is_active = '1' and product_id = " + escape.cote(productId));
        if(rs != null && rs.next()){
            price = rs.value("price");
        }
        return price;
    }

    ProductResponse getProducts(Contexte Etn,String catalogId,Language lang, String tagId, String siteId)
	{
        JSONArray products = new JSONArray();
        JSONArray clientSideProducts = new JSONArray();
        String minPrice = "";
        String maxPrice = "";
        String summary = "";
        String mainFeatures = "";

		String qry = "select p.*, concat(max(pv.created_on),'') as recent_created_on, concat(max(p.first_publish_on),'') as first_publish_date ";
		qry += " from products p, product_variants pv ";
		if(tagId.length() > 0) qry += ", product_tags pt";
		qry += " where p.id = pv.product_id and catalog_id = " + escape.cote(catalogId) + " and is_active = '1' ";
		if(tagId.length() > 0) qry += " and pt.product_id = p.id and pt.tag_id = " + escape.cote(tagId);
		qry += " group by p.id order by COALESCE(max(p.first_publish_on), max(pv.created_on)) desc, order_seq, id; ";

        Set rs = Etn.execute(qry);
        if(rs != null){
            while(rs.next()){
                JSONObject product = toJSONObject(rs);
                String productId = rs.value("id");
                String createdOn = parseNull(rs.value("recent_created_on"));
                String orderSeq = parseNull(rs.value("order_seq"));
                String firstPublishOn = parseNull(rs.value("first_publish_date"));

                if(firstPublishOn.length() > 0)
                    createdOn = firstPublishOn;

                JSONArray images = new JSONArray();
                ProductImageHelper imageHelper = new ProductImageHelper(productId);

                int variantId = getDefaultVariantId(Etn,productId,lang);
                if(variantId > 0){

                    String query = " select actual_file_name,path,label from product_variant_resources where product_variant_id = " + escape.cote(String.valueOf(variantId)) + " and langue_id = " + escape.cote(lang.getLanguageId()) + " and type = 'image' order by sort_order; ";

                    Set rsImages = Etn.execute(query);
                    String imagePathPrefix = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + siteId + "/img/4x3/";
                    String imageUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/4x3/";
                    if(rsImages != null){
                        while(rsImages.next()){
                            String esImageActualName = rsImages.value("actual_file_name");
                            Set rsMedia = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".files where file_name="+escape.cote(esImageActualName)+
                                " and site_id="+escape.cote(siteId)+" and (COALESCE(removal_date,'') = '' or  removal_date>now())");
                            if(rsMedia.rs.Rows>0){
                                JSONObject image = new JSONObject();

                                String imageName = rsImages.value("path");
                                String imagePath = imagePathPrefix + imageName;
                                String imageUrl = imageUrlPrefix + imageName;
                                String _version = getImageUrlVersion(imagePath);

                                image.put("image",imageUrl + _version);
                                image.put("label",rsImages.value("label"));
                                images.put(image);
                            }else{
                                System.out.println("Not Displaying=================="+rsImages.value("label"));
                            }
                        }
                    }
                }
                product.put("images",images);
                if(images.length() > 0){
                    product.put("image",images.get(0));
                }

                product.put("colors",getColors(Etn, catalogId, productId));
                String price = getMinPrice(Etn,productId);
                product.put("minPrice",price);
                String priceNumber = price;
                product.put("priceNumber",priceNumber);
                if(getDouble(priceNumber) < getDouble(minPrice)){
                    minPrice = priceNumber;
                }
                if(getDouble(priceNumber) > getDouble(maxPrice)){
                    maxPrice = priceNumber;
                }

                JSONObject attributeValues = getProductAttributeValues(Etn, catalogId, productId);
                summary = getProductSummary(Etn, productId, lang.getLanguageId());
                mainFeatures = getProductMainFeatures(Etn, productId, lang.getLanguageId());

                product.put("attributeValues",attributeValues);
                product.put("enabledAttributeValues", getEnableProductAttributeValues(Etn, productId, catalogId));
                product.put("summary", summary);
                product.put("main_features", mainFeatures);
                product.put("promotion_sort_seq", "");
                products.put(product);

                JSONObject clientSideProduct = new JSONObject();
                clientSideProduct.put("id",productId);
                clientSideProduct.put("created_on",createdOn);
                clientSideProduct.put("priceNumber",priceNumber);
                clientSideProduct.put("order_seq",orderSeq);
                clientSideProduct.put("attributeValues",attributeValues);
                clientSideProducts.put(clientSideProduct);

            }
        }

        return new ProductResponse(products,clientSideProducts,minPrice,maxPrice);
    }

    String EscapeCoteJava(String str) {

        String s = str.replaceAll("'", "\\\\'");
        s = s.replaceAll("\"", "\\\\'");
        return s;
    }

%>

<%
	//in case of test environment we will add T otherwise this tag will be empty because this tag is not added by pages module
	//so to avoid change in it we add Test environment identifier
	String env = "";
	if(parseNull(GlobalParm.getParm("IS_PROD_ENVIRONMENT")).equals("0")) env = "T";
	Set rsPortalConfig = Etn.execute("Select * from "+GlobalParm.getParm("PORTAL_DB")+".config where code = 'EXTERNAL_LINK'");
	rsPortalConfig.next();
	String portalExternalLink = rsPortalConfig.value("val");
	if(portalExternalLink.endsWith("/") == false) portalExternalLink += "/";

    String lang = parseNull(request.getParameter("lang"));
    String catalogId = parseNull(request.getParameter("cat"));
    String tagId = parseNull(request.getParameter("tagid"));

    Set rscat = Etn.execute("select * from catalogs where id = " + escape.cote(catalogId));
    if(rscat==null || rscat.rs.Rows == 0 || !rscat.next())
    {
        out.write("<div style='color:red;font-weight:bold'>No catalog provided</div>");
        return;
    }

    String siteId = parseNull(rscat.value("site_id"));
	Set rsSite = Etn.execute("Select * from "+GlobalParm.getParm("PORTAL_DB")+".sites where id = "+escape.cote(siteId));
	rsSite.next();

    Language language = LanguageFactory.instance.getLanguage(lang);
    if(language == null){
        language = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,siteId).get(0);
        lang = language.getCode();
    }
    
    set_lang(lang, request, Etn);

    String langColPrefix  = "lang_" + language.getLanguageId() + "_" ;
    String langJSONPrefix = "lang" + language.getLanguageId();

    boolean ecommerceEnabled = isEcommerceEnabled(Etn, siteId);

    String pageHeading = parseNull(rscat.value(langColPrefix + "heading"));
    String metakeywords = parseNull(rscat.value(langColPrefix + "meta_keywords"));
    String metadescription = parseNull(rscat.value(langColPrefix + "meta_description"));
    String essentialsAlignment = parseNull(rscat.value("essentials_alignment_lang_" + language.getLanguageId()));
    String catalogType = parseNull(rscat.value("catalog_type"));
    String catalogDefaultSort = parseNull(rscat.value("default_sort"));
    String html_variant = parseNull(rscat.value("html_variant"));

    String filterResultMessage = libelle_msg(Etn, request, "produit(s) correspondant à votre recherche");
    if("device".equals(catalogType)) filterResultMessage = libelle_msg(Etn, request, "résultat(s) correspondant à votre recherche");
    ProductResponse productResponse = getProducts(Etn,catalogId,language, tagId, siteId);

	String tagLabel = "";
	if(tagId.length() > 0)
	{
		Set rsTag = Etn.execute("select * from tags where site_id = "+escape.cote(siteId)+" and id = "+escape.cote(tagId));
		if(rsTag.next()) tagLabel = parseNull(rsTag.value("label"));
	}

    JSONArray products = productResponse.products;


    int numberOfProducts = products.length();

    JSONArray brands = toJSONArray(Etn,"select ifnull(brand_name,'') brand_name,count(0) number_of_products from products where catalog_id = " + escape.cote(catalogId) + " group by ifnull(brand_name,'') ");

    JSONArray specs = getSpecs(Etn,catalogId);

    Set rsShop = Etn.execute("select * from shop_parameters  where site_id = " + escape.cote(siteId));
    String currencyLanguage = "";

    if(rsShop.next()){

        Set rsLang = Etn.execute("select langue_" + language.getLanguageId() + " as lang_currency from langue_msg where LANGUE_REF = "+escape.cote(rsShop.value(langColPrefix + "currency")));

        if(rsLang.next()){

            currencyLanguage = parseNull(rsLang.value("lang_currency"));
        }

        if(currencyLanguage.length() == 0){

            currencyLanguage = parseNull(rsShop.value(langColPrefix + "currency"));
        }
    }

    String pagePath = "";
    String canonicalUrl = "";
    Set rsDescription  = Etn.execute("Select * from catalog_descriptions where langue_id = "+escape.cote(language.getLanguageId())+" and catalog_id = " + escape.cote(catalogId));
    if(rsDescription.next()){
        pagePath = parseNull(rsDescription.value("page_path"));
        canonicalUrl = parseNull(rsDescription.value("canonical_url"));
    }
	if(tagId.length() > 0 && tagLabel.length() > 0)
	{
		pagePath += "/" + ((UrlHelper.removeSpecialCharacters(UrlHelper.removeAccents(tagLabel))).replace("--","-")).toLowerCase();
	}
    if(pagePath.length() > 0) pagePath += ".html";

%>
<!DOCTYPE html>
<html lang="<%=parseNull(language.getCode())%>" dir="<%=language.getDirection()%>">
<head>
    <meta charset="UTF-8">
    <!--[if IE]>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/><![endif]-->
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <% if(parseNull(metakeywords).length() > 0) { %>
        <meta name="keywords" content="<%=metakeywords.replace("\"","&quot;")%>">
    <% } %>
    <% if(parseNull(metadescription).length() > 0) { %>
        <meta name="description" content="<%=metadescription.replace("\"","&quot;")%>">
    <% } %>
    <meta name="title" content="<%=pageHeading.replaceAll("\"","&quot;")%>">
    <meta name="etn:pname" content="<%=pageHeading.replaceAll("\"","&quot;")%>">

	<%if(env.length() > 0){ %>
		<meta name="etn:eleenv" content="<%=env%>">
	<% } %>

    <% if(pagePath.length() > 0) {
        String html_variant_path = "";
        if(html_variant.equals("logged"))
            html_variant_path =  html_variant+"/";
    %>
        <meta name="etn:eleurl" content="<%=html_variant_path%><%=pagePath.replaceAll("\"","&quot;")%>">
    <% } %>

    <% if(canonicalUrl.length() > 0) { %>
        <link rel="canonical" href="<%=canonicalUrl%>" />
    <% } %>
	
	<meta name="etn:eletype" content="commercialcatalog">
	<meta name="etn:eleid" content="<%=catalogId%>">

    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/newui/style<%=language.getDirection()%>.css">
    <title><%=pageHeading%></title>

	<script type="text/javascript">
		var asmPageInfo = asmPageInfo || {};
		asmPageInfo.apiBaseUrl = "<%=portalExternalLink%>";
		asmPageInfo.clientApisUrl = "<%=portalExternalLink%>clientapis/";
		asmPageInfo.expSysUrl = "<%=GlobalParm.getParm("EXP_SYS_EXTERNAL_URL")%>";
		asmPageInfo.environment = "<%=(env.equals("")?"P":env)%>";
		asmPageInfo.suid = "<%=rsSite.value("suid")%>";
		asmPageInfo.lang = "<%=lang%>";
	</script> 	
</head>
<body>
    <div class="PageTitle">
        <div class="container">
            <h1 class="h1-like"><%=pageHeading%></h1>
        </div>
    </div>
    <div style="display: none;" class="BannerImage">
        <div class="pageStyle-hr-line"></div>
        <div class="container">
            <img src="<%=request.getContextPath()%>/assets/examples/promotion-banner.png" alt="">
        </div>
    </div>

    <div class="TerminauxList">
        <div>
            <div class="container">
                <div class="TerminauxList-filters">
                    <select class="custom-select" onchange="sortDevices(this.value)">
                        <option class="etn-data-layer-event"  data-dl_event_category="device_list" data-dl_event_action="choice_click" data-dl_event_label="promotion" value="promotion" <%=catalogDefaultSort.equals("promotion")?"selected":""%> ><%=libelle_msg(Etn, request, "Promotions")%></option>
                        <option class="etn-data-layer-event"  data-dl_event_category="device_list" data-dl_event_action="choice_click" data-dl_event_label="new" value="new" <%=catalogDefaultSort.equals("new")?"selected":""%> ><%=libelle_msg(Etn, request, "Nouveautés")%></option>
                        <option class="etn-data-layer-event"  data-dl_event_category="device_list" data-dl_event_action="choice_click" data-dl_event_label="low" value="low" <%=catalogDefaultSort.equals("low")?"selected":""%> ><%=libelle_msg(Etn, request, "Prix croissants")%></option>
                        <option class="etn-data-layer-event"  data-dl_event_category="device_list" data-dl_event_action="choice_click" data-dl_event_label="high" value="high" <%=catalogDefaultSort.equals("high")?"selected":""%> ><%=libelle_msg(Etn, request, "Prix décroissants")%></option>
                        <option class="etn-data-layer-event"  data-dl_event_category="device_list" data-dl_event_action="choice_click" data-dl_event_label="all" value="all" <%=catalogDefaultSort.equals("all")?"selected":""%> ><%=libelle_msg(Etn, request, "Tous les produits")%></option>
                    </select>
                    <button type="button" class="btn btn-secondary mx-1" id="productFilter" onclick="javascript:if(typeof ___pushDataLayerEvent !== 'undefined') ___pushDataLayerEvent(this);"  data-dl_event_category="catalog_page" data-dl_event_action="button_click" data-dl_event_label="<%=com.etn.asimina.util.UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Filtrer"))%>">
                        <span data-svg="<%=request.getContextPath()%>/assets/icons/icon-filter.svg"></span>
                        <%=libelle_msg(Etn, request, "Filtrer")%>
                    </button>
                </div>
                <h2 class="TerminauxList-title"><%=parseNull(rscat.value(langColPrefix + "description"))%></h2>
                <div class="TerminauxList-results-count"><span><%=numberOfProducts%> <%=libelle_msg(Etn, request, "résultat(s)")%></span> </div>
                <div class="row TerminauxList-list terminaux">
                    <%
                    for(Object productObj : products){
                        JSONObject product = (JSONObject) productObj;
                    %>
                    <div id='product<%=product.getString("id")%>' class="col-sm-12 col-md-6 col-lg-4 etn-dl-product-impression etn-products-list TerminauxList-listItemsColumn <%= product.getString("enabledAttributeValues")%>"> <!--SINGLE PRODUCT-->
                        <div class="Tab Tab-Hidden">
                            <div class="Tab-left">
                                <div style="display: none;" class="Tab-icon" data-svg="<%=request.getContextPath()%>/assets/icons/icon-timer.svg"></div>
                                <span class="Tab-left-offer"></span>
                                <div class="Tab-triangle"></div>
                            </div>
                            <div style="display: none" class="Tab-right promotion-sale-active">
                                <div class="Counter" data-timestamp="1571403990">
                                    <div class="Counter-display Counter-days">00</div>
                                    <div class="Counter-separator">:</div>
                                    <div class="Counter-display Counter-hours">00</div>
                                    <div class="Counter-separator">:</div>
                                    <div class="Counter-display Counter-minutes">00</div>
                                    <div class="Counter-separator">:</div>
                                    <div class="Counter-display Counter-seconds">00</div>
                                    <div class="Counter-hline"></div>
                                </div>
                            </div>
                        </div>
                        <a href="product.jsp?id=<%=product.getString("id")%>" class="TerminauxItem">
                            <div class="col-wrapper">
                                <div class="col-custom">
                                    <div class="Terminaux-imageWrapper Image-ratio43">
                                        <div class="Image-wrapper">
                                            <%if(product.has("image") && product.getJSONObject("image").getString("image").length() > 0){%>
                                            <img src="<%=product.getJSONObject("image").getString("image")%>" alt="<%=product.getJSONObject("image").getString("label")%>">
                                            <%}else{%>
                                            <img src="data:image/png;base64,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" alt="">
                                            <%}%>
                                        </div>
                                    </div>

                                </div>
                                <div class="col-custom">
                                    <div class="TerminauxItem-title"><%=libelle_msg(Etn, request, product.getString("brandName"))%></div>
                                    <div class="TerminauxItem-subtitle"><%=product.getString(langJSONPrefix + "Name")%></div>
                                    <div class="TerminauxItem-price">
                                        <div class="TerminauxItem-price-title"><%=libelle_msg(Etn, request, "Prix seul")%></div>
                                        <div class="TerminauxItem-price-amount"></div>
                                        <div class="TerminauxItem-price-crossed">
                                            <del></del>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="ColorChart">
                                <div class="ColorChart-left">
                                    <%
                                    if(product.getJSONArray("colors").length() > 0){
                                        for(Object colorObj : product.getJSONArray("colors")){
                                            String color = (String) colorObj;

                                    %>
                                    <div style="z-index: 5; background-color: <%=color%>" class="ColorChart-colorCircle"></div>
                                    <%}
                                    }else{%>
                                    <div style="z-index: 5; background-color: #FFF"></div><!-- just to take up space-->
                                    <%}%>
                                </div>
                                <%
                                    if(product.getJSONArray("colors").length() > 1){
                                %>
                                        <div class="ColorChart-right"><%=product.getJSONArray("colors").length()%> <%=libelle_msg(Etn, request, "couleurs disponibles")%></div>
                                <%
                                    } else if(product.getJSONArray("colors").length() == 1) {
                                %>
                                        <div class="ColorChart-right"><%=product.getJSONArray("colors").length()%> <%=libelle_msg(Etn, request, "couleur disponible")%></div>
                                <%
                                    }
                                %>
                            </div>
							<div id='productcomewith_<%=product.getString("id")%>' style="display:none">
							<div class="TerminauxItem-payback">
                                <div class="TerminauxItem-payback-colL">
                                </div>
                                <div class="TerminauxItem-payback-colR"></div>
                            </div>
							</div>
                        </a>
                    </div><!--SINGLE RRODUCT-->
                    <%}%>
                </div><!--RRODUCT LIST-->
                <div class="TerminauxList-bottom">
                    <button type="button" class="btn btn-secondary TerminauxList-showMore terminaux etn-data-layer-event"  data-dl_event_category="device_list" data-dl_event_action="button_click" data-dl_event_label='<%=com.etn.asimina.util.UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Afficher plus de résultats"))%>'><%=libelle_msg(Etn, request, "Afficher plus de résultats")%></button>
                </div>
            </div>
        </div>
    </div>

    <%
        Set rsEssentials = Etn.execute("select * from catalog_essential_blocks where catalog_id=" + escape.cote(catalogId) + " and langue_id = " + escape.cote(language.getLanguageId()) + " order by order_seq;");

        if(rsEssentials.rs.Rows!=0){

    %>
    <div class="Essentiel">
        <div class="container">
            <h2><%=libelle_msg(Etn, request, "L'essentiel")%></h2>

            <div class="Essentiel-swiper swiper-container">
                <div class="Essentiel-list swiper-wrapper">
                <%
                    String essentialsAlign = "";

                    if(essentialsAlignment.contains("_right")) essentialsAlign = "align-reverse";

                    while(rsEssentials.next()){
                        String esImageActualName = rsEssentials.value("actual_file_name");
                        Set rsMedia = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".files where file_name="+escape.cote(esImageActualName)+
                            " and site_id="+escape.cote(siteId)+" and (COALESCE(removal_date,'') = '' or  removal_date>now())");

                        if(rsMedia.rs.Rows>0){
                            String esImageName = rsEssentials.value("file_name");
                            String esImageUrl = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/" + esImageName;
                %>
                            <div class="Essentiel-item swiper-slide <%=essentialsAlign%>">
                                <div class="Essentiel-photo">
                                    <img src="<%=esImageUrl%>" alt="<%=rsEssentials.value("image_label")%>">
                                </div>
                                <div class="Essentiel-content">
                                    <%=rsEssentials.value("block_text")%>
                                </div>
                            </div>

                <%
                            if(essentialsAlignment.startsWith("zig_zag")){
                                if(essentialsAlign.equals("")) essentialsAlign = "align-reverse";
                                else essentialsAlign = "";
                            }
                        }
                    }
                %>
                </div>
            </div>

            <div class="swiper-pagination"></div>
        </div>
    </div>
    <%}%>

    <div class="container" id="pricestaxlabeldiv" style="display:none">
        <div class="pageStyle-hr-line"></div>
        <div class="prixTaxesComprises">
            <div class="btn-50 right" id="pricestaxincludediv" style="display:none"><%=libelle_msg(Etn, request, "Prix toutes taxes comprises")%></div>
            <div class="btn-50 right" id="pricestaxexclusivediv" style="display:none"><%=libelle_msg(Etn, request, "Les prix sont affichés hors taxes")%></div>
        </div>
    </div>
    <div class="container">
        <div class="pageStyle-hr-line"></div>
    </div>
    <div class="WindowFilter-container">
        <div class="WindowFilter">
            <form>
                <div class="WindowFilter-topContainer">
                    <div class="WindowFilter-header">
                        <div class="WindowFilter-header-backBtn">
                            <span data-svg="<%=request.getContextPath()%>/assets/icons/icon-angle-left.svg"></span>
                            <%=libelle_msg(Etn, request, "Retour")%>
                        </div>
                        <div class="WindowFilter-header-text"><span id="spanNumberOfProducts"><%=numberOfProducts%></span> <%=filterResultMessage%></div>
                    </div>
                    <div class="WindowFilter-body">
                        <div class="WindowFilter-body-scrollable">
                            <div class="WindowFilter-price">
                                <div class="WindowFilter-price-title"><%=libelle_msg(Etn, request, "Prix")%></div>
                                <div class="WindowFilter-price-form">
                                    <div class="price-inputs">
                                        <div class="form-row">
                                            <span><%=libelle_msg(Etn, request, "À partir de")%></span>
                                            <div class="form-group col-12">
                                                <label for="inputPriceMin"><%=currencyLanguage%></label>
                                                <input type="text" class="form-control form-control" id="inputPriceMin" placeholder="<%=productResponse.minPrice%>" value="<%=productResponse.minPrice%>">
                                            </div>
                                        </div>
                                        <div class="form-row">
                                            <span><%=libelle_msg(Etn, request, "Jusqu’à")%></span>
                                            <div class="form-group col-12">
                                                <label for="inputPriceMax"><%=currencyLanguage%></label>
                                                <input type="text" class="form-control" id="inputPriceMax"  placeholder="<%=productResponse.maxPrice%>" value="<%=productResponse.maxPrice%>">
                                            </div>
                                        </div>
                                        <div class="WindowFilter-range" id="windowFilter-range"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="accordion WindowFilter-accordion" id="accordionFilters">
                                <%
                                for(Object specObj : specs){
                                    JSONObject spec = (JSONObject) specObj;
                                    String catalogAttributeId = spec.getString("catalogAttributeId");
                                %>
                                <div class="card div-search-catalog-attribute" data-catalog-attribute-id="<%=catalogAttributeId%>">
                                    <div class="card-header" id="headingSpec<%=catalogAttributeId%>">
                                        <h2 class="mb-0">
                                            <button class="btn btn-link" type="button" data-toggle="collapse"
                                                    data-target="#collapseSpec<%=catalogAttributeId%>"
                                                    aria-expanded="false" aria-controls="collapseSpec<%=catalogAttributeId%>">
                                                <%=libelle_msg(Etn,request,spec.getString("name"))%>
                                            </button>
                                        </h2>
                                    </div>
                                    <div id="collapseSpec<%=catalogAttributeId%>" class="collapse" aria-labelledby="headingSpec<%=catalogAttributeId%>"
                                         data-parent="#accordionFilters">
                                        <div class="card-body">
                                            <ul>
                                                <%for(Object valueObj : spec.getJSONArray("values")){
                                                    JSONObject value = (JSONObject) valueObj;
                                                %>
                                                <li class="li-search-catalog-attribute" onclick="modifySearch();" data-catalog-attribute-id="<%=catalogAttributeId%>" data-attribute-value="<%=EscapeCoteJava(removeAccents(value.getString("value")))%>">
                                                    <label class="custom-control custom-checkbox">
                                                        <input class="custom-control-input" name="brand" type="checkbox" data-catalog-attribute-checked="checked">
                                                        <span class="custom-control-label"></span>
                                                        <span class="custom-control-description"><%=libelle_msg(Etn,request,value.getString("value"))%> (<%=value.getString("count")%>)</span>
                                                    </label>
                                                </li>
                                                <%
                                                }
                                                if(numberOfProducts - spec.getInt("specTotalCount") > 0){
                                                %>
                                                <li class="li-search-catalog-attribute d-none" data-catalog-attribute-id="<%=catalogAttributeId%>" data-attribute-value="" onclick="modifySearch();">
                                                    <label class="custom-control custom-checkbox">
                                                        <input class="custom-control-input" name="brand" type="checkbox" data-catalog-attribute-checked="checked" >
                                                        <span class="custom-control-label"></span>
                                                        <span class="custom-control-description">[<%=libelle_msg(Etn,request,"None")%>] (<%=numberOfProducts - spec.getInt("specTotalCount")%>)</span>
                                                    </label>
                                                </li>
                                                <%}%>
                                            </ul>

                                        </div>
                                    </div>
                                </div>
                                <%}%>
                            </div>

                            <div class="WindowFilter-buttons">
                                <button type="button" class="btn btn-secondary etn-data-layer-event"  data-dl_event_category="filter_menu" data-dl_event_action="button_click" data-dl_event_label='<%=com.etn.asimina.util.UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Effacer"))%>' onclick="cancelSearch();"><%=libelle_msg(Etn, request, "Effacer")%></button>
                                <button type="submit" class="btn btn-primary etn-data-layer-event"  data-dl_event_category="filter_menu" data-dl_event_action="button_click" data-dl_event_label='<%=com.etn.asimina.util.UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Appliquer"))%>' ><%=libelle_msg(Etn, request, "Appliquer")%></button>
                            </div>
                        </div>
                        <div class="WindowFilter-body-gradientTop"></div>
                        <%-- <div class="WindowFilter-body-gradientBottom"></div> --%>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <symbol id="icon-star" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.ast0{fill-rule:evenodd;clip-rule:evenodd;fill:#f16e00}</style><path
                id="aFill-1" class="ast0" d="M15 3l-3.8 8L2 12.6l6.9 6.1L6.6 28l8.4-4.6 8.4 4.6-2.3-9.3 6.9-6.1-9.2-1.6z"></path></symbol>
        <symbol id="icon-star-empty" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.bst0{fill-rule:evenodd;clip-rule:evenodd;fill:#ccc}</style>
            <path id="bFill-1" class="bst0"
                  d="M15 3l-3.8 8L2 12.6l6.9 6.1L6.6 28l8.4-4.6 8.4 4.6-2.3-9.3 6.9-6.1-9.2-1.6z"></path></symbol>
        <symbol id="icon-star-half" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.cst0,.cst1{fill-rule:evenodd;clip-rule:evenodd;fill:#ccc}.cst1{fill:#f16e00}</style>
            <path class="cst0" d="M28 12.6L18.8 11 15 3v20.4l8.4 4.6-2.3-9.3z"></path>
            <path class="cst1" d="M15 23.4V3l-3.8 8L2 12.6l6.9 6.1L6.6 28z"></path></symbol>
    </svg>
    
    <script src="<%=request.getContextPath()%>/js/newui/TweenMax.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/newui/swiper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/newui/bundle.js"></script>
    <script src="<%=request.getContextPath()%>/js/nocache/listview.js"></script>

    <script>
        var postData = 'catalog_id=<%=catalogId%>&lang=<%=lang%>';
		if(______muid) postData += "&muid="+______muid;
        var isEcommerceEnabled = "";
        var products = "";

        var productIds = [];
        var catAttrIds = [];
        var attrValues = {};
        var searchProductIds = [];
        var promotionSortCounter = 0;

        isEcommerceEnabled = <%=ecommerceEnabled%>;
        products = <%=productResponse.clientSideProducts.toString()%>;

        $(document).ready(function(e){

            initializeDevices("<%=GlobalParm.getParm("PORTAL_URL")%>", postData, "<%=catalogDefaultSort%>");

			$(document).on("click touch",".etn-dl-product-impression",function()
			{
				if(typeof dataLayer !== 'undefined' && dataLayer != null)
				{
					var productImpression = new Object();
					var ecommerceObj = new Object();
					productImpression.event = "productClick";
					productImpression.ecommerce = ecommerceObj;

					var products = [];
					var product = new Object();
					for(var i=0;i<this.attributes.length;i++)
					{
						if((this.attributes[i].nodeName+"").indexOf("data-pi_")>-1)
						{
							var _dlc = this.attributes[i].nodeName.substring("data-pi_".length);
							product[_dlc] = this.attributes[i].value;
						}
					}
					products.push(product);

					ecommerceObj.click = {actionField:{'list':'Search results'}};
					ecommerceObj.products = products;

					productImpression.event_action = "";
					productImpression.event_category = "";
					productImpression.event_label = "";
					dataLayer.push(productImpression);
				}
			});
        });

        function detectDeviceType(){let isMobile=/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);if(isMobile)return'Mobile';return'Desktop';}

        function updateDevicePrices(pid, updatedPrice){

            products.forEach(function(product){

                if(pid == product.id){
                    product.priceNumber = updatedPrice;
                }

            });
        }

        function updateDevicePromotionOrder(pid){

            products.forEach(function(product){

                if(pid == product.id){
                    product.promotion_sort_seq = ++promotionSortCounter;
                }

            });
        }

        function sortDevices(value){

            var sortType = value;
            var sortedDevices = products;
            var deviceCount = 0;
            var html = "";

            if(sortType.length > 0){

                if(sortType === "new"){

                    sortedDevices.sort(function(a, b){

                        if(a.created_on == b.created_on){

                            if(a.order_seq == b.order_seq){

                                return a.id - b.id;

                            } else {

                                return a.order_seq - b.order_seq;
                            }

                        } else {

                            return new Date(b.created_on) - new Date(a.created_on);
                        }
                    });
                }
                else if(sortType === "low"){

                    sortedDevices.sort(function(a, b){return a.priceNumber - b.priceNumber;});
                }
                else if(sortType === "high"){

                    sortedDevices.sort(function(a, b){return b.priceNumber - a.priceNumber;});
                }
                else if(sortType === "promotion"){

                    sortedDevices.sort(function(a, b){return a.promotion_sort_seq - b.promotion_sort_seq;});
                }
                else if(sortType === "all"){

                    sortedDevices.sort(function(a, b){return a.order_seq - b.order_seq});
                }
            }

            sortedDevices.forEach(function(device){
                if(detectDeviceType()=='Mobile'){
                    if(deviceCount++ < 6){

                        $("#product"+device.id).css("display","flex");
                        $("#product"+device.id).attr("data-visibility","visible");

                    } else {

                        $("#product"+device.id).hide();
                        $("#product"+device.id).removeAttr("data-visibility");
                    }
                }else{
                    if(deviceCount++ < 12){

                        $("#product"+device.id).css("display","flex");
                        $("#product"+device.id).attr("data-visibility","visible");

                    } else {

                        $("#product"+device.id).hide();
                        $("#product"+device.id).removeAttr("data-visibility");
                    }
                }

                html += $("<div>").append($('#product'+device.id).clone()).html();
            });

            if(html.length > 0) {

                $(".TerminauxList-list").html(html)
                $(".TerminauxList-showMore.terminaux").show();
            }

			_setProductImpressionPosition();
            if(window.lazyload)
                lazyload();
        }

		function _setProductImpressionPosition()
		{
			var j=1;
			$(".etn-products-list").each(function(){
				if($(this).is(":hidden") == false && $(this)[0].hasAttribute("data-pi_position"))
				{
					$(this).attr("data-pi_position", j++);
				}

			});
		}

        function hasFilteredAttribute(product, selectCatalogAttributeValues, catAttribId){

            var flag = false;
            selectCatalogAttributeValues[catAttribId].forEach(function(val){

                if(!flag && $("#product" + product.id).hasClass("product-attr-val-" + catAttribId + "-" + val)){

                    flag = true;;
                }
            });

            return flag;
        }

        modifySearch = function(){

            var selectCatalogAttributeValues = getCatalogAttributes();
            var minPrice = parseFloat($(inputPriceMin).val());
            var maxPrice = parseFloat($(inputPriceMax).val());
            var filteredProducts = {};
            var filteredCatAttrIds = {};
            var productCountIds = 0;

            products.forEach(function(product){

                filteredCatAttrIds = {};

                for(var catAttribId in selectCatalogAttributeValues){

                    if(selectCatalogAttributeValues[catAttribId].length > 0){

                        filteredCatAttrIds[catAttribId] = hasFilteredAttribute(product,selectCatalogAttributeValues, catAttribId);
                    }
                }

                if(product.priceNumber >= minPrice && product.priceNumber <= maxPrice)
                    filteredProducts[product.id] = filteredCatAttrIds;
            });

            var catAttrs;
            var catAttrFlag = false;
            for(var productId in filteredProducts){

                catAttrs = filteredProducts[productId];
                catAttrFlag = false;

                for(var catAttrId in catAttrs){

                    if(!catAttrFlag && !catAttrs[catAttrId])
                        catAttrFlag = true;

                }

                if(!catAttrFlag)
                    productCountIds++;
            }

            $("#spanNumberOfProducts").html(productCountIds);
        }

        function getCatalogAttributes(){

            var attr = {};
            var attrChecked = {};
            var isAttrChecked = false;

            catAttrIds = [];
            attrValues = {};

            $("div.div-search-catalog-attribute").each(function(i,o){
                var catalogAttributeId = $(o).attr("data-catalog-attribute-id");
                if(catalogAttributeId){

                    attr[catalogAttributeId] = [];
                    attrChecked[catalogAttributeId] = [];
                    attrValues[catalogAttributeId] = [];

                    $("#collapseSpec" + catalogAttributeId + " li.li-search-catalog-attribute").each(function(i,o){

                        if($(o).find("input[type='checkbox']").attr("data-catalog-attribute-checked")){

                            attr[catalogAttributeId].push($(o).attr("data-attribute-value"));
                        }

                        if($(o).find("input[type='checkbox']").prop("checked")){

                            attrChecked[catalogAttributeId].push($(o).attr("data-attribute-value"));
                            attrValues[catalogAttributeId].push($(o).attr("data-attribute-value"));

                            if($.inArray( catalogAttributeId, catAttrIds) == -1) catAttrIds.push(catalogAttributeId);

                            isAttrChecked = true;
                        }
                    });
                }
            });

            if(isAttrChecked) return attrChecked;

            return attr;
        }

        function applySearch(){

            var selectCatalogAttributeValues = getCatalogAttributes();
            var minPrice = parseFloat($(inputPriceMin).val());
            var maxPrice = parseFloat($(inputPriceMax).val());
            var filteredProducts = {};
            var filteredCatAttrIds = {};
            var productCountIds = 0;

            products.forEach(function(product){

                $("#product" + product.id).hide();
                $("#product" + product.id).removeAttr("data-visibility");
                filteredCatAttrIds = {};

                for(var catAttribId in selectCatalogAttributeValues){

                    if(selectCatalogAttributeValues[catAttribId].length > 0){

                        filteredCatAttrIds[catAttribId] = hasFilteredAttribute(product,selectCatalogAttributeValues, catAttribId);
                    }
                }

                if(product.priceNumber >= minPrice && product.priceNumber <= maxPrice){

                    filteredProducts[product.id] = filteredCatAttrIds;
                }
            });

            var catAttrs;
            var catAttrFlag = false;

            for(var productId in filteredProducts){
                
                catAttrs = filteredProducts[productId];
                catAttrFlag = false;

                for(var catAttrId in catAttrs){

                    if(!catAttrFlag && !catAttrs[catAttrId])
                        catAttrFlag = true;
                }

                if(!catAttrFlag){

                    $("#product"+productId).css("display", "flex");
                    $("#product"+productId).attr("data-visibility","visible");
                    productCountIds++;
                }
            }

            var currentPercent = 0;
            $(".TerminauxList-results-count").find("span").html(productCountIds + ' <%= libelle_msg(Etn, request, "résultat(s)")%>' );
            $("#spanNumberOfProducts").html(productCountIds);
            $(".TerminauxList-showMore.terminaux").hide();

			_setProductImpressionPosition();
        }

        function cancelSearch(){

            $("div.div-search-catalog-attribute").each(function(i,o){
                var catalogAttributeId = $(o).attr("data-catalog-attribute-id");
                if(catalogAttributeId){
                    $("#collapseSpec" + catalogAttributeId + " li.li-search-catalog-attribute").each(function(i,o){
                        $(o).find("input[type='checkbox']").prop("checked",false);
                    });
                }
            });

            modifySearch();

            $(document).trigger("reset.slider");

            var i=0;
            $("div.TerminauxList-listItemsColumn").each(function(){
                if(detectDeviceType()=='Mobile'){
                    if(i++ < 6){    

                        $(this).css("display","flex");
                        $(this).attr("data-visibility","visible");

                    } else {

                        $(this).hide();
                        $(this).removeAttr("data-visibility");
                    }
                }else
                {
                    if(i++ < 12){    

                        $(this).css("display","flex");
                        $(this).attr("data-visibility","visible");

                    } else {

                        $(this).hide();
                        $(this).removeAttr("data-visibility");
                    }
                }
            });

            $(".TerminauxList-showMore.terminaux").show();
            
            var noOfProducts = $("div.TerminauxList-listItemsColumn").length;
            console.log("noOfProducts",noOfProducts);
            $(".TerminauxList-results-count").find("span").html(noOfProducts + ' <%= libelle_msg(Etn, request, "résultat(s)")%>' );
            $("#spanNumberOfProducts").html(noOfProducts);
        }

    </script>
</body>
</html>