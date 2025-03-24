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
    String editId = parseNull(request.getParameter("id"));
    // String siteId = getSiteId(session);//debug

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title>Dynamic Components</title>

    <style type="text/css">
        .text-capitalize-first:first-letter{
            text-transform: capitalize;
        }

        .bg-unpublished .previewBtn, .bg-changed .previewBtn{
            display: none !important;
        }

    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Dynamic", ""});
        breadcrumbs.add(new String[]{"Components", ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                <h1 class="h2">Components</h1>
                <div class="btn-toolbar mb-2 mb-md-0">

                    <button type="button" class="btn btn-primary mr-2"
                    onclick="goBack('')">Back</button>

                    <div class="btn-group mr-2">
                        <button class="btn btn-danger" type="button"
                        onclick="onGenerateComponentPreview('generate')">Generate Preview</button>
                        <button class="btn btn-danger" type="button"
                        onclick="onGenerateComponentPreview('delete')">Delete Preview</button>
                    </div>


                    <button type="button" class="btn btn-primary mr-2"
                    onclick="refreshTable();" title="Refresh"><i data-feather="refresh-cw"></i></button>

                    <button class="btn btn-success"
                        onclick="openAddEditComponentModal()">Add a Component</button>
                    
                    <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Dynamic components');" title="Add to shortcuts">
                        <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                    </button>
                </div>
            </div>
            <!-- row -->
            <table class="table table-hover table-vam" id="componentsTable" style="width:100%;">
                <thead class="thead-dark">
                    <tr>
                        <th scope="col">
                            <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                        </th>
                        <th scope="col">Component name</th>
                        <th scope="col">Preview status</th>
                        <th scope="col">Last changes</th>
                        <th scope="col">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- loaded by ajax -->
                </tbody>
            </table>
            <div id="actionsCellTemplate" class="d-none" >
                <button class="btn btn-sm btn-primary previewBtn" title="Preview"
                    onclick='previewComponent(this)'>
                    <i data-feather="eye"></i>
                </button>

                <button class="btn btn-sm btn-primary " title="Settings"
                    onclick='editComponent("#ID#")'>
                    <i data-feather="settings"></i>
                </button>

                <button class="btn btn-sm btn-danger" title="Delete"
                    onclick='deleteComponent("#ID#")' >
                    <i data-feather="trash-2"></i></button>

            </div>
            <!-- row-->
            <!-- container -->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>
    <%@ include file="componentsAddEdit.jsp"%>

    <!-- Modals -->
    <div class="modal fade" id="modalPreviewComponent" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-lg " role="document">
            <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="">Component preview</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="container-fluid">
                            <button type="button" class="btn btn-secondary  btn-block text-left mb-1"
                                    data-toggle="collapse" href="#previewImageCollapse" role="button" >
                                Image
                            </button>
                            <div class="collapse show py-2 col" id="previewImageCollapse">
                                <img id="previewCompImg" src="" class="img-fluid img-thumbnail" >
                            </div>
                            <button type="button" class="btn btn-secondary  btn-block text-left mb-1"
                                    data-toggle="collapse" href="#previewHTMLCollapse" role="button" >
                                HTML
                            </button>
                            <div class="collapse show py-2 col" id="previewHTMLCollapse">
                                <div id="previewCompHtml"></div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->
<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>/';
    // ready function
    $(function() {
        $('#componentsTable tbody').tooltip({
            placement : 'bottom',
            html:true,
            selector:".custom-tooltip"
        });

    	initTable();
        <% if(editId.length()>0){%>
            editComponent('<%=editId%>', true);
        <%}%>

        autoRefreshComponents();
    });

    function initTable(){

    	window.componentsTable = $('#componentsTable')
        .DataTable({
            responsive: true,
            pageLength : 100,
            ajax : function(data, callback, settings){
            	getComponentsList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
            	{ "data": "id" , className : ""  },
            	{ "data": "name"},
            	{ "data": "thumbnail_status", className : "text-capitalize-first" },
                { "data": "updated_ts" },
                { "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
            	{ targets : [0,4] , searchable : false, orderable : false},
                { targets : [0] ,
                    render: function ( data, type, row, meta ) {
                        if(type == "display"){
                            return '<input type="checkbox" class="idCheck d-none d-sm-block" name="compId" onclick="onCheckItem(this)" value="'+data+'" >';
                        }
                        else{
                            return data;
                        }
                    }
                },
                { targets : [2] ,
                    render: function ( data, type, row ) {
                        //for publish status
                        if(type == 'display' && data == 'error'){
                            var viewBtn = "&nbsp;<button type='button' class='btn btn-sm btn-secondary py-1' onclick='viewLog(this)'>view</button> "
                            return data + viewBtn;
                        }
                        else {
                            return data;
                        }

                    }
                },
                { targets : [3] ,
                    render: function ( data, type, row ) {
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
                        }
                        else {
                            let updatedText = data, toolTipText="";
                            if(row.updated_by) toolTipText += " Last change: By  " + row.updated_by;

                            updatedText +=' <a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="'+toolTipText+'">'+
                                feather.icons.info.toSvg()+
                            '</a>';  
                            return updatedText ;
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
                $(row).data('comp-id',data.id);
                $(row).data('comp-data',data);
                var rowStatus = "unpublished";
                if(data.thumbnail_status == "published"){
                    rowStatus = "published";
                }
                var status ;
                switch (rowStatus) {
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
    }

    function getComponentsList(data, callback, settings){
    	// showLoader();
    	$.ajax({
    		url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
    		data: {
    			requestType : 'getList'
    		},
    	})
    	.done(function(resp) {
    		var data = [];
    		if(resp.status == 1){
    			data = resp.data.components;
    			var actionTemplate = $('#actionsCellTemplate').html();
    			$.each(data, function(index, val) {
    				var curId = val.id;
                    val.published_ts = val.to_publish_ts = '';
    				val.actions = strReplaceAll(actionTemplate, "#ID#", curId);
    			});

                var compDependencyTemplate = $('#compDependencyTemplate');
                if(compDependencyTemplate.length > 0){
                    var compSelect = compDependencyTemplate.find('[name=dependency_comp_id]');
                    compSelect.html('<option value="">-- select component --</option>');

                    $.each(data,function(i,comp){
                        compSelect.append('<option value="'+comp.id+'">'+comp.name+'</option>');
                    });
                }
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

    function deleteComponent(compId){
    	bootConfirm("Are you sure you want to delete this component ?",
    		function(result){
    			if(!result) return;

    			showLoader();
    			$.ajax({
    				url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
    				data: {
    					requestType : 'deleteComponent',
    					id : compId
    				},
    			})
    			.done(function(resp) {
    				if(resp.status != 1){
    					bootNotifyError(resp.message);
    				}
                    else{
                        bootNotify("Component deleted.");
                    }
    				refreshTable();
    			})
    			.always(function() {
    				hideLoader();
    			});

    		});
    }

    function refreshTable(){
        window.componentsTable.ajax.reload(null,false);
    }

    function autoRefreshComponents(){
        setTimeout(function(){
            refreshTable();
            autoRefreshComponents();
        } , 2*60*1000);
    }


    function onGenerateComponentPreview(action){
        var rows = window.componentsTable.rows( { selected: true } ).nodes().to$();

        if(rows.length == 0){
            bootNotify("No components selected");
            return false;
        }

        var count = 0;

        var compIds = [];
        $.each(rows, function(index, row) {
            compIds.push($(row).data('comp-id'));
        });

        //for multi value parameters to work
        var params = $.param({

            requestType : 'generatePreview',
            isGenerate : (action == "generate"?"1":"0"),
            compIds : compIds
        },true);

        showLoader();
        $.ajax({
            url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
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


    function previewComponent(btn){
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var compId = tr.data('comp-id');

        showLoader();
        $.ajax({
            url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : "getThumbnailPreview",
                id : compId
            },
        })
        .done(function(resp) {
            if(resp.status == 1){

                var previewHTML = resp.data.html;
                var thumbnailUrl = resp.data.thumbnailUrl;
                var modal = $("#modalPreviewComponent");

                $("#previewCompImg").attr('src',thumbnailUrl);
                $("#previewCompHtml").text(previewHTML);

                modal.modal("show");
            }
        })
        .always(function() {
            hideLoader();
        });
    }

    function viewLog(btn){
        btn = $(btn);
        var tr = btn.parents('tr:first');
        var compId = tr.data('comp-id');

        showLoader();
        $.ajax({
            url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : "getLog",
                id : compId
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                var logStr = resp.data.log;
                logStr = strReplaceAll(resp.data.log,"\n","<br>");
                bootAlert(logStr,null,'large');
            }
        })
        .always(function() {
            hideLoader();
        });

    }

    function onCheckItem(check){
        check = $(check);
        var row = window.componentsTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.componentsTable.table().body()).find('.idCheck');
        }
        else{
            //un select all
            var allChecks = window.componentsTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked',isChecked);

        allChecks.each(function(index, el) {
           $(el).triggerHandler('click');
        });

    }


</script>
    </body>
</html>