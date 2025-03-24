<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.*"%>
<%@ include file="WEB-INF/include/lib_msg.jsp"%>
<%@ include file="WEB-INF/include/constants.jsp"%>
<%@ include file="common.jsp"%>

<%!

    String appendKeywords(String kw, String s)
    {
        if(parseNull(s).length() == 0 ) return kw.replace("\"","&quot;");
        if(parseNull(kw).length() > 0) kw += ", ";
        kw += parseNull(s);
        return kw.replace("\"","&quot;");
    }

    String getTitle(String name, String parent)
    {
        name = parseNull(name);
        parent = parseNull(parent);
        if(name.length() == 0 && parent.length() == 0) return "";
        if(name.length() > 0 && parent.length() == 0) return name;
        if(name.length() == 0 && parent.length() > 0) return parent;
        return name +  " | " + parent;
    }

    String getTargetOnClickByOpentype(String opentype){
        String targetOnClick = ("new_tab".equals(opentype) || "new_window".equals(opentype))?" target='_blank' ":"";
        if("new_window".equals(opentype)){
            targetOnClick += " onclick='openNewWindow(event,this)' ";
        }
        return targetOnClick;
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

    String id = parseNull(request.getParameter("id"));
    String lang = parseNull(request.getParameter("lang"));
    String portalPath = GlobalParm.getParm("PORTAL_URL");
    String cartPath = GlobalParm.getParm("CART_URL");
    String catalogId = "";
    String showBasket = "";
    String actionButtonDesktop = "";
    String actionButtonMobile = "";
    String actionButtonDesktopUrl = "";
    String actionButtonMobileUrl = "";
    String actionButtonDesktopUrlOpentype = "";
    String actionButtonMobileUrlOpentype = "";

    Language language = LanguageFactory.instance.getLanguage(lang);

    if(language == null)
    {
        language = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,getSiteByProductId(Etn,id)).get(0);
        lang = language.getCode();
    }

    set_lang(lang, request, Etn);
    

    String langDirection = language.getDirection();

    String prefix = getProductColumnsPrefix(Etn, request, lang);

    String q = "SELECT p.*, pd.seo_title, pd.seo, pd.seo_canonical_url, pd.summary, pd.main_features,"
            +" pd.essentials_alignment, pd.video_url, pd.page_path as product_page_path, cd.folder_name catalog_folder_name, IFNULL(fv.concat_path,'') as folder_path"
            +" FROM products p "
            +" INNER JOIN product_descriptions pd on p.id = pd.product_id"
            +" INNER JOIN catalogs c ON c.id = p.catalog_id"
            +" LEFT JOIN catalog_descriptions cd ON c.id = cd.catalog_id and cd.langue_id = "+escape.cote(language.getLanguageId())
            +" LEFT JOIN products_folders_lang_path fv ON p.folder_id = fv.folder_id and fv.langue_id = "+escape.cote(language.getLanguageId())+" and fv.site_id = c.site_id"
            +" WHERE p.id  = " + escape.cote(id)+" AND pd.langue_id="+escape.cote(language.getLanguageId());
    Set rs = Etn.execute(q);

    if(rs == null || rs.rs.Rows == 0)
    {
        out.write("<div style='color:red'>Error::No product found</div>");
        return;
    }
    rs.next();

    catalogId = parseNull(rs.value("catalog_id"));
    showBasket = parseNull(rs.value("show_basket"));
    String catalogFolderName = parseNull(rs.value("catalog_folder_name"));
    String productPagePath = parseNull(rs.value("product_page_path"));
    String html_variant = parseNull(rs.value("html_variant"));
    String folderPath = parseNull(rs.value("folder_path"));



    if(productPagePath.length() > 0) productPagePath += ".html";

    Set rscat = Etn.execute("select * from catalogs where id = " + escape.cote(catalogId));
    rscat.next();

    String listingscreenheading = parseNull(rscat.value(prefix + "heading"));
    String siteId = parseNull(rscat.value("site_id"));
	Set rsSite = Etn.execute("Select * from "+GlobalParm.getParm("PORTAL_DB")+".sites where id = "+escape.cote(siteId));
	rsSite.next();
	
    String metakeywords = "";
    metakeywords = appendKeywords(metakeywords, parseNull(rs.value(prefix + "name")));
    metakeywords = appendKeywords(metakeywords, parseNull(rs.value(prefix + "meta_keywords")));
    String metadescription = parseNull(rs.value("seo"));
    String metatitle = parseNull(rs.value("seo_title"));
    boolean ecommerceEnabled = isEcommerceEnabled(Etn, siteId);

    Set rsshop = Etn.execute("select * from shop_parameters where site_id = " + escape.cote(siteId) );
    rsshop.next();
    String continueShoppingUrl = parseNull(rsshop.value(prefix + "continue_shop_url"));
	
    String sorting = "";
    String sortVariant = parseNull(rs.value("sort_variant"));

    if(sortVariant.equals("cda"))
        sorting = ", created_on asc";
    else if(sortVariant.equals("cdd"))
        sorting = ", created_on desc";
    else if(sortVariant.equals("pd"))
        sorting = ", price desc";
    else if(sortVariant.equals("pa"))
        sorting = ", price asc";
    else if(sortVariant.equals("cu"))
        sorting = ", order_seq asc";
    else
        sorting = ", id";

    String variantQuery = "select id,pv.uuid as alg_obj_id, name, pv.frequency, pv.is_default, pv.price, pvd.main_features as variant_main_features, pd.main_features as product_details, pvd.action_button_desktop, pvd.action_button_desktop_url, pvd.action_button_desktop_url_opentype, pvd.action_button_mobile, pvd.action_button_mobile_url, pvd.action_button_mobile_url_opentype, pv.commitment, pv.sticker from product_descriptions pd, product_variants pv, product_variant_details pvd where pd.product_id = pv.product_id and pv.id = pvd.product_variant_id and pd.product_id = " + escape.cote(id) + " and pd.langue_id = " + escape.cote(language.getLanguageId()) + " and pvd.langue_id = " + escape.cote(language.getLanguageId()) + " and pv.is_active = 1 order by pv.is_default desc " + sorting;
    Set rsVariants = Etn.execute(variantQuery);
    int variantCount = rsVariants.rs.Rows;

    JSONArray variantsAlgObjectId = new JSONArray();

	String price1 = "";
	String price2 = "";
	String price3 = "";
	int dcommitment = 0;
	String dfrequency = "";
	//resultset is order by is_default and then sorting order ... so is_default will always be first ... if is_Default is not active then we will set price1 as first variant price
	int cnt=0;
	while(rsVariants.next())
	{
        variantsAlgObjectId.put(rsVariants.value("alg_obj_id"));
		double dprice = 0;
		try {
			dprice = Double.parseDouble(parseNull(rsVariants.value("price")));
		}catch(Exception e) { dprice = 0; }

		if(cnt == 0)
		{
			try {
				dcommitment = Integer.parseInt(parseNull(rsVariants.value("commitment")));
			}catch(Exception e) { dcommitment = 0;}

			price1 = ""+dprice;
			dfrequency = parseNull(rsVariants.value("frequency"));
		}
		else if(cnt == 1 && dprice > 0) price2 = ""+dprice;
		else if(cnt == 2 && dprice > 0) price3 = ""+dprice;
		cnt++;
	}
	rsVariants.moveFirst();

    String videoUrl = parseNull(rs.value("video_url"));

    String pname = parseNull(rs.value("brandName"));
    if(pname.length() > 0 )
        pname += " ";
    pname += parseNull(rs.value(prefix + "Name"));

    String ogImageSrc = "";
    Set rsImages = Etn.execute("select image_file_name as path, image_label as label from product_images where product_id = " + escape.cote(String.valueOf(id)) + " and langue_id = " + escape.cote(language.getLanguageId()) + " order by sort_order;");

    if(rsImages.next())
	{
        String imageName = rsImages.value("path");
        String imagePath = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + siteId + "/img/og/" + imageName;
        String imageUrl = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/og/" + imageName;
        String _version = getImageUrlVersion(imagePath);

        ogImageSrc = imageUrl + _version;

	}

    Set rsMetaTags = Etn.execute("select * from products_meta_tags where product_id = "+escape.cote(id) + " and langue_id = "+escape.cote(language.getLanguageId())+" order by id");

	String alltags = "";
	Set rsTags = Etn.execute("select product_id, group_concat(tag_id) as tags from product_tags where product_id = "+escape.cote(id) + " group by product_id order by tag_id");
	if(rsTags.next()) alltags = parseNull(rsTags.value("tags"));

    String ispreview = parseNull(request.getParameter("ispreview"));
    String ___prvMuid = "";
    if("1".equals(ispreview))
    {
        Set ___rsm = Etn.execute("select * from " + GlobalParm.getParm("PORTAL_DB") + ".site_menus where site_id  = " + escape.cote(siteId));
        if( ___rsm.next()) ___prvMuid = ___rsm.value("menu_uuid");
    }

%>
<!DOCTYPE html>
<% if(parseNull(lang).length() > 0) { %>
<html lang="<%=parseNull(lang)%>" dir="<%=langDirection%>">
    <% } else { %>
<html>
<% } %>
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

    <% if("rtl".equalsIgnoreCase(langDirection)) { %>
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/newui/stylertl.css">
    <% } else { %>
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/newui/style.css">
    <% } %>

	<meta name="title" content="<%=metatitle.replace("\"","&quot;")%>">
    <meta name="etn:pname" content="<%=pname.replace("\"","&quot;")%>">
    <meta name="etn:eletype" content="commercialcatalog">
    <meta name="etn:ctype" content="<%=parseNull(rscat.value("catalog_type")).replace("\"","&quot;")%>">
    <meta name="etn:cname" content="<%=parseNull(rscat.value("name")).replace("\"","&quot;")%>">
    <meta name="etn:eleprice" content="<%=price1%>">
    <meta name="etn:eleimage" content="<%=ogImageSrc%>">
    <%if(price2.length() > 0) {%><meta name="etn:eleprice2" content="<%=price2%>"><%}%>
    <%if(price3.length() > 0) {%><meta name="etn:eleprice3" content="<%=price3%>"><%}%>
	<meta name="etn:elecurrency" content="<%=parseNull(rsshop.value("lang_1_currency"))%>">
	<meta name="etn:eleid" content="<%=id%>">
	<meta name="etn:eletaglabel" content="<%=alltags%>">

	<% if(dcommitment <= 0){%>
		<meta name="etn:elecommitment" content="<%=libelle_msg(Etn, request, "Sans engagement")%>">
		<meta name="etn:elemonthly" content="false">
	<% } else {%>
		<meta name="etn:elecommitment" content="<%=libelle_msg(Etn, request, "Engagement") + " " + dcommitment + " " + libelle_msg(Etn, request, dfrequency)%>">
		<meta name="etn:elemonthly" content="true">
	<%}%>

    <%
        for (int i = 0; i < variantsAlgObjectId.length(); i++) {
    %>
        <meta name="alg:variant_objectid" content="<%=variantsAlgObjectId.getString(i)%>">
    <%
        }
    %>


	<%if(env.length() > 0){ %>
		<meta name="etn:eleenv" content="<%=env%>">
	<% } %>

    <% while(rsMetaTags.next()){%>
        <meta name="<%=rsMetaTags.value("meta_name")%>" content="<%=rsMetaTags.value("content")%>">
    <%}%>


    <%  if(productPagePath.length() > 0) {
            String html_variant_path = "";

            if(html_variant.equals("logged")){
                html_variant_path =  html_variant+"/";
            }

            if(catalogFolderName.length()>0){
                html_variant_path = html_variant_path + catalogFolderName + "/";
            }

            if(folderPath.length()>0){
                html_variant_path = html_variant_path + folderPath + "/";
            }
    %>

        <meta name="etn:eleurl" content="<%=html_variant_path%><%=productPagePath.replaceAll("\"","&quot;")%>">
    <%  } %>

    <title><%=getTitle((parseNull(rs.value(prefix+"name")).startsWith(libelle_msg(Etn, request,parseNull(rs.value("brand_name"))))?"":libelle_msg(Etn, request,parseNull(rs.value("brand_name"))))+" "+parseNull(rs.value(prefix + "name")), listingscreenheading)%></title>

<%

        //by default we will show share bar ... for portals where we have to disable it we just add entry to global param and set it non empty or not 1
        if(parseNull(com.etn.beans.app.GlobalParm.getParm("SHOW_SHARE_BAR")).length() == 0 || parseNull(com.etn.beans.app.GlobalParm.getParm("SHOW_SHARE_BAR")).equals("1"))
        {
    %>

    <jsp:include page="WEB-INF/include/sharebar.jsp">
        <jsp:param name="prefix" value="<%=prefix%>" />
        <jsp:param name="ptype" value="<%=PRODUCT_SHAREBAR_TYPE%>" />
        <jsp:param name="id" value="<%=id%>" />
        <jsp:param name="ogImage" value="<%=ogImageSrc%>" />
        <jsp:param name="productName" value="<%=pname%>" />
        <jsp:param name="description" value="<%=metadescription%>" />
        <jsp:param name="summary" value='<%=rs.value("summary")%>' />
    </jsp:include>

<% } %>

	<script type="text/javascript">
		var asmPageInfo = asmPageInfo || {};
		asmPageInfo.apiBaseUrl = "<%=portalExternalLink%>";
		asmPageInfo.clientApisUrl = "<%=portalExternalLink%>clientapis/";
		asmPageInfo.expSysUrl = "<%=com.etn.beans.app.GlobalParm.getParm("EXP_SYS_EXTERNAL_URL")%>";
		asmPageInfo.environment = "<%=(env.equals("")?"P":env)%>";
		asmPageInfo.suid = "<%=rsSite.value("suid")%>";
		asmPageInfo.lang = "<%=lang%>";		
	</script> 	
</head>
<body>

    <div class="PageTitle">
        <div class="container">

            <h1 class="h1-like"><%=(parseNull(rs.value(prefix+"name")).startsWith(libelle_msg(Etn, request,parseNull(rs.value("brand_name"))))?"":libelle_msg(Etn, request,parseNull(rs.value("brand_name"))))%> <%=parseNull(rs.value(prefix+"name"))%></h1>

        </div>
    </div>
<div class="OffreVariation-component">
<% if(variantCount > 1){ %>
    <div class="container OffreVariation-navbar-wrapper OffreVariation-navbar-6-items">
<%}%>
        <div class="OffreVariation-navbar">
    <%
        if(variantCount > 4){ //if product variant is greater than 4 then it shows
    %>

            <div class="pageStyle-bold btnNavBar btnNavBar-prev">
                <span data-svg="<%=request.getContextPath()%>/assets/icons/icon-angle-left.svg"></span>
                <span class="d-none d-lg-inline-block"><%=libelle_msg(Etn, request,"Offre précédente")%></span>
            </div>
    <%
        }

        if(variantCount > 1){
    %>

            <div class="pageStyle-bold">
                <span class="pageStyle-boldOrange"> <%= variantCount%>  <%=libelle_msg(Etn, request,"offre(s)")%></span>
                <%=libelle_msg(Etn, request,"disponibles")%>
                <span class="d-lg-none"> - <span class="OffreNavBar-activeSlide"></span>/<span class="OffreNavBar-nbSlides"></span></span>
            </div>
    <%
        }

        if(variantCount > 4){ //if product variant is greater than 4 then it shows
    %>

            <div class="pageStyle-bold btnNavBar btnNavBar-next">
                <span class="d-none d-lg-inline-block"><%=libelle_msg(Etn, request,"Offre Suivante")%></span>
                <span data-svg="<%=request.getContextPath()%>/assets/icons/icon-angle-right.svg"></span>
            </div>
    <%
        }
    %>
        </div>

<% if(variantCount > 1){ %>
    </div>
<%}%>

<%
    if(variantCount == 1){
%>
        <div class="OffreVariation-1item">
<%
    } else {
%>
        <div class="Offre-container container">
<%
    }
%>

<%
    if(variantCount > 1 && variantCount <= 4){ // if offer variant less than 4 then show the div
%>
        <div class="Offre-variation">
<%
    }

%>

<%
    if(variantCount == 1){
%>
        <div class="container">
            <div class="row mb-3">
<%
    } else {
%>
            <div class="Offre-swiper">
                <div class="swiper-container">
                    <div class="swiper-wrapper">
<%
    }
%>

            <%
                int counter = 0;
				int variantCnt = 0;
                String sticker = "";
                while(rsVariants.next()){

                    actionButtonDesktop = parseNull(rsVariants.value("action_button_desktop"));
                    actionButtonDesktopUrl = parseNull(rsVariants.value("action_button_desktop_url"));
                    actionButtonDesktopUrlOpentype = parseNull(rsVariants.value("action_button_desktop_url_opentype"));
                    actionButtonMobile = parseNull(rsVariants.value("action_button_mobile"));
                    actionButtonMobileUrl = parseNull(rsVariants.value("action_button_mobile_url"));
                    actionButtonMobileUrlOpentype = parseNull(rsVariants.value("action_button_mobile_url_opentype"));


					if(variantCnt == 0)
					{
						variantCnt ++;
					}
                    if(variantCount == 1){

            %>
                        <div class="col-xs-12 col-md-7">
            <%
                    }
            %>

                            <div id='pvariant_<%= parseNull(rsVariants.value("id"))%>' data-dl_event_category="offer_details" data-dl_event_action="div_click" data-dl_event_label='<%=UIHelper.escapeCoteValue(parseNull(rsVariants.value("name")))%>' class="OffreVariation swiper-slide etn-offer-variants etn-data-layer-event <% if(counter++ == 0){ %> OffreVariation-isActive <% } %>">

                                <div class="Tab Tab-hidden">
                                    <div class="Tab-left">
                                        <div class="Tab-icon" data-svg="<%=request.getContextPath()%>/assets/icons/icon-timer.svg"></div>
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

                                <%
                                    if(parseNull(rsVariants.value("sticker")).equalsIgnoreCase("web") || parseNull(rsVariants.value("sticker")).equalsIgnoreCase("orange"))
                                            sticker = "isFlash";
                                    else
                                        sticker = "isNouveau";
                                %>
                                <div class='OffreVariation-header OffreVariation-<%=sticker%>'>
                                    <div class="OffreVariation-price"></div>
                                    <div class="OffreVariation-engagement"></div>
                                    <div class="pageStyle-bold OffreVariation-titre"><span style="font-size: 20px;"><%= parseNull(rsVariants.value("name"))%></span>
                                        <br><span class="pageStyle-bold d-none"><span class="pageStyle-bold-sans d-none"><%=libelle_msg(Etn, request, "Sans")%></span> <span style="text-transform: capitalize;"><%=libelle_msg(Etn, request,"engagement")%></span> <span class="commitment"></span></span></div>
                                </div>

                                <div class="OffreVariation-content">
                            <%
                                if(showBasket.equals("1") && ecommerceEnabled){
                            %>
                                   <a href='#<%=libelle_msg(Etn, request,"Choisir ce forfait")%>' id='<%= parseNull(rsVariants.value("id"))%>' class="pageStyle-btn-forfait confrmOfferPackage " onclick="addToCart(this.id)"><%=libelle_msg(Etn, request,"Choisir ce forfait")%></a>
                            <%
                                } else if(showBasket.equals("0") && actionButtonMobile.length() > 0 && actionButtonMobileUrl.length() > 0){
                                    String targetOnClick = getTargetOnClickByOpentype(actionButtonMobileUrlOpentype);
                            %>
                                    <a href="<%= actionButtonMobileUrl%>" class="pageStyle-btn-forfait confrmOfferPackage etn-data-layer-event" id='<%= parseNull(rsVariants.value("id"))%>' data-dl_event_category="offer_details" data-dl_event_action="button_click" data-dl_event_label='<%=UIHelper.escapeCoteValue(actionButtonMobile)%>' <%=targetOnClick%> ><%= actionButtonMobile%></a>
                            <%
                                }
                            %>
                                    <div class="OffreVariation-description">
                                        <%=parseNull(rsVariants.value("variant_main_features"))%>
                                    </div>
                                    <div class="OffreVariation-warning">
                                        <div class="warning-additional-fee"></div>
                                    </div>
                                </div>
                            </div>
            <%
                    if(variantCount == 1){
            %>
                        </div>

                        <div class="col-xs-12 col-md-5">
                            <div class="OffreVariation-1item-summary" style="margin-top: 0;">

                                <div class="OffreVariation-forfait" style="border: 0">
                                    <div class="warning-additional-fee"> </div>
                                </div>

                            <%
                                if(showBasket.equals("1") && ecommerceEnabled){
                            %>
                                    <a href='#<%=libelle_msg(Etn, request,"Choisir ce forfait")%>' class="pageStyle-btn-forfait d-none d-lg-block " id='<%= parseNull(rsVariants.value("id"))%>' style="margin-top: 8px;" onclick="addToCart(this.id)"><%=libelle_msg(Etn, request,"Choisir ce forfait")%></a>
                            <%
                                } else if(showBasket.equals("0") && actionButtonDesktop.length() > 0 && actionButtonDesktopUrl.length() > 0){
                                    String targetOnClick = getTargetOnClickByOpentype(actionButtonDesktopUrlOpentype);
                            %>
                                    <a href="<%= actionButtonDesktopUrl%>" class="pageStyle-btn-forfait confrmOfferPackage action-dsktp-btn d-none d-md-block etn-data-layer-event" id='<%= parseNull(rsVariants.value("id"))%>' data-dl_event_category="offer_details" data-dl_event_action="button_click" data-dl_event_label='<%=UIHelper.escapeCoteValue(actionButtonDesktop)%>' style="margin-top: 8px;" <%=targetOnClick%> ><%= actionButtonDesktop%></a>
                            <%
                                }
                            %>

                                <div class="mt-3 discount_card_mv"> </div>
                                <div class="mt-3 warning-additional-fee"> </div>
                                <div class="AssociatedProductComewith" style="margin-top: 20px;"></div>

                            </div>
                        </div>
            <%
                    }
                }
            %>
                    </div>
                </div>
<%
    if(variantCount == 1){
%>
            <div class="swiper-pagination"></div>
		</div>
        </div>
<%
    }
	else {
%>
		</div>
<%
	}
%>

    <%
        if(variantCount > 1 && variantCount <= 4){
    %>
            </div>
    <%
        }

        if(null != rsVariants){

            rsVariants.moveFirst();
            rsVariants.next();
        }
    %>
    </div>

    <div class="container Offre-groupe">
        <div class="Offre-detail">
            <div class="Offre-description">
                <div class="Offre-content d-none d-lg-block">
                    <div class="Offre-title"><%=libelle_msg(Etn, request,"Détails de l'offre")%></div>
                    <div class="Offre-main-features"><%= parseNull(rsVariants.value("product_details"))%></div>
    <%
            if(videoUrl.length() > 0 ){
    %>
                <a href='#<%=libelle_msg(Etn, request,"Voir la vidéo")%>' class="Offre-video" data-toggle="modal" data-target="#lightboxVideoModal">
                    <span data-svg="<%=request.getContextPath()%>/assets/icons/icon-play.svg"></span> <%=libelle_msg(Etn, request,"Voir la vidéo")%>
                </a>
    <%
            }
    %>
                </div>
            </div>

    <%
            if(null != rsVariants && variantCount > 1 ){

    %>
                <div class="Offre-buttons">
                    <div class="Offre-forfait-informations">

                        <div class="Tab Tab-hidden">
                            <div class="Tab-left">
                                <div class="Tab-icon" data-svg="<%=request.getContextPath()%>/assets/icons/icon-timer.svg"></div>
                                <div class="Tab-left-offer"></div>
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

                        <div class="OffreVariation-forfait">
                            <div class="pageStyle-boldOrange"></div>
                            <div class="engagement"></div>
                            <div class="pageStyle-bold d-none"> <span class="pageStyle-bold-sans d-none"><%=libelle_msg(Etn, request, "Sans")%></span> <%=libelle_msg(Etn, request,"Engagement")%>  <span class="commitment"> </span></div>
                            <div class="warning-additional-fee"> </div>
                        </div>
                    </div>

                <%
                    if(showBasket.equals("1") && ecommerceEnabled){
                %>
                        <a href='#<%=libelle_msg(Etn, request,"Choisir ce forfait")%>' class="pageStyle-btn-forfait confrmOfferPackage " id='<%= parseNull(rsVariants.value("id"))%>' onclick="addToCart(this.id)" ><%=libelle_msg(Etn, request,"Choisir ce forfait")%></a>
                <%
                    }

                    int variantActionButtonCount = 0;
                    rsVariants.moveFirst();
                    while(rsVariants.next()){

                        actionButtonDesktop = parseNull(rsVariants.value("action_button_desktop"));
                        actionButtonDesktopUrl = parseNull(rsVariants.value("action_button_desktop_url"));

                        if(showBasket.equals("0") && actionButtonDesktop.length() > 0 && actionButtonDesktopUrl.length() > 0){
                            String targetOnClick = getTargetOnClickByOpentype(actionButtonDesktopUrlOpentype);
                %>
                            <a href="<%= actionButtonDesktopUrl%>" data-data-dl_event_category="offer_details" data-dl_event_action="button_click" data-dl_event_label='<%=UIHelper.escapeCoteValue(actionButtonDesktop)%>' class="pageStyle-btn-forfait confrmOfferPackage etn-data-layer-event action-dsktp-btn d-none <%if(variantActionButtonCount++ == 0){%> d-md-block <%}%>"   id='confrmOfferPackage_<%= parseNull(rsVariants.value("id"))%>' <%=targetOnClick%> ><%= actionButtonDesktop%></a>
                <%
                        }
                    }
                %>

                    <a style="display: none;" href='#<%=libelle_msg(Etn, request,"Choisir avec un mobile")%>' class="pageStyle-btn-mobile">
                        <span data-svg="<%=request.getContextPath()%>/assets/icons/icon-smartphone.svg"></span> <%=libelle_msg(Etn, request,"Choisir avec un mobile")%></a>

                    <div class="mt-3 discount_card_mv"> </div>
                    <div class="AssociatedProductComewith" style="margin-top: 20px;"></div>

                </div>
    <%
            }
    %>
        </div>
    </div>

<%
    ProductEssentialsImageHelper essentialsImageHelper = new ProductEssentialsImageHelper(id);
    Set rsEssentials = Etn.execute("select * from product_essential_blocks where product_id="+escape.cote(id)+" and langue_id="+escape.cote(language.getLanguageId())+" order by order_seq;");
    if(rsEssentials.rs.Rows!=0){

%>
<div class="Essentiel d-none d-lg-block">
    <div class="container">
        <h2><%=libelle_msg(Etn, request,"L'essentiel")%></h2>

        <div class="Essentiel-swiper swiper-container">
            <div class="Essentiel-list swiper-wrapper">
            <%
                String essentialsAlign = "";

                if(rs.value("essentials_alignment").contains("_right")) essentialsAlign = "align-reverse";

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
                        if(rs.value("essentials_alignment").startsWith("zig_zag")){
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
</div>

    <div class="Onglets OngletsOffres">
        <div class="container">
            <div class="o-tab-container accordion-layout">

                <a class="o-tab-heading d-lg-none" data-toggle="tab" href="#tab-0-content" id="tab0">
              <%=libelle_msg(Etn, request,"Détails de l'offre")%>        </a>
                <div class="o-tab-content d-lg-none" id="tab-0-content">
                    <div class="Offre-main-features-mble"><%= parseNull(rsVariants.value("product_details"))%></div>
            <%
                    if(videoUrl.length() > 0 ){
            %>
                    <a href='#<%=libelle_msg(Etn, request,"Voir la vidéo")%>' class="Offre-video" data-toggle="modal" data-target="#lightboxVideoModal">
                        <img src="<%=request.getContextPath()%>/assets/icons/icon-play.svg" alt='<%=libelle_msg(Etn, request,"Voir la vidéo")%>'> <%=libelle_msg(Etn, request,"Voir la vidéo")%> </a>
            <%
                    }
            %>

                </div>

            <%
                Set rstabs = Etn.execute("select * from product_tabs where product_id = " + escape.cote(id) + " and  langue_id = " + escape.cote(language.getLanguageId()) + " order by case coalesce(order_seq,'') when '' then 999999 else order_seq end ");

                int tabAlignCount = 0;
                int tabCount = 0;

                while(rstabs.next()){
            %>
                    <a class="o-tab-heading etn-data-layer-event" aria-expanded="<% if(tabAlignCount++ == 0) { %>true<% } %>" data-toggle="tab" href='#<%=parseNull(rstabs.value("name"))%>' data-dl_event_category="tab_details" data-dl_event_action="tab_click" data-dl_event_label="<%=UIHelper.escapeCoteValue(parseNull(rstabs.value("name")))%>" ><%=parseNull(rstabs.value("name"))%></a>
                    <div class="o-tab-content <% if(tabCount++ == 0) { %> show <% } %>" id="<%=fixTabname(parseNull(rstabs.value("name")))%>">
                        <%=parseNull(rstabs.value("content"))%>
                    </div>
            <%
                }
            %>

            </div>


<%
    ProductEssentialsImageHelper essentialsImageHelperMble = new ProductEssentialsImageHelper(id);
    Set rsEssentialsMble = Etn.execute("select * from product_essential_blocks where product_id="+escape.cote(id)+" and langue_id="+escape.cote(language.getLanguageId())+" order by order_seq;");
    if(rsEssentialsMble.rs.Rows!=0){

%>
<div class="Essentiel d-lg-none">
    <div class="container">
        <h2><%=libelle_msg(Etn, request,"L'essentiel")%></h2>

        <div class="Essentiel-swiper swiper-container">
            <div class="Essentiel-list swiper-wrapper">
            <%
                String essentialsAlign = "";

                if(rs.value("essentials_alignment").contains("_right")) essentialsAlign = "align-reverse";

                while(rsEssentialsMble.next()){
                    String esImageActualName = rsEssentialsMble.value("actual_file_name");
                    Set rsMedia = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".files where file_name="+escape.cote(esImageActualName)+
                        " and site_id="+escape.cote(siteId)+" and (COALESCE(removal_date,'') = '' or  removal_date>now())");

                    if(rsMedia.rs.Rows>0){
                        String esImageName = rsEssentialsMble.value("file_name");
                        String esImageUrl = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/" + esImageName;
            %>
                        <div class="Essentiel-item swiper-slide <%=essentialsAlign%>">
                            <div class="Essentiel-photo">
                                <img src="<%=esImageUrl%>" alt="<%=rsEssentialsMble.value("image_label")%>">
                            </div>
                            <div class="Essentiel-content">
                                <%=rsEssentialsMble.value("block_text")%>
                            </div>
                        </div>

            <%
                        if(rs.value("essentials_alignment").startsWith("zig_zag")){
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


        </div>
    </div>

    <div class="container">
        <div id='__sharebar' style='clear:both; margin-top:25px' class=" orange-plans __sharebar">
            <div id="sharebar"></div>
        </div>
        <div class="pageStyle-hr-line"></div>
        <div class="prixTaxesComprises">
            <div class="btn-50 left">
                <a href='javascript:goBack();' ><img src="<%=request.getContextPath()%>/assets/icons/icon-angle-left.svg" alt='<%=libelle_msg(Etn, request,"Retour")%>'><%=libelle_msg(Etn, request,"Retour")%></a>
            </div>
            <div class="btn-50 right" id="pricestaxincludediv" style="display:none"><%=libelle_msg(Etn, request, "Prix toutes taxes comprises")%></div>
            <div class="btn-50 right" id="pricestaxexclusivediv" style="display:none"><%=libelle_msg(Etn, request, "Les prix sont affichés hors taxes")%></div>
        </div>
    </div>

    <div class="container">
        <div class="pageStyle-hr-line"></div>
    </div>

    <div id="associatedProductLightBoxContainer"></div>

    <%
        if(videoUrl.length() > 0 ){
    %>
            <div class="Lightbox-video">

                <div class="modal fade" id="lightboxVideoModal" tabindex="-1" role="dialog" aria-labelledby="lightboxVideoModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered" role="document">
                        <div class="modal-content">
                            <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                            <div class="Lightbox-video-wrapper">
                                <img src="<%=request.getContextPath()%>/assets/illustrations/gabarit-16-9.gif" alt="">
                                <iframe class="Lightbox-video-iframe" width="560" height="315" src='<%= videoUrl%>?controls=0' frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen>
                                </iframe>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
    <%
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

<div class="BasketModal modal fade" id="addModal" tabindex="-1" role="dialog" aria-labelledby="addModalTitle"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <div class="BasketModal-title" id="addModalTitle">
                    <span class="BasketModal-iconTitle"
                          data-svg="/src/assets/icons/icon-valid.svg"></span>
                    <span class="BasketModal-titleWrapper h2"><%=libelle_msg(Etn, request, "Cet article a bien été ajouté à votre panier")%></span>
                </div>
                <div class="BasketModal-actions BasketModal-section">
                    <button type="button" class="btn btn-secondary etn-data-layer-event asm-continue-shop-btn" data-continue_url="<%=continueShoppingUrl%>" data-dl_event_action="button_click" data-dl_event_category="popin_add_products" data-dl_event_label="continue_buy"  data-dismiss="modal" data-bs-dismiss="modal" onclick="continueShopping(this);"><%=libelle_msg(Etn, request, "Continuer les achats")%></button>
                    <button type="button" class="btn btn-primary etn-data-layer-event" data-dl_event_action="button_click" data-dl_event_category="popin_add_products" data-dl_event_label="see_cart" onclick="proceedToCart('<%=cartPath%>')"><%=libelle_msg(Etn, request, "Voir le panier")%></button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="<%=request.getContextPath()%>/js/newui/swiper.min.js"></script>
<script src="<%=request.getContextPath()%>/js/newui/bundle.js"></script>
<script src="<%=request.getContextPath()%>/js/nocache/listview.js"></script>
<script src="<%=request.getContextPath()%>/js/bootbox.min.js"></script>

<script type="text/javascript">

    var portalUrl = '<%=portalPath%>';
    <%if("1".equals(ispreview))
    {%>
        var ______muid = "<%=___prvMuid%>";
    <%}%>
    jQuery(document).ready(function() {

        var postData = 'catalog_id=<%=catalogId%>&product_id=<%=id%>&lang=<%=lang%>&menu_uuid='+______muid;

        initializeOfferDetail(portalUrl, postData, '<%=request.getContextPath()%>').then(()=>{
            var detailChoice = document.getElementsByClassName("Offre-variation")[0];
            if(!urlSearchParams()){
                if(detailChoice.querySelector("[class*='isActive' i][data-dl_event_label]")){
                    var url = new URL(window.location);
                    url.searchParams.set("offer",detailChoice.querySelector("[class*='isActive' i][data-dl_event_label]").dataset.dl_event_label);
                    window.history.replaceState(null,"",url);
                }
            }
            
            var url = new URL(window.location);
            Array.from(detailChoice.querySelectorAll("[data-pi_category='offer']")).forEach((e)=>{
                e.addEventListener("click",function(){
                    let flag=false;
                    e.classList.forEach((e)=>{
                        if(flag) return;
                        flag = e.includes("isActive");
                    });
                    if(flag){
                        url.searchParams.set("offer",e.dataset.dl_event_label);
                    }else{
                        url.searchParams.delete("offer");
                    }
                    window.history.replaceState(null,"",url);
                });
            })
        }).catch(console.error);
        initSharebar('.__sharebar','<%=libelle_msg(Etn, request, "Partager sur")%>');
    });

    function urlSearchParams()
    {
        let isParam=false;
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        var detailChoice = document.getElementsByClassName("Offre-variation")[0];        
        for (const [key, value] of urlParams.entries()) {  
            isParam=true;
            let cssSelector = "[data-pi_category='"+key+"' i][data-dl_event_label='"+value+"' i]";
            let ele = detailChoice.querySelector(cssSelector);
            if(ele){
                if(!(ele.classList.contains("OffreVariation-isActive") || ele.classList.contains("active") || ele.classList.contains("disabled")) ){                    
                    ele.click();
                }
            }
        }
        return isParam;
    }

	function goBack()
	{
		var _ref = document.referrer;
		var _domain = document.domain;
		if(_ref.indexOf("//" + _domain) > -1)
		{
			var goback = -1;
			if(window.location.href.indexOf("#") > -1) goback = -2;
			history.go(goback);
		}
	}

    function openNewWindow(event, ele) {
        event.preventDefault(); //prevent <a> default click behavior
        var url = ele.href;

        if (window.innerWidth <= 640) {
            // if on mobile, open new tab not window
            // if width is smaller then 640px, create a temporary a elm that will open the link in new tab
            var a = document.createElement('a');
            a.setAttribute("href", url);
            a.setAttribute("target", "_blank");
            a.click();
        }
        else {
            var width = window.innerWidth * 0.66 ;
            var height = width * window.innerHeight / window.innerWidth ;
            // Ratio the hight to the width as the user screen ratio
            window.open(url , url, 'width=' + width + ', height=' + height
                + ', top=' + ((window.innerHeight - height) / 2)
                + ', left=' + ((window.innerWidth - width) / 2));
        }
        return false;
    }

</script>
</body>
</html>
