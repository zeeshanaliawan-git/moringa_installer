<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64,org.json.*"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*, com.etn.beans.Contexte,org.apache.http.client.methods.CloseableHttpResponse, org.apache.http.client.methods.*, org.apache.http.impl.client.CloseableHttpClient, org.apache.http.impl.client.HttpClients, org.apache.http.util.EntityUtils"%>
<%@ page import="com.etn.asimina.data.LanguageFactory"%>
<%@ include file="/lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>

<%!
    Object getBlocHTML(Contexte Etn, String API_ENDPOINT, Map<String,String> params) throws Exception {
        CloseableHttpClient httpClient = HttpClients.createDefault();
        String urlParams = "?";
        for (Map.Entry<String,String> entry : params.entrySet()){
            urlParams += entry.getKey()+"="+entry.getValue()+"&";
        }
        urlParams = urlParams.substring(0,urlParams.length()-1);
        HttpGet request = new HttpGet(API_ENDPOINT+urlParams);
        try (CloseableHttpResponse response = httpClient.execute(request)) {
            String resp = EntityUtils.toString(response.getEntity());
            return resp;
        }
    }

    String getKycStatus(Contexte Etn, String cartId)
    {
        Set rs = Etn.execute("SELECT idnow_status from cart where id="+escape.cote(cartId)+" AND idnow_last_try_ts >= DATE_SUB(NOW(), INTERVAL 24 HOUR)");
        if(rs.next()) return parseNull(rs.value("idnow_status"));
        return "";
    }

%>
<%
    int stepNumber = 2;
    String _error_msg = "Some error occurred while processing cart";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "funnel";

	String ___muuid = CartHelper.getCartMenuUuid(request);
	String session_id = CartHelper.getCartSessionId(request);
%>

<%@ include file="/logofooter.jsp"%>

<%
    final String API_ENDPOINT = request.getScheme()+"://"+"localhost" + GlobalParm.getParm("PAGES_WEBAPP_URL") + "api/getBlocHtml.jsp";
    Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
    boolean logged = false;
    String client_id = "";
    String client_uuid = "";
	if(client != null)
	{
		logged = true;
		client_id = client.getProperty("id");
		client_uuid = client.getProperty("client_uuid");
	}
    Cart cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid, true);
    String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);

    final String langId = cart.getLangId();
    
    Set rsLang = Etn.execute("SELECT langue_code FROM language where langue_id="+escape.cote(langId));
    rsLang.next();

    final String langCode = parseNull(rsLang.value("langue_code"));

    Map<String,String> params = new HashMap<>();
    Set rs = Etn.execute("SELECT * FROM idcheck_configurations WHERE site_id="+escape.cote(___loadedsiteid));
    
    if(rs.next())
    {
        if ( parseNull(rs.value("bloc_uuid")).length() > 0 ) 
        {
            params.put("bloc_uuid",parseNull(rs.value("bloc_uuid")));
        }
        else{
            response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"cart.jsp?muid="+___muuid);
            return;
        }
    }else{
        response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"cart.jsp?muid="+___muuid);
        return;
    }

    params.put("lang_code",langCode);

    final String resp = getBlocHTML(Etn,API_ENDPOINT,params).toString();
    JSONObject respJson = new JSONObject(resp);
    
    respJson = new JSONObject(respJson.get("data").toString());

    Set rsDomain = Etn.execute("Select domain from sites where id = " + escape.cote(_menuRs.value("site_id")));
    rsDomain.next();
    Map<String, String> gtmScriptCode = getGtmScriptCodeForCart(Etn, _menuRs.value("id"), rsDomain.value(0)+com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"checkout.jsp", "funnel", "", "", "",client_uuid,"","",(logged?"yes":"no"), "");

    String cartId = cart.getProperty("id");
    String json= "";
    
%>

<!DOCTYPE HTML>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
    <%=parseNull(gtmScriptCode.get("NOSCRIPT_SNIPPET"))%>
    
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
<style>
    .loading2{
	  overflow: hidden;
	  position: relative;
  }
  
.loading2::after{
	  content: "";
	  overflow: hidden;
	  display : block;
	  position:   absolute;
	  z-index:    99999;
	  top:        0;
	  left:       0;
	  height:     100%;
	  width:      100%;
	  background: rgba( 255, 255, 255, .8 )
				  url('../img/spinner.gif')
				  50% 50%
				  no-repeat;
  
}
  
body.loading2::after{
	position: fixed;
}
  
.loading2 > .loading2msg{
	  position: absolute;
	  top : 55%;
	  width : 100%;
	  text-align: center;
	  z-index: 9999999;
}
body.loading2 > .loading2msg{
	position: fixed;
}	
</style>
    <%@ include file="stepbar.jsp"%>
    <%=parseNull(gtmScriptCode.get("NOSCRIPT_SNIPPET"))%>
    <%=_headerHtml%>
    
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
    
    
        <%=_footerHtml%>
        <%=_endscriptshtml%>


    <%
        JSONArray bodyJsFiles = new JSONArray(respJson.get("bodyJsFiles").toString());
        for(int i=0;i<bodyJsFiles.length();i++)
        {
    %>
        <script src="<%=bodyJsFiles.get(i)%>"></script>
    <%  
        }
    %>
    <div >
    <form method='post' action='<%=parseNull(GlobalParm.getParm("CART_EXTERNAL_LINK"))%>deliv.jsp' id="cart-step">
        <input type='hidden' name='session_token' value='<%=escapeCoteValue(uuidSessionToken)%>'>
    </form>
    </div>
    <script>
        function showLoader(msg, ele){

            if(typeof ele === "undefined") ele = $('body');

            ele.addClass('loading2');

            $(ele).find('div.loading2msg').remove();
            var msgEle = $('<div>').addClass('loading2msg');
            $(ele).append(msgEle);

            if(typeof msg !== 'undefined'){
                msgEle.html(msg);
            }
            else{
                msgEle.html("");
            }

        }

        function hideLoader(){
            $('.loading2').removeClass('loading2');
        }
        let tries = 0;
        function getIdnowStatus(){
                       
            $.ajax({
                url: asmPageInfo.clientApisUrl+'idcheck/getStatus.jsp', type: 'POST', dataType: 'json',
                headers: {
                    'site-uuid' : asmPageInfo.suid,
                    'lang' : asmPageInfo.lang,
                },
            })
            .done(function(resp) {
                let status = resp.data.status;
                if(status == "EXPIRED" || status == "ERROR" ){    
                    setTimeout(()=>{
                        $('#cart-step').attr('action', 'kyc_error.jsp');
                        $("#cart-step").submit();
                    }, 3000);
                }
                if(status == "NAVIGATION_END" || status == "SUCCESS") 
                {
                    $("#cart-step").submit();
                }
            })
            .fail(function() {
               
            })
            .always(function() {
            });
        }


        window.addEventListener('message', function(event) {
            getIdnowStatus();
        });
    </script>
    
</body>
