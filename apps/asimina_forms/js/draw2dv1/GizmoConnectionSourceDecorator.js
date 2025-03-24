/*
* This class extends draw2d.ArrowConnectionDecorator
* The original class does not allow to set the height and width of arrow while initializing ArrowConnectionDecorator which this class lets the developer to do
*/

//need to implement this to show text
draw2d.Graphics.prototype.writeConnectionLabel=function(isVisible, id, htm, txt, X, Y){
	var tooltipId = "tooltip_" + id;
	var lableHtml = '<div onmouseover="document.getElementById(\''+tooltipId+'\').style.display=\'block\';" onmouseout="document.getElementById(\''+tooltipId+'\').style.display=\'none\';" id="'+id+'" style="font-size:10px;position:absolute;white-space:nowrap;';
			if(isVisible === true) lableHtml += 'display:block;';
			else lableHtml += 'display:none;';
			lableHtml += 'left:' + X + 'px;'+'top:' + Y + 'px;'+'">'+
			htm +
			'<\/div>';			
	this.jsGraphics.htm += lableHtml;
	
	X = X + 10;
	Y = Y - 5;
	lableHtml = '<div id="tooltip_'+id+'" class="errcode_tooltip" style="left:' + X + 'px;'+'top:' + Y + 'px;'+'">'+ txt + '<\/div>';
	this.jsGraphics.htm += lableHtml;
};
draw2d.GizmoConnectionSourceDecorator=function(_parent){
	this.parent = _parent;
	this.errCodeDivId='errCode_lbl_' + draw2d.UUID.create();
	this.labelVisible=false;
};
draw2d.GizmoConnectionSourceDecorator.prototype=new draw2d.ConnectionDecorator();
draw2d.GizmoConnectionSourceDecorator.prototype.type="draw2d.GizmoConnectionSourceDecorator";
draw2d.GizmoConnectionSourceDecorator.prototype.paint=function(g){	
	var htm = this.getLabelFormattedText();
	var txt = this.getLabelText();
	g.writeConnectionLabel(this.labelVisible, this.errCodeDivId, htm, txt, g.xt + 5, g.yt); 
};
draw2d.GizmoConnectionSourceDecorator.prototype.getLabelFormattedText=function()
{
	var htm = '';
	var txt = '';
	for(var i=0;i<this.parent.errCode.size;i++)
	{
		if(i==0) 
		{
			htm = "<span style='color:"+this.parent.errColor.get(i)+"'>" + this.parent.errCode.get(i) + "</span>";
			txt = this.parent.errCode.get(i);
		}
		else 
		{
			htm += ", " + "<span style='color:"+this.parent.errColor.get(i)+"'>" + this.parent.errCode.get(i) + "</span>";
			txt += ", " + this.parent.errCode.get(i);
		}
		if(txt.length > 5 && i < this.parent.errCode.size - 1 ) 
		{
			htm += "...";
			break;
		}
	}
	return htm;
};
draw2d.GizmoConnectionSourceDecorator.prototype.getLabelText=function()
{
	var htm = '';
	for(var i=0;i<this.parent.errCode.size;i++)
	{
		if(i==0) htm = this.parent.errCode.get(i);
		else htm += ", " + this.parent.errCode.get(i);
	}
	return htm;
};
draw2d.GizmoConnectionSourceDecorator.prototype.updateErrInfo=function()
{
	if(document.getElementById(this.errCodeDivId))
	{		
		document.getElementById(this.errCodeDivId).innerHTML = this.getLabelFormattedText();
		var tooltipId = "tooltip_" + this.errCodeDivId;
		document.getElementById(tooltipId).innerHTML = this.getLabelText();
	}
};
draw2d.GizmoConnectionSourceDecorator.prototype.hideLabels=function()
{
	this.labelVisible=false;
	document.getElementById(this.errCodeDivId).style.display='none';
};
draw2d.GizmoConnectionSourceDecorator.prototype.showLabels=function()
{
	this.labelVisible=true;
	document.getElementById(this.errCodeDivId).style.display='block';
};
draw2d.GizmoConnectionSourceDecorator.prototype.setLabelVisible=function(isVisible)
{
	this.labelVisible = isVisible;
}
