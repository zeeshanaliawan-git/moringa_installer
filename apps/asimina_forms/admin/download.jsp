<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /><%@page import="com.etn.lang.ResultSet.Set, java.util.List, java.util.ArrayList"%><%@ page import="java.io.File, java.io.IOException"%><%@ page import="java.io.FileInputStream" %><%@ page import="java.io.InputStream" %><%@ page import="java.io.BufferedInputStream"  %><%!
String parseNull(Object o) {
  if( o == null )
    return("");
  String s = o.toString();
  if("null".equals(s.trim().toLowerCase()))
    return("");
  else
    return(s.trim());
}
%><%
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");


	String formId = parseNull(request.getParameter("exp_formid"));
	String filename = parseNull(request.getParameter("exp_filename")).replace(" ","-").toLowerCase();
	String delimiter = ";";
	String rows = "";
	int i = 0;

	Set rs = Etn.execute("select pff.db_column_name from process_form_fields pff where pff.form_id = " + com.etn.sql.escape.cote(formId) + 
				" and pff.type not in ('hr_line', 'fileupload', 'label', 'imgupload', 'hyperlink', 'button', 'emptyblock', 'textrecaptcha', 'range') "+
				" and pff.db_column_name != '_etn_confirmation_link' order by seq_order, id");

	String value = "";
	while(rs.next()) {

		value = parseNull(rs.value(0));
		if(value.startsWith("_etn_")) value = value.substring("_etn_".length());

		rows += value.replace("\r\n"," ").replace("\n"," ");
		rows += delimiter;
	}

	if(rows.length() > 0)
		rows = rows.substring(0, rows.length()-1);
	
	rows += "\n";

	response.setContentType("APPLICATION/OCTET-STREAM"); 
	response.addHeader("Content-Disposition","attachment; filename="+ filename.replaceAll("/", "").replaceAll("\\\\", "") + ".csv");
	response.setHeader("Cache-Control", "private");
	response.setHeader("Pragma", "private");

	out.write(rows);

%>