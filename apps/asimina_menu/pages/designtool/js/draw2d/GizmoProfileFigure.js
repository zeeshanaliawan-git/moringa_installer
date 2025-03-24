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
  this.defaultBackgroundColor = new  draw2d.Color(255,255,255);
  this.highlightBackgroundColor = new  draw2d.Color(250,250,200);

  draw2d.CompartmentFigure.call(this);
  this.setDimension(width, height);
  this.setBackgroundColor(this.defaultBackgroundColor);
  this.setDeleteable(false);
  
  //this.removeEventListener("figureetner", this);
  //this.removeEventListener("figureleave", this);
  this.originalZIndex = this.html.style.zIndex;
};

draw2d.GizmoProfileFigure.prototype = new draw2d.CompartmentFigure();


draw2d.GizmoProfileFigure.prototype.setDimension=function(w,h){
draw2d.CompartmentFigure.prototype.setDimension.call(this,w,h);
};
/**
 * @private
 **/
draw2d.GizmoProfileFigure.prototype.createHTMLElement=function()
{
  var item = draw2d.CompartmentFigure.prototype.createHTMLElement.call(this);
  item.style.margin="0px";
  item.style.padding="0px";
  item.style.border= "1px solid black";

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
  this.titlebar.style.backgroundColor="#ccc";
  this.titlebar.style.color="black";
  this.textNode = document.createTextNode(this.displayName);
  this.titlebar.appendChild(this.textNode);
  this.titlebar.style.cursor="move";

  item.appendChild(this.titlebar);
  return item;
};

draw2d.GizmoProfileFigure.prototype.figureExists = function(figure)
{
	var alreadyExists = false;
	for(var i=0;i<this.children.size;i++)
	{
		if(this.children.get(i).id === figure.id)
		{
			alreadyExists = true;
			break;
		}
	}
	return alreadyExists;
};
draw2d.GizmoProfileFigure.prototype.onFigureEnter = function(/*:draw2d.Figure*/ figure)
{
  // Don't higlight if the figure already a child
  //
  
//  if(this.children[figure.id]===null)
  //   this.setBackgroundColor(this.highlightBackgroundColor);
/*  if(figure instanceof draw2d.GizmoFigure && figure.originalCompartment.id === this.id)
  {
	if(!this.figureExists(figure))
	{
		draw2d.CompartmentFigure.prototype.onFigureEnter.call(this,figure);
		this.addChild(figure);
	}
  }*/
  if(figure instanceof draw2d.GizmoProfileFigure) 
  {
	figure.html.style.zIndex = figure.originalZIndex;
	return null;
  }
};
draw2d.GizmoProfileFigure.prototype.addChild = function(/*:draw2d.Figure*/ figure)
{
	if(this.figureExists(figure)) return;
	draw2d.CompartmentFigure.prototype.addChild.call(this, figure);
};
draw2d.GizmoProfileFigure.prototype.removeChild = function(/*:draw2d.Figure*/ figure)
{
	var index = -1;
	for(var i=0;i<this.children.size;i++)
	{
		if(this.children.get(i).id === figure.id)
		{
			index = i;
			break;
		}
	}	
	if(index > -1) 
	{	
		this.children.removeElementAt(index);
		draw2d.CompartmentFigure.prototype.removeChild.call(this, figure);
	}
};
draw2d.GizmoProfileFigure.prototype.onFigureLeave = function(/*:draw2d.Figure*/ figure)
{
	if(figure instanceof draw2d.GizmoFigure) return true;
	draw2d.CompartmentFigure.prototype.onFigureLeave.call(this,figure);
	this.removeChild(figure);
};

draw2d.GizmoProfileFigure.prototype.onFigureDrop = function(/*:draw2d.Figure*/ figure)
{
  if(figure instanceof draw2d.GizmoProfileFigure) 
  {
	figure.html.style.zIndex = figure.originalZIndex;
	return;
  }  
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

draw2d.GizmoProfileFigure.prototype.onDragend=function()
{ 	
	this.html.style.zIndex = this.originalZIndex;
	var any = draw2d.Node.prototype.onDragend.call(this);
	if(this.workflow instanceof draw2d.GizmoWorkflow)
	{
		if(this.workflow.callAjax == false) return;
		var _y = this.y - this.workflow.deltaY;		
		var _shifted = 0;
		if(_y < 0) 
		{
			_shifted = ((-1) * _y ) + 1;
			_y = 1;
		}
		var data = "isPhase=0&process="+this.process+"&profile="+this.name+"&phase=&topLeftX="+this.x+"&topLeftY="+_y+"&width="+this.width+"&height="+this.height;
		for(var i=0;i<this.children.size; i++)
		{
			var child = this.children.get(i);
			if(!child.group.isExternalPhaseGroup) 
			{
				var _cy = child.y + _shifted - this.workflow.deltaY;
				data += "&isPhase=1&process="+this.process+"&profile="+this.name+"&phase="+child.group.figName+"&topLeftX="+child.x+"&topLeftY="+_cy+"&width="+child.width+"&height="+child.height;
			}
		}
		for(var i=0;i<this.workflow.connectionGroups.size;i++)
		{
			this.workflow.connectionGroups.get(i).refreshErrInfo();
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
};
draw2d.GizmoProfileFigure.prototype.getContextMenu=function(){
if(!this.workflow.callAjax) return null;
this.workflow.anyMenuShowing=true;//signaling workflow not to show its menu if this menu is visible
var menu=new draw2d.Menu();
menu.html.style.textAlign="left";
//menu.className="draw2dMenu";
//menu.html.style.color="#CA011F";
var oThis=this;
menu.appendMenuItem(new draw2d.MenuItem("Add Phase",null,function(){
oThis.workflow.onNewPhase(oThis.name, oThis.clickX, oThis.clickY);
}));
if(oThis.workflow.copiedPhase != null)
menu.appendMenuItem(new draw2d.MenuItem("Paste",null,function(){
oThis.workflow.onPastePhase(oThis, oThis.clickX, oThis.clickY);
}));
return menu;
};
draw2d.GizmoProfileFigure.prototype.onContextMenu=function(x,y){
	this.clickX = x;
	this.clickY = y;
	draw2d.CompartmentFigure.prototype.onContextMenu.call(this, x, y);
};
draw2d.GizmoProfileFigure.prototype.hide=function(_workflow)
{	
	var _callAjax = _workflow.callAjax;
	var _partialUpdate = _workflow.partialUpdate;
	_workflow.setCallAjax(false);
	_workflow.setPartialUpdate(false);
	
	_workflow.removeFigure(this);
	for(var i=0; i<this.children.size;i++)
	{
		this.children.get(i).hide(_workflow);
		//var pGrp = this.children.get(i).group;
//		pGrp.removeChild(this.children.get(i));
		//if(pGrp.children.size === 0) _workflow.removePhaseGroup(pGrp);		
		//although this phase is removed from its group but we set the group back coz all information related to phase is there in the group. 
		//Setting it back does not mean its added to phase group. We might need this group later to get phase info so have to save it
		//this.children.get(i).group = pGrp;
		this.children.get(i).profileCompartmentIsHidden=true;
	}

	_workflow.setCallAjax(_callAjax);
	_workflow.setPartialUpdate(_partialUpdate);
	
};
draw2d.GizmoProfileFigure.prototype.show=function(_workflow)
{	
	var _callAjax = _workflow.callAjax;
	var _partialUpdate = _workflow.partialUpdate;
	_workflow.setCallAjax(false);
	_workflow.setPartialUpdate(false);
	
	_workflow.addFigure(this);
	for(var i=0; i<this.children.size;i++)
	{
		if(this.children.get(i).group.children.size > 0)
		{
			this.children.get(i).profileCompartmentIsHidden=false;
			this.children.get(i).show(_workflow);			
		}
	}
	for(var i=0; i<this.children.size;i++)
	{
		if(this.children.get(i).group.children.size === 0)
		{
			this.children.get(i).profileCompartmentIsHidden=false;
			this.children.get(i).show(_workflow);			
		}
	}
	for(var i=0;i<_workflow.connectionGroups.size;i++)
	{
		_workflow.connectionGroups.get(i).refreshErrInfo();
	}

	_workflow.setCallAjax(_callAjax);
	_workflow.setPartialUpdate(_partialUpdate);
	
};
