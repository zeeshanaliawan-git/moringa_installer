<!-- Modals -->

        <div class="modal fade" id="modalAddEditSection" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
                <div class="modal-content">
                    <form id="formAddEditSection" action="" novalidate >
                        <input type="hidden" name="section_id" value="">
                        <input type="hidden" name="parent_section_id" value="">
                        <div class="modal-header">
                            <h5 class="modal-title"></h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div class="mb-2 text-right">
                                <button type="submit" class="btn btn-primary" >Save</button>
                            </div>
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapseSectionInfo" role="button" aria-expanded="true" aria-controls="collapseSectionInfo">
                                    <strong>Section Information</strong>
                                </div>
                                <div id="collapseSectionInfo" class="collapse show" style="border: medium none;">
                                    <div class="card-body">
                            <div class="form-group row">
                                <label class="col-sm-4 col-form-label">Section name</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" name="name" value=""
                                           maxlength="100" required="required" onchange="onNameChange(this)">
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-4 col-form-label">Section ID</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" name="custom_id" value=""
                                           maxlength="100" required="required"
                                           onkeyup="onKeyupCustomId(this)" onblur="onKeyupCustomId(this)">
                                    <div class="invalid-feedback ">
                                        Cannot be empty or duplicate.
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-4 col-form-label">Nb of items</label>
                                <div class="col-sm-4">
                                    <select class="custom-select" name="nb_items_select"
                                            onchange="onChangeNbItems(this)">
                                        <option value="1">limited</option>
                                        <option value="0">unlimited</option>
                                    </select>
                                </div>
                                <div class="col-sm-4">
                                    <input type="text" class="form-control" name="nb_items" value="1"
                                           maxlength="2" required="required"
                                           onkeyup="allowNumberOnly(this)" onblur="allowNumberOnly(this)">
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>

                                        <div class="form-group row">
                                            <label class="col-sm-4 col-form-label">Collapse by default</label>
                                            <div class="col-sm-8">
                                                 <select class="custom-select" name="collapse-by-default">
                                                    <option value="0">Open</option>
                                                    <option value="1">Close</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="form-group row">
                                            <label for="section-description" class="col-sm-4 col-form-label">Description</label>
                                            <div class="col-sm-8">
                                                <textarea class="form-control" name="section-description" rows="3" spellcheck="false"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapseSectionAdvanced" role="button" aria-expanded="true" aria-controls="collapseSectionAdvanced">
                                    <strong>Advanced 
                                        <a href="#" data-toggle="tooltip" title="" data-original-title="Default tooltip"></a>
                                        <svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                                    </strong>
                                </div>
                                <div id="collapseSectionAdvanced" class="collapse" style="border: medium none;">
                                    <div class="card-body">
                                        <div class="form-group row">
                                            <label class="col-sm-3 col-form-label">Display by default</label>
                                            <div class="col">
                                                 <select class="custom-select" name="display-by-default">
                                                    <option value="1">Yes</option>
                                                    <option value="0">No</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <label class="col-sm-3 col-form-label">Custom Css</label>
                                            <div class="col">
                                               <div class="w-100 ace-editor-css" style="min-height:100px"></div>
                                               <input type='hidden' name='custom-css-value'>
                                            </div>
                                        </div>
                                        <div class="js-editor">
                                            <div class="form-group row">
                                                <label class="col-sm-3 col-form-label">JS on trigger</label>
                                                <div class="col">
                                                    <select class="custom-select" name="js-ontrigger">
                                                        <option value="">--CHOOSE--</option>
                                                        <option value="blur">onBlur</option>
                                                        <option value="change">onChange</option>
                                                        <option value="click">onClick</option>
                                                        <option value="load">onLoad</option>
                                                        <option value="ready">onReady</option>
                                                    </select>
                                                </div>
                                            </div>

                                            <div class="form-group row">
                                                <label class="col-sm-3 col-form-label"></label>
                                                <div class="col">
                                                    <div class="w-100 ace-editor-js" style="min-height:100px"></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="text-right">
                                <button type="button" class="btn btn-danger js-editor-remove" onclick="removeJSEditor($(this).closest('form'))" style="display:none;">Remove an Item</button>
                                <button type="button" class="btn btn-success js-editor-add" onclick="appendAceEditor($(this).closest('form'))">Add an Item</button>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                            <button type="submit" class="btn btn-primary" >Save</button>
                        </div>
                    </form>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <div class="modal fade" id="modalSelectFieldType" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-slideout" role="document">
                <div class="modal-content">
                    <form id="formSelectFieldType" action="" novalidate >
                        <input type="hidden" name="section_id" value="">
                        <div class="modal-header">
                            <h5 class="modal-title font-weight-bold">Select field type</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <ul class="px-3" style="list-style: none;">
                                <%
                                    String fieldTypes[] = {
                                        "text", "multiline_text", "text_formatted",
                                        "select", "image", "file","bloc",
                                        "boolean", "URL",
                                        "tag", "date", "number"
                                        , "view_commercial_catalogs"
                                        , "view_commercial_products"
                                        , "view_structured_pages"
                                        , "view_structured_contents"
                                    };

                                    if(!canAddBlocField(Etn,template_id)){
                                        List<String> fieldTypesList = new ArrayList<>(Arrays.asList(fieldTypes));
                                        fieldTypesList.remove("bloc");
                                        fieldTypes = fieldTypesList.toArray(new String[0]);
                                    }

                                    for (String fieldType : fieldTypes) {
                                        String fieldTitle = fieldType.replace("view_", "view : ").replaceAll("_", " ");
                                %>
                                <li class="btn border-0 w-100 mb-1" style="background-color: #CCC;"
                                    data-toggle="modal" data-target="#modalAddEditField"
                                    data-caller="add" data-type="<%=escapeCoteValue(fieldType)%>"
                                    onclick="$('#modalSelectFieldType').modal('hide');">
                                    <div class="row" >
                                        <div class="col text-left text-capitalize font-weight-bold">
                                            <%=escapeCoteValue(fieldTitle)%></div>
                                        <div class="col text-right"><i data-feather="plus-circle"></i></div>
                                    </div>
                                </li>
                                <%
                                    }//for fieldtypes
%>
                            </ul>
                        </div>
                    </form>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <div class="modal fade" id="modalAddExistingField" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-lg modal-dialog-slideout" role="document">
                <div class="modal-content">
                    <form id="formAddExistingField" action="" novalidate >
                        <input type="hidden" name="section_id" value="">
                        <div class="modal-header">
                            <h5 class="modal-title font-weight-bold">Select existing field </h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div class="row mb-2">
                                <div class="col">
                                    Search :
                                    <input type="text" class="form-control form-control-sm searchExistingField"
                                           name="" value="" style="max-width: 300px;display: inline-block;">
                                </div>
                                <div class="col text-right">
                                    <button type="button" class="btn btn-sm btn-success addFieldBtn"
                                            data-toggle="modal" data-target="#modalSelectFieldType"
                                            onclick="$('#modalAddExistingField').modal('hide');"
                                            data-section-id="">
                                        add a field</button>
                                </div>
                            </div>
                            <ul id="existingFieldsList" class="px-0" style="list-style: none;">
                                <!-- dynamic content -->
                            </ul>
                            <div id="loader" style="display:none;">Loading...</div>
                        </div>
                        <div class="d-none">
                            <li id="existingFieldListItemTemplate"
                                class="existingFieldListItem btn w-100 p-0 mb-1"
                                onclick="addExistingField(this)"  >
                                <div class="card mb-1 text-left">
                                    <div class="card-header py-2 px-3">
                                        <div class="row d-flex align-items-center">
                                            <div class="col-4 font-weight-bold" ><span class="name">Bloc Name</span></div>
                                            <div class="col-3" ><span class="custom_id">bloc_name</span></div>
                                            <div class="col" ><span class="field_type">text field</span></div>
                                            <div class="col" ><span class="nb_items_text  ">limited : 1</span></div>
                                            <div class="col text-right">
                                                <i data-feather="plus-circle"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </li>
                        </div>
                        
                        <!-- <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                            <button type="submit" class="btn btn-primary" >Save</button>
                        </div> -->
                    </form>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <div class="modal fade" id="modalAddEditField" tabindex="-1" role="dialog" data-backdrop="static" >
            <div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
                <div class="modal-content">
                    <form id="formAddEditField" autocomplete="off" action="" novalidate >
                        <input type="hidden" name="section_id" value="">
                        <input type="hidden" name="field_id" value="">
                        <input type="hidden" name="field_type" value="">
                        <div class="modal-header bg-lg1">
                            <h5 class="modal-title font-weight-bold"></h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapseSection1" role="button" aria-expanded="true" aria-controls="collapseSection1">
                                    <strong>Field Information</strong>
                                </div>
                                <div id="collapseSection1" class="collapse show" style="border: medium none;">
                                    <div class="card-body">
                            <div class="form-group row">
                                            <label class="col-sm-3 col-form-label">Label</label>
                                <div class="col">
                                    <input type="text" class="form-control" name="name" value=""
                                           maxlength="100" required="required" onchange="onNameChange(this)">
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">ID</label>
                                <div class="col">
                                    <input type="text" class="form-control" name="custom_id" value=""
                                           maxlength="100" required="required"
                                           onkeyup="onKeyupCustomId(this)" onblur="onKeyupCustomId(this)">
                                    <div class="invalid-feedback ">
                                        Cannot be empty or duplicate within section.
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row booleanType">
                                <label class="col-sm-3 col-form-label">Type</label>
                                <div class="col">
                                    <select class="custom-select" name="field_specific_boolean_type">
                                        <option value="check">Checkbox</option>
                                        <option value="switch">Switch</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group row selectedTemplates">
                                <label class="col-sm-3 col-form-label">Selected Template</label>
                                <div class="col">
                                    <select class="custom-select mt-2" name="field_specific_selected_templates" onchange="checkSelectForDuplicate(this,'field_specific_selected_templates')">
                                        <option value="">-- SELECT TEMPLATE --</option>
                                        <option value="all">-- All --</option>
                                        <%
                                            Set rsTemplates = Etn.execute("select * from bloc_templates where id <> "+escape.cote(template_id)+" and type='block' and site_id="+escape.cote(siteId)+" order by name");
                                            while(rsTemplates.next()){
                                                if(!isBlocFieldExist(Etn,rsTemplates.value("id"),"")){
                                        %>
                                                    <option value="<%=escapeCoteValue(rsTemplates.value("id"))%>"><%=escapeCoteValue(rsTemplates.value("name"))%></option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>

                            <%-- <div class="form-group row imageFormat">
                                <label for="media-type" class="col-sm-3 col-form-label">Type</label>
                                <div class="col-sm-9">
                                    <select name="media-type" class="form-control" >
                                        <option value="all">All type of media</option>
                                        <option value="image">Image only</option>
                                        <option value="video">Video only</option>
                                    </select>
                                </div>
                            </div> --%>
                            
                            <div class="form-group row imageFormat">
                                <label for="image-format" class="col-sm-3 col-form-label">Format</label>
                                <div class="col-sm-9">
                                    <div class="btn-group" role="group">
                                        <button type="button" class="btn btn-secondary image-format">16:9</button>
                                        <button type="button" class="btn btn-secondary image-format">4:3</button>
                                        <button type="button" class="btn btn-secondary image-format">1:1</button>
                                        <button type="button" class="btn btn-secondary image-format">2:3</button>
                                        <button type="button" class="btn btn-secondary image-format">Free</button>
                                    </div>
                                    <input type="hidden" name="img-asp" />
                                </div>
                            </div>                            

                            <div class="form-group row" id="tagsListMainDiv">
                                <label class="col-sm-3 col-form-label">List of tags</label>
                                <div class="col" id="tagsList">
                                    <select id="tags_folder_list_0" class="custom-select tags_folder_list" name="tags_folder_list">
                                        <option value="">-- Select --</option>
                                        <option value="all" selected>All</option>
                                        <%
                                            Set rsTagsFolders = Etn.execute("select id,name from "+GlobalParm.getParm("CATALOG_DB")+".tags_folders where site_id="+
                                            escape.cote(siteId)+" and parent_folder_id=0");
                                            while(rsTagsFolders.next()){
                                                String folderName = parseNull(rsTagsFolders.value("name"));
                                                String folderId = parseNull(rsTagsFolders.value("id"));
                                        %>
                                            <option value="<%=folderId%>"><%=folderName%></option>
                                        <%}%>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group row isRequiredDiv">
                                <label class="col-sm-3 col-form-label">Required</label>
                                <div class="col py-2">
                                    <input class=" " type="checkbox" name="is_required" value="1" >
                                </div>
                            </div>

                            <div class="form-group row isindexedDiv">
                                <label class="col-sm-3 col-form-label">Indexed</label>
                                <div class="col py-2">
                                    <input class=" " type="checkbox" name="is_indexed" value="1" >
                                </div>
                            </div>

                            <div class="form-group row isBulkModificationDiv <%="store".equals(templateType)?"":"d-none"%>">
                                <label class="col-sm-3 col-form-label">Bulk Modification</label>
                                <div class="col py-2">
                                    <input class=" " type="checkbox" name="is_bulk_modify" value="1" >
                                </div>
                            </div>
                            <div class="form-group row isMetaVariableDiv">
                                <label class="col-sm-3 col-form-label">Meta Variable</label>
                                <div class="col py-2">
                                    <input class=" " type="checkbox" name="is_meta_variable" value="1" >
                                </div>
                            </div>
                            <div class="form-group row nbOfItemsDiv">
                                <label class="col-sm-3 col-form-label">Nb of items</label>
                                <div class="col">
                                    <select class="custom-select" name="nb_items_select"
                                            onchange="onChangeNbItems(this)">
                                        <option value="1">limited</option>
                                        <option value="0">unlimited</option>
                                    </select>
                                </div>
                                <div class="col">
                                    <input type="text" class="form-control" name="nb_items" value="1"
                                           maxlength="2" required="required"
                                           onkeyup="onKeyPressNBItems(this)" onblur="onKeyPressNBItems(this)">
                                    <div class="invalid-feedback">
                                        Cannot be empty.
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row urlType">
                                <label class="col-sm-3 col-form-label">Type</label>
                                <div class="col">
                                    <select class="custom-select" name="field_specific_url_type">
                                        <option value="url">URL only</option>
                                        <option value="url & label">URL + Label</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group row selectType">
                                <label for="select-type" class="col-sm-3 col-form-label">Type</label>
                                <div class="col-sm-9">
                                    <select class="custom-select" id="select-type" name="select-type">
                                        <option value="select">Select</option>
                                        <option value="search">Search Select</option>
                                    </select>
                                </div>
                            </div>                            
                            
                            <div class="form-group row fieldInfoDescription">
                                <label for="field-info-description" class="col-sm-3 col-form-label">Description</label>
                                <div class="col-sm-9">
                                    <textarea class="form-control" name="field-info-description" rows="3" spellcheck="false"></textarea>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label class="col-sm-3 col-form-label">Value</label>
                                <div class="col">
                                    <div class="row align-items-center selectType">
                                        <label>For writing query / pair value?</label>
                                        <input type="checkbox" id="option_query" onclick="queryselect(this)" style="margin-bottom: .5rem;margin-left: 10px;">
                                    </div>
                                    <div id="fieldValueDiv">
                                        <input type="text" class="form-control" name="value" value="">
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row fieldSpecific fieldSpecific_date">
                                <label class="col-sm-3 col-form-label">Date type</label>
                                <div class="col">
                                    <select class="custom-select" name="date_type"
                                            onchange="onChangeDateTypeFormat()">
                                        <option value="date">date</option>
                                        <option value="period">period</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row fieldSpecific fieldSpecific_date">
                                <label class="col-sm-3 col-form-label">Date format</label>
                                <div class="col">
                                    <select class="custom-select" name="date_format"
                                            onchange="onChangeDateTypeFormat()">
                                        <option value="date">date</option>
                                        <option value="date_time">date + time</option>
                                        <option value="time">time</option>
                                    </select>
                                </div>
                            </div>
							
							<div id='languageTabs'>
							<div>
								<ul class="nav nav-tabs pagePathTabs" role="tablist">
									<%
                                        active = true;
										for (Language lang:langsList) {
									%>
									<li class="nav-item" data-lang-id="<%=lang.getLanguageId()%>">
										<a class='nav-link <%=(active)?"active":""%>' data-lang-id="<%=lang.getLanguageId()%>"
										   data-toggle="tab" href="#langtabcontent_<%=lang.getLanguageId()%>"
										   role="tab" aria-controls="<%=lang.getLanguage()%>"
                                                    aria-selected="true"><%=libelle_msg(Etn, request, lang.getLanguage())%>
										</a>
									</li>
									<%
                                            active = false;
										}
									%>
								</ul>							
							</div>
							<div class="tab-content p-3">
							<%
                                active = true;
								for (Language lang:langsList) {
							%>
								<div class='tab-pane langTabContent <%=(active)?"show active":""%>'
									 id="langtabcontent_<%=lang.getLanguageId()%>"
									 role="tabpanel" aria-labelledby="<%=lang.getLanguage()%>-tab">
									<input type='hidden' name='langueIds' value='<%=lang.getLanguageId()%>' data-langue_code="<%=lang.getCode()%>">
									<div class="form-group row">
										<label class="col-sm-3 col-form-label">Default value</label>
										<div class="col fieldDefValueDiv" id="fieldDefValueDiv_<%=lang.getLanguageId()%>">
											<input type="text" class="form-control" name="default_value" value="">
										</div>
									</div>
									<div class="form-group row placeholderDiv" id="placeholderDiv_<%=lang.getLanguageId()%>">
										<label class="col-sm-3 col-form-label">Placeholder</label>
										<div class="col">
											<input type="text" class="form-control" name="placeholder" value="">
										</div>
									</div>
								</div>
							<%
                                active = false;
                                }
                            %>
							</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card mb-2">
                                <div class="card-header bg-secondary" data-toggle="collapse" href="#collapseAdvancedParameter" role="button" aria-expanded="true" aria-controls="collapseAdvancedParameter">
                                    <strong>Advanced Parameters</strong>
                                </div>
                                <div id="collapseAdvancedParameter" class="collapse" style="border: medium none;">
                                    <div class="card-body">
                                        <div class="form-group row">
                                            <label class="col-sm-3 col-form-label">Display by default</label>
                                            <div class="col">
                                                <select class="custom-select" name="display-by-default">
                                                    <option value="1">Yes</option>
                                                    <option value="0">No</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div id="advanced-param-field-options" style="display:none;">
                                            <div class="form-group row">
                                                <label class="col-sm-3 col-form-label ">Type</label>
                                                <div class="col">
                                                    <select class="custom-select" name="field-id-type">
                                                        <option value="none">Basic text field</option>
                                                        <option value="custom">Free content Unique Value</option>
                                                        <option value="auto">ID Autogenerated</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-group row modifiable">
                                                <label class="col-sm-3 col-form-label">Modifiable</label>
                                                <div class="col">
                                                    <select class="custom-select" name="field-modifiable">
                                                        <option value="always">Always</option>
                                                        <option value="create">At creation</option>
                                                        <option value="never">Never</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="form-group row">
                                            <label class="col-sm-3 col-form-label">Regular Expression</label>
                                            <div class="col">
                                                <input type="text" class="form-control" name="regex">
                                            </div>
                                        </div>

                                        <div class="form-group row">
                                            <label class="col-sm-3 col-form-label">Custom Css</label>
                                            <div class="col">
                                               <div class="w-100 ace-editor-css" style="min-height:100px"></div>
                                            </div>
                                        </div>
                                        <div class="js-editor">
                                            <div class="form-group row">
                                                <label class="col-sm-3 col-form-label">JS on trigger</label>
                                                <div class="col">
                                                    <select class="custom-select" name="js-ontrigger">
                                                        <option value="">--CHOOSE--</option>
                                                        <option value="blur">onBlur</option>
                                                        <option value="change">onChange</option>
                                                        <option value="click">onClick</option>
                                                        <option value="load">onLoad</option>
                                                        <option value="ready">onReady</option>
                                                    </select>
                                                </div>
                                            </div>

                                            <div class="form-group row">
                                                <label class="col-sm-3 col-form-label"></label>
                                                <div class="col">
                                                    <div class="w-100 ace-editor-js" style="min-height:100px"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="text-right">
                                            <button type="button" class="btn btn-danger js-editor-remove" onclick="removeJSEditor($(this).closest('form'))" style="display:none;">Remove an Item</button>
                                            <button type="button" class="btn btn-success js-editor-add" onclick="appendAceEditor($(this).closest('form'))">Add an Item</button>
                                        </div>
                                    </div>
                                </div>
							</div>
                        </div>
                        <div class="modal-footer">
                            <div class="container-fluid">
                                <div class="row">
                                    <div class="col text-left">
                                        <button id="listOfFieldsBtn" type="button" class="btn btn-primary"
                                                data-toggle="modal" data-target="#modalSelectFieldType"
                                                onclick="$('#modalAddEditField').modal('hide');" >
                                            List of fields</button>
                                    </div>
                                    <div class="col text-right">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                        <button type="submit" class="btn btn-primary" >Save</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div><!-- /.modal -->

        <template id="custom-js-editor">
            <div class="js-editor">
                <div class="form-group row">
                    <label class="col-sm-3 col-form-label">JS on trigger</label>
                    <div class="col">
                        <select class="custom-select" name="js-ontrigger">
                            <option value="">--CHOOSE--</option>
                            <option value="blur">onBlur</option>
                            <option value="change">onChange</option>
                            <option value="click">onClick</option>
                            <option value="load">onLoad</option>
                            <option value="ready">onReady</option>
                        </select>
                    </div>
                </div>

                <div class="form-group row">
                    <label class="col-sm-3 col-form-label"></label>
                    <div class="col">
                        <div class="w-100 ace-editor-js" style="min-height:100px"></div>
                    </div>
                </div>
            </div>
        </template>

        <template id="query-select">
            <div class="query-select">
                <div class="selectValueListItem mb-2" style="display: flex;">
                    <select class="custom-select" onchange="queryselectfield(this)">
                        <option selected="" value="free">Free Query</option>
                        <option value="catalogs">Product Catalogs</option>
                        <option value="page">Structured Content</option>
                        <option value="content">Structured Data</option>
                        <option value="blocs">Blocks</option>
                        <option value="freemarker_pages">Pages</option>
                    </select>
                </div>

                <div class="freeQuery form-row">
                    <textarea class="form-control" id="free-query" rows="3" spellcheck="false"></textarea>
                </div>

                <div id="value-label-select" style="display:none">
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <select class="custom-select" name="select-field-for-value">
                                <option selected="">--CHOOSE--</option>
                            </select>
                        </div>
                        <div class="form-group col-md-6">
                            <select class="custom-select" name="select-field-for-label">
                                <option selected="">--CHOOSE--</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
        </template>