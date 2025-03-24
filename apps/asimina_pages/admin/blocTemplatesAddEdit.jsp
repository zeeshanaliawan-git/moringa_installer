<%-- This file for including in other pages at the end of body tag --%>
<%@include file="blocsAddEdit.jsp" %>
<div class="modal fade" id="modalAddEditTemplate" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
        <div class="modal-content">
            <form id="addEditTemplateForm" action="" >
            <input type="hidden" name="requestType" value="saveTemplate">
            <input type="hidden" name="templateId" id="templateId" value="">
            <input type="hidden" name="templateType" id="templateType" value="<%=templateType%>">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel"></h5>
                <button type="button" class="close closeBtn" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                    <div class="pt-3" id="globalInfoCollapse">
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Name</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control" name="name" value=""
                                        maxlength="100" required="required"
                                        onchange="onNameChange(this)">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Template ID</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control" name="custom_id" value=""
                                        maxlength="100" required="required"
                                        onkeyup="onKeyupCustomId(this)"
                                        onblur="onKeyupCustomId(this)">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Type</label>
                            <div class="col-sm-9">
                                <select name="type" class="custom-select"  >
                                <% if(!isSystemTemplate){ %>
                                    <option value="<%=Constant.TEMPLATE_CLASSIC_BLOCK%>">Block</option>
                                    <option value="<%=Constant.TEMPLATE_FEED_VIEW%>">Feed view</option>
                                    <option value="<%=Constant.TEMPLATE_STRUCTURED_CONTENT%>">Structured content</option>
                                    <option value="<%=Constant.TEMPLATE_STRUCTURED_PAGE%>">Structured page</option>
                                    <option value="<%=Constant.TEMPLATE_STORE%>">Store</option>

                                <% } else { %>
                                    <option value="<%=Constant.SYSTEM_TEMPLATE_MENU%>">Menu</option>
                                    <option value="<%=Constant.SYSTEM_TEMPLATE_SIMPLE_PRODUCT%>">Simple Product</option>
                                    <option value="<%=Constant.SYSTEM_TEMPLATE_SIMPLE_VIRTUAL_PRODUCT%>">Simple Virtual Product</option>
                                    <option value="<%=Constant.SYSTEM_TEMPLATE_CONFIGURABLE_PRODUCT%>">Configurable Product</option>
                                    <option value="<%=Constant.SYSTEM_TEMPLATE_CONFIGURABLE_VIRTUAL_PRODUCT%>">Configurable Virtual Product</option>
                                <% } %>
                                </select>
                            </div>
                        </div>


                        <button type="button" class="btn btn-success btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#blocPresentation" role="button" aria-expanded="true" aria-controls="blocPresentation">Block Presentation</button>
                        <div class="container-fluid">
                        <ul class="nav nav-tabs" id="blocLangNavTabs" role="tablist">
                            <% active = true; for (Language lang : langsList) { %>
                            <li class="nav-item" data-lang-id="<%= lang.getLanguageId() %>">
                                <a class='nav-link <%=(active)?"active mainLang":"" %>' data-lang-id="<%= lang.getLanguageId() %>"
                                    id="blocLangTab_<%= lang.getLanguageId() %>" data-toggle="tab" href="#blocLangTabDesc_<%= lang.getLanguageId() %>"
                                    role="tab" aria-controls="<%= lang.getLanguage() %>" aria-selected="true"><%= lang.getLanguage() %>
                                </a>
                            </li>
                            <% active = false; } %>
                        </ul>
                        <div class="tab-content" id="blocLangTabDesc">
                            <% active = true; for (Language lang : langsList) { %>
                            <div class="tab-pane fade <%=(active)?"show active":"" %>" id="blocLangTabDesc_<%= lang.getLanguageId() %>" role="tabpanel"
                                aria-labelledby="blocLangTab_<%= lang.getLanguageId() %>">
                                <div class="card collapse show pt-3" id="blocPresentation">
                                    <div class="card-body bloc-presentation">
                                        <div class="template-items-container" data-lang-id="<%= lang.getLanguageId() %>">
                                            <div class="form-group template-description-div">
                                                <div class="form-group row ">
                                                    <label class="col-sm-3 col-form-label">Description</label>
                                                    <div class="col-sm-9">
                                                        <textarea class="form-control" name="description_<%= lang.getLanguageId() %>" rows="4" maxlength="5000"></textarea>
                                                    </div>
                                                </div>

                                                <div class="form-group row">
                                                    <label class="col col-form-label">Image <br><div class="d-flex"><div class="img-count">0</div>&nbsp;/&nbsp;<div class="img-limit">1</div></div></label>
                                                    <div class="col-9">
                                                        <div class="card image_card" data-img-limit="1">
                                                            <div class="card-body"> 
                                                                <span class="ui-state-media-default" style="padding:0px;display: inline-block;">
                                                                    <div class="bloc-edit-media">
                                                                        <button type="button" class="btn btn-success load-img" style="margin-right: .10rem;" onclick="loadFieldImageV2(this,false)" data-lang-id="<%= lang.getLanguageId()%>">Add a media</button>
                                                                        <button type="button" class="btn btn-danger disabled no-img" style="margin-right: .10rem;display:none">No more media</button>
                                                                    </div>
                                                                    <div class="bloc-edit-media-bgnd" style="height:100%; width:100%;min-width:145px;min-height:145px;  position:absolute; left:0; top:0">&nbsp;</div>
                                                                    <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="<%=GlobalParm.getParm("PAGES_APP_URL")%>img/add-picture-on.jpg">	
                                                                </span>															
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                            </div>
                                        </div>
                                        <div class="text-right">
                                            <button type="button" class="btn btn-success mx-1 add-template-description" data-lang-id="<%= lang.getLanguageId()%>">Add an item</button>
                                            <button type="button" class="btn btn-danger remove-template-description d-none" data-lang-id="<%= lang.getLanguageId() %>">Remove an item</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <% active = false; } %>
                        </div>
                    </div>
                        
                    </div>
               </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary closeBtn" data-dismiss="modal">Close</button>
                <button type="submit" class="btn btn-primary" >Save</button>
            </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<template id="add-template-description">
    <div class="form-group template-description-div">
        <div class="form-group row">
            <label class="col-sm-3 col-form-label">Description</label>
            <div class="col-sm-9">
                <textarea class="form-control" name="description" rows="4" maxlength="5000"></textarea>
            </div>
        </div>

        <div class="form-group row ">
            <label class="col col-form-label">Image <br><div class="d-flex"><div class="img-count">1</div>&nbsp;/&nbsp;<div class="img-limit">1</div></div></label>
            <div class="col-9">
                <div class="card image_card" data-img-limit="1">
                    <div class="card-body"> 
                        <span class="ui-state-media-default" style="padding:0px;display: inline-block;">
                            <div class="bloc-edit-media">
                                <button type="button" class="btn btn-primary mx-1" style="margin-right: .10rem;" onclick='loadFieldImageV2(this,true,"image","img")'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
                                <button type="button" class="btn btn-danger mx-1" style="margin-right: .1rem;" onclick='clearFieldImageV2(this)' ><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></button>
                            </div>
                            <div class="bloc-edit-media-bgnd" style="height:100%; width:100%;min-width:145px;min-height:145px;  position:absolute; left:0; top:0">&nbsp;</div>
                            <input type="hidden" name="image_value" class="image_value"/>
                            <input type="hidden" name="image_alt" class="image_alt"/>
                            <img class="card-image-top image_value" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="">	
                        </span>
                        <span class="ui-state-media-default" style="padding:0px;display: inline-block;">
                            <div class="bloc-edit-media">
                                <button type="button" class="btn btn-success load-img" style="margin-right: .10rem;display:none" onclick="loadFieldImageV2(this,false,'image','img')">Add a media</button>
                                <button type="button" class="btn btn-danger disabled no-img" style="margin-right: .10rem;">No more media</button>
                            </div>
                            <div class="bloc-edit-media-bgnd" style="height:100%; width:100%;min-width:145px;min-height:145px;  position:absolute; left:0; top:0">&nbsp;</div>
                            <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="<%=GlobalParm.getParm("PAGES_APP_URL")%>img/add-picture-on.jpg">	
                        </span>															
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script type="text/javascript">
    window.IMAGE_URL_PREPEND = '<%=getImageURLPrepend(getSiteId(session))%>';
        function updateRemoveButtonVisibility(langId) {
                        var container = $('.template-items-container[data-lang-id="' + langId + '"]');
                        var removeButton = $('.remove-template-description[data-lang-id="' + langId + '"]');
                        if (container.children().length > 0) {
                            removeButton.removeClass('d-none');
                        } else {
                            removeButton.addClass('d-none');
                        }
            }
    
    // ready function
    $(function() {
        

             $('.add-template-description').on('click', function() {
                var langId = $(this).data('lang-id');
                var template = document.getElementById('add-template-description').content.cloneNode(true);

                $(template).find('[name="description"]').attr('name', 'description_' + langId);
                $(template).find('[name="image_value"]').attr('name', 'image_value_' + langId);
                $(template).find('[name="image_alt"]').attr('name', 'image_alt_' + langId);
                $(template).find('.card-image-top').addClass('image_value_'+langId);
                

                $('.template-items-container[data-lang-id="' + langId + '"]').append(template);
                updateRemoveButtonVisibility(langId);
            });

            $('.remove-template-description').on('click', function() {
                var langId = $(this).data('lang-id');
                var container = $('.template-items-container[data-lang-id="' + langId + '"]');
                var templateDescriptionDiv = container.find('.template-description-div');
                if (templateDescriptionDiv.length > 1) {
                    templateDescriptionDiv.last().remove();
                }
                updateRemoveButtonVisibility(langId);
            });

            $('.template-items-container').each(function() {
                var langId = $(this).data('lang-id');
                updateRemoveButtonVisibility(langId);
            });

        $('#modalAddEditTemplate').on('show.bs.modal', onShowModalAddEditTemplate);

        $('#addEditTemplateForm').submit(function(event) {
            /* Act on the event */
            event.preventDefault();
            event.stopPropagation();
            onSaveTemplate();
        });

        $(".ckeditorField").ckeditor({
            filebrowserImageBrowseUrl : "imageBrowser.jsp?popup=1",
            extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
            colorButton_enableMore : true,
            colorButton_enableAutomatic : false,
            allowedContent: true,
            contentsCss: '<%=request.getContextPath()%>/css/bootstrap.min.css',
            colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
        });

        $("#modalAddEditTemplate").on("show.bs.modal",function(){
            var blocPresentation = $("#blocPresentation");
            if(blocPresentation.find(".template-description-div").length>1) blocPresentation.parent("#globalInfoCollapse").find(".remove-template-description").removeClass("d-none");
            else blocPresentation.closest("#globalInfoCollapse").find(".remove-template-description").addClass("d-none");
        });

        $("#modalAddEditTemplate").on("hide.bs.modal",function(){
            $("#blocPresentation").find(".template-description-div").not(":first").remove();
            $("#blocPresentation").find(".img-count").text("0");
            $("#blocPresentation").find(".ui-state-media-default").not(":last").remove();
            $("#blocPresentation").find(".ui-state-media-default").find(".load-img").show();
            $("#blocPresentation").find(".ui-state-media-default").find(".no-img").hide();

            $("#blocPresentation").find(".remove-template-description").addClass("d-none");
        });
    });

    function onShowModalAddEditTemplate(event){

        var button = $(event.relatedTarget);
        var modal  = $(this);
        var form = $('#addEditTemplateForm');
        form.get(0).reset();
        form.find('[name=templateId]').val('');
        form.find(':input:not(.closeBtn)').prop("disabled", false);
        
        //form.find('[name=image_value]').val('');
        //form.find('img').attr('src', '');

        var caller = button.data('caller');

        if(caller == "edit"){
            form.find('[name=custom_id]').prop("readonly", true);
            var templateId = button.data('template-id');
            var themeStatus = button.data('theme-status');
            showLoader();
            $.ajax({
                url: 'blocTemplatesAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : "getTemplateInfo",
                    templateId : templateId
                },
            })
            .done(function(resp) {
                if(resp.status === 1){
                    if(themeStatus == '<%=Constant.THEME_LOCKED%>' && <%=!isSuperAdmin(Etn)%>){
                         form.find(':input:not(.closeBtn)').prop("disabled", true);
                    }

                    var template = resp.data.template;
                    var tempDescription = resp.data.template["description-template"];
                    modal.find('.modal-title').text("Edit template : " + template.name);

                    var fieldList = ["name", "custom_id", "type"];
                    $.each(fieldList, function(index, fieldName) {
                        form.find('[name='+fieldName+']').val(template[fieldName]);
                    });
                    form.find('[name=templateId]').val(template.id);
                    form.find('[name=type]').prop('disabled',true);
                    $('.template-items-container').each(function() {
                        $(this).data('initial-template-removed', false);
                    });

                    $.each(tempDescription, function(index, jsonObject) {
                        var langId = jsonObject.lang_id;
                        var langTabContainer = $('.template-items-container[data-lang-id="' + langId + '"]');
                        var initialTemplateRemoved = langTabContainer.data('initial-template-removed');

                        if (jsonObject.description && jsonObject.image_src) {
                            if (!initialTemplateRemoved && (jsonObject.description || jsonObject.image_label || jsonObject.image_src)) {
                                langTabContainer.find('.template-description-div:has(textarea[name="description_' + langId + '"])').remove();
                                langTabContainer.data('initial-template-removed', true);
                            }
                            var template = document.getElementById('add-template-description').content.cloneNode(true);
                            $(template).find('[name="description"]').attr('name', 'description_' + langId).val(jsonObject.description);
                            $(template).find('.load-img').data('langId', langId);
                            if(jsonObject.hasOwnProperty("image_src") && jsonObject.image_src.length > 0){
                                $(template).find('input[name="image_value"]').attr('name', 'image_value_' + langId).val(jsonObject.image_src);
                                $(template).find('input[name="image_alt"]').attr('name', 'image_alt_' + langId).val(jsonObject.image_label);
                                $(template).find("img").first().addClass('image_value_'+langId);
                                $(template).find('img.image_value_'+langId).first().attr('src',window.IMAGE_URL_PREPEND+jsonObject.image_src);
                            }
                            else {
                                $(template).find(".ui-state-media-default").first().remove();
                            }
                            $('.template-items-container[data-lang-id="' + langId + '"]').append(template);
                            updateRemoveButtonVisibility(langId);
                        }
                    });  
                }
                else{
                    modal.modal('hide');
                }
            })
            .fail(function() {
                alert("Error in accessing server.");
                modal.modal('hide');
            })
            .always(function() {
                hideLoader();
            });

        }
        else{
            modal.find('.modal-title').text("Add a new Template");
            form.find('[name=type]').prop('disabled',false);
            form.find('[name=custom_id]').prop("readonly", false);
        }

    }

    function onSaveTemplate(){

        var form = $('#addEditTemplateForm');

        if( !form.get(0).checkValidity() ){
            return false;
        }

        showLoader();
        $.ajax({
            url: 'blocTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status === 1){
                form.find('[name=templateId]').val(resp.data.templateId);

                $('#modalAddEditTemplate').modal('hide');
                bootNotify("Template saved.");
                if(typeof refreshTable === 'function' ){
                    refreshTable();
                }
                var templateNameEle = $('.templateName');
                if(templateNameEle.length > 0){
                    var tName = form.find('[name=name]').val();
                    templateNameEle.html(tName);
                }
            }
            else{
                alert(resp.message);
            }
        })
        .fail(function() {
            alert("Error in saving. please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function onNameChange(name){
        name = $(name);
        var form = name.parents('form:first');
        customId = form.find('[name=custom_id]');

        if(name.val().trim().length > 0 && customId.length > 0 && customId.prop('readonly') == false){
            if(form.find('[name=templateId]').val().length == 0) customId.val(name.val().trim()).trigger('keyup');
        }
    }

</script>