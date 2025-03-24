<%-- This file for including in other pages at the end of body tag --%>
<%-- required  variable String 'screenType' --%>
<%! 
    String screenType = Constant.SCREEN_TYPE_BLOCKS;
%>
<div class="modal fade" id="modalAddNewBloc" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-dialog-slideout" role="document">
        <div class="modal-content">
                <div class="modal-header bg-lg1">
                <h5 class="modal-title">Add a new <%=screenType%></h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row mb-3 onPageEditor">
                    <div class="col-12">
                        <button type="button" class="btn btn-primary"
                            data-toggle="modal" data-target="#modalExistingBlocs"
                            onclick="$('#modalAddNewBloc').modal('hide')">
                            List of previous created <%=screenType%>s</button>
                    </div>
                </div>

                <div class="mb-2">
                    <input class="form-control" id="search-text-field" type="text" placeholder="Search"/>
                </div>
                <%
                    String blcTQuery = "SELECT id, name, type, custom_id FROM bloc_templates "
                                        + " WHERE site_id = " + escape.cote(getSiteId(session));
                    if(screenType.equals(Constant.SCREEN_TYPE_MENUS)){
                        blcTQuery += " AND type = '"+Constant.SYSTEM_TEMPLATE_MENU+"'"  ;
                    }
                    else{
                        blcTQuery += " AND type IN ('block','feed_view')";
                    }
                    blcTQuery += " ORDER BY name" ;
                    Set blocTmpltRs = Etn.execute(blcTQuery);
                    while(blocTmpltRs.next()){
                        String blocid= blocTmpltRs.value("id");
                        String blocName= blocTmpltRs.value("name");
                        String blocType= blocTmpltRs.value("type");
                %>
                <div style="display: flex;" class="node">
                    <div class="btn-group w-100 mb-2" >
                        <button type="button" class="btn btn-secondary btn-block text-left d-flex justify-content-between align-items-center" data-caller="add"
                    data-template='<%=blocTmpltRs.value("name")%>' data-template-id='<%=blocTmpltRs.value("id")%>'
                            data-template-type='<%=blocTmpltRs.value("type")%>' onclick="addNewBloc(this);" style="line-height:1">
                            <span class="font-weight-bold ">
                                <%=blocTmpltRs.value("name")%>
                            </span>
                            <span class="pull-right">
                                <i data-feather="plus-circle"></i>
                            </span>
                        </button>
                        <button class="btn btn-warning align-items-center" data-toggle="modal" data-target="#modalBlocInformation"
                            onclick="$('#modalAddNewBloc').modal('hide');processInfoModal('<%=blocid%>','<%=blocName%>','<%=blocType%>');">
                        <i data-feather="help-circle"></i>
                        </button>
                    </div>
                </div>
                <%
                    }
                %>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<div class="modal fade" id="modalBlocInformation" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
        <div class="modal-content">
                <div class="modal-header bg-lg1">
                <h5 class="modal-title">Block Information</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                
                <div class=" mb-3 text-right">
                    <div class="btn-group mr-2">
                        <button type="button" class="btn btn-primary"
                            data-toggle="modal" data-target="#modalAddNewBloc"
                            onclick="$('#modalBlocInformation').modal('hide')">
                            Back</button>
                        <button type="button" class="btn btn-primary btn-block use-template" data-caller="add" onclick="useTemplate(this)">Use this template</button>
                    </div>
                </div>
                <div class="container-fluid">
                    <ul class="nav nav-tabs" id="blocInfoLangNavTabs" role="tablist">
                        <% active = true; for (Language lang : langsList) { %>
                        <li class="nav-item" data-lang-id="<%= lang.getLanguageId() %>">
                            <a class='nav-link <%=(active)?"active mainLang":"" %>' data-lang-id="<%= lang.getLanguageId() %>"
                                id="blocInfoLangTab_<%= lang.getLanguageId() %>" data-toggle="tab" href="#blocInfoLangTabContent_<%= lang.getLanguageId() %>"
                                role="tab" aria-controls="<%= lang.getLanguage() %>" aria-selected="true"><%= lang.getLanguage() %>
                            </a>
                        </li>
                        <% active = false; } %>
                    </ul>

                    <div class="modal-inner-content" id="languageTabsContent">
                        <div class="tab-content">
                            <% active = true; for (Language lang : langsList) { %>
                            <div class="tab-pane fade <%= (active) ? "show active" : "" %> container" id="blocInfoLangTabContent_<%= lang.getLanguageId() %>" role="tabpanel"></div>
                            <% active = false; } %>
                        </div>
                    </div>
                </div>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->


<div class="modal fade" id="modalExistingBlocs" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-dialog-slideout" role="document">
        <div class="modal-content">
            <div class="modal-header bg-lg1">
                <h5 class="modal-title">List of existing <%=screenType%>s</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row mb-3">
                    <div class="col-12">
                        <button class="btn btn-primary mr-2"
                            data-toggle="modal" data-target="#modalAddNewBloc"
                            onclick="$('#modalExistingBlocs').modal('hide')">
                            Add new <%=screenType%></button>
                    </div>
                </div>
                <form action="" id="existingBlocsSearchForm" onsubmit="return false;">

                <fieldset class="form-group mb-1">
                    <input type="text" class="form-control"
                            name="search" placeholder="Search"
                            onkeyup="searchExistingBlocs();">
                </fieldset>
                <fieldset class="form-group">
                    <select class="custom-select" name="blocType"
                        onchange="searchExistingBlocs()" >

                        <option value="">Filter on type</option>
                        <option value='form'>Form</option>
                    <%
                        blocTmpltRs.moveFirst();
                        while(blocTmpltRs.next()){
                    %>
                        <option value='<%=blocTmpltRs.value("custom_id")%>'>
                            <%=blocTmpltRs.value("name")%></option>
                    <%
                        }
                    %>
                    </select>
                </fieldset>
                <fieldset class="form-group row">
                    <label class="col col-form-label"> Add bloc at</label>
                    <div class="col-8">
                        <select class="custom-select" name="addBlocPosition" id="addBlocPosition" >
                            <option value="bottom">Bottom</option>
                            <option value="top">Top</option>
                        </select>
                    </div>
                </fieldset>
                <ul id="existingBlocsList" class="mt-3 px-0" style="list-style: none;">


                </ul>
                    <div id="existingBlocsListTemplate" class="d-none">
                        <li class="btn border-0 w-100 mb-1" style="background-color: #CCC;"
                            onclick="addExistingBloc('#BLOC_ID#')" >
                            <div class="row" >
                                <div class="col text-left">
                                    <h6 class="m-0 font-weight-bold">#BLOC_NAME#</h6>
                                    <div class="small">#TEMPLATE_NAME#</div>
                                </div>
                                <div class="col d-flex flex-row-reverse align-items-center">
                                    <i data-feather="plus-circle"></i>
                                </div>
                            </div>
                        </li>
                    </div>
                </form>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<div class="modal fade" id="modalAddEditBloc" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-xl modal-dialog-slideout" role="document">
        <div class="modal-content">
            <div class="modal-header bg-lg1">
                <h5 class="modal-title"></h5>
                <div class="text-right">
                     <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

            </div>
            <div class="modal-body">
                <div class="mb-3 text-right">
                    <div class="btn-group mr-2">
                        <button type="button" class="btn btn-primary"
                                onclick="onSaveBloc()">
                            Save
                        </button>
                        <button type="button" class="btn btn-primary onPageEditor savePlaceBtn"
                                onclick="onSaveAndPlaceBloc()">
                            Save & place
                        </button>
                    </div>

                    <button type="button" class="btn btn-primary"
                            onclick="toggleAddEditBloc(this)" id="blocSettingsBtn">
                        <i data-feather="settings"></i>
                    </button>

                </div>
                <div class="container-fluid">
                    <ul class="nav nav-tabs " id="blocLangNavTabs" role="tablist">
                        <%
                            active = true;
                            for (Language lang: langsList) {
                        %>
                        <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
                            <a class='nav-link <%=(active)?"active mainLang":""%>' data-lang-id="<%=lang.getLanguageId()%>"
                               id="blocLangTab_<%=lang.getLanguageId()%>" data-toggle="tab" href="#blocLangTabContent_<%=lang.getLanguageId()%>"
                               role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%>
                            </a>
                        </li>
                        <%
                                active = false;
                            }
                        %>
                    </ul>
                    <div class="tab-content p-3">

                        <form id="addEditBlocForm" action="" method="POST" onsubmit="return false;" novalidate>
                            <input type="hidden" name="requestType" value="">
                            <input type="hidden" name="blocId" value="">
                            <input type="hidden" name="template_id" value="">
                            <input type="hidden" name="uniqueIds" value="">
                            <input type="hidden" name="template_type" value="">
                            <input type="hidden" name="rss_feed_ids" value="">
                            <input type="hidden" name="blocTags" value="">
                            <input type="hidden" name="detailsJson" value="">
                            <input type="hidden" name="triggerEvents" value="">
                            <div class="row nameRow notMultiLang">
                                <div class="col-12">
                                    <div class="form-group row">
                                        <label class="col col-form-label">Name</label>
                                        <div class="col-9">
                                            <input type="text" name="name" class="form-control" value=""
                                                   required="required" maxlength="100" id="blocNameField">
                                            <div class="invalid-feedback">
                                                Cannot be empty.
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col col-form-label">Tags</label>
                                        <div class="col-9">
                                            <input type="text" name="blocTagInput" class="form-control tagInputField"
                                                   value=""
                                                   placeholder="search and add (by clicking return)" onfocus="initTagAutocomplete(this)">
                                        </div>
                                        <div class="tagsDiv col-sm-12 form-group mt-3 blocTagsDiv"></div>
                                    </div>
                                    <div class="form-group row">
                                        <div class="col-9 offset-3 blocErrorMsg invalid-feedback"
                                             style="display: block;"></div>
                                    </div>
                                </div>
                            </div>
                            <div id="blocRssFeedsRow" class="row notMultiLang">
                                <div class="col-12">
                                    <div class="rssFeedFieldsContainer">

                                    </div>
                                    <div class="addRssBtn text-right mb-2">
                                        <button type="button" class="btn btn-success"
                                                onclick="addRssFeedField()">Add Rss feed
                                        </button>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col col-form-label">Sort by</label>
                                        <div class="col-9">
                                            <div class="input-group">
                                                <select name="rss_feed_sort" class="custom-select">
                                                    <option value="date_desc">Newest to oldest</option>
                                                    <option value="date_asc">Oldest to newest</option>
                                                    <option value="title_asc"> A -&gt; Z</option>
                                                    <option value="title_desc"> Z -&gt; A</option>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div id="blocParamRow" class="blocParamRow notMultiLang">
                                <div class="card">
                                        <div class="card-header bg-secondary" data-toggle="collapse" href="#blocParamCollapse" role="button">
                                            <strong >
                                                Bloc Parameters
                                            </strong>
                                    </div>
                                    <div class="collapse show pt-3" id="blocParamCollapse">
                                        <div class="card-body">
                                        <div class="form-group row">
                                            <label class="col col-form-label">Refresh</label>
                                            <div class="col-9">
                                                <select name="refresh_interval" class="custom-select">
                                                    <option value="0">Never</option>
                                                    <option value="15">every 15 minutes</option>
                                                    <option value="30">every 30 minutes</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Start at</label>
                                            <div class="col-9">
                                                <div class="input-group">
                                                    <input name="start_date" type="text"
                                                           class="form-control datepicker">
                                                    <div class="input-group-append">
                                                        <span class="input-group-text">
                                                            <i data-feather="calendar"></i>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">End at</label>
                                            <div class="col-9">
                                                <div class="input-group">
                                                    <input name="end_date" type="text"
                                                           class="form-control datepicker">
                                                    <div class="input-group-append">
                                                        <span class="input-group-text">
                                                            <i data-feather="calendar"></i>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Displayed for</label>
                                            <div class="col-9">
                                                <select name="visible_to" class="custom-select">
                                                    <option value="all">All</option>
                                                    <option value="anonymous">Anonymous</option>
                                                    <option value="logged">Logged</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Margin top</label>
                                            <div class="col-9">
                                                <select name="margin_top" class="custom-select">
                                                    <option value="0">0px</option>
                                                    <option value="10">10px</option>
                                                    <option value="20">20px</option>
                                                    <option value="30">30px</option>
                                                    <option value="40">40px</option>
                                                    <option value="50">50px</option>
                                                    <option value="60">60px</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Margin bottom</label>
                                            <div class="col-9">
                                                <select name="margin_bottom" class="custom-select">
                                                    <option value="0">0px</option>
                                                    <option value="10">10px</option>
                                                    <option value="20">20px</option>
                                                    <option value="30">30px</option>
                                                    <option value="40">40px</option>
                                                    <option value="50">50px</option>
                                                    <option value="60">60px</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col col-form-label">Description</label>
                                            <div class="col-9">
                                                <input type="text" name="description" class="form-control" value="">
                                            </div>
                                        </div>
                                        </div>
                                    </div><!--  collapse -->
                                    </div>
                                </div>
                        </form>

                        <div id="blocDataRow" class="tab-content">
                            <%
                                active = true;
                                for (Language lang:langsList) {
                            %>
                            <div class='tab-pane blocLangTabContent <%=(active)?"show active":""%>'
                                 id="blocLangTabContent_<%=lang.getLanguageId()%>"
                                 role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                <!-- templateSections -->
                                <form name="templateSectionsForm_<%=lang.getLanguageId()%>" class="langTemplateForm"
                                      action="" method="POST" onsubmit="return false;">
                                    <div class="langContent template_container bloc_section"
                                         id="blocLangContent_<%=lang.getLanguageId()%>" data-lang-id="<%=lang.getLanguageId()%>">

                                    </div>
                                </form>
                                <!-- /templateSections -->
                            </div>
                            <!-- tabContent -->
                            <%
                                    active =false;
                                }//for lang tab content
                            %>
                        </div>

                    </div>
                </div>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>

                <!-- <button type="submit" class="btn btn-primary" >Save</button> -->
                <button type="button" class="btn btn-primary"
                        onclick="onSaveBloc()">
                    Save
                </button>
                <button type="button" class="btn btn-primary onPageEditor savePlaceBtn"
                        onclick="onSaveAndPlaceBloc()">
                    Save & place
                </button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<!-- /.modal -->
<div class="d-none">
    <div id="template_rss_feed">
        <div class="form-group row rssFeedField">
                <label class="col col-form-label fieldLabel">Select RSS feed</label>
                <div class="col-9">
                    <div class="input-group">
                        <select name="rss_feed_id" class="custom-select" required="required" >
                            <option value=""> -- RSS feed --</option>
                        <%
                            String feedQ = "SELECT id, name FROM rss_feeds"
                                        + " WHERE site_id = " + escape.cote(getSiteId(session))
                                        + " AND is_active = 1 "
                                        + " ORDER BY name" ;
                            Set feedRs = Etn.execute(feedQ);
                            while(feedRs.next()){
                                out.write("<option value='"+feedRs.value("id")+"'>"
                                            +feedRs.value("name")+"</option>");
                            }
                        %>
                        </select>
                        <div class="input-group-append deleteBtn">
                            <button type="button" class="btn btn-danger"
                                onclick="deleteRssFeedField(event, this)">
                                <span aria-hidden="true">&times;</span></button>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<!-- template functions -->
<%@ include file="templateFunctions.jsp" %>

<script type="text/javascript">
    window.CATALOG_ROOT = '<%=GlobalParm.getParm("CATALOG_ROOT") + "/"%>';
    window.settingsIcon = feather.icons['settings'].toSvg();
    window.loadingBlocData = false;
    window.allTagsList = <%=getAllTagsJSON(Etn, getSiteId(session), GlobalParm.getParm("CATALOG_DB") )%>;

    $ch.screenType = '<%=screenType%>';

    // ready function
    $(function () {

        const picker = flatpickr('.datepicker', {
            dateFormat: "Y-m-d",
        });

        $('#blocLangNavTabs a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
            // e.target // newly activated tab
            // e.relatedTarget // previous active tab
            //on lang change enable/disable fields
            var tab = $(e.target);
            var readonlyFields = $('#modalAddEditBloc .notMultiLang ').find('input,textarea');
            var disableFields = $('#modalAddEditBloc .notMultiLang').find('select,button,[type=button],.datepicker');
            if (tab.hasClass('mainLang')) {
                //main language, enable all fields
                disableFields.prop('disabled',false);
                readonlyFields.prop('readonly', false);
            }
            else {
                // not 1st/main language , make non-multi lang fields readonly
                disableFields.prop('disabled',true);
                readonlyFields.prop('readonly', true);
            }

        });

        $('#modalAddNewBloc').on('hidden.bs.modal', function (event) {
            if (typeof window.tempAddNewBlocRef != "undefined"
                && window.tempAddNewBlocRef != null) {

                var addNewBlocRef = window.tempAddNewBlocRef;

                window.tempAddNewBlocRef = null;
                openAddEditBloc(addNewBlocRef);
            }
        });

        $('#modalExistingBlocs').on('show.bs.modal', function(event){
            var button = $(event.relatedTarget);
            var modal = $(this);

            var form = $('#existingBlocsSearchForm');
            form.get(0).reset();

            if(getPageBlocIds){
                var existingBlocCount = getPageBlocIds().length;
                var positionSelect = $('#addBlocPosition');
                positionSelect.find('option.tempPosition').remove();

                for (var i = 0; i < existingBlocCount+1; i++) {
                    var option = $('<option>')
                                    .attr('value',i)
                                    .addClass('tempPosition')
                    .text('position #' + (i + 1));
                    positionSelect.append(option);
                }
            }

            searchExistingBlocs();

        });

        $("#modalBlocInformation").on('hide.bs.modal',function(){
            var modal = $(this);
            var useTemplateBtn = modal.find(".use-template");
            useTemplateBtn.removeAttr("data-template-id data-template-type data-template");
            useTemplateBtn.off("click");
            //modal.find(".modal-inner-content").empty();
            window.tempAddNewBlocRef = undefined;
        });

        $('#modalAddEditBloc')
        .on('shown.bs.modal', function () {
            //work around fix for ckeditor dialog inputs not working inside modal
            $(document).off('focusin.bs.modal');

            var modal = $(this);
            modal.find('.modal-dialog').animate({scrollTop : 0});
        });

        $('#modalAddEditBloc')
        .on('hide.bs.modal', function () {
            $(this).find("input[name='template-name']").remove();
        });

        $('body').on('hidden.bs.modal', function () {
            if ($('.modal.show').length > 0) {
                $('body').addClass('modal-open');
            }
        });

        initTagAutocomplete($('#addEditBlocForm').find('input[name=blocTagInput]'));

        $("#search-text-field").on("input",function(){
            let search = $(this).val();
            if(search.length>0){
                $("button[data-template]").each(function() {
                    var templateValue = $(this).attr("data-template");
                    if (!templateValue.toLowerCase().includes(search.toLowerCase())) {
                        $(this).closest(".node").hide(); 
                    }else{
                        $(this).closest(".node").show(); 
                    }
                });
            }
            else{
                $("button[data-template]").each(function() {
                    $(this).closest(".node").show();
                });
            }
        });
    });

    function searchExistingBlocs() {
        var form = $('#existingBlocsSearchForm');

        var search = form.find('[name=search]').val();
        var blocType = form.find('[name=blocType]').val();

        // showLoader();
        $.ajax({
            url: 'blocsAjax.jsp', type: 'GET', dataType: 'json',
            data: {
                requestType : 'getBlocsAndFormsList',
                search : search,
                blocType : blocType,
                screenType : '<%=screenType%>'
            },
        })
        .done(function(resp) {
            var listHtml = '';
            if(resp.status == 1){

                var curSearch = form.find('[name=search]').val();
                var curBlocType = form.find('[name=blocType]').val();

                //check if result is of cur value
                if(curSearch !== resp.data.search || curBlocType !== resp.data.blocType){
                    return;
                }

                var listItemTemplate = $('#existingBlocsListTemplate');

                $.each( resp.data.blocs , function(index, obj) {
                    var itemHtml = listItemTemplate.html();
                    itemHtml = strReplaceAll(itemHtml, "#BLOC_ID#", obj.id);
                    itemHtml = strReplaceAll(itemHtml, "#BLOC_NAME#", obj.name);
                    itemHtml = strReplaceAll(itemHtml, "#TEMPLATE_NAME#", obj.template);

                    listHtml = listHtml + itemHtml;
                });
            }
            $('#existingBlocsList').html(listHtml);
        })
        .fail(function() {
            alert('Error in accessing server');
        })
        .always(function() {
            // hideLoader();
        });

    }

    function processInfoModal(id,name,type){

        $('[id^="blocInfoLangTabContent_"]').each(function() {
                $(this).empty();
        });

        $.ajax({
            url: 'blocTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getTemplateDescription',
                templateId : id
            },
        }).done(function(resp){
            if(resp.status == 1){
                var infoModal = $("#modalBlocInformation");
                var useTemplateBtn = infoModal.find(".use-template");
                useTemplateBtn.attr({"data-template":name,"data-template-id":id,"data-template-type":type});
                $.each(resp.data.template,function(index,jsonObject){
                    var langId = jsonObject.lang_id;
                    var infoModalContent = $("#blocInfoLangTabContent_" + langId);
                    var outerDiv = $("<div>").addClass("mb-3");
                    var rowTag = $("<div>");
                    var imgTag = $("<img>").addClass("mb-2");
                    imgTag.css({
                        "max-height" : "200px",
                        "width" : "100%",
                        "height" : "auto",
                        "object-fit" : "contain"
                    });
                    imgTag.attr("src",IMAGE_URL_PREPEND+jsonObject.image_src);
                    imgTag.attr("alt",jsonObject.image_label);
                    rowTag.append(imgTag);
                    outerDiv.append(rowTag).append("<br>").append("<br>").append(jsonObject.description);
                    infoModalContent.append(outerDiv);
                });
            }
            else
            {
                bootNotifyError(resp.message);
            }
        }).fail(function(resp){
            bootNotifyError(resp.message);
        });
        
    }

    function resetTransition(modal){
        setTimeout(function(){
            if(modal.data()["bs.modal"]){
                modal.data()["bs.modal"]._isTransitioning = false;
            }
        },2000);

    }

    function addNewBloc(btn){
        var modal = $('#modalAddNewBloc');
         window.tempAddNewBlocRef = btn.cloneNode(true);
        $('#modalBlocInformation').modal('hide');
        modal.modal('hide');
    }
    
    function useTemplate(btn){
        window.tempAddNewBlocRef = btn;
        openAddEditBloc(btn);
        $('#modalBlocInformation').modal('hide');
    }

    function openAddEditBloc(btn,name){
        var button = $(btn);
        var modal  = $('#modalAddEditBloc');

        var caller = button.data('caller');
        var blocId = button.data('bloc-id');
        var blocTemplate = button.data('template');
        var templateId = button.data('template-id');
        var templateType = button.data('template-type');
         
        if( !caller || !blocTemplate
            || blocTemplate.trim().length == 0){

            //bootstrap bug , workaround fix
            resetTransition(modal);
            return false;

        }

        var form = $('#addEditBlocForm');
        form.get(0).reset();
        form.find('.blocTagsDiv').html('');

        var blocErrorMsg = form.find('.blocErrorMsg');
        blocErrorMsg.html('');

        // var mainLangTab = $('#blocLangNavTabs li:first a[data-toggle=tab]:first');
        // mainLangTab.tab('show');
        let langId = $("#langNavTabs li a.active").attr("data-lang-id");
        if(langId){
            $('.nav-tabs a[href="#blocLangTabContent_'+langId+'"]').tab('show');
        } else{
            $('.nav-tabs a[href="#blocLangTabContent_1"]').tab('show');
        }


        var blocSettingsBtn = $('#blocSettingsBtn');
        var blocDataRow = $('#blocDataRow');
        var blocParamRow = $('#blocParamRow');
        var blocRssFeedsRow = $('#blocRssFeedsRow');

        blocDataRow.show();
        blocParamRow.hide();
        blocRssFeedsRow.hide();
        blocRssFeedsRow.find('.rssFeedFieldsContainer').html('');

        if(blocSettingsBtn.text() == 'back'){
            blocSettingsBtn.html(window.settingsIcon);
        }

        if(caller == "edit" || caller == "settings"){
            if(!blocId){
                resetTransition(modal);
                return event.preventDefault();
            }

            if(caller == "settings"){
                blocDataRow.hide();
                blocParamRow.show();
                blocSettingsBtn.html('back');
            }
            modal.find('.modal-title').text(`Edit \${$ch.screenType} : `);
            modal.find('.savePlaceBtn').hide();

            loadBlocData(modal, form, blocId);
        }
        else if(caller == "add"){

            if( !blocTemplate || blocTemplate.trim().length == 0){
                resetTransition(modal);
                return event.preventDefault();
            }
            
            modal.find('.modal-title').text("Add a new "+ $ch.screenType +" : "+blocTemplate);
            if($ch.isPageEditor){
                modal.find('.savePlaceBtn').show();
            }
            // blocDataRow.html('');
            loadBlocTemplateForm(modal, form, templateId);
            form.find('#blocNameField').val(name);
            form.append($("<input>").attr("type", "hidden").attr("disabled",true).attr("name","template-name").val(blocTemplate))
            form.find('[name=template_type]').val(templateType);

            if(templateType === 'feed_view'){
                blocRssFeedsRow.show();
                blocRssFeedsRow.find('.rssFeedFieldsContainer').html('');
                addRssFeedField();
            }

        }
        else{
            resetTransition(modal);
            return false;
        }

    }

    function toggleAddEditBloc(btn){

        var blocDataRow = $('#blocDataRow');
        var blocParamRow = $('#blocParamRow');
        if(blocDataRow.is(':visible')){
            blocDataRow.hide();
            blocParamRow.toggle({direction: 'left'},'fast');
            $(btn).html('back');
        }
        else{
            blocParamRow.hide();
            blocDataRow.toggle({direction: 'left'},'fast');
            $(btn).html(window.settingsIcon);
        }
    }

    function loadBlocTemplateForm(modal, form, templateId){

        showLoader();
        $.ajax({
            url: 'blocTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getTemplateSectionsData',
                template_id : templateId
            },
        })
        .done(function (resp) {
            if (resp.status == 1) {
                form.find('[name=blocId]').val('');

                form.find('[name=template_id]').val(templateId);

                var template_code = resp.data;
                form.data('template_code', template_code);

                var blocDetails = {};
                form.find('[name=detailsJson]').val(JSON.stringify(blocDetails));
                generateTemplateForm(template_code, blocDetails);
                modal.modal('show');
            }
            else {
                alert(resp.message);
            }
        })
        .always(function () {
            hideLoader();
        });

    }

    function loadBlocData(modal,form, blocId){

        showLoader();
        $.ajax({
            url: 'blocsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getBlocData',
                blocId : blocId
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                blocData = resp.data.bloc_data;
                form.find('[name=blocId]').val(blocData.id);

                form.find('[name=template_id]').val(blocData.template_id);
                form.find('[name=template_type]').val(blocData.template_type);
                
                form.find('[name=name]').val(blocData.name);
                var modalTitle = `Edit \${$ch.screenType} : \${blocData.name} ( \${blocData.template_name} ) `;
                modal.find('.modal-title').text(modalTitle);

                var blocTagInput = form.find("input[name=blocTagInput]");
                $.each(blocData.tags, function(index, tagObj) {
                     addTagGeneric(tagObj, blocTagInput);
                });
                form.find('[name=refresh_interval]').val(blocData.refresh_interval);
                form.find('[name=start_date]').val(blocData.start_date);
                form.find('[name=end_date]').val(blocData.end_date);
                form.find('[name=visible_to]').val(blocData.visible_to);
                form.find('[name=margin_top]').val(blocData.margin_top);
                form.find('[name=margin_bottom]').val(blocData.margin_bottom);
                form.find('[name=description]').val(blocData.description);
                form.find('[name=triggerEvents]').val(resp.data.bloc_data.triggers);
                try{             
                    trigger = JSON.parse(decodeURIComponent(resp.data.bloc_data.triggers));
                }catch(err)
                {
                    trigger = '';
                }
                form.find('[name=detailsJson]').val(JSON.stringify(blocData.details));
                form.data('blocDetails', blocData.details);
                form.data('template_code', resp.data.template_code);

                generateTemplateForm(resp.data.template_code, blocData.details);

                if (blocData.template_type === 'feed_view') {
                    var blocRssFeedsRow = $('#blocRssFeedsRow');
                    blocRssFeedsRow.show();
                    blocRssFeedsRow.find('.rssFeedFieldsContainer').html('');

                    var rss_feed_ids = blocData.rss_feed_ids.split(",");
                    $.each(rss_feed_ids, function (index, feedId) {
                        if (feedId.trim().length > 0) {
                            addRssFeedField(feedId.trim());
                        }
                    });

                    if(blocRssFeedsRow.find('.rssFeedField').length == 0){
                        //add atleast 1 rss feed field
                        addRssFeedField();
                    }

                    form.find('[name=rss_feed_sort]').val(blocData.rss_feed_sort);
                }

                modal.modal('show');
                if(arrTrigger.length > 0)
                    triggerChange();
            }
            else {
                alert(resp.message);
            }
        })
        .always(function () {
            hideLoader();
        });

    }

    function generateTemplateForm(templateCode, dataDetails) {
        
        $ch.langContentDivs = $('#blocDataRow .langContent');
        var langContentDivs = $ch.langContentDivs;
        langContentDivs.html('');
        var sections = templateCode.sections;
        if (!sections || sections.length == 0) {
            langContentDivs.append("<span class='text-danger'>No template fields defined</span>");
            return false;
        }
        langContentDivs.each(function (index, langContent) {
            langContent = $(langContent);
            var curLangId = langContent.data("langId");
            $.each(sections, function (index, secCode) {
                var sectionDiv = generateSectionContainer(secCode, langContent, curLangId);
                var landDetailObj = dataDetails[curLangId]
                if (typeof landDetailObj === 'object') {
                    try {
                        var templateDataObj = JSON.parse(landDetailObj.template_data);

                        //now filling form with existing data
                        fillBlocData(templateDataObj, sectionDiv);
                    } catch (ex) {
                        console.log(ex);
                    }
                }

            });

            $(".selectDiv").on("input",".autocomplete_input",function(){
                let value = $(this).val();
                let selectDiv = $(this).closest('.selectDiv');
                let autocompleteList = selectDiv.find(".autocomplete-items");
                if(value.length>1){
                    autocompleteList.show();
                    $.each(autocompleteList.find("li"),function(idx,element){
                        if(element.textContent.toLowerCase().includes(value.toLowerCase())) $(element).show();
                        else $(element).hide();
                    });
                }else{
                    autocompleteList.hide();
                }
            });

            $(".selectDiv").on('mousedown','.autocomplete-item',function(){
                $(this).closest('.selectDiv').find('.autocomplete_input').val($(this).text());
                $(this).closest('.selectDiv').find('select').val($(this).attr('value'));
            });

            $(".selectDiv").on('blur','.autocomplete_input',function(){
                $(this).closest('.selectDiv').find(".autocomplete-items").hide();
            });

            $('.uniqueId').on('blur',function(){
                let ele = $(this);
                if($(ele).prop("readonly")) return;
                
                let templateId = $('[name="template_id"]').val();
                let blocId = document.getElementById('addEditBlocForm').querySelector('input[name="blocId"]').value;

                if(blocId === undefined || blocId === null || blocId.length === 0){
                    blocId="";
                }

                if(ele.val().length>0){
                    ele.val().replace("$",'');

                    var uniqueIds = [];
                    $.each($('.langTemplateForm > div:first').find(".uniqueId"),function (index, el) {
                        var uniqueId = $(el).val().trim();
                        if (uniqueId.length > 0 && uniqueIds.indexOf(uniqueId) < 0) {
                            uniqueIds.push(uniqueId);
                        }
                    });

                    $.ajax({
                        url: 'blocsAjax.jsp',
                        dataType: 'json',
                        data: {
                            requestType : "checkUniqueId",
                            id : uniqueIds.join('$'),
                            templateId: templateId,
                            blocId : blocId,
                            pageType : "blocs",
                        },
                    })
                    .done(function(resp) {
                        let value = "";
                        let className = "";
                        if(resp.status == '0'){
                            value = "";
                            className = "is-invalid";
                            bootNotifyError("Id is not unique.");
                        }else{
                            value = ele.val();
                            className = "";
                        }
                        let langId = ele.closest(".langContent").data("langId");
                        langContentDivs.each(function(idx,langContentDiv){
                            let sectionId = ele.closest(".bloc_section").attr("id").replace("blocLangContent_"+langId,"blocLangContent_"+$(langContentDiv).data("langId"));
                            try {
                                let element = $(langContentDiv).find("[id='"+sectionId+"']").find("[name='"+ele.attr("name")+"']");
                                element.val(value);
                                if(className.length>0) element.addClass(className);    
                            } catch (error) {
                                return;
                            }
                        });
                    });

                }else {
                    let langId = ele.closest(".langContent").data("langId");
                    langContentDivs.each(function(idx,langContentDiv){
                        let sectionId = ele.closest(".bloc_section").attr("id").replace("blocLangContent_"+langId,"blocLangContent_"+$(langContentDiv).data("langId"));
                        try {
                            let element = $(langContentDiv).find("[id='"+sectionId+"']").find("[name='"+ele.attr("name")+"']");
                            element.val(ele.val());
                        } catch (error) {
                            return;
                        }
                    });
                }
            });
        });

        showLoader();

        $(langContentDivs).find(".ckeditorField").ckeditor({
            filebrowserImageBrowseUrl : "imageBrowser.jsp?popup=1",
            extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
            colorButton_enableMore : true,
            colorButton_enableAutomatic : false,
            allowedContent: true,
            contentsCss: '<%=request.getContextPath()%>/css/bootstrap.min.css',
            colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
        }, onFieldCkeditorReady);

        $ch.loadingBlocData = false;

        return true;
    }

    function onSaveAndPlaceBloc() {
        $ch.saveAndPlace = true;
        $('#existingBlocsSearchForm').find('[name=addBlocPosition]').val('bottom');
        onSaveBloc(); // $('#addEditBlocForm').trigger('submit');
    }

    function onSaveBloc() {
        var mainLangTab = $('#blocLangNavTabs li:first a[data-toggle=tab]:first');
        if (!mainLangTab.hasClass('active')) {
            mainLangTab.tab('show');
        }
        var modal = $('#modalAddEditBloc');
        var blocErrorMsg = modal.find('.blocErrorMsg');
        blocErrorMsg.html("");
        var form = $('#addEditBlocForm');

        form.removeClass('was-validated');

        if (!form.get(0).checkValidity()) {
            form.addClass('was-validated');
            return false;
        }
        else if (!verifyAllLanguageTemplateDataForBloc()) {
            return false;
        }

        var template_code = form.data('template_code');

        if (!template_code) {
            alert('template code not found.');
            return false;
        }

        var rss_feed_ids = [];
        form.find('[name=rss_feed_id]').each(function(index, el) {
            var feedId = $(el).val().trim();
            if(feedId.length > 0 && rss_feed_ids.indexOf(feedId) < 0){
                rss_feed_ids.push(feedId);
            }
        });

        var blocTags = [];
        form.find('.blocTagsDiv input.tagValue').each(function (index, el) {
            var tagId = $(el).val().trim();
            if (tagId.length > 0 && blocTags.indexOf(tagId) < 0) {
                blocTags.push(tagId);
            }
        });

        var uniqueIds = [];
        $.each($('.langTemplateForm > div:first').find(".uniqueId"),function (index, el) {
            var uniqueId = $(el).val().trim();
            if (uniqueId.length > 0 && uniqueIds.indexOf(uniqueId) < 0) {
                uniqueIds.push(uniqueId);
            }
        });

        var childBlocs = [];
        var detailsJson = {};
        var langContentDivs = modal.find(".langContent");
        langContentDivs.each(function (index, langContent) {
            langContent = $(langContent);
            var langId = langContent.attr("data-lang-id");
            $.each(langContent.find(".bloc-id"),function(idx,el){
                var value = $(el).val().trim();
                if (value.length > 0) {
                    childBlocs.push({
                        "langue_id": langId, 
                        "bloc_id": value
                    });
                }
            });
            var template_data = generateTemplateData(langContent);
            detailsJson["" + langId] = {
                langue_id : langId,
                template_data : template_data
            };
        });
        
        form.find('[name=requestType]').val("saveBloc");
        form.find('[name=detailsJson]').val(JSON.stringify(detailsJson));
        form.find('[name=rss_feed_ids]').val(rss_feed_ids.join(","));
        form.find('[name=blocTags]').val(blocTags.join(","));
        form.find('[name=uniqueIds]').val(uniqueIds.join('$'));
        
        let inputChildBloc = form.find("input[name='childBlocs']");
        if(inputChildBloc.length == 0 ){
            inputChildBloc = $("<input>").attr("type","hidden").attr("name","childBlocs");
            form.append(inputChildBloc);
        }
        inputChildBloc.val(JSON.stringify(childBlocs));
        
        if(arrTrigger.length > 0)
            form.find('[name=triggerEvents]').val(encodeURIComponent(JSON.stringify(arrTrigger)));
        

        showLoader();
        $.ajax({
            url : 'blocsAjax.jsp', type : 'POST', dataType : 'json',
            data : form.serialize(),
        })
        .done(function (resp) {
            if (resp.status === 1) {
                if($ch.blocField && $($ch.blocField).length > 0) { 
                    $($ch.blocField).find(".bloc-name").val(form.find("#blocNameField").val());
                    $($ch.blocField).find(".bloc-id").val(resp.data.blocId);
                    $($ch.blocField).find("button.edit-bloc,button.remove-bloc").show();
                    $($ch.blocField).find("button.edit-bloc").data("bloc-id",resp.data.blocId);
                    $($ch.blocField).find("button.edit-bloc").data("template-id",form.find("input[name='template_id']").val());
                    $($ch.blocField).find("button.edit-bloc").data("template",form.find("input[name='template-name']").val());
                    $($ch.blocField).find("button.add-bloc").hide();                    
                    $ch.blocField = undefined;
                }               

                $('#modalAddEditBloc').modal('hide');
                bootNotify("Bloc saved.");
                
                if(window.blocsTable){
                   window.blocsTable.ajax.reload(null,false);
                }
                if($ch.saveAndPlace === true){
                    $ch.saveAndPlace = false;
                    addExistingBloc(resp.data.blocId);
                }
                else if(typeof refreshPagePreview != 'undefined'){
                    refreshPagePreview();
                }

                if($ch.isPageEditor === true){
                    $ch.pageChanged = true;
                }
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error in saving bloc. please try again.");
        })
        .always(function () {
            $ch.saveAndPlace = false;
            hideLoader();
        });

    }

    function verifyAllLanguageTemplateDataForBloc() {
        var isAllValid = true;

        var langContentDivs = $("#modalAddEditBloc .langContent");
        langContentDivs.each(function (index, langContent) {

            langContent = $(langContent);
            var langId = langContent.attr("data-lang-id");
            var langTab = $('#blocLangTab_' + langId);
            var langName = langTab.text();
            var form = langContent.parents('form.langTemplateForm:first');

            var errorFields = [];
            //custom check for special fields like ckeditor
            form.find('.requiredInput').trigger('checkRequired');

            if (!form.get(0).checkValidity()) {
                var invalidFields = form.find(':invalid');
                if (invalidFields.length > 0) {
                    var errorMsg = "Error: Some required fields are empty for language " + langName;
                    bootNotifyError(errorMsg);
                    errorFields = errorFields.concat(invalidFields.toArray());
                }
            }
            console.log("errorFields1============",errorFields);

            var invalidFields = langContent.find('.is-invalid');
            if (invalidFields.length > 0) {
                var errorMsg = "Error: " + invalidFields.length
                    + " field(s) have invalid values for language " + langName;
                bootNotifyError(errorMsg);
                errorFields = errorFields.concat(invalidFields.toArray());
            }
            console.log("errorFields2============",errorFields);

            if (errorFields.length > 0) {
                if (isAllValid) {
                    //switch to tab of first error
                    langTab.trigger('click');
                    focusOnErrorField(errorFields, langContent);
                }

                isAllValid = false;
            }

        });

        return isAllValid;
    }

    function addRssFeedField(feedId) {
        var blocRssFeedsRow = $('#blocRssFeedsRow');
        var rssFeedFieldsContainer = blocRssFeedsRow.find('.rssFeedFieldsContainer');
        var addRssBtn = blocRssFeedsRow.find('.addRssBtn');


        var rssFeedField = $($('#template_rss_feed').html());

        var existing = rssFeedFieldsContainer.find('.rssFeedField');
        if(existing.length > 0){
            rssFeedField.find('.fieldLabel').html('&nbsp;');
        }
        else{
            rssFeedField.find('.deleteBtn').remove();
        }

        if(typeof feedId !== 'undefined'){
            rssFeedField.find('[name=rss_feed_id]').val(feedId);
        }

        rssFeedFieldsContainer.append(rssFeedField);

    }

    function deleteRssFeedField(event, btn){
        event.stopPropagation();

        $(btn).parents('.rssFeedField:first').remove();
    }

    function validateNumberInput(input) {
        if (input.value > 12) {
            input.value = 12;
        }
    }

</script>