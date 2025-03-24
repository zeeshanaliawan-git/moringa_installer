<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp"%>
<%
    String[] fontss =  PagesUtil.ALLOWED_FILETYPES.get("fonts");
    String[] fontsss =  PagesUtil.ALLOWED_FILETYPES.get("fonts");
    
    String[] fonts =  PagesUtil.ALLOWED_FILETYPES.get("fonts");

    for(String font:  fonts){
        System.out.println(font);
    }
    boolean isSuperAdmin =  isSuperAdmin(Etn);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title>Themes</title>
    <style type="text/css">

        .table-success .deleteBtn, .table-warning .deleteBtn {
            display: none !important;
        }

        .table-danger .unpublishBtn {
            display: none !important;
        }
        .table-success .syncBtn, .table-danger .syncBtn{
            display: none !important;
        }
    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Themes",""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
        <!-- beginning of container -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Themes</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <div class="col-12">
                        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                            <div class="btn-toolbar mb-2 mb-md-0">
                                <button type="button" class="btn btn-primary mr-2"  onclick="window.history.back()"
                                        >Back
                                </button>
                                <div class="btn-group mr-2">
                                    <button class="btn btn-success" type="button"
                                            onclick="onPublishTheme(false)">Publish
                                    </button>
                                </div>
                                <div class="btn-group mr-2">
                                    <button class="btn btn-success" type="button"
                                            onclick="openThemeModal()">Add a Theme
                                    </button>
                                </div>
                                <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Themes');" title="Add to shortcuts">
                                    <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div><!--head row -->
            <div class="row">
                <div class="col">
                    <form id="downloadThemeForm" action="downloadTheme.jsp" method="POST">
                        <input name="id" type="hidden"/>
                    </form>
                    <table class="table table-hover table-vam" id="themesTable" style="width:100%;">
                        <thead class="thead-dark">
                        <tr>
                            <th scope="col">
                            </th>
                            <th scope="col">Theme</th>
                            <th scope="col">Version</th>
                            <th scope="col">Status</th>
                            <th scope="col">Last Changes</th>
                            <th scope="col">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                    <div id="actionsCellTemplateTheme" class="d-none">
                        <button class="btn btn-sm btn-success syncBtn" title="Sync"
                                onclick="syncTheme('#THEMEUUID#')">
                            <i data-feather="refresh-cw"></i>
                        </button>
                        <a class="btn btn-sm btn-primary" title="Contents"
                           href="themeContents.jsp?id=#THEMEUUID#">
                            <i data-feather="list"></i>
                        </a>
                        <button class="btn btn-sm btn-primary" title="Settings"
                                onclick="openEditThemeModal('#THEMEID#')">
                            <i data-feather="settings"></i>
                        </button>
                        <button class="btn btn-sm btn-primary " title="Copy"
                                onclick="copyTheme('#THEMEID#')">
                            <i data-feather="copy"></i></button>
                        <button class="btn btn-sm btn-primary" title="Download"
                                onclick="downloadTheme('#THEMEID#')">
                            <i data-feather="download"></i>
                        </button>
                        <button class="btn btn-sm btn-danger deleteBtn" title="Delete"
                                onclick='deleteTheme("#THEMEID#")'>
                            <i data-feather="trash-2"></i></button>
                        <button class="btn btn-sm btn-danger unpublishBtn" title="Unpublish"
                                onclick="onUnpublishTheme(false,'#THEMEID#' )">
                            <i data-feather="x"></i>
                        </button>
                    </div>

                </div>
            </div><!-- row-->

        </div>
        <!-- container -->
        <!-- /end of container -->
    </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<!-- Modals -->
<!-- addEditThemeModal modal -->
<div class="modal fade" id="addEditThemeModal" tabindex="-1" role="dialog">
	<div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
		<div class="modal-content">
			<div class="modal-header bg-lg1">
				<h5 class="modal-title font-weight-bold" id="editThemeHeading"></h5>
				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">×</span>
				</button>
			</div>
			<div class="modal-body">
                <form id="editThemeForm" action="" novalidate>
                    <div class="mb-3 text-right">
                        <button type="button" class="btn btn-primary" onclick="updateTheme()">Save</button>
                    </div>
                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#collapseExample" role="button" 
                            aria-expanded="true" aria-controls="collapseExample">
                            <strong>Global Information</strong>
                        </div>
                        <div class="collapse p-3 show" id="collapseExample">
                            <div class="card-body">
                                <input type="hidden" name="id" class="form-control"  value="">
                                <input type="hidden" name="requestType" class="form-control"  value="addEditTheme">

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Theme Name</label>
                                    <div class="col-sm-9">
                                        <input type="text" name="name"  required="required" class="form-control" maxlength="100" value="">
                                        <div class="invalid-feedback">
                                            Cannot be empty.
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label" >Version</label>
                                    <div class="col-sm-9">
                                        <input type="text" name="version" placeholder="1.0.0"  onkeyup="onVersionKeyup(this)"  required="required" class="form-control" maxlength="10" value="1.0.0">
                                        <div class="invalid-feedback">
                                            Cannot be empty.
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label">Description</label>
                                    <div class="col-sm-9">
                                        <textarea class="form-control" name="description" rows="3" ></textarea>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label">Status</label>
                                    <div class="col-sm-9">
                                        <select class="custom-select" name="status" aria-label="">
                                            <option value="opened" >Opened</option>
                                            <option value="locked" >Locked</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <label  class="col-sm-3 col-form-label" >Theme Asimina Version</label>
                                    <div class="col-sm-9">
                                        <input type="text" name="asiminaVersion" disabled class="form-control" maxlength="10" value="">
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>
                </form>
            </div>  <!--end  body -->
        </div> <!--end  content -->
    </div>
</div> <!--end  modal -->

<div class="modal fade" id="modalPublish" tabindex="-1" role="dialog" >
    <div class="modal-dialog" role="document">
        <div class="modal-content" >
            <form class="formPublish" action="" onSubmit="return false" novalidate="">
                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="form-group row">
                            <div class="col publishMessage">

                            </div>
                            <div class="col-1">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label  class="col-sm-3 col-form-label">
                                <span class="text-capitalize actionName">Publish</span>
                            </label>
                            <div class="col-sm-9">
                                <button type="button" class="btn btn-primary publishNowBtn">Now</button>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label  class="col-sm-3 col-form-label">
                                <span class="text-capitalize actionName">Publish</span> on
                            </label>
                            <div class="col-sm-9">
                                <div class="input-group">
                                    <input type="text" class="form-control" name="publishTime" value="">
                                    <div class="input-group-append">
                                        <button class="btn btn-primary  rounded-right publishOnBtn" type="button">OK</button>
                                    </div>
                                    <div class="invalid-feedback">Please specify date and time</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->


<div class="modal fade" id="addThemeModal" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-dialog-slideout" role="document">
        <div class="modal-content">
            <form id="addThemeForm" action="" onsubmit="return false;" novalidate>
                <input type="hidden" name="requestType" value="uploadThemeFile">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel"> Add a theme</h5>
                    <div class="text-right">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
                <div class="modal-body">
                    <div class="form-group row">
                        <label class="col-sm-4 col-form-label">Load your theme</label>
                        <div class="input-group col-sm-8">
                            <div class="custom-file">
                                <input type="file" class="custom-file-input btn-primary" accept=".tar.gz"
                                       name="inputThemeFile" id="inputThemeFile"
                                       aria-describedby="inputGroupFileAddon01">
                                <label class="custom-file-label rounded-right fileLabel" for="inputThemeFile"
                                       style="justify-content: left;">Choose file</label>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-column justify-content-center align-items-center ">
                        Or
                        <button type="button" class="btn btn-success mt-3" onclick="createEmptyTheme()">Create Empty Theme</button>
                    </div>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" onclick="uploadThemeFile()">Load</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>

<%@ include file="checkPublishLogin.jsp"%>

<script type="text/javascript">
    // ready function
    $(function () {
        initThemeTable();
        $('#themesTable tbody').tooltip({
            placement: 'bottom',
            html: true,
            selector: ".custom-tooltip"
        });
        $ch.isSuperAdmin = <%=isSuperAdmin%>;

        $('#inputThemeFile').change(function () {
            var fileName = $(this)[0].files[0].name;
            $(this).next('.custom-file-label').html(fileName);
        });

        var publishTimeField = $('#modalPublish input[name=publishTime]');
        initDatetimeFields(publishTimeField, null, null, "date_time");
        publishTimeField.on('change',function(){
            if($(this).val().trim().length > 0){
                $(this).removeClass('is-invalid');
            }
        });

    });

    function initThemeTable() {

        window.themesTable = $('#themesTable')
        .DataTable({
            responsive: true,
            pageLength: 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax: function (data, callback, settings) {
                getThemesList(data, callback, settings);
            },
            order: [[1, 'asc'], [2, 'asc']],
            columns: [
                {"data": "id"},
                {"data": "name", className: "name"},
                {"data": "version"},
                {"data": "status", className: "text-capitalize"},
                {"data": "updated_ts"},
                {"data": "actions", className: "dt-body-right text-nowrap"},
            ],
            columnDefs: [
                {targets: [-1], searchable: false},
                {targets: [0, -1], orderable: false},
				{targets: [1], render: _hEscapeHtml},
                {
                    targets: [0],
                    render: function (data, type, row) {
                        if (type == 'display') {
                            return '<input type="radio" class="idCheck" name="themeId" onclick="onCheckItem(this)" value="' + data + '" >';
                        }
                        else {
                            return data;
                        }
                    }
                },
                {
                    targets: [2],
                    render: function (data, type, row) {
                        if (type == 'sort' && data.trim().length > 0) {
                            var digits = _hEscapeHtml(data).split('.');
                            var _v = ((parseInt(digits[0]) * 100) + (parseInt(digits[1]) * 100)) + parseInt(digits[2]);
                            return _v;
                        } else return data;

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
                var status ;
                switch (data['publish_status']) {
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
        })
    }

    function getThemesList(data, callback, settings) {

        showLoader();
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType: 'getThemesList',
            },
        })
        .done(function (resp) {
            var data = [];
            if (resp.status == 1) {
                data = resp.data.themes;
                var actionsCellTemplateElem = $('#actionsCellTemplateTheme');

                $.each(data, function (index, val) {
                    if(!$ch.isSuperAdmin && val.status == '<%=Constant.THEME_LOCKED%>'){
                        actionsCellTemplateElem.find(".deleteBtn").attr("disabled", true);
                    } else{
                        actionsCellTemplateElem.find(".deleteBtn").attr("disabled",false );
                    }
                    val.actions = strReplaceAll(actionsCellTemplateElem.html(), "#THEMEID#", val.id);
                    val.actions = strReplaceAll(val.actions, "#THEMEUUID#", val.uuid);
                });
            }
            callback({"data": data});
        })
        .fail(function () {
            callback({"data": []});
        })
        .always(function () {
            hideLoader();
        });
    }

    function  copyTheme(themeId) {
        openEditThemeModal(themeId, true);
    }

    function createEmptyTheme(){
        $("#addThemeModal").modal("hide");
        var themeAddEditModal =  $('#addEditThemeModal');
        var form = themeAddEditModal.find('#editThemeForm');
        form.removeClass("was-validated");
        form.find(":input:not(input[name=asiminaVersion])").prop("disabled", false);

        themeAddEditModal.find("#editThemeHeading").text("Add a theme");
        themeAddEditModal.find("input[name=requestType]").val("addEditTheme");
        themeAddEditModal.find("select[name=status]").val("opened");
        themeAddEditModal.find("input[name=id]").val('');
        themeAddEditModal.find("input[name=name]").val('');
        themeAddEditModal.find("input[name=version]").val('1.0.0');
        themeAddEditModal.find("textarea[name=description]").val('');
        themeAddEditModal.find("input[name=asiminaVersion]").val('<%=GlobalParm.getParm("APP_VERSION")%>');

        // only admin can update the themestatus
        if(!$ch.isSuperAdmin){
            $("#editThemeForm").find('select[name=status]').prop("disabled", true);
        }
        themeAddEditModal.modal("show");
    }

    function openEditThemeModal(id, isCopy) {
        showLoader();
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType: 'getThemeData',
                id: id
            },
        })
        .done(function (resp) {
            var data = [];
            var themeAddEditModal =  $('#addEditThemeModal');
            if (resp.status == 1) {
                data = resp.data.theme;
                var action = "";
                if(isCopy){
                    action = "Copy from";
                    themeAddEditModal.find("input[name=requestType]").val("copyTheme");
                    themeAddEditModal.find("select[name=status]").val("opened");
                } else{
                    action = "Edit";
                    themeAddEditModal.find("input[name=requestType]").val("addEditTheme");
                    themeAddEditModal.find("select[name=status]").val(data.status);
                }
                themeAddEditModal.find("#editThemeHeading").text(action+ " Theme : "+data.name+" V "+data.version);
                themeAddEditModal.find("input[name=id]").val(data.id);
                themeAddEditModal.find("input[name=name]").val(data.name);
                themeAddEditModal.find("input[name=version]").val(data.version);
                themeAddEditModal.find("textarea[name=description]").val(data.description);
                themeAddEditModal.find("input[name=asiminaVersion]").val(data.asimina_version);

                if(data.status == "<%=Constant.THEME_LOCKED%>" && $ch.isSuperAdmin == false && !isCopy){
                    $("#editThemeForm :input").prop("disabled", true);
                } else{
                    $("#editThemeForm :input:not(input[name=asiminaVersion])").prop("disabled", false);
                }
                // only admin can update the themestatus
                if(!$ch.isSuperAdmin){
                    $("#editThemeForm").find('select[name=status]').prop("disabled", true);
                }
                themeAddEditModal.modal("show");
            } else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error connecting to server, try again please.");
        })
        .always(function () {
            hideLoader();
        });
    }

    function updateTheme() {
        var form = $('#editThemeForm');
        form.removeClass("was-validated")

        if (!form.get(0).checkValidity()) {
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function (resp) {
            var themeAddEditModal =  $('#addEditThemeModal');
            if (resp.status == 1) {
                bootNotify(resp.message);
                themeAddEditModal.modal("hide");
                refreshDataTable();
            } else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error connecting to server, try again please.");
        })
        .always(function () {
            hideLoader();
        });
    }

     function downloadTheme(uuid) {
         var form = $('#downloadThemeForm');
         form.find("input[name=id]").val(uuid);
         form.get(0).submit();
    }

    function onCheckItem(check) {
        check = $(check);
        var row = window.themesTable.row(check.parents('tr:first'));

        if (check.prop('checked')) {
            row.select();
        }
        else {
            row.deselect();
        }
    }

    function refreshDataTable() {
        window.themesTable.ajax.reload(function () {
            $("input[name='themeId']").attr('checked', false);
        }, false);
    }

    function openThemeModal() {
        var modal = $('#addThemeModal');
        var form = $('#addThemeForm');

        form.get(0).reset();
        form.find('.custom-file-label').text("Choose File");

        modal.modal("show");
    }

    function deleteTheme(id) {
        bootConfirm("Are you sure you want to delete this theme ?",
            function (result) {
                if (!result) return;
                $.ajax({
                    url : 'themesAjax.jsp', type : 'POST', dataType : 'json',
                    data : {
                        requestType : 'deleteTheme',
                    id: id
                },
            })
            .done(function (resp) {
                if (resp.status == 1) {
                    bootNotify(resp.message);
                    refreshDataTable();
                } else {
                    bootNotifyError(resp.message);
                }
            })
            .fail(function () {
                bootNotifyError("Error connecting to server, try again please.");
            })
            .always(function () {
                hideLoader();
            });
        });
    }

    function publishTheme(id) {
        $.ajax({
            url : 'themesAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'publishTheme',
                themeId : id
            },
        })
        .done(function (resp) {
            if (resp.status == 1) {
                bootNotify(resp.message);
                refreshDataTable();
            }
            else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error connecting to server, try again please.");
        })
        .always(function () {
            hideLoader();
        });
    }

    function unpublishTheme(id) {
        $.ajax({
            url : 'themesAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'unpublishTheme',
                themeId : id
            },
        })
        .done(function (resp) {
            if (resp.status == 1) {
                bootNotify(resp.message);
                refreshDataTable();
            }
            else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error connecting to server, try again please.");
        })
        .always(function () {
            hideLoader();
        });
    }

    function uploadThemeFile() {
        var form = $('#addThemeForm');
        var input  = form.find('#inputThemeFile')
        var file = input.get(0).files[0];
        var fileName = file.name;
        var fileType = fileName.substring(fileName.lastIndexOf('.') + 1);
        if(fileType != "gz"){
            bootNotifyError("Invalid file type only tar.gz  files allowd");
            return;
        }
        var formData = new FormData(form.get(0));

        showLoader();
        $.ajax({
            type :  'POST',
            url: 'uploadTheme.jsp',
            data :  formData,
            dataType : "json",
            cache : false,
            contentType: false,
            processData: false,
        })
        .done(function (resp) {
            if (resp.status == 1) {
                bootNotify(resp.message);
                $('#addThemeModal').modal("hide");
                refreshDataTable();
            } else {
                bootAlert(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error connecting to server, try again please.");
        })
        .always(function () {
            hideLoader();
        });
    }



    function showPublishModal(message, action, callback){
        var modal = $('#modalPublish');

        modal.find('.actionName').text(action);

        modal.find('.publishMessage').text(message);

        modal.find(".publishNowBtn").off('click')
        .click(function(){
            var publishTime = "now";
            modal.modal('hide');
            callback(publishTime);
        });

        var publishTimeField = modal.find('input[name=publishTime]');
        publishTimeField.val("");

        modal.find(".publishOnBtn").off('click')
        .click(function(){
            var publishTime = publishTimeField.val().trim();

            if(publishTime.length === 0){
                publishTimeField.addClass('is-invalid');
                return false;
            }

            modal.modal('hide');
            callback(publishTime);
        });

        modal.modal('show');
    }

    function onPublishTheme(isLogin) {
        var themeId = $("input[name='themeId']:checked").val();
        if(themeId){
            $ch.publishUnpublishThemeId = themeId;
            $ch.publishUnpublishMessage = "Choose theme publish time";

            if(!themeId && themeId.length == 0){
                return false;
            }
            bootConfirm("Are you sure you want to publish this theme? <br><p><span class='text-warning'>Warning:</span> <b>All</b> the pages will be regenerated</p>", function (result) {
                if (result) {
                    onPublishUnpublish("publish", isLogin, themeId);
                }
            });
        } else{
            bootNotify("No theme selected");
        }
    }

    function onUnpublishTheme(isLogin, themeId) {
        $ch.publishUnpublishThemeId = themeId;
        $ch.publishUnpublishMessage = "Are you sure you want to unpublish this theme?";

        if(!themeId && themeId.length == 0){
            return false;
        }
        onPublishUnpublish("unpublish", isLogin, themeId);
    }

    function onPublishUnpublish(action, isLogin){
        if(typeof isLogin == 'undefined' || !isLogin){
            checkPublishLogin(action);
        }
        else{
            showPublishModal($ch.publishUnpublishMessage, action, function(publishTime){
                publishUnpublishTheme(action, publishTime);
            });
        }
    }

    function publishUnpublishTheme(action, publishTime){
        if($ch.publishUnpublishThemeId && $ch.publishUnpublishThemeId.length > 0) {
            showLoader();
            $.ajax({
                url : 'themesAjax.jsp', type : 'POST', dataType : 'json',
                data : {
                    requestType : action + 'Theme',
                    publishTime : publishTime,
                    themeId : $ch.publishUnpublishThemeId
                },
            })
            .done(function (resp) {
                if (resp.status === 1) {
                    bootNotify(resp.message);
                    refreshDataTable();
                }
                else {
                    bootAlert(resp.message);
                }
            })
            .fail(function () {
                bootNotifyError("Error in contacting server. please try again.");
            })
            .always(function () {
                hideLoader();
            });
        }
    }

    function syncTheme(themeId) {
        showLoader();
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'syncTheme',
                themeId: themeId
            },
        })
        .done(function(resp) {
            if(resp.status === 1){
                bootNotify(resp.message);
                refreshDataTable();
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

function onVersionKeyup(input) {
    input = $(input);
    var val = input.val();
    val = val.trim()
        .replace(/[^0-9\.]/g, '')
    var vNums = val.split('.').splice(0,3)

    for(var i = 0; i < 3; i++){
        if(i < vNums.length ){
            var n = Number(vNums[i])
            if(i == 0 && n == 0){
                vNums[i] = 1;
            } else{
                vNums[i] = n;
            }
        } else{
            vNums[i] = 0;
        }
    }
    vNums[vNums.length-1] = Number(vNums[vNums.length-1] + vNums.splice(3, vNums.length).join(""));
    val = vNums.join('.');
    input.val(val);
}

</script>
</body>
</html>