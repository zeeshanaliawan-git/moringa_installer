<!-- to be included in structuredItemEditor and blocAddEdit -->
<%
    if (parseNull(GlobalParm.getParm("URL_GEN_JS_URL")).length() > 0) {
%>
<script type="text/javascript" src='<%=GlobalParm.getParm("URL_GEN_JS_URL")%>'></script>
<script type="text/javascript">
    window.URL_GEN_AJAX_URL = '<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>';
</script>
<%  }%>
<style>
    .bg-success .btn-link{
        color:white !important;
    }
</style>
<div class="d-none">
    <div id="template_section">
        <div class="card-header bloc_section_btn #SECTION_ID# section-#COLOR# col-12 mb-1 p-0 bg-#COLOR#"
            id='section_btn_#SECTION_ID#' >
            <div class="btn-group w-100">
                <button type="button"
                        class="btn btn-block text-left btn-lg text-dark"
                        onclick="toggleSection('#SECTION_ID#')" >
                    <span>#SECTION_NAME#</span>
                    <span class="section_title"></span>
                    <span class="section-description">#SECTION_DESCRIPTION#</span>
                </button>
                <span type="button" class="btn btn-secondary duplicableOnly" >
                    <input type="text" name="sectionOrder" class="sectionOrderInput text-center rounded"
                        value="" style="width:40px"
                        onkeyup="allowNumberOnly(this)"
                        onkeydown="onKeyDownSectionOrder(event)"
                        onchange="onChangeSectionOrder(this)"  >
                </span>
                <span type="button" class="btn btn-secondary duplicableOnly"
                    onclick="onSectionUpDown(this, 1)">
                    <i data-feather="chevron-down"></i>
                </span>
                <button type="button" class="btn btn-danger duplicableOnly deleteSectionBtn" onclick="deleteSection(event, '#SECTION_ID#')">
                    <i data-feather="x"></i>
                </button>
                #BULK_MODIFY_CHECK#
            </div>
        </div>
        <div class="bloc_section #SECTION_ID# collapse card-body p-3 #IS_COLLAPSE#" id="#SECTION_ID#">
        </div>

    </div>
    <div id="template_add_section">
        <div class="add_section text-right mb-2">
            <button type="button" class="btn btn-success addSectionBtn"
                    onclick="addSection(this, '#SECTION_ID#','#ATTRIBUTES#','#SPECIFICATION#')">Add #SECTION_NAME# Section</button>
        </div>
    </div>
    <div id="template_add_field">
        <div class="add_field text-right">
            <button type="button" class="btn btn-success"
                    onclick="addField(this, '#FIELD_ID#')">Add a field</button>
        </div>
    </div>
    <div id="template_section_field_text">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'text')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group">
                    <input type="text" name="#FIELD_ID#" class="form-control textInput" value="">
                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_number">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'number')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group">
                    <input type="text" name="#FIELD_ID#" class="form-control textInput" value=""
                           onkeyup="allowFloatOnly(this)"  onblur="allowFloatOnly(this, true)" >
                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_URL">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'url')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group urlField">
                    <input type="text" class="form-control urlInput" data-lang-id="#LANG_ID#" name="#FIELD_ID#" value="">
                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger rounded-right d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_tag">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'tag')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group">
                    <input type="text" name="#FIELD_ID#" class="form-control tagInputField" value=""
                           placeholder="search and add (by clicking return)" >
                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
                <div class="tagsDiv col-sm-12 form-group mt-3"></div>
            </div>
        </div>
    </div>
    <div id="template_section_field_multiline_text">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'multiline_text')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group">
                    <textarea name="#FIELD_ID#" class="form-control multilineInput" >#FIELD_VALUE#</textarea>
                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_text_formatted">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'text_formatted')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group ckeditorContainer">
                    <div class="form-control border-0 p-0" style="height:auto;">
                        <textarea name="#FIELD_ID#" class="form-control ckeditorField">#FIELD_VALUE#</textarea>
                    </div>
                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>

    </div>
    <div id="template_section_field_select">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'select')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group selectDiv">
                    <select name="#FIELD_ID#" class="custom-select selectInput" style="display:none;"></select>
                    <div class="position-relative w-100">
                        <input class="form-control autocomplete_input" data-name="#FIELD_ID#" type="text" placeholder="--Select--" autocomplete="off">
                        <ul class="autocomplete-items position-absolute w-100 p-0 ml-4" style="list-style-type: none; max-height: 140px; display: none;"></ul>
                    </div>

                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_product_attribute">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'select')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group selectDiv">
                    <select name="#FIELD_ID#" class="custom-select selectInput" style="display:none;"></select>
                    <div class="position-relative w-100">
                        <input class="form-control autocomplete_input" data-name="#FIELD_ID#" type="text" placeholder="--Select--" autocomplete="off">
                        <ul class="autocomplete-items position-absolute w-100 p-0 ml-4" style="list-style-type: none; max-height: 140px; display: none;"></ul>
                    </div>

                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_product_specification">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'text')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group">
                    <input type="text" name="#FIELD_ID_LABEL_INDEXED#" class="form-control is_indexed" value="" hidden>
                    <input type="text" name="#FIELD_ID_LABEL#" class="form-control specValue" value="" readonly="readonly">
                    <input type="text" name="#FIELD_ID#" class="form-control textInput" value="">
                    <div class="input-group-append">
                        <select class="form-control" name="#FIELD_ID_SELECT#" onchange="changeFieldSpec(this)">
                            <option value="custom" selected>Custom</option>
                            <option value="default">Identical to the default variant</option>
                        </select>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_boolean">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'boolean')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9 field-boolean">
                <div class="input-group">
                    <div class="input-group-text form-control">
                        <input class="mr-2 booleanInput" type="checkbox" name="#FIELD_ID#"
                               onchange="onFieldBooleanChange(this)">
                        <label class="form-check-label text-muted" for="#FIELD_ID#">
                            (value = <span class="fieldValue"></span>)
                        </label>
                    </div>
                    <div class="input-group-append deleteBtn">
                        <button type="button" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_date">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'date')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="input-group">
                    <input type="text" class="form-control date_field date_field_start"
                           name="#FIELD_ID#_start" value="" placeholder="start date">
                    <span class="input-group-text dateEndDiv" style="border-radius: 0;">/</span>
                    <input type="text" class="form-control date_field date_field_end dateEndDiv"
                           name="#FIELD_ID#_end" value="" placeholder="end date">
                    <div class="input-group-append deleteBtn">
                        <button type="button" class=" btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <span aria-hidden="true">&times;</span></button>
                    </div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_image">
        <div class="form-group row" >
            <input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'image')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME# <br>
                <div class="d-flex">
                    <div class="img-count">0</div>&nbsp;/&nbsp;<div class="img-limit">1</div>
                </div>
            </label>
            <div class="col-sm-9">
                <div class="card image_card">
                    <div class="card-body"> 
                        <span class="ui-state-media-default" style="padding:0px;display: inline-block;">
                            <div class="bloc-edit-media">
                                <button type="button" class="btn btn-success load-img" style="margin-right: .10rem;" onclick="loadFieldImageV2(this,false,'#FIELD_ID#')">Add a media</button>
                                <button type="button" class="btn btn-danger no-img disabled" style="margin-right: .10rem;display:none">No more media</button>
                            </div>
                            <div class="bloc-edit-media-bgnd" style="height:100%; width:100%;min-width:145px;min-height:145px;  position:absolute; left:0; top:0">&nbsp;</div>
                            <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="../img/add-picture-on.jpg">	
                        </span>														

                    </div>
                </div>
                <div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>
    <div id="template_section_field_file">
        <div class="form-group row" >
			<input type='checkbox' data-field_name="#FIELD_ID#" onclick="editField(event, this, 'file')" class="bulkEditChkbox d-none">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9">
                <div class="card file_card">
                    <div class="card-body text-center file_body">
                        <input type="hidden" name="#FIELD_ID#"
                               value="" class="file_value">
                        <input type="text" class="form-control bg-secondary file_value"
                               placeholder="Select a file" value=""
                               style="width: 95%;" onfocus="return false;">
                        <div class="card-img-overlay p-1">
                            <button type="button" class="btn btn-danger btn-sm float-right d-none#SHOW_DELETE#"
                                    onclick="deleteField(event, this)">
                                <span aria-hidden="true">&times;</span></button>
                        </div>
                    </div>
                    <div class="card-footer file_footer">
                        <div class="form-group row mb-0">
                            <div class="col-6">
                                <button type="button" class="btn btn-link file-select-btn"
                                        onclick="loadFieldFile(this)">Select file
                                </button>
                            </div>
                            <div class="col-6">
                                <button type="button" class="btn btn-link text-danger"
                                        onclick="clearFieldFile(this)">Delete file
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div>
                    #BULK_MODIFY_CHECK#
                </div>
            </div>
        </div>
    </div>

    <div id="template_section_field_bloc">
        <div class="form-group row" >
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9 ">
                <div class="input-group mb-2">	
                    <select class="custom-select bloc-templates" name="#FIELD_ID#_template">
                        <option value="">-- SELECT TEMPLATE --</option>
                        <option value="all">-- All --</option>
                    </select>
                    <div class="asm-autocomplete">
                        <input type="text" class="form-control bloc-name asm-autocomplete-field" name="#FIELD_ID#_bloc_name">
                        <input type="hidden" class="form-control bloc-id" name="#FIELD_ID#_bloc_id">
                    </div>
                    <div class="input-group-append">
                        <button class="btn btn-primary edit-bloc" type="button" style=""><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
                        <button class="btn btn-success add-bloc" type="button" style="display: none;"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-plus"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg></button>
                        <button class="btn btn-danger remove-bloc" type="button" title="clear field" style=""><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                    </div>
                    
                    <div class="invalid-feedback">Please select a template; it cannot be empty.</div>
                    
                    <div class="input-group-append deleteBtn ml-1">
                        <button type="button" title="delete a field" class="btn btn-danger d-none#SHOW_DELETE#"
                                onclick="deleteField(event, this)">
                            <i data-feather="x"></i></button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="template_section_field_view_generic">
        <div class="form-group row viewField">
            <label class="col-sm-3 col-form-label" title="#FIELD_DESCRIPTION#">#FIELD_NAME#</label>
            <div class="col-sm-9" id="filter_fields_col">
                <div class="row mb-3 active_promotion_filter_row">
                    <label class="col-3 col-form-label">Filter active promotions</label>
                    <div class="col">
                        <div class="input-group viewPromotionFilterDiv">
                            <input name="promotionFilterCheckbox" class="form-check-input mt-2" type="checkbox">
                        </div>
                    </div>
                </div>
                <div class="row mb-3 load_sub_folders">
                    <label class="col-3 col-form-label">Load Sub Folders</label>
                    <div class="col">
                        <div class="input-group loadSubFoldersFileter">
                            <input name="subFoldersCheckbox" class="form-check-input mt-2" type="checkbox" checked>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <label class="col-3 col-form-label">Folder</label>
                    <div class="col">
                        <div class="input-group mb-1 viewFolderSelect">
                            <select name="folder" class="custom-select rounded-right"
                                    onchange="onChangeViewFolderSelect(this)">
                                <option value="">-- list of folders --</option>
                            </select>
                            <div class="invalid-feedback">Cannot be empty.</div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col text-right mb-1">
                        <button type="button" class="btn btn-success addFolderBtn"
                                onclick="addViewFolder(this)">Add folder
                        </button>
                    </div>
                </div>
                <div class="row">
                    <label class="col-3 col-form-label">Sort by</label>
                    <div class="col">
                        <div class="input-group mb-1 viewSortBySelect">
                            <select name="sortByColumn" class="custom-select">
                                <!-- to be loaded from as per field type -->
                            </select>
                            <select name="sortByDirection" class="custom-select">
                                <option value="ASC">Ascending</option>
                                <option value="DESC">Descending</option>
                            </select>

                        </div>

                    </div>
                </div>
                <div class="row">
                    <div class="col text-right mb-1 ">
                        <button type="button" class="btn btn-success addSortByBtn"
                                onclick="addViewSortBy(this)">Add sort by</button>
                    </div>
                </div>

                <div class="row">
                    <label class="col-3 col-form-label">Filter by</label>
                    <div class="col">
                        <div class="input-group mb-1 viewFilterByTemplate d-none">
                            <select name="filterByColumn" class="custom-select" >
                                <!-- to be loaded from as per field type -->
                            </select>
                            <select name="filterByOperator" class="custom-select" >
                                <option value="is">is</option>
                                <option value="not_is">not is</option>
                                <option value="like">like</option>
                                <option value="not_like">not like</option>
                                <option value="greater_than">greater than</option>
                                <option value="greater_than_or_equal">greater than or equal</option>
                                <option value="less_than">less than</option>
                                <option value="less_than_or_equal">less than or equal</option>
                                <option value="starts_with">starts with</option>
                                <option value="not_starts_with">not starts with</option>
                                <option value="ends_with">ends with</option>
                                <option value="not_ends_with">not ends with</option>
                            </select>
                            <div class="position-relative">
                                <input type="text" name="filterByValue" class="form-control" value="">
                                <ul class="autocomplete-list position-absolute p-0 m-0 w-100" style="list-style-type:none;max-height:160px;overflow-x: auto;">
                                </ul>
                            </div>
                            <div class="input-group-append">
                                <button type="button" class="btn btn-danger"
                                        onclick="deleteParent(this, '.viewFilterBySelect:first')">
                                    <span aria-hidden="true">&times;</span></button>
                            </div>

                        </div>

                    </div>
                </div>
                <div class="row">
                    <div class="col text-right mb-1">
                        <button type="button" class="btn btn-success addFilterByBtn"
                                onclick="addViewFilterBy(this)">Add filter
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="template_view_columns_view_commercial_catalogs">
        <select name="folder" class="custom-select productFoldersCatalogSelect">
            <option value="">-- list of folders --</option>
        </select>
        <select name="sortByColumn" class="custom-select">
            <option value="f.name">Name</option>
            <option value="f.created_on">Last updated</option>
            <option value="f.updated_on">Created datetime</option>
            <option value="f.catalog_type">Type</option>
            <option value="f.lang_1_heading">Title</option>
            <option value="fd.page_path">Path</option>
        </select>

        <select name="filterByColumn" >
            <option value="f.name">Name</option>
            <option value="f.created_on">Last updated</option>
            <option value="f.updated_on">Created datetime</option>
            <option value="f.catalog_type">Type</option>
            <option value="f.catalog_uuid">UUID</option>
            <option value="f.lang_1_heading">Title</option>
            <option value="fd.page_path">Path</option>
            <option value="f2.publish_status">Publish status</option>
        </select>
    </div>

    <div id="template_view_columns_view_commercial_products">
        <select name="folder" class="custom-select productFoldersSelect">
            <option value="">-- list of folders --</option>
        </select>
        <select name="sortByColumn" class="custom-select">
            <option value="p.lang_1_name">Name</option>
            <option value="p.created_on">Last updated</option>
            <option value="p.updated_on">Created datetime</option>
            <option value="f.name">Folder name</option>
            <option value="p2.publish_status">Publish status</option>
            <option value="p.brand_name">Manufacturer</option>
            <option value="pvd.name">Variant name</option>
            <option value="pv.price">Price</option>
            <option value="pv.is_active">Activated</option>
            <option value="pv.order_seq">Order Seq</option>
            <option value="pd.seo_title">Title</option>
            <option value="pd.page_path">Path</option>
        </select>
        <select name="filterByColumn" >
            <option value="p.lang_1_name">Name</option>
            <option value="pv.sku">SKU</option>
            <option value="p.uuid">UUID</option>
            <option value="p2.publish_status">Publish status</option>
            <option value="p.created_on">Last updated</option>
            <option value="p.updated_on">Created datetime</option>
            <option value="f.name">Folder name</option>
            <option value="f.uuid">Folder UUID</option>

            <option value="p.brand_name">Manufacturer</option>
            <option value="ptags.label">Tag</option>

            <option value="attrib_color.value">Color</option>
            <option value="attrib_storage.value">Storage</option>

            <option value="pvd.name">Variant name</option>
            <option value="pv.is_active">Activated</option>
            <option value="pv.sticker">Sticker</option>
            <option value="pv.price">Price</option>

            <option value="pvd.action_button_desktop">Button desktop label</option>
            <option value="pvd.action_button_desktop_url">Button desktop url</option>
            <option value="pvd.action_button_mobile">Button mobile label</option>
            <option value="pvd.action_button_mobile_url">Button mobile url</option>

            <option value="pd.seo_title">Title</option>
            <option value="pd.page_path">Path</option>
        </select>
    </div>


    <div id="template_view_columns_view_structured_contents">
        <select name="folder" class="custom-select contentFolderSelect structuredFolderSelect">
            <option value="">-- list of folders --</option>
        </select>
        <select name="sortByColumn" class="custom-select">
            <option value="p.name">Name</option>
            <option value="p.created_ts">Last updated</option>
            <option value="p.updated_ts">Created datetime</option>
            <option value="p.published_ts">Published datetime</option>
            <option value="f.name">Folder name</option>
        </select>
        <select name="filterByColumn">
            <option value="p.name">Name</option>
            <option value="p.publish_status">Status</option>
            <option value="p.created_ts">Last updated</option>
            <option value="p.updated_ts">Created datetime</option>
            <option value="p.published_ts">Published datetime</option>
            <option value="f.name">Folder name</option>
        </select>
    </div>


    <div id="template_view_columns_view_structured_pages">
        <select name="folder" class="custom-select pagesFolderSelect structuredFolderSelect">
            <option value="">-- list of folders --</option>
        </select>
        <select name="sortByColumn" class="custom-select">
            <option value="p.name">Name</option>
            <option value="p.created_ts">Last updated</option>
            <option value="p.updated_ts">Created datetime</option>
            <option value="p.published_ts">Published datetime</option>
            <option value="f.name">Folder name</option>
        </select>
        <select name="filterByColumn">
            <option value="p.name">Name</option>
            <option value="p.publish_status">Status</option>
            <option value="p.created_ts">Last updated</option>
            <option value="p.updated_ts">Created datetime</option>
            <option value="p.published_ts">Published datetime</option>
            <option value="f.name">Folder name</option>
        </select>
    </div>

</div>
<script type="text/javascript">
    $ch.bulkModificationMode = false;
    let callLangDetails = true;
	var validBulkModifSections = [];
    $ch.contextPath = '<%=request.getContextPath()%>/';
    $ch.loadingBlocData = false;
    window.IMAGE_URL_PREPEND = '<%=getImageURLPrepend(getSiteId(session))%>';
    window.MEDIA_LIBRARY_UPLOADS_URL = '<%=GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL")+getSiteId(session)%>';
    let siteId= '<%=getSiteId(session)%>';
    window.CATALOG_ROOT = '<%=GlobalParm.getParm("CATALOG_ROOT") + "/"%>';
    window.URL_GEN_AJAX_URL = '<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>';
    let bulkModificationScreen = false;

    let productId = "";
    let productUuid = "";
    let folderTypePages = "<%=Constant.FOLDER_TYPE_PAGES%>";
    let folderTypeContents = "<%=Constant.FOLDER_TYPE_CONTENTS%>";
    let langId1 = "<%=langsList.get(0).getLanguageId()%>";
</script>
<script src="<%=request.getContextPath()%>/js/template-function.js?__v=<%=com.etn.beans.app.GlobalParm.getParm("CSS_JS_VERSION")%>"></script>
<%@ include file="./templateUtilities/templateEditorUtility.jsp"%>