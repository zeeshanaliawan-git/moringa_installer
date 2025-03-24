<%@page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN" "http://www.w3.org/TR/html4/strict.dtd">
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%
String id = request.getParameter("id");
if(id==null) id ="0";

String nom = request.getParameter("nom");
if(nom==null) nom ="";

String texte = request.getParameter("texte");
if(texte==null) texte ="";

String condicion = request.getParameter("condicion");
if(condicion==null) condicion ="";


String sql="replace into sms (sms_id,nom,texte, where_clause) values("+escape.cote(id)+","+escape.cote(nom)+","+escape.cote(texte)+","+escape.cote(condicion)+")";
//System.out.println(""+sql);
int cmd = Etn.executeCmd(sql);
//int cmd=0;
out.clearBuffer();
out.write( "{\n");
String  n = "";
  out.print(( n+"\"cmd\": \""+cmd+"\""));
  n = ",\n";
  out.write( "\n}");


%>
