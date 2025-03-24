<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.UUID, java.util.Map, java.util.HashMap, java.util.List, java.util.ArrayList, org.json.*"%>
<%@ page import="com.etn.asimina.util.SiteHelper" %>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/commonFormMethod.jsp"%>
<%!
	String parseNull(Object o){
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
%>
<%
	String retJson = "{\"resp\":\"error\"}";

	String name = parseNull(request.getParameter("name"));
	
	String [] languages = request.getParameterValues("languages");
	
	int id = Etn.executeCmd("insert into sites (suid, name, created_by) values (uuid(), "+escape.cote(name)+", "+escape.cote(""+Etn.getId())+") ");
	if(id > 0)
	{
		try{
			for(String langId:languages){
				SiteHelper.insertSiteLang(Etn,id+"",langId);
			}

	        // create dafault page template
	        String PAGES_DB = GlobalParm.getParm("PAGES_DB");
	        String pid = "" + Etn.getId();

	        String q = "REPLACE INTO "+PAGES_DB+".page_templates (name, site_id, custom_id, description, template_code, is_system, uuid, created_ts, updated_ts, created_by, updated_by ) VALUES "
	            + " ( 'Default template', " + escape.cote(""+id) + ", 'default_template', 'Default page template', "
	            + " '<!DOCTYPE html>\n<html>\n    <head>\n        \n    </head>\n    <body>\n        ${content}\n    </body>\n</html>', "
	            + " '1', UUID(), NOW(), NOW(), " + escape.cote(pid) + ", " + escape.cote(pid) + " ) ";
	        int templateId = Etn.executeCmd(q);
	        if(templateId <= 0) throw new Exception("Error in creating default page template");

			q = "REPLACE INTO "+PAGES_DB+".page_templates_items(page_template_id, name, custom_id, sort_order, created_ts, updated_ts, created_by, updated_by) VALUES "
	            + " ( " + escape.cote(""+templateId) + ", 'Content', 'content', '0', NOW(), NOW(), " + escape.cote(pid) + ", " + escape.cote(pid) + " ) ";
	        int templateItemId = Etn.executeCmd(q);
	        if(templateItemId <= 0) throw new Exception("Error in creating default page template");

			q = " REPLACE INTO "+PAGES_DB+".page_templates_items_details( item_id, langue_id, css_classes, css_style ) "
				+ " SELECT " + escape.cote(""+templateItemId) + " AS item_id, "
	    		+ " l.langue_id AS langue_id, '' AS css_classes, '' AS css_style "
				+ " FROM "+PAGES_DB+".`language` AS l ";
			Etn.executeCmd(q);

			// create sign up and forgot form by default at the time of site creation.
			String formName = name.replaceAll("\\s", "_");
			createSignUpForm(""+id, formName, Etn);
			createForgotPasswordForm(""+id, formName, Etn);

			Etn.executeCmd("update "+GlobalParm.getParm("COMMONS_DB")+".user_sessions set selected_site_id = "+escape.cote(""+id)+" where menu_session_id = " + escape.cote(""+session.getId()));
			//we just enter an empty row in shop parameters as it is required at various places
			Etn.executeCmd("insert into "+GlobalParm.getParm("CATALOG_DB")+".shop_parameters (site_id) value ("+escape.cote(""+id)+") ");

			retJson = "{\"resp\":\"success\",\"site_id\":\""+id+"\"}";
		}
		catch(Exception ex){
			ex.printStackTrace();
			if(id > 0){
				Etn.executeCmd("DELETE FROM sites WHERE id = " + escape.cote(""+id));
			}
		}
	}

	out.write(retJson);
%>
