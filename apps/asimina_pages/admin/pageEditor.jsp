<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList,java.util.List,java.util.Base64 "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>

<%!
    JSONArray foldersHirarchy(String folderUuid, String siteId,Contexte Etn){

        JSONArray folders = new JSONArray();
        JSONObject parentObj = new JSONObject();

        String query = "SELECT f.name, f.uuid, IFNULL(pf.uuid,'') AS parent_folder_id "
            + " FROM pages_folders f "
            + " LEFT JOIN pages_folders pf ON pf.id = f.parent_folder_id "
            + " WHERE f.uuid = " + escape.cote(folderUuid)
            + " AND f.site_id = " + escape.cote(siteId);
        Set rs = Etn.execute(query);
        if (rs.next()) {
            
            parentObj.put("name", parseNull(rs.value("name")));
            parentObj.put("uuid", parseNull(rs.value("uuid")));

            if(parseNull(rs.value("parent_folder_id")).length() > 0) {
                folders=foldersHirarchy(parseNull(rs.value("parent_folder_id")),siteId,Etn);
            }
            folders.put(parentObj);
        }
        return folders;
    }
%>

<%
	String pageId = parseNull(request.getParameter("id"));
    String siteId = getSiteId(session);
    boolean isLocked=false;
    String lockedMsg="";

    Set rsLockedPage2 = Etn.execute("select * from locked_items where item_id="+escape.cote(pageId)+" and item_type='freemarker' and site_id="+escape.cote(siteId)+
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
    

    String folderType = Constant.FOLDER_TYPE_PAGES;
	String folderUuid = parseNull(request.getParameter("folderId"));
    String backUrl = "pages.jsp";
    String q = null;
	Set rs = null;
    JSONArray foldersarray = new JSONArray();

    q = "SELECT pp.name, p.id as page_id, p.html_file_path, p.type, pp.folder_id, p.langue_code "
        + "  , IF(ISNULL(pp.published_ts), 'danger' , IF(pp.updated_ts > pp.published_ts, 'warning' , 'success')) as ui_status, "
        + "  f.uuid as folder_uuid, f.name as folder_name,  IFNULL(pf.uuid,'') AS parent_folder_id, pf.name AS parent_folder_name  "
        + " FROM freemarker_pages pp"
        + " JOIN pages p ON p.parent_page_id = pp.id"
        + " LEFT JOIN pages_folders f ON f.id = p.folder_id "
        + " LEFT JOIN pages_folders pf ON pf.id = f.parent_folder_id "
        + " WHERE pp.id = " + escape.cote(pageId)
        + " AND pp.site_id = " + escape.cote(getSiteId(session))
        + " AND  pp.is_deleted = '0'"
        + " AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER);
	rs = Etn.execute(q);
    boolean invalidPageId = false;

    HashMap<String, String> pages = new HashMap<>();
    while(rs.next()){
        pages.put(rs.value("langue_code"), rs.value("page_id"));
    }
    String folderName = parseNull(rs.value("folder_name"));
    String parentFolderId = parseNull(rs.value("parent_folder_id"));
    String parentFolderName = parseNull(rs.value("parent_folder_name"));
    String folderId = parseNull(rs.value("folder_id"));
    String templateType = Constant.TEMPLATE_STRUCTURED_PAGE;
    boolean active = true;
    List<Language> langsList = getLangs(Etn,session);
    
    Set rsFolder = Etn.execute("select * from folders_tbl where id="+escape.cote(rs.value("folder_id")));
    if(rsFolder.next()){
        foldersarray=foldersHirarchy(rsFolder.value("uuid"),siteId,Etn);
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Page : <%=rs.value("name")%></title>
        
        <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
        <script src="<%=request.getContextPath()%>/ckeditor/adapters/jquery.js"></script>
        <script>
            CKEDITOR.timestamp = "" + parseInt(Math.random()*100000000);
        </script>

        <style type="text/css">
            .ui-datepicker.ui-widget{
                z-index: 2000 !important;
            }

            .publish-status-circle{
                border-radius: 50%;
                height: 25px;
                width: 25px;
                border-radius: 50%;
                border: 1px solid rgb(221, 221, 221);
                display: inline-block;
                vertical-align: middle;
                margin-left: 25px;
            }
            .langTabContent {
                padding-top: 20px;
                padding-bottom: 20px;
                min-height: 100px;
            }
            .pagePreviewIframe{
                width: 100%;
                height: 100%;
                border: none;
                padding-left: 15px;
                padding-right: 15px;
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
                breadcrumbs.add(new String[]{"Pages", "pages.jsp"});
                if(parentFolderId.length()>0){
                    String folderTemp="";
                    for (int i = 0; i < foldersarray.length(); i++) {
                        JSONObject obj = foldersarray.getJSONObject(i);
                        breadcrumbs.add(new String[]{obj.getString("name"), "pages.jsp?folderId="+ obj.getString("uuid")});
                        folderTemp=obj.getString("uuid");
                    }
                    backUrl += "?folderId="+folderTemp;
                }
                if(folderUuid.length()>0){
                    breadcrumbs.add(new String[]{folderName, "pages.jsp?folderId="+folderUuid});
                }
                breadcrumbs.add(new String[]{rs.value("name"), ""});

            %>
            <div class="c-body">
                <%@ include file="/WEB-INF/include/header.jsp" %>
                <%
                    if(isLocked){
                %>
                    <span class="locked"><%=lockedMsg%></span>
                <%
                    }
                %>
                <main class="c-main">
                    <!-- beginning of container -->
                    <div class="container-fluid">
                        <form action="" onsubmit="return false">
                            <input type="hidden" name="pageId" id="pageId" value='<%=pageId%>'>
                        </form>

                        <div class="row">
                            <div class="col-12">
                                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                                    <div class="d-flex align-items-center">
                                        <h1 class="h2 mr-3">Page : <span id="pageNameHeading" ><%=rs.value("name")%></span></h1>
                                        <div id="publishStatusDiv" class=" bg-<%=rs.value("ui_status")%> float-left m-1 publish-status-circle"></div>
                                    </div>
                                    <div class="btn-toolbar mb-2 mb-md-0">
                                        <%
                                            if(!isLocked){
                                        %>
                                        
                                        <button class="btn btn-success mr-1" type="button"
                                            data-toggle="modal" data-target="#modalAddNewBloc"
                                            data-caller="add" >Add a bloc</button>

                                        <button class="btn btn-success mr-1" type="button"
                                            data-toggle="modal" data-target="#modalExistingBlocs"
                                            onclick="">List of blocs</button>

                                        <div class="btn-group mr-2">
                                            <button class="btn btn-danger" type="button"
                                            onclick="onPublishUnpublish('publish')">Publish</button>
                                            <button class="btn btn-danger" type="button"
                                            onclick="onPublishUnpublish('unpublish')">Unpublish</button>
                                        </div>
                                    <%
                                        }
                                    %>
                                        <div class="btn-group mr-2"  id="previewBtn" >
                                            <button type="button" class="btn btn-warning"  onclick='onPageEditorPreview()'>Preview</button>
                                        </div>
                                        <div class="btn-group mr-1">
                                            <button class="btn btn-warning" type="button" onclick="showErrorLogs('<%=escapeCoteValue(pageId)%>');">Recent Logs</button>
                                            <button class="btn btn-primary" type="button" onclick="goBack('<%=escapeCoteValue(backUrl)%>');">Back</button>
                                            <%
                                                if(!isLocked){
                                            %>
                                            <button class="btn btn-primary" id="save-btn" type="button" style="display: none;"
                                                onclick="onPageEditorSave()" >save</button>
                                            <%
                                                }
                                            %>
                                        </div>

                                        <%
                                            if(!isLocked){
                                        %>
                                        <button class="btn btn-sm btn-primary "
                                            onclick='editPageSettings("<%=pageId%>", false)'>
                                            <i data-feather="settings"></i></button>
                                        <%
                                            }
                                        %>
                                    </div>
                                </div>
                            </div>
                        </div><!-- row -->

                        <ul class="nav nav-tabs page_preview_lang_tabs" id="langNavTabs" role="tablist">
                            <%
                                for (Language lang: langsList ) {
                                    
                            %>
                                <li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>" data-lang-code ="<%=lang.getCode()%>" >
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

                        <%
                            active = true;
                            for (Language lang: langsList) {
                        %>
                            <input type="hidden" id="page_editor_lang_<%=lang.getLanguageId()%>" value="<%=pages.get(lang.getCode())%>">
                            <div class='tab-pane langTabContent <%=(active)?"show active":""%>'
                                        id="langTabContent_<%=lang.getLanguageId()%>"
                                        role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
                                <div class="row">
                                    <div class="col-12 m-0 py-0 pr-0" style="padding-left:5px;">
                                        <div class=" embed-responsive iframeParent" style="min-height:70px" id="iframeParent_<%=lang.getLanguageId()%>">
                                            <iframe scrolling="no" class="pagePreviewIframe" data-lang-id="<%=lang.getLanguageId()%>" id="pagePreviewIframe_lang_<%=lang.getLanguageId()%>" src="" ></iframe>
                                        </div>
                                    </div>
                                </div>
                                <div class="row d-none">
                                <div class="blocEditDiv" >
                                    <div class="bloc_edit_bg">
                                        <%
                                            if(!isLocked){
                                        %>
                                        <div class="bloc_edit_buttons" style="">
                                            <span class="p-3 " style="font-weight: bold;">
                                                Bloc : <span class="blocName"></span>
                                            </span>
                                            <button type="button" class="boot-btn boot-btn-primary btnUp"
                                                style="margin-right: .10rem;"
                                                onclick="window.parent.pageBlocMove(this,'up')">
                                                <i data-feather="arrow-up"></i>
                                            </button>
                                            <button type="button" class="boot-btn boot-btn-primary btnDown"
                                                style="margin-right: .10rem;"
                                                onclick="window.parent.pageBlocMove(this,'down')">
                                                <i data-feather="arrow-down"></i>
                                            </button>
                                            <button type="button" class="boot-btn boot-btn-primary btnEdit"
                                                style="margin-right: .10rem;"
                                                onclick="window.parent.pageBlocEdit(this)">
                                                <i data-feather="edit"></i>
                                            </button>
                                            <button type="button" class="boot-btn boot-btn-danger btnDelete"
                                                style="margin-right: .1rem;"
                                                onclick="window.parent.pageBlocDelete(this)">
                                                <i data-feather="x-square"></i>
                                            </button>
                                        </div>
                                        <%}%>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                active =false;
                            }
                        %>

                        </div><!-- hidden row-->

                    </div>
                    <!-- /end of container -->
                </main>
            </div>
            <%@ include file="/WEB-INF/include/footer.jsp" %>
        </div>

        <%
            String screenType = Constant.SCREEN_TYPE_BLOCKS;
        %>
        <%@ include file="blocsAddEdit.jsp"%>

        <%@ include file="pageSettingsAddEdit.jsp"%>
        <%@ include file="pagesPublish.jsp"%>
        <div class="d-none">
            <button type="button" id="dummyEditBlocBtn"
                    class="btn btn-sm btn-primary "
                    data-caller="edit" data-bloc-id='' data-template='dummy'
                    onclick="openAddEditBloc(this);">
                    <i data-feather="edit"></i></button>
        </div>

<script type="text/javascript">

    $ch.isPageEditor = true;
    $ch.pageFrame = null;
    $ch.pageFrameWidth = 0;
    $ch.pageFrameHeight = 0;

    // ready function
    $(document).ready(function() {
        
        $('.page_preview_lang_tabs > li > a').on("click",function(e){
            e.preventDefault();
            refreshPagePreview($(this).attr("data-lang-id"));
        });

	  $('.pagePreviewIframe').bind('load', function(e) { //binds the event
		resizeIframe(e.target)
		var _thatFrame = e.target;
		//due to some dynamic data loading we have to recalculate the iframe size
		setTimeout(function(){ resizeIframe(_thatFrame); }, 2000);
        });

        var langId = $("#langNavTabs li a.active").attr("data-lang-id");
        var pageId =  $('#page_editor_lang_'+langId).val();

        var url = getPagePreviewUrl(pageId);

        $('#pagePreviewIframe_lang_'+langId).attr("src", url);
        $ch.pageChanged = false;

        $('button.navbar-toggler.sidebar-toggler').click(function(){
            setTimeout(resizeIframe,500);
        });
        $('button.sidebar-minimizer.brand-minimizer').click(function(){
            setTimeout(resizeIframe,500);
        });
        sendAjaxRequest();
    });

    $(".pagePreviewIframe").on("load",function(){
        setTimeout(function(){$("#save-btn").show()},1000);
    });

    function sendAjaxRequest() {
        $.ajax({
            url : 'pagesAjax.jsp', type : 'POST', dataType : 'json',
            data: {
                requestType : "manageLocks",
                pageType : "freemarker",
                pageId : '<%=pageId%>',
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

    
    function resizeIframe(iframe) {
	  if(!iframe){
	  	var langId = $("#langNavTabs li a.active").attr("data-lang-id");
		iframe = document.getElementById('pagePreviewIframe_lang_'+langId);
	  }
        iframe.style.height = iframe.contentWindow.document.body.scrollHeight + "px";
        iframe.parentNode.style.height = iframe.contentWindow.document.body.scrollHeight + "px";
    }
    
    function getPagePreviewUrl(id){
        if(!id){
            id  = 0;
        }
        return 'preview.jsp?id='+id+'&editor=1&rand='+getRandomInt(1000000);
    }

    function onPageEditorSave(confirmed){

        if(!confirmed){
            bootConfirm("Are you sure?",function(result){
                if(result){
                    onPageEditorSave(true);
                }
            });
            return false;
        }

        var pageId = $('#pageId').val();
        var blocIds = getPageBlocIds();

        showLoader();
        $.ajax({
            url: 'pagesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : "savePageBlocs",
                pageId : pageId,
                blocIds : blocIds.join(','),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                bootNotify("Page saved.");
                var langId = $("#langNavTabs li a.active").attr("data-lang-id");
                var pageId =  $('#page_editor_lang_'+langId).val();
                var url = getPagePreviewUrl(pageId);
                $('#pagePreviewIframe_lang_'+langId).attr("src", url);
                $ch.pageChanged = false;
            }
            else{
                alert(resp.message);
            }
        })
        .fail(function() {
            alert("Error in accessing server.");
        })
        .always(function() {
            hideLoader();
        });
    }

    var initResize = false;

    function onPreviewLoad(langId){
        if(langId){
            langId = $("#langNavTabs li a.active").attr("data-lang-id");
        }
        var pagePreviewFrame = $('#pagePreviewIframe_lang_'+langId);

        //resizeIframe(pagePreviewFrame);

        var editCssLink =  $('<link>').attr('rel','stylesheet')
        .attr('href','<%=request.getContextPath()%>/css/page-edit.css?rand=20200729');

        $(pagePreviewFrame).contents().find('head').append(editCssLink);
        let blocEditDiv = $('.blocEditDiv').first().html();
        let iframeBody = $(pagePreviewFrame).contents().find('body');
        let blocDivs = iframeBody.find('.bloc_div');
        blocDivs.each(function(index, el) {
            el = $(el);
            el.append(blocEditDiv).addClass('bloc_edit');
            el.find('.blocName').text(el.data('bloc-name'));
            if(el.hasClass('asm_form_div'))
                el.find(".btnEdit").remove();
        });
    }

    $('.pagePreviewIframe').each(function(){
        var langId =  this.getAttribute("data-lang-id");
        
        $(this).on("load",function (){
            onPreviewLoad(langId);
        });
    });

    function onPageSaveSuccess(resp, form){
        $('#pageNameHeading').text(form.find('[name=name]').val());
        refreshPagePreview();
    }

    function pageBlocEdit(btn){
        btn = $(btn);
        var blocDiv = btn.parents('.bloc_div:first');
        var blocId = blocDiv.data('bloc-id');
        var dummyButton = $('#dummyEditBlocBtn');
        dummyButton.attr('data-bloc-id',blocId);
        dummyButton.data('bloc-id',blocId);
        dummyButton.trigger('click');
    }

    function pageBlocDelete(btn){
        btn = $(btn);
        bootConfirm("Are you sure?", function(result){
            if(result){
                btn.parents('.bloc_edit:first').remove();
                $ch.pageChanged = true;
                refreshPagePreview();
             }
        })
    }

    function pageBlocMove(btn, direction){
        btn = $(btn);
        bloc = btn.parents('.bloc_edit:first');
        iframeBody = btn.parents('body:first');

        if(direction == 'down'){
            var nextEle = bloc.next();
            if(nextEle.hasClass('bloc_edit')){
                bloc.insertAfter(nextEle);
                $ch.pageChanged = true;
            }
        }
        else if(direction == 'up'){
            var prevEle = bloc.prev();
            if(prevEle.hasClass('bloc_edit')){
                bloc.insertBefore(prevEle);
                $ch.pageChanged = true;
            }
        }
    }

    function getPageBlocIds(){
        var blocIds = [];
        var langId = $("#langNavTabs li a.active").attr("data-lang-id");
        var pagePreviewFrame = $('#pagePreviewIframe_lang_'+langId)
        var blocDivs = pagePreviewFrame.contents().find('.bloc_div');
        blocDivs.each(function(index, el) {
            blocIds.push($(el).data('bloc-id'));
        });

        return blocIds;
    }

    function addExistingBloc(blocId){
        var form = $('#existingBlocsSearchForm');

        var blocPosition = 'top';
        if(form.length > 0){
            blocPosition = form.find('[name=addBlocPosition]').val();
        }

        var pageBlocIdsList = getPageBlocIds();

        switch(blocPosition){
            case 'bottom':
                pageBlocIdsList.push(blocId);
                break;
            case 'top':
                blocPosition = 0;
            default:
                var insertIndex =  parseInt(blocPosition);
                if( !isNaN(insertIndex)){
                    pageBlocIdsList.splice(insertIndex, 0, blocId);
                }
        }
        var langId = $("#langNavTabs li a.active").attr("data-lang-id");
        var pageId =  $('#page_editor_lang_'+langId).val();
        var url = getPagePreviewUrl(pageId) + "&blocIds="+pageBlocIdsList.join(",");
        $('#pagePreviewIframe_lang_'+langId).attr("src", url);

        $ch.pageChanged = true;
        $('#modalExistingBlocs').modal('hide');
    }

    function refreshPagePreview(langId){
        var pageBlocIdsList = getPageBlocIds();
        if(pageBlocIdsList.length == 0){
            pageBlocIdsList.push('0');
        }
        if(!langId){
            langId = $("#langNavTabs li a.active").attr("data-lang-id");
        }
        var pageId =  $('#page_editor_lang_'+langId).val();
        var url = getPagePreviewUrl(pageId) + "&blocIds="+pageBlocIdsList.join(",");
        $('#pagePreviewIframe_lang_'+langId).attr("src", url);
    }

    function onPageEditorPreview(){
        var langId = $("#langNavTabs li a.active").attr("data-lang-id");
        var pageId =  $('#page_editor_lang_'+langId).val();
        var curUrl = $('#pagePreviewIframe_lang_'+langId).attr("src");
        curUrl = curUrl.replace("&editor=1","");
        var params = "";
        if(curUrl.split("?").length>1){
            //params available
            params += curUrl.split("?")[1];
        }
        var win = window.open("pagePreview.jsp?"+params, "pagePreview_"+pageId);
        win.focus();
    }

    //overriding function from pagesAddEdit.jsp
    function onPublishUnpublish(action,isLogin){

        if(typeof isLogin == 'undefined' || !isLogin){
            checkPublishLogin(action);
        }
        else{
            var pages = [];
            pages.push({id:$('#pageId').val(), type:"<%=Constant.PAGE_TYPE_FREEMARKER%>"});
            publishUnpublishPages(pages, action, "now");
            // var msg = "Are you sure you want to "+action+" this page?";

            // showPublishPagesModal(msg, action, function(publishTime){
            //    var pages = [];
            //         pages.push({id:$('#pageId').val(), type:"<%=Constant.PAGE_TYPE_FREEMARKER%>"});
            //         publishUnpublishPages(pages, action, publishTime);
            // });

        }
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
                pageType: "freemarker",
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