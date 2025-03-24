<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>
<%
	String process = parseNull(request.getParameter("process"));
	String phase = parseNull(request.getParameter("phase"));
	String customerIdsList = parseNull(request.getParameter("customerIdsList"));

	Set rs = null;
	if(!process.equals("") && !phase.equals(""))
	{
		String query = " select cl.orderId, cl.customerId, '' as nom_vendeur, cl.contactPhoneNumber1, cl.name, cl.surnames, " +
			        "       cl.creationDate, '' as produits, pw.id wid , pw.proces, pw.priority, " +
				"       pw.instance_agent, pw.errCode, pw.errMessage, pw.attempt, pw.insertion_date, " +
				"       pw.start, pw.end, pw.phase, pw.flag, pw.operador, errs.errNom, errs.errMessage technicalMsg, " +
				"       errs.errType, errs.errCouleur, pw.status as post_work_status, '' as canalDeVente " +
				"  from customer cl, " +
				"       post_work pw, " +
				"       errcode errs " +
				" where cl.customerId = pw.client_key " +
			        "   and pw.proces   = " + escape.cote(process) + " " +
			        "   and pw.phase     = " + escape.cote(phase) + " " +
				"   and pw.errCode   = errs.id " +
	 		 	"   and pw.status in (0,1) ";
		if(!customerIdsList.equals(""))
		{
			customerIdsList = escape.cote(customerIdsList);
			customerIdsList = customerIdsList.replaceAll(",","','");			
			query += " and pw.client_key in ("+customerIdsList+") ";
		}
		query += " order by pw.id desc limit 20 ";				
		System.out.println(query);
		rs = Etn.execute(query);		
	}
%>

<% if (process.equals("") || phase.equals("")) { %>
	<span>ERROR: Invalid search criteria</span>
<% } else { 
	int index = 0;
	while(rs.next())
	{
%>
	<% if (index == 0) { %>
	<h3>Open orders</h3>
	<table cellpadding="0" cellspacing="0" border="0" style="margin-top:5px; margin-bottom:10px; border: 0px;" width="90%">	
		<tr>
			<th class="labels" width="10%">Process</th>
			<th class="labels" width="2%">:</th> 
			<td class="labels" width="25%"><%=process%></td>
			<th class="labels" width="10%">Phase</th>
			<th class="labels" width="2%">:</th> 
			<td class="labels" ><%=phase%></td>
		</tr>
	</table>
	<table cellspacing=0 cellpadding=0 class="result" id="ordersTable" width='100%' >
		<tr>
			<th>Order No.</th>
			<th>Order Date</th>
			<th>Name</th>
			<th>Surname</th>
			<th>Vendeur</th>
			<th>Products</th>
			<th>Sales channel</th>
			<th>PW ID</th>
			<th>Priority</th>
			<th>Instance Agent</th>
			<th>CSR</th>
			<th>id_pedido</th>
			<th>Err Code</th>
			<th>Err Msg</th>
			<th>Date insertion</th>
			<th>Start</th>
			<th>End</th>
			<th>No. Of Tries</th>
			<th>Flow</th>
		</tr>
	<% } %>
	
	<tr>
		<td><%=parseNull(rs.value("orderId"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("creationDate"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("name"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("surnames"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("nom_vendeur"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("produits"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("canalDeVente"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("wid"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("priority"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("instance_agent"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("operador")).equals("")? "Guizmo":parseNull(rs.value("operador"))%>&nbsp;</td>
		<!-- <td><%=parseNull(rs.value("post_work_status"))%>&nbsp;</td>-->
		<td><%
                        out.write("<span style='text-decoration:underline' onclick='return(client(\""
                        + rs.value("orderId")
                        + "\"))'>"
                        + rs.value("customerid") + "</span>");
                %></td>
		<td><%=parseNull(rs.value("errCode"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("errMessage"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("insertion_date"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("start"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("end"))%>&nbsp;</td>
		<td><%=parseNull(rs.value("attempt"))%>&nbsp;</td>
		<td><a href='javascript:viewOrderFlow("<%=process%>","<%=phase%>","<%=rs.value("customerId")%>")'>View</a></td>
	</tr>
	
<%	
	index ++;
	}//while 
	
} %>
</table>

<script id="ordersScript" type="text/javascript">
        sorttable.init(document.getElementById("ordersTable"));
</script>
