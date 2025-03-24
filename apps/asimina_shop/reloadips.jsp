
<%
	ServletContext sc  = getServletContext();
	out.write(request.getRemoteAddr());
	sc.setAttribute("RELOAD_IPS","1");
%>