<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.pages.EntityExport"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>

<%

    String exportType = parseNull(request.getParameter("exportType"));
    String exportLabel = parseNull(request.getParameter("exportLabel"));
    if (!EntityExport.isValidExportImportType(exportType)) {
        response.sendRedirect("export.jsp");
    }

    String nameColumn = exportType.replaceAll("_", " ");
    if (nameColumn.endsWith("s")) {
        nameColumn = nameColumn.substring(0, nameColumn.length() - 1);
    }
    if (exportLabel.length() == 0) {
        exportLabel = exportType.replaceAll("_", " ");
    }

    boolean showType = true;
    boolean showFolder = false;
    String typeHeaderName = "Type";
    if (exportType.equals("libraries") || exportType.equals("variables")) {
        showType = false;
    }
    else {
        switch (exportType) {
            case "blocs":
            case "structured_contents":
                typeHeaderName = "Template";
                break;
            // case "structured_pages":
            case "products":
                typeHeaderName = "Catalog / Type    ";
                break;
            case "page_templates":
                typeHeaderName  = "Custom ID";
        }
    }
    if (exportType.equals("pages") || exportType.startsWith("structured_")
        || exportType.equals("products") ||exportType.equals("stores")) {
        showFolder = true;
    }

    Set rs = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title>Export <%=exportLabel%>
    </title>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Tools", ""});
        breadcrumbs.add(new String[]{"Export", "export.jsp"});
        breadcrumbs.add(new String[]{exportLabel, ""});

    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
        <!-- beginning of container -->
        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Export <%=exportLabel%>
                </h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-primary mr-2"
                            onclick="goBack('export.jsp')">Back
                    </button>
                    <button type="button" class="btn btn-primary mr-2"
                            onclick="refreshTable();" title="Refresh">
                        <i data-feather="refresh-cw"></i></button>
                    <div class="btn-group mr-2">
                        <button style="cursor: default" class="btn btn-warning" type="button" disabled>
                            Export
                        </button>
                        <button class="btn btn-success" type="button"
                                onclick="exportSelected(0)">Json
                        </button>
                        <button class="btn btn-success" type="button"
                                onclick="exportSelected(1)">Excel
                        </button>
                    </div>
                </div>
            </div>
            <!-- row -->
            <%@include file="exportLangSelection.jsp"%>
            <form id="mainForm" action="" onsubmit="return false;" novalidate>
                        <input type="hidden" name="exportType" id="exportType" value="<%=exportType%>">
                        <table class="table table-hover table-vam" id="exportTable" style="width: 100%;">
                            <thead class="thead-dark">
                                <tr>
                                    <th scope="col" style="width: 30px;">
                                        <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                                    </th>
                                    <th scope="col" style="text-transform: capitalize;"><%=nameColumn%> name</span></th>
                                    <th scope="col"><%=typeHeaderName%></th>
                                    <th scope="col">Folder</th>
                                </tr>
                            </thead>
                            <tbody>
                            <!-- loaded by ajax -->
                            </tbody>
                        </table>
                    </form>
                <!-- row-->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>

    <div class="d-none">
        <form id="exportDataForm" action="exportData.jsp" method="POST">
            <input type="hidden" name="exportType" value="<%=exportType%>">
            <input type="hidden" name="langIds" value="">
            <input type="hidden" name="ids" value="">
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
        window.exportTable.ajax.reload(function(){
            $('#checkAll').triggerHandler('change');
        },false);
    }

    function initExportTable() {

        window.exportTable = $('#exportTable')
        .DataTable({
            // dom : "<flipt>",
            // deferRender : true,
            responsive: true,
            pageLength : 100,
			lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function (data, callback, settings) {
                getExportsList(data, callback, settings);
            },
            order : [[3, 'asc'], [2, 'asc'], [1, 'asc']],
            columns : [
                {"data" : "id", className : ""},
                {"data" : "name", className : ""},
                {"data" : "type", className : '<%=showType?"":"d-none"%>'},
                {"data" : "folder_name", className : '<%=showFolder?"":"d-none"%>'},
            ],
            columnDefs : [
                {targets : [0], searchable : false, orderable : false},
                {
                    targets : [0],
                    render : function (data, type, row, meta) {
                        return '<input type="checkbox" class="idCheck d-none d-sm-block" name="itemId" value=' + data + ' onclick="onCheckItem(this)" >';
                    }
                }
            ],
            select : {
                style       : 'multi',
                className   : 'bg-published',
                selector    : 'td.noselector' //dummyselector
            },
            createdRow : function ( row, data, index ) {
                $(row).data('item-id',data.id);
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
                requestType : 'getExportSelectList',
                exportType : $('#exportType').val()
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.exports;
                // var actionTemplate = $('#actionsCellTemplate').html();
                // $.each(data, function(index, val) {
                //     var curId = val.id;
                //     val.actions = strReplaceAll(actionTemplate, "#ID#", curId);
                // });
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

    function onCheckItem(check){
        check = $(check);
        var row = window.exportTable.row(check.parents('tr:first'));

        if(check.prop('checked')){
            row.select();
        }
        else{
            row.deselect();
        }
    }

    function onChangeCheckAll(checkAll){
        var isChecked = $(checkAll).prop('checked');

        if(isChecked){
            //select only visible
            var allChecks = $(window.exportTable.table().body()).find('.idCheck');
        }
        else{
            //un select all
            var allChecks = window.exportTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked',isChecked);

        allChecks.each(function(index, el) {
           $(el).triggerHandler('click');
        });

    }

    function validate() {
        return validateExportLangIds();
    }

    function exportSelected(excelExport){
        var rows = exportTable.rows( { selected: true } ).nodes().to$();

        var ids = [];
        $.each(rows, function(index, row) {
            ids.push($(row).data('item-id'));
        });

        if(ids.length === 0){
            bootNotify("No item selected.");
            return false;
        }
        else if(!validate()){
            return false;
        }

        var form = $('#exportDataForm');
        form.find('[name=ids]').val(ids.join(','));
        form.find('[name=langIds]').val(getExportLangIds());
        form.find('[name=excelExport]').val(excelExport);

        let exportType =form.find('[name=exportType]').val();
        let langIds = form.find('[name=langIds]').val();
        excelExport = form.find('[name=excelExport]').val();
        let idsTemp = form.find('[name=ids]').val();
        
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/exportData.jsp', 
            type: 'POST', 
            dataType: 'json',
            data: {
                "action": "isDwnldOnBrowser",
                "exportType": exportType,
                "langIds" : langIds,
                "excelExport" : excelExport,
                "ids" : idsTemp
            }
        })
        .always(function (resp) {
            if(resp.status == "true")
            {
                form.get(0).submit();
            }else{
                insertIntoBatch(exportType,langIds,excelExport,idsTemp,ids);
            }
        });

    }

    function insertIntoBatch(exportType,langIds,excelExport,idsTemp,ids){
        
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/exportData.jsp', 
            type: 'POST', 
            dataType: 'json',
            data: {
                "action": "insert",
                "exportType": exportType,
                "langIds" : langIds,
                "excelExport" : excelExport,
                "ids" : idsTemp
            }
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
            url: '<%=request.getContextPath()%>/admin/exportData.jsp', 
            type: 'POST', 
            dataType: 'json',
            data:{
                "action":"check",
                "exportType": exportType,
                "langIds":langIds,
                "excelExport":excelExport,
                "ids":$('#exportDataForm').find('[name=ids]').val(),
            }
        })
        .always(function (resp) {
            if(resp.status == "exported"){
                downloadFile(resp.url);
            }else if(resp.status == "false"){
                bootNotifyError(resp.message);
            }else{
                bootNotify("File is preparing to export.");
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
                setTimeout(downloadIfFileExist, 1000);
            }
        });
    }

</script>
    </body>
</html>