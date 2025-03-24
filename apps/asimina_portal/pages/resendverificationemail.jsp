<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, com.etn.util.Base64"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<%@ include file="../lib_msg.jsp"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

%>


<%
	String muid = parseNull(request.getParameter("muid"));
	String username = parseNull(request.getParameter("username"));

	Set rsm = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(muid));
	if(rsm.rs.Rows == 0)
	{
		out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Invalid parameters provided. Click the link in email and try again")+"\"}");		
		return;
	}
	rsm.next();
	String siteid = rsm.value("site_id");
	
	Set rs = Etn.execute("select * from clients where username = " + escape.cote(username) + " and site_id = " + escape.cote(siteid));
	if(rs.next())
	{		
		Etn.executeCmd("update clients set send_verification_email = 1 where id = " + rs.value("id"));
		Etn.executeCmd("select semfree("+escape.cote(com.etn.beans.app.GlobalParm.getParm("SELFCARE_SEMAPHORE"))+")");
		out.write("{\"status\":\"success\",\"msg\":\""+libelle_msg(Etn, request, "We have re-sent the account verification email to your email address") + " " + rs.value("email") +"\"}");	
	}
	else
	{
		out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Email provided is not registered with us")+"\"}");
	}
 
%>
