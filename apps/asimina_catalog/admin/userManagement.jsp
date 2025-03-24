<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.util.*, com.etn.asimina.util.ActivityLog"%>

<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%!
	String addSelectControl2(String id, String name, Map<String,String> map, boolean isMultiSelect, int maxControlSize)
	{
		int size = map.size();

		String html = "<select class='form-control' name='" + name + "' id='" + id + "' ";
		if(isMultiSelect)
			html = html + " size='" + maxControlSize + "' MULTIPLE>";
		else
			html = html + " >";

		for(String key : map.keySet())
		{
			String val = map.get(key);
			html = html + "<option value='" + escapeCoteValue(key) + "'>"+escapeCoteValue(val)+"</option>";
		}
		html = html + "</select>";
		return html;
	}
%>

<%
	String saveUsers = parseNull(request.getParameter("saveUsers"));
	if(saveUsers.equals("")) saveUsers = "0";
	String updateUsers = parseNull(request.getParameter("updateUsers"));
	if(updateUsers.equals("")) updateUsers = "0";
	String[] usernames = request.getParameterValues("username");
    String[] emails = request.getParameterValues("email");
	String[] personids = request.getParameterValues("personid");
	String[] firstnames = request.getParameterValues("firstname");
	String[] lastnames = request.getParameterValues("lastname");
	String[] passwords = request.getParameterValues("password");
	String[] profile = request.getParameterValues("profile");
	String[] deleteUsers = request.getParameterValues("deleteUser");

	String[] siteid = request.getParameterValues("siteid");

	String message = "";

	String currentuserprofil = "";
	if(session.getAttribute("PROFIL") != null) currentuserprofil = (String)session.getAttribute("PROFIL");

	List<String> assignSiteProfils = new ArrayList<String>();
	Map<String, String> profiles = new LinkedHashMap<String, String>();
	Set rsProfile = Etn.execute("select * from profil order by description ");
	while(rsProfile.next())
	{
		profiles.put(rsProfile.value("profil_id"),rsProfile.value("profil"));

		if("1".equals(rsProfile.value("assign_site"))) assignSiteProfils.add(rsProfile.value("profil_id"));
	}

	//only admin profil can save/update users
	if(updateUsers.equals("1") && usernames != null && ("ADMIN".equalsIgnoreCase(currentuserprofil) || "SUPER_ADMIN".equalsIgnoreCase(currentuserprofil)) )
	{
        String updatedPersonsIds = "";
        String updatedPersonsNames = "";
        Set rs_person = null;
        boolean  is_name_udpated  = true;
		for(int i=0; i<usernames.length;i++)
		{
            is_name_udpated  = true;
            rs_person =  Etn.execute("select first_name, last_name from person where person_id = "+escape.cote(personids[i]));
            rs_person.next();
            if(firstnames[i].trim().equals(parseNull(rs_person.value(0)))  && lastnames[i].trim().equals(parseNull(rs_person.value(1))))
                is_name_udpated = false;

            Etn.executeCmd("update person set First_name = "+escape.cote(firstnames[i].trim())+", last_name = "+escape.cote(lastnames[i].trim())+", e_mail = "+escape.cote(emails[i].trim())+ "  where person_id = "+escape.cote(personids[i])+" ");
            Set rs1 = Etn.execute("select * from profilperson where profil_id = "+escape.cote(profile[i])+" and person_id = "+escape.cote(personids[i])+" ");
            if(is_name_udpated || rs1.rs.Rows ==  0)
            {
                if(updatedPersonsNames.length()>0)
                    updatedPersonsNames += ", ";
                if(updatedPersonsIds.length()>0)
                    updatedPersonsIds += ",";

                updatedPersonsNames += firstnames[i];
                updatedPersonsIds += personids[i];
            }

            if(rs1.rs.Rows == 0) Etn.executeCmd("insert into profilperson (profil_id, person_id) values ("+escape.cote(profile[i])+","+escape.cote(personids[i])+" )");

			Etn.executeCmd("delete from person_sites where person_id = " + escape.cote(personids[i]));
			if(assignSiteProfils.contains(profile[i]))
			{
				String[] siteids = parseNull(siteid[i]).split(",");
				if(siteids != null)
				{
					for(int j=0;j<siteids.length;j++)
					{
						if(parseNull(siteids[j]).length() > 0) Etn.execute("insert into person_sites (person_id, site_id ) values ("+escape.cote(personids[i])+", "+escape.cote(parseNull(siteids[j]))+") " );
					}
				}
			}

			Etn.executeCmd("delete from profilperson where person_id = "+escape.cote(personids[i])+" and profil_id <> "+escape.cote(profile[i]));
		}
        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),updatedPersonsIds,"UPDATED","Users",updatedPersonsNames,parseNull(getSelectedSiteId(session)));

		if(deleteUsers != null)
		{
            Set rs_name = null;
            String deletedNames = "";
			for(int i=0; i<deleteUsers.length;i++)
			{
                rs_name =  Etn.execute("select first_name from person where person_id = "+escape.cote(deleteUsers[i])+" ");
                rs_name.next();
                if(deletedNames.length()>0) deletedNames += ", ";
                deletedNames += parseNull(rs_name.value(0));

				Etn.executeCmd("delete from login where pid = "+escape.cote(deleteUsers[i])+" ");
				Etn.executeCmd("delete from profilperson where person_id = "+escape.cote(deleteUsers[i])+" ");
				Etn.executeCmd("delete from person where person_id = "+escape.cote(deleteUsers[i])+" ");
				Etn.executeCmd("delete from person_sites where person_id = "+escape.cote(deleteUsers[i])+" ");

			}
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),convertArrayToCommaSeperated(deleteUsers),"DELETED","Users",deletedNames,parseNull(getSelectedSiteId(session)));

		}
		message = "Users updated/deleted successfully!!!";
	}

	Set rsUsers = Etn.execute("select p.person_id,l.is_two_auth_enabled as auth, l.name as username, p.First_name, p.last_name, p.e_mail, l.pid, pp.profil_id from login l, person p, profilperson pp where pp.person_id = p.person_id and p.person_id = l.pid order by p.person_id ");

	Set rsSites = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".sites where is_active = 1 order by name " );
	Map<String, String> sites = new LinkedHashMap<String, String>();
	while(rsSites.next())
	{
		sites.put(rsSites.value("id"), rsSites.value("name"));
	}

	Set rsForms = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished order by table_name " );
	Map<String, String> forms = new LinkedHashMap<String, String>();
	while(rsForms.next())
	{
		forms.put(rsForms.value("form_id"), rsForms.value("table_name"));
	}

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Users</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Users", ""});
%>

<script>
	function resetPassword(user)
	{
		$("#dialogWindow").html("<div class='modal-dialog ' role='document'><div class='modal-content'><div class='modal-header'><h5 class='modal-title'>Reset password</h5><button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button></div><div class='modal-body'><div style='font-size:10pt; text-align:center;'><div><input class='form-control' placeholder='New password' type='password' autocomplete='off' value='' id='newPassword' maxlength='50' size='30' /></div></div><div class='modal-footer'><button type='button' class='btn btn-light' data-dismiss='modal'>Cancel</button><button type='button' class='btn btn-success' onclick='saveNewPassword(\""+user+"\")'>Ok</button></div></div></div></div>");
		$("#dialogWindow").modal('show');
	}

    function ValidateEmail(mail)
    {
     if (/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(mail))
      {
        return (true);
      }
        return (false);
    }
	function saveNewPassword(param)
	{
        var user =   param.split(",");
        var pid  =  user[0];
        var username  =  user[1];
        console.log(username+"  "+pid)
		if(document.getElementById('newPassword'))
		{
			if( document.getElementById('newPassword').value == '') alert('Enter password');
			else
			{
				jQuery.ajax({
					url: 'updatePassword.jsp',
					data: {pid : pid, username:username, password : document.getElementById('newPassword').value},
					type: 'POST',
					dataType: 'json',
					async: false,
					success : function(json) {
						if(json.STATUS == "ERROR")
						{
							alert("There was some error while updating password");
							$("#dialogWindow").modal('hide');
						}
                        else if(json.STATUS == "INVALID"){
                            alert("Password must be at least 12 characters long with one uppercase letter, one lowercase letter, one number and one special character. Special characters allowed are !@#$%^&*");
                        }
						else
						{
							alert("Password changed successfully");
							$("#dialogWindow").modal('hide');
						}
					}
				});

			}
		}
	}

	function onUpdateUsers()
	{
		if (document.userFrm.username.length == undefined)
		{
			jQuery("#userErr_0").html("&nbsp;");
			if(document.userFrm.firstname.value == '')
			{
				jQuery("#userErr_0").html("Required fields are missing");
				return;
			}else if(jQuery('#email_'+i).val().trim() != ""){
                if(!ValidateEmail(jQuery('#email_'+i).val().trim())){
                    jQuery("#userErr_"+i).html("Email is not valid");
                    isError = 1;
                }
            }
			var _siteid = "";
			jQuery('#select_updsite_0 :selected').each(function(i, selected){
				if(jQuery(selected).val() != "#") _siteid = _siteid + jQuery(selected).val() + ",";
			});
			if(_siteid != "") _siteid = _siteid.substring(0, _siteid.length - 1);
			jQuery("#upd_siteid_0").val(_siteid);
			document.userFrm.submit();
		}
		else
		{
			var isError = 0;
			for(var i=0;i<document.userFrm.username.length;i++)
			{
				jQuery("#userErr_"+i).html("&nbsp;");
				if(document.userFrm.firstname[i].value == '')
				{
					jQuery("#userErr_"+i).html("Required fields are missing");
					isError = 1;
				}else if(jQuery('#email_'+i).val().trim() != ""){
                    if(!ValidateEmail(jQuery('#email_'+i).val().trim())){
                        jQuery("#userErr_"+i).html("Email is not valid");
                        isError = 1;
                    }
                }
				var _siteid = "";
				jQuery('#select_updsite_'+i+' :selected').each(function(i, selected){
					if(jQuery(selected).val() != "#") _siteid = _siteid + jQuery(selected).val() + ",";
				});
				if(_siteid != "") _siteid = _siteid.substring(0, _siteid.length - 1);
				jQuery("#upd_siteid_"+i).val(_siteid);
			}
			if(!isError) document.userFrm.submit();
		}
	}

	function onSaveNewUsers()
	{
		var isError = 0;
		var anythingToSave = 0;
		for(var i=0; i<5; i++)
		{
			jQuery("#new_colErr_"+i).html("&nbsp;");
			var rowError = 0;
			if(jQuery('#new_username_'+i).val() != '' ||  jQuery('#new_firstname_'+i).val() != '')
			{
				anythingToSave = 1;
				if(jQuery('#new_username_'+i).val() == '')
				{
					isError = 1;
					rowError = 1;
				}
				else if(jQuery('#new_firstname_'+i).val() == '')
				{
					isError = 1;
					rowError = 1;
				}
				else if(jQuery('#new_password_'+i).val() == '')
				{
					isError = 1;
					rowError = 1;
				}
				if(rowError) jQuery("#new_colErr_"+i).html("Required fields are missing");
				else
				{
                    if(jQuery('#new_email_'+i).val().trim() != '')
                    {
                        if(!ValidateEmail(jQuery('#new_email_'+i).val().trim())){
                            jQuery("#new_colErr_"+i).html("Email is not valid");
                            isError = 1;
                            rowError = 1;
                        }
                    }
				}

				if(!rowError)//check any site is selected
				{
					var _siteid = "";
					$('#select_newsite_'+i+' :selected').each(function(i, selected){
						if($(selected).val() != "#") _siteid = _siteid + $(selected).val() + ",";
					});
					if(_siteid != '') _siteid = _siteid.substring(0, _siteid.length - 1);
					$("#new_siteid_"+i).val(_siteid);
				}
			}
		}
		if (isError) return;
		if(!anythingToSave) return;
         jQuery.ajax({
             url: 'savenewuser.jsp',
             data: $('#newUserFrm').serialize(),
             type: 'POST',
             dataType: 'json',
             success : function(json) {
                if(json.status == "error")
                    jQuery("#new_colErr_"+json.errorline).html(json.message);
                else
                    document.newUserFrm.submit();
             }
         });
	}
</script>

</head>
<body>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
		<div>
			<h1 class="h2">Users</h1>
			<p class="lead"></p>
		</div>
		<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Users');" title="Add to shortcuts">
			<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
		</button>
	</div>
	<!-- /title -->


	<!-- container -->
	<div class="animated fadeIn">
	<form id="newUserFrm" name="newUserFrm" action="userManagement.jsp" method="post">
		<input class="form-control" type="hidden" name="saveUsers" value="1"/>

		<table class="table table-hover table-bordered results" cellpadding="0" cellspacing="0" border="0" id="newUsersTbl" width="95%">
		<thead class="thead-dark">
		<tr>
			<th>Login<span style="color:red">*</span></th>
			<th>Firstname<span style="color:red">*</span></th>
			<th>Lastname</th>
            <th>Email</th>
			<th>Password<span style="color:red">*</span></th>
			<th>Profile<span style="color:red">*</span></th>
			<th>Site(s)</th>
			<th width="20%">&nbsp;</th>
		</tr>
		</thead>
		<% for (int i=0;i<5;i++) { %>
			<tr>
				<td><input class="form-control" type='text' maxlength='50' size='30' id='new_username_<%=i%>' name='username' value='' /></td>
				<td><input class="form-control" type='text' maxlength='50' size='35' id='new_firstname_<%=i%>' name='firstname' value='' /></td>
				<td><input class="form-control" type='text' maxlength='50' size='35' id='new_lastname_<%=i%>' name='lastname' value='' /></td>
                <td><input class="form-control" type='email' maxlength='50' size='35' id='new_email_<%=i%>' name='email' value='' /></td>
				<td><input class="form-control" type='password' autocomplete='off' maxlength='15' size='25' id='new_password_<%=i%>' name='password' value='' /></td>
				<td>
					<select id='select_profile_<%=i%>' class="form-control" name="profile" onchange='changeProfile(this, "new", "<%=i%>")'>
						<% for(String __pr : profiles.keySet()) {
							out.write("<option value='"+__pr+"'>"+escapeCoteValue(profiles.get(__pr))+"</option>");
						} %>
					</select>
				<td><span id='spannewsiteid_<%=i%>' style='display:none'><%=addSelectControl2("select_newsite_"+i,"",sites, true, 3)%></span></td>
				<td style="width: 60px;"><span id="new_colErr_<%=i%>" style="font-size:9pt;color:red">&nbsp;</span></td>
			</tr>
			<input class="form-control" type="hidden" name="siteid" id="new_siteid_<%=i%>" value="" />
		<% } %>
		</table>
		<div style='margin-top:5px; text-align:center'><input class="btn btn-primary" type='button' value='Save User(s)' onclick="onSaveNewUsers()"/></div>
		<br>
	</form>
	<div class="mb-1" align='right'>
		<button class="btn btn-primary" type="button" id ='SendEmailToAll' onclick="setForEmail('All','SendEmailToAll')">Enable Auth For All</button>
		<button class="btn btn-danger" type="button" id ='UnsetAuthFromAll' onclick="unSetForEmail('All','UnsetAuthFromAll')">Disable Auth For All</button>
	</div>
	<form name="userFrm" action="userManagement.jsp" method="post">
	<input class="form-control" type="hidden" name="updateUsers" value="1"/>
	<table class="table table-hover table-bordered" >
		<%
			if(!message.equals("")){
		%>
		<tr>
			<td colspan="7" style="color:green; font-weight:bold"><%=message%></td>
		</tr>
		<%}%>
		<thead class="thead-dark">
		<tr>
			<th>Login</th>
			<th>Firstname<span style="color:red">*</span></th>
			<th>Lastname</th>
            <th>Email</th>
			<th>Profile<span style="color:red">*</span></th>
			<th>Site(s)</th>
			<th>Form (s)</th>
			<th>Delete</th>
			<th>Password</th>
			<th>Auth Management</th>
			<%-- <th>Remove Auth</th> --%>
			<th style="width: 40px;">&nbsp;</th>
		</tr>
		</thead>
		<%	int rowsNum = 0;
		    while(rsUsers.next()){
			String usernameTemp = escapeCoteValue(parseNull(rsUsers.value("username")));
		%>
			<tr>
				<td align="left"><input class="form-control" type='text' maxlength='50' size='30' disabled value='<%=escapeCoteValue(rsUsers.value("username"))%>' /></td>
				<td align="left"><input class="form-control" type='text' maxlength='50' size='35' id='firstname_<%=rowsNum%>' name='firstname' value='<%=escapeCoteValue(rsUsers.value("First_name"))%>' /></td>
				<td align="left"><input class="form-control" type='text' maxlength='50' size='35' id='lastname_<%=rowsNum%>' name='lastname' value='<%=escapeCoteValue(rsUsers.value("last_name"))%>' /></td>
                <td align="left"><input class="form-control" type='email' maxlength='50' size='35' id='email_<%=rowsNum%>' name='email' value='<%=escapeCoteValue(parseNull(rsUsers.value("e_mail")))%>' /></td>

				<td align="left">
					<select id='upd_select_profile_<%=rowsNum%>' class="form-control" name="profile" onchange='changeProfile(this, "old", "<%=rowsNum%>")'>
						<% for(String __pr : profiles.keySet()) {
							out.write("<option value='"+__pr+"'>"+escapeCoteValue(profiles.get(__pr))+"</option>");
						} %>
					</select>
				</td>
				<td><span id='spanupdsiteid_<%=rowsNum%>' style='display:none'><%=addSelectControl2("select_updsite_"+rowsNum,"",sites, true, 3)%></span></td>
				<td><span id='spanupdform_<%=rowsNum%>' class="form-btn" style='display:none'><button type="button" class="btn btn-primary btn-sm" onclick="getForms('select_updsite_<%=rowsNum%>','<%= escapeCoteValue(rsUsers.value("person_id")) %>')">Forms</button></span></td>
				<td align="center" id="activeChkBoxCol_<%=rowsNum%>"><input class="form-control" type='checkbox' id='isDelete_<%=rowsNum%>' name='deleteUser' value='<%=escapeCoteValue(rsUsers.value("person_id"))%>' /></td>
				<td align="center"><a href="javascript:resetPassword('<%=rsUsers.value("pid")+","+rsUsers.value("username")%>')" style="color:black">Change</a></td>
				<td align="left" width="10%">
				<%if(parseNull(rsUsers.value("auth")).equals("0")){%>
					<button class="btn btn-success" type="button" title="Enable Auth" id ='SetEmailBtn<%=rowsNum%>' onclick="setForEmail('<%=usernameTemp%>','SetEmailBtn<%=rowsNum%>')">
						<i class="fa fa-lock"></i>
					</button>
				<%}else{%>
					<button class="btn btn-success" type="button" title="Email QR code" id ='SetEmailBtn<%=rowsNum%>' onclick="setForEmail('<%=usernameTemp%>','SetEmailBtn<%=rowsNum%>')">
						<i class="fa fa-envelope"></i>
					</button>
					<button class="btn btn-dark" type="button" title="Disable Auth" id ='UnSetEmailBtn<%=rowsNum%>' onclick="unSetForEmail('<%=usernameTemp%>','UnSetEmailBtn<%=rowsNum%>')">
						<i class="fa fa-unlock"></i>
					</button>
				<%}%>
				</td>
				<%-- <td align="left" width="10%"><button class="btn btn-success" type="button" id ='UnSetEmailBtn<%=rowsNum%>' onclick="unSetForEmail('<%=usernameTemp%>','UnSetEmailBtn<%=rowsNum%>')">Remove Auth</button></td> --%>
				<td align="left" width="10%"><span id="userErr_<%=rowsNum%>" style="font-size:9pt;color:red">&nbsp;</span></td>
			</tr>
			<input class="form-control" type="hidden" id="username_<%=rowsNum%>" name="username" value="<%=escapeCoteValue(rsUsers.value("username"))%>"	/>
			<input class="form-control" type="hidden" id="person_id_<%=rowsNum%>" name="personid" value="<%=escapeCoteValue(rsUsers.value("person_id"))%>"	/>
			<input class="form-control" type="hidden" name="siteid" id="upd_siteid_<%=rowsNum%>" value="" />
			<script>
				$("#upd_select_profile_<%=rowsNum%>").val('<%=rsUsers.value("profil_id")%>');
				<% if(assignSiteProfils.contains(rsUsers.value("profil_id"))) { %>
					$("#spanupdsiteid_<%=rowsNum%>").show();
					$("#spanupdform_<%=rowsNum%>").show();
				<% } %>

				var dataarray = new Array();
				<%  Set rs1 = Etn.execute("select site_id from person_sites where person_id = "+escape.cote(rsUsers.value("person_id"))+" ");
				while(rs1.next())
				{ %>
					dataarray.push('<%=rs1.value("site_id")%>');
				<%  }  %>
				jQuery("#select_updsite_<%=rowsNum%>").val(dataarray);

			</script>
		<%
			rowsNum ++;
			}%>
	</table>
	<% if(rowsNum > 0) { %>
		<div style='margin-top:5px; text-align:center'><input class="btn btn-primary" type='button' value='Save' onclick="onUpdateUsers()"/></div>
	<% } %>
	<br />
	</form>

	<br>
	<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
</main>
	<%@ include file="/WEB-INF/include/footer.jsp" %>
<div id="dialogWindow" class="modal fade" ></div>

<!-- Modal -->
<div class="modal fade" id="forms-modal" tabindex="-1" role="dialog" aria-labelledby="formModal" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="form-modal-title">Forms</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
	  <input type="hidden" id="person-id" />
      <div class="modal-body" style="max-height: 250px; overflow-y:auto;">
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" onclick="setForms($('#forms-modal').find('#person-id').val())">Save</button>
      </div>
    </div>
  </div>
</div>



</div><!-- /c-body -->

<script>
jQuery(document).ready(function() {

	$("#forms-modal").on("hidden.bs.modal", function(){
		$(this).find(".modal-body").empty();
		$(this).find("#person-id").val("");
	});

	getForms = function(id,pId){
		$.ajax({
			url: "userManagementAjax.jsp", 
			method: 'post',
			data:{
				"action":"getForms",
				"person_id": pId,
				'sites':$(`#${id}`).val().toString()
			},
			success: function(result){
				let data = result.data;
				let modalbody = $("#forms-modal").find(".modal-body");
				let section='';
				for (let i = 0; i < data.length; i++) {
					if(section !== data[i].site) { 
						$(`<div class='section mt-3' id='${data[i].site.trim().replaceAll(" ","_")}'><h5>${_hEscapeHtml(data[i].site)}<h5></div>`).appendTo(modalbody);
						section = data[i].site;
					}
					$(`<div class="custom-control custom-checkbox mt-1">
							<input type="checkbox" class="custom-control-input" id="${data[i].id}" ${data[i].selected ? "checked" : ""}>
							<label class="custom-control-label m-0 m-auto" for="${data[i].id}">${_hEscapeHtml(data[i].name)}</label>
						</div>`).appendTo(modalbody.find(`[id='${data[i].site.trim().replaceAll(" ","_")}']`));
				}				
				$("#forms-modal").find("#person-id").val(pId);
				$("#forms-modal").modal("show");
			}
		});	
	}

	showAlert = function(type,txt)
	{
		let alert = $(".c-main").prepend($(`<div class='d-flex justify-content-center align-item-center h-100'>
			<div id="alert-msg" class="alert alert-${type} alert-dismissible fade show position-fixed mt-3" role="alert" style="z-index:9999;text-align:center;">
				${_hEscapeHtml(txt)}
				<button type="button" class="close" data-dismiss="alert" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div></div>`));

		setTimeout(() => {
			$("#alert-msg").fadeOut(1000, function() {
				$(this).remove();
			});
		}, 4000);
	}

	setForms = function(pid)
	{
		
		let formids = [];
		
		$("#forms-modal").find(".modal-body").find("input[type='checkbox']:checked").each(function(){
			formids.push($(this).attr("id"));
		});
				
		$.ajax({
			url: "userManagementAjax.jsp", 
			method: 'post',
			data:{
				"action":"setForms",
				"person_id": pid,
				"ids": formids
			},
			success: function(result){
				if(result.status == 0){
					$("#forms-modal").modal("hide");
					showAlert('success',result.msg);
				}else{					
					showAlert('success',result.msg);
				}
			}
		});	
	}

	changeProfile=function (obj, typ, i)
	{
		var obj2 = "#spannewsiteid_" + i;
		
		if("old" == typ)
		{
			obj2 = "#spanupdsiteid_" + i;
		}
		var val = $(obj).val();

		<% for(String spr : assignSiteProfils) { 
			%>
			if(val == '<%=spr%>')
			{
				$(obj2).fadeIn();
				$("#spanupdform_"+i).fadeIn();
				return;
			}
		<% } %>
		$("#spanupdform_"+i).fadeOut();
		$(obj2).fadeOut();
	}
	setForEmail=function(usernameTemp,btnId){
		$('#'+btnId)[0].className='btn btn-secondary';
		$.ajax({
			url: '<%=request.getContextPath()%>'+"/admin/setSecretKey.jsp", 
			method: 'post',
			data:{
				"username":usernameTemp,
				"action":"set"
			},
			success: function(resp){
				if(resp.status==0){
					showAlert('success',"2FA is enabled and an email is sent.");
					window.location.href = "<%=request.getContextPath()%>/admin/userManagement.jsp";
				}else{
					showAlert('danger',resp.message);
				}
			}
		});
	}
	unSetForEmail=function(usernameTemp,btnId){
		$('#'+btnId)[0].className='btn btn-secondary';
		$.ajax({
			url: '<%=request.getContextPath()%>'+"/admin/setSecretKey.jsp", 
			method: 'post',
			data:{
				"username":usernameTemp,
				"action":"unset"
			},
			success: function(resp){
				if(resp.status==0){
					showAlert('success',"2FA is disabled");
					window.location.href = "<%=request.getContextPath()%>/admin/userManagement.jsp";
				}else{
					showAlert('success',resp.message);
				}
			}
		});
	}
});
</script>
</body>
</html>
