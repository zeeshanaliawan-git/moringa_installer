<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.*" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp" %>
<%
    String action = parseNull(request.getParameter("action"));
    String batchId = parseNull(request.getParameter("batch_id"));
    String message="";
    JSONObject resp = new JSONObject();
    try{
        String query="";
        if(action.equalsIgnoreCase("skipp")){
            query="select skipped_items as item from batch_imports where id="+escape.cote(batchId);
        }else if(action.equalsIgnoreCase("update")){
            query="select updated_items as item from batch_imports where id="+escape.cote(batchId);
        }

        Set rs=Etn.execute(query);

        if(rs!=null && rs.next()){ 
            message=rs.value("item");
        }

        if(message.length()>0){
            message=message.replace("#","<br>");
        }else{
            message="No data available.";
        }
        
        resp.put("message",message);
        resp.put("status","true");
    }catch(Exception e){
        e.printStackTrace();
        resp.put("status","false");
        resp.put("message",e.getMessage());
    }
    out.write(resp.toString());
%>