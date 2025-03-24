<%@page import="com.etn.beans.Etn"%>
<style>
table.topMenu {
	margin-left:auto;
	margin-right:auto;
	width: 1024px;
	/*border: 1px solid #CCCCCB;*/
	background-color: #FFFFFF;
	/*padding: 5px 5px 5px;*/
	/*border-bottom:2px solid #000000;*/
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
	onNewOrder = function()
	{

	};	
});

</script>
<%
//	Set rs = Etn.execute("SELECT form_id, form_name FROM form_fields_generic_process WHERE rule_field = " + escape.cote("1") + " GROUP BY form_id, form_name;");
	Set rs = Etn.execute("SELECT * FROM process_forms order by process_name ");

%>

<div>
<table width="100%" cellpadding="0" cellspacing="0" border="0">

<tr>
<td>

<table width="100%" cellpadding="0" cellspacing="0" border="0" class="topMenu">

<tr class="bandeau_arcencell" >

<td  style="vertical-align: middle; background: #222222;">

<ul class="topnav">

    <li style="padding-top:10px;">
        <a href="#"><label  style="cursor:pointer ">PROCESS</label></a>
        <ul class="subnav" style="z-index: 5;">
        	<%
        		while(rs.next()){
			%>
					<li><a href='<%=request.getContextPath()%>/search.jsp?___fid=<%= rs.value("form_id")%>' ><label  style="cursor:pointer "><%= rs.value("process_name")%></label></a></li>
			<%
	        	}
        	%>
        </ul>

    </li>

    <li style="padding-top:10px;">
        <a href="#"><label  style="cursor:pointer ">FILTERS</label></a>
        <ul class="subnav" style="z-index: 5;">
        	<%
        		rs.moveFirst();
        		while(rs.next()){
			%>
					<li><a href='<%=request.getContextPath()%>/defineFilters.jsp?fid=<%= rs.value("form_id")%>' ><label  style="cursor:pointer "><%= rs.value("process_name")%></label></a></li>
			<%
	        	}
        	%>
        </ul>

    </li>

    <li style="padding-top:10px;">
        <a href="#"><label  style="cursor:pointer ">ADMIN</label></a>
        <ul class="subnav" style="z-index: 5;">
			<li><a href='<%=request.getContextPath()%>/process.jsp' ><label  style="cursor:pointer ">Process definition</label></a></li>
        </ul>

    </li>
	<li style="padding-top:10px;"><a href="<%=request.getContextPath()%>/ruleNewCreation.jsp" ><label  style="color:#fff;cursor:pointer ">RULES</label></a></li>
</ul>
</td>

</tr>

</table>
</td>
</tr>
</table>
</div>