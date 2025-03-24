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
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<%
	String selectedsiteid = getSelectedSiteId(session);
	String id = parseNull(request.getParameter("id"));
	String type = parseNull(request.getParameter("type"));
	String catalogId = parseNull(request.getParameter("catalogId"));
	String folderId = parseNull(request.getParameter("folderId"));
	String paramName = "";
	if("catalog".equals(type)) paramName = "cat_desc_page_path_lang_";
	else if("product".equals(type)) paramName = "description_page_path_lang_";

	String errMsg = "";
	boolean allPathsUnique = true;

	HashMap<String, String> prefixPathHM = getProductPrefixPathMap(Etn, selectedsiteid, catalogId, folderId);

	List<Language> langsList = getLangs(Etn,session);
	for (Language lang : langsList) {
		String pagePath = parseNull(request.getParameter(paramName + lang.getLanguageId()));

		if (pagePath.length() == 0) continue;

		if(prefixPathHM.containsKey(lang.getLanguageId())){
			pagePath = prefixPathHM.get(lang.getLanguageId()) + "/" + pagePath;
		}
		if (!UrlHelper.isUrlUnique(Etn, selectedsiteid, lang.getCode(), type, id, pagePath))
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