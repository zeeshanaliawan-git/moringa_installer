<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.asimina.util.UIHelper"%>
<%@ include file="common2.jsp" %>

<%
	String orderId = parseNull(request.getParameter("orderId"));
	String customerId = parseNull(request.getParameter("customerId"));

	String form_id = parseNull(request.getParameter("form_id"));

	String rowid = customerId;
	if(form_id.length() > 0) rowid = form_id;

	String process = parseNull(request.getParameter("process"));
	String currentPhase = parseNull(request.getParameter("currentPhase"));
	String nextProcess = parseNull(request.getParameter("nextProcess"));	
	String nextPhase = parseNull(request.getParameter("nextPhase"));
	String fromDialog = parseNull(request.getParameter("fromDialog"));
	String post_work_id = parseNull(request.getParameter("post_work_id"));
        String calendar_client_key = parseNull(request.getParameter("client_key"));

        if(calendar_client_key.length() > 0){
            rowid = calendar_client_key;
            Set rsOrder = Etn.execute("select * from post_work where status IN (0,9) AND phase NOT IN ('Cancel','Cancel30') AND is_generic_form = 0 AND client_key = "+escape.cote(calendar_client_key));
            if(rsOrder.next()){
                currentPhase = rsOrder.value("phase");
                post_work_id = rsOrder.value("id");
                process = rsOrder.value("proces");
                nextProcess = rsOrder.value("proces");
                if(currentPhase.equals(nextPhase)){
                    out.write("samePhase");
                    Etn.executeCmd("updade post_work SET priority=NOW() where id="+escape.cote(post_work_id));
                    Etn.execute("select semfree('"+SEMAPHORE+"')");
%>
                    <script>
                        opener.refreshCalendar();
                        opener.focus();
                        window.close();
                    </script>
<% 
                    return;
                }
                else if(nextPhase.equals("assignresource")||nextPhase.equals("Reschedule")) { 
%>
                    <script>
                            onOkChangePhase('<%=UIHelper.escapeCoteValue(orderId)%>', '<%=UIHelper.escapeCoteValue(rowid)%>', '<%=UIHelper.escapeCoteValue(process)%>', '<%=UIHelper.escapeCoteValue(currentPhase)%>', '<%=UIHelper.escapeCoteValue(nextProcess)%>','<%=UIHelper.escapeCoteValue(nextPhase)%>', '<%=UIHelper.escapeCoteValue(fromDialog)%>','<%=UIHelper.escapeCoteValue(post_work_id)%>','0');
                    </script>
<%                  return; 
}
            }
        }

	String query = "select r.errCode, e.errNom, e.errMessage from rules r, errcode e where start_phase = "+escape.cote(currentPhase)+" " + 
				   " and start_proc = "+escape.cote(process)+" and next_proc = "+escape.cote(nextProcess)+" and next_phase = "+escape.cote(nextPhase)+" and r.errCode = e.id ";
	Set rs = Etn.execute(query);
%>
<% if(rs.rs.Rows == 1) { 
	rs.next();
	%>
	<script>
		onOkChangePhase('<%=UIHelper.escapeCoteValue(orderId)%>', '<%=UIHelper.escapeCoteValue(rowid)%>', '<%=UIHelper.escapeCoteValue(process)%>', '<%=UIHelper.escapeCoteValue(currentPhase)%>', '<%=UIHelper.escapeCoteValue(nextProcess)%>','<%=UIHelper.escapeCoteValue(nextPhase)%>', '<%=UIHelper.escapeCoteValue(fromDialog)%>','<%=UIHelper.escapeCoteValue(post_work_id)%>','<%=UIHelper.escapeCoteValue(rs.value("errCode"))%>')
	</script>
<% } else { %>
<style>
#errTbl th {background-color:#f7b64c; color:white; border:1px solid #e78f08; }
#errTbl td {border-bottom:1px solid #f7b64c; }
</style>

<div id='changePhaseErrMsg' style="text-align:left; color:RED">&nbsp;</div> 
<div>
	<table id='errTbl' cellspacing='0' cellpadding='1' border='0' width="100%">
		<thead >
			<th width="4%">&nbsp;</th>
			<th width="30%">Err Nom</th>
			<th>Err Message</th>
		</thead>
		<% while(rs.next()) { %>
			<tr>
				<td align="center"><input type='radio' name='changePhaseErrCode' value='<%=UIHelper.escapeCoteValue(rs.value("errCode"))%>' /></td>				
				<td><%=UIHelper.escapeCoteValue(rs.value("errNom"))%></td>				
				<td><%=UIHelper.escapeCoteValue(rs.value("errMessage"))%></td>				
			</tr>
		<% } %>
	</table>
</div>
<div>
	<div onclick="javascript:onOkChangePhase('<%=UIHelper.escapeCoteValue(orderId)%>', '<%=UIHelper.escapeCoteValue(rowid)%>', '<%=UIHelper.escapeCoteValue(process)%>', '<%=UIHelper.escapeCoteValue(currentPhase)%>', '<%=UIHelper.escapeCoteValue(nextProcess)%>','<%=UIHelper.escapeCoteValue(nextPhase)%>', '<%=UIHelper.escapeCoteValue(fromDialog)%>','<%=UIHelper.escapeCoteValue(post_work_id)%>')" style="width:50px; padding-left:1px; margin-top:2px; margin-bottom:1px; cursor:pointer; background-color:<%=ORANGE%>; color:white; border-right:1px solid #bc3a00; border-bottom:1px solid #bc3a00">Ok</div>
</div>
<% } %>