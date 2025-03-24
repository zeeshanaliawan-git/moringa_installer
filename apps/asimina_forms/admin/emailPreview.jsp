<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.io.FileReader"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.io.File, java.io.StringWriter"%>
<%@ page import="freemarker.template.Configuration, freemarker.template.Template, freemarker.cache.*, freemarker.template.TemplateException" %>

<%@ include file="../common2.jsp" %>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%!

    private boolean isLetterOrDigit(char c) {
        return (c == '_' || Character.isLetterOrDigit(c));
    }

%>
<%
	String filePath = com.etn.beans.app.GlobalParm.getParm("MAIL_UPLOAD_PATH") + "mail";
	String mailId = parseNull(request.getParameter("id"));
	String tableName = parseNull(request.getParameter("table_name"));
	String type = parseNull(request.getParameter("type"));
	String langId = parseNull(request.getParameter("lang"));
    String formId = parseNull(request.getParameter("form_id"));
	String langCode = "";
	String templateName = "";

	String finalPath = filePath + mailId;
    
	Set rs = Etn.execute("select * from language where langue_id != " + escape.cote("1") + " and langue_id = " + escape.cote(langId));
    Set formFieldsRs = Etn.execute("SELECT pff.db_column_name, pff.type, now() as _datetime, curdate() as _date FROM process_form_fields_unpublished pff, process_form_field_descriptions_unpublished pffd WHERE pff.form_id = pffd.form_id AND pff.field_id = pffd.field_id AND pff.form_id = " + escape.cote(formId) + " AND pff.db_column_name IS NOT NULL AND pff.db_column_name != '';");

	if(rs.next()){
		langCode = rs.value("langue_code");
	}

    Map<String, String> formFieldFreemarkerValues = new HashMap<String, String>();

    while(formFieldsRs.next()){

        if(parseNull(formFieldsRs.value("type")).equals("textdate"))
            formFieldFreemarkerValues.put(parseNull(formFieldsRs.value("db_column_name")), parseNull(formFieldsRs.value("_date")));
        else if(parseNull(formFieldsRs.value("type")).equals("textdatetime"))
            formFieldFreemarkerValues.put(parseNull(formFieldsRs.value("db_column_name")), parseNull(formFieldsRs.value("_datetime")));
        else if(parseNull(formFieldsRs.value("type")).equals("number"))
            formFieldFreemarkerValues.put(parseNull(formFieldsRs.value("db_column_name")), "0");
        else
            formFieldFreemarkerValues.put(parseNull(formFieldsRs.value("db_column_name")), "[This label '" + parseNull(formFieldsRs.value("db_column_name")) + "' will be replaced with the value provided by the user.]");
    }    

	if(langCode.length() > 0)
		finalPath += "_" + langCode;

	if(type.equals("freemarker")){

        Configuration cfg = getFreemarkerConfig(com.etn.beans.app.GlobalParm.getParm("MAIL_REPOSITORY"));

        templateName = "/mail" + mailId;

        if(langCode.length() > 0)
        	templateName += "_" + langCode;

        Template template = cfg.getTemplate(templateName + ".ftl");

        StringWriter html = new StringWriter();

        template.process(formFieldFreemarkerValues, html); 

        String content = subStringTemplateContent(html.toString(), tableName);

        if(content.length() > 0)
	        out.write(content);
	    else 
	    	out.write("");

	} else{

		out.write(readDataFromFile(finalPath,tableName));
	}
%>