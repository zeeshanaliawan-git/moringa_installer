/*
* This class is responsible for rendering the rounded figure. It extends draw2d.Node class
*/
var editPhase = null;

draw2d.GizmoFigure=function(width, height, profile){
this.cornerWidth=15;
this.cornerHeight=15;
this.outputPort=null;
this.inputPort=null;
draw2d.Node.call(this);
this.setDimension(width, height);
this.originalHeight=-1;
this.allowDoubleClick=true;
this.profile = profile;
this.group = null;
this.hiddenConnections = new draw2d.ArrayList();
this.isHidden=false;
this.profileCompartmentIsHidden=false;
};
draw2d.GizmoFigure.prototype=new draw2d.Node();
draw2d.GizmoFigure.prototype.type="GizmoFigure";
draw2d.GizmoFigure.prototype.createHTMLElement=function(){
var item=document.createElement("div");
item.id=this.id;
item.style.position="absolute";
item.style.left=this.x+"px";
item.style.top=this.y+"px";
item.style.height=this.width+"px";
item.style.width=this.height+"px";
item.style.margin="0px";
item.style.padding="0px";
item.style.outline="none";
item.style.zIndex=""+draw2d.Figure.ZOrderBaseIndex;
this.top_left=document.createElement("div");
this.top_left.style.background="url(img/circle.png) no-repeat top left";
this.top_left.style.position="absolute";
this.top_left.style.width=this.cornerWidth+"px";
this.top_left.style.height=this.cornerHeight+"px";
this.top_left.style.left="0px";
this.top_left.style.top="0px";
this.top_left.style.fontSize="2px";
this.top_right=document.createElement("div");
this.top_right.style.background="url(img/circle.png) no-repeat top right";
this.top_right.style.position="absolute";
this.top_right.style.width=this.cornerWidth+"px";
this.top_right.style.height=this.cornerHeight+"px";
this.top_right.style.left="0px";
this.top_right.style.top="0px";
this.top_right.style.fontSize="2px";
this.bottom_left=document.createElement("div");
this.bottom_left.style.background="url(img/circle.png) no-repeat bottom left";
this.bottom_left.style.position="absolute";
this.bottom_left.style.width=this.cornerWidth+"px";
this.bottom_left.style.height=this.cornerHeight+"px";
this.bottom_left.style.left="0px";
this.bottom_left.style.top="0px";
this.bottom_left.style.fontSize="2px";
this.bottom_right=document.createElement("div");
this.bottom_right.style.background="url(img/circle.png) no-repeat bottom right";
this.bottom_right.style.position="absolute";
this.bottom_right.style.width=this.cornerWidth+"px";
this.bottom_right.style.height=this.cornerHeight+"px";
this.bottom_right.style.left="0px";
this.bottom_right.style.top="0px";
this.bottom_right.style.fontSize="2px";
this.header=document.createElement("div");
this.header.style.position="absolute";
this.header.style.left=this.cornerWidth+"px";
this.header.style.top="0px";
this.header.style.height=(this.cornerHeight)+"px";
this.header.style.backgroundColor="#CCCCFF";
this.header.style.borderTop="3px solid #666666";
this.header.style.fontSize="9px";
this.header.style.textAlign="center";
this.disableTextSelection(this.header);
this.footer=document.createElement("div");
this.footer.style.position="absolute";
this.footer.style.left=this.cornerWidth+"px";
this.footer.style.top="0px";
this.footer.style.height=(this.cornerHeight-1)+"px";
/*if (navigator.appName.indexOf("Microsoft Internet Explorer") >= 0)
{
	this.footer.style.height=(this.cornerHeight-1)+"px";
}
else
{
	this.footer.style.height=(this.cornerHeight-1)+"px";
}*/

this.footer.style.backgroundColor="white";
this.footer.style.borderBottom="1px solid #666666";
this.footer.style.fontSize="2px";
this.textarea=document.createElement("div");
this.textarea.style.position="absolute";
this.textarea.style.left="0px";
this.textarea.style.top=this.cornerHeight+"px";
this.textarea.style.backgroundColor="white";
this.textarea.style.borderTop="2px solid #666666";
this.textarea.style.borderLeft="1px solid #666666";
this.textarea.style.borderRight="1px solid #666666";
this.textarea.style.overflow="auto";
this.textarea.style.fontSize="8pt";
this.disableTextSelection(this.textarea);
item.appendChild(this.top_left);
item.appendChild(this.header);
item.appendChild(this.top_right);
item.appendChild(this.textarea);
item.appendChild(this.bottom_left);
item.appendChild(this.footer);
item.appendChild(this.bottom_right);
return item;
};
draw2d.GizmoFigure.prototype.setDimension=function(w,h){
draw2d.Node.prototype.setDimension.call(this,w,h);
if(this.top_left!==null){
this.top_right.style.left=(this.width-this.cornerWidth)+"px";
this.bottom_right.style.left=(this.width-this.cornerWidth)+"px";
this.bottom_right.style.top=(this.height-this.cornerHeight)+"px";
this.bottom_left.style.top=(this.height-this.cornerHeight)+"px";
this.textarea.style.width=(this.width-2)+"px";
/*if (navigator.appName.indexOf("Microsoft Internet Explorer") >= 0)
{
	this.textarea.style.width=(this.width-2)+"px";
}
else
{
	this.textarea.style.width=(this.width-2)+"px";
}*/

if((this.height-this.cornerHeight*2) <=0 ){
this.textarea.style.height="20px";
}
else{
this.textarea.style.height=(this.height-this.cornerHeight*2)+"px";
}

if((this.width-this.cornerWidth*2)<=0)
{
	this.header.style.width = "20px";
	this.footer.style.width = "20px";
}
else
{
	this.header.style.width=(this.width-this.cornerWidth*2)+"px";
	this.footer.style.width=(this.width-this.cornerWidth*2)+"px";
}

this.footer.style.top=(this.height-this.cornerHeight)+"px";
}
if(this.outputPort!==null){
this.outputPort.setPosition(this.width+5,this.height/2);
}
if(this.inputPort!==null){
this.inputPort.setPosition(-5,this.height/2);
}
};
draw2d.GizmoFigure.prototype.setTitle=function(title){
this.header.innerHTML=title;
};
draw2d.GizmoFigure.prototype.setContent=function(_5014){
this.textarea.innerHTML=_5014;
};
draw2d.GizmoFigure.prototype.onDragstart=function(x,y){
this.originalX = this.x; 
this.originalY = this.y;
this.originalCompartment = this.getParent();
var _5017=draw2d.Node.prototype.onDragstart.call(this,x,y);
if(this.header===null){
return false;
}
if(y<this.cornerHeight&&x<this.width&&x>(this.width-this.cornerWidth)){
this.toggle();
return false;
}
if(this.originalHeight==-1){
if(this.canDrag===true&&x<parseInt(this.header.style.width)&&y<parseInt(this.header.style.height)){
return true;
}
}else{
return _5017;
}
};
draw2d.GizmoFigure.prototype.setCanDrag=function(flag){
draw2d.Node.prototype.setCanDrag.call(this,flag);
this.html.style.cursor="";
if(this.header===null){
return;
}
if(flag){
this.header.style.cursor="move";
}else{
this.header.style.cursor="";
}
};
draw2d.GizmoFigure.prototype.setWorkflow=function(_5019){
draw2d.Node.prototype.setWorkflow.call(this,_5019);
if(_5019!==null&&this.inputPort===null){
this.inputPort=new draw2d.GizmoInputPort();
this.inputPort.setWorkflow(_5019);
this.inputPort.setName("input");
this.addPort(this.inputPort,-5,this.height/2);
this.outputPort=new draw2d.GizmoOutputPort();
this.outputPort.setMaxFanOut(50);
this.outputPort.setWorkflow(_5019);
this.outputPort.setName("output");
this.addPort(this.outputPort,this.width+5,this.height/2);
}
};
draw2d.GizmoFigure.prototype.toggle=function(){
if(this.group.isExternalPhaseGroup) return false;
if(this.originalHeight==-1){
this.originalHeight=this.height;
this.setDimension(this.width,this.cornerHeight*2);
this.setResizeable(false);
		/*var inConns = this.inputPort.getConnections();
		for(var i=0; i< inConns.getSize(); i++)
		{
			var conn = inConns.get(i);
			//this.incomingConnections.add(conn);
			//this.workflow.removeFigure(inConns.get(i));
			alert(conn.html);
			conn.html.style.display="none";
		}*/

}else{
this.setDimension(this.width,this.originalHeight);
this.originalHeight=-1;
this.setResizeable(true);
		/*var inConns = this.inputPort.getConnections();
		for(var i=0; i< inConns.getSize(); i++)
		{
			var conn = inConns.get(i);
			//this.incomingConnections.add(conn);
			//this.workflow.removeFigure(inConns.get(i));
			alert(conn.html);
			conn.html.style.display="block";
		}*/
}
};
draw2d.GizmoFigure.prototype.onDoubleClick=function(){
	if(this.allowDoubleClick == false) return;
	
	draw2d.Figure.prototype.onDoubleClick.call(this);	

	if(this.group.isExternalPhaseGroup)
	{
		//we will be implementing loadNextProcess in loadGraphicalProcess jsp as thats where we know the exact ID of process drop down which will be set with targetProcess and submitted to load that process
		if(this.loadNextProcess) this.loadNextProcess();
		return;
	}
	var data = "currentProfile="+this.profile+"&phase="+this.group.figName+"&process="+this.group.process+"&callAjax="+this.outputPort.workflow.callAjax+"&partialUpdate="+this.outputPort.workflow.partialUpdate;	
	jQuery.ajax({
		url: 'showEditPhase.jsp',
		type: 'POST',
		data: data,
		success: function(resp) {
			resp = jQuery.trim(resp);
			jQuery("#modalWindow").dialog("option","title","Edit Phase");
			jQuery("#modalWindow").dialog("option","width","550px");
			jQuery("#modalWindow").dialog("option","height","auto");
			jQuery('#modalWindow').unbind("dialogclose");	   
			jQuery("#modalWindow").html(resp);
			jQuery("#modalWindow").dialog('open');			
		},
		error : function(resp) {
			alert("Some error while communication with server. Try again or contact administrator");
		}				
	});									
	editPhase = this;
};
draw2d.GizmoFigure.prototype.setAllowDoubleClick=function(allow)
{
	this.allowDoubleClick = allow;
};
function onEditPhase(proc, oldPhase)
{
	if(jQuery('#editPhaseName').val() == '')
	{
		jQuery('#editPhaseMsg').html("Enter Phase name");
		return;
	}
	if(jQuery('#editPriority').val() != '' && !IsNumeric(jQuery('#editPriority').val()))
	{
		jQuery('#editPhaseMsg').html("Priority should be numeric");
		return;
	}					

	if(jQuery('#editPhaseDisplayName').val() == '') jQuery('#editPhaseDisplayName').val(jQuery('#editPhaseName').val());
	
	var vis = 0;
	if(document.getElementById('phaseVisible').checked) vis = 1;

	/*var rulesVisibleTo = "";
	for(var i=0;i<document.getElementsByName("rulesVisibleTo").length; i++)
	{
		if(document.getElementsByName("rulesVisibleTo")[i].checked && rulesVisibleTo == "") rulesVisibleTo = document.getElementsByName("rulesVisibleTo")[i].value;
		else if(document.getElementsByName("rulesVisibleTo")[i].checked) rulesVisibleTo += "|" + document.getElementsByName("rulesVisibleTo")[i].value;
	}
	*/
	var isReverse = 0;
	if(document.getElementById('isReverse').checked) isReverse = 1;
	var oprType = "O";
	if(document.getElementById('oprTypeT').checked) oprType = "T";

	//var data = "oprType="+oprType+"&isReverse="+isReverse+"&rulesVisibleTo="+rulesVisibleTo+"&visible="+vis+"&action=edit&process="+proc+"&oldPhase="+oldPhase+"&phase="+jQuery('#editPhaseName').val()+"&priority="+jQuery('#editPriority').val()+"&execute="+jQuery('#editExecute').val()+"&actors="+jQuery('#editActors').val()+"&displayName="+jQuery('#editPhaseDisplayName').val();
	var data = "oprType="+oprType+"&isReverse="+isReverse+"&visible="+vis+"&action=edit&process="+proc+"&oldPhase="+oldPhase+"&phase="+jQuery('#editPhaseName').val()+"&priority="+jQuery('#editPriority').val()+"&execute="+jQuery('#editExecute').val()+"&actors="+jQuery('#editActors').val()+"&displayName="+jQuery('#editPhaseDisplayName').val();
	jQuery.ajax({
		url: 'addNewPhase.jsp',
		type: 'POST',
		data: data,
		dataType:'json',
		success: function(resp) {
			if(resp.STATUS === "SUCCESS")
			{	
				editPhase.group.setFigureName(jQuery('#editPhaseName').val());
				editPhase.group.setDisplayName(jQuery('#editPhaseDisplayName').val());
				editPhase.group.setActors(jQuery('#editActors').val());
				editPhase.group.setPriority(jQuery('#editPriority').val());
				editPhase.group.setExecute(jQuery('#editExecute').val());
				if(document.getElementById('phaseVisible').checked) editPhase.group.setVisible(1);
				else editPhase.group.setVisible(0);
				//editPhase.group.setRulesVisibleTo(rulesVisibleTo);
				jQuery("#modalWindow").dialog('close');
				editPhase = null;
			}
			else
			{
				jQuery('#editPhaseMsg').html(resp.MESSAGE);
			}
		},
		error : function(resp) {
			alert("Some error while communication with server. Try again or contact administrator");
		}				
	});
};
draw2d.GizmoFigure.prototype.isFigureMovedOut=function()
{
	if(this.group.isExternalPhaseGroup) return false;//we are not handling intraprocess in profile groups. so always return false as that phase can be moved anywhere on the screen
	var movedOut = false;
	if (this.getParent() === null) 
	{	
		movedOut = true;
//		this.setParent(this.originalCompartment);
	//	this.getParent().addChild(this);
	}
	else if(this.originalCompartment.id != this.getParent().id)
	{
		movedOut = true;
		this.getParent().removeChild(this);
	}
	return movedOut;
};
draw2d.GizmoFigure.prototype.onDragend=function()
{ 			
	var any = draw2d.Node.prototype.onDragend.call(this);
	if(this.group.isExternalPhaseGroup && this.getParent() != null && this.getParent() instanceof draw2d.GizmoProfileFigure) 
	{
		this.getParent().removeChild(this);
		alert('External phase cannot be part of a profile grouping');
		this.x  = this.originalX;
		this.y  = this.originalY;
//		this.html.style.left = this.x;
//		this.html.style.top = this.y;
		this.setPosition(this.x, this.y);
		this.outputPort.workflow.moveResizeHandles(this.outputPort.workflow.getCurrentSelection());
		return;
	}
	var newCompartment = this.getParent();
	var newX = this.x;
	var newY = this.y;
	if(this.isFigureMovedOut())
	{
		if(this.outputPort.workflow.callAjax == false) 
		{
			this.x  = this.originalX;
			this.y  = this.originalY;
//			this.html.style.left = this.x;
//			this.html.style.top = this.y;
			this.setPosition(this.x, this.y);
			this.outputPort.workflow.moveResizeHandles(this.outputPort.workflow.getCurrentSelection());
			this.setParent(this.originalCompartment);
			this.getParent().addChild(this);
			this.outputPort.workflow.copiedPhase = null;
			return;
		}

//		alert('You cannot move phase out of its profile grouping');
		this.x  = this.originalX;
		this.y  = this.originalY;
//		this.html.style.left = this.x;
//		this.html.style.top = this.y;
		this.setPosition(this.x, this.y);
		this.outputPort.workflow.moveResizeHandles(this.outputPort.workflow.getCurrentSelection());
		this.setParent(this.originalCompartment);
		this.getParent().addChild(this);
		this.outputPort.workflow.copiedPhase = null;
		//this.movedOutOfCompartment = false;
		this.outputPort.workflow.copiedPhase = this;
		this.outputPort.workflow.setCopyToPhaseInfo(this, newCompartment, newX, newY);
		var h = "<div><div style='font-weight:bold'>Do you want to copy this phase or move?</div><div style='margin-top:10px'><input type='button' value='Copy' onclick='draw2d.GizmoWorkflow.prototype.copySpecial.call(this);' /><input type='button' value='Move' onclick='draw2d.GizmoWorkflow.prototype.moveSpecial.call(this);' /></div></div>";
		jQuery('#'+this.outputPort.workflow.modalWindowId).dialog("option","title","Copy/Move Phase");
		jQuery('#'+this.outputPort.workflow.modalWindowId).dialog("option","width","auto");
		jQuery('#'+this.outputPort.workflow.modalWindowId).dialog("option","height","auto");		
		jQuery('#'+this.outputPort.workflow.modalWindowId).html(h);
		jQuery('#'+this.outputPort.workflow.modalWindowId).dialog('open');			
		return;
	}

	if(this.outputPort.workflow instanceof draw2d.GizmoWorkflow)
	{
		if(this.outputPort.workflow.callAjax == false) return;

		if(this.group.isExternalPhaseGroup)
		{
			var d = "startProc="+this.group.loadedProcess+"&nextProc="+this.group.process+"&nextPhase="+this.group.figName+"&isExternalPhase=1";
		}
		else
		{
			var d = "isPhase=1&process="+this.group.process+"&profile="+this.profile+"&phase="+this.group.figName;
				
			//we need to make sure that the new coordinates of this figure is not outside its profile figure. Although this case is not possible
			//but still due to any reason it happens we stop it here
			if(!(this.x >= this.parent.x && this.x <= (this.parent.x + this.parent.width) && this.y >= this.parent.y && this.y <= (this.y + this.parent.y))) return false;
		}
		
		var _y = this.y - this.outputPort.workflow.deltaY;
		if(_y < 0) _y = 1;
		var data = d + "&topLeftX="+this.x+"&topLeftY="+_y+"&width="+this.width+"&height="+this.height;
		
		for(var i=0;i<this.outputPort.getConnections().size;i++)
		{
			this.outputPort.getConnections().get(i).group.refreshErrInfo();
		}
		for(var i=0;i<this.inputPort.getConnections().size;i++)
		{
			this.inputPort.getConnections().get(i).group.refreshErrInfo();
		}

		jQuery.ajax({
			url: 'updateCoordinates.jsp',
			type: 'POST',
			data: data,
			dataType: 'json',
			success: function(resp) {
				if (resp.STATUS == "ERROR")
				{
					alert("Some problem occured while saving coordinates of this object");
				}
			}
		});			
	}
};
draw2d.GizmoFigure.prototype.setGroup=function(groupFig){
	this.group = groupFig;
};	
draw2d.GizmoFigure.prototype.getGroup=function(){
	return this.group;
};
draw2d.GizmoFigure.prototype.getContextMenu=function(){
if(!this.workflow.callAjax) return null;
this.workflow.anyMenuShowing=true;//signaling workflow not to show its menu if this menu is visible
var menu=new draw2d.Menu();
menu.html.style.textAlign="left";
//menu.html.style.background="#CA011F";
var oThis=this;
if(!this.group.isExternalPhaseGroup)
{
	menu.appendMenuItem(new draw2d.MenuItem("Copy Phase",null,function(){
	oThis.workflow.anyMenuShowing=false;
	oThis.workflow.onCopyPhase(oThis);
	}));
}
menu.appendMenuItem(new draw2d.MenuItem("Delete Phase",null,function(){
	oThis.workflow.anyMenuShowing=false;
	oThis.workflow.deleteFromMenu=true;
	oThis.workflow.removeFigure(oThis);
}));

return menu;
};
draw2d.GizmoFigure.prototype.hide=function(_wf)
{
	if(this.isHidden) return;
	
	var _callAjax = _wf.callAjax;
	var _partialUpdate = _wf.partialUpdate;
	_wf.setCallAjax(false);
	_wf.setPartialUpdate(false);
	
	this.hiddenConnections = new draw2d.ArrayList();
	this.isHidden=true;
	for(var i=0;i<this.outputPort.getConnections().size;i++)
	{
		this.hiddenConnections.add(this.outputPort.getConnections().get(i));
	}
	for(var i=0;i<this.inputPort.getConnections().size;i++)
	{
		this.hiddenConnections.add(this.inputPort.getConnections().get(i));
	}
	for(var i=0;i<this.hiddenConnections.size;i++)
	{
		_wf.removeFigure(this.hiddenConnections.get(i));
		var cGrp = this.hiddenConnections.get(i).group;
		cGrp.removeChild(this.hiddenConnections.get(i));
		if(cGrp.children.size === 0) _wf.removeConnectionGroup(cGrp);					
		this.hiddenConnections.get(i).group = cGrp;//make backup of group just in-case if that phase was the only one on screen, then we need all its rules information
	}
		
	_wf.removeFigure(this);
	_wf.setCallAjax(_callAjax);
	_wf.setPartialUpdate(_partialUpdate);	
};
draw2d.GizmoFigure.prototype.show=function(_wf)
{
//	alert(this.isHidden);
//	alert(this.group.isHidden);
//	alert(this.profileCompartmentIsHidden);
	if(!this.isHidden) return;
	if(this.group.isHidden) return;
	if(this.profileCompartmentIsHidden) return;
	
	var _callAjax = _wf.callAjax;
	var _partialUpdate = _wf.partialUpdate;
	_wf.setCallAjax(false);
	_wf.setPartialUpdate(false);

	this.isHidden=false;	

	var pGrp = this.group; // this was the backup group we saved when we hide the phase
	_wf.addPhaseGroup(pGrp);
	//we get connections info from group if group has phases in it
	//or we get connections info from group if the group itself is not hidden
	//and if the outward or inward connections are empty, then we give preference to the list hiddenConnections of this phase to be drawn
	if(pGrp.children.size > 0 && !pGrp.isHidden && (pGrp.children.get(0).outputPort.getConnections().size > 0 || pGrp.children.get(0).inputPort.getConnections().size > 0))
	{
		for(var i=0;i<pGrp.children.get(0).outputPort.getConnections().size; i++)
		{
			var c1 = new draw2d.GizmoConnection();
			c1.setSource(this.getPort("output"));
			c1.setTarget(pGrp.children.get(0).outputPort.getConnections().get(i).targetPort);
			//this is the case if we hide say P1 and then P2, then we show P1 first and P2 later, P1 has hidden connections which go to P2 but P2 is not drawn yet.
			//so we add those hidden connections to P2 hidden connections list
			if(pGrp.children.get(0).outputPort.getConnections().get(i).targetPort.parentNode.isHidden) 
			{
				c1.group = pGrp.children.get(0).outputPort.getConnections().group;
				pGrp.children.get(0).outputPort.getConnections().get(i).targetPort.parentNode.hiddenConnections.add(c1);
			}
			else 
			{
				pGrp.children.get(0).outputPort.getConnections().get(i).group.addChild(c1);
				//pGrp.children.get(0).outputPort.getConnections().get(i).group.refreshErrInfo();
				pGrp.children.get(0).outputPort.getConnections().get(i).group.setLabelsVisible(_wf.labelsVisible);
				_wf.addFigure(c1);										
			}
		}
		for(var i=0;i<pGrp.children.get(0).inputPort.getConnections().size; i++)
		{
			var c1 = new draw2d.GizmoConnection();
			c1.setSource(pGrp.children.get(0).inputPort.getConnections().get(i).sourcePort);
			c1.setTarget(this.getPort("input"));
			//this is the case if we hide say P1 and then P2, then we show P1 first and P2 later, P1 has hidden connections which go to P2 but P2 is not drawn yet.
			//so we add those hidden connections to P2 hidden connections list
			if(pGrp.children.get(0).inputPort.getConnections().get(i).sourcePort.parentNode.isHidden)
			{
				c1.group = pGrp.children.get(0).inputPort.getConnections().group;
				pGrp.children.get(0).inputPort.getConnections().get(i).sourcePort.parentNode.hiddenConnections.add(c1);
			}
			else
			{				
				pGrp.children.get(0).inputPort.getConnections().get(i).group.addChild(c1);
				//pGrp.children.get(0).inputPort.getConnections().get(i).group.refreshErrInfo();			
				pGrp.children.get(0).inputPort.getConnections().get(i).group.setLabelsVisible(_wf.labelsVisible);
				_wf.addFigure(c1);										
			}
		}
	}
	else
	{
		for(var i=0;i<this.hiddenConnections.size;i++)
		{
			if(this.hiddenConnections.get(i).sourcePort.parentNode.isHidden || this.hiddenConnections.get(i).targetPort.parentNode.isHidden) continue;
			else 
			{
				_wf.addConnectionGroup(this.hiddenConnections.get(i).group);
				var c1 = new draw2d.GizmoConnection();
				c1.setSource(this.hiddenConnections.get(i).sourcePort);
				c1.setTarget(this.hiddenConnections.get(i).targetPort);			
				this.hiddenConnections.get(i).group.addChild(c1);
				//this.hiddenConnections.get(i).group.refreshErrInfo();
				this.hiddenConnections.get(i).group.setLabelsVisible(_wf.labelsVisible);
				_wf.addFigure(c1);
			}
		}
	}
	
	//check if any hiddenConnections are coming or going to a hidden phase, then make that connection part of that phase's hiddenConnections otherwise they wont be drawn later
	for(var i=0;i<this.hiddenConnections.size;i++)
	{
		//this is the case if we hide say P1 and then P2, then we show P1 first and P2 later, P1 has hidden connections which go to P2 but P2 is not drawn yet.
		//so we add those hidden connections to P2 hidden connections list
		if(this.hiddenConnections.get(i).sourcePort.parentNode.isHidden) this.hiddenConnections.get(i).sourcePort.parentNode.hiddenConnections.add(this.hiddenConnections.get(i));
		else if(this.hiddenConnections.get(i).targetPort.parentNode.isHidden) this.hiddenConnections.get(i).targetPort.parentNode.hiddenConnections.add(this.hiddenConnections.get(i));
	}
	pGrp.addChild(this);	

	_wf.addFigure(this);
	_wf.setCallAjax(_callAjax);
	_wf.setPartialUpdate(_partialUpdate);	
};
