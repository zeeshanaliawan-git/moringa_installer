<!-- This jsp for including in other where check publish login is needed for publishing   -->
<!-- Modal -->
<div class="modal fade" id="modalPublishLogin" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <form id="publishLoginForm" action="">
                <input type="hidden" name="requestType" value="doPublishLogin">
                <input type="hidden" name="action" value="">

                <div class="modal-header">
                    <h5 class="modal-title" id="">Connection for Publication</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="container-fluid">
                    <div class="errorMsg invalid-feedback alert alert-danger" role="alert" style="display: block;"></div>
                        <div class="form-group row">
                            <div class="col">
                                <input type="text" name="username" class="form-control"
                                    placeholder="username" required="required">
                            </div>
                        </div>
                        <div class="form-group row">
                            <div class="col">
                                <input type="password" name="password" class="form-control"
                                    placeholder="password" required="required">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Submit</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->
<script type="text/javascript">
    // ready function
    $(function() {

        $('#publishLoginForm').submit(function(event) {
            event.preventDefault();
            event.stopPropagation();
            onSubmitPublishLogin();
        });

    });

    function checkPublishLogin(action){
        showLoader();

        $.ajax({
            url: '<%=request.getContextPath()%>/admin/ajax/publishAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'isPublishLogin',
            },
        })
        .done(function(resp) {

            if(resp.status === 1){
                onPublishUnpublish(action, true);
            }
            else{
                var modal = $('#modalPublishLogin');
                var form = $('#publishLoginForm');
                form.get(0).reset();
                form.find('[name=action]').val(action);
                modal.find('.errorMsg').html("").hide();
                modal.modal('show');
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function checkUnPublishLogin(formId, action){
        showLoader();

        $.ajax({
            url: '<%=request.getContextPath()%>/admin/ajax/publishAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'isPublishLogin',
            },
        })
        .done(function(resp) {

            if(resp.status === 1){
                onUnpublish(formId, action, true);
            }
            else{
                var modal = $('#modalPublishLogin');
                var form = $('#publishLoginForm');
                form.get(0).reset();
                form.find('[name=action]').val(action);
                modal.find('.errorMsg').html("").hide();
                modal.modal('show');
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function onSubmitPublishLogin(){

        var modal = $('#modalPublishLogin');
        var form = $('#publishLoginForm');

        if( !form.get(0).checkValidity() ){
            return false;
        }

        showLoader();
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/ajax/publishAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status === 1){
                modal.modal('hide');
                var action = form.find('[name=action]').val();
                onPublishUnpublish(action, true);
            }
            else{
                modal.find('.errorMsg').html(resp.message).show();
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }
</script>