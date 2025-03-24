<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
int screenNumber = 2;
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.io.DataInputStream"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ include file="common2.jsp" %>

<%@ page import="com.etn.util.FormDataFilter"%>
<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.io.File"%>

<%
  String lang = parseNull(request.getParameter("lang"));
  String formId = parseNull(request.getParameter("form_id"));
  String ruleId = parseNull(request.getParameter("rule_id"));
  String isPreview = parseNull(request.getParameter("ispreview"));
  String isAdmin = parseNull(request.getParameter("is_admin"));


  if(isAdmin.length() == 0)
    isAdmin = "0";
  set_lang(lang, request, Etn,formId);

  Language language = LanguageFactory.instance.getLanguage(lang); 
  
  if(language == null){
    language = getLangs(Etn,getFormSiteId(Etn,formId)).get(0);
  }
  lang = language.getCode();
  String langId = language.getLanguageId();

  String formTitle = "Form";
  
  Set formRs = Etn.execute("SELECT title FROM process_forms pf, process_form_descriptions pfd WHERE pf.form_id = pfd.form_id AND langue_id = " + escape.cote(langId) + " AND pf.form_id = " + escape.cote(formId));

  if(formRs.next()){
    formTitle = parseNull(formRs.value("title"));
  }

  String direction = language.getDirection();
  JSONObject data = getDataObject(Etn, request, formId, langId, lang, ruleId, isPreview, isAdmin);
%>

<!DOCTYPE html>
<html lang="<%=lang%>" xmlns="http://www.w3.org/1999/xhtml" dir="<%=direction%>">
<head>

<title><%= formTitle%></title>

<%
    JSONArray metaData = data.getJSONArray("metaData");

    for(int i = 0; i < metaData.length(); i++){

      out.write(metaData.getString(i));
    }
%>

<%
	if("1".equals(isAdmin))
	{
		//in case of isAdmin we must return the jquery as this url must be called from an iframe which needs its jquery to be loaded
		out.write("<script type='text/javascript' src='"+request.getContextPath() + "/js/jquery.min.js"+"'></script>");
	}

    JSONArray jsFile = data.getJSONArray("jsFiles");

    for(int i = 0; i < jsFile.length(); i++){
%>
      <script type="text/javascript" src="<%=jsFile.getString(i)%>"></script>
<%
    }	

    JSONArray cssFile = data.getJSONArray("cssFiles");

    for(int i = 0; i < cssFile.length(); i++){
%>
      <link rel="stylesheet" type="text/css" href="<%=cssFile.getString(i)%>" />
<%
    }
%>

<script type="text/javascript">

<%
    out.write(data.get("bodyJs").toString());
%>

</script>

<style type="text/css">
<%
    out.write(data.get("bodyCss").toString());
%>  
</style>

</head>

<body>
  <div id="form_data">
    <% out.write(data.get("formHtml").toString()); %>
  </div>
</body>
</html>

