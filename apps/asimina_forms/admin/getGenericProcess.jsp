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
<%@ include file="../common2.jsp" %>

<!DOCTYPE html>
<html>
<head>
	<title></title>

	<meta charset="UTF-8"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">

	<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css">
	<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/jquery.min.css">

	<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/html_form_template.js"></script>
	
  <script type="text/javascript">
    
    setTimeout(function(){

      datetimePickerTrigger();
    }, 500);
    

  </script>

</head>
  <%@include file="/WEB-INF/include/menu.jsp"%>
<body>
<%

	String formName = parseNull(request.getParameter("form_name"));
	Set genericFormFilterRs = Etn.execute("SELECT * FROM generic_form_filters WHERE form_name = " + escape.cote(formName));
	Set selectedFilterRs = null;
	Set selectedListRs = null;
	Set selectedListValueRs = null;
    Map selectedElementValueMap = new HashMap<String, String>(); 
	String selectedFilter = "";
	String selectedList = "";
	String selectedListParams = "";
	String tableName = "";
	String requestParams = "";
	String params = "";
	int dbColumnCount = 0;

	if(genericFormFilterRs.next()){
		
		String[] token = parseNull(genericFormFilterRs.value("selected_filter")).split(",");

		for(int i=0; i < token.length; i++){

			if(token[i].length() > 0) selectedFilter += escape.cote(token[i]) + ","; 
		}

		token = parseNull(genericFormFilterRs.value("selected_list")).split(",");
		for(int i=0; i < token.length; i++){
			
			if(token[i].length() > 0) selectedList += escape.cote(token[i]) + ",";
		}

		selectedFilter = selectedFilter.substring(0, selectedFilter.length()-1);
		selectedList = selectedList.substring(0, selectedList.length()-1);

		selectedFilterRs = Etn.execute("SELECT * FROM form_fields_generic_process WHERE form_name = " + escape.cote(formName) + " AND label_id IN (" + selectedFilter + ")  ORDER BY 1;");


		selectedListRs = Etn.execute("SELECT id, table_name, label_id, label, db_column_name, name FROM form_fields_generic_process WHERE form_name = " + escape.cote(formName) + " AND label_id IN (" + selectedList + ") ORDER BY 1;");
			
		while(selectedListRs.next()){
			
			selectedListParams += parseNull(selectedListRs.value("db_column_name")) + ",";
			requestParams = parseNull(request.getParameter(parseNull(selectedListRs.value("name")).replaceAll(" ", "_").toLowerCase()));

			if(requestParams.length() > 0){

				params += parseNull(selectedListRs.value("db_column_name")).replaceAll(" ", "_").toLowerCase() + "=" + escape.cote(requestParams) + " AND ";
		        selectedElementValueMap.put(parseNull(selectedListRs.value("label_id")), requestParams);
			}

			tableName = parseNull(selectedListRs.value("table_name"));
			dbColumnCount++;
		}
		
		if(params.length() > 0)	params = params.substring(0, params.length()-4);

		selectedListParams = selectedListParams.substring(0, selectedListParams.length()-1);

		if(tableName.length() > 0){
			
			String query = "SELECT " + selectedListParams + "," + tableName + "_id as tid, rule_id FROM " + tableName;
			if(params.length() > 0) query += " WHERE " + params;
			
			System.out.println(query);
			selectedListValueRs = Etn.execute(query);
		}
	}
	
%>	
	<div class="page etn-orange-portal--">		
		<main id="mainFormDiv">
				<div class="container-fluid">
					
					<form id="generic_process_form" enctype="application/x-www-form-urlencoded" method="post" autocomplete="off" style="text-align: center;">

						<div style="border-bottom: 1px solid #ddd; background-color: #eee; width: 1024px; margin-left: 148px; margin-top: 20px; padding: 15px;" id="created_process_filters" class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
						<%
							if(null != selectedFilterRs){
								
								out.write(loadDynamicsSection(Etn, selectedFilterRs, null, selectedElementValueMap, "", "0", ""));
						%>
								<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
									<button onclick="search_generic_process()" type="button" class="btn btn-primary">Submit</button>
								</div>
						<%
							} 
						%>
						</div>

						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" style="margin-left: 135px; width: 128px; margin-top: 20px;">
							<button onclick="add_demand_register()" type="button" class="btn btn-primary">Add Demand</button>
						</div>

						<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" style="margin-top: 20px; width: 1024px; margin-left: 148px;">
							<table class="table table-striped">
								<tr>
								<%
									if(null != selectedListRs){
	
										selectedListRs.moveFirst();

										while(selectedListRs.next()){
								%>
											<th style="text-align: center;"><%= selectedListRs.value("label")%></th>
								<%
										}
									}
								%>
								</tr>
								<%

									if(null != selectedListValueRs){

										while(selectedListValueRs.next()){
								%>
											<tr style="cursor: pointer;" onclick="edit_generic_process('<%= parseNull(selectedListValueRs.value("rule_id")) %>','<%= parseNull(selectedListValueRs.value("tid"))%>')">
								<%
											for(int i=0; i < dbColumnCount; i++){
								%>
												<td><%= parseNull(selectedListValueRs.value(i))%></td>
								<%
											}
								%>
											</tr>
								<%
										}
									}
								%>
							</table>
						</div>
						
			    		<input type="hidden" id="edit_generic_process" value="<%=request.getContextPath()%>/editForms.jsp">
			    		<input type="hidden" id="add_demand" value="<%=request.getContextPath()%>/forms.jsp">
			    		<input type="hidden" id="form_name" value="<%=formName%>">
					</form>
				</div> 
			</main>


	</div>

</body>
</html>