<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

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
		com.etn.util.Logger.debug("updatesiteselection.jsp", ""+session.getId());
		Etn.executeCmd("insert into " + com.etn.beans.app.GlobalParm.getParm("COMMONS_DB") + ".user_sessions (catalog_session_id, selected_site_id) values ("+com.etn.sql.escape.cote("" + session.getId())+","+com.etn.sql.escape.cote(siteid)+") on duplicate key update last_updated_on = now(), selected_site_id = " + com.etn.sql.escape.cote(siteid) );

		session.setAttribute("SELECTED_SITE_ID", siteid);

		Etn.executeCmd("update login set last_site_id = "+escape.cote(siteid)+" where pid = " + escape.cote(""+Etn.getId()));

		out.write("{\"resp\":\"success\"}");		
	}
	else out.write("{\"resp\":\"error\"}");
%>