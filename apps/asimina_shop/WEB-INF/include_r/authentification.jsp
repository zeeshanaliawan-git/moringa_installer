<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.beans.app.GlobalParm" %>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="java.io.ByteArrayOutputStream"%>
<%@ page import="com.etn.util.Decode64"%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%
String ur = (String)session.getValue("referer");
String titre =  GlobalParm.getParm("APPLI");
titre = titre.toUpperCase();
String n = null;

 String auth = request.getHeader("Authorization");

 if(auth == null )
 {
  response.setStatus(401);
  response.setHeader("Pragma","No-cache");
  response.setHeader("Cache-Control","no-cache");
  response.setHeader("Expires",new Date(System.currentTimeMillis()+60000).toString());
  response.setHeader("WWW-Authenticate","Basic realm=\""+titre+"\"");

  return;
 }

 StringTokenizer st = new StringTokenizer(auth);
 String mode = st.nextToken();

 ByteArrayOutputStream b = new ByteArrayOutputStream();
 Decode64 d = new Decode64(b,st.nextToken());

 st = new StringTokenizer(b.toString(),":");

//String n = null;
String p = null;

if(st.hasMoreElements() ) n = st.nextToken();
if(st.hasMoreElements() ) p = st.nextToken();

if( n!= null && p != null )
{
  
  if( n.length() < 64 && p.length() < 64 )
  { n = escape.sql(n.trim()); p = escape.sql(p.trim());
    if( n.length() > 0 && p.length() > 0 )
     Etn.setContexte(n,p) ;
  }

}
else
  Etn.close();

if( Etn.getId() == 0 )
 {
   response.setStatus(401);
   response.setHeader("Pragma","No-cache");
   //response.setHeader("WWW-Authenticate","Basic realm=\""+ur+"\"");
   response.setHeader("WWW-Authenticate","Basic realm=\""+titre+"\"");
   return;
 }

int user_id=0;
if( Etn.getId() == 0){
if(1==1)return;
}
%>