<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<script type="text/javascript" src="js/jquery-latest.js"></script> 


<style>
body {
	margin: 0; padding: 0;
	font: 10px normal Arial, Helvetica, sans-serif;
	background: #ddd url(body_bg.gif) repeat-x;  /* a voir  */
}
.container {
	width: 960px;
	margin: 0 auto;
	position: relative;
}
#header {
	background: url(logo.non) no-repeat center top;
	padding-top: 120px;
}
#header .disclaimer {
	color: #999;
	padding: 100px 0 7px 0;
	text-align: right;
	display: block;
	position: absolute;
	top: 0; right: 0;
}
#header .disclaimer a {	color: #ccc;}

ul.topnav {
	list-style: none;
	padding: 0 20px;
	margin: 0;
	float: left;
	width: 920px;
	background: #222;
	font-size: 1.2em;
	background: url(img/bla.jpg) repeat-x;  /* a Voir couleur pm: image 1,31 pixel format jpg */
}
ul.topnav li {
	float: left;
	margin: 0;
	padding: 0 15px 0 0;
	position: relative; /*--Declare X and Y axis base for sub navigation--*/
}
ul.topnav li a{
	padding: 10px 5px;
	color: #fff;
	display: block;
	text-decoration: none;
	float: left;
}
ul.topnav li a:hover{
	background: url(img/orange3.jpg) repeat-x; /* no-repeat center top;*/
}
ul.topnav li span { /*--Drop down trigger styles--*/
	width: 17px;
	height: 35px;
	float: left;
	background: url(img/subnav_btn.gif) no-repeat center top;
}
ul.topnav li span.subhover {background-position: center bottom; cursor: pointer;} /*--Hover effect for trigger--*/
ul.topnav li ul.subnav {
	list-style: none;
	position: absolute; /*--Important - Keeps subnav from affecting main navigation flow--*/
	left: 0; top: 35px;
	background: #333;
	margin: 0; padding: 0;
	display: none;
	float: left;
	width: 170px;
	border: 1px solid #111;
}
ul.topnav li ul.subnav li{
	margin: 0; padding: 0;
	border-top: 1px solid #252525; /*--Create bevel effect--*/
	border-bottom: 1px solid #444; /*--Create bevel effect--*/
	clear: both;
	width: 170px;
}
html ul.topnav li ul.subnav li a {
	float: left;
	width: 145px;
	background: #333 url(img/dropdown_linkbg.gif) no-repeat 10px center;
	padding-left: 20px;
}
html ul.topnav li ul.subnav li a:hover { /*--Hover effect for subnav links--*/
	background: #222 url(img/dropdown_linkbg.gif) no-repeat 10px center;
}
</style>


<script type="text/javascript">
$(document).ready(function(){

	$("ul.subnav").parent().append("<span></span>"); //Only shows drop down trigger when js is enabled (Adds empty span tag after ul.subnav*)

	$("ul.topnav li span").click(function() { //When trigger is clicked...

		//Following events are applied to the subnav itself (moving subnav up and down)
		$(this).parent().find("ul.subnav").slideDown('fast').show(); //Drop down the subnav on click

		$(this).parent().hover(function() {
		}, function(){
			$(this).parent().find("ul.subnav").slideUp('slow'); //When the mouse hovers out of the subnav, move it back up
		});

		//Following events are applied to the trigger (Hover events for the trigger)
		}).hover(function() {
			$(this).addClass("subhover"); //On hover over, add class "subhover"
		}, function(){	//On Hover Out
			$(this).removeClass("subhover"); //On hover out, remove class "subhover"
	});

});

</script>


</head>

<body>
<%
boolean admin = ((String)session.getAttribute("PROFIL")).equals("ADMIN");
boolean super_adm = (((String)session.getAttribute("PROFIL")).equals("SUPER_ADMIN") || ((String)session.getAttribute("PROFIL")).equals("SUPER_ADMIN_SPAIN"));
boolean logistic = ((String)session.getAttribute("PROFIL")).equals("LOGISTICS");
boolean mgractiv = ((String)session.getAttribute("PROFIL")).equals("MGR_ACTIVE");
boolean mgrtele = ((String)session.getAttribute("PROFIL")).equals("MGR_TELE");
boolean csrtele = ((String)session.getAttribute("PROFIL")).equals("CSR_TELE");
boolean csractiv = ((String)session.getAttribute("PROFIL")).equals("CSR_ACTIVE");
%>

<table width="100%" cellpadding="0" cellspacing="0" border="0">
<tr>

<td style="padding: 2px 2px 2px 2px;" width="5%"><img src="<%=request.getContextPath()%>/img/logo.png"></td>
						<td class="titletop"  align="left" nowrap="nowrap" width="85%">&nbsp;Guizmo&nbsp;<span style="color: #313131;">&nbsp;Espa�a</span></td>


<td>						
<ul class="topnav">
    <li><a href="ibo.jsp">Liste Pedidos</a></li>

<% if( admin || super_adm ) { %>
    <li>
        <a href="#">Gesti�n</a>
        <ul class="subnav">
            <li><a href="mapterm.jsp">Terminales</a></li>
            <li><a href="maptar.jsp">Tarifas</a></li>
            <li><a href="mail_sms/modele.jsp">SMS/Mail</a></li>
            <li><a href="fraud.jsp">Lista Cara Dura</a></li>
        </ul>
    </li>
<% } else if( mgrtele || mgractiv ) { %>
   <li>
        <a href="#">Gesti�n</a>
        <ul class="subnav">
            <li><a href="mail_sms/modele.jsp">SMS/Mail</a></li>
            <li><a href="fraud.jsp">Lista Cara Dura</a></li>
        </ul>
    </li>
<% } 

if( super_adm ) { %>

    <li><a href="viewProcess.jsp">Process Flow</a></li>

<% } 
 
if( super_adm || admin || logistic ) { %>

    <li>
        <a href="#">Stock</a>
        <ul class="subnav">
            <li><a href="stock/stock.jsp">Existencias</a></li>
            <li><a href="stock/upload.jsp">T�l�chargement</a></li>
        </ul>
    </li>
<% } 

if( super_adm || admin || mgractiv || mgrtele ) { %>

    <li><a href="#">Statistics</a>
     <ul class="subnav">
            <li><a href="requeteur/admin/liste_requete.jsp">Requeteur</a></li>
            <li><a href="#">Suivi</a></li>
        </ul>
    </li>
<% } %>

    <li><a href="#">User</a>
        <ul class="subnav">
            <li><a href="changePassword.jsp">Change Password</a></li>
<% if( super_adm || admin || mgractiv || mgrtele ) { %>
            <li><a href="admin/userManagement.jsp">Manage Users</a></li>
<% } %>
        </ul>
    </li>

<% if( super_adm || admin ) { %>
    <li><a href="http://www.etancesys.com/es_ws/">Simul</a></li>
<% } %>

    <li><a href="#">Others 2</a></li>
    <li><a href="javascript:loadToucan()">Submit a problem</a></li>
    <li><a href="help.html">?</a></li>
</ul>
</td>
<td style="padding: 2px 2px 2px 2px;" width="5%"><img src="/mshop/img/logo_guizmo.png"></td>
</tr>
</table>
</body>

</html>
