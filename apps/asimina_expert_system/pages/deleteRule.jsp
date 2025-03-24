<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>

<%
	String ruleId = request.getParameter("ruleId");
	if(ruleId == null) ruleId = "";

	String resp = "SUCCESS";
	String message = "Rule deleted successfully";

	Set rs = Etn.execute("select * from expert_system_rules where id = "+escape.cote(ruleId));
	rs.next();
	String deleteTag = rs.value("output_tag");
	String outputTagType = rs.value("output_type");

	if(outputTagType.equals("S")) deleteTag = "";//we are not going to remove this tag from display html tag table in ui

	int row = Etn.executeCmd("delete from expert_system_conditions where rule_id = "+escape.cote(ruleId));
	if(row > 0)
	{
		row = Etn.executeCmd("delete from expert_system_rules where id = "+escape.cote(ruleId));

		if(outputTagType.equals("U")) 
		{
			rs = Etn.execute("select * from expert_system_rules where output_tag = "+escape.cote(deleteTag));
			if(rs.rs.Rows > 0) deleteTag = "";//we are not going to remove this tag from display html tag table in ui
		}
	}
	if(row == 0)
	{
		resp = "ERROR";
		message = "There was some error while deleting the rule";
	}

%>
{"RESPONSE":"<%=resp%>", "MESSAGE":"<%=message%>", "REMOVE_OUTPUT_TAG":"<%=deleteTag%>"}