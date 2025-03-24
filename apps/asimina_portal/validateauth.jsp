<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.Base64, javax.servlet.http.Cookie"%>
<%@ include file="clientcommon.jsp"%>

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
	String prodlogtxt = "";
	if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV"))) prodlogtxt = "PROD::";
	String originalUri = parseNull(request.getHeader("X-Original-URI"));
	com.etn.util.Logger.info("validateauth.jsp","---------------------------------------------");
	com.etn.util.Logger.info("validateauth.jsp",prodlogtxt + "in validate auth");
	com.etn.util.Logger.info("validateauth.jsp",prodlogtxt + "in-coming url : " + originalUri);
	com.etn.util.Logger.info("validateauth.jsp",request.getSession().getId());
	com.etn.util.Logger.info("validateauth.jsp",request.getServerName());	
	com.etn.util.Logger.info("validateauth.jsp","---------------------------------------------");
	
	boolean isInternalCall = false;
	if("127.0.0.1".equals(request.getServerName()) || "localhost".equals(request.getServerName().toLowerCase()) ) isInternalCall = true;
		
	if(isInternalCall == false)
	{
		String muid = parseNull(request.getParameter("muid"));
		if(muid.length() > 0)
		{
			com.etn.util.Logger.info("validateauth.jsp","---------------------------------------------");
			com.etn.util.Logger.info("validateauth.jsp","muid passed : " + muid);
			com.etn.util.Logger.info("validateauth.jsp","---------------------------------------------");
		}
		else muid = com.etn.asimina.util.SiteAuthHelper.getInstance().getApplicableMenu(Etn, originalUri);
		com.etn.util.Logger.info("validateauth.jsp","---------------------------------------------");
		com.etn.util.Logger.info("validateauth.jsp","Final muid : " + muid);
		com.etn.util.Logger.info("validateauth.jsp","---------------------------------------------");
		
		org.json.JSONObject json = verifyUserAuth(Etn, request, response, muid);

		if(parseNull(json.optString("login")).equals("1") == false)
		{
			com.etn.util.Logger.info("validateauth.jsp",prodlogtxt + "user not authenticated");
			response.setStatus(401);
			return;
		}		
		com.etn.util.Logger.info("validateauth.jsp",prodlogtxt + "user is already authenticated");
	}
%>