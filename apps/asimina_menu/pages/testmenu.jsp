<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64"%>

<html>
<head>
	<title>Portal</title>
	<link rel="stylesheet" type="text/css" href="../menu_resources/css/bootstrap__portal__.css">
	<link rel="stylesheet" type="text/css" href="../menu_resources/css/header__portal__.css">
	<link rel="stylesheet" type="text/css" href="../menu_resources/css/global__portal__.css">
	<link rel="stylesheet" type="text/css" href="../menu_resources/css/orange_socialbar__portal__.css">

	<script type="text/javascript" src="../js/jquery.min.js"></script>

    <script type="text/javascript " src="../menu_resources/js/script.js "></script>

</head>
<body >
	<jsp:include page='generatemenu.jsp'>
		<jsp:param name='menuid' value='9'/>
		<jsp:param name='ispreview' value='1' />
	</jsp:include>
</body>
</html>
