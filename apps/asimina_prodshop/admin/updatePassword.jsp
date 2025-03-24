<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ include file="../common.jsp" %>

<%
	String pid = request.getParameter("pid");
	String password = request.getParameter("password");
	
    if(!validatePass(password)){%>
    {
     "STATUS":"INVALID"
    }
  <%  }else{
	String currentuserprofil = "";
	if(session.getAttribute("PROFIL") != null) currentuserprofil = (String)session.getAttribute("PROFIL");

	int rowsUpdated = 0;
	if("ADMIN".equalsIgnoreCase(currentuserprofil)) rowsUpdated = Etn.executeCmd("update login set pass_expiry = adddate(now(), interval 90 day), pass = sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",'$',"+escape.cote(password)+",'$',puid),256) where pid = "+escape.cote(pid)+" ");
	if(rowsUpdated > 0)
	{
%>
{
	"STATUS":"SUCCESS"
}
<% } else { %>
{
	"STATUS":"ERROR"
}
<% }} %>
