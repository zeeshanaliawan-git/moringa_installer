var http; // objet XMLHttpRequest

function handleAJAXReturn() {
    if(http.readyState == 4) {
        if(http.status == 200) {
            var ele = document.getElementById("toucanFormDiv");
            if(!ele)
            {
                ele = document.createElement("div");
                ele.id = "toucanFormDiv";
                document.body.appendChild(ele);
                ele.style.visibility = "hidden";
            }
            //ele.target = "_blank";
            ele.innerHTML = http.responseText;
            var toucanFormEle = document.getElementById("toucanForm");
            toucanFormEle.submit();
        } else {
            window.alert("Erreur lors de la redirection vers toucan");
        }
		
    }
}
function loadToucan(contextPath, currentUrl)
{
    http = createRequestObject();
    var params = 'origin='+currentUrl + '&originPage='+currentUrl+'&errorMessage=';
	
    http.open('POST', contextPath+'/toucan.jsp', true);
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    http.setRequestHeader("Content-length", params.length);
    http.setRequestHeader("Connection", "close");
    http.onreadystatechange = handleAJAXReturn;
    http.send(params);
}

function createRequestObject()  {
    var http;
    if(window.XMLHttpRequest) { // Mozilla, Safari, ...
        http = new XMLHttpRequest();
    } else if(window.ActiveXObject) { // Internet Explorer
        http = new ActiveXObject("Microsoft.XMLHTTP");
    }
    return http;
}

function openWindow(url, wname, width, height) 
{
    window.open(url, wname, "height=" + height + ",width=" + width + "location = 0, status = 1, resizable = 0, scrollbars=1, toolbar = 0");
    return true;
}