<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type"%>
<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%
        
        String orderId = parseNull(request.getParameter("orderId"));
        String email = parseNull(request.getParameter("email"));
        String query = "select * from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders where orderRef="+escape.cote(orderId)+" and (email="+escape.cote(email)+" or contactPhoneNumber1="+escape.cote(email)+")";
        Set rs = Etn.execute(query);
        if(rs.rs.Rows>0) out.write("{\"valid\":\"1\"}");
	else out.write("{\"valid\":\"0\"}"); 
%>