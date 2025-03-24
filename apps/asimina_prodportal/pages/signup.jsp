<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>

<%@ include file="../clientcommon.jsp"%>

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
	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;		
	}
	
	boolean signupFormConfigured = false;
	if(parseNull(request.getParameter("muid")).length() > 0)
	{
		Set rs = Etn.execute("select p.* from "+GlobalParm.getParm("FORMS_DB")+".process_forms p, site_menus m where p.`type` = 'sign_up' and m.site_id = p.site_id and m.menu_uuid = "+escape.cote(parseNull(request.getParameter("muid"))));
		if(rs.next()) signupFormConfigured = true;
	}
	
	String _jsp = "defaultsignup.jsp";
	if(signupFormConfigured)
	{		
		String colname = "register_url";
		if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))) colname = "register_prod_url";
		Set rs2 = Etn.execute("select "+colname+" from site_menus where menu_uuid = "+escape.cote(parseNull(request.getParameter("muid"))));
		rs2.next();
		
		if(parseNull(rs2.value(0)).length() > 0)
		{
			response.sendRedirect(parseNull(rs2.value(0)));
			return;
		}
		_jsp = "customsignup.jsp";
	}
	
	//when coming from cart screen we will always go to default signup as in this case we have to autologin the user which cannot be handled through the signup form
	String isCart = parseNull(request.getParameter("isCart"));
	if(isCart.equals("1")) _jsp = "defaultsignup.jsp";


	request.getRequestDispatcher(_jsp).forward(request,response);		
%>