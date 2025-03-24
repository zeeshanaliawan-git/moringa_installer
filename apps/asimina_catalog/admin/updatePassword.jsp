<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog,  java.util.regex.* "%>


<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
	String pid = request.getParameter("pid");
    String username = parseNull(request.getParameter("username"));
	String password = parseNull(request.getParameter("password"));
    if(!com.etn.asimina.util.UIHelper.validatePass(password)){%>
    {
     "STATUS":"INVALID"
    }
  <%  }else{

	String currentuserprofil = "";
	if(session.getAttribute("PROFIL") != null) currentuserprofil = (String)session.getAttribute("PROFIL");

	int rowsUpdated = 0;
	//only admin profil can save/update users
	currentuserprofil = currentuserprofil.replaceAll("\\s+","");
	
	if("ADMIN".equalsIgnoreCase(currentuserprofil)||"SUPER_ADMIN".equalsIgnoreCase(currentuserprofil)) {
		rowsUpdated = Etn.executeCmd("update login set pass_expiry = adddate(now(), interval 90 day), pass = sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(password)+",':',puid),256) where pid = "+escape.cote(pid)+" ");
	}
	if(rowsUpdated > 0)
	{
        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),pid,"RESET PASSWORD","User Managment",username+" password reseted by "+parseNull(session.getAttribute("LOGIN")),parseNull(getSelectedSiteId(session)));
%>
{
	"STATUS":"SUCCESS"
}
<% } else { %>
{
	"STATUS":"ERROR"
}
<% }} %>
