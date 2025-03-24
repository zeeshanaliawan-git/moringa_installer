<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte,java.nio.charset.StandardCharsets, org.apache.http.HttpRequest, com.etn.beans.app.GlobalParm, org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="org.json.*, java.util.*, org.apache.http.client.methods.CloseableHttpResponse, org.apache.http.client.methods.*, org.apache.http.impl.client.CloseableHttpClient, org.apache.http.impl.client.HttpClients, org.apache.http.util.EntityUtils, com.etn.asimina.util.ApiCaller" %>
<%@ page import="org.apache.http.entity.StringEntity,org.apache.http.HttpHeaders,org.apache.http.entity.ContentType,java.io.BufferedReader,java.io.IOException,org.apache.http.HttpEntity,javax.servlet.http.Cookie,com.etn.asimina.util.PortalHelper,com.etn.asimina.beans.Cart,com.etn.asimina.cart.CartHelper, com.etn.util.Logger"%>

<%@include file="commonfunctions.jsp"%>

<%!
    String getIdnowResponse(Contexte Etn, String idnowUuid)
    {
        Set rs = Etn.execute("SELECT resp FROM idnow_sessions WHERE uuid="+escape.cote(idnowUuid));
        if(rs.next()) return PortalHelper.parseNull(rs.value("resp"));
        return "";
    }

%>

<%
	Logger.info("clientapis/idcheck/getFileCheckReport.jsp","--------------------------------------" );
	Logger.info("clientapis/idcheck/getFileCheckReport.jsp","in getFileCheckReport.jsp" );
	Logger.info("clientapis/idcheck/getFileCheckReport.jsp","--------------------------------------" );
    JSONObject json = new JSONObject();
    final String method = PortalHelper.parseNull(request.getMethod());
    final String siteUuid = PortalHelper.parseNull(request.getHeader("site-uuid"));
    String accessToken = PortalHelper.parseNull(request.getHeader("access-token"));
    Cookie [] cookies = request.getCookies();
	
	Etn.setSeparateur(2, '\001', '\002');
	Logger.info("clientapis/idcheck/getFileCheckReport.jsp","access-token:"+accessToken );
	Logger.info("clientapis/idcheck/getFileCheckReport.jsp","siteUuid:"+siteUuid );

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
       
    try{             
		
        Set rs = Etn.execute("SELECT * FROM idcheck_configurations where site_id="+escape.cote(siteId));
        rs.next();
            
        final String username = PortalHelper.parseNull(rs.value("email"));
        final String password = PortalHelper.parseNull(rs.value("password"));
		
        final String API_ENDPOINT = PortalHelper.parseNull(GlobalParm.getParm("IDCHECK_GET_TOKEN_END_POINT"));
        final String grantType = PortalHelper.parseNull(GlobalParm.getParm("IDCHECK_GRANT_TYPE"));
        final String clientId = PortalHelper.parseNull(GlobalParm.getParm("IDCHECK_CLIENT_ID"));
        final String broker = PortalHelper.parseNull(GlobalParm.getParm("IDCHECK_BROKER"));

		String idnowResp = getIdnowResponse(Etn, getIdnowUuidForToken(Etn,accessToken));
		if(idnowResp.length() > 0)
		{
			JSONObject jIdnowResp = new JSONObject(idnowResp);
			if(jIdnowResp.optString("status","").equalsIgnoreCase("SUCCESS"))
			{
				JSONObject jResult = jIdnowResp.getJSONObject("result");
				if(jResult.has("cisData"))
				{
					ApiCaller apiCaller = new ApiCaller(Etn);
					Map<String, String> headers = new HashMap<>();
					headers.put("Authorization" ,"Bearer "+getIdnowToken(Etn,accessToken));
					headers.put("Content-Type", "application/json;charset=UTF-8");
					
					JSONObject jCisData = jResult.getJSONObject("cisData");
					String fileCheckUid = jCisData.optString("fileCheckUid", "");
					String cisFileUid = jCisData.optString("cisFileUid", "");
					String realm = jCisData.optString("realm", "");
					
					if(fileCheckUid.length() > 0)
					{					
						JSONObject jApiResp = apiCaller.callApi("clientapis/idcheck/getFileCheckReport.jsp:getCheckReport", GlobalParm.getParm("IDNOW_CIS_BASE_URL") + "rest/v1/"+realm+"/file/"+cisFileUid+"/check/"+fileCheckUid, "GET", "", headers);
						if(jApiResp.getInt("status") == 0)
						{
							JSONObject jApiResponse = new JSONObject(jApiResp.getString("response"));
							json.put("status", 0);
							json.put("results", jApiResponse);
						}
						else
						{
							json.put("status", 95);
							json.put("err_code", "API_ERROR");
							json.put("err_msg", "API returned error");							
							json.put("err_details", jApiResp);
						}
					}					
				}
			}
			else
			{
				json.put("status", 91);
				json.put("err_code", "IDCHECK_NOT_SUCCESS");
				json.put("err_msg", "KYC status is :"+jIdnowResp.optString("status",""));
			}		
		}
		else
		{
			json.put("status", 92);
			json.put("err_code", "EMPTY_RESPONSE");
			json.put("err_msg", "KYC response is empty");
		}
    }
    catch(Exception e)
    {
		e.printStackTrace();
        json.put("status", 90);
        json.put("err_code", "SERVER_ERROR");
        json.put("err_msg", "Something went wrong");
    }
            
    Logger.info("clientapis/idcheck/getFileCheckReport.jsp","---------------------------------------------");
    Logger.info("clientapis/idcheck/getFileCheckReport.jsp"," RESPONSE JSON  "+json.toString() );
    Logger.info("clientapis/idcheck/getFileCheckReport.jsp","---------------------------------------------");
    out.write(json.toString());
%>