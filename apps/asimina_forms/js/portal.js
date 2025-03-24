function menuClick(n1, n, url)
{
	document.cookie = "menuitemtype="+n1+"; path=/";
	document.cookie = "menuitemclicked="+n+"; path=/";
	window.location = url;
}

function parseUrlForAjax(_url) 
{
	if(typeof _url != 'string') return _url;

	_url = getUrl(_url);
	if(_url.indexOf(______portalurl + 'process.jsp') > -1) 
	{
		if(_url.indexOf("?") > -1) _url = _url + "&___noscript=1";
		else _url = _url + "?___noscript=1";
		return _url;
	}	
	_url = ______portalurl + 'process.jsp?___mid='+______mid+'&___isajax=1&___noscript=1&___mainurl='+Base64.encode(______currenturl)+'&___goto='+Base64.encode(_url);
	return _url;
}

function parseUrl(_url) 
{
	if(typeof _url != 'string') return _url;
	_url = getUrl(_url);
	if(_url.indexOf(______portalurl + 'process.jsp') > -1) return _url;

	_url = ______portalurl + 'process.jsp?___mid='+______mid+'&___mainurl='+Base64.encode(______currenturl)+'&___goto='+Base64.encode(_url);
	return _url;
}

function hookforms()
{
	Array.prototype.forEach.call(document.querySelectorAll("form"), function(form) {
		var realSubmit = form.submit;
		form.submit = function() {
			form.action = parseUrl(form.action);
			realSubmit.call(form);
		};
	});
}

//for some case the form action was included http://backdown:8080 in url and then appending the external
//website link to it which is a problem. So we check if our link consists our domain we remove that part
//and return the remaining relative url of original website
function getUrl(_url) 
{
	var ourhost = window.location.host;
	if(_url.indexOf(ourhost) > -1) 
	{
		_url = _url.substring(_url.indexOf(ourhost) + ourhost.length);
	}
	return _url;
}

