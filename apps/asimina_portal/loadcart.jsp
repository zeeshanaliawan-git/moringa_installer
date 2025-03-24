<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.asimina.cart.*, com.etn.asimina.beans.*, com.etn.sql.escape, com.etn.util.Base64, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, java.net.*, java.util.*"%>

<%@ include file="../lib_msg.jsp"%>

<%!
	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}


        int parseNullInt(Object o)
        {
            if (o == null) return 0;
            String s = o.toString();
            if (s.equals("null")) return 0;
            if (s.equals("")) return 0;
            return Integer.parseInt(s);
        }

%>

<%
	response.setHeader("X-Frame-Options","deny");
	String muid = parseNull(request.getParameter("muid"));

	String json = "[]";
	String session_id = CartHelper.getCartSessionId(request);
	String site_id="";
	
	if(muid.trim().length() > 0)
	{
		Set rs = Etn.execute("select * from site_menus where menu_uuid = " + escape.cote(muid));
		if(rs.next())
		{
			set_lang(parseNull(rs.value("lang")), request, Etn);
			site_id = rs.value("site_id");
		}
		else return;
	}
        
	Cart cart = CartHelper.loadCart(Etn, request, session_id, site_id, muid);

	//we have a case where the orange money payment was done which sets the order_uuid in cart table
	//and the user did not go back to completion.jsp which actually cleansup the completed cart
	//this lead to a bug where same cart was used by the user next time and after the next payment new 
	//order was not inserted as the cart table already had order_uuid filled and the CartHelper class checks
	//if order_uuid already exists in cart then not to insert new order which is a valid case
	//so we are going to cleanup the cart here in case order_uuid is already filled which in ideal conditions should not happen
	if(cart != null && parseNull(cart.getProperty("order_uuid")).length() > 0)
	{
		com.etn.util.Logger.error("****************************************************************************************");
		com.etn.util.Logger.error("loadcart.jsp","Order uuid is already filled for cart which means this cart was successfully checked-out but user did not go back to completion page after making payment on external site. We must cleanup the cart now");
		com.etn.util.Logger.error("****************************************************************************************");
		CartHelper.cleanup(Etn, cart);
		cart = CartHelper.loadCart(Etn, request, session_id, site_id, muid);
	}
	
	int cartCount = 0;
	if(cart != null) 
	{
		for(CartItem item : cart.getItems())
		{
			cartCount += parseNullInt(item.getProperty("quantity"));
		}
	}
	
	out.write("{\"count\":"+cartCount+",\"carturl\":\""+parseNull(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK"))+"cart.jsp?muid="+muid+"\"}");
%>