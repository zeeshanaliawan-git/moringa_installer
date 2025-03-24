<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.UIHelper"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ include file="../common2.jsp" %>

<%
	String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));
	String process = parseNull(request.getParameter("process"));
	String profile = parseNull(request.getParameter("profile"));
	String phase = parseNull(request.getParameter("phase"));
	String isSave = parseNull(request.getParameter("isSave"));
	String[] banRules = request.getParameterValues("banRule");
	String[] deleteBannedRules = request.getParameterValues("deleteBannedRule");

	Set rsProc = Etn.execute("Select * from processes where site_id = "+escape.cote(siteId));
	Set rsProfile = Etn.execute("select * from profil");

	String bannedPhases = "";
	if(!profile.equals(""))
	{
		Set rsSelectedProf = Etn.execute("select p.*, pb.phases as bannedPhases from profil p left join profil_banned_phases pb on pb.profil_id = p.profil_id where p.profil_id = "+escape.cote(profile));
		rsSelectedProf.next();
		bannedPhases = parseNull(rsSelectedProf.value("bannedPhases"));
	}

	Set rsRules = null;
	Set rsPhase = null;
	if(!process.equals(""))
	{
		rsPhase = Etn.execute("select phase from phases where process = "+escape.cote(process));
		String qry = "select distinct start_proc, start_phase, next_proc, next_phase from rules where start_proc = "+escape.cote(process);
		if(!phase.equals("")) qry += " and start_phase = "+escape.cote(phase);
		rsRules = Etn.execute(qry);
	}

	if(isSave.equals("1"))
	{
		if(deleteBannedRules != null)
		{
			for(String deleteRule : deleteBannedRules)
			{
				int startIndex = bannedPhases.indexOf(deleteRule);
				if (startIndex == -1) continue; //this weird case comes when any rule was deleted and then page is refreshed. IE again posts the same form and that is not found in the bannedPhases now
				if(startIndex == 0)//means its on start
				{
					int firstCommaIndex = bannedPhases.indexOf(",");
					if(firstCommaIndex < 0) bannedPhases = "";
					else
					{
						bannedPhases = bannedPhases.substring(firstCommaIndex+1);
					}
				}
				else if((startIndex + deleteRule.length()) == bannedPhases.length())//means at the end
				{
					int lastCommaIndex = bannedPhases.lastIndexOf(",");
					bannedPhases = bannedPhases.substring(0, lastCommaIndex);
				}
				else //means its in-between
				{
					String part1 = bannedPhases.substring(0, startIndex-1);
					String part2 = bannedPhases.substring(startIndex+1);
					int firstCommaIndex = part2.indexOf(",");
					part2 = part2.substring(firstCommaIndex);
					bannedPhases = part1 + part2;
				}
			}
		}
		if(banRules !=null)
		{
			for(String banRule : banRules)
			{
				if(bannedPhases.indexOf(banRule) < 0)
				{
					if(bannedPhases.length() > 0) bannedPhases += ","+banRule;
					else bannedPhases = banRule;
				}
			}
		}
		Etn.executeCmd("insert into profil_banned_phases (profil_id,site_id,phases) value ("+escape.cote(profile)+","+escape.cote(siteId)+","+escape.cote(bannedPhases)+") on duplicate key update phases = "+escape.cote(bannedPhases));
	}

%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Dandellion - Ban Rules</title>
	<link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>

<script type="text/javascript">

	function submitForm()
	{
		document.forms[0].submit();
	}

	function onsave()
	{
		if(document.forms[0].profile.value=='')
		{
			alert("Select a profile");
			return;
		}
		document.forms[0].isSave.value = "1";
		document.forms[0].submit();
	}

</script>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
    <div class="c-wrapper c-fixed-components">
      <%@ include file="/WEB-INF/include/header.jsp" %>
        <main class="c-main"  style="padding:0px 30px">
			<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
				<h1 class="h2">Ban Rules</h1>
			</div>

<form name="myForm" action="bannedRules.jsp" method="post" class="form-horizontal">
<div class="container-fluid">
<input type="hidden" name="isSave" value="0"/>
<div class="card">
	<div class="card-body">
		<div class="form-group row">
			<label for="profile" class="col-sm-2 col-form-label">Profile</label>
			<div class="col-sm-10">
				<select name="profile" onchange="submitForm()" class="form-control">
					<option value="">----------</option>
				<% while(rsProfile.next()) { %>
					<option value="<%=rsProfile.value("profil_id")%>"><%=rsProfile.value("description")%></option>
				<% } %>
				</select>
			</div>
		</div>
		<div class="form-group row">
			<label for="inputEmail3" class="col-sm-2 col-form-label">Process</label>
			<div class="col-sm-10">
			<select name="process" onchange="submitForm()" class="form-control">
				<option value="">----------</option>
				<% while(rsProc.next()) { %>
					<option value="<%=rsProc.value("process_name")%>"><%=rsProc.value("display_name")%></option>
				<% } %>
			</select>
			</div>
		</div>
		<% if(rsPhase != null) { %>
		<div class="form-group row">
			<label for="inputEmail3" class="col-sm-2 col-form-label">Phase</label>
			<div class="col-sm-10">
			<select name="phase" onchange="submitForm()" class="form-control">
				<option value="">----------</option>
				<% while(rsPhase.next()) { %>
					<option value="<%=rsPhase.value("phase")%>"><%=rsPhase.value("phase")%></option>
				<% } %>
			</select>
			</div>
		</div>
		<% } %>

	</div>
</div>
<div class="card">
	<div class="card-header">Results</div>
	<div class="card-body">

		<% if(!bannedPhases.equals("")) {
			StringTokenizer st1 = new StringTokenizer(bannedPhases,",");
		%>
		<br/>
		<div style="padding:5px; text-align:left; font-weight:bold">Already Banned Rules for <span id="alreadyBannedLbl"></span></div>
		<table class="table"  style="font-size:14px;">
			<thead style="">
				<th width="4%">Delete</th>
				<th >Start Proc</th>
				<th >Start Phase</th>
				<th >Next Proc</th>
				<th >Next Phase</th>
			</thead>
			<% while(st1.hasMoreTokens()) {
				String val = st1.nextToken();
				if(val.equals("")) continue;
		%>
				<tr>
					<td><input type="checkbox" name="deleteBannedRule" value="<%=val%>"/></td>
		<%		StringTokenizer st2 = new StringTokenizer(val,":");
				while(st2.hasMoreTokens()) {
					String val1 = st2.nextToken();
			%>
					<td><%=val1%></td>
			<%  } %>
				</tr>
		<%  } %>
		</table>
		<%}%>


		<% if(rsRules != null) {
		%>
		<div style="padding:5px; text-align:left; font-weight:bold">Available Rules that could be Banned for <span id="availableForBanLbl"></span></div>
		<table class="table" style="font-size:14px;">
			<thead style="">
				<th width="4%">Add</th>
				<th width="24%">Start Proc</th>
				<th width="24%">Start Phase</th>
				<th width="24%">Next Proc</th>
				<th width="24%">Next Phase</th>
			</thead>
			<% while(rsRules.next()) {
				String val = rsRules.value("start_proc") + ":" + rsRules.value("start_phase") + ":" + rsRules.value("next_proc") + ":" + rsRules.value("next_phase");
				if(bannedPhases.indexOf(val) > -1 ) continue;
		%>
				<tr>
					<td><input type="checkbox" name="banRule" value="<%=val%>"/></td>
					<td><%=rsRules.value("start_proc")%></td>
					<td><%=rsRules.value("start_phase")%></td>
					<td><%=rsRules.value("next_proc")%></td>
					<td><%=rsRules.value("next_phase")%></td>
				</tr>
		<%  } %>
		</table>
		<%}%>

		<% if(!bannedPhases.equals("") || rsRules != null) { %>
	<div style="text-align:center"> <input type='button' name='Save' value='Save' onclick="onsave()" class="btn btn-success"/> </div>
<% } %>
</div>
	</div>
</div>






</form>
</div>
	  </main>
	</div>
<%-- <div > --%>


</body>

<script>
	var s = "";
	<% if(!profile.equals("")) { %>
		document.forms[0].profile.value = '<%=UIHelper.escapeCoteValue(profile)%>';
		if(document.getElementById("alreadyBannedLbl")) document.getElementById("alreadyBannedLbl").innerHTML = document.forms[0].profile[document.forms[0].profile.selectedIndex].text;
		s = "Profile: " + document.forms[0].profile[document.forms[0].profile.selectedIndex].text;
	<%}%>
	<% if(!process.equals("")) { %>
		document.forms[0].process.value = '<%=UIHelper.escapeCoteValue(process)%>';
		if(s != "") s += ", Process: " + document.forms[0].process[document.forms[0].process.selectedIndex].text;
		else s += "Process: " + document.forms[0].process[document.forms[0].process.selectedIndex].text;
	<%}%>
	<% if(!phase.equals("")) { %>
		document.forms[0].phase.value = '<%=UIHelper.escapeCoteValue(phase)%>';
		s += ", Phase: " + document.forms[0].phase[document.forms[0].phase.selectedIndex].text;
	<%}%>
	if(s!="" && document.getElementById('availableForBanLbl')) document.getElementById('availableForBanLbl').innerHTML = s;
</script>
</html>
