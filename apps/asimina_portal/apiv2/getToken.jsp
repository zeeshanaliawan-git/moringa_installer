<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte,java.nio.charset.StandardCharsets, org.apache.http.HttpRequest, com.etn.beans.app.GlobalParm,org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="org.json.*, java.util.*" %>


<%!
    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    String convertTimeToUTC(LocalDateTime datetime){
        LocalDateTime utcNow = datetime.atOffset(ZoneOffset.UTC).toLocalDateTime();
        DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
        String formattedDate = utcNow.format(formatter);
        return formattedDate.split("\\.")[0].replace("T", " ");
    }

    LocalDateTime getCurrentDateTime(){
        return LocalDateTime.now();
    }

    LocalDateTime getExpiryDatetime(){
        return LocalDateTime.now().plusSeconds(Long.parseLong(getTokenExpirySeconds()));
    }

    String generateToken(String apiId,String apiKey,String currentDatetime, String expiryDateTime){
        return DigestUtils.sha256Hex("#:#"+apiId+"#:#"+apiKey+"#:#"+currentDatetime+"#:#"+expiryDateTime);
    }

    String [] getNewToken(Contexte Etn, String apiId, String apiKey)
    {
        String currentDatetime = convertTimeToUTC(getCurrentDateTime());
        String expiryDatetime = convertTimeToUTC(getExpiryDatetime());
        String token = generateToken(apiId,apiKey,currentDatetime,expiryDatetime);
        String [] resp = { token, getTokenExpirySeconds()};
        Etn.executeCmd("insert into "+GlobalParm.getParm("COMMONS_DB")+".access_tokens(token, api_id, api_key,issue_at,expiration) VALUES ("+escape.cote(token)+","+escape.cote(apiId)+","+escape.cote(apiKey)+","+escape.cote(currentDatetime)+","+escape.cote(expiryDatetime)+")");
        return resp;
    }
	
	String getTokenExpirySeconds()
	{
		String s = parseNull(GlobalParm.getParm("TOKEN_EXPIRY"));
		if(s.length() == 0) s = "1800";
		return s;
	}

%>

<%
    String message = "";
    String err_code = "";
    int status = 0;
    JSONObject json = new JSONObject();
    JSONObject data = new JSONObject();

	final String authorization = request.getHeader("Authorization");

    if(authorization!=null && authorization.toLowerCase().startsWith("basic"))
    {
        String base64Credentials = authorization.substring("Basic".length()).trim();
        byte[] credDecoded = Base64.getDecoder().decode(base64Credentials);
        String credentials = new String(credDecoded, StandardCharsets.UTF_8);
        final String[] values = credentials.split(":");

        if(values.length>=2)
        {
            String apiId = values[0];
            String apiKey = values[1];
            System.out.println("apiId: " + apiId);
            System.out.println("apiKey: " + apiKey);
			String isProd = "0";
			if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))) isProd = "1";
			
            Set rs = Etn.execute("SELECT * FROM "+GlobalParm.getParm("COMMONS_DB")+".api_keys WHERE `id`="+escape.cote(parseNull(apiId))+" and `is_prod`="+escape.cote(isProd)+" and `key`="+escape.cote(parseNull(apiKey)));
            if(rs.rs.Rows == 0)
            {   
                status = 10;
                err_code = "INVALID_CREDENTIALS";
                message = "Invalid API ID or KEY";        
            }
            else
            {
                rs.next();
                String isActive = parseNull(rs.value("is_active"));
                if(!isActive.equals("1"))
                {
                    status = 20;
                    err_code = "API_KEY_IS_INACTIVE";
                    message = "Provided API KEY is inactive";
                }else{
                    String [] tokenInfo = getNewToken(Etn, apiId, apiKey);
                    if(tokenInfo!=null)
                    {
                        data.put("access_token", tokenInfo[0]);
                        data.put("expires_in", Integer.parseInt(tokenInfo[1]));
                        data.put("type", "Bearer");
                    }
                    else
                    {
                        status = 60;
                        err_code = "SYSTEM_ERROR";
                        message = "Something went wrong";   
                    }
                }
            }
        }
        else{
            status = 30;
            err_code = "API_ID_OR_KEY_DOES_NOT_EXIST";
            message = "API ID or KEY required";
        }
    }else{
        status = 50;
        err_code = "AUTH_TOKEN_MISSING";
        message = "Basic Authorization Required";
    }
    
    json.put("status",status);

    if(err_code.length() > 0 && status > 0)
    {
        json.put("err_code",err_code);
        json.put("err_msg",message);
    }else{
        json.put("data",data);
    }

    out.write(json.toString());
%>