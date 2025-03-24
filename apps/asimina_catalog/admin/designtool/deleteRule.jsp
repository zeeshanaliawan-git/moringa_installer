<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ include file="common.jsp" %>

<%
	String sourcePhase = parseNull(request.getParameter("sourcePhase"));
	String targetPhase = parseNull(request.getParameter("targetPhase"));
	String sourceProcess = parseNull(request.getParameter("sourceProcess"));
	String targetProcess = parseNull(request.getParameter("targetProcess"));
	String errCode = parseNull(request.getParameter("errCode"));
	
	int rows = Etn.executeCmd("delete from rules where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" and next_proc = "+escape.cote(targetProcess)+" and next_phase = "+escape.cote(targetPhase)+" and errCode = "+escape.cote(errCode)+" ");

	Set rsRules = Etn.execute("select * from rules where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" ");
	if(rsRules.rs.Rows == 0)
	{
		Etn.executeCmd("delete from has_action where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" ");
	}
	else
	{
		rsRules = Etn.execute("select * from rules where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" and priorite = 0 ");
		if(rsRules.rs.Rows == 0) //priorite 0 rule is deleted, then set priorite 0 for next rule and set its cle in has_action
		{
			rsRules = Etn.execute("select * from rules where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" order by cle ");
			rsRules.next();
			String cle = rsRules.value("cle");
			Etn.executeCmd("update rules set priorite = 0 where cle = "+escape.cote(cle)+" ");
			Etn.executeCmd("update has_action set cle = "+escape.cote(cle)+" where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" ");
		}
		else //this is a special case to handle as there can be many 0 priority rules (which should not happen but can in old data). So we check cle in has_action does exists in rules as well otherwise update in has_action
		{
			Set hasAction = Etn.execute("select * from has_action where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" ");
			if(hasAction.next())
			{
				String cle = hasAction.value("cle");
				rsRules = Etn.execute("select * from rules where cle = "+escape.cote(cle)+"");
				if(rsRules.rs.Rows == 0)//means this cle is deleted and there are more with priority 0
				{
					rsRules = Etn.execute("select * from rules where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" and priorite = 0 order by cle ");
					rsRules.next();
					cle = rsRules.value("cle");
					Etn.executeCmd("update has_action set cle = "+escape.cote(cle)+" where start_proc = "+escape.cote(sourceProcess)+" and start_phase = "+escape.cote(sourcePhase)+" ");
				}
			}
		}
	}
	
%>