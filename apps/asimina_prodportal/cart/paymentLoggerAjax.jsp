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
    String paymentRefId = parseNull(request.getParameter("paymentRefId"));
    String SHOP_DB = GlobalParm.getParm("SHOP_DB");

	if(paymentRefId.length() > 0){
		try{
			String q = " INSERT INTO "+SHOP_DB+".payment_log (payment_ref_id, payment_method, action, "
                        + " url, request, response, created_ts, created_by) VALUES ("
                        + escape.cote(paymentRefId)
                        + "," +  escape.cote(parseNull(request.getParameter("paymentMethod")))
                        + "," +  escape.cote(parseNull(request.getParameter("action")))
                        + "," +  escape.cote(parseNull(request.getParameter("url")))
                        + "," +  escape.cote(parseNull(request.getParameter("request")))
                        + "," +  escape.cote(parseNull(request.getParameter("response")))
                        + ", NOW(), " + escape.cote(""+Etn.getId()) + " ) " ;
			int id = Etn.executeCmd(q);

            if(id <= 0){
                message = "Error in inserting record in database.";
            }
			else{
			     status = STATUS_SUCCESS;
			}

		}
		catch(Exception ex){
			message += ex.getMessage();
			status = STATUS_ERROR;
			ex.printStackTrace();
		}

	}

	response.setContentType("application/json");
	JSONObject json = new JSONObject();
	json.put("status",status);
	json.put("message",message);

  	out.write(json.toString());
%>
