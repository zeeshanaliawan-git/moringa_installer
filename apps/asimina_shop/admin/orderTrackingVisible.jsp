<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.asimina.util.UIHelper"%>
<%@ include file="../common2.jsp" %>

<%
	if( !((String)session.getAttribute("PROFIL")).equals("ADMIN") && !((String)session.getAttribute("PROFIL")).equals("SUPER_ADMIN") )
	{
		response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
		return;
	}

    String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));

	String process = parseNull(request.getParameter("process"));

    Set rsLang = Etn.execute("select langue from language;");
	Set rsProc = Etn.execute("Select * from processes where site_id="+escape.cote(siteId));

	Set rsPhase = null;
	if(!process.equals(""))
	{
		rsPhase = Etn.execute("select * from phases where process = "+escape.cote(process));
	}

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Order Tracking Visibility</title>
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">

    <link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery-ui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<h1 class="h2">Order Tracking Visibility</h1>
		</div>
        <!-- Breadcrumb-->
        <div class="animated fadeIn">
          <div class="card">
            <div class="card-header">Order Tracking Visibility</div>
            <div class="card-body">
              <form name="myForm" id='myform' action="orderTrackingVisible.jsp" method="post">
                <div class="row">
                  <div class="col-xs-12 col-sm-6">
                    <div class="form-group">
                      <label class="col-3 control-label" for="processSlct"> Process</label>
                      <div class="col-9">
                              <select name="process" id='processSlct' class="form-control">
                                              <option value="">----------</option>
                                      <% while(rsProc.next()) { %>
                                              <option value="<%=rsProc.value("process_name")%>"><%=rsProc.value("display_name")%></option>
                                      <% } %>
                              </select>
                      </div>
                    </div>
                    <!-- /.col-->
                  </div>
                  <!-- /.row-->
                </div>
                    <div class="row">
                        <div class="col-sm-12 text-center">
                            <div class="" role="group" aria-label="controls">
                                <button type="button" class="btn btn-success" id="savebtn">Save</button>
                            </div>
                        </div>
                    </div>
              </form>
          </div>
          </div>
 <% if(rsPhase != null) { %>
          <div class="card">
            <div class="card-body">
                <form name="visibilityForm" id='visibilityForm' action="orderTrackingVisible.jsp" method="post">
                    <input type="hidden" name="process" value="<%=UIHelper.escapeCoteValue(process)%>" />
              <table class="table table-responsive-sm resultat table-hover table-striped">
                <thead>
                  <tr>
                      <th width="4%">Phase</th>
                      <th >Display name</th>
                      <%while(rsLang.next()){%>
                      <th >Display name (<%= rsLang.value("langue")%>)</th>
                      <%}%>
                      <th width='2%'>Visible?</th>
                  </tr>
              </thead>
              <tbody>
<% 	int c = 0;
while(rsPhase.next()) {
	String style="";
	if(c % 2 == 0) style="";
	c++;
%>
<tr style='<%=style%>'>
	<td>
	<%=rsPhase.value("phase")%>
	<input type="hidden" name="phase" value="<%=rsPhase.value("phase")%>" />	
	</td>
	<td><%=rsPhase.value("displayName")%></td>
	<%
		int count = 1;
		rsLang.moveFirst();
		while(rsLang.next()){
	%>
    <td>
        <div style='float:left'>
            <input id='<%=c%>_displayName<%=count%>' name="displayName<%=count%>" value="<%=rsPhase.value("displayName"+count)%>" class="displayName<%=count%> form-control" />
        </div>
    </td>
	<%
		count++;
	}
	if(count<=5)
	{
		for(int i=count;i<=5;i++)
		{
			out.write("<input type='hidden' value='' name='displayName"+i+"'>");
		}		
	}
	%>
	<td align='center'>
		<div style='float:left'>
            <input type='checkbox' id='<%=c%>' <%=(rsPhase.value("orderTrackVisible").equals("1")?"checked":"")%> value='<%=rsPhase.value("phase")%>' class='viscb' />
		</div>
		<div style='float:left'>
            <input type="hidden" name="visibility" id="<%=c%>_visibility" value="<%=rsPhase.value("orderTrackVisible")%>"/>
		</div>
		<div style='clear:both'></div>
	</td>
</tr>
<% } %>
              </tbody>
</table>
                </form>
            </div>
          </div>
 <% } %>
        </div>
      </main>
        <div class="modal fade" id="visibilityModal" tabindex="-1" role="dialog" aria-labelledby="Order" style="display: none;" aria-hidden="true">
            <div class="modal-dialog modal-info modal-sm" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <p class="modal-title" style="font-size:1.3em">Notification</p>
                        <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">×</span>
                        </button>
                    </div>
                    <div class="modal-body">

                    </div>
                </div>
            </div>
        </div>
    </div>
    <%@ include file="../WEB-INF/include/footer.jsp" %>
</body>
<script type="text/javascript">
	$(document).ready(function() {
		$("#processSlct").change(function(){
			$("#myform").submit();
		});

		$(".viscb").change(function(){
			var vis = "0";
			if($(this).is(':checked')) vis = "1";
			var _id = this.id;
			$("#"+_id+"_visibility").val(vis);
		});

		$("#savebtn").click(function(){
                    	$.ajax({
				url: "updateOrderTrackVisibility.jsp",
				method: "post",
				dataType: "json",
                            data: $("#visibilityForm").serialize(),
				success: function(json){
                            	window.status = 'Success';
                                $('#visibilityModal .modal-body').text(json.RESPONSE);
                                $('#visibilityModal').modal('show');
                            },
                            error : function(jqXHR, textStatus, errorThrown ){
                            	alert("Server communication error");
                            }
			});
		});  

		<% if(!process.equals("")) { %>
			$("#processSlct").val('<%=UIHelper.escapeCoteValue(process)%>');
		<% } %>
	});
</script>

</html>
