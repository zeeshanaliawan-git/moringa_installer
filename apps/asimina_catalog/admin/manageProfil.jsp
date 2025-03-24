<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.ArrayList, com.etn.asimina.util.ActivityLog"%>

<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%
	String save = parseNull(request.getParameter("save"));
	if(save.equals("")) save = "0";
	String update = parseNull(request.getParameter("update"));
	if(update.equals("")) update = "0";
	String[] profils = request.getParameterValues("profil");
	String[] descriptions = request.getParameterValues("profildesc");
	String[] deleteProfils = request.getParameterValues("deleteProfil");
	String[] profilids = request.getParameterValues("profilid");
	String[] selectedUrls = request.getParameterValues("selectedUrls");
	String[] is_webmaster = request.getParameterValues("is_webmaster");
	String successMessage = "";
	String errorMessage = "";

	ArrayList<String> specialProfils = new ArrayList<String>();
	specialProfils.add("ADMIN");
	specialProfils.add("WEB_SERV");
	specialProfils.add("TEST_SITE_ACCESS");
	specialProfils.add("PROD_SITE_ACCESS");
	specialProfils.add("PROD_CACHE_MGMT");
	specialProfils.add("PROD_PUBLISH");
	specialProfils.add("SUPER_ADMIN");
	specialProfils.add("SITE_ACCESS");

	ArrayList<String> nodelete = new ArrayList<String>();
	nodelete.add("MP_SHOP_ADMINS");
	nodelete.add("MP_SHOP_ADMINS_ADVANCE");

	if(save.equals("1") && profils != null)
	{
        String ids = "";
        String names = "";
		for(int i=0; i<profils.length;i++)
		{
			if(profils[i].trim().length() >0)
			{
				int _id = Etn.executeCmd("insert into profil (profil, description, assign_site) values ("+escape.cote(profils[i])+","+escape.cote(descriptions[i])+", 1)");
                if(ids.length()>0) ids += ",";
                if(names.length()>0) names += ", ";
                ids += _id;
                names += profils[i];


			}
		}
		successMessage = "Profiles added successfully!!!";
        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),ids,"CREATED","Profiles",names,parseNull(getSelectedSiteId(session)));
	}

	if(update.equals("1") && profils != null)
	{
		for(int i=0; i<profilids.length;i++)
		{
			String isWebmaster = parseNull(is_webmaster[i]);
			if(isWebmaster.length() == 0) isWebmaster = "1";
			
			if(specialProfils.contains(profils[i].toUpperCase())) isWebmaster = "0";//always 0 for special profiles
			
			Etn.executeCmd("update profil set profil = "+escape.cote(profils[i])+", description = "+escape.cote(descriptions[i])+", is_webmaster = "+escape.cote(isWebmaster)+" where profil_id = "+escape.cote(profilids[i])+" ");

			if(!specialProfils.contains(profils[i].toUpperCase()))
			{
				Etn.executeCmd("delete from page_profil where profil_id = "+escape.cote(profilids[i])+" ");
				String[] _urls = selectedUrls[i].split(",");

				for(String u : _urls)
				{
					if(!u.trim().equals("")) Etn.execute("insert into page_profil (url, profil_id) values ("+escape.cote(u)+","+escape.cote(profilids[i])+" )");
				}
			}
		}

		if(deleteProfils != null)
		{

			for(int i=0; i<deleteProfils.length;i++)
			{
				if(!nodelete.contains(profils[i].toUpperCase()))
				{
					Set rsUsers = Etn.execute("select * from profilperson where profil_id = "+escape.cote(deleteProfils[i]));
					if(rsUsers.rs.Rows > 0) errorMessage = "Some of the profiles have users defined so cannot be deleted";
					else
					{
						Etn.executeCmd("delete from profil where profil_id = "+escape.cote(deleteProfils[i]));
						Etn.executeCmd("delete from page_profil where profil_id = "+escape.cote(deleteProfils[i]));
					}
				}
			}
		}
		successMessage = "Profiles updated/deleted successfully!!!";
        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"","UPDATED","Profiles","",parseNull(getSelectedSiteId(session)));
	}


	Set rsProfil = Etn.execute("select * from profil order by profil");
	Set rsPages = Etn.execute(" select url, parent, rang, case coalesce(parent,'') when '' then name else concat(parent,' -> ',name) end as pagename from page union select '"+com.etn.beans.app.GlobalParm.getParm("PAGES_APP_URL")+"admin/mediaLibrary.jsp', 'zzzzz' as parent, 1000 as rang, 'Media Library'   order by parent, rang ");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>
<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Profiles", ""});
%>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Profiles</title>

<script src="<%=request.getContextPath()%>/js/bootstrap-notify.min.js"></script>


<script>
	function onUpdate()
	{
		$("#_msg").html("");
		if (document.updateFrm.profil.length == undefined)
		{
			jQuery("#profilErr_0").html("&nbsp;");
			if(document.updateFrm.profil.value == '' || document.updateFrm.profildesc.value == '')
			{
				jQuery("#profilErr_0").html("Required fields are missing");
				return;
			}
			else
			{
				var _profid = document.updateFrm.profilid.value;
				var _selectedUrls = "";
				$("._"+_profid).each(function(){
					if($(this).prop("checked")) _selectedUrls += this.value + ",";
				});
				document.updateFrm.selectedUrls.value = _selectedUrls;
			}

			document.updateFrm.submit();
		}
		else
		{
			var isError = 0;
			for(var i=0;i<document.updateFrm.profil.length;i++)
			{
				jQuery("#profilErr_"+i).html("&nbsp;");
				if(document.updateFrm.profil[i].value == '' || document.updateFrm.profildesc[i].value == '')
				{
					jQuery("#profilErr_"+i).html("Required fields are missing");
					isError = 1;
				}
				else
				{
					var _profid = document.updateFrm.profilid[i].value;
					var _selectedUrls = "";
					$("._"+_profid).each(function(){
						if($(this).prop("checked")) _selectedUrls += this.value + ",";
					});
					document.updateFrm.selectedUrls[i].value = _selectedUrls;
				}
			}
			if(!isError) document.updateFrm.submit();
		}
	}
	function onSave()
	{
		$("#_msg").html("");
		var isError = 0;
		var anythingToSave = 0;
		for(var i=0; i<3; i++)
		{
			jQuery("#new_colErr_"+i).html("&nbsp;");
			var rowError = 0;
			if(jQuery('#new_profil_'+i).val() != '' ||  jQuery('#new_profildesc_'+i).val() != '')
			{
				anythingToSave = 1;
				if(jQuery('#new_profil_'+i).val() == '')
				{
					isError = 1;
					rowError = 1;
				}
				else if(jQuery('#new_profildesc_'+i).val() == '')
				{
					isError = 1;
					rowError = 1;
				}
				if(rowError) jQuery("#new_colErr_"+i).html("Required fields are missing");
			}
		}
		if (isError) return;
		if(!anythingToSave) return;

		for(var i=0; i<3; i++)
		{
			var rowError = 0;
			if(jQuery('#new_profil_'+i).val() != '')
			{
				for(var j=0; j<3; j++)
				{
					if(jQuery('#new_profil_'+j).val() != '' && jQuery('#new_profil_'+j).val() == jQuery('#new_profil_'+i).val() && i!=j)
					{
						isError = 1;
						rowError = 1;
						jQuery("#new_colErr_"+i).html("Profile already exists in the list");
						break;
					}
				}

				$(".oldProfil").each(function(){
					if(jQuery('#new_profil_'+i).val() == this.value)
					{
						isError = 1;
						rowError = 1;
						jQuery("#new_colErr_"+i).html("Profile already in use");
						return;
					}
				});

			}
		}

		if(isError) return;

		document.myForm.submit();

	}

	function bootNotifyError(msg){
			bootNotify(msg, "danger");
		}
		
		function bootNotify(msg, type) {
		
			if (typeof type == 'undefined') {
				type = "success";
			}
			var settings = {
				type: type,
				delay: 2000,
				placement: {
					from: "top",
					align: "center"
				},
				offset : {
					y : 10,
				},
				z_index : 1500,//to show above bootstrap modal
			};
		
			jQuery.notify(msg, settings);
		}
		function deleteProfilFun(element){
            let canDelete = confirm("Are you sure to delete?");
            if(!canDelete) return;
			let profilId = $(element).attr("value");
             $.ajax({
                    type: "POST",
                    url: "catalogs/ajax/manageProfilAjax.jsp",
                    data: {
                        requestType: "deleteProfil",
                        profil : $(element).closest("tr").find("input").first().val(),
						deleteProfils : profilId
                    },
                    success: function(resp){ 
                        if(resp.status == 0 ){
							 bootNotify(resp.message);
                            window.location=window.location;
                        }else
                            bootNotifyError(resp.message);
                    },
                    error:function (){ 
                        bootNotifyError("error");
                    }  

            });          
        }



</script>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">Profiles<h1>
				<p class="lead"></p>
			</div>
			<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Profiles');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>

		</div>
	<!-- /title -->

	<!-- container -->
	<div class="animated fadeIn">
	<form name="myForm" action="manageProfil.jsp" method="post">
		<input type="hidden" name="save" value="1"/>

		<table class="table table-hover table-bordered results" cellpadding="0" cellspacing="0" border="0" id="newProfilTbl">
		<thead class="thead-dark">
			<tr>
				<th>Profile<span style="color:red">*</span></th>
				<th>Description<span style="color:red">*</span></th>
				<th width="25%">&nbsp;</th>
			</tr>
		</thead>
		<% for (int i=0;i<3;i++) { %>
			<tr>
				<td><input type='text' class='newProfil form-control' maxlength='50' size='30' id='new_profil_<%=i%>' name='profil' value='' /></td>
				<td><input type='text' maxlength='50' size='35' id='new_profildesc_<%=i%>' name='profildesc' value='' class="form-control"/></td>
				<td><span id="new_colErr_<%=i%>" style="font-size:9pt;color:red">&nbsp;</span></td>
			</tr>
		<% } %>
		</table>
		<div style='margin-top:5px; text-align:center'><input type='button' value='Save Profil(s)' onclick="onSave()" class="btn btn-primary"/></div>
		<br>
	</form>
	<form name="updateFrm" action="manageProfil.jsp" method="post">
	<input type="hidden" name="update" value="1"/>
	<table cellspacing="0" cellpadding="1" border="0" id="usersTbl" width="95%" class="table table-hover table-bordered results" >
		<%
			if(!successMessage.equals("")){
		%>
			<tr>
				<td colspan="7" style="color:green; font-weight:bold"><span id='_msg'><%=escapeCoteValue(successMessage)%></span></td>
			</tr>
		<%}%>
		<thead class="thead-dark">
			<tr>
				<th width="15%">Profile<span style="color:red">*</span></th>
				<th width="15%">Is Webmaster?<span style="color:red">*</span></th>
				<th width="15%">Description<span style="color:red">*</span></th>
				<th>Menu</th>
				<th width="5%">Delete</th>
				<th width="20%" width="30%">&nbsp;</th>
			</tr>
		</thead>
		<%	int rowsNum = 0;
		    while(rsProfil.next()){
			String readonly = "";
			boolean isSpecial = false;
			if(specialProfils.contains(rsProfil.value("profil").toUpperCase())) 
			{
				readonly = "readonly";
				isSpecial = true;
			}
		%>
			<tr>
				<td align="left"><input <%=readonly%> class='oldProfil form-control' type='text' maxlength='50' size='35' id='profil_<%=rowsNum%>' name='profil' value='<%=escapeCoteValue(rsProfil.value("profil"))%>' /></td>
				
				<td align="left">
					<%if(isSpecial){%>
						<input type='hidden' name='is_webmaster' value='0'>
					<%}else{%>
					<select class="form-control" name="is_webmaster" >
						<option value="0">No</option>
						<option <%=("1".equals(rsProfil.value("is_webmaster"))?"selected":"")%> value="1">Yes</option>
					</select>
					<%}%>
				</td>
				
				<td align="left"><input type='text' maxlength='50' size='35' id='profildesc_<%=rowsNum%>' name='profildesc' value='<%=escapeCoteValue(rsProfil.value("description"))%>' class="form-control"/></td>
				<td align="left">
					<%
						if(!specialProfils.contains(rsProfil.value("profil").toUpperCase())) {
							rsPages.moveFirst();
							while(rsPages.next()) {
								Set rsPageProfil = Etn.execute("select * from page_profil where url = "+escape.cote(rsPages.value("url"))+" and profil_id = "+escape.cote(rsProfil.value("profil_id")));
								String checked = "";
								if(rsPageProfil.rs.Rows > 0) checked = "checked";
					%>
								<input class="_<%=rsProfil.value("profil_id")%>" type='checkbox' <%=checked%> value='<%=escapeCoteValue(rsPages.value("url"))%>' />&nbsp;<%=escapeCoteValue(rsPages.value("pagename"))%><br/>
					<%
							}
						} %>
				</td>
				<td align="center" id="activeChkBoxCol_<%=rowsNum%>"><% if(!specialProfils.contains(rsProfil.value("profil").toUpperCase()) && !nodelete.contains(rsProfil.value("profil").toUpperCase())) { %><a href="javascript:void(0)" onclick="deleteProfilFun(this)" id="isDelete_<%=rowsNum%>" name="deleteProfil" value="<%=rsProfil.value("profil_id")%>">Delete</a><% } %></td>
				<td align="left"><span id="profilErr_<%=rowsNum%>" style="font-size:9pt;color:red">&nbsp;</span></td>
			</tr>
			<input type='hidden' name='profilid' value='<%=escapeCoteValue(rsProfil.value("profil_id"))%>' />
			<input type='hidden' name='selectedUrls' id="<%=rsProfil.value("profil_id")%>_urls" value=''/>
		<%
			rowsNum ++;
			}%>
	</table>
	<% if(rowsNum > 0) { %>
		<div style='margin-top:5px; text-align:center'><input type='button' value='Save' onclick="onUpdate()" class="btn btn-primary"/></div>
	<% } %>
	<br />
	</form>
	<br>
	<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	<!-- /container -->
</main>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /c-body -->



</body>
    <script type="text/javascript">
		jQuery(document).ready(function() {
			$(".newProfil").keydown(function(e){
				return e.which !== 32;
			});
		});
    </script>

</html>

