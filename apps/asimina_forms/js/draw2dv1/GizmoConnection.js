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
this.errCode=new draw2d.ArrayList();
this.errColor=new draw2d.ArrayList();
this.errName=new draw2d.ArrayList();
this.errType=new draw2d.ArrayList();
this.canDrag = false;
this.labelsVisible=false;
};
draw2d.GizmoConnection.prototype=new draw2d.Connection();
draw2d.GizmoConnection.prototype.type="GizmoConnection";
draw2d.GizmoConnection.prototype.paint=function(g)
{
	draw2d.Connection.prototype.paint.call(this,g);
};
draw2d.GizmoConnection.prototype.addErrInfo=function(_errCode, _errName, _errType, _errColor)
{
	this.errCode.add(_errCode);
	this.errName.add(_errName);
	this.errType.add(_errType);
	this.errColor.add(_errColor);
	
	if(this.getTargetDecorator())
	{
		this.getTargetDecorator().setColor(new draw2d.Color(_errColor));
		this.getTargetDecorator().setBackgroundColor(new draw2d.Color(_errColor));
	}
	
	if(this.getSourceDecorator() && this.getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) this.getSourceDecorator().updateErrInfo();
};
draw2d.GizmoConnection.prototype.showLabels=function()
{	
	this.labelsVisible = true;
	if(this.getSourceDecorator() && this.getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) this.getSourceDecorator().showLabels();
};
draw2d.GizmoConnection.prototype.hideLabels=function()
{	
	this.labelsVisible = false;
	if(this.getSourceDecorator() && this.getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) this.getSourceDecorator().hideLabels();
};
draw2d.GizmoConnection.prototype.getStartPoint=function(){
	var point = draw2d.Connection.prototype.getStartPoint.call(this);
	for(var i=0; i<this.sourcePort.getConnections().size; i++)
	{
		if(this.sourcePort.getConnections().get(i).id === this.id)
		{
			if(i%2 === 0) point.y = point.y + (Math.ceil(i/2) * 10 * -1);
			else point.y = point.y + (Math.ceil(i/2) * 10);
			point.x = point.x - 5;
		
			break;
		}
	}
	return point;	
};

draw2d.GizmoConnection.prototype.getEndPoint=function(){
    var point = draw2d.Connection.prototype.getEndPoint.call(this);
	for(var i=0; i<this.targetPort.getConnections().size; i++)
	{
		if(this.targetPort.getConnections().get(i).id === this.id)
		{
			if(i%2 === 0) point.y = point.y + (Math.ceil(i/2) * 8 * -1);
			else point.y = point.y + (Math.ceil(i/2) * 8);
			break;
		}
	}
	return point;
};
draw2d.GizmoConnection.prototype.setLabelsVisible=function(isVisible)
{
	this.labelsVisible = isVisible;
	if(this.getSourceDecorator() && this.getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator)
	{
		this.getSourceDecorator().setLabelVisible(isVisible);
	}
};
draw2d.GizmoConnection.prototype.onDoubleClick=function(){
	draw2d.Connection.prototype.onDoubleClick.call(this);
	if(this.sourcePort.workflow instanceof draw2d.GizmoWorkflow)
	{
		sourcePhase = this.sourcePort.parentNode.figName;
		targetPhase = this.targetPort.parentNode.figName;
		this.sourcePort.workflow.setCurrentFigure(this);
		var allowEdit = 1;
		if (this.sourcePort.workflow.callAjax == false) allowEdit = 0;
		jQuery.ajax({
			url: 'showConnectionInfo.jsp?sourceProcess='+this.sourcePort.parentNode.process+'&targetProcess='+this.targetPort.parentNode.process+'&sourcePhase='+sourcePhase+'&targetPhase='+targetPhase+'&allowEdit='+allowEdit,
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
draw2d.GizmoConnection.prototype.removeErrInfo=function(_errCode)
{
	var index = -1;
	for(var i = 0; i<this.errCode.size; i++)
	{
		if(this.errCode.get(i) === _errCode)
		{
			index = i;
			break;
		}
	}
	
	if(index > -1)
	{
		this.errCode.removeElementAt(index);
		this.errName.removeElementAt(index);
		this.errType.removeElementAt(index);
		this.errColor.removeElementAt(index);
		if(this.getTargetDecorator() && this.errColor.getLastElement())//incase when there is only one errcode, at time of updating rule, we first remove it and then add new. So removing it means errCode array will be empty so we dont change decorator in that case otherwise it gives script error
		{
			this.getTargetDecorator().setColor(new draw2d.Color(this.errColor.getLastElement()));
			this.getTargetDecorator().setBackgroundColor(new draw2d.Color(this.errColor.getLastElement()));
		}
	
		if(this.getSourceDecorator() && this.getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) this.getSourceDecorator().updateErrInfo();
		
		if(this.errColor.getLastElement())//incase when there is only one errcode, at time of updating rule, we first remove it and then add new. So removing it means errCode array will be empty so we dont change decorator in that case otherwise it gives script error
			this.setColor(new draw2d.Color(this.errColor.getLastElement()))
		

	}
	
};
draw2d.GizmoConnection.prototype.resetConnectionInfo=function()
{
	this.errCode=new draw2d.ArrayList();
	this.errColor=new draw2d.ArrayList();
	this.errName=new draw2d.ArrayList();
	this.errType=new draw2d.ArrayList();
};