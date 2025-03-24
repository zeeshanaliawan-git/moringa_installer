<% response.setHeader("X-Frame-Options","deny"); %>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, javax.servlet.http.Cookie"%>

<%@ page import="com.etn.asimina.authentication.*"%>

<%@ include file="lib_msg.jsp"%>
<%@ include file="commonlogin.jsp"%>
<%@ include file="getuserhomepage.jsp"%>

<%
	String username = parseNull(request.getParameter("username"));
	String password = parseNull(request.getParameter("password"));
	String token = parseNull(request.getParameter("logintoken"));
	String formtype = parseNull(request.getParameter("formtype"));
	String rememberme = parseNull(request.getParameter("rememberme"));

	String sessiontoken = "";
	boolean isMenuLogin = false;
	com.etn.util.Logger.info("dologin.jsp","---------------------------------------------");
	com.etn.util.Logger.info("dologin.jsp","dologin::"+request.getSession().getId());
	com.etn.util.Logger.info("dologin.jsp","---------------------------------------------");

	if(formtype.length() == 0)//we assume this form is the top menu login form
	{
		sessiontoken = parseNull(com.etn.asimina.session.ClientSession.getInstance().getParameter(Etn, request, "logintoken"));
		isMenuLogin = true;
	}
	else //when formtype length is more than 0 it means this form was popup login on cart.jsp in which case we get token from session attribute logintoken2
	{
		sessiontoken = parseNull(com.etn.asimina.session.ClientSession.getInstance().getParameter(Etn, request, "logintoken2"));
	}

	String ______muid = parseNull(request.getParameter("muid"));
	com.etn.asimina.session.ClientSession.getInstance().addParameter(Etn, request, response, "login_muid", ______muid);	

	if(!sessiontoken.equals(token))
	{
		out.write("{\"status\":150, \"response\":\"error\",\"message\":\""+libelle_msg(Etn, request, "Login token expired. Refresh the page and try again")+"\"}");
		return;
	}

	if(username.length() == 0 || password.length() == 0)
	{
		out.write("{\"status\":250, \"response\":\"error\",\"message\":\""+libelle_msg(Etn, request, "Enter a valid username and password")+"\"}");
		return;
	}

	String json = doLogin(Etn, request,  response, ______muid, username, password, isMenuLogin, rememberme);

	out.write(json);

%>
