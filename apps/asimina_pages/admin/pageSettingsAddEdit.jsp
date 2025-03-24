<%--required langsList object from parent--%>
<%--import pagesUtil is rquired from parent--%>
<%--import templateType is rquired from parent--%>
<%--import folderId is rquired from parent--%>
<%--import folderType is rquired from parent--%>
<%
    JSONObject pagePathJson = new JSONObject(PagesUtil.getAllPageFolderPaths(Etn, folderId, getSiteId(session) ));
%>
<!--Add Edit Modals -->
<div class="modal fade" id="modalAddEditPage" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-lg  modal-dialog-slideout" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="pageModalTilte"></h5>
                <div class="text-right">
                    
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </div>
            <div class="modal-body">
            <div class="text-right">
                <button type="button" id="saveButton1" class="btn btn-primary" onclick="onSavePageSettings()" >Save</button>
            </div>
                <div class="row">
                    <div class="col">
                        <div class="invalid-feedback mb-2" style="display:block;" id="pageSettingsErrorMsg" ></div>
                        <ul class="nav nav-tabs " id="pageSettingslangNavTabs" role="tablist">
                            <%
                                active = true;
                                for (Language lang: langsList) {
                            %>
                            <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
                                <a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
                                   id="pageSettingsLangTab_<%=lang.getLanguageId()%>" data-toggle="tab" href="#pageSettingslangTab_<%=lang.getLanguageId()%>"
                                   role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%></a>
                            </li>
                            <%
                                    active = false;
                                }
                            %>
                        </ul>
                        <div class="tab-content p-3" id="flangTabContent">
                            <form id="pageMainForm" action="" method="POST" onsubmit="return false;" noValidate>
                                <input type="hidden" name="id" value=''>
                                <input type="hidden" name="folderId" value='<%=folderId%>'>
                                <input type="hidden" name="folderType"  value='<%=folderType%>'>
                                <input type="hidden" name="requestType"  value='savePage'>
                                <input type="hidden" name="pageTags"  value=''>

                                <div class="p-3">
                                    <div class="form-group row">
                                        <label  class="col col-form-label">
                                            <span class="text-capitalize actionName">Publish Dates</span>
                                        </label>
                                        <div class="col-lg-9 col-md-8">
                                            <div class="row">
                                                <div class="col-6 pr-1">
                                                    <input placeholder="Publish Time" type="text" class="form-control" name="publishTime" value="">
                                                </div>
                                                <div class="col-6 pl-1">
                                                    <input type="text" placeholder="Unpublish Time" class="form-control" name="unpublishTime" value="">
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group row">
                                        <label class="col col-form-label">Name</label>
                                        <div class="col-lg-9 col-md-8 ">
                                            <input type="text" name="name" class="form-control"
                                                   value="" required="required" onchange="onChangeStructuredPageName(this)" >
                                            <div class="invalid-feedback">Cannot be empty.</div>
                                        </div>
                                    </div>

                                    <div id="blocTemplateSelect" class="form-group row">
                                        <label class="col col-form-label">Type</label>
                                        <div class="col-lg-9 col-md-8 ">
                                            <select name="templateId"
                                                    class="custom-select editDisabled" required=""
                                            >
                                                <option value=''>-- select type of page --</option>
                                                <option value='freemarker'>Freemarker</option>
                                                <%
                                                    q = "SELECT id, name, custom_id FROM bloc_templates "
                                                        + " WHERE site_id = " + escape.cote(getSiteId(session))
                                                        + " AND type = " + escape.cote(templateType);
                                                    rs = Etn.execute(q);
                                                    while (rs.next()) {
                                                        String label = rs.value("name") + " (" + rs.value("custom_id") + ")";
                                                %>
                                                <option value='<%=rs.value("id")%>'><%=label%>
                                                </option>
                                                <%
                                                    }
                                                %>
                                            </select>
                                            <div class="invalid-feedback">
                                                Select a template.
                                            </div>
                                        </div>
                                    </div>

                                </div>

                            </form>
                            <%
                                active = true;
								boolean _disableTags = false;
                                for (Language lang: langsList) {
                            %>
                            <div class='tab-pane langTabContent <%=(active)?"show active":""%>'
                                 id="pageSettingslangTab_<%=lang.getLanguageId()%>"
                                 role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">


                                <!-- page settings -->
                                <div class='langPageSettings'
                                     id="pageSettings_<%=lang.getLanguageId()%>"
                                     data-lang-id="<%=lang.getLanguageId()%>" data-lang-code="<%=lang.getCode()%>" >
                                    <form name="pageSettingsForm_<%=lang.getLanguageId()%>" class="langPageSettingsForm"
                                          id="pageSettingsForm_<%=lang.getLanguageId()%>"
                                          action="" method="POST" onsubmit="return false;" noValidate>
                                        <input type="hidden" name="requestType" value="savePage">
                                        <input type="hidden" name="pageType" value="<%=Constant.PAGE_TYPE_STRUCTURED%>">
                                        <input type="hidden" name="pageId" id="page_lang_<%=lang.getLanguageId()%>" value="">
                                        <input type="hidden" name="folderId" value="<%=folderId%>">

                                        <%
                                            String _pageFirstSectionHeading = "Global Information";
                                        %>
                                        <%@ include file="pagesAddEditFields.jsp"%>
                                    </form>
                                </div>
                                <!-- /page settings -->
                            </div>
                            <!-- tabContent -->
                            <%
                                    active=false;
									_disableTags = true;
                                }//for lang tab content
                            %>
                        </div>
                    </div>
                </div><!-- row -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" id="saveButton2" class="btn btn-primary" onclick="onSavePageSettings()">Save</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<!-- Modals -->
<div class="modal fade" id="modalCopyStructuredPage" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-slideout" role="document">
        <div class="modal-content">
            <form id="formCopyContent" action="" novalidate onsubmit="return false;">
                <input type="hidden" name="requestType" value="copyContent">
                <input type="hidden" name="contentId" value="">
                <input type="hidden" name="folderType" value="">
                <input type="hidden" name="structuredType" value="<%=Constant.STRUCTURE_TYPE_PAGE%>">
                <input type="hidden" name="pageType" value="">

                <div class="modal-header">
                    <h5 class="modal-title" id="">Copy content</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="form-group row">
                            <label class="col col-form-label">Copy From</label>
                            <div class="col-8">
                                <input type="text" name="contentName" class="form-control" readonly>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col col-form-label">New content name</label>
                            <div class="col-8">
                                <input type="text" name="name" class="form-control" value=""
                                       required="required" maxlength="100">
                                <div class="invalid-feedback">
                                    Cannot be empty.
                                </div>
                            </div>
                        </div>
                        <div class="form-group row pagePathRow">
                            <label class="col-sm-3 col-form-label">Path</label>
                            <div class="col-sm-9">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text">/</span>
                                    </div>

                                    <input type="text" class="form-control" name="path" value=""
                                           maxlength="500" required="required"
                                           onkeyup="onPathKeyup(this, true)"
                                           onblur="onPathBlur(this, true)">
                                    <div class="input-group-append">
                                        <span class="input-group-text">.html</span>
                                    </div>
                                    <div class="invalid-feedback"></div>
                                </div>

                            </div>

                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" id="saveButton" class="btn btn-primary" onclick="onCopyStructuredPageSave()">Save</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->



<script>

    $ch.contextPath = '<%=request.getContextPath()%>/';
    $ch.pagePathMap = JSON.parse('<%=pagePathJson.toString()%>');
    $ch.pageType = '<%=Constant.PAGE_TYPE_STRUCTURED%>';

    window.IMAGE_URL_PREPEND = '<%=getImageURLPrepend(getSiteId(session))%>';
    window.allTagsList = <%=getAllTagsJSON(Etn, getSiteId(session), GlobalParm.getParm("CATALOG_DB") )%>;

</script>

<script type="text/javascript">
    $(function () {
        if($("#folderType").val() == '<%=Constant.FOLDER_TYPE_STORE%>') {
            var templateField = $('#pageMainForm').find('[name=templateId]')
            $(templateField.children()[1]).attr('hidden',true)
            $(templateField.children()[2]).attr('selected',true)
        }

        //Set publish/unpublish ts
        initDatetimeFields($('#modalAddEditPage input[name=publishTime]'), null, null, "date_time");
        initDatetimeFields($('#modalAddEditPage input[name=unpublishTime]'), null, null, "date_time");

    });

    function openStructuredPageSettingsModal() {
        resetPageModal(true);
        if($("#folderType").val() == '<%=Constant.FOLDER_TYPE_STORE%>'){
            $('#pageModalTilte').text("Add a new store");
        }else{
            $('#pageModalTilte').text("Add a new page");
        }
        var modal = $('#modalAddEditPage');
        modal.modal('show');
    }

    function openPageSettingsModal() {
        resetPageModal(false);
        $('#pageModalTilte').text("Add a new page");
        var modal = $('#modalAddEditPage');
        modal.modal('show');
    }

    function initMetaVariablesToolTip(metaVariables){
        var variablesList = "";
        for (var key in metaVariables) {
            variablesList = variablesList + " - &lt;"+key+"&gt;<br>";
        }
         $('div.langPageSettings').each(function (index, div) {
             div = $(div);
             var langId = div.attr("data-lang-id");
             var langCode = div.attr("data-lang-code");
            $('#pageSettingsForm_' + langId).popover({
                selector : '[name=title], [name=meta_description] ',
                content : "<div style='max-height: 500px; overflow-y: auto; max-width: 170px; padding: 2px'>Use following <strong>&lt;...&gt;</strong> placeholders in text to output corresponding values dynamically<br>" +variablesList+"</div>",
                trigger : 'focus',
                container : 'body',
                placement:"right",
                html    : true
             });
         });
    }

    function customDateFormat(timeParm){
        var dateParts = timeParm.split(' ')[0].split('/');
        var timeParts = timeParm.split(' ')[1].split(':');
        var dateObj = new Date(dateParts[2], dateParts[1] - 1, dateParts[0], timeParts[0], timeParts[1], timeParts[2]);
        var convertedDate = dateObj.toISOString().split('T')[0];
        var convertedTime = dateObj.toTimeString().split(' ')[0];
        return convertedDate + ' ' + convertedTime;
    }

    function editPageSettings(id , isStructured){

        let pageTypeTmp = "freemarker";
        if(isStructured){
            pageTypeTmp = "structured";
        }
        $.ajax({
            url : "pagesAjax.jsp",
            type : 'POST',
            dataType : 'json',
            data : {
                requestType : "checkPageLock",
                pageType : pageTypeTmp,
                pageId: id
            },
        })
        .done(function (resp) {
            if (resp.data.rsp > 0 ) {
                document.getElementById("saveButton1").hidden=true;
                document.getElementById("saveButton2").hidden=true;
            }else{
                document.getElementById("saveButton1").hidden=false;
                document.getElementById("saveButton2").hidden=false;

            }
        })
        .fail(function () {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function () {
        });


        if(id){
            resetPageModal(isStructured);
            showLoader();
            $('.editDisabled').prop('disabled',true);
            var form = $('#pageMainForm');

            var url = "pagesAjax.jsp";
            var requestType = "getPageInfo";
            if(isStructured){
                url = "structuredContentsAjax.jsp";
                requestType = 'getStructuredPageInfo';
            }
            $.ajax({
                url : url,
                type : 'POST',
                dataType : 'json',
                data : {
                    requestType : requestType,
                    id : id,
                },
            })
            .done(function (resp) {

                if (resp.status == 1) {
                    var pages = resp.data.pages;
                    form.find('[name=id]').val(id);
                    form.find('[name=name]').val(resp.data.name);
                    if(resp.data.publishTime.length>0){
                        form.find('[name=publishTime]').val(customDateFormat(resp.data.publishTime).slice(0, -3));
                    }
                    if(resp.data.unpublishTime.length>0){
                        form.find('[name=unpublishTime]').val(customDateFormat(resp.data.unpublishTime).slice(0, -3));
                    }
                    if(isStructured){
                        form.find('[name=templateId]').val(resp.data.templateId);
                        var metaVariables = resp.data.metaVariables;
                        initMetaVariablesToolTip(metaVariables);
                    }else{
                        form.find('[name=templateId]').val("freemarker");
                    }

                    if($("#folderType").val() == '<%=Constant.FOLDER_TYPE_STORE%>'){
                        $('#pageModalTilte').text("Edit store : "+resp.data.name);
                    }else{
                        $('#pageModalTilte').text("Edit page : "+resp.data.name);
                    }
                    var emptyPages  = 0;
                    $('div.langPageSettings').each(function (index, div) {
                        div = $(div);
                        var langId = div.attr("data-lang-id");
                        var page =  pages["page_lang_"+langId];
                        if(page){
                            div.find("#page_lang_"+langId).val(page.id);
                            loadPageData( page ,langId, resp.data.tags, index);//tags are only to be drawn for first language tab
                        }else{
                            // emptyPages = emptyPages+1;
                        }
                    });
                    // if(emptyPages>0 && $('#folderType').val() == '<%=Constant.FOLDER_TYPE_PAGES%>'){
                    //     bootNotifyError("Error page not found.");
                    // }else{
                        var modal = $('#modalAddEditPage');
                        modal.modal('show');
                    // }
                }
                else {
                    bootNotifyError("Error in loading data. Please try again.");
                }
            })
            .fail(function () {
                bootNotifyError("Error in contacting server.Please try again.");
            })
            .always(function () {
                hideLoader();
            });
        }
    }

    function editStructuredPageSettings(id){
        editPageSettings(id, true)
    }

    function resetPageModal(isStructured) {
        if(isStructured){
            $ch.pageType = '<%=Constant.PAGE_TYPE_STRUCTURED%>';
        } else{
            $ch.pageType = '<%=Constant.PAGE_TYPE_FREEMARKER%>';
        }
        $('.editDisabled').prop('disabled',false);

        var form = $('#pageMainForm');

        form[0].reset();
        form.find('[name=id]').val("");
        form.removeClass('was-validated');

        var blocTemplateSelect =  form.find('#blocTemplateSelect');
        blocTemplateSelect.find('select').prop('required',true);
        blocTemplateSelect.removeClass('d-none');

        $("#pageSettingsErrorMsg").html("");
        let langId = $("#langNavTabs li a.active").attr("data-lang-id");
        if(langId){
            $('.nav-tabs a[href="#pageSettingslangTab_'+langId+'"]').tab('show');
        } else{
            $('.nav-tabs a[href="#pageSettingslangTab_1"]').tab('show');
        }

        $('div.langPageSettings').each(function (index, div) {
            div = $(div);

            let langId = div.attr("data-lang-id");
            let langCode = div.attr("data-lang-code");
            form = $('#pageSettingsForm_' + langId);
            if(isStructured){
                form.find('[name=pageType]').val('<%=Constant.PAGE_TYPE_STRUCTURED%>');
            } else {
                form.find('[name=pageType]').val('<%=Constant.PAGE_TYPE_FREEMARKER%>');
            }

            if($('#folderType').val() == "<%=Constant.FOLDER_TYPE_STORE%>"){
                form.find('[name=path]').prop("required", false)
                form.find('[name=title]').prop("required", false)
            }
            form[0].reset();
            form.removeClass('was-validated');
            $("#page_lang_"+langId).val('');

            div.find('.collapse').removeClass('show');
            div.find('.collapse:first').addClass('show');
            div.find('.pageFieldRowName,.pageFieldRowLanguage').addClass('d-none');
            div.find('[name=langue_code]').val(langCode);

            var curPathPrefix = $ch.pagePathMap[langId];
            if (typeof curPathPrefix == 'string' && curPathPrefix.trim().length > 0) {
                curPathPrefix = curPathPrefix.trim();
                var pathDiv = form.find('[name=path]').parents(".input-group:first");
                pathDiv.find(".input-group-prepend:first .input-group-text:first").text(curPathPrefix);
            }

            div.find(".card-image-top:first").attr("src","");
            div.find(".customMetaTagContent").html("");
            div.find('.pageTagsDiv').html("");
            div.find('._secondaryTagsDiv').html("");
            if (langId === '1') {
                div.find('[name=path]').on('change', function () {
                    var val = $(this).val();
                     $(".langPageSettings input[name=path]").val(val);
                });

                div.find('[name=title]').on('change', function () {
                    var val = $(this).val();
                    $(".langPageSettings input[name=title]").val(val);
                });
            }
        });

        initTagAutocomplete($('input[name=pageTagInput]'));
        hideLoader();
    }

    function onSavePageSettings() {

        var form = $("#pageMainForm");
        form.removeClass('was-validated');
        var pageSettingsErrorMsg = $("#pageSettingsErrorMsg");
        pageSettingsErrorMsg.html("");

        if (!form.get(0).checkValidity()) {
            form.addClass('was-validated');
            return false;
        }
        else if (!verifyAllPageSettings()) {
            return false;
        }
        

		var pageTags = [];

		$('.pageTagsDiv input.tagValue').each(function (index, el) {
			var tagId = $(el).val().trim();
			if (tagId.length > 0 && pageTags.indexOf(tagId) < 0) {
				pageTags.push(tagId);
			}
		});

		form.find('[name=pageTags]').val(pageTags.join(","));
        let tempolateId=form.find('[name=templateId]').val();
        // added tags and serailize the pages
        var reqParams = "";
        $('div.langPageSettings').each(function (index, el) {
            var langId = $(el).attr("data-lang-id");
            var form = $("#pageSettingsForm_" + langId);

            var pageFields =  form.serializeArray();
            var pageLangFields = [];
            pageFields.forEach(function (fieldObj) {
				if(fieldObj.name != "pageTags")
				{
                    if(fieldObj.name == "pageType")
                    {
                        if(tempolateId.length>0 && tempolateId !=="freemarker"){
                            fieldObj.value="structured";
                        }
                    }
					pageLangFields.push({name:fieldObj.name+"_lang_"+langId, value: fieldObj.value});
				}
            })

            reqParams += $.param(pageLangFields)+"&";
        });

        var url = "pagesAjax.jsp";
        form.find('input[name=requestType]').val("savePage");
        
        if(tempolateId.length>0 && tempolateId !=="freemarker"){
            url = 'structuredContentsAjax.jsp';
            form.find('input[name=requestType]').val("saveContentSettings");
        }
        reqParams += $.param(form.serializeArray());
        showLoader();
        $.ajax({
            url : url, type : 'POST', dataType : 'json',
            data : reqParams,
        })
        .done(function (resp) {
            if (resp.status == 1) {
                bootNotify(resp.message);
                $('#modalAddEditPage').modal("hide")

                if(typeof refreshDataTable === 'function'){
                    refreshDataTable();
                }else {
                    window.location.href=window.location.href
                }
            }
            else {
                $("#pageSettingsErrorMsg").html(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function () {
            hideLoader();
        });
    }

    function loadPageData(page ,langId, tags, index) {
        var form = $('#pageSettingsForm_' + langId);
        if(page && langId){
            var fieldList = [
                 "name", "langue_code",
                "path", "variant", "canonical_url", "title",
                "template_id", "meta_keywords", "meta_description",
                "dl_page_type", "dl_sub_level_1", "dl_sub_level_2",
                "social_title", "social_type", "social_description",
                "social_image",
                "social_twitter_message", "social_twitter_hashtags",
                "social_email_subject", "social_email_message",
                "social_email_popin_title", "social_sms_text"];

            $.each(fieldList, function (index, fieldName) {
                form.find('[name=' + fieldName + ']').val(page[fieldName]);
            });

            var socialImgSrc = "";
            if (page.social_image.length > 0) {
                socialImgSrc = IMAGE_URL_PREPEND + page.social_image;
            }
            form.find('.social_image_body img').attr('src', socialImgSrc);

            var addCustomMetaTagButton = form.find('.addCustomMetaTagButton');
            $.each(page.custom_meta_tags, function (index, metaObj) {
                addCustomMetaTag(addCustomMetaTagButton, metaObj);
            });

			if(index == 0 && tags)//tags are only to be drawn in first tab
			{
				var tagInput = form.find("input[name=pageTagInput]");
				$.each(tags, function (index, tagObj) {
					addTagGeneric(tagObj, tagInput);
				});		
			}

            form.find('[name=meta_description]').trigger('keyup');
            form.find('[name=title]').trigger('keyup');
            checkSocialImageDimensions(form);
            if(page.page_version==="V2"){
                disableAllInputsWithName("name");
                disableAllInputsWithName("path");
                disableAllInputsWithName("title");
                disableAllInputsWithName("meta_description");
            }
        }
    }

    function disableAllInputsWithName(name) {
        let inputElements = document.querySelectorAll('input[name="'+name+'"]');
        inputElements.forEach((inputElement) => {
            inputElement.setAttribute("readonly",true);
        });
    }

    function verifyAllPageSettings() {
        window.pageSettingsLangIds = [];
        $('div.langPageSettings').each(function (index, el) {

            var langId = $(el).attr("data-lang-id");
            var form = $("#pageSettingsForm_" + langId);
            var pageId = $('#page_lang_' + langId).val();
            var langTab = $('#pageSettingsLangTab_' + langId);

            var pageName = $("#pageMainForm").find("[name=name]").val();
            form.find("[name=name]").val(pageName);
            if(form.find("[name=path]").val().trim().length > 0 &&
                form.find("[name=title]").val().trim().length == 0){
                    form.find("[name=title]").prop('required', true);
            }else{
                form.find("[name=title]").prop('required', false);
            }
            if (!form.get(0).checkValidity() || !checkSocialImageDimensions(form)) {
                var langName = $('#-' + langId).text();
                form.addClass('was-validated');
                langTab.trigger('click');
                $('#metaTagsCollapse').collapse("show");
                bootNotifyError("Specify all required fields for language " + langName);
                return false;
            }
            window.pageSettingsLangIds.push(langId);
        });

        if (window.pageSettingsLangIds.length != $('div.langPageSettings').length) {
            return false;
        }

        window.pageSettingsLangIds = window.pageSettingsLangIds.reverse();
        return true;
    }

    function copyStructuredPage(btn, id) {
        if(id){
            var modal = $("#modalCopyStructuredPage");

            var form = $('#formCopyContent');
            form.get(0).reset();
            form.removeClass('was-validated');
            // form.find('.pagePathRow').show();
            var structuredPageName = $(btn).closest('tr').find("td.name").text();
            if($('#folderType').val() == '<%=Constant.FOLDER_TYPE_STORE%>'){
                form.find('[name=path]').prop("required", false);
            }else{
                form.find('[name=path]').prop("required", true);
            }
            form.find('[name=folderType]').val($('#folderType').val());
            form.find('[name=contentId]').val(id);
            form.find('[name=contentName]').val(structuredPageName);

            modal.modal('show');
        }
    }

    function onCopyStructuredPageSave() {
        var form = $('#formCopyContent');

        if (!form.get(0).checkValidity()) {
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url: 'structuredContentsAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootNotifyError(resp.message);
            }
            else {
                bootNotify("Copy created.")
                refreshDataTable();
                $('#modalCopyStructuredPage').modal('hide');
            }
        })
        .always(function () {
            hideLoader();
        });
    }
    function onChangeStructuredPageName(nameInput){
        var titleInputs = $('.langPageSettingsForm').find('[name=title]');
        for(var i = 0; i<titleInputs.length; i++){
            var titleInput =  $(titleInputs[i]);
            if(titleInput.val().trim().length == 0){
                titleInput.val($(nameInput).val());
            }
        }
    }

</script>