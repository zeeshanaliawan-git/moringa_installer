<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*"%>
<%@ page import="com.etn.asimina.util.*"%>
<%@ page import="com.etn.asimina.data.LanguageFactory"%>
<%@ page import="com.etn.asimina.beans.Language"%>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@ include file="../../common2.jsp"%>

<%
	String selectedsiteid = getSelectedSiteId(session);
	String id = parseNull(request.getParameter("id"));
	String type = parseNull(request.getParameter("type"));

	//before updating catalog/product data check for paths uniqueness

	String paramName = "";
	if("form".equals(type)) paramName = "page_path_lang_";

	String errMsg = "";
	boolean allPathsUnique = true;
	List<Language> langs = getLangs(Etn,session);

	for(Language lang : langs)
	{
		String pagePath = parseNull(request.getParameter(paramName + lang.getLanguageId()));

		if(pagePath.length() == 0) continue;

		if(!UrlHelper.isUrlUnique(Etn, selectedsiteid, lang.getCode(), type, id, pagePath))
		{
			String urlErrorMsg = UrlHelper.lastMsg;
			errMsg = "Error: Path '"+pagePath+"' entered for language '"+lang.getCode()+"' is not unique across the site. " + urlErrorMsg;

			allPathsUnique = false;
			break;	
		}
	}			
	if(!allPathsUnique) 
	{
		out.write("{\"status\":100, \"msg\":\""+errMsg+"\"}");
		return ;
	}

	out.write("{\"status\":0}");
	return ;
	
%>