<%@ page import="javax.net.ssl.HostnameVerifier, javax.net.ssl.SSLSession, java.io.*, java.util.Enumeration, java.util.Iterator, java.util.Map, java.util.HashMap, java.util.List, java.util.ArrayList , javax.servlet.*, java.util.zip.Inflater "%><%@ page import="javax.servlet.http.*, java.net.URL, java.net.URI, java.net.HttpURLConnection,java.util.zip.GZIPInputStream,java.util.zip.InflaterInputStream,com.etn.util.FormDataFilter"%><%!

	class Redirect
	{
		String url;
	}

	public class MyHostnameVerifier implements HostnameVerifier 
	{
		@Override
		public boolean verify(String hostname, SSLSession ssls) {
			return true;
		}    
	}

	private org.apache.http.client.protocol.HttpClientContext getLocalContext(HttpServletRequest request)
	{
		org.apache.http.client.protocol.HttpClientContext localContext = null;
		if(request.getSession().getAttribute("localcontext") != null)
		{
			localContext = (org.apache.http.client.protocol.HttpClientContext) request.getSession().getAttribute("localcontext");//dont move this to asimina web session for now
		}
		else localContext = org.apache.http.client.protocol.HttpClientContext.create();
		return localContext ;
	}

	private String getParam(String url, String paramName, String paramValue, String charset) throws Exception
	{
		String p = "";
		if(url.indexOf("?") == 0) p += "?";
		else p += "&";
		p += paramName + "=" + java.net.URLEncoder.encode(paramValue,charset);
		return p;
	}

	private boolean doAppendLanguage(String url)
	{
		boolean appendLang = false;
		String[] urls = parseNull(GlobalParm.getParm("PASS_LANG_URLS")).split(";");
		if(urls != null)
		{
			for(String surl : urls)
			{
				if(url.toLowerCase().startsWith(surl.toLowerCase()))
				{
					appendLang = true;
					break;
				}
			}
		}
		return appendLang;
	}

	private String appendLanguageParam(String url, String lang, String menuVersion)
	{
		//here we are checking if the url already contains the language then we should not add it .. this is just to keep old shops working without breaking as 
		//those have many urls with lang already set
		if(doAppendLanguage(url) && !url.toLowerCase().contains("lang="))
		{
			if(url.indexOf("?") > -1) url += "&lang=" + lang + "&mvrn=" + menuVersion;
			else url += "?lang=" + lang + "&mvrn=" + menuVersion;
		}
//		com.etn.util.Logger.debug("httputils.jsp","///////////////////////////////////// final url after adding the lang = " + url);
		return url;
	}

	private String appendSessionParams(String url, HttpServletRequest request)
	{
		boolean sendSessionParams = false;
		String[] sessionUrls = parseNull(GlobalParm.getParm("SEND_SESSION_PARAMS")).split(";");
		
		if(sessionUrls != null)
		{	
			for(String surls : sessionUrls)
			{
				if(url.toLowerCase().startsWith(surls.toLowerCase()))
				{
					sendSessionParams = true;
					break;
				}
			}
		}

		if(sendSessionParams)
		{
			//we have to see how to handle this as we moved session to asimina web session
			if(request.getSession().getAttributeNames() != null)
			{
				String sessionVariables = "";
				for(Enumeration e = request.getSession().getAttributeNames(); e.hasMoreElements();)
				{
					String prm = e.nextElement().toString();
					if("libelle_msg".equals(prm) || "logintoken".equals(prm)) continue;

					sessionVariables += "___session_" + prm + "=" + request.getSession().getAttribute(prm) + "&";
				}
				if(sessionVariables.length() > 0)
				{
					sessionVariables = sessionVariables.substring(0, sessionVariables.length() - 1);
					if(url.indexOf("?") > -1) url += "&" + sessionVariables;
					else url += "?" + sessionVariables;
				}
			}
		}
		return url;

	} 

	//NOTE::We are not sending the accept-encoding header which we get from request because apache library is not handling broli compression
	//so if accept-encoding has br in it then our request is not processed properly and not cached. 
	public String processRequest(String url, HttpServletRequest request, HttpServletResponse response, Redirect finalurl, boolean isresourceurl, String menuid, String lang, String menuVersion) throws Exception
	{
		com.etn.util.Logger.debug("httputils.jsp","start process request for url : " + url);

		org.apache.http.impl.client.CloseableHttpClient httpClient = getHttpClient();

		String reqcharset = getRequestCharset(request);

		String method = "GET";
		method = request.getMethod();
		if(method != null && method.indexOf(" ") > -1) method = method.substring(0, method.indexOf(" "));
		else if (method == null || method.trim().length() == 0) method = "GET";
		com.etn.util.Logger.debug("httputils.jsp","Method is = " + method);
	
		url = appendSessionParams(url, request);

		if("GET".equalsIgnoreCase(method) && !isresourceurl) url = appendLanguageParam(url, lang, menuVersion);

		url = encodeUrlQueryString(url, reqcharset);
	
		StringBuffer resp = new StringBuffer();
		org.apache.http.client.methods.CloseableHttpResponse httpResponse = null;

		if(isresourceurl) method = "GET";


		if("GET".equalsIgnoreCase(method))
		{
			org.apache.http.client.methods.HttpGet httpGet = new org.apache.http.client.methods.HttpGet(url);

			if(isresourceurl)
			{
				for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();)
				{
					String headerName = e.nextElement().toString();
					if(!headerName.equalsIgnoreCase("user-agent")) continue;
					httpGet.addHeader(headerName,request.getHeader(headerName));
				}
			}
			else
			{
				for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();)
				{
					String headerName = e.nextElement().toString();
					if(headerName.equalsIgnoreCase("host") || headerName.equalsIgnoreCase("accept-encoding")) continue;
//					com.etn.util.Logger.debug("httputils.jsp","---- request header : " + headerName + " " + request.getHeader(headerName));
					httpGet.addHeader(headerName,request.getHeader(headerName));
				}
			}
			org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);
			
			httpResponse = httpClient.execute(httpGet, localContext  );

			com.etn.util.Logger.info("httputils.jsp", url + " GET Response Status:: " + httpResponse.getStatusLine().getStatusCode());
			String charset = getCharSet(httpResponse);
			request.getSession().setAttribute("localcontext", localContext);//we have to see how to handle this as we moved session to asimina web session
			setCookies(response, localContext);
			List<URI> redirectLocations = localContext.getRedirectLocations();
			if(redirectLocations != null && redirectLocations.size() > 0) finalurl.url = redirectLocations.get(redirectLocations.size()-1).toASCIIString();
//com.etn.util.Logger.debug("httputils.jsp","response charset = " + charset);
				

			BufferedReader reader = new BufferedReader(new InputStreamReader(httpResponse.getEntity().getContent(), charset));

			String inputLine;

			while ((inputLine = reader.readLine()) != null) {
				resp.append(inputLine + "\n");
			}
			reader.close();
			httpClient.close();
			response.setStatus(httpResponse.getStatusLine().getStatusCode());
		}
		else if("POST".equalsIgnoreCase(method))
		{
			boolean isjsonxmlrequest = false;
			if(request.getHeader("Content-Type") != null && 
			   (request.getHeader("Content-Type").toLowerCase().contains("application/json") || request.getHeader("Content-Type").toLowerCase().contains("application/xml")))
			{
				isjsonxmlrequest = true;
			}

			org.apache.http.client.methods.HttpPost httpPost = new org.apache.http.client.methods.HttpPost(url);
			for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();)
			{
				String headerName = e.nextElement().toString();
				if(headerName.equalsIgnoreCase("host") || headerName.equalsIgnoreCase("content-length") || headerName.equalsIgnoreCase("accept-encoding")) continue;
				httpPost.addHeader(headerName,request.getHeader(headerName));
			}

			if(isjsonxmlrequest)
			{
				org.apache.http.entity.StringEntity se = getDataFromRequest(request, reqcharset);
				httpPost.setEntity(se);
			}
			else if (request.getHeader("Content-Type") != null && request.getHeader("Content-Type").contains("multipart/form-data"))
			{

				String cnttype= "";
				for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();){
					String headerName = e.nextElement().toString();
					if("content-type".equalsIgnoreCase(headerName)) cnttype = request.getHeader(headerName);
				}

				String bndry = "";
				if(cnttype.indexOf("boundary=") > -1) bndry = cnttype.substring(cnttype.indexOf("boundary=") + "boundary=".length());	
				if(bndry.indexOf(";") > -1) bndry = bndry.substring(0, bndry.indexOf(";"));		

				FormDataFilter formData = new FormDataFilter(request.getInputStream());
				String fieldData[] = new String[3];
				org.apache.http.entity.mime.MultipartEntityBuilder meb = org.apache.http.entity.mime.MultipartEntityBuilder.create().setMode(org.apache.http.entity.mime.HttpMultipartMode.BROWSER_COMPATIBLE).setCharset(java.nio.charset.Charset.forName(reqcharset));
				
				if(bndry.length() > 0) meb.setBoundary(bndry);

				boolean langAlreadyFound = false;

				while((fieldData = formData.getField()) != null)
				{
					if(formData.isStream())
					{	
						//handle the file
					}
					else
					{
						//check if parameter lang is already in the original request body
						if("lang".equals(fieldData[0])) langAlreadyFound = true;			
						meb.addTextBody(fieldData[0], parseNull(fieldData[1]), org.apache.http.entity.ContentType.TEXT_PLAIN);
		       	 	}				
				}
				//we have to pass menu's language in case language is required for the url and is missing
				if(!langAlreadyFound && doAppendLanguage(url)) meb.addTextBody("lang", parseNull(lang), org.apache.http.entity.ContentType.TEXT_PLAIN);
				
				org.apache.http.HttpEntity multipart = meb.build();

				httpPost.setEntity(multipart);

			}
			else
			{
				boolean langAlreadyFound = false;

				List<org.apache.http.NameValuePair> urlParameters = new ArrayList<org.apache.http.NameValuePair>();
				for(String key : request.getParameterMap().keySet())
				{
					//check if parameter lang is already in the original request body
					if("lang".equals(key)) langAlreadyFound = true;			

					if(request.getParameterValues(key) != null && request.getParameterValues(key).length > 0)
					{
						for(String pr : request.getParameterValues(key)) 
							urlParameters.add(new org.apache.http.message.BasicNameValuePair(key, pr));
					}
					else urlParameters.add(new org.apache.http.message.BasicNameValuePair(key, request.getParameter(key)));
				}
				//we have to pass menu's language in case language is required for the url and is missing
				if(!langAlreadyFound && doAppendLanguage(url)) urlParameters.add(new org.apache.http.message.BasicNameValuePair("lang", parseNull(lang)));

				org.apache.http.HttpEntity postParams = new org.apache.http.client.entity.UrlEncodedFormEntity(urlParameters, getRequestCharset(request));
				httpPost.setEntity(postParams);
			}

			org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);

			httpResponse = httpClient.execute(httpPost, localContext);
			com.etn.util.Logger.debug("httputils.jsp","POST Response Status:: " + httpResponse.getStatusLine().getStatusCode());
			request.getSession().setAttribute("localcontext", localContext);//we have to see how to handle this as we moved session to asimina web session
			setCookies(response, localContext);
			String charset = getCharSet(httpResponse);
		
			//redirects in post must not be done automatic .. it might requires user input so we will not capture any redirects for post
/*			List<URI> redirectLocations = localContext.getRedirectLocations();
			if(redirectLocations != null && redirectLocations.size() > 0) 
			{
				finalurl.url = redirectLocations.get(redirectLocations.size()-1).toASCIIString();
			}*/

			BufferedReader reader = new BufferedReader(new InputStreamReader(httpResponse.getEntity().getContent(), charset));
			String inputLine;
			while ((inputLine = reader.readLine()) != null) {
				resp.append(inputLine + "\n");
			}
			reader.close();
			httpClient.close();
			response.setStatus(httpResponse.getStatusLine().getStatusCode());
		}
		else com.etn.util.Logger.error("httputils.jsp","METHOD NOT SUPPORTED");
		if(httpResponse != null && httpResponse.getAllHeaders() != null)
		{
			for(int h=0; h < httpResponse.getAllHeaders().length; h ++)
			{
				if(httpResponse.getAllHeaders()[h].getName().equalsIgnoreCase("Content-Type")) 
				{
					com.etn.util.Logger.debug("httputils.jsp",httpResponse.getAllHeaders()[h].getName() + " " + httpResponse.getAllHeaders()[h].getValue());
					response.setHeader(httpResponse.getAllHeaders()[h].getName(), httpResponse.getAllHeaders()[h].getValue());
				}
				else if(httpResponse.getAllHeaders()[h].getName().equalsIgnoreCase("location"))
				{
					com.etn.util.Logger.debug("httputils.jsp",httpResponse.getAllHeaders()[h].getName() + " " + httpResponse.getAllHeaders()[h].getValue());
					String _location = getAbsoluteUrl(url, httpResponse.getAllHeaders()[h].getValue()); 					
					response.setHeader(httpResponse.getAllHeaders()[h].getName(), com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+com.etn.util.Base64.encode(menuid.getBytes("UTF-8"))+"&___mu=" + com.etn.util.Base64.encode((_location).getBytes("UTF-8")));
				}
			}
		} 
	
		return resp.toString().trim();
    	}

	private org.apache.http.entity.StringEntity getDataFromRequest(HttpServletRequest request, String charset)
	{
		InputStream in = null;
		org.apache.http.entity.StringEntity se = null;
		try
		{
			in = request.getInputStream();
			String data = "";
			int bytesRead = -1;
			int length=1024;
			byte[] buffer = new byte[length];
			while ((bytesRead = in.read(buffer)) != -1) {
				data += new String(buffer, 0, bytesRead);
			}
			com.etn.util.Logger.debug("httputils.jsp","---- xml/json " + data);
			se = new org.apache.http.entity.StringEntity(data, charset);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return se;
	}

	private String getRequestCharset(HttpServletRequest request)
	{
		/*String charset = "utf-8";
		if(request.getHeader("Content-Type") != null)
		{
			charset = request.getHeader("Content-Type");
			if(charset.indexOf("charset=") > -1)
				charset = charset.substring(charset.indexOf("charset=") + 8);
			if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
		}
//		com.etn.util.Logger.debug("httputils.jsp","--------- request charset = " + charset);
		return charset.trim();*/
		String charset = "utf-8";
		if(parseNull(request.getCharacterEncoding()).length() > 0) charset = parseNull(request.getCharacterEncoding());
//		com.etn.util.Logger.debug("httputils.jsp","--------- request charset = " + charset);
		return charset;
	}

	private String getCharSet(org.apache.http.client.methods.CloseableHttpResponse httpResponse)
	{
		String charset = "utf-8";
		if(httpResponse != null && httpResponse.getAllHeaders() != null)
		{
			for(int h=0; h < httpResponse.getAllHeaders().length; h ++)
			{
				if(httpResponse.getAllHeaders()[h].getName().equalsIgnoreCase("content-type") && httpResponse.getAllHeaders()[h].getValue().indexOf("charset=") > -1)
				{
					com.etn.util.Logger.debug("httputils.jsp",httpResponse.getAllHeaders()[h].getName() + " " + httpResponse.getAllHeaders()[h].getValue());
					charset = httpResponse.getAllHeaders()[h].getValue().substring(httpResponse.getAllHeaders()[h].getValue().indexOf("charset=") + 8);
					if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
					break;
				}
			}
		}
		com.etn.util.Logger.debug("httputils.jsp","--------- response charset = " + charset);
		return charset.replaceAll("\"","").trim();
	}

	/**
	* This function will replace all special characters in the URI part
	*/
	String escapeUrl(String url) throws Exception
	{
		String http = "http";
		if(url.startsWith("https:")) http = "https";
	
		url = url.substring(url.indexOf(http + "://") + (http + "://").length());
		String host = url;
		String port = "";
		String path = "";
		if(url.indexOf("/") > -1) 
		{
			host = url.substring(0, url.indexOf("/"));
			if(host.indexOf(":") > -1) 
			{
				port = host.substring(host.indexOf(":") + 1);
				host = host.substring(0, host.indexOf(":"));
			}
			
			path = url.substring(url.indexOf("/") );
		}	
		
		com.etn.util.Logger.debug("httputils.jsp","http = " + http + " host = " + host + " path = " + path + " port = " + port);
		URI u = null;
		if(port.length() > 0)  u = new URI(http, null, host, Integer.parseInt(port), path, null, null);
		else u = new URI(http, host, path, null);
		com.etn.util.Logger.debug("httputils.jsp",u.toURL().toString()); 
		return u.toURL().toString();
	}

	/*
	* This function separate outs query string from the actual uri and then encodes each part separately
	*/
	public String encodeUrlQueryString(String url, String charset) throws Exception
	{
		if(url.indexOf("?") > -1)
		{
			String u1 = url.substring(0, url.indexOf("?"));			
			u1 = escapeUrl(u1);
			//there can be case where url has ? but no parameters after it so we do substring starting from ? and not starting from index of ? + 1 .. u2 will always have ? as starting char
			String u2 = url.substring(url.indexOf("?"));
			
			if(u2.trim().length() > 1)//u2 will always have ? in it so minimum length of u2 is 1
			{
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
						u2 += _pr + "=" + java.net.URLEncoder.encode(_prv,charset);
					}
				}
				
				u2 = "?" + u2;
			}
						
			url = u1 + u2;
		}
		else 
		{
			url = escapeUrl(url);
		}	

		return url;
	}	

	public int downloadResource(String url, String basedir, String fpath, String fname, HttpServletRequest request) throws org.apache.http.conn.ConnectTimeoutException, Exception
	{
		int respcode = 0;

		FileOutputStream fout = null;
		BufferedReader reader = null;
		
		org.apache.http.impl.client.CloseableHttpClient httpClient = null;

		try
		{		
			httpClient = getHttpClient();
			String reqcharset = getRequestCharset(request);
			url = encodeUrlQueryString(url, reqcharset);

			org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);

			org.apache.http.client.methods.HttpGet httpGet = new org.apache.http.client.methods.HttpGet(url);

			for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();)
			{
				String headerName = e.nextElement().toString();
				if(!headerName.equalsIgnoreCase("user-agent")) continue;
				httpGet.addHeader(headerName,request.getHeader(headerName));
			}
			org.apache.http.client.methods.CloseableHttpResponse httpResponse = httpClient.execute(httpGet,localContext );

//		com.etn.util.Logger.debug("httputils.jsp","--------- downloadResource : " + url  + " "  + httpResponse.getStatusLine().getStatusCode());
			request.getSession().setAttribute("localcontext", localContext);//we have to see how to handle this as we moved session to asimina web session

			respcode = httpResponse.getStatusLine().getStatusCode() ;
			if(respcode == 404) return respcode;
			com.etn.util.Logger.debug("Download url : " + url + " : " + getContentType(httpResponse));			
			if(getContentType(httpResponse).toLowerCase().startsWith("text/html"))
			{
				com.etn.util.Logger.error("httputils.jsp","We are expecting a resource file to be downloaded but getting a html response. This could be an error. Do not save file and return 404");
				com.etn.util.Logger.error("httputils.jsp","URL : "  + url);
				return 404;
			}

			File dir = new File((basedir + fpath));
			if(!dir.exists()) createDirectories(basedir, fpath);

			fout = new FileOutputStream ((basedir + fpath + fname));

			int bytesRead = -1;
      		     	byte[] buffer = new byte[1024];
			InputStream in = httpResponse.getEntity().getContent();
			while ((bytesRead = in.read(buffer)) != -1) {
				fout.write(buffer, 0, bytesRead);
			}
			fout.flush();
		}
		catch(org.apache.http.conn.ConnectTimeoutException e)
		{
			com.etn.util.Logger.debug("httputils.jsp", basedir  + " : " + fpath + " : " + fname);

			e.printStackTrace();
			throw e;
		}
		catch(Exception e)
		{
			com.etn.util.Logger.debug("httputils.jsp","******************** " + basedir  + " : " + fpath + " : " + fname);
//			e.printStackTrace();
			throw e;
		}
		finally
		{
			if(fout != null) try { fout.close(); } catch (Exception e) {}
			if(reader != null) try { reader.close(); } catch (Exception e) {}
			if(httpClient != null) httpClient.close();
		}		
		return respcode;
	}

	private String getContentType(org.apache.http.client.methods.CloseableHttpResponse httpResponse)
	{
		if(httpResponse == null) return "";
		
		if(httpResponse.getAllHeaders() != null)
		{
			for(int h=0; h < httpResponse.getAllHeaders().length; h ++)
			{
				if(httpResponse.getAllHeaders()[h].getName().equalsIgnoreCase("Content-Type")) 
				{
					return httpResponse.getAllHeaders()[h].getValue();
				}
			}	
		}
		return "";
 	}

	//this writes img/pdf etc to response stream
	public void loadResource(String url, HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		org.apache.http.impl.client.CloseableHttpClient httpClient = getHttpClient();

		String reqcharset = getRequestCharset(request);
		url = encodeUrlQueryString(url, reqcharset);
//		com.etn.util.Logger.debug("httputils.jsp","------- " + url);


		org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);

		org.apache.http.client.methods.HttpGet httpGet = new org.apache.http.client.methods.HttpGet(url);
		for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();)
		{
			String headerName = e.nextElement().toString();
			if(headerName.equalsIgnoreCase("host") || headerName.equalsIgnoreCase("accept-encoding")) continue;
			httpGet.addHeader(headerName,request.getHeader(headerName));
		}
   
		org.apache.http.client.methods.CloseableHttpResponse httpResponse = httpClient.execute(httpGet,localContext );

		request.getSession().setAttribute("localcontext", localContext);//we have to see how to handle this as we moved session to asimina web session

//		BufferedInputStream input = null;
//		BufferedOutputStream output = null;
		InputStream input = null;
		OutputStream output = null;
		int bytesRead = -1;
		int buffer_size = 1024;

		try
		{
			if(httpResponse != null)
			{
				if(httpResponse.getAllHeaders() != null)
				{
					for(int h=0; h < httpResponse.getAllHeaders().length; h ++)
					{
						if(httpResponse.getAllHeaders()[h].getName().equalsIgnoreCase("Content-Type")) 
						{
							response.setHeader(httpResponse.getAllHeaders()[h].getName(), httpResponse.getAllHeaders()[h].getValue());
						}
					}	
				}
//				input = new BufferedInputStream(httpResponse.getEntity().getContent(), buffer_size);
//       		     	output = new BufferedOutputStream(response.getOutputStream(), buffer_size);

				if(httpResponse.getEntity() != null)
				{
					input = httpResponse.getEntity().getContent();
       			     	output = response.getOutputStream();
					byte[] buffer = new byte[buffer_size];
					while ((bytesRead = input.read(buffer)) > 0) {
                				output.write(buffer, 0, bytesRead);
		            		}
				}
			}

		}
		catch(Exception ex)
		{
			throw ex;
		}
		finally 
		{
			try { if(output != null) output.close(); if(input !=null) input.close(); if(httpClient != null) httpClient.close(); } catch(Exception ex){}
		}	
	}
	private void createDirectories(String basedir, String fpath)  throws Exception
	{
		String[] ds = fpath.split("/");
		String path = "";
		for(String d : ds)
		{
			if(path.length() == 0) path = d;
			else path += "/" + d;
			File f = new File((basedir + path));
//			com.etn.util.Logger.debug("httputils.jsp",".............. "  + basedir + path);
			try {
				if(!f.exists()) f.mkdir();
			} catch(Exception e) { e.printStackTrace(); }
		}
	}
	String getDomain(String url)
	{
		String domain = url;
		if(domain.toLowerCase().indexOf("https://") > -1) domain = domain.substring(domain.toLowerCase().indexOf("https:") + 8);
		else if(domain.toLowerCase().indexOf("http://") > -1) domain = domain.substring(domain.toLowerCase().indexOf("http:") + 7);

		if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));
		return domain.trim();
	}
	private boolean isBadDomain(String url)
	{	
		String d = getDomain(url);
		if(d.equalsIgnoreCase("search.mobinil.com")) return true;
		return false; 
	}
	private void setCookies(HttpServletResponse response, org.apache.http.client.protocol.HttpClientContext localContext)
	{
		org.apache.http.client.CookieStore cookieStore = (org.apache.http.client.CookieStore)localContext.getAttribute(org.apache.http.client.protocol.ClientContext.COOKIE_STORE);
		if(cookieStore.getCookies() != null)
		{
			for (int i = 0; i < cookieStore.getCookies().size(); i++) 
			{	
				javax.servlet.http.Cookie cookie = new javax.servlet.http.Cookie(cookieStore.getCookies().get(i).getName(), cookieStore.getCookies().get(i).getValue());
				cookie.setComment(cookieStore.getCookies().get(i).getComment());
				cookie.setDomain(cookieStore.getCookies().get(i).getDomain());
				cookie.setPath(cookieStore.getCookies().get(i).getPath());
				cookie.setSecure(cookieStore.getCookies().get(i).isSecure());
	
				if(cookieStore.getCookies().get(i).getExpiryDate() != null)
					cookie.setMaxAge((int)(((new java.util.Date()).getTime()-(cookieStore.getCookies().get(i).getExpiryDate()).getTime())/1000));

				response.addCookie(cookie);
			}
		}
	}

	private org.apache.http.impl.client.CloseableHttpClient getHttpClient() throws Exception
	{

		org.apache.http.conn.ssl.SSLContextBuilder builder = new org.apache.http.conn.ssl.SSLContextBuilder();
		builder.loadTrustMaterial(null, new org.apache.http.conn.ssl.TrustSelfSignedStrategy());
		org.apache.http.conn.ssl.SSLConnectionSocketFactory sslsf = new org.apache.http.conn.ssl.SSLConnectionSocketFactory(builder.build());
		org.apache.http.impl.client.CloseableHttpClient httpClient = org.apache.http.impl.client.HttpClients.custom().setSSLSocketFactory(sslsf).build();

		return httpClient;
	}

	public String doOrangeLogin(String url, HttpServletRequest request, HttpServletResponse response, Map<String, String> urlParams) throws Exception
	{
		org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);

		org.apache.http.impl.client.CloseableHttpClient httpClient = getHttpClient();
		
		org.apache.http.client.methods.HttpPost httpPost = new org.apache.http.client.methods.HttpPost(url);
		for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();){
			String headerName = e.nextElement().toString();
			if(headerName.equalsIgnoreCase("host") || headerName.equalsIgnoreCase("content-length") || headerName.equalsIgnoreCase("accept-encoding")) continue;
			httpPost.addHeader(headerName,request.getHeader(headerName));
		}

		List<org.apache.http.NameValuePair> urlParameters = new ArrayList<org.apache.http.NameValuePair>();
		for(String mk : urlParams.keySet())
		{
			urlParameters.add(new org.apache.http.message.BasicNameValuePair(mk, urlParams.get(mk)));
		}

		org.apache.http.HttpEntity postParams = new org.apache.http.client.entity.UrlEncodedFormEntity(urlParameters, getRequestCharset(request));
		httpPost.setEntity(postParams);

		org.apache.http.client.methods.CloseableHttpResponse httpResponse = httpClient.execute(httpPost, localContext);
		com.etn.util.Logger.debug("httputils.jsp","POST Response Status:: " + httpResponse.getStatusLine().getStatusCode());
		request.getSession().setAttribute("localcontext", localContext);//we have to see how to handle this as we moved session to asimina web session
		setCookies(response, localContext);

		String charset = getCharSet(httpResponse);
		
		StringBuffer resp = new StringBuffer();

		BufferedReader reader = new BufferedReader(new InputStreamReader(httpResponse.getEntity().getContent(), charset));
		String inputLine;
		while ((inputLine = reader.readLine()) != null) {
			resp.append(inputLine + "\n");
		}
		reader.close();
		httpClient.close();
//		response.setStatus(httpResponse.getStatusLine().getStatusCode());
		return resp.toString();
	}

%>