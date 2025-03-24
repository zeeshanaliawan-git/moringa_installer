<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="../common2.jsp" %>

<%

	String process = parseNull(request.getParameter("process"));
	String phase = parseNull(request.getParameter("phase"));
	String screenName = parseNull(request.getParameter("screenName"));
	String fieldName = parseNull(request.getParameter("fieldName"));
	String action = parseNull(request.getParameter("action"));
	String isEditable = parseNull(request.getParameter("isEditable"));
	if(isEditable.equals("")) isEditable="0";
	String isMandatory = parseNull(request.getParameter("isMandatory"));
	if(isMandatory.equals("")) isMandatory="0";
	String isHidden = parseNull(request.getParameter("isHidden"));
	if(isHidden.equals("")) isHidden="0";
	
	boolean isError = false;
	int rows = 0;
	Set rs = Etn.execute("select count(0) as c from field_settings where process = " + escape.cote(process) + " and phase = "+escape.cote(phase)+" and screenName = "+escape.cote(screenName)+" and fieldName = "+escape.cote(fieldName)+" ");
	rs.next();
	if(Integer.parseInt(rs.value("c")) == 0)
	{
		rows = Etn.executeCmd("insert into field_settings(process, phase, screenName, fieldName) values ("+escape.cote(process)+","+escape.cote(phase)+","+escape.cote(screenName)+","+escape.cote(fieldName)+") ");
		if(rows == 0) isError = true;
	}
	if(!isError)
	{
		if(action.equals("CHANGE_HIDDEN"))
		{
                    System.out.println("asad");
			if (Integer.parseInt(isHidden) == 1) 
				rows = Etn.executeCmd("update field_settings set isHidden = "+escape.cote(isHidden)+", isEditable = 0, isMandatory = 0 where process = " + escape.cote(process) + " and phase = "+escape.cote(phase)+" and screenName = "+escape.cote(screenName)+" and fieldName = "+escape.cote(fieldName)+" ");
			else
				rows = Etn.executeCmd("update field_settings set isHidden = "+escape.cote(isHidden)+" where process = " + escape.cote(process) + " and phase = "+escape.cote(phase)+" and screenName = "+escape.cote(screenName)+" and fieldName = "+escape.cote(fieldName)+" ");
			if(rows == 0 ) isError = true;
		}
		else if(action.equals("CHANGE_EDITABLE"))
		{
			if (Integer.parseInt(isEditable) == 0) 
				rows = Etn.executeCmd("update field_settings set isEditable = "+escape.cote(isEditable)+", isMandatory = 0 where process = " + escape.cote(process) + " and phase = "+escape.cote(phase)+" and screenName = "+escape.cote(screenName)+" and fieldName = "+escape.cote(fieldName)+" ");
			else
				rows = Etn.executeCmd("update field_settings set isEditable = "+escape.cote(isEditable)+" where process = " + escape.cote(process) + " and phase = "+escape.cote(phase)+" and screenName = "+escape.cote(screenName)+" and fieldName = "+escape.cote(fieldName)+" ");
			if(rows == 0 ) isError = true;
		}
		else if(action.equals("CHANGE_MANDATORY"))
		{
			rows = Etn.executeCmd("update field_settings set isMandatory = "+escape.cote(isMandatory)+" where process = " + escape.cote(process) + " and phase = "+escape.cote(phase)+" and screenName = "+escape.cote(screenName)+" and fieldName = "+escape.cote(fieldName)+" ");
			if(rows == 0 ) isError = true;
		}
	}
%>

<% if(isError) { %>
{"RESPONSE":"ERROR"}
<% } else { %>
{"RESPONSE":"SUCCESS"}
<% } %>