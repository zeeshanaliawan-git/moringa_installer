<%-- If this page has country specific implementation then create a jsp in countryspecific folder and provide its path in GlobalParm.conf --%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, com.etn.util.Base64, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>


<%@ include file="../clientcommon.jsp"%>
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
	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;
	}

	boolean forgotPasswordFormConfigured = false;
	if(parseNull(request.getParameter("muid")).length() > 0)
	{

		Set rs = Etn.execute("select p.* from "+GlobalParm.getParm("FORMS_DB")+".process_forms p, site_menus m where p.`type` = 'forgot_password' and m.site_id = p.site_id and m.menu_uuid = "+escape.cote(parseNull(request.getParameter("muid"))));
		if(rs.next()) forgotPasswordFormConfigured = true;
	}

	String _jsp = "defaultforgotpassword.jsp";
	if(forgotPasswordFormConfigured)
	{
		String colname = "forgot_pass_url";
		if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))) colname = "forgot_pass_prod_url";
		Set rs2 = Etn.execute("select "+colname+" from site_menus where menu_uuid = "+escape.cote(parseNull(request.getParameter("muid"))));
		rs2.next();

		if(parseNull(rs2.value(0)).length() > 0)
		{
			response.sendRedirect(parseNull(rs2.value(0)));
			return;
		}
		_jsp = "customforgotpassword.jsp";
	}

	request.getRequestDispatcher(_jsp).forward(request,response);
%>