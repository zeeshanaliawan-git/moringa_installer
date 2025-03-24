<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.*"%>
<%@ page import="com.etn.sql.escape"%>
<%@ include file="/WEB-INF/include/commonVal.jsp" %>
<%@ include file="/WEB-INF/include/commonMethod.jsp" %>
<%
String table=request.getParameter("tipo");
String t[] = tableStock(table);
table = t[0];

String tab1[] = (table.equalsIgnoreCase("stock")?tab_col_stock:tab_col_stock_other);

%>
<script>
   
function evt1(){

	 
}

$(document).ready(function() 
	    { 
	//alert("ici");
	//$("#tab_stock").tablesorter({ headers: { 4: { sorter: false},7: { sorter: false} } }); 
evt1();
doTri();
	    } 
	); 
	
	
function setInfo(tr,t){
	
	var tab_s = document.getElementById("tab_stock");
	if(t.date_update!=""){
		var cle_d = tab_s.rows[tr.rowIndex].cells[<%=getIndex(tab1,"date_saisie")%>];
		cle_d.innerHTML = t.date_update;
	}
	/*if(t.sv!=""){
		var cle_d2 = tab_s.rows[tr.rowIndex].cells[<%=getIndex(tab1,"stock_virtuel")%>];
		cle_d2.innerHTML = t.sv;
		//alert(t.st)
	}*/
	//alert(t.r_sup_stock)
	if(t.r_sup_stock!=""){
		var cle_d3 = tab_s.rows[tr.rowIndex].cells[<%=getIndex(tab1,"rotation_hebdo")%>];
		
		
		if(t.r_sup_stock==0){
			//cle_d3.innerHTML = t.st;
			cle_d3.style.fontWeight="";
			cle_d3.style.color="";
			//alert("a")
		}else{
			if(t.r_sup_stock==1){
				//cle_d3.innerHTML = t.st;
				cle_d3.style.fontWeight="bold";
				cle_d3.style.color="red";
				//alert("b")
			}
		}
	}
	
	if(t.ppr!=""){
		var cle_d4 = tab_s.rows[tr.rowIndex].cells[<%=getIndex(tab1,"pendiente_producto")%>];
		cle_d4.innerHTML = t.ppr;
		//alert(t.st)
	}
	//alert(t.reserve)
	if(t.reserve!=undefined){
		var cle_d4 = tab_s.rows[tr.rowIndex].cells[<%=getIndex(tab1,"reserve")%>];
		//show(cle_d4);
		var r = cle_d4.firstChild;
		if(t.reserve == 0){
			r.checked = false;
		}else{
			r.checked = true;
		}
		
		//alert(t.st)
	}
	
	
	
}

function getData(o,html){
	//show(html);
	var n = <%=tab1.length%>;
	//alert(n);
	//alert(html.col0);
	<%for(int y=0;y<tab1.length-2;y++){%>
		o.cells[<%=y%>].innerHTML=html.col<%=y%>;	
	<%}%>
	o.cells[parseInt(n,10)-4].innerHTML= "<input type=\"checkbox\" name=\"c\" value='0'>";
	o.cells[parseInt(n,10)-3].innerHTML= "<input type=\"checkbox\" name=\"c1\" checked value='1'>";
	o.cells[parseInt(n,10)].setAttribute("b_codesap",html.col0);
	o.cells[parseInt(n,10)].innerHTML= "<input type=\"button\" name=\"suppr\" onclick=\"supprC(this.parentNode.getAttribute('b_codesap'));\" style=\"cursor: pointer;color: red;font-weight: bold;border:0;background-color: #EEEEEE;\" value='X'>";
	
	
	var nb = 3;
	var tipo1 = document.getElementById("tipo");
	
	if( tipo1.selectedIndex == 1 ){
		nb = 5;
	}
	for( var c=0; c < nb;c++){
		o.cells[c].className = "m";
		//o.cells[c].dblclick( function() { alert("Hello"); } );
	}
//	evt1();
	
}
	
</script>
<%
    
String referencia = request.getParameter("referencia");
if(referencia == null) referencia ="";
String descripcion_ref = request.getParameter("descripcion_ref");
if(descripcion_ref == null) descripcion_ref ="";
String stock_disponible_portabilidad = request.getParameter("stock_disponible_portabilidad");
if(stock_disponible_portabilidad == null) stock_disponible_portabilidad ="";
String stock_virtuel = request.getParameter("stock_virtuel");
if(stock_virtuel == null) stock_virtuel ="";
String col1 = request.getParameter("col1");
if(col1 == null) col1 ="";

String marca = request.getParameter("marca");
if(marca == null) marca ="";

String signe1 = signe[Integer.parseInt(request.getParameter("signe1"),10)];
if(signe1 == null) signe1 ="";
String signe2 = signe[Integer.parseInt(request.getParameter("signe2"),10)];
if(signe2 == null) signe2 ="";

String sql="";




if(!table.equalsIgnoreCase("sim")){ 
//sql= "select referencia, descripcion_ref, stock_disponible_portabilidad,  stock_virtuel, col1,date_update,date_import,(stock_virtuel - coalesce(nb,0)) as nb,reserva from stock ";

sql = "select "+(table.equalsIgnoreCase("stock")?"stock.codesap, terminalIDEUP":"codesap, description")+" , stock_icp, reserve, actif, date_saisie, date_icp, stock_saisie"+(table.equalsIgnoreCase("stock")?",coalesce(pproducto.pendiente_producto,0) as pendiente_producto":",0 as pendiente_producto")+", rotation_hebdo, type,stock_saisie as nb,stock_virtuel ";


if(table.equals("stock")){
	sql+=" , m.terminalARPA, m.marca,gama_alta ";
}


sql+=" from  "+table;

if(table.equals("stock")){
	sql+=" , mapterminal m";
	sql+=" left join (select terminalsap,count(*) as pendiente_producto from phases p,post_work p2,customer c where p.process = p2.proces and p.phase = p2.phase and p2.client_key = c.customerid and p.phase = 'PendienteProducto98' and status=0 group by 1 order by 1) as pproducto on (pproducto.terminalsap = m.codesap)";
}
sql+=" where 1=1 ";

if(table.equals("stock")){
	sql+=" and m.codesap = "+table+".codesap ";
}

if(!referencia.equals("")){
	sql+= " and "+(table.equalsIgnoreCase("stock")?"m.codesap":"codesap")+" = "+escape.cote(referencia)+"";
}


if(!descripcion_ref.equals("")){
	sql+= " and "+(table.equalsIgnoreCase("stock")?"terminalIDEUP":"description")+" like "+escape.cote(descripcion_ref+"%")+"";
}
if(!stock_disponible_portabilidad.equals("")){
	sql+= " and stock_icp "+signe1+" "+escape.cote(stock_disponible_portabilidad)+"";
}
if(!stock_virtuel.equals("")){
	sql+= " and stock_virtuel "+signe2+" "+escape.cote(stock_virtuel)+"";
}
if(!col1.equals("")){
	sql+= " and actif = "+escape.cote(col1)+"";
}

if(!t[1].equals("")){
	sql+=" and type="+escape.cote(""+t[1]);	
}

if(!marca.equals("")){
	sql+= " and m.marca like "+escape.cote(marca+"%")+"";
}

sql+=" order by 1 ";

}else{
	sql="SELECT generica,sum(s1.stock_icp) as nb FROM `sim`s1 group by 1 order by 1";//count(*)
}

Set rs = Etn.execute(sql); 
//out.write(sql);
%>

<!-- <form method="post"> -->


<div class="infoligne">Numero de lïnea(s) : <div id="nb_ligne_tab" style="display: inline;"><%=rs.rs.Rows%></div></div>

<%if(!table.equalsIgnoreCase("sim")){ %>

<table id="tab_stock" class="tablesorter" border="0" cellpadding="0" cellspacing="1" align="center"width="95%">
<thead id="th_stock">
<tr>
<th width="5%">Referencia SAP</th>

<%if(table.equalsIgnoreCase("stock")){ %>
<th width="10%">Marca</th>
<%} %>

<th width="15%">Descripcion ref</th>

<%if(table.equalsIgnoreCase("stock")){ %>
<th width="15%">Nombre Arpa</th>
<%} %>

<th width="5%">Stock<br>ICP<br>(5 am)</th>
<th width="5%">Stock<br>Virtual</th>
<!-- <th width="7%">Nombre<br>ARPA</th> -->
<th width="5%">Pendiente<br>Producto</th>
<th width="5%">Rotacion<br>Semanal</th>
<th width="10%">Cobertura</th>
<th width="10%">Fecha<br>update</th>
<th width="10%">Fecha<br>import</th>
<th width="1%">Reserva</th>
<th width="1%">Activo</th>

<%if(table.equalsIgnoreCase("stock")){ %>
<th>gama alta</th> 
<th>Suppr.</th>
<%} %>
</tr>
</thead>	
<tbody id="tb">
<%

int r=0;



while( rs.next() )
{
 
	int sv = Integer.parseInt(rs.value("nb"),10);
	int si = Integer.parseInt(rs.value("stock_icp"),10);
	int ppro = Integer.parseInt(rs.value("pendiente_producto"),10);
	int rh = Integer.parseInt(rs.value("rotation_hebdo"),10);
%>



<tr>
<td><%=rs.value(table.equalsIgnoreCase("stock")?"codesap":"codesap")%></td>
<%if(table.equalsIgnoreCase("stock")){ %>
<td class="m"><%=rs.value("marca")%></td>
<%} %>
<td class="m"><%=rs.value(table.equalsIgnoreCase("stock")?"terminalIDEUP":"description")%></td>
<%if(table.equalsIgnoreCase("stock")){ %>
<td class="m"><%=rs.value("terminalARPA")%></td>
<%} %>
<td <%=(si<=0?"style='color:red;font-weight:bold;'":"") %>><%=si%></td>
<td class="m"><%=rs.value("stock_virtuel")%></td>
<!-- <td></td>  Nombre Arpa-->
<td <%=(ppro>=0?"style='color:red;font-weight:bold;'":"") %>><%=ppro%></td>
<td <%=(rh>sv?"style='color:red;font-weight:bold;'":"") %>><%=rh%></td>
<td></td>
<td class="d"><%=rs.value("date_saisie")%></td>
<td><%=rs.value("date_icp")%></td>
<td><input type="checkbox" name="c" <%=(rs.value("reserve").equals("1")?" checked ":" ")%> value="<%=rs.value("reserve")%>"/> </td>
<!-- <td><input type="checkbox" name="c1" <%=(rs.value("actif").equals("1")?" checked":" ")%> value="<%=rs.value("actif")%>"/> </td> -->
<td>
<%=AfficheSelect(h_statusStock,"",rs.value("actif"),""," class=\"s\" ","0","--") %>
</td>
<%if(table.equalsIgnoreCase("stock")){ %>
<td><%=AfficheSelect(tab_gama_alta,"",rs.value("gama_alta"),""," class=\"s\" ","","") %></td> 
<td><input type="button" name="suppr" onclick="supprC('<%=rs.value("codesap")%>');" style="cursor: pointer;color: red;font-weight: bold;border:0;background-color: #EEEEEE;" value='X'></td> 
<%} %>
</tr>
<%}%>
</tbody>

<tr>
	<td>&nbsp;<input type="text" libelle="- le code sap" id="codesap"  name="codesap" maxlength="9" size="5">&nbsp;</td>
	<%if(table.equalsIgnoreCase("stock")){ %>
	<td>&nbsp;<input type="text" libelle="- la marque" id="marca2" name="marca2" size="15">&nbsp;</td>
	<%} %>
	<td>&nbsp;<input type="text" libelle="- la description" id="description" name="description" size="20">&nbsp;</td>
	<%if(table.equalsIgnoreCase("stock")){ %>
	<td>&nbsp;<input type="text" libelle="- le nombre arpa" id="terminalARPA" name="terminalARPA" size="20">&nbsp;</td>
	<%} %>
	<td>&nbsp;<input type="text" libelle="- le stock icp" id="stock_saisie" name="stock_saisie" size="1">&nbsp;</td>
	<td>&nbsp;<input type="button" onclick="ajout(this);" value="+">&nbsp;</td>
	<td>--</td>
	<td>--</td>
	<td>--</td>
	<td>--</td>
	<td>--</td>
	<td>--</td>
	<td>--</td> 
	<%if(table.equalsIgnoreCase("stock")){ %>
	<td>--</td> 
	<td>--</td> 
	<%} %>
</tr>


</table>
<A NAME="terminal"></A>

<br>

<%}else{ %>

<table id="tab_stock" class="tablesorter" border="0" cellpadding="0" cellspacing="1" align="center"width="95%">
<thead id="th_stock">
<tr>
<th>Generica</th>
<th>Nombre</th>
</tr>
</thead>
<tr>
<%while( rs.next() )
{ %>
<tr>
<td><%=rs.value("generica")%></td>
<td><%=rs.value("nb")%></td>
</tR>
<%} %>
</tr>
</table>

<%} %>
