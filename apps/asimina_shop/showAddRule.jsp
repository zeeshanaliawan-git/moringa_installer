 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ include file="common.jsp" %>

<%
	String errCode = parseNull(request.getParameter("errCode"));
	String sourceProcess = parseNull(request.getParameter("sourceProcess"));
	String targetProcess = parseNull(request.getParameter("targetProcess"));
	String sourcePhase = parseNull(request.getParameter("sourcePhase"));
	String targetPhase = parseNull(request.getParameter("targetPhase"));
	String isEdit = parseNull(request.getParameter("isEdit"));
	
	boolean isUpdate = false;
	if(!errCode.equals("") && !sourceProcess.equals("") && !sourcePhase.equals("") && !targetProcess.equals("") && !targetPhase.equals("")) isUpdate = true;

		
	Set errRs = null;
	String action = "";
	String errColor = "";
	String nextestado = "";
	String connType = "";
	String connRdv = "";
	if(isUpdate)
	{
		errRs = Etn.execute("select * from errcode where id = "+escape.cote(errCode)+" ");
		errRs.next();
		errColor = parseNull(errRs.value("errCouleur"));
		if(!errColor.equals("")) errColor = errColor.substring(1);
		
		Set ruleRs = Etn.execute("select * from rules where start_proc="+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" and next_proc="+escape.cote(targetProcess)+" and next_phase = "+escape.cote(targetPhase)+" and errCode = "+escape.cote(errCode));
		ruleRs.next();
		action = parseNull(ruleRs.value("action"));
		nextestado = parseNull(ruleRs.value("nstate"));
		connType = parseNull(ruleRs.value("type"));
		connRdv = parseNull(ruleRs.value("rdv"));
	}

//	Set actionsRs = Etn.execute("Select * from actions ");
//	Map<String, String> allActions = new LinkedHashMap<String, String>();
//	allActions.put("#","-- Action --");
//	while(actionsRs.next()) allActions.put(actionsRs.value("name"),actionsRs.value("name"));
	
	String query = "select id, errNom, errMessage, errType, errCouleur from errcode ";
	if(isUpdate) query += " where id != " + escape.cote(errCode) + " ";
	query += " order by id";
	Set rs = Etn.execute(query);
%>
<div style='text-align:left;width:750px'>
	<table width='100%'>
	<tr>
	<td width="50%">
		<table cellspacing=0 cellpadding=1 width='100%'> 
			<tr><td colspan='4'><span style='color:red' id='addNewRuleMsg'>&nbsp;</span></td></tr>
			<% if(isUpdate && ((String)session.getAttribute("PROFIL")).equals("SUPER_ADMIN_SPAIN")) { %>
			<input type='hidden' value='' name='newConnErrCode' id='newConnErrCode' />
			<% } else { %>
			<tr><td width='30%'>Error Code</td><td width='2%'>:</td><td><input type='text' value='' name='newConnErrCode' id='newConnErrCode' maxlength='6' size='7'/>&nbsp;<span id='errCodeMsg' style='color:red; font-size:8pt;'>&nbsp;</span></td></tr>	
			<% } %>
			<tr><td width='30%'>Error Name</td><td width='2%'>:</td><td><input type='text' value='' name='newConnErrName' id='newConnErrName' maxlength='200' size='25'/></td></tr>
			<tr><td width='30%'>Error Message</td><td width='2%'>:</td><td><input type='text' value='' name='newConnErrMsg' id='newConnErrMsg' maxlength='78' size='25'/></td></tr>
			<tr><td width='30%'>Error Type</td><td width='2%'>:</td><td><select name='newConnErrType' id='newConnErrType'><option value='success'>SUCCESS</option><option value='failure'>FAILURE</option></select></td></tr>
			<tr><td width='30%'>Color</td><td width='2%'>:</td><td><input type='text' id='colorPicker' name='colorPicker'/>&nbsp;<span id='errColorMsg' style='color:red; font-size:8pt;'>&nbsp;</span></td></tr>
			<tr><td width='30%'>Nextestado</td><td width='2%'>:</td><td><input type='text' maxlength="10" size="10" id='nextestado' name='nextestado'/>&nbsp;<span id='nextestadoMsg' style='color:red; font-size:8pt;'>&nbsp;</span></td></tr>
			<tr><td width='30%'>Rdv</td><td width='2%'>:</td><td>
				<select name='newConnRdv' id='newConnRdv'>
					<option value='And'>And</option>
					<option value='Or'>Or</option>
					<option value='Custom'>Custom</option>
				</select>
			</td></tr>
			<tr><td width='30%'>Type</td><td width='2%'>:</td><td>
				<select name='newConnType' id='newConnType'>
					<option value='Cancelled'>Cancelled</option>
					<option value='Closed'>Closed</option>
					<option value='Abort'>Abort</option>
				</select>
			</td></tr>
			<tr><td width='30%' colspan="5">&nbsp;</td></tr>
		</table>
	</td>
	<td>
		<div style="height:200px; overflow:auto">
		<table width="100%" border="1" cellpadding="0" cellspacing="0">
			<thead style="background-color:#f5f5f5">
				<% if(!((String)session.getAttribute("PROFIL")).equals("SUPER_ADMIN_SPAIN")) { %>			
				<th>Err Code</th>
				<% } %>
				<th>Err Name</th>
				<th>Err Type</th>
				<th>Err Color</th>
			</thead>
			<% while(rs.next()) { %>
				<tr style="cursor:pointer" onclick="setErrInfo('<%=parseNull(rs.value("id"))%>','<%=parseNull(rs.value("errNom"))%>','<%=parseNull(rs.value("errType"))%>','<%=parseNull(rs.value("errCouleur"))%>','<%=parseNull(rs.value("errMessage"))%>')">
					<% if(!((String)session.getAttribute("PROFIL")).equals("SUPER_ADMIN_SPAIN")) { %>			
					<td><%=parseNull(rs.value("id"))%>&nbsp;</td>
					<% } %>
					<td><%=parseNull(rs.value("errNom"))%>&nbsp;</td>
					<td><%=parseNull(rs.value("errType"))%>&nbsp;</td>
					<td style='background-color:<%=parseNull(rs.value("errCouleur"))%>'>&nbsp;</td>
				</tr>
			<% } %>
		</table>		
		</div>
		(Click a row to select the error code)
	</td>
	</tr>
	</table>
</div>
<br>
<% if(isUpdate) { %>
<input type='hidden' id="updateRule" name='updateRule' value='1'/>
<% } else { %>
<input type='hidden' id="updateRule" name='updateRule' value='0'/>
<% } %>
<% if (isEdit.equals("1") || (!isUpdate)) { %>
<div style='text-align:center;margin-top:3px'><input type='button' value='Ok' onclick='draw2d.GizmoWorkflow.prototype.OnNewConnection()'></div>
<% } %>			   
<script>
	oldjquery('#colorPicker').ColorPicker({onSubmit: function(hsb, hex, rgb, el) { oldjquery(el).val(hex); oldjquery(el).ColorPickerHide(); }});
	
	function setErrInfo(errCode, errNom, errType, errColor, errMsg)
	{
		<% if(!isUpdate) { %>
			oldjquery('#newConnErrCode').val(errCode);
		<% } %>
		oldjquery('#newConnErrName').val(errNom);
		oldjquery('#newConnErrMsg').val(errMsg);
		oldjquery('#newConnErrType').val(errType);
		if(errColor.indexOf("#") > -1)
			errColor = errColor.substr(1, errColor.length);
		oldjquery('#colorPicker').val(errColor);
	}
	
	oldjquery(document).ready(function() {
		<% if(isUpdate) { %>
			document.getElementById('newConnErrCode').value = '<%=errRs.value("id")%>';
			<% if(!((String)session.getAttribute("PROFIL")).equals("SUPER_ADMIN_SPAIN")) { %>			
				document.getElementById('newConnErrCode').readOnly = true;
			<% } %>
			document.getElementById('newConnErrName').value = '<%=errRs.value("errNom")%>';
			document.getElementById('newConnErrMsg').value = '<%=errRs.value("errMessage")%>';
			document.getElementById('newConnErrType').value = '<%=errRs.value("errType")%>';
			document.getElementById('colorPicker').value = '<%=errColor%>';
			document.getElementById('nextestado').value = '<%=nextestado%>';
			document.getElementById('newConnRdv').value = '<%=connRdv%>';
			document.getElementById('newConnType').value = '<%=connType%>';
		<% } %>
		
	});
	
</script>