<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.List " %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp"%>

<%!
    JSONArray foldersHirarchy(String folderUuid, String siteId,Contexte Etn){

        JSONArray folders = new JSONArray();
        JSONObject parentObj = new JSONObject();

        String query = "SELECT f.name, f.uuid, IFNULL(pf.uuid,'') AS parent_folder_id "
            + " FROM pages_folders f "
            + " LEFT JOIN pages_folders pf ON pf.id = f.parent_folder_id "
            + " WHERE f.uuid = " + escape.cote(folderUuid)
            + " AND f.site_id = " + escape.cote(siteId);
        Set rs = Etn.execute(query);
        if (rs.next()) {
            
            parentObj.put("name", parseNull(rs.value("name")));
            parentObj.put("uuid", parseNull(rs.value("uuid")));

            if(parseNull(rs.value("parent_folder_id")).length() > 0) {
                folders=foldersHirarchy(parseNull(rs.value("parent_folder_id")),siteId,Etn);
            }
            folders.put(parentObj);
        }
        return folders;
    }
%>

<%
    Set rs;
    String q;
    String folderType = Constant.FOLDER_TYPE_PAGES;
    String folderUuid = parseNull(request.getParameter("folderId"));
    String editId = parseNull(request.getParameter("id"));

    String folderId = "0";
    String folderName = "";
    int folderLevel = 0;
    String parentFolderId = "";
    String parentFolderName = "";
    String siteId = getSiteId(session);
    String templateType = Constant.TEMPLATE_STRUCTURED_PAGE;
    JSONArray foldersarray = new JSONArray();

    if (folderUuid.length() > 0) {
        q = "SELECT f.id, f.name, f.uuid, f.folder_level, IFNULL(pf.uuid,'') AS parent_folder_id, pf.name AS parent_folder_name "
            + " FROM pages_folders f "
            + " LEFT JOIN pages_folders pf ON pf.id = f.parent_folder_id "
            + " WHERE f.uuid = " + escape.cote(folderUuid)
            + " AND f.site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);
        if (rs.next()) {
            folderId = rs.value("id");
            folderName = parseNull(rs.value("name"));
            folderLevel = parseInt(rs.value("folder_level"));
            parentFolderId = parseNull(rs.value("parent_folder_id"));
            parentFolderName = parseNull(rs.value("parent_folder_name"));
    
            foldersarray=foldersHirarchy(folderUuid,siteId,Etn);

        }
        else {
            response.sendRedirect("pages.jsp");
        }
    }

    String goBackUrl = "pages.jsp" + (parentFolderId.length() > 0 ? "?folderId=" + parentFolderId : "");
    boolean active = true;
    List<Language> langsList = getLangs(Etn,siteId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title>Pages</title>

    <style type="text/css">
        .table-success .deleteBtn, .table-warning .deleteBtn {
            display: none !important;
        }

        .table-danger .unpublishBtn {
            display: none !important;
        }
	</style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Content", ""});
        if(parentFolderId.length()>0){
            breadcrumbs.add(new String[]{"Pages", "pages.jsp"});
            
            for (int i = 0; i < foldersarray.length()-1; i++) {
                JSONObject obj = foldersarray.getJSONObject(i);
                breadcrumbs.add(new String[]{obj.getString("name"), "pages.jsp?folderId="+ obj.getString("uuid")});
            }
            
            breadcrumbs.add(new String[]{folderName, ""});

        } else if(folderUuid.length()>0){
            breadcrumbs.add(new String[]{"Pages", "pages.jsp"});
            breadcrumbs.add(new String[]{folderName, ""});
        } else{
            breadcrumbs.add(new String[]{"Pages", ""});
        }
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <input type="hidden" id="folderUuid" name="" value="<%=folderUuid%>"/>
            <input type="hidden" id="folderId" name="" value="<%=folderId%>"/>
            <input type="hidden" id="folderLevel" name="" value="<%=folderLevel%>"/>
            <input type="hidden" id="folderType" name="" value="<%=folderType%>"/>

            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Pages</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <%-- <div class="d-none">
                        <button type="button" class="btn btn-danger mr-2 d-none d-md-block"
                                onclick="deleteSelected();">Delete
                        </button>
                        <div class="btn-group mr-2">
                            <button class="btn btn-primary d-none d-md-block" type="button"
                                    onclick="onPublishUnpublish('publish')">Publish
                            </button>
                            <button class="btn btn-danger d-none d-md-block" type="button"
                                    onclick="onPublishUnpublish('unpublish')">Unpublish
                            </button>
                        </div>

                        <button type="button" class="btn btn-success d-none d-md-block mr-2"
                                onclick="openMoveToModal();" title="Move to">Move to
                        </button>
                    </div> --%>

                    <div class="btn-group mr-2">
                        <button type="button" class="btn btn-primary"
                                onclick="goBack('<%=goBackUrl%> ')">Back
                        </button>
                        <button type="button" class="btn btn-primary"
                                onclick="refreshDataTable();" title="Refresh"><i data-feather="refresh-cw"></i>
                        </button>
                    </div>

                    <div class="btn-group mr-2">
                        <button class="btn btn-danger dropdown-toggle" type="button" id="dropdownActionBtn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Actions</button>
                        <div class="dropdown-menu">
                            <a class="dropdown-item" onclick="onPublishUnpublish('publish')" href="#">Publish</a>
                            <a class="dropdown-item" onclick="onPublishUnpublish('unpublish')" href="#">Unpublish</a>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" onclick="deleteSelected()" href="#">Delete</a>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item" onclick="openMoveToModal()" href="#">Move To</a>
                        </div>
                    </div>
                    
                    <div class="btn-group mr-2">
                        <button class="btn btn-success dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Add</button>
                        <div class="dropdown-menu">
                            <a class="dropdown-item" <% if (folderLevel >= 4) { %> disabled <%}%> onclick="openFolderModal()" href="#" >Add a folder</a>
                            <a class="dropdown-item" onclick="openPageSettingsModal()" href="#">Add a page</a>
                        </div>
                    </div>                    

                    <button type="button" class="btn btn-secondary justify-content-center align-items-center d-none d-md-block" onclick="addToShortcut('Pages')" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>

                </div>
            </div>
                                <div class="row">
                                    <div class="col">
                                <table class="table table-hover table-vam" id="pagesTable" style="width:100%;">
                                    <thead class="thead-dark">
                                    <tr>
                                        <th scope="col">
                                            <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                                        </th>
                                        <th scope="col">&nbsp;<!--type icon --></th>
                                        <th scope="col">Name</th>
                                        <th scope="col">Type</th>
                                        <th scope="col">Variant</th>
                                        <th scope="col">Nb Items</th>
                                        <th scope="col">Last changes</th>
                                        <th scope="col">Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                                <div id="actionsCellTemplatePage" class="d-none">
                                    <a class="btn btn-sm btn-primary" title="Edit"
                                    href="pageEditor.jsp?id=#PAGEID#">
                                        <i data-feather="edit"></i>
                                    </a>
                                    <button class="btn btn-sm btn-primary " title="Settings"
                                            onclick='editPageSettings("#PAGEID#", false)'>
                                        <i data-feather="settings"></i>
                                    </button>
                                    <button class="btn btn-sm btn-primary " title="Copy"
                                            data-toggle="modal" data-target="#modalCopyPage"
                                            data-page-id='#PAGEID#'>
                                        <i data-feather="copy"></i></button>

                                    <button class="btn btn-sm btn-danger deleteBtn" title="Delete"
                                            onclick='deletePage("#PAGEID#","<%=Constant.PAGE_TYPE_FREEMARKER%>")'>
                                        <i data-feather="trash-2"></i></button>

                                    <button class="btn btn-sm btn-danger unpublishBtn" title="Unpublish"
                                            onclick='unpublishPage(this)'>
                                        <i data-feather="x"></i></button>

                                </div>
                                <div id="actionsCellTemplateStructuredPage" class="d-none">
                                    <a class="btn btn-sm btn-primary" title="Edit"
                                    href="structuredPageEditor.jsp?id=#PAGEID#">
                                        <i data-feather="edit"></i>
                                    </a>

                                    <button class="btn btn-sm btn-primary " title="Settings"
                                                onclick="editStructuredPageSettings('#PAGEID#')" >
                                        <i data-feather="settings"></i>
                                    </button>

                                    <button class="btn btn-sm btn-primary " title="Copy"
                                        onclick="copyStructuredPage(this ,'#PAGEID#')">
                                        <i data-feather="copy"></i></button>

                                    <button class="btn btn-sm btn-danger deleteBtn" title="Delete"
                                            onclick='deletePage("#PAGEID#","<%=Constant.PAGE_TYPE_STRUCTURED%>")'>
                                        <i data-feather="trash-2"></i></button>

                                    <button class="btn btn-sm btn-danger unpublishBtn" title="Unpublish"
                                            onclick='unpublishPage(this)'>
                                        <i data-feather="x"></i></button>

                                </div>
                                <div id="actionsCellTemplateFolder" class="d-none">
                                    <a class="btn btn-sm btn-primary openFolder" title="Open"
                                    href="pages.jsp?folderId=#FOLDERUUID#">
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
                                            onclick="deleteFolders('#FOLDERID#')">
                                        <i data-feather="trash-2"></i></button>

                                </div>
                            </div>
                        </div><!-- row-->
            <!-- container -->
            <!-- /end of container -->
        </main>
    </div>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<!-- Modals -->
<div class="modal fade" id="modalCopyPage" tabindex="-1" role="dialog" data-backdrop="static">
    <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
        <div class="modal-content">
            <div id="copyPageDivMain">
                <input type="hidden" name="pageId" value="">

                <div class="modal-header">
                    <h5 class="modal-title" id="">Copy page</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="form-group row">
                            <label class="col col-form-label">Copy From</label>
                            <div class="col-9">
                                <input type="text" name="pageName" class="form-control" readonly>
                            </div>
                        </div>
                        <div class="form-group row ">
                            <label class="col col-form-label">Duplicate blocs?</label>
                            <div class="col-9">
                                <div class="form-check mt-2">
                                    <input class="form-check-input" type="checkbox" name="duplicateBlocs" value='1'>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <ul class="nav nav-tabs " id="pageCopySettingslangNavTabs" role="tablist">
                                    <%
                                        for (Language lang: langsList) {
                                    %>
                                    <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
                                        <a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
                                           id="pageCopyLangTab_<%=lang.getLanguageId()%>" data-toggle="tab" href="#pageCopylangTab_<%=lang.getLanguageId()%>"
                                           role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%></a>
                                    </li>
                                    <%
                                            active = false;
                                        }
                                    %>
                                </ul>
                                <div class="tab-content p-3" id="flangTabContent">
                                    <%
                                        active = true;
                                        for (Language lang: langsList) {
                                    %>
                                    <div class='tab-pane langTabContent <%=(active)? "show active":""%>'
                                         id="pageCopylangTab_<%=lang.getLanguageId()%>"
                                         role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                        <div class='langPageCopy'
                                             id="pageCopy_<%=lang.getLanguageId()%>"
                                             data-lang-id="<%=lang.getLanguageId()%>" data-lang-id="<%=lang.getLanguageId()%>" >
                                            <form class="pageCopyForm" id="pageCopyForm_<%=lang.getLanguageId()%>" noValidate>
                                                <div class="form-group row">
                                                    <label class="col col-form-label">New page name</label>
                                                    <div class="col-9">
                                                        <input type="text" name="name" class="form-control" value=""
                                                               required="required" maxlength="100">
                                                        <div class="invalid-feedback">
                                                            Cannot be empty.
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group row">
                                                    <label  class="col-sm-3 col-form-label">Path</label>
                                                    <div class="col-sm-9">
                                                        <div class="input-group">
                                                            <div class="input-group-prepend pagePathPrefixDiv">
                                                                <span  class="input-group-text">/</span>
                                                            </div>
                                                            <input type="text" class="form-control" name="path" value=""
                                                                maxlength="500" required="required"
                                                                onkeyup="onPathKeyup(this)"
                                                                onblur="onPathBlur(this)">

                                                            <div class="input-group-append">
                                                                <span class="input-group-text rounded-right">.html</span>
                                                            </div>
                                                            <div class="invalid-feedback">
                                                                Cannot be empty
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group row">
                                                    <label class="col col-form-label">Variant</label>
                                                    <div class="col-9">
                                                        <select class="custom-select" name="variant">
                                                            <option value="all">All</option>
                                                            <option value="anonymous">Anonymous</option>
                                                            <option value="logged">Logged</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                        <!-- /page lang copy -->
                                    </div>
                                    <!-- tabContent -->
                                    <%
                                            active = false;
                                        }//for lang tab content
                                    %>
                                </div>
                            </div>
                        </div><!-- row -->
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button onclick="copyBlocPage()" class="btn btn-primary">Save</button>
                </div>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<!-- move to modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='moveToDlg' >
    <div class="modal-dialog modal-md" role="document">
        <div class="modal-content">
            <div class="modal-header" style='text-align:left'>
                <h5 class="modal-title">Move selected Pages</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">&times;</span>
                    </button>
            </div>
            <div class="modal-body">
                <div>
                    <div class="row">
                        <div class="form-group col-sm-12">
                            <select name="folder" class="custom-select" id="pagesFolderSelect">
                                <option value="">-- list of folders --</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group  col-sm-3">
                            <button type="button" class="btn btn-success" onclick="moveSelectedPages()">Submit</button>
                        </div>
                    </div>
                </div>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>


<%@ include file="foldersAddEdit.jsp" %>
<%@ include file="pageSettingsAddEdit.jsp" %>

<%@ include file="pagesPublish.jsp" %>
<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>/';
    // ready function
    $(function () {
        $('#pagesTable tbody').tooltip({
            placement: 'bottom',
            html: true,
            selector: ".custom-tooltip"
        });
        
        initPagesTable();

        $('#modalCopyPage').on('show.bs.modal', function (event) {
            let button = $(event.relatedTarget);
            let mainDiv = $('#copyPageDivMain');

            $('div.langPageCopy').each(function (index, div) {
                div = $(div);
                let langId = div.attr("data-lang-id");
                let langPageForm = div.find('.pageCopyForm');
                let curPathPrefix = $ch.pagePathMap[langId];

                langPageForm.removeClass('was-validated');

                if (typeof curPathPrefix == 'string' && curPathPrefix.trim().length > 0) {
                    curPathPrefix = curPathPrefix.trim();
                    let pathDiv = langPageForm.find('[name=path]').parents(".input-group:first");
                    pathDiv.find(".input-group-prepend:first .input-group-text:first").text(curPathPrefix);
                }
                if (langId === '1') {
                    div.find('input[name=path]').on('change', function () {
                        let val = $(this).val();
                         $(".langPageCopy input[name=path]").val(val);
                    });
                }
                div.find('input[name=name]').on('change', function () {
                    let val = $(this).val();
                    $(".langPageCopy input[name=name]").val(val);
                });
                langPageForm.trigger("reset");
            });

            let tr = button.parents('tr:first');
            let pageId = tr.data('page-id');
            let pageName = tr.find('td.name').text();

            mainDiv.find('[name=duplicateBlocs]').prop("checked", false);
            mainDiv.find('[name=pageId]').val(pageId);
            mainDiv.find('[name=pageName]').val(pageName);

        });

        // autoRefreshPages();

        $ch.actionsCellTemplatePage = $('#actionsCellTemplatePage').html();
        $ch.actionsCellTemplateFolder = $('#actionsCellTemplateFolder').html();
        $ch.actionsCellTemplateStructuredPage = $('#actionsCellTemplateStructuredPage').html();

        <%if(editId.length()>0){ %>
            editFolder('<%=editId%>');
        <%}%>
    });
 
    function initPagesTable() {

        window.pagesTable = jQuery('#pagesTable').DataTable({
            responsive: true,
            pageLength: 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax: function (data, callback, settings) {
                getPagesList(data, callback, settings);
            },
            searching: false,
            lengthChange:true,
            order: [[1, 'asc'], [2, 'asc']],
            columns: [
                {"data": "id"},
                {"data": "row_type"},
                {"data": "name", className: "name"},
                {"data": "row_type", className: "text-capitalize"},
                {"data": "variant", className: "text-capitalize"},
                {"data": "nb_items"},
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
                            return '<input type="checkbox" class="idCheck d-none d-sm-block ' + row.row_type
                                + '" name="pageId" onclick="onCheckItem(this)" value="' + data + '" >';
                        }
                        else {
                            return data;
                        }
                    }
                },
                {
                    targets: [1],
                    render: function (data, type, row) {
                        if (type == 'display') {
                            if (data == 'folder') {
                                var html =
                                '<a href="pages.jsp?folderId='+row.uuid+'" style="color:currentColor;">' +
                                    feather.icons.folder.toSvg({class: 'feather-20', fill: '#aaa'}) +
                                '</a>';
                            return html;
                            }
                            else {
                                var editor = "";
                                if(row.row_type == "structured"){
                                    editor = "structuredPageEditor.jsp?id="+row.id;
                                }else{
                                    editor = "pageEditor.jsp?id="+row.id;
                                 }
                                var html =
                                '<a href="'+editor+'" style="color:currentColor;">' +
                                    feather.icons.file.toSvg({class: 'feather-20', fill: "#fff"}) +
                                '</a>';
                                return html;
                            }
                        }
                        else {
                            return data;
                        }
                    }
                },
                {
                    targets: [2],
                    render: function (data, type, row) {
                        return '<strong>'+_hEscapeHtml(data)+'</strong>'
                    }
                },
                {
                    targets: [3],
                    render: function (data, type, row) {
                        if (data !== 'folder') {
                            return  "Page : " + row.page_type;
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
                                return '-';
                            }
                            else {
                                return data;
                            }
                        }
                        else {
                            return data;
                        }
                    }
                },
                {
                    targets: [5],
                    render: function (data, type, row) {
                        if (type == 'display') {
                            if (row.row_type == 'folder') {
                                var html =
                                '<a href="pages.jsp?folderId='+row.uuid+'" style="color:currentColor;"><span class="badge badge-secondary">' + data + '</span>' +
                                '</a>';
                                return html;
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
                if (row.row_type == "folder") {
                    $(row).data('folder-id', data.id);
                }
                else {
                    $(row).data('page-id', data.id);
                }
                let status ;
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
        });

        var lastDiv = $("#pagesTable_wrapper > div:first > div:last");
        lastDiv.append($('<div class="form-group d-flex align-items-center justify-content-end gap-2" ><label for="customSearch" class="mr-2 mt-2">Search:</label><input type="search"style="width:200px" class="form-control form-control-sm mr-2" id="customSearch"></div>'));
        

        const debouncedReloadPagesTable = debounce(function(){window.pagesTable.ajax.reload()}, 300); // Debounce with a 300ms delay

        $("#customSearch").off("keyup").on("keyup", debouncedReloadPagesTable);



    }
    
    function debounce(func, delay) {
        let timerId;

        return function () {
            const context = this;
            const args = arguments;

            clearTimeout(timerId);

            timerId = setTimeout(function () {
            func.apply(context, args);
            }, delay);
        };
    }

    function onCheckItem(check) {
        check = $(check);
        var row = window.pagesTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.pagesTable.table().body()).find('.idCheck');
        }
        else {
            //un select all
            var allChecks = window.pagesTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked', isChecked);

        allChecks.each(function (index, el) {
            $(el).triggerHandler('click');
        });

    }

    function getPagesList(data, callback, settings) {
        // showLoader();
        $.ajax({
             url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType: 'getPagesList',
                folderId: $('#folderUuid').val(),
                folderType: $('#folderType').val(),
                searchText: $('#customSearch').val()
                
            },
        })
        .done(function (resp) {
            var data = [];
            if (resp.status == 1) {
                data = resp.data.pages;

                $.each(data, function (index, val) {

                    if (val.row_type == "folder") {
                        val.actions = strReplaceAll($ch.actionsCellTemplateFolder, "#FOLDERID#", val.id);
                        val.actions = strReplaceAll(val.actions, "#FOLDERUUID#", val.uuid);
                    }
                    else if (val.row_type == "structured" && val.page_type !== "blocks") {
                        val.actions = strReplaceAll($ch.actionsCellTemplateStructuredPage, "#PAGEID#", val.id);
                    }
                    else {
                        val.actions = strReplaceAll($ch.actionsCellTemplatePage, "#PAGEID#", val.id);
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

    function copyBlocPage(){
        // checking validity
        let valid = true;
        let reqParams = '';
        $('div.langPageCopy').each(function (index, el) {
            let langId = $(el).attr("data-lang-id");
            let langTab = $('#pageCopyLangTab_' + langId);
            let langPageForm = $('#pageCopyForm_'+langId)

            if (!langPageForm.get(0).checkValidity()) {
                let langName = $('#-' + langId).text();
                langPageForm.addClass('was-validated');
                langTab.trigger('click');
                bootNotifyError("Specify all required fields for language " + langName);
                valid = false;
                return false;
            }
            let paramFields =  langPageForm.serializeArray();
            let paramLangFields = [];
            paramFields.forEach(function (fieldObj) {
                let fieldName = fieldObj.name;
                if(fieldName != 'name'){
                    fieldName = fieldName+"_lang_"+langId;
                }
                paramLangFields.push({name: fieldName, value: fieldObj.value});
            });
            reqParams += $.param(paramLangFields)+"&";
        });
        if(valid){
            copyPageRequest(reqParams);
        }
    }

    function copyPageRequest(reqParams) {
        showLoader();
        let mainDiv =  $('#copyPageDivMain');
        reqParams += $.param({pageId:  mainDiv.find('[name=pageId]').val()})+"&";
        reqParams += $.param({duplicateBlocs:  mainDiv.find('[name=duplicateBlocs]').prop("checked")?1:0})+"&";
        reqParams += $.param({requestType:  'copyBlocPage'})+"&";
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: reqParams,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootNotifyError(resp.message);
            }
            else {
                // generatePageHtml(resp.data.pageId, refreshDataTable);
                bootNotify("Page copy created.")
                refreshDataTable();
                $('#modalCopyPage').modal('hide');
            }
        })
        .always(function () {
            hideLoader();
        });

    }

    function deletePage(pageId, pageType) {
        bootConfirm("Are you sure you want to delete this page ?",
            function (result) {
                if (!result) return;

                var page = [{id: pageId, type: pageType}]
                deletePages(page);
            });
    }

    function deleteSelected() {
        var PAGE_FREEMARKER = '<%=Constant.PAGE_TYPE_FREEMARKER%>';
        var PAGE_STRUCTURED = '<%=Constant.PAGE_TYPE_STRUCTURED%>';

        var pageRows = window.pagesTable.rows({selected: true}).nodes().to$().find(".idCheck");
        if (pageRows.length == 0) {
            bootNotify("No page or folder selected");
            return false;
        }
        var publishedPageCount = 0;
        var foldersCount = 0;
        var pagesCount = 0;

        var deletedPages = [];

        $.each(pageRows, function (index, row) {
            if($(row).hasClass("folder")){
                deletedPages.push({id: $(row).val(), type: "folder"});
                foldersCount += 1;
            }else if($(row).hasClass(PAGE_STRUCTURED)){
                pagesCount += 1;
                if (!$(row).closest('tr').hasClass('table-danger')) {
                    publishedPageCount += 1;
                }else{
                    deletedPages.push({id: $(row).val(), type: PAGE_STRUCTURED});
                }
            }else if($(row).hasClass(PAGE_FREEMARKER)){
                pagesCount += 1;
                if (!$(row).closest('tr').hasClass('table-danger')) {
                    publishedPageCount += 1;
                }else{
                    deletedPages.push({id: $(row).val(), type: PAGE_FREEMARKER});
                }
            }
        });

        var confirmMsg = "";
        if(pagesCount >0){
            confirmMsg += " "+pagesCount + " page(s)";
        }
        if(foldersCount>0){
            if(confirmMsg.length>0){
                confirmMsg += " and ";
            }
            confirmMsg += " "+foldersCount + " folder(s)";
        }
        confirmMsg += " are selected. Are you sure you want to delete them?";

        if (publishedPageCount > 0) {
            confirmMsg += "<br><br>Note: " + publishedPageCount + " page(s) are published. Published pages will not be deleted.";
        }
        
        bootConfirm(confirmMsg, function (result) {
            if (result) {
                deletePages(deletedPages);
            }
        });
    }

    function deletePages(pages) {
        if (pages.length <= 0) {
            return false;
        }

        //for multi value parameters to work
        var params = $.param({
            requestType: 'deletePages',
            folderType: $('#folderType').val(),
            pages: JSON.stringify(pages)
        }, true);
        showLoader();
        $.ajax({
            url: 'publishUnpublishPagesAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootAlert(resp.message + " ");
            }
            else {
                bootNotify(resp.message);
            }
        })
        .always(function () {
            hideLoader();
            refreshDataTable();
        });

    }
    function deleteFolders(folders) {
        if (folders.length <= 0) {
            return false;
        }

        //for multi value parameters to work
        var params = $.param({
            requestType: 'deleteFolders',
            folderType: $('#folderType').val(),
            folders: folders
        }, true);
        showLoader();
        $.ajax({
            url: 'publishUnpublishPagesAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootAlert(resp.message + " ");
            }
            else {
                bootNotify(resp.message);
                refreshDataTable();
            }
        })
        .always(function () {
            hideLoader();
        });

    }

    function unpublishPage(btn) {
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var checkInput = tr.find('.idCheck');
        checkInput.prop('checked', true);
        onCheckItem(checkInput);
        onPublishUnpublish('unpublish', [$(checkInput)]);
    }


    function onPageSaveSuccess(resp, form) {
        refreshDataTable();
    }

    function refreshDataTable() {
        window.pagesTable.ajax.reload(function () {
            $('#checkAll').triggerHandler('change');
        }, false);
    }

    function autoRefreshPages() {
        setTimeout(function () {
            refreshDataTable();
            autoRefreshPages();
        }, 2 * 60 * 1000);
    }

    function  openMoveToModal() {
        var pageRows = window.pagesTable.rows({selected: true}).nodes().to$().find(".idCheck");
        if (pageRows.length == 0) {
            bootNotify("No page or folder selected");
            return false;
        }
        $("#moveToSelection").val("");
        $("#moveToDlg").modal("show");
        loadFoldersList($('#pagesFolderSelect'), $('#folderType').val());
    }

    function moveSelectedPages() {
        $("#moveToDlg").modal("hide");

        var PAGE_FREEMARKER = '<%=Constant.PAGE_TYPE_FREEMARKER%>';
        var PAGE_STRUCTURED = '<%=Constant.PAGE_TYPE_STRUCTURED%>';

        var moveToFoldreId = $('#pagesFolderSelect').val();
        var moveToFoldreName = $('#pagesFolderSelect option:selected').text();
        var pageRows = window.pagesTable.rows({selected: true}).nodes().to$().find(".idCheck");
        if(moveToFoldreId == ""){
            return false;
        }
        if (pageRows.length == 0) {
            bootNotify("No page or folder selected");
            return false;
        }
        var foldersCount = 0;
        var pagesCount = 0;

        var pages = [];

        $.each(pageRows, function (index, row) {
            if($(row).hasClass("folder")){
                pages.push({id: $(row).val(), type: "folder"});
                foldersCount += 1;
            }else if($(row).hasClass(PAGE_STRUCTURED)){
                pages.push({id: $(row).val(), type: PAGE_STRUCTURED});
                pagesCount += 1;
            }else if($(row).hasClass(PAGE_FREEMARKER)){
                pages.push({id: $(row).val(), type: PAGE_FREEMARKER});
                pagesCount += 1;
            }
        });

        var confirmMsg = "";
        if(pagesCount >0){
            confirmMsg += " "+pagesCount + " page(s)";
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
                movePages(pages, moveToFoldreId);
            }
        });
    }

    function movePages(pages, moveToFoldreId) {
        if (pages.length <= 0) {
            return false;
        }
        //for multi value parameters to work
        var params = $.param({
            requestType: 'movePages',
            pages: JSON.stringify(pages),
            folderType: $('#folderType').val(),
            moveToFolderId: moveToFoldreId
        }, true);

        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootAlert(resp.message + " ");
            }
            else {
                bootNotify(resp.message);
                refreshDataTable();
            }
        })
        .always(function () {
            hideLoader();
        });
    }

</script>
</body>
</html>