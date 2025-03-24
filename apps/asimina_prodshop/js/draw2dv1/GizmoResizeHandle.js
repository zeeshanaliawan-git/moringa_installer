/*
* This class extends draw2d.ResizeHandle
* The purpose of this class is to let us overwrite function onDragend. That function then calls _onDragend function which can be 
* implemented by calling jsp and specific actions can take place in it. In our case on drag end, we need to update coordinates of nodes
*/

draw2d.GizmoResizeHandle=function(fig,type)
{
	try{
		draw2d.ResizeHandle.call(this,fig, type);
		this._workflow = fig;
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
	if(this._workflow.callAjax == false) return;
	if(this._workflow.currentSelection.isIntraProcess)
	{
		var data = "isExternalPhase=1&process="+this._workflow.currentSelection.loadedProcess+"&phase="+this._workflow.currentSelection.figName+"&width="+this._workflow.currentSelection.getWidth()+"&height="+this._workflow.currentSelection.getHeight()+"&targetProcess="+this._workflow.currentSelection.process;			
	}
	else
	{
		var data = "process="+this._workflow.currentSelection.process+"&phase="+this._workflow.currentSelection.figName+"&width="+this._workflow.currentSelection.getWidth()+"&height="+this._workflow.currentSelection.getHeight();		
	}
	jQuery.ajax({
		url: 'updatePhaseSize.jsp',
		type: 'POST',
		data: data,
		success: function(resp) {
			resp = jQuery.trim(resp);
			if (resp.indexOf("ERROR") > -1)
			{
				alert("Some problem occured while saving size of phase object");
			}
		}
	});			
};