<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, com.etn.util.Base64, com.etn.beans.app.GlobalParm, com.etn.asimina.util.PortalHelper"%>
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
	String __pageTemplateType = "login";

	request.setAttribute("forced_menu", "0");	
	

	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;		
	}
	
%>


<%@ include file="../headerfooter.jsp"%>


<%
	String ftoken = parseNull(request.getParameter("t"));
	String clientUuid = "";

	//System.out.println("select * from clients where verification_token = " + escape.cote(ftoken));
	int err = 0;
	Set rs = Etn.execute("select * from clients where verification_token = " + escape.cote(ftoken));
	if(rs.rs.Rows == 0)
	{
		err = 1;
	}
	if(err == 0)
	{
		rs = Etn.execute("select * from clients where verification_token_expiry >= now() and verification_token = " + escape.cote(ftoken));
		if(rs.rs.Rows == 0)
		{
			err = 2;
		}
	}
    
	//System.out.println(rs.rs.Rows+"..!!");
    if(rs.next())
	{
    	clientUuid = parseNull(rs.value("client_uuid"));
    	//System.out.println(parseNull(rs.value("client_uuid"))+"]]]]]]]");
    	request.setAttribute("client_uuid", parseNull(rs.value("client_uuid")));
	}	
	
	String redirectTo = "";
%>

<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
<%=_headhtml%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<title><%=libelle_msg(Etn, request, "Vérification de compte")%></title>

</head>
<body>
	<%=_headerHtml%> 
	<div class="container">
		<h1 class='mt-2'><%=libelle_msg(Etn, request, "Vérification de compte")%></h1>
		<br>
		<%
		if(err > 0) 
		{
			if(err== 1) out.write("<div class='alert alert-danger' role='alert' >"+libelle_msg(Etn, request, "Invalid token provided")+"</div>");
			else if(err== 2) 
			{
			%>
			<div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
			<div class="alert alert-danger" id='errdiv' role="alert"><%=libelle_msg(Etn, request, "Token is already expired. Enter your username to get a verification email again")%></div>
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
			<%}
		}
		else {
			int rr = Etn.executeCmd("update clients set is_verified = 1 where verification_token = " + escape.cote(ftoken));			
						
			String _msg = libelle_msg(Etn, request, "Your account is verified. You will be redirected to homepage");
			Set clientRs = Etn.execute("SELECT * FROM clients WHERE LENGTH(pass) > 0 AND client_uuid = " + escape.cote(clientUuid));

			if(clientRs.rs.Rows == 0)
			{				
				redirectTo = "updatepassword.jsp?muid="+PortalHelper.escapeCoteValue(parseNull(request.getParameter("muid")))+"&client_uuid="+clientUuid;
				_msg = libelle_msg(Etn, request, "Your account is verified. You will be redirected automatically to set your password or click here");
			}			
			String _html = "<div class='alert alert-success' role='alert' >";
			if(redirectTo.length() > 0)
			{
				_html += "<a href='"+redirectTo+"'>";
			}
			_html += _msg;
			if(redirectTo.length() > 0)
			{
				_html += "</a>";
			}
			_html += "</div>";
			out.write(_html);
		}
		%>
    </div>

	<%=_footerHtml%>

    <%=_endscriptshtml%>


<script type="text/javascript">	
	$(document).ready(function() 
	{
		<% if(redirectTo.length() > 0) {%>
		setTimeout(function(){
			window.location.href = '<%=redirectTo%>';
		}, 2000);			
		<%} else if(err == 0){%>
		setTimeout(function(){
			__gotoPortalHome();
		}, 3000);			
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