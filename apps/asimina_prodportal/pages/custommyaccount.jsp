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
<%@ page import="com.etn.asimina.authentication.*"%>

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
	String __pageTemplateType = "default";
	
%>

<%@ include file="../headerfooter.jsp"%>

<%
	String token = java.util.UUID.randomUUID().toString();
	com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "myaccount_token", token);	

	String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
	String username = null;
	Set rsClient = Etn.execute("select username from clients where id = " + escape.cote(client_id));
	if(rsClient != null && rsClient.next()){
		username = parseNull(rsClient.value("username"));
	}

	if(username == null || "".equals(username)){
		out.write("Bad request");
		return;
	}
	
	Set rsF = Etn.execute("select * from "+GlobalParm.getParm("FORMS_DB")+".process_forms where site_id = "+escape.cote(___loadedsiteid)+" and `type` = 'sign_up' ");
	rsF.next();
	
	JSONObject user = null;
	
	AsiminaAuthenticationHelper asiminaAuthenticationHelper = new AsiminaAuthenticationHelper(Etn,___loadedsiteid,GlobalParm.getParm("CLIENT_PASS_SALT"));
	if(asiminaAuthenticationHelper != null)
	{
		AsiminaAuthentication asiminaAuthentication = asiminaAuthenticationHelper.getAuthenticationObject();		
		if(asiminaAuthentication != null)
		{		
			AsiminaAuthenticationResponse getUserResponse = asiminaAuthentication.getUser(username);
			if(getUserResponse.isDone()){
				user = getUserResponse.getHttpResponse();
			}
		}
	}
	
	if(user == null){
		out.write("Bad request");
		return;
	}
	
	Map<String, String> cols = new HashMap<String, String>();
	Iterator<String> userKeys = user.keys();
	while(userKeys.hasNext()){
		String userKey = userKeys.next();
		System.out.println("----userkey:" + userKey);
		cols.put(userKey,parseNull(user.getString(userKey)));
	}
	System.out.println("birthdate:" + cols.get("birthdate"));
	if(user.has("additional_info"))
	{
		if(parseNull(user.getString("additional_info")).length() > 0)
		{
			JSONObject additionalInfo = new JSONObject(parseNull(user.getString("additional_info")));
			Iterator<String> keys = additionalInfo.keys();
			while(keys.hasNext()) 
			{
				String key = keys.next();
				//System.out.println(key + " : " + additionalInfo.optString(key));
				cols.put(key, parseNull(additionalInfo.optString(key)));
			}		
		}
	}
	
	
	Map<String, String> formFieldsMapping = new HashMap<String, String>();
	formFieldsMapping.put("username","_etn_login");
	formFieldsMapping.put("name","_etn_first_name");
	formFieldsMapping.put("surname","_etn_last_name");
	formFieldsMapping.put("email","_etn_email");
	formFieldsMapping.put("civility","_etn_civility");
	formFieldsMapping.put("mobile_number","_etn_mobile_phone");
	formFieldsMapping.put("birthdate","_etn_birthdate");
	
%>


<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
	<title><%=libelle_msg(Etn, request, "Gérer mon profil")%></title>
<%=_headhtml%>
	<% if(____menuVersion.equalsIgnoreCase("v1")){%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<%}%>

	
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery.min.js' type='text/javascript'></script>
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery-ui.min.js' type='text/javascript'></script>
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/boosted.min413.js' type='text/javascript'></script>
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/jquery.datetimepicker-fr.js' type='text/javascript'></script>
	
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/intlTelInput.min.js' type='text/javascript'></script>
	<script src='https://www.google.com/recaptcha/api.js?hl=<%=_lang%>' type='text/javascript'></script>
	<script src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>js/triggers.js' type='text/javascript'></script>
</head>
<body>
	<%=_headerHtml%>
    <div class="container">
		<h1 class='mt-2'>
			<%=libelle_msg(Etn, request, "Gérer mon profil")%>
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
				
				$("input[type=reset]").remove();
				
				//remove all hidden fields coming from forms module
				$("input[type=hidden]").remove();
				
				$("#demand_form").attr("action","myaccountbackend.jsp");
				$('<input>').attr({type: 'hidden',name: 'muid',value:'<%=parseNull(request.getParameter("muid"))%>'}).appendTo('#demand_form');				
				$('<input>').attr({type: 'hidden',name: '_t',value:'<%=token%>'}).appendTo('#demand_form');				
				$('<input>').attr({type: 'hidden',id: 'appcontext',value:'<%=parseNull(GlobalParm.getParm("EXTERNAL_FORMS_LINK"))%>'}).appendTo('#demand_form');				
				$('<input>').attr({type: 'hidden',id: 'success_msg',value:'<%=libelle_msg(Etn, request, "Account info updated")%>'}).appendTo('#demand_form');								
				$('<input>').attr({type: 'hidden',id: '_ftyp',value:'<%=rsF.value("type")%>'}).appendTo('#demand_form');				
				$('<input>').attr({type: 'hidden',id: '_flang',value:'<%=_lang%>'}).appendTo('#demand_form');				
				$('<input>').attr({type: 'hidden',id: '_fsnew',value:'<%=0%>'}).appendTo('#demand_form');				
				
				//by default we will keep email disabled
				$('#_etn_email').prop('disabled', true );
				if($('#_etn_login') )
				{
					$('#_etn_email').prop('disabled', false );
				}
				$("._etn_agreement").html("");
				$("._etn_password").html("");

				$("#_etn_avatar").attr('onchange', 'readURL(this)');			
				
				<% for(String _col : cols.keySet()) {
					if(_col.equals("username"))
					{
						out.write("$('#_etn_login').prop('disabled', true );");
						out.write("$('#"+formFieldsMapping.get(_col)+"').val('"+escapeCoteValue(cols.get(_col))+"');");
					}
					else if(_col.equals("avatar"))
					{											
						if(parseNull(cols.get(_col)).length() > 0)													
							out.write("$('#files_list__etn_avatar').html('<input type=\"hidden\" name=\"orig_avatar\" value=\""+cols.get(_col)+"\"><img id=\"avatarimg\" src=\""+cols.get(_col)+"\" style=\"max-width:36px;max-height:36px;\">');");						
						else
							out.write("$('#files_list__etn_avatar').html('<input type=\"hidden\" name=\"orig_avatar\" value=\"\"><img id=\"avatarimg\" src=\"\" style=\"max-width:36px;max-height:36px;\">');");						
					}
					else if(formFieldsMapping.get(_col) != null) out.write("if($('#"+formFieldsMapping.get(_col)+"')) $('#"+formFieldsMapping.get(_col)+"').val('"+escapeCoteValue(cols.get(_col))+"');");
					else out.write("if($('#"+_col+"')) $('#"+_col+"').val('"+escapeCoteValue(cols.get(_col))+"');");
					
				%>				
					
				<%}%>
				
				$("input.textdate").each(function(index,object){
					var val = $(object).val();
					if(val){
						var parts = val.split("-");
						if(parts.length === 3){
							var year = parts[0];
							var month = parts[1];
							var day = parts[2];
							var format = $(object).attr("date-format");
							if(format === "m/d/Y"){
								$(object).val(month + "/" + day + "/" + year);
							}else if(format === "d/m/Y"){
								$(object).val(day + "/" + month + "/" + year);
							}		
						}
					}
				});
			
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