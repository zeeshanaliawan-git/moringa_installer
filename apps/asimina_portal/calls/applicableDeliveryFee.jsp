<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="java.io.*"%>
<%@ page import="java.lang.reflect.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm,com.etn.asimina.util.*,com.etn.asimina.cart.*,com.etn.asimina.beans.*,com.etn.util.Logger,org.json.*"%>

<%@ include file="../cart/lib_msg.jsp"%>
<%@ include file="../cart/common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="../cart/priceformatter.jsp"%>

<%
    
    String delivery_method = parseNull(request.getParameter("delivery_method"));
    String delivery_type = parseNull(request.getParameter("delivery_type"));
    String _datowncity = parseNull(request.getParameter("_datowncity"));
    String _dapostcode = parseNull(request.getParameter("_dapostcode"));
    String _daline1 = parseNull(request.getParameter("_daline1"));
    String _daline2 = parseNull(request.getParameter("_daline2"));
    String ___loadedsiteid = parseNull(request.getParameter("site_id"));
    String cartSessionId = CartHelper.getCartSessionId(request);

    double applicableHomeDeliveryShippingFees = 0.0;

    JSONObject json = new JSONObject();
    JSONArray deliv_types = new JSONArray();

    Cart cart = CartHelper.loadCart(Etn, request, cartSessionId, ___loadedsiteid, CartHelper.getCartMenuUuid(request));

    String defaultcurrency = cart.getDefaultCurrency();
    String priceformatter = cart.getPriceFormatter();
    String roundto = cart.getRoundTo();
    String showdecimals = cart.getShowDecimals();
	boolean isDeliveryType = false;
    String qry = "select price, displayName, subType from "+GlobalParm.getParm("CATALOG_DB")+".delivery_methods where site_id = " + escape.cote(___loadedsiteid) + " AND enable=1 AND method="+escape.cote(delivery_method);
    String tmpqry = qry;

    if(delivery_method.equalsIgnoreCase("home_delivery"))
	{
        String delivQry = "Select distinct(delivery_type) from "+GlobalParm.getParm("CATALOG_DB")+".deliveryfees where site_id="+escape.cote(___loadedsiteid);
		String whereclause = "";
        if( _datowncity.length() > 0 ) 
		{ 
			whereclause += " (dep_type='city' AND dep_value="+escape.cote(_datowncity)+") ";
		}
        if( _dapostcode.length() > 0 ) 
		{
			if(whereclause.length() > 0) whereclause += " OR ";
			whereclause += " (dep_type='postal' AND dep_value="+escape.cote(_dapostcode)+") ";
		}
        if( _daline2.length() > 0 ) 
		{ 
			if(whereclause.length() > 0) whereclause += " OR ";
			whereclause += " (dep_type='daline2' AND dep_value="+escape.cote(_daline2)+") ";
		}
		
		if(whereclause.length() > 0)
		{
			delivQry += " AND ( " + whereclause + " ) ";
		}
        
		Logger.info("applicableDeliveryFee.jsp","DELIVQRY : " + delivQry);
		
	    Set delivRs=Etn.execute(delivQry);
		
        if(delivRs.rs.Rows!=0)
		{
            String orclause = "";
            while(delivRs.next())
			{
                if(parseNull(delivRs.value("delivery_type")).length()>0)
                {
                    if(delivery_type.equalsIgnoreCase(parseNull(delivRs.value("delivery_type")))) isDeliveryType=true;
                    
                    deliv_types.put(parseNull(delivRs.value("delivery_type")));
					if(orclause.length() > 0) orclause += " OR ";
                    orclause += " subType="+escape.cote(parseNull(delivRs.value("delivery_type")));
                }
            }

			if(orclause.length() > 0)
			{
				qry += " AND ( " + orclause + " ) ";
			}
            qry += " order by price, orderSeq";
        }
		else
		{
            isDeliveryType =true;
            Set rs3 = Etn.execute(tmpqry);
            while(rs3.next())
			{
                deliv_types.put(parseNull(rs3.value("subType")));
			}
        }
    }
	else
	{
        isDeliveryType =true;
        delivery_type="";
        Set rs3 = Etn.execute(tmpqry);
        while(rs3.next())
		{
            deliv_types.put(parseNull(rs3.value("subType")));
        }
    }

    if(isDeliveryType)
        applicableHomeDeliveryShippingFees = CartHelper.getDeliveryFee(Etn, request, cart.getItems(), cart.getProperty("site_id"), delivery_method, delivery_type, _datowncity, _dapostcode, _daline1, _daline2);
    else{
        if(deliv_types.length()>0)
            applicableHomeDeliveryShippingFees = CartHelper.getDeliveryFee(Etn, request, cart.getItems(), cart.getProperty("site_id"), delivery_method, deliv_types.get(0).toString(), _datowncity, _dapostcode, _daline1, _daline2);
        else
            applicableHomeDeliveryShippingFees = CartHelper.getDeliveryFee(Etn, request, cart.getItems(), cart.getProperty("site_id"), delivery_method, delivery_type, _datowncity, _dapostcode, _daline1, _daline2);
    }
	
	Logger.info("applicableDeliveryFee.jsp","QRY : " + qry);
    Set rs = Etn.execute(qry);

    if(rs!=null && rs.next() && rs.rs.Rows>0)
        json.put("display_name",rs.value("displayName"));

	//apply promo code if applicable
	double discountValue = 0;
	if(PortalHelper.parseNull(cart.getProperty("promo_code")).length() > 0 && cart.hasPromoError() == false)
	{
		Set rsP = Etn.execute("select cp.discount_type, cp.discount_value "+
					" from "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion_coupon cpc "+
					" join "+GlobalParm.getParm("CATALOG_DB")+".cart_promotion cp on cp.id = cpc.cp_id and cp.site_id = "+escape.cote(cart.getProperty("site_id"))+" and cp.element_on = 'shipping_fee' "+
					" where cpc.coupon_code = "+escape.cote(PortalHelper.parseNull(cart.getProperty("promo_code"))));
		if(rsP.next())
		{
			if("fixed".equals(rsP.value("discount_type")))
			{
				discountValue = PortalHelper.parseNullDouble(rsP.value("discount_value"));
			}
			else
			{
				discountValue = (applicableHomeDeliveryShippingFees * PortalHelper.parseNullDouble(rsP.value("discount_value"))/100);
			}
			discountValue = PortalHelper.parseNullDouble(PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), discountValue+"", true));
			
			applicableHomeDeliveryShippingFees = applicableHomeDeliveryShippingFees - discountValue;
			if(applicableHomeDeliveryShippingFees < 0) applicableHomeDeliveryShippingFees = 0;
		}		
	}

    Logger.info("applicableDeliveryFee","delivery_method:::"+delivery_method);
    Logger.info("applicableDeliveryFee","delivery_type:::"+delivery_type);
    Logger.info("applicableDeliveryFee","_datowncity:::"+_datowncity);
    Logger.info("applicableDeliveryFee","_dapostcode:::"+_dapostcode);
    Logger.info("applicableDeliveryFee","_daline1:::"+_daline1);
    Logger.info("applicableDeliveryFee","_daline2:::"+_daline2);
    Logger.info("applicableDeliveryFee","applicableHomeDeliveryShippingFees: " + applicableHomeDeliveryShippingFees);
    Logger.info("applicableDeliveryFee","discountValue: " + discountValue);

    json.put("method",delivery_method);
    json.put("type",delivery_type);
    json.put("deliv_types",deliv_types);
    json.put("discount_value",discountValue);
    json.put("discount_value_fmt",PortalHelper.formatPrice(cart.getPriceFormatter(), cart.getRoundTo(), cart.getShowDecimals(), discountValue+"", false));

    if(applicableHomeDeliveryShippingFees == 0.0){
        json.put("delivery_fee",libelle_msg(Etn, request, "Gratuit"));
    }
    else{
        json.put("delivery_fee",PortalHelper.getCurrencyPosition(
                    Etn,
                    request,
                    ___loadedsiteid,
                    cart.getProperty("lang"),
					formatPrice(priceformatter, roundto, showdecimals, ""+applicableHomeDeliveryShippingFees),
					defaultcurrency));	
    }

    out.write(json.toString());  
%>
