<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%

    String pageId = parseNull(request.getParameter("id"));

    String q = null;
    Set rs = null;

    q = "SELECT id, name, layout, layout_data FROM pages "
        + " WHERE id = " + escape.cote(pageId)
        + " AND site_id = " + escape.cote(getSiteId(session))
        + " AND type = 'react'";
    rs = Etn.execute(q);

    if(!rs.next() || !"css-grid".equals(rs.value("layout")) ){
        response.sendRedirect("dynamicPages.jsp");
    }

    String pageLayout = parseNull(rs.value("layout"));
    String pageLayoutData = parseNull(rs.value("layout_data"));
    pageLayoutData = decodeJSONStringDB(pageLayoutData);
    Logger.info(pageLayoutData);

    try{
       JSONObject pageLayoutDataJson = new JSONObject(pageLayoutData);
    }
    catch(Exception ex){
        //if invalid layout data json, set empty
        Logger.debug("Invalid layout data json for css-grid page : " + pageLayoutData);
        pageLayoutData = "{}";
    }

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>

    <script src="<%=request.getContextPath()%>/js/uuidv4.min.js"></script>

    <title>Page : <%=rs.value("name")%></title>

    <style type="text/css">

        #pagePreviewIframe{
            width: 100%;
            height: 100%;
            border: none;
        }

        #gridContainer .grid {
            background-color: lightgray;
            height: 100%;
            width: 100%;
        }

        .grid > .grid {
            position: relative;
            border: 1px solid lightskyblue;
        }

        .grid > .gridItem {
            background-color: lightblue;
            z-index: 100;
            position: relative;
            border: 1px solid #0099cc;
            border-radius: 2px;
        }

        .grid > .gridItemPlaceholder {
            background-color: white;
            z-index: 50;
            border: dashed 1px grey;
            border-radius: 2px;
            padding-left: 5px;
            cursor: pointer;
        }

        .gridItem > .gridEditBar {
            position: absolute;
            top: 5px;
            right: 5px;
            z-index: 100;
            width: max-content;
        }

        .grid.gridItem > .gridEditBar {
            position: absolute;
            top: 5px;
            left: 5px;
            z-index: 101;
        }

        .gridItem.edit > .gridEditBar {
            z-index: 110;
        }

        .grid > .gridEditBar  .gridIcon {
            display: inline-block !important;
        }

        .grid > .gridEditBar > .convertToGridBtn , .grid > .gridEditBar > .editComponentBtn  {
            display: none;
        }

        .grid > .gridEditBar > .convertToItemBtn {
            display: inline-block !important;
        }

        .grid > .gridEditBar > .deleteGridItemBtn {
            display: none;
        }

    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Dynamic", ""});
        breadcrumbs.add(new String[]{"Dynamic pages", "dynamicPages.jsp"});
        breadcrumbs.add(new String[]{rs.value("name"),"" });

    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <form action="" onsubmit="return false">
                <input type="hidden" name="pageId" id="pageId" value='<%=pageId%>'>
            </form>

            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2 ">Page : <span id="pageNameHeading" ><%=rs.value("name")%></span>
                    <span style="height: 25px; width: 25px; border-radius: 50%; border: 1px solid rgb(221, 221, 221); display: inline-block; vertical-align: middle; margin-left: 15px; user-select: auto;" class="bg-success"></span>
                </h1>
                <div class="btn-toolbar mb-2 mb-md-0">


                    <div class="btn-group mr-2 mb-1">
                        <button class="btn btn-danger" type="button"
                        onclick="onPublishUnpublish('publish')">Publish</button>
                        <button class="btn btn-danger" type="button"
                        onclick="onPublishUnpublish('unpublish')">Unpublish</button>
                    </div>
                    <div class="btn-group mr-2 mb-1"  id="previewBtn" >
                        <button type="button" class="btn btn-warning"  onclick='onPageEditorPreview()'>Preview</button>
                    </div>

                    <button class="btn btn-success mr-1 mb-1" type="button"
                        onclick="openAddEditComponentModal()">Add a component</button>

                    <div class="btn-group mr-1 mb-1">
                        <button class="btn btn-primary" type="button"
                            onclick="goBack('dynamicPages.jsp',true)">Back</button>
                        <button class="btn btn-primary" type="button"
                            onclick="onPageEditorSave()" >save</button>
                    </div>
                    <button class="btn btn-sm btn-primary mb-1"
                        data-toggle="modal" data-target="#modalAddEditPage"
                        data-caller="edit" data-page-id='<%=pageId%>'>
                        <i data-feather="settings"></i></button>
                </div>
            </div>
            <!-- row -->
            <div class="row">
                <div class="col-12 m-0 py-0 pr-0" style="padding-left:5px;">
                    <div id="gridContainer" class="" style="width: 100%; min-height: 99vh; height: 100%;">
                    </div>
                </div>
            </div>

            <div class="row d-none">
                <div id="blocEditDiv" >
                    <div class="bloc_edit_buttons" style="">
                        <span class="p-3 " style="font-weight: bold;">
                            Bloc : <span class="blocName"></span>
                        </span>
                        <span class="mr-2" style="cursor:pointer;"
                            onclick="window.parent.pageBlocEdit(this)" >
                            <i data-feather="edit"></i></span>
                        <span class="mr-2" style="cursor:pointer;"
                            onclick="window.parent.pageBlocDelete(this)" >
                            <i data-feather="x-square"></i></span>
                    </div>

                </div>

            </div><!-- hidden row-->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>
    <!-- Modals -->
    <!-- Modal -->
    <div class="modal fade" id="modalEditGrid" tabindex=""  data-backdrop="" role="dialog" style="pointer-events: none;">
        <div class="modal-dialog modal-sm " id="draggable-modal" role="document" style="margin: 0 !important;">
            <div class="modal-content">
                <div class="modal-header py-1 px-2" style="cursor: move;">
                    <span class="modal-title">Grid Properties</span>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body p-2">
                    <form class="" onsubmit="return false;">
                        <div class="container-fluid">
                            <div class="row">
                                <div class="col-3 px-2 m-auto">Selected</div>
                                <div class="col">
                                    <input class="form-control form-control-sm" type="text" name="curSelectedName" readonly="">
                                </div>
                            </div>
                            <div class="row">
                                <div class="col p-0">
                                    <span style="transform: rotate(90deg); display: inline-block;">≑</span>Grid Columns
                                </div>
                            </div>
                            <div class="row">
                                <div class="col py-0 px-1 ">
                                    <div class="pb-1">
                                        <button type="button" class="btn btn-primary btn-sm w-100"
                                            onclick="grid.addGridColRow('col',true)">Add</button>
                                    </div>
                                    <div class="gridColumnsList"></div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col p-0">
                                    <span>≑</span>Grid Rows
                                </div>
                            </div>
                            <div class="row">
                                <div class="col py-0 px-1 ">
                                    <div class="pb-1">
                                        <button type="button" class="btn btn-primary btn-sm w-100"
                                            onclick="grid.addGridColRow('row',true)">Add</button>
                                    </div>
                                    <div class="gridRowsList"></div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col p-0">
                                    <span>⊞</span>Grid Gap
                                </div>
                            </div>
                            <div class="row">
                                <div class="col py-0 px-1">
                                    <div class="form-group row mb-1">
                                        <label class="col-3">Columns</label>
                                        <div class="input-group input-group-sm col">
                                            <!-- <div class="input-group-prepend"></div> -->
                                            <input class="form-control" type="number" min="0" step="0.5"
                                                name="gridGapColumnSize"
                                                oninput="grid.onInputGridSize(this, 'columnGap')">
                                            <select class="form-control custom-select" name="gridGapColumnSizeUnit"
                                                onchange="grid.onChangeGridSizeUnit('columnGap')">
                                                <option value="px">px</option>
                                                <option value="%">%</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group row mb-1">
                                        <label class="col-3">Rows</label>
                                        <div class="input-group input-group-sm col">
                                            <!-- <div class="input-group-prepend"></div> -->
                                            <input class="form-control" type="number" min="0" step="0.5"
                                                name="gridGapRowSize" oninput="grid.onInputGridSize(this, 'rowGap')">
                                            <select class="form-control custom-select" name="gridGapRowSizeUnit"
                                                onchange="grid.onChangeGridSizeUnit('rowGap')">
                                                <option value="px">px</option>
                                                <option value="%">%</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- contiainer -->
                    </form>
                </div>
                <!-- <div class="modal-footer d-none">
                    <button type="button" class="btn btn-primary|secondary|success|danger|warning|info|light|dark" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary|secondary|success|danger|warning|info|light|dark">Save changes</button>
                </div> -->
            </div>
        </div>
    </div><!-- /.modal -->
    <!-- Modal -->
    <div class="modal fade" id="modalEditGridItem" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="">Assign component</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form id="formEditGridItem" action="" novalidate onsubmit="return false;">
                        <input type="hidden" name="itemId" value="">
                        <div class="container-fluid">
                            <div class="form-group row">
                                <label class="col col-form-label">CSS classes</label>
                                <div class="col-8">
                                    <input type="text" name="cssClasses" class="form-control" >
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col col-form-label">CSS style</label>
                                <div class="col-8">
                                    <textarea name="cssStyle" class="form-control" oninput="onJsonInput(this)" ></textarea>
                                    <div class="invalid-feedback">Invalid JSON object</div>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label class="col col-form-label">Component</label>
                                <div class="col-8">
                                    <select name="compId" class="custom-select">
                                        <option value="">--</option>
                                    </select>
                                </div>
                            </div>
                            <div class="compPropertiesDiv" class="w-100">

                            </div>

                            <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-1"
                                    data-toggle="collapse" href="#itemUrlsCollapse" role="button" >
                                URLs
                            </button>
                            <div class="collapse show py-3" id="itemUrlsCollapse">
                                <div class="clearContent itemUrlsDiv" >

                                </div>
                                <div class="text-right">
                                    <button type="button" class="btn btn-success" onclick="addItemUrl()" >Add a URL</button>
                                </div>
                            </div>

                            <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-1"
                                    data-toggle="collapse" href="#itemCompUrlsCollapse" role="button" >
                                Component URLs
                            </button>
                            <div class="collapse show py-3" id="itemCompUrlsCollapse">
                                <div class="clearContent compUrlsDiv" >

                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="onSaveEditGridItem()" >Save changes</button>
                </div>
                <div class="d-none">
                    <div id="compPropFieldTemplate">
                        <div class="form-group row">
                            <label class="col col-form-label fieldLabel"></label>
                            <div class="col-8 fieldInputDiv">
                            </div>
                        </div>
                    </div>
                    <div id="compPropImageFieldTemplate">
                        <div class="card image_card">
                            <div class="card-body text-center image_body">

                                <img class="card-image-top" style="max-width:100px;max-height:100px" >
                            </div>
                            <div class="card-footer image_footer">
                                <div class="form-group row ">
                                    <div class="col-12">
                                        <input type="text" name="#PROP_FIELD_NAME#"
                                    value="" class="image_value form-control" onchange="onFieldImageChange(this)">
                                        <div class="invalid-feedback">Cannot be empty.</div>
                                    </div>
                                </div>
                                <div class="form-group row mb-0">
                                    <div class="col-6">
                                        <button type="button" class="btn btn-link"
                                            onclick="loadFieldImage(this)">Load Image</button>
                                    </div>
                                    <div class="col-6">
                                        <button type="button" class="btn btn-link text-danger"
                                            onclick="clearFieldImage(this)">Delete Image</button>
                                    </div>
                                </div>
                                <div class="col-12 d-none">
                                    <input type="text" name="dummyimagealt" value=""
                                        class="image_alt form-control" placeholder="alt text" maxlength="50">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="itemUrlTemplate">
                        <div class="form-group row compUrlDiv">
                            <div class="col input-group">
                                <input type="text" class="form-control"
                                    name="comp_url" placeholder="URL" required="required" />
                                <div class="input-group-append">
                                    <input type="button" class="btn btn-danger rounded-right" value="x"
                                        onclick="deleteParent(this,'.compUrlDiv')">
                                </div>
                                <div class="invalid-feedback">Cannot be empty</div>
                            </div>
                        </div>
                    </div>
                    <div id="itemCompUrlTemplate">
                        <div class="form-group row compUrlDiv">
                            <div class="col input-group">
                                <input type="text" class="form-control"
                                    name="item_comp_url" placeholder="URL" readonly="" />
                            </div>
                        </div>
                    </div>
                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->
    <%@ include file="dynamicPagesAddEdit.jsp"%>
    <%@ include file="pagesPublish.jsp"%>
    <%@ include file="componentsAddEdit.jsp"%>

    <div class="d-none">
        <button type="button" id="dummyEditBlocBtn"
                class="btn btn-sm btn-primary "
                data-caller="edit" data-bloc-id='' data-template='dummy'
                onclick="openAddEditBloc(this);">
                <i data-feather="edit"></i></button>

        <!-- templates -->
        <div id="template_grid_input" class="input-group input-group-sm mb-1 gridInputDiv">
            <input class="form-control" type="number" min="0" step="0.5" name="size"
                oninput="grid.onInputGridSize(this)">
            <select class="form-control custom-select" name="sizeUnit" onchange="grid.onChangeGridSizeUnit(this)">
                <option value="fr">fr</option>
                <option value="px">px</option>
                <option value="%">%</option>
                <option value="em">em</option>
                <option value="auto">auto</option>
                <option value="min-content">min-content</option>
                <option value="max-content">max-content</option>
                <option value="minmax">minmax</option>
            </select>
            <div class="input-group-append">
                <button type="button" class="btn btn-danger" onclick="grid.deleteGridColRow(this)">x</button>
            </div>
        </div>

        <div id="template_grid_edit_bar">
            <div class="gridEditBar">
                <span class="mr-1">
                    <span class="gridIcon" style="display: none;">⊞ <i class="cil-grid"></i> </span>
                    <span class="itemName"></span>
                    <input type="text" class="itemNameInput form-control form-control-sm" value=""
                        style="width:auto; display: none;" onclick="event.stopPropagation();"
                        oninput="grid.onInputItemName(this)">
                </span>
                <button class="showOnEdit saveItemBtn btn btn-sm btn-primary mr-1 py-0 px-1" type="button"
                    onclick="grid.saveGridItem(this);" style="display: none;"
                    title="Save" data-toggle="tooltip" >
                    <i data-feather="save"></i>
                </button>
                <button class="hideOnEdit editItemBtn btn btn-sm btn-primary mr-1 py-0 px-1" type="button"
                    onclick="grid.editGridItem(this);"
                    title="Edit" data-toggle="tooltip" >
                    <i data-feather="edit"></i>
                </button>
                <button class="editComponentBtn btn btn-sm btn-primary mr-1 py-0 px-1" type="button"
                    onclick="grid.editItemComponent(this);"
                    title="Edit component" data-toggle="tooltip" >
                    <i data-feather="settings"></i>
                </button>
                <button class="convertToGridBtn btn btn-sm btn-primary mr-1 py-0 px-1" type="button"
                    onclick="grid.convertToGrid(this);"
                    title="Convert to grid" data-toggle="tooltip" >
                    <i data-feather="grid"></i>
                </button>
                <button class="deleteGridItemBtn btn btn-sm btn-danger mr-1 py-0 px-1" type="button"
                    onclick="grid.deleteGridItem(this);"
                    title="Delete" data-toggle="tooltip" >
                    <i data-feather="trash"></i>
                </button>
                <button class="convertToItemBtn btn btn-sm btn-danger mr-1 py-0 px-1" type="button"
                    onclick="grid.convertToItem(this);" style="display: none;"
                    title="Convert to item"  data-toggle="tooltip" >
                    <i data-feather="x"></i>
                </button>

            </div>
        </div>
    </div>

<script type="text/javascript">

    $ch.isPageEditor = true;
    $ch.pageLayout = "<%=pageLayout%>";

    window.IMAGE_URL_PREPEND = '<%=getImageURLPrepend(getSiteId(session))%>';
    // ready function
    $(document).ready(function() {

        initPageLayoutData();
        $('.onPageEditor').show();
    });

    function initPageLayoutData(){
        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : "getLayoutData",
                id : $('#pageId').val(),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                grid.init(resp.data.layout_data, editGridItem);
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in accessing server.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function onPageEditorSave(confirmed){
        if(!confirmed){

        bootConfirm("Are you sure?",function(result){
                if(result){
                    onPageEditorSave(true);
                }
            });
            return false;
        }

        var layoutDataObj = grid.getGridData();

        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : "savePageLayout",
                pageId : $('#pageId').val(),
                layoutData : JSON.stringify(layoutDataObj),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                bootNotify("Page layout saved.");
                $ch.pageChanged = false;
            }
            else{
                alert(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in accessing server.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function onPageSaveSuccess(resp, form){
        $('#pageNameHeading').text(form.find('[name=name]').val());
        refreshPagePreview();
    }


    function refreshPagePreview(){
        var url = "grid-designer/index.jsp?id="+$('#pageId').val();
        url += '&rand='+getRandomInt(1000000);
        // $ch.pagePreviewFrame.get(0).src = url;
    }

    function onPageEditorPreview(){
        getPagePreview($('#pageId').val());
    }
    //overriding function from pagesAddEdit.jsp
    function onPublishUnpublish(action,isLogin){
        if(typeof isLogin == 'undefined' || !isLogin){
            checkPublishLogin(action);
        }
        else{
            var msg = "Are you sure you want to "+action+" this page?";

            showPublishPagesModal(msg, action, function(publishTime){
                var pages = [];
                pages.push({id:$('#pageId').val(), type:"react"});
                publishUnpublishPages(pages, action, publishTime);
            });
        }
    }

    function editGridItem(itemData){
        if(typeof itemData == "undefined" ||
            (typeof itemData.i == "undefined" && itemData.id == "udefined")
        ){
            return false;
        }

        var modal = $('#modalEditGridItem');

        showLoader();
        $.ajax({
            url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : "getList"
            },
        })
        .done(function(resp) {
            if(resp.status == 1){

                $ch.compList = resp.data.components;
                $ch.compDataMap = {};

                var compSelect = modal.find("select[name=compId]");
                compSelect.html("<option value=''>--</option>");

                $($ch.compList).each(function(index, curComp) {
                    $ch.compDataMap[curComp.id] = curComp;
                    compSelect.append("<option value='"+curComp.id+"'>"+curComp.name+"</option>")
                });

                openEditGridItemModal(itemData);
            }
            else{
                bootNotifyError("Error in loading components list");
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

    function openEditGridItemModal(item){

        var modal = $('#modalEditGridItem');
        var form = $('#formEditGridItem');
        form.removeClass('was-validated');

        var compPropertiesDiv = modal.find(".compPropertiesDiv");
        var itemUrlsDiv = modal.find(".itemUrlsDiv");
        var compUrlsDiv = modal.find(".compUrlsDiv");


        itemUrlsDiv.html("");

        var itemId = item.i || item.id;
        var compId = item.compId;
        var propValues = item.propValues || item.compPropValues;
        var cssClasses = item.cssClasses;
        var cssStyle = item.cssStyle;
        var urlList = item.urlList;

        form.find("[name=itemId]").val(itemId);
        form.find("[name=cssClasses]").val(cssClasses);
        form.find("[name=cssStyle]").val(cssStyle);

        $.each(urlList, function(index, url) {
            addItemUrl(url);
        });

        var compSelect = form.find("select[name=compId]");
        compSelect.val(compId);
        compSelect.change(function(event) {
            var curCompId = $(this).val();

            compPropertiesDiv.html("");
            compUrlsDiv.html("");

            if(curCompId.length == 0){
                return true;
            }
            var compData = $ch.compDataMap[curCompId];
            if(typeof compData != "undefined"
                && typeof compData.properties  != "undefined"  && Array.isArray(compData.properties) ){

                var compProps = compData.properties;
                $.each(compProps, function(index, curProp) {
                    compPropertiesDiv.append(getCompPropertyField(curProp, propValues));
                });

                var compUrls = compData.urls;
                $.each(compUrls, function(index, compUrl) {
                    addItemCompUrl(compUrl);
                });

            }

        }).trigger('change');

        modal.modal("show");
    }

    function getCompPropertyField(curProp, propValues){
        var formField = $($("#compPropFieldTemplate").html());

        var formLabelDiv = formField.find(".fieldLabel");
        var formInputDiv = formField.find(".fieldInputDiv");

        formLabelDiv.text(curProp.name);
        var propType = curProp.type;

        var propValue = "";
        if(typeof propValues[curProp.id] !== "undefined"){
            propValue = propValues[curProp.id];
        }

        if(propType == "string"){

            var input = $("<input type='text' class='form-control propField'>");
            input.attr("name","prop_id_"+curProp.id)
                .attr("data-id",curProp.id)
                .val(propValue);
            formInputDiv.append(input);
            if(curProp.is_required == "1"){
                input.attr("required","required");
                formInputDiv.append("<div class='invalid-feedback'>Cannot be empty.</div>")
            }
        }
        else if(propType == "number"){

            var input = $("<input type='text' class='form-control propField' oninput='allowFloatOnly(this)' >");
            input.attr("name","prop_id_"+curProp.id)
                .attr("data-id",curProp.id)
                .val(propValue);
            formInputDiv.append(input);
            if(curProp.is_required == "1"){
                input.attr("required","required");
                formInputDiv.append("<div class='invalid-feedback'>Cannot be empty.</div>")
            }
        }
        else if(propType == "boolean"){

            var input = $("<input type='checkbox' class='form-check-input propField' >");
            input.attr("name","prop_id_"+curProp.id)
                .attr("data-id",curProp.id);

            if(propValue == "true"){
                input.prop("checked",true);
            }

            var checkDiv = $("<div class='form-check'>");
            checkDiv.append(input);
            checkDiv.append($("<label class='form-check-label' >").text(curProp.name));

            formInputDiv.append(checkDiv);
            formLabelDiv.html("");
        }
        else if(propType == "json"){

            var input = $("<textarea class='form-control propField' oninput='onJsonInput(this)' >");
            input.attr("name","prop_id_"+curProp.id)
                .attr("data-id",curProp.id)
                .val(propValue);
            formInputDiv.append(input);
            var invalidMsg = "Invalid JSON object";
            if(curProp.is_required == "1"){
                input.attr("required","required");
                invalidMsg = "Required JSON object";
            }
            formInputDiv.append("<div class='invalid-feedback'>"+invalidMsg+"</div>")
        }
        else if(propType == "image"){
            var fieldTemplate = $("#compPropImageFieldTemplate").html();
            // fieldTemplate = strReplaceAll(fieldTemplate,"#PROP_FIELD_NAME", "prop_id_"+curProp.id);
            formInputDiv.append(fieldTemplate);
            input = formInputDiv.find("input.image_value");
            input.attr("name","prop_id_"+curProp.id)
                .attr("data-id",curProp.id)
                .val(propValue)
                .trigger("change");

            if(curProp.is_required == "1"){
                input.attr("required","required");
            }
        }


        return formField;
    }

    function onJsonInput(input){
        var val = $(input).val().trim();
        var required = $(input).prop("required");
        var isValid = false;

        try {
            if(!required && val.length == ""){
                isValid = true;
            }
            else {
                JSON.parse(val);
                isValid = true;
            }
        } catch (error) {
            isValid = false;
        }

        if (!isValid) {
            input.setCustomValidity("Invalid JSON.");
        } else {
            input.setCustomValidity("");
        }
    }

    function onSaveEditGridItem(){
        var modal = $('#modalEditGridItem');
        var form = $('#formEditGridItem');

        if (form.get(0).checkValidity() === false) {
            form.addClass("was-validated");
            var invalidFields = form.find(':invalid');
            if(invalidFields.length > 0){
                $(invalidFields.get(0)).focus();
            }
            return false;
        }

        var compIdSelect = form.find('[name=compId]');
        var compId = compIdSelect.val();

        var urlList = [];
        var itemUrlsDiv = modal.find(".itemUrlsDiv");
        itemUrlsDiv.find("[name=comp_url]").each(function(index, input) {
            var url =  $(input).val().trim();
            if(url.length > 0){
                urlList.push(url);
            }
        });

        var itemData = {
            itemId : form.find('[name=itemId]').val(),
            cssClasses : form.find('[name=cssClasses]').val(),
            cssStyle : form.find('[name=cssStyle]').val(),
            compId : compId,
            compName : "",
            propValues : {},
            urlList : urlList
        };

        if(compId.length > 0){
            var compName = compIdSelect.find("option:selected").text();
            itemData.compName = compName;

            var compData = $ch.compDataMap[compId];
            if(typeof compData != "undefined"
                && typeof compData.properties  != "undefined" && Array.isArray(compData.properties) ){

                var compProps = compData.properties;
                $.each(compProps, function(index, curProp) {
                    var propId = curProp.id;
                    var propValue = "";
                    var field = form.find("[name=prop_id_"+propId+"]");
                    if(field.length == 1){
                        if(curProp.type == "boolean"){
                            propValue = "false";
                            if(field.prop("checked")){
                                propValue = "true";
                            }
                        }
                        else{
                            propValue = field.val().trim();
                        }
                    }

                    itemData.propValues[propId] = propValue;

                });
            }
        }
        //console.log(itemData);//debug
        if(grid && grid.saveItemComponent){
            grid.saveItemComponent(itemData);
        }
        else{
            var saveGridItem = $ch.pagePreviewFrame.get(0).contentWindow.saveGridItem;
            if(saveGridItem){
                saveGridItem(itemData);
            }
        }

        modal.modal('hide');
    }

    function addItemUrl(url){
        var modal = $('#modalEditGridItem');
        var itemUrlsDiv = modal.find(".itemUrlsDiv");

        var container = itemUrlsDiv;
        var template = $('#itemUrlTemplate');

        var templateHtml = template.html();

        var newUrl = $(templateHtml);

        if(url){
            newUrl.find('[name=comp_url]').val(url);
        }

        container.append(newUrl);
    }

    function addItemCompUrl(url){

        if(url && url.trim().length > 0){
            var modal = $('#modalEditGridItem');
            var compUrlsDiv = modal.find(".compUrlsDiv");

            var container = compUrlsDiv;
            var template = $('#itemCompUrlTemplate');

            var templateHtml = template.html();

            var newUrl = $(templateHtml);

            newUrl.find('[name=item_comp_url]').val(url).prop("readonly",true);
            container.append(newUrl);
        }

    }

    function selectFieldImage(imgObj){

        var name = imgObj.name;
        var label = imgObj.label;

        var imageUrl = window.IMAGE_URL_PREPEND + name;

        window.fieldImageDiv.find('.image_value').val(imageUrl).trigger('change');

        window.fieldImageDiv.find('.image_body img').attr('src', imageUrl );

        // var image_alt = window.fieldImageDiv.find('.image_alt:first');
        // if(image_alt.val().length == 0){
        //     image_alt.val(label);
        //     image_alt.focus();
        // }
    }

    function onFieldImageChange(input){
        var imageDiv = $(input).parents('.image_card:first');

        var imageUrl = $(input).val().trim();
        if(imageUrl.length == 0){
            imageUrl = null;
        }

        imageDiv.find('.image_body img').attr('src', imageUrl );

    }

    var grid = {};
    grid.init = function (layoutData, editComponentFunction) {
        grid.gridContainer = $('#gridContainer');
        grid.rootGridData = {};
        grid.rootGridDiv = null;
        grid._curSelected = false;
        grid.isEditing = false;

        grid.nextGridItemNum = 0;


        grid.editorModal = $('#modalEditGrid');

        grid.rootGridData = grid.initGridData(layoutData);
        grid.rootGridDiv = grid.render(grid.rootGridData);

        grid.setCurSelected(grid.rootGridData);

        grid.gridContainer.on('click', grid.gridClickHandler);

        grid.showEditModal();
    };

    grid.initGridData = function (layoutData) {

        var pageLayoutObj = JSON.parse(layoutData);
        var gridObj = grid.getDefaultGridItemObject();

        if(!$.isEmptyObject(pageLayoutObj)){

            $.extend(true, gridObj, pageLayoutObj);

        }
        else{
            //new page , set default layout
            var rootId = uuidv4();

            $.extend(true, gridObj, {
                id: rootId,
                name: 'page',
                type: 'grid',
                parent: '',
                children: [
                $.extend(true,grid.getDefaultGridItemObject(),{
                    id: uuidv4(),
                    name: 'Grid Item 1',
                    type: 'gridItem',
                    parent: rootId,
                    itemProps: {
                        'grid-row-start': 1,
                        'grid-row-end': 2,
                        'grid-column-start': 1,
                        'grid-column-end': 2,
                    },
                }),
                // $.extend(true,grid.getDefaultGridItemObject(),{
                //     id: uuidv4(),
                //     name: 'gridItem_2',
                //     type: 'grid',
                //     parent: rootId,
                //     itemProps: {
                //         'grid-row-start': 1,
                //         'grid-row-end': 2,
                //         'grid-column-start': 2,
                //         'grid-column-end': 3,
                //     },
                //     gridProps: grid.getDefaultGridProps(),
                //     children: [],
                // })  ,
                ],
                gridProps: grid.getDefaultGridProps()
            });
        }

        return gridObj;
    };

    grid.getGridData = function(){
        return grid.rootGridData;
    };

    grid.setCurSelected = function (obj) {
        if(obj.id !== grid._curSelected.id){
            grid._curSelected = obj;
            grid.showEditModal();
        }
    };

    grid.getCurSelected = function () {
        return grid._curSelected;
    };

    grid.getCurSelectedGrid = function () {
        var gridObj = grid._curSelected;
        if (gridObj.type === 'gridItem') {
            gridObj = $('#' + gridObj.parent).data('gridData');
        }

        return gridObj;
    };

    grid.deleteById = function(deleteId, gridObj){
        if(!gridObj){
            gridObj = grid.rootGridData;
        }
        if(gridObj.type === 'grid'){
            $(gridObj.children).each(function(index, curChild) {
                if(curChild.id === deleteId){
                    //remove
                    gridObj.children.splice(index,1);
                    grid.setCurSelected(gridObj);
                    grid.render(gridObj);
                    return false;
                }
                else{
                    return grid.deleteById(deleteId, curChild);
                }
            });

        }

        return true;
    };

    grid.getDefaultGridItemObject = function(){
        var defaultGridItemObj = {
                id: '',
                name: '',
                type: '',
                parent: '',
                compId : '',
                compName: '',
                cssClasses: '',
                cssStyle: '',

                itemProps: {},
                gridProps : {},
                children: [],
                compPropValues : {},
                urlList : []
        };
        return defaultGridItemObj;
    };

    grid.getDefaultGridProps = function(){
        return {
                columns: [['1', 'fr'], ['1', 'fr']],
                rows: [['1', 'fr'], ['1', 'fr']],
                columnGap: ['0', 'px'],
                rowGap: ['0', 'px'],
                justifyItems: 'stretch',
                alignItems: 'stretch',
            };
    };

    grid.checkIsEditing = function(){
        if(grid.isEditing){
            bootNotifyError("Save currenly editing item first.");
            return false;
        }
        else{
            return true;
        }
    };

    grid.render = function (obj) {

        var container = grid.gridContainer;

        var isRootGrid = false;

        if (obj.parent.length > 0) {
            container = $('#' + obj.parent);
        }
        else{
            isRootGrid = true;
        }

        if ($('#' + obj.id).length > 0) {
            $('#' + obj.id).remove();
        }

        if (obj.type === 'grid'  || obj.type === 'gridItem') {

            var gridObj = obj;

            var gridDiv = $('<div>').attr({
                'id': obj.id,     //??
                'grid-id': obj.id, //??
                'grid-name': obj.name,
                'grid-type': obj.type,
                'grid-parent': obj.parent,
            });
            gridDiv.on('click',grid.onClickGridItem);
            gridDiv.data('gridData', obj);
            var isGrid = (obj.type === 'grid' && !$.isEmptyObject(obj.gridProps));

            gridDiv.addClass(obj.type);

            if(isGrid){
                var gridProps = obj.gridProps;
                var columnRowReducer = function (accumulator, curValue) {
                    return accumulator + " " + curValue.join("");
                };
                var cssGridProps = {
                    'display': 'grid',
                    'grid-template-columns': gridProps.columns.reduce(columnRowReducer, '').trim(),
                    'grid-template-rows': gridProps.rows.reduce(columnRowReducer, '').trim(),
                    'grid-column-gap': gridProps.columnGap.join(''),
                    'grid-row-gap': gridProps.rowGap.join(''),
                    'justify-items': gridProps.justifyItems,
                    'align-items': gridProps.alignItems,
                };
                gridDiv.css(cssGridProps);

                grid.addGridPlaceholders(gridDiv);
            }

            if (!isRootGrid) {
                gridDiv.addClass('gridItem');
                // because all divs except root grid div is a grid item
                // even if its type == grid

                grid.setItemProps(gridDiv, gridObj.itemProps);

                var editBarTemplate = $('#template_grid_edit_bar');
                gridDiv.append(editBarTemplate.html());
                // gridDiv.find('[data-toggle=tooltip]').tooltip({
                //  trigger : 'hover'
                // });
                gridDiv.find('.itemName').text(gridObj.name);
            }

            $(container).append(gridDiv);
            grid.nextGridItemNum += 1;

            //renderChidren
            if(isGrid){
                $(gridObj.children).each(function (idx, child) {
                    grid.render(child);
                });
            }

            //console.log(cssGridProps);
            console.log(gridDiv);
            console.log(gridObj);

            return gridDiv;
        }
    };

    grid.setItemProps = function (ele, itemProps) {
        $(ele).css({
            'grid-row-start': '' + itemProps['grid-row-start'],
            'grid-row-end': '' + itemProps['grid-row-end'],
            'grid-column-start': '' + itemProps['grid-column-start'],
            'grid-column-end': '' + itemProps['grid-column-end'],
        });
    };

    grid.addGridPlaceholders = function (gridDiv) {

        var gridData = gridDiv.data('gridData');

        for (var rowIdx = 0; rowIdx < gridData.gridProps.rows.length; rowIdx++) {

            for (var colIdx = 0; colIdx < gridData.gridProps.columns.length; colIdx++) {
                var placeholderDiv = $('<div class="gridItemPlaceholder">');
                placeholderDiv.css({
                    'grid-row-start': '' + (rowIdx + 1),
                    'grid-row-end': '' + (rowIdx + 2),
                    'grid-column-start': '' + (colIdx + 1),
                    'grid-column-end': '' + (colIdx + 2),
                });
                //placeholderDiv.text((rowIdx + 1) + " " + (colIdx + 1));
                placeholderDiv.on('click', grid.onClickGridPlaceholder)
                gridDiv.append(placeholderDiv);
            }
        }
    };

    grid.addNewGridItem = function (params) {
        var curSelected = grid.getCurSelected();

        if (curSelected.type === 'grid') {
            var parentId = curSelected.id;

            var gridItemObj = grid.getDefaultGridItemObject();

            $.extend(true, gridItemObj, {
                id: uuidv4(),
                name: 'Grid item ' + grid.nextGridItemNum,
                type: 'gridItem',
                parent: parentId,
                itemProps: {
                    'grid-row-start': '' + params.rowStart,
                    'grid-row-end': '' + params.rowEnd,
                    'grid-column-start': '' + params.colStart,
                    'grid-column-end': '' + params.colEnd,
                }
            });

            curSelected.children.push(gridItemObj);

            var gridItemDiv = grid.render(gridItemObj);
            grid.editGridItem(gridItemDiv.find('.editItemBtn'));
        }
    };

    grid.showEditModal = function () {

        // reset modal if it isn't visible
        if (!(grid.editorModal.is(':visible'))) {
            grid.editorModal.find('.modal-dialog').css({
                top: 0,
                left: 0
            });
        }
        grid.editorModal.modal({
            backdrop: false,
            show: true,
        });

        grid.renderEditModal();
    };

    grid.renderEditModal = function () {

        var gridObj = grid.getCurSelectedGrid();

        var gridProps = gridObj.gridProps;

        var modal = grid.editorModal;

        modal.find('[name=curSelectedName]').val(gridObj.name);

        modal.find('.gridColumnsList,.gridRowsList').html('');
        //grid columns
        $.each(gridProps.columns, function (index, curColumn) {
            grid.addGridColRow('col', false, curColumn);
        });
        //grid rows
        $.each(gridProps.rows, function (index, curRow) {
            grid.addGridColRow('row', false, curRow);
        });

        modal.find('[name=gridGapColumnSize]').val(gridProps.columnGap[0]);
        modal.find('[name=gridGapColumnSizeUnit]').val(gridProps.columnGap[1]);

        modal.find('[name=gridGapRowSize]').val(gridProps.rowGap[0]);
        modal.find('[name=gridGapRowSizeUnit]').val(gridProps.rowGap[1]);
    };

    grid.addGridColRow = function (type, isUpdate, data) {

        var selector = type === "col" ? ".gridColumnsList" : ".gridRowsList";
        var container = grid.editorModal.find(selector);
        var template = $('#template_grid_input');
        var inputRow = $(template.clone(true)).removeAttr('id');
        container.append(inputRow);

        inputRow.attr('data-type', type);

        if (typeof data === 'undefined') {
            data = ['1', 'fr'];//default value
        }

        inputRow.find('[name=size]').val(data[0]);
        inputRow.find('[name=sizeUnit]').val(data[1]);

        if (isUpdate) {
            grid.updateGridProps(type);
        }
    };

    grid.deleteGridColRow = function (btn) {
        var isConfirm = confirm("Are you sure ?");

        if (isConfirm) {
            var gridInputDiv = $(btn).parents('.gridInputDiv:first');
            var type = gridInputDiv.attr('data-type');
            gridInputDiv.remove();
            grid.updateGridProps(type);
        }
    };

    grid.updateGridProps = function (type) {

        console.log('updateGridProps', type);

        var curGridObj = grid.getCurSelectedGrid();

        var modal = grid.editorModal;

        if (type === 'col') {
            var columns = [];
            modal.find('.gridColumnsList .gridInputDiv')
                .each(function (index, el) {
                    el = $(el);
                    var size = el.find('[name=size]').val();
                    var sizeUnit = el.find('[name=sizeUnit]').val();

                    columns.push([size, sizeUnit]);
                });
            curGridObj.gridProps.columns = columns;
        }

        if (type === 'row') {
            var rows = [];
            modal.find('.gridRowsList .gridInputDiv')
                .each(function (index, el) {
                    el = $(el);
                    var size = el.find('[name=size]').val();
                    var sizeUnit = el.find('[name=sizeUnit]').val();

                    rows.push([size, sizeUnit]);
                });
            curGridObj.gridProps.rows = rows;
        }

        if (type === 'columnGap') {
            curGridObj.gridProps.columnGap = [
                modal.find('[name=gridGapColumnSize]').val(),
                modal.find('[name=gridGapColumnSizeUnit]').val(),
            ];
        }

        if (type === 'rowGap') {
            curGridObj.gridProps.rowGap = [
                modal.find('[name=gridGapRowSize]').val(),
                modal.find('[name=gridGapRowSizeUnit]').val(),
            ];
        }

        grid.render(curGridObj);

    };

    grid.editGridItem = function (btn) {

        if(!grid.checkIsEditing()){
            return false;
        }

        var gridItemDiv = $(btn).parents('.gridItem:first');
        var editBarDiv = gridItemDiv.find('.gridEditBar:first');

        grid.setCurSelected(gridItemDiv.data('gridData'));
        grid.isEditing = true;
        gridItemDiv.addClass("edit");

        gridItemDiv.find('.showOnEdit').show();
        gridItemDiv.find('.hideOnEdit').hide();

        var itemNameDiv = editBarDiv.find('.itemName:first');
        var itemNameInput = editBarDiv.find('.itemNameInput:first');

        itemNameInput.val(itemNameDiv.text());

        itemNameDiv.hide();
        itemNameInput.css('display', 'inline-block');
        itemNameInput.focus();
    };

    grid.editItemComponent = function (btn) {

        if(!grid.checkIsEditing()){
            return false;
        }

        var gridItemDiv = $(btn).parents('.gridItem:first');
        var editBarDiv = gridItemDiv.find('.gridEditBar:first');
        var gridDataObj = gridItemDiv.data('gridData');

        var type = gridDataObj.type;
        if(type === 'gridItem'){
            editGridItem(gridDataObj);
        }
    };

    grid.saveItemComponent = function (compData) {
        var itemId = compData.itemId;
        if(!itemId  || itemId.length === 0){
            return false;
        }
        var gridItemDiv = $('#'+itemId);
        var gridObj = gridItemDiv.data('gridData');

        var newProps = {
            compId : compData.compId,
            compName : compData.compName,
            cssClasses : compData.cssClasses,
            cssStyle : compData.cssStyle,
            compPropValues : compData.propValues,
            urlList : compData.urlList,
        };

        $.extend(gridObj, newProps);

        grid.isEditing = false;
        grid.setCurSelected(gridObj);
    };

    grid.convertToGrid = function (btn) {

        if(!grid.checkIsEditing()){
            return false;
        }

        var gridItemDiv = $(btn).parents('.gridItem:first');
        var editBarDiv = gridItemDiv.find('.gridEditBar:first');
        var gridDataObj = gridItemDiv.data('gridData');

        var type = gridDataObj.type;
        if(type === 'gridItem'){
            //convert to grid
            gridDataObj.gridProps = grid.getDefaultGridProps();
            gridDataObj.children = [];
            gridDataObj.type = 'grid';
            grid.setCurSelected(gridDataObj);
            grid.render(gridDataObj);

        }
    };

    grid.convertToItem = function (btn) {

        if(!grid.checkIsEditing()){
            return false;
        }

        var gridItemDiv = $(btn).parents('.gridItem:first');
        var editBarDiv = gridItemDiv.find('.gridEditBar:first');
        var gridDataObj = gridItemDiv.data('gridData');

        var type = gridDataObj.type;
        if(type === 'grid'){
            //convert to grid
            gridDataObj.gridProps = {};
            gridDataObj.children = [];
            gridDataObj.type = 'gridItem';
            grid.setCurSelected(gridDataObj);
            grid.render(gridDataObj);

        }
    };


    grid.expandGridItem = function (gridItemObj, placeholderDiv) {
        console.log("expandGridItem", gridItemObj, placeholderDiv);

        var gridItemDiv = $('#' + gridItemObj.id);
        var itemId = gridItemObj.id;
        var itemProps = gridItemObj.itemProps;
        // console.log(itemProps);

        var minRowStart = Math.min(itemProps['grid-row-start'], placeholderDiv.css('grid-row-start'));
        var minColStart = Math.min(itemProps['grid-column-start'], placeholderDiv.css('grid-column-start'));

        var maxRowEnd = Math.max(itemProps['grid-row-end'], placeholderDiv.css('grid-row-end'));
        var maxColEnd = Math.max(itemProps['grid-column-end'], placeholderDiv.css('grid-column-end'));

        var isCollision = false;
        var parentObj = gridItemDiv.parent().data('gridData');
        $(parentObj.children).each(function(index, childObj) {
            if(childObj.id === itemId){
                return true; //skip
            }

            var curP = childObj.itemProps;
            var rowCollision = ( (curP['grid-column-start'] > minColStart && curP['grid-column-start'] < maxColEnd)
                                    || (curP['grid-column-end'] > minColStart && curP['grid-column-end'] < maxColEnd));
            var colCollision = (curP['grid-row-start'] > minRowStart && curP['grid-row-start'] < maxRowEnd)
                                    || (curP['grid-row-end'] > minRowStart && curP['grid-row-end'] < maxRowEnd);

            if( rowCollision && colCollision ){
                isCollision = true;
                return false;
            }

        });

        if (!isCollision) {
            var itemProps = gridItemObj.itemProps;

            itemProps['grid-row-start'] = minRowStart;
            itemProps['grid-column-start'] = minColStart;

            itemProps['grid-row-end'] = maxRowEnd;
            itemProps['grid-column-end'] = maxColEnd;

            grid.setItemProps(gridItemDiv, itemProps);
            // console.log(itemProps);
        }

    };

    grid.saveGridItem = function (btn) {
        var gridItemDiv = $(btn).parents('.gridItem:first');
        var gridObj = gridItemDiv.data('gridData');

        var editBarDiv = gridItemDiv.find('.gridEditBar:first');

        gridItemDiv.removeClass("edit");

        gridItemDiv.find('.showOnEdit').hide();
        gridItemDiv.find('.hideOnEdit').show();

        var itemNameDiv = editBarDiv.find('.itemName:first');
        var itemNameInput = editBarDiv.find('.itemNameInput:first');

        var itemName = itemNameInput.val();
        itemNameDiv.text(itemName);
        gridObj.name = itemName;

        itemNameInput.hide();
        itemNameDiv.show();

        grid.isEditing = false;
        grid.setCurSelected(gridObj);
    };

    grid.deleteGridItem = function (btn) {
        btn = $(btn);
        var gridItemDiv = btn.parents('.gridItem:first');
        var itemId = gridItemDiv.attr('grid-id');
        if(grid.isEditing){
            var curSelected = grid.getCurSelected();
            if(curSelected.id === itemId){
                grid.isEditing = false;
            }
        }
        grid.deleteById(itemId);
    };

    grid.gridClickHandler = function (event) {
        event.preventDefault();

        console.log('clicked', event.target);
        grid.showEditModal();
    };

    grid.onClickGridItem = function (event) {
        var gridItemDiv = $(event.target);
        if (!gridItemDiv.hasClass('gridItem')) {
            return false;
        }
        console.log("gridItem click");

        grid.setCurSelected(gridItemDiv.data('gridData'));
    };

    grid.onClickGridPlaceholder = function (event) {
        var placeholderDiv = $(event.target);
        if (!placeholderDiv.hasClass('gridItemPlaceholder')) {
            return false;
        }
        console.log("placeholder click");


        var curSelected = grid.getCurSelected();
        if(grid.isEditing){
            //check if clicked is sibling of curSelected item
            var parentId = placeholderDiv.parent().attr('id');

            if (curSelected.parent === parentId) {
                grid.expandGridItem(curSelected, placeholderDiv);
            }
        }
        else{
            // if (curSelected.type === 'grid') {
                //make placeholder parent grid as curSelected
                var phParentObj = placeholderDiv.parent().data('gridData');
                grid.setCurSelected(phParentObj);

                grid.addNewGridItem({
                    rowStart: placeholderDiv.css('grid-row-start'),
                    colStart: placeholderDiv.css('grid-column-start'),
                    rowEnd: placeholderDiv.css('grid-row-end'),
                    colEnd: placeholderDiv.css('grid-column-end'),
                });
            // }
        }

    };

    grid.onInputItemName = function (input) {
        input = $(input);
        var saveItemBtn = input.parents('.gridEditBar:first').find('.saveItemBtn');

        saveItemBtn.prop('disabled', (input.val().trim() === ''));

    };

    grid.onInputGridSize = function (input, type) {
        input = $(input);
        console.log(input.val());

        var val = input.val();
        var validVal = grid.getValidNumber(val, 1);
        if (parseFloat(val) !== parseFloat(validVal)) {
            input.val(validVal);
        }

        if (typeof type == 'undefined') {
            type = input.parents('.gridInputDiv:first').attr('data-type');
        }

        grid.updateGridProps(type);
    };

    grid.onChangeGridSizeUnit = function (input, type) {
        
        if (typeof type == 'undefined') {
            type = $(input).parents('.gridInputDiv:first').attr('data-type');
        }
        grid.updateGridProps(type);
    };

    grid.getValidNumber = function (num, precision) {
        var floatVal = parseFloat(num);

        if (isNaN(floatVal)) {
            floatVal = 1.0;
        }
        var factor = (precision > 0) ? (precision * 10) : 1;
        return Math.round(floatVal * factor) / (factor);
    };

    
    dragElement(document.getElementById("draggable-modal"));

    function dragElement(elmnt) {
        var pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
        if (document.getElementById(elmnt.id + "header")) {
            document.getElementById(elmnt.id + "header").onmousedown = dragMouseDown;
        } else {
            elmnt.onmousedown = dragMouseDown;
        }

        function dragMouseDown(e) {
            e = e || window.event;
            e.preventDefault();
            pos3 = e.clientX;
            pos4 = e.clientY;
            document.onmouseup = closeDragElement;
            document.onmousemove = elementDrag;
        }

        function elementDrag(e) {
            e = e || window.event;
            e.preventDefault();
            pos1 = pos3 - e.clientX;
            pos2 = pos4 - e.clientY;
            pos3 = e.clientX;
            pos4 = e.clientY;
            elmnt.style.top = (elmnt.offsetTop - pos2) + "px";
            elmnt.style.left = (elmnt.offsetLeft - pos1) + "px";
        }

        function closeDragElement() {
            document.onmouseup = null;
            document.onmousemove = null;
        }
    }


</script>

    </body>
</html>