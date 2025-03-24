<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.util.Map,java.util.*"%>
<%@ page import="java.util.LinkedHashMap"%>

<%@ include file="../common.jsp" %>

<%!
	String addSelectControl2(String id, String name, Map<String,String> map, boolean isMultiSelect, int maxControlSize)
	{
		return addSelectControl2(id, name, map, isMultiSelect, maxControlSize, null);
	}
	
	String addSelectControl2(String id, String name, Map<String,String> map, boolean isMultiSelect, int maxControlSize, List<String> values)
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
			String slt = "";			
			if(values != null && values.contains(key)) slt= "selected";
			html = html + "<option "+slt+" value='" + escapeCoteValue(key) + "'>"+escapeCoteValue(val)+"</option>";
		}
		html = html + "</select>";
		return html;
	}
%>

<%
	String updateUsers = parseNull(request.getParameter("updateUsers"));
	if(updateUsers.equals("")) updateUsers = "0";
	String[] usernames = request.getParameterValues("username");
	String[] personids = request.getParameterValues("personid");
	String[] firstnames = request.getParameterValues("firstname");
	String[] lastnames = request.getParameterValues("lastname");
    String[] emails = request.getParameterValues("email");
	String[] passwords = request.getParameterValues("password");
	String[] profile = request.getParameterValues("profile");
	String[] deleteUsers = request.getParameterValues("deleteUser");
	String[] siteid = request.getParameterValues("siteid");
	String message = "";
	List<String> assignSiteProfils = new ArrayList<String>();
	Map<String, String> profiles = new LinkedHashMap<String, String>();
	
	String currentuserprofil = "";
	if(session.getAttribute("PROFIL") != null) currentuserprofil = (String)session.getAttribute("PROFIL");
	
	Set rsProfile = Etn.execute("select * from profil order by description ");
//	profiles.put("#","-- Selecciona perfil --");
	while(rsProfile.next())
	{
		profiles.put(rsProfile.value("profil_id"),rsProfile.value("description"));
		if("1".equals(rsProfile.value("assign_site"))) assignSiteProfils.add(rsProfile.value("profil_id"));
	}
	if(updateUsers.equals("1") && usernames != null  && ("ADMIN".equalsIgnoreCase(currentuserprofil) || "SUPER_ADMIN".equalsIgnoreCase(currentuserprofil)))
	{
		for(int i=0; i<usernames.length;i++)
		{
			Etn.executeCmd("update person set First_name = "+escape.cote(firstnames[i])+", last_name = "+escape.cote(lastnames[i])+", e_mail = "+escape.cote(emails[i])+" where person_id = "+escape.cote(personids[i])+" ");
			String[] _profiles = profile[i].split(",");
			for(int j=0;j<_profiles.length;j++)
			{
				Set rs1 = Etn.execute("select * from profilperson where profil_id = "+escape.cote(_profiles[j])+" and person_id = "+escape.cote(personids[i])+" ");
				if(rs1.rs.Rows ==0) Etn.executeCmd("insert into profilperson (profil_id, person_id) values ("+escape.cote(_profiles[j])+","+escape.cote(personids[i])+")");

				if(assignSiteProfils.contains(profile[i]))
				{
					Etn.executeCmd("delete from person_sites where person_id = " + escape.cote(personids[i]));
					String[] siteids = parseNull(siteid[i]).split(",");
					if(siteids != null)
					{
						for(int k=0;k<siteids.length;k++)
						{
							if(parseNull(siteids[k]).length() > 0) Etn.execute("insert into person_sites (person_id, site_id ) values ("+escape.cote(personids[i])+", "+escape.cote(parseNull(siteids[k]))+") " );
						}
					}
				}
			}
			Etn.executeCmd("delete from profilperson where person_id = "+escape.cote(personids[i])+" and profil_id not in ("+escape.cote(profile[i])+")");
		}

		if(deleteUsers != null)
		{
			for(int i=0; i<deleteUsers.length;i++)
			{
				Etn.executeCmd("delete from login where pid = "+escape.cote(deleteUsers[i])+" ");
				Etn.executeCmd("delete from profilperson where person_id = "+escape.cote(deleteUsers[i])+" ");
				Etn.executeCmd("delete from person where person_id = "+escape.cote(deleteUsers[i])+" ");
				Etn.executeCmd("delete from person_sites where person_id = "+escape.cote(deleteUsers[i])+" ");

			}
		}
		message = "Users updated/deleted successfully!!!";
	}

	Set rsUsers = Etn.execute("select p.person_id,l.is_two_auth_enabled as auth, l.name as username, p.First_name, p.last_name, p.e_mail as email, pr.assign_site from login l, person p, profilperson pp, profil pr where pr.profil_id = pp.profil_id and pp.person_id = p.person_id and p.person_id = l.pid order by l.name");

	Set rsSites = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".sites order by name " );
	Map<String, String> sites = new LinkedHashMap<String, String>();
	while(rsSites.next())
	{
		sites.put(rsSites.value("id"), rsSites.value("name"));
	}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
	
	<title>User Management</title>
   	
	<link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
			<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
				<h1 class="h2">User Management</h1>
			</div>
        	<div class="animated fadeIn">
				<div class="card">
					<div class="card-body bg-light">
						<form id ="newUserFrm" name="newUserFrm" action="userManagement.jsp" method="post" class="form-horizontal" role="form">

							<input type="hidden" name="saveUsers" value="1"/>

							<table>
								<thead>
									<tr>
										<th>Login<span style="color:red">*</span></th>
										<th>Firstname<span style="color:red">*</span></th>
										<th>Lastname</th>
										<th>Email</th>
										<th>Password<span style="color:red">*</span></th>
										<th>Profile<span style="color:red">*</span></th>
										<th>Site(s)</th>
										<th>&nbsp;</th>

									</tr>
								</thead>
								<tbody>
									<% for (int i=0;i<5;i++) { %>
										<tr>
											<td>
												<input type='text' maxlength='50' size='30' id='new_username_<%=i%>' name='username' class="hasDatepicker form-control" value='' />
											</td>
											<td>
												<input type='text' maxlength='50' size='30' id='new_firstname_<%=i%>' name='firstname' class="hasDatepicker form-control" value='' />
											</td>
											<td>
												<input type='text' maxlength='50' size='30' id='new_lastname_<%=i%>' name='lastname' class="hasDatepicker form-control" value='' />
											</td>
											<td><input class="form-control" type='email' maxlength='50' size='35' id='new_email_<%=i%>' name='email' value='' /></td>

											<td>
												<input type='password' maxlength='50' size='30' id='new_password_<%=i%>' name='password' class="hasDatepicker form-control" value='' />
											</td>
											
											<td><%=addSelectControl("select_profile_"+i,"_profile",profiles, false, 3,"new",i)%></td>
											<td><span id='spannewsiteid_<%=i%>' style='display:none'><%=addSelectControl2("select_newsite_"+i,"",sites, true, 3)%></span></td>

											<td><span id="new_colErr_<%=i%>" style="font-size:9pt;color:red">&nbsp;</span></td>
										</tr>
										<input class="form-control" type="hidden" name="siteid" id="new_siteid_<%=i%>" value="" />
										<input type="hidden" name="profile" id="new_profile_<%=i%>" value="" />
									<%}%>
								</tbody>
							</table>
							<div class="row">
								<div class="col-sm-12 text-center">
									<div role="group" aria-label="controls">
										<button type="button" class="btn btn-success" name="Search" onclick="onSaveNewUsers()" style="margin-top:30px">Save User(s)</button>
									</div>
								</div>
							</div>
						</form>
              		</div>
            	</div>
            	
				<div class="mb-1" align="right">
					<button class="btn btn-primary" type="button" id ='SendEmailToAll' onclick="setForEmail('All','SendEmailToAll')">Enable Auth For All</button>
					<button class="btn btn-danger" type="button" id ='UnsetAuthFromAll' onclick="unSetForEmail('All','UnsetAuthFromAll')">Disable Auth For All</button>
				</div>

				<div class="card">
              		<div class="card-body p-0">
						<form id ="updUserFrm" name="userFrm" action="userManagement.jsp" method="post" class="form-horizontal" role="form">
							<input type="hidden" name="updateUsers" value="1"/>
							<table class="table table-hover table-striped">
								<thead>
									<tr>
										<th>Login</th>
										<th>Firstname<span style="color:red">*</span></th>
										<th>Lastname</th>
										<th>Email</th>
										<th>Profile<span style="color:red">*</span></th>
										<th>Site(s)</th>
										<th>Delete</th>
										<th>Passsword</th>
										<th style="width:120px;">Auth</th>
										<th> </th>
									</tr>
								</thead>
								<tbody>
									<%	
									int rowsNum = 0;
									while(rsUsers.next()){
										String usernameTemp = escapeCoteValue(parseNull(rsUsers.value("username")));		
									%>
									<tr>
										<td align="left">
											<input type='text' maxlength='50' size='30' disabled class="form-control" value='<%=escapeCoteValue(rsUsers.value("username"))%>' />
										</td>
										<td align="left">
											<input type='text' maxlength='50' size='30' class="form-control" id='firstname_<%=rowsNum%>' name='firstname' value='<%=escapeCoteValue(rsUsers.value("First_name"))%>' />
										</td>
										<td align="left">
											<input type='text' maxlength='50' size='30' class="form-control" id='lastname_<%=rowsNum%>' name='lastname' value='<%=escapeCoteValue(rsUsers.value("last_name"))%>' />
										</td>
										<td align="left">
											<input type='text' maxlength='50' size='30' class="form-control" id='email_<%=rowsNum%>' name='email' value='<%=escapeCoteValue(parseNull(rsUsers.value("email")))%>' />
										</td>
										<td align="left">
											<%=addSelectControl("upd_select_profile_"+rowsNum,"upd_profile",profiles, false, 3,"old",rowsNum)%>
										</td>
										<td>
											<% 
											List<String> personSites = new ArrayList<>();
											if("1".equals(rsUsers.value("assign_site")))
											{
												Set rsPs = Etn.execute("select * from person_sites where person_id = "+escape.cote(rsUsers.value("person_id")));
												while(rsPs.next())
												{
													personSites.add(rsPs.value("site_id"));
												}
											}
											%>
											<span id='spanupdsiteid_<%=rowsNum%>' style='<%=("1".equals(rsUsers.value("assign_site"))?"":"display:none")%>'>
												<%=addSelectControl2("select_updsite_"+rowsNum,"",sites, true, 3, personSites)%>
											</span>
										</td>

										<td align="center" id="activeChkBoxCol_<%=rowsNum%>">
											<input type='checkbox' id='isDelete_<%=rowsNum%>' name='deleteUser' value='<%=escapeCoteValue(rsUsers.value("person_id"))%>' />
										</td>
										<td align="center">
											<a href="javascript:resetPassword('<%=escapeCoteValue(rsUsers.value("person_id"))%>')" style="color:black">Change</a>
										</td>
										<td align="left">
											<%if(parseNull(rsUsers.value("auth")).equals("0")){%>
												<button class="btn btn-success" type="button" title="Enable Auth" id ='SetEmailBtn<%=rowsNum%>' onclick="setForEmail('<%=escapeCoteValue(usernameTemp)%>','SetEmailBtn<%=rowsNum%>')">
													<i class="fa fa-lock"></i>
												</button>
											<%}else{%>
												<button class="btn btn-success" type="button" title="Email QR code" id ='SetEmailBtn<%=rowsNum%>' onclick="setForEmail('<%=escapeCoteValue(usernameTemp)%>','SetEmailBtn<%=rowsNum%>')">
													<i class="fa fa-envelope"></i>
												</button>
												<button class="btn btn-dark" type="button" title="Disable Auth" id ='UnSetEmailBtn<%=rowsNum%>' onclick="unSetForEmail('<%=escapeCoteValue(usernameTemp)%>','UnSetEmailBtn<%=rowsNum%>')">
													<i class="fa fa-unlock"></i>
												</button>
											<%}%>
										</td>
										<td align="left">
											<span id="userErr_<%=rowsNum%>" style="font-size:9pt;color:red">&nbsp;</span>
										</td>
									</tr>
									<input class="form-control" type="hidden" name="siteid" id="upd_siteid_<%=rowsNum%>" value="" />
								</tbody>
									<input type="hidden" id="person_id_<%=rowsNum%>" name="personid" value="<%=escapeCoteValue(rsUsers.value("person_id"))%>"	/>
									<input type="hidden" name="profile" id="upd_profile_<%=rowsNum%>" value="" />
									<input type="hidden" id="username_<%=rowsNum%>" name="username" value="<%=escapeCoteValue(rsUsers.value("username"))%>"	/>
									<script>
										var dataarray = new Array();
										<%  
										Set rs1 = Etn.execute("select pp.profil_id from profilperson pp where pp.person_id = "+escape.cote(rsUsers.value("person_id")));
										while(rs1.next())
										{
										%>
											dataarray.push('<%=escapeCoteValue(rs1.value("profil_id"))%>');
										<%}%>

										jQuery("#upd_select_profile_<%=rowsNum%>").val(dataarray);
									</script>
									<%
									rowsNum ++;
									}
									%>
							</table>
							<% if(rowsNum > 0) { %>
								<div class="row mb-2">
									<div class="col-sm-12 text-center">
										<div role="group" aria-label="controls">
											<button type="button" class="btn btn-success" name="Save" onclick="onUpdateUsers()" >Save</button>
										</div>
									</div>
								</div>
							<% } %>
						</form>
              		</div>
            	</div>
          	</div>
		</main>
    </div>
    <%@ include file="../WEB-INF/include/footer.jsp" %>
</div>
</body>

<!-- Modal -->
<div class="modal fade" id="dialogWindow" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Change Password</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
      </div>
	  <div class="modal-footer">
      </div>
    </div>
  </div>
</div>


<script type="text/javascript">

	changeProfile=function (obj, typ, i)
	{
		var obj2 = "#spannewsiteid_" + i;
		if("old" == typ)
		{
			obj2 = "#spanupdsiteid_" + i;
		}
		var val = $(obj).val();

		<% for(String spr : assignSiteProfils) { %>
			if(val == '<%=escapeCoteValue(spr)%>')
			{
				$(obj2).fadeIn();
				return;
			}
		<% } %>
		$(obj2).fadeOut();
	}

	setForEmail=function(usernameTemp,btnId){
		$('#'+btnId)[0].className='btn btn-secondary';
		$.ajax({
			url: '<%=request.getContextPath()%>'+"/admin/setSecretKey.jsp", 
			method:'post',
			data:{
				"username":usernameTemp,
				"action":"set"
			},
			success: function(result){
				let resp = JSON.parse(result);
				if(resp.status==0){
					alert("2FA is enabled and an email is sent.");
					window.location.href = "<%=request.getContextPath()%>/admin/userManagement.jsp";
				}else{
					alert(resp.message);
				}
			}
		});
	}
	unSetForEmail=function(usernameTemp,btnId){
		$('#'+btnId)[0].className='btn btn-secondary';
		$.ajax({
			url: '<%=request.getContextPath()%>'+"/admin/setSecretKey.jsp", 
			method:'post',
			data:{
				"username":usernameTemp,
				"action":"unset"
			},
			success: function(result){
				let resp = JSON.parse(result);
				if(resp.status==0){
					alert("2FA is disabled");
					window.location.href = "<%=request.getContextPath()%>/admin/userManagement.jsp";
				}else{
					alert(resp.message);
				}
			}
		});
	}

	function resetPassword(pid)
	{
		$("#dialogWindow").find(".modal-body").html("<div class='input-group' ><div class='form-group w-100'><label for='newPassword'>New Password</label><input type='password' value='' placeholder='New Password' class='form-control' id='newPassword' maxlength='50' size='30' /></div></div>");
		$("#dialogWindow").find(".modal-footer").html("<input type='button' class='btn btn-primary' value='OK' onclick='saveNewPassword(\""+pid+"\")' /> <input type='button' class='btn btn-danger' value='Close' data-dismiss='modal' />");
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


	function saveNewPassword(pid)
	{
		if(document.getElementById('newPassword'))
		{
			if(document.getElementById('newPassword').value == '') alert('Enter password');
			else
			{
				jQuery.ajax({
					url: 'updatePassword.jsp',
					data: {pid : pid, password : document.getElementById('newPassword').value},
					type: 'POST',
					dataType: 'json',
					async: false,
					success : function(json) {
						if(json.STATUS == "ERROR")
						{
							alert("There was some error while updating password");
							jQuery("#dialogWindow").modal('hide');
						}
                        else if(json.STATUS == "INVALID"){
                            alert("Password must be at least 12 characters long with one uppercase letter, one lowercase letter, one number and one special character. Special characters allowed are !@#$%^&*");
                        }
						else
						{
							alert("Password changed successfully");
							jQuery("#dialogWindow").modal('hide');
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
			var _profil = "";
			jQuery('#upd_select_profile_0 :selected').each(function(i, selected){
				if(jQuery(selected).val() != "#") _profil = _profil + jQuery(selected).val() + ",";
			});
			if(_profil == "")
			{
				jQuery("#userErr_0").html("Required fields are missing");
				return;
			}
			else _profil = _profil.substring(0, _profil.length - 1);
			jQuery("#upd_profile__0").val(_profil);

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
				}
				else
				{
                    if($('#email_'+i).val().trim() != ""){
                        if(!ValidateEmail($('#email_'+i).val().trim())){
                            $("#userErr_"+i).html("Email is not valid");
                            isError = 1;
                        }
                    }
                    if(isError != 1){
                        var _profil = "";
                        jQuery('#upd_select_profile_'+i+' :selected').each(function(i, selected){
                            if(jQuery(selected).val() != "#") _profil = _profil + jQuery(selected).val() + ",";
                        });
                        if(_profil == "")
                        {
                            jQuery("#userErr_"+i).html("Required fields are missing");
                            isError = 1;
                        }
                        else _profil = _profil.substring(0, _profil.length - 1);
                        jQuery("#upd_profile_"+i).val(_profil);
						

						var _siteid = "";
						jQuery('#select_updsite_'+i+' :selected').each(function(i, selected){
							if(jQuery(selected).val() != "#") _siteid = _siteid + jQuery(selected).val() + ",";
						});
						if(_siteid != "") _siteid = _siteid.substring(0, _siteid.length - 1);
						jQuery("#upd_siteid_"+i).val(_siteid);
                    }
				}
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
			var rowError = 0;
			jQuery("#new_colErr_"+i).html("&nbsp;");
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
				if(!rowError)//check any profil is selected
				{
					var _profil = "";
					jQuery('#select_profile_'+i+' :selected').each(function(i, selected){
						if(jQuery(selected).val() != "#") _profil = _profil + jQuery(selected).val() + ",";
					});
					if(_profil == "")
					{
						isError = 1;
						rowError = 1;
					}
					else _profil = _profil.substring(0, _profil.length - 1);
					jQuery("#new_profile_"+i).val(_profil);

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

		$.ajax({
			url : 'savenewuser.jsp',
			type: 'post',
			data: $('#newUserFrm').serialize(),
			dataType: 'json',
			success : function(json)
			{
				if(json.status == "error")
					jQuery("#new_colErr_"+json.errorline).html(json.message);
				else
					document.newUserFrm.submit();
			},
			error : function(res, err)
			{
				alert(err);
			}
		});
	}
</script>

</html>
