<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

String c = request.getParameter("c");
if(c == null) c = "";
%>

<html>
<body>
<h1>You are not authorized to access this page</h1>
<%
if("1".equals(c) == false){
%>
<input type='button' value='Go to Dashboard' onclick='javascript:window.location="<%=request.getContextPath()%>/ibo.jsp";' />
<%}%>
<% if(Etn.getId() > 0) { %>
&nbsp;&nbsp;
<input type='button' value='Logout' onclick='javascript:window.location="<%=request.getContextPath()%>/logout.jsp?t=<%=System.currentTimeMillis()%>";' />
<% } %>
</body>
</html>