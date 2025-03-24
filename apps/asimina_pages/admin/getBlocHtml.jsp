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
    String message = "";
    JSONObject data = new JSONObject();

    try{
        String isGenerateForProd = parseNull(request.getParameter("isGenerateForProd"));
		//this jsp is included in api/bloc.jsp so by default we assume isGenerateForProd true
		//if we have to include this jsp else where we must pass the isGenerateForProd as per the need
		if(isGenerateForProd.length() == 0) isGenerateForProd = "1";
		
		System.out.println("admin/getBlocHtml.jsp::isGenerateForProd="+("1".equals(isGenerateForProd)));
        String pageId = parseNull(request.getParameter("pageId"));
        String blocId = parseNull(request.getParameter("blocId"));

        PagesGenerator pagesGen = new PagesGenerator(Etn);
        data = pagesGen.getBlocHtmlByPage(blocId, pageId, ("1".equals(isGenerateForProd)));

        status = STATUS_SUCCESS;
    }
    catch(Exception ex){
        message = ex.getMessage();
        ex.printStackTrace();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>