<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.asimina.util.UIHelper"%>
<%@ include file="common.jsp" %>

<%
	String phase = parseNull(request.getParameter("phase"));
	String process = parseNull(request.getParameter("process"));
	String callAjax = parseNull(request.getParameter("callAjax")); 
	String partialUpdate = parseNull(request.getParameter("partialUpdate")); 
	//String rulesVisibleTo = parseNull(request.getParameter("rulesVisibleTo")); 
	String currentProfile = parseNull(request.getParameter("currentProfile")); 
	if(callAjax.equals("")) callAjax = "false";
	if(partialUpdate.equals("")) partialUpdate = "false";
	
	Set rs = Etn.execute("select * from phases where process = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" ");
	rs.next();
	
	Set rsProfiles = Etn.execute("select * from profil where profil != 'SUPER_ADMIN' ");	
	
	String readonly = "";
	if(partialUpdate.equalsIgnoreCase("true") && callAjax.equalsIgnoreCase("false")) readonly = "readonly";
%>
<div style="text-align:left">
<div id='editPhaseMsg' class='errMessage'>&nbsp;</div> 
<table width='95%'><tr><td >Phase name : </td><td> <input type='text' value='<%=rs.value("phase")%>' <%=readonly%> name='newPhaseName' id='editPhaseName' maxlength='32' size='32'/></td></tr> 
<tr><td >Display name : </td><td> <input type='text' value='<%=(rs.value("displayName")).replaceAll("'","&#39;")%>' name='newPhaseDisplayName' id='editPhaseDisplayName' maxlength='100' size='32'/></td></tr>
<tr><td>Priority : </td><td> <input type='text' value='<%=rs.value("priority")%>' <%=readonly%> name='priority' id='editPriority' size='17'/></td></tr> 
<tr><td>Execute : </td><td> <input type='text' value='<%=rs.value("execute")%>' <%=readonly%> name='execute' id='editExecute' maxlength='64' size='17'/></td></tr>
			
	<% if (rs.value("visc").equals("1")) { %>
		<tr><td>Visible : </td><td> <input type='checkbox' id='phaseVisible' name='phaseVisible' value='1' checked/></td></tr>
	<% } else { %>
		<tr><td>Visible : </td><td> <input type='checkbox' id='phaseVisible' name='phaseVisible' value='1'/></td></tr>
	<% } %>
	<% if (rs.value("reverse").equals("R")) { %>
		<tr><td>Reverse : </td><td> <input type='checkbox' id='isReverse' name='isReverse' value='1' checked/></td></tr>
	<% } else { %>
		<tr><td>Reverse : </td><td> <input type='checkbox' id='isReverse' name='isReverse' value='1'/></td></tr>
	<% } %>
	<tr><td>Opr Type : </td>
	<td>
		<input type='radio' name='oprType' id='oprTypeT' value='T' <%if(rs.value("oprType").equals("T")){%>checked<%}%>>Technical</input> <input type='radio' id='oprTypeO' name='oprType' value='O'<%if(rs.value("oprType").equals("O")){%>checked<%}%>>Operational</input> 
	</td>
	</tr>
		
	<tr><td>Actors : </td><td> <textarea name='actors' id='editActors' rows='4' cols='50'><%=rs.value("actors")%></textarea></td></tr> 
</table>
			
<% if(callAjax.equalsIgnoreCase("true") || partialUpdate.equalsIgnoreCase("true")) { %>
	<div style='text-align:center; margin-top:3px'><input type='button' id='newPhaseBtn' value='Ok' onclick=onEditPhase('<%=UIHelper.escapeCoteValue(process)%>','<%=UIHelper.escapeCoteValue(phase)%>')></div>
<% } %>
</div>
