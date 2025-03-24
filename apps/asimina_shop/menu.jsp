<%@ page import="java.util.Enumeration"%>

<%
String contextPath = "";
%>

<%-- We'll be showing this only for these roles. --%>

<center>

<table cellpadding="0" cellspacing="0" border="0" width="700">
	<tr>
		<td class="topleft"></td>
		<td class="topmiddle" style="text-align: center; width: 668px;">
		<table cellpadding="0" cellspacing="0" border="0"
			style="text-align: center;">
			<tr>
				<td><a href="<%=contextPath%>ibo.jsp">Admin</a></td>
				<td><a href="<%=contextPath%>ibo.jsp">Plataforma</a></td>
				<td><a href="<%=contextPath%>maptar.jsp">Tarifas</a></td>
				<td><a href="<%=contextPath%>mapterm.jsp">Terminales</a></td>
				<td><a href="<%=contextPath%>mapOperator.jsp">Operadores</a></td>
	</tr>
</table>
</center>

