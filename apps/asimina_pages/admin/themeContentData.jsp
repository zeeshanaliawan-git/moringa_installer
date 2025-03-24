<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp"%>
<%
     String selectedSiteId = getSiteId(session);
     String themeUuid = parseNull(request.getParameter("themeId"));
     String themeContent = parseNull(request.getParameter("content"));
     String title = "";
     String themeId  = "";
     String q = "SELECT * FROM themes WHERE site_id = "+escape.cote(selectedSiteId)+" AND uuid = "+escape.cote(themeUuid);
     Set rs =  Etn.execute(q);
     if(rs.next()){
          themeId = parseNull(rs.value("id"));
          title = "Content of theme : "+rs.value("name")+" V"+rs.value("version");
     } else{
         response.sendRedirect("themeContents.jsp?id="+themeUuid);
     }
     String themeStatus = rs.value("status");
     boolean isLocked =  themeStatus.equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn);
     String THEME_FILE_URL_PREPEND = parseNull(getThemeURLPrepend()) + selectedSiteId + "/"+themeUuid;

     boolean active = true;
    List<Language> langsList = getLangs(Etn,selectedSiteId);

%>

<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <script src="<%=request.getContextPath()%>/js/jquery.lazy.min.js"></script>

    <title>Theme Content Data</title>
    <style type="text/css">
        .bg-published .deleteBtn, .bg-changed .deleteBtn {
            display: none !important;
        }

        #addContentItemModal{
            width:100vw !important;
            display:block !important;
        }
        #addContentItemModal:not(.show){
            left: -100%;
        }
    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Themes","themes.jsp"});
        breadcrumbs.add(new String[]{rs.value("name")+" V"+rs.value("version"),"themeContents.jsp?id="+themeUuid});
        breadcrumbs.add(new String[]{themeContent,""});

    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <input type="hidden" id="themeContent"  value="<%=escapeCoteValue(themeContent)%>" >
            <input type="hidden" id="themeUuid" value="<%=escapeCoteValue(themeUuid)%>">
            <input type="hidden" id="themeId" value="<%=escapeCoteValue(themeId)%>">
        <!-- beginning of container -->
             <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Theme <%=themeContent%></h1>
                 <div class="btn-toolbar mb-2 mb-md-0">
                    <div class="col-12">
                        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                            <div class="btn-toolbar mb-2 mb-md-0">
                                <a type="button" href="themeContents.jsp?id=<%=escapeCoteValue(themeUuid)%>" class="btn btn-primary mr-2">
                                    Back
                                </a>
                                <button class="btn btn-success mr-2" title="Add New"
                                    onclick='openAddNewItemModal()' <%if(isLocked){%>disabled<%}%> > Add New
                                </button>
                                <button class="btn btn-success mr-2" title="Sync"
                                    onclick='syncContentItems()'>
                                    <i data-feather="refresh-cw"></i>
                                </button>
                                <button class="btn btn-danger mr-2" title="Delete"
                                    onclick='deleteSelected()' <%if(isLocked){%>disabled<%}%> > Delete
                                </button>
                            </div>
                        </div>
                    </div>
                </div><!-- row -->
            </div>
            <div class="row">
                <div class="col">
                    <table class="table table-hover table-vam" id="themeContentDataTable" style="width:100%;">
                        <thead class="thead-dark">
                        <tr>
                            <th scope="col">
                                <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                            </th>
                            <% if(themeContent.equals(Constant.THEME_CONTENT_FILES)){%>
                                <th scope="col">Name</th>
                                <th scope="col">Type</th>
                                <th scope="col">Size</th>
                            <%} else if(themeContent.equals(Constant.THEME_CONTENT_MEDIA)) {%>
                                <th scope="col">Resource</th>
                                <th scope="col">Type</th>
                                <th scope="col">Label</th>
                            <%} else if(themeContent.equals(Constant.THEME_CONTENT_LIBRARIES)){%>
                                <th scope="col">Type of Content</th>
                                <th scope="col">Status</th>
                                <th scope="col">Nb files</th>
                            <%} else if(themeContent.equals(Constant.THEME_CONTENT_TEMPLATES) ||
                                        themeContent.equals(Constant.THEME_CONTENT_SYSTEM_TEMPLATES) ||
                                        themeContent.equals(Constant.THEME_CONTENT_PAGE_TEMPALTES)) {%>
                                <th scope="col">Tempalte Name</th>
                                <th scope="col">Type</th>
                                <th scope="col">Status</th>
                                <th scope="col">Description</th>
                            <%}%>
<%--                            <th scope="col">Theme</th>--%>
                            <th scope="col">Last changes</th>
                            <th scope="col">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                    <div id="actionsCellTemplateThemeContent" class="d-none">
                        <button class="btn btn-sm btn-success syncBtn" type="button" title="Sync"
                        onclick='syncContentItem("#UNIQUE_ID#")'>
                        <i data-feather="refresh-cw"></i></button>
                        <% if(themeContent.equals(Constant.THEME_CONTENT_LIBRARIES)){%>
                            <button class="btn btn-sm btn-primary viewLibBtn" type="button"
                                onclick='viewLibrary(this)'>
                                <i data-feather="eye"></i>
                            </button>
                        <%}%>
                        <button class="btn btn-sm btn-danger deleteBtn" type="button"
                            onclick='deleteSingleContentItem("#UNIQUE_ID#")' <%if(isLocked){%>disabled<%}%> >
                            <i data-feather="trash-2"></i>
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


<!-- Modal -->
<div class="modal fade" id="viewLibraryModal" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title"></h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="form-group row">
                    <label class="col col-form-label">Name</label>
                    <div class="col-sm-9">
                        <input type="text" class="form-control libName"
                            name="name" maxlength="100" required disabled/>
                    </div>
                </div>

                <ul class="nav nav-tabs pagePathTabs" role="tablist">
                    <%
                        active = true;
                        for (Language lang: langsList) 
                        {
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
                        for (Language lang: langsList) 
                        {
                    %>
                            <div class='tab-pane langTabContent <%=(active)?"show active":""%>'
                                                                id="pathPrefixlangTabContent_<%=lang.getLanguageId()%>"
                                                                role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                <div class="row">
                                    <div class="col-6">
                                        <div class="card">
                                            <div class="card-header">
                                                <span class="font-weight-bold">Body</span>
                                            </div>
                                            <div class="card-body py-0 pr-0" style="">
                                                <ol id="bodyFilesList" class="filesList bodyFilesList_<%=lang.getLanguageId()%> sortable2 list-group m-2" style="min-height: 200px;">

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
                                                <ol id="headFilesList" class="filesList headFilesList_<%=lang.getLanguageId()%> sortable2 list-group m-2" style="min-height: 200px;">

                                                </ol>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                    <%
                            active = false;
                        }//for lang tab content
                    %>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->


<!-- Modal -->
<div class="modal fade" id="addContentItemModal" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-xl modal-dialog-slideout" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Select <%=themeContent%></h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col">
                        <%if(themeContent.equals(Constant.THEME_CONTENT_LIBRARIES)){%>
                        <div class="form-check mb-4">
                          <input class="form-check-input" type="checkbox" value="1" id="addLibraryFiles" checked>
                          <label class="form-check-label" for="addLibraryFiles">
                            Add library files in theme
                          </label>
                        </div>

                        <%}%>
                        <table class="table table-hover table-vam compact" id="selectItemsTable" style="width: 100%">
                            <thead class="thead-light">
                                <tr>
                                    <%if(themeContent.equals(Constant.THEME_CONTENT_LIBRARIES)){%>
                                        <th scope="col">Name</th>
                                    <%}else if(themeContent.equals(Constant.THEME_CONTENT_SYSTEM_TEMPLATES) || themeContent.equals(Constant.THEME_CONTENT_TEMPLATES)){%>
                                        <th scope="col">Template name</th>
<%--                                        <th scope="col">Type</th>--%>
                                    <%} else if(themeContent.equals(Constant.THEME_CONTENT_PAGE_TEMPALTES)){%>
                                        <th scope="col">Template name</th>
                                    <%} else if(themeContent.equals(Constant.THEME_CONTENT_FILES)){%>
                                        <th scope="col">File Name</th>
                                        <th scope="col">Type</th>
                                        <th scope="col">Size</th>
                                    <%}%>
                                    <th scope="col">Last changes</th>
                                    <th scope="col"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- loaded by ajax -->
                            </tbody>
                        </table>
                            </div>
                        <div id="actionsCellTemplate" class="d-none" >
                            <button class="btn btn-sm btn-primary" onclick='onSelectItem(this, "#ID#", "#UNIQUE_ID#" )'>select</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<script type="text/javascript">
    // ready function
    $(function () {
        $ch.CONTENT_FILES = "<%=Constant.THEME_CONTENT_FILES%>";
        $ch.CONTENT_MEDIA = "<%=Constant.THEME_CONTENT_MEDIA%>";
        $ch.CONTENT_LIBRARIES = "<%=Constant.THEME_CONTENT_LIBRARIES%>";
        $ch.CONTENT_PAGE_TEMPLATES = "<%=Constant.THEME_CONTENT_PAGE_TEMPALTES%>";
        $ch.CONTENT_SYSTEM_TEMPLATES = "<%=Constant.THEME_CONTENT_SYSTEM_TEMPLATES%>";
        $ch.CONTENT_TEMPALTES = "<%=Constant.THEME_CONTENT_TEMPLATES%>";
        $ch.isSuperAdmin = <%=isSuperAdmin(Etn)%>;
        $ch.THEME_LOCKED = '<%=Constant.THEME_LOCKED%>';
        $ch.content = '<%=escapeCoteValue(themeContent)%>';
        $ch.THEME_FILE_URL_PREPEND = '<%=THEME_FILE_URL_PREPEND%>';
        $ch.themeContent = $('#themeContent').val();
        $ch.themeUuid = $('#themeUuid').val();
        $ch.themeId = $('#themeId').val();
        $ch.tableData = [];
        window.selectItemsTable = null;

        initThemeTable();
    });
    function  getDataTableCols(contentType) {
        var cols = [];
        cols.push({"data": "id"});
        switch (contentType) {

            case $ch.CONTENT_FILES:
                cols.push({"data": "name",  className: "text-capitalize, file_name"});
                cols.push({"data": "extension"});
                cols.push({"data": "size"});
                break;
            case $ch.CONTENT_LIBRARIES:
                cols.push({"data": "name",  className: "text-capitalize name"});
                cols.push({"data": "status"});
                cols.push({"data": "nb_files"});
                break;
            case $ch.CONTENT_MEDIA:
                cols.push({"data": "name",  className: "text-capitalize name"});
                cols.push({"data": "extension" ,  className: "text-uppercase"});
                cols.push({"data": "name"});
                break;
            case $ch.CONTENT_TEMPALTES: case $ch.CONTENT_SYSTEM_TEMPLATES: case $ch.CONTENT_PAGE_TEMPLATES:
                cols.push({"data": "name",  className: "text-capitalize name"});
                cols.push({"data": "type", className: "text-capitalize"});
                cols.push({"data": "status"});
                cols.push({"data": "description"});
                break;
        }
        // cols.push({"data": "theme"});
        cols.push({"data": "last_modified"});
        cols.push({"data": "actions", className: "dt-body-right text-nowrap"});
        return cols;
    }

    function  getDataTablesColumnDefs (contentType) {
        var cols = [];
        cols.push({targets: [-1], searchable: false});
        cols.push({targets: [0, -1], orderable: false});
        cols.push({
                    targets: [0],
                    render: function (data, type, row) {
                        if (type == 'display') {
                            return '<input type="checkbox" class="idCheck d-none d-sm-block" name=""id onclick="onCheckItem(this)" value="' + data + '" >';
                        }
                        else {
                            return data;
                        }
                    }
                })

        cols.push({
                    targets: [-2],
                    render: function (data, type, row) {
                        if (type == 'sort' && data.trim().length > 0) {
                            return getMoment(data).unix();
                        }else{
                           return data;
                        }
                    }
                });


        switch (contentType) {
            case $ch.CONTENT_FILES:
                cols.push(
                { targets : [1] ,
                    render: function ( data, type, row ) {
                        if(type == 'display'){
                            var fileLink = "<a href='"
                                + $ch.THEME_FILE_URL_PREPEND +"/"+$('#themeContent').val() + "/" +data
                                +"' target='"+data+"' >"+data+"</a>";
                            return fileLink;
                        }
                        else {
                            return data;
                        }
                    }
                });
                break;
            case $ch.CONTENT_MEDIA:
                 cols.push({ targets : [1] ,
                    render: function ( data, type, row ) {
                        if(type == 'display'){
                            var retVal = data;
                            var fileUrl = $ch.THEME_FILE_URL_PREPEND +"/"+$('#themeContent').val() + "/" +data;
                            if(row.type == 'img'){
                                var rand = (new Date().getTime());
                                var origSrc = fileUrl+'?rand='+rand;
                                retVal = '<a href="'+origSrc+'" target="'+origSrc+'" '
                                            + ' onclick="onFileOpenClick(event)" > '
                                            + '<img src="../img/spinner.gif" data-src="'+origSrc+'" '
                                            + ' alt="'+data+'" orig-src="'+origSrc+'" '
                                            + ' file-src="'+origSrc+'" '
                                            + ' class="mediaImage lazy" style="max-height: 30px;" >'
                                            + '</a>' ;
                            }
                            else if(row.type == 'other' || row.type == 'video'){

                                var fileExt = row.extension;

                                var iconSrc = "../img/filetype/"+fileExt+".svg";
                                retVal =    '<a href="'+fileUrl+'" target="'+data+'" '
                                            + ' onclick="onFileOpenClick(event)" > '
                                            + '<img src="'+iconSrc+'" '
                                            + ' alt="'+data+'" orig-src="'+iconSrc+'" '
                                            + ' file-src="'+fileUrl+'" '
                                            + ' class="mediaImage" style="max-height: 30px;" '
                                            + ' > </a>';
                            }
                            else{
                                var retVal = "<a href='" + fileUrl +"' target='"+data+"' >"+data+"</a>";
                            }
                            return retVal;
                        }
                        else {
                            return data;
                        }
                    }
                })
                break;
            case $ch.CONTENT_LIBRARIES:
                 cols.push({
                    targets: [4],
                    render: function (data, type, row) {
                        if (type == 'display') {
                            return '<span class="badge badge-secondary" >'+data+'</span>';
                        }else{
                           return data;
                        }
                    }
                })
                cols.push({ targets : [2] ,
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
                })
                break;
            case $ch.CONTENT_TEMPALTES: case $ch.CONTENT_SYSTEM_TEMPLATES: case $ch.CONTENT_PAGE_TEMPLATES:
                cols.push({ targets : [3] ,
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
                })
                break;
        }
        return cols;
    }

    function initThemeTable() {
        window.themeContentDataTable = $('#themeContentDataTable')
        .DataTable({
            responsive: true,
            pageLength: $ch.content == $ch.CONTENT_MEDIA?10:100,
            ajax: function (data, callback, settings) {
                getThemeContentData(data, callback, settings);
            },
            order: [[1, 'asc']],
            columns: getDataTableCols($ch.content),
            columnDefs: getDataTablesColumnDefs($ch.content),

            createdRow : function ( row, data, index ) {
                $(row).data('uniqueId', data.uniqueId);
                if($ch.content == $ch.CONTENT_LIBRARIES){
                    $(row).data('lib-data', data.libData);
                    $(row).data('error', data.error);
                } else if($ch.content == $ch.CONTENT_TEMPALTES || $ch.content == $ch.CONTENT_SYSTEM_TEMPLATES || $ch.content == $ch.CONTENT_PAGE_TEMPLATES){
                    $(row).data('error', data.error);
                }
                $(row).addClass('table-light');
            },
            drawCallback: function() {
                // update the images shown on table changes
                $("#themeContentDataTable img.lazy").Lazy();
            },
            select: {
                style: 'multi',
                className: '',
                selector: 'td.noselector' //dummyselector
            },
        })
    }

    function getThemeContentData(data, callback, settings) {
        showLoader();
        data = {
            requestType: 'getThemeContentData',
            themeId: $ch.themeId,
            themeContent: $ch.themeContent
        };
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data: data,
        })
        .done(function (resp) {
            var data = [];
            if (resp.status == 1) {
                data = resp.data.themeContents;
                $ch.tableData = data;
                var actionsCellElem = $('#actionsCellTemplateThemeContent');
                $.each(data, function (index, val) {
                    if(val.syncRequired){
                        actionsCellElem.find(".syncBtn").show();
                    } else{
                        actionsCellElem.find(".syncBtn").hide();
                    }
                    val.actions = strReplaceAll(actionsCellElem.html(), "#UNIQUE_ID#", val.uniqueId);
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

   function onCheckItem(check) {
        check = $(check);
        var row = window.themeContentDataTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.themeContentDataTable.table().body()).find('.idCheck');
        }
        else {
            //un select all
            var allChecks = window.themeContentDataTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked', isChecked);

        allChecks.each(function (index, el) {
            $(el).triggerHandler('click');
        });
    }

    function refreshDataTable() {
        window.themeContentDataTable.ajax.reload(function () {
            $('#checkAll').triggerHandler('change');
        }, false);
    }

    function viewLibrary(btn) {
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var libData = tr.data("lib-data");
        var viewLibModal = $('#viewLibraryModal');

        viewLibModal.find(".modal-title").text("Library : "+libData.system_info.name);
        viewLibModal.find(".libName").val(libData.system_info.name);

        <%
            for (Language lang: langsList) 
            {
        %>
                var bodyFilesList = viewLibModal.find('.bodyFilesList_<%=lang.getLanguageId()%>');
                var headFilesList = viewLibModal.find('.headFilesList_<%=lang.getLanguageId()%>');
                bodyFilesList.html("");
                headFilesList.html("");
                if(libData.body_files!=undefined){
                    libData.body_files.forEach(function (file, index) {
                        addLibraryFileItem(file.name, bodyFilesList)
                    });

                    libData.head_files.forEach(function (file, index) {
                        addLibraryFileItem(file.name, headFilesList)
                    });
                }else{
                    for(let  i=0 ;i<libData.detail_langs.length;i++){
                        if("<%=lang.getCode()%>"=== libData.detail_langs[i].language_code){
                            libData.detail_langs[i].body_files.forEach(function (file, index) {
                                addLibraryFileItem(file.name, bodyFilesList)
                            });

                            libData.detail_langs[i].head_files.forEach(function (file, index) {
                                addLibraryFileItem(file.name, headFilesList)
                            });
                        }
                    }

                }
        <%
            }
        %>

        viewLibModal.modal("show");
    }

    function addLibraryFileItem(fileName, listEle){
        var li = $('<li class="list-group-item list-group-item-action list-group-item-success">').text(fileName);
        listEle.append(li);
    }

    function addMedia() {
        var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
        prop += "scrollbars=yes, menubar=no, location=no, statusbar=no";
        var winWidth = $(window).width() - 200;
        if (winWidth < 1000) {
            winWidth = 1000;
        }
        var winHeight = $(window).height() - 400;
        if (winHeight < 600) {
            winHeight = 600;
        }
        prop += ",width=" + winWidth + ",height=" + winHeight;

        var win = window.open('mediaLibrary.jsp?popup=1&fileTypes=img,other,video&theme=1', "mediaLibrary", prop);
        win.focus();
    }

    function openAddNewItemModal() {

        if($ch.themeContent === $ch.CONTENT_TEMPALTES){
            $ch.templateType = "bloc";
        } else if($ch.themeContent === $ch.CONTENT_SYSTEM_TEMPLATES){
            $ch.templateType = "system";
        }

        var contentItemModal  = $('#addContentItemModal');

        if($ch.themeContent === $ch.CONTENT_MEDIA){
                addMedia();
        } else{
            contentItemModal.modal("show");
            if(window.selectItemsTable){
                window.selectItemsTable.ajax.reload(function () {
                     $('#checkAll').triggerHandler('change');
                }, false);
            }else{
                initSelectItemsTable();
            }
        }
    }

    function getSelectItems (data, callback, settings){
        var url = 'blocTemplatesAjax.jsp';
        var reqData = {
            requestType : 'getList',
        }

        if($ch.themeContent === $ch.CONTENT_LIBRARIES){
            url = "librariesAjax.jsp"
        } else if($ch.themeContent === $ch.CONTENT_PAGE_TEMPLATES){
            url = "pageTemplatesAjax.jsp"
        }else if($ch.themeContent === $ch.CONTENT_FILES){
            url = "filesAjax.jsp"
            reqData["requestType"] = "getAllFilesList";
            reqData["fileTypes"] = ["css","js","fonts"].join(",");
        } else{
            reqData["templateType"] =  $ch.templateType;
        }

    	showLoader();
    	$.ajax({
    		url: url, type: 'POST', dataType: 'json',
    		data: reqData,
    	})
    	.done(function(resp) {
    		var data = [];
    		if(resp.status == 1){
                if($ch.themeContent === $ch.CONTENT_LIBRARIES) {
                    data = resp.data.libraries;
                } else if ($ch.themeContent === $ch.CONTENT_FILES){
                    data = resp.data.files;
                }
                else{
                    data = resp.data.templates;
                }
    			var actionTemplate = $('#actionsCellTemplate').html();
    			$.each(data, function(index, val) {
    			   val.actions = strReplaceAll(actionTemplate, "#ID#", val.id);
                   if($ch.themeContent === $ch.CONTENT_LIBRARIES) {
                        val.actions = strReplaceAll(val.actions, "#UNIQUE_ID#", val.name);
                    } else if ($ch.themeContent === $ch.CONTENT_FILES){
                        val.actions = strReplaceAll(val.actions, "#UNIQUE_ID#", val.file_name);
                    }else{
                        val.actions = strReplaceAll(val.actions, "#UNIQUE_ID#", val.custom_id);
                    }
    			});
    		}
    		callback( { "data" : data } );
    	})
    	.fail(function() {
    		callback( { "data" : [] } );
    	})
    	.always(function() {
    		hideLoader();
    	});
    }

    function initSelectItemsTable(){

        var cols = [];
        var columnDefs = [];

        if($ch.themeContent == $ch.CONTENT_FILES) {
            cols.push({ "data": "file_name" , className : "text-nowrap"});
            cols.push({ "data": "type" , className : "text-nowrap"});
            cols.push({ "data": "file_size" , className : "text-nowrap"});
        } else{
            cols.push({ "data": "name" , className : "text-nowrap"});
        }

        cols.push({ "data": "updated_ts" });
        cols.push({ "data": "actions", className : "dt-body-right" });

        columnDefs.push({ targets : [-1] , searchable : false});
        columnDefs.push({ targets : [-1] , orderable : false});
        columnDefs.push({ targets : [-2] ,
            render: function ( data, type, row ) {
                if(type == 'sort' && data.trim().length > 0){
                    return getMoment(data).unix();
                }
                else {
                    var toolTipText = "";
                    if(row.updated_by) toolTipText += "Last changes: by " + row.updated_by;

                    var htmlData = data +
                    ' <a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="'+toolTipText+'">'+
                        feather.icons.info.toSvg()+
                    '</a>'
                    return htmlData;
                }
            }
        });

        if($ch.themeContent == $ch.CONTENT_TEMPALTES && $ch.themeContent == $ch.CONTENT_SYSTEM_TEMPLATES){
            columnDefs.push({ targets : [2] ,
                render: function ( data, type, row, meta ) {
                    if(type == "display"){
                        return data.split("_").join(" ");
                    }
                    else{
                        return data;
                    }
                }
            });
        }
        window.selectItemsTable = $('#selectItemsTable')
        .DataTable({
            responsive: true,
            pageLength : 10,
            ajax : function(data, callback, settings){
                getSelectItems(data, callback, settings);
            },
            order : [[0,'asc']],
            columns : cols,
            columnDefs : columnDefs,
            select: {
                style       : 'multi',
                className   : 'bg-published',
                selector    : 'td.noselector' //dummyselector
            },
        });
    }

    function addNewContentItem(id, uniqueId, overwrite){
        var data = {
            requestType : "addNewContentItem",
            themeId: $ch.themeId,
            themeContent: $ch.themeContent,
            id: id,
            uniqueId: uniqueId,
            overwrite: overwrite,
        }

        if($ch.themeContent == $ch.CONTENT_TEMPALTES || $ch.themeContent == $ch.CONTENT_SYSTEM_TEMPLATES ){
            data["templateType"] = $ch.templateType;
        }
        if($ch.themeContent == $ch.CONTENT_LIBRARIES ){
            data["addLibraryFiles"] = $('#addLibraryFiles').prop("checked")?"1":"0";
        }
        showLoader();
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data: data,
        })
        .done(function(resp) {
            if(resp.status == 1){
                bootNotify(resp.message);
                refreshDataTable();
            }else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error connecting to server, please try again");
        })
        .always(function() {
            hideLoader();
        });
    }

    function deleteContentItems(ids) {
        if(ids.length <= 0){
            return;
        }
        showLoader();
    	$.ajax({
    		url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
    		data: $.param({
    			requestType : 'deleteContentItems',
                themeId: $ch.themeId,
                contentType: $ch.themeContent,
                ids: ids,
    		}, true),
    	})
    	.done(function(resp) {
    		if(resp.status == 1){
    		    bootNotify(resp.message);
    		    refreshDataTable();
    		}else{
                bootNotifyError(resp.message);
            }
    	})
    	.fail(function() {
            bootNotifyError("Error connecting to server please try again");
    	})
    	.always(function() {
    		hideLoader();
    	});
    }

    function onSelectItem(btn, id, uniqueId) {
        var type = "template";
        if($ch.themeContent == $ch.CONTENT_LIBRARIES){
            type = "library"
        } else if($ch.themeContent == $ch.CONTENT_FILES){
            type = "file"
        }
        var match = false;
        $ch.tableData.forEach(function (data) {
           var uniqueDataId  = "";

           if($ch.themeContent === $ch.CONTENT_LIBRARIES){
               uniqueDataId = data.name
           }else if ($ch.themeContent === $ch.CONTENT_FILES){
               uniqueDataId = data.name
           }else{
               uniqueDataId = data.custom_id
           }
           if(uniqueDataId == uniqueId){
                match = true;
                return false;
            }
        });

        if(match) {
            var type = "Template";
            if($ch.themeContent == $ch.CONTENT_LIBRARIES){
                type = "Library"
            }else if($ch.themeContent == $ch.CONTENT_FILES){
                type = "File"
            }
            bootConfirm(type+" already exsits in theme, do you want ot overwrite it ?", function (result) {
                if (result){
                    if($ch.themeContent == $ch.CONTENT_LIBRARIES){
                        addNewContentItem(id, uniqueId, '1');
                    }else{
                        addNewContentItem(id, uniqueId, '1');
                    }
                } else {
                    return;
                }
            });
        } else{
            addNewContentItem(id, uniqueId, '0');
        }
    }

    function onSelectMediaItem (data){
        var match = false;
        $ch.tableData.forEach(function (mediaFile) {
            if(mediaFile.name == data.name){
                match = true;
                return false;
            }
        });
        if(match){
            bootConfirm("Already exsits do you want to overwrite", function (result) {
                if(result){
                    addNewContentItem(data.name, data.name, 1)
                }
            });
        } else {
            addNewContentItem(data.name, data.name,  0)
        }
    }
    // these function used in media library
    function selectFieldFile(data) {
        onSelectMediaItem(data);
    }

    function selectFieldImageTheme (data){
        onSelectMediaItem(data);
    }

    function deleteSelected() {
        var selectedItems = window.themeContentDataTable.rows({selected: true}).nodes().to$().find(".idCheck");
        if (selectedItems.length == 0) {
            bootNotify("No item selected");
            return false;
        }
        var ids = [];
        $.each(selectedItems, function (index, row) {
            ids.push($(row).closest("tr").data("uniqueId"));
        });

        var contentItem = "media file(s)";
        if($ch.themeContent != $ch.CONTENT_MEDIA) {
            contentItem = $ch.themeContent;
            if (ids.length == 1) {
                contentItem = contentItem.toString().slice(0, -1);
            }
        }
        bootConfirm("Are you sure you want to delete "+ids.length +" "+contentItem+" ? ", function (result) {
            if(result){
                deleteContentItems(ids);
            }
        });
    }

    function deleteSingleContentItem(id) {
        if(id.length > 0){

            var contentItem = "media file";
            if($ch.themeContent != $ch.CONTENT_MEDIA){
                contentItem = $ch.themeContent.toString().slice(0, -1);
            }

            bootConfirm("Are you sure you want to delete this "+contentItem+" ?", function (result) {
                if(result){
                    deleteContentItems([id]);
                }
            })
        }
    }

    function viewItemError(btn){
        var tr = $(btn).parents("tr:first");

        var error = tr.data("error");
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

    function syncContentItems() {
        var selectedItems = window.themeContentDataTable.rows({selected: true}).nodes().to$().find(".idCheck");
        if (selectedItems.length == 0) {
            bootNotify("No item selected");
            return false;
        }
        var ids = [];
        $.each(selectedItems, function (index, row) {
            ids.push($(row).closest("tr").data("uniqueId"));
        });
        syncItems(ids);
    }

    function syncItems(ids) {
        showLoader();
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data:
                $.param({
                requestType : 'syncThemeContentItems',
                themeId: $ch.themeId,
                themeContent : $ch.themeContent,
                itemIds: ids
            },true),
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

    function syncContentItem(uniqueId) {
        syncItems([uniqueId])
    }

</script>
</body>
</html>