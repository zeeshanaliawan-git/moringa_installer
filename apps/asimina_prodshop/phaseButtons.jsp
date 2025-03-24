<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>

<%
	String customerId = request.getParameter("customerId");
	String phase = request.getParameter("phase");
	String process = request.getParameter("process");
	String orderId = request.getParameter("orderId");
	String fromDialog = request.getParameter("fromDialog");
	if(fromDialog == null || fromDialog.equals("")) fromDialog = "false";
	
	String query = "select * from phases where phase = "+escape.cote(phase)+" and process = "+escape.cote(process)+" ";
	Set rsPhase = Etn.execute(query);
	boolean showRulesButtons = false;			
	if(rsPhase.next() && (rsPhase.value("rulesVisibleTo")).indexOf((String)session.getAttribute("PROFIL")) > -1) showRulesButtons = true;
	if(((String)session.getAttribute("PROFIL")).startsWith("SUPER_ADMIN")) showRulesButtons = true;

	
	if(showRulesButtons)
	{
		query = "select distinct ph.phase,  ph.displayName, r.next_phase, r.next_proc from rules r, phases ph where r.next_proc = ph.process and r.next_phase = ph.phase and start_phase = "+escape.cote(phase)+" and start_proc = "+escape.cote(process)+" ";
		Set rsRules = Etn.execute(query);
%>
<% if(rsRules.rs.Rows > 0) { %>
<table id="phaseBtns" align="center" cellpadding="0" cellspacing="0" border="0">
	<tr><th>Estado Guizmo</th></tr>
	<tr>
		<td align="center">
			<% while(rsRules.next()) { %>
				<input type="button" name="<%=rsRules.value("next_phase")%>" value="<%=rsRules.value("displayName")%>" class="backbutsearch" onMouseOver="className='backbutsearchon';" onMouseOut="className='backbutsearch';"  onclick="onChangePhaseBtn('<%=orderId%>','<%=customerId%>','<%=process%>','<%=phase%>','<%=rsRules.value("next_phase")%>','<%=fromDialog%>');" />				
			<% } %>
		</td>
	</tr>
</table>
<% } 
}%>
