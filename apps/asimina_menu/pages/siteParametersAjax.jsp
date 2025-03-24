<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm,java.util.*,org.json.JSONObject, com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.asimina.util.ActivityLog, com.etn.asimina.beans.Language,com.etn.asimina.util.SiteHelper"%>


<%
    String SHOP_DB = "";

    String process = request.getParameter("process");
    String type = request.getParameter("type");

    JSONObject rspObj = new JSONObject();

    if(type.equals("prod")){
        SHOP_DB = GlobalParm.getParm("PROD_SHOP_DB") + ".";
    }else{
        SHOP_DB = GlobalParm.getParm("SHOP_DB") + ".";
    }

    Set rs = Etn.execute("select distinct phase from "+SHOP_DB+"phases where process = "+escape.cote(process));

    List<String> resp = new ArrayList<>();

    while(rs.next()) {
        resp.add(rs.value("phase"));
    }
    rspObj.put("resp",resp);
    out.write(rspObj.toString());

%>