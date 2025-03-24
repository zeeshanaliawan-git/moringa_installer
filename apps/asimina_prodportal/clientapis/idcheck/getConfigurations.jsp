<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte,java.nio.charset.StandardCharsets, org.apache.http.HttpRequest, com.etn.beans.app.GlobalParm, org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="org.json.*, java.util.*, org.apache.http.client.methods.CloseableHttpResponse, org.apache.http.client.methods.*, org.apache.http.impl.client.CloseableHttpClient, org.apache.http.impl.client.HttpClients, org.apache.http.util.EntityUtils" %>
<%@ page import="org.apache.http.entity.StringEntity,org.apache.http.HttpHeaders,org.apache.http.entity.ContentType,java.io.BufferedReader, java.io.*,org.apache.http.HttpEntity,javax.servlet.http.Cookie,com.etn.asimina.cart.CartHelper, com.etn.asimina.util.PortalHelper, com.etn.asimina.util.ApiCaller, com.etn.util.Logger"%>

<%@include file="commonfunctions.jsp"%>

<%!
    JSONObject fetchAllConfigurations(Contexte Etn, String API_ENDPOINT, String token, ApiCaller apiCaller) throws Exception {
		Logger.info("clientapis/idcheck/getConfiguration.jsp","in fetchAllConfigurations" );
		Map<String, String> headers = new HashMap<>();
		headers.put("Authorization" ,"Bearer "+getIdnowToken(Etn,token));
		headers.put("Content-Type", "application/json;charset=UTF-8");

		JSONObject jApiResp = apiCaller.callApi("clientapis/idcheck/getConfigurations.jsp:fetchAllConfigurations", API_ENDPOINT, "GET", "", headers);
		return jApiResp;
    }

    JSONObject createConfigurations(Contexte Etn, String API_ENDPOINT, String token,JSONObject payload, ApiCaller apiCaller) throws Exception {
		Logger.info("clientapis/idcheck/getConfiguration.jsp","in createConfigurations" );
		Map<String, String> headers = new HashMap<>();
		headers.put("Authorization" ,"Bearer "+getIdnowToken(Etn,token));
		headers.put("Content-Type", "application/json;charset=UTF-8");

		JSONObject jApiResp = apiCaller.callApi("clientapis/idcheck/getConfigurations.jsp:createConfigurations", API_ENDPOINT, "POST", payload.toString(), headers);
		return jApiResp;
    }

    JSONObject updateConfigurations(Contexte Etn, String API_ENDPOINT, String token, JSONObject payload, ApiCaller apiCaller) throws Exception {
		Logger.info("clientapis/idcheck/getConfiguration.jsp","in updateConfigurations" );
		Map<String, String> headers = new HashMap<>();
		headers.put("Authorization" ,"Bearer "+getIdnowToken(Etn,token));
		headers.put("Content-Type", "application/json;charset=UTF-8");

		JSONObject jApiResp = apiCaller.callApi("clientapis/idcheck/getConfigurations.jsp:updateConfigurations", API_ENDPOINT, "POST", payload.toString(), headers);
		return jApiResp;
    }

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

    JSONObject getConfigJson(Contexte Etn, String siteId, String langCode) throws JSONException {
        Set rs = Etn.execute("SELECT * FROM idcheck_configurations where site_id ="+escape.cote(siteId));
        JSONObject resp = new JSONObject();
        JSONObject options = new JSONObject();
        JSONObject theme = new JSONObject();
        JSONArray wordings = new JSONArray();
        String configId="";
        if(rs!=null && rs.next()){
            configId = PortalHelper.parseNull(rs.value("id"));
            resp.put("pathName",PortalHelper.parseNull(rs.value("path_name")));
            resp.put("code",PortalHelper.parseNull(rs.value("code")));
            
            try{
                String base64Image = convertImageToBase64(PortalHelper.parseNull(rs.value("logo")),siteId);
                theme.put("logo",base64Image);
            }catch(IOException e){
                //theme.put("logo",null);
            }

            theme.put("titleTxtColor",PortalHelper.parseNull(rs.value("title_txt_color")));
            theme.put("headerBgColor",PortalHelper.parseNull(rs.value("header_bg_color")));
            theme.put("btnBgColor",PortalHelper.parseNull(rs.value("btn_bg_color")));
            theme.put("btnHoverBgColor",PortalHelper.parseNull(rs.value("btn_hover_bg_color")));
            theme.put("btnTxtColor",PortalHelper.parseNull(rs.value("btn_txt_color")));
            theme.put("btnBorderRadius",PortalHelper.parseNull(rs.value("btn_border_rad")));
            theme.put("hideHeaderBorder", (PortalHelper.parseNull(rs.value("hide_head_border")).equals("0"))? false : true);
            theme.put("headerLogoAlign",PortalHelper.parseNull(rs.value("head_logo_align")));

            options.put("supportEmail",PortalHelper.parseNull(rs.value("support_email")));
            options.put("linkValidity",PortalHelper.parseNull(rs.value("link_validity")));
            options.put("emailSenderName",PortalHelper.parseNull(rs.value("email_sender_name")));

            JSONObject captureSettings = new JSONObject();
            
            captureSettings.put("blockUpload",(PortalHelper.parseNull(rs.value("block_upload")).equals("0"))? false : true);
            captureSettings.put("captureModeMobile",PortalHelper.parseNull(rs.value("capture_mobile")));
            captureSettings.put("disableImageBlackAndWhiteChecks",(PortalHelper.parseNull(rs.value("image_blk_whe_chk")).equals("0"))? false : true);
            captureSettings.put("disableImageQualityChecks",(PortalHelper.parseNull(rs.value("image_qty_chk")).equals("0"))? false : true);
            captureSettings.put("captureModeDesktop",PortalHelper.parseNull(rs.value("capture_desktop")));
            captureSettings.put("displayUploadPromptOnMobile",(PortalHelper.parseNull(rs.value("prompt_mobile")).equals("0"))? false : true);

            captureSettings = jsonObjectKeyCleanup(captureSettings);
            
            if(captureSettings != null)
                options.put("idCaptureSettings",captureSettings);

            theme = jsonObjectKeyCleanup(theme);
            if(theme != null)
                resp.put("theme",theme);
            
            options = jsonObjectKeyCleanup(options);
            if(options != null)
                resp.put("options",options);

            Set rsWording = Etn.execute("SELECT * FROM idcheck_config_wordings where config_id="+escape.cote(configId)+" AND langue_code="+escape.cote(langCode));

            while(rsWording != null && rsWording.next())
            {
                JSONObject wording = new JSONObject();
                wording.put("homeTitle",PortalHelper.parseNull(rsWording.value("home_title")));
                wording.put("homeMsg",PortalHelper.parseNull(rsWording.value("home_msg")));
                wording.put("authentInputMsg",PortalHelper.parseNull(rsWording.value("auth_input_msg")));
                wording.put("authentHelpMsg",PortalHelper.parseNull(rsWording.value("auth_help_msg")));
                wording.put("errorMsg",PortalHelper.parseNull(rsWording.value("error_msg")));
                wording.put("onboardingEndMsg",PortalHelper.parseNull(rsWording.value("onboarding_end_msg")));
                wording.put("expiredMsg",PortalHelper.parseNull(rsWording.value("expired_msg")));
                wording.put("linkEmailSubject",PortalHelper.parseNull(rsWording.value("link_email_subject")));
                wording.put("linkEmailMsg",PortalHelper.parseNull(rsWording.value("link_email_msg")));
                wording.put("linkEmailSignature",PortalHelper.parseNull(rsWording.value("link_email_signat")));
                wording.put("linkSmsMsg",PortalHelper.parseNull(rsWording.value("link_sms_msg")));
                wording.put("language",PortalHelper.parseNull(rsWording.value("langue_code")).toUpperCase());
                
                wording = jsonObjectKeyCleanup(wording);
                if(wording.length() == 1 || wording.length() == 0)
                    continue;
                else    
                    wordings.put(wording);
            }
            resp.put("wordings",wordings);
        }
        return resp;
    }

    String convertImageToBase64(String imageName, String siteId) throws IOException {
        String imagePath = GlobalParm.getParm("COMMON_RESOURCES_PATH") + siteId + File.separator +"img"+ File.separator +imageName;

        File imageFile = new File(imagePath);
        FileInputStream fileInputStream = new FileInputStream(imageFile);
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

        byte[] buffer = new byte[1024];
        int bytesRead;
        while ((bytesRead = fileInputStream.read(buffer)) != -1) {
            byteArrayOutputStream.write(buffer, 0, bytesRead);
        }

        byte[] imageBytes = byteArrayOutputStream.toByteArray();

        fileInputStream.close();
        byteArrayOutputStream.close();

        String base64Image = Base64.getEncoder().encodeToString(imageBytes);
        return base64Image;
    }

    String getConfigCode(Contexte Etn, String siteId)
    {
        Set rs = Etn.execute("SELECT code FROM idcheck_configurations where site_id ="+escape.cote(siteId));
        if(rs.next())
        return PortalHelper.parseNull(rs.value("code"));
        return "";
    }

    JSONObject getConfiguration(JSONArray jsonArray, String code) throws JSONException 
    {
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonObject = jsonArray.getJSONObject(i);
            if(jsonObject.get("code").toString().equalsIgnoreCase(code))
                return jsonObject;
        }
        return null;
    }

%>
<%
	Logger.info("clientapis/idcheck/getConfiguration.jsp","--------------------------------------" );
	Logger.info("clientapis/idcheck/getConfiguration.jsp","in getConfiguration.jsp" );
	Logger.info("clientapis/idcheck/getConfiguration.jsp","--------------------------------------" );

    String message = "";
    String err_code = "";
    int status = 0;
    JSONObject json = new JSONObject();
    final String method = PortalHelper.parseNull(request.getMethod());
    final String accessToken = PortalHelper.parseNull(request.getHeader("access-token"));
    final String siteUuid = PortalHelper.parseNull(request.getHeader("site-uuid"));
    String langCode = PortalHelper.parseNull(request.getHeader("lang"));

    if("POST".equalsIgnoreCase(method) == false)
	{
		json.put("status", 100);
		json.put("err_code", "METHOD_NOT_SUPPORTED");
		json.put("err_msg", "Method '"+method+"' is not supported");
		out.write(json.toString());
		return;
	}

    final String API_ENDPOINT = GlobalParm.getParm("IDCHECK_END_POINT")+"configuration";
    final String siteId = getSiteId(Etn,siteUuid);
    

    if(accessToken.length() == 0)
    {       
        json.put("status", 401);
        json.put("err_code", "UNAUTHORIZED");
        json.put("err_msg", "Access token required");
        out.write(json.toString());
        return;
    }

    if(siteId.length() == 0)
    {
        json.put("status", 50);
        json.put("err_code", "SITE_ID_MISSING");
        json.put("err_msg", "Site id required");
        out.write(json.toString());
        return;
    }

    langCode = getLang(Etn,langCode,siteId);

    if(!CartHelper.isKycRequired(Etn, siteId))
    {
        json.put("status", 70);
        json.put("err_code", "IDCHECK_NOT_ACTIVE");
        json.put("err_msg", "Idcheck configuration is not active");
        out.write(json.toString());
        return;
    }
    
    String code = getConfigCode(Etn,siteId);
    
    if(code.length() == 0)
    {
        json.put("status", 50);
        json.put("err_code", "CONFIGURATION_NOT_FOUND");
        json.put("err_msg", "Configuration not found");
        out.write(json.toString());
        return;
    }

    try
	{       
		ApiCaller apiCaller = new ApiCaller(Etn);
		JSONObject jApiResp = fetchAllConfigurations(Etn,API_ENDPOINT,accessToken, apiCaller);
		if(jApiResp.getInt("status") == 0)
		{
			JSONArray jsonArray = new JSONArray(jApiResp.getString("response"));
			JSONObject custConf = getConfiguration(jsonArray,code);
			
			JSONObject jObj = null;
			if(custConf==null)
			{
				jApiResp = createConfigurations(Etn, API_ENDPOINT,accessToken,getConfigJson(Etn,siteId,langCode), apiCaller);
				if(jApiResp.getInt("status") == 0)
				{
					jObj = new JSONObject(jApiResp.getString("response"));
				}
			}
			else
			{
				jApiResp = updateConfigurations(Etn,API_ENDPOINT+"/"+code,accessToken,getConfigJson(Etn,siteId,langCode), apiCaller);
				if(jApiResp.getInt("status") == 0)
				{
					jObj = new JSONObject(jApiResp.getString("response"));
				}
			}

			if(jObj == null)
			{
				json.put("status", 95);
				json.put("err_code", "API_ERROR");
				json.put("err_msg", "API returned error");							
				json.put("err_details", jApiResp);
			}
            else if(jObj.has("errorCode"))
			{
				json.put("status", 20);
				json.put("err_code", jObj.getString("errorCode"));
				json.put("err_msg", jObj.getString("message"));
				out.write(json.toString());
				return;
			}
			else
			{
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
    out.write(json.toString());
%>
