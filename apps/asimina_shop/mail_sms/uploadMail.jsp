<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.io.DataInputStream"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.io.File,com.etn.sql.escape"%>

<%@ page import="java.util.*, java.io.*, org.json.*, com.etn.util.XSSHandler"%>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*, org.apache.tika.*, com.etn.util.Logger"%>

<%!
	String parseNull(Object o) {
		if( o == null ) return("");
		
		String s = o.toString();

		if("null".equals(s.trim().toLowerCase()))
			return("");
		else
			return(s.trim());
	}


%>

<%
	int s = 0;
	String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));
		
	try
	{
		FileItemFactory factory = new DiskFileItemFactory();
		ServletFileUpload upload = new ServletFileUpload(factory);

		List items = null;

		try
		{
			upload.setHeaderEncoding("UTF-8");
			items = upload.parseRequest(request);
		}
		catch (FileUploadException e)
		{
			e.printStackTrace();
		}
		Iterator itr = items.iterator();
		List<FileItem> files = new ArrayList<FileItem>();		
		
		Map<String, List<String>> incomingfields = new HashMap<String, List<String>>();
		Map<String, List<FileItem>> filesMap = new HashMap<String, List<FileItem>>();

		while (itr.hasNext())
		{
			FileItem item = (FileItem)(itr.next());

			if (item.isFormField())
			{
				String field=item.getFieldName();
				String value = XSSHandler.clean(item.getString("UTF-8"));
				if(incomingfields.containsKey(field) == false)
				{
					incomingfields.put(field, new ArrayList<String>());
				}
				incomingfields.get(field).add(value);
			}
			else
			{
				String field = item.getFieldName();
				if(filesMap.containsKey(field) == false)
				{
					filesMap.put(field, new ArrayList<FileItem>());
				}
				filesMap.get(field).add(item);
			}
		}//while

		//required fields
		if(incomingfields.get("mailId") == null)
		{
			response.sendRedirect("modele.jsp?s=1");
			return;
		}
		
		String mailId = incomingfields.get("mailId").get(0);		
		Logger.info("mail_sms/uploadMail.jsp", "mailId:"+mailId);
		//mailId must be numeric value
		try {
			int nMailId = Integer.parseInt(mailId);
		} catch(Exception e) {
			e.printStackTrace();
			response.sendRedirect("modele.jsp?s=1");
			return;
		}
		
		String subject = "";
		if(incomingfields.get("subject") != null)
		{
			subject = incomingfields.get("subject").get(0);
		}
		Logger.info("mail_sms/uploadMail.jsp", "subject:"+subject);
		
		String lang = "";
		if(incomingfields.get("lang") != null)
		{
			lang = incomingfields.get("lang").get(0);
		}		
		Logger.info("mail_sms/uploadMail.jsp", "lang:"+lang);
		Set rsLang = Etn.execute("select * from language where langue_code = " + escape.cote(lang));
		if(!rsLang.next())
		{
			com.etn.util.Logger.error("uploadMail.jsp","Invalid lang passed : " + lang);
			lang = "";
		}
		
		List<String> allowedTypes = new ArrayList<>();
		allowedTypes.add("application/xhtml+xml");
		allowedTypes.add("text/plain");
		allowedTypes.add("text/html");
		allowedTypes.add("application/mbox");
		
		FileItem uploadFile = null;
		if(filesMap.get("uploadFile") != null)
		{
			uploadFile = filesMap.get("uploadFile").get(0);
		}
		if(uploadFile != null)
		{
			String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(uploadFile.getInputStream()));
			Logger.info("mail_sms/uploadMail.jsp", "uploadFile mimetype:"+_type);
			if(allowedTypes.contains(_type.toLowerCase()) == false )
			{
				response.sendRedirect("modele.jsp?s=3");
				return;				
			}
		}
		
		//check if mail Id = 0 means we need to add a new row in mails table and then upload file
		boolean isError = false;
		if(mailId.equals("0"))
		{
			Set rs = Etn.execute("select * from mails where site_id="+escape.cote(siteId)+" and sujet = "+com.etn.sql.escape.cote(subject));
			if(rs.rs.Rows > 0)
			{
				s = 2;
				isError = true;
			}	
			else
			{
				int row = Etn.executeCmd("insert into mails (sujet, seq,site_id) values ("+com.etn.sql.escape.cote(subject)+",'0',"+escape.cote(siteId)+") ");
				mailId = "" + row;
			}
		}
		
		if(isError == false && uploadFile != null)
		{
			String filePath = com.etn.beans.app.GlobalParm.getParm("MAIL_UPLOAD_PATH");
			String filename = "mail"+mailId;
			if(lang != null && lang.trim().length() > 0) filename += "_"+lang;

			File destFile = com.etn.asimina.util.FileUtil.getFile(filePath, filename);
			uploadFile.write(destFile);
		}				
	}
	catch(Exception e)
	{
		e.printStackTrace();
		s = 1;
	}	
	response.sendRedirect("modele.jsp?s="+s);

%>
