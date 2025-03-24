<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>

<%
	Set rs = Etn.execute("select * from "+GlobalParm.getParm("COMMONS_DB")+".user_sessions where is_publish_prod_login = 1 and catalog_session_id = " + escape.cote(session.getId()));
	if(rs.rs.Rows > 0) out.write("{\"is_prod_login\":\"true\"}");
	else out.write("{\"is_prod_login\":\"false\"}");
%>
