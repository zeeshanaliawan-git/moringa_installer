 
	document.body.addEventListener("mouseover", function(e) {	
		var targ;
		if (!e) var e = window.event;
		if (e.target) targ = e.target;
		else if (e.srcElement) targ = e.srcElement;
//		if(targ.tagName == 'DIV')
//		{
			e.stopPropagation();
			e.target.addEventListener("mouseout", function (e) {
				e.target.className = e.target.className.replace(new RegExp(" dataExtract_highlight\\b", "g"), "");
			});
			e.target.className += " dataExtract_highlight";
//		}
	});   

	
	