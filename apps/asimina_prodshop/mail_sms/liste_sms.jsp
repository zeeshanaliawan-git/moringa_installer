<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
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
<%
	Set rsLang = Etn.execute("select * from language order by langue_id");

    String delSmsId = parseNull(request.getParameter("delete_sms_template"));
	int deletedRows = Etn.executeCmd("delete from sms where sms_id = "+escape.cote(delSmsId));
    String selectedLang = parseNull(request.getParameter("lang"));
	if(selectedLang.length() == 0) selectedLang = "1";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Shop - Manage SMS</title>
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <%-- <link href="<%=request.getContextPath()%>/css/style.css" rel="stylesheet"> --%>
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <%-- Styles for jQuery calendars --%>
    <%-- <link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet"> --%>

    <!-- CoreUI and necessary plugins-->
    <script src="<%=request.getContextPath()%>/js/eshop.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <%-- <script src="<%=request.getContextPath()%>/js/jquery-ui.min.js"></script> --%>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
       <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>
<script>
function showProcessing(){
	$('#msg').html("<center>Loading, please wait<br><div style='text-align:center;'><img alt='Loading, please wait' src='../img/ajax-loader.gif'/></div></center>");
}
function getF(id){
	showProcessing();
	$.ajax({
		type: "GET",
		url: "<%=request.getContextPath()%>/mail_sms/sms.jsp",
		data: "id="+id+"&lang=<%=selectedLang%>",
		dataType: "html",
		success: function(html){
			$('#msg').html(html.replace("\\r\\n","<br>"));
		},
		error:function (xhr, ajaxOptions, thrownError){
	            $('#msg').html(xhr.responseText);
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
	var u ="lang=<%=selectedLang%>";
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
	$.post('<%=request.getContextPath()%>/mail_sms/getListeMail.jsp?lang=<%=selectedLang%>',postData, function(data) {
		$('#liste_des_mails').html(data);
	});
}

function deleteSmsTemplate(id){
    window.location.href = "liste_sms.jsp?lang="+$("#lang").val()+"&delete_sms_template="+id;
}

function changeLang()
{
    window.location.href = "liste_sms.jsp?lang="+$("#lang").val();
}

</script>
</head>
<body onload="listeM();" class="c-app" style="background-color:#efefef">

<!-- <body  class="app header-fixed sidebar-fixed sidebar-lg-show"> -->
   <%@ include file="../WEB-INF/include/sidebar.jsp" %>
   <div class="c-wrapper c-fixed-components">
        <%@ include file="/WEB-INF/include/header.jsp" %>
        <div class="app-body">
        <%
            if(delSmsId.length()>0 && deletedRows>0){
        %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
              <strong>Deleted</strong> successfully.
              <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
        <%}%>
          <main class="main">
            <!-- Breadcrumb-->
            <ol class="breadcrumb">
              <li class="breadcrumb-item">Home</li>
              <li class="breadcrumb-item">Admin</li>
              <li class="breadcrumb-item active"><a href="#">Manage SMS</a></li>
            </ol>
            </ol>
            <div class="container-fluid">
              <div class="animated fadeIn">
                <div class="card">
                  <div class="card-header">Manage SMS</div>
                  <div class="card-body">
                    <%@include file="menu.jsp" %>
            <form name="f1">

            <fieldset>
            <legend class="legend">SMS Templates</legend>
            <div class="mt-2 mb-2">
            	Language : <select id='lang' onchange="changeLang()">
            		<%while(rsLang.next()){%>
            		<option <%=selectedLang.equals(rsLang.value("langue_id"))?"selected":"" %> value='<%=rsLang.value("langue_id")%>'><%=rsLang.value("langue")%></option>
            		<%}%>
            	</select>
            </div>
            <table cellpadding="0" cellspacing="0" border="0" width="100%" style="border-collapse: collapse;">

            <tr>
            <td valign="top" width="50%" height="100%"   style="border: 1px solid #D0D0BF;padding: 5px 5px 5px 5px;background-color:#F4F2F2;" id='liste_des_mails'>


            </td>
            <td   style="border: 0px solid black;padding: 10px;"><div id='msg' style="width:100%;height: 100%;overflow: auto;"></div></td>
            </table>
            </fieldset>
            </form>
                  </div>
                </div>
              </div>
            </div>
    	</main>
        </div>
    </div>
</body>
</html>

