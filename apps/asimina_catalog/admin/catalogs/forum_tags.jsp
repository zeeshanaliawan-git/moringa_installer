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
%>
<!DOCTYPE html>
<html>
<head>
    <title>List of Forum Tags</title>
    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
</head>
	<%
	breadcrumbs.add(new String[]{"Content", ""});
	breadcrumbs.add(new String[]{"Forum Tags", ""});
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
                    <h1 class="h2">List of Forum Tags</h1>
                </div>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-primary mr-1"
                        onclick="goBack('pages.jsp')">Back</button>
                    <button class="btn btn-danger mr-2"
                        onclick="deleteSelectedTags()">Delete</button>
                    <button class="btn btn-success mr-2"
                        onclick="addTag()">Add a tag</button>

                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Forum Tags');" title="Add to shortcuts">
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
                            onclick='deleteTag(this)'>
                            <i data-feather="x"></i></button>
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

<script>
    //ready function
    $(function(){
        initTagsTable();


        $('#formAddEditTag').submit(function(event) {
            event.preventDefault();
            event.stopPropagation();
            onSaveTag();
        });

        $("#tagLabelField").on('keydown', function(event) {
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
            order : [[1,'asc']],
            columns : [
                { "data": "tag_id" },
                { "data": "tag_name" },
                { "data": "tag_id" },
                { "data": "nb_uses" },
                { "data": "created_on" },
                { "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
                { targets : [0,5] , searchable : false},
                { targets : [0,5] , orderable : false},
				{ targets : [1,2], render: _hEscapeHtml},
                { targets : [0] ,
                    render: function ( data, type, row ) {
                        return '<input type="checkbox" class="tagIdCheck" name="tag_id" value="'+data+'" >';
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
            url: 'forum_tags_ajax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getTagsList',
                id:'<%=edit_id%>'
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.tags;
                var actionTemplate = $('#actionsCellTemplate').html();
                $.each(data, function(index, val) {
                    var curId = val.id;
                    val.actions = strReplaceAll(actionTemplate, "#ID#", curId);
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

    function editTag(btn){

        var tr = $(btn).parents('tr.tagRow:first');
        var tagData = tr.data('tag-data');

        var modal = $('#modalAddEditTag');
        var form = $('#formAddEditTag');

        form.get(0).reset();

        form.find('[name=type]').val('edit');

        modal.find('.errorMsg').html('');

        modal.find('modal-title').text("Edit tag");


        form.find('[name=tagId]').val(tagData.tag_id).prop('readonly',true);
        form.find('[name=label]').val(tagData.tag_name);

        modal.modal('show');
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
            url: 'forum_tags_ajax.jsp', type: 'POST', dataType: 'json',
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

    function refreshTagsTable(){
        window.tagsTable.ajax.reload(null,false);
    }

    function deleteTag(btn){
        var tr = $(btn).parents('tr.tagRow:first');
        var tagData = tr.data('tag-data');
        var ids = [tagData.tag_id];

        var msg = "Are you sure you want to delete this tag?";
        bootConfirm(msg,function(result){
            if(result){
               deleteTags(ids);
            }
        });
    }

    function deleteSelectedTags(){
        var selectedTags = $('.tagIdCheck:checked');

        if(selectedTags.length == 0){
            bootNotify("No tag selected.","danger");
            return false;
        }

        var msg = "Are you sure you want to delete " + selectedTags.length + " tags?";
        bootConfirm(msg,function(result){
            if(result){
                var ids = [];
                selectedTags.each(function(index, el) {
                    ids.push($(el).val());
                });

               deleteTags(ids);
            }
        });
    }


    function deleteTags(ids){
        var idsStr = ids.join(',');
        showLoader();
        $.ajax({
            url: 'forum_tags_ajax.jsp', type: 'POST', dataType: 'json',
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

    function onChangeCheckAll(checkAll){
        $('.tagIdCheck').prop('checked',$(checkAll).prop('checked'));
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

</script>
</body>
</html>