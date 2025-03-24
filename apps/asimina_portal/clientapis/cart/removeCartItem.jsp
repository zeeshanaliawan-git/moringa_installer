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
<%@ include file="../errorTypes.jsp"%>

<%!

	String getVariantId(com.etn.beans.Contexte Etn, String variantUUID)
	{
		if(variantUUID.length() > 0)
		{
			Set rsVariant = Etn.execute("select id from " + GlobalParm.getParm("CATALOG_DB") + ".product_variants where uuid = " + escape.cote(variantUUID));
			if(rsVariant != null && rsVariant.next())
			{
				return rsVariant.value("id");
			}
		}
		return "";
	}        
%>

<%
	try
	{
		String variantUUID = parseNull(request.getParameter("variantId"));
		String muid = parseNull(request.getParameter("muid"));
		String sessionToken = parseNull(request.getParameter("sessionToken"));
		Set menuRs = Etn.execute("select * from site_menus where menu_uuid="+escape.cote(muid));
		String sessionId = com.etn.asimina.cart.CartHelper.getCartSessionId(request);
		if(muid.length() > 0 && menuRs != null && menuRs.next())
		{	
			String siteId = menuRs.value("site_id");	
			Set rsSite = Etn.execute("select enable_ecommerce from sites where id = " + escape.cote(siteId));
			if(rsSite != null && rsSite.next())
			{
				if("1".equals(rsSite.value("enable_ecommerce")))
				{
					String variantId = getVariantId(Etn,variantUUID);
					if(variantId.length() > 0)
					{
				
						String dbSessionToken = com.etn.asimina.cart.CartHelper.getSessionToken(Etn, sessionId, siteId);
						if(!sessionToken.equals(dbSessionToken))
						{
							out.write("{\"error\":true,\"status\":" + ErrorTypes.SESSION_TOKEN_MISMATCH + ",\"message\":\"" + ErrorMessages.SESSION_TOKEN_MISMATCH + "\"}");
						}
						else
						{
							String cartId = com.etn.asimina.cart.CartHelper.initialize(Etn, request, response, siteId, menuRs.value("lang"));
							if(com.etn.asimina.cart.CartHelper.removeItem(Etn,cartId,variantId))
							{
								com.etn.asimina.beans.Cart cart = com.etn.asimina.cart.CartHelper.loadCart(Etn, request, sessionId, siteId, muid, true, true);
								out.write("{\"error\":false,\"status\":" + 0 + ",\"sessionToken\":\"" + com.etn.asimina.cart.CartHelper.setSessionToken(Etn, cart) + "\"}");
							}
							else
							{
								out.write("{\"error\":true,\"status\":" + ErrorTypes.CART_ITEM_NOT_REMOVED + ",\"message\":\"" + ErrorMessages.CART_ITEM_NOT_REMOVED + "\"}");
							}
						}
					}
					else
					{
						out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_VARIANT_ID + ",\"message\":\"" + ErrorMessages.INVALID_VARIANT_ID + "\"}");
					}
				}
				else
				{
					out.write("{\"error\":true,\"status\":" + ErrorTypes.ECOMMERCE_DISABLED + ",\"message\":\"" + ErrorMessages.ECOMMERCE_DISABLED + "\"}");
				}
			}
			else
			{
				out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_SITE_ID + ",\"message\":\"" + ErrorMessages.INVALID_SITE_ID + "\"}");
			}
		}
		else
		{
			out.write("{\"error\":true,\"status\":" + ErrorTypes.INVALID_MENU_ID + ",\"message\":\"" + ErrorMessages.INVALID_MENU_ID + "\"}");
		}
	}
	catch(Exception ex)
	{
		ex.printStackTrace();
		JSONObject error = new JSONObject();
		error.put("error",true);
		error.put("status",ErrorTypes.SOME_EXCEPTION);
		error.put("message",ex.toString());
		error.put("stackTrace",getStackTrace(ex));
		out.write(error.toString());
	}
%>