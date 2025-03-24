<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ include file="common2.jsp" %>

<%
	String query = "select e.id as errCode, e.errNom, e.errMessage from errcode e where errType = 'cancel' order by e.id";
	Set rs = Etn.execute(query);
%>
<style>
#errTbl th {background-color:#f7b64c; color:white; border:1px solid #e78f08; }
#errTbl td {border-bottom:1px solid #f7b64c; }
</style>

<div id='cancelErrMsg' style="text-align:left; color:RED">&nbsp;</div> 
<div>
	<table id='errTbl' cellspacing='0' cellpadding='1' border='0' width="100%">
		<thead >
			<th width="4%">&nbsp;</th>
			<th width="10%">Codigo Motivo</th>
			<th width="30%">Motivo</th>
		</thead>
		<% while(rs.next()) { %>
			<tr>
				<td align="center"><input type='radio' name='cancelErrCode' value='<%=rs.value("errCode")%>' /></td>				 				
				<td><%=rs.value("errNom")%></td>				
				<td><%=rs.value("errMessage")%></td>				
			</tr>
		<% } %>
	</table>
</div>
<div>
	<div onclick="javascript:onCancel()" style="width:50px; padding-left:1px; margin-top:2px; margin-bottom:1px; cursor:pointer; background-color:<%=ORANGE%>; color:white; border-right:1px solid #bc3a00; border-bottom:1px solid #bc3a00">Ok</div>
</div>
