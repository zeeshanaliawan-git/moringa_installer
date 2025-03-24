<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, java.util.Map, java.util.LinkedHashMap,java.util.List, com.etn.asimina.util.ActivityLog, com.etn.beans.app.GlobalParm, com.etn.asimina.beans.Language"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file="common.jsp"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/imageHelper.jsp"%>

<%!
	String getMenuCacheFolder(com.etn.beans.Contexte Etn, String menuid)
	{
		Set rs = Etn.execute("Select m.*, s.name as sitename from site_menus m, sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();

		String path = getSiteFolderName(parseNull(rs.value("sitename"))) + "/";
		path += parseNull(rs.value("lang")).toLowerCase() + "/";

		return path;
	}

	boolean isInRules(com.etn.beans.Contexte Etn, String menuid, String href)
	{
		boolean isinrules = false;
		String colname = "apply_to";
		if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))) colname = "prod_apply_to";

		Set rs = Etn.execute("select * from menu_apply_to where menu_id = " + escape.cote(menuid));
		while(rs.next())
		{
			if(href.toLowerCase().startsWith(("http://" + parseNull(rs.value(colname))).toLowerCase()) || href.toLowerCase().startsWith(("https://" + parseNull(rs.value(colname))).toLowerCase()) )
			{
				isinrules = true;
				break;
			}
		}
		return isinrules;
	}

	String getTestSitePath(com.etn.beans.Contexte Etn, String menuid, String menupath, String url) throws Exception
	{
		if(parseNull(url).length() == 0) return "";

		if(url.toLowerCase().startsWith("http:") || url.toLowerCase().startsWith("https:"))
		{
			if(isInRules(Etn, menuid, url))
			{
				return GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(url.getBytes("UTF-8"));
			}
			return url;
		}

		return GlobalParm.getParm("CACHE_EXTERNAL_LINK") + getMenuCacheFolder(Etn, menuid) + url;

	}

	String getProdSitePath(com.etn.beans.Contexte Etn, String domain, String menuid, String menupath, String url) throws Exception
	{
		if(parseNull(url).length() == 0) return "";

		if(url.toLowerCase().startsWith("http:") || url.toLowerCase().startsWith("https:"))
		{
			if(isInRules(Etn, menuid, url))
			{
				return GlobalParm.getParm("PROD_EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(url.getBytes("UTF-8"));
			}
			return url;
		}

		return GlobalParm.getParm("PROD_CACHE_EXTERNAL_LINK") + getMenuCacheFolder(Etn, menuid) + url;
	}

	class AdditionalItem
	{
		String id="";
		String name="";
		String label="";
		String url="";
		String produrl="";
		String order="";
		String type="";
		String defaultselected="";
		String to_menu_id = "";
	}

	AdditionalItem getAdditionalItem(com.etn.beans.Contexte Etn, String menuid, String name, String type)
	{
		AdditionalItem item = new AdditionalItem();
		Set rssm = Etn.execute("select * from additional_menu_items where link_type = "+escape.cote(type)+" and name = "+escape.cote(name)+" and menu_id = "+escape.cote(menuid));
		if(rssm.next())
		{
			item.id = parseNull(rssm.value("id"));
			item.name = parseNull(rssm.value("name"));
			item.url = parseNull(rssm.value("url"));
			item.produrl = parseNull(rssm.value("prod_url"));
			item.order = parseNull(rssm.value("order_seq"));
			item.label = parseNull(rssm.value("label"));
			item.type = parseNull(rssm.value("link_type"));
			item.defaultselected = parseNull(rssm.value("default_selected"));
			item.to_menu_id = parseNull(rssm.value("to_menu_id"));
		}
		return item;
	}
%>

<%

	String warningmsg = parseNull(request.getParameter("warningmsg"));

	String menuid = parseNull(request.getParameter("menuid"));
	String siteid = getSiteId(session);

	if(menuid.length() == 0 && siteid.length() == 0)
	{
	    response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
       	response.setHeader("Location", GlobalParm.getParm("GESTION_URL"));
		return;
	}

	String saveseq = parseNull(request.getParameter("saveseq"));

	if(menuid.length() > 0)
	{
		//we only allow old menus to be configured from this site
		Set rss = Etn.execute("select * from site_menus where coalesce(menu_version, 'V1') = 'V1' and id = " + escape.cote(menuid));
		rss.next();
		//checking if the menu id provided was of same site as user can temper the url
		if(!siteid.equals(parseNull(rss.value("site_id"))))
		{
			response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
			response.setHeader("Location", "site.jsp" + "?errmsg=The menu you are trying to view does not belong to the selected site");
			return;
		}
	}

	Set rss = Etn.execute("select s.* from sites s where s.id = " + escape.cote(siteid));
	rss.next();

	boolean enableECommerce = "1".equals(rss.value("enable_ecommerce"));
	String sitename = parseNull(rss.value("name"));
	String sitedomain = parseNull(rss.value("domain"));
	String websitename = parseNull(rss.value("website_name"));

	if("1".equals(saveseq))
	{
		String[] menuitems = request.getParameterValues("menu_item_id");
		String[] itemsseq = request.getParameterValues("item_order_seq");
		if(menuitems != null && itemsseq != null)
		{
			for(int i=0; i<menuitems.length; i++)
			{
				String _q = "update menu_items set  ";
				if(itemsseq[i].length() == 0) _q += " order_seq = 0  ";
				else _q += "  order_seq = "+escape.cote(itemsseq[i]) ;
				_q += " where id = " + escape.cote(menuitems[i]);
				Etn.executeCmd(_q);
			}
			Etn.executeCmd("update site_menus set version = version + 1, updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+" where id = " + escape.cote(menuid));
		}
	}

//System.out.println("-=--- " + menuid + " " + siteid + " " + saveseq);

	String menuname = parseNull(request.getParameter("menuname"));


	String menupath = parseNull(request.getParameter("menupath"));
	if(menupath.length() > 0)
	{
		if(menupath.startsWith("/")) menupath = menupath.substring(1);
		if(!menupath.endsWith("/")) menupath = menupath + "/";
	}

	String homepageurl = parseNull(request.getParameter("homepageurl"));
	String seodescr = parseNull(request.getParameter("seodescr"));
	String seokeywords = parseNull(request.getParameter("seokeywords"));
	String prodhomepageurl = parseNull(request.getParameter("prodhomepageurl"));
	String mlang = parseNull(request.getParameter("mlang"));
	String javascript_filename = parseNull(request.getParameter("javascript_filename"));
	String enable_cart = parseNull(request.getParameter("enable_cart"));
	String use_smart_banner = parseNull(request.getParameter("use_smart_banner"));
	String smartbanner_position = parseNull(request.getParameter("smartbanner_position"));
	String smartbanner_days_hidden = parseNull(request.getParameter("smartbanner_days_hidden"));
	String smartbanner_days_reminder = parseNull(request.getParameter("smartbanner_days_reminder"));

	String logo_url = parseNull(request.getParameter("logo_url"));
	String logo_text = parseNull(request.getParameter("logo_text"));

	String hide_header = parseNull(request.getParameter("hide_header"));
	String hide_footer = parseNull(request.getParameter("hide_footer"));

	String hide_top_nav = parseNull(request.getParameter("hide_top_nav"));
	String animate_on_scroll = parseNull(request.getParameter("animate_on_scroll"));
	String default_size = parseNull(request.getParameter("default_size"));
	String enable_breadcrumbs = parseNull(request.getParameter("enable_breadcrumbs"));
	if(enable_breadcrumbs.length() == 0) enable_breadcrumbs = "1";

	String ojavascript_filename = javascript_filename;

	boolean uniquescripfilename= true;
	String action = parseNull(request.getParameter("action"));
	if("save".equals(action))
	{
		if(javascript_filename.length() > 0)
		{
			String _qry = "select * from site_menus where javascript_filename = " + escape.cote(javascript_filename);
			if(menuid.length() > 0) _qry += " and id <> " + escape.cote(menuid);
			Set rs4 = Etn.execute(_qry);
			if(rs4.rs.Rows > 0) uniquescripfilename = false;
		}

		if(uniquescripfilename)
		{
			javascript_filename = ascii7(javascript_filename).replace(" ","-");
			if(menuid.length() > 0)
			{
				Etn.executeCmd("update site_menus set production_path = "+escape.cote(menupath)+", enable_breadcrumbs = "+escape.cote(enable_breadcrumbs)+", logo_text= "+escape.cote(logo_text)+", default_size = "+escape.cote(default_size)+",animate_on_scroll = "+escape.cote(animate_on_scroll)+",hide_top_nav = "+escape.cote(hide_top_nav)+",hide_header = "+escape.cote(hide_header)+", hide_footer = "+escape.cote(hide_footer)+", smartbanner_position = "+escape.cote(smartbanner_position)+", smartbanner_days_reminder = "+escape.cote(smartbanner_days_reminder)+", smartbanner_days_hidden = "+escape.cote(smartbanner_days_hidden)+", version = version + 1, logo_url = "+escape.cote(logo_url)+", use_smart_banner = "+escape.cote(use_smart_banner)+", enable_cart = "+escape.cote(enable_cart)+", javascript_filename = "+escape.cote(javascript_filename)+", lang = "+escape.cote(mlang)+", prod_homepage_url = "+escape.cote(prodhomepageurl)+", seo_keywords = "+escape.cote(seokeywords)+", seo_description = "+escape.cote(seodescr)+",  updated_on = now(), updated_by = "+Etn.getId()+", homepage_url = "+escape.cote(homepageurl)+", name = "+escape.cote(menuname)+" where id = " +escape.cote(menuid));
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),menuid+"","UPDATED","Menu",menuname,siteid);

            }
			else
			{
				int id = Etn.executeCmd("insert into site_menus (production_path, enable_breadcrumbs, logo_text, default_size,animate_on_scroll,hide_top_nav,hide_header, hide_footer, smartbanner_position, smartbanner_days_hidden, smartbanner_days_reminder, logo_url, use_smart_banner,enable_cart, javascript_filename, menu_uuid, lang, site_id, name, homepage_url, seo_keywords, seo_description, prod_homepage_url, created_by) values ("+escape.cote(menupath)+","+escape.cote(enable_breadcrumbs)+", "+escape.cote(logo_text)+","+escape.cote(default_size)+","+escape.cote(animate_on_scroll)+","+escape.cote(hide_top_nav)+","+escape.cote(hide_header)+","+escape.cote(hide_footer)+","+escape.cote(smartbanner_position)+","+escape.cote(smartbanner_days_hidden)+","+escape.cote(smartbanner_days_reminder)+","+escape.cote(logo_url)+","+escape.cote(use_smart_banner)+","+escape.cote(enable_cart)+","+escape.cote(javascript_filename)+",UUID(), "+escape.cote(mlang)+","+escape.cote(siteid)+","+escape.cote(menuname)+","+escape.cote(homepageurl)+","+escape.cote(seokeywords)+","+escape.cote(seodescr)+","+escape.cote(prodhomepageurl)+","+Etn.getId()+") ");
				menuid = "" + id;

				//always add 127.0.0.1 by default as users always miss to add it
				Etn.executeCmd("insert into menu_apply_to (menu_id, apply_type, apply_to, add_gtm_script) values ("+escape.cote(menuid)+","+escape.cote("url_starting_with")+","+escape.cote("127.0.0.1")+", 1) ");

				Etn.executeCmd("insert into site_menu_htmls (menu_id) values ("+escape.cote(menuid)+") ");
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id+"","CREATED","Menu",menuname,siteid);

				response.sendRedirect("menudesigner.jsp?menuid="+menuid);
				return;
			}
		}
	}

	String findastorelabel = "";
	String findastoreurl = "";
	String prodfindastoreurl = "";
	String findastoreopenas  = "";

	String showsearchbar = "";
	String contactusurl = "";
	String prodcontactusurl = "";
	String contactusopenas = "";

	String searchbarlabel = "";
	String searchbarurl = "";
	String contactuslabel = "";
	String followusbarlabel = "";
	String followusbarcolor = "";
	String followusbarlayout = "";
	String showloginbar = "";
	String loginusernamelbl = "";
	String loginpasswordlbl = "";
	String loginbuttonlbl = "";
	String logoutbuttonlbl = "";
	String signuplbl = "";
	String forgotpwlbl = "";

	String searchcompletionurl = "";
	String searchparams = "";

	String regurl = "";
	String regprodurl = "";
	String accnturl = "";
	String accntprodurl = "";
	String forgotpwurl = "";
	String forgotpwprodurl = "";
	String logofile = "";
	String smalllogofile = "";
	String faviconfile = "";
	String searchapi = "";
	String test_404_url = "";
	String prod_404_url = "";

    boolean canChangeMenuPath = true;

	if(menuid.length() > 0)
	{
		Set rs = Etn.execute("select * from site_menus where id = " + escape.cote(menuid) + " and site_id = " + escape.cote(siteid));
		if(rs.next())
		{
			menuname = parseNull(rs.value("name"));
			findastorelabel = parseNull(rs.value("find_a_store_label"));
			findastoreurl = parseNull(rs.value("find_a_store_url"));
			prodfindastoreurl = parseNull(rs.value("prod_find_a_store_url"));
			findastoreopenas = parseNull(rs.value("find_a_store_open_as"));
			showsearchbar = parseNull(rs.value("show_search_bar"));
			searchapi = parseNull(rs.value("search_api"));
			contactusurl = parseNull(rs.value("contact_us_url"));
			prodcontactusurl = parseNull(rs.value("prod_contact_us_url"));
			contactusopenas = parseNull(rs.value("contact_us_open_as"));

			searchbarlabel = parseNull(rs.value("search_bar_label"));
			contactuslabel = parseNull(rs.value("contact_us_label"));
			followusbarlabel = parseNull(rs.value("follow_us_bar_label"));
			followusbarcolor = parseNull(rs.value("follow_us_bar_color"));
			followusbarlayout = parseNull(rs.value("follow_us_bar_layout"));
			homepageurl = parseNull(rs.value("homepage_url"));
			prodhomepageurl = parseNull(rs.value("prod_homepage_url"));
			seodescr = parseNull(rs.value("seo_description"));
			javascript_filename = parseNull(rs.value("javascript_filename"));
			enable_cart = parseNull(rs.value("enable_cart"));
			logo_url = parseNull(rs.value("logo_url"));
			logo_text = parseNull(rs.value("logo_text"));
			use_smart_banner = parseNull(rs.value("use_smart_banner"));
			smartbanner_position = parseNull(rs.value("smartbanner_position"));
			smartbanner_days_hidden = parseNull(rs.value("smartbanner_days_hidden"));
			smartbanner_days_reminder = parseNull(rs.value("smartbanner_days_reminder"));

			seokeywords = parseNull(rs.value("seo_keywords"));
			searchbarurl = parseNull(rs.value("search_bar_url"));
			mlang = parseNull(rs.value("lang"));
			showloginbar = parseNull(rs.value("show_login_bar"));
			loginusernamelbl = parseNull(rs.value("login_username_label"));
			loginpasswordlbl = parseNull(rs.value("login_password_label"));
			loginbuttonlbl = parseNull(rs.value("login_button_label"));
			logoutbuttonlbl = parseNull(rs.value("logout_button_label"));
			signuplbl = parseNull(rs.value("sign_up_label"));
			forgotpwlbl = parseNull(rs.value("forgot_password_label"));

			regurl = parseNull(rs.value("register_url"));
			regprodurl = parseNull(rs.value("register_prod_url"));
			accnturl = parseNull(rs.value("my_account_url"));
			accntprodurl = parseNull(rs.value("my_account_prod_url"));
			forgotpwurl = parseNull(rs.value("forgot_pass_url"));
			forgotpwprodurl = parseNull(rs.value("forgot_pass_prod_url"));

			searchcompletionurl = parseNull(rs.value("search_completion_url"));
			searchparams = parseNull(rs.value("search_params"));
			logofile = parseNull(rs.value("logo_file"));
			smalllogofile = parseNull(rs.value("small_logo_file"));
			faviconfile = parseNull(rs.value("favicon"));

			test_404_url = parseNull(rs.value("404_url"));
			prod_404_url = parseNull(rs.value("prod_404_url"));

			hide_header = parseNull(rs.value("hide_header"));
			hide_footer = parseNull(rs.value("hide_footer"));

			hide_top_nav = parseNull(rs.value("hide_top_nav"));
			animate_on_scroll = parseNull(rs.value("animate_on_scroll"));
			default_size = parseNull(rs.value("default_size"));
			enable_breadcrumbs = parseNull(rs.value("enable_breadcrumbs"));
			if(enable_breadcrumbs.length() == 0) enable_breadcrumbs = "1";

			menupath = parseNull(rs.value("production_path"));
			//now check the menu path in db is empty just fill it with default path always
			if(menupath.length() == 0)
			{
				menupath = getDefaultMenuPath(Etn, menuid);
				Etn.executeCmd("update site_menus set production_path = " + escape.cote(menupath) + " where id = " + escape.cote(menuid));
			}
		}
		else
		{
			out.write("Error!!! menu does not exists for the provided site");
			return;
		}
	}

	if(followusbarcolor.length() == 0) followusbarcolor = "white";
	if(followusbarlayout.length() == 0) followusbarlayout = "horizontal";
	if(animate_on_scroll.length() == 0) animate_on_scroll = "1";
	if(default_size.length() == 0) default_size = "large";

	String proddb = GlobalParm.getParm("PROD_DB");
	Set mnp = Etn.execute("select * from "+proddb+".site_menus where id = "  + escape.cote(menuid));

	Set allms = Etn.execute("select * from site_menus where site_id = " + escape.cote(siteid) + " and id <> " + escape.cote(menuid) + " and is_active = 1 order by name ");
	Map<String, String> allmenus = new LinkedHashMap<String, String>();
	allmenus.put("", "- - -");
	while(allms.next())
	{
		allmenus.put(allms.value("id"),allms.value("name"));
	}


	Set rscrawl = Etn.execute("select * from crawler_audit where menu_id = " + escape.cote(menuid) + " and status = 1 ");

	List<Language> langsList = getLangs(Etn,siteid);

	String globalWarnings = "<div class='mb-1'><strong>Ignore the warnings if the site is still under testing phase</strong></div>";
	int warningCount = 0;
	if(mnp.rs.Rows > 0)
	{
		canChangeMenuPath = false;
		if(sitedomain.length() == 0)
		{
			globalWarnings += "<div>Site domain is not defined. Click <a href='siteparameters.jsp' target='_blank'>here</a> to define</div>";
			warningCount++;
		}
		if(websitename.length() == 0)
		{
			globalWarnings += "<div>Site name is not defined. Click <a href='siteparameters.jsp' target='_blank'>here</a> to define</div>";
			warningCount++;
		}
		Set _rs01 = Etn.execute("select * from menu_apply_to where add_gtm_script = 1 and menu_id =" + escape.cote(menuid));
		if(_rs01.rs.Rows > 0)
		{
			if(parseNull(rss.value("gtm_code")).length() == 0 )
			{
				globalWarnings += "<div>GTM code is enabled but some of GTM info is not defined. Click <a href='siteparameters.jsp' target='_blank'>here</a> to define</div>";
				warningCount++;
			}
		}
	}

	String screenTitle = menuname;
	if(screenTitle.length() == 0) screenTitle = "Add Menu";
%>

<html>
<head>


	<title><%=escapeCoteValue(screenTitle)%></title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
	<style>

        .autocomplete-items {
            position: absolute;
            z-index: 19;
            top: 100%;
            left: -24px;
            right: 13px;
        }

        .autocomplete-items li {
            padding: 5px;
            cursor: pointer;
            background-color: #fff;
            border-bottom: 1px solid #ddd;
        }

        .autocomplete-items li:hover {
            background-color: #e9e9e9;
        }

		.autocomplete-item-highlight {
			background-color: #e9e9e9 !important;
		}
       
  </style>
	<style>
		.HeaderFBIcon{background:url('../img/smedia.png') 0 0;width:29px;height:29px;display:inline-block;}
		.HeaderTwitterIcon{background:url('../img/smedia.png') -35px 0;width:29px;height:29px;display:inline-block;}
		.HeaderYTubIcon{background:url('../img/smedia.png') 0 -70px;width:29px;height:29px;display:inline-block;}
		.HeaderGooglePlusIcon{background:url('../img/smedia.png') 0px -35px;width:29px;height:29px;display:inline-block;}
		.HeaderLinkedinIcon{background:url('../img/smedia.png') -35px -35px;width:29px;height:29px;display:inline-block;}
		.HeaderdailymotionIcon{background:url('../img/smedia.png') -35px -70px;width:29px;height:29px;display:inline-block;}
		.HeaderpinterestIcon{background:url('../img/smedia.png') 0px -140px;width:29px;height:29px;display:inline-block;}
		.HeaderinstagramIcon{background:url('../img/smedia.png') 0px -105px;width:29px;height:29px;display:inline-block;}
		.HeadernewsletterIcon{background:url('../img/smedia.png') -35px -105px;width:29px;height:29px;display:inline-block;}

.footer {
	border-top:1px solid #ccc;
	padding-left:2px;
	background:#eee;
	bottom: 0;
	height: 15px;
	left: 0;
	position: fixed;
	width: 100%;
}
	</style>

	<script type="text/javascript" src='<%=GlobalParm.getParm("URL_GEN_JS_URL")%>'></script>


<script>

function openTestSite() {
	window.open("<%=getTestSitePath(Etn, menuid, menupath, homepageurl)%>");
}

function openProdSite() {
	window.open("<%=getProdSitePath(Etn, sitedomain, menuid, menupath, prodhomepageurl)%>");
}
</script>

</head>

<%	
breadcrumbs.add(new String[]{"Navigation", ""});
breadcrumbs.add(new String[]{"Menus", "site.jsp"});
breadcrumbs.add(new String[]{screenTitle, ""});
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2"><%=escapeCoteValue(screenTitle)%></h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" >
					<button type="button" class="btn btn-default btn-primary" id='backbtn' title="Back">Back</button>
				</div>

				<div class="btn-group mr-2" role="group" >
					<button type="button" class="btn btn-default btn-primary" id='copybtn'>Duplicate</button>
				</div>

				<div class="btn-group mr-2" role="group">
					<button type="button" class="btn btn-default btn-primary dropdown-toggle" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Customize</button>
					<div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
						<a href="customcss/customdesign.jsp?menuid=<%=menuid%>" target='_blank' class="onsaveonly dropdown-item" style='display:none'>Customize CSS</a>
					</div>
				</div>

				<div class="btn-group mr-2">
					<a href="javascript:void(0)" id='previewbtn' class="onsaveonly btn btn-success" style='display:none' >Preview Test </a>
					<% if(mnp.rs.Rows > 0) { //check if menu is published to prod already then show prod link %>
							<% if(prodhomepageurl.length() > 0) { %>
							<a href="javascript:void(0)" id='prodpreviewbtn' class="onsaveonly btn btn-success" style='display:none' >Preview Prod </a>
							<% } %>
					<% } %>
				</div>
				<div class="btn-group mr-2">
					<a href="javascript:void(0)" id='publishbtn' class="onsaveonly btn btn-warning" style='display:none' >Publish Test </a>
					<a href="javascript:void(0)"  id='prodpublishbtn' class="onsaveonly btn btn-danger" style='display:none' >Publish Prod </a>
				</div>
				<div class="btn-group mr-2">
					<% if(homepageurl.length() > 0) { %>
						<a href="javascript:void(0)" id='tsite' onclick='openTestSite()' class="onsaveonly btn btn-light" style='display:none'  >Test site</a>
					<% } %>
					<% if(mnp.rs.Rows > 0 && prodhomepageurl.length() > 0) { //check if menu is published to prod already then show prod link %>
						<a href="javascript:void(0)" id='psite' onclick='openProdSite()' class="onsaveonly btn btn-light" style='display:none'  >Prod site</a>
					<% } %>
				</div>
			</div>
			<!-- /buttons bar -->
	</div>
	<!-- /title -->

	<!-- container -->
	<div class="animated fadeIn">
		<div class="row" style="margin-top: 30px;">
			<div class="col-sm-12">
				<div id='menustatusdiv' class="arrondi row" ></div>
			</div>
		</div>

		<% if(warningCount > 0) { %>
		<div id="accordion" class="m-t-10">
			<div class="card">
				<div class="card-header alert-danger" id="headingOne">
					<h5 class="mb-0">
						<button class="btn btn-link collapsed" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
						<%=warningCount%> warning(s)
						</button>
					</h5>
				</div>

				<div id="collapseOne" class="collapse" aria-labelledby="headingOne" data-parent="#accordion">
					<div class="card-body">
						<%=globalWarnings%>
					</div>
				</div>
			</div>
		</div>
		<% } %>
		<div class="m-t-20">
		<div class="alert t-s-grey" role="alert">Homepage <span style="float:right; margin:0px 20px"><button type="button" class="btn btn-primary btn-sm" id='savemenuinfobtn'>Save</button></span></div>
		<div class="alert alert-danger" id="alertBox1" role="alert" style="display:none"></div>
		<div class="alert alert-warning" id="alertBox2" role="alert" style="display:none"></div>
		<form id='mfrm' name='mfrm' action='menudesigner.jsp?menuid=<%=menuid%>' method='post' class='form-horizontal'>
			<input type='hidden' name='action' value='save' />
			<input type='hidden' name='siteid' value='<%=escapeCoteValue(siteid)%>' />
			<input type='hidden' name='isfavicon' id='isfavicon' value='0' />
			<input type='hidden' name='issmalllogo' id='issmalllogo' value='0' />
			<input type='hidden' id='cmenuid' value='<%=menuid%>' />
			<input type='hidden' id='sitefoldername' value='<%=getSiteFolderName(sitename)%>' />

				<div class="form-group row">
					<label for="menuname" class="col-sm-2 control-label">Menu name</label>
					<div class="col-sm-10">
						<input type="text" maxlength='100' class="form-control input-sm" name='menuname' id='menuname' value='<%=escapeCoteValue(menuname)%>'>
					</div>
				</div>
				<div class="form-group row">
					<label for="menuname" class="col-sm-2 control-label">Prod Path</label>
					<div class="col-sm-10">
						<div class="input-group">
							<div class="input-group-prepend">
								<span class="input-group-text"><%=getProdPortalLink(Etn)%></span>
							</div>
							<input <% if(!canChangeMenuPath) { out.write("readonly"); } %> type="text" class="form-control  page_path " id="menupath" name="menupath" value="<%=escapeCoteValue(menupath)%>">
							<div class="input-group" id='pathwarningdiv' style='display:none'>
								<span style='color:red;font-size:12px' id='pathwarningspan'></span>
							</div>
						</div>
					</div>
				</div>
				<div class="form-group row">
					<label for="homepageurl" class="col-sm-2 control-label">Test homepage URL</label>
					<div class="col-sm-10">
						<input type="text" maxlength='255' class="form-control input-sm" name='homepageurl' id='homepageurl' value='<%=escapeCoteValue(homepageurl)%>'>
					</div>
				</div>
				<div class="form-group row">
					<label for="inputPassword3" class="col-sm-2 control-label">Prod homepage url</label>
					<div class="col-sm-10">
						<input type="text" maxlength='255' class="form-control input-sm" name='prodhomepageurl' id='prodhomepageurl' value='<%=escapeCoteValue(prodhomepageurl)%>'>
					</div>
				</div>
				<div class="form-group row">
					<label for="seokeywords" class="col-sm-2 control-label">SEO Keywords</label>
					<div class="input-group col-sm-10">
						<input type="text" maxlength='1000' class="form-control input-sm"  name='seokeywords' id='seokeywords' value='<%=escapeCoteValue(seokeywords)%>'>
						<div class="input-group-append">
						    <span id="seoNbcar2" class="input-group-text"></span>
						</div>
					</div>
				</div>
				<div class="form-group row">
					<label for="seodescr" class="col-sm-2 control-label">SEO Description</label>
					<div class="col-sm-10 input-group">
						<input type="text" maxlength='1000' class="form-control input-sm" name='seodescr' id='seodescr' value='<%=escapeCoteValue(seodescr)%>' >
						<div class="input-group-append">
						    <span id="seoNbcar1" class="input-group-text"></span>
						</div>
					</div>
				</div>

				<div class="form-group row" data-toggle="tooltip" data-placement="top" title="Script filename for menu fetching : This name will be used to generate the script file to load our menus by external sites">
					<label for="javascript_filename" class="col-sm-2 control-label">JavaScript menu name</label>
					<div class="col-sm-10">
						<input type="text" maxlength='100' class="form-control input-sm"  name='javascript_filename' id='javascript_filename' value='<%=escapeCoteValue(javascript_filename)%>' >
					</div>
				</div>
				<div class="form-group row">
					<label for="mlang" class="col-sm-2 control-label">Language</label>
					<div class=" col-sm-4">
						<select name='mlang' id='mlang' class='form-control'>
							<option value=''>- - -</option>
							<% for(Language lang:langsList) { %>
								<option <%if(mlang.equalsIgnoreCase(lang.getCode())){%>selected<%}%> value='<%=escapeCoteValue(lang.getCode())%>'><%=escapeCoteValue(lang.getLanguage())%></option>
							<% } %>
						</select>
					</div>
					<% if(enableECommerce) { %>
					<label for="enable_cart" class="col-sm-2 control-label" data-toggle="tooltip" data-placement="top" title="Enable Cart to show cart icon in menu">Enable Cart</label>
					<div class=" col-sm-4" data-toggle="tooltip" data-placement="top" title="Enable Cart to show cart icon in menu">
						<select id='enable_cart' name='enable_cart' class='form-control'>
							<option <%if("0".equals(enable_cart)){%>selected<%}%> value='0'>No</option>
							<option <%if("1".equals(enable_cart)){%>selected<%}%> value='1'>Yes</option>
						</select>

					</div>
					<% } else {
						out.write("<input type='hidden' value='0' id='enable_cart' name='enable_cart' >");
					}
					%>

				</div>

				<% if("1".equals(parseNull(GlobalParm.getParm("SHOW_SMART_BANNER_OPTION")))) {%>
				<div class="form-group row">
					<label for="use_smart_banner" class="col-sm-2 control-label">Smart banner</label>
					<div class=" col-sm-4">
						<select id='use_smart_banner' name='use_smart_banner' class='form-control'>
							<option <%if("0".equals(use_smart_banner)){%>selected<%}%> value='0'>No</option>
							<option <%if("1".equals(use_smart_banner)){%>selected<%}%> value='1'>Yes</option>
						</select>
					</div>
					<label for="use_smart_banner" class="col-sm-2 control-label">Smart position</label>
					<div class=" col-sm-4">
						<select id='smartbanner_position' name='smartbanner_position' class='form-control'>
							<option <%if("top".equals(smartbanner_position)){%>selected<%}%> value='top'>Top</option>
							<option <%if("bottom".equals(smartbanner_position)){%>selected<%}%> value='bottom'>Bottom</option>
						</select>
					</div>
				</div>
				<div class="form-group row">
					<label for="smartbanner_days_hidden" class="col-sm-2 control-label">Smart days hidden</label>
					<div class=" col-sm-4">
						<input type="text" maxlength='2' class="form-control input-sm" name='smartbanner_days_hidden' id='smartbanner_days_hidden' value='<%=escapeCoteValue(smartbanner_days_hidden)%>'>
					</div>
					<label for="smartbanner_days_reminder" class="col-sm-2 control-label">Smart days reminder</label>
					<div class=" col-sm-4">
						<input type="text" maxlength='2' class="form-control input-sm" name='smartbanner_days_reminder' id='smartbanner_days_reminder' value='<%=escapeCoteValue(smartbanner_days_reminder)%>'>
					</div>
				</div>
				<%}%>
				<div class="form-group row">
					<label for="hide_header" class="col-sm-2 control-label">Hide Header?</label>
					<div class=" col-sm-4">
						<input type="checkbox" <%if("1".equals(hide_header)) {%>checked<%}%> class="form-control input-sm" name='hide_header' id='hide_header' value='1'>
					</div>
					<label for="hide_footer" class="col-sm-2 control-label">Hide Footer?</label>
					<div class=" col-sm-4">
						<input type="checkbox" <%if("1".equals(hide_footer)) {%>checked<%}%> class="form-control input-sm" name='hide_footer' id='hide_footer' value='1'>
					</div>
				</div>

				<div class="form-group row">
       		             <label for="hide_top_nav" class="col-sm-2 control-label">Hide Top Nav?</label>
					<div class=" col-sm-4">
						<input type="checkbox" <%if("1".equals(hide_top_nav)) {%>checked<%}%> class="form-control input-sm" name='hide_top_nav' id='hide_top_nav' value='1'>
					</div>
					<label for="enable_breadcrumbs" class="col-sm-2 control-label">Enable Breadcrumbs?</label>
					<div class=" col-sm-4">
						<select name="enable_breadcrumbs" id="enable_breadcrumbs" class='form-control'>
							<option value="0" <%if("1".equals(enable_breadcrumbs)) {%>selected<%}%> >No</option>
							<option value="1" <%if("1".equals(enable_breadcrumbs)) {%>selected<%}%> >Yes</option>
						</select>
					</div>
				</div>
                <div class="form-group row">
                    <label for="animate_on_scroll" class="col-sm-2 control-label">Animate on scroll?</label>
					<div class=" col-sm-4">
						<input type="checkbox" <%if("1".equals(animate_on_scroll)) {%>checked<%}%> class="form-control input-sm" name='animate_on_scroll' id='animate_on_scroll' value='1'>
					</div>
                    <label for="default_size" class="col-sm-2 control-label">Default Size</label>
					<div class=" col-sm-4">
						<select id='default_size' name='default_size' class='form-control'>
							<option <%if("large".equals(default_size)){%>selected<%}%> value='large'>Large</option>
							<option <%if("small".equals(default_size)){%>selected<%}%> value='small'>Small</option>
						</select>
					</div>
                </div>
				<div class="form-group row">
					<label for="logo_url" class="col-sm-2 control-label">Logo URL</label>
					<div class=" col-sm-4">
						<input type="text" maxlength='255' class="form-control input-sm" name='logo_url' id='logo_url' value='<%=escapeCoteValue(logo_url)%>'>
					</div>
					<label for="logo_text" class="col-sm-2 control-label">Logo Text</label>
					<div class=" col-sm-4">
						<input type="text" maxlength='255' class="form-control input-sm" name='logo_text' id='logo_text' value='<%=escapeCoteValue(logo_text)%>'>
					</div>
				</div>

				<div class="form-group row">
					<!-- Logo -->
					<div class="col-sm-6" id="logorow" style="display:none;">
						<div class="card">
							<div class="card-header">
							    Logo
							  </div>
							<div class="card-body text-center" id="logoimgtd">
								<% if(logofile.length() > 0){%>
								<a href="<%=GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/uploads/<%=logofile%>" target="_blank"><img style='max-width:100%;' src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/uploads/<%=logofile%>?_t=<%=System.currentTimeMillis()%>" /></a>
								<% } %>
							</div>
							<div class="card-footer">
								<div class="alert alert-danger" role="alert" id="alertLogoFile" style="display:none"></div>
								<input type="file" id='logofile' name='logofile' accept=".jpg, .jpeg, .png, .svg">
								<button class="btn btn-link text-primary" type="button" id='logobtn'>Upload <span class="oi oi-data-transfer-upload" aria-hidden="true"></span></button>
								<% if(logofile.length() > 0){%>
									<button type="button" class="btn btn-link text-danger" onclick='javascript:deletelogo()' id='deletelogofilebtn' >Delete <span class="oi oi-x" aria-hidden="true"></span></button>
								<%}%>
									<p><small style='margin-right:15px;color:red'>Preferred size: 50x50 pixels</small><small>Allowed file types: jpg, jpeg, png, svg </small></p>
							</div>
						</div>
					</div>
					<!-- /Logo -->
					<!-- small Logo -->
					<div class="col-sm-6" id="smalllogorow" style="display:none;">
						<div class="card">
							<div class="card-header">
							    Small Logo
							  </div>
							<div class="card-body text-center" id="slogoimgtd">
								<% if(smalllogofile.length() > 0){%>
								<a href="<%=GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/uploads/<%=smalllogofile%>" target="_blank"><img style='max-width:100%;' src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/uploads/<%=smalllogofile%>?_t=<%=System.currentTimeMillis()%>" /></a>
								<% } %>
							</div>
							<div class="card-footer">
								<div class="alert alert-danger" role="alert" id="alertsmalllogofile" style="display:none"></div>
								<input type="file" id='smalllogofile' name='smalllogofile' accept=".jpg, .jpeg, .png, .svg">
								<button class="btn btn-link text-primary" type="button" id='smalllogobtn'>Upload <span class="oi oi-data-transfer-upload" aria-hidden="true"></span></button>
								<% if(smalllogofile.length() > 0){%>
									<button type="button" class="btn btn-link text-danger" onclick='javascript:deleteSmalllogo()' id='deletesmalllogofilebtn' >Delete <span class="oi oi-x" aria-hidden="true"></span></button>
								<%}%>
									<p><small style='margin-right:15px;color:red'>Preferred size: 30x30 pixels</small><small>Allowed file types: jpg, jpeg, png, svg </small></p>
							</div>
						</div>
					</div>
					<!-- /small Logo -->
				</div>
				<div class="form-group row">
					<!-- Favicon -->
					<div class="col-sm-6" id='faviconrow' style="display:none">
						<div class="card">
							<div class="card-header">
							    Favicon
						  </div>
							<div class="card-body text-center"  id='faviconimgtd'>
								<% if(faviconfile.length() > 0) { %>
								<a href="<%=GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/uploads/<%=faviconfile%>" target="_blank"><img style='max-width:100%;' src="<%=GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/uploads/<%=faviconfile%>?_t=<%=System.currentTimeMillis()%>" /></a>
								<% } %>
							</div>
							<div class="card-footer">
								<div class="alert alert-danger" role="alert" id="alertFaviconFile" style="display:none"></div>
								<input type="file" id='faviconfile' name='faviconfile' accept=".png,.ico">
								<button type="button" class="btn btn-link text-primary"  id='faviconbtn'>Upload <span class="oi oi-data-transfer-upload" aria-hidden="true"></span></button>
								<% if(faviconfile.length() > 0){%>
									<button type="button" class="btn btn-link text-danger" onclick='javascript:deletefavicon()' id='deletefaviconfilebtn'>Delete  <span class="oi oi-x" aria-hidden="true"></span></button>
								<%}%>
								<p><small>Allowed file types: png, ico </small></p>
							</div>
						</div>

					</div>
					<!-- /Favicon -->

				</div>
			<input type='hidden' name='warningmsg' id='warningmsg' value=''/>
		</form>

		</div>
		 <!-- /homepage -->


	<div id='designer' style='//display:none; '>


		 <!-- menu tree -->
		<div class="row m-t-20">
			<div class="col-md-4" style="padding-left:0px !important">
				<div class="alert t-s-grey" role="alert">Menu</div>
				<div class="alert alert-danger" role="alert" id="alertMenuItem" style="display:none"></div>
				<div class="alert alert-success" role="alert" id="succMenuItem" style="display:none"></div>
				<div class="form-inline row" nowrap="nowrap">
					<div class="input-group col-sm-12">
						<input type="text" class="form-control" id='mitem' placeholder="Add a new menu" style="height:auto;">
						<div class="input-group-append">
							<button type="submit" class="btn btn-default btn-success" id='mitemaddok'><span class="oi oi-plus" aria-hidden="true" style="padding-top: 5px;padding-bottom: 4px;"></span></button>
							<button id="mitemsave" type="submit" class="btn btn-primary" onclick='saveorderseq()'>Save</button>
						</div>
					</div>
				</div>
				<div style='margin-top:5px; height:552px; overflow-y:auto;' id='menuitems'  ></div>
			</div>
			<div class="col-md-8" style="padding-right:0px !important">
				<div class="alert t-s-grey" role="alert">Edit menu item <span style="float:right; margin:0px 20px"><button type="button" class="btn btn-primary btn-sm" id='updatemenuitembtn'>Save</button></span></div>
				<div class="alert alert-danger" role="alert" id="editItemAlert" style="display:none"></div>
				<div class="alert alert-success" role="alert" id="editItemSucc" style="display:none"></div>
				<div class='form-horizontal' id='' name='' action='' method='post'>
					<div class="form-group row">
						<label for="cmenuitemname" class="col-sm-2 control-label">Name</label>
						<div class="col-sm-10">
							<input type="text" class="form-control input-sm" name='name' id='cmenuitemname' >
						</div>
					</div>
					<div class="form-group row">
						<label for="cmenuitemdisplayname" class="col-sm-2 control-label">Header Label</label>
						<div class="col-sm-10">
							<input type="text" class="form-control input-sm" name='display_name' id='cmenuitemdisplayname' >
						</div>
					</div>
					<div class="form-group row">
						<label for="cmenuitemfooterdisplayname" class="col-sm-2 control-label">Footer Label</label>
						<div class="col-sm-10">
							<input type="text" class="form-control input-sm" name='footer_display_name' id='cmenuitemfooterdisplayname' >
						</div>
					</div>
					<div class="form-group row">
						<label for="cdisplay_in_header" class="col-sm-2 control-label">Display in Header</label>
						<div class=" col-sm-4">
							<input type='checkbox' value='1' name='display_in_header' id='cdisplay_in_header' />
						</div>

						<label for="cdisplay_in_footer" class="col-sm-2 control-label">Display in Footer</label>
						<div class=" col-sm-4">
							<input type='checkbox' value='1' name='display_in_footer' id='cdisplay_in_footer' />
						</div>

					</div>
					<div class="form-group row">
						<label for="cdefaultselected" class="col-sm-2 control-label">Show Selected?</label>
						<div class=" col-sm-4">
							<input type='checkbox' value='1' name='defaultselected' id='cdefaultselected' />
						</div>
						<label for="cdefaultselected" class="col-sm-2 control-label" id='rightalignlabel'>Right align?</label>
						<div class=" col-sm-4">
							<input type='checkbox' value='1' name='rightalign' id='crightalign' />
							<span style='font-size:8pt;color:red'>This option will be effective for Header Level 1 items only<br>For right-to-left languages like arabic this option will actually mean as left align</span>
						</div>
					</div>
					<div class="form-group row">
						<label for="cvisible_to" class="col-sm-2 control-label">Visible To</label>
						<div class=" col-sm-4">
							<select name='visible_to' id='cvisible_to' class='form-control'>
								<option value=''>All</option>
								<option value='logged_in_user'>Logged in users</option>
							</select>
						</div>
					</div>
					<div class="form-group row " id='menuicondiv' style='display:none'>
						<label for="cmenuicon" class="col-md-2 control-label">Menu icon</label>
						<div class="col-sm-4">
							<div class="custom-file">
								<input type="file" class="custom-file-input" id="cmenuicon" name='cmenuicon' accept=".jpg, .jpeg, .png, .svg" onchange="readImageBase64File(event, 'menuiconimgdiv', 'menuiconimg', 'menuiconimgname')">
							  	<label class="custom-file-label" for="customFile">Select Icon</label>
								<p><small style='margin-right:15px;color:red'>Preferred size: 30x30 pixels</small><small>Allowed file types: jpg, jpeg, png, svg </small></p>
							</div>
						</div>
						<div class="col-sm-4">
							<div style='display:none; text-align:center;' id='menuiconimgdiv' >
								<input type='hidden' name='menuiconimgname' id='menuiconimgname' value=''>
								<img src='' style='width:30px; height:30px; background:#eee; padding:1px' id='menuiconimg'/><br/>
								<span style="cursor:pointer; color:red; font-size:11px;" onclick="javascript:clearphotocontent('menuiconimgdiv','menuiconimg', 'menuiconimgname')">Delete</span>
							</div>
						</div>
					</div>
					<div class="form-group row">
						<label for="__menuitemid" class="col-sm-2 control-label">Menu photo</label>
						<div class="col-sm-4">
							<div class="custom-file">
								<input type="file" class="custom-file-input" id="cmenuphoto" name='cmenuphoto' accept=".jpg, .jpeg, .png, .svg" onchange="readImageBase64File(event, 'menuphotodiv', 'menuphotoimg', 'menuphotoimgname')">
							  	<label class="custom-file-label" for="customFile">Select Photo</label>
								<p><small>Allowed file types: jpg, jpeg, png, svg </small></p>
							</div>
						</div>
						<div class="col-sm-4">
							<div style='display:none; text-align:center;' id='menuphotodiv' >
								<input type='hidden' name='menuphotoimgname' id='menuphotoimgname' value=''>
								<img src='' style='max-width:100px; max-height:100px; background:#eee; padding:1px' id='menuphotoimg'/><br/>
								<span style="cursor:pointer; color:red; font-size:11px;" onclick="javascript:clearphotocontent('menuphotodiv','menuphotoimg','menuphotoimgname')">Delete</span>
							</div>
						</div>
					</div>

					<div class="form-group row">
						<label for="cmenuphototagline" class="col-sm-2 control-label">Photo tag line</label>
						<div class="col-sm-10">
							<input type='text' class="form-control" value='' id='cmenuphototagline' name='cmenuphototagline' maxlength="255"/>
						</div>
					</div>

					<div class="form-group row">
						<label for="cmenuphototext" class="col-sm-2 control-label">Photo text</label>
						<div class="col-sm-10">
							<input type='text' class="form-control input-sm" value='' id='cmenuphototext' name='cmenuphototext' maxlength='255' size='70' />
						</div>
					</div>

					<div class="form-group row ">
						<label for="cmenuitemurl" class="col-md-2 control-label">URL Preprod</label>
						<div class=" col-sm-10">
							<div class="input-group">
								<input type="text" class="form-control" name='url' id='cmenuitemurl'>
							</div>
						</div>
					</div>

					<div class="form-group row ">
						<label for="cmenuitemprodurl" class="col-md-2 control-label">URL Prod</label>
						<div class=" col-sm-10">
							<div class="input-group">
								<input type="text" class="form-control" id="cmenuitemprodurl" ><!-- id=inputURLprod -->
							</div>
						</div>
					</div>

					<div class="form-group row " id='linklabeldiv' style='display:none'>
						<label for="clinklabel" class="col-md-2 control-label">Link Label</label>
						<div class=" col-sm-10">
							<div class="input-group">
								<input type="text" class="form-control" id="clinklabel" value="">
							</div>
					</div>
					</div>
					<div class="form-group row">
						<label for="cmseodescr" class="col-sm-2 control-label">Seo descript.</label>
						<div class="col-sm-10">
							<input type="text" maxlength="255" class="form-control input-sm" id='cmseodescr' name='cmseodescr' >
						</div>
					</div>
					<div class="form-group row">
						<label for="cmseokeywords" class="col-sm-2 control-label">Seo keywords</label>
						<div class="col-sm-10">
							<input type="text" maxlength="255" class="form-control input-sm" id='cmseokeywords' name='cmseokeywords' >
						</div>
					</div>

				</div>




			</div>
		</div>
		<!-- /menu tree -->

		<!-- trust domain -->
		<div class="row m-t-20" id="gorules">
			<div class="alert t-s-grey col-sm-12" role="alert">Trust domains
				<div class="btn-group pull-right">
					<button type="button" class="btn btn-default btn-success" id='applyrulebtn'>+ Add a trust domain</button>
					<button type="button" class="btn btn-primary" onclick='updatemenurules()'>Save</button>
				</div>
			</div>
			<div id='applicationdiv' class="col-sm-12"></div>
		</div>
		<!-- /trust domain -->

		<!-- specific blocks -->
		<div class="m-t-20">
			<div class="row">
				<div class="alert t-s-grey col-sm-12" role="alert">Specific blocs <span style="float:right; margin:0px 20px"><button type="button" class="btn btn-primary btn-sm" id='savesocialmedialinks'>Save</button></span></div>
			</div>
			<div class="alert alert-success" role="alert" id="additionalItemSucc" style="display:none"></div>
			<div class="alert alert-danger" role="alert" id="additionalItemErr" style="display:none"></div>
			<div class="row">
				<form name='mfrm2' id='mfrm2' class="col-sm-12" >
					<input type='hidden' name='menuid' value='<%=escapeCoteValue(menuid)%>' />
					<div class="">
						<div class="" id="accordion" >
						  	<div class="card card-info">
								<div class="card-header" role="tab" id="heading3">
							  		<h5 class="mb-0">
							  			<button class="btn btn-link" data-target="#collapse3" type="button" data-toggle="collapse" >Search bar</button></h5>
								</div>
								<div id="collapse3" class="card-collapse collapse" role="tabcard" aria-labelledby="heading3">
							  		<div class="card-body">
										<div class="form-horizontal">
											<div class="form-group row">
												<label for="searchbarlabel" class="col-sm-2 control-label">Label</label>
												<div class="col-sm-10">
													<input type='text' size='25' class="form-control" value='<%=escapeCoteValue(searchbarlabel)%>' name='searchbarlabel' id='searchbarlabel' maxlength='50'/>
												</div>
											</div>
											<div class="form-group row">
												<label for="inputEmail3" class="col-md-2 control-label">Enabled</label>
												<div class=" col-md-4">

													<input type='checkbox' value='1' name='showsearchbar' id='showsearchbar' <% if("1".equals(showsearchbar)){%>checked<%}%> />
												</div>

												<label for="searchapi" class="col-md-2 control-label">Search API</label>
												<div class=" col-md-4">
													<select name='searchapi' id="searchapi" class="form-control">
														<option <% if("internal".equals(searchapi)){%>selected<%}%> value='internal'>Internal</option>
														<% if("1".equals(GlobalParm.getParm("IS_ORANGE_APP"))) { %>
														<option <% if("external".equals(searchapi)){%>selected<%}%> value='external'>Orange API</option>
														<% } %>
														<option <% if("url".equals(searchapi)){%>selected<%}%> value='url'>URL</option>
													</select>
												</div>
											</div>
											<div class="form-group row __searchconfig __externalsearch __urlsearch ">
												<label for="searchbarurl" class="col-sm-2 control-label">Search URL</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(searchbarurl)%>' name='searchbarurl' id='searchbarurl' maxlength='255'/>

												</div>
											</div>
											<div class="form-group row __searchconfig __externalsearch ">
												<label for="searchcompletionurl" class="col-sm-2 control-label">Completion URL</label>
												<div class="col-sm-4">
													<input type="text" class="form-control" value='<%=escapeCoteValue(searchcompletionurl)%>' name='searchcompletionurl' id="searchcompletionurl" placeholder="" maxlength='255'>
												</div>
											</div>
											<div class="form-group row __searchconfig __externalsearch __urlsearch ">
												<label for="searchparams" class="col-sm-2 control-label">Param</label>
												<div class="col-sm-4">
													<input type="text" class="form-control" value='<%=escapeCoteValue(searchparams)%>' name='searchparams' id="searchparams" placeholder="" maxlength='255'>
												</div>
											</div>
										</div>
							  		</div>
								</div>
						  	</div>

						  	<div class="card card-info">
								<div class="card-header" role="tab" id="heading4">
							  		<h5 class="mb-0">
							  			<button class="btn btn-link" data-target="#collapse4" type="button" data-toggle="collapse" >Follow us bar</button></h5>
								</div>
								<div id="collapse4" class="card-collapse collapse" role="tabcard" aria-labelledby="heading4">
							  		<div class="card-body">
										<div class="form-horizontal">
											<div class="form-group row">
												<label for="followusbarlabel" class="col-sm-2 control-label">Label</label>
												<div class="col-sm-10">
													<input type='text' class='form-control' value='<%=escapeCoteValue(followusbarlabel)%>' name='followusbarlabel' id='followusbarlabel' placeholder="">
												</div>
											</div>

											<table id="social_media_select_table" cellpadding="0" cellspacing="0" border="0" align="right" width="90%">

											<%
												AdditionalItem aitem = getAdditionalItem(Etn, menuid, "facebook", "social_media");
												//if(aitem.id.length() == 0)
												aitem.order = "1";
											%>
											<tr>
												<td><input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='smlinks' value='facebook' /></td>
												<td><span class='HeaderFBIcon'></span></td>
												<td><input type='text' name='facebook_url' id='facebook_url' value='<%=escapeCoteValue(aitem.url)%>' size='30' maxlength='255' class="form-control"/></td>
												<input type='hidden' name='facebook_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' />
											<%
												aitem = getAdditionalItem(Etn, menuid, "instagram", "social_media");
												//if(aitem.id.length() == 0)
												aitem.order = "2";
											%>
												<td><input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='smlinks' value='instagram' /></td>
												<td><img src='../img/insta.jpg' style="height:26px; width:26px" alt="Instagram"></td>
												<td><input type='text' name='instagram_url' id='instagram_url' value='<%=escapeCoteValue(aitem.url)%>' size='30' maxlength='255' class="form-control"/></td>
												<input type='hidden' name='instagram_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' />
											</tr>
											<%
												aitem = getAdditionalItem(Etn, menuid, "linkedin", "social_media");
												//if(aitem.id.length() == 0)
												aitem.order = "3";
											%>
											<tr>
												<td><input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='smlinks' value='linkedin' /></td>
												<td><span class='HeaderLinkedinIcon'></span></td>
												<td><input type='text' name='linkedin_url' id='linkedin_url' value='<%=escapeCoteValue(aitem.url)%>' size='30' maxlength='255' class="form-control"/></td>
												<input type='hidden' name='linkedin_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' />
											<%
												aitem = getAdditionalItem(Etn, menuid, "newsletter", "social_media");
												//if(aitem.id.length() == 0)
												aitem.order = "4";
											%>
												<td><input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='smlinks' value='newsletter' /></td>
												<td><span class='HeadernewsletterIcon'></span></td>
												<td><input type='text' name='newsletter_url' id='newsletter_url' value='<%=escapeCoteValue(aitem.url)%>' size='30' maxlength='255' class="form-control"/></td>
												<input type='hidden' name='newsletter_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' />
											</tr>

											<%
												aitem = getAdditionalItem(Etn, menuid, "twitter", "social_media");
												//if(aitem.id.length() == 0)
												aitem.order = "5";
											%>
											<tr>
												<td><input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='smlinks' value='twitter' /></td>
												<td><span class='HeaderTwitterIcon'></span></td>
												<td><input type='text' name='twitter_url' id='twitter_url' value='<%=escapeCoteValue(aitem.url)%>' size='30' maxlength='255' class="form-control"/></td>
												<input type='hidden' name='twitter_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' />
											<%
												aitem = getAdditionalItem(Etn, menuid, "whatsapp", "social_media");
												//if(aitem.id.length() == 0)
												aitem.order = "6";
											%>

												<td><input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='smlinks' value='whatsapp' /></td>
												<td><img src='../img/whatsapp.png' style="height:26px; width:26px" alt="Whatsapp"></td>
												<td><input type='text' name='whatsapp_url' id='whatsapp_url' value='<%=escapeCoteValue(aitem.url)%>' size='30' maxlength='255' class="form-control"/></td>
												<input type='hidden' name='whatsapp_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' />
											</tr>

											<%
												aitem = getAdditionalItem(Etn, menuid, "youtube", "social_media");
												//if(aitem.id.length() == 0)
												aitem.order = "7";
											%>
											<tr>
												<td><input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='smlinks' value='youtube' /></td>
												<td><span class='HeaderYTubIcon'></span></td>
												<td><input type='text' name='youtube_url' id='youtube_url' value='<%=escapeCoteValue(aitem.url)%>' size='30' maxlength='255' class="form-control"/></td>
												<input type='hidden' name='youtube_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' />
											<%
												aitem = getAdditionalItem(Etn, menuid, "snapchat", "social_media");
												//if(aitem.id.length() == 0)
												aitem.order = "8";
											%>
												<td><input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='smlinks' value='snapchat' /></td>
												<td><img src='../img/snapchat.png' style="height:26px; width:26px" alt="Whatsapp"></td>
												<td><input type='text' name='snapchat_url' id='snapchat_url' value='<%=escapeCoteValue(aitem.url)%>' size='30' maxlength='255' class="form-control"/></td>
												<input type='hidden' name='snapchat_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' />
											<tr>
										</table>

										</div>
							  		</div>
								</div>
						  	</div>

						  	<div class="card card-info">
								<div class="card-header" role="tab" id="heading5">
							  		<h5 class="mb-0">
							  			<button class="btn btn-link" data-target="#collapse5" type="button" data-toggle="collapse" >Language</button></h5>
								</div>
								<div id="collapse5" class="card-collapse collapse" role="tabcard" aria-labelledby="heading5">
							  		<div class="card-body">
										<div class="form-horizontal">

											<table id="language_table" class="table table-hover table-bordered m-t-20">
												<thead class="thead-dark">
													<th>&nbsp;&nbsp;&nbsp;Label</th>
													<th>Menu</th>
													<th>Order</th>
												</thead>
												<% 
												for(Language lang:langsList) {
													String _lang_code = lang.getCode();
													aitem = getAdditionalItem(Etn, menuid, _lang_code, "language");
													if(aitem.label.length() == 0) aitem.label = _lang_code;
												%>
												<tr>
													<td>
														<div class="input-group">
															<span class="input-group-addon">
																<input type='checkbox' <% if(aitem.id.length() > 0) { %>checked<%}%> class='verifyurl' name='langlinks' value='<%=escapeCoteValue(_lang_code)%>' />
															</span>
															<input type='text' class='form-control' name='<%=_lang_code%>_label' value='<%=escapeCoteValue(aitem.label)%>' size='15' maxlength='30'/>
														</div>

													</td>
													<td><%=addSelectControl(""+_lang_code+"_to_menu_id", ""+_lang_code+"_to_menu_id", allmenus, aitem.to_menu_id, "form-control", "")%></td>
													<td><input type='text' class="form-control" name='<%=_lang_code%>_order' value='<%=escapeCoteValue(aitem.order)%>' size='1' /></td>
												</tr>
												<% } %>
											</table>

										</div>
							  		</div>
								</div>
						  	</div>

						  	<div class="card card-info">
								<div class="card-header" role="tab" id="heading6">
							  		<h5 class="mb-0">
							  			<button class="btn btn-link" data-target="#collapse6" type="button" data-toggle="collapse" >Authentication</button></h5>
								</div>
								<div id="collapse6" class="card-collapse collapse" role="tabcard" aria-labelledby="heading6">
							  		<div class="card-body">
										<div class="form-horizontal">
											<div class="form-group row">
												<label for="inputEmail3" class="col-md-2 control-label">Enabled</label>
												<div class=" col-md-4">
												<input type='checkbox' class='form-control' value='1' name='showloginbar' id='showloginbar' <% if("1".equals(showloginbar)){%>checked<%}%> />

												</div>
											</div>
											<div class="form-group row">
												<label for="loginusernamelbl" class="col-sm-2 control-label">Username label</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='25' value='<%=escapeCoteValue(loginusernamelbl)%>' name='loginusernamelbl' id='loginusernamelbl' maxlength='50'/>
												</div>
												<label for="loginpasswordlbl" class="col-sm-2 control-label">Password label</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(loginpasswordlbl)%>' name='loginpasswordlbl' id='loginpasswordlbl' maxlength='50'/>

												</div>
											</div>
											<div class="form-group row">
												<label for="loginbuttonlbl" class="col-sm-2 control-label">Login button label</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(loginbuttonlbl)%>' name='loginbuttonlbl' id='loginbuttonlbl' maxlength='50'/>
												</div>
												<label for="logoutbuttonlbl" class="col-sm-2 control-label">Logout button label</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(logoutbuttonlbl)%>' name='logoutbuttonlbl' id='logoutbuttonlbl' maxlength='50'/>
												</div>
											</div>
											<div class="form-group row">
												<label for="signuplbl" class="col-sm-2 control-label">Signup label</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(signuplbl)%>' name='signuplbl' id='signuplbl' maxlength='50'/>
												</div>
												<label for="forgotpwlbl" class="col-sm-2 control-label">Forgot password label</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(forgotpwlbl)%>' name='forgotpwlbl' id='forgotpwlbl' maxlength='50'/>
												</div>
											</div>
											<div class="alert alert-danger" role="alert"><span class="glyphicon glyphicon-info-sign" aria-hidden="true" style='margin-right:10px'></span>If following URLs are empty, portal pages will be used by default</div>
											<div class="form-group row">
												<label for="regurl" class="col-sm-2 control-label">Signup URL</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(regurl)%>' name='regurl' id='regurl' maxlength='500'/>
												</div>
												<label for="regprodurl" class="col-sm-2 control-label">Signup prod URL</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(regprodurl)%>' name='regprodurl' id='regprodurl' maxlength='500'/>
												</div>
											</div>
											<div class="form-group row">
												<label for="accnturl" class="col-sm-2 control-label">My account URL</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(accnturl)%>' name='accnturl' id='accnturl' maxlength='500'/>
												</div>
												<label for="accntprodurl" class="col-sm-2 control-label">My account prod URL</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(accntprodurl)%>' name='accntprodurl' id='accntprodurl' maxlength='500'/>
												</div>
											</div>
											<div class="form-group row">
												<label for="forgotpwurl" class="col-sm-2 control-label">Forgot password URL</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(forgotpwurl)%>' name='forgotpwurl' id='forgotpwurl' maxlength='500'/>
												</div>
												<label for="forgotpwprodurl" class="col-sm-2 control-label">Forgot password prod URL</label>
												<div class="col-sm-4">
													<input type='text' class="form-control" size='45' value='<%=escapeCoteValue(forgotpwprodurl)%>' name='forgotpwprodurl' id='forgotpwprodurl' maxlength='500'/>
												</div>
											</div>
										</div>
							  		</div>
								</div>
						  	</div>

						  	<div class="card card-info">
								<div class="card-header" role="tab" id="heading7">
							  		<h5 class="mb-0">
							  			<button class="btn btn-link" data-target="#collapse7" type="button" data-toggle="collapse" >Page 404</button></h5>
								</div>
								<div id="collapse7" class="card-collapse collapse" role="tabcard" aria-labelledby="heading7">
							  		<div class="card-body">
							  			<div class="form-horizontal">

							  				<div class="form-group row">
												<label for="404_url" class="col-sm-2 control-label">Test 404 URL </label>
												<div class="col-sm-10">
													<div class="input-group">
														<input type="text" maxlength='700' class="form-control"  name='404_url' id='404_url' value='<%=escapeCoteValue(test_404_url)%>' >
													</div>
												</div>
											</div>

											<div class="form-group row">
												<label for="prod_404_url" class="col-sm-2 control-label">Prod 404 URL </label>

												<div class="col-sm-10">
													<div class="input-group">
														<input type="text" maxlength='700' class="form-control"  name='prod_404_url' id='prod_404_url' value='<%=escapeCoteValue(prod_404_url)%>' >
													</div>
												</div>
											</div>

										</div>
									</div>
								</div>
						  	</div>

						</div>
					</div>

				</form>
			</div>
		</div>
		<!-- /specific blocks -->




	</div>

	<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	<br>
	<br>

	</div>
	<!-- /container -->
</main>
<div class="modal fade" tabindex="-1" role="dialog" id="copydialog" >
<!-- .modal content -->
	<div class="modal-dialog " role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Create duplicate</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			</div>
			<div class="modal-body">
				<div style='text-align:center'><input type='text' id='newmenuname' value='' placeholder='New menu name' class='form-control'/></div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
				<button type="button" class="btn btn-success" onclick='javascript:copyokbtnclick()'>Ok</button>
			</div>

		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
	<!-- /.modal content -->
</div>

<div id='applicationruledialog' class="modal fade" tabindex="-1" role="dialog" >
<!-- .modal content -->
	<div class="modal-dialog " role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Trusted Domains</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			</div>
			<div class="modal-body">
			<form id='applytofrm'>
				<input type='hidden' name='menuid' value='<%=escapeCoteValue(menuid)%>' />
				<div class="form-check form-check-inline">
				  <input class="form-check-input applytyperadio" type='radio' name='applytype' id='applytype_url' value='url' nowrap checked>
				  <label class="form-check-label" for="applytype_url">
				    Exact URL
				  </label>
				</div>
				<div class="form-check form-check-inline">
				  <input class="form-check-input applytyperadio" type="radio"  checked name='applytype' id='applytype_url_starting_with' value='url_starting_with' nowrap>
				  <label class="form-check-label" for="applytype_url_starting_with">
				    URL starting with
				  </label>
				</div>
				<input type='text' class='form-control applytourlreset' name='apply_to_url' id='apply_to_url' value='' maxlength='255'  placeholder="URL"/>
				<input type='text' class='form-control applytourlreset' name='apply_to_url_starting_with' id='apply_to_url_starting_with' value='' maxlength='255'  placeholder="URL starting with" style="display: none;"/>

				<div>
					<input type='hidden' name='replacetags' id='replacetags' value=''/>
					<span style='color:red' id='replacetagstd'>&nbsp;</span>
				</div>
			</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-primary" onclick='showselector()'>Replace Tags</button>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
				<button type="button" class="btn btn-success" onclick='javascript:saveapplyto()'>Ok</button>
			</div>

		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
	<!-- /.modal content -->
</div>
<iframe id="uploadTrg" name="uploadTrg" height="0" width="0" frameborder="0" ></iframe>

<!-- .modal -->
<div class="modal fade" tabindex="-1" role="dialog" id="crawlerErrorsDlg" >
<!-- .modal content -->
	<div class="modal-dialog modal-xl" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Crawler Errors</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			</div>
			<div class="modal-body" id="crawlerErrorsDlgBody">

			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
	<!-- /.modal content -->
</div>
<!-- /.modal -->
<!-- .modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'>
</div>
<!-- /.modal -->

		<%
			String prodpushid = menuid;
			String prodpushtype = "menu";
		%>
		<%@ include file="prodpublishlogin.jsp"%>
	<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script type="text/javascript">

	<% 
	out.write("var langs = new Object();\n");
	for(Language lang:langsList)
	{
		out.write("\tlangs['"+lang.getCode()+"'] = "+lang.getLanguageId() + "; \n");
	}
	%>
	function menuitem(id, name, url, photo, phototext, phototagline, orderseq)
	{
		this.id = id;
		this.name = name.replace(/'/g,"&#39;");
		this.url = url;
		this.items = new Array();
		this.candelete = true;
		this.display = true;
		this.defaultselected = 0;
		this.photo = photo;
		this.phototext = phototext.replace(/'/g,"&#39;");
		this.phototagline = phototagline.replace(/'/g,"&#39;");
		this.externallink = 1;
		this.orderseq = orderseq;
		this.seokeywords = '';
		this.seodescr = '';
		this.produrl = '';
		this.display_name = "";
		this.display_in_footer = 1;
		this.display_in_header = 1;
		this.footer_display_name = "";
		this.open_as = "";
		this.visible_to = "";
		this.rightalign = 0;
		this.linklabel = "";
		this.showlinklabel = false;
		this.showmenuicon = false;
		this.menuicon = "";
		this.menuiconbase64 = "";
		this.menuphotobase64 = "";
	}

	var _menu = new Array();
	var _level1 = new menuitem(-30, 'Header Level 1','','','','',0);
	_level1.candelete = false;
	_level1.display = false;
	var _level2 = new menuitem(-20, 'Header Level 2','','','','',0);
	_level2.candelete = false;
	_level2.display = false;
	var _level3 = new menuitem(-15, 'Gray footer','','','','',0);
	_level3.candelete = false;
	_level3.display = false;
	var _level4 = new menuitem(-10, 'Footer','','','','',0);
	_level4.candelete = false;
	_level4.display = false;
	_menu.push(_level1);
	_menu.push(_level2);
	_menu.push(_level3);
	_menu.push(_level4);

	function onPathKeyup(input)
	{
       	var val = $(input).val();
		val = val.trimLeft().replace(" ","-").replace(/[^a-zA-Z0-9\/-]/g,'').replace('/-','/').replace('--','-');
		if(val.startsWith("-"))
		{
			val = val.substring(1);
		}
		//resources is a keyword for path as we have a specific folder created at time of crawling and that is named resources
		//so we avoid using it in menu path to avoid any kind of conflicts later
		$(input).val(val.toLowerCase().replace("resources","").replace("//","/"));
	}

	var replacetags = new Array();

	function showSearchFields()
	{
		$(".__searchconfig").hide();
		var _searchcls = "__" + $("#searchapi").val() + "search";
		$("." + _searchcls).show();
	}

	jQuery(document).ready(function() {

		<%if(warningmsg.length() > 0) { out.write("$('#alertBox2').html(\""+warningmsg+"\");$('#alertBox2').show();"); } %>

		var hpUrlSelector = $('#homepageurl');
		var hpUrlGen = etn.initUrlGenerator(hpUrlSelector,'<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>', { langId : langs[$("#mlang").val()], showOpenType : false, allowEmptyValue : true});

		var prodHpUrlSelector = $('#prodhomepageurl');
		var prodHpUrlGen = etn.initUrlGenerator(prodHpUrlSelector,'<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>', { langId : langs[$("#mlang").val()], showOpenType : false, allowEmptyValue : true});

		var menuItemUrlSelector = $('#cmenuitemurl');
		var menuItemUrlGen = etn.initUrlGenerator(menuItemUrlSelector,'<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>', { langId : langs[$("#mlang").val()], showOpenType : true, allowEmptyValue : true});

		var prodMenuItemUrlSelector = $('#cmenuitemprodurl');
		var prodMenuItemUrlGen = etn.initUrlGenerator(prodMenuItemUrlSelector,'<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>', { langId : langs[$("#mlang").val()], showOpenType : false, allowEmptyValue : true});

		var url404Selector = $('#404_url');
		var url404UrlGen = etn.initUrlGenerator(url404Selector,'<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>', { langId : langs[$("#mlang").val()], showOpenType : false, allowEmptyValue : true});

		var prodUrl404Selector = $('#prod_404_url');
		var prodUrl404UrlGen = etn.initUrlGenerator(prodUrl404Selector,'<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>', { langId : langs[$("#mlang").val()], showOpenType : false, allowEmptyValue : true});

		showSearchFields();

		$("#searchapi").change(function(){
			showSearchFields();
		});

		$('#applicationruledialog input[type=radio]').change(function(){
			$('#applicationruledialog input[type=text]').hide();
			if(this.value == 'url') $('#applicationruledialog input[type=text]#apply_to_url').show();
			if(this.value == 'url_starting_with') $('#applicationruledialog input[type=text]#apply_to_url_starting_with').show();
		});

		$('#menupath').on("input",function(e){
			onPathKeyup(this);
		});

		<% if(menuid.length() > 0) {%>
			$("#logorow").show();
			$("#smalllogorow").show();
			$("#faviconrow").show();
		<%}%>

		$('#mitem').keypress(function (e) {
			if (e.which == 13)
			{
				addNewItemInMenu();
				return false;
			}
		});

		//init seo length
		$("#seoNbcar1").append($("#seodescr").val().length);

		//display seo length for homepage
		$("#seodescr").keyup(function( event ) {
			$("#seoNbcar1").empty();
			$("#seoNbcar1").append($("#seodescr").val().length);
		});

		//init seo length
		$("#seoNbcar2").append($("#seokeywords").val().length);

		//display seo length for homepage
		$("#seokeywords").keyup(function( event ) {
			$("#seoNbcar2").empty();
			$("#seoNbcar2").append($("#seokeywords").val().length);
		});

		$("#logobtn").click(function(){
			$("#alertLogoFile").fadeOut();
			$("#alertLogoFile").html('');
			if($("#logofile").val() =='')
			{
				$("#alertLogoFile").html("Select an image");
				$("#alertLogoFile").fadeIn();
				return;
			}
			var ext = $("#logofile").val();
			var ok=true;
			if(ext.indexOf(".") > -1) ext = ext.substring(ext.lastIndexOf(".") + 1);
			else ok=false;

			if(ext.toLowerCase() != "png" && ext.toLowerCase() != "jpg" && ext.toLowerCase() != "jpeg" && ext.toLowerCase() != "tif" && ext.toLowerCase() != "gif" && ext.toLowerCase() != "svg")
				ok = false;
			if(!ok)
			{
				$("#alertLogoFile").html("Not a valid image file");
				$("#alertLogoFile").fadeIn();
				return;
			}

			$('#mfrm').prepend('<input type="hidden" name="menuid" value="<%=escapeCoteValue(menuid)%>" />');

			$("#mfrm").attr('action','uploadlogo.jsp');
			$("#mfrm").attr('enctype','multipart/form-data');
			$("#mfrm").submit();
		});

		$("#smalllogobtn").click(function(){
			$("#alertsmalllogofile").fadeOut();
			$("#alertsmalllogofile").html('');
			if($("#smalllogofile").val() =='')
			{
				$("#alertsmalllogofile").html("Select an image");
				$("#alertsmalllogofile").fadeIn();
				return;
			}
			var ext = $("#smalllogofile").val();
			var ok=true;
			if(ext.indexOf(".") > -1) ext = ext.substring(ext.lastIndexOf(".") + 1);
			else ok=false;

			if(ext.toLowerCase() != "png" && ext.toLowerCase() != "jpg" && ext.toLowerCase() != "jpeg" && ext.toLowerCase() != "tif" && ext.toLowerCase() != "gif" && ext.toLowerCase() != "svg")
				ok = false;
			if(!ok)
			{
				$("#alertsmalllogofile").html("Not a valid image file");
				$("#alertsmalllogofile").fadeIn();
				return;
			}

			$("#issmalllogo").val("1");
			$('#mfrm').prepend('<input type="hidden" name="menuid" value="<%=escapeCoteValue(menuid)%>" />');

			$("#mfrm").attr('action','uploadlogo.jsp');
			$("#mfrm").attr('enctype','multipart/form-data');
			$("#mfrm").submit();
		});


		$("#faviconbtn").click(function(){
			$("#alertFaviconFile").fadeOut();
			$("#alertFaviconFile").html('');

			if($("#faviconfile").val() =='')
			{
				$("#alertFaviconFile").html("Select an image");
				$("#alertFaviconFile").fadeIn();
				return;
			}
			var ext = $("#faviconfile").val();
			var ok=true;
			if(ext.indexOf(".") > -1) ext = ext.substring(ext.lastIndexOf(".") + 1);
			else ok=false;

			if(ext.toLowerCase() != "ico")
				ok = false;
			if(!ok)
			{
				$("#alertFaviconFile").html("Not a valid favicon file");
				$("#alertFaviconFile").fadeIn();
				return;
			}
			$("#isfavicon").val('1');

			$('#mfrm').prepend('<input type="hidden" name="menuid" value="<%=escapeCoteValue(menuid)%>" />');

			$("#mfrm").attr('action','uploadlogo.jsp');
			$("#mfrm").attr('enctype','multipart/form-data');
			$("#mfrm").submit();
		});

		$("#copybtn").click(function(){
			$("#newmenuname").val("");
			$("#copydialog").modal("show");
		});

		copyokbtnclick=function() {
			if($.trim($("#newmenuname").val()) == '')
			{
				alert("Provide name for copy");
				return;
			}

			$.ajax({
       	       	url : 'copymenu.jsp',
              	       type: 'POST',
                     	data: {menuid : '<%=menuid%>', newname : $("#newmenuname").val()},
				dataType : 'json',
              	       success : function(json)
                     	{
					alert(json.msg);
					if(json.response == 'success') $("#copydialog").modal("hide");
	                     },
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});
		};

		$("#applyrulebtn").click(function(){
			$(".applytourlreset").each(function(){
				$(this).val("");
			});
			$("#replacetags").val("");
			$("#replacetagstd").html("");
			$("#applytype_url").prop("checked", true)
			$("#applicationruledialog").modal("show");
		});

		$("#publishbtn").click(function(){
			$.ajax({
       	       	url : 'publishmenu.jsp',
              	       type: 'POST',
                     	data: {menuid : '<%=menuid%>'},
              	       success : function(resp)
                     	{
					alert("Published");
	                     },
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});
		});

		loadapplyto=function()
		{
			$.ajax({
       	       	url : 'loadapplyto.jsp',
              	       type: 'POST',
                     	data: {menuid : '<%=menuid%>',siteid : '<%=siteid%>'},
              	       success : function(resp)
                     	{
					$("#applicationdiv").html(resp);
	                     },
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		};

		deleteapplyto=function(id)
		{
			if(!confirm("This action will delete the rule permanently. Are you sure to continue?")) return;

			$.ajax({
       	       	url : 'deleteapplyto.jsp',
              	       type: 'POST',
                     	data: {id : id, menuid : '<%=menuid%>'},
	                     dataType: 'json',
              	       success : function(json)
                     	{
					if(json.response == "error")
					{
						alert("Some error occurred while deleting menu application rules");
					}
					else
					{
						loadapplyto();
					}
	                     },
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		};

		saveapplyto=function()
		{
			var locationprovided = false;
			$(".applytyperadio").each(function(){
				if($(this).is(":checked"))
				{
					if($(this).val() == 'url' || $(this).val() == 'url_starting_with')
					{
//						if($.trim($("#apply_to_" + $(this).val()).val()) != '' && isValidUrl($("#apply_to_" + $(this).val()).val()))
						if($.trim($("#apply_to_" + $(this).val()).val()) != '' )
						{
							locationprovided = true;
						}
						else alert("You must provide a valid url starting with http/https");
					}
					else if($.trim($("#apply_to_" + $(this).val()).val()) != '') locationprovided = true;
					else alert("You must provide path");
				}
			});
			if(!locationprovided)
			{
				return;
			}

			$.ajax({
       	       	url : 'saveapplyto.jsp',
              	       type: 'POST',
                     	data: $("#applytofrm").serialize(),
	                     dataType: 'json',
              	       success : function(json)
                     	{
					if(json.response == "error")
					{
						alert("Some error occurred while saving menu application rules");
					}
					else
					{
						$("#applicationruledialog").modal("hide");
						loadapplyto();
					}
	                     },
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		};


		var selectedmenuid = -30;
		updatemenuiteminfo=function()
		{
			var _defaultselected = 0;
			var _display_in_footer = 0;
			var _display_in_header = 0;
			var _rightalign = 0;
			if($("#cdefaultselected").is(":checked")) _defaultselected = 1;
			if($("#crightalign").is(":checked")) _rightalign = 1;
			if($("#cdisplay_in_footer").is(":checked")) _display_in_footer = 1;
			if($("#cdisplay_in_header").is(":checked")) _display_in_header = 1;

			var _externallink = 1;

			$.ajax({
       	       	url : 'updatemenuitem.jsp',
				type: 'POST',
				data: {menuiconimgname : $("#menuiconimgname").val(), menuiconimg : $("#menuiconimg").attr('src'), menuphotoimgname : $("#menuphotoimgname").val(), menuphotoimg : $("#menuphotoimg").attr('src'), visible_to : $("#cvisible_to").val(), open_as : menuItemUrlGen.getOpenType() , display_in_header : _display_in_header, display_in_footer : _display_in_footer, footer_display_name : $("#cmenuitemfooterdisplayname").val(), display_name: $("#cmenuitemdisplayname").val(), menuitemid : selectedmenuid, name : $("#cmenuitemname").val(), prod_url : $("#cmenuitemprodurl").val(), url : $("#cmenuitemurl").val(), defaultselected : _defaultselected, externallink: _externallink, phototext : $("#cmenuphototext").val(), phototagline : $("#cmenuphototagline").val(), seokeywords : $("#cmseokeywords").val(), seodescr : $("#cmseodescr").val(), rightalign : _rightalign, linklabel : $("#clinklabel").val() },
				dataType: 'json',
				success : function(json)
				{
					if(json.response == "error")
					{
						$("#editItemAlert").html("Some error occurred while saving menu item info");
						$("#editItemAlert").fadeIn();
					}
					else
					{
						updateToMenu(_menu, selectedmenuid, json.id, json.name, json.url, json.defaultselected, json.menu_photo, json.photo_text, json.photo_tag_line, json.externallink, json.seo_keywords, json.seo_description, json.prod_url, json.display_name, json.display_in_footer, json.footer_display_name, json.open_as, json.visible_to, json.display_in_header, json.rightalign, json.linklabel, json.menu_photo_base64, json.menu_icon, json.menu_icon_base64);
						if(json.menu_photo != '') $("#menuphotoimg").attr('src',json.menu_photo_base64);
						else $("#menuphotoimg").attr('src','');

						if(json.menu_icon != '') $("#menuiconimg").attr('src',json.menu_icon_base64);
						else $("#menuiconimg").attr('src','');

						drawMenu();
						$("#editItemSucc").html("Menu item updated");
						$("#editItemSucc").fadeIn();
						$('#editItemSucc').delay(2000).fadeOut();
					}
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		};

		$("#updatemenuitembtn").click(function(){
			$("#editItemAlert").fadeOut();
			$("#editItemAlert").html('');

			if(selectedmenuid <= 0) return;
			if($.trim($("#cmenuitemname").val()) == '')
			{
				$("#editItemAlert").html("You must provide menu item name");
				$("#editItemAlert").fadeIn();
				$("#cmenuitemname").focus();
				return;
			}

			if(menuItemUrlSelector.hasClass("is-invalid"))
			{
				$("#editItemAlert").html("You must provide complete url starting with http/https");
				$("#editItemAlert").fadeIn();
				$("#cmenuitemurl").focus();
				return;
			}

			if(prodMenuItemUrlSelector.hasClass("is-invalid"))
			{
				$("#editItemAlert").html("You must provide complete url starting with http/https");
				$("#editItemAlert").fadeIn();
				$("#cmenuitemprodurl").focus();
				return;
			}

			$("#__menuitemid").val(selectedmenuid);
			updatemenuiteminfo();
		});

		clearphotocontent=function(_container,targetimg, imgname)
		{
			$("#"+imgname).val("");
			$("#" + _container).fadeOut();
			$("#" + targetimg).attr("src","");
		};

		readImageBase64File=function(e, _container, targetimg, imgname)
		{
			var reader = new FileReader();
			var fname = e.target.files[0].name;
			reader.fileName = e.target.files.name;
            		reader.onload = function (e) {
				$("#" + targetimg).attr("src",e.target.result);
				$("#" + imgname).val(fname);
				$("#" + _container).fadeIn();
			}
			reader.readAsDataURL(e.target.files[0]);
		};

		getMenuItems = function(items, level)
		{
			var h = "";
			var width=300;
			width = width - (level * 20);
			var margin=0;
			margin = margin + (level * 20);
			for(var i=0; i<items.length; i++)
			{
				h += "<div class='mymenuitems' id='div_"+items[i].id+"' onclick='showmenuitemdetails(\""+items[i].id+"\",\""+items[i].name.replace("\"", '\\\"')+"\",\""+items[i].url.replace("\"", '\\\"')+"\","+items[i].display+",\""+items[i].defaultselected+"\", \""+items[i].photo.replace("\"", '\\\"')+"\", \""+items[i].phototext.replace("\"", '\\\"')+"\", \""+items[i].phototagline.replace("\"", '\\\"')+"\", \""+items[i].externallink+"\", \""+items[i].seokeywords.replace("\"", '\\\"')+"\", \""+items[i].seodescr.replace("\"", '\\\"')+"\", \""+items[i].produrl.replace("\"", '\\\"')+"\", \""+items[i].display_name.replace("\"", '\\\"')+"\", \""+items[i].display_in_footer+"\", \""+items[i].footer_display_name.replace("\"", '\\\"')+"\", \""+items[i].open_as.replace("\"", '\\\"')+"\", \""+items[i].visible_to.replace("\"", '\\\"')+"\", \""+items[i].display_in_header+"\",\""+items[i].rightalign+"\",\""+items[i].linklabel.replace("\"", '\\\"')+"\","+items[i].showlinklabel+","+items[i].showmenuicon+",\""+items[i].menuphotobase64+"\",\""+items[i].menuicon+"\",\""+items[i].menuiconbase64+"\")' style='cursor:pointer;padding:2px; margin-bottom:2px; background:#ddd;border-radius:4px;margin-left:"+margin+"px;'><span style='margin:3px;display:inline-block'>"+items[i].name+"</span>";
				if(items[i].candelete) h += "<div style='float:right;'><input type='hidden' name='menu_item_id' value='"+items[i].id+"' /><input style='border-radius:4px;border:1px solid #aaa;' name='item_order_seq' type='text' size='2' maxlength='3' value=\""+items[i].orderseq+"\"/>&nbsp;<button type='button' class='btn btn-danger btn-sm' style='vertical-align:baseline' onclick='javascript:deletemenuitem(\""+items[i].id+"\")'><span class='oi oi-x' style='font-size:10px;' aria-hidden='true'></span></button></div><div style='clear:both'></div>";
				//<a href='javascript:deletemenuitem(\""+items[i].id+"\")' style='text-decoration:none; color:red'>X</a></div><div style='clear:both'></div>";
				h += "</div>";
				h += getMenuItems(items[i].items, level+1);
			}
			return h;
		};

		deletemenuitem=function(mid)
		{
			$("#alertMenuItem").fadeOut();
			$("#alertMenuItem").html("");
			$("#succMenuItem").fadeOut();
			$("#succMenuItem").html("");
			if(!confirm("Are you sure to continue with deleting the menu item?")) return false;

			$.ajax({
       	       	url : 'deletemenuitem.jsp',
              	       type: 'POST',
                     	data: {menuitemid : mid, menuid : '<%=menuid%>'},
	                     dataType: 'json',
              	       success : function(json)
                     	{
					if(json.response == "error")
					{
						$("#alertMenuItem").html("Some error occurred while deleting menu item");
						$("#alertMenuItem").fadeIn();
						$('#alertMenuItem').delay(2000).fadeOut();
					}
					else
					{
						selectedmenuid = -10; //resetting so that after updating menu we can select the parent of deleted item
						updatemenuafterdelete(_menu, mid);
						resetmenuproperties();
						resetmenuselection();
						drawMenu();
						$("#succMenuItem").html("Menu item deleted");
						$("#succMenuItem").fadeIn();
						$("#succMenuItem").delay(2000).fadeOut();
					}
	                     },
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		};

		updatemenuafterdelete=function(items, mid)
		{
			var found = false;
			for(var i=0; i<items.length; i++)
			{
				if(items[i].id == mid)
				{
					items.splice(i,1);
					found = true;
				}
				else
				{
					found = updatemenuafterdelete(items[i].items, mid);
					if(found && selectedmenuid == -10) selectedmenuid = items[i].id;
				}
				if(found) return found;
			}
			return false;
		};

		$("#mitemaddok").click(function(){
			addNewItemInMenu();
		});

		addNewItemInMenu=function()
		{
			$("#alertMenuItem").fadeOut();
			$("#alertMenuItem").html('');
			$("#succMenuItem").fadeOut();
			$("#succMenuItem").html("");

			if($.trim($("#mitem").val()) == '') return false;

			$.ajax({
       	       	url : 'addmenuitem.jsp',
				type: 'POST',
				data: {menuitemname : $("#mitem").val(), parentmenuitemid : selectedmenuid, menuid : '<%=menuid%>'},
				dataType: 'json',
				success : function(json)
				{
					if(json.response == "error")
					{
						$("#alertMenuItem").html("Some error occurred while saving menu item");
						$("#alertMenuItem").fadeIn();
						$("#alertMenuItem").delay(2000).fadeOut();
					}
					else
					{
						addToMenu(_menu, selectedmenuid, json.id, $.trim($("#mitem").val()), "", '', '', '', '', '', '', '', '','', $.trim($("#mitem").val()), 1, $.trim($("#mitem").val()),'same_window','',1,0,'', json.showlinklabel, json.showmenuicon, "", "", "");
						$("#mitem").val('');
						drawMenu();
						$("#succMenuItem").html("Menu item added");
						$("#succMenuItem").fadeIn();
						$("#succMenuItem").delay(2000).fadeOut();
					}
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		};

		updateToMenu=function(items, parentitemid, mid, mname, murl, defaultselected, photo, phototext, phototagline, externallink, seokeywords, seodescr, produrl, displayname, display_in_footer, footer_display_name, open_as, visible_to, display_in_header, rightalign, linklabel, menuphotobase64, menuicon, menuiconbase64)
		{
			var found = false;
			for(var i=0; i<items.length; i++)
			{
				if(items[i].id == parentitemid)
				{
					items[i].name = mname.replace(/'/g,"&#39;");
					items[i].url = murl;
					items[i].defaultselected = defaultselected;
					items[i].photo = photo;
					items[i].phototext = phototext.replace(/'/g,"&#39;");
					items[i].phototagline = phototagline.replace(/'/g,"&#39;");
					items[i].externallink = externallink;
					items[i].seodescr = seodescr.replace(/'/g,"&#39;");
					items[i].seokeywords = seokeywords.replace(/'/g,"&#39;");
					items[i].produrl = produrl;
					items[i].display_name = displayname.replace(/'/g,"&#39;");
					items[i].display_in_footer = display_in_footer;
					items[i].display_in_header = display_in_header;
					items[i].footer_display_name = footer_display_name.replace(/'/g,"&#39;");
					items[i].open_as = open_as;
					items[i].visible_to = visible_to;
					items[i].rightalign = rightalign;
					items[i].linklabel = linklabel.replace(/'/g,"&#39;");
					items[i].menuphotobase64 = menuphotobase64;
					items[i].menuicon = menuicon;
					items[i].menuiconbase64 = menuiconbase64;
					found = true;
				}
				else found = updateToMenu(items[i].items, parentitemid, mid, mname, murl, defaultselected, photo, phototext, phototagline, externallink, seokeywords, seodescr, produrl, displayname, display_in_footer, footer_display_name, open_as, visible_to, display_in_header, rightalign, linklabel, menuphotobase64, menuicon, menuiconbase64);
				if(found) return found;
			}
			return false;
		};

		addToMenu=function(items, parentmenuitemid, mid, mname, murl, defaultselected, photo, phototext, phototagline, externallink, orderseq, seokeywords, seodescr, produrl, displayname, display_in_footer, footer_display_name, open_as, visible_to, display_in_header, rightalign, linklabel, showlinklabel, showmenuicon, menuphotobase64, menuicon, menuiconbase64)
		{
			var found = false;
			//console.log(showmenuicon);
			for(var i=0; i<items.length; i++)
			{
				if(items[i].id == parentmenuitemid)
				{
					var _m = new menuitem(mid, mname, murl, photo, phototext, phototagline, orderseq);
					_m.defaultselected = defaultselected;
					_m.externallink = externallink;
					_m.seokeywords = seokeywords.replace(/'/g,"&#39;");
					_m.seodescr = seodescr.replace(/'/g,"&#39;");
					_m.produrl = produrl;
					_m.display_name = displayname.replace(/'/g,"&#39;");
					_m.display_in_footer = display_in_footer;
					_m.display_in_header = display_in_header;
					_m.footer_display_name = footer_display_name.replace(/'/g,"&#39;");
					_m.open_as = open_as;
					_m.visible_to = visible_to;
					_m.rightalign = rightalign;
					_m.linklabel = linklabel;
					_m.showlinklabel = showlinklabel;
					_m.showmenuicon = showmenuicon;
					_m.menuphotobase64 = menuphotobase64;
					_m.menuicon = menuicon;
					_m.menuiconbase64 = menuiconbase64;
					items[i].items.push(_m);
					found = true;
				}
				else found = addToMenu(items[i].items, parentmenuitemid, mid, mname, murl, defaultselected, photo, phototext, phototagline, externallink, orderseq, seokeywords, seodescr, produrl, displayname, display_in_footer, footer_display_name, open_as, visible_to, display_in_header, rightalign, linklabel, showlinklabel, showmenuicon, menuphotobase64, menuicon, menuiconbase64);
				if(found) return found;
			}
		};

		resetmenuproperties=function()
		{
			$("#cmenuitemname").val('');
			$("#cmenuitemdisplayname").val('');
			$("#cmenuitemfooterdisplayname").val('');
			$("#cmenuitemurl").val('');
			$("#cmenuitemprodurl").val('');
			$("#cdefaultselected").prop('checked',false);
			$("#crightalign").prop('checked',false);
			$("#cdisplay_in_footer").prop('checked',false);
			$("#cdisplay_in_header").prop('checked',false);
			$("#cvisible_to").val('');
//			$("#cexternallink").prop('checked',false);
			files = null;
			$("#cmenuphoto").val('');
			$("#cmenuphototext").val('');
			$("#cmenuphototagline").val('');
			$("#menuphotodiv").hide();
			$("#menuphotoimg").attr('src','');
			$("#cmseodescr").val("");
			$("#cmseokeywords").val("");
			$("#clinklabel").val("");
			$("#linklabeldiv").hide();
			$("#menuiconimg").attr("src","");
			$("#menuiconimgdiv").hide();
			$("#menuicondiv").hide();
			$("#menuiconimgname").val("");
			$("#menuphotoimgname").val("");
		};

		selecttoplevel=function()
		{
			resetmenuselection();
			selectedmenuid = 0;
			resetmenuproperties();
		};

		resetmenuselection=function()
		{
			$(".mymenuitems").each(function(){
				$(this).css('background-color','#ddd');
			});
		};

		showmenuitemdetails=function(mid, name, url, _display, defaultselected, photo, phototext, phototagline, externallink, seokeywords, seodescr, prod_url, displayname, display_in_footer, footer_display_name, open_as, visible_to, display_in_header, rightalign, linklabel, showlinklabel, showmenuicon, menuphotobase64, menuicon, menuiconbase64)
		{
			resetmenuselection();
			resetmenuproperties();

			$("#editItemAlert").hide();
			$("#editItemSucc").hide();
			$("#editItemAlert").html("");
			$("#editItemSucc").html("");

			$("#div_" + mid).css('background-color','#ddf');
			selectedmenuid = mid;
			if(_display)
			{
				$("#cmenuitemname").val(name);
				$("#cmenuitemdisplayname").val(displayname);
				$("#cmenuitemfooterdisplayname").val(footer_display_name);
				$("#cmenuitemurl").val(url);
				$("#cmenuitemprodurl").val(prod_url);
				if(defaultselected == 1) $("#cdefaultselected").prop('checked',true);
				else $("#cdefaultselected").prop('checked',false);

				if(rightalign == 1) $("#crightalign").prop('checked',true);
				else $("#crightalign").prop('checked',false);

				$("#clinklabel").val(linklabel);

				if(showlinklabel == true) $("#linklabeldiv").show();
				else $("#linklabeldiv").hide();

				if(showmenuicon == true) $("#menuicondiv").show();
				else $("#menuicondiv").hide();

				menuItemUrlGen.setOpenType(open_as);
				$("#cvisible_to").val(visible_to);

				if(display_in_footer == 1) $("#cdisplay_in_footer").prop('checked', true);
				else $("#cdisplay_in_footer").prop('checked', false);

				if(display_in_header == 1) $("#cdisplay_in_header").prop('checked', true);
				else $("#cdisplay_in_header").prop('checked', false);

//				if(externallink == 1) $("#cexternallink").prop('checked',true);
//				else $("#cexternallink").prop('checked',false);

				$("#cmenuphototext").val(phototext);
				$("#cmenuphototagline").val(phototagline);
				$("#cmseodescr").val(seodescr);
				$("#cmseokeywords").val(seokeywords);

				if(photo != '')
				{
					$("#menuphotoimgname").val(photo);
					$("#menuphotoimg").attr('src',menuphotobase64);
					$("#menuphotodiv").show();
				}
				if(menuicon != '')
				{
					$("#menuiconimgname").val(menuicon);
					$("#menuiconimg").attr('src',menuiconbase64);
					$("#menuiconimgdiv").show();
				}
			}
		};

		var _previewwin = null;

		saveorderseq=function()
		{
			$("#updorderseq").submit();
		};

		drawMenu=function()
		{
			$("#menuitems").html("<form id='updorderseq' method='post' action='menudesigner.jsp' ><input type='hidden' name='menuid' value='<%=escapeCoteValue(menuid)%>' /><input type='hidden' name='siteid' value='<%=escapeCoteValue(siteid)%>' /><input type='hidden' name='saveseq' value='1' />"+getMenuItems(_menu, 0)+"</form>");
			resetmenuselection();
			$("#div_" + selectedmenuid).css('background-color','#ddf');
//			previewmenu();
			if(_previewwin && !_previewwin.closed) previewmenu();
		};


		$("#previewbtn").click(function(){
			<% if(mlang.length() == 0) {
				out.write("$('#alertBox1').html('Select menu language and save');");
				out.write("$('#alertBox1').show();");
			} else { %>
				previewmenu();
			<% } %>
		});

		previewmenu=function()
		{
            var url  = "previewmenu.jsp?menuid=<%=menuid%>";
            console.log(url);
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
			_previewwin = window.open("pagePreview.jsp?url="+url,"Menu preview", prop);
			_previewwin.focus();
		};

		$("#prodpreviewbtn").click(function(){
			prodpreviewmenu();
		});

		prodpreviewmenu=function()
		{
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
			_previewwin = window.open("previewmenu.jsp?menuid=<%=menuid%>&p=1","Production Menu preview", prop);
			_previewwin.focus();
		};

		<% if(menuid.length() > 0) {
			String imgFolder = com.etn.beans.app.GlobalParm.getParm("MENU_IMAGES_FOLDER");
			Set rsmi = Etn.execute("select menu_icon, link_label, is_right_align, visible_to, open_as, display_in_footer, display_in_header, footer_display_name, display_name, prod_url, seo_keywords, seo_description, order_seq, id, menu_id, coalesce(menu_item_id,0) as menu_item_id, name, url, default_selected, menu_photo, menu_photo_text, menu_photo_tag_line, is_external_link from menu_items where menu_id = " + escape.cote(menuid) + " order by menu_item_id, coalesce(order_seq, 999999), id ");
			while(rsmi.next())
			{
				boolean _showlinklabel = false;
				boolean _showmenuicon = false;
				if("-20".equals(parseNull(rsmi.value("menu_item_id")))) _showlinklabel = true;
				else
				{
					Set _rs2 = Etn.execute("Select * from menu_items where id = " + escape.cote(parseNull(rsmi.value("menu_item_id"))));
					if(_rs2.next() && "-20".equals(parseNull(_rs2.value("menu_item_id"))) )
					{
						_showlinklabel = true;
						_showmenuicon = true;
					}
				}

				String mphotobase64 = "";
				if(parseNull(rsmi.value("menu_photo")).length() > 0)
				{
					mphotobase64 = getBase64Image(imgFolder, parseNull(rsmi.value("menu_photo")));
				}
				String miconbase64 = "";
				if(parseNull(rsmi.value("menu_icon")).length() > 0)
				{
					miconbase64 = getBase64Image(imgFolder, parseNull(rsmi.value("menu_icon")));
				}


			%>
				addToMenu(_menu, '<%=parseNull(rsmi.value("menu_item_id"))%>', '<%=parseNull(rsmi.value("id"))%>', '<%=parseNull(rsmi.value("name")).replace("'","&#39;")%>', '<%=parseNull(rsmi.value("url"))%>', <%=parseNull(rsmi.value("default_selected"))%>, '<%=parseNull(rsmi.value("menu_photo"))%>', '<%=parseNull(rsmi.value("menu_photo_text")).replace("'","&#39")%>', '<%=parseNull(rsmi.value("menu_photo_tag_line")).replace("'","&#39")%>', '<%=parseNull(rsmi.value("is_external_link"))%>', '<%=parseNull(rsmi.value("order_seq"))%>', '<%=parseNull(rsmi.value("seo_keywords")).replace("'","&#39")%>', '<%=parseNull(rsmi.value("seo_description")).replace("'","&#39")%>', '<%=parseNull(rsmi.value("prod_url"))%>', '<%=parseNull(rsmi.value("display_name")).replace("'","&#39;")%>', '<%=parseNull(rsmi.value("display_in_footer"))%>', '<%=parseNull(rsmi.value("footer_display_name")).replace("'","&#39;")%>', '<%=parseNull(rsmi.value("open_as"))%>', '<%=parseNull(rsmi.value("visible_to"))%>','<%=parseNull(rsmi.value("display_in_header"))%>','<%=parseNull(rsmi.value("is_right_align"))%>','<%=parseNull(rsmi.value("link_label")).replace("'","&#39;")%>', <%=_showlinklabel%>, <%=_showmenuicon%>, '<%=mphotobase64%>', '<%=parseNull(rsmi.value("menu_icon"))%>', '<%=miconbase64%>');
			<% } %>
			drawMenu();
			loadapplyto();
			$("#designer").show();

			$(".onsaveonly").each(function(){
				$(this).show();
			});
		<% } %>

		$("#backbtn").click(function(){
			window.location = "site.jsp";
		});

		<% if(menuid.length() == 0) { %>
		$("#mlang").change(function(){
			var _lng = $(this).val();
			var _pth = "";
			if(_lng != "")
			{
				_lng = _lng + "/";
				_pth = ($("#sitefoldername").val() + "/" + _lng).toLowerCase();
			}

			$("#menupath").val(_pth) ;
			if(_lng != '')
			{
				$("#pathwarningspan").html("Warning: Changing path other than '"+_pth+"' requires nginx/apache configuration changes");
				$("#pathwarningdiv").show();
			}
			else
			{
				$("#pathwarningdiv").hide();
			}
			hpUrlGen.options.langId = langs[$(this).val()];
			prodHpUrlGen.options.langId = langs[$(this).val()];
		});
		<% } %>
		<%
		//case when a menu is copied we have its language as empty but menuid is valid
		if(menuid.length() > 0 && mlang.length() == 0) {
		%>
		$("#mlang").change(function(){
			var _lng = $(this).val();
			if(_lng != "") _lng = _lng + "/";
			$("#menupath").val(($("#sitefoldername").val() + "/" + _lng).toLowerCase()) ;
		});
		<% } %>


		<% if(menuid.length() > 0 && canChangeMenuPath) { %>
				$("#pathwarningspan").html("Warning: Changing path other than '<%=getDefaultMenuPath(Etn, menuid)%>' requires nginx/apache configuration changes");
				$("#pathwarningdiv").show();
		<% } %>

		$("#savemenuinfobtn").click(function(){
			$("#alertBox1").fadeOut();
			$("#alertBox1").html("");
			$("#alertBox2").fadeOut();
			$("#alertBox2").html("");
			if($.trim($("#menuname").val()) == '')
			{
				$("#alertBox1").html("You must provide a name to menu");
				$("#alertBox1").fadeIn();
				$("#menuname").focus();
				return;
			}
			if(hpUrlSelector.hasClass("is-invalid"))
			{
				$("#alertBox1").html("You must provide a valid URL for homepage");
				$("#alertBox1").fadeIn();
				hpUrlSelector.focus();
				return;
			}
			if(prodHpUrlSelector.hasClass("is-invalid"))
			{
				$("#alertBox1").html("You must provide a valid URL for prod homepage");
				$("#alertBox1").fadeIn();
				prodHpUrlSelector.focus();
				return;
			}
			if($("#mlang").val() == '')
			{
				$("#alertBox1").html("You must select language of menu");
				$("#alertBox1").fadeIn();
				$("#mlang").focus();
				return;
			}
			if($("#menupath").val() == '')
			{
				$("#alertBox1").html("Path cannot be empty. Recommended path is : <%=getDefaultMenuPath(Etn, menuid)%>");
				$("#alertBox1").fadeIn();
				$("#menupath").focus();
				return;
			}

			$.ajax({
       	       	url : 'verifymenupath.jsp',
					type: 'POST',
					data: { id : $("#cmenuid").val(), menupath : $("#menupath").val(), lang : $("#mlang").val() },
					dataType: 'json',
					success : function(resp)
					{
						if(resp.status === 0 || resp.status === 2)
						{
							if(resp.status === 2) $("#warningmsg").val(resp.msg);
							$("#mfrm").submit();
						}
						else
						{
							$("#alertBox1").html(resp.msg);
							$("#alertBox1").fadeIn();
						}
					},
					error : function()
					{
						console.log("Error while communicating with the server");
					}
			});

		});

		$("#savesocialmedialinks").click(function()
		{
			$("#additionalItemSucc").fadeOut();
			$("#additionalItemSucc").html("");
			$("#additionalItemErr").fadeOut();
			$("#additionalItemErr").html("");

			var anyinvalidurl = false;
			$(".verifyurl").each(function(){
				if($(this).is(":checked"))
				{
					var v = $(this).val();
					anyinvalidurl = !isValidUrl($("#" + v + "_url").val());
				}
			});

			if(anyinvalidurl)
			{
				$("#additionalItemErr").html("You must provide complete url starting with http: or https:");
				$("#additionalItemErr").fadeIn();
				return;
			}

			if(url404Selector.hasClass("is-invalid"))
			{
				$("#additionalItemErr").html("You must provide a valid URL for 404 test page");
				$("#additionalItemErr").fadeIn();
				url404Selector.focus();
				return;
			}

			if(prodUrl404Selector.hasClass("is-invalid"))
			{
				$("#additionalItemErr").html("You must provide a valid URL for 404 prod page");
				$("#additionalItemErr").fadeIn();
				prodUrl404Selector.focus();
				return;
			}

			if($("#showsearchbar").is(":checked"))
			{
/*				if($.trim($("#searchbarurl").val()) != "" && !isValidUrl($("#searchbarurl").val()))
				{
					$("#additionalItemErr").html("You must provide complete url starting with http: or https:");
					$("#additionalItemErr").fadeIn();
					$("#searchbarurl").focus();
					return;
				}*/
			}
			$.ajax({
       	       	url : 'saveadditionalitems.jsp',
              	       type: 'POST',
                     	data: $("#mfrm2").serialize(),
	                     dataType: 'json',
              	       success : function(json)
                     	{
					if(json.response == "error")
					{
						$("#additionalItemErr").html("Some error occurred while saving menu details");
						$("#additionalItemErr").fadeIn();
						$("#additionalItemErr").delay(2000).fadeOut();
					}
					else
					{
						$("#additionalItemSucc").html("Menu items saved successfully");
						$("#additionalItemSucc").fadeIn();
						$("#additionalItemSucc").delay(2000).fadeOut();
						if(_previewwin && !_previewwin.closed) previewmenu();
					}
	                     },
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		});

		isValidUrl=function(url)
		{
			if($.trim(url) == '') return true;
			if($.trim(url).toLowerCase().indexOf("https:") != 0 && $.trim(url).toLowerCase().indexOf("http:") != 0)
				return false;
			//if($.trim(url).toLowerCase().indexOf("javascript:") != 0) return false;
			return true;
		};

		showselector=function()
		{
			var u = "";
			replacetags = new Array();
			if($("#applytype_url_starting_with").is(":checked")) u = $("#apply_to_url_starting_with").val();
			if($("#applytype_url").is(":checked")) u = $("#apply_to_url").val();

			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
			win = window.open("selector.jsp?url="+u,"Select divs to replace", prop);
			win.focus();
		};

		addSelectedSection=function(_id)
		{
			replacetags.push(_id);
			setreplacetags();
		};

		removeSelectedSection=function(_id)
		{
			for(var i=0; i<replacetags.length; i++)
			{
				if(replacetags[i] == _id) replacetags.splice(i, 1);
			}
			setreplacetags();
		};

		setreplacetags=function()
		{
			var r = "";
			for(var i=0; i<replacetags.length; i++)
			{
				if($.trim(r).length > 0) r += ", ";
				r += replacetags[i];
			}
			$("#replacetags").val(r);
			$("#replacetagstd").html(r);
		};

		updatemenurules=function()
		{
			$("#rulesfrm").submit();
		};

		refreshscreen=function()
		{
			window.location = "menudesigner.jsp?menuid=<%=menuid%>";
		};

		asklogin=function()
		{
			$("#lgdiv2").html("");
			$("#lgdiv2").hide("");
			$("#lgdiv1").show("");
			$("#lgusername").val("");
			$("#lgpassword").val("");
			$("#logindlg").dialog("open");
		};

		setgtmval=function(obj, id)
		{
			if($(obj).is(":checked")) $("#"+id+"_gtms").val("1");
			else $("#"+id+"_gtms").val("0");
		};

		$("#404urlgenbtn").click(function(){
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
			var win = window.open('<%=GlobalParm.getParm("URL_GENERATOR")%>?fid=404_url',"URL Generator", prop);
			win.focus();
		});

		$("#prod404urlgenbtn").click(function(){
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
			var win = window.open('<%=GlobalParm.getParm("URL_GENERATOR")%>?isprod=1&fid=prod_404_url',"URL Generator", prop);
			win.focus();
		});

		$("#urlgenbtn").click(function(){
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
			var win = window.open('<%=GlobalParm.getParm("URL_GENERATOR")%>',"URL Generator", prop);
			win.focus();
		});

		$("#produrlgenbtn").click(function(){
			var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
			var win = window.open('<%=GlobalParm.getParm("URL_GENERATOR")%>?isprod=1',"URL Generator", prop);
			win.focus();
		});

		seturl=function(id, u)
		{
			$("#"+id).val(u);
		};

		deleteSmalllogo=function()
		{
			if(confirm("Are you sure to delete the logo?"))
			{
				$.ajax({
      			       	url : 'deletemenulogo.jsp',
             			       type: 'POST',
                     		data: {menuid : '<%=menuid%>', typ : 's'},
					dataType:'json',
       	      		       success : function(json)
              	       	{
						if(json.resp == 'error') alert(json.msg);
						else
						{
							$("#slogoimgtd").html('&nbsp;');
							$("#deletesmalllogofilebtn").hide();
						}
		                     },
					error : function()
					{
						console.log("Error while communicating with the server");
					}
				});
			}
		};

		deletelogo=function()
		{
			if(confirm("Are you sure to delete the logo?"))
			{
				$.ajax({
      			       	url : 'deletemenulogo.jsp',
             			       type: 'POST',
                     		data: {menuid : '<%=menuid%>'},
					dataType:'json',
       	      		       success : function(json)
              	       	{
						if(json.resp == 'error') alert(json.msg);
						else
						{
							$("#logoimgtd").html('&nbsp;');
							$("#deletelogofilebtn").hide();
						}
		                     },
					error : function()
					{
						console.log("Error while communicating with the server");
					}
				});
			}
		};

		deletefavicon=function()
		{
			if(confirm("Are you sure to delete the favicon?"))
			{
				$.ajax({
      			       	url : 'deletemenulogo.jsp',
             			       type: 'POST',
                     		data: {menuid : '<%=menuid%>', isfavicon : '1'},
					dataType:'json',
       	      		       success : function(json)
              	       	{
						if(json.resp == 'error') alert(json.msg);
						else
						{
							$("#faviconimgtd").html('&nbsp;');
							$("#deletefaviconfilebtn").hide();
						}
		                     },
					error : function()
					{
						console.log("Error while communicating with the server");
					}
				});
			}
		};

		var crawldisabled = 0;

		$("#crawlbtn").click(function()
		{
			if(!confirm("Its recommended to crawl site once the menu is ready. Are you sure to continue?")) return;

			$("#crawlbtn").prop('disabled', true);
			crawldisabled = 5;
			$.ajax({
       	       	url : 'crawlmenu.jsp',
              	       type: 'POST',
                     	data: {menuid : '<%=menuid%>'},
				dataType : 'json',
              	       success : function(json)
                     	{
					alert(json.msg);
	                     },
				error : function()
				{
					console.log("Error while communicating with the server");
					$("#crawlbtn").prop('disabled', false);
					crawldisabled = 0;
				}
			});
		});

		viewCrawlerErrors=function()
		{
			$("#crawlerErrorsDlgBody").html("");
			$.ajax({
				url : 'getcrawlererrors.jsp',
				type: 'POST',
				data: {menuid : '<%=menuid%>'},
				success : function(htm)
				{
					$("#crawlerErrorsDlgBody").html(htm);
					$("#crawlerErrorsDlg").modal('show');
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		}

		<% if(menuid.length() > 0 ) { %>
			var _interval = null;
			var menustatuserror = 0;
			function checkmenustatus()
			{
				$.ajax({
       		       	url : 'getmenustatus.jsp',
					type: 'POST',
					data: {mid : '<%=menuid%>'},
					dataType: 'json',
					success : function(json)
					{
						$("#menustatusdiv").html(json.html);
						if(json.iscrawling == "false" && (crawldisabled--) <= 0) $("#crawlbtn").prop('disabled', false);
					},
					error : function()
					{
						menustatuserror++;
					}
				});
				//5 tries to get status failed means the session must be expired so we will kill the setInterval
				if(menustatuserror > 4) clearInterval(_interval);
			};

			checkmenustatus();
			_interval = setInterval(checkmenustatus, 5000);
		<% } %>

		<% if(rscrawl.rs.Rows > 0) { %>
			$("#crawlbtn").prop('disabled', true);
		<%}%>

		<% if(!uniquescripfilename) { %>
			alert("Error:Script file name <%=ojavascript_filename%> given is already used in another menu");
		<%}%>

	});
</script>
</body>

</html>

