<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ include file="../../common2.jsp"%>
<%@ page import="com.etn.util.ItsDate"%>

<!doctype html>
<html>
<head>
	<title>Insert Form</title>
	<meta charset="UTF-8"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">

	<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap__portal__.css">

	<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/Sortable.min.js"></script>
	<script type="text/javascript" src="js/html_form_template.js"></script>	
	
	<style type="text/css">
		.pre-scrollable {
			height: 940px;
		    overflow-y: auto;
		    background: transparent;
		}

		.o-drag_element {
			border: 1px solid #aaaaaa;
			border-radius: 6px;
			background-color: #e4e3e3;
			min-height: 5%;
			text-align: center;
			padding: 5px;
			cursor: move;
		}
	</style>
	
	<script type="text/javascript">


		$(document).ready(function(){

			$("#autocomplete").draggable({
				helper: 'clone'
			});

			$("#textfield").draggable({
				helper: 'clone'
			});

			$("#noneditablefield").draggable({
				helper: 'clone'
			});

			$("#textarea").draggable({
				helper: 'clone'
			});

			$("#email").draggable({
				helper: 'clone'
			});

			$("#number").draggable({
				helper: 'clone'
			});

			$("#hidden").draggable({
				helper: 'clone'
			});

			$("#date").draggable({
				helper: 'clone'
			});

			$("#datetime").draggable({
				helper: 'clone'
			});

			$("#radio").draggable({
				helper: 'clone'
			});

			$("#dropdown").draggable({
				helper: 'clone'
			});

			$("#checkbox").draggable({
				helper: 'clone'
			});

			$("#button").draggable({
				helper: 'clone'
			});

			$("#label").draggable({
				helper: 'clone'
			});

			$("#hr").draggable({
				helper: 'clone'
			});

			Sortable.create(document.getElementById('form_template'), {
				animation: 50,
			});

			$("#form_template").droppable({
				
				drop: function( event, ui ) {

					var elementId = ui.draggable.attr("id");
					var elementHtml = "";
					elementCounter++;

					switch(elementId) {

						case "textfield":
						case "email":
						case "number": 
						case "autocomplete":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p> <input id="element_textfield_' + elementCounter + '" class="o-form-control" type="' + elementId + '" field_type="fs" by_default_field="1" name="" maxlength="" size="" value="" autocomplete="false" /> </p> </div>  </div> </div>';
							break;
						case "date":
						case "datetime":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p> <input id="element_textfield_' + elementCounter + '" class="o-form-control" type="text' + elementId + '" field_type="fs" by_default_field="1" name="" maxlength="" size="" value="" autocomplete="false" readonly /> </p> </div>  </div> </div>';
							break; 
						case "textarea":
						case "hidden":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p> <input id="element_textfield_' + elementCounter + '" class="o-form-control" type="text' + elementId + '" field_type="fs" by_default_field="1" name="" maxlength="" size="" value="" autocomplete="false" /> </p> </div>  </div> </div>';
							break;
						case "radio":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; min-height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p style="text-align: left;" class="o-radio_option"> <input type="radio" name="" value="option1" field_type="fs" by_default_field="1" id="radio_option_' + elementCounter + '_1"> <label id="label_option_radio_' + elementCounter + '_1"> Option1 </label> </p> </div> </div> </div>';
							break;
						case "checkbox":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; min-height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p style="text-align: left;" class="o-checkbox_option" > <input type="checkbox" name="" value="option1" field_type="fs" by_default_field="1" id="checkbox_option_' + elementCounter + '_1"> <label id="label_option_checkbox_' + elementCounter + '_1"> Option1 </label> </p> </div> </div> </div>';							
							break;
						case "dropdown":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; min-height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p style="text-align: left;" ><select class="o-form-control" by_default_field="1" field_type="fs"><option id="dropdown_option_' + elementCounter + '_0" value="">---select---</option></select></p></div> </div> </div>';
							break;
						case "button":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> &nbsp; </p> <p> <input style="cursor: pointer;" id="btn_' + elementCounter + '" class="o-form-control " type="button" name="" value="Button"> </p> </div> </div> </div>';
							break;
						case "label":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElementLabel(this);"> Label </p> <span> <div type="label"></div> </span> </div>  </div> </div>';
							break;
						case "noneditablefield":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElementNonEditableLabel(this);"> Label </p> <span> <div type="noneditablefield"></div> </span> </div>  </div> </div>';
							break;
						case "hr":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="o-dropped_element o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12"> <div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12" > <div class="o-col-xs-1 o-col-sm-1 o-col-md-1 o-col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="o-glyphicon o-glyphicon-remove"></span> </div> <div class="o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11"> <p id="element_label_' + elementCounter + '" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px; cursor: pointer;" >  </p> <span> <div type="hr_line"></div> </span> <hr style="border-width: 1px; border-style: inset; clear: both;" />  </div>  </div> </div>';
							break;
						default:
							break;

					}

					
					setTimeout(function(){

						if(elementId == "label") selectedElementLabel($("#element_label_"+elementCounter));
						else if(elementId == "noneditablefield") selectedElementNonEditableLabel($("#element_label_"+elementCounter));
						else selectedElement($("#element_label_"+elementCounter));							

						var selectedResizeElement = "";
						$("#element_label_"+elementCounter).parent().parent().parent().resizable({

							start: function(event, ui){

								selectedResizeElement = ui.element;
							},
							stop: function(event,ui){

								var clientWidth = $(selectedResizeElement).parent().width();
								var targetWidth = ui.size.width;
								var finalWidth = Math.round((targetWidth/clientWidth)*100);
								var col = "";

								if(finalWidth >= 92) col = "o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12";
								else if(finalWidth >= 84) col = "o-col-xs-11 o-col-sm-11 o-col-md-11 o-col-lg-11";
								else if(finalWidth >= 76) col = "o-col-xs-10 o-col-sm-10 o-col-md-10 o-col-lg-10";
								else if(finalWidth >= 67) col = "o-col-xs-9 o-col-sm-9 o-col-md-9 o-col-lg-9";
								else if(finalWidth >= 59) col = "o-col-xs-8 o-col-sm-8 o-col-md-8 o-col-lg-8";
								else if(finalWidth >= 51) col = "o-col-xs-7 o-col-sm-7 o-col-md-7 o-col-lg-7";
								else if(finalWidth >= 42) col = "o-col-xs-6 o-col-sm-6 o-col-md-6 o-col-lg-6";
								else if(finalWidth >= 34) col = "o-col-xs-4 o-col-sm-5 o-col-md-5 o-col-lg-5";
								else if(finalWidth >= 26) col = "o-col-xs-4 o-col-sm-4 o-col-md-4 o-col-lg-4";
								else col = "o-col-xs-3 o-col-sm-3 o-col-md-3 o-col-lg-3"; 

								$(selectedResizeElement).attr("class", "o-dropped_element "+col);
								setTimeout(function(){
									
									$(selectedResizeElement).css("width", "");
								}, 200);
								
							}
						});
						}, 100);

					$(this).append(elementHtml);
				}
			});
		});
		
		setTimeout(function(){
			load_form_template();
		}, 200);
	</script>

</head>
<body >
<%
	String formId = parseNull(request.getParameter("form_id"));
%>	
	<div class="o-page etn-orange-portal--">		
		<main id="mainFormDiv">
				<div class="o-container-fluid">
					<div id="create_form_template" class="o-row">
						<div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12">
							<h1 style="text-align: center;">Edit Form Template</h1>
						</div>
					</div>

					<div id="form_template_ft_name" style="display: none;" class="o-row">
						<div class="o-col-xs-2 o-col-sm-2 o-col-md-2 o-col-lg-2" ></div>
						<div class="o-col-xs-10 o-col-sm-10 o-col-md-10 o-col-lg-10" > 
							<p id="" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px;"> 
								Process name 
								<span style="color: red;">*</span>
							</p> 
							<p> 
								<input id="form_template_form_name" class="o-form-control" type="text" name="" maxlength="" size="" value="" onfocusout="formName(this)"> 
							</p> 
							<p id="" class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12 o-control-label" style="text-align: left; padding: 2px;"> 
								Table name 
							</p> 
							<p> 
								<input id="form_template_table_name" class="o-form-control" type="text" name="" maxlength="" size="" value=""> 
							</p> 
						</div> 

					</div>

					<div id="form_template_design" style="display: none;" class="o-row" id="editorRow">
						<div class="o-col-xs-12 o-col-sm-12 o-col-md-12 o-col-lg-12">
							<div class="o-form-horizontal">
								<div class="o-row">
									<div class="o-form-group" style="margin-left: auto; margin-right: auto;">
										<div id="draggable_options" class="o-col-xs-2 o-col-sm-2 o-col-md-2 o-col-lg-2">
											<ul class="o-list-group">
												<li class="o-list-group-item">
													<p class="o-drag_element" id="autocomplete">
														Autocomplete
													</p>
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="textfield">
														Textfield
													</p>
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="textarea">
														Textarea
													</p>
												</li>
<!-- 
												<li class="o-list-group-item">
													<p class="o-drag_element" id="noneditablefield">
														Non-editable field
													</p>
												</li>
 -->
												<li class="o-list-group-item">
													<p class="o-drag_element" id="email">
														Email
													</p>
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="number">
														Number
													</p>
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="hidden">
														Hidden
													</p>
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="date">
														Date
													</p>
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="datetime">
														Datetime
													</p>
												</li>
												<li class="o-list-group-item">											
													<p class="o-drag_element" id="radio">
														Radio
													</p>
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="dropdown" > 
														Dropdown
													</p>											
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="checkbox">
														Checkbox
													</p>											
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="button">
														Button
													</p>											
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="label">
														Label
													</p>											
												</li>
												<li class="o-list-group-item">
													<p class="o-drag_element" id="hr">
														Insert Line
													</p>											
												</li>

												<li class="o-list-group-item" style="margin-top: 30px;border: none;">
													
													<div id="submit_button" >
														<input type="button" class="o-btn o-btn-success o-btn-block" name="submit" value="Update" onclick="saveForm();">
													</div>
												</li>
											</ul>
										</div>			

										<span id="msg_highlight_area" style="font-size: .8em; color: red;"> 
											Drop element(s) of the below bordered area.
										</span> 
										<form id="" enctype="application/x-www-form-urlencoded" method="post" name="" class="form_template_class" portalgenericform autocomplete="off">
											<div class="o-col-xs-10 o-col-sm-10 o-col-md-10 o-col-lg-10 pre-scrollable" id="form_template" style="border: 1px solid #eae3e3;"> </div>
											<div class="generic_form_id_error_msg" style="color:red">&nbsp;</div>
											<input type="hidden" id="update_form" value="update">
											<input type="hidden" id="form_id" value="<%=com.etn.asimina.util.UIHelper.escapeCoteValue(formId)%>">
											<input type="hidden" id="edit_html_form_page" value="<%=request.getContextPath()%>/editHtmlFormPage.jsp">
										</form>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div> 
			</main>


	</div>

</body>
</html>
