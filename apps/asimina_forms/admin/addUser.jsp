<%
	String _id = request.getParameter("id");
	String lang = request.getParameter("lang");

	String url = request.getContextPath() + "/forms.jsp";
	url += "?lang="+lang+"&form_id=" + _id + "&is_admin=1";

%>
<html>
<head>
<title>Add User</title>
</head>
<body>
<iframe src='<%=url%>' style='border:none; height:100%; width:100%'></iframe>
</body>
</html>