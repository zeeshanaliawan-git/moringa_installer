<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape"%>

<%@ include file="common.jsp" %>

<%
	String jsonId = parseNull(request.getParameter("jsonId"));
	String[] ruleIds = request.getParameterValues("ruleId");
	String[] execOrders = request.getParameterValues("execOrder");

	int i=0;
	for(String rId : ruleIds)
	{
		String execOrder = execOrders[i++];
		String q = "update expert_system_rules set exec_order = ";
		if(parseNull(execOrder).equals("")) q += " NULL ";
		else  q += escape.cote(execOrder);
		q += " where id = " + escape.cote(rId);
		Etn.executeCmd(q);
	}
%>
{"RESPONSE":"SUCCESS"}
