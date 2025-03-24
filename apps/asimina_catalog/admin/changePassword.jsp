<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog"%>

<%@ include file="/WEB-INF/include/commonMethod.jsp"%>


<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset="utf-8" />
	<title>Change Password</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

		<script>
			function onOk()
			{
				var isError = 0;
				$("#messageLbl").fadeOut();
				$("#messageLbl").html("");
				$.ajax({
					url : "changePasswordAjax.jsp",
					method : "post",
					data : $("#passwdFrm").serialize(),
					dataType : "json",
					success : function(json) {
						if(json.status == 0)
						{
							window.location.href = json.gotourl;
						}
						else
						{
							$("#messageLbl").html(json.msg);
							$("#messageLbl").fadeIn();
						}
					}
				});
			}
		</script>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- breadcrumb -->
	<%-- <nav aria-label="breadcrumb">
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a href='<%=request.getContextPath()%>/admin/gestion.jsp'>Home</a></li>
			<li class="breadcrumb-item active" aria-current="page">Change password</li>
		</ol>
	</nav> --%>
	<!-- /breadcrumb -->
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">Change Password</h1>
				<p class="lead"></p>
			</div>
		</div>
	<!-- /title -->

	<div class="container-fluid">
	<div class="animated fadeIn">
	<form id="passwdFrm" action="changePassword.jsp" method="post" autocomplete='off'>
		<% if(parseNull(session.getAttribute("PASS_EXPIRED")).equals("1")){%>
		<div class="m-b-10 m-t-10 alert alert-danger" role="alert" id="expmsg">Your password is expired. Kindly set new password</div>
		<%}%>
		<div style="display:none" class="m-b-10 m-t-10 alert alert-danger" role="alert" id="messageLbl"></div>

		<table class='table table-hover table-bordered results' cellpadding="0" cellspacing="0" border="0">
		<tbody>
			<tr>
				<td width="15%"><b>Old password</b></td>
				<td width="30%"><input type="password" autocomplete='off' class="form-control" value="" size="30" maxlength="50" name="oldPassword"></td>
			</tr>
			<tr>
				<td><b>New password</b></td>
				<td><input type="password" autocomplete='off' value="" class="form-control" size="30" maxlength="50" name="newPassword"></td>
			</tr>
			<tr>
				<td><b>Confirm new password</b></td>
				<td><input type="password" autocomplete='off' value="" class="form-control" size="30" maxlength="50" name="confirmPassword"></td>
			</tr>
			<tr>
				<td align="center" colspan="3"><button type="button" class="btn btn-primary" onclick="onOk()">Submit</button></td>
			</tr>
		</tbody>
		</table>
	</form>

	</div>
	</div>
</main>
</div><!-- /c-body -->
<%@ include file="/WEB-INF/include/footer.jsp" %>
</body>
</html>

