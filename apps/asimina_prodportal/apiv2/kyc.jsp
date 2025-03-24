<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64,org.json.*"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*, com.etn.beans.Contexte,org.apache.http.client.methods.CloseableHttpResponse, org.apache.http.client.methods.*, org.apache.http.impl.client.CloseableHttpClient, org.apache.http.impl.client.HttpClients, org.apache.http.util.EntityUtils"%>
<%@ include file="../../lib_msg.jsp"%>
<%@ include file="../../common.jsp"%>

<%!
    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    Object getBlocHTML(Contexte Etn, String API_ENDPOINT, Map<String,String> params) throws Exception {
        CloseableHttpClient httpClient = HttpClients.createDefault();
        String urlParams = "?";
        for (Map.Entry<String,String> entry : params.entrySet()){
            urlParams += entry.getKey()+"="+entry.getValue()+"&";
        }
        urlParams = urlParams.substring(0,urlParams.length()-1);
        System.out.println("urlParams: " + urlParams);
        HttpGet request = new HttpGet(API_ENDPOINT+urlParams);
        try (CloseableHttpResponse response = httpClient.execute(request)) {
            String resp = EntityUtils.toString(response.getEntity());
            return resp;
        }
    }

%>

<%
    int stepNumber = 1; 
	String _error_msg = "Some error occurred while processing cart";
	String __pageTemplateType = "funnel";

	String ___muuid = CartHelper.getCartMenuUuid(request);
	String session_id = CartHelper.getCartSessionId(request);
        
%>
<%@ include file="../logofooter.jsp"%>
<%
    final String API_ENDPOINT = request.getScheme()+"://"+"localhost" + GlobalParm.getParm("PAGES_WEBAPP_URL") + "api/getBlocHtml.jsp";
    
    Map<String,String> params = new HashMap<>();

    params.put("bloc_uuid","da91716d-69b9-4aaa-820a-b7d10d7aa253");
    params.put("lang_code","FR");

    String resp = getBlocHTML(Etn,API_ENDPOINT,params).toString();
    JSONObject respJson = new JSONObject(resp);
    
    respJson = new JSONObject(respJson.get("data").toString());
%>

<!DOCTYPE HTML>
<html >
<head>
    <%=_headhtml%>
    
    <%
        JSONArray headCssFiles = new JSONArray(respJson.get("headCssFiles").toString());
        for(int i=0;i<headCssFiles.length();i++)
        {
    %>
            <link rel="stylesheet" href="<%=headCssFiles.get(i)%>">
    <%  
        }
    %>

    <%
        JSONArray headJsFiles = new JSONArray(respJson.get("headJsFiles").toString());
        for(int i=0;i<headJsFiles.length();i++)
        {
    %>
            <script src="<%=headJsFiles.get(i)%>"></script>
    <%  
        }
    %>
</head>
<body>

    <%=_headerHtml%>
    <%@ include file="../../cart/stepbar.jsp"%>
    
    <%
        JSONArray bodyCssFiles = new JSONArray(respJson.get("bodyCssFiles").toString());
        for(int i=0;i<bodyCssFiles.length();i++)
        {
    %>
            <link rel="stylesheet" href="<%=bodyCssFiles.get(i)%>">
    <%  
        }
    %>
    <%=respJson.get("blocHtml").toString()%>
    <%
        JSONArray bodyJsFiles = new JSONArray(respJson.get("bodyJsFiles").toString());
        for(int i=0;i<bodyJsFiles.length();i++)
        {
    %>
        <script src="<%=bodyJsFiles.get(i)%>"></script>
    <%  
        }
    %>
</body>