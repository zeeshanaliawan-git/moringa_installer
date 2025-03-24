Graph = function(container, nodeWidth, nodeHeight)
{
	this.container = container;
	this.nodes = [];
	this.edges = [];
	this.nodeWidth = 100; //default
	this.nodeHeight = 100; //default

	this.graphMinX = 0;
	this.graphMaxX = 0;
	this.graphMinY = 0;
	this.graphMaxY = 0;

	this.nodeWidth = nodeWidth;
	this.nodeHeight = nodeHeight;

	if(container.style.left.indexOf('px') != -1) this.factorX = container.style.left.substring(0, container.style.left.indexOf('px'));
	else this.factorX = container.style.left;

	if(container.style.top.indexOf('px') != -1) this.factorY = container.style.top.substring(0, container.style.top.indexOf('px'));
	else this.factorY = container.style.top;

	this.factorX = 0;
	this.factorY = 0;

	if(navigator.userAgent.indexOf('Firefox') != -1)
		this.renderer = 'CANVAS';
	else
		this.renderer = 'VML';

	this.IEHtml;
	
	this.drawAreaMargin = 40;
	this.selfLineMargin = 30;
	
	this.VMLTextAdjustmentLeft = 20;
	this.VMLTextAdjustmentTop = 40;
}

Graph.prototype.addEdge = function(sourceId, targetId, contents) 
{ 
//	alert('source : ' + sourceId + ' target : ' + targetId + '   ' + contents);
        var edge = {source: sourceId, target: targetId, contents: contents};
        this.edges.push(edge);
}

Graph.prototype.addNode = function(nodeId, topLeftX, topLeftY, contents, background)
{
	var node;
	for(var i=0; i< this.nodes.length; i++)
	{
		if(this.nodes[i].id == nodeId)
		{
			node = this.nodes[i];
			break;
		}
	}

	if(this.nodes.length == 0)
	{
		this.graphMinX = topLeftX;
		this.graphMinY = topLeftY;
		this.graphMaxX = topLeftX + this.nodeWidth;
		this.graphMaxY = topLeftY + this.nodeHeight;
	}
	else
	{
		if(this.graphMinX > topLeftX)
			this.graphMixX = topLeftX;
		if(this.graphMinY > topLeftY)
			this.graphMinY = topLeftY;
		if(this.graphMaxX < (topLeftX + this.nodeWidth))
			this.graphMaxX = topLeftX + this.nodeWidth;
		if(this.graphMaxY < (topLeftY + this.nodeHeight))
			this.graphMaxY = topLeftY + this.nodeHeight;
	}
        if(node == undefined) 
	{
        	node = new Graph.Node();
		node.initialize(nodeId, topLeftX, topLeftY, contents, background); 
                this.nodes.push(node);
        }		
}

Graph.Node = function()
{
	var id;
	var contents;
	var topLeftX;
	var topLeftY;
	var background;
}

Graph.Node.prototype.initialize = function(id, x, y, contents, background)
{
	this.id = id;
	this.topLeftX = x;
	this.topLeftY = y;
	this.contents = contents;
	this.background = background;
}

Graph.prototype.InitializeDrawingArea = function()
{
	canElementX = this.graphMinX - this.drawAreaMargin;
	if(canElementX < 0) canElementX = 0;
	canElementY = this.graphMinY - this.drawAreaMargin;
	if(canElementY < 0) canElementY = 0;
	canElementWidth = this.graphMaxX + this.drawAreaMargin;
	canElementHeight = this.graphMaxY + this.drawAreaMargin;	

	if(this.renderer == 'CANVAS')
	{
		canvasElement = document.createElement('canvas');
		canvasElement.id = 'graphCanvas';
		this.container.appendChild(canvasElement);

		canvasElement.left = canElementX;
		canvasElement.top = canElementY;
		canvasElement.width = canElementWidth;
		canvasElement.height = canElementHeight;
//		canvasElement.style.border = '1px solid black';

		this.ctx = canvasElement.getContext("2d");
	}
	else if(this.renderer == 'VML')
	{
		this.IEHtml = '<v:group coordsize="'+canElementWidth+',' +canElementHeight+'" coordorigin="0, 0" style="position:absolute;width='+canElementWidth+'px;height='+canElementHeight+'px;" >'
	}
}

Graph.prototype.Draw = function()
{
	this.InitializeDrawingArea();

	for(var i=0;i<this.nodes.length;i++)
	{
		this.DrawNode(this.nodes[i]);
	}	

	
	for(var i=0;i<this.edges.length;i++)
	{
		var sourceNode;
		for(var j=0;j<this.nodes.length;j++)
		{
			if(this.edges[i].source == this.nodes[j].id)
			{
				sourceNode = this.nodes[j];
				break;
			}
		}
		var targetNode;
		for(var k=0;k<this.nodes.length;k++)
		{
			if(this.edges[i].target == this.nodes[k].id)
			{				
				targetNode = this.nodes[k];
				break;
			}
		}				
		var contents = this.edges[i].contents;

		if(sourceNode.id == targetNode.id)
		{
			this.DrawLineToSelf(sourceNode, contents);
		}
		else
		{				
			var sourceNodeOnTop = 0;
			var sourceNodeBelow = 0;
			var sourceNodeOnLeft = 0;
			var sourceNodeOnRight = 0;

			if((sourceNode.topLeftY + this.nodeHeight) < targetNode.topLeftY) sourceNodeOnTop = 1;
			else if(sourceNode.topLeftY > (targetNode.topLeftY + this.nodeHeight)) sourceNodeBelow = 1;

			if((sourceNode.topLeftX + this.nodeWidth) < targetNode.topLeftX) sourceNodeOnLeft = 1;
			else if(sourceNode.topLeftX > (targetNode.topLeftX + this.nodeWidth)) sourceNodeOnRight = 1;
	
			if(sourceNodeOnLeft == 1)
			{ 				
				this.DrawLine(sourceNode.topLeftX + this.nodeWidth, sourceNode.topLeftY + (this.nodeHeight/2),targetNode.topLeftX, targetNode.topLeftY + (this.nodeHeight/2));
				this.DrawArrow(sourceNode.topLeftX + this.nodeWidth, sourceNode.topLeftY + (this.nodeHeight/2), targetNode.topLeftX, targetNode.topLeftY + (this.nodeHeight/2));
//				this.addContentsToArc(sourceNode.id, targetNode.id, contents, sourceNode.topLeftX + this.nodeWidth, sourceNode.topLeftY + (this.nodeHeight/2), targetNode.topLeftX, targetNode.topLeftY + (this.nodeHeight/2));  
			}
			else if(sourceNodeOnTop == 1)
			{
				this.DrawLine(sourceNode.topLeftX + (this.nodeWidth/2), sourceNode.topLeftY + this.nodeHeight, targetNode.topLeftX + (this.nodeWidth/2), targetNode.topLeftY);
				this.DrawArrow(sourceNode.topLeftX + (this.nodeWidth/2), sourceNode.topLeftY + this.nodeHeight, targetNode.topLeftX + (this.nodeWidth/2), targetNode.topLeftY);
//				this.addContentsToArc(sourceNode.id, targetNode.id, contents, sourceNode.topLeftX + (this.nodeWidth/2), sourceNode.topLeftY + this.nodeHeight, targetNode.topLeftX + (this.nodeWidth/2), targetNode.topLeftY);  
			}	
			else if(sourceNodeOnRight == 1)
			{				
				this.DrawLine(sourceNode.topLeftX, sourceNode.topLeftY + (this.nodeHeight/2), targetNode.topLeftX + this.nodeWidth, targetNode.topLeftY + (this.nodeHeight/2));
				this.DrawArrow(sourceNode.topLeftX, sourceNode.topLeftY + (this.nodeHeight/2), targetNode.topLeftX + this.nodeWidth, targetNode.topLeftY + (this.nodeHeight/2));
//				this.addContentsToArc(sourceNode.id, targetNode.id, contents, sourceNode.topLeftX, sourceNode.topLeftY + (this.nodeHeight/2), targetNode.topLeftX + this.nodeWidth, targetNode.topLeftY + (this.nodeHeight/2));
			}
			else if(sourceNodeBelow == 1)
			{				
				this.DrawLine(sourceNode.topLeftX + (this.nodeWidth/2), sourceNode.topLeftY, targetNode.topLeftX + (this.nodeWidth/2), targetNode.topLeftY + this.nodeHeight);
				this.DrawArrow(sourceNode.topLeftX + (this.nodeWidth/2), sourceNode.topLeftY, targetNode.topLeftX + (this.nodeWidth/2), targetNode.topLeftY + this.nodeHeight);
//				this.addContentsToArc(sourceNode.id, targetNode.id, contents, sourceNode.topLeftX + (this.nodeWidth/2), sourceNode.topLeftY, targetNode.topLeftX + (this.nodeWidth/2), targetNode.topLeftY + this.nodeHeight);
			}	
		}
	}

	if(this.renderer == 'VML')
	{	
		this.IEHtml = this.IEHtml + '</v:group>';
		this.container.innerHTML = this.IEHtml;
	}
}

Graph.prototype.DrawNode = function(node)
{
	
        var element = document.createElement('div');
	element.id = "node_" + node.id
	element.innerHTML = node.contents;
	element.style.position = 'absolute';
	element.style.left = node.topLeftX + 5;
	element.style.top = node.topLeftY + 5;
	element.style.width = this.nodeWidth - 10;
	element.style.height = this.nodeHeight - 10;
//	element.style.border = '1px solid black';
	
	
	if(this.renderer == 'CANVAS')
	{
		this.container.appendChild(element);
		this.ctx.strokeStyle = 'black';
                this.ctx.beginPath();
		if(node.background != undefined) 
		{
			this.ctx.fillStyle = node.background;
			this.ctx.fillRect(node.topLeftX, node.topLeftY, this.nodeWidth, this.nodeHeight);
		}
                this.ctx.strokeRect(node.topLeftX, node.topLeftY, this.nodeWidth, this.nodeHeight);

                this.ctx.closePath();
                this.ctx.stroke();
	}
	else if(this.renderer == 'VML')
	{
		this.IEHtml = this.IEHtml + '<v:rect style="padding:5px;position:absolute;top:'+node.topLeftY+';left:'+node.topLeftX+';width:'+this.nodeWidth+';height:'+this.nodeHeight+';"';
		if(node.background != undefined)
		{
			this.IEHtml = this.IEHtml + ' fillcolor="' + node.background + '" ';
		}
		this.IEHtml = this.IEHtml + '>';
		this.IEHtml = this.IEHtml + element.innerHTML;
		this.IEHtml = this.IEHtml + '</v:rect>';
	}
}

Graph.prototype.DrawLineToSelf = function(node, arcContents)
{
	if(this.renderer == 'CANVAS')
	{
		this.ctx.strokeStyle = 'black';
        	this.ctx.fillStyle = 'black';
                this.ctx.lineWidth = 1.0;

                this.ctx.beginPath();
       	        this.ctx.moveTo(node.topLeftX + (this.nodeWidth/2), node.topLeftY);
               	this.ctx.lineTo(node.topLeftX + (this.nodeWidth/2), node.topLeftY - this.selfLineMargin);
		this.ctx.lineTo(node.topLeftX - this.selfLineMargin, node.topLeftY - this.selfLineMargin);
		this.ctx.lineTo(node.topLeftX - this.selfLineMargin, node.topLeftY + (this.nodeHeight/2));				
		this.ctx.lineTo(node.topLeftX, node.topLeftY + (this.nodeHeight/2));
                this.ctx.stroke();
		this.DrawArrow(node.topLeftX - this.selfLineMargin, node.topLeftY + (this.nodeHeight/2), node.topLeftX, node.topLeftY + (this.nodeHeight/2));

		if(arcContents != '' && arcContents != undefined)
		{ 
			var divArc = document.createElement('div');
			divArc.id = 'arc_'+node.id+'_'+node.id;
			divArc.innerHTML = arcContents;
			divArc.style.position = 'absolute';
			divArc.style.left = node.topLeftX;
			divArc.style.top = node.topLeftY - this.selfLineMargin;
			this.container.appendChild(divArc);			
		}
	}
	else if(this.renderer == 'VML')
	{
		this.IEHtml = this.IEHtml + '<v:line from="'+(node.topLeftX + (this.nodeWidth/2))+','+node.topLeftY+'" to="'+(node.topLeftX + (this.nodeWidth/2))+','+(node.topLeftY - this.selfLineMargin)+'"></v:line>';
		this.IEHtml = this.IEHtml + '<v:line from="'+(node.topLeftX + (this.nodeWidth/2))+','+(node.topLeftY - this.selfLineMargin)+'" to="'+(node.topLeftX - this.selfLineMargin)+','+(node.topLeftY - this.selfLineMargin)+'"></v:line>';
		this.IEHtml = this.IEHtml + '<v:line from="'+(node.topLeftX - this.selfLineMargin)+','+(node.topLeftY - this.selfLineMargin)+'" to="'+(node.topLeftX - this.selfLineMargin)+','+(node.topLeftY + (this.nodeHeight/2))+'"></v:line>';
		this.IEHtml = this.IEHtml + '<v:line from="'+(node.topLeftX - this.selfLineMargin)+','+( node.topLeftY + (this.nodeHeight/2))+'" to="'+(node.topLeftX)+','+(node.topLeftY + (this.nodeHeight/2))+'"><v:stroke endarrow="classic"/></v:line>';

		if(arcContents != '' && arcContents != undefined)
		{ 
			this.IEHtml = this.IEHtml + '<v:textbox style="position:absolute;padding:0;top:'+(node.topLeftY - this.selfLineMargin-this.VMLTextAdjustmentTop)+'px;left:'+(node.topLeftX-this.VMLTextAdjustmentLeft)+'px;">'+arcContents+'</v:textbox>';
		}
	}
}

Graph.prototype.DrawLine = function (fromX, fromY, toX, toY)
{
	if(this.renderer == 'CANVAS')
	{
		this.ctx.strokeStyle = 'black';
        	this.ctx.fillStyle = 'black';
                this.ctx.lineWidth = 1.0;

                this.ctx.beginPath();
       	        this.ctx.moveTo(fromX, fromY);
               	this.ctx.lineTo(toX, toY);				
                this.ctx.stroke();
	}
	else if(this.renderer == 'VML')
	{
		this.IEHtml = this.IEHtml + '<v:line from="'+fromX+','+fromY+'" to="'+toX+','+toY+'"><v:stroke endarrow="classic"/></v:line>';
	}
}

Graph.prototype.addContentsToArc = function(sourceNodeId, targetNodeId, contents, sourceX, sourceY, targetX, targetY)
{
	if(contents != '' && contents != undefined)
	{		
		var divTop = 0;
		var divLeft = 0;
		if((targetY - sourceY) == 0)
		{
			divTop = targetY;
			divLeft = (targetX - sourceX)/2;
			divLeft = sourceX + divLeft;
		}
		else if (targetX - sourceX == 0)
		{
			divLeft = targetX;
			divTop = (targetY - sourceY)/2;
			divTop = sourceY + divTop;
		}
		else
		{
			divLeft = ((targetX - sourceX)/2);
			divLeft = sourceX + divLeft;

			divTop = ((targetY - sourceY)/2);
			divTop = sourceY + divTop;
		}
		
		divLeft = divLeft + this.factorX;
		divTop = divTop + this.factorY;
		
		if(this.renderer == 'CANVAS')
		{
			var divArc = document.createElement('div');
			divArc.id = 'arc_'+sourceNodeId+'_'+targetNodeId;
			divArc.innerHTML = contents;
			divArc.style.position = 'absolute';
			divArc.style.left = divLeft;
			divArc.style.top = divTop;

			this.container.appendChild(divArc);
		}

		else if(this.renderer == 'VML') 
		{
			divTop = divTop - this.VMLTextAdjustmentTop;
			divLeft = divLeft - this.VMLTextAdjustmentLeft;
			this.IEHtml = this.IEHtml + '<v:textbox style="position:absolute;padding:0;top:'+divTop+'px;left:'+divLeft+'px;">'+contents+'</v:textbox>';
		}
	}
}

Graph.prototype.DrawArrow = function (sourceX, sourceY, targetX, targetY)
{
	if(this.renderer == 'VML') return; //vml provides arrow itself with v:line

        var tan = (targetY - sourceY) / (targetX - sourceX); //calc gradient
        var theta = Math.atan(tan);

	if(sourceX <= targetX) theta = Math.PI + theta;

	var length = 10;	//length of arrow
	var alpha = Math.PI/10; //angle of arrow

	var dx1 = length * Math.cos(theta + alpha)
        var dy1 = length * Math.sin(theta + alpha);

	var dx2 = length * Math.cos(theta - alpha)
        var dy2 = length * Math.sin(theta - alpha);

	var x1 = targetX + dx1;
	var y1 = targetY + dy1;
	var x2 = targetX + dx2;
	var y2 = targetY + dy2;

       	this.ctx.beginPath();
        this.ctx.moveTo(targetX, targetY);
        this.ctx.lineTo(x1,y1);
        this.ctx.lineTo(x2,y2);
       	this.ctx.fill();
}
