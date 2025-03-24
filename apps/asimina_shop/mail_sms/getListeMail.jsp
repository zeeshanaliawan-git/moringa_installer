<%@page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN" "http://www.w3.org/TR/html4/strict.dtd">
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>

<%!
String parseNull(Object o) {
  if( o == null )
    return("");
  String s = o.toString();
  if("null".equals(s.trim().toLowerCase()))
    return("");
  else
    return(s.trim());
}


%>

<%
	String lang = request.getParameter("lang");
	if(lang == null || lang.length() == 0) lang = "1";
%>
<% if(lang.equals("1")){%>
<br><img src='../img/puce3.png' border='0'>&nbsp;<a href='javascript://' onclick='getF(0);'>Create a new SMS</a><br>
<%}%>
<%
	String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));

	Set rsM = Etn.execute("select * from sms where site_id="+escape.cote(siteId));
	while(rsM.next()){
		out.write("<br><img src='../img/puce3.png' border='0'/>&nbsp;<a  title='Delete Sms' href='javascript://' onclick='deleteSmsTemplate("+rsM.value("sms_id")+");'><i onclick='deleteSmsTemplate(1)' style='color:red;margin-right:10px;margin-left:5px;' class='fa fa-trash'></i></a><a href='javascript://' onclick='getF("+rsM.value("sms_id")+");'>"+rsM.value("sms_id")+" - "+rsM.value("nom")+"</a><br>");
	}
%>

