<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape"%>

<%@ include file="common.jsp" %>


<%
	String resp = "SUCCESS";
	String message = "Saved successfully!!!";

	String jsonId = parseNull(request.getParameter("jsonId"));
	String[] outputTags = request.getParameterValues("outputTag");
	String[] htmlTagIds = request.getParameterValues("htmlTagId");

	if(outputTags != null)
	{
		int i= 0;
		for(String outputTag : outputTags)
		{
			String htmlTagId = parseNull(htmlTagIds[i++]);
			System.out.println("update expert_system_rules set html_tag_id = "+escape.cote(htmlTagId)+" where json_id = "+escape.cote(jsonId)+" and output_type = 'U' and output_tag = " + escape.cote(outputTag));
			Etn.executeCmd("update expert_system_rules set html_tag_id = "+escape.cote(htmlTagId)+" where json_id = "+escape.cote(jsonId)+" and output_type = 'U' and output_tag = " + escape.cote(outputTag));
		}
	}
	else message = "Nothing to save";

	out.write("{\"RESPONSE\":\""+resp+"\",\"MESSAGE\":\""+message+"\"}");
%>