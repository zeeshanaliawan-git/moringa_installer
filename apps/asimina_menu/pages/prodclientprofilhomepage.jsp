<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>
<%@ include file="common.jsp"%>
<%
	String siteid = parseNull(getSiteId(request.getSession()));

	String formId = "";
	Set rs = Etn.execute("select p.* from "+GlobalParm.getParm("FORMS_DB")+".process_forms p where p.`type` = 'sign_up' and p.site_id = "+escape.cote(siteid));
	if(rs.next()) formId = parseNull(rs.value("form_id"));
	
	if(formId.length() > 0)
	{		
		response.sendRedirect(GlobalParm.getParm("EXTERNAL_FORMS_LINK") + "admin/search.jsp?___fid=" + formId);
		return;
	}
	else
	{
		String _jsp = "clientprofilhomepage.jsp?isprod=1";
		request.getRequestDispatcher(_jsp).forward(request,response);		
	}
%>