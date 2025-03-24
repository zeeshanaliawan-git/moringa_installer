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

<%@ include file="../lib_msg.jsp"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	class FrmField {
		String name;
		String label;
		String ftype = "text";
		String possiblevalues;
		String value;
		boolean required = false;
		boolean editable = true;
	}

%>

<%
	String siteId = null;
	//new check to confirm if the signup form is configured for the menu we will use that 
	if(parseNull(request.getParameter("muid")).length() > 0)
	{
		String ___muuid2 = parseNull(request.getParameter("muid"));
		Set _rsM2 = Etn.execute("select * from site_menus where menu_uuid="+escape.cote(___muuid2));
		if(_rsM2.next())
		{
			siteId = _rsM2.value("site_id");
			String _url = "";
			if("1".equals(parseNull(GlobalParm.getParm("IS_PRODUCTION_ENV")))) _url = parseNull(_rsM2.value("my_account_prod_url"));
			else _url = parseNull(_rsM2.value("my_account_url"));
			
			if(_url.length() > 0)
			{
				response.sendRedirect(_url);
				return;
			}
		}		
	}

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
	Set rs = Etn.execute("select username from clients where id = " + escape.cote(client_id));
	if(rs != null && rs.next()){
		username = rs.value("username");	
	}
	
	if(siteId == null || "".equals(siteId) || username == null || "".equals(username)){
		out.write("Bad request");
		return;
	}
	
	JSONObject user = null;
	
	AsiminaAuthenticationHelper asiminaAuthenticationHelper = new AsiminaAuthenticationHelper(Etn,siteId,GlobalParm.getParm("CLIENT_PASS_SALT"));
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
	
	
	//by default we wont allow email to be editable
	//it can only be edited if we have username and email separate fields in the signup form
	boolean emailEditable = false;
	
	if(!parseNull(user.getString("email")).equals(username)) emailEditable = true;
	
	List<FrmField> allCols = new ArrayList<FrmField>();
	FrmField f = new FrmField();
	f.name = "email";
	f.label = libelle_msg(Etn, request, "Email");
	f.value = parseNull(user.getString("email"));
	f.required = true;
	f.editable = emailEditable;
	allCols.add(f);
	
	f = new FrmField();
	f.name = "civility";
	f.label = libelle_msg(Etn, request, "Civility");
	f.ftype = "select";
	f.value = parseNull(user.getString("civility"));
	f.possiblevalues = "{\"Mr\":\""+libelle_msg(Etn, request, "Mr")+"\",\"Mrs.\":\""+libelle_msg(Etn, request, "Mrs")+"\",\"Miss\":\""+libelle_msg(Etn, request, "Miss")+"\"}";
	f.required = true;
	allCols.add(f);
	
	f = new FrmField();
	f.name = "name";
	f.label = libelle_msg(Etn, request, "Name");
	f.value = parseNull(user.getString("name"));	
	f.required = true;
	allCols.add(f);
	
	f = new FrmField();
	f.name = "surname";
	f.label = libelle_msg(Etn, request, "Surname");
	f.value = parseNull(user.getString("surname"));
	allCols.add(f);
	
	f = new FrmField();
	f.name = "mobile_number";
	f.label = libelle_msg(Etn, request, "Contact No");
	f.value = parseNull(user.getString("mobile_number"));	
	allCols.add(f);
	
	f = new FrmField();
	f.name = "avatar";
	f.label = libelle_msg(Etn, request, "Avatar");
	f.ftype = "avatar";
	if(parseNull(user.getString("avatar")).length() > 0) f.value = parseNull(user.getString("avatar"));	
	else f.value = "";
	allCols.add(f);
		
	if(parseNull(user.getString("additional_info")).length() > 0)
	{
		JSONObject additionalInfo = new JSONObject(parseNull(user.getString("additional_info")));
		Iterator<String> keys = additionalInfo.keys();
		while(keys.hasNext()) 
		{
			String key = keys.next();
			f = new FrmField();
			f.name = key;
			f.label = key;
			f.value = parseNull(additionalInfo.optString(key));			
			allCols.add(f);
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

	<title><%=libelle_msg(Etn, request, "Gérer mon profil")%></title>

</head>
<body>
	<%=_headerHtml%>
    <div class="container">
		<h1 class='mt-2'>
			<%=libelle_msg(Etn, request, "Gérer mon profil")%>
		</h1>

		<div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
		<div class="alert alert-success" id='msgdiv' role="alert" style='display:none'></div>
		<div class='mt-5'>
		<form class="form-horizontal" id='frm' name='frm' method='post'>
			<input type='hidden' name='muid' value='<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(parseNull(request.getParameter("muid")))%>'>
			<input type='hidden' name='_t' value='<%=token%>'>
			<% for(FrmField s : allCols){
				
				String _readonly = "";
				if(!s.editable) _readonly = "readonly";
			%>
			<div class="row form-group">
				<label for="<%=s.name%>" class="col-sm-3 control-label "><%=s.label%><%if(s.required){%>&nbsp;<span style='color:red'>*</span><%}%></label>
				<div class="col-sm-9">
					<% if(s.ftype.equals("text")){%>
						<input <%=_readonly%> type="<%=s.name%>" value="<%=parseNull(s.value)%>" class="form-control registerinput <%if(s.required){out.write("required");}%>" name="<%=s.name%>" placeholder="<%=s.label%>">
					<%} else if(s.ftype.equals("select")){%>
						<select <%=_readonly%> class="form-control registerinput <%if(s.required){out.write("required");}%>" name="<%=s.name%>">
							<option value=''></option>
							<%
								JSONObject pvalues = new JSONObject(parseNull(s.possiblevalues));
								Iterator<String> keys = pvalues.keys();
								while(keys.hasNext()) 
								{
									String key = keys.next();
									String selected = "";
									if(key.equals(s.value)) selected = "selected";
									out.write("<option "+selected+" value='"+key+"'>"+pvalues.optString(key)+"</option>");
								}
							%>
						</select>
					<%} else if(s.ftype.equals("avatar")){ %>
						<div>
							<input type='hidden' name='orig_avatar' value='<%=parseNull(s.value)%>'>
							<input type='file' id='avatarfile' name='<%=s.name%>' accept=".jpg, .jpeg, .png"/>
							<img id='avatarimg' src='<%=parseNull(s.value)%>' style='max-width:36px; max-height:36px;' />
						</div>
						<div class='mt-1' style='color:red; font-size:0.8em'>Preferred size 36x36</div>
					<%}%>
				</div>
			</div>
			<%}%>
			<div class="row form-group">
				<label class='col-sm-3 control-label'></label>
				<div class="col-sm-9">
					<input type="button" class='btn btn-primary' id='savebtn' value='<%=libelle_msg(Etn, request, "Confirmer")%>' >
				</div>
			</div>
		</form>
		</div>
    </div>
	<%=_footerHtml%>

    <%=_endscriptshtml%>

</body>
<script type="text/javascript">	
	$(document).ready(function() 
	{		
		readURL=function(input) 
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

		$("#avatarfile").change(function() {
			readURL(this);
		});

		$("#savebtn").click(function()
		{
			$("#errdiv").html("");
			$("#errdiv").hide();
			$("#msgdiv").html("");
			$("#msgdiv").hide();
			
			var anyReqMissing = false;
			$(".required").each(function(){
				if($.trim($(this).val()) == '')
				{
					anyReqMissing = true;
				}
			});
			
			if(anyReqMissing)
			{
				$("#errdiv").html("<%=libelle_msg(Etn, request, "Some of required fields are missing")%>");
				$("#errdiv").show();
				return false;
			}
			
			var form = $('#frm')[0];

			var data = new FormData(form);
				
			$.ajax({
				url : 'myaccountbackend.jsp',
				type: "POST",
				enctype: 'multipart/form-data',
				processData: false,  // Important!
				contentType: false,
				cache: false,
				data: data,
                dataType : 'json',
				success : function(json)
	       		{	
					if(json.response == 'error') 
					{
						$("#errdiv").html(json.msg);
						$("#errdiv").show();
						$("#errdiv").focus();
					}
					else
					{
						$("#msgdiv").html(json.msg);
						$("#msgdiv").show();
						$("#msgdiv").focus();
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
</html>