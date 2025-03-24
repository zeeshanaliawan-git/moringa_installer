<%
	if(session.getAttribute("PROD_SITE_URL") != null)
	{
		String url = (String)session.getAttribute("PROD_SITE_URL");
		session.removeAttribute("PROD_SITE_URL");
		response.sendRedirect(url);
		return;
	}
	response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
%>