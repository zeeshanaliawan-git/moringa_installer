 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.List, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>

<%
    String selectedsiteid = getSelectedSiteId(session);
    String logedInUserName = parseNull(session.getAttribute("LOGIN"));
    String logedInUserId = parseNull(Etn.getId());

    String query = "select c.id,c.updated_on,'Folder' as type,c.name as 'name','C' as 'action','Catalog' as 'method','Products' as cname,pr.first_name AS 'deleted_by' "+
        "from catalogs_tbl c "+
        "LEFT JOIN person pr ON pr.person_id = c.updated_by "+
        "where c.is_deleted ='1' and c.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "select pft.id,pft.updated_on,'Folder' as type,pft.name as name,'F' as 'action','Folder' as 'method', "+
        "case when pft2.name IS NULL then c.name when pft3.name IS NULL then CONCAT(c.name,' > ',pft2.name) "+
        "ELSE CONCAT(c.name,' > ',pft3.name,' > ',pft2.name) END AS 'cname',pr.first_name AS 'deleted_by' "+
        "from products_folders_tbl pft "+
        "LEFT JOIN catalogs_tbl c ON c.id=pft.catalog_id LEFT JOIN person pr ON pr.person_id = pft.updated_by "+
        "LEFT JOIN products_folders_tbl pft2 ON pft2.id= pft.parent_folder_id LEFT JOIN products_folders_tbl pft3 ON pft3.id= pft2.parent_folder_id "+
        "where pft.is_deleted ='1' and c.is_deleted='0' and (pft2.is_deleted='0' or pft2.name is null) "+
        "and (pft3.is_deleted='0' or pft3.name is null) and pft.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT p.id,p.updated_on,p.product_type as type,p.lang_1_name as name,'P' as 'action','Product' as 'method', "+
        "case when pft1.name IS NULL then c.name when pft2.name IS NULL then CONCAT(c.name,' > ',pft1.name) "+
        "when pft3.name IS NULL then CONCAT(c.name,' > ',pft2.name,' > ',pft1.name) ELSE CONCAT(c.name,' > ',pft3.name,' > ',pft2.name,' > ',pft1.name) "+
        "END as cname,pr.first_name AS 'deleted_by' FROM products_tbl p LEFT JOIN catalogs_tbl c ON c.id=p.catalog_id "+
        "LEFT JOIN person pr ON pr.person_id = p.updated_by LEFT JOIN products_folders_tbl pft1 ON pft1.id= p.folder_id "+
        "LEFT JOIN products_folders_tbl pft2 ON pft2.id= pft1.parent_folder_id "+
        "LEFT JOIN products_folders_tbl pft3 ON pft3.id= pft2.parent_folder_id "+
        "WHERE p.is_deleted ='1' and c.is_deleted='0' and (pft1.is_deleted='0' or pft1.name is null) and "+
        "(pft2.is_deleted='0' or pft2.name is null) and (pft3.is_deleted='0' or pft3.name is null) and c.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.form_id AS id ,pf.updated_on,'Form' AS 'type',pf.process_name AS 'name','O' as 'action','Form' as 'method',"+
        "pf.table_name AS cname,pr.first_name AS 'deleted_by' "+
        "FROM "+GlobalParm.getParm("FORMS_DB")+".process_forms_unpublished_tbl pf "+ 
        "LEFT JOIN "+GlobalParm.getParm("FORMS_DB")+".person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id = "+escape.cote(selectedsiteid)+ " AND "+
        "pf.form_id not in (SELECT gu.FORM_ID FROM "+GlobalParm.getParm("FORMS_DB")+".games_unpublished gu WHERE gu.site_id = "+escape.cote(selectedsiteid)+") "+
        " UNION "+
        "SELECT pf.id,pf.updated_on,'Additional Fee' AS 'type',pf.additional_fee AS 'name','A' as 'action','Additional' as 'method',"+
        "'Additional Fee' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM additionalfees_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_on,'Cart Promotion' AS 'type',pf.name AS 'name','T' as 'action','CartPromotion' as 'method',"+
        "'Cart Promotion' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM cart_promotion_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_on,'Promotion' AS 'type',pf.name AS 'name','R' as 'action','Promotion' as 'method',"+
        "'Promotion' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM promotions_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_on,'Come With' AS 'type',pf.name AS 'name','W' as 'action','Comewith' as 'method',"+
        "'Come With' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM comewiths_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_on,'Subsidies' AS 'type',pf.name AS 'name','S' as 'action','Subsidies' as 'method',"+
        "'Subsidies' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM subsidies_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_on,'Delivery Fee' AS 'type',pf.name AS 'name','D' as 'action','Delivery' as 'method',"+
        "'Delivery Fee' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM deliveryfees_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_on,'Delivery Min' AS 'type',pf.name AS 'name','M' as 'action','DeliveryMins' as 'method',"+
        "'Delivery Min' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM deliverymins_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_ts AS updated_on,pf.type AS 'type',pf.name AS 'name','B' as 'action','BlockTemplates' as 'method',"+
        "'Templates' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM "+GlobalParm.getParm("PAGES_DB")+".bloc_templates_tbl pf "+
        "LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".person pr ON pr.person_id = pf.updated_by "+ 
        "LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".themes t ON t.id = pf.theme_id "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_ts AS updated_on,'Page Template' AS 'type',pf.name AS 'name','L' as 'action','PageTemplate' as 'method',"+
        "'Page Templates' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM "+GlobalParm.getParm("PAGES_DB")+".page_templates_tbl pf "+
        "LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".person pr ON pr.person_id = pf.updated_by "+ 
        "LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".themes t ON t.id = pf.theme_id "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_ts AS updated_on,'File' AS 'type',pf.file_name AS 'name','E' as 'action','Files' as 'method',"+
        "'File' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM "+GlobalParm.getParm("PAGES_DB")+".files_tbl pf "+
        "LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_ts AS updated_on,'Library' AS 'type',pf.name AS 'name','I' as 'action','Library' as 'method',"+
        "'Library' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_tbl pf "+
        "LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.id ,pf.updated_on,'Quantity Limit' AS 'type',pf.name AS 'name','Q' as 'action','QuantityLimits' as 'method',"+
        "'Quantity Limit' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM quantitylimits_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pf.qs_uuid AS 'id' ,pf.updated_on,"+
        "'Query Settings' AS 'type',pf.name AS 'name','G' as 'action','ExpertSystem' as 'method',"+
        "'Query Settings' AS cname,pr.first_name AS 'deleted_by' "+
        "FROM "+GlobalParm.getParm("EXPERT_SYSTEM_DB")+".query_settings_tbl pf "+
        "LEFT JOIN person pr ON pr.person_id = pf.updated_by "+
        "WHERE pf.is_deleted = '1' AND pf.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT sct.id,sct.updated_ts,'Content Page' AS 'type',sct.name AS 'name','J' as 'action','Contentpage' as 'method',"+
        " case when f1.name IS NULL then 'Pages' when f2.name IS NULL then f1.name ELSE CONCAT(f2.name,' > ',f1.name)"+
        " END as cname,pr.first_name AS 'deleted_by' FROM "+GlobalParm.getParm("PAGES_DB")+".structured_contents_tbl sct"+
        " LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".person pr ON pr.person_id = sct.updated_by LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+
        ".folders_tbl f1 ON f1.id=sct.folder_id LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".folders_tbl f2 ON f2.id=f1.parent_folder_id "+
        "WHERE sct.is_deleted='1' and (f1.name is null or f1.is_deleted='0') and structured_version='V1' AND sct.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT fpt.id,fpt.updated_ts,'Bloc Page' AS 'type',fpt.name AS 'name','K' as 'action','Blocpage' as 'method',"+
        " case when f1.name IS NULL then 'Pages' when f2.name IS NULL then f1.name ELSE CONCAT(f2.name,' > ',f1.name)"+
        " END as cname,pr.first_name AS 'deleted_by' FROM "+GlobalParm.getParm("PAGES_DB")+
        ".freemarker_pages_tbl fpt LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".person pr ON pr.person_id = fpt.updated_by"+
        " LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".folders_tbl f1 ON f1.id=fpt.folder_id LEFT JOIN "+
        GlobalParm.getParm("PAGES_DB")+".folders_tbl f2 ON f2.id=f1.parent_folder_id"+
        " WHERE fpt.is_deleted='1' and (f1.name is null or f1.is_deleted='0') AND fpt.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT pt.id,pt.updated_ts,'React Page' AS 'type',pt.name AS 'name','H' as 'action','Reactpage' as 'method',"+
        "case when f1.name IS NULL then 'Pages' when f2.name IS NULL then f1.name ELSE CONCAT(f2.name,' > ',f1.name)"+
        "END as cname,pr.first_name AS 'deleted_by' FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tbl pt"+
        " LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".person pr ON pr.person_id = pt.updated_by LEFT JOIN "+
        GlobalParm.getParm("PAGES_DB")+".folders_tbl f1 ON f1.id=pt.folder_id"+
        " LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".folders_tbl f2 ON f2.id=f1.parent_folder_id"+
        " WHERE pt.type = 'react' and pt.is_deleted='1' and (f1.name is null or f1.is_deleted='0') AND pt.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT f.id,f.updated_ts,'Folder' AS 'type',f.name AS 'name','N' as 'action','Pagesfolder' as 'method', "+
        "case when f1.name IS NULL then "+
        "'Pages' ELSE CONCAT(f1.name) "+
        "END as cname, "+
        "pr.first_name AS 'deleted_by' "+
        "FROM "+GlobalParm.getParm("PAGES_DB")+".folders_tbl f "+
        "LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".person pr ON pr.person_id = f.updated_by "+
        "LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".folders_tbl f1 ON f1.id=f.parent_folder_id "+
        "WHERE f.is_deleted='1' and (f1.name IS NULL or f1.is_deleted='0') AND f.site_id="+escape.cote(selectedsiteid)+
        " UNION "+
        "SELECT g.id AS 'id' ,g.updated_on,"+
        "'Game' AS 'type', g.name AS 'name','Z' as 'action','Game' as 'method',"+
        "'Game' AS cname, pr.first_name AS 'deleted_by' "+
        "FROM "+GlobalParm.getParm("FORMS_DB")+".games_unpublished g "+
        "LEFT JOIN person pr ON pr.person_id = g.updated_by "+
        "WHERE g.is_deleted = '1' AND g.site_id="+escape.cote(selectedsiteid);

    Set rs = Etn.execute(query);


%>

<!DOCTYPE html>

<html>
<head>
    <title>Trash</title>
    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    <%	
        breadcrumbs.add(new String[]{"Trash", ""});
    %>

<style type="text/css">
    .relatedProducts thead th{
        text-align: left;
    }
    .relatedProducts tbody tr td:first-child{
        width: 50px;
        white-space: nowrap;
    }
    .relatedProducts tbody tr td:last-child{
        width: 90%;
    }
    .modal-large {
        width: 75% !important;
        max-width: 75% !important;
    }
    #impDlgLoader {
        width: 100px;
        height: 100px;
        position: fixed;
        top: 50%;
        left: 45%;
        z-index: 1000;
        display:none;
    }
</style>

</head>
<body class="c-app" style="background-color:#efefef">

<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
   
            <!-- title -->
            <div class="">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <div>
                        <h1 class="h2">
                            Trash
                        </h1>
                    </div>

                    <!-- buttons bar -->
                    <div class="btn-toolbar mb-2 mb-md-0" >
                        <div class="btn-group mr-2 mt-1" role="group" aria-label="...">
                            <button type="button" class="btn  btn-primary" onclick="history.back()">Back</button>
                        </div>
                        <div class="btn-group mr-2 mt-1" >
                            <button type="button" class="btn btn-success" onclick="processMultiple('revert')">Revert</button>
                        </div>
                        <div class="btn-group mr-2 mt-1" >
                            <button type="button" class="btn btn-danger" onclick="processMultiple('delete')">Delete</button>
                        </div>
                        <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Trash');" title="Add to shortcuts">
                            <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                        </button>
                    </div>
                    <!-- /buttons bar -->
                </div><!-- /d-flex -->
            </div>
            <!-- /title -->

    <!-- container -->
    <div class="">
    <div class="animated fadeIn">
        <div id='successmsg' role='alert' class='alert alert-success m-t-10' style="display:none"></div>
        <div>

        <table id="productsTable" class="table table-hover table-vam m-t-20" >
            <thead class="thead-dark">
                <th class="text-center"><input type='checkbox' value='' onclick='onChangeCheckAll(this)' /></th>
                <th>Name</th>
                <th>Original Place</th>
                <th>Type</th>
                <th>Deleted Date</th>
                <th>Deleted By</th>
                <th>Actions</th>
            </thead>
            <tbody id='myTbody'>
                <%
                while(rs.next()) {

                    String actionPerform = parseNull(rs.value("METHOD"));
                    String typFlag = parseNull(rs.value("ACTION"));
                    
                %>
                    <tr class="table table-hover table-vam m-t-20 dataTable no-footer" >
                        <td style='text-align:center'>
                            <input type='checkbox' class='slt_option' value='<%=escapeCoteValue(parseNull(rs.value("ID"))+typFlag)%>' onclick='onCheckItem(this)' />
                        </td>

                        <td>
                            <%=escapeCoteValue(parseNull(rs.value("name")))%>
                        </td>

                        <td>
                            <%=escapeCoteValue(parseNull(rs.value("cname")).replace("Root Catalog","Products(new)"))%>
                        </td>
                        
                        <td>
                            <%=escapeCoteValue(rs.value("type"))%>
                        </td>
                        <td>
                            <%=escapeCoteValue(parseNull(rs.value("updated_on")))%>
                        </td>
                        <td>
                            <%=escapeCoteValue(parseNull(rs.value("deleted_by")))%>
                        </td>
                        <td class="text-right">
                            <button type="button" class="btn btn-success btn-sm"
                                onclick='processSingle("<%=escapeCoteValue(parseNull(rs.value("ID")))%>","revert<%=escapeCoteValue(actionPerform)%>","revert", "<%=escapeCoteValue(rs.value("type"))%>")'
                                data-toggle='tooltip' data-placement='top'
                                title="Revert"><i data-feather="repeat"></i>
                            </button>
                            <button type="button" class="btn btn-sm btn-danger" title="Delete"
                                onclick='processSingle("<%=escapeCoteValue(parseNull(rs.value("ID")))%>","delete<%=escapeCoteValue(actionPerform)%>","delete", "<%=escapeCoteValue(rs.value("type"))%>")' >
                                <i data-feather="trash-2"></i>
                            </button>
                        </td>
                    </tr>
                <%}%>
            </tbody>
        </table>
    </div>
    <div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
    </div>
    </div>
</main>

<%@ include file="../prodpublishloginmultiselect.jsp"%>
</div><!-- /c-body -->

<%@ include file="foldersAddEdit.jsp" %>
<%@ include file="/WEB-INF/include/footer.jsp" %>


<script type="text/javascript">
    var orderingchanged = false;

    $(document).ready(function() {

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

        window.productsTable = $('#productsTable').DataTable({
            responsive: true,
            order : [[4,'asc']],
            pageLength : 100,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            "language": {
                "emptyTable": "No products found"
            },
            rowReorder : {
                dataSrc : 1,
                selector : 'tr.row_product td:not(:first-child):not(:nth-child(2)):not(:last-child)'
            },
            select : {
                style       : 'multi',
                className   : '',
                selector    : 'td.noselector' //dummyselector
            },
            "columnDefs": [
                {   className : "text-center", targets : [0] },
                {   targets : [-0], orderable : false }
            ],
        });

        productsTable.on('row-reordered', function ( e, diff, edit ) {
            if(diff && diff.length > 0){
                orderingchanged = true;
            }
        });

    });

    let rowList = new Array();
    function processSingle(tid,call_type,call_method, typ)
    {
        console.log("=================> call_type : ",call_type);
        let msg="Are you sure to "+call_method+" this "+typ+"?";
        if(typ==="Folder" && call_method=='delete'){
            msg+=" Its folders and pages will be "+call_method+"ed automatically.";
        }
        if(confirm(msg))
        { 
            $.ajax({
                url: 'trashAjax.jsp',
                type: 'POST',
                dataType: 'json',
                data : {
                    requestType : call_type,
                    prodId: tid
                },
                success : function(json){
                    if(call_type.toLowerCase().includes("revert")){
                        json.message+=" Do you want to force revert?";
                    }
					if(json.status == "ERROR")
					{
                        bootConfirm(json.message, function(result){
                            if(result){
                                $.ajax({
                                    type : 'POST',
                                    url :  'trashAjax.jsp',
                                    dataType : 'json',
                                    data : {
                                        requestType: call_type,
                                        prodId: tid,
                                        severity: "force"
                                    },
                                    success : function(json){
                                        console.log(json);
                                        if(json.status == "SUCCESS"){
                                            bootNotify(json.message);
                                            setTimeout(function() {
                                                window.location = window.location;
                                            }, 2000);
                                        }
                                    }  
                                });
                            }
                        })  
					}
                    else window.location.reload();
                }
            
            });
        }
    }
    function processSingleWithForce(tid,call_type,call_method, typ,force)
    {
        if(typ!=='product'){

            let msg=typ+" already exist. Do you want to "+call_method+" this "+typ+" forcefully?";
        
            if(confirm(msg))
            {
                $.ajax({
                    url: 'trashAjax.jsp',
                    type: 'POST',
                    dataType: 'json',
                    data : {
                        requestType : call_type,
                        prodId: tid,
                        severity:force
                    },
                    success : function(json){
                        if(json.status == "ERROR")
                        {
                            
                            bootNotifyError(json.message);
                            
                        }
                        else window.location.reload();
                    }
                });
            }
        }
    }
    function processMultiple(call_method)
    {
        if(confirm("Are you sure to "+call_method+" selected rows?"))
        {
            $.ajax({
                url: 'trashAjax.jsp',
                type: 'POST',
                dataType: 'json',
                data : {
                    method : call_method,
                    requestType : 'multiple',
                    productId: rowList
                },
                success : function(json){
					if(json.status == "ERROR")
					{
						bootConfirm(json.message, function(result){
                            if(result){
                                $.ajax({
                                    type : 'POST',
                                    url : 'trashAjax.jsp',
                                    dataType : 'json',
                                    data : {
                                        method : call_method,
                                        requestType: 'forceRevertQuerySettingsMultiple',
                                        productId: rowList

                                    },
                                    success : function(json){
                                        if(json.status == "SUCCESS"){
                                            bootNotify(json.message);
                                            setTimeout(function() {
                                                window.location.reload();
                                            }, 5000);

                                        }
                                    }
                                })
                            }
                        });
					}
                    else window.location.reload();
                }
            });
        }
    }

    function onCheckItem(check){
        check = $(check);
        var row = productsTable.row(check.parents('tr:first'));
        if(check.prop('checked')){
            if(!rowList.includes(check.prop('value').toString())){
                rowList.push(check.prop('value').toString());
            }
            row.select();
        }
        else{
            if(rowList.includes(check.prop('value').toString())){
                rowList.splice(rowList.indexOf(check.prop('value').toString()), 1);
            }
            row.deselect();
        }
    }

    function onChangeCheckAll(checkAll){
        
        var allChecks = productsTable.rows().nodes().to$().find('.slt_option');
        allChecks.prop('checked',$(checkAll).prop('checked'));

        if($(checkAll).prop('checked')){
            rowList=[];
            allChecks.each(function(index, el) {
                if(!rowList.includes(el)){
                    rowList.push(el.value);
                }
                $(el).triggerHandler('click');
            
            });
        }else{
            rowList=[];
            allChecks.each(function(index, el) {
                $(el).triggerHandler('click');
            });
        }
    }


    function onKeyOrderSeq(event){

        var input = $(event.target);
        allowNumberOnly(input);

        if(event.which == 13 ){
            //enter pressed
            var val = parseInt(input.val());
            if( !isNaN(val) && val >= 0 ){
                var tr = input.parents("tr.row_product:first");
                var row = productsTable.row(tr);
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

                productsTable.draw(false);
                //we have to update the displayed numbering of all rows
                //according to new order of rows
                productsTable.rows('.row_product').every(function ( rowIdx, tableLoop, rowLoop ) {
                    var d = this.data();

                    d[1] = "" + (rowLoop+1);
                    this.data(d);

                } )
                .draw(false);
                orderingchanged = true;
            }
        }
    }

    

</script>
</body>
</html>
