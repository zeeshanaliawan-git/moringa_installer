function clearJsonValues(json)
{
//	alert(json);
	for(var key in json)
	{
		var _type = Object.prototype.toString.call(json[key]);

		if ( _type === '[object Array]') 
		{
			//special tabular data case in which column names are sent in cols attribute so we want them later so not clearing those
			if(key != 'cols') clearChilds(json[key]);
		}
		else if ( _type === '[object Object]') 
		{
			clearChilds(json[key]);
		}
		else 
		{
			json[key] = '';
		}
	}
	return json;
}

function clearChilds(json)
{
	for(var key in json)
	{
		var _type = Object.prototype.toString.call(json[key]);

		if ( _type === '[object Array]') 
		{
			//special tabular data case in which column names are sent in cols attribute so we want them later so not clearing those
			if(key != 'cols') clearChilds(json[key]);
		}
		else if ( _type === '[object Object]') 
		{
			clearChilds(json[key]);
		}
		else 
		{
			json[key] = '';
		}
	}	
}
