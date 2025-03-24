 <%@ page import="org.apache.http.impl.client.HttpClientBuilder, org.apache.http.HttpResponse, org.apache.http.HttpEntity, org.apache.http.NameValuePair, org.apache.http.client.*, org.apache.http.entity.*, org.apache.http.message.*, org.apache.http.util.*, org.apache.http.client.methods.*, org.apache.http.client.entity.UrlEncodedFormEntity "%>
<%!
	//TODO , paypal Utils server side REST API
	// ( SDK requires TLS v1.2 is enabled, its not enabled on our server)


	// from Orange API specifications
	// The status could take one of the following values: INITIATED; PENDING; EXPIRED; SUCCESS; FAILED
	// INITIATED waiting for user entry
	// PENDING user has clicked on “Confirmer”, transaction is in progress on Orange side
	// EXPIRED user has clicked on “Confirmer” too late (after token’s validity)
	// SUCCESS payment is done
	// FAILED payment has failed

	String getPaypalAccessToken(com.etn.beans.Contexte Etn, String siteid) throws Exception{


        try{
            String accessToken = "";

            //first check expiry
            Set rs = Etn.execute("SELECT DATEDIFF(val, NOW()) as diff FROM sites_config WHERE site_id = "+escape.cote(siteid)+" and code = 'paypal_access_expire_ts'");
            int diff = 0;
            if(rs.next()){
                diff = parseNullInt(rs.value("diff"));
            }

            //if not expired
            if(diff > 0){
                rs = Etn.execute("SELECT * FROM sites_config WHERE site_id = "+escape.cote(siteid)+" and code = 'paypal_access_token'");

                if(rs.next()){
                    accessToken = parseNull(rs.value("val"));
                }
            }

            if(accessToken.length() == 0){
                //get new access token from API
                String paypalScrt = "";
                String paypalClientKey = "";

                rs = Etn.execute("SELECT code,val FROM sites_config WHERE site_id = "+escape.cote(siteid)+" and code IN('paypal_scrt', 'paypal_client_key')");
                while(rs.next()){
                	if("paypal_scrt".equals(rs.value("code"))){
                    	paypalScrt = parseNull(rs.value("val"));
                	}
                	else if("paypal_client_key".equals(rs.value("code"))){
                    	paypalClientKey = parseNull(rs.value("val"));
                	}

                }

                if(paypalScrt.length() == 0 || paypalClientKey.length() == 0){
                    throw new Exception("ERROR: Paypal API not specified.");
                }

                String authString = paypalClientKey + ":" + paypalScrt;
                String encodedAuth = new String(org.apache.commons.codec.binary.Base64.encodeBase64(authString.getBytes("UTF-8")));
				System.out.println("BASE : "+ encodedAuth);
				encodedAuth = "QVVYY1dNc1NuRURud2VzMEUzNTB0Q3p4NFpCS1I2MElHZ0FTOU9ZZEd5MWN1di1HZ0k0NEx0MjN5REpsaDNYcWo4TjVlaDZGaFB4SkxrcUE6RUpxcHRkQVg4RklQZkM1VnhkQWhGTHVhQTBBdnZ2akFBSG5OeVlUN1huMjdzMGVrMFdJdDZjak5tTlozc05PaFlQbFkzQzQyZXhFejhXZVc=";

                List<NameValuePair> params = new ArrayList<NameValuePair>(1);
                params.add(new BasicNameValuePair("grant_type", "client_credentials"));

                UrlEncodedFormEntity entity = new UrlEncodedFormEntity(params);

                HttpClient httpClient = HttpClientBuilder.create().build();
                String tokenApiUrl = "https://api.sandbox.paypal.com/v1/oauth2/token";//todo debug getOrangeApiUrl(Etn, "token");
                HttpPost postRequest = new HttpPost(tokenApiUrl);
                postRequest.setEntity(entity);
                postRequest.addHeader("Authorization", "Basic "+encodedAuth);
                postRequest.addHeader("Content-Type", "application/x-www-form-urlencoded");

                HttpResponse response = httpClient.execute(postRequest);

                if(response.getStatusLine().getStatusCode() == 200){

                    HttpEntity responseEntity = response.getEntity();

                    String responseStr =  EntityUtils.toString(responseEntity);
                    System.out.println(responseStr);
                    JSONObject respJson = new JSONObject(responseStr);

                    accessToken = respJson.getString("access_token");
                    String expires_in = respJson.getString("expires_in");

                    String insQ = "INSERT INTO sites_config(site_id, code,val) VALUES "
                        + " ( "+escape.cote(siteid)+", 'paypal_access_token', "+ escape.cote(accessToken)+") "
                        + ", ( "+escape.cote(siteid)+", 'paypal_access_expire_ts', DATE(DATE_ADD(NOW() , INTERVAL "+escape.cote(expires_in)+" SECOND)) ) "
                        + " ON DUPLICATE KEY UPDATE val=VALUES(val)";

                    Etn.executeCmd(insQ);

                }
                else{
                    System.out.println("****PAYPAL ERROR: "+response.getStatusLine().toString());
                    System.out.println(postRequest.toString());
                    System.out.println(response.getStatusLine().toString());
                    System.out.println( EntityUtils.toString(response.getEntity()) );
                    throw new Exception("ERROR: API error code : "+ response.getStatusLine().getStatusCode());
                }

            }//end if

            //if still accessToken is empty
            if(accessToken.length() > 0){
                return accessToken;
            }
            else{
                throw new Exception("Error in contacting Paypal.");
            }

        }//main try
        finally{
             //if(response != null) response.close();
        }
    }

%>
