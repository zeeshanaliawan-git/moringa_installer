<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, java.util.Map, java.util.LinkedHashMap, com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp"%>
<%!
	String getSiteDomain(com.etn.beans.Contexte Etn, String siteid)
	{
		Set rs = Etn.execute("select * from sites where id = " + escape.cote(siteid));
		rs.next();
		String domain = parseNull(rs.value("domain")).toLowerCase();
		domain = domain.replace("https://","").replace("http://","");
		if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));
		
		return domain;
	}
%>
<%
	String menuid = parseNull(request.getParameter("id"));
	String menupath = parseNull(request.getParameter("menupath"));
	String lang = parseNull(request.getParameter("lang"));
	String siteid = getSiteId(session);
	
	String currentSiteDomain = getSiteDomain(Etn, siteid);
	
	//first verify there should be only 1 menu per language
	String qry = "Select * from site_menus where deleted = 0 and site_id = " + escape.cote(siteid) + " and lang = "  + escape.cote(lang);
	if(menuid.length() > 0) qry += " and id <> " + escape.cote(menuid);
	com.etn.util.Logger.debug("verifymenupath.jsp", qry);
	Set rs = Etn.execute(qry);
	if(rs.rs.Rows > 0)
	{
		out.write("{\"status\":1,\"msg\":\"A site can have only one menu per language. There is already a language defined for the selected language.\"}");
		return;
	}

	if(menupath.length() == 0)
	{
		out.write("{\"status\":1,\"msg\":\"Menu path cannot empty\"}");
		return;
	}
	
	if(menupath.startsWith("/")) menupath = menupath.substring(1);
	if(!menupath.endsWith("/")) menupath = menupath + "/";		

	if(menupath.equals("/"))
	{
		out.write("{\"status\":1,\"msg\":\"Menu path cannot be /\"}");
		return;
	}

	qry = "select m.*, s.name as sitename from site_menus m, sites s where m.deleted = 0 and s.id = m.site_id and coalesce(m.production_path, '') <> '' and m.production_path = " + escape.cote(menupath);
	if(menuid.length() > 0) qry += " and m.id <> " + escape.cote(menuid);
	com.etn.util.Logger.debug("verifymenupath.jsp", qry);
	rs = Etn.execute(qry);
	if(rs.next())
	{
		String conflictSiteId = parseNull(rs.value("site_id"));
		String conflictDomain = getSiteDomain(Etn, conflictSiteId);

		if(currentSiteDomain.equals(conflictDomain))
		{
			out.write("{\"status\":1,\"msg\":\"Path conflict. Production path given is conflicting with Menu : "+rs.value("name").replace("\"","\\\"")+" in Site : "+rs.value("sitename").replace("\"","\\\"")+". Sites with same domain cannot share paths\"}");
			return;			
		}
		else
		{
			out.write("{\"status\":2,\"msg\":\"WARNING!!! Path conflict. Production path given is conflicting with Menu : "+rs.value("name").replace("\"","\\\"")+" in Site : "+rs.value("sitename").replace("\"","\\\"")+"\"}");
			return;			
		}
	}

	qry = " select m.*, s.name as sitename from site_menus m, sites s where m.deleted = 0 and s.id = m.site_id and coalesce(m.production_path, '') <> '' and " + escape.cote(menupath) + " like concat(production_path,'%') "; 
	if(menuid.length() > 0) qry += " and m.id <> " + escape.cote(menuid);	
	com.etn.util.Logger.debug("verifymenupath.jsp", qry);
	rs = Etn.execute(qry);
	if(rs.next())
	{
		String conflictSiteId = parseNull(rs.value("site_id"));
		String conflictDomain = getSiteDomain(Etn, conflictSiteId);

		if(currentSiteDomain.equals(conflictDomain))
		{
			out.write("{\"status\":1,\"msg\":\"Path conflict. Menu : "+rs.value("name").replace("\"","\\\"")+" in Site : "+rs.value("sitename").replace("\"","\\\"")+" matches the first part of production path. Sites with same domain cannot share paths\"}");		
			return;
		}
		else
		{
			out.write("{\"status\":2,\"msg\":\"WARNING!!! Path conflict. Menu : "+rs.value("name").replace("\"","\\\"")+" in Site : "+rs.value("sitename").replace("\"","\\\"")+" matches the first part of production path\"}");		
			return;
		}
	}

	qry = " select m.*, s.name as sitename from site_menus m, sites s where m.deleted = 0 and s.id = m.site_id and coalesce(m.production_path, '') <> '' and production_path like " + escape.cote(menupath + "%") + " "; 
	if(menuid.length() > 0) qry += " and m.id <> " + escape.cote(menuid);	
	com.etn.util.Logger.debug("verifymenupath.jsp", qry);

	rs = Etn.execute(qry);
	if(rs.next())
	{
		String conflictSiteId = parseNull(rs.value("site_id"));
		String conflictDomain = getSiteDomain(Etn, conflictSiteId);

		if(currentSiteDomain.equals(conflictDomain))
		{
			out.write("{\"status\":1,\"msg\":\"Path conflict. Production path given matches the first part of Menu : "+rs.value("name").replace("\"","\\\"")+" in Site : "+rs.value("sitename").replace("\"","\\\"")+". Sites with same domain cannot share paths\"}");		
			return;
		}
		else
		{
			out.write("{\"status\":2,\"msg\":\"WARNING!!! Path conflict. Production path given matches the first part of Menu : "+rs.value("name").replace("\"","\\\"")+" in Site : "+rs.value("sitename").replace("\"","\\\"")+"\"}");		
			return;
		}
	}
	out.write("{\"status\":0}");

%>