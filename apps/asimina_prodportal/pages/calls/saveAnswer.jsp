<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
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

    int parseNullInt(Object o)
    {
        if (o == null) return 0;
        String s = o.toString();
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Integer.parseInt(s);
    }

%>
<%
        String client_uuid = parseNull(request.getParameter("client_uuid"));
        String question_uuid = parseNull(request.getParameter("question_uuid"));
        String answer = parseNull(request.getParameter("answer"));
        String user = "";

        Set rs = Etn.execute("select pc.client_id, pq.id from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_questions pq inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_question_clients pc on pc.question_uuid = pq.question_uuid where pq.question_uuid ="+escape.cote(question_uuid)+" and pc.client_uuid="+escape.cote(client_uuid));        
        if(rs.next()){
            Set rsClient = Etn.execute("select * from clients where id="+escape.cote(rs.value(0)));
            rsClient.next();
			user = parseNull(parseNull(rsClient.value("name"))+" "+parseNull(rsClient.value("surname")));

			if(user.length() == 0 && parseNull(rsClient.value("email")).length() > 0) user = parseNull(rsClient.value("email"));
			else user = parseNull(rsClient.value("username"));		
			if(user.contains("@")) user = user.substring(0,user.indexOf("@"));
			
            Etn.executeCmd("insert into "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_answers set answer="+escape.cote(answer)+", user="+escape.cote(user)+", question_id="+escape.cote(rs.value(1)));
        }
%>