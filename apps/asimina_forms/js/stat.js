jQuery(window).bind('load', function() {
	//alert("ici");
	//alert(document.referrer);
	//show( window.screen  );
	//alert("d:"+tm12345);
	jQuery.ajax({
		type: "POST",
		url: ______portalurl + "stat.jsp",
		data : {a:1,screen_width:window.screen.width,screen_height:window.screen.height,mid:______menuid,ourl:______currentcompleteurl,l_href:location.href,ref:document.referrer},
		
		dataType: "html",
		success: function(html){       
			//alert(html)
		
			
			},
			error:function (xhr, ajaxOptions, thrownError){ 
				alert("affMob\n"+xhr.responseText);
            }     
		  }); 		
	
	
	 
	
	});