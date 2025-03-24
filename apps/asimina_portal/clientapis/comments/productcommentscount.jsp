<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm, com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject, org.json.JSONArray, java.util.*"%>


<%
	String[] productIds = request.getParameterValues("id");
	JSONObject json = new JSONObject();
	if(productIds != null && productIds.length > 0)
	{
		json.put("status", 0);
		JSONArray products = new JSONArray();
		json.put("products", products);
		for(int i=0; i<productIds.length; i++)
		{
			int cnt = getCount(Etn, PortalHelper.parseNull(productIds[i]), "product");
			JSONObject jproduct = new JSONObject();
			jproduct.put("product_id",PortalHelper.parseNull(productIds[i]));
			jproduct.put("count", cnt);
			products.put(jproduct);
		}
	}
	else
	{		
		json.put("status", 10);
		json.put("msg", "No product IDs provided");
	}

	out.write(json.toString());
%>


