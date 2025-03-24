<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="common.jsp"%>

<%!
	String getMenuCacheFolder(com.etn.beans.Contexte Etn, String menuid)
	{
		Set rs = Etn.execute("Select m.*, s.name as sitename from site_menus m, sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();

		String path = getSiteFolderName(parseNull(rs.value("sitename"))) + "/";
		path += parseNull(rs.value("lang")).toLowerCase() + "/";

		return path;
	}

	boolean isInRules(com.etn.beans.Contexte Etn, String siteid, String href)
	{
		boolean isinrules = false;
		String colname = "apply_to";
		if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))) colname = "prod_apply_to";

		Set rs = Etn.execute("select * from sites_apply_to where site_id = " + escape.cote(siteid));
		while(rs.next())
		{
			if(href.toLowerCase().startsWith(("http://" + parseNull(rs.value(colname))).toLowerCase()) || href.toLowerCase().startsWith(("https://" + parseNull(rs.value(colname))).toLowerCase()) )
			{
				isinrules = true;
				break;
			}
		}
		return isinrules;
	}

	String getTestSitePath(com.etn.beans.Contexte Etn, String menuid, String url) throws Exception
	{
		if(parseNull(url).length() == 0) return "";

		if(url.toLowerCase().startsWith("http:") || url.toLowerCase().startsWith("https:"))
		{
			if(isInRules(Etn, menuid, url))
			{
				return GlobalParm.getParm("EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(url.getBytes("UTF-8"));
			}
			return url;
		}

		return GlobalParm.getParm("CACHE_EXTERNAL_LINK") + getMenuCacheFolder(Etn, menuid) + url;

	}

	String getProdSitePath(com.etn.beans.Contexte Etn, String menuid, String url) throws Exception
	{
		if(parseNull(url).length() == 0) return "";

		if(url.toLowerCase().startsWith("http:") || url.toLowerCase().startsWith("https:"))
		{
			if(isInRules(Etn, menuid, url))
			{
				return GlobalParm.getParm("PROD_EXTERNAL_LINK") + "process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(url.getBytes("UTF-8"));
			}
			return url;
		}

		return GlobalParm.getParm("PROD_CACHE_EXTERNAL_LINK") + getMenuCacheFolder(Etn, menuid) + url;
	}

%>
<%
	String siteid = getSiteId(session);
	String lang = parseNull(request.getParameter("lang"));

	Set rsLangs = Etn.execute("select l.* from "+GlobalParm.getParm("COMMONS_DB")+".sites_langs sl inner join language l on l.langue_id = sl.langue_id where sl.site_id ="+escape.cote(siteid)+" order by 1");
	
	String homepageurl = "";
	boolean isInProd = false;
	String langueId = "";
	String menuid = "";
	if(lang.length() > 0)
	{
		Set rsSm = Etn.execute("select * from site_menus where menu_version = 'V2' and site_id = "+escape.cote(siteid) + " and lang = "+escape.cote(lang));
		if(rsSm.next()) menuid = rsSm.value("id");
		Set rsL = Etn.execute("select * from language where langue_code = "+escape.cote(lang));
		if(rsL.next())
		{
			langueId = rsL.value("langue_id");
			Set rs = Etn.execute("select * from sites_details where site_id = "+escape.cote(siteid) + " and langue_id = "+escape.cote(rsL.value("langue_id")));
			if(rs.next())
			{
				homepageurl = parseNull(rs.value("homepage_url"));
				Set rsProd = Etn.execute("select * from "+GlobalParm.getParm("PROD_DB")+".sites_details where site_id = "+escape.cote(siteid) + " and langue_id = "+escape.cote(rsL.value("langue_id")));
				if(rsProd.rs.Rows > 0) isInProd = true;
			}
			
		}
	}	
%>

<html>
<head>
	<title>Cache</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
	
<%	
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Cache", ""});
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
				<h1 class="h2">Cache</h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group mr-2" role="group" aria-label="...">
					<input type='button' value='Reload page templates' onclick='reloadpagetemplates()' class="btn btn-default btn-danger"/>
				</div>
			
				<div class="btn-group mr-2">
					<a href="javascript:void(0)" id='publishbtn' class="onsaveonly btn btn-warning" >Build Test Site Cache</a>
					<a href="javascript:void(0)"  id='prodpublishbtn' class="onsaveonly btn btn-danger" >Build Prod Site Cache</a>
				</div>
				<div class="btn-group mr-2">
					<% if(homepageurl.length() > 0) { %>
						<a href="javascript:void(0)" id='tsite' onclick='openTestSite()' class="onsaveonly btn btn-light" >Test site</a>
					<% } %>
					<% if(isInProd && homepageurl.length() > 0) { //check if menu is published to prod already then show prod link %>
						<a href="javascript:void(0)" id='psite' onclick='openProdSite()' class="onsaveonly btn btn-light" >Prod site</a>
					<% } %>
				</div>
			</div>
			<!-- /buttons bar -->
	</div>
	<!-- /title -->


	<!-- container -->
	<div class="animated fadeIn">
		<div class="row">
			<label for="lang" class="col-sm-2 control-label">Language</label>
			<div class="col-sm-9">
			<select class="form-control" id="lang">
				<option value=''>-- Select Language --</option>
				<% while(rsLangs.next()){
					String selected = "";
					if(lang.equals(rsLangs.value("langue_code"))) selected = "selected";
					out.write("<option "+selected+" value='"+escapeCoteValue(rsLangs.value("langue_code"))+"'>"+escapeCoteValue(rsLangs.value("langue"))+"</option>");
				}%>
			</select>
			</div>	
		</div>
		<div class="row" style="margin-top: 30px;">
			<div class="col-sm-12">
				<div id='menustatusdiv' class="arrondi row" ></div>
			</div>
		</div>			
	</div>
	<!-- /container -->
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<!-- .modal -->
<div class="modal fade" tabindex="-1" role="dialog" id="crawlerErrorsDlg" >
<!-- .modal content -->
	<div class="modal-dialog modal-xl" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Crawler Errors</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			</div>
			<div class="modal-body" id="crawlerErrorsDlgBody">

			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
	<!-- /.modal content -->
</div>
<!-- /.modal -->
<!-- .modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'>
</div>
<!-- /.modal -->

<%
	String prodpushid = lang;
	String prodpushtype = "menuv2";
%>
<%@ include file="prodpublishlogin.jsp"%>




<script type="text/javascript">
	function reloadpagetemplates()
	{
		$.ajax({
			url : "reloadpagetemplates.jsp",
			method : "post",
			dataType : "json",
			data : { tm : (new Date().getMilliseconds()) },
			success : function (json) {
				alert("Success");
			}
		});
	}

function openTestSite() {
	window.open("<%=getTestSitePath(Etn, menuid, homepageurl)%>");
}
function openProdSite() {
	window.open("<%=getProdSitePath(Etn, menuid, homepageurl)%>");
}

	jQuery(document).ready(function() {
		$("#lang").change(function(){
			window.location.href = "cachemanagement.jsp?lang="+$(this).val();
		});

		refreshscreen=function()
		{
			window.location = "cachemanagement.jsp?lang=<%=lang%>";
		};

		$("#publishbtn").click(function(){
			$.ajax({
       	       	url : 'publishsite.jsp',
				type: 'POST',
				data: {lang : '<%=lang%>'},
				success : function(resp)
				{
					if(resp.status == 0) alert("Published");
					else alert(resp.msg);
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		});

		<% if(lang.length() > 0 ) { %>
		viewCrawlerErrors=function()
		{
			$("#crawlerErrorsDlgBody").html("");
			$.ajax({
				url : 'getcrawlererrors.jsp',
				type: 'POST',
				data: {menuid : '<%=menuid%>'},
				success : function(htm)
				{
					$("#crawlerErrorsDlgBody").html(htm);
					$("#crawlerErrorsDlg").modal('show');
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		}

		var crawldisabled = 0;
		var _interval = null;
		var menustatuserror = 0;
		function checkmenustatus()
		{
			$.ajax({
				url : 'getv2menustatus.jsp',
				type: 'POST',
				data: { lang : '<%=lang%>'},
				dataType: 'json',
				success : function(json)
				{
					$("#menustatusdiv").html(json.html);
					if(json.iscrawling == "false" && (crawldisabled--) <= 0) $("#crawlbtn").prop('disabled', false);
				},
				error : function()
				{
					menustatuserror++;
				}
			});
			//5 tries to get status failed means the session must be expired so we will kill the setInterval
			if(menustatuserror > 4) clearInterval(_interval);
		};

		checkmenustatus();
		_interval = setInterval(checkmenustatus, 5000);
		<% } %>

	});
</script>
</body>
</html>
