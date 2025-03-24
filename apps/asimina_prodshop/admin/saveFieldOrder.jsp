<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="../common2.jsp" %>

<%

	String[] id = request.getParameterValues("fieldId");
	String[] fieldDisplaySeq = request.getParameterValues("fieldDisplaySeq");

        for(int i=0; i<id.length; i++){
            Etn.executeCmd("update field_names set fieldDisplaySeq = "+escape.cote(fieldDisplaySeq[i])+" where id="+escape.cote(id[i]));
            //out.write(fieldDisplaySeq[i]+id[i]);
        }
%>