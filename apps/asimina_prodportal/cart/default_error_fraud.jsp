<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="java.security.MessageDigest,java.security.NoSuchAlgorithmException" %>
<%@ page import="com.etn.asimina.util.*, com.etn.asimina.cart.*" %>


<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>
<%
    int stepNumber = 3;
	String _error_msg = "Some error occurred while processing cart";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "funnel";

	String ___muuid = CartHelper.getCartMenuUuid(request);

%>
<%@ include file="../logofooter.jsp"%>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css">
<%=_headhtml%>

    <style>
 .js-focus-visible body{
          height:auto;
      }
      
      .etnhf-gray-footer{
          display: none;
      }
     </style>
    </head>
      <body class="isWithoutMenu">
<%=_headerHtml%>

<article class="container-lg TunnelNotice">
    <div class="TunnelNotice-titleContainer">
        <span class="TunnelNotice-icon" data-svg="/src/assets/icons/icon-alert.svg"></span>
        <h3 class="TunnelNotice-title"><%=LanguageHelper.getInstance().getTranslation(Etn, "Votre commande n'a pas pu aboutir. Veuillez contacter le service client")%></h3>
    </div>

    <div class="TunnelNotice-bodyContainer">
        <img class="TunnelNotice-image" src="/src/assets/illustrations/illustration-maintenance.svg"/>

        <div class="TunnelNotice-contentContainer">
            <p class="TunnelNotice-textBold">
                La finalisation de votre commande n'a pas pu aboutir. Veuillez contacter notre service client par
                email <a href="mailto:service-client@orange.country">service-client@orange.country</a> ou par
                téléphone <a href="tel:0102030405">0102030405</a>, prix d’un appel local, gratuit pour les clients
                Orange.
            </p>
        </div>
    </div>
</article>

<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="star_sprite">
    <symbol id="icon-star" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.ast0{fill-rule:evenodd;clip-rule:evenodd;fill:#f16e00}</style><path
            id="aFill-1" class="ast0" d="M15 3l-3.8 8L2 12.6l6.9 6.1L6.6 28l8.4-4.6 8.4 4.6-2.3-9.3 6.9-6.1-9.2-1.6z"/></symbol>
    <symbol id="icon-star-empty" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.bst0{fill-rule:evenodd;clip-rule:evenodd;fill:#ccc}</style>
        <path id="bFill-1" class="bst0"
              d="M15 3l-3.8 8L2 12.6l6.9 6.1L6.6 28l8.4-4.6 8.4 4.6-2.3-9.3 6.9-6.1-9.2-1.6z"/></symbol>
    <symbol id="icon-star-half" viewBox="0 0 30 30" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><style>.cst0,.cst1{fill-rule:evenodd;clip-rule:evenodd;fill:#ccc}.cst1{fill:#f16e00}</style>
        <path class="cst0" d="M28 12.6L18.8 11 15 3v20.4l8.4 4.6-2.3-9.3z"/>
        <path class="cst1" d="M15 23.4V3l-3.8 8L2 12.6l6.9 6.1L6.6 28z"/></symbol>
</svg>

<script>

</script>
      <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js" ></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/focus-visible.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/popper.min.js" ></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/jquery.tablesorter.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/swiper.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/boosted.js" ></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bs-custom-file-input.min.js"></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/TweenMax.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/nouislider.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/algoliasearch.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/mobile-detect.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/sticky-sidebar.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/ResizeSensor.min.js"></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bundle.js"></script>
     <%=_footerHtml%>

    <%=_endscriptshtml%>

  </body>
    <script>

    jQuery(document).ready(function(){
        
    });
    </script>
</html>
