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
			String qry = "select count(0) c from rules where errCode = "+escape.cote(errCode)+" and start_proc = '"+replaceQoute(sourceProcess)+"' and start_phase = '"+replaceQoute(sourcePhase)+"' and next_proc = '"+replaceQoute(targetProcess)+"' and next_phase = '"+replaceQoute(targetPhase)+"' ";
			Set rs = Etn.execute(qry);
			rs.next();
			if(Integer.parseInt(rs.value("c")) == 0) isOk = true;
		}
		
		if(isOk)
		{
//			Set rsAction = Etn.execute("select * from has_action where start_proc = '"+replaceQoute(sourceProcess)+"' and start_phase = '"+replaceQoute(sourcePhase)+"' ");
			Set rsAction = Etn.execute("select r.cle, a.action from has_action a, rules r where r.cle = a.cle and r.priorite = 0 and r.start_phase = a.start_phase and r.start_proc = a.start_proc and a.start_proc = '"+replaceQoute(sourceProcess)+"' and a.start_phase = '"+replaceQoute(sourcePhase)+"' ");			
			
			String ruleAction = "";
			if(rsAction.next()) ruleAction = parseNull(rsAction.value("action"));
		
			String qry = "select count(0) c from errcode where id = "+escape.cote(errCode)+" ";
			Set errRs = Etn.execute(qry);
			errRs.next();
			if(Integer.parseInt(errRs.value("c")) == 0)
			{
				Etn.executeCmd("insert into errcode (id, errNom, errMessage, errType, errCouleur) values("+escape.cote(errCode)+",'"+replaceQoute(errName)+"','"+replaceQoute(errMsg)+"',"+escape.cote(errType)+","+escape.cote(color)+" )");
			}
			else
			{	
				Etn.executeCmd("update errcode set errCouleur = "+escape.cote(color)+", errNom = '"+replaceQoute(errName)+"', errMessage = '"+replaceQoute(errMsg)+"', errType = "+escape.cote(errType)+" where id = "+escape.cote(errCode)+" ");
			}

			if(updateRule.equals("0"))
			{
				int priorite = 0;
				Set rsRules = Etn.execute("select * from rules where start_proc = '"+replaceQoute(sourceProcess)+"' and start_phase = '"+replaceQoute(sourcePhase)+"' ");
				if(rsRules.rs.Rows > 0 ) priorite = 1;
				qry = " insert into rules (start_proc, start_phase, errCode, next_proc, next_phase, action, priorite, nstate, rdv, type) "+
					" values ('"+replaceQoute(sourceProcess)+"','"+replaceQoute(sourcePhase)+"','"+replaceQoute(errCode)+"','"+replaceQoute(targetProcess)+"','"+replaceQoute(targetPhase)+"','"+replaceQoute(ruleAction)+"','"+priorite+"',"+escape.cote(nstate)+",'"+replaceQoute(connRdv)+"','"+replaceQoute(connType)+"') ";
			}
			else
				qry = "update rules set rdv = '"+replaceQoute(connRdv)+"', type = '"+replaceQoute(connType)+"', nstate = "+escape.cote(nstate)+", action = '"+replaceQoute(ruleAction)+"' where start_proc = '"+replaceQoute(sourceProcess)+"' and start_phase = '"+replaceQoute(sourcePhase)+"' and next_proc = '"+replaceQoute(targetProcess)+"' and next_phase = '"+replaceQoute(targetPhase)+"' and errCode = '"+replaceQoute(errCode)+"'";
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