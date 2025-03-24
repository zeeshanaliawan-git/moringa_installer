<%@page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN" "http://www.w3.org/TR/html4/strict.dtd">
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>

<br><img src='../img/puce3.png' border='0'>&nbsp;<a href='javascript://' onclick='getF(0);'>Create a new SMS</a><br>
<%
Set rsM = Etn.execute("select * from sms"); 
while(rsM.next()){
	out.write("<br><img src='../img/puce3.png' border='0'>&nbsp;<a href='javascript://' onclick='getF("+rsM.value("sms_id")+");'>"+rsM.value("sms_id")+" - "+rsM.value("nom")+"</a><br>");
}
%>
