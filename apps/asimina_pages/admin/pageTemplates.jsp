<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    Set rs = null;
    String q = null;
    boolean isSuperAdmin = isSuperAdmin(Etn);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title>Page Templates List</title>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Developer", ""});
        breadcrumbs.add(new String[]{"Page Templates", ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
                <!-- beginning of container -->
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                            <h1 class="h2">Page Templates</h1>
                            <div class="btn-toolbar mb-2 mb-md-0">
                                <%
                                    //check if default system template exists
                                    q = "SELECT id FROM page_templates WHERE is_system = '1' AND site_id = " + escape.cote(getSiteId(session));
                                    rs = Etn.execute(q);
                                    boolean isDefTemplateExists = !(rs.next());
                                    if(isDefTemplateExists){
                                %>
                                <button id="createDefTemplateBtn" type="button" class="btn btn-success mr-2"
                                    onclick="createDefaultTemplate();">Create default template</button>
                                <% } %>

                                <button type="button" class="btn btn-danger mr-2"
                                    onclick="deleteSelectedTemplates();">Delete</button>
                                <div class="btn-group mr-2">
                                    <button type="button" class="btn btn-primary"
                                        onclick="goBack('pages.jsp')">Back</button>
                                </div>
                                <button type="button" class="btn btn-primary mr-2"
                                    onclick="refreshTable();" title="Refresh">
                                    <i data-feather="refresh-cw"></i></button>
                                <button class="btn btn-success mr-2"
                                    type="button" onclick="openAddEditPageTemplateModal();">Add a template</button>
                                <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Page Templates');" title="Add to shortcuts">
                                    <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                                </button>
                            </div>
                        </div>
                        <!-- row -->
                        <table class="table table-hover table-vam" id="templatesTable" style="width: 100%;">
                            <thead class="thead-dark">
                                <tr>
                                    <th scope="col">
                                        <input type="checkbox" class="" id="checkAll" onchange="onChangeCheckAll(this)">
                                    </th>
                                    <th scope="col">Template name</th>
                                    <th scope="col">ID</th>
                                    <th scope="col">Description</th>
                                                <th scope="col">Theme</th>
                                    <th scope="col">Nb uses</th>
                                    <th scope="col">Last changes</th>
                                    <th scope="col" style="min-width:150px">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- loaded by ajax -->
                            </tbody>
                        </table>
                        <div id="actionsCellTemplate" class="d-none" >
                            <a class="btn btn-sm btn-primary editBtn"
                                href="pageTemplateEditor.jsp?id=#ID#">
                                <i data-feather="edit"></i></a>
                            <button class="btn btn-sm btn-primary settingsBtn"
                                            type="button" onclick="openAddEditPageTemplateModal('#ID#', '#THEME_STATUS#')">
                                <i data-feather="settings"></i></button>
                            <button class="btn btn-sm btn-primary " title="Copy"
                                    onclick="openCopyTemplateModal('#ID#')" >
                                <i data-feather="copy"></i></button>
                            <button class="btn btn-sm btn-danger deleteBtn" onclick="deleteTemplate('#ID#')">
                                <i data-feather="x"></i></button>
                        </div>
                        <!-- row-->
                <!-- /end of container -->
            </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>

    <!-- Modal -->
    <%@ include file="pageTemplatesAddEdit.jsp"%>


    <div class="modal fade" id="modalCopyTemplate" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="copyTemplateForm" action="">
                    <input type="hidden" name="requestType" value="copyTemplate">
                    <input type="hidden" name="copyId" value="">

                    <div class="modal-header">
                        <h5 class="modal-title" id="">Copy page template</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">Copy from</label>

                                <div class="col-sm-9">
                                    <input type="text" name="copyTemplateName" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">New name</label>

                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="name" value=""
                                           maxlength="100" required="required"
                                           onchange="onNameChange(this)">
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">New template ID</label>

                                <div class="col-sm-9">
                                    <input type="text" class="form-control" name="custom_id" value=""
                                           maxlength="100" required="required"
                                           onkeyup="onKeyupCustomId(this)"
                                           onblur="onKeyupCustomId(this)">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="onSaveCopyTemplate()" >Save</button>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <div class="modal fade" id="modalTemplateUse" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" >Template used in these pages</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <table class="table">
                            <thead class="thead-dark">
                                <tr>
                                    <th>Page</th>
                                    <th>Path</th>
                                    <!-- <th>&nbsp;</th>
                                    <th>&nbsp;</th> -->
                                </tr>
                            </thead>
                            <tbody id="templateUsesTbody" >

                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->
</div>
<script type="text/javascript">
    // ready function
    $(function() {
        $ch.isSuperAdmin = <%=isSuperAdmin%>;
        $ch.THEME_LOCKED = '<%=Constant.THEME_LOCKED%>';

        $('#templatesTable tbody').tooltip({
            placement : 'bottom',
            html:true,
            selector:".custom-tooltip"
        });

        initMainDataTable();

    });

    function initMainDataTable(){

        window.dataTable = $('#templatesTable')
        .DataTable({
            // dom : "<flipt>",
            // deferRender : true,
            responsive: true,
            pageLength : 100,
            /*-----------------Added By Awais------------------*/
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            /*-----------------End------------------*/
            ajax : function(data, callback, settings){
                getList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
                { "data": "id" , className : "" },
                { "data": "name" , className : "text-nowrap"},
                { "data": "custom_id" , className : "text-nowrap"},
                { "data": "description" },
                { "data": "theme_name" },
                { "data": "nb_use" , className : "nb_use" },
                { "data": "updated_ts" },
                { "data": "actions", className : "dt-body-right" },
            ],
            columnDefs : [
                { targets : [0,-1] , searchable : false, orderable : false},
                { targets : [0] ,
                    render: function ( data, type, row, meta ) {
                        var disable = row.theme_name.length > 0? "disabled":"";
                        return '<input type="checkbox" class="idCheck" '+disable+'  name="templateId" onclick="onCheckItem(this)" value="'+data+'" >';
                    }
                },
                { targets : [4] ,
                    render: function ( data, type, row, meta ) {
                    var badge_color = "warning";
                        var theme = "Local"
                        if(data.length > 0){
                            badge_color = 'success';
                            theme = data+" V"+row.theme_version;
                        }
                        return '<span class="badge badge-'+badge_color+'">'+theme+'</span>';
                    }
                },
                { targets : [6] ,
                    render: function ( data, type, row ) {
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
                        }
                        else {
                            // let updatedText = data;
                            // if(row.updatedby) updatedText += " by " + row.updatedby;
                            // return updatedText;

                            let toolTipText = "";
                            if(row.updatedby) toolTipText += "Last changes: by " + row.updatedby;

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
                var row$ = $(row);
                row$.data('template-data',data);
                if(data.is_system == '1'){
                    row$.find('.deleteBtn,.idCheck').addClass('disabled').prop('disabled',true).removeClass('idCheck');
                }
            },
        });
    }

    function onCheckItem(check){
        check = $(check);
        var row = window.dataTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.dataTable.table().body()).find('.idCheck:not(:disabled)');
        }
        else{
            //un select all
            var allChecks = window.dataTable.rows().nodes().to$().find('.idCheck:not(:disabled)');
        }

        allChecks.prop('checked',isChecked);

        allChecks.each(function(index, el) {
           $(el).triggerHandler('click');
        });

    }

    function getList(data, callback, settings){
        // showLoader();
        $.ajax({
            url: 'pageTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getList'
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.templates;
                var actionTemplateElem = $('#actionsCellTemplate');
                $.each(data, function(index, val) {
                    var curId = val.id;
                    if(val.theme_name.length>0){// part of a theme
                        actionTemplateElem.find(".deleteBtn").attr("disabled", true);
                    } else{
                        actionTemplateElem.find(".deleteBtn").attr("disabled", false);
                    }

                    if(val.theme_status.length > 0 && val.theme_status == $ch.THEME_LOCKED && !$ch.isSuperAdmin){
                        actionTemplateElem.find(".editBtn").html(feather.icons.eye.toSvg())
                    } else{
                        actionTemplateElem.find(".editBtn").html(feather.icons.edit.toSvg())
                    }
                    var actionTemplate = actionTemplateElem.html();

                    var badge_color = (val.nb_use > 0)?'secondary':'danger';
                    val.nb_use = '<a href="#" data-id="'+curId+'" onclick="showTemplateUses(this)" > <span class="badge badge-'+badge_color+'">'+val.nb_use+'</span></a>';
                    val.actions = strReplaceAll(actionTemplate, "#ID#", curId);
                    val.actions = strReplaceAll(val.actions, "#THEME_STATUS#", val.theme_status);
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

    function openCopyTemplateModal(copyTemplateId) {

        var modal = $('#modalCopyTemplate');
        var form = modal.find('form:first');
        form.get(0).reset();
        form.find('[name=copyId]').val('');
        form.removeClass('was-validated');

        showLoader();
        $.ajax({
            url: 'pageTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType: "getInfo",
                templateId: copyTemplateId
            },
        })
        .done(function (resp) {
            if (resp.status === 1) {

                var template = resp.data.template;

                var copyTemplateName = template.name + " ( " + template.custom_id + " )";

                form.find("[name=copyId]").val(copyTemplateId);
                form.find("[name=copyTemplateName]").val(copyTemplateName);

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

    function onSaveCopyTemplate(){
        var modal = $('#modalCopyTemplate');
        var form = modal.find('form:first');

        form.addClass('was-validated');
        if (!form.get(0).checkValidity()) {
            return false;
        }

        showLoader();
        $.ajax({
            url: 'pageTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function (resp) {
            if (resp.status === 1) {
                form.find('[name=id]').val(resp.data.id);

                modal.modal('hide');
                bootNotify("Page template copied.");
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

    function deleteTemplate(templateId){
        bootConfirm("Are you sure you want to delete this page template?",
            function(result){
                if(!result) return;

                var templateIds = [templateId];
                deleteTemplates(templateIds);
            });
    }

    function deleteSelectedTemplates(){

        var rows = window.dataTable.rows( { selected: true } ).nodes().to$();

        if(rows.length == 0){
            bootNotify("No template selected");
            return false;
        }

        var templatesUsedCount = 0;

        var templateIds = [];
        $.each(rows, function(index, row) {
            var data = $(row).data('template-data');
            templateIds.push(data.id);
            if(parseInt(data.nb_use) > 0){
                templatesUsedCount += 1;
            }
        });

        var confirmMsg = ""+ templateIds.length + " templates are selected. Are you sure you want to delete these templates? this action is not reversible.";

        if(templatesUsedCount > 0){
            confirmMsg += "<br/>Note: "+ templatesUsedCount +" template(s) are in use. templates in use will not be deleted.";
        }

        bootConfirm(confirmMsg, function (result){
            if(result){
                deleteTemplates(templateIds);
            }
        });

    }

    function deleteTemplates(templateIds){
        if(templateIds.length <= 0){
            return false;
        }

        //for multi value parameters to work
        var params = $.param({
            requestType : 'deleteTemplates',
            templateIds : templateIds
        },true);

        showLoader();
        $.ajax({
            url: 'pageTemplatesAjax.jsp', type: 'POST', dataType: 'json',
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

    function refreshTable(){
        window.dataTable.ajax.reload(function(){
            $('#checkAll').triggerHandler('change');
        },false);
    }

    function showTemplateUses(ele){
        ele = $(ele);

        if(parseInt(ele.text()) > 0 ){
            showLoader();
            $.ajax({
                url: 'pageTemplatesAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : 'getUses',
                    templateId : ele.data('id')
                },
            })
            .done(function(resp) {
                if(resp.status == 1){

                    var rowsHtml = '';
                    $.each(resp.data.pages, function(index, page) {


                        var prodLink = "&nbsp;";
                        if(page.is_published == "1"){
                            prodLink = '<a target="templateUsePreviewPublished" href="preview.jsp?published=1&id=' + page.id + '">pubilshed preview</a>';
                        }
                        //TODO add a link to edit page for each type
                        var row = '<tr><td> ' + page.name
                        + '</td><td>' + page.path
                        // + '</td><td><a target="templateUsePreview" href="pagePreview.jsp?id=' + page.id + '">preview</a>'
                        // + '</td><td>' + prodLink
                        + '</td></tr>';
                        rowsHtml = rowsHtml + row;
                    });

                    $('#templateUsesTbody').html(rowsHtml);

                    $('#modalTemplateUse').modal('show');
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

    function createDefaultTemplate(){
        showLoader();
        $.ajax({
            url: 'pageTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType: "createDefaultTemplate"
            },
        })
        .done(function (resp) {
            if (resp.status === 1) {
                $('#createDefTemplateBtn').remove();
                bootNotify("Default template created");
                refreshTable();
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

</script>
    </body>
</html>