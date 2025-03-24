<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    String siteId = getSiteId(session);
    boolean isSuperAdmin = isSuperAdmin(Etn);
    
    String q = null;
    
    String batchId = parseNull(request.getParameter("batch_id"));
	
    String messgae = "";
    String updateTime = "";
    String status = "";
    String color = "";
    
	if(batchId.length() > 0){
        Set rs = Etn.execute("select message,updated_ts,status from batch_imports where id = "+escape.cote(batchId));
        if(rs.next()){
            messgae=rs.value("message");
            updateTime=rs.value("updated_ts");
            status=rs.value("status");
            status=status.substring(0, 1).toUpperCase() + status.substring(1);
        }
    }


%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Import</title>

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
                <h1 class="h2">Import</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" onclick="refreshEngine()" class="btn btn-success mr-2" >Refresh</button>
                    <button type="button" class="btn btn-primary"
                        onclick="goBack('load.jsp')">Back</button>
                </div>
            </div>
            <div id="importFormRow" class="row tableRow">
                <div class="col">
                <%if(!status.equalsIgnoreCase("Importing")){%>
                    <form class="form-inline" action="" onsubmit="return false;">
                        <select id="importType" name="importType" class="custom-select mr-2"
                                onchange="onChangeImportType(this)">
                            <option value="keep">Keep existing data</option>
                            <option value="replace">Replace existing data</option>
                            <option value="duplicate">Duplicate</option>
                        </select>
                        <select id="importTypeReplace" name="importTypeReplace"
                            class="custom-select mr-2" style="display:none;">
                            <option value="partial">Replace partial</option>
                            <option value="all">Replace all</option>
                        </select>
                        <%if(!(status.equalsIgnoreCase("Import error")||status.equalsIgnoreCase("Load error"))){%>
                            <button type="button" class="btn btn-primary"
                                onclick="onImport()">Import</button>
                        <%}%>
                        <button type="button" class="btn btn-warning ml-2"
                            onclick="onVerify()">Verify</button>
                        <button type="button" class="btn btn-danger ml-2"
                            onclick="onIgnore()">Ignore</button>
                        <% if(isSuperAdmin){ %>
                        <div class="form-check form-check-inline ml-1 small" >
                          <input class="form-check-input" type="checkbox" name="importDatetime" value="1"
                            id="importDateTimeCheckbox"
                            onchange="onChangeImportDatetime(this)">
                          <label class="form-check-label" style="height: 50px;width: 300px;font-size:16px;">Import creation and last update datetime</label>
                        </div>
                        <% } %>
                    </form>
                <%}%>

                    <div><label style="font-size:15px; margin-top:15px"><b>Batch Status : </b>
                    <%if(status.equalsIgnoreCase("importing")){%>
                        <%=status%> <i class='fas fa-circle-notch fa-spin'></i>
                    <%}else{%>
                        <%=status%>
                    <%}%>
                    </label></div>
                    <%if(messgae.length() > 0){ 
                        if(status.equalsIgnoreCase("Import error")||status.equalsIgnoreCase("Load error")||status.equalsIgnoreCase("Ignored")){
                            color="red";
                        }else{
                            color="black";
                        }
                    %>
                    <div class="mt-3">Process started on:   <%=updateTime%></div> <div style="color:<%=color%>;"><%=messgae%></div>
                    <%}%>
                </div>
            </div>
            <div id="importTableRow" class="row tableRow mt-2">
                <div class="col">
                <form id="mainForm" action="" onsubmit="return false;" novalidate>

                    <table class="table table-hover table-vam" id="importTable" style="width: 100%;">
                        <thead class="thead-dark">
                            <tr>
                                <th scope="col" style="width: 30px;">
                                    <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                                </th>
                                <th scope="col">Item #</th>
                                <th scope="col">Name</th>
                                <th scope="col">Type</th>
                                <th scope="col">Status</th>
                                <th scope="col">Process</th>
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
    if('<%=batchId%>'==='' || '<%=batchId%>'===undefined){
        goBack('load.jsp');
    }
    $ch.contextPath = '<%=request.getContextPath()%>';
    $ch.itemsDataList = [];

    // ready function
    $(function() {
        $('#importType').val("keep");
        $('#catalogRow').hide();
        initImportTable();
        if('<%=status%>'==='Importing'){
            setTimeout(reloadStatus, 10000);
        }
    });

    function showItems(action,batchId){
        $.ajax({
            url: '<%=request.getContextPath()%>/admin/importMsgFetch.jsp?action='+action+'&batch_id='+batchId, 
            type: 'POST', 
            dataType: 'json',
        })
        .always(function (resp) {
            console.log(resp);
            if(resp.status == "true")
            {
                bootbox.alert({
                    message : resp.message,
                    size : 'large',
                    title : action+"ed"
                });
            }else{
                bootbox.alert({
                    message : resp.message,
                    size : 'large',
                    title : "Error"
                });
            }
        });
    }
    function showErrors(errorIds){
        bootbox.alert({
            message : errorIds,
            size : 'large',
            title : "Error Items"
        });
    }

    function initImportTable(){
        window.importTable = $('#importTable')
        .DataTable({
            responsive: true,
            deferRender : true,
            ajax :{
                url: 'loadFilesAjax.jsp', 
                type: 'POST', 
                dataType: 'json',
                data:{
                    batch_id:'<%=batchId%>',
                    request_type:'import',
                },
            },
            paging : false,
            order : [[1,'asc']],
            columns : [
                { "data": "id" , className : ""  },
                { "data": "id" , className : ""  },
                { "data": "name", className : ""},
                { "data": "type", className : "text-capitalize"},
                { "data": "status", className : ""},
                { "data": "process", className : ""},
            ],
            columnDefs : [
                { targets : [0] , searchable : false,  orderable : false },
                { targets : [0] ,
                    render: function ( data, type, row, meta ) {
                        return '<input type="checkbox" class="idCheck d-none d-sm-block" name="itemId" value='+data+' onclick="onCheckItem(this)" >';
                    }
                },
                { targets : [4] ,
                    render: function ( data, type, row, meta ) {

                        if(data === "new" || data === "existing"){
                            var color = (data === "new") ? "info" : "warning";
                            return "<span class='text-capitalize badge badge-"+color+"' > " + data +"</span>";
                        }
                        else if(data === "error"){
                            return '<button class="btn btn-danger btn-sm py-0 px-1" type="button" '
                                +'  onclick="viewItemError(this)"> <span class="text-capitalize" > '
                                + data + '</span> (click to view)</button>';
                        }
                        else {
                            return data;
                        }
                    }
                }
            ],
            select: {
                style       : 'multi',
                className   : 'bg-published',
                selector    : 'td.noselector' //dummyselector
            },
            createdRow : function ( row, data, index ) {
                $(row).data('item-id',data.id);
                $(row).data('item-data',data);
            },
            initComplete : function(settings){
                try{
                    var table = settings.oInstance.api();

                    var container =  $(table.table().container());

                    var importFormRow = $('#importFormRow');

                    var targetDiv = container.find('.row:first > [class*=col]:first');

                    if(targetDiv.length > 0){
                        targetDiv.append(importFormRow);
                    }
                }
                catch(ex){
                    //do nothing
                }

            }
        });
    }
    function onCheckItem(check){
        check = $(check);
        var row = importTable.row(check.parents('tr:first'));

        if(check.prop('checked')){
            row.select();
        }
        else{
            row.deselect();
        }
    }

    function onChangeCheckAll(checkAll){
        var allChecks = importTable.rows().nodes().to$().find('.idCheck');

        allChecks.prop('checked',$(checkAll).prop('checked'));

        allChecks.each(function(index, el) {
           $(el).triggerHandler('click');
        });

    }

    function viewItemError(btn){
        var tr = $(btn).parents("tr:first");

        var error = tr.data("item-data").error;
        var heading = $("<span>").text("Error").addClass('h5')[0].outerHTML;
        var errorList = "";
        $.each(error.split(","), function(index, val) {
             if(val.trim().length > 0){
                errorList += $("<li>").addClass('text-danger')
                        .text(val)
                        [0].outerHTML;
             }
        });

        errorList = $("<ol>").html(errorList)[0].outerHTML;
        var html = heading+"<br>"+errorList;

        bootAlert(html,null,'');
    }

    function onChangeImportType(input){
        input = $(input);
        var val = $(input).val();

        var importTypeReplace = $('#importTypeReplace');
        if("replace" === val){

            bootConfirm("Are you sure you want to replace data?",
                function(isConfirm){
                    if(isConfirm){
                        importTypeReplace.show();
                    }
                    else{
                        input.val("keep");
                        importTypeReplace.hide();
                    }
                });
        }
        else{
            importTypeReplace.hide();
        }
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

    function onIgnore() {
        bootConfirm("Are you sure you want to ignore this batch?",
            function(isConfirm){
                if(isConfirm){
                    $.ajax({
                        url: 'loadFilesAjax.jsp', 
                        type: 'POST', 
                        dataType: 'json',
                        data:{
                            batch_id:'<%=batchId%>',
                            request_type:'ignore',
                        },
                    })
                    .done(function(resp) {
                        var data = [];
                        if(resp.status == 1){
                            goBack('load.jsp');
                            // $('#importTable').DataTable().ajax.reload();
                            // window.location.reload();
                        }
                        else{
                            bootAlert("<span class='text-danger'>"+resp.message+"</span>", null, 'medium');
                        }
                        // verifyAllItems();
                    })
                    .fail(function() {
                        bootNotifyError("Error in contacting server.Please try again.");
                    })
                    .success(function() {
                    }).always(function(){
                        
                    });
                }
            }
        );
        
    }
    function onVerify() {
        $.ajax({
            url: 'loadFilesAjax.jsp', 
            type: 'POST', 
            dataType: 'json',
            data:{
                batch_id:'<%=batchId%>',
                request_type:'verify',
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                // bootAlert(resp.message, null, 'medium');
                // window.location.reload();
                goBack('load.jsp');
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
        }).always(function(){
            
        });
    }


    function onImport(){
        var rows = importTable.rows( { selected: true } ).nodes().to$();

        if(rows.length == 0){
            bootNotify("No items selected");
            return false;
        }



        var count = {
            "new" : 0,
            "existing" : 0,
            "error" : 0
        };

        var items = [];
        $.each(rows, function(index, row) {
            var itemData = $(row).data('item-data');
            var itemStatus = itemData.status;
            count[itemStatus] += 1;
            if(itemStatus == "new" || itemStatus == "existing"){
                items.push(itemData.id);
            }
        });

        var msg = "You have selected " + rows.length + " items.<br>"
                    + count["new"] + " new, "
                    + count["existing"] + " existing and "
                    + count["error"] + " with error (ignored)."
                    + "<br> Are you sure you want to import these items ? ";

        bootConfirm(msg,
            function(isConfirm){
                if(isConfirm){
                    submitImportData(items);
                }
            });
    }

    function submitImportData(items){
        var importType = $('#importType').val()==undefined ?'':$('#importType').val();
        var importTypeReplace = $('#importTypeReplace').val()==undefined ?'':$('#importTypeReplace').val();
        var importDatetime = $('#importDatetime').val()==undefined ?'':$('#importDatetime').val();
        var targetCatalogId = $('#targetCatalog').val()==undefined ?'':$('#targetCatalog').val();

        let jsonInfo={'importType':importType,'importTypeReplace':importTypeReplace,'importDatetime':importDatetime,'targetCatalogId':targetCatalogId,'clientId':'<%=Etn.getId()%>','isSuperAdmin':'<%=isSuperAdmin(Etn)%>'};

        var formData = new  FormData();
        formData.append("jsonInfo", JSON.stringify(jsonInfo));
        formData.append("itemsJson", items.toString());
        formData.append("batchId", '<%=batchId%>');

        $.ajax({
            url: 'importAjax.jsp', type: 'POST', dataType: 'json',
            enctype : 'multipart/form-data',
            processData : false,
            contentType : false,
            cache : false,
            data: formData,
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

	
	function reloadStatus(){
        $('#importTable').DataTable().ajax.reload();
        if('<%=status%>'==='Importing'){
            setTimeout(reloadStatus, 10000);
        }
	}

</script>
    </body>
</html>