<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ include file="common2.jsp" %>
<%@ include file="lib_msg.jsp" %>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.util.*" %>
<%@include file="countryspecific/commonmethods.jsp"%>

<%! 

	String parseNull(Object o) 
	{
		if( o == null )
			return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase()))
			return("");
		else
			return(s.trim());
	}

%>
<%
	String _error_msg = "";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";

	String mid = getDefaultMenuId(Etn, request);
	if(mid.length() == 0)
	{
		out.write("No menu id found");
		return;
	}
	Set __rs = Etn.execute("select * from site_menus where id = " + escape.cote(mid));
	__rs.next();

	String msg = "Some error occurred";
	msg = parseNull(com.etn.asimina.session.PortalSession.getInstance().getParameter(Etn, request, "_error_msg"));
	com.etn.asimina.session.PortalSession.getInstance().removeParameter(Etn, request, "_error_msg");	

%>
<%@ include file="headerfooter.jsp"%>

<!doctype html>
<html lang="<%=_lang%>" >
<head>
<%=_headhtml%>
<style>
  .etn-orange-portal-- table.o-results tr td{
    padding: 15px;
  }
</style>

</head>
<body>
<div class="etn-orange-portal--">
<%=_headerHtml%>
<div id="container" class="o-container">	
	<center>
	<div style='margin-top:25px; margin-bottom:25px'>
		<span style='color:red; font-size:20px; font-weight:bold'><%=libelle_msg(Etn, request, msg)%></span>
	</div>
	</center>
</div>
</div>

 <%=_footerHtml%>

 <%=_endscriptshtml%>
</body>
</html>