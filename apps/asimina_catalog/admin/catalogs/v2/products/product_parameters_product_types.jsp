<%-- Product type modal --%>
<div class="modal fade" id="addProductTypeModal" tabindex="-1" data-backdrop="static" aria-labelledby="addProductTypeModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title" id="addProductTypeModalLabel">Add Product Type</h2>
                <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal"  onclick="closeProductTypeModal()" aria-label="Close">
                <span aria-hidden="true">&times;</span>
                </button>
            </div>
			<div class="modal-body">
				<div class="mb-2 text-right" id="saveProductTypes">
					<button type="button" class="btn btn-primary" onclick="saveProductType()">Save</button>
				</div>
				
				<form id="productTypeForm">
					<div class="card mb-2">
						<div class="card-header bg-section-dark" style="background-color:#4F5D73;color:#ffffff;" data-toggle="collapse" href="#productInfoSectionCollapse" role="button" aria-expanded="true" aria-controls="productInfoSectionCollapse"><strong>Product Type Information</strong></div>
						<div class="collapse show" id="productInfoSectionCollapse" style="border:none; margin-bottom:none;">
	
							<div class="card-body">
								<div class="form-group row">
									<label for="productName" class="col-sm-3 col-form-label">Product Type Name</label>
									<div class="col-sm-9">
										<input type="text" class="form-control validateProducType" id="productName" value="" required="required">
                                        <div class="invalid-feedback">
                                            Product type name cannot be empty.
                                        </div>
									</div>
								</div>

								<div class="form-group row">
									<label for="productTemplate" class="col-sm-3 col-form-label">Template</label>
									<div class="col-sm-9">
										<select class="custom-select validateProducType" id="productTemplate">
										</select>
									</div>
								</div>
								<div class="form-group row">
									<label for="categoriesList" class="col-sm-3 col-form-label">Categories</label>
									<div class="col-sm-9" id="availableCategories">
                                        <div class="add_field text-right mt-2">
                                            <button type="button" class="btn btn-success btn-sm" onclick="appendCategory(null)">Add a Value</button>
                                        </div>
									</div>
								</div>

								<div class="form-group row">
									<label for="attributesList" class="col-sm-3 col-form-label">Attributes</label>
									<div class="col-sm-9" id="availableAttributes">
										<div class="add_field text-right mt-2">
											<button type="button" class="btn btn-success btn-sm" onclick="appendAttribute(null)">Add a Value</button>
										</div>
									</div>
								</div>
								
								<div class="form-group row">
									<label for="specificationsList" class="col-sm-3 col-form-label">
                                        Specifications <a href="#" class="ml-2" data-toggle="tooltip" title=""></a>
                                        <svg viewBox="0 0 24 24" width="15" height="15" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg><br>
                                        <button type="button" class="btn btn-success mt-2" data-toggle="modal" onclick="downloadSpecifications()">Download<svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg></button>
                                    </label> 

									<div class="col-sm-9" id="specificationsInfo">
									</div>
								</div>
							</div>
						</div>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>

<script type="text/javascript">

    let defaultCategories;
    let defaultAttributes;

    function returnProductRow(product){
        let infoMsg = "";
        if(product.updated_ts !== null && product.updated_ts !== undefined){
            infoMsg+=`Last changes on ${product.updated_ts} by ${product.updated_by_user}`;
        }
        if(product.created_ts !== null && product.created_ts !== undefined){
            infoMsg+=`</br>Created on ${product.created_ts} by ${product.created_by_user}`;
        }


        let html = `<tr class="table-success">
            <td><strong>${product.type_name}</strong></td>
            <td>${product.template}</td>
            <td>${product.attributes.length}</td>
            <td>${product.categories.length}</td>
            <td>${product.nb_uses}</td>
            <td>${product.updated_ts} <a href="javascript:void(0)" class="custom-tooltip" data-toggle="tooltip" title="" data-original-title="${infoMsg}"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-info"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg></a></td>
            <td class="text-right">
                <button type="button" class="btn btn-sm btn-primary" onclick="openProductTypeModal('${btoa(JSON.stringify(product))}',false)" data-toggle="modal" data-target="#addProductTypeModal"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-edit"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
                <button type="button" class="btn btn-sm btn-primary" onclick="openProductTypeModal('${btoa(JSON.stringify(product))}',true)"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-copy"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg></button>
                <button class="btn btn-sm btn-danger" onclick="deleteProductType('${product.uuid}')"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
            </td>
        </tr>`;
        return html;
    }
    
    function makeProductRows(){
        $.ajax({
            url: 'product_parameters_ajax.jsp',
            type: 'GET',
            dataType: 'json',
            data: {
                requestType: 'getProductTypes',
            },
        })
        .done(function(resp) {
            if (resp.status == 1) {
                let products = resp.data.product_types;
                for(let i=0;i<products.length;i++){
                    const productsTable = document.getElementById(`productsTable`);
                    productsTable.innerHTML += returnProductRow(products[i]);
                }
            }
            else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            alert("Error in accessing server.");
        });
    }

    function openProductTypeModal(productData, isCopy){
        let product = productData;
        if(product !== null){
            product = JSON.parse(atob(product));
            $("#addProductTypeModalLabel").html("Edit product type");
        }else $("#addProductTypeModalLabel").html("Add product type");

        $.ajax({
            url: 'product_parameters_ajax.jsp',
            type: 'GET',
            dataType: 'json',
            data: {
                requestType: 'getProductDefaultData',
            },
        }).done( function(resp){
            if(resp.status === 1){
                emptyProductTypeModal();

                defaultCategories = resp.data.categories;
                defaultAttributes = resp.data.attributes;

                let selectElement = document.getElementById("productTemplate");
                let templates = resp.data.templates;
                selectElement.innerHTML="";
                
                templates.forEach(optionData => {
                    let option = document.createElement("option");
                    option.value = optionData.id;
                    option.textContent = optionData.name;
                    if (product !== null && optionData.id === product.template_id) option.setAttribute("selected", true);
                    selectElement.appendChild(option);
                });

                let specifications = {};
                if(product!=null) {
                    if(!isCopy) document.getElementById("productInfoSectionCollapse").innerHTML+=`<input id="productTypeUuid" type="text" hidden="true" value="${product.uuid}">`;
                    document.getElementById("productName").value=product.type_name;

                    for(let i=0;i<product.categories.length;i++) { appendCategory(product.categories[i]); }
                    for(let i=0;i<product.attributes.length;i++) { appendAttribute(product.attributes[i]); }
                    if(product.specifications !== undefined && product.specifications !== null) specifications = product.specifications;
                }

                let specificationHtml= `<select class="custom-select mb-2" id="specificationsList" onchange='manageSpecification(${JSON.stringify(specifications)})'>`;
                if(Object.keys(specifications).length > 0) {
                    if(specifications.data_entry_type==="icecat") specificationHtml+=`<option  value="manual">Manualy</option><option selected value="icecat">Icecat</option>`;
                    else if(specifications.data_entry_type==="manual") specificationHtml+=`<option selected value="manual">Manualy</option><option value="icecat">Icecat</option>`;
                    else specificationHtml+=`<option value="manual">Manualy</option><option value="icecat">Icecat</option>`;
                } 
                else specificationHtml+=`<option value="manual">Manualy</option><option value="icecat">Icecat</option>`;

                specificationHtml+=`</select>`;
                document.getElementById("specificationsInfo").innerHTML = specificationHtml;
                manageSpecification(JSON.stringify(specifications));

                if(product) toggleAttributes(true,isCopy);
            }
            else bootNotifyError(resp.message);
        });
        $("#addProductTypeModal").modal("show");
    }

    function manageSpecification(specifications){
        specifications = typeof specifications === 'string'?JSON.parse(specifications):specifications;
        
        let specificationHtml="";
        let select = document.getElementById('specificationsList');

        if(select!==null && select.nextElementSibling !== null) {
            while (select.nextElementSibling) {
                let nextSibling = select.nextElementSibling;
                if (nextSibling && (nextSibling.id === 'specsIcecat' || nextSibling.id === 'specsManualy' || nextSibling.id === 'manualSpecificationType')) {
                    nextSibling.parentNode.removeChild(nextSibling);
                }
            }
        }

        if(select.value==="icecat") {
            specificationHtml+=`<div id="specsIcecat" class="input-group mb-3">
                        <div class="custom-file">
                            <input type="file" class="custom-file-input" id="iceCatFile" aria-describedby="inputGroupFileAddon01" placeholder="Load file">
                            <label class="custom-file-label" for="iceCatFile">Choose file</label>
                        </div>
                    </div>`;
            document.getElementById("specificationsInfo").insertAdjacentHTML('beforeend', specificationHtml);
        } else {
            let manualType = "";
            specificationHtml= `<select class="custom-select mb-2" id="manualSpecificationType" onchange='changeManualSpecification(${JSON.stringify(specifications)})'><option value="" disabled>-- Select a type --</option>`;

            if(Object.keys(specifications).length > 0){
                if(specifications.data_type==="free") {
                    specificationHtml+=`<option selected value="free">Free</option><option value="json">Key:Value</option>`;
                    manualType="free";
                } else if(specifications.data_type==="json") {
                    specificationHtml+=`<option value="free">Free</option><option selected value="json">Key:Value</option>`;
                    manualType="json";
                } 
            } else specificationHtml+=`<option value="json">Key:Value</option> <option value="free">Free</option>`;

            document.getElementById("specificationsInfo").insertAdjacentHTML('beforeend', specificationHtml);
            changeManualSpecification(JSON.stringify(specifications));
        }
    }

    function addSpecification(label,value) {
        let specificationHtml=`<input type="checkbox" class="mx-2" name="is_indexed" value="0" onchange="updateIndexValue(this)">
        <input type="text" class="form-control validateProducType" name="specLabel" value="${label}">
                <input type="text" class="form-control validateProducType" name="specValue" value="${value}">
                <div class="input-group-append">
                    <button class="btn btn-danger" type="button" onclick="removeThisField(this)"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                </div>`;
        
        var tempDiv = document.createElement("div");
        tempDiv.className = "input-group mb-2 jsonSpecfication";
        tempDiv.innerHTML = specificationHtml;

        var parentDiv = document.getElementById("specsManualy");
        let newChildIndex = parentDiv.children.length - 1;
        if(newChildIndex<0) newChildIndex = 0
        var secondToLastChild = parentDiv.children[newChildIndex];
        parentDiv.insertBefore(tempDiv, secondToLastChild);
    }
    

    function changeManualSpecification(specs) {
        let specification = null;
        specs = typeof specs === 'string'?JSON.parse(specs):specs;
        
        if(Object.keys(specs).length > 0 && specs.specification.length > 0) specification=specs.specification;

        let select = document.getElementById('manualSpecificationType');
        if(select!==null && select.nextElementSibling !== null) {
            while (select.nextElementSibling) {
                let nextSibling = select.nextElementSibling;
                if (nextSibling && (nextSibling.id === 'specsIcecat' || nextSibling.id === 'specsManualy' || nextSibling.id === 'manualSpecificationType')) {
                    nextSibling.parentNode.removeChild(nextSibling);
                }
            }
        }

        let specificationHtml =`<div id="specsManualy">`;
        if(select.value==="free") {
            if(specification===null) specification = "";
            try {
                JSON.parse(specification);
                specificationHtml+=`<textarea class="form-control mb-2 validateProducType" id="specsContentManually" rows="3" placeholder="paste specifications in bulk using this format:
                    label,value,is_indexed;
                    label,value,is_indexed;" value=""></textarea>`;
            } catch (error) {
                specificationHtml+=`<textarea class="form-control mb-2 validateProducType" id="specsContentManually" rows="3" placeholder="paste specifications in bulk using this format:
                label,value,is_indexed;
                label,value,is_indexed;" value="${specification}">${specification}</textarea>`;
            }
        } else {
            if(specification!==null && specification.length>0) {
                try {
                    specification = JSON.parse(specification);
                    for(let i=0;i<specification.length; i++) {
                        let isIndexed = "";
                        let indexValue = "0";
                        if(!specification[i].is_indexed || specification[i].is_indexed==="1") {
                            isIndexed = "checked";
                            indexValue="1";
                        }

                        specificationHtml+=`<div class="input-group mb-2 jsonSpecfication">
                            <input type="checkbox" class="mx-2" name="is_indexed" value="${indexValue}" ${isIndexed} onchange="updateIndexValue(this)">
                            <input type="text" class="form-control validateProducType" name="specLabel" value="${specification[i].specLabel}">
                            <input type="text" class="form-control validateProducType" name="specValue" value="${specification[i].specValue}">
                            <div class="input-group-append">
                                <button class="btn btn-danger" type="button" onclick="removeThisField(this)"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                            </div>
                        </div>`;
                    }
                } catch (error) {}
            }

            specificationHtml+=`<div class="add_field text-right">
                    <button type="button" class="btn btn-success btn-sm" onclick="addSpecification('','')">Add a Value</button>
                </div>
            </div>`;
        }
        document.getElementById("specificationsInfo").insertAdjacentHTML('beforeend',specificationHtml);
    }

    function updateIndexValue(checkbox) {
        if (checkbox.checked) checkbox.value = "1";
        else checkbox.value = "0";
    }

    function appendAttribute(attribute) {
        let parentDiv = document.getElementById('availableAttributes');
        let htmlToAppend = `<select class="custom-select attributesList" name="attributesList" id="attributesList">`;

        for(let i=0;i<defaultAttributes.length;i++) {
            let selected = "";
            if(attribute!== null && defaultAttributes[i].uuid===attribute.uuid) selected = "selected";
            htmlToAppend+=`<option ${selected} value="${defaultAttributes[i].uuid}">${defaultAttributes[i].atrName}</option>`
        }

        htmlToAppend+=`</select>
                        <div class="input-group-append">
                            <button class="btn btn-danger" type="button" onclick="removeThisField(this)"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                        </div>`;
        
        let newElement = document.createElement('div');
        newElement.className = "input-group mb-2";
        newElement.innerHTML = htmlToAppend;
        parentDiv.insertBefore(newElement, parentDiv.children[parentDiv.children.length - 1]);
    }

    function appendCategory(category) {
        let parentDiv = document.getElementById('availableCategories');
        let htmlToAppend = `<select class="custom-select categoriesList" name="categoriesList" id="categoriesList">`;

        for(let i=0;i<defaultCategories.length;i++) {
            let selected = "";
            if(category!== null && defaultCategories[i].uuid===category.uuid) selected = "selected";
            htmlToAppend+=`<option ${selected} value="${defaultCategories[i].uuid}">${defaultCategories[i].name}</option>`
        }
        
        for(let i=0;i<defaultCategories.length;i++){
            if(defaultCategories[i].sub_categories != null) htmlToAppend+=getCategoriesOptions(defaultCategories[i],category);
        }

        htmlToAppend+=`</select>
                        <div class="input-group-append">
                            <button class="btn btn-danger" type="button" onclick="removeThisField(this)"><svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>
                        </div>`;
        
        let newElement = document.createElement('div');
        newElement.className = "input-group mb-2";
        newElement.innerHTML = htmlToAppend;
        parentDiv.insertBefore(newElement, parentDiv.children[parentDiv.children.length - 1]);
    }

    function getCategoriesOptions(parentCategory, selectedCategory) {
        let htmlString = `<optgroup class="bg-secondary" label="${parentCategory.name}">`;
        let categories = parentCategory.sub_categories; 

        for(let i=0;i<categories.length;i++){
            let selected = "";
            if(selectedCategory!== null && categories[i].uuid===selectedCategory.uuid) selected = "selected";
            htmlString+=`<option ${selected} value="${categories[i].uuid}">${categories[i].name}</option>`;
        }
        htmlString+=`</optgroup>`;

        for(let i=0;i<categories.length;i++){
            if(categories[i].sub_categories != null) htmlString+=getCategoriesOptions(categories[i],selectedCategory);
        }
        return htmlString;
    }

    function removeThisField(button) {
        var parentDiv = button.parentNode.parentNode;
        parentDiv.parentNode.removeChild(parentDiv);
    }

    function deleteProductType(productId) {
        bootConfirm("Are you sure you want to delete this type?", function (result) {
            if (result) {
                $.ajax({
                    url: "product_parameters_ajax.jsp",
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        requestType: 'deleteProductType',
                        productId:productId,
                    },
                }).done( function(resp){
                    if(resp.status === 1){
                        document.getElementById("productsTable").innerHTML="";
                        makeProductRows();
                    }
                    else bootNotifyError(resp.message);
                });
            }
        });
    }

    function saveProductType() {
        if(validateInputs("validateProducType")) {
            let saveJson = getProductTypeJson();
            $.ajax({
                url: "product_parameters_ajax.jsp",
                type: 'POST',
                dataType: 'json',
                data: {
                    requestType: 'saveProductType',
                    productType : JSON.stringify(saveJson),
                },
            }).done( function(resp){
                if(resp.status === 0) {
                    closeProductTypeModal();
                    bootNotifyError(resp.message);
                } else {
                    if(saveJson.productTypeUuid) bootNotify("Product Type updated successfully.");
                    else bootNotify("Product Type saved successfully.");

                    document.getElementById("productsTable").innerHTML="";
                    makeProductRows();
                    closeProductTypeModal();
                }
            });
        }
    }

    function getProductTypeJson() {
        let saveJson={};
        if(document.getElementById('productTypeUuid') !== undefined && document.getElementById('productTypeUuid') !== null) {
            saveJson["productTypeUuid"] = document.getElementById('productTypeUuid').value;
        }
        saveJson["productName"] = document.getElementById('productName').value;
        saveJson["templateId"] = document.getElementById('productTemplate').value;
        
        let categories = [];
        let inputs = document.getElementsByName('categoriesList');
        for(var i = 0; i < inputs.length; i++) { categories.push(inputs[i].value); }

        saveJson["categories"] = categories;

        let attributes = [];
        inputs = document.getElementsByName('attributesList');
        for(var i = 0; i < inputs.length; i++) { attributes.push(inputs[i].value); }
        
        saveJson["attributes"] = attributes;
        saveJson["specJson"] = getSpecificationJson();
        return saveJson;
    }

    function getSpecificationJson() {
        let specification = {};
        let  data_entry_type = document.getElementById("specificationsList").value;
        specification["data_entry_type"] = data_entry_type;

        if(data_entry_type==="manual"){
            let  specType = document.getElementById("manualSpecificationType").value;
            specification["data_type"] = specType;

            if(specType === "free") specification["specifications"] = document.getElementById("specsContentManually").value;
            else {
                let specs = [];

                let specsDiv = document.getElementsByClassName('jsonSpecfication');
                for(var i = 0; i < specsDiv.length; i++) {
                    let specJson = {};
                    specJson["specLabel"] = specsDiv[i].querySelector("input[name='specLabel']").value;
                    specJson["specValue"] = specsDiv[i].querySelector("input[name='specValue']").value;
                    specJson["is_indexed"] = specsDiv[i].querySelector("input[name='is_indexed']").value;

                    specs.push(specJson);
                }
                specification["specifications"] = specs;
            }
        }
        return specification;
    }

    function downloadSpecifications() {
        let specification = getSpecificationJson();
        if(specification.data_entry_type==="manual") {
            let blob = new Blob([JSON.stringify(specification, null, 4)], { type: 'application/json' });
            let url = window.URL.createObjectURL(blob);
            let a = document.createElement('a');
            a.href = url;
            a.download = "specifications.json";
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url)
        }
    }

    function closeProductTypeModal() { emptyProductTypeModal(true); }

    function emptyProductTypeModal(isClose) {

        document.getElementById("productName").value ="";
        if(document.getElementById('productTypeUuid') !== null) document.getElementById('productTypeUuid').remove();

        toggleAttributes(false,false);
        
        let parentElement = document.getElementById('availableCategories');
        let childElements = parentElement.children;
        while(childElements.length>1) { parentElement.removeChild(childElements[0]); }

        parentElement = document.getElementById('availableAttributes');
        childElements = parentElement.children;
        while(childElements.length>1) { parentElement.removeChild(childElements[0]); }

        let select = document.getElementById('specificationsList');
        if(select && document.getElementById('specificationsList').value=="manual"){
            if(document.getElementById('manualSpecificationType').value=="free") {
                if(document.getElementById("specsManualy")) document.getElementById("specsManualy").querySelector("#specsContentManually").value="";
            } 
            else Array.from(document.getElementById("specsManualy").getElementsByClassName("jsonSpecfication")).forEach(element => { element.remove(); });
        }
    }

    function toggleAttributes(isEdit,isCopy) {

        document.getElementById("productTemplate").disabled = isEdit;
/*
        if(isEdit && !isCopy){
            let selectElements = document.querySelectorAll('select[name="attributesList"]');
            selectElements.forEach((selectElement) => {
                selectElement.disabled = true;
            });

            let specDiv = document.getElementById("specificationsInfo");
            document.getElementById("specificationsList").disabled = true;
            document.getElementById("manualSpecificationType").disabled = true;

            if(specDiv.querySelector("#specsIcecat")){
                specDiv.querySelector("#iceCatFile").disabled=true;
            } else if(specDiv.querySelector("#specsManualy")){
                let specJson = specDiv.querySelector("#specsManualy").getElementsByClassName("jsonSpecfication");
                if(specJson.length>0){
                    Array.from(specJson).forEach(element => {
                        Array.from(element.querySelectorAll("input")).forEach(inputElement => {
                            inputElement.disabled = true;
                        });
                        element.querySelector('button').style.display = 'none';
                    });
                }else{
                    if(specDiv.querySelector("#specsContentManually")) specDiv.querySelector("#specsContentManually").disabled=true;
                }
            }
        }
        */
        let availableAttribBtn = document.querySelector('#availableAttributes .add_field > button');
        let specsManualyBtn =  document.querySelector('#specsManualy .add_field > button');
        
        /*if(isEdit  && !isCopy) {
            if(availableAttribBtn) availableAttribBtn.style.display = 'none';
            if(specsManualyBtn) specsManualyBtn.style.display = 'none';
        }else {
            if(availableAttribBtn) availableAttribBtn.style= '';
            if(specsManualyBtn) specsManualyBtn.style= '';
        }*/
        if(availableAttribBtn) availableAttribBtn.style= '';
        if(specsManualyBtn) specsManualyBtn.style= '';

        let addFieldDivs = document.querySelectorAll('#availableAttributes .input-group');
        if (addFieldDivs.length > 0) {
            addFieldDivs.forEach((addFieldDiv) => {
                //if(isEdit && !isCopy) addFieldDiv.querySelector('button').style.display = 'none';
                //else addFieldDiv.querySelector('button').style= '';
                addFieldDiv.querySelector('button').style= '';
            });
        }
    }

</script>
