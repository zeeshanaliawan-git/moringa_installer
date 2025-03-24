___portaljquery(window).bind('load', function() {
	___portaljquery("#etn_btn_faq_yes").on('click touch', function () {
		___portaljquery.ajax({
			type: "POST",
			url: ______portalurl + "faqstat.jsp",
			data : {document_title:document.title,ourl:______dcurl,l_href:location.href, ref:document.referrer,muid:______muid, coption : 'yes' },			
			dataType: "html",
			success: function(html){       
			},
			error:function (xhr, ajaxOptions, thrownError){ 
				console.log("affMob\n"+xhr.responseText);
            		}     
		}); 		
	});

	___portaljquery("#etn_btn_faq_no").on('click touch', function () {
		___portaljquery.ajax({
			type: "POST",
			url: ______portalurl + "faqstat.jsp",
			data : {document_title:document.title,ourl:______dcurl,l_href:location.href, ref:document.referrer,muid:______muid, coption : 'no' },			
			dataType: "html",
			success: function(html){       
			},
			error:function (xhr, ajaxOptions, thrownError){ 
				console.log("affMob\n"+xhr.responseText);
            		}     
		}); 		
	});
	
});


