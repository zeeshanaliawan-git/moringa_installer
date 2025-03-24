<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape,java.util.List, java.util.ArrayList, java.util.HashSet, java.io.File, java.util.HashMap, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>
<%


    String siteId = getSelectedSiteId(session);

    String isProdParam = parseNull(request.getParameter("isProd"));
    boolean isProd = "1".equals(isProdParam);

    String dbname = "";
    String titlePrefix = "Test Site";

    if(isProd){
        dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
        titlePrefix = "Prod Site";
    }

    String q = null;
    Set rs = null;

    String cid = parseNull(request.getParameter("cid"));

    Set rsCat = Etn.execute("SELECT id, name, catalog_type  FROM "+dbname+"catalogs "
                            + " WHERE site_id = " + escape.cote(siteId)
                            + " AND catalog_type != 'offer' "
                            + " ORDER BY name ");

    Map<String,String> catalogMap = new LinkedHashMap<String, String>(rsCat.rs.Rows+1);
    catalogMap.put("","-- catalog --");
    while(rsCat.next()){
        catalogMap.put(rsCat.value("id"), rsCat.value("name"));
    }

    String backto = isProd ? "prodcatalogs.jsp": "catalogs.jsp";
%>
<!DOCTYPE html>

<html>
<head>
    <title>Stocks - <%=titlePrefix%></title>

    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<style type="text/css">

</style>

</head>

<%

breadcrumbs.add(new String[]{"Marketing", ""});
breadcrumbs.add(new String[]{titlePrefix, ""});
breadcrumbs.add(new String[]{"Stocks", ""});
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
    <!-- title -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
        <div>
            <h1 class="h2">Stocks - <%=titlePrefix%></h1>
        </div>
        <!-- buttons bar -->
        <div class="btn-toolbar mb-2 mb-md-0">
            <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('<%=titlePrefix%>'==='Test Site'?'Stocks test':'Stocks prod');" title="Add to shortcuts">
                <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
            </button>
        </div>
        <!-- /buttons bar -->
    </div><!-- /d-flex -->
    
    <div class="">
        <form name='mainForm' id='mainForm' method="POST" onsubmit="return false;" >
            <input type="hidden" name="isProd" id="isProd" value='<%=isProd?"1":""%>'>
            <div class="form-group row">
                <label  class="col-form-label">Catalog</label>
                <div class="col-sm-3">
                    <%=addSelectControl("cid","cid",catalogMap, cid, "custom-select", "onchange='refreshStocksTable()'")%>
                </div>
                <button type="button" class="btn btn-primary" onclick="exportToCSV()" title="export stock to CSV">
                    EXPORT CSV
                </button>
            </div>
        </form>
    </div>
    
    <!-- /title -->


    <!-- container -->
    <div class="animated fadeIn">
        <div id='errmsg' class="alert alert-danger" role="alert" style="display:none"></div>
        <div id='successmsg' role='alert' class='alert alert-success m-t-10' style="display:none"></div>
        <div>
            <form name='frm' id='frm' method="GET" onsubmit="return false;" >
                <table id="stocksTable" class="table table-hover border table-vam m-t-20 " >
                    <thead class="thead-dark">
                        <th >ID</th>
                        <th >Product</th>
                        <th >Variant Stock</th>
                        <th >SKU</th>
                        <th >Min Stock Thresh</th>
                        <th >Total Stock</th>
                        <th >Last changes</th>
                        <th >Last changes by</th>
                        <th>Actions</th>
                    </thead>
                    <tbody>
                        <!-- loaded by ajax -->
                    </tbody>
                </table>
                <div id="actionsCellTemplate" class="d-none" >
                    <button class="btn btn-sm btn-primary " title="Edit"
                        onclick="editProductStock('#ID#', '#NAME#')">
                        <i data-feather="edit"></i></a>
                </div>
                <ol id="variantStockTemplate" class="d-none" >
                    <li class="list-group-item p-0" style="background: inherit;">
                        <div class="d-flex py-1">
                            <div class="d-flex flex-grow-1" >
                                #VARIANT_INFO#
							</div>
                            <div class="flex-grow-0 m-auto" >#STOCK#</div>
                        </div>
                    </li>
                </ol>
                <div id="variantStockFieldTemplate" class="d-none">
                    <div class="form-group row">
                        <input type="hidden" name="variant_id" value="#ID#">
                        <label class="col-4 col-form-label">
							<div class="row">
								#VARIANT_INFO#
							</div>
						</label>
                        <div class="col">
                            <div class="input-group">
                                <span class="input-group-prepend">
                                    <button type="button" class="btn btn-primary" onclick="addToStock('#ID#',-1)">-</button>
                                </span>
                                <input type="text" class="form-control" name="stock_value" id="stock_value_#ID#" value="#STOCK#" onkeyup="allowNumberOnly(this)" >
                                <span class="input-group-append">
                                    <button type="button" class="btn btn-primary" onclick="addToStock('#ID#',+1)">+</button>
                                </span>
                            </div>
                        </div>
                        <div class="col">
                            <div class="input-group">
                                <span class="input-group-prepend">
                                    <button type="button" class="btn btn-primary" onclick="addToStock('#ID#',-1,true)">-</button>
                                </span>
                                <input type="text" class="form-control" name="minimum_stock_thresh" id="minimum_stock_thresh_#ID#" value="#STOCK-THRESH#" onkeyup="allowNumberOnly(this)" >
                                <span class="input-group-append">
                                    <button type="button" class="btn btn-primary" onclick="addToStock('#ID#',+1,true)">+</button>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    <div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>

    </div>
</main>

<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- c-body -->

<!-- Modals -->
<div class="modal fade" id="editProductStockModal" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
        <div class="modal-content">
            <form id="editProductStockForm" action="" novalidate>
                <input type="hidden" name="requestType" value="saveProductStock">
                <input type="hidden" name="isProd" value='<%=isProd?"1":""%>'>
                <input type="hidden" name="productId" value="">

                <div class="modal-header">
                    <h5 class="modal-title" id="">Edit stock : <span class="productName"></span></h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="container-fluid " >
                        <div class="row border-bottom border-light badge-secondary mb-2">
                            <div class="col-4 p-3"><strong>Variant name</strong></div>
                            <div class="col-4 p-3 text-center"><strong>Stock</strong></div>
                            <div class="col-4 p-3 text-center"><strong>Minimum Threshold</strong></div>
                        </div>
                        <div class="fieldContainer">
                            <!-- dynamic content -->
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="saveProductStock()" >Save</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->
<script type="text/javascript">
    $(document).ready(function() {

        initStocksTable();

    });

    function initStocksTable(){

        window.stocksTable = $('#stocksTable')
        .DataTable({
            responsive: true,
            pageLength : 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            language : {
                "emptyTable": "No products found"
            },
            ajax : function(data, callback, settings){
                getStockList(data,callback,settings);
            },
            order : [[1,'asc']],
            columns : [
                { "data": "id", className: "d-none", searchable: false },
                { "data": "name", className: "text-capitalize" },
                { "data": "variant_stock" },
                { "data": "sku" },
                { "data": "minimum_threshold", width: "30px"  },
                { "data": "total_stock", width: "30px" },
                { "data": "updated_on", width: "30px" },
                { "data": "updated_by", width: "40px" },
                { "data": "actions", className: "dt-body-right text-nowrap", width: "30px", searchable: false, orderable: false, responsivePriority: 6 },
            ],
            createdRow : function ( row, data, index ) {
                $(row).data('stock-data',data);
            },
        });
    }

    function refreshStocksTable(){
        window.stocksTable.ajax.reload(null,false);
    }

    function exportToCSV(){
        let catalogid = $('#cid').val();
        if(catalogid.length <= 0){
            alert("The selected catalog does not exist. Please choose a valid catalog and try again.");
            return;
        }

        $.ajax({
            url: 'productStocksAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : "exportStockList",
                catalogId : $('#cid').val(),
                isProd : $('#isProd').val(),
            },
        }).done(function(resp) {
            if(resp.status == 1)
                window.location.href= "<%=GlobalParm.getParm("PRODUCTS_IMG_PATH")%>" + resp.data.url;
            else
                BootNotifyError(resp.message);
        }).fail(function() {
            BootNotifyError("failed");
        })
        .always(function() {
            // hideLoader();
        });
    }

    function getStockList(data, callback, settings, requestType = "getStockList"){
        $.ajax({
            url: 'productStocksAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : requestType,
                catalogId : $('#cid').val(),
                isProd : $('#isProd').val(),
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                data = resp.data.stocks;
                var actionTemplate = $('#actionsCellTemplate').html();
                var variantStockTemplate = $('#variantStockTemplate').html();
                // var skuTemplate = $('#skuTemplate').html();
                $.each(data, function(index, val) {
                    var curId = val.id;
                    var total_stock = 0;

                    var variant_stock = "<ol class='list-group list-group-flush'>";
                    var skus ="<ol class='list-group list-group-flush'>";
                    var minStockThreshHtml = "<ol class='list-group list-group-flush'>";
                    $.each(val.variants,function(i,variant){
						var _vinfo = "";
                        var _skuinfo="";
                        var _minstockinfo="";

						if(variant.thumbnail != '')
						{
							_vinfo = `
                            <a href='${variant.image_path}' target='_blank' style="flex-basis:40px">
                                <img style='height:40px; width:40px' src='${variant.thumbnail}'>
                            </a>
                            <div  class="flex-grow-1 text-wrap px-2 m-auto" style="max-width:40ch">
                                ${variant.name}
                            </div>`;
						}
						else
						{
                            _vinfo = "<div>"+variant.name+"</div>"
						}

                        _minstockinfo = "<li class='list-group-item p-0 m-auto'>"+variant.minimum_threshold+"</li>";

                        _skuinfo = "<li class='list-group-item p-0' >"+variant.sku+"</li>";
						
                        var curVariantStock = strReplaceAll(variantStockTemplate, "#VARIANT_INFO#", _vinfo);
                        curVariantStock = strReplaceAll(curVariantStock, "#STOCK#", variant.stock);

                        minStockThreshHtml +=_minstockinfo;
                        skus +=_skuinfo; 
                        variant_stock += curVariantStock;
                        total_stock += parseInt(variant.stock);
						
                    });
                    val.minimum_threshold = minStockThreshHtml+"</ol>";
                    val.sku = skus +"</ol>";
                    val.variant_stock = variant_stock + "</ol>";
                    val.total_stock = total_stock;
                    val.actions = strReplaceAll(actionTemplate, "#ID#", curId);
					//if i change single qoute to &#39; still the code breaks on front end
                    val.actions = strReplaceAll(val.actions, "#NAME#", (val.name).replace("'", "\\'").replace("\"", "&#34;"));
					
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

    function editProductStock(productId, productName){
        showLoader();
        $.ajax({
            url: 'productStocksAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getProductStock',
                catalogId : $('#cid').val(),
                isProd : $('#isProd').val(),
                productId : productId
            },
        })
        .done(function(resp) {
            var data = [];
            console.log(resp);
            if(resp.status == 1){
                if(resp.data.variants.length > 0){
                    openEditStockModal(productId,productName, resp.data.variants);
                }
                else{
                    bootNotify("Product has no variants");
                }
            }
            else{
                if(resp.message.length > 0){
                    bootNotifyError(resp.message);
                }
            }
        })
        .fail(function() {
            bootNotifyError("Unable to contact server");
        })
        .always(function() {
            hideLoader();
        });
    }

    function openEditStockModal(productId, productName, variantsList){
        var modal = $('#editProductStockModal');

        modal.find('[name=productId]').val(productId);
        modal.find('.productName').text(productName);

        var fieldContainer  = modal.find('.fieldContainer');
        fieldContainer.html('');
        var variantStockFieldTemplate = $('#variantStockFieldTemplate').html();
        $.each(variantsList, function(index, variant) {
            var fieldHtml = variantStockFieldTemplate;
            fieldHtml = strReplaceAll(fieldHtml, "#ID#", variant.id);
			
			var _vinfo = "";
			if(variant.thumbnail != '')
			{
				_vinfo = "<div class='m-0 m-auto'><a href='"+variant.image_path+"' target='_blank'><img style='max-height:40px; max-width:40px' src='"+variant.thumbnail+"'></a></div><div class='col-8'>"+variant.name+"</div>";
			}
			else
			{
				_vinfo = "<div>"+variant.name+"</div>"
			}
			
            fieldHtml = strReplaceAll(fieldHtml, "#VARIANT_INFO#", _vinfo);
            fieldHtml = strReplaceAll(fieldHtml, "#STOCK#", variant.stock);
            fieldHtml = strReplaceAll(fieldHtml, "#STOCK-THRESH#", variant.minimum_threshold);

            fieldContainer.append(fieldHtml);
        });

        modal.modal('show');
    }

    function saveProductStock(){
        var modal = $('#editProductStockModal');
        var form = modal.find("form:first");

        showLoader();
        $.ajax({
            url: 'productStocksAjax.jsp', type: 'POST', dataType: 'json',
            data: form.serialize(),
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){
                bootNotify("Product stock updated");
                refreshStocksTable();
                modal.modal('hide');
            }
            else{
                hideLoader();
                if(resp.message.length > 0){
                    bootNotifyError(resp.message);
                }
            }
        })
        .fail(function() {
            bootNotifyError("Unable to contact server");
        })
        .always(function() {
            hideLoader();
        });

    }

    function addToStock(id, addValue,isthresh){
        let elementId = '#stock_value_'+id;
        if(isthresh!==undefined && isthresh == true) elementId = '#minimum_stock_thresh_'+id;
        var stockInp = $(elementId);

        if(stockInp.length != 1)return false;
        var stockVal = stockInp.val();
        try{
            stockVal = parseInt(stockVal.trim());
            if(isNaN(stockVal)){
                stockVal = 0;
            }
        }
        catch(ex){
            stockVal = 0;
        }

        stockVal = stockVal + addValue;
        stockInp.val( stockVal<0 ? 0 : stockVal);
    }

</script>

</body>
</html>

