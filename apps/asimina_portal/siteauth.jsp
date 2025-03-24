<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm, com.etn.util.Logger, com.etn.asimina.util.SiteAuthHelper"%>
<%@include file="common2.jsp"%>
<%!
	private String parseNull(Object o)
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
	Logger.info("siteauth.jsp","---------------------------------------------");
	Logger.info("siteauth.jsp",prodlogtxt + "in site auth");
	Logger.info("siteauth.jsp",prodlogtxt + "in-coming url : " + originalUri);
	Logger.info("siteauth.jsp",request.getSession().getId());
	Logger.info("siteauth.jsp","---------------------------------------------");

	String loginurl = "";
	String muid = parseNull(request.getParameter("muid"));
	if(muid.length() > 0)
	{
		com.etn.util.Logger.info("siteauth.jsp","---------------------------------------------");
		com.etn.util.Logger.info("siteauth.jsp","muid passed : " + muid);
		com.etn.util.Logger.info("siteauth.jsp","---------------------------------------------");
		
		loginurl = SiteAuthHelper.getInstance().getLoginUrlForMenu(Etn, muid);
	}
	if(parseNull(loginurl).length() == 0) loginurl = SiteAuthHelper.getInstance().getLoginUrl(Etn, originalUri);
	
	if(loginurl.contains("?")) loginurl += "&";
	else loginurl += "?";
	
	loginurl += "_tm=" + System.currentTimeMillis();
	loginurl += "&_ref=" + java.net.URLEncoder.encode(originalUri, "UTF-8") ;

	response.sendRedirect(loginurl);

%>