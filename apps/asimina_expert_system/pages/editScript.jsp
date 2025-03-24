<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, java.io.*, com.etn.beans.app.GlobalParm, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>
<%
	boolean fileFound = true;
	String txt = "";
	
	String msg = parseNull(request.getParameter("message"));
	String jsonid = parseNull(request.getParameter("jsonid"));
	try {
		int jj = Integer.parseInt(jsonid);
	} catch(Exception e) {
		fileFound = false;
	}
	
	if(fileFound)
	{
		File scrFile = new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_" + escapeCoteValue(jsonid) + ".js");
		if(scrFile.length() == 0) fileFound = false;

		BufferedReader br = null;
		try
		{
			br = new BufferedReader(new InputStreamReader(new FileInputStream(scrFile)));
			String line = null;
			while ((line = br.readLine()) != null) txt += line + "\n";
			br.close();
		}
		catch(Exception e)
		{
			fileFound = false;
			if(br != null) br.close();
		}
	}

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Expert System</title>

<link href="css/abcde.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" />

<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-ui-1.8.18.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

</head>
<body>
	<center>
	<% if(fileFound) { %>
		<form id='myform' action='saveScript.jsp' method='post'>
			<input type='hidden' value='<%=escapeCoteValue(jsonid)%>' name='jsonid' />
			<textarea id='txt' name='txt' rows='40' cols='150'><%=escapeCoteValue(txt)%></textarea>
			<input type='button' value='Save Script' id='savebtn' />
		</form>
	<% } else { %>
		<div style='margin-top:20px;font-weight:bold;color:red'>No script file found for edit</div>
	<% } %>
	</center>
</body>
	<script type="text/javascript">
		jQuery(document).ready(function() {
	
			<% if(!msg.equals("")) { %>
				alert('<%=escapeCoteValue(msg)%>');
			<% } %>

			$("#savebtn").click(function(){
				if(!confirm("Are you sure to update the script with this version?")) return;
				$("#myform").submit();
			});
		});
	</script>
</html>