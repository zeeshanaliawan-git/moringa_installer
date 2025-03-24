<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="/common.jsp" %>

<%
	String id = parseNull(request.getParameter("tid"));	
	Etn.executeCmd("delete from rlock where form_table_id  = "+escape.cote(id)+" and csr = "+escape.cote((String)session.getAttribute("LOGIN"))+" ");
%>