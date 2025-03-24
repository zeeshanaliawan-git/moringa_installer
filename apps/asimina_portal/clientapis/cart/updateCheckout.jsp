<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.sql.escape, java.util.*, java.net.*, javax.servlet.http.Cookie"%>
<%@ page import="java.io.*, org.json.*, com.etn.asimina.cart.*, com.etn.asimina.beans.*, com.etn.asimina.util.*, com.etn.util.XSSHandler"%>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*, org.apache.tika.*"%>
<%@ include file="../errorTypes.jsp"%>

<%!
	class AdditionalInfoField {
		String name;
		String displayName;
		String sectionName;
		String sectionDisplayName;
		String ftype;
		List<String> allowedTypes = null;
	}
	
	JSONArray saveFileToDisk(String uploadDir, String baseUrl, AdditionalInfoField aif, List<FileItem> files) throws Exception
	{
		if(files == null || aif == null || files.size() == 0) return null;
		JSONArray jValues = new JSONArray();
		
		for(FileItem fi : files)
		{
			String filename = PortalHelper.parseNull(fi.getName());
			filename = filename.replace("/","").replace("\\","");
			if(filename.length() == 0) continue;
			System.out.println("<<<<<<<< " + aif.name + " : " + filename);
						
			String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(fi.getInputStream()));
			
			JSONObject jVal = PortalHelper.LinkedJSONObject();
			jVal.put("filename", filename);
			jVal.put("base_url", baseUrl);
			jVal.put("base_dir", uploadDir);
			jVal.put("content_type", _type);

			com.etn.util.Logger.info("updatecheckout.jsp", "saveFileToDisk::"+uploadDir+filename);
			File destFile = new File((uploadDir+filename).replaceAll("../", "").replaceAll("\\\\", ""));
			fi.write(destFile);
			jValues.put(jVal);
		}
		return jValues;
	}

	boolean isValidFile(AdditionalInfoField aif, List<FileItem> files) throws Exception
	{
		if(aif == null || files == null || files.size() == 0 || aif.allowedTypes == null || aif.allowedTypes.size() == 0) return true;
		for(FileItem fileItem : files)
		{
			if(fileItem.getName().length() == 0) continue;
			String _type = new Tika().detect(org.apache.commons.io.IOUtils.toByteArray(fileItem.getInputStream()));

			if (aif.allowedTypes.contains(_type) == false) 
			{
				return false;
			}
		}
		return true;
	}
	
	JSONObject addAdditionalInfoField(JSONObject jAddInfo, AdditionalInfoField aif, JSONArray jValues) throws Exception
	{
		System.out.println(">>>>>>>>>>>>> "+aif.name + " jValues : "+jValues.length());
		JSONObject jSection = null;
		if(jAddInfo.has("sections") == false)
		{
			jAddInfo.put("sections", new JSONArray());
		}
		for(int i=0;i<jAddInfo.getJSONArray("sections").length();i++)
		{
			if(PortalHelper.parseNull(jAddInfo.getJSONArray("sections").getJSONObject(i).getString("name")).equals(aif.sectionName))
			{
				jSection = jAddInfo.getJSONArray("sections").getJSONObject(i);
				jSection.remove("display_name");
				jSection.put("display_name", aif.sectionDisplayName);//just updating the display name if its changed in db
				break;
			}
		}
		if(jSection == null) 
		{
			jSection = PortalHelper.LinkedJSONObject();
			jSection.put("name", aif.sectionName);
			jSection.put("display_name", aif.sectionDisplayName);
			jAddInfo.getJSONArray("sections").put(jSection);
		}
		if(jSection.has("fields") == false)
		{
			jSection.put("fields", new JSONArray());
		}
		if(jValues.length() == 0)
		{
			//lets remove this field from the json
			boolean found = false;
			int i=0;
			for(i=0;i<jSection.getJSONArray("fields").length();i++)
			{			
				if(PortalHelper.parseNull(jSection.getJSONArray("fields").getJSONObject(i).getString("name")).equals(aif.name))
				{
					found = true;
					break;
				}
			}
			if(found)
			{
				System.out.println(">>>><<<< remove field " + aif.name);
				jSection.getJSONArray("fields").remove(i);
			}
		}
		else
		{
			JSONObject jField = null;
			for(int i=0;i<jSection.getJSONArray("fields").length();i++)
			{			
				if(PortalHelper.parseNull(jSection.getJSONArray("fields").getJSONObject(i).getString("name")).equals(aif.name))
				{
					jField = jSection.getJSONArray("fields").getJSONObject(i);
					jField.remove("display_name");
					jField.remove("type");
					jField.put("display_name", aif.displayName);//just updating the display name if its changed in db
					jField.put("type", aif.ftype);//just updating the display name if its changed in db
					break;
				}
			}
			if(jField == null)
			{
				jField = PortalHelper.LinkedJSONObject();
				jField.put("name", aif.name);
				jField.put("type", aif.ftype);
				jField.put("display_name", aif.displayName);
				jSection.getJSONArray("fields").put(jField);
			}
			if(jField.has("value")) jField.remove("value");
			jField.put("value", jValues);
		}
		return jAddInfo;
	}

	String getSingleFieldValue(Map<String, List<String>> incomingfields, String fieldName)
	{
		if(incomingfields == null) return null;
		if(incomingfields.get(fieldName) == null) return null;
		if(incomingfields.get(fieldName).size() == 0) return null;
		return incomingfields.get(fieldName).get(0);
	}

%>
<%
	try
	{
		String muid = com.etn.asimina.util.PortalHelper.parseNull(request.getParameter("muid"));
		String sessionToken = com.etn.asimina.util.PortalHelper.parseNull(request.getParameter("sessionToken"));
		System.out.println(".............................sessionToken:" + sessionToken);
		System.out.println("............................." + request.getContentType());
		if(request.getContentType() != null && request.getContentType().startsWith("multipart/form-data;"))
		{
			Set rsMenu = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(muid));
			if(muid.length() > 0 && rsMenu != null && rsMenu.next())
			{			
				String siteId = rsMenu.value("site_id");
				Set rsSite = Etn.execute("select enable_ecommerce from sites where id = " + escape.cote(siteId));
				if(rsSite != null && rsSite.next())
				{
					if("1".equals(rsSite.value("enable_ecommerce")))
					{
						String sessionId = CartHelper.getCartSessionId(request);
						String dbSessionToken = CartHelper.getSessionToken(Etn, sessionId, siteId);
						System.out.println("........................dbSessionToken:" + dbSessionToken + " sessionId:" + sessionId + " siteId:"+ siteId);
						if(dbSessionToken.length() == 0 || sessionToken.equals(dbSessionToken) == false)
						{
							out.write("{\"error\":true,\"status\":" + ErrorTypes.SESSION_TOKEN_MISMATCH + ",\"message\":\"" + ErrorMessages.SESSION_TOKEN_MISMATCH + "\"}");
						}
						else
						{
							int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

							int status = STATUS_ERROR;
							String message = "";
							JSONObject data = new JSONObject();

							String q = "";
							String updateParameters = "";
							Set rs = null;
							boolean identityPhotoUploaded = false;
							
							ArrayList<String> identityPhotoFileTypes = new ArrayList<>();
							identityPhotoFileTypes.add("image/jpeg");
							identityPhotoFileTypes.add("image/png");
							identityPhotoFileTypes.add("image/gif");
							identityPhotoFileTypes.add("image/svg+xml");
							identityPhotoFileTypes.add("image/bmp");
							identityPhotoFileTypes.add("image/tiff");
							identityPhotoFileTypes.add("application/pdf");

							Map<String, AdditionalInfoField> additionalFieldsMetaData = new HashMap<String, AdditionalInfoField>();
							Set rsAddFields = Etn.execute("select f.*, s.name as section_name, s.display_name as section_display_name from checkout_add_info_fields f inner join checkout_add_info_sections s on s.id = f.section_id and s.site_id = "+escape.cote(siteId));
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
										boolean isValid = isValidFile(aif, additionalInfoFilesMap.get(field));
										if(isValid == false)
										{
											throw new Exception("Error:: File type not supported for field : " + aif.displayName);
										}
									}
								}
							}							
							
							ArrayList<String> includeCols = new ArrayList<String>();
							includeCols.add("identityId");
							includeCols.add("name");
							includeCols.add("surnames");
							includeCols.add("contactPhoneNumber1");
							includeCols.add("email");
							includeCols.add("identityType");
							includeCols.add("baline1");
							includeCols.add("baline2");
							includeCols.add("batowncity");
							includeCols.add("bapostalCode");
							includeCols.add("salutation");
							includeCols.add("newPhoneNumber");
							includeCols.add("delivery_method");
							includeCols.add("selected_boutique");
							includeCols.add("rdv_boutique");
							includeCols.add("rdv_date");
							includeCols.add("delivery_type");
							includeCols.add("payment_method");
							includeCols.add("daline1");
							includeCols.add("daline2");
							includeCols.add("datowncity");
							includeCols.add("dapostalCode");
							includeCols.add("country");
							includeCols.add("keepEmail");
							includeCols.add("sendKeepEmail");
							includeCols.add("keepEmailMuid");
							includeCols.add("newsletter");
									
							if(!identityPhotoUploaded && PortalHelper.parseNull(getSingleFieldValue(incomingfields, "existingIdentityPhoto")).length()>0) updateParameters += " identityPhoto = " + escape.cote(PortalHelper.parseNull(getSingleFieldValue(incomingfields, "existingIdentityPhoto")));
							for(String parameter : incomingfields.keySet())
							{
								if(includeCols.contains(parameter))
								{			
									if(!updateParameters.equals("")) updateParameters += ",";
									updateParameters += parameter + " = " + escape.cote(PortalHelper.parseNull(getSingleFieldValue(incomingfields, parameter)));												
								}			
							}

							Set rsCart = Etn.execute("select * from cart WHERE session_id = "+ escape.cote(sessionId)+" and site_id="+escape.cote(siteId));
							rsCart.next();
							String cartuuid = rsCart.value("uuid");

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

										if(jValues != null) jAddInfo = addAdditionalInfoField(jAddInfo, aif, jValues);
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
									JSONArray jValues = saveFileToDisk(additionalInfoUploadFolder, additionalInfoBaseUrl, aif, additionalInfoFilesMap.get(field));
									if(jValues != null) jAddInfo = addAdditionalInfoField(jAddInfo, aif, jValues);				
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
							
							String updateQry =  "UPDATE cart SET "+updateParameters+" WHERE session_id = "+ escape.cote(sessionId)+" and site_id="+escape.cote(siteId);
							System.out.println("................updateQry:" + updateQry);
							int rr = Etn.executeCmd(updateQry);
							if(rr > 0) 
							{
								status = STATUS_SUCCESS;
							}
							else
							{
								throw new Exception("ERROR:: Unable to process the request");
							}

							JSONArray errors = new JSONArray();
							List<CartError> cErrors = CartHelper.getCartErrors(Etn, request, sessionId, siteId, muid);
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
							JSONObject resp = new JSONObject();
							resp.put("error", false);
							resp.put("data", data);
							resp.put("cart_errors", errors);
							com.etn.asimina.beans.Cart cart = com.etn.asimina.cart.CartHelper.loadCart(Etn, request, sessionId, siteId, muid, true, true);		
							resp.put("sessionToken",com.etn.asimina.cart.CartHelper.setSessionToken(Etn, cart));			
							out.write(resp.toString());
						}
					}
					else
					{
						out.write("{\"error\":true,\"status\":" + ErrorTypes.ECOMMERCE_DISABLED + ",\"message\":\"" + ErrorMessages.ECOMMERCE_DISABLED + "\"}");
					}
				}
				else
				{
					out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_SITE_ID + ",\"message\":\"" + ErrorMessages.INVALID_SITE_ID + "\"}");
				}
			}
			else
			{
				out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_MENU_ID + ",\"message\":\"" + ErrorMessages.INVALID_MENU_ID + "\"}");
			}
		}
		else
		{
			out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_CONTENT_TYPE + ",\"message\":\"" + ErrorMessages.INVALID_CONTENT_TYPE + "\"}");
		}
	}
	catch(Exception ex)
	{
		ex.printStackTrace();
		JSONObject error = new JSONObject();
		error.put("error",true);
		error.put("status",ErrorTypes.SOME_EXCEPTION);
		error.put("message",ex.toString());
		error.put("stackTrace",getStackTrace(ex));
		out.write(error.toString());
	}
 %>
