<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, com.etn.util.Base64, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

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

<% 	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";


%>

<%@ include file="../headerfooter.jsp"%>


<%
	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;
	}

	String ftoken = parseNull(request.getParameter("t"));

	int err = 0;
	Set rs = Etn.execute("select * from clients where forgot_pass_token = " + escape.cote(ftoken));
	if(rs.rs.Rows == 0)
	{
		err = 1;
	}
	if(err == 0)
	{
		rs = Etn.execute("select * from clients where forgot_pass_token_expiry >= now() and forgot_pass_token = " + escape.cote(ftoken));
		if(rs.rs.Rows == 0)
		{
			err = 2;
		}
	}

%>

<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
<%=_headhtml%>
	<% if(____menuVersion.equalsIgnoreCase("v1")){%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<%}%>
	<title><%=libelle_msg(Etn, request, "Réinitialiser le mot de passe")%></title>
</head>
<body>
	<%=_headerHtml%>
	<div class="container">
		<h1 class='mt-2'><%=libelle_msg(Etn, request, "Réinitialiser le mot de passe")%></h1>
		<br>
		<%
		if(err > 0) {
			if(err== 1) out.write("<div class='alert alert-danger' role='alert' >"+libelle_msg(Etn, request, "Invalid token provided")+"</div>");
			else if(err== 2) out.write("<div class='alert alert-danger' role='alert' >"+libelle_msg(Etn, request, "Token is already expired")+"</div>");
		}
		else {
			rs = Etn.execute("select * from clients where forgot_pass_token = " + escape.cote(ftoken));
			rs.next();
		%>
		<div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
		<div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
		<form class="form-horizontal" id='frm' autocomplete="off" style="overflow: hidden;">
			<input type='hidden' name='muid' value='<%=___muuid%>' />
			<input type='hidden' name='ftoken' value='<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(ftoken)%>' />
			<div class="form-group row">
                <label for="username" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Utilisateur")%></label>
                <div class="col-sm-9">
                  <input type="username" class="form-control" id="username" disabled value="<%=rs.value("username")%>">
                </div>
			</div>
			<div class="form-group row">
                <label for="password" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Nouveau mot de passe")%>&nbsp;<span style='color:red'>*</span></label>
                <div class="col-sm-9">
                  <input type="password" class="form-control" autocomplete="off" id="password" name="password" placeholder="<%=libelle_msg(Etn, request, "Nouveau mot de passe")%>">
                </div>
			</div>
			<div class='form-group row'>
				<label for='passwd' class='col-sm-3 control-label '><%=libelle_msg(Etn, request, "Confirmez le mot de passe")%>&nbsp;<span style='color:red'>*</span></label>
				<div class='col-sm-9'><input class='form-control' type='password' name='confirmPassword' id='confirmPassword' value='' autocomplete='off' placeholder='<%=libelle_msg(Etn, request, "Confirmez le mot de passe")%>' /></div>
			</div>
			<div class="row form-group">
				<label class='col-sm-3 control-label'></label>
				<div class="col-sm-9" id='btndiv'>
					<button type='button' class="btn btn-primary" id='submitBtn' style="cursor:pointer"><%=libelle_msg(Etn, request, "Confirmer")%></button>
                </div>
			</div>
		</form>
		<%}%>
	</div>

	<%=_footerHtml%>

    <%=_endscriptshtml%>


<script type="text/javascript">
	$(document).ready(function()
	{
		$("#submitBtn").click(function()
		{
			$("#succdiv").fadeOut();
			$("#succdiv").html("");

			$("#errdiv").fadeOut();
			$("#errdiv").html("");
			
			let _password = $("#frm").find("input[name=password]").val();
			let _confirmpassword = $("#frm").find("input[name=confirmPassword]").val();						

			if(_password == "")
			{
				$("#errdiv").html("<%=libelle_msg(Etn, request, "Certaines informations demandées restent à renseigner")%>");
				$("#errdiv").show();
				return;
			}
			if(_confirmpassword == "")
			{
				$("#errdiv").html("<%=libelle_msg(Etn, request, "Certaines informations demandées restent à renseigner")%>");
				$("#errdiv").show();
				return;
			}

			if(_password.length < 8)
			{
				$("#errdiv").html("<%=libelle_msg(Etn, request, "Le mot de passe doit contenir au moins 8 caractères")%>");
				$("#errdiv").show();
				return;
			}
			else if(!(/^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$/i.test(_password)))
			{
				$("#errdiv").html("<%=libelle_msg(Etn, request, "Le mot de passe doit contenir au moins un caractère et un chiffre")%>");
				$("#errdiv").show();
				return;
			}

			if(_password != _confirmpassword)
			{
				$("#errdiv").html("<%=libelle_msg(Etn, request, "Le nouveau mot de passe ne correspond pas à la confirmation du mot de passe")%>");
				$("#errdiv").show();
				return;
			}

			$.ajax({
				url : 'resetpassbackend.jsp',
	       		type: 'post',
				data : $("#frm").serialize(),
		       	dataType: 'json',
       		       success : function(json)
	       		{
					if(json.status == 'error')
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

						$("#btndiv").html("");
						setTimeout(function(){
							__gotoPortalHome();
						}, 2000);
				   }
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});

		});
	});
</script>

</body>
</html>