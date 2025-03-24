___portaljquery(window).bind('load', function() {
	___portaljquery(".___portalmenulink").each(function(){
		___portaljquery(this).attr("target","_self");
	});	

	var ___urlmatch = ______portalurl.toLowerCase();
//	if(___urlmatch.indexOf("https:") > -1 ) ___urlmatch = ___urlmatch.substring(8);
//	else if(___urlmatch.indexOf("http:") > -1 ) ___urlmatch = ___urlmatch.substring(7);

//	alert(___urlmatch);
//	alert("http://"+document.domain+___urlmatch);

	___portaljquery("a").each(function()
	{
//		alert(this.href + " "+ ___urlmatch);
		if(this.href.toLowerCase().indexOf("http:") == 0 || this.href.toLowerCase().indexOf("https:") == 0)
		{
//			if(this.href.toLowerCase().indexOf("http://"+___urlmatch) == 0 || this.href.toLowerCase().indexOf("https://"+___urlmatch) == 0)
			if(this.href.toLowerCase().indexOf("http://"+document.domain+___urlmatch) == 0 || this.href.toLowerCase().indexOf("https://"+document.domain+___urlmatch) == 0)
			{
				if(!___portaljquery(this).hasClass("o_dont_fix_url")) ___portaljquery(this).attr({target: "_self"});
			}
			else ___portaljquery(this).attr({target: "_blank"});
		}
	});

	___portaljquery(".o_menu_open_new_tab").each(function() 
	{
		___portaljquery(this).attr({target: "_blank"});
	});
	
	___portaljquery(".o_menu_open_new_window").each(function()
	{
		//alert(___portaljquery(this).attr('href'));
		___portaljquery(this).attr({target: "_self"});
		var _href = ___portaljquery(this).attr('href');
		___portaljquery(this).attr('href','javascript:_portal_opennewwindow("'+_href+'")');
	});
	
	_portal_opennewwindow=function(_url)
	{
		var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
		prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
		prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight; 
		var _win = window.open(_url,"", prop);
		_win.focus(); 
	};

});