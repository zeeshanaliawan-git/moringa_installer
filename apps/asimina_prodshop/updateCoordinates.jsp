<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ include file="common.jsp" %>


<%
	String isExternalPhase = parseNull(request.getParameter("isExternalPhase"));
	
	String reqStatus = "SUCCESS";
	if(!isExternalPhase.equals("1"))
	{
		String[] process = request.getParameterValues("process");		
		String[] phase = request.getParameterValues("phase");		
		String[] profile = request.getParameterValues("profile");		
		String[] isPhase = request.getParameterValues("isPhase");		
		String[] x = request.getParameterValues("topLeftX");  
		String[] y = request.getParameterValues("topLeftY");
		String[] w = request.getParameterValues("width");
		String[] h = request.getParameterValues("height");
		for(int i=0; i<process.length;i++)
		{
			int rows = 0;			
			Set rs = null;
			if(isPhase[i].equals("1"))
			{
				rs = Etn.execute("select * from coordinates where process = "+escape.cote(process[i])+" and phase = "+escape.cote(phase[i])+" and profile = "+escape.cote(profile[i])+" ");
				if(rs.rs.Rows == 0)
				{
					rows = Etn.executeCmd ("insert into coordinates (process, phase, profile, topLeftX, topLeftY, width, height) values ("+escape.cote(process[i])+","+escape.cote(phase[i])+","+escape.cote(profile[i])+","+escape.cote(x[i])+","+escape.cote(y[i])+","+escape.cote(w[i])+","+escape.cote(h[i])+")");
				}
				else
				{
					rows = Etn.executeCmd ("update coordinates set topLeftX = "+escape.cote(x[i])+", topLeftY = "+escape.cote(y[i])+", width = "+escape.cote(w[i])+", height = "+escape.cote(h[i])+" where process = "+escape.cote(process[i])+" and phase = "+escape.cote(phase[i])+" and profile = "+escape.cote(profile[i])+"  ");
				}
			}
			else
			{
				rs = Etn.execute("select * from coordinates where process = "+escape.cote(process[i])+" and profile = "+escape.cote(profile[i])+" and (phase is null or phase = '')");
				if(rs.rs.Rows == 0)
				{
					rows = Etn.executeCmd ("insert into coordinates (process, profile, topLeftX, topLeftY, width, height) values ("+escape.cote(process[i])+","+escape.cote(profile[i])+","+escape.cote(x[i])+","+escape.cote(y[i])+","+escape.cote(w[i])+","+escape.cote(h[i])+")");
				}
				else
				{
					rows = Etn.executeCmd ("update coordinates set topLeftX = "+escape.cote(x[i])+", topLeftY = "+escape.cote(y[i])+", width = "+escape.cote(w[i])+", height = "+escape.cote(h[i])+" where process = "+escape.cote(process[i])+" and (phase is null or phase = '') and profile = "+escape.cote(profile[i])+" ");
				}
			}
			if (rows == 0) reqStatus = "ERROR";
		}
	}
	else
	{		
		String startProc = parseNull(request.getParameter("startProc"));
		String nextProc = parseNull(request.getParameter("nextProc"));
		String nextPhase = parseNull(request.getParameter("nextPhase"));
		String x = request.getParameter("topLeftX");  
		String y = request.getParameter("topLeftY");
		String w = request.getParameter("width");
		String h = request.getParameter("height");
		if(isExternalPhase.equals("1"))
		{
			Set rs = Etn.execute("select * from external_phases where start_proc = "+escape.cote(startProc)+" and next_proc = "+escape.cote(nextProc)+" and next_phase = "+escape.cote(nextPhase)+" ");
			int rows = 0;
			if(rs.rs.Rows == 0) rows = Etn.executeCmd("insert into external_phases (start_proc, next_proc, next_phase, width, height, topLeftX, topLeftY) values ("+escape.cote(startProc)+","+escape.cote(nextProc)+","+escape.cote(nextPhase)+","+escape.cote(w)+","+escape.cote(h)+","+escape.cote(x)+","+escape.cote(y)+" )");
			else rows = Etn.executeCmd("update external_phases set width="+escape.cote(w)+", height="+escape.cote(h)+", topLeftX ="+escape.cote(x)+", topLeftY = "+escape.cote(y)+" where start_proc = "+escape.cote(startProc)+" and next_proc = "+escape.cote(nextProc)+" and next_phase = "+escape.cote(nextPhase)+" ");
			if (rows == 0) reqStatus = "ERROR";
		}
	}
%>
{"STATUS":"<%=reqStatus%>"}
