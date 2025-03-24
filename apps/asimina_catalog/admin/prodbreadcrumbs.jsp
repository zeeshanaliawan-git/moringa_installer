<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, java.util.Map, java.util.LinkedHashMap"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%
	String accessid = getAccessId(Etn);

%>
<!DOCTYPE html>
<html>
<body>
	<form name='afrm' method='post' action='<%=com.etn.beans.app.GlobalParm.getParm("MENU_DESIGNER_URL") + "pages/sitemap/prodbreadcrumbs.jsp"%>'>
		<input type='hidden' name='__aid' value='<%=accessid%>' />
		<input type='hidden' name='__csid' value='<%=session.getId()%>' />
	</form>
</body>
<script>
	document.afrm.submit();
</script>
</html>
