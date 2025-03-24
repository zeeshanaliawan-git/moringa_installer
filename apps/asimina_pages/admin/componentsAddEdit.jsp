
<!-- Modal -->
<div class="modal fade" id="modalAddEditComponent" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-dialog-slideout" role="document">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel"></h5>
                <div class="text-right">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            </div>

            <div class="modal-body">
                <div class="text-right mb-3">
                    <button type="button" class="btn btn-primary onPageEditor savePlaceBtn"
                            onclick="saveComponent(true)" style="display: none;">
                            Save & add</button>
                    <button type="button" class="btn btn-primary" onclick="saveComponent()" >Save</button>
                </div>
                <form id="formAddEditComponent" action="" onsubmit="return false;" novalidate>
                    <input type="hidden" name="id" id="curEditCompId" value="">
                    
                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#globalInfoCollapse" role="button" aria-expanded="true" aria-controls="globalInfoCollapse">
                            <strong>Global information</strong>
                        </div>
                        <div class="collapse show py-3" id="globalInfoCollapse">
                            <div class="card-body">
                                <div id="fileErrorMsg" class="invalid-feedback" style="display: block;"></div>
                                <div class="form-group row">
                                    <label class="col col-form-label">Name</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control"
                                            name="name" maxlength="100"
                                            readonly="readonly"
                                            required="required" />
                                        <div class="invalid-feedback">Cannot be empty. No space or special characters allowed.</div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col"></div>
                                    <div class="col-sm-9 input-group mb-3">
                                        <div class="custom-file">
                                            <input type="file" id="compFile" name="file" accept=".jsx,.js"
                                            class="custom-file-input" aria-describedby="file"
                                            onchange="onFileInputChange(this)">
                                            <label id="compFileLabel" class="custom-file-label rounded-right" for="file">Upload new file</label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#compPropertiesCollapse" role="button" aria-expanded="true" aria-controls="compPropertiesCollapse">
                            <strong>Properties</strong>
                        </div>
                        <div class="collapse show py-3" id="compPropertiesCollapse">
                            <div class="card-body">
                                <div id="compPropertiesDiv" class="clearContent" ></div>
                                <div class="text-right">
                                    <button type="button" class="btn btn-success" onclick="addCompProperty()" >Add a property</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#compUrlsCollapse" role="button" aria-expanded="true" aria-controls="compUrlsCollapse">
                            <strong>URLs</strong>
                        </div>
                        <div class="collapse show py-3" id="compUrlsCollapse">
                            <div class="card-body">
                                <div id="compUrlsDiv" class="clearContent" >

                                </div>
                                <div class="text-right">
                                    <button type="button" class="btn btn-success" onclick="addCompUrl()" >Add a URL</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#compDependenciesCollapse" role="button" aria-expanded="true" aria-controls="compDependenciesCollapse">
                            <strong>Dependencies</strong>
                        </div>
                        <div class="collapse show py-3" id="compDependenciesCollapse">
                            <div class="card-body">
                                <div id="compDependenciesDiv" class="clearContent"></div>
                                <div class="text-right">
                                    <button type="button" class="btn btn-success" onclick="addCompDependency()" >Add a dependency</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#compPackagesCollapse" role="button" aria-expanded="true" aria-controls="compPackagesCollapse">
                            <strong>Packages</strong>
                        </div>
                        <div class="collapse show py-3" id="compPackagesCollapse">
                            <div class="card-body">
                                <div id="compPackagesDiv" class="clearContent"></div>
                                <div class="text-right">
                                    <button type="button" class="btn btn-success" onclick="addCompPackage()" >Add a package</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card mb-2">
                        <div class="card-header bg-secondary" data-toggle="collapse" href="#compLibrariesCollapse" role="button" aria-expanded="true" aria-controls="compLibrariesCollapse">
                            <strong>Libraries</strong>
                        </div>
                        <div class="collapse show py-3" id="compLibrariesCollapse">
                            <div class="card-body">
                                <div id="compLibrariesDiv" class="clearContent"></div>
                                <div class="text-right">
                                    <button type="button" class="btn btn-success" onclick="addCompLibrary()" >Add a Library</button>
                                </div>
                            </div>
                        </div>
                    </div>

                </form>
                <div class="d-none">
                    <div id="compPropertyTemplate">
                        <div class="form-group row compPropertyDiv">
                            <input type="hidden" name="property_id" value="" />
                            <div class="col input-group mb-3">
                                <input type="text" class="form-control"
                                    name="property_name" maxlength="100" placeholder="Name"
                                    required="required" />
                                <select name="property_type"
                                    class="custom-select property_type"
                                    style="max-width: max-content;"
                                    required="required">
                                    <option value="">-- Type --</option>
                                    <option value="string">Text</option>
                                    <option value="number">Number</option>
                                    <option value="boolean">Boolean</option>
                                    <option value="image">Image</option>
                                    <option value="json">JSON</option>
                                </select>
                                <select name="property_is_required"
                                    class="custom-select property_is_required"
                                    style="max-width: max-content;">
                                    <option value="1">Required</option>
                                    <option value="0">Optional</option>
                                </select>
                                <div class="input-group-append">
                                    <input type="button" class="btn btn-danger button-rounded deleteBtn" value="x"
                                        onclick="deleteParent(this,'.compPropertyDiv')">
                                </div>
                                <div class="invalid-feedback">Specify name and type</div>
                            </div>
                        </div>
                    </div>
                    <div id="compUrlTemplate">
                        <div class="form-group row compUrlDiv">
                            <div class="col input-group mb-3">
                                <input type="text" class="form-control"
                                    name="comp_url"
                                    placeholder="URL" required="required" />
                                <div class="input-group-append">
                                    <input type="button" class="btn btn-danger rounded-right" value="x"
                                        onclick="deleteParent(this,'.compUrlDiv')">
                                </div>
                                <div class="invalid-feedback">Cannot be empty</div>
                            </div>
                        </div>
                    </div>
                    <div id="compDependencyTemplate">
                        <div class="form-group row compDependencyDiv">
                            <div class="col input-group mb-3">
                                <select name="dependency_comp_id" class="custom-select"
                                    required="required">
                                    <!-- options filled dynamically -->
                                </select>
                                <div class="input-group-append">
                                    <input type="button" class="btn btn-danger rounded-right" value="x"
                                        onclick="deleteParent(this,'.compDependencyDiv')">
                                </div>
                                <div class="invalid-feedback">Select a component</div>
                            </div>
                        </div>
                    </div>
                    <div id="compPackageTemplate">
                        <div class="form-group row compPackageDiv">
                            <div class="col input-group mb-3">
                                <input type="text" class="form-control"
                                    name="package_name" maxlength="100"
                                    placeholder="Package name" required="required" />
                                <div class="input-group-append">
                                    <input type="button" class="btn btn-danger rounded-right" value="x"
                                        onclick="deleteParent(this,'.compPackageDiv')">
                                </div>
                                <div class="invalid-feedback">Cannot be empty</div>
                            </div>
                        </div>
                    </div>
                    <div id="compLibraryTemplate">
                        <div class="compLibraryDiv col py-2 mb-1 ">
                            <div class="form-group row">
                                <div class="col input-group" >
                                    <select class="custom-select" name="library_id"
                                        required="required">
                                        <option value="">-- Select files library --</option>
                                    <%
                                        Set compLibRs = Etn.execute("SELECT id, name FROM libraries WHERE site_id = " + escape.cote(getSiteId(session))+ " ORDER BY name");
                                        while(compLibRs.next()){
                                        out.write("<option value='"+compLibRs.value("id")+"'>"+compLibRs.value("name")+"</option>");
                                        }
                                    %>
                                    </select>
                                    <div class="input-group-append">
                                        <input type="button" class="btn btn-danger rounded-right" onclick="deleteParent(this,'.compLibraryDiv')" value="Remove">
                                    </div>
                                    <div class="invalid-feedback">Please select a library.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div> <!--/modal-body -->
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="saveComponent()" >Save</button>
                <button type="button" class="btn btn-primary onPageEditor savePlaceBtn"
                        onclick="saveComponent(true)" style="display: none;">
                        Save & add</button>
            </div>

        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->
<div class="modal fade" id="modalExistingComponents" tabindex="-1" role="dialog" data-backdrop="static" >
    <div class="modal-dialog modal-dialog-slideout" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">List of existing components</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="container-fluid">
                    <div class="row mb-3">
                        <div class="col-12">
                            <button class="btn btn-success"
                                    onclick="$('#modalExistingComponents').modal('hide');openAddEditComponentModal()">Add new component</button>
                            <!-- <button class="btn btn-primary mr-2"
                                data-toggle="modal" data-target="#modalAddNewBloc"
                                onclick="$('#modalExistingComponents').modal('hide')">
                                Add new bloc</button> -->
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-12" >
                            <form action="" id="formExistingComponents" onsubmit="return false;">

                            <fieldset class="form-group mb-1">
                                <input type="text" class="form-control"
                                        name="search" placeholder="Search"
                                        onkeyup="searchExistingComponents(this);">
                            </fieldset>
                            <ul id="existingComponentsList" class="mt-3 px-0" style="list-style: none;">


                            </ul>
                            <div id="existingComponentsListTemplate" class="d-none">
                                <li class="btn border-0 w-100 mb-1 componentListItem" style="background-color: #CCC;"
                                    onclick="addExistingComponentToGrid('#ID#')" >
                                    <div class="row" >
                                        <div class="col text-left col-10">
                                            <h6 class="m-0 font-weight-bold componentName">#NAME#</h6>
                                            <div class="small" style="white-space: normal;">
                                                <strong>Properties:</strong> #PROPERTIES#</div>
                                        </div>
                                        <div class="col d-flex flex-row-reverse align-items-center">
                                            <i data-feather="plus-circle"></i>
                                        </div>
                                    </div>
                                </li>
                            </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <!-- <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="submit" class="btn btn-primary" >Save</button>
            </div> -->
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->
<script type="text/javascript">


    // ready function
    $(function() {

        $('#modalExistingComponents').on('hidden.bs.modal',function(event){
            if(typeof window.tempAddCompIdRef != "undefined"
                && window.tempAddCompIdRef != null){

                var compId = window.tempAddCompIdRef;

                window.tempAddCompIdRef = null;

                addComponentToGrid(compId);
            }
        });


    });

    function addExistingComponentToGrid(compId){

        window.tempAddCompIdRef = compId;
        $('#modalExistingComponents').modal('hide');
    }

    function openAddEditComponentModal(fileType){

        var modal = $('#modalAddEditComponent');
        var form = $('#formAddEditComponent');

        form.get(0).reset();
        form.removeClass('was-validated');
        $('#fileErrorMsg').text('');
        modal.find('.clearContent').html('');
        modal.find('.is-invalid').removeClass('is-invalid');
        modal.find('.modal-title').text("Add a new component");
        $('#compFileLabel').text('Upload new file');

        form.find('[name=id]').val('');
        form.find('[name=name]').val('');

        addComponentIdProperty();

        loadDependenciesList();

        modal.modal('show');

    }

    function editComponent(id, isFilterList){
        showLoader();
        $.ajax({
            url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getComponentInfo',
                id : id,
            },
        })
        .done(function(resp) {
            if(resp.status == 1){
                var compData = resp.data.component;
                editComponentModal(compData);
                if(isFilterList === true){
                    window.componentsTable.search(compData.name).draw();
                }
            }
        })
        .fail(function() {
            bootNotifyError("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function editComponentModal(data){
        var modal = $('#modalAddEditComponent');
        var form = $('#formAddEditComponent');

        form.get(0).reset();
        form.removeClass('was-validated');
        $('#fileErrorMsg').text('');
        modal.find('.clearContent').html('');
        modal.find('.is-invalid').removeClass('is-invalid');


        modal.find('.modal-title').text('Edit ' + data.name + ' component');
        $('#compFileLabel').text('Upload new file');


        form.find('[name=id]').val(data.id);
        form.find('[name=name]').val(data.name);

        data.properties.forEach(function(prop){
            addCompProperty(prop);
        });

        data.urls.forEach(function(url){
            addCompUrl(url);
        });

        data.dependencies.forEach(function(dependency){
            addCompDependency(dependency);
        });

        data.packages.forEach(function(package){
            addCompPackage(package);
        });

        data.libraries.forEach(function(library){
            addCompLibrary(library);
        });

        addComponentIdProperty();
        loadDependenciesList();

        modal.modal('show');
    }

    function loadDependenciesList(){
        showLoader();
        $.ajax({
            url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getListShort'
            },
        })
        .done(function(resp) {

            if(resp.status == 1){
                var components = resp.data.components;

                var select = $('#compDependencyTemplate [name=dependency_comp_id]');
                var optionsHtml = '<option value="">-- select component --</option>';

                $.each( components , function(index, comp) {
                    optionsHtml = optionsHtml + '<option value="'+comp.id+'">'+comp.name+'</option>';
                });

                select.html(optionsHtml);
            }
            else{
                bootNotifyError(resp.message);
            }

        })
        .fail(function() {
            bootNotifyError("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function saveComponent(addToGrid){
        var modal = $('#modalAddEditComponent');
        var form = $('#formAddEditComponent');
        var errorMsgEle = $('#fileErrorMsg')

        var isError = false;

        if(!form.get(0).checkValidity()){
            isError = true;
        }

        var name = form.find('input[name=name]');
        var fileId = form.find('input[name=id]');
        var fileInput = form.find('input[name=file]');

        if( name.val().trim().length == 0 ||  !isalphanumeric(name.val().trim()) ){
            name.addClass('is-invalid');
            name.get(0).setCustomValidity("Cannot be empty");
            isError = true;
        }

        if(fileInput.get(0).files.length > 0){
            var errorMsg = validateFileUpload(fileInput,"jsx");
            fileInput.get(0).setCustomValidity(errorMsg);
            if(errorMsg.length > 0){
                //errorMsgEle.html(errorMsg).show();
                isError = true;
            }
        }

        // $('#compPropertiesDiv').find('.compPropertyDiv').each(function(index, el) {
        //     var property_name = $(el).find('[name=property_name]');
        //     var property_type = $(el).find('[name=property_type]');

        //     if(property_name.val().trim().length === 0){
        //         property_name.addClass('is-invalid');
        //     }

        //     if(property_type.val().trim().length === 0){
        //         property_type.addClass('is-invalid');
        //     }

        // });

        if(isError){
            form.addClass('was-validated');
            return false;
        }

        // if(form.find('.is-invalid').length > 0){
        //     form.find('.is-invalid').get(0).focus();
        //     return false;
        // }

        form.find(':disabled').prop('disabled',false);

        var formData = new FormData(form.get(0));
        showLoader();
        $.ajax({
            type :  'POST',
            url :   'componentSave.jsp',
            data :  formData,
            dataType : "json",
            cache : false,
            contentType: false,
            processData: false,
        })
        .done(function(resp) {
            if(resp.status == 1){

                form.get(0).reset();

                modal.modal('hide');
                bootNotify(resp.message);
                if(typeof refreshTable !== "undefined"){
                    refreshTable();
                }

                if(addToGrid){
                    addComponentToGrid(resp.data.id);
                }
            }
            else{
                bootNotifyError(resp["message"]);
            }
        })
        .fail(function(resp) {
             bootNotifyError("Error in contacting server.Please try again.");
        })
        .always(function() {
            hideLoader()
        });

    }

    function onFileInputChange(input){
        input = $(input);
        var form = $('#formAddEditComponent');

        var fileType = "jsx";
        var fileId = form.find('[name=id]').val();

        var errorMsg = "";
        var numFiles = input.get(0).files.length;
        var fileNameValue = "";
        $('#fileErrorMsg').text('');
        if(numFiles > 0){
            var file = input.get(0).files[0];

            var fileName = file.name;

            var fileExt = fileName.substring(fileName.lastIndexOf('.')+1);

            if(ALLOWED_TYPES[fileType].indexOf(fileExt) < 0){
                errorMsg = "Error: please selected valid filetype.";
                $('#fileErrorMsg').text(errorMsg);
            }
            $('#compFileLabel').text(fileName);

            if(fileName.lastIndexOf('.') >= 0){
                fileName = fileName.substring(0,fileName.lastIndexOf('.'));
            }
            var fileNameInput = form.find('[name=name]');
            fileNameInput.val(fileName);

            fileNameInput.removeClass('is-invalid');
        }
    }

    function addComponentIdProperty(){
        var compPropertiesDiv = $('#compPropertiesDiv');
        var template = $('#compPropertyTemplate');

        var isExist = false;
        compPropertiesDiv.find('.compPropertyDiv [name=property_name]').each(function(index, el) {
            if($(el).val() == "componentId"){
                isExist = true;
            }
        });

        if(!isExist){
            var data = {
                propert_id : '',
                name : "componentId",
                type : "string",
                is_required : "1"
            }

            addCompProperty(data);
        }
    }

    function addCompProperty(data){
        var compPropertiesDiv = $('#compPropertiesDiv');
        var template = $('#compPropertyTemplate');

        var templateHtml = template.html();

        var newProperty = $(templateHtml);

        var isCompId = false;
        if(data){
            newProperty.find('[name=property_id]').val(data.id);
            newProperty.find('[name=property_name]').val(data.name);
            newProperty.find('[name=property_type]').val(data.type);
            newProperty.find('[name=property_is_required]').val(data.is_required);

            isCompId = (data.name == "componentId");
            if(isCompId){
                newProperty.find('input,select').prop('disabled',true);
            }
        }
        newProperty.find('[name=property_name]').on('input',onPropertyNameInput);

        if(isCompId){
            compPropertiesDiv.prepend(newProperty);
        }
        else{
            compPropertiesDiv.append(newProperty);
        }
    }

    function onPropertyNameInput(event){
        allowAphaNumericOnly(event.target);
    }

    function deleteParent(ele, parentSearchTerm){

        $(ele).parents(parentSearchTerm+':first').remove();
    }

    function addCompUrl(url){
        var container = $('#compUrlsDiv');
        var template = $('#compUrlTemplate');

        var templateHtml = template.html();

        var newUrl = $(templateHtml);

        if(url){
            newUrl.find('[name=comp_url]').val(url);
        }

        container.append(newUrl);
    }


    function addCompDependency(data){
        var container = $('#compDependenciesDiv');
        var template = $('#compDependencyTemplate');

        var curEditCompId = $('#curEditCompId').val();

        var templateHtml = template.html();

        var newDependancy = $(templateHtml);

        var dependencySelect = newDependancy.find('[name=dependency_comp_id]');

        if(curEditCompId.length > 0){
            dependencySelect.find('option[value='+curEditCompId+']').remove();
        }

        if(data){
            dependencySelect.val(data.id);
        }

        container.append(newDependancy);
    }

    function addCompPackage(data){
        var container = $('#compPackagesDiv');
        var template = $('#compPackageTemplate');

        var templateHtml = template.html();

        var newPackage = $(templateHtml);

        if(data){
            newPackage.find('[name=package_name]').val(data.package_name);
        }

        container.append(newPackage);
    }

    function addCompLibrary(data){
        var container = $('#compLibrariesDiv');
        var template = $('#compLibraryTemplate');

        var templateHtml = template.html();

        var libDiv = $(templateHtml);

        if(data){
            libDiv.find('[name=library_id]').val(data.library_id);
        }
        container.append(libDiv);
    }

    function openExistingComponentsModal(){
        var modal = $('#modalExistingComponents');
        var form = $('#formExistingComponents');

        form.get(0).reset();
        modal.find('.clearContent').html('');
        showLoader();
        $.ajax({
            url: 'componentsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'getListShort'
            },
        })
        .done(function(resp) {
            var listHtml = '';
            if(resp.status == 1){
                var components = resp.data.components;
                var listItemTemplate = $('#existingComponentsListTemplate');

                $.each( components , function(index, obj) {
                    var itemHtml = listItemTemplate.html();
                    itemHtml = strReplaceAll(itemHtml, "#ID#", obj.id);
                    itemHtml = strReplaceAll(itemHtml, "#NAME#", obj.name);
                    itemHtml = strReplaceAll(itemHtml, "#PROPERTIES#", obj.properties);

                    listHtml = listHtml + itemHtml;
                });
            }
            else{
                bootNotifyError(resp.message);
            }

            $('#existingComponentsList').html(listHtml);

        })
        .fail(function() {
            bootNotifyError("Error contacting server.");
        })
        .always(function() {
            hideLoader();
        });

        modal.modal('show');
    }

    function searchExistingComponents(input){
        var searchTerm = $(input).val().trim();

        var itemList = $("#existingComponentsList");

        if(searchTerm.length == 0){
            itemList.find(".componentListItem").show();
        }
        else{
            searchTerm = searchTerm.toLowerCase();
            itemList.find(".componentListItem").each(function(index, el) {
                var name = $(el).find(".componentName").text().trim();
                if(name.toLowerCase().indexOf(searchTerm) >= 0){
                    $(el).show();
                }
                else{
                    $(el).hide();
                }
            });
        }
    }


</script>