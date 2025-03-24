<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page  import="java.io.FileInputStream" %>
<%@ page  import="java.io.InputStream" %>
<%@ page  import="java.io.BufferedInputStream"  %>
<%@ page  import="java.io.File, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"  %>

<%@ include file="common.jsp"%>

<%
	String jsonid = parseNull(request.getParameter("jsonid"));
	try {
		int jj = Integer.parseInt(jsonid);
	} catch(Exception e) {
		response.setContentType("text/plain");
		out.write("invalid id");
		return;		
	}
		
		
	String filetype = parseNull(request.getParameter("filetype"));

	Set rs = Etn.execute("select * from expert_system_json where id = " + escape.cote(jsonid));
	rs.next();
	
	
	String filepath = GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER");
	String filename = parseNull(rs.value("script_file"));
	String actualfilename = filename;
	if(filetype.equals("2")) 
	{
		actualfilename = filename.substring(0, filename.lastIndexOf(".")) + "_backup.js";
		filename = parseNull(rs.value("last_backup"));
	}
	else if(filetype.equals("generatedHtml")) 
	{
		filepath = GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_JSP_FOLDER");
		actualfilename = "html_" + CommonHelper.escapeCoteValue(jsonid) + ".jsp";
		filename = "html_" + CommonHelper.escapeCoteValue(jsonid) + ".jsp";
	}
	
	BufferedInputStream buf=null;
	ServletOutputStream myOut=null;

	try
	{

		File myfile = new File(filepath+filename);
		FileInputStream input = new FileInputStream(myfile);
		//set response headers
		myOut = response.getOutputStream( );

		response.setContentType("APPLICATION/OCTET-STREAM");

		response.addHeader("Content-Disposition","attachment; filename="+actualfilename);

		response.setContentLength( (int) myfile.length( ) );
		
		buf = new BufferedInputStream(input);
		int readBytes = 0;

		//read from the file; write to the ServletOutputStream
		while((readBytes = buf.read( )) != -1)
			myOut.write(readBytes);
		if (myOut != null)
			myOut.close( );
		if (buf != null)
			buf.close( );         
	} 
	catch (Exception e)
	{   
		request.setAttribute("exception",e);
		if (myOut != null)
			myOut.close( );
		if (buf != null)
			buf.close( );         
	}
%>