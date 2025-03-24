/*
* This class is extension of draw2d.Connection
* Attribute errCode and errColor are associated with connection everytime a new connection is created or loaded from db. These properties
* are later used at time of deleting a connection to make sure connection with given errCode is deleted
* The function getStartPoint and getEndPoint are overwritten. They basically add padding between connections if their source and/or target are same so
* that they start and/or end at different points to make links more clear
*/

draw2d.GizmoConnection=function(){
draw2d.Connection.call(this);
this.setTargetDecorator(new draw2d.GizmoConnectionDecorator(14,6));
this.setSourceDecorator(new draw2d.GizmoConnectionSourceDecorator(this));
this.setRouter(new draw2d.GizmoConnectionRouter());
this.setSourceAnchor(new draw2d.GizmoConnectionAnchor());
this.setTargetAnchor(new draw2d.GizmoConnectionAnchor());
this.canDrag = false;
this.group=null;
this.direction=0;
this.isShifted=false;
this.allowDoubleClick=true;
this.allowDelete=true;
};
draw2d.GizmoConnection.prototype=new draw2d.Connection();
draw2d.GizmoConnection.prototype.type="GizmoConnection";
draw2d.GizmoConnection.prototype.paint=function(g)
{
	draw2d.Connection.prototype.paint.call(this,g);
};

draw2d.GizmoConnection.prototype.getStartPoint=function(){
	//if(this.sourcePort.parentNode.group.id == this.targetPort.parentNode.group.id) this.sourcePort.workflow.isLoop = true;
	//else this.sourcePort.workflow.isLoop = false;
	var point = draw2d.Connection.prototype.getStartPoint.call(this);

	//var lines=this.getSource().workflow.getLines();
	var lines=this.getTarget().parentNode.outputPort.getConnections();
	var lineIsViceVersa = false;
	for(var i=0;i<lines.getSize();i++)
	{
		var line=lines.get(i);
		if(line.id != this.id && line.getTarget().parentNode.id==this.getSource().parentNode.id&&line.getSource().parentNode.id==this.getTarget().parentNode.id && !line.isShifted )
		{		
			lineIsViceVersa = true;
			break;
		}
	}
	//alert(lineIsViceVersa);
	if(lineIsViceVersa)
	{		
		var x = this.sourcePort.parentNode.getBounds().x;
		var w = this.sourcePort.parentNode.width;
		var y = this.sourcePort.parentNode.getBounds().y;
		var h = this.sourcePort.parentNode.height;
		this.direction = this.getDirection(this.sourcePort.parentNode.getBounds(), point);
	
		if(this.direction === 1) point.y = point.y + 6;
		else if(this.direction === 2) point.x = point.x + 6;
		else if(this.direction === 3) point.y = point.y + 6;
		else if(this.direction === 0) point.x = point.x + 6;
		this.isShifted = true;
	}
	return point;	
};


draw2d.GizmoConnection.prototype.getEndPoint=function(){
	//if(this.sourcePort.parentNode.group.id == this.targetPort.parentNode.group.id) this.sourcePort.workflow.isLoop = true;
	//else this.sourcePort.workflow.isLoop = false;
    var point = draw2d.Connection.prototype.getEndPoint.call(this);
	if(this.isShifted)
	{
		if(this.direction === 1) point.y = point.y + 6;
		else if(this.direction === 2) point.x = point.x + 6;
		else if(this.direction === 3) point.y = point.y + 6;
		else if(this.direction === 0) point.x = point.x + 6;
	}
	return point;
};
draw2d.GizmoConnection.prototype.getDirection=function(r,p){
var _5b2e=Math.abs(r.x-p.x);
var _5b2f=3;
var i=Math.abs(r.y-p.y);
if(i<=_5b2e){
_5b2e=i;
_5b2f=0;
}
i=Math.abs(r.getBottom()-p.y);
if(i<=_5b2e){
_5b2e=i;
_5b2f=2;
}
i=Math.abs(r.getRight()-p.x);
if(i<_5b2e){
_5b2e=i;
_5b2f=1;
}
return _5b2f;
};
draw2d.GizmoConnection.prototype.onDoubleClick=function(){
	if(!this.allowDoubleClick) return;
	draw2d.Connection.prototype.onDoubleClick.call(this);
	if(this.sourcePort.workflow instanceof draw2d.GizmoWorkflow)
	{
		sourcePhase = this.sourcePort.parentNode.group.figName;
		targetPhase = this.targetPort.parentNode.group.figName;
		this.sourcePort.workflow.setCurrentFigure(this);
		var allowEdit = 1;
		if (this.sourcePort.workflow.callAjax == false) allowEdit = 0;
		jQuery.ajax({
			url: 'showConnectionInfo.jsp?sourceProcess='+this.sourcePort.parentNode.group.process+'&targetProcess='+this.targetPort.parentNode.group.process+'&sourcePhase='+sourcePhase+'&targetPhase='+targetPhase+'&allowEdit='+allowEdit,
			type: 'POST',
			success: function(resp) {
				resp = jQuery.trim(resp);
				jQuery("#modalWindow").dialog("option","title","Rule");
				jQuery("#modalWindow").dialog("option","width","450px");
				jQuery("#modalWindow").dialog("option","height","auto");		
				jQuery("#modalWindow").html(resp);
				jQuery("#modalWindow").dialog('open');				
			},
			error : function(resp) {
				alert("Some error while communication with server. Try again or contact administrator");
			}
		});								
	}
};
draw2d.GizmoConnection.prototype.setGroup=function(groupFig){
	this.group = groupFig;
};	
draw2d.GizmoConnection.prototype.setAllowDoubleClick=function(_flag){
	this.allowDoubleClick = _flag;
};	
draw2d.GizmoConnection.prototype.setAllowDelete=function(_flag){
	this.allowDelete = _flag;
};	
draw2d.GizmoConnection.prototype.getContextMenu=function(){
if(!this.allowDoubleClick) return null;
//if(!this.sourcePort.workflow.callAjax) return null;
this.sourcePort.workflow.anyMenuShowing=true;//signaling workflow not to show its menu if this menu is visible
var menu=new draw2d.Menu();
menu.html.style.textAlign="left";
//menu.html.style.background="#CA011F";
var oThis=this;

menu.appendMenuItem(new draw2d.MenuItem("View Info",null,function(){
	oThis.sourcePort.workflow.anyMenuShowing=false;
	//oThis.sourcePort.workflow.removeFigure(oThis);
	oThis.onDoubleClick();
}));
if(this.sourcePort.workflow.callAjax && this.allowDelete)
{
	menu.appendMenuItem(new draw2d.MenuItem("Delete",null,function(){
		oThis.sourcePort.workflow.anyMenuShowing=false;
		oThis.sourcePort.workflow.removeFigure(oThis);
	}));
}

return menu;
};
