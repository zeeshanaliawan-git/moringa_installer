<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="common.jsp"%>
<%@ include file="/WEB-INF/include/imageHelper.jsp"%>

<%
	String menuitemid = parseNull(request.getParameter("menuitemid"));
		
	Set rs = Etn.execute("select * from menu_items where id = " + escape.cote(menuitemid));	
	rs.next();
	
	String menuid = rs.value("menu_id");
	String siteid = getSiteId(session);	
	Set rss = Etn.execute("select * from site_menus where site_id = "+escape.cote(siteid)+" and id = " + escape.cote(menuid));		
	//checking if the menu id provided was of same site as user can temper the url
	if(rss.rs.Rows == 0) 
	{		
		out.write("{\"response\":\"error\",\"msg\":\"Invalid menu item provided\"}");
		return;
	}
	
	String name = parseNull(request.getParameter("name"));
	String display_name = parseNull(request.getParameter("display_name"));
	String url = parseNull(request.getParameter("url"));
	String defaultselected = parseNull(request.getParameter("defaultselected"));
	String phototext = parseNull(request.getParameter("phototext"));
	String phototagline = parseNull(request.getParameter("phototagline"));
	String externallink = parseNull(request.getParameter("externallink"));
	String seokw = parseNull(request.getParameter("seokeywords"));
	String seodescr = parseNull(request.getParameter("seodescr"));
	String prod_url = parseNull(request.getParameter("prod_url"));
	String display_in_footer = parseNull(request.getParameter("display_in_footer"));
	String footer_display_name = parseNull(request.getParameter("footer_display_name"));
	String open_as = parseNull(request.getParameter("open_as"));
	String visible_to = parseNull(request.getParameter("visible_to"));
	String rightalign = parseNull(request.getParameter("rightalign"));
	if(rightalign.length() == 0 ) rightalign = "0";

	String linklabel = parseNull(request.getParameter("linklabel"));

	String display_in_header = parseNull(request.getParameter("display_in_header"));

	String menuiconimgname = parseNull(request.getParameter("menuiconimgname"));
	String menuiconimg = parseNull(request.getParameter("menuiconimg"));
	String menuphotoimgname = parseNull(request.getParameter("menuphotoimgname"));
	String menuphotoimg = parseNull(request.getParameter("menuphotoimg"));

	String imgFolder = com.etn.beans.app.GlobalParm.getParm("MENU_IMAGES_FOLDER");
	if(menuiconimgname.length() > 0 && menuiconimg.length() > 0)
	{
		menuiconimgname = "micon_" + menuitemid + "." + getExtension(menuiconimgname);
		saveBase64(menuiconimg, imgFolder, menuiconimgname);		
	}

	if(menuphotoimgname.length() > 0 && menuphotoimg.length() > 0)
	{
		menuphotoimgname = "menu_" + menuitemid + "." + getExtension(menuphotoimgname);
		saveBase64(menuphotoimg, imgFolder, menuphotoimgname);
	}


	String q = "update menu_items set visible_to = "+escape.cote(visible_to)+", ";
	if(open_as.length() == 0) q += " open_as = NULL ";
	else q += " open_as = "+escape.cote(open_as);
	q += ", link_label = "+escape.cote(linklabel)+", is_right_align = "+escape.cote(rightalign)+", footer_display_name = "+escape.cote(footer_display_name)+", display_in_header = "+escape.cote(display_in_header)+", display_in_footer = "+escape.cote(display_in_footer)+",display_name = "+escape.cote(display_name)+", prod_url = "+escape.cote(prod_url)+", seo_keywords = "+escape.cote(seokw)+", seo_description = "+escape.cote(seodescr)+", is_external_link = "+escape.cote(externallink)+", menu_photo_text = "+escape.cote(phototext)+", menu_photo_tag_line = "+escape.cote(phototagline)+", name = "+escape.cote(name)+", url = "+escape.cote(url)+", default_selected = "+escape.cote(defaultselected);
	q += ", menu_icon = " + escape.cote(menuiconimgname);
	q += ", menu_photo = " + escape.cote(menuphotoimgname);
	q += " where id = " + escape.cote(menuitemid) ;
	//System.out.println(q);
	int id = Etn.executeCmd(q);
	if(id > 0) 
	{
		rs = Etn.execute("select * from menu_items where id = " + escape.cote(menuitemid));
		rs.next();

		Etn.executeCmd("update site_menus set version = version + 1, updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+" where id = " + escape.cote(parseNull(rs.value("menu_id"))));

		String mphotobase64 = "";
		if(parseNull(rs.value("menu_photo")).length() > 0)
		{
			mphotobase64 = getBase64Image(imgFolder, parseNull(rs.value("menu_photo")));
		}
		String miconbase64 = "";
		if(parseNull(rs.value("menu_icon")).length() > 0)
		{
			miconbase64 = getBase64Image(imgFolder, parseNull(rs.value("menu_icon")));
		}

		out.write("{\"response\":\"success\",\"id\":\""+id+"\",\"name\":\""+parseNull(rs.value("name")).replace("\"","\\\"")+"\",\"url\":\""+parseNull(rs.value("url")).replace("\"","\\\"")+"\",\"defaultselected\":\""+parseNull(rs.value("default_selected")).replace("\"","\\\"")+"\",\"menu_photo\":\""+parseNull(rs.value("menu_photo")).replace("\"","\\\"")+"\",\"photo_text\":\""+parseNull(rs.value("menu_photo_text")).replace("\"","\\\"")+"\",\"photo_tag_line\":\""+parseNull(rs.value("menu_photo_tag_line")).replace("\"","\\\"")+"\",\"externallink\":\""+parseNull(rs.value("is_external_link")).replace("\"","\\\"")+"\",\"seo_keywords\":\""+parseNull(rs.value("seo_keywords")).replace("\"","\\\"")+"\",\"seo_description\":\""+parseNull(rs.value("seo_description")).replace("\"","\\\"")+"\",\"prod_url\":\""+parseNull(rs.value("prod_url")).replace("\"","\\\"")+"\",\"display_name\":\""+parseNull(rs.value("display_name")).replace("\"","\\\"")+"\",\"display_in_footer\":\""+parseNull(rs.value("display_in_footer"))+"\",\"footer_display_name\":\""+parseNull(rs.value("footer_display_name")).replace("\"","\\\"")+"\",\"open_as\":\""+parseNull(rs.value("open_as")).replace("\"","\\\"")+"\",\"visible_to\":\""+parseNull(rs.value("visible_to")).replace("\"","\\\"")+"\",\"display_in_header\":\""+parseNull(rs.value("display_in_header"))+"\",\"rightalign\":\""+parseNull(rs.value("is_right_align"))+"\",\"linklabel\":\""+parseNull(rs.value("link_label")).replace("\"","\\\"")+"\",\"menu_photo_base64\":\""+mphotobase64+"\",\"menu_icon\":\""+parseNull(rs.value("menu_icon")).replace("\"","\\\"")+"\",\"menu_icon_base64\":\""+miconbase64+"\"}");
	}
	else out.write("{\"response\":\"error\",\"msg\":\"Error updating menu item\"}");
%>
