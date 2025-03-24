/*
* This class extends draw2d.ResizeHandle
* The purpose of this class is to let us overwrite function onDragend. That function then calls _onDragend function which can be 
* implemented by calling jsp and specific actions can take place in it. In our case on drag end, we need to update coordinates of nodes
*/

draw2d.GizmoResizeHandle=function(fig,type)
{
	try{
		draw2d.ResizeHandle.call(this,fig, type);
		//this._workflow = fig;
	}
	catch(e){
		pushErrorStack(e,"draw2d.GizmoResizeHandle=function(/*:String*/ fig, /*:String*/ type)");
	}
};
draw2d.GizmoResizeHandle.prototype=new draw2d.ResizeHandle();
draw2d.GizmoResizeHandle.prototype.type="draw2d.GizmoResizeHandle";
draw2d.GizmoResizeHandle.prototype.onDragend=function()
{	
	draw2d.ResizeHandle.prototype.onDragend.call(this);
	this._onDragend();
};

draw2d.GizmoResizeHandle.prototype._onDragend=function()
{
	if(this.workflow.callAjax == false) return;
	if(this.workflow.currentSelection instanceof draw2d.GizmoProfileFigure)
	{	
		var _y = this.workflow.currentSelection.y - this.workflow.deltaY;		
		var _shifted = 0;
		if(_y < 0) 
		{
			_shifted = ((-1) * _y ) + 1;
			_y = 1;
		}
		var d = "isPhase=0&process="+this.workflow.currentSelection.process+"&profile="+this.workflow.currentSelection.name+"&phase=&topLeftX="+this.workflow.currentSelection.x+"&topLeftY="+_y+"&width="+this.workflow.currentSelection.width+"&height="+this.workflow.currentSelection.height;
		for(var i=0;i<this.workflow.currentSelection.children.size; i++)
		{
			var child = this.workflow.currentSelection.children.get(i);
			if(!child.group.isExternalPhaseGroup) 
			{
				var _cy = child.y + _shifted - this.workflow.deltaY;
				d += "&isPhase=1&process="+this.workflow.currentSelection.process+"&profile="+this.workflow.currentSelection.name+"&phase="+child.group.figName+"&topLeftX="+child.x+"&topLeftY="+_cy+"&width="+child.width+"&height="+child.height;
			}
		}
		
	}
	else if(this.workflow.currentSelection instanceof draw2d.GizmoFigure && this.workflow.currentSelection.group.isExternalPhaseGroup)
	{
		var d = "isExternalPhase=1&startProc="+this.workflow.currentSelection.group.loadedProcess+"&nextProc="+this.workflow.currentSelection.group.process+"&nextPhase="+this.workflow.currentSelection.group.figName+"&isExternalPhase=1";
		var _y = this.workflow.currentSelection.y - this.workflow.deltaY;		
		d = d + "&topLeftX="+this.workflow.currentSelection.x+"&topLeftY="+_y+"&width="+this.workflow.currentSelection.width+"&height="+this.workflow.currentSelection.height;
	}
	else if(this.workflow.currentSelection instanceof draw2d.GizmoFigure)
	{
		var d = "isPhase=1&process="+this.workflow.currentSelection.group.process+"&profile="+this.workflow.currentSelection.profile+"&phase="+this.workflow.currentSelection.group.figName;
		var _y = this.workflow.currentSelection.y - this.workflow.deltaY;		
		d = d + "&topLeftX="+this.workflow.currentSelection.x+"&topLeftY="+_y+"&width="+this.workflow.currentSelection.width+"&height="+this.workflow.currentSelection.height;		
	}
	var data = d;	
	
	oldjquery.ajax({
		url: 'updateCoordinates.jsp',
		type: 'POST',
		data: data,
		dataType: 'json',
		success: function(resp) {
			if (resp.STATUS == "ERROR")
			{
				alert("Some problem occured while saving size of phase object");
			}
		}
	});			
};