<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ page import="java.io.File"%>
<%@ include file="../common2.jsp"%>

<!doctype html>
<html>
<head>
	<title>Insert Form</title>
	<meta charset="UTF-8"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">

	<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
	<script type="text/javascript" src="<%=request.getContextPath()%>/js/html_form_template.js"></script>	

	<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css">
	
	<style type="text/css">
		.pre-scrollable {
			min-height: 1180px;
		    overflow-y: auto;
		    background: transparent;
		}

		.drag_element {
			border: 1px solid #aaaaaa;
			border-radius: 6px;
			background-color: #e4e3e3;
			min-height: 5%;
			text-align: center;
			padding: 5px;
			cursor: move;
		}

		div.attribute_value_image{
			position: relative;
			display: inline-block;
			cursor: pointer;
		}
		div.attribute_value_image div{
			display: none;
			position: absolute;
			left: 0;
			top: 0;
			background-color: rgba(255,255,255,0.5);
			width: 100%;
			height: 100%;
		}
		div.attribute_value_image:hover div {
			display: block;
			cursor: pointer;
		}
		div.attribute_value_image:hover div i.fa{
			font-size: 16px;
			display: block;
			margin: 5px;
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

			$("#multextfield").draggable({
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

			$("#emptyblock").draggable({
				helper: 'clone'
			});

			$("#number").draggable({
				helper: 'clone'
			});

			$("#hidden").draggable({
				helper: 'clone'
			});

			$("#fileupload").draggable({
				helper: 'clone'
			});

			$("#imgupload").draggable({
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

			$("#hyperlink").draggable({
				helper: 'clone'
			});

			$("#label").draggable({
				helper: 'clone'
			});

			$("#hr").draggable({
				helper: 'clone'
			});

			$("#recaptcha").draggable({
				helper: 'clone'
			});

			$("#password").draggable({
				helper: 'clone'
			});

			Sortable.create(document.getElementById('form_template'), {
				animation: 50,
			});

			$("#form_template").droppable({
				
				drop: function( event, ui ) {

					var elementId = ui.draggable.attr("id");
					var appcontext = $("#appcontext").val() + "uploads/images/";
					var elementHtml = "";
					elementCounter++;
					
					switch(elementId) {

						case "textfield":
						case "email":
						case "number": 
						case "autocomplete":
						case "fileupload":
						case "password":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p> <input id="element_textfield_' + elementCounter + '" class="form-control" type="' + elementId + '" name="" maxlength="" size="" value="" autocomplete="false" /> </p> </div>  </div> </div>';
							break;
						case "recaptcha":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> &nbsp; </p> <p> <input id="element_textfield_' + elementCounter + '" class="form-control" type="textrecaptcha" name="" maxlength="" size="" value="" autocomplete="false" /> </p> </div>  </div> </div>';
							break;
						case "emptyblock":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="padding: 2px; cursor: pointer; min-height: 20px;" onclick="selectedElementEmptyBlock(this);"> </p> </div>  </div> </div>';
							break;
						case "imgupload":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer; height: 15px;" onclick="selectedElement(this);"> </p> <p> <input id="element_textfield_' + elementCounter + '" class="form-control" type="imgupload" autocomplete="false" style="display: none;" /> <a href="#"> <img src="' + appcontext + 'dummy.png" class="img-rounded" width="50" height="50" /> </a> </p> </div>  </div> </div>';
							break;
						case "multextfield":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p> <input id="element_textfield_' + elementCounter + '" class="form-control" type="' + elementId + '" field_type="fs" by_default_field="1" group_of_fields="1" name="" maxlength="" size="" value="" autocomplete="false" /> </p> </div>  </div> </div>';
							break;
						case "date":
						case "datetime":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p> <input id="element_textfield_' + elementCounter + '" class="form-control" type="text' + elementId + '" name="" maxlength="" size="" value="" autocomplete="false" readonly /> </p> </div>  </div> </div>';
							break; 
						case "textarea":
						case "hidden":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p> <input id="element_textfield_' + elementCounter + '" class="form-control" type="text' + elementId + '" name="" maxlength="" size="" value="" autocomplete="false" /> </p> </div>  </div> </div>';
							break;
						case "radio":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; min-height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p style="text-align: left;" class="radio_option"> <input type="radio" name="" value="option1" id="radio_option_' + elementCounter + '_1"> <label id="label_option_radio_' + elementCounter + '_1"> Option1 </label> </p> </div> </div> </div>';
							break;
						case "checkbox":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; min-height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p style="text-align: left;" class="checkbox_option" > <input type="checkbox" name="" value="option1" id="checkbox_option_' + elementCounter + '_1"> <label id="label_option_checkbox_' + elementCounter + '_1"> Option1 </label> </p> </div> </div> </div>';							
							break;
						case "dropdown":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; min-height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> Label </p> <p style="text-align: left;" ><select class="form-control" ><option id="dropdown_option_' + elementCounter + '_0" value="">---select---</option></select></p></div> </div> </div>';							
							break;
						case "button":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElement(this);"> &nbsp; </p> <p> <input style="cursor: pointer;" id="btn_' + elementCounter + '" class="form-control " type="button" name="" value="Button" /> </p> </div> </div> </div>';
							break;
						case "hyperlink":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer; height: 15px;" onclick="selectedElement(this);"> </p> <p> <input id="element_textfield_' + elementCounter + '" class="form-control" type="hyperlink" value="" autocomplete="false" style="display: none;" /> <input type="checkbox" /> <a href="#">Label</a> </p> </div> </div> </div>';
							break;
						case "label":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElementLabel(this);"> Label </p> <span> <div type="label"></div> </span> </div>  </div> </div>';
							break;
						case "noneditablefield":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" onclick="selectedElementNonEditableLabel(this);"> Label </p> <span> <div type="noneditablefield"></div> </span> </div>  </div> </div>';
							break;
						case "hr":
							elementHtml = '<div style="display: inline-block; border-radius: 20px; border: 1px solid #a8a8a8; margin-top: 5px; height: 85px;" class="dropped_element col-xs-12 col-sm-12 col-md-12 col-lg-12"> <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" > <div class="col-xs-1 col-sm-1 col-md-1 col-lg-1 delete_created_element" style="float: right;"><span onclick="deleteElement(this)" style="color: red; cursor: pointer;" title="Delete" class="glyphicon glyphicon-remove"></span> </div> <div class="col-xs-11 col-sm-11 col-md-11 col-lg-11"> <p id="element_label_' + elementCounter + '" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px; cursor: pointer;" >  </p> <span> <div type="hr_line"></div> </span> <hr style="border-width: 1px; border-style: inset; clear: both;" />  </div>  </div> </div>';
							break;
						default:
							break;

					}

					setTimeout(function(){

							if(elementId == "label") selectedElementLabel($("#element_label_"+elementCounter));
							else if(elementId == "noneditablefield") selectedElementNonEditableLabel($("#element_label_"+elementCounter));
							else if(elementId == "emptyblock") selectedElementEmptyBlock($("#element_label_"+elementCounter));
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

									if(finalWidth >= 92) col = "col-xs-12 col-sm-12 col-md-12 col-lg-12";
									else if(finalWidth >= 84) col = "col-xs-11 col-sm-11 col-md-11 col-lg-11";
									else if(finalWidth >= 76) col = "col-xs-10 col-sm-10 col-md-10 col-lg-10";
									else if(finalWidth >= 67) col = "col-xs-9 col-sm-9 col-md-9 col-lg-9";
									else if(finalWidth >= 59) col = "col-xs-8 col-sm-8 col-md-8 col-lg-8";
									else if(finalWidth >= 51) col = "col-xs-7 col-sm-7 col-md-7 col-lg-7";
									else if(finalWidth >= 42) col = "col-xs-6 col-sm-6 col-md-6 col-lg-6";
									else if(finalWidth >= 34) col = "col-xs-4 col-sm-5 col-md-5 col-lg-5";
									else if(finalWidth >= 26) col = "col-xs-4 col-sm-4 col-md-4 col-lg-4";
									else col = "col-xs-3 col-sm-3 col-md-3 col-lg-3"; 

									$(selectedResizeElement).attr("class", "dropped_element "+col);
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
	String formId = parseNull(request.getParameter("form_uuid"));
	String actionForm = "add";

	if(formId.length() > 0) actionForm = "update";
%>	
	<div class="page etn-orange-portal--">		
		<main id="mainFormDiv">
				<div class="container-fluid">
					<div id="create_form_template" class="row">
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
							<h1 style="text-align: center;">Create Form</h1>
						</div>
					</div>

					<div class="row">
						<div class="col-xs-2 col-sm-2 col-md-2 col-lg-2" >
					<%
						if(formId.length() > 0){
					%>
							<a style="margin-top: 320px; margin-left: 40px;" class="btn btn-primary btn-lg active" role="button" aria-pressed="true" href='#' onclick="previewForm('<%= formId%>')"> Preview</a>
					<%
						}
					%>
						</div>
						<div class="col-xs-10 col-sm-10 col-md-10 col-lg-10" > 
							<p id="" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px;"> 
								Form name 
								<span style="color: red;">*</span>
							</p> 
							<p> 
								<input id="form_template_form_name" class="form-control" type="text" name="" maxlength="" size="" value="" onfocusout="formName(this)"> 
							</p> 
							<p id="" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px;"> 
								Table name 
								<span style="color: red;">*</span>
							</p> 
							<p> 
								<input id="form_template_table_name" class="form-control" type="text" name="" maxlength="" size="" value=""> 
								<span style="color: red; display: none; font-size: 0.8em;">Space or special charater not allowed.</span>
							</p> 
							<p id="" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px;"> 
								Title 
							</p> 
							<p> 
								<input id="form_template_title" class="form-control" type="text" name="" maxlength="" size="" value=""> 
							</p> 
							<p id="" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px;"> 
								Success Msg. 
							</p> 
							<p> 
								<input id="form_template_success_msg" class="form-control" type="text" name="" maxlength="" size="" value=""> 
							</p> 
							<p id="" class="col-xs-12 col-sm-12 col-md-12 col-lg-12 control-label" style="text-align: left; padding: 2px;"> 
								Submit button label 
							</p> 
							<p> 
								<input id="form_template_submit_btn_lbl" class="form-control" type="text" name="" maxlength="" size="" value=""> 
							</p> 
						</div> 

					</div>

					<div class="row" id="editorRow">
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
							<div class="form-horizontal">
								<div class="row">
									<div class="form-group" style="margin-left: auto; margin-right: auto;">
										<div id="draggable_options" class="col-xs-2 col-sm-2 col-md-2 col-lg-2">
											<ul class="list-group">
												<li class="list-group-item">
													<p class="drag_element" id="autocomplete">
														Autocomplete
													</p>
												</li>
												<li class="list-group-item">											
													<p class="drag_element" id="recaptcha">
														Re-captcha
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="button">
														Button
													</p>											
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="checkbox">
														Checkbox
													</p>											
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="dropdown" > 
														Dropdown
													</p>											
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="date">
														Date
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="datetime">
														Datetime
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="email">
														Email
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="emptyblock">
														Empty block
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="fileupload">
														File
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="hidden">
														Hidden
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="hyperlink">
														Hyperlink
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="imgupload">
														Image
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="hr">
														Insert Line
													</p>											
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="label">
														Label
													</p>											
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="multextfield">
														Multiple textfield
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="number">
														Number
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="password">
														Password
													</p>
												</li>
												<li class="list-group-item">											
													<p class="drag_element" id="radio">
														Radio
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="textfield">
														Textfield
													</p>
												</li>
												<li class="list-group-item">
													<p class="drag_element" id="textarea">
														Textarea
													</p>
												</li>

												<li class="list-group-item" style="margin-top: 30px;border: none;">
													
													<div id="submit_button" >
														<input type="button" class="btn btn-success btn-block" name="submit" value="Save" onclick="saveForm();">
													</div>
												</li>
											</ul>
										</div>			

										<span id="msg_highlight_area" style="font-size: .8em; color: red;"> 
											Drop element(s) of the below bordered area.
										</span> 
										<form id="" enctype="application/x-www-form-urlencoded" method="post" name="" class="form_template_class" portalgenericform autocomplete="off">
											<div class="col-xs-10 col-sm-10 col-md-10 col-lg-10 pre-scrollable" id="form_template" style="border: 1px solid #eae3e3;"> </div>
											<div class="generic_form_id_error_msg" style="color:red">&nbsp;</div>
											<input type="hidden" id="update_form" value="<%= actionForm%>">
											<input type="hidden" id="edit_html_form_page" value="<%=request.getContextPath()%>/admin/htmlFormPage.jsp">
											<input type="hidden" id="form_uuid" value="<%= formId%>">
											<input type="hidden" id="appcontext" value="<%=request.getContextPath()%>/" />
											<input type="hidden" id="imgUploadSelectedElement" value="" />
										</form>
									</div>
								</div>
							</div>
						</div>
					</div>
					
				</div> 
			</main>
	</div>

						<div class="modal fade" style='text-align:center; display:none; clear:both;' id='uploadProductImageDialog' >
						<div class="modal-dialog" role="document" style="width: 1200px;">
							<div class="modal-content" style="height: 600px; overflow: scroll;" >
								<div class="modal-header" style='text-align:left'>
									<h5 class="modal-title">Upload Image Gallery</h5>
								        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
								          <span aria-hidden="true">&times;</span>
								        </button>
								</div>
								<div class="modal-body text-left">
									<div>
										<form method='post' enctype='multipart/form-data' onsubmit="return false;">
											<div class="form-group row">
												<label class='col-sm-4'>File</label>
												<div class='col-sm-8'><input type='file' name='imageFile' class="imageFile" value=''/></div>
											</div>
										</form>
									</div>
								</div>
								<div class="modal-footer">
									<button type="button" class="btn btn-success" onclick='uploadGalleryImage()'>Upload</button>
								</div>
								<div class="row">
									<div style='text-align:left; margin-left: 30px;'>
										<h5 class="modal-title">Image Gallery</h5>
									</div> 
									<div class="col-xs-11 col-sm-11 col-md-11 col-lg-11" style="border: 1px solid #eae3e3; margin-left: 40px; margin-bottom: 15px; margin-top: 10px;">
										<ul id="imageGalleryList" style="width: 100%; padding: 0px; list-style: none;">
										<%
											try{
												
												String path = GlobalParm.getParm("UPLOAD_IMG_PATH");
												String imagePath = GlobalParm.getParm("FORM_UPLOADS_PATH") + "images/";
												String fileName = "";

												File imageFolder = new File(path);
												File[] listOfFiles = imageFolder.listFiles();

												if(listOfFiles.length == 0){
										%>
													<center><span>No image found.</span></center>
										<%
												}
												for (int i = 0; i < listOfFiles.length; i++) {
													if (listOfFiles[i].isFile()) {
														fileName = listOfFiles[i].getName();
										%>

													<li onclick="update_selected_image(this)" style="height: 284px; width: 30%; float: left; margin: 15px; padding: 15px; border: 1px dotted silver; cursor: pointer;">										
														<center>
															<span style="font-weight: bold; word-break: break-word;"><%= fileName%></span>
															<input type="hidden" value="<%= fileName%>">
														</center>
														<br>
														<center>
															<img src='<%= imagePath+fileName%>' style="max-height: 169px;">
														</center>
													
													</li>											
										<%
													} 
												}


											}catch(Exception e){
												e.printStackTrace();
											}

										%>
										</ul>
									</div>
								</div>
							</div><!-- /.modal-content -->
						</div><!-- /.modal-dialog -->
					</div>


</body>
</html>



