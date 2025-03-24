<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.*, com.etn.util.Base64, org.json.*"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<%@ include file="../lib_msg.jsp"%>
<%@ include file="../commonlogin.jsp"%>
<%@ include file="../getuserhomepage.jsp"%>

<%!
	public boolean isValidEmailAddress(String email) 
	{
       	String ePattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$";
		java.util.regex.Pattern p = java.util.regex.Pattern.compile(ePattern);
           	java.util.regex.Matcher m = p.matcher(email);
           	return m.matches();
   	}
%>


<%
	String token = parseNull(request.getParameter("_t"));
	boolean tokenmatch = false;

	String sToken = parseNull(com.etn.asimina.session.ClientSession.getInstance().getParameter(Etn, request, "signup_token"));
	if(sToken.equals(token)) tokenmatch = true;

	if(!tokenmatch)
	{
		out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Token mis-match. Refresh the page and try again")+"\"}");
		return;
	}

	HashSet<String> excludeCols = new HashSet<String>(Arrays.asList(
		"email",
		"name",
		"civility",
		"password",
		"surname",
		"fixe",
		"mobile",
		"mobile_number",
		"lastloadedmenuid",
		"mobile_orangeid",
		"mobile_orangepassword",
		"fixe_orangeid",
		"fixe_orangepassword",
		"t",
		"muid",
		"r",
		"_t",
		"showUsernameField"
	));
	JSONObject additional_info = new JSONObject();
	
	Map<String, String[]> parameters = request.getParameterMap();
	for(String parameter : parameters.keySet()) 
	{
		if(!excludeCols.contains(parameter)) additional_info.put(parameter,parseNull(request.getParameter(parameter)));
	}
                
	String email = parseNull(request.getParameter("email"));
	String civility = parseNull(request.getParameter("civility"));
	String name = parseNull(request.getParameter("name"));
	String surname = parseNull(request.getParameter("surname"));
	String mobile_number = parseNull(request.getParameter("mobile_number"));
	String lastloadedmenuid = parseNull(request.getParameter("lastloadedmenuid"));
	String muid = parseNull(request.getParameter("muid"));
	String showUsernameField = parseNull(request.getParameter("showUsernameField"));
	String username = parseNull(request.getParameter("username"));

	//redirect to this page after successful registration and if the flag auto verify user is 1
	String ___ref = parseNull(request.getParameter("r"));

	if("1".equals(showUsernameField))
	{
		if(username.length() == 0 || email.length() == 0 || name.length() == 0)
		{
			out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Certaines informations demandées restent à renseigner")+"\"}");
			return;
		}		
	}
	else
	{
		if(email.length() == 0 || name.length() == 0)
		{
			out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Certaines informations demandées restent à renseigner")+"\"}");
			return;
		}	
		username = email;		
	}

	if(!(isValidEmailAddress(email)))
	{
		out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "adresse mail invalide fournie")+"\"}");
		return;
	}

	String siteid = parseNull(request.getParameter("site_id"));
	if(siteid.length() == 0)
	{
		Set rsMenu = Etn.execute("Select * from site_menus where menu_uuid = " + escape.cote(muid));
		if(rsMenu.next()) siteid = rsMenu.value("site_id");
	}
	if(siteid.length() == 0)
	{
		System.out.println("ERROR::signupbackend.jsp::site id is missing");
		out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Unable to register due to missing information")+"\"}");
		return;
	}

	Set rs = Etn.execute("select * from clients where site_id = "+escape.cote(siteid)+" and username = " + escape.cote(username));
	if(rs.rs.Rows > 0)
	{
		if("1".equals(showUsernameField)) out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Ce nom d'utilisateur est déjà pris")+"\"}");
		else out.write("{\"status\":\"error\",\"msg\":\""+libelle_msg(Etn, request, "Cette adresse mail a déjà été enregistrée")+"\"}");
	}
	else 
	{
		String autoVerifyUser = parseNull(com.etn.beans.app.GlobalParm.getParm("AUTO_VERIFY_CLIENT"));		
		boolean autoLogin = false;
		//referrer is not empty means its coming from cart screen so we must auto-login
		if(___ref.length() > 0) autoLogin = true;
		
		String sendVerificationEmail = "0";
		if(!autoVerifyUser.equals("1")) 
		{
			autoVerifyUser = "0";
			sendVerificationEmail = "1";
		}
		
		String client_profil_id = "";
		Set rsClientProfil = Etn.execute("select id from client_profils where site_id = "+escape.cote(siteid)+" and is_default=1;");
		if(rsClientProfil.next()) client_profil_id = rsClientProfil.value("id");
		//by default we are setting is_verified = 1 for testing purposes 
		int id = Etn.executeCmd("insert into clients (civility,username, signup_menu_uuid, send_verification_email, site_id, mobile_number, client_uuid, email, name, surname, is_verified, client_profil_id, additional_info) values ("+escape.cote(civility)+","+escape.cote(username)+","+escape.cote(muid)+","+escape.cote(sendVerificationEmail)+","+escape.cote(siteid)+","+escape.cote(mobile_number)+",uuid(), "+escape.cote(email)+","+escape.cote(name)+","+escape.cote(surname)+", "+escape.cote(autoVerifyUser)+", "+escape.cote(client_profil_id)+", "+escape.cote(additional_info.toString())+") ");

		com.etn.asimina.session.ClientSession.getInstance().removeParameter(Etn, request, "signup_token");
 
		String gotoUrl = com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")+"pages/signupsuccess.jsp?muid="+muid+"&email="+email+"&sv="+sendVerificationEmail;

		if(autoLogin)
		{
			gotoUrl = ___ref;
			String _usrname = username;
			if(!"1".equals(showUsernameField)) _usrname = email;
			String json = doLogin(Etn, request,  response, muid, _usrname, "", false, "0", true);
		}
		com.etn.asimina.session.ClientSession.getInstance().removeParameter(Etn, request, "signup_token");
		out.write("{\"status\":\"success\",\"goto\":\""+gotoUrl+"\"}");
	}		

%>