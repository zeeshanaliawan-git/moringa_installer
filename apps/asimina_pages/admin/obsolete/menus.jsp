<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    String q = "";
	Set rs = null;

    List<Language> langsList = getLangs(Etn,getSiteId(session));

    String PROD_PORTAL_LINK = getProdPortalLink(Etn);

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title>Menus list</title>

    <style type="text/css">

    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- breadcrumb -->
            <%-- <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0">
                    <li class="breadcrumb-item"><a href='<%=GlobalParm.getParm("CATALOG_ROOT")%>/admin/gestion.jsp'>Home</a></li>
                    <li class="breadcrumb-item">Navigation</li>
                    <li class="breadcrumb-item">Menus</li>
                </ol>
            </nav> --%>
            <!-- /breadcrumb -->
            <!-- beginning of container -->
            <div class="row">
                <div class="col-12">
                    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                        <h1 class="h2">List of menus</h1>
                        <div class="btn-toolbar mb-2 mb-md-0">
                            <button type="button" class="btn btn-danger mr-2"
                            onclick="deleteSelectedMenus();">Delete</button>

                            <button type="button" class="btn btn-primary mr-2"
                            onclick="goBack('')">Back</button>

                            <button type="button" class="btn btn-primary mr-2"
                            onclick="refreshDataTable();" title="Refresh"><i data-feather="refresh-cw"></i></button>

                            <a class="btn btn-success" href="menuEditor.jsp" >Add a menu</a>
                        </div>
                    </div>
                </div>
            </div><!-- row -->

            <div class="row">
                <div class="col">
                    <table class="table table-hover table-vam" id="mainDataTable" style="width:100%;">
                        <thead class="thead-dark">
                            <tr>
                                <th scope="col">
                                    <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                                </th>
                                <th scope="col">Menu name</th>
                                <th scope="col">Language</th>
                                <th scope="col">Template</th>
                                <th scope="col">Last changes</th>
                                <th scope="col">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- loaded by ajax -->
                        </tbody>
                    </table>
                    <div id="actionsCellTemplate" class="d-none" >
                        <a class="btn btn-sm btn-primary " title="Edit"
                            href="menuEditor.jsp?id=#ID#">
                            <i data-feather="edit"></i></a>
                        <!-- TODO  copy menu -->
                        <button class="btn btn-sm btn-primary d-none" title="Copy"
                            onclick="copyMenu('#ID#')" disabled="">

                            <i data-feather="copy"></i></button>

                        <button class="btn btn-sm btn-danger deleteBtn" title="Delete"
                            onclick='deleteMenu("#ID#")' >
                            <i data-feather="trash-2"></i></button>
                    </div>
                </div>
            </div><!-- row-->
            <!-- container -->
            <!-- /end of container -->
        </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>

<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>/';
    // ready function
    $(function() {
        $('#mainDataTable tbody').tooltip({
            placement : 'bottom',
            html:true,
            selector:".custom-tooltip"
        });
    	initMainDataTable();

    });

    function initMainDataTable(){

    	window.mainDataTable = $('#mainDataTable')
        .DataTable({
            // dom : "<flipt>",
            // deferRender : true,
            responsive: true,
            pageLength : 100,
            ajax : function(data, callback, settings){
            	getMenusList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
            	{ "data": "id"   },
            	{ "data": "name", className : ""},
                { "data": "language" },
            	{ "data": "template_name" },
                { "data": "updated_ts" },
            	{ "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
            	{ targets : [-1] , searchable : false},
                { targets : [0,-1] , orderable : false},
                { targets : [0] ,
                    render: function ( data, type, row ) {
                        if(type == 'display'){
                            return '<input type="checkbox" class="idCheck d-none d-sm-block" name="menuId" onclick="onCheckItem(this)" value="'+data+'" >';
                        }
                        else{
                            return data;
                        }
                    }
                },
                { targets : [4] ,
                    render: function ( data, type, row ) {
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
                        }
                        else {
                            let updatedText = data,toolTipText="";
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
                $(row).data('menu-id',data.id);
            },
        });
    }

    function onCheckItem(check){
        check = $(check);
        var row = window.mainDataTable.row(check.parents('tr:first'));

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
            var allChecks = $(window.mainDataTable.table().body()).find('.idCheck');
        }
        else{
            //un select all
            var allChecks = window.mainDataTable.rows().nodes().to$().find('.idCheck');
        }

        allChecks.prop('checked',isChecked);

        allChecks.each(function(index, el) {
           $(el).triggerHandler('click');
        });

    }

    function getMenusList(data, callback, settings){
    	// showLoader();
    	$.ajax({
    		url: 'menusAjax.jsp', type: 'POST', dataType: 'json',
    		data: {
    			requestType : 'getList'
    		},
    	})
    	.done(function(resp) {
    		var data = [];
    		if(resp.status == 1){
    			data = resp.data.menus;
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

    function deleteMenu(id){
    	bootConfirm("Are you sure you want to delete this menu ?",
    		function(result){
    			if(!result) return;

    			var idsList = [id];
                deleteMenus(idsList);

    		});
    }

    function deleteSelectedMenus(){
        var rows = window.mainDataTable.rows( { selected: true } ).nodes().to$();

        if(rows.length == 0){
            bootNotify("No menu selected");
            return false;
        }

        var idsList = [];
        $.each(rows, function(index, row) {
            var curId = $(row).data('menu-id');
            idsList.push(curId);
        });

        var confirmMsg = ""+ idsList.length + " menus are selected. Are you sure you want to delete these menus? this action is not reversible.";

        bootConfirm(confirmMsg, function (result){
            if(result){
                deleteMenus(idsList);
            }
        });

    }

    function deleteMenus(idsList){
        if(idsList.length <= 0){
            return false;
        }

        //for multi value parameters to work
        var params = $.param({
            requestType : 'deleteMenus',
            ids : idsList
        },true);

        showLoader();
        $.ajax({
            url: 'menusAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function(resp) {
            if(resp.status != 1){
                bootAlert("<span class='text-danger'>"+resp.message+"</span>");
            }
            else{
                bootAlert(resp.message+" ");
            }
            refreshDataTable();
        })
        .always(function() {
            hideLoader();
        });

    }


    function refreshDataTable(){
        window.mainDataTable.ajax.reload(function(){
            $('#checkAll').triggerHandler('change');
        },false);
    }


</script>
    </body>
</html>