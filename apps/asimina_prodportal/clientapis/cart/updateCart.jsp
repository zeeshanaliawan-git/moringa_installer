<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.sql.escape, java.util.*, javax.servlet.http.Cookie, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.asimina.cart.CartHelper, com.etn.util.Logger"%>
<%@ page import="java.io.*"%>
<%@ include file="/common.jsp"%>
<%@ include file="/cart/lib_msg.jsp"%>
<%@ include file="/cart/common.jsp"%>
<%@ include file="/cart/commonprice.jsp"%>
<%@ include file="../errorTypes.jsp"%>

<%!  

	class Variant
	{
		public Variant(String variantId,String price)
		{
			this.variantId = variantId;
			this.price = price;
		}
		public String variantId;
		public String price;
		public boolean hasPrice()
		{
			double priceD = parseDouble(this.price);
			return priceD > 0;
		}
	}
	
	double parseDouble(String number)
	{
		double numberD = 0;
		try
		{
			numberD = Double.parseDouble(number);
		}
		catch(NumberFormatException ex)
		{
			Logger.info("clientapis/cart/updateCart.jsp", "Number:" + number);
		}
		return numberD;
	}
	
	boolean isValidEntry(com.etn.beans.Contexte Etn, String variantUUID, String clientId)
	{
		if(clientId.length()>0) return true;
		
		Set rsVariant = Etn.execute("select c.buy_status from "+GlobalParm.getParm("CATALOG_DB")+".catalogs c inner join "+GlobalParm.getParm("CATALOG_DB")+".products p on c.id=p.catalog_id inner join "+GlobalParm.getParm("CATALOG_DB")+".product_variants pv on p.id=pv.product_id where pv.uuid="+escape.cote(variantUUID));
		rsVariant.next();
		
		if(rsVariant.value(0).equals("logged")) return false;            
		else return true;
	}
	
	Variant getVariant(com.etn.beans.Contexte Etn, String variantUUID)
	{
		if(variantUUID.length() > 0)
		{
			Set rsVariant = Etn.execute("select * from " + GlobalParm.getParm("CATALOG_DB") + ".product_variants where uuid = " + escape.cote(variantUUID));
			if(rsVariant != null && rsVariant.next())
			{
				return new Variant(parseNull(rsVariant.value("id")),parseNull(rsVariant.value("price")));
			}
		}
		return null;
	}
	
	JSONObject getResponse(boolean error,int status,String message) throws Exception
	{
		return new JSONObject().put("error",error).put("status",status).put("message",message);
	}
        
%>

<%
	try
	{	
		Logger.info("clientapis/cart/updateCart.jsp", "Start");
		String variantUUID = parseNull(request.getParameter("variantId"));
		String sku = "";
		if(variantUUID.length() == 0)
		{
			sku = parseNull(request.getParameter("sku"));
			Logger.info("clientapis/cart/updateCart.jsp", "sku : " + sku);
			if(sku.length() > 0)
			{
				Set rsV = Etn.execute("Select * from "+GlobalParm.getParm("CATALOG_DB")+".product_variants where sku = "+escape.cote(sku));
				if(rsV != null && rsV.next())
				{
					variantUUID = parseNull(rsV.value("uuid"));
				}
			}
		}
		Logger.info("clientapis/cart/updateCart.jsp", "variantUUID : " + variantUUID);		
		
		String selectedComewithVariantUUID = parseNull(request.getParameter("selectedComewithVariant"));
		String muid = parseNull(request.getParameter("muid"));
		
		if(muid.length() == 0)
		{
			String suid = parseNull(request.getParameter("suid"));
			String lang = parseNull(request.getParameter("lang"));
			if(suid.length() > 0 && lang.length() > 0)
			{
				Set menuRs = Etn.execute("select m.menu_uuid from site_menus m join sites s on s.id = m.site_id where m.lang = "+escape.cote(lang)+" and s.suid = "+escape.cote(suid));
				if(menuRs != null && menuRs.next())
				{
					muid = parseNull(menuRs.value("menu_uuid"));
				}
			}			
		}
		
		String price = parseNull(request.getParameter("price"));
		String clientId = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
		String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
		JSONObject resp = new JSONObject();	
		
		if(!isValidEntry(Etn, variantUUID, clientId))
		{
			resp = getResponse(true,ErrorTypes.ONLY_LOGGED_IN,ErrorMessages.ONLY_LOGGED_IN);
		}
		else
		{
			Set menuRs = Etn.execute("select * from site_menus where menu_uuid="+escape.cote(muid));
			if(muid.length() > 0 && menuRs != null && menuRs.next())
			{	
				Variant variant = getVariant(Etn,variantUUID);
				if(variant != null && variant.variantId.length() > 0)
				{
					String variantId = variant.variantId;
					Variant selectedComewithVariant = getVariant(Etn,selectedComewithVariantUUID);
					if((selectedComewithVariantUUID.length() == 0) || (selectedComewithVariantUUID.length() > 0 && selectedComewithVariant != null && selectedComewithVariant.variantId.length() > 0))
					{
						String selectedComewithVariantId = "";
						if(selectedComewithVariantUUID.length() > 0) selectedComewithVariantId = selectedComewithVariant.variantId;
						String siteId = menuRs.value("site_id");						
						String cartId = CartHelper.initialize(Etn, request, response, siteId, menuRs.value("lang"));
						Logger.info("clientapis/cart/updateCart.jsp", "cartId:" + cartId);
						
						String cartType = "";						
						Set rsCart = Etn.execute("select * from cart where id = "+escape.cote(cartId));
						if(rsCart.next()) cartType = parseNull(rsCart.value("cart_type"));
						if(cartType.length() == 0) cartType = CartHelper.Type.NORMAL;
						Logger.info("clientapis/cart/updateCart.jsp", "cartType:" + cartType);

						double dMaxAmountAllowed = 0;
						if(cartType.equalsIgnoreCase(CartHelper.Type.TOPUP) || cartType.equalsIgnoreCase(CartHelper.Type.CARD_TO_WALLET))
						{
							Set rsShopParams = Etn.execute("select topup_max_amount, card2wallet_max_amount from "+GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id = "+escape.cote(siteId));
							rsShopParams.next();						
							
							String _col = "topup_max_amount";
							if(cartType.equalsIgnoreCase(CartHelper.Type.CARD_TO_WALLET)) _col = "card2wallet_max_amount";
							dMaxAmountAllowed = parseDouble(rsShopParams.value(_col));
							Logger.info("clientapis/cart/updateCart.jsp", _col+":" + dMaxAmountAllowed);
						}
						
						java.util.Map<String, String> res = null;
						if(variant.hasPrice())
						{
							Logger.info("clientapis/cart/updateCart.jsp", "in price");
							res = com.etn.asimina.cart.CartHelper.addItem(Etn, request, siteId, cartId, sku, variantId, selectedComewithVariantId);
						}
						else
						{
							Logger.info("clientapis/cart/updateCart.jsp", "in zero price");
							double priceD = parseDouble(price);
							if(cartType.equalsIgnoreCase(CartHelper.Type.NORMAL) == false && dMaxAmountAllowed > 0 && priceD > dMaxAmountAllowed)
							{
								resp = getResponse(true,ErrorTypes.PRICE_LIMIT_EXCEED,ErrorMessages.PRICE_LIMIT_EXCEED);
							}
							else if(priceD > 0)
							{
								res = CartHelper.addItem(Etn, request, siteId, cartId, sku, variantId, selectedComewithVariantId,priceD);
							}
							else
							{
								resp = getResponse(true,ErrorTypes.INVALID_PRICE,ErrorMessages.INVALID_PRICE);
							}
						}
						if(res != null)
						{
							Logger.info("clientapis/cart/updateCart.jsp", "status:" + res.get("err_msg"));
							if(res.get("status") != null && res.get("status").equals("SUCCESS"))
							{
								resp.put("error",false);
								resp.put("status",0);
								resp.put("sessionToken", CartHelper.setSessionTokenByCartId(Etn, cartId, siteId));
							}
							else
							{	
								resp = getResponse(true,ErrorTypes.CART_ITEM_NOT_ADDED,ErrorMessages.CART_ITEM_NOT_ADDED);
								resp.put("err_type",res.get("err_type"));
								resp.put("err_msg",res.get("err_msg"));
							}
						}
						else
						{
							Logger.info("clientapis/cart/updateCart.jsp", "res is null");
						}
					}
					else
					{
						resp = getResponse(true,ErrorTypes.INVALID_VARIANT_ID,ErrorMessages.INVALID_VARIANT_ID);
					}
				}
				else
				{				
					resp = getResponse(true,ErrorTypes.INVALID_VARIANT_ID,ErrorMessages.INVALID_VARIANT_ID);
				}
			}
			else
			{
				resp = getResponse(true,ErrorTypes.INVALID_MENU_ID,ErrorMessages.INVALID_MENU_ID);
			}
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
