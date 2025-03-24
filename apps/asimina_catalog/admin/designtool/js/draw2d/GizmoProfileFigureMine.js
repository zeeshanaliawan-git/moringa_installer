/* This notice must be untouched at all times.

Open-jACOB Draw2D
The latest version is available at
http://www.openjacob.org

Copyright (c) 2006 Andreas Herz. All rights reserved.
Created 5. 11. 2006 by Andreas Herz (Web: http://www.freegroup.de )

LICENSE: LGPL

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License (LGPL) as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA,
or see http://www.gnu.org/copyleft/lesser.html
*/
draw2d.GizmoProfileFigure=function(name, displayName, width, height, process)
{
  this.name = name;
  this.displayName = displayName;
  this.process = process;
  this.titlebar=null;
  //this.defaultBackgroundColor = new  draw2d.Color(255,255,255);
  //this.highlightBackgroundColor = new  draw2d.Color(250,250,200);

  draw2d.Node.call(this);
  this.setDimension(width, height);
  //this.setBackgroundColor(this.defaultBackgroundColor);
  this.setDeleteable(false);
  
  this.children=new draw2d.ArrayList();
  
  //this.removeEventListener("figureetner", this);
  //this.removeEventListener("figureleave", this);
};

draw2d.GizmoProfileFigure.prototype = new draw2d.Node();
draw2d.GizmoProfileFigure.prototype.type="draw2d.GizmoProfileFigure";
draw2d.GizmoProfileFigure.prototype.addChild=function(figure){
	figure.setParent(this);
	this.children.add(figure);
};
draw2d.GizmoProfileFigure.prototype.removeChild=function(figure){
figure.setParent(null);
this.children.remove(figure);
};
draw2d.GizmoProfileFigure.prototype.setDimension=function(w,h){
draw2d.Figure.prototype.setDimension.call(this,w,h);
};
/**
 * @private
 **/
draw2d.GizmoProfileFigure.prototype.createHTMLElement=function()
{
  var item = draw2d.Node.prototype.createHTMLElement.call(this);  
  item.style.position="absolute";
  item.style.margin="0px";
  item.style.padding="0px";
  item.style.border= "1px solid black";
  item.style.cursor=null;

  this.titlebar = document.createElement("div");
  this.titlebar.style.position="absolute";
  this.titlebar.style.left   = "0px";
  this.titlebar.style.top    = "0px";
  this.titlebar.style.width = (this.getWidth()-5)+"px";
  this.titlebar.style.height = "15px";
  this.titlebar.style.margin = "0px";
  this.titlebar.style.padding= "0px";
  this.titlebar.style.font="normal 10px verdana";
  //this.titlebar.style.backgroundColor="blue";
  //this.titlebar.style.borderBottom="1px solid gray";
  this.titlebar.style.borderLeft="5px solid transparent";
  this.titlebar.style.whiteSpace="nowrap";
  this.titlebar.style.textAlign="left";
  this.titlebar.style.backgroundColor="#CA011F";
  this.titlebar.style.color="white";
  this.textNode = document.createTextNode(this.displayName);
  this.titlebar.appendChild(this.textNode);

  item.appendChild(this.titlebar);
  return item;
};

draw2d.GizmoProfileFigure.prototype.onFigureEnter = function(/*:draw2d.Figure*/ figure)
{
  // Don't higlight if the figure already a child
  //
  //if(this.children[figure.id]===null)
     //this.setBackgroundColor(this.highlightBackgroundColor);
	alert("E " + this.name + " : " + this.children.size);
  draw2d.CompartmentFigure.prototype.onFigureEnter.call(this,figure);
  //return false;
};

draw2d.GizmoProfileFigure.prototype.onFigureLeave = function(/*:draw2d.Figure*/ figure)
{
	//alert('b')
	alert("L " + this.name + " : " + this.children.size);
	if(figure instanceof draw2d.GizmoFigure)
	{
		figure.movedOutOfCompartment = true;		
		return;
	}
	draw2d.CompartmentFigure.prototype.onFigureLeave.call(this,figure);
};

draw2d.GizmoProfileFigure.prototype.onFigureDrop = function(/*:draw2d.Figure*/ figure)
{
  draw2d.CompartmentFigure.prototype.onFigureDrop.call(this,figure);

  this.setBackgroundColor(this.defaultBackgroundColor);
};


/**
 * @param {int} w new width of the window. 
 * @param {int} h new height of the window. 
 **/
draw2d.GizmoProfileFigure.prototype.setDimension=function( w /*:int*/, h /*:int*/)
{
  draw2d.CompartmentFigure.prototype.setDimension.call(this,w,h);
  if(this.titlebar!==null)
  {
    this.titlebar.style.width=(this.getWidth()-5)+"px";
  }
};

/**
 * @param {String} title The new title of the window
 **/
draw2d.GizmoProfileFigure.prototype.setTitle= function(title /*:String*/)
{
  this.title = title;
};

/**
 * @type int
 **/
draw2d.GizmoProfileFigure.prototype.getMinWidth=function()
{
  return 50;
};

/**
 * @type int
 **/
draw2d.GizmoProfileFigure.prototype.getMinHeight=function()
{
  return 50;
};


/**
 *
 **/
draw2d.GizmoProfileFigure.prototype.setBackgroundColor= function(/*:draw2d.Color*/ color)
{
  this.bgColor = color;
  if(this.bgColor!==null)
    this.html.style.backgroundColor=this.bgColor.getHTMLStyle();
  else
    this.html.style.backgroundColor="transparent";
};

draw2d.GizmoProfileFigure.prototype.onDrag=function(){
var oldX=this.getX();
var oldY=this.getY();
draw2d.Node.prototype.onDrag.call(this);
for(var i=0;i<this.children.getSize();i++){
var child=this.children.get(i);
child.setPosition(child.getX()+this.getX()-oldX,child.getY()+this.getY()-oldY);
}
};

draw2d.GizmoProfileFigure.prototype.onDragend=function()
{ 	
	var any = draw2d.Node.prototype.onDragend.call(this);
	if(this.workflow instanceof draw2d.GizmoWorkflow)
	{
		if(this.workflow.callAjax == false) return;
		
		var data = "name="+this.process+"_"+this.name+"&topLeftX="+this.x+"&topLeftY="+this.y+"&width="+this.width+"&height="+this.height;
		for(var i=0;i<this.children.size; i++)
		{
			var child = this.children.get(i);
			if(child.isIntraProcess) var n = this.process+"_"+this.name +"_"+ child.process +"_"+ child.figName; 
			else var n = this.process+"_"+this.name +"_"+ child.figName; 
			data += "&name="+n+"&topLeftX="+child.x+"&topLeftY="+child.y+"&width="+child.width+"&height="+child.height;
		}
		jQuery.ajax({
			url: 'updateCoordinates.jsp',
			type: 'POST',
			data: data,
			dataType: 'json',
			success: function(resp) {
				if (resp.STATUS == "ERROR")
				{
					alert("Some problem occured while saving coordinates of this object");
				}
			}
		});	
	}
}	
