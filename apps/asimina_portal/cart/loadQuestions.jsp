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
    Set rsQuestions = Etn.execute("select pq.* from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_questions pq inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_answers pa on pq.id = pa.question_id inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p on pq.product_id = p.id where p.product_uuid="+escape.cote(product_id)+" group by pq.id");
    int total_questions = rsQuestions.rs.Rows;
    int page_size = 5;
    int total_pages = total_questions/page_size;
    if(total_questions%page_size!=0) total_pages++;
    out.write("<input id='questions_total_pages' type='hidden' value='"+total_pages+"' />");
    rsQuestions = Etn.execute("select pq.* from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_questions pq inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_answers pa on pq.id = pa.question_id inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p on pq.product_id = p.id where p.product_uuid="+escape.cote(product_id)+" group by pq.id order by pq.tm desc limit "+num*5+",5");
    while(rsQuestions.next()){
%>

<li class="o-list-group-item">
   <h4 class="name">
     <strong><%=rsQuestions.value("user")%></strong>
     <small><%=rsQuestions.value("tm")%></small>
   </h4>
   <p class="comment" style="margin-bottom:30px;margin-top:15px;font-size: 16px;"><%=rsQuestions.value("question")%></p>
   <strong style="display: none;">Answers</strong>
    <ul class="o-list-group">
    <%
    Set rsAnswers = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_answers where question_id="+escape.cote(rsQuestions.value("id"))+" order by tm desc");
    while(rsAnswers.next()){
%>
<li class="o-list-group-item" style="">
    <h5>
        <strong><%=rsAnswers.value("user")%></strong>
        <small><%=rsAnswers.value("tm")%></small>
    </h5>
    <p class="comment" style="margin-top:15px;font-size: 16px;"><%=rsAnswers.value("answer")%></p>
</li>
<%
}
%>        
    </ul>
 </li>
<%
    }
%>