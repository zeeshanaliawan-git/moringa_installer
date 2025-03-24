<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.ArrayList, com.etn.beans.app.GlobalParm"%>

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


%>

<%
	String pMuid = parseNull(request.getParameter("muid"));
	if(com.etn.asimina.session.ClientSession.getInstance().isClientLoggedIn(Etn, request) == true)
	{
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK") + "pages/myaccount.jsp?muid="+	pMuid);
		return;		
	}

	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";
	
%>

<%@ include file="../headerfooter.jsp"%>

<% if(___authPageUrl.length() > 0){
	response.sendRedirect(___authPageUrl + "?tm="+System.currentTimeMillis()+"&exp=1&msg="+libelle_msg(Etn, request, "Your session is already expired"));
	return;
}else{%>

<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
	<%=_headhtml%>
	<% if(____menuVersion.equalsIgnoreCase("v1")){%>
	<link href="<%=GlobalParm.getParm("CATALOG_LINK")%>css/newui/style.css?__v=<%=GlobalParm.getParm("CSS_JS_VERSION")%>" rel="stylesheet" type="text/css">
	<%}%>
	<title><%=libelle_msg(Etn, request, "Session expired")%></title>
</head>
<body>
    <%=_headerHtml%>
	<div class="etn-orange-portal--">
	<center>
	<div style='color:red; margin-top:5%; margin-bottom:5%; font-size:24px'><%=libelle_msg(Etn, request, "Your session is already expired")%></div>
	</center>
	</div>
     <%=_footerHtml%>

    <%=_endscriptshtml%>
</body>
</html>
<%}%>