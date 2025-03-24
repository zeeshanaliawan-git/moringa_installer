<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList, java.util.List " %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%
    Set rs = null;
    String q = null;
    boolean active = true;
    List<Language> langsList = getLangs(Etn,session);

    int editId = parseInt(request.getParameter("editId"));

%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp" %>
        <title>Menu JS List</title>
    </head>
<body class="c-app" style="background-color:#efefef">
    <%@ include file="/WEB-INF/include/sidebar.jsp" %>
    <div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Menu js",""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">List of Menu JS</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-danger mr-2"
                            onclick="deleteSelectedMenuJs();">Delete
                    </button>
                    <div class="btn-group mr-2">
                        <button class="btn btn-danger" type="button"
                                onclick="onPublishUnpublish('publish')">Publish
                        </button>
                        <button class="btn btn-danger" type="button"
                                onclick="onPublishUnpublish('unpublish')">Unpublish
                        </button>
                    </div>
                    <div class="btn-group mr-2">
                        <button type="button" class="btn btn-primary"
                                onclick="goBack('pages.jsp')">Back
                        </button>
                    </div>
                    <button type="button" class="btn btn-primary mr-2"
                            onclick="refreshTable();" title="Refresh">
                        <i data-feather="refresh-cw"></i></button>
                    <button class="btn btn-success mr-2"
                            type="button" onclick="openAddEditMenuJsModal();">Add a Menu JS
                    </button>
                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Menu js');" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>
                </div>
            </div>
            <!-- row -->
            <table class="table table-hover table-vam" id="menuJsTable" style="width: 100%;">
                <thead class="thead-dark">
                <tr>
                    <th scope="col">
                        <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                    </th>
                    <th scope="col">Name</th>
                    <th scope="col">Description</th>
                    <th scope="col">Status</th>
                    <th scope="col">Last changes</th>
                    <th scope="col" style="min-width:150px;">Actions</th>
                </tr>
                </thead>
                <tbody>
                <!-- loaded by ajax -->
                </tbody>
            </table>
            <div id="actionsCellTemplate" class="d-none">
                <button class="btn btn-sm btn-primary settingsBtn"
                        type="button" onclick="openAddEditMenuJsModal('#ID#')">
                    <i data-feather="edit"></i></button>
                <button class="btn btn-sm btn-primary " title="Copy"
                        onclick="openCopyMenuJsModal('#ID#')">
                    <i data-feather="copy"></i></button>
                <button class="btn btn-sm btn-danger deleteBtn" onclick="deleteSingleMenuJs('#ID#')">
                    <i data-feather="x"></i></button>
            </div>
            <!-- row-->
            <!-- /end of container -->
        </main>
    </div>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    <textarea id="hiddenInput" name="ignore" value="" style="display:none;"></textarea>

    <!-- Modal -->
    <div class="modal fade" id="modalAddEditMenuJs" tabindex="-1" role="dialog" data-backdrop="static">
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="addEditMenuJsForm" action="" novalidate>
                    <input type="hidden" name="requestType" value="saveMenuJs">
                    <input type="hidden" name="id" value="">
                    <input type="hidden" name="details"  value="">

                    <div class="modal-header">
                        <h5 class="modal-title"></h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group row">
                            <label class="col-3 col-form-label">Name</label>
                            <div class="col">
                                <input type="text" class="form-control" name="name" value=""
                                       maxlength="100" required="required">
                                <div class="invalid-feedback">
                                    Cannot be empty.
                                </div>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col-3 col-form-label">Description</label>
                            <div class="col">
                                <input type="text" class="form-control" name="description" value=""
                                       maxlength="1000">
                            </div>
                        </div>
                        <div class="form-group row keyRow">
                            <label class="col-3 col-form-label">Key</label>
                            <div class="col">
                                <div class="input-group">
                                    <input type="text" class="form-control" name="uuid" value=""
                                            id="menuJsKey" readonly="">
                                    <div class="input-group-append">
                                        <button type="button" class="btn btn-success" id="copyBtn"
                                                onclick="copyInputToClipboard('#menuJsKey')">
                                            <i class="fa fa-copy"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="form-group row keyRow">
                            <label class="col-3 col-form-label">&nbsp;</label>
                            <div class="col">
                                <button type="button" class="btn btn-success" onclick="regenerateMenuJsKey()">Generate new key</button>
                            </div>
                        </div>
                        <div>
                            <ul class="nav nav-tabs menuJsDetailsTabs" role="tablist">
                                <%
                                    //TODO add copy to all button for lanuage copy from default to all
                                    for (Language lang:langsList) {
                                %>
                                <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
                                    <a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
                                       data-toggle="tab" href="#menuJsDetails_<%=lang.getLanguageId()%>"
                                       role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%>
                                    </a>
                                </li>
                                <%
                                        active =false;
                                    }
                                %>
                            </ul>

                            <div class="tab-content py-2" style="border:none;">
                                <%
                                    active =true;
                                    for (Language lang:langsList) {
                                %>
                                <div class='tab-pane langTabContent menuJsLangDetailsDiv menuJsLangDetailsDiv_<%=lang.getLanguageId()%> <%=(active)?"show active":""%>'
                                     id="menuJsDetails_<%=lang.getLanguageId()%>"
                                     data-lang-id='<%=lang.getLanguageId()%>'
                                     role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                    <!-- lang specific fields  -->

                                    <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-1"
                                            data-toggle="collapse" href="#headerCollapse_<%=lang.getLanguageId()%>" role="button">
                                        Header
                                    </button>
                                    <div class="collapse show headerFooterCollapse headerCollapse px-2"
                                         id="headerCollapse_<%=lang.getLanguageId()%>">
                                        <div class="form-group row searchRow pt-2">
                                            <div class="col">
                                                <div class="input-group">
                                                    <select class="custom-select bloc_search_type" name="ignore">
                                                        <option value=""> -- bloc type --</option>
                                                        <option value="system">System bloc</option>
                                                        <option value="bloc">Standard bloc</option>
                                                    </select>
                                                    <div class="position-relative">
                                                    <input type="text" class="form-control bloc_search_term"
                                                            placeholder="search and select" name="ignore"/>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col-2 col-form-label">Header</label>
                                            <div class="col">
                                                <div class="w-100 pt-2">
                                                    <div class="headerFooterBlocList headerBlocList_<%=lang.getLanguageId()%> ">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-1"
                                            data-toggle="collapse" href="#footerCollapse_<%=lang.getLanguageId()%>" role="button">
                                        Footer
                                    </button>
                                    <div class="collapse show headerFooterCollapse footerCollapse px-2"
                                         id="footerCollapse_<%=lang.getLanguageId()%>">
                                        <div class="form-group row searchRow pt-2">
                                            <div class="col">
                                                <div class="input-group">
                                                    <select class="custom-select bloc_search_type" name="ignore">
                                                        <option value=""> -- bloc type --</option>
                                                        <option value="system">System bloc</option>
                                                        <option value="bloc">Standard bloc</option>
                                                    </select>
                                                    <div class="position-relative">
                                                    <input type="text" class="form-control bloc_search_term"
                                                        placeholder="search and select" name="ignore"/>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col-2 col-form-label">Footer</label>
                                            <div class="col">
                                                <div class="w-100 pt-2">
                                                    <div class="headerFooterBlocList footerBlocList_<%=lang.getLanguageId()%> ">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="keyRow">
                                        <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-1"
                                                data-toggle="collapse" href="#menuJsInstructionsCollapse_<%=lang.getLanguageId()%>" role="button">
                                            Instructions
                                        </button>
                                        <div class="collapse show px-2"
                                             id="menuJsInstructionsCollapse_<%=lang.getLanguageId()%>">
                                            <div class="row pt-2">
                                                <div class="col">
                                                    <ol>
                                                        <li>
                                                            Add script with tag to the page with <var>id</var> and <var>lang</var> as parameters
                                                            <br><br>
                                                            <pre class="text-wrap text-success font-weight-bold">&lt;script src="<%=request.getContextPath()%>/api/menujs.jsp?id=<var><span class="text-info menuJsId"></span></var>&lang=<span class="text-info "><var><%=lang.getCode()%></var></span>"&gt;&lt;/script&gt;</pre>

                                                        </li>
                                                        <li>
                                                            On document ready, header will be loaded in element <code>id="mosse-header"</code> and  footer will be loaded in element <code>id="mosse-footer"</code>
                                                        </li>
                                                        <li>
                                                            You can load header and footer in custom elements using followingfunction :
                                                            <br><code>AsiminaMenuJs.addHeaderFooter( "headerElementId", "footerElementid" )</code>
                                                        </li>
                                                        <li>Advanced options:<br>
                                                            you can prevent loading specific js/css files an array of strings. Any css/js file containing any of the terms in array will not be loaded. Assign the array to property <code>AsiminaMenuJs.excludedFiles</code>. example:
                                                            <br>
                                                            <code> AsiminaMenuJs.excludedFiles = ["jquery","bootstrap"]; </code>

                                                        </li>
                                                    </ol>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                </div>
                                <!-- tabContent -->
                                <%
                                        active =false;
                                    }//for lang tab content
                                %>
                            </div>
                        </div>

                        <!-- modal body -->
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="onSaveMenuJs()">Save</button>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div>
    <!-- /.modal -->
    <div class="modal fade" id="modalCopyMenuJs" tabindex="-1" role="dialog" data-backdrop="static">
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="copyMenuJsForm" action="">
                    <input type="hidden" name="requestType" value="copyMenuJs">
                    <input type="hidden" name="copyId" value="">

                    <div class="modal-header">
                        <h5 class="modal-title" id="">Copy menu js</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="form-group row">
                                <label class="col-4 col-form-label">Copy from</label>
                                <div class="col">
                                    <input type="text" name="copyName" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-4 col-form-label">Name</label>
                                <div class="col">
                                    <input type="text" class="form-control" name="name" value=""
                                           maxlength="100" required="required">
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-4 col-form-label">Description</label>
                                <div class="col">
                                    <input type="text" class="form-control" name="description" value=""
                                           maxlength="1000">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="onSaveCopyMenuJs()">Save</button>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->
    <!-- /.modal -->
    <div class="d-none">
        <div id="blocItemTemplate">
            <div class="col mb-2 p-0 headerFooterBlocItem">
                <div class="btn-group w-100">
                    <div class="btn btn-secondary btn-lg btn-block text-left">
                        #NAME#
                    </div>
                    <button type="button" class="btn btn-danger" onclick="removeHeaderFooterBlocItem(this)">
                        <i data-feather="x"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
    </div>

<%@ include file="checkPublishLogin.jsp" %>
<script type="text/javascript">
    
    $ch.editId = '<%=editId%>';
    $(function () {
        $('#copyBtn').popover({
            content: 'copied to clipboard',
            placement: 'top',
            delay: 0
        })
        .on('shown.bs.popover',function(){
            setTimeout(function(){
                $('#copyBtn').popover('hide');
            }, 1000);
        });

        $('#menuJsTable tbody').tooltip({
            placement : 'bottom',
            html : true,
            selector : ".custom-tooltip"
        });

        initMainDataTable();

        $ch.TEMPLATE_BLOC_ITEM = $('#blocItemTemplate').html();

        function debounce(func, timeout = 300){
            let timer;
            return (...args) => {
                clearTimeout(timer);
                timer = setTimeout(() => { func.apply(this, args); }, timeout);
            };
        }

        $('input.bloc_search_term').on('change paste keyup',function(e){
            // console.log(e.target);
            debounce((e)=>{console.log(e)});
        });

        $('input.bloc_search_term').each(function (index, input) {

            var blocType = $(input).parent().parent().find('select.bloc_search_type:first');
            input.addEventListener("input",function(e){
                var ul = e.target.parentElement.querySelector(".autocomplete-items");
                if(ul==null){
                    ul = document.createElement("ul");
                    ul.classList.add("autocomplete-items","position-absolute","bg-white","d-flex","flex-column","p-2","overflow-auto","w-100");
                    ul.style.listStyleType = "none";
                    ul.style.overflow = "auto";
                    ul.style.left = "0";
                    ul.style.gap = "7px";
                    ul.style.maxHeight = "280px";
                    ul.style.zIndex = "99999999";
                    e.target.parentNode.appendChild(ul);
                }
                var searchTerm = e.target.value;
                console.log(blocType.val());
                if(searchTerm.length > 1){
                    showLoader();
                    $.ajax({
                        url : 'blocsAjax.jsp',
                        dataType : 'json',
                        data : {
                            requestType : "searchBlocsList",
                            search : searchTerm,
                            type : blocType.val(),
                        },
                    })
                    .done(function (resp) {
                        console.log(resp);
                        if (resp.status == '1') {
                            ul.innerHTML="";
                            var blocsData = resp.data.blocs.map(function (blocObj, idx) {
                                blocObj.label = blocObj.name;
                                return blocObj;
                            });
                            renderMenu(ul, blocsData);
                        }
                        else {
                            ul.innerHTML="";
                            bootNotifyError(resp.message);
                            
                        }
                    })
                    .fail(function () {
                        ul.innerHTML="";
                        bootNotifyError("Error in accessing server.");
                        
                    })
                    .always(function () {
                        hideLoader();
                    });
                }
            });
        });


        if($ch.editId > 0){
            openAddEditMenuJsModal($ch.editId);
        }

    });

    function renderMenu(menuElement, items) {
        items.forEach(function (item) {
         renderMenuItem(menuElement, item);
        });
    }

    function renderMenuItem(ul, item) {
        var li = document.createElement("li");
        li.dataset.value=item.value;
        li.innerText=item.label;
        
        li.addEventListener("click",function(e)
        {
            var targetUl=e.target.closest("ul");
            var inputTag = targetUl.previousSibling;
            selectHeaderFooterBloc(item, inputTag);
            inputTag.value=e.target.value;
            targetUl.innerHTML="";
        });
        ul.appendChild(li);
    }

    function initMainDataTable() {
        
        window.dataTable = jQuery('#menuJsTable')
        .DataTable({
            responsive: true,
            pageLength : 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function (data, callback, settings) {
                getList(data, callback, settings);
            },
            order : [[1, 'asc']],
            columns : [
                {"data" : "id", className : ""},
                {"data" : "name", className : "text-nowrap"},
                {"data" : "description"},
                {"data" : "publish_status"},
                {"data" : "updated_ts"},
                {"data" : "actions", className : "dt-body-right"},
            ],
            columnDefs : [
                {targets : [0, -1], searchable : false, orderable : false},
				{targets : [1,2], render: _hEscapeHtml},
                {
                    targets : [0],
                    render : function (data, type, row, meta) {
                        return '<input type="checkbox" class="idCheck d-none d-sm-block" name="menuJsId" onclick="onCheckItem(this)" value="' + data + '" >';
                    }
                },
                {
                    targets : [-2],
                    render : function (data, type, row) {
                        if (type == 'sort' && data.trim().length > 0) {
                            return getMoment(data).unix();
                        }
                        else {

                            let toolTipText = "";
                            if (row.updatedby) toolTipText += "Last changes: by " + row.updatedby;

                            let htmlData = data +
                                ' <a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="' + toolTipText + '">' +
                                feather.icons.info.toSvg() +
                                '</a>'
                            return htmlData;
                        }

                    }
                },

            ],
            select : {
                style : 'multi',
                className : 'bg-published',
                selector : 'td.noselector' //dummyselector
            },
            createdRow : function (row, data, index) {
                var row$ = $(row);
                row$.data('row-data', data);
                let status;
                switch (data['row_status']) {
                    case 'published':
                        status = 'success';
                        break;
                    case 'unpublished':
                        status = 'danger';
                        break;
                    case 'changed':
                        status = 'warning';
                        break;
                    default:
                        break;
                }
                $(row).addClass('table-' + status);
            },
        });
    }

    function onCheckItem(check) {
        check = $(check);
        var row = window.dataTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.dataTable.table().body()).find('.idCheck');
        }
        else {
            //un select all
            var allChecks = window.dataTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked', isChecked);

        allChecks.each(function (index, el) {
            $(el).triggerHandler('click');
        });

    }

    function getList(data, callback, settings) {
        // showLoader();
        $.ajax({
            url : 'menuJsAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'getList'
            },
        })
        .done(function (resp) {
            var data = [];
            if (resp.status == 1) {
                data = resp.data.menuJs;
                var actionTemplate = $('#actionsCellTemplate').html();
                $.each(data, function (index, val) {
                    var curId = val.id;
                    val.actions = strReplaceAll(actionTemplate, "#ID#", curId);
                });
            }
            callback({"data" : data});
        })
        .fail(function () {
            callback({"data" : []});
        })
        .always(function () {
            // hideLoader();
        });

    }

    function selectHeaderFooterBloc(blocData, input) {
        var headerFooterCollapse = $(input).parents('.headerFooterCollapse:first');

        var headerFooterBlocList = headerFooterCollapse.find(".headerFooterBlocList");

        if (headerFooterBlocList.find('.headerFooterBlocItem').length > 0) {
            bootNotifyError("bloc already selected.");
            return false;
        }

        var blocHtml = strReplaceAll($ch.TEMPLATE_BLOC_ITEM, '#NAME#', blocData.name + ' (' + blocData.type + ')');
        blocHtml = $(blocHtml);
        blocHtml.attr({
            'data-bloc-id' : blocData.id,
            'data-bloc-name' : blocData.name,
            'data-bloc-type' : blocData.type,
        });

        headerFooterBlocList.append(blocHtml);

        //hide searchRow
        headerFooterCollapse.find('.searchRow').hide();
    }

    function removeHeaderFooterBlocItem(div) {
        var headerFooterCollapse = $(div).parents('.headerFooterCollapse:first');
        deleteParent(div, '.headerFooterBlocItem');
        headerFooterCollapse.find('.searchRow').show();
    }

    function openAddEditMenuJsModal(menuJsId) {

        var modal = $('#modalAddEditMenuJs');
        var form = $('#addEditMenuJsForm');
        form.removeClass('was-validated');
        form.get(0).reset();
        form.find('[name=id],[name=details],[name=uuid]').val('');
        form.find('.searchRow').show();
        form.find('.keyRow').hide();
        form.find('.menuJsId').text('');
        var blocsLists = form.find('.headerFooterBlocList');
        blocsLists.html('');
        form.find('.menuJsDetailsTabs:first li:first-child a').tab('show');

        if (typeof menuJsId === 'undefined') {
            //add new
            modal.find('.modal-title').text("Add a new menu js");
            modal.modal('show');
        }
        else {
            //edit
            showLoader();
            $.ajax({
                url : 'menuJsAjax.jsp', type : 'POST', dataType : 'json',
                data : {
                    requestType : "getInfo",
                    id : menuJsId
                },
            })
            .done(function (resp) {
                if (resp.status === 1) {

                    var menujs = resp.data.menu_js;

                    modal.find('.modal-title').text("Edit : " + menujs.name);

                    var fieldList = ["id", "name", "description", "uuid"];

                    $.each(fieldList, function (index, fieldName) {
                        form.find('[name=' + fieldName + ']').val(menujs[fieldName]);
                    });
                    form.find('.menuJsId').text(menujs.uuid);

                    var detailsList = menujs.details;
                    detailsList.forEach(function (curDetail) {
                        var langId = curDetail.langue_id;
                        var langDiv = $('#menuJsDetails_' + langId);
                        if (langDiv.length == 0) return true;

                        if (curDetail.header_bloc_name.length > 0) {
                            var searchInput = langDiv.find('.headerCollapse:first input.bloc_search_term:first');
                            var blocDataObj = {
                                id : curDetail.header_bloc_id,
                                name : curDetail.header_bloc_name,
                                type : curDetail.header_bloc_type,
                            };
                            selectHeaderFooterBloc(blocDataObj, searchInput);
                        }

                        if (curDetail.footer_bloc_name.length > 0) {
                            var searchInput = langDiv.find('.footerCollapse:first input.bloc_search_term:first');
                            var blocDataObj = {
                                id : curDetail.footer_bloc_id,
                                name : curDetail.footer_bloc_name,
                                type : curDetail.footer_bloc_type,
                            };
                            selectHeaderFooterBloc(blocDataObj, searchInput);
                        }

                    })

                    modal.find('.keyRow').show();
                    modal.modal('show');
                }
                else {
                    bootNotifyError(resp.message);
                }
            })
            .fail(function () {
                bootNotifyError("Error in accessing server.");
            })
            .always(function () {
                hideLoader();
            });
        }

    }

    function onSaveMenuJs() {

        var modal = $('#modalAddEditMenuJs');
        var form = modal.find("form:first");

        form.addClass('was-validated');
        if (!form.get(0).checkValidity()) {
            return false;
        }
        var detailsList = [];
        form.find(".menuJsLangDetailsDiv").each(function (i, div) {
            div = $(div);
            var detailObj = {
                langue_id : div.attr('data-lang-id'),
                header_bloc_id : 0,
                header_bloc_type : '',
                footer_bloc_id : 0,
                footer_bloc_type : '',
            };
            var headerBlocItem = div.find('.headerCollapse:first .headerFooterBlocItem:first');
            if (headerBlocItem.length > 0) {
                detailObj.header_bloc_id = headerBlocItem.attr('data-bloc-id');
                detailObj.header_bloc_type = headerBlocItem.attr('data-bloc-type');
            }

            var footerBlocItem = div.find('.footerCollapse:first .headerFooterBlocItem:first');
            if (footerBlocItem.length > 0) {
                detailObj.footer_bloc_id = footerBlocItem.attr('data-bloc-id');
                detailObj.footer_bloc_type = footerBlocItem.attr('data-bloc-type');
            }
            detailsList.push(detailObj);
        });
        form.find('[name=details]').val(JSON.stringify(detailsList));

        showLoader();
        $.ajax({
            url : 'menuJsAjax.jsp', type : 'POST', dataType : 'json',
            data : form.serialize(),
        })
        .done(function (resp) {
            if (resp.status === 1) {
                form.find('[name=id]').val(resp.data.id);
                modal.modal('hide');
                bootNotify("Menu JS saved.");

                if (typeof refreshTable === 'function') {
                    refreshTable();
                }
            }
            else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error in saving. please try again.");
        })
        .always(function () {
            hideLoader();
        });

    }

    function openCopyMenuJsModal(copyId) {

        var modal = $('#modalCopyMenuJs');
        var form = modal.find('form:first');
        form.get(0).reset();
        form.find('[name=copyId]').val('');
        form.removeClass('was-validated');

        showLoader();
        $.ajax({
            url : 'menuJsAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : "getInfo",
                id : copyId
            },
        })
        .done(function (resp) {
            if (resp.status === 1) {
                var menuJs = resp.data.menu_js;
                var copyName = menuJs.name;

                form.find("[name=copyId]").val(copyId);
                form.find("[name=copyName]").val(copyName);

                modal.modal('show');
            }
            else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error in accessing server.");
        })
        .always(function () {
            hideLoader();
        });
    }

    function onSaveCopyMenuJs() {
        var modal = $('#modalCopyMenuJs');
        var form = modal.find('form:first');

        form.addClass('was-validated');
        if (!form.get(0).checkValidity()) {
            return false;
        }

        showLoader();
        $.ajax({
            url : 'menuJsAjax.jsp', type : 'POST', dataType : 'json',
            data : form.serialize(),
        })
        .done(function (resp) {
            if (resp.status === 1) {
                form.find('[name=id]').val(resp.data.id);

                modal.modal('hide');
                bootNotify("Menu js copied.");
                refreshTable();
            }
            else {
                bootAlert(resp.message);
            }
        })
        .fail(function () {
            bootAlert("Error in copying. please try again.");
        })
        .always(function () {
            hideLoader();
        });
    }

    function deleteSingleMenuJs(menuJsId) {
        bootConfirm("Are you sure you want to delete this menu js?",
            function (result) {
                if (!result) return;

                var menuJsIds = [menuJsId];
                deleteMenuJs(menuJsIds);
            });
    }

    function deleteSelectedMenuJs() {

        var rows = window.dataTable.rows({selected : true}).nodes().to$();

        if (rows.length == 0) {
            bootNotify("No record selected");
            return false;
        }

        var menuJsIds = [];
        $.each(rows, function (index, row) {
            var data = $(row).data('row-data');
            menuJsIds.push(data.id);

        });

        var confirmMsg = "" + menuJsIds.length + " records are selected. Are you sure you want to delete these? this action is not reversible.";
        bootConfirm(confirmMsg, function (result) {
            if (result) {
                deleteMenuJs(menuJsIds);
            }
        });

    }

    function deleteMenuJs(menuJsIds) {
        if (menuJsIds.length <= 0) {
            return false;
        }

        //for multi value parameters to work
        var params = $.param({
            requestType : 'deleteMenuJs',
            ids : menuJsIds
        }, true);

        showLoader();
        $.ajax({
            url : 'menuJsAjax.jsp', type : 'POST', dataType : 'json',
            data : params,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootAlert(resp.message + " ");
            }
            else {
                bootNotify(resp.message);
            }
            refreshTable();
        })
        .always(function () {
            hideLoader();
        });

    }

    function regenerateMenuJsKey(confirmed) {

        if(!confirmed){
            var msg = "<span class='text-warning'> This operation will replace the existing key and block all the pages using it. </span><br> Are you sure you want to generate new key?  ";
            bootConfirm(msg, function(response){
                if(response === true){
                   regenerateMenuJsKey(true);
               }
            });
            return false;
        }
        var modal = $('#modalAddEditMenuJs');
        //if modal is not open , abort
        if(!modal.hasClass('show'))return false;
        var form = modal.find("form:first");

        var menuJsId = form.find('[name=id]').val();

        showLoader();
        $.ajax({
            url : 'menuJsAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'regenerateMenuJsKey',
                id : menuJsId
            },
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootAlert(resp.message + " ");
            }
            else {
                bootNotify(resp.message);
                refreshTable();
                openAddEditMenuJsModal(menuJsId);
            }
        })
        .always(function () {
            hideLoader();
        });

    }

    function refreshTable() {
        window.dataTable.ajax.reload(function () {
            $('#checkAll').triggerHandler('change');
        }, false);
    }

    function onPublishUnpublish(action,isLogin){

        var checkedRows = window.dataTable.rows( { selected: true } ).nodes().to$();
        if(checkedRows.length == 0){
            bootNotify("No menujs selected");
        }
        else{

            if(typeof isLogin == 'undefined' || !isLogin){
                checkPublishLogin(action);
            }
            else{
                var msg = "" + checkedRows.length + " menu js selected.\n";
                msg += "Are you sure you want to "+action+" these?";
                var idsList = checkedRows.find('.idCheck').map(function(){
                    return $(this).val();
                }).get();
                bootConfirm(msg, function(isConfirmed){
                    if(!isConfirmed)return;

                    //for multi value parameters to work
                    var params = $.param({
                        requestType : 'publishUnpublish',
                        action : action,
                        ids : idsList
                    }, true);

                    showLoader();
                    $.ajax({
                        url : 'menuJsAjax.jsp', type : 'POST', dataType : 'json',
                        data : params,
                    })
                    .done(function (resp) {
                        if (resp.status != 1) {
                            bootAlert(resp.message + " ");
                        }
                        else {
                            bootNotify(resp.message);
                        }
                        refreshTable();
                    })
                    .always(function () {
                        hideLoader();
                    });
                })

            }
        }
    }


</script>
</body>
</html>