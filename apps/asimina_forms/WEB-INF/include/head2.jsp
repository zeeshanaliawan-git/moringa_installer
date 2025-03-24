	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="<%=request.getContextPath()%>/img/favicon.ico">

  <!-- jQuery -->
  <SCRIPT LANGUAGE="JavaScript" SRC="<%=request.getContextPath()%>/js/jquery.min.js"></script>

  <!-- Bootstrap 4 -->
  <link href="<%=request.getContextPath()%>/css/boosted.min413.css" rel="stylesheet">
  <script src="<%=request.getContextPath()%>/js/boosted.min413.js"></script>

  <!-- Icons -->
  <link href="<%=request.getContextPath()%>/css/font-awesome.min.min.css" type="text/css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/open-iconic-bootstrap.css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/orangeIcons.min.css" rel="stylesheet">
  <link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap-custom-icons.css">
    <!-- Feather icons (svg icons) -->
    <script src="<%=request.getContextPath()%>/js/feather.min.js"></script>
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

  

  <!-- Misc -->
  <link href="<%=request.getContextPath()%>/css/moringa-cms.css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/navbar-fixed-top.css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/my.css" type="text/css" rel="stylesheet">

  <script src="<%=request.getContextPath()%>/js/html_form_template.js"></script>

<!-- datepicker -->
  <link href="<%=request.getContextPath()%>/css/flatpickr.min.css" rel="stylesheet">
  <script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
   <style>

      .autocomplete-items {
            position: absolute;
            z-index: 19;
            top: 100%;
            left: -24px;
            right: 13px;
        }

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
    
     .dropdown-menu{
      min-width: 13rem;
     }
    .border-left-success td:first-child{ border-left: 4px solid green;}
    .border-left-warning td:first-child{ border-left: 4px solid orange;}
    .border-left-danger td:first-child{ border-left: 4px solid red;}
   </style>


