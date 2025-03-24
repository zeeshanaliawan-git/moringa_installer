package com.etn.asimina.util;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;

/**
* This class will add the required javascript depending on which components are added in the page template
* NOTE:: Never manipulate the jsoup doc here
*/
public class BlockSystemJsFunctions
{
	private static String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
	
	public static boolean isCartEnabled(org.jsoup.nodes.Document doc)
	{
		boolean bool = false;			
		org.jsoup.select.Elements eles = doc.select(".asm-cf-cart");
		if(eles != null && eles.size() > 0) bool = true;
		
		//check ecommerce enabled or not
		eles = doc.select("meta[name=pr:secom]");
		if(eles == null || eles.size() == 0) bool = false;
		else if(parseNull(eles.first().attr("content")).equals("1") == false) bool = false;

		com.etn.util.Logger.info("BlockSystemJsFunctions","Cart enabled : " + bool);
		return bool;
	}
	
	public static boolean isInternalSearchEnabled(org.jsoup.nodes.Document doc)
	{
		boolean bool = false;
		org.jsoup.select.Elements eles = doc.select(".asm-cf-search");
		if(eles != null && eles.size() > 0) bool = true;
		com.etn.util.Logger.info("BlockSystemJsFunctions","Search enabled : " + bool);
		return bool;
	}
	
	public static boolean isAuthEnabled(org.jsoup.nodes.Document doc)
	{
		boolean bool = false;
		org.jsoup.select.Elements eles = doc.select(".asm-cf-auth");
		if(eles != null && eles.size() > 0) bool = true;
		com.etn.util.Logger.info("BlockSystemJsFunctions","Auth enabled : " + bool);
		return bool;
	}
	
	public static boolean isAuthPage(org.jsoup.nodes.Document doc)
	{
		boolean bool = false;
		org.jsoup.select.Elements eles = doc.select(".asm-cf-auth-page");
		if(eles != null && eles.size() > 0) bool = true;
		com.etn.util.Logger.info("BlockSystemJsFunctions","Auth enabled : " + bool);
		return bool;
	}
	
	public static boolean loadProducts(org.jsoup.nodes.Document doc)
	{
		boolean bool = false;
		org.jsoup.select.Elements eles = doc.select(".asm-cf-list-products");
		if(eles != null && eles.size() > 0) bool = true;
		com.etn.util.Logger.info("BlockSystemJsFunctions","Load Products : " + bool);
		return bool;
	}

	public static boolean loadSingleProduct(org.jsoup.nodes.Document doc)
	{
		boolean bool = false;
		org.jsoup.select.Elements eles = doc.select(".asm-cf-product");
		if(eles != null && eles.size() > 0) bool = true;
		com.etn.util.Logger.info("BlockSystemJsFunctions","Load single Product : " + bool);
		return bool;
	}
	
	public static boolean isBreadcrumbAdded(org.jsoup.nodes.Document doc)
	{
		boolean bool = false;
		org.jsoup.select.Elements eles = doc.select(".asm-cf-breadcrumb");
		if(eles != null && eles.size() > 0) bool = true;
		com.etn.util.Logger.info("BlockSystemJsFunctions","Breadcrumb added : " + bool);
		return bool;
	}

	public static boolean isFormExist(org.jsoup.nodes.Document doc)
	{
		boolean bool = false;
		org.jsoup.select.Elements eles = doc.select(".asm-cf-form");
		if(eles != null && eles.size() > 0) bool = true;
		com.etn.util.Logger.info("BlockSystemJsFunctions","Form JS added : " + bool);
		return bool;
	}
	
	public static String getRequiredJs(com.etn.beans.Contexte Etn, org.jsoup.nodes.Document doc)
	{
		boolean authEnabled = isAuthEnabled(doc);
		boolean cartEnabled = isCartEnabled(doc);
		boolean internalSearchEnabled = isInternalSearchEnabled(doc);
		boolean isBreadcrumbAdded = isBreadcrumbAdded(doc);
		boolean isAuthPage = isAuthPage(doc);			
		boolean isFormPage = isFormExist(doc);

		boolean loadProducts = loadProducts(doc);
		boolean loadSingleProduct = loadSingleProduct(doc);

			
		com.etn.util.Logger.info("BlockSystemJsFunctions","authEnabled:"+authEnabled+" isAuthPage:"+isAuthPage+" cartEnabled:"+cartEnabled+" loadProducts:"+loadProducts+" loadSingleProduct:"+loadSingleProduct+" isBreadcrumbAdded:"+isBreadcrumbAdded+"  isForm:"+isFormPage+"internalSearchEnabled:"+internalSearchEnabled);		
		return getRequiredJs(Etn, doc , authEnabled, cartEnabled, internalSearchEnabled, isBreadcrumbAdded, isAuthPage, loadProducts, loadSingleProduct,isFormPage);
	}

	public static String getFormType(com.etn.beans.Contexte Etn, org.jsoup.nodes.Document doc)
	{
		String _scr="";
		org.jsoup.select.Elements eles = doc.select(".asm-cf-form");
		_scr += "\t asimina.cf.formtypes={}\n";						
		for( org.jsoup.nodes.Element ele : eles){
			while (ele != null) {
				if (ele.tagName().equalsIgnoreCase("form")) {
					Set rs = Etn.execute("SELECT type FROM "+com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+".process_forms WHERE form_id="+escape.cote(ele.attr("data-formid")));
					rs.next();
					_scr += "\tasimina.cf.formtypes["+escape.cote(ele.attr("data-formid"))+"]='"+parseNull(rs.value("type"))+"';\n";
				}
				ele = ele.parent();
			}
		}
		return _scr;
	}
	
	private static String getRequiredJs(com.etn.beans.Contexte Etn, org.jsoup.nodes.Document doc ,boolean authEnabled, boolean cartEnabled, boolean internalSearchEnabled, boolean isBreadcrumbAdded, boolean isAuthPage, boolean loadProducts, boolean loadSingleProduct, boolean isForm)
	{
		if(authEnabled == false && cartEnabled == false && internalSearchEnabled == false
		&& isBreadcrumbAdded == false && isAuthPage == false && loadProducts == false && loadSingleProduct == false && isForm == false) return "";
		
		boolean debug = ("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV")) == false);
		
		String _scr = "<script type=\"text/javascript\">\n";
		_scr += "\tvar asimina = asimina || {};\n";
		_scr += "\tasimina.cf = asimina.cf || {};\n";
		_scr += "\tasimina.cf._muid = ______muid;\n";
		_scr += "\tasimina.cf._suid = ______suid;\n";
		_scr += "\tasimina.cf._purl = ______portalurl;\n";
		_scr += "\tasimina.cf._lang = ______lang;\n";
		_scr += "\tasimina.cf._cookiePath = ______portalurl2;\n";
		
		
		
		if(loadProducts)
		{
			_scr += "\tasimina.cf.products = asimina.cf.products || {};\n";	
			_scr += "\tasimina.cf.products.load=function() {\n";
			
			_scr += "\t\t___portaljquery('.asm-cf-list-products').each(function() {\n";				
			_scr += "\t\t\tlet fid =___portaljquery(this).data('asm-cf-list-products-fid');\n";
			if(debug) _scr += "\t\t\tconsole.log(fid);\n";
			_scr += "\t\t\tlet callback =___portaljquery(this).data('asm-cf-list-products-callback');\n";
			if(debug) _scr += "\t\t\tconsole.log(callback);\n";
			_scr += "\t\t\t___portaljquery.ajax({\n";
			_scr += "\t\t\t\turl : asimina.cf._purl + 'clientapis/catalogs/fetchproducts.jsp',\n";
			_scr += "\t\t\t\tmethod : 'post',\n";
			_scr += "\t\t\t\tdata : { id : fid, suid : asimina.cf._suid, lang : asimina.cf._lang },\n";
			_scr += "\t\t\t\tdataType : 'json',\n";
			_scr += "\t\t\t\tsuccess : function (json){\n";
			_scr += "\t\t\t\t\tif(typeof callback !== 'undefined') {\n";
			_scr += "\t\t\t\t\t\tlet xc = eval(callback);\n";
			_scr += "\t\t\t\t\t\tif (typeof xc == 'function') xc(json);\n";
			_scr += "\t\t\t\t\t\telse console.log('ERROR::list products callback is not a function');\n";
			_scr += "\t\t\t\t\t} else console.log('ERROR::add list products callback function');\n";
            _scr += "\t\t\t\t}\n";
			_scr += "\t\t\t})\n";
			_scr += "\t\t})\n";
			_scr += "\t}\n\n";
		}

		if(loadSingleProduct)
		{
			_scr += "\tasimina.cf.product = asimina.cf.product || {};\n";	
			_scr += "\tasimina.cf.product.load=function() {\n";			
			_scr += "\t\t___portaljquery('.asm-cf-product').each(function() {\n";				
			_scr += "\t\t\tlet pid =___portaljquery(this).data('asm-cf-product-id');\n";
			if(debug) _scr += "\t\t\tconsole.log(pid);\n";
			_scr += "\t\t\tlet callback =___portaljquery(this).data('asm-cf-product-callback');\n";
			if(debug) _scr += "\t\t\tconsole.log(callback);\n";
			_scr += "\t\t\t___portaljquery.ajax({\n";
			_scr += "\t\t\t\turl : asimina.cf._purl + 'clientapis/catalogs/fetchproduct.jsp',\n";
			_scr += "\t\t\t\tmethod : 'post',\n";
			_scr += "\t\t\t\tdata : { id : pid, suid : asimina.cf._suid, lang : asimina.cf._lang },\n";
			_scr += "\t\t\t\tdataType : 'json',\n";
			_scr += "\t\t\t\tsuccess : function (json){\n";
			_scr += "\t\t\t\t\tif(typeof callback !== 'undefined') {\n";
			_scr += "\t\t\t\t\t\tlet xc = eval(callback);\n";
			_scr += "\t\t\t\t\t\tif (typeof xc == 'function') xc(json);\n";
			_scr += "\t\t\t\t\t\telse console.log('ERROR::fetch product callback is not a function');\n";
			_scr += "\t\t\t\t\t} else console.log('ERROR::add fetch product callback function');\n";
            _scr += "\t\t\t\t}\n";
			_scr += "\t\t\t})\n";
			_scr += "\t\t})\n";
			_scr += "\t}\n\n";
		}
		
		if(isBreadcrumbAdded)
		{
			_scr += "\tasimina.cf.breadcrumb = asimina.cf.breadcrumb || {};\n";			
			_scr += "\tasimina.cf.breadcrumb._cuid = ___portaljquery(\"meta[name='pr:cuid']\").attr('content');\n";
			
			_scr += "\tasimina.cf.breadcrumb.load=function() {\n";			
			if(debug) _scr += "\t\tconsole.log('in asimina.cf.breadcrumb.load');\n";
			_scr += "\t\tlet callback = ___portaljquery('.asm-cf-breadcrumb').data('asm-cf-breadcrumb-callback');\n";			
			_scr += "\t\t___portaljquery.ajax({\n";
			_scr += "\t\t\turl : asimina.cf._purl + 'loadbreadcrumbs.jsp',\n";
			_scr += "\t\t\tmethod : 'post',\n";
			_scr += "\t\t\tdata : { cuid : asimina.cf.breadcrumb._cuid },\n";
			_scr += "\t\t\tdataType : 'json',\n";
			_scr += "\t\t\tsuccess : function (json){\n";
			_scr += "\t\t\t\tif(typeof callback !== 'undefined') {\n";
			_scr += "\t\t\t\t\tlet xc = eval(callback);\n";
			_scr += "\t\t\t\t\tif (typeof xc == 'function') xc(json);\n";
			_scr += "\t\t\t\t\telse console.log('ERROR::breadcrumb callback is not a function');\n";
			_scr += "\t\t\t\t} else console.log('ERROR::add breadcrumb callback function');\n";
            _scr += "\t\t\t}\n";
			_scr += "\t\t});\n";
			_scr += "\t}\n\n";			
		}

		if(authEnabled)
		{
			_scr += "\tasimina.cf.auth = asimina.cf.auth || {};\n";
			_scr += "\tasimina.cf.auth._signupUrl = asimina.cf._purl + 'pages/signup.jsp?muid=' + asimina.cf._muid;\n";
			_scr += "\tasimina.cf.auth._forgotPassUrl = asimina.cf._purl + 'pages/forgotpassword.jsp?muid=' + asimina.cf._muid;\n";
			_scr += "\tasimina.cf.auth._myAccountUrl = asimina.cf._purl + 'pages/myaccount.jsp?muid=' + asimina.cf._muid;\n";
			_scr += "\tasimina.cf.auth._changePassUrl = asimina.cf._purl + 'pages/changepassword.jsp?muid=' + asimina.cf._muid;\n";
			if(isAuthPage) _scr += "\tasimina.cf._authPage = true;\n\n";
			else _scr += "\tasimina.cf._authPage = false;\n\n";
			
			_scr += "\tasimina.cf.auth.login=function(_data) {\n";
			if(debug) _scr += "\t\tconsole.log('in asimina.cf.auth.login');\n";
			_scr += "\t\tif(typeof _data === 'undefined') { console.log('ERROR::No data object provided'); return false; } \n";
			_scr += "\t\tif(typeof _data.token === 'undefined' || typeof _data.username === 'undefined' || typeof _data.password === 'undefined') { console.log('ERROR::token, username and password must be provided'); return false; } \n";
			_scr += "\t\tlet _remme = 0;\n";
			_scr += "\t\tif(typeof _data.remember_me !== 'undefined') _remme = _data.remember_me; \n";
			_scr += "\t\t___portaljquery.ajax({\n";
			_scr += "\t\t\turl : asimina.cf._purl + 'dologin.jsp',\n";
			_scr += "\t\t\tdata : {muid : asimina.cf._muid, username : _data.username, password : _data.password, rememberme : _remme, logintoken : _data.token},\n";
			_scr += "\t\t\ttype: 'post',\n";
			_scr += "\t\t\tdataType: 'json',\n";
			_scr += "\t\t\tsuccess : function(json){\n";
			_scr += "\t\t\t\tif(json.response == 'error'){\n";
			_scr += "\t\t\t\t\tif(json.gotoUrl){\n";
			_scr += "\t\t\t\t\t\tlet _referrer = window.location.href;\n";
			_scr += "\t\t\t\t\t\tlet _goto = json.gotoUrl;\n";
			_scr += "\t\t\t\t\t\tif(_goto.indexOf('?') > -1) _goto += '&';\n";
			_scr += "\t\t\t\t\t\telse _goto += '?';\n";
			_scr += "\t\t\t\t\t\t_goto += 'ref=' + encodeURIComponent(_referrer);\n";
			_scr += "\t\t\t\t\t\twindow.location = _goto;\n";
			_scr += "\t\t\t\t\t} else {\n";
			_scr += "\t\t\t\t\t\tif(typeof _data.error_callback !== 'undefined') {\n";
			_scr += "\t\t\t\t\t\t\tlet xc = eval(_data.error_callback);\n";
			_scr += "\t\t\t\t\t\t\tif (typeof xc == 'function') xc(json);\n";
			_scr += "\t\t\t\t\t\t\telse console.log('ERROR::login failure callback is not a function');\n";
			_scr += "\t\t\t\t\t\t} else console.log('ERROR::add login failure callback function');\n";
			_scr += "\t\t\t\t\t}\n";
			_scr += "\t\t\t\t} else if(json.response == 'success') {\n";
			_scr += "\t\t\t\t\tif(json.rememberme == '1'){\n";
			_scr += "\t\t\t\t\t\tlet __scookiesecure = 'sameSite=strict'; \n";
			_scr += "\t\t\t\t\t\tif(location.protocol === 'https:') __scookiesecure += ';secure';\n";
			_scr += "\t\t\t\t\t\tlet now = new Date();\n";
			_scr += "\t\t\t\t\t\tnow.setTime( now.getTime() + 7 * 24 * 3600 * 1000 );\n";
			_scr += "\t\t\t\t\t\tif(json.cuid) document.cookie = '_rme_cuid='+json.cuid+';'+__scookiesecure+'; expires='+now.toUTCString()+'; path='+asimina.cf._cookiePath;\n";
			_scr += "\t\t\t\t\t\tif(json.token) document.cookie = '_rme_token='+json.token+';'+__scookiesecure+'; expires='+now.toUTCString()+'; path='+asimina.cf._cookiePath;\n";
			_scr += "\t\t\t\t\t\tif(json.validator) document.cookie = '_rme_vld='+json.validator+';'+__scookiesecure+'; expires='+now.toUTCString()+'; path='+asimina.cf._cookiePath;\n";
			_scr += "\t\t\t\t\t}\n";
			_scr += "\t\t\t\t\tif(typeof _data.success_url !== 'undefined' && _data.success_url != '') window.location = _data.success_url;\n";
			_scr += "\t\t\t\t\telse if(typeof _data.success_callback !== 'undefined') {\n";
			_scr += "\t\t\t\t\t\tlet xc = eval(_data.success_callback);\n";
			_scr += "\t\t\t\t\t\tif (typeof xc == 'function') xc({status : json.status, cuid : json.cuid});\n";
			_scr += "\t\t\t\t\t\telse console.log('ERROR::login success callback is not a function');\n";
			_scr += "\t\t\t\t\t}\n";
			_scr += "\t\t\t\t\telse if(asimina.cf._authPage == false && json.refresh && json.refresh == '1') location.reload();\n";
			_scr += "\t\t\t\t\telse if(json.gotoUrl && json.gotoUrl != '') window.location = json.gotoUrl;\n";
			_scr += "\t\t\t\t\telse __gotoPortalHome();\n";
			_scr += "\t\t\t\t}\n";
			_scr += "\t\t\t},\n";
			_scr += "\t\t\terror : function(){\n";
			_scr += "\t\t\t\twindow.status = 'error connecting server';\n";
			_scr += "\t\t\t}\n";
			_scr += "\t\t});\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.auth.logout=function(callback) {\n";
			if(debug) _scr += "\t\tconsole.log('in asimina.cf.auth.logout');\n";
			_scr += "\t\t___portaljquery.ajax({\n";
			_scr += "\t\t\turl : asimina.cf._purl + 'dologout.jsp',\n";
			_scr += "\t\t\ttype: 'post',\n";
			_scr += "\t\t\tdata : {muid : asimina.cf._muid},\n";
			_scr += "\t\t\tdataType: 'json',\n";
			_scr += "\t\t\tsuccess : function(json){\n";
			_scr += "\t\t\t\tif(json.response == 'success'){\n";
			_scr += "\t\t\t\t\tlet __scookiesecure = 'sameSite=strict';\n";
			_scr += "\t\t\t\t\tif(location.protocol === 'https:') __scookiesecure += ';secure';\n";
			_scr += "\t\t\t\t\tdocument.cookie = '_rme_cuid=;'+__scookiesecure+'; expires=Thu, 01 Jan 1970 00:00:01 GMT; path='+asimina.cf._cookiePath;\n";
			_scr += "\t\t\t\t\tdocument.cookie = '_rme_token=;'+__scookiesecure+'; expires=Thu, 01 Jan 1970 00:00:01 GMT; path='+asimina.cf._cookiePath;\n";
			_scr += "\t\t\t\t\tdocument.cookie = '_rme_vld=;'+__scookiesecure+'; expires=Thu, 01 Jan 1970 00:00:01 GMT; path='+asimina.cf._cookiePath;\n";
			_scr += "\t\t\t\t}\n";			
			_scr += "\t\t\t\tif(typeof callback !== 'undefined') {\n";
			_scr += "\t\t\t\t\tlet xc = eval(callback);\n";
			_scr += "\t\t\t\t\tif (typeof xc == 'function') xc(json);\n";
			_scr += "\t\t\t\t\telse console.log('ERROR::logout callback is not a function');\n";
			_scr += "\t\t\t\t} else { __gotoPortalHome(); }\n";
			_scr += "\t\t\t},\n";
			_scr += "\t\t\terror : function(){\n";
			_scr += "\t\t\t\twindow.status = 'error connecting server';\n";
			_scr += "\t\t\t}\n";
			_scr += "\t\t});\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.auth.signUp=function() {\n";
			_scr += "\t\twindow.location = asimina.cf.auth._signupUrl;\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.auth.getSignupUrl=function() {\n";
			_scr += "\t\treturn asimina.cf.auth._signupUrl;\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.auth.forgotPassword=function() {\n";
			_scr += "\t\twindow.location = asimina.cf.auth._forgotPassUrl;\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.auth.getForgotPasswordUrl=function() {\n";
			_scr += "\t\treturn asimina.cf.auth._forgotPassUrl;\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.auth.myAccount=function() {\n";
			_scr += "\t\twindow.location = asimina.cf.auth._myAccountUrl;\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.auth.getMyAccountUrl=function() {\n";
			_scr += "\t\treturn asimina.cf.auth._myAccountUrl;\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.auth.changePassword=function() {\n";
			_scr += "\t\twindow.location = asimina.cf.auth._changePassUrl;\n";
			_scr += "\t}\n\n";

			_scr += "\tasimina.cf.auth.getChangePasswordUrl=function() {\n";
			_scr += "\t\treturn asimina.cf.auth._changePassUrl;\n";
			_scr += "\t}\n\n";

			_scr += "\t___portaljquery('.asm-cf-signup-url').attr('href', asimina.cf.auth._signupUrl);\n\n";
			_scr += "\t___portaljquery('.asm-cf-changepassword-url').attr('href', asimina.cf.auth._changePassUrl);\n\n";
			_scr += "\t___portaljquery('.asm-cf-forgotpassword-url').attr('href', asimina.cf.auth._forgotPassUrl);\n\n";
			_scr += "\t___portaljquery('.asm-cf-myaccount-url').attr('href', asimina.cf.auth._myAccountUrl);\n\n";

			_scr += "\tasimina.cf.auth.checkLogin=function() {\n";
			if(debug) _scr += "\t\tconsole.log('in asimina.cf.auth.checkLogin');\n";
			_scr += "\t\tlet callbacks = [];\n";
			_scr += "\t\t___portaljquery('.asm-cf-auth').each(function(){\n";
			_scr += "\t\t\t if(___portaljquery(this).data('asm-cf-checklogin-callback')) callbacks.push(___portaljquery(this).data('asm-cf-checklogin-callback'));\n";
			_scr += "\t\t});\n";
			_scr += "\t\t___portaljquery.ajax({\n";
			_scr += "\t\t\turl : asimina.cf._purl + 'checklogin.jsp',\n";
			_scr += "\t\t\ttype: 'post',\n";
			_scr += "\t\t\tdata : {muid : asimina.cf._muid},\n";
			_scr += "\t\t\tdataType : 'json',\n";
			_scr += "\t\t\tsuccess : function(resp){\n";
			_scr += "\t\t\t\tif(callbacks.length == 0) { console.log('ERROR::add check login callback function'); } \n";
			_scr += "\t\t\t\telse {\n";
			_scr += "\t\t\t\t\tfor(let i=0;i<callbacks.length;i++) {\n";
			_scr += "\t\t\t\t\t\tif(typeof callbacks[i] !== 'undefined') {\n";
			_scr += "\t\t\t\t\t\t\tlet xc = eval(callbacks[i]);\n";
			_scr += "\t\t\t\t\t\t\tif (typeof xc == 'function') xc(resp);\n";
			_scr += "\t\t\t\t\t\t\telse console.log('ERROR::check login callback is not a function');\n";
			_scr += "\t\t\t\t\t\t}\n";
			_scr += "\t\t\t\t\t}\n";
			_scr += "\t\t\t\t}\n";
			_scr += "\t\t\t},\n";
			_scr += "\t\t\terror : function() {\n";
			_scr += "\t\t\t\twindow.status = 'error connecting server';\n";
			_scr += "\t\t\t}\n";
			_scr += "\t\t});\n";
			_scr += "\t}\n\n";	
		}

		if(cartEnabled)
		{
			_scr += "\tasimina.cf.cart = asimina.cf.cart || {};\n";			
			_scr += "\tasimina.cf.cart._cartUrl = '"+parseNull(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK"))+"cart.jsp?muid='+asimina.cf._muid;\n";			
			_scr += "\tasimina.cf.cart.load=function(){\n";
			if(debug) _scr += "\t\tconsole.log('in asimina.cf.cart.load');\n";
			_scr += "\t\tlet callback = ___portaljquery('.asm-cf-cart').data('asm-cf-cart-callback');\n";
			_scr += "\t\t___portaljquery.ajax({\n";
			_scr += "\t\t\turl : asimina.cf._purl + 'loadcart.jsp',\n";
			_scr += "\t\t\ttype: 'post',\n";
			_scr += "\t\t\tdata : {muid : asimina.cf._muid},\n";
			_scr += "\t\t\tdataType : 'json',\n";
			_scr += "\t\t\tsuccess : function(resp){\n";
			_scr += "\t\t\t\tif(typeof callback !== 'undefined') {\n";
			_scr += "\t\t\t\t\tlet xc = eval(callback);\n";
			_scr += "\t\t\t\t\tif (typeof xc == 'function') xc(resp);\n";
			_scr += "\t\t\t\t\telse console.log('ERROR::cart callback is not a function');\n";
			_scr += "\t\t\t\t} else console.log('ERROR::add cart call back function');\n";
			_scr += "\t\t\t},\n";
			_scr += "\t\t\terror : function() {\n";
			_scr += "\t\t\t\t\twindow.status = 'error connecting server';\n";
			_scr += "\t\t\t\t}\n";
			_scr += "\t\t});\n";
			_scr += "\t}\n\n";	
			
			_scr += "\tasimina.cf.cart.view=function() {\n";
			if(debug) _scr += "\t\tconsole.log('in asimina.cf.cart.view');\n";
			_scr += "\t\twindow.location = asimina.cf.cart._cartUrl;\n";
			_scr += "\t}\n\n";
			
			_scr += "\tasimina.cf.cart.getCartUrl=function() {\n";
			_scr += "\t\treturn asimina.cf.cart._cartUrl;\n";
			_scr += "\t}\n\n";
			
			_scr += "\t___portaljquery('.asm-cf-cart-url').attr('href', asimina.cf.cart._cartUrl);\n\n";			
		}

		if(isForm)
		{
			_scr += getFormType(Etn, doc);
			_scr += "\tasimina.cf.form = asimina.cf.form || {};\n";						
			_scr += "\tasimina.cf.form.load=function(q) {\n";
			if(debug) _scr += "\t\tconsole.log('in asimina.cf.form.load');\n";
			_scr +="const IMAGE_QUALITY = "+parseNull(com.etn.beans.app.GlobalParm.getParm("client_image_quality"))+";\n";
			_scr +="const MAX_FILE_SIZE = "+parseNull(com.etn.beans.app.GlobalParm.getParm("client_image_max_size"))+"; \n";
			_scr +="function isRequiredEmpty(element, value) {\n";
			_scr +="    if (element.required && value.length == 0) return true;\n";
			_scr +="    return false;\n";
			_scr +="}\n";
			_scr +="function validateEmail(email) {\n";
			_scr +="    if(email.length==0) return true;\n";
			_scr +="    const re =\n";
			_scr +="        /^(([^<>()\\[\\]\\.,;:\\s@\"]+(\\.[^<>()\\[\\]\\.,;:\\s@\"]+)*)|(\".+\"))@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$/;\n";
			_scr +="    return re.test(String(email).toLowerCase());\n";
			_scr +="}\n";
			_scr +="function imageCompress(file) {\n";
			_scr +="    if (file.size >= MAX_FILE_SIZE) {\n";
			_scr +="        let outputFile = file;\n";
			_scr +="        const blobURL = window.URL.createObjectURL(file);\n";
			_scr +="        const img = new Image();\n";
			_scr +="        img.src = blobURL;\n";
			_scr +="        const canvas = document.createElement(\"canvas\");\n";
			_scr +="        const [newWidth, newHeight] = calculateSize(img, 2048);\n";
			_scr +="        canvas.width = newWidth;\n";
			_scr +="        canvas.height = newHeight;\n";
			_scr +="        const ctx = canvas.getContext(\"2d\");\n";
			_scr +="        ctx.drawImage(img, 0, 0, newWidth, newHeight);\n";
			_scr +="        canvas.toBlob(\n";
			_scr +="            (blob) => {\n";
			_scr +="                outputFile = new File([blob], file.name);\n";
			_scr +="            },\n";
			_scr +="            \"image/jpeg\",\n";
			_scr +="            IMAGE_QUALITY\n";
			_scr +="        );\n";
			_scr +="        return outputFile;\n";
			_scr +="    }\n";
			_scr +="    return file;\n";
			_scr +="}\n";
			_scr +="function calculateSize(img, size) {\n";
			_scr +="    let width = img.width;\n";
			_scr +="    let height = img.height;\n";
			_scr +="    let aspectRatio = width / height;\n";
			_scr +="    if (width > height && width > size) {\n";
			_scr +="        width = size;\n";
			_scr +="        height = width / aspectRatio;\n";
			_scr +="    } else if (height > size) {\n";
			_scr +="        height = size;\n";
			_scr +="        width = height * aspectRatio;\n";
			_scr +="    }\n";
			_scr +="    return [width, height];\n";
			_scr +="}\n";
			_scr +="const ignoreTypes = new Set(\"button\", \"submit\", \"reset\");\n";
			_scr +="function formSubmit(element) {\n";
			_scr +="    let form = element.target.closest(\"form\");\n";
			_scr +="    form.addEventListener(\"submit\", function (e) {\n";
			_scr +="        e.preventDefault();\n";
			_scr +="    });\n";
			_scr +="    let error_msgs = {};\n";
			_scr +="    let formData = new FormData();\n";
			_scr +="    formData.set(\"action\", \"ajax/backendAjaxCallHandler.jsp\");\n";
			_scr +="    Array.from(form.elements).forEach(function (e) {\n";
			_scr +="        let inputType = e.type.toLowerCase();\n";
			_scr +="        let inputKey = e.dataset.noeFname || e.name || e.id;\n";
			_scr +="        if (ignoreTypes.has(inputType)) return;\n";
			_scr +="        let inputValue = e.value;\n";
			_scr +="        if (inputType == \"file\") {\n";
			_scr +="            inputValue = e.files[0];\n";
			_scr +="            if (inputValue == undefined) return;\n";
			_scr +="            if (inputValue.type.includes(\"image\"))\n";
			_scr +="                inputValue = imageCompress(inputValue);\n";
			_scr +="            if (inputValue.size >= MAX_FILE_SIZE) {\n";
			_scr +="                if (error_msgs[inputKey]?.length > 0)\n";
			_scr +="                    error_msgs[inputKey].push(\"File too large\");\n";
			_scr +="                else error_msgs[inputKey] = [\"File too large\"];\n";
			_scr +="            }\n";
			_scr +="        } else if (inputType == \"email\") {\n";
			_scr +="            if (!validateEmail(inputValue)) {\n";
			_scr +="                if (error_msgs[inputKey]?.length > 0)\n";
			_scr +="                    error_msgs[inputKey].push(\"Invalid email address\");\n";
			_scr +="                else error_msgs[inputKey] = [\"Invalid email address\"];\n";
			_scr +="            }\n";
			_scr +="        } else if (inputType == \"radio\" || inputType == \"checkbox\")\n";
			_scr +="            inputValue = Array.from(document.querySelectorAll(\"input[data-noe-fname=\" + inputKey + \"]:checked\")).map(input=>{if(input.checked)return input.value});\n";
			_scr +="        if (isRequiredEmpty(e, inputValue)) {\n";
			_scr +="            if (error_msgs[inputKey]?.length > 0)\n";
			_scr +="                error_msgs[inputKey].push(\"Required Field missing\");\n";
			_scr +="            else error_msgs[inputKey] = [\"Required Field missing\"];\n";
			_scr +="            return;\n";
			_scr +="        } else formData.set(inputKey, inputValue);\n";
			_scr +="    });\n";
			_scr +="    formData.set(\"appcontext\", \""+parseNull(com.etn.beans.app.GlobalParm.getParm("FORMS_WEBAPP_URL"))+"\");\n";
			_scr +="    formData.set(\"mid\", ______menuid || formData.get(\"mid\"));\n";
			_scr +="    formData.set(\"menu_lang\", ______lang || formData.get(\"menu_lang\"));\n";
			_scr +="    formData.set(\"portalurl\", ______portalurl || formData.get(\"portalurl\"));\n";
			_scr +="    formData.set(\"form_id\", form.dataset.formid);\n";
			_scr +="    formData.set(\"_ftype\", asimina.cf.formtypes[form.dataset.formid]);\n";
			_scr +="    let response={};\n";
			_scr +="    if (Object.keys(error_msgs).length > 0) {\n";
			_scr +="        response = {\n";
			_scr +="            response: \"error\",\n";
			_scr +="            msg: \"Error in fields\",\n";
			_scr +="            fields: JSON.stringify(error_msgs),\n";
			_scr +="        };\n";
			_scr +="        if (typeof form.dataset.callback !== 'undefined') { let xc = eval(form.dataset.callback); if (typeof xc == 'function') xc(response); else console.log('ERROR::forms callback is not a function');}\n";
			_scr +="        else alert(JSON.stringify(response));\n";
			_scr +="    } else {\n";
			_scr +="        form.reset();\n";
			_scr +="\n";
			_scr +="        if(formData.get(\"_ftyp\") == \"sign_up\" || formData.get(\"_ftyp\") == \"forgot_password\" ){\n";
			_scr +="\n";
			_scr +="            ___portaljquery.ajax({\n";
			_scr +="                type: \"POST\",\n";
			_scr +="				url: formData.get(\"appcontext\") + \"api/checkclient.jsp\",\n";
			_scr +="				data: frm,\n";
			_scr +="				processData: false,\n";
			_scr +="				contentType: false,\n";
			_scr +="				dataType: \'JSON\',\n";
			_scr +="                success: function (resp){\n";
			_scr +="                    if(resp.status!=0){\n";
			_scr +="        				if (typeof form.dataset.callback !== 'undefined') { let xc = eval(form.dataset.callback); if (typeof xc == 'function') xc(resp); else console.log('ERROR::forms callback is not a function');}\n";			
			_scr +="                        else alert(JSON.stringify(response)); \n";
			_scr +="                    }\n";
			_scr +="                    else\n";
			_scr +="                        submitingForm(form,response,formData);\n";
			_scr +="                },\n";
			_scr +="                error: function (err) {\n";
			_scr +="                    response[\"msg\"] = \"Error, something went wrong.\";\n";
			_scr +="                    response[\"response\"] = \"error\";\n";
			_scr +="        			if (typeof form.dataset.callback !== 'undefined') { let xc = eval(form.dataset.callback); if (typeof xc == 'function') xc(response); else console.log('ERROR::forms callback is not a function');}\n";						
			_scr +="                    else alert(JSON.stringify(response));\n";
			_scr +="                }\n";
			_scr +="            });\n";
			_scr +="        }\n";
			_scr +="        else submitingForm(form,response,formData);\n";
			_scr +="    }\n";
			_scr +="}\n";
			_scr +="\n";
			_scr +="function submitingForm(form,response,formData){\n";
			_scr +="\n";
			_scr +="    ___portaljquery.ajax({\n";
			_scr +="        type: \"POST\",\n";
			_scr +="        url: formData.get(\"appcontext\") + formData.get(\"action\"),\n";
			_scr +="        data: formData,\n";
			_scr +="        processData: false,\n";
			_scr +="        contentType: false,\n";
			_scr +="        dataType: \"JSON\",\n";
			_scr +="        success: function (resp) {\n";
			_scr +="        	console.log(JSON.stringify(resp));\n";
			_scr +="        	if (typeof form.dataset.callback !== 'undefined') { let xc = eval(form.dataset.callback); if (typeof xc == 'function') xc(resp); else console.log('ERROR::forms callback is not a function');}\n";									
			_scr +="            else alert(JSON.stringify(response));\n";
			_scr +="        },\n";
			_scr +="        error: function (err) {\n";
			_scr +="            response[\"msg\"] = \"Error, something went wrong.\";\n";
			_scr +="            response[\"response\"] = \"error\";\n";
			_scr +="        	if (typeof form.dataset.callback !== 'undefined') { let xc = eval(form.dataset.callback); if (typeof xc == 'function') xc(response); else console.log('ERROR::forms callback is not a function');}\n";									
			_scr +="            else alert(JSON.stringify(response));\n";
			_scr +="        },\n";
			_scr +="    })\n";
			_scr +="}\n";
			_scr +="\n";
			_scr +="let submitbtns = document.getElementsByClassName(\"asm-cf-form\");\n";
			_scr +="for (let submitbtn of submitbtns) {\n";
			_scr +="    submitbtn.addEventListener(\"click\", function (e) {\n";
			_scr +="        e.preventDefault();\n";
			_scr +="        formSubmit(e);\n";
			_scr +="    });\n";
			_scr +="}\n";
			_scr +="\n";
			_scr += "\t}\n\n";
		}

		if(internalSearchEnabled)
		{
			_scr += "\tasimina.cf.search = asimina.cf.search || {};\n";						
			_scr += "\tasimina.cf.search.do=function(q) {\n";
			if(debug) _scr += "\t\tconsole.log('in asimina.cf.search.do');\n";
			_scr += "\t\tif(___portaljquery.trim(q) != '') window.location = asimina.cf._purl + 'search.jsp?muid='+asimina.cf._muid+'&q='+encodeURIComponent(q);\n";
			_scr += "\t}\n\n";
		}
		_scr += "</script>\n";
		//load cart
		
		String onreadyfunctions = "";
		if(loadProducts) 
		{
			onreadyfunctions += "asimina.cf.products.load();";
		}		
		if(loadSingleProduct) 
		{
			onreadyfunctions += "asimina.cf.product.load();";
		}		
		if(cartEnabled) 
		{
			onreadyfunctions += "asimina.cf.cart.load();";
		}		
		if(authEnabled) 
		{
			onreadyfunctions += "asimina.cf.auth.checkLogin();";
		}	
		if(isBreadcrumbAdded) 
		{
			onreadyfunctions += "asimina.cf.breadcrumb.load();";
		}

		if(isForm) 
		{
			onreadyfunctions += "asimina.cf.form.load();";
		}

		if(onreadyfunctions.length() > 0)
		{
			_scr += "<script type='text/javascript'>___portaljquery(document).ready(function() { "+onreadyfunctions+" });</script>\n";
		}
		return _scr;
	}
}