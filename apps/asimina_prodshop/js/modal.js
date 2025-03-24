ModalControl = function(modalWindowId)
{
	modalWindowOverlay = document.getElementById(modalWindowId);
	that = this;
}

ModalControl.prototype.closeModalWindow = function () 
{  		
	modalWindowOverlay.style.visibility = "hidden";
	modalWindowOverlay.innerHTML = "";//THIS NEED TO BE DONE OTHERWISE IDs FOR DIFFERENT ELEMENTS HAVE CONFLICT IN POPUP SCREEN
}

//overwrite this function in case you need to do some action on close button
ModalControl.prototype.closeCallback = function () { }

ModalControl.prototype.showMaxModalWindow = function (innerHtml)
{
	var actualHeight = document.body.clientHeight;
	var actualWidth  = document.body.clientWidth;
	
	that.showModalWindow(innerHtml, actualWidth - 20, actualHeight - 20);
}

ModalControl.prototype.showModalWindow = function (innerHtml, width, height)
{
	var actualHeight = document.body.scrollHeight;
	var actualWidth  = document.body.scrollWidth;

	var leftVal = 0;
	var topVal  = 0;

	if(height < document.body.clientHeight)
		topVal = (document.body.clientHeight - height)/2;

	if(width < document.body.clientWidth)
		leftVal = (document.body.clientWidth - width)/2;	

	topVal = topVal + document.body.scrollTop;
	leftVal = leftVal + document.body.scrollLeft;	

	contentsWidth = width-10;//some bug in IE ... it makes contents div wider than topbar div

	var containerStyle = "height:" + height + "px; width:" + width + "px; left:" + leftVal + "px; top:" + topVal + "px;";
	modalWindowOverlay.innerHTML  = "<div class='modalBackground'  style='height:"+actualHeight+"px; width:"+actualWidth+"px;'></div>" + 
					"<IFRAME class='modalFrame' frameBorder='0'  scrolling='no' ></IFRAME>"+					
					"<div class='modalContainer' style='"+containerStyle+"'>" +
					"<div class='modalTopbar' style='width:"+width+"px;'><a href='javascript:that.closeModalWindow();that.closeCallback();' style='text-decoration:none; color:black; font-size:9px'>(X)</a>&nbsp;&nbsp;</div>" +
					"<div class='contents' style='height:"+height+";width:"+contentsWidth+"px;'>"+innerHtml+"</div>" +					
					"</div>";
	modalWindowOverlay.style.visibility = "visible";
}