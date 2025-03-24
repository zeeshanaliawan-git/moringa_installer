<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.beans.app.GlobalParm"%>

<%@ page import="java.util.*, java.io.*, org.json.*, com.etn.util.XSSHandler"%>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*, org.apache.tika.*, com.etn.util.Logger"%>

<%@ include file="/common2.jsp" %>

<%
	StringBuffer output = new StringBuffer();

	String status = "SUCCESS";
	String message = "";

	String imageFileName = null;

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

	FileItem uploadFile = null;
	if(filesMap.get("imageFile") != null)
	{
		uploadFile = filesMap.get("imageFile").get(0);
	}
	if(uploadFile != null)
	{
		String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(uploadFile.getInputStream()));
		Logger.info("admin/ajax/uploadImage.jsp", "uploadFile mimetype:"+_type);
		ArrayList<String> allowedImageTypes = new ArrayList<>();
		allowedImageTypes.add("image/jpeg");
		allowedImageTypes.add("image/png");
		allowedImageTypes.add("image/gif");
		allowedImageTypes.add("image/svg+xml");
		allowedImageTypes.add("image/bmp");
		allowedImageTypes.add("image/tiff");
		
		if(allowedImageTypes.contains(_type.toLowerCase()) == false)
		{
			status = "ERROR";
			output.append("<center><span>Not a valid image file.</span></center>");
		}
	}
	else
	{
		status = "ERROR";
		output.append("<center><span>No image found.</span></center>");
	}
	
	if(status.equals("ERROR") == false)
	{
		String IMAGE_DIR = GlobalParm.getParm("UPLOAD_IMG_PATH");
		//IMPORTANT for XSS: cleanup filename as we use it to save file to disk
		imageFileName = uploadFile.getName().replaceAll("/", "").replaceAll("\\\\", "");
		Logger.info("admin/ajax/uploadImage.jsp","Saving image : "+IMAGE_DIR+imageFileName);
		File destFile = new File(IMAGE_DIR+imageFileName);
		uploadFile.write(destFile);
		
		String imagePath = GlobalParm.getParm("FORM_UPLOADS_PATH") + "images/";
		
        File imageFolder = new File(IMAGE_DIR);
        File[] listOfFiles = imageFolder.listFiles();

        if(listOfFiles.length == 0) output.append("<center><span>No image found.</span></center>");
        
        for (int i = 0; i < listOfFiles.length; i++) {

			if (listOfFiles[i].isFile()) 
			{
				String filename = listOfFiles[i].getName();

				output.append("<li onclick='update_selected_image(this)' style='height: 284px; width: 30%; float: left; margin: 15px; padding: 15px; border: 1px dotted silver; cursor: pointer;'>");
				output.append("<center> <span style='font-weight: bold; word-break: break-word;'>" + filename + "</span> <input type='hidden' value='" + filename + "'> </center> <br>");
				output.append("<center> <img src='" + imagePath+filename + "' style='max-height: 169px;'> </center> </li>");
			} 
        }
		
	}
	out.write("{ \"status\":\"" + status + "\",\"message\":\"" + message + "\",\"imageFileName\":\"" + imageFileName + "\",\"image_html\":\"" + output.toString() + "\"}");
%>