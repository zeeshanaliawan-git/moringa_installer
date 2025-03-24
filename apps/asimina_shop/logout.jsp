<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ include file="/WEB-INF/include/usagelogs.jsp"%>

<%
	String cp = request.getParameter("cp");

	String login = "";
	if(session.getAttribute("LOGIN") != null) login = (String)session.getAttribute("LOGIN");
	if(login.length() > 0)
	{
		addusagelog(Etn, request, login, "logout success", null);		
	}

	java.util.Enumeration e = (java.util.Enumeration) (session.getAttributeNames());

	if(Etn.getId() != 0)
	{
		Etn.executeCmd("update login set access_id = '' where pid = " + com.etn.sql.escape.cote(""+Etn.getId()));
	}

	Etn.close();
	while ( e.hasMoreElements())
       {
       	String attr = (String)e.nextElement();
//		out.write(attr + " <br> ");
		session.removeAttribute(attr);
	}	
	session.invalidate();

	String url = request.getContextPath() + "/login.jsp?tm="+System.currentTimeMillis()+"&smsg=Logout successfully!!!!";
	if("1".equals(cp)) url += "&c=1";
	
	response.sendRedirect(url);	

%>