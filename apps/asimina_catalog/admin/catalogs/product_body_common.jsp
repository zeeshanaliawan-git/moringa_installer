<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.List, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.google.gson.*,com.google.gson.reflect.TypeToken" %>
<%@ page import="com.etn.asimina.data.LanguageFactory" %>
<%@ page import="com.etn.asimina.beans.Language" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="com.etn.beans.Contexte" %>
<%@ page import="com.etn.asimina.util.UIHelper"%>
<%@ page import="com.etn.asimina.util.ProductImageHelper"%>
<%@ page import="com.etn.asimina.util.ProductShareBarImageHelper"%>
<%@ page import="com.etn.asimina.util.ImageHelper"%>

<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%@ include file="/urlcreator.jsp"%>
<%@ include file="/WEB-INF/include/imager.jsp"%>
<%!

	void getFolders(com.etn.beans.Contexte Etn, String siteid, String folderid, Map<String, String> listOfFolders)
	{
		Set rs = Etn.execute("Select * from products_folders where site_id = "+escape.cote(siteid)+" and id = "+escape.cote(folderid));
		if(rs.next())
		{
			getFolders(Etn, siteid, rs.value("parent_folder_id"), listOfFolders);
			listOfFolders.put(rs.value("uuid"), rs.value("name"));
		}
	}

	String getPreviewMosaicUrl(Set rs)
	{
		if(rs == null) return "";

		String u = GlobalParm.getParm("EXTERNAL_CATALOG_LINK") + "admin/catalogs/pagePreview.jsp?ty=c&id="+rs.value("catalog_id");
		return u;
	}

	String getPreviewUrl(Set rs)
	{
		if(rs == null) return "";

		String u = GlobalParm.getParm("EXTERNAL_CATALOG_LINK") + "admin/catalogs/pagePreview.jsp?ty=p&id="+rs.value("id");
		return u;
	}

%>
<%
	String isProd = parseNull(request.getParameter("isprod"));
	boolean bIsProd = "1".equals(isProd);
  String selectedsiteid = getSelectedSiteId(session);
  List<Language> langsList = getLangs(Etn, selectedsiteid);
  Language firstLanguage = langsList.get(0);

	String dbname = "";
	if(bIsProd)
	{
		dbname = GlobalParm.getParm("PROD_DB") + ".";
	}

	boolean isOrangeApp = "1".equals(parseNull(GlobalParm.getParm("IS_ORANGE_APP")));


    String folderUuid = parseNull(request.getParameter("folderId"));
    String folderId = "0";
	String cid = parseNull(request.getParameter("cid"));
	if(cid.length() == 0)
	{
		out.write("<div style='font-weight:bold; color:red'>No catalog selected.</div><input type='button' value='Back' onclick='javascript:window.location=\"../gestion.jsp\";'>");
		return;
	}
	Set rscat = Etn.execute("select * from "+dbname+"catalogs where id = " + escape.cote(cid));
	if(rscat == null || rscat.rs.Rows == 0)
	{
		out.write("<div style='font-weight:bold; color:red'>No catalog selected.</div><input type='button' value='Back' onclick='javascript:window.location=\"../gestion.jsp\";'>");
		return;
	}
    if(folderUuid.length()>0){
        Set rsFolder = Etn.execute("select id from "+dbname+"products_folders where uuid = " + escape.cote(folderUuid));
        if(!rsFolder.next())
        {
            response.sendRedirect("catalogs.jsp?cid="+cid);
            return;
        }else{
            folderId = rsFolder.value("id");
        }
    }


	rscat.next();

	String id = parseNull(request.getParameter("id"));
    String catalogType = parseNull(rscat.value("catalog_type"));
    String backto = parseNull(request.getParameter("backto"));
    //if(backto.length() == 0) backto = "products.jsp?cid=" + cid;
    if(backto.length() == 0) backto = "catalogs.jsp?cid=" + cid;
    if(bIsProd) backto = "prodproducts.jsp?cid=" + cid;
    if(folderUuid.length()>0)   backto = backto+"&folderId="+folderUuid;
  
    Set rs3 = Etn.execute("select uuid from products_folders where id = (select folder_id from products where id=" + escape.cote(id) + ")");
    rs3.next();
        String uuid = rs3.value("uuid");
        backto = backto + "&folderId=" + uuid;
    
    

    boolean showManufacturers = ( "product".equals(catalogType)
                                    || "device".equals(catalogType)
                                    || "accessory".equals(catalogType) );

    String catTypeLabel = catalogType.replace("_"," ");


    ArrayList<String> arr = new ArrayList<String>();

    Set rs = null;
    if(id.length() > 0){
        rs = Etn.execute("SELECT p.*, c.price_tax_included, c.tax_percentage, c.invoice_nature AS default_invoice_nature "
        + " FROM "+dbname+"products p "
        + " JOIN "+dbname+"catalogs c ON p.catalog_id = c.id  "
        + " WHERE p.id =  " + escape.cote(id)
        + " AND c.id = " + escape.cote(cid));
        if(rs == null || !rs.next()){
            //if id was passed but was invalid
            //redirect response
            response.sendRedirect(backto);
        }
    }

    String prodType = getRsValue(rs,"product_type");
    if(prodType.length() == 0){
        Set rsCatalogTypes = Etn.execute("SELECT product_type FROM "+dbname+"catalog_types WHERE value="+escape.cote(catalogType));
        if(rsCatalogTypes.next()){
            prodType = getRsValue(rsCatalogTypes,"product_type");
        }
    }

    LinkedHashMap<String, String> yesno = new LinkedHashMap<String, String>();
    yesno.put("0","No");
    yesno.put("1","Yes");

    LinkedHashMap<String, String> yesno2 = new LinkedHashMap<String, String>();
    yesno2.put("1","Yes");
    yesno2.put("0","No");

    LinkedHashMap<String, String> hoursHM = new LinkedHashMap<String, String>();
    for(int h=0; h<24; h++){
        hoursHM.put(""+h, ""+h);
    }
    LinkedHashMap<String, String> minsHM = new LinkedHashMap<String, String>();
    minsHM.put("0","0");
    minsHM.put("15","15");
    minsHM.put("30","30");
    minsHM.put("45","45");

    LinkedHashMap<String, String> feedbackDDValues = new LinkedHashMap<String, String>();
    feedbackDDValues.put("0","No");
    feedbackDDValues.put("1","Logged-in Users");
    feedbackDDValues.put("2","All Users");

    LinkedHashMap<String, String> feedbackDDValues2 = new LinkedHashMap<String, String>();
    feedbackDDValues2.put("0","No");
    feedbackDDValues2.put("1","Visible and Editable Logged-in Users");
    feedbackDDValues2.put("2","Visible and Editable All Users");
    feedbackDDValues2.put("3","Editable Logged-in / Visible All");

    LinkedHashMap<String, String> variantSortOptionValues = new LinkedHashMap<String, String>();
    variantSortOptionValues.put("cda","Created date asc");
    variantSortOptionValues.put("cdd","Created date desc");
    variantSortOptionValues.put("pd","Price desc");
    variantSortOptionValues.put("pa","Price asc");
    variantSortOptionValues.put("cu","Custom");

    String lang_tab = parseNull(request.getParameter("lang_tab"));
    if(lang_tab.length() == 0) lang_tab = "lang"+firstLanguage.getLanguageId()+"show";

	String previewMosaicUrl = getPreviewMosaicUrl(rs);
	String previewUrl = getPreviewUrl(rs);

	String lastpublish = "";
	String nextpublish = "";
	String cachetask = "";

	if(rs != null)
	{
		String process = getProcess("product");
		Set rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" ");
		if(rspw.next()) nextpublish = parseNull(rspw.value(0));
		else
		{
			rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') as dt, task from "+GlobalParm.getParm("PREPROD_PORTAL_DB")+".cache_tasks where content_type = 'product' and status = 0 and site_id = "+escape.cote(selectedsiteid)+" and content_id = "+escape.cote(id) + " order by id limit 1");
			if(rspw.next()) 
			{
				cachetask = parseNull(rspw.value("task")).equals("generate")?"Enqueued for cache":"Enqueued for publish";
			}
		}

		rspw = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status  in (0, 2) and phase = 'published' and client_key = " + escape.cote(id) + " and proces = "+escape.cote(process)+" order by id desc limit 1 ");
		if(rspw.next()) lastpublish = parseNull(rspw.value(0));
	}



	Set rsfm = Etn.execute("select f.* from "+dbname+"familie f where f.catalog_id = " + escape.cote(cid) + " order by f.name " );

	Set catAttributesRs = Etn.execute("SELECT * FROM "+dbname+"catalog_attributes WHERE type = 'selection' AND catalog_id = " + escape.cote(cid) + " ORDER BY sort_order ");



    ProductImageHelper productImageHelper = null;
    ProductShareBarImageHelper productShareBarImageHelper = null;
    if(rs != null){
        productImageHelper = new ProductImageHelper(id);
        productShareBarImageHelper = new ProductShareBarImageHelper(id);
    }

	String specsCatAttributesQuery = "SELECT *,'' AS attribute_value_id,'' AS attribute_value FROM catalog_attributes WHERE type = 'specs' AND catalog_id = " + escape.cote(cid) + " ORDER BY sort_order ";

	Set catAttributeValuesRs = null;

	if(rs != null){
		catAttributeValuesRs = Etn.execute("SELECT v.*,c.value_type FROM "+dbname+"product_attribute_values AS v JOIN "+dbname+"catalog_attributes c ON c.cat_attrib_id = v.cat_attrib_id AND c.type = 'selection' WHERE catalog_id = " + escape.cote(cid) + " AND product_id = " + escape.cote(id) + " ORDER BY c.sort_order,v.sort_order ");

		specsCatAttributesQuery = "SELECT c.*, v.id AS attribute_value_id, v.attribute_value FROM catalog_attributes c "
 		+ " LEFT JOIN product_attribute_values v ON c.cat_attrib_id = v.cat_attrib_id AND product_id = " + escape.cote(id)
 		+ " WHERE type = 'specs' AND catalog_id = " + escape.cote(cid)
		+ " GROUP BY c.cat_attrib_id ORDER BY c.sort_order ";
	}


	Set specsCatAttributesRs = Etn.execute(specsCatAttributesQuery);

	boolean isPriceTaxIncluded = false;
	String taxPercentage = "0";
	if(rs != null){
		isPriceTaxIncluded = "1".equals(getRsValue(rs,"price_tax_included"));
		taxPercentage = getRsValue(rs,"tax_percentage");
	}
	else{
		Set catRs = Etn.execute("SELECT price_tax_included, tax_percentage FROM "+dbname+"catalogs WHERE id = "+escape.cote(cid));
		if(catRs!=null && catRs.next()){
			isPriceTaxIncluded = "1".equals(getRsValue(catRs,"price_tax_included"));
			taxPercentage = getRsValue(catRs,"tax_percentage");
		}
	}
	if(taxPercentage.length() == 0 ) taxPercentage = "0";
	
	//this list is in reverse order
	Map<String, String> listOfFolders = new LinkedHashMap<String, String>();
	listOfFolders.put("", rscat.value("name"));
	getFolders(Etn, rscat.value("site_id"), folderId, listOfFolders);
	
	String screenTitle = "";
	if(rs != null) { 
		screenTitle = "Edition of: " + escapeCoteValue(getValue(rs, "lang_"+firstLanguage.getLanguageId()+"_name"));
	}
	else
	{
		screenTitle = "Add a "+catTypeLabel;
	}                         
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>

    <title><%=screenTitle%></title>

    <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    <script src="<%=request.getContextPath()%>/js/etn.asimina.js"></script>
    <link href="<%=request.getContextPath()%>/css/bootstrap-colorpicker.min.css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/bootstrap-colorpicker.min.js"></script>

    <script src="<%=request.getContextPath()%>/js/urlgen/etn.urlgenerator.js"></script>
    <script type="text/javascript">
        window.URL_GEN_AJAX_URL = "<%=request.getContextPath()%>/js/urlgen/urlgeneratorAjax.jsp";

        // for media library
        window.PAGES_APP_URL = '<%=parseNull(GlobalParm.getParm("PAGES_APP_URL"))%>';
        window.MEDIA_LIBRARY_UPLOADS_URL = '<%=parseNull(GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL"))+selectedsiteid+"/"%>';
        window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = window.MEDIA_LIBRARY_UPLOADS_URL + 'img/';
    </script>
    <!--we need this here as it is the core library-->
    <style>
        .table tr td {border: 0px;}

    .lang_tabs
    {
      padding-top:5px;
      padding-bottom:5px;
      padding-left:25px;
      padding-right:25px;
      font-weight:bold;
      background-color:#fff;
      color: black;
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

    tr.attrib-value-row td{
      background-color: lightgrey;
    }

    div.attribute_value_image{
      position: relative;
      display: inline-block;
      cursor: pointer;
    }
    div.attribute_value_image div{
      display: none;
      position: absolute;
      left: 0;
      top: 0;
      background-color: rgba(255,255,255,0.5);
      width: 100%;
      height: 100%;
    }
    div.attribute_value_image:hover div {
      display: block;
      cursor: pointer;
    }
    div.attribute_value_image:hover div i.fa{
      font-size: 16px;
      display: block;
      margin: 5px;
    }

    .specs-attrib-table td{
      white-space: nowrap;
      border-bottom: lightgrey 1px solid;
      padding : 3px;
    }

    .specs-attrib-table th{
      font-weight: bold;
      background-color: lightgrey;
      padding : 3px;
      width: 150px;
    }

    .imageGalleryList{
      width: 100%;
      padding: 0px;
      list-style: none;
    }

    .imageGalleryList > .image-gallery-item{
      width: 30%;
      float: left;
      margin: 2px;
      padding: 2px;
      border: 1px dotted silver;

    }

    .imageGalleryList > .image-gallery-item img{
      max-width: 100%;
      max-height: 100%;
    }

    .image-gallery-item.selected-item {
      border: 1px solid blue;
    }

    .deleteSchedule{
      position: absolute;
      top: 0px;
      right: 2px;
      z-index: 999999;
    }

    .genre_childs a:hover{
      color:blue !important;
    }

    .ui-autocomplete{
      z-index: 99999;
    }

    span.fc-title{
      font-size: 0.85em !important;
    }

    .orange-app-hidden{
      <%=isOrangeApp?"display:none;":""%>
    }

  </style>
  <script>
    function previewMosaicNew() {
		let langid = 1;
		$(".nav-tabs").find(".nav-item").each(function(){
			let navlink = $(this).find(".nav-link");
			if(navlink && $(navlink).hasClass("active"))
			{
				langid = $(navlink).attr("data-language-id");
			}
		});
        var win = window.open("<%=previewMosaicUrl%>&langid="+langid, "Listing");
    }

    function previewProductNew() {
		let langid = 1;
		$(".nav-tabs").find(".nav-item").each(function(){
			let navlink = $(this).find(".nav-link");
			if(navlink && $(navlink).hasClass("active"))
			{
				langid = $(navlink).attr("data-language-id");
			}
		});
        var win = window.open("<%=previewUrl%>&langid="+langid, "Listing");
    }
	
  </script>
</head>

<%
	breadcrumbs.add(new String[]{"Content", ""});
	breadcrumbs.add(new String[]{"Products", "catalogs.jsp"});
	for(String fuuid : listOfFolders.keySet())
	{
		breadcrumbs.add(new String[]{escapeCoteValue(listOfFolders.get(fuuid)), "products.jsp?cid="+cid+"&folderId="+fuuid});
	}	
	breadcrumbs.add(new String[]{screenTitle, ""});
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
                      <h1 class="h2">
							<%=screenTitle%>
							<span style="height: 25px; width: 25px; border-radius: 50%; border: 1px solid rgb(221, 221, 221); display: inline-block; vertical-align: middle; margin-left: 15px; user-select: auto;" class="bg-success">
							</span>
                      </h1>
                      <p class="lead"></p>
                  </div>
                  <!-- buttons bar -->
                  <div class="btn-toolbar mb-2 mb-md-0">
                      <% if(bIsProd) { %>
                      <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                          <button type='button' class='btn btn-default btn-primary' onclick='goback()'>Back</button>
                      </div>
                      <% } else { %>
                      <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                          <button type="button" class="btn btn-danger" onclick="onbtnclickpublish('<%=id%>', 'product','publish')">Publish</button>
                          <button type="button" class="btn btn-danger" onclick="onbtnclickpublish('<%=id%>', 'product','delete')">Unpublish</button>
                      </div>
                      <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                          <button type='button' class='btn btn-default btn-primary' onclick='goback()'>Back</button>
                          <% if( lastpublish.length() > 0 && !catalogType.equals("offer") && ___sbIsEnabled ) { //___sbIsEnabled is defined in web-inf/include/header.jsp %>
                          <button type="button" class="btn btn-default btn-primary" onclick='javascript:window.location="prodproductStocks.jsp?cid=<%=cid%>";'>Stock</button>
                          <% } %>
                      </div>
                      <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                          <button type="button" class="btn btn-warning" disabled>Preview</button>
                          <button type='button' class='btn btn-default btn-success' onclick="javascript:previewMosaicNew()">mosaic</button>
                          <button type='button' class='btn btn-default btn-success' onclick="javascript:previewProductNew()">detail</button>
                      </div>
                      <% } %>
                  </div>
                  <!-- /buttons bar -->
              </div><!-- /d-flex -->

              <!-- messages zone  -->
              <div class='m-b-20'>
                  <!-- info -->
                  <% if(lastpublish.length() > 0) { %>
                  <div id='infoBox' class="alert alert-success" role="alert">
                      <div id=''>Last published on :
                          <%=lastpublish%>
                      </div>
                  </div>
                  <% } %>
                  <% if(nextpublish.length() > 0) { %>
                  <div id='infoBox' class="alert alert-danger" role="alert">
                      <div id=''><span>Next publish on : </span><span style='color:red'>
                              <%=nextpublish%></span></div>
                      <%if(!bIsProd) {%>
                      <div><span style='color:red'>WARNING!!!</span> If you make any changes now those will be published also</div>
                      <%}%>
                  </div>
                  <% } else if(cachetask.length() > 0) { %>
                  <div id='infoBox' class="alert alert-danger" role="alert">
                      <div id=''><span style='color:red'><%=cachetask%></span></div>
                  </div>
                  <% } %>

                  <%
                      String productSaveMsg = parseNull(session.getAttribute("PRODUCT_SAVE_MSG"));
                      if(productSaveMsg.length() > 0){
                          session.removeAttribute("PRODUCT_SAVE_MSG");
                  %>
                      <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <span><%=productSaveMsg%></span>
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                          <span aria-hidden="true">&times;</span>
                        </button>
                      </div>
                  <%
                      }
                  %>
            <div id="errmsg" class="alert alert-danger" role="alert" style="display:none"></div>
                  <!-- /info -->
              </div>
              <!-- messages zone  -->
            <!-- /title -->