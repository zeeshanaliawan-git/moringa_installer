
<!-- Modal -->
<div class="modal fade" id="modalAddEditPage" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
        <div class="modal-content">
            <form id="addEditPageForm" action="" novalidate="">
                <input type="hidden" name="requestType" value="saveReactPage">
                <input type="hidden" name="pageId" id="pageId" value="">
                <input type="hidden" name="pageType" value="react">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel"></h5>
                    <div class="text-right">
                        
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
                <div class="modal-body">
                    <div class="text-right mb-3">
                        <button type="submit" class="btn btn-primary" >Save</button>
                    </div>
                    <%-- <button type="button" class=" btn btn-secondary btn-lg btn-block text-left mb-1"
                            data-toggle="collapse" href="#globalInfoCollapse" role="button" >
                        Global information
                    </button> --%>
                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#globalInfoCollapse" role="button" aria-expanded="true" aria-controls="globalInfoCollapse">
                            <strong>Global information</strong>
                        </div>
                        <div class="collapse show pt-3" id="globalInfoCollapse">
                            <div class="card-body">
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Page name</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="name" value=""
                                                maxlength="100" required="required">
                                    </div>
                                    <div class="invalid-feedback">Cannot be empty.</div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Package name</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="package_name" value=""
                                                maxlength="100" required="required"
                                                oninput="onPackageNameInput(this)"
                                                onblur="onPackageNameBlur(this)">
                                        <div class="invalid-feedback">Cannot be empty.</div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Class name</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="class_name" value=""
                                                maxlength="100" required="required"
                                                oninput="onClassNameInput(this)"
                                                onblur="onClassNameBlur(this)">
                                        <div class="invalid-feedback">Cannot be empty.</div>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label">Path</label>
                                    <div class="col-sm-9">
                                        <div class="input-group">
                                            <div class="input-group-prepend">
                                                <span class="input-group-text">/</span>
                                            </div>

                                            <input type="text" class="form-control" name="path" value=""
                                                maxlength="500" required="required"
                                                onkeyup="onPathKeyup(this)"
                                                onblur="onPathBlur(this)">
                                            <div class="input-group-append">
                                                <span class="input-group-text rounded-right">/index.html</span>
                                            </div>
                                            <div class="invalid-feedback">Cannot be empty.</div>
                                        </div>
                                    </div>

                                </div>
                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label">Title</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="title" value="" maxlength="100" required="required">
                                        <div class="invalid-feedback">Cannot be empty.</div>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label">Language</label>
                                    <div class="col-sm-9">
                                        <select class="custom-select" name="langue_code">
                                        <%
                                            Set langRs = Etn.execute("SELECT * FROM language");
                                            while(langRs.next()){
                                        %>
                                            <option value='<%=getValue(langRs,"langue_code")%>'><%=getValue(langRs,"langue")%> - <%=getValue(langRs,"langue_code")%></option>
                                        <%  }  %>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label">Variant</label>
                                    <div class="col-sm-9">
                                        <select class="custom-select" name="variant" >
                                            <option value="all">All</option>
                                            <option value="anonymous">Anonymous</option>
                                            <option value="logged">Logged</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div><!--  collapse -->
                    </div>

                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#layoutCollapse" role="button" aria-expanded="true" aria-controls="layoutCollapse">
                            <strong>Layout</strong>
                        </div>
                        <div class="collapse show pt-3" id="layoutCollapse">
                            <div class="card-body">
                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label">Layout type</label>
                                    <div class="col-sm-9">
                                        <select class="custom-select" name="layout" onchange="onPageLayoutChange(this)" >
                                            <option value="css-grid">CSS grid</option>
                                            <option value="react-grid-layout">React grid layout</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group row reactGridLayoutFields">
                                    <label  class="col-sm-3 col-form-label">Row height</label>
                                    <div class="col-sm-9">
                                        <div class="input-group">
                                            <input type="text" class="form-control"
                                                name="row_height" value="50"
                                                maxlength="4" required="required"
                                                onkeyup="allowPositiveNumberOnly(this)"

                                                >
                                            <div class="input-group-append">
                                                <span class="input-group-text rounded-right">px</span>
                                            </div>
                                            <div class="invalid-feedback">Cannot be empty.</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row reactGridLayoutFields">
                                    <label  class="col-sm-3 col-form-label">Item margins</label>
                                    <div class="col-sm-9">
                                        <div class="row mb-1">
                                            <div class="col-2 col-form-label">X :</div>
                                            <div class="col">
                                                <div class="input-group">
                                                    <input type="text" class="form-control"
                                                        name="item_margin_x" value="5"
                                                        maxlength="4" required="required"
                                                        onkeyup="allowPositiveNumberOnly(this)"
                                                        >
                                                    <div class="input-group-append">
                                                        <span class="input-group-text rounded-right">px</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row ">
                                            <div class="col-2 col-form-label">Y :</div>
                                            <div class="col">
                                                <div class="input-group">
                                                    <input type="text" class="form-control"
                                                        name="item_margin_y" value="5"
                                                        maxlength="4" required="required"
                                                        onkeyup="allowPositiveNumberOnly(this)"
                                                        >
                                                    <div class="input-group-append">
                                                        <span class="input-group-text rounded-right">px</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                                <div class="form-group row  reactGridLayoutFields">
                                    <label  class="col-sm-3 col-form-label">Item padding</label>
                                    <div class="col-sm-9">
                                        <div class="row mb-1">
                                            <div class="col-2 col-form-label">X :</div>
                                            <div class="col">
                                                <div class="input-group">
                                                    <input type="text" class="form-control"
                                                        name="container_padding_x" value="5"
                                                        maxlength="4" required="required"
                                                        onkeyup="allowPositiveNumberOnly(this)"
                                                        >
                                                    <div class="input-group-append">
                                                        <span class="input-group-text rounded-right">px</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-2 col-form-label">Y :</div>
                                            <div class="col">
                                                <div class="input-group">
                                                    <input type="text" class="form-control"
                                                        name="container_padding_y" value="5"
                                                        maxlength="4" required="required"
                                                        onkeyup="allowPositiveNumberOnly(this)"
                                                        >
                                                    <div class="input-group-append">
                                                        <span class="input-group-text rounded-right">px</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div><!--  collapse -->
                    </div>

                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#pageUrlsCollapse" role="button" aria-expanded="true" aria-controls="pageUrlsCollapse">
                            <strong>Page URLs</strong>
                        </div>
                        <div class="collapse show pt-3" id="pageUrlsCollapse">
                            <div class="card-body">
                                <div class="pageUrlContent clearContent list-group mb-2">

                                </div>
                                <div id="pageUrlTemplate" class="d-none">
                                    <div class="pageUrlRow list-group-item p-2">
                                        <div class="form-group row">
                                            <label  class="col-sm-3 col-form-label">Javascript key</label>
                                            <div class="col-sm-9">
                                                <div class="input-group">
                                                    <input type="text" class="form-control"
                                                        name="page_url_js_key" maxlength="100"
                                                        onkeyup="allowAphaNumericOnly(this)"
                                                        >
                                                    <div class="input-group-append">
                                                        <button type="button" class="btn btn-danger rounded-right"
                                                        onclick="deleteParent(this,'.pageUrlRow')">
                                                        x</button>
                                                    </div>
                                                    <div class="invalid-feedback">Cannot be empty.</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label  class="col-sm-3 col-form-label">URL</label>
                                            <div class="col-sm-9">
                                                <input type="url" class="form-control"
                                                    name="page_url" maxlength=2500  >
                                                <div class="invalid-feedback">Cannot be empty. Must be a valid URL.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col text-right">
                                        <button type="button" class="btn btn-success addPageUrlButton"
                                                onclick="addPageUrl(this)">Add a URL</button>
                                    </div>
                                </div>
                            </div>
                        </div><!--  collapse -->
                    </div>
                </div><!-- modal body -->
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary" >Save</button>
                </div>
            </form>

            <div class="d-none">

            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<%
    // String _IMAGE_URL_PREPEND = getImageURLPrepend();
    // String _CATALOG_ROOT = GlobalParm.getParm("CATALOG_ROOT") + "/";
%>
<script type="text/javascript">

    window.CONTEXT_PATH = '<%=request.getContextPath()%>/';

    // ready function
    $(function() {

        $('#modalAddEditPage').on('show.bs.modal', onShowModalAddEditPage);

        $('#addEditPageForm').submit(function(event) {
            /* Act on the event */
            event.preventDefault();
            event.stopPropagation();
            onSavePage();
        });

    });

    function onShowModalAddEditPage(event){
        var button = $(event.relatedTarget);
        var modal  = $(this);
        var form = $('#addEditPageForm');
        form.get(0).reset();
        form.find('[name=pageId]').val('');
        form.find('.clearContent').html('');
        form.removeClass('was-validated');
        var layoutInput = form.find('[name=layout]');
        layoutInput.trigger('change');

        var caller = button.data('caller');

        if(caller == "edit"){
            var pageId = button.data('page-id');
            layoutInput.prop('disabled',true);

            showLoader();
            $.ajax({
                url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : "getDynamicPageInfo",
                    pageId : pageId
                },
            })
            .done(function(resp) {
                if(resp.status == 1){

                    var page = resp.data.page;

                    modal.find('.modal-title').text("Edit page : " + page.name);

                    var fieldList = ["name", "path", "variant", "canonical_url", "title",
                                        "langue_code", "package_name", "class_name",
                                        "layout",
                                        ,"row_height","item_margin_x","item_margin_y"
                                        ,"container_padding_x", "container_padding_y"];

                    $.each(fieldList, function(index, fieldName) {
                        form.find('[name='+fieldName+']').val(page[fieldName]);
                    });

                    var btn = form.find("button:first");
                    page.page_urls.forEach(function(pageUrlObj){
                        addPageUrl(btn, pageUrlObj);
                    });

                    form.find('[name=pageId]').val(page.id);
                    layoutInput.trigger('change');
                }
                else{
                    // bootNotify(resp.message, "danger");
                    modal.modal('hide');
                }
            })
            .fail(function() {
                bootNotifyError("Error in accessing server.");
                modal.modal('hide');
            })
            .always(function() {
                hideLoader();
            });

        }
        else{
            layoutInput.prop('disabled',false);
            modal.find('.modal-title').text("Add a new Page");
        }

    }

    function onSavePage(){

        var form = $('#addEditPageForm');

        var isError = !form.get(0).checkValidity();

        if( isError){
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status === 1){
                form.find('[name=pageId]').val(resp.data.pageId);

                $('#modalAddEditPage').modal('hide');
                onPageSaveSuccess(resp, form);
                bootNotify("Page saved successfully");
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in saving page. please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function deleteParent(ele, parentSearchTerm){

        $(ele).parents(parentSearchTerm+':first').remove();
    }

    function onPackageNameInput(input){
        input = $(input);
        input.val(input.val().trim().replace(/[^a-zA-Z0-9\-]/g,'').replace("--","-"));
    }
    function onPackageNameBlur(input){
        input = $(input);
        input.val(input.val().trim());
        while(input.val().startsWith("-")){
            input.val(input.val().substring(1));
        }
        while(input.val().endsWith("-")){
            input.val(input.val().substring(0,input.val().length-1));
        }
    }

    function onClassNameInput(input){
        input = $(input);
        input.val(input.val().trim().replace(/[^a-zA-Z0-9]/g,''));
    }
    function onClassNameBlur(input){
        input = $(input);
        input.val(input.val().trim());
        while("0123456789".indexOf(input.val().charAt(0)) >= 0) {
            input.val(input.val().substring(1));
        }
        if(input.val().length > 0){
            input.val(input.val().charAt(0).toUpperCase() + input.val().substring(1));
        }
    }

    function getPagePreview(pageId){
        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data : {
                requestType : "getPagePreview",
                pageId : pageId
            }
        })
        .done(function(resp) {
            hideLoader();
            if(resp.status === 1){
                var url = window.CONTEXT_PATH + resp.data.url;
                var win = window.open("pagePreview.jsp?url="+url, pageId + "_preview");
                win.focus();
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function allowPositiveNumberOnly(ele){
        allowNumberOnly(ele);
        ele = $(ele);
        if(! (parseInt($(ele).val()) >= 0) ){
            ele.val('0');
        }

    }

    function addPageUrl(button, pageObj){
        var form = $(button).parents("form:first");

        var newPageUrl = $($('#pageUrlTemplate').html());

        newPageUrl.find('[type=text]').attr('required','required');

        if(typeof pageObj != 'undefined'){
            newPageUrl.find('[name=page_url]').val(pageObj.url);
            newPageUrl.find('[name=page_url_js_key]').val(pageObj.js_key);
        }

        form.find('.pageUrlContent').append(newPageUrl);
    }

    function onPageLayoutChange(select){
        var form = $('#addEditPageForm');

        var layout = $(select).val();
        if(layout === 'react-grid-layout'){
            form.find('.reactGridLayoutFields').show();
        }
        else{
            form.find('.reactGridLayoutFields').hide();
        }

    }

</script>