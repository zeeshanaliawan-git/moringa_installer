<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>

<%@ include file="common.jsp" %>
<%@ include file="jsonParser.jsp" %>

<%!
	String getIsSelected(String val, String currentVal)
	{
		if(val.equalsIgnoreCase(currentVal)) return "selected";
		return "";
	}

	String getFullPath(List<String> tags)
	{
		String s = "";
		for(String t : tags)
		{
			if(s.length() > 0) s += "." + t;
			else s = t;
		}
		return s;
	}

	String getTagTypes(List<String> tagTypes)
	{
		String s = "";
		for(String t : tagTypes)
		{
			if(s.length() > 0) s += "," + t;
			else s = t;
		}
		return s;
	}

	String getHtml(Map<String, Object> map, int level, boolean parentIsArray, String parentJsonTag, List<String> tagsPath, List<String> tagsType )
	{

		String html = "";
		int width = 350;
		int margin = 0;
		margin = 15*level;
		width = width - margin;

		int count = 0;
		for(String key : map.keySet())
		{   
			String displayKey = key;
			boolean selectAllowed = true;
			int prop = 0 ;
			
			html += "<div style=\"margin-left:"+margin+"px;padding-top:2px; padding-bottom:2px;\">";
		
			String selectedTag = getFullPath(tagsPath);
			if(selectedTag.length()==0) selectedTag = key;
			else selectedTag += "." + key;

			if(map.get(key) instanceof MyObject)
			{
				if(((MyObject)map.get(key)).isArray)
				{
					tagsPath.add(key + "[*]");
					prop = 1;
					tagsType.add("1");
				}
				else if(((MyObject)map.get(key)).isObject)
				{	
					tagsPath.add(key);
					selectAllowed = false;
					tagsType.add("0");
				}
				else
				{	
					tagsPath.add(key);
					tagsType.add("0");
					if(key.startsWith("EXPSYS_SPECIAL_COL_"))
					{
						String defaultHeaderName = parseNull(((MyObject)map.get(key)).defaultHeaderName);
						if(defaultHeaderName.length() > 0) displayKey += " (" + defaultHeaderName + ")";
					}
					prop = 3;
				}
			}
			else
			{
				tagsType.add("0");
				prop = 3;
			}
			
			if(selectAllowed) html += "<a style='text-decoration:none; color:black' href='javascript:setSelectedJson(\""+selectedTag+"\",\""+prop+"\",\""+getTagTypes(tagsType)+"\");'>"+displayKey+"</a>";
			else html += key;
			if(map.get(key) instanceof MyObject)
			{
				level ++;
				html += getHtml(((MyObject)map.get(key)).map, level, ((MyObject)map.get(key)).isArray, key, tagsPath, tagsType);
				level --;
				tagsPath.remove(tagsPath.size() - 1);
			}
 
	
			tagsType.remove(tagsType.size() - 1);
			html += "</div>";
		}
		return html;
	}


%>
<%
	String jsonId = parseNull(request.getParameter("jsonid"));
	Set rsScr = Etn.execute("select * from expert_system_json where id = " + escape.cote(jsonId));
	rsScr.next();

	JsonParser parser = new JsonParser();
	Map<String, Object> map = parse(parser, rsScr.value("json"), new ArrayList<ColsDatas>());        
	
	int level = 0;
	List<String> tagsPath = new ArrayList<String>();
	List<String> tagsType = new ArrayList<String>();
	String html = getHtml(map, level, false, "", tagsPath, tagsType);
	out.write(html);
%>