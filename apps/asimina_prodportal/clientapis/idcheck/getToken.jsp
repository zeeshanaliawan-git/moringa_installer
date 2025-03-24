<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte,java.nio.charset.StandardCharsets, org.apache.http.HttpRequest, com.etn.beans.app.GlobalParm, org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="org.json.*, java.util.*, org.apache.http.client.methods.CloseableHttpResponse, org.apache.http.client.methods.*, org.apache.http.impl.client.CloseableHttpClient, org.apache.http.impl.client.HttpClients, org.apache.http.util.EntityUtils" %>
<%@ page import="org.apache.http.entity.StringEntity,javax.servlet.http.Cookie, com.etn.asimina.util.PortalHelper, com.etn.asimina.util.ApiCaller, com.etn.util.Logger"%>

<%@include file="commonfunctions.jsp"%>

<%!
    LocalDateTime getExpiryDateTime(String seconds){
        return LocalDateTime.now().plusSeconds(Integer.parseInt(seconds));
    }

    String generateToken(String token, String type, String refreshToken){
        return DigestUtils.sha256Hex("#:#"+token+"#:#"+type+"#:#"+refreshToken+"#:#");
    }

    String convertTimeToUTC(LocalDateTime datetime){
        LocalDateTime utcNow = datetime.atOffset(ZoneOffset.UTC).toLocalDateTime();
        DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
        String formattedDate = utcNow.format(formatter);
        return formattedDate.split("\\.")[0].replace("T", " ");
    }

    String getToken(Contexte Etn, JSONObject resp) throws Exception
    {
        String tokenExpiry = convertTimeToUTC(getExpiryDateTime(resp.get("expires_in").toString()));
        String refreshExpiry = convertTimeToUTC(getExpiryDateTime(resp.get("refresh_expires_in").toString()));
        String token = generateToken(resp.get("access_token").toString(),resp.get("token_type").toString(),resp.get("refresh_token").toString());
        Etn.executeCmd("insert into idcheck_access_tokens(token,access_token,access_token_expires_in,refresh_token,refresh_token_expires_in,token_type) VALUES ("+escape.cote(token)+","+escape.cote(resp.get("access_token").toString())+","+escape.cote(tokenExpiry)+","+escape.cote(resp.get("refresh_token").toString())+","+escape.cote(refreshExpiry)+","+escape.cote(resp.get("token_type").toString())+")");
        return token;
    }

    public JSONObject getIdCheckToken(Contexte Etn, String API_ENDPOINT, String grantType,String clientId,String username,String password,String broker) throws Exception 
	{
		ApiCaller apiCaller = new ApiCaller(Etn);
		Map<String, String> headers = new HashMap<>();
		headers.put("Content-Type", "application/x-www-form-urlencoded");

		String params = "grant_type=" + grantType + "&client_id=" + clientId + "&username=" + username + "&password=" + password + "&broker=" + broker;
		
		JSONObject jApiResp = apiCaller.callApi("clientapis/idcheck/getToken.jsp:getIdCheckToken", API_ENDPOINT, "POST", params, headers);
		return jApiResp;
    }

%>

<%
	Logger.info("clientapis/idcheck/getToken.jsp","--------------------------------------" );
	Logger.info("clientapis/idcheck/getToken.jsp","in getToken.jsp" );
	Logger.info("clientapis/idcheck/getToken.jsp","--------------------------------------" );

    String message = "";
    String err_code = "";
    int status = 0;
    JSONObject json = new JSONObject();

    final String method = PortalHelper.parseNull(request.getMethod());
    final String siteUuid = PortalHelper.parseNull(request.getHeader("site-uuid"));
    
    if("POST".equalsIgnoreCase(method) == false)
	{
		json.put("status", 100);
		json.put("err_code", "METHOD_NOT_SUPPORTED");
		json.put("err_msg", "Method '"+method+"' is not supported");
		out.write(json.toString());
		return;
	}

    try
    {

        final String siteId = getSiteId(Etn,siteUuid);
        final String API_ENDPOINT = PortalHelper.parseNull(GlobalParm.getParm("IDCHECK_GET_TOKEN_END_POINT"));
        final String grantType = PortalHelper.parseNull(GlobalParm.getParm("IDCHECK_GRANT_TYPE"));
        final String clientId = PortalHelper.parseNull(GlobalParm.getParm("IDCHECK_CLIENT_ID"));
        final String broker = PortalHelper.parseNull(GlobalParm.getParm("IDCHECK_BROKER"));

        Set rs = Etn.execute("SELECT * FROM idcheck_configurations where site_id="+escape.cote(siteId));
        rs.next();
            
        final String username = PortalHelper.parseNull(rs.value("email"));
        final String password = PortalHelper.parseNull(rs.value("password"));
            
        if(siteId.length() == 0)
        {
            json.put("status", 60);
            json.put("err_code", "SITE_ID_MISSING");
            json.put("err_msg", "Site id is required");
            out.write(json.toString());
            return;
        }

        if(grantType.length() == 0)
        {    
            json.put("status", 50);
            json.put("err_code", "GRANT_TYPE_MISSING");
            json.put("err_msg", "Grant type is not provided");
            out.write(json.toString());
            return;
        }

        if(clientId.length() == 0)
        {
            json.put("status", 30);
            json.put("err_code", "CLIENT_ID_MISSING");
            json.put("err_msg", "CLIENT ID IS REQUIRED");
            out.write(json.toString());
            return;
        }  

        if(username.length() == 0 && password.length() == 0 && broker.length() == 0)
        {
            json.put("status", 20);
            json.put("err_code", "REQUIRED_FIELDS_MISSING");
            json.put("err_msg", "Required fields missing");
            out.write(json.toString());
            return;
        }
                      
		JSONObject jApiResp = getIdCheckToken(Etn, API_ENDPOINT, grantType, clientId, username, password, broker);
		if(jApiResp.getInt("status") == 0)
		{
			JSONObject jsonObject = new JSONObject(jApiResp.getString("response"));
			if(jsonObject.has("error"))
			{
				json.put("status", 60);
				json.put("err_code", jsonObject.getString("error"));
				json.put("err_msg", jsonObject.getString("error_description"));
				out.write(json.toString());
				return;
			}
			else
			{
				String token = getToken(Etn,jsonObject);
				if(token.length()>0)
				{
					Cookie idnowCookie = new Cookie("__idnow", token);
					idnowCookie.setMaxAge(60 * 30);
					response.addCookie(idnowCookie);

					json.put("access_token",token);
					json.put("expires_in",jsonObject.getString("expires_in"));
				}			
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
        json.put("err_code", "SYSTEM_ERROR");
        json.put("err_msg", "Something went wrong");; 
        out.write(json.toString());
        return;
    }
    json.put("status",status);
    out.write(json.toString());
%>