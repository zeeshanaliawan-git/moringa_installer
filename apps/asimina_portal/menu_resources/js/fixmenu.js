___portaljquery(window).bind('load', function() {
	___portaljquery(".___portalmenulink").each(function(){
		___portaljquery(this).attr("target","_self");
	});	

	var ___urlmatch = ______portalurl2.toLowerCase();
	___portaljquery("a").each(function()
	{
		if(___portaljquery(this).attr('id') != '___portalhomepagelink' && ___portaljquery(this).attr('href') != "#" ) 
		{
			if(this.href.toLowerCase().indexOf("http:") == 0 || this.href.toLowerCase().indexOf("https:") == 0)
			{
				if(this.href.toLowerCase().indexOf("http://"+document.domain+___urlmatch) == 0 || this.href.toLowerCase().indexOf("https://"+document.domain+___urlmatch) == 0)
				{
					if(!___portaljquery(this).hasClass("o_dont_fix_url")) ___portaljquery(this).attr({target: "_self"});
				}
				else ___portaljquery(this).attr({target: "_blank"});
			}
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

	___portaljquery(".o_menu_open_same_window").each(function() 
	{
		___portaljquery(this).attr({target: "_self"});
	});
	
	_portal_opennewwindow=function(_url)
	{
		var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
		prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
		prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight; 
		var _win = window.open(_url,"", prop);
		_win.focus(); 
	};

	___portaljquery(".MenuTop").each(function(){
		___portaljquery(this).attr("data-lf-top-fixed","");
	});

	___portaljquery(".MenuDesktop").each(function(){
		___portaljquery(this).attr("data-lf-top-fixed","");
	});

	___portaljquery(".asimina_sso_link").each(function()
	{
		___portaljquery(this).attr({target: "_blank"});
	});

	if(___portaljquery('.o-page-header .o-orange-ghost-bt').attr('onclick') == 'history.go(-1);' || ___portaljquery('.o-page-header .o-orange-ghost-bt').attr('onclick') == 'history.go(-1)' )
	{
		if(document.referrer.indexOf(document.domain) < 0)
		{
			___portaljquery('.o-page-header .o-orange-ghost-bt').removeAttr('onclick');			
			___portaljquery('.o-page-header .o-orange-ghost-bt').on('click', function(){ __gotoPortalHome(); });			
		}
	}


});