<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<%@ include file="apicall.jsp"%>

<%
	String brand = parseNull(request.getParameter("brand"));
	String model = parseNull(request.getParameter("model"));

	String json = requestDevice(brand, model);
	out.write(json);
%>

