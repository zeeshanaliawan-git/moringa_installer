<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="common.jsp"%>

<%
	String menuid = parseNull(request.getParameter("menuid"));
	String[] smlinks = request.getParameterValues("smlinks");
	String[] langlinks = request.getParameterValues("langlinks");

	String siteid = getSiteId(session);	
	Set rss = Etn.execute("select * from site_menus where site_id = "+escape.cote(siteid)+" and id = " + escape.cote(menuid));		
	//checking if the menu id provided was of same site as user can temper the url
	if(rss.rs.Rows == 0) 
	{		
		out.write("{\"response\":\"error\",\"msg\":\"Invalid menu provided\"}");
		return;
	}
	
	Etn.executeCmd("delete from additional_menu_items where menu_id = " + escape.cote(menuid));
	if(smlinks != null)
	{
		for(int i=0; i<smlinks.length; i++)
		{
			String url = parseNull(request.getParameter(smlinks[i]+"_url"));
			String order = parseNull(request.getParameter(smlinks[i]+"_order"));

			Etn.executeCmd("insert into additional_menu_items (menu_id, name, url, order_seq, link_type) values ("+escape.cote(menuid)+","+escape.cote(smlinks[i])+","+escape.cote(url)+","+escape.cote(order)+",'social_media') ");
		}
	}
	if(langlinks != null)
	{
		for(int i=0; i<langlinks.length; i++)
		{
//			String url = parseNull(request.getParameter(langlinks[i]+"_url"));
//			String produrl = parseNull(request.getParameter(langlinks[i]+"_prod_url"));
			String tomenuids = parseNull(request.getParameter(langlinks[i]+"_to_menu_id"));
			String order = parseNull(request.getParameter(langlinks[i]+"_order"));
			String label = parseNull(request.getParameter(langlinks[i]+"_label"));
			String default_selected = parseNull(request.getParameter(langlinks[i]+"_default_selected"));


			Etn.executeCmd("insert into additional_menu_items (menu_id, name, label, to_menu_id, default_selected, order_seq, link_type) values ("+escape.cote(menuid)+","+escape.cote(langlinks[i])+","+escape.cote(label)+","+escape.cote(tomenuids)+","+escape.cote(default_selected)+","+escape.cote(order)+",'language') ");
		}
	}

	String showfindastore = parseNull(request.getParameter("showfindastore"));
	if(showfindastore.length() == 0) showfindastore = "0";
	String findastorelabel = parseNull(request.getParameter("findastorelabel"));
	String findastoreurl = parseNull(request.getParameter("findastoreurl"));
	String prodfindastoreurl = parseNull(request.getParameter("prodfindastoreurl"));
	String findastore_open_as = parseNull(request.getParameter("findastore_open_as"));


	String showsearchbar = parseNull(request.getParameter("showsearchbar"));
	if(showsearchbar.length() == 0) showsearchbar = "0";
	String searchapi = parseNull(request.getParameter("searchapi"));

	String searchbarlabel = parseNull(request.getParameter("searchbarlabel"));
	String searchbarurl = parseNull(request.getParameter("searchbarurl"));
	String searchbarprodurl = parseNull(request.getParameter("searchbarprodurl"));


	String followusbarlabel = parseNull(request.getParameter("followusbarlabel"));
	String followusbarcolor = parseNull(request.getParameter("followusbarcolor"));
	String followusbarlayout = parseNull(request.getParameter("followusbarlayout"));

	String showcontactus = parseNull(request.getParameter("showcontactus"));
	if(showcontactus.length() == 0) showcontactus = "0";

	String contactuslabel = parseNull(request.getParameter("contactuslabel"));
	String contactusurl = parseNull(request.getParameter("contactusurl"));
	String prodcontactusurl = parseNull(request.getParameter("prodcontactusurl"));
	String contactus_open_as = parseNull(request.getParameter("contactus_open_as"));


	String showloginbar = parseNull(request.getParameter("showloginbar"));
	if(showloginbar.length() == 0) showloginbar = "0";

	String loginusernamelbl = parseNull(request.getParameter("loginusernamelbl"));
	String loginpasswordlbl = parseNull(request.getParameter("loginpasswordlbl"));
	String loginbuttonlbl = parseNull(request.getParameter("loginbuttonlbl"));
	String logoutbuttonlbl = parseNull(request.getParameter("logoutbuttonlbl"));

	String signuplbl = parseNull(request.getParameter("signuplbl"));
	String forgotpwlbl = parseNull(request.getParameter("forgotpwlbl"));

	String regurl = parseNull(request.getParameter("regurl"));
	String regprodurl = parseNull(request.getParameter("regprodurl"));
	String accnturl = parseNull(request.getParameter("accnturl"));
	String accntprodurl = parseNull(request.getParameter("accntprodurl"));
	String forgotpwurl = parseNull(request.getParameter("forgotpwurl"));
	String forgotpwprodurl = parseNull(request.getParameter("forgotpwprodurl"));

	String searchcompletionurl = parseNull(request.getParameter("searchcompletionurl"));
	String searchprodcompletionurl = parseNull(request.getParameter("searchprodcompletionurl"));
	String searchparams = parseNull(request.getParameter("searchparams"));
	String searchprodparams = parseNull(request.getParameter("searchprodparams"));

	String test404url = parseNull(request.getParameter("404_url"));
	String prod404url = parseNull(request.getParameter("prod_404_url"));


	Etn.executeCmd("update site_menus set version = version + 1, 404_url = "+escape.cote(test404url)+", prod_404_url = "+escape.cote(prod404url)+", updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+", search_completion_url = "+escape.cote(searchcompletionurl)+", search_params = "+escape.cote(searchparams)+", contact_us_open_as = "+escape.cote(contactus_open_as)+", find_a_store_open_as = "+escape.cote(findastore_open_as)+", register_url = "+escape.cote(regurl)+", register_prod_url = "+escape.cote(regprodurl)+", forgot_pass_url= "+escape.cote(forgotpwurl)+", forgot_pass_prod_url= "+escape.cote(forgotpwprodurl)+", my_account_url= "+escape.cote(accnturl)+", my_account_prod_url = "+escape.cote(accntprodurl)+", sign_up_label = "+escape.cote(signuplbl)+", forgot_password_label = "+escape.cote(forgotpwlbl)+", show_login_bar = "+escape.cote(showloginbar)+", login_username_label = "+escape.cote(loginusernamelbl)+", login_password_label= "+escape.cote(loginpasswordlbl)+", login_button_label= "+escape.cote(loginbuttonlbl)+", logout_button_label= "+escape.cote(logoutbuttonlbl)+", search_bar_url = "+escape.cote(searchbarurl)+",prod_contact_us_url = "+escape.cote(prodcontactusurl)+", contact_us_url = "+escape.cote(contactusurl)+", contact_us_label = "+escape.cote(contactuslabel)+", show_contact_us = "+escape.cote(showcontactus)+", search_bar_label = "+escape.cote(searchbarlabel)+", follow_us_bar_label = "+escape.cote(followusbarlabel)+", follow_us_bar_color = "+escape.cote(followusbarcolor)+", follow_us_bar_layout = "+escape.cote(followusbarlayout)+", show_search_bar = "+escape.cote(showsearchbar)+", show_find_a_store= "+escape.cote(showfindastore)+", find_a_store_url = "+escape.cote(findastoreurl)+", prod_find_a_store_url = "+escape.cote(prodfindastoreurl)+", find_a_store_label = "+escape.cote(findastorelabel)+", search_api = "+escape.cote(searchapi)+" where id = " + escape.cote(menuid));

	out.write("{\"response\":\"success\"}");
%>
