/*
* This class extends draw2d.ArrowConnectionDecorator
* The original class does not allow to set the height and width of arrow while initializing ArrowConnectionDecorator which this class lets the developer to do
*/

draw2d.GizmoConnectionDecorator=function(height,width){
	draw2d.ArrowConnectionDecorator.call(height, width);
	this.height = height;
	this.width = width;
};
draw2d.GizmoConnectionDecorator.prototype=new draw2d.ArrowConnectionDecorator();
draw2d.GizmoConnectionDecorator.prototype.type="draw2d.GizmoConnectionDecorator";