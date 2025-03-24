<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/lib_msg.jsp"%>

<%!
    List<String> getColumns(Set rs)
    {
        rs.next();
        List<String> list = new ArrayList<String>(Arrays.asList(rs.ColName));
        String [] col = {"created_by","created_on","created_ts","updated_by","updated_on","updated_ts","published_by","published_ts","to_generate","to_generate_by",
                "to_publish","to_publish_by","to_publish_ts","to_unpublish","to_unpublish_by","to_unpublish_ts","deleted_by","is_deleted","site_id"};
        for(String val : col){ 
            list.removeIf(value->value.equalsIgnoreCase(val));
        }
        return list;
    }

    boolean canAddBlocField(Contexte Etn,String templateId){
        Set rs = Etn.execute("select * from bloc_field_selected_templates where selected_template_id="+escape.cote(templateId));
        return rs.rs.Rows<=0;
    }

    boolean isBlocFieldExist(Contexte Etn, String templateId,String parentSectionId){
        String whereCondition = " bloc_template_id = "+escape.cote(templateId);
        if(!parseNull(parentSectionId).isEmpty()) whereCondition = " parent_section_id = "+escape.cote(parentSectionId);
        
        Set rsSections = Etn.execute("select * from bloc_templates_sections where "+whereCondition);
        while(rsSections.next()){
            Set rsFields = Etn.execute("select * from sections_fields where section_id="+escape.cote(rsSections.value("id")));
            while(rsFields.next()){
                if(rsFields.value("type").equals("bloc")) return true;
            }
            return isBlocFieldExist(Etn,templateId,rsSections.value("id"));
        }
        return false;
    }
%>

<%
    String siteId = getSiteId(session);
    String MEDIA_LIBRARY_UPLOADS_URL = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL")+siteId;
    String IMAGE_URL_PREPEND = getImageURLPrepend(siteId);
    String CATALOG_ROOT = GlobalParm.getParm("CATALOG_ROOT") + "/";

    String template_id = parseNull(request.getParameter("id"));

    String q = null;
    Set rs = null;
    q = "SELECT bt.id, bt.name, bt.type, th.status as theme_status FROM bloc_templates bt "
        + " LEFT JOIN themes th ON th.id = bt.theme_id"
        + " WHERE bt.id = " + escape.cote(template_id)
        + " AND bt.site_id = " + escape.cote(siteId);
    rs = Etn.execute(q);

    if (!rs.next()) {
        response.sendRedirect("blocTemplates.jsp");
    }

    String themeStatus = rs.value("theme_status");
    boolean isLocked = false;

    if(themeStatus.equals("locked") && !isSuperAdmin(Etn)){
        isLocked = true;
    }

    String templateType = rs.value("type");
    boolean isSystemTemplate = Arrays.asList(Constant.getSystemTemplateTypes()).contains(templateType);

    String goBackUrl = isSystemTemplate ? "systemTemplates.jsp" : "blocTemplates.jsp";
	boolean active=true;
	List<Language> langsList = getLangs(Etn,session);
    List<String> catalogColumns = getColumns(Etn.execute("SELECT * FROM "+GlobalParm.getParm("CATALOG_DB")+".catalogs LIMIT 1"));
    List<String> contentColumns = getColumns(Etn.execute("SELECT * FROM structured_contents LIMIT 1"));
    List<String> pagesColumns = getColumns(Etn.execute("SELECT * FROM freemarker_pages LIMIT 1"));
    List<String> blocsColumns = getColumns(Etn.execute("SELECT * FROM blocs LIMIT 1"));
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <%@ include file="../WEB-INF/include/head2.jsp"%>
        <title>Template : <%=rs.value("name")%></title>

        <script type="text/javascript" src='<%=GlobalParm.getParm("URL_GEN_JS_URL")%>'></script>
        <script type="text/javascript">window.URL_GEN_AJAX_URL = '<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>';</script>
        <!-- ace editor -->
        <script src="<%=request.getContextPath()%>/js/ace/ace.js" ></script>
        <!-- ace modes -->
        <script src="<%=request.getContextPath()%>/js/ace/mode-freemarker.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/mode-javascript.js" ></script>
        <script src="<%=request.getContextPath()%>/js/ace/mode-css.js" ></script>

        <script src="<%=request.getContextPath()%>/ckeditor/ckeditor.js"></script>
        <script src="<%=request.getContextPath()%>/ckeditor/adapters/jquery.js"></script>

        <style type="text/css">
            .selectValueList > li:first-child .deleteBtn{
                display: none;
            }

            .sortable li{
                margin : 5px 0px;
            }

            .sortable li.new{
                margin : 5px 2px;
            }

            .col-form-label {
                font-weight: bold;
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
                <%@ include file="templateUtilities/templateEditorMainHtml.jsp" %>
                <%@ include file="/WEB-INF/include/footer.jsp" %>
            </div>
        
            <%@ include file="templateUtilities/templateEditorModals.jsp"%>

            <%@ include file="blocTemplatesAddEdit.jsp"%>
            <%@ include file="templateUtilities/templateEditorUtility.jsp"%>

        <script type="text/javascript">
            window.IMAGE_URL_PREPEND = '<%=IMAGE_URL_PREPEND%>';
            window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = '<%=IMAGE_URL_PREPEND%>';
            $ch.MEDIA_LIBRARY_UPLOADS_URL = '<%=MEDIA_LIBRARY_UPLOADS_URL%>';
            window.CATALOG_ROOT = '<%=CATALOG_ROOT%>';
            window.allTagsList = <%=getAllTagsJSON(Etn, siteId, GlobalParm.getParm("CATALOG_DB"))%>;
            var aceCommonOptions = {
                minLines: 20,
                showPrintMargin : false,
                autoScrollEditorIntoView: true
            };
            var javascriptOpts = $.extend({ mode: "ace/mode/javascript"}, aceCommonOptions);
            var cssOpts = $.extend({ mode: "ace/mode/css"}, aceCommonOptions);

            let offsetExistingFieldModal = 0;
            let limitExistingFieldModal = 30;
            let loadingExistingFieldModal = false;

            let selectedFolders=[];
            // ready function
            $(function() {
                $ch.pageChanged = false;
                $ch.savedData = "";
                
                getData();

                var el = document.getElementById("sectionsList");
                var sortable = Sortable.create(el,{animation: 50});

                var catalogsCol = '<%= catalogColumns.toString()%>';
                $ch.catalogsCol = catalogsCol.substring(1,catalogsCol.length-1).replaceAll(" ","").split(",");
                var contentCol = '<%= contentColumns.toString()%>';
                $ch.contentCol = contentCol.substring(1,contentCol.length-1).replaceAll(" ","").split(",");
                var pagesCol = '<%= pagesColumns.toString()%>';
                $ch.pagesCol = pagesCol.substring(1,pagesCol.length-1).replaceAll(" ","").split(",");
                var blocsCol = '<%= blocsColumns.toString()%>';
                $ch.blocsCol = blocsCol.substring(1,blocsCol.length-1).replaceAll(" ","").split(",");    

                // Section modal
                $('#modalAddEditSection').on('show.bs.modal', showModalAddEditSection).on('shown.bs.modal', function() {
                    $(this).find('input:visible').first().focus();
                });

                //Field modal
                $('#modalAddEditField').on('show.bs.modal', showModalAddEditField).on('shown.bs.modal', function() {
                    $(this).find('input:visible').first().focus();
                });
                
                $('#modalAddEditSection').on('hide.bs.modal',function(){
                    if($(this).find(".js-editor").length>1) $(this).find(".js-editor").not(":first").remove();
                    
                    $(this).find(".js-editor-remove").hide();
                    setAceEditorValue($(this).find(".ace-editor-css"),"");
                    setAceEditorValue($(this).find(".ace-editor-js"),"");
                })

                $('#modalAddEditField').on('hide.bs.modal', function(){
                    $(this).find("[readonly]").removeAttr("readonly");
                    $(this).find("[disabled]").removeAttr("disabled");
                    $(this).find("#field-text,.tagsDiv").remove();
                    if($(this).find(".js-editor").length>1)
                        $(this).find(".js-editor").not(":first").remove();
                    $(this).find(".js-editor-remove").hide();
                    setAceEditorValue($(this).find(".ace-editor-css"),"");
                    setAceEditorValue($(this).find(".ace-editor-js"),"");
                    selectedFolders=[];
                });

                $('#formAddEditSection').on('change', 'input,select,textarea', function(event) {
                    $(this).removeClass('is-invalid');
                });

                // Section modal
                $('#modalSelectFieldType').on('show.bs.modal', function(event) {
                    var button = $(event.relatedTarget);
                    var modal = $(this);
                    var form = $('#formSelectFieldType');
                    form.get(0).reset();

                    var section_id = button.attr("data-section-id");

                    if (typeof section_id == "undefined") {
                        section_id = button.parents('li.sectionListItem:first').data('section_id');
                    }
                    form.find('[name=section_id]').val(section_id);
                });

                $('.image-format').on('click',function(){
                    if($(".image-format.active").is($(this))) $(this).removeClass("active");
                    else{
                        $(".image-format.active").removeClass("active");
                        $(this).addClass("active");
                        $(this).closest(".imageFormat").find("[name=img-asp]").val($(this).text().replace(":","x"));
                    }
                });

                $('#formAddEditSection').submit(function(event) {
                    event.preventDefault();
                    event.stopPropagation();
                    onSaveSection($(this));
                });

                $('#formAddEditField').submit(function(event) {
                    event.preventDefault();
                    event.stopPropagation();
                    onSaveField($(this));
                });



                $('#modalAddExistingField').on('show.bs.modal', function(event) {
                    loadExistingFieldData("");
                    var button = $(event.relatedTarget);
                    var modal = $(this);

                    var section_id = button.parents('li.sectionListItem:first').data('section_id');
                    modal.find('[name=section_id]').val(section_id);
                    modal.find('.addFieldBtn').attr("data-section-id", section_id);
                });
                
                $(".ace-editor-js").each(function() {
                    var jsEditor = ace.edit(this, javascriptOpts);
                    jsEditor.setFontSize(15);
                    this.style.minHeight="100px";
                });
                
                $(".ace-editor-css").each(function() {
                    var cssEditor = ace.edit(this, cssOpts);
                    cssEditor.setFontSize(15);
                    this.style.minHeight="100px";
                });

                $(document).on("change",".default_value_templates",function(e){
                    
                    let tempIds = [];
                    if($(e.target).val() == "all") {
                        $(e.target).find("option:not([value=''], [value='all'])").each(function(idx,el){
                            tempIds.push($(el).val());
                        });
                    }
                    else tempIds.push($(e.target).val());
                    
                    $(e.target).parent().find(".edit-bloc,.add-bloc,.remove-bloc").hide();

                    getBlocsLists(tempIds).then(blocs => {
                        populateListToAutocomplete($(e.target).next(".asm-autocomplete").find("input.asm-autocomplete-field"),blocs);
                    $(e.target).parent().find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                    $(e.target).parent().find("input").val("");
                    }).catch(error => {
                        console.error(error);
                    });           

                });

                $(document).on('click','.autocomplete-items li',function(){
                    let inputGroup = $(this).closest(".input-group");
                    let inputBloc = $(this).prop("tagName") == "A" ? $(this) : $(this).find("a");
                    let blocId = inputBloc.data("id");
                    let blocName = inputBloc.attr("value");

                    inputGroup.find("[name='bloc_id']").val(blocId);
                    inputGroup.find("[name='bloc_name']").val(blocName);

                    if(inputGroup.find("select").val() == "all" || inputGroup.find("select").val() == "") inputGroup.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                    else {
                        let tempId = inputGroup.find(".bloc-templates").val();
                        inputGroup.find(".edit-bloc,.remove-bloc").show();
                        inputGroup.find(".add-bloc").hide();                        
                        inputGroup.find(".edit-bloc")
                            .attr("data-caller","edit")
                            .attr("data-bloc-id", blocId)
                            .attr("data-template-id",tempId)
                            .attr("data-template",inputGroup.find(`.bloc-templates option[value="\${tempId}"]`).text())
                            .attr("data-template-type","bloc");
                    }
                    inputGroup.find(".autocomplete-items").remove();
                });

                $(document).on("change","[name='field_specific_url_type']",function(){
                    if($(this).val() == "url & label" && $(this).closest("form").find(".urlGenLabel").length == 0){
                        $(`<div class="input-group mb-3 urlGenLabel">
                            <div class="input-group-prepend">
                                <span class="input-group-text" for="url-gen-label">Label</span>
                            </div>
                            <input type="text" class="form-control" name="url-gen-label">
                        </div>`).insertBefore($(this).closest("form").find(".urlGenDiv"));
                    }else $(".urlGenLabel").remove();
                });

                $(document).on("input",".default_value_bloc",function(e){
                    let field = $(e.target);
                    let inputGroup = field.closest(".input-group");
                    let templateId = inputGroup.find(".bloc-templates").val();
                    let templateName = inputGroup.find(`.bloc-templates option[value='\${templateId}']`).text();

                    if(field.val().length <= 1) 
                    {
                        inputGroup.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                        return;
                    }
                        
                    field.next("input").val("");

                    if(templateId == "all" || templateId == "") inputGroup.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                    else{
                        inputGroup.find(".remove-bloc").show();
                        handleBlocButtons(inputGroup,"add",null,templateId,templateName);
                    }
                });

                $(document).on('keydown',".default_value_bloc",function(e){
                    
                    if (!["Enter", "ArrowDown", "ArrowUp"].includes(e.key)) return;
                    if(e.key == "Enter") e.preventDefault();
                    let field = $(e.target);
                    let inputGroup = field.closest(".input-group");
                    let templateId = inputGroup.find(".bloc-templates").val();
                    let templateName = inputGroup.find(`.bloc-templates option[value='\${templateId}']`).text();
                    let isEditable = false;
                    let bId = "";

                    $.each(field.data("autocompleteList"),function(idx, tmp){
                        if(field.val().toLowerCase() == tmp.label.toLowerCase()) {
                            templateName = tmp.template;
                            templateId = tmp.template_id;
                            bId = tmp.id;
                            isEditable = true;
                            return;
                        }
                    });

                    if(templateId == "all" || templateId == "" || field.val().length == 0){
                        inputGroup.find("button.edit-bloc,button.add-bloc,button.remove-bloc").hide();
                        return;
                    }
                    
                    if(!isEditable) {
                        field.next("input").val("");
                        inputGroup.find(".remove-bloc").show();
                        handleBlocButtons(inputGroup,"add",null,templateId,templateName);
                    }else if(e.key == "Enter" && isEditable) {
                        inputGroup.find(".remove-bloc").show();
                        handleBlocButtons(inputGroup,"edit",bId,templateId,templateName);
                        field.next("input").val(bId);
                        inputGroup.find(".autocomplete-items").remove();
                    }
                    
                });                

                handleEventListnerOnSelect(document.querySelector(".tags_folder_list"),0);

                $('#modalAddExistingField .modal-body').on('scroll', function() {
                    if ($(this).scrollTop() + $(this).innerHeight() >= ($(this)[0].scrollHeight-10)) loadExistingFieldData("");
                });

                $('#modalAddExistingField').on('hidden.bs.modal', function () {
                    $("#loader").show();
                    offsetExistingFieldModal = 0;
                    limitExistingFieldModal = 30;
                    loadingExistingFieldModal = false;
                    $('#existingFieldsList').empty();

                    $("#loader").hide();
                });

                $('.searchExistingField').on('keyup', debounce(function() {
                    onKeyUpExistingFieldSearch($(this));
                }, 300));
            });

            function getData() {
                showLoader();
                $.ajax({
                    url: 'blocTemplatesAjax.jsp',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        requestType: 'getTemplateSectionsData',
                        template_id: $('#template_id').val(),
                    },
                }).done(function(resp) {
                    if (resp.status == 1) {
                        initData(resp.data);
                        $ch.savedData = JSON.stringify(getDataForSave());
                        $ch.pageChanged = false;
                    }
                    else alert(resp.message);
                }).fail(function() {
                    alert("Error in accessing server.");
                }).always(function() {
                    hideLoader();
                });
            }

            function initData(data) {
                showLoader();
                $(data.sections).each(function(index, section) {
                    initSectionData(section, '');
                });
                hideLoader();
            }

            function initSectionData(section, parentSectionId) {
                var sectionListItem = insertUpdateSection(section.id, section.name,section.custom_id, section.nb_items,parentSectionId, section.is_system, 
                        section.description, section.is_collapse, section.display, section.css_code, section.js_code,section.is_new_product_item);
                if (!sectionListItem) {
                    return false;
                }
                var curSectionId = section.id;

                var fieldsList = sectionListItem.find('ul.fieldsList:first');
                $(section.fields).each(function(index, f) {
                    insertUpdateField(fieldsList, f.id, f.type,f.name, f.custom_id, f.nb_items,f.description,f.is_query,f.query_type,f.select_type,f.display,
                        f.unique_type,f.modifiable,f.reg_exp,f.css_code,f.js_code, null, f,f.is_new_product_item,f.field_specific_data);
                });

                $(section.sections).each(function(index, nestedSection) {
                    initSectionData(nestedSection, curSectionId);
                });
            }

            function insertUpdateSection(section_id,name,custom_id,nb_items,parent_section_id,is_system,description,is_collapse,display,css_code,js_code,is_new_product_item) {
                var sectionItem = $('#section_' + section_id);
                if (parent_section_id.length > 0) {
                    var parentSection = $('#section_' + parent_section_id);

                    if (parentSection.length == 0) {
                        return false;
                    }

                    if (parentSection.parents('li.sectionListItem').length > 4) {
                        //max 2 level nested sections allowed
                        return false;
                    }
                }

                if (sectionItem.length === 0) {
                    sectionItem = $('#sectionListItemTemplate').clone(true);

                    if (section_id.length == 0) {
                        section_id = 'new_' + getRandomInt(10000);
                    }

                    sectionItem.attr('id', 'section_' + section_id);

                    sectionItem.addClass('section_' + section_id);

                    if (parent_section_id.length == 0) {
                        $('#addSectionListItem').before(sectionItem);
                    } else {
                        var parentFieldsList = parentSection.find('ul.fieldsList:first');
                        parentFieldsList.find('>li.addFieldListItem:first').before(sectionItem);
                    }
                    
                    Array.from(sectionItem).forEach(element=>{Sortable.create(element.querySelector("ul.fieldsList:first-child"),{animation:100});}); 
                }

                if (sectionItem.parents('li.sectionListItem').length >= 5) {
                    sectionItem.find('.addNestedSectionBtn').hide();
                }

                sectionItem.data('section_id', section_id);
                sectionItem.data('name', name);
                sectionItem.data('custom_id', custom_id);
                sectionItem.data('nb_items', nb_items);
                sectionItem.data('is_system', is_system);
                sectionItem.data('is_collapse', is_collapse);
                sectionItem.data('description', description);
                sectionItem.data('display', display);
                sectionItem.data('css_code', css_code);
                sectionItem.data('js_code', js_code);
                sectionItem.data('is_new_product_item', is_new_product_item);

                if(is_system == 1){
                    sectionItem.find('.systemHide').hide();
                }

                var nb_items_text = 'unlimited';
                if (parseInt(nb_items) != 0) {
                    nb_items_text = 'limited : ' + nb_items;
                }
                
                sectionItem.find('.section_header:first .name').text(name);
                sectionItem.find('.section_header:first .custom_id').text(custom_id);
                sectionItem.find('.section_header:first .nb_items_text').text(nb_items_text);

                return sectionItem;
            }

            function insertUpdateField(fieldsList,field_id,field_type,name,custom_id,nb_items,description,is_query,query_type,select_type,display,unique_type,
                    modifiable,reg_exp, css_code,js_code, form, data,is_new_product_item,field_specific_data) {
                
                field_specific_data = getFieldSpecificDataJson(field_specific_data);

                fieldListItem = fieldsList.find('> li.field_' + field_id);

                if (fieldListItem.length === 0) {
                    //new field
                    fieldListItem = $('#fieldListItemTemplate').clone(true);

                    if (field_id.length == 0) {
                        field_id = "new_" + getRandomInt(10000);
                    }

                    fieldListItem.attr('id', null);
                    fieldListItem.addClass("field_" + field_id);

                    fieldsList.find('>li.addFieldListItem').before(fieldListItem);
                }

                fieldListItem.data('field_id', field_id);
                fieldListItem.data('field_type', field_type);
                fieldListItem.data('name', name);
                fieldListItem.data('custom_id', custom_id);
                fieldListItem.data('nb_items', nb_items);
                fieldListItem.data('is_meta_variable', '0');
                fieldListItem.data('is_required', '0');
                fieldListItem.data('is_indexed', '0');
                fieldListItem.data('is_bulk_modify', '0');
                fieldListItem.data('is_query', is_query);
                fieldListItem.data('query_type', query_type);
                fieldListItem.data('select_type', select_type);
                fieldListItem.data('description',description);
                fieldListItem.data('display',display);
                fieldListItem.data('unique_type',unique_type);
                fieldListItem.data('modifiable',modifiable);
                fieldListItem.data('reg_exp',reg_exp);
                fieldListItem.data('css_code',css_code);
                fieldListItem.data('js_code',js_code);
                fieldListItem.data('is_new_product_item',is_new_product_item);

                if(field_type==="boolean" ) fieldListItem.data('field_specific_boolean_type',getDataFromJson(field_specific_data,"check","type"));
                if(field_type==="URL") fieldListItem.data('field_specific_url_type',getDataFromJson(field_specific_data,"url","type"));
                if(field_type==="image") fieldListItem.data('field_specific_media_type',getDataFromJson(field_specific_data,"image","type"));
                if(field_type ==="bloc" ) fieldListItem.data('field_specific_selected_templates',getDataFromJson(field_specific_data,[],"templates_ids"));

                var is_system = 0;
                if (form != null) {
                    setFieldDataValues(field_type, fieldListItem, form);
                } else if (data != null) {
                    fieldListItem.data('value', data.value);
                    fieldListItem.data('lang_data', data.lang_data);
                    fieldListItem.data('is_required', data.is_required);
                    fieldListItem.data('is_indexed', data.is_indexed);
                    fieldListItem.data('is_bulk_modify', data.is_bulk_modify);
                    fieldListItem.data('is_meta_variable', data.is_meta_variable);
                    is_system = data.is_system;
                }

                fieldListItem.data('is_system', is_system);

                if(is_system == 1){
                    fieldListItem.find(".systemHide").hide();
                }

                var nb_items_text = 'unlimited';
                if (parseInt(nb_items) != 0) {
                    nb_items_text = 'limited : ' + nb_items;
                }

                var required_text = ("1" === fieldListItem.data('is_required')) ? "required" : "";
                var indexed_text = ("1" === fieldListItem.data('is_indexed')) ? "indexed" : "";
                var bulk_modify_text = ("1" === fieldListItem.data('is_bulk_modify')) ? "bulk modify" : "";
                var meta_variable_text = ("1" === fieldListItem.data('is_meta_variable')) ? "meta_variable " : "";

                fieldListItem.find('span.name').text(name);
                fieldListItem.find('span.field_type').text(field_type);
                fieldListItem.find('span.custom_id').text(custom_id);
                fieldListItem.find('span.nb_items_text').text(nb_items_text);
                fieldListItem.find('span.required_text').text(required_text);
                fieldListItem.find('span.indexed_text').text(indexed_text);
				<%if("store".equals(templateType)){%>
                    fieldListItem.find('span.bulk_modify_text').text(bulk_modify_text);
				<%}%>
                fieldListItem.find('span.meta_variable_text').text(meta_variable_text);
            }

            function setFieldDataValues(fieldType, fieldListItem, form) {
                var value = "";
                var langData = [];
				let langIds = form.find('[name=langueIds]');
				let placeholders = form.find('[name=placeholder]');

                switch (fieldType) {
                    case "text":
                    case "multiline_text":
                    case "text_formatted":
                    case "number":					
						var defValues = form.find('[name=default_value]');
						for(let i=0; i<langIds.length; i++) {
							let lData = {};
							lData.langue_id = $(langIds[i]).val();
							lData.langue_code = $(langIds[i]).data('langue_code');
							lData.default_value = $(defValues[i]).val();
							lData.placeholder = $(placeholders[i]).val();

							langData.push(lData);
						}
                        break;

                    case "URL":
						var defValues = form.find('[name=default_value]');
                        var defLabels = form.find('input[name="url-gen-label"]');
						for(let i=0; i<langIds.length; i++) {

							var urlInput = $(defValues[i]);
							var url_value = urlInput.val();
							var url_openType = urlInput.data('url-generator').getOpenType();
                            var url_label = $(defLabels[i]);

                            console.log(url_label.val());
                            let urlArr = [url_value, url_openType];
                            if(url_label.length > 0) urlArr.push(url_label.val()); 
							var default_value = JSON.stringify(urlArr);
							
							let lData = {};
							lData.langue_id = $(langIds[i]).val();
							lData.langue_code = $(langIds[i]).data('langue_code');
							lData.default_value = default_value;
							lData.placeholder = $(placeholders[i]).val();

							langData.push(lData);
						}
					
                        break;

                    case "boolean":
                        var default_value = form.find('[name=default_value]:checked').val();
                        
						//for boolean the default selected option will always be same for all languages
                        let valString = "on";
                        if(default_value==="0") valString = "off";

                        default_value = form.find('[name=value_'+valString+']').val();
						for(let i=0; i<langIds.length; i++) {
							let lData = {};
							lData.langue_id = $(langIds[i]).val();
							lData.langue_code = $(langIds[i]).data('langue_code');
							lData.default_value = default_value;
							langData.push(lData);
						}

                        var value_on = form.find('[name=value_on]').val();
                        var value_off = form.find('[name=value_off]').val();
                        value = JSON.stringify({on: value_on, off: value_off});
                        break;

                    case "select":
                        var is_query = form.find("#option_query").prop("checked");

                        if(!is_query){
                            value = [];

                            form.find('li.selectValueListItem').each(function(index, li) {
                                li = $(li);
                                var option_value = li.find('[name=option_value]').val();
                                var option_label = li.find('[name=option_label]').val();
                                value.push([option_value, option_label]);

                                //for case of select default value for all languages will always be same
                                if (li.find('[name=default_value]').prop('checked')) {
                                    for(let i=0; i<langIds.length; i++) {
                                        var default_value = option_value;
                                        let lData = {};
                                        lData.langue_id = $(langIds[i]).val();
                                        lData.langue_code = $(langIds[i]).data('langue_code');
                                        lData.default_value = default_value;

                                        langData.push(lData);
                                    }
                                }
                            });
                            value = JSON.stringify(value);
                        }else{
                            
                            var q_type = form.find(".query-select > .selectValueListItem > select").val();
                            
                            if(q_type!="free")
                                value = form.find("[name=select-field-for-value]").val()+","+form.find("[name=select-field-for-label]").val();
                            else
                                value = form.find("#free-query").val();
                        }

                        break;

                    case "image":

                        form.find(".langTabContent").each(function(){
                            let imageValue = $(this).find(".image_value").val() || "";
                            let imageAlt = $(this).find(".image_alt").val() ||  "";
                            console.log(imageAlt,imageValue);
                            langData.push({
                                langue_id : $(this).find("[name='langueIds']").attr("value"),
                                langue_code : $(this).find("[name='langueIds']").attr("data-langue_code"),
                                default_value : `\${imageValue},\${imageAlt}`,
                            });
                        });
                        
                        value = form.find("[name=img-asp]").val(); 
                        break;

                    case "file":
						var defValues = form.find('[name=default_value]');
						for(let i=0; i<langIds.length; i++) {							
							var default_value = $(defValues[i]).val().trim();
							let lData = {};
							lData.langue_id = $(langIds[i]).val();
							lData.langue_code = $(langIds[i]).data('langue_code');
							lData.default_value = default_value;
							langData.push(lData);
						}
                        break;

                    case "tag":

						for(let i=0; i<langIds.length; i++) {
							let _htmlDiv = $("#fieldDefValueDiv_"+$(langIds[i]).val());
							var tagsList = [];					
							_htmlDiv.parent().find('.tagsDiv input.tagValue').each(function(index, input) {
								var curTag = $(input).val();
								tagsList.push(curTag);
							});
							default_value = JSON.stringify(tagsList);

							let lData = {};
							lData.langue_id = $(langIds[i]).val();
							lData.langue_code = $(langIds[i]).data('langue_code');
							lData.default_value = default_value;

							langData.push(lData);
						}
                        var selects = document.querySelectorAll('select[name="tags_folder_list"]');
                        var distinctValues = [];
                        selects.forEach(function (select) {
                            var selectedValue = select.value;
                            if (!distinctValues.includes(selectedValue) && selectedValue.length>0) {
                                distinctValues.push(selectedValue);
                            }
                        });
                        value = distinctValues.join(",");

                        break;
                    case "date":        ///date section

                        var date_type = form.find('[name=date_type]').val();
                        var date_format = form.find('[name=date_format]').val();

						for(let i=0; i<langIds.length; i++) {			
							let _htmlDiv = $("#fieldDefValueDiv_"+$(langIds[i]).val());
                            splitDates(_htmlDiv[0]);
							var date_value_start = _htmlDiv.find('[name=date_value_start]').val();
							var date_value_end = _htmlDiv.find('[name=date_value_end]').val();

							if (date_type == 'period') {
								default_value = [date_value_start, date_value_end];
							}
							else {
								default_value = [date_value_start, date_value_start];
							}

							value = JSON.stringify({
								date_type: date_type,
								date_format: date_format,
							});

							default_value = JSON.stringify(default_value);
							let lData = {};
							lData.langue_id = $(langIds[i]).val();
							lData.langue_code = $(langIds[i]).data('langue_code');
							lData.default_value = default_value;

							langData.push(lData);
						}
                        break;
                    case "bloc":
                        
                        form.find("[name='langueIds']").each(function(){
                            let data = {};
                            data["langue_id"] = $(this).val();
                            data["langue_code"] = $(this).attr("data-langue_code");
                            templates = []
                            form.find("[name='default_value'] option").not("[value=''], [value='all']").each(function(){
                                templates.push( {
                                    id: $(this).val(),
                                    template_name: $(this).text()
                                });
                            });
                            
                            data["default_value"] = {
                                template_id : form.find("[name='default_value']").val(),
                                bloc_id : form.find("[name='bloc_id']").val(),
                                bloc_name : form.find("[name='bloc_name']").val(),
                                templates : templates
                            };
                            data["placeholder"] = "";
                            langData.push(data);
                        });
                        break;
                    case "view_structured_contents":
                    case "view_structured_pages":
                        value = form.find('select.catalogType').val();
                        break;
                }
                var is_required = form.find('[name=is_required]').prop('checked') ? "1" : "0";
                var is_meta_variable = form.find('[name=is_meta_variable]').prop('checked') ? "1" : "0";
                var is_indexed = form.find('[name=is_indexed]').prop('checked') ? "1" : "0";
                var is_bulk_modify = form.find('[name=is_bulk_modify]').prop('checked') ? "1" : "0";

                var placeholder = form.find('[name=placeholder]').val().trim();

                fieldListItem.data('value', value);
                fieldListItem.data('lang_data', langData);
                fieldListItem.data('is_required', is_required);
                fieldListItem.data('is_indexed', is_indexed);
                fieldListItem.data('is_bulk_modify', is_bulk_modify);
                fieldListItem.data('is_meta_variable', is_meta_variable);
            }

            function loadExistingFieldData(search,isEmptyList) {
                return new Promise((resolve, reject) => {
                    if(isEmptyList) {
                        $("#loader").show();
                        offsetExistingFieldModal = 0;
                        limitExistingFieldModal = 30;
                        loadingExistingFieldModal = false;
                        $('#existingFieldsList').empty();
                    }

                    if (loadingExistingFieldModal) return;
                    loadingExistingFieldModal = true;

                    $.ajax({
                        url: 'blocTemplatesAjax.jsp',
                        type: 'GET',
                        dataType: 'json',
                        data: {
                            requestType: 'getExistingFields',
                            offset: offsetExistingFieldModal, 
                            limit: limitExistingFieldModal,
                            search:search
                        },
                        beforeSend: function() {
                            $("#loader").show(); // Show the loader
                        },
                    })
                    .done(function(resp) {
                        if (resp.status == 1) {
                            var fieldsList = resp.data.fields;
                            var fieldListItemTemplate = $('#existingFieldListItemTemplate');

                            var existingFieldsList = $('#existingFieldsList');
                            $.each(fieldsList, function(index, fieldData) {
                                var fieldListItem = fieldListItemTemplate.clone(true);

                                fieldListItem.attr('id', null);
                                fieldListItem.data('field-data', fieldData);
                                fieldListItem.data('field_id', fieldData.id);
                                fieldListItem.data('name', fieldData.name);
                                fieldListItem.data('custom_id', fieldData.custom_id);
                                fieldListItem.data('field_type', fieldData.type);
                                fieldListItem.data('nb_items', fieldData.nb_items);
                                fieldListItem.data('value', fieldData.value);
                                fieldListItem.data('lang_data', fieldData.lang_data);
                                fieldListItem.data('is_required', fieldData.is_required);
                                fieldListItem.data('is_indexed', fieldData.is_indexed);
                                fieldListItem.data('is_bulk_modify', fieldData.is_bulk_modify);
                                fieldListItem.data('is_meta_variable', fieldData.is_meta_variable);
                                
                                let field_specific_data = getFieldSpecificDataJson(fieldData.field_specific_data);
                                if(fieldData.type==="boolean") fieldListItem.data('field_specific_boolean_type',getDataFromJson(field_specific_data,"check","type"));
                                if(fieldData.type==="image") fieldListItem.data('field_specific_media_type',getDataFromJson(field_specific_data,"image","type"));
                                if(fieldData.type==="URL") {
                                    fieldListItem.data('field_specific_url_type',getDataFromJson(field_specific_data,"check","type"));
                                }
                                if(fieldData.type==="bloc") {
                                    fieldListItem.data('field_specific_selected_templates',getDataFromJson(field_specific_data,[],"templates_ids"));
                                }

                                var nb_items_text = 'unlimited';
                                if (parseInt(fieldData.nb_items) != 0) {
                                    nb_items_text = 'limited : ' + fieldData.nb_items;
                                }

                                fieldListItem.find('span.name').text(fieldData.name);
                                fieldListItem.find('span.field_type').text(fieldData.type);
                                fieldListItem.find('span.custom_id').text(fieldData.custom_id);
                                fieldListItem.find('span.nb_items_text').text(fieldData.nb_items_text);
                                existingFieldsList.append(fieldListItem);
                            });
                            offsetExistingFieldModal += limitExistingFieldModal;
                            resolve();
                        } else reject(resp.message);
                    })
                    .fail(function() {reject(error);})
                    .always(function() {
                        loadingExistingFieldModal = false;
                        $("#loader").hide();
                    });
                });
            }

            function onSave(isConfirm) {
                if (!isConfirm) {
                    bootConfirm("Are you sure?", function(result) {
                        if (result) onSave(true);
                    });
                    return false;
                }

                var dataObj = getDataForSave();
                showLoader();
                $.ajax({
                    url: 'blocTemplatesAjax.jsp',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        requestType: 'saveTemplateSections',
                        template_id: $('#template_id').val(),
                        data: JSON.stringify(dataObj),
                    },
                }) .done(function(resp) {
                    if (resp.status == 1) {
                        bootNotify("Template saved.");
                        $ch.savedData = JSON.stringify(dataObj);
                        $ch.pageChanged = false;
                    } else alert(resp.message);
                }) .fail(function() {
                    alert("Error in accessing server.");
                }) .always(function() {
                    hideLoader();
                });
            }

            function getDataForSave() {
                var dataObj = {
                    template_id: $('#template_id').val(),
                    sections: [],
                };

                var sectionsList = $('#sectionsList > li.sectionListItem');

                sectionsList.each(function(index, sectionItem) {
                    var sectionJson = getSectionJson(sectionItem);

                    dataObj.sections.push(sectionJson);

                });
                return dataObj;
            }

            function getSectionJson(sectionItem) {
                sectionItem = $(sectionItem);
                var sectionJson = {
                    id: sectionItem.data('section_id'),
                    name: sectionItem.data('name'),
                    custom_id: sectionItem.data('custom_id'),
                    nb_items: sectionItem.data('nb_items'),
                    is_collapse: sectionItem.data('is_collapse'),
                    description: sectionItem.data('description'),
                    display: sectionItem.data('display'),
                    css_code: sectionItem.data('css_code'),
                    js_code: sectionItem.data('js_code'),
                    is_new_product_item: sectionItem.data('is_new_product_item')!==undefined?sectionItem.data('is_new_product_item'):"0"
                };

                var sectionFields = [];

                var fieldsList = sectionItem.find('ul.fieldsList:first');

                //process fields
                fieldsList.find(">li.fieldListItem")
                .each(function(index, fieldLi) {
                    fieldLi = $(fieldLi);
                    let field_specific_data={};
                    if(fieldLi.data('field_type')=="boolean") field_specific_data["type"] = fieldLi.data('field_specific_boolean_type');
                    if(fieldLi.data('field_type')==="URL") field_specific_data["type"] = fieldLi.data('field_specific_url_type');
                    if(fieldLi.data('field_type')==="image") field_specific_data["type"] = fieldLi.data('field_specific_media_type');
                    if(fieldLi.data('field_type')==="bloc") {
                        field_specific_data["templates_ids"] = fieldLi.data('field_specific_selected_templates');
                    }

                    var fieldJson = {
                        id: fieldLi.data('field_id'),
                        name: fieldLi.data('name'),
                        custom_id: fieldLi.data('custom_id'),
                        nb_items: fieldLi.data('nb_items'),
                        type: fieldLi.data('field_type'),
                        select_type: fieldLi.data('select_type'),
                        is_query: fieldLi.data('is_query'),
                        value: fieldLi.data('value'),
                        lang_data: fieldLi.data('lang_data'),
                        is_required: fieldLi.data('is_required'),
                        is_indexed: fieldLi.data('is_indexed'),
                        is_bulk_modify: fieldLi.data('is_bulk_modify'),
                        is_meta_variable: fieldLi.data('is_meta_variable'),
                        description: fieldLi.data('description'),
                        display: fieldLi.data('display'),
                        modifiable: fieldLi.data('modifiable'),
                        unique_type: fieldLi.data('unique_type'),
                        query_type: fieldLi.data('query_type'),
                        reg_exp: fieldLi.data('reg_exp'),
                        css_code: fieldLi.data('css_code'),
                        js_code: fieldLi.data('js_code'),
                        field_specific_data: JSON.stringify(field_specific_data),
                        is_new_product_item:  fieldLi.data('is_new_product_item')!==undefined?fieldLi.data('is_new_product_item'):"0"
                    };
                    sectionFields.push(fieldJson);
                });

                sectionJson.fields = sectionFields;
                //process nested sections
                var nestedSections = [];
                fieldsList.find(">li.sectionListItem")
                        .each(function(index, nestedSectionItem) {
                            nestedSections.push(getSectionJson(nestedSectionItem));
                        });

                sectionJson.sections = nestedSections;

                return sectionJson;
            }

            function onSaveSection(form) {
                form.find('.is-invalid').removeClass('is-invalid');

                var section_id = form.find('[name=section_id]').val();
                var parent_section_id = form.find('[name=parent_section_id]').val();
                var name = form.find('[name=name]').val();
                var custom_id = form.find('[name=custom_id]').val();
                var nb_items = form.find('[name=nb_items]').val();
                var section_description = form.find('[name=section-description]').val();
                var is_collapse = form.find('[name=collapse-by-default]').val();
                var is_display = form.find('[name=display-by-default]').val();
                var css_code = getAceEditorValue(form.find(".ace-editor-css"));
                var js_code = [];

                $.each(form.find(".js-editor"), function(idx,ele){
                    var arr = [];
                    arr.push($(ele).find("[name=js-ontrigger]").val());
                    arr.push(encodeURIComponent(getAceEditorValue($(ele).find(".ace-editor-js"))));
                    js_code.push(arr);
                });
                

                if (parent_section_id.length > 0) {
                    var parentSection = $('#section_' + parent_section_id);
                    if (parentSection.length == 0) {
                        return false;
                    }
                }

                form.find('[required]').each(function(index, el) {
                    if ($(el).val().trim().length == 0) {
                        $(el).addClass('is-invalid');
                    }
                });

                if (form.find('.is-invalid').length === 0) {
                    //custom validations
                    if (parent_section_id.length > 0) {
                        //nested section, so check custom_id against section fields + sections
                        var fieldsList = parentSection.find('ul.fieldsList').first();
                        if (isDuplicateCustomId(custom_id, fieldsList, 'section_id', section_id)) {
                            form.find('[name=custom_id]').addClass('is-invalid');
                        }

                    } else {
                        //main section, so check custom_ids of main sections
                        if (isDuplicateCustomId(custom_id, $('#sectionsList'), 'section_id', section_id)) {
                            form.find('[name=custom_id]').addClass('is-invalid');
                        }
                    }

                }

                if (form.find('.is-invalid').length !== 0) {
                    form.find('.is-invalid').first().focus();
                    return false;
                }

                //all good

                insertUpdateSection(section_id, name, custom_id, nb_items, parent_section_id, 0, section_description, is_collapse, is_display, css_code, js_code,"1");

                $('#modalAddEditSection').modal('hide');

                checkPageChanged();

            }

            function onSaveField(form) {
                form.find('.is-invalid').removeClass('is-invalid');

                var section_id = form.find('[name=section_id]').val();
                var field_id = form.find('[name=field_id]').val();
                var field_type = form.find('[name=field_type]').val();

                var name = form.find('[name=name]').val();
                var custom_id = form.find('[name=custom_id]').val();
                var nb_items = form.find('[name=nb_items]').val();
                var nb_items_select = form.find('[name=nb_items_select]').val();
                var description = form.find('[name=field-info-description]').val();
                var select_type = form.find('[name=select-type]').val();
                var is_query = (form.find('#option_query').prop('checked'))? "1":"0";
                var query_type = (form.find(".query-select > .selectValueListItem > select").length>0)? form.find(".query-select > .selectValueListItem > select").val() : "";
                var display =  form.find('[name=display-by-default]').val();
                var unique_type = form.find('[name=field-id-type]').val();
                var modifiable = form.find('[name=field-modifiable]').val();

                let field_specific_data={};
                if(field_type=="boolean") field_specific_data["type"] = form.find('[name=field_specific_boolean_type]').val();
                if(field_type==="URL") field_specific_data["type"] = form.find('[name=field_specific_url_type]').val();
                if(field_type==="image") field_specific_data["type"] = form.find('[name="media-type"]').val();
                if(field_type==="bloc") {
                    let valuesArray=[];
                    form.find('[name=field_specific_selected_templates]').each(function() {
                        let val = $(this).val();
                        if(val.length>0) valuesArray.push(val);
                    });
                    field_specific_data["templates_ids"] = valuesArray;
                    if(form.find('select.bloc-templates').val().length == 0) form.find('select.bloc-templates').addClass("is-invalid");
                    else form.find('select.bloc-templates').removeClass("is-invalid");
                }
                
                var reg_exp = encodeURIComponent(form.find('[name=regex]').val());
                var css_code = getAceEditorValue(form.find('.ace-editor-css'));
                var js_code = [];
                $.each(form.find(".js-editor"), function(idx,ele){
                    var arr = [];
                    arr.push($(ele).find("[name=js-ontrigger]").val());
                    arr.push(encodeURIComponent(getAceEditorValue($(ele).find(".ace-editor-js"))));
                    js_code.push(arr);
                });
                

                var sectionItem = $('#section_' + section_id);
                var fieldsList = null;

                if (sectionItem.length > 0) {
                    fieldsList = sectionItem.find('ul.fieldsList:first');
                }
                else {
                    $('#modalAddEditField').modal('hide');
                }

                form.find('[required]').each(function(index, el) {
                    if ($(el).val().trim().length == 0) {
                        $(el).addClass('is-invalid');
                    }
                });

                if (form.find('.is-invalid').length === 0) {
                    //custom validations
                    if (isDuplicateCustomId(custom_id, fieldsList, 'field_id', field_id)) {
                        form.find('[name=custom_id]').addClass('is-invalid');
                    }
                }

                if(field_type == 'select' && !is_query) form.find("[name=option_label]").attr("required", true);

                if (form.find('.is-invalid').length !== 0) {
                    form.find('.is-invalid').first().focus();
                    return false;
                }

                //all good

                insertUpdateField(fieldsList, field_id, field_type,
                        name, custom_id, nb_items, description,is_query,query_type,select_type,display,unique_type,modifiable,reg_exp, css_code,js_code,form, null,"1",JSON.stringify(field_specific_data));

                $('#modalAddEditField').modal('hide');

                checkPageChanged();
            }

            function deleteSection(btn) {
                btn = $(btn);
                bootConfirm("Are you sure?", function(result) {
                    if (result) {
                        btn.parents('li.sectionListItem:first').remove();
                    }
                })
            }

            function deleteField(btn) {
                btn = $(btn);

                bootConfirm("Are you sure?", function(result) {
                    if (result) {
                        btn.parents('li.fieldListItem:first').remove();
                    }
                })
            }

            function addExistingField(li) {
                var li = $(li);
                var modal2 = $('#modalAddExistingField');

                var fieldData = li.data('field-data');

                var modal = $("#modalAddEditField");
                var form = $('#formAddEditField');
                form.get(0).reset();
                form.find('[name=field_id]').val('');
                form.find('.is-invalid').removeClass('is-invalid');
                $('#listOfFieldsBtn').show();

                $('#listOfFieldsBtn').hide();

                var fieldItem = li;
                var section_id = modal2.find('[name=section_id]').val();

                form.find('[name=section_id]').val(section_id);

                var field_type = fieldItem.data('field_type');
                form.find('[name=field_type]').val(field_type);

                form.find('[name=field_id]').val('');
                form.find('[name=name]').val(fieldItem.data('name'));
                
                if(field_type==="boolean") form.find('[name=field_specific_boolean_type]').val(fieldItem.data('field_specific_boolean_type'));
                else if(field_type==="URL") form.find('[name=field_specific_url_type]').val(fieldItem.data('field_specific_url_type'));
                else if(field_type==="image") form.find('[name="media-type"]').val(fieldItem.data('field_specific_media_type'));
                else if(fieldData.type==="bloc") {
                    let valuesArray=fieldItem.data('field_specific_selected_templates');
                    duplicateElement(form,"field_specific_selected_templates",valuesArray.length-1);
                    form.find('[name=field_specific_selected_templates]').each(function(index) {
                        try{
                            $(this).val(valuesArray[index]);
                        }catch(ex){
                            $(this).val('');
                        }
                    });
                }

                form.find('[name=custom_id]').val(fieldItem.data('custom_id')).prop('readonly', true);

                var nbItems = parseInt(fieldItem.data('nb_items'));
                form.find('[name=nb_items]').val(nbItems);
                if (nbItems > 0) {
                    form.find('[name=nb_items]').prop('readonly', false).val(nbItems);
                    form.find('[name=nb_items_select]').val(1);
                }
                else {
                    form.find('[name=nb_items]').prop('readonly', false).val(nbItems).prop('readonly', true);
                    form.find('[name=nb_items_select]').val(0);
                }
                var modalTitle = "Edit "+ strReplaceAll(field_type, "_", " ")+ " : " + fieldItem.data('name');
                modal.find('.modal-title').text(modalTitle);

                initFieldType(field_type, fieldItem);

                var sectionItem = $('#section_' + section_id);
                var fieldsList = sectionItem.find('ul.fieldsList:first');

                var custom_id = fieldItem.data('custom_id');

                if (isDuplicateCustomId(custom_id, fieldsList, 'field_id', '')) {
                    bootNotifyError('Field ID already exists in the section');
                    return;
                }
                onSaveField(form);
            }

            function showModalAddEditSection(event) {
                var button = $(event.relatedTarget);
                var modal = $(this);
                var form = $('#formAddEditSection');
                form.get(0).reset();
                form.find('[name=section_id]').val('');
                form.find('[name=parent_section_id]').val('');
                form.find("[type=submit]").prop('disabled',false).show();

                var caller = button.data('caller');

                if (caller == "edit") {
                    var sectionItem = button.parents('li.sectionListItem:first');
                    
                    form.find('[name=section_id]').val(sectionItem.data('section_id'));
                    form.find('[name=name]').val(sectionItem.data('name'));
                    form.find('[name=section-description]').val(sectionItem.data('description'));
                    form.find('[name=collapse-by-default]').val(sectionItem.data('is_collapse'));
                    form.find('[name=display-by-default]').val(sectionItem.data('display'));
                    form.find('[name=custom_id]').val(sectionItem.data('custom_id')).prop('readonly', true);

                    var nbItems = parseInt(sectionItem.data('nb_items'));
                    form.find('[name=nb_items]').val(nbItems);
                    if (nbItems > 0) {
                        form.find('[name=nb_items]').prop('readonly', false).val(nbItems);
                        form.find('[name=nb_items_select]').val(1);
                    }
                    else {
                        form.find('[name=nb_items]').prop('readonly', false).val(0).prop('readonly', true);
                        form.find('[name=nb_items_select]').val(0);
                    }
                    
                    setAceEditorValue(form.find('.ace-editor-css'),sectionItem.data('css_code'),true);
                    if(sectionItem.data('js_code').length>0){
                        $.each((typeof sectionItem.data('js_code') == 'object')? sectionItem.data('js_code'): JSON.parse(sectionItem.data("js_code")),function(idx,obj){
                            if(idx>0){
                                appendAceEditor(form);
                                form.find(".js-editor-remove").show();
                            }else form.find(".js-editor-remove").hide();
                            form.find('[name=js-ontrigger]:last').val(obj[0].toLowerCase());
                            setAceEditorValue(form.find('.ace-editor-js:last'),decodeURIComponent(obj[1]),false);
                        });
                    }

                    modal.find('.modal-title').text("Edit section : " + sectionItem.data('name'));

                    var isSystem = sectionItem.data('is_system') == '1';
                    var isNewProduct = sectionItem.data('is_new_product_item') == '1';
                    if(isSystem && !isNewProduct){
                        form.find("[type=submit]").prop('disabled',true).hide();
                    }

                    if(isSystem && isNewProduct){
                        form.find('input[name="name"]').prop('readOnly', true);
                        form.find('select[name="nb_items_select"]').prop('disabled', true);
                        form.find('input[name="nb_items"]').prop('readOnly', true);
                    }
                }
                else {
                    modal.find('.modal-title').text("Add a section of fields");
                    form.find('[name=custom_id]').prop('readonly', false);
                    if (caller == "addNested") {
                        modal.find('.modal-title').text("Add a nested section of fields");

                        var parent_section_id = button.parents('li.sectionListItem:first').data('section_id');
                        form.find('[name=parent_section_id]').val(parent_section_id);
                    }
                }

            }

            function showModalAddEditField(event) {
                var button = $(event.relatedTarget);
                var modal = $(this);
                var form = $('#formAddEditField');
                form.get(0).reset();
                form.find('[name=field_id]').val('');
                form.find('.is-invalid').removeClass('is-invalid');
                form.find('[type=submit]').prop('disabled', false).show();
                $('#listOfFieldsBtn').show();

                var caller = button.data('caller');

                var field_type = "";
                if (caller == "edit") {
                    $('#listOfFieldsBtn').hide();

                    var fieldItem = button.parents('li.fieldListItem:first');
                    var section_id = button.parents('li.sectionListItem:first').data('section_id');

                    form.find('[name=section_id]').val(section_id);

                    field_type = fieldItem.data('field_type');
                    form.find('[name=field_type]').val(field_type);

                    form.find('[name=field_id]').val(fieldItem.data('field_id'));
                    form.find('[name=name]').val(fieldItem.data('name'));
                    form.find('[name=custom_id]').val(fieldItem.data('custom_id')).prop('readonly', true);
                    form.find('[name=field-info-description]').val(fieldItem.data('description'));
                    form.find('[name=display-by-default]').val(fieldItem.data('display'));
                    form.find('[name=select-type]').val(fieldItem.data('select_type'));
                    form.find('[name=field-id-type]').val(fieldItem.data('unique_type'));
                    form.find('[name=field-modifiable]').val(fieldItem.data('modifiable'));
                    form.find('[name=regex]').val(decodeURIComponent(fieldItem.data('reg_exp')));

                    if(field_type==="boolean") {
                        form.find('[name=field_specific_boolean_type]').val(fieldItem.data('field_specific_boolean_type'));
                    }
                    if(field_type==="image") {
                        form.find('[name="media-type"]').val(fieldItem.data('field_specific_media_type')).trigger("change");
                    }
                    if(field_type==="URL") {
                        form.find('[name=field_specific_url_type]').val(fieldItem.data('field_specific_url_type'));
                    }
                    if(field_type==="bloc") {
                        let valuesArray=fieldItem.data('field_specific_selected_templates');
                        duplicateElement(form,"field_specific_selected_templates",valuesArray.length-1);
                        form.find('[name=field_specific_selected_templates]').each(function(index) {
                            try{
                                $(this).val(valuesArray[index]);
                            }catch(ex){
                                $(this).val('');
                            }
                        });
                    }

                    var nbItems = parseInt(fieldItem.data('nb_items'));
                    form.find('[name=nb_items]').val(nbItems);
                    if (nbItems > 0) {
                        form.find('[name=nb_items]').prop('readonly', false).val(nbItems);
                        form.find('[name=nb_items_select]').val(1);
                    } else {
                        form.find('[name=nb_items]').prop('readonly', false).val(nbItems).prop('readonly', true);
                        form.find('[name=nb_items_select]').val(0);
                    }

                    setAceEditorValue(form.find('.ace-editor-css'),fieldItem.data('css_code'),true);

                    if(fieldItem.data('js_code').length>0){
                        $.each((typeof fieldItem.data('js_code') == 'object')? fieldItem.data('js_code') : JSON.parse(fieldItem.data('js_code')),function(idx,obj){
                            if(idx>0){
                                 appendAceEditor(form);
                                 form.find(".js-editor-remove").show();
                            }else form.find(".js-editor-remove").hide();

                            form.find('[name=js-ontrigger]:last').val(obj[0].toLowerCase());
                            setAceEditorValue(form.find('.ace-editor-js:last'),decodeURIComponent(obj[1]),false);
                        });
                    }

                    var modalTitle = "Edit "+ strReplaceAll(field_type, "_", " ")+ " : " + fieldItem.data('name');
                    modal.find('.modal-title').text(modalTitle);

                    initFieldType(field_type, fieldItem);
                    var isSystem = fieldItem.data('is_system') == '1';
                    var isNewProduct = fieldItem.data('is_new_product_item') == '1';
                    if(isSystem && !isNewProduct){
                        form.find('[type=submit]').prop('disabled', true).hide();
                    }

                    if(isSystem && isNewProduct){
                        form.find('input[name="name"]').prop('readOnly', true);
                        form.find('select[name="nb_items_select"]').prop('disabled', true);
                        form.find('input[name="nb_items"]').prop('readOnly', true);
                    }
                }
                else {

                    var section_id = $('#formSelectFieldType').find('[name=section_id]').val();

                    form.find('[name=custom_id]').prop('readonly', false);

                    field_type = button.data('type');
                    form.find('[name=field_type]').val(field_type);

                    form.find('[name=section_id]').val(section_id);

                    modal.find('.modal-title').text("Add a " + strReplaceAll(field_type, "_", " ") + " field");

                    initFieldType(field_type);
                }

                if (!field_type || field_type.length == 0) {
                    return false;
                }

            }

            function initFieldType(fieldType, fieldItem) {
                var form = $('#formAddEditField');
                var valueDiv = $('#fieldValueDiv');
                var defValueDiv = $('.fieldDefValueDiv');
                var placeholderDiv = form.find('.placeholderDiv');
                var isRequiredDiv = form.find('.isRequiredDiv');
                var isIndexedDiv = form.find('.isIndexedDiv');
                var isMetaVariableDiv = form.find('.isMetaVariableDiv');
                var nbOfItemsDiv = form.find('.nbOfItemsDiv');
                var fieldDescriptionDiv = form.find(".fieldInfoDescription");

                fieldDescriptionDiv.show();
                form.find('.fieldSpecific,.selectType,.imageFormat,#advanced-param-field-options,#tagsListMainDiv,.booleanType,.urlType,.selectedTemplates').hide();
                valueDiv.html('');
				
                defValueDiv.html("");
				
				$(".nav-link").first().tab("show");
				
                var showValue = false;
                var showDefValue = false;
                var showIsRequired = true;
                var showPlaceholder = false;
                var showNbOfItems = true;
				
				let langIds = form.find('[name=langueIds]');
                switch (fieldType) {
                    case "text":
                        showPlaceholder = true;
						var input = $('<input type="text" class="form-control" name="default_value" value="">');
						defValueDiv.html(input);
                        form.find("#advanced-param-field-options").show();
						if (fieldItem && fieldItem.data("lang_data")) {
							let langData = fieldItem.data("lang_data");							
							for(let i=0;i<langData.length; i++) {
								$("#fieldDefValueDiv_"+langData[i].langue_id).find("input[name=default_value]").val(langData[i].default_value);
							}
						}
                        showDefValue = true;
                        break;

                    case "number":
                        showPlaceholder = true;
                        var input = $('<input type="text" class="form-control" name="default_value" value="" '
                                + ' onkeyup="allowFloatOnly(this)"  onblur="allowFloatOnly(this, true)" >');
                        defValueDiv.html(input);
                        form.find("#advanced-param-field-options").show();
						if (fieldItem && fieldItem.data("lang_data")) {
							let langData = fieldItem.data("lang_data");
							for(let i=0;i<langData.length; i++) {
								$("#fieldDefValueDiv_"+langData[i].langue_id).find("input[name=default_value]").val(langData[i].default_value);
							}
						}
                        showDefValue = true;
                        break;

                    case "URL":
                        
                        showPlaceholder = true;
                        form.find(".urlType").show();
                        var input = $('<input type="text" class="form-control" name="default_value" value="">');
                        defValueDiv.html(input);
                        if(fieldItem && fieldItem.data("lang_data")) {
                            let urlType = "url";
                            if(fieldItem.data("field_specific_url_type")) 
                                urlType = fieldItem.data('field_specific_url_type');
                            
                            form.find('[name="field_specific_url_type"]').val(urlType);
                            
							let langData = fieldItem.data("lang_data");
                            let urlLabels = [];
							for(let i=0;i<langData.length; i++) {
								var url_value = "";
								var url_openType = "";
                                var url_label = "";
								var defaultValue = langData[i].default_value.trim();
                                
								try{
									defValList = JSON.parse(defaultValue);
									url_value = defValList[0];
									url_openType = defValList[1];
                                    if(defValList[2] !== undefined){
                                        url_label = defValList[2];
                                        urlLabels.push({
                                            fieldId : "#fieldDefValueDiv_"+langData[i].langue_id,
                                            urlLabel: url_label
                                        });
                                    }
								} catch(ex){
									url_value  = defaultValue;
								}

								let _htmlField = $("#fieldDefValueDiv_"+langData[i].langue_id).find("input[name=default_value]");								
								_htmlField.val(url_value);
                                
								initUrlFieldInput(_htmlField);

                                if(url_openType.length > 0){
									_htmlField.data('url-generator').setOpenType(url_openType);
								}
							}

                            if(urlType == "url & label") {
                                form.find('[name="field_specific_url_type"]').trigger("change");
                                $.each(urlLabels,function(idx, val){
                                    $(val.fieldId).find("input[name='url-gen-label']").val(val.urlLabel);
                                });
                            }
						}
						else {
							for(let i=0;i<langIds.length;i++)
							{
								let _htmlField = $("#fieldDefValueDiv_"+$(langIds[i]).val()).find("input[name=default_value]");									
								initUrlFieldInput(_htmlField);
							}
						}
                        showDefValue = true;
                        break;

                    case "multiline_text":
                        showPlaceholder = true;
                        var input = $('<textarea class="form-control" name="default_value"></textarea>');
                        defValueDiv.html(input);
                        if (fieldItem && fieldItem.data("lang_data")) {
							let langData = fieldItem.data("lang_data");
							for(let i=0;i<langData.length; i++) {
								let _htmlField = $("#fieldDefValueDiv_"+langData[i].langue_id).find("textarea[name=default_value]");
								_htmlField.text(langData[i].default_value);
							}
                        }
                        showDefValue = true;
                        break;

                    case "text_formatted":
                        var input = $('<textarea class="form-control" name="default_value"></textarea>');
                        defValueDiv.html(input);
                        if (fieldItem && fieldItem.data("lang_data")) {
							let langData = fieldItem.data("lang_data");
							for(let i=0;i<langData.length; i++) {
								let _htmlField = $("#fieldDefValueDiv_"+langData[i].langue_id).find("textarea[name=default_value]");
								_htmlField.text(langData[i].default_value);
							}
                        }
                        showDefValue = true;
                        break;
                    case "boolean":
                        showIsRequired = false;
                        form.find(".booleanType").show();
                        var valueHtml = $('#booleanFieldValueTemplate').clone(true).attr('id', null);
                        valueDiv.html(valueHtml);
                        showValue = true;

                        if (fieldItem) {
                            form.find('[name="field_specific_boolean_type"]').val(fieldItem.data('field_specific_boolean_type'));

                            var valueStr = fieldItem.data('value');
                            if (isJsonString(valueStr)) {
                                valueJson = JSON.parse(valueStr);
                                valueDiv.find('[name=value_on]').val(valueJson.on);
                                valueDiv.find('[name=value_off]').val(valueJson.off);
                            }

                            var default_value = fieldItem.data('lang_data')[0].default_value;
                            var defValueInput = valueDiv.find('.default_value_' + default_value);
                            if (defValueInput.length > 0) {
                                defValueInput.prop('checked', true);
                            }
                        }
                        break;
                    case "bloc":
                        showIsRequired = false;
                        form.find(".selectedTemplates").show();
                        form.find("[name='field_specific_selected_templates']").first().siblings("[name='field_specific_selected_templates']").remove();
                        var valueHtml = $('#blocFieldValueTemplate').clone(true).attr('id', null);
                        valueDiv.html(valueHtml);
                        loadAutoComplete($(valueHtml).find(".asm-autocomplete-field"));
                        showValue = true;
                        if (fieldItem) {
                            let valuesArray = fieldItem.data('field_specific_selected_templates');
                            duplicateElement(form,"field_specific_selected_templates",valuesArray.length-1);
                            form.find('[name=field_specific_selected_templates]').each(function(index) {
                                try{
                                    $(this).val(valuesArray[index]);
                                }catch(ex){
                                    $(this).val('');
                                }
                                $(this).trigger("change");
                            });
                           
                            var default_value = "";
                            let templateId = "";
                            let templateName = "";
                            let blocName = "";
                            let blocId = "";

                            try{
                                default_value = JSON.parse(fieldItem.data('lang_data')[0].default_value);
                                templateId = default_value.template_id;
                                templateName = default_value.template_name;
                                blocName = default_value.bloc_name;
                                blocId = default_value.bloc_id;
                            } catch(ex){
                                try{
                                    default_value = fieldItem.data('lang_data')[0].default_value;
                                    templateId = default_value.template_id;
                                    templateName = default_value.template_name;
                                    blocName = default_value.bloc_name;
                                    blocId = default_value.bloc_id;
                                }catch(innerEx){}
                            }

                            valueDiv.find('.default_value_templates').val(templateId).trigger("change");

                            setTimeout(function(){
                                valueDiv.find('[name="bloc_name"]').val(blocName).trigger($.Event("keydown", { key: "Enter", keyCode: 13, which: 13, trigger: true }));
                            },1000);                            
                        }
                        
                        break;
                    case "select":
                        
                        var valueEle = $('#selectFieldValueTemplate').clone(true).attr('id', null);

                        fieldDescriptionDiv.hide();
                        form.find(".selectType").show();

                        valueDiv.html(valueEle);

                        Array.from(valueDiv).forEach(valDiv=>{
                            Array.from(valDiv.querySelectorAll(".selectValueList")).forEach(element => {
                                Sortable.create(element,{animation:100});
                            });
                        });
                        
                        if (fieldItem) {
                            var valueStr = fieldItem.data('value');
                            //for select case the default value for all languages will always be same so we just pick the default value from first language
                            var default_value;
                            if(fieldItem.data("is_query") == "1"){
                                if(!form.find("#option_query").prop("checked"))
                                    form[0].querySelector("#option_query").click();

                                var q_type = (fieldItem.data("query_type").length>0)? fieldItem.data("query_type") : 'free';
                                
                                $.each(form.find(".query-select > .selectValueListItem > select").find("option"),function(idx,opt){                                    
                                    ($(opt).attr("value") == q_type)? $(opt).prop("selected",true).trigger("change") : null
                                });

                                if(q_type!="free") {
                                    form.find("[name=select-field-for-value]").val(valueStr.split(",")[0]);
                                    form.find("[name=select-field-for-label]").val(valueStr.split(",")[1]);
                                }else
                                    form.find("#free-query").val(valueStr);
                                
                            }
                            else{
                                form.find("#option_query").prop("checked",false);

                                if(fieldItem.data("lang_data")[0])
                                    default_value = fieldItem.data("lang_data")[0].default_value;
                                    
                                if (isJsonString(valueStr)) {
                                    //remove empty li
                                    valueEle.find('li:first').remove();

                                    var valueList = JSON.parse(valueStr);
                                    var addBtn = valueEle.find('button.addBtn');
                                    $.each(valueList, function(index, valueItem) {
                                        addSelectValue(addBtn, valueItem);
                                    });

                                    valueEle.find('li.selectValueListItem').each(function(index, li) {
                                        li = $(li);
                                        if (default_value == li.find('[name=option_value]').val()) {
                                            li.find('[name=default_value]').prop('checked', true);
                                            return false;
                                        }
                                    });
                                }
                            }
                        }
                        else {
                            valueEle.find('[name=default_value]').prop('checked', true);
                        }
                        showValue = true;
                        break;

                    case "image":
                        var defValueEle = $('#imageFieldDefValueTemplate').clone(true).attr('id', null);
                        let defaultLimit = 1;
                        
                        defValueEle.find(".image_card").data("img-limit",defaultLimit);
                        form.find('.imageFormat').show();

                        defValueDiv.html(defValueEle);
                        showDefValue = true;
                        let asp = "Free";
                        
                        if (fieldItem && fieldItem.data("lang_data")) {
                            asp = fieldItem.data("value");
                            form.find('[name="media-type"]').val(fieldItem.data('field_specific_media_type'));
							let langData = fieldItem.data("lang_data");
							for(let i=0;i<langData.length; i++)
							{
								let str = langData[i].default_value;
								let image_value = str.substring(0, str.indexOf(','));
								let image_alt = str.substring(str.indexOf(',') + 1);

								let _htmlDiv = $("#fieldDefValueDiv_"+langData[i].langue_id);
                                let _imageSpan = $(`<span class="ui-state-media-default mx-1" style="padding:0px;display: inline-block;">
                                            <div class="bloc-edit-media">
                                                <button type="button" class="btn btn-primary mx-1" style="margin-right: .10rem;" onclick='loadFieldImageV2(this,true)'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
                                                <button type="button" class="btn btn-danger mx-1" style="margin-right: .1rem;" onclick='clearFieldImageV2(this)' ><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></button>
                                            </div>
                                            <div class="bloc-edit-media-bgnd" style="height:100%; width:100%; min-width:145px; min-height:145px; position:absolute; left:0; top:0">&nbsp;</div>
                                            <input type="hidden" name="image_value" class="image_value" />
                                            <input type="hidden" name="image_alt" class="image_alt" />
                                            <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="">
                                        </span>`);
                                
								_imageSpan.find('input.image_value').val(image_value);
                                _imageSpan.find('input.image_alt').val(image_alt);
								let imgEle = _imageSpan.find('img');
                                let imageSrc = "";

								if(image_value.length > 0){
									imageSrc = window.IMAGE_URL_PREPEND + image_value;
                                    _htmlDiv.find(".no-img").show();
                                    _htmlDiv.find(".load-img").hide();
                                    _imageSpan.insertBefore(_htmlDiv.find(".ui-state-media-default:last"));
								}
								else{
                                    _htmlDiv.find(".no-img").hide();
                                    _htmlDiv.find(".load-img").show();
								}
                                imgEle.attr('src', imageSrc);
								
							}
                        }

                        $.each(form.find(".image-format"),function(idx,obj){
                            if($(obj).hasClass("active")) $(obj).removeClass("active");
                            if($(obj).text() == asp.replace("x",":")) $(obj).click();
                        });
                        break;
                    case "file":
                        var defValueEle = $('#fileFieldDefValueTemplate').clone(true).attr('id', null);
                        defValueDiv.html(defValueEle);
                        showDefValue = true;
                        if (fieldItem && fieldItem.data("lang_data")) {
							let langData = fieldItem.data("lang_data");
							for(let i=0;i<langData.length; i++)
							{
								var default_value = langData[i].default_value;
								$("#fieldDefValueDiv_"+langData[i].langue_id).find("input[name=default_value]").val(default_value);
								$("#fieldDefValueDiv_"+langData[i].langue_id).find("input.file_value").val(default_value);
							}
                        }
                        break;
                    case "tag":
                        var defValueEle = $('#tagFieldDefValueTemplate').html();
                        defValueDiv.html(defValueEle);
                        if(defValueDiv.parent().find(".tagsDiv").length==0){
                            let tmp = document.getElementById("tagsDiv").cloneNode(true);
                            tmp.removeAttribute("id");
                            defValueDiv.parent().append(tmp);
                        }
                        form.find('#tagsListMainDiv').show();
                        showDefValue = true;

                        resetSelectFields();
                        if(fieldItem && fieldItem.data("value").length>0){
                            let tmpSavedFolders=fieldItem.data("value").split(",");
                            if(document.getElementById("tagsList").children.length<=tmpSavedFolders.length && tmpSavedFolders.length>0){
                                for(let i =0;i<tmpSavedFolders.length;i++) {
                                    initTagsFolderSelect();
                                }
                            }

                            if(selectedFolders.length==0 && tmpSavedFolders.length>0){
                                selectedFolders = tmpSavedFolders;
                            }
                            for(let i=0;i<selectedFolders.length;i++) {
                                let tagsSelect = document.getElementById("tags_folder_list_"+i);
                                for(let j=0;j<tagsSelect.options.length;j++) {
                                    if(tagsSelect.options[j].value===selectedFolders[i]){
                                        tagsSelect.options[j].selected=true;
                                        break;
                                    }
                                }
                            }
                            reloadTags();
                        }
                        
                        if (fieldItem && fieldItem.data("lang_data")) {
							let langData = fieldItem.data("lang_data");
							for(let i=0;i<langData.length; i++)
							{
								let _htmlDiv = $("#fieldDefValueDiv_"+langData[i].langue_id);
								let tagInputField = _htmlDiv.find("input.tagInputField");
								initTagAutocomplete(tagInputField);								
								tagInputField.data("data-nb-items",parseInt(fieldItem.data('nb_items')));
								
								var defValue = langData[i].default_value;
								if (isJsonString(defValue)) {
									var tagsList = JSON.parse(defValue);
									$.each(tagsList, function(index, tag) {
										if (tag.trim().length > 0) {
											addTagGeneric(tag, tagInputField);
										}
									});
								}else{
                                    
                                }
							}
                        }else{
							for(let i=0;i<langIds.length; i++)
							{
								let _htmlDiv = $("#fieldDefValueDiv_"+$(langIds[i]).val());
								let tagInputField = _htmlDiv.find("input.tagInputField");
								initTagAutocomplete(tagInputField);								
								tagInputField.data("data-nb-items",1);
							}                            
                        }
                        break;
                    case "date":
                        form.find('.fieldSpecific_date').show();
                        var defValueEle = $('#dateFieldDefValueTemplate').clone(true).attr('id', null);
                        defValueDiv.html(defValueEle);
                        showDefValue = true;
                        if (fieldItem) {
							var valueStr = fieldItem.data('value');

							if (isJsonString(valueStr)) {
								var value = JSON.parse(valueStr);
								if (typeof value.date_type != 'undefined') {
									form.find('[name=date_type]').val(value.date_type);
								}
								if (typeof value.date_format != 'undefined') {
									form.find('[name=date_format]').val(value.date_format);
								}
							}
							
							if (fieldItem.data("lang_data")) {
								let langData = fieldItem.data("lang_data");
								for(let i=0;i<langData.length; i++)
								{
									let defValueStr = langData[i].default_value;								
									let _htmlDiv = $("#fieldDefValueDiv_"+langData[i].langue_id);
									if (isJsonString(defValueStr)) {
										var defValue = JSON.parse(defValueStr);
                                        
										if (Array.isArray(defValue) && defValue.length == 2) {
                                            _htmlDiv.find('[name=date_value_start]').val(defValue[0]);
                                            _htmlDiv.find('[name=date_value_end]').val(defValue[1]);
										}
									}
								}
							}
                        }
                        onChangeDateTypeFormat();
                        break;

                    case "view_commercial_catalogs":
                    case "view_commercial_products":

                        showNbOfItems = false;

                        break;

                    case "view_structured_contents":
                    case "view_structured_pages":

                        showNbOfItems = false;

                        var valueHtml = $('#viewStructuredFieldValueTemplate').html();
                        valueDiv.html(valueHtml);
                        var catalogValue = '';
                        if(fieldItem){
                            catalogValue = fieldItem.data('value');
                        }
                        loadStructuredCatalogTypes(valueDiv.find('select'), catalogValue, fieldType);
                        showValue = true;

                        break;

                }//switch
				
				if(showPlaceholder || showDefValue) $("#languageTabs").show();
				else $("#languageTabs").hide();

                valueDiv.parents('.form-group:first').toggle(showValue);

                defValueDiv.each(function(){
					$(this).parents('.form-group:first').toggle(showDefValue);
				});

                nbOfItemsDiv.toggle(showNbOfItems);

                if (showIsRequired) {
                    var isRequiredVal = false;
                    var isIndexedVal = false;
                    var isBulkModificationVal = false;
                    var isMetaVariableVal = false;

                    if (fieldItem) {
                        isRequiredVal = (fieldItem.data('is_required') == "1");
                        isIndexedVal = (fieldItem.data('is_indexed') == "1");
                        isBulkModificationVal = (fieldItem.data('is_bulk_modify') == "1");
                        isMetaVariableVal = (fieldItem.data('is_meta_variable') == "1");
                    }

                    form.find('[name=is_required]').prop('checked', isRequiredVal);
                    form.find('[name=is_indexed]').prop('checked', isIndexedVal);
                    form.find('[name=is_bulk_modify]').prop('checked', isBulkModificationVal);
                    form.find('[name=is_meta_variable]').prop('checked', isMetaVariableVal);

                    isRequiredDiv.show();
                    isIndexedDiv.show();
                    isMetaVariableDiv.show();
                }
                else {
                    isRequiredDiv.hide();
                    isIndexedDiv.hide();
                    isMetaVariableDiv.hide();
                }

                if (showPlaceholder) {
                    var placeholderVal = "";
					if (fieldItem && fieldItem.data("lang_data")) {
						let langData = fieldItem.data("lang_data");
						for(let i=0;i<langData.length; i++)
						{
							$("#placeholderDiv_"+langData[i].langue_id).find("input[name=placeholder]").val(langData[i].placeholder);
						}
					}
                    placeholderDiv.show();
                }
                else {
                    placeholderDiv.hide();
                }
                if(fieldType == 'image') form.find('[name="media-type"]').trigger("change");
            }
        </script>
    </body>
</html>