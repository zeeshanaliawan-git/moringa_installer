<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.Contexte, java.util.LinkedHashMap"%>
<%@include file="../common.jsp"%>
<%@include file="urlcommons.jsp"%>


<%
	String selectedSiteId = getSiteId(session);

	String isprod = parseNull(request.getParameter("isprod"));

	String titlePrefix = "Test Site";
	String dbname = "";
	if("1".equals(isprod)) 
	{
		titlePrefix = "Prod Site";
		dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
	}


	Set rsr = Etn.execute("select r.*, m.name as menuname from "+dbname+"redirects r left outer join "+dbname+"site_menus m on m.id = r.menu_type where (r.menu_type = '*' or r.menu_type in (select id from "+dbname+"site_menus where site_id = "+escape.cote(selectedSiteId)+")) order by r.menu_type, r.old_url, r.new_url ");

	Set rsm = Etn.execute("select m.*, s.name as site_name from "+dbname+"sites s, "+dbname+"site_menus m where m.deleted = 0 and s.id = "+escape.cote(selectedSiteId)+" and m.site_id = s.id order by s.name, m.name ");

	String externalpath = parseNull(com.etn.beans.app.GlobalParm.getParm("CACHE_EXTERNAL_LINK"));
	String redirectbaseurl = parseNull(com.etn.beans.app.GlobalParm.getParm("SEND_REDIRECT_LINK"));

	if(isprod.equals("1"))
	{
		externalpath = parseNull(com.etn.beans.app.GlobalParm.getParm("PROD_CACHE_EXTERNAL_LINK"));
		redirectbaseurl = parseNull(com.etn.beans.app.GlobalParm.getParm("PROD_SEND_REDIRECT_LINK"));
	}

	LinkedHashMap<String, String> urls = new LinkedHashMap<String, String>();
	while(rsm.next())
	{
		String sitefolder = getSiteFolderName(rsm.value("site_name"));

		Set rsp = Etn.execute("select * from "+dbname+"cached_pages c where cached = 1 and menu_id = "+escape.cote(parseNull(rsm.value("id")))+" and coalesce(filename, '') <> '' order by url ");

		while(rsp.next())
		{
			if(!parseNull(rsp.value("content_type")).contains("text/html")) continue;
			String domain = getDomain(rsp.value("url"));

			String localpath = getLocalPath(Etn, rsp.value("url"), dbname);
			String urlfileid = parseNull(rsp.value("filename"));

			String finalpath = externalpath + sitefolder + "/" + getFolderId(Etn, domain, dbname)  + localpath + urlfileid;

			//NOTE:: old_url in redirects for /2/personal/1/3/homepage.html will be /2/sites/1/3/homepage.html .. that is why we have separate redirectfromurl
			String redirectfromurl = redirectbaseurl + sitefolder + "/" + getFolderId(Etn, domain, dbname)  + localpath + urlfileid;

			urls.put(redirectfromurl, finalpath);
		}
	}

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<title>Redirections</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{titlePrefix, ""});
breadcrumbs.add(new String[]{"Redirections", ""});
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
				<h1 class="h2">Redirections</h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-primary" onclick='addredirection()'>Add redirection</button>
				</div>
				<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Redirections');" title="Add to shortcuts">
					<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
				</button>
			</div>
			<!-- /buttons bar -->
	</div>
	<!-- /title -->


<!-- container -->
<div class="animated fadeIn">
	<div>
		<table class="table table-hover table-vam table-striped m-t-20">
			<thead class="thead-dark">
				<th>Old Url</th>
				<th>New Url</th>
				<th>One to Many</th>
				<th>Menu type</th>
				<th>&nbsp;</th>
			</thead>
		<% while(rsr.next())
		{
			String onetomany = "Yes";
			if(parseNull(rsr.value("one_to_one")).equals("1")) onetomany = "No";
			String _menu = parseNull(rsr.value("menuname"));
			if(_menu.length() == 0) _menu = parseNull(rsr.value("menu_type"));
		%>
			<tr>
				<td><%=escapeCoteValue(parseNull(rsr.value("old_url")))%></td>
				<td><%=escapeCoteValue(parseNull(rsr.value("new_url")))%></td>
				<td><%=escapeCoteValue(onetomany)%></td>
				<td><%= escapeCoteValue(_menu)%></td>
				<td style="text-align: center;">
				<button type="button" class="btn btn-danger btn-sm" onclick='removeredirection("<%=parseNull(rsr.value("old_url"))%>","<%=parseNull(rsr.value("new_url"))%>","<%=parseNull(rsr.value("one_to_one"))%>","<%=parseNull(rsr.value("menu_type"))%>")' title="Delete"><span class="oi oi-x"></span></button>
				</td>
				<!-- <input type='button' value='Remove' onclick='removeredirection("<//%=parseNull(rsr.value("old_url"))%>","<//%=parseNull(rsr.value("new_url"))%>","<//%=parseNull(rsr.value("one_to_one"))%>","<//%=parseNull(rsr.value("menu_type"))%>")' /> -->
			</tr>
		<%}%>
		</table>
	</div>
	<br>
	<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
</div>
</main>

<div id='addredirectiondlg' style='display:none; clear:both;' class="modal fade" tabindex="-1" role="dialog" >
<div class="modal-dialog modal-lg" role="document">
<div class="modal-content">
	<div class="modal-header" style='text-align:left'>
		<h5 class="modal-title">Add Redirection</h5>
		<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	</div>
	<div class="modal-body">
		<div class="alert alert-danger" role="alert" id="addredirectiondlgAlert" style="display:none"></div>
		<div style='margin-top:5px; margin-bottom:5px;'>
			<span style='color:red'>NOTE: For old site redirects do not mention http/https and the domain name in the old url</span>
		</div>
		<table cellpadding=4 cellspacing=0 border=0 width="95%">
		<tr>
			<td style='font-weight:bold' nowrap>Old URL</td>
			<td style='font-weight:bold'>&nbsp;:&nbsp;</td>
			<td style='font-weight:bold'>
				<input type='text' id='oldurltxt' value='' size='60' />
				<br>
				<select id='oldurlslt' class="form-control">
					<option value=''>----- Select -----</option>
					<% for(String fromurl : urls.keySet()) {%>
						<option value='<%=escapeCoteValue(fromurl)%>'><%=urls.get(fromurl)%></option>
					<%}%>
				</select>
			</td>
		</tr>
		<tr>
			<td style='font-weight:bold' nowrap>New URL</td>
			<td style='font-weight:bold'>&nbsp;:&nbsp;</td>
			<td >
				<input type='text' id='newurltxt' value='' size='60' />
				<br>
				<select id='newurlslt' class="form-control">
					<option value=''>----- Select -----</option>
					<% for(String fromurl : urls.keySet()) {%>
						<option value='<%=escapeCoteValue(urls.get(fromurl))%>'><%=urls.get(fromurl)%></option>
					<%}%>
				</select>
			</td>
		</tr>
		<tr>
			<td style='font-weight:bold' nowrap>One-to-One</td>
			<td style='font-weight:bold'>&nbsp;:&nbsp;</td>
			<td >
				<select id='onetooneslt' class="form-control w-25">
					<option value=''>-- Select --</option>
					<option value='1'>Yes</option>
					<option value='0'>No</option>
				</select>
			</td>
		</tr>
		<tr>
			<td style='font-weight:bold' nowrap>Menu</td>
			<td style='font-weight:bold'>&nbsp;:&nbsp;</td>
			<td >
				<select id='menu_type' class="form-control w-25">
					<option value=''>-- Select --</option>
					<% rsm.moveFirst();
					while(rsm.next()) { %>
						<option value='<%=escapeCoteValue(parseNull(rsm.value("id")))%>'><%=parseNull(rsm.value("name"))%></option>
					<% } %>
				</select>
			</td>
		</tr>
		</table>
	</div>
	<div class="modal-footer">
		<button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
		<button type="button" class="btn btn-success" id="addbtn" >Add</button>
	</div>
</div>
</div>
</div>


<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /app-body -->
<script>
jQuery(document).ready(function()
{
	$("#addbtn").click(function()
	{
		if($.trim($("#oldurltxt").val()) == '' && $.trim($("#oldurlslt").val()) == '' )
		{
			$("#addredirectiondlgAlert").html("You must provide Old URL");
			$("#addredirectiondlgAlert").show();
			return;
		}
		if($.trim($("#newurltxt").val()) == '' && $.trim($("#newurlslt").val()) == '' )
		{
			$("#addredirectiondlgAlert").html("You must provide New URL");
			$("#addredirectiondlgAlert").show();
			return;
		}
		if($.trim($("#oldurltxt").val()) != '' && $.trim($("#oldurlslt").val()) != '' )
		{
			$("#addredirectiondlgAlert").html("Either select value for Old URL or enter its value. You cannot do both at sametime");
			$("#addredirectiondlgAlert").show();
			return;
		}
		if($.trim($("#newurltxt").val()) != '' && $.trim($("#newurlslt").val()) != '' )
		{
			$("#addredirectiondlgAlert").html("Either select value for New URL or enter its value. You cannot do both at sametime");
			$("#addredirectiondlgAlert").show();
			return;
		}
		if($("#onetooneslt").val() == '')
		{
			$("#addredirectiondlgAlert").html("You must select if its a one-to-one mapping of redirection or one-to-many");
			$("#addredirectiondlgAlert").show();
			$("#onetooneslt").focus();
			return;
		}
		if($("#menu_type").val() == '')
		{
			$("#addredirectiondlgAlert").html("You must select the menu for which redirection is to be added");
			$("#addredirectiondlgAlert").show();
			$("#menu_type").focus();
			return;
		}

		var oldurl = "";
		var newurl = "";
		if($.trim($("#oldurltxt").val()) != '') oldurl = $.trim($("#oldurltxt").val());
		else if($.trim($("#oldurlslt").val()) != '') oldurl = $.trim($("#oldurlslt").val());

		if($.trim($("#newurltxt").val()) != '') newurl = $.trim($("#newurltxt").val());
		else if($.trim($("#newurlslt").val()) != '') newurl = $.trim($("#newurlslt").val());


		var refreshurl = "redirections.jsp";
		if("<%=isprod%>" == "1") refreshurl = "prodredirections.jsp";
		$.ajax({
      	       	url : 'addredirection.jsp',
             	       type: 'POST',
                    	data: {oldurl : oldurl, newurl : newurl, onetoone : $("#onetooneslt").val(), isprod : '<%=isprod%>', menu_type : $("#menu_type").val()},
			dataType : 'json',
             	       success : function(json)
                    	{
				if(json.response == 'success')
				{
					window.location = refreshurl ;
				}
				else alert(json.msg);
                     },
			error : function()
			{
				alert("Error while communicating with the server");
			}
		});

	});

	addredirection=function()
	{
		$("#oldurltxt").val("");
		$("#newurltxt").val("");
		$("#oldurlslt").val("");
		$("#newurlslt").val("");
		$("#menu_type").val("");
		$("#addredirectiondlgAlert").html("");
		$("#addredirectiondlgAlert").hide();
		$("#addredirectiondlg").modal("show");
	};

	removeredirection=function(oldurl, newurl, onetoone, menu_type)
	{
		if(!confirm("Are you sure to remove this redirection?")) return;

		$.ajax({
      	       	url : 'removeredirection.jsp',
             	       type: 'POST',
                    	data: {oldurl : oldurl, newurl : newurl, onetoone : onetoone, isprod : '<%=isprod%>', menu_type : menu_type},
			dataType : 'json',
             	       success : function(json)
                    	{
				if(json.response == 'success')
				{
					window.location = window.location;
				}
				else alert(json.msg);
                     },
			error : function()
			{
				alert("Error while communicating with the server");
			}
		});

	};

});
</script>

</body>
</html>