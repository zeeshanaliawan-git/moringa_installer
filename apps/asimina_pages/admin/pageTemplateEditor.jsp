<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList, java.util.List "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    String IMAGE_URL_PREPEND = getImageURLPrepend(getSiteId(session));
    String CATALOG_ROOT = GlobalParm.getParm("CATALOG_ROOT") + "/";

    String templateId = parseNull(request.getParameter("id"));

    String q;
    Set rs;

    q = "SELECT pt.id, pt.name, pt.custom_id, th.status as themeStatus FROM page_templates pt"
        + " LEFT JOIN themes th ON th.id  = pt.theme_id "
        + " WHERE pt.id = " + escape.cote(templateId)
        + " AND pt.site_id = " + escape.cote(getSiteId(session));
    rs = Etn.execute(q);

    if (!rs.next()) {
        response.sendRedirect("pageTemplates.jsp");
    }
    String themeStatus = rs.value("themeStatus");

    boolean saveAllowed = true;

    if(themeStatus.equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn)){
        saveAllowed = false;
    }

    String templateCustomId = rs.value("custom_id");

    boolean active=true;
    List<Language> langsList = getLangs(Etn,session);

%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Page Template: <%=rs.value("name")%></title>

        <!-- ace editor -->
        <script src="<%=request.getContextPath()%>/js/ace/ace.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/ext-language_tools.js" ></script>
        <!-- <script src="<%=request.getContextPath()%>/js/ace/ext-beautify.js" ></script> -->
        <!-- ace modes -->
        <script src="<%=request.getContextPath()%>/js/ace/mode-ftl.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/mode-html.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/mode-css.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/mode-javascript.js" ></script>
        <!-- ace theme -->
        <script src="<%=request.getContextPath()%>/js/ace/theme-github.js" ></script>


        <style type="text/css">
            .ace_editor {
                border: 1px solid lightgray;
                min-height: 500px;
                font-family: monospace;
                font-size: 14px;
                /*margin: auto;*/
                /*width: 80%;*/
            }

            .ace_editor.ace_autocomplete{
                min-height: 200px;
            }

            .selectValueList > li:first-child .deleteBtn{
                display: none;
            }

            .sortable li{
                margin : 5px 0px;
            }

            .sortable li.new{
                margin : 5px 2px;
            }

            .edit-bar{
                position: absolute;
                right: 5px;
                top: 0px;
                /*margin-top: 5px;*/
            }

            .region-heading{
                font-size: 20px;
                text-align: center;
            }


            .regionListItem[data-custom-id=content]{
                background-color: green !important;
            }

            .regionListItem[data-custom-id=content] .edit-bar{
                display: none !important;
            }

        </style>
    </head>
   <body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Developer", ""});
        breadcrumbs.add(new String[]{"Page templates", "pageTemplates.jsp"});
        breadcrumbs.add(new String[]{rs.value("name"), ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
                <!-- beginning of container -->
                <form id="mainForm" action="" onsubmit="return false;">
                    <input type="hidden" name="templateId" id="templateId" value="<%=templateId%>" >
                </form>

                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-start pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Edit
                        '<span class="pageTemplateName"><%=rs.value("name")%></span>'
                        (<span class="pageTemplateCustomId"><%=templateCustomId%></span>)
                    </h1>
                    <div class="btn-toolbar mb-2 mb-md-0 flex-wrap flex-md-nowrap">
                        <button class="btn btn-sm btn-success"
                                data-toggle="modal"
                                data-target="#modalAddEditRegion"
                                data-caller="add">
                            Add a Region
                        </button>
                        <div class="btn-group mx-2">
                            <button class="btn btn-primary" type="button" onclick="onClickGoBack('pageTemplates.jsp')">Back</button>
                                        <button class="btn btn-primary" <%if(!saveAllowed){%>disabled<%}%> type="button" onclick="onSave()">Save</button>
                        </div>

                        <button class="btn btn-primary mr-2 "
                                            type="button" onclick="openAddEditPageTemplateModal('<%=templateId%>', '<%=themeStatus%>')" >
                            <i data-feather="settings"></i></button>

                    </div>
                </div>
                <!-- row -->
                <nav class="nav nav-pills mb-4" id="mainTabs" role="tablist">
                    <a class="nav-item nav-link mr-2 active" id="regionsTab"
                       data-toggle="tab" href="#regionsContent" role="tab" aria-controls="regions"
                       aria-selected="true">
                        Regions</a>
                    <a class="nav-item nav-link mr-2" id="codeTab"
                       data-toggle="tab" href="#codeContent" role="tab" aria-controls="code"
                       aria-selected="true">
                        Code</a>
                </nav>

                <div class="tab-content p-3" id="mainTabContents">
                    <div id="regionsContent" class="pt-0 tab-pane show active" role="tabpanel" aria-labelledby="regionsTab">
                        <div class="row">
                            <div class="col-12 px-2">
                                <div class="pageRegion my-1" style="position:relative">
                                    <p class="region-heading">Page</p>
                                    <div class="edit-bar" >
                                        <button class="btn btn-sm btn-link border-0 p-0"
                                                onclick="openAddEditPageTemplateModal('<%=templateId%>','<%=themeStatus%>')" >
                                            <i data-feather="edit"></i>
                                        </button>
                                    </div>
                                </div>
                                <ul id="regionsList" class="sortable">
                                    <!-- dynamic content -->
                                </ul>
                            </div>
                        </div><!-- row-->
                    </div>

                    <div id="codeContent" class="pt-0 tab-pane" role="tabpanel" aria-labelledby="codeTab">
                        <div class="row px-3 mt-3 availableFieldsDiv">
                            <div class="col">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <button class="btn btn-secondary" disabled>Available fields</button>
                                    </div>
                                    <select class="custom-select " id="fieldSelect">
                                    </select>
                                    <div class="input-group-append">
                                        <button class="btn btn-success" id="copyBtn" onclick="copyField('#fieldSelect')"
                                            >Copy</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row px-3 availableFieldsDiv">
                            <div class="col">
                                <small>
                                    Freemarker reference links:
                                    <a target="_blank" href="https://freemarker.apache.org/docs/dgui_template_exp.html#exp_cheatsheet">Expressions cheatsheet</a> ,
                                    <a target="_blank" href="https://freemarker.apache.org/docs/ref_directive_alphaidx.html">#directives</a> ,
                                    <a target="_blank" href="https://freemarker.apache.org/docs/ref_builtins_alphaidx.html">?built_ins</a>
                                </small>
                            </div>
                        </div>
                        <div class="row px-3 availableFieldsDiv">
                            <div class="col">
                                <small>
                                    Tip: Use <code> ctrl + space</code> for field list autocomplete.

                                </small>
                            </div>
                            <div class="col text-right">
                                <small><a href="javascript:void(0)" onclick="showAceEditorSettings()">Show editor settings</a> (shortcut: <code> ctrl + ,</code>)

                                    Edtior theme :
                                    <a href="javascript:void(0)" onclick="setAceEditorTheme('light')">Light</a>&nbsp;/&nbsp;
                                    <a href="javascript:void(0)" onclick="setAceEditorTheme('dark')">Dark</a>
                                </small>
                            </div>
                        </div>

                        <div class="editor_div col">
                            <div id="code_editor"></div>
                        </div>
                        <textarea id="hiddenInput" name="ignore" value="" style="display:none;"></textarea>
                    </div>


                </div>
                <!-- /end of container -->
            </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
        </div>

        <div class="d-none">
            <!-- templates -->

            <li id="regionListItemTemplate" class="regionListItem bg-warning ">
                <div class="my-2" style="position:relative;">
                    <p class="region-heading name" style="">
                        Name
                    </p>
                    <div class="edit-bar" >
                        <button class="btn btn-sm btn-link border-0 p-0"
                                data-toggle="modal"
                                data-target="#modalAddEditRegion"
                                data-caller="edit">
                            <i data-feather="edit"></i>
                        </button>
                        <button class="deleteRegionBtn btn btn-sm btn-link border-0 p-0"
                                onclick="deleteRegion(this)">
                            <i data-feather="x-square"></i>
                        </button>
                    </div>
                </div>

            </li>

            <div id="regionBlocItemTemplate">
                <div class="col mb-2 p-0 regionBlocItem" >
                    <div class="btn-group w-100">
                        <div class="btn btn-secondary btn-lg btn-block text-left" >
                            #NAME#
                        </div>
                        <button type="button" class="btn btn-danger" onclick="deleteParent(this, '.regionBlocItem')">
                            <i data-feather="x"></i>
                        </button>
                    </div>
                </div>
            </div>

        </div> <!-- hidden div -->

        <!-- Modals -->
        <div class="modal fade" id="modalAddEditRegion" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
                <div class="modal-content">
                    <form id="formAddEditRegion" action="" novalidate >
                        <input type="hidden" name="region_id" value="">
                        <div class="modal-header">
                            <h5 class="modal-title"></h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div class="form-group row">
                                <label class="col-sm-4 col-form-label">Region Name</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" name="name" value=""
                                           maxlength="100" required="required" onchange="onNameChange(this)">
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-4 col-form-label">Region ID</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" name="custom_id" value=""
                                           maxlength="100" required="required"
                                           onkeyup="onKeyupCustomId(this)" onblur="onKeyupCustomId(this)">
                                    <div class="invalid-feedback ">
                                        Cannot be empty or duplicate.
                                    </div>
                                </div>
                            </div>
                            <div>
                                <ul class="nav nav-tabs regionDetailsTabs" role="tablist">
                                <%
                                    //TODO add copy to all button for lanuage copy from default to all
                                    active = true;
                                    for (Language lang:langsList) {
                                %>
                                    <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
                                      <a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
                                        data-toggle="tab" href="#regionDetails_<%=lang.getLanguageId()%>"
                                        role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%></a>
                                    </li>
                                <%
                                    active =false;
                                    }
                                %>
                                </ul>

                                <div class="tab-content p-3">
                                    <%
                                        active = true;
                                        for (Language lang:langsList) {
                                    %>
                                        <div class='tab-pane langTabContent regionLangDetailsDiv regionLangDetailsDiv_<%=lang.getLanguageId()%> <%=(active)?"show active":""%>'
                                                id="regionDetails_<%=lang.getLanguageId()%>"
                                                data-lang-id='<%=lang.getLanguageId()%>'
                                                role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                            <!-- lang specific fields  -->

                                            <div class="form-group row">
                                                <label class="col-sm-4 col-form-label">CSS classes</label>
                                                <div class="col-sm-8">
                                                    <input type="text" class="form-control css_classes"
                                                        name="css_classes_<%=lang.getLanguageId()%>" value=""
                                                        maxlength="500" >
                                                </div>
                                            </div>
                                            <div class="form-group row">
                                                <label class="col-sm-4 col-form-label">CSS style</label>
                                                <div class="col-sm-8">
                                                    <input type="text" class="form-control css_style"
                                                        name="css_style_<%=lang.getLanguageId()%>" value=""
                                                        maxlength="500" >
                                                </div>
                                            </div>

                                            <div class="form-group row">
                                                <label class="col-sm-4 col-form-label">Add a block</label>
                                                <div class="col-sm-8">
                                                    <div class="w-100">
                                                        <div class="input-group">
                                                            <select <%if(!active){%>disabled<%}%> class="custom-select bloc_search_term" name="ignore" id="searchBlocType">
                                                                <option value=""> -- bloc type -- </option>
                                                                <option value="system">System bloc</option>
                                                                <option value="bloc">Standard bloc</option>
                                                            </select>
                                                            <div class="position-relative">
                                                            <input <%if(!active){%>disabled<%}%> type="text" class="form-control bloc_search_term"
                                                                    placeholder="search and add" name="ignore"/>
                                                            </div>
                                                            <div class="input-group-append">
                                                                <button type="button" class="btn btn-secondary ">Add</button>
                                                            </div>

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
                                    <div class="form-group row">
                                        <div class="col-sm-4"></div>
                                        <div class="col-sm-8">
                                            <div class="w-100">
                                                <div class="w-100 pt-2">
                                                    <div id = "regionBlocsList">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                            </div>



                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                            <button type="button" class="btn btn-primary" onclick="onSaveRegion()" >Save</button>
                        </div>
                    </form>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <%@ include file="pageTemplatesAddEdit.jsp"%>

        <script type="text/javascript">
            window.IMAGE_URL_PREPEND = '<%=IMAGE_URL_PREPEND%>';
            window.CATALOG_ROOT = '<%=CATALOG_ROOT%>';

            // ready function
            $(function() {

                $ch.pageChanged = false;
                $ch.savedData = "";

                getData();
                $ch.REGION_BLOC_ITEM_TEMPLATE = $('#regionBlocItemTemplate').html();
                $ch.codeEditor = initAceEditor("code_editor", { mode: "ace/mode/ftl"});
                setAceEditorTheme("dark");
                $ch.codeEditor.setKeyboardHandler("ace/keyboard/sublime");


                Sortable.create(document.getElementById("regionsList"),{animation:20});
                Sortable.create(document.querySelector('#modalAddEditRegion #regionBlocsList'), {
                    draggable: 'div.regionBlocItem',
                    direction: 'vertical',
                    cursor: 'move',
                });

                Sortable.create(document.getElementById("regionBlocsList"),{animation:20});

                $('#mainTabs a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
                    //console.log(e);
                });

                // Section modal
                $('#modalAddEditRegion')
                .on('show.bs.modal', showModalAddEditRegion)
                .on('shown.bs.modal', function() {
                        $(this).find('input:visible').first().focus();
                    });

                $('#formAddEditRegion').on('change', 'input,select,textarea', function(event) {
                    $(this).removeClass('is-invalid');
                });

                $('#modalAddEditRegion').on('hidden.bs.modal', function (e) {
                    if(e.target.querySelector(".autocomplete-items")!=null)
                        e.target.querySelector(".autocomplete-items").outerHTML="";
                })

                $('input.bloc_search_term').each(function (index, input) {

                    var blocType = $(input).parent().parent().find('select.bloc_search_term:first');

                    input.addEventListener("blur",function(e){
                        var ul = e.target.parentElement.querySelector(".autocomplete-items");
                        if(ul!=null)
                            ul.outerHTML="";
                    });

                    input.addEventListener("input",function(e){
                        var ul = e.target.parentElement.querySelector(".autocomplete-items");
                        if(ul==null){
                            ul = document.createElement("ul");
                            ul.classList.add("autocomplete-items","position-absolute","bg-white","d-flex","flex-column","p-2","overflow-auto","w-100");
                            ul.style.listStyleType = "none";
                            ul.style.overflow = "auto";
                            ul.style.left = "0";
                            ul.style.gap = "7px";
                            ul.style.maxHeight = "280px";
                            ul.style.zIndex = "99999999";
                            e.target.parentNode.appendChild(ul);
                        }
                        var searchTerm = e.target.value;
                        
                        if(searchTerm.length > 1){
                            showLoader();
                            $.ajax({
                                url : 'blocsAjax.jsp',
                                dataType : 'json',
                                data : {
                                    requestType : "searchBlocsList",
                                    search : searchTerm,
                                    type : blocType.val(),
                                },
                            })
                            .done(function (resp) {
                                if (resp.status == '1') {
                                    ul.innerHTML="";
                                    var blocsData = resp.data.blocs.map(function (blocObj, idx) {
                                        blocObj.label = blocObj.name;
                                        return blocObj;
                                    });
                                    renderMenu(ul, blocsData);
                                }
                                else {
                                    ul.innerHTML="";
                                    bootNotifyError(resp.message);
                                    
                                }
                            })
                            .fail(function () {
                                ul.innerHTML="";
                                bootNotifyError("Error in accessing server.");
                                
                            })
                            .always(function () {
                                hideLoader();
                            });
                        }else
                            ul.outerHTML="";
                    });

                    
                });

            });

            function renderMenu(menuElement, items) {
                items.forEach(function (item) {
                    renderMenuItem(menuElement, item);
                });
            }

            function renderMenuItem(ul, item) {
                var li = document.createElement("li");
                li.classList.add("py-2","px-2");
                li.style.cursor="pointer";
                li.dataset.value=item.label;
                li.dataset.id=item.id;
                li.innerText=item.label;
                
                li.addEventListener("mousedown",function(e)
                {
                    var targetUl=e.target.closest("ul");
                    var inputTag = targetUl.parentElement.querySelector("input");
                    inputTag.value=e.target.dataset.value;
                    addBlocToRegion({id:e.target.dataset.id,name:e.target.dataset.value,type:$(inputTag).parent().parent().find('select.bloc_search_type:first').val()});
                    inputTag.value="";
                    targetUl.innerHTML="";
                });
                ul.appendChild(li);
            }


            function onClickGoBack(url) {
                checkPageChanged();
                goBack(url);
            }

            function checkPageChanged() {
                if ($ch.savedData != JSON.stringify(getDataForSave())) {
                    $ch.pageChanged = true;
                    // console.log("page changed");
                }
                else {
                    $ch.pageChanged = false;
                }
            }

            function openTemplateResources(id) {
                checkPageChanged();
                if ($ch.pageChanged) {
                    bootConfirm("Unsaved changes will be lost. Are you sure?",
                            function(result) {
                                if (result) {
                                    window.location.href = "templateResources.jsp?id=" + id;
                                }
                            });
                }
                else {
                    window.location.href = "templateResources.jsp?id=" + id;
                }

            }

            function onSave(isConfirm) {

                if (!isConfirm) {
                    bootConfirm("Are you sure?", function(result) {
                        if (result)
                            onSave(true);
                    });
                    return false;
                }

                var dataObj = getDataForSave();

                //console.log(dataObj); //debug
                showLoader();
                $.ajax({
                    url: 'pageTemplatesAjax.jsp',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        requestType: 'saveTemplateData',
                        id : $('#templateId').val(),
                        data: JSON.stringify(dataObj),
                    },
                })
                .done(function(resp) {
                    if (resp.status == 1) {
                        bootNotify("Template saved.");
                        $ch.savedData = JSON.stringify(dataObj);
                        $ch.pageChanged = false;
                    }
                    else {
                        bootAlert(resp.message);
                    }
                })
                .fail(function() {
                    bootNotifyError("Error in accessing server.");
                })
                .always(function() {
                    hideLoader();
                });

            }

            function getDataForSave() {
                var dataObj = {
                    templateId: $('#templateId').val(),
                    template_code : $ch.codeEditor.getSession().getValue(),
                    regions: getAllRegionsList(),
                };

                return dataObj;
            }

            function getAllRegionsList(){
                var regions = [];

                var regionsList = $('#regionsList > li.regionListItem');

                regionsList.each(function(index, regionItem) {

                    var regionJson = getRegionJson(regionItem);

                    regions.push(regionJson);

                });

                return regions;
            }

            function getRegionJson(regionItem) {
                regionItem = $(regionItem);

                var regionJson = {
                    id: regionItem.data('region_id'),
                    name: regionItem.data('name'),
                    custom_id: regionItem.data('custom_id'),
                    details : regionItem.data('region_details'),
                };

                return regionJson;
            }

            function addBlocToRegion(blocData){
                var regionBlocsList = $('#regionBlocsList');
                var blocHtml = strReplaceAll($ch.REGION_BLOC_ITEM_TEMPLATE, '#NAME#', blocData.name);
                blocHtml = $(blocHtml);
                blocHtml.attr({
                    'data-bloc-id' : blocData.id,
                    'data-bloc-name' : blocData.name,
                    'data-bloc-type' : blocData.type,
                });

                regionBlocsList.append(blocHtml);
            }

            function showModalAddEditRegion(event) {
                var button = $(event.relatedTarget);
                var modal = $(this);
                var form = $('#formAddEditRegion');
                form.get(0).reset();
                form.find('.is-invalid').removeClass('is-invalid');
                form.find('[name=region_id]').val('');
                var regionBlocsList = form.find('#regionBlocsList');
                regionBlocsList.html('');

                form.find('.regionDetailsTabs:first li:first-child a').tab('show');

                var caller = button.data('caller');

                if (caller == "edit") {
                    var regionItem = button.parents('li.regionListItem:first');

                    form.find('[name=region_id]').val(regionItem.data('region_id'));
                    form.find('[name=name]').val(regionItem.data('name'));
                    form.find('[name=custom_id]').val(regionItem.data('custom_id')).prop('readonly', true);

                    var regionDetails = regionItem.data('region_details');
                    if( Array.isArray(regionDetails) ){
                        var blocsData = [];
                        $.each(regionDetails, function(index, detailObj) {
                            var langId = detailObj.langue_id;
                            var detailsDiv = form.find('.regionLangDetailsDiv_'+langId);
                            if(detailsDiv.length > 0){
                                detailsDiv.find('input.css_classes').val(detailObj.css_classes);
                                detailsDiv.find('input.css_style').val(detailObj.css_style);
                            }
                            if(index == 0){
                                blocsData = detailObj.blocs;
                            }
                        });
                        $.each(blocsData, function(index, blocObj) {
                            addBlocToRegion(blocObj);
                        });
                    }

                    modal.find('.modal-title').text("Edit section : " + regionItem.data('name'));
                }
                else {
                    modal.find('.modal-title').text("Add a Region");
                    form.find('[name=custom_id]').prop('readonly', false);

                }

            }

            function onSaveRegion() {
                var form = $('#formAddEditRegion');

                var region_id = form.find('[name=region_id]').val();
                var name = form.find('[name=name]').val();
                var custom_id = form.find('[name=custom_id]').val();

                form.find('.is-invalid').removeClass('is-invalid');

                form.find('[required]').each(function(index, el) {
                    if ($(el).val().trim().length == 0) {
                        $(el).addClass('is-invalid');
                    }
                });

                if (form.find('.is-invalid').length === 0) {
                    //custom validations
                    if (isDuplicateCustomId(custom_id, $('#regionsList'), 'region_id', region_id)) {
                        form.find('[name=custom_id]').addClass('is-invalid');
                    }
                }

                if (form.find('.is-invalid').length !== 0) {
                    form.find('.is-invalid').first().focus();
                    return false;
                }

                var regionDetails = [];

                form.find(".regionLangDetailsDiv")
                .each(function(index, langDiv) {
                    langDiv = $(langDiv);
                    var langId = langDiv.attr('data-lang-id');

                    var detailObj = {
                        langue_id : langId,
                        css_classes : langDiv.find('input.css_classes:first').val(),
                        css_style : langDiv.find('input.css_style:first').val(),
                        blocs : []
                    };

                    regionDetails.push(detailObj);
                });
                // adding blocs for the first lang
                var blocs = []
                $('#regionBlocsList').find('.regionBlocItem')
                .each(function (index, el) {
                    el = $(el);
                    blocs.push({
                        id : el.attr('data-bloc-id'),
                        name : el.attr('data-bloc-name'),
                        type : el.attr('data-bloc-type'),
                    });
                });
				
				for(let _i=0; _i<regionDetails.length; _i++)
				{
					regionDetails[_i].blocs = blocs;
				}

                //all good

                insertUpdateRegion(region_id, name, custom_id, regionDetails);
                initAvailableFields();
                $('#modalAddEditRegion').modal('hide');

                checkPageChanged();

            }

            function insertUpdateRegion(region_id, name, custom_id, regionDetails) {

                var regionItem = $('#region_' + region_id);

                if (regionItem.length === 0) {
                    regionItem = $('#regionListItemTemplate').clone(true);

                    if (region_id.length == 0) {
                        region_id = 'new_' + getRandomInt(10000);
                    }

                    regionItem.attr('id', 'region_' + region_id);

                    regionItem.addClass('region_' + region_id);

                    $('#regionsList').append(regionItem);

                }

                regionItem.data('region_id', region_id);
                regionItem.data('name', name);
                regionItem.data('custom_id', custom_id);
                regionItem.data('region_details', regionDetails);


                regionItem.find('.name').text(name);
                regionItem.find('.custom_id').text(custom_id);

                regionItem.attr('data-custom-id', custom_id);

                return regionItem;
            }

            function onChangeNbItems(select) {
                select = $(select);
                nb_items = select.form().find('[name=nb_items]');

                if (select.val() == '0') {
                    nb_items.prop('readonly', false).val(0).prop('readonly', true);
                }
                else {
                    nb_items.prop('readonly', false).val(1);
                }
            }

            function isDuplicateCustomId(customId, list, dataKey, dataValue) {
                var isDuplicate = false;

                var items = $(list).find('> li');

                items.each(function(index, li) {
                    li = $(li);
                    if (li.data('custom_id') == customId
                            && li.data(dataKey) != dataValue) {

                        isDuplicate = true;
                    }
                });

                return isDuplicate;
            }

            function deleteRegion(btn) {
                btn = $(btn);

                bootConfirm("Are you sure?", function(result) {
                    if (result) {
                        btn.parents('li.regionListItem:first').remove();
                        initAvailableFields();
                    }
                });
            }

            function getData() {

                showLoader();
                $.ajax({
                    url: 'pageTemplatesAjax.jsp',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        requestType: 'getTemplateData',
                        templateId: $('#templateId').val(),
                    },
                })
                .done(function(resp) {
                    if (resp.status == 1) {
                        initData(resp.data);

                        $ch.savedData = JSON.stringify(getDataForSave());
                        $ch.pageChanged = false;
                    }
                    else {
                        bootAlert(resp.message);
                    }
                })
                .fail(function() {
                    bootNotifyError("Error in accessing server.");
                })
                .always(function() {
                    hideLoader();
                });

            }

            function initData(data) {
                showLoader();

                $ch.codeEditor.getSession().setValue(data.template_code);
                $(data.items).each(function(index, region) {
                    insertUpdateRegion(region.id, region.name,
                        region.custom_id, region.details);
                });
                initAvailableFields();
                hideLoader();
            }


            function onNameChange(name) {
                name = $(name);
                var form = name.parents('form:first');
                customId = form.find('[name=custom_id]');

                if (name.val().trim().length > 0 && customId.length > 0
                        && customId.prop('readonly') == false) {
                    customId.val(name.val().trim()).trigger('keyup');
                }
            }

            function initAvailableFields(){
                var fieldsList = [];

                var regionsList = getAllRegionsList();

                fieldsList.push("Content : \${content}");

                regionsList.forEach( (region) => {

                    if( region.custom_id === 'content') return;

                    fieldsList.push(region.name + " > css classes : \${"+region.custom_id +".css_classes}");
                    fieldsList.push(region.name + " > css style : \${"+region.custom_id +".css_style}");
                    var blocListEntry = region.name + " > blocs : <#list "
                        + region.custom_id +".blocs  as cur_bloc > \${cur_bloc} </#list>";
                    fieldsList.push(blocListEntry);
                });

                fieldsList.push("Page Info > language code : \${page.lang}");
                fieldsList.push("Page Info > path : \${page.path}")
                fieldsList.push("Page Info > path : \${page.uuid}");
                //page Meta parameters
                fieldsList.push("Page Info > Meta > Title : \${page.meta.title}");
                fieldsList.push("Page Info > Meta > Type : \${page.meta.type}");
                fieldsList.push("Page Info > Meta > Locale : \${page.meta.locale}");
                fieldsList.push("Page Info > Meta > Keywords : \${page.meta.keywords}");
                fieldsList.push("Page Info > Meta > Description : \${page.meta.description}");
                fieldsList.push("Page Info > Meta > Image : \${page.meta.image}");
                fieldsList.push("Page Info > Meta > Image width : \${page.meta.image_width}");
                fieldsList.push("Page Info > Meta > Image height : \${page.meta.image_height}");
                fieldsList.push("Page Info > Meta > Image type : \${page.meta.image_type}");
                fieldsList.push("Page Info > Meta > Twitter card : \${page.meta.twitter_card}");

                fieldsList.push("Site Param > Homepage URL : \${site_param.homepage_url}");
                fieldsList.push("Site Param > Page 404 URL : \${site_param.page_404_url}");
                fieldsList.push("Site Param > Prod path : \${site_param.production_path}");
                fieldsList.push("\${translateFunc()}");

                fieldsList.push("Data JSON object : JSON.parse('\${data_json!?js_string}')");

                var fieldSelect = $('#fieldSelect');
                fieldSelect.html('');
                for (var i = 0; i < fieldsList.length; i++) {
                    fieldSelect.append( $('<option>').attr('value',fieldsList[i])
                                                        .text(fieldsList[i]) );
                }

                initEditorAutocompleteList(true);

            }

            function initEditorAutocompleteList(isReset){

                var fieldSelect = $('#fieldSelect');
                if(isReset){
                    $ch.templateFieldsList = [];
                }
                fieldSelect.find('option').each(function(index, el) {
                    var fieldVal = $(el).attr('value');

                    var label = fieldVal.substring(0,fieldVal.indexOf(" : "));
                    var value = fieldVal.substring(fieldVal.indexOf(" : ") + 3);
                    if(value.indexOf(">") > 0){
                        value = strReplaceAll(value,"> ",">\n");
                        value = strReplaceAll(value,"} ","}\n");
                    }

                    $ch.templateFieldsList.push({
                        name: label,
                        value: value,
                        score: 1,
                        meta: "freemarker"

                    });

                });
            }

            function copyField(fieldSelector) {
                var input = $('#hiddenInput');

                if (typeof fieldSelector === 'undefined') {
                    fieldSelector = '#fieldSelect';
                }

                var fieldVal = $(fieldSelector).val();

                if (fieldVal.trim().length > 0) {
                    var val = fieldVal;
                    if (val.indexOf(" : ") >= 0) {
                        val = fieldVal.substring(fieldVal.indexOf(" : ") + 3);
                    }

                    if (val.indexOf(">") > 0) {
                        val = strReplaceAll(val, "> ", ">\n");
                        val = strReplaceAll(val, "} ", "}\n");
                    }
                    input.val(val);
                    input.show();
                    input.select();
                    document.execCommand("copy");
                    //navigator.clipboard.writeText(input.val());
                    input.hide();

                    $('#copyBtn').popover('show');
                }
            }

        </script>
    </body>
</html>