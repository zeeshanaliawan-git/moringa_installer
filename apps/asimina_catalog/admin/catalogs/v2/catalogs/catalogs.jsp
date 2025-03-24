\<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.asimina.util.ActivityLog, com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.List, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../../common.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>


<%!
    int parseNullInt(Object o)
    {
        if (o == null) return 0;
        String s = o.toString();
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Integer.parseInt(s);
    }

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
    String COMMONS_DB = GlobalParm.getParm("COMMONS_DB") + ".";
    String pagesDb = GlobalParm.getParm("PAGES_DB") + ".";

	String selectedsiteid = getSelectedSiteId(session);
	String folderUuid = parseNull(request.getParameter("folderId"));
    int maxFolderLevel = parseNullInt(GlobalParm.getParm("max_catalogs_folder_level"));
    
    String folderId = "0";
    int folderLevel = 0;
    String parentFolderId = "";

    String catalogPublishStatus="";
    String[] catStatusArr={};
    boolean taxParamsDifferent = false;
    String catalogVersion="";
    String catalogType="";

    int pagesFolderForProducts = 0;
    Set rsPagesFolderForProducts = Etn.execute("select * from "+pagesDb+"folders where name='Root Product Folder' and parent_folder_id='0' and site_id="+escape.cote(selectedsiteid));
    if(rsPagesFolderForProducts.rs.Rows>0){
        rsPagesFolderForProducts.next();
        pagesFolderForProducts = parseNullInt(rsPagesFolderForProducts.value("id"));
    }else{
        pagesFolderForProducts = Etn.executeCmd("insert into "+pagesDb+"folders (name,created_by,updated_by,type,site_id,folder_version) VALUES ('Root Product Folder',0,0,"+
            escape.cote("stores")+","+escape.cote(selectedsiteid)+",'V2')");
    }

    int rootCatalog = 0;
    Set rsRootCatalog = Etn.execute("select * from catalogs where name='Root Catalog' and catalog_version='V2' and site_id="+escape.cote(selectedsiteid));
    if(rsRootCatalog.rs.Rows>0){
        rsRootCatalog.next();
        rootCatalog = parseNullInt(rsRootCatalog.value("id"));
    }else{
        rootCatalog = Etn.executeCmd("insert into catalogs (name,created_by,catalog_version,site_id) VALUES ('Root Catalog',0,'V2',"+escape.cote(selectedsiteid)+")");
    }

    Set rscat = Etn.execute("select * from catalogs where id = " + escape.cote(""+rootCatalog));
    if(rootCatalog>0){
        rscat.next();
        catalogType = parseNull(rscat.value("catalog_type"));
        catalogVersion = parseNull(rscat.value("version"));
        taxParamsDifferent = "1".equals(parseNull(rscat.value("price_tax_included")));
        catStatusArr = getCatalogPublishStatus(Etn, ""+rootCatalog, catalogVersion);
        catalogPublishStatus = catStatusArr[0];
    }

    if (folderUuid.length() > 0) {
        String q = "SELECT f.name,f.id, f.uuid, f.folder_level, IFNULL(pf.uuid,'') AS parent_folder_id "
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
            response.sendRedirect("catalogs.jsp");
        }
    }

    String folderPrefixPath = "";
    Set rsFolderPath = Etn.execute("select concat_path from products_folders_lang_path where site_id="+escape.cote(selectedsiteid)+
        " and langue_id=(SELECT lang.langue_id FROM language lang LEFT JOIN "+COMMONS_DB+ "sites_langs sl ON lang.langue_id = sl.langue_id WHERE sl.site_id=" + 
        escape.cote(selectedsiteid)+" limit 1) and folder_id="+escape.cote(folderId));

    if(rsFolderPath.rs.Rows>0 && rsFolderPath.next()) folderPrefixPath= rsFolderPath.value("concat_path");

    Map<String, String> listOfFolders = new LinkedHashMap<String, String>();
	getFolders(Etn, rscat.value("site_id"), folderId, listOfFolders);
    
    String backto = "";
    if(folderUuid.length()>0 && parentFolderId.length()>0) backto = "catalogs.jsp?folderId="+parentFolderId;
    else backto = "catalogs.jsp";

    Set rsLang = Etn.execute("SELECT lang.* FROM language lang LEFT JOIN "+COMMONS_DB+ "sites_langs sl ON lang.langue_id = sl.langue_id WHERE sl.site_id=" + escape.cote(selectedsiteid));

    String _wtId= com.etn.asimina.util.UIHelper.getWebappAuthToken(Etn, request);
%>

<!DOCTYPE html>

<html>
<head>
	<title>Products</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    <%
        String lastFolderName = "";
        for(String fuuid : listOfFolders.keySet()) lastFolderName = listOfFolders.get(fuuid);
        
        breadcrumbs.add(new String[]{"Content", ""});
        breadcrumbs.add(new String[]{"Products", "catalogs.jsp"});
        
        for(String fuuid : listOfFolders.keySet())
        {
            if(folderUuid.equals(fuuid) == false) breadcrumbs.add(new String[]{escapeCoteValue(listOfFolders.get(fuuid)), "catalogs.jsp?folderId="+fuuid});
            else breadcrumbs.add(new String[]{escapeCoteValue(listOfFolders.get(fuuid)), ""});
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

        <div class="btn-toolbar mb-2 mb-md-0" >
            <div class="btn-group mr-2 mt-1 product_btn" role="group" aria-label="...">
                <button type="button" class="btn btn-danger" onclick="onpublish('multi')">Publish</button>
                <button type="button" class="btn btn-danger" onclick="onpublish('multidelete')">Unpublish</button>
            </div>
            <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                <button type="button" class="btn  btn-primary" onclick='javascript:window.location="<%=escapeCoteValue(backto)%>";'>Back</button>
            </div>
            <div class="btn-group mr-2 mt-1" >
                <button type="button" class="btn btn-success" onclick="openMoveToModal()">Move To</button>
            </div>
            <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                <div class="btn-group" role="group">
                    <%
                        if (folderLevel < maxFolderLevel) {%>
                            <button type="button" class="btn btn-success" id="addFolderBtn"
                                onclick='openFolderModal()'>Add a folder
                            </button>
                    <%
                        }
                    %>
                    <button type="button" class="btn btn-success" onclick='openProductModal("")'>Add a product</button>
                </div>
            </div>
        </div>
        
		<!-- /buttons bar -->
	</div><!-- /d-flex -->
	<!-- /title -->

	<!-- container -->
	<div class="">
	<div class="animated fadeIn">
	<div>
        <input type="hidden" id="folderUuid" name="" value="<%=escapeCoteValue(folderUuid)%>"/>
        <input type="hidden" id="folderId" name="" value="<%=escapeCoteValue(folderId)%>"/>
        <input type="hidden" id="folderLevel" name="" value="<%=escapeCoteValue(folderLevel+"")%>"/>

        <div id="catalogs-list" >
		</div>
        <div id="show-alert"></div>
        <div class="row">
        <div class="col">
		<table class="table table-hover table-vam" id="resultsdata" style="width:100%;">
			<thead class="thead-dark">
            <tr>
                <th scope="col">
                    <input type="checkbox" class="" id="checkAll" onchange="onChangeCheckAll(this)">
                </th>
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

<!-- /.modal -->
<div class="modal fade" tabindex="-1" role="dialog" id='logindlg'>
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <form id="publishLoginForm" action="" class="loginForm" >
                <div class="modal-header">
                    <h5 class="modal-title">Connection for Publication</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div>
                        <div class="alert alert-danger invalid-feedback errorMsg" role="alert" style='display:none'></div>
                        <div class="form-group">
                            <input name="username" placeholder="username" class="form-control" type="text" id="lgusername" required="required" />
                        </div>
                        <div class="form-group">
                            <input name="password" placeholder="password" class="form-control" type="password" id="lgpassword" required="required" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-success" >Connect</button>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<!-- /.modal -->


<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'></div>

<%@ include file="foldersAddEdit.jsp" %>
<%@ include file="products.jsp" %>
<%@ include file="/WEB-INF/include/footer.jsp" %>

</div>

<script>

    let _ids;
    let _publishtype;
    let _itemtype;

    jQuery(document).ready(function(){
        initDataTable();
        $('#logindlg form.loginForm').submit(function(event) {
            event.preventDefault();
            event.stopPropagation();
            onprodloginok();
        });
    });

    function initDataTable(){
        var rowCounter = 0;
        window.resultsdata= jQuery('#resultsdata').DataTable({
            responsive: true,
            pageLength: 10,
            ajax: function (data, callback, settings){
                getCommercialProducts(data, callback, settings);
            },
            searching: false,
            lengthChange:true,
            columns: [
            {"data": "ID", className: "text-center"},
            {"data": "row_type"},
            {"data": "NAME", className: "name"},
            {"data": "TYPE"},
            {"data": "NB_ITEMS", className: "text-center"},
            {"data": "updated_ts",className: "text-nowrap"},
            {"data": "actions", className: "text-right text-nowrap"},
        ],
        "columnDefs": [
            { "orderable": false, "targets": [0,6] },
            <%int counter = 0;%>
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    var dataType = row.isCatalog ? 'catalog' : (row.TYPE == 'product') ? 'product' : 'folder';
                    return `<input type="checkbox" class="slt_option" data-type="${dataType}" value="${row.ID}">`;
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    let html = "";
                    let cId = row.CATALOG_ID;
                    if(cId == undefined) cId = row.ID;
                    if (row.ICON == 'folder') {
                        if(row.path == undefined){
                                html = '<a href="catalogs.jsp?folderId='+row.UUID+'" style="color:currentColor;">' +
                                    feather.icons.folder.toSvg({class: 'feather-20', fill: '#aaa', style: 'height: 20px; width: 20px;'})+'</a>';
                        }else{
                            html = '<a href="catalogs.jsp?folderId='+row.UUID+'" style="color:currentColor;" title="'+row.path+'">'+
                                feather.icons.folder.toSvg({class: 'feather-20', fill: '#aaa', style: 'height: 20px; width: 20px;'})+'</a>';
                        }
                    } else{
                        if (row.path == undefined) html = `<img src="${row.SRC}" style="max-height:40px; max-width:40px">`;
                        else html = `<img src="${row.SRC}" style="max-height:40px; max-width:40px" title="${row.path}">`;
                    }
                    return html;
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    return `<strong style="font-size: 14px; line-height: 21px;">${_hEscapeHtml(data)}</strong>`;
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    return `<span style="font-size: 14px; line-height: 21px;">${data}</span>`;
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    let CATALOG_ID = row.CATALOG_ID;
                    if (row.CATALOG_ID == null) CATALOG_ID = row.ID;

                    let folderIdParam = row.UUID ? 'folderId=' + row.UUID : '';

                    if (row.NB_ITEMS !== 0 && row.NB_ITEMS !== '-')
                        return `<a href="catalogs.jsp?${folderIdParam}" style="color:black"><span class="badge badge-secondary ">${row.NB_ITEMS}</span></a>`;
                    else return `<a href="catalogs.jsp?${folderIdParam}" style="color:black"></a>`;
                }
            },
            {
                targets: [parseInt('<%=counter++%>')],
                render: function (data, type, row) {
                    let tooltipContent = '';
                    let updatedDate = row.UPDATED_ON.split(' ')[0];
                    let updatedTime = row.UPDATED_ON.split(' ')[1];
                    let createdDate = row.CREATED_ON.split(' ')[0];
                    let createdTime = row.CREATED_ON.split(' ')[1];
                    
                    if (row.publishStatus[0] === "unpublished") {
                        tooltipContent = `Last Change: ${createdDate} \n ${createdTime} by ${row.UPDATED_BY}`;
                    } else {
                        tooltipContent = `Last Change: ${createdDate}\n${createdTime} by ${row.UPDATED_BY}\nLast Publication: ${updatedDate}\n${updatedTime} by ${row.CREATED_BY}`;
                    }

                    let content = '<span style="font-size: 14px; line-height: 21px;">' + updatedDate + ' ' + updatedTime + '</span>' + ' <a href="javascript:void(0)" class="custom-tooltip ml-1" data-toggle="tooltip" title="' + tooltipContent + '">' + feather.icons.info.toSvg() + '</a>';

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
                        action ="<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='List of products' href='catalogs.jsp?folderId="+row.UUID+"'>"+feather.icons.list.toSvg()+"</a>"
                        +"<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='Settings' onclick='editFolder(\""+row.ID+"\")' style='color: white'>"+feather.icons.settings.toSvg()+"</a>";
                        //+"<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' title='Copy folder'onclick='openCopyFolderModal(\""+row.ID+"\")'' style='color: white'>"+feather.icons.copy.toSvg()+"</a>";
                        
                        action +="<a class='btn btn-danger btn-sm ml-1' title= 'Delete' onclick='ondelete(\""+row.ID+"\",\"folder\",\""+row.NAME+"\")' style='color: white'>"+feather.icons["trash-2"].toSvg()+"</a>";
                    }
                    else if(row.ICON == "folder"  && row.publishStatus[0] !== "unpublished" && row.isCatalog == false){
                        action ="<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='List of products' href='catalogs.jsp?folderId="+row.UUID+"'>"+feather.icons.list.toSvg()+"</a>"
                        +"<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' data-placement='top' title='Settings' onclick='editFolder(\""+row.ID+"\")' style='color: white'>"+feather.icons.settings.toSvg()+"</a>";
                        //+"<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' title='Copy folder'onclick='openCopyFolderModal(\""+row.ID+"\")'' style='color: white'>"+feather.icons.copy.toSvg()+"</a>";
                        
                        action +="<a class='btn btn-danger btn-sm ml-1' title= 'Delete' onclick='ondelete(\""+row.ID+"\",\"folder\",\""+row.NAME+"\")' style='color: white'>"+feather.icons["trash-2"].toSvg()+"</a>";
                    }
                    else if(row.ICON !== "folder"){
                        action =`<a class='btn btn-primary btn-sm ml-1' style='color: white' data-toggle='tooltip' data-placement='top' title='To Page Editor' onclick="gotToPageEditorScreen('${row.ID}')">${feather.icons.edit.toSvg()}</a>`
                        +`<a class='btn btn-primary btn-sm ml-1' title='Settings' onclick="openProductModal('${row.ID}')" style='color: white'>${feather.icons.settings.toSvg()}</a>`;
                        //+`<a class='btn btn-primary btn-sm ml-1' data-toggle='tooltip' title='Duplicate product' onclick="onCopyProduct('${row.ID}')" style='color: white'>${feather.icons.copy.toSvg()}</a>`;
                        
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


        $("#resultsdata_wrapper > div:first > div:last").append($('<div class="form-group d-flex align-items-center justify-content-end gap-2" ><label for="customSearch" class="mr-2 mt-2">Search:</label><input type="search"style="width:200px" class="form-control form-control-sm mr-2" id="customSearch"></div>'));

        const debouncedReloadPagesTable = debounce(function(){
            isSearch = true;
            window.resultsdata.ajax.reload()
        }, 300);

        $("#customSearch").off("keyup").on("keyup", debouncedReloadPagesTable);
        
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
        $.ajax({
            url:'commercialProductsAjax.jsp',
            data: {
                requestType: "getProducts",
                folderId: '<%= escapeCoteValue(folderUuid) %>',
                catalogId: '<%=escapeCoteValue(rootCatalog+"")%>',
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
                if (resp.message != undefined && resp.message != "") bootNotify(resp.message);
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

    function refreshscreen(){
        window.location.reload();
    }

    function ondelete(tid, type, name){
        if(type === "folder") deleteFolder(tid);
        else{
            if(confirm("Are you sure to delete this product?")){
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

    function openMoveToModal(){
        var selectedRows = $(".slt_option:checked");

        if (selectedRows.length > 0){
            $("#productsFoldersSelect").val("");
            $("#moveToDlg").modal("show");
            loadProductFoldersList($('#productsFoldersSelect'));
        }else{
            bootNotify("No product or folder selected");
            return false;
        }
    }

    function loadProductFoldersList(productFoldersSelect) {
        $.ajax({
            url : 'foldersAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'getProductFoldersList',
                catalogId: "<%=escapeCoteValue(rootCatalog+"")%>"
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
                            if(lastConcatPath != "") selectHtml +='</optgroup>';

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
            } else alert(resp.message);
        })
        .always(function() {
            hideLoader();
        });
    }

    function moveSelectedProducts() {
        $("#moveToDlg").modal("hide");
        
        var products = [];
        var moveToFoldreId = $('#productsFoldersSelect').val();
        var moveToFoldreName = $('#productsFoldersSelect option:selected').text();
        var moveToCatalogId = $('#productsFoldersSelect option:selected').attr("data-cat-id");
        var productRows = $(".slt_option:checked[data-type='product']");
        var folderRows = $(".slt_option:checked[data-type='folder']");

        if (productRows.length + folderRows.length == 0) {
            bootNotify("No product or folder selected");
            return false;
        }

        $.each(productRows, function (index, row) {
            products.push({id: $(row).val(), type: "product"});
        });

        $.each(folderRows, function (index, row) {
            products.push({id: $(row).val(), type: "folder"});
        });

        var confirmMsg = "";
        if(productRows.length >0) confirmMsg += " "+productRows.length + " product(s)";
        if(folderRows.length>0){
            if(confirmMsg.length>0) confirmMsg += " and ";
            confirmMsg += " "+folderRows.length + " folder(s)";
        }
        confirmMsg += " are selected. Are you sure you want to move them to "+moveToFoldreName+" folder?";

        bootConfirm(confirmMsg, function (result) {
            if (result) moveProducts(products, moveToFoldreId,moveToCatalogId);
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
            if (resp.status != 1) bootAlert(resp.message + " ");
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

    function onpublish(publishType) {
        var selectedRows = $(".slt_option:checked");
        if (selectedRows.length > 0){
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
        }else bootNotify("No product selected");
    };

    function onbtnclickpublish(ids, itemtype, publishtype){
        _ids = ids;
        _publishtype = publishtype;
        _itemtype = itemtype;
        $.ajax({
            url : '<%=request.getContextPath()%>/admin/isprodpushlogin.jsp',
            type: 'GET',
            dataType:'json',
            success : function(json){
                if(json.is_prod_login == 'true') showpublishdlg();
                else{
                    var loginModal = $("#logindlg");
                    var loginForm = loginModal.find(".loginForm");
                    loginForm.get(0).reset();
                    loginModal.find(".errorMsg").hide();
                    loginModal.modal("show");
                }
            },
            error : function(){
                bootNotifyError("Error while communicating with the server");
            }
        });
    };

    function onprodloginok() {
        var modal = $("#logindlg");

        var form = modal.find(".loginForm");
        var errorMsg = modal.find(".errorMsg");

        var username = modal.find('[name=username]');
        var password = modal.find('[name=password]');

        errorMsg.html("").hide();

        if(!form.get(0).checkValidity()) return false;

        $.ajax({
            url : '<%=request.getContextPath()%>/admin/prodaccesslogin.jsp',
            type: 'POST',
            data: {username : username.val(), password : password.val()},
            dataType:'json',
            success : function(json) {
                if(json.resp == 'error') errorMsg.html(json.msg).show();
                else {
                    modal.modal('hide');
                    showpublishdlg();
                }
            },
            error : function() {
                bootNotifyError("Error while communicating with the server");
            }
        });
    };

    function showpublishdlg() {
        $.ajax({
            url : '<%=request.getContextPath()%>/admin/showpublish.jsp',
            type: 'POST',
            data : {id : _ids, type : _itemtype, publishtype : _publishtype },
            success : function(resp){
                console.log(resp);
                $("#publishdlg").html(resp);
                $("#publishdlg").modal('show');
            },
            error : function()
            {
                bootNotifyError("Error while communicating with the server");
            }
        });
    };
</script>
</body>
</html>
