<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,org.json.JSONObject,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, com.etn.asimina.util.UIHelper, com.etn.asimina.util.BlockedUserConfig"%>
<%@ page import="org.apache.commons.codec.binary.Hex,org.apache.commons.codec.binary.Base32,java.security.SecureRandom,com.etn.asimina.util.TOTP"%>


<%!
    String getKey(){
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[20];
        random.nextBytes(bytes);
        Base32 base32 = new Base32();
        return base32.encodeToString(bytes);
    }
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

    int parseInt(Object o) {
        return parseInt(o, 0);
    }

    int parseInt(Object o, int defaultValue) {
        String s = parseNull(o);
        if (s.length() > 0) {
            try {
                return Integer.parseInt(s);
            }
            catch (Exception e) {
                return defaultValue;
            }
        }
        else {
            return defaultValue;
        }
    }

    double parseDouble(Object o) {
        return parseDouble(o, 0.0);
    }

    double parseDouble(Object o, double defaultValue) {
        String s = parseNull(o);
        if (s.length() > 0) {
            try {
                return Double.parseDouble(s);
            }
            catch (Exception e) {
                return defaultValue;
            }
        }
        else {
            return defaultValue;
        }
    }
%>

<%
    int status = 0;
    String message= "";

    try{
        String action = parseNull(request.getParameter("action"));
        String userName = parseNull(request.getParameter("username"));
        String commonDb = GlobalParm.getParm("COMMONS_DB")+".";
        String key="";

        if(action.equalsIgnoreCase("set")){

            String query="";

            if(userName.equalsIgnoreCase("all")){
                Set rs = Etn.execute("select name,secret_key from login");
                while(rs.next()){

                    String secretKey = parseNull(rs.value("secret_key"));
                    String name = parseNull(rs.value("name"));
                    
                    if(secretKey.length() > 0){
                        query="update login set is_two_auth_enabled=1,send_email=1 where name="+escape.cote(name);
                    }else{
                        key = getKey();
                        System.out.println("Key For single=="+key);
                        query="Update login set is_two_auth_enabled=1,send_email=1,secret_key="+escape.cote(key)+" where name="+escape.cote(name);
                    }
                    Etn.executeCmd(query);
                }

            }else{
                Set rs = Etn.execute("select secret_key from login where name="+escape.cote(userName));
                if(rs.next()){

                    String secretKey = parseNull(rs.value("secret_key"));
                    
                    if(secretKey.length() > 0){
                        query="update login set is_two_auth_enabled=1,send_email=1 where name="+escape.cote(userName);
                    }else{
                        key = getKey();
                        System.out.println("Key For single=="+key);
                        query="Update login set is_two_auth_enabled=1,send_email=1,secret_key="+escape.cote(key)+" where name="+escape.cote(userName);
                    }
                    Etn.executeCmd(query);
                }
            }

            Set rs1 = Etn.execute("select val from "+commonDb+"config where code ='SELFCARE_SEMAPHORE'");
            if(rs1!=null && rs1.next()){
                Etn.execute("Select semfree("+escape.cote(rs1.value("val"))+")");
            }

        }else{
            if(!userName.equalsIgnoreCase("all")){
                Etn.executeCmd("Update login set is_two_auth_enabled=0,send_email=0 where name="+escape.cote(userName));
            }else{
                Etn.executeCmd("Update login set is_two_auth_enabled=0,send_email=0");
            }
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



