<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape"%>

<%@ include file="common.jsp"%>

<%
	String siteid = getSiteId(session);
	String ty = parseNull(request.getParameter("type"));
	String id = parseNull(request.getParameter("id"));

	String process = getProcess(ty);

	String nextpublish = "";
	Set rs = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = " + escape.cote(id) + " and proces = " + escape.cote(process));
	if(rs.next()) nextpublish = parseNull(rs.value(0));
%>
<!-- .modal content -->
	<div class="modal-dialog " role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title">Publication</h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			</div>
			<div class="modal-body">
				<div id='infoBox' class="alert alert-info" role="alert" <% if(nextpublish.length() == 0) { %>style='display:none'<%}%>>
					<div id='infoPublication' <% if(nextpublish.length() == 0) { %>style='display:none'<%}%>>
						<span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
						<span class="m-l-10">
							<% if(nextpublish.length() > 0) { %>
								Next publish on : <%=nextpublish%>
							<% } %>
						</span>
					</div>
				</div>
				<div id='alertBox' class="alert alert-danger" role="alert" style='display:none'>
					<div id='alertUsername' style='display:none'><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span class="m-l-10">Username missing</span></div>
				</div>
				<div>
					<div class="form-inline">
						<label for="menuname" class="col-sm-3 control-label">Publish</label>
						<button type="button" class="btn btn-default btn-primary " onclick='publishnow()'>Now</button>
					</div>


					<div class="form-inline m-t-10" >
						<label for="" class=" col-sm-3 control-label">Publish on</label>
						<div class="input-group">
							<input name="date" class="form-control" type="text" id='datetimepicker'/>
							<span class="input-group-btn">
								<button class="btn btn-default btn-primary" type="button" onclick='publishon()'>OK</button>
							</span>
						</div>
					</div>
				</div>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
	<!-- /.modal content -->

<script>
	jQuery(document).ready(function() {
		publishon=function()
		{
			if($("#datetimepicker").val() == '')
			{
				alert("Select date/time");
				$("#datetimepicker").focus();
			}
			_publish($("#datetimepicker").val());
		};
		publishnow=function()
		{
			_publish(-1);
		};
		_publish=function(_on)
		{
			<% if("menuv2".equals(ty)){%>
			$.ajax({
				url : '<%=request.getContextPath()%>/pages/publishsite.jsp',
				type: 'POST',
				data: { lang : '<%=id%>', type : '<%=ty%>', on : _on, prod : 1},
				dataType : 'json',
				success : function(json)
				{
					alert(json.msg);
					if(json.status == 0)
					{
						$("#nextpublish___").html(json.next_publish_on);
						if(typeof refreshscreen != 'undefined') refreshscreen();
					}
				},
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});
			<%}else{%>
			$.ajax({
				url : '<%=request.getContextPath()%>/pages/publish.jsp',
				type: 'POST',
				data: {id : '<%=id%>', type : '<%=ty%>', on : _on},
				dataType : 'json',
				success : function(json)
				{
					alert(json.msg);
					if(json.response == 'success')
					{
						$("#nextpublish___").html(json.next_publish_on);
						if(typeof refreshscreen != 'undefined') refreshscreen();
					}
				},
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});
			<%}%>
		};

		flatpickr("#datetimepicker", {
			dateFormat: "d/m/Y H:i",
			enableTime: true,
			time_24hr: true,
			locale: "fr"
		});

	});
</script>