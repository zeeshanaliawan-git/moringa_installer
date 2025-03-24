<!-- Modal -->
<div class="modal fade" id="modalAddEditPage" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
        <div class="modal-content">
            <form id="addEditPageForm" action="" onsubmit="return false;" novalidate>
                <input type="hidden" name="requestType" value="savePage">
                <input type="hidden" name="pageType" value="freemarker">
                <input type="hidden" name="pageId" id="pageId" value="">
                <input type="hidden" name="folderId" value="">

                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel"></h5>
                    <div class="text-right">
                        
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
                <div class="modal-body">
<div class="text-right mb-3"><button type="button" class="btn btn-primary" onclick="onSavePage()">Save</button></div>
                    <%
                        String _pageFirstSectionHeading = "Global information";
						boolean _disableTags = false;
                    %>
                    <%@ include file="pagesAddEditFields.jsp" %>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="onSavePage()">Save</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<!-- /.modal -->
<%
    String _IMAGE_URL_PREPEND = getImageURLPrepend(getSiteId(session));
    String _CATALOG_ROOT = GlobalParm.getParm("CATALOG_ROOT") + "/";
%>
<script type="text/javascript">

    window.IMAGE_URL_PREPEND = '<%=_IMAGE_URL_PREPEND%>';
    window.CATALOG_ROOT = '<%=_CATALOG_ROOT%>';

    window.allTagsList = <%=getAllTagsJSON(Etn, getSiteId(session), GlobalParm.getParm("CATALOG_DB") )%>;

    // ready function
    $(function () {

        $('#modalAddEditPage').on('show.bs.modal', onShowModalAddEditPage);

        var addEditPageForm = $('#addEditPageForm');

        var pageTagInput = addEditPageForm.find("input[name=pageTagInput]");
        initTagAutocomplete(pageTagInput)

        var pathPrefixHtml = "";

        <%
            langRs = Etn.execute("SELECT * FROM language ORDER BY langue_id");
            while(langRs.next()){
        %>
        pathPrefixHtml += "<span class='input-group-text pagePathPrefix' id = 'pagePathPrefix_<%=langRs.value("langue_code")%>'>/</span>";
        <%  }  %>
        addEditPageForm.find('.pagePathPrefixDiv').html(pathPrefixHtml);

        addEditPageForm.find('select[name="langue_code"]')
        .on('change', function () {
            var selectedLangCode = $(this).val();
            addEditPageForm.find('span.pagePathPrefix').hide();
            if (selectedLangCode.length > 0) {
                $('#pagePathPrefix_' + selectedLangCode).show();
            }
        }).trigger('change');

    });

    function onShowModalAddEditPage(event) {
        var button = $(event.relatedTarget);
        var modal = $(this);
        var form = $('#addEditPageForm');
        form.get(0).reset();
        form.find('[name=pageId]').val('');
        form.find('.customMetaTagContent').html('');
        form.find(".pageTagsDiv").html('');
        form.find("._secondaryTagsDiv").html('');
        form.removeClass('was-validated');
        var caller = button.data('caller');

        if (caller == "edit") {
            var pageId = button.data('page-id');

            showLoader();
            $.ajax({
                url : 'pagesAjax.jsp', type : 'POST', dataType : 'json',
                data : {
                    requestType : "getPageInfo",
                    pageId : pageId
                },
            })
            .done(function (resp) {
                if (resp.status == 1) {

                    var page = resp.data.page;

                    modal.find('.modal-title').text("Edit page : " + page.name);

                    var fieldList = ["name", "path", "variant", "canonical_url", "title",
                        "langue_code", "template_id", "meta_keywords", "meta_description",
                        "dl_page_type", "dl_sub_level_1", "dl_sub_level_2",
                        "social_title", "social_type", "social_description",
                        "social_image",
                        "social_twitter_message", "social_twitter_hashtags",
                        "social_email_subject", "social_email_message",
                        "social_email_popin_title", "social_sms_text"];

                    $.each(fieldList, function (index, fieldName) {
                        form.find('[name=' + fieldName + ']').val(page[fieldName]);
                    });

                    var selectedLangCode = form.find('select[name="langue_code"]').children("option:selected").val();
                    $('#path_prefix_' + selectedLangCode).removeClass("d-none");

                    setPagePrefixPaths(page.pagePathPrefixList);

                    var socialImgSrc = "";
                    if (page.social_image.length > 0) {
                        socialImgSrc = IMAGE_URL_PREPEND + page.social_image;
                    }
                    form.find('.social_image_body img').attr('src', socialImgSrc);

                    var addCustomMetaTagButton = form.find('.addCustomMetaTagButton');
                    $.each(page.custom_meta_tags, function (index, metaObj) {
                        addCustomMetaTag(addCustomMetaTagButton, metaObj);
                    });

                    var tagInput = form.find("input[name=pageTagInput]");
                    $.each(page.tags, function (index, tagObj) {
                        addTagGeneric(tagObj, tagInput);
                    });

                    form.find('[name=pageId]').val(page.id);

                    form.find('[name=meta_description]').trigger('keyup');
                    checkSocialImageDimensions(form);
                }
                else {
                    // bootNotify(resp.message, "danger");
                    modal.modal('hide');
                }
            })
            .fail(function () {
                bootNotifyError("Error in accessing server.");
                modal.modal('hide');
            })
            .always(function () {
                hideLoader();
            });

        }
        else {

            showLoader();
            $.ajax({
                url : 'foldersAjax.jsp', type : 'POST', dataType : 'json',
                data : {
                    requestType : "getPagePrefixPathsByFolderId",
                    folderId : $('#folderId').val()
                },
            })
            .done(function (resp) {
                if (resp.status == 1) {
                    modal.find('.modal-title').text("Add a new Page");
                    setPagePrefixPaths(resp.data.pagePathPrefixList);
                }
                else {
                    modal.modal('hide');
                }
            })
            .fail(function () {
                bootNotifyError("Error in accessing server.");
                modal.modal('hide');
            })
            .always(function () {
                hideLoader();
            });
        }
    }

    function setPagePrefixPaths(pagePrefixPathsList){
        pagePrefixPathsList.forEach(function(curPathPrefix){
            var pathPrefixEle = $('#pagePathPrefix_' + curPathPrefix.langue_code);
            if (pathPrefixEle.length > 0) {
                pathPrefixEle.text(curPathPrefix.concat_path + "/");
            }
        });
    }

    function onSavePage() {

        var form = $('#addEditPageForm');
        var folderId = $('#folderId').val();
        if (!form.get(0).checkValidity() || !checkSocialImageDimensions(form)) {
            form.addClass('was-validated');
            return false;
        }


        var pageTags = [];
        form.find('.pageTagsDiv input.tagValue').each(function (index, el) {
            var tagId = $(el).val().trim();
            if (tagId.length > 0 && pageTags.indexOf(tagId) < 0) {
                pageTags.push(tagId);
            }
        });
        form.find('[name=pageTags]').val(pageTags.join(","));
        form.find('[name=folderId]').val(folderId);

        showLoader();
        $.ajax({
            url : 'pagesAjax.jsp', type : 'POST', dataType : 'json',
            data : form.serialize(),
        })
        .done(function (resp) {
            if (resp.status === 1) {
                form.find('[name=pageId]').val(resp.data.pageId);

                $('#modalAddEditPage').modal('hide');
                onPageSaveSuccess(resp, form);
                bootNotify("Page saved successfully");
            }
            else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error in saving page. please try again.");
        })
        .always(function () {
            hideLoader();
        });

    }


</script>