<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, com.etn.util.Base64, com.etn.beans.app.GlobalParm, com.etn.asimina.util.PortalHelper"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="java.util.regex.Matcher"%>

<%@ page import="com.etn.asimina.authentication.*"%>

<%@ include file="../clientcommon.jsp"%>

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

<%  String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";

    request.setAttribute("forced_menu", "0");

    if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
    {
        response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+  parseNull(request.getParameter("muid")));
        return;
    }

%>


<%@ include file="../headerfooter.jsp"%>

<%
    String errmsg = "";
    boolean done = false;
    String clientUuid = parseNull(request.getParameter("client_uuid"));
    //System.out.println("______________"+clientUuid);
    String sid = parseNull(request.getParameter("sid"));
    if(clientUuid.length() == 0)
    {
        response.sendRedirect("error.jsp");
        return;
    }

    Set rs = Etn.execute("select * from clients where client_uuid = " + escape.cote(clientUuid));
    if(rs.rs.Rows == 0)
    {
        response.sendRedirect("error.jsp");
        return;
    }

    rs.next();

    String siteId = null;
    String muid = request.getParameter("muid");
    Set rsSite = Etn.execute("select site_id from site_menus where menu_uuid = " + escape.cote(muid));
    if(rsSite != null && rsSite.next()){
        siteId = rsSite.value("site_id");
    }else{
        response.sendRedirect("error.jsp");
        return;
    }

    String username = rs.value("username");
    String updatePassword = parseNull(request.getParameter("updatePassword"));
    if(updatePassword.equals("1"))
    {
        String newpass = parseNull(request.getParameter("newPassword"));
        String confirmpass = parseNull(request.getParameter("confirmPassword"));
        if(!newpass.equals(confirmpass))
        {
            errmsg = libelle_msg(Etn, request, "Le nouveau mot de passe ne correspond pas à la confirmation du mot de passe");
        }
        else if(!validatePass(newpass)){
            errmsg = libelle_msg(Etn, request, "Le mot de passe doit contenir une lettre majuscule, une lettre minuscule, un chiffre et doit comporter 8 caractères");
        }
        else
        {
            AsiminaAuthenticationHelper helper = new AsiminaAuthenticationHelper(Etn, siteId,com.etn.beans.app.GlobalParm.getParm("CLIENT_PASS_SALT"));
            AsiminaAuthentication auth = helper.getAuthenticationObject();
            AsiminaAuthenticationResponse resp = auth.forceChangePassword(username, newpass);
            if(resp.isDone())
            {
                done = true;
            }
            else
            {
                errmsg = libelle_msg(Etn, request, "Some error occurred while saving password. Please try again");
            }
        }
    }

%>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
<%=_headhtml%>
    <link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">

    <title><%=libelle_msg(Etn, request, "Définir le mot de passe")%></title>

    <script type="text/javascript" src="../js/jquery.min.js"></script>

</head>
<body>
    <%=_headerHtml%>
    <div class="container">
        <h1 class='mt-2'><%=libelle_msg(Etn, request, "Définir le mot de passe")%></h1>
        <br>
        <% if(done) {%>
            <div class="alert alert-success" id='succdiv' role="alert"><%=libelle_msg(Etn, request, "Your password is updated successfully. You will be redirected to homepage in ")%><span id='timerspan'>5</span> <%= libelle_msg(Etn, request, "seconds")%> <%= libelle_msg(Etn, request, "or click")%>&nbsp;<a href='<%=request.getContextPath()%>/pages/updatepassword.jsp?client_uuid=<%=PortalHelper.escapeCoteValue(clientUuid)%>'><%=libelle_msg(Etn, request, "here")%></a></div>
        <% } %>
        <div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
        <form class="form-horizontal" autocomplete="off" id='passfrm' method='post' action='<%=request.getContextPath()%>/pages/updatepassword.jsp?muid=<%=PortalHelper.escapeCoteValue(parseNull(request.getParameter("muid")))%>&client_uuid=<%=PortalHelper.escapeCoteValue(clientUuid)%>' >
            <input type='hidden' name='updatePassword' value='1'>

            <div class='form-group row'>
                <label for='username' class='col-sm-3 control-label '><%=libelle_msg(Etn, request, "Utilisateur")%></label>
                <div class='col-sm-9'><input class='form-control' type='text' name='username' id='username' value='<%=parseNull(rs.value("username"))%>' readonly autocomplete='off' /></div>
            </div>
            <div class='form-group row'>
                <label for='passwd' class='col-sm-3 control-label '><%=libelle_msg(Etn, request, "Nouveau mot de passe")%></label>
                <div class='col-sm-9'><input class='form-control' type='password' name='newPassword' id='newPassword' value='' autocomplete='off' placeholder='<%=libelle_msg(Etn, request, "Nouveau mot de passe")%>' /></div>
            </div>
            <div class='form-group row'>
                <label for='passwd' class='col-sm-3 control-label '><%=libelle_msg(Etn, request, "Confirmez le mot de passe")%></label>
                <div class='col-sm-9'><input class='form-control' type='password' name='confirmPassword' id='confirmPassword' value='' autocomplete='off' placeholder='<%=libelle_msg(Etn, request, "Confirmez le mot de passe")%>' /></div>
            </div>
            <% if(!done) {%>
                <div class='form-group row'>
                    <label class='col-sm-3 control-label'></label>
                    <div class='col-sm-9'><button type="button" class='btn btn-primary' onclick='onOk()'><%=libelle_msg(Etn, request, "Confirmer")%></button></div>
                </div>
            <% } %>
        </form>
    </div>

     <%=_footerHtml%>

    <%=_endscriptshtml%>
</body>

<script>
    jQuery(document).ready(function() {

        $("#newPassword").focus();

        onOk=function()
        {
            $("#errdiv").html("");
            $("#errdiv").hide();
            $("#errdiv").removeClass("alert-success").addClass("alert-danger");
            if($("#newPassword").val() == "")
            {
                $("#errdiv").html("<%=PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Certaines informations demandées restent à renseigner"))%>");
                $("#errdiv").show();
                return;
            }
            if($("#confirmPassword").val() == "")
            {
                $("#errdiv").html("<%=PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Certaines informations demandées restent à renseigner"))%>");
                $("#errdiv").show();
                return;
            }

            if(document.getElementById('newPassword').value.length < 12)
            {
                $("#errdiv").html("<%=PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Le mot de passe doit contenir au moins 12 caractères"))%>");
                $("#errdiv").show();
                return;
            }
            if($("#newPassword").val() != $("#confirmPassword").val())
            {
                $("#errdiv").html("<%=PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Le nouveau mot de passe ne correspond pas à la confirmation du mot de passe"))%>");
                $("#errdiv").show();
                return;
            }
            $("#passfrm").submit();
        };

        <%if(errmsg.length() > 0){%>
            $("#errdiv").html("<%=PortalHelper.escapeCoteValue(errmsg)%>");
            $("#errdiv").show();
        <% } %>

        <% if(done) {%>
            setTimeout(function(){ __gotoPortalHome() }, 5000);
            var timeleft = 5;
            setRemainingSeconds=function(){
                timeleft -= 1;
                $("#timerspan").html(timeleft);
            };

            setInterval(setRemainingSeconds, 1000);
        <% } %>

    });
</script>
</html>