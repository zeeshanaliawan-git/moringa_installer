<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>
 
<%
	String action = parseNull(request.getParameter("action"));
	String phase = parseNull(request.getParameter("phase"));
	String displayName = parseNull(request.getParameter("displayName"));
	String process = parseNull(request.getParameter("process"));
	String x = parseNull(request.getParameter("topLeftX"));  
	String y = parseNull(request.getParameter("topLeftY"));
	String priority = parseNull(request.getParameter("priority"));
	String execute = parseNull(request.getParameter("execute"));
	String actors = parseNull(request.getParameter("actors"));
	String visible = parseNull(request.getParameter("visible"));
	String currentProfile = parseNull(request.getParameter("currentProfile"));
	String isReverse = parseNull(request.getParameter("isReverse"));
	String oprType = parseNull(request.getParameter("oprType"));
	String width = parseNull(request.getParameter("width"));
	String height = parseNull(request.getParameter("height"));
	if(visible.equals("")) visible = "0";
	if(isReverse.equals("")) isReverse = "0";
	
	if(oprType.equals("")) oprType = "O";
	
	if(isReverse.equals("1")) isReverse = "R";
	else isReverse = "S";
	String message= "";
	String status = "SUCCESS";
	if(action.equals("new"))
	{
		String qry = "select * from phases where process = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" ";
		Set rs = Etn.execute(qry);
		if(rs.rs.Rows > 0)
		{
			status = "ERROR";
			message= "Phase with given name already exists";
		}
		else
		{
			qry= "insert into phases (process, phase, displayName, topLeftX, topLeftY,actors,priority,execute, visc, rulesVisibleTo, reverse, oprType) values ("+escape.cote(process)+","+escape.cote(phase)+","+escape.cote(displayName)+","+escape.cote(x)+","+escape.cote(y)+","+escape.cote(actors)+","; 
			if(priority.equals(""))
				qry += "NULL";
			else 
				qry += " "+escape.cote(priority)+" ";
			
			qry += ", "+escape.cote(execute)+","+escape.cote(visible)+","+escape.cote(currentProfile)+","+escape.cote(isReverse)+","+escape.cote(oprType)+")";	
			
			int rows = Etn.executeCmd(qry);
		
			if (rows == 0)
			{
				status = "ERROR"; 
				message = "Some error occured while adding new phase";
			} 
			else
			{
				
				Set rs1 = Etn.execute("select * from coordinates where process = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and profile = "+escape.cote(currentProfile)+" ");
				if(rs1.rs.Rows == 0)
				{
					Etn.executeCmd("insert into coordinates (process, profile, phase, topLeftX, topLeftY, width, height) values ("+escape.cote(process)+","+escape.cote(currentProfile)+","+escape.cote(phase)+","+escape.cote(x)+","+escape.cote(y)+","+escape.cote(width)+","+escape.cote(height)+")");
				}
				else
				{
					Etn.executeCmd ("update coordinates set topLeftX = "+escape.cote(x)+", topLeftY = "+escape.cote(y)+", width = "+escape.cote(width)+", height = "+escape.cote(height)+" where process = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and profile = "+escape.cote(currentProfile)+" ");
				}
				
			}			
		}
	}
	else if(action.equals("edit"))
	{
		String oldPhase = parseNull(request.getParameter("oldPhase"));
		
		boolean phaseNameError = false;
		if(!(oldPhase).equals((phase)))
		{
			String qry = "select count(0) c from phases where process = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" ";
			Set rs = Etn.execute(qry);
			rs.next();
			if(Integer.parseInt(rs.value("c")) > 0)
			{
				phaseNameError = true;
			}
		}
		
		if(!phaseNameError)
		{
			String qry = "UPDATE phases SET";
				qry +=   " phase="+escape.cote(phase)+" ";
				qry +=   ", displayName="+escape.cote(displayName)+" ";
				qry +=   ", actors="+escape.cote(actors)+" ";
				qry +=   ", visc="+escape.cote(visible)+"";
				if(priority.equals(""))
					qry +=   ", priority=NULL";
				else
					qry +=   ", priority="+escape.cote(priority)+" ";
				qry +=   ", execute="+escape.cote(execute)+" ";
				qry += ", reverse = "+escape.cote(isReverse)+" ";
				qry += ", oprType = "+escape.cote(oprType)+" ";
				qry +=   " WHERE process = "+escape.cote(process)+" AND phase = "+escape.cote(oldPhase)+" ";
				
				int rows = Etn.executeCmd(qry);
					
				if (rows > 0)
				{
					Etn.executeCmd("UPDATE rules SET start_phase = "+escape.cote(phase)+" where start_proc = "+escape.cote(process)+" and start_phase = "+escape.cote(oldPhase)+" ");
					Etn.executeCmd("UPDATE rules SET next_phase = "+escape.cote(phase)+" where next_proc = "+escape.cote(process)+" and next_phase = "+escape.cote(oldPhase)+" ");								
					Etn.executeCmd("UPDATE post_work set phase = "+escape.cote(phase)+" where proces = "+escape.cote(process)+" and phase = "+escape.cote(oldPhase)+" ");
					Etn.executeCmd("UPDATE external_phases SET next_phase = "+escape.cote(phase)+" where next_proc = "+escape.cote(process)+" and next_phase = "+escape.cote(oldPhase)+" ");								
					
					
					Set rsRulesVisible = Etn.execute("select rulesVisibleTo from phases WHERE process = "+escape.cote(process)+" AND phase = "+escape.cote(phase)+" ");
					rsRulesVisible.next();
					java.util.StringTokenizer st = new java.util.StringTokenizer(rsRulesVisible.value("rulesVisibleTo"), "|");
					while(st.hasMoreTokens())
					{
						String curProf = st.nextElement().toString();					
						Etn.executeCmd("update coordinates set phase = "+escape.cote(phase)+" where process = "+escape.cote(process)+" and profile ="+escape.cote(curProf)+" and phase="+escape.cote(oldPhase)+" ");
					}
					
					Etn.executeCmd("update has_action set start_phase = "+escape.cote(phase)+" where start_proc = "+escape.cote(process)+" and start_phase = "+escape.cote(oldPhase)+" ");													
				} 
				else
				{
					status = "ERROR"; 
					message = "Some error occured while updating phase";
				}	
		}
		else
		{
			status = "ERROR"; 
			message = "Phase with given name already exists";
		}
	}
%>
{"STATUS":"<%=status%>","MESSAGE":"<%=message%>"}