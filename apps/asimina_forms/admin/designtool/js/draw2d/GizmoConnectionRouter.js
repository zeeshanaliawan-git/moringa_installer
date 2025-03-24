/*
* This class extends draw2d.ManhattanConnectionRouter
* The original class draws the loop connection (source and target is same) as a straight line from sourcePort to targetPort.
* We need the loop to look like loop where the connection goes up then to left and then to targetPort. 
* The function _route is overwritten for that purpose. In case of looping we have our own code otherwise we call the base
* class's _route.
*/

draw2d.GizmoConnectionRouter=function(){
draw2d.ManhattanConnectionRouter.call(this);
};
draw2d.GizmoConnectionRouter.prototype=new draw2d.ManhattanConnectionRouter();
draw2d.GizmoConnectionRouter.prototype.type="GizmoConnectionRouter";

draw2d.Connection.prototype.getEndPoint=function(){
if(this.isMoving==false){
return this.targetAnchor.getLocation(this.sourceAnchor.getReferencePoint());
}else{
return draw2d.Line.prototype.getEndPoint.call(this);
}
};

draw2d.GizmoConnectionRouter.prototype._route=function(conn, fromPoint, fromDirection, toPoint, toDirection){
	if(conn.sourcePort.parentNode.id == conn.targetPort.parentNode.id ) 
	{
		conn.addPoint(new draw2d.Point(toPoint.x,toPoint.y));
		conn.addPoint(new draw2d.Point(toPoint.x+20,toPoint.y));
		conn.addPoint(new draw2d.Point(toPoint.x+20,toPoint.y - (conn.sourcePort.parentNode.getBounds().h/2) - 20));
		conn.addPoint(new draw2d.Point(fromPoint.x-20,toPoint.y - (conn.sourcePort.parentNode.getBounds().h/2) - 20));
		conn.addPoint(new draw2d.Point(fromPoint.x-20,fromPoint.y));
		conn.addPoint(new draw2d.Point(fromPoint.x,fromPoint.y));
		return;
	}
	draw2d.ManhattanConnectionRouter.prototype._route.call(this, conn, fromPoint, fromDirection, toPoint, toDirection);
};
