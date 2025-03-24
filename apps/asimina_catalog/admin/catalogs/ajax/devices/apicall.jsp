<%!
	class MyResponse
	{
		String json;
		int status;
	}

	MyResponse callApi(String prms, String action)
	{
		String username = com.etn.beans.app.GlobalParm.getParm("PHONES_DIRECTORY_USER");
		String pass = com.etn.beans.app.GlobalParm.getParm("PHONES_DIRECTORY_PASSWORD");
		String countryid = com.etn.beans.app.GlobalParm.getParm("PHONES_DIRECTORY_COUNTRY_ID");
		String url = com.etn.beans.app.GlobalParm.getParm("PHONES_DIRECTORY_API_URL");

		String proxyhost = com.etn.beans.app.GlobalParm.getParm("HTTP_PROXY_HOST");
		String proxyport = com.etn.beans.app.GlobalParm.getParm("HTTP_PROXY_PORT");
		final String proxyuser = com.etn.beans.app.GlobalParm.getParm("HTTP_PROXY_USER");
		final String proxypasswd = com.etn.beans.app.GlobalParm.getParm("HTTP_PROXY_PASSWD");


		if("fetchall".equals(action)) url = url + "fetchdevices.jsp";
		else if("fetch".equals(action)) url = url + "fetchdevice.jsp";
		else if("requestDevice".equals(action)) url = url + "requestdevice.jsp";

		java.net.HttpURLConnection c = null;
		MyResponse myresp = null;
		try
		{			
			String auth = "Basic "+ com.etn.util.Base64.encode((username+":"+pass).getBytes("UTF-8"));

			java.net.URL u = new java.net.URL(url);
			if(proxyhost != null && proxyhost.trim().length() > 0 )
			{
				java.net.Proxy proxy = new java.net.Proxy(java.net.Proxy.Type.HTTP, new java.net.InetSocketAddress (proxyhost, Integer.parseInt(proxyport)));			

				if(proxyuser != null && proxyuser.trim().length() > 0)
				{
					//System.out.println(url + " : " +proxyhost + " : " + proxyport + " : " + proxyuser + " : " + proxypasswd);
					java.net.Authenticator authenticator = new java.net.Authenticator() {
						public java.net.PasswordAuthentication getPasswordAuthentication() {
							return (new java.net.PasswordAuthentication(proxyuser, proxypasswd.toCharArray()));
						}
					};
					java.net.Authenticator.setDefault(authenticator);
				}

				c = (java.net.HttpURLConnection) u.openConnection(proxy);
			}
			else c = (java.net.HttpURLConnection) u.openConnection();

			byte[] params = null;			
			if(prms != null && prms.length() > 0)
			{
				params = prms.getBytes("UTF-8");
			}

			c.setRequestMethod("POST");
			if(params != null) c.setRequestProperty("Content-length", ""+params.length);
			c.setDoOutput(true);
			c.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			c.setRequestProperty("Authorization", auth);	
			c.setRequestProperty("CountryID", countryid);	
			//c.setRequestProperty("User-Agent", "Mozilla/5.0");
			c.connect();

			java.io.OutputStream os = c.getOutputStream();
			os.write(params);

			int status = c.getResponseCode();			
			//System.out.println("status :: " + status);
			myresp = new MyResponse();
			myresp.status = status;					
			switch (status) 
			{
				case 200:
				case 201:
					java.io.BufferedReader br = new java.io.BufferedReader(new java.io.InputStreamReader(c.getInputStream()));
					StringBuilder sb = new StringBuilder();
					String line;
					while ((line = br.readLine()) != null) 
					{
						sb.append(line+"\n");
					}
					br.close();
					myresp.json = sb.toString();
					break;
				default : myresp.json = "{\"status\":\"error\"}";
			}					
			System.out.println("Directory API url : " + url + " resp code : " + status + " json : " + myresp.json);	
		}
		catch(Exception e) 
		{
			e.printStackTrace();
		}
		finally
		{
			if(c != null) 
			{
				try 
				{
					c.disconnect();
				}
				catch (Exception e) {}
			}	
		}
		return myresp;

	}

	String requestDevice(String brand, String model)
	{
		String country = com.etn.beans.app.GlobalParm.getParm("PHONES_DIRECTORY_COUNTRY");
		String data = "brand="+brand+"&model="+model+"&country="+country;
		MyResponse mr = callApi(data, "requestDevice");
		if(mr == null) return "{\"status\":\"error\",\"msg\":\"Unable to communicate with phones directory api\"}";
		return mr.json;
	}

	String fetchDevices(String brand, String model, String dtype, java.util.List<String> allMigratedDevices, java.util.List<String> siteMigratedDevices)
	{
		String data = "brand="+brand+"&model="+model+"&dtype="+dtype;
		for(String md : allMigratedDevices)
		{
			data += "&migrated_devices=" + md;
		}
		for(String md : siteMigratedDevices)
		{
			data += "&site_migrated_devices=" + md;
		}

		MyResponse mr = callApi(data, "fetchall");		
		if(mr == null) return "{\"status\":\"error\",\"msg\":\"Unable to communicate with phones directory api\"}";
		return mr.json;
	}

	String fetchDevice(String nacode)
	{
		String data = "nacode="+nacode;
		MyResponse mr = callApi(data, "fetch");
		if(mr == null) return "{\"status\":\"error\",\"msg\":\"Unable to communicate with phones directory api\"}";
		return mr.json;
	}
%>

