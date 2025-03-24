<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.ArrayList"%>

<%@ include file="../common.jsp" %>

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
	
	if(save.equals("1") && profils != null)
	{
		for(int i=0; i<profils.length;i++)
		{
			if(profils[i].trim().length() >0)
			{
				Etn.executeCmd("insert into profil (profil, description, assign_site) values ("+escape.cote(profils[i])+","+escape.cote(descriptions[i])+", 1)");
			}
		}
		successMessage = "Profils added successfully!!!";
	}
	
	if(update.equals("1") && profils != null)
	{
		for(int i=0; i<profilids.length;i++)
		{
			Etn.executeCmd("update profil set profil = "+escape.cote(profils[i])+", description = "+escape.cote(descriptions[i])+" where profil_id = "+escape.cote(profilids[i])+" "); 

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
				
				Set rsUsers = Etn.execute("select * from profilperson where profil_id = "+escape.cote(deleteProfils[i]));
				if(rsUsers.rs.Rows > 0) errorMessage = "Some of the profils have users defined so cannot be deleted";
				else 
				{
					Etn.executeCmd("delete from profil where profil_id = "+escape.cote(deleteProfils[i]));			
					Etn.executeCmd("delete from page_profil where profil_id = "+escape.cote(deleteProfils[i]));			
				}
			}
		}
		successMessage = "Profils updated/deleted successfully!!!";
	}
	
	Set rsProfil = Etn.execute("select * from profil order by profil");
	Set rsPages = Etn.execute("select *, case coalesce(parent,'') when '' then name else concat(parent,' -> ',name) end as pagename from page order by parent, rang");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Profil Management</title>
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap-notify.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
			 document.querySelectorAll('.c-sidebar-nav-link').forEach((node)=>{
            if(node.href === window.location.origin+window.location.pathname) {
                node.classList.add('c-active');
                node.parentNode.parentNode.parentNode.classList.add('c-show');
            }
        	});
        });
    </script>

<script>
	function resetPassword(username)
	{
		$("#dialogWindow").find(".modal-body").html("<div class='input-group' ><div class='form-group w-100'><label for='newPassword'>New Password</label><input type='password' value='' placeholder='New Password' class='form-control' id='newPassword' maxlength='50' size='30' /></div></div>");
		$("#dialogWindow").find(".modal-footer").html("<input type='button' class='btn btn-primary' value='OK' onclick='saveNewPassword(\""+username+"\")' /> <input type='button' class='btn btn-danger' value='Close' data-dismiss='modal' />");
		$("#dialogWindow").modal('show');
	}
	
	//this function decodes the spanish accents to be shown properly in javascript alerts
	function html_entity_decode(str) 
	{  
		var ta=document.createElement("textarea");  
		ta.innerHTML=str.replace(/</g,"<").replace(/>/g,">");  
		return ta.value;  
	}  
	
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
				alert($("._"+_profid));
				$("._"+_profid).each(function(){
					if($(this).attr("checked")) _selectedUrls += this.value + ",";
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
						if (jQuery(this).is(":checked")) _selectedUrls += this.value + ",";
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
						jQuery("#new_colErr_"+i).html("Profil already exists in the list");
						break;
					}
				}
				
				$(".oldProfil").each(function(){
					if(jQuery('#new_profil_'+i).val() == this.value)
					{
						isError = 1;
						rowError = 1;
						jQuery("#new_colErr_"+i).html("Profil already in use");
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
			console.log(profilId);
             $.ajax({
                    type: "POST",
                    url: "calls/manupulateProfil.jsp",
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
		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<h1 class="h2">Profil Management</h1>
		</div>
        <div class="animated fadeIn">
            <div class="card">
              <div class="card-body">
                  <form name="myForm" action="manageProfil.jsp" method="post" class="form-horizontal" role="form">			        
                      <input type="hidden" name="save" value="1"/>            
                      <div class="row">
                          <div class="col-md-4">
                              <div class="form-group">						
                                  <label for="profil" class="control-label">Profil<span style="color:red">*</span></label>
                                  <div>
                                      <% for (int i=0;i<3;i++) { %>			
                                      <input type="text" id="new_profil_<%=i%>" name="profil" size="10" class="form-control" placeholder="" value="">
                                      <br/>
                                      <% } %>
                                  </div>
                              </div>
                          </div>
                          <div class="col-md-4 offset-md-2">
                              <div class="form-group">

                                  <label for="profil" class="control-label">Description<span style="color:red">*</span></label>
                                  <div>
                                      <% for (int i=0;i<3;i++) { %>			
                                      <input type="text" id="new_profildesc_<%=i%>" name="profildesc" size="10" class="form-control" placeholder="" value="">
                                      <br/>
                                      <% } %>
                                  </div>
                              </div>

                          </div>
                          <div class="col-xs-1 col-sm-2">
                              <div class="form-group">
                                  <div class="col-sm-9">
                                      <% for (int i=0;i<3;i++) { %>			
                                      <span id="new_colErr_<%=i%>" style="font-size:9pt;color:red">&nbsp;</span>
                                      <br/>
                                      <% } %>
                                  </div>
                              </div>
                          </div>
                      </div>
                      <div class="row">
                          <div class="col-sm-12 text-center">
                              <div class="" role="group" aria-label="controls">
                                  <button type="button" class="btn btn-success" name="Search" onclick="onSave()" >Save Profil(s)</button>
                              </div>
                          </div>
                      </div>
                  </form>
              </div>
            </div>
            <div class="card">	
              <div class="card-body p-0 pb-3">		
		<form name="updateFrm" action="manageProfil.jsp" method="post" class="form-horizontal" role="form">

			<input type="hidden" name="update" value="1"/>	

			<table class="table table-responsive-sm resultat table-hover table-striped">
	
				<thead> 
					<th >Profil<span style="color:red">*</span></th>
					<th >Description<span style="color:red">*</span></th>
					<th >Menu</th>
					<th >Delete</th>
					<th >&nbsp;</th>
				</thead>

				<%	int rowsNum = 0;
				    while(rsProfil.next()){
					String readonly = "";
					if(specialProfils.contains(rsProfil.value("profil").toUpperCase())) readonly = "readonly";
				%>
					<tr>
						<td align="left">
							<input type="text" id="profil_<%=rowsNum%>" name="profil" size="10" class="hasDatepicker form-control" placeholder="" value='<%=rsProfil.value("profil")%>' <%=readonly%>>
						</td>
						<td align="left">
							<input type="text" id="profildesc_<%=rowsNum%>" name="profildesc" size="10" class="hasDatepicker form-control" placeholder="" value='<%=rsProfil.value("description")%>'>
						</td>
						<td align="left">
							<%	
								if(!specialProfils.contains(rsProfil.value("profil").toUpperCase())) {
									rsPages.moveFirst(); 
									while(rsPages.next()) {	
										Set rsPageProfil = Etn.execute("select * from page_profil where url = "+escape.cote(rsPages.value("url"))+" and profil_id = "+escape.cote(rsProfil.value("profil_id")));
										String checked = "";
										if(rsPageProfil.rs.Rows > 0) checked = "checked";									
							%>
										<input class="_<%=rsProfil.value("profil_id")%>" type='checkbox' <%=checked%> value='<%=rsPages.value("url")%>' />&nbsp;<%=rsPages.value("pagename")%><br/>
							<% 
									}
								} %>
						</td>
						<td align="center" id="activeChkBoxCol_<%=rowsNum%>">
    						<a href="javascript:void(0)" onclick="deleteProfilFun(this)" id="isDelete_<%=rowsNum%>" name="deleteProfil" value="<%=rsProfil.value("profil_id")%>" class="btn btn-danger btn-sm">Delete</a>

						</td>
						<td align="left"><span id="profilErr_<%=rowsNum%>" style="font-size:9pt;color:red">&nbsp;</span></td>
					</tr>
					<input type='hidden' name='profilid' value='<%=rsProfil.value("profil_id")%>' />
					<input type='hidden' name='selectedUrls' id="<%=rsProfil.value("profil_id")%>_urls" value=''/>
				<%	
					rowsNum ++;
					}%>


			</table>

			<% if(rowsNum > 0) { %>
		            <div class="row">
		                <div class="col-sm-12 text-center">
		                    <div class="" role="group" aria-label="controls">
								<button type="button" class="btn btn-success" name="Search" onclick="onUpdate()" >Save</button>
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
</body>

    <script type="text/javascript">
		jQuery(document).ready(function() {
			$(".newProfil").keydown(function(e){
				return e.which !== 32;
			});
		});
    </script> 

</html>
