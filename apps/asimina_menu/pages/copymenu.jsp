<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*"%>

<%@ include file="common.jsp"%>

<%
	List<String> sitemenusCols = new ArrayList<String>();
	sitemenusCols.add("site_id");
	sitemenusCols.add("show_search_bar");
	sitemenusCols.add("follow_us_bar_label");
	sitemenusCols.add("follow_us_bar_color");
	sitemenusCols.add("follow_us_bar_layout");
	sitemenusCols.add("follow_us_bar_icon");
	sitemenusCols.add("search_bar_label");
	sitemenusCols.add("homepage_url");
	sitemenusCols.add("seo_keywords");
	sitemenusCols.add("seo_description");
	sitemenusCols.add("prod_homepage_url");
	sitemenusCols.add("search_bar_url");
	sitemenusCols.add("show_login_bar");
	sitemenusCols.add("login_username_label");
	sitemenusCols.add("login_password_label");
	sitemenusCols.add("login_button_label");
	sitemenusCols.add("logout_button_label");
	sitemenusCols.add("sign_up_label");
	sitemenusCols.add("forgot_password_label");
	sitemenusCols.add("register_url");
	sitemenusCols.add("register_prod_url");
	sitemenusCols.add("forgot_pass_url");
	sitemenusCols.add("forgot_pass_prod_url");
	sitemenusCols.add("my_account_url");
	sitemenusCols.add("my_account_prod_url");
	sitemenusCols.add("search_completion_url");
	sitemenusCols.add("search_params");
	sitemenusCols.add("search_api");
	sitemenusCols.add("enable_cart");
	sitemenusCols.add("404_url");
	sitemenusCols.add("prod_404_url");
	sitemenusCols.add("use_smart_banner");
	sitemenusCols.add("logo_url");
	sitemenusCols.add("smartbanner_days_hidden");
	sitemenusCols.add("smartbanner_days_reminder");
	sitemenusCols.add("smartbanner_position");
	sitemenusCols.add("hide_header");
	sitemenusCols.add("hide_footer");
	sitemenusCols.add("hide_top_nav");
	sitemenusCols.add("animate_on_scroll");
	sitemenusCols.add("default_size");
	sitemenusCols.add("logo_text");
	sitemenusCols.add("enable_breadcrumbs");

	String menuid = parseNull(request.getParameter("menuid"));
	String newname = parseNull(request.getParameter("newname"));

	if(menuid.length() == 0) 
	{
		out.write("{\"response\":\"error\",\"msg\":\"No menu id provided for copy\"}");
		return;
	}
	if(newname.length() == 0)
	{
		out.write("{\"response\":\"error\",\"msg\":\"Provide name for copy\"}");
		return;
	}
	String resp = "success";
	String msg = "";
	
	String iq = "insert into site_menus (menu_uuid, name, created_on, created_by, is_active, deleted, version ";
	for(String c : sitemenusCols)
	{
		iq += "," + c ;
	}
	iq += ") select uuid(), "+escape.cote(newname)+", now(), "+escape.cote(""+Etn.getId())+", 1, 0, 1 ";
	for(String c : sitemenusCols)
	{
		iq += "," + c ;
	}
	iq += " from site_menus where id = " + escape.cote(menuid);

	int newmenuid = Etn.executeCmd(iq);

	if(newmenuid > 0)
	{
		msg = "Menu copied";
		Map<Integer, Integer> ids = new HashMap<Integer, Integer>();
		Set rs = Etn.execute("select * from menu_items where menu_id = " + escape.cote(menuid) + " order by menu_item_id, id ");
		while(rs.next())
		{
			int menuitemid = Integer.parseInt(rs.value("menu_item_id"));
			if(menuitemid > 0)
			{
				if(ids.get(menuitemid) == null) continue;
				menuitemid = ids.get(menuitemid);
			}
			String q = "insert into menu_items (menu_id, menu_item_id, name, url, default_selected, menu_photo_text, menu_photo_tag_line, " +
					" is_external_link, order_seq, seo_keywords, seo_description, prod_url, display_name, display_in_footer, footer_display_name, open_as, visible_to, display_in_header, is_right_align, link_label, menu_icon) "+
					" values ( "+newmenuid+", "+menuitemid+", "+escape.cote(parseNull(rs.value("name")))+", "+escape.cote(parseNull(rs.value("url")))+ 
					" ," +	escape.cote(parseNull(rs.value("default_selected")))+ ","+escape.cote(parseNull(rs.value("menu_photo_text")))+ 
					"," + escape.cote(parseNull(rs.value("menu_photo_tag_line")))+ "," + parseNull(rs.value("is_external_link"))  + 
					"," + escape.cote(parseNull(rs.value("order_seq"))) + "," + escape.cote(parseNull(rs.value("seo_keywords"))) + "," + escape.cote(parseNull(rs.value("seo_description"))) + 
					"," + escape.cote(parseNull(rs.value("prod_url"))) +
					"," + escape.cote(parseNull(rs.value("display_name"))) +
					"," + escape.cote(parseNull(rs.value("display_in_footer"))) +
					"," + escape.cote(parseNull(rs.value("footer_display_name"))) +
					"," + escape.cote(parseNull(rs.value("open_as"))) +
					"," + escape.cote(parseNull(rs.value("visible_to"))) +
					"," + escape.cote(parseNull(rs.value("display_in_header"))) +
					"," + escape.cote(parseNull(rs.value("is_right_align"))) +
					"," + escape.cote(parseNull(rs.value("link_label"))) +
					"," + escape.cote(parseNull(rs.value("menu_icon"))) +
					" ) ";
			int r = Etn.executeCmd(q);
			ids.put(Integer.parseInt(rs.value("id")), r);
		}		

		Etn.executeCmd("insert into additional_menu_items (menu_id, name, url, order_seq, link_type, label, default_selected, prod_url, to_menu_id)  "+ 
				" select "+newmenuid+", name, url, order_seq, link_type, label, default_selected, prod_url, to_menu_id from additional_menu_items where menu_id = " + escape.cote(menuid));

		Etn.executeCmd("insert into menu_apply_to (menu_id, apply_type, apply_to, replace_tags, prod_apply_to, cache, add_gtm_script ) " + 
				" select "+newmenuid+", apply_type, apply_to, replace_tags, prod_apply_to, cache, add_gtm_script from menu_apply_to where menu_id = " + escape.cote(menuid));
	}
	else 
	{
		resp = "error";
		msg = "Error while creating the copy";
	}
	out.write("{\"response\":\""+resp+"\",\"msg\":\""+msg+"\"}");
%>