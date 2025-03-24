<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.SiteHelper, com.etn.util.CommonHelper"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ include file="common.jsp"%>


<%
	boolean isprod = "1".equals(request.getParameter("isprod"));
	String siteid = SiteHelper.getSiteId(session);
	
	String title = "Site Configs";
	String dbname = "";
	String formaction = "siteconfigs.jsp";
	if(isprod) 
	{
		dbname = GlobalParm.getParm("PROD_DB") + ".";
		title = "Prod Site Configs";
		formaction += "?isprod=1";
	}
	
	if("1".equals(request.getParameter("issave")))
	{
		String[] codes = request.getParameterValues("code");
		String[] vals = request.getParameterValues("val");
		
		if(codes != null && vals !=null)
		{
			for(int i=0;i<codes.length;i++)
			{
				Etn.executeCmd("update "+dbname+"sites_config set val = "+escape.cote(parseNull(vals[i]))+" where site_id = "+escape.cote(siteid)+" and code = "+escape.cote(codes[i]));
			}
		}
	}
	
	Set rs = Etn.execute("Select * from "+dbname+"sites_config where site_id = "+escape.cote(siteid)+" order by code ");
%>

<html>
<head>
	<title><%=title%></title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
</head>

<%	
breadcrumbs.add(new String[]{"Navigation", ""});
breadcrumbs.add(new String[]{title, ""});
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2"><%=title%></h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" aria-label="...">
					<% if(isprod == false ) {%>
					<input type='button' value='Prod Site Configs' onclick='javascript:window.location.href="siteconfigs.jsp?isprod=1";' class="btn btn-warning" />
					<%}else{%>
					<input type='button' value='Test Site Configs' onclick='javascript:window.location.href="siteconfigs.jsp";' class="btn btn-warning" />
					<%}%>
					<input type='button' value='Save' onclick='onsave()' class="mr-2 btn btn-success" />
				</div>
			</div>
			<!-- /buttons bar -->
	</div>
	<!-- /title -->

	<!-- container -->
	<div class="animated fadeIn p-3">
	<form name='frm' id='frm' action='<%=formaction%>' method='post'>
		<input type='hidden' name='issave' value='1'>
		<div>
			<table class="table table-hover table-bordered m-t-20">
				<thead class="thead-dark">
					<th style="text-align: left;vertical-align: top;">Config</th>
					<th style="text-align: left;vertical-align: top;">Value</th>
				</thead>
			<% while(rs.next()){%>
				<tr>
					<td><input type='hidden' name='code' value='<%=rs.value("code")%>'><%=rs.value("code")%></td>
					<td><input class="form-control" type='text' name='val' value='<%=CommonHelper.escapeCoteValue(CommonHelper.parseNull(rs.value("val")))%>'</td>
				</tr>
			
			<%
			}
			%>
			</table>
		</div>
		</form>
		<br>
		<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
</main>

<script type='text/javascript'>
function onsave()
{
	$("#frm").submit();
}
</script>

</body>

</html>

