<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ include file="../common2.jsp" %>
<%@ include file="../lib_msg.jsp" %>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm"%>
<%@ page import="java.util.*" %>

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

%>

<%
	String _error_msg = libelle_msg(Etn, request, "Your session is expired. Please login again");
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";
	

%>
<%@ include file="../headerfooter.jsp"%>
<!doctype html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>
<%=_headhtml%>
<style>
  .etn-orange-portal-- table.o-results tr td{
    padding: 15px;
  }
</style>

</head>
<body>
<div class="etn-orange-portal--">
<%=_headerHtml%>
<div id="container" class="o-container">
	<h1><%=libelle_msg(Etn, request, "Product Review")%></h1>
	<div class="o-container">
		<%
                String id = parseNull(request.getParameter("qid"));
                String client_uuid = parseNull(request.getParameter("clid"));
                String prefix = getProductColumnsPrefix(Etn, request, _lang);

		Set rs = Etn.execute("select pq.question, pc.client_id, p.* from "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_questions pq inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p on pq.product_id = p.id inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".product_question_clients pc on pc.question_uuid = pq.question_uuid where pq.question_uuid ="+escape.cote(id)+" and pc.client_uuid="+escape.cote(client_uuid));
		if(rs.next())
                {
		%>
          <div class="o-row">
            <div class="o-well o-col-sm-3">
             <img src="<%=GlobalParm.getParm("PRODUCTS_IMG_PATH") + rs.value("image_name")%>" alt="<%=rs.value(prefix + "name")%>" style="width:100%;height:auto">
              <p style="margin-top:15px">
                <strong><%=rs.value(prefix + "name")%></strong>
              </p>
            </div>
            <form class="o-form-horizontal o-col-sm-9" id='frm'>
                          <input type='hidden' value='<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(id)%>' id='question_uuid' name='question_uuid'>
                <div class="o-form-group ">
                  <label class="o-col-sm-2 o-control-label"><%=libelle_msg(Etn, request, "Question")%>&nbsp;</label>
                  <div class="o-col-sm-10">
                    <span class="o-form-control" disabled><%=rs.value("question")%></span>
                  </div>
                </div>
                <div class="o-form-group ">
                  <label class="o-col-sm-2 o-control-label"><%=libelle_msg(Etn, request, "Answer")%>&nbsp;</label>
                  <div class="o-col-sm-10">
                      <textarea class="o-form-control" id="answer" style="resize:vertical"></textarea>
                  </div>
                </div>
                <div class="o-form-group ">

                  <div class="o-col-sm-offset-2 o-col-sm-3">
                    <button type="button" class="o-btn o-black o-color-white" onclick="submitAnswer('<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(id)%>','<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(client_uuid)%>')" ><%=libelle_msg(Etn, request, "Submit Answer")%></button>
                  </div>
                </div>
            </form>
          </div>
                <%}%>
	</div>
</div>
</div>
 <%=_footerHtml%>
 <%=_endscriptshtml%>
</body>
<script>
___portaljquery(document).ready(function(){

});

function submitAnswer(id, client_uuid){
                    var answer = ___portaljquery("#answer").val();
                    if(answer==""){
                        alert("<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Please provide an answer"))%>");
                        return;
                    }
                    var postData = {
                        answer: answer,
                        client_uuid: client_uuid,
                        question_uuid: id
                    };
                    ___portaljquery.ajax({
			url : '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>pages/calls/saveAnswer.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            alert("<%=com.etn.asimina.util.PortalHelper.escapeCoteValue(libelle_msg(Etn, request, "Answer Saved!"))%>");
                            __gotoPortalHome();
			}
                    });
                }

</script>
</html>
