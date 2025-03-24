<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set"%>

<%@ include file="common2.jsp" %>

<%
    // Request parameters
    String accountNumber = parseNull(request.getParameter("accountNumber"));
	if(!checkAccountNumber(accountNumber)){	
%>
ERROR
<% } else { %>
SUCCESS
<%}%>