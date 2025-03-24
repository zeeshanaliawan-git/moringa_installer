<%@ page trimDirectiveWhitespaces="true" %><jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/><%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%><%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%><%@ page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm, com.etn.util.Logger"%><%@ page import="com.etn.sql.escape"%><%@ page import="com.etn.util.Base64, java.net.HttpURLConnection, org.jsoup.*, java.util.regex.Pattern, java.util.regex.Matcher"%><%@include file="common2.jsp"%><%@include file="lib_msg.jsp"%><%@include file="httputils.jsp"%><%@include file="cache.jsp"%><%@include file="countryspecific/commonmethods.jsp"%><%!
	class Detect
	{
		public final String tagStart= "\\<\\w+((\\s+\\w+(\\s*\\=\\s*(?:\".*?\"|'.*?'|[^'\"\\>\\s]+))?)+\\s*|\\s*)\\>";
		public final String tagEnd= "\\</\\w+\\>";
		public final String tagSelfClosing= "\\<\\w+((\\s+\\w+(\\s*\\=\\s*(?:\".*?\"|'.*?'|[^'\"\\>\\s]+))?)+\\s*|\\s*)/\\>";
		public final String htmlEntity= "&[a-zA-Z][a-zA-Z0-9]+;";
		public final Pattern htmlPattern=Pattern.compile("("+tagStart+".*"+tagEnd+")|("+tagSelfClosing+")|("+htmlEntity+")",Pattern.DOTALL);
 
		public boolean isHtml(String s) 
		{
			boolean ret=false;
			if (s != null) {
				ret=htmlPattern.matcher(s).find();
			}
			return ret;
		}
	}
	
	boolean isHtmlPageUrl(String url)
	{
		url = parseNull(url).toLowerCase();
		if(url.length() == 0) return false;
		if(url.equals("#")) return false;
		if(url.equals("/")) return false;
		if(url.contains(".html") == false) return false;
		
		String htmlUrl = url;
		if(htmlUrl.contains("?")) htmlUrl = htmlUrl.substring(0, htmlUrl.indexOf("?"));
		if(htmlUrl.contains("#")) htmlUrl = htmlUrl.substring(0, htmlUrl.indexOf("#"));
		if(htmlUrl.endsWith(".html")) return true;
		return false;		
	}
	
	String findApplicableRule(Contexte Etn, String menuid, String menuVersion, String url)
	{
		String applicableruleid = "";
		String q1 = "select m.*, a.id as rid from site_menus m, menu_apply_to a where m.is_active = 1 and a.menu_id = m.id and a.apply_type = 'url' and a.apply_to = " + escape.cote(url) +
					" and m.id = " + escape.cote(menuid) +
					"  order by case coalesce(m.preference,'') when '' then 999999 else preference end, m.id  ";
		
		if("v2".equalsIgnoreCase(menuVersion))
		{
			q1 = "select m.*, a.id as rid from site_menus m, sites_apply_to a where m.is_active = 1 and a.site_id = m.site_id and a.apply_type = 'url' and a.apply_to = " + escape.cote(url) +
				" and m.id = " + escape.cote(menuid) +
				"  order by case coalesce(m.preference,'') when '' then 999999 else preference end, m.id  ";
		}
		
		Set rsmenu = Etn.execute(q1);
		if(rsmenu.next())
		{
			applicableruleid = rsmenu.value("rid");
		}
		else
		{
			q1 = "select m.*, a.id as rid from site_menus m, menu_apply_to a where m.is_active = 1 and a.menu_id = m.id and a.apply_type = 'url_starting_with' and " + escape.cote(url) + " like concat(a.apply_to,'%') " +
				" and m.id = " + escape.cote(menuid) +
				" order by case coalesce(m.preference,'') when '' then 999999 else preference end, length(a.apply_to) desc ";
			
			if("v2".equalsIgnoreCase(menuVersion))
			{
				q1 = "select m.*, a.id as rid from site_menus m, sites_apply_to a where m.is_active = 1 and a.site_id = m.site_id and a.apply_type = 'url_starting_with' and " + escape.cote(url) + " like concat(a.apply_to,'%') " +
					" and m.id = " + escape.cote(menuid) +
					" order by case coalesce(m.preference,'') when '' then 999999 else preference end, length(a.apply_to) desc ";						
			}
			
			rsmenu = Etn.execute(q1);
			if(rsmenu.next())
			{
				applicableruleid = rsmenu.value("rid");
			}
		}	
		return applicableruleid;
	}
	
	Map<String, String> fixOldFormatUrls(String url)
	{
		try
		{
			if(parseNull(url).length() == 0 ) return null;
			
			Map<String, String> mp = null;
			if(url.toLowerCase().startsWith("http://127.0.0.1/") || url.toLowerCase().startsWith("http://localhost/"))
			{
				Logger.debug("process.jsp","fixOldFormatUrls::Internal url : "+url);
				if(url.contains("_catalog/listproducts.jsp") || url.contains("_prodcatalog/listproducts.jsp"))
				{
					Logger.debug("process.jsp","Its a listing screen url");
					if(url.indexOf("?") > -1)
					{
						java.util.Map<String, java.util.List<String>> mParams = getQueryParams(url);
						if(mParams != null && mParams.get("cat") != null && mParams.get("cat").isEmpty() == false)
						{
							url = url.substring(0, url.indexOf("?"));
							url += "?";
							url += "cat=" + mParams.get("cat").get(0);
							
							mp = new HashMap<String, String>();
							mp.put("url", url);
							mp.put("eurl", Base64.encode(url.getBytes("UTF-8")));
						}
					}				
				}			
				else if(url.contains("_catalog/product.jsp") || url.contains("_prodcatalog/product.jsp"))
				{
					Logger.debug("process.jsp","Its a detail screen url");
					if(url.indexOf("?") > -1)
					{
						java.util.Map<String, java.util.List<String>> mParams = getQueryParams(url);
						if(mParams != null && mParams.get("id") != null && mParams.get("id").isEmpty() == false)
						{
							url = url.substring(0, url.indexOf("?"));
							url += "?";
							url += "id=" + mParams.get("id").get(0);
							
							mp = new HashMap<String, String>();
							mp.put("url", url);
							mp.put("eurl", Base64.encode(url.getBytes("UTF-8")));
						}
					}
				}			
			}
			
			return mp;
		}
		catch(Exception e)
		{
			Logger.error("process.jsp","Error in fixOldFormatUrls");
			e.printStackTrace();
			return null;
		}
	}	
	
	java.util.Map<String, java.util.List<String>> getQueryParams(String url)
	{
		url = parseNull(url);
		if(url.length() == 0 ) return null;
		
		if(url.indexOf("?") < 0 ) return null;
		
		java.util.Map<String, java.util.List<String>> mParams = null;
		
		String u2 = url.substring(url.indexOf("?"));
			
		if(u2.trim().length() > 1)//u2 will always have ? in it so minimum length of u2 is 1
		{
			mParams = new java.util.HashMap<String, java.util.List<String>>();
			
			u2 = u2.substring(1);//first character is always ?

			String[] ps = u2.split("&");
			u2 = "";
			for(int i=0; i<ps.length; i++)
			{
				if(i > 0) u2 += "&";
				if(ps[i].indexOf("=") < 0) u2 += ps[i];
				else
				{
					String _pr = ps[i].substring(0, ps[i].indexOf("="));
					String _prv = "";
					if(ps[i].indexOf("=") == (ps[i].length()-1)) _prv = "";
					else _prv = ps[i].substring(ps[i].indexOf("=") + 1);

					if(mParams.get(_pr) == null) mParams.put(_pr, new java.util.ArrayList<String>());					
					mParams.get(_pr).add(_prv);
				}
			}
			
			return mParams;
		}
		else return null;
	}	
	String getImageFinalUrl(String _absurl, String _nurl)
	{
		_nurl = parseNull(_nurl);
		_absurl = parseNull(_absurl);
		
		String _temp = "";
		if(_absurl.indexOf("?") > -1)
		{
			_temp = parseNull(_absurl.substring(_absurl.lastIndexOf("?")));
		}	

		if(_temp.length() > 0 && !_nurl.contains(_temp)) 
		{
			_nurl = _nurl + _temp;
		}
		return _nurl;
	}	
	String appendKeywords(String kw, String s)
	{
		if(parseNull(s).length() == 0 ) return kw;
		if(parseNull(kw).length() > 0) kw += ", ";
		kw += parseNull(s);
		return kw;
	}
	class ResourcePath
	{
		String path = "";
		String file = "";
	}
	
	/*
	* This function will be used to know which of resources are from local repository
	* and we are not suppose to cache those. All resources from that path will be 
	* copied to a specific folder at time of building cache
	*/
	boolean isLocalResource(String url)
	{				
		return com.etn.asimina.util.PortalHelper.isLocalResource(url);
	}
	
	/*
	* This function will be used to know which of resources are from local repository
	* and we are not suppose to cache those. All resources from that path will be 
	* copied to a specific folder at time of building cache
	*/
	boolean isLocalAsset(String url)
	{		
		return com.etn.asimina.util.PortalHelper.isLocalAsset(url);
	}
	
	boolean ignoreRelativeUrl(String[] ignoreRelUrls, String url)
	{
		return com.etn.asimina.util.PortalHelper.ignoreRelativeUrl(ignoreRelUrls, url);
	}

	String appendToTitle(String t, String ws)
	{
		t = parseNull(t);
		ws = parseNull(ws);
		if(t.length() == 0 && ws.length() == 0) return "";
		if(t.length() > 0 && ws.length() == 0) return t;
		if(t.length() == 0 && ws.length() > 0) return ws;

		if(ascii7(t).toLowerCase().indexOf(ascii7(ws).toLowerCase()) > -1) return t;	
		return t +  " | " + ws;
	}

	String parseNull(Object o) 
	{
		if( o == null )
			return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase()))
			return("");
		else
			return(s.trim());
	}

	class Resource
	{
		String url;
		int httpcode = 0;
		boolean istimeout = false;

		@Override
		public boolean equals(Object obj) {
			if (obj == null) {
				return false;
			}
			if (getClass() != obj.getClass()) {
				return false;
			}
			final Resource other = (Resource) obj;
			if ((this.url == null) ? (other.url != null) : !this.url.equals(other.url)) {
				return false;
			}
			if (this.httpcode != other.httpcode) {
				return false;
			}
			if (this.istimeout != other.istimeout) {
				return false;
			}
			return true;
		}

		@Override
		public int hashCode() {
			int hash = 7;
			hash = 19 * hash + (this.url != null ? this.url.hashCode() : 0);
			hash = 19 * hash + this.httpcode;
			hash = 19 * hash + (this.istimeout ? 1 : 0);
			return hash;
		}
	}

	String processJsFile(String input, String mainurl, String menuid)
	{
		//for local content do nothing and return
		if(mainurl.startsWith("http://127.0.0.1") || mainurl.startsWith("http://localhost")) return input;
		
		//process all window.location
	       Pattern urlpattern = Pattern.compile("window.location\\s*\\=\\s*(['\"]?+)(.)*?([\\;])");
        	Matcher m = urlpattern.matcher(input);
		List<String> windowlocations = new ArrayList<String>();
        	while (m.find()) {
       	     	String cssurl = m.group();
			if(!windowlocations.contains(cssurl)) windowlocations.add(cssurl);
		}
		for(String u : windowlocations)
		{
			if(u.indexOf("=") < 0) continue;
			String u1 = u.substring(u.indexOf("=") + 1).trim();
			String endingchar = "";
			if(u1.endsWith(";")) 
			{
				endingchar = ";";
				u1 = u1.substring(0, u1.length() - 1);
			}
			String newurl = " window.location = parseUrl("+u1+")" + endingchar;
			input = input.replace(u, newurl); 
		}

		//process all window.location
	       urlpattern = Pattern.compile("=\\s*getContextPath()\\s*\\s*(.)*\\s*");
        	m = urlpattern.matcher(input);
		windowlocations.clear();
        	while (m.find()) {
       	     	String cssurl = m.group();
			if(!windowlocations.contains(cssurl)) windowlocations.add(cssurl);
		}
		for(String u : windowlocations)
		{
			if(u.indexOf("=") < 0) continue;
			String u1 = u.substring(u.indexOf("=") + 1).trim();
			String endingchar = "";
			if(u1.indexOf(";") > -1) 
			{
				endingchar = ";";
				u1 = u1.substring(0, u1.indexOf(";"));	
				u1 = u1.replace("getContextPath()","\"\"");
			}
			String newurl = " = parseUrl("+u1+")" + endingchar;
			input = input.replace(u, newurl); 
		}

		urlpattern = Pattern.compile("\\s*window.location.href\\s*\\=\\s*(.)*?([\\;])");
        	m = urlpattern.matcher(input);
		windowlocations.clear();
        	while (m.find()) {
       	     	String cssurl = m.group() + " ";//space added to avoid stringindexoutofbounds exception
			if(cssurl.indexOf(";") > -1) cssurl= (cssurl.substring(0, cssurl.indexOf(";") +1)).trim();
			cssurl = cssurl.trim();
			//means its inside an if condition
			if(cssurl.startsWith("=")) continue;
			if(!windowlocations.contains(cssurl)) windowlocations.add(cssurl);
		}
		for(String u : windowlocations)
		{
			if(u.indexOf("=") < 0) continue;
			String u1 = u.substring(u.indexOf("=") + 1).trim();
			String endingchar = "";
			if(u1.endsWith(";")) 
			{
				endingchar = ";";
				u1 = u1.substring(0, u1.length() - 1);
			}
			String newurl = " window.location.href = parseUrl("+u1+")" + endingchar;
			input = input.replace(u, newurl); 
		}

		urlpattern = Pattern.compile("\\s*=\\s*window.location.href");
        	m = urlpattern.matcher(input);
		windowlocations.clear();
        	while (m.find()) {
       	     	String cssurl = m.group();
			if(!windowlocations.contains(cssurl)) windowlocations.add(cssurl);
		}
		for(String u : windowlocations)
		{
			input = input.replace(u, " = parseUrl(Base64.decode(______dcurl)) "); 
		}

		urlpattern = Pattern.compile("\\s*document.location.href\\s*\\=\\s*(.)*?([\\;])");
        	m = urlpattern.matcher(input);
		windowlocations.clear();
        	while (m.find()) {
       	     	String cssurl = m.group();
			cssurl = cssurl.trim();
			//means its inside an if condition
			if(cssurl.startsWith("=")) continue;
			if(!windowlocations.contains(cssurl.trim())) windowlocations.add(cssurl.trim());
		}
		for(String u : windowlocations)
		{
			if(u.indexOf("=") < 0) continue;
			String u1 = u.substring(u.indexOf("=") + 1).trim();
			String endingchar = "";
			if(u1.endsWith(";")) 
			{
				endingchar = ";";
				u1 = u1.substring(0, u1.length() - 1);
			}
			String newurl = " document.location.href = parseUrl("+u1+")" + endingchar;
			input = input.replace(u, newurl); 
		}
		urlpattern = Pattern.compile("\\s*([.])?location.href\\s*\\=\\s*(.)*?([\\;])");
        	m = urlpattern.matcher(input);
		windowlocations.clear();
        	while (m.find()) {
       	     	String cssurl = m.group();
			cssurl = cssurl.trim();
			//means its inside an if condition
			if(cssurl.startsWith("=")) continue;
			if(!windowlocations.contains(cssurl.trim())) windowlocations.add(cssurl.trim());
		}
		for(String u : windowlocations)
		{
			if(u.indexOf("=") < 0) continue;
			String u1 = u.substring(u.indexOf("=") + 1).trim();
			String endingchar = "";
			if(u1.endsWith(";")) 
			{
				endingchar = ";";
				u1 = u1.substring(0, u1.length() - 1);
			}
			String newurl = " location.href = parseUrl("+u1+")" + endingchar;
			input = input.replace(u, newurl); 
		}

		urlpattern = Pattern.compile("<script\\s*src=(.*?)\\s*/script>");
		m = urlpattern.matcher(input);
		while (m.find()) 
		{
			String cc = m.group();
			String ch = "'";
			if(cc.indexOf("\"") > -1) ch = "\"";
			String cc1 = cc.substring(0, cc.indexOf(ch));               
			String curl = cc.substring(cc.indexOf(ch) + 1);
			String cc2 = curl.substring(curl.indexOf(ch)+1);
			curl = curl.substring(0, curl.indexOf(ch));
			try {
				curl = getAbsoluteUrl(mainurl, curl);
				curl = GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(curl.getBytes("UTF-8"));
			} catch(Exception e) {
				e.printStackTrace();
			}
			String fcc = cc1 + ch + curl + ch + cc2;
			input = input.replace(cc, fcc);
		}

		return input;
	}
	String fixAjaxUrls(String mainurl, String domain, String contents)
	{
		return fixAjaxUrls(mainurl, domain, contents, false);
	}

	String fixAjaxUrls(String mainurl, String domain, String contents, boolean checkjquery)
	{ 		
		//for local content do nothing and return
		if(mainurl.startsWith("http://127.0.0.1") || mainurl.startsWith("http://localhost")) return contents;
	
		//here we checking if the file contains .ajaxSettings then its a jquery main file and we will not replace ajax urls in it as we are replacing the place where its called from
		if(checkjquery && (contents.contains(".ajaxSettings") || contents.contains("* Bootstrap v") || contents.contains("/*! jQuery UI") || contents.contains("/*! jQuery v") || contents.contains("http://www.idangero.us/swiper") || contents.contains("(http://boosted.orange.com)")))
		{
			Logger.debug("process.jsp","============================= its a jquery/swiper/boosted file so ignore it");
			return contents;
		}

		List<String> listurls = new ArrayList<String>();

//		Pattern urlpattern = Pattern.compile("url\\s*\\:\\s*['\"](.*?)['\"]");
		Pattern urlpattern = Pattern.compile("(?i)(.)*url\\s*\\:\\s*(.)*");
		Matcher m = urlpattern.matcher(contents);
		while (m.find()) {
			boolean isVariable = false;
			String cssurl = m.group().trim();	
			//another check to make sure any variable named abc_url is not changed
			String st = cssurl.substring(0, cssurl.indexOf(":"));
			st = st.trim();
			if(st.startsWith(",") || st.startsWith(";")) st = st.substring(1);
			if(!st.toLowerCase().equals("url")) continue;

			if(cssurl.startsWith(",") || cssurl.startsWith(";")) cssurl = cssurl.substring(1);
			if(cssurl.indexOf(",") > -1) cssurl = cssurl.substring(0, cssurl.indexOf(","));
			if(cssurl.indexOf(";") > -1) cssurl = cssurl.substring(0, cssurl.indexOf(";"));

			if(!listurls.contains(cssurl)) listurls.add(cssurl);		
		}
		for(String u : listurls)
		{
			String actualurl = u;
			actualurl = (actualurl.substring(actualurl.indexOf(":") + 1)).trim();		
			if(actualurl.length() == 0) continue;

/*			if(actualurl.indexOf("'") > -1 || actualurl.indexOf("\"") > -1) //url is hardcoded string			
			{
				actualurl = (actualurl.replace("'","").replace("\"","'")).trim();
				if(actualurl.length() > 0) 
					contents = contents.replace(u, " url : parseUrlForAjax("+actualurl+") ");
			}
			else //its a variable*/
			contents = contents.replace(u, " url : parseUrlForAjax("+actualurl+") ");
		}		

		//$.post or jQuery.post
		listurls.clear();
		urlpattern = Pattern.compile("\\.post\\s*\\(\\s*(.)*");
		m = urlpattern.matcher(contents);
		while (m.find()) {
			boolean isVariable = false;
			String cssurl = m.group().trim();	
			if(cssurl.indexOf(",") > -1) cssurl = cssurl.substring(0, cssurl.indexOf(","));
			if(!listurls.contains(cssurl)) listurls.add(cssurl);		
		}

		for(String u : listurls)
		{
			String actualurl = u;
			actualurl = (actualurl.substring(actualurl.indexOf("(") + 1)).trim();		
			if(actualurl.length() == 0) continue;

			if(actualurl.indexOf("'") > -1 || actualurl.indexOf("\"") > -1) //url is hardcoded string			
				contents = contents.replace(u, ".post(parseUrlForAjax('"+(actualurl.replace("'","").replace("\"","")).trim()+"') ");
			else //its a variable
				contents = contents.replace(u, ".post(parseUrlForAjax("+actualurl+") ");

		}		

		return contents;
	}	

	boolean isInRules(com.etn.beans.Contexte Etn, String menuid, String href, String menuVersion, String siteid)
	{
		return com.etn.asimina.util.PortalHelper.isInRules(Etn, menuid, href, menuVersion, siteid);
	}

	String getLocalUrl(com.etn.beans.Contexte Etn, String domain, String url, String currentMenuPath)
	{
		ResourcePath rp = getResourcePath(Etn, url, false);		
		String _localpath = rp.path;
		String _localfile = rp.file;

		return currentMenuPath + getFolderId(Etn, domain) + _localpath + _localfile;
	}
	String fixUrls(com.etn.beans.Contexte Etn, String mainurl, String domain, String localbaseurl, String contents, List<Resource> resources, List<String> rextensions, String menuid)
	{
		return fixUrls(Etn, mainurl, domain, localbaseurl, contents, resources, rextensions, false, menuid);
	}
	boolean isSameDomain(String domain, String url)
	{
		boolean same = false;
		String domain1 = getDomain(url);

		if(domain1.equalsIgnoreCase(domain)) same = true;
		else
		{
			domain = domain + " ";
			if(domain.indexOf(".") > 0) domain = (domain.substring(domain.indexOf(".") + 1)).trim();
			if(domain1.toLowerCase().contains(domain.toLowerCase())) same = true;
		}
		return same;
	}
	//for javascript code we have case where an image name is in an if condition which means its not a valid image url so for javascript code
	//we need to know the http response code in any case to decide whether it was a valid img url or not. If its not a valid img url means
	//we will not fix the image path in that particular script code. So in this case if we have a timeout exception we will not cache the file
	//as we want http code. In all other case if there is a timeout we just insert into failed_urls to be tried again later which we cannot do
	//in case of javascript as decision of changing img url in javascript depends on http response code
	String fixUrls(com.etn.beans.Contexte Etn, String mainurl, String domain, String localbaseurl, String contents, List<Resource> resources, List<String> rextensions, boolean isscript, String menuid)
	{
		for(Resource r : resources)
		{
			//its a script code manipulation and for the resource we had timeout so we cannot decide whether it was a valid img url or it was part of variable
			//so we skip it
			//also if its a 404 means it was not a valid resource url so we will not change it in script code
			if(isscript && (r.httpcode == 404 || r.istimeout)) continue;
			String _absurl = "";
			try {
				_absurl = getAbsoluteUrl(mainurl, r.url);
			} 
			catch(java.net.MalformedURLException ex) { Logger.error("process.jsp","fixUrls :: Error get absolute url : " + r.url); continue; }
			catch(Exception ex) { ex.printStackTrace(); }

			String ext = "";
			String _lf = getLocalFilename(_absurl);
			if(_lf.indexOf(".") > -1) ext = _lf.substring(_lf.lastIndexOf("."));
			if(ext.indexOf("?") > -1) ext = ext.substring(0, ext.indexOf("?"));
			if(ext.indexOf("#") > -1) ext = ext.substring(0, ext.indexOf("#"));
			if(rextensions.contains(ext.toLowerCase()))
			{
				//here have to call getUnfixedLocalPath so that %20 is not replaced in url otherwise
				//in some case there is url with %20 and sometimes same url with space instead of %20
				//so a fixed path will replace urls twice in the file
				ResourcePath rp = getResourcePath(Etn, _absurl, true);
				String replaceurl = r.url;
				if(replaceurl.indexOf("?") > -1) replaceurl = replaceurl.substring(0, replaceurl.indexOf("?"));
				contents = contents.replace(replaceurl, localbaseurl + rp.path + rp.file);
			}
			else
			{
				try
				{
					contents = contents.replace(r.url, GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(_absurl.getBytes("UTF-8")));
				}
				catch (Exception ex) { ex.printStackTrace(); }
			}
		}
		return contents;
	}
	void downloadUrls(com.etn.beans.Contexte Etn, String mainurl, String mainencodedurl, String domain, String basedir, List<Resource> resources, HttpServletRequest request, List<String> rextensions, List<String> failedurls)
	{
		downloadUrls(Etn, mainurl, mainencodedurl, domain, basedir, resources, request, rextensions, failedurls, false);
	}
	//for javascript code we have case where an image name is in an if condition which means its not a valid image url so for javascript code
	//we need to know the http response code in any case to decide whether it was a valid img url or not. If its not a valid img url means
	//we will not fix the image path in that particular script code. So in this case if we have a timeout exception we will not cache the file
	//as we want http code. In all other case if there is a timeout we just insert into failed_urls to be tried again later which we cannot do
	//in case of javascript as decision of changing img url in javascript depends on http response code
	void downloadUrls(com.etn.beans.Contexte Etn, String mainurl, String mainencodedurl, String domain, String basedir, List<Resource> resources, HttpServletRequest request, List<String> rextensions, List<String> failedurls, boolean settimeout)
	{
		for(Resource r : resources)
		{
			String _absurl = "";
			try {
				_absurl = getAbsoluteUrl(mainurl, r.url);
			} 
			catch(java.net.MalformedURLException ex) { Logger.error("process.jsp","downloadUrls :: Error get absolute url : " + r.url); continue; }
			catch(Exception ex) { ex.printStackTrace(); continue; }
//			if(isSameDomain(domain, _absurl))
//			{			
				String ext = "";
				String _lf = getLocalFilename(_absurl);
				if(_lf.indexOf(".") > -1) ext = _lf.substring(_lf.lastIndexOf("."));
				if(ext.indexOf("?") > -1) ext = ext.substring(0, ext.indexOf("?"));
				if(ext.indexOf("#") > -1) ext = ext.substring(0, ext.indexOf("#"));
				if(rextensions.contains(ext.toLowerCase()))
				{
					try 
					{				
						int respcode = downloadResourceFromUrl(Etn, domain, _absurl, basedir, request);
						r.httpcode = respcode;
					}
					catch(org.apache.http.conn.ConnectTimeoutException ex)
					{
						if(settimeout) r.istimeout = true;
						else failedurls.add(_absurl); // Etn.executeCmd("insert into failed_urls (domain, encoded_url, failed_url) values ("+escape.cote(domain)+","+escape.cote(mainencodedurl)+", "+escape.cote(_absurl)+") ");
						ex.printStackTrace();
					}
					catch(Exception ex) 
					{
						failedurls.add(_absurl); // Etn.executeCmd("insert into failed_urls (domain, encoded_url, failed_url) values ("+escape.cote(domain)+","+escape.cote(mainencodedurl)+", "+escape.cote(_absurl)+") ");
						ex.printStackTrace();
					}					
				}
//			}
		}
	}
	List<Resource> getUrlsFromStyling(String res)
	{
		List<Resource> listurls = new ArrayList<Resource>();
		String localResourcesUrl = parseNull(GlobalParm.getParm("COMMON_RESOURCES_URL"));

		Pattern urlpattern = Pattern.compile("(?i)url\\s*\\(\\s*(['\"]?+)(.*?)\\1\\s*\\)");
		Matcher m = urlpattern.matcher(res);
		while (m.find()) {
			String cssurl = m.group();
			cssurl = cssurl.substring(cssurl.indexOf("(") + 1);
			cssurl = cssurl.substring(0, cssurl.lastIndexOf(")"));
			cssurl = cssurl.replace("\"","").replace("'","").trim();

			if(cssurl.indexOf("?") > -1) cssurl = cssurl.substring(0, cssurl.indexOf("?"));
			Resource r = new Resource();
			r.url = cssurl;
			if(!listurls.contains(r) && !cssurl.toLowerCase().contains("data:image") 
				&& !r.url.startsWith("#") && parseNull(r.url).length() > 0 && !r.url.startsWith(localResourcesUrl)) listurls.add(r);
		}

		return listurls;
	}
	List<Resource> getResourceUrlsFromString(String res)
	{
		List<Resource> listurls = new ArrayList<Resource>();

	       Pattern urlpattern = Pattern.compile("[A-Za-z0-9\\/\\-\\_\\.\\$\\%\\:]*(\\.(?i)(htc|jpg|png|gif|bmp|jpeg|tiff|cgm|ief))");
		Matcher m = urlpattern.matcher(res);
		while (m.find()) {
			String cssurl = m.group();
			cssurl = cssurl.replace("\"","").replace("'","");
			String c1 = cssurl.substring(0, cssurl.lastIndexOf(".")).trim();
			Resource r = new Resource();
			r.url = cssurl;			
			if(c1.trim().length() > 0 && !listurls.contains(r) && !cssurl.toLowerCase().contains("data:image")) listurls.add(r);
		}

		return listurls;
	}
	String getNewUrl(String absurl) throws Exception
	{
		String anchor = "";
		if(absurl.indexOf("#") > -1) anchor = absurl.substring(absurl.indexOf("#"));
		absurl = Base64.encode(absurl.getBytes("UTF-8")) + anchor;
		return absurl;
	}
	
	ResourcePath getResourcePath(com.etn.beans.Contexte Etn, String url, boolean unfixed)
	{
		ResourcePath rp = new ResourcePath();
		String localpath = "";
		String localfile = "";
		if(unfixed) 
		{
			localpath = getUnfixedLocalPath(Etn, url);
			localfile = getUnfixedLocalFilename(url);
		}
		else
		{
			localpath = getLocalPath(Etn, url);
			localfile = getLocalFilename(url);
		}

		if(url.indexOf("?") > -1) 
		{
			String u1 = url.substring(0, url.indexOf("?"));
			String u2 = url.substring(url.indexOf("?")).trim();
			boolean isImageUrl = false;
			if(u1.indexOf("/") > -1) 
			{
				String temp = u1.substring(u1.lastIndexOf("/"));
				if(temp.indexOf(".") > -1)
				{
					String ext = (temp.substring(temp.lastIndexOf("."))).toLowerCase();
					if(ext.equals(".png") || ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".gif") ||
					ext.equals(".tif") ||  ext.equals(".tiff") ||  ext.equals(".jfif") ||  ext.equals(".bmp") ||  ext.equals(".exif") 
					||  ext.equals(".svg") ||  ext.equals(".ppm")||  ext.equals(".pgm")  ||  ext.equals(".pbm") ||  ext.equals(".pnm"))
					{
						isImageUrl = true;
					}
				}
			}
			
			//assumption is if there is a ? in url means its not directly a resource but some service which serves the url
			//this is normally case for images			
			if(!isImageUrl)
			{
				u1 = url.substring(0, url.indexOf("?")) + "/";
				localpath = getLocalPath(Etn, u1);
				u2 = url.substring(url.indexOf("?") + 1).replace("&","").replace("%","").replace(":","").replace("/","").trim();
				localfile = getLocalFilename(u2);
				if(unfixed) 
				{
					localpath = getUnfixedLocalPath(Etn, u1);
					localfile = getUnfixedLocalFilename(u2);
				}
				else
				{
					localpath = getLocalPath(Etn, u1);
					localfile = getLocalFilename(u2);
				}
			}
		}
		rp.path = localpath;
		rp.file = localfile;
		rp.file = ascii7(rp.file);
		if(rp.file.trim().length() == 0) rp.file = "_aa";//some dummy file name in case no file name can be generated
		return rp;
	}

	//resources are images/swf/pdfs etc
	int downloadResourceFromUrl(com.etn.beans.Contexte Etn, String domain, String url, String basedir, HttpServletRequest request) throws org.apache.http.conn.ConnectTimeoutException, Exception
	{
		return downloadResourceFromUrl(Etn, domain, url, basedir, request, false);
	}
	int downloadResourceFromUrl(com.etn.beans.Contexte Etn, String domain, String url, String basedir, HttpServletRequest request, boolean nametolowercase) throws org.apache.http.conn.ConnectTimeoutException, Exception
	{
		ResourcePath rp = getResourcePath(Etn, url, false);
		String localpath = rp.path;
		String localfile = rp.file;
		if(nametolowercase) localfile = localfile.toLowerCase();		
		int respcode = 0;
//		File f = new File(basedir + localpath + localfile);
//		if(!f.exists() || f.length() == 0)
//		{			
			try
			{
				respcode = downloadResource(url, basedir, localpath, localfile, request);
			}
			catch(org.apache.http.conn.ConnectTimeoutException e)
			{
				throw e;
			}
			catch(Exception e)
			{
				throw e;
			}
//		}
		//returns the local server url
		return respcode;
	}	
	boolean getTimeout (boolean origTimeout, List<Resource> rs)
	{
		if(origTimeout) return true;
		for(Resource r : rs)
		{
			if(r.istimeout) return true;
		}
		return false;
	}

	List<String> getAllMenuPaths(com.etn.beans.Contexte Etn)
	{
		Logger.debug("process.jsp","Fetching all menus path");
		java.util.List<String> menupaths = new java.util.ArrayList<String>();
		Set rs = Etn.execute("select id from site_menus");
		while(rs.next())
		{
			menupaths.add(getMenuPath(Etn, rs.value("id")));
		}
		return menupaths;
	}

%><%
	//this list contains extensions of images/pdf etc which we will download when found rather then routing through process.jsp
	//this list is case sensitive ... always add lower case extensions to this
	final List<String> rextensions = new ArrayList<String>();
	rextensions.add(".jpg");
	rextensions.add(".cgm");
	rextensions.add(".jpeg");
	rextensions.add(".bmp");
	rextensions.add(".png");
	rextensions.add(".gif");
	rextensions.add(".tiff");
	rextensions.add(".pdf");
	rextensions.add(".doc");
	rextensions.add(".xls");
	rextensions.add(".xlsx");
	rextensions.add(".docx");
	rextensions.add(".csv");
	rextensions.add(".txt");
	rextensions.add(".ico"); 
	rextensions.add(".exe"); 
	rextensions.add(".ppt");
	rextensions.add(".pptx");
	rextensions.add(".ief");
	rextensions.add(".svg");
	rextensions.add(".djv");
	rextensions.add(".djvu");
	rextensions.add(".wbmp");
	rextensions.add(".ras");
	rextensions.add(".pnm");
	rextensions.add(".pbm");
	rextensions.add(".pgm");
	rextensions.add(".ppm");
	rextensions.add(".rgb");
	rextensions.add(".au");
	rextensions.add(".snd");
	rextensions.add(".kar");
	rextensions.add(".midi");
	rextensions.add(".mid");
	rextensions.add(".mp3");
	rextensions.add(".mp2");
	rextensions.add(".mp1");
	rextensions.add(".mpga");
	rextensions.add(".aifc");
	rextensions.add(".aif");
	rextensions.add(".aiff");
	rextensions.add(".m3u");
	rextensions.add(".ra");
	rextensions.add(".ram");
	rextensions.add(".wav");
	rextensions.add(".rtf");
	rextensions.add(".rtx");
	rextensions.add(".mov");
	rextensions.add(".qt");
	rextensions.add(".mpeg");
	rextensions.add(".mpg");
	rextensions.add(".mpe");
	rextensions.add(".abs");
	rextensions.add(".m4u");
	rextensions.add(".mxu");
	rextensions.add(".avi");
	rextensions.add(".wmv");
	rextensions.add(".movie");
	rextensions.add(".zip");
	rextensions.add(".gzip");
	rextensions.add(".tgz");
	rextensions.add(".swf");
	rextensions.add(".flv");
	rextensions.add(".ttf");
	rextensions.add(".eot");
	rextensions.add(".woff");
	rextensions.add(".woff2");
	rextensions.add(".svg");
	rextensions.add(".otf");
	rextensions.add(".m4v");
	rextensions.add(".webp");
	
	Etn.setSeparateur(2, '\001', '\002');

	String prodlogtxt = " ";
	boolean bIsProd = false;
	if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV"))) 
	{
		prodlogtxt = " PROD ";
		bIsProd = true;
	}

	//this flag tells if the publisher is calling the urls then we have to use the header/footer html which has
	//process.jsp urls as its refreshing cache. Otherwise by default for calls from client's browser we use header/footer html_1 which has .html links in it (these will be called for dynamic urls)
	String headerhtmlcol = "header_html_1";
	String footerhtmlcol = "footer_html_1";
	String internalcall = parseNull(request.getParameter("___rf"));
	boolean binternalcall = false;
	if("1".equals(internalcall))
	{
		binternalcall = true;
	}

	if(binternalcall || !bIsProd)
	{
		headerhtmlcol = "header_html";
		footerhtmlcol = "footer_html";
	}

	String sitemapcall = parseNull(request.getParameter("___stm"));
	boolean bsitemapcall = false;
	if("1".equals(sitemapcall))
	{
		bsitemapcall = true;
	}


	Logger.debug("process.jsp","*******************************************************************");
	Logger.debug("process.jsp"," header col : " + headerhtmlcol + "  footer col : " + footerhtmlcol);
	Logger.debug("process.jsp","*******************************************************************");

	String ___isErr = parseNull(request.getParameter("___isErr"));

	String eurl = parseNull(request.getParameter("___mu"));
	String noscript = parseNull(request.getParameter("___noscript"));

	String _mainurl = parseNull(request.getParameter("___mainurl"));
	String _gotourl = parseNull(request.getParameter("___goto"));

	String ___isajax = parseNull(request.getParameter("___isajax"));

	String menuid = parseNull(request.getParameter("___mid"));
	if(menuid.length() == 0 || !org.apache.commons.codec.binary.Base64.isArrayByteBase64(menuid.getBytes("UTF-8")) )
	{
		Logger.error("process.jsp",prodlogtxt+"::Invalid ___mid provided");
		response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND, "Page not found");
		return;
	}


//	Logger.debug("process.jsp","-------- checking b64 ----------------------------- " + org.apache.commons.codec.binary.Base64.isArrayByteBase64(eurl.getBytes("UTF-8")));
	Logger.debug("process.jsp","****************************************************** " + eurl); 

	if(eurl.length() == 0 && (_mainurl.length() == 0 || _gotourl.length() == 0) )
	{
		Logger.error("process.jsp",prodlogtxt+"::No encoded URLs provided");
		response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND, "Page not found");
		return;
	}

	if(eurl.length() > 0)
	{
		if( !org.apache.commons.codec.binary.Base64.isArrayByteBase64(eurl.getBytes("UTF-8")) )
		{
			Logger.error("process.jsp",prodlogtxt+"::Invalid ___mu provided");
			response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND, "Page not found");
			return;
		}
	}
	else
	{
		if(_mainurl.length() > 0 && !org.apache.commons.codec.binary.Base64.isArrayByteBase64(_mainurl.getBytes("UTF-8")) )
		{
			Logger.error("process.jsp",prodlogtxt+"::Invalid ___mainurl provided");
			response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND, "Page not found");
			return;
		}
		if(_gotourl.length() > 0 && !org.apache.commons.codec.binary.Base64.isArrayByteBase64(_gotourl.getBytes("UTF-8")) )
		{
			Logger.error("process.jsp",prodlogtxt+"::Invalid ___goto provided");
			response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND, "Page not found");
			return;
		}
	}


	Logger.info("process.jsp","---------------------"+prodlogtxt+"PORTAL : process request at "+com.etn.util.ItsDate.getWith(System.currentTimeMillis(),true)+" --");
	Logger.info("process.jsp","----"+prodlogtxt+"session id : " + request.getSession().getId());
	//means we r getting mainurl and gotourl
	if(eurl == null || eurl.trim().length() == 0)
	{
		String anyparams = "";
		try
		{
			if(_gotourl.indexOf("?") > -1) 
			{
				anyparams = _gotourl.substring(_gotourl.indexOf("?"));
				_gotourl = _gotourl.substring(0, _gotourl.indexOf("?"));
			}
			_mainurl = new String(java.util.Base64.getDecoder().decode(_mainurl));
			_gotourl = new String(java.util.Base64.getDecoder().decode(_gotourl));
		} 
		catch(Exception e) 
		{ 
			Logger.error("process.jsp","---------------------"+prodlogtxt+" error url : " + _gotourl);
			e.printStackTrace(); 
			response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND, "Page not found");
			return; 
		}
		Logger.info("process.jsp",""+prodlogtxt+"main url : " + _mainurl);
		Logger.info("process.jsp",""+prodlogtxt+"goto url : " + _gotourl);
		String aurl = getAbsoluteUrl(_mainurl, _gotourl);
		eurl = Base64.encode(aurl.getBytes("UTF-8"));
		if(parseNull(anyparams).length() > 0) eurl = eurl + anyparams;

	}

//	Logger.debug("process.jsp","++++++++++  " + menuid);
	if(menuid.length() > 0)
	{
		try
		{
			menuid = new String(java.util.Base64.getDecoder().decode(menuid));
		} 
		catch(Exception e) 
		{ 
			e.printStackTrace(); 
			Logger.error("process.jsp",prodlogtxt+"PORTAL::Invalid menu id"); 
			response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND, "Page not found"); 
			Logger.debug("process.jsp","return");
			return; 
		}

	}  
	
	
	Set __rs23 = Etn.execute("select * from site_menus where is_active = 1 and id = " + escape.cote(menuid));
	if(__rs23.rs.Rows == 0)
	{
		Logger.error("process.jsp",prodlogtxt+"PORTAL::The menu ID passed is no more active"); 
		response.sendError(javax.servlet.http.HttpServletResponse.SC_FORBIDDEN, "accès refusé");
		Logger.debug("process.jsp","return");
		return; 		
	}

	boolean addscript = true;
	if("1".equals(noscript)) addscript = false;
	if(eurl == null || eurl.trim().length() == 0) 
	{
		out.write("No url provided");
		return;
	}

	String url = "";
	try
	{
		String anyparams = "";
		if(eurl.indexOf("?") > -1) 
		{
//			Logger.debug("process.jsp","********************* there are params in encoded url");
			anyparams = eurl.substring(eurl.indexOf("?"));
			eurl = eurl.substring(0, eurl.indexOf("?"));
//			Logger.debug("process.jsp","********************* params " + anyparams);
		}

		url = new String(java.util.Base64.getDecoder().decode(eurl));
		if(parseNull(anyparams).length() > 0) 
		{
			url = url + anyparams;		
			eurl = eurl + anyparams;					
		}
		Logger.info("process.jsp","--"+prodlogtxt+"********************* final " + url);
	}
	catch(Exception e) 
	{ 
		out.write("Invalid url provided");
		Logger.debug("process.jsp","---------------------"+prodlogtxt+" error url : " + eurl);
		e.printStackTrace();		
		response.sendError(javax.servlet.http.HttpServletResponse.SC_NOT_FOUND, "Page not found");
		return;
	}
	//first thing after getting the url is to check if its old format internal url we have to fix it
	Map<String, String> fixedUrls = fixOldFormatUrls(url);
	if(fixedUrls != null)
	{
		Logger.debug("URL before fix : " + url);
		Logger.debug("eURL before fix : " + eurl);
		if(fixedUrls.get("url") != null) url = parseNull(fixedUrls.get("url"));
		if(fixedUrls.get("eurl") != null) eurl = parseNull(fixedUrls.get("eurl"));
		Logger.debug("URL after fix  : " + url);
		Logger.debug("eURL after fix  : " + eurl);
	}

	String _a = getLocalFilename(url);

	String resourceFileExtension = "";
	if(_a.indexOf(".") > -1) resourceFileExtension = _a.substring(_a.lastIndexOf("."));
	Logger.debug("process.jsp","^^^^^^^^^^^^^^^^^^^^^^ resourceFileExtension : " + resourceFileExtension);

	String urlfileid = "";
	String cached = "0";
	String origContentType = "";
	String urldb = "";
	boolean redirect = false;	

	boolean isOrangeApp = "1".equals(GlobalParm.getParm("IS_ORANGE_APP"));
	boolean includeCustomCss = "1".equals(GlobalParm.getParm("INCLUDE_CUSTOM_CSS"));

	//if its a loop we redirect to looping url rather making cache call that url 
	if(aLoopingUrl(url))
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		response.setHeader("X-Frame-Options","deny");
		response.setHeader("Location", getUrlForLoop(url));
		return;
	}


	//check page compatibility .. if IE browsers other than IE8 or less
	boolean iscompatibile = isCompatible(request, url);
	if(!iscompatibile)
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
		response.setHeader("Location", com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"noncompatible.html?lg="+getDefaultLanguage(Etn));
		return;
	}	
	
	String cachedFilePath = "";
	String cachedFileName = "";
	String cachedFileUrl = "";
	String dlPageType = "";
	String dlSubLevel1 = "";	
	String dlSubLevel2 = "";	
	String sub_page_type_level3 = "";

	//we are checking for encoded url and menu id in cached pages. seconnd select is if no rows are found then we check for menu_id = 0, this will
	//always be the case for css/js files as for those we always save in table menu id = 0. But for other urls there will always be 
	//the menu id in table. Order by is important to load most prefered file
	String _q = "select cp.file_url, cp.file_path, c.*, m.site_id as siteid, s.name as sitename, c.menu_id as mid, '-10' as pref from cached_pages c, site_menus m, sites s, cached_pages_path cp where cp.id = c.id and m.site_id = s.id and m.is_active = 1 and m.id = c.menu_id and c.menu_id = "+escape.cote(menuid)+" and c.hex_eurl = hex(sha(" + escape.cote(eurl) + ")) ";
	_q += " order by case pref when '' then 999999 else pref end, mid ";

	Set rs = Etn.execute(_q);
	if(rs.next()) 
	{
		Logger.debug("process.jsp","-----"+prodlogtxt+"URL : " + rs.value("url") + " menuid : " + rs.value("mid") + " cached : " + rs.value("cached") + " filename : " + parseNull(rs.value("filename")));		
		cached = rs.value("cached");
		urlfileid = rs.value("id");
		if(parseNull(rs.value("filename")).length() > 0) 
		{
			redirect = true;
			cachedFileName = parseNull(rs.value("filename"));
			cachedFileUrl = parseNull(rs.value("file_url"));
		}
		else
		{
			cachedFileName = urlfileid;
		}
		if(parseNull(rs.value("res_file_extension")).length() > 0) cachedFileName += parseNull(rs.value("res_file_extension"));

		//this is done to fix the issue where a page was initially crawled at time of menu publish in which case breadcrumb adds the appropriate data layer
		//but later if that page is scheduled to be refreshed after some time interval with menu publish, then datalayer items were empty as breadcrumb code
		//is not called by publisher in that case. So we fetch these values from db which are set by menu publish and in single page recache datalayer items will be filled
		//as per the values of last publish
		dlPageType = parseNull(rs.value("pagetype"));
		dlSubLevel1 = parseNull(rs.value("sub_level_1"));
		dlSubLevel2 = parseNull(rs.value("sub_level_2"));
		sub_page_type_level3 = parseNull(rs.value("ptitle"));

		cachedFilePath = parseNull(rs.value("file_path"));
		origContentType = rs.value("content_type");
		urldb = rs.value("url");				
		//post method means something new is being sent to server so we cannot show from cache
		if(!request.getMethod().equalsIgnoreCase("GET") && !request.getMethod().equalsIgnoreCase("HEAD")) cached = "0";
	}		

	urlfileid = urlfileid.toLowerCase();
	
	String currentMenuPath = getMenuPath(Etn, menuid);
	String cacheFolder = getMenuCacheFolder(Etn, menuid);

	boolean filefound = true;
	List<String> failedurls = new ArrayList<String>();

	String siteid = "";
	String siteuuid = "";
	String ecommerceEnabled = "";
	String menuVersion = "V1";
	String homepageurl = "";
	String mlang = "";
	String mlanglocale = "";
	String mdirection = "";
	String favicon = "";
	String sitedomain = "";
	String sitename = "";
	String websiteName= "";
	String facebookappid= "";
	String twitteraccount= "";
	String seokeywords = "";
	String seodescr = "";

	boolean issearchadded = false;
	String searchapi = "";
	String searchurl = "";
	String searchcompletionurl = "";
	String searchparams = "";
	String menuuuid = "";
	String usesmartbanner = "";
	String smartbannerposition = "top";//default it will be top always
	String smartbannerreminderdays = "";
	String smartbannerhiddendays = "";
	String showloginbar = "0";
	boolean bShowLoginBar = false;
	boolean bEnableCart = false;
	String snapPixelCode = "";	
	boolean pagesOnlyOpenInIframe = false;
	
	///always here
	Set rscc = Etn.execute("select m.*, s.open_only_in_iframe, s.website_name, s.facebook_app_id, s.twitter_account, s.id as siteid, s.suid as siteuuid, s.name as sitename, s.domain as sitedomain, "+
						" s.enable_ecommerce, s.snap_pixel_code, s.site_auth_enabled, s.gtm_code, s.country_code, s.datalayer_domain, s.datalayer_brand, s.datalayer_market, "+
						" l.langue_code, l.og_local, l.direction "+
						" from sites s, site_menus m, language l where m.lang = l.langue_code and s.id = m.site_id and m.id = "+escape.cote(menuid));
	if(rscc.next())
	{
		pagesOnlyOpenInIframe = "1".equals(rscc.value("open_only_in_iframe"));
		
		siteid = rscc.value("siteid");
		siteuuid = rscc.value("siteuuid");
		ecommerceEnabled = parseNull(rscc.value("enable_ecommerce"));
		if(ecommerceEnabled.length() == 0) ecommerceEnabled = "0";
		menuVersion = rscc.value("menu_version");
		homepageurl = rscc.value("homepage_url");//for v2 menus homepage_url and prod_homepage_url will always be same 

		mlang = parseNull(rscc.value("langue_code"));
		mlanglocale = parseNull(rscc.value("og_local"));
		mdirection = parseNull(rscc.value("direction"));
		
		favicon = parseNull(rscc.value("favicon"));
		sitedomain = parseNull(rscc.value("sitedomain"));
		sitename = parseNull(rscc.value("sitename"));		
		
		websiteName = parseNull(rscc.value("website_name"));		
		facebookappid = parseNull(rscc.value("facebook_app_id"));		
		twitteraccount = parseNull(rscc.value("twitter_account"));		
		
		//for v2 menus this will always be empty
		seokeywords = parseNull(rscc.value("seo_keywords"));
		seodescr = parseNull(rscc.value("seo_description"));		

		menuuuid = parseNull(rscc.value("menu_uuid"));
		searchapi = parseNull(rscc.value("search_api"));
		snapPixelCode = parseNull(rscc.value("snap_pixel_code"));

		bShowLoginBar = ("1".equals(parseNull(rscc.value("show_login_bar"))) || "1".equals(parseNull(rscc.value("site_auth_enabled"))) );
		if(bShowLoginBar) showloginbar = "1";

		if("1".equals(parseNull(rscc.value("enable_cart")))) bEnableCart = true;

		usesmartbanner = parseNull(rscc.value("use_smart_banner"));

		smartbannerposition = parseNull(rscc.value("smartbanner_position"));
		smartbannerreminderdays = parseNull(rscc.value("smartbanner_days_reminder"));
		smartbannerhiddendays = parseNull(rscc.value("smartbanner_days_hidden"));

		if("1".equals(rscc.value("show_search_bar"))) issearchadded = true;
		searchurl = parseNull(rscc.value("search_bar_url"));
		searchcompletionurl = parseNull(rscc.value("search_completion_url"));
		searchparams = parseNull(rscc.value("search_params"));		
	}
	
	Logger.info("Site ID ::"+siteid + " uuid :" + siteuuid + " ecommerce:" + ecommerceEnabled);
	//we will always use separate folder caching from v1.5 onwards .. there was no case where we have to do same folder caching so we set this flag true always
	boolean enableseparatefoldercaching = true;
	
	//from 2.9.1 onwards for test site we keep caching off always
	if(bIsProd == false) cached = "0";

	if("1".equals(cached))
	{
		String basedir = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("DOWNLOAD_PAGES_FOLDER");
		//When the crawler is calling urls then we are going to create pages in a separate folder so that the site itself is not disturbed
		//once the crawler finishes its work, it will move the new cached pages to the actual folder from which site is working
		if(binternalcall && enableseparatefoldercaching)
		{
			basedir = GlobalParm.getParm("PUBLISHER_BASE_DIR") + GlobalParm.getParm("PUBLISHER_DOWNLOAD_PAGES_FOLDER");
		}
		if(!basedir.trim().endsWith("/")) basedir = basedir + "/";

		//check if need to reload the page
		InputStream in = null;
		OutputStream soutput = null;
		try
		{ 
			response.setContentType(origContentType);
		
			if(redirect)
			{
				//set the menuid in session also
				com.etn.asimina.session.PortalSession.getInstance().addParameter(Etn, request, response, "MENU_ID_LOADED", menuid);	

				Logger.debug("process.jsp","--"+prodlogtxt+"Going to check for file exists " + basedir + cachedFilePath + cachedFileName);
				File _file = new File((basedir + cachedFilePath + cachedFileName));
				if(_file.exists())
				{
					String sendredirectlink = currentMenuPath;
					//When the crawler is calling urls then we are going to create pages in a separate folder so that the site itself is not disturbed so we return redirect link for that
					if(binternalcall && enableseparatefoldercaching)
					{
						sendredirectlink = getMenuPathFor(Etn, menuid, "PUBLISHER_SEND_REDIRECT_LINK");
					}
					else if("1".equals(___isErr))
					{
						sendredirectlink = getMenuPathFor(Etn, menuid, "SITEMAP_SEND_REDIRECT_LINK");
					}
					else if(bsitemapcall)
					{
						sendredirectlink = getMenuPathFor(Etn, menuid, "SITEMAP_SEND_REDIRECT_LINK");
					}

					//here we cannot send the cachedFileUrl directly because in case of crawling the path will be different
					//and in db we have the file url starting with public menu path so we have to remove the public path from file_url 
					//and send to appropriate sendredirectlink
					String _path = sendredirectlink + cachedFileUrl.replace(currentMenuPath, "") + java.net.URLEncoder.encode(cachedFileName, "utf-8");
					Logger.debug("process.jsp","--"+prodlogtxt+"redirecting to cached page " + _path);
					response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
					response.setHeader("X-Frame-Options","deny");
					response.setHeader("Location", _path);

					return;
				}
				else filefound = false;
			}
			else
			{
				Logger.debug("process.jsp","--"+prodlogtxt+"Basedir for resources : " + basedir);
				if(bIsProd) response.setDateHeader("Expires", System.currentTimeMillis() + 604800000L); 

				String domain = getDomain(url);				
				String localpath = getLocalPath(Etn, url);

				Logger.debug("process.jsp","--"+prodlogtxt+"writing cached page to response stream " + basedir + cachedFilePath + cachedFileName);
				File _fp = new File((basedir + cachedFilePath + cachedFileName));

				java.text.SimpleDateFormat dateFormatGmt = new java.text.SimpleDateFormat("E, dd MMM yyyy HH:mm:ss z", java.util.Locale.ENGLISH);
				dateFormatGmt.setTimeZone(java.util.TimeZone.getTimeZone("GMT"));

				String lastModifiedTime = dateFormatGmt.format(_fp.lastModified());
				response.setHeader("Last-Modified",lastModifiedTime);

				in = new FileInputStream(_fp);
	
				soutput = response.getOutputStream();
				int bytesRead = -1;
      			     	byte[] buffer = new byte[1024];
				while ((bytesRead = in.read(buffer)) != -1) {
					soutput.write(buffer, 0, bytesRead);
				}

	
//			Logger.debug("process.jsp","************************"+prodlogtxt+"fetched cached " + urlfileid + parseNull(dbResFileExtension) + " -- content type " + response.getContentType() + " " + url);
			}
		}
		catch(java.io.FileNotFoundException e)
		{
			filefound = false;
			Logger.error("process.jsp","-------------------------"+prodlogtxt+"filenot found " );
		}
		catch(Exception e)
		{
			e.printStackTrace();
			filefound = false;
		}
		finally
		{	
			try { 
				if(soutput != null) soutput.close(); 
				if(in != null) in.close(); 
			} catch(Exception e) {}
		}
	}	

	String applicableruleid = "0";	
	if(("0".equals(cached) || !filefound) && rextensions.contains(resourceFileExtension.toLowerCase()))
	{
		try
		{
			String domain = getDomain(url);

			String basedir = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("DOWNLOAD_PAGES_FOLDER");
			//When the crawler is calling urls then we are going to create pages in a separate folder so that the site itself is not disturbed
			//once the crawler finishes its work, it will move the new cached pages to the actual folder from which site is working
			if(binternalcall && enableseparatefoldercaching)
			{
				basedir = GlobalParm.getParm("PUBLISHER_BASE_DIR") + GlobalParm.getParm("PUBLISHER_DOWNLOAD_PAGES_FOLDER");
			}

			if(!basedir.trim().endsWith("/")) basedir = basedir + "/";

			File dfile = new File(basedir + cacheFolder);
			try {
				if(!dfile.exists()) createDirectories(basedir, cacheFolder);
			} catch(Exception e) { e.printStackTrace(); }
			basedir += cacheFolder;

			basedir += getFolderId(Etn, domain);
			//create the getfolderid folder if it does not exists
			dfile = new File(basedir);
			try {
				if(!dfile.exists()) dfile.mkdir();
			} catch(Exception e) { e.printStackTrace(); }

			ResourcePath rp = getResourcePath(Etn, url, false);
			String localpath = rp.path;
			String localfile = rp.file;
			localfile = localfile.toLowerCase();
			downloadResourceFromUrl(Etn, domain, url, basedir, request, true);

			if(parseNull(request.getParameter("___ar")).length() > 0)
			{
				try
				{
					applicableruleid = new String(java.util.Base64.getDecoder().decode(parseNull(request.getParameter("___ar"))));
				} catch(Exception e) { e.printStackTrace(); Logger.error("process.jsp",prodlogtxt+"PORTAL::Invalid applicableruleid"); applicableruleid="0";}
			}  

			String originalurl = url;
			String _url2 = url;
			if(_url2.toLowerCase().startsWith("https://")) _url2 = _url2.substring(8);
			else if(_url2.toLowerCase().startsWith("http://")) _url2 = _url2.substring(7);
			_url2 = _url2.trim();
			if(_url2.endsWith("/")) _url2 = _url2.substring(0, _url2.lastIndexOf("/"));

			boolean findapplicablerule = true;
			if(applicableruleid.length() > 0 && !applicableruleid.equals("0"))
			{
				findapplicablerule = false;
				String _mq = "select * from menu_apply_to where id = " + escape.cote(applicableruleid);
				if("v2".equalsIgnoreCase(menuVersion)) _mq = "select * from sites_apply_to where id = " + escape.cote(applicableruleid);
				Set __rsr = Etn.execute(_mq);				
				if(__rsr.rs.Rows == 0) findapplicablerule = true;
			}

			if(findapplicablerule)
			{
				applicableruleid = findApplicableRule(Etn, menuid, menuVersion, _url2);
			}

//			Logger.debug("process.jsp","**************************************");
//			Logger.debug("process.jsp","---------"+prodlogtxt+"menu id sent : " + menuid);
//			Logger.debug("process.jsp","---------"+prodlogtxt+"applying rule id : " + applicableruleid );
//			Logger.debug("process.jsp","**************************************");
				
			String sendredirectlink = getMenuPath(Etn, menuid);
			//When the crawler is calling urls then we are going to create pages in a separate folder so that the site itself is not disturbed so we return redirect link for that
			if(binternalcall && enableseparatefoldercaching)
			{
				sendredirectlink = getMenuPathFor(Etn, menuid, "PUBLISHER_SEND_REDIRECT_LINK");
			}
			else if("1".equals(___isErr))
			{
				sendredirectlink = getMenuPathFor(Etn, menuid, "SITEMAP_SEND_REDIRECT_LINK");
			}
			else if(bsitemapcall)
			{
				sendredirectlink = getMenuPathFor(Etn, menuid, "SITEMAP_SEND_REDIRECT_LINK");
			}

			String _relativecachedpath = cacheFolder + getFolderId(Etn, domain) + localpath;
			String _path = sendredirectlink + getFolderId(Etn, domain) + localpath + java.net.URLEncoder.encode(localfile,"utf-8");
			
			Logger.debug("process.jsp","--"+prodlogtxt+" _relativecachedpath : "+ _relativecachedpath);
			Logger.debug("process.jsp","--"+prodlogtxt+" _path : "+ _path);
			Cacher c = new Cacher(domain, eurl, Etn, basedir, request.getContentType(), new ArrayList<String>(), new ArrayList<String>(), menuid, applicableruleid, localfile, false, request, false, true, binternalcall, _relativecachedpath, "", false, "", currentMenuPath, cacheFolder);
			c.cache();
			if(bIsProd) response.setDateHeader("Expires", System.currentTimeMillis() + 604800000L); 

			response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
			response.setHeader("Location", _path);

			return;
		}
		catch(org.apache.http.conn.ConnectTimeoutException e)
		{
			out.write("Connection timeout with host server");
			e.printStackTrace();
		}
		catch(Exception e) { e.printStackTrace(); }
		return;
	}
	else if("0".equals(cached) || !filefound)
	{
		try
		{
			if(!isInRules(Etn, menuid, url, menuVersion, siteid))
			{
				Logger.error("process.jsp","--------------------------------"+prodlogtxt+" URL is not in rules : " + url);
				response.sendError(javax.servlet.http.HttpServletResponse.SC_FORBIDDEN, "accès refusé");
				return;	
			}		

			String finalResourcesUrl = parseNull(GlobalParm.getParm("COMMON_RESOURCES_URL"));
			if(finalResourcesUrl.endsWith("/") == false) finalResourcesUrl += "/";
			finalResourcesUrl += siteid + "/";
			Logger.debug("finalResourcesUrl="+finalResourcesUrl);

			currentMenuPath = getMenuPath(Etn, menuid);

			String publisherSendRedirectLink = getMenuPathFor(Etn, menuid, "PUBLISHER_SEND_REDIRECT_LINK");
			String sitemapSendRedirectLink = getMenuPathFor(Etn, menuid, "SITEMAP_SEND_REDIRECT_LINK");

			List<String> duplicateCssLinks = new ArrayList<String>();

			List<String> duplicateJsLinks = new ArrayList<String>();
			if("v1".equalsIgnoreCase(menuVersion)) duplicateJsLinks.add("/js/newui/TweenMax.min.js");

			String cssApp = "_catalog";
			if(bIsProd) cssApp = "_prodcatalog";

			//if a page is recached we must recache its related urls (all href,css,js)
			ArrayList<String> recacheurls = new ArrayList<String>();
			String originalurl = url;
			boolean isresourcelink = false;
//			if(_a.toLowerCase().endsWith(".css") || _a.toLowerCase().endsWith(".js") || _a.toLowerCase().endsWith(".axd") || _a.toLowerCase().endsWith(".htc")) isresourcelink = true;
			if(resourceFileExtension.equalsIgnoreCase(".css") || resourceFileExtension.equalsIgnoreCase(".js") || resourceFileExtension.equalsIgnoreCase(".axd") || resourceFileExtension.equalsIgnoreCase(".htc")) isresourcelink = true;
			Logger.debug("process.jsp","^^^^^^^^^^^^^^^^^^^^^^ isresourcelink : " + isresourcelink);

			Redirect finalurl = new Redirect();

			boolean isjsonrequest = false;

			Set allLangs = Etn.execute("select * from language where langue_code <> " + escape.cote(mlang) );			

			String contents = processRequest(url, request, response, finalurl, isresourcelink, menuid, mlang, menuVersion);		

			for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();)
			{
				String headerName = e.nextElement().toString();
				if("accept".equalsIgnoreCase(headerName) && request.getHeader(headerName).toLowerCase().indexOf("application/json") > -1) isjsonrequest = true;
			}

			Logger.debug("process.jsp","response.getStatus() ::: " + response.getStatus());
			if(response.getStatus() >= 300)
			{
				org.jsoup.nodes.Document doc = get404PageHtml(Etn, request, response, menuid);
				out.write(doc.html());
				return;
			}

			String charset = "utf-8";
			if(parseNull(response.getCharacterEncoding()).length() > 0) charset = parseNull(response.getCharacterEncoding()); 
//			Logger.debug("process.jsp","-------"+prodlogtxt+"response charset 2 :  "  + charset);

			if(finalurl.url != null && finalurl.url.length() > 0)
			{
				Logger.debug("process.jsp",""+prodlogtxt+"redirect to : " + finalurl.url);
				url = finalurl.url;
			}

			boolean anytimeout = false;	

			String _url2 = url;
			if(_url2.toLowerCase().startsWith("https://")) _url2 = _url2.substring(8);
			else if(_url2.toLowerCase().startsWith("http://")) _url2 = _url2.substring(7);
			_url2 = _url2.trim();
			if(_url2.endsWith("/")) _url2 = _url2.substring(0, _url2.lastIndexOf("/"));

			//here we are checking if the original page's ruleid is sent in url or not. This case will be for css/js/iframes
			//where we will use the ruleid of original page to decide whether to cache it or no
			if(parseNull(request.getParameter("___ar")).length() > 0)
			{
				try
				{
					applicableruleid = new String(java.util.Base64.getDecoder().decode(parseNull(request.getParameter("___ar"))));
				} catch(Exception e) { e.printStackTrace(); Logger.error("process.jsp",prodlogtxt+"PORTAL::Invalid applicableruleid"); applicableruleid="0";}
			}  

			boolean findapplicablerule = true;
			if(applicableruleid.length() > 0 && !applicableruleid.equals("0"))
			{
				findapplicablerule = false;
				String _mq = "select * from menu_apply_to where id = " + escape.cote(applicableruleid);				
				if("v2".equalsIgnoreCase(menuVersion)) _mq = "select * from sites_apply_to where id = " + escape.cote(applicableruleid);
				
				Set __rsr = Etn.execute(_mq);
				//this means the rule id sent is no more valid so we find it 
				if(__rsr.rs.Rows == 0) findapplicablerule = true;
			}

			if(findapplicablerule)
			{
				applicableruleid = findApplicableRule(Etn, menuid, menuVersion, _url2);
			}

			_a = _a + "  " ; //adding space to exact match ending string
			//if file does not have html tag we cannot pass it to jsoup otherwise it adds the html tags 
			//on contents so we will parse it as js file

			String domain = getDomain(originalurl);
			String basedir = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("DOWNLOAD_PAGES_FOLDER");
			//When the crawler is calling urls then we are going to create pages in a separate folder so that the site itself is not disturbed
			//once the crawler finishes its work, it will move the new cached pages to the actual folder from which site is working
			if(binternalcall && enableseparatefoldercaching)
			{
				basedir = GlobalParm.getParm("PUBLISHER_BASE_DIR") + GlobalParm.getParm("PUBLISHER_DOWNLOAD_PAGES_FOLDER");
			}

			if(!basedir.trim().endsWith("/")) basedir = basedir + "/";
			
			File dfile = new File(basedir);
			try {
				if(!dfile.exists()) dfile.mkdir();
			} catch(Exception e) { e.printStackTrace(); }

			dfile = new File(basedir + cacheFolder);
			try {
				if(!dfile.exists()) createDirectories(basedir, cacheFolder);
			} catch(Exception e) { e.printStackTrace(); }
			basedir += cacheFolder;

			//we are saving this as later we append the domain's folder to basedir which cannot be removed
			String originalBaseDir = basedir;

			String localbaseurl = currentMenuPath;
			
			basedir += getFolderId(Etn, domain);
			localbaseurl += getFolderId(Etn, domain);

			dfile = new File(basedir);
			try {
				if(!dfile.exists()) dfile.mkdir();
			} catch(Exception e) { e.printStackTrace(); }

			boolean ishtml = false;
			boolean isProcessed = false;
			if(isjsonrequest || response.getContentType().contains("application/json") || response.getContentType().contains("application/ld+json") 
				|| response.getContentType().contains("application/xml") )
			{
				//do nothing to contents and just pass them back
				Logger.debug("process.jsp",""+prodlogtxt+"json response = " + contents);
				isProcessed = true;
			}
			//this was a weird case happened long time ago when the url being processed did not had the appropriate extension in it 
			//but the content type returned was pdf or image ... so in this case we have to download the resource as we doing before 
			//where we check for url extension in resources list .. just leaving this code here as was not sure how this happened
			else if(response.getContentType().contains("application/pdf") || response.getContentType().contains("image/png") || response.getContentType().contains("image/jpeg") || response.getContentType().contains("image/jpg"))
			{
				//false so that we download contents from this url
				isProcessed = false;
				//do nothing to contents and just pass them back
				Logger.debug("process.jsp",""+prodlogtxt+" its a pdf file ");				
			}
			else if(resourceFileExtension.equalsIgnoreCase(".css") || response.getContentType().contains("text/css"))
			{	
				isProcessed = true;
				String localpath = getLocalPath(Etn, url);	
				String localfile = getLocalFilename(url);
				List<Resource> resourceurls = getUrlsFromStyling(contents);
				downloadUrls(Etn, url, eurl, domain, basedir, resourceurls, request, rextensions, failedurls);
				contents = fixUrls(Etn, url, domain, localbaseurl, contents, resourceurls, rextensions, menuid);
			}
			else if(resourceFileExtension.equalsIgnoreCase(".js") || resourceFileExtension.equalsIgnoreCase(".axd") || resourceFileExtension.equalsIgnoreCase(".htc") 
				|| response.getContentType().contains("application/x-javascript") || response.getContentType().contains("application/javascript")
				|| response.getContentType().contains("text/x-component"))
			{
				isProcessed = true;
				String localpath = getLocalPath(Etn, url);	
				String localfile = getLocalFilename(url);
				List<Resource> resourceurls = getResourceUrlsFromString(contents);

				//no need to fix ajax calls to social websites through our server
				String sb = parseNull(GlobalParm.getParm("SHARE_BAR_JS"));
//				if(parseNull(sb).length() == 0 || !url.contains(sb))
				if(!noProcessJs(url))
				{
					contents = processJsFile(contents, url, menuid);
				}
				downloadUrls(Etn, url, eurl, domain, basedir, resourceurls, request, rextensions, failedurls,  true);
				anytimeout = getTimeout(anytimeout, resourceurls);

				contents = fixUrls(Etn, url, domain, localbaseurl, contents, resourceurls, rextensions, true, menuid);
				//no need to fix ajax calls to social websites through our server
//				if(parseNull(sb).length() == 0 || !url.contains(sb))
				if(!noProcessJs(url))
				{
					contents = fixAjaxUrls(url, domain, contents, true);
				}
			}
			else if("1".equals(___isajax))
			{
				isProcessed = true;
				String localpath = getLocalPath(Etn, url);	
				String localfile = getLocalFilename(url);
				List<Resource> resourceurls = getResourceUrlsFromString(contents);
				contents = processJsFile(contents, url, menuid);
				downloadUrls(Etn, url, eurl, domain, basedir, resourceurls, request, rextensions, failedurls,  true);
				contents = fixUrls(Etn, url, domain, localbaseurl, contents, resourceurls, rextensions, true, menuid);
				contents = fixAjaxUrls(url, domain, contents);
			}
			else if(response.getContentType().contains("text/html") && (new Detect()).isHtml(contents))
			{
				isProcessed = true;
				ishtml  = true;

				//add all images to this so that they can be downloaded
				Map<String, String> extras = new HashMap<String, String>();
	
//				org.jsoup.nodes.Document doc = Jsoup.parse(contents, url, org.jsoup.parser.Parser.xmlParser());


				contents = handleSpecialCases(contents, originalurl);

				org.jsoup.nodes.Document doc = Jsoup.parse(contents, url);
				doc.outputSettings().charset(charset);

				//this was only supported in old menus
				if("v1".equalsIgnoreCase(menuVersion))
				{
					//click rules
					Set clicks = Etn.execute("select * from menu_click_rules where menu_apply_to_id = " + escape.cote(applicableruleid));
					while(clicks.next())
					{
						try//separate try catch as if anything fails we dont want the page to fail loading
						{
							String elem = parseNull(clicks.value("parent_tag"));
							if(parseNull(clicks.value("parent_tag_attr")).length() > 0) elem += "["+parseNull(clicks.value("parent_tag_attr"))+"]";
							else continue;
		
	//						Logger.debug("process.jsp","###########------------------ " + elem);
							org.jsoup.select.Elements eles = doc.select(elem);	
							if(eles != null)
							{				
	//							Logger.debug("process.jsp","###########------------------ " + eles.size());
								for(org.jsoup.nodes.Element ele : eles)
								{
									boolean isadvert = false;
									elem = parseNull(clicks.value("target_tag"));
									if(parseNull(clicks.value("target_tag_attr")).length() > 0) elem += "["+parseNull(clicks.value("target_tag_attr"))+"]";
	//						Logger.debug("process.jsp","###########------------------ target  : " + elem);
											
									org.jsoup.select.Elements ieles = ele.select(elem);
									if(ieles != null)
									{
	//							Logger.debug("process.jsp","###########------------------ " + ieles.size());
										for(org.jsoup.nodes.Element iele : ieles)
										{
	//							Logger.debug("process.jsp","###########------------------ " + iele.attr("src") + " :: " + parseNull(clicks.value("target_tag")) + " :: " + parseNull(clicks.value("target_tag_word")) );

											if("img".equalsIgnoreCase(parseNull(clicks.value("target_tag"))) && iele.attr("src").contains(parseNull(clicks.value("target_tag_word")))) 
											{
												isadvert = true;
												break;
											}
											if("a".equalsIgnoreCase(parseNull(clicks.value("target_tag"))) && iele.attr("href").contains(parseNull(clicks.value("target_tag_word"))))
											{
												isadvert = true;
												break;
											}
										}
									}
	//							Logger.debug("process.jsp","###########------------------ " + isadvert);

									if(isadvert)//for all href in this container we will mark it either open in new tab or none clickable
									{
										ieles = ele.select("a");
										if(ieles != null)
										{
											for(org.jsoup.nodes.Element iele : ieles)
											{
												iele.addClass("____portal_rule_applied");
												iele.attr("href",iele.absUrl("href"));

	//											if("new_tab".equalsIgnoreCase(parseNull(clicks.value("click_type")))) iele.addClass("____portal_open_new_tab");
												//all external links will open in new tab by default ... script fixmenu.js handles that
												if("do_nothing".equalsIgnoreCase(parseNull(clicks.value("click_type")))) iele.attr("href","javascript:void(0)");
											}
										}
									}
								}
							}
						} catch(Exception e) { e.printStackTrace(); }
					}
					//end click rules
				}

				String redirectForRelativeUrl = currentMenuPath;
				//When the crawler is calling urls then we are going to create pages in a separate folder so that the site itself is not disturbed so we return redirect link for that
				if(binternalcall && enableseparatefoldercaching)
				{
					redirectForRelativeUrl = publisherSendRedirectLink;
				}

				String[] ignoreRelUrls = parseNull(GlobalParm.getParm("IGNORE_RELATIVE_URLS")).split(";");				
				String cachedResourcesFolder = getCachedResourcesUrl(Etn, menuid);

				doc = addDependencyScripts(doc, originalurl);

				List<String> allmenupaths = getAllMenuPaths(Etn);		
				
				org.jsoup.select.Elements eles = doc.select(".asm-continue-shop-btn");
				for(org.jsoup.nodes.Element ele : eles)
				{
					String _r = parseNull(ele.attr("data-continue_url"));
					if(_r.length() == 0 || _r.equals("#")) continue;

					boolean isHtmlPageUrl = isHtmlPageUrl(_r);

					if(!_r.toLowerCase().startsWith("http:") && !_r.toLowerCase().startsWith("https:")
						&& isHtmlPageUrl && !ignoreRelativeUrl(ignoreRelUrls, _r) )
					{
						Logger.debug("process.jsp","--"+prodlogtxt+" Check for relative url .asm-continue-shop-btn : " + _r);
						
						//assumption that if user has added relative url starting with / means it must be a complete path otherwise we append menu path to it
						if(!_r.startsWith("/"))
						{
							//here we append the menu url to href which does not start with /
							//when the page is being crawled the url appended must be publisher send redirect link so that crawler can find this page
							//this also means after crawling crawler must replace the publisher send redirect link must by actual menu path
							//special case of continue shopping url where we are appending currentMenuPath to relative url because
							//the url replacer is not able to replace this url if we append redirectForRelativeUrl
							Logger.debug("process.jsp","--"+prodlogtxt+" Appending " + currentMenuPath + " to relative url " + _r);
							ele.attr("data-continue_url", currentMenuPath + _r);
						}
					}					
				}
				
				eles = doc.select("a[href]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					//special case of image gallery added to products screen ... in there we have hrefs with image path and we dont want that to go through process.jsp instead they should be downloaded while caching page
					if(parseNull(ele.className()).contains("etn_portal_gallery"))
					{
						if(parseNull(ele.attr("href")).length() > 0)
						{
							ele.attr("href", ele.absUrl("href").replaceAll("\n",""));	
							extras.put(ele.absUrl("href").replaceAll("\n",""), null);
						}
						//csrc could be empty or does not exists							
						if(parseNull(ele.attr("csrc")).length() > 0)
						{
							ele.attr("csrc", ele.absUrl("csrc").replaceAll("\n",""));	
							extras.put(ele.absUrl("csrc").replaceAll("\n",""), null);							
						}
					}
					else
					{
						String _r = parseNull(ele.attr("href"));

						boolean isHtmlPageUrl = isHtmlPageUrl(_r);
						
						String absUrl = parseNull(ele.absUrl("href"));

						String _ext = "";
						if(_r.indexOf(".") > -1) _ext = _r.substring(_r.lastIndexOf("."));
			
						if(_r.toLowerCase().startsWith("tel:")) ele.attr("href", _r.replace("#","%23")); 
						else if(_r.toLowerCase().startsWith("javascript:") || !isInRules(Etn, menuid, ele.absUrl("href"), menuVersion, siteid)) continue;
						else if(ele.className().contains("____portal_rule_applied")) continue;//click rule is applied so do not convert it to encoded url
						else if(ele.className().contains("asimina_sso_link"))
						{
							ele.attr("href", GlobalParm.getParm("EXTERNAL_LINK") + ele.attr("href"));
							ele.attr("target","_blank");
						}
						else if(_r.equals("#")) continue;
						else if(_r.equals("/")) continue;
						else if(_r.length() == 0) continue;
						else if(_r.startsWith("#")) continue;
						else if(_r.startsWith("clientapis/"))
						{
							Logger.debug("process.jsp","--"+prodlogtxt+" Appending " + GlobalParm.getParm("EXTERNAL_LINK") + " to client " + _r);							
							ele.attr("href", GlobalParm.getParm("EXTERNAL_LINK") + _r);
						}
						else if(isLocalResource(_r)) 
						{
							if(bIsProd) 
							{
								_r = _r.replace(finalResourcesUrl, cachedResourcesFolder);							
							}
							_r = _r.replace("http://127.0.0.1","").replace("http://localhost","");
							ele.attr("href", _r);//setting relative path 
							//we add this class because its a common resource which might not be available at time of crawling
							//as common resources are copied as the end of crawling ... so this can lead to 404 everytime
							ele.addClass("moringa-no-crawl");
						}						
						else if(rextensions.contains(_ext.toLowerCase())) ele.attr("href", GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___ar="+Base64.encode(applicableruleid.getBytes("UTF-8"))+"&___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+getNewUrl(ele.absUrl("href")));
						//relative url must be local relative url then we proceed otherwise we change it to process.jsp
						else if(!_r.toLowerCase().startsWith("http:") && !_r.toLowerCase().startsWith("https:")
							&& (absUrl.toLowerCase().startsWith("http://127.0.0.1") || absUrl.toLowerCase().startsWith("http://localhost"))
							&& isHtmlPageUrl && !ignoreRelativeUrl(ignoreRelUrls, _r) )
						{
							Logger.debug("process.jsp","--"+prodlogtxt+" Check for relative url : " + _r);
							
							//assumption that if user has added relative url starting with / means it must be a complete path otherwise we append menu path to it
							if(!_r.startsWith("/"))
							{
								//here we append the menu url to href which does not start with /
								//when the page is being crawled the url appended must be publisher send redirect link so that crawler can find this page
								//this also means after crawling crawler must replace the publisher send redirect link must by actual menu path
								Logger.debug("process.jsp","--"+prodlogtxt+" Appending " + redirectForRelativeUrl + " to relative url " + _r);
								ele.attr("href", redirectForRelativeUrl + _r);
							}
						}
						else if(encodeUrl(ele.absUrl("href"), allmenupaths)) 
						{
							String __absUrl = ele.absUrl("href");
							Map<String, String> fixedAbsUrl = fixOldFormatUrls(__absUrl); 
							if(fixedAbsUrl != null)
							{
								Logger.debug("process.jsp","Before encoding url");
								Logger.debug("process.jsp","url : "+ __absUrl);
								if(fixedAbsUrl.get("url") != null) __absUrl = fixedAbsUrl.get("url");
								Logger.debug("process.jsp","fixed url : "+ __absUrl);
							}
							ele.attr("href", GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+getNewUrl(__absUrl));	
						}
					}
				}
				eles = doc.select("iframe[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(!isInRules(Etn, menuid, ele.absUrl("src"), menuVersion, siteid)) continue;

					String _r = ele.attr("src");					
					if(_r.toLowerCase().startsWith("javascript:")) continue;
					if(parseNull(_r).length() == 0 || parseNull(_r).equals("/") || parseNull(_r).startsWith("#")) continue;										
					
					String absUrl = parseNull(ele.absUrl("src"));					
					
					boolean isHtmlPageUrl = isHtmlPageUrl(_r);
					
					if(!_r.toLowerCase().startsWith("http:") && !_r.toLowerCase().startsWith("https:")
						&& (absUrl.toLowerCase().startsWith("http://127.0.0.1") || absUrl.toLowerCase().startsWith("http://localhost"))
						&& isHtmlPageUrl && !ignoreRelativeUrl(ignoreRelUrls, _r) )
					{
						Logger.debug("process.jsp","--"+prodlogtxt+" Check for relative url : " + _r);
						
						//assumption that if user has added relative url starting with / means it must be a complete path otherwise we append menu path to it
						if(!_r.startsWith("/"))
						{
							//here we append the menu url to href which does not start with /
							//when the page is being crawled the url appended must be publisher send redirect link so that crawler can find this page
							//this also means after crawling crawler must replace the publisher send redirect link must by actual menu path
							Logger.debug("process.jsp","--"+prodlogtxt+" Appending " + redirectForRelativeUrl + " to relative url " + _r);
							ele.attr("src", redirectForRelativeUrl + _r);
						}
					}					
					else if(encodeUrl(ele.absUrl("src"), allmenupaths))
					{
						String ___uc = getNewUrl(ele.absUrl("src"));
						ele.attr("src", GlobalParm.getParm("EXTERNAL_LINK") +  "process.jsp?___ar="+Base64.encode(applicableruleid.getBytes("UTF-8"))+"&___noscript=1&___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+ ___uc);	
						recacheurls.add(___uc);
					}
				}
				eles = doc.select("link[rel=shortlink]");
				{
					if(eles != null) eles.remove();
				}
				eles = doc.select("link[rel=canonical]");
				{
					if(eles != null && eles.size() > 0)
					{	
						//only remove canonical for drupal pages
						String relC = parseNull(eles.first().attr("href"));
						if(relC.length() == 0 || relC.startsWith("/drupal") || relC.startsWith("http://127.0.0.1/drupal")  || relC.startsWith("http://localhost/drupal") ) eles.remove();
					}
				}
				
				eles = doc.select("link[href]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					String _rel = parseNull(ele.attr("rel"));
					if(_rel.equalsIgnoreCase("canonical") || _rel.equalsIgnoreCase("shortlink")) continue;
					
					String _r = ele.attr("href");
					if(parseNull(_r).length() == 0 || parseNull(_r).equals("/") || parseNull(_r).startsWith("#")) continue;
					if(parseNull(_r).toLowerCase().startsWith("javascript:")) continue;
					
					ele.attr("href", ele.absUrl("href"));
					if(!isInRules(Etn, menuid, ele.absUrl("href"), menuVersion, siteid)) continue;
										
					if(isLocalAsset(_r))
					{
						_r = _r.replace("http://127.0.0.1","").replace("http://localhost","");
						if(_r.indexOf("?") > -1) _r = _r + "&__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));
						else _r = _r + "?__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));						
						ele.attr("href", _r);//setting relative path 
						continue;											
					}
										
					if(isLocalResource(_r)) 
					{
						if(bIsProd) 
						{
							_r = _r.replace(finalResourcesUrl, cachedResourcesFolder);							
						}
						_r = _r.replace("http://127.0.0.1","").replace("http://localhost","");
						if(_r.indexOf("?") > -1) _r = _r + "&__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));
						else _r = _r + "?__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));
						ele.attr("href", _r);//setting relative path 
						continue;
					}
		
					//following css is used in search pages of orange and these css contains too many external resources which fails most of the time due to slow network so we are not caching these
//					if(ele.absUrl("href").startsWith("https://img.ke.woopic.com/resources/css/") || ele.absUrl("href").startsWith("http://img.ke.woopic.com/resources/css/")) continue;

					//remove the css from catalog pages which is added by cache again
					_r = ele.absUrl("href");
					boolean duplicateCss = false;
					for(String dsl : duplicateCssLinks)
					{
						Logger.debug("process.jsp", "checking duplicate css " + _r + " against " + dsl);
						if(_r.toLowerCase().contains(dsl.toLowerCase()))
						{
							duplicateCss = true;
							break;
						}
					}

					if(duplicateCss)
					{
						Logger.debug("process.jsp", _r + " is a duplicate css ");
						ele.remove();
						continue;
					}
		
					String _lf = getLocalFilename(ele.absUrl("href"));
					String uext = "";
					if(_lf.indexOf(".") > -1) uext = _lf.substring(_lf.lastIndexOf("."));
				
					if(rextensions.contains(uext.toLowerCase()))//its an ico or anyother resource 
					{
						if(parseNull(ele.attr("href")).length() > 0) extras.put(ele.absUrl("href"), null);
					}
					else
					{
						String ___uc = getNewUrl(ele.absUrl("href"));
						ele.attr("href", GlobalParm.getParm("EXTERNAL_LINK") +  "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___noscript=1&___mu="+___uc);		
						recacheurls.add(___uc);
					}
				}
				eles = doc.select("form[action]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(!isInRules(Etn, menuid, ele.absUrl("action"), menuVersion, siteid)) continue;
					
					String _r = parseNull(ele.attr("action"));
					String absUrl = parseNull(ele.absUrl("action"));
					
					if(_r.length() == 0) continue;
					if(_r.startsWith("mailto:")) continue;					
					if(parseNull(_r).equals("/") || parseNull(_r).startsWith("#")) continue;
					
					boolean isHtmlPageUrl = isHtmlPageUrl(_r);

					Logger.debug("process.jsp","--"+prodlogtxt+" form action ");
					
					if(!_r.toLowerCase().startsWith("http:") && !_r.toLowerCase().startsWith("https:")
						&& (absUrl.toLowerCase().startsWith("http://127.0.0.1") || absUrl.toLowerCase().startsWith("http://localhost"))
						&& isHtmlPageUrl && !ignoreRelativeUrl(ignoreRelUrls, _r) )
					{
						Logger.debug("process.jsp","--"+prodlogtxt+" Check for relative url : " + _r);
						
						//assumption that if user has added relative url starting with / means it must be a complete path otherwise we append menu path to it
						if(!_r.startsWith("/"))
						{
							//here we append the menu url to href which does not start with /
							//when the page is being crawled the url appended must be publisher send redirect link so that crawler can find this page
							//this also means after crawling crawler must replace the publisher send redirect link must by actual menu path
							Logger.debug("process.jsp","--"+prodlogtxt+" Appending " + redirectForRelativeUrl + " to relative url " + _r);
							ele.attr("action", redirectForRelativeUrl + _r);
						}
					}
					else if(encodeUrl(ele.absUrl("action"), allmenupaths)) ele.attr("action", GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+getNewUrl(ele.absUrl("action")));	
				}

				eles = doc.select("*[data-uri]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					String _r = parseNull(ele.attr("data-uri"));
					if(parseNull(_r).length() == 0 || parseNull(_r).equals("/") || parseNull(_r).startsWith("#")) continue;
					
					String ___uc = getNewUrl(ele.absUrl("data-uri"));
					ele.attr("action", GlobalParm.getParm("EXTERNAL_LINK") +  "process.jsp?___ar="+Base64.encode(applicableruleid.getBytes("UTF-8"))+"&___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+___uc);	
					recacheurls.add(___uc);
				}

				eles = doc.select("script[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					String _r = ele.attr("src");					
					if(parseNull(_r).length() == 0 || parseNull(_r).equals("/") || parseNull(_r).startsWith("#")) continue;
					if(ignoreJs(ele.absUrl("src"))) continue;
					
					ele.attr("src", ele.absUrl("src"));
					if(!isInRules(Etn, menuid, ele.absUrl("src"), menuVersion, siteid)) continue;	
					
					if(isLocalAsset(_r))
					{
						_r = _r.replace("http://127.0.0.1","").replace("http://localhost","");
						if(_r.indexOf("?") > -1) _r = _r + "&__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));
						else _r = _r + "?__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));						
						ele.attr("src", _r);//setting relative path 
						continue;											
					}
					if(isLocalResource(_r)) 
					{
						if(bIsProd) 
						{
							_r = _r.replace(finalResourcesUrl, cachedResourcesFolder);							
						}
						_r = _r.replace("http://127.0.0.1","").replace("http://localhost","");
						if(_r.indexOf("?") > -1) _r = _r + "&__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));
						else _r = _r + "?__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));						
						ele.attr("src", _r);//setting relative path 
						continue;					
					}
					
					//remove the js from catalog pages which is added by cache again
					_r = ele.absUrl("src");
					boolean duplicateJs = false;
					for(String dsl : duplicateJsLinks)
					{
						Logger.debug("process.jsp", "--"+prodlogtxt+" checking duplicate js " + _r + " against " + dsl);
						if(_r.toLowerCase().contains(dsl.toLowerCase()))
						{
							duplicateJs = true;
							break;
						}
					}

					if(duplicateJs)
					{
						Logger.debug("process.jsp", "--"+prodlogtxt+" " + _r + " is a duplicate js ");
						ele.remove();
						continue;
					}

					String ___uc = getNewUrl(ele.absUrl("src"));						
					ele.attr("src", GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___noscript=1&___mu="+___uc);		
					recacheurls.add(___uc);
				}

				eles = doc.select("source[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					//we found one case of type video so handling that only for now
					if(!(ele.attr("type")).toLowerCase().startsWith("video")) continue;					
					if(parseNull(ele.attr("src")).length() == 0 || parseNull(ele.attr("src")).equals("/") || parseNull(ele.attr("src")).startsWith("#")) continue;					
										
					ele.attr("src", ele.absUrl("src").replaceAll("\n",""));	
					if(!isInRules(Etn, menuid, ele.absUrl("src"), menuVersion, siteid)) continue;	
					extras.put(ele.absUrl("src").replaceAll("\n",""), null);	
				}
				eles = doc.select("image[xlink:href]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("xlink:href")).length() == 0) continue;
					if(ele.attr("xlink:href").startsWith("data:")) continue;
					if(parseNull(ele.attr("xlink:href")).equals("/") || parseNull(ele.attr("xlink:href")).startsWith("#")) continue;					
					
					ele.attr("xlink:href", ele.absUrl("xlink:href").replaceAll("\n",""));	
					extras.put(ele.absUrl("xlink:href").replaceAll("\n",""), null);	
				}
				eles = doc.select("img[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if((ele.attr("src")).toLowerCase().startsWith("data:")) continue;					
					if(parseNull(ele.attr("src")).length() == 0 || parseNull(ele.attr("src")).equals("/") || parseNull(ele.attr("src")).startsWith("#")) continue;
										
					ele.attr("src", ele.absUrl("src").replaceAll("\n",""));	
					extras.put(ele.absUrl("src").replaceAll("\n",""), null);	
				}
				eles = doc.select("img[data-src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if((ele.attr("data-src")).toLowerCase().startsWith("data:")) continue;					
					if(parseNull(ele.attr("data-src")).length() == 0 || parseNull(ele.attr("data-src")).equals("/") || parseNull(ele.attr("data-src")).startsWith("#")) continue;
					
					ele.attr("data-src", ele.absUrl("data-src").replaceAll("\n",""));	
					extras.put(ele.absUrl("data-src").replaceAll("\n",""), null);	
				}
				eles = doc.select("img[data-retina]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(ele.attr("data-retina").toLowerCase().startsWith("data:")) continue;					
					if(parseNull(ele.attr("data-retina")).length() == 0 || parseNull(ele.attr("data-retina")).equals("/") || parseNull(ele.attr("data-retina")).startsWith("#")) continue;

					ele.attr("data-retina", ele.absUrl("data-retina").replaceAll("\n",""));	
					extras.put(ele.absUrl("data-retina").replaceAll("\n",""), null);	
				}
				eles = doc.select("img[data-original]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(ele.attr("data-original").toLowerCase().startsWith("data:")) continue;
					if(parseNull(ele.attr("data-original")).length() == 0 || parseNull(ele.attr("data-original")).equals("/") || parseNull(ele.attr("data-original")).startsWith("#")) continue;

					ele.attr("data-original", ele.absUrl("data-original").replaceAll("\n",""));	
					extras.put(ele.absUrl("data-original").replaceAll("\n",""), null);	
				}
				eles = doc.select("img[data-lazy-src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(ele.attr("data-lazy-src").toLowerCase().startsWith("data:")) continue;					
					if(parseNull(ele.attr("data-lazy-src")).length() == 0 || parseNull(ele.attr("data-lazy-src")).equals("/") || parseNull(ele.attr("data-lazy-src")).startsWith("#")) continue;										

					ele.attr("data-lazy-src", ele.absUrl("data-lazy-src").replaceAll("\n",""));	
					extras.put(ele.absUrl("data-lazy-src").replaceAll("\n",""), null);	
				}
				eles = doc.select("*[background]");
				for(org.jsoup.nodes.Element ele : eles)
				{					
					if(parseNull(ele.attr("background")).length() == 0 || parseNull(ele.attr("background")).equals("/") || parseNull(ele.attr("background")).startsWith("#")) continue;
						
					ele.attr("background", ele.absUrl("background"));	
					//background could be a color as well so we call getResourceUrlsFromString to make sure its an image in background
					if(!getResourceUrlsFromString(ele.absUrl("background")).isEmpty()) extras.put(ele.absUrl("background"), null);	
				}

				eles = doc.select("embed[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{					
					if(parseNull(ele.attr("src")).length() == 0 || parseNull(ele.attr("src")).equals("/") || parseNull(ele.attr("src")).startsWith("#")) continue;									
					
					ele.attr("src", ele.absUrl("src"));	
					extras.put(ele.absUrl("src"), null);	
				}

				eles = doc.select("object[data]");
				for(org.jsoup.nodes.Element ele : eles)
				{					
					if(parseNull(ele.attr("data")).length() == 0 || parseNull(ele.attr("data")).equals("/") || parseNull(ele.attr("data")).startsWith("#")) continue;				

					ele.attr("data", ele.absUrl("data"));	
					extras.put(ele.absUrl("data"), null);	
				}
				eles = doc.select("param[name=movie]");
				for(org.jsoup.nodes.Element ele : eles)
				{					
					if(parseNull(ele.attr("value")).length() == 0 || parseNull(ele.attr("value")).equals("/") || parseNull(ele.attr("value")).startsWith("#")) continue;				

					ele.attr("value", ele.absUrl("value"));	
					extras.put(ele.absUrl("value"), null);		
				}
				eles = doc.select("param[name=FlashVars]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					String[] flashvars = parseNull(ele.attr("value")).split("&");	
					if(flashvars != null)
					{
						for(String fv : flashvars)
						{
							if(parseNull(fv).length() == 0) continue;
							String[] va = fv.split("=");
							if(va == null) continue;
							if("flv".equalsIgnoreCase(va[0])) 
							{
								if(parseNull(va[1]).length() > 0 && parseNull(va[1]).equals("/") == false && parseNull(va[1]).startsWith("#") == false)
								{
									extras.put(getAbsoluteUrl(url, va[1]), null);			
								}								
							}
							else if("startimage".equalsIgnoreCase(va[0])) 
							{
								if(parseNull(va[1]).length() > 0 && parseNull(va[1]).equals("/") == false && parseNull(va[1]).startsWith("#") == false)
								{
									extras.put(getAbsoluteUrl(url, va[1]), null);	
								}								
							}
						}
					}
				}

				eles = doc.select("input[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("src")).length() == 0 || parseNull(ele.attr("src")).equals("/") || parseNull(ele.attr("src")).startsWith("#")) continue;				

					ele.attr("src", ele.absUrl("src"));
	
					String _lf = getLocalFilename(ele.absUrl("src"));
					String uext = "";
					if(_lf.indexOf(".") > -1) uext = _lf.substring(_lf.lastIndexOf("."));

					if(rextensions.contains(uext.toLowerCase()))
					{
						extras.put(ele.absUrl("src"), null);
					}
					else  
					{
						String ___uc = getNewUrl(ele.absUrl("src"));
						ele.attr("src", GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___ar="+Base64.encode(applicableruleid.getBytes("UTF-8"))+"&___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___noscript=1&___mu="+___uc);		
						recacheurls.add(___uc);
					}
				}

				eles = doc.select("meta[property=og:image]");
				if(eles != null && eles.size() > 0) 
				{	
					String __u1 = parseNull(eles.first().attr("content"));
					if(__u1.length() > 0 && __u1.equals("/") == false && __u1.startsWith("#") == false)
					{
						__u1 = getAbsoluteUrl(url, __u1);
						extras.put(__u1, null);
					}
				}

				eles = doc.select("meta[name=twitter:image]");
				if(eles != null && eles.size() > 0) 
				{	
					String __u1 = eles.first().attr("content");
					if(__u1.length() > 0 && __u1.equals("/") == false && __u1.startsWith("#") == false)
					{
						__u1 = getAbsoluteUrl(url, __u1);
						extras.put(__u1, null);
					}
				}

				eles = doc.select("meta[name=etn:eleimage]");
				if(eles != null && eles.size() > 0) 
				{	
					String __u1 = eles.first().attr("content");
					if(__u1.length() > 0 && __u1.equals("/") == false && __u1.startsWith("#") == false)
					{
						__u1 = getAbsoluteUrl(url, __u1);
						extras.put(__u1, null);
					}
				}

				//check if images are already on our server if not then retrieve them
				for(String e : extras.keySet())
				{
					if(parseNull(e).length() == 0 || parseNull(e).equals("/") || parseNull(e).startsWith("#")) continue;
					//no need to download images which are not in trusted domains .. we should show images directly as on some countries internet connection on servers
					//is not available and they might be showing some rss feeds
					if(!isInRules(Etn, menuid, e, menuVersion, siteid)) continue;
					
					if(isLocalResource(e)) 
					{
						String _r = e;						
						
						if(bIsProd) 
						{
							_r = _r.replace(finalResourcesUrl, cachedResourcesFolder);							
						}
						_r = _r.replace("http://127.0.0.1","").replace("http://localhost","");
						extras.put(e, _r);//setting relative path 						
						continue;
					}
					
					try
					{
						Logger.debug("process.jsp","-------------------------------- downloading : " + e + "   basedir : " + basedir);
						if(downloadResourceFromUrl(Etn, domain, e, basedir, request) != 404) 
						{
							extras.put(e, getLocalUrl(Etn, domain, e, currentMenuPath));
						}
						else extras.put(e, "#"); //when the url is in 404 we should set it to hash because otherwise http://127.0.0.1 appears in the pages for missing resources
					} 
					catch(org.apache.http.conn.ConnectTimeoutException ex) 
					{
						//due to any reason if the downloading of resource file failed, next time we still have to download it again
						//otherwise wen page is fetched from cache it will not try any resource file download.
						//so for cache pages we will try downloading the failed urls
						failedurls.add(e); 
						//Etn.executeCmd("insert into failed_urls (domain, encoded_url, failed_url) values ("+escape.cote(domain)+", "+escape.cote(eurl)+", "+escape.cote(e)+") ");
					}
					catch(Exception ex)
					{
//Logger.error("process.jsp","Error downloading : " + e);
						failedurls.add(e); 
						ex.printStackTrace();
					}
				}

				eles = doc.select("a[href]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					//special case of image gallery added to products screen ... in there we have hrefs with image path and we dont want that to go through process.jsp instead they should be downloaded while caching page
					if(parseNull(ele.className()).contains("etn_portal_gallery"))
					{
						if(parseNull(ele.attr("href")).length() > 0 && extras.get(ele.absUrl("href")) != null) 
						{
							ele.attr("href", extras.get(ele.absUrl("href")));		
							if(parseNull(ele.attr("csrc")).length() > 0)
							{
								//for those which have csrc we will set style attribute also
								String _csrc = ele.absUrl("csrc");
								if(extras.get(_csrc) != null)
								{
									ele.attr("csrc", extras.get(_csrc));
									ele.attr("style","background-image:url('"+extras.get(_csrc)+"')");
								}							
							}
						}
					}
				}
				eles = doc.select("source[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					//we found one case of type video so handling that only for now
					if(!ele.attr("type").startsWith("video")) continue;
					if(parseNull(ele.attr("src")).length() == 0) continue;
					if(extras.get(ele.absUrl("src")) != null) ele.attr("src", extras.get(ele.absUrl("src")));	
				}			
				eles = doc.select("image[xlink:href]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("xlink:href")).length() == 0) continue;
					if(extras.get(ele.absUrl("xlink:href")) != null) ele.attr("xlink:href", extras.get(ele.absUrl("xlink:href")));	
				}		
				eles = doc.select("img[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("src")).length() == 0) continue;
					if(extras.get(ele.absUrl("src")) != null) 
					{
						String _temp = getImageFinalUrl(ele.absUrl("src"), extras.get(ele.absUrl("src")));
						ele.attr("src", _temp);	
					}
				}	
				eles = doc.select("img[data-src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("data-src")).length() == 0) continue;
					if(extras.get(ele.absUrl("data-src")) != null) 
					{
						String _temp = getImageFinalUrl(ele.absUrl("data-src"), extras.get(ele.absUrl("data-src")));
						ele.attr("data-src", _temp);	
					}
				}	
				eles = doc.select("img[data-retina]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("data-retina")).length() == 0) continue;
					if(extras.get(ele.absUrl("data-retina")) != null) 
					{
						String _temp = getImageFinalUrl(ele.absUrl("data-retina"),extras.get(ele.absUrl("data-retina")));
						ele.attr("data-retina", _temp);	
					}						
				}	
				eles = doc.select("img[data-original]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("data-original")).length() == 0) continue;
					if(extras.get(ele.absUrl("data-original")) != null) 
					{
						String _temp = getImageFinalUrl(ele.absUrl("data-original"), extras.get(ele.absUrl("data-original")));
						ele.attr("data-original", _temp);	
					}												
				}	
				eles = doc.select("img[data-lazy-src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("data-lazy-src")).length() == 0) continue;
					if(extras.get(ele.absUrl("data-lazy-src")) != null) 
					{
						String _temp = getImageFinalUrl(ele.absUrl("data-lazy-src"), extras.get(ele.absUrl("data-lazy-src")));
						ele.attr("data-lazy-src", _temp);	
					}																	
				}	
				eles = doc.select("embed[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("src")).length() == 0) continue;
					if(extras.get(ele.absUrl("src")) != null) ele.attr("src", extras.get(ele.absUrl("src")));	
				}
				eles = doc.select("object[data]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("data")).length() == 0) continue;
					if(extras.get(ele.absUrl("data")) != null) ele.attr("data", extras.get(ele.absUrl("data")));
				}
				eles = doc.select("param[name=movie]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("value")).length() == 0) continue;
					if(extras.get(ele.absUrl("value")) != null) ele.attr("value", extras.get(ele.absUrl("value")));
				}
				eles = doc.select("param[name=FlashVars]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					String[] flashvars = parseNull(ele.attr("value")).split("&");	
					if(flashvars != null)
					{
						String origFlashVars = parseNull(ele.attr("value"));
						for(String fv : flashvars)
						{
							if(parseNull(fv).length() == 0) continue;
							String[] va = fv.split("=");
							if(va == null) continue;
							if("flv".equalsIgnoreCase(va[0]) && extras.get(getAbsoluteUrl(url, va[1])) != null) origFlashVars = origFlashVars.replace(va[1], extras.get(getAbsoluteUrl(url, va[1])));
							else if("startimage".equalsIgnoreCase(va[0]) && extras.get(getAbsoluteUrl(url, va[1])) != null) origFlashVars = origFlashVars.replace(va[1], extras.get(getAbsoluteUrl(url, va[1])));			
						}
						ele.attr("value", origFlashVars);
					}
				}
				eles = doc.select("input[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("src")).length() == 0) continue;
					if(extras.get(ele.absUrl("src")) != null) ele.attr("src", extras.get(ele.absUrl("src")));	
				}	
				eles = doc.select("link[href]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("href")).length() == 0) continue;
					if(extras.get(ele.absUrl("href")) != null) ele.attr("href", extras.get(ele.absUrl("href")));	
				}	
				eles = doc.select("*[background]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(parseNull(ele.attr("background")).length() == 0) continue;
					if(extras.get(ele.absUrl("background")) != null) ele.attr("background", extras.get(ele.absUrl("background")));	
				}	

				eles = doc.select("meta[property=og:image]");
				if(eles != null && eles.size() > 0) 
				{	
					String __u1 = eles.first().attr("content");					
					if(parseNull(__u1).length() > 0)
					{
						__u1 = getAbsoluteUrl(url, __u1);
						//for og:image if image is not cached we make it empty .. not keeping the original url of _Catalog or _prodcatalog
						//if(extras.get(__u1) != null) 
						String _temp = getImageFinalUrl(__u1, parseNull(extras.get(__u1)));
						eles.first().attr("content", _temp);						
					}
				}

				eles = doc.select("meta[name=twitter:image]");
				if(eles != null && eles.size() > 0) 
				{	
					String __u1 = eles.first().attr("content");
					if(parseNull(__u1).length() > 0)
					{
						__u1 = getAbsoluteUrl(url, __u1);
						//for twitter:image if image is not cached we make it empty .. not keeping the original url of _Catalog or _prodcatalog
						//if(extras.get(__u1) != null) 
						eles.first().attr("content", parseNull(extras.get(__u1)));
					}
				}

				eles = doc.select("meta[name=etn:eleimage]");
				if(eles != null && eles.size() > 0) 
				{	
					String __u1 = eles.first().attr("content");
					if(parseNull(__u1).length() > 0)
					{
						__u1 = getAbsoluteUrl(url, __u1);
						//for twitter:image if image is not cached we make it empty .. not keeping the original url of _Catalog or _prodcatalog
						//if(extras.get(__u1) != null) 
						eles.first().attr("content", parseNull(extras.get(__u1)));
					}
				}

				//download css resources
				eles = doc.getElementsByTag("script");
				if(eles.size() > 0)
				{
					for (org.jsoup.nodes.Element ele : eles)
					{            
						for (org.jsoup.nodes.DataNode node : ele.dataNodes()) 
						{
							String output = node.toString();
//							String output = ele.html();
//for abj screen
							List<Resource> resourceurls = getResourceUrlsFromString(output);
 							downloadUrls(Etn, url, eurl, domain, basedir, resourceurls, request, rextensions, failedurls, true);
							anytimeout = getTimeout(anytimeout, resourceurls);
							output = fixUrls(Etn, url, domain, localbaseurl, output, resourceurls, rextensions, true, menuid);			
							output = fixAjaxUrls(url, domain, output);
							output = processJsFile(output, url, menuid);
//for abj screen
//							ele.html(output);
							node.setWholeData(output);
						}
					}
				}
				eles = doc.getElementsByTag("style");

				if(eles.size() > 0)
				{
					for (org.jsoup.nodes.Element ele : eles)
					{                
						for (org.jsoup.nodes.DataNode node : ele.dataNodes()) 
						{
							//we need to handle data:image as its failing for www.google.com/search
							String output = node.toString();
//							String output = ele.html();
							List<Resource> resourceurls = getUrlsFromStyling(output);
							downloadUrls(Etn, url, eurl, domain, basedir, resourceurls, request, rextensions, failedurls);
							output = fixUrls(Etn, url, domain, localbaseurl, output, resourceurls, rextensions, menuid);
//							ele.html(output);
							node.setWholeData(output);
						}
					}
				} 

				//now parse the whole document to find out any other urls for images embedded in style attributes
				eles = doc.select("*[style]");
				for(org.jsoup.nodes.Element ele : eles)
				{
					if(ele.attr("style").toLowerCase().contains("background"))	
					{
						String output = ele.attr("style");
						List<Resource> resourceurls = getUrlsFromStyling(output);
//						Logger.debug("process.jsp"," ****--- " + ele.attr("style") + " " + resourceurls.size() + " " + output);
						downloadUrls(Etn, url, eurl, domain, basedir, resourceurls, request, rextensions, failedurls);
						output = fixUrls(Etn, url, domain, localbaseurl, output, resourceurls, rextensions, menuid);
						ele.attr("style", output);
//						Logger.debug("process.jsp"," --- " + ele.attr("style"));

					}
				}	

				//remove original base url
				eles = doc.select("base[href]");
				if(eles != null)
				{
					eles.remove();
				}

				//change all img tags to add lazy loading
				//first find if any carrousel is added then dont add lazy loading to it
				ArrayList<String> ignoreLazyLoad = new ArrayList<String>();
				org.jsoup.select.Elements carrImgs = doc.select("div.swiper-wrapper img");
				if(carrImgs != null && carrImgs.size() > 0)
				{
					Logger.debug("****************  carrousels images found " + carrImgs.size());
					for(org.jsoup.nodes.Element cImg: carrImgs)
					{
						if(!ignoreLazyLoad.contains(cImg.attr("src"))) ignoreLazyLoad.add(cImg.attr("src"));
					}
				}
				//find the preload device images ... these must also be loaded with dom to increase speed
				carrImgs = doc.select("#_preloadImages img");
				if(carrImgs != null && carrImgs.size() > 0)
				{
					Logger.debug("****************  _preloadImages images found " + carrImgs.size());
					for(org.jsoup.nodes.Element cImg: carrImgs)
					{
						if(!ignoreLazyLoad.contains(cImg.attr("src"))) ignoreLazyLoad.add(cImg.attr("src"));
					}
				}
				eles = doc.select("img[src]");
				for(org.jsoup.nodes.Element ele : eles)
				{ 
					if(parseNull(ele.attr("src")).startsWith("data:")) continue;
					if(parseNull(ele.attr("src")).length() == 0) continue;
					if(parseNull(ele.className()).contains("moringa-no-lazyload")) continue;
					
					//images which are in carrousel we are ignoring from lazy loading
					if(ignoreLazyLoad.contains(parseNull(ele.attr("src")))) 
					{
						Logger.debug("Ignoring image for lazy load : " + ele.attr("src"));
						continue;
					}
					if(parseNull(ele.attr("data-src")).length() == 0)//this make sures the lazy load is not already added on the image in which case we ignore adding lazy loading
					{
						ele.attr("data-src",  ele.attr("src"));
						ele.attr("src", request.getContextPath() + "/menu_resources/img/blank.gif");	
						ele.addClass("lazyload");						
					}
				}	

				org.jsoup.select.Elements h1s = doc.select("title");
				if(h1s != null && h1s.size() > 0) sub_page_type_level3 = parseNull(h1s.first().html()); 
				if(sub_page_type_level3.indexOf("|") > -1) sub_page_type_level3 = parseNull(sub_page_type_level3.substring(0, sub_page_type_level3.indexOf("|")));
				
				h1s = doc.select("meta[name=etn:dl_page_type]");
				if(h1s != null && h1s.size() > 0) dlPageType = parseNull(h1s.first().attr("content"));
				
				h1s = doc.select("meta[name=etn:dl_sub_level_1]");
				if(h1s != null && h1s.size() > 0) dlSubLevel1 = parseNull(h1s.first().attr("content"));
				
				h1s = doc.select("meta[name=etn:dl_sub_level_2]");
				if(h1s != null && h1s.size() > 0) dlSubLevel2 = parseNull(h1s.first().attr("content"));

				//check for any menu rules
				if(addscript) //add script means we are not coming through an ajax call
				{
					String replacetags = "", headerhtml = "", footerhtml = "";
					if("v1".equalsIgnoreCase(menuVersion))
					{
						Set __rsMHtml = Etn.execute("Select "+headerhtmlcol+", "+footerhtmlcol+" from site_menu_htmls where menu_id = " + escape.cote(menuid));
						__rsMHtml.next();
						headerhtml = parseNull(__rsMHtml.value(headerhtmlcol));
						footerhtml = parseNull(__rsMHtml.value(footerhtmlcol));
					}

					//first preference is menu which is to be applied on exact match url
					String _mq = "select a.id as rid, a.replace_tags from menu_apply_to a where a.id = "+escape.cote(applicableruleid);
					if("v2".equalsIgnoreCase(menuVersion))
					{
						_mq = "select a.id as rid, a.replace_tags from sites_apply_to a where a.id = "+escape.cote(applicableruleid);
					}
					Set menurules = Etn.execute(_mq);
			
					if(menurules.next())
					{
						replacetags = parseNull(menurules.value("replace_tags"));
					}
					
					if("v1".equalsIgnoreCase(menuVersion))
					{
						String colname = "url";
						if(bIsProd) colname = "prod_url";
						Set rsmi = Etn.execute("select * from menu_items where menu_id = "+escape.cote(menuid)+" and "+colname+" = " + escape.cote(originalurl));
						if(rsmi.next())
						{
							if(parseNull(rsmi.value("seo_keywords")).length() > 0) seokeywords = parseNull(rsmi.value("seo_keywords"));
							if(parseNull(rsmi.value("seo_description")).length() > 0) seodescr = parseNull(rsmi.value("seo_description"));
						}
					}

					if(websiteName.length() > 0)
					{
						//we need to append this to title of page
						eles = doc.select("title");
						if(eles != null && eles.size() > 0)
						{
							org.jsoup.nodes.Element ele = eles.first();
							String t = parseNull(ele.html());
							t = appendToTitle(t, websiteName);
							ele.html(t);					
						}
					}
	
					if(seodescr.length() > 0)
					{
						eles = doc.select("meta[name=description]");
						if(eles == null || eles.size() == 0)
						{
							org.jsoup.nodes.Element ele = doc.select("head").first();
							if(ele != null) 
							{
								ele.prepend("<meta name=\"description\" content=\""+escapeCoteValue(seodescr)+"\" >");
							}
						}	
					}

					if(seokeywords.length() > 0)
					{
						eles = doc.select("meta[name=keywords]");
						if(eles == null || eles.size() == 0)
						{
							org.jsoup.nodes.Element ele = doc.select("head").first();
							if(ele != null) 
							{
								ele.prepend("<meta name=\"keywords\" content=\""+escapeCoteValue(seokeywords)+"\" >");
							}
						}
					}

					if(replacetags.length() > 0)
					{
						//hide the divs
						String[] containers = replacetags.split(",");
						if(containers != null)
						{
							for(int j=0; j< containers.length; j++)
							{
//								Logger.debug("process.jsp","-------------- " + containers[j]);
								if(containers[j].trim().length() == 0 ) continue;
	
								String divc = containers[j].trim();

								String containertype = divc.substring(0, divc.indexOf("#"));
								String containerid = divc.substring(divc.indexOf("#") + 1);
								if(containerid.startsWith("id:")) 
								{
									containerid = containerid.substring("id:".length());
//									Logger.debug("process.jsp","=== search div : " + containertype + "#" + containerid);
									eles = doc.select(containertype + "#" + containerid);
									if(eles != null && eles.size() > 0) 
									{
//										doc.select(containertype + "#" + containerid).first().remove();	
										eles.first().remove();
									}
								}
								else if(containerid.startsWith("class:"))
								{
									containerid = containerid.substring("class:".length());
									String[] containerclasses = containerid.split(" ");
									if(containerclasses != null)
									{
										String clss = "";
										for(int k=0; k < containerclasses.length; k++) 
										{
											if(containerclasses[k].trim().length() == 0 ) continue;
											clss += "." + containerclasses[k].trim();
										}
//										Logger.debug("process.jsp","=== search div : " + containertype + clss);
										eles = doc.select(containertype + clss);
										if(eles != null && eles.size() > 0) eles.first().remove();
									}
								}
								else if(containerid.startsWith("number:"))
								{
									String containernumber = containerid.substring("number:".length());
									eles = doc.getElementsByTag(containertype);
									int ncontainernumber = Integer.parseInt(containernumber);
									//index starts from 0
									if(eles.eq(ncontainernumber-1).first() != null) eles.eq(ncontainernumber-1).first().remove();
								}
							}
						}
					}
	
					if("v1".equalsIgnoreCase(menuVersion))
					{
						if(headerhtml.length() > 0 || footerhtml.length() > 0)
						{
							org.jsoup.nodes.Element ele = doc.select("head").first();
							if(ele != null) 
							{
								if("rtl".equalsIgnoreCase(mdirection))
								{
									ele.append("<link href='"+GlobalParm.getParm("EXTERNAL_LINK") +"menu_resources/css/newui/headerfooter-rtl.css?__v="+parseNull(GlobalParm.getParm("CSS_JS_VERSION"))+"' rel='stylesheet' type='text/css'>");
								}
								else
								{					
									ele.append("<link href='"+GlobalParm.getParm("EXTERNAL_LINK") +"menu_resources/css/newui/headerfooter.css?__v="+parseNull(GlobalParm.getParm("CSS_JS_VERSION"))+"' rel='stylesheet' type='text/css'>");
								}
								//for other than orange we have option to customize our menu colors
								if(includeCustomCss) 
								{
									//check if the custom css exists or not ... not always custom css will be available so to avoid 404 we check if file exists or not
									try
									{
										File customcssfile = new File(GlobalParm.getParm("BASE_DIR") + "menu_resources/css/custom_"+menuid+".css");
										if(customcssfile.exists()) ele.append("<link href='"+GlobalParm.getParm("EXTERNAL_LINK") +"menu_resources/css/custom_"+menuid+".css?__v="+parseNull(GlobalParm.getParm("CSS_JS_VERSION"))+"' rel='stylesheet' type='text/css'>");
									}
									catch(Exception e) {}
								}
							}
						}

						if(headerhtml.length() > 0)
						{	
							org.jsoup.nodes.Element ele = doc.select("body").first();
							if(ele != null) 
							{
								//first add breadcrumb placeholder then add header on top of it
								ele.prepend("<div class='etn-portal' id='etn_breadcrumb'></div>");
								ele.prepend(headerhtml);
							}
						}

						if(footerhtml.length() > 0)
						{
							org.jsoup.nodes.Element ele = doc.select("body").first();
							if(ele != null) ele.append(footerhtml);
						}
					}
					
					//case in orange-guinee but we handling it for all pages
					//the response from their server had charset iso-8859-1 whereas in the page itself its defined utf-8 in meta tag
					//the code saves everything in iso (which is returned in response header) and initially was writing the bytes in iso
					//to jsp output. But after redirecting to html page, the html page had utf-8 whereas the time it was saved to disk was iso (due to in header)
					//so we are going to replace the meta tag with the charset we get from response rather than depending on the charset in html saved
					eles = doc.select("meta[http-equiv=Content-Type]");
					if(eles != null && eles.size() > 0)
					{
						eles.first().remove();
					}

					org.jsoup.nodes.Element htmlele = doc.select("html").first();
					if(mlang.length() > 0) htmlele.attr("lang",mlang); 
					if(mdirection.length() == 0) htmlele.attr("dir","ltr");
					else htmlele.attr("dir", mdirection); 


					org.jsoup.nodes.Element headele = doc.select("head").first();

					Logger.debug("Site ID ::"+siteid);					
					Map<String, String> gtmScriptCode = getGtmScriptCodeForCachedPages(Etn, menuid, applicableruleid, url, dlPageType, dlSubLevel1, dlSubLevel2, sub_page_type_level3, menuVersion);
					
					if(addscript && headele != null)
					{
						String u1 = url;
						if(u1.indexOf("?") > -1) u1 = url.substring(0, u1.indexOf("?"));		
						if(u1.indexOf("#") > -1) u1 = url.substring(0, u1.indexOf("#"));
	
						eles = doc.select("meta[property=og:url]");
						if(eles != null && eles.size() > 0) 
						{	
							eles.first().remove();
						}

						eles = doc.select("meta[property=og:locale]");
						if(eles != null && eles.size() > 0 && parseNull(eles.first().attr("content")).length() == 0) 
						{	
							eles.first().remove();
						}

						eles = doc.select("meta[property=fb:app_id]");
						if(eles != null && eles.size() > 0) 
						{	
							eles.first().remove();
						}

						eles = doc.select("meta[property=og:site_name]");
						if(eles != null && eles.size() > 0) 
						{	
							eles.first().remove();
						}

						eles = doc.select("meta[name=twitter:url]");
						if(eles != null && eles.size() > 0) 
						{
							eles.first().remove();
						}

						eles = doc.select("meta[name=twitter:site]");
						if(eles != null && eles.size() > 0) 
						{
							eles.first().remove();
						}

						eles = doc.select("meta[name=twitter:title]");
						if(eles != null && eles.size() > 0) 
						{
							eles.first().remove();
						}

						eles = doc.select("meta[property=og:title]");
						if(eles != null && eles.size() > 0) 
						{
							eles.first().remove();
						}

						String _scr = "\n";
		
						eles = doc.select("meta[name=viewport]");
						if(eles != null && !eles.isEmpty()) eles.first().remove();
						_scr += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">";

						//not adding click jack script into test site pages as those are being authentication already
						//and as we are now showing the preview of products/catalogs/pages etc from test site cache
						//we cannot add click jack script in test site otherwise preview page is redirected which itself is using iframe
						if(bIsProd)
						{
							_scr += "<style id='___portal_antiClickjack'>body{display:none !important;}</style>\n";
							_scr += "<script type='text/javascript'>\n";
							String[] allowIframeDomains = parseNull(com.etn.asimina.util.PortalHelper.getSiteConfig(Etn, siteid, "allow_iframe_domains")).split(",");
							String orDomains = "";
							if(allowIframeDomains != null && allowIframeDomains.length > 0)
							{
								_scr += "function ___getRefferDomain() {if(!document.referrer || document.referrer == '') return ''; let domain = (new URL(document.referrer));domain = domain.hostname;return domain;}\n";
								_scr += "let ___dm = ___getRefferDomain();\n";
								int ordm = 0;
								for(String dm : allowIframeDomains)
								{
									if(ordm++ > 0) orDomains += " || ";
									if(parseNull(dm).length() > 0) orDomains += " ___dm == '"+parseNull(dm)+"' ";
								}
							}
							
							String clickjackscript = "var ___portal_antiClickjack = document.getElementById('___portal_antiClickjack');\n";
							clickjackscript += "___portal_antiClickjack.parentNode.removeChild(___portal_antiClickjack);\n";

							
							if(pagesOnlyOpenInIframe)
							{
								_scr += "if (self === top) { window.stop(); console.log('You are not authorized to view this page'); }\n";
								if(orDomains.length() > 0)
								{
									_scr += "else if ("+orDomains+") {\n";
									_scr += clickjackscript;
									_scr += "}\n";															
								}
							}
							else 
							{
								if(orDomains.length() > 0) orDomains = " || " + orDomains;
								_scr += "if (self === top "+orDomains+") {\n";
								_scr += clickjackscript;
								_scr += "}\n";
							}
													
							_scr += "else {\n";
							_scr += "top.location = self.location;\n";
							_scr += "}\n";
							_scr += "</script>\n";
						}
						
						_scr += "<script type='text/javascript'>\nvar ______durl = '"+Base64.encode(u1.getBytes("UTF-8"))+"';\n";
						_scr += "var ______mid = '"+Base64.encode(menuid.getBytes("UTF-8"))+"';\n"; 
						_scr += "var ______menuid = '"+menuid+"';\n"; 
						_scr += "var ______muid = '"+menuuuid+"';\n"; 
						_scr += "var ______suid = '"+siteuuid+"';\n"; 
						_scr += "var ______dcurl = '"+Base64.encode(url.getBytes("UTF-8"))+"';\n"; 
						_scr += "var ______portalurl2 = '"+GlobalParm.getParm("PORTAL_LINK")+"';\n";
						_scr += "var ______portalurl = '"+GlobalParm.getParm("EXTERNAL_LINK")+"';\n";
						_scr += "var ______lang = '"+mlang+"';\n";
						_scr += "var ______loginenable = "+showloginbar+";\n";
						
						String ___env = "T";
						if(bIsProd) 
						{
							___env = "P";
						}
						
						_scr += "var ______env = '"+___env+"';\n";

						_scr += "</script>\n";
	
						headele.prepend(_scr);

						if(favicon.length() > 0)
						{
							org.jsoup.select.Elements faviconeles = doc.select("link[rel=shortcut icon]");
							if(faviconeles != null && faviconeles.size() > 0) faviconeles.first().remove();

							headele.append("<link rel='shortcut icon' href='"+GlobalParm.getParm("EXTERNAL_LINK")+GlobalParm.getParm("MENU_IMAGES_PATH")+favicon+"' />\n");
						}

						//smart banner
						if("1".equals(usesmartbanner) )
						{
							Set rsshopparams = Etn.execute("select * from "+parseNull(GlobalParm.getParm("CATALOG_DB"))+".shop_parameters where site_id = " + escape.cote(siteid));
							if(rsshopparams.next())
							{
								String langprefix = getLangPrefix(Etn, request, mlang);
								_scr = "<meta name='smartbanner:title' content=\""+escapeCoteValue(parseNull(rsshopparams.value(langprefix + "sb_title")))+"\">";
								if(smartbannerhiddendays.length() > 0 && !"0".equals(smartbannerhiddendays)) _scr += "<meta name='smartbanner:daysHidden' content=\""+escapeCoteValue(smartbannerhiddendays)+"\">";
								if(smartbannerreminderdays.length() > 0 && !"0".equals(smartbannerreminderdays)) _scr += "<meta name='smartbanner:daysReminder' content=\""+escapeCoteValue(smartbannerreminderdays)+"\">";
								_scr += "<meta name='smartbanner:disable-positioning' content='true'>";
								_scr += "<meta name='smartbanner:author' content=\""+escapeCoteValue(parseNull(rsshopparams.value(langprefix + "sb_author")))+"\">";
								_scr += "<meta name='smartbanner:price' content=\""+escapeCoteValue(parseNull(rsshopparams.value(langprefix + "sb_price")))+"\">";
								_scr += "<meta name='smartbanner:button' content=\""+escapeCoteValue(parseNull(rsshopparams.value(langprefix + "sb_button_label")))+"\">";
								String enabledPlatforms = "";
								if("1".equals(parseNull(rsshopparams.value("sb_platform_ios")))) 
								{
									enabledPlatforms = "ios";
									_scr += "<meta name='smartbanner:price-suffix-apple' content=\""+escapeCoteValue(parseNull(rsshopparams.value(langprefix + "sb_ios_price_suffix")))+"\">";
									_scr += "<meta name='smartbanner:icon-apple' content=\""+parseNull(parseNull(GlobalParm.getParm("SMART_BANNER_ICON_URL")) + siteid + "/" + rsshopparams.value("sb_ios_icon"))+"\">";
									_scr += "<meta name='smartbanner:button-url-apple' content=\""+escapeCoteValue(parseNull(rsshopparams.value(langprefix + "sb_ios_button_url")))+"\">";
								}
								if("1".equals(parseNull(rsshopparams.value("sb_platform_android"))))
								{
									if(enabledPlatforms.length() > 0) enabledPlatforms += ",";
									enabledPlatforms += "android";
									_scr += "<meta name='smartbanner:price-suffix-google' content=\""+escapeCoteValue(parseNull(rsshopparams.value(langprefix + "sb_android_price_suffix")))+"\">";
									_scr += "<meta name='smartbanner:icon-google' content=\""+parseNull(parseNull(GlobalParm.getParm("SMART_BANNER_ICON_URL")) + siteid + "/" + rsshopparams.value("sb_android_icon"))+"\">";
									_scr += "<meta name='smartbanner:button-url-google' content=\""+escapeCoteValue(parseNull(rsshopparams.value(langprefix + "sb_android_button_url")))+"\">";
								}
								_scr += "<meta name='smartbanner:enabled-platforms' content=\""+escapeCoteValue(enabledPlatforms)+"\">";

								if("bottom".equalsIgnoreCase(smartbannerposition)) _scr += "<link rel='stylesheet' href='"+GlobalParm.getParm("EXTERNAL_LINK") +"menu_resources/css/smartbanner-bottom.min.css'>";
								else _scr += "<link rel='stylesheet' href='"+GlobalParm.getParm("EXTERNAL_LINK") +"menu_resources/css/smartbanner.min.css'>";
								_scr += "<script defer src='"+GlobalParm.getParm("EXTERNAL_LINK") +"menu_resources/js/smartbanner.min.js'></script>";

								headele.prepend(_scr);

							}
						}
						
						headele.prepend(gtmScriptCode.get("SCRIPT_SNIPPET"));
						
						//get all meta etn: tags and put those before the GTM script as GTM script needs those
						eles = doc.select("meta");
						if(eles != null && eles.size() > 0)
						{
							for(org.jsoup.nodes.Element ele : eles)
							{
								if(parseNull(ele.attr("name")).startsWith("etn:"))
								{
									ele.remove();
									headele.prepend(ele.toString());
								}
							}
						}

						//have to keep charset in first 1024 bytes
						headele.prepend("<meta http-equiv='Content-Type' content='text/html; charset="+charset+"'> \n");
						
						if(snapPixelCode.length() > 0)
						{
							String snapStr = "<script type='text/javascript'>" +							
											"(function(e,t,n){if(e.snaptr)return;var a=e.snaptr=function()" +
											"{a.handleRequest?a.handleRequest.apply(a,arguments):a.queue.push(arguments)};" +
											"a.queue=[];var s='script';r=t.createElement(s);r.async=!0;" +
											"r.src=n;var u=t.getElementsByTagName(s)[0];" +
											"u.parentNode.insertBefore(r,u);})(window,document," +
											"'https://sc-static.net/scevent.min.js');" +
											"snaptr('init', '"+snapPixelCode+"', {" +
											"'user_email': '__INSERT_USER_EMAIL__'" +
											"});" +
											"snaptr('track', 'PAGE_VIEW');" +
											"</script>";
							
							headele.append(snapStr);
						}
						
						//these are required by BlockSystemJsFunctions so we add first
						headele.append("<meta name=\"pr:secom\" content=\""+ecommerceEnabled+"\">");
						headele.append("<meta name=\"pr:suid\" content=\""+siteuuid+"\">");
						headele.append("<meta name=\"pr:muid\" content=\""+menuuuid+"\">");
						headele.append("<meta name=\"pr:mvrn\" content=\""+menuVersion.toUpperCase()+"\">");
					}
					
					org.jsoup.nodes.Element bodyele = doc.select("body").first();
					if(addscript && bodyele != null)
					{
						if(gtmScriptCode.get("NOSCRIPT_SNIPPET") != null)
						{
							bodyele.prepend(gtmScriptCode.get("NOSCRIPT_SNIPPET"));
						}
						String _scr = "<script type='text/javascript'>var __loadWithNoConflict = false;\nif(typeof window.jQuery != \"undefined\") __loadWithNoConflict = true;</script><script src='"+GlobalParm.getParm("EXTERNAL_LINK")+"menu_resources/js/newui/portalbundle.js?__v="+parseNull(GlobalParm.getParm("CSS_JS_VERSION"))+"' ></script>\n";
						_scr += "<script type='text/javascript'>var ___portaljquery = null;\nif(__loadWithNoConflict) ___portaljquery = $.noConflict(true);\nelse ___portaljquery = window.jQuery;</script>\n";

						if(headerhtml.length() > 0 || footerhtml.length() > 0) 
						{
							_scr += "<script src='"+GlobalParm.getParm("EXTERNAL_LINK") +"menu_resources/js/newui/headerfooterbundle.js?__v="+parseNull(GlobalParm.getParm("CSS_JS_VERSION"))+"'></script>\n";			
						}
						else if("V2".equalsIgnoreCase(menuVersion))
						{
							_scr += "<script src='"+GlobalParm.getParm("EXTERNAL_LINK") +"menu_resources/js/newui/default.js?__v="+parseNull(GlobalParm.getParm("CSS_JS_VERSION"))+"'></script>\n";			
						} 
						_scr += com.etn.asimina.util.BlockSystemJsFunctions.getRequiredJs(Etn, doc);		
						_scr += "<script type='text/javascript'>___portaljquery(document).ready(function() { lazyload(); });</script>\n";

						if("v1".equalsIgnoreCase(menuVersion))
						{
							if(issearchadded) 
							{
								if("url".equalsIgnoreCase(searchapi))//external search implemented by Orange
								{
									if(!searchurl.toLowerCase().startsWith("http:") && !searchurl.toLowerCase().startsWith("https:") && !searchurl.toLowerCase().startsWith("/"))
									{
										searchurl = currentMenuPath + searchurl;
									}
										
									_scr += "<script>var ____searchurl = '"+searchurl+"';</script>\n";
									_scr += "<script>var ____searchparam = '"+searchparams+"';</script>\n";
								}
								else if("external".equalsIgnoreCase(searchapi))//external search implemented by Orange
								{
									_scr += "<script type=\"text/javascript\">\n";
									_scr += "var defercss2 = document.createElement('link');\n";
									_scr += "defercss2.rel = 'stylesheet';\n";
									_scr += "defercss2.href = 'https://img.ke.woopic.com/resources/external/emea/completion/v4-0/sources/css/completion.min.css';\n";
									_scr += "defercss2.type = 'text/css';\n";
									_scr += "var godefer2 = document.getElementsByTagName('link')[0];\n";
									_scr += "godefer2.parentNode.insertBefore(defercss2, godefer2);\n";
									_scr += "</script>\n";

									_scr += "<script src='https://img.ke.woopic.com/resources/external/emea/completion/v4-0/sources/js/completion.min.js'></script>\n";
									_scr += "<script>var dsearch = new OrangeSearch();\n dsearch.__initCompleter('"+searchcompletionurl+"','"+searchparams+"','"+searchurl+"','moringadesktopsearchfield');</script>\n";
									_scr += "<script>var msearch = new OrangeSearch();\n msearch.__initCompleter('"+searchcompletionurl+"','"+searchparams+"','"+searchurl+"','moringamobilesearchfield');</script>\n";

								}
							}

							if(bShowLoginBar || bEnableCart) 
							{
								_scr += "<script type='text/javascript'>\n";
								_scr += "___portaljquery(document).ready(function() {\n";

								if(bShowLoginBar) 
								{ 
									_scr += "__checkLogin();\n";
								}
								if(bEnableCart) 
								{
									//add the script directly to page to improve load time
									_scr += "__loadcart();\n";
								}
								_scr += "});\n";
								_scr += "</script>";
							}
						}
						
						if("v2".equalsIgnoreCase(menuVersion))
						{							
							_scr += "<script type='text/javascript'>function __gotoPortalHome() { var __hp = '"+currentMenuPath+homepageurl+"'; if(__hp.indexOf(\"?\") > -1) __hp +=\"&\"; else __hp +=\"?\";  __hp +=\"tm=\"+(new Date().getTime()); window.location = __hp; }</script>\n";							
						}
						else
						{
							_scr += "<script type='text/javascript'>function __gotoPortalHome() { var __hp = ___portaljquery(\"#___portalhomepagelink\").attr('href'); if(__hp.indexOf(\"?\") > -1) __hp +=\"&\"; else __hp +=\"?\";  __hp +=\"tm=\"+(new Date().getTime()); window.location = __hp; }</script>\n";							
						}
						
						bodyele.append(_scr);

						String forterId = parseNull(com.etn.asimina.util.PortalHelper.getSiteConfig(Etn, siteid, "forter_id"));
						if(forterId.length() > 0) 
						{
							String debugToken = "";
							if(bIsProd == false) debugToken = " console.log('forter token : ' + token); ";
							_scr = "<!-- BEGIN FORTER SCRIPTS -->";		
							_scr += "<script type=\"text/javascript\">document.addEventListener('ftr:tokenReady', function(evt) { var token = evt.detail; "+debugToken+" ___portaljquery.ajax({url: '"+GlobalParm.getParm("EXTERNAL_LINK")+"/clientapis/forter/savetoken.jsp', data : { t : token }, dataType : 'json', method : 'post', success : function(j) { console.log(j); } }); });</script>";
							_scr += "<script type=\"text/javascript\" id=\""+forterId+"\">(function () { var merchantConfig = { csp: false }; var siteId = \""+forterId+"\";function t(t,e){for(var n=t.split(\"\"),r=0;r<n.length;++r)n[r]=String.fromCharCode(n[r].charCodeAt(0)+e);return n.join(\"\")}function e(e){return t(e,-_).replace(/%SN%/g,siteId)}function n(t){try{if(\"number\"==typeof t&&window.location&&window.location.pathname){for(var e=window.location.pathname.split(\"/\"),n=[],r=0;r<=Math.min(e.length-1,Math.abs(t));r++)n.push(e[r]);return n.join(\"/\")||\"/\"}}catch(t){}return\"/\"}function r(t){try{Q.ex=t,o()&&-1===Q.ex.indexOf(X.uB)&&(Q.ex+=X.uB),i()&&-1===Q.ex.indexOf(X.uBr)&&(Q.ex+=X.uBr),a()&&-1===Q.ex.indexOf(X.nIL)&&(Q.ex+=X.nIL),window.ftr__snp_cwc||(Q.ex+=X.s),B(Q)}catch(t){}}function o(){var t=\"no\"+\"op\"+\"fn\",e=\"g\"+\"a\",n=\"n\"+\"ame\";return window[e]&&window[e][n]===t}function i(){return!(!navigator.brave||\"function\"!=typeof navigator.brave.isBrave)}function a(){return document.currentScript&&document.currentScript.src}function c(t,e){function n(o){try{o.blockedURI===t&&(e(),document.removeEventListener(r,n))}catch(t){document.removeEventListener(r,n)}}var r=\"securitypolicyviolation\";document.addEventListener(r,n),setTimeout(function(){document.removeEventListener(r,n)},2*60*1e3)}function u(t,e,n,r){var o=!1;t=\"https://\"+t,c(t,function(){r(!0),o=!0});var i=document.createElement(\"script\");i.onerror=function(){if(!o)try{r(!1),o=!0}catch(t){}},i.onload=n,i.type=\"text/javascript\",i.id=\"ftr__script\",i.async=!0,i.src=t;var a=document.getElementsByTagName(\"script\")[0];a.parentNode.insertBefore(i,a)}function f(){tt(X.uDF),setTimeout(w,N,X.uDF)}function s(t,e,n,r){var o=!1,i=new XMLHttpRequest;if(c(\"https:\"+t,function(){n(new Error(\"CSP Violation\"),!0),o=!0}),\"//\"===t.slice(0,2)&&(t=\"https:\"+t),\"withCredentials\"in i)i.open(\"GET\",t,!0);else{if(\"undefined\"==typeof XDomainRequest)return;i=new XDomainRequest,i.open(\"GET\",t)}Object.keys(r).forEach(function(t){i.setRequestHeader(t,r[t])}),i.onload=function(){\"function\"==typeof e&&e(i)},i.onerror=function(t){if(\"function\"==typeof n&&!o)try{n(t,!1),o=!0}catch(t){}},i.onprogress=function(){},i.ontimeout=function(){\"function\"==typeof n&&n(\"tim\"+\"eo\"+\"ut\",!1)},setTimeout(function(){i.send()},0)}function d(t,siteId,e){function n(t){var e=t.toString(16);return e.length%2?\"0\"+e:e}function r(t){if(t<=0)return\"\";for(var e=\"0123456789abcdef\",n=\"\",r=0;r<t;r++)n+=e[Math.floor(Math.random()*e.length)];return n}function o(t){for(var e=\"\",r=0;r<t.length;r++)e+=n(t.charCodeAt(r));return e}function i(t){for(var e=t.split(\"\"),n=0;n<e.length;++n)e[n]=String.fromCharCode(255^e[n].charCodeAt(0));return e.join(\"\")}e=e?\"1\":\"0\";var a=[];return a.push(t),a.push(siteId),a.push(e),function(t){var e=40,n=\"\";return t.length<e/2&&(n=\",\"+r(e/2-t.length-1)),o(i(t+n))}(a.join(\",\"))}function h(){function t(){F&&(tt(X.dUAL),setTimeout(w,N,X.dUAL))}function e(t,e){r(e?X.uAS+X.uF+X.cP:X.uAS+X.uF),F=\"F\"+\"T\"+\"R\"+\"A\"+\"U\",setTimeout(w,N,X.uAS)}window.ftr__fdad(t,e)}function l(){function t(){F&&setTimeout(w,N,X.uDAD)}function e(t,e){r(e?X.uDS+X.uF+X.cP:X.uDS+X.uF),F=\"F\"+\"T\"+\"R\"+\"A\"+\"U\",setTimeout(w,N,X.uDS)}window.ftr__radd(t,e)}function w(t){try{var e;switch(t){case X.uFP:e=O;break;case X.uDF:e=M;break;default:e=F}if(!e)return;var n=function(){try{et(),r(t+X.uS)}catch(t){}},o=function(e){try{et(),Q.td=1*new Date-Q.ts,r(e?t+X.uF+X.cP:t+X.uF),t===X.uFP&&f(),t===X.uDF&&(I?l():h()),t!==X.uAS&&t!==X.dUAL||I||l(),t!==X.uDS&&t!==X.uDAD||I&&h()}catch(t){r(X.eUoe)}};if(e===\"F\"+\"T\"+\"R\"+\"A\"+\"U\")return void o();u(e,void 0,n,o)}catch(e){r(t+X.eTlu)}}var g=\"22ge:t7mj8unkn;1forxgiurqw1qhw2vwdwxv\",v=\"fort\",p=\"erTo\",m=\"ken\",_=3;window.ftr__config={m:merchantConfig,s:\"24\",si:siteId};var y=!1,U=!1,T=v+p+m,x=400*24*60,A=10,S={write:function(t,e,r,o){void 0===o&&(o=!0);var i=0;window.ftr__config&&window.ftr__config.m&&window.ftr__config.m.ckDepth&&(i=window.ftr__config.m.ckDepth);var a,c,u=n(i);if(r?(a=new Date,a.setTime(a.getTime()+60*r*1e3),c=\"; expires=\"+a.toGMTString()):c=\"\",!o)return void(document.cookie=escape(t)+\"=\"+escape(e)+c+\"; path=\"+u);for(var f=1,s=document.domain.split(\".\"),d=A,h=!0;h&&s.length>=f&&d>0;){var l=s.slice(-f).join(\".\");document.cookie=escape(t)+\"=\"+escape(e)+c+\"; path=\"+u+\"; domain=\"+l;var w=S.read(t);null!=w&&w==e||(l=\".\"+l,document.cookie=escape(t)+\"=\"+escape(e)+c+\"; path=\"+u+\"; domain=\"+l),h=-1===document.cookie.indexOf(t+\"=\"+e),f++,d--}},read:function(t){var e=null;try{for(var n=escape(t)+\"=\",r=document.cookie.split(\";\"),o=32,i=0;i<r.length;i++){for(var a=r[i];a.charCodeAt(0)===o;)a=a.substring(1,a.length);0===a.indexOf(n)&&(e=unescape(a.substring(n.length,a.length)))}}finally{return e}}},D=window.ftr__config.s;D+=\"ck\";var L=function(t){var e=!1,n=null,r=function(){try{if(!n||!e)return;n.remove&&\"function\"==typeof n.remove?n.remove():document.head.removeChild(n),e=!1}catch(t){}};document.head&&(!function(){n=document.createElement(\"link\"),n.setAttribute(\"rel\",\"pre\"+\"con\"+\"nect\"),n.setAttribute(\"cros\"+\"sori\"+\"gin\",\"anonymous\"),n.onload=r,n.onerror=r,n.setAttribute(\"href\",t),document.head.appendChild(n),e=!0}(),setTimeout(r,3e3))},E=e(g||\"22ge:t7mj8unkn;1forxgiurqw1qhw2vwdwxv\"),C=t(\"[0Uhtxhvw0LG\",-_),R=t(\"[0Fruuhodwlrq0LG\",-_),P=t(\"Li0Qrqh0Pdwfk\",-_),k=e(\"dss1vlwhshuirupdqfhwhvw1qhw\"),q=e(\"2241414142gqv0txhu|\"),F,b=\"fgq71iruwhu1frp\",M=e(\"(VQ(1\"+b+\"2vq2(VQ(2vfulsw1mv\"),V=e(\"(VQ(1\"+b+\"2vqV2(VQ(2vfulsw1mv\"),O;window.ftr__config&&window.ftr__config.m&&window.ftr__config.m.fpi&&(O=window.ftr__config.m.fpi+e(\"2vq2(VQ(2vfulsw1mv\"));var I=!1,N=10;window.ftr__startScriptLoad=1*new Date;var j=function(t){var e=\"ft\"+\"r:tok\"+\"enR\"+\"eady\";window.ftr__tt&&clearTimeout(window.ftr__tt),window.ftr__tt=setTimeout(function(){try{delete window.ftr__tt,t+=\"_tt\";var n=document.createEvent(\"Event\");n.initEvent(e,!1,!1),n.detail=t,document.dispatchEvent(n)}catch(t){}},1e3)},B=function(t){var e=function(t){return t||\"\"},n=e(t.id)+\"_\"+e(t.ts)+\"_\"+e(t.td)+\"_\"+e(t.ex)+\"_\"+e(D),r=x;!isNaN(window.ftr__config.m.ckTTL)&&window.ftr__config.m.ckTTL&&(r=window.ftr__config.m.ckTTL),S.write(T,n,r,!0),j(n),window.ftr__gt=n},G=function(){var t=S.read(T)||\"\",e=t.split(\"_\"),n=function(t){return e[t]||void 0};return{id:n(0),ts:n(1),td:n(2),ex:n(3),vr:n(4)}},H=function(){for(var t={},e=\"fgu\",n=[],r=0;r<256;r++)n[r]=(r<16?\"0\":\"\")+r.toString(16);var o=function(t,e,r,o,i){var a=i?\"-\":\"\";return n[255&t]+n[t>>8&255]+n[t>>16&255]+n[t>>24&255]+a+n[255&e]+n[e>>8&255]+a+n[e>>16&15|64]+n[e>>24&255]+a+n[63&r|128]+n[r>>8&255]+a+n[r>>16&255]+n[r>>24&255]+n[255&o]+n[o>>8&255]+n[o>>16&255]+n[o>>24&255]},i=function(){if(window.Uint32Array&&window.crypto&&window.crypto.getRandomValues){var t=new window.Uint32Array(4);return window.crypto.getRandomValues(t),{d0:t[0],d1:t[1],d2:t[2],d3:t[3]}}return{d0:4294967296*Math.random()>>>0,d1:4294967296*Math.random()>>>0,d2:4294967296*Math.random()>>>0,d3:4294967296*Math.random()>>>0}},a=function(){var t=\"\",e=function(t,e){for(var n=\"\",r=t;r>0;--r)n+=e.charAt(1e3*Math.random()%e.length);return n};return t+=e(2,\"0123456789\"),t+=e(1,\"123456789\"),t+=e(8,\"0123456789\")};return t.safeGenerateNoDash=function(){try{var t=i();return o(t.d0,t.d1,t.d2,t.d3,!1)}catch(t){try{return e+a()}catch(t){}}},t.isValidNumericalToken=function(t){return t&&t.toString().length<=11&&t.length>=9&&parseInt(t,10).toString().length<=11&&parseInt(t,10).toString().length>=9},t.isValidUUIDToken=function(t){return t&&32===t.toString().length&&/^[a-z0-9]+$/.test(t)},t.isValidFGUToken=function(t){return 0==t.indexOf(e)&&t.length>=12},t}(),X={uDF:\"UDF\",dUAL:\"dUAL\",uAS:\"UAS\",uDS:\"UDS\",uDAD:\"UDAD\",uFP:\"UFP\",mLd:\"1\",eTlu:\"2\",eUoe:\"3\",uS:\"4\",uF:\"9\",tmos:[\"T5\",\"T10\",\"T15\",\"T30\",\"T60\"],tmosSecs:[5,10,15,30,60],bIR:\"43\",uB:\"u\",uBr:\"b\",cP:\"c\",nIL:\"i\",s:\"s\"};try{var Q=G();try{Q.id&&(H.isValidNumericalToken(Q.id)||H.isValidUUIDToken(Q.id)||H.isValidFGUToken(Q.id))?window.ftr__ncd=!1:(Q.id=H.safeGenerateNoDash(),window.ftr__ncd=!0),Q.ts=window.ftr__startScriptLoad,B(Q),window.ftr__snp_cwc=!!S.read(T),window.ftr__snp_cwc||(M=V);for(var $=\"for\"+\"ter\"+\".co\"+\"m\",z=\"ht\"+\"tps://c\"+\"dn9.\"+$,J=\"ht\"+\"tps://\"+Q.id+\"-\"+siteId+\".cd\"+\"n.\"+$,K=\"http\"+\"s://cd\"+\"n3.\"+$,W=[z,J,K],Y=0;Y<W.length;Y++)L(W[Y]);var Z=new Array(X.tmosSecs.length),tt=function(t){for(var e=0;e<X.tmosSecs.length;e++)Z[e]=setTimeout(r,1e3*X.tmosSecs[e],t+X.tmos[e])},et=function(){for(var t=0;t<X.tmosSecs.length;t++)clearTimeout(Z[t])};window.ftr__fdad=function(e,n){if(!y){y=!0;var r={};r[P]=d(window.ftr__config.s,siteId,window.ftr__config.m.csp),s(E,function(n){try{var r=n.getAllResponseHeaders().toLowerCase();if(r.indexOf(R.toLowerCase())>=0){var o=n.getResponseHeader(R);window.ftr__altd2=t(atob(o),-_-1)}if(r.indexOf(C.toLowerCase())<0)return;var i=n.getResponseHeader(C),a=t(atob(i),-_-1);if(a){var c=a.split(\":\");if(c&&2===c.length){for(var u=c[0],f=c[1],s=\"\",d=0,h=0;d<20;++d)s+=d%3>0&&h<12?siteId.charAt(h++):Q.id.charAt(d);var l=f.split(\",\");if(l.length>1){var w=l[0],g=l[1];F=u+\"/\"+w+\".\"+s+\".\"+g}}}e()}catch(t){}},function(t,e){n&&n(t,e)},r)}},window.ftr__radd=function(t,e){function n(e){try{var n=e.response,r=function(t){function e(t,o,i){try{if(i>=n)return{name:\"\",nextOffsetToProcess:o,error:\"Max pointer dereference depth exceeded\"};for(var a=[],c=o,u=t.getUint8(c),f=0;f<r;){if(f++,192==(192&u)){var s=(63&u)<<8|t.getUint8(c+1),d=e(t,s,i+1);if(d.error)return d;var h=d.name;return a.push(h),{name:a.join(\".\"),nextOffsetToProcess:c+2}}if(!(u>0)){if(0!==u)return{name:\"\",nextOffsetToProcess:c,error:\"Unexpected length at the end of name: \"+u.toString()};return{name:a.join(\".\"),nextOffsetToProcess:c+1}}for(var l=\"\",w=1;w<=u;w++)l+=String.fromCharCode(t.getUint8(c+w));a.push(l),c+=u+1,u=t.getUint8(c)}return{name:\"\",nextOffsetToProcess:c,error:\"Max iterations exceeded\"}}catch(t){return{name:\"\",nextOffsetToProcess:o,error:\"Unexpected error while parsing response: \"+t.toString()}}}for(var n=4,r=100,o=16,i=new DataView(t),a=i.getUint16(0),c=i.getUint16(2),u=i.getUint16(4),f=i.getUint16(6),s=i.getUint16(8),d=i.getUint16(10),h=12,l=[],w=0;w<u;w++){var g=e(i,h,0);if(g.error)throw new Error(g.error);if(h=g.nextOffsetToProcess,!Number.isInteger(h))throw new Error(\"invalid returned offset\");var v=g.name,p=i.getUint16(h);h+=2;var m=i.getUint16(h);h+=2,l.push({qname:v,qtype:p,qclass:m})}for(var _=[],w=0;w<f;w++){var g=e(i,h,0);if(g.error)throw new Error(g.error);if(h=g.nextOffsetToProcess,!Number.isInteger(h))throw new Error(\"invalid returned offset\");var y=g.name,U=i.getUint16(h);if(U!==o)throw new Error(\"Unexpected record type: \"+U.toString());h+=2;var T=i.getUint16(h);h+=2;var x=i.getUint32(h);h+=4;var A=i.getUint16(h);h+=2;for(var S=\"\",D=h,L=0;D<h+A&&L<r;){L++;var E=i.getUint8(D);D+=1;S+=(new TextDecoder).decode(t.slice(D,D+E)),D+=E}if(L>=r)throw new Error(\"Max iterations exceeded while reading TXT data\");h+=A,_.push({name:y,type:U,class:T,ttl:x,data:S})}return{transactionId:a,flags:c,questionCount:u,answerCount:f,authorityCount:s,additionalCount:d,questions:l,answers:_}}(n);if(!r)throw new Error(\"Error parsing DNS response\");if(!(\"answers\"in r))throw new Error(\"Unexpected response\");var o=r.answers;if(0===o.length)throw new Error(\"No answers found\");var i=o[0].data;if(i=i.replace(/^\"(.*)\"$/,\"$1\"),decodedVal=function(t){var e=40,n=32,r=126;try{for(var o=atob(t),i=\"\",a=0;a<o.length;a++)i+=function(t){var o=t.charCodeAt(0),i=o-e;return i<n&&(i=r-(n-i)+1),String.fromCharCode(i)}(o[a]);return atob(i)}catch(t){return}}(i),!decodedVal)throw new Error(\"failed to decode the value\");var a=function(t){var e=\"_\"+\"D\"+\"L\"+\"M\"+\"_\",n=t.split(e);if(!(n.length<2)){var r=n[0],o=n[1];if(!(r.split(\".\").length-1<1))return{jURL:r,eURL:o}}}(decodedVal);if(!a)throw new Error(\"failed to parse the value\");var c=a.jURL,u=a.eURL;F=function(t){for(var e=\"\",n=0,r=0;n<20;++n)e+=n%3>0&&r<12?siteId.charAt(r++):Q.id.charAt(n);return t.replace(\"/PRM1\",\"\").replace(\"/PRM2\",\"/main.\").replace(\"/PRM3\",e).replace(\"/PRM4\",\".js\")}(c),window.ftr__altd3=u,t()}catch(t){}}function r(t,n){e&&e(t,n)}if(!U){window.ftr__config.m.dr===\"N\"+\"D\"+\"R\"&&e(new Error(\"N\"+\"D\"+\"R\"),!1),q&&k||e(new Error(\"D\"+\"P\"+\"P\"),!1),U=!0;try{var o=function(t){for(var e=new Uint8Array([0,0]),n=new Uint8Array([1,0]),r=new Uint8Array([0,1]),o=new Uint8Array([0,0]),i=new Uint8Array([0,0]),a=new Uint8Array([0,0]),c=t.split(\".\"),u=[],f=0;f<c.length;f++){var s=c[f];u.push(s.length);for(var d=0;d<s.length;d++)u.push(s.charCodeAt(d))}u.push(0);var h=16,l=new Uint8Array([0,h]),w=new Uint8Array([0,1]),g=new Uint8Array(e.length+n.length+r.length+o.length+i.length+a.length+u.length+l.length+w.length);return g.set(e,0),g.set(n,e.length),g.set(r,e.length+n.length),g.set(o,e.length+n.length+r.length),g.set(i,e.length+n.length+r.length+o.length),g.set(a,e.length+n.length+r.length+o.length+i.length),g.set(u,e.length+n.length+r.length+o.length+i.length+a.length),g.set(l,e.length+n.length+r.length+o.length+i.length+a.length+u.length),g.set(w,e.length+n.length+r.length+o.length+i.length+a.length+u.length+l.length),g}(k);!function(t,e,n,r,o){var i=!1,a=new XMLHttpRequest;if(c(\"https:\"+t,function(){o(new Error(\"CSP Violation\"),!0),i=!0}),\"//\"===t.slice(0,2)&&(t=\"https:\"+t),\"withCredentials\"in a)a.open(\"POST\",t,!0);else{if(\"undefined\"==typeof XDomainRequest)return;a=new XDomainRequest,a.open(\"POST\",t)}a.responseType=\"arraybuffer\",a.setRequestHeader(\"Content-Type\",e),a.onload=function(){\"function\"==typeof r&&r(a)},a.onerror=function(t){if(\"function\"==typeof o&&!i)try{o(t,!1),i=!0}catch(t){}},a.onprogress=function(){},a.ontimeout=function(){\"function\"==typeof o&&o(\"tim\"+\"eo\"+\"ut\",!1)},setTimeout(function(){a.send(n)},0)}(q,\"application/dns-message\",o,n,r)}catch(t){e(t,!1)}}};var nt=O?X.uFP:X.uDF;tt(nt),setTimeout(w,N,nt)}catch(t){r(X.mLd)}}catch(t){}})();</script>";
							_scr += "<!-- END FORTER SCRIPTS -->";
							
							bodyele.append(_scr);
						}	
					}
				}	
				
				String eleEnv = "";
				eles = doc.select("meta[name=etn:eleenv]");
				if(eles != null && eles.size() > 0)
				{
					eleEnv = parseNull(eles.first().attr("content"));
				}

				String htmlfilename = "";
				String htmlFilePath = "";
				boolean useWebmasterUrl = false;
				eles = doc.select("meta[name=etn:eleurl]");
				if(eles != null && eles.size() > 0)
				{				
					htmlfilename = parseNull(eles.first().attr("content"));
					htmlfilename = removeAccents(htmlfilename);
					if(htmlfilename.indexOf("/") > -1)
					{
						htmlFilePath = htmlfilename.substring(0, htmlfilename.lastIndexOf("/")) + "/";
						htmlfilename = (htmlfilename.substring(htmlfilename.lastIndexOf("/"))).replace("/","");	
					}
					useWebmasterUrl = true;
				}	

				//test environment url added in production environment so we should not use webmaster url otherwise 
				//test environment page will over-write prod page
				if(bIsProd && eleEnv.equals("T"))
				{
					htmlfilename = "";
					useWebmasterUrl = false;
				}
				
				if(htmlfilename.length() == 0)
				{	
					useWebmasterUrl = false;
					eles = doc.select("meta[name=etn:pname]");
					if(eles != null && eles.size() > 0)
					{						
						htmlfilename = parseNull(eles.first().attr("content"));
					}				
					else if(htmlfilename.length() == 0)
					{
						htmlfilename = sub_page_type_level3;
					}
					//if no url is provided by webmaster we use the old logic to save files
					htmlFilePath = getFolderId(Etn, domain) + getLocalPath(Etn, originalurl);
					if(htmlfilename.trim().length() > 0) 
					{
						//using better function to remove accents
						htmlfilename = removeAccents(parseNull(htmlfilename));
						htmlfilename = htmlfilename.replaceAll("[^\\w\\s]","").replaceAll("[^\\p{IsAlphabetic}\\p{Digit}]", "-");
					}
				}

				htmlfilename = parseNull(htmlfilename).toLowerCase();
				htmlFilePath = parseNull(htmlFilePath).toLowerCase();
				
				Logger.debug("process.jsp"," htmlFilePath : " + htmlFilePath);
				Logger.debug("process.jsp"," htmlfilename : " + htmlfilename);

				String[] dynamicUrls = parseNull(GlobalParm.getParm("DYNAMIC_PAGES")).split(";");
				boolean isDynamicPage = false;
				if(dynamicUrls != null)
				{
					for(String dyn : dynamicUrls)
					{
						if(parseNull(dyn).length() == 0) continue;
						if(url.startsWith(dyn)) 
						{
							isDynamicPage = true;
							break;
						}
					}
				}
			
				//String _relativecachedpath = cacheFolder + getFolderId(Etn, domain) + getLocalPath(Etn, originalurl);
				String _relativecachedpath = cacheFolder + htmlFilePath;
				//if(useWebmasterUrl) _relativecachedpath = cacheFolder + htmlFilePath;
				Logger.debug("process.jsp","--"+prodlogtxt+" _relativecachedpath : "+ _relativecachedpath);	
				Cacher c = new Cacher(domain, eurl, Etn, originalBaseDir, response.getContentType(), failedurls, recacheurls, menuid, applicableruleid, htmlfilename, true, request, isDynamicPage, false, binternalcall, _relativecachedpath, sub_page_type_level3, useWebmasterUrl, htmlFilePath, currentMenuPath, cacheFolder);
				String _savefilename = c.cache();	

				String sendredirectlink = currentMenuPath;
				//When the crawler is calling urls then we are going to create pages in a separate folder so that the site itself is not disturbed so we return redirect link for that
				if(binternalcall && enableseparatefoldercaching)
				{
					sendredirectlink = publisherSendRedirectLink;
				}
				else if("1".equals(___isErr))
				{
					sendredirectlink = sitemapSendRedirectLink;
				}
				else if(bsitemapcall)
				{
					sendredirectlink = sitemapSendRedirectLink;
				}

				String cachedpageid = c.getCachedPageId();
				org.jsoup.nodes.Element headele = doc.select("head").first();
				if(headele != null)
				{ 
					headele.append("<meta name=\"pr:cid\" content=\""+cachedpageid+"\">");		
					headele.append("<meta name=\"pr:cuid\" content=\""+c.getCachedPageUuid()+"\">");
					String _cisprod = "T";
					if(bIsProd) _cisprod = "P";
					headele.append("<meta name=\"pr:cenv\" content=\""+_cisprod+"\">");		
					headele.append("<meta name=\"pr:clang\" content=\""+mlang+"\">");
					headele.append("<meta name=\"pr:version\" content=\""+GlobalParm.getParm("APP_VERSION")+"\">");
					if(bIsProd)
					{
						org.jsoup.select.Elements _algEle = doc.select("meta[name=alg:objectid]");
						if(_algEle == null || _algEle.size() == 0)
						{
							headele.append("<meta name=\"alg:objectid\" content=\""+cachedpageid+"\">");		
						}
					}
				}
				else
				{
					String _cisprod = "T";
					String _algObjectId = "";
					if(bIsProd)
					{
						_cisprod = "P";
						org.jsoup.select.Elements _algEle = doc.select("meta[name=alg:objectid]");
						if(_algEle == null || _algEle.size() == 0)
						{
							_algObjectId = "<meta name=\"alg:objectid\" content=\""+cachedpageid+"\">";
						}
					}
					doc.prepend("<head><meta name=\"pr:cid\" content=\""+cachedpageid+"\"><meta name=\"pr:cuid\" content=\""+c.getCachedPageUuid()+"\"><meta name=\"pr:cenv\" content=\""+_cisprod+"\"><meta name=\"pr:clang\" content=\""+mlang+"\"><meta name=\"pr:version\" content=\""+GlobalParm.getParm("APP_VERSION")+"\">"+_algObjectId+"</head>");
				}

				String _path = sendredirectlink + htmlFilePath + java.net.URLEncoder.encode(_savefilename,"utf-8");
				if(addscript && headele != null)
				{
					//remove trailing / from domain
					String sitedomain2 = sitedomain;
					if(sitedomain2.endsWith("/")) sitedomain2 = sitedomain2.substring(0, sitedomain2.lastIndexOf("/"));
		
					String ogurl = currentMenuPath + htmlFilePath + java.net.URLEncoder.encode(_savefilename, "utf-8");
					String _scr = "";

					_scr += "<meta property='og:url' content='"+sitedomain2+escapeCoteValue(ogurl)+"' />";

					_scr += "<meta property='og:locale' content='"+escapeCoteValue(mlanglocale)+"' />";
					while(allLangs.next())
					{
						_scr += "<meta property='og:locale:alternate' content='"+escapeCoteValue(parseNull(allLangs.value("og_local")))+"' />";
					}

					//adding domain to og:image and twitter:image
					org.jsoup.select.Elements ogImageEles = doc.select("meta[property=og:image]");
					if(ogImageEles != null && ogImageEles.size() > 0) 
					{	
						String __u1 = ogImageEles.first().attr("content");
						if(parseNull(__u1).length() > 0)
						{
							__u1 = sitedomain2 + __u1;
							ogImageEles.first().attr("content", __u1);
						}
					}

					ogImageEles = doc.select("meta[name=twitter:image]");
					if(ogImageEles != null && ogImageEles.size() > 0) 
					{	
						String __u1 = ogImageEles.first().attr("content");
						if(parseNull(__u1).length() > 0)
						{
							__u1 = sitedomain2 + __u1;
							ogImageEles.first().attr("content", __u1);
						}
					}

					ogImageEles = doc.select("meta[name=etn:eleimage]");
					if(ogImageEles != null && ogImageEles.size() > 0) 
					{	
						String __u1 = ogImageEles.first().attr("content");
						if(parseNull(__u1).length() > 0)
						{
							__u1 = sitedomain2 + __u1;
							ogImageEles.first().attr("content", __u1);
						}
					}

					_scr += "<meta property='fb:app_id' content='"+escapeCoteValue(facebookappid)+"' />";
					_scr += "<meta property='og:site_name' content='"+escapeCoteValue(websiteName)+"' />";
					_scr += "<meta name='twitter:url' content='"+sitedomain2+escapeCoteValue(ogurl)+"' />";
					_scr += "<meta name='twitter:site' content='"+escapeCoteValue(twitteraccount)+"' />";

					org.jsoup.select.Elements finalPageTitle = doc.select("title");
					if(finalPageTitle != null && finalPageTitle.size() > 0)
					{
						org.jsoup.nodes.Element tpele = finalPageTitle.first();
						_scr += "<meta name='twitter:title' content='"+escapeCoteValue(parseNull(tpele.html()))+"' />";
						_scr += "<meta property='og:title' content='"+escapeCoteValue(parseNull(tpele.html()))+"' />";


						org.jsoup.select.Elements mtitles = doc.select("meta[name=title]");
						if(mtitles != null && mtitles.size() > 0) mtitles.first().remove();
						_scr += "<meta name='title' content='"+escapeCoteValue(parseNull(tpele.html()))+"' />";						
					}


					if(_scr.length() > 0) headele.prepend(_scr);
				}

				contents = doc.outerHtml();
				if(isDynamicPage) 
				{
					//function defined in countryspecific/commonmethods.jsp
					contents = specialProcessing(contents, originalurl);	
				} 

				c.saveFileToDisk(contents, _savefilename);
				response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
				response.setHeader("X-Frame-Options","deny");
				response.setHeader("Location", _path);

				return;
			}//end else if ishtml
			else
			{
				isProcessed = true;
				String localpath = getLocalPath(Etn, url);	
				String localfile = getLocalFilename(url);
				List<Resource> resourceurls = getResourceUrlsFromString(contents);
				downloadUrls(Etn, url, eurl, domain, originalBaseDir, resourceurls, request, rextensions, failedurls, true);
				anytimeout = getTimeout(anytimeout, resourceurls);
				contents = fixUrls(Etn, url, domain, localbaseurl, contents, resourceurls, rextensions, true, menuid);
			}

			//in-case of resources we have to download them and then redirect to their path
			if(!isProcessed)//download resource
			{
				ResourcePath _rp = getResourcePath(Etn, url, false);
				String _localpath = _rp.path;
				String _localfile = _rp.file;
				_localfile = _localfile.toLowerCase();
				downloadResourceFromUrl(Etn, domain, url, basedir, request, true);

				String sendredirectlink = currentMenuPath;
				//When the crawler is calling urls then we are going to create pages in a separate folder so that the site itself is not disturbed so we return redirect link for that
				if(binternalcall && enableseparatefoldercaching)
				{
					sendredirectlink = getMenuPathFor(Etn, menuid, "PUBLISHER_SEND_REDIRECT_LINK");
				}			
				else if("1".equals(___isErr))
				{
					sendredirectlink = getMenuPathFor(Etn, menuid, "SITEMAP_SEND_REDIRECT_LINK");
				}
				else if(bsitemapcall)
				{
					sendredirectlink = getMenuPathFor(Etn, menuid, "SITEMAP_SEND_REDIRECT_LINK");
				}

				String _relativecachedpath = cacheFolder + getFolderId(Etn, domain) + _localpath;
				String _path = sendredirectlink + getFolderId(Etn, domain) + _localpath + java.net.URLEncoder.encode(_localfile,"utf-8");

				Logger.debug("process.jsp","--"+prodlogtxt+" _relativecachedpath : "+ _relativecachedpath);
				Logger.debug("process.jsp","--"+prodlogtxt+" _path : "+ _path);
				Cacher c = new Cacher(domain, eurl, Etn, originalBaseDir, response.getContentType(), new ArrayList<String>(), new ArrayList<String>(), menuid, applicableruleid, _localfile, false, request, false, true, binternalcall, _relativecachedpath, "", false, "", currentMenuPath, cacheFolder);
				c.cache();

				response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
				response.setHeader("Location", _path);
				return;
			}
			else
			{
				String filePath = getFolderId(Etn, domain) + getLocalPath(Etn, url);
				String _relativecachedpath = cacheFolder + filePath;

				Logger.debug("process.jsp","--"+prodlogtxt+" _relativecachedpath : "+ _relativecachedpath);
				Cacher c = new Cacher(domain, eurl, Etn, originalBaseDir, response.getContentType(), failedurls, recacheurls, menuid, applicableruleid, "", false, request, false, false, binternalcall, _relativecachedpath, "", resourceFileExtension, filePath, currentMenuPath, cacheFolder);
				String _savefilename = c.cache();				
				out.write(contents);
				c.saveFileToDisk(contents, _savefilename);
//				Logger.debug("process.jsp","************************"+prodlogtxt+"content type " + response.getContentType() );
			}
		}	
		catch(org.apache.http.conn.ConnectTimeoutException e)
		{
			out.write("Connection timeout with host server");
			e.printStackTrace();
		}
		catch(Exception e) { e.printStackTrace(); }
	}
%> 