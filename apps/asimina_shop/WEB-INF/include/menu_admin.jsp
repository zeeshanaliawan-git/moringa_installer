<%
	String _version = com.etn.beans.app.GlobalParm.getParm("APP_VERSION");
	if(_version == null) _version = "";
	else _version = "v" + _version;
%>

<style>
table.topMenu {
	margin-left:auto;
	margin-right:auto;
	width: 1000px;
	border: 1px solid #CCCCCB;
	background-color: white;
	padding: 5px 5px 5px;
	font-size:8pt;
	z-index:9999;
}
</style>

<script type="text/javascript">
jQuery(document).ready(function(){

	jQuery("ul.subnav").parent().append("<span></span>"); //Only shows drop down trigger when js is enabled (Adds empty span tag after ul.subnav*)
	//jQuery("ul.subnav2").parent().append("<span></span>"); //Only shows drop down trigger when js is enabled (Adds empty span tag after ul.subnav*)

	jQuery("ul.topnav li span").click(function() { //When trigger is clicked...

		//Following events are applied to the subnav itself (moving subnav up and down)
		jQuery(this).parent().find("ul.subnav").slideDown('fast').show(); //Drop down the subnav on click

		jQuery(this).parent().hover(function() {
		}, function(){
			jQuery(this).parent().find("ul.subnav").slideUp('slow'); //When the mouse hovers out of the subnav, move it back up
		});

		//Following events are applied to the trigger (Hover events for the trigger)
		}).hover(function() {
			jQuery(this).addClass("subhover"); //On hover over, add class "subhover"
		}, function(){	//On Hover Out
			jQuery(this).removeClass("subhover"); //On hover out, remove class "subhover"
	});
	jQuery("ul.topnav li ul.subnav li.secondLevel").hover(function() {
		jQuery(this).addClass("subhover"); //On hover over, add class "subhover"
		//Following events are applied to the subnav itself (moving subnav up and down)
		jQuery(this).parent().find("ul.subnav2").slideDown('fast').show(); //Drop down the subnav on click
		
		}, function(){	//On Hover Out
			jQuery(this).parent().find("ul.subnav2").slideUp('slow'); //When the mouse hovers out of the subnav, move it back up
	});
});

</script>


<%
	Set ____rsp = Etn.execute("select case coalesce(p2.parent,'') when '' then p2.name else p2.parent end as _parent, " +
				" case coalesce(p2.parent,'') when '' then 0 else 1 end as _isparent, min(p2.rang) as rang " +
				" from page p, page p2 where p2.url = p.url group by _parent order by rang, _parent");


%>
<header>
    <nav class="navbar  navbar-inverse">
        <div class="container-fluid">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="#"><%=com.etn.beans.app.GlobalParm.getParm("APP_NAME") + " " + _version%> </a>
            </div>
            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">

				<ul class="nav navbar-nav">
				<% while(____rsp.next()) { 
						if("0".equals(____rsp.value("_isparent")))
						{
							String ____q = "select * from page p where p.name = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" and coalesce(p.parent) = '' ";
							if(!"admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")) && !"super_admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")))
							{
								____q = "select * from page p, page_profil pr where p.name = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" and coalesce(p.parent) = '' ";
								____q += " and pr.url = p.url " ;
								____q += " and pr.profil_id = " + com.etn.sql.escape.cote((String)session.getAttribute("PROFIL_ID"));
							}
							Set ____rs1 = Etn.execute(____q);
							if(____rs1.next())
							{
								String ____u = parseNull(____rs1.value("url"));
								if(!____u.startsWith("/") && !____u.toLowerCase().startsWith("http:") && !____u.toLowerCase().startsWith("https:")) ____u = request.getContextPath() + "/" + ____u;

								String ____target = "";
								if("1".equals(____rs1.value("new_tab"))) ____target = " target='_blank' ";
				%>		
							<li><a href="<%=____u%>" <%=____target%>><%=____rs1.value("name")%></a></li>
				<%			
							}
						}
						else
						{
							String ____q = "select * from page p where p.parent = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" ";
							if(!"admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")) && !"super_admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")))
							{
								____q = "select * from page p, page_profil pr where p.parent = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" ";
								____q += " and pr.url = p.url " ;
								____q += " and pr.profil_id = " + com.etn.sql.escape.cote((String)session.getAttribute("PROFIL_ID"));
							}
							____q += " order by rang, name ";
							Set ____rs1 = Etn.execute(____q);
							if(____rs1.rs.Rows == 0) continue;

				%>
							<li class="dropdown">
							<a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" href="javascript:void(0)"><%=____rsp.value("_parent")%><span class="caret"></span></a>
							<ul class="dropdown-menu">
							<% while(____rs1.next()) { 
								String ____u = parseNull(____rs1.value("url"));
								if(!____u.startsWith("/") && !____u.toLowerCase().startsWith("http:") && !____u.toLowerCase().startsWith("https:")) ____u = request.getContextPath() + "/" + ____u;


								String ____target = "";
								if("1".equals(____rs1.value("new_tab"))) ____target = " target='_blank' ";
							%>
								<li><a href="<%=____u%>" <%=____target%>><%=____rs1.value("name")%></a></li>
							<% } %>
							</ul>
							</li>
				<%	  	}
				} %>
						<li class="dropdown">
							<a class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false" href="javascript:void(0)">Profil<span class="caret"></span></a>
							<ul class="dropdown-menu">
								<li><a href="<%=request.getContextPath()+"/changePassword.jsp"%>">Change Password</a></li>
							</ul>
						</li>
				</ul>

                <ul class="nav navbar-nav navbar-right">
                    <li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                          You are logged in as <span class="user-name"><%=(String)session.getAttribute("LOGIN")%></span>
                        </a>
                    </li>
                </ul>
            </div>
            <!-- /.navbar-collapse -->
        </div>
        <!-- /.container-fluid -->
    </nav>
</header>
