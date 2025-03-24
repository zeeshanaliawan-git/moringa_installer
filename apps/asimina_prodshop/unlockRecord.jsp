<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>

<%
	String customerId = parseNull(request.getParameter("customerId"));	
	String form_id = parseNull(request.getParameter("form_id"));	

	String id = customerId;
	String is_generic_form = "0";	
	if(form_id.length() > 0)
	{
		is_generic_form = "1";
		id = form_id;
	}

	Etn.executeCmd("delete from rlock where is_generic_form = "+escape.cote(is_generic_form)+" and id  = "+escape.cote(id)+" and csr = "+escape.cote((String)session.getAttribute("LOGIN"))+" ");
%>