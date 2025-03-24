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
	String _error_msg = "Some error occurred while processing cart";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "funnel";
	
	String sessionId = CartHelper.getCartSessionId(request);
	System.out.println("......session_id:" + sessionId);
%>

<%
	try
	{
		String sessionToken = parseNull(request.getParameter("sessionToken"));
		String muid = parseNull(request.getParameter("muid"));
		JSONObject resp = new JSONObject();
		Set rsMenu = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(muid));
		if(muid.length() > 0 && rsMenu != null && rsMenu.next())
		{
			String lang = parseNull(rsMenu.value("lang"));
			Set rsLang =Etn.execute("select * from language where langue_code="+escape.cote(lang));
			if(rsLang != null && rsLang.next())
			{
				String siteId = parseNull(rsMenu.value("site_id"));
				Set rsSite = Etn.execute("select enable_ecommerce from sites where id = " + escape.cote(siteId));
				if(rsSite != null && rsSite.next())
				{
					if("1".equals(rsSite.value("enable_ecommerce")))
					{
						String dbSessionToken = CartHelper.getSessionToken(Etn, sessionId, siteId);
						System.out.println("...........................dbSessionToken:" + dbSessionToken + " sessionToken:" + sessionToken);
						if(!sessionToken.equals(dbSessionToken))
						{
							resp.put("error",true);
							resp.put("status",ErrorTypes.SESSION_TOKEN_MISMATCH);
							resp.put("message",ErrorMessages.SESSION_TOKEN_MISMATCH);
						}
						else
						{
							set_lang(lang,request, Etn);
							Set rsShop =Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id="+escape.cote(siteId));
							if(rsShop != null && rsShop.next())
							{
								String client_id = "";
								boolean logged = false;
								String client_uuid = "";	
								Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
								if(client != null)
								{
									logged = true;
									client_id = client.getProperty("id");
									client_uuid = client.getProperty("client_uuid");
								}
								
								Cart cart = CartHelper.loadCart(Etn, request, sessionId, siteId, muid, true, true);
								
								
								if(cart.isEmpty())
								{		
									resp.put("error",true);
									resp.put("message","cart is empty");
									resp.put("redirectUrl",cart.getError(CartError.EMPTY_CART).getReturnUrl());
								}
								else if(cart.getError(CartError.PROMO_ERROR) != null)
								{
									resp.put("error",true);
									resp.put("message","promo error");
									resp.put("redirectUrl","cart.jsp?muid=" + muid);
								}
								else
								{	
									HashMap<String, String> paymentImages = new HashMap<String, String>();
									paymentImages.put("credit_card","/src/assets/icons/payment-method/Visa.png");
									paymentImages.put("cash_on_delivery","/src/assets/icons/payment-method/ic_Currency_money.png");
									paymentImages.put("cash_on_pickup","/src/assets/icons/payment-method/ic_Currency_money.png");
									paymentImages.put("orange_money","/src/assets/icons/payment-method/Orangemoney.png");
									paymentImages.put("paypal","/src/assets/icons/payment-method/Paypal.png");
									paymentImages.put("orange_money_obf","/src/assets/icons/payment-method/Orangemoney.png");

									String defaultcurrency = cart.getDefaultCurrency();
									String priceformatter = cart.getPriceFormatter();
									String roundto = cart.getRoundTo();
									String showdecimals = cart.getShowDecimals();        
									
									JSONArray paymentMethods = new JSONArray();
									Set rsPaymentMethods = Etn.execute("select pm.*,apm.test_redirect_url,apm.prod_redirect_url from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".payment_methods pm join " + com.etn.beans.app.GlobalParm.getParm("PREPROD_CATALOG_DB") + ".all_payment_methods apm on pm.method = apm.method where site_id = " + escape.cote(siteId) + " and enable=1 order by orderSeq;");
									if(rsPaymentMethods != null)
									{
										while(rsPaymentMethods.next())
										{
											JSONObject paymentMethod = new JSONObject();
											paymentMethod.put("method",escapeCoteValue(rsPaymentMethods.value("method")));
											paymentMethod.put("price",escapeCoteValue((parseNullDouble(rsPaymentMethods.value("price"))<=0?"0":formatPrice(priceformatter, roundto, showdecimals, rsPaymentMethods.value("price"), true))));
											paymentMethod.put("imageUrl",escapeCoteValue(parseNull(paymentImages.get(rsPaymentMethods.value("method")))));
											paymentMethod.put("priceLabel",escapeCoteValue((parseNullDouble(rsPaymentMethods.value("price"))<=0?parseNull(rsShop.value("lang_"+ parseNull(rsLang.value("langue_id"))+"_free_payment_method")):formatPrice(priceformatter, roundto, showdecimals, rsPaymentMethods.value("price"))+" "+defaultcurrency)));
											paymentMethod.put("displayName",libelle_msg(Etn, request, rsPaymentMethods.value("displayName")));
											System.out.println("......" + com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV"));
											if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV")))
											{
												paymentMethod.put("redirectUrl",rsPaymentMethods.value("prod_redirect_url"));
											}
											else
											{
												paymentMethod.put("redirectUrl",rsPaymentMethods.value("test_redirect_url"));
											}
											paymentMethods.put(paymentMethod);
										}
										resp.put("error",false);
										resp.put("status",0);
										resp.put("paymentMethods",paymentMethods);
										resp.put("sessionToken",CartHelper.setSessionToken(Etn, cart));
									}
									else
									{
										resp.put("error",true);
										resp.put("status",ErrorTypes.RESULT_SET_NULL);
										resp.put("message",ErrorMessages.RESULT_SET_NULL);
									}
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
				resp.put("status",ErrorTypes.INVALID_LANG);
				resp.put("message",ErrorMessages.INVALID_LANG);
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