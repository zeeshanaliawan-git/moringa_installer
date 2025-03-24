\<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.asimina.util.ActivityLog, com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.List, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>


<%!
    void getFolders(com.etn.beans.Contexte Etn, String siteid, String folderid, Map<String, String> listOfFolders)
	{
		Set rs = Etn.execute("Select * from products_folders where site_id = "+escape.cote(siteid)+" and id = "+escape.cote(folderid));
		if(rs.next())
		{
			getFolders(Etn, siteid, rs.value("parent_folder_id"), listOfFolders);
			listOfFolders.put(rs.value("uuid"), rs.value("name"));
		}
	}

%>

<%
    String dbname = "";
	String selectedsiteid = getSelectedSiteId(session);
    String errmsg = "";
    boolean taxParamsDifferent = false;
	String cid = parseNull(request.getParameter("cid"));
	String folderUuid = parseNull(request.getParameter("folderId"));
    String folderId = "0";
    int folderLevel = 0;
    String parentFolderId = "";
    String[] catStatusArr={};
    String catalogPublishStatus="";
    String catalogVersion="";
    String catalogType="";

    

    Set rscat = Etn.execute("select * from catalogs where id = " + escape.cote(cid));

    if(cid.length()>0){
        rscat.next();
        catalogType = parseNull(rscat.value("catalog_type"));
        catalogVersion = parseNull(rscat.value("version"));
        taxParamsDifferent = "1".equals(parseNull(rscat.value("price_tax_included")));
        catStatusArr = getCatalogPublishStatus(Etn, cid, catalogVersion);
        catalogPublishStatus = catStatusArr[0];
    }

    if (folderUuid.length() > 0) {
        String q = "SELECT f.id, f.uuid, f.folder_level, IFNULL(pf.uuid,'') AS parent_folder_id "
            + " FROM products_folders f "
            + " LEFT JOIN products_folders pf ON pf.id = f.parent_folder_id "
            + " WHERE f.uuid = " + escape.cote(folderUuid)
            + " AND f.site_id = " + escape.cote(selectedsiteid);
        Set rs = Etn.execute(q);
        if (rs.next()) {
            folderId = rs.value("id");
            folderLevel = parseInt(rs.value("folder_level"));
            parentFolderId = parseNull(rs.value("parent_folder_id"));
        }
        else {
            response.sendRedirect("products.jsp?cid="+cid);
        }
    }
    Map<String, String> listOfFolders = new LinkedHashMap<String, String>();
	listOfFolders.put("", rscat.value("name"));
	getFolders(Etn, rscat.value("site_id"), folderId, listOfFolders);

    String backto = "";


    if(cid.length()>0 && folderUuid.length() == 0){
        backto = "catalogs.jsp";
    }
    else if(cid.length()>0 && folderUuid.length()>0){
        backto = "catalogs.jsp?cid="+cid;
        if(parentFolderId.length()>0)
            backto = backto+"&folderId="+parentFolderId;
    }

%>

<!DOCTYPE html>

<html>
<head>
	<title>Products</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

	<%
	String lastFolderName = "";
	for(String fuuid : listOfFolders.keySet())
	{
		lastFolderName = listOfFolders.get(fuuid);
	}
	breadcrumbs.add(new String[]{"Content", ""});
	breadcrumbs.add(new String[]{"Products", "catalogs.jsp"});
	for(String fuuid : listOfFolders.keySet())
	{
		if(folderUuid.equals(fuuid) == false)
		{
			breadcrumbs.add(new String[]{escapeCoteValue(listOfFolders.get(fuuid)), "catalogs.jsp?cid="+cid+"&folderId="+fuuid});
		}
		else
		{
			breadcrumbs.add(new String[]{escapeCoteValue(listOfFolders.get(fuuid)), ""});
		}
	}
	%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
		<div>
			<h1 class="h2">Products</h1>
			<p class="lead"></p>
		</div>
        

        <% if(cid.length()>0 ){ %>
            <div class="btn-toolbar mb-2 mb-md-0" >
                <div class="btn-group mr-2 mt-1 product_btn" role="group" aria-label="...">
                    <button type="button" class="btn btn-danger" onclick="onpublish('multi')">Publish</button>
                    <button type="button" class="btn btn-danger" onclick="onpublish('multidelete')">Unpublish</button>
                    <button type="button" class="btn btn-danger" onclick='onpublishorder()' id='publishtoprodorderbtn'>Publish order</button>
                </div>
                <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                    <button type="button" class="btn  btn-primary" onclick='javascript:window.location="<%=backto%>";'>Back</button>
                    <button type="button" class="btn btn-primary product_btn" onclick='onsave(this,<%=cid%>)'>Save</button>
                    <% if( !catalogPublishStatus.equals("unpublished") && !catalogType.equals("offer") && ___sbIsEnabled ) { //___sbIsEnabled is defined in web-inf/include/header.jsp %>
                    <button type="button" class="btn  btn-primary product_btn" onclick='javascript:window.location="prodproductStocks.jsp?cid=<%=cid%>";'>Stock</button>
                    <% } %>
                </div>
                <div class="btn-group mr-2 mt-1" >
                    <button type="button" class="btn btn-success" onclick="openMoveToModal()">Move To</button>
                </div>
                <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                    <div class="btn-group" role="group">
                        <button type="button" class="btn btn-success" id="addFolderBtn"
                            onclick='openFolderModal()'<% if (folderLevel == 3) {%> disabled <%}%>  >Add a folder
                        </button>
                        <%
                          String productUrl = "product.jsp?cid="+cid+"&folderId="+folderUuid;
                        %>
                        <button type="button" class="btn btn-success" onclick='window.location="<%=productUrl%>";'>Add a product</button>
                        <% if("device".equalsIgnoreCase(catalogType)){%>
                                <button type="button" class="btn btn-success" id='importdevicebtn'>Import a new device</button>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
        }else {   %>
                        
		<!-- buttons bar -->
		<div class="btn-toolbar mb-2 mb-md-0">
			 <div class="btn-group mr-2" role="group" aria-label="...">
				<button type="button" class="btn btn-danger" onclick='onpublishUnpublish("publish")' id='publishtoprodbtn'> <% if(folderUuid.length() > 0){%> disabled <%}%> Publish</button>
				<button type="button" class="btn btn-danger" onclick='onpublishUnpublish("unpublish")' id='unpublishtoprodbtn'>Unpublish</button>
			</div>
			<div class="btn-group mr-2" role="group" aria-label="...">
				<button type="button" class="btn btn-success" id="addFolderBtn"
						onclick='javascript:window.location="catalog.jsp";' >Add a Catalog
				</button>
			</div>
			<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Products');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>
		</div>
        <%}%>
		<!-- /buttons bar -->
	</div><!-- /d-flex -->
	<!-- /title -->

	<!-- container -->
	<div class="">
	<div class="animated fadeIn">
	<div>
        <input type="hidden" id="catalogId" name="" value="<%=cid%>"/>
        <input type="hidden" id="folderUuid" name="" value="<%=folderUuid%>"/>
        <input type="hidden" id="folderId" name="" value="<%=folderId%>"/>
        <input type="hidden" id="folderLevel" name="" value="<%=folderLevel%>"/>
        <div id="catalogs-list" >
		</div>
        <div id="show-alert"></div>
            <%  if(taxParamsDifferent){ %>

            <div id="tax-param" class="alert alert-warning" role="alert">Price tax included and/or Show prices with tax configuration is different among the folders defined. This will lead to errors in tax calculations. These two flags must be same across all folders.</div> 
            <%}%>
        <div class="row">
        <div class="col">
		<table class="table table-hover table-vam" id="resultsdata" style="width:100%;">
			<thead class="thead-dark">
            <tr>
                <th scope="col">
                    <input type="checkbox" class="d-none d-sm-block" id="checkAll" onchange="onChangeCheckAll(this)">
                </th>
                <%if(cid.length()>0){%>
                    <th scope="col">Order</th>
                <%}%>
                <th scope="col">&nbsp;<!--type icon --></th>
                <th scope="col">Name</th>
                <th scope="col">Type</th>
                <th scope="col">Nb Items</th>
                <th scope="col">Last changes</th>
                <th scope="col">Actions</th>
            </tr>
			</thead>
		</table>
    </div>
	</div>
	<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	</div>
	<br>
</main>
<div class="modal fade" id="copyProductModal" tabindex="-1" role="dialog" >
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <form id="copyProductForm" action="" novalidate="">
                <input type="hidden" name="requestType" value="copyProduct">
                <input type="hidden" name="productId" value="">

                <div class="modal-header">
                    <h5 class="modal-title" id="">Copy product</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="container-fluid">

                        <div class="form-group row">
                            <label class="col col-form-label">New product name</label>
                            <div class="col-8">
                                <input type="text" name="productNewName" class="form-control" value=""
                                required="required" maxlength="100" >
                                <div class="invalid-feedback">
                                    Cannot be empty.
                                </div>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label class="col">Copy images ?</label>
                            <div class="col-8 form-check">
                                <input type="checkbox" class="form-check-input mx-0 my-1" name="copyImages" value="1">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="copyProductSubmit()" >Submit</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<!-- move to modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='moveToDlg' >
    <div class="modal-dialog modal-md" role="document">
        <div class="modal-content">
            <div class="modal-header" style='text-align:left'>
                <h5 class="modal-title">Move selected Products</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">&times;</span>
                    </button>
            </div>
            <div class="modal-body">
                <div>
                    <div class="row">
                        <div class="form-group col-sm-12">
                            <select name="folder" class="custom-select" id="productsFoldersSelect">
                                <option value="">-- list of folders --</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group  col-sm-3">
                            <button type="button" class="btn btn-success" onclick="moveSelectedProducts()">Submit</button>
                        </div>
                    </div>
                </div>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>

<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'></div>

<div class="modal fade" tabindex="-1" role="dialog" id='importdlg' >
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header" style='text-align:left'>
                <h5 class="modal-title">Import Devices</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                      <span aria-hidden="true">&times;</span>
                    </button>
            </div>
            <div class="modal-body">
                <div id="impDlgLoader"><img src="<%=request.getContextPath()%>/img/loader.gif" /></div>
                <div>
                    <div id='impDlgAlert' class="alert alert-danger" role="alert" style='display:none'>
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span class="m-l-10">You must provide brand and/or model to short list the devices</span>
                    </div>
                    <div id='impDlgAlert2' class="alert alert-danger" role="alert" style='display:none'>
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span class="m-l-10">Some error occurred while fetching devices</span>
                    </div>
                    <div id='impDlgAlert3' class="alert alert-danger" role="alert" style='display:none'>
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span class="m-l-10">No devices found for the given criteria</span>
                    </div>
                    <div id='impDlgAlert4' class="alert alert-success" role="alert" style='display:none'>
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><span class="m-l-10">Device imported</span>
                    </div>
                    <div class="row">
                        <div class="form-group col-sm-6">
                            <input placeholder="Brand" class="form-control" type="text" id="impDlgBrand"/>
                        </div>
                        <div class="form-group col-sm-6">
                            <input placeholder="Model" class="form-control" type="text" id="impDlgModel"/>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col-sm-6">
                            <select class="form-control" id="impDlgDType">
                                <option value="">-- Device Type --</option>
                                <option value="Connected Object">Connected Object</option>
                                <option value="datacard">Datacard</option>
                                <option value="mobile">Mobile</option>
                                <option value="tablet">Tablet</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group  col-sm-3">
                            <button type="button" class="btn btn-success" onclick="searchDevices()">Search</button>
                        </div>
                    </div>
                </div>
                <div style='display:none; margin-top:10px; margin-bottom:10px;' id='requestDeviceDiv'>
                    <div>Cannot find your device? <button type="button" class="btn btn-light" onclick="addNewRequest()">Request for new device</button></div>
                </div>
                <div style="border-top: 1px solid #e9ecef">
                    <div id='impDlgResults' style='display:none; margin-top:10px'>
                        <table id='impDlgDevicesTbl' class='table table-hover table-vam m-t-20'>
                        <thead class='thead-dark'>
                        <th>Image</th>
                        <th>Brand</th>
                        <th>Model</th>
                        <th>Last changes</th>
                        <th>&nbsp;</th>
                        </thead>
                        <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>

<%@ include file="../prodpublishloginmultiselect.jsp"%>
<%@ include file="foldersAddEdit.jsp" %>
<%@ include file="/WEB-INF/include/footer.jsp" %>

</div>

<%-- ----------------------------  Catalog Scripts ---------------------------- --%>
<script>
var orderingchanged = false;
var requestType = "getCommercialProducts";
var MEDIA_IMAGE_URL_PREFIX = '<%=GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + selectedsiteid + "/img/"%>';
	jQuery(document).ready(function()
	{

        $(".product_btn").hide();
        $('#resultsdata tbody').tooltip({
            placement: 'bottom',
            html: true,
            selector: ".custom-tooltip"
        });

        initDataTable();
        
        $('.custom-tooltip').tooltip({
	        placement : 'bottom',
	        trigger: 'manual',
	        html:true,
	        animation:false
	    }).on("mouseenter", function () {
		        var _this = this;
		        $(this).tooltip("show");
		        $(".tooltip").on("mouseleave", function () {
		            $(_this).tooltip('hide');
		        });
		    }).on("mouseleave", function () {
		        var _this = this;
		        setTimeout(function () {
		            if (!$(".tooltip:hover").length) {
		                $(_this).tooltip("hide");
		            }
		        }, 300);
		});

		// var orderingchanged = false;
		// $(".order_seq").change(function(){
		// 	orderingchanged = true;
		// });

		$("#sltall").click(function()
		{
			if($(this).is(":checked"))
			{
				$(".slt_option").each(function(){$(this).prop("checked",true)});
			}
			else
			{
				$(".slt_option").each(function(){$(this).prop("checked",false)});
			}
		});

		$(".slt_option").click(function()
		{
			$("#sltall").prop("checked",false);
		});

        $('#checkAll').prop('checked', false);

		$('.custom-tooltip').tooltip({
            placement : 'bottom',
            trigger: 'manual',
            html:true,
            animation:false
        }).on("mouseenter", function () {
                var _this = this;
                $(this).tooltip("show");
                $(".tooltip").on("mouseleave", function () {
                    $(_this).tooltip('hide');
                });
            }).on("mouseleave", function () {
                var _this = this;
                setTimeout(function () {
                    if (!$(".tooltip:hover").length) {
                        $(_this).tooltip("hide");
                    }
                }, 300);
        });

        <%if(errmsg.length() > 0) {%>
            $("#errmsg").html("<%=errmsg%>");
            $("#errmsg").show();
        <%}%>

        impDlgDataTable = $('#impDlgDevicesTbl').DataTable({
            "responsive": true,
            "columnDefs": [
                { "orderable": false, "targets": [0,4] },
                { "searchable": false, "targets": [0,3,4] }
            ]
        });

        $("#importdevicebtn").click(function(){
            //reset everything before opening
            $("#impDlgAlert").hide();
            $("#impDlgAlert2").hide();
            $("#impDlgAlert3").hide();
            $("#impDlgAlert4").hide();

            $("#impDlgModel").val("");
            $("#impDlgBrand").val("");
            $("#impDlgDType").val("");
            impDlgDataTable.clear();
            $("#impDlgResults").hide();
            $("#requestDeviceDiv").hide();
			$("#impDlgLoader").hide();
            $("#importdlg").modal("show");
        });

        
        <%/*if(editId.length()>0){ %>
            editFolder('<%=editId%>');
        <%}*/%>
        var productRows = resultsdata.rows(".row_product").nodes().to$();
        $("tbody").addClass("sortable");

        setRowOrder = function(){

            $('#resultsdata tbody tr').each(function(i,tr){
                $(tr).find('.order_seq_sort').val($(tr).find('.order_seq').val());
                $(tr).find('.order_seq')
                .val(i+1);
            });
        };

            setTimeout(function() {
                if (document.querySelector('#resultsdata tbody.sortable .product')) {
                    Sortable.create(document.querySelector('#resultsdata tbody.sortable'), {
                        handle: '.product', 
                        direction: 'vertical',
                        scroll: true,
                        scrollSensitivity: 100,
                        scrollSpeed: 30,
                        forcePlaceholderSize: true,
                        animation: 50,
                        onUpdate: function(event) {
                            setRowOrder();
                            orderingchanged = true;
                        }
                    });
                }
            }, 1000);


            $('#resultsdata tbody tr input.order_seq')
			.keyup(onKeyOrderSeq)
			.blur(setRowOrder);

		    setRowOrder();
        
	});

    function onpublishUnpublish(publishType)
    {
        if ($(".slt_option:checked").length > 0)
        {
            var catalogids = "";
            var productids = "";
            var doPublish = true;
            $(".slt_option").each(function(){
                if($(this).is(":checked") == true) 
                    if($(this).data("type") === "catalog") 
                        catalogids += $(this).val() + ",";
                    else if($(this).data("type") === "product") 
                        productids += $(this).val() + ",";
                    else
                    {
                        bootNotifyError("Unselect product folder");
                        doPublish = false;
                        return;
                    }
            });
            

            if(doPublish)
            if(publishType == "publish"){
                
                if(catalogids.length>0)
                    onbtnclickpublish(catalogids, "catalog", "multi");
                if(productids.length>0)
                    onbtnclickpublish(productids, "product", "multi");
            }           
            if(publishType == "unpublish"){
                if(catalogids.length>0)
                    onbtnclickpublish(catalogids, "catalog", "multidelete");
                if(productids.length>0)
                    onbtnclickpublish(productids, "product", "multidelete");
            }
        }
        else
        {
            bootNotify("No catalog selected");
        }
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


    function getCommercialProducts(data, callback, settings){
        let search = $('#customSearch').val();
        if(search!==undefined && search.length>1)  requestType ="searchCommercialProduct";
        else if('<%= cid %>'.length > 0) requestType = "getProducts";
        else requestType="getCommercialProducts";
            $.ajax({
                url:'ajax/commercialProductsAjax.jsp',
                data: {
                    requestType: requestType,
                    folderId: '<%= folderUuid %>',
                    catalogId: '<%= cid %>',
                    searchText: $('#customSearch').val(),
                    delete_id: window.resultsdata.delete_id,
                    delete_id_type: window.resultsdata.delete_id_type,
                    delete_product_name: window.resultsdata.delete_product_name,
                }
            })  
        .done(function (resp){
            window.resultsdata.delete_id='';
            window.resultsdata.delete_id_type='';
            window.resultsdata.delete_product_name='';
            isSearch = false;
            data = resp.data;
            if(resp.status ==1 || resp.errmsg == undefined ){
                $('#show-alert').addClass("d-none");
                 if (resp.message != undefined && resp.message != "")bootNotify(resp.message);
            }else{
                $('#show-alert').removeClass("d-none");
                $('#show-alert').html('<div class="alert alert-danger" role="alert">'+resp.errmsg+'</div>');
            }

            callback({"data": resp.data});
        })
        .fail(function(){
            callback({"data":data});
        })
        .always(function(){
        });
    }
    function onpublishorder()
    {
        var _continue = true;
        if(orderingchanged)
        {
            if(!confirm("Some changes are made in ordering which are not saved. Do you still want to continue publishing old ordering?")) _continue = false;
        }
        if(!_continue) return;

        if ($(".slt_option:checked").length > 0)
        {
            var ids = "";
            $(".slt_option").each(function(){
                if($(this).is(":checked") == true) ids += $(this).val() + ",";
            });
            onbtnclickpublish(ids, "catalog", "ordering");
        }
        else
        {
            bootNotify("No catalog selected");
        }
    };

    function refreshscreen()
    {
        window.location = window.location
    };

    function initDataTable(){
        var rowCounter = 0;
        window.resultsdata= jQuery('#resultsdata').DataTable({
            responsive: true,
            pageLength: 10,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            ajax: function (data, callback, settings){
                getCommercialProducts(data, callback, settings);
            },
            searching: false,
            lengthChange:true,
            columns: [
            {"data": "ID", className: "text-center"},
            <%if(cid.length()>0){%>
            {"data": "order_seq"},
            <%}%>
            {"data": "row_type"},
            {"data": "NAME", className: "name"},
            {"data": "TYPE"},
            {"data": "NB_ITEMS", className: "text-center"},
            {"data": "updated_ts",className: "text-nowrap"},
            {"data": "actions", className: "text-right text-nowrap"},
        ],
        "columnDefs": [
            { "orderable": false, "targets": [0,<% if(cid.length()>0){ %>2,<% } %>-1] },
            <%int counter = 0;%>
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    var dataType = row.isCatalog ? 'catalog' : (row.TYPE == 'product') ? 'product' : 'folder';
                    return '<input type="checkbox" class="slt_option d-none d-sm-block" data-type="' + dataType + '" value="' + row.ID + '">';
                }
            },
             <%
                if (cid.length() > 0) {
                %>
                {
                    targets: [parseInt('<%=counter++ %>')],
                    render: function (data, type, row) {
                         
                        // Increment counter for the next row
                        
                        if(row.ICON !== 'folder'){
                        var nextCounter = ++rowCounter;
                        return '<td align="center">' +
                                '<input type="text" size="2" maxlength="6" name="order_seq" class="order_seq form-control" value="' + nextCounter + '"/>' +
                                '<input type="hidden" size="2" maxlength="6" name="order_seq_sort" class="order_seq_sort form-control" value="' + nextCounter + '"/>' +
                            '</td>';
                        }
                        else{
                            return '<td></td>';
                        }
                    }
                },
                <%
                }
                %>

            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    var html = "";
                    var cId;
                    cId = row.CATALOG_ID;
                    if(cId == undefined) cId = row.ID;
                    if (row.ICON == 'folder') {
                        if(row.path == undefined){
                                html = '<a href="catalogs.jsp?cid='+cId+'&folderId='+row.UUID+'" style="color:currentColor;">' +
                                feather.icons.folder.toSvg({class: 'feather-20', fill: '#aaa', style: 'height: 20px; width: 20px;'}) +
                            '</a>';
                        }else{
                            html = '<a href="catalogs.jsp?cid=' + cId + '&folderId=' + row.UUID + '" style="color:currentColor;" title="' + row.path + '">' +
                                feather.icons.folder.toSvg({class: 'feather-20', fill: '#aaa', style: 'height: 20px; width: 20px;'}) +
                                '</a>';

                            }
                    } else {
                        if (row.path == undefined){
                            html = '<img src="'+row.SRC+'" style="max-height:40px; max-width:40px">';
                        }
                        else
                        html = '<img src="' + row.SRC + '" style="max-height:40px; max-width:40px" title="' + row.path + '">';
                    }

                    return html;
                }
            },
           
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    return '<strong style="font-size: 14px; line-height: 21px;">'+_hEscapeHtml(data)+'</strong>';
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    return '<span style="font-size: 14px; line-height: 21px;">' + data + '</span>';
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    var CATALOG_ID = row.CATALOG_ID;
                    if (row.CATALOG_ID == null) CATALOG_ID = row.ID;

                    var folderIdParam = row.UUID ? '&folderId=' + row.UUID : '';

                    if (row.NB_ITEMS !== 0 && row.NB_ITEMS !== '-')
                        return '<a href="catalogs.jsp?cid=' + CATALOG_ID + folderIdParam + '" style="color:black"><span class="badge badge-secondary ">' + row.NB_ITEMS + '</span></a>';
                    else
                        return '<a href="catalogs.jsp?cid=' + CATALOG_ID + folderIdParam + '" style="color:black"></a>';
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    var tooltipContent = '';
                    var updatedDate = row.UPDATED_ON.split(' ')[0];
                    var updatedTime = row.UPDATED_ON.split(' ')[1];
                    var createdDate = row.CREATED_ON.split(' ')[0];
                    var createdTime = row.CREATED_ON.split(' ')[1];
                    
                    if (row.publishStatus[0] === "unpublished") {
                        tooltipContent = 'Last Change: ' + createdDate + '\n' + createdTime + ' by ' + row.UPDATED_BY;
                    } else {
                        tooltipContent = 'Last Change: ' + createdDate + '\n' + createdTime + ' by ' + row.UPDATED_BY + '\n' +
                                        'Last Publication: ' + updatedDate + '\n' + updatedTime + ' by ' +row.CREATED_BY;
                    }

                    
                    var content = '<span style="font-size: 14px; line-height: 21px;">' + updatedDate + ' ' + updatedTime + '</span>' + ' <a href="javascript:void(0)" class="custom-tooltip ml-1" data-toggle="tooltip" title="' + tooltipContent + '">' + feather.icons.info.toSvg() + '</a>';

                    return content;
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    let search_cid = row.CATALOG_ID;
                    if(search_cid == undefined) search_cid =row.ID;
                    let action = ""; 
                    if(row.ICON == "folder"  && row.publishStatus[0] == "unpublished" && row.isCatalog == false){
                            action ="<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='List of products' href='catalogs.jsp?cid="+search_cid+'&folderId='+row.UUID+"'>"+feather.icons.list.toSvg()+"</a><a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='Settings' onclick='editFolder(\""+row.ID+"\")'' style='color: white'>"+feather.icons.settings.toSvg()+"</a><a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' title='Copy folder'onclick='openCopyFolderModal(\""+row.ID+"\")'' style='color: white'>"+feather.icons.copy.toSvg()+"</a>";
                            action +="<a class='btn btn-danger btn-sm ml-1' title= 'Delete' onclick='ondelete(\""+row.ID+"\",\"folder\",\""+row.NAME+"\")' style='color: white'>"+feather.icons["trash-2"].toSvg()+"</a>";
                    
                        }
                    else if(row.ICON == "folder"  && row.publishStatus[0] == "unpublished" && row.isCatalog == true){
                            action ="<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='List of products of :"+row.NAME+" ' href='catalogs.jsp?cid="+row.ID+"'>"+feather.icons.list.toSvg()+"</a><a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='List of products of :"+row.NAME+" ' href='catalog.jsp?id="+search_cid+"'>"+feather.icons.settings.toSvg()+"</a>";
                            if(row.PHASE == "published" || row.PHASE == "changed") action +="<a class='btn btn-danger btn-sm ml-1' title= 'Unpublish' onclick='onbtnclickpublish(\""+row.ID+"\",\"catalog\",\"delete\")' style='color: white'>"+feather.icons["x"].toSvg()+"</a>";
                            else action +="<a class='btn btn-danger btn-sm ml-1' title= 'Delete' onclick='ondelete(\""+row.ID+"\",\"catalog\",\""+row.NAME+"\")'' style=\"color: white\">"+feather.icons["trash-2"].toSvg()+"</a>";
                        }
                    else if(row.ICON == "folder"  && row.publishStatus[0] !== "unpublished" && row.isCatalog == true){
                        action ="<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='List of products of :"+row.NAME+" ' href='catalogs.jsp?cid="+row.ID+"'>"+feather.icons.list.toSvg()+"</a><a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='List of products of :"+row.NAME+" ' href='catalog.jsp?id="+search_cid+"'>"+feather.icons.settings.toSvg()+"</a><a class='btn btn-primary btn-sm ml-1' title='Product stock for catalog :"+row.NAME+" ' href=\"prodproductStocks.jsp?cid="+row.ID+"\" >"+feather.icons["shopping-cart"].toSvg()+"</a>";
                        if(row.PHASE == "published" || row.PHASE == "changed") action +="<a class='btn btn-danger btn-sm ml-1' title= 'Unpublish' onclick='onbtnclickpublish(\""+row.ID+"\",\"catalog\",\"delete\")' style='color: white'>"+feather.icons["x"].toSvg()+"</a>";
                        else action +="<a class='btn btn-danger btn-sm ml-1' title= 'Delete'onclick='ondelete(\""+row.ID+"\",\"catalog\",\""+row.NAME+"\")'' style='color: white'>"+feather.icons["trash-2"].toSvg()+"</a>";
                    }
                    else if(row.ICON == "folder"  && row.publishStatus[0] !== "unpublished" && row.isCatalog == false){
                        action ="<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='List of products' href='catalogs.jsp?cid="+search_cid+'&folderId='+row.UUID+"'>"+feather.icons.list.toSvg()+"</a><a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='Settings' onclick='editFolder(\""+row.ID+"\")'' style='color: white'>"+feather.icons.settings.toSvg()+"</a><a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' title='Copy folder'onclick='openCopyFolderModal(\""+row.ID+"\")'' style='color: white'>"+feather.icons.copy.toSvg()+"</a>";
                        action +="<a class='btn btn-danger btn-sm ml-1' title= 'Delete' onclick='ondelete(\""+row.ID+"\",\"folder\",\""+row.NAME+"\")' style='color: white'>"+feather.icons["trash-2"].toSvg()+"</a>";
                    }
                    else if(row.ICON !== "folder"){
                        action ="<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip'  title='Product parameters of :"+row.NAME+"' href='product.jsp?cid="+search_cid+'&id='+row.ID+"'>"+feather.icons.edit.toSvg()+"</a><a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' title='Duplicate product parameters of :"+row.NAME+" 'onclick='onCopyProduct(\""+row.ID+"\")'' style='color: white'>"+feather.icons.copy.toSvg()+"</a>";                                         
                        if(row.PHASE == "published" || row.PHASE == "changed") action +="<a class='btn btn-danger btn-sm ml-1' title= 'Unpublish' onclick='onbtnclickpublish(\""+row.ID+"\",\"product\",\"delete\")' style='color: white'>"+feather.icons["x"].toSvg()+"</a>";
                        else action +="<a class='btn btn-danger btn-sm ml-1' title= 'Delete' onclick='ondelete(\""+row.ID+"\",\""+row.TYPE+"\",\""+row.NAME+"\")'' style='color: white'>"+feather.icons["trash-2"].toSvg()+"</a>";
                    }


                    return action;
                }
            },
            ],
            createdRow: function (row, data, index) {
                if(data.TYPE == "product")
                    $(".product_btn").show();
            
                let rowColor= "danger";
                if(data.publishStatus[0]== "published") rowColor="success";
                else if(data.publishStatus[0]== "changed"){
                    if((new Date(data.TBL2_DT)) > (new Date(data.UPDATED_ON))) rowColor="success";
                    else
                        rowColor="warning";
                }
                else rowColor="danger";     
                $(row).addClass('table-' + rowColor);
                
                if(data.ICON !== "folder") $(row).addClass('product');           
            },    
        });

        resultsdata.on('row-reordered', function ( e, diff, edit ) {
            if(diff && diff.length > 0){
                orderingchanged = true;
            }
        });


        var lastDiv = $("#resultsdata_wrapper > div:first > div:last");
            lastDiv.append($('<div class="form-group d-flex align-items-center justify-content-end gap-2" ><label for="customSearch" class="mr-2 mt-2">Search:</label><input type="search"style="width:200px" class="form-control form-control-sm mr-2" id="customSearch"></div>'));

            const debouncedReloadPagesTable = debounce(function(){
                isSearch = true;
                window.resultsdata.ajax.reload()
            }, 300);

            $("#customSearch").off("keyup").on("keyup", debouncedReloadPagesTable);
        
    }
    
    function refreshscreen()
    {
        var url = window.location.toString();
        var index = url.indexOf("&id=");
        if(index != -1){
            url = url.substring(0, index);
        }
        window.location = url;
    }

    function onsave(btn, catId)
    {
        $("#successmsg").fadeOut();
        $("#successmsg").html('');
        $("#errmsg").fadeOut();
        $("#errmsg").html('');
        
        var prodIds = [];

        $('#resultsdata tbody tr .slt_option').each(function(i, inputChkBox){
            prodIds.push($(inputChkBox).val());
        });

        if(prodIds.length === 0){
            return false;
        }

        var params = {
            requestType : "orderCatProducts",
            catId : catId,
            prodIds  : prodIds.join(",")
        };


        $(btn).prop('disabled',true);
        showLoader();
        $.ajax({
            url: 'productAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: params,
        })
        .done(function(response) {
            if(response.status !== "SUCCESS"){
                $("#errmsg").html("Error: products order not saved. please try again");
                $("#errmsg").show();
            }
            else{
                $("#successmsg").html("Products order saved");
                $("#successmsg").show();
                orderingchanged = false;
            }

        })
        .fail(function() {
            $("#errmsg").html("Error: products order not saved. please try again");
            $("#errmsg").show();
        })
        .always(function() {
            $(btn).prop('disabled',false);
            hideLoader();
        });
    }


    function onChangeCheckAll(checkAll) {
        var isChecked = $(checkAll).prop('checked');
        var allChecks;
        if (isChecked) {
            //select only visible
           allChecks = $('#resultsdata').find('.slt_option:visible');
        }
        else {
            //un select all
            allChecks = $('#resultsdata').find('.slt_option');
        }

        allChecks.prop('checked', isChecked).trigger('change');

        // allChecks.prop('checked', isChecked);

        // allChecks.each(function (index, el) {
        //     $(el).triggerHandler('click');
        // });

    }

    function ondelete(tid, type, name)
    {

        if(type === "folder"){
            deleteFolder(tid);
        }else{
            if(confirm("Are you sure to delete this catalog?"))
            {
                window.resultsdata.delete_id=tid;
                window.resultsdata.delete_id_type=type;
                window.resultsdata.delete_product_name=name;
                window.resultsdata.ajax.reload();
            }
        }
    }

    function onCopyProduct(productId){

        var modal = $('#copyProductModal');

        var form = $('#copyProductForm');
        form.get(0).reset();
        form.removeClass('was-validated');

        form.find('[name=productId]').val(productId);
        form.find('[name=productNewName]').val("");
        form.find('[name=copyImages]').prop('checked',false);


        modal.modal('show');
    }

    function copyProductSubmit(){
        var modal = $('#copyProductModal');
        var form = $('#copyProductForm');
        form.removeClass('was-validated');

        if(!form.get(0).checkValidity()){
            form.addClass('was-validated');
            return false;
        }

        var productId = form.find('[name=productId]').val();
        var productNewName = form.find('[name=productNewName]').val();
        var copyImages = form.find('[name=copyImages]').prop('checked')?"1":"0";

        if(productId.trim().length == 0){
            modal.modal('hide');
        }

        showLoader();
        $.ajax({
            url: 'productCopyAjax.jsp',
            dataType: 'json',
            data: {
                productId : productId,
                productNewName : productNewName,
                copyImages : copyImages,
            },
        })
        .done(function(response) {
            if(response.status == 1){

                modal.modal('hide');
                bootNotify("Product copied successfully. Refreshing list...");
                window.location.href = window.location.href;
            }
            else{
                bootNotifyError("Error in copying product. "+response.message);
            }

        })
        .fail(function() {
            bootNotifyError("Error in contacting server.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function oncopy_old(tid)
    {
        $("#successmsg").html();
        $("#successmsg").hide();
        $("#errmsg").html();
        $("#errmsg").hide();


        var prodId = tid;

        showLoader();
        $.ajax({
            url: 'productAjax.jsp',
            dataType: 'json',
            data: {
                requestType: 'getProductRelationships',
                prodId : prodId
            },
        })
        .done(function(response) {
            if(response.status !== "SUCCESS"){
                $("#errmsg").html("Error: in getting product relationship data");
                $("#errmsg").show();
                return;
            }

            openCopyDialog(prodId, response.data.mandatory, response.data.suggested);

        })
        .fail(function() {
            $("#errmsg").html("Error: in getting product relationship data");
            $("#errmsg").show();
        })
        .always(function() {
            hideLoader();
        });

    }

    function onCheckItem(check){
        check = $(check);
        var row = resultsdata.row(check.parents('tr:first'));

        if(check.prop('checked')){
            row.select();
        }
        else{
            row.deselect();
        }
    }

    function onpublish(publishType)
    {
        var selectedRows = $(".slt_option:checked");
        if (selectedRows.length > 0)
        {
            if(publishType == "multidelete"){
                selectedRows = selectedRows.filter(":not(.bg-unpublished)");
                if(selectedRows.length == 0){
                    bootNotify("No published items selected");
                    return false;
                }
            }

            var ids = "";
            selectedRows.each(function(index, tr) {
                    ids += $(tr).val()+ ",";
            });
            
            onbtnclickpublish(ids, "product", publishType);
        }
        else
        {
            bootNotify("No product selected");
        }
    };

    function onpublishorder()
    {
        if(orderingchanged)
        {
            if(!confirm("Some changes are made in ordering which are not saved. Do you still want to continue publishing old ordering?")){

                return false;
            }
        }

        var selectedRows = resultsdata.rows('.row_product',{ selected: true }).nodes().to$();
        if (selectedRows.length > 0)
        {
            var ids = "";
            selectedRows.each(function(index, tr) {
                ids += $(tr).find('input.slt_option:first').val()+ ",";
            });

            onbtnclickpublish(ids, "product", "ordering");
        }
        else
        {
            bootNotify("No product selected");
        }
    }

    function onKeyOrderSeq(event){

        var input = $(event.target);
        allowNumberOnly(input);

        if(event.which == 13 ){
            //enter pressed
            var val = parseInt(input.val());
            if( !isNaN(val) && val >= 0 ){
                var tr = input.parents("tr.product:first");
                var row = resultsdata.row(tr);
                var rowData = row.data();

                var existingVal = rowData[1];

                if(existingVal == (""+val)){
                    return false;
                }

                if(val > parseInt(existingVal)){
                    val = val + 1;
                }
                else{
                    val = val - 1;
                }

                rowData[1] = ""+val;
                row.data(rowData);

                resultsdata.draw(false);
                //we have to update the displayed numbering of all rows
                //according to new order of rows
                resultsdata.rows('.product').every(function ( rowIdx, tableLoop, rowLoop ) {
                    var d = this.data();

                    d[1] = "" + (rowLoop+1);
                    this.data(d);

                } )
                .draw(false);
                orderingchanged = true;
            }
        }
    }

    function addNewRequest()
    {
        $("#importdlg").modal("hide");
        $("#requestDlgAlert").hide();
        $("#requestDlgSucc").hide();
        $("#requestDlgError").hide();
        $("#requestDlgBrand").val("");
        $("#requestDlgModel").val("");
        $("#requestDeviceDlg").modal("show");
    }

    function submitRequest()
    {
        $("#requestDlgAlert").fadeOut();
        $("#requestDlgSucc").fadeOut();
        $("#requestDlgError").fadeOut();
        if($.trim($("#requestDlgBrand").val()) == "" || $.trim($("#requestDlgModel").val()) == "" )
        {
            $("#requestDlgAlert").fadeIn();
            return;
        }

        $.ajax({
            url: 'ajax/devices/requestDevice.jsp',
            type: 'POST',
                dataType: 'json',
                data: {brand : $("#requestDlgBrand").val(), model : $("#requestDlgModel").val()},
                success : function(json)
                {
                    if(json.status == "success")
                    {
                        $("#requestDlgBrand").val("");
                        $("#requestDlgModel").val("");
                        $("#requestDlgSucc").fadeIn();
                    }
                    else
                    {
                        $("#requestDlgError").fadeIn();
                    }
                }
            });

    }

    function openCopyDialog(prodId,mandatoryList,suggestedList){
        var copyDialog = $('#copyProductDialog');

        $('#copyProductId').val(prodId);
        $('#copyProductNewName').val("");
        $('#copyProductCopyImages').prop('checked',true);

        if(mandatoryList.length > 0){
            var html = "";
            for (var i = 0; i < mandatoryList.length; i++) {
                var obj = mandatoryList[i];

                html += "<tr><td>" + obj.name + "</td><td>"
                    + "<input name='' value='' data-id='"+obj.id+"' maxlength='255' "
                    + " class='relatedMandatoryProductName' style='width:100%;' />"
                    + "</td></tr>" ;
            }

            copyDialog.find('.relatedProductsMandatory .relatedProductsContent').html(html);
            copyDialog.find('.relatedProductsMandatory').show();
        }
        else{
            copyDialog.find('.relatedProductsMandatory .relatedProductsContent').html("");
            copyDialog.find('.relatedProductsMandatory').hide();
        }

        if(suggestedList.length > 0){
            var html = "";
            for (var i = 0; i < suggestedList.length; i++) {
                var obj = suggestedList[i];

                html += "<tr>"
                    + "<td><input type='checkbox' name='' value='1' data-id='"+obj.id+"' "
                    + " class='relatedSuggestedProductCheckbox' /> </td>"
                    + "<td>" + obj.name + "</td>"
                    + "<td><input name='' value='' data-id='"+obj.id+"' maxlength='255' "
                    + " class='relatedSuggestedProductName_"+obj.id+"' style='width:100%;' />"
                    + "</td></tr>" ;
            }

            copyDialog.find('.relatedProductsSuggested .relatedProductsContent').html(html);
            copyDialog.find('.relatedProductsSuggested').show();
        }
        else{
            copyDialog.find('.relatedProductsSuggested .relatedProductsContent').html("");
            copyDialog.find('.relatedProductsSuggested').hide();
        }

        copyDialog.find('.infoMsg').html("");
        copyDialog.find('.errorMsg').html("");

        copyDialog.modal("show");

    }


    function copyProduct_old(){
        var dialogDiv = $('#copyProductDialog');
        var prodNewName = $('#copyProductNewName').val().trim();

        //validations
        if(prodNewName === ""){
            bootNotifyError("Error: product name cannot be empty.");
            return false;
        }

        var mandatoryProducts = [];
        var suggestedProducts = [];
        var isError = false;

        dialogDiv.find('.relatedMandatoryProductName').each(function(index, el) {
            if($(el).val().trim() === ''){
                bootNotifyError("Error: Mandatory product new name cannot be empty.");
                isError = true;
                return false;
            }
            else{
                mandatoryProducts.push({
                    id : $(el).attr('data-id'),
                    name : 	$(el).val().trim()
                });
            }
        });

        if(isError)
            return false;

        dialogDiv.find('.relatedSuggestedProductCheckbox:checked').each(function(index, el) {
            var sId = $(el).attr('data-id');
            var input = dialogDiv.find('.relatedSuggestedProductName_'+sId+':first');
            if(input.val().trim() === ''){
                bootNotifyError("Error: Selected suggested product new name cannot be empty.");
                isError = true;
                return false;
            }
            else{
                suggestedProducts.push({
                    id : $(el).attr('data-id'),
                    name : 	input.val().trim()
                });
            }
        });

        if(isError)
            return false;

        if(!confirm("Are you sure ?")){
            return false;
        }
        var errorMsg = dialogDiv.find('.errorMsg');
        var infoMsg = dialogDiv.find('.infoMsg');

        errorMsg.html("");
        infoMsg.html("");

        var newProdId = "";
        var copiedProductIdList = [];

        // var formData = dialogDiv.find('form:first').serialize();

        var deleteCopiedProducts = function(idList){

            if(idList.length === 0){
                return false;
            }

            $.ajax({
                url: 'productAjax.jsp',
                type: 'POST',
                dataType: 'json',
                data: {
                    requestType : 'dProducts',
                    productId : idList
                },
            })
            .done(function(response) {
                if(response["status"] !== "ERROR"){

                }
            })
            .fail(function() {
                //console.log("error");
            })
            .always(function() {

            });

        };

        var copyProductRecursive = function(productId, productNewName, copyImages,
                                        parentProductId, relationshipType){
            showLoader();
            var params = {
                productId : productId,
                productNewName : productNewName,
                copyImages : 1,
                parentProductId : parentProductId,
                relationshipType : relationshipType
            };

            $.ajax({
                type :  'POST',
                url :   'copyproduct.jsp',
                data :  params,
                dataType : "json",
                cache : false,
                success:function(response){
                    if(response["status"] !== "ERROR" && response.data.newId != ''){

                        if(parentProductId == ''){
                            newProdId = response.data.newId;
                        }
                        copiedProductIdList.push(response.data.newId);

                        if(mandatoryProducts.length > 0){
                            //recursively call
                            var mObj = mandatoryProducts.shift();
                            copyProductRecursive(mObj.id,mObj.name, copyImages,
                                                    newProdId, 'mandatory');
                        }
                        else if(suggestedProducts.length > 0){
                            //recursively call
                            var sObj = suggestedProducts.shift();
                            copyProductRecursive(sObj.id,sObj.name, copyImages,
                                                    newProdId, 'suggested');
                        }
                        else{
                            infoMsg.html("Product copied successfully. Refreshing list...");
                            window.location.href = window.location.href;
                        }

                    }
                    else{
                        errorMsg.html("Error encountered in copying product.");
                        deleteCopiedProducts(copiedProductIdList);
                    }
                },
                error: function(data){
                    errorMsg.html("Error in contacting server.Please try again.");
                    deleteCopiedProducts(copiedProductIdList);
                },
                complete : function(){
                    hideLoader();
                }
            });

        };//end function copyProductRecursive

        //call recursive function
        var productId = $('#copyProductId').val();
        var copyProductImages = ($('#copyProductCopyImages').prop('checked'))?"1":"0";
        copyProductRecursive( productId, prodNewName, copyProductImages,'','');


    }

    function searchDevices()
    {
        $("#impDlgAlert").hide();
        $("#impDlgAlert2").hide();
        $("#impDlgAlert3").hide();
        $("#impDlgAlert4").hide();

        if($.trim($("#impDlgBrand").val()) == "" && $.trim($("#impDlgModel").val()) == "" )
        {
            $("#impDlgAlert").show();
            return;
        }
        $("#impDlgLoader").show();
        $("#impDlgResults").hide();
        $("#requestDeviceDiv").hide();
        $.ajax({
            url: 'ajax/devices/fetch.jsp',
            type: 'POST',
            dataType: 'json',
            data: {model : $("#impDlgModel").val(), brand : $("#impDlgBrand").val(), dtype : $("#impDlgDType").val()},
            complete : function()
            {
                $("#impDlgLoader").hide();
            },
            success : function(json)
            {
                impDlgDataTable.clear();
                if(json.status == "error")
                {
                    $("#impDlgAlert2").show();
                }
                else if(json.devices && json.devices.length > 0)
                {
                    for(var i=0; i<json.devices.length;i++)
                    {
                        var importBtn = "";
                        if(json.devices[i].alreadyImported == false) importBtn = "<a href='javascript:importDevice("+i+",\""+json.devices[i].nacode+"\")' style='font-weight:bold;font-size:15pt'>+</a>";
                        var rowNode = impDlgDataTable.row.add([
                            "<img src='"+json.devices[i].image+"' style='max-height:40px; max-width:40px' />",
                            json.devices[i].brand,
                            json.devices[i].model,
                            "On : "+json.devices[i].updated_on+" <br> By :" + json.devices[i].updated_by,
                            importBtn
                            ]).draw().node();
                        if(json.devices[i].alreadyImported == true) $(rowNode).addClass("bg-published");
                        else $(rowNode).addClass("bg-unpublished");
                        $(rowNode).attr("id","device_" + json.devices[i].nacode);
                    }

                    $("#impDlgResults").show();
                    $("#requestDeviceDiv").show();
                }
                else
                {
                    $("#impDlgResults").hide();
                    $("#impDlgAlert3").show();
                    $("#requestDeviceDiv").show();

                }
            }
        });

    }

    function importDevice(index, nacode)
    {

        $("#impDlgAlert").hide();
        $("#impDlgAlert2").hide();
        $("#impDlgAlert3").hide();
        $("#impDlgAlert4").hide();

        $("#impDlgLoader").show();
        $.ajax({
            url: 'ajax/devices/import.jsp',
            type: 'POST',
            dataType: 'json',
            data: {nacode : nacode, catalogid : '<%=cid%>', folderId:$('#folderId').val()},
            complete : function()
            {
                $("#impDlgLoader").hide();
            },
            success : function(json)
            {
                if(json.status == "error")
                {
                    $("#impDlgAlert2").show();
                }
                else
                {
                    impDlgDataTable.cell(index, 4).data("").draw();
                    $(impDlgDataTable.row(index).node()).removeClass("bg-unpublished").addClass("bg-published");
                    $("#impDlgAlert4").show();

                    var rowCount = resultsdata.rows().nodes().to$().length;
                    var rowData = [];

                    rowData.push("<input type='checkbox' class='slt_option d-none d-sm-block' value='"+json.product_id+"' /><input type='hidden' name='id' value='"+json.product_id+"'  />");
                    rowData.push(rowCount+1); //rowData.push(json.order_seq);
                    if(json.image != null && json.image.length > 0){
                        rowData.push("<img src='"+ MEDIA_IMAGE_URL_PREFIX + json.image +"' style='max-height:40px; max-width:40px' />");
                    }
                    else{
                        rowData.push("");
                    }
                    rowData.push(json.brand + " " + json.model);
                    rowData.push("&nbsp;-");

                    var updatedOn = json.updated_on;
                    var toolTipText = "";

                    if(updatedOn.length > 0 )
                    {
                        toolTipText = "Last change: "+json.updated_on+" by "+json.updated_by;
                    }
                    

                    var rowNode = resultsdata.row.add(rowData).draw().node();
                    $(rowNode).find('td:last-child').addClass('text-right');
                    $(rowNode).find('td').eq(3).addClass('font-weight-bold');
                    $(rowNode).find('.custom-tooltip').tooltip({
                        placement : 'bottom',
                        trigger: 'manual',
                        html:true,
                        animation:false
                    }).on("mouseenter", function () {
                            var _this = this;
                            $(this).tooltip("show");
                            $(".tooltip").on("mouseleave", function () {
                                $(_this).tooltip('hide');
                            });
                    }).on("mouseleave", function () {
                        var _this = this;
                        setTimeout(function () {
                            if (!$(".tooltip:hover").length) {
                                $(_this).tooltip("hide");
                            }
                        }, 300);
                    });

                    $(rowNode).addClass('row_product');
                    $(rowNode).addClass('bg-unpublished');
                    // $('.product_btn').show();
                }
            }
        });

    }

    function openMoveToModal() {

        var selectedRows = $(".slt_option:checked");
        var productRows = resultsdata.rows(".slt_option",{ selected: true }).nodes().to$();
        var folderRows = resultsdata.rows(".slt_option",{ selected: true }).nodes().to$();
        if (selectedRows.length == 0) {
            bootNotify("No product or folder selected");
            return false;
        }
        else {
        if (selectedRows.length > 0){
            $("#productsFoldersSelect").val("");
            $("#moveToDlg").modal("show");
            loadProductFoldersList($('#productsFoldersSelect'));
        }
    }
    }

    function loadProductFoldersList(productFoldersSelect) {
        $.ajax({
            url : 'foldersAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'getProductFoldersList',
                catalogId: $('#catalogId').val()
            },
        })
        .done(function (resp) {
            if (resp.status == 1) {
                var selectHtml = "";
                var productSelect = $(productFoldersSelect);

                if (productSelect.length > 0 ) {
                    var foldersList = resp.data.folders;
                    var lastConcatPath = "";
                    selectHtml += '<option value="">-- list of folders --</option>';
                    $.each(foldersList, function (index, curFolder) {
                        if (lastConcatPath !== curFolder.concat_path) {
                            if(lastConcatPath != ""){
                                selectHtml +='</optgroup>';
                            }
                            lastConcatPath  = curFolder.concat_path;
                            selectHtml +='<optgroup  class="bg-secondary" label="'+curFolder.concat_path + "/"+'" >';
                            selectHtml +='<option value="'+curFolder.uuid+'" data-cat-id="'+curFolder.catalog_id+'">'+curFolder.name+'</option>';
                        }else{
                            selectHtml +='<option value="'+curFolder.uuid+'" data-cat-id="'+curFolder.catalog_id+'">'+curFolder.name+'</option>';
                        }
                    });
                    selectHtml += '</optgroup>';
                    productSelect.html(selectHtml);
                }
            }
            else {
                alert(resp.message);
            }
        })
        .always(function() {
            hideLoader();
        });
    }

    function moveSelectedProducts() {
        $("#moveToDlg").modal("hide");
        
        var moveToFoldreId = $('#productsFoldersSelect').val();
        var moveToFoldreName = $('#productsFoldersSelect option:selected').text();
        var moveToCatalogId = $('#productsFoldersSelect option:selected').attr("data-cat-id");
        var productRows = $(".slt_option:checked[data-type='product']");
        var folderRows = $(".slt_option:checked[data-type='folder']");

        if (productRows.length + folderRows.length == 0) {
            bootNotify("No product or folder selected");
            return false;
        }

        var products = [];

        $.each(productRows, function (index, row) {
            products.push({id: $(row).val(), type: "product"});
        });

        $.each(folderRows, function (index, row) {
            products.push({id: $(row).val(), type: "folder"});
        });

        var confirmMsg = "";
        if(productRows.length >0){
            confirmMsg += " "+productRows.length + " product(s)";
        }
        if(folderRows.length>0){
            if(confirmMsg.length>0){
                confirmMsg += " and ";
            }
            confirmMsg += " "+folderRows.length + " folder(s)";
        }
        confirmMsg += " are selected. Are you sure you want to move them to "+moveToFoldreName+" folder?";

        bootConfirm(confirmMsg, function (result) {
            if (result) {
                moveProducts(products, moveToFoldreId,moveToCatalogId);
            }
        });
    }

    function moveProducts(products, moveToFoldreId, moveToCatalogId) {
        if (products.length <= 0) {
            return false;
        }
        //for multi value parameters to work
        var params = $.param({
            requestType: 'moveProducts',
            products: JSON.stringify(products),
            moveToFolderId: moveToFoldreId,
            moveToCatalogId: moveToCatalogId
        }, true);

        showLoader();
        $.ajax({
            url: 'foldersAjax.jsp', type: 'POST', dataType: 'json',
            data: params,
        })
        .done(function (resp) {
            if (resp.status != 1) {
                bootAlert(resp.message + " ");
            }
            else {
                bootNotify(resp.message);
                setTimeout(function(){
                    refreshscreen();
                }, 3000);
            }

        })
        .always(function () {
            hideLoader();
        });
    }

</script>
</body>
</html>
