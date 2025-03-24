<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte, com.etn.beans.app.GlobalParm, java.util.List, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map,  org.json.JSONObject, org.json.JSONArray, com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language, com.etn.asimina.beans.KeyValuePair, com.etn.asimina.util.SiteHelper" %>
<%@ page import="com.etn.asimina.util.*" %>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%@ include file="/urlcreator.jsp"%>
<%
    String isprod = parseNull(request.getParameter("isprod"));
    String dbname = "";
    boolean bIsProd = false;
    if(bIsProd)
    {
        bIsProd = true;
        dbname = GlobalParm.getParm("PROD_DB") + ".";
    }

    boolean isOrangeApp = "1".equals(parseNull(GlobalParm.getParm("IS_ORANGE_APP")));

    String lang_tab = parseNull(request.getParameter("lang_tab"));
    if(lang_tab.length() == 0) lang_tab = "lang1show";

    String id = parseNull(request.getParameter("id"));

    Set rs = null;
    String readonly = "";
    String viewname = "";
    String catalogtype = "";
    boolean priceTaxIncluded = false;

    String topBanProductList = "";
    String topBanProductDetail = "";
    String topBanHub = "";
    String bottomBanProductList = "";
    String bottomBanProductDetail = "";
    String bottomBanHub = "";
    //boolean ecommerceEnabled = false;
    String selectedsiteid = getSelectedSiteId(session);
    boolean ecommerceEnabled = isEcommerceEnabled(Etn, selectedsiteid);

    if(id.length() > 0)
    {
        rs = Etn.execute("select * from "+dbname+"catalogs where id =  " + escape.cote(id) + " and site_id = " + escape.cote(selectedsiteid));

        if(rs == null || rs.rs.Rows < 1){
            response.sendRedirect("catalogs.jsp");
			return;
        }

        rs.next();

        if("1".equals(rs.value("is_special"))) readonly = "readonly";
        viewname = parseNull(rs.value("view_name"));
        catalogtype = parseNull(rs.value("catalog_type"));
        priceTaxIncluded = "1".equals(parseNull(rs.value("price_tax_included")));

        topBanProductList = parseNull(rs.value("topban_product_list"));
        topBanProductDetail = parseNull(rs.value("topban_product_detail"));
        topBanHub = parseNull(rs.value("topban_hub"));

        bottomBanProductList = parseNull(rs.value("bottomban_product_list"));
        bottomBanProductDetail = parseNull(rs.value("bottomban_product_detail"));
        bottomBanHub = parseNull(rs.value("bottomban_hub"));
    }

    List<Language> langsList = getLangs(Etn,selectedsiteid);

    String catalogPublishStatus = "unpublished";
    String lastpublish = "";
    String nextpublish = "";

    Set attribRs = null;
    Set attribRs2 = null;

    Set rsDesc = null;
    if(id.length() > 0)
    {
        String process = getProcess("catalog");
        Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" ");
        if(rspw.next()) nextpublish = parseNull(rspw.value(0));

        rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status  in (0, 2) and phase = 'published' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
        if(rspw.next()) lastpublish = parseNull(rspw.value(0));

        String catStatusArr[] = getCatalogPublishStatus(Etn, id, rs.value("version"));
        catalogPublishStatus = catStatusArr[0];
        lastpublish = catStatusArr[1];

        attribRs = Etn.execute("SELECT * FROM "+dbname+"catalog_attributes WHERE type = 'selection' AND catalog_id = " + escape.cote(id) + " ORDER BY sort_order ");

        attribRs2 = Etn.execute("SELECT * FROM "+dbname+"catalog_attributes WHERE type = 'specs' AND catalog_id = " + escape.cote(id) + " ORDER BY sort_order ");

        rsDesc = Etn.execute("Select * from "+dbname+"catalog_descriptions where catalog_id = " + escape.cote(id));
    }

    //String backto = parseNull(request.getParameter("backto"));
    //if(backto.length() == 0) backto = "commercialProducts.jsp";
     String backto = "";
     backto = "catalogs.jsp";

    LinkedHashMap<String, String> priceformatters = new LinkedHashMap<String, String>();
    priceformatters.put("","---- select ----");
    priceformatters.put("french","French");
    priceformatters.put("german","German");
    priceformatters.put("us","US");


    LinkedHashMap<String, String> rountodecimals = new LinkedHashMap<String, String>();
    rountodecimals.put("","---");
    rountodecimals.put("0","0");
    rountodecimals.put("1","1");
    rountodecimals.put("2","2");
    rountodecimals.put("3","3");

    LinkedHashMap<String, String> showdecimals = new LinkedHashMap<String, String>();
    showdecimals.put("","---");
    showdecimals.put("0","0");
    showdecimals.put("1","1");
    showdecimals.put("2","2");
    showdecimals.put("3","3");

    int nlangs = langsList.size();
    /*if(lang_1.length() > 0) nlangs++;
    if(lang_2.length() > 0) nlangs++;
    if(lang_3.length() > 0) nlangs++;
    if(lang_4.length() > 0) nlangs++;
    if(lang_5.length() > 0) nlangs++;*/
    int widthlangcol = 16;
    if(nlangs > 0) widthlangcol = 85/nlangs;


    Map<String, String> catalogTypes = new LinkedHashMap<String, String>();
    Set rsCatalogTypes = Etn.execute("select * from catalog_types order by name ");
    while(rsCatalogTypes.next()){
        catalogTypes.put(rsCatalogTypes.value("value"), rsCatalogTypes.value("name"));
    }

    ArrayList<KeyValuePair<String, String>> pageTemplatesList = new ArrayList<KeyValuePair<String,String>>();
    Set ptRs = Etn.execute("SELECT id, name FROM "+GlobalParm.getParm("PAGES_DB")+".page_templates WHERE site_id = "+escape.cote(selectedsiteid)+" ORDER BY is_system DESC, name ASC");
    while(ptRs.next()){
        pageTemplatesList.add(new KeyValuePair(ptRs.value("id"), ptRs.value("name")));
    }
    boolean canChangeCatalogType = (rs == null);
    // if(id.length() > 0)
    // {
    //  Set rsp = Etn.execute("select * from "+dbname+"products where catalog_id = " + escape.cote(id));
    //  //once products are added to catalog we will not allow to change catalog type as it can create problems
    //  if(rsp.rs.Rows > 0) canChangeCatalogType = false;
    // }

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
    <title><%=getValue(rs,"name")%></title>

    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
    <script src="<%=request.getContextPath()%>/js/etn.asimina.js"></script>

    <link href="<%=request.getContextPath()%>/css/spectrum.min.css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/spectrum.min.js"></script>

    <script src="<%=request.getContextPath()%>/js/urlgen/etn.urlgenerator.js"></script>
    <script type="text/javascript">
        window.URL_GEN_AJAX_URL = "<%=request.getContextPath()%>/js/urlgen/urlgeneratorAjax.jsp";

        // for media library
        window.PAGES_APP_URL = '<%=parseNull(GlobalParm.getParm("PAGES_APP_URL"))%>';
        window.MEDIA_LIBRARY_UPLOADS_URL = '<%=parseNull(GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL"))+selectedsiteid+"/"%>';
        window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = window.MEDIA_LIBRARY_UPLOADS_URL + 'img/';
    </script>

    <style>
        .lang_tabs
        {
            padding-top:5px;
            padding-bottom:5px;
            padding-left:15px;
            padding-right:15px;
            font-weight:bold;
            background-color:#eee;
            border-bottom:1px solid #ddd;
            border-right:1px solid #ddd;
        }
        .selected_lang_tab
        {
            background-color:orange;
        }

        .lang1show
        {
            display:none;
        }
        .lang2show
        {
            display:none;
        }
        .lang3show
        {
            display:none;
        }
        .lang4show
        {
            display:none;
        }
        .lang5show
        {
            display:none;
        }

        .prod-type-error{
            border-color: red;
        }

        #attribList input.attribute_name, #attribListSpecs input.attribute_name{
            width : 250px;
        }

        .orange-app-hidden{
            <%=isOrangeApp?"display:none;":""%>
        }

        .currency_hide {
            display: none;
        }


    </style>
</head>
	<%
	breadcrumbs.add(new String[]{"Content", ""});
	breadcrumbs.add(new String[]{"Products", "catalogs.jsp"});
	if(id.length() == 0 ) breadcrumbs.add(new String[]{"New Catalog", ""});
	else breadcrumbs.add(new String[]{getValue(rs,"name"), ""});
	%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
    <!-- title -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
        <div>
            <% if(id.length() == 0 ) { %>
                <h1 class="h2" >New Catalog
                <span style="height: 25px; width: 25px; border-radius: 50%; border: 1px solid rgb(221, 221, 221); display: inline-block; vertical-align: middle; margin-left: 15px; user-select: auto;" class="bg-success">
                                    </span>
                </h1>
            <% } else { %>
                <h1 class="h2" >
                    <%=getValue(rs,"name")%>
                    <span style="height: 25px; width: 25px; border-radius: 50%; border: 1px solid rgb(221, 221, 221); display: inline-block; vertical-align: middle; margin-left: 15px; user-select: auto;" class="bg-success">
                                    </span>

                </h1>
            <% } %>
            <p class="lead"></p>
        </div>

        <!-- buttons bar -->
        <div class="btn-toolbar mb-2 mb-md-0">
            <div class="btn-group mr-2" role="group" aria-label="...">
                <button type="button" class="btn btn-default btn-primary" id='backbtn' onclick='javascript:window.location="<%=backto%>";'>Back</button>
                <%if(!bIsProd){%>
                <button id="savebtn1" type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
                <%}%>
            </div>
            <div class="btn-group mr-2" role="group" aria-label="...">
                <%if(bIsProd){%>
                <button type="button" class="btn btn-success issaved" onclick="javascript:window.location='prodproducts.jsp?cid=<%=id%>';">Products</button>
                <%} else {%>
                <button type="button" class="btn btn-success issaved" onclick="javascript:window.location='catalogs.jsp?cid=<%=id%>';">Products</button>
                <%}%>
            </div>
            <div class="btn-group" role="group" aria-label="...">
                <%if(!bIsProd){%>
                <button type="button" class="btn btn-danger issaved"
                    onclick="onbtnclickpublish('<%=getValue(rs,"id")%>', 'catalog','publish')" >Publish to prod</button>
                <!-- <button type="button" class="btn btn-danger issaved" id='prodpublishbtn'>Publish to prod</button> -->

                <%}%>
            </div>
        </div>
        <!-- /buttons bar -->
    </div><!-- /d-flex -->
    <!-- /title -->
    <!-- container -->
    <div class="animated fadeIn">
        <!-- messages zone  -->
        <div class='m-b-20'>
            <!-- info -->
            <% if(!bIsProd && lastpublish.length() > 0) { %>
                <div id='infoBox' class="alert alert-success mb-1" role="alert" >
                    <div id=''>Last published on : <%=lastpublish%></div>
                </div>
                <% if(nextpublish.length() > 0) { %>
                    <div id='infoBox' class="alert alert-danger mb-1" role="alert" >
                        <div id=''><span >Next publish on : </span><span style='color:red'><%=nextpublish%></span></div>
                        <% if(!bIsProd) { %><div ><span style='color:red'>WARNING!!!</span> If you make any changes now those will be published also</div><%}%>
                    </div>
                <% } %>
            <% } %>
            <%
                String catalogSaveMsg = parseNull(session.getAttribute("CATALOG_SAVE_MSG"));
                if(catalogSaveMsg.length() > 0){
                    session.removeAttribute("CATALOG_SAVE_MSG");
            %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                  <span><%=catalogSaveMsg%></span>
                  <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                  </button>
                </div>
            <%
                }
            %>
            <!-- /info -->
        </div>
        <div id='errmsg' class="alert alert-danger" role="alert" style="display:none"></div>
        <!-- messages zone  --></div>
        <form name='frm' id='frm' method='POST' action='savecatalog.jsp' enctype='multipart/form-data'>
            <input type='hidden' name='id' id='catalog_id' value='<%=getValue(rs, "id")%>' />

        <div class="multilingual-section">
            <!-- Catalog definition -->
            <div class="card mb-2">
                <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" >
                    <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#catalog-definition-collapse" role="button" style="padding:0.75rem 1.25rem;color:#3c4b64">
                        <strong>Catalog definition</strong>
                    </button>
                    <% if(!bIsProd) { %>
                       <button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
                    <%}%>
                </div>
                <div class="collapse border-0 show" id="catalog-definition-collapse">
                    <div class="card-body">
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Name</label>
                            <div class="col-sm-9">
                                <input type='text' class='form-control' <%=readonly%> name='name' id='name' value='<%=getValue(rs,"name")%>' size="40">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Catalog type</label>
                            <div class="col-sm-9">
                                <%if(canChangeCatalogType){%>
                                    <select class='custom-select' name='catalog_type' id='catalog_type'>
                                        <option value="">-- Catalog Type --</option>
                                        <%
                                        for(String catalogTypeVal : catalogTypes.keySet()) { %>
                                                        <option <%if(catalogTypeVal.equals(catalogtype)){%>selected<%}%> value='<%=catalogTypeVal%>'><%=catalogTypes.get(catalogTypeVal)%></option>
                                        <% } %>
                                    </select>
                                    <%} else {%>
                                        <input type='text' class="form-control" readonly value='<%=catalogTypes.get(catalogtype)%>' />
                                        <input type='hidden' name='catalog_type' id='catalog_type' value='<%=catalogtype%>' />
                                    <%}%>
                            </div>
                        </div>
                        <div class="form-group row d-none">
                            <label class="col-sm-3 col-form-label">Display</label>
                            <div class="col-sm-9">
                                <select class='custom-select' name='view_name' id='view_name'>
                                    <option value="listing">Vertical listing</option>
                                    <option <%if("gridview".equals(viewname)){%>selected<%}%> value='gridview'>Grid Layout 1</option>
                                    <option <%if("gridview1".equals(viewname)){%>selected<%}%> value='gridview2'>Grid Layout 2</option>
                                    <option <%if("gridview2".equals(viewname)){%>selected<%}%> value='gridview3'>Grid Layout 3</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group row d-none">
                            <label class="col-sm-3 col-form-label">Hub Display</label>
                            <div class="col-sm-9">
                                <input type='text' maxlength='50' class='form-control' id='hub_page_orientation' name='hub_page_orientation' value='<%=getValue(rs,"hub_page_orientation")%>' placeholder="Hub page orientation">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Prices tax included ?</label>
                            <div class="col-sm-9">
                                <select class='custom-select' name='price_tax_included' id='price_tax_included'>
                                    <option value="0" <%=priceTaxIncluded?"":"selected"%> >No</option>
                                    <option value="1" <%=priceTaxIncluded?"selected":""%> >Yes</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group row <%=(ecommerceEnabled?"":"d-none")%>">
                            <label class="col-sm-3 col-form-label">Buy Status</label>
                            <div class="col-sm-9">
                                <select class='custom-select' name='buy_status' id='buy_status'>
                                    <option value="all" <%=getValue(rs,"buy_status").equals("all")?"selected":""%> >All</option>
                                    <option value="logged" <%=getValue(rs,"buy_status").equals("logged")?"selected":""%> >Logged-In Users</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Default sorting</label>
                            <div class="col-sm-9">
                                <select class='custom-select' name='default_sort' id='default_sort'>
                                    <option value="promotion" <%=getValue(rs,"default_sort").equals("promotion")?"selected":""%> >Promotion</option>
                                    <option value="new" <%=getValue(rs,"default_sort").equals("new")?"selected":""%> >Nouveautés</option>
                                    <option value="low" <%=getValue(rs,"default_sort").equals("low")?"selected":""%> >Prix croissants</option>
                                    <option value="high" <%=getValue(rs,"default_sort").equals("high")?"selected":""%> >Prix décroissants</option>
                                    <option value="all" <%=getValue(rs,"default_sort").equals("all")?"selected":""%> >Tous les produits</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Variant</label>
                            <div class="col-sm-9">
                            <select class='custom-select' name='html_variant' id='html_variant'>
                                    <option value="all" <%=getValue(rs,"html_variant").equals("all")?"selected":""%> >All</option>
                                    <option value="anonymous" <%=getValue(rs,"html_variant").equals("anonymous")?"selected":""%> >Anonymous</option>
                                    <option value="logged" <%=getValue(rs,"html_variant").equals("logged")?"selected":""%> >Logged</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Page template</label>
                            <div class="col-sm-9">

                                <%=UIHelper.getLangSelectsRowWise(langsList,"cat_desc_page_template_id_lang_%s", "cat_desc_page_template_id_lang_%s", pageTemplatesList," page_template_id custom-select", " required " ,"page_template_id",rsDesc )%>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- /Catalog definition -->

            <!-- Tax definition -->
            <div class="card mb-2">
                <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" >
                    <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#catalog-tax-definitions-collapse" role="button" style="padding:0.75rem 1.25rem;color:#3c4b64">
                        <strong>Tax definition</strong>
                    </button>
                    <% if(!bIsProd) { %>
                       <button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
                    <%}%>
                </div>
                <div class="col-12 border-0 collapse" id="catalog-tax-definitions-collapse">
                    <div class="card-body">
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Tax percentage</label>
                            <div class="col-sm-9">
                                <input type='text' class='form-control' name='tax_percentage' value='<%=getValue(rs, "tax_percentage")%>' onkeyup="allowFloatOnly(this);" onchange="formatNumber(this,2);">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Show prices with tax?</label>
                            <div class="col-sm-9">
                                <select name='show_amount_tax_included' class='custom-select'>
                                    <option <%if("1".equals(getRsValue(rs, "show_amount_tax_included"))){%>selected<%}%> value='1'>Yes</option>
                                    <option <%if("0".equals(getRsValue(rs, "show_amount_tax_included"))){%>selected<%}%> value='0'>No</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- /Tax definition -->

            <!-- Catalog description -->
            <div class="card mb-2">
                <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" >
                    <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#catalog-description-collapse" role="button" style="padding:0.75rem 1.25rem;color:#3c4b64">
                        <strong>Catalog description</strong>
                    </button>
                    <% if(!bIsProd) { %>
                       <button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
                    <%}%>
                </div>
                <div class="col-12 border-0 collapse" id="catalog-description-collapse">
                        <div class="card-body">

                            <!-- Language catalog description -->
                            <div class="w-100">
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Title</label>
                                    <div class="col-sm-9">
                                        <%=UIHelper.getLangInputs(langsList,"lang_%s_heading","lang_%s_heading","lang_%s_heading",rs)%>
                                    </div>
                                </div>

                                <div class="form-group row d-none">
                                    <label class="col-sm-3 col-form-label">Detail title</label>
                                    <div class="col-sm-9">
                                        <%=UIHelper.getLangInputs(langsList,"lang_%s_details_heading","lang_%s_details_heading","lang_%s_details_heading",rs)%>
                                    </div>
                                </div>

                                <div class="form-group row d-none">
                                    <label class="col-sm-3 col-form-label">Hub title</label>
                                    <div class="col-sm-9">
                                        <%=UIHelper.getLangInputs(langsList,"lang_%s_hub_page_heading","lang_%s_hub_page_heading","lang_%s_hub_page_heading",rs)%>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Description</label>
                                    <div class="col-sm-9">
                                        <%=UIHelper.getLangInputs(langsList,"lang_%s_description","lang_%s_description","lang_%s_description",rs," cat_lang_description ")%>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Top banner</label>
                                    <div class="col-sm-9">
                                        <div class="input-group mb-3">
                                            <%=UIHelper.getLangInputs(langsList,"lang_%s_top_banner_path","lang_%s_top_banner_path"
                                                ,"lang_%s_top_banner_path",rs, " top_banner_path")%>
                                        </div>
                                        <div class="d-none">
                                            <%=UIHelper.getLangInputsRowWise(langsList,"top_banner_path_opentype_%s","","top_banner_path_opentype",rsDesc, " top_banner_path_opentype d-none ")%>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Apply to : </label>
                                    <div class="col-sm-9" style="margin-top: 5px;">
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="checkbox"
                                             name="topban_product_list"
                                             value="<%=escapeCoteValue(topBanProductList)%>"
                                             <%=topBanProductList.equals("1")?"checked":""%> >
                                            <label class="form-check-label" for="topban_product_list">Product list</label>
                                        </div>
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="checkbox"
                                             name="topban_product_detail"
                                             value="<%=escapeCoteValue(topBanProductDetail)%>"
                                             <%=topBanProductDetail.equals("1")?"checked":""%> >
                                            <label class="form-check-label" for="topban_product_detail">Product detail</label>
                                        </div>
                                        <div class="form-check form-check-inline d-none">
                                            <input class="form-check-input" type="checkbox"
                                             name="topban_hub"
                                             value="<%=escapeCoteValue(topBanHub)%>"
                                             <%=topBanHub.equals("1")?"checked":""%> >
                                            <label class="form-check-label" for="topban_hub">Hub</label>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Bottom banner</label>
                                    <div class="col-sm-9">
                                        <div class="input-group mb-3">
                                            <%=UIHelper.getLangInputs(langsList,"lang_%s_bottom_banner_path","lang_%s_bottom_banner_path","lang_%s_bottom_banner_path",rs, " bottom_banner_path")%>
                                        </div>
                                        <div class="d-none">
                                            <%=UIHelper.getLangInputsRowWise(langsList,"bottom_banner_path_opentype_%s","","bottom_banner_path_opentype",rsDesc, " bottom_banner_path_opentype d-none ")%>
                                        </div>
                                    </div>
                                </div>


                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Apply to : </label>
                                    <div class="col-sm-9" style="margin-top: 5px;">
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="checkbox"
                                             name="bottomban_product_list"
                                             value="<%=escapeCoteValue(bottomBanProductList)%>"
                                             <%=bottomBanProductList.equals("1")?"checked":""%> >
                                            <label class="form-check-label" for="bottomban_product_list">Product list</label>
                                        </div>
                                        <div class="form-check form-check-inline">
                                            <input class="form-check-input" type="checkbox"
                                             name="bottomban_product_detail"
                                             value="<%=escapeCoteValue(bottomBanProductDetail)%>"
                                             <%=bottomBanProductDetail.equals("1")?"checked":""%> >
                                            <label class="form-check-label" for="bottomban_product_detail">Product detail</label>
                                        </div>
                                        <div class="form-check form-check-inline d-none">
                                            <input class="form-check-input" type="checkbox"
                                             name="bottomban_hub"
                                             value="<%=escapeCoteValue(bottomBanHub)%>"
                                             <%=bottomBanHub.equals("1")?"checked":""%> >
                                            <label class="form-check-label" for="bottomban_hub">Hub</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- /Language catalog description -->

                            <%@ include file="catalog_essential_blocks.jsp" %>

                        </div>

                </div>
            </div>
            <!-- /Catalog description -->

            <!-- SEO Information -->
            <div class="card mb-2">
                <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" >
                    <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#seo-information-collapse" role="button" style="padding:0.75rem 1.25rem;color:#3c4b64">
                        <strong>SEO Information</strong>
                    </button>
                    <% if(!bIsProd) { %>
                       <button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
                    <%}%>
                </div>
                <div class="col-12 border-0 collapse" id="seo-information-collapse">
                    <div class="card-body">

                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Prefix Path</label>
                            <div class="col-sm-9">
                                <%=UIHelper.getLangInputsRowWise(langsList,"cat_desc_folder_name_lang_%s","cat_desc_folder_name_lang_%s","folder_name",rsDesc, " folder_name ")%>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Path</label>
                            <div class="col-sm-9">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">/</span>
                                    </div>
                                    <%=UIHelper.getLangInputsRowWise(langsList,"cat_desc_page_path_lang_%s","cat_desc_page_path_lang_%s","page_path",rsDesc, " page_path ","required")%>
                                    <div class="input-group-append">
                                        <span class="input-group-text">.html</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Canonical URL</label>
                            <div class="col-sm-9">
                                <%=UIHelper.getLangInputsRowWise(langsList,"cat_desc_canonical_url_lang_%s","cat_desc_canonical_url_lang_%s","canonical_url",rsDesc, " canonical_url ")%>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">SEO description</label>
                            <div class="col-sm-9">
                                <div class="input-group mb-3">
                                    <%=UIHelper.getLangInputs(langsList,"lang_%s_meta_description","lang_%s_meta_description","lang_%s_meta_description",rs, "meta_description_input rounded-left")%>

                                    <%=UIHelper.getLangFields(langsList,"<div class='input-group-append asimina-multilingual-block' id='description_seo_lang_%1$s_count_append' ><span class='input-group-text rounded-right' id='description_seo_lang_%1$s_count' data-language-id='%1$s'>0</span></div>")%>
                                </div>
                            </div>
                    </div>

                        <div class="form-group row d-none">
                            <label class="col-sm-3 col-form-label">SEO keywords</label>
                            <div class="col-sm-9">
                                <%=UIHelper.getLangInputs(langsList,"lang_%s_meta_keywords","lang_%s_meta_keywords","lang_%s_meta_keywords",rs)%>

                            </div>
                        </div>

                    </div>
                </div>
            </div>
            <!-- /SEO Information -->


            <div class="">
                <%@ include file="catalog_attributes.jsp" %>
            </div>

        </div>
        <!-- div.multilingual-section -->

            <!-- Catalog properties , hidden/deprecated -->
            <div class="row d-none">
                <div class="btn-group col-12 px-0 mb-2" role="group" >
                    <button type="button" class="btn btn-secondary btn-lg btn-block text-left" data-toggle="collapse" href="#catalog-properties-collapse" role="button" >
                        Catalog properties
                    </button>
                    <% if(!bIsProd) { %>
                       <button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
                    <%}%>
                </div>
                <div class="col-12 p-3 collapse" id="catalog-properties-collapse">
                    <!-- Product type -->

                    <div class="btn-group col-12 px-0 mb-2" role="group" >
                        <button type="button" class="btn btn-success btn-lg btn-block text-left" role="button" >
                            Custom Product Types
                        </button>

                    </div>
                    <div class="d-none">
                        <input type="hidden" name="product_types_custom" id="product_types_custom" value='<%=getValue(rs,"product_types_custom")%>' />

                        <ul id="productTypeTemplate" class="list-group" >
                            <li class="list-group-item">
                                Display Label :
                                <input type="text" name="ignore" class="productTypeLabel form-control" value="" onchange="checkProductType(this)"  maxlength='100' />
                                &nbsp;System Value :
                                <input type="text" name="ignore" class="productTypeValue form-control" value="" onchange="checkProductType(this);" onkeyup="formatProductTypeValue(this);" maxlength='100' />

                                &nbsp; <button type="button" onclick='removeProductType(this);' class="btn btn-danger"><span class="oi oi-x"></span></button>
                            </li>
                        </ul>
                    </div>
                    <div class="px-3 pb-3 ">
                        <div class="w-100 form-inline">
                            <ul id="productTypesList" class="list-group">

                            </ul>
                        </div>
                        <% %>
                        <div class="w-100 pt-3">
                            <button type="button" class="btn btn-success" onclick='addProductType()' <%=(rs==null)?"disabled":""%>>Add a custom type</button>
                        </div>
                        <%%>
                    </div>

                    <!-- /Product type -->

                </div>
            </div>
            <!-- /Catalog properties -->

            <div class="row justify-content-end">
                <a href="#"  class="arrondi htpage">^ Top of screen ^</a>
            </div>

        </form>
    </div>
</main>
<!-- /id=container -->

<!-- .modal -->
<div class="modal fade" id="publishdlg" tabindex="-1" role="dialog">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <!-- modal content goes here -->
    </div>
  </div>
</div>

<!-- /.modal -->

<%if(!bIsProd){%>
    <!-- .modal -->
    <%-- <div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'>
    </div> --%>
    <div class="modal fade" id="publishdlg" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
        <!-- modal content goes here -->
        </div>
    </div>
    </div>
    <!-- /.modal -->

    <div class="modal fade" id="urldlg" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
        <!-- modal content goes here -->
        </div>
    </div>
    </div>

    <div class="modal fade" id="natureDialog" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
        <!-- modal content goes here -->
        </div>
    </div>
    </div>

    <%
        String prodpushid = id;
        String prodpushtype = "catalog";
    %>
    <%@ include file="../prodpublishloginmultiselect.jsp"%>
<%}%>


    <%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /c-body -->

<script>

    etn.asimina.page.ready(100,function(e){

        var extraSelectors = ["input.form-check-input"];
        etn.asimina.langtabs.init(<%=new JSONArray(langsList)%>, extraSelectors);
        etn.asimina.constants.init(<%=com.etn.asimina.data.ConstantsFactory.instance.getJSON().toString()%>);

        $("input.meta_description_input").on("input",function(e){
            var langId = $(this).attr("data-language-id");
            if(langId){
                $("#description_seo_lang_" + langId + "_count").html($(this).val().length);
            }
        }).trigger('input');

        $("input.cat_lang_description").on("change",function(e){
            var langId = $(this).attr("data-language-id");
            var seoDescription = $('#lang_'+langId+'_meta_description');
            seoDescription.val($(this).val().trim()).triggerHandler('input');

        });

        var updateSEOInfo = function(langId)
		{
			var catalogName = $("#name").val();
			var catalogId = $("#catalog_id").val();
			var pagePath = $("#cat_desc_page_path_lang_"+langId);
			var folderName = $("#cat_desc_folder_name_lang_"+langId);

			//page path will only be set for a new catalog ... we don't want to disturb page path once a catalog is saved
			if(catalogId == "" && folderName.length > 0 && catalogName.length > 0)
			{
				var folderStr = catalogName;

				folderName.val("");
				$.each(folderStr.split(" "), function(index, val)
				{
					if(val.length === 0 || val == "|")
					{
						return true;
					}

					folderName.val(folderName.val() + " " + val);
					folderName.triggerHandler("input");
				});
				folderName.triggerHandler('blur');
			}

			//page path will only be set for a new catalog ... we don't want to disturb page path once a catalog is saved
			if(catalogId == "" && pagePath.length > 0 && catalogName.length > 0)
			{
				var pathStr = catalogName;

				pagePath.val("catalogs/");
				$.each(pathStr.split(" "), function(index, val)
				{
					if(val == "|")
					{
						return true;
					}

					pagePath.val(pagePath.val() + " " + val);
					pagePath.triggerHandler("input");
				});
				pagePath.triggerHandler('blur');
			}
		};

		$("#name").on("change",function(e)
		{
			$(".page_path").each(function()
			{
				var langId = $(this).attr("data-language-id");
				updateSEOInfo(langId);
			});
		});

    });


    function onFolderKeyUp(input){
        var val = $(input).val();
        val = val.trimLeft()
                    .replace(" ","-")
                    .replace(/[^a-zA-Z0-9-]/g,'')
                    .replace('--','-');
        if(val.startsWith("-")){
            val = val.substring(1);
        }
        $(input).val(val.toLowerCase());
    }

    function onFolderBlur(input){
        var val = $(input).val();

        if(val.endsWith("/")){
            val = val.substring(0,val.length-1);
        }
        $(input).val(val.toLowerCase());
    }

    jQuery(document).ready(function() {
        var anythingchanged=  false;

        initAttributes();

        initUrlGeneratorFields();

        $('input.page_path').on("input",function(e){
            onPathKeyup(this);
        }).on("blur",function(e){
            onPathBlur(this);
        });

        $('input.folder_name').on("input",function(e){
            onFolderKeyUp(this);
        }).on("blur",function(e){
            onFolderBlur(this);
        });

        if($("#catalog_id").val().length > 0){
            $(".issaved").show();
        }
        else{
            $(".issaved").hide();
        }

        onsave = function() {
            etn.asimina.langtabs.selectFirstLang();
            $("#errmsg").html("");
            $("#errmsg").fadeOut();
            if($.trim($("#name").val()) == '')
            {
                $("#errmsg").html("Provide catalog name");
                $("#errmsg").fadeIn();
                return;
            }
            if($.trim($("#catalog_type").val()) == '')
            {
                $("#errmsg").html("Select appropriate catalog type");
                $("#errmsg").fadeIn();
                return;
            }
            var invalidFields = $('#frm input.is-invalid, #frm input:invalid');
            if(invalidFields.length > 0){
                $("#errmsg").html("Fields have invalid values.");
                $ ("#errmsg").fadeIn();
                invalidFields.first().focus();
                return;
            }

            setProductTypes();

            //we have to replace src= with something else otherwise XSS filter removes that from ckeditor fields
            //when saving in db we will revert it back to src= so that image shows up next time
            $(".ckeditor_field").each(function(){
                var _id = $(this).attr('id');
                var vl = CKEDITOR.instances[_id].getData();

                if(vl.indexOf("src=") > -1)
                {
                    vl = vl.replace(/src=/gi,"_etnipt_=");
                }
                if(vl.indexOf("href=") > -1)
                {
                    vl = vl.replace(/href=/gi,"_etnhrf_=");
                }
                if(vl.indexOf("style=") > -1)
                {
                    vl = vl.replace(/style=/gi,"_etnstl_=");
                }

                //set value in hidden alternative field
                //this hack is needed because ckeditor updates the associated textarea
                // on form submit event.
                var hiddenAltField = $("#" + _id + "_ipt");
                if(hiddenAltField.length == 0){
                    hiddenAltField = $("<input>").attr("type","hidden")
                        .attr("name",$(this).attr("name"));
                    //insert before textarea
                    $(this).before(hiddenAltField);
                }
                $(this).attr("name","ignore");

                hiddenAltField.val(vl);
            });

    		var _data = "id=<%=id%>&type=catalog";
    		$(".page_path").each(function(){
    			_data += "&" + $(this).attr("name") + "=" + $(this).val();
    		});

            $.ajax({
                url : 'checkpathsuniqueness.jsp',
                type: 'POST',
                data: _data,
                dataType : 'json',
                success : function(resp)
                {
                  	if(resp.status == 0) $("#frm").submit();
    	            else
                	{
                             	bootNotifyError(resp.msg);

                		$("#errmsg").html(resp.msg);
                		$("#errmsg").fadeIn();
                		$("#errmsg").focus();
                	}
                },
                error : function  ()
                {
                  	alert("Error while communicating with the server");
                }
            });

        };

        refreshscreen=function()
        {
            window.location = "catalog.jsp?id=<%=id%>";
        }

        $("input[type=text],select,textarea,input[type=checkbox]").change(function(){
            anythingchanged = true;
        });

        goback=function()
        {
            if(anythingchanged)
            {
                if(!confirm("Do you want to discard the changes?")) return;
            }
            window.location="<%=backto%>";
        };

        configureurl=function(urltype)
        {
            $("#urldlg").find(".modal-content").html("<div style='color:red'>Loading .....</div>");
            $("#urldlg").modal('show');
            $.ajax({
                    url : '../shopurl.jsp',
                           type: 'POST',
                        data: {id : '<%=id%>', urltype : urltype, catalog : 'catalogs'},
                           success : function(resp)
                        {
                    $("#urldlg").find(".modal-content").html(resp);
                         },
                error : function()
                {
                    alert("Error while communicating with the server");
                }
            });
        };

        openHelp=function()
        {
            var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
            prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
            prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
            var _previewwin = window.open("hubpagehelp.html","Help", prop);
            _previewwin.focus();
        };



        if($('#invoice_nature').val() === ''){
            $('#clearNatureBtn').hide();
        }

        initProductTypes();

        $(".form-check-input").click(function(){

            if($(this).val()==0) $(this).val("1");
            else $(this).val("0");

        });

    });//end document ready

    function initUrlGeneratorFields(){
        if(!etn || !etn.initUrlGenerator){
            return false;
        }

        var urlGenOpts = {
            showOpenType : true,
            allowEmptyValue : true
        };
        var OPENTYPE_VALID_VALUES = ["same_window", "new_tab", "new_window"];
        $('input.top_banner_path, input.bottom_banner_path').each(function(index, input) {
            input = $(input);
            var gen = etn.initUrlGenerator(input, window.URL_GEN_AJAX_URL, urlGenOpts);
            var langId = input.attr('data-language-id');

            var openTypeSelect = gen.getOpenTypeSelect();
            openTypeSelect.attr('multilingual','ignore');

            var openTypeVal = "";
            if(input.hasClass("top_banner_path")){
                openTypeVal = $('#top_banner_path_opentype_'+langId).val();
            }
            else{
                openTypeVal = $('#bottom_banner_path_opentype_'+langId).val();
            }

            if(OPENTYPE_VALID_VALUES.indexOf(openTypeVal) >= 0){
                openTypeSelect.val(openTypeVal);
            }

            var urlGenDiv = gen.getUrlGenDiv();
            urlGenDiv.addClass('asimina-multilingual-block');
            urlGenDiv.attr('id',input.attr('id')+'_url_container');
            urlGenDiv.attr('data-language-id',langId);
            urlGenDiv.attr('multilingual','true');
            if(input.css('display') == 'none'){
                urlGenDiv.css('display','none');
            }

        });

    }

    function seturl(id, url){
        $("#"+id).val(url);
    };

    function setNature(natureVal){
        if(natureVal != ""){
            $('#invoice_nature').val(natureVal);
            $('#invoice_nature_value').text(natureVal);
            $('#clearNatureBtn').show();
            $('#natureDialog').modal('hide');
        }
    }

    function clearNature(){
        $('#invoice_nature').val('');
        $('#invoice_nature_value').text('');
        $('#clearNatureBtn').hide();
    }

    function showHideNatureChilds(familyCount) {
        var _hidden = $("#genre_is_hidden_" + familyCount).val();
        if (_hidden === '0') {
            $(".genre_childs_" + familyCount).hide();
            $("#genre_expand_" + familyCount).hide();
            $("#genre_collapse_" + familyCount).show();
            $("#genre_is_hidden_" + familyCount).val("1");
        }
        else {
            $(".genre_childs_" + familyCount).show();
            $("#genre_collapse_" + familyCount).hide();
            $("#genre_expand_" + familyCount).show();
            $("#genre_is_hidden_" + familyCount).val("0");
        }
    }


    <%
        if(!bIsProd) {

    %>
    //-- product type

    function checkProductType(ele){
        var li = $(ele).parent('li:first');

        var labelInput = li.find('input.productTypeLabel');
        var valueInput = li.find('input.productTypeValue');

        if(labelInput.length > 0 && valueInput.length > 0 ){
            labelInput.removeClass('prod-type-error');
            valueInput.removeClass('prod-type-error');

            formatProductTypeValue(valueInput);

            if(labelInput.val().trim().length === 0){
                labelInput.addClass('prod-type-error');
            }

            if(valueInput.val().trim().length === 0){
                valueInput.addClass('prod-type-error');
            }

        }
    }

    function formatProductTypeValue(input){
        $(input).val($(input).val().replace(/[^\w\d-_]/g,''));
    }

    var MAX_PROD_TYPE_COUNT = 20;
    function addProductType(productTypeObj){

        if( $('#productTypesList li').length >= MAX_PROD_TYPE_COUNT){
            var msg = "Cannot add more than '" + MAX_PROD_TYPE_COUNT + "' product types.";
            alert(msg);
            return false;
        }

        var li  = $('#productTypeTemplate li:first').clone(true);

        if(typeof productTypeObj != 'undefined'
            && typeof productTypeObj["label"] != 'undefined'
            && typeof productTypeObj["value"] != 'undefined'){

            var label = productTypeObj["label"];
            var value = productTypeObj["value"];
            try{
                if( label.trim().length > 0 && value.trim().length > 0  ){

                    li.find('input.productTypeLabel').val(label);

                    li.find('input.productTypeValue').val(value);
                }
            }
            catch(ex){

            }
        }

        $('#productTypesList').append(li);
    }

    function addManufacturer(manufacturerObj){

        var li  = $('#manufacturerTemplate li:first').clone(true);

        if(typeof manufacturerObj != 'undefined'
            && typeof manufacturerObj["name"] != 'undefined'){

            var name = manufacturerObj["name"];
            try{
                if( name.trim().length > 0 ){

                    li.find('input.manufacturerName').val(name);
                }
            }
            catch(ex){

            }
        }

        $('#manufacturersList').append(li);
    }

    function removeProductType(ele){
        if(confirm("Are you sure ?")){
            $(ele).parent('li:first').remove();
        }
    }


    function setProductTypes(){

        var productTypesList = [];

        $('#productTypesList li').each(function(index, el) {

            var label = $(el).find('input.productTypeLabel:first').val().trim();
            var value = $(el).find('input.productTypeValue:first').val().trim();

            try{
                if( label.length > 0 &&  value.length > 0 ){

                    productTypesList.push({
                        "label" : label,
                        "value" : value
                    });
                }

            }
            catch(ex){
                //skip
            }


        });

        $('#product_types_custom').val(JSON.stringify(productTypesList));
    }


    function setManufacturers(){

        var manufacturersList = [];

        $('#manufacturersList li').each(function(index, el) {

            var name = $(el).find('input.manufacturerName:first').val().trim();

            try{
                if( name.length > 0){

                    manufacturersList.push({
                        "name" : name
                    });
                }

            }
            catch(ex){
                //skip
            }


        });

        $('#manufacturers').val(JSON.stringify(manufacturersList));
    }

    function initProductTypes(){

        var prodTypeStr = $('#product_types_custom').val().trim();

        try{

            var productTypesList = null;
            try{
                productTypesList = JSON.parse(prodTypeStr);
            }
            catch(ex){ }


            if( $.isArray(productTypesList) && productTypesList.length > 0 ){

                for (var i = 0; i < productTypesList.length; i++) {
                    var productTypeObj = productTypesList[i];

                    addProductType(productTypeObj);
                }
            }
        }
        catch(ex){
            //do nothing
        }
    }

    function initManufacturers(){

        var manStr = $('#manufacturers').val().trim();

        try{

            var manufacturersList = null;
            try{
                manufacturersList = JSON.parse(manStr);
            }
            catch(ex){ }


            if( $.isArray(manufacturersList) && manufacturersList.length > 0 ){

                for (var i = 0; i < manufacturersList.length; i++) {
                    var manufacturerObj = manufacturersList[i];

                    addManufacturer(manufacturerObj);
                }
            }
        }
        catch(ex){
            //do nothing
        }
    }

    <%}else{%>
        //empty functions when page is opened from production view

        function initProductTypes ()
        {
        }
        function addProductType ()
        {
        }
        function initManufacturers ()
        {
        }
        function addManufacturer ()
        {
        }
    <%}%>

</script>
</body>
</html>