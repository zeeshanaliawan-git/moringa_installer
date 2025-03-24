<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog, java.util.regex.*, java.util.* "%>

<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%
    String status = "success";
     int errorLine = -1;
    String message = "";
    String saveUsers = parseNull(request.getParameter("saveUsers"));
    if(saveUsers.equals("")) saveUsers = "0";
    String updateUsers = parseNull(request.getParameter("updateUsers"));
    if(updateUsers.equals("")) updateUsers = "0";
    String[] usernames = request.getParameterValues("username");
    String[] emails = request.getParameterValues("email");
    String[] personids = request.getParameterValues("personid");
    String[] firstnames = request.getParameterValues("firstname");
    String[] lastnames = request.getParameterValues("lastname");
    String[] passwords = request.getParameterValues("password");
    String[] profile = request.getParameterValues("profile");
    String[] deleteUsers = request.getParameterValues("deleteUser");
    String[] siteid = request.getParameterValues("siteid");

    String currentuserprofil = "";
    if(session.getAttribute("PROFIL") != null) currentuserprofil = (String)session.getAttribute("PROFIL");

    List<String> assignSiteProfils = new ArrayList<String>();
    Map<String, String> profiles = new LinkedHashMap<String, String>();
    Set rsProfile = Etn.execute("select * from profil order by description ");
//  profiles.put("#","-- Selecciona perfil --");
    while(rsProfile.next())
    {
        profiles.put(rsProfile.value("profil_id"),rsProfile.value("description"));

        if("1".equals(rsProfile.value("assign_site"))) assignSiteProfils.add(rsProfile.value("profil_id"));
    }
    //validation loignname and password
    Set rs = null;
    int count = 0;
    for(int i=0; i<usernames.length;i++)
    {
        if(!usernames[i].equals("")){
            if(!com.etn.asimina.util.UIHelper.validatePass(parseNull(passwords[i]))){
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

        if(usernames != null && ("ADMIN".equalsIgnoreCase(currentuserprofil) || "SUPER_ADMIN".equalsIgnoreCase(currentuserprofil)) )
        {
            String personsIds = "";
            String personsNames = "";
            for(int i=0; i<usernames.length;i++)
            {

                if(usernames[i].trim().length() >0)
                {
                    int person_id = Etn.executeCmd("insert into person (First_name, last_name,e_mail) values ("+escape.cote(firstnames[i])+","+escape.cote(lastnames[i])+","+escape.cote(emails[i])+")");

                    if(personsIds.length()>0)
                        personsIds += ",";
                    personsIds +=  person_id;
                    if(personsNames.length()>0)
                        personsNames += ", ";
                    personsNames +=  firstnames[i];


                    Etn.executeCmd("insert into profilperson (profil_id, person_id) values ("+escape.cote(profile[i])+","+escape.cote(""+person_id)+")");
                    if(assignSiteProfils.contains(profile[i]))
                    {
                        String[] siteids = parseNull(siteid[i]).split(",");
                        if(siteids != null)
                        {
                            for(int j=0;j<siteids.length;j++)
                            {
                                if(parseNull(siteids[j]).length() > 0) Etn.execute("insert into person_sites (person_id, site_id ) values ("+escape.cote(""+person_id)+", "+escape.cote(parseNull(siteids[j]))+") " );
                            }
                        }
                    }
                    String personuuid = java.util.UUID.randomUUID().toString();
                    Etn.executeCmd("insert into login (pid, name, pass, puid, pass_expiry) values ("+escape.cote(""+person_id)+","+escape.cote(usernames[i])+", sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(passwords[i])+",':',"+escape.cote(personuuid)+"),256), "+escape.cote(personuuid)+", adddate(now(), interval 90 day))");
                }
            }

            message = "Users added successfully!!!";
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),personsIds,"CREATED","Users",personsNames,parseNull(getSelectedSiteId(session)));
        }
    }

out.write("{\"status\":\""+status+"\",\"errorline\":\""+errorLine+"\",\"message\":\""+message+"\"}");

%>