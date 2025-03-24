<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.asimina.util.UIHelper"%>
<%@ include file="common.jsp" %>

<%
	String sourceProcess = parseNull(request.getParameter("sourceProcess"));
	String targetProcess = parseNull(request.getParameter("targetProcess"));
	String sourcePhase = parseNull(request.getParameter("sourcePhase"));
	String targetPhase = parseNull(request.getParameter("targetPhase"));
	String forDelete = parseNull(request.getParameter("forDelete"));
	String allowEdit = parseNull(request.getParameter("allowEdit"));
	if(allowEdit.equals("")) allowEdit = "0";
	
	String qry = "select r.errCode, e.errNom, errType, errCouleur from rules r, errcode e where e.id = r.errCode and r.next_proc = "+escape.cote(targetProcess)+" and r.start_proc = "+escape.cote(sourceProcess)+" and r.start_phase = "+escape.cote(sourcePhase)+" and r.next_phase = "+escape.cote(targetPhase)+" ";	

	Set rs = Etn.execute(qry);
	
	Set actionsRs = Etn.execute("Select * from actions ");
	Map<String, String> allActions = new LinkedHashMap<String, String>();
	allActions.put("#","-- Action --");
	while(actionsRs.next()) allActions.put(actionsRs.value("name"),actionsRs.value("name"));
	
	Set rsAction = Etn.execute("select * from has_action where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" ");
	String ruleAction = "";
	if(rsAction.next()) ruleAction = parseNull(rsAction.value("action"));
	
%>
	
	<div style="height:auto; overflow:auto">
		<form name='ruleDeleteFrm' action=''>
		<div>
		<table border="1" cellpadding="0" cellspacing="0" width="100%">
			<thead style="background-color:#f5f5f5">	
				<%if(forDelete.equals("1")) {%>
					<th>&nbsp;</th>
				<%}%>
				<th>Err Code</th>
				<th>Err Name</th>
				<th>Err Type</th>
				<th>Err Color</th>
				<%if(!forDelete.equals("1") && allowEdit.equals("1")) {%>
				<th>&nbsp;</th>
				<%}
				else if(!forDelete.equals("1") && !allowEdit.equals("1")) {%>
				<th>&nbsp;</th>
				<%}%>
			</thead>
<%
		while(rs.next())
		{
%>
			<tr>
				<%if(forDelete.equals("1")) {%>
					<td align="center"><input type='radio' name='ruleDeleteChkbx' value='<%=rs.value("errCode")%>'></td>
				<%}%> 
				<td>&nbsp;<%=rs.value("errCode")%></td>
				<td>&nbsp;<%=rs.value("errNom")%></td>
				<td>&nbsp;<%=rs.value("errType")%></td>
				<td style='background-color:<%=parseNull(rs.value("errCouleur"))%>'>&nbsp;</td>
				<%if(!forDelete.equals("1") && allowEdit.equals("1")) {%>
				<td>&nbsp;<a style='color:black' href="javascript:onEditRule('<%=UIHelper.escapeCoteValue(sourceProcess)%>','<%=UIHelper.escapeCoteValue(sourcePhase)%>','<%=UIHelper.escapeCoteValue(targetProcess)%>','<%=UIHelper.escapeCoteValue(targetPhase)%>','<%=rs.value("errCode")%>',1)">Edit</a>&nbsp;</td>
				<%}
				else if(!forDelete.equals("1") && !allowEdit.equals("1")) {%>
				<td>&nbsp;<a style='color:black' href="javascript:onEditRule('<%=UIHelper.escapeCoteValue(sourceProcess)%>','<%=UIHelper.escapeCoteValue(sourcePhase)%>','<%=UIHelper.escapeCoteValue(targetProcess)%>','<%=UIHelper.escapeCoteValue(targetPhase)%>','<%=rs.value("errCode")%>',0)">View</a>&nbsp;</td>
				<%}%>
			</tr>
<% } %>
		</table>
		</div>
		<%if(!forDelete.equals("1")) {%>
		<div style="text-align:left; padding-top:2px; padding-bottom:2px; border-top:1px solid gray; margin-top:15px; border-bottom:1px solid gray;">
			<div style="font-weight:bold; ">Rule Action</div>
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<% if(allowEdit.equals("1")) { %>
				<tr>
					<td colspan="3">
						<table cellspacing=0 cellpadding=1 width='100%'>
							<tr>
								<td><%=addSelectControl("newConnActionChoice","newConnActionChoice",allActions,false, 0)%>&nbsp;<a style="font-size:12pt;text-decoration:none;color:black" href='javascript:addAction()'>+</a></td>
							</tr>
							<tr>
								<td><span id="spanParam"><select name="newConnActionParam" id="newConnActionParam"><option value="#">-- Param --</option></select></span></td>
							</tr>
						</table>
					</td>
				</tr>
				<% } %>
				<tr><td >Action</td><td width='2%'>:</td><td><input type='text' <% if(!allowEdit.equals("1")) { %>readonly<%}%>  value='' name='newConnAction' id='newConnAction' maxlength='64' size='35'/>
					     &nbsp;
						 <% if(allowEdit.equals("1")) { %>
						 <input type="button" style="font-size:8pt" value="Save Action" id="saveActionBtn"/>
						 <% } %>
				</td></tr>
			</table>
		</div>
		<% } %>
		</form>
	</div>
	<%if(forDelete.equals("1")) {%>
	<div style='text-align:center'>
		<input type='button' value='Delete' onclick="onRuleDelete()">
	</div>
	<%}%>
	
	<script>
		jQuery(document).ready(function() {
			if(jQuery("#newConnAction")) jQuery("#newConnAction").val('<%=ruleAction%>');
			
			jQuery('#newConnActionChoice').change(function() { 	
				jQuery('#spanParam').html('<select name="newConnActionParam" id="newConnActionParam"><option value="#">-- Param --</option></select>');
				if(jQuery('#newConnActionChoice').val() == '#') return;
				else
				{
					jQuery.ajax({
						url: 'loadActionParameters.jsp',
						type: 'POST',
						data: { actionName : jQuery('#newConnActionChoice').val() },
						success: function(resp) {
							resp = jQuery.trim(resp);
							jQuery('#spanParam').html(resp);					
						}			
					});													
				}
			});
			
			
			jQuery("#saveActionBtn").click(function(){
				var isError = 0;
				if(jQuery("#newConnAction").val() != '')
				{
					var commaSep = jQuery("#newConnAction").val().split(",");
					for (var i=0;i<commaSep.length;i++)
					{
						var colonSep = commaSep[i].split(":");
						if(colonSep.length != 2) 
						{
							isError = 1;
							alert('Invalid format for action. Format is action_name:param_id,action_name:param_id');
							break;
						}
					}					
				}
				if(!isError)
				{
					jQuery.ajax({
						url: 'saveRuleAction.jsp',
						type: 'POST',
						data: { sourceProcess : '<%=sourceProcess%>', sourcePhase : '<%=sourcePhase%>', ruleAction : jQuery("#newConnAction").val() },
						dataType: 'json',
						success: function(resp) {
							alert(resp.MESSAGE);
						}			
					});													
				}
			});
			
		});
		
		function addAction()
		{
			if(jQuery('#newConnActionChoice').val() == '#') alert('Select action');
			else if(jQuery('#newConnActionParam').val() == '#') alert('Select parameter');
			else
			{
				var v = jQuery('#newConnAction').val();
				if(v != '') v = v + "," + jQuery('#newConnActionChoice').val() + ":" + jQuery('#newConnActionParam').val();
				else v = jQuery('#newConnActionChoice').val() + ":" + jQuery('#newConnActionParam').val();
				jQuery('#newConnAction').val(v);
			}
		}		
		
		function onEditRule(proc, sourcePhase, targetProc, targetPhase, errcode, isEdit)
		{
			jQuery.ajax({
				url: 'showAddRule.jsp',
				type: 'POST',
				data: { sourceProcess: proc, sourcePhase : sourcePhase, targetProcess: targetProc, targetPhase : targetPhase, errCode : errcode, isEdit : isEdit },
				success: function(resp) {
					resp = jQuery.trim(resp);
					jQuery("#modalWindow").dialog('close');
					if (isEdit == 1) jQuery("#modalWindow").dialog("option","title","Edit Rule");
					else jQuery("#modalWindow").dialog("option","title","View Rule");
					jQuery("#modalWindow").dialog("option","width","780px");
					jQuery("#modalWindow").dialog("option","height","auto");		
					jQuery("#modalWindow").html(resp);
					jQuery("#modalWindow").dialog('open');
				},
				error : function(resp) {
					alert("Some error while communication with server. Try again or contact administrator");
				}			
			});										
		}
	
		function onRuleDelete()
		{
			var anyChecked = false;			
			for(i=0;i<document.ruleDeleteFrm.ruleDeleteChkbx.length;i++)
			{
				if(document.ruleDeleteFrm.ruleDeleteChkbx[i].checked)
				{
					var errCode = document.ruleDeleteFrm.ruleDeleteChkbx[i].value;
					var data = "sourceProcess=<%=sourceProcess%>&sourcePhase=<%=sourcePhase%>&targetProcess=<%=targetProcess%>&targetPhase=<%=targetPhase%>&errCode="+errCode;
					jQuery.ajax({
						url: 'deleteRule.jsp',
						type: 'POST',
						data: data,
						success: function(resp) {
							//variable workflow is actually defined in processStatus.jsp
							var conn = null;
							for(var i=0; i<workflow.lines.size; i++)
							{
								if(workflow.lines.get(i) instanceof draw2d.GizmoConnection &&
									workflow.lines.get(i).sourcePort.parentNode.group.figName == '<%=UIHelper.escapeCoteValue(sourcePhase)%>' &&
									workflow.lines.get(i).sourcePort.parentNode.group.process == '<%=UIHelper.escapeCoteValue(sourceProcess)%>' &&
									workflow.lines.get(i).targetPort.parentNode.group.figName == '<%=UIHelper.escapeCoteValue(targetPhase)%>' &&
									workflow.lines.get(i).targetPort.parentNode.group.process == '<%=UIHelper.escapeCoteValue(targetProcess)%>' )
								{
									conn = workflow.lines.get(i);
									break;
								}
							}							
							if(conn)
								conn.group.removeErrInfo(errCode);
							alert('Rule deleted successfully');
							jQuery("#modalWindow").dialog('close');
						},
						error : function(resp) {
							alert("Some error while communication with server. Try again or contact administrator");
						}			
					});										
					anyChecked = true;
				}
			}
			if(!anyChecked)
			{
				alert('Select rule to delete');
				return;
			}
		}
	</script>
	

	
