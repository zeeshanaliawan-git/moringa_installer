<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%
	String url = request.getParameter("u");
	
	if(url == null || url.length() == 0)
	{
		out.write("<html><body><h1 style='color:red'>Page not found</h1></body></html>");
		return;					
	}
	url = "http://127.0.0.1" + url;
	url = new java.net.URL(url).toURI().toASCIIString();
	
	out.write(org.jsoup.Jsoup.connect(url).get().html());
%>