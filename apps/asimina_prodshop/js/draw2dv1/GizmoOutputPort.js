/*
* This class extends draw2d.OutputPort
* The functions onDrop and createCommand are overwritten to allow loop connections (where source and target of a connection is same node)
*/
draw2d.GizmoOutputPort=function(_4aff){
	draw2d.OutputPort.call(this,_4aff);
};
draw2d.GizmoOutputPort.prototype=new draw2d.OutputPort();
draw2d.GizmoOutputPort.prototype.type="GizmoOutputPort";
draw2d.GizmoOutputPort.prototype.onDrop=function(port){
	if(this.getMaxFanOut()<=this.getFanOut()){
		return;
	}
	var _4b01=new draw2d.CommandConnect(this.parentNode.workflow,this,port);
	_4b01.setConnection(new draw2d.GizmoConnection());
	this.parentNode.workflow.getCommandStack().execute(_4b01);
};
//the original createCommand function in draw2d.Port does not allow to draw connection when source port and target port are from same node. So we have overwritten it here
draw2d.GizmoOutputPort.prototype.createCommand=function(_575f){
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