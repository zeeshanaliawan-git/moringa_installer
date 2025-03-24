<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp" %>
<%
	String siteid = getSelectedSiteId(session);
	Set rs = Etn.execute("select id, screen_name, url, destination_page, ckeditor_page_id, json_uuid from expert_system_json where site_id = "+escape.cote(siteid)+" order by id ");
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<title>Expert System</title>

<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<%
breadcrumbs.add(new String[]{"Tools", ""});
breadcrumbs.add(new String[]{"Expert System", ""});
%>

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
					<h1 class="h2">
						List of queries
					</h1>
					<p class="lead"></p>
				</div>

				<!-- buttons bar -->
				<div class="btn-toolbar mb-2 mb-md-0">
					<div class="btn-group mr-2" role="group" aria-label="...">
						<input type='button' value='Add Screen' id='addBtn' class="btn btn-primary" />
					</div>
					<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Expert System');" title="Add to shortcuts">
						<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
					</button>
				</div>
				<!-- /buttons bar -->
			</div><!-- /d-flex -->
			<!-- /title -->

			<div class="animated fadeIn">
				<div>
					<table class="table table-bordered table-hover" cellspacing='0' cellpadding='1' border='1' width="70%">
						<tr>
							<th nowrap>Json Id</th>
							<th >Screen name</th>
							<th>Url</th>
							<th>&nbsp;</th>
							<th>&nbsp;</th>
							<!-- <th>&nbsp;</th> -->
							<th>&nbsp;</th>
							<th>&nbsp;</th>
						</tr>
						<% while(rs.next()) { %>
							<tr>
								<td><%=rs.value("json_uuid")%></td>
								<td><%=rs.value("screen_name")%></td>
								<td>
									Json Url : <%=rs.value("url")%>
									<% if(!parseNull(rs.value("destination_page")).equals("")) { %>
										<br/>
										Dest Page : <%=rs.value("destination_page")%> 
									<% } %>
								</td>
								<td><a href='rules.jsp?jsonid=<%=rs.value("id")%>'>Rules</a></td>
								<td><a href='uiScript.jsp?jsonid=<%=rs.value("id")%>&juuid=<%=rs.value("json_uuid")%>'>Ui Script</a></td>
								<!-- <td><a href='#' onclick='layoutESDesign("<%=rs.value("id")%>","<%=rs.value("ckeditor_page_id")%>")'>Layout</a></td> -->
								<td><input type='button' value='Delete' class="btn btn-danger" onclick='deleteScreen("<%=rs.value("id")%>")' /></td>
								<td><input type='button' value='Copy' class="btn btn-primary" onclick='copyScreen("<%=rs.value("id")%>")' /></td>
							</tr>
						<% } %>
					</table> 
				</div>
				<br>
				<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
			</div>
		</main>
		<%@ include file="/WEB-INF/include/footer.jsp" %>
	</div>	
<div id="dialogWindow" title="New Screen"></div>
<!-- Modal -->
<div class="modal fade" id="ckeditorModal" role="dialog">
	<div class="modal-dialog modal-lg">

	<!-- Modal content-->
	<div class="modal-content">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal">&times;</button>
			<h4 class="modal-title">Create New Blank Page</h4>
		</div>

		<div class="modal-body">
			<div role="tabpanel" class="tab-pane" id="newBlank">
				<form id="newPageForm" action="" method="POST" role="form" >
					<input type="hidden" id="ckeditor_page_id" name="ckeditor_page_id" value="" />
					<input type="hidden" id="request_type" name="type" value="new" />
					<input type="hidden" id="esjsonId" name="esjsonId" value="">
					<div style="float: right;" class="form-group">
						<a type="button" id="preview_ckeditor_page" class="btn btn-link" href="#" target="_blank" style="display: none;">Preview</a>
					</div>
					<div class="form-group">
						<p><label style="float: left;">Page Name :</label></p>
						<p><input type="text" id="urlname" name="urlname" class="form-control" placeholder=""></p>
					</div>

					<div class="row" >
						<div class="col-xs-3">
							<div class="form-group">
								<label for="columncount" class="form-label" >Select Design Layout</label>
								<select name="layout_design" id="layout_design" class="form-control">
								<option value="1">1</option>
								<option value="2">2</option>
								</select>
							</div>
						</div>
						<div id="es_selected_layout" class="col-xs-8">
							<div class="row">
								<div class="col-xs-12" style="border:1px dashed #ccc; background-color:#efefef; min-height:200px;"></div>
							</div>
							<div class="row" class="col-xs-12"> &nbsp; </div>
							<div class="row">
								<div class="col-xs-12" style="border:1px dashed #ccc; background-color:#efefef; min-height:200px;"></div>
							</div>
						</div>
					</div>
					<button id="sbmt_newPageForm" style="margin-top: 5%;" type="submit" class="btn btn-primary">Create</button>
				</form>
			</div>
		</div>
		<div class="modal-footer">
			<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		</div>
	</div>
</div>
<!-- Modal -->

    <script type="text/javascript">
		jQuery(document).ready(function() {
			$("#dialogWindow").dialog({
				bgiframe: true, autoOpen: false, height: 'auto', width:'auto', modal: true, resizable : false
			});			

			$("#layout_design").on("change", function(){

				if(this.value == "1"){

					$("#es_selected_layout").html('<div class="row"> <div class="col-xs-12" style="border:1px dashed #ccc; background-color:#efefef; min-height:200px;"></div> </div> <div class="row" class="col-xs-12"> &nbsp; </div> <div class="row"> <div class="col-xs-12" style="border:1px dashed #ccc; background-color:#efefef; min-height:200px;"></div> </div>');
				}else if(this.value = "2"){

					$("#es_selected_layout").html('<div class="row"> <div class="col-sm-5" style="border:1px dashed #ccc; background-color:#efefef; min-height:200px;"></div> <div class="col-xs-2"> &nbsp; </div> <div class="col-sm-5" style="border:1px dashed #ccc; background-color:#efefef; min-height:200px;"></div> </div> <div class="row"> <div class="row" class="col-xs-12"> &nbsp; </div> <div class="col-sm-5" style="border:1px dashed #ccc; background-color:#efefef; min-height:200px;"></div> <div class="col-xs-2"> &nbsp; </div> <div class="col-sm-5" style="border:1px dashed #ccc; background-color:#efefef; min-height:200px;"></div> </div>');
				}
			});

			$("#addBtn").click(function(){
				var h = "<table cellpadding='0' cellspacing='0' border='0' width='600px'>";
				h += "<tr><td width='20%' nowrap>Screen</td><td width='2%'>:</td><td><input type='text' id='newscreenname' value='' maxlength='30'/></td></tr>";
				h += "<tr><td nowrap>Json Url</td><td>:</td><td><input type='text' id='newurl' value='' maxlength='250' size='85'/></td></tr>";
				h += "<tr><td colspan='3' align='center'><input type='button' onclick='addNewScreen()' value='Ok'/></td></tr>";
				h += "</table>";

				$("#dialogWindow").html(h);				
				$("#dialogWindow").dialog('open');
			});

			deleteScreen=function(jsonid)
			{
				if(!confirm("Are you sure you want to continue with delete?")) return;

				$.ajax({ 
					url : 'deleteScreen.jsp',
					type: 'POST',
					data : {jsonid : jsonid},
					dataType : 'json',
					success : function(json1)
					{		 
						if(json1.RESPONSE == 'SUCCESS') window.location='screens.jsp';
						else alert("Some error occurred");
					}
				});							
			};

			copyScreen=function(fromJsonId)
			{
				var h = "<table cellpadding='0' cellspacing='0' border='0' width='300px'>";
				h += "<tr><td width='20%' nowrap>Copy to Screen</td><td width='2%'>:</td><td><input type='text' id='copytopscreenname' value='' maxlength='30'/></td></tr>";
				h += "<tr><td colspan='3' align='center'><input type='button' onclick='doCopy(\""+fromJsonId+"\")' value='Ok'/></td></tr>";
				h += "</table>";

				$("#dialogWindow").html(h);				
				$("#dialogWindow").dialog('open');
			};

			doCopy=function(fromJsonId)
			{
//				alert(fromJsonId);
				if($.trim($("#copytopscreenname").val()) == '')
				{
					alert("Provide screen name to copy settings");
					return;
				}
				$.ajax({ 
					url : 'copyScreen.jsp',
					type: 'POST',
					data : {screenname : $("#copytopscreenname").val(), fromjsonid : fromJsonId},
					dataType : 'json',
					success : function(json)
					{		
						alert(json.MSG)
						if(json.RESPONSE == 'SUCCESS') 
						{
							$("#dialogWindow").dialog('close');
							window.location='screens.jsp';	
						}
					},
					error:function()
					{
						alert("Some error while saving screen info");
					}
				});						
			};

			addNewScreen=function() {

				if($.trim($("#newscreenname").val()) == '')
				{
					alert("Provide screen name");
					return;
				}
				if($.trim($("#newurl").val()) == '')
				{
//					alert("Provide url from which to retrieve the json");
//					return;
					$.ajax({ 
						url : 'saveScreen.jsp',
						type: 'POST',
						data : {screen : $("#newscreenname").val(), url : $("#newurl").val()},
						dataType : 'json',
						success : function(json1)
						{		
							$("#dialogWindow").dialog('close');
							if(json1.RESPONSE == 'SUCCESS') window.location='screens.jsp';
							else alert("Some error occurred");
						},
						error:function()
						{
							alert("Some error while saving screen info");
						}
					});			
				}
				else
				{
					$.ajax({
						url : $.trim($("#newurl").val()),
						type: 'POST',
						dataType : 'json',
						success : function(json)
						{		
							json = clearJsonValues(json);
							$.ajax({ 
								url : 'saveScreen.jsp',
								type: 'POST',
								data : {json : JSON.stringify(json), screen : $("#newscreenname").val(), url : $("#newurl").val()},
								dataType : 'json',
								success : function(json1)
								{		
									$("#dialogWindow").dialog('close');
									if(json1.RESPONSE == 'SUCCESS') window.location='screens.jsp';
									else alert("Some error occurred");
								},
								error:function()
								{
									alert("Some error while saving screen info");
								}
							});			
						},
						error:function()
						{
							alert("Some error while fetching json from provided url");
						}
					});			
				}	
			};

            var newPageForm = $('#newPageForm');
            newPageForm.on('submit',function(event){
                event.preventDefault();
                var pageName = newPageForm.find('input[name=urlname]');

                if( $.trim(pageName.val()) == ""){
                    alert("page name cannot be empty.");
                    pageName.focus();
                    return false;
                }

                $.ajax({
                    url: 'htmlPageNewBackend.jsp',
                    type: 'GET',
                    dataType: 'JSON',
                    data: newPageForm.serialize()
                })
                .done(function(response) {

                    if(response.RESPONSE == "SUCCESS"){
                        alert("Page added successfully.");
                        window.location.href = "";
                    }
                    else{
                        alert("Error in adding page. Please try again.");
                    }
                })
                .fail(function() {
                    alert("Error in adding page. Please try again.");
                })

            });

		});

		function layoutESDesign(jsonId, ckeditorPageId){

			$.ajax({ 
				url : 'htmlPageNewBackend.jsp',
				type: 'POST',
				data : {
					type : 'getCkeditorPageName',
					esjsonId : jsonId,
					ckeditor_page_id : ckeditorPageId
				},
				dataType : 'json',
				success : function(json)
				{		
					$("#urlname").val("");
					$("#urlname").prop("readonly", false);
					$("#preview_ckeditor_page").css("display","none");
					$("#preview_ckeditor_page").prop("href","#");
					$("#sbmt_newPageForm").text("Create");
					$("#request_type").val("new");
					$("#ckeditor_page_id").val("");

					$("#layout_design").val(1);
					$("#layout_design").trigger("change");

					var pageName = json.name;

					if(json.html_generated>0){

						if(pageName.length > 0){

							$("#sbmt_newPageForm").text("Update");
							$("#request_type").val("update");
							$("#ckeditor_page_id").val(ckeditorPageId);

							$("#preview_ckeditor_page").css("display","block");
							$("#preview_ckeditor_page").prop("href",json.file_path)
							$("#urlname").val(json.name);
							$("#urlname").prop("readonly", true);
							$("#layout_design").val(json.design_layout);
							$("#layout_design").trigger("change");

						}

						$("#esjsonId").val(jsonId);
						$('#ckeditorModal').modal('toggle');

					} else {
						alert("Kindly generate the html file first.");
					}

				}
			});
		}

    </script> 

</body>
</html>