<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.asimina.util.ActivityLog, com.etn.asimina.beans.Language,com.etn.asimina.util.SiteHelper"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="../../../common.jsp"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%
    String COMMONS_DB = GlobalParm.getParm("COMMONS_DB") + ".";
	String siteid = parseNull(getSiteId(request.getSession()));
    String mediaUrl = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL");

    if(mediaUrl.endsWith("/")) mediaUrl+=siteid;
    else mediaUrl+="/"+siteid;
    mediaUrl+="/img/";
    
    Set rsLang = Etn.execute("SELECT lang.* FROM language lang LEFT JOIN "+COMMONS_DB+ "sites_langs sl ON lang.langue_id = sl.langue_id WHERE sl.site_id=" + escape.cote(siteid));
%>

<html>
<head>
	<title>Product parameters</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    
    <link href="<%=request.getContextPath()%>/css/bootstrap-colorpicker.min.css" rel="stylesheet">
    <link href="jquery.treegrid.css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/bootstrap-colorpicker.min.js"></script>

    <style type="text/css">
        .modal-dialog-slideout {
            min-height: 100%;
            margin: 0;
            margin-left: auto;
            transform: translateX(100%);
        }

        .modal.fade .modal-dialog-slideout {
            transform: translateX(0);
            transition: transform .3s ease-out;
        }

        .modal.fade.show .modal-dialog-slideout {
            transform: translateX(0%);
        }

    </style>

</head>
<body class="c-app" style="background-color:#efefef">
    <%@ include file="/WEB-INF/include/sidebar.jsp" %>
    <div class="c-wrapper c-fixed-components">
        <%
            breadcrumbs.add(new String[]{"System", ""});
            breadcrumbs.add(new String[]{"Product parameters", ""});
        %>
        <%@ include file="/WEB-INF/include/header.jsp" %>
        <div class="c-body">
            <main class="c-main"  style="padding:0px 30px">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                    <div class="d-flex">
                        <h2>Product Parameters</h2>
                    </div>
                    <div class="btn-toolbar mb-2 mb-md-0">
                        <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Product parameters');" title="Add to shortcuts">
                            <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                        </button>
                    </div>
                </div>
                <div class="animated fadeIn">
                    <div class="alert alert-danger" id="alertBox1" role="alert" style="display:none"></div>
                    <div>

                        <div class="card mb-2">
                            <div class="p-0 card-header btn-group bg-secondary d-flex">
                                <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#attributesCollapse" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64">
                                    <strong>Attributes</strong>
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-help-circle"><circle cx="12" cy="12" r="10"></circle><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                </button>
                                <button type="button" class="btn btn-success" onclick="openAttributeModal()" style="width: 200px; text-wrap:nowrap"> 
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-plus-circle mr-2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                                    Add an Attribute
                                </button>
                                <button type="button" class="btn btn-default btn-primary" onclick="onSaveAttributes()">Save</button>
                            </div>
                            <div class="collapse border-0 show" id="attributesCollapse">
                                <div class="card-body">
                                </div>
                            </div>
                        </div>

                        <div class="card mb-2">
                            <div class="p-0 card-header btn-group bg-secondary d-flex">
                                <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#categoriesCollapse" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64">
                                    <strong>Categories</strong>
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-help-circle"><circle cx="12" cy="12" r="10"></circle><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                </button>
                                <button type="button" class="btn btn-success" onclick="openCategoryModal('0','0','','',)" style="width: 200px; text-wrap:nowrap"> 
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-plus-circle mr-2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                                    Add a Category
                                </button>
                            </div>
                            <div class="collapse border-0" id="categoriesCollapse">
                                <div class="card-body">
                                    <table class="table table-hover tree-basic">
                                        <thead class="thead-dark">
                                            <tr>
                                                <th scope="col">Name</th>
                                                <th scope="col" style="width:150px">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody id="categoriesTable">
                                            
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <div class="card mb-2">
                            <div class="p-0 card-header btn-group bg-secondary d-flex">
                                <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#poductsCollapse" role="button" aria-expanded="false" style="padding:0.75rem 1.25rem;color:#3c4b64">
                                    <strong>List of product types</strong>
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-help-circle"><circle cx="12" cy="12" r="10"></circle><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"></path><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                </button>
                                <button type="button" class="btn btn-success" onclick="openProductTypeModal(null,false)" style="width: 200px; text-wrap:nowrap"> 
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-plus-circle mr-2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                                    Add Product Type
                                </button>
                            </div>
                            <div class="collapse border-0" id="poductsCollapse">
                                <div class="card-body d-flex">
                                    <table class="table table-hover" id="table-list-products">
                                        <thead class="thead-dark">
                                            <tr>
                                                <th scope="col">Name</th>
                                                <th scope="col">Templates</th>
                                                <th scope="col">Nb Attributes</th>
                                                <th scope="col">Nb Categories</th>
                                                <th scope="col">Nb Uses</th>
                                                <th scope="col">Last Changes</th>
                                                <th scope="col" style="width:150px">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody id="productsTable">
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>

            <%@ include file="/WEB-INF/include/footer.jsp" %>
        </div>
        <%@ include file="product_parameters_attributes.jsp" %>
        <%@ include file="product_parameters_categories.jsp" %>
        <%@ include file="product_parameters_product_types.jsp" %>
    </div>


<script type="text/javascript">

    $(function() {

        makeAtrDivs();
        drawCategoriesHtml();
        makeProductRows();
        
        $('#table-list-products tbody').tooltip({
            placement: 'bottom',
            html: true,
            selector: ".custom-tooltip"
        });       
    });

</script>
<script src="jquery.treegrid.js"></script>
</body>
</html>
