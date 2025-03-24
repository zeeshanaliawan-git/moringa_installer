<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%> 

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="../common2.jsp" %>

<%
	String process = parseNull(request.getParameter("process"));
	String[] phase = request.getParameterValues("phase");
	String[] visibility = request.getParameterValues("visibility");
	String[] displayName1 = request.getParameterValues("displayName1");
	String[] displayName2 = request.getParameterValues("displayName2");
	String[] displayName3 = request.getParameterValues("displayName3");
	String[] displayName4 = request.getParameterValues("displayName4");
	String[] displayName5 = request.getParameterValues("displayName5");
        String query = "";
        boolean isError = false;

        for(int i=0; i<phase.length; i++){
            int r = Etn.executeCmd(query = "update phases set orderTrackVisible = "+escape.cote(visibility[i])+", displayName1 = "+escape.cote(displayName1[i])+
            ",displayName2 = "+escape.cote(displayName2[i])+",displayName3 = "+escape.cote(displayName3[i])+
            ",displayName4 = "+escape.cote(displayName4[i])+",displayName5 = "+escape.cote(displayName5[i])+
			" where process = "+escape.cote(process)+
            " and phase = " +escape.cote(phase[i]));
            
            if(r == 0) isError = true;
        }
            if(isError) out.write("{\"RESPONSE\":\"Error\"}");
            else out.write("{\"RESPONSE\":\"Success\"}");
%>

