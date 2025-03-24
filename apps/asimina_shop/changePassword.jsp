<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ include file="common.jsp" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Change Password</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
        <!-- Breadcrumb-->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Change Password</h1>
            </div>
            <div class="animated fadeIn">
            <div class="card">
              <div class="card-body">
				<% if(parseNull(session.getAttribute("PASS_EXPIRED")).equals("1")){%>
				<div class="m-b-10 m-t-10 alert alert-danger" role="alert" id="expmsg">Your password is expired. Kindly set new password</div>
				<%}%>			  
				<div style="display:none" class="m-b-10 m-t-10 alert alert-danger" role="alert" id="messageLbl"></div>
                  <form id="passfrm" name="passwdFrm" action="changePassword.jsp" method="post" class="form-horizontal" role="form">	
                      <div class="row">
                          <div class="col-xs-12 col-sm-6">

                              <div class="form-group row">
                                  <label for="oldPassword" class="col-sm-3 control-label"> Old Password</label>
                                  <div class="col-sm-9">
                                      <input type="password" id="oldPassword" name="oldPassword" size="10" class="hasDatepicker form-control">
                                  </div>
                              </div>

                              <div class="form-group row">
                                  <label for="newPassword" class="col-sm-3 control-label"> New Password</label>
                                  <div class="col-sm-9">
                                      <input type="password" id="newPassword" name="newPassword" size="10" class="hasDatepicker form-control">
                                  </div>
                              </div>

                              <div class="form-group row">
                                  <label for="confirmPassword" class="col-sm-3 control-label"> Confirm New Password</label>
                                  <div class="col-sm-9">
                                      <input type="password" id="confirmPassword" name="confirmPassword" size="10" class="hasDatepicker form-control">
                                  </div>
                              </div>

                          </div>
                      </div>

                      <div class="row">
                          <div class="col-sm-12 text-center">
                              <div class="" role="group" aria-label="controls">
                                  <button type="button" class="btn btn-success" name="Search" onclick="onOk()" >Save</button>
                              </div>
                          </div>
                      </div>
                  </form>
              </div>
            </div>
          </div>						
		</main>
    </div>
<%@ include file="WEB-INF/include/footer.jsp" %>
</body>
<script type="text/javascript">
jQuery(document).ready(function() {

	onOk=function()
	{
		$("#errmsgdiv").html("");
		$("#errmsgdiv").hide();
		$("#errmsgdiv").removeClass("alert-success").addClass("alert-danger");
		$.ajax({
			url : "changePasswordAjax.jsp",
			method:'post',
			data : $("#passfrm").serialize(),
			dataType : "json",
			success : function(json) {
				if(json.status == 0)
				{
					window.location.href =json.gotourl;
				}
				else
				{
					$("#messageLbl").html(json.msg);
					$("#messageLbl").fadeIn();
				}
			}
		});
	};
	
});
</script>	
</html>