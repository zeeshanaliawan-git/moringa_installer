<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.asimina.util.UIHelper,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, com.etn.asimina.util.BlockedUserConfig"%>

<%@ page import="org.apache.commons.codec.binary.Hex,org.apache.commons.codec.binary.Base32,java.security.SecureRandom,com.etn.asimina.util.TOTP"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/usagelogs.jsp"%>
<%@ include file="../common.jsp" %>

<%!

	long parseLong(Object o) {
        return parseLong(o, 0);
    }

    long parseLong(Object o, long defaultValue) {
        String s = parseNull(o);
        if (s.length() > 0) {
            try {
                return Long.parseLong(s);
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

	if(Etn.getId() != 0)
	{
		response.sendRedirect(request.getContextPath() + "/admin/gestion.jsp");
		return;
	}

	String ip = UIHelper.getIP(request);
	String version = GlobalParm.getParm("APP_VERSION");
	String portalDb = GlobalParm.getParm("PORTAL_DB");
	if(version == null) version = "";
	else version = "v" + version;

	String dologin = parseNull(request.getParameter("dologin"));
	String lgntoken = "";
	String errmsg = parseNull(request.getParameter("errmsg"));
	String succmsg = parseNull(request.getParameter("smsg"));
    String username = parseNull(request.getParameter("username"));


//-------------------------Ahsan Start------------------------------------------
    String secretKey = "";
    String authEnable = "0";
    String totp = parseNull(request.getParameter("totp"));
    String code = "";
    long moringaTime = parseLong(request.getParameter("moringaTime"));
    Base32 base32 = new Base32();
    
    Set rsOtp1 = Etn.execute("select * from login where name="+escape.cote(username)); 

    if(rsOtp1!=null && rsOtp1.next()){
        secretKey=parseNull(rsOtp1.value("secret_key"));
        authEnable=parseNull(rsOtp1.value("is_two_auth_enabled"));
    }

    byte[] bytes = base32.decode(secretKey);

    String hexKey = Hex.encodeHexString(bytes);
    //-------------------------Ahsan End------------------------------------------

	if(parseNull(request.getParameter("c")).equals("1"))
	{
		succmsg = "Your password is changed successfully. Login with your new password";
	}

	if("1".equals(dologin))
	{
        // ip block check
        Map<String, String> userConfig = BlockedUserConfig.instance.userConfig;
        Map<String, String> ipConfig = BlockedUserConfig.instance.ipConfig;

        Set rst = Etn.execute("select case when attempt >= "+escape.cote(ipConfig.get("nAttempts"))+" then 0 else 1 end as cantry from login_tries where adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseNullInt(ipConfig.get("blockTime")), ipConfig.get("blockTimeUnit"))))+" minute) > now() and ip = " + escape.cote(ip));

        boolean cantry = true;
        if(rst.next() && "0".equals(rst.value("cantry"))) cantry = false;
        if(!cantry)
        {
            addusagelog(Etn, request, username, "login failure", "invalid username or password");
            errmsg = "Your IP is blocked";
            Etn.executeCmd("update login_tries set attempt = attempt + 1, tm = now() where ip = " + escape.cote(ip));
        }
		else
		{

            // unblock/delete ip if the ip block time has passed
            Etn.executeCmd("delete from login_tries where attempt >= "+escape.cote(ipConfig.get("blockTimeUnit"))+" and adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseNullInt(ipConfig.get("blockTime")), ipConfig.get("blockTimeUnit"))))+" minute) <= now() and ip = " + escape.cote(ip));

            // check user-account block
            rst = Etn.execute("select case when attempt >= "+escape.cote(userConfig.get("nAttempts"))+" then 0 else 1 end as cantry from user_login_tries where adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseNullInt(userConfig.get("blockTime")), userConfig.get("blockTimeUnit"))))+" minute) > now() and username = " + escape.cote(username));

            cantry = true;
            if(rst.next() && "0".equals(rst.value("cantry"))) cantry = false;
            if(!cantry)
            {
                addusagelog(Etn, request, username, "login failure", "invalid username or password");
                errmsg = "Account "+username+" is blocked";
                Etn.executeCmd("update user_login_tries set attempt = attempt + 1, tm = now() where username = " + escape.cote(username));
            }else{
                // unblock/ delete user if the user block time has passed
                Etn.executeCmd("delete from user_login_tries where attempt >= "+escape.cote(userConfig.get("nAttempts"))+" and adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseNullInt(userConfig.get("blockTime")), userConfig.get("blockTimeUnit"))))+" minute) <= now() and username = " + escape.cote(username));
                lgntoken = parseNull(request.getParameter("lgntoken"));
                if(session.getAttribute("lgntoken") != null && ((String)session.getAttribute("lgntoken")).equals(lgntoken))
                {
                    
//-----------------------Start Check Authentication TOTP by Ahsan-----------------------------
                    if(authEnable.equals("1")){
                        code = TOTP.getOTP(hexKey,moringaTime);
                    }
                    
                    if(code.length()>0 && !code.equalsIgnoreCase(totp)){
                        addusagelog(Etn, request, username, "login failure", "invalid TOTP");
                        errmsg = "Invalid TOTP";
                        Etn.executeCmd("insert into login_tries (ip, tm, attempt) values ("+escape.cote(ip)+",now(),'1') on duplicate key update attempt = attempt + 1, tm = now() ");
                        // check if the userAccount exist or not
                        Set rs =  Etn.execute("select pid from login where name = "+escape.cote(username));
                        if(rs.rs.Rows>0){
                            Etn.executeCmd("insert into user_login_tries (username, tm, attempt) values ("+escape.cote(username)+", now(), '1') on duplicate key update attempt = attempt + 1, tm = now() ");
                        }
//-----------------------End Check Authentication TOTP by Ahsan-----------------------------
                    }
                    else{

                        Set _rsPass = Etn.execute("select sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",'$',"+escape.cote(parseNull(request.getParameter("passwd")))+",'$',puid),256) from login where name = "+escape.cote(username));
                        if(_rsPass.next()) 
						{
							String hashPass = parseNull(_rsPass.value(0));

							Etn.setContexte(username,hashPass);
							if(Etn.getId() == 0)
							{
								addusagelog(Etn, request, username, "login failure", "invalid username or password");
								errmsg = "Invalid username or password";
								Etn.executeCmd("insert into login_tries (ip, tm, attempt) values ("+escape.cote(ip)+",now(),'1') on duplicate key update attempt = attempt + 1, tm = now() ");
								// check if the userAccount exist or not
								Set rs =  Etn.execute("select pid from login where name = "+escape.cote(username));
								if(rs.rs.Rows>0){
									Etn.executeCmd("insert into user_login_tries (username, tm, attempt) values ("+escape.cote(username)+", now(), '1') on duplicate key update attempt = attempt + 1, tm = now() ");
								}
							}
							else
							{
								//success login
								addusagelog(Etn, request, username, "login success", null);
								Etn.executeCmd("delete from login_tries where ip = " + escape.cote(ip));
								Etn.executeCmd("delete from user_login_tries where username = " + escape.cote(username));

								if(parseNull(rsOtp1.value("selected_site_id")).length() > 0 && !parseNull(rsOtp1.value("selected_site_id")).equals("0")){
									session.setAttribute("SELECTED_SITE_ID", parseNull(rsOtp1.value("selected_site_id")));

									Set rsSite = Etn.execute("select name from "+portalDb+".sites where id="+escape.cote(parseNull(rsOtp1.value("selected_site_id"))));
									rsSite.next();
									session.setAttribute("SELECTED_SITE_NAME", parseNull(rsSite.value("name")));
								}else{
									session.setAttribute("SELECTED_SITE_ID", "");
								}
								if(parseNull(request.getParameter("_url")).length() > 0)
								{
									response.sendRedirect(parseNull(request.getParameter("_url")));
									return;
								}
								else
								{
									response.sendRedirect(request.getContextPath() + "/admin/gestion.jsp");
									return;
								}
							}//end if
						}
						else
						{
							addusagelog(Etn, request, username, "login failure", "invalid username or password");
							errmsg = "Invalid username or password";
							Etn.executeCmd("insert into login_tries (ip, tm, attempt) values ("+escape.cote(ip)+",now(),'1') on duplicate key update attempt = attempt + 1, tm = now() ");
							// check if the userAccount exist or not
							Set rs =  Etn.execute("select pid from login where name = "+escape.cote(username));
							if(rs.rs.Rows>0){
								Etn.executeCmd("insert into user_login_tries (username, tm, attempt) values ("+escape.cote(username)+", now(), '1') on duplicate key update attempt = attempt + 1, tm = now() ");
							}
						}
                    }
                }
                else
                {
                    addusagelog(Etn, request, username , "login failure", "token mis-match");
                    errmsg = "Token mis-match. Try again";
                }
            }
		}
	}

	//lets share the token between multiple login screens if username/password is empty which means user is redirected to login and has not attempted login yet
	//we check if user/pass is not empty means user tried to login so we will reset the token this time
	if(username.length() > 0 || parseNull(request.getParameter("passwd")).length() > 0)
	{
		lgntoken = java.util.UUID.randomUUID().toString();
		session.setAttribute("lgntoken", lgntoken);
	}
	else if(session.getAttribute("lgntoken") != null)//token is in session already so use it otherwise multiple screens give token mismatch error
	{
		lgntoken = (String)session.getAttribute("lgntoken");
	}

	//case for login screen opened first time
	if(lgntoken.length() == 0)
	{
		lgntoken = java.util.UUID.randomUUID().toString();
		session.setAttribute("lgntoken", lgntoken);
	}


%>

<html>
<head>

    <title>Shop</title>
    <%@ include file="/WEB-INF/include/head2.jsp"%>

</head>
<body style='background:white !important'>
	<div class="container mt-5">
		<div class="jumbotron">
		<!-- Main component for a primary marketing message or call to action -->
            <h1 style="font-size:63px;"> <img src="<%=request.getContextPath()%>/img/logo.png" alt="" style="width: 50px; height: auto; margin-right: 30px;">Welcome to <%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%> </h1>
            <br>
            <div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
            <div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
            <form class="form-horizontal" autocomplete="off" id='lgnfrm' method='post' action='<%=request.getContextPath()%>/login.jsp' >
                <input type='hidden' name='lgntoken' value='<%=UIHelper.escapeCoteValue(lgntoken)%>'>
                <input type='hidden' name='dologin' value='1'>
                <input type='hidden' name='_url' value='<%=UIHelper.escapeCoteValue(parseNull(request.getParameter("_url")))%>'>

                <div class='form-group row'>
                    <label for='username' class='col-sm-3 control-label text-right'>Username</label>
                    <div class='col-sm-7'><input class='form-control' type='text' name='username' id='username' value='' autocomplete='off' /></div>
                </div>
                <div class='form-group row'>
                    <label for='passwd' class='col-sm-3 control-label text-right'>Password</label>
                    <div class='col-sm-7'><input class='form-control' type='password' name='passwd' id='passwd' value='' autocomplete='off' /></div>
                </div>
                <div class='form-group row' style="display: none;">
                    <label for='totp' class='col-sm-3 control-label text-right'>Authentication Code</label>
                    <div class='col-sm-7'><input class='form-control' name='totp' id='totp' value='' autocomplete='off' /></div>
                    <div id="timerdiv"><input class='form-control' name='moringaTime' id='moringaTime' value='' autocomplete='off' /></div>
                </div>

                <div class='form-group row'>
                    <label class='col-sm-3 control-label'></label>
                    <div class='col-sm-7'><button type="button" class='btn btn-primary' id='lgnbtn' onclick='letslogin()'>Login</button></div>
                </div>

                <div class='form-group row'>
                    <label class='col-sm-7 control-label'></label>
                    <div class='col-sm-3' style="text-align:right;"><a style="font-size: 12px;" href="forgotpassword.jsp">Forgot password?</a></div>
                </div>
            </form>
            <div style='float:right; font-weight:bold;'><%=version%></div>
        </div>

                <%--top down modal--%>
        <div class="modal fade pt-5" tabindex="-1" id="totpModal" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Please Enter your 6 digit TOTP</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="container p-5 text-center">
                        <input class="d-inline-block text-center rounded" style="width:50px;height:50px;" type="text" id="totp1" oninput='digitValidate(this)' required onkeyup='tabChange("totp1",0)' maxlength=1 >
                        <input class="d-inline-block text-center rounded" style="width:50px;height:50px;" type="text" id="totp2" oninput='digitValidate(this)' required onkeyup='tabChange("totp2",1)' maxlength=1 >
                        <input class="d-inline-block text-center rounded" style="width:50px;height:50px;" type="text" id="totp3" oninput='digitValidate(this)' required onkeyup='tabChange("totp3",2)' maxlength=1 >
                        <input class="d-inline-block text-center rounded" style="width:50px;height:50px;" type="text" id="totp4" oninput='digitValidate(this)' required onkeyup='tabChange("totp4",3)' maxlength=1 >
                        <input class="d-inline-block text-center rounded" style="width:50px;height:50px;" type="text" id="totp5" oninput='digitValidate(this)' required onkeyup='tabChange("totp5",4)' maxlength=1 >
                        <input class="d-inline-block text-center rounded" style="width:50px;height:50px;" type="text" id="totp6" oninput='digitValidate(this)' required onkeyup='tabChange("totp6",5)' maxlength=1 >
                    </div>
                    <div class="modal-footer">
                        <button type="button" disabled class="btn btn-primary" id="totpSubmitBtn" onclick="submitTotp()" data-dismiss="modal">Submit</button>
                    </div>
                </div>
            </div>
        </div>

    </div>


</body>
<script>
	jQuery(document).ready(function() {

        let totp=[];

		$("#username").focus();

		$('.form-control').keypress(function (e) {
			if (e.which == 13)
			{
                letslogin();
				return false;
			}
		});

		letslogin=function()
		{
			$("#succdiv").html("");
			$("#succdiv").hide();
			$("#errdiv").html("");
			$("#errdiv").hide();
			if($("#username").val() == '' || $("#passwd").val() == '' )
			{
				$("#errdiv").html("You must provide username/password");
				$("#errdiv").show();
			}
			else
			{
                $.ajax({
                    url: '<%=request.getContextPath()%>'+"/checkAuth.jsp", 
					method:'post',
                    data:{
                        "username":document.getElementById("username").value
                    },
                    success: function(result){
                        let resp = JSON.parse(result);
                        if(resp.status==0){
                            $('#totpModal').modal('show');
                            setTimeout(() => {
                                document.getElementById('totp1').focus();
                            }, 500);
                        }else{
                            document.getElementById('moringaTime').value = new Date().getTime();
				            $("#lgnfrm").submit();
                        }
                    }
                });
			}
		};

        digitValidate = function(ele){
            ele.value = ele.value.replace(/[^0-9]/g,'');
        };

        tabChange = function(id,num){
            let eleInput = document.getElementById(id);

            if(eleInput.value !=''){
            
                totp[num] = eleInput.value;
                let ele = eleInput.nextElementSibling;
                if(ele!= undefined){
                    ele.focus();
                }else{
                    document.getElementById('totpSubmitBtn').disabled = false;
                }
            }
            
        };

        submitTotp =function(){
			console.log((new Date()).getTime())
            document.getElementById('moringaTime').value = (new Date()).getTime();
            document.getElementById('totp').value = totp.toString().replaceAll(",","");

            $('#totpModal').modal('hide');
            $("#lgnfrm").submit();
        };

		<%if(errmsg.length() > 0){%>
			$("#errdiv").html("<%=UIHelper.escapeCoteValue(errmsg)%>");
			$("#errdiv").show();
		<% } else if (succmsg.length() > 0) { %>
			$("#succdiv").html("<%=UIHelper.escapeCoteValue(succmsg)%>");
			$("#succdiv").show();
		<% } %>

	});
</script>
</html>
