<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.*, org.json.*"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<%@ include file="/common.jsp" %>

<%!
	String getQueryStatus(com.etn.beans.Contexte Etn, String qsuuid)
	{
		String status = "NOT_PUBLISHED";

		Set rs = Etn.execute("select case when coalesce(qsp.version, -1) = -1 then 2 when qs.version = coalesce(qsp.version, -1) then 1 else 0 end from query_settings qs left join query_settings_published qsp on qs.qs_uuid = qsp.qs_uuid where qs.qs_uuid = " + escape.cote(qsuuid));
		rs.next();
		if(rs.value(0).equals("0"))
		{
			status = "NEEDS_PUBLISH";
		}
		else if(rs.value(0).equals("1"))
		{
			status = "PUBLISHED";
		}
		return status;
	}
%>

<%
	String siteid = getSelectedSiteId(session);
	boolean isPreview = true;
    String id = parseNull(request.getParameter("id"));

	Set rs = Etn.execute("select qs.*, qt.query_type, qt.query_name as query_category from query_settings qs inner join query_types qt on qs.query_type_id=qt.id where qs.qs_uuid="+escape.cote(id)+" and site_id="+escape.cote(siteid));
	if(rs.rs.Rows == 0)
	{
		response.sendRedirect(request.getContextPath() + "/pages/v2/queries.jsp?msg=Query you trying to view does not belong to selected site");
		return;
	}
	rs.next();

	String _subquerttype = "";
	String _title = rs.value("name");
	if("forms".equals(rs.value("query_category")))
	{
		Set __rs = Etn.execute("select * from "+GlobalParm.getParm("FORMS_DB")+".process_forms where form_id = "+escape.cote(rs.value("query_sub_type_id")));
		if(__rs.next()) _subquerttype = __rs.value("process_name");
	}
	else if("structured_page".equals(rs.value("query_category")))
	{
		if("all".equalsIgnoreCase(rs.value("query_sub_type_id"))) _subquerttype = "All";
		else
		{
			Set __rs = Etn.execute("select s.id as uuid, s.name from " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".bloc_templates s where s.id = "+escape.cote(rs.value("query_sub_type_id")));
			if(__rs.next()) _subquerttype = __rs.value("name");
		}
	}
	else if("stores".equals(rs.value("query_category")))
	{
		if("all".equalsIgnoreCase(rs.value("query_sub_type_id"))) _subquerttype = "All";
		else
		{
			Set __rs = Etn.execute("select s.id as uuid, s.name from " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".bloc_templates s where s.id = "+escape.cote(rs.value("query_sub_type_id")));
			if(__rs.next()) _subquerttype = __rs.value("name");
		}
	}
	else if("structured_content".equals(rs.value("query_category")))
	{
		if("all".equalsIgnoreCase(rs.value("query_sub_type_id"))) _subquerttype = "All";
		else
		{
			Set __rs = Etn.execute("select s.id as uuid, s.name from " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".bloc_templates s where s.id = "+escape.cote(rs.value("query_sub_type_id")));
			if(__rs.next()) _subquerttype = __rs.value("name");
		}
	}
	else if("blocs".equals(rs.value("query_category")))
	{
		if("all".equalsIgnoreCase(rs.value("query_sub_type_id"))) _subquerttype = "All";
		else
		{
			Set __rs = Etn.execute("select s.id as uuid, s.name from " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".bloc_templates s where s.id = "+escape.cote(rs.value("query_sub_type_id")));
			if(__rs.next()) _subquerttype = __rs.value("name");
		}
	}
	else if("subsidies".equals(rs.value("query_category")))
	{
		if("all".equalsIgnoreCase(rs.value("query_sub_type_id"))) _subquerttype = "All";
		else
		{
			Set __rs = Etn.execute("select s.id as uuid, s.name from " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".subsidies s where s.id = "+escape.cote(rs.value("query_sub_type_id")));
			if(__rs.next()) _subquerttype = __rs.value("name");
		}
	}
	else if("deliveryfees".equals(rs.value("query_category")))
	{
		if("all".equalsIgnoreCase(rs.value("query_sub_type_id"))) _subquerttype = "All";
		else
		{
			Set __rs = Etn.execute("select s.id as uuid, s.name from " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".deliveryfees s where s.id = "+escape.cote(rs.value("query_sub_type_id")));
			if(__rs.next()) _subquerttype = __rs.value("name");
		}
	}
	else if("pages".equals(rs.value("query_category")))
	{
		_subquerttype = "All";
	}
	else
	{
		_subquerttype = rs.value("query_sub_type_id");
	}

	String queryType = parseNull(rs.value("query_type"));
	String queryTypeId = parseNull(rs.value("query_type_id"));
	String querySubTypeId = parseNull(rs.value("query_sub_type_id"));
	String queryName = parseNull(rs.value("name"));
	String queryCategory = parseNull(rs.value("query_category"));

	String _colSettings = rs.value("column_settings");
	if(_colSettings.length() == 0) _colSettings = "{}";
    JSONObject columnSettings = new JSONObject(_colSettings);
	
	String _selectedCols = rs.value("selected_columns");
	if(_selectedCols.length() == 0) _selectedCols = "[]";	
	JSONArray selectedColumns = new JSONArray(_selectedCols);
	
	List<String> selectedColumnsList = new ArrayList<String>();
	for(int _i=0;_i<selectedColumns.length();_i++)
	{
		if(parseNull(selectedColumns.optString(_i)).length()> 0) selectedColumnsList.add(parseNull(selectedColumns.optString(_i)));
	}
	
	String _filterSettings = rs.value("filter_settings");
	if(_filterSettings.length() == 0) _filterSettings = "[]";
	JSONArray filterSettings = new JSONArray(_filterSettings);
	
	String _sortSettings = rs.value("sorting_settings");
	if(_sortSettings.length() == 0) _sortSettings = "[]";	
	JSONArray sortingSettings = new JSONArray(_sortSettings);

	Map<String, String> dbs = new HashMap<String, String>();
	//in products query we have catalog_db and preprod_catalog_db reference .. when admin mode these both 
	//will be same but in public mode it will be different
	dbs.put("preprod_catalog_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_CATALOG_DB"));
	dbs.put("catalog_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_CATALOG_DB"));
	dbs.put("portal_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_PORTAL_DB"));
	dbs.put("commons_db", com.etn.beans.app.GlobalParm.getParm("COMMONS_DB"));
	dbs.put("shop_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_SHOP_DB"));

    List<String> columnList = new ArrayList<String>();

    if(queryCategory.equals("forms"))
	{
		columnList = getFormSelectableCols(Etn, querySubTypeId);
    } 
	else 
	{
    	columnList = getSelectableColumns(Etn, queryCategory,querySubTypeId);
	}
	
	List<String> filterColumns = new ArrayList<String>();

	List<String> unselectedColList = new ArrayList<String>();
	for(String _col : columnList)
	{
		filterColumns.add(escape.cote(_col));
		if(selectedColumnsList.contains(_col) ||  _col.startsWith("$")) continue;
		unselectedColList.add(_col);
	}
	
	//sort both lists and merge them again
	selectedColumnsList.sort( Comparator.comparing( String::toString ) ); 
	unselectedColList.sort( Comparator.comparing( String::toString ) ); 
	
	if(!"forms".equals(rs.value("query_category")))
	{
		columnList.clear();
		columnList.addAll(selectedColumnsList);
		columnList.addAll(unselectedColList);
	}
    
	int noOfAvailableColumns = columnList.size();
	String pageNo = parseNull(request.getParameter("pageNo"));
	
	String queryStatus = getQueryStatus(Etn, id);
	String vStatusColor = "danger";
	if(queryStatus.equals("PUBLISHED")) vStatusColor = "success";
	else if(queryStatus.equals("NEEDS_PUBLISH")) vStatusColor = "warning";
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

	<title>Edit Query</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
	<link rel="stylesheet" href="<%=request.getContextPath()%>/pages/css/v2/jquery.json-viewer.css">
	<script src="<%=request.getContextPath()%>/pages/js/v2/jquery.json-viewer.js"></script>
	<script>
		function random(length) {
			if(!length) length = 5;
			var result           = '';
			var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
			var charactersLength = characters.length;
			for ( var i = 0; i < length; i++ ) {
			  result += characters.charAt(Math.floor(Math.random() * 
							charactersLength));
		   }
		   return result;
		}
	</script>
</head>

<%
breadcrumbs.add(new String[]{"Tools", ""});
breadcrumbs.add(new String[]{"Queries", "queries.jsp"});
breadcrumbs.add(new String[]{"Edit Query", ""});
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
			<!-- Title + buttons -->
			<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
				<h1 class="h2">Edit Query : <%=escapeCoteValue(_title)%><span style="height: 25px; width: 25px; border-radius: 50%; border: 1px solid rgb(221, 221, 221); display: inline-block; vertical-align: middle; margin-left: 15px; user-select: auto;" class="bg-<%=vStatusColor%>"></span></h1>
				<div class="btn-toolbar mb-2 mb-md-0">
					<div class="btn-toolbar mb-2 mb-md-0 mt-2">
						<div class="btn-group mr-2">
							<a href='<%=GlobalParm.getParm("EXPERT_SYSTEM_WEB_APP")%>pages/v2/queries.jsp' class="btn btn-primary" >Back</a>
						</div>

						<button class="btn btn-primary "  data-toggle="modal" data-target="#edit_query_modal"><i data-feather="settings"></i></button>
					</div>
				</div>
			</div>

			<div class="row">
				<div class="col-sm-4">
					<div class="card border-dark mb-3 h-100">
						<div class="card-header font-weight-bold">Type of item</div>
						<div class="card-body text-dark">

							<select class="custom-select mb-2" disabled>
									<option value="" selected><%=queryType%></option>
							</select>
							<label class="custom-control custom-radio">
								<input type="radio" class="custom-control-input" autocomplete="off" checked disabled>
								<span class="custom-control-label"><%=_subquerttype%></span>
							</label>
						</div>
						<div class="card-footer text-right">
							<!--<button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#modal-new-querry-s1">Edit</button>-->
						</div>
					</div>
				</div>
				<div class="col-sm-4">

					<div class="card border-dark mb-3 h-100">
						<div class="card-header font-weight-bold">List of fields</div>
						<div class="card-body text-dark">

							<label class="custom-control custom-checkbox">
								<input type="checkbox" class="custom-control-input" autocomplete="off" <%=(noOfAvailableColumns==selectedColumns.length()?"checked":"")%> disabled>
								<span class="custom-control-label">All</span>
							</label>
                        <%
                            for(int i = 0; i<noOfAvailableColumns; i++){

                        %>
							<label class="custom-control custom-checkbox">
								<input type="checkbox" class="custom-control-input" autocomplete="off" <%=(selectedColumnsList.contains(columnList.get(i).toLowerCase())?"checked":"")%> disabled>
								<span class="custom-control-label"><%=columnList.get(i).toLowerCase()%></span>
							</label>
                        <%
                            if(i>3) break;
                        }

                        if(noOfAvailableColumns>5){

                        %>
							<label>
								<%=noOfAvailableColumns-5%> more
							</label>
                        <%}%>
						</div>
						<div class="card-footer text-right">
							<button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#modal-new-querry-s2">Edit</button>
						</div>
					</div>
				</div>
				<div class="col-sm-4">
					<div class="card border-dark mb-3 h-100">
						<div class="card-header font-weight-bold">Filter criterias</div>
						<div class="card-body text-dark">
							<h2 style="font-size:14px">Filtering criterias</h2>
							<%
								for(int i=0; i<filterSettings.length(); i++){
							%>
									<label class="custom-control custom-checkbox">
										<input type="checkbox" class="custom-control-input" autocomplete="off" checked disabled>
										<span class="custom-control-label"><%=filterSettings.optJSONObject(i).optString("filter_column_name")%> <%=filterSettings.optJSONObject(i).optString("filter_type")%> <%=filterSettings.optJSONObject(i).optString("filter_value")%>  <i class="nav-icon feather-16 text-danger <%=(filterSettings.optJSONObject(i).optString("is_variable").equals("1")?"":"d-none")%>" data-feather="check"></i></span>
									</label>
							<%
								}
							%>

							<h2 style="font-size:14px; margin-top:30px">Sorting criterias</h2>
							<%
								for(int i=0; i<sortingSettings.length(); i++){
							%>
									<label class="custom-control custom-checkbox">
										<input type="checkbox" class="custom-control-input" autocomplete="off" checked disabled>
										<span class="custom-control-label"><%=sortingSettings.optJSONObject(i).optString("sort_column_name")%> = sort <%=(sortingSettings.optJSONObject(i).optString("sort_type").equals("asc")?"ascending":"descending")%></span>
									</label>
							<%
								}
							%>
						</div>
						<div class="card-footer text-right">
							<button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#modal-new-querry-s3">Edit</button>
						</div>
					</div>
				</div>
			</div>
				<!-- code source -->
			<style>
				p.options label {
				  margin-right: 10px;
				}
				p.options input[type=checkbox] {
				  vertical-align: middle;
				}
				textarea#json-input {
				  width: 100%;
				  height: 200px;
				}
				pre#json-renderer {
				  border: 1px solid #aaa;
				  background-color:#fff;
				}
			</style>

			<div class="border mt-3">
				<textarea id="json-input" autocomplete="off" style="display:none">
				<%
				try{

					String finalJson = getJSONPlainStructureFromQuery(Etn, siteid, id, pageNo, dbs, false, isPreview);
					finalJson = finalJson.replaceAll("&quot;","\\\\\"");
			//			System.out.println(finalJson);
					out.write(finalJson);

				}catch(Exception e){
					e.printStackTrace();
				}
				%>
				</textarea>
			</div>
			<div style='color:orange; font-weight:bold'>Results below are limit to max 10 records</div>
			<pre id="json-renderer"></pre>
		</main>
		<!-- /main container -->
	</div>	
	<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>


	<div class="modal fade" id="modal-new-querry-s2" tabindex="-1" role="dialog" aria-hidden="true">
		<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header bg-lg1">
					<h5 class="modal-title font-weight-bold" id="exampleModalLabel">List of fields</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">×</span>
					</button>
				</div>
				<div class="modal-body">
					<div class="mb-3 text-right">
						<button type="button" class="btn btn-primary" onclick="updateColumnSettings()">Save</button>
					</div>
					<table class="table table-hover" id="table-pages">
					<thead class="thead-dark">
						<tr>
							<th scope="col"><input id="select_all_columns" type="checkbox" <%=(noOfAvailableColumns==selectedColumns.length()?"checked":"")%>></th>
							<th scope="col">Column Name</th>
					
						</tr>
					</thead>
					<tbody>
						<%
							for(int i = 0; i<noOfAvailableColumns; i++){
						%>
						<tr>
							<th scope="row"><input type="checkbox" name="query_column_name" class="query_column_names" value="<%=columnList.get(i).toLowerCase()%>" <%=(columnSettings.has(columnList.get(i).toLowerCase())?"checked":"")%>></th>
							<td><%=columnList.get(i).toLowerCase()%></td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>





				</div>
			</div>
		</div>
	</div>
<!-- modal list of existing blocs -->

	<div class="modal fade" id="modal-new-querry-s3" tabindex="-1" role="dialog" aria-hidden="true">
		<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header bg-lg1">
					<h5 class="modal-title font-weight-bold" id="exampleModalLabel">Set filtering and sorting criterias</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">×</span>
					</button>
				</div>
				<div class="modal-body">
					<div class="mb-3 text-right">
						<button type="button" class="btn btn-primary" onclick="updateFilterSettings()">Save</button>
					</div>

					<form style="padding:20px">

							<h2>Filtering criterias:</h2>

							<div id="filter_container"></div>
					        <div id='filter_error' style="display: inline-block;" class='invalid-feedback d-none'>Same rule added multiple times.</div>


							<div class="mt-0 text-right">
								<button type="button" class="btn btn-success" onclick="addFilter()">Add a rule</button>
							</div>

							<h2>Sorting criterias:</h2>
							<div id="sorting_container">

                                                        </div>
							<div class="mt-0 text-right">
								<button type="button" class="btn btn-success" onclick="addSort()">Add a rule</button>
							</div>




						</form>



				</div>
			</div>
		</div>
	</div>

        <!-- modal list of existing blocs -->

	<div class="modal fade" id="edit_query_modal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel3" aria-hidden="true">
		<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header bg-lg1">
					<h5 class="modal-title font-weight-bold" id="exampleModalLabel">Parameters of query</h5>
					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">×</span>
					</button>
				</div>
				<div class="modal-body">

					<div class="mb-3 text-right">
						<button type="button" class="btn btn-primary" onclick="updateQuerySettings()">Save</button>
					</div>
					<form style="padding:20px">

							<div class="form-group row pageFieldRowName">
								<label class="col-sm-3 col-form-label">Query name</label>
								<div class="col-sm-9">
									<input id="edit_name" type="text" class="form-control" name="name" value="<%=rs.value("name")%>" maxlength="100" required="required">
									<div class="invalid-feedback">
										Cannot be empty
									</div>
								</div>
							</div>
							<div class="form-group row pageFieldRowName">
								<label class="col-sm-3 col-form-label">Query ID</label>
								<div class="col-sm-9">
									<input id="edit_query_id" type="text" class="form-control" name="query_id" value="<%=rs.value("query_id")%>" disabled maxlength="100" required="required">
									<div class="invalid-feedback">
										Cannot be empty
									</div>
								</div>
							</div>
							<div class="form-group row">
								<label for="edit_access" class="col-sm-3 col-form-label">Access</label>
								<div class="col-sm-9">
									<select id="edit_access" class="custom-select" >
										<option>-- Access --</option>
										<option value="private" <%=("private".equals(rs.value("access"))?"selected":"")%>>Private</option>
										<option value="public" <%=("public".equals(rs.value("access"))?"selected":"")%>>Public</option>
									</select>
								</div>
							</div>
							<div class="form-group row pageFieldRowName">
								<label class="col-sm-3 col-form-label">Querry key</label>
								<div class="col-sm-9">
									<input id="edit_query_key" type="text" value="<%=rs.value("query_key")%>" class="form-control" disabled maxlength="100" required="required">
									<div class="invalid-feedback">
										Cannot be empty
									</div>
								</div>
							</div>
							<div class="form-group row">
								<label for="edit_query_format" class="col-sm-3 col-form-label">Format</label>
								<div class="col-sm-9">
									<select class="custom-select" id="edit_query_format" >
                                                                        <%
                                                                            Set rsQueryFormats = Etn.execute("select id, type from query_formats;");
                                                                            while(rsQueryFormats.next()){
                                                                        %>
                                                                            <option value="<%=rsQueryFormats.value("id")%>" <%=(rsQueryFormats.value("id").equals(rs.value("query_format"))?"selected":"")%>><%=rsQueryFormats.value("type")%></option>
                                                                        <%}%>
									</select>
								</div>
							</div>

							<div class="form-group row">
								<label for="edit_paginate" class="col-sm-3 col-form-label">Paginate</label>
								<div class="col-sm-9">
								<div class="input-group mb-3">
								  <div class="input-group-prepend">
									<div class="input-group-text">
									  <input id="edit_paginate" type="checkbox" <%=(rs.value("paginate").equals("1")?"checked":"")%>>
									</div>
								  </div>
								  <input id="edit_items_per_page" type="text" value="<%=rs.value("items_per_page")%>" class="form-control" placeholder="number of items per page">
								</div>
								</div>
							</div>



						</form>



				</div>
			</div>
		</div>
	</div>


<script type="text/javascript">
    var currentQuery = '<%=id%>';
    var selectedColumns = <%=_selectedCols%>;
    var filterColumns = <%=filterColumns%>;
    var filterSettings = <%=_filterSettings%>;
    var sortingSettings = <%=_sortSettings%>;
    var filterColumnName = false;
    var filterColumnType = false;
	var columnNameFilters = {};
	var columnTypeFilters = {};
	var filters = {};
	var filterArray = [];

    jQuery(document).ready(function() {
        feather.replace();
        // Generate on click
        $('#btn-json-viewer').click(renderJson);

        // Generate on option change
        $('p.options input[type=checkbox]').click(renderJson);

        // Display JSON sample on page load
        renderJson();

        validateFilter = function(){

			filters = {};
			$("#filter_container").children().each(function(){

				if($(this).find(".filter_column_name").val()+"_"+$(this).find(".filter_type").val() in filters){

					filters[$(this).find(".filter_column_name").val()+"_"+$(this).find(".filter_type").val()] = filters[$(this).find(".filter_column_name").val()+"_"+$(this).find(".filter_type").val()] + 1;

				} else {

					filters[$(this).find(".filter_column_name").val()+"_"+$(this).find(".filter_type").val()] = 1;
				}
			});
        }

        $('#filter_container').html("");
        $('#sorting_container').html("");
        for(var i=0; i<filterSettings.length; i++){
            addFilter(filterSettings[i]);
        }

        for(var i=0; i<sortingSettings.length; i++){
            addSort(sortingSettings[i]);
        }

        $("#select_all_columns").change(function () {
            $('input[name="query_column_name"]').prop('checked', $(this).prop("checked"));
        });

		validateFilter();
    });

    function renderJson() {
        //alert($('#json-input').val());
		try {
            var input = eval('(' + $('#json-input').val() + ')');
        }
        catch (error) {
            console.log("Cannot eval JSON");
			return false;
        }
        var options = {
            collapsed: $('#collapsed').is(':checked'),
            rootCollapsable: $('#root-collapsable').is(':checked'),
            withQuotes: $('#with-quotes').is(':checked'),
            withLinks: $('#with-links').is(':checked')
        };
        $('#json-renderer').jsonViewer(input, options);
    }

    function addFilter(obj={filter_column_name:"",filter_type:"",filter_value:"",is_variable:""}){
        var index = random();
        var html = `<div class="input-group mb-2">
                        <input id='filter_column_name_`+index+`' name="filter_column_name" class="form-control ui-autocomplete-input filter_column_name">
                        <select id='filter_type_`+index+`' name="filter_type" class="custom-select filter_type">
                                <option value="" selected>--- Filter rule ---</option>
                                <option value="<">Is less than</option>
                                <option value="<=">Is less than or equal to</option>
                                <option value="=">Is equal to</option>
                                <option value="<>">Is not equal to</option>
                                <option value=">=">Is greater than or equal to</option>
                                <option value=">">Is greater than</option>
								<option value="start">Starts with</option>
								<option value="contains">Contains</option>
								<option value="end">Ends with</option>
                        </select>
                        <input id='filter_value_`+index+`' name="filter_value" type="text" class="form-control ui-autocomplete-input" placeholder="value" value="" autocomplete="off">
                        <div class="input-group-append">
                                <span class="input-group-text" id="inputGroup-sizing-default">Is a variable?</span>
                                <div class="input-group-text">
                                        <input id='is_variable_`+index+`' type="checkbox" name="is_variable"/>
                                </div>
                                <button class="btn btn-danger" type="button" onclick='removeRow(this)'><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                        </div>
                </div>`;
        $('#filter_container').append(html);
        $('#filter_column_name_'+index).val(obj.filter_column_name);
        $('#filter_type_'+index).val(obj.filter_type);
        $('#filter_value_'+index).val(obj.filter_value);
        if(obj.is_variable=="1") $('#is_variable_'+index).prop('checked',true);

		$( '#filter_column_name_'+index ).autocomplete({
                source: filterColumns
		})
		.data( "ui-autocomplete" )._renderItem = function( ul, item ) {
			$(".ui-autocomplete").css("z-index", "1100");
			var newText = String(item.label).replace(
				  new RegExp(this.term, "gi"),
				  "<span class='ui-state-highlight'>$&</span>");

		  return $("<li>")
			  .data("ui-autocomplete-item", item)
			  .append("<a>" + newText + "</a>")
			  .appendTo(ul);
		};

        validateFilter();
    }

    function addSort(obj={sort_column_name:"",sort_type:""}){
        var index = $('select[name="sort_column_name"]').length;
        var selectHtml = "<option value='' selected>--- fields ---</option>";
        for(var i=0; i<selectedColumns.length; i++){
            selectHtml += "<option value='"+selectedColumns[i]+"'>"+selectedColumns[i]+"</option>";
        }
        var html = `<div class="input-group mb-2">
                <select id='sort_column_name_`+index+`' name="sort_column_name" class="custom-select">
                        `+selectHtml+`
                </select>
                <select id='sort_type_`+index+`' name="sort_type" class="custom-select">
                        <option value="" selected>--- Sort rule ---</option>
                        <option value="asc">Sort ascending</option>
                        <option value="desc">Sort descending</option>
                </select>
                <div class="input-group-append">
                        <button class="btn btn-danger" type="button" onclick='removeRow(this)'><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                </div>
        </div>`;
        $('#sorting_container').append(html);
        $('#sort_column_name_'+index).val(obj.sort_column_name);
        $('#sort_type_'+index).val(obj.sort_type);
    }

    function removeRow(element){
        $(element).closest('.input-group').remove();
    }

    function updateQuerySettings(){

    	var params = {
                id: currentQuery,
                name: $("#edit_name").val(),
                path: $("#edit_path").val(),
                access: $("#edit_access").val(),
                query_format: $("#edit_query_format").val(),
                paginate: ($("#edit_paginate").is(':checked')?"1":"0"),
                items_per_page: $("#edit_items_per_page").val()

            };

        $.ajax({
            type :  'POST',
            url :   'calls/updateQuerySettings.jsp',
            data :  params,
            dataType : "json"
        })
        .done(function(resp) {
            $("#edit_query_modal").modal("toggle");
            window.location = window.location;

        })
        .fail(function(resp) {
             alert("Error in contacting server.Please try again.");
        })
        .always(function() {
            //hideLoader();
        });
    }

    function updateFilterSettings(){

		validateFilter();

		for(var val in filters){

			if(filters[val] > 1){
				$("#filter_error").removeClass("d-none");
				return false;
			}
		}

        var filterSettings = [];
        for(var i=0; i<$('input[name="filter_column_name"]').length; i++){
            if($('input[name="filter_column_name"]').eq(i).val()!="" && $('select[name="filter_type"]').eq(i).val()!="" && $('input[name="filter_value"]').eq(i).val()!=""){
                var tempObj = {
                    filter_column_name: $('input[name="filter_column_name"]').eq(i).val(),
                    filter_type: $('select[name="filter_type"]').eq(i).val(),
                    filter_value: $('input[name="filter_value"]').eq(i).val(),
                    is_variable: ($('input[name="is_variable"]').eq(i).is(':checked')?"1":"0")
                };
                filterSettings.push(tempObj);
            }

        }

        var sortingSettings = [];
        for(var i=0; i<$('select[name="sort_column_name"]').length; i++){
            if($('select[name="sort_column_name"]').eq(i).val()!="" && $('select[name="sort_type"]').eq(i).val()!=""){
                var tempObj = {
                    sort_column_name: $('select[name="sort_column_name"]').eq(i).val(),
                    sort_type: $('select[name="sort_type"]').eq(i).val()
                };
                sortingSettings.push(tempObj);
            }

        }

        $.ajax({
            type :  'POST',
            url :   'calls/updateQuerySettings.jsp',
            data :  {
                id: currentQuery,
                filter_settings: JSON.stringify(filterSettings),
                sorting_settings: JSON.stringify(sortingSettings)

            },
            dataType : "json"
        })
        .done(function(resp) {
            window.location = window.location;

        })
        .fail(function(resp) {
             alert("Error in contacting server.Please try again.");
        })
        .always(function() {
            //hideLoader();
        });
    }

    function updateColumnSettings(){
        selectedColumns = [];
        var columnSettings = {};
        for(var i=0; i<$('input[name="query_column_name"]').length; i++){
            if($('input[name="query_column_name"]').eq(i).is(':checked')){
                var value = $('input[name="query_column_name"]').eq(i).val();
                var label = $('input[name="query_column_label"]').eq(i).val();
                selectedColumns.push(value);
                columnSettings[value] = "";
            }
        }

    	var params = {
                id: currentQuery,
                selected_columns: JSON.stringify(selectedColumns),
                column_settings: JSON.stringify(columnSettings)
            };


        $.ajax({
            type :  'POST',
            url :   'calls/updateQuerySettings.jsp',
            data :  params,
            dataType : "json"
        })
        .done(function(resp) {
            window.location = window.location;

        })
        .fail(function(resp) {
             window.status = "Error in contacting server.Please try again.";
        })
        .always(function() {
            //hideLoader();
        });
    }

</script>

</body>
</html>