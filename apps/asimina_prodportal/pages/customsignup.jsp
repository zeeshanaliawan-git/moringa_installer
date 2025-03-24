<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
<%@ page import="java.io.UnsupportedEncodingException,org.json.JSONArray,org.json.JSONObject"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<%@ include file="../common.jsp"%>


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

%>

<%@ include file="../headerfooter.jsp"%>

<%
	Set rsF = Etn.execute("select * from "+GlobalParm.getParm("FORMS_DB")+".process_forms where site_id = "+escape.cote(___loadedsiteid)+" and `type` = 'sign_up' ");
	rsF.next();
		
%>


<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
<%=_headhtml%>
	<% if(____menuVersion.equalsIgnoreCase("v1")){%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<%}%>

	<title><%=libelle_msg(Etn, request, "S'inscrire")%></title>

	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery.min.js' type='text/javascript'></script>
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery-ui.min.js' type='text/javascript'></script>
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/boosted.min413.js' type='text/javascript'></script>
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery.datetimepicker-fr.js' type='text/javascript'></script>
	
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/intlTelInput.min.js' type='text/javascript'></script>
	<script src='https://www.google.com/recaptcha/api.js?hl=<%=_lang%>' type='text/javascript'></script>
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/triggers.js' type='text/javascript'></script>
	
	<script type='text/javascript'>
		var ______menuid = '<%=_menuid%>';
	</script>
	
</head>
<body>
	<%=_headerHtml%>
    <div class="container">
		<h1 class='mt-2'>
			<%=libelle_msg(Etn, request, "S'inscrire")%>
		</h1>

		<div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
		<div class="alert alert-success" id='msgdiv' role="alert" style='display:none'></div>
		<div class='mt-5' id='frmdiv'></div>
		<div class='mt-5' id='frmjsfiles' style='display:none'></div>
    </div>
	<%=_footerHtml%>

    <%=_endscriptshtml%>

</body>
<script type="text/javascript">	
	function loadForm()
	{
		$.ajax({
			url : '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>api/forms.jsp',
			data : {lang : '<%=_lang%>', form_id : '<%=rsF.value("form_id")%>'},
			method : 'post',
			dataType : 'json',
			success : function(json){
				if(json.data.cssFiles)
				{
					for(var i=0;i<json.data.cssFiles.length;i++)
					{
						<% if(____menuVersion.equalsIgnoreCase("v1") == false){%>
						if(json.data.cssFiles[i].indexOf("boosted.min.css") > -1) continue;
						if(json.data.cssFiles[i].indexOf("boosted5.min.css") > -1) continue;

						<%}%>
						if(json.data.cssFiles[i] != '') $('<link>').attr({href: json.data.cssFiles[i],rel:"stylesheet",type:"text/css"}).appendTo('head');				
					}
					
				}
				if(json.data.bodyCss != '')
				{
					$('<style>').attr('type', 'text/css').text(json.data.bodyCss).appendTo("head");
				}

				$("#frmdiv").html(json.data.formHtml);								
								
				if(json.data.jsFiles)
				{				
					for(var i=0;i<json.data.jsFiles.length;i++)
					{
						//we added these by default

						if( json.data.jsFiles[i] == '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery.min.js') continue;
						if( json.data.jsFiles[i] == '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery-ui.min.js') continue;
						if( json.data.jsFiles[i] == '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/boosted.min413.js') continue;
						if( json.data.jsFiles[i] == '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/boosted5.min.js') continue;
						if( json.data.jsFiles[i] == '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery.datetimepicker-fr.js') continue;
						if( json.data.jsFiles[i] == '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/intlTelInput.min.js') continue;
						if( json.data.jsFiles[i] == 'https://www.google.com/recaptcha/api.js?hl=<%=_lang%>') continue;
						if( json.data.jsFiles[i] == '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/triggers.js') continue;
						
						if(json.data.jsFiles[i] != '') $('<script>').attr({src: json.data.jsFiles[i], type:'text/javascript'}).appendTo($("#frmjsfiles"));				
					}
				}
				if(json.data.bodyJs != '')
				{
					$('<script>').attr('type', 'text/javascript').text(json.data.bodyJs).appendTo("head");
				}
				
			}
		});
	};
	
	function readURL(input) 
	{
		if (input.files && input.files[0]) 
		{
			var reader = new FileReader();    
			reader.onload = function(e) 
			{
				$('#avatarimg').attr('src', e.target.result);
			}    
			reader.readAsDataURL(input.files[0]); // convert to base64 string
		}
	};

	$(document).ready(function() 
	{		
		loadForm();
		
	});
</script>
</html>