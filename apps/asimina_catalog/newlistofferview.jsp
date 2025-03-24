<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.beans.Contexte"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>
<%@ page import="com.etn.asimina.util.UrlHelper"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.*"%>

<%@ include file="WEB-INF/include/lib_msg.jsp"%>
<%@ include file="WEB-INF/include/imager.jsp"%>
<%@ include file="common.jsp"%>

<%!

    class ProductResponse{

        JSONArray products;

        ProductResponse(JSONArray products){

            this.products = products;
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
    
    JSONArray getColors(Contexte Etn,String catalogId){
        JSONArray colors = new JSONArray();
        Set rs = Etn.execute("select color from catalog_attribute_values cv join catalog_attributes ca on ca.cat_attrib_id = cv.cat_attrib_id and ca.value_type='color' where catalog_id =  " + escape.cote(catalogId));
        if(rs != null){
            while(rs.next()){
                colors.put(rs.value("color"));
            }
        }
        return colors;
    }

    String getProductSummary(Contexte Etn, String productId, String lang, String catalogdb){

        String summary = "";
        Set rs = Etn.execute("select summary from " + catalogdb + ".product_descriptions where product_id = " + escape.cote(productId) + " and langue_id = " + escape.cote(lang));

        if(rs != null && rs.next()){
            summary = rs.value("summary");
        }
        return summary;
    }

    String getProductMainFeatures(Contexte Etn, String productId, String lang, String catalogdb){

        String mainFeatures = "";
        Set rs = Etn.execute("select main_features from " + catalogdb + ".product_descriptions where product_id = " + escape.cote(productId) + " and langue_id = " + escape.cote(lang));

        if(rs != null && rs.next()){
            mainFeatures = rs.value("main_features");
        }
        return mainFeatures;
    }

    JSONObject getProductAttributeValues(Contexte Etn,String catalogId,String productId){

        JSONObject values = new JSONObject();
        String query = "" +
                        " select c.cat_attrib_id,GROUP_CONCAT(attribute_value) attribute_values " +
                        "   from catalog_attributes c " +
                        "   left join product_attribute_values v on c.cat_attrib_id = v.cat_attrib_id and product_id = " + escape.cote(productId) +
                        "  where catalog_id = " + escape.cote(catalogId) +
                        "  group by c.cat_attrib_id  ";
        Set rs = Etn.execute(query);
        if(rs != null){
            while(rs.next()){
                values.put(rs.value("cat_attrib_id"),rs.value("attribute_values").split(","));
            }
        }
        return values;
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

    int getVariantCount(Contexte Etn, String productId){

        int count = 0;
        Set rs = Etn.execute("select count(*) as variant_count from product_variants where is_active = '1' and product_id = " + escape.cote(productId));

        if(rs != null && rs.next()){

            count = parseNullInt(rs.value("variant_count"));
        }

        return count;
    }

    int getVariantCommitment(Contexte Etn, String productId){

        int count = 0;
        Set rs = Etn.execute("select commitment from product_variants where is_active = '1' and product_id = " + escape.cote(productId) + " and commitment != '0' group by commitment");

        if(rs != null && rs.next()){

            count = parseNullInt(rs.value("commitment"));
        }

        return count;
    }

    ProductResponse getProducts(Contexte Etn,String catalogId,Language lang, String tagId, String siteId){
        JSONArray products = new JSONArray();

        String summary = "";
        String mainFeatures = "";

		String qry = "select p.* ";
		qry += " from products p, product_variants pv ";
		if(tagId.length() > 0) qry += ", product_tags pt";
		qry += " where p.id = pv.product_id and p.catalog_id = " + escape.cote(catalogId) + " and pv.is_active = '1' ";
		if(tagId.length() > 0) qry += " and pt.product_id = p.id and pt.tag_id = " + escape.cote(tagId);
		qry += " group by p.id order by p.order_seq, p.id";
        Set rs = Etn.execute(qry);
        if(rs != null){
            while(rs.next()){
                JSONObject product = toJSONObject(rs);
                String productId = rs.value("id");
                JSONArray images = new JSONArray();
                ProductImageHelper imageHelper = new ProductImageHelper(productId);

                String query = " select image_file_name as path, image_label as label from product_images where product_id = " + escape.cote(String.valueOf(productId)) + " and langue_id = " + escape.cote(lang.getLanguageId()) + " order by sort_order; ";

                Set rsImages = Etn.execute(query);
                if(rsImages != null){
                    String imagePathPrefix = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + siteId + "/img/4x3/";
                    String imageUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/4x3/";
                    while(rsImages.next()){
                        JSONObject image = new JSONObject();

                        String imageName = rsImages.value("path");
                        String imagePath = imagePathPrefix + imageName;
                        String imageUrl = imageUrlPrefix + imageName;
                        String _version = getImageUrlVersion(imagePath);

                        image.put("image",imageUrl + _version);
                        image.put("label",rsImages.value("label"));
                        images.put(image);
                    }
                }
                product.put("images",images);
                if(images.length() > 0){
                    product.put("image",images.get(0));
                }
                product.put("colors",getColors(Etn,productId));

                summary = getProductSummary(Etn, productId, lang.getLanguageId());
                mainFeatures = getProductMainFeatures(Etn, productId, lang.getLanguageId());

                JSONObject attributeValues = getProductAttributeValues(Etn,catalogId,productId);
                product.put("attributeValues",attributeValues);
                product.put("summary", summary);
                product.put("main_features", mainFeatures);
                product.put("variant_count", getVariantCount(Etn, productId));
                product.put("variant_commitment", getVariantCommitment(Etn, productId));
                products.put(product);
            }
        }
        return new ProductResponse(products);
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

    
    Set rscat = Etn.execute("select * from catalogs where catalog_type in ('offer') and id = " + escape.cote(catalogId));
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

	String tagLabel = "";
	if(tagId.length() > 0)
	{
		Set rsTag = Etn.execute("select * from tags where site_id = "+escape.cote(siteId)+" and id = "+escape.cote(tagId));
		if(rsTag.next()) tagLabel = parseNull(rsTag.value("label"));
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

    String pageHeading = parseNull(rscat.value(langColPrefix + "heading"));
    String metakeywords = parseNull(rscat.value(langColPrefix + "meta_keywords"));
	String metadescription = parseNull(rscat.value(langColPrefix + "meta_description"));
    String essentialsAlignment = parseNull(rscat.value("essentials_alignment_lang_" + language.getLanguageId()));
    String html_variant = parseNull(rscat.value("html_variant"));


    ProductResponse productResponse = getProducts(Etn,catalogId,language,tagId,siteId);

    JSONArray products = productResponse.products;

    int numberOfProducts = products.length();

    JSONArray brands = toJSONArray(Etn,"select ifnull(brand_name,'') brand_name,count(0) number_of_products from products where catalog_id = " + escape.cote(catalogId) + " group by ifnull(brand_name,'') ");
	
    try{
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

    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/newui/style<%=language.getDirection()%>.css">
    <title><%=pageHeading%></title>
	
	<meta name="etn:eletype" content="commercialcatalog">
	<meta name="etn:eleid" content="<%=catalogId%>">	

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
                <h2 class="TerminauxList-title"><%=parseNull(rscat.value(langColPrefix + "description"))%></h2>
                <div class="TerminauxList-results-count"><span><%=numberOfProducts%> <%=libelle_msg(Etn, request, "offre(s)")%></span> <%=libelle_msg(Etn, request, "correspondant à votre recherche")%></div>
                <div class="row TerminauxList-list offres">
                    <%
                    for(Object productObj : products){

                        JSONObject product = (JSONObject) productObj;
                    %>
                    <div id="product<%=product.getString("id")%>" class="col-sm-12 col-md-6 col-lg-6 offreListeCol etn-dl-product-impression etn-offers-list"  > <!--SINGLE PRODUCT-->
                        <div class="Tab Tab-Hidden">
                            <div class="Tab-left">
                                <div style="display: none;" class="Tab-icon" data-svg="<%=request.getContextPath()%>/assets/icons/icon-timer.svg"></div>
                                <span class="Tab-left-offer"></span>
                                <div class="Tab-triangle"></div>
                            </div>
                            <div style="display: none;" class="Tab-right promotion-sale-active">
                                <div class="Counter" data-timestamp="">
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
                        <a href="product.jsp?id=<%=product.getString("id")%>" class="OffreItem">
                                <div class="col-picto">
									<%if(product.has("image") && product.getJSONObject("image").getString("image").length() > 0){%>
									<img src="<%=product.getJSONObject("image").getString("image")%>" alt="<%=product.getJSONObject("image").getString("label")%>">
									<%}else{%>
									<img src="data:image/png;base64,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" alt="">
									<%}%>
                                </div>
                                <div class="col-texte">
                                    <div class="col-texte-top">

                                        <div class="OffreItem-title"><%=product.getString("brandName")%> <%=product.getString(langJSONPrefix + "Name")%></div>
                                        <div class="OffreItem-content">
                                            <%= parseNull(product.getString("summary"))%>
                                        </div>

                                    </div>

                                    <div class="col-texte-bottom">
                                        <div class="OffreItem-price">
                                        <%
                                            if(product.getInt("variant_count") > 1){
                                        %>
                                                <span class="price_from"><%=libelle_msg(Etn, request, "À partir de")%></span>
                                        <%
                                            } else {
                                        %>
                                                <span class="price_only"><%=libelle_msg(Etn, request, "Prix seul")%></span>
                                        <%
                                            }
                                        %>
                                            <span class="underline"></span>
                                            <span class="pageStyle-boldOrange" style="text-transform: none !important;"></span>
                                        <%
                                            if(product.getString("productType").equalsIgnoreCase("offer_postpaid")){
                                        %>
                                                <span class="little">/<%=libelle_msg(Etn, request, "mois")%></span>
                                        <%
                                            }
                                        %>
                                            <br/>
                                        <%
                                            if(product.getInt("variant_commitment") > 0){
                                        %>

                                                <span><%=libelle_msg(Etn, request, "Avec engagement")%></span>
                                        <%
                                            } else {
                                        %>

                                                <span><%=libelle_msg(Etn, request, "Sans engagement")%></span>
                                        <%
                                            }
                                        %>
                                        </div>
                                    </div>
                                </div>
                        </a>
                    </div><!--SINGLE RRODUCT-->
                    <%}%>
                </div><!--RRODUCT LIST-->
                <div class="TerminauxList-bottom">
                    <button type="button" class="btn btn-secondary TerminauxList-showMore offres etn-data-layer-event" data-dl_event_category="catalog_page" data-dl_event_action="button_click" data-dl_event_label="<%=UIHelper.escapeCoteValue(libelle_msg(Etn, request, "Afficher plus de résultats"))%>"><%=libelle_msg(Etn, request, "Afficher plus de résultats")%></button>
                </div>
            </div>
        </div>
    </div>

    <%
        Set rsEssentials = Etn.execute("select * from catalog_essential_blocks where catalog_id=" + escape.cote(catalogId) + " and langue_id=" + escape.cote(language.getLanguageId()) + " order by order_seq;");

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
<%

    }catch(Exception ex){

        ex.printStackTrace();
    }

%>
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

	<script src="<%=request.getContextPath()%>/js/newui/swiper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/newui/bundle.js"></script>
    <script src="<%=request.getContextPath()%>/js/nocache/listview.js"></script>
    <script type="text/javascript">

        jQuery(document).ready(function() {

            var postData = 'catalog_id=<%=catalogId%>&lang=<%=lang%>';
			if(______muid) postData += "&muid="+______muid;
            initializeOffers('<%=GlobalParm.getParm("PORTAL_URL")%>', postData);

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

    </script>

</body>
</html>