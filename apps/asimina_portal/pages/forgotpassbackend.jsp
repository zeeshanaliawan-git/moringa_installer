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

	public boolean isValidEmailAddress(String email) 
	{
       	String ePattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$";
		java.util.regex.Pattern p = java.util.regex.Pattern.compile(ePattern);
           	java.util.regex.Matcher m = p.matcher(email);
           	return m.matches();
   	}
%>


<%
	String username = parseNull(request.getParameter("username"));

	String _showUsernameField = parseNull(request.getParameter("_showUsernameField"));
	boolean bShowUsernameField = "1".equals(_showUsernameField);
	String token = parseNull(request.getParameter("_t"));
	String muid = parseNull(request.getParameter("muid"));

	boolean tokenmatch = false;
	String sToken = parseNull(com.etn.asimina.session.ClientSession.getInstance().getParameter(Etn, request, "forgot_password_token"));
	if(sToken.equals(token)) tokenmatch = true;

	if(!tokenmatch)
	{
		out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Token mis-match. Refresh the page and try again")+"\"}");
		return;
	}

	if(username.length() == 0)
	{
		if(bShowUsernameField) out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Provide your account username")+"\"}");
		else out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Provide your account email")+"\"}");
		return; 
	}

	String siteid = parseNull(request.getParameter("site_id"));
	if(siteid.length() == 0)
	{
		Set rsMenu = Etn.execute("Select * from site_menus where menu_uuid = " + escape.cote(muid));
		if(rsMenu.next()) siteid = rsMenu.value("site_id");
	}
	if(siteid.length() == 0)
	{
		System.out.println("ERROR::forgotpassbackend.jsp::site id is missing");
		out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Unable to proceed due to missing information")+"\"}");
		return;
	}


	Set rs = Etn.execute("select * from clients where site_id = "+escape.cote(siteid)+" and username = " + escape.cote(username));
	if(rs.next())
	{		
		com.etn.asimina.session.ClientSession.getInstance().removeParameter(Etn, request, "forgot_password_token");
		Etn.executeCmd("update clients set forgot_pass_muid = "+escape.cote(muid)+", forgot_password = 1  where id = " + escape.cote(rs.value("id")));
		out.write("{\"status\":\"success\",\"msg\":\""+libelle_msg(Etn, request, "An email with the instructions is sent to your account email address")+"\"}");
		Etn.execute("Select semfree("+escape.cote(com.etn.beans.app.GlobalParm.getParm("SELFCARE_SEMAPHORE"))+")");
	}
	else
	{
		if(bShowUsernameField) out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Login provided is not registered with us")+"\"}");
		else out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Email provided is not registered with us")+"\"}");
	}
 
%>
