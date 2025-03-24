<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%@ include file="../common.jsp"%>
<%
    String selectedsiteid = getSelectedSiteId(session);
    String edit_id = parseNull(request.getParameter("id"));
    String folderId = parseNull(request.getParameter("folder_id"));

    int maxFolderLevel = Integer.parseInt(GlobalParm.getParm("MAX_TAG_FOLDER_LEVEL"));
    boolean validFolderLevel=true;

	String loadedFolderName = "";
    if(folderId.length() > 0){
        Set rsFolder = Etn.execute("select * from tags_folders where uuid="+escape.cote(folderId)+" and site_id="+escape.cote(selectedsiteid));
        if(rsFolder.next()) {
			loadedFolderName = rsFolder.value("name");
            if(Integer.parseInt(parseNull(rsFolder.value("folder_level")))>=maxFolderLevel){
                validFolderLevel=false;
            }
        }else{
            response.sendRedirect(request.getContextPath()+"/admin/catalogs/tags.jsp");
        }
    }

%>
<!DOCTYPE html>
<html>
<head>
    <title>List of tags</title>
    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
</head>
	<%
	if(folderId.length() == 0)
	{
		breadcrumbs.add(new String[]{"Content", ""});
		breadcrumbs.add(new String[]{"Tags", ""});
	}
	else
	{
		breadcrumbs.add(new String[]{"Content", ""});
		breadcrumbs.add(new String[]{"Tags", "tags.jsp"});
		breadcrumbs.add(new String[]{"Folder - "+loadedFolderName, ""});
	}
	%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">

            <!-- title -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <div>
                    <h1 class="h2">List of tags</h1>
                </div>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <%if(folderId.length()>0){%>
                        <button type="button" class="btn btn-primary mr-1"
                            onclick="history.back();">Back</button>
                        <%if(validFolderLevel){%>
                            <button class="btn btn-success mr-2"
                                onclick="addTag()">Add a tag</button>
                        <%}%>
                    <%}%>
                    <button class="btn btn-primary mr-2"
                        onclick="openMoveToModal()">Move Tag</button>

                    <%if(validFolderLevel){%>
                        <button class="btn btn-success mr-2"
                            onclick="addFolder()">Add a Folder</button>
                    <%}%>

                    <button class="btn btn-danger mr-2"
                        onclick="deleteSelectedItems()">Delete</button>
                        
                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Tags');" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>
                </div>
            </div>
            <!-- /title -->

            <!-- content -->
            <div class="row animated fadeIn">
                <div class="col">
                    <table class="table table-hover" id="tagsTable" style="width: 100%;">
                        <thead class="thead-dark">
                            <tr>
                                <th scope="col"><input type="checkbox" class="" id="checkAll" onchange="onChangeCheckAll(this)"></th>
                                <th scope="col"> </th>
                                <th scope="col">Tag</th>
                                <th scope="col">ID</th>
                                <th scope="col">Nb using</th>
                                <th scope="col">Created</th>
                                <th scope="col" class="dt-body-right text-nowrap"
                                    style="width:100px">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- loaded by ajax -->
                        </tbody>
                    </table>
                    <div id="actionsCellTemplate" class="d-none" >
                        <button class="btn btn-sm btn-primary " type="button"
                            onclick='editTag(this)'>
                            <i data-feather="settings"></i></button>
                        <button class="btn btn-sm btn-danger" type="button"
                            onclick='deleteItem(this)'>
                            <i data-feather="x"></i></button>
                    </div>
                    <div id="actionsCellTemplateFolder" class="d-none" >
                        <button class="btn btn-sm btn-primary " type="button"
                            onclick='openFolder(this)'>
                            <i data-feather="list"></i></button>
                        <button class="btn btn-sm btn-danger" type="button"
                            onclick='deleteItem(this)'>
                            <i data-feather="trash"></i></button>
                    </div>
                </div>
            </div>
            <!-- /content -->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>

    <!-- Modal -->
    <div class="modal fade" id="modalAddEditTag" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="formAddEditTag" action="" >
                <input type="hidden" name="requestType" value="saveTag">
                <input type="hidden" name="type" id="saveType" value="add|edit">
                <input type="hidden" name="folder_id" value='<%=escapeCoteValue(folderId)%>'>
                <div class="modal-header">
                    <h5 class="modal-title">Add tag</h5>
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
                    <div class="errorMsg text-danger small">error message</div>
                    <div class="form-group row">
                        <label class="col-sm-3 col-form-label">Tag label</label>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" name="label" value=""
                                    maxlength="100" required="required" id="tagLabelField"
                                    onchange="onChangeTagLabel(this)">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label class="col-sm-3 col-form-label">Tag ID</label>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" name="tagId" value=""
                                    maxlength="100" required="required"
                                    id="tagIdField"
                                    onkeyup="onKeyupTagId(this)">
                        </div>
                    </div>

                </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <!-- Modal -->
    <div class="modal fade" id="modalAddFolder" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="formAddFolder" action="" >
                <input type="hidden" name="requestType" value="saveFolder">
                <input type="hidden" name="parentFolderId" value='<%=escapeCoteValue(folderId)%>'>
                <div class="modal-header">
                    <h5 class="modal-title">Add Folder</h5>
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
                    <div class="errorMsg text-danger small">error message</div>
                    <div class="form-group row">
                        <label class="col-sm-3 col-form-label">Folder label</label>
                        <div class="col-sm-9">
                            <input type="text" class="form-control" name="label" value=""
                                maxlength="100" required="required" id="folderLabelField">
                        </div>
                    </div>
                </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <div class="modal fade" id="modalTagUses" tabindex="-1" role="dialog" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Using : </h5>
                    <div class="text-right">
                        <!-- <button type="submit" class="btn btn-primary" >Save</button> -->
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
                <div class="modal-body">
                    <button type="button" class="btn btn-success btn-lg btn-block text-left mb-1"
                            data-toggle="collapse" href="#catalogsUsesCollapse" role="button" >
                        Catalogs
                    </button>
                    <div class="collapse show pt-3" id="catalogsUsesCollapse">
                        <ol id="catalogUsesList">
                        </ol>
                    </div>
                    <button type="button" class="btn btn-success btn-lg btn-block text-left mb-1"
                            data-toggle="collapse" href="#productsUsesCollapse" role="button" >
                        Products
                    </button>
                    <div class="collapse show pt-3" id="productsUsesCollapse">
                        <ol id="productUsesList">
                        </ol>
                    </div>
                    <button type="button" class="btn btn-success btn-lg btn-block text-left mb-1"
                            data-toggle="collapse" href="#pagesUsesCollapse" role="button" >
                        Pages
                    </button>
                    <div class="collapse show pt-3" id="pagesUsesCollapse">
                        <ol id="pageUsesList">
                        </ol>
                    </div>
                    <button type="button" class="btn btn-success btn-lg btn-block text-left mb-1"
                            data-toggle="collapse" href="#blocsUsesCollapse" role="button" >
                        Blocs
                    </button>
                    <div class="collapse show pt-3" id="blocsUsesCollapse">
                        <ol id="blocUsesList">
                        </ol>
                    </div>
                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <!-- move to modal -->
    <div class="modal fade" tabindex="-1" role="dialog" id='moveToDlg' >
        <div class="modal-dialog modal-md" role="document">
            <div class="modal-content">
                <div class="modal-header" style='text-align:left'>
                    <h5 class="modal-title">Move tag to folder.</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                        </button>
                </div>
                <div class="modal-body">
                    <div>
                        <div class="row">
                            <div class="form-group col-sm-12">
                                <select name="folder" class="custom-select" id="tagsFolderSelect">
                                    <option value="">-- list of folders --</option>
                                </select>
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group  col-sm-3">
                                <button type="button" class="btn btn-success" onclick="moveSelectedTags()">Submit</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div>

<script>
    //ready function
    $(function(){
        
        initTagsTable();

        $('#formAddEditTag').submit(function(event) {
            event.preventDefault();
            event.stopPropagation();
            onSaveTag();
        });
        
        $('#formAddFolder').submit(function(event) {
            event.preventDefault();
            event.stopPropagation();
            onSaveFolder();
        });

        $("#tagLabelField").on('keydown', function(event) {
            //dont allow comma ,
            if(event.which == 188){
                return false;
            }
        });

        $("#folderLabelField").on('keydown', function(event) {
            //dont allow comma ,
            if(event.which == 188){
                return false;
            }
        });

        window.PAGES_APP_URL = '<%=GlobalParm.getParm("PAGES_APP_URL")%>';

    });

    function initTagsTable(){
	
        window.tagsTable = $('#tagsTable')
        .DataTable({
            "responsive": true,
            "language": {
                "emptyTable": "No tags found"
            },
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function(data, callback, settings){
                getTagsList(data,callback,settings);
            },
            order : [[1,'desc']],
            columns : [
                { "data": "id" },
                { "data": "type" },
                { "data": "label", className : "label"},
                { "data": "label_id" },
                { "data": "nb_uses" },
                { "data": "created_on" },
                { "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
                { targets : [0,5] , searchable : false},
                { targets : [0,5] , orderable : false},
				{ targets : [2] , render: _hEscapeHtml},
                { targets : [0] ,
                    render: function ( data, type, row ) {
                        if(row.type=="tag"){
                            return '<input type="checkbox" class="tagIdCheck" name="tagId" value="'+data+'" >';
                        }else{
                            return '<input type="checkbox" class="folderIdCheck" name="folderId" value="'+data+'" >';
                        }
                    }
                },
                { targets : [1] ,
                    render: function ( data, type, row ) {
                        if(data=='folder'){
                            return '<a href="tags.jsp?folder_id='+row.uuid+'" style="color:currentColor;"><i class="fa fa-folder-open" aria-hidden="true"></i></a>';
                        }else{
                            return "";
                        }
                    }
                },
                { targets : [3] ,
                    render: function ( data, type, row ) {
                        var badge_color = (data > 0)?'secondary':'danger';
                        return '<a href="javascript:void(0)" onclick="showTagUses(this)" > <span class="badge badge-'+badge_color+'">'+data+'</span></a>';
                    }
                },


            ],
            createdRow : function ( row, data, index ) {
                $(row).data('tag-data',data).addClass('tagRow');
            },
        });
    }

    function getTagsList(data, callback, settings){
        // showLoader();
        $.ajax({
            url: 'tagsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getTagsList',
                id:'<%=escapeCoteValue(edit_id)%>',
                folder_id:'<%=escapeCoteValue(folderId)%>',
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.tags;
                var actionTemplate = $('#actionsCellTemplate').html();
                var actionTemplateFodler = $('#actionsCellTemplateFolder').html();
                $.each(data, function(index, val) {
                    if(val.type=="tag"){
                        var curId = val.id;
                        val.actions = strReplaceAll(actionTemplate, "#ID#", curId);
                    }else{
                        var curId = val.id;
                        val.actions = strReplaceAll(actionTemplateFodler, "#ID#", curId);
                    }

                    // var badge_color = (val.nb_uses > 0)?'secondary':'danger';
                    //  val.nb_uses = '<a href="javascript:void(0)" onclick="showTagUses(this)" > <span class="badge badge-'+badge_color+'">'+val.nb_uses+'</span></a>';
                });
            }
            callback( { "data" : data } );
        })
        .fail(function() {
            callback( { "data" : [] } );
        })
        .always(function() {
            // hideLoader();
        });

    }

    function addTag(){
        var modal = $('#modalAddEditTag');
        var form = $('#formAddEditTag');

        form.get(0).reset();

        form.find('[name=type]').val('add');

        modal.find('.errorMsg').html('');

        modal.find('modal-title').text("Add tag");

        form.find('[name=tagId]').prop('readonly',false);

        modal.modal('show');
    }

    function addFolder(){
        var modal = $('#modalAddFolder');
        var form = $('#formAddFolder');

        form.get(0).reset();

        modal.find('.errorMsg').html('');

        modal.find('modal-title').text("Add Folder");

        modal.modal('show');
    }

    function editTag(btn){
        var tr = $(btn).parents('tr.tagRow:first');
        var tagData = tr.data('tag-data');

        var modal = $('#modalAddEditTag');
        var form = $('#formAddEditTag');

        form.get(0).reset();

        form.find('[name=type]').val('edit');

        modal.find('.errorMsg').html('');

        modal.find('modal-title').text("Edit tag");


        form.find('[name=tagId]').val(tagData.id).prop('readonly',true);
        form.find('[name=label]').val(tagData.label);

        modal.modal('show');
    }

    function openFolder(btn){
        var tr = $(btn).parents('tr.tagRow:first');
        var tagData = tr.data('tag-data');
        window.location.href='tags.jsp?folder_id='+tagData.uuid;
    }

    function onSaveTag(){

        var modal = $('#modalAddEditTag');
        var form = $('#formAddEditTag');

        var errorMsg = modal.find('.errorMsg');

        errorMsg.html('');

        if( !form.get(0).checkValidity() ){
            return false;
        }

        showLoader();
        $.ajax({
            url: 'tagsAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status === 1){
                refreshTagsTable();
                var saveType = $('#saveType').val();
                if(saveType === 'add'){
                    //requirment , keep modal open
                    //, refresh form to add new tag
                    addTag();
                }
                else{
                    modal.modal('hide');
                }
                bootNotify('Tag saved.');
            }
            else{
                errorMsg.html(resp.message);
            }
        })
        .fail(function() {
            alert("Error in saving tag. please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }
    function onSaveFolder(){

        var modal = $('#modalAddFolder');
        var form = $('#formAddFolder');
        
        var errorMsg = modal.find('.errorMsg');

        errorMsg.html('');

        if( !form.get(0).checkValidity() ){
            return false;
        }

        showLoader();
        $.ajax({
            url: 'tagsFolderAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status==1){
                addFolder();
                modal.modal('hide');
                window.location.reload();
            }
        })
        .fail(function() {
            alert("Error in saving folder, please try again.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function refreshTagsTable(){
        window.tagsTable.ajax.reload(null,false);
    }

    function deleteItem(btn){
        var tr = $(btn).parents('tr.tagRow:first');
        
        var tagData = tr.data('tag-data');
        if(tagData.nb_uses > 0 ){
            bootNotify("A tag or folder with existing usage cannot be deleted.","danger");//new chnages
            return false;
        }
        var ids = [tagData.id];

        var msg = "Are you sure you want to delete this "+tagData.type+"?";
        bootConfirm(msg,function(result){
            if(result){
                if(tagData.type=="tag"){
                    deleteTags(ids);
                }else{
                    deleteFolders(ids);
                }
            }
        });
    }

    function deleteSelectedItems(){
        var selectedTags = $('.tagIdCheck:checked');
        var selectedFolders = $('.folderIdCheck:checked');
        var hasUsage = false;
        if(selectedTags.length == 0 && selectedFolders.length == 0){
            bootNotify("No tag / folder selected.","danger");
            return false;
        }

        selectedTags.each(function() {//new chnages
            var tr = $(this).parents('tr.tagRow:first');
            var tagData = tr.data('tag-data');
            if (tagData.nb_uses > 0) {
                hasUsage = true;
                return false;
            }
        });

        if (!hasUsage) {//new chnages
            selectedFolders.each(function() {
                var tr = $(this).parents('tr.folderRow:first');
                var folderData = tr.data('folder-data');
                if (folderData.nb_uses > 0) {
                    hasUsage = true;
                    return false;
                }
            });
        }

        if (hasUsage) {//new chnages
            bootNotify("A tag or folder with existing usage cannot be deleted.", "danger");
            return false;
        }

        var msg = "Are you sure you want to delete " + selectedTags.length + " tags and "+selectedFolders.length+" folders?";
        bootConfirm(msg,function(result){
            if(result){
                var ids = [];
                selectedTags.each(function(index, el) {
                    ids.push($(el).val());
                });

                var folderIds = [];
                selectedFolders.each(function(index, el) {
                    folderIds.push($(el).val());
                });

               deleteTags(ids);
               deleteFolders(folderIds);
            }
        });
    }

    function deleteTags(ids){
        if(ids.length>0){
            var idsStr = ids.join(',');
            showLoader();
            $.ajax({
                url: 'tagsAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : "deleteTags",
                    ids : idsStr
                },
            })
            .done(function(resp) {
                if(resp.status === 1){
                    bootNotify('Tag(s) deleted.');
                }
                refreshTagsTable();
            })
            .fail(function() {
                alert("Error in deleting tags. please try again.");
            })
            .always(function() {
                hideLoader();
            });
        }

    }

    function deleteFolders(ids){
        if(ids.length>0){
            var idsStr = ids.join(',');
            showLoader();
            $.ajax({
                url: 'tagsFolderAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : "deleteFolders",
                    ids : idsStr
                },
            })
            .done(function(resp) {
                if(resp.stats==1){
                    bootNotify(resp.message);
                }else{
                    bootNotifyError(resp.message);
                }
                refreshTagsTable();
            })
            .fail(function() {
                alert("Error in deleting folders. Please try again.");
            })
            .always(function() {
                hideLoader();
            });
        }

    }

    function showTagUses(btn){
        btn = $(btn);
        var tr = $(btn).parents('tr.tagRow:first');
        var tagData = tr.data('tag-data');

        if(tagData.nb_uses > 0){
            showLoader();
            $.ajax({
                url: 'tagsAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : "getTagUses",
                    tagId : tagData.id
                },
            })
            .done(function(resp) {
                if(resp.status === 1){
                    var catalogs = resp.data.catalogs;
                    var catalogList = $('#catalogUsesList');
                    catalogList.html('');
                    if(catalogs.length == 0){
                        catalogList.html('<li>None </li>');
                    }
                    else{
                        $.each(catalogs, function(index, curObj) {
                            var link = $('<a>');
                            link.attr('href','catalog.jsp?id='+curObj.id);
                            link.text(curObj.name);
                            catalogList.append($("<li>").html(link));
                        });
                    }

                    var products = resp.data.products;
                    var productList = $('#productUsesList');
                    productList.html('');
                    if(products.length == 0){
                        productList.html('<li>None </li>');
                    }
                    else{
                        $.each(products, function(index, curObj) {
                            var link = $('<a>');
                            link.attr('href','product.jsp?cid='+curObj.cid+'&id='+curObj.id);
                            link.text(curObj.name);
                            productList.append($("<li>").html(link));
                        });
                    }

                    var pages = resp.data.pages;
                    var pageList = $('#pageUsesList');
                    pageList.html('');
                    if(pages.length == 0){
                        pageList.html('<li>None </li>');
                    }
                    else{
                        $.each(pages, function(index, curObj) {
                            var link = $('<a>');
                            link.attr('href',window.PAGES_APP_URL+'admin/pageEditor.jsp?id='+curObj.id);
                            link.text(curObj.name + (curObj.type == 'structured'?' (structured)':''));
                            pageList.append($("<li>").html(link));
                        });
                    }

                    var blocs = resp.data.blocs;
                    var blocList = $('#blocUsesList');
                    blocList.html('');
                    if(blocs.length == 0){
                        blocList.html('<li>None </li>');
                    }
                    else{
                        $.each(blocs, function(index, curObj) {
                            var link = $('<a>');
                            link.attr('href',window.PAGES_APP_URL+'admin/blocs.jsp?editBlocId='+curObj.id);
                            link.text(curObj.name);
                            blocList.append($("<li>").html(link));
                        });
                    }


                    $('#modalTagUses').modal('show');
                }
            })
            .fail(function() {
                alert("Error in getting tag uses. please try again.");
            })
            .always(function() {
                hideLoader();
            });
        }

    }

    function onChangeCheckAll(checkAll){
        $('.tagIdCheck').prop('checked',$(checkAll).prop('checked'));
        $('.folderIdCheck').prop('checked',$(checkAll).prop('checked'));
    }

    function onChangeTagLabel(input){
        var val = $(input).val();

        var saveType = $('#saveType');

        if(saveType.val() === 'add'){
            $('#tagIdField').val(val.trim()).trigger('keyup');
        }

        $(input).val(val);
    }

    function onKeyupTagId(input){
        var val = $(input).val();

        val  = val.replace(/\s+/g,"-").replace(/[^a-zA-Z0-9\-]/g,'').toLowerCase();

        while(val.startsWith("-")){
            val = val.substring(1);
        }

        $(input).val(val);
    }

    function  openMoveToModal() {
        var selectedTags = $('.tagIdCheck:checked');

        if(selectedTags.length == 0){
            bootNotify("No tag selected.","danger");
            return false;
        }
        
        $("#moveToDlg").modal("show");
        loadFoldersList($('#tagsFolderSelect'));
    }

    function loadFoldersList(folderSelect) {
        $.ajax({
            url : 'tagsFolderAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'getListForViews',
            },
        })
        .done(function (resp) {
            if (resp.status == 1) {
                if($('#tagsFolderSelect')[0].length<=1){

                    folderSelect.append('<option value="0">Root (Base folder)</option>')
                    for(let i=0;i<resp.data.length;i++) {
                        let fieldData = resp.data[i];
                        folderSelect.append('<option value="'+fieldData.id+'">'+fieldData.name+'</option>');
                    }

                    for(let i=0;i<resp.data.length;i++) {
                        let fieldData = resp.data[i];
                        if(fieldData.childFolder.length >0){
                            let optGroup = $('<optgroup class="bg-secondary" label="'+fieldData.name+'" >');
                            folderSelect.append(optGroup);
                            getChildFolder(optGroup,fieldData.childFolder);
                        }
                    }
                }
            }
            else {
                bootAlert(resp.message);
            }
        })
        .always(function () {
            // hideLoader();
        });
    }
    function getChildFolder(optGroup,childFolders){
        for(let i=0;i<childFolders.length;i++) {

            var option = $('<option>').text('>'+childFolders[i].name).attr('value', childFolders[i].id).attr('style', 'background-color:white;color:#768192;');
            optGroup.append(option);
            if(childFolders[i].childFolder.length >0){
                getChildFolder(optGroup,childFolders[i].childFolder)
            }
        }

    }

    function moveSelectedTags() {

        var selectedTags = $('.tagIdCheck:checked');

        var ids = [];
        selectedTags.each(function(index, el) {
            ids.push($(el).val());
        });
        let tagIds = ids.join(",");

        $("#moveToDlg").modal("hide");

        var moveToFoldreName = $('#tagsFolderSelect option:selected').text();
        var moveToFoldreId = $('#tagsFolderSelect').val();

        if(moveToFoldreId == ""){
            return false;
        }
        if (tagIds.length == 0) {
            bootNotify("No tag(s) selected","danger");
            return false;
        }

        let confirmMsg = "Are you sure you want to move tags to "+moveToFoldreName+" folder?";

        bootConfirm(confirmMsg, function (result) {
            if (result) {
                moveTags(tagIds, moveToFoldreId);
            }
        });

    }

    function moveTags(tagIds, moveToFoldreId) {
        if (tagIds.length <= 0) {
            return false;
        }
        //for multi value parameters to work
        var params = $.param({
            requestType: 'moveTags',
            tagIds: tagIds,
            moveToFolderId: moveToFoldreId
        }, true);

        showLoader();
        $.ajax({
            url: 'tagsFolderAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootNotify(resp.message ,"danger");
            }
            else {
                bootNotify(resp.message);
            }
        })
        .always(function () {
            hideLoader();
            refreshTagsTable();
        });
    }

</script>
</body>
</html>