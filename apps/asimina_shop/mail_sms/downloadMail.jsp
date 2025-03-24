<%@ page import="java.io.*"%>
<%
	String lang=request.getParameter("lang");
	String mailId=request.getParameter("mailId");
	try {
		int nMailId = Integer.parseInt(mailId);
		String filename = "mail"+mailId;
		
		//cleanup lang parameter to be used in filename
		if(lang != null && lang.trim().length() > 0) filename += "_"+lang;
		
		System.out.println("filename:"+filename);
		filename = com.etn.asimina.util.FileUtil.sanitizePath(filename);
		System.out.println("filename after sanitizePath:"+filename);

		java.net.URL downloadFile = config.getServletContext().getResource("/mail_sms/mail/"+filename);		
		InputStream inputStream = downloadFile.openStream();
		OutputStream o = response.getOutputStream();

		try
		{
			response.setContentType("APPLICATION/OCTET-STREAM");
			response.setHeader("Content-Disposition", "attachment; filename=\""+filename+"\";");
			
			byte[] buffer = new byte[1024];
			int bytesRead = 0;
			do
			{
				bytesRead = inputStream.read(buffer, 0, buffer.length);
				o.write(buffer, 0, bytesRead);
			}
			while (bytesRead == buffer.length);

			o.flush();
		}
		finally
		{
			if(inputStream != null)
			{
				inputStream.close();
			}
			o.close();            
		}
	}
	catch(Exception e)
	{
		response.setContentType("text/html");
		out.write("<!DOCTYPE html><html><body>Invalid file ID</body></html>");
	}
%>
