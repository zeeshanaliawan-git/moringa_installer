<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, org.json.JSONObject, org.json.JSONArray"%>

<%!
	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	String getHomepageTranslation(com.etn.beans.Contexte Etn, String langId)
	{
		String home = "Homepage";
		Set rst = Etn.execute("select langue_" + langId + " from langue_msg where LANGUE_REF = 'home' ");
		if(rst.next() && parseNull(rst.value(0)).length() > 0) home = parseNull(rst.value(0));
		return home;
	}
%>


<%
	response.setHeader("X-Frame-Options","deny");
	boolean bIsProd = "1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV"));

	String cacheUuid = parseNull(request.getParameter("cuid"));

	JSONArray bArray = new JSONArray();
	if(cacheUuid.length() > 0)
	{		
		if(bIsProd == false)
		{
			Set rs = Etn.execute("select m.published_home_url, c.ptitle, l.langue_id from site_menus m, language l, cached_pages c where m.id = c.menu_id and m.lang = l.langue_code and c.cache_uuid = " + escape.cote(cacheUuid));		
			String ptitle = "";
			String langId = "";
			String publishedHomeUrl = "";		
			if(rs.next())
			{
				langId = parseNull(rs.value("langue_id"));			
				ptitle = parseNull(rs.value("ptitle"));
				publishedHomeUrl = parseNull(rs.value("published_home_url"));								
			}
			if(langId.length() == 0) langId = "1";
			
			JSONObject bobj = new JSONObject();
			bobj.put("name",getHomepageTranslation(Etn, langId));
			bobj.put("url",publishedHomeUrl);
			bArray.put(bobj);
			
			bobj = new JSONObject();
			bobj.put("name",ptitle);
			bobj.put("url","#");
			bArray.put(bobj);
		}
		else
		{
			Set rs = Etn.execute("select m.published_home_url, cpp.breadcrumb, l.langue_id from site_menus m, language l, cached_pages cp, cached_pages_path cpp where l.langue_code = m.lang and m.id = cp.menu_id and cpp.id = cp.id and cp.cache_uuid = " + escape.cote(cacheUuid));
			String breadcrumbJson = "";
			String langId = "";
			String publishedHomeUrl = "";
			if(rs.next())
			{
				langId = parseNull(rs.value("langue_id"));
				breadcrumbJson = parseNull(rs.value("breadcrumb"));
				publishedHomeUrl = parseNull(rs.value("published_home_url"));					
			}
			if(langId.length() == 0) langId = "1";
			if(parseNull(breadcrumbJson).length() > 0)
			{
				//System.out.println(langId + " :: " + breadcrumbJson);
				JSONArray jArray = new JSONArray(breadcrumbJson);
				for(int i=0;i<jArray.length();i++)
				{
					JSONObject jobj = jArray.getJSONObject(i);		
					if("1".equals(parseNull(jobj.optString("selected"))))
					{
						JSONObject bobj = new JSONObject();
						if("1".equals(parseNull(jobj.optString("ishome"))))
						{						
							bobj.put("name",getHomepageTranslation(Etn, langId));
							bobj.put("url",publishedHomeUrl);				
						}
						else
						{
							String pageid = parseNull(jobj.optString("pageid"));
							Set brrs = Etn.execute("select cp.ptitle, cpp.published_url from cached_pages cp left outer join cached_pages_path cpp on cpp.id = cp.id where coalesce(cp.ptitle,'') <> '' and cp.is_url_active = 1 and cp.id = " + escape.cote(pageid));
							if(brrs.next())
							{
								bobj.put("name",parseNull(brrs.value("ptitle")));
								bobj.put("url",parseNull(brrs.value("published_url")));
							}
						}
						bArray.put(bobj);
					}
				}
			}
		}
	}
	//System.out.println(bArray.toString());
	out.write(bArray.toString());
%>
