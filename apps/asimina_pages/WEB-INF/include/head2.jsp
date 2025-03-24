<meta charset="utf-8">
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- <meta http-equiv="X-UA-Compatible" content="IE=edge"> -->
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="<%=com.etn.beans.app.GlobalParm.getParm("CATALOG_ROOT")%>/img/logo.png?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>">

    <!-- jQuery -->
    <script src="<%=request.getContextPath()%>/js/jquery.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js/moment.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>


    <!-- Bootstrap 4 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/popper.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    
    <script src="<%=request.getContextPath()%>/js/bootbox.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
    <link href="<%=request.getContextPath()%>/css/animate.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/bootstrap-notify.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script> 

    <!-- core ui -->
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/moringa-cui.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/coreui.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>

    <!-- Icons -->
    <link href="<%=request.getContextPath()%>/css/font-awesome-all.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/open-iconic-bootstrap.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/orangeIcons.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">

    <link href="<%=request.getContextPath()%>/css/datatables.min.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/datatables.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script> 

    <script src="<%=request.getContextPath()%>/js/Sortable.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script> 

    <!-- Feather icons (svg icons) -->
    <script src="<%=request.getContextPath()%>/js/feather.min.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
            document.querySelectorAll('.c-sidebar-nav-link').forEach((node)=>{
                if(node.href===window.location.origin+window.location.pathname) {
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
    <link href="<%=request.getContextPath()%>/css/menu.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/my.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/moringa-cms.css?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet">
    <script>window.$ch = {};</script>    	
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/flatpickr.min.css">
    <script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
    
    <script src="<%=request.getContextPath()%>/js/common.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>" defer></script>
    <style>
        .autocomplete-items {
            position: absolute;
            z-index: 19;
            top: 100%;
            left: 0;
            overflow-x: hidden;
            font-size: 12px;
            padding-left: 0;
            width: 100%;
        } 

        .asm-autocomplete {
            position: relative;
        }

        /* .autocomplete-items {
            position: absolute;
            z-index: 19;
            top: 100%;
            left: -24px;
            right: 13px;
        } */

        .autocomplete-items li {
            padding: 5px;
            cursor: pointer;
            background-color: #fff;
            border-bottom: 1px solid #ddd;
        }

        .autocomplete-items li:hover {
            background-color: #e9e9e9;
        }

		.autocomplete-item-highlight {
			background-color: #e9e9e9 !important;
		}
    </style>
    <%
        //used to output breadcrumbs in sidebar.jsp
        // each page can add breadcrumbs using example:
        //   breadcrumbs.add(new String[]{"<label>","<url>"});  // url can be empty
        java.util.List<String[]> breadcrumbs = new java.util.ArrayList<>();
        breadcrumbs.add(new String[]{"Home", com.etn.beans.app.GlobalParm.getParm("CATALOG_ROOT") + "/admin/gestion.jsp"});
    %>
