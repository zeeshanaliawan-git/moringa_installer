<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ include file="../common.jsp" %>

<%
	String supplierId = parseNull(request.getParameter("supplierId"));	
	String status = "ERROR";

	Set rs = Etn.execute("SELECT * FROM supplier WHERE id = " + escape.cote(supplierId));
	StringBuffer supplierDetail = new StringBuffer();

	if(rs.next())
	{
		supplierDetail.append("{");
		supplierDetail.append("\"supplier\":\"");
		supplierDetail.append(parseNull(rs.value("supplier")));
		supplierDetail.append("\",\"category\":\"");
		supplierDetail.append(parseNull(rs.value("category")));
		supplierDetail.append("\",\"address\":\"");
		supplierDetail.append(parseNull(rs.value("address")));
		supplierDetail.append("\",\"email\":\"");
		supplierDetail.append(parseNull(rs.value("email")));
		supplierDetail.append("\",\"phone_number\":\"");
		supplierDetail.append(parseNull(rs.value("phone_number")));
		supplierDetail.append("\",\"supplier_detail\":\"");
		supplierDetail.append(parseNull(rs.value("supplier_detail")));
		supplierDetail.append("\"}}");

		status = "SUCCESS";
	}

	out.write("{\"RESPONSE\":\""+status+"\",\"DATA\":"+supplierDetail+"");
%>
