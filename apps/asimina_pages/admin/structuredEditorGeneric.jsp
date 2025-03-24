<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList,  java.util.List, java.util.HashMap , com.etn.pages.PagesUtil"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%!

    void copyJSONArray(JSONArray sourceArray, JSONArray destinationArray) {
        for (int i = 0; i < sourceArray.length(); i++) {
            destinationArray.put(sourceArray.get(i));
        }
    }

    JSONArray getPageProductFolders(Contexte Etn, String folderId, String catalogDb){
        JSONArray rspArray = new JSONArray();
        Set rs = Etn.execute("select uuid,name,parent_folder_id from "+catalogDb+"products_folders where id="+escape.cote(folderId));
        if(rs.next()){
            if(!rs.value("parent_folder_id").equals("0")){
                copyJSONArray(getPageProductFolders(Etn,rs.value("parent_folder_id"), catalogDb), rspArray);
            }
            JSONObject folderObj = new JSONObject();
            folderObj.put("uuid",rs.value("uuid"));
            folderObj.put("name",rs.value("name"));
            rspArray.put(folderObj);
        }   
        return rspArray;
    }
%>
<%

    final String STRUCTURED_CONTENT = "content";
    final String STRUCTURED_PAGE = "page";

    String catalogDb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".";

    String q = "";
    Set rs = null;

    String contentId = parseNull(request.getParameter("id"));
    String siteId  = getSiteId(session);
    boolean isLocked=false;
    String lockedMsg="";

    Set rsLockedPage2 = Etn.execute("select * from locked_items where item_id="+escape.cote(contentId)+" and item_type='structured' and site_id="+escape.cote(siteId)+
    " and is_locked=1 and locked_by!="+escape.cote(""+Etn.getId()));
    if(rsLockedPage2.next()){
        isLocked=true;

        Set rsPerson = Etn.execute("select * from person where person_id="+escape.cote(parseNull(rsLockedPage2.value("locked_by"))));
        if(rsPerson.next()){
            lockedMsg ="This page is currently being edited"+(parseNull(rsPerson.value("first_name")).length()>0?" by "+parseNull(rsPerson.value("first_name"))+" "+
                parseNull(rsPerson.value("last_name")):"")+" and it will not be available for editing until it is closed"+(parseNull(rsPerson.value("first_name")).length()>0?" by "+parseNull(rsPerson.value("first_name"))+" "+
                parseNull(rsPerson.value("last_name")):"."); 
        }
    }
    
    String backUrl = "structuredContents.jsp?";
    String folderType = Constant.FOLDER_TYPE_CONTENTS;
    String folderTable = getFolderTableName(folderType);
    String templateType = Constant.TEMPLATE_STRUCTURED_CONTENT;
    String editorUrl = "structuredContentEditor.jsp";
    boolean isPage = false;

    if(structureType.equals(STRUCTURED_PAGE)){
        editorUrl = "structuredPageEditor.jsp";
        isPage = true;
    }

    String folderId = "0";
    String folderName = "";
    String folderUuid = "";
    String parentFolderId = "";
    String parentFolderName = "";
    String folderRedirectUUID = "";
    String productId = "";
    String productUuid = "";
    String contentName = "";

    boolean invalidParams = false;

    Set contentRs = null;

    String pageTitle = "Edit structured "+structureType;
    if(contentId.length() > 0){
        q = "SELECT sc.id, sc.name, sc.folder_id, sc.publish_status, bt.type as template_type "
            + " , IF(ISNULL(sc.published_ts), 'danger' , IF(sc.updated_ts > sc.published_ts, 'warning' , 'success')) as ui_status  "
            + " FROM structured_contents as sc "
            + " JOIN bloc_templates bt ON bt.id = sc.template_id "
            + " WHERE sc.id = " + escape.cote(contentId)
            + " AND sc.site_id = " + escape.cote(siteId)
            + " AND sc.type = " + escape.cote(structureType);
        //Logger.debug(q);
        contentRs = Etn.execute(q);
        if(!contentRs.next()) invalidParams = true;

        contentName = contentRs.value("name");
        templateType = contentRs.value("template_type");
        
        if(templateType.equals(Constant.TEMPLATE_STORE)){
            folderType = Constant.FOLDER_TYPE_STORE;
            backUrl = "stores.jsp?";
        }else if(templateType.equals(Constant.TEMPLATE_STRUCTURED_PAGE)){
            folderType = Constant.FOLDER_TYPE_PAGES;
            backUrl = "pages.jsp?";
        }else if(templateType.contains("product")){
            Set rsProductOfPage = Etn.execute("select p.id,p.product_uuid from products_map_pages pmp left join "+catalogDb+"products p on p.id=pmp.product_id where pmp.page_id="+escape.cote(contentId));
            if(rsProductOfPage.next()) {
                productId= rsProductOfPage.value("id");
                productUuid= rsProductOfPage.value("product_uuid");
            }

            folderType = Constant.FOLDER_TYPE_STORE;
            backUrl = com.etn.beans.app.GlobalParm.getParm("CATALOG_ROOT")+"/admin/catalogs/v2/catalogs/catalogs.jsp";
            pageTitle = "Edit product page";
        }
        folderTable = getFolderTableName(folderType);

        folderId = contentRs.value("folder_id");
        if(parseInt(folderId) > 0){
            q = "SELECT f.id, f.name as folder_name, f.uuid, f.folder_level, IFNULL(pf.uuid,'') AS parent_folder_id, pf.name AS parent_folder_name "
            + " FROM " + folderTable + " f "
            + " LEFT JOIN " + folderTable + " pf ON pf.id = f.parent_folder_id "
            + " WHERE f.site_id = " + escape.cote(siteId)
            + " AND f.id = " + escape.cote(folderId);
            rs = Etn.execute(q);
            if(rs.next()){
                folderUuid = rs.value("uuid");
                folderName = parseNull(rs.value("folder_name"));
                parentFolderId = parseNull(rs.value("parent_folder_id"));
                parentFolderName = parseNull(rs.value("parent_folder_name"));
            }
        }
    }
    if (contentRs == null && (folderUuid = parseNull(request.getParameter("folderId"))).length() > 0) {
        q = "SELECT f.id, f.uuid, f.name as folder_name, f.folder_level,  IFNULL(pf.uuid,'') AS parent_folder_id, pf.name AS parent_folder_name "
            + " FROM " + folderTable + " f "
            + " LEFT JOIN " + folderTable + " pf ON pf.id = f.parent_folder_id "
            + " WHERE f.uuid = " + escape.cote(folderUuid)
            + " AND f.site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);
        if (rs.next()) {
            folderId = rs.value("id");
            folderUuid = rs.value("uuid");
            folderName = parseNull(rs.value("folder_name"));
            parentFolderId = parseNull(rs.value("parent_folder_id"));
            parentFolderName = parseNull(rs.value("parent_folder_name"));
        } else invalidParams = true;
    }
    if(folderUuid.length() > 0 && !templateType.contains("product")) backUrl += "&folderId="+ folderUuid;

    if(invalidParams) response.sendRedirect(backUrl);

    boolean active = true;
    List<Language> langsList = getLangs(Etn,siteId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp"%>
    <title><%=escapeCoteValue(pageTitle)%></title>


    <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
    <script src="<%=request.getContextPath()%>/ckeditor/adapters/jquery.js" defer></script>
    <script>
        CKEDITOR.timestamp = "" + parseInt(Math.random()*100000000);
    </script>

    <style type="text/css">

        .publish-status-circle{
            border-radius: 50%;
            height: 25px;
            width: 25px;
            border-radius: 50%;
            border: 1px solid rgb(221, 221, 221);
            display: inline-block;
            vertical-align: middle;
            margin-left: 15px;
        }

        .ui-datepicker.ui-widget{
            z-index: 2000 !important;
        }

        .locked {
            color: white;
            font-weight: bold;
            background-color: red;
            padding-left: 5px;
            padding-top: 4px;
        }

    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
     <%
        breadcrumbs.add(new String[]{"Content", ""});
        if(templateType.contains("product")){
            breadcrumbs.add(new String[]{"Products New", backUrl});
            Set rsProduct = Etn.execute("select folder_id from "+catalogDb+"products where id= (select product_id from products_map_pages where page_id="+escape.cote(contentId)+")");
            if(rsProduct.next() && !parseNull(rsProduct.value("folder_id")).isEmpty() && !rsProduct.value("folder_id").equals("0")){
                for(Object obj : getPageProductFolders(Etn,rsProduct.value("folder_id"),catalogDb)){
                    JSONObject folderObj = (JSONObject)obj;
                    breadcrumbs.add(new String[]{folderObj.getString("name"), backUrl+"?folderId="+folderObj.getString("uuid")});
                    folderRedirectUUID = folderObj.getString("uuid");
                }
            }
        }else{
            String baseScreenUrl = "pages.jsp";
            String baseScreenTitle = "Pages";

            if(structureType.equals(STRUCTURED_CONTENT)){
                baseScreenUrl = "structuredContents.jsp";
                baseScreenTitle = "Structured Data";
            } else{
                if(templateType.equals(Constant.TEMPLATE_STORE)){
                    baseScreenUrl = "stores.jsp";
                    baseScreenTitle = "Stores";
                }else if(templateType.equals(Constant.TEMPLATE_STRUCTURED_PAGE)){
                    baseScreenUrl = "pages.jsp";
                    baseScreenTitle = "Pages";
                }
            }
            breadcrumbs.add(new String[]{baseScreenTitle, baseScreenUrl});

            if(parentFolderId.length()>0){
                breadcrumbs.add(new String[]{parentFolderName, baseScreenUrl+"?folderId="+ parentFolderId});
            }
            if(folderUuid.length()>0){
                breadcrumbs.add(new String[]{folderName, baseScreenUrl+"?folderId="+folderUuid});
            }
            if(contentRs != null && contentRs.value("name").length()>0){
                breadcrumbs.add(new String[]{contentRs.value("name"), ""});
            }
        }

        if(!parseNull(folderRedirectUUID).isEmpty()){
            backUrl+="?folderId="+folderRedirectUUID;
        }
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <%
            if(isLocked){
        %>
            <span class="locked"><%=lockedMsg%></span>
        <%
            }
        %>
        <main class="c-main"  style="padding:0px 30px">
            <!-- beginning of container -->

                        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                            <%
                                String heading = "Add new " + structureType;
                                if(templateType.contains("product")) heading = "Add new product";
                                if(contentRs != null) heading = "Edit: " + contentRs.value("name");
                            %>
                            <div>
                                <h1 id="contentHeading" class="h2 float-left mr-3"><%=escapeCoteValue(heading)%></h1>
                                <div id="publishStatusDiv" class='bg-<%=contentRs!= null?contentRs.value("ui_status"): "success"%> float-left m-1 publish-status-circle'></div>
                            </div>

                            <div class="btn-toolbar mb-2 mb-md-0 flex-wrap flex-md-nowrap">
                                <button type="button" class="btn btn-warning mr-1" onclick="showErrorLogs('<%=escapeCoteValue(contentId)%>')">Recent Logs</button>
                                <button type="button" class="btn btn-primary mr-1" onclick="goBack('<%=escapeCoteValue(backUrl)%>')">Back</button>
                                <%if(!isLocked){%>
                                    <button class="btn btn-primary mr-1" type="button" onclick="onSaveStructuredContent()">Save</button>
                                <%}%>

                                <div id="publihsBtnDiv" class="d-none">
                                    <%
                                        if(isPage){
                                    %>
                                        <%
                                            if(!isLocked){
                                        %>
                                                <button class="btn btn-primary mr-2" title="Settings" onclick="editStructuredPageSettings('<%=contentId%>')">
                                                    <i data-feather="settings"></i>
                                                </button>
                                        <%
                                            }
                                        %>

                                        <button type="button" class='btn btn-warning mr-2 d-none unpublished publishedPreviewBtn' onclick="previewStructuredPage(true)" >
                                            Preview published
                                        </button>
                                        <button type="button" class="btn d-none d-md-inline btn-warning"  onclick='previewStructuredPage()'>Preview</button>
                                    <%
                                        }
                                        if(!isLocked){
                                    %>
                                            <div class="btn-group d-none d-md-inline mr-2">
                                                <button class="btn btn-danger" type="button" onclick="onPublishUnpublish('publish')">Publish</button>
                                                <button class="btn btn-danger" type="button" onclick="onPublishUnpublish('unpublish')">Unpublish</button>
                                            </div>

                                            <div class="btn-group mr-2">
                                                <button class="btn btn-danger dropdown-toggle d-block d-md-none" type="button" id="dropdownActionBtn" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Actions</button>
                                                <div class="dropdown-menu">
                                                    <a class="dropdown-item" onclick="onPublishUnpublish('publish')" href="#">Publish</a>
                                                    <a class="dropdown-item" onclick="onPublishUnpublish('unpublish')" href="#">Unpublish</a>
                                                    <div class="dropdown-divider"></div>
                                                    <a class="dropdown-item" onclick="previewStructuredPage(true)" href="#">Preview</a>
                                                    <a class="dropdown-item d-none unpublished publishedPreviewBtn" onclick="editStructuredPageSettings('<%=contentId%>')" href="#">Preview Published</a>
                                                </div>
                                            </div>
                                    <%
                                        }
                                    %>
                                </div>
                            </div>
                        </div>
                <div style=" user-select: auto;">
                        <div class="invalid-feedback" style="display:block;" id="errorMsgDiv" ></div>
                        <ul class="nav nav-tabs " id="langNavTabs" role="tablist">
                        <%
                            for (Language lang:langsList) {
                        %>
                            <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
                              <a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
                                id="langTab_<%=lang.getLanguageId()%>" data-toggle="tab" href="#langTabContent_<%=lang.getLanguageId()%>"
                                role="tab" aria-controls="<%=lang.getLanguage()%>" aria-selected="true"><%=lang.getLanguage()%></a>
                            </li>
                        <%
                                active = false;
                            }
                        %>
                        </ul>
                        <div class="tab-content p-3" id="flangTabContent">
                            <form id="mainForm" action="" method="POST" onsubmit="return false;" noValidate>
                                <input type="hidden" name="contentId" id="contentId" value='<%=contentId%>'>
                                <input type="hidden" name="uniqueIds" value="">
                                <input type="hidden" name="folderId" id="folderId" value='<%=folderId%>'>
                                <input type="hidden" name="folderType" id="folderType" value='<%=folderType%>'>
                                <input type="hidden" name="structureType" id="structureType" value='<%=structureType%>'>

                                <div class="">
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Name</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="contentName" id="contentName" class="form-control"
                                            value="<%=escapeCoteValue(contentName)%>" <%= templateType.contains("product") ? "readonly" : "" %> required="required" >
                                            <div class="invalid-feedback">Cannot be empty.</div>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Template</label>
                                        <div class="col-sm-9">
                                            <select id="contentTemplateId" name="template_id"
                                                    class="custom-select editDisabled" required=""
                                                    onChange="onChangeTemplate(this)">
                                                <option value=''>-- template --</option>
                                                <%
                                                    q = "SELECT id, name, custom_id FROM bloc_templates "
                                                        + " WHERE site_id = " + escape.cote(getSiteId(session))
                                                        + " AND type = " + escape.cote(templateType);
                                                    rs = Etn.execute(q);
                                                    while (rs.next()) {
                                                        String label = rs.value("name") + " (" + rs.value("custom_id") + ")";
                                                %>
                                                <option value='<%=rs.value("id")%>'><%=label%>
                                                </option>
                                                <%
                                                    }
                                                %>
                                            </select>
                                            <div class="invalid-feedback">
                                                Select a template.
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </form>
                            <%
                                active = true;
                                for (Language lang:langsList) {
                            %>
                                <div class='tab-pane langTabContent <%=(active)?"show active":""%>'
                                        id="langTabContent_<%=lang.getLanguageId()%>"
                                        role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                    <!-- templateSections -->
                                    <input type="hidden" id="page_id_<%=lang.getLanguageId()%>" name="page_id_<%=lang.getLanguageId()%>"  value="" />
                                    <form name="templateSectionsForm_<%=lang.getLanguageId()%>" class="langTemplateForm"
                                        action="" method="POST" onsubmit="return false;">
                                        <div class="langContent template_container bloc_section"
                                            id="langContent_<%=lang.getLanguageId()%>" data-lang-id="<%=lang.getLanguageId()%>" >

                                        </div>
                                    </form>
                                    <!-- /templateSections -->
                                </div>
                                <!-- tabContent -->
                            <%
                                    active =false;
                                }//for lang tab content
                            %>
                        </div>
                </div><!-- row -->


            <!-- container -->
            <!-- /end of container -->
        </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>

    <!-- Modals -->
    <%@ include file="blocsAddEdit.jsp" %>
    <%@ include file="pageSettingsAddEdit.jsp" %>
    <%-- <%@ include file="templateFunctions.jsp" %> --%>
    
    <%@ include file="structuredContentsPublish.jsp"%>
    <%@ include file="pagesPublish.jsp"%>

<script type="text/javascript">

    $ch.contextPath = '<%=request.getContextPath()%>/';
    $ch.structureType = '<%=structureType%>';

    productId = "<%=productId%>".length>0?"<%=productId%>":"";
    productUuid = "<%=productUuid%>".length>0?"<%=productUuid%>":"";

    window.IMAGE_URL_PREPEND = '<%=getImageURLPrepend(getSiteId(session))%>';
    window.allTagsList = <%=getAllTagsJSON(Etn, getSiteId(session), GlobalParm.getParm("CATALOG_DB") )%>;
    // ready function
    $(function () {
        $ch.langContentDivs = $("#flangTabContent").find(".langContent") ;

        var contentId = $('#contentId').val();

        if (contentId.length > 0) {
            loadContentData();
            $('#publihsBtnDiv').removeClass("d-none");
        }

        sendAjaxRequest();
        feather.replace();

    });

    function sendAjaxRequest() {
        $.ajax({
            url : 'pagesAjax.jsp', type : 'POST', dataType : 'json',
            data: {
                requestType : "manageLocks",
                pageType : "structured",
                pageId : '<%=contentId%>',
            },
        }).done(function (resp) {
            var lockedElement = document.querySelector('.locked');
            if (lockedElement) {
                if(resp.data.rsp==0){
                    lockedElement.style.display = 'none';
                    window.location.reload();
                }else if(resp.data.rsp==1){
                    lockedElement.style.display = 'true';
                }else if(resp.data.rsp==2){
                    lockedElement.style.display = 'none';
                }
            }
        });
        setTimeout(sendAjaxRequest,30000);
    }

    function loadContentData(){
        var contentId = $('#contentId').val();
        var folderId = $('#folderId').val();
        var structureType = $('#structureType').val();

        if(contentId.length === 0) return false;

        $('.editDisabled').prop('disabled',true);

        showLoader();
        $.ajax({
            url : 'structuredContentsAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'getContentDetail',
                contentId : contentId,
                // folderId : folderId,
                // structureType : structureType,
            },
        })
        .done(function (resp) {
            var data = [];
            if (resp.status == 1) {
                var content = resp.data.content;
                var form = $('#mainForm');
                form.find('[name=name]').val(content.name);
                form.find('[name=template_id]').val(content.template_id);

                $ch.templateCode = content.template_code;
                var contentDetailList = content.template_data;
                generateStructuredContentForm($ch.templateCode, contentDetailList,content.attributes,content.specification,content.name);
            }
            else {
                bootNotifyError("Error in loading content template and data. Please try again.");
            }
        })
        .fail(function () {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function () {
            hideLoader();
        });
    }

    /* deprecated */
    function initContentEditor() {
        var catalogId = $('#catalogId').val();
        var contentId = $('#contentId').val();

        showLoader();
        $.ajax({
            url : 'structuredContentsAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'getContentDetail',
                folderId : '<%=folderId%>',
                contentId : '<%=contentId%>',
            },
        })
        .done(function (resp) {
            var data = [];
            if (resp.status == 1) {
                var templateCode = resp.data.content.template_code;
                var contentDetailList = resp.data.content.templsate_data;

                $ch.templateCode = templateCode;
                generateStructuredContentForm(templateCode, contentDetailList);
            }
            else {
                bootNotifyError("Error in loading content template and data. Please try again.");
            }
        })
        .fail(function () {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function () {
            hideLoader();
        });

    }

    function onSaveStructuredContent(pagesSaved) {
        var form = $("#mainForm");
        form.removeClass('was-validated');
        var errorMsgDiv = $("#errorMsgDiv");
        errorMsgDiv.html("");
        if (!form.get(0).checkValidity()) {
            form.addClass('was-validated');
            return false;
        }
        else if (!verifyAllLanguageTemplateData()) {
            return false;
        }
        
        var contentId = $('#contentId').val();
        var templateId = $("#contentTemplateId").val();
        var folderId = $("#folderId").val();
        var name = $("#contentName").val();
        var folderType = '<%=folderType%>';

        var uniqueIds = [];
        $.each($('.langTemplateForm > div:first').find(".uniqueId"),function (index, el) {
            var uniqueId = $(el).val().trim();
            if (uniqueId.length > 0 && uniqueIds.indexOf(uniqueId) < 0) {
                uniqueIds.push(uniqueId);
            }
        });

        var data = {
            requestType : "saveContent",
            id : contentId,
            folderId : folderId,
            templateId : templateId,
            name : name,
            structureType : $ch.structureType,
            folderType : folderType,
            uniqueIds : uniqueIds.join('$')
        };

        var langContentDivs = $("#flangTabContent").find(".langContent");

        let isInvalid = false;

        langContentDivs.each(function (index, langContent) {
            langContent = $(langContent);
            var langId = langContent.attr("data-lang-id");
            data['page_id_'+langId] = $('#page_id_'+langId).val();
            var templateData = generateTemplateData(langContent);
            data["contentDetailData_" + langId] = JSON.stringify(templateData);
            let blocFieldIds = [];
            $.each(langContent.find(".requiredInput.image_card"),function(idx, el) {
                updateFieldImageRequiredStatusV2($(el));
            });            
            if(langContent.find(".requiredInput").hasClass("border-danger")) {
                isInvalid = true;
                bootNotifyError("Image field Required for lang :: "+$("#langTab_"+langId).attr("aria-controls"));
            }
            langContent.find(".bloc-id").each(function(idx, el){       
                blocFieldIds.push($(el).val());
            });
            data["blocIds_"+langId] = blocFieldIds.join(",");
        });

        if(isInvalid) return false;

        showLoader();
        $.ajax({
            url : 'structuredContentsAjax.jsp', type : 'POST', dataType : 'json',
            data : data,
        })
        .done(function (resp) {
            if (resp.status == 1) {
                $('#publihsBtnDiv').removeClass("d-none");
                $('#contentId').val(resp.data.id);
                $('#contentHeading').html("Edit: " + name);

                if('<%=templateType%>'.includes("product")){
                    let msg = "Product saved";
                    if(contentId) msg = "Product updated";
                    bootNotify(msg);
                    setTimeout(function() {
                        window.location.href = window.location.href;
                    }, 1000);
                } 
                else bootNotify(resp.message);
            }
            else {
                $("#errorMsgDiv").html(resp.message);
            }
        })
        .fail(function () {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function () {
            hideLoader();
        });
    }

    function verifyAllLanguageTemplateData() {
        var isAllValid = true;

        var langContentDivs = $(".langContent");
        langContentDivs.each(function (index, langContent) {

            langContent = $(langContent);
            var langId = langContent.attr("data-lang-id");
            var langTab = $('#langTab_' + langId);
            var langName = langTab.text();
            var form = langContent.parents('form.langTemplateForm:first');

            var errorFields = [];
            //custom check for special fields like ckeditor
            form.find('.requiredInput').trigger('checkRequired');

            if (!form.get(0).checkValidity()) {
                var invalidFields = form.find(':invalid');
                if (invalidFields.length > 0) {
                    var errorMsg = "Error: Some required fields are empty for language " + langName;
                    bootNotifyError(errorMsg);
                    errorFields = errorFields.concat(invalidFields.toArray());
                }
            }

            var invalidFields = langContent.find('.is-invalid');
            if (invalidFields.length > 0) {
                var errorMsg = "Error: " + invalidFields.length
                    + " field(s) have invalid values for language " + langName;
                bootNotifyError(errorMsg);
                errorFields = errorFields.concat(invalidFields.toArray());
            }

            if (errorFields.length > 0) {
                if (isAllValid) {
                    //switch to tab of first error
                    langTab.trigger('click');
                    focusOnErrorField(errorFields, langContent);
                }

                isAllValid = false;
            }

        });
        return isAllValid;
    }

    //overriding function from structuredContentPublish.jsp
    function onPublishUnpublish(action, isLogin) {

        if (typeof isLogin == 'undefined' || !isLogin) checkPublishLogin(action);
        else {
            var folderType = $('#folderType').val();
            var itemType = "structured data";

            if(folderType == '<%=Constant.FOLDER_TYPE_STORE%>'){
                itemType = "store";
            }else if(folderType == '<%=Constant.FOLDER_TYPE_PAGES%>'){
                itemType = "strucutred page";
            }
            var msg = "Are you sure you want to " + action + " this " + itemType + "?";
            if($ch.structureType == "content") {
                bootConfirm(msg, function (result) {
                    if (result) {
                        var contentIds = [];
                        contentIds.push($('#contentId').val());
                        publishUnpublishContents(contentIds, action);
                    }
                });
            }
            else{
                var structuredPages = [];
                structuredPages.push({id:$('#contentId').val(), type:"structured"});
                publishUnpublishPages(structuredPages, action, "now")
            }
        }
    }

    function getPageSettingsData() {

        var retData = [];

        var langPageSettings = $('div.langPageSettings');

        langPageSettings.each(function (index, el) {
            var curPs = $(el);
            var curLangId = curPs.attr("data-lang-id");
            var curData = [];
            var formDataArray = curPs.find('form:first').serializeArray();

            var curData = $.map(formDataArray, function (item, index) {
                return {
                    name : item.name + "_" + curLangId,
                    value : item.value
                };
            });

            retData = retData.concat(curData);
        });

        return retData;
    }

    function refreshPublishUnpublishStatus(action, responseStatus) {
        var status = "warning";
        if(action === "publish"){
            status = "success";
        }
        if(action === "unpublish"){
            status = "danger";
        }

        if (responseStatus == 1) {
            var pubStatusDiv = $("#publishStatusDiv");
            pubStatusDiv.removeClass('bg-success bg-danger bg-warning');
            pubStatusDiv.addClass('bg-' + status);

            var publishedPreviewBtn = $(".publishedPreviewBtn");
            publishedPreviewBtn.removeClass('published unpublished changed');
            publishedPreviewBtn.addClass(action + "ed");
        }
    }

    function onChangeTemplate(select) {

        if ($('#contentId').val().length > 0) {
            return;
        }

        var templateId = $(select).val();

        if (templateId.length === 0) {
            $ch.langContentDivs.html('');
        }

        showLoader();
        $.ajax({
            url : 'blocTemplatesAjax.jsp', type : 'POST', dataType : 'json',
            data : {
                requestType : 'getTemplateSectionsData',
                template_id : templateId,
            },
        })
        .done(function (resp) {
            if (resp.status == 1) {
                var templateCode = {
                    sections : resp.data.sections
                };
                generateStructuredContentForm(templateCode, []);
            }
            else {
                bootNotifyError("Error in loading template sections data. Please try again.");
            }
        })
        .fail(function () {
            bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function () {
            hideLoader();
        });

    }

    function addBlurEvent(inputElement,langId,sectionNum) {
        $(inputElement).on('blur', function() {
            var targetName = $(this).attr('name');
            var targetValue = $(this).val();
            let thisEleLabel = $(this).closest('div').parent('div').siblings('label').text();
            
            if(!sectionNum){
                var elementsWithSameName = $("input[name='" + targetName + "'], select[name='" + targetName + "']");
                if(targetName=="product_general_informations.product_attributes"){
                    elementsWithSameName.each(function() {
                        let currentFieldLabel = $(this).closest('div').parent('div').siblings('label').text();
                        if(thisEleLabel==currentFieldLabel) $(this).val(targetValue);
                    });
                }else elementsWithSameName.val(targetValue);
            }else{
                var langContentDivs = $ch.langContentDivs;
                langContentDivs.each(function (indexLang, langContent) {
                    langContent = $(langContent);
                    var curLangId = langContent.attr("data-lang-id");
                    if(langId != curLangId){
                        let inputsAndSelects = document.getElementById("langContent_" + curLangId + ".section_product_variants_1.section_product_variants_variant_x_" + sectionNum)
                            .querySelectorAll("input[name='" + targetName + "'], select[name='" + targetName + "']");

                        inputsAndSelects.forEach(element => {
                            if(targetName=="product_variants_variant_x.product_variants_variant_x_attributes"){
                                let currentFieldLabel = $(element).closest('div').parent('div').siblings('label').text();
                                if(thisEleLabel==currentFieldLabel) element.value = targetValue;
                            }else{
                                element.value = targetValue;
                            }
                        });
                    }
                });

            }
        });
    }

    function addClassToInputs(langId,inputName,sectionNum){
        let inputsOfGivenName = $("#langTabContent_" + langId + " input[name='" + inputName + "'], #langTabContent_" + langId + " select[name='" + inputName + "']");
        inputsOfGivenName.each(function() {
            if (!$(this).hasClass("copyToOtherLang")) $(this).addClass("copyToOtherLang");
            
            if (!$._data(this, "events") || !$._data(this, "events").blur) addBlurEvent(this,langId,sectionNum);
        });
    }

    function disableOtherlangInputs(langId,inputName){
        let inputsAndSelects = $("#langTabContent_" + langId + " input[name='" + inputName + "'], #langTabContent_" + langId + " select[name='" + inputName + "']");
        inputsAndSelects.each(function() {
            if ($(this).is('input')) {
                if (!$(this).prop("readonly")) {
                    $(this).prop("readonly", true);
                }
            } else if ($(this).is('select')) {
                if (!$(this).prop("disabled")) {
                    $(this).prop("disabled", true);
                }
            }
        });

    }

    function generateStructuredContentForm(templateCode, contentDetailList,attributes,specification,productName) {
        var langContentDivs = $ch.langContentDivs;

        langContentDivs.html('');

        var sections = templateCode.sections;
        if (!sections || sections.length == 0) {
            langContentDivs.append("<span class='text-danger'>No template fields defined</span>");
            return false;
        }

        $ch.loadingBlocData = true;

        langContentDivs.each(function (indexLang, langContent) {
            langContent = $(langContent);
            var curLangId = langContent.attr("data-lang-id");

            $.each(sections, function (index, secCode) {
                var sectionDiv = generateSectionContainer(secCode, langContent, curLangId,attributes,specification);
                $.each(contentDetailList, function (i, contentDetailObj) {
                    if (contentDetailObj.langue_id == curLangId) {
                        try {
                            $('#page_id_'+curLangId).val(contentDetailObj.page_id);
                            var templateDataObj = JSON.parse(contentDetailObj.content_data);

                            //now filling form with existing data
                            fillBlocData(templateDataObj, sectionDiv,productName);
                        } catch (ex) {
                            console.log(ex);
                        }
                        return false;
                    }
                });
            });

            if(indexLang==0){
                addClassToInputs(curLangId,'product_general_informations.product_general_informations_manufacturer');
                addClassToInputs(curLangId,'product_general_informations.product_general_informations_ean');
                addClassToInputs(curLangId,'product_general_informations.product_general_informations_sku');
                addClassToInputs(curLangId,'product_general_informations.product_general_informations_price_price');
                addClassToInputs(curLangId,'product_general_informations.product_general_informations_price_frequency');
                addClassToInputs(curLangId,'product_general_informations.product_attributes');
            }else{
                disableOtherlangInputs(curLangId,'product_general_informations.product_general_informations_manufacturer');
                disableOtherlangInputs(curLangId,'product_general_informations.product_general_informations_ean');
                disableOtherlangInputs(curLangId,'product_general_informations.product_general_informations_sku');
                disableOtherlangInputs(curLangId,'product_general_informations.product_general_informations_price_price');
                disableOtherlangInputs(curLangId,'product_general_informations.product_general_informations_price_frequency');
                disableOtherlangInputs(curLangId,'product_general_informations.product_general_informations_tags');
                disableOtherlangInputs(curLangId,'product_general_informations.product_attributes');
                
                disableOtherlangInputs(curLangId,'product_variants_variant_x.product_variants_variant_x_ean');
                disableOtherlangInputs(curLangId,'product_variants_variant_x.product_variants_variant_x_sku');
                disableOtherlangInputs(curLangId,'product_variants_variant_x.product_variants_variant_x_price_price');
                disableOtherlangInputs(curLangId,'product_variants_variant_x.product_variants_variant_x_price_frequency');
                disableOtherlangInputs(curLangId,'product_variants_variant_x.product_variants_variant_x_tags');
                disableOtherlangInputs(curLangId,'product_variants_variant_x.product_variants_variant_x_attributes');

                let otherLangSectionId = "langContent_"+curLangId+".section_product_variants_1.section_product_variants_variant_x";
                let addSectionBtn = document.getElementById(otherLangSectionId);
                if(addSectionBtn) {
                    addSectionBtn = addSectionBtn.querySelector(".add_section");
                    if(addSectionBtn) addSectionBtn.remove();
                }
            }

            $(".selectDiv").on("input",".autocomplete_input",function(){
                let value = $(this).val();
                let selectDiv = $(this).closest('.selectDiv');
                let autocompleteList = selectDiv.find(".autocomplete-items");
                if(value.length>1){
                    autocompleteList.show();
                    $.each(autocompleteList.find("li"),function(idx,element){
                        if(element.textContent.toLowerCase().includes(value.toLowerCase())) $(element).show();
                        else $(element).hide();
                    });
                }else{
                    autocompleteList.hide();
                }
            });

            $(".selectDiv").on('mousedown','.autocomplete-item',function(){
                $(this).closest('.selectDiv').find('.autocomplete_input').val($(this).text());
                $(this).closest('.selectDiv').find('select').val($(this).attr('value'));
            });

            $(".selectDiv").on('blur','.autocomplete_input',function(){
                $(this).closest('.selectDiv').find(".autocomplete-items").hide();
            });

            $('.uniqueId').on('blur',function(){
                let ele = $(this);
                if($(ele).prop("readonly")) return;
                
                let templateId = $('[name="template_id"]').val();
                let contentId = $('#contentId').val();
                
                if(ele.val().length>0){
                    ele.val().replace("$",'');

                    var uniqueIds = [];
                    $.each($('.langTemplateForm > div:first').find(".uniqueId"),function (index, el) {
                        var uniqueId = $(el).val().trim();
                        if (uniqueId.length > 0 && uniqueIds.indexOf(uniqueId) < 0) {
                            uniqueIds.push(uniqueId);
                        }
                    });
                    $.ajax({
                        url: 'blocsAjax.jsp',
                        dataType: 'json',
                        data: {
                            requestType : "checkUniqueId",
                            id : uniqueIds.join('$'),
                            templateId: templateId,
                            blocId : contentId,
                            pageType : "struct",
                        },
                    })
                    .done(function(resp) {
                        let value = "";
                        let className = "";
                        if(resp.status == '0'){
                            value = "";
                            className = "is-invalid";
                            bootNotifyError("Id is not unique.");
                        }else{
                            value = ele.val();
                            className = "";
                        }
                        let langId = ele.closest(".langContent").data("langId");
                        langContentDivs.each(function(idx,langContentDiv){
                            let sectionId = ele.closest(".bloc_section").attr("id").replace("blocLangContent_"+langId,"blocLangContent_"+$(langContentDiv).data("langId"));
                            try {
                                let element = $(langContentDiv).find("[id='"+sectionId+"']").find("[name='"+ele.attr("name")+"']");
                                element.val(value);
                                if(className.length>0) element.addClass(className);    
                            } catch (error) {
                                return;
                        }
                    });
                    });

                }else {
                    let langId = ele.closest(".langContent").data("langId");
                    langContentDivs.each(function(idx,langContentDiv){
                        let sectionId = ele.closest(".bloc_section").attr("id").replace("blocLangContent_"+langId,"blocLangContent_"+$(langContentDiv).data("langId"));
                        try {
                            let element = $(langContentDiv).find("[id='"+sectionId+"']").find("[name='"+ele.attr("name")+"']");
                            element.val(ele.val());
                        } catch (error) {
                            return;
                        }
                    });
                }
            });
        });

        showLoader();
        jQuery(langContentDivs).find(".ckeditorField").ckeditor({
            filebrowserImageBrowseUrl : "imageBrowser.jsp?popup=1",
            extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
            colorButton_enableMore : true,
            colorButton_enableAutomatic : false,
            allowedContent: true,
            contentsCss: '<%=request.getContextPath()%>/css/bootstrap.min.css',
            colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
        }, onFieldCkeditorReady);

        $ch.loadingBlocData = false;
    }

    function previewStructuredPage(publishedPreview) {

        var langId = $("#langNavTabs .active:first").attr("data-lang-id");
        var pageId = $("#page_id_" + langId).val();
        if(parseInt(pageId) > 0){
            var url = "pagePreview.jsp?id=" + pageId + '&rand=' + getRandomInt(1000000);
            var windowName = "structuredPagePreview_" + pageId;
            if (publishedPreview) {
                url += "&published=1";
                windowName += "published";
            }
            var win = window.open(url, windowName);
            win.focus();
        }else{
            bootNotify("Page not exist");
        }

    }

    function showErrorLogs(id){
        $.ajax({
            url: 'blocsAjax.jsp',
            dataType: 'json',
            type:'POST',
            data: {
                requestType : "fetchPageLogs",
                id : id,
                pageType: "structured",
            },
        }).always(function (resp) {
            if(resp.status === 1) {
                bootbox.alert({
                    message : resp.message,
                    size : 'large',
                    title : "Generate Logs"
                });
            } else{
                bootbox.alert({
                    message : resp.message,
                    size : 'large',
                    title : "Error"
                });
            }
        });
    }

</script>
    </body>
</html>