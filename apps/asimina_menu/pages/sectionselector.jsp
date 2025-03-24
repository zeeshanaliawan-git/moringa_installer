<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.sql.escape, com.etn.util.Base64, org.jsoup.*"%>
<%@ include file="httputils.jsp" %>
<%!
	class Redirect
	{
		String url;
	}
%>
<%
	Redirect finalurl = new Redirect();
	String url = request.getParameter("url");
	if(url == null) url = "";
	url = url.trim();
	String contents = processRequest(url, request, response, finalurl, false , "0");

	if(finalurl.url != null && finalurl.url.length() > 0)
	{
		System.out.println(" redirect to : " + finalurl.url);
		url = finalurl.url;
	}

	org.jsoup.nodes.Document doc = Jsoup.parse(contents, url);
	org.jsoup.select.Elements eles = doc.select("a[href]");
	for(org.jsoup.nodes.Element ele : eles)
	{
		ele.attr("href", ele.absUrl("href"));	
	}
		
	eles = doc.select("iframe[src]");
	for(org.jsoup.nodes.Element ele : eles)
	{
		ele.attr("src", ele.absUrl("src"));	
	}
		
	eles = doc.select("link[href]");
	for(org.jsoup.nodes.Element ele : eles)
	{
		ele.attr("href", ele.absUrl("href"));
	}
		
	eles = doc.select("script[src]");
	for(org.jsoup.nodes.Element ele : eles)
	{
		ele.attr("src", ele.absUrl("src"));	
	}
		
	eles = doc.select("img[src]");
	for(org.jsoup.nodes.Element ele : eles)
	{
		ele.attr("src", ele.absUrl("src"));	
	}

	eles = doc.select("*[background]");
	for(org.jsoup.nodes.Element ele : eles)
	{
		ele.attr("background", ele.absUrl("background"));	
	}

	eles = doc.select("embed[src]");
	for(org.jsoup.nodes.Element ele : eles)
	{
		ele.attr("src", ele.absUrl("src"));	
	}

	eles = doc.select("input[src]");
	for(org.jsoup.nodes.Element ele : eles)
	{
		ele.attr("src", ele.absUrl("src"));
	}

	org.jsoup.nodes.Element headele = doc.select("head").first();
	headele.append("<link rel='stylesheet' type='text/css' href='"+com.etn.beans.app.GlobalParm.getParm("MORINGA_MENU_EXTERNAL_LINK")+"css/montre.css' />\n");

	org.jsoup.nodes.Element bodyele = doc.select("body").first();
	bodyele.append("<script type='text/javascript' src='"+com.etn.beans.app.GlobalParm.getParm("MORINGA_MENU_EXTERNAL_LINK")+"js/ccDataExtract.js'></script>\n<script type='text/javascript' src='"+com.etn.beans.app.GlobalParm.getParm("MORINGA_MENU_EXTERNAL_LINK")+"js/ccFirebug-effect.js'></script>\n");
	contents = doc.outerHtml();

	out.write(contents);	
%>
