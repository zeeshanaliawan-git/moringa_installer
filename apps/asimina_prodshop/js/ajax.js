Ajax = {	
	getHTTPObject : function() {
		var http = false;
		if(typeof ActiveXObject != 'undefined') {
			try {http = new ActiveXObject("Msxml2.XMLHTTP");}
			catch (e) {
				try {http = new ActiveXObject("Microsoft.XMLHTTP");}
				catch (E) {http = false;}
			}
		} else if (window.XMLHttpRequest) {
			try {http = new XMLHttpRequest();}
			catch (e) {http = false;}
		}

		return http;
	},
	makeGetRequest : function (url,onSuccessCallback,onFailureCallback) {
		var http = this.init(); 
		if(!http||!url) return;
		if (http.overrideMimeType) http.overrideMimeType('text/xml');

		var now = "uid=" + new Date().getTime();
		url += (url.indexOf("?")+1) ? "&" : "?";
		url += now;

		http.open("GET", url, true);		
		http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      		http.setRequestHeader("Connection", "close");	

		http.onreadystatechange = function () {
			if (http.readyState == 4) {
				if(http.status == 200) {
					var result = "";
					if(http.responseText) result = http.responseText;				
					
					if(onSuccessCallback) onSuccessCallback(result);
				} else {
					if(onFailureCallback) onFailureCallback(result); 
					else alert("Oops!!! Some error occurred while communicating with server. Error : " + http.status + " Response : " + http.responseText);
				}
			}
		}
		http.send(null);
	},
	makePostRequest : function (calledAction, formId, onSuccessCallback, onFailureCallback) {
		var http = this.init(); 
		if(!http||!calledAction) return;
		if (http.overrideMimeType) http.overrideMimeType('text/xml');

		var now = "uid=" + new Date().getTime();
		calledAction += (calledAction.indexOf("?")+1) ? "&" : "?";
		calledAction += now;

		parameters = this.getFormParameters(formId);

		http.open("POST", calledAction + "&" + parameters, true);	
		http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      		http.setRequestHeader("Connection", "close");	

		http.onreadystatechange = function () {
			if (http.readyState == 4) {
				if(http.status == 200) {
					var result = "";
					if(http.responseText) result = http.responseText;
					
					if(onSuccessCallback) onSuccessCallback(result);
				} else {
					if(onFailureCallback) onFailureCallback(result); 
					else alert("Oops!!! Some error occurred while communicating with server. Error : " + http.status + " Response : " + http.responseText);
				}
			}
		}
		http.send(null);
	},
	init : function() {return this.getHTTPObject();},
	getFormParameters : function(formId) {
		queryString="";
		var frm = document.getElementById(formId);
		var numberElements = frm.elements.length;
		for(var i = 0; i < numberElements; i++) 
		{
			if(frm.elements[i].length === undefined)
			{
				queryString += frm.elements[i].name+"="+
				encodeURIComponent(frm.elements[i].value)+"&";
			}
			else
			{
				for(j=0; j<frm.elements[i].length; j++)
				{
					if(frm.elements[i][j].selected)
					{
						queryString += frm.elements[i].name+"="+
						encodeURIComponent(frm.elements[i][j].value)+"&";
					}
				}
			}
		}//for
		if(queryString.length > 0)
			queryString = queryString.substring(0,queryString.length-1);
		return queryString; 
	}	
}