<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, com.etn.asimina.util.ApplyPageTemplateHelper, com.etn.asimina.util.SiteAuthHelper"%>

<%
	//This jsp will be called by portal engine only
	//Engine will call it for prodportal only when a site is published
	//We have to reload page templates which are loaded once by the Singleton class ApplyPageTemplateHelper	
	
	String siteid = request.getParameter("siteid");
	if(siteid == null || siteid.length() == 0) 
	{
		out.write("{\"status\":1}");
		return;
	}
	
	String ip = com.etn.asimina.util.PortalHelper.getIP(request);
	if(ip.equals("127.0.0.1") == false)
	{
		out.write("{\"status\":2}");
		return;
	}	

	List<String> ids = new ArrayList<>();
	Set rs = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".page_templates where site_id = "+escape.cote(siteid));	
	while(rs.next())
	{
		ids.add(rs.value("id"));
	}
	com.etn.util.Logger.info("reloadPageTemplates.jsp", "Reload page templates for site id : " + siteid);
	
	ApplyPageTemplateHelper.getInstance().reload(ids);
	SiteAuthHelper.getInstance().reloadAll();

	out.write("{\"status\":0}");
%>