<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<!DOCTYPE html>
<html lang="en">

    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Load</title>

        <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/datatables.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/moringa-cui.css" rel="stylesheet">


		<script src="<%=request.getContextPath()%>/js/common.js"></script>
		<script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/moment.min.js"></script>
		<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
		<script src="<%=request.getContextPath()%>/js/datatables.min.js"></script>
        <style> 
        /* .btn-sm.btn {
            padding: 0.2rem 0.1rem;
            font-size: 10px;
        } */
        </style>
    </head>

    <body class="c-app" style="background-color:#efefef">
    <%
        breadcrumbs.add(new String[]{"Tools", ""});
        breadcrumbs.add(new String[]{"Import", ""});
    %>
    <%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Load</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" onclick="refreshEngine()" class="btn btn-success mr-2" >Refresh</button>
                    <button type="button" class="btn btn-primary"
                        onclick="goBack('pages.jsp')">Back</button>
                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Load');" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>
                </div>
            </div>
            <!-- row -->
            <div class="small">
                You can load data in JSON format. Download sample JSON format for
                <a href="<%=request.getContextPath()%>/sample/libraries_sample.json" download>Library</a>,
                <a href="<%=request.getContextPath()%>/sample/blocs_sample.json" download>Bloc templates</a>,
                <a href="<%=request.getContextPath()%>/sample/bloc_templates_sample.json" download>Blocks</a> and
                <a href="<%=request.getContextPath()%>/sample/pages_sample.json" download>Pages</a>
            </div>
            <div id="loadFileFormRow" class="row tableRow">
                <div class="col">
                    <form id="formUploadImportFile" action="" method="POST"
                        class="form-inline" onsubmit="uploadDataFile(event);"
                            onreset="resetUploadForm()" >
                        <input type="hidden" name="importDatetime" id="importDatetime" value="0">
                        <div class="custom-control mr-2 p-0">
                            <div class="custom-file ">
                                <input type="file" id="importFile" name="file"
                                    accept=".json,.xlsx" required="required"
                                    class="custom-file-input"
                                    onchange="onFileInputChange(this)">
                                <label class="custom-file-label rounded-right fileLabel" for="importFile" style="justify-content: left;">Choose file</label>
                                <div class="invalid-feedback">No file selected.</div>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-success mr-2" >Load</button>
                        <button type="reset" class="btn btn-secondary mr-2" >Reset</button>
                    </form>
                </div>
            </div>
            <div id="loadFormRow" class="row tableRow">
            </div>
            <div id="loadTableRow" class="row tableRow mt-2">
                <div class="col">
                <form id="mainForm" action="" onsubmit="return false;" novalidate>

                    <table class="table table-hover table-vam" id="loadTable" style="width: 100%;">
                        <thead class="thead-dark">
                            <tr>
                                <%-- <th scope="col" style="width: 30px;">
                                    <input type="checkbox" class="" id="checkAll" onchange="onChangeCheckAll(this)">
                                </th> --%>
                                <th scope="col">Batch#</th>
                                <th scope="col">Name</th>
                                <th scope="col">Created on</th>
                                <th scope="col">Status</th>
                                <th scope="col" style="width 80px">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- loaded by ajax -->
                        </tbody>
                    </table>
                </form>
                </div>
            </div><!-- row-->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>

    <!-- Modals -->

<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>';
    $ch.itemsDataList = [];

    // ready function
    $( document ).ready(function() {
         window.importTable = $('#loadTable').DataTable({
            responsive: true,
            deferRender: true,
            "searching": true,
            order:[[4,'asc']],
            lengthMenu: [[100, 250, 375, 500, -1], [100,250,375,500, 'All']],
            pageLength : 100,
            ajax :{
                url: 'loadFilesAjax.jsp', 
                type: 'GET', 
                dataType: 'json',
                data:{
                    request_type:'load',
                },
            },
            columns : [
                { "data": "batch_id", className : ""},
                { "data": "name", className : ""},
                { "data": "created_ts", className : ""},
                { "data": "status", className : "text-capitalize"},
                { "data": "action", className : ""},
            ],
            columnDefs : [
                { targets : [3] ,
                    render: function ( data, type, row, meta ) {
                        if(data=='waiting' || data=='processing'){
                            return data+" <i class='fas fa-circle-notch fa-spin'></i>";
                        }else{
                            return data;
                        }
                    }
                },
            ],
            
        });
    });
    

    function resetUploadForm(){
        var form = $('#formUploadImportFile');

        form.find('.fileLabel').html("Choose file");
    }


    function doAction(batchId,action) {

        bootConfirm("Are you sure you want to "+action+" this batch?",
            function(isConfirm){
                if(isConfirm){
                    $.ajax({
                        url: 'loadFilesAjax.jsp', 
                        type: 'POST', 
                        dataType: 'json',
                        data:{
                            batch_id:batchId,
                            request_type:action,
                        },
                    })
                    .done(function(resp) {
                        var data = [];
                        if(resp.status == 1){
                            // bootAlert(resp.message, null, 'medium');
                            window.location.reload();
                        }
                        else{
                            bootAlert("<span class='text-danger'>"+resp.message+"</span>", null, 'medium');
                        }
                        // verifyAllItems();
                        $('#importTable').DataTable().ajax.reload();
                    })
                    .fail(function() {
                        bootNotifyError("Error in contacting server.Please try again.");
                    })
                    .success(function() {
                    });
                }
            }
        );
        

    }
    function refreshEngine() {
        showLoader();
        $.ajax({
            url: 'loadFilesAjax.jsp', 
            type: 'POST', 
            dataType: 'json',
            data:{
                request_type:'refresh',
            },
        })
        .done(function(resp) {
            // $('#importTable').DataTable().ajax.reload();
            window.location.reload();
        })
        .fail(function() {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .success(function() {
        }).always(function() {
            hideLoader();
        });
    }
    
    


    function uploadDataFile(event){
        event.preventDefault();

        var form = $('#formUploadImportFile');

        form.find('.is-invalid').removeClass('is-invalid');
        onChangeImportDatetime();

        if( !form.get(0).checkValidity() ){
            form.addClass('was-validated');
            return false;
        }

        var formData = new FormData(form.get(0));
        $.ajax({
            type :  'POST',
            url :   'importDataFileUpload.jsp',
            data :  formData,
            dataType : "json",
            cache : false,
            contentType: false,
            processData: false,
        })
        .done(function(resp) {
            if(resp.status == 1){
                var form = $('#formUploadImportFile');
                form.get(0).reset(); //debug
                $('#loadTable').DataTable().ajax.reload();
                $ch.itemsDataList = resp.data;
                window.location.reload();
            }
            else{
                bootNotifyError(resp["message"]);
            }
        })
        .fail(function(resp) {
             bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function() {
        });

    }

    function redirectToImport(batch_table_id){
        let path = '<%=request.getContextPath()%>';
        window.location=path+"/admin/import.jsp?batch_id="+batch_table_id;
    }

    function onFileInputChange(input){

        input = $(input);
        var form = $('#formUploadImportFile');

        var fileLabel = "Choose file";

        var fileType = form.find('[name=fileType]').val();

        var numFiles = input.get(0).files.length;
        var fileNameValue = "";
        if(numFiles > 0){
            var file = input.get(0).files[0];

            fileLabel = file.name;
        }

        form.find('.fileLabel').html(fileLabel);
    }

    function onChangeImportDatetime(){
        input = $('#importDateTimeCheckbox');
        if(input.prop('checked')){
            $('#importDatetime').val("1");
        }
        else{
            $('#importDatetime').val("0");
        }
    }
    setTimeout(reloadStatus, 10000);
	function reloadStatus(){
		$('#loadTable').DataTable().ajax.reload();
        setTimeout(reloadStatus, 10000);
	}
</script>
    </body>
</html>