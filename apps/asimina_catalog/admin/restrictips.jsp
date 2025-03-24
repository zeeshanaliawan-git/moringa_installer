<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.util.*, com.etn.asimina.util.ActivityLog"%>

<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%
	
	if("1".equals(request.getParameter("save")))
	{
		String[] pid = request.getParameterValues("pid");
		String[] ips = request.getParameterValues("ip");
		for(int i=0;i<pid.length;i++)
		{
			Etn.executeCmd("update login set allowed_ips = "+escape.cote(parseNull(ips[i]))+" where pid = "+escape.cote(parseNull(pid[i])));
		}
	}

	Set rsUsers = Etn.execute("select p.person_id,l.is_two_auth_enabled as auth, l.name as username, l.allowed_ips,  p.First_name, p.last_name, p.e_mail, l.pid, pp.profil_id from login l, person p, profilperson pp where pp.person_id = p.person_id and p.person_id = l.pid order by p.person_id ");

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Restrict IPs</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Restrict IPs", ""});
%>

</head>
<body>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
	<main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
		<div>
			<h1 class="h2">Restrict IPs</h1>
			<p class="lead"></p>
		</div>
	</div>
	<!-- /title -->


	<!-- container -->
	<div class="animated fadeIn">
	<form name="userFrm" action="restrictips.jsp" method="post">
	<input class="form-control" type="hidden" name="save" value="1"/>
	<table class="table table-hover table-bordered" >
		<thead class="thead-dark">
		<tr>
			<th>Login</th>
			<th>Name</th>
			<th>Allowed IPs<span style="font-size:0.8em;margin-left:5px">(comma separated IPs list)</span></th>
		</tr>
		</thead>
		<%	
		    while(rsUsers.next()){
		%>
			<tr>
				<td align="left">
					<%=escapeCoteValue(rsUsers.value("username"))%>
				</td>
				<td align="left">
					<%=escapeCoteValue(rsUsers.value("First_name"))%> <%=escapeCoteValue(rsUsers.value("last_name"))%>
				</td>
                <td align="left"><input class="form-control" type='text' maxlength='50' size='35' name='ip' value='<%=escapeCoteValue(parseNull(rsUsers.value("allowed_ips")))%>' /></td>
			</tr>
			<input class="form-control" type="hidden" name="pid" value="<%=escapeCoteValue(rsUsers.value("person_id"))%>"	/>
		<%
			}%>
	</table>
	<div style='margin-top:5px; text-align:center'><input class="btn btn-primary" type='button' value='Save' onclick="onsave()"/></div>
	<br />
	</form>

	<br>
	<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /c-body -->

<script>
function onsave()
{
	document.forms[0].submit();
}
</script>
</body>
</html>
