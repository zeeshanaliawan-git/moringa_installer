<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.Contexte, java.io.*, java.util.ArrayList"%>
<%@include file="../common.jsp"%>
<%@include file="urlcommons.jsp"%>

<%!

	String getProdSitePath(String domain, String url) throws Exception
	{
		if(parseNull(domain).length() == 0) return url;
		
		domain = domain.toLowerCase();
		String htp = "http://";
		if(domain.startsWith("https://")) htp = "https://";
		domain = domain.replace("https://","").replace("http://","");
		
		if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));
		
		return htp + domain + url;
	}
	
	String getUrlForDisplay(String u)
	{
		if(u == null || u.trim().length() == 0) return u;
		ArrayList<String> urls = new ArrayList<String>();
		int loops = 20;
		for(int i=0;i<loops;i++)
		{
			if(u.length() > 151)
			{
				urls.add(u.substring(0, 150) + "<br>");
				u = u.substring(150);
			}
			else if(u.length() <= 151)
			{
				urls.add(u);
				break;
			}
			if((i + 1) == loops)
			{
				urls.add(u);
				break;
			}
		}
		u = "";
		for(String _u : urls) u += _u;
		return u;
	}
%>

<%
	String selectedSiteId = getSiteId(session);

	String isprod = parseNull(request.getParameter("isprod"));

	String titlePrefix = "Test Site";
	String dbname = "";
	String action = "sitemap.jsp";
	boolean isProd = false;
	if("1".equals(isprod))
	{
		dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
		action = "prodsitemap.jsp";
		titlePrefix = "Prod Site";
		isProd = true;
	}


	Set rsm = Etn.execute("select m.*, s.name as site_name, s.domain as site_domain from "+dbname+"sites s, "+dbname+"site_menus m where m.deleted = 0 and s.id = "+escape.cote(selectedSiteId)+" and m.site_id = s.id order by s.name, m.name ");
	String menuid = parseNull(request.getParameter("menuid"));

	String sitefolder = "";
	String menupath = "";
	String sitedomain = "";

	Set rsp = null;
	String menu_type = "";
	String sitemapurl = "";
	if(menuid.length() > 0)
	{
		Set rs2 = Etn.execute("select m.*, s.name as site_name, s.domain as site_domain from "+dbname+"sites s, "+dbname+"site_menus m where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs2.next();
		sitefolder = getSiteFolderName(parseNull(rs2.value("site_name")));
		sitedomain = parseNull(rs2.value("site_domain"));
		menupath = parseNull(rs2.value("production_path"));
		
		menu_type = rs2.value("id");
		rsp = Etn.execute("select c.*, cpp.published_url from "+dbname+"cached_pages c, "+dbname+"cached_pages_path cpp where cpp.id = c.id and c.menu_id = "+escape.cote(menuid)+" and coalesce(c.filename, '') <> '' and (c.is_url_active = 1 or c.is_404_page = 1) order by c.url ");
		if(parseNull(rs2.value("sitedomain")).length() > 0) sitemapurl = parseNull(rs2.value("sitedomain")) + "/sitemap.xml";
	}

	int nredirects = 0;

	String externalpath = parseNull(com.etn.beans.app.GlobalParm.getParm("CACHE_EXTERNAL_LINK"));
	String redirectbaseurl = parseNull(com.etn.beans.app.GlobalParm.getParm("SEND_REDIRECT_LINK"));

	if(isprod.equals("1"))
	{
		externalpath = parseNull(com.etn.beans.app.GlobalParm.getParm("PROD_CACHE_EXTERNAL_LINK"));
		redirectbaseurl = parseNull(com.etn.beans.app.GlobalParm.getParm("PROD_SEND_REDIRECT_LINK"));
	}


%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<title>Sitemap</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{titlePrefix, ""});
breadcrumbs.add(new String[]{"Sitemap", ""});
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
				<h1 class="h2">Sitemap</h1>
				<p class="lead"></p>
			</div>

			<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Sitemap');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<% if(isprod.equals("1") && sitemapurl.length() > 0) { %>
				<div class="btn-group" role="group" aria-label="...">
					<button type="button" class="btn btn-primary" onclick='javascript:window.open("<%=sitemapurl%>");'>View Sitemap xml</button>
				</div>
				<% } %>
			</div>
			<!-- /buttons bar -->
	</div>
	<!-- /title -->



	<!-- container -->
	<div class="animated fadeIn">
		 <div class="m-b-20">
			 <form id='frm1' name='frm1' action='<%=action%>' method='post'>
			 <select name='menuid' onchange='reload()'  class="form-control col-4">
				<option value=''>- - - Select Menu - - -</option>
				<% while(rsm.next()) {%>
					<option <%if(menuid.equals(rsm.value("id"))){%>selected<%}%> value='<%=escapeCoteValue(rsm.value("id"))%>'><%=escapeCoteValue(rsm.value("site_name") + " : " + rsm.value("name"))%></option>
				<% } %>
			</select>
			</form>
		</div>


		<% if(rsp != null && rsp.rs.Rows > 0) { %>
		<div>
			<!-- messages zone  -->
			<div class='m-b-20'>
			<div class="alert alert-danger" role="alert" >
				<div >
					Either we mark appropriate 404 page for the crawler or we provide 404 page url in the menu designer
					<br>
					If a URL is not cached Auto refresh will have no effect
				</div>
			</div>
	
			</div><!-- /messages zone  -->


			<table class="table table-hover table-bordered m-t-20" style="table-layout: fixed">
			<thead class="thead-dark">
				<tr>
					<th>Original url</th>
					<th style="width:4%">Cached</th>
					<th>Redirected From</th>
					<th>Portal url</th>
					<th>Redirected To</th>
					<th>From Page</th>
					<th style="width:10%;">Auto Refresh</h>
				</tr>
			</thead>
		<%
		int cnt =0;
		String _color = "";

		String homepagecrawlerpath = "";
		//page level 0 is always homepage
		Set _rs1 = Etn.execute("select published_home_url from "+dbname+"site_menus where id = "+escape.cote(menuid));
		if(_rs1.next()) homepagecrawlerpath = _rs1.value("published_home_url");

		while(rsp.next())
		{
			if(cnt++ % 2 != 0) _color = "background:#eee;";
			else _color = "";

			if(!parseNull(rsp.value("content_type")).contains("text/html")) continue;

			String domain = getDomain(rsp.value("url"));

			String localpath = getLocalPath(Etn, rsp.value("url"), dbname);
			String urlfileid = parseNull(rsp.value("filename"));

			String localpathwithprimarykey = getLocalPath(Etn, rsp.value("url"), true, dbname);

			String finalpath = externalpath + parseNull(rsp.value("filepath")) + urlfileid;
			if(isProd) finalpath = parseNull(rsp.value("published_url"));		

			//old url in redirects table will always have /sites/ in it .. like for prod we access pages at /2/ but tomcat gets /2/sites/
			String redirectfrom = redirectbaseurl + parseNull(rsp.value("filepath")) + urlfileid;
			if(isProd) redirectfrom = parseNull(rsp.value("published_url"));

			Set rsf = Etn.execute("select * from "+dbname+"redirects where menu_type = "+escape.cote(menu_type)+" and new_url = " + escape.cote(finalpath));

			Set rsr = Etn.execute("select * from "+dbname+"redirects where menu_type = "+escape.cote(menu_type)+" and old_url = " + escape.cote(redirectfrom));

			Set rspaths = Etn.execute("select cp.*, cpp.published_url as page_url, cpp2.published_url as parent_page_url " +
						" from "+dbname+"crawler_paths cp inner join "+dbname+"cached_pages c on c.id = cp.page_id and c.menu_id = cp.menu_id "+
						" inner join "+dbname+"cached_pages_path cpp on cpp.id = c.id " +
						" left outer join "+dbname+"cached_pages c2 on c2.menu_id = cp.menu_id and c2.id = cp.parent_page_id " +
						" left outer join "+dbname+"cached_pages_path cpp2 on cpp2.id = c2.id " +
						" where cp.menu_id = "+escape.cote(menuid)+" and cp.page_id = " + escape.cote(rsp.value("id")));

			String parentpages = "";
			boolean hpurladded = false;
			while(rspaths.next())
			{
				//for homepage there should be no from url
				if("1".equals(rspaths.value("is_homepage_link")))
				{
					parentpages = "<b>HOMEPAGE</b>";
					_color = "background:#dff0d8";
					break;
				}
				//for 404 there should be no from url
				if("1".equals(rspaths.value("is_404")))
				{
					parentpages = "<b>404</b>";
					_color = "background:#f2dede";
					break;
				}
				//for menu links we just show the homepage as the from page otherwise it will contain a huge list of pages as menu is included in all pages
				if("1".equals(rspaths.value("is_menu_link")))
				{
					parentpages = "<a style='color:green' href='"+getProdSitePath(sitedomain, homepagecrawlerpath)+"' target='_blank'>" + homepagecrawlerpath + "</a><br>";
					break;
				}
				else if(parseNull(rspaths.value("parent_page_url")).length() > 0)
				{
					parentpages +="<a href='"+getProdSitePath(sitedomain, parseNull(rspaths.value("parent_page_url")))+"' target='_blank'>" + parseNull(rspaths.value("parent_page_url")) + "</a><br>";
				}
			}
		%>
			<tr>
				<td style='border-bottom:1px solid #ccc; border-right:1px solid #ccc;<%=_color%>' ><%=getUrlForDisplay(parseNull(rsp.value("url")))%></td>
				<td style='border-bottom:1px solid #ccc; border-right:1px solid #ccc;<%=_color%>' ><%=parseNull(rsp.value("cached"))%></td>
				<td style='border-bottom:1px solid #ccc; border-right:1px solid #ccc;<%=_color%>;white-space: normal;' >
					<% if(rsf != null && rsf.rs.Rows > 0) {
						while(rsf.next()) {
					%>
						<div id='rdr_<%=nredirects%>'>
							<div style='border-bottom:1px solid #eee;' >
								<a target='_blank' href='<%=escapeCoteValue(getProdSitePath(sitedomain, parseNull(rsf.value("old_url"))))%>'><%=escapeCoteValue(rsf.value("old_url"))%></a>
								<br><input type='button' value='Remove redirection' onclick='removeredirection("<%=rsf.value("old_url")%>","<%=finalpath%>", "<%=rsf.value("one_to_one")%>","rdr_<%=nredirects%>", "<%=rsf.value("menu_type")%>")'/>
							</div>
						</div>
					<%	nredirects++;
						}//while
					}%>
				</td>
				<td style='border-bottom:1px solid #ccc; border-right:1px solid #ccc;<%=_color%>;white-space: normal' ><input type='hidden' id='pagename_<%=rsp.value("id")%>' value="<%=escapeCoteValue(urlfileid)%>" ><a class='<%=finalpath.replace("/","-").replace(".","-")%>' id='myurl_<%=rsp.value("id")%>' target='_blank' href='<%=getProdSitePath(sitedomain, parseNull(finalpath))%>'><%=finalpath%></td>
				<td style='border-bottom:1px solid #ccc; border-right:1px solid #ccc;<%=_color%>' >
					<% if(rsr != null && rsr.rs.Rows > 0) {
						while(rsr.next()) {
					%>
						<div id='rdr_<%=nredirects%>'>
							<div style='border-bottom:1px solid #eee;' >
								<a target='_blank' href='<%=escapeCoteValue(getProdSitePath(sitedomain, parseNull(rsr.value("new_url"))))%>'><%=escapeCoteValue(rsr.value("new_url"))%></a>
								<br><input type='button' value='Remove redirection' onclick='removeredirection("<%=redirectfrom%>","<%=rsr.value("new_url")%>", "<%=rsr.value("one_to_one")%>","rdr_<%=nredirects%>", "<%=rsr.value("menu_type")%>")'/>
							</div>
						</div>
					<%	nredirects++;
						}//while
					}%>
				</td>
				<td style='border-bottom:1px solid #ccc; border-right:1px solid #ccc;<%=_color%>' align='center'>
					<%=parentpages%>
				</td>

				<td style='border-bottom:1px solid #ccc; border-right:1px solid #ccc;<%=_color%>' align='center'>
					<select class='refresh_minutes' id='refreshmins_<%=rsp.value("id")%>'>
						<option <%if("0".equals(rsp.value("refresh_minutes"))){%>selected<%}%> value=0>Never</option>
						<option <%if("15".equals(rsp.value("refresh_minutes"))){%>selected<%}%> value=15>Every 15 mins</option>
						<option <%if("30".equals(rsp.value("refresh_minutes"))){%>selected<%}%> value=30>Every 30 mins</option>
						<option <%if("60".equals(rsp.value("refresh_minutes"))){%>selected<%}%> value=60>Every 60 mins</option>
					</select>
					<br>
					<span id='msgspan_<%=rsp.value("id")%>' style='font-size:8pt; color:green'></span>
				</td>
			</tr>
		<%}%>
		</table>
		<br>
		<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	<%}%>
</div>
</main>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /app-body -->
<script>
jQuery(document).ready(function()
{
	reload=function()
	{
		$("#frm1").submit();
	};

	focusLink=function(cls)
	{
		if($("." + cls)) $("." + cls).get(0).focus();
	};

	removeredirection=function(oldurl, newurl, onetoone, rid, menu_type)
	{
		if(confirm("Are you sure to remove this redirection?"))
		{
			$.ajax({
      		       	url : 'removeredirection.jsp',
             		       type: 'POST',
	                    	data: {oldurl : oldurl, newurl: newurl, onetoone : onetoone, isprod : '<%=isprod%>', menu_type : menu_type},
				dataType : 'json',
             		       success : function(json)
	                    	{
					alert(json.msg);
					if(json.response == 'success') $("#"+rid).html('');
	                     },
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});
		}
	};

	$(".refresh_minutes").change(function(){
		var id = $(this).attr('id');
		id = id.substring(id.indexOf("_")+1);

		$("#msgspan_" + id).html("");

		$.ajax({
			url : 'changerefreshinterval.jsp',
             		type: 'POST',
	              data: {cid : id, isprod : '<%=isprod%>', mins : $(this).val()},
			dataType : 'json',
             		success : function(json)
	              {
				//console.log(json.msg);
				$("#msgspan_" + id).html(json.msg);
				setTimeout(function(){ $("#msgspan_" + id).html(""); }, 2000);
	              },
			error : function()
			{
				alert("Error while communicating with the server");
			}
		});

	});

});
</script>

</body>
</html>