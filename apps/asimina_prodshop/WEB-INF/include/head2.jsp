    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">

    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/flatpickr.min.css" rel="stylesheet">

    
    

    <!-- CoreUI and necessary plugins-->
    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
    <script>
        $(function() {
            document.querySelectorAll('.c-sidebar-nav-link').forEach((node)=>{
                if(node.href === window.location.origin+window.location.pathname) {
                    node.classList.add('c-active');
                    node.parentNode.parentNode.parentNode.classList.add('c-show');
                }
            });
        });
    </script>