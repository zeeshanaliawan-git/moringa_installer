<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.util.Base64, com.etn.beans.app.GlobalParm, com.etn.sql.escape, org.jsoup.*, java.util.*"%>
<%@include file="commonmethods.jsp"%>


<%!
	boolean is404url(String url)
	{
		if(url == null || url.length() == 0) return false;
		if(url.indexOf("/") > -1) url = url.substring(url.lastIndexOf("/"));
		if(url.indexOf("?") > -1) url = url.substring(0, url.lastIndexOf("?"));

		url = url.toLowerCase();
		if(url.endsWith(".html") || url.endsWith(".pdf") || url.endsWith(".php") || url.endsWith(".bsp")) return true;
		if(url.indexOf(".") < 0) return true;
		return false;//here we assume its a css or image or js so we return 404
	}

	String parseNull(Object o) 
	{
		if( o == null )
			return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase()))
			return("");
		else
			return(s.trim());
	}
%>
<%
	boolean isprod = false;
	String prodstr = "";
	if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))) 
	{
		isprod = true;
		prodstr = "PROD";
	}

	String originator = (String)request.getAttribute("javax.servlet.error.request_uri");
	String urlDecodedOriginator = java.net.URLDecoder.decode(originator, "UTF-8");	

	com.etn.util.Logger.info("countryspecific/onerror404.jsp","-------------- "+prodstr+" 404 originator :: "+ originator + " :: " + com.etn.util.ItsDate.getWith(System.currentTimeMillis(),true)) ;
	com.etn.util.Logger.info("countryspecific/onerror404.jsp","----------------------------- "+prodstr+" :: " + urlDecodedOriginator);
	com.etn.util.Logger.info("countryspecific/onerror404.jsp","----------------------------- "+prodstr+" :: " + request.getServerName().toLowerCase());
	com.etn.util.Logger.info("countryspecific/onerror404.jsp","----------------------------- "+prodstr+" user-agent :: " + parseNull(request.getHeader("user-agent")));		
	com.etn.util.Logger.info("countryspecific/onerror404.jsp","----------------------------- "+prodstr+" x-forwarded-for :: " + parseNull(request.getHeader("x-forwarded-for")));		
	com.etn.util.Logger.info("countryspecific/onerror404.jsp","----------------------------- "+prodstr+" x-real-ip :: " + parseNull(request.getHeader("x-real-ip")));		
	
	//new check if the 404 originator is local server means its most probably coming from crawler so just return
	if("127.0.0.1".equals(request.getServerName()) || "localhost".equals(request.getServerName().toLowerCase()) )
	{
		com.etn.util.Logger.info("countryspecific/onerror404.jsp", prodstr + " 404 is originated locally .. just return");
		response.setStatus(404);
		return;
	}
	
	//new check if the 404 originator is publisher we just return 404 instead of doing processing here
	if(originator.startsWith(GlobalParm.getParm("PROXY_PREFIX") + GlobalParm.getParm("PUBLISHER_SEND_REDIRECT_LINK")) ||
		originator.startsWith(GlobalParm.getParm("PUBLISHER_SEND_REDIRECT_LINK")))
	{
		com.etn.util.Logger.info("countryspecific/onerror404.jsp", prodstr + " 404 is originated by publisher .. just return");
		response.setStatus(404);
		return;
	}

	//we have to block whole site for IE8 or less
	boolean iscompatibile = isCompatible(request, ""); 
	if(!iscompatibile)
	{
		com.etn.util.Logger.debug("countryspecific/onerror404.jsp","=---- going to non compatible page");
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
		response.setHeader("Location", com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"noncompatible.html?lg="+getDefaultLanguage(Etn));
		response.setHeader("X-Frame-Options","deny");
		return;
	}	
	
	Set rs = Etn.execute("select r.* from redirects r where r.one_to_one = 1 and (r.old_url = " + escape.cote(originator) + " or concat("+escape.cote(parseNull(GlobalParm.getParm("PROXY_PREFIX")))+",r.old_url) = " + escape.cote(originator) + " or r.old_url = " + escape.cote(urlDecodedOriginator) + " or concat("+escape.cote(parseNull(GlobalParm.getParm("PROXY_PREFIX")))+",r.old_url) = " + escape.cote(urlDecodedOriginator) + " ) ");
	if(rs.next())
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		response.setHeader("Location", parseNull(rs.value("new_url")));
		return;		
	}

	rs = Etn.execute("select r.* from redirects r where r.one_to_one = 0 and (" + escape.cote(originator) + "  like concat(r.old_url,'%') or " + escape.cote(originator) + "  like concat("+escape.cote(parseNull(GlobalParm.getParm("PROXY_PREFIX")))+",r.old_url,'%') or " + escape.cote(urlDecodedOriginator) + "  like concat(r.old_url,'%') or " + escape.cote(urlDecodedOriginator) + "  like concat("+escape.cote(parseNull(GlobalParm.getParm("PROXY_PREFIX")))+",r.old_url,'%') ) ");
	if(rs.next())
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		response.setHeader("Location", parseNull(rs.value("new_url")));
		return;		
	}

	String menuid = getDefaultMenuId(Etn, request);
	Set rsm = Etn.execute("select * from site_menus where id = " + menuid );
	rsm.next();

	String lang = parseNull(rsm.value("lang"));
	String logourl = parseNull(rsm.value("logo_url"));
	logourl = logourl.replace("http://","").replace("HTTP://","").replace("https://","").replace("HTTPS://","");
	if(lang.length() == 0) lang= "fr";//default

	String menu_type = rsm.value("id");
	String siteid = rsm.value("site_id");

	boolean isvalid = false;
	String[] validurls = parseNull(GlobalParm.getParm("VALID_404_URLS")).split(";");
	if(validurls != null)
	{
		for(int i=0; i < validurls.length; i++)
		{
			if(originator.toLowerCase().startsWith(parseNull(validurls[i]).toLowerCase())) isvalid=true;
		}
	}

	if(!isvalid)
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		
		//we just go to the domain and apache will do the redirection to appropriate homepage 
		String sch = "http";
		if(parseNull(request.getScheme()).length() > 0) sch = request.getScheme();
		String hp = sch + "://" + request.getServerName().toLowerCase();

		if(logourl.length() > 0)
		{
			hp = sch + "://" + logourl;
		}

		response.setHeader("Location", hp);
		return;
	}
	else
	{
		if(is404url(originator)) response.setStatus(404);
		org.jsoup.nodes.Document doc = get404PageHtml(Etn, request, response, menuid);
		out.write(doc.html());
	}
%>