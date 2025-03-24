/*
* This class extends draw2d.InputPort
* The functions onDrop and createCommand are overwritten to allow loop connections (where source and target of a connection is same node)
*/

draw2d.GizmoInputPort=function(_5920){
draw2d.InputPort.call(this,_5920);
};
draw2d.GizmoInputPort.prototype=new draw2d.InputPort();
draw2d.GizmoInputPort.prototype.type="GizmoInputPort";
draw2d.GizmoInputPort.prototype.onDrop=function(port){
	if(port.getMaxFanOut&&port.getMaxFanOut()<=port.getFanOut()){
		return;
	}
	var _5922=new draw2d.CommandConnect(this.parentNode.workflow,port,this);
	_5922.setConnection(new draw2d.GizmoConnection());
	this.parentNode.workflow.getCommandStack().execute(_5922);
};
//the original createCommand function in draw2d.Port does not allow to draw connection when source port and target port are from same node. So we have overwritten it here
draw2d.GizmoInputPort.prototype.createCommand=function(_575f){
	if(_575f.getPolicy()===draw2d.EditPolicy.MOVE){
		if(!this.canDrag){
			return null;
		}
		return new draw2d.CommandMovePort(this);
	}
	if(_575f.getPolicy()===draw2d.EditPolicy.CONNECT){
		return new draw2d.CommandConnect(_575f.canvas,_575f.source,_575f.target);
	}
	return null;
};