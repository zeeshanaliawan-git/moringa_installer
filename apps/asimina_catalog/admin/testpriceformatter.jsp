<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>

<%@ include file="../../priceformatter.jsp"%>


<%
	String formatter = request.getParameter("formatter");

	String roundto = request.getParameter("roundto");
	String decimals = request.getParameter("decimals");
	String amnt = request.getParameter("amnt");

	out.write("{\"amnt\":\""+formatPrice(formatter, roundto, decimals, amnt)+"\"}");
%>