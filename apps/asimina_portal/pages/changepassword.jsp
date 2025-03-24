<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>

<%@ include file="../clientcommon.jsp"%>

<%@ include file="../lib_msg.jsp"%>

<%!
	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}



%>

<%
	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == false)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/sessionexpired.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;
	}

	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";

	String token = java.util.UUID.randomUUID().toString();
	com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "change_password_token", token);	
%>
<%@ include file="../headerfooter.jsp"%>

<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
	<title><%=libelle_msg(Etn, request, "Changer le mot de passe")%></title>
<%=_headhtml%>
	<%if(____menuVersion.equalsIgnoreCase("v1") == true){%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<%}%>
	<script type="text/javascript" src="../js/jquery.min.js"></script>

	<% if(parseNull(GlobalParm.getParm("CUSTOM_CHANGE_PASS_CSS")).length() > 0) {%>
	<link href="<%=parseNull(GlobalParm.getParm("CUSTOM_CHANGE_PASS_CSS"))+"?__v="+GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<%}%>
</head>
<body>
	<%=_headerHtml%>
	<div class="container">
		<h1 class='mt-2'>
			<%=libelle_msg(Etn, request, "Changer le mot de passe")%>
		</h1>
		<div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
		<div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
		<div class='mt-5'>
			<form class="form-horizontal" id='frm' name='frm' autocomplete="off" >
				<input type='hidden' name='muid' value='<%=___muuid%>' />
				<input type='hidden' name='_t' value='<%=token%>' />
				<div class="row form-group">
					<label for="password" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "ancien mot de passe")%>&nbsp;<span style='color:red'>*</span></label>
					<div class="col-sm-9">
					  <input type="password" autocomplete='off' class="form-control" id="password" name="password" placeholder="<%=libelle_msg(Etn, request, "ancien mot de passe")%>">
					</div>
				</div>
				<div class="row form-group">
					<label for="newpassword" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Nouveau mot de passe")%>&nbsp;<span style='color:red'>*</span></label>
					<div class="col-sm-9">
					  <input type="password" autocomplete='off' class="form-control" id="newpassword" name="newpassword" placeholder="<%=libelle_msg(Etn, request, "Nouveau mot de passe")%>">
					</div>
				</div>
				<div class="row form-group">
					<label for="confirmpassword" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Confirmez le mot de passe")%>&nbsp;<span style='color:red'>*</span></label>
					<div class="col-sm-9">
					  <input type="password" autocomplete='off' class="form-control" id="confirmpassword" name="confirmpassword" placeholder="<%=libelle_msg(Etn, request, "Confirmez le mot de passe")%>">
					</div>
				</div>
				<div class="row form-group">
					<label class='col-sm-3 control-label'></label>
					<div class="col-sm-9" id='submitBtnDiv'>
						<input type="button" class='btn btn-primary' id='submitBtn' value='<%=libelle_msg(Etn, request, "Confirmer")%>' >
					</div>
				</div>
            </form>
        </div>
    </div>

	<%=_footerHtml%>

    <%=_endscriptshtml%>


<script type="text/javascript">
	
	var ___remaining=5;
	$(document).ready(function()
	{
		$("#submitBtn").click(function()
		{
			$("#succdiv").fadeOut();
			$("#succdiv").html("");

			$("#errdiv").fadeOut();
			$("#errdiv").html("");

			if($.trim($("#password").val()) == "" || $.trim($("#newpassword").val()) == "" || $.trim($("#confirmpassword").val()) == "" )
			{
				$("#errdiv").html("<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Certaines informations demandées restent à renseigner"))%>");
				$("#errdiv").fadeIn();
				return false;
			}
			if(document.frm.confirmpassword.value != document.frm.newpassword.value)
			{
				$("#errdiv").html("<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Le nouveau mot de passe ne correspond pas à la confirmation du mot de passe"))%>");
				$("#errdiv").fadeIn();
				$("#newpassword").focus();
				return false;
			}
			if(document.frm.newpassword.value.length < 8)
			{
				$("#errdiv").html("<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Le mot de passe doit contenir au moins 8 caractères"))%>");
				$("#errdiv").fadeIn();
				$("#newpassword").focus();
				return false;
			}

			$.ajax({
				url : 'changepasswordbackend.jsp',
	       		type: 'post',
				data : $("#frm").serialize(),
		       	dataType: 'json',
				success : function(json)
	       		{
					if(json.status != 0 )
					{
						$("#errdiv").html(json.msg);
						$("#errdiv").fadeIn();
						$("#errdiv").focus();
					}
					else
					{
						$("#succdiv").html(json.msg);
						$("#succdiv").fadeIn();
						$("#succdiv").focus();
						$("#submitBtnDiv").html('');
						logOutFunction();
						
					}
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});

		});
	});
	
	function logOutFunction(){
		let ___timeout = window.setInterval(function(){
			___remaining--;
			document.getElementById("logOutTime").innerHTML = ___remaining;
			if(___remaining<=0) {
				__doPortalLogout();
				window.clearInterval(___timeout);
			}
		}, 1000);
	}
</script>

</body>
</html>