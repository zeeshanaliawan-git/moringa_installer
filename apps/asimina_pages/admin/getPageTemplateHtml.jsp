<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,  com.etn.pages.PagesUtil, com.etn.pages.PagesGenerator, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "", templateHtml = "";
    try{
        String templateUuid = parseNull(request.getParameter("templateUuid"));
        String lang = parseNull(request.getParameter("lang"));
        String contentId = parseNull(request.getParameter("contentId"));

		Set rsLang = Etn.execute("select langue_id from language where langue_code = "+escape.cote(lang));
		if(rsLang.next())		
		{					
			Set rs = Etn.execute("select id, site_id from page_templates where uuid = " + escape.cote(templateUuid));
			if(rs.next())
			{
				PagesGenerator pagesGen = new PagesGenerator(Etn);

				templateHtml = pagesGen.getPageTemplateHtml(rs.value("id"), rsLang.value("langue_id"), rs.value("site_id"), contentId);
				status = STATUS_SUCCESS;
			}
		}
    }
    catch(Exception ex){
        message = ex.getMessage();
        ex.printStackTrace();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",templateHtml);
    out.write(jsonResponse.toString());
%>