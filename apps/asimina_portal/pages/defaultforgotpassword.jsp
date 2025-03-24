<%-- If this page has country specific implementation then create a jsp in countryspecific folder and provide its path in GlobalParm.conf --%>

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

<%

	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;		
	}

	//new check to confirm if the forgotpassword form is configured for the menu we will use that 
	if(parseNull(request.getParameter("muid")).length() > 0)
	{
		String ___muuid2 = parseNull(request.getParameter("muid"));
		Set _rsM2 = Etn.execute("select * from site_menus where menu_uuid="+escape.cote(___muuid2));
		if(_rsM2.next())
		{
			String _url = "";
			if("1".equals(parseNull(GlobalParm.getParm("IS_PRODUCTION_ENV")))) _url = parseNull(_rsM2.value("forgot_pass_prod_url"));
			else _url = parseNull(_rsM2.value("forgot_pass_url"));
			
			if(_url.length() > 0)
			{
				response.sendRedirect(_url);
				return;
			}
		}		
	}
		
	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "login";

	String token = java.util.UUID.randomUUID().toString();
	com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "forgot_password_token", token);	
        
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
	<title><%=libelle_msg(Etn, request, "Mot de passe oublié?")%></title>   
</head>
<body>
	<%=_headerHtml%>
	<div class="container">
		<h1 class='mt-2'><%=libelle_msg(Etn, request, "Mot de passe oublié?")%></h1>
		<br>
		
		<div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
		<div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
		<form class="form-horizontal" id='frm' autocomplete="off" style="overflow: hidden;">
			<input type='hidden' name='muid' value='<%=___muuid%>' />
			<input type='hidden' name='_t' value='<%=token%>' />
			<% if(showUsernameField) {%>
				<input type='hidden' name='_showUsernameField' value='1' />
			<% } %>
			<div class="row form-group">
                <label for="username" class="col-sm-3 control-label "><%=libelle_msg(Etn, request, "Utilisateur")%>&nbsp;<span style='color:red'>*</span></label>
                <div class="col-sm-9">
                  <input type="username" class="form-control" id="username" name="username" placeholder="<%=libelle_msg(Etn, request, "Utilisateur")%>">
                </div>
			</div>    
			<div class="row form-group">
				<label class='col-sm-3 control-label'></label>
				<div class="col-sm-9">
					<input type="button" class='btn btn-primary' id='submitBtn' value='<%=libelle_msg(Etn, request, "Confirmer")%>' >
				</div>
			</div>			
		</form>

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

			$.ajax({
				url : 'forgotpassbackend.jsp',
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