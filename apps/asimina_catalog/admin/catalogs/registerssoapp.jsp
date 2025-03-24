<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>

<%
	String appname = parseNull(request.getParameter("appname"));
	String appurl = parseNull(request.getParameter("appurl"));
	String enablesso = parseNull(request.getParameter("enablesso"));
	String ssosignupurl = parseNull(request.getParameter("ssosignupurl"));

	if(appurl.length() == 0 || appname.length() == 0)
	{
		out.write("{\"resp\":\"error\", \"msg\":\"App name and URL must be provided\"}");
		return;
	}

	if(!appurl.toLowerCase().startsWith("http://") && !appurl.toLowerCase().startsWith("https://"))
	{
		out.write("{\"resp\":\"error\", \"msg\":\"Enter a valid App URL\"}");
		return;
	}

	if("1".equals(enablesso) && ssosignupurl.length() == 0)
	{
		out.write("{\"resp\":\"error\", \"msg\":\"To enable SSO for app you must provide a sign-up URL which will be called to create a User in your application. Parameters passed to that URL will be username and ssoid\"}");
		return;
	}

	if(!"1".equals(enablesso)) ssosignupurl = "";
	if(ssosignupurl.length() > 0 && !ssosignupurl.toLowerCase().startsWith("http://") && !ssosignupurl.toLowerCase().startsWith("https://"))
	{
		out.write("{\"resp\":\"error\", \"msg\":\"Enter a valid Signup URL\"}");
		return;
	}
	
	Set rs = Etn.execute("select * from "+GlobalParm.getParm("SSO_DB")+".apps where name = " + escape.cote(appname));
	if(rs.rs.Rows > 0)
	{
		out.write("{\"resp\":\"error\", \"msg\":\"App with the given name already exists\"}");
		return;
	}

	int i = Etn.executeCmd("insert into "+GlobalParm.getParm("SSO_DB")+".apps (app_id, name, url, is_sso_enabled, signup_url, created_by) values (uuid(),"+escape.cote(appname)+","+escape.cote(appurl)+","+escape.cote(enablesso)+","+escape.cote(ssosignupurl)+","+escape.cote(""+Etn.getId())+") " );

	if(i > 0)
	{
		out.write("{\"resp\":\"success\", \"msg\":\"App registered successfully\"}");
	}
	else
	{
		out.write("{\"resp\":\"error\", \"msg\":\"App registration failed. Try again or contact administrator\"}");
	}
%>
