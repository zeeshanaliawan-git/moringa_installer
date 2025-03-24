<%!
	/*
	* This function will check which js files we don't want to cache. The param NO_CACHE_JS can have a path in which all js files will not be cached.
	* Or it can have path of a specific js file which will be ignored. 
	*/
	boolean ignoreJs(String u)
	{
		String[] ignoreJsFiles = parseNull(com.etn.beans.app.GlobalParm.getParm("NO_CACHE_JS")).split(";");

		boolean ignoreJs = false;
		if(ignoreJsFiles != null && ignoreJsFiles.length > 0)
		{
			for(String ijf : ignoreJsFiles)
			{
				if(parseNull(ijf).length() == 0) continue;
				if(u.contains(parseNull(ijf))) 
				{
					ignoreJs = true;//we are not going to process this file and leave it ... and not going to make it absolute path otherwise it will change to 127.0.0.1
					break;
				}						
			}	
		}
		return ignoreJs;
	}

	/*
	* This function will check which js files we will cache but we will not process those. With Process it means we will not change any URLs inside it to go through cache system.
	* When we process a js file we check for all ajax calls, window.location, window.location.href etc and change the URLs to go through our function parseUrlForAjax. That function actually makes it go 
	* through the cache system. The param NO_PROCESS_JS can have a path in which all js files will not be cached. Or it can have path of a specific js file which will not be processed. 
	* Example of such file is sharebar.js in which we have to make ajax calls from client machine to the facebook, twitter etc and don't want to put load on our server to make all those through cache
	*/
	boolean noProcessJs(String u)
	{
		if(u.length() == 0) return false;
		if(u.startsWith("http://127.0.0.1/")) 
		{
			com.etn.util.Logger.info("JS is a local resource so dont process it : " + u);
			return true;
		}
		String[] ignoreJsFiles = parseNull(com.etn.beans.app.GlobalParm.getParm("NO_PROCESS_JS")).split(";");

		boolean ignoreJs = false;
		if(ignoreJsFiles != null && ignoreJsFiles.length > 0)
		{
			for(String ijf : ignoreJsFiles)
			{
				if(parseNull(ijf).length() == 0) continue;
				if(u.contains(parseNull(ijf))) 
				{
					ignoreJs = true;//we are not going to process this file and leave it ... and not going to make it absolute path otherwise it will change to 127.0.0.1
					break;
				}						
			}	
		}	

		return ignoreJs;
	}

	String getUrlForLoop(String u)
	{
		if(u == null || u.trim().length() == 0) return "";		
		u = u.trim();
		
		String externallink = com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK");
		if(u.indexOf(externallink) > -1)
		{
			u = u.substring(u.indexOf(externallink));
		}

		return u;
	}

	boolean aLoopingUrl(String u)
	{
		if(u == null || u.trim().length() == 0) return false;
		String originalUrl = u;
		u = u.trim();
		boolean isloop = false;

		String externallink = com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK");

		if(u.toLowerCase().startsWith("http://") || u.toLowerCase().startsWith("https://"))
		{
			if(u.toLowerCase().startsWith("http://")) u = u.substring(7);
			else if(u.toLowerCase().startsWith("https://")) u = u.substring(8);
		
			if(u.indexOf("/") > -1) u = u.substring(u.indexOf("/"));
		} 

		if(u.startsWith(externallink + "process.jsp")) isloop = true;

		com.etn.util.Logger.debug("countryspecific/commonmethods.jsp",originalUrl + " **** isloop : " + isloop);
		return isloop;
	}

	boolean encodeUrl(String u, java.util.List<String> allmenupaths)
	{
		if(u == null || u.trim().length() == 0) return false;
		u = u.trim();

		//every country have its own list of ignoreThem urls ... not putting this in config in case we need to ignore another url we dont have to restart tomcat
		String ignoreThem = parseNull(com.etn.util.AppConfig.getConfig("ignore_urls_for_encode"));


		boolean encodeUrl = true;
		String[] ignoreUrls = ignoreThem.split(";");
		if(ignoreUrls != null)
		{
			for(String iurl : ignoreUrls)
			{
				if(iurl.trim().length() == 0) continue;
				if(u.toLowerCase().startsWith(iurl.toLowerCase()))
				{
					encodeUrl = false;
					break;
				} 
			}
		}

		//here give names of sites so that if any url of .html is coming in which is a cached page then we dont have to encode it again
		//this case can only happen when crawler is crawling the site and it reaches a 404 page of main site which already has .html links so we have to ignore all those
		if(encodeUrl)
		{
			String urlstart = "http://127.0.0.1";
			for(String ss : allmenupaths)
			{
				if(u.toLowerCase().startsWith(urlstart+ss)) 
				{
					encodeUrl = false;
					break;
				}
			}
		}
		
		//check if it is a looping url then dont encode it again
		if(encodeUrl && aLoopingUrl(u)) encodeUrl = false;		

		return encodeUrl;
	}

	boolean isCompatible(javax.servlet.http.HttpServletRequest request, String url)
	{
		if(url != null && (url.trim().endsWith("countryspecific/noncompatible.jsp") || url.trim().endsWith(".png") || url.trim().endsWith(".jpg"))) return true;

		boolean iscompatible = true;
		//check page compatibility .. if IE browsers other than IE 9 we have to give error
		String userAgent = parseNull(request.getHeader("user-agent")).toLowerCase();
		if(userAgent.indexOf("msie") > -1)
		{
			iscompatible = false;
			String browser = userAgent.substring(userAgent.indexOf("msie") + 4);
			if(browser.indexOf(";") > -1) 
			{
				browser = browser.substring(0, browser.indexOf(";"));
				double ieVersion = Double.parseDouble(browser.trim());
				if(ieVersion > 9) {
					iscompatible = true;
				}					
			}
		}
		return iscompatible;
	}

	//this if for dynamic pages if for any country we require anything special to be done
	String handleSpecialCases(String contents, String url)
	{
		return contents;
	}

	//this if for dynamic pages if for any country we require anything special to be done
	String specialProcessing(String contents, String url)
	{
		return contents;
	}

	//this if for dynamic pages if for any country we require anything special to be done
	org.jsoup.nodes.Document addDependencyScripts(org.jsoup.nodes.Document doc, String url)
	{
		return doc;
	}

	String encrypt(String txt) throws Exception
	{
		String key = com.etn.beans.app.GlobalParm.getParm("ORANGE_PASSWORD_PHRASE");
		java.security.Key aesKey = new javax.crypto.spec.SecretKeySpec(key.getBytes(), "AES");
		javax.crypto.Cipher cipher = javax.crypto.Cipher.getInstance("AES/CBC/PKCS5Padding");
		byte[] iv = new byte[cipher.getBlockSize()];

		javax.crypto.spec.IvParameterSpec ivparams = new javax.crypto.spec.IvParameterSpec(iv);
	  	// encrypt the text
		cipher.init(javax.crypto.Cipher.ENCRYPT_MODE, aesKey, ivparams);
       	byte[] encrypted = cipher.doFinal(txt.getBytes("UTF8"));

		return new sun.misc.BASE64Encoder().encode(encrypted);
	}

	String decrypt(String txt) throws Exception
	{ 
		String key = com.etn.beans.app.GlobalParm.getParm("ORANGE_PASSWORD_PHRASE");
		java.security.Key aesKey = new javax.crypto.spec.SecretKeySpec(key.getBytes(), "AES");
		javax.crypto.Cipher cipher = javax.crypto.Cipher.getInstance("AES/CBC/PKCS5Padding");
		byte[] iv = new byte[cipher.getBlockSize()];
		javax.crypto.spec.IvParameterSpec ivparams = new javax.crypto.spec.IvParameterSpec(iv);
	
	  	// encrypt the text
		cipher.init(javax.crypto.Cipher.DECRYPT_MODE, aesKey, ivparams);
       	byte[] dec = new sun.misc.BASE64Decoder().decodeBuffer(txt);

		byte[] utf8 = cipher.doFinal(dec);
		return new String(utf8, "UTF8");

	}

	String getDefaultMenuId(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request)
	{
		String menuid = "";
		
		String originator = "";
		if(request.getAttribute("javax.servlet.error.request_uri") != null) originator = parseNull((String)request.getAttribute("javax.servlet.error.request_uri"));

		String proxyprefix = parseNull(com.etn.beans.app.GlobalParm.getParm("PROXY_PREFIX"));
		originator = originator.replace(proxyprefix, "");
			
		if(originator.length() > 0 && !originator.equals("/"))
		{
			if(!originator.startsWith("/")) originator = "/" + originator;
			originator = request.getServerName().toLowerCase() + originator;
			
			String sendredirect = parseNull(com.etn.beans.app.GlobalParm.getParm("SEND_REDIRECT_LINK"));
			if(!sendredirect.endsWith("/")) sendredirect += "/";
			
			//we order by with bigger paths descending order so that we match the most relevant path .. if a menu has path /fr and other has /fr2 and originator is starting with /fr2 
			//descending order will make sure /fr2 is matched rather /fr which is wrong
			com.etn.lang.ResultSet.Set rs2 = Etn.execute("select m.id, s.domain, concat("+escape.cote(sendredirect)+", m.production_path) as mpath "+
						" from sites s, site_menus m where m.site_id = s.id and m.is_active = 1 and coalesce(m.production_path,'') <> '' "+
						" order by length(s.domain) desc, length(m.production_path) desc");
			while(rs2.next())
			{
				String domain = parseNull(rs2.value("domain")).toLowerCase();
				domain = domain.replace("http://","").replace("https://","");
				String mpath = domain + parseNull(rs2.value("mpath"));

				if(originator.startsWith(mpath))
				{
					menuid = rs2.value("id");
					break;
				}				
			}
		}

		if(menuid.length() == 0 || "0".equals(menuid))
		{
			menuid = parseNull(com.etn.asimina.session.PortalSession.getInstance().getParameter(Etn, request, "MENU_ID_LOADED"));
		}		

		if(menuid.length() == 0 || "0".equals(menuid))
		{
			String _cookie = request.getHeader("cookie");
			Cookie[] _cookies = request.getCookies();
			if(_cookies != null) 
			{
	       		for (Cookie cookie : _cookies) 
				{ 
					if(cookie.getName().equals("_stat_muid")) 
					{
						String menu_uuid = cookie.getValue();
						com.etn.lang.ResultSet.Set __rs = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(menu_uuid));
						if(__rs.next()) menuid = __rs.value("id");
					}
				}
			}
		}

		if(menuid.length() == 0 || "0".equals(menuid))
		{
			com.etn.util.Logger.debug("countryspecific/commonmethods.jsp","getting default menu for domain " + request.getServerName().toLowerCase());

			//just setting a big number 100000 for ordering purpose
			com.etn.lang.ResultSet.Set _rs = Etn.execute("select s.id, case when m2.is_active = 1 then s.default_menu_id else 100000 end as default_menu_id, m.id as menuid "+
							" from sites s left outer join site_menus m2 on m2.id = s.default_menu_id, site_menus m "+
							" where s.id = m.site_id and m.is_active = 1 "+
							" and s.domain like "+com.etn.sql.escape.cote("http://"+request.getServerName().toLowerCase()+"%")+" or s.domain like "+com.etn.sql.escape.cote("https://"+request.getServerName().toLowerCase()+"%")+
							" order by default_menu_id, s.id, m.id " );
			if(_rs.next())
			{
				menuid = parseNull(_rs.value("default_menu_id"));
				if(menuid.length() == 0 || "100000".equals(menuid))//100000 is returned when the default_menu_id is not active any more 
				{
					//no default menu was selected for this domain then we use the first one
					menuid = parseNull(_rs.value("menuid"));
				}
			}				
		}	

		if(menuid.length() == 0 || "0".equals(menuid))
		{
			//get first menu id of all sites
			com.etn.lang.ResultSet.Set _rs = Etn.execute("select s.id, m.id as menuid from sites s, site_menus m where s.id = m.site_id and m.is_active = 1 order by s.id, m.id " );
			if(_rs.next())
			{
				menuid = _rs.value("menuid");
			}
		}	

		com.etn.util.Logger.info("countryspecific/commonmethods.jsp","Menu id found is : " + menuid);
		return menuid;
	}

	String getErrorPage(com.etn.beans.Contexte Etn, String menuid) throws Exception
	{ 
		String url404 = "";
		com.etn.lang.ResultSet.Set rs = Etn.execute("select * from site_menus where id = " + escape.cote(menuid));
		if(rs.next())
		{
			String cachedId = parseNull(rs.value("published_404_cached_id"));
			if(cachedId.length() > 0)
			{
				com.etn.lang.ResultSet.Set rs2 = Etn.execute("Select cpp.file_path, cp.filename from cached_pages_path cpp, cached_pages cp where cp.id = cpp.id and cp.id = " + escape.cote(cachedId));
				if(rs2.next())
				{
					url404 = parseNull(rs2.value("file_path")) + parseNull(rs2.value("filename"));
					if(url404.length() > 0) url404 = com.etn.beans.app.GlobalParm.getParm("LOCAL_LINK") + com.etn.beans.app.GlobalParm.getParm("DOWNLOAD_PAGES_FOLDER") + url404;
				}
			}
			
		}
		
		if(url404.length() == 0)
		{
			String pname = "404.jsp";
		
			String encUrl = com.etn.util.Base64.encode((com.etn.beans.app.GlobalParm.getParm("LOCAL_LINK")+"countryspecific/"+pname).getBytes("UTF-8"));
			url404 = com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___isErr=1&___mid="+com.etn.util.Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+encUrl;
		}
		return url404;
	}

	org.jsoup.nodes.Document get404PageHtml(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, String menuid) throws Exception
	{
		String basicauthvalue = "";
		java.util.Enumeration<String> headerNames = request.getHeaderNames();
		while (headerNames.hasMoreElements()) {
			String headerName = headerNames.nextElement();
			System.out.println(headerName);
			if(headerName.equalsIgnoreCase("authorization")) 
			{
				basicauthvalue  = request.getHeader(headerName);
				break;
			}			
		}
		
		String url404 = getErrorPage(Etn, menuid);
		if(!url404.startsWith("http://127.0.0.1")) url404 = "http://127.0.0.1" + url404;
		return org.jsoup.Jsoup.connect(url404).header("Authorization", basicauthvalue  ).get();
	}
	
	String getDefaultLanguage(com.etn.beans.Contexte Etn)
	{
		com.etn.lang.ResultSet.Set rs = Etn.execute("Select * from language order by langue_id limit 1");
		if(rs.next()) return rs.value("langue_code");
		return "";
	}
%>