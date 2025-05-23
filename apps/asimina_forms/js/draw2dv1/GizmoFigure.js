/*
* This class is responsible for rendering the rounded figure. It extends draw2d.Node class
*/
var editPhase = null;

draw2d.GizmoFigure=function(width, height, name, act, prio, exe, visible, rulesVisibleTo, displayName, proc, loadedProc){
this.figName = name;
this.displayName = displayName;
this.actors = act;
this.priority = prio;
this.execute = exe;
this.visible = visible;
this.rulesVisibleTo = rulesVisibleTo;
this.cornerWidth=15;
this.cornerHeight=15;
this.outputPort=null;
this.inputPort=null;
draw2d.Node.call(this);
this.setDimension(width, height);
this.originalHeight=-1;
this.allowDoubleClick=true;
this.process = proc;
this.isIntraProcess=false;
this.loadedProcess = loadedProc;
};
draw2d.GizmoFigure.prototype=new draw2d.Node();
draw2d.GizmoFigure.prototype.type="GizmoFigure";
draw2d.GizmoFigure.prototype.createHTMLElement=function(){
var item=document.createElement("div");
item.id=this.id;
item.style.position="absolute";
item.style.left=this.x+"px";
item.style.top=this.y+"px";
item.style.height=this.width+"px";
item.style.width=this.height+"px";
item.style.margin="0px";
item.style.padding="0px";
item.style.outline="none";
item.style.zIndex=""+draw2d.Figure.ZOrderBaseIndex;
this.top_left=document.createElement("div");
this.top_left.style.background="url(img/circle.png) no-repeat top left";
this.top_left.style.position="absolute";
this.top_left.style.width=this.cornerWidth+"px";
this.top_left.style.height=this.cornerHeight+"px";
this.top_left.style.left="0px";
this.top_left.style.top="0px";
this.top_left.style.fontSize="2px";
this.top_right=document.createElement("div");
this.top_right.style.background="url(img/circle.png) no-repeat top right";
this.top_right.style.position="absolute";
this.top_right.style.width=this.cornerWidth+"px";
this.top_right.style.height=this.cornerHeight+"px";
this.top_right.style.left="0px";
this.top_right.style.top="0px";
this.top_right.style.fontSize="2px";
this.bottom_left=document.createElement("div");
this.bottom_left.style.background="url(img/circle.png) no-repeat bottom left";
this.bottom_left.style.position="absolute";
this.bottom_left.style.width=this.cornerWidth+"px";
this.bottom_left.style.height=this.cornerHeight+"px";
this.bottom_left.style.left="0px";
this.bottom_left.style.top="0px";
this.bottom_left.style.fontSize="2px";
this.bottom_right=document.createElement("div");
this.bottom_right.style.background="url(img/circle.png) no-repeat bottom right";
this.bottom_right.style.position="absolute";
this.bottom_right.style.width=this.cornerWidth+"px";
this.bottom_right.style.height=this.cornerHeight+"px";
this.bottom_right.style.left="0px";
this.bottom_right.style.top="0px";
this.bottom_right.style.fontSize="2px";
this.header=document.createElement("div");
this.header.style.position="absolute";
this.header.style.left=this.cornerWidth+"px";
this.header.style.top="0px";
this.header.style.height=(this.cornerHeight)+"px";
this.header.style.backgroundColor="#CCCCFF";
this.header.style.borderTop="3px solid #666666";
this.header.style.fontSize="9px";
this.header.style.textAlign="center";
this.disableTextSelection(this.header);
this.footer=document.createElement("div");
this.footer.style.position="absolute";
this.footer.style.left=this.cornerWidth+"px";
this.footer.style.top="0px";
this.footer.style.height=(this.cornerHeight-1)+"px";
/*if (navigator.appName.indexOf("Microsoft Internet Explorer") >= 0)
{
	this.footer.style.height=(this.cornerHeight-1)+"px";
}
else
{
	this.footer.style.height=(this.cornerHeight-1)+"px";
}*/

this.footer.style.backgroundColor="white";
this.footer.style.borderBottom="1px solid #666666";
this.footer.style.fontSize="2px";
this.textarea=document.createElement("div");
this.textarea.style.position="absolute";
this.textarea.style.left="0px";
this.textarea.style.top=this.cornerHeight+"px";
this.textarea.style.backgroundColor="white";
this.textarea.style.borderTop="2px solid #666666";
this.textarea.style.borderLeft="1px solid #666666";
this.textarea.style.borderRight="1px solid #666666";
this.textarea.style.overflow="auto";
this.textarea.style.fontSize="8pt";
this.disableTextSelection(this.textarea);
item.appendChild(this.top_left);
item.appendChild(this.header);
item.appendChild(this.top_right);
item.appendChild(this.textarea);
item.appendChild(this.bottom_left);
item.appendChild(this.footer);
item.appendChild(this.bottom_right);
return item;
};
draw2d.GizmoFigure.prototype.setDimension=function(w,h){
draw2d.Node.prototype.setDimension.call(this,w,h);
if(this.top_left!==null){
this.top_right.style.left=(this.width-this.cornerWidth)+"px";
this.bottom_right.style.left=(this.width-this.cornerWidth)+"px";
this.bottom_right.style.top=(this.height-this.cornerHeight)+"px";
this.bottom_left.style.top=(this.height-this.cornerHeight)+"px";
this.textarea.style.width=(this.width-2)+"px";
/*if (navigator.appName.indexOf("Microsoft Internet Explorer") >= 0)
{
	this.textarea.style.width=(this.width-2)+"px";
}
else
{
	this.textarea.style.width=(this.width-2)+"px";
}*/

if((this.height-this.cornerHeight*2) <=0 ){
this.textarea.style.height="20px";
}
else{
this.textarea.style.height=(this.height-this.cornerHeight*2)+"px";
}

if((this.width-this.cornerWidth*2)<=0)
{
	this.header.style.width = "20px";
	this.footer.style.width = "20px";
}
else
{
	this.header.style.width=(this.width-this.cornerWidth*2)+"px";
	this.footer.style.width=(this.width-this.cornerWidth*2)+"px";
}

this.footer.style.top=(this.height-this.cornerHeight)+"px";
}
if(this.outputPort!==null){
this.outputPort.setPosition(this.width+5,this.height/2);
}
if(this.inputPort!==null){
this.inputPort.setPosition(-5,this.height/2);
}
};
draw2d.GizmoFigure.prototype.setTitle=function(title){
this.header.innerHTML=title;
};
draw2d.GizmoFigure.prototype.setContent=function(_5014){
this.textarea.innerHTML=_5014;
};
draw2d.GizmoFigure.prototype.onDragstart=function(x,y){
var _5017=draw2d.Node.prototype.onDragstart.call(this,x,y);
if(this.header===null){
return false;
}
if(y<this.cornerHeight&&x<this.width&&x>(this.width-this.cornerWidth)){
this.toggle();
return false;
}
if(this.originalHeight==-1){
if(this.canDrag===true&&x<parseInt(this.header.style.width)&&y<parseInt(this.header.style.height)){
return true;
}
}else{
return _5017;
}
};
draw2d.GizmoFigure.prototype.setCanDrag=function(flag){
draw2d.Node.prototype.setCanDrag.call(this,flag);
this.html.style.cursor="";
if(this.header===null){
return;
}
if(flag){
this.header.style.cursor="move";
}else{
this.header.style.cursor="";
}
};
draw2d.GizmoFigure.prototype.setWorkflow=function(_5019){
draw2d.Node.prototype.setWorkflow.call(this,_5019);
if(_5019!==null&&this.inputPort===null){
this.inputPort=new draw2d.GizmoInputPort();
this.inputPort.setWorkflow(_5019);
this.inputPort.setName("input");
this.addPort(this.inputPort,-5,this.height/2);
this.outputPort=new draw2d.GizmoOutputPort();
this.outputPort.setMaxFanOut(50);
this.outputPort.setWorkflow(_5019);
this.outputPort.setName("output");
this.addPort(this.outputPort,this.width+5,this.height/2);
}
};
draw2d.GizmoFigure.prototype.toggle=function(){
if(this.originalHeight==-1){
this.originalHeight=this.height;
this.setDimension(this.width,this.cornerHeight*2);
this.setResizeable(false);
}else{
this.setDimension(this.width,this.originalHeight);
this.originalHeight=-1;
this.setResizeable(true);
}
};
draw2d.GizmoFigure.prototype.onDoubleClick=function(){
	if(this.allowDoubleClick == false) return;
	
	draw2d.Figure.prototype.onDoubleClick.call(this);	

	if(this.isIntraProcess)
	{
		//we will be implementing loadNextProcess in loadGraphicalProcess jsp as thats where we know the exact ID of process drop down which will be set with targetProcess and submitted to load that process
		if(this.loadNextProcess) this.loadNextProcess();
		return;
	}
	var data = "phase="+this.figName+"&process="+this.process+"&callAjax="+this.outputPort.workflow.callAjax+"&rulesVisibleTo="+this.rulesVisibleTo+"&partialUpdate="+this.outputPort.workflow.partialUpdate;	
	jQuery.ajax({
		url: 'showEditPhase.jsp',
		type: 'POST',
		data: data,
		success: function(resp) {
			resp = jQuery.trim(resp);
			jQuery("#modalWindow").dialog("option","title","Edit Phase");
			jQuery("#modalWindow").dialog("option","width","550px");
			jQuery("#modalWindow").dialog("option","height","auto");
			jQuery('#modalWindow').unbind("dialogclose");	   
			jQuery("#modalWindow").html(resp);
			jQuery("#modalWindow").dialog('open');			
		},
		error : function(resp) {
			alert("Some error while communication with server. Try again or contact administrator");
		}				
	});									
	editPhase = this;
};
draw2d.GizmoFigure.prototype.setFigureName=function(figName)
{
	this.figName = figName;
};
draw2d.GizmoFigure.prototype.setDisplayName=function(displayName)
{
	this.displayName = displayName;
	this.setTitle(this.displayName);
};
draw2d.GizmoFigure.prototype.setActors=function(act)
{
	this.actors = act;
};
draw2d.GizmoFigure.prototype.setAllowDoubleClick=function(allow)
{
	this.allowDoubleClick = allow;
};
draw2d.GizmoFigure.prototype.setPriority=function(prio)
{
	this.priority = prio;
};
draw2d.GizmoFigure.prototype.setExecute=function(exe)
{
	this.execute = exe;
};
draw2d.GizmoFigure.prototype.setVisible=function(vis)
{
	this.visible = vis;
};
draw2d.GizmoFigure.prototype.setRulesVisibleTo=function(rulesVisibleTo)
{
	this.rulesVisibleTo = rulesVisibleTo;
};
function onEditPhase(proc, oldPhase)
{
	if(jQuery('#editPhaseName').val() == '')
	{
		jQuery('#editPhaseMsg').html("Enter Phase name");
		return;
	}
	if(jQuery('#editPriority').val() != '' && !IsNumeric(jQuery('#editPriority').val()))
	{
		jQuery('#editPhaseMsg').html("Priority should be numeric");
		return;
	}					

	if(jQuery('#editPhaseDisplayName').val() == '') jQuery('#editPhaseDisplayName').val(jQuery('#editPhaseName').val());
	
	var vis = 0;
	if(document.getElementById('phaseVisible').checked) vis = 1;

	var rulesVisibleTo = "";
	for(var i=0;i<document.getElementsByName("rulesVisibleTo").length; i++)
	{
		if(document.getElementsByName("rulesVisibleTo")[i].checked && rulesVisibleTo == "") rulesVisibleTo = document.getElementsByName("rulesVisibleTo")[i].value;
		else if(document.getElementsByName("rulesVisibleTo")[i].checked) rulesVisibleTo += "|" + document.getElementsByName("rulesVisibleTo")[i].value;
	}

	var isReverse = 0;
	if(document.getElementById('isReverse').checked) isReverse = 1;
	var oprType = "O";
	if(document.getElementById('oprTypeT').checked) oprType = "T";

	var data = "oprType="+oprType+"&isReverse="+isReverse+"&rulesVisibleTo="+rulesVisibleTo+"&visible="+vis+"&action=edit&process="+proc+"&oldPhase="+oldPhase+"&phase="+jQuery('#editPhaseName').val()+"&priority="+jQuery('#editPriority').val()+"&execute="+jQuery('#editExecute').val()+"&actors="+jQuery('#editActors').val()+"&displayName="+jQuery('#editPhaseDisplayName').val();
	jQuery.ajax({
		url: 'addNewPhase.jsp',
		type: 'POST',
		data: data,
		success: function(resp) {
			resp = jQuery.trim(resp);
			if(resp.indexOf('SUCCESS') > -1)
			{	
				editPhase.setFigureName(jQuery('#editPhaseName').val());
				editPhase.setDisplayName(jQuery('#editPhaseDisplayName').val());
				editPhase.setActors(jQuery('#editActors').val());
				editPhase.setPriority(jQuery('#editPriority').val());
				editPhase.setExecute(jQuery('#editExecute').val());
				if(document.getElementById('phaseVisible').checked) editPhase.setVisible(1);
				else editPhase.setVisible(0);
				editPhase.setRulesVisibleTo(rulesVisibleTo);
				jQuery("#modalWindow").dialog('close');
				editPhase = null;
			}
			else
			{
				jQuery('#editPhaseMsg').html(resp);
			}
		},
		error : function(resp) {
			alert(resp.value);
			alert("Some error while communication with server. Try again or contact administrator");
		}				
	});
};
draw2d.GizmoFigure.prototype.onDragend=function()
{ 	
	var any = draw2d.Node.prototype.onDragend.call(this);

	if(this.outputPort.workflow instanceof draw2d.GizmoWorkflow)
	{
		if(this.outputPort.workflow.callAjax == false) return;

		if(this.isIntraProcess)
		{
			var data = "isExternalPhase=1&process="+this.loadedProcess+"&phase="+this.figName+"&topLeftX="+this.x+"&topLeftY="+this.y+"&targetProcess="+this.process;
		}
		else
		{
			var data = "process="+this.process+"&phase="+this.figName+"&topLeftX="+this.x+"&topLeftY="+this.y;	
		}
		jQuery.ajax({
			url: 'updateCoordinates.jsp',
			type: 'POST',
			data: data,
			success: function(resp) {
				resp = jQuery.trim(resp);
				if (resp.indexOf("ERROR") > -1)
				{
					alert("Some problem occured while saving coordinates of this object");
				}
			}
		});			
	}
}	

