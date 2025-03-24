<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, com.etn.util.Base64"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="java.util.regex.Matcher"%>

<%@ page import="com.etn.asimina.authentication.*"%>

<%@ include file="../lib_msg.jsp"%>

<%!
    String parseNull(Object o)
    {
        if( o == null ) return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase())) return("");
        else return(s.trim());
    }
    boolean validatePass(String password)
    {
        String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{8,})";
        Pattern r = Pattern.compile(pattern);
        Matcher m = r.matcher(password);
        if (m.find())
            return true;
        else
            return false;
    }

%>


<%
    String ftoken = parseNull(request.getParameter("ftoken"));
    String password = parseNull(request.getParameter("password"));
    String confirmPassword = parseNull(request.getParameter("confirmPassword"));
    String muid = parseNull(request.getParameter("muid"));

    com.etn.lang.ResultSet.Set rsMenu = Etn.execute("select site_id from site_menus where menu_uuid = " + com.etn.sql.escape.cote(muid));
    if(rsMenu != null && rsMenu.next())
    {
        String siteid = rsMenu.value("site_id");

        if(ftoken.length() == 0)
        {
            out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Invalid token provided")+"\"}");
            return;
        }
        if(password.length() == 0)
        {
            out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "You must provide a password")+"\"}");
            return;
        }
        if(!password.equals(confirmPassword)){
            out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Le mot de passe ne correspond pas")+"\"}");
            return;
        }
        if(!validatePass(password)){
            out.write("{\"status\":\"error\",\"msg\":\""+ libelle_msg(Etn, request, "Le mot de passe doit contenir une lettre majuscule, une lettre minuscule, un chiffre et doit comporter 8 caractères")+"\"}");
            return;
        }

        Set rs = Etn.execute("select * from clients where forgot_pass_token_expiry >= now() and forgot_pass_token = " + escape.cote(ftoken));
        if(rs.next())
        {
            AsiminaAuthenticationHelper helper = new AsiminaAuthenticationHelper(Etn, siteid,com.etn.beans.app.GlobalParm.getParm("CLIENT_PASS_SALT"));
            AsiminaAuthentication auth = helper.getAuthenticationObject();
            AsiminaAuthenticationResponse resp = auth.forceChangePassword(rs.value("username"), password);
            if(resp.isDone())
            {
                Etn.executeCmd("update clients set forgot_pass_token = null, forgot_pass_token_expiry = null where id = " + escape.cote(rs.value("id")));
                out.write("{\"status\":\"success\",\"msg\":\""+libelle_msg(Etn, request, "Password updated successfully")+"\"}");
            }
            else
            {
                out.write("{\"status\":4,\"msg\":\""+libelle_msg(Etn, request, "Impossible de mettre à jour le mot de passe. Réessayer")+"\"}");
            }
        }
        else
        {
            out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Invalid token provided. The token may have expired or used already")+"\"}");
        }
    }
    else
    {
        out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Invalid menu id provided")+"\"}");
    }

%>
