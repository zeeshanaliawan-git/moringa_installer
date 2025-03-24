<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map,java.util.List, com.etn.beans.app.GlobalParm"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>
<%!
	// public static String escapeDblCote(String str){
 //        return "\"" + str.replace("\"","\\\"") +"\"";
 //    }
%>
<%
	String STATUS_SUCCESS = "SUCCESS", STATUS_ERROR = "ERROR";
	String message = "";
    String status = STATUS_ERROR;
    String requestType = request.getParameter("requestType");
    StringBuffer data = new StringBuffer();

    if("orderPromotions".equalsIgnoreCase(requestType)){
            try{
                    String promoIds = parseNull(request.getParameter("promoIds"));

                    String promoIdList[] = promoIds.split(",");

                    if( promoIdList.length == 0 ){
                            throw new Exception("");
                    }

                    String q = "";
                    for(int i=0; i<promoIdList.length; i++){

                            q = "UPDATE promotions SET order_seq = " + (i+1)
                                    + " WHERE id = " + escape.cote(promoIdList[i]);

                            Etn.executeCmd(q);
                    }

                    status = STATUS_SUCCESS;
                    message = "";
            }
            catch(Exception ex){
                    status = STATUS_ERROR;
            }

    }

    if(data.length() == 0){
		data.append("\"\"");
	}

	response.setContentType("application/json");
  	out.write("{\"status\":\""+status+"\",\"message\":\""+message+"\",\"data\":"+data+"}");

%>
