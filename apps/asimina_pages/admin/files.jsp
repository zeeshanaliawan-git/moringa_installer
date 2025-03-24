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
    boolean isSuperAdmin = isSuperAdmin(Etn);
    String selectedSiteId = getSiteId(session);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Pages : Files</title>

        <style type="text/css">
            /*debug*/
            .bg-css{
                background-color: lightseagreen;
            }

            .bg-js{
                background-color: lightcyan;
            }

            .file-row > td{
                cursor: move;
            }
            #dragDropMain{
                align-self: center;
                align-items: center;
                justify-content: center;
                max-width: 100%;
            }
            .drop-zone {
                align-self: center;
                max-width: 100%;
                height: 200px;
                padding: 25px;
                display: flex;
                align-items: center;
                justify-content: center;
                text-align: center;
                font-family: "Quicksand", sans-serif;
                font-weight: 500;
                font-size: 20px;
                cursor: pointer;
                color: #cccccc;
                border: 4px dashed #009578;
                border-radius: 10px;
            }

            .drop-zone--over {
                border-style: solid;
            }

            .drop-zone__input {
                display: none;
            }

            .drop-zone__thumb {
                width: 100%;
                height: 100%;
                border-radius: 10px;
                overflow: hidden;
                background-color: #cccccc;
                background-size: cover;
                position: relative;
            }

            .drop-zone__thumb::after {
                content: attr(data-label);
                position: absolute;
                bottom: 0;
                left: 0;
                width: 100%;
                padding: 5px 0;
                color: #ffffff;
                background: rgba(0, 0, 0, 0.75);
                font-size: 14px;
                text-align: center;
            }

        </style>
    </head>
    <body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Developer", ""});
        breadcrumbs.add(new String[]{"Files", ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
                <!-- beginning of container -->
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">List of Files</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <button type="button" class="btn btn-primary mr-1"
                            onclick="goBack('pages.jsp')">Back</button>
                        <button type="button" class="btn btn-primary mr-2"
                                    onclick="refreshFilesTable();" title="Refresh">
                                    <i data-feather="refresh-cw"></i></button>

                        <button class="btn btn-success mr-2"
                            onclick="openAddMediaModal()">Add new file</button>
                        
                        <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Files');" title="Add to shortcuts">
                            <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                        </button>
                    </div>
                </div>
                <!-- row -->

                <table class="table table-hover table-vam" id="filesTable" style="width: 100%;">
                    <thead class="thead-dark">
                        <tr>
                            <th scope="col">ID</th>
                            <th scope="col">File name</th>
                            <th scope="col" class="typeHeader">Type</th>
                            <th scope="col" >Size</th>
                            <th scope="col" >Theme</th>
                            <th scope="col">Last changes</th>
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
                        onclick='editFile("#ID#")'>
                        <i data-feather="settings"></i></button>
                                <button class="btn btn-sm btn-danger delBtn" type="button"
                        onclick='deleteSingleFile("#ID#")'>
                        <i data-feather="x"></i></button>
                </div>
                <!-- row-->
                <!-- /end of container -->
            </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
        </div>

        <div class="d-none" id="typeFilterDiv">
            <div class="float-right pl-1 m-0">
                <label>Type:&nbsp;
                    <select name="typeFilter" style="width: auto;"
                        class="custom-select custom-select-sm ml-1"
                        onchange="applyFileTypeFilter(this)"
                        onclick="event.stopPropagation();return false;">

                    </select>
                </label>
            </div>
        </div>
        <!-- Modals -->
        <div class="modal fade" id="modalAddFile" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-slideout" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title"></h5>
                        <button type="button" class="close closeBtn" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="formAddEditFile" action="" onsubmit="return false;" novalidate>
                            <input type="hidden" name="id" value="">

                            <div class="invalid-feedback fileErrorMsg" style="display: block;"></div>
                            <div class="form-group row">
                                <label class="col col-form-label">File name</label>
                                <div class="col-sm-9 input-group">
                                     <input type="text" class="form-control"
                                        name="name" maxlength="300" required
                                        onkeyup="onKeyUpFileName(this)"
                                        onblur="onKeyUpFileName(this)"
                                        readonly="readonly" />
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col col-form-label">Type</label>
                                <div class="col-sm-9 input-group" >
                                    <select class="custom-select" name="fileTypeSelect" disabled>
                                        <option value="css">CSS</option>
                                        <option value="js">JS</option>
                                        <option value="fonts">FONTS</option>
                                        <option value="other">OTHER</option>
                                    </select>
                                </div>
                                <input type="hidden" name="fileType" value="">
                            </div>
                            <div class="input-group mb-3">
                                <div class="custom-file">
                                    <input type="file" multiple id="file" name="file"
                                    class="custom-file-input" aria-describedby="file"
                                    onchange="onFileInputChange(this)">
                                    <label class="custom-file-label rounded-right fileLabel" for="file">Upload new file</label>
                                </div>
                                <!-- <div id="fileErrorMsg" class="invalid-feedback" style="display: block;"></div> -->
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary closeBtn" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary"
                            onclick="uploadFile()">Upload</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <!-- ------------------------------------Modal created by Ahsan for multiple files uploading------------------------------------- -->

        <div class="modal fade" id="modalAddFiles" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-slideout modal-xl" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close closeBtn" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <form id="formAddFile" action="" onsubmit="return false;" novalidate>
                            <div class="col">
                                <div class="drop-zone">
                                    <span class="drop-zone__prompt">Drop file(s) here or click to upload</span>
                                    <input type="file" multiple name="myFile" class="drop-zone__input">
                                </div>
                                <div id="dragDropMain" class="row mt-4 ml-3">

                                </div>
                            </div>
                        </form>
                    </div>
                    <div id="multipleFilespload" class="modal-footer">
                        <button type="button" class="btn btn-secondary closeBtn" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary uploadBtn"
                                onclick="uploadAllFiles()">Upload</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <!-- ----------------------------------------------till here ahsan code---------------------------------------------------------- -->

<script type="text/javascript">

    $ch.isSuperAdmin = <%=isSuperAdmin%>;
    $ch.THEME_LOCKED = '<%=Constant.THEME_LOCKED%>';

    $ch.filesTable = $('#filesTable');
    $ch.filesList = $('#filesTable tbody');

    $ch.FILE_TYPES = ["css","js","fonts"];
    $ch.FILE_URL_PREPEND = '<%=getFileURLPrepend()+selectedSiteId+"/"%>';

    

    $ch.CONFIG_MAX_FILE_UPLOAD_SIZE = {
        "default" : '<%=getMaxFileUploadSize("default")%>' ,
        "other"   : '<%=getMaxFileUploadSize("other")%>' ,
        "video"   : '<%=getMaxFileUploadSize("video")%>' ,
    };

    // ready function
    $(function() {

        $('#filesTable tbody').tooltip({
            placement : 'bottom',
            html:true,
            selector:".custom-tooltip"
        });

        initDataTable();

        //override max file sizes in common with config values
        if(typeof window.MAX_FILE_SIZES != 'undefined'){
            $.each($ch.CONFIG_MAX_FILE_UPLOAD_SIZE, function(key, val) {
                if(val.length > 0){
                    window.MAX_FILE_SIZES[key] = parseInt(val);
                }
            });
        }

    });

    function initDataTable(){

        window.filesTable = $('#filesTable')
        .DataTable({
            // dom : "<flipt>",
            responsive: true,
            deferRender : true,
            scrollX : true,
            pageLength : 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function(data, callback, settings){
                getList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
                { "data": "id"  , className : "d-none" },
                { "data": "file_name" },
                { "data": "type", className : ""},
                { "data": "file_size", className : ""},
                { "data": "theme_name" },
                { "data": "updated_ts" },
                { "data": "actions", className : "dt-body-right" },
            ],
            columnDefs : [
                { targets : [0,-1] , searchable : false},
                { targets : [0,-1] , orderable : false},
                { targets : [3] ,
                    render: function ( data, type, row ) {
                        if(type == 'display'){
                            return data +' KB';
                        }
                        else {
                            return data;
                        }

                    }
                },
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
                { targets : [1] ,
                    render: function ( data, type, row ) {
                        if(type == 'display'){
                            var fileLink = "<a href='"
                                + $ch.FILE_URL_PREPEND + row.type + "/" +data
                                +"' target='"+data+"' >"+data+"</a>";
                            return fileLink;
                        }
                        else {
                            return data;
                        }

                    }
                },
            ],
            createdRow : function ( row, data, index ) {
                $(row).data('file-data',data);

            },
            initComplete : function(settings, json ){

                var table = settings.oInstance.api();

                var typeFilterSelect = $('#typeFilterDiv select');
                var fileTypeOptions = "<option value=''>All</option>";
                $.each($ch.FILE_TYPES, function(index, curFileType) {
                    fileTypeOptions += "<option value='"+curFileType+"'>"+curFileType.toUpperCase()+"</option>";
                });
                typeFilterSelect.html(fileTypeOptions);

                $('.dataTables_filter').before($('#typeFilterDiv').html());
            },
        });
    }

    function getList(data, callback, settings){
        // showLoader();
        $.ajax({
            url: 'filesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getAllFilesList',
                fileTypes : $ch.FILE_TYPES.join(",")
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.files;
                var actionTemplateEle = $('#actionsCellTemplate');
                $.each(data, function(index, val) {
                    var curId = val.id;
                    if(val.theme_status.length > 0){
                        actionTemplateEle.find('.delBtn').attr("disabled",true);
                    } else{
                        actionTemplateEle.find('.delBtn').attr("disabled",false);
                    }
                    var actionTemplate = actionTemplateEle.html();
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

    function refreshFilesTable(){
        window.filesTable.ajax.reload(null,false);
    }

    function openAddFileModal(){

        var modal = $('#modalAddFile');
        modal.find(':input').prop("disabled", false);
        var form = $('#formAddEditFile');
        form.get(0).reset();
        form.find('.fileErrorMsg').text('');

        modal.find('.modal-title').text('Add new file');


        form.find('[name=id]').val('');
        form.find('[name=name]').val('');

        form.find('[name=fileType]').val("");
        form.find('[name=fileTypeSelect]').val("");

        var fileInputAccept = [];
        $.each($ch.FILE_TYPES, function(index, curFileType) {
            fileInputAccept.push( "."+ALLOWED_TYPES[curFileType].join(',.') );
        });

        fileInputAccept = fileInputAccept.join(",");

        form.find('[name=file]').attr('accept',fileInputAccept);
        form.find('.fileLabel').text('Upload new file');

        modal.modal('show');

    }

    // Added by ahsan for adding multiple files------------------------------------------------------------------
    let files=[];
    let names=[];
    let invalidFileNames='';

    function openAddMediaModal(){

        let modal = $('#modalAddFiles');
        let form = $('#formAddFile');
        form.get(0).reset();
        $('#dragDropMain').html('');
        $('#multipleFilespload').show();
        $('.drop-zone').show();
        $('.progress').hide();
        $('#fileAlreadyExist').html('')
        invalidFileNames="";
        files=[];
        names=[];
        modal.modal('show');

    }
    document.querySelectorAll(".drop-zone__input").forEach((inputElement) => {
        const dropZoneElement = inputElement.closest(".drop-zone");

        dropZoneElement.addEventListener("click", (e) => {
            inputElement.click();
        });

        inputElement.addEventListener("change", (e) => {
            if (inputElement.files.length) {
                for(let i=0; i<inputElement.files.length;i++) {
                    updateThumbnail(dropZoneElement, inputElement.files[i]);
                }
            }
        });
        dropZoneElement.addEventListener("dragover", (e) => {
            e.preventDefault();
            dropZoneElement.classList.add("drop-zone--over");
        });

        ["dragleave", "dragend"].forEach((type) => {
            dropZoneElement.addEventListener(type, (e) => {
                dropZoneElement.classList.remove("drop-zone--over");
            });
        });

        dropZoneElement.addEventListener("drop", (e) => {
            e.preventDefault();

            if (e.dataTransfer.files.length) {
                inputElement.files = e.dataTransfer.files;
                for(let i=0; i<inputElement.files.length;i++) {
                    updateThumbnail(dropZoneElement, e.dataTransfer.files[i]);
                }

            }
            dropZoneElement.classList.remove("drop-zone--over");
        });

    });
    function removeFile(thisElement) {
        document.getElementById(thisElement.parentNode.id).remove();
        for(let i=0;i<files.length;i++){
            if(files[i].id===thisElement.parentNode.id){
                files.splice(i,1);
                names.splice(i,1);
            }
        }

    }
    function updateThumbnail(dropZoneElement, file) {
        if(!names.includes(file.name)) {
            let fileSplitted = file.name.split('.')
            let fileType = fileSplitted[fileSplitted.length - 1].toLowerCase();

            let fontFiles = ["ttf", "eot", "otf", "svg", "woff", "woff2"]
            let fileReader = new FileReader();
            let newDiv = "";
            fileReader.readAsDataURL(file);
            let id = Date.now().toString(36) + Math.random().toString(36).substr(2);
            file["id"] = id;

            if (fontFiles.includes(fileType)) {
                file["fileType"] = "fonts";
            }
            else if("css"==fileType){
                file["fileType"] = "css";
            }
            else if("js"==fileType){
                file["fileType"] = "js";
            }
            else {
                file["fileType"] = 'other';
            }
            fileReader.onload = () => {
                newDiv = "<form id='" + id + "' class='col-sm-3 mt-4' style='border-radius: 6px;border-color: #3b3b1f;border: 2px solid #c6c6c6;padding: 10px;text-align: center;justify-content: center;align-items: center;align-items: center;height: 200px;'><div id='fileAlreadyExist"+id+"' class='invalid-feedback' style='display: contents;'></div><button class='close' style='position: absolute;right: 10px;' onclick='removeFile(this)'><span class='hide-close'>&times;</span></button><i class='fas fa-file' style='font-size: 50px;display: block;margin-top: 50px;'></i><span>" + file.name + "</span></form>";
                $('#dragDropMain').append(newDiv);
            };
            checkFileExist(file.name,file.fileType,id)
            files.push(file);
            names.push(file.name);
        }
    }
    function uploadAllFiles(){
        let modal = $('#modalAddFiles');
        let form = $('#formAddFile');
        $('#multipleFilespload').hide();
        $('.drop-zone').hide();
        let progress=1;

        form.append("<div class='progress mt-3'><div class='progress-bar' role='progressbar' style='width: " + progress + "%' aria-valuenow='" + progress + "' aria-valuemin='0' aria-valuemax='100'></div></div>")
        
        for (let i = 0; i < files.length; i++) {
            let arr = files[i].name.split('.');
            arr.pop();
            let label = arr.join('.');
            let formData = new FormData();
            
            formData.append('file', files[i])
            formData.append('name', files[i].name)
            formData.append('label', label)
            formData.append('fileType', files[i].fileType)
            
            $.ajax({
                type : 'POST',
                url : 'fileUpload.jsp',
                data : formData,
                dataType : "json",
                cache : false,
                contentType : false,
                processData : false,
            })
            .done(function (resp) {
                progress = progress + (100 / files.length)
                $('.progress-bar').attr('aria-valuenow', progress)
                $('.progress-bar').attr('style', "width:" + progress + "%")
                if (progress >= 100)
                    if (resp.status == 1) {
                        form.get(0).reset();
                        modal.modal('hide');
                        bootNotify("Media saved.");
                        refreshFilesTable();
                    }
                    else {
                        console.log(resp);
                        bootNotifyError("Error in file uploading");
                        modal.modal('hide');
                        refreshFilesTable();
                        form.get(0).reset();
                        hideLoader();
                    }
            })
            .fail(function (resp) {
                bootNotifyError("Error in contacting server.Please try again.");
                modal.modal('hide');
                refreshFilesTable();
                form.get(0).reset();
                hideLoader();
            })
            .always(function() {
                hideLoader()
            });
        }
    }

    function checkFileExist(name,fileType,id){
        $.ajax({
            url : 'filesAjax.jsp',
            type : 'POST',
            dataType : 'json',
            data : {
                requestType : "getSafeFilename",
                fileName : name,
                fileType : fileType,
            },
        })
        .done(function(resp) {
            if(resp.status != 1){
                let warningMsg = "File exist. Uploading it will override existing file.";
                warningMsg = "<span class=' mt-3 text-warning'>"+warningMsg + "</span>";
                $('#fileAlreadyExist'+id).append(warningMsg);
            }
            else{
                $('#fileAlreadyExist'+id).html('');
            }

        })
        .fail(function () {
            bootNotifyError("Error contacting server. please try again.");
        })
    }

    //till here ahsan's code------------------------------------------------------------------------------------------------------------
    function editFile(fileId){
        showLoader();
        $.ajax({
            url: 'filesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getFileInfo',
                id : fileId,
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                editFileModal(resp.data.file);
            }
        })
        .fail(function() {
            alert("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function editFileModal(fileData){
        var modal = $('#modalAddFile');
        if(fileData.theme_status == $ch.THEME_LOCKED && !$ch.isSuperAdmin){
            modal.find(':input:not(.closeBtn)').prop("disabled", true);
        } else{
            modal.find(':input').prop("disabled", false);
        }
        var form = $('#formAddEditFile');
        form.get(0).reset();
        form.find('.fileErrorMsg').text('');

        var fileType = fileData.type;

        modal.find('.modal-title').text('Edit ' + fileType.toUpperCase() + " file");

        var fileName = fileData.file_name;

        var fileExt = fileName.substring(fileName.lastIndexOf('.')+1);

        form.find('[name=id]').val(fileData.id);
        form.find('[name=name]').val(fileName);

        form.find('[name=fileType]').val(fileType);
        form.find('[name=fileTypeSelect]').val(fileType);

        form.find('[name=file]').attr('accept',"."+fileExt);
        form.find('.fileLabel').text('Upload new file');
        // $('#fileNameAppend').text("."+fileType);

        modal.modal('show');
    }

    function uploadFile(){
        var modal = $('#modalAddFile');
        var form = $('#formAddEditFile');
        var errorMsgEle = form.find('.fileErrorMsg');

        form.find('.is-invalid').removeClass('is-invalid');
        errorMsgEle.html('');
        var errorMsg = "";

        var name = form.find('input[name=name]');

        if(name.val().trim().length == 0){
            name.addClass('is-invalid');
            errorMsgEle.html("name cannot be empty.");
            return;
        }

        var fileId = form.find('input[name=id]');
        var fileType = form.find('input[name=fileType]');

        var fileInput = form.find('input[name=file]');

        if( onFileInputChange(fileInput) === false){
            return false;
        }

        var errorMsg = validateFileUpload(fileInput,fileType.val());
        if(errorMsg.length > 0){
            errorMsgEle.html(errorMsg).show();
            return;
        }

        var formData = new FormData(form.get(0));
        showLoader();
        $.ajax({
            type :  'POST',
            url :   'fileUpload.jsp',
            data :  formData,
            dataType : "json",
            cache : false,
            contentType: false,
            processData: false,
        })
        .done(function(resp) {
            if(resp.status == 1){

                form.get(0).reset();

                modal.modal('hide');
                bootNotify("File saved.");
                refreshFilesTable();
            }
            else{
                errorMsgEle.html(resp["message"]);
            }
        })
        .fail(function(resp) {
             errorMsgEle.html("Error in contacting server.Please try again.");
        })
        .always(function() {
            hideLoader()
        });

    }

    function onFileInputChange(input){
        input = $(input);
        var form = $('#formAddEditFile');
        var errorMsgDiv = form.find('.fileErrorMsg');
        errorMsgDiv.text('');

        var fileId = form.find('[name=id]').val();

        var numFiles = input.get(0).files.length;
        var errorMsg = "";

        if(numFiles > 0){
            var file = input.get(0).files[0];

            var fileName = file.name;

            input.parent().find(".fileLabel").text(fileName);

            var fileExt = "";
            if(fileName.lastIndexOf('.') > 0){
                fileExt = fileName.substring(fileName.lastIndexOf('.')+1);
                fileExt = fileExt.toLowerCase();
            }

            if(fileId == ""){
                //new file
                var foundFileType = "";
                $.each($ch.FILE_TYPES, function(index, curFileType) {
                    var curAllowedFileTypes = ALLOWED_TYPES[curFileType];
                    if(curAllowedFileTypes.indexOf(fileExt) >= 0){
                        foundFileType = curFileType;
                        return false;//break the each loop
                    }
                });

                if(foundFileType.length > 0){
                    var fileNameInput = form.find('[name=name]');
                    fileNameInput.val(fileName);
                    fileNameInput.trigger('blur');
                }
                else{
                   errorMsg = "Error: please selected valid filetype.";

                }

                form.find('[name=fileType]').val(foundFileType);
                form.find('[name=fileTypeSelect]').val(foundFileType);
            }
            else{
                //edit existing file, only allow same files with same extension
                var fileNameInput = form.find('[name=name]');
                var existingFileName = fileNameInput.val();

                var existingFileExt = existingFileName.substring(existingFileName.lastIndexOf('.')+1);
                existingFileExt = existingFileExt.toLowerCase();

                if(existingFileExt !== fileExt){
                    errorMsg = "Error: Invalid file type. Please select file of same type as of existing.";
                }

            }
        }

        if(errorMsg.length > 0){
            errorMsgDiv.text(errorMsg);
            return false;
        }
    }

    function deleteSingleFile(fileId,){
            const idToDelete = [fileId];
                        
            bootConfirm("Are you sure you want to delet the file?", function(result){
                if(result){
                    deleteFile(idToDelete);
                }
            });

    }

    function deleteFile(idToDelete){

        showLoader();
        $.ajax({
            url: 'filesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'deleteFile',
                elements : JSON.stringify(idToDelete),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                bootNotify("File deleted.");
                refreshFilesTable();
            }
            else{
                bootAlert(resp.message);
                refreshFilesTable();
            }
        })
        .fail(function() {
            alert("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function applyFileTypeFilter(sel){
        var val = $(sel).val();
        window.filesTable.column(2).search(val).draw();
    }

</script>
    </body>
</html>