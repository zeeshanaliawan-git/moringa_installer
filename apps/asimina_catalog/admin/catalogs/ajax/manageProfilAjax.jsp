<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte,java.nio.charset.StandardCharsets, com.etn.beans.app.GlobalParm,org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter,java.text.SimpleDateFormat"%>
<%@ page import="org.json.*, java.util.*,java.io.*,org.apache.commons.io.comparator.LastModifiedFileComparator" %>


<%!
    String parseNull(Object o) {
        if (o == null || "null".equalsIgnoreCase(o.toString().trim())) {
            return "";
        } else {
            return o.toString().trim();
        }
    }

    boolean isExist(Contexte Etn, String profil)
    {
        String dbname = GlobalParm.getParm("PORTAL_DB");
        Set rs = Etn.execute("select * from "+dbname+".clients  where profil ="+escape.cote(profil)); 
        if(rs.rs.Rows>0) return true;
        return false;
    }

    boolean isExist2(Contexte Etn, String deleteProfils)
    {
        String dbname = GlobalParm.getParm("PORTAL_DB");
        Set rs = Etn.execute("select * from "+dbname+".clients  where profil ="+escape.cote(deleteProfils)); 
        if(rs.rs.Rows>0) return true;
        return false;
    }
%>
<%
    int status = 0;
    String message = "";
    String err_code = "";
    JSONObject json = new JSONObject();
    JSONObject data = new JSONObject();
    

    final String method = parseNull(request.getMethod());
    try {
        if (method.length() > 0 && method.equalsIgnoreCase("POST")) {
            final String requestType = parseNull(request.getParameter("requestType"));
            final String profil = parseNull(request.getParameter("profil"));
            final String deleteProfils = parseNull(request.getParameter("deleteProfils"));
            if (requestType.length() > 0) {
                if (requestType.equalsIgnoreCase("delete")) {
                    if(isExist(Etn,profil))
                    { 
                        status = 30;
                        err_code = "CLIENT_PROFIL_ALREADY_IN_USE";
                        message = "Client profil already in use";
                    }
                    else
                    {
                        Etn.execute("DELETE FROM client_profil where profil="+escape.cote(profil));
                        status = 0;
                        message = "Successfully deleted!";
                    }
                }
                else if (requestType.equalsIgnoreCase("deleteProfil")){
                    if(isExist2(Etn,deleteProfils)){
                    status = 30;
                    err_code = "CLIENT_PROFIL_ALREADY_IN_USE";
                    message = "Client profil already in use";
                    }
                    else{
                        if(deleteProfils != null){
                            Set rsUsers = Etn.execute("select * from profilperson where profil_id = "+escape.cote(deleteProfils));
                            if(rsUsers.rs.Rows > 0){
                                Set User = Etn.execute("select description from profil where profil_id = "+escape.cote(deleteProfils));
                                User.next();
                                Set User2 = Etn.execute("select concat(p.First_name, ' ', p.last_name) as name from person p where person_id in (select person_id from profilperson where profil_id=" + escape.cote(deleteProfils) + ")");
                                User2.next();
                                status = 40;
                             message = "This profile \"" + User.value("description") + "\" can not be deleted because it is currently assigned to the user \"" + User2.value("name") + "\"";

                            }
                            else 
                            {
                                Etn.executeCmd("delete from profil where profil_id = "+escape.cote(deleteProfils));			
                                Etn.executeCmd("delete from page_profil where profil_id = "+escape.cote(deleteProfils));			
                                message = "Successfully deleted";
                            }
                        }

                    }
                } 
                else {
                    status = 20;
                    err_code = "INVALID_ACTIONS";
                    message = "Provided action is invalid";
                }
            } else {
                status = 10;
                err_code = "ACTION_IS_MISSING";
                message = "Action is missing";
            }

        } else {
            status = 100;
            err_code = "NOT_SUPPORTED";
            message = "fetch.jsp does not support the " + method + " method";
        }
    } catch (Exception e) {
        status = 150;
        err_code = "SYSTEM_ERROR";
        message = "Something went wrong";
    }

    if(err_code.length() > 0 && status > 0)
    {
        JSONObject jobj = new JSONObject();
        json.put("err_code",err_code);
        json.put("err_msg",message);
        json.put("data",jobj);
    }else{
        json.put("status",status);
        json.put("message",message);
    }

    out.write(json.toString());
%>