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
	String phase = parseNull(request.getParameter("phase"));
	String process = parseNull(request.getParameter("process"));
	String x = parseNull(request.getParameter("topLeftX"));  
	String y = parseNull(request.getParameter("topLeftY"));
	String width = parseNull(request.getParameter("width"));
	String height = parseNull(request.getParameter("height"));
	String profile = parseNull(request.getParameter("profile"));

	String message= "";
	String status = "SUCCESS";

	String qry = "select * from phases where process = "+escape.cote(process)+" and phase = "+escape.cote(phase)+"";
	Set rs = Etn.execute(qry);
	rs.next();
	java.util.StringTokenizer st = new java.util.StringTokenizer(rs.value("rulesVisibleTo"), "|");
	boolean found = false;
	while(st.hasMoreTokens())
	{
		String curProf = st.nextElement().toString();
		if(curProf.equals(profile)) 
		{
			found = true;
			break;
		}
	}
	if(found)
	{
		status = "ERROR";
		message= "Phase with given name already exists for this profile";
	}
	else
	{
		String rulesVisibleTo = rs.value("rulesVisibleTo") + "|" + profile;
		qry = "UPDATE phases SET";
		qry +=   " rulesVisibleTo="+escape.cote(rulesVisibleTo)+" ";
		qry +=   " WHERE process = "+escape.cote(process)+" AND phase = "+escape.cote(phase)+" ;";
			
		int rows = Etn.executeCmd(qry);
					
		if (rows == 0)
		{
			status = "ERROR"; 
			message = "Some error while copying phase";
		}	
		else
		{		
			Set rs1 = Etn.execute("select * from coordinates where process = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and profile = "+escape.cote(profile)+" ");
			if(rs1.rs.Rows == 0)
			{
				Etn.executeCmd("insert into coordinates (process, profile, phase, topLeftX, topLeftY, width, height) values ("+escape.cote(process)+","+escape.cote(profile)+","+escape.cote(phase)+","+escape.cote(x)+","+escape.cote(y)+","+escape.cote(width)+","+escape.cote(height)+")");				
			}
			else
			{
				Etn.executeCmd ("update coordinates set topLeftX = "+escape.cote(x)+", topLeftY = "+escape.cote(y)+", width = "+escape.cote(width)+", height = "+escape.cote(height)+" where process = "+escape.cote(process)+" and phase = "+escape.cote(phase)+" and profile = "+escape.cote(profile)+" ");
			}
			
		}
	}
%>
{"STATUS":"<%=status%>","MESSAGE":"<%=message%>"}