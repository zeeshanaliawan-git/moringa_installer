<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.sql.escape, java.util.*, java.net.*, javax.servlet.http.Cookie"%>
<%@ page import="java.io.*, org.json.*, com.etn.asimina.cart.*, com.etn.asimina.beans.*, com.etn.asimina.util.*, com.etn.util.XSSHandler"%>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*, org.apache.tika.*, com.etn.util.Logger"%>

<%!
	String getSingleFieldValue(Map<String, List<String>> incomingfields, String fieldName)
	{
		if(incomingfields == null) return null;
		if(incomingfields.get(fieldName) == null) return null;
		if(incomingfields.get(fieldName).size() == 0) return null;
		return incomingfields.get(fieldName).get(0);
	}

%>
<%
	Logger.info("updatecheckout.jsp", "In updatecheckout");

	String ___muuid = CartHelper.getCartMenuUuid(request);
	String session_id = CartHelper.getCartSessionId(request);
	
	Set menuRs = Etn.execute("select * from site_menus where menu_uuid="+escape.cote(___muuid));
	menuRs.next();
	String siteid = menuRs.value("site_id");
	String mlang = menuRs.value("lang");
	
	Map<String, AdditionalInfoField> additionalFieldsMetaData = new HashMap<String, AdditionalInfoField>();
	Set rsAddFields = Etn.execute("select f.*, s.name as section_name, s.display_name as section_display_name from checkout_add_info_fields f inner join checkout_add_info_sections s on s.id = f.section_id and s.site_id = "+escape.cote(siteid));
	while(rsAddFields.next())
	{
		AdditionalInfoField aif = new AdditionalInfoField();
		aif.name = PortalHelper.parseNull(rsAddFields.value("name"));
		aif.displayName = PortalHelper.parseNull(rsAddFields.value("display_name"));
		aif.sectionName = PortalHelper.parseNull(rsAddFields.value("section_name"));
		aif.sectionDisplayName = PortalHelper.parseNull(rsAddFields.value("section_display_name"));
		aif.ftype = PortalHelper.parseNull(rsAddFields.value("ftype"));
		if(PortalHelper.parseNull(rsAddFields.value("file_allowed_types")).length() > 0)
		{
			aif.allowedTypes = new ArrayList<String>(Arrays.asList(PortalHelper.parseNull(rsAddFields.value("file_allowed_types")).split(";")));
		}		
		additionalFieldsMetaData.put(aif.name, aif);
	}
	
	com.etn.asimina.util.LanguageHelper.getInstance().set_lang(Etn, mlang);

	Set rsCart = Etn.execute("select * from cart WHERE session_id = "+ escape.cote(session_id)+" and site_id="+escape.cote(siteid));
	rsCart.next();
	String cartuuid = rsCart.value("uuid");
			
	int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

	int status = STATUS_ERROR;
	String message = "";
	JSONObject data = new JSONObject();

	String q = "";
	Set rs = null;
	boolean identityPhotoUploaded = false;
	JSONArray errors = new JSONArray();
	
	ArrayList<String> identityPhotoFileTypes = new ArrayList<>();
	identityPhotoFileTypes.add("image/jpeg");
	identityPhotoFileTypes.add("image/png");
	identityPhotoFileTypes.add("image/gif");
	identityPhotoFileTypes.add("image/svg+xml");
	identityPhotoFileTypes.add("image/bmp");
	identityPhotoFileTypes.add("image/tiff");
	identityPhotoFileTypes.add("application/pdf");

	String sendKeepEmail = "";

	try {
		String UPLOAD_DIR = GlobalParm.getParm("funnel_documents_base_dir");	
		File dir = new File(UPLOAD_DIR);
		if (!dir.exists()) {
			dir.mkdir();
		}
		if(UPLOAD_DIR.endsWith("/") == false) UPLOAD_DIR += "/";

		//note:cart_documents is also hardcoded in dev_shop/customerEdit.jsp
		String identityPhotoDir = UPLOAD_DIR + "cart_documents/";
		dir = new File(identityPhotoDir);
		if (!dir.exists()) {
			dir.mkdir();
		}

		
		// get max possible size
		long maxFileSize = 10 * 1024 * 1024;

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

		Map<String, List<String>> incomingAdditionalInfofields = new HashMap<String, List<String>>();
		Map<String, List<String>> incomingfields = new HashMap<String, List<String>>();
		Map<String, List<FileItem>> filesMap = new HashMap<String, List<FileItem>>();
		Map<String, List<FileItem>> additionalInfoFilesMap = new HashMap<String, List<FileItem>>();
		
		while (itr.hasNext())
		{
			FileItem item = (FileItem)(itr.next());

			if (item.isFormField())
			{
				String field=item.getFieldName();
				String value = XSSHandler.clean(item.getString("UTF-8"));
				if(additionalFieldsMetaData.get(field) == null)
				{
					if(incomingfields.containsKey(field) == false)
					{
						incomingfields.put(field, new ArrayList<String>());
					}
					incomingfields.get(field).add(value);
				}
				else
				{
					if(incomingAdditionalInfofields.containsKey(field) == false)
					{
						incomingAdditionalInfofields.put(field, new ArrayList<String>());
					}
					incomingAdditionalInfofields.get(field).add(value);					
				}
			}
			else
			{
				String field = item.getFieldName();
				if(additionalFieldsMetaData.get(field) == null)
				{
					if(filesMap.containsKey(field) == false)
					{
						filesMap.put(field, new ArrayList<FileItem>());
					}
					filesMap.get(field).add(item);
				}
				else
				{
					if(additionalInfoFilesMap.containsKey(field) == false)
					{
						additionalInfoFilesMap.put(field, new ArrayList<FileItem>());
					}
					additionalInfoFilesMap.get(field).add(item);					
				}
			}
		}//while
		
		FileItem identityPhotoFile = null;
		if(filesMap.get("identityPhoto") != null && filesMap.get("identityPhoto").size() > 0)
		{
			identityPhotoFile = filesMap.get("identityPhoto").get(0);
		}
		
		String[] identityPhotoAllowedExtensions = new String[]{"jpeg", "jpg", "png", "gif", "bmp", "tif", "tiff", "svg", "pdf"};
		
		String updateParameters = "";
		

		if(identityPhotoFile != null && identityPhotoFile.getName().length() > 0)
		{
			String fileName = identityPhotoFile.getName();
			String fileExtension = "";
			int dotIndex = fileName.lastIndexOf(".");
			if (dotIndex > 0 && (dotIndex + 1) < fileName.length()) {
				fileExtension = PortalHelper.parseNull(fileName.substring(dotIndex + 1));
			}                

			boolean fileTypeFound = false;
			if (identityPhotoAllowedExtensions.length > 0) {
				for (String curAllowedType : identityPhotoAllowedExtensions) {
					if (curAllowedType.equals(fileExtension.toLowerCase())) {
						fileTypeFound = true;
						break;
					}
				}
			}

			if (!fileTypeFound) {
				throw new Exception("Error: Unsupported File extension '" + fileExtension + "' for identity photo ");
			}
			
			String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(identityPhotoFile.getInputStream()));

			if (identityPhotoFileTypes.contains(_type) == false) {
				throw new Exception("Error: Unsupported File uploaded for identity photo");
			}
			
			String fileUuid = java.util.UUID.randomUUID().toString();
			int fileId = Etn.executeCmd("insert into files set file_name="+escape.cote(identityPhotoFile.getName())+" , file_uuid="+escape.cote(fileUuid)+" , file_extension="+escape.cote(fileExtension));
			if(fileId>0){
				File destFile = new File(identityPhotoDir + fileUuid+"."+fileExtension);
				identityPhotoFile.write(destFile);
				updateParameters += " identityPhoto = " + escape.cote(fileUuid);
				identityPhotoUploaded = true;
			}
		}
		//verify all uploaded files first
		if(additionalInfoFilesMap != null)
		{
			for(String field : additionalInfoFilesMap.keySet())
			{
				AdditionalInfoField aif = additionalFieldsMetaData.get(field);
				if(aif != null)
				{
					boolean isValid = PortalHelper.isAdditionalFileValid(aif, additionalInfoFilesMap.get(field));
					if(isValid == false)
					{
						throw new Exception("Error:: File type not supported for field : " + aif.displayName);
					}
				}
			}
		}
		
		ArrayList<String> excludeCols = new ArrayList<String>();
		excludeCols.add("id");
		excludeCols.add("client_id");
		excludeCols.add("session_id"); 
		excludeCols.add("emailConfirmation");
		excludeCols.add("session_token"); 
		excludeCols.add("hostUrl");
		excludeCols.add("grandTotal");
		excludeCols.add("existingIdentityPhoto");
				
		if(!identityPhotoUploaded && PortalHelper.parseNull(getSingleFieldValue(incomingfields, "existingIdentityPhoto")).length()>0) updateParameters += " identityPhoto = " + escape.cote(PortalHelper.parseNull(getSingleFieldValue(incomingfields, "existingIdentityPhoto")));
		for(String parameter : incomingfields.keySet())
		{
			if(parameter.equals("sendKeepEmail")) sendKeepEmail = PortalHelper.parseNull(getSingleFieldValue(incomingfields, parameter));
			if(excludeCols.contains(parameter)) continue;
					
			if(!updateParameters.equals("")) updateParameters += ",";
			updateParameters += parameter + " = " + escape.cote(PortalHelper.parseNull(getSingleFieldValue(incomingfields, parameter)));			
		}
		
		JSONObject jAddInfo = null;		
		if(incomingAdditionalInfofields.size() > 0 || additionalInfoFilesMap.size() > 0)
		{
			String additionalInfo = PortalHelper.parseNull(rsCart.value("additional_info"));
			if(additionalInfo.length() == 0) additionalInfo = "{}";
			
			try {
				jAddInfo = PortalHelper.LinkedJSONObject(additionalInfo);
			} catch(Exception e) { 
				jAddInfo = PortalHelper.LinkedJSONObject();
				e.printStackTrace(); 
			}
			
			for(String field : incomingAdditionalInfofields.keySet())
			{
				AdditionalInfoField aif = additionalFieldsMetaData.get(field);
				if(aif != null)
				{
					JSONArray jValues = null;
					for(String vl : incomingAdditionalInfofields.get(field))
					{
						if(jValues == null) jValues = new JSONArray();
						jValues.put(vl);
					}

					if(jValues != null) jAddInfo = PortalHelper.addAdditionalInfoField(jAddInfo, aif, jValues);
				}
			}	
			
			//note:cart_additional_info is also hardcoded in dev_shop/customerEdit.jsp
			String additionalInfoUploadFolder = UPLOAD_DIR;
			additionalInfoUploadFolder += "cart_additional_info/";
			dir = new File(additionalInfoUploadFolder);
			if (!dir.exists()) {
				dir.mkdir();
			}
			additionalInfoUploadFolder += cartuuid + "/";
			dir = new File(additionalInfoUploadFolder);
			if (!dir.exists()) {
				dir.mkdir();
			}
			
			String additionalInfoBaseUrl = GlobalParm.getParm("funnel_documents_base_url");
			if(additionalInfoBaseUrl.endsWith("/") == false) additionalInfoBaseUrl += "/";
			additionalInfoBaseUrl += "cart_additional_info/"+cartuuid+"/";
			
			for(String field : additionalInfoFilesMap.keySet())
			{
				AdditionalInfoField aif = additionalFieldsMetaData.get(field);
				JSONArray jValues = PortalHelper.saveAdditionalFileToDisk(additionalInfoUploadFolder, additionalInfoBaseUrl, aif, additionalInfoFilesMap.get(field));
				if(jValues != null) jAddInfo = PortalHelper.addAdditionalInfoField(jAddInfo, aif, jValues);				
			}
			
		}
		if(jAddInfo != null)
		{
			System.out.println("-------------------------------");
			System.out.println("-------------------------------");
			System.out.println(""+jAddInfo.toString());
			if(!updateParameters.equals("")) updateParameters += ",";
			updateParameters += " additional_info = "+PortalHelper.escapeCote2(jAddInfo.toString());
		}
		
		String updateQry =  "UPDATE cart SET "+updateParameters+" WHERE session_id = "+ escape.cote(session_id)+" and site_id="+escape.cote(siteid);
		
		Logger.info("updatecheckout.jsp", "session_id::"+ session_id+" site_id::"+siteid);
		
		int rr = Etn.executeCmd(updateQry);
		Logger.info("updatecheckout.jsp", "rr::"+rr);
		if(rr > 0) 
		{
			status = STATUS_SUCCESS;
		}
		else
		{
			throw new Exception("ERROR:: Unable to process the request");
		}
		
		List<CartError> cErrors = CartHelper.getCartErrors(Etn, request, session_id, siteid, ___muuid);
		if(cErrors != null)
		{
			for(CartError err : cErrors)
			{
				JSONObject jError = new JSONObject();
				jError.put("err_type", err.getType());
				jError.put("err_msg", err.getMessage());
				errors.put(jError);
			}
		}
		
	}//end try
	catch (Exception e) {
		e.printStackTrace();
		status = STATUS_ERROR;
		message = e.getMessage();
	}
	finally {
	}	

	Logger.info("updatecheckout.jsp", "status::"+status);

	if("1".equals(sendKeepEmail) == false)
	{
		//must load cart again so that updated values can be fetched
		Cart cart = CartHelper.loadCart(Etn, request, session_id, siteid, ___muuid);
		if(status == STATUS_SUCCESS)
		{
			if(PortalHelper.parseNull(cart.getProperty("cart_step")).equalsIgnoreCase(CartHelper.Steps.DELIVERY) && PortalHelper.parseNull(cart.getProperty("delivery_method")).length() == 0)
			{
				status = STATUS_ERROR;
				message = com.etn.asimina.util.LanguageHelper.getInstance().getTranslation(Etn, "Delivery method must be selected");
			}
			else if(PortalHelper.parseNull(cart.getProperty("cart_step")).equalsIgnoreCase(CartHelper.Steps.PAYMENT) && PortalHelper.parseNull(cart.getProperty("payment_method")).length() == 0)
			{
				status = STATUS_ERROR;
				message = com.etn.asimina.util.LanguageHelper.getInstance().getTranslation(Etn, "Payment method must be selected");
			}
		}
	}
	
	JSONObject jsonResponse = new JSONObject();
	jsonResponse.put("status", status);
	jsonResponse.put("message", message);
	jsonResponse.put("data", data);
	jsonResponse.put("cart_errors", errors);
	
	Logger.info("updatecheckout.jsp", "response::"+jsonResponse.toString());
	out.write(jsonResponse.toString());
        
%>
