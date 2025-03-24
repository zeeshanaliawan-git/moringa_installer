<%!
	String ascii7( String  src )
	{
		return removeAccents(src);
	}

	String getAbsoluteUrl(String mainurl, String url) throws Exception
	{
		if(url == null || url.trim().length() == 0) return "";
		if(url.toLowerCase().startsWith("https://") || url.toLowerCase().startsWith("http://")) return url;
		java.net.URL baseUrl = new java.net.URL(mainurl);
		java.net.URL nurl = new java.net.URL( baseUrl , url);
			
		return nurl.toString();
	}

	String removeAccents(String src)
	{
		return com.etn.asimina.util.UrlHelper.removeAccents(src);
	}
	
	String getSiteFolderName(String s)
	{
		return com.etn.asimina.util.PortalHelper.getSiteFolderName(s);
	}
	
	String getMenuPath(com.etn.beans.Contexte Etn, String menuid)
	{		
		return com.etn.asimina.util.PortalHelper.getMenuPath(Etn, menuid);
	}

	String getMenuPathFor(com.etn.beans.Contexte Etn, String menuid, String configCode)
	{
		return com.etn.asimina.util.PortalHelper.getMenuPathFor(Etn, menuid, configCode);
	}

	String getMenuCacheFolder(com.etn.beans.Contexte Etn, String menuid)
	{	
		return com.etn.asimina.util.PortalHelper.getMenuCacheFolder(Etn, menuid);
	}
 
	String getCachedResourcesUrl(com.etn.beans.Contexte Etn, String menuid)
	{
		return com.etn.asimina.util.PortalHelper.getCachedResourcesUrl(Etn, menuid);
	}
			
	java.util.Map<String, String> getGtmScriptCodeForCachedPages(com.etn.beans.Contexte Etn, String menuid, String applicableruleid, String url, String pagetype, String sub_page_type_level1, String sub_page_type_level2, String sub_page_type_level3, String menuVersion) throws Exception
	{
		boolean addgtmscript = false;
		String tablename = "menu_apply_to";
		if("v2".equalsIgnoreCase(menuVersion)) tablename = "sites_apply_to";		
		Set _rsa1 = Etn.execute("select * from "+tablename+" where id = " + com.etn.sql.escape.cote(applicableruleid));
		if(_rsa1.next()) addgtmscript = "1".equals(parseNull(_rsa1.value("add_gtm_script")));
		return getGtmScriptCode(Etn, menuid, addgtmscript, url, pagetype, sub_page_type_level1, sub_page_type_level2, sub_page_type_level3, "", "", "", "no", "");
	}
	
	java.util.Map<String, String> getGtmScriptCodeForCart(com.etn.beans.Contexte Etn, String menuid, String url, String pagetype, String sub_page_type_level1, String sub_page_type_level2, String sub_page_type_level3, String clientuuid, String clienttype, String contracttype, String loggedin, String cookieConsent) throws Exception
	{
		boolean addgtmscript = false;
		Set rsm = Etn.execute("select * from site_menus where id = "+com.etn.sql.escape.cote(menuid));
		if(rsm.next())
		{
			String qry = "select add_gtm_script from menu_apply_to where apply_to = '127.0.0.1' and apply_type = 'url_starting_with' and menu_id = " + com.etn.sql.escape.cote(menuid);
			if("v2".equalsIgnoreCase(rsm.value("menu_version"))) 
			{
				qry = "select add_gtm_script from sites_apply_to where apply_to = '127.0.0.1' and apply_type = 'url_starting_with' and site_id = " + com.etn.sql.escape.cote(rsm.value("site_id"));		
			}
			System.out.println(qry);

			Set _rsa1 = Etn.execute(qry);
			if(_rsa1.next()) addgtmscript = "1".equals(parseNull(_rsa1.value("add_gtm_script")));
		}
		return getGtmScriptCode(Etn, menuid, addgtmscript, url, pagetype, sub_page_type_level1, sub_page_type_level2, sub_page_type_level3, clientuuid, clienttype, contracttype, loggedin, cookieConsent);
	}

	java.util.Map<String, String> getGtmScriptCode(com.etn.beans.Contexte Etn, String menuid, boolean addgtmscript, String url, String pagetype, String sub_page_type_level1, String sub_page_type_level2, String sub_page_type_level3, String clientuuid, String clienttype, String contracttype, String loggedin, String cookieConsent) throws Exception
	{
		Set rs = Etn.execute("select m.*, s.suid as site_uuid, s.datalayer_moringa_perimeter, s.site_auth_enabled, s.gtm_code, s.country_code, s.datalayer_domain, s.datalayer_brand, s.datalayer_market, s.datalayer_asset_type, s.datalayer_orange_zone from site_menus m, sites s where s.id = m.site_id and m.id = " + com.etn.sql.escape.cote(menuid));
		rs.next();

		String menuuuid = parseNull(rs.value("menu_uuid"));
		String mlang = parseNull(rs.value("lang"));
		String gtmcode = parseNull(rs.value("gtm_code"));
		String countrycode = parseNull(rs.value("country_code"));
		String siteuuid = parseNull(rs.value("site_uuid"));

		String datalayerBrand = parseNull(rs.value("datalayer_brand"));
		String datalayerDomain = parseNull(rs.value("datalayer_domain"));
		String datalayerMarket = parseNull(rs.value("datalayer_market"));
		
		String datalayerAssetType = parseNull(rs.value("datalayer_asset_type"));
		String datalayerOrangeZone = parseNull(rs.value("datalayer_orange_zone"));
		String datalayerMoringaPerimeter = parseNull(rs.value("datalayer_moringa_perimeter"));

		String statsScript = "function e_stat(flg) {let eleType='';if(document.head.querySelector(\"meta[name=\'etn:eletype\']\")){eleType=document.head.querySelector(\"meta[name=\'etn:eletype\']\").content;} "+
			"let eleid='';if(document.head.querySelector(\"meta[name=\'etn:eleid\']\")){eleid=document.head.querySelector(\"meta[name=\'etn:eleid\']\").content}; let ctype='';if(document.head.querySelector(\"meta[name=\'etn:ctype\']\")){ctype=document.head.querySelector(\"meta[name=\'etn:ctype\']\").content;} "+
			"let scpageid=''; if(document.head.querySelector(\"meta[name=\'etn:scpageid\']\")){scpageid=document.head.querySelector(\"meta[name=\'etn:scpageid\']\").content;} document.cookie='_page_token="
			+(com.etn.util.Base64.encode(url.getBytes("UTF-8"))).replace("=","")+";path="+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+
			"'; document.cookie='_stat_muid="+menuuuid+";path="+com.etn.beans.app.GlobalParm.getParm("PORTAL_LINK")+
			"'; var e_xhttp = new XMLHttpRequest(); var e_params = 'suid="+siteuuid+"&lang="+mlang+"&eletype='+eleType+'&eleid='+eleid+'&ctype='+ctype+'&scpageid='+scpageid+'&muid="+menuuuid+"&ref='+document.referrer+'&screen_height='+window.screen.height+'&screen_width='+window.screen.width+'&a=1&document_title='+document.title+'&l_href='+location.href+'&ourl="+(com.etn.util.Base64.encode(url.getBytes("UTF-8")))+"&df='+flg; e_xhttp.open('POST', '"+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"stat.jsp', true); e_xhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded; charset=UTF-8'); e_xhttp.send(e_params); }\n";
		java.util.Map<String, String> gtmScripts = new java.util.HashMap<String, String>();
		if(addgtmscript)
		{
			String datalayerPagename = "";
			if(parseNull(pagetype).length() > 0) datalayerPagename += "{{"+pagetype.replace("'","\\'")+"}}"; 
			datalayerPagename += "/"; 
			
			if(parseNull(sub_page_type_level1).length() > 0) datalayerPagename += "{{"+sub_page_type_level1.replace("'","\\'")+"}}"; 
			datalayerPagename += "/"; 
			
			if(parseNull(sub_page_type_level2).length() > 0) datalayerPagename += "{{"+sub_page_type_level2.replace("'","\\'")+"}}"; 
			datalayerPagename += "/"; 
			
			if(sub_page_type_level3.length() > 0) datalayerPagename += "{{"+sub_page_type_level3.replace("'","\\'")+"}}";
			
			String dlStr = "{'cookie_consent':'"+parseNull(cookieConsent).replace("'","\\'")+"','platform':__platform(),'asset_type':'"+datalayerAssetType.replace("'","\\'")+"','orange_zone':'"+datalayerOrangeZone.replace("'","\\'")+"','moringa_perimeter':'"+datalayerMoringaPerimeter.replace("'","\\'")+"','brand':'"+datalayerBrand.replace("'","\\'")+"','section':'"+datalayerDomain.replace("'","\\'")+"','country':'"+countrycode.replace("'","\\'")+"','market_type':'"+datalayerMarket.replace("'","\\'")+"','language':'"+mlang+"','page_type':'"+parseNull(pagetype).replace("'","\\'")+"','page_name':'"+datalayerPagename+"','page_hostname':window.location.hostname,'page_url':window.location.href,'referrer_url':document.referrer,'sub_page_type_level1':'"+sub_page_type_level1.replace("'","\\'")+"','sub_page_type_level2':'"+sub_page_type_level2.replace("'","\\'")+"','sub_page_type_level3':'"+sub_page_type_level3.replace("'","\\'")+"','orange_client_id':'"+parseNull(clientuuid).replace("'","\\'")+"','client_type':'"+parseNull(clienttype).replace("'","\\'")+"','contract_type':'"+parseNull(contracttype).replace("'","\\'")+"','user_logged':'"+parseNull(loggedin).replace("'","\\'")+"','event_category':'','event_action':'','event_label':'','search_query':'','search_results':'','search_section':'','search_clicked_link':'','product_name':'','product_brand':'','product_id':'','product_price':'','product_category':'','product_variant':'','product_position':'','product_quantity':'','product_stock':'','product_stock_number':'','product_sold':'','revenue':'','currency_code':'','order_id':'','tax':'','shipping_cost':'','shipping_type':'','funnel_name':'','funnel_step':'','funnel_step_name':'','product_line':'','order_type':'','acquisition_retention_type':''}";

			String _scr = "<script>function __platform(){var i,a='web',o=!1;return i=navigator.userAgent||navigator.vendor||window.opera,(/(android|bb\\d+|meego).+mobile|avantgo|bada\\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(i)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\\-(n|u)|c55\\/|capi|ccwa|cdm\\-|cell|chtm|cldc|cmd\\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\\-s|devi|dica|dmob|do(c|p)o|ds(12|\\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\\-|_)|g1 u|g560|gene|gf\\-5|g\\-mo|go(\\.w|od)|gr(ad|un)|haie|hcit|hd\\-(m|p|t)|hei\\-|hi(pt|ta)|hp( i|ip)|hs\\-c|ht(c(\\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\\-(20|go|ma)|i230|iac( |\\-|\\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\\/)|klon|kpt |kwc\\-|kyo(c|k)|le(no|xi)|lg( g|\\/(k|l|u)|50|54|\\-[a-w])|libw|lynx|m1\\-w|m3ga|m50\\/|ma(te|ui|xo)|mc(01|21|ca)|m\\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\\-2|po(ck|rt|se)|prox|psio|pt\\-g|qa\\-a|qc(07|12|21|32|60|\\-[2-7]|i\\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\\-|oo|p\\-)|sdk\\/|se(c(\\-|0|1)|47|mc|nd|ri)|sgh\\-|shar|sie(\\-|m)|sk\\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\\-|v\\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\\-|tdg\\-|tel(i|m)|tim\\-|t\\-mo|to(pl|sh)|ts(70|m\\-|m3|m5)|tx\\-9|up(\\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\\-|your|zeto|zte\\-/i.test(i.substr(0,4)))&&(o=!0),o&&(a='web mobile'),a}</script>\n";
			_scr += "<script id='etn_datalayer'>dataLayer = ["+dlStr+"];</script>\n";
			_scr += "<!-- Google Tag Manager -->\n";
			_scr += "<script>" + statsScript + "(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':";
			_scr += "new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],";
			_scr += "j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.onload=function(){ e_stat(1);};j.onerror=function(){e_stat(0);};j.async=true;j.src=";
			_scr += "'//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);";
			_scr += "})(window,document,'script','dataLayer','"+gtmcode+"');</script>\n";
			_scr += "<!-- End Google Tag Manager -->\n";
			
			_scr += "<script id='etn_datalayer_obj'>var _etn_dl_obj = "+dlStr+";</script>\n";

			gtmScripts.put("SCRIPT_SNIPPET", _scr);
			
			_scr = "<noscript><iframe src='//www.googletagmanager.com/ns.html?id="+gtmcode+"' height='0' width='0' style='display:none;visibility:hidden'></iframe></noscript>\n";
			gtmScripts.put("NOSCRIPT_SNIPPET", _scr);
			
		}
		else
		{
			String _scr = "<script>" + statsScript; 
			_scr += "e_stat(1);\n";
			_scr += "</script>";
			gtmScripts.put("SCRIPT_SNIPPET", _scr);			
		}
		return gtmScripts;
	}
%>