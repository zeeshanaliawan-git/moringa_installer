<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    // this is generic jsp included in blocTemplates.jsp and systemTemplates.jsp
    // having variable templateType

    boolean isSystemTemplate = "system".equals(templateType);
    boolean isSuperAdmin = isSuperAdmin(Etn);
    String pageTitle = "Templates";
    if(isSystemTemplate){
        pageTitle = "System Templates";
    }
    Set rs = null;
    List<Language> langsList = getLangs(Etn,session);
    boolean active = true;
    String screenType = Constant.SCREEN_TYPE_BLOCKS;
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title><%=pageTitle%></title>

        <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
        <script src="<%=request.getContextPath()%>/ckeditor/adapters/jquery.js"></script>

        <script type="text/javascript">
            $ch.templateType = '<%=templateType%>';
            $ch.isSystemTemplate = ("system" === $ch.templateType);
        </script>
    </head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Developer", ""});
        breadcrumbs.add(new String[]{pageTitle, ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
                <!-- beginning of container -->
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                            <h1 class="h2"><%=pageTitle%></h1>
                            <div class="btn-toolbar mb-2 mb-md-0">
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
                                data-toggle="modal" data-target="#modalAddEditTemplate"
                                data-caller="Add">Add a template</button>
                                <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('<%=pageTitle%>');" title="Add to shortcuts">
                                    <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                                </button>
                            </div>
                        </div>
                        <!-- row -->
                        <div class="row">
                            <div class="col">
                                <table class="table table-hover table-vam" id="templatesTable" style="width: 100%;">
                                    <thead class="thead-dark">
                                        <tr>
                                            <th scope="col">
                                                <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                                            </th>
                                            <th scope="col">Template name</th>
                                            <th scope="col">Type</th>
                                                <th scope="col">Theme</th>
                                            <th scope="col">Nb use</th>
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
                                        href="templateEditor.jsp?id=#ID#">
                                        <i data-feather="edit"></i></a>
                                    <a class="btn btn-sm btn-primary resourceEditBtn"
                                        href="templateResources.jsp?id=#ID#">
                                        <i data-feather="code"></i></a>
                                    <button class="btn btn-sm btn-primary settingsBtn"
                                        data-toggle="modal" data-target="#modalAddEditTemplate"
                                            data-caller="edit" data-template-id='#ID#' data-theme-status='#THEME_STATUS#'>
                                        <i data-feather="settings"></i></button>
                                    <button class="btn btn-sm btn-danger deleteBtn" onclick='deleteTemplate(this, "#ID#")'>
                                        <i data-feather="x"></i></button>
                                </div>
                            </div>
                        </div><!-- row-->
                <!-- /end of container -->
            </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
        </div>

        <!-- Modal -->
        <%@ include file="blocTemplatesAddEdit.jsp"%>

<script type="text/javascript">
    // ready function
    $(function() {
        $ch.isSuperAdmin = <%=isSuperAdmin%>;
        $ch.THEME_LOCKED = '<%=Constant.THEME_LOCKED%>';
        initBlocTemplatesTable();

    });

    $('#templatesTable tbody').tooltip({
                placement : 'bottom',
                html:true,
                selector:".custom-tooltip"
    });


    function initBlocTemplatesTable(){

        window.dataTable = $('#templatesTable')
        .DataTable({
            responsive: true,
            pageLength : 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function(data, callback, settings){
                getList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
                { "data": "id" , className : "" },
                { "data": "name" , className : "text-nowrap"},
                { "data": "type" , className : "text-nowrap text-capitalize-first" },
                { "data": "theme_name" },
                { "data": "nb_use", className : "text-nowrap" },
                { "data": "updated_ts" },
                { "data": "actions", className : "dt-body-right" },
            ],
            columnDefs : [
                { targets : [6] , searchable : false},
                { targets : [0,6] , orderable : false},
                { targets : [0] ,
                    render: function ( data, type, row, meta ) {
                        if(type == 'display'){
                            var disable = row.theme_name.length > 0? "disabled":"";
                            return '<input type="checkbox" class="idCheck d-none d-sm-block" '+disable+' name="templateId" onclick="onCheckItem(this)" value="'+data+'" >';
                        }
                        else {
                            return data;
                        }
                    }
                },
                { targets : [5] ,
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
                { targets : [2] ,
                    render: function ( data, type, row, meta ) {
                        if(type == "display"){
                            return data.split("_").join(" ");
                        }
                        else{
                            return data;
                        }
                    }
                },
                { targets : [4] ,
                    render: function ( data, type, row, meta ) {
                        var nb_use = data;
                        var badge_color = (nb_use > 0)?'secondary':'danger';
                        return '<span class="badge badge-'+badge_color+'">'+nb_use+'</span>';
                    }
                },
                { targets : [3] ,
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
            ],
            select: {
                style       : 'multi',
                className   : 'bg-published',
                selector    : 'td.noselector' //dummyselector
            },
            createdRow : function ( row, data, index ) {
                var row$ = $(row);
                row$.data('template-data',data);
                if(data.type == 'structured_content'){
                    row$.find('.resourceEditBtn').addClass('disabled');
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
            url: 'blocTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getList',
                templateType : $ch.templateType
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


    function deleteTemplate(button, templateId){
        button = $(button);
        var tr = button.parents('tr:first');
        var nb_use =  tr.data('template-data').nb_use;
        if(parseInt(nb_use) != 0){
            bootAlert("Cannot delete template. It is used in 1 or more places.");
        }
        else {
            bootConfirm("Are you sure you want to delete this template ?",
            function(result){
                if(!result) return;

                var templateIds = [templateId];
                deleteTemplates(templateIds);
            });
        }

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
            confirmMsg += "<br>Note: " +templatesUsedCount + " template(s) are in use. templates in use will not be deleted.";
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
            url: 'blocTemplatesAjax.jsp', type: 'POST', dataType: 'json',
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

</script>
    </body>
</html>