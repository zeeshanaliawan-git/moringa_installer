<%!
	org.json.JSONObject verifyUserAuth(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, String muid) throws Exception 
	{
		String isLoggedIn = "0";
		String isLoggedInAsSuperUser = "0";

		String clientid = "";
		String cuid= "";
		String cname = "";
		String name = "";
		String surname = "";
		String homepage = "";

		com.etn.util.Logger.info("clientcommon.jsp","---------------------------------------------");
		com.etn.util.Logger.info("clientcommon.jsp","verifyUserAuth::"+request.getSession().getId());
		com.etn.util.Logger.info("clientcommon.jsp","---------------------------------------------");
		String profilId = "";
		org.json.JSONObject additionalInfo = null;
		String avatar = "";

		com.etn.lang.ResultSet.Set rsM = Etn.execute("select s.id, s.site_auth_enabled,m.lang from site_menus m, sites s where m.site_id = s.id and m.menu_uuid = " + com.etn.sql.escape.cote(muid));
		rsM.next();

		//not checking if logged-in user is of same site because we are not supporting this for the time-being
		//com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request, muid);
		com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
		
		if(client != null)
		{
			isLoggedIn = "1";
			if("1".equals(client.getProperty("is_super_user"))) isLoggedInAsSuperUser = "1";
			clientid = client.getProperty("id");
			cuid = parseNull(client.getProperty("client_uuid"));
			cname = parseNull(client.getProperty("name")) + " " + parseNull(client.getProperty("surname"));
			name = parseNull(client.getProperty("name"));
			surname = parseNull(client.getProperty("surname"));
			avatar = parseNull(client.getProperty("avatar"));			
			profilId = parseNull(client.getProperty("client_profil_id"));			
			try {
				additionalInfo = new org.json.JSONObject(parseNull(client.getProperty("additional_info")));
			} catch(Exception e) { }
		}
		else
		{
			String siteid = rsM.value("id");
			
			com.etn.util.Logger.info("User not logged in ... going to check remember me cookies");
			//check if remember me cookies are available
			Cookie[] cookies = request.getCookies();

			String rememberMeToken = "";
			String rememberMeCuid = "";
			String rememberMeValidator = "";
			if(cookies != null)
			{
				for (int i = 0; i < cookies.length; i++) 
				{
					String cookiename = cookies[i].getName();
					String cookievalue = parseNull(cookies[i].getValue());
					if("_rme_token".equals(cookiename)) rememberMeToken = cookievalue;
					else if("_rme_cuid".equals(cookiename)) rememberMeCuid = cookievalue;
					else if("_rme_vld".equals(cookiename)) rememberMeValidator = cookievalue;
				}
			}
			
			if(rememberMeToken.length() > 0 && rememberMeCuid.length() > 0 && rememberMeValidator.length() > 0)
			{
				com.etn.util.Logger.info("remember me cookies found");

				//check in db if we find the token and validator in auths table ... auth token must be checked against the site id client 
				//case could be 2 sites on same domain and user clicks rememberme on first site and we should not auto login him on second site
				com.etn.lang.ResultSet.Set rs = Etn.execute("select c.* from auth_tokens a, clients c where c.site_id = "+com.etn.sql.escape.cote(siteid)+" and c.client_uuid = a.client_uuid and a.id = "+com.etn.sql.escape.cote(rememberMeToken)+" and a.validator = sha2("+com.etn.sql.escape.cote(rememberMeValidator)+",256) and a.client_uuid = "+com.etn.sql.escape.cote(rememberMeCuid)+" and a.expiry > now() ");
				if(rs != null && rs.next()) 
				{
					Etn.executeCmd("update clients set last_login_on = now() where id = " + com.etn.sql.escape.cote(rs.value("id")));

					com.etn.util.Logger.info("remember me validated from db");

					cuid = parseNull(rs.value("client_uuid"));
					cname = parseNull(parseNull(rs.value("name")) + " " + parseNull(rs.value("surname")));
					name = parseNull(rs.value("name"));
					surname = parseNull(rs.value("surname"));
					
					if("1".equals(parseNull(rs.value("is_super_user"))))
					{
						isLoggedInAsSuperUser = "1";		
					}
					else
					{
						isLoggedInAsSuperUser = "0";		
					}
					
					isLoggedIn = "1";
					clientid = rs.value("id");
					avatar = parseNull(rs.value("avatar"));
					
					profilId = rs.value("client_profil_id");
					try {
						additionalInfo = new org.json.JSONObject(parseNull(rs.value("additional_info")));
					} catch(Exception e) { }
					com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "client_id", clientid);
				}
			}			
		}		

		org.json.JSONObject json = new org.json.JSONObject();
		json.put("su", isLoggedInAsSuperUser);
		json.put("login", isLoggedIn);
		json.put("cuid", cuid);
		json.put("cname", cname);
		json.put("name", name);
		json.put("surname", surname);
		json.put("profil", profilId);
		json.put("avatar", avatar);
		if(additionalInfo != null) json.put("additional_info", additionalInfo);
		json.put("mlang", rsM.value("lang"));
		
		return json;
	}
%>