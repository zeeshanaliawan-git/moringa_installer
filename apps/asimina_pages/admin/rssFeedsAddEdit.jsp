<%-- This file for including in other pages at the end of body tag --%>

<div class="modal fade" id="modalAddEditRssFeed" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
        <div class="modal-content">
            <form id="formAddEditRssFeed" action="" novalidate onsubmit="return false;" >
                <input type="hidden" name="requestType" value="saveRssFeed">
                <input type="hidden" name="id" value="">

            <div class="modal-header">
                <h5 class="modal-title"></h5>
                <div class="text-right">
                    
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </div>
            <div class="modal-body">
            <div class="text-right mb-3">
                 <button type="button" class="btn btn-primary"
                        onclick="onSaveRssFeed()">
                        Save</button>
                    <button type="button" class="btn btn-primary"
                        onclick="onSaveAndImportRssFeed()">
                        Save & import</button>
            </div>
                <div class="container-fluid">
                    <div class="errorMsg small text-danger"></div>
                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#globalInfoCollapse" role="button" 
                        aria-expanded="true" aria-controls="globalInfoCollapse">
                            <strong>Global information</strong>
                        </div>
                        <div class="collapse show pt-3" id="globalInfoCollapse">
                            <div class="card-body">
                                <div class="form-group row">
                                    <label class="col col-form-label">Feed name</label>
                                    <div class="col-9">
                                        <input type="text" name="name" class="form-control" value=""
                                            required="required" maxlength="100" >
                                        <div class="invalid-feedback">
                                            Cannot be empty.
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col col-form-label">Feed URL</label>
                                    <div class="col-9">
                                        <input type="url" name="url" class="form-control" value=""
                                            required="required" maxlength="1500" >
                                        <div class="invalid-feedback">
                                            Must be a valid URL.
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col col-form-label">Nb item max import</label>
                                    <div class="col-9">
                                        <select name="max_items" class="custom-select"  >
                                            <option value="0">All</option>
                                            <option value="5">5</option>
                                            <option value="10">10</option>
                                            <option value="15">15</option>
                                            <option value="20">20</option>
                                            <option value="25">25</option>
                                            <option value="30">30</option>
                                            <option value="35">35</option>
                                            <option value="40">40</option>
                                            <option value="45">45</option>
                                            <option value="50">50</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col col-form-label">Item Activation</label>
                                    <div class="col-9">
                                        <select name="activation_type" class="custom-select"  >
                                            <option value="auto">Auto activate</option>
                                            <option value="never">Never activate</option>
                                            <option value="update">Activate updated</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col col-form-label">Synchro frequency</label>
                                    <div class="col-9">
                                        <div class="input-group">
                                            <input type="text" name="sync_frequency" class="form-control" value="1"
                                                required="required" maxlength="3"
                                                onkeyup="allowNumberOnly(this)" onblur="onBlurSyncFrequency(this)" >

                                            <select name="sync_frequency_unit" class="custom-select" required="required" >
                                                    <option value="minute">Minute</option>
                                                    <option value="hour">Hour</option>
                                                    <option value="day">Day</option>
                                            </select>
                                        </div>

                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col col-form-label">Synchro type</label>
                                    <div class="col-9">
                                        <select name="sync_type" class="custom-select" required="required" >
                                            <option value=""> -- Synchro type -- </option>
                                            <option value="delete">Delete & reimport</option>
                                            <option value="update">Update existing</option>
                                            <option value="duplicate">Duplicate existing</option>
                                        </select>
                                        <div class="invalid-feedback">
                                            Select an option.
                                        </div>
                                    </div>
                                </div>
                            </div><!--  collapse -->
                        </div>
                    </div>

                    <div id="channelInfoDiv">
                        <div class="card mb-2">
                            <div class="card-header bg-secondary" data-toggle="collapse" href="#channelInfoCollapse" role="button" 
                            aria-expanded="true" aria-controls="channelInfoCollapse">
                                <strong>Channel information</strong>
                            </div>
                            <div class="collapse show pt-3" id="channelInfoCollapse">
                                <div class="card-body" id="channelInfoCollapseCardBody">
                                </div>
                            </div>
                        </div>
                        <div class="d-none">
                            <div class="form-group row" id="channelFieldTemplate">
                                <label class="col col-form-label text-capitalize fieldLabel">Title</label>
                                <div class="col-9">
                                    <input type="text" name="ignore" class="form-control" value="" readonly="readonly">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<script type="text/javascript">

    function addRssFeed(){
        var modal = $('#modalAddEditRssFeed');
        var form = $('#formAddEditRssFeed');

        form.get(0).reset();
        modal.find('.errorMsg').html('');
		modal.find('.modal-title').text('Add Feed');
        form.removeClass('was-validated');

        form.find('[name=id]').val('');

        form.find('[name=sync_frequency]').val("15");
        form.find('[name=sync_type]').val("delete");

        $('#channelInfoDiv').hide();

        modal.modal('show');
    }

    function editRssFeed(feedId){

        showLoader();
        $.ajax({
            url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getRssFeedInfo',
                id : feedId,
            },
        })
        .done(function(resp) {
            if(resp.status === 1){
                openRssFeedModal(resp.data);
            }
            else{
                bootNotify(resp.message,"danger");
            }
        })
        .fail(function() {
            alert("Error in accessing server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function openRssFeedModal(feedInfo){
        var modal = $('#modalAddEditRssFeed');
        var form = $('#formAddEditRssFeed');

        form.get(0).reset();
        modal.find('.errorMsg').html('');
        form.removeClass('was-validated');

        modal.find('.modal-title').text('Edit feed: ' + feedInfo.name);

        $('#channelInfoDiv').show();

        form.find('[name=id]').val(feedInfo.id);

        var fields = ['name','url','max_items','activation_type','sync_frequency','sync_frequency_unit','sync_type'];
        $.each(feedInfo, function(key, value) {
            var input = form.find('[name='+key+']');
            if(input.length > 0){
                input.val(value);
            }
        });

        var channelInfoContainer = $('#channelInfoCollapseCardBody');
        channelInfoContainer.html('');

        var channelInfo = feedInfo.channel;

        var channelFields = ['title','link','description',
                'language', 'category', 'copyright', 'pubDate', 'ttl', 'image_url', 'image_title'];
        var fieldTemplate = $('#channelFieldTemplate').clone();
        fieldTemplate.attr('id',null);
        $.each(channelFields, function(index, fieldName) {
            var fieldLabel = fieldName;

            fieldLabel = strReplaceAll(fieldLabel,"_", " ");
            fieldLabel = fieldLabel.replace("url","URL");
            fieldLabel = fieldLabel.replace("ttl","TTL");

            var fieldValue = channelInfo[fieldName];
            if(typeof fieldValue === 'undefined'){
                fieldValue = '';
            }

            var fieldDiv = fieldTemplate.clone();
            fieldDiv.find('.fieldLabel').html(fieldLabel);
            fieldDiv.find('input').val(fieldValue);
            channelInfoContainer.append(fieldDiv);
        });

        $.each(channelInfo, function(key, value) {
            if(channelFields.indexOf(key) < 0){
                //not in the defined list
                var fieldLabel = key;
                fieldLabel = strReplaceAll(fieldLabel,"_", " ");
                var fieldValue = value;
                var fieldDiv = fieldTemplate.clone();
                fieldDiv.find('.fieldLabel').html(fieldLabel);
                fieldDiv.find('input').val(fieldValue);
                channelInfoContainer.append(fieldDiv);
            }

        });

        modal.modal('show');
    }

    function onSaveAndImportRssFeed(){
        $ch.saveAndImportRssFeed = true;
        onSaveRssFeed();
    }

    function onSaveRssFeed(){

        var form = $('#formAddEditRssFeed');
        var modal = $('#modalAddEditRssFeed');

        var errorMsg = modal.find('.errorMsg');
        errorMsg.html('');

        if( !form.get(0).checkValidity() ){
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status === 1){

                modal.modal('hide');
                bootNotify("Feed saved.");
                refreshTable();
                if($ch.saveAndImportRssFeed){
                    var feedId = resp.data.id;
                    importRssFeed(feedId, true);
                }
            }
            else{
                errorMsg.html(resp.message);
            }
        })
        .fail(function() {
            alert("Error in accessing server. please try again.");
        })
        .always(function() {
            $ch.saveAndImportRssFeed = false;
            hideLoader();
        });

    }

    function importRssFeed(feedId, confirmed){

        if(!confirmed){
            bootConfirm("Are you sure you want to import this feed?",
                function(result){
                    if(result){
                        importRssFeed(feedId, true);
                    }
                });
            return false;
        }

        showLoader();
        $.ajax({
            url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'importRssFeed',
                id : feedId,
            },
        })
        .done(function(resp) {
            if(resp.status === 1){

                bootNotify("Feed imported.");
                refreshTable();
            }
            else{
                bootNotify(resp.message,"danger");
            }
        })
        .fail(function() {
            alert("Error in accessing server. please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function onBlurSyncFrequency(input){
        allowNumberOnly(input);
        var val = $(input).val();

        try{
            val = parseInt(val);
            if(isNaN(val) || val <= 0){
                val = 1;
            }
        }
        catch(err){
            val = 1;
        }

        $(input).val(val);
    }

</script>