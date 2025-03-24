<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>


<%
	String sourceProcess = parseNull(request.getParameter("sourceProcess"));
	String sourcePhase = parseNull(request.getParameter("sourcePhase"));
	String ruleAction = parseNull(request.getParameter("ruleAction"));
	
	Set rsAction = Etn.execute("select r.cle, a.action from has_action a, rules r where r.cle = a.cle and r.priorite = 0 and r.start_phase = a.start_phase and r.start_proc = a.start_proc and a.start_proc = "+escape.cote(sourceProcess)+" and a.start_phase = "+escape.cote(sourcePhase));
	int rows = 0;
	String cle = "";
	if(rsAction.rs.Rows == 0)
	{
		Set rsRules = Etn.execute("select * from rules where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" and priorite = 0 ");
		rsRules.next();
		cle = rsRules.value("cle");
		rows = Etn.executeCmd("insert into has_action(start_proc, start_phase, cle, action) values ("+escape.cote(sourceProcess)+","+escape.cote(sourcePhase)+","+escape.cote(cle)+","+escape.cote(ruleAction)+") ");
	}
	else
	{
		rsAction.next();
		cle = rsAction.value("cle");			
		rows = Etn.executeCmd("update has_action set action = "+escape.cote(ruleAction)+" where cle = "+escape.cote(cle)+" and start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)); 
	}
	if(rows > 0)
	{
		Etn.executeCmd("update rules set action  = "+escape.cote(ruleAction)+" where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)); 
		out.write("{\"STATUS\":\"SUCCESS\", \"MESSAGE\":\"Action updated successfully\"}");

		//check if has_action action is empty delete that row from it otherwise engine marks the flag and later if any action is added that wont be called on it
		rsAction = Etn.execute("select * from has_action a where a.cle = "+escape.cote(cle)+" and a.start_proc = "+escape.cote(sourceProcess)+" and a.start_phase = "+escape.cote(sourcePhase));
		if(rsAction.next() && parseNull(rsAction.value("action")).length() == 0)
		{
			Etn.execute("delete from has_action where cle = "+escape.cote(cle)+" and start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase));
		}

	}
	else
	{
		out.write("{\"STATUS\":\"ERROR\", \"MESSAGE\":\"Error while updating action\"}");
	}
	
%>