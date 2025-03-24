<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%

    String template_id = parseNull(request.getParameter("id"));
    List<Language> langsList = getLangs(Etn,session);
    boolean active = true;

    String q = null;
    Set rs = null;

    q = "SELECT bt.id, bt.name, bt.type, th.status as theme_status "
        + " FROM bloc_templates bt "
        + " LEFT JOIN themes th ON th.id = bt.theme_id"
        + " WHERE bt.id = " + escape.cote(template_id)
        + " AND bt.site_id = " + escape.cote(getSiteId(session));
    rs = Etn.execute(q);

    if(!rs.next()){
        response.sendRedirect("blocTemplates.jsp");
    }

    String themeStatus = rs.value("theme_status");
    boolean isLocked = false;
    String editIcon = "edit";

    if(themeStatus.equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn)){
        isLocked = true;
        editIcon = "eye";
    }
    String templateType = rs.value("type");

    if( Constant.TEMPLATE_STRUCTURED_CONTENT.equals(templateType) ){
        response.sendRedirect("templateEditor.jsp?id="+template_id);
    }

    boolean isSystemTemplate = Arrays.asList(Constant.getSystemTemplateTypes()).contains(templateType);

    String goBackUrl = isSystemTemplate ? "systemTemplates.jsp" : "blocTemplates.jsp";

%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Template : <%=rs.value("name")%></title>

        <script src="<%=request.getContextPath()%>/js/fuse.min.js" ></script>

        <!-- ace editor -->
        <script src="<%=request.getContextPath()%>/js/ace/ace.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/ext-language_tools.js" ></script>
        <!-- <script src="<%=request.getContextPath()%>/js/ace/ext-beautify.js" ></script> -->
        <!-- ace modes -->
        <script src="<%=request.getContextPath()%>/js/ace/mode-ftl.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/mode-html.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/mode-css.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/mode-javascript.js" ></script>
        <!-- ace theme -->
        <script src="<%=request.getContextPath()%>/js/ace/theme-github.js" ></script>

        <style type="text/css">
            .ace_editor {
                border: 1px solid lightgray;
                min-height: 500px;
                font-family: monospace;
                font-size: 14px;
                /*margin: auto;*/
                /*width: 80%;*/
            }

            .list-group-item{
                display: list-item !important;
            }

            .ace_editor.ace_autocomplete{
                min-height: 200px;
            }

            ul#ui-id-1 {
                max-height: 400px;
                overflow-y: auto;
                overflow-x: hidden;
            }

            .ace_editor.ace_autocomplete.ace-monokai.ace_dark {
                width: 50%;
            }

        </style>
    </head>
   <body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Developer", ""});
        breadcrumbs.add(new String[]{isSystemTemplate?"System Templates": "Templates", isSystemTemplate? "systemTemplates.jsp":"blocTemplates.jsp"});
        breadcrumbs.add(new String[]{rs.value("name"), ""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
                <!-- beginning of container -->
                <form id="mainForm" action="" onsubmit="return false;">
                    <input type="hidden" name="template_id" id="template_id" value="<%=template_id%>" >
                    <input type="hidden" name="template_type" id="template_type" value="<%=templateType%>" >

                    <input type="hidden" name="requestType" id="requestType" value="" >
                    <input type="hidden" name="template_code" id="template_code" value="" >
                    <input type="hidden" name="css_code" id="css_code" value="" >
                    <input type="hidden" name="js_code" id="js_code" value="" >
                    <input type="hidden" name="jsonld_code" id="jsonld_code" value="" >
                    <input type="hidden" name="libraries" id="libraries" value="" >
                </form>

                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-start pt-3 pb-2 mb-3 border-bottom">
                    <h1 class="h2">Code source of template : <span class="templateName"><%=rs.value("name")%></span> (<%=rs.value("type").replace("_"," ")%>)</h1>
                    <div class="btn-toolbar mb-2 mb-md-0 flex-wrap flex-md-nowrap">
                        <div class="btn-group mx-2">
                            <button class="btn btn-primary" type="button" onclick="onClickGoBack('<%=goBackUrl%>')">Back</button>
                                        <button class="btn btn-primary" type="button" <%if(isLocked){%> disabled <%}%> onclick="onSave()">save</button>
                        </div>

                        <button class="btn btn-primary mr-2 "
                                    data-toggle="modal" data-target="#modalAddEditTemplate"
                                                data-caller="edit" data-template-id='<%=rs.value("id")%>' data-theme-status='<%=themeStatus%>'>
                                    <i data-feather="settings"></i></button>

                        <button class="btn btn-success " type="button"
                            onclick='openTemplateEditor(<%=rs.value("id")%>)'>
                            <i data-feather="<%=editIcon%>"></i></button>
                    </div>
                </div>
                <!-- row -->

                <nav class="nav nav-pills mb-4" id="mainTabs" role="tablist">
                    <a class="nav-item nav-link mr-2 active" id="codeTab"
                        data-toggle="tab" href="#codeContent" role="tab" aria-controls="code" aria-selected="true">
                        code</a>
                    <a class="nav-item nav-link mr-2 " id="libTab"
                        data-toggle="tab" href="#libContent" role="tab" aria-controls="library" >
                        file libraries</a>
                    <a class="nav-item nav-link mr-2" id="cssTab"
                        data-toggle="tab" href="#cssContent" role="tab" aria-controls="css" >
                        css</a>
                    <a class="nav-item nav-link mr-2 " id="jsTab"
                        data-toggle="tab" href="#jsContent" role="tab" aria-controls="js" >
                        js</a>
                    <a class="nav-item nav-link mr-2 " id="jsonldTab"
                        data-toggle="tab" href="#jsonldContent" role="tab" aria-controls="js" >
                        json_ld</a>
                </nav>

                <div class="tab-content p-3" id="mainTabContents">
                    <div class="row px-3 mt-3 availableFieldsDiv">
                        <div class="col">
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <button class="btn btn-secondary" disabled>Available fields</button>
                                </div>
                                <div class="position-relative flex-fill">
                                    <input type="text" id="fieldSelectAuto" class="form-control" value=""
                                        placeholder='Search or select and click "copy" button'>
                                </div>
                                <select class="custom-select d-none" id="fieldSelect">
                                </select>
                                <div class="input-group-append">
                                    <button class="btn btn-light" onclick="fieldSelectShowAll()"
                                        ><i data-feather="chevron-down"></i></button>
                                    <button class="btn btn-success" id="copyBtn"
                                        onclick="copyField('#fieldSelectAuto')"
                                        >copy</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row px-3 availableFieldsDiv">
                        <div class="col">
                            <small>
                                Freemarker reference links:
                                <a target="_blank" href="https://freemarker.apache.org/docs/dgui_template_exp.html#exp_cheatsheet">Expressions cheatsheet</a> ,
                                <a target="_blank" href="https://freemarker.apache.org/docs/ref_directive_alphaidx.html">#directives</a> ,
                                <a target="_blank" href="https://freemarker.apache.org/docs/ref_builtins_alphaidx.html">?built_ins</a>
                            </small>
                        </div>
                    </div>
                    <div class="row px-3 availableFieldsDiv">
                        <div class="col">
                            <small>
                                Tip: Use <code> ctrl + space</code> for field list autocomplete.

                            </small>
                        </div>
                        <div class="col text-right">
                            <small><a href="javascript:void(0)" onclick="showAceEditorSettings()">Show editor settings</a> (shortcut: <code> ctrl + ,</code>)

                                Edtior theme :
                                <a href="javascript:void(0)" onclick="setAceEditorTheme('light')">Light</a>&nbsp;/&nbsp;
                                <a href="javascript:void(0)" onclick="setAceEditorTheme('dark')">Dark</a>
                            </small>
                        </div>
                    </div>

                    <div id="codeContent" class="pt-0 tab-pane show active" role="tabpanel" aria-labelledby="codeTab">

                        <div class="row">
                            <div class="editor_div col">
                                <div id="template_code_editor"></div>
                            </div>
                        </div>


                    </div>

                    <div id="cssContent" class="tab-pane pt-0" role="tabpanel" aria-labelledby="cssTab">
                        <div class="row">
                            <div class="editor_div col pr-1">
                                <div class="card">
                                    <div class="card-header">
                                        <div class="font-weight-bold">Custom css</div>
                                    </div>
                                    <div class="card-body p-0" style="min-height: 500px;">
                                        <div id="css_code_editor"></div>
                                    </div>
                                </div>
                            </div>

                        </div>

                    </div> <!-- cssContent -->

                    <div id="jsContent" class="tab-pane pt-0" role="tabpanel" aria-labelledby="jsTab">
                        <div class="row">
                            <div class="editor_div col pr-1">
                                <div class="card">
                                    <div class="card-header">
                                        <div class="font-weight-bold">Custom js</div>
                                    </div>
                                    <div class="card-body p-0" style="min-height: 500px;">
                                        <div id="js_code_editor"></div>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div> <!-- js content -->

                    <div id="jsonldContent" class="tab-pane pt-0" role="tabpanel" aria-labelledby="jsonldContent">
                        <div class="row">
                            <div class="editor_div col pr-1">
                                <div class="card">
                                    <div class="card-header">
                                        <div class="font-weight-bold">Json-ld</div>
                                    </div>
                                    <div class="card-body p-0" style="min-height: 500px;">
                                        <div id="json_code_editor"></div>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div> <!-- js content -->

                    <div id="libContent" class="tab-pane" role="tabpanel" aria-labelledby="jsTab">
                        <div class="row">
                             <div class="col">
                                <div class="card">
                                    <div class="card-header">
                                        <span class="font-weight-bold">Libraries</span>
                                        <button class="btn btn-primary py-0 ml-2" type="button"
                                            onclick="openAddLibraryModal()" >
                                            <i data-feather="plus-circle"></i></button>
                                    </div>
                                    <div class="card-body py-0 pr-0" style="min-height: 500px;">
                                        <ul id="librariesList" class="list-group m-2 col-md-6 col-xs-12">

                                        </ul>
                                    </div>
                                </div>
                           </div>
                        </div>
                    </div> <!-- lib content -->
                </div>
                <textarea id="hiddenInput" name="ignore" value="" style="display:none;"></textarea>
                <!-- row-->
                <!-- /end of container -->
            </main>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
        </div>

        <!-- modal -->
        <div class="modal fade" id="modalAddLibrary" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Add library</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">

                        <div class="input-group">
                            <select class="custom-select" id="librarySelect" name="librarySelect"
                                        onchange="">
                            </select>
                            <div class="input-group-append">
                                <button type="button" class="btn btn-primary" onclick="addLibrary()" >
                                    select</button>
                            </div>
                        </div>
                    </div>
                    <!-- <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="" >Submit</button>
                    </div> -->
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <%@ include file="blocTemplatesAddEdit.jsp"%>

<script type="text/javascript">
    // ready function

    $(function() {

        $ch.pageChanged = false;
        $ch.savedData = "";

        var availableFieldsDiv = $('.availableFieldsDiv');

        $('#mainTabs a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
          var curTab = $(e.target); // newly activated tab

          var tabTarget = curTab.attr('href');
          if(tabTarget === '#libContent'){
            availableFieldsDiv.hide();
          }
          else{
            availableFieldsDiv.show();
          }

        });

        $ch.templateEditor = initAceEditor("template_code_editor", { mode: "ace/mode/ftl"});

        $ch.cssEditor = initAceEditor("css_code_editor", { mode: "ace/mode/css"});

        $ch.jsEditor = initAceEditor("js_code_editor", { mode: "ace/mode/javascript"});

        $ch.jsonldEditor = initAceEditor("json_code_editor", { mode: "ace/mode/json"});

        getData();

        // Array.from(document.getElementsByClassName("sortable2")).forEach(element =>{Sortable.create(element,{animation:50})});

        $('#copyBtn').popover({
            content: 'copied to clipboard',
            placement: 'top',
            delay: 0
        })
        .on('shown.bs.popover',function(){
            setTimeout(function(){
                $('#copyBtn').popover('hide');
            }, 1000);
        });

        setAceEditorTheme("dark");
        $ch.templateEditor.setKeyboardHandler("ace/keyboard/sublime");

        $ch.fieldsAutoCompleteList = [];
        $ch.fieldsFuse = new Fuse($ch.fieldsAutoCompleteList, {
            keys : ["value"],
            isCaseSensitive: false,
            ignoreLocation: true,
            ignoreFieldNorm: true,
            includeScore: true,
            shouldSort: false,
            threshold: 0.2, //most important
            // includeMatches: false,
            // findAllMatches: false,
            // minMatchCharLength: 1,
            // location: 0,
            // distance: 100,
            // useExtendedSearch: false,

        });

        const fieldSelectAuto = document.querySelector('#fieldSelectAuto');

        fieldSelectAuto.addEventListener('focus', function(event) {
            const input = event.target;
            if (input.value.length > 0) {
                input.setSelectionRange(0, 9999);
            }
        });

        fieldSelectAuto.addEventListener('blur', function(event) {
            if(event.target.nextElementSibling)
            event.target.nextElementSibling.innerHTML="";
        });

        fieldSelectAuto.addEventListener('input', function(event) {
            autocompleteFunc(event.target);
        });

        fieldSelectAuto.addEventListener("keydown",function(event){
          var ulTag = event.target.nextElementSibling;
          if(event.key==="ArrowDown"){
            var li = ulTag.querySelector(".autocomplete-item-highlight");
            if(li){
              var sibling = li.nextElementSibling;
              if(sibling) {
                li.classList.remove("autocomplete-item-highlight");
                ulTag.scrollTop = (sibling.offsetTop);
                sibling.classList.add("autocomplete-item-highlight");
                event.target.value = sibling.dataset.value;
              }
            }else{
              if(ulTag.querySelector("li")){
                event.target.value = ulTag.querySelector("li").dataset.value;
                li = ulTag.querySelector("li").classList.add("autocomplete-item-highlight");
              }
            }
          }else if(event.key==="ArrowUp"){
            var li = ulTag.querySelector(".autocomplete-item-highlight");
            if(li){
              var sibling = li.previousElementSibling;
              if(sibling) {
                li.classList.remove("autocomplete-item-highlight");
                ulTag.scrollTop = (sibling.offsetTop);
                sibling.classList.add("autocomplete-item-highlight");
                event.target.value = sibling.dataset.value;
              };
            }
          }
          else if(event.key === "Escape"){
            ulTag.innerHTML="";
          }
          else if(event.key === "Enter"){
            var li = ulTag.querySelector(".autocomplete-item-highlight");
            if(li) {
              event.target.value = li.dataset.value;
              ulTag.innerHTML="";
            }
          }
        });
    });

    function autocompleteFunc(e) {
        var ul = e.parentElement.querySelector(".autocomplete-items");
        if(ul==null){
            ul = document.createElement("ul");
            ul.classList.add("autocomplete-items","position-absolute","bg-white","d-flex","flex-column","pl-0", "overflow-auto","w-100");
            ul.style.listStyleType = "none";
            ul.style.overflow="auto";
            ul.style.left = "0";
            ul.style.maxHeight = "280px";
            ul.style.zIndex = "99999999";
            e.parentNode.appendChild(ul);
        }

        const searchTerm = e.value.trim();
        var resultList = $ch.fieldsAutoCompleteList;
        ul.innerHTML="";
        if (searchTerm.length > 0) {
            resultList = $ch.fieldsFuse.search(searchTerm, {limit : 20})
            .map(function(obj){
                return {
                    label : obj.item.label,
                    value : obj.item.value
                };
            });
            
            renderMenu(ul, resultList);
        } else {
            renderMenu(ul,resultList);
        }
    }

    function renderMenu(menuElement, items) {
        items.forEach(function (item) {
            renderMenuItem(menuElement, item);
        });
    }

  function renderMenuItem(ul, item) {
    var li = document.createElement("li");
    li.classList.add("py-2","px-2");
    li.style.cursor="pointer";
    li.dataset.value=item.value;
    li.innerText=item.label;
    
    li.addEventListener("mousedown",function(e)
    {
        var targetUl = e.target.closest("ul");
        var inputTag = targetUl.parentElement.querySelector("input");
        inputTag.value = e.target.dataset.value;
        targetUl.innerHTML="";
    });
    ul.appendChild(li);
  }

    function fieldSelectShowAll(){
        autocompleteFunc(document.getElementById("fieldSelectAuto"));
    }

    function initEditorAutocompleteList(isReset){

        var fieldSelect = $('#fieldSelect');
        if(isReset){
            $ch.templateFieldsList = [];
        }

        $ch.fieldsAutoCompleteList = [];

        fieldSelect.find('option').each(function(index, el) {
            var fieldVal = $(el).attr('value');

            var label = fieldVal.substring(0,fieldVal.indexOf(" : "));
            var value = fieldVal.substring(fieldVal.indexOf(" : ") + 3);

            $ch.fieldsAutoCompleteList.push({
                label : fieldVal,
                value : value
            });

            if(value.indexOf(">") > 0){
                value = strReplaceAll(value,"> ",">\n");
                value = strReplaceAll(value,"} ","}\n");
            }

            $ch.templateFieldsList.push({
                name: label,
                value: value,
                score: 1,
                meta: "freemarker"

            });

        });
        $ch.fieldsFuse.setCollection($ch.fieldsAutoCompleteList);
    }

    function onClickGoBack(url){
        checkPageChanged();
        goBack(url);
    }

    function checkPageChanged(){
        if($ch.savedData != getDataforSave() ){
            $ch.pageChanged = true;
            console.log("page changed");
        }
        else{
            $ch.pageChanged = false;
        }
    }

    function openTemplateEditor(id){
        checkPageChanged();
        if($ch.pageChanged){
            bootConfirm("Unsaved changes will be lost. Are you sure?",
                function(result){
                    if(result){
                        window.location.href = "templateEditor.jsp?id="+id;
                    }
                });
        }
        else{
            window.location.href = "templateEditor.jsp?id="+id;

        }
    }

    function onSave(isConfirm){

        if(!isConfirm){
            bootConfirm("Are you sure?",function(result){
                if(result) onSave(true);
            });
            return false;
        }

        showLoader();

        var formData = getDataforSave();

        $.ajax({
            url: 'blocTemplatesAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: formData,
        })
        .done(function(resp) {
            if(resp.status == 1){
                bootNotify("Template saved.");
                $ch.savedData = formData;
                $ch.pageChanged = false;
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in accessing server.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function getDataforSave(){
        var form = $('#mainForm');

        $('#requestType').val('saveTemplateResources');
        $('#template_code').val($ch.templateEditor.getSession().getValue());
        $('#css_code').val($ch.cssEditor.getSession().getValue());
        $('#js_code').val($ch.jsEditor.getSession().getValue());
        $('#jsonld_code').val($ch.jsonldEditor.getSession().getValue());


        var libraries = [];
        $('#librariesList li').each(function(index, li) {
            libraries.push($(li).data('libId'));
        });
        $('#libraries').val(libraries.join(","));

        return form.serialize();
    }

    function getData(){

        showLoader();
        $.ajax({
            url: 'blocTemplatesAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: {
                requestType : 'getTemplateResourcesData',
                template_id :  $('#template_id').val(),
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                initData(resp.data);
                $ch.savedData = getDataforSave();
                $ch.pageChanged = false;
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in accessing server.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function initData(data){
        showLoader();
        $ch.templateEditor.getSession().setValue(data.template_code);
        $ch.cssEditor.getSession().setValue(data.css_code);
        $ch.jsEditor.getSession().setValue(data.js_code);
        $ch.jsonldEditor.getSession().setValue(data.jsonld_code);
        var librariesList = $('#librariesList');
        librariesList.html('');
        $.each(data.libraries, function(index, library) {
            addLibraryListItem(librariesList, library.name, library.id);
        });

        hideLoader();

        getFields();
    }

    function getFields(){
        showLoader();
        $.ajax({
            url: 'blocTemplatesAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: {
                requestType : 'getTemplateSectionsData',
                template_id :  $('#template_id').val(),
                with_extra : '1',
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                processFields(resp.data);
                initEditorAutocompleteList();
            }
            else{
                bootNotifyError(resp.message );
            }
        })
        .fail(function() {
            bootNotifyError("Error in accessing server." );
        })
        .always(function() {
            hideLoader();
        });

    }

    function processFields(data){

        var fieldsList = [];

        for (var i = 0; i < data.sections.length; i++) {
            var section = data.sections[i];

            var sectionFields = processSectionFields(section, "", "");

            fieldsList = fieldsList.concat(sectionFields);

        }//for sections

        fieldsList.push("Page Info > language code : \${page.lang}");
        fieldsList.push("Page Info > path : \${page.path}");
        fieldsList.push("Page Info > path : \${page.uuid}");

        //page Meta parameters
        fieldsList.push("Page Info > Meta > Title : \${page.meta.title}");
        fieldsList.push("Page Info > Meta > Type : \${page.meta.type}");
        fieldsList.push("Page Info > Meta > Locale : \${page.meta.locale}");
        fieldsList.push("Page Info > Meta > Keywords : \${page.meta.keywords}");
        fieldsList.push("Page Info > Meta > Description : \${page.meta.description}");
        fieldsList.push("Page Info > Meta > Image : \${page.meta.image}");
        fieldsList.push("Page Info > Meta > Image width : \${page.meta.image_width}");
        fieldsList.push("Page Info > Meta > Image height : \${page.meta.image_height}");
        fieldsList.push("Page Info > Meta > Image type : \${page.meta.image_type}");
        fieldsList.push("Page Info > Meta > Twitter card : \${page.meta.twitter_card}");
        fieldsList.push("Page Info > Date > Created : \${page.date.created}");
        fieldsList.push("Page Info > Date > Modified : \${page.date.modified}");
        fieldsList.push("Page Info > Date > Published : \${page.date.published}");
        fieldsList.push("Page Info > Time > Created : \${page.time.created}");
        fieldsList.push("Page Info > Time > Modified : \${page.time.modified}");
        fieldsList.push("Page Info > Time > Published : \${page.time.published}");
		
        fieldsList.push("Bloc Info > Date > Created : \${bloc.date.created}");
        fieldsList.push("Bloc Info > Date > Modified : \${bloc.date.modified}");
        fieldsList.push("Bloc Info > Time > Created : \${bloc.time.created}");
        fieldsList.push("Bloc Info > Time > Modified : \${bloc.time.modified}");

        fieldsList.push("Site Param > Homepage URL : \${site_param.homepage_url}");
        fieldsList.push("Site Param > Page 404 URL : \${site_param.page_404_url}");
        fieldsList.push("Site Param > Prod path : \${site_param.production_path}");

        fieldsList.push("Data JSON object : JSON.parse('\${data_json!?js_string}')");

        //extra template fields by type if any
        for (var i = 0; i < data.extra.length; i++) {
            var extraSection = data.extra[i];

            var extraSectionFields = processSectionFields(extraSection, "", "");

            fieldsList = fieldsList.concat(extraSectionFields);

        }

        for (let i = 0; i < data.globalVariables.length; i++) {
            fieldsList.push("Variable "+(i+1)+" : \${"+data.globalVariables[i]+"}")
        }

        var fieldSelect = $('#fieldSelect');
        fieldSelect.html('');
        for (var i = 0; i < fieldsList.length; i++) {
            fieldSelect.append( $('<option>').attr('value',fieldsList[i])
                                                .text(fieldsList[i]) );
        }

    }

    function processSectionFields(section, parentName, parentCustomId){

        var fieldsList = [];

        var secPrefix = section.custom_id;
        var secName = section.name;

        var isParent = (parentCustomId.length > 0);

        if(section.nb_items != 1 ){
            //unlimited or multiple
            secPrefix = "cur_"+secPrefix;

            if(isParent && parentName.split(">").length >= 2){
                secPrefix += "_1";
            }

            var entry = (!isParent ? "" : parentName+" > ") + section.name
                        + " (Section as list) : <#list "
                        + (!isParent ? "" : parentCustomId+".")
                        + section.custom_id+" as "+secPrefix+"> </#list>";

            fieldsList.push(entry);
        }
        else{

            secPrefix = (!isParent ? "" : parentCustomId+".") + secPrefix
        }

        // secPrefix = secPrefix + ".";

        for (var i = 0; i < section.fields.length; i++) {
            var field = section.fields[i];

            var entry =  (!isParent ? "" : parentName+" > ") + secName + " > " + field.name;

            var altEntry = '';
            var labelEntry = '';
            var isDatePeriod = false;
            var isDateType = false;
            if(field.type == "image"){
                altEntry = entry + " (alt)";
                entry = entry + " (src)";
            }
            else if(field.type == "date"){
                var fieldProps = JSON.parse(field.value);
                isDateType = true;
                isDatePeriod = (fieldProps.date_type == "period");

                if(isDatePeriod){
                    altEntry = entry + " (end)";
                    entry = entry + " (start)";
                }
            }
            else if(field.type == "tag"){
                altEntry = entry + " (id)";
                entry = entry + " (label)";
            }
            else if(field.type == "URL"){
                altEntry = entry + " (openType)";
                if(JSON.parse(field.field_specific_data)["type"] == "url & label") labelEntry = entry + " (label)";
                entry = entry + " (url)";
            }
            else if(field.type == "file"){
                altEntry = entry + " (label)";
                entry = entry + " (src)";
            }


            if(field.type != "tag"){
                if(field.nb_items == 1 ){
                    //single
                    if(isDatePeriod){
                        entry = entry + " : \${" + secPrefix + "." + field.custom_id + "_start}";
                        altEntry = altEntry + " : \${" + secPrefix + "." + field.custom_id + "_end}";
                    } else{
                        entry = entry + " : \${" + secPrefix + "." + field.custom_id + "}";
                        if(field.type == "image") altEntry = altEntry + " : \${" + secPrefix + "." + field.custom_id + "_alt}";
                        else if(field.type == "URL"){
                            altEntry = altEntry + " : \${" + secPrefix + "." + field.custom_id + "_openType}";
                            if(JSON.parse(field.field_specific_data)["type"] == "url & label") fieldsList.push(labelEntry + " : \${" + secPrefix + "." + field.custom_id + "_label}");
                        } else if(field.type == "file") altEntry = altEntry + " : \${" + secPrefix + "." + field.custom_id + "_label}";
                    }
                } else{
                    var curFieldId = "cur_"+field.custom_id;
                    if(isParent && parentName.split(">").length >= 2) curFieldId += "_1";

                    if(isDatePeriod){
                        entry = entry + "(multiple as list) : <#list " + secPrefix + "."+ field.custom_id+"_start as "+curFieldId+">  \${"+curFieldId+"} </#list>";
                        altEntry = altEntry + " (multiple) : \${" + secPrefix + "." + field.custom_id+ "_end["+curFieldId+"?counter-1]}";
                    } else{
                        //unlimited or multiple
                        if(field.custom_id == "product_variants_variant_x_specifications_x_spec" || field.custom_id == "product_variants_variant_x_attributes"){
                            entry = entry + "(multiple as list) : <#list " + secPrefix + "."+ field.custom_id+" as "+curFieldId+"></#list>";
                        }else{
                            entry = entry + "(multiple as list) : <#list " + secPrefix + "."+ field.custom_id+" as "+curFieldId+">  \${"+curFieldId+"} </#list>";
                            if(field.type == "image"){
                                altEntry = altEntry + " (multiple) : \${" + secPrefix + "." + field.custom_id+ "_alt["+curFieldId+"?counter-1]}";
                            } else if(field.type == "URL"){
                                if(JSON.parse(field.field_specific_data)["type"] == "url & label") fieldsList.push(labelEntry + " (multiple) : \${" + secPrefix + "." + field.custom_id+ "_label["+curFieldId+"?counter-1]}");
                                altEntry = altEntry + " (multiple) : \${" + secPrefix + "." + field.custom_id+ "_openType["+curFieldId+"?counter-1]}";
                            } else if(field.type == "file"){
                                altEntry = altEntry + " (multiple) : \${" + secPrefix + "." + field.custom_id + "_label["+curFieldId+"?counter-1]}";
                            }
                        }
                    }
                }
            } else{
                //tag field ----------> every tag field is a list of tags
                if(field.nb_items == 1 ){
                    //single
                    entry += " (tags list)";
                    var curFieldId = "cur_"+field.custom_id;
                    if(isParent && parentName.split(">").length >= 2) curFieldId += "_1";

                    entry = entry + " : <#list " + secPrefix + "." + field.custom_id+" as "+curFieldId+">  \${"+curFieldId+"} </#list>";
                    altEntry = altEntry + " : \${" + secPrefix + "." + field.custom_id+"_id["+curFieldId+"?counter-1]}";
                } else{
                    entry += " (multiple)(tags list)";
                    altEntry += " (multiple)(tags ids)";
                    var outLoopFieldId  = "outer_cur_" + field.custom_id;
                    if(isParent && parentName.split(">").length >= 2) outLoopFieldId += "_1";

                    var curFieldId = "cur_"+field.custom_id;
                    //unlimited or multiple
                    entry = entry + " : <#list " + secPrefix + "." + field.custom_id+" as "+outLoopFieldId+"> "
                            + " <#list "+outLoopFieldId+" as "+curFieldId+">   \${"+curFieldId+"}  </#list> </#list>";

                    altEntry = altEntry + " : \${" + secPrefix + "." + field.custom_id+"_id["+outLoopFieldId+"?counter-1]["+curFieldId+"?counter-1]}";
                }
            }

            fieldsList.push(entry);
            if(field.custom_id == "product_variants_variant_x_attributes"){
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".name}");
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".type}");
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".unit}");
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".value}");
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".icon}");
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".label}");
            }

            if(field.custom_id == "product_variants_variant_x_specifications_x_spec"){
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".spec_value}");
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".value}");
                fieldsList.push(parentName+" > "+ secName + " > " + field.name + " \${"+curFieldId+".label}");
            }

            if(altEntry.length > 0) fieldsList.push(altEntry);

            if(field.type.startsWith("view_")) loadViewFields(field, entry);
        }//for fields

        if(typeof section.sections !== 'undefined' ){
            for (var i = 0; i < section.sections.length; i++) {
                var nestedSection = section.sections[i];

                var sectionName =  (!isParent ? "" : parentName+" > ") + section.name;
                // var sectionCustomId = (!isParent ? "" : parentCustomId+".") + section.custom_id;
                var nestedFieldsList = processSectionFields(nestedSection,sectionName, secPrefix);

                fieldsList = fieldsList.concat(nestedFieldsList);
            }
        }

        return fieldsList;
    }

    function loadViewFields(field, entry){
        // showLoader();
        $.ajax({
            url: 'blocTemplatesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getViewSampleJSON',
                viewType : field.type,
                viewTemplateId : field.value
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                processViewFields(field, entry, resp.data.view_code, resp.data.template_code);
                initEditorAutocompleteList(true);
            }
            else{
                console.error("Error in getting view sample json. "+ resp.message);
            }
        })
        .fail(function() {
            // bootNotifyError("Error contacting server.");
        })
        .always(function() {
            // hideLoader();
        });
    }

    function processViewFields(field, entry, viewCode, templateCode){
        var parentLabelPrefix = entry.substring(0, entry.indexOf(" : ")).trim();
        var parentFieldPrefix = entry.substring(entry.indexOf(" : ") + 3).trim();

        parentFieldPrefix = parentFieldPrefix.replaceAll(/[\${}]/g,"");

        var viewJson = {
            data : []
        };
        viewJson.data.push(viewCode);
        var templateSections = templateCode.sections || [];

        var getFieldsList = function(obj, labelPrefix, fieldPrefix){
            var retList = [];
            var objList = [];

            if(typeof obj !== 'object'){
                return retList;
            }

            if( Array.isArray(obj) ){
                var fieldName = fieldPrefix;
                if(fieldPrefix.indexOf(".") > 0){
                    fieldName = fieldPrefix.substring(fieldPrefix.lastIndexOf(".")+1);

                    if(fieldName == 'data'){
                        //to distinguish "data" list variable among view fields
                        var dataFieldName = fieldPrefix.substring(0,fieldPrefix.lastIndexOf("."));
                        if(dataFieldName.lastIndexOf(".") >= 0){
                            dataFieldName =  dataFieldName.substring(dataFieldName.lastIndexOf(".")+1);
                        }
                        fieldName = dataFieldName + "_data";
                    }
                }


                fieldName = "cur_"+fieldName;

                var entry = labelPrefix + " (list)"
                    + " : "
                    + "<#list "
                    + fieldPrefix +" as "+fieldName+"> </#list>";
                retList.push(entry);

                if(obj.length > 0){
                    var subList = getFieldsList( obj[0], labelPrefix, fieldName);
                    retList = retList.concat(subList);
                }

                return retList;
            }

            for(var key in obj ){
                if(key === 'template_data'){
                    obj[key] = {};
                }

                var value = obj[key];

                if(typeof value == 'object'){
                    objList.push(key);
                }
                else{
                    var entry = labelPrefix + " > " + key
                        + " : \${" + fieldPrefix + "." + key + "}";
                    retList.push(entry);
                }
            }

            //process objects
            for (var i = 0; i < objList.length; i++) {
                var key = objList[i];
                var curLabelPrefix = labelPrefix + " > " + key;
                var curFieldPrefix = fieldPrefix + "." + key;

                if(key === 'template_data'){

                    templateSections.forEach(function(section){
                        var sectionFields = processSectionFields(section, curLabelPrefix, curFieldPrefix);
                        retList = retList.concat(sectionFields);
                    });

                }
                else{
                    var subFieldsList = getFieldsList(obj[key],  curLabelPrefix, curFieldPrefix);
                    retList  = retList.concat(subFieldsList);
                }
            }

            return retList;
        };

        var fieldsList =  getFieldsList(viewJson, parentLabelPrefix, parentFieldPrefix);

        //console.log("fieldsList",fieldsList);
        var fieldSelect = $('#fieldSelect');
        var targetOption = null;
        fieldSelect.find('option').each(function(index, opt) {
            var curVal = $(opt).val();
            if(curVal == entry){
                targetOption = opt;
                return false;
            }
        });
        if(targetOption != null){
            var fieldsListOptions = fieldsList.map(function(curVal) {
                return $('<option>').text(curVal).attr('value',curVal);
            });

            $(targetOption).after(fieldsListOptions);
        }
    }

    function openAddLibraryModal(){

        var modal = $('#modalAddLibrary');

        var librarySelect = $('#librarySelect');
        librarySelect.html('<option value="">select ...</option>');

        showLoader();
        $.ajax({
            url: 'librariesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getCompactList',
            },
        })
        .done(function(resp) {
            var data = [];
            if(resp.status == 1){

                $.each(resp.data.libraries, function(index, library) {
                    var opt = $('<option>').attr('value',library.id).text(library.name);
                    librarySelect.append(opt);
                });

                modal.modal('show');
            }
            else{
                //Error bootNotify(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });

    }

    function addLibrary(){
        var modal = $('#modalAddLibrary');
        var librarySelect = $('#librarySelect');
        var librariesList = $('#librariesList');

        var libId = librarySelect.val();
        if(libId == ""){
            return false;
        }

        if(librariesList.find('.libId_'+libId).length == 0){
            var libName = librarySelect.find('option:selected').text();
            addLibraryListItem(librariesList, libName, libId);
        }

        modal.modal('hide');
    }

    function addLibraryListItem(listEle , libName, libId){

        var li = $('<li class="list-group-item list-group-item-action list-group-item-success">');

        li.data('libId',libId).addClass('libId_'+libId).text(libName)
            .append('<button type="button" class="close" onclick="removeListItem(this);"><span >&times;</span></button>');

        listEle.append(li);
    }


    function removeListItem(btn){
        $(btn).parents('li:first').remove();
    }

    function copyField(fieldSelector){
    var input = $('#hiddenInput');

    if(typeof fieldSelector === 'undefined' ){
        fieldSelector = '#fieldSelect';
    }

    var fieldVal = $(fieldSelector).val();

    if(fieldVal.trim().length > 0 ){
        var val = fieldVal;
        if(val.indexOf(" : ") >= 0){
            val = fieldVal.substring(fieldVal.indexOf(" : ") + 3);
        }

        if(val.indexOf(">") > 0){
            val = strReplaceAll(val,"> ",">\n");
            val = strReplaceAll(val,"} ","}\n");
        }
        input.val(val);
        input.show();
        input.select();
        document.execCommand("copy");
        //navigator.clipboard.writeText(input.val());
        input.hide();

        $('#copyBtn').popover('show');
    }
}


</script>
    </body>
</html>