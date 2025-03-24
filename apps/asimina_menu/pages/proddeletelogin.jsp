<div id='deletedlg' style='display:none;' class="modal fade" tabindex="-1" role="dialog" >
</div>

<div id='dlogindlg' style='display:none' class="modal fade" tabindex="-1" role="dialog" >
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
						<div id='alertUsername' style='display:none'><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span class="m-l-10">Username missing</span></div>
						<div id='alertPassword' style='display:none'><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span class="m-l-10">Password missing</span></div>
						<div id='alertInvalid' style='display:none'><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span class="m-l-10"></span></div>
					</div>
					<div class="form-group">
						<input type='text' class="form-control" maxlength='50' size='40' id='dlgusername' placeholder="username">
					</div>
					<div class="form-group">
						<input type='password' class="form-control" maxlength='50' size='40' id='dlgpassword' placeholder="password">
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
				<button type="button" class="btn btn-success" onclick='ondprodloginok()'>Connect</button>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div>

<script>
	jQuery(document).ready(function() {


		var _proddelid = "";
		var _proddeltyp = "";
	
		ondprodloginok=function()
		{
			$("#alertBox").hide();
			$("#alertUsername").hide();
			$("#alertPassword").hide();
			$("#alertInvalid").hide();
			$("#alertInvalid").html('');

			if($.trim($("#dlgusername").val()) == '')
			{
				$("#alertUsername").show();
				$("#alertBox").show();
				return;
			}
			if($.trim($("#dlgpassword").val()) == '')
			{
				$("#alertPassword").show();
				$("#alertBox").show();
				return;
			}
			$.ajax({
      		       	url : 'prodaccesslogin.jsp',
             		       type: 'POST',
                     	data: {username : $("#dlgusername").val(), password : $("#dlgpassword").val()},
				dataType:'json',
             		       success : function(json)
                     	{
					if(json.resp == 'error') 
					{
						$("#alertInvalid").html(json.msg);
						$("#alertInvalid").show();
						$("#alertBox").show();
					}
					else
					{	
						ondel();
						$("#dlogindlg").modal("hide");
					}
	                     },
				error : function()
				{
					$("#alertInvalid").html("Error while communicating with the server");
					$("#alertInvalid").show();
					$("#alertBox").show();
				}
			});			
		};

		onproddel=function(id, typ)
		{
			$("#alertBox").hide();
			$("#alertUsername").hide();
			$("#alertPassword").hide();
			$("#alertInvalid").hide();
			$("#alertInvalid").html('');

			_proddelid = id;
			_proddeltyp = typ;
			$.ajax({
      		       	url : 'isprodpushlogin.jsp',
             		       type: 'GET',
				dataType:'json',
             		       success : function(json)
                     	{
					if(json.is_prod_login == 'true') ondel();
					else
					{	
						$("#dlgusername").val("");
						$("#dlgpassword").val("");
						$("#dlogindlg").modal("show");
					}
	                     },
				error : function()
				{
					$("#alertInvalid").html("Error while communicating with the server");
					$("#alertInvalid").show();
					$("#alertBox").show();
				}
			});			

		};
		
		ondel=function()
		{
			var h = "<div class='modal-dialog ' role='document'>" + 
					"<div class='modal-content'>" + 
					"<div class='modal-header'>" + 
					"<h5 class='modal-title'>Delete from Production</h5>" + 
					"<button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>" + 
					"</div>" + 
					"<div class='modal-body'>" + 
					"<div>" + 
					"<div class='form-inline'>" + 
					"<label for='menuname' class='col-sm-3 control-label'>Delete</label>" + 
					"<button type='button' class='btn btn-default btn-primary ' onclick='deletenow()'>Now</button>" + 
					"</div>" + 
					"<div class='form-inline m-t-10' >" + 
					"<label for='' class=' col-sm-3 control-label'>Delete On</label>" + 
					"<div class='input-group'>" + 
					"<input name='date' class='form-control' type='text' id='datetimepicker'/>" + 
					"<span class='input-group-btn'>" + 
					"<button class='btn btn-default btn-primary' type='button' onclick='deleteon()'>OK</button>" + 
					"</span>" + 
					"</div>" + 
					"</div>" + 
					"</div>" + 
					"</div>" + 
					"</div><!-- /.modal-content -->" + 
					"</div><!-- /.modal-dialog -->";

			$("#deletedlg").html(h);
			$("#deletedlg").modal('show');

			flatpickr("#datetimepicker", {
				dateFormat: "d/m/Y H:i",
				enableTime: true,
				time_24hr: true,
				locale: "fr"
			});


		}

		deleteon=function()
		{
			if($("#datetimepicker").val() == '')
			{
				alert("Select date/time");
				$("#datetimepicker").focus();
			}
			_delete($("#datetimepicker").val());
		};
		deletenow=function()
		{
			_delete(-1);
		};
		_delete=function(_on)
		{
			if(!confirm("Are you sure to continue with deletion?")) return;
			$.ajax({
      		       	url : 'proddelete.jsp',
             		       type: 'POST',
                     	data: {id : _proddelid, type : _proddeltyp, on : _on},
				dataType : 'json',
             		       success : function(json)
                     	{
					if(json.response != 'success') alert(json.msg);
					else refreshscreen();						
	                     },
				error : function()
				{
					alert("Error while communicating with the server");
				}
			});			
		};
	});
</script>