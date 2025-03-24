<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");  %>
<%@ page import="com.etn.lang.ResultSet.*"%>
<%@ page import="com.etn.sql.escape"%>
<%@ include file="/WEB-INF/include/commonVal.jsp" %>
<%@ include file="/WEB-INF/include/commonMethod.jsp" %>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  --> 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Guizmo - Stock</title>
<link rel="stylesheet" type="text/css" href="../css/menu.css">
<link rel="stylesheet" type="text/css" media="screen" href="../css/eshop.css" />
<link rel="stylesheet" type="text/css" href="../css2/general.css"> 
<link rel="stylesheet" type="text/css" href="../css/general.css">
<script src="../js/jquery-1.4.2.min.js" type="text/javascript"></script><!-- jquery-latest.js -->
<script src="../js/jquery.tablesorter.js" type="text/javascript"></script>
<script src="../js/eshop.js" type="text/javascript"></script>
<script>

var a = <%=getIndex(tab_col_stock,"codesap")%>;




</script>
<script src="../js/stock.js" type="text/javascript"></script>


</head>
<body>

<div id="D1" style="display: none;">
<input class="saisie" type="text" style="width: 90%;" id="inp" onblur="editChange(this)"/>
</div>
<div id="D2" style="display: none;">
<input class="cal" type="text" id="cal" />
</div>

<%@include file="/WEB-INF/include/menu_admin.jsp"%>

<table cellpadding="0" cellspacing="0" border="0" style="background-color: white;width: 100%;text-align: center;">

<tr>
<td class="htitle" align="center">Gestión de stock</td>
</tr>
<!--
<tr>
<td><%@include file="menu_stock.jsp" %></td></tr>
-->


<tr>
<td style="text-align: center;">
<fieldset>
<legend class="legend">Busca stock</legend>
<table cellpadding="0" cellspacing="0" width="100%" border="0" align="center">
<tr><td id="td_stock0" align="right" colspan="8"><img src='../img/arrow.png' border='0'><A HREF="#terminal">Añadir un terminal</A>&nbsp;&nbsp;</td></tr>
<tr>
	<td id="td_stock1" class="textesearch" width="10%">Referencia SAP</td>
	<td id="td_stock2"  class="textesearch" width="15%">&nbsp;:&nbsp;<input name="referencia" id="referencia" value="" size="10"></input></td>
	<td id="td_stock3"  class="textesearch" width="10%">Stock ICP (5 am)</td>
	<td id="td_stock4"  class="textesearch" width="15%">&nbsp;:&nbsp;<select id="choix1" name="choix1">
					<%for(int s=0;s<signe.length;s++){ %>
					<option value="<%=s%>"><%=signe[s]%>
					<%} %>
					</select>
	<input name="stock_disponible_portabilidad" id="stock_disponible_portabilidad" value="" size="10"></input></td>
	<td id="td_stock5"  class="textesearch" width="10%">Activo</td>
	<td id="td_stock6"  class="textesearch" width="10%"><!-- 40% -->&nbsp;:&nbsp;
	
	<!-- <select name="col1" id="col1"><option value="">Todos </option><option value="0">No </option><option value="1" selected>Si</option></select></td>-->
	
	<%=AfficheSelect(h_statusStock,"col1","","--","","","--") %>
	
	<td id='td_marca1' class="textesearch">Marca</td>
	<td id='td_marca2' class="textesearch" >&nbsp;:&nbsp;<input name="marca" id="marca" value="" size="10"></input></td>
</tr>
<tr>
	<td id="td_stock7"  class="textesearch" style="align:left;">Descripcion ref<br><span style="color: #999999;font-size: 7pt;">(Comienza por)</span></td>
	<td id="td_stock8"  class="textesearch">&nbsp;:&nbsp;<input name="descripcion_ref" id="descripcion_ref" value="" size="10"></input></td>
	<td id="td_stock9"  class="textesearch">Stock Virtual</td>
	<td id="td_stock10"  class="textesearch">&nbsp;:&nbsp;<select id="choix2" name="choix2">
					<%for(int s=0;s<signe.length;s++){ %>
					<option value="<%=s%>"><%=signe[s]%>
					<%} %>
					</select>
	<input name="stock_virtuel" id="stock_virtuel" value="" size="10"></input></td>
	<td id="td_stock11"  class="textesearch">Tipo de Producto</td>
	<td id="td_stock12"  class="textesearch">&nbsp;:&nbsp;<select id="tipo" name="tipo" onchange="selectTipo(this);">
					
					<option>Terminal</option>
					<option>Accesorio</option>
					<option>Regalo</option>
					<option <%=(request.getParameter("type_upload")!=null?"selected":"") %>>SIM</option>					
					
		
					</select>
	</td>
	
	
	</tr>

<tr><td>&nbsp;</td></tr>

<tr><td colspan="8" align="center"><input class="search" type="submit" value="" onclick="getResults(getSearchData());"></input></td>
</tr>
</table>
</fieldset>
</td>
</tr>
</table>



<div id="resultsDiv"></div>


<!-- 
<input name="send" type="submit" onclick="return(soumet(this));" value="aaa">
<input name="datas" type="hidden">
 -->


</body>
</html>
