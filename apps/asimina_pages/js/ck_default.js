if(typeof ckd === "undefined"){

	var ckd = {
	};

	//constants / literals
	ckd.DYNAMIC_CONTENT_CLASS = 'dynamic-content';
	ckd.ATTRIBUTE_FILES_URL = 'data-files-url';
	ckd.ATTRIBUTE_ID = 'data-id';
	ckd.ATTRIBUTE_PROCESSED = 'data-processed';

	ckd.DYNAMIC_ES_FILES = 'expertsystemcomponent';
	ckd.ATTRIBUTE_ES_FILES_URL = 'data-es-files-url';
	ckd.ATTRIBUTE_ES_DATA_JSON_ID = 'data-jsonid';
	ckd.ATTRIBUTE_ES_FETCH_DATA_URL = 'fetch-data-es-url';

	//for IE
	var forEach = function(ctn, callback){
	    return Array.prototype.forEach.call(ctn, callback);
	}

	ckd.init = function(){
		ckd.nodeList = null;

		ckd.filesUrlMap = [];

		ckd.cssFileUrls = [];
		ckd.cssChildrenFileUrls = [];

		ckd.jsChildrenFileUrls = [];
		ckd.jsFileUrls = [];

	};

	ckd.initEs = function(){
		ckd.esNodeList = null;

		ckd.esFilesUrlMap = [];

		ckd.esCssFileUrls = [];
		//ckd.esCssChildrenFileUrls = [];

		ckd.esJsChildrenFileUrls = [];
		ckd.esJsFileUrls = [];
	};

	ckd.loadExpertSystemResourceFiles = function(){

		ckd.initEs();
		ckd.esNodeList = document.querySelectorAll("."+ckd.DYNAMIC_ES_FILES);

		var count = ckd.esNodeList.length;
		var jsonsbFUnction = "";
		var jsonFunction = "";
		var esJsonId = "";

		var onEsComplete = function(){

			if((count=count-1) <= 0){
				ckd.esProcessCssFiles();
				ckd.esProcessJsFiles();
			}
		};

		forEach(ckd.esNodeList, function(ele){

			var esFilesUrl = ckd.getEsAttributeValue(ele, ckd.ATTRIBUTE_ES_FILES_URL);
			var anyParams = "0";
			ckd.esFilesUrlMap[esFilesUrl] = {
				callback : ""
			};

			if(esFilesUrl.length == 0){

				onEsComplete();
			}else{

				ckd.ajax({
					url : esFilesUrl,
					method : "POST",
					data : {
						jsonId : ckd.getEsAttributeValue(ele, ckd.ATTRIBUTE_ES_DATA_JSON_ID)
					},
					onSuccess : function(resp){

						try{
							var json = JSON.parse(resp);
							jsonFunction = json["es_function"];
							jsonsbFUnction = json["es_sb_function"];
							anyParams = json["anyParams"];
							esJsonId = ckd.getEsAttributeValue(ele, ckd.ATTRIBUTE_ES_DATA_JSON_ID);

							ckd.esProcessFilesUrlResponse(json);

							ckd.esFilesUrlMap[esFilesUrl].callback = json["callback"];

						}
						catch(e){
							console.log("error:"+e);
						}

					},
					onFail : function(){
						//debug
						console.log("Error in fetching files list : " + esFilesUrl);
					},
					onComplete : function(){
						//debug
						onEsComplete();

						var isJQueryLoaded = setInterval(function(){

							if(window.$ != undefined){

								var _esSBtnFunction = Function(jsonsbFUnction);
								_esSBtnFunction();
								if(anyParams == "0")
									ckd.fetchData(ckd.getEsAttributeValue(ele, ckd.ATTRIBUTE_ES_FETCH_DATA_URL), ckd.getEsAttributeValue(ele, ckd.ATTRIBUTE_ES_DATA_JSON_ID), "");

								clearInterval(isJQueryLoaded);
							}
						}, 1000);

//						var _esSBtnFunction = Function(jsonsbFUnction);
//						_esSBtnFunction();


					}
				});
			}
			return;
		});
		ckd.fetchData = function(url, jsonuuid, _data)
		{
			var isPreview = "";

			if(ckd.getURLParameter("is_preview") != undefined) isPreview = ckd.getURLParameter("is_preview");

			if(_data == '') _data = "jsonId=" + jsonuuid + "&is_preview=" + isPreview;
			ckd.ajax({
				url : url,
				method : "POST",
				data : _data,
				onSuccess : function(json){

					var _applyExpertSystemRules = Function("_json","jsonid", jsonFunction);
					_applyExpertSystemRules(JSON.parse(json), esJsonId);
				}
			});
		};
	}

	ckd.getEsAttributeValue = function(ele, attributeId){

		return ele.getAttribute(attributeId);
	};

	ckd.getURLParameter = function(sParam){

	    var sPageURL = window.location.search.substring(1);
	    var sURLVariables = sPageURL.split('&');

	    for (var i = 0; i < sURLVariables.length; i++) {

	    	var sParameterName = sURLVariables[i].split('=');
        	if (sParameterName[0] == sParam) return sParameterName[1];
	    }
	};

	ckd.loadDynamicContent = function(){

		//ckd.jsFileUrls = [];
		ckd.init();

		ckd.nodeList = document.querySelectorAll('.'+ckd.DYNAMIC_CONTENT_CLASS);


		var count = ckd.nodeList.length;

		var onComplete = function(){
			//when all node urls are processed
			//then process the js files
			if( (count=count-1)  <= 0){
				ckd.processCssFiles();
				ckd.processJsFiles();
			}
		};

		forEach(ckd.nodeList, function(ele){

			var processed = ele.getAttribute(ckd.ATTRIBUTE_PROCESSED);
			if(processed != null){
				//already processed , skip it
				return;
			}

			ele.setAttribute(ckd.ATTRIBUTE_PROCESSED,'1');
			ele.className = ele.className + " " + ckd.ATTRIBUTE_PROCESSED;


			var filesUrl = ele.getAttribute(ckd.ATTRIBUTE_FILES_URL);
			ckd.filesUrlMap[filesUrl] = {
				callback : ""
			};

			if(filesUrl.length == 0){
				onComplete();
			}
			else{

				ckd.ajax({
					url : filesUrl,
					method : "POST",
					data : null,
					onSuccess : function(resp){
						try{
							var json = JSON.parse(resp);
							ckd.processFilesUrlResponse(json);

							ckd.filesUrlMap[filesUrl].callback = json["callback"];
						}
						catch(e){
							console.log("error:"+e);
						}

					},
					onFail : function(){
						//debug
						console.log("Error in fetching files list : " + filesUrl);
					},
					onComplete : function(){
						//debug
						// console.log('files list fetch complete :' + filesUrl);
						onComplete();
					}
				});
			}


		});

	};

	ckd.processFilesUrlResponse = function(json){
		var head = document.getElementsByTagName('head')[0];
		try{
			//process css files
			if( typeof json["css"] != "undefined"){
				json["css"].forEach( function(fileUrl){
					//add all js files to a global list
					//load later with callback

					ckd.cssFileUrls.push(fileUrl["path"]);

					fileUrl["children"].forEach(function(childrenFileUrl){
						ckd.cssChildrenFileUrls.push(childrenFileUrl["path"]);
					});

					if(fileUrl["children"].length > 0)
						ckd.cssFileUrls.push(ckd.cssChildrenFileUrls);

				});
			}
			//process js files
			if( typeof json["js"] != "undefined"){

				json["js"].forEach( function(fileUrl){
					//add all js files to a global list
					//load later with callback

					ckd.jsFileUrls.push(fileUrl["path"]);

					fileUrl["children"].forEach(function(childrenFileUrl){
						ckd.jsChildrenFileUrls.push(childrenFileUrl["path"]);
					});

					if(fileUrl["children"].length > 0)
						ckd.jsFileUrls.push(ckd.jsChildrenFileUrls);
				});
			}
		}
		catch(e1){}
	};

	ckd.processCssFiles = function(){

		ckd.cssFileUrls = ckd.removeArrayDuplicates(ckd.cssFileUrls);

		var head = document.getElementsByTagName("head")[0];

		ckd.cssFileUrls.forEach(function(url){

			if(Array.isArray(url)){

				setTimeout(function(){

					url.forEach(function(childrenUrl){

						var link = document.createElement('link');
						link.setAttribute('rel','stylesheet');
						link.setAttribute('href',childrenUrl);
						head.appendChild(link);
					});
				}, 500);
			}else{

				var link = document.createElement('link');
				link.setAttribute('rel','stylesheet');
				link.setAttribute('href',url);
				head.appendChild(link);
			}
		});
	};

	ckd.processJsFiles = function(){

		ckd.jsFileUrls = ckd.removeArrayDuplicates(ckd.jsFileUrls);

		var count = null;

		var onLoad = function(){

			if( (count = count-1) <= 0){

				ckd.processNodeListCallbacks();
			}
		};

		if(count == 0){
			onLoad();
		}
		else{
			ckd.jsFileUrls.forEach(function(url){

				if(Array.isArray(url)){
					count += url.length;
					setTimeout(function(){

						url.forEach(function(childrenUrl){
							ckd.getScript(childrenUrl, onLoad);
						});

					}, 500);
				}else{
					count = 1;
					ckd.getScript(url, onLoad);
				}

			});
		}


	};

	ckd.processNodeListCallbacks = function(){
		forEach(ckd.nodeList, function(ele){
			var processed = ele.getAttribute(ckd.ATTRIBUTE_PROCESSED);
			if(processed == null){
				//skip as it was not processed
				return;
			}

			var filesUrl = ele.getAttribute(ckd.ATTRIBUTE_FILES_URL);
			var callback = ckd.filesUrlMap[filesUrl].callback;

			if(typeof callback == 'string' && callback.length > 0){
				var callbackFunc = eval(callback);
				//empty the div
				ele.innerHTML = "";
				callbackFunc(ele);
			}
		});
	};

	ckd.esProcessFilesUrlResponse = function(json){
		var head = document.getElementsByTagName('head')[0];

		try{
			//process css files
			if( typeof json["css"] != "undefined"){

				json["css"].forEach( function(fileUrl){
					//add all js files to a global list
					//load later with callback

					ckd.esCssFileUrls.push(fileUrl["path"]);

/*					fileUrl["children"].forEach(function(childrenFileUrl){
						ckd.esCssChildrenFileUrls.push(childrenFileUrl["path"]);
					});
					if(fileUrl["children"].length > 0)
						ckd.esCssFileUrls.push(ckd.esCssChildrenFileUrls);
*/
				});
			}
			//process js files
			if( typeof json["js"] != "undefined"){

				json["js"].forEach( function(fileUrl){
					//add all js files to a global list
					//load later with callback

					ckd.esJsFileUrls.push(fileUrl["path"]);

					if(fileUrl["children"] != undefined){

						fileUrl["children"].forEach(function(childrenFileUrl){
							ckd.esJsChildrenFileUrls.push(childrenFileUrl["path"]);
						});

						if(fileUrl["children"].length > 0){
							ckd.esJsFileUrls.push(ckd.esJsChildrenFileUrls);
						}
					}

				});
			}
		}
		catch(e1){}
	};

	ckd.esProcessCssFiles = function(){

		ckd.esCssFileUrls = ckd.removeArrayDuplicates(ckd.esCssFileUrls);

		var head = document.getElementsByTagName("head")[0];

		ckd.esCssFileUrls.forEach(function(url){

/*			if(Array.isArray(url)){

				setTimeout(function(){

					url.forEach(function(childrenUrl){

						var link = document.createElement('link');
						link.setAttribute('rel','stylesheet');
						link.setAttribute('href',childrenUrl);
						head.appendChild(link);
					});
				}, 500);
			}else{
*/
				var link = document.createElement('link');
				link.setAttribute('rel','stylesheet');
				link.setAttribute('href',url);
//				link.async = false;
				head.appendChild(link);
//			}
		});
	};

	ckd.esProcessJsFiles = function(){

		ckd.esJsFileUrls = ckd.removeArrayDuplicates(ckd.esJsFileUrls);

		var count = null;

		var onLoad = function(){

			if( (count = count-1) <= 0){

				ckd.esProcessNodeListCallbacks();
			}
		};

		if(count == 0){
			onLoad();
		}
		else{
			ckd.esJsFileUrls.forEach(function(url){

				if(Array.isArray(url)){
					count += url.length;
					setTimeout(function(){

						url.forEach(function(childrenUrl){
							ckd.getScript(childrenUrl, onLoad);
						});

					}, 500);
				}else{
					count = 1;

					ckd.getScript(url, onLoad);
				}

			});
		}


	};

	ckd.esProcessNodeListCallbacks = function(){
		forEach(ckd.esNodeList, function(ele){

			var filesUrl = ckd.getEsAttributeValue(ele, ckd.ATTRIBUTE_ES_FILES_URL);
			var callback = ckd.esFilesUrlMap[filesUrl].callback;

			if(typeof callback == 'string' && callback.length > 0){
				var callbackFunc = eval(callback);
				//empty the div
				ele.innerHTML = "";
				callbackFunc(ele);
			}
		});
	};

	ckd.dummyCallback = function(div){
		//debug
		console.log('dynamic callback ' + div.getAttribute(ckd.ATTRIBUTE_ID));
		ckd.ajax({
			url : '/dev_ckeditor/pages/dummyTestPage.jsp?type=getDashletContent',
			method : "GET",
			data : null,
			onSuccess : function(resp){
				div.innerHTML = resp;
			}
		});
	}

	//--- utility functions ---

	ckd.removeArrayDuplicates = function(arr){

		var map = {};
		var retArr = [];
		arr.forEach(function(value){

			if(Array.isArray(value)){
				var inRetArr = [];
				value.forEach(function(childrenValue){

					if(typeof map[childrenValue] == 'undefined'){
						inRetArr.push(childrenValue);
						map[childrenValue] = true;
					}

				});
				retArr.push(inRetArr);
			}else{
				if(typeof map[value] == 'undefined'){
					retArr.push(value);
					map[value] = true;
				}
			}

		});

		return retArr;
	};

	//native add script with onload callback
	// src : https://gist.github.com/tmilewski/896561

	ckd.getScript = function(url, callback) {

		var head	= document.getElementsByTagName("head")[0];
		var script	= document.createElement("script");
		var done 	= false; // Handle Script loading

		script.onload = script.onreadystatechange = script.onerror = function() { // Attach handlers for all browsers

			if ( !done && (!this.readyState || this.readyState === "loaded" || this.readyState === "complete") ) {
				done = true;
				if (callback) { callback(); }
				script.onload = script.onreadystatechange = null; // Handle memory leak in IE

				//debug
				console.log('js file loaded readystate :'+this.readyState+' :' + script.src);
			}
		};
		script.src	= url;
//		script.async = false;

		head.appendChild(script);
		return undefined; // We handle everything using the script element injection
	};


	//jQuery-like ajax function , using native JS only
	ckd.ajax = function(obj){

		 //obj = {url,method,data,onSuccess,onFail,onComplete};
		var xhr = new XMLHttpRequest();
		if (!xhr) {
			console.log('Cannot create an XMLHTTP instance');
			return false;
		}

		xhr.onreadystatechange = function(){
			if (xhr.readyState === XMLHttpRequest.DONE){

				if (xhr.status === 200) {

			       if(typeof obj.onSuccess === "function"){
			       		obj.onSuccess(xhr.responseText);
			       }
		     	}
		     	else{

			       if(typeof obj.onFail === "function"){
			       		obj.onFail(xhr.responseText, xhr.status);
			       }
			    }

			    if(typeof obj.onComplete === "function"){
		       		obj.onComplete(xhr.responseText, xhr.status);
		       	}
		    }
		};


		if(obj.method !== undefined) obj.method = obj.method.toUpperCase();
		if(obj.method !== "POST"){
			obj.method == "GET";
		}

		xhr.open(obj.method,obj.url);

		if(obj.method === "POST"){
			xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			if(typeof obj.data === "string"){
				xhr.send(obj.data);
			}
			else if(typeof obj.data === "object"){
				xhr.send(ckd.makeParamString(obj.data));
			}
			else{
				xhr.send();
			}

		}
		else{
			xhr.send();
		}
	};

	ckd.makeParamString = function(dataObj){
		var encodedString = '';
	    for (var prop in dataObj) {
	        if (dataObj.hasOwnProperty(prop)) {
	            if (encodedString.length > 0) {
	                encodedString += '&';
	            }
	            encodedString += prop + '=' + encodeURIComponent(dataObj[prop]);
	        }
	    }
	    return encodedString;
	};

	// simple native js copied from jQuery code for document.ready() function
	// https://github.com/jquery/jquery/blob/master/src/core/ready.js
	ckd.readyList = [];
	ckd.onDomReady = function(fn){

		if(typeof fn != "function"){
			return;
		}

		ckd.readyList.push(fn);

		// The ready event handler and self cleanup method
		function completed() {
			//debug
			// console.log('** onDomReady:completed called');

			//debug
			//document.removeEventListener( "DOMContentLoaded", completed );
			//window.removeEventListener( "load", completed );

			ckd.readyList.forEach(function(listFn){
				listFn.call();
			});
			ckd.readyList = [];
		}

		// Catch cases where $(document).ready() is called
		// after the browser event has already occurred.
		// Support: IE <=9 - 10 only
		// Older IE sometimes signals "interactive" too soon
		if ( document.readyState === "complete" ||
			( document.readyState !== "loading" && !document.documentElement.doScroll ) ) {

			// Handle it asynchronously to allow scripts the opportunity to delay ready
			window.setTimeout( completed );

		} else {

			// Use the handy event callback
			document.addEventListener( "DOMContentLoaded", completed );

			// A fallback to window.onload, that will always work
			window.addEventListener( "load", completed );
		}
	}


	//call load dynamic content on domReady
	ckd.onDomReady(function(){
		ckd.loadDynamicContent();
		ckd.loadExpertSystemResourceFiles();
	});
}

