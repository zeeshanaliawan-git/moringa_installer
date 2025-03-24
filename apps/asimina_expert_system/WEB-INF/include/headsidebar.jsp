    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="<%=request.getContextPath()%>/img/logo.png?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>">

    <script src="<%=request.getContextPath()%>/js2/jquery-1.12.1.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js2/popper.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js2/moment.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <!-- Bootstrap 4 -->
    <link href="<%=request.getContextPath()%>/css2/bootstrap4.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js2/bootstrap4.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <!-- Bootstrap 4 -->
    <link href="<%=request.getContextPath()%>/css2/animate.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js2/bootbox.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js2/bootstrap-notify.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <link href="<%=request.getContextPath()%>/css2/coreui-icons.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">

    <!-- Icons -->
    <link href="<%=request.getContextPath()%>/css2/font-awesome-all.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css2/open-iconic-bootstrap.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css2/orangeIcons.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">

    <!-- jQuery UI -->
    <link href="<%=request.getContextPath()%>/css2/jquery-ui.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js2/jquery-ui.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <!-- Datetimepicker -->
    <link href="<%=request.getContextPath()%>/css2/jquery.datetimepicker.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js2/jquery.datetimepicker.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <!-- DataTables -->
    <link href="<%=request.getContextPath()%>/css2/datatables.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js2/jquery.dataTables.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js2/datatables.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <script src="<%=request.getContextPath()%>/js2/coreui.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <!-- Feather icons (svg icons) -->
    <script src="<%=request.getContextPath()%>/js2/feather.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script type="text/javascript">
      $(function() {
        feather.replace();
         document.querySelectorAll('.c-sidebar-nav-link').forEach((node)=>{
            if(node.href === window.location.origin+window.location.pathname) {
                node.classList.add('c-active');
                node.parentNode.parentNode.parentNode.classList.add('c-show');
            }
        });
    });
  </script>

  <!-- jQuery Text Editor -->
  <link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css2/jquery-te-1.4.0.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>">
  <script src="<%=request.getContextPath()%>/js2/jquery-te-1.4.0.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

  <!-- Full Calendar -->
  <link href="<%=request.getContextPath()%>/css2/fullcalendar.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
  <script src="<%=request.getContextPath()%>/js2/fullcalendar.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

  <!-- Misc -->
  <link href="<%=request.getContextPath()%>/css/menu.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/my.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" type="text/css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/moringa-cms.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/moringa-cui.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">

  <!-- <script src="<%=request.getContextPath()%>/js2/support_proxy.jsp"></script> -->
  <script src="<%=request.getContextPath()%>/js2/common.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

  <style>
    .autocomplete-items {
        position: absolute;
        z-index: 19;
        top: 100%;
        left: -24px;
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
	String _version = com.etn.beans.app.GlobalParm.getParm("APP_VERSION");
	if(_version == null) _version = "";
	else _version = "v" + _version;

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

	Set __rssessioins = Etn.execute("select coalesce(selected_site_id,'') as selected_site_id from " + com.etn.beans.app.GlobalParm.getParm("COMMONS_DB") + ".user_sessions where expsys_session_id = " + escape.cote(""+session.getId()));

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

	//used to output breadcrumbs in sidebar.jsp
	// each page can add breadcrumbs using example:
	//   breadcrumbs.add(new String[]{"<label>","<url>"});  // url can be empty
	java.util.List<String[]> breadcrumbs = new java.util.ArrayList<>();
	breadcrumbs.add(new String[]{"Home", com.etn.beans.app.GlobalParm.getParm("CATALOG_URL") + "admin/gestion.jsp"});

%> 