<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog,  java.util.regex.* "%>
<%@ page import="com.etn.asimina.authentication.*"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="java.util.regex.Matcher"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null )
			return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase()))
			return("");
		else
			return(s.trim());
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
    String clientUuid = parseNull(request.getParameter("uuid"));
	String password = parseNull(request.getParameter("password"));
	String login = parseNull(request.getParameter("login"));
	String email = parseNull(request.getParameter("email"));
	String site_id = parseNull(request.getParameter("site_id"));
	String lsu = parseNull(request.getParameter("lsu"));
	String isEmail = parseNull(request.getParameter("isEmail"));
	
	String portaldb = GlobalParm.getParm("PROD_PORTAL_DB");
	com.etn.util.Logger.debug("resetClientPassword.jsp","Site ID: " + site_id);
	com.etn.util.Logger.debug("resetClientPassword.jsp","isEmail: " + isEmail);
	com.etn.util.Logger.debug("resetClientPassword.jsp","lsu: "+ lsu);


	if(lsu.equalsIgnoreCase("true")) portaldb = GlobalParm.getParm("PORTAL_DB");

	if(isEmail.equalsIgnoreCase("true"))
	{
		boolean forgotPasswordFormConfigured = false;
		Set rs = Etn.execute("Select form_id, table_name from "+GlobalParm.getParm("FORM_DB")+".process_forms where type='forgot_password' and site_id="+escape.cote(site_id));
		if(rs.next()) forgotPasswordFormConfigured = true;

		if(forgotPasswordFormConfigured)
		{	
			Set result = Etn.execute("select * from "+portaldb+".site_menus where lang = (select langue_code from language order by langue_id limit 1) and  site_id = "+escape.cote(site_id)+" and is_active = 1 union select * from "+portaldb+".site_menus where site_id = "+escape.cote(site_id)+" and is_active = 1 limit 1;");
			if(result.next()) 
			{	
				
				Set link = Etn.execute("select * from "+portaldb+".config where code = 'EXTERNAL_LINK'");
				link.next();

				int pid = Etn.executeCmd("insert into "+GlobalParm.getParm("FORM_DB")+"."+rs.value("table_name")+" (rule_id, form_id, created_on ,menu_lang, mid, portalurl, _etn_email, _etn_login) values(0,"+escape.cote(rs.value("form_id"))+",NOW(),"+escape.cote(result.value("lang"))+","+escape.cote(result.value("id"))+","+escape.cote(link.value("val"))+","+escape.cote(email)+","+escape.cote(login)+")");
				Etn.executeCmd("insert into "+GlobalParm.getParm("FORM_DB")+".post_work (proces,phase,priority,insertion_date,client_key,form_table_name) values("+escape.cote(rs.value("table_name"))+",'FormSubmitted',NOW(),NOW(),"+escape.cote(pid+"")+","+escape.cote(rs.value("table_name"))+")");
				Etn.execute("select semfree('"+GlobalParm.getParm("SEMAPHORE")+"')");
				
				com.etn.util.Logger.debug("resetClientPassword.jsp","menu_uuid: "+result.value("menu_uuid"));
				com.etn.util.Logger.debug("resetClientPassword.jsp","Row inserted successfully");
				out.write("{\"STATUS\":\"SUCCESS\",\"msg\":\"Reset Email has been sent\"}");
			}
			
		}
		else{
			com.etn.util.Logger.debug("resetClientPassword.jsp","Not inserted");
			out.write("{\"STATUS\":\"ERROR\",\"msg\":\"Error occured while sending Email\"}");
		}
	}
	else{
		if(clientUuid.length() > 0)
		{
			if(validatePass(password)){
				com.etn.util.Logger.debug("resetClientPassword.jsp","Updating password by Admin");
				AsiminaAuthenticationHelper helper = new AsiminaAuthenticationHelper(Etn, site_id,com.etn.beans.app.GlobalParm.getParm("PROD_PORTAL_DB"),com.etn.beans.app.GlobalParm.getParm("CLIENT_PASS_SALT"));
				AsiminaAuthentication auth = helper.getAuthenticationObject();
				AsiminaAuthenticationResponse resp = auth.forceChangePassword(login, password);
				if(resp.isDone())
				{
					com.etn.util.Logger.debug("resetClientPassword.jsp","password updated successfully");
					out.write("{\"STATUS\":\"SUCCESS\",\"msg\":\"Password changed successfully\"}");	
				}
				else{
					com.etn.util.Logger.debug("resetClientPassword.jsp","Failed to update password by admin");
					out.write("{\"STATUS\":\"ERROR\",\"msg\":\"Unable to change password\"}");
				}
			}else{
				out.write("{\"STATUS\":\"INVALID\",\"msg\":\""+ "Password must be at least 12 characters long with one uppercase letter, one lowercase letter, one number and one special character. Special characters allowed are !@#$%^&*"+"\"}");
			}
		}
	}
%>