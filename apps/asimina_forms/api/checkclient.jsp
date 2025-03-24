<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ include file="../common2.jsp" %>

<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.io.File, org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*, com.etn.util.XSSHandler"%>

<%

	List items = null;
	FileItemFactory factory = new DiskFileItemFactory();
	ServletFileUpload upload = new ServletFileUpload(factory);

	try 
	{
		upload.setHeaderEncoding("UTF-8");
		items = upload.parseRequest(request);

		Iterator itr = items.iterator();
		Map<String, String> incomingfields = new HashMap<String, String>();

		String field= "";
		String value= "";
		String multipleFieldValue = "";

		while (itr.hasNext()) 
		{
			FileItem item = (FileItem)(itr.next());

			if (item.isFormField()) 
			{
				field=item.getFieldName();
				value = XSSHandler.clean(item.getString("UTF-8"));

				if(incomingfields.containsKey(field))
				{
					multipleFieldValue = incomingfields.get(field) + "!@##@!" + value;
					incomingfields.put(field, multipleFieldValue);

				}
				else
				{
					incomingfields.put(field, value);
				}        
			}
		}

		String _flang = parseNull(incomingfields.get("_flang"));	
		String formid = parseNull(incomingfields.get("form_id"));	
		String username = parseNull(incomingfields.get("_etn_login"));
		String email = parseNull(incomingfields.get("_etn_email"));
		String dbname = GlobalParm.getParm("PROD_PORTAL_DB");
		String portalUrl = parseNull(incomingfields.get("portalurl"));
		String isAdmin = parseNull(incomingfields.get("isadmin"));
		
		if(isAdmin.length() == 0) isAdmin = "0";
		
		if(portalUrl.toLowerCase().contains("_portal")) dbname = GlobalParm.getParm("PORTAL_DB");
		if("1".equals(isAdmin)) dbname = GlobalParm.getParm("PROD_PORTAL_DB");


		Set _rsFrm = Etn.execute("select * from process_forms where form_id = " + escape.cote(formid));
		_rsFrm.next();

		String siteId = parseNull(_rsFrm.value("site_id"));
		String formType = parseNull(_rsFrm.value("type"));

		set_lang(_flang, request, Etn,parseNull(_rsFrm.value("form_id")));
		
        boolean formHasLoginField = false;
        if(incomingfields.get("_etn_login") != null) formHasLoginField = true;

        out.write(verifyClient(Etn, request, formHasLoginField, username, email, dbname, siteId, formType).toString());
	} 
	catch (FileUploadException e) 
	{
		e.printStackTrace();
		out.write("{\"status\":" + 5 + ",\"message\":\"" + (e.getMessage()).replace("\"","\\\"") + "\"}");
	} catch(JSONException je){

		je.printStackTrace();
		out.write("{\"status\":" + 6 + ",\"message\":\"" + (je.getMessage()).replace("\"","\\\"") + "\"}");		
	}

%>


