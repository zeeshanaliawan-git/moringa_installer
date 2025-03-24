<%@ page import="javax.net.ssl.HostnameVerifier, javax.net.ssl.SSLSession, java.io.*, java.util.Enumeration, java.util.Iterator, java.util.Map, java.util.HashMap, java.util.List, java.util.ArrayList , javax.servlet.*, java.util.zip.Inflater "%><%@ page import="javax.servlet.http.*, java.net.URL, java.net.URI, java.net.HttpURLConnection,java.util.zip.GZIPInputStream,java.util.zip.InflaterInputStream "%><%!
	public class MyHostnameVerifier implements HostnameVerifier 
	{
		@Override
		public boolean verify(String hostname, SSLSession ssls) {
			//case where the certificate returned by search.mobinil.com has domain search.ke.voila.fr due to which it was failing
			//we are ignoring certificate for this case
			return true;
		}    
	}

	private org.apache.http.client.protocol.HttpClientContext getLocalContext(HttpServletRequest request)
	{
		org.apache.http.client.protocol.HttpClientContext localContext = null;

		if(request.getSession().getAttribute("localcontext") != null)
		{
			localContext = (org.apache.http.client.protocol.HttpClientContext) request.getSession().getAttribute("localcontext");

/*			org.apache.http.client.CookieStore cookieStore = (org.apache.http.client.CookieStore)localContext.getAttribute(org.apache.http.client.protocol.ClientContext.COOKIE_STORE);
			List<org.apache.http.cookie.Cookie> cookies = cookieStore.getCookies();
			for (int i = 0; i < cookies.size(); i++) {
				System.out.println("getLocalContext :: cookie: " + cookies.get(i));
			}*/
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

	public String processRequest(String url, HttpServletRequest request, HttpServletResponse response, Redirect finalurl, boolean isresourceurl, String menuid) throws Exception
	{
		System.out.println("---------------------- process request -----------------------------");
		System.out.println(url);
		String reqcharset = getRequestCharset(request);

		String method = "GET";
		method = request.getMethod();
		if(method != null && method.indexOf(" ") > -1) method = method.substring(0, method.indexOf(" "));
		else if (method == null || method.trim().length() == 0) method = "GET";
		System.out.println("Method is = " + method);
	
		url = encodeUrlQueryString(url, reqcharset);

		org.apache.http.impl.client.CloseableHttpClient httpClient = null;
		if(isBadDomain(url)) httpClient = org.apache.http.impl.client.HttpClients.custom().setSSLHostnameVerifier(new MyHostnameVerifier()).build();
		else httpClient = org.apache.http.impl.client.HttpClients.createDefault();
	
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
					if(headerName.equalsIgnoreCase("host")) continue;
					//skip this header as apache http version we using do not support brotli
					if(headerName.equalsIgnoreCase("Accept-Encoding")) continue;
//				System.out.println("---- request header : " + headerName + " " + request.getHeader(headerName));
					httpGet.addHeader(headerName,request.getHeader(headerName));
				}
			}
			org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);
			
			httpResponse = httpClient.execute(httpGet, localContext  );

			System.out.println("GET Response Status:: " + httpResponse.getStatusLine().getStatusCode());
			String charset = getCharSet(httpResponse);
			request.getSession().setAttribute("localcontext", localContext);
			setCookies(response, localContext);
			List<URI> redirectLocations = localContext.getRedirectLocations();
			if(redirectLocations != null && redirectLocations.size() > 0) finalurl.url = redirectLocations.get(redirectLocations.size()-1).toASCIIString();
//System.out.println("response charset = " + charset);
				

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
			for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();){
				String headerName = e.nextElement().toString();
				if(headerName.equalsIgnoreCase("host") || headerName.equalsIgnoreCase("content-length")) continue;
				//skip this header as apache http version we using do not support brotli
				if(headerName.equalsIgnoreCase("Accept-Encoding")) continue;				
				httpPost.addHeader(headerName,request.getHeader(headerName));
			}

			if(isjsonxmlrequest)
			{
				org.apache.http.entity.StringEntity se = getDataFromRequest(request, reqcharset);
				httpPost.setEntity(se);
			}

			else
			{
				List<org.apache.http.NameValuePair> urlParameters = new ArrayList<org.apache.http.NameValuePair>();
				for(String key : request.getParameterMap().keySet())
				{
					if(request.getParameterValues("key") != null && request.getParameterValues("key").length > 0)
					{
						for(String pr : request.getParameterValues("key")) 
							urlParameters.add(new org.apache.http.message.BasicNameValuePair(key, pr));
					}
					else urlParameters.add(new org.apache.http.message.BasicNameValuePair(key, request.getParameter(key)));
				}

				org.apache.http.HttpEntity postParams = new org.apache.http.client.entity.UrlEncodedFormEntity(urlParameters);
				httpPost.setEntity(postParams);
			}

			org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);

			httpResponse = httpClient.execute(httpPost, localContext);
			System.out.println("POST Response Status:: " + httpResponse.getStatusLine().getStatusCode());
			request.getSession().setAttribute("localcontext", localContext);
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
		else System.out.println("METHOD NOT SUPPORTED");
		if(httpResponse != null && httpResponse.getAllHeaders() != null)
		{
			for(int h=0; h < httpResponse.getAllHeaders().length; h ++)
			{
				if(httpResponse.getAllHeaders()[h].getName().equalsIgnoreCase("Content-Type")) 
				{
					System.out.println(httpResponse.getAllHeaders()[h].getName() + " " + httpResponse.getAllHeaders()[h].getValue());
					response.setHeader(httpResponse.getAllHeaders()[h].getName(), httpResponse.getAllHeaders()[h].getValue());
				}
				else if(httpResponse.getAllHeaders()[h].getName().equalsIgnoreCase("location"))
				{
					System.out.println(httpResponse.getAllHeaders()[h].getName() + " " + httpResponse.getAllHeaders()[h].getValue());
					String _location = getAbsoluteUrl(url, httpResponse.getAllHeaders()[h].getValue()); 					
//					response.setHeader(httpResponse.getAllHeaders()[h].getName(), com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu=" + Base64.encode((_location).getBytes("UTF-8")));
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
			System.out.println("---- xml/json " + data);
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
		String charset = "utf-8";
		if(request.getHeader("Content-Type") != null)
		{
			charset = request.getHeader("Content-Type");
			if(charset.indexOf("charset=") > -1)
				charset = charset.substring(charset.indexOf("charset=") + 8);
			if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
		}
//		System.out.println("--------- request charset = " + charset);
		return charset.trim();
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
					System.out.println(httpResponse.getAllHeaders()[h].getName() + " " + httpResponse.getAllHeaders()[h].getValue());
					charset = httpResponse.getAllHeaders()[h].getValue().substring(httpResponse.getAllHeaders()[h].getValue().indexOf("charset=") + 8);
					if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
					break;
				}
			}
		}
		System.out.println("--------- response charset = " + charset);
		return charset.trim();
	}

	String escapeUrl(String url) throws Exception
	{
		if(!url.contains(" ")) return url;
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
//System.out.println("http = " + http + " host = " + host + " path = " + path + " port = " + port);
		URI u = null;
		if(port.length() > 0)  u = new URI(http, null, host, Integer.parseInt(port), path, null, null);
		else u = new URI(http, host, path, null);
//System.out.println(u.toURL().toString());
		return u.toURL().toString();
	}

	public String encodeUrlQueryString(String url, String charset) throws Exception
	{
		if(url.indexOf("?") > -1 && url.indexOf("?") < (url.length() - 1))
		{
			String u1 = url.substring(0, url.indexOf("?")+1);
			String u2 = url.substring(url.indexOf("?") + 1);
			if(u2.trim().length() > 0)
			{
				String[] ps = u2.split("&");
				u2 = "";
				for(int i=0; i<ps.length; i++)
				{
					if(i > 0) u2 += "&";
					String[] ps2 = ps[i].split("=");
					if(ps2 != null && ps2.length >= 2) u2 += ps2[0] + "=" + java.net.URLEncoder.encode(ps2[1],charset);
					else u2 += ps[i];
				}
			}
			u1 = escapeUrl(u1);
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
		String reqcharset = getRequestCharset(request);
		url = encodeUrlQueryString(url, reqcharset);

		org.apache.http.impl.client.CloseableHttpClient httpClient = null;
		if(isBadDomain(url)) httpClient = org.apache.http.impl.client.HttpClients.custom().setSSLHostnameVerifier(new MyHostnameVerifier()).build();
		else httpClient = org.apache.http.impl.client.HttpClients.createDefault();

		org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);

		org.apache.http.client.methods.HttpGet httpGet = new org.apache.http.client.methods.HttpGet(url);

		for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();)
		{
			String headerName = e.nextElement().toString();
			if(!headerName.equalsIgnoreCase("user-agent")) continue;
			httpGet.addHeader(headerName,request.getHeader(headerName));
		}
		org.apache.http.client.methods.CloseableHttpResponse httpResponse = httpClient.execute(httpGet,localContext );

//		System.out.println("--------- downloadResource : " + url  + " "  + httpResponse.getStatusLine().getStatusCode());
		request.getSession().setAttribute("localcontext", localContext);

		respcode = httpResponse.getStatusLine().getStatusCode() ;
		if(respcode == 404) return respcode;

		FileOutputStream fout = null;
		BufferedReader reader = null;

		try
		{		
			File dir = new File(basedir + fpath);
			if(!dir.exists()) createDirectories(basedir, fpath);
			fout = new FileOutputStream (basedir + fpath + fname);

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
			System.out.println( basedir  + " : " + fpath + " : " + fname);

			e.printStackTrace();
			throw e;
		}
		catch(Exception e)
		{
			System.out.println("******************** " + basedir  + " : " + fpath + " : " + fname);
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


	//this writes img/pdf etc to response stream
	public void loadResource(String url, HttpServletRequest request, HttpServletResponse response) throws Exception
	{
		String reqcharset = getRequestCharset(request);
		url = encodeUrlQueryString(url, reqcharset);
//		System.out.println("------- " + url);

		org.apache.http.impl.client.CloseableHttpClient httpClient = null;
		if(isBadDomain(url)) httpClient = org.apache.http.impl.client.HttpClients.custom().setSSLHostnameVerifier(new MyHostnameVerifier()).build();
		else httpClient = org.apache.http.impl.client.HttpClients.createDefault();

		org.apache.http.client.protocol.HttpClientContext localContext = getLocalContext(request);

		org.apache.http.client.methods.HttpGet httpGet = new org.apache.http.client.methods.HttpGet(url);
		for( Enumeration e = request.getHeaderNames() ; e.hasMoreElements();)
		{
			String headerName = e.nextElement().toString();
			if(headerName.equalsIgnoreCase("host")) continue;
			httpGet.addHeader(headerName,request.getHeader(headerName));
		}
   
		org.apache.http.client.methods.CloseableHttpResponse httpResponse = httpClient.execute(httpGet,localContext );

		request.getSession().setAttribute("localcontext", localContext);

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
			File f = new File(basedir + path);
//			System.out.println(".............. "  + basedir + path);
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

	String getAbsoluteUrl(String mainurl, String url) throws Exception
	{
		if(url.toLowerCase().startsWith("https://") || url.toLowerCase().startsWith("http://")) return url;
		URL baseUrl = new URL(mainurl);
		URL nurl = new URL( baseUrl , url);
			
		return nurl.toString();
	}
%>