<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte,com.etn.asimina.cart.CartHelper,com.etn.asimina.beans.Cart,java.nio.charset.StandardCharsets, org.apache.http.HttpRequest, com.etn.beans.app.GlobalParm, org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="org.json.*, java.util.*, org.apache.http.client.methods.CloseableHttpResponse, org.apache.http.client.methods.*, org.apache.http.impl.client.CloseableHttpClient, org.apache.http.impl.client.HttpClients, org.apache.http.util.EntityUtils" %>
<%@ page import="org.apache.http.entity.StringEntity,org.apache.http.HttpHeaders,org.apache.http.entity.ContentType,java.io.BufferedReader,java.io.IOException,org.apache.http.HttpEntity,javax.servlet.http.Cookie, com.etn.asimina.util.PortalHelper, com.etn.asimina.util.ApiCaller, com.etn.util.Logger"%>

<%@include file="commonfunctions.jsp"%>

<%!
    JSONObject jsonObjectKeyCleanup(JSONObject jsonObject) throws JSONException{
        String[] keys = JSONObject.getNames(jsonObject);
        try{
            if (keys != null) {
                for (String key : keys) {
                    if (PortalHelper.parseNull(jsonObject.get(key)).length()==0) {
                        jsonObject.remove(key);
                    }
                }
            }
        }catch(JSONException e)
        {
            return null;
        }
        if(jsonObject.length() == 0) return null;
        return jsonObject;
    }  

    JSONObject getConfigJson(Contexte Etn,String siteId, String langCode) throws JSONException {
        Set rs = Etn.execute("select a.*,b.code from idcheck_iframe_conf a join idcheck_configurations b on a.site_id = b.site_id where a.site_id ="+escape.cote(siteId));
        JSONObject resp = new JSONObject();
        if(rs!=null && rs.next()){

            JSONObject interfaceSettings = new JSONObject();
            JSONObject contactData = new JSONObject();
            JSONArray documentsToCapture = new JSONArray(); 
            JSONObject redirectionData = new JSONObject();
            JSONObject options = new JSONObject();

            interfaceSettings.put("confCode",PortalHelper.parseNull(rs.value("code")));
            interfaceSettings.put("language",PortalHelper.parseNull(langCode).toUpperCase());

            interfaceSettings = jsonObjectKeyCleanup(interfaceSettings);
            if(interfaceSettings!=null)
                resp.put("interfaceSettings",interfaceSettings);

            Set docRs = Etn.execute("Select * from idcheck_doc_capture_conf where idcheck_iframe_conf_id="+escape.cote(PortalHelper.parseNull(rs.value("id")))+" ORDER BY id");
            
            while(docRs.next()){
                
                JSONObject docToCapt = new JSONObject();
                docToCapt.put("code",PortalHelper.parseNull(docRs.value("capture_code")));

                if(PortalHelper.parseNull(docRs.value("doc_type")).length() > 0){

                    JSONArray docTypes= new JSONArray();
                    for(String val : docRs.value("doc_type").split(","))
                    {
                        docTypes.put(val);
                    }
                    docToCapt.put("docTypes",docTypes);
                }

                docToCapt.put("optional",(PortalHelper.parseNull(docRs.value("optional")).equals("0"))? false : true);
                docToCapt.put("versoHandling",PortalHelper.parseNull(docRs.value("verso_handling")));
                docToCapt.put("withDocLiveness",(PortalHelper.parseNull(docRs.value("with_doc_liveness")).equals("0"))? false : true);
                docToCapt.put("label",PortalHelper.parseNull(docRs.value("liveness_label")));
                docToCapt.put("description",PortalHelper.parseNull(docRs.value("liveness_description")));

                

                JSONObject livenessReferenceDoc = new JSONObject();
                
                livenessReferenceDoc.put("location",PortalHelper.parseNull(docRs.value("liveness_ref_location")));
                livenessReferenceDoc.put("value",PortalHelper.parseNull(docRs.value("liveness_ref_value")));

                livenessReferenceDoc = jsonObjectKeyCleanup(livenessReferenceDoc);
                if(livenessReferenceDoc!=null)
                    docToCapt.put("livenessReferenceDoc",livenessReferenceDoc);

                docToCapt = jsonObjectKeyCleanup(docToCapt);
                if(docToCapt!=null)
                    documentsToCapture.put(docToCapt);
            }
            
            if(documentsToCapture!=null && documentsToCapture.length() > 0){
                resp.put("documentsToCapture",documentsToCapture);
            }


            JSONObject cisConf = new JSONObject();
            
            cisConf.put("realm",PortalHelper.parseNull(rs.value("realm")));
            cisConf.put("fileUid",PortalHelper.parseNull(rs.value("fileUid")+"-"+System.currentTimeMillis()));
            cisConf.put("fileLaunchCheck",(PortalHelper.parseNull(rs.value("fileLaunchCheck")).equals("0"))? false : true);
            cisConf.put("fileCheckWait",(PortalHelper.parseNull(rs.value("fileCheckWait")).equals("0"))? false : true);


            if(PortalHelper.parseNull(rs.value("fileTags")).length() > 0){
                JSONArray fileTags= new JSONArray();
                for(String val : rs.value("fileTags").split(","))
                {
                    fileTags.put(val);
                }
                cisConf.put("fileTags",fileTags);
            }

            cisConf = jsonObjectKeyCleanup(cisConf);
            if(cisConf != null){
                JSONObject resultHandler = new JSONObject();
                resultHandler.put("cisConf",cisConf);
                resp.put("resultHandler",resultHandler);
            }
            
            redirectionData.put("successRedirectUrl",(PortalHelper.parseNull(rs.value("success_redirect_url")).length()>0)? PortalHelper.parseNull(rs.value("success_redirect_url")):"");
            redirectionData.put("errorRedirectUrl",(PortalHelper.parseNull(rs.value("error_redirect_url")).length()>0)? PortalHelper.parseNull(rs.value("error_redirect_url")):"");
            redirectionData.put("autoRedirect",(PortalHelper.parseNull(rs.value("auto_redirect")).equals("0"))? false : true);

            redirectionData = jsonObjectKeyCleanup(redirectionData);
            if(redirectionData != null){
                if(redirectionData.has("successRedirectUrl") || redirectionData.has("errorRedirectUrl"))
                resp.put("redirectionData",redirectionData);
            }
            
            contactData.put("notificationType",PortalHelper.parseNull(rs.value("notification_type")));
            contactData.put("value",PortalHelper.parseNull(rs.value("notification_value")));
            
            contactData = jsonObjectKeyCleanup(contactData);
            if(contactData != null){
                resp.put("contactData",contactData);
            }

            options.put("identificationCode",PortalHelper.parseNull(rs.value("ident_code")));
            options.put("iframeDisplay",(PortalHelper.parseNull(rs.value("iframe_display")).equals("0"))? false : true);
            options.put("iframeRedirectParent",(PortalHelper.parseNull(rs.value("iframe_redirect_parent")).equals("0"))? false : true);

            JSONObject consent = new JSONObject();
            consent.put("biometricConsent",(PortalHelper.parseNull(rs.value("biometric_consent")).equals("0"))? false : true);
        
            options.put("consent",consent);

            JSONObject legalMentions = new JSONObject();
            legalMentions.put("hideLink",(PortalHelper.parseNull(rs.value("legal_hide_link")).equals("0"))? false : true);
            legalMentions.put("externalLink",PortalHelper.parseNull(rs.value("legal_external_link")));

            legalMentions = jsonObjectKeyCleanup(legalMentions);
            if(legalMentions != null){
                options.put("legalMentions",legalMentions);
            }
        
            options.put("captureModeDesktop",PortalHelper.parseNull(rs.value("iframe_capt_mode_desk")));
            options.put("captureModeMobile",PortalHelper.parseNull(rs.value("iframe_capt_mode_mob")));

            options = jsonObjectKeyCleanup(options);
            if(options != null){
                resp.put("options",options);
            }

        }
        return resp;
    }

    int insertIdnowStatus(Contexte Etn, String siteid, String uid, String status, JSONObject configJson)
    {
        return Etn.executeCmd("INSERT INTO idnow_sessions (idnow_uid, site_id,status, iframe_url_json) VALUES("+escape.cote(uid)+", "+escape.cote(siteid)+","+escape.cote(status)+", "+PortalHelper.escapeCote2(configJson.toString())+")");
    }

    JSONObject getIframeUrl(Contexte Etn, String API_ENDPOINT, String token, JSONObject payload) throws Exception 
	{
		ApiCaller apiCaller = new ApiCaller(Etn);
		Map<String, String> headers = new HashMap<>();
		headers.put("Authorization" ,"Bearer "+getIdnowToken(Etn,token));
		headers.put("Content-Type", "application/json;charset=UTF-8");

		JSONObject jApiResp = apiCaller.callApi("clientapis/idcheck/getIframeUrl.jsp:getIframeUrl", API_ENDPOINT, "POST", payload.toString(), headers);
		return jApiResp;
    }

%>

<%
	Logger.info("clientapis/idcheck/getIframeUrl.jsp","--------------------------------------" );
	Logger.info("clientapis/idcheck/getIframeUrl.jsp","in getIframeUrl.jsp" );
	Logger.info("clientapis/idcheck/getIframeUrl.jsp","--------------------------------------" );

    int status = 0;
    JSONObject json = new JSONObject();
    final String method = PortalHelper.parseNull(request.getMethod());
    final String siteUuid = PortalHelper.parseNull(request.getHeader("site-uuid"));
    String langCode = PortalHelper.parseNull(request.getHeader("lang"));
    final String accessToken = PortalHelper.parseNull(request.getHeader("access-token"));

    
    
    if("POST".equalsIgnoreCase(method) == false)
	{
		json.put("status", 100);
		json.put("err_code", "METHOD_NOT_SUPPORTED");
		json.put("err_msg", "Method '"+method+"' is not supported");
		out.write(json.toString());
		return;
	}   

    if(accessToken.length() == 0)
    {
        json.put("status", 401);
        json.put("err_code", "UNAUTHORIZED");
		json.put("err_msg", "Access token required");
        out.write(json.toString());
        return;
    }

    if(tokenExpiry(Etn,accessToken))
    {
        json.put("status", 401);
        json.put("err_code", "UNAUTHORIZED");
		json.put("err_msg", "Access token expired");
        out.write(json.toString());
        return;
    }

    final String siteId = getSiteId(Etn,siteUuid);

    final String API_ENDPOINT = GlobalParm.getParm("IDCHECK_END_POINT")+"onboarding/sendlink";

    if(siteId.length() == 0)
    {
        json.put("status", 60);
        json.put("err_code", "SITE_ID_MISSING");
		json.put("err_msg", "Site id required");
        out.write(json.toString());
        return;
    }

    langCode = getLang(Etn,langCode,siteId);

    if(!CartHelper.isKycRequired(Etn,siteId))
    {
        json.put("status", 70);
        json.put("err_code", "IDCHECK_NOT_ACTIVE");
		json.put("err_msg", "Idcheck configuration is not active");
        out.write(json.toString());
        return;
    }

    try
    {
        JSONObject configJson = getConfigJson(Etn,siteId,langCode);    
        JSONObject jApiResp = getIframeUrl(Etn,API_ENDPOINT,accessToken,configJson);
		if(jApiResp.getInt("status") == 0)
		{
			JSONObject jObj = new JSONObject(jApiResp.getString("response"));
			if(jObj.has("errorCode"))
			{
				json.put("status", jObj.getInt("httpCode"));
				json.put("err_code", jObj.getString("errorCode"));
				json.put("err_msg", jObj.getString("message"));
		
				if(jObj.has("data")) json.put("data", jObj.getJSONObject("data"));

				out.write(json.toString());
				return;
			}
			else
			{
				insertIdnowStatus(Etn, siteId, jObj.getString("uid"), "pending", configJson);

				String idnowUuid = getUuidForIdnowId(Etn,jObj.getString("uid"));

				Etn.execute("update idcheck_access_tokens set idnow_uuid="+escape.cote(PortalHelper.parseNull(idnowUuid))+" where token="+escape.cote(accessToken));
				
				final String cartSession = CartHelper.getCartSessionId(request);
				if(cartSession.length() > 0){

					final String ___muuid = CartHelper.getCartMenuUuid(request);
					Cart cart = CartHelper.loadCart(Etn, request, cartSession, siteId, ___muuid, true);
					final String cartId = cart.getProperty("id");
					Etn.execute("UPDATE cart SET idnow_uuid="+escape.cote(idnowUuid)+" where id="+escape.cote(cartId));
				}
				json.put("data",jObj);
			}   
		}
		else
		{
			json.put("status", 95);
			json.put("err_code", "API_ERROR");
			json.put("err_msg", "API returned error");							
			json.put("err_details", jApiResp);
		}
    }
    catch(Exception e)
    {
        json.put("status", 90);
        json.put("err_code", "SERVER_ERROR");
		json.put("err_msg", "Something went wrong");
        out.write(json.toString());
        return; 
    }
    
    json.put("status",status);    

    Logger.info("clientapis/idcheck/getiframeUrl.jsp","---------------------------------------------");
    Logger.info("clientapis/idcheck/getiframeUrl.jsp"," RESPONSE JSON  "+json.toString() );
    Logger.info("clientapis/idcheck/getiframeUrl.jsp","---------------------------------------------");

    out.write(json.toString());
%>