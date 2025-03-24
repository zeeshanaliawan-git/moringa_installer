<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>

<%
	String fromStartProc = parseNull(request.getParameter("fromStartProc"));
	String fromStartPhase = parseNull(request.getParameter("fromStartPhase"));
	String fromTargetProc = parseNull(request.getParameter("fromTargetProc"));
	String fromTargetPhase = parseNull(request.getParameter("fromTargetPhase"));
	String toStartProc = parseNull(request.getParameter("toStartProc"));
	String toStartPhase = parseNull(request.getParameter("toStartPhase"));
	String toTargetProc = parseNull(request.getParameter("toTargetProc"));
	String toTargetPhase = parseNull(request.getParameter("toTargetPhase"));
	String isCopy = parseNull(request.getParameter("isCopy"));
	if(isCopy.equals("")) isCopy = "0";
	Set rsProcess = Etn.execute("select distinct process from phases ");
	
	if(isCopy.equals("1") &&
	   !fromStartProc.equals("") && !fromStartPhase.equals("") && !fromTargetProc.equals("") && !fromTargetPhase.equals("") &&
	   !toStartProc.equals("") && !toStartPhase.equals("") && !toTargetProc.equals("") && !toTargetPhase.equals(""))
	{
		Set rsRules = Etn.execute("select * from rules where start_proc = "+escape.cote(fromStartProc)+" and start_phase = "+escape.cote(fromStartPhase)+" and next_proc = "+escape.cote(fromTargetProc)+" and next_phase = "+escape.cote(fromTargetPhase)+" ");
		while(rsRules.next())
		{
			Set rsCount = Etn.execute("select count(0) as c from rules where errCode = "+escape.cote(rsRules.value("errCode"))+" and start_proc = "+escape.cote(toStartProc)+" and start_phase = "+escape.cote(toStartPhase)+" ");
			rsCount.next();
			if(Integer.parseInt(rsCount.value("c")) == 0)//errCode for the target process/rules does not exist. Insert it
			{
				String qry = "insert into rules (start_proc, start_phase, next_proc, next_phase, errCode, action, priorite, tipo) values (";
				qry += " "+escape.cote(toStartProc)+" ";
				qry += ","+escape.cote(toStartPhase)+" ";
				qry += ","+escape.cote(toTargetProc)+" ";
				qry += ","+escape.cote(toTargetPhase)+" ";
				qry += ","+escape.cote(rsRules.value("errCode"))+" ";
				qry += ","+escape.cote(rsRules.value("action"))+" ";
				qry += ","+escape.cote(rsRules.value("priorite"))+" ";
				qry += ","+escape.cote(rsRules.value("tipo"))+" ";
				qry += ")";
				Etn.executeCmd(qry);
			}
		}
	}

	Set rsFromStartPhases = null;
	if(!fromStartProc.equals(""))
	{
		rsFromStartPhases = Etn.execute("select distinct start_phase as phase from rules where start_proc = "+escape.cote(fromStartProc)+" ");
	}
	Set rsFromTargetProc = null;
	if(!fromStartProc.equals("") && !fromStartPhase.equals(""))
	{
		rsFromTargetProc = Etn.execute("select distinct next_proc as process from rules where start_proc = "+escape.cote(fromStartProc)+" and start_phase = "+escape.cote(fromStartPhase)+" ");
	}
	Set rsFromTargetPhase = null;
	if(!fromStartProc.equals("") && !fromStartPhase.equals("") && !fromTargetProc.equals(""))
	{
		rsFromTargetPhase = Etn.execute("select distinct next_phase as phase from rules where start_proc = "+escape.cote(fromStartProc)+" and start_phase = "+escape.cote(fromStartPhase)+" and next_proc = "+escape.cote(fromTargetProc)+" ");
	}
	Set rsFromRules = null;
	if(!fromStartProc.equals("") && !fromStartPhase.equals("") && !fromTargetProc.equals("") && !fromTargetPhase.equals(""))
	{
		rsFromRules = Etn.execute("select * from rules where start_proc = "+escape.cote(fromStartProc)+" and start_phase = "+escape.cote(fromStartPhase)+" and next_proc = "+escape.cote(fromTargetProc)+" and next_phase = "+escape.cote(fromTargetPhase)+" ");
	}

	Set rsToStartPhases = null;
	if(!toStartProc.equals(""))
	{
		rsToStartPhases = Etn.execute("select phase from phases where process = "+escape.cote(toStartProc)+" ");
	}
	Set rsToTargetPhase = null;
	if(!toTargetProc.equals(""))
	{
		rsToTargetPhase = Etn.execute("select phase from phases where process = "+escape.cote(toTargetProc)+" ");
	}
	Set rsToRules = null;
	if(!toStartProc.equals("") && !toStartPhase.equals("") && !toTargetProc.equals("") && !toTargetPhase.equals(""))
	{
		rsToRules = Etn.execute("select * from rules where start_proc = "+escape.cote(toStartProc)+" and start_phase = "+escape.cote(toStartPhase)+" and next_proc = "+escape.cote(toTargetProc)+" and next_phase = "+escape.cote(toTargetPhase)+" ");
	}
	Set rsToAllRules = null;
	if(!toStartProc.equals("") && !toStartPhase.equals(""))
	{
		rsToAllRules = Etn.execute("select * from rules where start_proc = "+escape.cote(toStartProc)+" and start_phase = "+escape.cote(toStartPhase)+" order by next_proc, next_phase");
	}
%>

<html>
<head>
<title>Shop - Copy Rules</title>
<link rel="stylesheet" type="text/css" href="css/menu.css">
<link rel="stylesheet" type="text/css" href="css2/general.css">
        <%-- Styles for jQuery calendars --%>
        <link rel="stylesheet" type="text/css" href="css2/ui-lightness/jquery-ui-1.8.2.custom.css">
        <link rel="stylesheet" type="text/css" href="css2/ui-lightness/jquery-ui-1.8.custom.css">

        <%-- jQuery calendars --%>
        <script type="text/javascript" language="javascript" src="js2/jquery-1.4.2.min.js"></script>
        <script type="text/javascript" language="javascript" src="js2/ui.datepicker-es.2.js"></script>        
		<script type="text/javascript" language="javascript" src="js2/jquery-ui-1.8.2.custom.min.js"></script>		
        <script type="text/javascript" language="javascript" src="js2/jquery.ui.core.js"></script>
        <script type="text/javascript" language="javascript" src="js2/jquery.ui.resizable.js"></script>
        <script type="text/javascript" language="javascript" src="js2/jquery.ui.draggable.js"></script>

<script>
	function onCopy()
	{		
		if(document.forms[0].fromStartProc.value=='' ||
		   document.forms[0].fromStartPhase.value=='' ||
		   document.forms[0].fromTargetProc.value=='' ||
		   document.forms[0].fromTargetPhase.value=='')
		  {
			alert("Select Copy From Processes/Phases");
			return;
		  }
		if(document.forms[0].toStartProc.value=='' ||
		   document.forms[0].toStartPhase.value=='' ||
		   document.forms[0].toTargetProc.value=='' ||
		   document.forms[0].toTargetPhase.value=='')
		  {
			alert("Select Copy To Processes/Phases");
			return;
		  }
		  
		if(document.forms[0].fromStartProc.value==document.forms[0].toStartProc.value &&
		   document.forms[0].fromStartPhase.value==document.forms[0].toStartPhase.value)
		{
			alert("Copy To Processes/Phases should not be same as Copy From Processes/Phases");
			return;
		}
		document.forms[0].isCopy.value = "1";
		document.forms[0].submit();
	}
</script>
		
</head>
<body>
<div>

<%@include file="/WEB-INF/include/menu_admin.jsp"%>

	<div style="width:950px">
		<form name="myFrm" action="copyRules.jsp" method="post">
		<input type='hidden' name="isCopy" value="0"/>
		<div style="float:left; width:445px">
		<table cellspacing="0" cellpadding="0" border="0">
			<tr>
				<td colspan="4" style="height:45px" align="center"><b>Copy Rules From</b></td>
			</tr>
			<tr>
				<td><b>Start Proc</b></td>
				<td>
					<select name="fromStartProc" onchange="javascript:document.forms[0].submit()">
						<option value="">-</option>
						<% while(rsProcess.next()) { %>
							<option value="<%=rsProcess.value("process")%>" <%if(fromStartProc.equals(rsProcess.value("process"))){%>selected<%}%>><%=parseNull(rsProcess.value("process"))%></option>
						<% } %>
					</select>
				</td>
				<td><b>Start Phase</b></td>
				<td>
					<select name="fromStartPhase" onchange="javascript:document.forms[0].submit()">
					<option value="">-</option>
					<% if(rsFromStartPhases != null) {%>
						<% while(rsFromStartPhases.next()) { %>
							<option value="<%=rsFromStartPhases.value("phase")%>" <%if(fromStartPhase.equals(rsFromStartPhases.value("phase"))){%>selected<%}%>><%=parseNull(rsFromStartPhases.value("phase"))%></option>
						<% } %>
					<% } %>
					</select>
				</td>
			</tr>
			<tr>
				<td><b>Target Proc</b></td>
				<td>
					<select name="fromTargetProc" onchange="javascript:document.forms[0].submit()">
						<option value="">-</option>
						<% if(rsFromTargetProc != null) { %>
						<% while(rsFromTargetProc.next()) { %>
							<option value="<%=rsFromTargetProc.value("process")%>" <%if(fromTargetProc.equals(rsFromTargetProc.value("process"))){%>selected<%}%>><%=parseNull(rsFromTargetProc.value("process"))%></option>
						<% } %>
						<% } %>
					</select>
				</td>
				<td><b>Target Phase</b></td>
				<td>
					<select name="fromTargetPhase"  onchange="javascript:document.forms[0].submit()">
					<option value="">-</option>
					<% if(rsFromTargetPhase != null) {%>
						<% while(rsFromTargetPhase.next()) { %>
							<option value="<%=rsFromTargetPhase.value("phase")%>" <%if(fromTargetPhase.equals(rsFromTargetPhase.value("phase"))){%>selected<%}%>><%=parseNull(rsFromTargetPhase.value("phase"))%></option>
						<% } %>
					<% } %>
					</select>
				</td>
			</tr>
			<% if(rsFromRules !=null && rsFromRules.rs.Rows > 0) { %>
				<tr>
					<td colspan="4" height="45px" align="center">&nbsp;</td>
				</tr>			
				<tr>
					<td colspan="5">
						<table cellspacing='0' cellpadding='0' border='1'>
							<tr><td><b>ErrCode</b></td><td><b>priorite</b></td><td><b>action</b></td><td><b>tipo</b></td></tr>
							<% while(rsFromRules.next()){%>
								<tr><td><%=rsFromRules.value("errCode")%></td><td><%=parseNull(rsFromRules.value("priorite"))%></td><td><%=parseNull(rsFromRules.value("action"))%></td><td><%=parseNull(rsFromRules.value("tipo"))%></td></tr>
							<%}%>
						</table>
					</td>
				</tr>
			<%}%>
		</table>
		</div>
		<div style="float:right; width:445px">
		<table cellspacing="0" cellpadding="0" border="0" width="45%">
			<tr>
				<td colspan="4" height="45px" align="center"><b>Copy Rules To</b></td>
			</tr>
			<tr>
				<td><b>Start Proc</b></td>
				<td>
					<select name="toStartProc" onchange="javascript:document.forms[0].submit()">
						<option value="">-</option>
						<% rsProcess.moveFirst();
							while(rsProcess.next()) { %>
							<option value="<%=rsProcess.value("process")%>" <%if(toStartProc.equals(rsProcess.value("process"))){%>selected<%}%>><%=parseNull(rsProcess.value("process"))%></option>
						<% } %>
					</select>
				</td>
				<td><b>Start Phase</b></td>
				<td>
					<select name="toStartPhase" onchange="javascript:document.forms[0].submit()">
					<option value="">-</option>
					<% if(rsToStartPhases != null) {%>
						<% while(rsToStartPhases.next()) { %>
							<option value="<%=rsToStartPhases.value("phase")%>" <%if(toStartPhase.equals(rsToStartPhases.value("phase"))){%>selected<%}%>><%=parseNull(rsToStartPhases.value("phase"))%></option>
						<% } %>
					<% } %>
					</select>
				</td>
			</tr>
			<tr>
				<td><b>Target Proc</b></td>
				<td>
					<select name="toTargetProc" onchange="javascript:document.forms[0].submit()">
						<option value="">-</option>
						<% rsProcess.moveFirst(); %>
						<% while(rsProcess.next()) { %>
							<option value="<%=rsProcess.value("process")%>" <%if(toTargetProc.equals(rsProcess.value("process"))){%>selected<%}%>><%=parseNull(rsProcess.value("process"))%></option>
						<% } %>
					</select>
				</td>
				<td><b>Target Phase</b></td>
				<td>
					<select name="toTargetPhase"  onchange="javascript:document.forms[0].submit()">
					<option value="">-</option>
					<% if(rsToTargetPhase != null) {%>
						<% while(rsToTargetPhase.next()) { %>
							<option value="<%=rsToTargetPhase.value("phase")%>" <%if(toTargetPhase.equals(rsToTargetPhase.value("phase"))){%>selected<%}%>><%=parseNull(rsToTargetPhase.value("phase"))%></option>
						<% } %>
					<% } %>
					</select>
				</td>
			</tr>
			<% if(rsToAllRules !=null && rsToAllRules.rs.Rows > 0) { %>
				<tr>
					<td colspan="4" height="45px" align="center">&nbsp;</td>
				</tr>						
				<tr>
					<td colspan="5">
						<table cellspacing='0' cellpadding='0' border='1'>
							<tr><td><b>Next Proc</b></td><td><b>Next Phase</b></td><td><b>ErrCode</b></td><td><b>priorite</b></td><td><b>action</b></td><td><b>tipo</b></td></tr>
							<% while(rsToAllRules.next()){%>
								<tr><td><%=rsToAllRules.value("next_proc")%></td><td><%=rsToAllRules.value("next_phase")%></td><td><%=rsToAllRules.value("errCode")%></td><td><%=parseNull(rsToAllRules.value("priorite"))%></td><td><%=parseNull(rsToAllRules.value("action"))%></td><td><%=parseNull(rsToAllRules.value("tipo"))%></td></tr>
							<%}%>
						</table>
					</td>
				</tr>
			<%}%>
		</table>
		</div>
		
		<div style="clear:both;text-align:center; margin-top:15px">
			<input type='button' value='Copy' onclick="onCopy()"/>
		</div>
		
		</form>
	</div>

</div>	
</body>
</html>
