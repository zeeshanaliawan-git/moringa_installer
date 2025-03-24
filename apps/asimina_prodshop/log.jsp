<%@page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.io.*,com.etn.asimina.util.FileUtil"%>
<%
  response.setContentType("text/plain;charset=UTF-8");
  String tmp = "/tmp/"+session.getId();
  String cmd[] = new String[2];
  cmd[0] = "/home/umair/pjt/mshop/viewlog";
  cmd[1] = tmp;
  Process p = Runtime.getRuntime().exec( cmd);

  p.waitFor();
  int err = p.exitValue();

  File f = FileUtil.getFile( tmp );//change
  FileInputStream in = new FileInputStream(f);
  byte b[] = new byte[4096];
  int i;
  while( ( i = in.read(b) ) != -1 )
    out.write( new String( b , 0 , i) );

  in.close();
  f.delete();

%>
