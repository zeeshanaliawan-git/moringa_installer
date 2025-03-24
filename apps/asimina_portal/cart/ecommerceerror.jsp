<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="java.security.MessageDigest,java.security.NoSuchAlgorithmException" %>


<%@ include file="lib_msg.jsp"%>
<%@ include file="commonprice.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>

<%
    int stepNumber = 3;
	String _error_msg = "Some error occurred while processing cart";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "cart";	
%>
<%@ include file="../headerfooter.jsp"%>
  <!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css">
<%=_headhtml%>
    </head>
      <body class="isWithoutMenu">
<%=_headerHtml%>
<br>
<br>
<br>
<br>
<br>
<article class="container-lg TunnelNotice">
    <div class="TunnelNotice-titleContainer">
        <span class="TunnelNotice-icon" data-svg="/src/assets/icons/icon-alert.svg"></span>
        <h3 class="TunnelNotice-title" style="color:red !important"><%=libelle_msg(Etn, request, "You are not authorized to view cart. Contact administrator")%></h3>
    </div>
</article>
<br>
<br>
<br>
<br>
<br>
     <%=_footerHtml%>

    <%=_endscriptshtml%>

  </body>
</html>
