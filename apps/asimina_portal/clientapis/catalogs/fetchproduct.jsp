<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.Contexte, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*, com.etn.util.Base64"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.util.Logger"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.*"%>

<%@ include file="productcommons.jsp"%>
<%
	String id = PortalHelper.parseNull(request.getParameter("id"));
	String suid = PortalHelper.parseNull(request.getParameter("suid"));
	String lang = PortalHelper.parseNull(request.getParameter("lang"));

	Logger.debug("clientapis/catalogs/fetchproduct.jsp","id:"+id);
	Logger.debug("clientapis/catalogs/fetchproduct.jsp","suid:"+suid);
	Logger.debug("clientapis/catalogs/fetchproduct.jsp","lang:"+lang);

	String catalogdb = GlobalParm.getParm("CATALOG_DB");

	JSONObject jResp = newJsonObject();

	Set rsSite = Etn.execute("select * from sites where suid = "+escape.cote(suid));
	rsSite.next();
	String siteid = rsSite.value("id");
	
	Set rsP = Etn.execute("select p.*, c.site_id, c.catalog_type from "+catalogdb+".products p join "+catalogdb+".catalogs c on c.id = p.catalog_id and c.site_id = "+escape.cote(siteid)+" where p.product_uuid = "+escape.cote(id));
	if(!rsP.next())
	{
		jResp.put("status", 10);
		jResp.put("err_code", "no_data_found");
		jResp.put("err_msg", "No data found for provided ID");
		out.write(jResp.toString());
		return;		
	}
			
	String catalogtype = rsP.value("catalog_type");
	String catalogid = rsP.value("catalog_id");
	
	String langQry = "select * from language where langue_code = "+escape.cote(lang)+" order by langue_id";
	if(lang.length() == 0) langQry = " select * from language order by langue_id ";
	
	Set rsLang = Etn.execute(langQry);
	rsLang.next();
	lang = rsLang.value("langue_code");
	
	JSONObject jData = newJsonObject();
	
	jData.put("language", lang);
	
	String clientid = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);

	jData.put("product", getProductDetails(Etn, request, id, siteid, lang, clientid));
	
	jData.put("shop_parameters", getShopParameters(Etn, siteid, rsLang.value("langue_id")));
					
	jResp.put("status", 0);
	jResp.put("data", jData);		
	out.write(jResp.toString());
%>