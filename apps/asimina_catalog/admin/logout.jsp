<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.asimina.util.ActivityLog"%>

<%@ include file="../WEB-INF/include/usagelogs.jsp"%>
<%!
    String parseNull(Object o)
    {
        if( o == null )
            return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase()))
            return("");
        else
            return(s.trim());
    }
    // String faqId = parseNull(request.getParameter("faqId"));

%>

<%
	String cp = request.getParameter("cp");

	String login = "";
	if(session.getAttribute("LOGIN") != null) login = (String)session.getAttribute("LOGIN");
	if(login.length() > 0)
	{
		addusagelog(Etn, request, login, "logout success", null);
	}

    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),session.getId()+"","LOGOUT","User",parseNull(session.getAttribute("LOGIN")),parseNull(session.getAttribute("SELECTED_SITE_ID")));

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

	Etn.executeCmd("delete from " + com.etn.beans.app.GlobalParm.getParm("COMMONS_DB") + ".user_sessions where catalog_session_id = " + com.etn.sql.escape.cote("" + session.getId()) );

	String url = request.getContextPath() + "/login.jsp?tm="+System.currentTimeMillis()+"&smsg=Logout successfully!!!!";
	if("1".equals(cp)) url += "&c=1";

    response.sendRedirect(url);

%>