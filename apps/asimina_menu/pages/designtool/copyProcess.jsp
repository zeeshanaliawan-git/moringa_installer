<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>

<%
	String process = parseNull(request.getParameter("process"));
	String copyAs = replaceQoute(parseNull(request.getParameter("copyAs")));
	String message = "";
	String status = "SUCCESS";
	
	boolean isError = false;
	String qry = "select count(0) as c from phases where process = "+escape.cote(copyAs)+" ";
	Set rs = Etn.execute(qry);
	rs.next();
	if(Integer.parseInt(rs.value("c")) > 0)
	{
		isError = true;
		message = "Process with the given name already exists";
		status = "ERROR";
	}
	
	if(!isError)
	{
		qry = " insert into phases (process, phase, type, text, stepNb, actors, activities, priority, execute, visc, isManual, displayName, rulesVisibleTo, oprType, reverse, topLeftX, topLeftY) " ;
		qry += " select '"+replaceQoute(copyAs)+"', phase, type, text, stepNb, actors, activities, priority, execute, visc, isManual, displayName, rulesVisibleTo, oprType, reverse, topLeftX, topLeftY ";
		qry += " from phases where process = '"+replaceQoute(process)+"'";
		Etn.executeCmd(qry);

		qry = " insert into rules (start_proc, start_phase, errCode, next_proc, next_phase, nstate, action, priorite, rdv, type) ";
		qry += " select '"+replaceQoute(copyAs)+"', start_phase, errCode, '"+replaceQoute(copyAs)+"', next_phase, nstate, action, priorite, rdv, type ";
		qry += " from rules where start_proc = next_proc and start_proc = '"+replaceQoute(process)+"' ";
		Etn.executeCmd(qry);

		qry = " insert into rules (start_proc, start_phase, errCode, next_proc, next_phase, nstate, action, priorite, rdv, type) ";
		qry += " select '"+replaceQoute(copyAs)+"', start_phase, errCode, next_proc, next_phase, nstate, action, priorite, rdv, type ";
		qry += " from rules where start_proc != next_proc and start_proc = '"+replaceQoute(process)+"' ";
		Etn.executeCmd(qry);

		qry = " insert into external_phases (start_proc, next_proc, next_phase, width, height, topLeftX, topLeftY) ";
		qry += " select '"+replaceQoute(copyAs)+"', next_proc, next_phase, width, height, topLeftX, topLeftY ";
		qry += " from external_phases where start_proc = '"+replaceQoute(process)+"'";
		Etn.executeCmd(qry);

		qry = " insert into coordinates (process, profile, phase, topLeftX, topLeftY, width, height) ";
		qry += " select '"+replaceQoute(copyAs)+"', profile, phase, topLeftX, topLeftY, width, height ";
		qry += " from coordinates where process = '"+replaceQoute(process)+"'" ;
		Etn.executeCmd(qry);

		Set rsNew = Etn.execute("select * from rules where start_proc = '"+replaceQoute(copyAs)+"' and priorite = 0");
		while(rsNew.next())
		{
			Etn.executeCmd("insert into has_action (start_proc, start_phase, cle, action) values ("+escape.cote(rsNew.value("start_proc"))+","+escape.cote(rsNew.value("start_phase"))+","+escape.cote(rsNew.value("cle"))+","+escape.cote(rsNew.value("action"))+")");
		}
		
		message = "Process copied successfully as "+copyAs;//dont change this message as its checked on processStatus.jsp to see if its error or not
	}
%>	
{"RESPONSE_STATUS":"<%=status%>","MESSAGE":"<%=message%>"}