<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%

    String feedId = parseNull(request.getParameter("id"));

	String q = "";
    Set rs = null;

    q = "SELECT name FROM rss_feeds WHERE id = " + escape.cote(feedId)
        + " AND site_id = " + escape.cote(getSiteId(session));
    rs = Etn.execute(q);

    if(!rs.next()){
        response.sendRedirect("rssFeeds.jsp");
    }

    String feedName = rs.value("name");

%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>RSS Feed: <%=feedName%></title>

    </head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Content", ""});
        breadcrumbs.add(new String[]{"RSS feeds", "rssFeeds.jsp"});
        breadcrumbs.add(new String[]{feedName, ""});

    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->
            <form id="mainForm" action="" onsubmit="return false;">
                <input type="hidden" name="feedId" id="feedId" value="<%=feedId%>">
                <input type="hidden" name="feedName" id="feedName" value="<%=feedName%>">
            </form>
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">RSS feed: <%=feedName%></h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <div class="btn-group mr-2">
                        <button type="button" class="btn btn-primary"
                            onclick="goBack('rssFeeds.jsp')">Back</button>
                    </div>
                    <div class="btn-group mr-2" role="group" >
                        <button type="button" class="btn btn-primary "
                        onclick="editRssFeed('<%=feedId%>');" title="Edit Feed">
                            <i data-feather="settings"></i></button>
                        <button type="button" class="btn btn-primary "
                        onclick="importRssFeed('<%=feedId%>');" title="Refresh">
                            <i data-feather="refresh-cw"></i></button>
                    </div>
                    <div class="btn-group ">
                        <button class="btn btn-danger" type="button"
                        onclick="setSelectedFeedItemsStatus(1)">Activate</button>
                        <button class="btn btn-danger" type="button"
                        onclick="setSelectedFeedItemsStatus(0)">Deactivate</button>
                    </div>

                </div>
            </div>
            <!-- row -->
            <table class="table table-hover table-vam" id="itemsTable" style="width: 100%;">
                <thead class="thead-dark">
                    <tr>
                        <th scope="col">
                            <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                        </th>
                        <th scope="col">Title</th>
                        <th scope="col">Link</th>
                        <th scope="col">Status</th>
                        <th scope="col">Last changes</th>
                        <th scope="col">Pub date</th>
                        <th scope="col" style="width:180px">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- loaded by ajax -->
                </tbody>
            </table>
            <div id="actionsCellTemplate" class="d-none" >
                <button class="btn btn-sm btn-primary " type="button"
                    onclick="viewFeedItem('#ID#')" >
                    <i data-feather="eye"></i>
                </button>
                <button class="btn btn-sm btn-danger " onclick="deleteFeedItem('#ID#')" >
                    <i data-feather="x"></i>
                </button>
            </div>
            <!-- row-->
            <!-- /end of container -->
        </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>
    <%@ include file="rssFeedsAddEdit.jsp"%>

    <div class="modal fade" id="modalViewFeedItem" tabindex="-1" role="dialog" data-backdrop="static" >
        <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
            <div class="modal-content">
                <form id="formViewFeedItem" action="" novalidate onsubmit="return false;" >
                    <input type="hidden" name="requestType" value="saveRssFeed">
                    <input type="hidden" name="id" value="">

                <div class="modal-header">
                    <h5 class="modal-title"></h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="errorMsg small text-danger"></div>
                        <div class="card mb-2">
                            <div class="card-header bg-secondary" data-toggle="collapse" href="#itemInfoCollapse" role="button" 
                            aria-expanded="true" aria-controls="itemInfoCollapse">
                                <strong>Item information</strong>
                            </div>
                            <div class="collapse show pt-3" id="itemInfoCollapse">
                                <div class="card-body" id="itemInfoCollapseCarBody"></div>
                            </div><!--  collapse -->
                        </div>
                        <div class="d-none">
                            <div class="form-group row" id="itemFieldTemplate">
                                <label class="col col-form-label text-capitalize fieldLabel"></label>
                                <div class="col-9">
                                    <input type="text" class="form-control" value="" readonly="readonly" style="display:none;">
                                    <textarea  class="form-control" readonly="readonly" style="display: none;"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                </form>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->


<script type="text/javascript">

    $(function() {
    	initItemsTable();
    });

    function refreshTable(){
        window.itemsTable.ajax.reload(null,false);
    }

    function initItemsTable(){

    	window.itemsTable = jQuery('#itemsTable')
        .DataTable({
            responsive: true,
            pageLength : 100,
            ajax : function(data, callback, settings){
            	getRssFeedItemsList(data,callback,settings);
            },
            order : [[5,'desc']],
            columns : [
            	{ "data": "id" },
                { "data": "title" },
            	{ "data": "link"},
                { "data": "status"},
                { "data": "updated_ts" },
                { "data": "pubdate_std" },
            	{ "data": "actions", className : "dt-body-right text-nowrap" },
            ],
            columnDefs : [
            	{ targets : [0,6] , searchable : false},
            	{ targets : [0,6] , orderable : false},
                { targets : [0] ,
                    render: function ( data, type, row ) {
                        return '<input type="checkbox" class="idCheck d-none d-sm-block" name="itemId" value='+data+' >';

                    }
                },
                 { targets : [2] ,
                    render: function ( data, type, row ) {
                       return '<strong>'+ data +'</strong>';

                    }
                },
                { targets : [4,5] ,
                    render: function ( data, type, row ) {
                        if(type == 'sort' && data.trim().length > 0){
                            return getMoment(data).unix();
                        }
                        else {
                            return data;
                        }

                    }
                },
            ],
            createdRow : function ( row, data, index ) {
                $(row).data('item-data',data);
                var color = data['status']=='active' ? "published" : "unpublished";

                $(row).addClass('table-'+(color==='published'?'success':'danger'));
            },
            initComplete : function(){
                // $(this).find('.btn.btn-primary:first').trigger('click');
            }
        });
    }

    function getRssFeedItemsList(data, callback, settings){
    	// showLoader();
    	$.ajax({
    		url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
    		data: {
    			requestType : 'getRssFeedItemsList',
                id : $('#feedId').val()
    		},
    	})
    	.done(function(resp) {
    		var data = [];
    		if(resp.status == 1){
    			data = resp.data.items;
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

    function viewFeedItem(itemId){
        showLoader();
        $.ajax({
            url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getItemInfo',
                id : itemId,
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                var item = resp.data.item;

                var itemFields = ['title','link','description','guid',
                    'enclosure_url','enclosure_type','enclosure_length',
                    'pubDate','category','author','comments','source',
                    'source_url','updated_ts','created_ts'];

                var itemFieldTemplate = $('#itemFieldTemplate').clone().attr('id',null);
                var itemInfoCollapse = $('#itemInfoCollapseCarBody');
                itemInfoCollapse.html('');
                $.each(itemFields, function(index, fieldName) {

                    var fieldVal = item[fieldName];
                    if(typeof fieldVal == 'undefined'){
                        fieldVal = '';
                    }

                    var fieldDiv = itemFieldTemplate.clone();
                    fieldDiv.find('.fieldLabel').html(strReplaceAll(fieldName,"_"," "));
                    if(fieldName == "description"){
                        fieldDiv.find('textarea').val(fieldVal).show();
                    }
                    else{
                        fieldDiv.find('input').val(fieldVal).show();
                    }
                    itemInfoCollapse.append(fieldDiv);

                });

                $.each(item, function(fieldName, fieldVal) {
                    if(itemFields.indexOf(fieldName) < 0){
                        var fieldDiv = itemFieldTemplate.clone();
                        fieldDiv.find('.fieldLabel').html(strReplaceAll(fieldName,"_"," "));
                        if(fieldVal.length > 100){
                            fieldDiv.find('textarea').val(fieldVal).show();
                        }
                        else{
                            fieldDiv.find('input').val(fieldVal).show();
                        }
                        itemInfoCollapse.append(fieldDiv);
                    }

                });

                $('#modalViewFeedItem').modal('show');
            }
            else{
                bootNotify(resp.message, "danger");
            }
        })
        .fail(function() {
            bootNotify("Error in accessing server. please try again.","danger");
        })
        .always(function() {
            hideLoader();
        });
    }

    function deleteFeedItem(itemId){

        bootConfirm("Are you sure ?", function(result){

            if(!result) return;

            showLoader();
            $.ajax({
                url: 'rssFeedsAjax.jsp', type: 'POST', dataType: 'json',
                data: {
                    requestType : 'deleteFeedItem',
                    id : itemId,
                },
            })
            .done(function(resp) {
                if(resp.status == 1){
                    bootNotify("Item deleted.");
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

    function setSelectedFeedItemsStatus(isActive, confirmed){
        var selectedIds = $('[name=itemId]:checked');

        if(selectedIds.length === 0){
            bootNotify("No item selected.");
            return false;
        }

        if(!confirmed){
            var confirmMsg = "Are you sure you want to ";
            confirmMsg += (isActive==1?"activated":"deactivate");
            confirmMsg += " " + selectedIds.length + " item(s) ?";


            bootConfirm(confirmMsg, function(result){
                    if(result){
                        setSelectedFeedItemsStatus(isActive, true);
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
                requestType : 'setFeedItemsStatus',
                status : isActive,
                ids : idsList.join(","),
                feedId : $('#feedId').val(),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                bootNotify("Item(s) status updated.");
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