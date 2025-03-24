<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape" %>
<%@ include file="dashboardCommon.jsp" %>
<%@ include file="/common2.jsp" %>
<%
    String siteId = parseNull(session.getAttribute("SELECTED_SITE_ID"));
    JSONObject data =  getFunnelChartData(Etn,siteId,request.getParameter("start"), request.getParameter("end"),request.getParameter("catalogType"));
    out.write(data.toString());
%>