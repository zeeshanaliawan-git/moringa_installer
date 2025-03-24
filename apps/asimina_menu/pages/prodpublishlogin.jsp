<!-- /.modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='logindlg'>
	<div class="modal-dialog modal-sm" role="document">
		<div class="modal-content">
			<div class="modal-header" style='text-align:left'>
				<h5 class="modal-title">Connection for Publication</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
			</div>
			<div class="modal-body">
				<div>
					<div id='alertBox' class="alert alert-danger" role="alert" style='display:none'>
						<div id='alertUsername' style='display:none'><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span >Enter username</span></div>
						<div id='alertPassword' style='display:none'><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span >Enter password</span></div>
						<div id='alertInvalid' style='display:none'><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span ></span></div>
					</div>
					<div class="form-group">
						<input name="username" placeholder="username" class="form-control" type="text" id="lgusername"/>
					</div>
					<div class="form-group">
						<input name="password" placeholder="password" class="form-control" type="password" id="lgpassword"/>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
				<button type="button" class="btn btn-success" onclick='onprodloginok()'>Connect</button>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div>
<!-- /.modal -->



<script>
	jQuery(document).ready(function() {
		//$("#logindlg").dialog({
		//	bgiframe: true, autoOpen: false, height: 'auto', width:'auto', modal: true, resizable : false
		//});

		$("#lgusername").focus();
		
		$("#prodpublishbtn").click(function()
		{
			$.ajax({
				url : '<%=request.getContextPath()%>/pages/isprodpushlogin.jsp',
				type: 'GET',
				dataType:'json',
				success : function(json)
				{
					if(json.is_prod_login == 'true') showpublishdlg();
					else
					{
						$("#alertBox").hide();
						$("#alertUsername").hide();
						$("#alertPassword").hide();
						$("#alertInvalid").hide();
						$("#alertInvalid").html("");
						$("#lgusername").val("");
						$("#lgpassword").val("");
						$("#logindlg").modal("show");
					}
				},
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});
		});

		onprodloginok=function()
		{
			$("#alertBox").hide();
			$("#alertUsername").hide();
			$("#alertPassword").hide();
			$("#alertInvalid").hide();
			$("#alertInvalid").html("");

			if($.trim($("#lgusername").val()) == '')
			{
				$("#alertUsername").show();
				$("#alertBox").show();
				return;
			}
			if($.trim($("#lgpassword").val()) == '')
			{
				$("#alertPassword").show();
				$("#alertBox").show();
				return;
			}
			$.ajax({
				url : '<%=request.getContextPath()%>/pages/prodaccesslogin.jsp',
				type: 'POST',
				data: {username : $("#lgusername").val(), password : $("#lgpassword").val()},
				dataType:'json',
				success : function(json)
				{
					if(json.resp == 'error')
					{
						$("#alertInvalid").html(json.msg)
						$("#alertBox").css("display", "block");
						$("#alertInvalid").css("display", "block");
					}
					else
					{
						showpublishdlg();
						$('#logindlg').modal('hide');
					}
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		};

		showpublishdlg=function()
		{
			$.ajax({
				url : '<%=request.getContextPath()%>/pages/showpublish.jsp',
				type: 'POST',
				data: {id : '<%=prodpushid%>', type : '<%=prodpushtype%>'},
				success : function(resp)
				{
					$("#publishdlg").html(resp);
					$("#publishdlg").modal('show');
				},
				error : function()
				{
					console.log("Error while communicating with the server");
				}
			});
		};

	});
</script>