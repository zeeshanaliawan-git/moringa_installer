/*
* This class is responsible to hold the similar phase figures
*/

//GizmoFigureGroup=function(name, act, prio, exe, visible, displayName, rulesVisibleTo, proc, loadedProc)
GizmoFigureGroup=function(name, act, prio, exe, color, visible, displayName, proc, loadedProc)
{
this.id=draw2d.UUID.create();
this.figName = name;
this.displayName = displayName;
this.actors = act;
this.priority = prio;
this.execute = exe;
this.color = color;
this.visible = visible;
this.process = proc;
this.isExternalPhaseGroup=false;
if(proc != loadedProc) this.isExternalPhaseGroup=true;
this.loadedProcess = loadedProc;
//this.rulesVisibleTo = rulesVisibleTo;
this.isHidden = false;
this.children = new draw2d.ArrayList();
};
GizmoFigureGroup.prototype.type="GizmoFigureGroup";
GizmoFigureGroup.prototype.addChild=function(figure)
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
GizmoFigureGroup.prototype.removeChild=function(figure)
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
	}
};
GizmoFigureGroup.prototype.setFigureName=function(figName)
{
	this.figName = figName;
};
GizmoFigureGroup.prototype.setDisplayName=function(displayName)
{
	this.displayName = displayName;
	for(var i=0;i<this.children.size;i++) this.children.get(i).setTitle(this.displayName);
};
GizmoFigureGroup.prototype.setActors=function(act)
{
	this.actors = act;
};
GizmoFigureGroup.prototype.setPriority=function(prio)
{
	this.priority = prio;
};
GizmoFigureGroup.prototype.setExecute=function(exe)
{
	this.execute = exe;
};
GizmoFigureGroup.prototype.setColor=function(color)
{
	this.color = color;
};
GizmoFigureGroup.prototype.setVisible=function(vis)
{
	this.visible = vis;
};
GizmoFigureGroup.prototype.setRulesVisibleTo=function(rulesVisibleTo)
{
	this.rulesVisibleTo = rulesVisibleTo;
};
GizmoFigureGroup.prototype.hide=function(_wf)
{
	var _callAjax = _wf.callAjax;
	var _partialUpdate = _wf.partialUpdate;
	_wf.setCallAjax(false);
	_wf.setPartialUpdate(false);
	
	var size = this.children.size;
	for(var i=0;i<size;i++)
	{
		this.children.get(i).hide(_wf);
	}
	this.isHidden = true;
	
	_wf.setCallAjax(_callAjax);
	_wf.setPartialUpdate(_partialUpdate);	
};
GizmoFigureGroup.prototype.show=function(_wf)
{
	var _callAjax = _wf.callAjax;
	var _partialUpdate = _wf.partialUpdate;
	_wf.setCallAjax(false);
	_wf.setPartialUpdate(false);

	for(var i=0;i<this.children.size;i++)
	{
		this.isHidden = false;
		this.children.get(i).show(_wf);		
	}
	for(var i=0;i<_wf.connectionGroups.size;i++)
	{
		_wf.connectionGroups.get(i).refreshErrInfo();
	}
	_wf.setCallAjax(_callAjax);
	_wf.setPartialUpdate(_partialUpdate);	
};
