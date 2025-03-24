<%!
	String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	String doLogin(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request,  javax.servlet.http.HttpServletResponse response, String ______muid, String username, String password, boolean isMenuLogin, String rememberme) throws Exception
	{
		return doLogin(Etn, request, response, ______muid, username, password, isMenuLogin, rememberme, false);
	}
	
	String doLogin(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request,  javax.servlet.http.HttpServletResponse response, String ______muid, String username, String password, boolean isMenuLogin, String rememberme, boolean fromSignup) throws Exception
	{
		com.etn.lang.ResultSet.Set rsMenu = Etn.execute("select * from site_menus where menu_uuid = " + com.etn.sql.escape.cote(______muid));
		rsMenu.next();
		String menuid = rsMenu.value("id");
		String json = "";
		String siteid = rsMenu.value("site_id");
		
		AsiminaAuthenticationHelper asiminaAuthenticationHelper = new AsiminaAuthenticationHelper(Etn,siteid,com.etn.beans.app.GlobalParm.getParm("CLIENT_PASS_SALT"));
		if(asiminaAuthenticationHelper != null)
		{
			AsiminaAuthentication asiminaAuthentication = asiminaAuthenticationHelper.getAuthenticationObject();
			
			if(asiminaAuthentication != null)
			{		
				AsiminaAuthenticationResponse getUserResponse = asiminaAuthentication.authenticate(username,password);					
				if(fromSignup || getUserResponse.isDone())
				{
					if(asiminaAuthenticationHelper.isDefaultAuthentication() == false)
					{
						System.out.println("---- no default going to create or get user");
						AsiminaAuthenticationResponse defaultCreateUserResponse = asiminaAuthenticationHelper.getDefaultAuthenticationObject().getOrCreateUser(
								username,null,password,getUserResponse.getHttpResponse().getString("name"), getUserResponse.getHttpResponse().getString("surname"), 
								getUserResponse.getHttpResponse().getString("display_name"),null,"1",______muid,null,null,null,null, 
								getUserResponse.getHttpResponse().getString("language"), getUserResponse.getHttpResponse().getString("time_zone"),false
							);
						System.out.println("----- " + defaultCreateUserResponse.isDone());
						System.out.println(getUserResponse.getHttpResponse().toString());
						if(defaultCreateUserResponse.isDone()){
							System.out.println("---- defaultCreateUserResponse is here");								
							getUserResponse = defaultCreateUserResponse;
						}
					}
					//checking again as in non default authentication we try to create a client if that is successfull then we move ahead
					if(getUserResponse.isDone())
					{
						String clientId = getUserResponse.getHttpResponse().getString("id");
						
						com.etn.lang.ResultSet.Set rsCart = Etn.execute("select * from cart c inner join cart_items ci on c.id=ci.cart_id where c.client_id="+escape.cote(clientId)+" and c.site_id="+escape.cote(siteid));
						if(rsCart.rs.Rows > 0)
						{
							com.etn.util.Logger.info("commonlogin.jsp", "Client's carts found so set their session IDs in the cookies");
							while(rsCart.next())
							{
								
								String cartType = parseNull(rsCart.value("cart_type"));
								com.etn.util.Logger.info("commonlogin.jsp", cartType);
								String cartCookieName = com.etn.asimina.cart.CartHelper.getCookieName(cartType);
							
								String session_id = rsCart.value("session_id");
								
								javax.servlet.http.Cookie __cartCookie = new javax.servlet.http.Cookie(cartCookieName, session_id);
								__cartCookie.setMaxAge(24*7*60*60);

								//cookie must be set to appropriate path which in production will always be / in portal_link
								__cartCookie.setPath(com.etn.beans.app.GlobalParm.getParm("PORTAL_LINK"));

								response.addCookie(__cartCookie);
							}
						}
						else
						{
							com.etn.util.Logger.info("commonlogin.jsp", "No previous ");
							//deleting his existing empty carts if any, as they are of no use.
							Etn.executeCmd("delete from cart_items where cart_id in (select id from cart where client_id="+com.etn.sql.escape.cote(clientId)+" and site_id="+escape.cote(siteid)+")");
							Etn.executeCmd("delete from cart where client_id="+com.etn.sql.escape.cote(clientId)+" and site_id="+escape.cote(siteid));
								
							java.util.List<String> cartTypes = com.etn.asimina.cart.CartHelper.getCartTypes();
							for(String cartType : cartTypes)
							{
								com.etn.util.Logger.info("commonlogin.jsp", cartType);
								String cartCookieName = com.etn.asimina.cart.CartHelper.getCookieName(cartType);
								
								String session_id = "";
								javax.servlet.http.Cookie[] theCookies = request.getCookies();
								if(theCookies != null)
								{
									for (javax.servlet.http.Cookie cookie : theCookies)
									{
										if(cookie.getName().equals(cartCookieName)) session_id = cookie.getValue();//System.out.println(cookie.getName()+ " "+);
									}
								}								
								if(parseNull(session_id).length() > 0) 
								{
									Etn.executeCmd("update cart set session_access_time = now(), client_id="+escape.cote(clientId)+" where session_id="+escape.cote(session_id)+" and site_id="+escape.cote(siteid));
								}
								
							}
						}											
							
						Etn.executeCmd("update clients set last_login_on = now() where id = " + com.etn.sql.escape.cote(clientId));
																		
						String clientUUID = getUserResponse.getHttpResponse().getString("client_uuid");
						String email = getUserResponse.getHttpResponse().getString("email");
						String clientProfilId = getUserResponse.getHttpResponse().getString("client_profil_id");
						String isSuperUser = getUserResponse.getHttpResponse().getString("is_super_user");

						String uhomepage = getHomePage(Etn,clientProfilId,rsMenu.value("lang"));            
						com.etn.util.Logger.info("dologin.jsp", "user homepage url : " + uhomepage);
						json = "{\"status\":0, \"response\":\"success\"";
							
						if(!isMenuLogin || uhomepage.equals("")) json+=",\"refresh\":\"1\"";
						else json+=",\"gotoUrl\":\""+uhomepage+"\"";

						if(rememberme.equals("1"))
						{
							String lgnToken = java.util.UUID.randomUUID().toString();
							String lgnValidator = java.util.UUID.randomUUID().toString();

							Etn.executeCmd("insert into auth_tokens (id, validator, client_uuid, expiry) values ("+escape.cote(lgnToken)+", sha2("+escape.cote(lgnValidator)+",256),"+escape.cote(clientUUID)+", adddate(now(), interval 7 day)) ");

							json += ",\"rememberme\":\"1\"";
							json += ",\"token\":\""+lgnToken+"\"";
							json += ",\"validator\":\""+lgnValidator+"\"";			
							json += ",\"cuid\":\""+clientUUID+"\"";
						}
						else json += ",\"rememberme\":\"0\"";
						json += "}";
						
						com.etn.asimina.session.ClientSession.getInstance().removeParameter(Etn, request, "logintoken");
						com.etn.asimina.session.ClientSession.getInstance().removeParameter(Etn, request, "logintoken2");
						
						com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "client_id", clientId);
					}
					else
					{
						json = "{\"status\":100,\"response\":\"error\",\"message\":\""+libelle_msg(Etn, request, "Unable to create client. Please contact administrator")+"\"}";
					}
				}
				else
				{
					json = "{\"status\":200,\"response\":\"error\",\"message\":\""+libelle_msg(Etn, request, "Username and password you entered does not match any account")+"\"}";
				}			
			}
			else
			{
				json = "{\"status\":300,\"response\":\"error\",\"message\":\""+libelle_msg(Etn, request, "In correct site settings. Please contact administrator. Error code 102")+"\"}";
			}				
		}
		else
		{
			json = "{\"status\":300,\"response\":\"error\",\"message\":\""+libelle_msg(Etn, request, "In correct site settings. Please contact administrator. Error code 101")+"\"}";
		}
		//System.out.println(json);
		return json;
	}
%>
