<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.asimina.util.ActivityLog, com.etn.asimina.beans.Language,com.etn.asimina.util.SiteHelper"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="common.jsp"%>
<%@ include file="/WEB-INF/include/commonFormMethod.jsp"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%!
	String getSelectOptions(Set rs, String selectId){
		String options = "";
		rs.moveFirst();
		while(rs.next()){
			options += "<option value='"+rs.value("id")+"'"
					+ (selectId.equals(rs.value("id"))?"selected":"") + " >"+rs.value("name")+"</option>";
		}
		return options;
	}

    String getNameById(Set rs, String selectId){
        String name = "";
        rs.moveFirst();
        while(rs.next()){
            if(selectId.equals(rs.value("id"))){
                name = parseNull(rs.value("name"));
            }
        }
        return name;
    }

    String trimApplyToUrl(String applyToUrl){
        String url = applyToUrl;
        if(url.toLowerCase().startsWith("https://"))
            url = url.substring(8);
        else if(url.toLowerCase().startsWith("http://"))
            url = url.substring(7);

        url = url.trim();
        if(url.endsWith("/"))
            url = url.substring(0, url.lastIndexOf("/"));

        return url;
    }

    String setToGenerateFreemarkers(String db,String siteId)
    {
        String query = "Update "+db+"freemarker_pages SET to_generate = 1, updated_ts = NOW() WHERE site_id = "+escape.cote(siteId);
        return query;
    }

	void updateProcessPhase(com.etn.beans.Contexte Etn, String siteId, String action, String process, String phase, boolean isProd)
	{
		String dbname = "";
		if(isProd) dbname = GlobalParm.getParm("PROD_DB") + ".";
		System.out.println("Process:"+process+" phase:"+phase+" action:"+action+" isprod:"+isProd+" site:"+siteId);
		if(process.length() == 0 || phase.length() == 0)
		{
			Etn.executeCmd("delete from "+dbname+"site_config_process where site_id = "+escape.cote(siteId)+" and `action` = "+escape.cote(action));
		}
		else
		{
			Etn.executeCmd("insert into "+dbname+"site_config_process (site_id, `action`, process, phase) values ("+escape.cote(siteId)+", "+escape.cote(action)+", "+escape.cote(process)+", "+escape.cote(phase)+") on duplicate key update process = "+escape.cote(process)+", phase = "+escape.cote(phase));
		}
	}
%>
<%
	boolean isSuperAdmin = "SUPER_ADMIN".equalsIgnoreCase((String)session.getAttribute("PROFIL"));


    String COMMONS_DB = GlobalParm.getParm("COMMONS_DB") + ".";
    String PROD_PORTAL_DB = GlobalParm.getParm("PROD_DB") + ".";
    String PAGES_DB = GlobalParm.getParm("PAGES_DB") + ".";
    String CATALOG_DB = GlobalParm.getParm("CATALOG_DB") + ".";
    String SHOP_DB = GlobalParm.getParm("SHOP_DB") + ".";
    String PROD_SHOP_DB = GlobalParm.getParm("PROD_SHOP_DB") + ".";

	String siteid = parseNull(getSiteId(request.getSession()));
	String activeslct = parseNull(request.getParameter("activeslct"));
    List<Language> langsList = getLangs(Etn,siteid);
	if(activeslct.length() == 0) activeslct = "1";

	String selectedproddefaultmenu = "";

	Set rsLang = Etn.execute("SELECT lang.* FROM " + CATALOG_DB + "language lang LEFT JOIN " + COMMONS_DB
                + "sites_langs sl ON lang.langue_id = sl.langue_id WHERE sl.site_id=" + escape.cote(siteid));

	if("1".equals(parseNull(request.getParameter("issave"))))
	{
		String auto_accept_signup = parseNull(request.getParameter("auto_accept_signup"));
		if(auto_accept_signup.length() == 0) auto_accept_signup = "0";
		String snap_pixel_code = parseNull(request.getParameter("snap_pixel_code"));
		String gtmcode = parseNull(request.getParameter("gtmcode"));
		String countrycode = parseNull(request.getParameter("countrycode"));
		String websitename = parseNull(request.getParameter("website_name"));
		String sitedomain = parseNull(request.getParameter("site_domain"));
		if(sitedomain.length() > 0 && sitedomain.endsWith("/"))
		{
			sitedomain = sitedomain.substring(0, sitedomain.length()-1);
		}

		String default_menu_id = parseNull(request.getParameter("default_menu_id"));
		String datalayer_domain = parseNull(request.getParameter("datalayer_domain"));
		String datalayer_brand = parseNull(request.getParameter("datalayer_brand"));
		String datalayer_market = parseNull(request.getParameter("datalayer_market"));
		String datalayer_asset_type = parseNull(request.getParameter("datalayer_asset_type"));
		String datalayer_orange_zone = parseNull(request.getParameter("datalayer_orange_zone"));
		String datalayer_moringa_perimeter = parseNull(request.getParameter("datalayer_moringa_perimeter"));

		String enable_ecommerce = parseNull(request.getParameter("enable_ecommerce"));

		String facebook_app_id = parseNull(request.getParameter("facebook_app_id"));
		String twitter_account = parseNull(request.getParameter("twitter_account"));

		String geocoding_api = parseNull(request.getParameter("geocoding_api"));
		String googlemap_api = parseNull(request.getParameter("googlemap_api"));
		String leadformance_api = parseNull(request.getParameter("leadformance_api"));
		String load_map = parseNull(request.getParameter("load_map"));
		String shop_location_type = parseNull(request.getParameter("shop_location_type"));
		String package_point_location_type = parseNull(request.getParameter("package_point_location_type"));
		String algolia_stores_index = parseNull(request.getParameter("algolia_stores_index"));

		String site_auth_enabled = parseNull(request.getParameter("site_auth_enabled"));
		String site_auth_login_page = parseNull(request.getParameter("site_auth_login_page"));

		String authentication_type = parseNull(request.getParameter("authentication_type"));
		String orange_authentication_api_url = parseNull(request.getParameter("orange_authentication_api_url"));
		String orange_authorization_code = parseNull(request.getParameter("orange_authorization_code"));
		String orange_token_api_url = parseNull(request.getParameter("orange_token_api_url"));
		String boosted_version = parseNull(request.getParameter("form_boosted_version"));
		String generate_breadcrumbs = parseNull(request.getParameter("generate_breadcrumbs"));

		//xss filter will remove onclick so when saving onclick is replace with _etn_oclk_ so we are replacing it here again before updating in db
		site_auth_login_page = site_auth_login_page.replace("_etn_oclk_=","onclick=");
		site_auth_login_page = site_auth_login_page.replace("_etn_source_=","src=");
		site_auth_login_page = site_auth_login_page.replace("<etn_meta","<meta");
		site_auth_login_page = site_auth_login_page.replace("<etn_link","<link");
		site_auth_login_page = site_auth_login_page.replace("<etn_script","<script");

		site_auth_login_page = site_auth_login_page.replace("<etn_style","<style");
		site_auth_login_page = site_auth_login_page.replace("</etn_script>","</script>");
		site_auth_login_page = site_auth_login_page.replace("</etn_link>","</link>");
		site_auth_login_page = site_auth_login_page.replace("</etn_style>","</style>");
		site_auth_login_page = site_auth_login_page.replace("</etn_a>","</a>");

		site_auth_login_page = site_auth_login_page.replace("<etn_a","<a");
		site_auth_login_page = site_auth_login_page.replace("etn_hrf=","href=");
		site_auth_login_page = site_auth_login_page.replace("etn_javascript_:","javascript:");

		String qry = "update sites set "
			+"  authentication_type = "+escape.cote(authentication_type)
			+", orange_authentication_api_url = "+escape.cote(orange_authentication_api_url)
			+", orange_authorization_code = "+escape.cote(orange_authorization_code)
			+", orange_token_api_url = "+escape.cote(orange_token_api_url)
			+", auto_accept_signup = "+escape.cote(auto_accept_signup)
			+", snap_pixel_code = "+escape.cote(snap_pixel_code)
			+", datalayer_asset_type = "+escape.cote(datalayer_asset_type)
			+", datalayer_orange_zone = "+escape.cote(datalayer_orange_zone)
			+", datalayer_moringa_perimeter = "+escape.cote(datalayer_moringa_perimeter)
			+", site_auth_enabled = "+escape.cote(site_auth_enabled)
			+", site_auth_login_page = "+escape.cote(site_auth_login_page)
			+", facebook_app_id = "+escape.cote(facebook_app_id)
			+", twitter_account = "+escape.cote(twitter_account)
			+", geocoding_api = "+escape.cote(geocoding_api)
			+", googlemap_api = "+escape.cote(googlemap_api)
			+", leadformance_api = "+escape.cote(leadformance_api)
			+", algolia_stores_index = "+escape.cote(algolia_stores_index)
			+", load_map = "+escape.cote(load_map)
			+", shop_location_type = "+escape.cote(shop_location_type)
			+", package_point_location_type = "+escape.cote(package_point_location_type)
			+", datalayer_domain = "+escape.cote(datalayer_domain)
			+", datalayer_brand = "+escape.cote(datalayer_brand)
			+", datalayer_market = "+escape.cote(datalayer_market)
			+", version = version + 1, default_menu_id = "+escape.cote(default_menu_id)
			+", domain = "+escape.cote(sitedomain)
			+", website_name = "+escape.cote(websitename)
			+", gtm_code = "+escape.cote(gtmcode)
			+", country_code = "+escape.cote(countrycode)
			+", form_boosted_version = "+escape.cote(boosted_version)
			+", generate_breadcrumbs = "+escape.cote(generate_breadcrumbs)
             +", updated_on = NOW()";

		//only super admin can update this flag
		if(isSuperAdmin) qry += ", enable_ecommerce = " + escape.cote(enable_ecommerce);
		qry += " where id = " + escape.cote(siteid);

		Etn.executeCmd(qry);

        Etn.executeCmd(setToGenerateFreemarkers(PAGES_DB,siteid));

		Etn.executeCmd(qry);

        //-------------------------------Added By Ahsan------------------------------
		updateProcessPhase(Etn, siteid, "initpayment", parseNull(request.getParameter("processLocalInitiate")), parseNull(request.getParameter("phasesLocalInitiate")), false);
		updateProcessPhase(Etn, siteid, "confirmation", parseNull(request.getParameter("processLocalConfirmation")), parseNull(request.getParameter("phasesLocalConfirmation")), false);

		updateProcessPhase(Etn, siteid, "initpayment", parseNull(request.getParameter("processProdInitiate")), parseNull(request.getParameter("phasesProdInitiate")), true);
		updateProcessPhase(Etn, siteid, "confirmation", parseNull(request.getParameter("processProdConfirmation")), parseNull(request.getParameter("phasesProdConfirmation")), true);

        //-------------------------------Till Here------------------------------

        rsLang.moveFirst();
        while(rsLang.next()){
            String langId = rsLang.value("langue_id");
            String production_path = parseNull(request.getParameter("production_path_"+langId));

            if(production_path.length() > 0){
                production_path = production_path.toLowerCase();
                if(production_path.startsWith("/")) production_path = production_path.substring(1);
                if(!production_path.endsWith("/")) production_path = production_path + "/";
            }

            String homepage_url = parseNull(request.getParameter("homepage_url_"+langId));
            String page_404_url = parseNull(request.getParameter("page_404_url_"+langId));
            String login_page_url = parseNull(request.getParameter("login_page_url_"+langId));
            String error_page_url = parseNull(request.getParameter("error_page_url_"+langId));
            String fraud_page_url = parseNull(request.getParameter("fraud_page_url_"+langId));
            String default_page_template_id = parseNull(request.getParameter("default_page_template_id_"+langId));
            String login_page_template_id = parseNull(request.getParameter("login_page_template_id_"+langId));
            String cart_page_template_id = parseNull(request.getParameter("cart_page_template_id_"+langId));
            String funnel_page_template_id = parseNull(request.getParameter("funnel_page_template_id_"+langId));


            qry = "REPLACE INTO sites_details(site_id, langue_id, production_path, homepage_url, page_404_url, login_page_url, default_page_template_id, "+
                "login_page_template_id, cart_page_template_id, funnel_page_template_id,error_page_url,fraud_page_url ) VALUES ("
                + escape.cote(siteid) + "," + escape.cote(langId)
                + "," + escape.cote(production_path)
                + "," + escape.cote(homepage_url) + "," + escape.cote(page_404_url)+ "," + escape.cote(login_page_url)
                + "," + escape.cote(default_page_template_id)
                + "," + escape.cote(login_page_template_id)
                + "," + escape.cote(cart_page_template_id)
                + "," + escape.cote(funnel_page_template_id)
                + "," + escape.cote(error_page_url)
                + "," + escape.cote(fraud_page_url)
                + ")";
            Etn.executeCmd(qry);


            String[] apply_to_id = request.getParameterValues("apply_to_id");
            String[] apply_type = request.getParameterValues("apply_type");
            String[] apply_to = request.getParameterValues("apply_to");
            String[] replace_tags = request.getParameterValues("replace_tags");
            String[] add_gtm_script = request.getParameterValues("add_gtm_script");
            String[] apply_to_cache = request.getParameterValues("apply_to_cache");

            ArrayList<String> applyToIds = new ArrayList<>();
            if(apply_to_id != null && areArraysEqualSize(apply_to_id, apply_type, apply_to,
                    replace_tags, add_gtm_script, apply_to_cache)){

                for (int i=0; i < apply_to_id.length; i++ ) {
                    try{
                        if(parseNull(apply_to[i]).length() == 0){
                            //apply to is required
                            //skip entries which are empty
                            continue;
                        }

                        String curApplyToId = parseNull(apply_to_id[i]);

                        String applyTo = trimApplyToUrl(parseNull(apply_to[i]));

                        boolean isLocalhost = "127.0.0.1".equals(applyTo);

                        if(curApplyToId.length() == 0){

                            if(isLocalhost){
                                // skip if already exists
                                qry = "SELECT 1 FROM sites_apply_to WHERE site_id = " + escape.cote(siteid)
                                    + " AND apply_to = "+ escape.cote(applyTo);
                                Set tempRs = Etn.execute(qry);
                                if(tempRs.next()){
                                    continue; //skip
                                }
                            }

                            qry = "INSERT INTO sites_apply_to(site_id, apply_type, apply_to, replace_tags, add_gtm_script, cache ) VALUES ("
                                + escape.cote(siteid)
                                + "," + escape.cote(parseNull(apply_type[i]))
                                + "," + escape.cote(parseNull(applyTo))
                                + "," + escape.cote(parseNull(replace_tags[i]))
                                + "," + escape.cote(parseNull(add_gtm_script[i]))
                                + "," + escape.cote(parseNull(apply_to_cache[i]))
                                + " )";

                            int applyToId = Etn.executeCmd(qry);

                            if(applyToId <= 0){
                                Logger.debug("Error in creating sites_apply_to.");
                            }
                            else{
                                curApplyToId = "" + applyToId;
                            }
                        }
                        else{
                            qry = "UPDATE sites_apply_to SET add_gtm_script=" + escape.cote(parseNull(add_gtm_script[i]));

                            //for localhost only add_gtm_script is editable
                            if(!isLocalhost){
                                qry += ", apply_type=" + escape.cote(parseNull(apply_type[i]))
                                    + ", apply_to=" + escape.cote(parseNull(applyTo))
                                    + ", replace_tags=" + escape.cote(parseNull(replace_tags[i]))
                                    + ", cache=" + escape.cote(parseNull(apply_to_cache[i]));
                            }

                            qry += " WHERE id = " + escape.cote(curApplyToId)
                                    + " AND site_id = " + escape.cote(siteid);
                            Etn.executeCmd(qry);

                        }

                        //Logger.info(qry);
                        applyToIds.add(escape.cote(curApplyToId));

                    }
                    catch(Exception ex){
                        ex.printStackTrace();
                    }

                }//for

            }//if arrays equal

            //deleted entries
            qry = "DELETE FROM sites_apply_to WHERE site_id = " + escape.cote(siteid);
            if(applyToIds.size() > 0){
                qry += " AND id NOT IN (" + String.join(",", applyToIds) + ")";
            }
            Etn.executeCmd(qry);
        }

        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"","UPDATED","Site Parameters","Site parameters updated",siteid);
	}

	String siteName = "";

	String q = "select s.*, COALESCE(s.form_boosted_version,'4.x') as form_boosted_version , ps.generate_breadcrumbs as prod_generate_breadcrumbs, ps.auto_accept_signup as prod_auto_accept_signup, ps.snap_pixel_code as prod_snap_pixel_code, ps.datalayer_asset_type as prod_datalayer_asset_type, ps.datalayer_orange_zone as prod_datalayer_orange_zone, ps.datalayer_moringa_perimeter as prod_datalayer_moringa_perimeter, ps.enable_ecommerce as prod_enable_ecommerce, ps.datalayer_domain as prod_datalayer_domain, ps.datalayer_brand as prod_datalayer_brand, ps.datalayer_market as prod_datalayer_market, ps.gtm_code as prod_gtm, ps.country_code as prod_ccode, ps.default_menu_id as prod_default_menu_id, ps.website_name as prod_website_name, ps.domain as prod_site_domain, ps.facebook_app_id as prod_facebook_app_id, ps.twitter_account as prod_twitter_account, ps.geocoding_api as prod_geocoding_api, ps.googlemap_api as prod_googlemap_api, ps.leadformance_api as prod_leadformance_api,  ps.load_map as prod_load_map, ps.shop_location_type as prod_shop_location_type, ps.package_point_location_type as prod_package_point_location_type, ps.site_auth_login_page as prod_site_auth_login_page, ps.site_auth_enabled as prod_site_auth_enabled,ps.authentication_type as prod_authentication_type,ps.orange_authentication_api_url as prod_orange_authentication_api_url,ps.orange_token_api_url prod_orange_token_api_url,ps.orange_authorization_code prod_orange_authorization_code,  COALESCE(ps.form_boosted_version,'4.x') as prod_form_boosted_version  from sites s left outer join "+PROD_PORTAL_DB+"sites ps on ps.id = s.id where s.id = " + escape.cote(siteid);
	//System.out.println(q);
	Set rs = Etn.execute(q);
	rs.next();

	siteName = parseNull(rs.value("name"));
    String siteFolderName = getSiteFolderName(siteName);

	String isCreateSignupForm = parseNull(request.getParameter("is_create_signup_form"));
	if("1".equals(isCreateSignupForm))
	{
		// create sign up and forgot form by default at the time of site creation.
		createSignUpForm(siteid, parseNull(siteName), Etn);
		createForgotPasswordForm(siteid, parseNull(siteName), Etn);
		ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"","UPDATED","Site Parameters","Signup/Forgot Password forms generated",siteid);
	}

	Set signupFormRs = Etn.execute("select * from " + GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished where site_id = " + escape.cote(siteid) + " and type = " + escape.cote("sign_up") + " AND table_name = " + escape.cote("sign_up_site_"+siteid));

	Set forgotPasswordFormRs = Etn.execute("select * from " + GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished where site_id = " + escape.cote(siteid) + " and type = " + escape.cote("forgot_password") + " AND table_name = " + escape.cote("forgot_password_site_"+siteid));

	boolean siteHasSignupForm = false;
	boolean siteHasForgotPasswordForm = false;

	if(signupFormRs.rs.Rows > 0)
		siteHasSignupForm = true;

	if(forgotPasswordFormRs.rs.Rows > 0)
		siteHasForgotPasswordForm = true;

	Set rsm = Etn.execute("select * from site_menus where site_id = " + escape.cote(siteid) + " order by id ");

    Set satRs = Etn.execute("SELECT * FROM sites_apply_to WHERE site_id = " + escape.cote(siteid) + " order by id ");
    ArrayList<JSONObject> applyToList = new ArrayList<>();
    while(satRs.next()){
        JSONObject obj = new JSONObject();
        obj.put("id",satRs.value("id"));
        obj.put("apply_type",satRs.value("apply_type"));
        obj.put("apply_to",satRs.value("apply_to"));
        obj.put("add_gtm_script",satRs.value("add_gtm_script"));
        obj.put("cache",satRs.value("cache"));
        obj.put("replace_tags",satRs.value("replace_tags"));
        applyToList.add(obj);
    }

    Set pageTemplateRs = Etn.execute("SELECT id, name FROM "+PAGES_DB+"page_templates WHERE site_id = " +escape.cote(siteid)
                        + " ORDER BY is_system DESC, name ASC");
    Set footerRs = Etn.execute("SELECT id, name FROM "+PAGES_DB+"blocs WHERE site_id = " +escape.cote(siteid)
                        + " ORDER BY name");

    Set siteRs = Etn.execute("SELECT ps.version <> ts.version as equal FROM sites ts, "+GlobalParm.getParm("PROD_DB")+".sites ps WHERE ts.id = ps.id AND ps.id="+escape.cote(siteid));
    siteRs.next();

    String updated = parseNull(siteRs.value("equal"));
    int siteConfigCounter = 0;
%>

<html>
<head>
	<title>Site <%=escapeCoteValue(rs.value("name"))%></title>


	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    <%
        breadcrumbs.add(new String[]{"System", ""});
        breadcrumbs.add(new String[]{"Site Parameters", ""});
    %>

    <%
        if (parseNull(GlobalParm.getParm("URL_GEN_JS_URL")).length() > 0) {
    %>
        <script type="text/javascript" src='<%=GlobalParm.getParm("URL_GEN_JS_URL")%>'></script>
        <script type="text/javascript">
            window.URL_GEN_AJAX_URL = '<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>';
        </script>
    <%  } %>

</head>
<body class="c-app" style="background-color:#efefef">
    <%@ include file="/WEB-INF/include/sidebar.jsp" %>
    <div class="c-wrapper c-fixed-components">
        <%@ include file="/WEB-INF/include/header.jsp" %>
        <div class="c-body">
            <main class="c-main"  style="padding:0px 30px">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <div class="d-flex">
                        <h1 class="h2">Site Parameters</h1>
                        <div id="publishStatusDiv" class="bg-<%= ("1".equals(updated))? "warning":"success" %> float-left m-1 rounded-circle" style="width:25px;height:25px"></div>
                    </div>
                    <!-- buttons bar -->
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <%
                            if((!siteHasSignupForm || !siteHasForgotPasswordForm) && isSuperAdmin){
                        %>
                        <div class="btn-group mr-2" role="group" aria-label="...">
                            <input type='button' value='Create signup / forgot form'  id='create_signup_form' class="btn btn-default btn-success"/>
                        </div>
                        <%
                            }
                        %>
                        <div class="btn-group" role="group" aria-label="...">
                            <input type='button' value='Back'  id='backbtn' class="btn btn-default btn-primary"/>
                            <input type='button' value='Save' class="btn btn-default btn-primary" onclick="onSave()" />
                        </div>

                        <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Site parameters');" title="Add to shortcuts">
                            <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                        </button>
                    </div>
                    <!-- /buttons bar -->
                </div>
                <div class="animated fadeIn">
                    <div class="alert alert-danger" id="alertBox1" role="alert" style="display:none"></div>
                    <div>
                        <form name='frm' id='frm' action='siteparameters.jsp' method='post'>
                            <input type='hidden' name='issave' id='issave' value='0' >
                            <ul class="nav nav-tabs" role="tablist">
                                <%
                                    rsLang.moveFirst();
                                    boolean active = false;
                                    while(rsLang.next()){
                                        String langId = rsLang.value("langue_id");
                                %>
                                <li class="nav-item" data-lang-id="<%=langId%>">
                                    <a class='nav-link <%=!active?"active":""%>' data-lang-id="<%=langId%>"
                                    data-toggle="tab" href="#langDetails_<%=langId%>"
                                    role="tab" aria-controls="<%=rsLang.value("langue")%>" aria-selected="true"><%=rsLang.value("langue")%></a>
                                </li>
                                <%
                                        active = true;
                                    }
                                    Set remainingLang = Etn.execute("SELECT lang.* FROM "+GlobalParm.getParm("CATALOG_DB")+".language lang WHERE lang.langue_id NOT IN (SELECT sl.langue_id FROM "+GlobalParm.getParm("COMMONS_DB")+".sites_langs sl WHERE sl.site_id="+escape.cote(siteid)+")");
                                    if(remainingLang.rs.Rows>0){
                                %>
                                <li class="nav-item dropdown" id="langAddBtn">
                                    <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-expanded="false"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-plus-circle nav-icon"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg></a>
                                    <div class="dropdown-menu"><%while(remainingLang.next()){%><a class="dropdown-item" href="#" lang-id="<%=remainingLang.value("langue_id")%>"><%=remainingLang.value("langue")%></a><%}%></div>
                                </li>
                                <%}%>
                            </ul>
                            <div class="tab-content p-3">
                                <%
                                    rsLang.moveFirst();
                                    active = false;
                                    while(rsLang.next()){
                                        String langId = rsLang.value("langue_id");
                                        boolean isProdPathEditable = true;
                                        Set sdRs = Etn.execute("SELECT * FROM sites_details WHERE site_id = " + escape.cote(siteid)
                                            + " AND langue_id = " + escape.cote(langId));
                                        sdRs.next();
                                        Set psdRs = Etn.execute("SELECT * FROM "+PROD_PORTAL_DB+"sites_details WHERE site_id = "
                                            + escape.cote(siteid) + " AND langue_id = " + escape.cote(langId));
                                        psdRs.next();

                                        String curProdPath = parseNull(sdRs.value("production_path"));
                                        if(psdRs.value("site_id").length() > 0){
                                            isProdPathEditable = false;
                                        }
                                        else{
                                            if(curProdPath.length() == 0){
                                                curProdPath = siteFolderName + "/"+ rsLang.value("langue_code") + "/";
                                            }
                                        }
										
										int langCnt = 0;
                                %>
                                <div class="tab-pane <%=!active?"active":""%>" id="langDetails_<%=langId%>">
                                    <div class="card mb-2">
                                        <div class="card-header bg-secondary" data-toggle="collapse" href="#generalParameters" role="button" aria-expanded="false" aria-controls="collapseGlobalParameters">
                                            <strong>Site Info</strong>
                                        </div>
                                        <div class="collapse border-0" id="generalParameters">
                                            <div class="card-body">

                                                <div class="d-flex">
                                                    <div class="col px-0 py-1">
                                                        <h3 class="m-1">Set site info</h3>
                                                    </div>
                                                    <div class="col px-0 py-1">
                                                        <h3 class="m-1">
                                                            Production site info
                                                        </h3>
                                                    </div>
                                                </div>
                                                <div class="d-flex">
                                                    <!-- left column -->
                                                    <div class="col p-1">
                                                        <div class="form-horizontal">
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Google tag manager code">
                                                                <label for="gtmcode" class="col-sm-3 control-label" style="line-height:2rem;">GTM</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control gtmcode" <% if(!active){ %>name='gtmcode' onchange="duplicateField(this)"<%}else{%>disabled<%}%> id="gtmcode" maxlength='50' size='40' value='<%=escapeCoteValue(parseNull(rs.value("gtm_code")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer brand">
                                                                <label for="datalayer_brand" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Brand</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control datalayer_brand" id="datalayer_brand" maxlength='255' size='40' <% if(!active){ %>name='datalayer_brand' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("datalayer_brand")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer domain">
                                                                <label for="datalayer_domain" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Domain</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control datalayer_domain" id="datalayer_domain" maxlength='255' size='40' <% if(!active){ %>name='datalayer_domain' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("datalayer_domain")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer market">
                                                                <label for="datalayer_market" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Market</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control datalayer_market" id="datalayer_market" maxlength='255' size='40' <% if(!active){ %>name='datalayer_market' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("datalayer_market")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer asset type">
                                                                <label for="datalayer_asset_type" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Asset Type</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control datalayer_asset_type" id="datalayer_asset_type" maxlength='75' size='40' name='datalayer_asset_type' <% if(!active){ %>name='datalayer_asset_type' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("datalayer_asset_type")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer orange zone">
                                                                <label for="datalayer_orange_zone" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Orange Zone</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control datalayer_orange_zone" id="datalayer_orange_zone" maxlength='75' size='40' name='datalayer_orange_zone' <% if(!active){ %>name='datalayer_orange_zone' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("datalayer_orange_zone")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer moringa perimeter">
                                                                <label for="datalayer_moringa_perimeter" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Moringa Perimeter</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control datalayer_moringa_perimeter" id="datalayer_moringa_perimeter" maxlength='75' size='40' <% if(!active){ %>name='datalayer_moringa_perimeter' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("datalayer_moringa_perimeter")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex">
                                                                <label for="countrycode" class="col-sm-3 control-label" style="line-height:2rem;">Country code</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control countrycode" id="countrycode" maxlength='50' size='40' <% if(!active){ %>name='countrycode' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("country_code")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="This name goes into title of each page">
                                                                <label for="website_name" class="col-sm-3 control-label" style="line-height:2rem;">Website name</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control website_name" id="website_name" maxlength='100' size='40' <% if(!active){ %>name='website_name' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("website_name")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="This domain name will only be used in javascript link to fetch our menu by external sites">
                                                                <label for="site_domain" class="col-sm-3 control-label" style="line-height:2rem;">Domain</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control site_domain" id='site_domain' maxlength='100' size='50' <% if(!active){ %>name='site_domain' onchange="duplicateField(this)"<%}else{%>disabled<%}%> id='site_domain' value='<%=escapeCoteValue(parseNull(rs.value("domain")))%>' >
                                                                </div>
                                                            </div>
                                                            <% if(isSuperAdmin) { %>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="enable_ecommerce" class="col-sm-3 control-label" style="line-height:2rem;">Enable Ecommerce</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select enable_ecommerce" id='enable_ecommerce' <% if(!active){ %>name='enable_ecommerce' onchange="duplicateField(this)"<%}else{%>disabled<%}%> class="form-control input">
                                                                        <option value="0">No</option>
                                                                        <option value="1" <%=parseNull(rs.value("enable_ecommerce")).equals("1")?"selected":""%>>Yes</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <% } %>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="default_menu_id" class="col-sm-3 control-label" style="line-height:2rem;">Default Menu</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select default_menu_id" id='default_menu_id' <% if(!active){ %>name='default_menu_id' onchange="duplicateField(this)"<%}else{%>disabled<%}%> name='default_menu_id' >
                                                                        <option value='0'>-- Select menu --</option>
                                                                        <% while(rsm.next()) {
                                                                            if(parseNull(rs.value("prod_default_menu_id")).equals(rsm.value("id"))) selectedproddefaultmenu = parseNull(rsm.value("name"));
                                                                        %>
                                                                            <option value='<%=escapeCoteValue(rsm.value("id"))%>' <%if(rsm.value("id").equals(parseNull(rs.value("default_menu_id")))){%>selected<%}%> <%if("0".equals(parseNull(rs.value("is_active")))){%>style='color:red'<%}%>><%=escapeCoteValue(rsm.value("name"))%></option>
                                                                        <% } %>
                                                                    </select>
                                                                    <br>
                                                                    <span>Default menu will be used for this domain's default homepage and default 404. If left blank then system will use the first menu as default menu</span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="auto_accept_signup" class="col-sm-3 control-label" style="line-height:2rem;">Auto accept client signup?</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select auto_accept_signup" id='auto_accept_signup' <% if(!active){ %>name='auto_accept_signup' onchange="duplicateField(this)"<%}else{%>disabled<%}%>>
                                                                        <option value='0'>No</option>
                                                                        <option value='1' <%=parseNull(rs.value("auto_accept_signup")).equals("1")?"selected":""%>>Yes</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="form_boosted_version" class="col-sm-3 control-label" style="line-height:2rem;">Boosted Form Version</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select form_boosted_version" id='form_boosted_version' <% if(!active){ %>name='form_boosted_version' onchange="duplicateField(this)"<%}else{%>disabled<%}%>>
                                                                        <option value='4.x' <%=parseNull(rs.value("form_boosted_version")).equals("4.x")?"selected":""%>>4.x</option>
                                                                        <option value='5.x' <%=parseNull(rs.value("form_boosted_version")).equals("5.x")?"selected":""%>>5.x</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="generate_breadcrumbs" class="col-sm-3 control-label" style="line-height:2rem;">Generate Breadcrumbs</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select generate_breadcrumbs" id='generate_breadcrumbs' <% if(!active){ %>name='generate_breadcrumbs' onchange="duplicateField(this)"<%}else{%>disabled<%}%>>
                                                                        <option value='0' <%=parseNull(rs.value("generate_breadcrumbs")).equals("0")?"selected":""%>>No</option>
                                                                        <option value='1' <%=parseNull(rs.value("generate_breadcrumbs")).equals("1")?"selected":""%>>Yes</option>
                                                                    </select>
                                                                    <span style='color:red;font-size:10px'>This option is for bloc system menus</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <!-- / left column -->
                                                    <!-- right column -->
                                                    <div class="col p-1 rightColumn">
                                                        <div class="form-horizontal">
                                                            <div class="form-group d-flex">
                                                                <label for="prod_gtm" class="col-sm-3 control-label" style="line-height:2rem;">GTM</label>
                                                                <div class="col-sm px-0">
                                                                    <input type="text" class="form-control" id="prod_gtm" value='<%=escapeCoteValue(parseNull(rs.value("prod_gtm")))%>' disabled>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer brand">
                                                                <label for="prod_datalayer_brand" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Brand</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control" id="prod_datalayer_brand" maxlength='255' size='40' disabled value='<%=escapeCoteValue(parseNull(rs.value("prod_datalayer_brand")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer domain">
                                                                <label for="prod_datalayer_domain" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Domain</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control" id="prod_datalayer_domain" maxlength='255' size='40' disabled value='<%=escapeCoteValue(parseNull(rs.value("prod_datalayer_domain")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer market">
                                                                <label for="prod_datalayer_market" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Market</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control" id="prod_datalayer_market" maxlength='255' size='40' disabled value='<%=escapeCoteValue(parseNull(rs.value("prod_datalayer_market")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer asset type">
                                                                <label for="prod_datalayer_asset_type" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer asset type</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control" id="prod_datalayer_asset_type" maxlength='75' size='40' disabled value='<%=escapeCoteValue(parseNull(rs.value("prod_datalayer_asset_type")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer orange zone">
                                                                <label for="prod_datalayer_orange_zone" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer asset type</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control" id="prod_datalayer_orange_zone" maxlength='75' size='40' disabled value='<%=escapeCoteValue(parseNull(rs.value("prod_datalayer_orange_zone")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="Datalayer moringa perimeter">
                                                                <label for="prod_datalayer_moringa_perimeter" class="col-sm-3 control-label" style="line-height:2rem;">Datalayer Moringa Perimeter</label>
                                                                <div class="col-sm px-0">
                                                                    <input type='text' class="form-control" id="prod_datalayer_moringa_perimeter" maxlength='75' size='40' disabled value='<%=escapeCoteValue(parseNull(rs.value("prod_datalayer_moringa_perimeter")))%>' >
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex">
                                                                <label for="prod_ccode" class="col-sm-3 control-label" style="line-height:2rem;">Country code</label>
                                                                <div class="col-sm px-0">
                                                                    <input type="text" class="form-control" id="prod_ccode" value='<%=escapeCoteValue(parseNull(rs.value("prod_ccode")))%>' disabled>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex">
                                                                <label for="prod_website_name" class="col-sm-3 control-label" style="line-height:2rem;">Website name</label>
                                                                <div class="col-sm px-0">
                                                                    <input type="text" class="form-control" id="prod_website_name" value='<%=escapeCoteValue(parseNull(rs.value("prod_website_name")))%>' disabled>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex">
                                                                <label for="prod_site_domain" class="col-sm-3 control-label" style="line-height:2rem;">Domain</label>
                                                                <div class="col-sm px-0">
                                                                    <input type="text" class="form-control" id="prod_site_domain" value='<%=escapeCoteValue(parseNull(rs.value("prod_site_domain")))%>' disabled>
                                                                </div>
                                                            </div>
                                                            <% if(isSuperAdmin) { %>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="prod_enable_ecommerce" class="col-sm-3 control-label" style="line-height:2rem;">Enable Ecommerce</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select input" id="prod_enable_ecommerce" disabled>
                                                                        <option value="0">No</option>
                                                                        <option value="1" <%=parseNull(rs.value("prod_enable_ecommerce")).equals("1")?"selected":""%>>Yes</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <% } %>
                                                            <div class="form-group d-flex">
                                                                <label for="prod_default_menu_id" class="col-sm-3 control-label" style="line-height:2rem;">Default Menu</label>
                                                                <div class="col-sm px-0">
                                                                    <input type="text" class="form-control" id="prod_default_menu_id" value='<%=escapeCoteValue(selectedproddefaultmenu)%>' disabled>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="prod_auto_accept_signup" class="col-sm-3 control-label" style="line-height:2rem;">Auto accept client signup?</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select" id='prod_auto_accept_signup' disabled >
                                                                        <option value='0'>No</option>
                                                                        <option value='1' <%=parseNull(rs.value("prod_auto_accept_signup")).equals("1")?"selected":""%>>Yes</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="prod_boosted_version" class="col-sm-3 control-label" style="line-height:2rem;">Boosted Form Version</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select" id='prod_form_boosted_version' disabled >
                                                                        <option value='4.x' <%=parseNull(rs.value("prod_form_boosted_version")).equals("4.x")?"selected":""%>>4.x</option>
                                                                        <option value='5.x' <%=parseNull(rs.value("prod_form_boosted_version")).equals("5.x")?"selected":""%>>5.x</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                            <div class="form-group d-flex" data-toggle="tooltip" data-placement="top" title="">
                                                                <label for="prod_generate_breadcrumbs" class="col-sm-3 control-label" style="line-height:2rem;">Generate Breadcrumbs</label>
                                                                <div class="col-sm px-0">
                                                                    <select class="custom-select" id='prod_generate_breadcrumbs' disabled >
                                                                        <option value='0' <%=parseNull(rs.value("prod_generate_breadcrumbs")).equals("0")?"selected":""%>>No</option>
                                                                        <option value='1' <%=parseNull(rs.value("prod_generate_breadcrumbs")).equals("1")?"selected":""%>>Yes</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <!-- / right column -->
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                    <div class="card mb-2">
                                        <div class="p-0 card-header btn-group bg-secondary d-flex">
                                            <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#langSpecificPropsCollapse" role="button" aria-expanded="true" style="padding:0.75rem 1.25rem;color:#3c4b64">
                                                <strong>Language specific parameters</strong>
                                            </button>
                                            <button type="button" class="btn btn-default btn-primary" onclick="onSave()">Save</button>
                                        </div>
                                        <div id="langSpecificPropsCollapse" class="collapse border-0">
                                            <div class="card-body" data-lang-id="<%=langId%>">
                                                <div class="row">
                                                    <div class="col left-column">
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Prod path</label>
                                                            <div class="col">
                                                                <div class="input-group">
                                                                    <div class="input-group-prepend">
                                                                        <span class="input-group-text"><%=getProdPortalLink(Etn)%></span>
                                                                    </div>
                                                                        <input type="text" class="form-control production_path"
                                                                            data-lang-id='<%=langId%>'
                                                                            name="production_path_<%=langId%>" id="production_path_<%=langId%>"
                                                                            value='<%=curProdPath%>'
                                                                            <%= (!isProdPathEditable)? "readonly":"required" %>
                                                                        >
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Homepage URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control homepage_url"
                                                                    data-lang-id='<%=langId%>' 
                                                                    name="homepage_url_<%=langId%>" id="homepage_url_<%=langId%>"
                                                                    value='<%=parseNull(sdRs.value("homepage_url"))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Page 404 URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control page_404_url"
                                                                    data-lang-id='<%=langId%>'
                                                                    name="page_404_url_<%=langId%>" id="page_404_url_<%=langId%>"
                                                                    value='<%=parseNull(sdRs.value("page_404_url"))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Login page URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control login_page_url"
                                                                    data-lang-id='<%=langId%>'
                                                                    name="login_page_url_<%=langId%>" id="login_page_url_<%=langId%>"
                                                                    value='<%=parseNull(sdRs.value("login_page_url"))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Default page template</label>
                                                            <div class="col">
                                                                <select class="custom-select" name="default_page_template_id_<%=langId%>" id="default_page_template_id_<%=langId%>">
                                                                    <option value="0">-- no template --</option>
                                                                    <%=getSelectOptions(pageTemplateRs, parseNull(sdRs.value("default_page_template_id")))%>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Login page template</label>
                                                            <div class="col">
                                                                <select class="custom-select" name="login_page_template_id_<%=langId%>" id="login_page_template_id_<%=langId%>">
                                                                    <option value="0">-- no template --</option>
                                                                    <%=getSelectOptions(pageTemplateRs, parseNull(sdRs.value("login_page_template_id")))%>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Cart page template</label>
                                                            <div class="col">
                                                                <select class="custom-select" name="cart_page_template_id_<%=langId%>" id="cart_page_template_id_<%=langId%>">
                                                                    <option value="0">-- no template --</option>
                                                                    <%=getSelectOptions(pageTemplateRs, parseNull(sdRs.value("cart_page_template_id")))%>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Funnel page template</label>
                                                            <div class="col">
                                                                <select class="custom-select" name="funnel_page_template_id_<%=langId%>" id="funnel_page_template_id_<%=langId%>">
                                                                    <option value="0">-- no template --</option>
                                                                    <%=getSelectOptions(pageTemplateRs, parseNull(sdRs.value("funnel_page_template_id")))%>
                                                                </select>
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Fraud Page URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control fraud_page_url"
                                                                    data-lang-id='<%=langId%>'
                                                                    name="fraud_page_url_<%=langId%>" id="fraud_page_url_<%=langId%>"
                                                                    value='<%=parseNull(sdRs.value("fraud_page_url"))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Error Page URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control error_page_url"
                                                                    data-lang-id='<%=langId%>'
                                                                    name="error_page_url_<%=langId%>" id="error_page_url_<%=langId%>"
                                                                    value='<%=parseNull(sdRs.value("error_page_url"))%>' >
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col">
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Prod path</label>
                                                            <div class="col">
                                                                <div class="input-group">
                                                                    <div class="input-group-prepend">
                                                                        <span class="input-group-text"><%=getProdPortalLink(Etn)%></span>
                                                                    </div>
                                                                        <input type="text" class="form-control" disabled
                                                                        name="" value='<%=parseNull(psdRs.value("production_path"))%>'
                                                                        >
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Homepage URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control " disabled
                                                                    value='<%=parseNull(psdRs.value("homepage_url"))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Page 404 URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control" disabled
                                                                    value='<%=parseNull(psdRs.value("page_404_url"))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Login page url</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control" disabled
                                                                    value='<%=parseNull(psdRs.value("login_page_url"))%>' >
                                                            </div>
                                                        </div>

                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Default page template</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control" disabled
                                                                    value='<%=getNameById(pageTemplateRs, parseNull(psdRs.value("default_page_template_id")))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Login page template</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control" disabled
                                                                    value='<%=getNameById(pageTemplateRs, parseNull(psdRs.value("login_page_template_id")))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Cart page template</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control" disabled
                                                                    value='<%=getNameById(pageTemplateRs, parseNull(psdRs.value("cart_page_template_id")))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Funnel page template</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control" disabled
                                                                    value='<%=getNameById(pageTemplateRs, parseNull(psdRs.value("funnel_page_template_id")))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Fraud Page URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control" disabled
                                                                    value='<%=parseNull(psdRs.value("fraud_page_url"))%>' >
                                                            </div>
                                                        </div>
                                                        <div class="form-group row">
                                                            <label class="col-sm-3 col-form-label">Error Page URL</label>
                                                            <div class="col">
                                                                <input type="text" class="form-control" disabled
                                                                    value='<%=parseNull(psdRs.value("error_page_url"))%>' >
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card mb-2">
                                        <div class="p-0 card-header btn-group bg-secondary d-flex">
                                            <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#socialCollapse" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64">
                                                <strong>Social Parameters</strong>
                                            </button>
                                            <button type="button" class="btn btn-default btn-primary" onclick="onSave()">Save</button>
                                        </div>
                                        <div class="collapse border-0" id="socialCollapse">
                                            <div class="card-body d-flex">
                                                <!-- left col -->
                                                <div class="col p-1">
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="This is facebook app ID used in social components e.g. share bar, etc">
                                                        <label for="facebook_app_id" class="col-sm-3 control-label">Facebook app ID</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="facebook_app_id" maxlength='50' size='40' <% if(!active){ %>name='facebook_app_id' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("facebook_app_id")))%>' >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="This is twitter account handle used in social components e.g. share bar, etc">
                                                        <label for="twitter_account" class="col-sm-3 control-label">Twitter account</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="twitter_account" maxlength='50' size='40' <% if(!active){ %>name='twitter_account' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("twitter_account")))%>' >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="This is twitter account handle used in social components e.g. share bar, etc">
                                                        <label for="snap_pixel_code" class="col-sm-3 control-label">Snap Pixel ID</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="snap_pixel_code" maxlength='75' size='40' <% if(!active){ %>name='snap_pixel_code' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("snap_pixel_code")))%>' >
                                                        </div>
                                                    </div>

                                                </div>
                                                <!-- /left col -->

                                                <!-- right col -->
                                                <div class="col p-1">
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="This is facebook app ID used in social components e.g. share bar, etc">
                                                        <label for="prod_facebook_app_id" class="col-sm-3 control-label">Facebook app ID</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_facebook_app_id" maxlength='50' size='40' value='<%=escapeCoteValue(parseNull(rs.value("prod_facebook_app_id")))%>' disabled >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="This is twitter account handle used in social components e.g. share bar, etc">
                                                        <label for="prod_twitter_account" class="col-sm-3 control-label">Twitter account</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_twitter_account" maxlength='50' size='40' value='<%=escapeCoteValue(parseNull(rs.value("prod_twitter_account")))%>' disabled >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="This is twitter account handle used in social components e.g. share bar, etc">
                                                        <label for="prod_snap_pixel_code" class="col-sm-3 control-label">Snap Pixel ID</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_snap_pixel_code" maxlength='75' size='40' value='<%=escapeCoteValue(parseNull(rs.value("prod_snap_pixel_code")))%>' disabled >
                                                        </div>
                                                    </div>
                                                </div>
                                                <!-- /right col -->
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card mb-2">
                                        <div class="p-0 card-header btn-group bg-secondary d-flex">
                                            <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#geoCollapse" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64">
                                                <strong>Geolocation Parameters</strong>
                                            </button>
                                            <button type="button" class="btn btn-default btn-primary" onclick="onSave()">Save</button>
                                        </div>

                                        <div class="collapse border-0" id="geoCollapse">
                                            <div class="card-body d-flex">
                                                <!-- left col -->
                                                <div class="col-6 p-1">
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Geocoding API key">
                                                        <label for="geocoding_api" class="col-sm-3 control-label">Geocoding API</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control geocoding_api" id="geocoding_api" maxlength='100' size='40' <% if(!active){ %>name='geocoding_api' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("geocoding_api")))%>' >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Google Maps API key">
                                                        <label for="googlemap_api" class="col-sm-3 control-label">Google Maps API</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control googlemap_api" id="googlemap_api" maxlength='100' size='40' <% if(!active){ %>name='googlemap_api' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("googlemap_api")))%>' >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Aloglia Stores Index">
                                                        <label for="algolia_stores_index" class="col-sm-3 control-label">Aloglia Stores Index</label>
                                                        <div class="col-sm-9">
                                                            <select class="custom-select algolia_stores_index" id="algolia_stores_index" <% if(!active){ %>name='algolia_stores_index' onchange="duplicateField(this)"<%}else{%>disabled<%}%>>
                                                                <option value="">-- Algolia Index --</option>
                                                            <% Set rsAlg = Etn.execute("Select * from "+GlobalParm.getParm("CATALOG_DB")+".algolia_indexes where site_id = "+escape.cote(siteid)+" and coalesce(algolia_index,'') <> '' order by index_name");
                                                            while(rsAlg.next()){
                                                                String slt = "";
                                                                if(rsAlg.value("algolia_index").equals(parseNull(rs.value("algolia_stores_index")))) slt = "selected";
                                                                out.write("<option value='"+escapeCoteValue(rsAlg.value("algolia_index"))+"' "+slt+">"+escapeCoteValue(rsAlg.value("index_name"))+"</option>");
                                                            }
                                                            %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Leadformance API key">
                                                        <label for="leadformance_api" class="col-sm-3 control-label">Leadformance API</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control leadformance_api" id="leadformance_api" maxlength='100' size='40' <% if(!active){ %>name='leadformance_api' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("leadformance_api")))%>' >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Shop Location Type">
                                                        <label for="shop_location_type" class="col-sm-3 control-label">Shop Location Type</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control shop_location_type" id="shop_location_type" maxlength='255' size='40' <% if(!active){ %>name='shop_location_type' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("shop_location_type")))%>' >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Package Point Location Type">
                                                        <label for="package_point_location_type" class="col-sm-3 control-label">Package Point Location Type</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control package_point_location_type" id="package_point_location_type" maxlength='100' size='40' <% if(!active){ %>name='package_point_location_type' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='<%=escapeCoteValue(parseNull(rs.value("package_point_location_type")))%>' >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Load Maps ?">
                                                        <label for="load_map" class="col-sm-3 control-label">Load Maps ?</label>
                                                        <div class="col-sm-9">
                                                            <input type='checkbox' class="form-control load_map" id="load_map" <% if(!active){ %>name='load_map' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='1' <%if("1".equals(parseNull(rs.value("load_map")))){%>checked<%}%> >
                                                        </div>
                                                    </div>

                                                </div>
                                                <!-- /left col -->

                                                <!-- right col -->
                                                <div class="col-6 p-1">
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Geocoding API key">
                                                        <label for="prod_geocoding_api" class="col-sm-3 control-label">Geocoding API</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_geocoding_api" maxlength='100' size='40' value='<%=escapeCoteValue(parseNull(rs.value("prod_geocoding_api")))%>' disabled >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Google Maps API key">
                                                        <label for="prod_googlemap_api" class="col-sm-3 control-label">Google Maps API</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_googlemap_api" maxlength='100' size='40' value='<%=escapeCoteValue(parseNull(rs.value("prod_googlemap_api")))%>' disabled >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Aloglia Stores Index">
                                                        <label for="prod_algolia_stores_index" class="col-sm-3 control-label">Aloglia Stores Index</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_algolia_stores_index" maxlength='100' size='40' name='prod_algolia_stores_index' value='<%=escapeCoteValue(parseNull(rs.value("prod_algolia_stores_index")))%>' disabled >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Leadformance API key">
                                                        <label for="prod_leadformance_api" class="col-sm-3 control-label">Leadformance API</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_leadformance_api" maxlength='100' size='40' value='<%=escapeCoteValue(parseNull(rs.value("prod_leadformance_api")))%>' disabled >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Shop Location Type">
                                                        <label for="prod_shop_location_type" class="col-sm-3 control-label">Shop Location Type</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_shop_location_type" maxlength='100' size='40' value='<%=escapeCoteValue(parseNull(rs.value("prod_shop_location_type")))%>' disabled >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Package Point Location Type">
                                                        <label for="prod_package_point_location_type" class="col-sm-3 control-label">Package Point Location Type</label>
                                                        <div class="col-sm-9">
                                                            <input type='text' class="form-control" id="prod_package_point_location_type" maxlength='100' size='40' value='<%=escapeCoteValue(parseNull(rs.value("prod_package_point_location_type")))%>' disabled >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Load Maps ?">
                                                        <label for="prod_load_map" class="col-sm-3 control-label">Load Maps ?</label>
                                                        <div class="col-sm-9">
                                                            <input type='checkbox' class="form-control" id="prod_load_map" value='1' <%if("1".equals(parseNull(rs.value("prod_load_map")))){%>checked<%}%> disabled>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!-- /right col -->
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card mb-2">
                                        <div class="p-0 card-header btn-group bg-secondary d-flex">
                                            <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#authCollapse" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64">
                                                <strong>Authentication</strong> <small >(This authentication is different from the menu based authentication. Enabling authentication here will not let users to view any page of website without first login)</small>
                                            </button>
                                            <button type="button" class="btn btn-default btn-primary" onclick="onSave()">Save</button>
                                        </div>

                                        <div class="collapse border-0" id="authCollapse" >
                                            <div class="card-body d-flex">
                                                <!-- left col -->
                                                <div class="col-6 p-1">
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Enabling authentication will restrict access to complete site">
                                                        <label for="site_auth_enabled" class="col-sm-3 control-label">Enable?</label>
                                                        <div class="col-sm-9">
                                                            <input type='checkbox' class="form-control site_auth_enabled" id="site_auth_enabled" <% if(!active){ %>name='site_auth_enabled' onchange="duplicateField(this)"<%}else{%>disabled<%}%> value='1' <%if("1".equals(parseNull(rs.value("site_auth_enabled")))){%>checked<%}%> >
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Site login page html">
                                                        <label for="site_auth_login_page" class="col-sm-3 control-label">Login page html</label>
                                                        <div class="col-sm-9">
                                                            <textarea class="col-sm-12 form-control site_auth_login_page" <% if(!active){ %>name='site_auth_login_page' onchange="duplicateField(this)"<%}else{%>disabled<%}%> id='site_auth_login_page' rows='10' ><%=escapeCoteValue(parseNull(rs.value("site_auth_login_page")))%></textarea>
                                                                <br><br><input type='button' class="btn btn-default btn-primary" value='Help' id='helpbtn'>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!-- /left col -->

                                                <!-- right col -->
                                                <div class="col-6 p-1">
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Enabling authentication will restrict access to complete site">
                                                        <label for="prod_site_auth_enabled" class="col-sm-3 control-label">Enable?</label>
                                                        <div class="col-sm-9">
                                                            <input type='checkbox' class="form-control" id="prod_site_auth_enabled" value='1' <%if("1".equals(parseNull(rs.value("prod_site_auth_enabled")))){%>checked<%}%> disabled>
                                                        </div>
                                                    </div>
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="This is twitter account handle used in social components e.g. share bar, etc">
                                                        <label for="prod_site_auth_login_page" class="col-sm-3 control-label">Login page html</label>
                                                        <div class="col-sm-9">
                                                            <textarea class="col-sm-12 form-control" disabled id='prod_site_auth_login_page' rows='10' ><%=escapeCoteValue(parseNull(rs.value("prod_site_auth_login_page")))%></textarea>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!-- right col -->
                                            </div>
                                        </div>
                                     </div>
                                     <div class="card mb-2">
                                        <div class="p-0 card-header btn-group bg-secondary d-flex">
                                            <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#authTypeCollapse" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64"><strong>Authentication Type</strong></button>
                                            <button type="button" class="btn btn-default btn-primary" onclick="onSave()">Save</button>
                                        </div>

                                        <div class="collapse border-0" id="authTypeCollapse" >
                                            <div class="card-body d-flex">
                                                <!-- left col -->
                                                <div class="col-6 p-1">
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Authentication type">
                                                        <label for="authentication_type" class="col-sm-3 control-label">Authentication type</label>
                                                        <div class="col-sm-9">
                                                            <select class="custom-select authentication_type" <% if(!active){ %>name='authentication_type' onchange="duplicateField(this)"<%}else{%>disabled<%}%> id="authentication_type" onchange="onAuthTypeChange()">
                                                                <option <%=parseNull(rs.value("authentication_type")).equals("default")?"selected":""%>>default</option>
                                                                <option <%=parseNull(rs.value("authentication_type")).equals("orange")?"selected":""%>>orange</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="form-group row orange-authentication-api-row" data-toggle="tooltip" data-placement="top" title="Orange token API Url">
                                                        <label for="orange_token_api_url" class="col-sm-3 control-label">Orange Token API Url</label>
                                                        <div class="col-sm-9">
                                                            <input disabled class="form-control" type="text" name="orange_token_api_url" id="orange_token_api_url" value="<%=parseNull(rs.value("orange_token_api_url"))%>">
                                                        </div>
                                                    </div>
                                                    <div class="form-group row orange-authentication-api-row" data-toggle="tooltip" data-placement="top" title="Orange Authorization Code">
                                                        <label for="orange_authorization_code" class="col-sm-3 control-label">Orange Authorization Code</label>
                                                        <div class="col-sm-9">
                                                            <input disabled class="form-control" type="text" name="orange_authorization_code" id="orange_authorization_code" value="<%=parseNull(rs.value("orange_authorization_code"))%>">
                                                        </div>
                                                    </div>
                                                    <div class="form-group row orange-authentication-api-row" data-toggle="tooltip" data-placement="top" title="Orange Authentication API Url">
                                                        <label for="orange_authentication_api_url" class="col-sm-3 control-label">Orange Authentication API Url</label>
                                                        <div class="col-sm-9">
                                                            <input disabled class="form-control" type="text" name="orange_authentication_api_url" id="orange_authentication_api_url" value="<%=parseNull(rs.value("orange_authentication_api_url"))%>">
                                                        </div>
                                                    </div>
                                                </div>
                                                <!-- /left col -->

                                                <!-- right col -->
                                                <div class="col-6 p-1">
                                                    <div class="form-group row" data-toggle="tooltip" data-placement="top" title="Authentication type">
                                                        <label for="prod_authentication_type" class="col-sm-3 control-label">Authentication type</label>
                                                        <div class="col-sm-9">
                                                            <input  class="form-control" type="text" disabled value="<%=parseNull(rs.value("prod_authentication_type"))%>">
                                                        </div>
                                                    </div>
                                                    <div class="form-group row orange-authentication-api-row" data-toggle="tooltip" data-placement="top" title="Orange token API Url">
                                                        <label for="orange_token_api_url" class="col-sm-3 control-label">Orange Token API Url</label>
                                                        <div class="col-sm-9">
                                                            <input disabled class="form-control" type="text" value="<%=parseNull(rs.value("prod_orange_token_api_url"))%>">
                                                        </div>
                                                    </div>
                                                    <div class="form-group row orange-authentication-api-row" data-toggle="tooltip" data-placement="top" title="Orange Authorization Code">
                                                        <label for="orange_authorization_code" class="col-sm-3 control-label">Orange Authorization Code</label>
                                                        <div class="col-sm-9">
                                                            <input disabled class="form-control" type="text" value="<%=parseNull(rs.value("prod_orange_authorization_code"))%>">
                                                        </div>
                                                    </div>
                                                    <div class="form-group row orange-authentication-api-row" data-toggle="tooltip" data-placement="top" title="Orange Authentication API Url">
                                                        <label for="orange_authentication_api_url" class="col-sm-3 control-label">Orange Authentication API Url</label>
                                                        <div class="col-sm-9">
                                                            <input disabled class="form-control" type="text" value="<%=parseNull(rs.value("prod_orange_authentication_api_url"))%>">
                                                        </div>
                                                    </div>
                                                </div>
                                                <!-- right col -->
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card mb-2">
                                        <div class="p-0 card-header btn-group bg-secondary d-flex">
                                            <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#trustedDomainsCollapse_<%=langId%>" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64"><strong>Trusted Domain</strong></button>
                                            <button type="button" class="btn btn-success <% if(active){ %>d-none<%}%>" onclick="addTrustedDomain(<%=langCnt%>, <%=langId%>)" style="text-wrap:nowrap">+ Add a trusted domain</button>
                                            <button type="button" class="btn btn-default btn-primary" onclick="onSave()">Save</button>
                                        </div>

                                        <div class="collapse border-0" id="trustedDomainsCollapse_<%=langId%>">
                                            <div class="card-body d-flex">
                                                <div class="col">
                                                    <ul class="nav nav-tabs trustedTabs" role="tablist">
                                                        <li class="nav-item" >
                                                            <a class='nav-link active'
                                                            data-toggle="tab" href="#trustedDomainTabLocal_<%=langId%>"
                                                            role="tab" aria-controls="" aria-selected="true">Local</a>
                                                        </li>
                                                        <li class="nav-item" >
                                                            <a class='nav-link'
                                                            data-toggle="tab" href="#trustedDomainTabProduction_<%=langId%>"
                                                            role="tab" aria-controls="" aria-selected="true">Production</a>
                                                        </li>
                                                    </ul>
                                                    <div class="tab-content" >
                                                        <div  id="trustedDomainTabLocal_<%=langId%>" class="tab-pane fade show active" role="tabpanel" aria-labelledby="nav-home-tab">
                                                            <div class="table-responsive">
                                                                <table class="table table-bordered table-hover ">
                                                                    <thead class="thead-dark">
                                                                        <tr>
                                                                        <th scope="col">Apply to</th>
                                                                        <th scope="col">URL/Path</th>
                                                                        <th scope="col">GTM</th>
                                                                        <th scope="col">Cache</th>
                                                                        <th scope="col">Replace tags</th>
                                                                        <th>&nbsp;</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody id="trustedDomainsTableBody_<%=langId%>">
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                        <div  id="trustedDomainTabProduction_<%=langId%>" class="tab-pane fade" role="tabpanel" aria-labelledby="nav-home-tab">
                                                            <div class="table-responsive">
                                                                <table class="table table-bordered table-hover ">
                                                                    <thead class="thead-dark">
                                                                        <tr>
                                                                        <th scope="col">Apply to</th>
                                                                        <th scope="col">URL/Path</th>
                                                                        <th scope="col">GTM</th>
                                                                        <th scope="col">Cache</th>
                                                                        <th scope="col">Replace tags</th>
                                                                        <th>&nbsp;</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <%
                                                                            Set psatRs = Etn.execute("SELECT * FROM "+PROD_PORTAL_DB+"sites_apply_to WHERE site_id = " + escape.cote(siteid) + " order by id ");
                                                                            while(psatRs.next()){
                                                                        %>
                                                                            <tr>
                                                                                <td class="text-nowrap"><%="url".equals(psatRs.value("apply_type"))?"Exact URL":"URL starting with"%></td>
                                                                                <td><%=psatRs.value("apply_to")%></td>
                                                                                <td>
                                                                                    <input type="checkbox" disabled <%="1".equals(psatRs.value("add_gtm_script"))?"checked":""%> >
                                                                                </td>
                                                                                <td><%="1".equals(psatRs.value("cache"))?"ON":"OFF"%></td>
                                                                                <td><%=psatRs.value("replace_tags")%></td>
                                                                                <td>&nbsp;</td>
                                                                            </tr>
                                                                        <%  }   %>
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <%
                                        Set rsEcommerce = Etn.execute("select enable_ecommerce from sites where id = " +escape.cote(siteid) );
                                        if(rsEcommerce.next() && "1".equals(parseNull(rsEcommerce.value("enable_ecommerce")))){


                                        if(siteConfigCounter==0){
                                    %>
                                    <div class="card mb-2">
                                        <div class="p-0 card-header btn-group bg-secondary d-flex">
                                            <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#siteConfigCollapse" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64"><strong>Site Config</strong></button>
                                            <button type="button" class="btn btn-default btn-primary" onclick="onSave()">Save</button>
                                        </div>

                                        <div class="collapse border-0" id="siteConfigCollapse">
                                            <div class="card-body d-flex">
                                                <div class="col">
                                                    <ul class="nav nav-tabs trustedTabs" role="tablist">
                                                        <li class="nav-item" >
                                                            <a class='nav-link active'
                                                            data-toggle="tab" href="#siteConfigTabLocal"
                                                            role="tab" aria-controls="" aria-selected="true">Local</a>
                                                        </li>
                                                        <li class="nav-item" >
                                                            <a class='nav-link'
                                                            data-toggle="tab" href="#siteConfigTabProduction"
                                                            role="tab" aria-controls="" aria-selected="true">Production</a>
                                                        </li>
                                                    </ul>
                                                    <div class="tab-content" >
                                                        <div  id="siteConfigTabLocal" class="tab-pane fade show active" role="tabpanel" aria-labelledby="nav-home-tab">
                                                            <div class="table-responsive">
                                                                <table class="table table-bordered table-hover ">
                                                                    <thead class="thead-dark">
                                                                        <tr>
                                                                            <th scope="col">Action</th>
                                                                            <th scope="col">Process</th>
                                                                            <th scope="col">Phase</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <%
                                                                            String process="";
                                                                            String phase="";
                                                                            Set rsSiteConfig = Etn.execute("SELECT process, phase FROM site_config_process WHERE site_id = " + escape.cote(siteid) + " and action='initpayment' ");
                                                                            if(rsSiteConfig.next()){
                                                                                process = parseNull(rsSiteConfig.value("process"));
                                                                                phase = parseNull(rsSiteConfig.value("phase"));
                                                                            }
                                                                        %>
                                                                            <tr>
                                                                                <td>Initiate Payment</td>
                                                                                <td>
                                                                                    <select name="processLocalInitiate" id="processLocalInitiate" onchange="loadPhasesOfProcess('processLocalInitiate','phasesLocalInitiate','local')" class="form-control" style="display:inline-block;width:auto;">
																						<option value=''></option>
                                                                                        <%
                                                                                            Set rsProcesses = Etn.execute("SELECT * from "+SHOP_DB+"processes where site_id="+escape.cote(siteid));
                                                                                            while(rsProcesses.next()){
                                                                                        %>
																								<option <%=(parseNull(rsProcesses.value("process_name")).equals(process)==true?"selected='selected'":"")%> value="<%=parseNull(rsProcesses.value("process_name"))%>"><%=parseNull(rsProcesses.value("display_name"))%></option>
                                                                                        <%
                                                                                            }
                                                                                        %>
                                                                                    </select>
                                                                                </td>

                                                                                <td>
                                                                                        <select name="phasesLocalInitiate" id="phasesLocalInitiate" class="form-control" style="display:inline-block;width:auto;">
                                                                                    <%
                                                                                        if(process.length()>0){
                                                                                            Set rsPhases = Etn.execute("select distinct phase from "+SHOP_DB+"phases where process="+escape.cote(process));
                                                                                            while(rsPhases.next()){
                                                                                    %>
																								<option <%=(parseNull(rsPhases.value("phase")).equals(phase)==true?"selected='selected'":"")%> value="<%=parseNull(rsPhases.value("phase"))%>"><%=parseNull(rsPhases.value("phase"))%></option>
																					<%
                                                                                            }
                                                                                        }
                                                                                    %>
                                                                                        </select>
                                                                                </td>
                                                                            </tr>

                                                                        <%
                                                                            process="";
                                                                            phase="";
                                                                            rsSiteConfig = Etn.execute("SELECT process, phase FROM site_config_process WHERE site_id = " + escape.cote(siteid) + " and action='confirmation' ");
                                                                            if(rsSiteConfig.next()){
                                                                                process = parseNull(rsSiteConfig.value("process"));
                                                                                phase = parseNull(rsSiteConfig.value("phase"));
                                                                            }
                                                                        %>
                                                                            <tr>
                                                                                <td>Order Confirmation</td>
                                                                                <td>
                                                                                    <select name="processLocalConfirmation" id="processLocalConfirmation" onchange="loadPhasesOfProcess('processLocalConfirmation','phasesLocalConfirmation','local')" class="form-control" style="display:inline-block;width:auto;">
																						<option value=''></option>
                                                                                        <%
                                                                                            rsProcesses = Etn.execute("SELECT * from "+SHOP_DB+"processes where site_id="+escape.cote(siteid));
                                                                                            while(rsProcesses.next()){
                                                                                                if(parseNull(rsProcesses.value("process_name")).equals(process)){
                                                                                        %>
                                                                                                    <option selected="selected" value="<%=parseNull(rsProcesses.value("process_name"))%>"><%=parseNull(rsProcesses.value("display_name"))%></option>
                                                                                        <%
                                                                                                }else{
                                                                                        %>
                                                                                                    <option value="<%=parseNull(rsProcesses.value("process_name"))%>"><%=parseNull(rsProcesses.value("display_name"))%></option>
                                                                                        <%
                                                                                                }
                                                                                            }
                                                                                        %>
                                                                                    </select>
                                                                                </td>

                                                                                <td>
                                                                                        <select name="phasesLocalConfirmation" id="phasesLocalConfirmation" class="form-control" style="display:inline-block;width:auto;">
                                                                                    <%
                                                                                        if(process.length()>0){
                                                                                            Set rsPhases = Etn.execute("select distinct phase from "+SHOP_DB+"phases where process="+escape.cote(process));
                                                                                            while(rsPhases.next()){
                                                                                                if(parseNull(rsPhases.value("phase")).equals(phase)){
                                                                                    %>
                                                                                                    <option selected="selected" value="<%=parseNull(rsPhases.value("phase"))%>"><%=parseNull(rsPhases.value("phase"))%></option>
                                                                                    <%
                                                                                                }else{
                                                                                    %>
                                                                                                    <option value="<%=parseNull(rsPhases.value("phase"))%>"><%=parseNull(rsPhases.value("phase"))%></option>
                                                                                    <%
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    %>
                                                                                        </select>
                                                                                </td>
                                                                            </tr>


                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                        <div  id="siteConfigTabProduction" class="tab-pane fade" role="tabpanel" aria-labelledby="nav-home-tab">
                                                            <div class="table-responsive">
                                                                <table class="table table-bordered table-hover ">
                                                                    <thead class="thead-dark">
                                                                        <tr>
                                                                            <th scope="col">Action</th>
                                                                            <th scope="col">Process</th>
                                                                            <th scope="col">Phase</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <%
                                                                            process="";
                                                                            phase="";
                                                                            rsSiteConfig = Etn.execute("SELECT process, phase FROM "+PROD_PORTAL_DB+"site_config_process WHERE site_id = " + escape.cote(siteid) + " and action='initpayment' ");
                                                                            if(rsSiteConfig.next()){
                                                                                process = parseNull(rsSiteConfig.value("process"));
                                                                                phase = parseNull(rsSiteConfig.value("phase"));
                                                                            }
                                                                        %>
                                                                            <tr>
                                                                                <td>Initiate Payment</td>
                                                                                <td>
                                                                                    <select name="processProdInitiate" id="processProdInitiate" onchange="loadPhasesOfProcess('processProdInitiate','phasesProdInitiate','prod')" class="form-control" style="display:inline-block;width:auto;">
																						<option value=''></option>
                                                                                        <%
                                                                                            rsProcesses = Etn.execute("SELECT * from "+PROD_SHOP_DB+"processes where site_id="+escape.cote(siteid));
                                                                                            while(rsProcesses.next()){
                                                                                                if(parseNull(rsProcesses.value("process_name")).equals(process)){
                                                                                        %>
                                                                                                    <option selected="selected" value="<%=parseNull(rsProcesses.value("process_name"))%>"><%=parseNull(rsProcesses.value("display_name"))%></option>
                                                                                        <%
                                                                                                }else{
                                                                                        %>
                                                                                                    <option value="<%=parseNull(rsProcesses.value("process_name"))%>"><%=parseNull(rsProcesses.value("display_name"))%></option>
                                                                                        <%
                                                                                                }
                                                                                            }
                                                                                        %>
                                                                                    </select>
                                                                                </td>

                                                                                <td>
                                                                                        <select name="phasesProdInitiate" id="phasesProdInitiate" class="form-control" style="display:inline-block;width:auto;">
                                                                                    <%
                                                                                        if(process.length()>0){
                                                                                            Set rsPhases = Etn.execute("select distinct phase from "+PROD_SHOP_DB+"phases where process="+escape.cote(process));
                                                                                            while(rsPhases.next()){
                                                                                                if(parseNull(rsPhases.value("phase")).equals(phase)){
                                                                                    %>
                                                                                                    <option selected="selected" value="<%=parseNull(rsPhases.value("phase"))%>"><%=parseNull(rsPhases.value("phase"))%></option>
                                                                                    <%
                                                                                                }else{
                                                                                    %>
                                                                                                    <option value="<%=parseNull(rsPhases.value("phase"))%>"><%=parseNull(rsPhases.value("phase"))%></option>
                                                                                    <%
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    %>
                                                                                        </select>
                                                                                </td>
                                                                            </tr>
                                                                        <%
                                                                            process="";
                                                                            phase="";
                                                                            rsSiteConfig = Etn.execute("SELECT process, phase FROM "+PROD_PORTAL_DB+"site_config_process WHERE site_id = " + escape.cote(siteid) + " and action='confirmation' ");
                                                                            if(rsSiteConfig.next()){
                                                                                process = parseNull(rsSiteConfig.value("process"));
                                                                                phase = parseNull(rsSiteConfig.value("phase"));
                                                                            }
                                                                        %>
                                                                            <tr>
                                                                                <td>Order Confirmation</td>
                                                                                <td>
                                                                                    <select name="processProdConfirmation" id="processProdConfirmation" onchange="loadPhasesOfProcess('processProdConfirmation','phasesProdConfirmation','prod')" class="form-control" style="display:inline-block;width:auto;">
																						<option value=''></option>
                                                                                        <%
                                                                                            rsProcesses = Etn.execute("SELECT * from "+PROD_SHOP_DB+"processes where site_id="+escape.cote(siteid));
                                                                                            while(rsProcesses.next()){
                                                                                                if(parseNull(rsProcesses.value("process_name")).equals(process)){
                                                                                        %>
                                                                                                    <option selected="selected" value="<%=parseNull(rsProcesses.value("process_name"))%>"><%=parseNull(rsProcesses.value("display_name"))%></option>
                                                                                        <%
                                                                                                }else{
                                                                                        %>
                                                                                                    <option value="<%=parseNull(rsProcesses.value("process_name"))%>"><%=parseNull(rsProcesses.value("display_name"))%></option>
                                                                                        <%
                                                                                                }
                                                                                            }
                                                                                        %>
                                                                                    </select>
                                                                                </td>

                                                                                <td>
                                                                                        <select name="phasesProdConfirmation" id="phasesProdConfirmation" class="form-control" style="display:inline-block;width:auto;">
                                                                                    <%
                                                                                        if(process.length()>0){
                                                                                            Set rsPhases = Etn.execute("select distinct phase from "+PROD_SHOP_DB+"phases where process="+escape.cote(process));
                                                                                            while(rsPhases.next()){
                                                                                                if(parseNull(rsPhases.value("phase")).equals(phase)){
                                                                                    %>
                                                                                                    <option selected="selected" value="<%=parseNull(rsPhases.value("phase"))%>"><%=parseNull(rsPhases.value("phase"))%></option>
                                                                                    <%
                                                                                                }else{
                                                                                    %>
                                                                                                    <option value="<%=parseNull(rsPhases.value("phase"))%>"><%=parseNull(rsPhases.value("phase"))%></option>
                                                                                    <%
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    %>
                                                                                        </select>
                                                                                </td>
                                                                            </tr>
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <%
                                            siteConfigCounter++;
                                            System.out.println(siteConfigCounter);
                                        }
                                    }
                                    %>

                                    <div class="d-flex justify-content-end">
                                        <button class="btn btn-danger" type="button" onclick='removeLang("<%=rsLang.value("langue")%>","<%=rsLang.value("langue_id")%>")' >Remove <%=rsLang.value("langue")%></button>
                                    </div>
                                </div>
                                <%
										langCnt++;
                                        active = true;
                                    }
                                %>
                        </form>
                    </div>
                </div>
            </main>

            <div class="d-none">
                <div >
                    <table>
                    <tr id="trustedDomainRowTemplate">
                        <td class="px-1">
                            <input type="hidden" name="apply_to_id" value="">
                            <select name="apply_type" class="custom-select" onchange="onChangeApplyType(this)">
                                <option value="url">Exact URL</option>
                                <option value="url_starting_with">URL starting with</option>
                            </select>
                        </td>
                        <td class="px-1">
                            <input type="text" class="form-control applyToInput" name="apply_to" value=""
                                            maxlength="255" required="required" placeholder="URL">
                        </td>
                        <td align="center">
                            <input type="hidden" name="add_gtm_script" value="0">
                            <input class="form-check-input" type="checkbox" name="add_gtm_script_check"
                                value="1" onchange="onChangeGtmCheckbox(this)">
                        </td>
                        <td align="center" class="text-nowrap">
                            <select name="apply_to_cache" class="custom-select">
                            <option value="0">OFF</option>
                            <option value="1">ON</option>
                            </select>
                        </td>
                        <td class="px-1" style="width: 20%;">
                            <input type="hidden" name="replace_tags" value="">
                            <span class="replaceTagsSpan"></span>
                        </td>
                        <td class="text-nowrap">
                            <button type="button" class="btn btn-sm btn-success replaceTagsBtn" title="Replace tags"
                                        onclick='openReplaceTagsWindow(this)' >
                                        <i data-feather="code"></i></button>
                            <button type="button" class="btn btn-sm btn-danger deleteBtn" title="Delete"
                                        onclick='deleteTrustedDomain(this)' >
                                        <i data-feather="x"></i></button>
                        </td>
                    </tr>
                    </table>
                </div>
            </div>

            <%@ include file="/WEB-INF/include/footer.jsp" %>
            <div id='dhelp' class="modal fade" tabindex="-1" role="dialog" >
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header" style='text-align:left'>
                            <h5 class="modal-title">How to create a login page</h5>
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                                </button>
                        </div>
                        <div class="modal-body">
                            <div>
                                <div class="form-group">
                                <ul><strong>Following things are mandatory for the login page html</strong>
                                <li>The html must contain a form</li>
                                <li>The action of form will always be ##frmPath##</li>
                                <li>Method of form as post and autocomplete off</li>
                                <li>Example form tag : <strong>&lt;form action='##frmPath##' autocomplete='off' method='post' name='frm'&gt;</strong></li>
                                <li>Name of username field must be login</li>
                                <li>Name of password field must be passwd</li>
                                <li>The login button should always has <strong>onclick='javascript:document.forms[0].submit()'</strong></li>
                                <li>To display error message on the form in case of wrong user/password entered, <br>add <strong>&lt;div style='color:red'&gt;##message##&lt;/div&gt;</strong> anywhere in the page you want to display the message. <br>You can change its styling</li>
                                </ul>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
                        </div>
                    </div><!-- /.modal-content -->
                </div><!-- /.modal-dialog -->
            </div>
        </div>
    </div>

	<form name='signup_frm' id='signup_frm' action='siteparameters.jsp' method='post'>
		<input type="hidden" name="is_create_signup_form" value="1">
	</form>

<script type="text/javascript">
    window.$ch = window.$ch || {};

	jQuery(document).ready(function() {

        <%
        rsLang.moveFirst();
		int langCnt = 0;
        while(rsLang.next())
		{
            String langId = rsLang.value("langue_id");		
            for(JSONObject applyToObj : applyToList){
        %>
            addTrustedDomain(<%=langCnt%>, <%=langId%>, <%=applyToObj.toString()%>);
        <%
            }
			langCnt++;
		}
        %>

		$('input.homepage_url').each(function (i, input) {
			var langId = $(input).attr('data-lang-id');
            $(input).attr("data")
            initUrlFieldInput(input, {
                allowEmptyValue : true,
                showOpenType : false,
                // langId : langId
            });
		});

        $('input.page_404_url').each(function (i, input) {
            var langId = $(input).attr('data-lang-id');
            $(input).attr("data")
            initUrlFieldInput(input, {
                allowEmptyValue : true,
                showOpenType : false,
                // langId : langId
            });
        });

        $('input.error_page_url').each(function (i, input) {
            var langId = $(input).attr('data-lang-id');
            $(input).attr("data")
            initUrlFieldInput(input, {
                allowEmptyValue : true,
                showOpenType : false,
                // langId : langId
            });
        });

        $('input.fraud_page_url').each(function (i, input) {
            var langId = $(input).attr('data-lang-id');
            $(input).attr("data")
            initUrlFieldInput(input, {
                allowEmptyValue : true,
                showOpenType : false,
                // langId : langId
            });
        });

        $('input.login_page_url').each(function (i, input) {
            var langId = $(input).attr('data-lang-id');
            $(input).attr("data")
            initUrlFieldInput(input, {
                allowEmptyValue : true,
                showOpenType : false,
                // langId : langId
            });
        });


        $('input.production_path').on('input', function(event) {
            return  onPathKeyup(this);
        });

        //on change of primary language , set other language fields same as it
        $('#langDetails_1 .left-column').find('input[type=text],select')
        .not('.production_path')
        .on('change', function(event) {
            var input = $(this);
            var name = input.attr('name');
            name = name.substring(0, name.lastIndexOf(''));
            console.log(name);
            $('.langDetailsDiv').each(function(index, el) {
                var langId = $(el).attr('data-lang-id');
                if(langId != '1'){
                    $('[name='+name+''+langId+']').val(input.val()).trigger('change');
                }
            });
        });

		enableOrangeFields($("#authentication_type").val());

 		refreshscreen=function()
		{
			window.location = "siteparameters.jsp";
		};

		$("#createmenubtn").click(function(){
			window.location = "menudesigner.jsp?siteid=<%=siteid%>";
		});

		$("#backbtn").click(function(){
			window.location = "site.jsp";
		});


		$("#create_signup_form").on("click", function(){
			$("#signup_frm").submit();
		});

		isValidUrl=function(url)
		{
			if($.trim(url) == '') return true;
            return false;
		};

		$("#helpbtn").click(function(){
			$("#dhelp").modal("show");
		});

        $(".dropdown-item").click(function(e){
            $(e.target).remove();
            if($('li#langAddBtn .dropdown-menu').is(':empty')) $('li#langAddBtn').addClass('d-none');

            addLang(e.target.attributes['lang-id'].value);

        });

        loadPhasesOfProcess = function(processId, phaseId,type){
            let process = document.getElementById(processId).value;
            $.ajax({
                url: 'siteParametersAjax.jsp', type: 'GET', dataType: 'json',
                data: {
                    "process" : process,
                    "type" : type,
                },
            }).always(function(resp) {
                let options = resp.resp;
                let secondSelect = document.getElementById(phaseId);
                secondSelect.innerHTML = "";
                for (let i = 0; i < options.length; i++) {
                    let option = document.createElement("option");
                    option.value = options[i];
                    option.text = options[i];
                    secondSelect.appendChild(option);
                }
            });
        }
	});


    function duplicateField(obj)
	{
		if(obj.type == "checkbox")
		{
			var isChecked = $(obj).is(":checked");
			$("."+obj.id).each(function(){
				if($(this).attr('id') == obj.name)
				{
					if(isChecked) $(this).prop('checked', true);
					else $(this).prop('checked', false);
				}
			});

		}
		else
		{
			$("."+obj.id).each(function(){
				if($(this).attr('id') == obj.name)
				{
					$(this).val(obj.value);
				}
			});
		}
	}

    function onSave( isProdPathValid ){

        var form = $("#frm");
        hideErrorMsg();
        form.find(".production_path").removeClass('is-invalid');

        //call url validation
        form.find("input.homepage_url, input.page_404_url, input.login_page_url,input.fraud_page_url,input.error_page_url").trigger('blur');

        var invalidFields = form.find('.is-invalid');
        if(invalidFields.length > 0 ){
            showErrorMsg("Some fields have invalid values");
            focusInvalidInput(invalidFields[0]);
            return false;
        }

        let processProdInitiate = "";
		if(document.getElementById('processProdInitiate') != null) processProdInitiate = document.getElementById('processProdInitiate').value;

        let phasesProdInitiate = "";
        if(document.getElementById('phasesProdInitiate') != null) phasesProdInitiate = document.getElementById('phasesProdInitiate').value;

        let processLocalInitiate = "";
        if(document.getElementById('processLocalInitiate') != null) processLocalInitiate = document.getElementById('processLocalInitiate').value;

        let phasesLocalInitiate = "";
		if(document.getElementById('phasesLocalInitiate') != null) phasesLocalInitiate = document.getElementById('phasesLocalInitiate').value;

        let processProdConfirmation = "";
		if(document.getElementById('processProdConfirmation') != null) processProdConfirmation = document.getElementById('processProdConfirmation').value;

        let phasesProdConfirmation = "";
		if(document.getElementById('phasesProdConfirmation') != null) phasesProdConfirmation = document.getElementById('phasesProdConfirmation').value;

        let processLocalConfirmation = "";
		if(document.getElementById('processLocalConfirmation') != null) processLocalConfirmation = document.getElementById('processLocalConfirmation').value;

        let phasesLocalConfirmation = "";
		if(document.getElementById('phasesLocalConfirmation') != null) phasesLocalConfirmation = document.getElementById('phasesLocalConfirmation').value;

        /*if(processProdInitiate.length == 0 || phasesProdInitiate.length == 0 ||processLocalInitiate.length == 0 ||phasesLocalInitiate.length == 0 ||
            processProdConfirmation.length==0 || phasesProdConfirmation.length==0 ||processLocalConfirmation.length==0|| phasesLocalConfirmation.length==0){
            showErrorMsg("Site config fields are missing.");
            return false;
        }*/

        if($.trim($("#site_domain").val()) != '')
        {
            var _sdomain = $.trim($("#site_domain").val());

            if(_sdomain.toLowerCase().indexOf("https:") != 0 && _sdomain.toLowerCase().indexOf("http:") != 0)
            {
                showErrorMsg("You must provide valid domain starting with http: or https:");
                return false;
            }
            _sdomain = _sdomain.toLowerCase().replace("http://","").replace("https://","");

            if(_sdomain.endsWith("/")) _sdomain = _sdomain.substring(0, _sdomain.length-1);

            if(_sdomain.indexOf("/") > -1)
            {
                showErrorMsg("Enter a valid Domain");
                return false;
            }

        }

        if($.trim($("#site_auth_login_page").val()) != '')
        {

            var v = $("#site_auth_login_page").val();
            v = v.replace(/onclick=/g,"_etn_oclk_=");
            v = v.replace(/src=/g,"_etn_source_=");
            v = v.replace(/<meta/g,"<etn_meta");
            v = v.replace(/<link/g,"<etn_link");
            v = v.replace(/<script/g,"<etn_script");
            v = v.replace(/<style/g,"<etn_style");
            v = v.replace(/<a/g,"<etn_a");
            v = v.replace(/href=/g,"etn_hrf=");
            v = v.replace(/javascript:/g,"etn_javascript_:");
            v = v.replace(/<\/script>/g,"</etn_script>");
            v = v.replace(/<\/link>/g,"</etn_link>");
            v = v.replace(/<\/style>/g,"</etn_style>");
            v = v.replace(/<\/a>/g,"</etn_a>");

            $("#site_auth_login_page").val(v);
        }

        if(!isProdPathValid){
            return validateProdPaths(function(){
                onSave(true);
            });
        }

        $("#issave").val('1');
        $("#frm").submit();
    }


    function operateLang(id,triggerFunction)
    {
        $.ajax({
            url: 'siteLangsOperations.jsp', type: 'POST', dataType: 'json',
            data: {
                lang : id,
                trigger : triggerFunction
            },
        }).always(function(resp) {
            if(resp.status==0)
                location.reload();
        });
    }

    function addLang(id)
    {
        operateLang(id,"add");
    }

    function removeLang(lang,id){
        if(!confirm("Do you want to remove "+lang+" ?"))
            return;
        operateLang(id,"remove");
    }

    function enableOrangeFields(val){
        if(val === "orange"){
            $("#orange_authentication_api_url").prop( "disabled", false );
            $("#orange_authorization_code").prop( "disabled", false );
            $("#orange_token_api_url").prop( "disabled", false );
        }else{
            $("#orange_authentication_api_url").prop( "disabled", true );
            $("#orange_authorization_code").prop( "disabled", true );
            $("#orange_token_api_url").prop( "disabled", true );
        }
    }

    function onAuthTypeChange(){
        enableOrangeFields($("#authentication_type").val());
    }

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


    function initUrlFieldInput(input, options) {
        if (!etn || !etn.initUrlGenerator) {
            return false;
        }

        var urlGenOpts = {
            showOpenType: true,
            allowEmptyValue: true
        };

        if(typeof options == 'object'){
            urlGenOpts = $.extend(urlGenOpts, options);
        }

        var gen = etn.initUrlGenerator(input, window.URL_GEN_AJAX_URL, urlGenOpts);
        input = $(input);
        input.data('url-generator', gen);

        //adjust delete button inside input group
        var urlFieldDiv = input.parents('.urlField:first');
        var urlDeleteBtn = urlFieldDiv.find('.deleteBtn');
        urlDeleteBtn.insertBefore(gen.errorMsg);
    }

    function showErrorMsg(errorMsg, scrollTop){
        $("#alertBox1").html(errorMsg).fadeIn();
        if(scrollTop !== false){
            if(typeof($('#topOfScreenLink')[0])!="undefined")
                $('#topOfScreenLink')[0].click();
        }
    }

    function hideErrorMsg(){
        $('#alertBox1').hide();
    }

    function validateProdPaths(callback){

        var form = $("#frm");
        var isValid = true;
        var prodPaths = [];
        form.find("input.production_path").each(function(index, input) {

            var curProdPath = $(input).val().trim();
            if(curProdPath.length === 0){
                $(input).addClass('is-invalid');
                showErrorMsg("Prod path cannot be empty.");
                isValid = false;
                focusInvalidInput(input);
                return false;
            }
            else if(prodPaths.indexOf(curProdPath) >= 0){
                $(input).addClass('is-invalid');
                showErrorMsg("Path conflict. Prod path for each language should be unique.");
                isValid = false;
                focusInvalidInput(input);
                return false;
            }
            else{
                $(input).removeClass('is-invalid');
                prodPaths.push(curProdPath);
            }
        });

        if(!isValid) return false;
        $.ajax({
            url: 'verifysitepaths.jsp', type: 'POST', dataType: 'json',
            data: {
                siteDomain : $('#site_domain').val(),
                prodPaths : prodPaths.join(',')
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                if(callback){
                    callback();
                }
            }
            else{
                showErrorMsg(resp.message);
            }
        })
        .fail(function() {
            showErrorMsg("Error in contacting server for paths verification. Please try again.");
        })
        .always(function() {
        });

    }

    function addTrustedDomain(langidx, langid, dataObj){
		//console.log(dataObj);
        var newRow = $('#trustedDomainRowTemplate').clone();

        newRow.attr('id',null);
        $('#trustedDomainsTableBody_'+langid).append(newRow);

        if(typeof dataObj === 'undefined'){
            newRow.find("[name=apply_to]").focus();
        }
        else{
            var isLocalhost = ("127.0.0.1" == (dataObj.apply_to.trim()));

            newRow.find('[name=apply_to_id]').val(dataObj.id);
            newRow.find('[name=apply_type]').val(dataObj.apply_type).trigger('change');
            newRow.find('[name=apply_to]').val(dataObj.apply_to);
            newRow.find('[name=apply_to_cache]').val(dataObj.cache);

            var addGtmCheck = newRow.find('[name=add_gtm_script_check]');
            if(dataObj.add_gtm_script == '1'){
                addGtmCheck.prop('checked',true).trigger('change');
            }

            newRow.find('[name=replace_tags]').val(dataObj.replace_tags);
            newRow.find('.replaceTagsSpan').html(dataObj.replace_tags);

            if(isLocalhost){
                newRow.find("[name=apply_to]")
                    .prop('readonly',true);

                newRow.find('[name=apply_type]').prop("disabled",true)
                    .attr('name','').after("<input type='hidden' name='apply_type' value='"+dataObj.apply_type+"'>");

                newRow.find('[name=apply_to_cache]').replaceWith("<strong>ON</strong><input <input type='hidden' name='apply_to_cache' value='1'>");

                newRow.find(".deleteBtn, .replaceTagsBtn").hide();
            }

			if(langidx > 0)
			{
				newRow.find(".deleteBtn, .replaceTagsBtn").hide();
				newRow.find('[name=apply_type]').prop("disabled",true);
				newRow.find('[name=add_gtm_script_check]').prop("disabled",true);
				newRow.find('[name=apply_to_cache]').prop("disabled",true);
				newRow.find('[name=apply_to]').prop("disabled",true);
				
				newRow.find('[name=apply_to_id]').removeAttr("name");
				newRow.find('[name=apply_type]').removeAttr("name");
				newRow.find('[name=apply_to]').removeAttr("name");
				newRow.find('[name=apply_to_cache]').removeAttr("name");
				newRow.find('[name=add_gtm_script]').removeAttr("name");
				newRow.find('[name=add_gtm_script_check]').removeAttr("name");
				newRow.find('[name=replace_tags]').removeAttr("name");
			}
        }
    }

    function focusInvalidInput(input){
        if(!$(input).is(":visible")){
            $(input).closest(".collapse").collapse("show");
            if(input.hasAttribute("data-lang-id")){
                $('a[data-lang-id='+$(input).attr("data-lang-id")+']').trigger('click');
            }
        }
        $(input).focus();
        $([document.documentElement, document.body]).animate({
            scrollTop: $(input).offset().top - 120
        }, 1000);
    }

    function deleteTrustedDomain(btn){
        var msg = "Are you sure you want to delete?";
        if(confirm(msg)){
            $(btn).parents("tr:first").remove();
        }
    }

    function onChangeApplyType(select){
        select = $(select);
        inputs = select.parent().parent().find("input.applyToInput");

        var placeholder = select.val() == "url_starting_with" ? "URL starting with" : "URL";
        inputs.attr('placeholder', placeholder);

    }

    function onChangeGtmCheckbox(checkbox){
        checkbox = $(checkbox);
        var hiddenInput = checkbox.parent().find('[name=add_gtm_script]');

        hiddenInput.val(checkbox.prop('checked')?"1":"0");
    }

    $ch.replaceTagsList = [];
    $ch.replaceTagInput = null;
    function openReplaceTagsWindow(btn){
        btn = $(btn);
        var row = btn.parents("tr:first");
        $ch.replaceTagInput = row.find("[name=replace_tags]");
        $ch.replaceTagsList = [];

        var u = row.find('[name=apply_to]').val().trim();
        if(!u.startsWith("http://") && !u.startsWith("https://")){
            u = "http://"+u;
        }

        var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
        prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
            prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
            win = window.open("selector.jsp?url="+u,"Select divs to replace", prop);
            win.focus();
    };
	
    function addSelectedSection(_id){
        $ch.replaceTagsList.push(_id);
        setReplaceTags();
    };

    function removeSelectedSection(_id){
        for(var i=0; i<$ch.replaceTagsList.length; i++)
        {
            if($ch.replaceTagsList[i] == _id) $ch.replaceTagsList.splice(i, 1);
        }
        setReplaceTags();
    };

    function setReplaceTags(){
        var replaceTagsStr = $ch.replaceTagsList.join(", ");
        $ch.replaceTagInput.val(replaceTagsStr);

        $ch.replaceTagInput.parent().find(".replaceTagsSpan").html(replaceTagsStr);
    };

</script>

</body>
</html>
