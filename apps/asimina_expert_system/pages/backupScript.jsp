<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="java.io.*, com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.asimina.util.*"%>
<%@ include file="common.jsp" %>

<%
	String jsonid = parseNull(request.getParameter("jsonid"));
	try {
		int jj = Integer.parseInt(jsonid);
	} catch(Exception e) {
		out.write("{\"RESPONSE\":\"ERROR\",\"MSG\":\"Invalid ID \"}");
		return;
	}
	
	File fromFile = new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_"+CommonHelper.escapeCoteValue(jsonid)+".js");
	if(!fromFile.exists())
	{
		out.write("{\"RESPONSE\":\"ERROR\",\"MSG\":\"No script file found\"}");
	}
	else
	{
		FileInputStream from = null; // Stream to read from source
		FileOutputStream to = null; // Stream to write to destination
		String bkupFile = "expsys_ui_"+CommonHelper.escapeCoteValue(jsonid)+"_"+System.currentTimeMillis()+".js";
		File toFile = new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + bkupFile); 
		try
		{
			from = new FileInputStream(fromFile);
			to = new FileOutputStream(toFile);
			byte[] buffer = new byte[4096];
			int bytes_read;
			while ((bytes_read = from.read(buffer)) != -1) to.write(buffer, 0, bytes_read);
			Etn.executeCmd("update expert_system_json set last_backup = "+escape.cote(bkupFile)+" where id = " + escape.cote(jsonid));
		}
		finally {
			if (from != null)
				try {
					from.close();
				} catch (IOException e) {
				;
				}
			if (to != null)
				try {
					to.close();
				} catch (IOException e) {
				;
			}
		}
		out.write("{\"RESPONSE\":\"SUCCESS\",\"MSG\":\"Backup created \"}");
	}
%>