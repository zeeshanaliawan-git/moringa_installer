/*
* This class extends draw2d.Workflow class and draw the figures.
* The functions addFigure and removeFigure are overwritten as we have to show dialog box and also make ajax calls here
* To let the workflow know when we are ready for ajax calls, the function setCallAjax is introduced
*/

var gizWFCurrentFig=null;
var ____workflow=null;
var defaultWidthFigure = 120;
var defaultHeightFigure = 80;
var copyToCompartment=null;
var copyToX=null;
var copyToY=null;
var isLoop = false;

draw2d.GizmoWorkflow=function(process, id, modalWindowId)
{
	try{
		if(!id)
		{
			return;
		}
		this.process = process;
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
		
		this.modalWindowId = modalWindowId;
		
		this.phaseGroups = new draw2d.ArrayList();
		this.connectionGroups = new draw2d.ArrayList();
		this.profileFigures = new draw2d.ArrayList();
		this.copiedPhase = null;
		this.anyMenuShowing=false;
		this.isIE=false;
		this.arrowsOpacity=0.4;
		this.deleteFromMenu = false;
		____workflow = this;
		this.deltaY=0;
	}
	catch(e){
		pushErrorStack(e,"draw2d.GizmoWorkflow=function(/*:String*/ id, /*:String*/ process)");
	}
};
draw2d.GizmoWorkflow.prototype=new draw2d.Workflow();
draw2d.GizmoWorkflow.prototype.type="draw2d.GizmoWorkflow";
draw2d.GizmoWorkflow.prototype.clear=function()
{
	draw2d.Workflow.prototype.clear.call(this);
	this.phaseGroups = new draw2d.ArrayList();
	this.connectionGroups = new draw2d.ArrayList();
	this.profileFigures = new draw2d.ArrayList();
	this.copiedPhase = null;
	this.anyMenuShowing=false;
	gizWFCurrentFig=null;
	isLoop=false;
};
draw2d.GizmoWorkflow.prototype.addFigure=function(fig,xPos,yPos)
{	
	//we need to set the color of connection as user selects it so will draw connection in OnNewConnection function
	if( (fig instanceof draw2d.GizmoConnection && this.callAjax) ||
		(fig instanceof draw2d.GizmoConnection && this.partialUpdate) )
	{
		var _error = false;
		if(fig.sourcePort instanceof draw2d.OutputPort && fig.targetPort instanceof draw2d.OutputPort) _error = true;
		if(fig.sourcePort instanceof draw2d.InputPort && fig.targetPort instanceof draw2d.InputPort) _error = true;

		if(fig.sourcePort.parentNode.group.id === fig.targetPort.parentNode.group.id) _error = true;
		if(fig.sourcePort.parentNode.group.isExternalPhaseGroup) _error = true;// we dont allow other process node to be source phase. It can only be target phase
		if(_error)
		{
			draw2d.Workflow.prototype.addFigure.call(____workflow,fig,0,0,true);
			draw2d.Workflow.prototype.removeFigure.call(____workflow,fig);											
			return false;
		}
		
		//the connection which was added by user need to be added to workflow and then removed immediately otherwise it takes up a space in workflow 
		//and is also associated to the phase which should not be the case as we are going to add all connections ourselves now. 
		draw2d.Workflow.prototype.addFigure.call(____workflow,fig,xPos,yPos,true);
		draw2d.Workflow.prototype.removeFigure.call(____workflow,fig);											
		gizWFCurrentFig = fig;
		oldjquery.ajax({
			url: 'showAddRule.jsp',
			type: 'GET',
			cache: false,
			success: function(resp) {
				resp = oldjquery.trim(resp);
				oldjquery('#'+____workflow.modalWindowId).dialog("option","title","New Rule");
				oldjquery('#'+____workflow.modalWindowId).dialog("option","width","auto");
				oldjquery('#'+____workflow.modalWindowId).dialog("option","height","auto");		
				oldjquery('#'+____workflow.modalWindowId).html(resp);
				oldjquery('#'+____workflow.modalWindowId).dialog('open');
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
draw2d.GizmoWorkflow.prototype.onNewPhase=function(currentProfile, x, y)
{	
	if(this.process === '#' || this.process === "")
	{
		alert('Select a process');
		return;
	}				
	html = "<div style='text-align:left'><div id='newPhaseMsg' class='errMessage'>&nbsp;</div>" + 
		   "<table width='95%'><tr><td>Phase name : </td><td> <input type='text' value='' name='newPhaseName' id='newPhaseName' maxlength='32' size='33'/></td></tr>" + 
		   "<tr><td>Display name : </td><td> <input type='text' value='' name='newPhaseDisplayName' id='newPhaseDisplayName' maxlength='100' size='33'/></td></tr>" +
			"<tr><td>Priority : </td><td> <input type='text' value='' name='priority' id='priority' size='17'/></td></tr>" + 
		   "<tr><td>Execute : </td><td> <input type='text' value='' name='execute' id='execute' maxlength='64' size='17'/></td></tr>" + 
		   "<tr><td>Color : </td><td> <input type='text' value='' name='color' id='color' maxlength='7' size='17'/></td></tr>" + 
		   "<tr><td>Visible : </td><td> <input type='checkbox' id='phaseVisible' name='phaseVisible' value='1' checked/></td></tr>" + 
		   "<tr><td>Reverse : </td><td> <input type='checkbox' id='isReverse' name='isReverse' value='1' checked/></td></tr>" + 
		   "<tr><td>Opr Type : </td><td> <input type='radio' name='oprType' id='oprTypeT' value='T'>Technical</input> <input type='radio' id='oprTypeO' name='oprType' value='O' checked>Operational</input> </td></tr>" + 
		   "<tr><td>Actors : </td><td> <textarea value='' name='actors' id='actors' rows='4' cols='50'></textarea></td></tr>" + 
		   "</table>" + 
		   "<div style='text-align:center; margin-top:3px'><input type='button' id='newPhaseBtn' value='Ok' onclick='____workflow.onOkNewPhase(\""+currentProfile+"\","+x+","+y+")'></div></div>" ;

	oldjquery('#'+this.modalWindowId).dialog("option","title","New Phase");
	oldjquery('#'+this.modalWindowId).dialog("option","width","550px");
	oldjquery('#'+this.modalWindowId).dialog("option","height","auto");
	oldjquery('#'+this.modalWindowId).unbind("dialogclose");	   
	oldjquery('#'+this.modalWindowId).html(html);
        oldjquery('#color').ColorPicker({onSubmit: function(hsb, hex, rgb, el) { oldjquery(el).val('#'+hex); oldjquery(el).ColorPickerHide(); }});
	oldjquery('#'+this.modalWindowId).dialog('open');	
};
draw2d.GizmoWorkflow.prototype.OnNewConnection=function()
{
	var conn = gizWFCurrentFig;
	document.getElementById("addNewRuleMsg").innerHTML = "&nbsp;";
	if(document.getElementById("errCodeMsg")) document.getElementById("errCodeMsg").innerHTML = "&nbsp;";
	document.getElementById("errColorMsg").innerHTML = "&nbsp;";
	document.getElementById("nextestadoMsg").innerHTML = "&nbsp;";
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
	if(isError == 1) return;
	var errCode = document.getElementById('newConnErrCode').value;
	var errName = document.getElementById('newConnErrName').value;
	var errMsg = document.getElementById('newConnErrMsg').value;
	var errType = document.getElementById('newConnErrType').value;
	var errColor = document.getElementById('colorPicker').value;	
//	var ruleAction = document.getElementById('newConnAction').value;	
	var updateRule = document.getElementById('updateRule').value;
	var nextestado = document.getElementById('nextestado').value;	
	
	var connRdv = document.getElementById('newConnRdv').value;	
	var connType = document.getElementById('newConnType').value;			
	
	var sPort = conn.sourcePort;
	var tPort = conn.targetPort;
	//alert(sPort.getConnections().size);
	var connectionsAlreadyForSourceToTarget = false;
	var prevConn = null;
	if(sPort.getConnections().size > 0 && updateRule != 1)
	{
		for(var i=0; i<sPort.getConnections().size;i++)
		{
			if(conn.id != sPort.getConnections().get(i).id && 
				conn.sourcePort.parentNode.group.figName == sPort.getConnections().get(i).sourcePort.parentNode.group.figName &&
				conn.sourcePort.parentNode.group.process == sPort.getConnections().get(i).sourcePort.parentNode.group.process &&
				conn.targetPort.parentNode.group.figName == sPort.getConnections().get(i).targetPort.parentNode.group.figName &&
				conn.targetPort.parentNode.group.process == sPort.getConnections().get(i).targetPort.parentNode.group.process)
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
	else if(updateRule == 1) connectionsAlreadyForSourceToTarget = true;
	var sourcePhase = conn.sourcePort.parentNode.group.figName;
	var targetPhase = conn.targetPort.parentNode.group.figName;		

	//firefox is not ready to send # in color in the url string .... removing # from it
	//errColor = errColor.substr(errColor.indexOf('#') + 1);
	var data = "connType="+connType+"&connRdv="+connRdv+"&nextestado="+nextestado+"&updateRule="+updateRule+"&sourceProcess="+sPort.parentNode.group.process+"&sourcePhase="+sourcePhase+"&targetProcess="+conn.targetPort.parentNode.group.process+"&targetPhase="+targetPhase+"&errCode="+errCode+"&errColor="+errColor+"&errName="+errName+"&errType="+errType+"&errMsg="+errMsg;

	oldjquery.ajax({
		url: 'addRule.jsp',
		type: 'POST',
		data: data,
		dataType: 'json',
		success: function(resp) {
			if(resp.STATUS === "ERROR")
			{			
				document.getElementById("addNewRuleMsg").innerHTML = resp.MESSAGE;
			}
			else
			{		
				var cGrp = conn.group;
				oldjquery('#'+____workflow.modalWindowId).dialog('close');
				if(!connectionsAlreadyForSourceToTarget)
				{
					//the connection which was added by user need to be added to workflow and then removed immediately otherwise it takes up a space in workflow 
					//and is also associated to the phase which should not be the case as we are going to add all connections ourselves now. 
//					draw2d.Workflow.prototype.addFigure.call(____workflow,conn,0,0,true);
//					draw2d.Workflow.prototype.removeFigure.call(____workflow,conn);									
					var srcPhaseGrp = conn.sourcePort.parentNode.group;
					var targetPhaseGrp = conn.targetPort.parentNode.group;
					cGrp = new GizmoConnectionGroup();
					____workflow.addConnectionGroup(cGrp);
					for(var k=0;k<srcPhaseGrp.children.size;k++)
						for(var m=0;m<targetPhaseGrp.children.size;m++)
						{
							var c1 = new draw2d.GizmoConnection();
							c1.setSource(srcPhaseGrp.children.get(k).getPort("output"));
							c1.setTarget(targetPhaseGrp.children.get(m).getPort("input"));									
							cGrp.addChild(c1);							
							cGrp.addErrInfo(errCode, errName, errType, "#"+errColor);
							draw2d.Workflow.prototype.addFigure.call(____workflow,c1,0,0,true);							
						}					
				}
				//else draw2d.Workflow.prototype.addFigure.call(____workflow,conn,0,0,true);
				if(updateRule == "1") cGrp.removeErrInfo(errCode);
				if(connectionsAlreadyForSourceToTarget) cGrp.addErrInfo(errCode, errName, errType, "#"+errColor);				
				//conn.setColor(new draw2d.Color("#" + errColor));
				cGrp.setLabelsVisible(____workflow.labelsVisible);
				cGrp.refreshErrInfo();
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
	if(fig instanceof draw2d.GizmoFigure && this.callAjax)
	{		
		if(this.deleteFromMenu)
		{
			this.deleteFromMenu = false;
			if(!confirm("Are you sure to delete the phase?")) return false;
		}
		var data = "process="+fig.group.process+"&phase="+fig.group.figName+"&loadedProcess="+fig.group.loadedProcess+"&profile="+fig.profile;
		oldjquery.ajax({
			url: 'deletePhase.jsp',
			type: 'POST',
			data: data,
			async: false,
			success: function(resp) {
				var connsToRemove = new draw2d.ArrayList();
				for(var i=0; i<fig.inputPort.getConnections().size; i++)
				{				
					connsToRemove.add(fig.inputPort.getConnections().get(i));
				}
				for(var i=0; i<fig.outputPort.getConnections().size; i++)
				{
					connsToRemove.add(fig.outputPort.getConnections().get(i));
				}			
				var _group = fig.group;
				_group.removeChild(fig);
				if(!_group.isExternalPhaseGroup) fig.getParent().removeChild(fig);

				//we need to remove phase group as all its children are removed
				if(_group.children.size === 0) ____workflow.removePhaseGroup(_group);
				draw2d.Workflow.prototype.removeFigure.call(____workflow,fig);
				for(var j=0;j<connsToRemove.size;j++)
				{
					draw2d.Workflow.prototype.removeFigure.call(____workflow,connsToRemove.get(j));				
					var cGrp = connsToRemove.get(j).group;
					cGrp.removeChild(connsToRemove.get(j));
					if(cGrp.children.size === 0) ____workflow.removeConnectionGroup(cGrp);					
				}
			},
			error : function(resp) {
				alert("Some error while communication with server. Try again or contact administrator");
			}			
		});					
	}
	else if(fig instanceof draw2d.GizmoConnection && this.callAjax)
	{
		if(fig.allowDelete)
		{
			var sourcePhase = fig.sourcePort.parentNode.group.figName;
			var targetPhase = fig.targetPort.parentNode.group.figName;	
			if(fig.group.errCode.size > 1)
			{
				oldjquery.ajax({
					url: 'showConnectionInfo.jsp?sourceProcess='+fig.sourcePort.parentNode.group.process+'&targetProcess='+fig.targetPort.parentNode.group.process+'&sourcePhase='+sourcePhase+'&targetPhase='+targetPhase+'&forDelete=1',
					type: 'POST',
					success: function(resp) {
						resp = oldjquery.trim(resp);
						oldjquery('#'+____workflow.modalWindowId).dialog("option","title","Delete Rule");
						oldjquery('#'+____workflow.modalWindowId).dialog("option","width","450");
						oldjquery('#'+____workflow.modalWindowId).dialog("option","height","auto");		
						oldjquery('#'+____workflow.modalWindowId).html(resp);
						oldjquery('#'+____workflow.modalWindowId).dialog('open');
					},
					error : function(resp) {
						alert("Some error while communication with server. Try again or contact administrator");
					}
				});								
			}
			else
			{			
				var errCode = fig.group.errCode.get(0);
				var data = "sourceProcess="+fig.sourcePort.parentNode.group.process+"&targetProcess="+fig.targetPort.parentNode.group.process+"&sourcePhase="+sourcePhase+"&targetPhase="+targetPhase+"&errCode="+errCode;
				oldjquery.ajax({
					url: 'deleteRule.jsp',
					type: 'POST',
					data: data,
					success: function(resp) {
						var conn = null;
						for(var i=0; i<____workflow.lines.size; i++)
						{
							if(____workflow.lines.get(i) instanceof draw2d.GizmoConnection &&
								____workflow.lines.get(i).sourcePort.parentNode.group.figName == sourcePhase &&
								____workflow.lines.get(i).sourcePort.parentNode.group.process == fig.sourcePort.parentNode.group.process &&
								____workflow.lines.get(i).targetPort.parentNode.group.figName == targetPhase &&
								____workflow.lines.get(i).targetPort.parentNode.group.process == fig.targetPort.parentNode.group.process )
							{
								conn = ____workflow.lines.get(i);
								break;
							}
						}							
						if(conn)
						{
							var grp = conn.group;
							grp.removeErrInfo(errCode);
							for(var j=0; j<grp.children.size;j++) draw2d.Workflow.prototype.removeFigure.call(____workflow,grp.children.get(j));
							____workflow.removeConnectionGroup(grp);
						}					
					},
					error : function(resp) {
						alert("Some error while communication with server. Try again or contact administrator");
					}			
				});					
			}
		}
		else
		{
			alert("Incoming rule from an external process cannot be deleted here. Load external process to delete the rule");
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
	for(var i=0; i<this.connectionGroups.size; i++)
	{
		this.connectionGroups.get(i).showLabels();
	}	
};
draw2d.GizmoWorkflow.prototype.hideConnectionLabels=function()
{	
	this.labelsVisible = false;
	for(var i=0; i<this.connectionGroups.size; i++)
	{
		this.connectionGroups.get(i).hideLabels();
	}
};
draw2d.GizmoWorkflow.prototype.setCurrentFigure=function(_fig)
{
	gizWFCurrentFig = _fig;
};
draw2d.GizmoWorkflow.prototype.addPhaseGroup=function(figure)
{
	var alreadyExists = false;
	for(var i=0;i<this.phaseGroups.size;i++)
	{
		if(figure.id === this.phaseGroups.get(i).id)
		{
			alreadyExists = true;
			break;
		}
	}
	if(!alreadyExists) this.phaseGroups.add(figure);
};
draw2d.GizmoWorkflow.prototype.addConnectionGroup=function(figure)
{
	var alreadyExists = false;
	for(var i=0;i<this.connectionGroups.size;i++)
	{
		if(figure.id === this.connectionGroups.get(i).id)
		{
			alreadyExists = true;
			break;
		}
	}
	if(!alreadyExists) this.connectionGroups.add(figure);
};
draw2d.GizmoWorkflow.prototype.removePhaseGroup=function(figure)
{
	var index = -1;
	for(var i=0;i<this.phaseGroups.size;i++)
	{
		if(figure.id === this.phaseGroups.get(i).id)
		{
			index = i;
			break;
		}
	}
	if(index > -1) this.phaseGroups.removeElementAt(index);
};
draw2d.GizmoWorkflow.prototype.removeConnectionGroup=function(figure)
{
	var index = -1;
	for(var i=0;i<this.connectionGroups.size;i++)
	{
		if(figure.id === this.connectionGroups.get(i).id)
		{
			index = i;
			break;
		}
	}
	if(index > -1) this.connectionGroups.removeElementAt(index);
};
draw2d.GizmoWorkflow.prototype.onOkNewPhase = function (currentProfile, pX, pY)
{
	var _pY = parseFloat(pY) - parseFloat(____workflow.deltaY);
	if(oldjquery('#newPhaseName').val() == '')
	{
		oldjquery('#newPhaseMsg').html("Enter Phase name");
		return;
	}
	if(oldjquery('#priority').val() != '' && !IsNumeric(oldjquery('#priority').val()))
	{
		oldjquery('#newPhaseMsg').html("Priority should be numeric");
		return;
	}					
	
	if(oldjquery('#newPhaseDisplayName').val() == '') oldjquery('#newPhaseDisplayName').val(oldjquery('#newPhaseName').val());
	
	var vis = 0;
	if(document.getElementById('phaseVisible').checked) vis = 1;

/*	var rulesVisibleTo = "";
	for(var i=0;i<document.getElementsByName("rulesVisibleTo").length; i++)
	{
		if(document.getElementsByName("rulesVisibleTo")[i].checked && rulesVisibleTo == "") rulesVisibleTo = document.getElementsByName("rulesVisibleTo")[i].value;
		else if(document.getElementsByName("rulesVisibleTo")[i].checked) rulesVisibleTo += "|" + document.getElementsByName("rulesVisibleTo")[i].value;
	}*/

	var isReverse = 0;
	if(document.getElementById('isReverse').checked) isReverse = 1;
	var oprType = "O";
	if(document.getElementById('oprTypeT').checked) oprType = "T";
	var data = "topLeftX="+pX+"&topLeftY="+_pY+"&width="+defaultWidthFigure+"&height="+defaultHeightFigure+"&oprType="+oprType+"&isReverse="+isReverse+"&currentProfile="+currentProfile+"&visible="+vis+"&action=new&process="+____workflow.process+"&phase="+oldjquery('#newPhaseName').val()+"&priority="+oldjquery('#priority').val()+"&execute="+oldjquery('#execute').val()+"&actors="+oldjquery('#actors').val()+"&displayName="+oldjquery('#newPhaseDisplayName').val();

	oldjquery.ajax({
		url: 'addNewPhase.jsp',
		type: 'POST',
		data: data,
		dataType:'json',
		success: function(resp) {
			if(resp.STATUS === 'SUCCESS')
			{	
				var vis = 0;				
				if(document.getElementById('phaseVisible').checked) vis = 1;
				
				var newFigGroup = new GizmoFigureGroup(oldjquery('#newPhaseName').val(),oldjquery('#actors').val(),oldjquery('#priority').val(),oldjquery('#execute').val(),oldjquery('#color').val(), vis, oldjquery('#newPhaseDisplayName').val(),____workflow.process,____workflow.process);
				____workflow.addPhaseGroup(newFigGroup);
				var newNode= new draw2d.GizmoFigure(defaultWidthFigure,defaultHeightFigure,currentProfile);
				newNode.setTitle(oldjquery('#newPhaseDisplayName').val());
				newNode.setContent('');
				newNode.footer.style.backgroundColor="white";
				workflow.addFigure(newNode, pX, pY);
				newFigGroup.addChild(newNode);
				oldjquery('#showLabels').attr('checked', false);
				oldjquery('#toolBarDiv').show();
				if(oldjquery('#toolBar1')) oldjquery('#toolBar1').show();
				if(oldjquery('#toolBar2')) oldjquery('#toolBar2').show();
				oldjquery("#modalWindow").dialog('close');
				for(var i=0;i<____workflow.getFigures().size; i++)
					if(____workflow.getFigures().get(i) instanceof draw2d.GizmoProfileFigure && ____workflow.getFigures().get(i).name === currentProfile)
					{
						____workflow.getFigures().get(i).addChild(newNode);
						break;
					}
			}
			else oldjquery('#newPhaseMsg').html(resp.MESSAGE);
		},
		error : function(resp) {
			alert("Some error while communication with server. Try again or contact administrator");
		}				
	});						
};		
draw2d.GizmoWorkflow.prototype.onCopyPhase = function (fig)
{
	this.copiedPhase = fig;
};
draw2d.GizmoWorkflow.prototype.canPaste=function(compartment)
{
	var found = false;
	for(var i=0;i<compartment.children.size;i++)
	{
		if(compartment.children.get(i) instanceof draw2d.GizmoFigure && compartment.children.get(i).group.figName === this.copiedPhase.group.figName)
		{
			found = true;
			break;
		}
	}
	if(found) return false;
	return true;
};
draw2d.GizmoWorkflow.prototype.onPastePhase = function (compartment, pX, pY)
{
	var _pY = parseFloat(pY) - parseFloat(____workflow.deltaY);

	if(this.copiedPhase === null || this.copiedPhase.getParent() === null) alert("Copy a phase first");
	else if(compartment.id === this.copiedPhase.getParent().id) alert("Cannot copy into same profile");
	else
	{
		if(!this.canPaste(compartment)) alert("Phase already exists in this profile");
		else
		{
			var data = "width="+defaultWidthFigure+"&height="+defaultHeightFigure+"&process="+this.copiedPhase.group.process+"&phase="+this.copiedPhase.group.figName+"&profile="+compartment.name+"&topLeftX="+pX+"&topLeftY="+_pY;

			oldjquery.ajax({
				url: 'copyPhase.jsp',
				type: 'POST',
				data: data,
				dataType:'json',
				async:false,
				success: function(resp) {
					if(resp.STATUS === 'SUCCESS')
					{	
						var newNode= new draw2d.GizmoFigure(defaultWidthFigure,defaultHeightFigure,compartment.name);
						newNode.setTitle(____workflow.copiedPhase.group.displayName);
						newNode.setContent('');
						newNode.footer.style.backgroundColor="white";
						workflow.addFigure(newNode, pX, pY);
						compartment.addChild(newNode);
						____workflow.copiedPhase.group.addChild(newNode);
						for(var j=0;j<____workflow.copiedPhase.outputPort.getConnections().size;j++)
						{
							var c1 = new draw2d.GizmoConnection();
							c1.setSource(newNode.getPort("output"));
							c1.setTarget(____workflow.copiedPhase.outputPort.getConnections().get(j).targetPort);				
							____workflow.copiedPhase.outputPort.getConnections().get(j).group.addChild(c1);
							____workflow.copiedPhase.outputPort.getConnections().get(j).group.refreshErrInfo();
							draw2d.Workflow.prototype.addFigure.call(____workflow,c1,0,0,true);							
						}
						
						for(var j=0;j<____workflow.copiedPhase.inputPort.getConnections().size;j++)
						{
							var c1 = new draw2d.GizmoConnection();
							c1.setSource(____workflow.copiedPhase.inputPort.getConnections().get(j).sourcePort);
							c1.setTarget(newNode.getPort("input"));
							____workflow.copiedPhase.inputPort.getConnections().get(j).group.addChild(c1);
							____workflow.copiedPhase.inputPort.getConnections().get(j).group.refreshErrInfo();
							draw2d.Workflow.prototype.addFigure.call(____workflow,c1,0,0,true);							
						}											
					}
					else alert(resp.MESSAGE);
					____workflow.copiedPhase = null;
				},
				error : function(resp) {
					alert("Some error while communication with server. Try again or contact administrator");
					____workflow.copiedPhase = null;
				}				
			});									
		}		
	}	
};
draw2d.GizmoWorkflow.prototype.addProfileFigure=function(figure)
{
	var alreadyExists = false;
	for(var i=0;i<this.profileFigures.size;i++)
	{
		if(figure.id === this.profileFigures.get(i).id)
		{
			alreadyExists = true;
			break;
		}
	}
	if(!alreadyExists) this.profileFigures.add(figure);
};
draw2d.GizmoWorkflow.prototype.removeProfileGroup=function(figure)
{
	var index = -1;
	for(var i=0;i<this.profileFigures.size;i++)
	{
		if(figure.id === this.profileFigures.get(i).id)
		{
			index = i;
			break;
		}
	}
	if(index > -1) this.profileFigures.removeElementAt(index);
};
draw2d.GizmoWorkflow.prototype.setCurrentSelection=function(obj)
{
	var prevSelection = this.currentSelection;
	draw2d.Workflow.prototype.setCurrentSelection.call(this,obj);
	var currentSelection = this.currentSelection;
	if(prevSelection && prevSelection instanceof draw2d.GizmoFigure)
	{
		for(var i=0; i<prevSelection.inputPort.getConnections().getSize(); i++)
		{
			prevSelection.inputPort.getConnections().get(i).setLineWidth(1);			
		}
		for(var i=0; i<prevSelection.outputPort.getConnections().getSize(); i++)
		{
			prevSelection.outputPort.getConnections().get(i).setLineWidth(1);
		}		
	}
	if(currentSelection && currentSelection instanceof draw2d.GizmoFigure)
	{		
		for(var i=0; i<currentSelection.inputPort.getConnections().getSize(); i++)
		{
			currentSelection.inputPort.getConnections().get(i).setLineWidth(2);
		}
		for(var i=0; i<currentSelection.outputPort.getConnections().getSize(); i++)
		{
			currentSelection.outputPort.getConnections().get(i).setLineWidth(2);
		}		
	}
};

draw2d.GizmoWorkflow.prototype.getContextMenu=function(){
if(!this.callAjax) return null;
if(this.anyMenuShowing && this.menu) return null;
var menu=new draw2d.Menu();
menu.html.style.textAlign="left";
//menu.className="draw2dMenu";
//menu.html.style.color="#CA011F";
var oThis=this;
menu.appendMenuItem(new draw2d.MenuItem("Add External Phase",null,function(){
oThis.onExternalPhase(oThis.clickX, oThis.clickY);
}));
return menu;
};
draw2d.GizmoWorkflow.prototype.onContextMenu=function(x,y){
	this.clickX = x;
	this.clickY = y;
	draw2d.Workflow.prototype.onContextMenu.call(this, x, y);
};

draw2d.GizmoWorkflow.prototype.onExternalPhase=function(x,y)
{
	if(this.process === '#' || this.process === "")
	{
		alert('Select a process');
		return;
	}				
	html = "<div id='externalPhaseMsg' class='errMessage'>&nbsp;</div>" + 
		   "<table width='95%'><tr><td>Process : </td><td><select name='otherProcess' id='otherProcess' onchange='____workflow.loadPhases()'>";
	
		for(var i=0; i<document.getElementById("process").options.length;i++)
		{
			var opt = document.getElementById("process").options[i].value;
			if(opt != document.getElementById("process").value)
				html += "<option value='"+opt+"'>"+document.getElementById("process").options[i].text+"</option>";
		}
	html += "</select></td></tr>";
	html += "<tr><td>Phase : </td><td><select name='otherProcessPhase' id='otherProcessPhase'><option value='#'>-- Select Phase --</option></td></tr>";
	html += "<tr><td colspan=2><input type='button' value='Ok' onclick='____workflow.onSelectExternalProcess("+x+","+y+")'/></td></tr>";
	html += "</table>";
	oldjquery('#'+____workflow.modalWindowId).dialog("option","title","External Phase");
	oldjquery('#'+____workflow.modalWindowId).dialog("option","width","350px");
	oldjquery('#'+____workflow.modalWindowId).dialog("option","height","auto");
	oldjquery('#'+____workflow.modalWindowId).unbind("dialogclose");	   
	oldjquery('#'+____workflow.modalWindowId).html(html);
	oldjquery('#'+____workflow.modalWindowId).dialog('open');
		
};
draw2d.GizmoWorkflow.prototype.onSelectExternalProcess=function(pX, pY)
{
	var _pY = parseFloat(pY) - parseFloat(____workflow.deltaY);
	oldjquery("#externalPhaseMsg").html("");
	if(oldjquery("#otherProcessPhase").val() == '#')
	{	
		oldjquery("#externalPhaseMsg").html("Select Phase");
		return;
	}
	oldjquery.ajax({
		url: 'addExternalPhase.jsp',
		type: 'POST',
		data: {topLeftX: pX, topLeftY: _pY, width: defaultWidthFigure, height: defaultHeightFigure, process: oldjquery('#process').val(), targetProcess: oldjquery('#otherProcess').val(), targetPhase: oldjquery('#otherProcessPhase').val() },
		dataType: 'json',
		success: function(resp) {
			if(resp.RESPONSE_TYPE == "SUCCESS")
			{
				var displayName = document.getElementById('otherProcessPhase')[document.getElementById('otherProcessPhase').selectedIndex].text;
				var groupObj = new GizmoFigureGroup(oldjquery('#otherProcessPhase').val(),'','','','','',displayName,oldjquery('#otherProcess').val(), ____workflow.process);
				____workflow.addPhaseGroup(groupObj);					
				var newNode= new draw2d.GizmoFigure(defaultWidthFigure,defaultHeightFigure,'');
				newNode.setTitle(displayName);
				newNode.setContent('<div style="background-color:gray; color:white; font-weight: bold"> Process : '+oldjquery('#otherProcess').val()+'</div>');
				newNode.footer.style.backgroundColor="white";
				//newNode.isIntraProcess = true;
				groupObj.addChild(newNode);
				workflow.addFigure(newNode, pX,pY);
				oldjquery("#modalWindow").dialog('close');			
			}
			else
			{
				oldjquery("#externalPhaseMsg").html(resp.MESSAGE);						
			}
		}
	});						
};
draw2d.GizmoWorkflow.prototype.loadPhases=function()
{
	oldjquery.ajax({
		url: 'loadExternalPhases.jsp',
		type: 'POST',
		data: {targetProcess : oldjquery("#otherProcess").val(), process : oldjquery("#process").val()},
		dataType: 'json',
		success: function(resp) {
			var opts1 = document.getElementById('otherProcessPhase').options;
			opts1.length = 1;
			document.getElementById('otherProcessPhase').selectedIndex=0;
			for( var i = 0, j = 1 ; i < resp.PHASES.length ; i++ )
			{
				opts1[j] = new Option(resp.PHASES[i].PHASE.DISPLAYNAME);
				opts1[j].value = resp.PHASES[i].PHASE.NAME;
				j++;
			}
		}
	});						
};
draw2d.GizmoWorkflow.prototype.setCopyToPhaseInfo=function(_fig, _compartment, _x, _y)
{
	this.originalPhaseMoved = _fig;
	this.copyToCompartment=_compartment;
	this.copyToX=_x;
	this.copyToY=_y;
};
//these functions are called from a dialog box so we cant use this reference in these functions as from dialog box/ajax these functions are called using
//draw2d.GizmoWorkflow.prototype.copySpecial.call or draw2d.GizmoWorkflow.prototype.moveSpecial.call which means once called this reference wont work here
draw2d.GizmoWorkflow.prototype.copySpecial=function()
{
	oldjquery('#'+____workflow.modalWindowId).dialog('close');
	if(!____workflow.copyToCompartment) 
	{
		alert("Cannot copy here");
		return null;
	}
	____workflow.onPastePhase(____workflow.copyToCompartment, ____workflow.copyToX, ____workflow.copyToY);
};
draw2d.GizmoWorkflow.prototype.moveSpecial=function()
{
	oldjquery('#'+____workflow.modalWindowId).dialog('close');
	if(!____workflow.copyToCompartment) 
	{
		alert("Cannot move here");
		return null;
	}
	if(!____workflow.canPaste(____workflow.copyToCompartment)) 
	{
		alert("Phase already exists in this profile");
		return;
	}
	____workflow.onPastePhase(____workflow.copyToCompartment, ____workflow.copyToX, ____workflow.copyToY);
	____workflow.removeFigure(____workflow.originalPhaseMoved);
};
