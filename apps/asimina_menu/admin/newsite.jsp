<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%!
	String parseNull(Object o){
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
	<title>New Site</title>
	<style>
		.abutton
		{
			border-right:1px solid #ddd;
			border-bottom:1px solid #ddd;
			margin-bottom:5px; background-color:#eee;
			color:black;
			padding:5px 8px 5px 8px;
		}
		.alink
		{
			color:black;
		}
	</style>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"New Site",""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
				<h1 class="h2">New Site</h1>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
				<div class="btn-group" role="group" aria-label="...">
					<button type="button" class="btn btn-primary" id="saveBtn" >Save</button>
				</div>
			</div>
			<!-- /buttons bar -->
	</div>
	<!-- /title -->

	<div class="animated fadeIn">
		<div class="alert alert-danger" role="alert" id='errmsg' style='display:none'></div>
		<form name='frm' id='frm' method='post' action='' >
			<div class="form-group row col-sm-8">
				<label for="name" class="col-sm-2 pl-0 control-label">Name <a href="#" data-toggle="popover" data-trigger='hover' data-placement="top"  title="Site name" data-content="content to define"><span class="glyphicon glyphicon-info-sign m-l-10" aria-hidden="true"></span></a></label>
				<div class="col-sm-9">
					<input type='text' class='form-control' name='name' id='name' value='' size="40" maxlength='75'>
				</div>
			</div>
			<div class="form-check">
			<% 
				Set rs = Etn.execute("SELECT langue_id,langue FROM language");
				while (rs.next()){%>
					<div class="mr-2">
						<input class="form-check-input site-lang mr-2" type="checkbox" name="languages" value="<%=rs.value("langue_id")%>" id="lang_<%=rs.value("langue_id")%>">
						<label class="form-check-label mr-2" for="lang_<%=rs.value("langue_id")%>">
							<%=rs.value("langue") %>
						</label>
					</div>
				<%}%>
			</div>
		</form>
	</div>
</main>
	<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>
<script type="text/javascript">
jQuery(document).ready(function() {

	$("#saveBtn").click(function()
	{
		$("#errmsg").html("");
		$("#errmsg").hide();
		if($.trim($("#name").val()) == "")
		{
			$("#errmsg").html("You must provide site name");
			$("#errmsg").show();
			return;
		}
		if(! $(".site-lang").is(":checked")){
			bootNotifyError("No Language has been selected");
			return;
		}
		$.ajax({
			url : 'savesite.jsp',
			type: 'POST',
			data: $("#frm").serialize(),
			dataType : 'json',
			success : function(json)
			{
				if(json.resp == 'success') window.location.href= "<%=request.getContextPath()%>/pages/siteparameters.jsp?_tm=<%=System.currentTimeMillis()%>";
			},
			error : function()
			{
				console.log("Error while communicating with the server");
			}
		});
	});
});

function bootNotifyError(msg){
  bootNotify(msg, "danger");
}

function bootNotify(msg, type) {

    if (typeof type == 'undefined') {
        type = "success";
    }
    var settings = {
        type: type,
        delay: 2000,
        placement: {
            from: "top",
            align: "center"
        },
        offset : {
            y : 10,
        },
        z_index : 1500,//to show above bootstrap modal
        // animate: {
        //     enter: 'animated fadeInDown',
        //     exit: 'animated fadeOutRight'
        // }
    };

    $.notify(msg, settings);
}
</script>
</body>
</html>
