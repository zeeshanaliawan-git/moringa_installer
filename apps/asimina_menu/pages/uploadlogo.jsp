<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.util.FormDataFilter"%>
<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.io.File"%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.beans.app.GlobalParm"%>
<%@ include file="common.jsp"%>

<%
	String menuid = "";
	String isfavicon = "";
	String issmalllogo = "";
	String siteid = getSiteId(session);

	FormDataFilter formData = new FormDataFilter(request.getInputStream());
	FileOutputStream fileOutput = null;

	String fileActualName = "";
	String fieldData[] = new String[3];
	boolean fileuploaded = false;
	try
	{
		while((fieldData = formData.getField()) != null)
		{
			if(formData.isStream())
			{	
				fileActualName=fieldData[1];

				int idx = fileActualName.lastIndexOf("/");
				int idy = fileActualName.lastIndexOf("\\");
				if(idx >= 0) fileActualName=fileActualName.substring(idx + 1); 
				if(idy >= 0) fileActualName=fileActualName.substring(idy + 1); 
				fileuploaded = true;
			}
			else
			{
				if(fieldData[0].equals("menuid")) menuid = parseNull(fieldData[1]);
				else if(fieldData[0].equals("isfavicon")) isfavicon = parseNull(fieldData[1]);
				else if(fieldData[0].equals("issmalllogo")) issmalllogo = parseNull(fieldData[1]);
			}
		}	

		if(parseNull(menuid).length() > 0)
		{		
			Set rss = Etn.execute("select * from site_menus where site_id = "+escape.cote(siteid)+" and id = " + escape.cote(menuid));
			//checking if the menu id provided was of same site as user can temper the url
			if(rss.rs.Rows == 0) 
			{		
				response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
				response.setHeader("Location", "site.jsp" + "?errmsg=The menu you are trying to view does not belong to the selected site");
				return;
			}
				
			String filename = "";	
			String q = "update site_menus set version = version + 1, updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());
			String ext = "";

			if(fileActualName.indexOf(".") > -1) ext = fileActualName.substring(fileActualName.lastIndexOf("."));
			
			if(!ext.toLowerCase().equals(".jpg") && !ext.toLowerCase().equals(".jpeg") && !ext.toLowerCase().equals(".png") 
				&& !ext.toLowerCase().equals(".gif") && !ext.toLowerCase().equals(".tif") && !ext.toLowerCase().equals(".svg") && !ext.toLowerCase().equals(".ico"))
			{
				com.etn.util.Logger.error("uploadlogo.jsp","----------------------- ERROR ----------------------------");
				com.etn.util.Logger.error("uploadlogo.jsp","Invalid file extension found for menu logo/favicon");
				com.etn.util.Logger.error("uploadlogo.jsp","-----------------------------------------------------------");
			}
			else
			{
				if("1".equals(isfavicon)) 
				{
					filename = "favicon_" + menuid + ext;
					q += ", favicon = " + escape.cote(filename);
				}
				else if("1".equals(issmalllogo)) 
				{
					filename = "slogo_" + menuid + ext;
					q += ", small_logo_file = " + escape.cote(filename);
				}
				else 
				{
					filename = "logo_" + menuid + ext;
					q += ", logo_file = " + escape.cote(filename);
				}

				fileOutput = new FileOutputStream(com.etn.beans.app.GlobalParm.getParm("MENU_IMAGES_FOLDER")+filename);
				formData.writeTo(fileOutput);

				q += " where id = " + escape.cote(menuid) ;

				Etn.executeCmd(q);
			}
		}

		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
		response.setHeader("Location", "menudesigner.jsp?menuid="+menuid);
		
	}
	catch(Exception e)
	{
		e.printStackTrace();
		throw e;
	}
	finally
	{
		if(fileOutput != null) fileOutput.close();
	}


%>
