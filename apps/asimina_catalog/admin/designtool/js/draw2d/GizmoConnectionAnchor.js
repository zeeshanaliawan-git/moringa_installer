draw2d.GizmoConnectionAnchor=function(owner){
draw2d.ConnectionAnchor.call(this,owner);
};
draw2d.GizmoConnectionAnchor.prototype=new draw2d.ConnectionAnchor();
draw2d.GizmoConnectionAnchor.prototype.type="draw2d.GizmoConnectionAnchor";
draw2d.GizmoConnectionAnchor.prototype.getLocation=function(_5009){
if(this.getOwner().workflow.isLoop) return this.getOwner().getAbsolutePosition();
var r=new draw2d.Dimension();
r.setBounds(this.getBox());
r.translate(-1,-1);
r.resize(1,1);
var _500b=r.x+r.w/2;
var _500c=r.y+r.h/2;
if(r.isEmpty()||(_5009.x==_500b&&_5009.y==_500c)){
return new Point(_500b,_500c);
}
var dx=_5009.x-_500b;
var dy=_5009.y-_500c;
var scale=0.5/Math.max(Math.abs(dx)/r.w,Math.abs(dy)/r.h);
dx*=scale;
dy*=scale;
_500b+=dx;
_500c+=dy;
return new draw2d.Point(Math.round(_500b),Math.round(_500c));
};
draw2d.GizmoConnectionAnchor.prototype.getBox=function(){
return this.getOwner().getParent().getBounds();
};
draw2d.GizmoConnectionAnchor.prototype.getReferencePoint=function(){
return this.getBox().getCenter();
};
