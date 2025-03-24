___portaljquery(document).ready(function() {
	
	___portaljquery(".internalmoringaheadersearchfield").on("keyup", function(e) 
	{

		var unicode = e.charCode ? e.charCode : e.keyCode;
					
		if(unicode == 13) 
		{
       		if(___portaljquery.trim(___portaljquery(this).val()) != '')
			{ 
				window.location = ______portalurl + "search.jsp?muid="+______muid+"&q=" + ___portaljquery(this).val();
			}
		}
	});

});