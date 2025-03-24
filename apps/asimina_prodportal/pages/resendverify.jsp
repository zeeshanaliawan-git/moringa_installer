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
	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "login";
	
	String ___msg = parseNull(request.getParameter("msg"));
		
%>


<%@ include file="../headerfooter.jsp"%>

<%
	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;		
	}

%>

<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
<%=_headhtml%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<title><%=libelle_msg(Etn, request, "Renvoyer l'e-mail de vérification")%></title>

</head>
<body>
	<%=_headerHtml%> 
	<div class="container">
		<h1 class='mt-2'><%=libelle_msg(Etn, request, "Renvoyer l'e-mail de vérification")%></h1>
		<br>
		<div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
		<div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
		<form class="form-horizontal" id='frm' autocomplete="off" style="overflow: hidden;">
			<input type='hidden' name='muid' value='<%=___muuid%>' />
			<div class="row form-group">
				<label for="username" class="col-sm-3 control-label"><%=libelle_msg(Etn, request, "Username")%></label>
				<div class="col-sm-9">
					<input type="username" class="form-control" id="username" name="username" value="" >
				</div>
			</div>             
			<div class="row  form-group">
				<label class="col-sm-3 control-label"></label>
				<div class="col-sm-9">
					<input type="button" class="btn btn-primary" id='submitBtn' value='<%=libelle_msg(Etn, request, "Confirmer")%>' >
				</div>
			</div>			
		</form>
    </div>

	<%=_footerHtml%>

    <%=_endscriptshtml%>


<script type="text/javascript">	
	$(document).ready(function() 
	{
		<% if(___msg.length() > 0) {%>
			$("#errdiv").html('<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(___msg)%>');
			$("#errdiv").show();
		<%}%>
		
		$("#submitBtn").click(function()
		{
			if($.trim($("#username").val()) === '') return false;
			
			$.ajax({
				url : 'resendverificationemail.jsp',
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
						$("#errdiv").hide();
						$("#errdiv").html("");
						$("#btnbar").html("");
						setTimeout(function(){ __gotoPortalHome() }, 8000);						
						
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