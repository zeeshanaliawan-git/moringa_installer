<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ include file="common.jsp" %>

<%
	String comments = parseNull(request.getParameter("comments"));
	String customerId = parseNull(request.getParameter("customerId"));
	String form_id = parseNull(request.getParameter("form_id"));

	String orderId = parseNull(request.getParameter("orderId"));
	String phaseDisplayName = request.getParameter("phaseDisplayName");
	String post_work_id = request.getParameter("post_work_id");
	String sql = ""; 
	String redirect = "";

	if(form_id.length() > 0)
	{
		sql = "update generic_forms set comments = concat('<tr><td>',date_format(current_timestamp,'%d/%m/%Y %H:%i:%s'),'</td><td>',"+escape.cote(phaseDisplayName)+",'</td>','<td>"+(String)session.getAttribute("LOGIN")+"</td><td>',"+escape.cote(escapeHtml(comments))+",'</td></tr>',ifnull(comments,'')) where id = "+escape.cote(form_id)+" ";
		redirect = "genericFormEdit.jsp?post_work_id="+post_work_id+"&customerId="+form_id;
	}

	else if(customerId.length() > 0)
	{
		String targetTable = "orders";
		if("1".equals(com.etn.beans.app.GlobalParm.getParm("POST_WORK_SPLIT_ITEMS"))) targetTable = "order_items";
		
		sql = "update "+targetTable+" set comments = concat('<tr><td>',date_format(current_timestamp,'%d/%m/%Y %H:%i:%s'),'</td><td>',"+escape.cote(phaseDisplayName)+",'</td>','<td>"+(String)session.getAttribute("LOGIN")+"</td><td>',"+escape.cote(escapeHtml(comments))+",'</td></tr>',ifnull(comments,'')) where id = "+escape.cote(customerId)+" ";
		redirect = "customerEdit.jsp?post_work_id="+post_work_id+"&customerId="+customerId;
	}

	if(sql.length() > 0 ) Etn.executeCmd(sql);
	
	response.sendRedirect(redirect);
%>