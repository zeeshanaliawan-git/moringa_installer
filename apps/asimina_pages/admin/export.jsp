<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%
    Set rs = null;
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Export</title>

    </head>
    <body class="c-app" style="background-color:#efefef">
    <%
        breadcrumbs.add(new String[]{"Tools", ""});
        breadcrumbs.add(new String[]{"Export", ""});
    %>
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Export</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-primary mr-2"
                    onclick="refreshTable();" title="Refresh">
                        <i data-feather="refresh-cw"></i></button>
                    <button type="button" class="btn btn-primary"
                        onclick="goBack('pages.jsp')">Back</button>
                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Export');" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>
                </div>
            </div>
            <!-- row -->
            <%@include file="exportLangSelection.jsp"%>
            <table class="table table-hover table-vam" id="exportTable" style="width: 100%;">
                <thead class="thead-dark">
                    <tr>
                        <th scope="col"> <!-- hidden id column --></th>
                        <th scope="col">Type of export</th>
                        <th scope="col">Nb of items</th>
                        <th scope="col" style="width:180px">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- loaded by ajax -->
                </tbody>
            </table>
            <div id="actionsCellTemplate" class="d-none" >
                <div class="btn-group mr-2">
                    <button style="cursor: default" class="btn btn-sm btn-warning " type="button" disabled>
                        All
                    </button>
                    <button class="btn btn-sm btn-success " type="button"
                        onclick="exportAll('#ID#', '0');" >
                        Json
                    </button>
                    <button class="btn btn-sm btn-success " type="button"
                        onclick="exportAll('#ID#', '1');" >
                        Excel
                    </button>
                </div>
                <button class="btn btn-sm btn-success " type="button"
                    onclick="exportSelect('#ID#','#LABEL#');" >
                    Select
                </button>
            </div>
            <!-- row-->
            <!-- /end of container -->
        </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>
    <div class="d-none">
        <form id="exportSelectForm" action="exportSelect.jsp" method="GET">
            <input type="hidden" name="exportType" value="">
            <input type="hidden" name="exportLabel" value="">
            <input type="hidden" name="langIds" value="">
        </form>
        <form id="exportAllDataForm" action="exportData.jsp" method="POST">
            <input type="hidden" name="exportType" value="">
            <input type="hidden" name="langIds" value="">
            <input type="hidden" name="ids" value="all">
            <input type="hidden" name="excelExport" value="">
        </form>
    </div>
<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>';

    // ready function
    $(function() {
        initExportTable();
        downloadIfFileExist();
    });

    function refreshTable(){
        window.exportTable.ajax.reload(null,false);
    }

    function initExportTable(){

        window.exportTable = $('#exportTable')
        .DataTable({
            // dom : "<flipt>",
            // deferRender : true,
            responsive: true,
            pageLength : 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function(data, callback, settings){
                getExportsList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
                { "data": "id" , className : "d-none"  },
                { "data": "name", className : "text-capitalize"},
                { "data": "nb_count" , className : "nb_count" },
                { "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
                { targets : [3] , searchable : false},
                { targets : [3] , orderable : false},
            ],
            createdRow : function ( row, data, index ) {
                //$(row).data('id',data.id);
            },
            initComplete : function(){
                // $(this).find('.btn.btn-primary:first').trigger('click');
            }
        });
    }

    function getExportsList(data, callback, settings){
        // showLoader();
        $.ajax({
            url: 'exportAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getExportsList'
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.exports;
                var actionTemplate = $('#actionsCellTemplate').html();
                $.each(data, function(index, val) {
                    var curId = val.id;
                    val.name = strReplaceAll(val.label,"_"," ");
                    val.actions = strReplaceAll(actionTemplate, "#ID#", curId);
                    val.actions = strReplaceAll(val.actions, "#LABEL#", val.name);
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

    function validate(){
        return validateExportLangIds();
    }

    function exportSelect(exportType, exportLabel){
        if(!validate()) return false;
        var form = $('#exportSelectForm');
        form.find('[name=exportType]').val(exportType);
        form.find('[name=exportLabel]').val(exportLabel);
        form.find('[name=langIds]').val(getExportLangIds());
        form.get(0).submit();
    }

    function exportAll(exportType, excelExport){


        if(!validate()) return false;
        var form = $('#exportAllDataForm');
        form.find('[name=exportType]').val(exportType);
        form.find('[name=langIds]').val(getExportLangIds());
        form.find('[name=excelExport]').val(excelExport);

        exportType =form.find('[name=exportType]').val();
        let langIds = form.find('[name=langIds]').val();
        excelExport = form.find('[name=excelExport]').val();
        let ids = form.find('[name=ids]').val();

        $.ajax({
            url: '<%=request.getContextPath()%>/admin/exportData.jsp?action=isDwnldOnBrowser&exportType='+exportType+'&langIds='+langIds+'&excelExport='+excelExport+'&ids='+ids, 
            type: 'POST', 
            dataType: 'json',
        })
        .always(function (resp) {
            if(resp.status == "true")
            {
                form.get(0).submit();
            }else{
                insertIntoBatch(exportType,langIds,excelExport,ids);
            }
        });
    }
    
    function insertIntoBatch(exportType,langIds,excelExport,ids){
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/exportData.jsp?action=insert&exportType='+exportType+'&langIds='+langIds+'&excelExport='+excelExport+'&ids='+ids, 
            type: 'POST', 
            dataType: 'json',
        })
        .always(function (resp) {
            if(resp.status == "true")
            {
                bootNotify(resp.message);
                setTimeout(checkExportStatus, 10000,exportType,langIds,excelExport,ids);
            }else{
                bootNotifyError(resp.message);
            }
        });
    }

    function checkExportStatus(exportType,langIds,excelExport,ids){
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/exportData.jsp?action=check&exportType='+exportType+'&langIds='+langIds+'&excelExport='+excelExport+'&ids='+ids, 
            type: 'POST', 
            dataType: 'json',
        })
        .always(function (resp) {
            if(resp.status == "exported"){
                downloadFile(resp.url);
            }else if(resp.status == "false"){
                bootNotifyError(resp.message);
            }else{
                bootNotify("File is being prepared for the Export");
                setTimeout(checkExportStatus, 15000,exportType,langIds,excelExport,ids);
            }
        });
    }
    function downloadFile(filePath){
        let temp="../"+filePath;
        var link=document.createElement('a');
        link.href = temp;
        link.target = "_blank";
        link.download = temp.substr(temp.lastIndexOf('/') + 1);
        link.click();

        setTimeout(deleteFileIfExist, 1000,filePath);
        
    }
    function deleteFileIfExist(filePath){
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/exportData.jsp?action=deleteFile&filePath='+filePath, 
            type: 'POST', 
            dataType: 'json',
        })
        .always(function (resp) {
        });
    }

    function downloadIfFileExist(){
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/exportData.jsp?action=checkFileExist', 
            type: 'POST', 
            dataType: 'json',
        })
        .always(function (resp) {
            if(resp.status=="true"){
                let filesArray = resp.files.split("$");
                for(let i=0;i<filesArray.length;i++){
                    downloadFile(resp.url+filesArray[i]);
                }
            }else if(resp.status!="false"){
                bootNotify("File is under "+resp.message);
                setTimeout(downloadIfFileExist, 8000);
            }
        });
    }

</script>
    </body>
</html>