<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ include file="common.jsp" %>

<%
	String phase = parseNull(request.getParameter("phase"));
	String process = parseNull(request.getParameter("process"));
	String loadedProcess = parseNull(request.getParameter("loadedProcess"));
	String profile = parseNull(request.getParameter("profile"));
	
	boolean deleteOtherHasAction = false;
	Set rsNextPhase = Etn.execute("select distinct start_phase, start_proc from rules where next_proc = "+escape.cote(process)+" and next_phase = "+escape.cote(phase));		
	
	if(!loadedProcess.equalsIgnoreCase(process))//means its an external process phase going to be deleted. So in this case just delete rules
	{
		Etn.executeCmd("delete from rules where start_proc = "+escape.cote(loadedProcess)+" and next_proc = "+escape.cote(process)+" and next_phase = "+escape.cote(phase));		
		Etn.executeCmd("delete from rules where start_proc = "+escape.cote(process)+" and next_proc = "+escape.cote(loadedProcess)+" and start_phase = "+escape.cote(phase));
		Etn.executeCmd("delete from external_phases where start_proc = "+escape.cote(loadedProcess)+" and next_proc = "+escape.cote(process)+" and next_phase = "+escape.cote(phase));
		deleteOtherHasAction = true;
	}
	else
	{
		Set rs = Etn.execute("select rulesVisibleTo from phases where process = "+escape.cote(process)+" and phase = "+escape.cote(phase));
		rs.next();
		java.util.StringTokenizer st = new java.util.StringTokenizer(rs.value("rulesVisibleTo"), "|");
		String newRulesVisibleTo = "";
		while(st.hasMoreTokens())
		{
			String curProf = st.nextElement().toString();					
			if(!curProf.equals(profile)) newRulesVisibleTo += curProf + "|";
		}
		
		if(newRulesVisibleTo.equals(""))
		{		
			Etn.executeCmd("delete from rules where start_proc = "+escape.cote(process)+" and start_phase = "+escape.cote(phase));
			Etn.executeCmd("delete from rules where next_proc = "+escape.cote(process)+" and next_phase = "+escape.cote(phase));						
			Etn.executeCmd("delete from phases where process = "+escape.cote(process)+" and phase = "+escape.cote(phase));
			Etn.executeCmd("delete from external_phases where next_proc = "+escape.cote(process)+" and next_phase = "+escape.cote(phase));
			Etn.executeCmd("delete from coordinates where process = "+escape.cote(process)+" and profile="+escape.cote(profile)+" and phase="+escape.cote(phase));
			Etn.executeCmd("delete from has_action where start_proc = "+escape.cote(process)+" and start_phase = "+escape.cote(phase));				
			deleteOtherHasAction = true;
		}
		else
		{
			newRulesVisibleTo = newRulesVisibleTo.substring(0, newRulesVisibleTo.lastIndexOf("|"));
			Etn.executeCmd("update phases set rulesVisibleTo = "+escape.cote(newRulesVisibleTo)+" where process = "+escape.cote(process)+" and phase = "+escape.cote(phase));
			Etn.executeCmd("delete from coordinates where process = "+escape.cote(process)+" and profile="+escape.cote(profile)+" and phase="+escape.cote(phase));
		}
	}	
	
	if(deleteOtherHasAction)
	{
		while(rsNextPhase.next())
		{
			Set rsRls = Etn.execute("select * from rules where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase")));
			if(rsRls.rs.Rows == 0) Etn.executeCmd("delete from has_action where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase")));
			else 
			{
				rsRls = Etn.execute("select * from rules where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase"))+" and priorite = 0 ");
				if(rsRls.rs.Rows == 0) //priorite 0 rule is deleted, then set priorite 0 for next rule and set its cle in has_action
				{
					rsRls = Etn.execute("select * from rules where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase"))+" order by cle ");
					rsRls.next();
					String cle = rsRls.value("cle");
					Etn.executeCmd("update rules set priorite = 0 where cle = "+escape.cote(cle));
					Etn.executeCmd("update has_action set cle = "+escape.cote(cle)+" where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase")));
				}
				else //this is a special case to handle as there can be many 0 priority rules (which should not happen but can in old data). So we check cle in has_action does exists in rules as well otherwise update in has_action
				{
					Set hasAction = Etn.execute("select * from has_action where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase")));
					if(hasAction.next())
					{
						String cle = hasAction.value("cle");
						rsRls = Etn.execute("select * from rules where cle = "+escape.cote(cle));
						if(rsRls.rs.Rows == 0)//means this cle is deleted and there are more with priority 0
						{
							rsRls = Etn.execute("select * from rules where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase"))+" and priorite = 0 order by cle ");
							rsRls.next();
							cle = rsRls.value("cle");
							Etn.executeCmd("update has_action set cle = "+escape.cote(cle)+" where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase")));
						}
					}
				}
			}
		}
	
	}
%>