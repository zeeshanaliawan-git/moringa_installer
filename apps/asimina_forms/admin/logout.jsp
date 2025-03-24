<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%
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

	response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CATALOG_URL") + "/admin/logout.jsp?t="+System.currentTimeMillis());	

%>