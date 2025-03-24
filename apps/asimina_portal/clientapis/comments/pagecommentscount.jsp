<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm, com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject, org.json.JSONArray, java.util.*"%>


<%
	String[] pageIds = request.getParameterValues("id");
	JSONObject json = new JSONObject();
	if(pageIds != null && pageIds.length > 0)
	{
		json.put("status", 0);
		JSONArray pages = new JSONArray();
		json.put("pages", pages);
		for(int i=0; i<pageIds.length; i++)
		{
			int cnt = getCount(Etn, PortalHelper.parseNull(pageIds[i]), "page");
			JSONObject jpage = new JSONObject();
			jpage.put("page_id",PortalHelper.parseNull(pageIds[i]));
			jpage.put("count", cnt);
			pages.put(jpage);
		}
	}
	else
	{		
		json.put("status", 10);
		json.put("msg", "No page IDs provided");
	}

	out.write(json.toString());
%>


