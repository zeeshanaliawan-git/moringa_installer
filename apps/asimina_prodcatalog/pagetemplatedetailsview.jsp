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
	
	String productid = parseNull(request.getParameter("id"));
	String lang = parseNull(request.getParameter("lang"));

	com.etn.asimina.beans.Language language = com.etn.asimina.data.LanguageFactory.instance.getLanguage(lang);
	if(language ==  null)
	{
		language = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,getSiteByProductId(Etn,productid)).get(0);
	}
	
	String producttype = "";
	String catalogtype = "";
	String pageTemplateId = "";
	String siteId = "";
	Set rs = Etn.execute("select p.*, case when coalesce(pd.page_template_id,0) = 0 then cd.page_template_id else pd.page_template_id end as product_page_template_id, c.site_id, c.catalog_type from products p left outer join product_descriptions pd on pd.product_id = p.id and pd.langue_id = "+escape.cote(language.getLanguageId())+", catalogs c left outer join catalog_descriptions cd on cd.catalog_id = c.id and cd.langue_id = "+escape.cote(language.getLanguageId())+" where p.catalog_id = c.id and p.id = "+escape.cote(productid));
	if(rs.next()) 
	{
		producttype = rs.value("product_type");
		catalogtype = parseNull(rs.value("catalog_type"));
		siteId = parseNull(rs.value("site_id"));	
		
		pageTemplateId = parseNull(rs.value("product_page_template_id"));
	}

	String _jsp = GlobalParm.getParm("CATALOG_INTERNAL_LINK");
	if("offer".equals(catalogtype))
	{
		if(parseNull(GlobalParm.getParm("CUSTOM_OFFER_VIEW")).length() == 0) _jsp += "newofferview.jsp";
		else _jsp += parseNull(GlobalParm.getParm("CUSTOM_OFFER_VIEW"));
	}
	else if("service".equals(producttype))
	{
		_jsp += "serviceview.jsp";
	}
	else if("service_day".equals(producttype)|| "service_night".equals(producttype))
	{
		_jsp += "servicedayview.jsp?producttype="+producttype;
	}
	else
	{
		if(parseNull(GlobalParm.getParm("CUSTOM_PRODUCT_VIEW")).length() == 0) _jsp += "newproductview.jsp";
		else _jsp += parseNull(GlobalParm.getParm("CUSTOM_PRODUCT_VIEW"));
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
	com.etn.util.Logger.info("pagetemplatedetailsview.jsp", _jsp);
	
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