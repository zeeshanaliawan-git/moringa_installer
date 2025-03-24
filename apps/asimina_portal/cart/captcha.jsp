<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>

<%@ include file="lib_msg.jsp"%>

<%@ include file="common.jsp"%>
<%

    String lang = parseNull(request.getParameter("lang"));
    String cap = parseNull(request.getParameter("g-recaptcha-response"));
    String prefix = getProductColumnsPrefix(Etn, request, lang);

    String langue_code = "";
    Set __rs1 = Etn.execute("select '0' as _a, langue_code from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".language where langue_code = " + escape.cote(lang) + " union select '1' as _a, langue_code from cat_moringa.language where langue_id =  0 order by _a ");
    if(__rs1.next()) langue_code = parseNull(__rs1.value("langue_code"));

    
    
        
	
%>
<!DOCTYPE html>
<% if(parseNull(langue_code).length() > 0) { %>
<html lang="<%=parseNull(langue_code)%>">
<% } else { %>
<html>
<% } %>
  <head>
    <title>Order Complete</title>
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/bootstrap__portal__.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/global__portal__.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/header__portal__.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orange_socialbar__portal__.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/cart.css">
<!--    <link rel="stylesheet" href="css/jquery-ui.min.css">
    <link rel="stylesheet" href="css/jquery-ui.structure.min.css">
    <link rel="stylesheet" href="css/jquery-ui.theme.min.css">-->
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/bootstrap.js"></script>
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
<!--    <script src="js/jquery-ui.min.js"></script>-->
    <script>
      $(document).ready(function(){
          
            alert("<%=cap%>");
      });

    </script>
    <style>
              
              .etn-orange-portal-- .o-breadcrumb > .o-active a{
                color:#777;
              }
            </style>
  </head>
  <body class="etn-orange-portal--">
      <%@ include file="header.jsp"%> 
    <section class="portal-cart o-payment o-container">
        
      <div class="o-row">
        <div class="o-jumbotron">
            <form action="captcha.jsp" method="POST">
      <div class="g-recaptcha" data-sitekey="6LeoKgkUAAAAAI9XeLkyYWpBmj2gccAfiFI_KU61"></div>
      <br/>
      <input type="submit" value="Submit">
    </form>
            <p><a class="o.btn o-btn-o-primary o-btn-lg" href="javascript:__gotoPortalHome();" role="button">Revenir aux achats</a></p>
          </div>
      </div>
    </section>
      <%@ include file="footer.jsp"%> 
  </body>
</html>