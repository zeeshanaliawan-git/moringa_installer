<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.util.ItsDate"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="common.jsp"%>

<%
	String siteid = parseNull(getSiteId(request.getSession()));

	String isprod = parseNull(request.getParameter("isprod"));
	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
	
	String uname = parseNull(request.getParameter("uname"));
	String dfrom = parseNull(request.getParameter("dfrom"));
	String dto = parseNull(request.getParameter("dto"));

	if(dfrom.length() == 0 && dto.length() == 0)
	{
		Set rs = Etn.execute("select date_format(now(), '%d/%m/%Y') t, date_format(adddate(now(), interval -2 day), '%d/%m/%Y') f ");
		rs.next();
		dfrom = parseNull(rs.value("f"));
		dto = parseNull(rs.value("t"));
	}
	
	String q = "select * from "+dbname+"client_usage_logs where site_id = " + escape.cote(siteid);
	if(uname.length() > 0)
	{
		q += " and login like " + escape.cote(uname + "%");
	}
	if(dfrom.length() > 0) 
	{
		long l1 = ItsDate.getDate(dfrom);
		String z1 = ItsDate.stamp(l1);
		q += " and activity_on >= " + escape.cote(z1);
	}
	if(dto.length() > 0)
	{
		long l1 = ItsDate.getDate(dto);
		String z1 = ItsDate.stamp(l1);
		z1 = z1.substring(0,8) + "235959";
		q += " and activity_on <= " + escape.cote(z1);		
	}
	q += " order by activity_on desc ";
	String filteredColumns = "activity_on,login,activity,activity_from,details";
	session.setAttribute("qry",q);
	session.setAttribute("filterCol",filteredColumns);
	Set rsClients = Etn.execute(q);
    
%>

<html>
<head>
	<title>Clients Log</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"System", ""});
if("1".equals(isprod)) breadcrumbs.add(new String[]{"Prod Site", ""});
else breadcrumbs.add(new String[]{"Test Site", ""});
breadcrumbs.add(new String[]{"Clients Log", ""});
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
		<div style="width: 100%;">
			<h1 class="h2 float-left">Clients Log</h1>
			<p class="lead"></p>
		</div>
		<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Clients Log');" title="Add to shortcuts">
			<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
		</button>
	</div>
	<!-- /title -->
		<!-- container -->
	<div class="animated fadeIn">
	<form name='frm' id='frm' action='<%=("1".equals(isprod)?"prodclientslog.jsp":"clientslog.jsp")%>' method='post' >
		<table class="m-t-20" style="margin-bottom:0;" >
			<tr>
				<td>
					<input type='text' value='<%=uname%>' size='50' maxlength='75' name='uname' id="uname" class="form-control" placeholder='Username'/>
				</td>
				<td>
					<input type='text' value='<%=dfrom%>' size='12' maxlength='10' name='dfrom' id="dfrom" class="form-control" placeholder='Activity date from'/>
				</td>
				<td>
					<input type='text' value='<%=dto%>' size='12' maxlength='10' name='dto' id="dto" class="form-control" placeholder='Activity date to'/>
				</td>
				<td>
					<button type='button' onclick='search()' class="btn btn-success" >
					Search
					</button>
				</td>
				<td>
					<a type='button' href="downloadCsv.jsp" class="btn btn-primary" >
					Export CSV
					</a>
				</td>
			</tr>
		</table>
	</form>
		<table id="resultsdata" cellpadding=0 cellspacing=0 border=0 class="table table-hover table-vam m-t-20">
			<thead class="thead-dark">
				<tr>
					<th>Date</th>
					<th>Username</th>
					<th>Activity</th>
					<th>Activity From</th>
					<th>Details</th>
				</tr>
			</thead>
			<%
			while(rsClients.next()){
			%>
			<tr>
				<td><%=parseNull(rsClients.value("activity_on"))%></td>
				<td><%=parseNull(rsClients.value("login"))%></td>
				<td><%=parseNull(rsClients.value("activity"))%></td>
				<td><%=parseNull(rsClients.value("activity_from"))%></td>
				<td><%=parseNull(rsClients.value("details"))%></td>
			</tr>
			<%
			}
			%>
		</table>
	</form>
	</div>	
	<!-- /container -->
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /app-body -->
<script>
    function search()
	{
        $("#frm").submit();
    }
    
    jQuery(document).ready(function() 
	{
		
		$("#dfrom").flatpickr({ dateFormat: 'd/m/Y'});
		$("#dto").flatpickr({ dateFormat: 'd/m/Y'});

		$.extend($.fn.dataTable.ext.type.order, {
			"my-custom-sort-asc": function (val_1, val_2) {
				var dateParts = val_1.split("/");
				var timeParts = dateParts[2].split(" ");
				var day = parseInt(dateParts[0], 10);
				var month = parseInt(dateParts[1], 10) - 1; 
				var year = parseInt(timeParts[0], 10);
				var time = timeParts[1].split(":");
				var hours = parseInt(time[0], 10);
				var minutes = parseInt(time[1], 10);
				var seconds = parseInt(time[2], 10);
				var dateObject = new Date(year, month, day, hours, minutes, seconds);

				var dateParts1 = val_2.split("/");
				var timeParts1 = dateParts1[2].split(" ");
				var day1 = parseInt(dateParts1[0], 10);
				var month1 = parseInt(dateParts1[1], 10) - 1; 
				var year1 = parseInt(timeParts1[0], 10);
				var time1 = timeParts1[1].split(":");
				var hours1 = parseInt(time1[0], 10);
				var minutes1 = parseInt(time1[1], 10);
				var seconds1 = parseInt(time1[2], 10);
				var dateObject1 = new Date(year1, month1, day1, hours1, minutes1, seconds1);

				if (dateObject < dateObject1) {
				return -1;
				} else if (dateObject > dateObject1) {
				return 1;
				} else {
				return 0;
				}
			},

			"my-custom-sort-desc": function (val_1, val_2) {
				var dateParts = val_1.split("/");
				var timeParts = dateParts[2].split(" ");
				var day = parseInt(dateParts[0], 10);
				var month = parseInt(dateParts[1], 10) - 1; 
				var year = parseInt(timeParts[0], 10);
				var time = timeParts[1].split(":");
				var hours = parseInt(time[0], 10);
				var minutes = parseInt(time[1], 10);
				var seconds = parseInt(time[2], 10);
				var dateObject = new Date(year, month, day, hours, minutes, seconds);

				var dateParts1 = val_2.split("/");
				var timeParts1 = dateParts1[2].split(" ");
				var day1 = parseInt(dateParts1[0], 10);
				var month1 = parseInt(dateParts1[1], 10) - 1; 
				var year1 = parseInt(timeParts1[0], 10);
				var time1 = timeParts1[1].split(":");
				var hours1 = parseInt(time1[0], 10);
				var minutes1 = parseInt(time1[1], 10);
				var seconds1 = parseInt(time1[2], 10);
				var dateObject1 = new Date(year1, month1, day1, hours1, minutes1, seconds1);

				if (dateObject < dateObject1) {
				return 1;
				} else if (dateObject > dateObject1) {
				return -1;
				} else {
				return 0;
				}
			}
		});

		$('#resultsdata').DataTable({
			"responsive": true,
			"pageLength": 50,
			"language": {
				"emptyTable": "No records found"
			},
            "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
			"columnDefs": [
				{"type":"my-custom-sort","targets": [0]},
			    { "orderable": false, "targets": [2,3,4] }
			],
			aaSorting: [[0, 'desc']]
		});
    });
</script>
</html>