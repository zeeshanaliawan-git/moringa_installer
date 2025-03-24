<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, java.util.Map, java.util.LinkedHashMap"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<%
	String selectedsiteid = getSelectedSiteId(session);

	String token = com.etn.asimina.util.UIHelper.getWebappAuthToken(Etn, request);

%>
<html>
<body>
	<form name='afrm' method='post' action='<%=com.etn.beans.app.GlobalParm.getParm("MENU_DESIGNER_URL") + "pages/site.jsp?id="+selectedsiteid%>'>
		<input type='hidden' name='__wt' value='<%=token%>' />
	</form>
</body>
<script>
	document.afrm.submit();
</script>
</html>