<!-- Add Attribute Modal -->
        <div class="modal fade" id="addAttributeModal" tabindex="-1" aria-labelledby="addAttributeModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-slideout modal-md" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title" id="addAttributeModalLabel">Add attribute</h2>
                        <button type="button" onclick="clearAttributeModal()" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="card mb-2">
                            <div class="card-header bg-secondary" data-toggle="collapse" href="#globalInfoCollapse" role="button" aria-expanded="true" aria-controls="globalInfoCollapse">
                                <strong>Attribute</strong>
                            </div>
                            <div class="collapse show pt-3" id="globalInfoCollapse">
                                <div class="card-body">
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Name</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control validate" name="atrName" value="" maxlength="100" required="required">
                                            <div class="invalid-feedback">
                                                Attribute name cannot be empty.
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Type</label>
                                        <div class="col-sm-9">
                                            <select class="form-control validate" onchange="onTypeChange('globalInfoCollapse')" name="atrType">
                                                <option value="color">Color</option>
                                                <option value="text">Text</option>
                                                <option value="boolean">Boolean</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Unity</label>
                                        <div class="col-sm-9 attrUnitDiv">
                                            <input type="text" class="form-control" name="atrUnit" value="">
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Image</label>
                                        <div class="col-sm-9 attrImgDiv">
                                            <div class="card image_card" data-img-limit="1">
                                                <div class="card-body"> 
                                                    <span class="ui-state-media-default" style="padding:0px;display: inline-block;">
                                                        <div class="bloc-edit-media">
                                                            <button type="button" class="btn btn-success load-img" style="margin-right: .10rem;" onclick="loadFieldImageV2(this,false)">Add a media</button>
                                                            <button type="button" class="btn btn-danger no-img disabled" style="margin-right: .10rem;display:none">No more media</button>
                                                        </div>
                                                        <div class="bloc-edit-media-bgnd" style="height:100%; width:100%;min-width:145px;min-height:145px;  position:absolute; left:0; top:0">&nbsp;</div>
                                                        <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="<%=GlobalParm.getParm("EXTERNAL_CATALOG_LINK")%>img/add-picture-on.jpg">	
                                                    </span>															
                                                </div>														
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Value</label>
                                        <div class="col-sm-9 attrValDiv">
                                            <button type="button" class="btn btn-success addValBtnModal" onclick="appendAttributeValue(this)">Add a Value</button>
                                        </div>
                                    </div>
                                    
                                </div>
                                <!-- pagePathMainDiv -->
                            </div><!--  collapse -->
                        </div>
                    </div>
                    <div class="modal-footer" id="saveAttriutes">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="saveAttribute('globalInfoCollapse',false,'validate')">Save</button>
                    </div>
                </div>
            </div>
        </div>

<script type="text/javascript">
    window.PAGES_APP_URL = "<%=GlobalParm.getParm("PAGES_APP_URL")%>";
    window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = "<%=mediaUrl%>";
    window.IS_PRODUCT_SCREEN = true;
    function openAttributeModal(){
        $('#addAttributeModal').modal('show');
    }

    function makeAtrDivs(){
        $.ajax({
            url: 'product_parameters_ajax.jsp',
            type: 'GET',
            dataType: 'json',
            data: {
                requestType: 'getAttributes',
            },
        })
        .done(function(resp) {
            if (resp.status === 1) {
                let attributes = resp.data.attributes;
                for(let i=0;i<attributes.length;i++){
                    let atrJson = attributes[i];
                    const attributesDiv = document.getElementById("attributesCollapse").querySelector('div');
                    attributesDiv.innerHTML += returnAttributeHtml(atrJson.atrName,atrJson.atrType,atrJson.atrUnit,atrJson.atrIcon,atrJson.values,atrJson.atrId);
                }
                $(".color-picker").colorpicker();
            } else bootNotifyError(resp.message);
        }).fail(function() {
            alert("Error in accessing server.");
        });
    }

    function appendAttributeValue(button){
        let attributeType ="text";
        let attributeTypeSelect = button.parentElement.parentElement.parentElement.querySelector('select[name="atrType"]');
        if(attributeTypeSelect) attributeType = attributeTypeSelect.value;

        let valideClass = "validate";
        if(button.parentElement.parentElement.parentElement.parentElement.id.startsWith("collapseSectionAttribute")) valideClass = "validateAtr";

        let attrValHtml = `<div class="input-group mb-2 attrRow">
                <div class="input-group-prepend"> 
                    <span class="input-group-text" ><svg viewBox="0 0 24 24" width="18" height="18" style="transform: rotate(90deg);" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg></span>
                </div>		
                <input type="text" class="form-control ${valideClass}" name="atrValLabel" value="" required="required" placeholder="label">`;
                
                if(attributeType==="color") attrValHtml += `<input type="text" placeholder="value" autocomplete="off" name="atrValue" class="form-control _title-txt-color color-picker colorpicker-element ${valideClass}" value="" data-colorpicker-id="1" >`;
                else attrValHtml += `<input type="text" autocomplete="off" placeholder="value" name="atrValue" class="form-control ${valideClass}" value="" >`;
                
                attrValHtml+=`<div class="input-group-append">
                    <button class="btn btn-danger" type="button" onclick="removeAttributeValue(this)">x</button>
                </div>
            </div>`;
        button.insertAdjacentHTML('beforebegin', attrValHtml);
        
        setTimeout(() => {
            $(".color-picker").colorpicker();
        }, 500);
    }

    function removeAttributeValue(button) {
        let parentDiv = button.closest('.attrRow');
        if (parentDiv) parentDiv.remove();
    }

    function returnAttributeHtml(atrName,type,atrUnit,atrIcon,values,id){
        let atrId = `collapseSectionAttribute_`+document.getElementsByClassName(`attributeContent`).length;

        let html = `<div class="card mb-2 attributeContent">
                        <div class="btn-group w-100">
                            <button type="button" class="btn btn-block btn-success text-left" data-toggle="collapse" href="#${atrId}" aria-expanded="true" aria-controls="${atrId}" style="padding:0.75rem 1.25rem;">
                                <strong class="section_title">${atrName}</strong>
                            </button>
                            <button type="button" class="btn btn-danger" onclick="removeAttr('${id}',this)">x</button>
                        </div>
                        <div class="collapse show" id="${atrId}" style="border: none;">
                            <div class="card-body">
                                
                                <input type="text" hidden class="form-control" name="atrId" value="${id}">

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Attribute name</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control validateAtr" name="atrName" value="${atrName}">
                                        <div class="invalid-feedback">
                                            Attribute name cannot be empty.
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Type</label>
                                    <div class="col-sm-9">
                                        <select class="custom-select" onchange="onTypeChange('${atrId}')" name="atrType">`;
                                    
                                    let valueClass = "form-control";
                                    if(type==="color"){
                                        html+=`<option value="color" selected>Color</option><option value="text">Text</option><option value="boolean">Boolean</option>`;
                                        valueClass += " _title-txt-color color-picker colorpicker-element";
                                    } else if(type==="boolean") html+=`<option value="color">Color</option><option value="text">Text</option><option value="boolean" selected>Boolean</option>`;
                                    else html+=`<option value="color">Color</option><option value="text" selected>Text</option><option value="boolean">Boolean</option>`;

                                    html+=`</select>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Unity</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="atrUnit" value="${atrUnit}">
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Image</label>
                                    <div class="col-sm-9">
                                        <div class="card image_card" data-img-limit="1">
                                            <div class="card-body">
                                                ${atrIcon.length > 0 ? `<span class="ui-state-media-default mx-1" style="padding:0px;display: inline-block;">
                                                    <div class="bloc-edit-media">
                                                        <button type="button" class="btn btn-primary mx-1" style="margin-right: .10rem;" onclick='loadFieldImageV2(this,true)'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
                                                        <button type="button" class="btn btn-danger mx-1" style="margin-right: .1rem;" onclick='clearFieldImageV2(this)' ><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></button>
                                                    </div>
                                                    <div class="bloc-edit-media-bgnd" style="height:100%; width:100%; min-width:145px; min-height:145px; position:absolute; left:0; top:0">&nbsp;</div>
                                                    <input type="hidden" name="atrIcon" class="image_value" value="${atrIcon}"/>
                                                    <input type="hidden" name="image_alt" class="image_alt" />
                                                    <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="<%=mediaUrl%>${atrIcon}">
                                                </span> `:``}                                                
                                                <span class="ui-state-media-default" style="padding:0px;display: inline-block;">
                                                    <div class="bloc-edit-media">
                                                        <button type="button" class="btn btn-success load-img" style="margin-right: .10rem;${atrIcon.length > 0? `display:none`:``}" onclick="loadFieldImageV2(this,false)">Add a media</button>
                                                        <button type="button" class="btn btn-danger no-img disabled" style="margin-right: .10rem;${atrIcon.length > 0? ``:`display:none`}">No more media</button>
                                                    </div>
                                                    <div class="bloc-edit-media-bgnd" style="height:100%; width:100%;min-width:145px;min-height:145px;  position:absolute; left:0; top:0">&nbsp;</div>
                                                    <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="<%=GlobalParm.getParm("EXTERNAL_CATALOG_LINK")%>img/add-picture-on.jpg">	
                                                </span>															
                                            </div>														
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group row">
                                    <label class="col-sm-3 col-form-label">Value</label> 
                                    <div class="col-sm-9 attrValDiv">`;
                                
                                let readOnlyBoolean="";
                                let hiddenButton="";
                                if(type=="boolean") {
                                    readOnlyBoolean = "readonly";
                                    hiddenButton = "hidden='true'";
                                }

                                if(values.length > 0){
                                    for(let i=0; i<values.length;i++){
                                        html+=`<div class="input-group mb-2 attrRow">
                                                <div class="input-group-prepend"> 
                                                    <span class="input-group-text" id="addon-wrapping"><svg viewBox="0 0 24 24" width="18" height="18" style="transform: rotate(90deg);" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg></span>
                                                </div>
                                                <input type="text" class="form-control validateAtr" ${readOnlyBoolean} value="${values[i].atrValLabel}" name="atrValLabel" placeholder="label">
                                                <input type="text" autocomplete="off" ${readOnlyBoolean} class="${valueClass} validateAtr" value="${values[i].atrValue}" name="atrValue" placeholder="value" data-colorpicker-id="2">`;
                                        if(type!=="boolean"){
                                            html+=`<div class="input-group-append">
                                                <button class="btn btn-danger" type="button" onclick="removeAttributeValue(this)">x</button>
                                            </div>`;
                                        }  
                                        html+=`</div>`;
                                    }
                                }

                                html+=`<button type="button" class="btn btn-success addValBtnModal" ${hiddenButton} onclick="appendAttributeValue(this)">Add a Value</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>`;

        return html;
    }

    function removeAttr(id,btn){
        $.ajax({
            url: 'product_parameters_ajax.jsp',
            type: 'POST',
            dataType: 'json',
            data: {
                requestType: 'deleteAttribute',
                id:id,
            },
        }).done(function(resp) {
            if (resp.status === 1) {
                btn.parentElement.parentElement.remove();
                bootNotify("Attribute deleted successfully.")
            }else bootNotifyError(resp.message);
        })
        .fail(function() {
            alert("Error in accessing server.");
        });
    }

    function getAttributeJson(id,isEdit){
        var parentDiv = document.getElementById(id);
        let saveJson = {};
        saveJson["atrName"] = parentDiv.querySelector('input[name="atrName"]').value;
        saveJson["atrType"] = parentDiv.querySelector('select[name="atrType"]').value;
        saveJson["atrUnit"] = parentDiv.querySelector('input[name="atrUnit"]').value;
        saveJson["atrIcon"] = parentDiv.querySelector('input[name="atrIcon"]') ? parentDiv.querySelector('input[name="atrIcon"]').value : "";

        if(isEdit) saveJson["atrId"] = parentDiv.querySelector('input[name="atrId"]').value;
        
        let atrVals = [];
        const attrRows = parentDiv.querySelectorAll('.attrRow');
        attrRows.forEach(row => {
            const atrValLabelInput = row.querySelector('input[name="atrValLabel"]');
            const atrValueInput = row.querySelector('input[name="atrValue"]');
            const jsonObj = {
                atrValLabel: atrValLabelInput ? atrValLabelInput.value : '',
                atrValue: atrValueInput ? atrValueInput.value : ''
            };
            atrVals.push(jsonObj);
        });
        saveJson["values"] = atrVals;
        return saveJson;
    }

    function saveAttribute(id,isEdit,validateClass){
        if(validateInputs(validateClass)){
            let atrJson = getAttributeJson(id,isEdit);
            if(atrJson && atrJson.atrName.length>0 && atrJson.values.length>0){
                $.ajax({
                    url: 'product_parameters_ajax.jsp',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        requestType: 'saveAttribute',
                        atrJson:JSON.stringify(atrJson),
                    },
                }).done(function(resp) {
                    if (resp.status == 1) {
                        if(isEdit) bootNotify("Attribute updated successfully.");
                        else {
                            bootNotify("Attribute saved successfully.");
                            reloadAttributesInModal();
                        }
                    } else bootNotifyError(resp.message);
                }).fail(function() {
                    bootNotifyError("Error in accessing server.");
                });
            } else bootNotifyError("Attribute data is missing.");
        }
    }

    function reloadAttributesInModal(){
        clearAttributeModal();
        Array.from(document.getElementsByClassName("attributeContent")).forEach(element => {
            element.remove();
        });
        makeAtrDivs();
    }

    function validateInputs(validateClass){
        var inputs = document.querySelectorAll("."+validateClass);
        inputs.forEach(function(input) {
            if (input.value.trim() === '') input.classList.add('is-invalid');
            else input.classList.remove('is-invalid');
        });
        return document.querySelectorAll('.is-invalid').length>0?false:true;
    }

    function onSaveAttributes(){
        let atrDivs = document.getElementById(`attributesCollapse`).getElementsByClassName(`attributeContent`).length;
        for(let i=0;i<atrDivs;i++){
            if(document.getElementById(`collapseSectionAttribute_${i}`)) saveAttribute(`collapseSectionAttribute_${i}`,true,"validateAtr");
        }
    }

    function onTypeChange(id){
        var parentDiv = document.getElementById(id);
        let attributeType = parentDiv.querySelector('select[name="atrType"]');
        if(attributeType) attributeType = attributeType.value;
        
        $(parentDiv).find('.attrRow').remove();
        if(attributeType==="boolean") {
            $(parentDiv).find(".addValBtnModal").attr("hidden", true);

            let booleanHtml =`<div class="input-group mb-2 attrRow">
                                <input type="text" class="form-control validate" readonly name="atrValLabel" value="On" required="required" placeholder="label">
                                <input type="text" autocomplete="off" placeholder="value" readonly name="atrValue" class="form-control validate" value="1">
                            </div>
                            <div class="input-group mb-2 attrRow">
                                <input type="text" class="form-control validate" name="atrValLabel" readonly value="Off" required="required" placeholder="label">
                                <input type="text" autocomplete="off" placeholder="value" name="atrValue" readonly class="form-control validate" value="0">
                            </div>`
            $(booleanHtml).insertBefore($(parentDiv).find('.addValBtnModal'));

        } else $(parentDiv).find(".addValBtnModal").removeAttr("hidden");
    }

    function clearAttributeModal(){
        let parentDiv = document.getElementById("addAttributeModal");
        
        let input = parentDiv.querySelector(`input[name="atrName"]`);
        if (input) input.value = '';
        input = parentDiv.querySelector(`input[name="atrUnit"]`);
        if (input) input.value = '';
        
        // clearing image while closing modal
        parentDiv.querySelector(".ui-state-media-default").querySelector("button.btn-danger").click();
        
        let attributeType = parentDiv.querySelector('select[name="atrType"]');
        if(attributeType && attributeType.value != "boolean"){
            Array.from(parentDiv.getElementsByClassName("attrRow")).forEach(element => {
                element.remove();
            });
        }
    }

</script>