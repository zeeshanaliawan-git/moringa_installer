function IsNumeric(strString)
//  check for valid numeric strings	
{
	var strValidChars = "0123456789.-";
	var strChar;
	var blnResult = true;

	if (strString.length == 0) return false;

	//  test strString consists of valid characters listed above
	for (i = 0; i < strString.length && blnResult == true; i++)
	{
		strChar = strString.charAt(i);
		if (strValidChars.indexOf(strChar) == -1)
		{
			blnResult = false;
		}
	}
	return blnResult;
}

function IsInteger(obj)
//  check for valid numeric strings	
{
	var strValidChars = "0123456789";
	var strChar;
	var blnResult = true;

	if (obj.value.length == 0) return false;

	//  test strString consists of valid characters listed above
	for (i = 0; i < obj.value.length && blnResult == true; i++)
	{
		strChar = obj.value.charAt(i);
		if (strValidChars.indexOf(strChar) == -1)
		{
			blnResult = false;
		}
	}
	if(!blnResult)
	{
		alert("Not a valid numeric value");
		obj.value = '';
		obj.focus();
	}
	return blnResult;
}

function numbersonly( e )
{
  var unicode = e.charCode ? e.charCode : e.keyCode;	
  if(unicode == 37 || unicode == 40 || unicode == 38 || unicode == 39 || unicode == 46 || unicode == 9) return true;
  if(e.ctrlKey && (unicode == 99 || unicode == 120 || unicode == 118)) return true;

  //if the key isn't the backspace key (which we should allow)
  if( unicode != 8 )
  { 
    //if not a number
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

function doubleonly( e, obj )
{
  var unicode = e.charCode ? e.charCode : e.keyCode;
	//alert(unicode);
	//only 1 decimal allowed
  if(unicode == 46 && obj.value.indexOf(".") > -1) return false;
  //if the key isn't the backspace key (which we should allow)
  if( unicode != 8 && unicode != 46 && unicode != 37 && unicode != 39 && unicode != 9 )
  { 
    //if not a number
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
