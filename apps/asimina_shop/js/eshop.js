function show( z)
{

 var s = "" ;

  w = open("about:blank","aide",
      'height=360,width=400,top=100,left=140,scrollbars=yes,resizable');
  w.document.open();

  for( var i in z )
      { s = "";
        c = ("" + i).charAt(0);
        if(c < '0' || c > '9' )
            s += " <font color=blue>" + i  + "</font>->" + eval( "z." +i) ;
        else
            s += " " + i + "-> void ptr ";
        s += "<br>";
        w.document.write(s);
      }

 w.document.close();

 return(false);
}

function xmlPost( url , xml , fct,obj)
{
//  var a1 = document.getElementById("action_"+appli);
//  a1.src="img2/action2.gif";
//prompt(url+"===="+xml,url+"===="+xml)	
	var xq = null;

 if(window.XMLHttpRequest)
  xq = new XMLHttpRequest();
 else if(window.ActiveXObject)
  xq = new ActiveXObject("Msxml2.XMLHTTP");
 else xq = new ActiveXObject("Microsoft.XMLHTTP");

 if( xq == null ) return;
 
 xq.open( "POST" , url , true);

  xq.onreadystatechange = function() {
  if(xq.readyState == 4){
	if( xq.status==200){
		fct( xq.responseText,obj);
	}else{
//	a.src="img2/action2.gif";
//	a.title = msg_w + appli;
		alert(xq.responseText,obj)
	}
   }
  }
 xq.setRequestHeader("Content-type", "application/x-www-form-urlencoded; charset=UTF8");
 xq.send(xml);
}