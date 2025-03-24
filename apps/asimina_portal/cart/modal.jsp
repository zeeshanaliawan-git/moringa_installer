<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>


<%@ include file="lib_msg.jsp"%>
<%@ include file="commonprice.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>
<%@ include file="menu.jsp"%>

<%   	
String json = "[]";
Cookie[] theCookies = request.getCookies();
if(theCookies != null) {
for (Cookie cookie : theCookies) { 
            //System.out.println(cookie.getName()+ " "+cookie.getValue());
            if(cookie.getName().equals(com.etn.beans.app.GlobalParm.getParm("CART_COOKIE"))) json = URLDecoder.decode(cookie.getValue(), "UTF-8");
          }
        }
    //System.out.println(json);

        Gson gson = new Gson();
        Type stringObjectMap = new TypeToken<List<Object>>(){}.getType();
        List<Object> list = gson.fromJson(json, stringObjectMap);



	//String id = parseNull(request.getParameter("id"));
        String prefix = getProductColumnsPrefix(Etn, request, lang);

        //System.out.println(rs.rs.Rows+""+ids);
        //System.out.println(lang);
	/*if(rs == null || rs.rs.Rows == 0)
	{
		out.write("<div style='color:red'>Error::No product found</div>");
		return;
	}*/
	//rs.next();

  String langue_code = "";
  Set __rs1 = Etn.execute("select '0' as _a, langue_code from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".language where langue_code = " + escape.cote(lang) + " union select '1' as _a, langue_code from language where langue_id =  0 order by _a ");
  if(__rs1.next()) langue_code = parseNull(__rs1.value("langue_code"));
  
	String _lastLoadedMenuId = "-1";
	Set ___rs23 = Etn.execute("select * from site_menus where menu_uuid = "+escape.cote(muid));
	if(___rs23.next()) _lastLoadedMenuId = parseNull(___rs23.value("id"));

  %>
  <!DOCTYPE html>
  <% if(parseNull(langue_code).length() > 0) { %>
  <html lang="<%=parseNull(langue_code)%>">
  <% } else { %>
  <html>
  <% } %>
  <head>
    <title>Portal Cart</title>
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/bootstrap__portal__.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/global__portal__.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/header__portal__.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orange_socialbar__portal__.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/cart.css">
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/bootstrap.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cart.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cookie.js"></script>
    <script>
      var ______portalurl = '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>';
      var ______menuid = '<%=_lastLoadedMenuId%>';
      var ______muid = '<%=muid%>';
      $(document).ready(function(){
        $(window).keydown(function(event){
          if(event.keyCode == 13) {
            event.preventDefault();
            return false;
          }
        });

        $('#buyall').on('click touch',function(){
          checkLogin('<%=com.etn.beans.app.GlobalParm.getParm("PORTAL_CONTEXTPATH")%>');
        });
        $('#close-login-popup').on('click touch',function(e){
          e.preventDefault();
          e.stopPropagation();

          $('#login-popup').removeClass('active');
        });

        $('#login').on('click touch',function(e){
          e.preventDefault();
          doLogin('<%=com.etn.beans.app.GlobalParm.getParm("PORTAL_CONTEXTPATH")%>');
        });

		if(typeof __checkLogin === "function") __checkLogin();
		else if(typeof asimina.cf.auth !== "undefined" && typeof asimina.cf.auth.checkLogin === "function") asimina.cf.auth.checkLogin();
        
      });
      
      function removeItem(index){
            //$(element).closest('li').remove();
            var productsArray = getCookieJSON('<%=com.etn.beans.app.GlobalParm.getParm("CART_COOKIE")%>');
            productsArray.splice(index,1);
            setCookieJSON('<%=com.etn.beans.app.GlobalParm.getParm("CART_COOKIE")%>',productsArray,7);
            window.location="cart.jsp";
          }


        </script>
        <style>
        body{
          min-height: 1000px;
        }
          .o-orange_modal {
            position: absolute;
            z-index: 9001;
            display: block;
            width: 100%;
            height: 400px;
            /*left: 5%;*/
            top: 50px;
            background: white;
            box-shadow: 0 0 20px 0 rgba(0,0,0,0.5);
          }
          .o-orange_modal .o-header.o-black, 
          .o-orange_modal .o-footer.o-black {
            height: auto;
            padding: 15px;
          }
          .o-orange_modal .o-content{
            padding: 15px;
            max-height: 300px;
            overflow: auto;
          }
        .o-overlay{
          display: none;
          position: absolute;
          left: 0;
          top: 0;
          z-index: 9000;
          width: 100%;
          height: 100%;
          overflow: hidden;
          background-color: rgba(0,0,0,0.5);
        }
        .o-overlay.o-active{
          display: block;
        }
        </style>
      </head>
      <body class="etn-orange-portal--">
      <div class="o-overlay o-active"></div>
        <%@ include file="header.jsp"%>
        <div class="portal-cart o-container" style='height: 1000px;'>
        <div class="o-orange_modal">
          <div class="o-header o-black">
            <h3 class="o-color-white o-bold">Terms and conditions</h3>
          </div>
          <div class="o-content">
            <p>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Vitae, pariatur nostrum! Repellat saepe eum sequi unde, qui consequatur, ea aut, nobis laboriosam corrupti reprehenderit! Laborum distinctio, cumque nesciunt minus at.
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Rem est quisquam tempora. Porro at cupiditate, ducimus nam ipsa nisi fuga minima magni delectus eligendi aspernatur, voluptas amet error voluptatibus! Placeat?

              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Hic beatae quae vel quo. Ex vitae ipsum, accusantium voluptas quos suscipit vero laborum quis velit expedita nemo atque eligendi at libero.
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Amet odio a impedit dolore, asperiores fugiat excepturi nam voluptas voluptatum ullam, quae iure velit, fugit ut atque perspiciatis sunt, rerum dolorum?
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quisquam, dignissimos repellat quae voluptate amet praesentium, maiores sapiente eligendi ex ad dolores non nesciunt cupiditate cum molestiae odio minus eum qui.
            </p>
            <p>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Vitae, pariatur nostrum! Repellat saepe eum sequi unde, qui consequatur, ea aut, nobis laboriosam corrupti reprehenderit! Laborum distinctio, cumque nesciunt minus at.
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Rem est quisquam tempora. Porro at cupiditate, ducimus nam ipsa nisi fuga minima magni delectus eligendi aspernatur, voluptas amet error voluptatibus! Placeat?

              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Hic beatae quae vel quo. Ex vitae ipsum, accusantium voluptas quos suscipit vero laborum quis velit expedita nemo atque eligendi at libero.
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Amet odio a impedit dolore, asperiores fugiat excepturi nam voluptas voluptatum ullam, quae iure velit, fugit ut atque perspiciatis sunt, rerum dolorum?
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quisquam, dignissimos repellat quae voluptate amet praesentium, maiores sapiente eligendi ex ad dolores non nesciunt cupiditate cum molestiae odio minus eum qui.
            </p>
            <p>
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Vitae, pariatur nostrum! Repellat saepe eum sequi unde, qui consequatur, ea aut, nobis laboriosam corrupti reprehenderit! Laborum distinctio, cumque nesciunt minus at.
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Rem est quisquam tempora. Porro at cupiditate, ducimus nam ipsa nisi fuga minima magni delectus eligendi aspernatur, voluptas amet error voluptatibus! Placeat?

              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Hic beatae quae vel quo. Ex vitae ipsum, accusantium voluptas quos suscipit vero laborum quis velit expedita nemo atque eligendi at libero.
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Amet odio a impedit dolore, asperiores fugiat excepturi nam voluptas voluptatum ullam, quae iure velit, fugit ut atque perspiciatis sunt, rerum dolorum?
              Lorem ipsum dolor sit amet, consectetur adipisicing elit. Quisquam, dignissimos repellat quae voluptate amet praesentium, maiores sapiente eligendi ex ad dolores non nesciunt cupiditate cum molestiae odio minus eum qui.
            </p>
          </div>
          <div class="o-footer o-black o-cf o-clearfix">
            <button type="button" class="o-btn o-orange-btn o-pull-right" style="background-color: #f16e00;color:#fff;"><strong>Fermer</strong></button>
          </div>
        </div>
        </div>
        <%@ include file="footer.jsp"%> 
  </body>
  </html>