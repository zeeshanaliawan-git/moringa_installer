<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.math.RoundingMode, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>


<%@ include file="lib_msg.jsp"%>
<%@ include file="commonprice.jsp"%>
<%@ include file="common.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>
<%        
        String json = parseNull(request.getParameter("json"));
        Gson gson = new Gson();
        Type stringObjectMap = new TypeToken<List<Object>>(){}.getType();
        List<Object> list = gson.fromJson(json, stringObjectMap);
        String errors = "";
        System.out.println(json+list.size());
		int cartCount= 0;
		int articlesCount=0;
        if(list != null && list.size() != 0)
        {
			org.json.JSONObject stockValidationsJson = com.etn.asimina.cart.CartHelper.validateStock(Etn, request, session_id, ___loadedsiteid);
			cartCount = stockValidationsJson.getInt("cartCount");
			articlesCount = stockValidationsJson.getInt("articlesCount");
			errors = com.etn.asimina.util.PortalHelper.parseNull(stockValidationsJson.optString("errors"));
        }
        HashMap<Integer, String> errorsMap = new HashMap<Integer, String>();
        if(!errors.equals("")){
            out.write("{\"status\" : \"NOK\", \"reason\" : \"The selected timeslot is not available\"}");
        }
        else{
            for(int i=0;i<list.size();i++){
                Map<String,Object> map = (Map)list.get(i);
                String client_key = parseNull(map.get("client_key"));
                /*String product_uuid = parseNull(map.get("id"));
                int qty = parseNullInt(map.get("qty"));
                String bt = parseNull(map.get("bt"));
                String installment_plan = parseNull(map.get("installment_plan"));
                List<Object> attributes = (List)map.get("attributes");*/
                String start_time = parseNull(map.get("start_time"));
                String date = parseNull(map.get("date"));
                /*String end_date = parseNull(map.get("end_date"));
                String slot_discount_type = parseNull(map.get("slot_discount_type"));
                double slot_discount_value = parseNullDouble(map.get("slot_discount_value"));*/

                String query = "UPDATE "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".order_items SET service_start_time="+escape.cote(start_time)+",service_date="+escape.cote(date)/*+",price="+escape.cote(totalPriceString)*/+" WHERE id="+escape.cote(client_key);
                System.out.println(query);
                int j = Etn.executeCmd(query);
                if(j>0){
                    out.write("{\"status\" : \"OK\", \"reason\" : \"Appointment Updated\"}");
                }
                else{
                    out.write("{\"status\" : \"NOK\", \"reason\" : \"Unexpected Error\"}");
                }
            }
        }
  %>
