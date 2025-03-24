<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, java.io.File, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>

<%@ include file="common.jsp" %>
<%
	String jsonid = parseNull(request.getParameter("jsonid"));
	try {
		int jj = Integer.parseInt(jsonid);
	} catch(Exception e) {
		out.write("{\"RESPONSE\":\"ERROR\"}");
		return;
	}
	
	Etn.executeCmd("delete from expert_system_script where json_id = " + escape.cote(jsonid));
	Etn.executeCmd("update expert_system_json set last_backup = '', script_file = '' where id = " + escape.cote(jsonid));

	File file = new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_"+CommonHelper.escapeCoteValue(jsonid)+".js");
	if(file.exists())
	{
		//backup the file
		String bkupFile = "expsys_ui_"+CommonHelper.escapeCoteValue(jsonid)+"_"+System.currentTimeMillis()+".js";
		File file2 = new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + bkupFile); 
		boolean success = file.renameTo(file2);
		if(success) Etn.executeCmd("update expert_system_json set last_backup = "+escape.cote(bkupFile)+" where id = " + escape.cote(jsonid));
	}
%>
{"RESPONSE":"SUCCESS"}