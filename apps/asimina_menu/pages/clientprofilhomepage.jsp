<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="common.jsp"%>


<%
	String siteid = parseNull(getSiteId(request.getSession()));
	
	String formId = "";
	Set rs = Etn.execute("select p.* from "+GlobalParm.getParm("FORMS_DB")+".process_forms p where p.`type` = 'sign_up' and p.site_id = "+escape.cote(siteid));
	if(rs.next()) formId = parseNull(rs.value("form_id"));
	
	if(formId.length() > 0)
	{		
		response.sendRedirect(GlobalParm.getParm("EXTERNAL_FORMS_LINK") + "admin/search.jsp?___fid=" + formId);
		return;
	}	

	String isprod = parseNull(request.getParameter("isprod"));
	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";

       String id = parseNull(request.getParameter("id"));
       String name = parseNull(request.getParameter("name"));
       String surname = parseNull(request.getParameter("surname"));
       String email = parseNull(request.getParameter("email"));
       String password = parseNull(request.getParameter("password"));
       String profil = parseNull(request.getParameter("profil"));
       String verified = parseNull(request.getParameter("verified"));

	if(!id.equals(""))
	{
		String newPassword = "";
		if(!password.equals("")) newPassword = ", pass = sha2(concat("+escape.cote(GlobalParm.getParm("CLIENT_PASS_SALT"))+",'#',"+escape.cote(password)+",'#', client_uuid), 256) ";
            
       	if(!email.equals("")) Etn.executeCmd("update " +dbname+ "clients set is_verified = "+escape.cote(verified)+", email="+escape.cote(email) + ", name=" + escape.cote(name) + ", surname=" + escape.cote(surname) + ", client_profil_id=" + escape.cote(profil) + newPassword + " where id="+escape.cote(id));
	}
	else if(!password.equals("") && !email.equals(""))
	{
		String clientuuid = java.util.UUID.randomUUID().toString();
		Etn.executeCmd("insert into " +dbname+ "clients set username = "+escape.cote(email)+", site_id = "+escape.cote(siteid)+", is_verified = "+escape.cote(verified)+", client_uuid = "+escape.cote(clientuuid)+", email="+escape.cote(email) + ", name=" + escape.cote(name) + ", surname=" + escape.cote(surname) + ", pass = sha2(concat("+escape.cote(GlobalParm.getParm("CLIENT_PASS_SALT"))+",'#',"+escape.cote(password)+",'#',"+escape.cote(clientuuid)+"), 256) ");
	}

       Set rsClients = Etn.execute("select c.*, ph.profil as profilName from " +dbname+ "clients c left join " +dbname+ "client_profils ph on c.client_profil_id = ph.id where c.site_id = "+escape.cote(siteid)+" order by c.id");
        
       Set rsProfils = Etn.execute("select * from " +dbname+ "client_profils where site_id = " + escape.cote(siteid));
        
%>

<html>
<head>
	<title>Client Management</title>

<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"System", ""});
if("1".equals(isprod)) breadcrumbs.add(new String[]{"Production", ""});
else breadcrumbs.add(new String[]{"Preprod", ""});
breadcrumbs.add(new String[]{"Clients", ""});
%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
<%@ include file="/WEB-INF/include/header.jsp" %>
<main class="c-main" style="padding:0px 30px">
	<!-- breadcrumb -->
	<!-- /breadcrumb -->
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div style="width: 100%;">
				<h1 class="h2 float-left">Clients - <% if("1".equals(isprod)) { %>Production
					<% } else { %>Preprod<%}%></h1>
				<p class="lead"></p>
			</div>
	</div><!-- /d-flex -->
	<!-- /title -->
		<!-- container -->
	<div>
	<div class="animated fadeIn">
	<style>
		#mainTable.table-fixed th{
			width:20%;
		}
	</style>
	<form name='frm' id='frm' action='<%=("1".equals(isprod)?"prodclientprofilhomepage.jsp":"clientprofilhomepage.jsp")%>' method='post' >
		<table id="mainTable" class="table table-fixed table-hover table-vam m-t-20" style="margin-bottom:0;">
			<thead class="thead-dark">
                        <tr>
                                <th>Email</th>
                                <th>Name</th>
                                <th>Surname</th>
                                <th>Profil</th>
                                <th style='width:5% !important'>Activated?</th>
                                <th>Password</th>
                        </tr>
			</thead>
                        <tr>
                            <td>
                                <input type="hidden" name="id" id="edit_id" />
                                <input type='text' size='50' name='email' id="edit_email" class="form-control"/>
                            </td>
                            <td><input type='text' size='50' name='name' id="edit_name" class="form-control"/></td>
                            <td><input type='text' size='50' name='surname' id="edit_surname" class="form-control"/></td>
                            <td>
                                <select name="profil" id="edit_profil" class="form-control">
                                    <option></option>                                    
                                <%
                                while(rsProfils.next()){
                                %>
                                    <option value="<%=rsProfils.value("id")%>"><%=rsProfils.value("profil")%></option>
                                <%}%>
                                </select>
                            </td>
                            <td>
					<select id='edit_verified' name='verified' class='form-control'>
						<option value='1'>Yes</option>
						<option value='0'>No</option>
					</select>
				</td>
                            <td>
                                <button class="btn btn-secondary btn-block" id="changePasswordBtn" type="button" style="display:none">Change Password</button>
                                <input type='password' size='50' name='password' id="edit_password" class="form-control" /></td>
			</tr>
		</table>
                                <button type="button" class="btn btn-success float-right" style="margin-bottom: 30px;" onclick="onSave();">Save</button>
	</form>
		<table id="mainTable" cellpadding=0 cellspacing=0 border=0 width='50%' class="table table-hover table-vam m-t-20">
			<thead class="thead-dark">
                        <tr>
                                <th>Email</th>
                                <th>Name</th>
                                <th>Surname</th>
                                <th>Profil</th>
                                <th width='5%'>Activated?</th>
                                <th>Last Login</th>
                                <th>Edit</th>
                        </tr>
			</thead>
                    <%
                    while(rsClients.next()){
                    %>
			<tr>
                            <td><input type='text' size='50' id='email_<%=rsClients.value("id")%>' value="<%=rsClients.value("email")%>" readonly class="form-control"/></td>
                            <td><input type='text' size='50' id='name_<%=rsClients.value("id")%>' value="<%=rsClients.value("name")%>" readonly class="form-control"/></td>
                            <td><input type='text' size='50' id='surname_<%=rsClients.value("id")%>' value="<%=rsClients.value("surname")%>" readonly class="form-control"/></td>
                            <td>
                                <input type='hidden' id='profil_<%=rsClients.value("id")%>' value="<%=rsClients.value("client_profil_id")%>"/>
                                <input type='text' size='50' value="<%=rsClients.value("profilName")%>" readonly class="form-control"/>
                            </td>
                            <td>
                                	<input type='hidden' id='verified_<%=rsClients.value("id")%>' value="<%=rsClients.value("is_verified")%>"/>
					<input type='text' size='4' value='<% if("1".equals(rsClients.value("is_verified")) ) { out.write("Yes"); } else { out.write("No"); } %>' id='verified' readonly class='form-control'>
				</td>
				<td>
					<%=parseNull(rsClients.value("last_login_on")) %>
				</td>
                            <td><button class="btn btn-default edit-btn" onclick="editClient(<%=rsClients.value("id")%>)"></button></td>
			</tr>
                    <%
                    }
                    %>
		</table>
	</form>
	</div>	
	</div><!-- /container -->
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>
<script>
    function editClient(id){
        $("#edit_id").val(id);
        $("#edit_email").val($("#email_"+id).val());
        $("#edit_name").val($("#name_"+id).val());
        $("#edit_surname").val($("#surname_"+id).val());
        $("#edit_profil").val($("#profil_"+id).val());
	 $("#edit_verified").val($("#verified_"+id).val());

        $('#edit_password').hide('fast');
        $('#changePasswordBtn').show('fast');
    }
    
    function onSave(){
        if($("#edit_email").val()==""){
            alert("Email is mandatory");
            return;
        }
        
        if($("#edit_id").val()=="" && $("#edit_password").val()==""){
            alert("Password is mandatory");
            return;
        }
        
        $("#frm").submit();
    }
    
    jQuery(document).ready(function() {
        $(".edit-btn").html(feather.icons['edit'].toSvg());
        $('#changePasswordBtn').click(function(){
            $(this).hide('fast');
            $('#edit_password').show('fast');
        })
    });
</script>
</html>