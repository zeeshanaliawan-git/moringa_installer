<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm,com.etn.asimina.util.UIHelper"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/usagelogs.jsp"%>
<%@ include file="common.jsp"%>

<%
    String version = GlobalParm.getParm("APP_VERSION");
    // if(isClientLoggedIn(Etn, request, parseNull(request.getParameter("muid"))) == true)
    // {
    //     response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+  parseNull(request.getParameter("muid")));
    //     return;
    // }

    String ftoken = parseNull(request.getParameter("t"));
    String username = "";
    String err = "";
    if(!ftoken.trim().equals("")){
        Set rs = Etn.execute("select * from person where forgot_pass_token = " + escape.cote(ftoken));
        if(rs.rs.Rows == 0)
        {
            err = "Invalid token provided";
        }
        if(err.length()  ==  0)
        {
            rs = Etn.execute("select p.*,l.name as username from person p, login l where p.person_id = l.pid  and p.forgot_pass_token_expiry >= now() and p.forgot_pass_token = " + escape.cote(ftoken));
            if(rs.rs.Rows == 0)
            {
                err = "Token is already expired";
            }else{
                rs.next();
                username = parseNull(rs.value("username"));
            }
        }
    }else{
        err = "Empty token provided";
    }
%>
<html>
<head>
    <title>Reset Password</title>
  <%@ include file="/WEB-INF/include/head2.jsp"%>
</head>
<body>


    <div class="container">
        <div class="jumbotron">
        <h1 style="font-size:63px;"> <img src="<%=request.getContextPath()%>/img/logo.png" alt="" style="width: 50px; height: auto; margin-right: 30px;"></span>Welcome to <%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%> </h1>
        <br>

        <div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
        <div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
        <form class="form-horizontal" autocomplete="off"  id='frm' action='<%=request.getContextPath()%>/forgotpassword.jsp' >
            <input type='hidden' name='ftoken' value='<%=escapeCoteValue(ftoken)%>' />
            <div class='form-group row'>
                <h3 class='col-sm-4 control-label text-right' style="textAlign:center">Reset Password</h3><div class='col-sm-8'></div>
            </div>
            <div class='form-group row'>
                <label for='username' class='col-sm-3 control-label text-right'>Username</label>
                <div class='col-sm-7'><input class='form-control' type='text' disabled name='username' id='username' value='<%=UIHelper.escapeCoteValue(username)%>' autocomplete='off'/></div>
            </div>
            <div class='form-group row'>
                <label for='password' class='col-sm-3 control-label text-right'>New Password&nbsp;<span style='color:red'>*</span></label>
                <div class='col-sm-7'><input class='form-control' type='password' name='password' id='password' value=''/></div>
            </div>
            <div class='form-group row'>
                <label for='confirmPassword' class='col-sm-3 control-label text-right'>Confirm Password&nbsp;<span style='color:red'>*</span></label>
                <div class='col-sm-7'><input class='form-control' type='password' name='confirmPassword' id='confirmPassword' value='' /></div>
            </div>

            <div class='form-group row'>
                <label class='col-sm-3 control-label'></label>
                <div id='submitBtnDiv' class='col-sm-7'><button type="button" class='btn btn-primary' style="cursor:pointer" id='submitBtn'>Submit</button></div>
            </div>
             <div class='form-group row'>
                <label class='col-sm-7 control-label'></label>
                <div class='col-sm-3' style="text-align:right;"><a style="font-size: 12px;" href="login.jsp">Login here</a></div>
            </div>
        </form>
        <div style='float:right; font-weight:bold;'><%=UIHelper.escapeCoteValue(version)%></div>
        </div>

    </div>


<script type="text/javascript">
    var count = 3;
    $(document).ready(function()
    {
        $("#submitBtn").click(function()
        {
            $("#succdiv").hide();
            $("#succdiv").html("");

            $("#errdiv").hide();
            $("#errdiv").html("");

            if($("#password").val().trim() == "")
            {

                $("#errdiv").html("Password required");
                $("#errdiv").show();
                return;
            }
            if($("#confirmPassword").val().trim() == "")
            {
                $("#errdiv").html("Confirm password required");
                $("#errdiv").show();
                return;
            }

            $.ajax({
                url : 'resetpassbackend.jsp',
                type: 'post',
                data : $("#frm").serialize(),
                dataType: 'json',
                   success : function(json)
                {
                    if(json.status == 'error')
                    {
                        $("#errdiv").html(json.msg);
                        $("#errdiv").fadeIn();
                        $("#errdiv").focus();
                    }
                    else
                    {
                        $("#succdiv").html(json.msg+", redirecting to login "+count+" sec");
                        $("#succdiv").fadeIn();
                        $("#succdiv").focus();

                        $("#submitBtnDiv").html("");
                        setInterval(function(){
                            if(count == 0)
                                location.replace("<%=request.getContextPath()%>/login.jsp")
                            else{
                                count = count -1;
                                $("#succdiv").html(json.msg+", redirecting to login in "+count+" sec");
                            }
                        }, 1000);
                   }
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                }
            });

        });

        <%if(err.length() > 0){%>
            $("#errdiv").html("<%=UIHelper.escapeCoteValue(err)%>");
            $("#errdiv").show();
        <% } %>
    });
</script>

</body>
</html>
