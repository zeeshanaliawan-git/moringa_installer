<main class="c-main"  style="padding:0px 30px">
    <!-- beginning of container -->
    <form id="mainForm" action="" onsubmit="return false;">
        <input type="hidden" name="template_id" id="template_id" value="<%=com.etn.asimina.util.SiteHelper.escapeCoteValue(template_id+"")%>" >
    </form>

    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-start pt-3 pb-2 mb-3 border-bottom">
        <h1 class="h2">Edit '<span class="templateName"><%=com.etn.asimina.util.SiteHelper.escapeCoteValue(rs.value("name"))%></span>' template (<%=com.etn.asimina.util.SiteHelper.escapeCoteValue(rs.value("type").replace("_", " "))%>)</h1>
        <div class="btn-toolbar mb-2 mb-md-0 flex-wrap flex-md-nowrap">
            <div class="btn-group mx-2">
                <button class="btn btn-primary" type="button" onclick="onClickGoBack('<%=com.etn.asimina.util.SiteHelper.escapeCoteValue(goBackUrl)%>')">Back</button>
                <button class="btn btn-primary" type="button" <%if(isLocked){%> disabled <%}%> onclick="onSave()">save</button>
            </div>

            <button class="btn btn-primary mr-2" data-toggle="modal" data-target="#modalAddEditTemplate" data-caller="edit" data-template-id='<%=com.etn.asimina.util.SiteHelper.escapeCoteValue(rs.value("id"))%>' data-theme-status='<%=com.etn.asimina.util.SiteHelper.escapeCoteValue(themeStatus)%>'>
                <i data-feather="settings"></i>
            </button>

            <button class="btn btn-success" type="button" <%=templateType.equals(Constant.TEMPLATE_STRUCTURED_CONTENT) ? "disabled" : ""%> onclick='openTemplateResources(<%=com.etn.asimina.util.SiteHelper.escapeCoteValue(rs.value("id"))%>)'>
                <i data-feather="code"></i>
            </button>
        </div>
    </div>
    <!-- row -->
    <!-- sections main list -->
    <ul id="sectionsList" class="sortable bg-light">
        <!-- dynamic content -->
        <!-- add section -->
        <li class="new" id="addSectionListItem">
            <div class="card border-0 m-0" >
                <div class="card-body text-center" style="">
                    <button class="btn btn-sm btn-success" data-toggle="modal" data-target="#modalAddEditSection" data-caller="add" >add a section</button>
                </div>
            </div>
        </li>
    </ul><!-- sections main list -->
    <div class="d-none">
        <!-- templates -->
        <li id="sectionListItemTemplate" class="sectionListItem border-0">
            <div class="card mb-2">
                <div class="card-header section_header">
                    <div class="row">
                        <div class="d-none">
                            <span class="section_id"></span>
                            <span class="nb_items"></span>
                        </div>
                        <div class="col m-0 m-auto font-weight-bold" ><span class="name"></span></div>
                        <div class="col m-0 m-auto" ><span class="custom_id"></span></div>
                        <div class="col m-0 m-auto" ><span class="type">section</span></div>
                        <div class="col m-0 m-auto" ><span class="nb_items_text"></span></div>
                        <div class="col-2 text-right" >
                            <button class="btn btn-sm btn-primary mr-1" data-toggle="modal" data-target="#modalAddEditSection" data-caller="edit"><i data-feather="settings"></i></button>
                            <button class="btn btn-sm btn-danger mr-1 systemHide" onclick="deleteSection(this)"><i data-feather="x"></i></button>
                        </div>
                    </div>
                </div> <!-- card header -->
                <div class="card-body">
                    <div class="card-body section_body" >
                        <ul class="fieldsList sortable connected-sortable droppable-area droppable-limited-area">
                            <!-- fields list items -->
                            <li class="addFieldListItem new">
                                <div class="card border-0 m-0">
                                    <div class="card-body bg-white text-center py-2" style="">
                                        <button class="btn btn-sm btn-success mr-1 mb-0"  data-toggle="modal" data-target="#modalSelectFieldType">add a field</button>
                                        <button class="btn btn-sm btn-success mr-1 mb-0"  data-toggle="modal" data-target="#modalAddExistingField">add existing field</button>
                                        <button class="btn btn-sm btn-success addNestedSectionBtn" data-toggle="modal" data-target="#modalAddEditSection" data-caller="addNested" > 
                                            add a nested section
                                        </button>
                                    </div>
                                </div>
                            </li>

                        </ul>
                    </div> <!-- card body -->
                </div>
            </div> <!-- card -->
        </li>
        <li id="fieldListItemTemplate" class="fieldListItem">
            <div class="card m-0 bg-light shadow-sm">
                <div class="card-header py-2 px-3">
                    <div class="row d-flex align-items-center">
                        <div class="col font-weight-bold" ><span class="name">Bloc Name</span></div>
                        <div class="col" ><span class="custom_id">bloc_name</span></div>
                        <div class="col" ><span class="field_type">text field</span></div>
                        <div class="col" ><span class="nb_items_text  ">limited : 1</span></div>
                        <div class="col" ><span class="required_text"></span></div>
                        <div class="col" ><span class="indexed_text"></span></div>
                        <div class="col" ><span class="bulk_modify_text"></span></div>
                        <div class="col" ><span class="meta_variable_text"></span></div>

                        <div class="col-2 text-right">
                            <button class="btn btn-sm btn-primary mr-1" data-toggle="modal" data-target="#modalAddEditField" data-caller="edit"><i data-feather="settings"></i></button>
                            <button class="btn btn-sm btn-danger mr-1 systemHide" onclick="deleteField(this)"><i data-feather="x"></i></button>
                        </div>
                    </div>
                </div>
            </div>
        </li>

        <ul id="selectFieldValueTemplate" class="selectValueList p-0 m-0" style="list-style: none">
            <li class="selectValueListItem mb-2" >
                <div class="row d-flex align-items-center">
                    <div class="col p-0 m-0 pr-1" id="selectValueIcon">
                        <div><i data-feather="chevron-up"></i></div>
                        <div style="margin-top: -10px;"><i data-feather="chevron-down"></i></div>
                    </div>
                    <div class="col p-0 m-0 pr-1">
                        <input type="radio" name="default_value" value="">
                    </div>
                    <div class="col-5 p-0 m-0 pr-1">
                        <input type="text" class="form-control" name="option_value" value="" placeholder="value" >
                    </div>
                    <div class="col-5 p-0 m-0 pr-1">
                        <input type="text" class="form-control" name="option_label" value="" placeholder="label">
                    </div>
                    <div class="col p-0 m-0">
                        <button class="deleteBtn btn btn-sm btn-danger p-0 m-0" onclick="deleteElementGeneric(this, 'li.selectValueListItem:first', false)"><i data-feather="x"></i></button>
                    </div>
                </div>
            </li>
            <li class="add">
                <!-- <div class="row"> -->
                <!-- <div class="col text-center"> -->
                <button class="addBtn btn btn-sm btn-primary py-0 w-25" type="button" onclick="addSelectValue(this)"><i data-feather="plus-circle"></i></button>
                <!-- </div> -->
                <!-- </div> -->
            </li>
        </ul>

        <div id="booleanFieldValueTemplate" class="container-fluid">
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <div class="input-group-text">
                        <input type="radio" name="default_value" value="1" class="default_value_1" checked>
                    </div>
                    <span class="input-group-text"><strong>On</strong></span>
                </div>
                <input type="text" class="form-control" name="value_on" value="1" maxlength="100" required="required">
                <div class="invalid-feedback">Cannot be empty or duplicate.</div>
            </div>
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <div class="input-group-text">
                        <input type="radio" name="default_value" value="0" class="default_value_0" >
                    </div>
                    <span class="input-group-text"><strong>Off</strong></span>
                </div>
                <input type="text" class="form-control" name="value_off" value="0" maxlength="100" required="required">
                <div class="invalid-feedback">Cannot be empty or duplicate.</div>
            </div>
        </div>
        
        <div id="blocFieldValueTemplate">
            <div class="input-group mb-2">	
                <select class="custom-select bloc-templates default_value_templates" name="default_value">
                    <option value="">-- SELECT TEMPLATE --</option>
                    <option value="all">-- All --</option>
                </select>
                <div class="asm-autocomplete">
                    <input type="text" class="form-control default_value_bloc asm-autocomplete-field" name="bloc_name">
                    <input type="hidden" class="form-control bloc-id" name="bloc_id">
                </div>
                <div class="input-group-append">
                    <button class="btn btn-primary edit-bloc" type="button" style="display:none"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
                    <button class="btn btn-success add-bloc" type="button" style="display:none"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-plus"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg></button>
                    <button class="btn btn-danger remove-bloc" type="button" style="display:none"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                </div>                
                <div class="invalid-feedback">Please select a template; it cannot be empty.</div>
            </div>
        </div>

        <div id="viewStructuredFieldValueTemplate" class="container-fluid">
            <select name="catalogType" class="custom-select catalogType">
                <option value="">-- select catalog type --</option>
            </select>
        </div>

        <div id="imageFieldDefValueTemplate" class="container-fluid">
            <div class="card image_card">
                <div class="card-body"> 	
                    <span class="ui-state-media-default" style="padding:0px;display: inline-block;">
                        <div class="bloc-edit-media">
                            <button type="button" class="btn btn-success load-img" style="margin-right: .10rem;" onclick="loadFieldImageV2(this,false)">Add a media</button>
                            <button type="button" class="btn btn-danger no-img disabled" style="margin-right: .10rem;display:none;">No more media</button>
                        </div>
                        <div class="bloc-edit-media-bgnd" style="height:100%; width:100%;min-width:145px;min-height:145px;  position:absolute; left:0; top:0">&nbsp;</div>
                        <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="../img/add-picture-on.jpg">	
                    </span>														
                </div>
            </div>
        </div>

        <div id="fileFieldDefValueTemplate" class="container-fluid">
            <div class="card file_card">
                <div class="card-body text-center file_body">
                    <input type="hidden" class="file_value" name="default_value" value="" >
                    <input type="text" class="form-control file_value" readonly="" placeholder="Select a file" name="ignore">
                </div>
                <div class="card-footer file_footer">
                    <div class="form-group row mb-0">
                        <div class="col-6">
                            <button type="button" class="btn btn-link" onclick="loadFieldFile(this)">Select file</button>
                        </div>
                        <div class="col-6">
                            <button type="button" class="btn btn-link text-danger" onclick="clearFieldFile(this)">Delete file</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="tagFieldDefValueTemplate" class="container-fluid">
            <input type="text" name="defaultTagInput" class="form-control tagInputField"  value="" placeholder="search and add (by clicking return)">
        </div>
        <div class="tagsDiv col-sm-12 form-group mt-3" id="tagsDiv"></div>

        <div id="dateFieldDefValueTemplate" class="container-fluid">
            <div class="form-group row">
                <label class="col-2 col-form-label dateEndDateDiv">Start</label>
                <div class="col">
                    <input type="text" class="form-control date_value" name="date_value_start" value="">
                </div>
            </div>
            <div class="form-group row dateEndDateDiv">
                <label class="col-2 col-form-label">End</label>
                <div class="col">
                    <input type="text" class="form-control date_value" name="date_value_end" value="">
                </div>
            </div>
        </div>
    </div> <!-- hidden div -->
    <!-- row-->
    <!-- /end of container -->
</main>