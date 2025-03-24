<%-- This file for including in other pages at the end of body tag --%>
<div class="modal fade" id="modalAddEditPageTemplate" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-slideout" role="document">
        <div class="modal-content">
            <form id="addEditPageTemplateForm" action="" novalidate>
                <input type="hidden" name="requestType" value="saveTemplate">
                <input type="hidden" name="id" id="id" value="">

                <div class="modal-header">
                    <h5 class="modal-title"></h5>
                    <button type="button" class="close closeBtn" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#globalInfoCollapse" role="button" aria-expanded="true" aria-controls="globalInfoCollapse">
                            <strong>Global information</strong>
                        </div>
                        <div class="collapse show pt-3" id="globalInfoCollapse">
                            <div class="card-body">
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Name</label>

                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="name" value=""
                                            maxlength="100" required="required"
                                            onchange="onNameChange(this)">
                                        <div class="invalid-feedback">
                                            Cannot be empty
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Template ID</label>

                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="custom_id" value=""
                                            maxlength="100" required="required"
                                            onkeyup="onKeyupCustomId(this)"
                                            onblur="onKeyupCustomId(this)">
                                        <div class="invalid-feedback">
                                            Cannot be empty
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Description</label>

                                    <div class="col-sm-9">
                                        <textarea class="form-control" name="description" rows="3" maxlength="500"></textarea>
                                    </div>
                                </div>
                            </div>

                        </div><!--  collapse -->
                    </div>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary closeBtn" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="onSavePageTemplate()">Save</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<!-- /.modal -->

<script type="text/javascript">

    // ready function
    $(function () {



    });

    function openAddEditPageTemplateModal(templateId, themeStatus) {

        var modal = $('#modalAddEditPageTemplate');
        var form = $('#addEditPageTemplateForm');
        form.find(':input:not(.closeBtn)').prop("disabled", false);
        form.removeClass('was-validated');
        form.get(0).reset();
        form.find('[name=id]').val('');
        form.find('[name=name],[name=custom_id]').prop('readonly',false);

        if (typeof templateId === 'undefined') {
            //add new
            modal.find('.modal-title').text("Add a new page template");
            modal.modal('show');
        }
        else {
            //edit
            showLoader();
            $.ajax({
                    url: 'pageTemplatesAjax.jsp', type: 'POST', dataType: 'json',
                    data: {
                        requestType: "getInfo",
                        templateId: templateId
                    },
                })
                .done(function (resp) {
                    if (resp.status === 1) {
                        var template = resp.data.template;
                        if(themeStatus.length > 0 && themeStatus == '<%=Constant.THEME_LOCKED%>' && <%=!isSuperAdmin(Etn)%>){
                             form.find(':input:not(.closeBtn)').prop("disabled", true);
                        }
                        modal.find('.modal-title').text("Edit template : " + template.name);

                        var fieldList = ["name", "custom_id", "description"];

                        $.each(fieldList, function (index, fieldName) {
                            form.find('[name=' + fieldName + ']').val(template[fieldName]);
                        });
                        form.find('[name=id]').val(template.id);

                        if(template.is_system == '1'){
                            form.find('[name=name],[name=custom_id]').prop('readonly',true);
                        }

                        modal.modal('show');
                    }
                    else {
                        bootNotifyError(resp.message);
                    }
                })
                .fail(function () {
                    bootNotifyError("Error in accessing server.");
                })
                .always(function () {
                    hideLoader();
                });
        }

    }


    function onSavePageTemplate() {

        var modal = $('#modalAddEditPageTemplate');
        var form = modal.find("form:first");

        form.addClass('was-validated');
        if (!form.get(0).checkValidity()) {
            return false;
        }

        showLoader();
        $.ajax({
            url: 'pageTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function (resp) {
            if (resp.status === 1) {
                form.find('[name=id]').val(resp.data.id);

                modal.modal('hide');
                bootNotify("Page template saved.");

                if (typeof refreshTable === 'function') {
                    refreshTable();
                }
                var templateNameEle = $('.pageTemplateName');
                if (templateNameEle.length > 0) {
                    let name = form.find('[name=name]').val();
                    templateNameEle.html(name);
                }
                var templateCustomIdEle = $('.pageTemplateCustomId');
                if (templateCustomIdEle.length > 0) {
                    let name = form.find('[name=custom_id]').val();
                    templateCustomIdEle.html(name);
                }
            }
            else {
                bootAlert(resp.message);
            }
        })
        .fail(function () {
            bootAlert("Error in saving. please try again.");
        })
        .always(function () {
            hideLoader();
        });

    }

    function onNameChange(name) {
        name = $(name);
        let form = name.parents('form:first');
        let customId = form.find('[name=custom_id]');

        if (name.val().trim().length > 0 && customId.length > 0
            && customId.prop('readonly') == false) {
            customId.val(name.val().trim()).trigger('keyup');
        }
    }

</script>