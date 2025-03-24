<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp"%>

<%
	//now all profils asimina user profils can login for publish to prod
	Set rs = Etn.execute("select * from login l, profil pr, profilperson pp where pr.profil not in ('PROD_CACHE_MGMT','PROD_SITE_ACCESS','TEST_SITE_ACCESS') and l.pid = pp.person_id  and pp.profil_id = pr.profil_id and l.name = "+escape.cote(parseNull(request.getParameter("username")))+" and l.pass = sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(parseNull(request.getParameter("password")))+",':',l.puid),256) ");
	if(rs.rs.Rows == 0)
		out.write("{\"resp\":\"error\",\"msg\":\"Invalid username or password\"}");
	else
	{
		Etn.executeCmd("update "+GlobalParm.getParm("COMMONS_DB")+".user_sessions set is_publish_prod_login = 1 where menu_session_id = " + escape.cote(session.getId()));
		out.write("{\"resp\":\"success\"}");
	} 
%>