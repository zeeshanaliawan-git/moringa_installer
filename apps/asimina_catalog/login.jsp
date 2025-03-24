<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog, com.etn.asimina.util.UIHelper , com.etn.asimina.util.BlockedUserConfig"%>

<%@ page import="org.apache.commons.codec.binary.Hex,org.apache.commons.codec.binary.Base32,java.security.SecureRandom,com.etn.asimina.util.TOTP"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/usagelogs.jsp"%>

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
    
    String ip = com.etn.asimina.util.ActivityLog.getIP(request);
	com.etn.util.Logger.debug("X-Forwarded-For:"+request.getHeader("X-Forwarded-For"));
	com.etn.util.Logger.debug("IP:"+ip);
    String version = GlobalParm.getParm("APP_VERSION");
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
    
    Set rsOtp1 = Etn.execute("select is_two_auth_enabled,secret_key from login where name="+escape.cote(username)); 

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

        Set rst = Etn.execute("select case when attempt >= "+escape.cote(ipConfig.get("nAttempts"))+" then 0 else 1 end as cantry from login_tries where adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseInt(ipConfig.get("blockTime")), ipConfig.get("blockTimeUnit"))))+" minute) > now() and ip = " + escape.cote(ip));

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
            Etn.executeCmd("delete from login_tries where attempt >= "+escape.cote(ipConfig.get("blockTimeUnit"))+" and adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseInt(ipConfig.get("blockTime")), ipConfig.get("blockTimeUnit"))))+" minute) <= now() and ip = " + escape.cote(ip));

            // check user-account block
            rst = Etn.execute("select case when attempt >= "+escape.cote(userConfig.get("nAttempts"))+" then 0 else 1 end as cantry from user_login_tries where adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseInt(userConfig.get("blockTime")), userConfig.get("blockTimeUnit"))))+" minute) > now() and username = " + escape.cote(username));

            cantry = true;
            if(rst.next() && "0".equals(rst.value("cantry"))) cantry = false;
            if(!cantry)
            {
                addusagelog(Etn, request, username, "login failure", "invalid username or password");
                errmsg = "Account "+username+" is blocked";
                Etn.executeCmd("update user_login_tries set attempt = attempt + 1, tm = now() where username = " + escape.cote(username));
            }else{
                // unblock/ delete user if the user block time has passed
                Etn.executeCmd("delete from user_login_tries where attempt >= "+escape.cote(userConfig.get("nAttempts"))+" and adddate(tm, interval "+escape.cote(String.valueOf(UIHelper.convertTimeUnitToMinutes(parseInt(userConfig.get("blockTime")), userConfig.get("blockTimeUnit"))))+" minute) <= now() and username = " + escape.cote(username));
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
                        Set _rsPass = Etn.execute("select pid, sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(parseNull(request.getParameter("passwd")))+",':',puid),256) as hashpass "+
						" from login where name = "+escape.cote(username));
                        if(_rsPass.next()) 
						{
							Set rsProfile = Etn.execute("select pp.* from profilperson pp, profil p where p.profil_id = pp.profil_id and pp.person_id = "+escape.cote(_rsPass.value("pid"))+" and profil not in ('TEST_SITE_ACCESS','PROD_SITE_ACCESS') ");
							if(rsProfile.rs.Rows == 0)
							{
								addusagelog(Etn, request, username, "login failure", "invalid profil accessing");
								errmsg = "You are not authorized to login here";
								Etn.executeCmd("insert into login_tries (ip, tm, attempt) values ("+escape.cote(ip)+",now(),'1') on duplicate key update attempt = attempt + 1, tm = now() ");
								// check if the userAccount exist or not
								Set rs =  Etn.execute("select pid from login where name = "+escape.cote(username));
								if(rs.rs.Rows>0){
									Etn.executeCmd("insert into user_login_tries (username, tm, attempt) values ("+escape.cote(username)+", now(), '1') on duplicate key update attempt = attempt + 1, tm = now() ");
								}
							}
							else
							{
								String hashPass = parseNull(_rsPass.value("hashpass"));

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
									Set rsl = Etn.execute("select * from login where pid = " + escape.cote(""+Etn.getId()) );
									if(rsl.next())
									{
										String siteid = "";
										long lSiteId = 0;
										if(parseNull(rsl.value("last_site_id")).length() > 0) 
										{
											try {
												lSiteId = Long.parseLong(parseNull(rsl.value("last_site_id")));
											} catch(Exception e) {}
										}
										if(lSiteId > 0)
										{
											siteid = parseNull(rsl.value("last_site_id"));                                
										}
										else
										{
											Set rsP = Etn.execute("select * from person_sites where person_id = " + escape.cote(""+Etn.getId()));
											if(rsP.rs.Rows == 1)//only one site is assigned to this user so we select it by default
											{
												rsP.next();
												siteid = parseNull(rsP.value("site_id"));
												Etn.executeCmd("update login set last_site_id = "+escape.cote(siteid)+" where pid = " + escape.cote(""+Etn.getId()));
											}
										}
										Etn.executeCmd("insert into " + com.etn.beans.app.GlobalParm.getParm("COMMONS_DB") + ".user_sessions (pid, catalog_session_id, selected_site_id) values ("+escape.cote(""+Etn.getId())+","+escape.cote("" + session.getId())+","+escape.cote(siteid)+") on duplicate key update pid = "+escape.cote(""+Etn.getId())+", last_updated_on = now(), selected_site_id = " + escape.cote(siteid) );
										ActivityLog.addLog(Etn,request,request.getParameter("username"),""+Etn.getId(),"LOGIN","User",request.getParameter("username"),siteid);							
										session.setAttribute("SELECTED_SITE_ID", siteid);
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
								}//end else
							}//else rsProfile.rs.Rows == 0
						}//end if
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
                    addusagelog(Etn, request, username, "login failure", "token mis-match");
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
    <title>Login</title>
    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    <link href="<%=request.getContextPath()%>/css/navbar-fixed-top.css" rel="stylesheet">

</head>
<body>


    <div class="container">
        <div class="jumbotron">
        <!-- Main component for a primary marketing message or call to action -->
        <h1 style="font-size:63px;"> <img src="<%=request.getContextPath()%>/img/logo.png" alt="" style="width: 50px; height: auto; margin-right: 30px;"></span>Welcome to <%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%> </h1>
        <br>
        <div class="alert alert-success" id='succdiv' role="alert" style='display:none'></div>
        <div class="alert alert-danger" id='errdiv' role="alert" style='display:none'></div>
        <form class="form-horizontal" autocomplete="off" id='lgnfrm' method='post' action='<%=request.getContextPath()%>/login.jsp' >
            <input type='hidden' name='lgntoken' value='<%=UIHelper.escapeCoteValue(lgntoken)%>'>
            <input type='hidden' name='dologin' value='1'>
            <input type='hidden' name='_url' value='<%=escapeCoteValue(parseNull(request.getParameter("_url")))%>'>

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
                        <input class="d-inline-block form-control totp-field text-center rounded" style="width:50px;height:50px;" type="text" id="totp1" required maxlength=1 >
                        <input class="d-inline-block form-control totp-field text-center rounded" style="width:50px;height:50px;" type="text" id="totp2" required maxlength=1 >
                        <input class="d-inline-block form-control totp-field text-center rounded" style="width:50px;height:50px;" type="text" id="totp3" required maxlength=1 >
                        <input class="d-inline-block form-control totp-field text-center rounded" style="width:50px;height:50px;" type="text" id="totp4" required maxlength=1 >
                        <input class="d-inline-block form-control totp-field text-center rounded" style="width:50px;height:50px;" type="text" id="totp5" required maxlength=1 >
                        <input class="d-inline-block form-control totp-field text-center rounded" style="width:50px;height:50px;" type="text" id="totp6" required maxlength=1 >
                        <div id="error-msg" class="mt-2" style="color: red; display: none;">Please enter digit only</div>
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

        $("#totpModal").on("hide.bs.modal",function(){
            $(this).find(".totp-field").each(function(idx, ele) {
                $(ele).val(''); 
            });
            $("#totpSubmitBtn").prop("disabled",true);
        });

        function fillTotop(val, ele)
        {
            if(val.length == 0) {
                $(ele).removeClass("is-invalid");
                $("#error-msg").hide();
                return;
            }

            let isDigit = /^\d$/.test(val);

            if(!isDigit) {
                $(ele).val("");
                $(ele).addClass("is-invalid");
                $("#error-msg").show();
            }
            else {
                $(ele).val(val);
                $(ele).removeClass("is-invalid");
                $("#error-msg").hide();
                if($(ele).nextAll(".totp-field").length > 0)
                    $(ele).next(".totp-field").focus();
                else
                    $("#totpSubmitBtn").prop("disabled",false);
            }
        }

        $(".totp-field").on("input",function(event){
            let input = $(this).val();
            fillTotop(input,$(this));
        });

        $(".totp-field").on("keyup",function(e){
            if(e.key.toLowerCase() == "backspace")
            {
                let input = $(this).val();
                if(input.length > 0) { 
                    $(this).val("");
                }else{
                    if($(this).prevAll(".totp-field").length>0)
                        $(this).prev(".totp-field").focus();
                }
            }
            if (e.key >= '0' && e.key <= '9') {
                let input = $(this).val();
                if(input.length > 0) {
                    $(this).next(".totp-field").focus();
                    if($(this).nextAll(".totp-field").length > 0){
                        $(this).next(".totp-field").val(e.key);
                    }
                }
            }
            var elementsWithValue = $(".totp-field").filter(function() {
                return $(this).val() !== "";
            });
            if(elementsWithValue.length < 6) $("#totpSubmitBtn").prop("disabled",true);
            else $("#totpSubmitBtn").prop("disabled",false);

            if(e.key.toLowerCase() == "enter" && !$('#totpSubmitBtn').is(':disabled')) submitTotp();

        });

        $(".totp-field").on("paste",function(){
            let pastedText = (event.originalEvent || event).clipboardData.getData('text');
            let firstSixDigits = pastedText.trim().replace(/\D/g, '').slice(0, 6);
            let ele = $(this);
            let count=0;
            do{
                let digit = parseInt(firstSixDigits[count++]);
                fillTotop(digit, ele);
                if($(ele).nextAll(".totp-field").length == 0) break;
                ele = $(ele).next(".totp-field");
            }
            while(count<6);
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

        submitTotp =function(){
			console.log((new Date()).getTime())
            document.getElementById('moringaTime').value = (new Date()).getTime();
            let values = $(".totp-field").map(function() {
                    return $(this).val();
            }).get();
            let totp = values.join("");
            document.getElementById('totp').value = totp; 

            $('#totpModal').modal('hide');
            $("#lgnfrm").submit();
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
