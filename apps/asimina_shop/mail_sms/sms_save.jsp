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

  String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));

  String id = request.getParameter("id");
  if(id==null) id ="0";

  String nom = request.getParameter("nom");
  if(nom==null) nom ="";

  String texte = request.getParameter("texte");
  if(texte==null) texte ="";

  String condicion = request.getParameter("condicion");
  if(condicion==null) condicion ="";

  String selectedLang = request.getParameter("lang");
  if(selectedLang==null || selectedLang.length() == 0) selectedLang ="1";

  String texteColName = "texte";
  if(selectedLang.equals("1") == false) texteColName = "lang_"+selectedLang+"_texte";

  String sql = "";
  if(id.equals("0")) // new sms
  {
    sql = "insert into sms (nom,"+texteColName+", where_clause,site_id) values ("+escape.cote(nom)+","+escape.cote(texte)+","+escape.cote(condicion)+","+escape.cote(siteId)+") ";
  }
  else
  {
    sql=" update sms set nom = "+escape.cote(nom)+", where_clause = "+escape.cote(condicion)+", "+texteColName+" = "+escape.cote(texte)+" where sms_id = "+escape.cote(id);
  }
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
