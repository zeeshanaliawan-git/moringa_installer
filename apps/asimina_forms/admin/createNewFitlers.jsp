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
	<title></title>

	<meta charset="UTF-8"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">

	<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/jquery.min.css">
	<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css">

	<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/html_form_template.js"></script>

</head>
<body>
  <%@include file="/WEB-INF/include/menu.jsp"%>
<%
	String formName = parseNull(request.getParameter("form_name"));
	Set createdFormFilterRs = Etn.execute("SELECT id, form_name, table_name, label_id, label FROM form_fields_generic_process WHERE form_name = " + escape.cote(formName) + " AND type NOT IN ('noneditablefield', 'hr_line', 'label', 'button') ORDER by 1;");

	Set selectedFilterRs = Etn.execute("SELECT * FROM generic_form_filters WHERE form_name = " + escape.cote(formName));
	Set filterParamRs = null;
	Set listParamRs = null;

	String filterParams = "";
	String listParams = "";

	if(selectedFilterRs.next()){
		
		String[] token = parseNull(selectedFilterRs.value("selected_filter")).split(",");
		for(int i=0; i < token.length; i++){

			if(token[i].length() > 0) filterParams += escape.cote(token[i]) + ",";
		}

		token = parseNull(selectedFilterRs.value("selected_list")).split(",");
		for(int i=0; i < token.length; i++){

			if(token[i].length() > 0) listParams += escape.cote(token[i]) + ",";
		}
		
		if(filterParams.length() > 0){
			
			filterParams = filterParams.substring(0, filterParams.length()-1);
			filterParamRs = Etn.execute("SELECT label_id, label FROM form_fields_generic_process WHERE form_name = " + escape.cote(formName) + " AND label_id IN (" + filterParams + ") ORDER by 2;");
		} 
	
		if(listParams.length() > 0){
			
			listParams = listParams.substring(0, listParams.length()-1);
			listParamRs = Etn.execute("SELECT label_id, label FROM form_fields_generic_process WHERE form_name = " + escape.cote(formName) + " AND label_id IN (" + listParams + ") ORDER by 2;");
		}	
		

		
	}

%>	
	<div class="page etn-orange-portal--">		
		<main id="mainFormDiv">
				<div class="container-fluid">
					<div id="create_form_template" class="row">
						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
							<h1 style="text-align: center;">Create New Filters</h1>
						</div>
					</div>

					<div id="created_form_templates" class="row">
						<div style="margin-left: 80px;" class="col-xs-3 col-sm-3 col-md-3 col-lg-3">
							<p class="col-sm-6 control-label"> <label>Selected Filters</label> </p>
							<div style="margin-top: 30px; margin-left: 20px;">
								<table class="table table-striped">
									<tr>									
										<th> Filter name </th>
										<th> Delete </th>
									</tr>
									<%

										if(null != filterParamRs && filterParamRs.rs.Rows == 0){
									%>
											<tr>
												<td>
													No filter selected yet.
												</td>
												<td>
													&nbsp;
												</td>
											</tr>
									<%
										}

										while(null != filterParamRs && filterParamRs.next()){
									%>
											<tr>
												<td>
													<%= filterParamRs.value("label")%>
												</td>
												<td>
													<span onclick="delete_selected_filter(this)" id='<%= filterParamRs.value("label_id")%>' style="cursor: pointer;" class="glyphicon glyphicon-remove"></span>
												</td>
											</tr>
									<%
										}
									%>
								</table>
							</div>
							
						</div>
						<div class="col-xs-1 col-sm-1 col-md-1 col-lg-1" style="width: 2%; margin-top: 200px;">
							
							<span style="cursor: pointer; font-size: x-large;" class="glyphicon glyphicon-arrow-left" onclick="move_to_selected_filters();">
							</span>						
						</div>
						<div class="col-xs-4 col-sm-4 col-md-4 col-lg-4">
							<p class="col-sm-4 control-label"> <label>Created Filters</label> </p>
							<select multiple id="created_form_filters" class="form-control" style="min-height: 500px;">
							<%
								while(createdFormFilterRs.next()){
							%>
									<option value='<%=createdFormFilterRs.value("label_id")%>'><%=createdFormFilterRs.value("label")%></option>
							<%
								}
							%>
							</select>
						</div>
						<div class="col-xs-1 col-sm-1 col-md-1 col-lg-1" style="width: 2%; float: left; margin-top: 200px;">
							<span style="cursor: pointer; font-size: x-large;" class="glyphicon glyphicon-arrow-right" onclick="move_to_selected_list();">
							</span>						
						</div>
						<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">							
							<p class="col-sm-6 control-label"> <label>Selected list</label> </p>
							<div style="margin-top: 30px; margin-left: 20px;">
								<table class="table table-striped">
									<tr>									
										<th> Filter name </th>
										<th> Delete </th>
									</tr>
									<%

										if(null != listParamRs && listParamRs.rs.Rows == 0){
									%>
											<tr>
												<td>
													No filter selected yet.
												</td>
												<td>
													&nbsp;
												</td>
											</tr>
									<%
										}

										while(null != listParamRs && listParamRs.next()){
									%>
											<tr>
												<td>
													<%= listParamRs.value("label")%>
												</td>
												<td>
													<span onclick="delete_selected_list(this)" id='<%= listParamRs.value("label_id")%>' style="cursor: pointer;" class="glyphicon glyphicon-remove"></span>
												</td>
											</tr>
									<%
										}
									%>
								</table>
							</div>
						</div>
					</div>
					<input type="hidden" id="form_name" value="<%= formName%>">
				</div> 
			</main>


	</div>

</body>
</html>