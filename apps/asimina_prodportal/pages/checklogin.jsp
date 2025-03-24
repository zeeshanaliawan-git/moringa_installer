<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.Base64"%>

<%@ include file="../clientcommon.jsp"%>
<%@ include file="../lib_msg.jsp"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

%>

<%
	String muid = parseNull(request.getParameter("muid"));

    String login = "";
    String profil = "no_profil";

	String myaccountlocation = com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"pages/myaccount.jsp?muid="+muid;
	String sessionexpiredlocation = com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"pages/sessionexpired.jsp?muid="+muid;

	//not checking if logged-in user is of same site because we are not supporting this for the time-being
	//com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request, muid);
	com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	
	if(client == null)
	{
		out.write("{\"loggedin\":\"0\",\"goto\":\""+sessionexpiredlocation+"\",\"login\":\""+login+"\"}");
		return;
	}	
	
	login = parseNull(client.getProperty("login"));
	Set rsClient = Etn.execute("select profil from clients where id="+escape.cote(parseNull(client.getProperty("id"))));
	rsClient.next();
	if(!rsClient.value(0).equals("")) profil = rsClient.value(0);
	
	out.write("{\"loggedin\":\"1\",\"goto\":\""+myaccountlocation+"\",\"login\":\""+login+"\",\"profil\":\""+profil+"\"}");
%>
