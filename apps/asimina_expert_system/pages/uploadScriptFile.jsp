<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set"%>
<%@ include file="common.jsp"%>

<%@ page import="com.etn.util.FormDataFilter, com.etn.asimina.util.CommonHelper"%>
<%@ page import="java.io.*"%>
<%@ page import="com.etn.sql.escape, com.etn.util.ItsDate, com.etn.beans.app.GlobalParm"%>

<%
	FileOutputStream fileOutput = null;
	String fileActualName="";
	String resp = "error";
	String msg =  "";
	String anyManualChanges = "0";

	String jsonid = parseNull(request.getParameter("jsonid"));
	try {
		int jj = Integer.parseInt(jsonid);
	} catch(Exception e) {
		out.write("{\"response\":\""+resp+"\",\"msg\":\""+"Invalid ID"+"\",\"any_manual_changes\":\""+anyManualChanges+"\"}");	
		return;
	}
	
	String saveFilepath = GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER");
	String filename="expsys_ui_" + CommonHelper.escapeCoteValue(jsonid) + ".js";
	
	FormDataFilter formData = new FormDataFilter(request.getInputStream());

	File dir = new File(saveFilepath);
	if(!dir.exists()) dir.mkdir();

	boolean isError = false;
	try
	{
       	while((formData.getField()) != null)
		{
			if(formData.isStream())
			{
				fileOutput = new FileOutputStream(saveFilepath + filename);
				formData.writeTo(fileOutput);
				fileOutput.close();
				resp = "success";
				msg = "File uploaded successfully!!!";
				Etn.executeCmd("update expert_system_json set script_file = "+escape.cote(filename)+" where id = " + escape.cote(jsonid));
			}
		}			
	}//end try
	catch(Exception e)
	{
		e.printStackTrace();
		if(fileOutput != null) fileOutput.close();
		resp = "error";
		msg = "Some error occurred while uploading the file";
		isError = true;
	}

	if(!isError)
	{
		String manualChangesScript = "";
		BufferedReader br = null;
		try
		{
			br = new BufferedReader(new InputStreamReader(new FileInputStream(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_"+CommonHelper.escapeCoteValue(jsonid)+".js")));
			String line = null;
			boolean manualStart = false;
			while ((line = br.readLine()) != null) {
				if(line.trim().equals("//</MANUAL_CHANGES>")) manualStart = false;
				if(manualStart)
				{
					manualChangesScript += line + "\n";
				}
				if(line.trim().equals("//<MANUAL_CHANGES>")) manualStart = true;
			}			
			br.close();
		}
		catch(Exception e)
		{
			if(br != null) br.close();
		}
		
		if(manualChangesScript.trim().length() > 0)
		{
			anyManualChanges = "1";
			Etn.executeCmd(" update expert_system_json set any_manual_changes = '"+anyManualChanges+"' where id = " + escape.cote(jsonid));
		}
	}	

	out.write("{\"response\":\""+resp+"\",\"msg\":\""+msg+"\",\"any_manual_changes\":\""+anyManualChanges+"\"}");	
%>
