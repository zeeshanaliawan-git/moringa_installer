<!-- /.modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='logindlg'>
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
	jQuery(document).ready(function() 	{

        $('#logindlg form.loginForm').submit(function(event) {
            event.preventDefault();
            event.stopPropagation();
            onprodloginok();
        });

		var _ids = "";
		var _publishtype = "";
		var _itemtype = "";

		onbtnclickpublish=function(ids, itemtype, publishtype)
		{
			_ids = ids;
			_publishtype = publishtype;
			_itemtype = itemtype;
			$.ajax({
                url : '<%=request.getContextPath()%>/admin/isprodpushlogin.jsp',
                type: 'GET',
                dataType:'json',
                success : function(json)
                {
                    if(json.is_prod_login == 'true') {
                        showpublishdlg();
                    }
                    else{
                        var loginModal = $("#logindlg");
                        var loginForm = loginModal.find(".loginForm");
                        loginForm.get(0).reset();
                        loginModal.find(".errorMsg").hide();
                        loginModal.modal("show");
                    }
                },
                error : function(){
                    bootNotifyError("Error while communicating with the server");
                }
            });
		};

		onprodloginok=function()
		{
            var modal = $("#logindlg");

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
                data: {username : username.val(), password : password.val()},
                dataType:'json',
                success : function(json)
                {
                    if(json.resp == 'error')
                    {
                        errorMsg.html(json.msg).show();
                    }
                    else
                    {
                        modal.modal('hide');
                        showpublishdlg();
                    }
                },
                error : function()
                {
                    bootNotifyError("Error while communicating with the server");
                }
            });
        };

        showpublishdlg=function()
        {
            $.ajax({
                url : '<%=request.getContextPath()%>/admin/showpublish.jsp',
                type: 'POST',
                data : {id : _ids, type : _itemtype, publishtype : _publishtype },
                success : function(resp)
                {
                    $("#publishdlg").html(resp);
                    $("#publishdlg").modal('show');
                },
                error : function()
                {
                    bootNotifyError("Error while communicating with the server");
                }
            });
        };

 });
</script>