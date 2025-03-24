<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
<%!
	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
%>
<%
    String comments = parseNull(request.getParameter("comments"));
    String product_id = parseNull(request.getParameter("product_id"));
    String user = parseNull(request.getParameter("user"));
	
	String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);

    int is_guest = 1;
    if(!client_id.equals("")){
        Set rsClient = Etn.execute("select * from clients where id="+escape.cote(client_id));
        rsClient.next();
        user = parseNull(parseNull(rsClient.value("name"))+" "+parseNull(rsClient.value("surname")));
        if(user.length() == 0 && parseNull(rsClient.value("email")).length() > 0) user = parseNull(rsClient.value("email"));
		else user = parseNull(rsClient.value("username"));		
		if(user.contains("@")) user = user.substring(0,user.indexOf("@"));
		
        is_guest = 0;
    }    
    Etn.executeCmd("insert into "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_comments set comment="+escape.cote(comments)+", is_guest="+is_guest+", user="+escape.cote(user)+", product_id=(select id from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where product_uuid="+escape.cote(product_id)+")");
%>