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
<%@include file="../common2.jsp"%>
<%!
	class SearchFilters
	{
		String id;
		String ftype;
		String fieldId;
		String fieldName;
		String showAsRange;
	}

	class Results
	{
		String id;
		String fieldId;
		String fieldName;
	}

%>

<!DOCTYPE html>

<html>
<head>
	<title>Define filters</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<script type="text/javascript">
	
	$(document).ready(function() {

		goback = function(){

			window.location = "process.jsp";
		}
	});

</script>

</head>
<body class="c-app header-fixed sidebar-fixed sidebar-lg-show">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
<%@ include file="/WEB-INF/include/header.jsp" %>
<div class="c-body">

<%
	String formid = parseNull(request.getParameter("fid"));
    String selectedSiteId = getSelectedSiteId(session);
	
	Set createdFormFilterRs = Etn.execute("SELECT f.form_id, p.table_name, f.field_id, f.label FROM process_form_fields_unpublished f, process_forms p WHERE f.type not in ('label','noneditablefield','button','hr_line', 'multextfield', 'imgupload', 'fileupload', 'emptyblock', 'hyperlink') and p.form_id = f.form_id and f.form_id = " + escape.cote(formid) + " AND label IS NOT NULL AND label != '' ORDER by 1;");

	ArrayList<SearchFilters> filters = new ArrayList<SearchFilters>();
	Set rsF = Etn.execute("SELECT m.id, m.field_id, f.type, f.label, m.show_range, coalesce(m.display_order,0) as display_order FROM form_search_fields m, process_form_fields_unpublished f WHERE f.form_id = m.form_id and f.field_id = m.field_id and m.form_id = " + escape.cote(formid) + " order by coalesce(m.display_order,0) ");
	while(rsF.next())
	{
		SearchFilters fil = new SearchFilters();
		fil.id = parseNull(rsF.value("id"));
		fil.fieldId = parseNull(rsF.value("field_id"));
		fil.fieldName = parseNull(rsF.value("label"));
		fil.showAsRange = parseNull(rsF.value("show_range"));
		fil.ftype = parseNull(rsF.value("type"));
		filters.add(fil);
	}

	ArrayList<Results> resultFields = new ArrayList<Results>();
	rsF = Etn.execute("SELECT  m.id, m.field_id, f.label, coalesce(m.display_order,0) as display_order FROM form_result_fields m, process_form_fields_unpublished f WHERE f.form_id = m.form_id and f.field_id = m.field_id and m.form_id = " + escape.cote(formid) + " order by coalesce(m.display_order,0) ");
	while(rsF.next())
	{
		Results res = new Results();
		res.id = parseNull(rsF.value("id"));
		res.fieldId = parseNull(rsF.value("field_id"));
		res.fieldName = parseNull(rsF.value("label"));
		resultFields.add(res);
	}

	Set rsform = Etn.execute("select * from process_forms where form_id = " + escape.cote(formid));
	rsform.next();

%>	

<main class="c-main"  style="padding:0px 30px">
	<!-- breadcrumb -->
	<%-- <nav aria-label="breadcrumb">
		<ol class="breadcrumb">
			<li class="breadcrumb-item"><a href='<%=GlobalParm.getParm("CATALOG_URL")%>admin/gestion.jsp'>Home</a></li>
			<li class="breadcrumb-item"><a href="<%=request.getContextPath()%>/admin/process.jsp">Processes</a></li>
			<li class="breadcrumb-item active" aria-current="page">Filters</li>
		</ol>
	</nav> --%>
	<!-- /breadcrumb -->
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">Process : <%=escapeCoteValue(rsform.value("process_name"))%>
					
				</h1>
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
			<%
				if(formid.length() == 0)
				{
					Set rs1 = Etn.execute("select * from process_forms where site_id = " + escape.cote(selectedSiteId) + " order by process_name");
					String html = "<div class='col-sm-5'><select class='form-control'  id='sfid' name='fid' ><option value=''>--- Select ---</option>";
					while(rs1.next())
					{
						html += "<option value='"+rs1.value("form_id")+"'>"+rs1.value("process_name")+"</option>";
					}
					html += "</select></div>";
					out.write(html);
					return;
				}
			%>				
				<form name='frm' id='frm' method='post' action='' >

					<div style="margin-top: 50px;" id="created_form_templates" class="row">
						<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">
							<p class="col-sm-6 control-label"> <label>Search criteria fields</label> </p>
							<div style="margin-top: 30px; margin-left: 20px;">
								<table class="table table-striped">
									<tr>									
										<th> Filter name </th>
										<th align='center'> Show Range? </th>
										<th> Delete </th>
									</tr>
									<%

										if(filters.isEmpty()) {
									%>
											<tr><td colspan='3'>No fields selected yet.</td></tr>
									<%
										}

										for(SearchFilters fil : filters)
										{
											boolean chkboxenabled = false;
									%>
											<tr>
												<td>
													<%=escapeCoteValue(fil.fieldName)%>
												</td>
												<td align='center'>											
													<% if(fil.ftype.equalsIgnoreCase("number") || fil.ftype.equalsIgnoreCase("textdate") || fil.ftype.equalsIgnoreCase("textdatetime")) { chkboxenabled = true; } %>
													<input type='checkbox' value='1' id='<%=fil.id+"_chkbox"%>' <%if(!chkboxenabled){%>disabled<%}%>  <%if(fil.showAsRange.equals("1")){%>checked<%}%> onchange="updateRangeFlag(this, '<%=fil.id%>')"/>
												</td>
												<td>
													<span onclick="deleteSearchFilter('<%=fil.id%>')" id='<%=fil.id%>' style="cursor: pointer;" class="btn btn-danger btn-sm"><i data-feather="x"></i></span>
												</td>
											</tr>
									<%
										}
									%>
								</table>
							</div>
							
						</div>
						<div class="col-xs-1 col-sm-1 col-md-1 col-lg-1" style="width: 2%; margin-top: 200px;">
							
							<a onclick="addSearchFilters();" href='#' class="btn btn-primary btn-sm" data-toggle="tooltip" data-placement="top" title="move left"><i data-feather="arrow-left"></i></a>
						</div>
						<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">
							<p class="col-sm-6 control-label"> <label>Available form fields</label> </p>
							<select multiple id="created_form_filters" class="form-control" style="min-height: 500px;">
							<%
								while(createdFormFilterRs.next()){
							%>
									<option value='<%=createdFormFilterRs.value("field_id")%>'><%=createdFormFilterRs.value("label")%></option>
							<%
								}
							%>
							</select>
						</div>
						<div class="col-xs-1 col-sm-1 col-md-1 col-lg-1" style="width: 2%; float: left; margin-top: 200px;">
							<a onclick="addResultFilters();" href='#' class="btn btn-primary btn-sm" data-toggle="tooltip" data-placement="top" title="move left"><i data-feather="arrow-right"></i></a>
						</div>
						<div class="col-xs-3 col-sm-3 col-md-3 col-lg-3">							
							<p class="col-sm-6 control-label"> <label>Result fields</label> </p>
							<div style="margin-top: 30px; margin-left: 20px;">
								<table class="table table-striped">
									<tr>									
										<th> Filter name </th>
										<th> Delete </th>
									</tr>
									<%

										if(resultFields.isEmpty()){
									%>
											<tr><td colspan='2'>No fields selected yet.</td></tr>
									<%
										}

										for(Results res : resultFields) {
									%>
											<tr>
												<td>
													<%=escapeCoteValue(res.fieldName)%>
												</td>
												<td>
													<span onclick="deleteResultFilter('<%=res.id%>')"  id='<%=res.fieldId%>' style="cursor: pointer;" class="btn btn-danger btn-sm"><i data-feather="x"></i></span>
												</td>
											</tr>
									<%
										}
									%>
								</table>
							</div>
						</div>
					</div>
					<input type="hidden" id="fid" value="<%=formid%>">
				</form>
			</div>
			<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
		</div>
	</div>
	<br>

</main>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>
</div>

</body>
</html>
