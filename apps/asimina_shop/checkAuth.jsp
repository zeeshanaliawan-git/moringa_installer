<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,org.json.JSONObject,com.etn.sql.escape"%>
<%@ page import="org.apache.commons.codec.binary.Hex,org.apache.commons.codec.binary.Base32,java.security.SecureRandom,com.etn.asimina.util.TOTP"%>


<%!
    String parseNull(Object o) {
        if (o == null) return ("");
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }
%>

<%
    int status = 0;
    String message= "";

    try{
        String userName = parseNull(request.getParameter("username"));

        if(userName.length()>0){
            Set rs = Etn.execute("select is_two_auth_enabled from login where name="+escape.cote(userName));
            if(rs.next()){
                if(parseNull(rs.value("is_two_auth_enabled")).equals("1")){
                    status=0;
                }else{
                    status=1;
                    message ="Auth not enabled";
                }
            }else{
                status=1;
                message = "Invalid username.";
            }
           

        }else{
            status = 1;
            message = "User Name not present.";
        }
    }catch(Exception e){
        status=1;
        message=e.getMessage();
    }

    JSONObject resp = new JSONObject();
    resp.put("status",status);
    resp.put("message",message);

    out.write(resp.toString());
%>



