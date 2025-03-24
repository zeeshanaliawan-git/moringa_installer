<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.sql.escape, java.util.*, javax.servlet.http.Cookie, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken"%>
<%@ page import="java.io.*"%>
<%@ include file="/common.jsp"%>
<%@ include file="/cart/lib_msg.jsp"%>
<%@ include file="/cart/common.jsp"%>
<%@ include file="/cart/commonprice.jsp"%>

<%!
        
	boolean isValidEntry(com.etn.beans.Contexte Etn, String variant_id, String client_id){
		if(client_id.length()>0) return true;
		
		Set rsVariant = Etn.execute("select c.buy_status from "+GlobalParm.getParm("CATALOG_DB")+".catalogs c inner join "+GlobalParm.getParm("CATALOG_DB")+".products p on c.id=p.catalog_id inner join "+GlobalParm.getParm("CATALOG_DB")+".product_variants pv on p.id=pv.product_id where pv.id="+escape.cote(variant_id));
		rsVariant.next();
		
		if(rsVariant.value(0).equals("logged")) return false;            
		else return true;
	}
        
%>

<%
	String variant_id = parseNull(request.getParameter("id"));
	String selectedComewithVariant = parseNull(request.getParameter("selectedComewithVariant"));
	String sku = parseNull(request.getParameter("sku"));
	String muid = parseNull(request.getParameter("muid"));
	String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
	String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
	if(!isValidEntry(Etn, variant_id, client_id)){
		out.write("{\"status\":\"ERROR\", \"type\":\"only_logged\", \"reason\":\"Only logged-in users can add this product!\"}");
		return;
	}
	

	Set menuRs = Etn.execute("select * from site_menus where menu_uuid="+escape.cote(muid));
	menuRs.next();
	
	String site_id = menuRs.value("site_id");
	
	String cartId = com.etn.asimina.cart.CartHelper.initialize(Etn, request, response, site_id, menuRs.value("lang"));
	java.util.Map<String, String> res = com.etn.asimina.cart.CartHelper.addItem(Etn, request, site_id, cartId, sku, variant_id, selectedComewithVariant);
	if(res.get("status").equals("SUCCESS"))
	{
		out.write("{\"status\":\"SUCCESS\"}");
	}
	else
	{
		out.write("{\"status\":\""+res.get("status")+"\", \"type\":\""+res.get("err_type")+"\", \"reason\":\""+res.get("err_msg")+"\"}");
	}                        
%>
