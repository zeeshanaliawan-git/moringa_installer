package com.etn.asimina.cart;

import com.etn.lang.ResultSet.Set;
import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.asimina.util.*;
import com.etn.asimina.beans.*;
import com.etn.asimina.session.*;
import com.etn.util.ItsDate;
import com.etn.asimina.cart.CommonPrice;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.HashSet;
import java.util.Date;
import java.util.UUID;
import java.text.SimpleDateFormat;
import java.net.URLDecoder;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;

import org.json.JSONObject;
import org.json.JSONArray;

/**
* This class implements cart related functions
* 
*/
public class CartHelper
{	
    public static class ItemActions
    {
        public static final String INCREMENT = "inc";
        public static final String DECREMENT = "dec";
    }

    public static class Type
    {
        public static final String NORMAL = "normal";
        public static final String TOPUP = "topup";
        public static final String CARD_TO_WALLET = "card2wallet";
    }	

    public static class Steps
    {
        public static final String PERSONAL_INFO = "personal_info";
        public static final String DELIVERY = "delivery";
        public static final String PAYMENT = "payment";
    }	

	public static List<String> getCartTypes()
	{
		List<String> types = new ArrayList<>();
		types.add(Type.NORMAL);
		types.add(Type.TOPUP);
		types.add(Type.CARD_TO_WALLET);
		return types;
	}	
	
	//by default we always initialize normal cart
    public static String initialize(Contexte Etn, HttpServletRequest request, HttpServletResponse response, String siteId, String lang) throws Exception
	{
		return initialize(Etn, request, response, siteId, lang, PortalHelper.parseNull(request.getParameter("cartType")).toLowerCase());
	}
	
    public static String initialize(Contexte Etn, HttpServletRequest request, HttpServletResponse response, String siteId, String lang, String type) throws Exception
	{		
		type = PortalHelper.parseNull(type).toLowerCase();
		String sessionId = getCartSessionId(request, type);
		String clientId = PortalHelper.parseNull(ClientSession.getInstance().getLoginClientId(Etn, request));
		if(PortalHelper.parseNull(sessionId).length() == 0)//no cart for this session
		{
			Logger.info("CartHelper", "No cart cookie found so create new one");
			sessionId = addNewCart(Etn, response, siteId, clientId, lang, type);
		}
		else//cart cookie found
		{
			Logger.info("CartHelper", "Cart cookie found");
			Set rsCart = Etn.execute("select * from cart where session_id="+escape.cote(sessionId)+" and site_id="+escape.cote(siteId));
			boolean insertNewRow = false; // insert new row either when a row against the current session id and site id do not exist, or when the client id of current cart is different from the user who logged in.
			if(rsCart.next())
			{				
				if(PortalHelper.parseNull(rsCart.value("order_uuid")).length() > 0)
				{
					//some cart was inserted in dandellion but as user did not reach completion page, the cart was not cleaned-up and we have problem in that case
					Logger.error("Cart already has order_uuid set in it. Previous cart was not cleaned-up. We must cleanup now and initialize new cart");
					insertNewRow = true;
					cleanup(Etn, rsCart.value("id"));
				}
				//this If is here for a reason .. dont add it to previous if with an and
				else if(clientId.length() > 0)
				{
					if(PortalHelper.parseNull(rsCart.value("client_id")).length() == 0) Etn.executeCmd("update cart set client_id="+escape.cote(clientId)+" where id="+escape.cote(rsCart.value("id")));
					else if(rsCart.value("client_id").equals(clientId) == false) insertNewRow = true; // means our current cart is already assigned to some other user
				}            
			} 
			else
			{
				insertNewRow = true;
			} 
			
			if(insertNewRow)
			{
				//deleting his existing carts on this site if any, as they are of no use.
				if(clientId.length() > 0) 
				{
					Etn.executeCmd("delete from cart_items where cart_id in (select id from cart where client_id="+escape.cote(clientId)+" and site_id="+escape.cote(siteId)+")");					
					Etn.executeCmd("delete from cart where client_id="+com.etn.sql.escape.cote(clientId)+" and site_id="+escape.cote(siteId));
				}
				sessionId = addNewCart(Etn, response, siteId, clientId, lang, type);
			} 
			
		}
		
		String cartId = "";
		Set rsCart = Etn.execute("select * from cart where session_id="+escape.cote(sessionId)+" and site_id="+escape.cote(siteId));
		if(rsCart.next()) 
		{
			cartId = rsCart.value("id");
			Etn.executeCmd("update cart set lang = "+escape.cote(PortalHelper.parseNull(lang))+" where id = "+escape.cote(cartId));
		}
		return cartId;
	}
	
	private static String addNewCart(Contexte Etn, HttpServletResponse response, String siteId, String clientId, String lang, String type)
	{
		type = PortalHelper.parseNull(type).toLowerCase();
		if(type.length() == 0) type = Type.NORMAL;
		Logger.info("CartHelper", "add new "+type+" cart");
		
		String cookieName = getCookieName(type);
		
		String sessionId = UUID.randomUUID().toString();
		Cookie __cartCookie = new Cookie(cookieName, sessionId);
		__cartCookie.setMaxAge(24*7*60*60);

		__cartCookie.setPath(GlobalParm.getParm("PORTAL_LINK"));
		response.addCookie(__cartCookie);				
		Etn.executeCmd("insert into cart set cart_type = "+escape.cote(type)+", session_access_time = now(), lang = "+escape.cote(PortalHelper.parseNull(lang))+", session_id="+escape.cote(sessionId)+", site_id="+escape.cote(siteId)+", client_id="+escape.cote(PortalHelper.parseNull(clientId)));
		return sessionId;
	}
	
	public static String getCookieName()
	{
		return getCookieName(null);
	}
	
	public static String getCookieName(String type)
	{
		type = PortalHelper.parseNull(type).toLowerCase();
		if(type.length() == 0) type = Type.NORMAL;
		
		String cookieName = GlobalParm.getParm("CART_COOKIE");
		if(type.length() > 0 && type.equalsIgnoreCase(Type.NORMAL) == false) cookieName = GlobalParm.getParm("CART_COOKIE")+"_"+PortalHelper.parseNull(type).toLowerCase();
		return cookieName;
	}
	
	public static boolean removeItem(Contexte Etn, String cartId, String variantId)
	{
		int i = Etn.executeCmd("delete from cart_items where variant_id = "+escape.cote(variantId)+" and cart_id ="+escape.cote(cartId));
		if(i > 0) 
		{
			Etn.executeCmd("update cart set session_access_time = now() where id = "+escape.cote(cartId));
			return true;
		}
		return false;
	}
	
	public static boolean removeItem(Contexte Etn, String cartItemId)
	{
		String cartId = "0";
		Set rs = Etn.execute("select * from cart_items where id = "+escape.cote(cartItemId));
		if(rs.next()) cartId = rs.value("cart_id");
		int i = Etn.executeCmd("delete from cart_items where id = "+escape.cote(cartItemId));
		if(i > 0) 
		{
			Etn.executeCmd("update cart set session_access_time = now() where id = "+escape.cote(cartId));
			return true;
		}
		return false;
	}
	
	public static boolean updateItem(Contexte Etn, String cartId, String variantId, String updateType, int qty)
	{
		Set rs = Etn.execute("select * from cart_items where cart_id = "+escape.cote(cartId)+" and variant_id ="+escape.cote(variantId));
		if(rs.next())
		{
			return updateItem(Etn, rs.value("id"), updateType, qty);
		}
		return false;
	}
	
	//updateType can be inc or dec or we can provide a specific quantity in updateType
	public static boolean updateItem(Contexte Etn, String cartItemId, String updateType, int qty)
	{
		String catalogDb = GlobalParm.getParm("CATALOG_DB");
		Set rsP = Etn.execute("select p.product_type from "+catalogDb+".product_variants pv, "+catalogDb+".products p, cart_items ci "+
							" where p.id = pv.product_id and pv.id = ci.variant_id and ci.id = "+escape.cote(cartItemId));
		
		if(rsP.rs.Rows == 0)
		{
			Logger.info("CartHelper","--------------------------------------------------------------");
			Logger.error("CartHelper","Unable to find product against the cart_item_id : "+cartItemId);
			Logger.info("CartHelper","--------------------------------------------------------------");
			return false;
		}
		
		rsP.next();
		String productType = rsP.value("product_type");
		//if("offer_prepaid".equals(productType) || "offer_postpaid".equals(productType) || "simple_virtual_product".equals(productType) || "configurable_virtual_product".equals(productType))
		if(PortalHelper.isOffer(productType))
		{
			Logger.info("CartHelper","Offer's quantity cannot be updated");
			return false;
		}
		
		int i = 0;
		if(updateType.equalsIgnoreCase(ItemActions.INCREMENT))
		{
			i = Etn.executeCmd("update cart_items set quantity=quantity+1 where id="+escape.cote(cartItemId));
		}
		else if(updateType.equalsIgnoreCase(ItemActions.DECREMENT))
		{
			i = Etn.executeCmd("update cart_items set quantity=quantity-1 where quantity>1 and id="+escape.cote(cartItemId));
		}
		else
		{
			if(qty < 1) qty = 1;
			i = Etn.executeCmd("update cart_items set quantity="+escape.cote(qty+"")+" where id="+escape.cote(cartItemId));
		}
		if(i > 0) 
		{
			Etn.executeCmd("update cart c join cart_items ci on ci.cart_id = c.id set c.session_access_time = now() where ci.id = "+escape.cote(cartItemId));
			return true;
		}
		return false;
	}
	
	private static String getCartType(Contexte Etn, String cartId)
	{
		String cartType = "";
		Set rs = Etn.execute("select * from cart  where id ="+escape.cote(cartId));
		if(rs.next()) 
		{
			cartType = PortalHelper.parseNull(rs.value("cart_type"));			
		}
		if(cartType.length() == 0) cartType = CartHelper.Type.NORMAL;//default must be normal cart always
		return cartType;
	}
	
	public static Map<String, String> addItem(Contexte Etn, HttpServletRequest request, String siteId, String cartId, String sku, String variantId, String selectedComewithVariant)
	{
		boolean removeAllItems = false;
		//topup/card2wallet cart can have one item only and ideally that item can have only 1 quantity so we always remove all items from it then add the new one 
		if(getCartType(Etn, cartId).equalsIgnoreCase(Type.NORMAL) == false) removeAllItems = true;
		return addItem(Etn, request, siteId, cartId, sku, variantId, selectedComewithVariant, 0, removeAllItems);
	}
	
	public static Map<String, String> addItem(Contexte Etn, HttpServletRequest request, String siteId, String cartId, String sku, String variantId, String selectedComewithVariant, double price)
	{
		boolean removeAllItems = false;
		//topup/card2wallet cart can have one item only and ideally that item can have only 1 quantity so we always remove all items from it then add the new one 
		if(getCartType(Etn, cartId).equalsIgnoreCase(Type.NORMAL) == false) removeAllItems = true;
		return addItem(Etn, request, siteId, cartId, sku, variantId, selectedComewithVariant, price, removeAllItems);
	}
	
	public static Map<String, String> addItem(Contexte Etn, HttpServletRequest request, String siteId, String cartId, String sku, String variantId, String selectedComewithVariant, boolean removeAllItems)
	{
		return addItem(Etn, request, siteId, cartId, sku, variantId, selectedComewithVariant, 0, removeAllItems);
	}
	
	//removeAllItems means that there can be only one item in this cart .. this is for topup/card2wallet functionality
	private static Map<String, String> addItem(Contexte Etn, HttpServletRequest request, String siteId, String cartId, String sku, String variantId, String selectedComewithVariant, double price, boolean removeAllItems)
	{
		String catalogdb = GlobalParm.getParm("CATALOG_DB");
        String productQuery = "";
        if(PortalHelper.parseNull(sku).length() > 0) 
		{
			productQuery = " select p.product_type, pv.id, p.catalog_id, pv.stock "+
						" from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on pv.product_id = p.id inner join "+catalogdb+".catalogs c on c.id = p.catalog_id "+
						" where pv.sku ="+escape.cote(sku)+" and c.site_id="+escape.cote(siteId);
		}
        else 
		{
			productQuery = " select p.product_type, pv.id, p.catalog_id, pv.stock "+
						" from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on pv.product_id = p.id where pv.id ="+escape.cote(variantId);
		}
		
        Set rsProduct = Etn.execute(productQuery);
        rsProduct.next();
        
		Map<String, String> results = new HashMap<String, String>();
		
        variantId = PortalHelper.parseNull(rsProduct.value("id"));
		
		if(removeAllItems)//we must delete all items from this cart and then add new
		{
			Etn.executeCmd("delete from cart_items where cart_id = "+escape.cote(cartId));
		}
		
        Set rsCartItems = Etn.execute("select * from cart_items where variant_id="+escape.cote(variantId)+" and cart_id="+escape.cote(cartId)+" and COALESCE(comewith_variant_id,'')="+escape.cote(selectedComewithVariant));
        if(rsCartItems.next())
		{
//            if(!(rsProduct.value("product_type").equals("offer_postpaid") || rsProduct.value("product_type").equals("offer_prepaid") 
//				|| "simple_virtual_product".equals(rsProduct.value("product_type")) || "configurable_virtual_product".equals(rsProduct.value("product_type"))))
            if(PortalHelper.isOffer(rsProduct.value("product_type")) == false)
			{
                if(PortalHelper.parseNullInt(rsCartItems.value("quantity")) >= PortalHelper.parseNullInt(rsProduct.value("stock")))
				{
					results.put("status", "ERROR");
					results.put("err_type", "stock_limit");
					results.put("err_msg", "Stock limit reached!");
                }
                else if(PortalHelper.parseNullInt(rsCartItems.value("quantity")) >= CommonPrice.getQuantityLimit(Etn, variantId, CommonPrice.getComewith(Etn, request, variantId, "lang_1_", "1", rsCartItems.value("comewith_excluded"), false, "", PortalHelper.parseNullInt(rsCartItems.value("quantity")), rsCartItems.value("comewith_variant_id"))))
				{
					results.put("status", "ERROR");
					results.put("err_type", "quantity_limit");
					results.put("err_msg", "Quantity limit reached!");
                }
                else 
				{
					Etn.executeCmd("update cart_items set price_per_item = "+escape.cote(""+price)+", quantity = quantity+1 where id="+escape.cote(rsCartItems.value("id")));
					results.put("status", "SUCCESS");
				}
            }else{
				results.put("status", "SUCCESS");
			}
        }
        else if(variantId.length() > 0)
		{
			Set rsshop = Etn.execute("select * from "+catalogdb+".shop_parameters where site_id =  " + escape.cote(siteId) );
			rsshop.next();
			boolean canInsert = true;
            if(rsshop.value("multiple_catalogs_checkout").equals("0"))
			{
                rsCartItems = Etn.execute("select p.catalog_id from cart_items ci inner join "+catalogdb+".product_variants pv on ci.variant_id=pv.id inner join "+catalogdb+".products p on pv.product_id = p.id where ci.cart_id="+escape.cote(cartId));
                if(rsCartItems.next())
				{
                    if(!rsCartItems.value("catalog_id").equals(rsProduct.value("catalog_id")))
					{
						results.put("status", "ERROR");
						results.put("err_type", "multiple_catalogs_checkout");
						results.put("err_msg", "You cannot have items from different catalogs in the same cart!");
						canInsert = false;
                    }
                }
            }
            
			if(canInsert)
			{
				Etn.executeCmd("insert into cart_items set price_per_item ="+escape.cote(""+price)+", quantity = 1, variant_id="+escape.cote(variantId)+", cart_id="+escape.cote(cartId)+", comewith_variant_id="+escape.cote(selectedComewithVariant));            
				results.put("status", "SUCCESS");
			}
        } 
		
		Etn.executeCmd("update cart set session_access_time = now() where id = "+escape.cote(cartId));
		return results;
	}
	
	public static String getSessionToken(Contexte Etn, String cartSessionId, String siteId) throws Exception
	{
		String timeout = PortalHelper.parseNull(GlobalParm.getParm("SHOP_SESSION_TIMEOUT_MINS"));
		if(timeout.length() == 0) timeout = "60"; //mins

		Set rs = Etn.execute("select *, TIMESTAMPDIFF(MINUTE, session_access_time, now()) as _diff from cart where session_id = " + escape.cote(cartSessionId) + " and site_id = "+escape.cote(siteId));
		if(rs.next())
		{
			//if cart was not accessed for "SHOP_SESSION_TIMEOUT_MINS" then we return empty string so that new session can be started			
			if(PortalHelper.parseNullInt(rs.value("_diff")) > PortalHelper.parseNullInt(timeout)) return "";
			else return rs.value("session_token");
		}
		return "";
	}
	
	public static String setSessionTokenByCartId(Contexte Etn, String cartId, String siteId) throws Exception
	{
		String token = UUID.randomUUID().toString();
		Etn.executeCmd("update cart set session_access_time = now(), session_token = " + escape.cote(token) + " where id = " + escape.cote(cartId) + " and site_id = "+escape.cote(siteId));
		return token;
	}
	
	public static String setSessionToken(Contexte Etn, String cartSessionId, String siteId) throws Exception
	{
		String token = UUID.randomUUID().toString();
		Etn.executeCmd("update cart set session_access_time = now(), session_token = " + escape.cote(token) + " where session_id = " + escape.cote(cartSessionId) + " and site_id = "+escape.cote(siteId));
		return token;
	}
	
	public static String setSessionToken(Contexte Etn, Cart cart) throws Exception
	{
		return setSessionToken(Etn, cart.getProperty("session_id"), cart.getProperty("site_id"));
	}
	
	public static List<CartError> getCartErrors(Contexte Etn, HttpServletRequest request, String cartSessionId, String siteId, String menuUuid) throws Exception
	{
		//when load cart errors from updateCheckout.jsp, we do not have to update the access time otherwise user's session can never be timed-out
		//as the session token in db is checked in funnel screens and if we update the access time here as well the access time never times out
		Cart cart = loadCart(Etn, request, cartSessionId, siteId, menuUuid, false, false, false);
		return cart.getErrors();
	}
	
	public static Cart loadCart(Contexte Etn, HttpServletRequest request, String cartSessionId, String siteId, String menuUuid) throws Exception
	{
		return loadCart(Etn, request, cartSessionId, siteId, menuUuid, false, false, false);
	}
	
	public static Cart loadCart(Contexte Etn, HttpServletRequest request, String cartSessionId, String siteId, String menuUuid, boolean removeLowStockItems) throws Exception
	{
		boolean updateAccessTime = false;
		if(removeLowStockItems == true) updateAccessTime = true;
		return loadCart(Etn, request, cartSessionId, siteId, menuUuid, removeLowStockItems, updateAccessTime, false);
	}

	public static Cart loadCart(Contexte Etn, HttpServletRequest request, String cartSessionId, String siteId, String menuUuid, boolean removeLowStockItems, boolean reloadVoucher) throws Exception
	{
		boolean updateAccessTime = false;
		if(removeLowStockItems == true) updateAccessTime = true;
		return loadCart(Etn, request, cartSessionId, siteId, menuUuid, removeLowStockItems, updateAccessTime, reloadVoucher);
	}

	/**
	* This function will load the cart state as per in the db. Will do stock validation and set the error if any item is low on stock and that item will be marked for low stock
	* After stock validation will apply all the cart rules which will apply promo if any, calculate the delivery fees ( if any ), payment fees ( if any ) , cart totals
	*/
	private static Cart loadCart(Contexte Etn, HttpServletRequest request, String cartSessionId, String siteId, String menuUuid, boolean removeLowStockItems, boolean updateAccessTime, boolean reloadVoucher) throws Exception
	{		
		String clientId = ClientSession.getInstance().getLoginClientId(Etn, request);
		
		Logger.info("CartHelper", "Loading cart session_id : " + cartSessionId + " siteid : " + siteId + " menu-uuid : " + menuUuid + " client id : "+ clientId + " removeLowStockItems : " + removeLowStockItems + " updateAccessTime : "+ updateAccessTime);
		Set rsMenu = Etn.execute("select m.*, s.voucher_api_implementation_cls from site_menus m, sites s where s.id = m.site_id and m.menu_uuid = "+escape.cote(menuUuid));
		if(rsMenu.rs.Rows == 0)
		{
			Logger.error("CartHelper","Menu uuid provided does not exists");
			Cart cart = new Cart();
			cart.addError(CartError.EMPTY_CART, "unknowerror.html");
			return cart;
		}
		rsMenu.next();
		
		String menuid = rsMenu.value("id");		
		String langCode = rsMenu.value("lang");
		String langId = "1";//default		
		String voucherApiImplementationClass = PortalHelper.parseNull(rsMenu.value("voucher_api_implementation_cls"));
		//if incoming lang was empty or not found in the language table, we will get the first language by default
		Set __rs1 = Etn.execute("select '0' as _a, langue_code, langue_id from language where langue_code = " + escape.cote(langCode) + " union select '1' as _a, langue_code, langue_id from language where langue_id = 1 order by _a ");
		if(__rs1.next()){
			langId = PortalHelper.parseNull(__rs1.value("langue_id"));
		}
		String prefix = LanguageHelper.getInstance().getProductColumnsPrefix(Etn, langCode);
		
		Logger.info("CartHelper","menu id : " + menuid + " lang : " + langCode);
		
		String cachedResourcesUrl = PortalHelper.getCachedResourcesUrl(Etn, menuid);
		String cachedResourcesFolder = PortalHelper.getMenuResourcesFolder(Etn, menuid);
		String menuPath = PortalHelper.getMenuPath(Etn, menuid);
		
		String emptyCartUrl = "";
        String defaultcurrency = "";
        String currencycode = "";
		String priceformatter = "";
		String roundto = "";
		String showdecimals = "";
		
		String terms = "";
		String terms_error = "";
		String cart_message = "";
		String checkout_login = "";
		String deliver_outside_dep_error_msg = "";
		String deliver_outside_dep = "";
		
		Set rsshop = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".shop_parameters where site_id =  " + escape.cote(siteId) );
		if(rsshop.next())
		{
			if(PortalHelper.parseNull(rsshop.value(prefix + "empty_cart_url")).length() > 0)
			{
				emptyCartUrl = menuPath + PortalHelper.parseNull(rsshop.value(prefix + "empty_cart_url"));
			}			
			
			currencycode = PortalHelper.parseNull(rsshop.value(prefix + "currency"));
			defaultcurrency = LanguageHelper.getInstance().getTranslation(Etn, rsshop.value(prefix + "currency"));
			priceformatter = rsshop.value(prefix + "price_formatter");
			roundto = PortalHelper.parseNull(rsshop.value(prefix + "round_to_decimals"));
			if(roundto.length() == 0) roundto = "0";
			showdecimals = PortalHelper.parseNull(rsshop.value(prefix + "show_decimals"));
			if(showdecimals.length() == 0) showdecimals = "0";
			
			terms = rsshop.value(prefix + "terms");
			terms_error = rsshop.value(prefix + "terms_error");
			cart_message = rsshop.value(prefix + "cart_message");
			checkout_login = rsshop.value("checkout_login");
			deliver_outside_dep_error_msg = PortalHelper.parseNull(rsshop.value(prefix + "deliver_outside_dep_error"));
			deliver_outside_dep = rsshop.value("deliver_outside_dep");
			
		}
		if(emptyCartUrl.length() == 0) emptyCartUrl = "unknowerror.html";//dummy page url so that it will go to 404
		
		Cart cart = new Cart();		
		cart.setLang(langCode);
		cart.setLangId(langId);
		cart.setMenuId(menuid);
		cart.setMenuUuid(menuUuid);
		cart.setLangColumnPrefix(prefix);
		cart.setCurrencyCode(currencycode);
		cart.setDefaultCurrency(defaultcurrency);
		cart.setPriceFormatter(priceformatter);
		cart.setRoundTo(roundto);
		cart.setShowDecimals(showdecimals);
		cart.setItems(new ArrayList<CartItem>());
		cart.setTaxNumbers(new HashMap<String, Integer>());
		cart.setTerms(terms);
		cart.setTermsErrorMsg(terms_error);
		cart.setCartMessage(cart_message);
		cart.setCheckoutRequireLogin("1".equals(checkout_login));
		cart.setAllowMultipleCatalogsCheckout("1".equals(rsshop.value("multiple_catalogs_checkout")));
		cart.setAllowDeliverOutsideDep("1".equals(deliver_outside_dep));
		cart.setDeliverOutsideDepErrorMsg(deliver_outside_dep_error_msg);	

		Set rsCart = Etn.execute("Select *, date_format(delivery_date, '%Y%m%d') as delivery_date_fmt_db from cart where session_id = "+escape.cote(cartSessionId) + " and site_id = "+escape.cote(siteId));
		if(rsCart.next())
		{			
			Etn.executeCmd("update cart set lang = "+escape.cote(langCode)+" where id = "+escape.cote(rsCart.value("id")));
			//every time cart is accessed we will update its access time to know the last access time when getting the session token
			//we only have to update access time when we are loading cart from funnel screens
			if(updateAccessTime) Etn.executeCmd("update cart set session_access_time = now() where id = "+ rsCart.value("id"));
			
			//make sure there are no items in the cart which are already unpublished/deleted
			Etn.executeCmd("delete from cart_items where cart_id = "+escape.cote(rsCart.value("id")) + " and variant_id not in (select id from "+GlobalParm.getParm("CATALOG_DB")+".product_variants)");
			
			for(int i=0; i<rsCart.ColName.length; i++)
			{
				//special case to handle where a shop requires user to register before buying anything 
				//and on checkout screens they dont ask for user's email
				//in thise case the email in cart table will be empty whereas we will have the email in session
				//and we must use that email ... we will not update in cart table but will update in the cart object
				//so that we do not have to handle such case at different places
				String propValue = PortalHelper.parseNull(rsCart.value(i));
				if(rsCart.ColName[i].toLowerCase().equals("email") && propValue.length() == 0)
				{
					Client client = ClientSession.getInstance().getLoggedInClient(Etn, request);
					if(client != null) propValue = PortalHelper.parseNull(client.getProperty("email"));
				}
				else if(rsCart.ColName[i].toLowerCase().equals("cart_type") && propValue.length() == 0)
				{
					propValue = CartHelper.Type.NORMAL;//default always normal
				}
				cart.addProperty(rsCart.ColName[i], propValue);
			}		
			
			//stock validation is done before loading cart items as in some cases we might have to delete low stock items
			Map<String, Object> stockValidation = validateStock(Etn, request, cartSessionId, siteId, cart.isAllowMultipleCatalogsCheckout());
			
			cart.setArticlesCount((Integer)stockValidation.get("articlesCount"));
			
			@SuppressWarnings("unchecked")
			List<Long> stockErrorItemIds = (List<Long>)stockValidation.get("errors");
			if(stockErrorItemIds.isEmpty() == false)
			{
				if(removeLowStockItems)
				{
					//some steps in cart we delete the low stock items as user is already at some point where we cannot give stock error anymore
					//that is how it was implemented in some screens like payment
					for(long itemId : stockErrorItemIds)
					{
						Etn.executeCmd("delete from cart_items where id = "+escape.cote(""+itemId));							
					}
				}
				else 
				{
					Logger.error("CartHelper","Insufficient stock error");
					cart.addError(CartError.INSUFFICIENT_STOCK, GlobalParm.getParm("CART_EXTERNAL_LINK") + "cart.jsp?muid="+menuUuid);
				}
			}			
						
			Set rsCi = Etn.execute("select * from cart_items where cart_id = "+escape.cote(rsCart.value("id")) + " order by id");//order by is important here as we have to set item position in the cart which is sent to gtm
			if(rsCi.rs.Rows == 0)
			{
				Logger.info("CartHelper","Cart is empty 1");
				cart.addError(CartError.EMPTY_CART, emptyCartUrl);
			}
			else
			{
				//we have to fill this variant set first and then fill the variants info
				java.util.HashSet<String> variantSet = new java.util.HashSet<String>();
				while(rsCi.next())
				{
					Logger.info("CartHelper","Adding variant "+rsCi.value("variant_id")+" to variant set");
					variantSet.add(rsCi.value("variant_id"));			
				}			
				
				String imageFolder = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + siteId;
				String imageBaseUrl = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId;
				
				if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV")))
				{
					imageFolder = cachedResourcesFolder;
					imageBaseUrl = cachedResourcesUrl;					
				}
				
				if(imageFolder.endsWith("/") == false) imageFolder += "/";
				if(imageBaseUrl.endsWith("/") == false) imageBaseUrl += "/";
				
				String imageUrlPrefix = imageBaseUrl + "img/4x3/";
				String thumbnailUrlPrefix = imageBaseUrl + "img/thumb/";
				
				String imagePathPrefix = imageFolder + "img/4x3/";
				String thumbnailPathPrefix = imageFolder + "img/thumb/";
				
				int position = 0;
				rsCi.moveFirst();
				while(rsCi.next())
				{
					//clear delivery fee at every step as it will be set again
					Etn.executeCmd("update cart_items set delivery_fee_per_item = null where id="+escape.cote(rsCi.value("id")));
					
					CartItem cItem = new CartItem();
					cart.getItems().add(cItem);
					
					if(stockErrorItemIds.contains(PortalHelper.parseNullLong(rsCi.value("id")))) cItem.setAvailable(false);
					else cItem.setAvailable(true);
					
					for(int i=0; i<rsCi.ColName.length; i++)
					{
						cItem.addProperty(rsCi.ColName[i], rsCi.value(i));
					}
					
					int itemQty = PortalHelper.parseNullInt(cItem.getProperty("quantity"));
										
					Set rsV = Etn.execute(" select pvd.name as variant_name, pv.uuid variant_uuid,p.product_uuid,pv.price as variant_price, "+
								" pv.sku, pv.ean, pv.stock as variant_stock, pv.frequency, pv.commitment, p.*, pt.tag_id, pf.name as folder_name "+
								" from "+GlobalParm.getParm("CATALOG_DB")+".product_variants pv "+
								" inner join "+GlobalParm.getParm("CATALOG_DB")+".products p on pv.product_id = p.id "+
								" LEFT JOIN "+GlobalParm.getParm("CATALOG_DB")+".product_tags pt ON pt.product_id = p.id "+
								" LEFT JOIN "+GlobalParm.getParm("CATALOG_DB")+".products_folders pf ON p.folder_id = pf.id "+
								" left join "+GlobalParm.getParm("CATALOG_DB")+".product_variant_details pvd on pv.id = pvd.product_variant_id and pvd.langue_id="+escape.cote(cart.getLangId())+
								" where pv.id ="+escape.cote(rsCi.value("variant_id")));
					rsV.next();
					
					Set rscat = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".catalogs where id = " + escape.cote(rsV.value("catalog_id")));
					rscat.next();									
					
					ProductVariant variant = new ProductVariant();
					cItem.setVariant(variant);

					variant.setVariantId(rsCi.value("variant_id"));
					variant.setVariantUUID(rsV.value("variant_uuid"));
					variant.setVariantName(rsV.value("variant_name"));
					variant.setVariantStock(PortalHelper.parseNullLong(rsV.value("variant_stock")));
					variant.setProductId(rsV.value("id"));
					variant.setProductUUID(rsV.value("product_uuid"));
					variant.setProductName(rsV.value(prefix + "name"));					
					variant.setProductType(rsV.value("product_type"));
					variant.setBrandName(rsV.value("brand_name"));
					variant.setFolderId(rsV.value("folder_id"));
					variant.setFolderName(rsV.value("folder_name"));
					variant.setCatalogId(rsV.value("catalog_id"));
					variant.setCatalogName(rscat.value("name"));
					variant.setCatalogType(rscat.value("catalog_type"));
					variant.setSku(rsV.value("sku"));
					variant.setEan(rsV.value("ean"));
					variant.setDuration(PortalHelper.parseNullInt(rsV.value("commitment")));
					variant.setProductVersion(PortalHelper.parseNull(rsV.value("product_version")));
					//this is basically for v2 products otherwise jsonarray will always be empty
					variant.setProductCategories(PortalHelper.getProductCategories(Etn, rsV.value("id")));
					
					//by default in database frequency value is always set to month for all old products which ideally should not happen
					//whereas frequency is only applicable for specific product types ... so we put this check here otherwise calculations of cart were wrong
					if(PortalHelper.isFrequencyApplicable(rsV.value("product_type"), rsV.value("product_version")) && PortalHelper.parseNull(rsV.value("frequency")).length() > 0)
					{
						variant.setCurrencyFreq(LanguageHelper.getInstance().getTranslation(Etn, rsV.value("frequency")));
						variant.setFrequency(PortalHelper.parseNull(rsV.value("frequency")));
					}
					variant.setTagId(rsV.value("tag_id"));
										
					//For normal cart we don't allow variant price to be overwritten while adding item to cart
					//this functionality was only required in topup/card2wallet functionality
					boolean overwritePrice = false;
					if(cart.getProperty("cart_type").equalsIgnoreCase(Type.NORMAL) == false)
					{
						double overwrittenPrice = PortalHelper.parseNullDouble(cItem.getProperty("price_per_item"));
						if(overwrittenPrice > 0)//above 0 means use this price
						{
							variant.setUnformattedVariantPrice(cItem.getProperty("price_per_item"));
							overwritePrice = true;
						}
						else
						{
							variant.setUnformattedVariantPrice(rsV.value("variant_price"));
						}
					}
					else variant.setUnformattedVariantPrice(rsV.value("variant_price"));
					
					Logger.info("CartHelper","Adding variant : " + variant.getVariantId() + " variant name : " + variant.getVariantName() + " stock : " + variant.getVariantStock() + " product id : " + variant.getProductId() + " product name : " + variant.getProductName() + " overwritePrice : " + overwritePrice + " new price : " + cItem.getProperty("price_per_item") + " productVersion : " + variant.getProductVersion());

					if(variant.getProductVersion().equalsIgnoreCase("V2"))
					{
						JSONArray jImages = PortalHelper.getV2ProductVariantImages(Etn, variant.getProductId(), cart.getLangId(), variant.getVariantUUID());
						if(jImages == null)
						{
							jImages = PortalHelper.getV2ProductImage(Etn, variant.getProductId(), cart.getLangId());
						}
						
						if(jImages != null && jImages.length() > 0)
						{
							Logger.info("CartHelper", "Images : " + jImages.toString());
							JSONObject jImage = jImages.getJSONObject(0);
							variant.setImageAlt(jImage.optString("alt", ""));
							
							String imageName = jImage.getString("value");						
							String imagePath = imagePathPrefix + imageName;
							String imageUrl = imageUrlPrefix + imageName;

							String _version = PortalHelper.getImageUrlVersion(imagePath);

							variant.setImageName(imageName);
							variant.setImageUrl(imageUrl+_version);
							variant.setImagePath(imagePath);
							
							String thumbnailPath = thumbnailPathPrefix + imageName;
							String thumbnailUrl = thumbnailUrlPrefix + imageName;
							
							variant.setThumbnailUrl(thumbnailUrl+_version);
							variant.setThumbnailPath(thumbnailPath);

							Logger.info("CartHelper","Thumbnail url : " + variant.getThumbnailUrl() + " path : " + variant.getThumbnailPath());
							Logger.info("CartHelper","4x3 url : " + variant.getImageUrl() + " path : " + variant.getImagePath());
						}
						
						String productUrl = "#";
						Set rsP = Etn.execute("Select * From "+GlobalParm.getParm("PAGES_DB")+".products_map_pages where product_id = "+escape.cote(variant.getProductId()));
						if(rsP.next())
						{
							String contentId = rsP.value("page_id");
							rsP = Etn.execute("Select id From "+GlobalParm.getParm("PAGES_DB")+".pages where type = 'structured' and parent_page_id = "+escape.cote(contentId) + " and langue_code = " + escape.cote(cart.getLang()));
							if(rsP.next())
							{
								String pageId = rsP.value("id");
								rsP = Etn.execute("select cpp.published_url, cpp.file_url, c.filename from cached_pages_path cpp, cached_pages c where c.id = cpp.id and cpp.content_type = 'page' and cpp.content_id = "+escape.cote(pageId));
								if(rsP.next())
								{
									if(PortalHelper.parseNull(rsP.value("published_url")).length() > 0)
									{
										productUrl = PortalHelper.parseNull(rsP.value("published_url"));
									}
									else
									{
										productUrl = PortalHelper.parseNull(rsP.value("file_url")) + PortalHelper.parseNull(rsP.value("filename"));
									}
								}
							}
							if(productUrl.length() == 0) productUrl = "#";
						}
						variant.setProductUrl(productUrl);
						
					}
					else
					{
						String query = "";
						if(variant.getProductType().startsWith("offer_"))
						{
							query = " select image_file_name as path, image_label as label from "+GlobalParm.getParm("CATALOG_DB")+".product_images where product_id = " + escape.cote(variant.getProductId()) + " and langue_id = " + escape.cote(cart.getLangId()) + " order by sort_order limit 1; ";
						}
						else
						{
							query = "select * from "+GlobalParm.getParm("CATALOG_DB")+".product_variant_resources where type='image' and product_variant_id="+escape.cote(variant.getVariantId())+" and langue_id="+escape.cote(cart.getLangId())+" order by sort_order limit 1";
						}
						
						Set rsVariantImage = Etn.execute(query);
						if(rsVariantImage.next())
						{
							variant.setImageAlt(rsVariantImage.value("label"));
							
							String imageName = rsVariantImage.value("path");						
							String imagePath = imagePathPrefix + imageName;
							String imageUrl = imageUrlPrefix + imageName;

							String _version = PortalHelper.getImageUrlVersion(imagePath);

							variant.setImageName(imageName);
							variant.setImageUrl(imageUrl+_version);
							variant.setImagePath(imagePath);
							
							String thumbnailPath = thumbnailPathPrefix + imageName;
							String thumbnailUrl = thumbnailUrlPrefix + imageName;
							
							variant.setThumbnailUrl(thumbnailUrl+_version);
							variant.setThumbnailPath(thumbnailPath);
							
							Logger.info("CartHelper","Thumbnail url : " + variant.getThumbnailUrl() + " path : " + variant.getThumbnailPath());
							Logger.info("CartHelper","4x3 url : " + variant.getImageUrl() + " path : " + variant.getImagePath());
						}
						
						String productUrl = "#";
						Set rsUrl = Etn.execute("select * from "+GlobalParm.getParm("COMMONS_DB")+".content_urls where langue_id = "+escape.cote(langId)+" and content_type = 'product' and site_id = "+escape.cote(siteId)+" and content_id = "+escape.cote(variant.getProductId()));
						if(rsUrl.next())
						{
							productUrl = rsUrl.value("page_path").toLowerCase();
						}					
						if(productUrl.length() == 0) productUrl = "#";
						else
						{
							productUrl = menuPath + productUrl;
						}
						variant.setProductUrl(productUrl);
					}
					

					/////// TAX ///////
					//we keep overwriting and whatever flag values for last item that will get preference
					//ideally in any shop these flags will be same for all variants/products/catalog
					cart.setPriceTaxIncluded("1".equals(PortalHelper.parseNull(rscat.value("price_tax_included")))?true:false);
					cart.setShowAmountWithTax("1".equals(PortalHelper.parseNull(rscat.value("show_amount_tax_included")))?true:false);
					
					variant.setPriceTaxIncluded("1".equals(PortalHelper.parseNull(rscat.value("price_tax_included")))?true:false);
					variant.setShowAmountWithTax("1".equals(PortalHelper.parseNull(rscat.value("show_amount_tax_included")))?true:false);

					TaxPercentage taxpercentage = new TaxPercentage();
					variant.setTaxPercentage(taxpercentage);
					TaxPercentage taxpercentageWT = new TaxPercentage(); // to output without tax
					variant.setTaxPercentageWT(taxpercentageWT);
					
					taxpercentage.tax = PortalHelper.parseNullDouble(rscat.value("tax_percentage"));
					taxpercentageWT.tax = taxpercentage.tax;
					
					Logger.info("CartHelper","taxpercentage.tax:"+taxpercentage.tax);
					
					if(taxpercentage.tax > 0 && !cart.getTaxNumbers().containsKey(taxpercentage.tax+"")) cart.getTaxNumbers().put(taxpercentage.tax+"",cart.getTaxNumbers().size()+1);
					
					taxpercentage.input_with_tax = variant.isPriceTaxIncluded();
					taxpercentageWT.input_with_tax = variant.isPriceTaxIncluded();
					taxpercentage.output_with_tax = variant.isShowAmountWithTax();
					taxpercentageWT.output_with_tax = variant.isShowAmountWithTax();
					taxpercentage.tax_exclusive = false;
					taxpercentageWT.tax_exclusive = true;

					String productPriceString = CommonPrice.getPrice(Etn, variant.getVariantId(), taxpercentage, itemQty, true, clientId, variantSet, "", overwritePrice, cItem.getProperty("price_per_item"));
					String productOldPriceString = CommonPrice.getPrice(Etn, variant.getVariantId(), taxpercentage, itemQty, false, variantSet, overwritePrice, cItem.getProperty("price_per_item"));
					String productPriceStringWT = CommonPrice.getPrice(Etn, variant.getVariantId(), taxpercentageWT, itemQty, true, clientId, variantSet, "", overwritePrice, cItem.getProperty("price_per_item"));
					String productOldPriceStringWT = CommonPrice.getPrice(Etn, variant.getVariantId(), taxpercentageWT, itemQty, false, variantSet, overwritePrice, cItem.getProperty("price_per_item"));
					String dlProductPriceString = CommonPrice.getPrice(Etn, variant.getVariantId(), taxpercentage, 1, true, clientId, variantSet, "", overwritePrice, cItem.getProperty("price_per_item"));
					String dlProductPriceStringWT = CommonPrice.getPrice(Etn, variant.getVariantId(), taxpercentageWT, 1, true, clientId, variantSet, "", overwritePrice, cItem.getProperty("price_per_item"));
					
					Logger.info("CartHelper","productPriceString:" + productPriceString + " productOldPriceString:" + productOldPriceString);

					double productPrice = PortalHelper.parseNullDouble(productPriceString);
					double productOldPrice = PortalHelper.parseNullDouble(productOldPriceString);
					double productPriceWT = PortalHelper.parseNullDouble(productPriceStringWT);
					double productOldPriceWT = PortalHelper.parseNullDouble(productOldPriceStringWT);

					String formatted_price = (productPrice<=0?LanguageHelper.getInstance().getTranslation(Etn, "gratuit"):PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (variant.isShowAmountWithTax()?productPrice:productPriceWT)+""));
					String formatted_old_price = (productOldPrice<=0?LanguageHelper.getInstance().getTranslation(Etn, "gratuit"):PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (variant.isShowAmountWithTax()?productOldPrice:productOldPriceWT)+""));
					String price_value = (productPrice<=0?"0":PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (variant.isShowAmountWithTax()?productPrice:productPriceWT)+"", true));
					String dl_price_value = (productPrice<=0?"0":PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (variant.isShowAmountWithTax()?dlProductPriceString:dlProductPriceStringWT), true));
					String price_old_value = (productOldPrice<=0?"0":PortalHelper.formatPrice(priceformatter, roundto, showdecimals, (variant.isShowAmountWithTax()?productOldPrice:productOldPriceWT)+"", true));
					
					JSONArray additionalFee = CommonPrice.getAdditionalFee(Etn, request, variant.getVariantId(), cart.getLangColumnPrefix(), productOldPriceString, itemQty);
					JSONArray additionalFeeWT = CommonPrice.getAdditionalFee(Etn, request, variant.getVariantId(), cart.getLangColumnPrefix(), productOldPriceStringWT, itemQty);									
					JSONArray comewith = CommonPrice.getComewith(Etn, request, variant.getVariantId(), cart.getLangColumnPrefix(), cart.getLangId(), cItem.getProperty("comewith_excluded"), false, menuid, itemQty, cItem.getProperty("comewith_variant_id"));

					if(cItem.isAvailable())
					{
						//if(variant.hasFrequency().getProductType().equals("offer_postpaid"))
						if(variant.hasFrequency())
						{
							cart.setGrandTotalRecurring(cart.getGrandTotalRecurring()+productPrice);
							setGrandTotalRecurring(cart, variant.getFrequency(), productPrice);
							
							cart.setGrandTotalRecurringWT(cart.getGrandTotalRecurringWT() + productPriceWT);							
							setGrandTotalRecurringWT(cart, variant.getFrequency(), productPriceWT);
						}
						else
						{
							cart.setGrandTotal(cart.getGrandTotal() + productPrice);
							cart.setGrandTotalWT(cart.getGrandTotalWT() + productPriceWT);
						}

						for(int i=0; i<additionalFee.length(); i++) cart.setGrandTotal(cart.getGrandTotal() + PortalHelper.parseNullDouble(additionalFee.getJSONObject(i).getString("price")));
						for(int i=0; i<additionalFeeWT.length(); i++) cart.setGrandTotalWT( cart.getGrandTotalWT() + PortalHelper.parseNullDouble(additionalFeeWT.getJSONObject(i).getString("price")));
						
						for(int i=0; i<comewith.length(); i++)
						{
							String comewithVariantFrequency = comewith.getJSONObject(i).getJSONObject("variant").optString("frequency","");
							double comewithVariantPrice = PortalHelper.parseNullDouble(comewith.getJSONObject(i).getJSONObject("variant").optString("price"));
							double comewithVariantPriceWT = PortalHelper.parseNullDouble(comewith.getJSONObject(i).getJSONObject("variant").optString("priceWT"));
							if("offer_postpaid".equals(comewith.getJSONObject(i).getJSONObject("variant").optString("productType","")) || comewithVariantFrequency.length() > 0)
							{
								cart.setGrandTotalRecurring(cart.getGrandTotalRecurring() + comewithVariantPrice);
								setGrandTotalRecurring(cart, comewithVariantFrequency, comewithVariantPrice);
								
								cart.setGrandTotalRecurringWT(cart.getGrandTotalRecurringWT() + comewithVariantPriceWT);
								setGrandTotalRecurringWT(cart, comewithVariantFrequency, comewithVariantPriceWT);
							}
							else
							{
								cart.setGrandTotal(cart.getGrandTotal() + comewithVariantPrice);
								cart.setGrandTotalWT(cart.getGrandTotalWT() + comewithVariantPriceWT);
							}
						} 
						
					}
					
					
					JSONObject promotion = CommonPrice.getPromotion(Etn, request, variant.getVariantId(), cart.getLangColumnPrefix());							
					if(promotion.has("duration")) variant.setDiscountDuration(PortalHelper.parseNullInt(promotion.getString("duration")));
					
					variant.setProductPrice(productPrice);
					variant.setProductOldPrice(productOldPrice);
					variant.setProductPriceWT(productPriceWT);
					variant.setProductOldPriceWT(productOldPriceWT);
					variant.setFormattedPrice(formatted_price);
					variant.setFormattedOldPrice(formatted_old_price);
					variant.setPriceValue(price_value);
					variant.setUnitPrice(dl_price_value);
					variant.setPriceOldValue(price_old_value);
					variant.setAdditionalFee(additionalFee);
					variant.setAdditionalFeeWT(additionalFeeWT);
					variant.setComewith(comewith);
					variant.setPromotion(promotion);
					
					if(variant.getProductVersion().equalsIgnoreCase("V2"))
					{
						JSONArray jAttributes = PortalHelper.getV2ProductVariantAttributes(Etn, variant.getProductId(), cart.getLangId(), variant.getVariantUUID());
						if(jAttributes == null) jAttributes = new JSONArray();
						Logger.info("CartHelper", "Attributes : " + jAttributes.toString());
						variant.setAttributes(jAttributes);
					}
					else
					{
						Set rsAttributes = Etn.execute(" select ca.name, cav.attribute_value from "+GlobalParm.getParm("CATALOG_DB")+".product_variants pv inner join "+GlobalParm.getParm("CATALOG_DB")+".product_variant_ref pvr on pv.id = pvr.product_variant_id inner join "+GlobalParm.getParm("CATALOG_DB")+".catalog_attributes ca on pvr.cat_attrib_id = ca.cat_attrib_id inner join "+GlobalParm.getParm("CATALOG_DB")+".catalog_attribute_values cav on pvr.catalog_attribute_value_id = cav.id where pv.id ="+escape.cote(variant.getVariantId()));
						JSONArray attributes = new JSONArray();
						while(rsAttributes.next()){
							JSONObject attribute = new JSONObject();
							attribute.put("name", rsAttributes.value(0));
							attribute.put("value", rsAttributes.value(1));
							//for v2 product attributes we have label field as well which has the text value of attribute in it
							//so we set this for v1 products also to keep things consistent and it will be easier to show attributes in emails as well
							attribute.put("label", rsAttributes.value(1));
							attributes.put(attribute);
						}	
						variant.setAttributes(attributes);
					}
					
					cItem.setPosition(position);
					position++;
				}//end while
				
				//this was done for OBW where they want their scratch cards to be used as promo codes in asimina
				//factory design pattern is used for this. By default we do nothing
				//OBW implementation will load voucher code from external API and then will add that to asimina in cart rules so that rest of the code works
				if(reloadVoucher)
				{
					VoucherFactory vf = new VoucherFactory(voucherApiImplementationClass);
					VoucherLoader vl = vf.getVoucherLoader();					
					boolean bool = vl.loadVoucher(Etn, request, cart.getProperty("site_id"), PortalHelper.parseNull(cart.getProperty("promo_code")));
				}
				
				//apply cart rules 
				applyCartRules(Etn, request, cart);
			}
		}
		else
		{				
			Logger.error("CartHelper","Cart is empty 2");
			cart.addError(CartError.EMPTY_CART, emptyCartUrl);
		}
		return cart;
	}	
	
	private static void setGrandTotalRecurring(Cart cart, String frequency, double amount) throws Exception
	{
		Map<String, Double> _map = cart.getGrandTotalRecurringMap();
		if(_map == null)
		{
			_map = new HashMap<>();
			cart.setGrandTotalRecurringMap(_map);
		}
		if(_map.get(frequency) == null) _map.put(frequency, 0d);
		double _d = _map.get(frequency);
		_d = _d + amount;
		_map.put(frequency, _d);	
	}
	
	private static void setGrandTotalRecurringWT(Cart cart, String frequency, double amount) throws Exception
	{
		Map<String, Double> _map = cart.getGrandTotalRecurringWTMap();
		if(_map == null)
		{
			_map = new HashMap<>();
			cart.setGrandTotalRecurringWTMap(_map);
		}
		if(_map.get(frequency) == null) _map.put(frequency, 0d);
		double _d = _map.get(frequency);
		_d = _d + amount;
		_map.put(frequency, _d);	
	}
	
	private static void applyCartRules(Contexte Etn, HttpServletRequest request, Cart cart) throws Exception
	{
		Logger.info("CartHelper", "In applyCartRules");
		String siteId = cart.getProperty("site_id");
		String cartSessionId = cart.getProperty("session_id");
		String deliveryMethod = cart.getProperty("delivery_method");
		String deliveryType = cart.getProperty("delivery_type");
		String paymentMethod = cart.getProperty("payment_method");

		String paymentDisplayName = "";
		double paymentFees = 0;

		Set rsPaymentMethods = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".payment_methods where site_id =  "+escape.cote(siteId) + " and method="+escape.cote(paymentMethod));
		if(rsPaymentMethods.next())
		{
			paymentDisplayName = rsPaymentMethods.value("displayName");
			paymentFees = PortalHelper.parseNullDouble(rsPaymentMethods.value("price"));
		}
				
		double shippingFees = 0;
		double defaultShippingFees = 0;
		String deliveryDisplayName = "";
		String shippingFeeStr = "";//this might contain word no-show in which case we dont show the shipping fee in recap
		
		if(deliveryMethod.length()>0)
		{
			Set rsDeliveryPrice = Etn.execute("select price, displayName from "+GlobalParm.getParm("CATALOG_DB")+".delivery_methods where site_id = " + escape.cote(siteId) + " and subType = " + escape.cote(deliveryType) + " and method="+escape.cote(deliveryMethod));
			if(rsDeliveryPrice.next())
			{
				defaultShippingFees = PortalHelper.parseNullDouble(rsDeliveryPrice.value(0));
				shippingFeeStr = rsDeliveryPrice.value(0);
				deliveryDisplayName = rsDeliveryPrice.value(1);
				shippingFees = getDeliveryFee(Etn, request, cart, defaultShippingFees);
			} 
		}
		
		//----------------
		double grandTotal = cart.getGrandTotal();
		double grandTotalWT = cart.getGrandTotalWT();
		double grandTotalRecurring = cart.getGrandTotalRecurring();
		double grandTotalRecurringWT = cart.getGrandTotalRecurringWT();
		boolean showamountwithtax = cart.isShowAmountWithTax();
		String prefix = cart.getLangColumnPrefix();
		
		String promoCode = cart.getProperty("promo_code");
		
        double totalTax = (grandTotal - grandTotalWT);
        double totalTaxRecurring = (grandTotalRecurring - grandTotalRecurringWT);
		
		double totalCartDiscount = 0;
		double totalShippingDiscount = 0;
		boolean promoApplied = false;
		String promoAppliedType = "";
		double promoValue = 0;
		JSONObject cartRulesObj = getCartRules(Etn, request, cart, (showamountwithtax?grandTotal:grandTotalWT));		
		JSONArray cartRules = cartRulesObj.getJSONArray("cartRules");
		JSONArray calculatedCartDiscounts = new JSONArray();
		boolean skipRule = cartRulesObj.getBoolean("skipRule");
		
		double grandTotalAfterDiscount = grandTotal;
		double grandTotalWTAfterDiscount = grandTotalWT;
		String promoError = "";
		
		if(skipRule == false)//this will be true when no delivery or payment method is yet selected and rule is applicable on them .. so it will be true once customer has selected the delivery/payment methods
		{
			Map<String, Double> cartItemPriceAfterDiscount = new HashMap<>();
			Map<String, Double> comewithPriceAfterDiscount = new HashMap<>();
			for(int i=0; i<cartRules.length(); i++)
			{			
				String cartRuleDiscountType = cartRules.getJSONObject(i).getString("discount_type");
				String cartRuleDiscountValue = cartRules.getJSONObject(i).getString("discount_value");
				String cartRuleElementOn = cartRules.getJSONObject(i).getString("element_on");
				JSONArray jCartRuleElementsOn = cartRules.getJSONObject(i).getJSONArray("on_elements");
				String ruleAppliedOn = "";
				double discountValue = 0;
				double originalRuleValue = 0;
				boolean cartRuleApplicable = false;
				int discountCount = 0;		
				
				if(cartRuleElementOn.equals("cart_total"))
				{
					if(cartRuleDiscountType.equals("fixed")) 
					{
						originalRuleValue = PortalHelper.parseNullDouble(cartRuleDiscountValue);
						discountValue = PortalHelper.parseNullDouble(cartRuleDiscountValue);
						if(discountValue > (showamountwithtax?grandTotalAfterDiscount:grandTotalWTAfterDiscount)) discountValue = (showamountwithtax?grandTotalAfterDiscount:grandTotalWTAfterDiscount);
					}
					else 
					{
						double percentDiscount = ((showamountwithtax?grandTotalAfterDiscount:grandTotalWTAfterDiscount) * PortalHelper.parseNullDouble(cartRuleDiscountValue)/100);
						discountValue = percentDiscount;
						originalRuleValue = percentDiscount;
					}			
				
					discountValue = PortalHelper.parseNullDouble(PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), discountValue+"", true));
					
					totalCartDiscount += discountValue;
					cartRuleApplicable = true;
					discountCount++;
					
					grandTotalAfterDiscount = grandTotalAfterDiscount - discountValue;
					grandTotalWTAfterDiscount = grandTotalWTAfterDiscount - discountValue;				
				}
				else if(cartRuleElementOn.equals("shipping_fee"))
				{
					if(cartRuleDiscountType.equals("fixed")) 
					{
						originalRuleValue = PortalHelper.parseNullDouble(cartRuleDiscountValue);
						discountValue = PortalHelper.parseNullDouble(cartRuleDiscountValue);
						if(discountValue > shippingFees) discountValue = shippingFees;
					}
					else 
					{
						double percentDiscount = (shippingFees * PortalHelper.parseNullDouble(cartRuleDiscountValue)/100);
						discountValue = percentDiscount;
						originalRuleValue = percentDiscount;
					}
					
					discountValue = PortalHelper.parseNullDouble(PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), discountValue+"", true));
					
					totalShippingDiscount += discountValue;
					cartRuleApplicable = true;
					discountCount++;
				}
				else
				{
					double dCartRuleDiscountValue = PortalHelper.parseNullDouble(cartRuleDiscountValue);
					for(int j=0; j<cart.getItems().size(); j++)
					{
						if(cartRuleDiscountType.equals("fixed")) 
						{
							Logger.info("CartHelper", "Remaining discount value is : " + dCartRuleDiscountValue);
						}
						CartItem ci = cart.getItems().get(j);
						int ciQty = PortalHelper.parseNullInt(ci.getProperty("quantity"));
						ProductVariant variant = ci.getVariant();
						
						if(cartItemPriceAfterDiscount.get(ci.getProperty("id")) == null)
						{
							cartItemPriceAfterDiscount.put(ci.getProperty("id"), PortalHelper.parseNullDouble(variant.getPriceValue()));
						}
						
						JSONObject jElementOn = getCartRuleElementOn(jCartRuleElementsOn, variant.getProductId(), variant.getSku());
						if(jElementOn != null)//ideally this can never be null otherwise there is some issue
						{			
							double currentDiscountValue = 0;
							cartRuleElementOn = PortalHelper.parseNull(jElementOn.getString("on"));

							if(cartRuleElementOn.equals("product"))
							{
								ruleAppliedOn = variant.getProductName();
							}
							else
							{
								ruleAppliedOn = "sku:"+variant.getSku();
							}
							cartRuleApplicable = true;
							if(cartRuleDiscountType.equals("fixed")) 
							{
								double variantPrice = cartItemPriceAfterDiscount.get(ci.getProperty("id"));
								Logger.info("CartHelper", "Cart item : " + ci.getProperty("id") + " product : " + variant.getProductName() + " price after other cart rules : " + variantPrice);
								originalRuleValue += dCartRuleDiscountValue;
								if(dCartRuleDiscountValue > variantPrice) 
								{
									currentDiscountValue = variantPrice;
									discountValue += variantPrice;
									
									dCartRuleDiscountValue = dCartRuleDiscountValue - variantPrice;
								}
								else
								{
									currentDiscountValue = dCartRuleDiscountValue;
									discountValue += dCartRuleDiscountValue;
									
									dCartRuleDiscountValue = 0;
								}
							}
							else 
							{
								double percentDiscount = (PortalHelper.parseNullDouble(variant.getUnitPrice()) * PortalHelper.parseNullDouble(cartRuleDiscountValue)/100) * ciQty;
								currentDiscountValue = percentDiscount;
								discountValue += percentDiscount;
								originalRuleValue += percentDiscount;							
							}
							discountCount++;
							
							cartItemPriceAfterDiscount.put(ci.getProperty("id"), cartItemPriceAfterDiscount.get(ci.getProperty("id")) - currentDiscountValue);
						}
													
						//check comewiths for this cart item
						JSONArray comewith = CommonPrice.getComewith(Etn, request, ci.getVariant().getVariantId(), 
									cart.getLangColumnPrefix(), cart.getLangId(), ci.getProperty("comewith_excluded"), 
									false, cart.getMenuId(), ciQty, ci.getProperty("comewith_variant_id"));
						if(comewith != null && comewith.length() > 0)
						{
							Logger.info("CartHelper", "item has comewiths");
							for(int k=0; k<comewith.length(); k++)
							{												
								jElementOn = getCartRuleElementOn(jCartRuleElementsOn, comewith.getJSONObject(k).optString("product_id"), comewith.getJSONObject(k).optString("sku"));
								if(jElementOn != null)//ideally this can never be null otherwise there is some issue
								{	
									double currentDiscountValue = 0;
								
									cartRuleElementOn = PortalHelper.parseNull(jElementOn.getString("on"));

									if(cartRuleElementOn.equals("product"))
									{
										ruleAppliedOn = comewith.getJSONObject(k).optString("productName");
									}
									else
									{
										ruleAppliedOn = "sku:"+comewith.getJSONObject(k).optString("sku");
									}
									
									JSONObject jVariant = comewith.getJSONObject(k).getJSONObject("variant");								
									
									//same variant can be as a comewith with some other product so we must append cart item id here to keep it unique
									if(comewithPriceAfterDiscount.get(ci.getProperty("id") + ":"+ comewith.getJSONObject(k).getString("variant_id")) == null)
									{
										comewithPriceAfterDiscount.put(ci.getProperty("id") + ":"+ comewith.getJSONObject(k).getString("variant_id"), PortalHelper.parseNullDouble(variant.getPriceValue()));
									}
									
									cartRuleApplicable = true;
									if(cartRuleDiscountType.equals("fixed")) 
									{
										//double variantPrice = PortalHelper.parseNullDouble(jVariant.optString("price","0"));
										double variantPrice = comewithPriceAfterDiscount.get(ci.getProperty("id") + ":"+ comewith.getJSONObject(k).getString("variant_id"));
										Logger.info("CartHelper", "Comewith variant id : " + comewith.getJSONObject(k).getString("variant_id") + " product : " + comewith.getJSONObject(k).optString("productName") + " price after other cart rules : " + variantPrice);
										if(comewith.getJSONObject(k).getBoolean("show_amount_with_tax") == false) variantPrice = PortalHelper.parseNullDouble(jVariant.optString("priceWT","0"));
										
										originalRuleValue += dCartRuleDiscountValue;
										if(dCartRuleDiscountValue > variantPrice) 
										{
											currentDiscountValue = variantPrice;
											discountValue += variantPrice;
											
											dCartRuleDiscountValue = dCartRuleDiscountValue - variantPrice;
										}
										else
										{
											currentDiscountValue = dCartRuleDiscountValue;
											discountValue += dCartRuleDiscountValue;
											
											dCartRuleDiscountValue = 0;
										}
									}
									else 
									{
										double unitPrice = PortalHelper.parseNullDouble(jVariant.optString("unit_price","0"));
										if(comewith.getJSONObject(k).getBoolean("show_amount_with_tax") == false) unitPrice = PortalHelper.parseNullDouble(jVariant.optString("unit_price_wt","0"));
										
										double percentDiscount = (unitPrice * PortalHelper.parseNullDouble(cartRuleDiscountValue)/100) * ciQty;
										currentDiscountValue = percentDiscount;
										discountValue += percentDiscount;
										originalRuleValue += percentDiscount;							
									}
									discountCount++;
									
									comewithPriceAfterDiscount.put(ci.getProperty("id") + ":"+ comewith.getJSONObject(k).getString("variant_id"), comewithPriceAfterDiscount.get(ci.getProperty("id") + ":"+ comewith.getJSONObject(k).getString("variant_id")) - currentDiscountValue);
								}// if jElementOn != null 
							} 
						}
					}
			
					discountValue = PortalHelper.parseNullDouble(PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), discountValue+"", true));
					
					totalCartDiscount += discountValue;

					grandTotalAfterDiscount = grandTotalAfterDiscount - discountValue;
					grandTotalWTAfterDiscount = grandTotalWTAfterDiscount - discountValue;
							
				}

				String cartRuleCouponCode = cartRules.getJSONObject(i).getString("coupon_code");
				if(cartRuleCouponCode.length()>0)
				{
					promoValue = discountValue;
					promoApplied = true;
					promoAppliedType = cartRuleElementOn;
				} 
				
				if(grandTotalAfterDiscount < 0) grandTotalAfterDiscount = 0;
				if(grandTotalWTAfterDiscount < 0) grandTotalWTAfterDiscount = 0;
				
				if(cartRuleApplicable)
				{
					JSONObject tempDiscountObject = new JSONObject();
					tempDiscountObject.put("ruleAppliedOn",ruleAppliedOn);
					tempDiscountObject.put("discountType",cartRuleDiscountType);
					tempDiscountObject.put("originalRuleValue",PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), originalRuleValue+"", true));
					tempDiscountObject.put("rulesCount",discountCount);
					tempDiscountObject.put("elementOn",cartRuleElementOn);
					tempDiscountObject.put("couponCode",cartRuleCouponCode);
					tempDiscountObject.put("discountValue", discountValue);
					
					calculatedCartDiscounts.put(tempDiscountObject);
				}
			}
						
			if(promoApplied == false && promoCode.length()>0)
			{
				promoError = PortalHelper.parseNull(cartRulesObj.optString("promoErrorMsg"));
				//if the coupon failed due to some cart rule like coupon defined for logged user, or for some specific dates or specific amount or specific product
				//then promoError will be set already ... otherwise it means coupon is just no valid so we give default message here
				if(promoError.length() == 0) promoError = LanguageHelper.getInstance().getTranslation(Etn, "Invalid promo");
			}
		}
		shippingFees -= totalShippingDiscount;
		if(shippingFees<0) shippingFees = 0;

		if(showamountwithtax)
		{
			if(grandTotal > 0)
			{
				grandTotalWT = ((grandTotal - totalCartDiscount) * grandTotalWT / grandTotal);
				totalTax = (grandTotal - totalCartDiscount) * totalTax / grandTotal;
				grandTotal = (grandTotal - totalCartDiscount);
			}
		}
		else
		{
			if(grandTotalWT > 0)
			{
				grandTotal = ((grandTotalWT - totalCartDiscount) * grandTotal / grandTotalWT);
				totalTax = (grandTotalWT - totalCartDiscount) * totalTax / grandTotalWT;
				grandTotalWT = (grandTotalWT - totalCartDiscount);
			}
		}
		if(grandTotal<0)
		{
			grandTotal = totalTax = grandTotalWT = 0;
		} 
		
		String deliveryError = "";
		if(deliveryMethod.equals("home_delivery"))
		{
			deliveryError = getDeliveryError(Etn, request, cart, (showamountwithtax?grandTotal:grandTotalWT));                        
		}
		grandTotal += shippingFees + paymentFees;
		grandTotalWT += shippingFees + paymentFees;	
		
		cart.setPaymentDisplayName(paymentDisplayName);
		cart.setPaymentFees(paymentFees);
		cart.setShippingFees(shippingFees);
		cart.setShippingFeeStr(shippingFeeStr);
		cart.setDefaultShippingFees(defaultShippingFees);
		cart.setDeliveryDisplayName(deliveryDisplayName);
		cart.setGrandTotal(grandTotal);
		cart.setGrandTotalWT(grandTotalWT);
		cart.setGrandTotalRecurring(grandTotalRecurring);
		cart.setGrandTotalRecurringWT(grandTotalRecurringWT);
		cart.setTotalTax(totalTax);
		cart.setTotalTaxRecurring(totalTaxRecurring);
		cart.setTotalCartDiscount(totalCartDiscount);
		cart.setTotalShippingDiscount(totalShippingDiscount);
		cart.setPromoApplied(promoApplied);
		cart.setPromoAppliedType(promoAppliedType);
		cart.setPromoValue(promoValue);
		cart.setCalculatedCartDiscounts(calculatedCartDiscounts);
		
		if(PortalHelper.parseNull(promoError).length() > 0)
		{
			Logger.error("CartHelper","Promo error " + promoError);
			cart.addError(CartError.PROMO_ERROR, promoError, null);
		}
		if(PortalHelper.parseNull(deliveryError).length() > 0)
		{
			Logger.error("CartHelper","Delivery error "+deliveryError);
			cart.addError(CartError.DELIVERY_ERROR, deliveryError, null);
		}
	}
	
	private static JSONObject getCartRuleElementOn(JSONArray jElementsOn, String productId, String sku) throws Exception
	{
		Logger.info("CartHelper", "in getCartRuleElementOn");
		for(int i=0; i<jElementsOn.length(); i++)
		{
			JSONObject jElementOn = jElementsOn.getJSONObject(i);
			String on = PortalHelper.parseNull(jElementOn.getString("on"));
			String value = PortalHelper.parseNull(jElementOn.getString("value"));
			
			if("product".equals(on) && productId.equals(value))
			{
				Logger.info("CartHelper", "returning : " + jElementOn.toString());
				return jElementOn;
			}
			else if(sku.equals(value))
			{
				Logger.info("CartHelper", "returning : " + jElementOn.toString());
				return jElementOn;
			}
		}
		//this is not possible case ideally
		Logger.error("CartHelper", "returning null .. ideally this is not possible. code logic must be checked");
		return null;
	}
	
	private static Map<String, Object> validateStock(Contexte Etn, HttpServletRequest request, String sessionId, String siteId, boolean allowMultipleCatalogsCheckout) throws Exception
	{
		Logger.info("CartHelper", "In validateStock");		
		List<Long> errorIds = new ArrayList<Long>();
		Set rsCartItem = Etn.execute("select ci.* from cart c inner join cart_items ci on c.id = ci.cart_id where session_id="+escape.cote(sessionId)+" and site_id="+escape.cote(siteId) + " order by ci.id ");
		int cartCount = 0;
		int articlesCount = 0;
		String currentCatalogId = "";
		HashMap<String, Integer> stockMap = new HashMap<String, Integer>();
		while(rsCartItem.next())
		{
			long cartItemId = PortalHelper.parseNullLong(rsCartItem.value("id"));
			String variant_id = rsCartItem.value("variant_id");
			int qty = PortalHelper.parseNullInt(rsCartItem.value("quantity"));

			Set rs = Etn.execute(" select pv.*, p.product_type, p.catalog_id from "+GlobalParm.getParm("CATALOG_DB")+".product_variants pv inner join "+GlobalParm.getParm("CATALOG_DB")+".products p on pv.product_id = p.id where pv.id ="+escape.cote(variant_id));
			
			if(rs.next())
			{
				if(allowMultipleCatalogsCheckout == false && currentCatalogId.length()>0 && !currentCatalogId.equals(rs.value("catalog_id"))) errorIds.add(cartItemId);
				else
				{
					//if(rs.value("product_type").startsWith("offer_") || "simple_virtual_product".equals(rs.value("product_type")) || "configurable_virtual_product".equals(rs.value("product_type")))
					if(PortalHelper.isOffer(rs.value("product_type")))
					{
						if(rs.value("is_show_price").equals("0")) 
						{
							errorIds.add(cartItemId);
						}
						else articlesCount+= qty;
					} 
					else if(rs.value("product_type").equals("service_day")){

					}
					else if(rs.value("product_type").equals("service_night")){

					}
					else if(rs.value("product_type").equals("service")){

					}
					else if(rs.value("product_type").equals("pack_prepaid")||rs.value("product_type").equals("pack_postpaid")){

					}
					else
					{ //if(rs.value("product_type").equals("product"))
						int stock = PortalHelper.parseNullInt(rs.value("stock"));
						if(stockMap.containsKey(variant_id)){
							stock = stockMap.get(variant_id);
						}
						else{
							//stockMap.put(variant_id, stock);
						}
						stock -= qty;
						
						if(stock<0 || rs.value("is_show_price").equals("0")) {
							errorIds.add(cartItemId);
						}
						else articlesCount+= qty;
						
						stockMap.put(variant_id, stock);

						JSONArray comewith = CommonPrice.getComewith(Etn, request, variant_id, "lang_1_", "1", rsCartItem.value("comewith_excluded"), false, "", qty, rsCartItem.value("comewith_variant_id")); // sending lang 1 because we are not concered with product names here, we just need comewiths stock
						for(int i=0; i<comewith.length(); i++)
						{
							if("label".equals(comewith.getJSONObject(i).optString("comewith"))) continue;

							JSONObject comewithVariant = comewith.getJSONObject(i).getJSONObject("variant");
							if(comewithVariant.optString("isShowPrice").equals("0"))
							{
								errorIds.add(cartItemId);
							}
							//else if(comewithVariant.optString("productType").startsWith("offer_") || "simple_virtual_product".equals(comewithVariant.optString("productType")) || "configurable_virtual_product".equals(comewithVariant.optString("productType")))
							else if(PortalHelper.isOffer(comewithVariant.optString("productType")))
							{
								continue;
							}
							stock = PortalHelper.parseNullInt(comewithVariant.optString("variantStock"));
							if(stockMap.containsKey(comewith.getJSONObject(i).optString("variant_id"))){
								stock = stockMap.get(comewith.getJSONObject(i).optString("variant_id"));
							}
							stock -= qty;
							if(stock<0) {
								errorIds.add(cartItemId);
							}
							stockMap.put(comewith.getJSONObject(i).optString("variant_id"), stock);
							
						} 
						
					}
					currentCatalogId = rs.value("catalog_id");
				}
			}
			cartCount++;
		}	
		
		Map<String, Object> obj = new HashMap<String, Object>();
		obj.put("errors", errorIds);
		obj.put("cartCount", cartCount);
		obj.put("articlesCount", articlesCount);
		
		return obj;
	}

    private static String getDeliveryError(Contexte Etn, HttpServletRequest request, Cart cart, double totalAmount)
	{
		Logger.info("CartHelper", "In getDeliveryError");		
		
        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");

        boolean logged = ClientSession.getInstance().isClientLoggedIn(Etn, request);
		
		LanguageHelper languageHelper = LanguageHelper.getInstance();

		int totalQty = 0;
		for(CartItem item : cart.getItems())
		{
			totalQty += PortalHelper.parseNullInt(item.getProperty("quantity"));
		}

		String currencycode = PortalHelper.parseNull(cart.getCurrencyCode());
		String currency = languageHelper.getTranslation(Etn, PortalHelper.parseNull(cart.getDefaultCurrency()));
		
		String deliveryMinQuery = "select * from "+catalogdb+".deliverymins ";
		deliveryMinQuery += " where site_id = "+escape.cote(PortalHelper.parseNull(cart.getProperty("site_id")));		
		if(logged == false) deliveryMinQuery += " and visible_to <> 'logged' ";//not logged so ignore logged variants here
		deliveryMinQuery += " and (dep_type='all' or dep_type='city' and dep_value="+escape.cote(PortalHelper.parseNull(cart.getProperty("datowncity")));
		deliveryMinQuery += " or dep_type='daline2' and dep_value="+escape.cote(PortalHelper.parseNull(cart.getProperty("daline2")));
		deliveryMinQuery += " or dep_type='postal' and "+escape.cote(PortalHelper.parseNull(cart.getProperty("dapostalCode")))+" like concat(dep_value,'%'))";
		deliveryMinQuery += " order by order_seq limit 1";
		
		Set rsDeliveryMin = Etn.execute(deliveryMinQuery);
		if(rsDeliveryMin.next())
		{
			if(rsDeliveryMin.value("criteria_type").equals("minimum"))
			{
				if(rsDeliveryMin.value("minimum_type").equals("quantity"))
				{
					if(totalQty >= PortalHelper.parseNullDouble(rsDeliveryMin.value("minimum_total"))) return "";
					else return languageHelper.getTranslation(Etn, "Le quantité minimum pour votre commande pour cette adresse de livraison doit être: ")+rsDeliveryMin.value("minimum_total");
				}
				else
				{
					if(totalAmount >= PortalHelper.parseNullDouble(rsDeliveryMin.value("minimum_total"))) return "";
					else return languageHelper.getTranslation(Etn, "Le montant minimum pour votre commande pour cette adresse de livraison doit être: ")+rsDeliveryMin.value("minimum_total")+" "+currency;
				}
			}
			else
			{
				if(rsDeliveryMin.value("minimum_type").equals("quantity"))
				{
					if(totalQty <= PortalHelper.parseNullDouble(rsDeliveryMin.value("minimum_total"))) return "";
					else return languageHelper.getTranslation(Etn, "Le quantité maximum pour votre commande pour cette adresse de livraison doit être: ")+rsDeliveryMin.value("minimum_total");
				}
				else
				{
					if(totalAmount <= PortalHelper.parseNullDouble(rsDeliveryMin.value("minimum_total"))) return "";
					else return languageHelper.getTranslation(Etn, "Le montant maximum pour votre commande pour cette adresse de livraison doit être: ")+rsDeliveryMin.value("minimum_total")+" "+currency;
				}
			}

		}
		else
		{
			//if no minimum quantity found for datown/dapostalcode then we check if delivery outside department if not allowed means
			//incoming datown/dapostalcode delivery is not allowed
			if(cart.isAllowDeliverOutsideDep()) return "";
			else return PortalHelper.parseNull(cart.getDeliverOutsideDepErrorMsg())+"&nbsp;";
		}
    }	
	
    private static double getDeliveryFee(Contexte Etn, HttpServletRequest request, Cart cart, double defaultFee)
	{
		return getDeliveryFee(Etn, request, cart.getItems(), cart.getProperty("site_id"), cart.getProperty("delivery_method"), cart.getProperty("datowncity"), cart.getProperty("dapostalCode"), cart.getProperty("daline1"), cart.getProperty("daline2"), defaultFee, true, cart.getProperty("delivery_type"));
	}
	
	/*
	* This function can be called for calculating the delivery fees for display purposes only
	* The case is we land on delivery screen for first time and we have to show default deliv fee depending on the address entered
	* by user in personal info screen. Till then we have no delivery method, datowncity, dapostalCode, daline1 and daline2 filled in the db	
	* We pass updateDb = false here as we just want to do calculate the delivery fee and not update anything in the db
	*/
    public static double getDeliveryFee(Contexte Etn, HttpServletRequest request, List<CartItem> items, String siteId, String deliveryMethod, String deliverySubType, String datowncity, String dapostalCode, String daline1, String daline2)
	{
		double defaultFee = 0;
		
		if(PortalHelper.parseNull(deliveryMethod).length() > 0)
		{
			//As the purpose of this function is to calculate delivery fee without even the user reaching the delivery step in checkout flow, 
			//we might get the deliverySubType empty in which case we will always show the minimum price of provided delivery method.
			//Note:One delivery method can have different sub-types which can have different fee
			String qry = "select price, displayName, subType from "+GlobalParm.getParm("CATALOG_DB")+".delivery_methods "+
						" where site_id = " + escape.cote(siteId) + " and enable=1 and method="+escape.cote(deliveryMethod);
			if(PortalHelper.parseNull(deliverySubType).length() > 0 ) qry += " and subType = " + escape.cote(PortalHelper.parseNull(deliverySubType));
			qry += " order by price, orderSeq ";

			Set rsDeliveryPrice = Etn.execute(qry);
			if(rsDeliveryPrice.next())
			{
				defaultFee = PortalHelper.parseNullDouble(rsDeliveryPrice.value("price"));
				//if no delivery sub type is passed we will use the min price subtype for delivery fee calculations
				deliverySubType = PortalHelper.parseNull(rsDeliveryPrice.value("subType"));
			}
		}
		return getDeliveryFee(Etn, request, items, PortalHelper.parseNull(siteId), PortalHelper.parseNull(deliveryMethod), PortalHelper.parseNull(datowncity), PortalHelper.parseNull(dapostalCode), PortalHelper.parseNull(daline1), PortalHelper.parseNull(daline2), defaultFee, false, deliverySubType);
	}
	
	/*
	* This function is called by the public getDeliveryFee method which actually can be called at outside the checkout flow
	* So if you have to update anything in the db in this function, use the flag updateDb.
	*/
    private static double getDeliveryFee(Contexte Etn, HttpServletRequest request, List<CartItem> items, String siteId, String deliveryMethod, String datowncity, String dapostalCode, String daline1, String daline2, double defaultFee, boolean updateDb, String deliverySubType)
	{
		Logger.info("CartHelper", "In getDeliveryFee");		
		
		if("home_delivery".equals(deliveryMethod) == false) return defaultFee;
		
        HashSet<String> deliveryFeeIds = new HashSet<String>();
        double deliveryFee = 0;

        boolean logged = ClientSession.getInstance().isClientLoggedIn(Etn, request);

		for(CartItem item : items)
		{
			//no delivery fee applicable on offers
			if(item.isOffer()) continue;
			int quantity = PortalHelper.parseNullInt(item.getProperty("quantity"));
			ProductVariant variant = item.getVariant();

			String qry = getDeliveryFeeQuery(variant, siteId, datowncity, dapostalCode, daline1, daline2, logged, deliverySubType);
            Set rsDeliveryFee = Etn.execute(qry);
            if(rsDeliveryFee.next())
			{
                if(rsDeliveryFee.value("applicable_per_item").equals("1"))
				{
                    deliveryFee += PortalHelper.parseNullDouble(rsDeliveryFee.value("fee"))*quantity;
                    if(updateDb) Etn.executeCmd("update cart_items set delivery_fee_per_item = "+escape.cote(rsDeliveryFee.value("fee"))+" where id="+escape.cote(item.getProperty("id")));
                }
                else if(!deliveryFeeIds.contains(rsDeliveryFee.value("id")))
				{
                    deliveryFeeIds.add(rsDeliveryFee.value("id"));
                    deliveryFee += PortalHelper.parseNullDouble(rsDeliveryFee.value("fee"));
                }
            }
            else
			{
                if(!deliveryFeeIds.contains("0"))
				{
                    deliveryFeeIds.add("0");
                    deliveryFee += defaultFee;
                }
            }
        }
        return deliveryFee;
    }
	
	private static String getDeliveryFeeQuery(ProductVariant variant, String siteId, String datowncity, String dapostalCode, String daline1, String daline2, boolean logged, String deliverySubType)
	{
		String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");

		String deliveryFeeQuery = "select d.* from "+catalogdb+".deliveryfees d inner join "+catalogdb+".deliveryfees_rules dr on d.id=dr.deliveryfee_id";
		deliveryFeeQuery += " and ((dr.applied_to_type='product' and dr.applied_to_value="+escape.cote(PortalHelper.parseNull(variant.getProductId()))+")";
		deliveryFeeQuery += " or (dr.applied_to_type='catalog' and dr.applied_to_value="+escape.cote(PortalHelper.parseNull(variant.getCatalogId()))+")";
		deliveryFeeQuery += " or (dr.applied_to_type='sku' and dr.applied_to_value="+escape.cote(PortalHelper.parseNull(variant.getSku()))+")";
		deliveryFeeQuery += " or (dr.applied_to_type='product_type' and dr.applied_to_value="+escape.cote(PortalHelper.parseNull(variant.getCatalogType()))+")";
		deliveryFeeQuery += " or (dr.applied_to_type='manufacturer' and dr.applied_to_value="+escape.cote(PortalHelper.parseNull(variant.getBrandName()))+")";
		deliveryFeeQuery += " or (dr.applied_to_type='tag' and dr.applied_to_value=" + escape.cote(PortalHelper.parseNull(variant.getTagId())) + ") or dr.applied_to_type='all')";
		deliveryFeeQuery += " where d.site_id = "+escape.cote(PortalHelper.parseNull(siteId));
		if(logged == false) deliveryFeeQuery += " and d.visible_to <> 'logged' ";//not logged so ignore logged variants here
		deliveryFeeQuery += " and coalesce(d.delivery_type,'') = "+escape.cote(PortalHelper.parseNull(deliverySubType));
		deliveryFeeQuery += " and (d.dep_type='all' or d.dep_type='city' and d.dep_value="+escape.cote(PortalHelper.parseNull(datowncity));
		deliveryFeeQuery += " or d.dep_type='daline2' and d.dep_value="+escape.cote(PortalHelper.parseNull(daline2));
		deliveryFeeQuery += " or d.dep_type='postal' and "+escape.cote(PortalHelper.parseNull(dapostalCode))+" like concat(d.dep_value,'%'))";
		deliveryFeeQuery += " group by dr.deliveryfee_id order by d.order_seq";		

		return deliveryFeeQuery;
	}
	
	/**
	* Do not update anything in db in this function otherwise you have to call loadCart again if that change can effect the cart object/calculations
	* This function is returning list of delivery rules associating cart item ID to each on which that delivery rule is applicable
	* If any item has no applicable delivery rule that goes with 0 object which means 0 object items have no per item delivery fee
	* We could have added a property of delivery per item to CartItem pojo but requirement was on the UI we have to show same delivery rule items together
	* which can be at different indexes in cart.getItems() list ... so this function solves that issue
	*/
    public static JSONObject getDeliveryFeeIndexes(Contexte Etn, HttpServletRequest request, Cart cart, double defaultFee) throws Exception
	{
        JSONObject deliveryFeeIndexes = new JSONObject();
		
		if(PortalHelper.parseNull(cart.getProperty("delivery_method")).equals("home_delivery") == false)
		{
			//add all items to 0 key for getRecap.jsp
			if(deliveryFeeIndexes.has("0") == false)
			{
				JSONObject tempObject = new JSONObject();
				tempObject.put("applicable_per_item","0");
				tempObject.put("fee",defaultFee);
				JSONArray tempArray = new JSONArray();
				
				for(int i=0; i<cart.getItems().size(); i++)
				{
					tempArray.put(i);
				}
				
                tempObject.put("indexes",tempArray);
                deliveryFeeIndexes.put("0",tempObject);				
			}
			return deliveryFeeIndexes;
		}

        boolean logged = ClientSession.getInstance().isClientLoggedIn(Etn, request);

        int cartIndex = 0;
		for(CartItem item : cart.getItems())
		{        
			ProductVariant variant = item.getVariant();
			
            JSONObject tempObject;
            JSONArray tempArray;

			String qry = getDeliveryFeeQuery(variant, cart.getProperty("site_id"), cart.getProperty("datowncity"), cart.getProperty("dapostalCode"), cart.getProperty("daline1"), cart.getProperty("daline2"), logged, cart.getProperty("delivery_type"));
            Set rsDeliveryFee = Etn.execute(qry);
            if(rsDeliveryFee.next())
			{
                if(deliveryFeeIndexes.has(rsDeliveryFee.value("id")))
				{
                    tempObject = deliveryFeeIndexes.getJSONObject(rsDeliveryFee.value("id"));
                    tempArray = tempObject.getJSONArray("indexes");
                }
                else
				{
                    tempObject = new JSONObject();
                    tempObject.put("applicable_per_item",rsDeliveryFee.value("applicable_per_item"));
                    tempObject.put("fee",PortalHelper.parseNullDouble(rsDeliveryFee.value("fee")));
                    tempArray = new JSONArray();
                }
                tempArray.put(cartIndex);
                tempObject.put("indexes",tempArray);
                deliveryFeeIndexes.put(rsDeliveryFee.value("id"),tempObject);
            }
            else
			{
                if(deliveryFeeIndexes.has("0"))
				{
                    tempObject = deliveryFeeIndexes.getJSONObject("0");
                    tempArray = tempObject.getJSONArray("indexes");
                }
                else
				{
                    tempObject = new JSONObject();
                    tempObject.put("applicable_per_item","0");
                    tempObject.put("fee",defaultFee);
                    tempArray = new JSONArray();
                }
                tempArray.put(cartIndex);
                tempObject.put("indexes",tempArray);
                deliveryFeeIndexes.put("0",tempObject);
            }
            cartIndex++;
        }
        return deliveryFeeIndexes;
    }

    private static JSONObject getCartRules(Contexte Etn, HttpServletRequest request, Cart cart, double totalAmount) throws Exception
	{
		Logger.info("CartHelper", "In cartRulesObj : " + cart.getProperty("id"));
		String promoError = "";
        JSONArray cartRules = new JSONArray();
        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");

        boolean logged = ClientSession.getInstance().isClientLoggedIn(Etn, request);

		List<String> arrIds = new ArrayList<String>();
        int quantity = 0;
		for(CartItem item : cart.getItems())
		{
			Logger.info("CartHelper", "Item variant id : "+item.getVariant().getVariantId());
			arrIds.add(item.getVariant().getVariantId());
			
            quantity += PortalHelper.parseNullInt(item.getProperty("quantity"));			
			
			//27-jun-24 ... comewiths must be considered for cart rules ... ticket:5000
			JSONArray comewith = CommonPrice.getComewith(Etn, request, item.getVariant().getVariantId(), cart.getLangColumnPrefix(), cart.getLangId(), item.getProperty("comewith_excluded"), false, cart.getMenuId(), 1, item.getProperty("comewith_variant_id"));
			if(comewith != null && comewith.length() > 0)
			{
				Logger.info("CartHelper", "item has comewiths");
				for(int i=0; i<comewith.length(); i++)
				{
					String _id = comewith.getJSONObject(i).optString("variant_id");
					Logger.info("CartHelper", "comewith variant id : "+_id);

					arrIds.add(_id);
				} 
			}
		}
		
		LanguageHelper languageHelper = LanguageHelper.getInstance();

		String paymentMethod = cart.getProperty("payment_method");
		String deliveryMethod = cart.getProperty("delivery_method");

        Set rsOrders = Etn.execute("select promo_code from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders where promo_code="+escape.cote(cart.getProperty("promo_code")));

        String cartRulesQuery = "select cp.*, cpc.coupon_code from "+catalogdb+".cart_promotion cp left join "+catalogdb+".cart_promotion_coupon cpc on cp.id = cpc.cp_id "+
			" where cp.site_id="+escape.cote(cart.getProperty("site_id"))+" and COALESCE(cpc.coupon_code,'') IN("+escape.cote(cart.getProperty("promo_code"))+",'') group by cp.id order by order_seq";

        Set rsCartRules = Etn.execute(cartRulesQuery);
		boolean skipRule = false;
        while(rsCartRules.next())
		{
			//no delivery method selected yet so skip this rule for now
			if(rsCartRules.value("element_on").equals("shipping_fee") && PortalHelper.parseNull(cart.getProperty("delivery_method")).length() == 0) 
			{
				skipRule = true;
				continue;
			}
			//we dont add visible to check in the query as we want to give appropriate message to user
			if(rsCartRules.value("visible_to").equals("logged") && !logged) 
			{
				//now check if current cart rule is a coupon code rule then set its error message
				if(rsCartRules.value("coupon_code").length() > 0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Promo valid only for logged in users");
				continue;// check rule applied to logged in user or all
			}
			//user per coupon already reached limit
			if(rsCartRules.value("coupon_code").length()>0 && PortalHelper.parseNullInt(rsCartRules.value("uses_per_coupon"))>0 && PortalHelper.parseNullInt(rsCartRules.value("uses_per_coupon")) <= rsOrders.rs.Rows) 
			{
				//now check if current cart rule is a coupon code rule then set its error message
				if(promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Coupon limit reached");
				continue;			
			}
			if(rsCartRules.value("coupon_code").length()>0 && PortalHelper.parseNull(rsCartRules.value("uses_per_coupon")).length() > 0 && PortalHelper.parseNullInt(rsCartRules.value("uses_per_coupon")) == 0) 
			{
				//new case where we first check if any value is given in user_per_coupon .. if given and if its value is 0 it also means the coupon limit is reached
				//this case was added for OBW scratch cards where we fetch the scratch card from their api at first then at last step in cart
				//we again check from their api if the scratch card is still valid .. if not valid then we set its user_per_coupon = 0 in our db
				if(promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Coupon limit reached");
				continue;			
			}
            String startDateString = rsCartRules.value("start_date");
            String endDateString = rsCartRules.value("end_date");
            try 
			{
                if(!CommonPrice.isValidDateRange(startDateString, endDateString)) 
				{
					//now check if current cart rule is a coupon code rule then set its error message
					if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Promo not valid today");
					continue;
				}
                if(rsCartRules.value("rule_type").equals("cart_product"))
				{
                    if(arrIds.size() == 0) 
					{
						//now check if current cart rule is a coupon code rule then set its error message
						if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "No items in cart");
						continue;
					}
                    String whereClause = "";
                    if(rsCartRules.value("verify_condition").equals("product")) whereClause = " and p.id = "+escape.cote(rsCartRules.value("rule_condition_value"));
                    else if(rsCartRules.value("verify_condition").equals("sku")) whereClause = " and pv.sku = "+escape.cote(rsCartRules.value("rule_condition_value"));
                    else if(rsCartRules.value("verify_condition").equals("product_type")) whereClause = " and c.catalog_type = "+escape.cote(rsCartRules.value("rule_condition_value"));
                    else if(rsCartRules.value("verify_condition").equals("catalog")) whereClause = " and p.catalog_id = "+escape.cote(rsCartRules.value("rule_condition_value"));
                    else if(rsCartRules.value("verify_condition").equals("manufacturer")) whereClause = " and p.brand_name = "+escape.cote(rsCartRules.value("rule_condition_value"));
					
					String inclause = "";
					for(String _id : arrIds)
					{
						if(inclause.length() > 0) inclause += ",";
						inclause += escape.cote(_id);
					}
                    
                    Set rsVariant = Etn.execute("select pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id where pv.id IN ("+inclause+") "+whereClause);
                    if(!rsVariant.next()) 
					{
						//now check if current cart rule is a coupon code rule then set its error message
						if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Not valid on selected items");
						continue;
					}
                }
                else if(rsCartRules.value("rule_type").equals("cart_attribute"))
				{
                    if(rsCartRules.value("verify_condition").equals("payment_method"))
					{
                        if(paymentMethod.equals("") || !paymentMethod.equals(rsCartRules.value("rule_condition_value"))) 
						{
							//now check if current cart rule is a coupon code rule then set its error message							
							if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Not valid on selected payment method");
							continue;
						}
						else if(PortalHelper.parseNull(paymentMethod).length() == 0)
						{
							skipRule = true;
							continue;
						}						
                    }
                    else if(rsCartRules.value("verify_condition").equals("delivery_method"))
					{
                        if(deliveryMethod.equals("") || !deliveryMethod.equals(rsCartRules.value("rule_condition_value"))) 
						{
							//now check if current cart rule is a coupon code rule then set its error message
							if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Not valid on selected delivery method");
							continue;
						}
						else if(PortalHelper.parseNull(deliveryMethod).length() == 0)
						{
							skipRule = true;
							continue;
						}						
                    }
                    else if(rsCartRules.value("verify_condition").equals("total_amount"))
					{
                        if(rsCartRules.value("rule_condition").equals("is") && PortalHelper.parseNullDouble(rsCartRules.value("rule_condition_value"))!=totalAmount) 
						{
							if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Total should be equal to ")+rsCartRules.value("rule_condition_value");
							continue;
						}
                        if(rsCartRules.value("rule_condition").equals("greater_than") && PortalHelper.parseNullDouble(rsCartRules.value("rule_condition_value"))>=totalAmount) 
						{
							if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Total should be greater than ")+rsCartRules.value("rule_condition_value");
							continue;
						}
                        if(rsCartRules.value("rule_condition").equals("less_than") && PortalHelper.parseNullDouble(rsCartRules.value("rule_condition_value"))<=totalAmount) 
						{
							if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Total should be less than ")+rsCartRules.value("rule_condition_value");
							continue;
						}
                    }
                    else if(rsCartRules.value("verify_condition").equals("total_quantity"))
					{
                        if(rsCartRules.value("rule_condition").equals("is") && PortalHelper.parseNullDouble(rsCartRules.value("rule_condition_value"))!=quantity) 
						{
							if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Quantity should be equal to ")+rsCartRules.value("rule_condition_value");
							continue;
						}
                        if(rsCartRules.value("rule_condition").equals("greater_than") && PortalHelper.parseNullDouble(rsCartRules.value("rule_condition_value"))>=quantity) 
						{
							if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Quantity should be greater than ")+rsCartRules.value("rule_condition_value");
							continue;
						}
                        if(rsCartRules.value("rule_condition").equals("less_than") && PortalHelper.parseNullDouble(rsCartRules.value("rule_condition_value"))<=quantity) 
						{
							if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) promoError = languageHelper.getTranslation(Etn, "Quantity should be less than ")+rsCartRules.value("rule_condition_value");
							continue;
						}
                    }
                }
				
				JSONArray jElementsOn = new JSONArray();
				if("list".equalsIgnoreCase(rsCartRules.value("element_on")))
				{
					List<String> onElementsVariantId = new ArrayList<>();
					
					Set rsElementsOn = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion_on_elements where cart_promo_id = "+escape.cote(rsCartRules.value("id")));
					while(rsElementsOn.next())
					{
						JSONObject jEleOn = new JSONObject();
						jEleOn.put("on", rsElementsOn.value("element_on"));
						jEleOn.put("value", rsElementsOn.value("element_on_value"));

						JSONArray jVIds = new JSONArray();
						String colname = "sku";
						if("product".equalsIgnoreCase(rsElementsOn.value("element_on"))) colname = "product_id";
						Set _rsV = Etn.execute("select id from "+GlobalParm.getParm("CATALOG_DB")+".product_variants where "+colname+" = "+escape.cote(rsElementsOn.value("element_on_value")));
						while(_rsV.next())
						{
							onElementsVariantId.add(_rsV.value("id"));							
							jVIds.put(_rsV.value("id"));							
						}				
						
						jEleOn.put("variant_ids", jVIds);
						jElementsOn.put(jEleOn);
					}
					Logger.info("CartHelper", "cart_promo_id : " + rsCartRules.value("id"));
					Logger.info("CartHelper", "jElementsOn : " + jElementsOn.toString());
					
					if(onElementsVariantId.size() == 0)
					{
						if(rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0) 
						{
							promoError = languageHelper.getTranslation(Etn, "Invalid promo code");							
						}
						continue;
					}
					
					boolean anyFound = false;
					for(String vId : arrIds)
					{
						for(String eOnVid : onElementsVariantId)
						{
							if(vId.equals(eOnVid))
							{
								anyFound = true;
								break;
							}
						}
					}
					
					if(anyFound == false && rsCartRules.value("coupon_code").length()>0 && promoError.length() == 0)
					{
						promoError = languageHelper.getTranslation(Etn, "Not valid on selected items");
						continue;
					}
					
				}

                if(rsCartRules.value("rule_field").equals("0")) cartRules = new JSONArray();

                JSONObject cartRule = new JSONObject();
				
				String eleOn = rsCartRules.value("element_on");
				if(jElementsOn.length() > 0) eleOn = "list";
				
                cartRule.put("name", rsCartRules.value("name"));
                cartRule.put("discount_type", rsCartRules.value("discount_type"));
                cartRule.put("discount_value", rsCartRules.value("discount_value"));
                cartRule.put("element_on", eleOn);
                cartRule.put("on_elements", jElementsOn);
                cartRule.put("coupon_code", rsCartRules.value("coupon_code"));
                cartRules.put(cartRule);

				//if no futher rule applicable return from here
                if(rsCartRules.value("rule_field").equals("0")) 
				{
					JSONObject resp = new JSONObject();
					resp.put("cartRules", cartRules);
					resp.put("promoErrorMsg", promoError);
					resp.put("skipRule", skipRule);
					return resp;
				}
            } 
			catch (Exception e) 
			{
                e.printStackTrace();
				JSONObject resp = new JSONObject();
				resp.put("cartRules", cartRules);
				resp.put("promoErrorMsg", promoError);
				resp.put("skipRule", skipRule);
                return resp;
            }
        }
		
		JSONObject resp = new JSONObject();
		resp.put("cartRules", cartRules);
		resp.put("promoErrorMsg", promoError);
		resp.put("skipRule", skipRule);
        return resp;
    }

	public static ProfilDiscount getApplicableProfilDiscount(Contexte Etn, String profil, String catalogid, String productid)
	{
		Set rsClientProfil = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".client_profil where profil="+escape.cote(profil));
		ProfilDiscount pdiscount = new ProfilDiscount();
		while(rsClientProfil.next())
		{
			if(rsClientProfil.value("catalog_id").equals("0"))
			{
				pdiscount.setOverallDiscount(PortalHelper.parseNullDouble(rsClientProfil.value("discount_value")));
				pdiscount.setOverallDiscountType(rsClientProfil.value("discount_type"));
			}
			else if(catalogid.equals(rsClientProfil.value("catalog_id")) && rsClientProfil.value("product_id").equals("0"))
			{
				pdiscount.setCatalogDiscount(PortalHelper.parseNullDouble(rsClientProfil.value("discount_value")));
				pdiscount.setCatalogDiscountType(rsClientProfil.value("discount_type"));
			}
			else if(productid.equals(rsClientProfil.value("product_id")))
			{
				pdiscount.setProductDiscount(PortalHelper.parseNullDouble(rsClientProfil.value("discount_value")));
				pdiscount.setProductDiscountType(rsClientProfil.value("discount_type"));
			}
		}
		return pdiscount;
	}

	private static CartError checkFraud(Contexte Etn, Cart cart, String clientId, String ipAddr)
	{
		return checkFraud(Etn, cart.getProperty("site_id"), cart.getMenuUuid(), clientId, cart.getProperty("identityId"), cart.getProperty("email"), ipAddr);
	}

	//this function was old and used in all places to have to keep it here for now. This old function does not support cart type and also it has fixed 3 columns check 
	//in future do not use this function ..... instead use checkFraud(Contexte Etn, String siteId, String menuUuid, String clientId, String cartType, Map<String, String> columns)
	@Deprecated
	public static CartError checkFraud(Contexte Etn, String siteId, String menuUuid, String clientId, String identityId, String email, String ipAddr)
	{
		Logger.error("CartHelper", "In OLD checkFraud function. Change code to use the new function");
		Map<String, String> columns = new HashMap<>();
		columns.put("identityId", identityId);
		columns.put("email", email);
		columns.put("ip", ipAddr);
		
		return checkFraud(Etn, siteId, menuUuid, clientId, CartHelper.Type.NORMAL, columns);
	}
		
	public static CartError checkFraud(Contexte Etn, String siteId, String menuUuid, String clientId, String cartType, Map<String, String> columns)
	{
		Logger.info("CartHelper", "In checkFraud for cart_type : "+cartType);
		
		Set rsFraud = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".fraud_rules where cart_type = "+escape.cote(cartType)+" and site_id =  "+escape.cote(siteId) + " and enable=1 order by days desc");
		while(rsFraud.next())
		{
			String fraudColumn = rsFraud.value("column");
			String fraudValue = PortalHelper.parseNull(columns.get(fraudColumn));
			if(fraudValue.length() > 0)
			{
				Set rsOrders = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".orders where "+escape.cote(fraudColumn).replaceAll("'","`")+"="+escape.cote(fraudValue)+" and tm > DATE_SUB(now(), INTERVAL "+rsFraud.value("days")+" DAY)");

				if(rsOrders.rs.Rows >= PortalHelper.parseNullInt(rsFraud.value("limit")))
				{
					Etn.executeCmd("insert into "+GlobalParm.getParm("CATALOG_DB")+".fraud_rules_log set ip = "+escape.cote(PortalHelper.parseNull(columns.get("ip")))+", cart_type = "+escape.cote(cartType)+", site_id = "+escape.cote(siteId)+", tm=now(), `column`="+escape.cote(fraudColumn)+", days="+escape.cote(rsFraud.value("days"))+", `limit`="+escape.cote(rsFraud.value("limit"))+", client_id="+escape.cote(clientId)+", value="+escape.cote(fraudValue));
					
					CartError cErr = new CartError();
					cErr.setReturnUrl(GlobalParm.getParm("CART_EXTERNAL_LINK")+"error_fraud.jsp?muid="+menuUuid+"&_tm="+System.currentTimeMillis());
					return cErr;
				}
			}
		}
		return null;
	}

	public static Map<String, String> loadFraudRuleColumns(Contexte Etn, HttpServletRequest request, Cart cart)
	{		
		Map<String, String> columns = new HashMap<>();
		Set rs = Etn.execute("select * from "+GlobalParm.getParm("COMMONS_DB")+".fraud_rules_columns order by display_name ");
		while(rs.next())
		{
			//name is same as in the cart table which goes in properties of cart object
			String val = PortalHelper.parseNull(cart.getProperty(rs.value("name")));
			if("ip".equalsIgnoreCase(rs.value("name")))
			{
				columns.put(rs.value("name"), PortalHelper.getIP(request));				
			}
			else
			{
				columns.put(rs.value("name"), val);
			}
		}
		return columns;
	}
	
	/**
	* This function will insert a new row in payments_ref table in shop database and also insert the cart into orders in phase InitiatePayment
	* All cart level checks like fraud check, low item check etc must be handled by developer before calling this function
	*
	*/
	public static PaymentsRef initiatePayment(Contexte Etn, HttpServletRequest request, Cart cart, String paymentMethod, String paymentId, String hostUrl, String returnUrl, String cancelUrl) throws Exception
	{		
		PaymentsRef pref = null;
		String logPrefix = "initiatePayment:cid:"+cart.getProperty("id")+":";
		
		String clientId = "";
		Client client = ClientSession.getInstance().getLoggedInClient(Etn, request);
		if(client != null)
		{
			clientId = client.getProperty("id");
		}			
		
		String menuUuid = cart.getMenuUuid();
		String lang = cart.getLang();
		String siteId = cart.getProperty("site_id");		
		//as are handling near to impossible case where client id was in session but was not found in db so we can land here again after clientId.length() > 0 if
		if(clientId.length() == 0)
		{		
			String name = PortalHelper.parseNull(cart.getProperty("name"));
			String surnames = PortalHelper.parseNull(cart.getProperty("surnames"));
			String email = PortalHelper.parseNull(cart.getProperty("email"));
	
			//check if this email already exists then get that client_uuid
			Set rs = Etn.execute("select * from clients where site_id = "+escape.cote(siteId)+" and email="+escape.cote(email));
			if(rs.next())
			{			
				clientId = rs.value("id");
			}
			else//otherwise insert the client
			{
				String client_profil_id = "";
				Set rsClientProfil = Etn.execute("select id from client_profils where is_default=1;");
				if(rsClientProfil.next()) client_profil_id = rsClientProfil.value("id");
				int new_id = Etn.executeCmd("insert into clients (site_id, client_uuid, username, email, pass, name, surname, client_profil_id, signup_menu_uuid) values ("+escape.cote(siteId)+", uuid(), "+escape.cote(email)+", "+escape.cote(email)+",'',"+escape.cote(name)+","+escape.cote(surnames)+","+escape.cote(client_profil_id)+","+escape.cote(menuUuid)+") ");
				if(new_id>0) 
				{
					clientId = new_id+"";
				}
			}		
		}
				
		String totalPrice = PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), cart.getGrandTotal()+"", true);
		
		String paymentRefId = UUID.randomUUID().toString();

		while(true){
			String query = "SELECT id FROM "+GlobalParm.getParm("SHOP_DB")+".payments_ref WHERE id = "+escape.cote(paymentRefId);
			Set rs = Etn.execute(query);
			if(rs.rs.Rows==0){
				break;
			}
			else{
				paymentRefId = UUID.randomUUID().toString();
			}
		}
		
		String query = "INSERT INTO "+GlobalParm.getParm("SHOP_DB")+".payments_ref (id, payment_id, menu_uuid, payment_method, host_url, total_price, cart_id, return_url, cancel_url, created_ts) VALUES "
					+ " ( " +escape.cote(paymentRefId)
					+ " , "  +escape.cote(PortalHelper.parseNull(paymentId))
					+ " , "  +escape.cote(menuUuid)
					+ " , "  +escape.cote(PortalHelper.parseNull(paymentMethod))
					+ " , "  +escape.cote(PortalHelper.parseNull(hostUrl))
					+ " , "  +escape.cote(totalPrice)
					+ " , "  +escape.cote(cart.getProperty("id"))
					+ " , "  +escape.cote(returnUrl)
					+ " , "  +escape.cote(cancelUrl)
					+ " , NOW())";
		
		if(Etn.executeCmd(query) > 0)
		{
			int orderId = insertOrderIntoDb(Etn, request, cart, clientId, null, paymentRefId, "", "", "", "", "initiated", "", totalPrice, "");
			
			if(orderId > 0)
			{
				Set rsProcesses = Etn.execute("Select * from site_config_process where action='initpayment' and site_id="+escape.cote(siteId));
				rsProcesses.next();

				insertOrderPhase(Etn, orderId, PortalHelper.parseNull(rsProcesses.value("process")), PortalHelper.parseNull(rsProcesses.value("phase")));
				
				Etn.executeCmd("update "+GlobalParm.getParm("SHOP_DB")+".payments_ref set order_id = "+escape.cote(""+orderId)+" where id = "+escape.cote(paymentRefId));
				
				Set rs = Etn.execute("Select * from "+GlobalParm.getParm("SHOP_DB")+".payments_ref where id = "+escape.cote(paymentRefId));
				if(rs.next())
				{
					pref = new PaymentsRef();
					for(int i=0; i<rs.ColName.length; i++)
					{
						String propValue = PortalHelper.parseNull(rs.value(i));
						pref.addProperty(rs.ColName[i], propValue);
					}
				}
			}									
		}
		
		return pref;
		
	}
	
	private static void insertOrderPhase(Contexte Etn, int orderId, String process, String phase) throws Exception
	{
		String query = "INSERT INTO "+GlobalParm.getParm("SHOP_DB")+".post_work SET client_key="+escape.cote(orderId+"")+", proces="+escape.cote(process)+", phase="+escape.cote(phase)+", status=0, errCode=0, priority=NOW(), insertion_date=NOW();";
		Etn.executeCmd(query);
		Etn.executeCmd("SELECT semfree("+escape.cote(GlobalParm.getParm("SHOP_SEMAPHORE"))+");");		
	}
	
	private static int insertOrderIntoDb(Contexte Etn, HttpServletRequest request, Cart cart, String clientId, Map<String, String> extraOrderInfo, 
									String payment_ref_id, String payment_id, String payment_token, String payment_url, String payment_notif_token,
									String payment_status, String payment_txn_id, String payment_total_amount, String transaction_code) throws Exception									
	{
		String logPrefix = "insertOrderIntoDb:cid:"+cart.getProperty("id")+":";
		Logger.info("CartHelper", logPrefix+"Ready to insert new order");			

		String menuUuid = cart.getMenuUuid();
		String lang = cart.getLang();
		String siteId = cart.getProperty("site_id");		

		String salutation = PortalHelper.parseNull(cart.getProperty("salutation"));
		String name = PortalHelper.parseNull(cart.getProperty("name"));
		String surnames = PortalHelper.parseNull(cart.getProperty("surnames"));
		String identityId = PortalHelper.parseNull(cart.getProperty("identityId"));
		String identityType = PortalHelper.parseNull(cart.getProperty("identityType"));
		String contactPhoneNumber1 = PortalHelper.parseNull(cart.getProperty("contactPhoneNumber1"));
		String email = PortalHelper.parseNull(cart.getProperty("email"));
		String baline1 = PortalHelper.parseNull(cart.getProperty("baline1"));
		String baline2 = PortalHelper.parseNull(cart.getProperty("baline2"));
		String batowncity = PortalHelper.parseNull(cart.getProperty("batowncity"));
		String bapostalCode = PortalHelper.parseNull(cart.getProperty("bapostalCode"));
		String daline1 = PortalHelper.parseNull(cart.getProperty("daline1"));
		String daline2 = PortalHelper.parseNull(cart.getProperty("daline2"));
		String datowncity = PortalHelper.parseNull(cart.getProperty("datowncity"));
		String dapostalCode = PortalHelper.parseNull(cart.getProperty("dapostalCode"));
		String identityPhoto = PortalHelper.parseNull(cart.getProperty("identityPhoto"));
		String newPhoneNumber = PortalHelper.parseNull(cart.getProperty("newPhoneNumber"));
		String selected_boutique = PortalHelper.parseNull(cart.getProperty("selected_boutique"));
		String rdv_boutique = PortalHelper.parseNull(cart.getProperty("rdv_boutique"));
		String rdv_date = PortalHelper.parseNull(ItsDate.stamp(ItsDate.getDate(cart.getProperty("rdv_date"))));
		String delivery_method = PortalHelper.parseNull(cart.getProperty("delivery_method"));
		String delivery_type = PortalHelper.parseNull(cart.getProperty("delivery_type"));
		String country = PortalHelper.parseNull(cart.getProperty("country"));
		String newsletter = PortalHelper.parseNull(cart.getProperty("newsletter"));						
		String currencycode = cart.getCurrencyCode();
		String defaultcurrency = cart.getDefaultCurrency();
		String priceformatter = cart.getPriceFormatter();
		String roundto = cart.getRoundTo();
		String showdecimals = cart.getShowDecimals();
		String payment_method = PortalHelper.parseNull(cart.getProperty("payment_method"));
		
		//IDCheck kyc fields
		String kyc_uuid = PortalHelper.parseNull(cart.getProperty("idnow_uuid"));
		String kyc_uid = "";
		String kyc_status = "";
		String kyc_ts = "";
		String kyc_resp = "";

		if(kyc_uuid.length() > 0){
			Set kycRs = Etn.execute("SELECT * FROM idnow_sessions where uuid="+escape.cote(kyc_uuid));
			if(kycRs.next()){
				kyc_uid = PortalHelper.parseNull(kycRs.value("idnow_uid"));
				kyc_status = PortalHelper.parseNull(kycRs.value("status"));
				kyc_resp = PortalHelper.parseNull(kycRs.value("resp"));
				kyc_ts = PortalHelper.parseNull(kycRs.value("resp_timestamp"));
			}

		}

		
				
		double paymentFees = cart.getPaymentFees();
		double shippingFees = cart.getShippingFees();
		
		String orderType = "Order";
		String promoCode = cart.getProperty("promo_code");
		double promoValue = cart.getPromoValue();
		
		String forterToken = PortalHelper.parseNull(ClientSession.getInstance().getParameter(Etn, request, "forter_token"));
		
		LanguageHelper languageHelper = LanguageHelper.getInstance();			
		
		String parentUuid = UUID.randomUUID().toString();
		
		Logger.info("CartHelper", logPrefix+"New order parentUuid : " + parentUuid);			
			
		List<String> orderItemIds = new ArrayList<String>();
		for(CartItem item : cart.getItems())
		{
			Logger.info("CartHelper",  logPrefix+"CartItem : "+item.toJSON());
			
			ProductVariant variant = item.getVariant();
			int qty = PortalHelper.parseNullInt(item.getProperty("quantity"));
			
			String productName = languageHelper.getTranslation(Etn, PortalHelper.parseNull(variant.getBrandName())) + " " + PortalHelper.parseNull(variant.getProductName());
			
			JSONObject product_snapshot = new JSONObject();
			product_snapshot.put("price", PortalHelper.parseNull(variant.getUnformattedVariantPrice()));
			product_snapshot.put("variantName",PortalHelper.parseNull(variant.getVariantName()));
			product_snapshot.put("variant_uuid",PortalHelper.parseNull(variant.getVariantUUID()));
			product_snapshot.put("sku",PortalHelper.parseNull(variant.getSku()));
			product_snapshot.put("ean",PortalHelper.parseNull(variant.getEan()));
			product_snapshot.put("comewithExcluded", PortalHelper.parseNull(item.getProperty("comewith_excluded")));
			product_snapshot.put("deliveryFeePerItem",PortalHelper.parseNull(item.getProperty("delivery_fee_per_item")));
			product_snapshot.put("attributes", variant.getAttributes());
			product_snapshot.put("duration", variant.getDuration());
			//product_snapshot.put("variantImage", PortalHelper.getBase64Image(variant.getThumbnailPath()));
			product_snapshot.put("image_name", variant.getImageName());
			product_snapshot.put("original_image_path", variant.getThumbnailPath());
			product_snapshot.put("original_image_url", variant.getThumbnailUrl());
			product_snapshot.put("frequency", variant.getFrequency());
			product_snapshot.put("product_version", variant.getProductVersion());
			product_snapshot.put("product_uuid", variant.getProductUUID());
			product_snapshot.put("v2_categories", variant.getProductCategories());
			
			if(variant.getProductVersion().equalsIgnoreCase("V2"))
			{
				//assumption that product type is considered as catalog in v2 so we set that in type
				Set rspd = Etn.execute("select pt.type_name "+
					" from "+GlobalParm.getParm("CATALOG_DB")+".products p "+
					" join "+GlobalParm.getParm("CATALOG_DB")+".products_definition pd on pd.id = p.product_definition_id "+
					" join "+GlobalParm.getParm("CATALOG_DB")+".product_types_v2 pt on pt.id = pd.product_type "+
					" where p.id = "+escape.cote(variant.getProductId()));
				if(rspd.next())
				{
					//we will always be here
					product_snapshot.put("type", rspd.value("type_name"));
				}
				else
				{
					product_snapshot.put("type", variant.getCatalogName());
				}
			}
			else
			{
				product_snapshot.put("type", variant.getCatalogName());
			}
			
			if(PortalHelper.parseNull(variant.getImageName()).length() > 0)
			{
				try
				{
					//copy image to variant images location in shop webapp
					String shopVariantImagePath = PortalHelper.parseNull(GlobalParm.getParm("VARIANT_IMAGE_UPLOAD_DIRECTORY"));
					if(shopVariantImagePath.length() > 0)
					{
						if(shopVariantImagePath.endsWith("/") == false) shopVariantImagePath += "/";
						Logger.info("CartHelper", "Copy variant image "+variant.getThumbnailPath()+" to "+shopVariantImagePath + variant.getImageName());
						java.nio.file.Files.copy((new java.io.File(variant.getThumbnailPath())).toPath(), (new java.io.File(shopVariantImagePath + variant.getImageName())).toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
					}
					else
					{
						Logger.error("CartHelper", "Property VARIANT_IMAGE_UPLOAD_DIRECTORY is empty");
					}				
				}
				catch(Exception fe)
				{
					Logger.error("CartHelper", "Error copying variant image file");
					fe.printStackTrace();
				}
			}
			
			
			String query = "INSERT INTO "+GlobalParm.getParm("SHOP_DB")+".order_items SET product_ref="+escape.cote(PortalHelper.parseNull(variant.getVariantId()))
					+",brand_name="+escape.cote(PortalHelper.parseNull(variant.getBrandName()))+",product_full_name="+escape.cote(productName)
					+",quantity="+escape.cote(qty+"")+",product_name="+escape.cote(PortalHelper.parseNull(variant.getProductName()))
					+",product_snapshot="+PortalHelper.escapeCote2(product_snapshot.toString())
					+",price="+escape.cote(variant.getFormattedPrice())+",product_type="+PortalHelper.escapeCote2(variant.getProductType())
					+",price_value="+escape.cote(variant.getPriceValue())+",price_old_value="+escape.cote(variant.getPriceOldValue())+",tax_percentage="+escape.cote(variant.getTaxPercentage().tax+"")
					+",attributes="+PortalHelper.escapeCote2(variant.getAttributes().toString())+",comewiths="+PortalHelper.escapeCote2(variant.getComewith().toString())
					+",additionalfees="+PortalHelper.escapeCote2(variant.getAdditionalFee().toString())+",promotion="+PortalHelper.escapeCote2(variant.getPromotion().toString())
					+",parent_id="+escape.cote(parentUuid)+",catalog_name="+escape.cote(variant.getCatalogName());

			int j = Etn.executeCmd(query);
			if(j>0)
			{
				orderItemIds.add(j+"");
			}					
		}
			
		if(orderItemIds.isEmpty() == false)
		{
			SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy");
			SimpleDateFormat tf = new SimpleDateFormat("HH:mm");
			SimpleDateFormat orderf = new SimpleDateFormat("yyMM");
			Date date = new Date();
			String orderDate = df.format(date);
			String orderTime = tf.format(date);

			String randomString = Math.random()+"";
			randomString = randomString.substring(2,10);
			String orderRef = orderf.format(date)+(Math.random()+"").substring(2,10);

			while(true){
				Set orderRs = Etn.execute("SELECT * FROM "+GlobalParm.getParm("SHOP_DB")+".orders where orderRef="+escape.cote(orderRef));
				if(orderRs.rs.Rows==0) break;
				orderRef = orderf.format(date)+(Math.random()+"").substring(2,10);
			}

			Logger.info("CartHelper", logPrefix+"New order orderRef : " + orderRef);			
			
			JSONObject order_snapshot = getOrderSnapshot(Etn, cart, extraOrderInfo);
			
			Logger.info("CartHelper",  logPrefix+"Cart : "+cart.toJSON());
			
			String query = "INSERT INTO "+GlobalParm.getParm("SHOP_DB")+".orders SET orderType="+escape.cote(orderType)+",creationdate=NOW(),client_id="+escape.cote(clientId)
				+",name="+escape.cote(name)+",surnames="+escape.cote(surnames)+",salutation="+escape.cote(salutation)
				+",identityId="+escape.cote(identityId)+",identityType="+escape.cote(identityType)+",contactPhoneNumber1="+escape.cote(contactPhoneNumber1)+",country="+escape.cote(country)
				+",spaymentmean="+escape.cote(payment_method)+",shipping_method_id="+escape.cote(delivery_method)+",email="+escape.cote(email)+",baline1="+escape.cote(baline1)+",baline2="+escape.cote(baline2)
				+",batowncity="+escape.cote(batowncity)+",bapostalCode="+escape.cote(bapostalCode)
				+",daline1="+escape.cote(daline1)+",daline2="+escape.cote(daline2)+",datowncity="+escape.cote(datowncity)+",dapostalCode="+escape.cote(dapostalCode)
				+",menu_uuid="+escape.cote(menuUuid)+",ip="+escape.cote(PortalHelper.getIP(request))
				+",total_price="+escape.cote(PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotal()+"", true))+",parent_uuid="+escape.cote(parentUuid)+",orderRef="+escape.cote(orderRef)
				+",lang="+escape.cote(lang)+",currency="+escape.cote(defaultcurrency)+",currency_code="+escape.cote(currencycode)
				+",payment_fees="+escape.cote(PortalHelper.formatPrice(priceformatter, roundto, showdecimals, paymentFees+"", true))
				+",delivery_fees="+escape.cote(PortalHelper.formatPrice(priceformatter, roundto, showdecimals, shippingFees+"", true))
				+",payment_id="+escape.cote(payment_id)+",payment_token="+escape.cote(payment_token)+",payment_url="+escape.cote(payment_url)+",payment_notif_token="+escape.cote(payment_notif_token)
				+",payment_status="+escape.cote(payment_status)+",payment_txn_id="+escape.cote(payment_txn_id)+",transaction_code="+escape.cote(transaction_code)
				+",order_snapshot="+PortalHelper.escapeCote2(order_snapshot.toString())
				+",identityPhoto="+escape.cote(identityPhoto)+",newPhoneNumber="+escape.cote(newPhoneNumber)+",delivery_type="+escape.cote(delivery_type)
				+",payment_ref_total_amount="+escape.cote(payment_total_amount)+",payment_ref_id="+escape.cote(payment_ref_id)+",user_agent="+escape.cote(PortalHelper.parseNull(request.getHeader("user-agent")))+",site_id="+escape.cote(siteId)+",newsletter="+escape.cote(newsletter)
				+",cart_type="+escape.cote(cart.getProperty("cart_type"))
				+",additional_info="+escape.cote(cart.getProperty("additional_info"))
				+",cart_id="+escape.cote(cart.getProperty("id"))
				+",delivery_start_hour="+escape.cote(cart.getProperty("delivery_start_hour"))
				+",delivery_start_min="+escape.cote(cart.getProperty("delivery_start_min"))
				+",delivery_end_hour="+escape.cote(cart.getProperty("delivery_end_hour"))
				+",delivery_end_min="+escape.cote(cart.getProperty("delivery_end_min"))
				+",delivery_date="+escape.cote(cart.getProperty("delivery_date_fmt_db"))
				+",forter_token="+escape.cote(forterToken)
				+",x_forwarded_for="+escape.cote(PortalHelper.parseNull(request.getHeader("X-Forwarded-For")))
				+",selected_boutique="+PortalHelper.escapeCote2(selected_boutique)+",rdv_boutique="+escape.cote(rdv_boutique)+",rdv_date="+escape.cote(rdv_date)+",promo_code="+escape.cote((cart.isPromoApplied()?promoCode:""));

			int ii = Etn.executeCmd(query);
			if(isKycRequired(Etn,siteId))
				Etn.executeCmd("INSERT INTO "+GlobalParm.getParm("SHOP_DB")+".order_kyc_info SET order_id="+escape.cote(""+ii)
					+",kyc_uid="+escape.cote(kyc_uid)+",kyc_resp="+PortalHelper.escapeCote2(kyc_resp)+",kyc_status="+escape.cote(kyc_status)+",kyc_ts="+escape.cote(kyc_ts));

			return ii;

		}
		return -1;
	}

	public static Map<String, String> insertOrder(Contexte Etn, HttpServletRequest request, Cart cart, String parentUuid, String transaction_code, Map<String, String> extraOrderInfo) throws Exception
	{
		String payment_ref_id = PortalHelper.parseNull(request.getParameter("payment_ref_id"));
		return insertOrder(Etn, request, cart, parentUuid, transaction_code, extraOrderInfo, payment_ref_id);
	}
	
	/**
	* Following error codes can be returned
	* 100 : Cart has errors which could be low stock, promo error, delivery error or empty cart
	* 110 : Fraud error
	* 120 : In case of paypal if payment status is not success
	* 130 : Unable to load the order from db
	**/
	public static Map<String, String> insertOrder(Contexte Etn, HttpServletRequest request, Cart cart, String parentUuid, String transaction_code, Map<String, String> extraOrderInfo, String payment_ref_id) throws Exception
	{		
		Logger.info("CartHelper", "In insertOrder " + cart.getProperty("id"));
		String logPrefix = "insertOrder:cid:"+cart.getProperty("id")+":";
		
		parentUuid = PortalHelper.parseNull(parentUuid);
		
		//parentUuid is empty always for this step except for Orange money server to server APIs which are implemented for OCM and OBF
		//in these two countries we do not call initiatePayment function but always insert the order to phase OrderReceived at payment step
		//then we have process designed to handle the server to server API calls. So once the payment step is done and we reach completion screen,
		//we always send the parentUuid to insertOrder function so that order is not inserted again into shop db but just update order snapshot with some extra info if any
		
		if(parentUuid.length() == 0)
		{
			Logger.info("CartHelper",  logPrefix+"parentUuid passed is empty");			
			parentUuid = PortalHelper.parseNull(cart.getProperty("order_uuid"));
		}
		Logger.info("CartHelper", logPrefix+"Final parentUuid : "+ parentUuid);
		
		boolean checkForErrors = true;
		payment_ref_id = PortalHelper.parseNull(payment_ref_id);
		Logger.info("CartHelper", logPrefix+"payment_ref_id : "+ payment_ref_id);
		if(payment_ref_id.length() > 0)
		{
			Set payRefRs = Etn.execute("SELECT * FROM "+GlobalParm.getParm("SHOP_DB")+".payments_ref WHERE id = "+escape.cote(payment_ref_id));
			if(payRefRs.next())
			{
				if("1".equalsIgnoreCase(PortalHelper.parseNull(payRefRs.value("is_success"))))
				{
					Logger.info("CartHelper",  logPrefix+"Payment already done so just insert order without checking cart errors");
					checkForErrors = false;//payment is successfully done so we are not going to check for any errors and just add order
				}
			}
		}
		
		
		Logger.info("CartHelper",  logPrefix+"checkForErrors : "+checkForErrors);
		
		Map<String, String> resp = new HashMap<String, String>();
		//we are suppose to insert the order so check for errors
		//if parentUuid is not empty means we are not going to insert the order and there can be chances stock for some item
		//could be 0 as order is already inserted .. so in this case we ignore all errors
		//if payment_ref_id length is greater than 0 means payment is already made so even if we have errors we must insert the order
		if(checkForErrors && parentUuid.length() == 0 && cart.hasError())
		{
			String errType = "";
			for(CartError cErr : cart.getErrors())
			{
				errType += cErr.getType() + ",";
			}
			resp.put("status","100");//cart has some errors
			resp.put("errtype","cart_error");
			resp.put("returnUrl", GlobalParm.getParm("CART_EXTERNAL_LINK")+"errorOrder.jsp?_tm="+System.currentTimeMillis()+"_ty="+errType);
			Logger.info("CartHelper", logPrefix+"cart has errors");
			return resp;
		}
		
		String payment_method = PortalHelper.parseNull(cart.getProperty("payment_method"));
		
		String payment_id = "";
		String payment_token = "";
		String payment_url = "";
		String payment_notif_token = "";
		String payment_status = "";
		String payment_txn_id = "";
		String paypal_order_id = "";
		String payment_total_amount = "";
		String payment_order_id = "";
		String payment_is_success = "0";
		
		if(payment_ref_id.length() > 0)
		{
			Set payRefRs = Etn.execute("SELECT * FROM "+GlobalParm.getParm("SHOP_DB")+".payments_ref WHERE id = "+escape.cote(payment_ref_id));

			if(payRefRs.next())
			{
				payment_id = payRefRs.value("payment_id");
				payment_token = payRefRs.value("payment_token");
				payment_url = payRefRs.value("payment_url");
				payment_notif_token = payRefRs.value("payment_notif_token");
				payment_status = payRefRs.value("payment_status");
				payment_txn_id = payRefRs.value("payment_txn_id");
				paypal_order_id = payRefRs.value("paypal_order_id");
				payment_order_id = payRefRs.value("order_id");
				payment_total_amount = PortalHelper.parseNull(payRefRs.value("total_price"));
				//this flag must be set by the developer implementing the payment APIs
				//depending on this flag only after the payment step the order will only be moved OrderReceived phase
				//every API returns different payment status like some send SUCCESS and some send SUCCESSFUL
				//so we cannot handle those in common code. Its the responsibility of developer to set is_success = 1 in case payment is done
				payment_is_success = PortalHelper.parseNull(payRefRs.value("is_success"));
			}
			
			if("paypal".equals(payment_method))
			{
				if("1".equals(payment_is_success) == true) payment_status = "verify_payment";
				transaction_code = paypal_order_id;
			}
			else if(PortalHelper.parseNull(transaction_code).length() == 0)
			{
				transaction_code = payment_txn_id;
			}
			
			//if order was already inserted at payment step using function initiatePayment only then we have payment_order_id 
			//in that case we must update payment related info into order table
			if(parentUuid.length() == 0 && payment_order_id.length() > 0)
			{
				Logger.info("CartHelper", logPrefix+" Order already inserted at payment step. Order ID : "+payment_order_id+". Just update payment info");
				//update payment related information to orders table
				Etn.executeCmd("update "+GlobalParm.getParm("SHOP_DB")+".orders set "+
						" payment_ref_id="+escape.cote(payment_ref_id)+
						",payment_id="+escape.cote(payment_id)+
						",payment_token="+escape.cote(payment_token)+
						",payment_url="+escape.cote(payment_url)+
						",payment_notif_token="+escape.cote(payment_notif_token)+
						",payment_status="+escape.cote(payment_status)+
						",payment_txn_id="+escape.cote(payment_txn_id)+
						",transaction_code="+escape.cote(transaction_code)+
						",payment_ref_total_amount="+escape.cote(payment_total_amount)+
						",payment_is_success="+escape.cote(payment_is_success)+
						" where id = "+escape.cote(payment_order_id));				
			}

			//we must check it inside if payment_ref_id.length() > 0 because its not always that orange money or paypal send us payment ref id
			//with new implementation of orange money, it will always insert order into dandellion before reaching completion
			//in which case payment_ref_id will not be sent in the request parameter
			if("1".equals(payment_is_success) == false)
			{
				resp.put("status","120");//payment error
				resp.put("errtype","payment_error");
				resp.put("returnUrl", GlobalParm.getParm("CART_EXTERNAL_LINK")+"errorOrder.jsp?_tm="+System.currentTimeMillis()+"_ty=PAYMENT_ERROR");
				Logger.info("CartHelper", logPrefix+"we have payment error so not going to insert the order");
				return resp;
			}

		}
		
		Logger.info("CartHelper", logPrefix+"payment_status:"+payment_status+"  transaction_code:"+transaction_code);
		
		boolean newInserted = false;
		//case of order inserted at payment step
		if(parentUuid.length() == 0 && payment_order_id.length() > 0)
		{
			//this order was inserted at payment step so we will update some info and move it to OrderReceived phase if payment was successfully done
			Set rsOd = Etn.execute("Select * from "+GlobalParm.getParm("SHOP_DB")+".orders where id = "+escape.cote(payment_order_id));
			rsOd.next();
			//we have already marked payment_is_success in orders table so the engine will take order to next appropriate phase
			parentUuid = rsOd.value("parent_uuid");
			//Order waits in InitiatePayment phase for 30 mins ... the action waitPayment30mins runs every 5 mins
			//and check for payment_is_success in orders table ... if its 1 it will go to error code 0 else if order is not 30mins old it will retry after 5mins
			//so we must set priority of phase to now as it might have been set for next 5mins because of last run of waitPayment30mins
			Etn.executeCmd("update "+GlobalParm.getParm("SHOP_DB")+".post_work set priority = now() where client_key = "+escape.cote(payment_order_id)+" and status = 0");
			Logger.info("CartHelper", logPrefix+" set priority of phase InitiatePayment to now so that it should move to next phase at errorCode = 0");
			Etn.execute("select semfree("+escape.cote(GlobalParm.getParm("SHOP_SEMAPHORE"))+")");
			
			//before we never used to insert the order in db at payment step
			//so we still consider this as new inserted order as for user its a new order
			//only in OBF/OCM orange money implementation we send it as newInserted false
			newInserted = true;
		}		
		else if(parentUuid.length() == 0)//normal case where order was not inserted at payment step
		{
			//we have to insert order			
			String clientId = "";
			boolean logged = false;
			String clientUuid = "";	
			Client client = ClientSession.getInstance().getLoggedInClient(Etn, request);
			if(client != null)
			{
				logged = true;
				clientId = client.getProperty("id");
				clientUuid = client.getProperty("client_uuid");
			}			
			
			//as are handling near to impossible case where client id was in session but was not found in db so we can land here again after clientId.length() > 0 if
			if(clientId.length() == 0)
			{	
				String menuUuid = cart.getMenuUuid();
				String lang = cart.getLang();
				String siteId = cart.getProperty("site_id");		
		
				String name = PortalHelper.parseNull(cart.getProperty("name"));
				String surnames = PortalHelper.parseNull(cart.getProperty("surnames"));
				String email = PortalHelper.parseNull(cart.getProperty("email"));
		
				//check if this email already exists then get that client_uuid
				Set rs = Etn.execute("select * from clients where site_id = "+escape.cote(siteId)+" and email="+escape.cote(email));
				if(rs.next())
				{			
					clientId = rs.value("id");
					clientUuid = rs.value("client_uuid");
				}
				else//otherwise insert the client
				{
					String client_profil_id = "";
					Set rsClientProfil = Etn.execute("select id from client_profils where is_default=1;");
					if(rsClientProfil.next()) client_profil_id = rsClientProfil.value("id");
					int new_id = Etn.executeCmd("insert into clients (site_id, client_uuid, username, email, pass, name, surname, client_profil_id, signup_menu_uuid) values ("+escape.cote(siteId)+", uuid(), "+escape.cote(email)+", "+escape.cote(email)+",'',"+escape.cote(name)+","+escape.cote(surnames)+","+escape.cote(client_profil_id)+","+escape.cote(menuUuid)+") ");
					if(new_id>0) 
					{
						clientId = new_id+"";
						rs = Etn.execute("select * from clients where id = "+escape.cote(clientId));
						rs.next();
						clientUuid = rs.value("client_uuid");
					}
				}		
			}

			//checkForErrors is false in case the payment is already made which means no one would be doing fraud after making payment
			//so in that case we dont have to check for fraud
			if(checkForErrors)
			{
				CartError fraudErr = CartHelper.checkFraud(Etn, cart, clientId, PortalHelper.getIP(request));
				if(fraudErr != null)
				{
					resp.put("status","110");//fraud
					resp.put("errtype","fraud_error");
					resp.put("returnUrl", fraudErr.getReturnUrl());
					Logger.info("CartHelper", logPrefix+"Returning due to fraud error");
					return resp;
				}
				//check if total amount is greater than 0 then payment type must be selected
				if(cart.getGrandTotal() > 0 && PortalHelper.parseNull(cart.getProperty("payment_method")).length() == 0)
				{
					resp.put("status","150");//payment method is missing
					resp.put("errtype","no_payment_method");
					resp.put("returnUrl", GlobalParm.getParm("CART_EXTERNAL_LINK")+"errorOrder.jsp?_tm="+System.currentTimeMillis()+"_ty=NO_PAYMENT_METHOD");
					Logger.info("CartHelper", logPrefix+"total amount due is more than 0 and payment method is missing. We cannot insert order.");
					return resp;
				}
			}	
			
			int orderId = insertOrderIntoDb(Etn, request, cart, clientId, extraOrderInfo, payment_ref_id, payment_id, payment_token, payment_url, payment_notif_token,
									payment_status, payment_txn_id, payment_total_amount, transaction_code);
									
			if(orderId > 0 ) 
			{
				Set rsOd = Etn.execute("Select * from "+GlobalParm.getParm("SHOP_DB")+".orders where id = "+escape.cote(""+orderId));
				rsOd.next();
				parentUuid = rsOd.value("parent_uuid");
				
				String siteId = cart.getProperty("site_id");
				Set rsProcesses = Etn.execute("Select * from site_config_process where action='confirmation' and site_id="+escape.cote(siteId));
				rsProcesses.next();

				insertOrderPhase(Etn, orderId, PortalHelper.parseNull(rsProcesses.value("process")), PortalHelper.parseNull(rsProcesses.value("phase")));
			}					
			//if order was previously inserted this will still be false
			newInserted = true;
		}

		//if any extra info need to be added to order snapshop, then we update it
		//this is mostly for the OBF and OCM case where after payment step we needed to add some extra info in order snapshot where the order 
		//was already inserted in db
		if(extraOrderInfo != null && extraOrderInfo.size() > 0)
		{
			JSONObject order_snapshot = getOrderSnapshot(Etn, cart, extraOrderInfo);
			Etn.executeCmd("UPDATE "+GlobalParm.getParm("SHOP_DB")+".orders SET order_snapshot = " + PortalHelper.escapeCote2(order_snapshot.toString()) + " WHERE parent_uuid = " + escape.cote(parentUuid));			
		}
		//load order
		Set rs = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".orders where parent_uuid = " + escape.cote(parentUuid));
		if(rs.next())
		{
			resp.put("status","0");
			resp.put("orderRef",rs.value("orderRef"));
			resp.put("orderUuid",rs.value("parent_uuid"));
			resp.put("orderId",rs.value("id"));
			resp.put("newInserted",newInserted+"");
			Logger.info("CartHelper", logPrefix+"Order inserted");
		}
		else
		{
			resp.put("status","130");
			resp.put("errtype","order_error");
			resp.put("returnUrl", GlobalParm.getParm("CART_EXTERNAL_LINK")+"errorOrder.jsp?_tm="+System.currentTimeMillis()+"_ty=CONFIRM_ERROR");
			Logger.info("CartHelper", logPrefix+"Order not inserted");
		}
		return resp;
	}
	
	/**
	* This will delete the cart entry from db and payment ref if any
	**/
	public static void cleanup(Contexte Etn, Cart cart) throws Exception
	{
		cleanup(Etn, cart.getProperty("id"));
	}
	
	public static void cleanup(Contexte Etn, String cartid) throws Exception
	{
//		Etn.executeCmd("delete from "+GlobalParm.getParm("SHOP_DB")+".payments_ref where cart_id = "+escape.cote(cartid));
//		Etn.executeCmd("delete from idnow_sessions where cart_id = "+escape.cote(cartid));
		Etn.executeCmd("delete from cart_items where cart_id = "+escape.cote(cartid));
		Etn.executeCmd("delete from cart where id = "+escape.cote(cartid));		
	}
	
	private static JSONObject getOrderSnapshot(Contexte Etn, Cart cart, Map<String, String> extraOrderInfo) throws Exception
	{
		String priceformatter = cart.getPriceFormatter();
		String roundto = cart.getRoundTo();
		String showdecimals = cart.getShowDecimals();
		LinkedHashSet<String> taxHS=new LinkedHashSet<String>();
		String paymentMethod = cart.getProperty("payment_method");		
		
		JSONObject order_snapshot = new JSONObject();
		order_snapshot.put("deliveryDisplayName", cart.getDeliveryDisplayName());
		order_snapshot.put("paymentDisplayName",cart.getPaymentDisplayName());
		order_snapshot.put("payer",(paymentMethod.equals("cash_on_delivery")?LanguageHelper.getInstance().getTranslation(Etn, "A Payer"):LanguageHelper.getInstance().getTranslation(Etn, "Payé")));
		order_snapshot.put("taxString",CommonPrice.getTaxString2(Etn, taxHS, cart.getTaxNumbers()));
		order_snapshot.put("promoValue", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getPromoValue()+"", true));
		order_snapshot.put("promoApplied", cart.isPromoApplied());
		order_snapshot.put("calculatedCartDiscounts", cart.getCalculatedCartDiscounts());
		order_snapshot.put("promoAppliedType", cart.getPromoAppliedType());
		order_snapshot.put("grandTotal", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotal()+"", true));
		order_snapshot.put("grandTotalWT", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotalWT()+"", true));
		order_snapshot.put("grandTotalRecurring", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotalRecurring()+"", true));
		order_snapshot.put("grandTotalRecurringWT", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotalRecurringWT()+"", true));
		order_snapshot.put("totalTax", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getTotalTax()+"", true));
		order_snapshot.put("paymentFees", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getPaymentFees()+"", true));
		order_snapshot.put("shippingFees", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getShippingFees()+"", true));
		order_snapshot.put("totalCartDiscount", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getTotalCartDiscount()+"", true));
		order_snapshot.put("totalShippingDiscount", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getTotalShippingDiscount()+"", true));
		
		if(cart.getGrandTotalRecurringMap() != null)
		{
			JSONArray jArr = new JSONArray();
			for(String k : cart.getGrandTotalRecurringMap().keySet())
			{
				JSONObject jObj = new JSONObject();
				jObj.put("frequency", k);
				jObj.put("total_amount_fmt", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotalRecurringMap().get(k)+"", false));
				jObj.put("total_amount", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotalRecurringMap().get(k)+"", true));
				jArr.put(jObj);
			}
			order_snapshot.put("grandTotalRecurringMap", jArr);
		}
		
		if(cart.getGrandTotalRecurringWTMap() != null)
		{
			JSONArray jArr = new JSONArray();
			for(String k : cart.getGrandTotalRecurringWTMap().keySet())
			{
				JSONObject jObj = new JSONObject();
				jObj.put("frequency", k);
				jObj.put("total_amount_fmt", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotalRecurringWTMap().get(k)+"", false));				
				jObj.put("total_amount", PortalHelper.formatPrice(priceformatter, roundto, showdecimals, cart.getGrandTotalRecurringWTMap().get(k)+"", true));				
				jArr.put(jObj);
			}
			order_snapshot.put("grandTotalRecurringWTMap", jArr);
		}
		
		if(extraOrderInfo != null)
		{
			for(String _key : extraOrderInfo.keySet())
			{
				order_snapshot.put(PortalHelper.parseNull(_key), PortalHelper.parseNull(extraOrderInfo.get(_key)));
			}
		}
		return order_snapshot;
	}
	
	//by default we always load normal cart
	public static String getCartSessionId(HttpServletRequest request)
	{
		return getCartSessionId(request, PortalHelper.parseNull(request.getParameter("cartType")).toLowerCase());
	}
		
	public static String getCartSessionId(HttpServletRequest request, String type)
	{
		Cookie[] theCookies = request.getCookies();
		if(theCookies != null) 
		{			
			type = PortalHelper.parseNull(type).toLowerCase();
			if(type.length() == 0) type = Type.NORMAL;

			String cookieName = getCookieName(type);
			
			for (Cookie cookie : theCookies) 
			{				
				if(cookie.getName().equals(cookieName)) 
				{
					return cookie.getValue();
				}
			}
		}
		return "";
	}

	public static String getCartMenuUuid(HttpServletRequest request)
	{
		String muid = PortalHelper.parseNull(request.getParameter("muid"));
		if(muid.length() > 0)
		{
			return muid;
		}
		else
		{
			Cookie[] theCookies = request.getCookies();
			if(theCookies != null) 
			{
				String menuCookieName = GlobalParm.getParm("CART_COOKIE").replaceAll("CartItems","")+"MenuUuid";
				for (Cookie cookie : theCookies) 
				{				
					if(cookie.getName().equals(menuCookieName)) 
					{
						try {
							return URLDecoder.decode(cookie.getValue(), "UTF-8");
						} catch (Exception e) { return ""; }					
					}
				}
			}
		}
		return "";
	}	
	
	public static JSONObject getAdditionalInfoFieldObj(Cart cart, String sectionName, String fieldName)
	{
		JSONObject jField = null;
		if(PortalHelper.parseNull(cart.getProperty("additional_info")).length() > 0)
		{
			try
			{
				JSONObject jAddInfo = new JSONObject(PortalHelper.parseNull(cart.getProperty("additional_info")));
				if(jAddInfo.has("sections"))
				{
					for(int it=0;it<jAddInfo.getJSONArray("sections").length();it++)
					{
						if(PortalHelper.parseNull(jAddInfo.getJSONArray("sections").getJSONObject(it).getString("name")).equals(sectionName))
						{
							JSONArray jFields = jAddInfo.getJSONArray("sections").getJSONObject(it).getJSONArray("fields");
							for(int ft=0;ft<jFields.length();ft++)
							{
								if(fieldName.equals(PortalHelper.parseNull(jFields.getJSONObject(ft).getString("name"))))
								{
									jField = jFields.getJSONObject(ft);
									break;
								}
							}
						}
					}
				}
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}
		return jField;
	}
	
	public static String getAdditionalInfoFieldType(Cart cart, String sectionName, String fieldName)
	{
		try
		{
			JSONObject jField = getAdditionalInfoFieldObj(cart, sectionName, fieldName);
			if(jField != null && jField.has("type"))
			{
				return PortalHelper.parseNull(jField.getString("type"));
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return null;
	}
	
	public static String getAdditionalInfoFieldSingleValue(Cart cart, String sectionName, String fieldName)
	{
		try
		{
			JSONObject jField = getAdditionalInfoFieldObj(cart, sectionName, fieldName);
			if(jField != null && jField.has("value") && jField.getJSONArray("value").length() > 0)
			{
				if("file".equalsIgnoreCase(jField.getString("type")))
				{
					JSONArray jValues = jField.getJSONArray("value");
					if(jValues != null && jValues.length() > 0) 
					{
						return PortalHelper.parseNull(jValues.getJSONObject(0).getString("filename"));
					}				
				}
				else
				{
					JSONArray jValues = jField.getJSONArray("value");
					if(jValues != null && jValues.length() > 0) return PortalHelper.parseNull(jValues.getString(0));
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return null;
	}
	
	public static List<String> getAdditionalInfoFieldValues(Cart cart, String sectionName, String fieldName)
	{
		List<String> values = null;
		try
		{			
			JSONObject jField = getAdditionalInfoFieldObj(cart, sectionName, fieldName);
			if(jField != null && jField.has("value") && jField.getJSONArray("value").length() > 0)
			{
				
				if("file".equalsIgnoreCase(jField.getString("type")))
				{
					JSONArray jValues = jField.getJSONArray("value");
					if(jValues != null && jValues.length() > 0) 
					{
						values = new ArrayList<>();
						for(int i=0;i<jValues.length();i++)
						{
							values.add(PortalHelper.parseNull(jValues.getJSONObject(i).getString("filename")));
						}
					}				
				}
				else
				{
					JSONArray jValues = jField.getJSONArray("value");
					if(jValues != null && jValues.length() > 0) 
					{
						values = new ArrayList<>();
						for(int i=0;i<jValues.length();i++)
						{
							values.add(PortalHelper.parseNull(jValues.getString(i)));
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return values;
	}
	
	public static boolean isKycRequired(Contexte Etn, String siteid)
	{
		Set rs = Etn.execute("select is_active from idcheck_configurations where site_id="+escape.cote(siteid));		
		if(rs.next()){
			if(PortalHelper.parseNull(rs.value("is_active")).equals("1")) return true;
			return false;
		} 
		return false;
	}

	public static boolean canTryKyc(Contexte Etn, String cartId)
	{
		Set rs = Etn.execute("select * from cart where idnow_tries <=3 AND idnow_last_try_ts > NOW() - INTERVAL 24 HOUR AND id="+escape.cote(cartId));		
		if(rs.next()){
			if(PortalHelper.parseNull(rs.value("id")).length()>0) return true;
			return false;
		} 
		return false;
	}
	
	public static boolean isKycCompleted(Contexte Etn, String cartid)
	{
		Set rs = Etn.execute("SELECT * FROM idnow_sessions where resp_timestamp > NOW() - INTERVAL 24 HOUR AND uuid = (Select idnow_uuid from cart where id ="+escape.cote(cartid)+" )");
		if(rs.next())
		{
			return "success".equalsIgnoreCase(rs.value("status"));
		}
		
		return false;
	}
	
	public static String getKycStatus(Contexte Etn, String cartid)
	{
		Set rs = Etn.execute("SELECT * FROM idnow_sessions where resp_timestamp > NOW() - INTERVAL 24 HOUR AND uuid = (Select idnow_uuid from cart where id = "+escape.cote(cartid)+" )");
		if(rs.next())
		{
			return PortalHelper.parseNull(rs.value("status"));
		}
		
		return "";
	}
	
	public static boolean cartHasProduct(Contexte Etn, HttpServletRequest request, Cart cart) throws Exception
	{
		boolean hasProduct = false;
		for(CartItem cItem : cart.getItems())
		{
			//if("product".equals(cItem.getVariant().getProductType()) || "simple_product".equals(cItem.getVariant().getProductType()) || "configurable_product".equals(cItem.getVariant().getProductType())) 
			if(PortalHelper.isProduct(cItem.getVariant().getProductType())) 
			{
				hasProduct = true;
				break;
			}
			else
			{
				ProductVariant variant = cItem.getVariant();
				JSONArray comewith = CommonPrice.getComewith(Etn, request, variant.getVariantId(), cart.getLangColumnPrefix(), cart.getLangId(), cItem.getProperty("comewith_excluded"), false, cart.getMenuId(), 1, cItem.getProperty("comewith_variant_id"));
				if(comewith != null && comewith.length() > 0)
				{
					for(int i=0; i<comewith.length(); i++)
					{
						//if("product".equals(comewith.getJSONObject(i).getJSONObject("variant").optString("productType","")))
						if(PortalHelper.isProduct(comewith.getJSONObject(i).getJSONObject("variant").optString("productType","")))
						{
							hasProduct = true;
							break;
						}
					} 
				}
				
				if(hasProduct) break;
			}
		}
		return hasProduct;
	}
}