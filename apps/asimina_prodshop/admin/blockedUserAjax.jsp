<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.asimina.util.BlockedUserConfig, org.json.JSONArray,org.json.JSONObject, com.etn.asimina.util.UIHelper"%>
<%@ include file="../common.jsp" %>
<%
    String blockedType =  parseNull(request.getParameter("blockType")); //user or ip
    String ipOrUsername =  parseNull(request.getParameter("ipOrUsername"));

    // user account
    String tableName = "user_login_tries";
    String selectCol = "username";
    String nAttempts =  BlockedUserConfig.instance.userConfig.get("nAttempts");
    String blockTime =  BlockedUserConfig.instance.userConfig.get("blockTime");
    String blockTimeUnit =  BlockedUserConfig.instance.userConfig.get("blockTimeUnit");


    if(blockedType.equals("ip")){
        selectCol = "ip";
        tableName = "login_tries";
        nAttempts =  BlockedUserConfig.instance.ipConfig.get("nAttempts");
        blockTime =  BlockedUserConfig.instance.ipConfig.get("blockTime");
        blockTimeUnit =  BlockedUserConfig.instance.ipConfig.get("blockTimeUnit");
    }

    // unblock ip/account
    if(!ipOrUsername.equals("")){

        Etn.executeCmd("DELETE  FROM "+tableName+" WHERE "+selectCol+" = "+escape.cote(ipOrUsername));
    }
    //get unblock user/ip
    Set rs =  Etn.execute("SELECT *  FROM "+tableName+"  WHERE attempt >= "+escape.cote(nAttempts)+" AND adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseNullInt(blockTime), blockTimeUnit)))+" minute) > now()");

    JSONArray returnArray = new JSONArray();
    while(rs.next()){
        JSONObject obj = new JSONObject();
        System.out.println(rs.value("username"));
        obj.put("ipOrUsername",rs.value(0));
        obj.put("attempts",rs.value("attempt"));
        obj.put("lastAttempt",rs.value("tm"));
        returnArray.put(obj);
    }

    out.write(returnArray.toString());
%>