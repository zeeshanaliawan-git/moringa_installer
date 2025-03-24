<%
    List<Language> langsList = getLangs(Etn,selectedsiteid);
    boolean active = true;
%>
    <!--Add Edit  Modals -->
    <div class="modal fade" id="modalAddEditFolder" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="formAddEditFolder" action="" onsubmit="return false;">
                    <input type="hidden" name="requestType" value="saveFolder">
                    <input type="hidden" name="id" value="">
                    <input type="hidden" name="parentFolderUuid" value="">
                    <input type="hidden" name="catalogId" value="">
                    <div class="modal-header">
                        <h5 class="modal-title"> <!-- set dynamically --></h5>
                        <div class="text-right">
                           
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </div>
                    <div class="modal-body">
                    <div class="text-right mb-3">
                             <button type="button" class="btn btn-primary"
                                onclick="onSaveFolder()">
                                Save</button>
                    </div>

                        <div class="card mb-2">
                            <div class="card-header bg-secondary" data-toggle="collapse" href="#globalInfoCollapse" role="button" 
                            aria-expanded="true" aria-controls="globalInfoCollapse">
                                <strong>Folder definition</strong>
                            </div>
                            <div class="collapse show pt-3" id="globalInfoCollapse">
                                <div class="card-body">
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Name</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="name" value=""
                                                    maxlength="100" required="required">
                                            <div class="invalid-feedback">
                                                Cannot be empty.
                                            </div>
                                        </div>
                                    </div>
                                    <div class="pagePathMainDiv pageOnly w-100">
                                        <ul class="nav nav-tabs pagePathTabs" role="tablist">
                                        <%  
                                            active = true;
                                            for (Language lang : langsList ) {
                                        %>
                                            <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
                                            <a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
                                                data-toggle="tab" href="#pathPrefixlangTabContent_<%=lang.getLanguageId()%>"
                                                role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%></a>
                                            </li>
                                        <%
                                                active = false;
                                            }
                                        %>
                                        </ul>

                                        <div class="tab-content p-3">
                                            <%
                                                active = true;
                                                for (Language lang: langsList) {
                                                    
                                            %>
                                                <div class='tab-pane langTabContent <%=(active)?"show active":""%>'
                                                        id="pathPrefixlangTabContent_<%=lang.getLanguageId()%>"
                                                        role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                                    <div class="form-group row">
                                                        <label class="col-sm-4 col-form-label">Path prefix</label>
                                                        <div class="col-sm-8">
                                                            <div class="input-group">
                                                                <input type="text" class="form-control"
                                                                    name="path_prefix_<%=lang.getLanguageId()%>"
                                                                    value="" maxlength="100"
                                                                    onkeyup="onPathKeyup(this,true)"
                                                                    onblur="onPathBlur(this,true)" >

                                                                <div class="input-group-append">
                                                                    <span class="input-group-text rounded-right">/</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                </div>
                                                <!-- tabContent -->
                                            <%
                                                    active = false;
                                                }//for lang tab content
                                            %>
                                        </div>
                                    </div>
                                    <!-- pagePathMainDiv -->
                                </div><!--  collapse -->
                            </div><!--  collapse -->
                        </div><!--  collapse -->
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->


    <!-- Copy Modals -->
    <div class="modal fade" id="modalCopyFolder" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="formCopyFolder" action="" onsubmit="return false;">
                    <input type="hidden" name="requestType" value="copyFolder">
                    <input type="hidden" name="id" value="">
                    <div class="modal-header">
                        <h5 class="modal-title"> Copy folder</h5>
                        <div class="text-right">
                            
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    </div>
                    <div class="p-4">
                    <div class="text-right mb-3">
                        <button type="button" class="btn btn-primary"
                                onclick="copyFolder()">
                                Save</button>
                    </div>
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Copy from</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control" id="copyFrom" value="" readonly />
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label labelName">New name</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control" name="name" value=""
                                        maxlength="100" required="required" autofocus />
                                <div class="invalid-feedback">
                                    Cannot be empty.
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

<script type="text/javascript">

    function openFolderModal(folderData){

        var modal = $('#modalAddEditFolder');
        var form = $('#formAddEditFolder');

        form.get(0).reset();
        form.removeClass('was-validated');
        form.find('[name=id]').val('');
        form.find('.pagePathTabs:first li:first-child a').tab('show');

        if(typeof folderData === 'undefined' ){
            //add new
            modal.find('.modal-title').text('Add new folder');
        }
        else{
            //edit existing
            modal.find('.modal-title').text('Edit folder: ' + folderData.name);
            form.find('[name=id]').val(folderData.id);
            form.find('[name=name]').val(folderData.name);

            var pathPrefixObj = folderData.path_prefix;
            if(typeof pathPrefixObj == 'object'){
                $.each(pathPrefixObj, function(curLangId, curPathPrefix){
                    var pathPrefixInput = form.find('[name=path_prefix_'+curLangId+']');
                    if(pathPrefixInput.length > 0){
                        pathPrefixInput.val(curPathPrefix);
                    }
                });
            }
        }
        modal.modal('show');
    }

    function editFolder(id){
        if(id){
            showLoader();
            $.ajax({
                url: 'foldersAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : 'getFolderInfo',
                    id : id
                },
            })
            .done(function(resp) {
                if(resp.status == 1){
                    openFolderModal(resp.data.folder);
                    // if(isFilterList === true){
                    //     window.catalogsTable.search(resp.data.catalog.name).draw();
                    // }
                }
                else{
                    bootNotifyError(resp.message);
                }
            })
            .fail(function() {
                alert("Error in accessing server. please try again.");
            })
            .always(function() {
                hideLoader();
            });
        }
    }

    function openCopyFolderModal(id){
        var prevFolderName =  $(event.target).closest('tr').find("td.name").text();
        var modal = $('#modalCopyFolder');
        var form = $('#formCopyFolder');
        form.get(0).reset();
        form.removeClass('was-validated');
        form.find('[name=id]').val(id);
        modal.find('#copyFrom').val(prevFolderName);
        modal.modal('show');
    }

    function copyFolder(){
        var modal = $('#modalCopyFolder');
        var form = $('#formCopyFolder');

        if( !form.get(0).checkValidity() ){
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url: 'foldersAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status === 1){
                modal.modal('hide');
                bootNotify("Folder Copied.");
                refreshscreen();
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            alert("Error in accessing server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function onSaveFolder(){
        var modal = $('#modalAddEditFolder');
        var form = $('#formAddEditFolder');
        var id =  form.find('[name=id]').val();

        if($('#folderLevel').val() != 3 || id){

            var parentFolderUuid =  $('#folderUuid').val();
            var catalogId =  $('#catalogId').val();
            form.find('[name=parentFolderUuid]').val(parentFolderUuid);
            form.find('[name=catalogId]').val(catalogId);

            if( !form.get(0).checkValidity() ){
                form.addClass('was-validated');
                return false;
            }

            showLoader();
            $.ajax({
                url: 'foldersAjax.jsp', type: 'POST', dataType: 'json',
                data: form.serialize(),
            })
            .done(function(resp) {
                if(resp.status === 1){
                    modal.modal('hide');
                    bootNotify("Folder saved.");
                    refreshscreen();
                }
                else{
                    bootNotifyError(resp.message);
                }
            })
            .fail(function() {
                alert("Error in accessing server. please try again.");
            })
            .always(function() {
                hideLoader();
            });

        }
    }

    function deleteFolder(id){
        bootConfirm("Are you sure you want to delete this Folder ?",
            function(result){
                if(!result) return;

                var idsList = [id];
                deleteFolders(idsList);

            });
    }

    function deleteFolders(idsList){
        if(idsList.length <= 0){
            return false;
        }

        var params = $.param({
            requestType : 'deleteFolders',
            ids : idsList
        },true);

        showLoader();
        $.ajax({
            url: 'foldersAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function(resp) {
            if(resp.status != 1){
                bootAlert(resp.message + " ");
            }
            else if (resp.status == 1){
                if(resp.message.includes("published products cannot be deleted.")){
                    bootNotifyError(resp.message);
                }else if(resp.message.includes("duplicate present in Trash.")){
                    bootNotifyError(resp.message);
                }
                else{
                    bootNotify(resp.message);
                }
                 setTimeout(refreshscreen, 4000);
            }
        })
        .always(function() {
            hideLoader();
        });
    }

</script>