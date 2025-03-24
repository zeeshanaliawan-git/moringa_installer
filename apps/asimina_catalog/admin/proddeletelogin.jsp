<div id='deletedlg' style='display:none;' class="modal fade" tabindex="-1" role="dialog" >
</div>

<!-- /.modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='dlogindlg'>
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <form id="publishLoginForm" action="" class="loginForm" >
                <div class="modal-header">
                    <h5 class="modal-title">Connection for Publication</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div>
                        <div class="alert alert-danger invalid-feedback errorMsg" role="alert" style='display:none'></div>
                        <div class="form-group">
                            <input name="username" placeholder="username" class="form-control" type="text" id="lgusername" required="required" />
                        </div>
                        <div class="form-group">
                            <input name="password" placeholder="password" class="form-control" type="password" id="lgpassword" required="required" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-success" >Connect</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<!-- /.modal -->

<script>
	jQuery(document).ready(function() {


        $('#dlogindlg form.loginForm').submit(function(event) {
            event.preventDefault();
            event.stopPropagation();
            onDeleteProdloginok();
        });


		var _proddelid = "";
		var _proddeltyp = "";

		onDeleteProdloginok=function()
		{

             var modal = $("#dlogindlg");

            var form = modal.find(".loginForm");
            var errorMsg = modal.find(".errorMsg");

            var username = modal.find('[name=username]');
            var password = modal.find('[name=password]');

            errorMsg.html("").hide();

            if( !form.get(0).checkValidity() ){
                return false;
            }

            $.ajax({
                url : '<%=request.getContextPath()%>/admin/prodaccesslogin.jsp',
                type: 'POST',
                data: {username : username.val(), password : username.val()},
                dataType:'json',
                success : function(json)
                {
                    if(json.resp == 'error')
                    {
                        errorMsg.html(json.msg).show();
                    }
                    else
                    {
                        modal.modal("hide");
                        ondel();
                    }
                },
                error : function()
                {
                    bootNotifyError("Error while communicating with the server");
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
//alert(_proddelid + " " + _proddeltyp);
			$.ajax({
      		       	url : '<%=request.getContextPath()%>/admin/isprodpushlogin.jsp',
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
				enableTime: true,
				dateFormat: "d/m/Y H:i",
				time_24hr: true,
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
				url : '<%=request.getContextPath()%>/admin/proddelete.jsp',
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
					bootNotifyError("Error while communicating with the server");
				}
			});
		};
	});
</script>