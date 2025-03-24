<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, com.etn.util.Base64, com.etn.beans.app.GlobalParm, com.etn.asimina.util.PortalHelper"%>

<%@ include file="../lib_msg.jsp"%>

<%@ include file="../clientcommon.jsp"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}


%>

<%
	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+	parseNull(request.getParameter("muid")));
		return;		
	}
	

	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "login";
	
%>

<%@ include file="../headerfooter.jsp"%>

<%
	String email = parseNull(request.getParameter("email"));
	String sv = parseNull(request.getParameter("sv"));
%>

<!DOCTYPE html>
<html>
<head>
<%=_headhtml%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">

</head>
<body>
<%=_headerHtml%>
	<center>
		<div style="padding-top:60px; padding-bottom:60px">
		<h1>
			<%=libelle_msg(Etn, request, "Enregistrez")%>
		</h1>
		<% if("1".equals(sv)) { %>		
			<div style='margin-bottom:25px;'><%=libelle_msg(Etn, request, "Vous devez vérifier votre adresse e-mail en cliquant sur l'url envoyée à l'adresse e-mail") + " : " + PortalHelper.escapeCoteValue(email) +". " + PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Si vous ne recevez pas l'e-mail, vérifiez le dossier spam"))%></div>
		<% } else { %>
			<div style='margin-bottom:25px;'><%=libelle_msg(Etn, request, "Enregistrement réussis. Dès à présent, vous allez pouvoir vous connecter à votre compte avec votre email") + " : " + PortalHelper.escapeCoteValue(email)%></div>
		<% } %>
		</div>
	</center>
     <%=_footerHtml%>

    <%=_endscriptshtml%>

<script type="text/javascript">	
	$(document).ready(function() 
	{
	});
</script>
</body>
</html>