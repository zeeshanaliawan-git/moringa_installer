<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    String editId =  parseNull(request.getParameter("id"));
	Set rs = null;
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>RSS Feeds List</title>

        <style type="text/css">

        </style>
    </head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Content", ""});
        breadcrumbs.add(new String[]{"RSS feeds", ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->

                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">RSS feeds</h1>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <div class="btn-group mr-2">
                            <button type="button" class="btn btn-primary"
                                onclick="goBack('pages.jsp')">Back</button>
                        </div>
                        <button type="button" class="btn btn-primary mr-2"
                        onclick="refreshTable();" title="Refresh">
                            <i data-feather="refresh-cw"></i></button>
                        <div class="btn-group mr-2">
                            <button class="btn btn-danger" type="button"
                            onclick="setSelectedFeedsStatus(1)">Activate</button>
                            <button class="btn btn-danger" type="button"
                            onclick="setSelectedFeedsStatus(0)">Deactivate</button>
                        </div>
                        <button class="btn btn-success"
                            onclick="addRssFeed()">Add a feed</button>

                        <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('RSS feeds');" title="Add to shortcuts">
                            <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                        </button>
                    </div>
                </div>
                <div class="row">
                    <div class="col">
                        <table class="table table-hover table-vam" id="rssTable" style="width: 100%;">
                            <thead class="thead-dark">
                                <tr>
                                    <th scope="col">
                                        <input type="checkbox" class="" id="checkAll" onchange="onChangeCheckAll(this)">
                                    </th>
                                    <th scope="col">RSS feed</th>
                                    <th scope="col">Nb items</th>
                                    <th scope="col">Status</th>
                                    <th scope="col">Last Synced</th>
                                    <th scope="col">Last changes</th>
                                    <th scope="col" style="width:180px">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- loaded by ajax -->
                            </tbody>
                        </table>
                        <div id="actionsCellTemplate" class="d-none" >
                            <a class="btn btn-sm btn-primary " href="rssFeedItems.jsp?id=#ID#" >
                                <i data-feather="list"></i>
                            </a>
                            <button class="btn btn-sm btn-primary " type="button"
                                onclick="editRssFeed('#ID#')" >
                                <i data-feather="settings"></i>
                            </button>
                            <button class="btn btn-sm btn-danger " onclick="deleteRssFeed('#ID#')" >
                                <i data-feather="x"></i>
                            </button>
                        </div>
                    </div>
                </div><!-- row-->

            <!-- /end of container -->
        </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>


    <%@ include file="rssFeedsAddEdit.jsp"%>


<script type="text/javascript">

    // ready function
    $(function() {

        $('#rssTable tbody').tooltip({
            placement : 'bottom',
            html:true,
            selector:".custom-tooltip"
        });

    	initRssTable();
        var editId = '<%=editId%>';
        if(editId.length>0){
            editRssFeed(editId);
        }

    });

    function refreshTable(){
        window.rssTable.ajax.reload(null,false);
    }

    function initRssTable(){

    	window.rssTable = jQuery('#rssTable')
        .DataTable({
            responsive: true,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax : function(data, callback, settings){
            	getRssFeedsList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
            	{ "data": "id"},
                { "data": "name" },
            	{ "data": "nb_items"},
                { "data": "status"},
            	{ "data": "last_sync_ts" },
                { "data": "updated_ts" },
            	{ "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
            	{ targets : [0,6] , searchable : false},
            	{ targets : [0,6] , orderable : false},
				{ targets : [1], render: _hEscapeHtml},
                { targets : [0] ,
                    render: function ( data, type, row ) {
                        return '<input type="checkbox" class="idCheck d-none d-sm-block" name="feedId" value='+data+' >';

                    }
                },
                { targets : [4] ,
                    render: function ( data, type, row ) {
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
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
            ],
            createdRow : function ( row, data, index ) {
                $(row).data('rss-data',data);
                 let status ;
                 console.log(data);
                switch (data['status']) {
                    case 'active':
                        status='success'; break;
                    case 'in-active':
                        status='danger'; break;
                    default:
                        break;
                }
                $(row).addClass('table-' + status);
            },
            initComplete : function(){
                // $(this).find('.btn.btn-primary:first').trigger('click');
            }
        });
    }

    function getRssFeedsList(data, callback, settings){
    	// showLoader();
    	$.ajax({
    		url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
    		data: {
    			requestType : 'getRssFeedsList'
    		},
    	})
    	.done(function(resp) {
    		var data = [];
    		if(resp.status == 1){
    			data = resp.data.rssFeeds;
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

    function deleteRssFeed(feedId){

        bootConfirm("Are you sure ?", function(result){

            if(!result) return;

            showLoader();
            $.ajax({
                url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : 'deleteRssFeed',
                    id : feedId,
                },
            })
            .done(function(resp) {
                if(resp.status == 1){
                    bootNotify("Feed deleted.");
                }
                else{
                    bootNotify(resp.message, "danger");
                }
                refreshTable();
            })
            .fail(function() {
                alert("Error in accessing server. please try again.");
            })
            .always(function() {
                hideLoader();
            });

        });

    }

    function setSelectedFeedsStatus(isActive, confirmed){
        var selectedIds = $('[name=feedId]:checked');

        if(selectedIds.length === 0){
            bootNotify("No feed selected.");
            return false;
        }

        if(!confirmed){
            var confirmMsg = "Are you sure you want to ";
            confirmMsg += (isActive==1?"activated":"deactivate");
            confirmMsg += " " + selectedIds.length + " feed(s) ?";


            bootConfirm(confirmMsg, function(result){
                    if(result){
                        setSelectedFeedsStatus(isActive, true);
                    }
                });
            return false;
        }

        var idsList = [];
        selectedIds.each(function(index, el) {
            idsList.push($(el).val());
        });

        showLoader();
        $.ajax({
            url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'setFeedsStatus',
                status : isActive,
                ids : idsList.join(","),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                bootNotify("Feed(s) status updated.");
            }
            else{
                bootNotify(resp.message, "danger");
            }
            refreshTable();
        })
        .fail(function() {
            alert("Error in accessing server. please try again.");
        })
        .always(function() {
            hideLoader();
        });


    }

    function onChangeCheckAll(checkAll){
        $('.idCheck').prop('checked',$(checkAll).prop('checked'));
    }

</script>
    </body>
</html>