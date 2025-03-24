<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*"%>

<%!

	String parseNull(String str) {
		String s = null;
		try {
			s = str.trim();
			if (s.length() == 0)
				s = "";
		} catch (Exception e) {
			s = "";
		}
		return s;
	}

%>
<!DOCTYPE html>
<html>
<head>
	<title>Define Rules</title>

	<meta charset="UTF-8"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">

	<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css">

	<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/html_form_template.js"></script>

	<script type="text/javascript">
		
		var value = "";		

		function load_rule_form_template(){

			value = $("#rule_form_list").val();
			if(value != ""){

			    $.ajax({
			        url : $("#appcontext").val()+'admin/ajax/backendAjaxCallHandler.jsp',
			        type: 'POST',
			        dataType: 'JSON',
			        data: {
			        	"action": 'load_rule_selected_form_template',
			        	"form_id": value
			        },
			        success : function(response) {

			        	var ruleColumns = "";

			        	for(var i=0; i < response.json_generic_process.length; i++){

			        		ruleColumns += response.json_generic_process[i];
			        		if(i != response.json_generic_process.length-1) ruleColumns += ",";
			        	}

			        	$("#list_rule_columns").val(ruleColumns);
			        	$("#rule_combination_form").css("display", "block");
			        	$("#selected_form_id").val(value);
						$("#rule_combination_list").html(response.json_combination_rules);
			        }
			    });
			}
		}

		function add_rule_combination(){

			var flag = false;
			$('#rule_combination_list select[required], input[required]').each(function(){

				if($(this).val().length==0 && !flag){

					alert("kindly fill the required field.");
					$(this).focus();
					flag = true;
				}

			});

			if(!flag) $("#rule_combination_form").submit();
		}

		function formFieldMapping(formId, ruleId){
			
			var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			propriete += ",width=1250" + ",height=800"; 
			win = window.open($("#form_fields_url").val() + "?form_id=" + formId + "&rule_id=" + ruleId, "Mapping the fields", propriete);
			win.focus();
		}

		setTimeout(function(){

			value = $("#rule_form_list").val();
			if(value != "") load_rule_form_template();

		}, 200);

	</script>

</head>
<body>
  <%@include file="/WEB-INF/include/menu.jsp"%>
<%

	Set formsRs = Etn.execute("SELECT distinct pf.form_id, process_name FROM process_forms pf, process_form_fields pff WHERE pf.form_id = pff.form_id AND pff.rule_field = " + escape.cote("1") + " ORDER BY 2;");

	String selectedFormId = parseNull(request.getParameter("selected_form_id"));
	String ruleName = parseNull(request.getParameter("rule_name"));
	String groupId = parseNull(request.getParameter("group_id"));
	String listRuleColumns = parseNull(request.getParameter("list_rule_columns"));

	String insertQuery = "INSERT INTO process_rules (rule_name, group_id, form_id, rule_combination) VALUES ";
	String params = "";
	String requestParams = "";

	String[] token = listRuleColumns.split(",");

	if(listRuleColumns.length() > 0){

		params = "";
		for(int i=0; i<token.length; i++){

			requestParams = "";

			if(request.getParameterValues(token[i]).length > 1){

				for(int j=0; j < request.getParameterValues(token[i]).length; j++){
					
					requestParams += request.getParameterValues(token[i])[j];
					if( j != request.getParameterValues(token[i]).length-1 ) requestParams += ",";
				}
			}
			else
				requestParams = request.getParameter(token[i]).trim();

			params += escape.cote(token[i]) + "," + escape.cote(requestParams);
			if(i != token.length-1) params += ",";
		}

		insertQuery += "(" + escape.cote(ruleName) + "," + escape.cote(groupId) + "," + escape.cote(selectedFormId) + ", COLUMN_CREATE(" + params + "));";

		int r = Etn.executeCmd(insertQuery);
	}

/*
	String selectedFormId = parseNull(request.getParameter("selected_form_id"));
	String listRuleColumns = parseNull(request.getParameter("list_rule_columns"));

	String insertQuery = "INSERT INTO generic_rules (form_id, rule_combination) VALUES ";
	String params = "";

	String[] token = listRuleColumns.split(",");
	String[] ruleArray = null;

	boolean recordFound = true;
	boolean isRuleValid = false;
	int colIndex = 0;

	if(listRuleColumns.length() > 0){

		while(recordFound){
	
			recordFound = false;
			isRuleValid = false;

			params = "";
			for(int i=0; i<token.length; i++){
				
				ruleArray = request.getParameterValues(token[i]);


				if(colIndex < ruleArray.length){
					
					if(ruleArray[colIndex].length() > 0) isRuleValid = true;
	
					params += escape.cote(token[i]) + "," + escape.cote(ruleArray[colIndex]);
					recordFound = true;
					if(i != token.length-1) params += ",";
				}			

			}
			
			if(colIndex != ruleArray.length && isRuleValid) insertQuery += "(" + escape.cote(selectedFormId) + ", COLUMN_CREATE(" + params + ")),";
			 
			colIndex++; 
		}

		insertQuery += params;
		insertQuery = insertQuery.substring(0, insertQuery.length()-1);

		int r = Etn.executeCmd(insertQuery);
		System.out.println(r);
	}
*/
%>	
	<div class="page etn-orange-portal--">		
		<main id="mainFormDiv">
				<div class="container">
					<div id="create_form_template" class="row">
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" style='text-align:center; font-weight:bold; font-size:16px; margin-bottom:15px'>
							Define Rules
						</div>
					</div>
					<div id="created_form_templates" class="row">
						<div class='col-sm-12 text-center'>
							<label class='col-sm-2 control-label'>Process</label>	
							<div class='col-sm-5' >
								<select id="rule_form_list" class="form-control" onchange="load_rule_form_template();">
									<option value="">---select---</option>
								<%
									while(formsRs.next()){
								%>
										<option <% if(selectedFormId.equals(formsRs.value("form_id"))){ %> selected="selected" <% } %> value='<%=formsRs.value("form_id")%>'><%=formsRs.value("process_name")%></option>
								<%
									}
								%>
								</select>
							</div>
						</div>
				</div>
				<div class="container-fluid">
					<form id="rule_combination_form" enctype="application/x-www-form-urlencoded" method="post" name="" autocomplete="off" style="text-align: center; display: none;">

						<div id="rule_combination_list" style="margin-top: 40px;" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">

						</div>

						<div id="form_rule_template" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
						</div>
						
						<div id="group_actions" style="margin-top: 40px;" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
						</div>

						<input type='hidden' id='list_rule_columns' name='list_rule_columns' value='' /> 
						<input type="hidden" id="selected_form_id" name="selected_form_id" value="">
			    		<input type="hidden" id="form_fields_url" value="<%=request.getContextPath()%>/mappingFields.jsp">
			    		<input type="hidden" id="add_action" value="<%=request.getContextPath()%>/addAction.jsp">
						<input type="hidden" id="appcontext" value="<%=request.getContextPath()%>/" />

					</form>
				</div> 
			</main>


	</div>

</body>
</html>