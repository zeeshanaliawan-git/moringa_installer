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
	//new check to confirm if the signup form is configured for the menu we will use that 
	if(parseNull(request.getParameter("muid")).length() > 0)
	{
		String ___muuid2 = parseNull(request.getParameter("muid"));
		Set _rsM2 = Etn.execute("select * from site_menus where menu_uuid="+escape.cote(___muuid2));
		if(_rsM2.next())
		{
			String regUrl = "";
			if("1".equals(parseNull(GlobalParm.getParm("IS_PRODUCTION_ENV")))) regUrl = parseNull(_rsM2.value("register_prod_url"));
			else regUrl = parseNull(_rsM2.value("register_url"));
			
			if(regUrl.length() > 0)
			{
				response.sendRedirect(regUrl);
				return;
			}
		}		
	}


	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "login";
	

	String token = java.util.UUID.randomUUID().toString();
	com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "signup_token", token);	
        
	String isCart = parseNull(request.getParameter("isCart"));

	//redirect to this page after successful registration
	String ___ref = parseNull(request.getParameter("r"));
		
%>
<%@ include file="../headerfooter.jsp"%>

<%
	boolean showUsernameField = false;
	
	//if the signup form is designed in forms module, check if its using Login field separately other than the email field then we also have to show that here
	Set rsF = Etn.execute("select * from "+GlobalParm.getParm("FORMS_DB")+".process_forms where site_id = "+escape.cote(___loadedsiteid)+" and `type` = 'sign_up' ");
	if(rsF.next())
	{
		Set rsField = Etn.execute("select * from "+GlobalParm.getParm("FORMS_DB")+".process_form_fields where form_id = "+escape.cote(rsF.value("form_id"))+" and db_column_name = '_etn_login'");	
		if(rsField.rs.Rows > 0) showUsernameField = true;
	}
%>

<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
<%=_headhtml%>
	<% if(____menuVersion.equalsIgnoreCase("v1")){%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<%}%>

	<script type="text/javascript" src="../js/jquery.min.js"></script>
</head>
<%if(isCart.equals("1")){%>
<body style="padding: 0 !important;">
<div class="container">
	<h2 class='mt-2'><%=libelle_msg(Etn, request, "Enregistrement")%></h2>
	<hr>
<%}else{%>
<body>
<%=_headerHtml%>
<div class="container">
	<h1 class='mt-2'><%=libelle_msg(Etn, request, "Enregistrement")%></h1>
<%}%>        
	<div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
	<div class='mt-5'>
		<form class="etnhf-form-horizontal" id='frm' style="overflow: hidden;">
			<input type='hidden' name='muid' value='<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(___muuid)%>' />
			<input type='hidden' name='r' value='<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(___ref)%>' />
			<input type='hidden' name='_t' value='<%=token%>' />
			<input type='hidden' name='showUsernameField' value='<%if(showUsernameField) out.write("1"); else out.write("0");%>' />
			<% if(showUsernameField) {%>
			<div class="row form-group">
				<label for="username" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Username")%>&nbsp;<span style='color:red'>*</span></label>
				<div class="col-sm-9">
					<input type="text" class="form-control required" id="username" name="username" placeholder="<%=libelle_msg(Etn, request, "Username")%>">
				</div>
			</div>
			<% } %>
			<div class="row form-group">
				<label for="email" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Email")%>&nbsp;<span style='color:red'>*</span></label>
				<div class="col-sm-9">
					<input type="email" class="form-control required" id="email" name="email" placeholder="<%=libelle_msg(Etn, request, "Email")%>">
				</div>
			</div>
			<div class="row form-group">
				<label for="civility" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Civility")%>&nbsp;<span style='color:red'>*</span></label>
				<div class="col-sm-9">
					<select id='civility' name='civility' class="form-control required">
						<option value=''></option>
						<option value='Mr'><%=libelle_msg(Etn, request, "Mr")%></option>
						<option value='Mrs'><%=libelle_msg(Etn, request, "Mrs")%></option>
						<option value='Miss'><%=libelle_msg(Etn, request, "Miss")%></option>
					</select>
				</div>
			</div>
			<div class="row form-group">
				<label for="name" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Name")%>&nbsp;<span style='color:red'>*</span></label>
				<div class="col-sm-9">
					<input type="text" class="form-control required" id="name" name="name" placeholder="<%=libelle_msg(Etn, request, "Name")%>">
				</div>
			</div>
			<div class="row form-group">
				<label for="surname" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Surname")%>&nbsp;<span style='color:red'>*</span></label>
				<div class="col-sm-9">
					<input type="text" class="form-control required" id="surname" name="surname" placeholder="<%=libelle_msg(Etn, request, "Surname")%>">
				</div>
			</div>
			<div class="row form-group">
				<label for="mobile_number" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Contact number")%></label>
				<div class="col-sm-9">
					<input type="text" class="form-control" id="mobile_number" name="mobile_number" placeholder="<%=libelle_msg(Etn, request, "Contact number")%>">
				</div>
			</div>
			<div class="row form-group">
				<label class='col-sm-3 control-label'></label>
				<div class="col-sm-9">
					<input type="button" class='btn btn-primary' id='registerbtn' value='<%=libelle_msg(Etn, request, "Confirmer")%>' >
				</div>
			</div>			
		</form>
	</div>
</div>

<%if(!isCart.equals("1")){%>
	<%=_footerHtml%>
	<%=_endscriptshtml%>
<%}%>
<script type="text/javascript">	
	$(document).ready(function() 
	{
		$("#registerbtn").click(function(){

			if(typeof __checkLogin === "function") __checkLogin();
			else if(typeof asimina.cf.auth !== "undefined" && typeof asimina.cf.auth.checkLogin === "function") asimina.cf.auth.checkLogin();

			$("#errdiv").html("");
			$("#errdiv").hide();
			$.ajax({
				url : 'signupbackend.jsp',
	       		type: 'post',
				data : $("#frm").serialize(),
		       	dataType: 'json',
				success : function(json)
	       		{
					if(json.status == 'error') 
					{
						$("#errdiv").html(json.msg);
						$("#errdiv").show();
						$("#errdiv").focus();
					}
					else{
						<%if(isCart.equals("1")){%>
							parent.setLogin($("#email").val(),"<%=libelle_msg(Etn, request, "Enregistrement réussis. Dès à présent, vous allez pouvoir vous connecter à votre compte avec votre email") + " : "%>");
						<%}else{%>
							window.location = json.goto;
						<%}%>
					} 
				},
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});

		});
	});
</script>
</body>
</html>