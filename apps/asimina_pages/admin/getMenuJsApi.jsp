<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /> <%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%> <% request.setCharacterEncoding("UTF-8"); 
response.setCharacterEncoding("UTF-8"); %> <%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.pages.PagesUtil, com.etn.pages.PagesGenerator, java.util.LinkedHashMap, org.json.*, 
org.jsoup.*"%> <%@ include file="../WEB-INF/include/commonMethod.jsp"%> <%@ include file="pagesUtil.jsp"%> <%!
	String fixUrls(String domain, String menuPath, String html)
	{
		org.jsoup.nodes.Document doc = Jsoup.parse("<div id='FIX_HTML_FOR_EXTERNAL'>"+html+"</div>");
		doc.outputSettings().charset("utf-8");
		
		org.jsoup.select.Elements eles = doc.select("a[href]");
		for(org.jsoup.nodes.Element ele : eles)
		{
			String href = PagesUtil.parseNull(ele.attr("href"));
			
			if(href.length() == 0 || href.equals("#")) continue;
			if(href.startsWith("tel:")) continue;
			if(href.startsWith("mailto:")) continue;
			if(href.startsWith("javascript:")) continue;
			
			if(href.toLowerCase().startsWith("http://") == false && href.toLowerCase().startsWith("https://") == false)
			{
				if(href.toLowerCase().startsWith("/") == false) ele.attr("href", menuPath + href);
				else ele.attr("href", domain + href);
			}
		}
		
		eles = doc.select("img[src]");
		for(org.jsoup.nodes.Element ele : eles)
		{
			String src = PagesUtil.parseNull(ele.attr("src"));
			if(src.toLowerCase().startsWith("data:")) continue;
			if(src.length() == 0 || src.startsWith("#")) continue;
								
			if(src.toLowerCase().startsWith("http://") == false && src.toLowerCase().startsWith("https://") == false)
			{
				ele.attr("src", domain + src);
			}
		}
		eles = doc.select("span[data-svg]");
		for(org.jsoup.nodes.Element ele : eles)
		{
			String src = PagesUtil.parseNull(ele.attr("data-svg"));
			if(src.toLowerCase().startsWith("data:")) continue;
			if(src.length() == 0 || src.startsWith("#")) continue;
								
			if(src.toLowerCase().startsWith("http://") == false && src.toLowerCase().startsWith("https://") == false)
			{
				ele.attr("data-svg", domain + src);
			}
		}
		return doc.select("#FIX_HTML_FOR_EXTERNAL").first().html();
	}
	void fixFilesUrls(JSONObject data, String domain, String tag)
	{
		if(data.has(tag) == false) return;
		JSONArray jFiles = new JSONArray();
		for(int i=0;i<data.getJSONArray(tag).length();i++)
		{
			jFiles.put(domain + data.getJSONArray(tag).getString(i));
		}
		data.remove(tag);
		data.put(tag, jFiles);
	}
%> <%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;
    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();
    try{
        String menuJsUuid = parseNull(request.getParameter("id"));
        String langCode = parseNull(request.getParameter("lang"));
        if(menuJsUuid.length() == 0 || langCode.length() == 0){
            throw new Exception("Invalid params");
        }
        String q = "SELECT mjd.* "
            + " FROM menu_js mj"
            + " JOIN menu_js_details mjd ON mj.id = mjd.menu_js_id"
            + " JOIN language l ON mjd.langue_id = l.langue_id "
            + " WHERE mj.uuid = " + escape.cote(menuJsUuid)
            + " AND l.langue_code = " + escape.cote(langCode)
            + " AND mj.publish_status = 'published'";
        Set rs = Etn.execute(q);
        if(!rs.next()){
            throw new Exception("");
        }
        try{
            data = new JSONObject(rs.value("published_json"));
			String domain = "";
			String menuPath = "";
			Set rsP = Etn.execute("select s.domain, sm.production_path "+
				" from "+GlobalParm.getParm("PROD_PORTAL_DB")+".sites s "+
				" join "+GlobalParm.getParm("PROD_PORTAL_DB")+".site_menus sm on sm.site_id = s.id and sm.lang = "+escape.cote(langCode)+
				" join menu_js m on m.site_id = s.id where m.uuid = "+escape.cote(menuJsUuid));
			if(rsP.next())
			{
				domain = PagesUtil.parseNull(rsP.value("domain"));
				menuPath = PagesUtil.parseNull(rsP.value("production_path"));
			}
			if(PagesUtil.parseNull(domain).length() == 0)
			{
				//production domains are always in https so we must add https here
				domain = "https://"+request.getServerName();
			}
			
			menuPath = domain + "/" + menuPath;
			
			fixFilesUrls(data, domain, "jsFiles");
			fixFilesUrls(data, domain, "headJsFiles");
			fixFilesUrls(data, domain, "bodyJsFiles");
			
			fixFilesUrls(data, domain, "cssFiles");
			fixFilesUrls(data, domain, "bodyCssFiles");
			fixFilesUrls(data, domain, "headCssFiles");
			
			if(data.has("header"))
			{
				String header = data.getString("header");
				data.remove("header");
				data.put("header", fixUrls(domain, menuPath, header));
			}
			if(data.has("footer"))
			{
				String footer = data.getString("footer");
				data.remove("footer");
				data.put("footer", fixUrls(domain, menuPath, footer));
			}
			
        }catch (JSONException e) {
            Logger.debug("Invalid JSON in menu js " + rs.value("menu_js_id") + " | " + langCode);
            e.printStackTrace();
        }
        status = STATUS_SUCCESS;
    }
    catch(Exception ex){
        message = ex.getMessage();
        //ex.printStackTrace();
    }
    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>
