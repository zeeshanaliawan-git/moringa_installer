/*
* This class is responsible to hold the similar phase figures
*/

GizmoConnectionGroup=function()
{
this.id=draw2d.UUID.create();
this.errCode=new draw2d.ArrayList();
this.errColor=new draw2d.ArrayList();
this.errName=new draw2d.ArrayList();
this.errType=new draw2d.ArrayList();
this.labelsVisible=false;
this.children = new draw2d.ArrayList();
};
GizmoConnectionGroup.prototype.type="GizmoConnectionGroup";
GizmoConnectionGroup.prototype.addChild=function(figure)
{
	var alreadyExists = false;
	for(var i=0;i<this.children.size;i++)
	{
		if(figure.id === this.children.get(i).id)
		{
			alreadyExists = true;
			break;
		}
	}
	if(!alreadyExists) 
	{
		this.children.add(figure);
		figure.setGroup(this);	
	}
};

GizmoConnectionGroup.prototype.removeChild=function(figure)
{
	var index = -1;
	for(var i=0;i<this.children.size;i++)
	{
		if(figure.id === this.children.get(i).id)
		{
			index = i;
			break;
		}
	}
	if(index > -1) 
	{
		this.children.removeElementAt(index);
		figure.setGroup(null);
		this.refreshErrInfo();
	}
};

GizmoConnectionGroup.prototype.resetConnectionInfo=function()
{
	this.errCode=new draw2d.ArrayList();
	this.errColor=new draw2d.ArrayList();
	this.errName=new draw2d.ArrayList();
	this.errType=new draw2d.ArrayList();
};
GizmoConnectionGroup.prototype.addErrInfo=function(_errCode, _errName, _errType, _errColor)
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
	
	if(index > -1) return;//means already exists in the list	
		
	this.errCode.add(_errCode);
	this.errName.add(_errName);
	this.errType.add(_errType);
	this.errColor.add(_errColor);
	
	for(var i=0; i<this.children.size;i++)
	{
		if(this.children.get(i).getTargetDecorator())
		{
			this.children.get(i).getTargetDecorator().setColor(new draw2d.Color(_errColor));
			this.children.get(i).getTargetDecorator().setBackgroundColor(new draw2d.Color(_errColor));
		}
		
		if(this.children.get(i).getSourceDecorator() && this.children.get(i).getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) 
		{
			this.children.get(i).getSourceDecorator().updateErrInfo();
		}
		
		this.children.get(i).setColor(new draw2d.Color(_errColor));
	}
};
GizmoConnectionGroup.prototype.removeErrInfo=function(_errCode)
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
		for(var i=0; i<this.children.size;i++)
		{
			if(this.children.get(i).getTargetDecorator() && this.errColor.getLastElement())//incase when there is only one errcode, at time of updating rule, we first remove it and then add new. So removing it means errCode array will be empty so we dont change decorator in that case otherwise it gives script error
			{
				this.children.get(i).getTargetDecorator().setColor(new draw2d.Color(this.errColor.getLastElement()));
				this.children.get(i).getTargetDecorator().setBackgroundColor(new draw2d.Color(this.errColor.getLastElement()));
			}
		
			if(this.children.get(i).getSourceDecorator() && this.children.get(i).getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) this.children.get(i).getSourceDecorator().updateErrInfo();
			
			if(this.errColor.getLastElement())//incase when there is only one errcode, at time of updating rule, we first remove it and then add new. So removing it means errCode array will be empty so we dont change decorator in that case otherwise it gives script error
				this.children.get(i).setColor(new draw2d.Color(this.errColor.getLastElement()))
		}

	}
	
};
GizmoConnectionGroup.prototype.showLabels=function()
{	
	this.labelsVisible = true;
	for(var i = 0; i<this.children.size; i++)
	{
		if(this.children.get(i).getSourceDecorator() && this.children.get(i).getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) this.children.get(i).getSourceDecorator().showLabels();
	}	
};
GizmoConnectionGroup.prototype.hideLabels=function()
{	
	this.labelsVisible = false;
	for(var i = 0; i<this.children.size; i++)
	{
		if(this.children.get(i).getSourceDecorator() && this.children.get(i).getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) this.children.get(i).getSourceDecorator().hideLabels();
	}
};
GizmoConnectionGroup.prototype.setLabelsVisible=function(isVisible)
{
	this.labelsVisible = isVisible;
	for(var i = 0; i<this.children.size; i++)
	{
		if(this.children.get(i).getSourceDecorator() && this.children.get(i).getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator)
		{
			this.children.get(i).getSourceDecorator().setLabelVisible(isVisible);
		}
	}
};
GizmoConnectionGroup.prototype.refreshErrInfo=function()
{
	this.setLinesStroke();
	for(var i=0; i<this.children.size;i++)
	{
		if(this.children.get(i).getTargetDecorator() && this.errColor.getLastElement())//incase when there is only one errcode, at time of updating rule, we first remove it and then add new. So removing it means errCode array will be empty so we dont change decorator in that case otherwise it gives script error
		{
			this.children.get(i).getTargetDecorator().setColor(new draw2d.Color(this.errColor.getLastElement()));
			this.children.get(i).getTargetDecorator().setBackgroundColor(new draw2d.Color(this.errColor.getLastElement()));
		}
	
		if(this.children.get(i).getSourceDecorator() && this.children.get(i).getSourceDecorator() instanceof draw2d.GizmoConnectionSourceDecorator) this.children.get(i).getSourceDecorator().updateErrInfo();
		
		if(this.errColor.getLastElement())//incase when there is only one errcode, at time of updating rule, we first remove it and then add new. So removing it means errCode array will be empty so we dont change decorator in that case otherwise it gives script error
			this.children.get(i).setColor(new draw2d.Color(this.errColor.getLastElement()))
	}
};
GizmoConnectionGroup.prototype.getShortestDistance=function()
{
	var shortest = 99999999;
	for(var i=0; i<this.children.size;i++)
	{
		var sp = this.children.get(i).getStartPoint();
		var ep = this.children.get(i).getEndPoint();
		
		var dx = ep.x - sp.x;
		var dy = ep.y - sp.y;
		
		var dx2 = dx*dx;
		var dy2 = dy*dy;
		var distance = Math.sqrt(dx2 + dy2);	
		if(distance < shortest) shortest = distance;
	}
	return shortest;
};
GizmoConnectionGroup.prototype.setLinesStroke=function()
{
	if(this.children.size > 0 && this.children.get(0).sourcePort.workflow.isIE) return;
	var shortestDistance = this.getShortestDistance();
	for(var i=0; i<this.children.size;i++)
	{
		var sp = this.children.get(i).getStartPoint();
		var ep = this.children.get(i).getEndPoint();
		
		var dx = ep.x - sp.x;
		var dy = ep.y - sp.y;
		
		var dx2 = dx*dx;
		var dy2 = dy*dy;
		var distance = Math.sqrt(dx2 + dy2);	
		if(distance > shortestDistance) 
		{
			this.children.get(i).setAlpha(this.children.get(0).sourcePort.workflow.arrowsOpacity);			
		}
		else
		{
			this.children.get(i).setAlpha(1);
		}
		this.children.get(i).setLineWidth(this.children.get(i).stroke);
	}
};
