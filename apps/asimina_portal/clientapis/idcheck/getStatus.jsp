<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte,java.nio.charset.StandardCharsets, org.apache.http.HttpRequest, com.etn.beans.app.GlobalParm, org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="org.json.*, java.util.*, org.apache.http.client.methods.CloseableHttpResponse, org.apache.http.client.methods.*, org.apache.http.impl.client.CloseableHttpClient, org.apache.http.impl.client.HttpClients, org.apache.http.util.EntityUtils" %>
<%@ page import="org.apache.http.entity.StringEntity,org.apache.http.HttpHeaders,org.apache.http.entity.ContentType,java.io.BufferedReader,java.io.IOException,org.apache.http.HttpEntity,javax.servlet.http.Cookie,com.etn.asimina.util.PortalHelper,com.etn.asimina.beans.Cart,com.etn.asimina.cart.CartHelper, com.etn.asimina.util.PortalHelper, com.etn.asimina.util.ApiCaller, com.etn.util.Logger"%>

<%@include file="commonfunctions.jsp"%>
<%!
    JSONObject getIdnowStatus(Contexte Etn, String API_ENDPOINT, String token, String Uid) throws Exception 
	{
		ApiCaller apiCaller = new ApiCaller(Etn);
		Map<String, String> headers = new HashMap<>();
		headers.put("Authorization" ,"Bearer "+getIdnowToken(Etn,token));
		headers.put("Content-Type", "application/json;charset=UTF-8");
		
		JSONObject jApiResp = apiCaller.callApi("clientapis/idcheck/getStatus.jsp:getIdnowStatus", API_ENDPOINT+Uid+"/status", "GET", "", headers);
		return jApiResp;
    }

    void insertResponse(Contexte Etn, String uuid, String status, JSONObject resp)
    {
        Etn.execute("UPDATE idnow_sessions SET resp="+PortalHelper.escapeCote2(PortalHelper.parseNull(resp.toString()))+", status="+escape.cote(PortalHelper.parseNull(status))+", resp_timestamp=NOW() WHERE uuid="+escape.cote(uuid));  
    }
%>

<%
	Logger.info("clientapis/idcheck/getStatus.jsp","--------------------------------------" );
	Logger.info("clientapis/idcheck/getStatus.jsp","in getStatus.jsp" );
	Logger.info("clientapis/idcheck/getStatus.jsp","--------------------------------------" );

    JSONObject json = new JSONObject();
    final String method = PortalHelper.parseNull(request.getMethod());
    final String siteUuid = PortalHelper.parseNull(request.getHeader("site-uuid"));
    String accessToken = PortalHelper.parseNull(request.getHeader("access-token"));
    Cookie [] cookies = request.getCookies();

    if("POST".equalsIgnoreCase(method) == false)
	{
		json.put("status", 100);
		json.put("err_code", "METHOD_NOT_SUPPORTED");
		json.put("err_msg", "Method '"+method+"' is not supported");
		out.write(json.toString());
		return;
	}

    final String siteId = getSiteId(Etn,siteUuid);

    if(accessToken.length() == 0){
        accessToken = getAccessToken(cookies);
    }

    if(accessToken.length() == 0)
    {
        json.put("status", 40);
        json.put("err_code", "UNAUTHORIZED");
		json.put("err_msg", "Access token required");
        out.write(json.toString());
        return;
    }

    if(tokenExpiry(Etn,accessToken))
    {
        json.put("status", 40);
        json.put("err_code", "UNAUTHORIZED");
		json.put("err_msg", "Access token expired");
        out.write(json.toString());
        return;
    }

    if(siteId.length() == 0)
    {
        json.put("status", 60);
        json.put("err_code", "SITE_ID_MISSING");
		json.put("err_msg", "SITE ID Required");
        out.write(json.toString());
        return;
    }

    if(!CartHelper.isKycRequired(Etn, siteId))
    {
        json.put("status", 70);
        json.put("err_code", "IDCHECK_NOT_ACTIVE");
        json.put("err_msg", "Idcheck configuration is not active");
        out.write(json.toString());
        return;
    }
       
    try
	{                        
        String idnowUuid = getIdnowUuidForToken(Etn,accessToken);
		JSONObject jApiResp = getIdnowStatus(Etn,GlobalParm.getParm("IDCHECK_END_POINT")+"onboarding/",accessToken,getIdnowId(Etn,idnowUuid));
		if(jApiResp.getInt("status") == 0)
		{
			JSONObject jObj = new JSONObject(jApiResp.getString("response"));
			Logger.info("clientapis/idcheck/getStatus.jsp","---------------------------------------------");
			Logger.info("clientapis/idcheck/getStatus.jsp"," IDNOW RESPONSE JSON  = "+jObj.toString());
			Logger.info("clientapis/idcheck/getStatus.jsp","---------------------------------------------");
			
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
				json.put("data",jObj);
				Logger.info("clientapis/idcheck/getStatus.jsp","---------------------------------------------");
				Logger.info("clientapis/idcheck/getStatus.jsp"," INSERTING RESPONSE ");
				insertResponse(Etn, idnowUuid,jObj.getString("status"), jObj);
				Logger.info("clientapis/idcheck/getStatus.jsp","---------------------------------------------");
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
    
    json.put("status",0);
    
    Logger.info("clientapis/idcheck/getStatus.jsp","---------------------------------------------");
    Logger.info("clientapis/idcheck/getStatus.jsp"," RESPONSE JSON  "+json.toString() );
    Logger.info("clientapis/idcheck/getStatus.jsp","---------------------------------------------");
    out.write(json.toString());
%>