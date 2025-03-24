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

    q = "SELECT id, name, layout FROM pages "
        + " WHERE id = " + escape.cote(pageId)
        + " AND site_id = " + escape.cote(getSiteId(session))
        + " AND type = 'react'";
    rs = Etn.execute(q);

    if(!rs.next() || !"react-grid-layout".equals(rs.value("layout")) ){
        response.sendRedirect("dynamicPages.jsp");
    }

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title>Page : <%=rs.value("name")%></title>

    <style type="text/css">

        #pagePreviewIframe{
            width: 100%;
            height: 100%;
            border: none;
        }
    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <form action="" onsubmit="return false">
                <input type="hidden" name="pageId" id="pageId" value='<%=pageId%>'>
            </form>

            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2 ">Page : <span id="pageNameHeading" ><%=rs.value("name")%></span></h1>
                <div class="btn-toolbar mb-2 mb-md-0">


                    <div class="btn-group mr-2 mb-1">
                        <button class="btn btn-danger" type="button"
                        onclick="onPublishUnpublish('publish')">Publish</button>
                        <button class="btn btn-danger" type="button"
                        onclick="onPublishUnpublish('unpublish')">Unpublish</button>
                    </div>

                    <div class="btn-group mr-2 mb-1"id="previewBtn" >
                        <button type="button" class="btn btn-warning"  onclick='onPageEditorPreview()'>Preview</button>
                    </div>

                    <button class="btn btn-success mr-1 mb-1" type="button"
                        onclick="openAddEditComponentModal()">Add a component</button>

                    <button class="btn btn-success mr-1 mb-1" type="button"
                        onclick="openExistingComponentsModal()">List of components</button>

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
                    <div class="embed-responsive" id="iframeParent">
                        <iframe id="pagePreviewIframe" src="" ></iframe>
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
    </div>

<script type="text/javascript">

    $ch.isPageEditor = true;
    $ch.pagePreviewFrame = $('#pagePreviewIframe');

    window.IMAGE_URL_PREPEND = '<%=getImageURLPrepend(getSiteId(session))%>';
    // ready function
    $(document).ready(function() {

        var url = 'grid-designer/index.jsp?id='+$('#pageId').val()+'&rand='+getRandomInt(1000000);

        $ch.pagePreviewFrame.get(0).src = url;

        $('button.navbar-toggler.sidebar-toggler').click(function(){
            setTimeout(resizeIframe,500);
        });
        $('button.sidebar-minimizer.brand-minimizer').click(function(){
            setTimeout(resizeIframe,500);
        });

        $('.onPageEditor').show();
    });

    function onPageEditorSave(confirmed){
        if(!confirmed){

        bootConfirm("Are you sure?",function(result){
                if(result){
                    onPageEditorSave(true);
                }
            });
            return false;
        }

        var saveGridLayout = $ch.pagePreviewFrame.get(0).contentWindow.saveGridLayout;
        if(saveGridLayout){
            saveGridLayout();
        }

    }

    function addComponentToGrid(compId){

        var addGridLayoutItem = $ch.pagePreviewFrame.get(0).contentWindow.addGridLayoutItem;
        if(addGridLayoutItem){
            addGridLayoutItem(compId);
        }

    }

    function onSaveLayoutSuccess(msg){
        bootNotify(msg);
    }

    function onSaveLayoutFail(msg){
        bootNotifyError(msg);
    }

    function resizeIframe(){
        console.log("Iframe resized");
        $ch.pagePreviewFrame.parent().height($ch.pagePreviewFrame.contents().find('body:first').height()+100);
        $ch.pagePreviewFrame.contents().find('body:first').width($ch.pagePreviewFrame.width()-22);
    }

    var initResize = false;
    function onPreviewLoad(){

        resizeIframe();

        var editCssLink =  $('<link>').attr('rel','stylesheet')
        .attr('href','<%=request.getContextPath()%>/css/page-edit.css');

        $ch.pagePreviewFrame.contents().find('head').append(editCssLink);


        var blocEditDiv = $('#blocEditDiv').html();
        // console.log(blocEditDiv);
        var iframeBody = $ch.pagePreviewFrame.contents().find('body');
        var blocDivs = iframeBody.find('.bloc_div');
        blocDivs.each(function(index, el) {
            el = $(el);
            // console.log(el);
            el.append(blocEditDiv).addClass('bloc_edit')
            el.find('.blocName').text(el.data('bloc-name'));
        });

        // Sortable.create(iframeBody[0],{animation:10});
    }

    $ch.pagePreviewFrame.load(onPreviewLoad);

    function onPageSaveSuccess(resp, form){
        $('#pageNameHeading').text(form.find('[name=name]').val());
        refreshPagePreview();
    }


    function refreshPagePreview(){

        var url = "grid-designer/index.jsp?id="+$('#pageId').val();
        url += '&rand='+getRandomInt(1000000);
        $ch.pagePreviewFrame.get(0).src = url;
        resizeIframe();
    }

    function onPageEditorPreview(){
        getPagePreview($('#pageId').val());
    }
    function onPageEditorMobilePreview(){
        getPageMobilePreview($('#pageId').val());
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
                pages.push({id:$('#pageId').val(), type:'<%=Constant.PAGE_TYPE_REACT%>'});
                publishUnpublishPages(pages, action, publishTime);
            });
        }
    }

    function editGridItem(itemData){
        if(typeof itemData == "undefined" ||
            typeof itemData.i == "undefined"){
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

        var itemId = item.i;
        var compId = item.compId;
        var propValues = item.propValues;
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

        var saveGridItem = $ch.pagePreviewFrame.get(0).contentWindow.saveGridItem;
        if(saveGridItem){
            saveGridItem(itemData);
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

    function selectFieldImageDynamic(imgObj){

        var name = imgObj.name;
        var label = imgObj.label;

        var imageUrl = window.IMAGE_URL_PREPEND + name;

        window.fieldImageDiv.find('.image_value').val(imageUrl).trigger('change');

        window.fieldImageDiv.find('.image_body img').attr('src', imageUrl );
    }

    function onFieldImageChange(input){
        var imageDiv = $(input).parents('.image_card:first');

        var imageUrl = $(input).val().trim();
        if(imageUrl.length == 0){
            imageUrl = null;
        }

        imageDiv.find('.image_body img').attr('src', imageUrl );

    }

    function drag_start(event) {
        var style = window.getComputedStyle(event.target, null);
        var str = (parseInt(style.getPropertyValue("left")) - event.clientX) + ',' + (parseInt(style.getPropertyValue("top")) - event.clientY) + ',' + event.target.id;
        event.dataTransfer.setData("Text", str);
    }

    function drop(event) {
        var offset = event.dataTransfer.getData("Text").split(',');
        var dm = document.getElementById(offset[2]);
        dm.style.left = (event.clientX + parseInt(offset[0], 10)) + 'px';
        dm.style.top = (event.clientY + parseInt(offset[1], 10)) + 'px';
        event.preventDefault();
        return false;
    }

    function drag_over(event) {
        event.preventDefault();
        return false;
    }

</script>
    </body>
</html>