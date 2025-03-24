<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    final String STRUCTURED_CONTENT = "content";
    final String STRUCTURED_PAGE = "page";

    String q = "";
	Set rs = null;
    // String siteId = getSiteId(session);//debug

    String catalogId = parseNull(request.getParameter("cid"));

    q = "SELECT id, name FROM structured_catalogs "
        + " WHERE id = " + escape.cote(catalogId)
        + " AND site_id = " + escape.cote(getSiteId(session));

    String backUrl = "structuredCatalogs.jsp";
    String editorUrl = "structuredContentEditor.jsp";
    String templateType = Constant.TEMPLATE_STRUCTURED_CONTENT;

    boolean isPage = false;
    if(structureType.equals(STRUCTURED_PAGE)){
        backUrl = "structuredPageCatalogs.jsp";
        editorUrl = "structuredPageEditor.jsp";
        templateType = Constant.TEMPLATE_STRUCTURED_PAGE;
        isPage = true;
    }

    Set catRs = Etn.execute(q);
    if(!catRs.next()){
        response.sendRedirect(backUrl);
    }
    String catName = catRs.value("name");

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title><%=catName%></title>

    <style type="text/css">
        .bg-published .deleteBtn, .bg-changed .deleteBtn{
            display: none !important;
        }

        .bg-unpublished .unpublishBtn{
            display: none !important;
        }
    </style>
</head>
<body class="app header-fixed sidebar-fixed sidebar-lg-show">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <%@ include file="/WEB-INF/include/sidebar.jsp" %>
        <main class="c-main">
            <!-- breadcrumb -->
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href='<%=GlobalParm.getParm("CATALOG_ROOT")%>/admin/gestion.jsp'>Home</a></li>
                    <li class="breadcrumb-item">Content</li>
                    <li class="breadcrumb-item"><a href='<%=backUrl%>'>Structured <%=structureType%></a></li>
                    <li class="breadcrumb-item"><%=catName%></li>
                </ol>
            </nav>
            <!-- /breadcrumb -->
            <!-- beginning of container -->
            <div class="container-fluid">

                <div class="row">
                    <div class="col-12">
                        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                            <h1 class="h2"><%=catName%></h1>
                            <div class="btn-toolbar mb-2 mb-md-0">
                                <button type="button" class="btn btn-danger mr-2"
                                onclick="deleteSelectedContents();">Delete</button>
                                <div class="btn-group mr-2">
                                    <button class="btn btn-danger" type="button"
                                    onclick="onPublishUnpublish('publish')">Publish</button>
                                    <button class="btn btn-danger" type="button"
                                    onclick="onPublishUnpublish('unpublish')">Unpublish</button>
                                </div>

                                <button type="button" class="btn btn-primary mr-2"
                                onclick="goBack('<%=backUrl%>')">Back</button>

                                <button type="button" class="btn btn-primary mr-2"
                                onclick="refreshDataTable();" title="Refresh"><i data-feather="refresh-cw"></i></button>

                                <a class="btn btn-success" title="Add a content"
                                    href="<%=editorUrl%>?cid=<%=catalogId%>">
                                    Add a <%=structureType%></a>
                            </div>
                        </div>
                    </div>
                </div><!-- row -->
                <div class="row mb-2">
                    <div class="col-12">
                        <div class="small">
                            <strong>Legend : </strong>
                            <span class="bg-published rounded p-1" >Published</span>
                            <span class="bg-changed rounded p-1" >Published(Changes pending to publish)</span>
                            <span class="bg-unpublished rounded p-1 text-muted" >Not Published</span>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col">
                        <table class="table table-hover table-vam" id="contentsTable" style="width:100%;">
                            <thead class="thead-dark">
                                <tr>
                                    <th scope="col">
                                        <input type="checkbox" class="" id="checkAll" onchange="onChangeCheckAll(this)">
                                    </th>
                                    <th scope="col">Description name</th>
                                    <th scope="col">Nb use</th>
                                    <th scope="col">Last changes</th>
                                    <th scope="col">Publish status</th>
                                    <th scope="col">Last publication</th>
                                    <th scope="col">Next publication</th>
                                    <th scope="col">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- loaded by ajax -->
                            </tbody>
                        </table>
                        <div id="actionsCellTemplate" class="d-none" >
                            <a class="btn btn-sm btn-primary " title="Edit"
                                href="<%=editorUrl%>?cid=<%=catalogId%>&id=#ID#">
                                <i data-feather="edit"></i></a>
                            <button class="btn btn-sm btn-primary " title="Copy"
                                onclick="copyContent(this)">
                                <i data-feather="copy"></i></button>

                            <button class="btn btn-sm btn-danger deleteBtn" title="Delete"
                                onclick="deleteContent('#ID#')" >
                                <i data-feather="trash-2"></i></button>

                            <button class="btn btn-sm btn-danger unpublishBtn" title="Unpublish"
                                onclick='unpublishContent(this)' >
                                <i data-feather="x"></i></button>

                        </div>
                    </div>
                </div><!-- row-->

            </div>
            <!-- container -->
            <!-- /end of container -->
        </main>
    </div>
    <%@ include file="/WEB-INF/include/footer.jsp" %>

    <!-- Modals -->
    <div class="modal fade" id="modalCopyContent" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="formCopyContent" action="" novalidate onsubmit="return false;">
                    <input type="hidden" name="requestType" value="copyContent">
                    <input type="hidden" name="contentId" value="">

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
                                    required="required" maxlength="100" >
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row pagePathRow">
                                <label  class="col-sm-3 col-form-label">Path</label>
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
                        <button type="button" class="btn btn-primary" onclick="onCopyContentSave()" >Save</button>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

<%@ include file="structuredContentsPublish.jsp"%>

<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>/';
    $ch.structureType = '<%=structureType%>';
    // ready function
    $(function() {

    	initDataTable();

    });

    function initDataTable(){

    	window.contentsTable = $('#contentsTable')
        .DataTable({
            // dom : "<flipt>",
            // deferRender : true,
            responsive: true,
            pageLength : 100,
            ajax : function(data, callback, settings){
            	getContentsList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
            	{ "data": "id"   },
            	{ "data": "name", className : "contentName"},
            	{ "data": "nb_use", className : "d-none" },
                { "data": "updated_ts" },
                { "data": "publish_status" , className: "text-capitalize "},
                { "data": "published_ts", },
                { "data": "to_publish_ts" , className: 'text-capitalize <%=isPage?"":"d-none"%> '},
            	{ "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
            	{ targets : [0,7] , searchable : false},
            	{ targets : [0,7] , orderable : false},
                { targets : [0] ,
                    render: function ( data, type, row ) {
                        return '<input type="checkbox" class="idCheck" name="id" onclick="onCheckItem(this)" value="'+data+'" >';
                    }
                },
                { targets : [3,5] ,
                    render: function ( data, type, row ) {
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
                        }
                        else {
                            return data;
                        }

                    }
                },
            ],
            select: {
                style       : 'multi',
                className   : '',
                selector    : 'td.noselector' //dummyselector
            },
            createdRow : function ( row, data, index ) {
                $(row).data('content-id',data.id);
                var pubStatus = data.ui_status;
                $(row).addClass('bg-'+pubStatus);
            },
        });
    }

    function onCheckItem(check){
        check = $(check);
        var row = window.contentsTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.contentsTable.table().body()).find('.idCheck');
        }
        else{
            //un select all
            var allChecks = window.contentsTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked',isChecked);

        allChecks.each(function(index, el) {
           $(el).triggerHandler('click');
        });

    }

    function getContentsList(data, callback, settings){
    	// showLoader();
    	$.ajax({
    		url: 'structuredContentsAjax.jsp', type: 'POST', dataType: 'json',
    		data: {
    			requestType : 'getList',
                catalogId : '<%=catalogId%>'
    		},
    	})
    	.done(function(resp) {
    		var data = [];
    		if(resp.status == 1){
    			data = resp.data.contents;
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

    function copyContent(button){
        var isPage = $ch.structureType == 'page';

        button = $(button);
        var modal  = $("#modalCopyContent");

        var form = $('#formCopyContent');
        form.get(0).reset();
        form.removeClass('was-validated');

        if(isPage){
            form.find('.pagePathRow').show();
            form.find('[name=path]').val();
        }
        else{
            form.find('.pagePathRow').hide();
            form.find('[name=path]').val("dummy");
        }

        var tr = button.parents('tr:first');
        var contentId = tr.data('content-id');
        var contentName = tr.find('td.contentName').text();

        form.find('[name=contentId]').val(contentId);
        form.find('[name=contentName]').val(contentName);

        modal.modal('show');
    }

    function onCopyContentSave(){
        var form = $('#formCopyContent');

        if( !form.get(0).checkValidity() ){
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url: 'structuredContentsAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status != 1){
                bootNotifyError(resp.message);
            }
            else{
                bootNotify("Copy created.")
                refreshDataTable();
                $('#modalCopyContent').modal('hide');
            }
        })
        .always(function() {
            hideLoader();
        });

    }

    function deleteContent(id){

    	bootConfirm("Are you sure you want to delete this "+$ch.structureType+" ?",
    		function(result){
    			if(!result) return;

    			var idsList = [id];
                deleteContents(idsList);

    		});
    }

    function deleteSelectedContents(){
        var rows = window.contentsTable.rows( { selected: true } ).nodes().to$();

        if(rows.length == 0){
            bootNotify("No "+$ch.structureType+" selected");
            return false;
        }

        var publishedCount = 0;

        var idsList = [];
        $.each(rows, function(index, row) {
            var curId = $(row).data('content-id');
            idsList.push(curId);
            if( !$(row).hasClass('bg-unpublished') ){
                publishedCount += 1;
            }
        });

        var confirmMsg = ""+ idsList.length + " "+$ch.structureType+"s are selected. Are you sure you want to delete these "+$ch.structureType+"s? this action is not reversible.";

        if(publishedCount > 0){
            confirmMsg += "<br>Note: " +publishedCount + " "+$ch.structureType+"(s) are published. Published "+$ch.structureType+"s will not be deleted.";
        }

        bootConfirm(confirmMsg, function (result){
            if(result){
                deleteContents(idsList);
            }
        });

    }

    function deleteContents(idsList){
        if(idsList.length <= 0){
            return false;
        }

        //for multi value parameters to work
        var params = $.param({
            requestType : 'deleteContents',
            ids : idsList
        },true);

        showLoader();
        $.ajax({
            url: 'structuredContentsAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function(resp) {
            if(resp.status != 1){
                bootAlert(resp.message + " ");
            }
            else{
                bootNotify(resp.message);
            }
            refreshDataTable();
        })
        .always(function() {
            hideLoader();
        });

    }

    function unpublishContent(btn){
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var checkInput =  tr.find('.idCheck');
        checkInput.prop('checked',true);
        onCheckItem(checkInput);
        onPublishUnpublish('unpublish');
    }

    function refreshDataTable(){
        window.contentsTable.ajax.reload(function(){
            $('#checkAll').triggerHandler('change');
        },false);
    }

    function refreshPublishUnpublishStatus(action, responseStatus){
        refreshDataTable();
    }

</script>
    </body>
</html>