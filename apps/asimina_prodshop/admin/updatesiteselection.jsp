<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape"%>
<%@ include file="../common.jsp" %>

<%
	String siteid = parseNull(request.getParameter("id"));
	boolean switchSite = true;
	String profil = parseNull(session.getAttribute("PROFIL"));
	Set rs = Etn.execute("Select * from profil where profil = " + escape.cote(profil));
	if(rs.next())
	{		
		if("1".equals(parseNull(rs.value("assign_site"))))
		{
			//confirm the site is assigned to the user
			Set rs2 = Etn.execute("select * from person_sites where site_id = " + escape.cote(siteid) + " and person_id = " + escape.cote(""+Etn.getId()));
			if(rs2.rs.Rows == 0) switchSite = false;
		}
	}
	else switchSite = false;
	
	if(switchSite)
	{
		session.setAttribute("SELECTED_SITE_ID", siteid);

		Set rsSite = Etn.execute("select name from "+com.etn.beans.app.GlobalParm.getParm("PORTAL_DB")+".sites where id="+escape.cote(siteid));
		rsSite.next();
		session.setAttribute("SELECTED_SITE_NAME", parseNull(rsSite.value("name")));

		Etn.executeCmd("update login set selected_site_id = "+escape.cote(siteid)+" where pid = " + escape.cote(""+Etn.getId()));

		out.write("{\"resp\":\"success\"}");		
	}
	else out.write("{\"resp\":\"error\"}");
%>