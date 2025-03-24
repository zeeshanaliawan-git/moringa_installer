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

<%

	Set destPageRs = Etn.execute("SELECT DISTINCT destination_page FROM dest_page_settings;");
	Set destPageFilterRs = Etn.execute("SELECT dps.destination_page, dps.auto_screen, dpf.* FROM dest_page_filters dpf, dest_page_settings dps WHERE dpf.dest_page_id = dps.id;");

%>
		<div class="container">
		<div style='text-align:center'><h2>Expert system screens</h2></div>
		<center>

			<div class="form-horizontal" role="form" style="padding: 15px; background: #eee; border-radius: 6px; margin-bottom: 15px;">
				
				<div id="createUserFilterMainDiv">				

					<div class="row"> 
						<div class="col-xs-12 col-sm-6"> 
							<div class="form-group"> 
								<label class="col-sm-3">Dest. page : </label> 
								<div class="col-sm-9"> 
									<select name="destination_page" id="destination_page" class="form-control"> 
										<option value="">---select---</option>
						<%
									while(destPageRs.next()){
						%>
										<option value='<%= parseNull(destPageRs.value("destination_page")).replaceAll(" ", "_")%>'><%= parseNull(destPageRs.value("destination_page"))%></option>
						<%
									}
						%>
									</select>
								</div> 
							</div> 
						</div> 
					</div> 

					<div class="row"> 
						<div class="col-xs-12 col-sm-6"> 
							<div class="form-group"> 
								<label class="col-sm-3">Display name : </label> 
								<div class="col-sm-9"> 
									<input name="display_name" id="display_name" type="text" class="form-control" placeholder="Display name"> 
								</div> 
							</div> 
						</div> 

						<div class="col-xs-12 col-sm-6"> 
							<div class="form-group"> 
								<label class="col-sm-4">Used as parameter : </label> 
								<div class="col-sm-1"> 
									<input name="used_as_parameter" id="used_as_parameter" type="checkbox"> 
								</div> 
							</div> 
						</div> 
					</div>
				</div>
				
				<div class="row"> 
					<div class="col-xs-12 col-sm-6"> 
						<div class="form-group"> 
							<label class="col-sm-3">Type : </label> 
							<div class="col-sm-9"> 
								<select onchange="user_filter_type(this)" id="user_filter_type" class="form-control"> 
									<option>---select---</option> 
									<option value="textfield" >Textfield</option> 
									<option value="dropdown" >Dropdown</option> 
								</select> 
							</div> 
						</div> 
					</div> 

					<div id="options_query_div" style="display: none;" class="col-xs-12 col-sm-6"> 
						<div class="form-group"> 
							<label class="col-sm-4">Query : </label> 
							<div class="col-sm-1">
								<textarea rows="4" cols="40" name="options_query" id="options_query"> </textarea>
							</div> 
						</div> 
					</div> 
				</div>

				<div class="row">
					<div class="col-sm-12 text-center">
						<div class="" role="group" aria-label="controls">
							<button id="createUserFilterCreate" type="button" class="btn btn-primary">Create</button>
							<input type="hidden" id="step_no" value="1">
							<input type="hidden" id="dest_page_added" value="true">
							<input type="hidden" id="dest_page_id" value="">
						</div>
					</div>
				</div>	
			</div>

			<div id="createdUserFilters" class="row">
				<table class="table table-hover">
					<thead>
						<tr>
							<th>Display name</th>
							<th>Used as parameter</th>
							<th>Destination page</th>
						</tr>
					</thead>
					<tbody>
				<%
						while(destPageFilterRs.next()){
				%>
							<tr>
								<td><%= destPageFilterRs.value("display_name")%></td>
								<td><%= destPageFilterRs.value("used_as_parameter")%></td>
								<td><%= destPageFilterRs.value("destination_page")%></td>
							</tr>
				<%
						}

						if(destPageFilterRs.rs.Rows == 0){
				%>		
							<tr>
								<td>&nbsp;</td>
								<td>No filter(s) found.</td>
								<td>&nbsp;</td>
							</tr>
				<%
						}
				%>
					</tbody>
				</table>
			</div>
		</center>
	</div>

</body>
    <script type="text/javascript">
		jQuery(document).ready(function() {

			user_filter_type = function(element){

				if($(element).val() == "dropdown") $("#options_query_div").css("display", "block");
				else $("#options_query_div").css("display", "none");
			};

		});

    </script> 
</html>	