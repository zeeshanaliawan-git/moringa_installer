<%
	String ___muuid = parseNull(request.getParameter("muid"));

	if(___muuid.length() == 0) 
	{
		response.sendRedirect("error.html");//this will lead to 404 page
		return;
	}
	
	Set _rm = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(___muuid));
	if((_rm == null || _rm.rs.Rows == 0))
	{
		response.sendRedirect("error.html");//this will lead to 404 page
		return;
	}

	Etn.setSeparateur(2, '\001', '\002');
	//define _error_msg in original jsps 

	Set _menuRs = Etn.execute("select m.*, l.langue_id, s.website_name, s.suid as site_uuid, s.enable_ecommerce, "+
		" case when "+escape.cote(__pageTemplateType)+" = 'login' then sd.login_page_template_id when "+escape.cote(__pageTemplateType)+" = 'funnel' then sd.funnel_page_template_id when "+escape.cote(__pageTemplateType)+" = 'cart' then sd.cart_page_template_id else sd.default_page_template_id end as applicable_page_template_id, sd.default_page_template_id  "+
		" from site_menus m join sites s on s.id = m.site_id left outer join language l on l.langue_code = m.lang left outer join sites_details sd on sd.site_id = m.site_id and sd.langue_id = l.langue_id where m.menu_uuid="+escape.cote(___muuid));

	//do not rename these variables as they are used in other jsps
	String _headerHtml = "", _footerHtml = "", _menuid = "", _lang = "", _homepageUrl ="" , _headhtml = "", 	_endscriptshtml = "", _title = "", _favicon = "", ___loadedsiteid = "", ___showloginbar = "", __searchapi = "", ___authPageUrl = "";
	String __searchcompletionurl = "", __searchurl = "", __searchparams = "", ____menuVersion = "V1", ____publishedHpUrl = "", ___loadedlangid = "", ___ptemplateid = "",___loadedsiteuuid = "", ___ecommerceEnabled = "", ___cartFooter = "";
	if(_menuRs != null && _menuRs.next())
	{
		_menuid = _menuRs.value("id");
		_lang = _menuRs.value("lang");
		___ecommerceEnabled = _menuRs.value("enable_ecommerce");
		___loadedlangid = _menuRs.value("langue_id");
		___loadedsiteid = _menuRs.value("site_id");
		___loadedsiteuuid = _menuRs.value("site_uuid");
		____publishedHpUrl = parseNull(_menuRs.value("published_home_url"));	
		
		_title = parseNull(_menuRs.value("website_name"));		
		___ptemplateid = parseNull(_menuRs.value("applicable_page_template_id"));		
		if(___ptemplateid.length() == 0 || "0".equals(___ptemplateid))
		{
			___ptemplateid = parseNull(_menuRs.value("default_page_template_id"));		
		}
		
		____menuVersion = parseNull(_menuRs.value("menu_version"));				
		if(____menuVersion.length() == 0) ____menuVersion = "V1";
		
		if("V1".equalsIgnoreCase(____menuVersion))
		{
			//we get this for V1 menus only ... in V2 they can create footer using block system
			___cartFooter = parseNull(_menuRs.value("cart_footer_html"));
			if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV")))
			{
				Set __rsMHtml = Etn.execute("Select case when coalesce(header_html_1,'') = '' then header_html else header_html_1 end as headerhtml, case when coalesce(footer_html_1,'') = '' then footer_html else footer_html_1 end as footerhtml from site_menu_htmls where menu_id = " + escape.cote(_menuRs.value("id")));
				__rsMHtml.next();
				_headerHtml = __rsMHtml.value("headerhtml");
				_footerHtml = __rsMHtml.value("footerhtml");
			}
			else
			{
				Set __rsMHtml = Etn.execute("Select header_html, footer_html from site_menu_htmls where menu_id = " + escape.cote(_menuRs.value("id")));			
				__rsMHtml.next();
				_headerHtml = __rsMHtml.value("header_html");
				_footerHtml = __rsMHtml.value("footer_html");
			}
			__searchurl = parseNull(_menuRs.value("search_bar_url"));
			__searchcompletionurl = parseNull(_menuRs.value("search_completion_url"));
			__searchparams = parseNull(_menuRs.value("search_params"));
			_favicon = parseNull(_menuRs.value("favicon"));
			___showloginbar = parseNull(_menuRs.value("show_login_bar"));
			__searchapi = parseNull(_menuRs.value("search_api"));
	    }		
	}
	else
	{
		com.etn.asimina.session.PortalSession.getInstance().addParameter(Etn, request, response, "_error_msg", _error_msg);	
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "error.jsp");
		return;
	}

	_headhtml = "<title>"+_title+"</title> \n";
	if(_favicon.length() > 0) _headhtml += "<link rel='shortcut icon' href='"+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+com.etn.beans.app.GlobalParm.getParm("MENU_IMAGES_PATH")+_favicon+"' />";
	_headhtml += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n";
	_headhtml += "<meta name=\"pr:mvrn\" content=\""+____menuVersion.toUpperCase()+"\">\n";
	_headhtml += "<meta name=\"pr:suid\" content=\""+___loadedsiteuuid+"\">\n";
	_headhtml += "<meta name=\"pr:muid\" content=\""+___muuid+"\">\n";
	_headhtml += "<meta name=\"pr:lang\" content=\""+_lang+"\">\n";
	_headhtml += "<meta name=\"pr:secom\" content=\""+___ecommerceEnabled+"\">\n";

	com.etn.asimina.util.LanguageHelper.getInstance().set_lang(Etn, _lang);
	String langDirection = com.etn.asimina.util.LanguageHelper.getInstance().getLangDirection(Etn, _lang);
	
	if("V2".equalsIgnoreCase(____menuVersion))
	{
		String tuuid = "";
		Set _rsT = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".page_templates where id = "+escape.cote(___ptemplateid));
		if(_rsT.next()) tuuid = parseNull(_rsT.value("uuid"));
		_headhtml += "<meta name='pr:tuid' content='"+tuuid+"' >\n";
		
		//this code is used by the dynamic content like cart/funnel steps/signup etc
		//these pages are never cached which means they never have the breadcrumbs
		//so we will set the cenv as P always so that breadcrumb API does not return the dummy breadcrumb
		//and will always return empty json and if the template has the breadcrumb added to it then nothing is shown which is correct
		_headhtml += "<meta name=\"pr:cenv\" content=\"P\">\n";
	}
	else
	{
		if("rtl".equalsIgnoreCase(langDirection)) 
		{
			_headhtml += "<link rel=\"stylesheet\" type=\"text/css\" href='"+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"menu_resources/css/newui/headerfooter-rtl.css?__v=" + parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))+"'>\n";
		}
		else
		{
			_headhtml += "<link rel=\"stylesheet\" type=\"text/css\" href='"+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"menu_resources/css/newui/headerfooter.css?__v=" + parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))+"'>\n";
		}
	
		boolean includeCustomCss = "1".equals(com.etn.beans.app.GlobalParm.getParm("INCLUDE_CUSTOM_CSS"));
		if(includeCustomCss) 
		{
			//check if the custom css exists or not ... not always custom css will be available so to avoid 404 we check if file exists or not
			try
			{
				java.io.File customcssfile = new java.io.File(com.etn.beans.app.GlobalParm.getParm("BASE_DIR") + "menu_resources/css/custom_"+_menuid+".css");
				if(customcssfile.exists()) _headhtml += "<link rel=\"stylesheet\" type=\"text/css\" href='"+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"menu_resources/css/custom_"+_menuid+".css?__v=" + parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))+"'>\n";
			}
			catch(Exception e) {}
		}
	}
	//System.out.println("____menuVersion ------------------------------ " + ____menuVersion);
	String colname = "homepage_url";
	if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV"))) colname = "prod_homepage_url";
	_homepageUrl = parseNull(_menuRs.value(colname));

	String portalExternalLink = GlobalParm.getParm("EXTERNAL_LINK");
	if(portalExternalLink.endsWith("/") == false) portalExternalLink += "/";
	String env = "T";
	if(parseNull(GlobalParm.getParm("IS_PRODUCTION_ENV")).equals("1")) env = "T";
	
	_headhtml += "<script type='text/javascript'>\n";
	_headhtml += "var asmPageInfo = asmPageInfo || {};\n";
	_headhtml += "asmPageInfo.apiBaseUrl = '"+portalExternalLink+"';\n";
	_headhtml += "asmPageInfo.clientApisUrl = '"+portalExternalLink+"clientapis/';\n";
	_headhtml += "asmPageInfo.expSysUrl = '"+GlobalParm.getParm("EXP_SYS_EXTERNAL_URL")+"';\n";
	_headhtml += "asmPageInfo.environment = '"+env+"';\n";
	_headhtml += "asmPageInfo.suid = '"+___loadedsiteuuid+"';\n";
	_headhtml += "asmPageInfo.lang = '"+_lang+"';\n";
	_headhtml += "</script>\n";

	_endscriptshtml += "<script type='text/javascript'>var __loadWithNoConflict = false;\n";
	_endscriptshtml += "if(typeof window.jQuery != 'undefined') __loadWithNoConflict = true;</script>\n";
	_endscriptshtml += "<script src='"+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"menu_resources/js/newui/portalbundle.js?__v=" + parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))+"'></script>\n";
	_endscriptshtml += "<script type='text/javascript'>\n";
	_endscriptshtml += "var ___portaljquery = null;\n";
	_endscriptshtml += "if(__loadWithNoConflict) ___portaljquery = $.noConflict(true);\n";
	_endscriptshtml += "___portaljquery = window.jQuery;\n";
	_endscriptshtml += "var ______portalurl2 = '"+com.etn.beans.app.GlobalParm.getParm("PORTAL_LINK")+"';\n";
	_endscriptshtml += "var ______portalurl = '"+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"';\n";
	_endscriptshtml += "var ______muid = '"+ ___muuid +"';\n";
	_endscriptshtml += "var ______mid = '"+ com.etn.util.Base64.encode(_menuid.getBytes("UTF-8")) +"';\n";
	_endscriptshtml += "var ______lang = '"+ _lang +"';\n";
	_endscriptshtml += "var ______suid = '"+ ___loadedsiteuuid +"';\n";
	
	if("V1".equalsIgnoreCase(____menuVersion)) _endscriptshtml += "var ______loginenable = '"+ ___showloginbar +"';\n";
	
	_endscriptshtml += "</script> \n";
   
	if("V1".equalsIgnoreCase(____menuVersion)) 
	{
		_endscriptshtml += "<script src='"+com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"menu_resources/js/newui/headerfooterbundle.js?__v=" + parseNull(com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION"))+"'></script> \n";	

		if("external".equalsIgnoreCase(__searchapi))//external search implemented by Orange
		{
			_endscriptshtml += "<script type=\"text/javascript\">\n";
			_endscriptshtml += "var defercss2 = document.createElement('link');\n";
			_endscriptshtml += "defercss2.rel = 'stylesheet';\n";
			_endscriptshtml += "defercss2.href = 'https://img.ke.woopic.com/resources/external/emea/completion/v4-0/sources/css/completion.min.css';\n";
			_endscriptshtml += "defercss2.type = 'text/css';\n";
			_endscriptshtml += "var godefer2 = document.getElementsByTagName('link')[0];\n";
			_endscriptshtml += "godefer2.parentNode.insertBefore(defercss2, godefer2);\n";
			_endscriptshtml += "</script>\n";

			_endscriptshtml += "<script src='https://img.ke.woopic.com/resources/external/emea/completion/v4-0/sources/js/completion.min.js'></script>\n";
			_endscriptshtml += "<script>var dsearch = new OrangeSearch();\n dsearch.__initCompleter('"+__searchcompletionurl+"','"+__searchparams+"','"+__searchurl+"','desktopsearchfield');</script>\n";
			_endscriptshtml += "<script>var msearch = new OrangeSearch();\n msearch.__initCompleter('"+__searchcompletionurl+"','"+__searchparams+"','"+__searchurl+"','mobilesearchfield');</script>\n";
		}

		if("1".equals(_menuRs.value("show_login_bar")) || "1".equals(_menuRs.value("enable_cart"))) 
		{
			_endscriptshtml += "<script type='text/javascript'>\n";
			_endscriptshtml += "___portaljquery(document).ready(function() {\n";

			if("1".equals(_menuRs.value("show_login_bar"))) 
			{ 
				_endscriptshtml += "__checkLogin();\n";
			}
			if("1".equals(_menuRs.value("enable_cart"))) 
			{
				//add the script directly to page to improve load time
				_endscriptshtml += "__loadcart();\n";
			}
			_endscriptshtml += "});\n";
			_endscriptshtml += "</script>";

		}
	}
	else//block system menu
	{
		Set ___rsSiteDetails = Etn.execute("select * from sites_details where site_id = "+escape.cote(___loadedsiteid)+ " and langue_id = "+escape.cote(___loadedlangid));
		if(___rsSiteDetails.next())
		{
			if(parseNull(___rsSiteDetails.value("login_page_url")).length() > 0)
			{
				___authPageUrl = com.etn.asimina.util.PortalHelper.getMenuPath(Etn, _menuid) + parseNull(___rsSiteDetails.value("login_page_url"));
			}
		}
	}

	_endscriptshtml += "<script type='text/javascript'>function __gotoPortalHome() { window.location = '"+____publishedHpUrl+"?tm='+(new Date().getTime()); }</script>\n";

	String forterId = parseNull(com.etn.asimina.util.PortalHelper.getSiteConfig(Etn, ___loadedsiteid, "forter_id"));
	if(forterId.length() > 0) 
	{
		_endscriptshtml += "<!-- BEGIN FORTER SCRIPTS -->";		
		_endscriptshtml += "<script type=\"text/javascript\">document.addEventListener('ftr:tokenReady', function(evt) { var token = evt.detail; console.log('forter token : ' + token); ___portaljquery.ajax({url: '"+GlobalParm.getParm("EXTERNAL_LINK")+"/clientapis/forter/savetoken.jsp', data : { t : token }, dataType : 'json', method : 'post', success : function(j) { console.log(j); } }); });</script>";
		_endscriptshtml += "<script type=\"text/javascript\" id=\""+forterId+"\">(function () { var merchantConfig = { csp: false }; var siteId = \""+forterId+"\";function t(t,e){for(var n=t.split(\"\"),r=0;r<n.length;++r)n[r]=String.fromCharCode(n[r].charCodeAt(0)+e);return n.join(\"\")}function e(e){return t(e,-_).replace(/%SN%/g,siteId)}function n(t){try{if(\"number\"==typeof t&&window.location&&window.location.pathname){for(var e=window.location.pathname.split(\"/\"),n=[],r=0;r<=Math.min(e.length-1,Math.abs(t));r++)n.push(e[r]);return n.join(\"/\")||\"/\"}}catch(t){}return\"/\"}function r(t){try{Q.ex=t,o()&&-1===Q.ex.indexOf(X.uB)&&(Q.ex+=X.uB),i()&&-1===Q.ex.indexOf(X.uBr)&&(Q.ex+=X.uBr),a()&&-1===Q.ex.indexOf(X.nIL)&&(Q.ex+=X.nIL),window.ftr__snp_cwc||(Q.ex+=X.s),B(Q)}catch(t){}}function o(){var t=\"no\"+\"op\"+\"fn\",e=\"g\"+\"a\",n=\"n\"+\"ame\";return window[e]&&window[e][n]===t}function i(){return!(!navigator.brave||\"function\"!=typeof navigator.brave.isBrave)}function a(){return document.currentScript&&document.currentScript.src}function c(t,e){function n(o){try{o.blockedURI===t&&(e(),document.removeEventListener(r,n))}catch(t){document.removeEventListener(r,n)}}var r=\"securitypolicyviolation\";document.addEventListener(r,n),setTimeout(function(){document.removeEventListener(r,n)},2*60*1e3)}function u(t,e,n,r){var o=!1;t=\"https://\"+t,c(t,function(){r(!0),o=!0});var i=document.createElement(\"script\");i.onerror=function(){if(!o)try{r(!1),o=!0}catch(t){}},i.onload=n,i.type=\"text/javascript\",i.id=\"ftr__script\",i.async=!0,i.src=t;var a=document.getElementsByTagName(\"script\")[0];a.parentNode.insertBefore(i,a)}function f(){tt(X.uDF),setTimeout(w,N,X.uDF)}function s(t,e,n,r){var o=!1,i=new XMLHttpRequest;if(c(\"https:\"+t,function(){n(new Error(\"CSP Violation\"),!0),o=!0}),\"//\"===t.slice(0,2)&&(t=\"https:\"+t),\"withCredentials\"in i)i.open(\"GET\",t,!0);else{if(\"undefined\"==typeof XDomainRequest)return;i=new XDomainRequest,i.open(\"GET\",t)}Object.keys(r).forEach(function(t){i.setRequestHeader(t,r[t])}),i.onload=function(){\"function\"==typeof e&&e(i)},i.onerror=function(t){if(\"function\"==typeof n&&!o)try{n(t,!1),o=!0}catch(t){}},i.onprogress=function(){},i.ontimeout=function(){\"function\"==typeof n&&n(\"tim\"+\"eo\"+\"ut\",!1)},setTimeout(function(){i.send()},0)}function d(t,siteId,e){function n(t){var e=t.toString(16);return e.length%2?\"0\"+e:e}function r(t){if(t<=0)return\"\";for(var e=\"0123456789abcdef\",n=\"\",r=0;r<t;r++)n+=e[Math.floor(Math.random()*e.length)];return n}function o(t){for(var e=\"\",r=0;r<t.length;r++)e+=n(t.charCodeAt(r));return e}function i(t){for(var e=t.split(\"\"),n=0;n<e.length;++n)e[n]=String.fromCharCode(255^e[n].charCodeAt(0));return e.join(\"\")}e=e?\"1\":\"0\";var a=[];return a.push(t),a.push(siteId),a.push(e),function(t){var e=40,n=\"\";return t.length<e/2&&(n=\",\"+r(e/2-t.length-1)),o(i(t+n))}(a.join(\",\"))}function h(){function t(){F&&(tt(X.dUAL),setTimeout(w,N,X.dUAL))}function e(t,e){r(e?X.uAS+X.uF+X.cP:X.uAS+X.uF),F=\"F\"+\"T\"+\"R\"+\"A\"+\"U\",setTimeout(w,N,X.uAS)}window.ftr__fdad(t,e)}function l(){function t(){F&&setTimeout(w,N,X.uDAD)}function e(t,e){r(e?X.uDS+X.uF+X.cP:X.uDS+X.uF),F=\"F\"+\"T\"+\"R\"+\"A\"+\"U\",setTimeout(w,N,X.uDS)}window.ftr__radd(t,e)}function w(t){try{var e;switch(t){case X.uFP:e=O;break;case X.uDF:e=M;break;default:e=F}if(!e)return;var n=function(){try{et(),r(t+X.uS)}catch(t){}},o=function(e){try{et(),Q.td=1*new Date-Q.ts,r(e?t+X.uF+X.cP:t+X.uF),t===X.uFP&&f(),t===X.uDF&&(I?l():h()),t!==X.uAS&&t!==X.dUAL||I||l(),t!==X.uDS&&t!==X.uDAD||I&&h()}catch(t){r(X.eUoe)}};if(e===\"F\"+\"T\"+\"R\"+\"A\"+\"U\")return void o();u(e,void 0,n,o)}catch(e){r(t+X.eTlu)}}var g=\"22ge:t7mj8unkn;1forxgiurqw1qhw2vwdwxv\",v=\"fort\",p=\"erTo\",m=\"ken\",_=3;window.ftr__config={m:merchantConfig,s:\"24\",si:siteId};var y=!1,U=!1,T=v+p+m,x=400*24*60,A=10,S={write:function(t,e,r,o){void 0===o&&(o=!0);var i=0;window.ftr__config&&window.ftr__config.m&&window.ftr__config.m.ckDepth&&(i=window.ftr__config.m.ckDepth);var a,c,u=n(i);if(r?(a=new Date,a.setTime(a.getTime()+60*r*1e3),c=\"; expires=\"+a.toGMTString()):c=\"\",!o)return void(document.cookie=escape(t)+\"=\"+escape(e)+c+\"; path=\"+u);for(var f=1,s=document.domain.split(\".\"),d=A,h=!0;h&&s.length>=f&&d>0;){var l=s.slice(-f).join(\".\");document.cookie=escape(t)+\"=\"+escape(e)+c+\"; path=\"+u+\"; domain=\"+l;var w=S.read(t);null!=w&&w==e||(l=\".\"+l,document.cookie=escape(t)+\"=\"+escape(e)+c+\"; path=\"+u+\"; domain=\"+l),h=-1===document.cookie.indexOf(t+\"=\"+e),f++,d--}},read:function(t){var e=null;try{for(var n=escape(t)+\"=\",r=document.cookie.split(\";\"),o=32,i=0;i<r.length;i++){for(var a=r[i];a.charCodeAt(0)===o;)a=a.substring(1,a.length);0===a.indexOf(n)&&(e=unescape(a.substring(n.length,a.length)))}}finally{return e}}},D=window.ftr__config.s;D+=\"ck\";var L=function(t){var e=!1,n=null,r=function(){try{if(!n||!e)return;n.remove&&\"function\"==typeof n.remove?n.remove():document.head.removeChild(n),e=!1}catch(t){}};document.head&&(!function(){n=document.createElement(\"link\"),n.setAttribute(\"rel\",\"pre\"+\"con\"+\"nect\"),n.setAttribute(\"cros\"+\"sori\"+\"gin\",\"anonymous\"),n.onload=r,n.onerror=r,n.setAttribute(\"href\",t),document.head.appendChild(n),e=!0}(),setTimeout(r,3e3))},E=e(g||\"22ge:t7mj8unkn;1forxgiurqw1qhw2vwdwxv\"),C=t(\"[0Uhtxhvw0LG\",-_),R=t(\"[0Fruuhodwlrq0LG\",-_),P=t(\"Li0Qrqh0Pdwfk\",-_),k=e(\"dss1vlwhshuirupdqfhwhvw1qhw\"),q=e(\"2241414142gqv0txhu|\"),F,b=\"fgq71iruwhu1frp\",M=e(\"(VQ(1\"+b+\"2vq2(VQ(2vfulsw1mv\"),V=e(\"(VQ(1\"+b+\"2vqV2(VQ(2vfulsw1mv\"),O;window.ftr__config&&window.ftr__config.m&&window.ftr__config.m.fpi&&(O=window.ftr__config.m.fpi+e(\"2vq2(VQ(2vfulsw1mv\"));var I=!1,N=10;window.ftr__startScriptLoad=1*new Date;var j=function(t){var e=\"ft\"+\"r:tok\"+\"enR\"+\"eady\";window.ftr__tt&&clearTimeout(window.ftr__tt),window.ftr__tt=setTimeout(function(){try{delete window.ftr__tt,t+=\"_tt\";var n=document.createEvent(\"Event\");n.initEvent(e,!1,!1),n.detail=t,document.dispatchEvent(n)}catch(t){}},1e3)},B=function(t){var e=function(t){return t||\"\"},n=e(t.id)+\"_\"+e(t.ts)+\"_\"+e(t.td)+\"_\"+e(t.ex)+\"_\"+e(D),r=x;!isNaN(window.ftr__config.m.ckTTL)&&window.ftr__config.m.ckTTL&&(r=window.ftr__config.m.ckTTL),S.write(T,n,r,!0),j(n),window.ftr__gt=n},G=function(){var t=S.read(T)||\"\",e=t.split(\"_\"),n=function(t){return e[t]||void 0};return{id:n(0),ts:n(1),td:n(2),ex:n(3),vr:n(4)}},H=function(){for(var t={},e=\"fgu\",n=[],r=0;r<256;r++)n[r]=(r<16?\"0\":\"\")+r.toString(16);var o=function(t,e,r,o,i){var a=i?\"-\":\"\";return n[255&t]+n[t>>8&255]+n[t>>16&255]+n[t>>24&255]+a+n[255&e]+n[e>>8&255]+a+n[e>>16&15|64]+n[e>>24&255]+a+n[63&r|128]+n[r>>8&255]+a+n[r>>16&255]+n[r>>24&255]+n[255&o]+n[o>>8&255]+n[o>>16&255]+n[o>>24&255]},i=function(){if(window.Uint32Array&&window.crypto&&window.crypto.getRandomValues){var t=new window.Uint32Array(4);return window.crypto.getRandomValues(t),{d0:t[0],d1:t[1],d2:t[2],d3:t[3]}}return{d0:4294967296*Math.random()>>>0,d1:4294967296*Math.random()>>>0,d2:4294967296*Math.random()>>>0,d3:4294967296*Math.random()>>>0}},a=function(){var t=\"\",e=function(t,e){for(var n=\"\",r=t;r>0;--r)n+=e.charAt(1e3*Math.random()%e.length);return n};return t+=e(2,\"0123456789\"),t+=e(1,\"123456789\"),t+=e(8,\"0123456789\")};return t.safeGenerateNoDash=function(){try{var t=i();return o(t.d0,t.d1,t.d2,t.d3,!1)}catch(t){try{return e+a()}catch(t){}}},t.isValidNumericalToken=function(t){return t&&t.toString().length<=11&&t.length>=9&&parseInt(t,10).toString().length<=11&&parseInt(t,10).toString().length>=9},t.isValidUUIDToken=function(t){return t&&32===t.toString().length&&/^[a-z0-9]+$/.test(t)},t.isValidFGUToken=function(t){return 0==t.indexOf(e)&&t.length>=12},t}(),X={uDF:\"UDF\",dUAL:\"dUAL\",uAS:\"UAS\",uDS:\"UDS\",uDAD:\"UDAD\",uFP:\"UFP\",mLd:\"1\",eTlu:\"2\",eUoe:\"3\",uS:\"4\",uF:\"9\",tmos:[\"T5\",\"T10\",\"T15\",\"T30\",\"T60\"],tmosSecs:[5,10,15,30,60],bIR:\"43\",uB:\"u\",uBr:\"b\",cP:\"c\",nIL:\"i\",s:\"s\"};try{var Q=G();try{Q.id&&(H.isValidNumericalToken(Q.id)||H.isValidUUIDToken(Q.id)||H.isValidFGUToken(Q.id))?window.ftr__ncd=!1:(Q.id=H.safeGenerateNoDash(),window.ftr__ncd=!0),Q.ts=window.ftr__startScriptLoad,B(Q),window.ftr__snp_cwc=!!S.read(T),window.ftr__snp_cwc||(M=V);for(var $=\"for\"+\"ter\"+\".co\"+\"m\",z=\"ht\"+\"tps://c\"+\"dn9.\"+$,J=\"ht\"+\"tps://\"+Q.id+\"-\"+siteId+\".cd\"+\"n.\"+$,K=\"http\"+\"s://cd\"+\"n3.\"+$,W=[z,J,K],Y=0;Y<W.length;Y++)L(W[Y]);var Z=new Array(X.tmosSecs.length),tt=function(t){for(var e=0;e<X.tmosSecs.length;e++)Z[e]=setTimeout(r,1e3*X.tmosSecs[e],t+X.tmos[e])},et=function(){for(var t=0;t<X.tmosSecs.length;t++)clearTimeout(Z[t])};window.ftr__fdad=function(e,n){if(!y){y=!0;var r={};r[P]=d(window.ftr__config.s,siteId,window.ftr__config.m.csp),s(E,function(n){try{var r=n.getAllResponseHeaders().toLowerCase();if(r.indexOf(R.toLowerCase())>=0){var o=n.getResponseHeader(R);window.ftr__altd2=t(atob(o),-_-1)}if(r.indexOf(C.toLowerCase())<0)return;var i=n.getResponseHeader(C),a=t(atob(i),-_-1);if(a){var c=a.split(\":\");if(c&&2===c.length){for(var u=c[0],f=c[1],s=\"\",d=0,h=0;d<20;++d)s+=d%3>0&&h<12?siteId.charAt(h++):Q.id.charAt(d);var l=f.split(\",\");if(l.length>1){var w=l[0],g=l[1];F=u+\"/\"+w+\".\"+s+\".\"+g}}}e()}catch(t){}},function(t,e){n&&n(t,e)},r)}},window.ftr__radd=function(t,e){function n(e){try{var n=e.response,r=function(t){function e(t,o,i){try{if(i>=n)return{name:\"\",nextOffsetToProcess:o,error:\"Max pointer dereference depth exceeded\"};for(var a=[],c=o,u=t.getUint8(c),f=0;f<r;){if(f++,192==(192&u)){var s=(63&u)<<8|t.getUint8(c+1),d=e(t,s,i+1);if(d.error)return d;var h=d.name;return a.push(h),{name:a.join(\".\"),nextOffsetToProcess:c+2}}if(!(u>0)){if(0!==u)return{name:\"\",nextOffsetToProcess:c,error:\"Unexpected length at the end of name: \"+u.toString()};return{name:a.join(\".\"),nextOffsetToProcess:c+1}}for(var l=\"\",w=1;w<=u;w++)l+=String.fromCharCode(t.getUint8(c+w));a.push(l),c+=u+1,u=t.getUint8(c)}return{name:\"\",nextOffsetToProcess:c,error:\"Max iterations exceeded\"}}catch(t){return{name:\"\",nextOffsetToProcess:o,error:\"Unexpected error while parsing response: \"+t.toString()}}}for(var n=4,r=100,o=16,i=new DataView(t),a=i.getUint16(0),c=i.getUint16(2),u=i.getUint16(4),f=i.getUint16(6),s=i.getUint16(8),d=i.getUint16(10),h=12,l=[],w=0;w<u;w++){var g=e(i,h,0);if(g.error)throw new Error(g.error);if(h=g.nextOffsetToProcess,!Number.isInteger(h))throw new Error(\"invalid returned offset\");var v=g.name,p=i.getUint16(h);h+=2;var m=i.getUint16(h);h+=2,l.push({qname:v,qtype:p,qclass:m})}for(var _=[],w=0;w<f;w++){var g=e(i,h,0);if(g.error)throw new Error(g.error);if(h=g.nextOffsetToProcess,!Number.isInteger(h))throw new Error(\"invalid returned offset\");var y=g.name,U=i.getUint16(h);if(U!==o)throw new Error(\"Unexpected record type: \"+U.toString());h+=2;var T=i.getUint16(h);h+=2;var x=i.getUint32(h);h+=4;var A=i.getUint16(h);h+=2;for(var S=\"\",D=h,L=0;D<h+A&&L<r;){L++;var E=i.getUint8(D);D+=1;S+=(new TextDecoder).decode(t.slice(D,D+E)),D+=E}if(L>=r)throw new Error(\"Max iterations exceeded while reading TXT data\");h+=A,_.push({name:y,type:U,class:T,ttl:x,data:S})}return{transactionId:a,flags:c,questionCount:u,answerCount:f,authorityCount:s,additionalCount:d,questions:l,answers:_}}(n);if(!r)throw new Error(\"Error parsing DNS response\");if(!(\"answers\"in r))throw new Error(\"Unexpected response\");var o=r.answers;if(0===o.length)throw new Error(\"No answers found\");var i=o[0].data;if(i=i.replace(/^\"(.*)\"$/,\"$1\"),decodedVal=function(t){var e=40,n=32,r=126;try{for(var o=atob(t),i=\"\",a=0;a<o.length;a++)i+=function(t){var o=t.charCodeAt(0),i=o-e;return i<n&&(i=r-(n-i)+1),String.fromCharCode(i)}(o[a]);return atob(i)}catch(t){return}}(i),!decodedVal)throw new Error(\"failed to decode the value\");var a=function(t){var e=\"_\"+\"D\"+\"L\"+\"M\"+\"_\",n=t.split(e);if(!(n.length<2)){var r=n[0],o=n[1];if(!(r.split(\".\").length-1<1))return{jURL:r,eURL:o}}}(decodedVal);if(!a)throw new Error(\"failed to parse the value\");var c=a.jURL,u=a.eURL;F=function(t){for(var e=\"\",n=0,r=0;n<20;++n)e+=n%3>0&&r<12?siteId.charAt(r++):Q.id.charAt(n);return t.replace(\"/PRM1\",\"\").replace(\"/PRM2\",\"/main.\").replace(\"/PRM3\",e).replace(\"/PRM4\",\".js\")}(c),window.ftr__altd3=u,t()}catch(t){}}function r(t,n){e&&e(t,n)}if(!U){window.ftr__config.m.dr===\"N\"+\"D\"+\"R\"&&e(new Error(\"N\"+\"D\"+\"R\"),!1),q&&k||e(new Error(\"D\"+\"P\"+\"P\"),!1),U=!0;try{var o=function(t){for(var e=new Uint8Array([0,0]),n=new Uint8Array([1,0]),r=new Uint8Array([0,1]),o=new Uint8Array([0,0]),i=new Uint8Array([0,0]),a=new Uint8Array([0,0]),c=t.split(\".\"),u=[],f=0;f<c.length;f++){var s=c[f];u.push(s.length);for(var d=0;d<s.length;d++)u.push(s.charCodeAt(d))}u.push(0);var h=16,l=new Uint8Array([0,h]),w=new Uint8Array([0,1]),g=new Uint8Array(e.length+n.length+r.length+o.length+i.length+a.length+u.length+l.length+w.length);return g.set(e,0),g.set(n,e.length),g.set(r,e.length+n.length),g.set(o,e.length+n.length+r.length),g.set(i,e.length+n.length+r.length+o.length),g.set(a,e.length+n.length+r.length+o.length+i.length),g.set(u,e.length+n.length+r.length+o.length+i.length+a.length),g.set(l,e.length+n.length+r.length+o.length+i.length+a.length+u.length),g.set(w,e.length+n.length+r.length+o.length+i.length+a.length+u.length+l.length),g}(k);!function(t,e,n,r,o){var i=!1,a=new XMLHttpRequest;if(c(\"https:\"+t,function(){o(new Error(\"CSP Violation\"),!0),i=!0}),\"//\"===t.slice(0,2)&&(t=\"https:\"+t),\"withCredentials\"in a)a.open(\"POST\",t,!0);else{if(\"undefined\"==typeof XDomainRequest)return;a=new XDomainRequest,a.open(\"POST\",t)}a.responseType=\"arraybuffer\",a.setRequestHeader(\"Content-Type\",e),a.onload=function(){\"function\"==typeof r&&r(a)},a.onerror=function(t){if(\"function\"==typeof o&&!i)try{o(t,!1),i=!0}catch(t){}},a.onprogress=function(){},a.ontimeout=function(){\"function\"==typeof o&&o(\"tim\"+\"eo\"+\"ut\",!1)},setTimeout(function(){a.send(n)},0)}(q,\"application/dns-message\",o,n,r)}catch(t){e(t,!1)}}};var nt=O?X.uFP:X.uDF;tt(nt),setTimeout(w,N,nt)}catch(t){r(X.mLd)}}catch(t){}})();</script>";
		_endscriptshtml += "<!-- END FORTER SCRIPTS -->";
	}	


%>