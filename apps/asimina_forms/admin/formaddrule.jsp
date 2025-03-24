<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ include file="../common2.jsp"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<!DOCTYPE html>

<html>
<head>
	<title>Form designer</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<script type="text/javascript">
	
	$(document).ready(function() {

		goback = function(){

			window.location = "process.jsp";
		}
	});

</script>


</head>
<body class="app header-fixed sidebar-fixed sidebar-lg-show">

<%@ include file="/WEB-INF/include/header.jsp" %>
<div class="c-body">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>

<%
	String formId = parseNull(request.getParameter("fid"));
	Set processRs = Etn.execute("SELECT field_id, label FROM process_form_fields WHERE form_id = " + escape.cote(formId) + " AND type NOT IN ( " + escape.cote("label") + "," + escape.cote("noneditablefield") + "," + escape.cote("hr_line") + "," + escape.cote("multextfield") + "," + escape.cote("emptyblock") + "," + escape.cote("hyperlink") + "," + escape.cote("imgupload") + "," + escape.cote("button") + "," + escape.cote("fileupload") + ")");

	Set freqRuleRs = Etn.execute("SELECT fr.*, pff.label FROM freq_rules fr LEFT OUTER JOIN process_form_fields pff ON fr.form_id = pff.form_id AND fr.field_id = pff.field_id WHERE fr.form_id = " + escape.cote(formId));

%>

<main class="c-main">
	<!-- breadcrumb -->
	<%-- <nav aria-label="breadcrumb">
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a href='<%=GlobalParm.getParm("CATALOG_URL")%>admin/gestion.jsp'>Home</a></li>
			<li class="breadcrumb-item"><a href="<%=request.getContextPath()%>/admin/process.jsp">Processes</a></li>
			<li class="breadcrumb-item active" aria-current="page">Rule</li>
		</ol>
	</nav> --%>
	<!-- /breadcrumb -->
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">Add rule</h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-primary" id="saveBtn" onclick='goback()'>Back</button>
				</div>
			</div>
			<!-- /buttons bar -->
		</div>
	<!-- /title -->

	<!-- container -->
	<div class="container-fluid">
		<div class="animated fadeIn">
			<div>
				<form name='frm' id='frm' method='post' action='' >

					<div class="row" style="padding-top: 20px;">

						<div class="col-sm-12">
							
							<table class="table table-hover table-bordered">
								<thead class="thead-dark">
									<tr>
										<th>Delete</th>
										<th>Field</th>
										<th>Frequency</th>
										<th>Period</th>
										<th>&nbsp;</th>
									</tr>
								</thead>
								<tbody>
									<tr>
										<td>&nbsp;</td>
										<td>
											<select class="form-control" id="form_rule_field" name="form_rule_field">
												<option value="">--- Select ---</option>
												<option value="ip">Ip</option>
										<%
												while(processRs.next()){
										%>
													<option value='<%= parseNull(processRs.value("field_id"))%>'><%= parseNull(processRs.value("label"))%></option>
										<%
												}
										%>
											</select>										
										</td>
										<td>
											<input type="text" name="frequency" id="frequency" value="" class="form-control" />
										</td>
										<td>								
											<select class="form-control" id="period">
												<option value="">---select---</option>
												<option value="daily">Daily</option>
												<option value="weekly">Weekly</option>
												<option value="monthly">Monthly</option>
											</select>
										</td>
										<td>
											<a class="btn btn-primary active" role="button" aria-pressed="true" href="#" onclick="add_rule_field()"> Add</a>
										</td>
									</tr>
								<%
									String label = "";
									String value = "";
									String frequency = "";
									String period = "";
									String fieldId = "";
									String id = "";

									if(freqRuleRs.rs.Rows == 0){
								%>

										<tr>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											<td>No rule found(s).</td>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
										</tr>

								<%
									}
									while(freqRuleRs.next()){
										
										label = parseNull(freqRuleRs.value("label"));
										frequency = parseNull(freqRuleRs.value("frequency"));
										period = parseNull(freqRuleRs.value("period"));
										fieldId = parseNull(freqRuleRs.value("field_id"));
										id = parseNull(freqRuleRs.value("id"));

										if(fieldId.equals("ip")) label = "Ip";
								%>
										
										<tr>
											<td><span id="<%= fieldId%>" style="color: red; cursor: pointer;" onclick="delete_rule_field(this.id)" class="glyphicon glyphicon-remove"></span></td>
											<td><%= label%></td>
											<td>
												<input type="text" name="frequency" id="frequency" value='<%= frequency%>' class="form-control" />
											</td>
											<td>
												<select class="form-control" id="period">
													<option <% if(period.equals("")){%> selected <%} %> value="">---select---</option>
													<option <% if(period.equals("daily")){%> selected <%} %> value="daily">Daily</option>
													<option <% if(period.equals("weekly")){%> selected <%} %> value="weekly">Weekly</option>
													<option <% if(period.equals("monthly")){%> selected <%} %> value="monthly">Monthly</option>
												</select>									
											</td>
											<td>
												<a class="btn btn-primary active" role="button" aria-pressed="true" href="#" onclick="update_rule_field(this, '<%= fieldId%>', '<%= id%>')"> Update</a>								
											</td>
										</tr>

								<%
									}
								%>
								</tbody>
								
							</table>
							<input type="hidden" id="form_id" value="<%= formId%>">
			        		<input type="hidden" id="appcontext" value="<%=request.getContextPath()%>/" />

						</div>
						
					</div>

				</form>
				</div>
				<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
		</div>
	</div>
	<br>

</main>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

</body>
</html>
