<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.asimina.util.ActivityLog"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<%@ include file="common.jsp"%>

<%!
	String getSiteStatus(com.etn.beans.Contexte Etn, String siteid)
	{
		String proddb = com.etn.beans.app.GlobalParm.getParm("PROD_DB");
		String status = "NOT_PUBLISHED";
		Set rs = Etn.execute("select * from "+proddb+".sites where id = " + escape.cote(siteid));
		if(rs.rs.Rows == 0)
		{
			return status;
		}
		status = "PUBLISHED";
		rs = Etn.execute("select case when s1.version = s2.version then '1' else '0' end from sites s1, "+proddb+".sites s2 where s1.id = s2.id and s1.id = " + escape.cote(siteid));
		rs.next();
		if(rs.value(0).equals("0"))
		{
			status = "NEEDS_PUBLISH";
			return status;
		}
		rs = Etn.execute("select * from site_menus where is_active = 1  and deleted = 0 and site_id = " + escape.cote(siteid));
		while(rs.next())
		{
			Set rs1 = Etn.execute("select * from "+proddb+".site_menus where id = " + escape.cote(rs.value("id")));
			if(rs1.next() && !parseNull(rs.value("version")).equals(parseNull(rs1.value("version"))) )
			{
				status = "NEEDS_PUBLISH";
				break;
			}
		}
		return status;
	}

	String getMenuStatus(com.etn.beans.Contexte Etn, String menuid)
	{
		String proddb = com.etn.beans.app.GlobalParm.getParm("PROD_DB");
		String status = "NOT_PUBLISHED";
		Set rs = Etn.execute("select * from "+proddb+".site_menus where id = " + escape.cote(menuid));
		if(rs.rs.Rows == 0)
		{
			return status;
		}
		status = "PUBLISHED";
		rs = Etn.execute("select case when m1.version = m2.version then '1' else '0' end from site_menus m1, "+proddb+".site_menus m2 where m1.id = m2.id and m1.id = " + escape.cote(menuid));
		rs.next();
		if(rs.value(0).equals("0"))
		{
			status = "NEEDS_PUBLISH";
		}
		return status;
	}
%>
<%
	Set _rs1 = Etn.execute("select * from page where url like  "+escape.cote("%"+request.getContextPath() + "/pages/site.jsp"));
	if(_rs1.rs.Rows == 0)
	{
		response.sendRedirect(request.getContextPath() + "/pages/siteparameters.jsp");
		return;
	}

	String siteid = parseNull(getSiteId(request.getSession()));
	
	Set _rsM = Etn.execute("Select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".site_menus where site_id = "+escape.cote(siteid)+" and menu_version = 'V2' and is_active = 1");
	if(_rsM.next())
	{
		//v2 menu has more preference which must be cached from clear cache screen so we redirect to it
		response.sendRedirect(request.getContextPath() + "/pages/cachemanagement.jsp");
		return;
	}
	
	
	String activeslct = parseNull(request.getParameter("activeslct"));
	if(activeslct.length() == 0) activeslct = "1";

	if("1".equals(parseNull(request.getParameter("issave"))))
	{
		String[] mids = request.getParameterValues("menuid");
		String[] isactives = request.getParameterValues("isactive");
		String[] prefs = request.getParameterValues("pref");
		if(mids !=null)
		{
            String ids = "";
            String manus = "";
			for(int i =0 ;i<mids.length; i++)
			{
                Set rs =  Etn.execute("select name from site_menus where id = "+escape.cote(mids[i])+" and site_id = "+escape.cote(siteid));
                rs.next();
                if(ids.length()>0) ids += ",";
                if(manus.length()>0) manus += ", ";
                ids += mids[i];
                manus += parseNull(rs.value(0));
				String _pref = " null ";

				if(parseNull(prefs[i]).length() > 0) _pref = escape.cote(prefs[i]);
				Etn.executeCmd("update site_menus set preference = "+_pref+", is_active = "+ escape.cote(isactives[i])+"  where id =  "+ escape.cote(mids[i]));
			}
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),ids,"UPDATED","Site Menus",manus,siteid);
		}
	}

	String q = "select s.*, ps.gtm_code as prod_gtm, ps.country_code as prod_ccode, ps.website_name as prod_website_name, ps.domain as prod_site_domain from sites s left outer join "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".sites ps on ps.id = s.id where s.id = " + escape.cote(siteid);
	Set rs = Etn.execute(q);
	rs.next();
	Set rsco = Etn.execute("select * from co_form_settings where site_id = "  + escape.cote(siteid));
	String siteStatus = getSiteStatus(Etn, siteid);
	boolean ecommerceEnabled = isEcommerceEnabled(Etn, parseNull(siteid));
%>

<html>
<head>

	<title>Menus</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<%	
breadcrumbs.add(new String[]{"Navigation", ""});
breadcrumbs.add(new String[]{"Menus", ""});
%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">
					Menus
					<%if("PUBLISHED".equals(siteStatus)) { %>
					<span style="height:15px;width:15px;border-radius:50%; border:1px solid #ddd;" class="bg-success">&nbsp;&nbsp;&nbsp;&nbsp;</span>
					<%} else if("NEEDS_PUBLISH".equals(siteStatus)) { %>
					<span style="height:15px;width:15px;border-radius:50%; border:1px solid #ddd;" class="bg-warning">&nbsp;&nbsp;&nbsp;&nbsp;</span>
					<%} else { %>
					<span style="height:15px;width:15px;border-radius:50%; border:1px solid #ddd;" class="bg-danger">&nbsp;&nbsp;&nbsp;&nbsp;</span>
					<% } %>
				</h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" aria-label="...">
					<input type='button' value='Save' id='savemenusbtn' class="btn btn-primary" />
				       <input type='button' value='New Menu' id='createmenubtn' class="btn btn-primary" />
				</div>
				<div class="btn-group mr-2" role="group" aria-label="...">
				       <input type='button' value='Settings' id='settingsbtn' class="btn btn-success" />
				</div>
				<% if(ecommerceEnabled) { %>
				<div class="btn-group" role="group">
					<button type="button" onclick='gotocheckoutparams()' class="btn btn-default btn-primary" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
						Checkout Form
					</button>
				</div>
				<%}%>
				<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Menus');" title="Add to shortcuts">
					<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
				</button>
			</div>
			<!-- /buttons bar -->
	</div>
	<!-- /title -->

<!-- container -->
	<div class="animated fadeIn p-3">
	<form name='frm' id='frm' action='site.jsp' method='post'>
		<input type='hidden' name='issave' id='issave' value='0'>
		<div>
			<table class="table table-hover table-bordered m-t-20">
				<thead class="thead-dark">
				<th style="text-align: left;vertical-align: top;">Name</th>
				<th style="text-align: left;vertical-align: top;">Status<br>
					<select name='activeslct' id='activeslct' class="form-control">
						<option value='#'>All</option>
						<option <% if(activeslct.equals("1")){%>selected<%}%> value='1'>Active</option>
						<option <% if(activeslct.equals("0")){%>selected<%}%> value='0'>Inactive</option>
					</select>
				</th>
				<th style="text-align: left;vertical-align: top;">Order</th>
				<th style="text-align: left;vertical-align: top;">Next Action</th>
				<th>&nbsp;</th>
			</thead>
			<%
				q = "select s.*, s2.id as prodid from site_menus s left outer join "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".site_menus s2 on s2.id = s.id where s.deleted = 0 and coalesce(s.menu_version,'V1') = 'V1' and s.site_id = " + escape.cote(siteid);
				if(!"#".equals(activeslct)) q += " and s.is_active = " + escape.cote(activeslct);
				q += " order by coalesce(s.preference, 99999), s.name ";
				Set rsm = Etn.execute(q);


				String process  = getProcess("menu");
				while(rsm.next()) {

					String rowColor = "";
					String sitestatus = getMenuStatus(Etn, rsm.value("id"));
					if("NOT_PUBLISHED".equals(sitestatus)) rowColor = "danger"; //red
					else if("NEEDS_PUBLISH".equals(sitestatus)) rowColor = "warning"; //orange
					else rowColor = "success"; //green


					String nextaction = "";
					Set _rsp = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s'), phase from post_work where client_key = "+escape.cote(rsm.value("id"))+" and proces = "+escape.cote(process)+" and phase in  ('publish', 'delete') and status = 0 ");
					if(_rsp.next())
					{
						if("publish".equals(_rsp.value("phase"))) nextaction = "<span>Publish to prod on <span > " + _rsp.value(0) + "</span><br><a style='color:red;' href='cancelaction.jsp?type=menu&id="+rsm.value("id")+"&goto=site.jsp' >Cancel Publish</a>";
						else if("delete".equals(_rsp.value("phase"))) nextaction = "<span>Delete from prod on " + _rsp.value(0) + "</span><br><a style='color:red' href='cancelaction.jsp?type=menu&id="+rsm.value("id")+"&goto=site.jsp' >Cancel Delete</a>";
					}

/*					String _rowcls = "danger";
					if(parseNull(rsm.value("prodid")).length() > 0)
					{
						 _rowcls = "success";
						//check for any modifications done after the last publish
						_rsp = Etn.execute("select date_format(priority, '%Y%m%d%H%i%s') as _dt from post_work where status in (0,2) and phase = 'published' and client_key = " + escape.cote(rsm.value("id")) + " and proces = " + escape.cote(process) + " order by id desc limit 1 ");
						if(_rsp.next())
						{
							String lastpublish = _rsp.value("_dt");
							Set rs2 = Etn.execute("select case when datediff(updated_on,  "+escape.cote(lastpublish)+") > 0 then '1' else '0' end from site_menus where id = " + rsm.value("id"));
							rs2.next();
							if("1".equals(rs2.value(0))) _rowcls = "warning";
						}
					}*/
			%>
						<input type='hidden' name='menuid' value='<%=escapeCoteValue(rsm.value("id"))%>' >
				<tr class='table-<%=rowColor%>'>
					<td>
					<a href="menudesigner.jsp?menuid=<%=rsm.value("id")%>" class="simplelink">
					<strong><%=escapeCoteValue(rsm.value("name"))%></strong>
					</a></td>
					<td>
						<select name='isactive' id='isactive' class='form-control'>
							<option <% if(parseNull(rsm.value("is_active")).equals("1")){%>selected<%}%> value='1'>Active</option>
							<option <% if(parseNull(rsm.value("is_active")).equals("0")){%>selected<%}%> value='0'>Inactive</option>
						</select>
					</td>
					<td><input type='text' name='pref' value='<%=escapeCoteValue(rsm.value("preference"))%>' size='5' maxlength='4' class='form-control'></td>
					<td><%=nextaction%></td>
					<td style="text-align: center;">
					<button type="button" class="btn btn-primary btn-sm" onClick="window.location.href='menudesigner.jsp?menuid=<%=rsm.value("id")%>'"><span class="oi oi-pencil" aria-hidden="true"></span></button>
					&nbsp;
					<% if(parseNull(rsm.value("prodid")).length()  == 0){%>
					<button type="button" class="btn btn-warning btn-sm"  onClick="javascript:deletemenu('<%=rsm.value("id")%>')" title="Delete from Preprod"><span class="oi oi-x"></span></button>
					<%}%>
					<% if(parseNull(rsm.value("prodid")).length() > 0){%>
					<button type="button" class="btn btn-danger btn-sm" onClick="javascript:onproddel('<%=rsm.value("id")%>','menu')" title="Delete from Production"><span class="oi oi-x" ></span></button>
					<%}%>
					&nbsp;


					</td></tr>
			<% } %>
			</table>
		</div>
		</form>
		<br>
		<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
</main>

<%@ include file="proddeletelogin.jsp"%>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- app-body -->
<script type="text/javascript">
	jQuery(document).ready(function() {

 		refreshscreen=function()
		{
			window.location = "site.jsp";
		};

		$("#settingsbtn").click(function(){
			window.location = "siteparameters.jsp";
		});

		$("#createmenubtn").click(function(){
			window.location = "menudesigner.jsp";
		});

		$("#backbtn").click(function(){
			window.location = "portal.jsp";
		});

		$("#activeslct").change(function(){
			$("#frm").submit();
		});

		$("#savemenusbtn").click(function(){

			if($.trim($("#site_domain").val()) != '' && !isValidUrl($("#site_domain").val()))
			{
				alert("You must provide valid domain main starting with http: or https:");
				$("#site_domain").focus();
				return;
			}

			$("#issave").val('1');
			$("#frm").submit();
		});

		isValidUrl=function(url)
		{
			if($.trim(url) == '') return true;
			if($.trim(url).toLowerCase().indexOf("https:") != 0 && $.trim(url).toLowerCase().indexOf("http:") != 0)
				return false;
			//if($.trim(url).toLowerCase().indexOf("javascript:") != 0) return false;
			return true;
		};

		deletemenu=function(id)
		{
			if(!confirm("Are you sure you want to delete this menu?")) return;
			$.ajax({
       	       	url : 'deletemenu.jsp',
              	       type: 'POST',
                     	data: {menuid : id},
				dataType : 'json',
              	       success : function(json)
                     	{
					if(json.response == 'error') alert("Some error occurred while deleting the menu");
					else window.location = "site.jsp";
	                     },
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});
		};

		openWindowCheckoutForm=function(formOption, isProd)
		{
			var propriete1 = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
			propriete1 += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
			propriete1 += ",width=1200" + ",height=800";

			var url = "";

			if(formOption == "checkoutform") url = "checkoutform.jsp";
			else if(formOption == "cotranslation") url = "<%=com.etn.beans.app.GlobalParm.getParm("CATALOG_ROOT")%>/admin/coformtranslation.jsp?site_id=<%=siteid%>";
			else if(formOption == "previewcheckoutform") url = "previewcheckoutform.jsp?site_id=<%=siteid%>&form_option=" + formOption + "&isProd=" + isProd;

			var win1 = window.open(url,"", propriete1);
			win1.focus();
		};

		gotocheckoutparams=function()
		{
			window.location = "checkoutform.jsp";
		}

	});
</script>
</body>
</html>
