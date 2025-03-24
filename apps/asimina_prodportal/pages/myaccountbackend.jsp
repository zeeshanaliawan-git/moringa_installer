<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.*, org.json.JSONObject, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.io.*"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException,com.etn.util.XSSHandler,org.apache.commons.fileupload.*, org.apache.commons.fileupload.FileItem, org.apache.commons.fileupload.disk.DiskFileItemFactory, org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@ page import="javax.imageio.ImageIO"%>
<%@ page import="java.awt.*"%>
<%@ page import="java.awt.image.BufferedImage"%>
<%@ page import="com.etn.asimina.authentication.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.text.ParseException"%>
<%@ include file="../lib_msg.jsp"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
	
	String getOrangeDate(String date){
		try{
			return new SimpleDateFormat("yyyy-MM-dd").format(new SimpleDateFormat("dd/MM/yyyy").parse(date));
		}catch(Exception ex){
			ex.printStackTrace();
			return "";
		}
	}

	String resizeImage(InputStream input, int width, int height, String ofilename) throws IOException 
	{
        BufferedImage originalImage = ImageIO.read(input);
		 
        // get file extension
        String fileExtension = ofilename.substring(ofilename.lastIndexOf(".") + 1);
		String s1 = "data:image/jpeg;base64,";
		int iType = BufferedImage.TYPE_INT_RGB;
		if(fileExtension.toLowerCase().equals(".png")) 
		{
			s1 = "data:image/png;base64,";
			iType = BufferedImage.TYPE_INT_ARGB;
		}
		
        BufferedImage newResizedImage = new BufferedImage(width, height, iType);
        Graphics2D g = newResizedImage.createGraphics();

        g.setBackground(Color.WHITE);
        g.setPaint(Color.WHITE);

        // background transparent
        //g.setComposite(AlphaComposite.Src);
        g.fillRect(0, 0, width, height);

        /* try addRenderingHints()
        // VALUE_RENDER_DEFAULT = good tradeoff of performance vs quality
        // VALUE_RENDER_SPEED   = prefer speed
        // VALUE_RENDER_QUALITY = prefer quality
        g.setRenderingHint(RenderingHints.KEY_RENDERING,
                              RenderingHints.VALUE_RENDER_QUALITY);

        // controls how image pixels are filtered or resampled
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                              RenderingHints.VALUE_INTERPOLATION_BILINEAR);

        // antialiasing, on
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                              RenderingHints.VALUE_ANTIALIAS_ON);*/

        Map<RenderingHints.Key,Object> hints = new HashMap<>();
        hints.put(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        hints.put(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        hints.put(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.addRenderingHints(hints);

        // puts the original image into the newResizedImage
        g.drawImage(originalImage, 0, 0, width, height, null);
        g.dispose();

		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ImageIO.write(newResizedImage, fileExtension, baos);
		byte[] bytes = baos.toByteArray();		
		
		return s1 + com.etn.util.Base64.encode(bytes);
    }

%>

<%
	String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
	Set rs = Etn.execute("select * from clients where id = " + escape.cote(client_id));
	rs.next();
	String username = rs.value("username");
	String formRowId = parseNull(rs.value("form_row_id"));

	java.util.List<String> ignorecols = new ArrayList<String>();
	ignorecols.add("muid");
	ignorecols.add("pass");
	ignorecols.add("is_verified");
	ignorecols.add("site_id");
	ignorecols.add("is_active");
	ignorecols.add("orig_avatar");
	ignorecols.add("_t");
	
	java.util.List<String> allCols = new ArrayList<String>();
	allCols.add("username");
	allCols.add("email");
	allCols.add("name");
	allCols.add("surname");
	allCols.add("mobile_number");
	allCols.add("avatar");
	allCols.add("civility");
	
	Map<String, String> customFormFieldsMapping = new HashMap<String, String>();
	customFormFieldsMapping.put("_etn_login","username");
	customFormFieldsMapping.put("_etn_first_name","name");
	customFormFieldsMapping.put("_etn_last_name","surname");
	customFormFieldsMapping.put("_etn_email","email");
	customFormFieldsMapping.put("_etn_civility","civility");
	customFormFieldsMapping.put("_etn_mobile_phone","mobile_number");
	customFormFieldsMapping.put("_etn_avatar","avatar");
	customFormFieldsMapping.put("_etn_birthdate","birthdate");
	customFormFieldsMapping.put("_etn_lang","lang");
	customFormFieldsMapping.put("_etn_time_zone","time_zone");
	customFormFieldsMapping.put("_etn_gender","gender");
	
	
	String status = "success";
	String msg = "";
	try
	{	
		String field= "";
		String value= "";
		String multipleFieldValue = "";

		FileItemFactory factory = new DiskFileItemFactory();
		ServletFileUpload upload = new ServletFileUpload(factory);
	
		java.util.List items = null;

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
		java.util.List<FileItem> files = new ArrayList<FileItem>();

		Map<String, String> incomingfields = new HashMap<String, String>();
		Map<String, String> origIncomingfields = new HashMap<String, String>();
        Map<String, String> filesMap = new HashMap<String, String>();
		
		while (itr.hasNext()) 
		{
			FileItem item = (FileItem)(itr.next());

			if (item.isFormField()) 
			{
				field = item.getFieldName();				
				value = XSSHandler.clean(item.getString("UTF-8"));
				String _field = field;
				if(customFormFieldsMapping.get(field) != null) _field = customFormFieldsMapping.get(field);
				incomingfields.put(_field, value);
				origIncomingfields.put(field, value);
			} 
			else 
			{
				field = item.getFieldName();
				value = item.getName();
				
				String _field = field;
				if(customFormFieldsMapping.get(field) != null) _field = customFormFieldsMapping.get(field);

				filesMap.put(_field, value);
				files.add(item);
			}
		}


		if(null != files && files.size() > 0)
		{			
			for(FileItem fi : files) 
			{
				field = fi.getFieldName();
				String _field = field;
				if(customFormFieldsMapping.get(field) != null) _field = customFormFieldsMapping.get(field);
				
				InputStream fis = fi.getInputStream();
				if(parseNull(fi.getName()).length() > 0)
				{
					int _width = 36;
					int _height = 36;
					if(parseNull(GlobalParm.getParm("AVATAR_WIDTH")).length() > 0 && parseNull(GlobalParm.getParm("AVATAR_HEIGHT")).length() > 0)
					{
						try 
						{
							_width = Integer.parseInt(parseNull(GlobalParm.getParm("AVATAR_WIDTH")));
							_height = Integer.parseInt(parseNull(GlobalParm.getParm("AVATAR_HEIGHT")));
						} 
						catch(Exception _ex)
						{
							_ex.printStackTrace();
							_width = 36;
							_height = 36;
						}
					}
					
					String b64 = resizeImage(fis, 36, 36, fi.getName());
					//add this to incoming fields so that we can save to db
					incomingfields.put(_field, b64);
					origIncomingfields.put(field, b64);
				}
				else 
				{
					incomingfields.put(_field, "");
					origIncomingfields.put(field, "");
				}
			}
		}

		String muid = parseNull(incomingfields.get("muid"));	
		Set rsM = Etn.execute("select * from site_menus where menu_uuid = "+ escape.cote(muid));
		String lang = "";
		String siteid = "";
		
		if(rsM.next())
		{
			lang = parseNull(rsM.value("lang"));
			siteid = parseNull(rsM.value("site_id"));
		}
		
		set_lang(lang,request,Etn);

		//default msg
		msg = libelle_msg(Etn, request, "Account info updated");

		String _token = parseNull(incomingfields.get("_t"));
		boolean tokenmatch = false;
		String sToken = parseNull(com.etn.asimina.session.ClientSession.getInstance().getParameter(Etn, request, "myaccount_token"));
		if(sToken.equals(_token)) tokenmatch = true;

		if(!tokenmatch)
		{
			status = "error";
			msg = libelle_msg(Etn, request, "Token mis-match. Refresh the page and try again");
		}
		else
		{
			String q = " update clients set updated_date = now() ";			
			
			JSONObject additionalInfo = new JSONObject();			
			for(String f : incomingfields.keySet())
			{
				if(ignorecols.contains(f)) continue;
	//			System.out.println(f);
				if(allCols.contains(f))
				{
					if(f.equals("avatar") && parseNull(incomingfields.get(f)).length() == 0)
					{					
						q += ", " + f + " = " + escape.cote(incomingfields.get("orig_avatar"));
					}
					else q += ", " + f + " = " + escape.cote(incomingfields.get(f));
				}
				else
				{
					additionalInfo.put(f, incomingfields.get(f));
				}
			}
			
			q += ", additional_info = " + escape.cote(additionalInfo.toString());
			q += " where id = " + escape.cote(client_id);
			
			//System.out.println(q);
			Etn.executeCmd(q);											
			
			//We update the local client table nonetheless. After that we check if we have to update the 
			AsiminaAuthenticationHelper asiminaAuthenticationHelper = new AsiminaAuthenticationHelper(Etn,siteid,GlobalParm.getParm("CLIENT_PASS_SALT"));
			if(asiminaAuthenticationHelper != null)
			{
				if(asiminaAuthenticationHelper.isDefaultAuthentication() == false)
				{
					AsiminaAuthentication asiminaAuthentication = asiminaAuthenticationHelper.getAuthenticationObject();		
					if(asiminaAuthentication != null)
					{	

						System.out.println("username:" + username);
						System.out.println("birthdate:" + incomingfields.get("birthdate"));
						AsiminaAuthenticationResponse resp = 
							asiminaAuthentication.updateUser(
								username,/*username field is disabled so it is not poted*/
								incomingfields.get("email"),
								incomingfields.get("name"),
								incomingfields.get("surname"),
								incomingfields.get("surname") + ", " + incomingfields.get("name"),
								incomingfields.get("mobile_number"),
								additionalInfo.toString(),
								incomingfields.get("avatar"), 
								incomingfields.get("gender"),
								getOrangeDate(incomingfields.get("birthdate")),
								incomingfields.get("lang"),
								incomingfields.get("time_zone")
							);
						if(resp.isDone() == false){
							msg = resp.getMessage() + " " + resp.getDescription();
							status = "error";
						}
					}
				}
			}
			
			if(formRowId.length() > 0)
			{		
				String _formTblname = "";
				Set rsForm = Etn.execute("select p.* from "+GlobalParm.getParm("FORMS_DB")+".process_forms p where p.`type` = 'sign_up' and p.site_id = "+escape.cote(siteid));
				if(rsForm.next()) _formTblname = parseNull(rsForm.value("table_name"));
			
				//update data in forms table as well
				String q2 = " update "+GlobalParm.getParm("FORMS_DB")+"."+_formTblname+" set updated_on = now() ";
				for(String f : origIncomingfields.keySet())
				{
					if(ignorecols.contains(f)) continue;
					if(f.equals("_etn_avatar") && parseNull(origIncomingfields.get(f)).length() == 0)
					{					
						q2 += ", " + f + " = " + escape.cote(origIncomingfields.get("orig_avatar"));
					}
					else q2 += ", " + f + " = " + escape.cote(origIncomingfields.get(f));
				}
				
				q2 += " where "+_formTblname+"_id = " + escape.cote(formRowId);
				
				//System.out.println(q2);
				Etn.executeCmd(q2);			
			}
		}
	}
	catch(Exception e)
	{
		e.printStackTrace();
		msg = libelle_msg(Etn, request, "Error updating account info");
		status = "error";
	} 	


	out.write("{\"response\":\""+status+"\",\"msg\":\""+msg.replace("\"","\\\"")+"\"}");
%>