<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp"%>


<%
	String menuid = parseNull(request.getParameter("menuid"));
	String siteid = getSiteId(session);	
	Set rss = Etn.execute("select * from site_menus where site_id = "+escape.cote(siteid)+" and id = " + escape.cote(menuid));		
	//checking if the menu id provided was of same site as user can temper the url
	if(rss.rs.Rows == 0) 
	{		
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
		response.setHeader("Location", "site.jsp" + "?errmsg=The menu you are trying to view does not belong to the selected site");
		return;
	}

	String[] ids = request.getParameterValues("id");
	String[] apply_tos = request.getParameterValues("apply_to");
	String[] prod_apply_tos = request.getParameterValues("prod_apply_to");
	String[] add_gtm_scripts = request.getParameterValues("add_gtm_script");
	String[] trusted_domain_cache = request.getParameterValues("trusted_domain_cache");

	if(ids != null)
	{
		for(int i=0; i<ids.length; i++)
		{
			String applyto = parseNull(apply_tos[i]);
			if(applyto.toLowerCase().startsWith("https://")) applyto = applyto.substring(8);
			else if(applyto.toLowerCase().startsWith("http://")) applyto = applyto.substring(7);
			applyto = applyto.trim();
			if(applyto.endsWith("/")) applyto = applyto.substring(0, applyto.lastIndexOf("/"));

			String prodapplyto = parseNull(prod_apply_tos[i]);
			if(prodapplyto.toLowerCase().startsWith("https://")) prodapplyto = prodapplyto.substring(8);
			else if(prodapplyto.toLowerCase().startsWith("http://")) prodapplyto = prodapplyto.substring(7);
			prodapplyto = prodapplyto.trim();
			if(prodapplyto.endsWith("/")) prodapplyto = prodapplyto.substring(0, prodapplyto.lastIndexOf("/"));

			Etn.executeCmd("update menu_apply_to set add_gtm_script = "+escape.cote(add_gtm_scripts[i])+", prod_apply_to = "+escape.cote(prodapplyto)+", apply_to = "+escape.cote(applyto)+" where id = " + escape.cote(ids[i]) );
			
			//check if menu is published and this rule exists in prod db then we update its value ... otherwise we update in preprod db
			Set rsP = Etn.execute("select * from "+GlobalParm.getParm("PROD_DB")+".menu_apply_to where id = " + escape.cote(ids[i]));
			if(rsP.next())
			{
				Etn.executeCmd("update "+GlobalParm.getParm("PROD_DB")+".menu_apply_to set cache = "+parseNull(trusted_domain_cache[i])+" where id ="+escape.cote(ids[i]));
			}
			else
			{
				Etn.executeCmd("update menu_apply_to set cache = "+parseNull(trusted_domain_cache[i])+" where id ="+escape.cote(ids[i]));
			}
		}
		Etn.executeCmd("update site_menus set version = version + 1, updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+" where id = " + escape.cote(menuid));

	}
//	response.sendRedirect("menudesigner.jsp?siteid="+siteid+"&menuid="+menuid);

	response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
	response.setHeader("Location", "menudesigner.jsp?menuid="+menuid);

%>
