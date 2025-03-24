<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set"%>
<%@ include file="/common.jsp"%>
<%@ page import="com.etn.sql.escape, com.etn.util.ItsDate, com.etn.util.*, com.etn.beans.app.GlobalParm,com.etn.util.Base64, com.etn.asimina.util.*"%>
<%@page import="java.io.*"%>

<%
	Etn.setSeparateur(2, '\001', '\002');
	
    String jsonId = parseNull(request.getParameter("jsonId"));
    String quuid = parseNull(request.getParameter("qid"));
    String suid = parseNull(request.getParameter("suid"));
    String cid = parseNull(request.getParameter("cid"));

    response.setContentType("application/json");

    if(jsonId.length() > 0){
%>
        <jsp:include page="fetchdatav1.jsp" >  
            <jsp:param name="jsonId" value="<%=CommonHelper.escapeCoteValue(jsonId)%>" />  
        </jsp:include> 
<%
    } else if(quuid.length() > 0){
%>
        <jsp:include page="fetchdatav2.jsp" >  
            <jsp:param name="qid" value="<%=CommonHelper.escapeCoteValue(quuid)%>" />  
        </jsp:include> 
<%
    } else if(suid.length() > 0 && cid.length() > 0){
%>
        <jsp:include page="fetchdatav2.jsp" >  
            <jsp:param name="suid" value="<%=CommonHelper.escapeCoteValue(suid)%>" />  
            <jsp:param name="cid" value="<%=CommonHelper.escapeCoteValue(cid)%>" />  
        </jsp:include> 
<%
    }
%>

