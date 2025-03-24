<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
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
<%@ include file="../common2.jsp" %>

<%@ page import="com.etn.util.FormDataFilter"%>
<%@ page import="java.io.FileOutputStream"%>
<%@ page import="java.io.File"%>

<%

  String lang = parseNull(request.getParameter("lang"));
  String formId = parseNull(request.getParameter("form_id"));
  String ruleId = parseNull(request.getParameter("rule_id"));
  String isPreview = parseNull(request.getParameter("ispreview"));
  String message = "";
  int status = 0;
  String langId = "";

  set_lang(lang, request, Etn, formId);


  Language language = LanguageFactory.instance.getLanguage(lang);
  langId = language.getLanguageId();

  if(language == null){
    message = "Invalid language provided";
    status = 0;
  }
  
  if(lang.length() == 0)
    lang = language.getCode();

  JSONObject forms = new JSONObject();
  JSONObject data = new JSONObject();

  if(formId.length() > 0){

    try{

      data = getDataObject(Etn, request, formId, langId, lang, ruleId, isPreview);
      status = 1;

    } catch(JSONException jex) {

        message = jex.getMessage();
        jex.printStackTrace();
    
    } catch(Exception ex) {

        message = ex.getMessage();
        ex.printStackTrace();
    }
  } else {

    message = "Form id is not found.";
    status = 0;
  }


  forms.put("data", data);
  forms.put("message", message);
  forms.put("status", status);

  out.write(forms.toString());

%>


