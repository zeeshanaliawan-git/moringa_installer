<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape"%>
<%@ page import="java.io.DataInputStream"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<%@ page import="java.io.FileInputStream, java.io.OutputStream,org.apache.tika.*,com.etn.asimina.util.FileUtil"%>
<%@ page import="java.io.File"%>

<%!
    String parseNull(Object o) {
        if (o == null) {
            return ("");
        }
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }
%>
<%
    String authorizationHeader = request.getHeader("Authorization");
    
    if (authorizationHeader != null && authorizationHeader.startsWith("Basic ")) {
        
        String credentials = new String(javax.xml.bind.DatatypeConverter.parseBase64Binary(authorizationHeader.substring(6)));
        String[] parts = credentials.split(":");

        Set rsPass = Etn.execute("select l.pass,sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(parts[1])+
            ",':',l.puid),256),p.profil from login l left join profilperson pp on l.pid = pp.person_id left join profil p on pp.profil_id=p.profil_id  where l.name = "+
            escape.cote(parts[0]));

        if(rsPass.next() && parseNull(rsPass.value(0)).equals(parseNull(rsPass.value(1)))) {
            if(parseNull(rsPass.value(2)).equalsIgnoreCase("TEST_SITE_ACCESS")){

                String formId = parseNull(request.getParameter("formId"));
                String rowId = parseNull(request.getParameter("rowId"));
                String mediaName = parseNull(request.getParameter("mediaName"));

                if(formId.length()<=0){
                    out.write("Form id required");
                } else if(rowId.length()<=0){
                    out.write("Row id required");
                } else if(mediaName.length()<=0){
                    out.write("Media name required");
                }else{
					//before using any request parameter in path for a file we must cleanup that
                    String path = parseNull(GlobalParm.getParm("FORM_UPLOADS_ROOT_PATH"))+formId.replaceAll("/", "").replaceAll("\\\\", "")+"/"+rowId.replaceAll("/", "").replaceAll("\\\\", "")+"/"+mediaName.replaceAll("/", "").replaceAll("\\\\", "");
                    File downloadMediaDir = FileUtil.getFile(path);//change

                    if (downloadMediaDir.exists()) {
                        
                        response.setContentType(new Tika().detect(path));
                        response.setHeader("Content-Disposition", "attachment; filename=\"" + mediaName.replaceAll("/", "").replaceAll("\\\\", "") + "\"");
                        
                        try{
                            FileInputStream fis = new FileInputStream(downloadMediaDir);
                            OutputStream os = response.getOutputStream();

                            byte[] buffer = new byte[4096];
                            int bytesRead;

                            while ((bytesRead = fis.read(buffer)) != -1) {
                                os.write(buffer, 0, bytesRead);
                            }
                            os.flush();
                            os.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }else{
                        out.write("File does not exist for Form id:"+formId+", Row id:"+rowId+", Media name"+mediaName);
                    }
                }

            }else{
                out.write("Unauthenticated");
            }
        }else{
            out.write("Unauthorized");
        }
    } else {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setHeader("WWW-Authenticate", "Basic realm=\"Your Auth\"");
        out.write("Authentication required.");
    }
%>
