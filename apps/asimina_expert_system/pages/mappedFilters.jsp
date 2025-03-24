<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>

<%@ include file="common.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Expert System</title>

<script type="text/javascript">
	
	$(document).ready(function(){

		$("#es_filter_trigger").on('click', function(){

			$.ajax({ 
				url : 'pages/createUserFilterBackend.jsp',
				type: 'POST',
				data : $('#user_created_filter_form').serialize(),
				dataType : 'HTML',
				success : function(json)
				{		
					callScriptFetchData();
				},
				error:function()
				{
					alert("Some error while communicate server.");
				}

			});
		});

	});

</script>

</head>

<body>

<%
	String destPageName = parseNull(request.getParameter("dest_page_name"));
	Set userFilterRs = Etn.execute("SELECT dps.destination_page, dps.auto_screen, dpf.* FROM dest_page_filters dpf, dest_page_settings dps WHERE dpf.dest_page_id = dps.id AND dps.destination_page = " + escape.cote(destPageName));
%>
		<div class="container">

		<center>

			<div class="form-horizontal" style="padding: 15px; background: #eee; border-radius: 6px; margin-bottom: 15px;">
				<div class="row">
					<form id="user_created_filter_form" action="createUserFilterBackend.jsp" method="POST">				
						<input type="hidden" name="type" value="add_user_filter_value">		
						<input type="hidden" name="dest_page_name" value="<%= CommonHelper.escapeCoteValue(destPageName)%>">
					<%
						String displayName = "";

						while(userFilterRs.next()){
							displayName = userFilterRs.value("display_name");
					%>
							<div class="col-xs-12 col-sm-6">
								<div class="form-group">
									<label class="col-sm-3"><%= displayName%></label>
									<div class="col-sm-9">
					<%
									if(userFilterRs.value("user_filter_type").equals("textfield")){

					%>
										<input id='<%= displayName.replaceAll(" ","_").toLowerCase()%>' name="<%= CommonHelper.escapeCoteValue(displayName)%>" type="text" class="form-control" >
					<%
									}
					%>
									</div>
								</div>
							</div>
					<%
						}
					%>
					</form>
				</div>
				
				<div class="row">
					<div class="col-sm-12 text-center">
						<div class="" role="group" aria-label="controls">
							<button id="es_filter_trigger" type="button" class="btn btn-primary">Search</button>
						</div>
					</div>
				</div>	
			</div>
		</center>
	</div>

</body>
</html>	