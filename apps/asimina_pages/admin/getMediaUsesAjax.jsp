<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape,java.util.Arrays, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, com.sun.xml.internal.bind.v2.runtime.reflect.opt.Const"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>


<%
    int status=0;
    JSONObject respObj= new JSONObject();
    JSONArray dataArray = new JSONArray();
    String fileId = request.getParameter("file_id");

    try{
        Set rsString =Etn.execute("SELECT file_id,file_name,type,GROUP_CONCAT(used_at) as used_at FROM media_records WHERE file_id="+escape.cote(fileId)+" GROUP BY type");
        while(rsString.next()){
            JSONObject curObj= new JSONObject();
            for(String colName:rsString.ColName){
                curObj.put(colName.toLowerCase(),rsString.value(colName));
            }
            dataArray.put(curObj);
        }

    }catch (Exception e){
        status=1;
    }
    respObj.put("files",dataArray);
    respObj.put("status",status);
    out.write(respObj.toString());
%>