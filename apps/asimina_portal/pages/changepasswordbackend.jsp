<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.asimina.authentication.*"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="java.util.regex.Matcher"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>

<%@ include file="../lib_msg.jsp"%>
<%!
	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
    boolean validatePass(String password)
    {
        String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{8,})";
        Pattern r = Pattern.compile(pattern);
        Matcher m = r.matcher(password);
        if (m.find())
            return true;
        else
            return false;
    }
%>

<%
	String token = parseNull(request.getParameter("_t"));

	boolean tokenmatch = false;
	String sToken = parseNull(com.etn.asimina.session.ClientSession.getInstance().getParameter(Etn, request, "change_password_token"));
	if(sToken.equals(token)) tokenmatch = true;

	if(!tokenmatch)
	{
		out.write("{\"status\":\"5\",\"msg\":\""+libelle_msg(Etn, request, "Token mis-match. Refresh the page and try again")+"\"}");
		return;
	}

	String password = parseNull(request.getParameter("password"));
	String newpassword = parseNull(request.getParameter("newpassword"));
	String confirmpassword = parseNull(request.getParameter("confirmpassword"));
	String muid = parseNull(request.getParameter("muid"));

	com.etn.lang.ResultSet.Set rsMenu = Etn.execute("select site_id from site_menus where menu_uuid = " + com.etn.sql.escape.cote(muid));
	if(rsMenu != null && rsMenu.next())
	{
		String siteid = rsMenu.value("site_id");

		if(password.length() == 0 || newpassword.length() == 0 || confirmpassword.length() == 0)
		{
			out.write("{\"status\":1,\"msg\":\""+libelle_msg(Etn, request, "Certaines informations demandées restent à renseigner")+"\"}");
			return;
		}

		if(!newpassword.equals(confirmpassword))
		{
			out.write("{\"status\":2,\"msg\":\""+libelle_msg(Etn, request, "Le nouveau mot de passe ne correspond pas à la confirmation du mot de passe")+"\"}");
			return;
		}
		if(password.equals(newpassword))
		{
			out.write("{\"status\":2,\"msg\":\""+libelle_msg(Etn, request, "Le nouveau mot de passe ne peut pas être identique à votre ancien mot de passe")+"\"}");
			return;
		}
        else if(!validatePass(newpassword)){
            out.write("{\"status\":2,\"msg\":\""+libelle_msg(Etn, request, "Le mot de passe doit contenir une lettre majuscule, une lettre minuscule, un chiffre et doit comporter 8 caractères")+"\"}");
            return;
        }

		String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
		Set rs = Etn.execute("select * from clients where id = " + escape.cote(client_id) );
		if(rs != null && rs.next())
		{
			AsiminaAuthenticationHelper helper = new AsiminaAuthenticationHelper(Etn, siteid,com.etn.beans.app.GlobalParm.getParm("CLIENT_PASS_SALT"));
			AsiminaAuthentication auth = helper.getAuthenticationObject();
			AsiminaAuthenticationResponse resp = auth.changePassword(rs.value("username"), password,newpassword);
			if(resp.isDone())
			{
				out.write("{\"status\":\"0\",\"msg\":\""+libelle_msg(Etn, request, "Password updated successfully. You will be logged out in <span id='logOutTime'>5</span> seconds")+"\"}");
			}
			else
			{
				out.write("{\"status\":4,\"msg\":\""+libelle_msg(Etn, request, "Impossible de mettre à jour le mot de passe. Réessayer")+"\"}");
			}
		}
		else
		{
			out.write("{\"status\":3,\"msg\":\""+libelle_msg(Etn, request, "Le mot de passe saisi ne correspond pas à votre mot de passe actuel")+"\"}");
			return;
		}
	}
	else
	{
		out.write("{\"status\":\"5\",\"msg\":\""+libelle_msg(Etn, request, "Invalid menu id provided")+"\"}");
	}
%>