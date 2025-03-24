/*
* This class extends draw2d.Workflow class and draw the figures.
* The functions addFigure and removeFigure are overwritten as we have to show dialog box and also make ajax calls here
* To let the workflow know when we are ready for ajax calls, the function setCallAjax is introduced
*/

var gizWFCurrentFig=null;

draw2d.GizmoWorkflow=function(id)
{
	try{
		if(!id)
		{
			return;
		}
		this.callAjax = false;
		this.partialUpdate = false;
		draw2d.Workflow.call(this,id);
		this.resizeHandle1=new draw2d.GizmoResizeHandle(this,1);
		this.resizeHandle2=new draw2d.GizmoResizeHandle(this,2);
		this.resizeHandle3=new draw2d.GizmoResizeHandle(this,3);
		this.resizeHandle4=new draw2d.GizmoResizeHandle(this,4);
		this.resizeHandle5=new draw2d.GizmoResizeHandle(this,5);
		this.resizeHandle6=new draw2d.GizmoResizeHandle(this,6);
		this.resizeHandle7=new draw2d.GizmoResizeHandle(this,7);
		this.resizeHandle8=new draw2d.GizmoResizeHandle(this,8);
		this.labelsVisible=false;
	}
	catch(e){
		pushErrorStack(e,"draw2d.GizmoWorkflow=function(/*:String*/ id, /*:String*/ process)");
	}
};
draw2d.GizmoWorkflow.prototype=new draw2d.Workflow();
draw2d.GizmoWorkflow.prototype.type="draw2d.GizmoWorkflow";
draw2d.GizmoWorkflow.prototype.addFigure=function(fig,xPos,yPos)
{
	//we need to set the color of connection as user selects it so will draw connection in OnNewConnection function
	if( (fig instanceof draw2d.GizmoConnection && this.callAjax) ||
		(fig instanceof draw2d.GizmoConnection && this.partialUpdate) )
	{
		if(fig.sourcePort instanceof draw2d.OutputPort && fig.targetPort instanceof draw2d.OutputPort) return;
		if(fig.sourcePort instanceof draw2d.InputPort && fig.targetPort instanceof draw2d.InputPort) return;
		
		if(fig.sourcePort.parentNode.isIntraProcess) return;// we dont allow other process node to be source phase. It can only be target phase

		gizWFCurrentFig = fig;
		jQuery.ajax({
			url: 'showAddRule.jsp',
			type: 'GET',
			success: function(resp) {
				resp = jQuery.trim(resp);
				jQuery("#modalWindow").dialog("option","title","New Rule");
				jQuery("#modalWindow").dialog("option","width","auto");
				jQuery("#modalWindow").dialog("option","height","auto");		
				jQuery("#modalWindow").html(resp);
				jQuery("#modalWindow").dialog('open');
			},
			error : function(resp) {
				alert("Some error while communication with server. Try again or contact administrator");
			}
		});							
	}
	else
	{
		draw2d.Workflow.prototype.addFigure.call(this,fig,xPos,yPos,true);
	}
	
};
draw2d.GizmoWorkflow.prototype.OnNewConnection=function()
{
	var conn = gizWFCurrentFig;
	document.getElementById("addNewRuleMsg").innerHTML = "&nbsp;";
	if(document.getElementById("errCodeMsg")) document.getElementById("errCodeMsg").innerHTML = "&nbsp;";
	document.getElementById("errColorMsg").innerHTML = "&nbsp;";
	document.getElementById("nextestadoMsg").innerHTML = "&nbsp;";
	document.getElementById("tipoMsg").innerHTML = "&nbsp;";
	var isError = 0;
	if(document.getElementById('newConnErrCode').value == '')
	{
		document.getElementById('errCodeMsg').innerHTML = 'Enter error code';
		isError = 1;
	}
	if(document.getElementById('colorPicker').value == '')
	{
		document.getElementById('errColorMsg').innerHTML = 'Select color';
		isError = 1;
	}
	/*if(document.getElementById('newConnAction').value != '')
	{
		var commaSep = document.getElementById('newConnAction').value.split(",");
		for (var i=0;i<commaSep.length;i++)
		{
			var colonSep = commaSep[i].split(":");
			if(colonSep.length != 2) 
			{
				isError = 1;
				document.getElementById('errActionMsg').innerHTML = 'Invalid format for action. Format is action_name:param_id,action_name:param_id';
				break;
			}
		}					
	}*/
	if(document.getElementById('nextestado').value != '' && !document.getElementById('nextestado').value.match(/^\d+$/))
	{
		document.getElementById('nextestadoMsg').innerHTML = 'Nextestado should be numeric';
		isError = 1;
	}
	if(document.getElementById('tipo').value != '' && document.getElementById('tipo').value != 0 && 
	   document.getElementById('tipo').value != 1 && document.getElementById('tipo').value != 2 )
	{
		document.getElementById('tipoMsg').innerHTML = 'Tipo should be from 0 - 2';
		isError = 1;
	}
	if(isError == 1) return;
	var errCode = document.getElementById('newConnErrCode').value;
	var errName = document.getElementById('newConnErrName').value;
	var errMsg = document.getElementById('newConnErrMsg').value;
	var errType = document.getElementById('newConnErrType').value;
	var errColor = document.getElementById('colorPicker').value;	
//	var ruleAction = document.getElementById('newConnAction').value;	
	var updateRule = document.getElementById('updateRule').value;	
	var nextestado = document.getElementById('nextestado').value;	
	var tipo = document.getElementById('tipo').value;	
			
	var _workflow = conn.sourcePort.workflow;
	
	var sPort = conn.sourcePort;
	var tPort = conn.targetPort;
	
	var connectionsAlreadyForSourceToTarget = false;
	var prevConn = null;
	if(sPort.getConnections().size > 1)
	{
		for(var i=0; i<sPort.getConnections().size;i++)
		{
			if(conn.id != sPort.getConnections().get(i).id && 
				conn.sourcePort.parentNode.figName == sPort.getConnections().get(i).sourcePort.parentNode.figName &&
				conn.sourcePort.parentNode.process == sPort.getConnections().get(i).sourcePort.parentNode.process &&
				conn.targetPort.parentNode.figName == sPort.getConnections().get(i).targetPort.parentNode.figName &&
				conn.targetPort.parentNode.process == sPort.getConnections().get(i).targetPort.parentNode.process)
			{
				connectionsAlreadyForSourceToTarget = true;
				prevConn  = sPort.getConnections().get(i);
				break;
			}
		}
		if (connectionsAlreadyForSourceToTarget)
		{
			if(conn.sourcePort!==null){
				conn.sourcePort.detachMoveListener(conn);
				conn.fireSourcePortRouteEvent();
			}
			if(conn.targetPort!==null){
				conn.targetPort.detachMoveListener(conn);
				conn.fireTargetPortRouteEvent();
			}
			conn = prevConn;
		}
	}
	var sourcePhase = conn.sourcePort.parentNode.figName;
	var targetPhase = conn.targetPort.parentNode.figName;		
	
	//firefox is not ready to send # in color in the url string .... removing # from it
	//errColor = errColor.substr(errColor.indexOf('#') + 1);
	//var data = "nextestado="+nextestado+"&ruleAction="+ruleAction+"&updateRule="+updateRule+"&sourceProcess="+sPort.parentNode.process+"&sourcePhase="+sourcePhase+"&targetProcess="+conn.targetPort.parentNode.process+"&targetPhase="+targetPhase+"&errCode="+errCode+"&errColor="+errColor+"&errName="+errName+"&errType="+errType+"&errMsg="+errMsg;
	var data = "tipo="+tipo+"&nextestado="+nextestado+"&updateRule="+updateRule+"&sourceProcess="+sPort.parentNode.process+"&sourcePhase="+sourcePhase+"&targetProcess="+conn.targetPort.parentNode.process+"&targetPhase="+targetPhase+"&errCode="+errCode+"&errColor="+errColor+"&errName="+errName+"&errType="+errType+"&errMsg="+errMsg;
	
	jQuery.ajax({
		url: 'addRule.jsp',
		type: 'POST',
		data: data,
		success: function(resp) {
			resp = jQuery.trim(resp);
			if(resp.indexOf('SUCCESS') < 0)
			{			
				document.getElementById("addNewRuleMsg").innerHTML = resp;
			}
			else
			{
				jQuery("#modalWindow").dialog('close');
				if(updateRule == "1") conn.removeErrInfo(errCode);
				conn.addErrInfo(errCode, errName, errType, "#"+errColor);
				conn.setColor(new draw2d.Color("#" + errColor));
				conn.setLabelsVisible(_workflow.labelsVisible);
				
				if(!connectionsAlreadyForSourceToTarget)
					draw2d.Workflow.prototype.addFigure.call(_workflow,conn,0,0,true);
				gizWFCurrentFig = null;				
			}
		},
		error : function(resp) {
			alert("Some error while communication with server. Try again or contact administrator");
		}
	});					
}
draw2d.GizmoWorkflow.prototype.removeFigure=function(fig)
{	
	var __gizWorkflow = this;
	if(fig instanceof draw2d.GizmoFigure && this.callAjax)
	{		
		var data = "process="+fig.process+"&phase="+fig.figName+"&loadedProcess="+fig.loadedProcess;		
		jQuery.ajax({
			url: 'deletePhase.jsp',
			type: 'POST',
			data: data,
			async: false,
			success: function(resp) {
				for(var i=0; i<fig.inputPort.getConnections().size; i++)
				{
					fig.inputPort.getConnections().get(i).resetConnectionInfo();					
				}
				for(var i=0; i<fig.outputPort.getConnections().size; i++)
				{
					fig.outputPort.getConnections().get(i).resetConnectionInfo();
				}
				draw2d.Workflow.prototype.removeFigure.call(__gizWorkflow,fig);
			},
			error : function(resp) {
				alert("Some error while communication with server. Try again or contact administrator");
			}			
		});					
	}
	else if(fig instanceof draw2d.GizmoConnection && this.callAjax)
	{
		var sourcePhase = fig.sourcePort.parentNode.figName;
		var targetPhase = fig.targetPort.parentNode.figName;	
		if(fig.errCode.size > 1)
		{
			jQuery.ajax({
				url: 'showConnectionInfo.jsp?sourceProcess='+fig.sourcePort.parentNode.process+'&targetProcess='+fig.targetPort.parentNode.process+'&sourcePhase='+sourcePhase+'&targetPhase='+targetPhase+'&forDelete=1',
				type: 'POST',
				success: function(resp) {
					resp = jQuery.trim(resp);
					jQuery("#modalWindow").dialog("option","title","Delete Rule");
					jQuery("#modalWindow").dialog("option","width","450");
					jQuery("#modalWindow").dialog("option","height","auto");		
					jQuery("#modalWindow").html(resp);
					jQuery("#modalWindow").dialog('open');
				},
				error : function(resp) {
					alert("Some error while communication with server. Try again or contact administrator");
				}
			});								
		}
		else
		{			
			var errCode = fig.errCode.get(0);
			var data = "sourceProcess="+fig.sourcePort.parentNode.process+"&targetProcess="+fig.targetPort.parentNode.process+"&sourcePhase="+sourcePhase+"&targetPhase="+targetPhase+"&errCode="+errCode;
			jQuery.ajax({
				url: 'deleteRule.jsp',
				type: 'POST',
				data: data,
				success: function(resp) {
					draw2d.Workflow.prototype.removeFigure.call(__gizWorkflow,fig);
				},
				error : function(resp) {
					alert("Some error while communication with server. Try again or contact administrator");
				}			
			});					
		}
	}
	else
		draw2d.Workflow.prototype.removeFigure.call(this,fig);
};
draw2d.GizmoWorkflow.prototype.setCallAjax=function(_callAjax)
{
	this.callAjax = _callAjax;
};
draw2d.GizmoWorkflow.prototype.setPartialUpdate=function(_partialUpdate)
{
	this.partialUpdate = _partialUpdate;
};
draw2d.GizmoWorkflow.prototype.showConnectionLabels=function()
{	
	this.labelsVisible = true;
	for(var i=0; i<this.lines.size; i++)
	{
		if(this.lines.get(i) instanceof draw2d.GizmoConnection) this.lines.get(i).showLabels();
	}
};
draw2d.GizmoWorkflow.prototype.hideConnectionLabels=function()
{	
	this.labelsVisible = false;
	for(var i=0; i<this.lines.size; i++)
	{
		if(this.lines.get(i) instanceof draw2d.GizmoConnection) this.lines.get(i).hideLabels();
	}
};
draw2d.GizmoWorkflow.prototype.setCurrentFigure=function(_fig)
{
	gizWFCurrentFig = _fig;
};