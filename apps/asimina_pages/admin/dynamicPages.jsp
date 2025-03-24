<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.List "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    Set rs = null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title>Dynamic pages List</title>

    <style type="text/css">
        .table-danger .deleteBtn/*, .bg-changed .deleteBtn*/{
            display: none !important;
        }

        .table-danger .unpublishBtn{
            display: none !important;
        }

        .table-success .downloadBtn{
            display: inline-block !important;
        }

        .html-status-published .previewHtmlBtn{
            display: inline-block !important;
        }
    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Dynamic", ""});
        breadcrumbs.add(new String[]{"Pages", ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                <h1 class="h2">Dynamic Pages</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" hidden="true" class="btn btn-danger mr-2"
                        onclick="deleteSelectedPages();">Delete</button>
                    <div class="btn-group mr-2">
                        <button class="btn btn-danger" type="button"
                        onclick="onPublishUnpublish('publish')">Publish</button>
                        <button class="btn btn-danger" type="button"
                        onclick="onPublishUnpublish('unpublish')">Unpublish</button>
                    </div>

                    <div class="btn-group mr-2">
                        <button class="btn btn-danger" type="button"
                        onclick="onGeneratePageHtml('generate')">Generate HTML</button>
                        <button class="btn btn-danger" type="button"
                        onclick="onGeneratePageHtml('delete')">Delete HTML</button>
                    </div>


                    <button type="button" class="btn btn-primary mr-2"
                    onclick="goBack('')">Back</button>

                    <button type="button" class="btn btn-primary mr-2"
                    onclick="refreshPagesTable();" title="Refresh"><i data-feather="refresh-cw"></i></button>

                    <button class="btn btn-success"
                    data-toggle="modal" data-target="#modalAddEditPage"
                    data-caller="Add">Add a Page</button>

                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Dynamic pages');" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>
                </div>
            </div>
           
            <table class="table table-hover table-vam" id="pagesTable" style="width:100%;">
                <thead class="thead-dark">
                    <tr>
                        <th scope="col">
                            <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                        </th>
                        <th scope="col">Page Name</th>
                        <th scope="col">Published Path</th>
                        <th scope="col">Variant</th>
                        <th scope="col">Publish Status</th>
                        <th scope="col">HTML Status</th>
                        <th scope="col">Last Changes</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- loaded by ajax -->
                </tbody>
            </table>
            <div id="actionsCellTemplate" class="d-none" >
                <a class="btn btn-sm btn-primary " title="Edit"
                    href="#EDITORURL#?id=#PAGEID#">
                    <i data-feather="edit"></i></a>

                <button class="btn btn-sm btn-primary previewHtmlBtn d-none" title="Preview"
                    onclick='previewDynamicHtml(this)' >
                    <i data-feather="eye"></i>
                </button>

                <button class="btn btn-sm btn-primary " title="Settings"
                    data-toggle="modal" data-target="#modalAddEditPage"
                    data-caller="edit" data-page-id='#PAGEID#'>
                    <i data-feather="settings"></i>
                </button>
                <button class="btn btn-sm btn-primary " title="Copy"
                    data-toggle="modal" data-target="#modalCopyPage"
                    data-page-id='#PAGEID#'>
                    <i data-feather="copy"></i></button>

                <button class="btn btn-sm btn-danger deleteBtn" title="Delete"
                    onclick='deletePage("#PAGEID#")' >
                    <i data-feather="trash-2"></i></button>

                <div class="btn-group downloadBtn" style="display: none;">
                    <button class="btn btn-sm btn-primary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" >
                    <i data-feather="download"></i></a></button>
                    <div class="dropdown-menu dropdown-menu-right " style="min-width: auto;" >
                        <a class="dropdown-item  p-2" href="javascript:void(0)"
                            onclick='downloadDynamicPageFiles("#PAGEID#", "index")'
                            >Index files</a>
                        <a class="dropdown-item  p-2" href="javascript:void(0)"
                            onclick='downloadDynamicPageFiles("#PAGEID#", "js_css")'
                            >JS/CSS files</a>
                        <a class="dropdown-item  p-2" href="javascript:void(0)"
                            onclick='downloadDynamicPageFiles("#PAGEID#", "project")'
                            >React files</a>
                    </div>
                </div>

                <button class="btn btn-sm btn-danger unpublishBtn" title="Unpublish"
                    onclick='unpublishPage(this)' >
                    <i data-feather="x"></i></button>

            </div>
            <!-- row-->
            <!-- container -->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>

    <!-- Modals -->
    <div class="modal fade" id="modalCopyPage" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="copyPageForm" action="" novalidate>
                    <input type="hidden" name="requestType" value="copyReactPage">
                    <input type="hidden" name="pageId" value="">

                    <div class="modal-header">
                        <h5 class="modal-title" id="">Copy React Page</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="form-group row">
                                <label class="col col-form-label">Copy From</label>
                                <div class="col-8">
                                    <input type="text" name="pageName" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col col-form-label">New Page Name</label>
                                <div class="col-8">
                                    <input type="text" name="name" class="form-control" value=""
                                    required="required" maxlength="100" >
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
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
                            <div class="form-group row">
                                <label  class="col-sm-3 col-form-label">Variant</label>
                                <div class="col-sm-9">
                                    <select class="custom-select" name="variant" >
                                        <option value="all">All</option>
                                        <option value="anonymous">Anonymous</option>
                                        <option value="logged">Logged</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label  class="col-sm-3 col-form-label">Language</label>
                                <div class="col-sm-9">
                                    <select class="custom-select" name="langue_code">
                                        <%
                                            for(Language lang:getLangs(Etn,session)){
                                        %>
                                        <option value='<%=lang.getCode()%>'><%=lang.getLanguage()%> - <%=lang.getCode()%></option>
                                        <%  }  %>
                                    </select>
                                </div>
                            </div>


                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary" >Save</button>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <%@ include file="dynamicPagesAddEdit.jsp"%>
    <%@ include file="pagesPublish.jsp"%>
<script type="text/javascript">

    // ready function
    $(function() {

        $ch.contextPath = '<%=request.getContextPath()%>/';
        
        $('#pagesTable tbody').tooltip({
            placement : 'bottom',
            html:true,
            selector:".custom-tooltip"
        });

        initPagesTable();

        $('#modalCopyPage').on('show.bs.modal', function(event){
            var button = $(event.relatedTarget);
            var modal  = $(this);

            var form = $('#copyPageForm');
            form.get(0).reset();


            var tr = button.parents('tr:first');
            var pageId = tr.data('page-id');
            var pageName = tr.find('td.pageName').text();

            form.find('[name=pageId]').val(pageId);
            form.find('[name=pageName]').val(pageName);

        });


        $('#copyPageForm').submit(function(event) {
            event.preventDefault();
            event.stopPropagation();
            onCopyPage();
        });

        autoRefreshPages();
    });

    function initPagesTable(){

        window.pagesTable = $('#pagesTable')
        .DataTable({
            // dom : "<flipt>",
            // deferRender : true,
            responsive: true,
            pageLength : 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function(data, callback, settings){
                getPagesList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
                { "data": "id"  },
                { "data": "name", className : "pageName"},
                { "data": "published_path" },
                { "data": "variant", className : "text-capitalize d-none"},
                { "data": "publish_status", className : "" },
                { "data": "get_html_status", className : "" },
                { "data": "updated_ts" },
                { "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
                { targets : [0,6] , searchable : false, orderable : false},
                { targets : [0] ,
                    render: function ( data, type, row ) {
                        if(type == 'display'){
                            return '<input type="checkbox" class="idCheck d-none d-sm-block <%=Constant.PAGE_TYPE_REACT%>" name="pageId" onclick="onCheckItem(this)" value="'+data+'" >';
                        }
                        else{
                            return data;
                        }
                    }
                },
                { targets : [6] ,
                    render: function ( data, type, row ) {
                        //for datetime columns
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
                        }
                        else {
                            var html = data;
                            var toolTipText = "";
                            
                            if(data && row.updatedby)
                                toolTipText += "Last change: By "+ row.updatedby;
                            
                            if(row.published_ts){  
                                toolTipText += "<br>Last publication: "+ row.published_ts;
                                if(row.publishedby) toolTipText += " by "+ row.publishedby;
                            }

                            html+=' '+
                            '<a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="'+toolTipText+'">'+
                                feather.icons.info.toSvg()+
                            '</a>'; 
                            return html;
                        }

                    }
                },
                { targets : [4] ,
                    render: function ( data, type, row ) {
                        //for publish status
                        if(type == 'display' && data == 'error'){
                            var viewBtn = "&nbsp;<button type='button' class='btn btn-sm btn-secondary py-1' onclick='viewLog(this,\"getLog\")'>view</button> "
                            return data + viewBtn;
                        }
                        else {
                            return data;
                        }

                    }
                },
                { targets : [5] ,
                    render: function ( data, type, row ) {
                        //for publish status
                        if(type == 'display' && data == 'error'){
                            var viewBtn = "&nbsp;<button type='button' class='btn btn-sm btn-secondary py-1' onclick='viewLog(this,\"getHtmlLog\")'>view</button> "
                            return data + viewBtn;
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
                $(row).data('page-id',data.id);
                var pubStatus = "unpublished";
                if(data.publish_status === 'published'){
                    pubStatus = "published";
                    if(getMoment(data.published_ts).isBefore(getMoment(data.updated_ts))){
                        pubStatus = "changed";
                    }
                }
                $(row).addClass('table-'+(pubStatus=='published'?'success':'danger') + ' html-status-'+data.get_html_status);

            },
        });
    }

    function onCheckItem(check){
        check = $(check);
        var row = window.pagesTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.pagesTable.table().body()).find('.idCheck');
        }
        else{
            //un select all
            var allChecks = window.pagesTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked',isChecked);

        allChecks.each(function(index, el) {
           $(el).triggerHandler('click');
        });

    }

    function getPagesList(data, callback, settings){
        // showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getPagesListDynamic',
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.pages;
                var actionTemplate = $('#actionsCellTemplate').html();
                $.each(data, function(index, val) {
                    var curId = val.id;
                    if(val.publish_status === "none"){
                        val.publish_status = "";
                    }

                    var published_path = "";
                    if(val.published_path.length > 0){
                        var url = $ch.contextPath+val.published_path;
                        published_path = '<a href="'+url+'" target="'+url+'">'+val.path+'/index.html</a>';
                    }
                    val.published_path = published_path;

                    var editorUrl = "dynamicPageEditor.jsp";
                    if(val.layout === 'css-grid'){
                        editorUrl = "dynamicPageEditor2.jsp";
                    }

                    val.actions = strReplaceAll(actionTemplate, "#EDITORURL#", editorUrl);
                    val.actions = strReplaceAll(val.actions, "#PAGEID#", curId);
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

    function onCopyPage(){
        var form = $('#copyPageForm');

        if( !form.get(0).checkValidity() ){
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            if(resp.status != 1){
                bootNotifyError(resp.message);
            }
            else{
                // generatePageHtml(resp.data.pageId, refreshPagesTable);
                bootNotify("Page copy created.")
                refreshPagesTable();
                $('#modalCopyPage').modal('hide');
            }
        })
        .always(function() {
            hideLoader();
        });

    }

    function deletePage(pageId){
        bootConfirm("Are you sure you want to delete this page ?",
            function(result){
                if(!result) return;

                var pageIds = [{id: pageId, type: '<%=Constant.PAGE_TYPE_REACT%>'}];
                deletePages(pageIds);

            });
    }

    function deleteSelectedPages(){
        var rows = window.pagesTable.rows( { selected: true } ).nodes().to$();

        if(rows.length == 0){
            bootNotify("No page selected");
            return false;
        }

        var publishedCount = 0;

        var deletedPages = [];
        $.each(rows, function(index, row) {
            deletedPages.push({id: $(row).data('page-id'), type: '<%=Constant.PAGE_TYPE_REACT%>'});
            if( !$(row).hasClass('table-danger') ){
                publishedCount += 1;
            }
        });

        var confirmMsg = ""+ deletedPages.length + " pages are selected. Are you sure you want to delete these pages? this action is not reversible.";

        if(publishedCount > 0){
            confirmMsg += "<br>Note: " +publishedCount + " page(s) are published. Published pages will not be deleted.";
        }

        bootConfirm(confirmMsg, function (result){
            if(result){
                deletePages(deletedPages);
            }
        });

    }

    function deletePages(pages){
        if(pages.length <= 0) {
            return false;
        }
        //for multi value parameters to work
        var params = $.param({
            requestType: 'deletePages',
            pages: JSON.stringify(pages)
        }, true);

        showLoader();
        $.ajax({
            url: 'publishUnpublishPagesAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function(resp) {
            if(resp.status != 1){
                bootAlert(resp.message + " ");
            }
            else{
                bootNotify(resp.message);
            }
            refreshPagesTable();
        })
        .always(function() {
            hideLoader();
        });

    }

    function unpublishPage(btn){
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var checkInput =  tr.find('.idCheck');
        checkInput.prop('checked',true);
        onCheckItem(checkInput);
        onPublishUnpublish('unpublish' , [$(checkInput)]);
    }


    function onPageSaveSuccess(resp, form){
        refreshPagesTable();
    }

    function refreshPagesTable(){
        window.pagesTable.ajax.reload(function(){
            $('#checkAll').triggerHandler('change');
        },false);
    }

    function autoRefreshPages(){
        setTimeout(function(){
            refreshPagesTable();
            autoRefreshPages();
        } , 2*60*1000);
    }

    //moved to common.js, remove later
    function getMoment(datetimeStr){
      return moment(datetimeStr, "DD/MM/YYYY HH:mm:ss");
    }

    function downloadDynamicPageFiles(pageId, requestType){
        var downloadDiv = $("#downloadDiv");
        if(downloadDiv.length == 0){
            $("body").append("<div id='downloadDiv' class='d-none'>");
            downloadDiv = $("#downloadDiv");
        }

        var url = "dynamicPageDownloader.jsp?requestType=" + requestType + "&id="+pageId;
        downloadDiv.append("<iframe src='"+url+"'>");
    }

    function viewLog(btn, requestType){
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var pageId = tr.data('page-id');

        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : requestType,
                id : pageId
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                var logStr = resp.data.log;
                logStr = strReplaceAll(resp.data.log,"\n","<br>");
                bootbox.alert({
                    message : logStr,
                    size : 'large',
                    title : "View log"
                });
            }
        })
        .always(function() {
            hideLoader();
        });

    }


    function onGeneratePageHtml(action, confirmed){
        var rows = window.pagesTable.rows( { selected: true } ).nodes().to$();

        if(rows.length == 0){
            bootNotify("No pages selected");
            return false;
        }

        var count = 0;

        var ids = [];
        $.each(rows, function(index, row) {
            ids.push($(row).data('page-id'));
        });

        if(!confirmed){
            var confirmMsg = "Are you sure you want to generate HTML of " + ids.length + " pages ? ";
            bootConfirm(confirmMsg,
                function(result){
                    if(!result) return;
                    onGeneratePageHtml(action, true);
                });
            return false;
        }


        //for multi value parameters to work
        var params = $.param({
            requestType : 'generateHtml',
            isGenerate : (action == "generate"?"1":"0"),
            ids : ids
        },true);

        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function(resp) {
            if(resp.status != 1){
                bootAlert(resp.message + " ");
            }
            else{
                bootNotify(resp.message);
            }
            refreshPagesTable();
        })
        .always(function() {
            hideLoader();
        });

    }

    function previewDynamicHtml(btn){
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var pageId = tr.data('page-id');

        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getDynamicHtml',
                id : pageId
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                var dynamicHtml = resp.data.html;
                dynamicHtml = $("<div>").text(dynamicHtml).html();
                dynamicHtml = strReplaceAll(dynamicHtml,"\n","<br>");
                bootbox.alert({
                    message : dynamicHtml,
                    size : 'large',
                    title : "Generated HTML"
                });
            }
        })
        .always(function() {
            hideLoader();
        });

    }

</script>
    </body>
</html>