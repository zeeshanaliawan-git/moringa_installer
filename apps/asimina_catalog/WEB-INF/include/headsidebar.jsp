    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="<%=request.getContextPath()%>/img/logo.png?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js/moment.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    
    <!-- Bootstrap 4 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap4.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/bootstrap4.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <!-- Bootstrap 4 -->
    <link href="<%=request.getContextPath()%>/css/animate.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/bootbox.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap-notify.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">

    <!-- Icons -->
    <link href="<%=request.getContextPath()%>/css/font-awesome-all.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/open-iconic-bootstrap.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/orangeIcons.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">

    <!-- Datetimepicker -->
    <link href="<%=request.getContextPath()%>/css/flatpickr.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/flatpickr.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    

    <!-- DataTables -->
    <link href="<%=request.getContextPath()%>/css/datatables.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <%-- <script src="<%=request.getContextPath()%>/js/jquery.dataTables.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script> --%>
    <script src="<%=request.getContextPath()%>/js/datatables.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <script src="<%=request.getContextPath()%>/js/Sortable.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <script src="<%=request.getContextPath()%>/js/coreui.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <link href="<%=request.getContextPath()%>/css/my.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">

    <!-- Feather icons (svg icons) -->
    <script src="<%=request.getContextPath()%>/js/feather.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script type="text/javascript">
		$(function() {
			feather.replace();
			document.querySelectorAll('.c-sidebar-nav-link').forEach((node)=>{
				if(node.href === window.location.origin+window.location.pathname) 
				{
					node.classList.add('c-active');
					node.parentNode.parentNode.parentNode.classList.add('c-show');
				}
			});
		});
		
		let _hHtmlChars = {
		  '&': '&amp;',
		  '<': '&lt;',
		  '>': '&gt;',
		  '"': '&quot;',
		  "'": '&#39;',
		  '/': '&#x2F;',
		  '`': '&#x60;',
		  '=': '&#x3D;',
		  '\\':'&#92;'
		};

		function _hEscapeHtml (string) {
			return String(string).replace(/[&<>"'`\\=\/]/g, function (s) {
				return _hHtmlChars[s];
			});
		}		
		
  </script>

  <!-- Misc -->
  <link href="<%=request.getContextPath()%>/css/menu.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/my.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/moringa-cms.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/moringa-cui.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">

  <!-- <script src="<%=request.getContextPath()%>/js/support_proxy.jsp"></script> -->
  <script src="<%=request.getContextPath()%>/js/common.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

  <style>
  
  .autocomplete-items {
            position: absolute;
            z-index: 19;
            top: 100%;
            left: 0;
            right: 13px;
            overflow-x: hidden;
            font-size: 12px;
        }

        .autocomplete-items li {
            padding: 5px;
            cursor: pointer;
            background-color: #fff;
            border-bottom: 1px solid #ddd;
        }

        .autocomplete-items li:hover {
            background-color: #e9e9e9 !important;
        }

		.autocomplete-item-highlight {
			background-color: #e9e9e9 !important;
		}
    .dropdown-menu{
        min-width: 13rem;
    }
    .bg-published { background-color: #dff0d8;}
    .bg-published:hover { background-color: #d0e9c6 !important;}

    .bg-changed { background-color: #fcf8e3;}
    .bg-changed:hover { background-color: #faf2cc !important;}

    .bg-unpublished { background-color: #f2dede;}
    .bg-unpublished:hover { background-color: #ebcccc !important;}
  </style>


<%
	String ____version = com.etn.beans.app.GlobalParm.getParm("APP_VERSION");
	if(____version == null) ____version = "";
	else ____version = "v" + ____version;

	Set ___rsper = Etn.execute("select pr.assign_site from profil pr, profilperson p where p.profil_id = pr.profil_id and p.person_id = " + escape.cote(""+ Etn.getId()));
	boolean useAssignedSites = false;
	if(___rsper.next())
	{
		if("1".equals(___rsper.value("assign_site"))) useAssignedSites = true;
	}

	Set __rssite = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".sites where is_active = 1 order by name " );
	if(useAssignedSites)
	{
		__rssite = Etn.execute("select s.* from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".sites s, person_sites ps where s.is_active = 1 and ps.site_id = s.id and ps.person_id = "+escape.cote(""+Etn.getId())+" order by name " );
	}

	String __selectedsite = "";
	String __selectedsitename = "Select Site";

	Set __rssessioins = Etn.execute("select coalesce(selected_site_id,'') as selected_site_id from " + com.etn.beans.app.GlobalParm.getParm("COMMONS_DB") + ".user_sessions where catalog_session_id = " + escape.cote(""+session.getId()));

	if(__rssessioins.next())
	{
		__selectedsite = __rssessioins.value("selected_site_id");
		if(__selectedsite.length() > 0)
		{
			while(__rssite.next())
			{
				if(__selectedsite.equals(__rssite.value("id"))) __selectedsitename = __rssite.value("name");
			}
			__rssite.moveFirst();
		}
	}

	String ___sbSiteId = "";
	if(session.getAttribute("SELECTED_SITE_ID") != null) ___sbSiteId = (String)session.getAttribute("SELECTED_SITE_ID");

	boolean ___sbIsEnabled = false;

	if(___sbSiteId.length() > 0)
	{
		com.etn.lang.ResultSet.Set ___rss = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") +".sites where is_active = 1 and id = " +com.etn.sql.escape.cote(___sbSiteId) );
		if(___rss.next())
		{
			___sbIsEnabled = "1".equals(___rss.value("enable_ecommerce"));
		}
	}

	//com.etn.util.Logger.debug("dev_catalog/sidebar.jsp","Selected site id : " + ___sbSiteId + " ecommerce enabled : " + ___sbIsEnabled);
       String whereClause = "";
       if(!___sbIsEnabled) whereClause = " and requires_ecommerce = 0 ";

	Set ____rsp = Etn.execute("select case coalesce(parent,'') when '' then name else parent end as _parent, case coalesce(icon,'') when '' then icon else parent_icon end as _icon, " +
				" case coalesce(parent,'') when '' then 0 else 1 end as _isparent, min(rang) as rang " +
				" from page where 1=1 "+whereClause+" group by _parent order by rang, _parent");


	//used to output breadcrumbs in sidebar.jsp
	// each page can add breadcrumbs using example:
	//   breadcrumbs.add(new String[]{"<label>","<url>"});  // url can be empty
	java.util.List<String[]> breadcrumbs = new java.util.ArrayList<>();
	breadcrumbs.add(new String[]{"Home", request.getContextPath() + "/admin/gestion.jsp"});
%>
