<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN" "http://www.w3.org/TR/html4/strict.dtd"> -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Guizmo - Upload</title>
<link rel="stylesheet" type="text/css" href="../css/menu.css">
<link rel="stylesheet" type="text/css" media="screen" href="../css/eshop.css" />
<link rel="stylesheet" type="text/css" href="../css2/general.css"> 
<link rel="stylesheet" type="text/css" href="../css/general.css">
<script src="../js/eshop.js" type="text/javascript"></script>
<script src="../js/js-upload/jquery-1.4.2.min.js" type="text/javascript"></script>
<script src="../js/js-upload/jquery.upload-1.0.2.js" type="text/javascript"></script>
</head>
<body>
<form name="f1" action="stock.jsp" method="post">
<%@include file="/WEB-INF/include/menu_admin.jsp"%>


<table cellpadding="0" cellspacing="0" border="0" style="background-color: white;width: 100%;text-align: center;">

<tr>
<td class="htitle" align="center">Upload SIM</td>
</tr>
<!-- 
<tr>
<td><%@include file="menu_stock.jsp" %></td></tr>

 -->

<tr>
<td style="text-align: center;">
<fieldset>
<legend class="legend">Upload SIM</legend>
<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
<tr>
<td>
<div class="message">


<script type="text/javascript">
	$(function() {
        $('#file1').change(function() {
            $(this).upload('../js/js-upload/upload_fic2.jsp', function(res) {
                //$(res).insertAfter(this);
                //show(res);
                $(this)[0].value = "";
                var str = "Fichier " + res.fichier + " chargé<br>";
                //document.getElementById("file1").value = "";
                if(res.err==""){
                	str+= "Número importado de línea : " + res.ligne_i;
                	
                	document.getElementById("s").disabled = false;
                	
                }else{
                	if(res.err==-1){
						str = "Número de columna diferente";
                	}else{
                		if(res.err==-2){
                			str = "El fichero no contiene las columnas esperadas";
                		}else{
                			if(res.err==-100){
                				str = "Fichero no encontrado";
                			}else{
								str = res.err; 
                			}
                		}
                	}
					
                
                }
                
            	document.getElementById("info_fic").innerHTML = str;                
            }, 'json');
        });
    });

  </script>

  <input type="file" name="file" id="file1"/>
  <div id="info_fic"></div>
 	
 	<br>
 	<input type="button" id="s" name="s" class="continuar" value="" disabled="disabled" onclick="var f = document.f1;f.submit();">
	<br>
	<center style="display: none;">
	<table><tr><td>
	Sauvegarder le fichier en texte tabulé :
		<br>- Faire enregister-sous
		<br>- Sélectionner Type de fichier Texte (séparateur : tabulation)
	
	</td>
	</tr>
	<tr><td><br></td></tr>
	<tr><td>Exemple de fichier <a href="javascript:document.f3.submit();">exemple_import_stock.txt</a> </td></tr>
	</table>
	</center>
</div>
</td>
</tr>
</table>
</fieldset>
</td>
</tr>
</table>
<input type="hidden" name="type_upload" value="sim"/>
</form>

<form action="exemple2.jsp" method="post" name="f3" id="f3">

</form>

</body>
</html>


