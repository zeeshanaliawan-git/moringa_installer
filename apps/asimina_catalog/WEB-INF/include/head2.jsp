	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="favicon.ico">


  <SCRIPT LANGUAGE="JavaScript" SRC="<%=request.getContextPath()%>/js/jquery.min.js"></script>
  <script src="<%=request.getContextPath()%>/js/moment.min.js"></script>

  <!-- Bootstrap 4 -->
  <link href="<%=request.getContextPath()%>/css/bootstrap4.min.css" rel="stylesheet">
  <script src="<%=request.getContextPath()%>/js/bootstrap4.min.js"></script>

  <!-- Icons -->
  <link href="<%=request.getContextPath()%>/css/font-awesome.min.min.css" type="text/css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/open-iconic-bootstrap.css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/orangeIcons.min.css" rel="stylesheet">

  <!-- Datetimepicker -->
  <link href="<%=request.getContextPath()%>/css/flatpickr.min.css" type="text/css" rel="stylesheet">
  <script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>

  <!-- DataTables -->
  <link href="<%=request.getContextPath()%>/css/rowReorder.dataTables.min.css" rel="stylesheet" >
  <link href="<%=request.getContextPath()%>/css/dataTables.bootstrap4.min.css" rel="stylesheet">
  <script src="<%=request.getContextPath()%>/js/jquery.dataTables.min.js"></script>
  <script src="<%=request.getContextPath()%>/js/dataTables.bootstrap4.min.js"></script>
  <script src="<%=request.getContextPath()%>/js/dataTables.rowReorder.min.js"></script>

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

  <%-- <!-- jQuery Text Editor -->
  <link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/jquery-te-1.4.0.css">
  <script src="<%=request.getContextPath()%>/js/jquery-te-1.4.0.min.js"></script>

  <!-- Full Calendar -->
  <link href="<%=request.getContextPath()%>/css/fullcalendar.min.css" type="text/css" rel="stylesheet">
  <script src="<%=request.getContextPath()%>/js/fullcalendar.min.js"></script> --%>

  <!-- Misc -->
  <link href="<%=request.getContextPath()%>/css/menu.css" type="text/css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/my.css" type="text/css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/moringa-cms.css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/moringa-cui.css" rel="stylesheet">
  <link href="<%=request.getContextPath()%>/css/navbar-fixed-top.css" rel="stylesheet">

  <!-- script src="<%=request.getContextPath()%>/js/support_proxy.jsp"></script-->
  <script src="<%=request.getContextPath()%>/js/common.js"></script>

  <style>
        
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


