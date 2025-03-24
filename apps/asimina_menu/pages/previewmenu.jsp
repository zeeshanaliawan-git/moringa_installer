<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="common.jsp"%>

<%	
	String menuid = request.getParameter("menuid");
	String isprod = request.getParameter("p");

%>
<html>
<head>
	<title>Portal</title>
	<link href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/newui/headerfooter.css" rel="stylesheet" type="text/css">


	<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/js/newui/portalbundle.js"></script> 
	<script type='text/javascript'>var ___portaljquery = $;</script>
	<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/js/newui/headerfooterbundle.js"></script> 

</head>
<body > 
	<jsp:include page='generatemenu.jsp'>
		<jsp:param name='menuid' value='<%=escapeCoteValue(menuid)%>'/>
		<jsp:param name='ispreview' value='1' />
		<jsp:param name='isprod' value='<%=escapeCoteValue(isprod)%>' />
	</jsp:include>
	<div style='height:95px; text-align:center; padding-top:50px; font-size:20px'>
		<span style='color:#ddd'>PAGE CONTENTS</span>
	</div>
	<jsp:include page='generatefooter.jsp'>
		<jsp:param name='menuid' value='<%=escapeCoteValue(menuid)%>'/>
		<jsp:param name='ispreview' value='1' />
		<jsp:param name='isprod' value='<%=escapeCoteValue(isprod)%>' />
	</jsp:include>
</body>
</html>
