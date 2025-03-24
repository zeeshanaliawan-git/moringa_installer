<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.regex.*, java.util.*"%>

<%@ include file="../common.jsp" %>

<%
    String status = "success";
    int errorLine = -1;
    String message = "";
    String[] usernames = request.getParameterValues("username");
    String[] emails = request.getParameterValues("email");
    String[] personids = request.getParameterValues("personid");
    String[] firstnames = request.getParameterValues("firstname");
    String[] lastnames = request.getParameterValues("lastname");
    String[] passwords = request.getParameterValues("password");
    String[] profile = request.getParameterValues("profile");
    String[] siteid = request.getParameterValues("siteid");
 
    //validation loignname and password
    Set rs = null;
    int count = 0;
    for(int i=0; i<usernames.length;i++)
    {
        if(!usernames[i].equals("")){
            if(!validatePass(passwords[i].trim())){
                status = "error";
                errorLine = i;
                message = "Password must be at least 12 characters long with one uppercase letter, one lowercase letter, one number and one special character. Special characters allowed are !@#$%^&*";
                break;
            }
            for(int j=0; j<5; j++)
            {
                if(usernames[i].trim().equals(usernames[j].trim()) && i!=j)
                {
                    status = "error";
                    message = "Login name already exists in the list";
                    errorLine = i;
                    break;
                }
            }
            rs = Etn.execute("select count(0) c from login where name = " + escape.cote(usernames[i]));
            rs.next();
            count = Integer.parseInt(rs.value("c"));
            if(count != 0)
            {
                status = "error";
                message = "Login name already in use";
                errorLine = i;
                break;
            }
        }
    }
    
    if(status.equals("success")){

        for(int i=0; i<usernames.length;i++)
        {
            if(usernames[i].trim().length() >0)
            {
                int person_id = Etn.executeCmd("insert into person (First_name, last_name, e_mail) values ("+escape.cote(firstnames[i])+","+escape.cote(lastnames[i])+","+escape.cote(emails[i])+")");
                String[] _profiles = profile[i].split(",");
                for(int j=0;j<_profiles.length;j++)
                {
                    Etn.executeCmd("insert into profilperson (profil_id, person_id) values ("+escape.cote(_profiles[j])+","+escape.cote(""+person_id)+" )");
                    String[] siteids = parseNull(siteid[i]).split(",");
                    if(siteids != null)
                    {
                        for(int k=0;k<siteids.length;k++)
                        {
                            if(parseNull(siteids[k]).length() > 0) Etn.execute("insert into person_sites (person_id, site_id ) values ("+escape.cote(""+person_id)+", "+escape.cote(parseNull(siteids[k]))+") " );
                        }
                    }
                }
                String personuuid = java.util.UUID.randomUUID().toString();
                Etn.executeCmd("insert into login (pid, name, pass, puid, pass_expiry) values ("+escape.cote(""+person_id)+","+escape.cote(usernames[i])+", sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",'$',"+escape.cote(passwords[i])+",'$',"+escape.cote(personuuid)+"),256), "+escape.cote(personuuid)+", adddate(now(), interval 90 day))");
            }
        }
        message = "Users added successfully!!!";
    }
out.write("{\"status\":\""+status+"\",\"errorline\":\""+errorLine+"\",\"message\":\""+message+"\"}");

%>