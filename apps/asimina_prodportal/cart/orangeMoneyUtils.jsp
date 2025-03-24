<%@ page import="com.etn.asimina.util.GroupOrangeMoney"%>
<%!

	// from Orange API specifications
	// The status could take one of the following values: INITIATED; PENDING; EXPIRED; SUCCESS; FAILED
	// INITIATED waiting for user entry
	// PENDING user has clicked on “Confirmer”, transaction is in progress on Orange side
	// EXPIRED user has clicked on “Confirmer” too late (after token’s validity)
	// SUCCESS payment is done
	// FAILED payment has failed

	JSONObject initiateOrangeMoneyTransaction(com.etn.beans.Contexte Etn, String orderRefId,
    											double orderAmount,
    											String returnUrl, String notifUrl, String lang, String siteid) throws Exception{
		//wrapper function
		return initiateOrangeMoneyTransaction(Etn, orderRefId, orderAmount, returnUrl, returnUrl, notifUrl, lang, siteid);
	}

    JSONObject makeHttpCallForInit(com.etn.beans.Contexte Etn,String orderRefId,double orderAmount,String returnUrl,String cancelUrl,String notifUrl,String accessToken, String lang, String siteid) throws Exception
	{	
		com.etn.util.Logger.info("orangeMoneyUtils.jsp", "makeHttpCallForInit::Site ID : " + siteid);
		HashMap<String, String> orangeConfig = getOrangeConfig(Etn, siteid);

		String merchant_key = orangeConfig.get("orange_merchant_key")
			, currency = orangeConfig.get("orange_currency")
			, reference = orangeConfig.get("orange_merchant_reference");

		JSONObject json = new JSONObject();
		json.put("merchant_key", merchant_key);
		json.put("currency", currency);
		json.put("order_id", orderRefId);
		json.put("amount", orderAmount);
		json.put("return_url", returnUrl);
		json.put("cancel_url", cancelUrl);
		json.put("notif_url", notifUrl);
		json.put("lang", lang);
		json.put("reference", reference);

		String webPaymentApiUrl = orangeConfig.get("orange_api_webpayment");
		Map<String, String> requestHeaders = new HashMap<>();
		requestHeaders.put("Accept", "application/json");
		requestHeaders.put("Content-Type", "application/json");
		requestHeaders.put("Authorization", "Bearer " + accessToken);
		

		boolean useProxy = true;//by default we assume we will use proxy if its configured
		String orange_api_use_proxy = orangeConfig.get("orange_api_use_proxy");
		if("false".equalsIgnoreCase(orange_api_use_proxy) || "0".equals(orange_api_use_proxy)) useProxy = false;
		
		com.etn.asimina.util.ApiCaller apiCaller = new com.etn.asimina.util.ApiCaller(Etn);
		JSONObject jResponse = apiCaller.callApi("orangeMoneyUtils.makeHttpCallForInit", webPaymentApiUrl, "POST", json.toString(), requestHeaders, useProxy);

		return jResponse;
	}
	
	JSONObject initiateOrangeMoneyTransaction(com.etn.beans.Contexte Etn, String orderRefId,
    											double orderAmount,
    											String returnUrl, String cancelUrl,
    											String notifUrl, String lang, String siteid) throws Exception{
        try{
			com.etn.util.Logger.info("orangeMoneyUtils.jsp", "initiateOrangeMoneyTransaction::Site ID : " + siteid);
			
			if(orderRefId.length() == 0 || orderRefId.length() >= 30){
				//order ref id should less than 30 chars
				throw new Exception("Error: Invalid id length.");
			}

			if(returnUrl.length() == 0 || returnUrl.length() >= 130){
				throw new Exception("Error: Invalid return URL length.");
			}

			if(cancelUrl.length() == 0 || cancelUrl.length() >= 130){
				throw new Exception("Error: Invalid cancelURL length.");
			}

			if(orderAmount <= 0.0){
				throw new Exception("Error: Invlid order amount.");			
			}
            String accessToken = getOrangeAccessToken(Etn, siteid);
			
			JSONObject response = makeHttpCallForInit(Etn,orderRefId,orderAmount,returnUrl,cancelUrl,notifUrl,accessToken, lang, siteid);
			
			if(response.getInt("http_code") == 401){
				accessToken = getForceOrangeToken(Etn, siteid);
				response = makeHttpCallForInit(Etn,orderRefId,orderAmount,returnUrl,cancelUrl,notifUrl,accessToken, lang, siteid);
			}
            
			if(response.getInt("http_code") == 201){
				System.out.println(response.optString("response","{}"));//debug
				JSONObject respJson = new JSONObject(response.optString("response","{}"));
				return respJson;
			}else{
				System.out.println(response.optString("response",""));//debug
				return null;
			}
        }
        finally{

        }
    }
	
	JSONObject makeOrderStautsCall(com.etn.beans.Contexte Etn,Set rs,String accessToken, String siteid) throws Exception
	{
		com.etn.util.Logger.info("orangeMoneyUtils.jsp", "makeOrderStautsCall::Site ID : " + siteid);
		double amount = Double.parseDouble(rs.value("total_price"));
		String order_id = rs.value("payment_id");
		String pay_token = rs.value("payment_token");

		JSONObject json = new  JSONObject();
		json.put("order_id", order_id);
		json.put("amount", amount);
		json.put("pay_token", pay_token);

		Map<String, String> requestHeaders = new HashMap<>();
		requestHeaders.put("Accept", "application/json");
		requestHeaders.put("Content-Type", "application/json");
		requestHeaders.put("Authorization", "Bearer " + accessToken);

		String transactionStatusApiUrl = getOrangeApiUrl(Etn, "transactionstatus", siteid);

		boolean useProxy = true;//by default we assume we will use proxy if its configured
		String orange_api_use_proxy = getOrangeApiUrl(Etn, "orange_api_use_proxy", siteid);
		if("false".equalsIgnoreCase(orange_api_use_proxy) || "0".equals(orange_api_use_proxy)) useProxy = false;

		com.etn.asimina.util.ApiCaller apiCaller = new com.etn.asimina.util.ApiCaller(Etn);
		JSONObject jResponse = apiCaller.callApi("orangeMoneyUtils.makeOrderStautsCall", transactionStatusApiUrl, "POST", json.toString(), requestHeaders, useProxy);

		return jResponse;
	}
	
	String getOrderStatus(com.etn.beans.Contexte Etn,String query, String siteid)throws Exception
	{
		com.etn.util.Logger.info("orangeMoneyUtils.jsp", "getOrderStatus::Site ID : " + siteid);
		Set rs = Etn.execute(query);
		if(rs.next()){

			String accessToken = getOrangeAccessToken(Etn, siteid);
	        JSONObject jResponse = makeOrderStautsCall(Etn,rs,accessToken, siteid);
	        System.out.println(jResponse.optString("response","{}"));
			if(jResponse.getInt("http_code") == 401)
			{
				accessToken = getForceOrangeToken(Etn, siteid);
				jResponse = makeOrderStautsCall(Etn,rs,accessToken,siteid);
			}
	        if(jResponse.getInt("http_code") == 201)
			{
		        return jResponse.optString("response","{}");
			}
			else
			{
				return null;
			}
		}
		return null;
	}
	
	String getPaymentId(com.etn.beans.Contexte Etn,String query)
	{
		Set rs = Etn.execute(query);
		if(rs.next()){
			return rs.value("payment_id");
		}
		return "";
	}

	String getAndUpdatePaymentStatus(com.etn.beans.Contexte Etn, String paymentRefid, String SHOP_DB) throws Exception
	{
		String siteid = "";
		Set _rs = Etn.execute("select c.site_id from "+SHOP_DB+".payments_ref p, cart c where c.id = p.cart_id and p.id = "+ escape.cote(paymentRefid));
		if(_rs.next())
		{
			siteid = _rs.value("site_id");
		}
		com.etn.util.Logger.info("orangeMoneyUtils.jsp", "getAndUpdatePaymentStatus::Site ID : " + siteid);
		
		String q = "SELECT * FROM "+SHOP_DB+".payments_ref "
			+ " WHERE id = "+ escape.cote(paymentRefid)
			+ " AND payment_token != '' AND payment_id != '' "
			+ " AND payment_status NOT IN ('SUCCESS', 'FAILED', 'EXPIRED') ";
		String responseStr =  getOrderStatus(Etn,q,siteid);
		String paymentId = getPaymentId(Etn,q);
		
		System.out.println("response:");
		System.out.println(responseStr);
		if(responseStr != null){
			JSONObject respJson = new JSONObject(responseStr);

			System.out.println("json:");
			System.out.println(respJson.toString());

			if(respJson.getString("order_id").equals(paymentId)
				&& respJson.getString("status").length() > 0
				&& respJson.getString("txnid").length() > 0)
			{
				String newStatus = respJson.getString("status");
				String isSuccess = "0";
				if("success".equalsIgnoreCase(newStatus)) isSuccess = "1";
				String txnid = respJson.getString("txnid");
				Etn.executeCmd("UPDATE "+SHOP_DB+".payments_ref SET payment_status=" + escape.cote(newStatus)
							+ " ,is_success = "+escape.cote(isSuccess)+", payment_txn_id=" + escape.cote(txnid)
							+ " WHERE id = "+ escape.cote(paymentRefid) );
				return newStatus;
			}
		}
		else
		{
			//error
		}

		q = "SELECT payment_status FROM "+SHOP_DB+".payments_ref "
			+ " WHERE id = "+ escape.cote(paymentRefid)
			+ " AND payment_token != '' AND payment_id != '' ";
		//System.out.println(q);
		Set rs = Etn.execute(q);
		if(rs.next())
		{
			return rs.value("payment_status");
		}
		else
		{
			return "";
		}
	}
	
	String getForceOrangeToken(com.etn.beans.Contexte Etn, String siteid) throws Exception{
		
		com.etn.util.Logger.info("orangeMoneyUtils.jsp", "getForceOrangeToken::Site ID : " + siteid);
		String accessToken = "";
		
		//get new access token from orange API
		String orangeScrt = "";

		Set rs = Etn.execute("SELECT val FROM sites_config WHERE site_id = "+escape.cote(siteid)+" and code = 'orange_scrt'");
		if(rs.next()){
			orangeScrt = parseNull(rs.value("val"));
		}

		if(orangeScrt.length() == 0){
			throw new Exception("ERROR: Orange API not specified.");
		}
		
		String tokenApiUrl = getOrangeApiUrl(Etn, "token", siteid);
		String params = "grant_type=client_credentials";
		Map<String, String> requestHeaders = new HashMap<>();
		requestHeaders.put("Authorization", "Basic "+orangeScrt);
		requestHeaders.put("Content-Type", "application/x-www-form-urlencoded");
		

		boolean useProxy = true;//by default we assume we will use proxy if its configured
		String orange_api_use_proxy = getOrangeApiUrl(Etn, "orange_api_use_proxy", siteid);
		if("false".equalsIgnoreCase(orange_api_use_proxy) || "0".equals(orange_api_use_proxy)) useProxy = false;

		com.etn.asimina.util.ApiCaller apiCaller = new com.etn.asimina.util.ApiCaller(Etn);
		JSONObject jResponse = apiCaller.callApi("orangeMoneyUtils.getForceOrangeToken", tokenApiUrl, "POST", params, requestHeaders, useProxy);

		if(jResponse.getInt("http_code") == 200)
		{
			JSONObject respJson = new JSONObject(jResponse.optString("response","{}"));

			accessToken = respJson.getString("access_token");
			String expires_in = respJson.getString("expires_in");//this is in seconds
			
			GroupOrangeMoney.setToken(siteid, accessToken, (System.currentTimeMillis()/1000) + parseNullInt(expires_in));
		}
		else
		{
			System.out.println("****ORANGE ERROR: "+jResponse.getInt("http_code"));
			System.out.println(jResponse.optString("response","{}"));
			throw new Exception("ERROR: Orange API error code : "+ jResponse.getInt("http_code"));
		}
		return accessToken;
	}

    String getOrangeAccessToken(com.etn.beans.Contexte Etn, String siteid) throws Exception	
	{
		com.etn.util.Logger.info("orangeMoneyUtils.jsp", "getOrangeAccessToken::Site ID : " + siteid);
        try
		{
            String accessToken = "";
			if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV")) == false)
			{
				System.out.println("OM Token:" + GroupOrangeMoney.getAccessToken(siteid));
				System.out.println("OM Expiry ts: " + GroupOrangeMoney.getExpiry(siteid));
			}
			
            //first check expiry
			long diff = GroupOrangeMoney.getExpiry(siteid) - (System.currentTimeMillis()/1000);
			System.out.println("Expiring in: "+diff+" seconds");

            //if not expired
			//here we checking that diff be more than 10 seconds to be on safe side
            if(diff > 10){
				accessToken = GroupOrangeMoney.getAccessToken(siteid);
            }

            if(accessToken.length() == 0)
			{
				accessToken = getForceOrangeToken(Etn, siteid);
            }

            //if still accessToken is empty
            if(accessToken.length() > 0)
			{
                return accessToken;
            }
            else
			{
                throw new Exception("Error in contacting Orange.");
            }

        }//main try
        finally
		{
             //if(response != null) response.close();
        }
    }

    HashMap<String,String> getOrangeConfig(com.etn.beans.Contexte Etn, String siteid){
		com.etn.util.Logger.info("orangeMoneyUtils.jsp", "getOrangeConfig::Site ID : " + siteid);
		HashMap<String, String> map = new HashMap<String,String>(10);
		Set rs = Etn.execute("SELECT * FROM sites_config WHERE site_id = "+escape.cote(siteid)+" and code LIKE 'orange_%'");
		while(rs.next()){
			map.put(rs.value("code"), rs.value("val"));
		}
		return map;
	}

	String getOrangeApiUrl(com.etn.beans.Contexte Etn, String type, String siteid){
		
		com.etn.util.Logger.info("orangeMoneyUtils.jsp", "getOrangeApiUrl::Site ID : " + siteid);
		String apiUrl = "";

        Set rs = Etn.execute("SELECT val FROM sites_config WHERE site_id = "+escape.cote(siteid)+" and code = "+ escape.cote("orange_api_"+type));
        if(rs.next()){
            apiUrl = parseNull(rs.value("val"));
        }

        return apiUrl;
	}

    String extractPostRequestBody(HttpServletRequest request) {
	    if ("POST".equalsIgnoreCase(request.getMethod())) {
	        java.util.Scanner s = null;
	        try {
	            s = new java.util.Scanner(request.getInputStream(), "UTF-8").useDelimiter("\\A");
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	        return s.hasNext() ? s.next() : "";
	    }
	    return "";
	}
%>