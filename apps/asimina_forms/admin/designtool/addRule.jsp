<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>

<%
	String status = "SUCCESS";
	String message = "";
	try
	{
		String sourcePhase = parseNull(request.getParameter("sourcePhase"));
		String targetPhase = parseNull(request.getParameter("targetPhase"));
		String sourceProcess = parseNull(request.getParameter("sourceProcess"));
		String targetProcess = parseNull(request.getParameter("targetProcess"));
		String errCode = parseNull(request.getParameter("errCode"));
		String errName = parseNull(request.getParameter("errName"));
		String errMsg = parseNull(request.getParameter("errMsg"));
		String errType = parseNull(request.getParameter("errType"));
		String color = parseNull(request.getParameter("errColor"));
		String updateRule = parseNull(request.getParameter("updateRule"));
		String nstate = parseNull(request.getParameter("nextestado"));
		String connType = parseNull(request.getParameter("connType"));
		String connRdv = parseNull(request.getParameter("connRdv"));
		
		if(nstate.equals("")) nstate = "0";

		color = "#" + color;

		//verify nstate
		boolean isOk = true;
		if(updateRule.equals("0"))
		{
			isOk = false;
			String qry = "select count(0) c from rules where errCode = "+escape.cote(errCode)+" and start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" and next_proc = "+escape.cote(targetProcess)+" and next_phase = "+escape.cote(targetPhase)+" ";
			Set rs = Etn.execute(qry);
			rs.next();
			if(Integer.parseInt(rs.value("c")) == 0) isOk = true;
		}
		
		if(isOk)
		{
//			Set rsAction = Etn.execute("select * from has_action where start_proc = "+escape.cote(sourceProcess)+"' and start_phase = '"+escape.cote(sourcePhase)+"' ");
			Set rsAction = Etn.execute("select r.cle, a.action from has_action a, rules r where r.cle = a.cle and r.priorite = 0 and r.start_phase = a.start_phase and r.start_proc = a.start_proc and a.start_proc = "+escape.cote(sourceProcess)+" and a.start_phase = "+escape.cote(sourcePhase)+" ");			
			
			String ruleAction = "";
			if(rsAction.next()) ruleAction = parseNull(rsAction.value("action"));
		
			String qry = "select count(0) c from errcode where id = "+escape.cote(errCode)+" ";
			Set errRs = Etn.execute(qry);
			errRs.next();
			if(Integer.parseInt(errRs.value("c")) == 0)
			{
				Etn.executeCmd("insert into errcode (id, errNom, errMessage, errType, errCouleur) values("+escape.cote(errCode)+","+escape.cote(errName)+","+escape.cote(errMsg)+","+escape.cote(errType)+","+escape.cote(color)+" )");
			}
			else
			{	
				Etn.executeCmd("update errcode set errCouleur = "+escape.cote(color)+", errNom = "+escape.cote(errName)+", errMessage = "+escape.cote(errMsg)+", errType = "+escape.cote(errType)+" where id = "+escape.cote(errCode)+" ");
			}

			if(updateRule.equals("0"))
			{
				int priorite = 0;
				Set rsRules = Etn.execute("select * from rules where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" ");
				if(rsRules.rs.Rows > 0 ) priorite = 1;
				qry = " insert into rules (start_proc, start_phase, errCode, next_proc, next_phase, action, priorite, nstate, rdv, type) "+
					" values ("+escape.cote(sourceProcess)+","+escape.cote(sourcePhase)+","+escape.cote(errCode)+","+escape.cote(targetProcess)+","+escape.cote(targetPhase)+","+escape.cote(ruleAction)+","+priorite+","+escape.cote(nstate)+","+escape.cote(connRdv)+","+escape.cote(connType)+") ";
			}
			else
				qry = "update rules set rdv = "+escape.cote(connRdv)+", type = "+escape.cote(connType)+", nstate = "+escape.cote(nstate)+", action = "+escape.cote(ruleAction)+" where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" and next_proc = "+escape.cote(targetProcess)+" and next_phase = "+escape.cote(targetPhase)+" and errCode = "+escape.cote(errCode)+"";
			int rows = Etn.executeCmd(qry);
			if(rows <= 0)
			{
				status = "ERROR";
				message = "Some error occurred while adding/updating rule";
			}
		}
		else
		{
			status = "ERROR";
			message = "Rule already exists for Start Proc: "+sourceProcess+", Start Phase: "+sourcePhase+", Next Proc: "+targetProcess+", Next Phase: "+targetPhase+", Err Code: "+errCode;
		}
	} 
	catch (Exception e) { 
	e.printStackTrace();
		status = "ERROR";
		message = "Some error occurred while adding new rule";
	} 
%>
{"STATUS":"<%=status%>","MESSAGE":"<%=message%>"}