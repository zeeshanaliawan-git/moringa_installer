    <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    Set rs = null;
    String siteId = parseNull(session.getAttribute("SELECTED_SITE_ID"));
    boolean active = true;
    List<Language> langsList = getLangs(Etn,siteId);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Libaries List</title>

        <style type="text/css">
            .list-group-item{
                display: list-item !important;
            }
        </style>
    </head>
   <body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Developer", ""});
        breadcrumbs.add(new String[]{"Libraries", ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
                <!-- beginning of container -->
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">List of Libraries</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <button type="button" class="btn btn-primary mr-2"
                                onclick="goBack('blocTemplates.jsp')">Back</button>
                        <button type="button" class="btn btn-primary mr-2"
                                    onclick="refreshLibTable();" title="Refresh">
                                    <i data-feather="refresh-cw"></i></button>
                        <button class="btn btn-success mr-2"
                            type="button" onclick="showAddEditLibrary('add')">Add a Library</button>
                        <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Libraries');" title="Add to shortcuts">
                            <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                        </button>
                    </div>
                </div>
                <!-- row -->
                <table class="table table-hover table-vam" id="librariesTable" style="width: 100%;">
                    <thead class="thead-dark">
                        <tr>
                            <th scope="col"><input type="checkbox" class="d-none d-sm-block" id="checkAll"></th>
                            <th scope="col">Name</th>
                            <th scope="col">Nb Files</th>
                            <th scope="col">Nb Uses</th>
                            <th scope="col">Theme</th>
                            <th scope="col">Last Changes</th>
                            <th scope="col" style="min-width:150px">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- loaded by ajax -->
                    </tbody>
                </table>
                <div id="actionsCellTemplate" class="d-none" >
                    <button class="btn btn-sm btn-primary " type="button"
                        onclick="showAddEditLibrary('edit','#ID#')">
                        <i data-feather="settings"></i></button>
                    <button class="btn btn-sm btn-danger " onclick='deleteLibrary("#ID#")'>
                        <i data-feather="x"></i></button>
                </div>
                <!-- row-->
                <!-- /end of container -->
            </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
        </div>

        <!-- Modal -->
        <div class="modal fade" id="modalAddEditLibrary" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
                <div class="modal-content">

                    <div class="modal-header">
                        <h5 class="modal-title"></h5>
                        <button type="button" class="close closeBtn" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="addEditLibraryForm" action="" novalidate>
                            <input type="hidden" name="requestType" value="saveLibrary">
                            <input type="hidden" name="id" value="">
                            <div class="errorMsg invalid-feedback" style="display: block;"></div>
                            <div class="form-group row">
                                <label class="col col-form-label">Name</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control"
                                        name="name" maxlength="100" required/>
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                   </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col">
                                    <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-1"
                                        href="#dummy" role="button" >
                                        Files</button>
                                </div>
                            </div>

                            <div>
                                <div class="text-muted">
                                    <small>( Drag n drop to reorder and move files in the lists )</small>
                                </div>
                                <div class="pagePathMainDiv pageOnly">
                                    <ul class="nav nav-tabs pagePathTabs" role="tablist">
                                        <%
                                            active = true;
                                            for (Language lang: langsList) {
                                        %>
                                                <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
                                                    <a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
                                                    data-toggle="tab" href="#pathPrefixlangTabContent_<%=lang.getLanguageId()%>"
                                                    role="tab" aria-controls="<%=lang.getLanguage()%>"
                                                    aria-selected="true"><%=lang.getLanguage()%>
                                                    </a>
                                                </li>
                                        <%
                                                active = false;
                                            }
                                        %>
                                    </ul>

                                    <div class="tab-content">
                                        <%
                                            active = true;
                                            for (Language lang: langsList) {
                                        %>
                                                <div class='tab-pane langTabContent <%=(active)?"show active":""%>'
                                                    id="pathPrefixlangTabContent_<%=lang.getLanguageId()%>"
                                                    role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                                    <div class="row mt-4">
                                                        <div class="form-group row mb-3 col-12">
                                                            <div class="input-group col">
                                                                <select name="filesSelect_<%=lang.getLanguageId()%>" class="custom-select filesSelect">
                                                                    <option value="">Choose a file ...</option>
                                                                </select>
                                                                <div class="input-group-append">
                                                                    <button class="btn btn-success" type="button"
                                                                    onclick="addSelectedFile(<%=lang.getLanguageId()%>)">Add File</button>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="col-6">
                                                            <div class="card">
                                                                <div class="card-header">
                                                                    <span class="font-weight-bold">Body</span>
                                                                </div>
                                                                <div class="card-body py-0 pr-0" style="">
                                                                    <ol id="bodyFilesList_<%=lang.getLanguageId()%>" class="filesList bodyFilesList_<%=lang.getLanguageId()%> sortable2 list-group m-2" style="min-height: 200px;">

                                                                    </ol>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-6">
                                                            <div class="card">
                                                                <div class="card-header">
                                                                    <span class="font-weight-bold">Head</span>
                                                                </div>
                                                                <div class="card-body py-0 pr-0" style="">
                                                                    <ol id="headFilesList_<%=lang.getLanguageId()%>" class="filesList headFilesList_<%=lang.getLanguageId()%> sortable2 list-group m-2" style="min-height: 200px;">

                                                                    </ol>
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
                                </div>
                            </div>

                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary closeBtn" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="saveLibrary()" >Save</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->
<script type="text/javascript">
    // ready function
    $(function() {

        $('#librariesTable tbody').tooltip({
            placement : 'bottom',
            html:true,
            selector:".custom-tooltip"
        });
        
        initDataTable();

        $('#modalAddEditLibrary').on('show.bs.modal', function(event){

            var modal = $(this);

            showLoader();
            $.ajax({
                url: 'filesAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : 'getFilesListForLibrary',
                },
            })
            .done(function(resp) {
                if(resp.status == 1){
                    $.each(resp.data.files, function(index, file) {
                        var opt  = $("<option>").attr('value',file.id).text(file.file_name);
                        modal.find('.filesSelect').append(opt);
                    });
                }
            })
            .fail(function(w) {
                bootAlert("Error contacting server.");
            })
            .always(function() {
                hideLoader();
            });
        });

        $('#modalAddEditLibrary').on('hide.bs.modal', function(){
            var modal = $(this);
            modal.find(".filesSelect").html("");
        });
    
        Array.from(document.getElementsByClassName("filesList")).forEach(ele => {
            try{
                Sortable.create(ele,
                    {
                        animation:10,
                        group:{
                            name:'shared'
                        }
                    }
                );
            } catch (error)
            {
                console.error("Error creating Sortable:",error);
            }
        });
        
    });

    function initDataTable(){

        window.dataTable = $('#librariesTable')
        .DataTable({
            responsive: true,
            pageLength : 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function(data, callback, settings){
                getList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
                { "data": "id"  , className : "d-none" },
                { "data": "name" },
                { "data": "nb_files" },
                { "data": "nb_uses" },
                { "data": "theme_name" },
                { "data": "updated_ts" },
                { "data": "actions", className : "dt-body-right" },
            ],
            columnDefs : [
                { targets : [0,2,3,4,5,5] , searchable : false},
                { targets : [0,-1] , orderable : false},
				{ targets : [1], render: _hEscapeHtml},
                { targets : [5] ,
                    render: function ( data, type, row ) {
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
                        }
                        else {
                            let updatedText = data,toolTipText="";
                            if(row.updatedby) toolTipText += " Last change: By  " + row.updatedby;

                            updatedText +=' <a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="'+toolTipText+'">'+
                                feather.icons.info.toSvg()+
                            '</a>';  
                            return updatedText ;
                        }
                    }
                },
                { targets : [4] ,
                    render: function ( data, type, row, meta ) {
                    var badge_color = "warning";
                        var theme = "Local"
                        if(data.length > 0){
                            badge_color = 'success';
                            theme = data+" V"+row.theme_version;
                        }
                        return '<span class="badge badge-'+badge_color+'">'+theme+'</span>';
                    }
                },
            ],
            createdRow : function ( row, data, index ) {
                $(row).data('lib-data',data);
            },
        });
    }

    function getList(data, callback, settings){
        $.ajax({
            url: 'librariesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getList'
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.libraries;
                var actionTemplate = $('#actionsCellTemplate');
                $.each(data, function(index, val) {
                    if(parseInt(val.theme_id) > 0){
                        actionTemplate.find(".btn-danger").attr("disabled" , true);
                    } else{
                        actionTemplate.find(".btn-danger").attr("disabled" ,false);
                    }
                    var curId = val.id;
                    val.actions = strReplaceAll(actionTemplate.html(), "#ID#", curId);
                });
            }
            callback( { "data" : data } );
        })
        .fail(function() {
            callback( { "data" : [] } );
        })

    }

    function refreshLibTable(){
        window.dataTable.ajax.reload(null,false);
    }

    function showAddEditLibrary(type, libId){
        var modal = $('#modalAddEditLibrary');
        var form = $('#addEditLibraryForm');
        form.get(0).reset();
        form.removeClass('was-validated');
        form.find('[name=id]').val('');
        modal.find(':input:not(.closeBtn)').prop("disabled", false);

        var errorMsg = modal.find('.errorMsg');
        errorMsg.html('');
        <%
            for (Language lang: langsList) {
        %>
            if(type === "edit"){
                getLibraryInfo(modal,form, libId,'<%=lang.getLanguageId()%>');
            }
            else{
                modal.find('.modal-title').text("Add a new file library ");
                modal.find('.bodyFilesList_<%=lang.getLanguageId()%>').html('');
                modal.find('.headFilesList_<%=lang.getLanguageId()%>').html('');
                
                modal.modal('show');
            }
        <%
            }
        %>
    }

    function addSelectedFile(lang_id){
        var modal = $('#modalAddEditLibrary');

        var filesSelect = modal.find('[name=filesSelect_'+lang_id+']');

        var fileId  = filesSelect.val();
        if(fileId == ""){
            return false;
        }
        
        var bodyFilesList = modal.find('.bodyFilesList_'+lang_id);
        var headFilesList = modal.find('.headFilesList_'+lang_id);

        var isExist = false;
        bodyFilesList.add(headFilesList).find('li').each(function(index, li) {
            if($(li).data('fileId') == fileId){
                isExist = true;
                return false;
            }
        });
        if(isExist){
            return;
        }

        var fileName = filesSelect.find('option:selected').text();

        addLibraryFileItem(fileId, fileName, bodyFilesList);
    }

    function addLibraryFileItem(fileId, fileName, listEle){

        var li  = $('<li>'+fileName+'</li>');

        li.data('file-id', fileId);

        var li = $('<li class="list-group-item list-group-item-action list-group-item-success">');
        li.data('fileName',fileName).data('fileId',fileId).text(fileName)
            .append('<button type="button" class="close" onclick="removeListItem(this);"><span >&times;</span></button>');

        listEle.append(li);
    }

    function removeListItem(btn){
        $(btn).parents('li:first').remove();
    }

    function getLibraryInfo(modal, form, libId,langId){
        showLoader();
        $.ajax({
            url: 'librariesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getLibraryInfo',
                id : libId,
                langId:langId,
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                var libData = resp.data.library;

                if(libData.theme_status == '<%=Constant.THEME_LOCKED%>' && <%=!isSuperAdmin(Etn)%>){
                    modal.find(':input:not(.closeBtn)').prop("disabled", true);
                }

                modal.find('.modal-title').text("Edit library : "+libData.name);

                form.find('[name=id]').val(libData.id);
                form.find('[name=name]').val(libData.name);
                
                var bodyFilesList = modal.find('.bodyFilesList_'+langId);
                var headFilesList = modal.find('.headFilesList_'+langId);

                bodyFilesList.html('');
                headFilesList.html('');
                $.each(libData.files, function(index, file) {
                    if(file.page_position == 'head'){
                        addLibraryFileItem(file.id, file.name, headFilesList);
                    }
                    else{
                        addLibraryFileItem(file.id, file.name, bodyFilesList);
                    }
                });

                modal.modal('show');
            }
        })
        .fail(function() {
            bootAlert("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function saveLibrary(){
        var modal = $('#modalAddEditLibrary');
        var form = $('#addEditLibraryForm');

        var errorMsg = modal.find('.errorMsg');
        errorMsg.html('');

        if (form.get(0).checkValidity() === false) {
            form.addClass('was-validated');
            return;
        }

        var libId = form.find('[name=id]');
        var libName = form.find('[name=name]');

        showLoader();

        let defaultBodyFiles=[];
        let defaultHeadFiles=[];
        let reqarray=[];

        let headObj={};
        

        <%
            for (Language lang: langsList) {
                String langId = lang.getLanguageId();
        %>
                var bodyFilesList = modal.find('.bodyFilesList_<%=langId%>');
                var headFilesList = modal.find('.headFilesList_<%=langId%>');

                var bodyFiles = [];
                var headFiles = [];
                
                bodyFilesList.find('li').map(function(i,li) {
                    bodyFiles.push($(li).data('fileId'));
                });

                headFilesList.find('li').map(function(i,li) {
                    headFiles.push($(li).data('fileId'));
                });

                headObj["lang"]='<%=langId%>';
                headObj["body"]=bodyFiles.join(",");
                headObj["head"]=headFiles.join(",");
                reqarray.push(headObj);
                headObj={};
        <%
            }
        %>

        $.ajax({
            url: 'librariesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'saveLibrary',
                id : libId.val(),
                name : libName.val(),
                bodyFiles : JSON.stringify(reqarray),
            },
        })
        .done(function(resp) {
            if(resp.status !== 1){
                bootAlert("Error adding files in library.");
            }else{

                refreshLibTable();
                modal.modal('hide');
                bootNotify("Library saved.");
            }
        })
        .fail(function() {
            bootAlert("Error adding files in library.");
        })

        hideLoader();
    }

    function deleteLibrary(id, confirmed){

        if (!confirmed) {
            bootConfirm("Are you sure?", function(result){
                if(result){
                    deleteLibrary(id, true);
                }
            });
            return false;
        }

        showLoader();
        $.ajax({
            url: 'librariesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'deleteLibrary',
                id : id,
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                bootNotify("Library deleted.");
                refreshLibTable();
            }
            else{
                bootAlert(resp.message);
                refreshLibTable();
            }
        })
        .fail(function() {
            bootAlert("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });
    }


</script>
    </body>
</html>