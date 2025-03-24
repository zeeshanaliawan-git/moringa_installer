<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject"%>
<%@ include file="../common.jsp"%>

<%
    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	
	//source_id is the post_id of forum
	JSONObject obj = markDisliked(Etn, client, PortalHelper.parseNull(request.getParameter("source_id")), "forum");
	
    out.write(obj.toString());
%>