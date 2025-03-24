<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList"%>
<%@ page import="com.etn.pages.PagesGenerator"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>
<%!
	boolean isPageFormExist(com.etn.beans.Contexte etn, String pageId)
	{
		Set rs= etn.execute("Select * FROM pages_forms where page_id="+escape.cote(pageId));
		if(rs!=null && rs.rs.Rows > 0){
			System.out.println("rs"+rs.rs.Rows);
			return true;
		}
		return false;
	}

	String getBoostedVersion(com.etn.beans.Contexte etn, String siteId)
    {
        String qry = "Select COALESCE(st.form_boosted_version,'4.x') as boosted_version FROM "+parseNull(GlobalParm.getParm("PORTAL_DB"))+".sites st where id = "+ escape.cote(siteId);        
        Set rs  = etn.execute(qry);
        if (rs.next()) {
            if(parseNull(rs.value("boosted_version")).equalsIgnoreCase("5.x"))
                return "5.x";
        }
        return "4.x";
    }

%>

<%
	String pageId = parseNull(request.getParameter("id"));
	String rand = parseNull(request.getParameter("rand"));
	String blocIdsStr = parseNull(request.getParameter("blocIds"));
    if(rand.length() == 0){
        rand = ""+getRandomNumber();
    }

	boolean fromPageEditor = parseNull(request.getParameter("editor")).equals("1");
	boolean previewPublished = parseNull(request.getParameter("published")).equals("1");

	ArrayList<String> blocIdsList = new ArrayList<>();

	if(blocIdsStr.length() > 0){
		for(String str : blocIdsStr.split(",")){
			if(str.startsWith("form_") || parseInt(str,-1) >= 0){
				blocIdsList.add(str);
			}
		}
	}

	String q = null;
	Set rs = null;
	String siteId = getSiteId(session);
	q = " SELECT id, type, to_generate, html_file_path "
	+ " , publish_status, published_html_file_path, published_ts "
	+ " FROM pages "
	+ " WHERE id = " + escape.cote(pageId)
	+ " AND site_id = " + escape.cote(siteId);
	Set pageRs = Etn.execute(q);

	if(!pageRs.next()){
		// response.sendRedirect("pages.jsp");
		out.write("<h1 style='color:red;margin:50px'>Error: No page found for preview</h1>");
		return;
	}

	PagesGenerator pagesGen = new PagesGenerator(Etn);
    if(fromPageEditor){
    	pagesGen.setFromPageEditor(true);
	}

	String fullPageStr = "";
	String pageUrl = "";
	if(blocIdsList.size() == 0){
		String toGenerate = pageRs.value("to_generate");
		if(Constant.PAGE_TYPE_STRUCTURED.equals(pageRs.value("type"))){
			q = "SELECT to_generate FROM structured_contents sc"
				+ " JOIN structured_contents_details scd ON sc.id = scd.content_id "
				+ " WHERE scd.page_id = " + escape.cote(pageId)
				+ " AND sc.site_id = " + escape.cote(siteId);
			rs = Etn.execute(q);
			if(rs.next()){
				toGenerate = rs.value("to_generate");
			}
			else{
				toGenerate = "1";
			}
		}

		if( fromPageEditor
			|| ( "1".equals(toGenerate) && !previewPublished ) ){
			fullPageStr  = pagesGen.generatePageString(pageId);
			if(isPageFormExist(Etn,pageId)){
				if(getBoostedVersion(Etn,siteId).equalsIgnoreCase("5.x"))
					fullPageStr=fullPageStr.replace("<!-- page.bodyTags -->","<!-- page.bodyTags --><link type='text/css' href='"+GlobalParm.getParm("EXTERNAL_FORMS_LINK")+"css/boosted5.min.css' rel='stylesheet'><script type='text/javascript' href='"+GlobalParm.getParm("EXTERNAL_FORMS_LINK")+"js/boosted5.min.js'></script>");
				else
					fullPageStr=fullPageStr.replace("<!-- page.bodyTags -->","<!-- page.bodyTags --><link type='text/css' href='"+GlobalParm.getParm("EXTERNAL_FORMS_LINK")+"css/boosted.min413.css' rel='stylesheet'><script type='text/javascript' href='"+GlobalParm.getParm("EXTERNAL_FORMS_LINK")+"js/boosted.min413.js'></script>");
			}
            out.write(fullPageStr);
		}
		else{

			if(previewPublished){
				String pageHtmlPath = pageRs.value("published_html_file_path");
				String PAGES_PUBLISH_FOLDER = GlobalParm.getParm("PAGES_PUBLISH_FOLDER");

				pageUrl =  "/" + PAGES_PUBLISH_FOLDER + pageHtmlPath;
				pageUrl += "?rand="+rand;
	                // response.sendRedirect(request.getContextPath() + pageUrl);
			}
			else{
				String pageHtmlPath = pageRs.value("html_file_path");
				String PAGES_SAVE_FOLDER = GlobalParm.getParm("PAGES_SAVE_FOLDER");

				pageUrl =  "/" + PAGES_SAVE_FOLDER + pageHtmlPath;
				pageUrl += "?rand="+rand;
			}

			javax.servlet.RequestDispatcher r = request.getRequestDispatcher(pageUrl);
			r.forward(request,response);

           	// removed forwarding as it did not trigger iframe onload and caused issues in page editor
			// javax.servlet.RequestDispatcher r = request.getRequestDispatcher(pageUrl);
			// System.out.println(r.toString());
			// r.forward(request,response);
		}


	}
	else{
		
		fullPageStr  = pagesGen.generatePageString(pageId, blocIdsList);
		if(isPageFormExist(Etn,pageId)){
			if(getBoostedVersion(Etn,siteId).equalsIgnoreCase("5.x"))
				fullPageStr=fullPageStr.replace("<!-- page.bodyTags -->","<!-- page.bodyTags --><link type='text/css' href='"+GlobalParm.getParm("EXTERNAL_FORMS_LINK")+"css/boosted5.min.css' rel='stylesheet'><script type='text/javascript' href='"+GlobalParm.getParm("EXTERNAL_FORMS_LINK")+"js/boosted5.min.js'></script>");
			else
				fullPageStr=fullPageStr.replace("<!-- page.bodyTags -->","<!-- page.bodyTags --><link type='text/css' href='"+GlobalParm.getParm("EXTERNAL_FORMS_LINK")+"css/boosted.min413.css' rel='stylesheet'><script type='text/javascript' href='"+GlobalParm.getParm("EXTERNAL_FORMS_LINK")+"js/boosted.min413.js'></script>");
		}
		out.write(fullPageStr);
	}
%>
