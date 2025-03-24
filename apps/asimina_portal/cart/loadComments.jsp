<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type"%>
<%@ include file="lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%!
int parseNullInt(String s)
{
    if (s == null) return 0;
    if (s.equals("null")) return 0;
    if (s.equals("")) return 0;
    return Integer.parseInt(s);
}
%>
<%
    String product_id = parseNull(request.getParameter("product_id"));
    int num = parseNullInt(request.getParameter("num"))-1;
    //System.out.println("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_comments where product_id="+escape.cote(product_id)+" limit "+num*5+",5");
    Set rsComments = Etn.execute("select pc.* from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_comments pc inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p on pc.product_id = p.id where p.product_uuid="+escape.cote(product_id));
    int total_comments = rsComments.rs.Rows;
    int page_size = 5;
    int total_pages = total_comments/page_size;
    if(total_comments%page_size!=0) total_pages++;
    out.write("<input id='total_pages' type='hidden' value='"+total_pages+"' />");
    rsComments = Etn.execute("select pc.* from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_comments pc inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p on pc.product_id = p.id where p.product_uuid="+escape.cote(product_id)+" order by tm desc limit "+num*5+",5");
    while(rsComments.next()){
%>

<li class="o-list-group-item">
   <h4 class="name">
     <strong><%=rsComments.value("user")%></strong>
     <small><%=rsComments.value("tm")%></small>
   </h4>
   <pre class="comment"><%=rsComments.value("comment")%></pre>
 </li>
<%
    }
%>