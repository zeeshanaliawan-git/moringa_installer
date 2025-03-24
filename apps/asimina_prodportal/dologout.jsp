<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, javax.servlet.http.Cookie"%>

<% response.setHeader("X-Frame-Options","deny"); %>

<%
	com.etn.asimina.session.ClientSession.getInstance().clear(response);
	com.etn.asimina.session.PortalSession.getInstance().clear(response);

	Cookie[] cookies = request.getCookies();
	String cartCookieName = com.etn.beans.app.GlobalParm.getParm("CART_COOKIE");
	Cookie __cartCookie = new Cookie(cartCookieName, "");
	__cartCookie.setMaxAge(0);
	__cartCookie.setPath(request.getContextPath());
	response.addCookie(__cartCookie);

	for (int i = 0; i < cookies.length; i++) 
	{
		if("_rme_token".equals(cookies[i].getName()))
		{
			Etn.executeCmd("delete from auth_tokens where id = " + escape.cote(cookies[i].getValue()) );
			//break;
		}
	}

	java.util.Enumeration keys = session.getAttributeNames();
	while (keys.hasMoreElements())
	{
		String key = (String)keys.nextElement();
		session.removeAttribute(key);
	}
	out.write("{\"response\":\"success\"}");
%>