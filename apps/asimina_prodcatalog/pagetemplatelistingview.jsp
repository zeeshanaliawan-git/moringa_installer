<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.beans.app.GlobalParm, com.etn.sql.escape"%>
<%@ page import="org.jsoup.*, java.util.*, org.json.JSONObject"%>
<%@ include file="common.jsp"%>
<%!

	String addParamToUrl(String url, String param, String val)
	{
		if(url.contains("?")) url += "&";
		else url += "?";
		url += param + "=" + val;
		return url;
	}
%>
<%	
	//this is just added to support old sites not using page templates
	//if empty which will be case in preview mode we should show page template if its selected
	String menuversion = parseNull(request.getParameter("mvrn"));
	if(menuversion.length() == 0) menuversion = "v2";


	String catalogId = parseNull(request.getParameter("cat"));
	String lang = parseNull(request.getParameter("lang"));

	com.etn.asimina.beans.Language language = com.etn.asimina.data.LanguageFactory.instance.getLanguage(lang);

	if(language==null){
		language = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,getSiteByCatalogId(Etn,catalogId)).get(0);
	}
	
	String catalogtype = "";
	String pageTemplateId = "";
	String siteId = "";
	Set rs = Etn.execute("select c.*, cd.page_template_id from catalogs c left outer join catalog_descriptions cd on cd.catalog_id = c.id and langue_id = "+escape.cote(language.getLanguageId())+" where c.id = "+escape.cote(catalogId));
	if(rs.next()) 
	{
		catalogtype = rs.value("catalog_type");
		pageTemplateId = parseNull(rs.value("page_template_id"));
		siteId = parseNull(rs.value("site_id"));
	}


	String _jsp = GlobalParm.getParm("CATALOG_INTERNAL_LINK");
	if("offer".equals(catalogtype))
	{
		if(parseNull(GlobalParm.getParm("CUSTOM_OFFER_LISTING_VIEW")).length() == 0) _jsp += "newlistofferview.jsp";
		else _jsp += parseNull(GlobalParm.getParm("CUSTOM_OFFER_LISTING_VIEW"));
	}
	else
	{
		if(parseNull(GlobalParm.getParm("CUSTOM_PRODUCT_LISTING_VIEW")).length() == 0) _jsp += "newlistproductview.jsp";
		else _jsp += parseNull(GlobalParm.getParm("CUSTOM_PRODUCT_LISTING_VIEW"));
	}
	
	Map<String, String[]> requestParams = request.getParameterMap();
	if(requestParams != null && requestParams.size() > 0)
	{
		for(String param : requestParams.keySet())
		{
			String[] vals = requestParams.get(param);
			if(vals != null && vals.length > 0)
			{				
				for(int j=0;j<vals.length;j++)
				{
					_jsp = addParamToUrl(_jsp, param, parseNull(vals[j]));
				}
			}
			else _jsp = addParamToUrl(_jsp, param, "");
		}
	}
	com.etn.util.Logger.info("pagetemplatelistingview.jsp", _jsp);
	
	boolean outputContentWithoutTemplate = false;
	org.jsoup.nodes.Document jspDoc = Jsoup.connect(_jsp).get();

	if(pageTemplateId.length() > 0 && "0".equals(pageTemplateId) == false && "v2".equalsIgnoreCase(menuversion))
	{
		String tuuid = "";
		Set _rsT = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".page_templates where id = "+escape.cote(pageTemplateId));
		if(_rsT.next()) tuuid = parseNull(_rsT.value("uuid"));
		
		String contentDivId = java.util.UUID.randomUUID().toString();
		String pageTemplateApiUrl = "http://127.0.0.1"+GlobalParm.getParm("PAGES_APP_URL")+"api/pageTemplate.jsp?templateUuid="+tuuid+"&lang="+lang+"&contentId="+contentDivId;
		
		String _jsonStr = Jsoup.connect(pageTemplateApiUrl).ignoreContentType(true).execute().body();
		JSONObject json = new JSONObject(_jsonStr);

		if(json.getInt("status") == 1)
		{
			String templateHtml = parseNull(json.get("data"));
			
			org.jsoup.nodes.Element jspBody = jspDoc.select("body").first();
			org.jsoup.nodes.Element jspHead = jspDoc.select("head").first();
			
			org.jsoup.nodes.Document templateDoc = Jsoup.parse(templateHtml);
			org.jsoup.nodes.Element templateHead = templateDoc.select("head").first();
			org.jsoup.nodes.Element templateContentDiv = templateDoc.select("div[id=content_"+contentDivId+"]").first();
			 
			templateHead.append(jspHead.html());
			templateContentDiv.append(jspBody.html());
			out.write(templateDoc.outerHtml());
		}
		else outputContentWithoutTemplate = true;
	}
	else outputContentWithoutTemplate = true;
	
	if(outputContentWithoutTemplate)
	{
		out.write(jspDoc.outerHtml());
	}
%>