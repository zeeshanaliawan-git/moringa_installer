<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>

<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%!
	void callUrl(String u)
	{
		java.net.HttpURLConnection con = null;
		try
		{			
			System.out.println(u );	
			java.net.URL url = new java.net.URL(u);
			con = (java.net.HttpURLConnection)url.openConnection();
			con.setRequestProperty("User-Agent", "Mozilla/5.0");		
			int responseCode = con.getResponseCode();
			System.out.println(" resp code : " + responseCode );	
		}		
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
%>
<%
	callUrl("http://127.0.0.1/"+GlobalParm.getParm("PORTAL_APP")+"/reloadpagetemplate.jsp?id=all&t="+System.currentTimeMillis());
	callUrl("http://127.0.0.1/"+GlobalParm.getParm("PROD_PORTAL_APP")+"/reloadpagetemplate.jsp?id=all&t="+System.currentTimeMillis());
%>
{"status":0}