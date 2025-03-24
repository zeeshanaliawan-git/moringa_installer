<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, java.net.*, java.util.*, com.etn.beans.app.GlobalParm"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="common.jsp"%>


<%
	String selectedsiteid = getSelectedSiteId(session);
	Set rssite = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PORTAL_DB")+".sites where id = " + escape.cote(selectedsiteid));
	String sitename = "";
	if(rssite.next()) sitename = parseNull(rssite.value("name"));

	String fid = parseNull(request.getParameter("fid"));

	String formName = parseNull(request.getParameter("fname"));

	String isprod = parseNull(request.getParameter("isprod"));
	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";

	Set langs = Etn.execute("select * from "+dbname+"language order by langue_id " );
	ArrayList<String> langids = new ArrayList<String>();

	String gotopage = "libmsgs.jsp";
	
	String msg = "";
	String dc = parseNull(request.getParameter("dc"));
	if(dc.length() > 0)
	{
		msg = dc + " row(s) deleted";
	}

%>
<!DOCTYPE html>

<html>
<head>
<meta charset="UTF-8">
	<title>Translations</title>
<script>
	function onsave()
	{
		document.forms[0].submit();
	}
	
	function ondelete()
	{
		if(confirm("Are you sure to delete all un-used words/phrases?"))
		{
			$("#delflag").val("1");
			$("#efrm").submit();
		}
	}
	function onReloadTranslation(){
		$.ajax({
            url: 'reloadalltranslations.jsp', type: 'POST',
        })
	}
</script>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"Translations", ""});
%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">

	<!-- title -->
		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">Translations</h1>
				<p class="lead"></p>
			</div>

			<% if(!"1".equals(isprod)) { %>
			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-success" onclick='onReloadTranslation()'>Reload Translatiions</button>
				</div>
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-danger" onclick='ondelete()'>Delete unused</button>	
				</div>
				<div class="btn-group" role="group" aria-label="...">
					<button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
				</div>
				<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Translations');" title="Add to shortcuts">
					<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
				</button>
			</div>
			<!-- /buttons bar -->
			<% } %>
		</div><!-- /d-flex -->
	<!-- /title -->

	<!-- container -->
	<div class="">
		<div class="animated fadeIn">
			<!-- messages zone  -->
			<div class='m-b-20'>
				<!-- info -->
				<div class="alert alert-danger" role="alert" id="smsg" style="display:none"><%=escapeCoteValue(msg)%></div>
			</div><!-- /message zone --></div>

			<div>
			<form name='efrm' id='efrm' method='post' action='savelibmsgs.jsp' >
			<input type='hidden' name='delflag' id='delflag' value='0'>
				<table class="table table-hover table-vam m-t-20" id="table-items" style="width: 100%;table-layout: fixed;word-wrap:break-word;">
					<thead class="thead-dark">
						<tr class="bg-table">
							<th>&nbsp;</th>
							<% int _r = 1;
							while(langs.next()) {
								langids.add(""+_r);
								_r++;
							%>
								<th style="text-align: center;text-transform: uppercase;"><%=escapeCoteValue(parseNull(langs.value("langue")))%></th>
							<% } %>
						</tr>
					</thead>


					<tbody >
					<% 
						String disabled = "";
						if("1".equals(isprod)) disabled = "disabled";
						List<String> languerefs = null;

						String qry = "select * from "+dbname+"langue_msg where 1=1 ";
						//this should only be for preprod case
						if(languerefs != null && !"1".equals(isprod))
						{
							String inclause = "";
							for(String lf : languerefs)
							{
								if(parseNull(lf).length() == 0) continue;
								//we just making sure to insert the missing labels into db first
								Set _rs = Etn.execute("select * from langue_msg where LANGUE_REF = " + escape.cote(parseNull(lf)));
								if(_rs.rs.Rows == 0 ) Etn.execute("insert into langue_msg (LANGUE_REF) values ("+escape.cote(parseNull(lf))+") ");
								if(parseNull(inclause).length() > 0) inclause += ",";
								inclause += escape.cote(parseNull(lf));
							}
							if(parseNull(inclause).length() > 0) qry += " and LANGUE_REF in ("+inclause+") ";
						}
						qry += " order by LANGUE_REF ";


						Set rs = Etn.execute(qry);
						int _row = 0;
						while(rs.next()) {
						String color = "";
						if(_row++ % 2 != 0) color = "background:#eee;";
					%>
						<tr>
							<td style='<%=color%>'><%=escapeCoteValue(parseNull(rs.value("LANGUE_REF")))%><input type='hidden' name='LANGUE_REF' value='<%=escapeCoteValue(parseNull(rs.value("LANGUE_REF")))%>' /></td>
							<% for(String id : langids) {
								if("0".equals(id)) continue; %>
							<td  style='<%=color%>'><input type='text' <%=disabled%> name='LANGUE_<%=id%>' class="form-control input" style="width:100%" maxlength='255' value='<%=escapeCoteValue(parseNull(rs.value("LANGUE_" + id)))%>' /></td>
							<% } %>
						</tr>
					<% } %>
					</tbody>
				</table>
			</form>
		</div>

		<br>
		<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
		</div>
	</div> <!-- /container -->
</main>

	<%@ include file="/WEB-INF/include/footer.jsp" %>
</div> <!-- /c-body -->


<script>
	/* Create an array with the values of all the input boxes in a column */
	$.fn.dataTable.ext.order['dom-text'] = function  ( settings, col )
	{
		return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {
			return $('input', td).val();
		} );
	}

	/* Create an array with the values of all the input boxes in a column, parsed as numbers */
	$.fn.dataTable.ext.order['dom-text-numeric'] = function  ( settings, col )
	{
		return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {
			return $('input', td).val() * 1;
		} );
	}

	/* Create an array with the values of all the select options in a column */
	$.fn.dataTable.ext.order['dom-select'] = function  ( settings, col )
	{
		return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {
			return $('select', td).val();
		} );
	}

	/* Create an array with the values of all the checkboxes in a column */
	$.fn.dataTable.ext.order['dom-checkbox'] = function  ( settings, col )
	{
		return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {
			return $('input', td).prop('checked') ? '1' : '0';
		} );
	}

	jQuery(document).ready(function() {
		
		<%if(msg.length() >0){
			out.write("$('#smsg').show();\n");
			out.write("setTimeout(function(){$('#smsg').fadeOut();}, 2000);\n");
		}%>

		$('[data-toggle="tooltip"]').tooltip();
		$('[data-toggle="popover"]').popover();

		$('#table-items').DataTable( {
			"autoWidth": false,
			"lengthMenu": [[50, 100, -1], [50, 100, "All"]],
			"iDisplayLength": 50,
			"columnDefs": [
				{ "width": "30%", "targets": 0 }
				<%
					int wth = 70/langs.rs.Rows;
					int _t = 1;
					langs.moveFirst();
					while(langs.next()) {
				%>
					,{ "width": "<%=wth%>%", "targets": <%=_t%> }
				<% } %>
			],
			"columns": [
				null,
				<%
					langs.moveFirst();
					while(langs.next()) {
				%>
					{ "orderDataType": "dom-text", type: 'string' },
				<% } %>
			]
		} );


		refreshscreen=function()
		{
			window.location = "<%=gotopage%>";
		}

	});
</script>
</body>
</html>
