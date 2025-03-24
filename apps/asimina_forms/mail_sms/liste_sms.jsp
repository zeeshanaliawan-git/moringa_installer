<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> -->

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>

<%!
String parseNull(Object o) {
  if( o == null )
    return("");
  String s = o.toString();
  if("null".equals(s.trim().toLowerCase()))
    return("");
  else
    return(s.trim());
}


%>

<html>
<head>
<title>Guizmo - Manage SMS/Mail</title>
<script src="../js/jquery.min.js" type="text/javascript"></script>
<script src="../js/eshop.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="../css/menu.css">
<link rel="stylesheet" type="text/css" href="../css2/general.css"> 
<script>
function showProcessing(){
	$('#msg').html("<center>Loading, please wait<br><div style='text-align:center;'><img alt='Loading, please wait' src='../img/ajax-loader.gif'/></div></center>");
}
function getF(id){
	showProcessing();
	$.ajax({
		type: "GET",
		url: "<%=request.getContextPath()%>/mail_sms/sms.jsp",
		data: "id="+id,
		dataType: "html",
		context : document.getElementById("msg"),
		success: function(html){       
			var o = $(this)[0].context;
			//show(o);
			o.innerHTML = html.replace("\\r\\n","<br>");
			},
		error:function (xhr, ajaxOptions, thrownError){ 
	            //alert(xhr.status); 
	          var o = $(this)[0].context;
	            o.innerHTML = xhr.responseText;
	        }  

		  }); 
}
function mettreC(t){

	var txtarea = document.getElementById("text1");

	var valeur = t;

	    txtarea.focus();

	    if (txtarea.createTextRange){ //Si IE
			document.selection.createRange().text += valeur;
	    }else{
			if (txtarea.setSelectionRange)
	    	{
	       		var longeurText = txtarea.selectionEnd;
	        	txtarea.value = txtarea.value.substr(0, longeurText) + valeur + txtarea.value.substr(longeurText);
	        	txtarea.setSelectionRange(longeurText + valeur.length, longeurText + valeur.length);
	    	}
		}
}
function ajout_modif(){
	var tab = new Array("id","nom","texte","condicion");
	var u ="";
	for(var i=0;i<tab.length;i++){
		var d = eval("document.f1."+tab[i]+"");
		if(d.tagName == "INPUT" || d.tagName == "TEXTAREA" ){
			u+=(u==""?"":"&")+tab[i]+"="+d.value;
		}else{
			if(d.tagName == "SELECT"){
				u+=(u==""?"":"&")+tab[i]+"="+d[d.selectedIndex].value;
			}
		}
	}
	$.ajax({
		type: "POST",
		url: "<%=request.getContextPath()%>/mail_sms/sms_save.jsp",
		data: u,
		dataType: "json",
		contentType: "application/x-www-form-urlencoded;charset=UTF-8",
		success: function(html){       
			//alert(html.cmd);
			if(parseInt(html.cmd,10) >=0){
				alert("Saved successfully");
				listeM();
			}else{
				alert("Error");
			}
			
			
			},
		error:function (xhr, ajaxOptions, thrownError){ 
	            //alert(xhr.status); 
	            alert("Problem : \n"+xhr.responseText);
	        }  

		  }); 
	
}
function listeM(postData){
	$.post('<%=request.getContextPath()%>/mail_sms/getListeMail.jsp',postData, function(data) {
		$('#liste_des_mails').html(data);
	});
	
	
}
</script>
<style type="text/css">
html{
width: 100%;
height: 100%;
font-size: 12px;
}
/*a:ACTIVE,a:HOVER,a:VISITED,a:LINK{
	font-family: arial;
	font-size: 12px;
	color: #FF6600;
}*/
</style>
</head>
<body onload="listeM();">
<center>
<%@include file="/WEB-INF/include/menu_admin.jsp"%>
<form name="f1">
<div class="htitle" align="center">Manage SMS / Mail</div>

<table class="global" cellpadding="0" cellspacing="0" border="0">
<tr>
<td>
<%@include file="menu.jsp" %>
</td>
</tr>


<tr>
<td width="100%" >

<fieldset>
<legend class="legend">SMS Templates</legend>
<table cellpadding="0" cellspacing="0" border="0" width="100%" style="border-collapse: collapse;">

<tr>
<td valign="top" width="25%" height="100%"   style="border: 1px solid #D0D0BF;padding: 5px 5px 5px 5px;background-color:#F4F2F2;" id='liste_des_mails'>


</td>
<td   style="border: 0px solid black;padding: 10px;"><div id='msg' style="width:100%;height: 100%;overflow: auto;"></div></td>
</table>
</fieldset>
</td>
</tr>
</table>
</form>
</center>
</body>
</html>

