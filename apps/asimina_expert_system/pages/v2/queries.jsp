<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
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
	Set rsSite = Etn.execute("select * from "+GlobalParm.getParm("PREPROD_PORTAL_DB")+".sites where id ="+escape.cote(siteid));
	rsSite.next();
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

	<title>Queries</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

	<%
		breadcrumbs.add(new String[]{"Tools", ""});
		breadcrumbs.add(new String[]{"Queries", ""});
	%>

	<script src="<%=request.getContextPath()%>/pages/js/v2/perfect-scrollbar.js"></script>
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
	<style>
		.autocomplete-items {
			width: 100%;
			padding: 0.375rem 1.75rem 0.375rem 0.75rem;
			font-size: .875rem;
			font-weight: 400;
			line-height: 1.5;
			border: 1px solid;
			border-radius: 0.5rem;
			color: #768192;
			background: #fff;
			border-color: #d8dbe0;
		}
		.autocomplete-items>li{
			border-bottom: none !important;
			padding:0px 10px;
		}
		.autocomplete-items>li:hover{
			background:#39f !important;
			color: white;
			padding:0px 10px;
  			cursor: pointer;
		}
	</style>
</head>

<body class="c-app" style="background-color:#efefef">
	<%@ include file="/WEB-INF/include/sidebar.jsp" %>
	<div class="c-wrapper c-fixed-components">
		<%@ include file="/WEB-INF/include/header.jsp" %>
		<div class="c-body">
        	<main class="c-main"  style="padding:0px 30px">
				<!-- Title + buttons -->
				<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
					<h1 class="h2">Queries</h1>
					<div class="btn-toolbar mb-2 mb-md-0">
						<div class="btn-toolbar mb-2 mb-md-0 mt-2">
							<div class="btn-group mr-2"><a href='<%=GlobalParm.getParm("GESTION_URL")%>' class="btn btn-primary" >Back</a></div>
							<div class="btn-group mr-2">
								<button class="btn btn-danger" onclick="onpublish()">Publish</button>
								<button class="btn btn-danger" onclick="onunpublish()">Unpublish</button>
							</div>
							<button class="btn btn-success mr-2" data-toggle="modal" data-target="#modal-new-querry">Add a query</button>
							<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Queries');" title="Add to shortcuts">
                                <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                            </button>
						</div>
					</div>
				</div>
				<!-- /Title + buttons -->

				<table class="table table-hover" id="table-pages">
					<thead class="thead-dark">
						<tr>
							<th scope="col"><input type="checkbox" class="" id="sltall"></th>
							<th scope="col">Query name</th>
							<th scope="col">Query ID</th>
							<th scope="col">Path</th>
							<th scope="col">Last changes</th>
							<th scope="col" style="width:180px">Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
							Set rs = Etn.execute("select qs.*, lg.name AS last_updated_by from query_settings qs LEFT OUTER JOIN login lg on lg.pid = qs.updated_by where site_id="+escape.cote(siteid));

							String queryStatus = "";
							String qsuuid = "";
							String rowColor = "";

							while(rs.next()){

								qsuuid = parseNull(rs.value("qs_uuid"));
								queryStatus = getQueryStatus(Etn, qsuuid);
								rowColor = "";

								if("NOT_PUBLISHED".equals(queryStatus)) rowColor = "danger"; //red
								else if("NEEDS_PUBLISH".equals(queryStatus)) rowColor = "warning"; //orange
								else rowColor = "success"; //green
						%>
						<tr class="table-<%=rowColor%>">
							<th scope="row"><input type="checkbox" class="slt_option" value="<%=qsuuid%>"></th>
							<td><strong><%=rs.value("name")%></strong></td>
							<td><strong><%=rs.value("query_id")%></strong></td>
							<td>
								<%if("NOT_PUBLISHED".equals(queryStatus) == false){%>
									Option 1 : <a target="_blk" href="<%=com.etn.beans.app.GlobalParm.getParm("ES_API_V2_URL")%>fetchdata.jsp?qid=<%=qsuuid%>"><%=com.etn.beans.app.GlobalParm.getParm("ES_API_V2_URL")%>fetchdata.jsp?qid=<%=qsuuid%></a>
									<br>
									<br>
									Option 2 : <a target="_blk" href="<%=com.etn.beans.app.GlobalParm.getParm("ES_API_V2_URL")%>fetchdata.jsp?cid=<%=java.net.URLEncoder.encode(rs.value("query_id"),"utf8")%>&suid=<%=rsSite.value("suid")%>" class="custom-tooltip" data-toggle="tooltip" title="If you are using this url inside javascript, then use variable ______suid or asmPageInfo.suid for the value of parameter suid in the url to make things more dynamic"><%=com.etn.beans.app.GlobalParm.getParm("ES_API_V2_URL")%>fetchdata.jsp?cid=<%=rs.value("query_id")%>&suid=<%=rsSite.value("suid")%></a>
									&nbsp;<a href="#" class="custom-tooltip" data-toggle="tooltip" title="If you are using this url inside javascript, then use variable ______suid or asmPageInfo.suid for the value of parameter suid in the url to make things more dynamic"><i data-feather="info"></i></a>
								<%}%>
							</td>
							<td>
								<% 
									if(parseNull(rs.value("updated_on")).length() >0) { 
										out.write("<span style='color:green'>On</span>: "+parseNull(rs.value("updated_on")) +
										"<br><span style='color:green'>By</span>: "+parseNull(rs.value("last_updated_by")));
									}
									else{out.write("&nbsp;");}
								%>
							</td>
							<td class="text-right">
								<button class="btn btn-sm btn-primary " onclick="window.location.href='editQuery.jsp?id=<%=qsuuid%>'"><i data-feather="edit"></i></button>
								<button class="btn btn-sm btn-primary " onclick="editQuerySettings('<%=qsuuid%>')"><i data-feather="settings"></i></button>
								<button class="btn btn-sm btn-primary " onclick="copyQueryUuid('<%=qsuuid%>')" data-toggle="modal" data-target="#copy_query_modal"><i data-feather="copy"></i></button>
								<% if("NOT_PUBLISHED".equals(queryStatus)){%>
								<button class="btn btn-sm btn-danger " onclick="deleteQuerySettings('<%=qsuuid%>','deleteQuerySettings')"><i data-feather="x"></i></button>
								<%}%>
							</td>
						</tr>
					<%}%>
					</tbody>
				</table>
			</main>
		</div>
		<div class="modal fade" id="modal-new-querry" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel3" aria-hidden="true">
			<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
				<div class="modal-content" style="height: 100vh;">
					<div class="modal-header bg-lg1">
						<h5 class="modal-title font-weight-bold" id="exampleModalLabel">Step 1 : define parameters of the querry</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">×</span>
						</button>
					</div>
					<div class="modal-body">
						<form style="padding:20px">

							<div class="form-group row pageFieldRowName">
								<label class="col-sm-3 col-form-label is-required">Query name</label>
								<div class="col-sm-9">
									<input id="name" type="text" class="form-control" name="name" value="" maxlength="100" required="required" onchange='onQueryNameChange(this)'>
									<div class="invalid-feedback d-none" style="display: block;">
										Query name is mandatory.
									</div>
								</div>
							</div>
							<div class="form-group row pageFieldRowName">
								<label class="col-sm-3 col-form-label is-required">Query ID</label>
								<div class="col-sm-9">
									<input id="query_id" type="text" class="form-control" name="query_id" value="" maxlength="100" required="required" onkeyup="onKeyUpQueryId(this)" onblur="onKeyUpQueryId(this)">
									<div class="invalid-feedback d-none" style="display: block;">
										Query id is mandatory.
									</div>
								</div>
							</div>
							<div class="form-group row">
								<label for="access" class="col-sm-3 col-form-label">Access</label>
								<div class="col-sm-9">
									<select id="access" class="custom-select" >
										<option value>-- Access --</option>
										<option value="public" selected="">Public</option>
										<option value="private">Private</option>
									</select>
								</div>
							</div>
							<div class="form-group row">
								<label for="query_format" class="col-sm-3 col-form-label">Format</label>
								<div class="col-sm-9">
									<select class="custom-select" id="query_format"  >
										<%
											Set rsQueryFormats = Etn.execute("select id, type from query_formats;");
											while(rsQueryFormats.next()){
										%>
											<option value="<%=rsQueryFormats.value("id")%>" ><%=rsQueryFormats.value("type")%></option>
										<%}%>
									</select>
								</div>
							</div>
							<div class="form-group row">
								<label class="col-sm-3 col-form-label">Paginate</label>
								<div class="col-sm-9">
								<div class="input-group mb-3">
								  <div class="input-group-prepend">
									<div class="input-group-text">
									  <input id="paginate" type="checkbox" aria-label="Checkbox for following text input">
									</div>
								  </div>
								  <input id="items_per_page" type="text" class="form-control" aria-label="Text input with checkbox" placeholder="number of items per page">
								</div>
								</div>
							</div>
						</form>
					</div>
					<div class="modal-footer">
						<div class="text-right">
							<button type="button" class="btn btn-primary" onclick="gotoStep(2, 'next')">Next</button>
						</div>
					</div>
				</div>
			</div>
		</div>

		<!-- modal list of existing blocs -->

		<div class="modal fade" id="modal-new-querry1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel3" aria-hidden="true">
			<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
				<div class="modal-content" style="height: 100vh;">
					<div class="modal-header bg-lg1">
						<h5 class="modal-title font-weight-bold" id="exampleModalLabel">Step 2 : what do you want to extract?</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">×</span>
						</button>
					</div>
					<div class="modal-body">
						<form style="padding:20px">
							<div class="form-group row">
								<label class="col-sm-4 col-form-label is-required">Type </label>
								<div class="col-sm-8">
									<select class="custom-select" id="query_type">
										<option value="" selected>-- Select --</option>
										<%
											Set rsQueryTypes = Etn.execute("select * from query_types order by query_type");
											while(rsQueryTypes.next()){
										%>
												<option qname='<%=rsQueryTypes.value("query_name")%>' value="<%=rsQueryTypes.value("id")%>" >
													<%=rsQueryTypes.value("query_type")%>
												</option>
										<%
											}
										%>
									</select>
									<div class="invalid-feedback d-none" style="display: block;">
										Type is mandatory.
									</div>
									<input type="hidden" value="select" id="item_status">
								</div>
							</div>
							
							<div id="sub_type_items"></div>
								
							<div id="query_sub_type_error" class="invalid-feedback d-none" style="display: block;"></div>

							<div class="form-group row d-none">
								<label for="structure_catalog" class="col-sm-4 col-form-label">Structure catalog</label>
								<div id="structure_catalog" class="col-sm-8" style="height: 310px; overflow: auto;"> </div>
							</div>
						</form>
					</div>

					<div class="modal-footer">
						<div class="col-sm-12 text-right">
							<button type="button" class="btn btn-primary" onclick="gotoStep(2, 'back');">Back</button>
							<button type="button" class="btn btn-primary" onclick="gotoStep(3, 'next');">Next</button>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- /modal list of existing blocs -->

		<!-- modal list of existing blocs -->

		<div class="modal fade" id="modal-new-querry2" tabindex="-1" role="dialog" aria-hidden="true">
			<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
				<div class="modal-content" style="height: 100vh;">
					<div class="modal-header bg-lg1">
						<h5 class="modal-title font-weight-bold" id="exampleModalLabel">Step 3 : which fields do you want to extract?</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">×</span>
						</button>
					</div>
					<div class="modal-body d-flex overflow-hidden" style="flex-direction:column">
						<form class="d-flex" style="
							flex-direction:column;
							flex-shrink: 1;
							flex-grow: 0;
							flex-basis: 100%;overflow: hidden;">
							<div class="row">
								<label for="inputPassword"  class="col-6 col-form-label is-required">Available columns</label>
								<div id="query_column_names_error" class="col-6 invalid-feedback d-none text-right" style="display: block;">
									Column is mandatory.
								</div>
							</div>
							<div class="flex-grow-1 flex-shrink-1 overflow-auto">

								<table class="table table-sm table-hover" style="flex-basis:inherit;overflow: auto;">
									<tbody id="query_column_names"></tbody>
								</table>
							</div>
							
						</form>
					</div>
					<div class="modal-footer">
						<div class="col-sm-12 text-right mt-2">
							<button type="button" class="btn btn-primary" onclick="gotoStep(3, 'back');">Back</button>
							<button type="button" class="btn btn-primary" onclick="gotoStep(4, 'next');">Next</button>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- /!\modal list of existing blocs -->

		<!-- modal list of existing blocs -->

		<div class="modal fade" id="modal-new-querry3" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel3" aria-hidden="true">
			<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
				<div class="modal-content" style="height: 100vh;">
					<div class="modal-header bg-lg1">
						<h5 class="modal-title font-weight-bold" id="exampleModalLabel">Step 4 : which filtering and sorting do you want to apply to your querry?</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">×</span>
						</button>
					</div>
					<div class="modal-body">
						<form style="padding:20px; height: 450px; overflow: auto;">
							<h2>Filtering criterias:</h2>
							<div id="filter_container">
								<div class="input-group mb-2">
									<select  name="filter_column_name" class="custom-select">
										<option value="" selected>--- fields ---</option>
										<option value="">id</option>
										<option value="">manufacturer</option>
										<option value="">...</option>
									</select>
									<select name="filter_type" class="custom-select">
										<option value="" selected>--- Filter rule ---</option>
										<option value="<">Is less than</option>
										<option value="<=">Is less than or equal to</option>
										<option value="=">Is equal to</option>
										<option value="<>">Is not equal to</option>
										<option value=">=">Is greater than or equal to</option>
										<option value=">">Is greater than</option>
										<option value="<">Is between</option>
										<option value=">">Is not between</option>
									</select>
									<input name="filter_value" type="text" class="form-control ui-autocomplete-input" placeholder="value" value="" autocomplete="off">
									<div class="input-group-append">
										<span class="input-group-text">Is a variable?</span>
										<div class="input-group-text">
											<input type="checkbox" name="is_variable"/>
										</div>
										<button class="btn btn-danger" type="button" onclick="removeRow(this);"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
									</div>
								</div>
							</div>
							<div id="filter_error" style="display: inline-block;" class="invalid-feedback d-none">Same rule added multiple times.</div>
							<div class="mt-0 text-right">
								<button type="button" class="btn btn-success" onclick="addFilter()" >Add a rule</button>
							</div>

							<h2>Sorting criterias:</h2>
							<div id="sorting_container">
								<div class="input-group mb-2">
									<select name="sort_column_name" class="custom-select">
										<option value="" selected>--- fields ---</option>
										<option value="sku">id</option>
										<option value="product">manufacturer</option>
										<option value="product">product name</option>
										<option value="product">...</option>
									</select>
									<select name="sort_type" class="custom-select">
										<option value="" selected>--- Sort rule ---</option>
										<option value="asc">Sort ascending</option>
										<option value="desc">Sort descending</option>
									</select>
									<div class="input-group-append">
										<button class="btn btn-danger" type="button" onclick="removeRow(this)"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
									</div>
								</div>
							</div>
							<div class="mt-0 text-right">
								<button type="button" class="btn btn-success" onclick="addSort()" >Add a rule</button>
							</div>
							<div class="mt-5 text-right">
							</div>
						</form>
					</div>
					<div class="modal-footer">
						<div class="col-sm-12 text-right">
							<button type="button" class="btn btn-primary" onclick="gotoStep(4, 'back');">Back</button>
							<button type="button" class="btn btn-primary" onclick="saveQuerySettings()">Save</button>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- /!\modal list of existing blocs -->
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
									<input id="edit_name" type="text" class="form-control" name="name" value="list of accessories" maxlength="100" required="required">
									<div class="invalid-feedback">
										Cannot be empty
									</div>
								</div>
							</div>
							<div class="form-group row pageFieldRowName">
								<label class="col-sm-3 col-form-label">Query ID</label>
								<div class="col-sm-9">
									<input id="edit_query_id" type="text" class="form-control" name="query_id" value="list-of-accessories" disabled maxlength="100" required="required">
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
										<option value="private" selected="">Private</option>
										<option value="public">Public</option>
									</select>
								</div>
							</div>
							<div class="form-group row pageFieldRowName">
								<label class="col-sm-3 col-form-label">Querry key</label>
								<div class="col-sm-9">
									<input id="edit_query_key" type="text" class="form-control" disabled maxlength="100" required="required" onchange="onChangePageName(this)">
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
											rsQueryFormats.moveFirst();
											while(rsQueryFormats.next()){
										%>
												<option value="<%=rsQueryFormats.value("id")%>" selected=""><%=rsQueryFormats.value("type")%></option>
										<%
											}
										%>
									</select>
								</div>
							</div>

							<div class="form-group row">
								<label class="col-sm-3 col-form-label">Paginate</label>
								<div class="col-sm-9">
									<div class="input-group mb-3">
										<div class="input-group-prepend">
											<div class="input-group-text">
												<input id="edit_paginate" type="checkbox" aria-label="Checkbox for following text input">
											</div>
										</div>
										<input id="edit_items_per_page" type="text" class="form-control" aria-label="Text input with checkbox" 
											placeholder="number of items per page">
									</div>
								</div>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
		<!-- /!\modal list of existing blocs -->

		<!-- modal list of copy query -->

		<div class="modal fade" id="copy_query_modal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel3" aria-hidden="true">
			<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
				<div class="modal-content">
					<div class="modal-header bg-lg1">
						<h5 class="modal-title font-weight-bold" id="exampleModalLabel">Copy of query</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">×</span>
						</button>
					</div>
					<div class="modal-body">

						<div class="mb-3 text-right">
							<button type="button" class="btn btn-primary" onclick="copyQuerySettings()">Save</button>
						</div>

						<form style="padding:20px">
							<div class="form-group row pageFieldRowName">
								<input type="hidden" id="selected_qsuuid" value="">
								<label class="col-sm-3 col-form-label">Query name</label>
								<div class="col-sm-9">
									<input id="copy_name" type="text" class="form-control" name="copy_name" value="" maxlength="100" required="required">
									<div class="invalid-feedback">
										Cannot be empty
									</div>
								</div>
							</div>
							<div class="form-group row pageFieldRowName">
								<label class="col-sm-3 col-form-label">Query ID</label>
								<div class="col-sm-9">
									<input id="copy_query_id" type="text" class="form-control" name="copy_query_id" value="" maxlength="100" required="required">
									<div class="invalid-feedback">
										Cannot be empty
									</div>
								</div>
							</div>
							<div class="form-group row">
								<label for="access" class="col-sm-3 col-form-label">Access</label>
								<div class="col-sm-9">
									<select id="copy_access" class="custom-select" >
										<option value>-- Access --</option>
										<option value="private" selected="">Private</option>
										<option value="public">Public</option>
									</select>
								</div>
							</div>
							<div class="form-group row">
								<label for="copy_query_format" class="col-sm-3 col-form-label">Format</label>
								<div class="col-sm-9">
									<select class="custom-select" id="copy_query_format"  >
										<%
											rsQueryFormats = Etn.execute("select id, type from query_formats;");
											while(rsQueryFormats.next()){
										%>
												<option value="<%=rsQueryFormats.value("id")%>" ><%=rsQueryFormats.value("type")%></option>
										<%
											}
										%>
									</select>
								</div>
							</div>

							<div class="form-group row">
								<label class="col-sm-3 col-form-label">Paginate</label>
								<div class="col-sm-9">
									<div class="input-group mb-3">
										<div class="input-group-prepend">
											<div class="input-group-text">
												<input id="copy_paginate" type="checkbox" aria-label="Checkbox for following text input">
											</div>
										</div>
										<input id="copy_items_per_page" type="text" class="form-control" aria-label="Text input with checkbox" 
											placeholder="number of items per page">
									</div>
								</div>
							</div>
						</form>

					</div>
				</div>
			</div>
		</div>
	<!-- modal list of copy query -->
	<%@ include file="/WEB-INF/include/footer.jsp" %>


    <script type="text/javascript">

        var currentQuery = null;
        var selectedColumns = null;
        var allColumns = [];
		
		jQuery(document).ready(function() {
			$('[data-toggle="tooltip"]').tooltip();
			feather.replace();

			$('#table-pages').DataTable( {
				"responsive": true,
				"pageLength": 50,
				"lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
				"order": [[ 1, "asc" ]]
			} );

			$("#query_type").change(function() {
				$("#structure_catalog").parent().addClass("d-none");

				let selectedVal = $("#query_type").val();
				let selectedName = $(this).find("option:selected").attr("qname");

				let displaySubType="";
				if(selectedName=="forms"){
					displaySubType="Forms";
				} else if(selectedName=="structured_page"){
					displaySubType="Structure catalog";
				} else if(selectedName=="structured_content"){
					displaySubType="Structure content";
				} else if(selectedName=="stores"){
					displaySubType="Stores";
				} else {
					displaySubType="Sub types";
				}

				$("#query_sub_type_error").html("");

				$("#sub_type_items").html('');

				let htmlTxt=`<div id="query_sub_type_\${selectedVal}" class="form-group row query_sub_type">
			 					<label class="col-sm-4 col-form-label is-required" id=sub_type_label>\${displaySubType}</label>
								<div class="col-sm-8" id='subTypeDiv'></div>
							</div>`;
				
				$("#sub_type_items").append(htmlTxt);
				addSubTypeInput("#query_sub_type_"+selectedVal,selectedVal,selectedName);
			});

		});

		function addSubTypeInput(subDivId,selectedVal,selectedName){
			let inputCount=0;
			let isValidTypeForBtn = ("blocs,forms,products,subsidies,deliveryfees".indexOf($('option:selected', $("#query_type")).attr('qname')) === -1);
			if($(subDivId+" .autocomplete_input:last").attr("id") && isValidTypeForBtn){
				inputCount = parseInt($(subDivId+" .autocomplete_input:last").attr("id").split("_").pop())+1;
			}

			let mgTop = '';
			let inputRemoveBtn = '';

			if(inputCount>0){
				mgTop='mt-3';
				inputRemoveBtn =`<div role="button" class="btn btn-sm btn-danger ml-auto" title="Remove select" onclick="removeInput(this,'\${subDivId}','\${selectedVal}','\${selectedName}')">
						<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" 
						stroke-linecap="round" stroke-linejoin="round" class="feather feather-x"><line x1="18" y1="6" x2="6" y2="18"></line>
						<line x1="6" y1="6" x2="18" y2="18"></line></svg></div>`;
			}
			
			let htmlTxt=`<div class="typc \${mgTop}" style="display: flex; align-items: center;">
							<div class="position-relative w-100">
								<input style="margin-right: 3px;" class="form-control autocomplete_input" type="text" placeholder="--Select--" autocomplete="off" id="autocomplete_input_\${inputCount}">
								<ul class="autocomplete-items p-0 ml-4" id="subTypeList_\${inputCount}" style="list-style-type:none;display:none;max-height:140px;"></ul>
							</div>
							<input type="text" name="query_sub_type" value="" hidden>
						</div>\${inputRemoveBtn}`;
				
			$("#subTypeDiv").append(htmlTxt);
			// if(($(subDivId+" #addSubBtn").length==0) ){
			// 	$(subDivId).append(`<div role='button' id='addSubBtn' class='btn btn-primary ml-auto mt-3' onclick="addSubTypeInput('\${subDivId}','\${selectedVal}','\${selectedName}')">Add a Sub Type</div>`);
			// }

			// if($(subDivId+" .autocomplete_input").length>=3 || !isValidTypeForBtn){
			// 	if($("#addSubBtn")){
			// 		$("#addSubBtn").remove();
			// 	}
			// }

			$.ajax({
				url : "queriesAjax.jsp",
				data : {
					"queryTypeName":selectedName,
					"queryTypeId":selectedVal,
				},
				dataType : 'json',
				method : 'post',
				success : function (response) {
					if(response.status==0){
						var options = "";
						if(response.data.length>1){
							options += "<li value='All' data-value='All'><a style='cursor:pointer;' >All</a>";
						}
						
						response.data.forEach(function(item) {
							options += "<li data-value='"+item.id+"' value='" + item.name + "'>"+item.name;
						});

						$("#subTypeList_"+inputCount).append(options);

						$(".autocomplete-items li").on("mousedown",function(){
							$(this).parents(".autocomplete-items").css("display","none");
							$(this).parents(".typc").find(".autocomplete_input").val($(this).attr("value"));
							$(this).parents(".typc").find("[name=query_sub_type]").val($(this).attr("data-value"));
						});

						$(".autocomplete_input").on("blur",function(){
							$(this).next().css("display","none");
						});

						$(".autocomplete_input").on("focus",function(){
							$(this).next().css("display","");
							var inputField = $(this);
							var inputValue = $(this).val().toLowerCase();
							$(".autocomplete-items li").each(function() {
								
								var option = $(this);
								var optionText = option.text().toLowerCase();

								if (optionText.indexOf(inputValue) > -1) {
									option.show();
								} else {
									option.hide();
								}
							});
						})

						$(".autocomplete_input").on("input", function() {
							$(this).next().css("display","");
							var inputField = $(this);
							var inputValue = $(this).val().toLowerCase();
							$(".autocomplete-items li").each(function() {
								
								var option = $(this);
								var optionText = option.text().toLowerCase();

								if (optionText.indexOf(inputValue) > -1) {
									option.show();
								} else {
									option.hide();
								}
							});
						});
					}
				}
			});
		}

		function removeInput(button,subDivId,selectedVal,selectedName){
			button.previousElementSibling.remove(); 
			button.remove();
			if($(subDivId+" #addSubBtn").length==0){
				$(subDivId).append(`<div role='button' id='addSubBtn' class='btn btn-primary ml-auto mt-3' onclick="addSubTypeInput('`+
					subDivId+`','`+selectedVal+`','`+selectedName+`')">Add a Sub Type</div>`);
			}
		}
		
		function onQueryNameChange(name)
		{
			name = $(name);
			var form = name.parents('form:first');
			customId = form.find('[id=query_id]');

			if(name.val().trim().length > 0 && customId.length > 0 && customId.prop('readonly') == false)
			{
				customId.val(name.val().trim()).trigger('keyup');
			}			
		}
		
		function onKeyUpQueryId(input)
		{
			var val = $(input).val();

			var startWithDigitRegex = new RegExp(/^\d/);
			while (startWithDigitRegex.test(val)) {
				val = val.substring(1);
			}

			val = val.replace(/\s+/g, "_").replace(/[^a-zA-Z0-9_]/g, '').toLowerCase();

			//custom id should not end with _<number>
			while (true) {
				if (val.lastIndexOf("_") >= 0) {
					var testStr = val.substring(val.lastIndexOf("_"));
					if (/_[\d]+$/g.test(testStr)) {
						val = val.substring(0, val.lastIndexOf("_"));
					}
					else {
						break;
					}
				}
				else {
					break;
				}
			}

			$(input).val(val);			
		}

        function gotoStep(stepNumber, action){

        	if(stepNumber == 2){
				
				var flag = false;

				if($("#name").val() == ""){

					$("#name").next().removeClass("d-none");
					flag = true;

				} else{

					$("#name").next().addClass("d-none");
				}

				if($("#query_id").val() == "")
				{
					$("#query_id").next().html("Query ID is mandatory");
					$("#query_id").next().removeClass("d-none");
					flag = true;

				} else{

					$("#query_id").next().addClass("d-none");
				}

				if(!flag && 'next' === action)//we must verify the query id from db to make sure its unique across the site
				{
					$.ajax({
						url : "calls/verifyqueryid.jsp",
						data : { qid : $("#query_id").val() },
						dataType : 'json',
						method : 'post',
						success : function (json) {
							if(json.status == 1)
							{
								$("#query_id").next().html("Query ID must be unique across the site");
								$("#query_id").next().removeClass("d-none");
								flag = true;
							}
							else
							{
								$("#query_id").next().addClass("d-none");
								$("#modal-new-querry1").modal("toggle");
								$("#modal-new-querry").modal("hide");
							}							
						}
					});
				}

				if(!flag && 'next' !== action) 
				{
					$("#modal-new-querry").modal("toggle");
					$("#modal-new-querry1").modal("hide");
				}

        	}
            else if(stepNumber == 3){


				var flag = false;

				if($("#query_type").val() == ""){

					$("#query_type").next().removeClass("d-none");
					return false;

				} else {

					$("#query_type").next().addClass("d-none");
				}

				var querySubTypeInput = $("#query_sub_type_" + $("#query_type").val() + " input[name=query_sub_type]");
				var selectedOption = $('option:selected', $("#query_type"));
				var querySubTypeError = $("#query_sub_type_error");

				if (querySubTypeInput.length == 0) {
					if (selectedOption.attr('qname') == "structured_page") {
						querySubTypeError.html("Structure catalog is mandatory.");
					} else if (selectedOption.attr('qname') == "stores") {
						querySubTypeError.html("Store is mandatory.");
					} else if (selectedOption.attr('qname') == "structured_content") {
						querySubTypeError.html("Structure content is mandatory.");
					} else if (selectedOption.attr('qname') == "forms") {
						querySubTypeError.html("Form is mandatory.");
					} else {
						querySubTypeError.html("Sub type is mandatory.");
					}

					querySubTypeError.removeClass("d-none");
					return false;
				} else{
					querySubTypeError.addClass("d-none");
				}

				if(!flag){

					if(action == "next"){

		                $("#modal-new-querry2").modal("toggle");
						$("#modal-new-querry1").modal("hide")
		                // var query_sub_type = $('input[name="query_sub_type"]').val();
						// if(query_sub_type!="") getColumnNames(query_sub_type);
						$('input[name="query_sub_type"]').each(function() {
		                	getColumnNames($(this).val());
						});

					} else if(action == "back") {

						$("#modal-new-querry2").modal("hide");
						$("#modal-new-querry1").modal("toggle");
					}
				}
            }
            else if(stepNumber == 4){

				var flag = false;

				if($("#query_column_names input[type=checkbox]:checked").length == 0){

					$("#query_column_names_error").removeClass("d-none");
					return false;

				} else {

					$("#query_column_names_error").addClass("d-none");
				}

				if(!flag){

					if(action == "next"){

		                $("#modal-new-querry3").modal("toggle");
		                $("#modal-new-querry2").modal("hide");
		                selectedColumns = [];
		                var selectAll = false;
		                $(".query_column_names").each(function() {
							if($(this).val() == "All" && $(this).is(":checked")) selectAll = true;
		                    else if(selectAll || $(this).is(":checked")){
								var value = $(this).val();
		                        selectedColumns.push(value);
		                    }
		                });
		                $('#filter_container').html("");
		                $('#sorting_container').html("");
		                addFilter();
		                addSort();

					} else if(action == "back") {

		                $("#modal-new-querry3").modal("hide");
		                $("#modal-new-querry2").modal("toggle");
					}
				}
            }
        }

		function getSelectColumn(val){
			let html =
				`<tr>
					<td>
						<label class="custom-control custom-checkbox mb-0">
							<input type="checkbox" class="custom-control-input query_column_names" autocomplete="off" value="`+val+`">
							<span class="custom-control-label">`+val+`</span>
						</label>
					</td>					
				</tr>`;

			return html;
		}

		function addCustomColumn(){
			let customCol = $("#input_custom_column").val();
			if(customCol){
				let html = getSelectColumn(customCol);
				$("#query_column_names").append(html);
			}
			$("#input_custom_column").val("");
		}

        function getColumnNames(query_sub_type){


	        var params = {
	                query_sub_type: query_sub_type,
	                query_type: $('option:selected', $("#query_type")).attr('qname')
	        };

			if($('option:selected', $("#query_type")).attr('qname') == "structured_page" || $('option:selected', $("#query_type")).attr('qname') == "structured_content" || $('option:selected', $("#query_type")).attr('qname') == "stores"){

				params.suuid = $("input[name='structure_catalog']:checked").val();
			}

            $.ajax({
                type :  'POST',
                url :   'calls/getColumnNames.jsp',
                data :  params,
                dataType : "json"
            })
            .done(function(resp) {
                var html = "";
                for(var i = 0; i<resp.length; i++){
					if(!resp[i].startsWith("$")){
						html+= getSelectColumn(resp[i]);
					}
					allColumns.push(resp[i]);
                }
                $("#query_column_names").html(html);
            })
            .fail(function(resp) {
                 alert("Error in contacting server.Please try again.");
            })
            .always(function() {
            });
        }

        function editQuerySettings(id){
            $.ajax({
                type :  'POST',
                url :   'calls/getQuerySettings.jsp',
                data :  {id: id},
                dataType : "json"
            })
            .done(function(resp) {
                currentQuery = id;
                $("#edit_name").val(resp.name);
                $("#edit_query_id").val(resp.query_id);
                $("#edit_access").val(resp.access);
                $("#edit_query_key").val(resp.query_key);
                $("#edit_query_format").val(resp.query_format);
                if(resp.paginate=="1") $("#edit_paginate").prop("checked",true);
                else $("#edit_paginate").prop("checked",false);
                $("#edit_items_per_page").val(resp.items_per_page);
                $("#edit_query_modal").modal("toggle");

            })
            .fail(function(resp) {
                 alert("Error in contacting server.Please try again.");
            })
            .always(function() {
            });
        }

        function deleteQuerySettings(id, requestType){
        	if(!confirm("Are you sure to delete the query?"))
        		return false;

            $.ajax({
                type :  'POST',
                url :   'calls/deleteQuerySettings.jsp',
                data :  {
					id: id,
					requestType: requestType
				}
            })
            .done(function(resp) {
				var responseData = JSON.parse(resp);

				if(responseData.status == "SUCCESS"){
					bootNotify(responseData.message);
					setTimeout(function() {
						window.location.reload();
					}, 2000);
					
				}else if(responseData.status !== "SUCCESS" && requestType == "deleteQuerySettings"){
					bootConfirm(responseData.message, function(result){
						if(result){
							deleteQuerySettings(id,"forceDeleteQuerySettings");
						}
					});

				}else{
					bootAlert(responseData.message);
				}
            })
            .fail(function(resp) {
                 alert("Error in contacting server.Please try again.");
            })
            .always(function() {
            });
        }

        function updateQuerySettings(){
            $.ajax({
                type :  'POST',
                url :   'calls/updateQuerySettings.jsp',
                data :  {
                    id: currentQuery,
                    name: $("#edit_name").val(),
                    access: $("#edit_access").val(),
                    query_format: $("#edit_query_format").val(),
                    paginate: ($("#edit_paginate").is(':checked')?"1":"0"),
                    items_per_page: $("#edit_items_per_page").val()

                },
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
            });
        }

        function copyQueryUuid(qsuuid){

        	$("#selected_qsuuid").val(qsuuid);
        }

        function copyQuerySettings(){
            $.ajax({
                type :  'POST',
                url :   'calls/copyQuerySettings.jsp',
                data :  {
                    id:   $("#selected_qsuuid").val(),
                    name: $("#copy_name").val(),
                    query_id: $("#copy_query_id").val(),
                    access: $("#copy_access").val(),
                    query_format: $("#copy_query_format").val(),
                    paginate: ($("#copy_paginate").is(':checked')?"1":"0"),
                    items_per_page: $("#copy_items_per_page").val()

                },
                dataType : "html"
            })
            .done(function(resp) {
                $("#copy_query_modal").modal("toggle");
                window.location = window.location;

            })
            .fail(function(resp) {
                 alert("Error in contacting server.Please try again.");
            })
            .always(function() {
            });
        }

        function addFilter(){
			var columnFieldId = random();
            var html = `<div class="input-group mb-2">
                            <input id="` + columnFieldId + `" name="filter_column_name" class="form-control ui-autocomplete-input filter_column_name">                                    
                            <select name="filter_type" class="custom-select filter_type">
								<option value="" selected>--- Filter rule ---</option>
								<option value="<">Is less than</option>
								<option value="<=">Is less than or equal to</option>
								<option value="=">Is equal to</option>
								<option value="<>">Is not equal to</option>
								<option value=">=">Is greater than or equal to</option>
								<option value=">">Is greater than</option>
								<option value="<">Is between</option>
								<option value=">">Is not between</option>
								<option value="start">Starts With</option>
								<option value="contains">Contains</option>
								<option value="end">Ends With</option>
                            </select>
                            <input name="filter_value" type="text" class="form-control ui-autocomplete-input" placeholder="value" value="" autocomplete="off">
                            <div class="input-group-append">
								<span class="input-group-text" id="inputGroup-sizing-default">Is a variable?</span>
								<div class="input-group-text">
										<input type="checkbox" name="is_variable"/>
								</div>
								<button class="btn btn-danger" type="button" onclick="removeRow(this)"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                            </div>
                    </div>`;
            $('#filter_container').append(html);			
			$( "#" + columnFieldId ).autocomplete({
                source: allColumns
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
        }

        function addSort(){
            var selectHtml = "<option value='' selected>--- fields ---</option>";
            for(var i=0; i<selectedColumns.length; i++){
                selectHtml += "<option value='"+selectedColumns[i]+"'>"+selectedColumns[i]+"</option>";
            }
            var html = `<div class="input-group mb-2">
                    <select name="sort_column_name" class="custom-select">
                            `+selectHtml+`
                    </select>
                    <select name="sort_type" class="custom-select">
                            <option value="" selected>--- Sort rule ---</option>
                            <option value="asc">Sort ascending</option>
                            <option value="desc">Sort descending</option>
                    </select>
                    <div class="input-group-append">
                            <button class="btn btn-danger" type="button" onclick="removeRow(this)"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                    </div>
            </div>`;
            $('#sorting_container').append(html);
        }

        function saveQuerySettings(){

			var filters = {};
			$("#filter_container").children().each(function(){

				if($(this).find(".filter_column_name").val()+"_"+$(this).find(".filter_type").val() in filters){

					filters[$(this).find(".filter_column_name").val()+"_"+$(this).find(".filter_type").val()] = filters[$(this).find(".filter_column_name").val()+"_"+$(this).find(".filter_type").val()] + 1;

				} else {

					filters[$(this).find(".filter_column_name").val()+"_"+$(this).find(".filter_type").val()] = 1;
				}
			});

			for(var val in filters){

				if(filters[val] > 1){
					$("#filter_error").removeClass("d-none");
					return false;
				}
			}

            var filterSettings = [];
            for(var i=0; i<$('input[name="filter_column_name"]').length; i++){
                if($('select[name="filter_column_name"]').eq(i).val()!="" && $('select[name="filter_type"]').eq(i).val()!="" && $('input[name="filter_value"]').eq(i).val()!=""){
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

            var columnSettings = {};
            for(var i=0; i<selectedColumns.length; i++){
                columnSettings[selectedColumns[i]]="";
            }

            if($("#query_type").val() == "2" || $("#query_type").val() == "3"){

            	columnSettings.suuid = $("input[name='structure_catalog']:checked").val();
            }

            $.ajax({
                type :  'POST',
                url :   'calls/saveQuerySettings.jsp',
                data :  {
                    site_id: <%=siteid%>,
                    query_id: $("#query_id").val(),
                    query_type_id: $("#query_type").val(),
                    query_sub_type_id: $('input[name="query_sub_type"]').val(),
                    name: $("#name").val(),
                    access: $("#access").val(),
                    query_format: $("#query_format").val(),
                    paginate: ($("#paginate").is(':checked')?"1":"0"),
                    items_per_page: $("#items_per_page").val().length>0?$("#items_per_page").val():0,
                    selected_columns: JSON.stringify(selectedColumns),
                    filter_settings: JSON.stringify(filterSettings),
                    sorting_settings: JSON.stringify(sortingSettings),
                    column_settings: JSON.stringify(columnSettings)
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

		$("#sltall").click(function()
		{
			if($(this).is(":checked"))
			{
				$(".slt_option").each(function(){$(this).prop("checked",true)});
			}
			else
			{
				$(".slt_option").each(function(){$(this).prop("checked",false)});
			}
		});

		$(".slt_option").click(function()
		{
			$("#sltall").prop("checked",false);
		});

        function onpublish(){

			if ($(".slt_option:checked").length > 0)
			{
				var ids = "";
				$(".slt_option").each(function(){
					if($(this).is(":checked") == true) ids += $(this).val() + ",";
				});
				if(ids.length > 0) ids = ids.substr(0, ids.length-1);
                $.ajax({
                    type :  'POST',
                    url :   'calls/publish.jsp',
                    data :  {
                    	uuid: ids
                    },
                    dataType : "html"
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
			else
			{
				alert("No items selected");
			}
        }

        function onunpublish(){

			if ($(".slt_option:checked").length > 0)
			{
				if(confirm("Are you sure to unpublish seleted queries?"))
				{
					var ids = "";
					$(".slt_option").each(function(){
						if($(this).is(":checked") == true) ids += $(this).val() + ",";
					});
					if(ids.length > 0) ids = ids.substr(0, ids.length-1);
					
					$.ajax({
						type :  'POST',
						url :   'calls/unpublish.jsp',
						data :  {
							uuid: ids
						},
						dataType : "html"
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
			}
			else
			{
				alert("No items selected");
			}
        }

	    function removeRow(element){

	        $(element).closest('.input-group').remove();
	    }

    </script>

</body>
</html>