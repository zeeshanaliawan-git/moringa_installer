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

<%
	String selectedSiteId = getSelectedSiteId(session);

	Set processRs = Etn.execute("SELECT form_id, process_name FROM process_forms WHERE site_id = " + escape.cote(selectedSiteId) + " ORDER BY 2;");

%>

<!DOCTYPE html>

<html>
<head>
	<title>Search Forms</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<%	
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Search Forms", ""});
%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">Search Forms</h1>
				<p class="lead"></p>
			</div>
			
			<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Search Forms');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>
		</div>
	<!-- /title -->

	<!-- container -->
	<div class="animated fadeIn">
	<div>
	<form name='frm' id='frm' method='post' action='' >
		<table class="table table-hover table-bordered m-t-20" id="resultsdata">
			<thead class="thead-dark">
				<th style="text-align: left;">Form name</th>
				<th style="text-align: left;">Action</th>
			</thead> 


			<tbody>
			<%
				String formName = "";
				String formId = "";
				int i = 0;

				if(processRs.rs.Rows == 0){
			%>
					<tr>
						<td style="font-weight: bold;" colspan='2'>No form available under selected site.</td>
					</tr>
			<%
				}
	
				while(processRs.next()){

					formName = parseNull(processRs.value("process_name"));
					formId = parseNull(processRs.value("form_id"));
					String clr = "";
					
					if(i++ % 2 != 0) clr = "background-color:#eee";
	  			%>

					<tr>
						<td><%=escapeCoteValue(formName)%></td>
						<td style="text-align: center;">
							<a class="btn btn-primary btn-sm" role="button" aria-pressed="true" href='<%= GlobalParm.getParm("FORMS_WEB_APP")%>admin/search.jsp?___fid=<%= formId%>' data-toggle="tooltip" data-placement="top" title="Search"> <i data-feather="search"></i></a>
						</td>
	   				</tr>
				<%
					}//while
				%>
				
			</tbody>
		</table>

		<input type="hidden" id="html_form_page" value="<%=request.getContextPath()%>/admin/htmlFormPage.jsp">
		<input type="hidden" id="edit_html_form_page" value="<%=request.getContextPath()%>/admin/htmlFormPage.jsp">
		<input type="hidden" id="form_translation" value='<%=GlobalParm.getParm("CATALOG_URL")%>admin/libmsgs.jsp?reqtype=pform'>
		<input type="hidden" id="form_add_rule" value='<%= request.getContextPath()%>/admin/formaddrule.jsp'>

	</form>
	</div>
	<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	<br>

</main>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script>
	jQuery(document).ready(function()
	{
		refreshscreen=function()
		{
			window.location = window.location
		};
	});
	function search()
	{
		document.frm.issave.value = "0";
		document.frm.submit();
	}
</script>
</body>
</html>
