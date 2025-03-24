<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Expert System</title>

<link href="css/abcde.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css" href="../css/ui-lightness/jquery-ui-1.8.18.custom.css" />
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/menu.css">

<SCRIPT LANGUAGE="JavaScript" SRC="../js/jquery-1.9.1.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../js/jquery-ui-1.10.4.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../js/bootstrap.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

</head>

<body>

    <%@include file="/WEB-INF/include/menu.jsp"%>

		<div class="container">
		<div style='text-align:center'><h2>Expert system screens</h2></div>
		<center>

			<div class="form-horizontal" role="form" style="padding: 15px; background: #eee; border-radius: 6px; margin-bottom: 15px;">
				
				<div id="createUserFilterMainDiv">				
					<div class="row">
						<div class="col-xs-12 col-sm-6">
							<div class="form-group">
								<label class="col-sm-3">Dest. page</label>
								<div class="col-sm-9">
									<input name="destination_page" id="destination_page" type="text" class="form-control" placeholder="Destination page">
								</div>
							</div>
						</div>
					</div>
				</div>
				
				<div class="row">
					<div class="col-sm-12 text-center">
						<div class="" role="group" aria-label="controls">
							<button id="createUserFilterBack" disabled type="button" class="btn btn-primary">Back</button>
							<button id="createUserFilterNext" type="button" class="btn btn-primary">Next</button>
							<input type="hidden" id="step_no" value="1">
							<input type="hidden" id="dest_page_added" value="true">
							<input type="hidden" id="dest_page_id" value="">
						</div>
					</div>
				</div>	
			</div>

			<div id="createdUserFilters" style="display: none;" class="row">
				<table class="table table-hover">
					<thead>
						<tr>
							<th>Display name</th>
							<th>Used as parameter</th>
							<th>Destination page</th>
						</tr>
					</thead>
					<tbody id="createdUserFiltersList">
					</tbody>
				</table>
			</div>
		</center>
	</div>

</body>
    <script type="text/javascript">
		jQuery(document).ready(function() {

			$("#createUserFilterNext").on('click', function(){

				if($("#destination_page").val().length == 0){
					alert("Enter destination page.");
					$("#destination_page").focus();
					return false;
				}

				var stepNo = $("#step_no").val();

				if(stepNo == 1){

					$.ajax({ 
						url : 'createUserFilterBackend.jsp',
						type: 'POST',
						data : {
							type : "add_destination_page", 
							destination_page : $("#destination_page").val(),
							dest_page_added : $("#dest_page_added").val(),
							dest_page_id : $("#dest_page_id").val()
						},
						dataType : 'json',
						success : function(json)
						{		
							if(json.RESPONSE == "SUCCESS"){

								var html = "<div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Dest. page : </label> <div class=\"col-sm-9\"> <input name=\"destination_page\" id=\"destination_page\" type=\"text\" class=\"form-control\" value=\"" + $("#destination_page").val() + "\" readonly> </div> </div> </div> </div> <div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Auto. screen?</label> <div class=\"col-sm-9\"> <input name=\"auto_screen\" style=\"margin-right: 100%;\" id=\"auto_screen\" checked type=\"checkbox\" > </div> </div> </div> </div>";
								$("#createUserFilterMainDiv").html(html);
								$("#createUserFilterBack").prop("disabled", false);
								$("#dest_page_added").val("false");
								$("#dest_page_id").val(json.DEST_PAGE_ID);

							}

							$("#step_no").val(parseInt(stepNo)+1);
						},
						error:function()
						{
							alert("Some error while saving destination page");
						}

					});			

				} else if(stepNo == 2){

					$.ajax({ 
						url : 'createUserFilterBackend.jsp',
						type: 'POST',
						data : {
							type : "add_auto_screen", 
							auto_screen : $("#auto_screen").prop('checked'),
							dest_page_id : $("#dest_page_id").val(),
							dest_page_name : $("#destination_page").val()
						},
						dataType : 'JSON',
						success : function(json)
						{
							if(json.RESPONSE == "SUCCESS"){

								var html = "<div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Dest. page : </label> <div class=\"col-sm-9\"> <input name=\"destination_page\" id=\"destination_page\" type=\"text\" class=\"form-control\" value=\"" + $("#destination_page").val() + "\" readonly> </div> </div> </div> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-4\">Auto. screen : </label> <div class=\"col-sm-1\"> <input ";

								if($("#auto_screen").prop('checked')) html += " checked ";

								html += "disabled name=\"auto_screen\" id=\"auto_screen\" type=\"checkbox\"> </div> </div> </div> </div> <div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Type : </label> <div class=\"col-sm-9\"> <select onchange=\"user_filter_type(this)\" id=\"user_filter_type\" class=\"form-control\"> <option>---select---</option> <option value=\"textfield\" >Textfield</option> <option value=\"dropdown\" >Dropdown</option> </select> </div> </div> </div> </div> <div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Display name : </label> <div class=\"col-sm-9\"> <input name=\"display_name\" id=\"display_name\" type=\"text\" class=\"form-control\" placeholder=\"Display name\"> </div> </div> </div> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-4\">Used as parameter : </label> <div class=\"col-sm-1\"> <input name=\"used_as_parameter\" id=\"used_as_parameter\" type=\"checkbox\"> </div> </div> </div> </div>";

								$("#createUserFilterNext").html("Save");
								$("#createUserFilterNext").attr("id", "createUserFilterSave");								
								$("#createUserFilterMainDiv").html(html);

							}else if(json.RESPONSE == "FOF"){

								alert("Destination file is not found");
								return false;
							}


							$("#step_no").val(parseInt(stepNo)+1);
						},
						error:function()
						{
							alert("Some error while saving destination page");
						}

					});

				} else if(stepNo == 3){

					$.ajax({ 
						url : 'createUserFilterBackend.jsp',
						type: 'POST',
						data : {
							type : "add_dest_page_filter", 
							display_name : $("#display_name").val(),
							dest_page_id : $("#dest_page_id").val(),
							user_filter_type : $("#user_filter_type").val(),
							used_as_parameter : $("#used_as_parameter").prop("checked")
						},
						dataType : 'HTML',
						success : function(json)
						{		

							var html = "<div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Dest. page : </label> <div class=\"col-sm-9\"> <input name=\"destination_page\" id=\"destination_page\" type=\"text\" class=\"form-control\" value=\"" + $("#destination_page").val() + "\" readonly> </div> </div> </div> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-4\">Auto. screen : </label> <div class=\"col-sm-1\"> <input ";

							if($("#auto_screen").prop('checked')) html += " checked ";

							html += "disabled name=\"auto_screen\" id=\"auto_screen\" type=\"checkbox\"> </div> </div> </div> </div> <div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Display name : </label> <div class=\"col-sm-9\"> <input name=\"display_name\" id=\"display_name\" type=\"text\" class=\"form-control\" placeholder=\"Display name\"> </div> </div> </div> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-4\">Used as parameter : </label> <div class=\"col-sm-1\"> <input name=\"used_as_parameter\" id=\"used_as_parameter\" type=\"checkbox\"> </div> </div> </div> </div>";

							$("#createUserFilterMainDiv").html(html);
							$("#createdUserFilters").css("display", "block");
							$("#createdUserFiltersList").html(json);

							$("#step_no").val(parseInt(stepNo)+1);
						},
						error:function()
						{
							alert("Some error while saving destination page");
						}

					});

				}
			});


			$("#createUserFilterBack").on('click', function(){

				var stepNo = $("#step_no").val();
				
				if(stepNo == 2){

					var html = "<div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Dest. page : </label> <div class=\"col-sm-9\"> <input name=\"destination_page\" id=\"destination_page\" type=\"text\" class=\"form-control\" value=\"" + $("#destination_page").val() + "\" > </div> </div> </div> </div>";

					$("#createUserFilterMainDiv").html(html);
					$("#createUserFilterBack").prop("disabled", true);
					$("#dest_page_added").val("true");

				}else if(stepNo == 3){

					var html = "<div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Dest. page : </label> <div class=\"col-sm-9\"> <input name=\"destination_page\" id=\"destination_page\" type=\"text\" class=\"form-control\" value=\"" + $("#destination_page").val() + "\" readonly> </div> </div> </div> </div> <div class=\"row\"> <div class=\"col-xs-12 col-sm-6\"> <div class=\"form-group\"> <label class=\"col-sm-3\">Auto screen?</label> <div class=\"col-sm-9\"> <input "

					if($("#auto_screen").prop('checked')) html += " checked ";

					html += "name=\"auto_screen\" style=\"margin-right: 100%;\" id=\"auto_screen\" type=\"checkbox\" > </div> </div> </div> </div>";

					$("#createUserFilterMainDiv").html(html);
				}

				$("#createUserFilterSave").html("Next");
				$("#createUserFilterSave").attr("id", "createUserFilterNext");
				$("#step_no").val(stepNo-1);
			});

			user_filter_type = function(element){

				alert($(element).val());
			};

		});

    </script> 
</html>	