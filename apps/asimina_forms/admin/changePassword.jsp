<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<%@ include file="../common2.jsp" %>

<%!
	String convertToHex(byte[] data) 
	{ 
        StringBuffer buf = new StringBuffer();
        for (int i = 0; i < data.length; i++) { 
            int halfbyte = (data[i] >>> 4) & 0x0F;
            int two_halfs = 0;
            do { 
                if ((0 <= halfbyte) && (halfbyte <= 9)) 
                    buf.append((char) ('0' + halfbyte));
                else 
                    buf.append((char) ('a' + (halfbyte - 10)));
                halfbyte = data[i] & 0x0F;
            } while(two_halfs++ < 1);
        } 
        return buf.toString();
    } 
 
    String MD5(String text) throws NoSuchAlgorithmException, UnsupportedEncodingException  
	{ 
        MessageDigest md;
        md = MessageDigest.getInstance("MD5");
        byte[] md5hash = new byte[32];
        md.update(text.getBytes("utf8"), 0, text.length());
        md5hash = md.digest();
        return convertToHex(md5hash);
    } 


%>

<%
	String oldPassword = parseNull(request.getParameter("oldPassword"));
	String newPassword = parseNull(request.getParameter("newPassword"));
	String confirmPassword = parseNull(request.getParameter("confirmPassword"));
	String updatePassword = parseNull(request.getParameter("updatePassword"));
	
	String message = "&nbsp;";
	if(updatePassword.equals("1"))
	{
		Set rs = Etn.execute("select pass from login where pid = "+escape.cote(""+Etn.getId())+" ");//change
		rs.next();
		if(MD5(oldPassword).equals(rs.value("pass")))
		{
			Etn.executeCmd("update login set pass = "+escape.cote(MD5(newPassword))+" where pid = "+escape.cote(""+Etn.getId())+" ");//change
			message = "Password updated";
		}
		else message = "Wrong previous password entered";
	}
%>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset="utf-8" />
		<title>Change Password</title>

		<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/menu.css">
		<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/general.css" />
		<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/bootstrap.min.css">
		<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/general.css" />
		<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css" />

		<script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/html_form_template.js"></script>

		<script>
		
			function onOk()
			{
				var isError = 0;
				document.getElementById("oldPasswdLbl").innerHTML = "&nbsp;";
				document.getElementById("newPasswdLbl").innerHTML = "&nbsp;";
				document.getElementById("confirmPasswdLbl").innerHTML = "&nbsp;";
				if(document.passwdFrm.oldPassword.value =="")
				{
					isError = 1;
					document.getElementById("oldPasswdLbl").innerHTML = "Enter old password";					
				}
				if(document.passwdFrm.newPassword.value =="")
				{
					isError = 1;
					document.getElementById("newPasswdLbl").innerHTML = "Enter new password";					
				}
				if(document.passwdFrm.confirmPassword.value =="")
				{
					isError = 1;
					document.getElementById("confirmPasswdLbl").innerHTML = "Enter confirm password";					
				}
				if(isError == 0 && document.passwdFrm.confirmPassword.value != document.passwdFrm.newPassword.value)
				{
					isError = 1;
					alert("New password does not match with confirm password");
				}
				if(isError == 0 && document.passwdFrm.newPassword.value.length < 8)
				{
					isError = 1;
					alert("Password must be at-least 8 characters long");
				}
				if(isError == 0 && !(/^(?=\D*\d)(?=[^a-z]*[a-z])[0-9a-z]+$/i.test(document.passwdFrm.newPassword.value)))
				{
					isError = 1;
					alert("Password must contain atleast one character and one number");
				}
				if(isError == 1) return;
				document.passwdFrm.submit();
			}
		</script>
	</head>
	<body>
		<%@ include file="/WEB-INF/include/menu.jsp"%>

	<form name="passwdFrm" action="changePassword.jsp" method="post" autocomplete='off'>		
	<div>
	
		<input type="hidden" name="updatePassword" value="1"/>
		<center>
		<h2>Change Password</h2>

		<div style="margin-top:10px;color:red" id="messageLbl"><%=message%></div>
		</center>
		<div style='text-align:center; width:800px; margin-left:auto; margin-right:auto'>
		<table style='width: 820px;border: 1px solid #CCCCCB;background-color: white;padding: 5px 5px 5px;' cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td width="15%"></td>
				<td width="25%" style='font-size:12px'><b>Old password</b></td>
				<td width="50%"><b>:&nbsp;&nbsp;</b><input type="password" autocomplete='off' value="" size="30" maxlength="50" name="oldPassword">&nbsp;<span id="oldPasswdLbl" style="font-size:8pt;color:red">&nbsp;</span></td>
				<td></td>			
				</tr>			
			<tr>
				<td></td>
				<td style='font-size:12px'><b>New password</b></td>
				<td><b>:&nbsp;&nbsp;</b><input type="password" autocomplete='off' value="" size="30" maxlength="50" name="newPassword">&nbsp;<span id="newPasswdLbl" style="font-size:8pt;color:red">&nbsp;</span></td>
				<td></td>			
				</tr>			
			<tr>
				<td></td>
				<td style='font-size:12px'><b>Confirm new password</b></td>
				<td><b>:&nbsp;&nbsp;</b><input type="password" autocomplete='off' value="" size="30" maxlength="50" name="confirmPassword">&nbsp;<span id="confirmPasswdLbl" style="font-size:8pt;color:red">&nbsp;</span></td>
				<td></td>			
				</tr>	
			<tr>
				<td align="center" colspan="4"><input type="button" class="orangeButton" value="Ok" onclick="onOk()"></td>
			</tr>
		</table>
		</div>
	</div>
	</form>
	</body>
</html>
			
