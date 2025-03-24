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
	
	Set rsAction = Etn.execute("select * from has_action where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase));
	String ruleAction = "";
	if(rsAction.next()) ruleAction = parseNull(rsAction.value("action"));
	
%>
	<style>
		.table thead th {
			font-size: 13px;
		}
	</style>
	<div >
		<form name='ruleDeleteFrm' action=''>
		<div>
		<table class="table table-bordered">
			<thead>	
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
			<table border="0" cellpadding="0" cellspacing="0" width="100%" >
				<% if(allowEdit.equals("1")) { %>
				<tr>
					<td colspan="3">
						<table cellspacing=0 cellpadding=1 width='100%' class="table">
							<tr>
								<td>
									<div class="row">
										<div class="col-10">
												<%=addSelectControl("newConnActionChoice","newConnActionChoice",allActions,false, 0)%>
										</div>
										<div class="col-2">
												<a class="btn btn-primary" href='javascript:addAction()'>+</a>
										</div>
									</div>
									
								</td>
							</tr>
							<tr>
								<td><span id="spanParam"><select name="newConnActionParam" id="newConnActionParam" class="form-control"><option value="#">-- Param --</option></select></span></td>
							</tr>
						</table>
					</td>
				</tr>
				<% } %>
				<tr>
					<td >Action</td>
					<td colspan="2"><input class="form-control" type='text' <% if(!allowEdit.equals("1")) { %>readonly<%}%>  value='' name='newConnAction' id='newConnAction'/>
						
					</td>
			</tr>
			<tr>
				<td></td>
				<td> <% if(allowEdit.equals("1")) { %>
					<input type="button" style="font-size:8pt;margin-top:30px;" value="Save Action" id="saveActionBtn" class="btn btn-success"/>
					<% } %></td>
				<td></td>
			</tr>
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
		oldjquery(document).ready(function() {
			if(oldjquery("#newConnAction")) oldjquery("#newConnAction").val('<%=ruleAction%>');
			
			oldjquery('#newConnActionChoice').change(function() { 	
				oldjquery('#spanParam').html('<select class="form-control" name="newConnActionParam" id="newConnActionParam"><option value="#">-- Param --</option></select>');
				if(oldjquery('#newConnActionChoice').val() == '#') return;
				else
				{
					oldjquery.ajax({
						url: 'loadActionParameters.jsp',
						type: 'POST',
						data: { actionName : oldjquery('#newConnActionChoice').val() },
						success: function(resp) {
							resp = oldjquery.trim(resp);
							oldjquery('#spanParam').html(resp);					
						}			
					});													
				}
			});
			
			
			oldjquery("#saveActionBtn").click(function(){
				var isError = 0;
				if(oldjquery("#newConnAction").val() != '')
				{
					var commaSep = oldjquery("#newConnAction").val().split(",");
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
					oldjquery.ajax({
						url: 'saveRuleAction.jsp',
						type: 'POST',
						data: { sourceProcess : '<%=sourceProcess%>', sourcePhase : '<%=sourcePhase%>', ruleAction : oldjquery("#newConnAction").val() },
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
			if(oldjquery('#newConnActionChoice').val() == '#') alert('Select action');
			else if(oldjquery('#newConnActionParam').val() == '#') alert('Select parameter');
			else
			{
				var v = oldjquery('#newConnAction').val();
				if(v != '') v = v + "," + oldjquery('#newConnActionChoice').val() + ":" + oldjquery('#newConnActionParam').val();
				else v = oldjquery('#newConnActionChoice').val() + ":" + oldjquery('#newConnActionParam').val();
				oldjquery('#newConnAction').val(v);
			}
		}		
		
		function onEditRule(proc, sourcePhase, targetProc, targetPhase, errcode, isEdit)
		{
			oldjquery.ajax({
				url: 'showAddRule.jsp',
				type: 'POST',
				data: { sourceProcess: proc, sourcePhase : sourcePhase, targetProcess: targetProc, targetPhase : targetPhase, errCode : errcode, isEdit : isEdit },
				success: function(resp) {
					resp = oldjquery.trim(resp);
					oldjquery("#modalWindow").dialog('close');
					if (isEdit == 1) oldjquery("#modalWindow").dialog("option","title","Edit Rule");
					else oldjquery("#modalWindow").dialog("option","title","View Rule");
					oldjquery("#modalWindow").dialog("option","width","780px");
					oldjquery("#modalWindow").dialog("option","height","auto");		
					oldjquery("#modalWindow").html(resp);
					oldjquery("#modalWindow").dialog('open');
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
					oldjquery.ajax({
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
							oldjquery("#modalWindow").dialog('close');
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
	

	
