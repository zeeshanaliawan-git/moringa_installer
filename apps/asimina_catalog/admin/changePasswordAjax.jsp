<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog"%>

<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<%
	String oldPassword = parseNull(request.getParameter("oldPassword"));
	String newPassword = parseNull(request.getParameter("newPassword"));
	String confirmPassword = parseNull(request.getParameter("confirmPassword"));

	int status = 1;
	String message = "";
	String gotoUrl = "";

	if(oldPassword.length() == 0 || newPassword.length() == 0)
	{
		message = "Required data is missing";
	}
	else if(newPassword.equals(confirmPassword) == false)
	{
		message = "New password and confirm password do not match";
	}
	else
	{
		boolean passOk = false;
		if(com.etn.asimina.util.UIHelper.validatePass(newPassword)) passOk = true;
		if(passOk)
		{
			Set rs = Etn.execute("select sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(newPassword)+",':',puid),256) as newpass, pass from login where pass = sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(oldPassword)+",':',puid),256) and pid = "+escape.cote(""+Etn.getId()));
			if(rs.rs.Rows > 0)
			{
				rs.next();
				if(parseNull(rs.value("newpass")).equals(parseNull(rs.value("pass"))))
				{
					message = "New password should be different than your old password";
				}
				else
				{
					Etn.executeCmd("update login set pass_expiry = adddate(now(), interval 90 day), pass = sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(newPassword)+",':',puid),256) where pid = "+escape.cote(""+Etn.getId()));
					message = "Password updated";
					status = 0;
					ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),Etn.getId()+"","PASSWORD CHANGED","User",parseNull(session.getAttribute("LOGIN")),parseNull(getSelectedSiteId(session)));
					gotoUrl = request.getContextPath() + "/admin/logout.jsp?cp=1&tm="+System.currentTimeMillis();
				}
			}
			else message = "Old password entered is wrong";
		}
		else message = "Password must be at least 12 characters long with one uppercase letter, one lowercase letter, one number and one special character. Special characters allowed are !@#$%^&*";
	}
%>
{"status":<%=status%>, "msg":"<%=message%>", "gotourl":"<%=gotoUrl%>"}
