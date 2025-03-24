<%@page contentType="text/html; charset=UTF-8" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%
String term=request.getParameter("term");
if(term==null)term="";
System.out.println("term="+request.getParameter("term")); %>
<%
String sql="select * from mails";
if(!term.equals("")){
	sql+=" where sujet like "+escape.cote("%"+term+"%")+"";
}


Set rsM = Etn.execute(sql); 
String r = "";
while(rsM.next()){
	r += (r.equals("")?"":",")+"{"+"\"value\":\"mail:"+rsM.value("id")+"\",\"label\":\""+rsM.value("sujet").replace("\"","")+ " (mail:"+rsM.value("id")+")" + "\"}";
	//r += (r.equals("")?"":",")+"{"+"\"label\":\"mail:"+rsM.value("seq")+"\""+"}";
}
//out.write(sql);
sql="select * from sms";
if(!term.equals("")){
	sql+=" where nom like "+escape.cote("%"+term+"%")+"";
}
//out.write(sql);
rsM = Etn.execute(sql);


while(rsM.next()){
	r += (r.equals("")?"":",")+"{"+"\"value\":\"sms:"+rsM.value("sms_id")+"\",\"label\":\""+rsM.value("nom").replace("\"","")+ " (sms:"+rsM.value("sms_id")+")" +"\"}";
	//r += (r.equals("")?"":",")+"{"+"\"label\":\"sms:"+rsM.value("sms_id")+"\""+"}";
}
out.write("["+r+"]");%>