<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape,com.etn.beans.app.GlobalParm, java.util.*, java.text.*, org.json.*"%>
<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%
    String STATUS_SUCCESS = "SUCCESS", STATUS_ERROR = "ERROR";
    String message = "";
    String status = STATUS_ERROR;
    String requestType = parseNull(request.getParameter("requestType"));

    Object data = null;

    String SHOP_DB = GlobalParm.getParm("SHOP_DB");

    if("updateTxnId".equals(requestType)){

        try{
            String id = parseNull(request.getParameter("id"));
            String paymentId = parseNull(request.getParameter("paymentId"));
            String txnId = parseNull(request.getParameter("txnId"));



            String q = "SELECT * FROM "+SHOP_DB+".payments_ref WHERE id = "+ escape.cote(id);
            Set rs = Etn.execute(q);

            if(rs.next()){
                if( "paypal".equals(rs.value("payment_method"))
                    && paymentId.equals(rs.value("payment_id")) ){

                    q = "UPDATE "+SHOP_DB+".payments_ref "
                        + " SET payment_txn_id = " + escape.cote(txnId)
                        + " , payment_status = 'INITIATED'"
                        + "  WHERE id = "+ escape.cote(id);
                    Etn.executeCmd(q);
                }
                else{
                    throw new Exception("Error: Invalid credentials.");
                }
            }
            else{
                throw new Exception("Error: Invalid credentials.");
            }

            status = STATUS_SUCCESS;
            message = "";

        }
        catch(Exception ex){
            message += ex.getMessage();
            status = STATUS_ERROR;
            ex.printStackTrace();
        }

    }
    else if("verifyAuth".equals(requestType)){

        try{
            String id = parseNull(request.getParameter("id"));
            String paymentId = parseNull(request.getParameter("paymentId"));
            String txnId = parseNull(request.getParameter("txnId"));
            double totalPrice = Double.parseDouble(parseNull(request.getParameter("totalPrice")));
            String orderId = parseNull(request.getParameter("orderId"));

            String q = "SELECT * FROM "+SHOP_DB+".payments_ref WHERE id = "+ escape.cote(id);
            Set rs = Etn.execute(q);

            if(rs.next()){
                double total_priceDb = Double.parseDouble(rs.value("total_price"));
                if( "paypal".equals(rs.value("payment_method"))
                    && paymentId.equals(rs.value("payment_id"))
                    && txnId.equals(rs.value("payment_txn_id"))
                    && totalPrice == total_priceDb
                    ){

                    q = "UPDATE "+SHOP_DB+".payments_ref "
                        + " SET paypal_order_id = "+escape.cote(orderId)+", payment_status = 'AUTHENTICATED'"
                        + "  WHERE id = "+ escape.cote(id);
                    Etn.executeCmd(q);
                }
                else{
                    throw new Exception("Error: Invalid credentials.");
                }
            }
            else{
                throw new Exception("Error: Invalid credentials.");
            }

            status = STATUS_SUCCESS;
            message = "";

        }
        catch(Exception ex){
            message += ex.getMessage();
            status = STATUS_ERROR;
            ex.printStackTrace();
        }

    }
    else if("confirmPayment".equals(requestType)){

        try{
            String id = parseNull(request.getParameter("id"));
            String paymentId = parseNull(request.getParameter("paymentId"));
            String txnId = parseNull(request.getParameter("txnId"));
            double totalPrice = Double.parseDouble(parseNull(request.getParameter("totalPrice")));
            String paymentState = parseNull(request.getParameter("paymentState"));
			String orderId = parseNull(request.getParameter("orderId"));
			
            if(!"approved".equals(paymentState)){
                throw new Exception("Error: Invalid credentials.");
            }


            String q = "SELECT * FROM "+SHOP_DB+".payments_ref WHERE id = "+ escape.cote(id);
            Set rs = Etn.execute(q);

            if(rs.next()){
                double total_priceDb = Double.parseDouble(rs.value("total_price"));
                if( "paypal".equals(rs.value("payment_method"))
                    && paymentId.equals(rs.value("payment_id"))
                    && txnId.equals(rs.value("payment_txn_id"))
                    && totalPrice == total_priceDb
                    && "AUTHENTICATED".equals(rs.value("payment_status"))
                    )
				{

                    q = "UPDATE "+SHOP_DB+".payments_ref "
                        + " SET paypal_order_id = "+escape.cote(orderId)+", payment_status = 'SUCCESS', is_success = 1 "
                        + "  WHERE id = "+ escape.cote(id);
                    Etn.executeCmd(q);
                }
                else{
                    throw new Exception("Error: Invalid credentials.");
                }
            }
            else{
                throw new Exception("Error: Invalid credentials.");
            }

            status = STATUS_SUCCESS;
            message = "";

        }
        catch(Exception ex){
            message += ex.getMessage();
            status = STATUS_ERROR;
            ex.printStackTrace();
        }

    }

    if(data == null){
        data = new JSONObject();
    }

    response.setContentType("application/json");
    JSONObject json = new JSONObject();
    json.put("status",status);
    json.put("message",message);
    json.put("data",data);

    out.write(json.toString());
%>
