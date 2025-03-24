function numbersonly( event )
{
    // Allow: backspace, delete, tab, escape, and enter
    if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 || 
 	  // Allow: Ctrl+A
        (event.keyCode == 65 && event.ctrlKey === true) || 
         // Allow: home, end, left, right
        (event.keyCode >= 35 && event.keyCode <= 39)) {
    	      // let it happen, don't do anything
             return;
    }
    else {
       	 // Ensure that it is a number and stop the keypress
//	        if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {		
	        if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
	            event.preventDefault(); 
	        }   
    }

}//end function    

function isnumeric(val)
{
	if(val.match((/[^0-9]/g))) return false;
	else return true;
}

function isvaluedouble(val)
{
//	alert(val);
	if(val.match((/[^0-9\.]/g))) return false;
	else 
	{
		return !isNaN(parseFloat(val)) && isFinite(val);
	}
}

function isdoubleonly(obj)
{
	obj.value = obj.value.replace(/[\,]/g,'.');
	var val = obj.value;
	return isvaluedouble(val);
//	alert(val);
//	if(val.match((/[^0-9\.]/g))) return false;
//	else 
//	{
//		return !isNaN(parseFloat(val)) && isFinite(val);
//	}
}

function isSignedDoubleonly(obj)
{
	obj.value = obj.value.replace(/[\,]/g,'.');
	var val = obj.value;
//	alert(val);
	if(val.match((/[^(\-)?0-9\.]/g))) return false;
	else 
	{
		return !isNaN(parseFloat(val)) && isFinite(val);
	}
}

function isalphanumeric(val)
{
	if(val.match((/[^0-9\A-Z\a-z]/g))) return false;
	else return true;
}


function alphanumeric( event )
{
    // Allow: backspace, delete, tab, escape, and enter
    if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 || 
 	  // Allow: Ctrl+A
        (event.keyCode == 65 && event.ctrlKey === true) || 
         // Allow: home, end, left, right
        (event.keyCode >= 35 && event.keyCode <= 39)) {
    	      // let it happen, don't do anything
             return;
    }
    else {
       	 // Ensure that it is a number and stop the keypress
		 if(event.shiftKey && (event.keyCode >= 65 && event.keyCode <= 90)) return;
		 if(event.keyCode >= 65 && event.keyCode <= 90) return;
	        if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
	            event.preventDefault(); 
	        }   
    }

}//end function    


function parseXML(xmlString)
{
	if (window.DOMParser)
	{
		parser=new DOMParser();
		xmlDoc=parser.parseFromString(xmlString,"text/xml");
	}
	else // Internet Explorer
	{
		xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
		xmlDoc.async="false";
		xmlDoc.loadXML(xmlString); 
	} 
	return xmlDoc.documentElement;
}

function getNodeValue (node)
{
	if(typeof node.textContent != 'undefined') return node.textContent;
	if(typeof node.text != 'undefined') return node.text;
	if(typeof node.innerText != 'undefined') return node.innerText;
}



function telNumber( e )
{
  var unicode = e.charCode ? e.charCode : e.keyCode;

  //if the key isn't the backspace key (which we should allow)
  if( unicode != 8  && unicode != 9)
  { 
    //. space and -
    if(unicode == 46 || unicode == 32 || unicode == 45)
    {
	return true;
    }
    if( unicode < 48 || unicode > 57 )
    {
      //disable key press
      return false;
    }//end if
    else
    {
      // enable keypress
      return true;
    }//end else
  }//end if
  else
  {
    // enable keypress
    return true;
  }//end else
}//end function    



function checkValidTelNumber(obj)
{
	var phoneRE = /^[0]\d-\d\d-\d\d-\d\d-\d\d$|^[0]\d.\d\d.\d\d.\d\d.\d\d$|^[0]\d \d\d \d\d \d\d \d\d$|^[0]\d\d\d\d\d\d\d\d\d$/; 
	if(obj.value.match(phoneRE)) return true;
	else return false;
}

function checkValidMobileNumber(obj)
{
	var phoneRE = /^[0][6]|[0][7]-\d\d-\d\d-\d\d-\d\d$|^[0][6]|[0][7].\d\d.\d\d.\d\d.\d\d$|^[0][6]|[0][7] \d\d \d\d \d\d \d\d$|^[0][6]|[0][7]\d\d\d\d\d\d\d\d$/; 
	if(obj.value.match(phoneRE)) return true;
	else return false;
}

function checkValidEmail(obj)
{
        var emailRegExp = new RegExp('^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]{2,}[.][a-zA-Z]{2,3}$');
	if(obj.value.match(emailRegExp)) return true;
	else return false;
}  

function nospaceallowed( event )
{
	if(event.keyCode == 32) event.preventDefault();
	return true;
}

function doubleonly( event )
{
    // Allow: backspace, delete, tab, escape, and enter
    if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 || 
 	  // Allow: Ctrl+A
        (event.keyCode == 65 && event.ctrlKey === true) || 
         // Allow: home, end, left, right
        (event.keyCode >= 35 && event.keyCode <= 39)) {
    	      // let it happen, don't do anything
             return;
    }
    else if(event.keyCode == 190 || event.keyCode == 110) {
        var targ;
        if (event.target) targ = event.target;
	else if (event.srcElement) targ = event.srcElement;
	if(targ.value.indexOf(".") > -1) event.preventDefault(); 
    }
    else {
       	 // Ensure that it is a number and stop the keypress
//	        if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
	        if ((event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
	            event.preventDefault(); 
	        }   
    }

}//end function   

function goToUrl(url)
{
	if(url.indexOf('http://') == 0 || url.indexOf('https://') == 0)
	{
		window.open(url);
	}
	else
	{
		window.open('http://' + url);
	}
} 


function checkPostalCode(event)
{
    // Allow: backspace, delete, tab, escape, and enter
    if ( event.keyCode == 46 || event.keyCode == 8 || event.keyCode == 9 || event.keyCode == 27 || event.keyCode == 13 || 
 	  // Allow: Ctrl+A
        (event.keyCode == 65 && event.ctrlKey === true) || 
         // Allow: home, end, left, right
        (event.keyCode >= 35 && event.keyCode <= 39)) {
    	      // let it happen, don't do anything
             return;
    }
    else {
       	 // Ensure that it is a number and stop the keypress
	        if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
	            event.preventDefault(); 
	        }   
    }
}


function getVatAmount(totalAmount, vatPerc)
{
	if(totalAmount == '' || vatPerc == '') return 0;
	totalAmount = parseFloat(totalAmount);
	vatPerc = parseFloat(vatPerc);
	return (totalAmount - (totalAmount / (1+ (vatPerc/100)))).toFixed(2);
}

function amountWithoutVat(totalAmount, vatAmnt)
{
	if(totalAmount == '' || vatAmnt == '') return 0;
	totalAmount = parseFloat(totalAmount);
	vatAmnt = parseFloat(vatAmnt);
	return (totalAmount - vatAmnt).toFixed(2);
}


function formatAmount(inAmnt)
{	
	if(!inAmnt) inAmnt = "";
        inAmnt = "" + inAmnt;
	if(inAmnt.indexOf(".") < 0) inAmnt += ".00";
	var b = inAmnt.substring(inAmnt.indexOf(".") + 1);
	if(b.length == 1) inAmnt += "0";
	
	inAmnt = inAmnt.replace(".",",");
	return inAmnt;
}
