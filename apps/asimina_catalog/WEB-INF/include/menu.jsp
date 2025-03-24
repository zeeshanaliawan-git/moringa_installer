<%
	String version = com.etn.beans.app.GlobalParm.getParm("APP_VERSION");
	if(version == null) version = "";
	else version = "v" + version;
%>

<style>
table.topMenu {
	margin-left:auto;
	margin-right:auto;
	width:1200px;
	/*border: 1px solid #CCCCCB;*/
	/*background-color: white;*/
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

<div style="border: 1px solid black;background: #222222;width: 100%;height: 60px;margin: 0px;">




<table width="100%" cellpadding="0" cellspacing="0" border="0" class="topMenu">
<tr>
<td style="vertical-align: top;padding-top: 20px;"><a href="../admin/gestion.jsp" style='color:green;font-weight:bold;font-size: 13pt;text-decoration: none;'>Asimina <%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%></a></td>

<td style="vertical-align: middle;" >
<ul class="topnav">
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
				String ____target = "";
				if("1".equals(____rs1.value("new_tab"))) ____target = " target='_blank' ";
%>
			<li><a href="<%=____u%>" <%=____target%>><%=____rs1.value("name")%></a></li>
			<li style="font-size: 10pt;vertical-align: middle;color:white;height:35px;padding-top:10px;"> </li>

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

			<li>
			<a href="javascript:void(0)"><%=____rsp.value("_parent")%></a>
			<ul class="subnav" style='z-index:9999'>
			<% while(____rs1.next()) {
				String ____u = parseNull(____rs1.value("url"));
				String ____target = "";
				if("1".equals(____rs1.value("new_tab"))) ____target = " target='_blank' ";
			%>
				<li><a href="<%=____u%>" <%=____target%>><%=____rs1.value("name")%></a></li>
			<% } %>
			</ul>
			</li>
			<li style="font-size: 10pt;vertical-align: middle;color:white;height:35px;padding-top:10px;"> </li>
<%	  	}
} %>
		<li>
			<a href="javascript:void(0)">Profil</a>
			<ul class="subnav" style='z-index:9999'>
				<li><a href="<%=request.getContextPath()+"/admin/changePassword.jsp"%>">Change Password</a></li>
			</ul>
		</li>
</ul>
</td>
<td align='left' style="vertical-align: top;padding-top: 20px;">
<span style='font-weight:bold; color: silver'><%=(String)session.getAttribute("LOGIN")%></span>
&nbsp;&nbsp;<span style='font-size:9pt;color:red'><%=version%></span>
</td>
</tr>

</table>


</div>




<br>
