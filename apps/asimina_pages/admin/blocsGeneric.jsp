<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%
    Set rs = null;
    String editBlocId = parseNull(request.getParameter("editBlocId"));
    boolean isMenuScreen = screenType.equals(Constant.SCREEN_TYPE_MENUS);
    List<Language> langsList = getLangs(Etn,session);
    boolean active = true;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title><%=capitalizeFirstLetter(screenType) + "s"%> List</title>

    <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
    <script src="<%=request.getContextPath()%>/ckeditor/adapters/jquery.js" defer></script>
    <script>
        CKEDITOR.timestamp = "" + parseInt(Math.random() * 100000000);
    </script>
    <style type="text/css">
        .ui-datepicker.ui-widget {
            z-index: 2000 !important;
        }

        #blocUsesTbody td.usesAction{
            display:flex;
            justify-content: end;
        }
        #blocUsesTbody td.usesAction > a{
            font-size : 14px;
        }
    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
        <%
        breadcrumbs.add(new String[]{"Content", ""});
        breadcrumbs.add(new String[]{screenType+"s", ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main" style="padding:0px 30px">
            <!-- beginning of container -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">List of <%=capitalizeFirstLetter(screenType) + "s"%>
                </h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-danger mr-2"
                            onclick="deleteSelectedBlocs();">Delete
                    </button>
                    <div class="btn-group mr-2">
                        <button type="button" class="btn btn-primary"
                                onclick="goBack('pages.jsp')">Back
                        </button>
                    </div>
                    <button type="button" class="btn btn-primary mr-2"
                            onclick="refreshTable();" title="Refresh">
                        <i data-feather="refresh-cw"></i></button>
                    <button class="btn btn-success mr-2"
                            data-toggle="modal" data-target="#modalAddNewBloc"
                            data-caller="add">Add a <%=screenType%>
                    </button>
                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('<%=screenType%>'==='bloc'?'Blocs':'Menus (new)');" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>
                </div>
            </div>
            <!-- row -->
            <div class="row">
                <div class="col">
                    <table class="table table-hover table-vam" id="blocsTable" style="width: 100%;">
                        <thead class="thead-dark">
                        <tr>
                            <th scope="col">
                                <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                            </th>
                            <th scope="col"><%=capitalizeFirstLetter(screenType)%> name</th>
                            <th scope="col">Template</th>
                            <th scope="col">Nb use</th>
                            <th scope="col">Last changes</th>
                            <th scope="col" style="width:180px">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        <!-- loaded by ajax -->
                        </tbody>
                    </table>
                    <div id="actionsCellTemplate" class="d-none">
                        <button class="btn btn-sm btn-primary editBlocBtn " type="button"
                                data-caller="edit" data-bloc-id='#BLOC_ID#' data-template='#TEMPLATE_NAME#'
                                onclick="openAddEditBloc(this);">
                            <i data-feather="edit"></i>
                        </button>
                        <button class="btn btn-sm btn-primary " type="button"
                                data-caller="settings" data-bloc-id='#BLOC_ID#' data-template='#TEMPLATE_NAME#'
                                onclick="openAddEditBloc(this)">
                            <i data-feather="settings"></i>
                        </button>
                        <button class="btn btn-sm btn-primary "
                            data-toggle="modal" data-target="#modalCopyBloc"
                            data-bloc-id='#BLOC_ID#'>
                            <i data-feather="copy"></i>
                        </button>
                        <button class="btn btn-sm btn-danger " onclick='deleteBloc(this,"#BLOC_ID#")' >
                            <i data-feather="x"></i>
                        </button>
                    </div>
                </div>
            </div><!-- row-->
            <!-- /end of container -->
        </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>

        <!-- Modal -->

        <div class="modal fade" id="modalBlocUse" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-xl modal-dialog-slideout" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" >Bloc used in these pages</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <table class="table">
                            <thead class="thead-dark">
                                <tr>
                                    <th>Name</th>
                                    <th>Type</th>
                                    <th>Path</th>
                                    <th>&nbsp;</th>
                                </tr>
                            </thead>
                            <tbody id="blocUsesTbody" >

                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

    <div class="modal fade" id="modalCopyBloc" tabindex="-1" role="dialog" data-backdrop="static">
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="copyBlocForm" action="" novalidate>
                    <input type="hidden" name="requestType" value="copyBloc">
                    <input type="hidden" name="blocId" value="">

                    <div class="modal-header">
                        <h5 class="modal-title">Copy <%=screenType%></h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="form-group row">
                                <label class="col col-form-label">Copy From</label>
                                <div class="col-8">
                                    <input type="text" name="blocName" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col col-form-label">New <%=screenType%> name</label>
                                <div class="col-8">
                                    <input type="text" name="name" class="form-control" value=""
                                           required="required" maxlength="100">
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <%@ include file="blocsAddEdit.jsp" %>


    <script type="text/javascript" defer>

        $ch.contextPath = '<%=request.getContextPath()%>';
        $ch.editBlocId = '<%=editBlocId%>';
        $ch.screenType = '<%=screenType%>';

        // ready function
        $(function () {

            initBlocsTable();
            $('#blocsTable tbody').tooltip({
                placement : 'bottom',
                html : true,
                selector : ".custom-tooltip"
            });

            // to hide page editor only controls
            $('.onPageEditor').hide();

            $('#modalCopyBloc').on('show.bs.modal', function (event) {
                var button = $(event.relatedTarget);
                var modal = $(this);

                var form = $('#copyBlocForm');
                form.get(0).reset();

            var tr = button.parents('tr:first');
            var blocId = tr.data('bloc-id');
            var blocName = tr.find('td.blocName').text();

            form.find('[name=blocId]').val(blocId);
            form.find('[name=blocName]').val(blocName);

        });


            $('#copyBlocForm').submit(function (event) {
                event.preventDefault();
                event.stopPropagation();
                onCopyBloc();
            });


        });

        function refreshTable() {
            blocsTable.ajax.reload(function () {
            checkAll.dispatchEvent(new Event('change'));
            }, false);
        }

        function initBlocsTable() {

            window.blocsTable = jQuery('#blocsTable')
            .DataTable({
                // dom : "<flipt>",
                // deferRender : true,
                responsive: true,
                lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
                ajax : function (data, callback, settings) {
                    getBlocsList(data, callback, settings);
                },
                order : [[1, 'asc']],
                columns : [
                    {"data" : "id", className : ""},
                    {"data" : "name", className : "blocName"},
                    {"data" : "template", className : "text-capitalize"},
                    {"data" : "nb_use", className : "nb_use"},
                    {"data" : "updated_ts"},
                    {"data" : "actions", className : "dt-body-right text-nowrap"},
                ],
                columnDefs : [
                    {targets : [0, 5], searchable : false},
                    {targets : [0, 5], orderable : false},
					{targets: [1], render: _hEscapeHtml},
                    {
                        targets : [0],
						render: function ( data, type, row, meta ) {
                        return '<input type="checkbox" class="idCheck d-none d-sm-block" name="blocId" onclick="onCheckItem(this)" value="'+data+'" >';
                    }
                },
                { targets : [4] ,
                    render: function ( data, type, row ) {
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
                        }
                        else {
                            let toolTipText = "";
                            if(row.updated_by) toolTipText += "Last changes: by " + row.updated_by;

                            let htmlData= data +
                            ' <a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="'+toolTipText+'">'+
                                feather.icons.info.toSvg()+
                            '</a>'
                            return htmlData;
                        }

                    }
                },
            ],
            select: {
                style       : 'multi',
                className   : 'bg-published',
                selector    : 'td.noselector' //dummyselector
            },
            createdRow : function ( row, data, index ) {
                $(row).addClass('table-light');
	          $(row).data('bloc-id',data.id);
              $(row).data('bloc-data',data);
            },
            initComplete : function(){
                // $(this).find('.btn.btn-primary:first').trigger('click');
            }
        });
    }

    function onCheckItem(check){
        check = $(check);
        var row = window.blocsTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.blocsTable.table().body()).find('.idCheck');
        }
        else{
            //un select all
            var allChecks = window.blocsTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked', isChecked);

        allChecks.each(function (index, el) {
            $(el).triggerHandler('click');
        });

    }

        function getBlocsList(data, callback, settings) {
            // showLoader();
            $.ajax({
                url : 'blocsAjax.jsp', type : 'POST', dataType : 'json',
                data : {
                    requestType : 'getBlocsList',
                    screenType : $ch.screenType
                },
            })
            .done(function (resp) {
                var data = [];
                if (resp.status == 1) {
                    data = resp.data.blocs;
                    var actionTemplate = $('#actionsCellTemplate').html();
                    $.each(data, function (index, val) {
                        var curId = val.id;
                        var badge_color = (val.nb_use > 0) ? 'secondary' : 'danger';
                        val.nb_use = '<a href="#" data-bloc-id="' + curId + '" onclick="showBlocUses(this)" > <span class="badge badge-' + badge_color + '">' + val.nb_use + '</span></a>';
                        val.actions = strReplaceAll(actionTemplate, "#BLOC_ID#", curId);
                        val.actions = strReplaceAll(val.actions, "#TEMPLATE_NAME#", val.template);
                    });
                }
                callback({"data" : data});
                editBlocFromParameter();
            })
            .fail(function () {
                callback({"data" : []});
    	})
    	.always(function() {
    		// hideLoader();
    	});

    }

    function showBlocUses(ele){
        ele = $(ele);

        if(parseInt(ele.text()) > 0 ){
            showLoader();
            $.ajax({
                url: 'blocsAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : 'getBlocUses',
                    blocId : ele.data('bloc-id')
                },
            })
            .done(function(resp) {
                if(resp.status == 1){

                    var rowsHtml = '';
                    $.each(resp.data.uses, function(index, curUse) {
                        if(curUse.type == "page"){

                            var editLink = '&nbsp;<a class="btn btn-sm btn-warning" target="blocUsePreview" href="pagePreview.jsp?id=' + curUse.id + '">preview</a>';
                            if(curUse.is_published == "1"){
                                editLink += '&nbsp;<a class="btn btn-sm btn-warning" target="blocUsePreviewPublished" href="pagePreview.jsp?published=1&id=' + curUse.id + '">pubilshed preview</a>';
                            }
                            editLink += '&nbsp;<a class="btn btn-sm btn-primary" target="_blank" href="pageEditor.jsp?id=' + curUse.parent_page_id + '">'+feather.icons['edit'].toSvg()+'</a>';

                            curUse.editLink = editLink;
                        }
                        else if(curUse.type == "page_template"){
                            curUse.path = "-";
                            curUse.editLink = '<a class="btn btn-sm btn-primary" target="_blank" href="pageTemplateEditor.jsp?id=' + curUse.id + '">'+feather.icons['edit'].toSvg()+'</a>';
                        }
                        else if(curUse.type == "menu_js"){
                            curUse.path = "-";
                            curUse.editLink = '<a class="btn btn-sm btn-primary" target="_blank" href="menuJs.jsp?editId=' + curUse.id + '">'+feather.icons['edit'].toSvg()+'</a>';
                        }
                        else{
                            curUse.path = "-";
                            curUse.editLink = "";
                        }
                        let curType = strReplaceAll(curUse.type,"_"," ");
                        var row = `
                                <tr>
                                    <td>\${curUse.name}</td>
                                    <td class="text-capitalize-first" >\${curType}</td>
                                    <td>\${curUse.path}</td>
                                    <td class="usesAction">\${curUse.editLink}</td>
                                </tr>
                            `;
                        rowsHtml = rowsHtml + row;
                    });

                    $('#blocUsesTbody').html(rowsHtml);

                    $('#modalBlocUse').modal('show');
                }

            })
            .fail(function() {
                alert('Error in accessing server.');
            })
            .always(function() {
                hideLoader();
            });
        }
    }

    function onCopyBloc() {
        var form = $('#copyBlocForm');

        if (!form.get(0).checkValidity()) {
            form.addClass('was-validated');
            return false;
        }

        showLoader();
        $.ajax({
            url : 'blocsAjax.jsp', type : 'POST', dataType : 'json',
            data : form.serialize(),
        })
        .done(function (resp) {
            if (resp.status != 1) {
                alert(resp.message);
            }
            else {
                bootNotify($ch.screenType + " copy created.");
            }
            refreshTable();
            $('#modalCopyBloc').modal('hide');
        })
        .always(function () {
            hideLoader();
        });

    }

    function deleteBloc(button, blocId) {

        button = $(button);
        var tr = button.parents('tr:first');
        var nb_use = tr.find('td.nb_use').text();
        if (parseInt(nb_use) != 0) {
            bootAlert(`Cannot delete \${$ch.screenType}. It is used in 1 or more pages.`);
        }
        else {
            bootConfirm(`Are you sure you want to delete this \${$ch.screenType} ?`,
                function (result) {
                    if (!result) return;

                    var blocIds = [blocId];
                    deleteBlocs(blocIds);
                });
        }

    }

    function deleteSelectedBlocs() {
        var rows = window.blocsTable.rows({selected : true}).nodes().to$();

        if (rows.length == 0) {
            bootNotify(`No \${$ch.screenType} selected`);
            return false;
        }

        var blocsUsedCount = 0;

        var blocIds = [];
        $.each(rows, function (index, row) {
            var data = $(row).data('bloc-data');
            blocIds.push(data.id);
            var nb_use = $(data.nb_use).text();
            if (parseInt(nb_use) > 0) {
                blocsUsedCount += 1;
            }
        });

        //using javascript string literals for appending variables to strings
        //you have to use \$  instead of $  in JSP files because of conflict with JSP syntax
        var confirmMsg = "" + blocIds.length
            + ` \${$ch.screenType}s are selected. Are you sure you want to delete these \${$ch.screenType}s? this action is not reversible.`;

        if (blocsUsedCount > 0) {
            confirmMsg += `<br>Note: \${blocsUsedCount}  \${$ch.screenType}(s) are in use.
                            \${$ch.screenType}s in use will not be deleted.`;
        }

        bootConfirm(confirmMsg, function (result) {
            if (result) {
                deleteBlocs(blocIds);
            }
        });

    }

    function deleteBlocs(blocIds) {
        if (blocIds.length <= 0) {
            return false;
        }

        //for multi value parameters to work
        var params = $.param({
            requestType : 'deleteBlocs',
            blocIds : blocIds,
            screenType : $ch.screenType
        },true);

        showLoader();
        $.ajax({
            url: 'blocsAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function(resp) {
            if(resp.status != 1){
                bootAlert(resp.message + " ");
            }
            else{
                bootNotify(resp.message);
            }
            refreshTable();
        })
        .always(function() {
            hideLoader();
        });

    }

    function editBlocFromParameter(){
        if($ch.editBlocId.length > 0){

            var dataList = window.blocsTable.data();
            $.each(dataList, function(index, obj) {
                if(obj.id == $ch.editBlocId){
                    //window.blocsTable.search(obj.name).draw();
                    $('<div>').append(obj.actions).find('.editBlocBtn').trigger('click');
                }
            });

            $ch.editBlocId = ''; //one time
        }
    }


</script>
    </body>
</html>