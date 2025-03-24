<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%
    final String STRUCTURED_CONTENT = "content";
    final String STRUCTURED_PAGE = "page";

    String structureType = STRUCTURED_CONTENT;

    String q = "";
    Set rs = null;
    // String siteId = getSiteId(session);//debug

    String folderType = Constant.FOLDER_TYPE_CONTENTS;
    String folderUuid = parseNull(request.getParameter("folderId"));
    String editId = parseNull(request.getParameter("id"));
    String folderId = "0";
    String folderName = "";
    int folderLevel = 0;
    String parentFolderId = "";
    String parentFolderName = "";



    if (folderUuid.length() > 0) {
        q = "SELECT f.id, f.name, f.uuid, f.folder_level, IFNULL(pf.uuid,'') AS parent_folder_id, pf.name as parent_folder_name"
            + " FROM structured_contents_folders f "
            + " LEFT JOIN structured_contents_folders pf ON pf.id = f.parent_folder_id "
            + " WHERE f.uuid = " + escape.cote(folderUuid)
            + " AND f.site_id = " + escape.cote(getSiteId(session));
        rs = Etn.execute(q);
        if (rs.next()) {
            folderId = rs.value("id");
            folderName = parseNull(rs.value("name"));
            folderLevel = parseInt(rs.value("folder_level"));
            parentFolderName = parseNull(rs.value("parent_folder_name"));
            parentFolderId = parseNull(rs.value("parent_folder_id"));
        }
        else {
            response.sendRedirect("structuredContents.jsp");
        }
    }

    String backUrl = "structuredContents.jsp" + (parentFolderId.length() > 0 ? "?folderId=" + parentFolderId : "");

    String catalogId = parseNull(request.getParameter("cid"));

    String editorUrl = "structuredContentEditor.jsp";
    String templateType = Constant.TEMPLATE_STRUCTURED_CONTENT;
    boolean active = true;
    List<Language> langsList = getLangs(Etn,session);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title>Structured data list</title>

    <style type="text/css">
       .table-success .deleteBtn, .table-warning .deleteBtn {
            display: none !important;
        }

        .table-danger .unpublishBtn {
            display: none !important;
        }
        .pageOnly{
            display: none;
        }
        .dataTables_length select {
              min-width: 75px !important;
        }

    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Content", ""});
        if(parentFolderId.length()>0){
            breadcrumbs.add(new String[]{"Structured data", "structuredContents.jsp"});
            breadcrumbs.add(new String[]{parentFolderName, "pages.jsp?folderId="+ parentFolderId});
            breadcrumbs.add(new String[]{folderName, ""});

        } else if(folderUuid.length()>0){
            breadcrumbs.add(new String[]{"Structured data", "structuredContents.jsp"});
            breadcrumbs.add(new String[]{folderName, ""});
        } else{
            breadcrumbs.add(new String[]{"Structured data", ""});
        }
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
       
        <!-- beginning of container -->

            <input type="hidden" id="folderUuid" name="" value="<%=folderUuid%>"/>
            <input type="hidden" id="folderId" name="" value="<%=folderId%>"/>
            <input type="hidden" id="folderLevel" name="" value="<%=folderLevel%>"/>
            <input type="hidden" id="folderType" name="" value="<%=folderType%>"/>

            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                        <h1 class="h2">Structured data</h1>
                        <div class="btn-toolbar mb-2 mb-md-0">
                            <button type="button" hidden="true" class="btn btn-danger mr-2"
                                    onclick="deleteSelectedContents();">Delete
                            </button>
                            <div class="btn-group mr-2">
                                <button class="btn btn-danger" type="button"
                                        onclick="onPublishUnpublish('publish')">Publish
                                </button>
                                <button class="btn btn-danger" type="button"
                                        onclick="onPublishUnpublish('unpublish')">Unpublish
                                </button>
                            </div>

                            <button type="button" class="btn btn-primary mr-2"
                                    onclick="goBack('<%=backUrl%>')">Back
                            </button>

                            <button type="button" class="btn btn-primary mr-2"
                                    onclick="refreshDataTable();" title="Refresh"><i data-feather="refresh-cw"></i>
                            </button>

                                <button type="button" class="btn btn-success mr-2"
                                    onclick="openMoveToModal();" title="Move to">Move to
                            </button>

                            <div class="btn-group" role="group">
                                <button type="button" class="btn btn-success" id="addFolderBtn"
                                        onclick="openFolderModal()" <% if (folderLevel == 2) {%> disabled <%}%> >Add a
                                    folder
                                </button>
                                <a class="btn btn-success" title="Add a content"
                                   href="<%=editorUrl%>?folderId=<%=folderUuid%>">
                                    Add a content
                                </a>
                            </div>
                            <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Structured data');" title="Add to shortcuts">
                                <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                            </button>

                        </div>
            </div><!-- row -->
            <div class="row">
                <div class="col">
                    <table class="table table-hover table-vam" id="contentsTable" style="width:100%;">
                        <thead class="thead-dark">
                        <tr>
                            <th scope="col">
                                <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                            </th>
                            <th scope="col">&nbsp;<!--type icon --></th>
                            <th scope="col">Name</th>
                            <th scope="col">Type</th>
                            <th scope="col">Nb Items</th>
                            <th scope="col">Last changes</th>
                            <th scope="col">Actions</th>

                        </tr>
                        </thead>
                        <tbody>
                        <!-- loaded by ajax -->
                        </tbody>
                    </table>
                    <div id="actionsCellTemplate" class="d-none">
                        <a class="btn btn-sm btn-primary " title="Edit"
                           href="<%=editorUrl%>?folderId=<%=folderUuid%>&id=#ID#">
                            <i data-feather="edit"></i>
                        </a>

                        <button class="btn btn-sm btn-primary " title="Copy"
                                onclick="copyContent(this)">
                            <i data-feather="copy"></i>
                        </button>

                        <button class="btn btn-sm btn-danger deleteBtn" title="Delete"
                                onclick="deleteContent('#ID#')">
                            <i data-feather="trash-2"></i></button>

                        <button class="btn btn-sm btn-danger unpublishBtn" title="Unpublish"
                                onclick='unpublishContent(this)'>
                            <i data-feather="x"></i></button>

                    </div>
                    <div id="actionsCellTemplateFolder" class="d-none">
                        <a class="btn btn-sm btn-primary openFolder" title="Open"
                           href="structuredContents.jsp?folderId=#FOLDERUUID#">
                            <i data-feather="list"></i>
                        </a>
                        <button class="btn btn-sm btn-primary " title="Settings"
                                onclick="editFolder('#FOLDERID#')">
                            <i data-feather="settings"></i>
                        </button>
                        <button class="btn btn-sm btn-primary " title="Copy"
                                onclick="openCopyFolderModal(this, '#FOLDERID#')">
                            <i data-feather="copy"></i></button>

                        <button class="btn btn-sm btn-danger" title="Delete"
                                onclick="deleteFolder('#FOLDERID#')">
                            <i data-feather="trash-2"></i></button>

                    </div>
                </div>
            </div><!-- row-->

        <!-- container -->
        <!-- /end of container -->
    </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<!-- Modals -->
<div class="modal fade" id="modalCopyContent" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-slideout" role="document">
        <div class="modal-content">
            <form id="formCopyContent" action="" novalidate onsubmit="return false;">
                <input type="hidden" name="requestType" value="copyContent">
                <input type="hidden" name="contentId" value="">
                <input type="hidden" name="folderType" value="">
                <input type="hidden" name="structuredType" value="<%=Constant.STRUCTURE_TYPE_CONTENT%>">

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
                                </div>
                            </div>

                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="onCopyContentSave()">Save</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<!-- move to modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='moveToDlg' >
    <div class="modal-dialog modal-md" role="document">
        <div class="modal-content">
            <div class="modal-header" style='text-align:left'>
                <h5 class="modal-title">Move selected Contents</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">&times;</span>
                    </button>
            </div>
            <div class="modal-body">
                <div>
                    <div class="row">
                        <div class="form-group col-sm-12">
                            <select name="folder" class="custom-select" id="contentsFolderSelect">
                                <option value="">-- list of folders --</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group  col-sm-3">
                            <button type="button" class="btn btn-success" onclick="moveSelectedContents()">Submit</button>
                        </div>
                    </div>
                </div>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>

<%@ include file="foldersAddEdit.jsp" %>
<%@ include file="structuredContentsPublish.jsp" %>

<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>/';
    $ch.structureType = '<%=structureType%>';
    // ready function
    $(function () {
        $('#contentsTable tbody').tooltip({
            placement: 'bottom',
            html: true,
            selector: ".custom-tooltip"
        });

        initDataTable();

        $ch.actionCellTemplate = $('#actionsCellTemplate').html();
        $ch.actionsCellTemplateFolder = $('#actionsCellTemplateFolder').html();

        <%if(editId.length()>0){ %>
            editFolder('<%=editId%>');
        <%}%>
    });

    function initDataTable() {

        window.contentsTable = jQuery('#contentsTable')
        .DataTable({
            // dom : "<flipt>",
            // deferRender : true,
            responsive: true,
            "lengthMenu": [[1000, 3000, 5000, 10000,-1], [1000, 3000, 5000, 10000, "All"]],
            pageLength: 10000,

            ajax: function (data, callback, settings) {
                getContentsList(data, callback, settings);
            },
            order: [[1, 'asc'], [2, 'asc']],
            columns: [
                {"data": "id"},
                {"data": "row_type", className: ""},
                {"data": "name", className: "name contentName"},
                {"data": "row_type", className: "text-capitalize"},
                {"data": "nb_items", className: ""},
                {"data": "updated_ts"},
                {"data": "actions", className: "dt-body-right text-nowrap"},
            ],
            columnDefs: [
                {targets: [-1], searchable: false},
                {targets: [0, -1], orderable: false},
                {
                    targets: [0],
                    render: function (data, type, row) {
                        if (type == 'display') {
                            return '<input type="checkbox" class="idCheck d-none d-block ' + row.row_type + '" ' +
                                ' name="id" onclick="onCheckItem(this)" value="' + data + '" >';
                        }
                        else {
                            return data;
                        }
                    }
                },
                {
                    targets: [1],
                    render: function (data, type, row) {
                        if (type === 'display') {
                            if (data == 'folder') {
                                return feather.icons.folder.toSvg({class: 'feather-20', fill: '#aaa'});
                            }
                            else {
                                return feather.icons.file.toSvg({class: 'feather-20', fill: "#fff"});
                            }
                        }
                        else if (type === 'sort') {
                            return (data == 'folder') ? 0 : 1;
                        }
                        else {
                            return data;
                        }
                    }
                },
                 {
                    targets: [2],
                    render: function (data, type, row) {
                        return '<strong>'+data+'</strong>'
                    }
                },
                {
                    targets: [3],
                    render: function (data, type, row) {
                        if (data !== 'folder') {
                            return data + " : " + row.item_type;
                        }
                        else {
                            return data;
                        }
                    }
                },
                {
                    targets: [4],
                    render: function (data, type, row) {
                        if (type == 'display') {
                            if (row.row_type == 'folder') {
                                return '<span class="badge badge-secondary">' + data + '</span>';
                            }
                            else {
                                return '-';
                            }
                        }
                        else {
                            return data;
                        }
                    }
                },
                {
                    targets: [-2],
                    render: function (data, type, row) {
                        if (type == 'sort' && data.trim().length > 0) {
                            return getMoment(data).unix();
                        }
                        else {
                            var html = data;
                            var toolTipText = "";

                            if (data && row.updated_by)
                                toolTipText += "Last change: By " + row.updated_by;

                            if (row.published_ts)
                                toolTipText += "<br>Last publication: " + row.published_ts;

                            if (row.to_publish_ts)
                                toolTipText += "<br>Next publication: " + row.to_publish_ts;

                            html += ' ' +
                                '<a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="' + toolTipText + '">' +
                                feather.icons.info.toSvg() +
                                '</a>';
                            return html;
                        }

                    }
                },
            ],
            select: {
                style: 'multi',
                className: '',
                selector: 'td.noselector' //dummyselector
            },
            createdRow: function (row, data, index) {
                $(row).data('content-id', data.id);
                var pubStatus = data.ui_status;
                let status ;
                switch (pubStatus) {
                    case 'published':
                        status='success'; break;
                    case 'unpublished':
                        status='danger'; break;
                    case 'changed':
                        status='warning'; break;
                    default:
                        break;
                }
                $(row).addClass('table-' + status);
            },
        });
    }

    function onCheckItem(check) {
        check = $(check);
        var row = window.contentsTable.row(check.parents('tr:first'));

        if (check.prop('checked')) {
            row.select();
        }
        else {
            row.deselect();
        }
    }

    function onChangeCheckAll(checkAll) {
        var isChecked = $(checkAll).prop('checked');

        if (isChecked) {
            //select only visible
            var allChecks = $(window.contentsTable.table().body()).find('.idCheck');
        }
        else {
            //un select all
            var allChecks = window.contentsTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked', isChecked);

        allChecks.each(function (index, el) {
            $(el).triggerHandler('click');
        });

    }

    function getContentsList(data, callback, settings) {
        // showLoader();
        $.ajax({
            url: 'structuredContentsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType: 'getList',
                catalogId: '<%=catalogId%>',
                folderId: $('#folderUuid').val()
            },
        })
        .done(function (resp) {
            var data = [];
            if (resp.status == 1) {
                data = resp.data.contents;
                $.each(data, function (index, val) {
                    var curId = val.id;

                    if (val.row_type == "folder") {
                        val.actions = strReplaceAll($ch.actionsCellTemplateFolder, "#FOLDERID#", val.id);
                        val.actions = strReplaceAll(val.actions, "#FOLDERUUID#", val.uuid);
                    }
                    else {
                        val.actions = strReplaceAll($ch.actionCellTemplate, "#ID#", val.id);
                    }
                });
            }
            callback({"data": data});
        })
        .fail(function () {
            callback({"data": []});
        })
        .always(function () {
            // hideLoader();
        });

    }

    function copyContent(button) {
        var isPage = $ch.structureType == 'page';

        button = $(button);
        var modal = $("#modalCopyContent");

        var form = $('#formCopyContent');
        form.get(0).reset();
        form.removeClass('was-validated');

        if (isPage) {
            form.find('.pagePathRow').show();
            form.find('[name=path]').val();
        }
        else {
            form.find('.pagePathRow').hide();
            form.find('[name=path]').val("dummy");
        }
        form.find('[name=folderType]').val($('#folderType').val());

        var tr = button.parents('tr:first');
        var contentId = tr.data('content-id');
        var contentName = tr.find('td.contentName').text();

        form.find('[name=contentId]').val(contentId);
        form.find('[name=contentName]').val(contentName);

        modal.modal('show');
    }

    function onCopyContentSave() {
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
                $('#modalCopyContent').modal('hide');
            }
        })
        .always(function () {
            hideLoader();
        });

    }

    function deleteContent(id) {

        bootConfirm("Are you sure you want to delete this " + $ch.structureType + " ?",
            function (result) {
                if (!result) return;

                var idsList = [{id: id , type: "content"}];
                deleteContents(idsList);

            });
    }

    function deleteSelectedContents() {

        var rows = window.contentsTable.rows({selected: true}).nodes().to$().find(".idCheck");
        var foldersCount = 0;
        var contentCount = 0;

        var deletedContents = [];

        if (rows.length == 0) {
            bootNotify("No " + $ch.structureType + " selected");
            return false;
        }
        var publishedCount = 0;

        $.each(rows, function (index, row) {

            if($(row).hasClass("folder")){
                deletedContents.push({id: $(row).val(), type: "folder"});
                foldersCount += 1;
            }else {
                deletedContents.push({id: $(row).val(), type: "content"});
                contentCount += 1;
                if (!$(row).closest('tr').hasClass('table-danger')) {
                    publishedCount += 1;
                }
            }
        });

        var confirmMsg = "";
        if(contentCount>0){
           confirmMsg += contentCount + " " + $ch.structureType + "(s)";
        }
        if(foldersCount>0){
            if(confirmMsg.length>0){
                confirmMsg += " and ";
            }
            confirmMsg += foldersCount + " folder(s)";
        }
           confirmMsg += " are selected. Are you sure you want to delete them? this action is not reversible.";

        if (publishedCount > 0) {
            confirmMsg += "<br>Note: " + publishedCount + " " + $ch.structureType + "(s) are published. Published " + $ch.structureType + "s will not be deleted.";
        }

        bootConfirm(confirmMsg, function (result) {
            if (result) {
                deleteContents(deletedContents);
            }
        });
    }

    function deleteContents(contents) {
        if (contents.length <= 0) {
            return false;
        }

        //for multi value parameters to work
        var params = $.param({
            requestType: 'deleteContents',
            contents: JSON.stringify(contents)
        }, true);

        showLoader();
        $.ajax({
            url: 'structuredContentsAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootAlert(resp.message + " ");
            }
            else {
                bootNotify(resp.message);
            }
            refreshDataTable();
        })
        .always(function () {
            hideLoader();
        });

    }

    function openMoveToModal() {
        var contentRows = window.contentsTable.rows({selected: true}).nodes().to$().find(".idCheck");
        if (contentRows.length == 0) {
            bootNotify("No content or folder selected");
            return false;
        }
        $("#moveToSelection").val("");
        $("#moveToDlg").modal("show");
        loadFoldersList($('#contentsFolderSelect'), '<%=Constant.FOLDER_TYPE_CONTENTS%>');
    }

    function moveSelectedContents() {
        $("#moveToDlg").modal("hide");

        var moveToFoldreId = $('#contentsFolderSelect').val();
        var moveToFoldreName = $('#contentsFolderSelect option:selected').text();
        var contentRows = window.contentsTable.rows({selected: true}).nodes().to$().find(".idCheck");

        if (contentRows.length == 0) {
            bootNotify("No content or folder selected");
            return false;
        }
        var foldersCount = 0;
        var contentsCount = 0;

        var contents = [];

        $.each(contentRows, function (index, row) {
            if($(row).hasClass("folder")){
                contents.push({id: $(row).val(), type: "folder"});
                foldersCount += 1;
            }else {
                contents.push({id: $(row).val(), type: "content"});
                contentsCount += 1;
            }
        });

        var confirmMsg = "";
        if(contentsCount >0){
            confirmMsg += " "+contentsCount + " content(s)";
        }
        if(foldersCount>0){
            if(confirmMsg.length>0){
                confirmMsg += " and ";
            }
            confirmMsg += " "+foldersCount + " folder(s)";
        }
        confirmMsg += " are selected. Are you sure you want to move them to "+moveToFoldreName+" folder?";

        bootConfirm(confirmMsg, function (result) {
            if (result) {
                moveContents(contents, moveToFoldreId)
            }
        });
    }

    function moveContents(contents, moveToFoldreId) {
        if (contents.length <= 0) {
            return false;
        }
        //for multi value parameters to work
        var params = $.param({
            requestType: 'moveContents',
            contents: JSON.stringify(contents),
            moveToFolderId: moveToFoldreId
        }, true);

        showLoader();
        $.ajax({
            url: 'structuredContentsAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootAlert(resp.message + " ");
            }
            else {
                bootNotify(resp.message);
            }
            refreshDataTable();
        })
        .always(function () {
            hideLoader();
        });
    }

    function unpublishContent(btn) {
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var checkInput = tr.find('.idCheck');
        checkInput.prop('checked', true);
        onCheckItem(checkInput);
        onPublishUnpublish('unpublish');
    }

    function refreshDataTable() {
        window.contentsTable.ajax.reload(function () {
            $('#checkAll').triggerHandler('change');
        }, false);
    }

    function refreshPublishUnpublishStatus(action, responseStatus) {
        refreshDataTable();
    }

</script>
</body>
</html>