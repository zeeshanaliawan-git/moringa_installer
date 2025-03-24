<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape"%>
<%@ page import="java.io.*, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>

<%@ include file="common.jsp" %>

<%
	String jsonid = parseNull(request.getParameter("jsonid"));
	String msg = "Script updated!!!";

	String script = parseNull(request.getParameter("txt"));

	FileOutputStream fos = null;
	boolean isError = false;
	try
	{
		fos = new FileOutputStream(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_"+CommonHelper.escapeCoteValue(jsonid)+".js");
		fos.write(script.getBytes("utf8"));
		fos.close();
	}
	catch(Exception e)
	{
		if(fos != null) fos.close();
		e.printStackTrace();	
		msg = "Some error occurred while saving the script";	
		isError = true;
	}

	String anyManualChanges = "0";
	if(!isError)
	{
		if(script.indexOf("<MANUAL_CHANGES>") > -1)
		{
			String s1 = script.substring(script.indexOf("//<MANUAL_CHANGES>") + 18);
			if(s1.indexOf("</MANUAL_CHANGES>") > -1)
			{
				s1 = s1.substring(0, s1.indexOf("//</MANUAL_CHANGES>"));
				if(s1.trim().length() > 0) anyManualChanges = "1";
			}
		}
		Etn.executeCmd("update expert_system_json set any_manual_changes = "+escape.cote(anyManualChanges)+" where id = " + escape.cote(jsonid));
	}	

//	response.sendRedirect("editScript.jsp?jsonid=" + CommonHelper.escapeCoteValue(jsonid) + "&message=" + CommonHelper.escapeCoteValue(msg));
%>

<script>
	if(opener && opener.showHideWarning) opener.showHideWarning('<%=anyManualChanges%>');
	window.location = "editScript.jsp?jsonid=<%=jsonid%>&message=<%=msg%>";
</script>
