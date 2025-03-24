<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*"%>
<%@ page import="org.json.JSONObject,org.json.JSONArray" %>

<%@ include file="../../lib_msg.jsp"%>
<%@ include file="../../cart/common.jsp"%>
<%@ include file="../../common2.jsp"%>
<%@ include file="../../common.jsp"%>
<%@ include file="../../cart/priceformatter.jsp"%>
<%@ include file="../errorTypes.jsp"%>


<%
	try
	{
		String sessionToken = parseNull(request.getParameter("sessionToken"));
		String muid = parseNull(request.getParameter("muid"));
		String sessionId = CartHelper.getCartSessionId(request);
		JSONObject resp = new JSONObject();
		Set rsMenu = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(muid));
		if(muid.length() > 0 && rsMenu != null && rsMenu.next())
		{	
			String lang = parseNull(rsMenu.value("lang"));
			String siteId = parseNull(rsMenu.value("site_id"));
			Set rsSite = Etn.execute("select enable_ecommerce from sites where id = " + escape.cote(siteId));
			if(rsSite != null && rsSite.next())
			{
				if("1".equals(rsSite.value("enable_ecommerce")))
				{
					String dbSessionToken = CartHelper.getSessionToken(Etn, sessionId, siteId);
					if(!sessionToken.equals(dbSessionToken))
					{
						resp.put("error",true);
						resp.put("status",ErrorTypes.SESSION_TOKEN_MISMATCH);
						resp.put("message",ErrorMessages.SESSION_TOKEN_MISMATCH);
					}
					else
					{
						Set rsShop = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id="+escape.cote(siteId));
						if(rsShop != null && rsShop.next())
						{
							if(request.getParameter("promoCode") != null)
							{
								String promoCode = parseNull(request.getParameter("promoCode"));
								//this value will be used later by CartHelper
								Etn.executeCmd("update cart set promo_code = "+escape.cote(promoCode) + " where session_id = "+escape.cote(sessionId)+" and site_id = " +escape.cote(siteId));
								Cart cart = CartHelper.loadCart(Etn, request, sessionId, siteId, muid, true, true);
								if(cart.hasPromoError())
								{
									resp.put("error",true);
									resp.put("status",1);
									resp.put("message","promo error");
									resp.put("redirectUrl","cart.jsp?muid="+muid);
								}
								else
								{
									resp.put("error",false);
									resp.put("status",0);
									resp.put("message","promo applied");
									resp.put("sessionToken",CartHelper.setSessionToken(Etn, cart));
								}
							}
							else
							{
								resp.put("error",true);
								resp.put("status",ErrorTypes.INVALID_PROMO_CODE);
								resp.put("message",ErrorMessages.INVALID_PROMO_CODE);
							}
						}
						else
						{
							resp.put("error",true);
							resp.put("status",ErrorTypes.INVALID_SHOP);
							resp.put("message",ErrorMessages.INVALID_SHOP);
						}
					}
				}
				else
				{
					resp.put("error",true);
					resp.put("status",ErrorTypes.ECOMMERCE_DISABLED);
					resp.put("message",ErrorMessages.ECOMMERCE_DISABLED);
				}
			}
			else
			{
				resp.put("error",true);
				resp.put("status",ErrorTypes.INVALID_SITE_ID);
				resp.put("message",ErrorMessages.INVALID_SITE_ID);
			}
		}
		else
		{
			resp.put("error",true);
			resp.put("status",ErrorTypes.INVALID_MENU_ID);
			resp.put("message",ErrorMessages.INVALID_MENU_ID);
		}
		out.write(resp.toString());
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