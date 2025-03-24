<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>View Process</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet">

    <link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery-ui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
</head>
<body class="app header-fixed sidebar-fixed aside-menu-fixed sidebar-lg-show">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="app-body">
      <%@ include file="/WEB-INF/include/sidebar.jsp" %>	
      <main class="main">
        <!-- Breadcrumb-->
        <ol class="breadcrumb" style="margin-bottom: 0px;">
		<li class="breadcrumb-item">Home</li>
                <li class="breadcrumb-item active"><a href="#">View Process</a></li>
          <!-- Breadcrumb Menu-->
        </ol>
        <div class="">
          <div class="animated fadeIn">
            <div class="card" style="margin-bottom: 0px;">
<!--              <div class="card-header">View Process</div>-->
              <div class="card-body" style='padding: 0px; width: 100%;'>
                  <iframe src='viewProcess.jsp' style='width:100%; height: 100%; border: none;'></iframe>
              </div>
            </div>
          </div>
        </div>						
        </main>
    </div><%@ include file="WEB-INF/include/footer.jsp" %>
<script>
    $(document).ready(function() {
        adjustCardBody();
        $(window).on('resize', function(){
            adjustCardBody();adjustCardBody();adjustCardBody();
        });
    });
    
    function adjustCardBody(){
        $('.card-body').height(($('.app-footer').offset().top-$('.card-body').offset().top)-4); 
        /*setTimeout(function(){ 
            console.log(($('.app-footer').offset().top-$('.card-body').offset().top)-4);
            $('.card-body').height(($('.app-footer').offset().top-$('.card-body').offset().top)-4); 
            $('.card-body').height(($('.app-footer').offset().top-$('.card-body').offset().top)-4); 
            $('.card-body').height(($('.app-footer').offset().top-$('.card-body').offset().top)-4); 
            console.log(($('.app-footer').offset().top-$('.card-body').offset().top)-4);
        }, 3000);*/
    }
</script>
</body>
</html>