<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="common.jsp"%>

<%
	String menuitemname = parseNull(request.getParameter("menuitemname"));
	String parentmenuitemid = parseNull(request.getParameter("parentmenuitemid"));
	String menuid = parseNull(request.getParameter("menuid"));
	
	String siteid = getSiteId(session);	
	Set rss = Etn.execute("select * from site_menus where site_id = "+escape.cote(siteid)+" and id = " + escape.cote(menuid));		
	//checking if the menu id provided was of same site as user can temper the url
	if(rss.rs.Rows == 0) 
	{		
		out.write("{\"response\":\"error\",\"msg\":\"Invalid menu provided\"}");
		return;
	}

	String q = "insert into menu_items (menu_id, menu_item_id, name, display_name, footer_display_name) values (";
	q += escape.cote(menuid);

	if(parentmenuitemid.equals("0")) q += ", null ";
	else q += "," + escape.cote(parentmenuitemid);

	q += "," + escape.cote(menuitemname);
	q += "," + escape.cote(menuitemname);
	q += "," + escape.cote(menuitemname);
	q += ")";

	int id = Etn.executeCmd(q);
	if(id > 0) 
	{
		Etn.executeCmd("update site_menus set updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+" where id = " + escape.cote(menuid));

		//for first level and second level menus we have to show link label field
		boolean showLinkLabel = false;
		boolean showmenuicon = false;

		if(parentmenuitemid.equals("-20")) showLinkLabel = true;
		else
		{
			Set rs1 = Etn.execute("Select * from menu_items where id = " + escape.cote(parentmenuitemid));
			if(rs1.next() && parseNull(rs1.value("menu_item_id")).equals("-20") ) 
			{
				showLinkLabel = true;
				showmenuicon = true;
			}
		}
		out.write("{\"response\":\"success\",\"id\":\""+id+"\",\"name\":\""+menuitemname+"\",\"url\":\"\",\"showlinklabel\":\""+showLinkLabel+"\",\"showmenuicon\":\""+showmenuicon+"\"}");
	}
	else out.write("{\"response\":\"error\"}");
%>
