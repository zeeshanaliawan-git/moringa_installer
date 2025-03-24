<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog, com.etn.asimina.util.UIHelper"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/usagelogs.jsp"%>


<%
    String version = GlobalParm.getParm("APP_VERSION");
    String username =  parseNull(request.getParameter("username"));
    String referrer =  parseNull(request.getParameter("referrer"));
    //System.out.println("username = "+username);
    String errmsg = parseNull(request.getParameter("errmsg"));
    String succmsg = parseNull(request.getParameter("smsg"));
    if(!username.trim().equals("")){
        Set rs = Etn.execute("select p.person_id, l.name as username, p.First_name, p.last_name, p.e_mail, l.pid, pp.profil_id from login l, person p, profilperson pp where pp.person_id = p.person_id and p.person_id = l.pid  and l.name =  "+escape.cote(username));

        if(rs.next()){
            if(parseNull(rs.value("e_mail")).length() > 0){
            // send email
                if(Etn.executeCmd("update person set forgot_password_referrer = "+escape.cote(referrer)+", forgot_password = 1 where person_id = "+escape.cote(parseNull(rs.value("person_id")))) > 0){
                    succmsg = "An email with the instructions is sent to your account email address";
                    Etn.execute("select semfree("+escape.cote(GlobalParm.getParm("SEMAPHORE"))+") ");
                }
            }
            else{
                   errmsg = "This username has no email address, contact admin.";
            }
        }else{
           errmsg = "Username not exsits";
        }
    }
%>

<html>
<head>
    <title>Forgot Password</title>
  <%@ include file="/WEB-INF/include/head2.jsp"%>
</head>
<body>
    <div class="container">
        <div class="jumbotron">
        <h1 style="font-size:63px;"> <img src="<%=request.getContextPath()%>/img/logo.png" alt="" style="width: 50px; height: auto; margin-right: 30px;"></span>Welcome to <%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%> </h1>
        <br>
        <div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
        <div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
        <form class="form-horizontal" autocomplete="off" id='lgnfrm' method='post' action='<%=request.getContextPath()%>/forgotpassword.jsp' >
			<input type="hidden" name="referrer" id="_referrer" value="">
            <div class='form-group row'>
                <h3 class='col-sm-4 control-label text-right' style="textAlign:center">Forgot Password</h3><div class='col-sm-8'></div>
            </div>
            <br>
            <div class='form-group row'>
                <label for='username' class='col-sm-3 control-label text-right'>Username</label>
                <div class='col-sm-7'><input class='form-control' type='text' name='username' id='username' value='<%=UIHelper.escapeCoteValue(username)%>' autocomplete='off' /></div>
            </div>

            <div class='form-group row'>
                <label class='col-sm-3 control-label'></label>
                <div class='col-sm-7'><button type="button" class='btn btn-primary' id='lgnbtn' onclick='onSubmit()'>Submit</button></div>
            </div>
            <div class='form-group row'>
                <label class='col-sm-7 control-label'></label>
                <div class='col-sm-3' style="text-align:right;"><a style="font-size: 12px;" href="login.jsp">Back to login</a></div>
            </div>
        </form>
        <div style='float:right; font-weight:bold;'><%=version%></div>
        </div>

    </div>


</body>
<script>
    jQuery(document).ready(function() {

		$("#_referrer").val(window.location.protocol + "//" + document.domain);

        $("#username").focus();

        $('.form-control').keypress(function (e) {
            if (e.which == 13)
            {
                $('form#lgnfrm').submit();
                return false;
            }
        });

        onSubmit=function()
        {
            $("#succdiv").html("");
            $("#succdiv").hide();
            $("#errdiv").html("");
            $("#errdiv").hide();
            if($("#username").val() == '')
            {
                $("#errdiv").html("You must provide username/password");
                $("#errdiv").show();
            }
            else
            {
                $("#lgnfrm").submit();
            }
        };

        <%if(errmsg.length() > 0){%>
            $("#errdiv").html("<%=escapeCoteValue(errmsg)%>");
            $("#errdiv").show();
        <% } else if (succmsg.length() > 0) { %>
            $("#succdiv").html("<%=escapeCoteValue(succmsg)%>");
            $("#succdiv").show();
        <% } %>

    });
</script>
</html>
