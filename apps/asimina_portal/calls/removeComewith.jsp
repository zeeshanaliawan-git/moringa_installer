<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.sql.escape,com.google.gson.Gson, java.util.*, javax.servlet.http.Cookie"%>
<%@ page import="java.io.*"%>


<%!

	String parseNull(Object o) 
	{
		if( o == null )
			return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase()))
			return("");
		else
			return(s.trim());
	}


%>

<%
	String cart_item_id = parseNull(request.getParameter("cart_item_id"));
	String comewith_id = parseNull(request.getParameter("comewith_id"));
	
	Set rsCartItems = Etn.execute("select * from cart_items where id="+escape.cote(cart_item_id));
	rsCartItems.next();
	if(!rsCartItems.value("comewith_excluded").equals("")) comewith_id = rsCartItems.value("comewith_excluded")+","+comewith_id;
	
	Etn.executeCmd("update cart_items set comewith_excluded="+escape.cote(comewith_id)+" where id="+escape.cote(cart_item_id));
        
%>
{"status":0}