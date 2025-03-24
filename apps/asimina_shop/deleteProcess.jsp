<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ include file="common.jsp" %>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>

<%
	String process = parseNull(request.getParameter("process"));
	Set rsNextPhase = Etn.execute("select distinct start_phase, start_proc from rules where next_proc = "+escape.cote(process));		
	
	Etn.executeCmd("delete from rules where start_proc = "+escape.cote(process));
	Etn.executeCmd("delete from rules where next_proc = "+escape.cote(process));
	Etn.executeCmd("delete from phases where process = "+escape.cote(process));	
	Etn.executeCmd("delete from processes where process_name = "+escape.cote(process));	
	Etn.executeCmd("delete from external_phases where start_proc = "+escape.cote(process));	
	Etn.executeCmd("delete from external_phases where next_proc = "+escape.cote(process));	
	Etn.executeCmd("delete from coordinates where process = "+escape.cote(process));	
	Etn.executeCmd("delete from has_action where start_proc = "+escape.cote(process));	
	
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
				Etn.executeCmd("update has_action set cle = '"+cle+"' where start_proc = "+escape.cote(rsNextPhase.value("start_proc"))+" and start_phase = "+escape.cote(rsNextPhase.value("start_phase")));
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
	
%>