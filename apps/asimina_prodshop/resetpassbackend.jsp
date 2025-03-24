<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, java.util.regex.*,com.etn.beans.app.GlobalParm"%>
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
        String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{12,})";
        Pattern r = Pattern.compile(pattern);
        Matcher m = r.matcher(password);
        if (m.find())
            return true;
        else
            return false;
    }

%>
<%
	String ftoken = parseNull(request.getParameter("ftoken"));
	String password = parseNull(request.getParameter("password"));
    String confirmPassword = parseNull(request.getParameter("confirmPassword"));

	if(ftoken.length() == 0)
	{
		out.write("{\"status\":\"error\",\"msg\":\""+"Invalid token provided"+"\"}");
		return;
	}
	if(password.length() == 0)
	{
		out.write("{\"status\":\"error\",\"msg\":\""+"You must provide a password"+"\"}");
		return;
	}
    if(!password.equals(confirmPassword)){
        out.write("{\"status\":\"error\",\"msg\":\""+"Password did not match"+"\"}");
        return;
    }
    if(!validatePass(password)){
        out.write("{\"status\":\"error\",\"msg\":\""+ "Password must be at least 12 characters long with one uppercase letter, one lowercase letter, one number and one special character. Special characters allowed are !@#$%^&*"+"\"}");
        return;
    }

	Set rs = Etn.execute("select * from person where forgot_pass_token_expiry >= now() and forgot_pass_token = " + escape.cote(ftoken));
	if(rs.next())
	{
		// set the password
        int rowsUpdated = Etn.executeCmd("update login set pass_expiry = adddate(now(), interval 90 day), pass = sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",'$',"+escape.cote(password)+",'$',puid),256) where pid = "+escape.cote(parseNull(rs.value("person_id")))+" ");
		if(rowsUpdated>0)
		{
			Etn.executeCmd("update person set forgot_pass_token = null, forgot_pass_token_expiry = null where person_id = " + escape.cote(parseNull(rs.value("person_id"))));
			out.write("{\"status\":\"success\",\"msg\":\""+"Password updated successfully"+"\"}");
		}
		else
		{
			out.write("{\"status\":4,\"msg\":\""+"Unable to update password. Try again"+"\"}");
		}
	}
	else
	{
		out.write("{\"status\":\"error\",\"msg\":\""+"Invalid token provided. The token may have expired or used already"+"\"}");
	}

%>
