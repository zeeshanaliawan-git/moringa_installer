package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.KeyStore;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Properties;
import java.io.File;
import java.net.URLConnection;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;
import org.json.*;


public class ApiCaller {
	
	private ClientSql Etn;
	private Properties env;
	private boolean isProd;
	private String applicationName = "shop_engine";
	private int wkid;
	private String clid;
	
	public ApiCaller(ClientSql Etn, Properties env)
	{
		this.Etn = Etn;
		this.env = env;
		this.isProd = "1".equals(env.getProperty("IS_PROD_SHOP"));
		if(isProd) applicationName = "prodshop_engine";
	}
	
	public void setWkid(int wkid)
	{
		this.wkid = wkid;
	}
	
	public void setClid(String clid)
	{
		this.clid = clid;
	}
	
	private void buildMultiPartRequest(HttpURLConnection htp, Map<String, List<String>> fields, Map<String, List<File>> files, Map<String, String> requestHeaders) throws Exception
	{
		log("build MultiPartRequest");
		OutputStream o = null;
		try
		{
			String LINE_FEED = "\r\n";
			String charset = "utf-8";
			
			if(requestHeaders != null)
			{
				for(String keyString : requestHeaders.keySet())
				{
					if(isProd == false)
					{
						log("Setting header:"+keyString+":"+requestHeaders.get(keyString));
					}
					htp.setRequestProperty(keyString, requestHeaders.get(keyString));
				}
			}
			
			String boundary = "========" + System.currentTimeMillis() + "========";
			htp.setUseCaches(false);
			htp.setDoOutput(true); // indicates POST method
			htp.setDoInput(true);
			htp.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

			htp.connect();
			o = htp.getOutputStream();
			
			if(fields != null && fields.size() > 0)
			{
				
				for(String name : fields.keySet())
				{
					List<String> values = fields.get(name);
					if(values != null)
					{
						for(String value : values)
						{
							StringBuilder sb = new StringBuilder();
							
							sb.append("--" + boundary).append(LINE_FEED);
							sb.append("Content-Disposition: form-data; name=\"" + name + "\"").append(LINE_FEED);
							sb.append("Content-Type: text/plain; charset=" + charset).append(LINE_FEED);
							sb.append(LINE_FEED);
							sb.append(value).append(LINE_FEED);
							//log(sb.toString());
							o.write(sb.toString().getBytes("UTF-8"));
						}
					}
				}
			}
			
			if(files != null && files.size() > 0)
			{
				for(String fieldName : files.keySet())
				{
					List<File> fs = files.get(fieldName);
					if(fs != null)
					{
						for(File f : fs)
						{
							StringBuilder sb = new StringBuilder();
							
							log(fieldName + " : " +f.getName() + " :" + URLConnection.guessContentTypeFromName(f.getName()));
							sb.append("--" + boundary).append(LINE_FEED);
							sb.append("Content-Disposition: form-data; name=\"" + fieldName+ "\"; filename=\"" + f.getName() + "\"").append(LINE_FEED);
							sb.append("Content-Type: "+ URLConnection.guessContentTypeFromName(f.getName())).append(LINE_FEED);
							sb.append("Content-Transfer-Encoding: binary").append(LINE_FEED);
							sb.append(LINE_FEED);
			
							o.write(sb.toString().getBytes("UTF-8"));

							FileInputStream inputStream = null;
							try
							{
								inputStream = new FileInputStream(f);
								byte[] buffer = new byte[4096];
								int bytesRead = -1;
								while ((bytesRead = inputStream.read(buffer)) != -1) {
									o.write(buffer, 0, bytesRead);
								}
								o.flush();

								sb = new StringBuilder();
								sb.append(LINE_FEED);
								o.write(sb.toString().getBytes("UTF-8"));
								
							}
							finally
							{
								if(inputStream != null) inputStream.close();
							}

						}
					}
				}
			}			
			StringBuilder sb = new StringBuilder();
			sb.append("--" + boundary);
			o.write(sb.toString().getBytes("UTF-8"));
		}
		finally
		{
			if(o != null) o.close();
		}
	}
	
	private void buildRequest(HttpURLConnection htp, String method, String params, Map<String, String> requestHeaders) throws Exception
	{
		log("build Request");
		OutputStream o = null;
		try
		{
			log("Method:"+method);
			log("request body:"+Util.parseNull(params));
			
			htp.setConnectTimeout(30000);
			htp.setRequestMethod(method.toUpperCase());
			
			if(requestHeaders != null)
			{
				for(String keyString : requestHeaders.keySet())
				{
					if(isProd == false)
					{
						log("Setting header:"+keyString+":"+requestHeaders.get(keyString));
					}
					htp.setRequestProperty(keyString, requestHeaders.get(keyString));
				}
			}
			
			if(("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method)) && Util.parseNull(params).length() > 0)
			{	
				byte b[] = params.getBytes("UTF-8");
				htp.setRequestProperty("Content-Length",""+b.length);
				htp.setDoInput(true);
				htp.setDoOutput(true);
				htp.setUseCaches(false);
				
				htp.connect();
				o = htp.getOutputStream();
				o.write(b);
			}			
		}
		finally
		{
			if(o != null) o.close();
		}
	}
	
	private java.net.Proxy getProxy(boolean useProxy)
	{
		if(useProxy == false) 
		{
			log("getProxy useProxy is false");
			return null;
		}

		String proxyhost = Util.parseNull(env.getProperty("HTTP_PROXY_HOST"));
		String proxyport = Util.parseNull(env.getProperty("HTTP_PROXY_PORT"));
		final String proxyuser = Util.parseNull(env.getProperty("HTTP_PROXY_USER"));
		final String proxypasswd = Util.parseNull(env.getProperty("HTTP_PROXY_PASSWD"));
		
		java.net.Proxy proxy = null;
		if(proxyhost.length() > 0 )
		{
			log("Open connection using proxy");
			proxy = new java.net.Proxy(java.net.Proxy.Type.HTTP, new java.net.InetSocketAddress (proxyhost, Integer.parseInt(proxyport)));			

			if(proxyuser.length() > 0)
			{
				java.net.Authenticator authenticator = new java.net.Authenticator() {
					public java.net.PasswordAuthentication getPasswordAuthentication() {
						return (new java.net.PasswordAuthentication(proxyuser, proxypasswd.toCharArray()));
					}
				};
				java.net.Authenticator.setDefault(authenticator);
			}
		}
		return proxy;		
	}
	
	private HttpsURLConnection openConnectionHttps(URL url, boolean useProxy) throws Exception
	{		
		HttpsURLConnection htps = null;
		
		java.net.Proxy proxy = getProxy(useProxy);
		if(proxy != null)
		{
			log("Open connection using proxy");
			htps = (HttpsURLConnection) url.openConnection(proxy);
		}
		else 
		{
			log("Open connection without proxy");
			htps = (HttpsURLConnection) url.openConnection();
		}
		
		return htps;
	}
	
	private HttpURLConnection openConnectionHttp(URL url, boolean useProxy) throws Exception
	{
		HttpURLConnection htp = null;
		java.net.Proxy proxy = getProxy(useProxy);
		if(proxy != null)
		{
			log("Open connection using proxy");
			htp = (HttpURLConnection) url.openConnection(proxy);
		}
		else 
		{
			log("Open connection without proxy");
			htp = (HttpURLConnection) url.openConnection();
		}
		
		return htp;
	}
	
	public JSONObject callApi(String procedureName, String apiEndpoint, String method, String params, Map<String, String> requestHeaders) throws Exception
	{
		return callApi(procedureName, apiEndpoint, method, params, requestHeaders, "", "", "", true);
	}
	
	public JSONObject callApi(String procedureName, String apiEndpoint, String method, String params, Map<String, String> requestHeaders, boolean useProxy) throws Exception
	{
		return callApi(procedureName, apiEndpoint, method, params, requestHeaders, "", "", "", useProxy);
	}
	
	public JSONObject callApi(String procedureName, String apiEndpoint, String method, String params, Map<String, String> requestHeaders, String KEYSTORE_PATH, String KEYSTORE_PASSWORD, String KEYSTORE_TYPE) throws Exception
	{
		return callApi(procedureName, apiEndpoint, method, params, requestHeaders, KEYSTORE_PATH, KEYSTORE_PASSWORD, KEYSTORE_TYPE, true);
	}
	
	public JSONObject callApi(String procedureName, String apiEndpoint, String method, String params, Map<String, String> requestHeaders, String KEYSTORE_PATH, String KEYSTORE_PASSWORD, String KEYSTORE_TYPE, boolean useProxy) throws Exception
	{
		return callApi(procedureName, apiEndpoint, method, params, requestHeaders, KEYSTORE_PATH, KEYSTORE_PASSWORD, KEYSTORE_TYPE, useProxy, false, null, null);
	}
	
	public JSONObject callApiMultipart(String procedureName, String apiEndpoint, Map<String, List<String>> fields, Map<String, List<File>> files, Map<String, String> requestHeaders) throws Exception
	{
		return callApiMultipart(procedureName, apiEndpoint, fields, files, requestHeaders, "", "", "", true);
	}
	
	public JSONObject callApiMultipart(String procedureName, String apiEndpoint,Map<String, List<String>> fields, Map<String, List<File>> files, Map<String, String> requestHeaders, boolean useProxy) throws Exception
	{
		return callApiMultipart(procedureName, apiEndpoint, fields, files, requestHeaders, "", "", "", useProxy);
	}
	
	public JSONObject callApiMultipart(String procedureName, String apiEndpoint,Map<String, List<String>> fields, Map<String, List<File>> files, Map<String, String> requestHeaders, String KEYSTORE_PATH, String KEYSTORE_PASSWORD, String KEYSTORE_TYPE) throws Exception
	{
		return callApiMultipart(procedureName, apiEndpoint, fields, files, requestHeaders, KEYSTORE_PATH, KEYSTORE_PASSWORD, KEYSTORE_TYPE, true);
	}
	
	public JSONObject callApiMultipart(String procedureName, String apiEndpoint,Map<String, List<String>> fields, Map<String, List<File>> files, Map<String, String> requestHeaders, String KEYSTORE_PATH, String KEYSTORE_PASSWORD, String KEYSTORE_TYPE, boolean useProxy) throws Exception
	{
		return callApi(procedureName, apiEndpoint, "POST", null, requestHeaders, KEYSTORE_PATH, KEYSTORE_PASSWORD, KEYSTORE_TYPE, useProxy, true, fields, files);
	}
	
	private JSONObject callApi(String procedureName, String apiEndpoint, String method, String params, Map<String, String> requestHeaders, String KEYSTORE_PATH, String KEYSTORE_PASSWORD, String KEYSTORE_TYPE, boolean useProxy, boolean isMultiPart, Map<String, List<String>> fields, Map<String, List<File>> files) throws Exception
	{
		HttpURLConnection htp = null;
		HttpsURLConnection htps = null;
		JSONObject jResp = null;
		BufferedReader reader = null;
		InputStreamReader isReader = null;
		int responseCode = 0;
		String responseCharset = "";
		long startTime = 0;
		long endTime = 0;
		
		String responseContentType = "";
		try
		{	
			log("Start : " + getTime());
			log("Calling url : " + apiEndpoint);
			URL url = new URL(apiEndpoint);
						
			if(Util.parseNull(KEYSTORE_PATH).length() > 0)
			{
				//we have locally placed the certificate so we have to load it
				FileInputStream truststoreFile = new FileInputStream(KEYSTORE_PATH);
				TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
				KeyStore truststore = KeyStore.getInstance("JKS");
				truststore.load(truststoreFile, (KEYSTORE_PASSWORD).toCharArray());
				trustManagerFactory.init(truststore);
				SSLContext sc = SSLContext.getInstance("SSL");
				sc.init(null, trustManagerFactory.getTrustManagers(), new java.security.SecureRandom()); 			

				startTime = System.currentTimeMillis();
				
				htps = openConnectionHttps(url, useProxy);
				htps.setSSLSocketFactory(sc.getSocketFactory());
								
				if(isMultiPart) buildMultiPartRequest(htps, fields, files, requestHeaders);
				else buildRequest(htps, method, params, requestHeaders);

				responseCode = htps.getResponseCode();
				responseCharset = Util.getCharset(Util.parseNull(htps.getContentType()));	
				
				if(responseCode >= 200 && responseCode <= 299) 
				{
					isReader = new InputStreamReader(htps.getInputStream(), responseCharset);
				}			
				else 
				{
					isReader = new InputStreamReader(htps.getErrorStream(), responseCharset);
				}
				responseContentType = Util.parseNull(htps.getHeaderField("Content-Type"));
				endTime = System.currentTimeMillis();
			}
			else
			{
				startTime = System.currentTimeMillis();
				
				htp = openConnectionHttp(url, useProxy);
				
				if(isMultiPart) buildMultiPartRequest(htp, fields, files, requestHeaders);
				else buildRequest(htp, method, params, requestHeaders);
				
				responseCode = htp.getResponseCode();
				responseCharset = Util.getCharset(Util.parseNull(htp.getContentType()));	

				if(responseCode >= 200 && responseCode <= 299) 
				{
					isReader = new InputStreamReader(htp.getInputStream(), responseCharset);
				}			
				else 
				{
					isReader = new InputStreamReader(htp.getErrorStream(), responseCharset);
				}
				responseContentType = Util.parseNull(htp.getHeaderField("Content-Type"));
				endTime = System.currentTimeMillis();
			}
						
			jResp = new JSONObject();			
			jResp.put("http_code", responseCode);
			jResp.put("response_content_type", responseContentType);

			reader = new BufferedReader(isReader);
			
			if(responseCode >= 200 && responseCode <= 299) 
			{
                jResp.put("status", 0);
            }			
			else 
			{
                jResp.put("status", responseCode);
			}

			StringBuffer sb = new StringBuffer();	
			String inputLine;
			while ((inputLine = reader.readLine()) != null) {
				sb.append(inputLine);
			}
			jResp.put("response", sb.toString());
			
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".api_action_logs (wkid, clid, appl_name, procedure_name, api_url, request_method, request_body, api_response, http_code, api_env, response_time) "+
				" value ("+escape.cote(""+this.wkid)+", "+escape.cote(this.clid)+", "+escape.cote(applicationName)+", "+escape.cote(procedureName)+", "+escape.cote(apiEndpoint)+", "+escape.cote(method)+", "+escape.cote(Util.parseNull(params))+", "+escape.cote(sb.toString())+", "+escape.cote(responseCode+"")+", "+escape.cote((isProd?"prod":"test"))+", "+escape.cote(""+(endTime - startTime))+") ");
		}
		catch(Exception e)
		{
			endTime = System.currentTimeMillis();
			Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".api_action_logs (wkid, clid, appl_name, procedure_name, api_url, request_method, request_body, api_response, http_code, api_env, response_time) "+
				" value ("+escape.cote(""+this.wkid)+", "+escape.cote(this.clid)+", "+escape.cote(applicationName)+", "+escape.cote(procedureName)+", "+escape.cote(apiEndpoint)+", "+escape.cote(method)+", "+escape.cote(Util.parseNull(params))+", "+escape.cote(e.getMessage())+", "+escape.cote(responseCode+"")+", "+escape.cote((isProd?"prod":"test"))+", "+escape.cote(""+(endTime - startTime))+") ");
				
			e.printStackTrace();
			throw e;
		}
		finally
		{
			if(reader != null) reader.close();
			if(isReader != null) isReader.close();
			if(htp != null) htp.disconnect();
			if(htps != null) htps.disconnect();
			
			log("End : " + getTime());
		}		
		log(jResp.toString());
		return jResp;		
	}

	public void addLogEntry(String procedureName, String msg)
	{
		Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".api_action_logs (wkid, clid, appl_name, procedure_name, api_env, msg) "+
			" value ("+escape.cote(""+this.wkid)+", "+escape.cote(this.clid)+", "+escape.cote(applicationName)+", "+escape.cote(procedureName)+", "+escape.cote(isProd?"prod":"test")+", "+escape.cote(msg)+") ");
	}

	private void log(String m)
	{
		System.out.println("ApiCaller::" + m);
	}

	private void logE(String m)
	{
		System.out.println("ApiCaller::ERROR::" + m);
	}	

	private String getTime()
	{ 
		return( com.etn.util.ItsDate.getWith(System.currentTimeMillis(),true) ); 
	}
}