<%-- Product type modal --%>
<div class="modal fade" id="addProductTypeModal" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="addProductTypeModalLabel" style="display: none;" aria-hidden="true">
    <div class="modal-dialog modal-dialog-slideout modal-xl" role="document">
        <div class="modal-content">
            <div class="modal-header bg-lg1">
                <h5 class="modal-title font-weight-bold" id="addProductTypeModalLabel">Add a product</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close" onclick="emptyProductModal()">
                    <span aria-hidden="true">x</span>
                </button>
            </div>
            <div class="modal-body">
                <div id="createError1" class="alert alert-danger" role="alert" style="display:none">How do you want to create your product? Please choose an option.</div>
                <div id="createError2" class="alert alert-danger" role="alert" style="display:none">Please select a type of product.</div>
                <form style="padding:20px">
                    <div class="mb-5"><p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi. </p></div>
                    <div class="form-group row mt-5"><label class="col-sm-12 col-form-label">How do you want to create your product?</label></div>
                        
                    <div id="methodCreateProduct" class="row">
                        <div class="col-sm-4 mb-3 mb-sm-0">
                            <div id="manualy" class="card rollCard" onclick="selectCard('manualy')">
                                <div class="card-header bg-dark text-white font-weight-bold">
                                    <div class="form-group form-check" style="margin-bottom: 0px !important;">
                                        <input type="radio" class="form-check-input" id="manualyRadio" name="cardRadios">
                                        <label class="form-check-label" for="exampleCheck1">Manualy</label>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <p class="card-text">With supporting text below as a natural lead-in to additional content.</p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-sm-4">  
                            <div id="upload" class="card rollCard" onclick="selectCard('upload')">
                                <div class="card-header bg-dark text-white font-weight-bold">
                                    <div class="form-group form-check" style="margin-bottom: 0px !important;">
                                        <input type="radio" class="form-check-input" id="uploadRadio" name="cardRadios">
                                        <label class="form-check-label" for="exampleCheck1">by upload</label>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <p class="card-text">With supporting text below as a natural lead-in to additional content.</p>
                                </div>
                            </div>
                        </div>

                        <div class="col-sm-4">
                            <div id="icecat" class="card rollCard" onclick="selectCard('icecat')">
                                <div class="card-header bg-dark text-white font-weight-bold">
                                    <div class="form-group form-check" style="margin-bottom: 0px !important;">
                                        <input type="radio" class="form-check-input" id="icecatRadio" name="cardRadios">
                                        <label class="form-check-label" for="exampleCheck1">With Icecat</label>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <p class="card-text">With supporting text below as a natural lead-in to additional content.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div id="manualCreation" style="display: none;">
                        <div class="form-group row pageFieldRowName">
                                <label class="col-sm-3 col-form-label">Product name</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control validate" id="productName" value="" maxlength="100" required="required">
                                    <div class="invalid-feedback">
                                        Product name is required.
                                    </div>
                                </div>
                        </div>

                        <div class="form-group row">
                            <label for="staticEmail" class="col-sm-3 col-form-label">Type of product</label>
                            <div class="col-sm-9">
                                <select class="custom-select validate" id="manualProductType">
                                    <option value="">-- Select The type of product to create --</option>
                                    <%
                                        Set rsProductType = Etn.execute("select type_name, id from product_types_v2 where site_id="+escape.cote(selectedsiteid)+" order by id");
                                        while(rsProductType.next()){
                                    %>
                                            <option value="<%=escapeCoteValue(rsProductType.value("id"))%>"><%=escapeCoteValue(rsProductType.value("type_name"))%></option>
                                    <%
                                        }
                                    %>
                                </select>
                                <div class="invalid-feedback">Product type is required. </div>
                            </div>
                        </div>

                        <div class="form-group row pageFieldRowName">
                            <label class="col-sm-3 col-form-label">URL</label>
                            <div class="col-sm-9">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text" id="basic-addon3"><%=escapeCoteValue(escapeCoteValue(folderPrefixPath))%>/</span>
                                    </div>
                                    <input type="text" required onkeyup="onPathKeyup(this,true)" onblur="onPathBlur(this,true)" 
                                        class="form-control page_path validate" id="manualUrl" value="">
                                    <div class="input-group-append"><span class="input-group-text rounded-right">.html</span></div>
                                    <div class="invalid-feedback">Url is required.</div>
                                </div>
                            </div>
                        </div>

                        <div class="form-group row pageFieldRowName">
                            <label class="col-sm-3 col-form-label">Title</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control validate" id="manualTitle" value="" maxlength="100" 
                                    required>
                                <div class="invalid-feedback">Title is required.</div>
                            </div>
                        </div>

                        <div class="form-group row">
                            <label class="col-sm-3 col-form-label">Meta description</label>
                            <div class="col-sm-9">
                                <div class="input-group">
                                    <input required="required" type="text" class="form-control validate" id="metaDescription" 
                                        value="" maxlength="500">
                                    <div class="invalid-feedback">Meta description is required.</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="uploadCreation" style="display: none;">

                        <p class="card-text">You can load one or a bunch of products by using a CSV file or Xls field. If you have to load simple and confugurable produts, you have to upload separet file. you will find just below the template of file for somple product and configurable product.</p>

                        <div class="form-group row">
                            <label for="staticEmail" class="col-sm-3 col-form-label">Download file model for </label>
                            <div class="col-sm-9">
                                <div class="input-group">
                                    <select class="custom-select">
                                        <option selected="">-- Select a file model  --</option>
                                        <option value="2">Accessory</option>
                                        <option value="3">Offer</option>
                                        <option value="3">Phone</option>
                                    </select>
                                    <select class="custom-select">
                                        <option selected="">-- Select a format  --</option>
                                        <option value="2">XLS</option>
                                        <option value="3">CSV</option>
                                    </select>
                                </div>
                                
                            </div>
                        </div>
                        
                        <div class="form-group row pageFieldRowName">
                            <label class="col-sm-3 col-form-label">File to upload</label>
                            <div class="col-sm-9">
                                <div class="input-group mb-3">
                                    <div class="custom-file">
                                        <input type="file" class="custom-file-input" id="inputGroupFile02">
                                        <label class="custom-file-label">Choose file</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <p>Or</p>

                        <div class="form-group row pageFieldRowName">
                            <label class="col-sm-3 col-form-label">Copy / paste data</label>
                            <div class="col-sm-9">
                                <textarea class="form-control mb-2" rows="3" placeholder="paste data using the right format"></textarea> 
                            </div>
                        </div>

                    </div>

                    <div id="icecatCreation" style="display: none;">
                        <p class="card-text">Please fill in this information and upload the file from Icecat. The file must contain only one product, or, for configurable products, a set of variations.</p>
                        <div class="form-group row pageFieldRowName">
                            <label class="col-sm-3 col-form-label">URL</label>
                            <div class="col-sm-9">
                                <div class="input-group">
                                    <div class="input-group-prepend">
                                        <span class="input-group-text" id="basic-addon3">foldername/</span>
                                    </div>																		
                                    <input type="text" class="form-control" aria-label="" value="">
                                    <div class="input-group-append">
                                        <span class="input-group-text rounded-right">.html</span>
                                    </div>
                                </div>
                                <div class="invalid-feedback">
                                    Cannot be empty
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label for="staticEmail" class="col-sm-3 col-form-label">Type of product</label>
                            <div class="col-sm-9">
                                <select class="custom-select" id="inputGroupSelect03">
                                    <option selected="">-- Select the type of product to create --</option>
                                    <option value="2">Accessory</option>
                                    <option value="3">Offer</option>
                                    <option value="3">Phone</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-group row">
                            <label for="staticEmail" class="col-sm-3 col-form-label">How do you want to load data</label>
                            <div class="col-sm-9">
                                <select class="custom-select" id="inputGroupSelect03" onchange="icecatMethod(this)">
                                    <option selected="">-- Select the method --</option>
                                    <option value="upload">Formatted file upload</option>
                                    <option value="ean">Seek an EAN</option>
                                </select>
                            </div>
                        </div>
                        
        
                        <div id="methodEan" class="form-group row pageFieldRowName" style="display:none">
                            <label class="col-sm-3 col-form-label">Ean</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control" placeholder="EAN" aria-label="Recipient's username" aria-describedby="button-addon2">
                            </div>
                        </div>

                        <div id="methodUpload" class="form-group row pageFieldRowName" style="display:none">
                            <label class="col-sm-3 col-form-label">File to upload</label>
                            <div class="col-sm-9">
                                <div class="input-group mb-3">
                                    <div class="custom-file">
                                        <input type="file" class="custom-file-input" id="inputGroupFile02">
                                        <label class="custom-file-label">Choose file</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-2 text-right">
                        <button type="button" class="btn btn-primary" id="buttonNext" onclick="onSaveProduct()">Save & Next</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function openProductModal(productId){
        let modalLabel = document.getElementById("addProductTypeModal").querySelector("#addProductTypeModalLabel");
        if(productId.length>0){
            modalLabel.textContent = 'Edit product';
            $.ajax({
                url:'commercialProductsAjax.jsp',
                data: {
                    requestType:'getProductV2ById',
                    productId:productId
                }
            }).done(function(resp){
                let data = resp.data;
                if(data.save_type=="manualy"){
                    document.getElementById("addProductTypeModal")
                    document.getElementById("manualyRadio").checked = true;

                    document.getElementById("productName").value = data.name;
                    document.getElementById("manualUrl").value = data.url;
                    document.getElementById("manualTitle").value = data.title;
                    document.getElementById("metaDescription").value = data.meta_description;

                    var select = document.getElementById("manualProductType");
                    for (var i = 0; i < select.options.length; i++) {
                        var option = select.options[i];
                        if (option.value === data.product_type) {
                            option.selected = true;
                            break;
                        }
                    }
                    select.disabled=true;

                    let manualDiv = document.getElementById('manualCreation');
                    manualDiv.style.display = 'block';

                    var input = document.createElement('input');
                    input.setAttribute('type', 'text');
                    input.setAttribute('id', 'productV2Id');
                    input.setAttribute('value', data.id);
                    input.setAttribute('hidden', true);
                    manualDiv.appendChild(input);

                    input = document.createElement('input');
                    input.setAttribute('type', 'text');
                    input.setAttribute('id', 'productV1Id');
                    input.setAttribute('value', productId);
                    input.setAttribute('hidden', true);
                    manualDiv.appendChild(input);

                    $('#buttonNext').attr('onClick', 'onSaveProduct("'+data.save_type+'")');
                }
            });
        }else{
            modalLabel.textContent = 'Add a product';
            emptyProductModal();
            document.getElementById("manualProductType").disabled=false;
        }
        $("#addProductTypeModal").modal("show");
    }

    function selectCard(selectedObject){

        $(".rollCard").each(function( index ) {
            $( this ).removeClass("selected");
        });
    
        $("#"+selectedObject).addClass("selected");
        $("#"+selectedObject+"Radio").prop("checked", true);
        $('#buttonNext').attr('onClick', 'onSaveProduct("'+selectedObject+'")');
    
        if(selectedObject == "manualy") {
            $('#createError2').hide();
            
            $('#manualCreation').show();
            $('#uploadCreation').hide();
            $('#icecatCreation').hide();
        }
        else if(selectedObject == "upload") {
            $('#createError2').hide();
            
            $('#manualCreation').hide();
            $('#uploadCreation').show();
            $('#icecatCreation').hide();
        }
        else if(selectedObject == "icecat") {
            $('#createError2').hide();
            
            $('#manualCreation').hide();
            $('#uploadCreation').hide();
            $('#icecatCreation').show();
        }
    }
  
    function icecatMethod(selectedObject){
  
        $('#methodEan').hide();
        $('#methodUpload').hide();
    
        if(selectedObject.value == "ean") {
            $('#methodEan').show();
            $('#methodUpload').hide();
        }
        else if(selectedObject.value == "upload") {
            $('#methodEan').hide();
            $('#methodUpload').show();
        }
    }

    function createPagesThroughApi(product,productId,templateId,msg,pageId){
        $.ajax({
            url:'<%=com.etn.beans.app.GlobalParm.getParm("PAGES_APP_URL")%>admin/structuredContentsAjax.jsp',type: 'POST', dataType: 'json',
            data: {
                requestType: "saveContentSettings",
                folderId:'<%=escapeCoteValue(pagesFolderForProducts+"")%>',
                templateId:templateId,
                name:product.productName,
                folderType:"stores",
                version:"V2",
                productId:productId,
                title:product.title,
                meta_description:product.description,
                url:product.url,
                folderUrl:product.folderUrl,
                siteId:'<%=escapeCoteValue(selectedsiteid+"")%>',
                id:pageId,
                isFromProduct:"1",
                __wt:'<%=_wtId%>',
            }
        })  
        .done(function (resp){
            if(resp.status===1){
                hideLoader();
                emptyProductModal();
                $("#addProductTypeModal").modal("hide");
                location.href = '<%=com.etn.beans.app.GlobalParm.getParm("PAGES_APP_URL")%>admin/structuredPageEditor.jsp?id='+resp.data.id+'&folderId='+'<%=escapeCoteValue(pagesFolderForProducts+"")%>';
            }else{
                if(!pageId || pageId.length==0) deleteProductPermanently(productId,true);
                else {
                    onRspFunction("Error creating product.");
                }
            }
        });
    }

    function onRspFunction(msg) {
        document.getElementById("buttonNext").hidden=true;
        hideLoader();
        bootNotifyError(msg);
        setTimeout(function(){
            window.location.reload();
        },2000);
    }

    function deleteProductPermanently(productId,isRollback){
        $.ajax({
            url:'commercialProductsAjax.jsp',type: 'DELETE',
            data: {
                requestType: "deleteProductPermanently",
                productId: productId,
            }
        })  
        .done(function (resp){
            if(isRollback) {
                onRspFunction("Error creating product, data is rollbacked.");
            }else{
                if(resp.status==1) bootNotify(resp.msg);
                else bootNotifyError(resp.msg);
            } 
        });
    }
  
    function onSaveProduct(nextTreatment){
        if(nextTreatment == "manualy") {
            if(!validateInputs()){
                $('#createError1').show();
            }else{
                showLoader();
                $('#createError1').hide();

                let product = {};
                product["saveType"] = nextTreatment;
                product["productType"] = document.getElementById("manualProductType").value;
                product["productName"] = document.getElementById("productName").value;
                product["url"] = document.getElementById("manualUrl").value;
                product["title"] = document.getElementById("manualTitle").value;
                product["description"] = document.getElementById("metaDescription").value;

                if("<%=escapeCoteValue(folderPrefixPath)%>".length > 0) {
                    product["folderUrl"] = "<%=escapeCoteValue(folderPrefixPath)%>/".replace(/\//g, '~');
                }

                if(document.getElementById("productV1Id") !== null) product["productV1Id"] = document.getElementById("productV1Id").value;
                if(document.getElementById("productV2Id") !== null) product["productV2Id"] = document.getElementById("productV2Id").value;
                $.ajax({
                    url:'commercialProductsAjax.jsp',type: 'POST', dataType: 'json',
                    data: {
                        requestType: "saveProduct",
                        folderId: '<%=escapeCoteValue(folderId+"")%>',
                        catalogId: '<%=escapeCoteValue(rootCatalog+"")%>',
                        productJson: JSON.stringify(product),
                    }
                })  
                .done(function (resp){
                    let msg = "";
                    if(resp.message!== undefined && resp.message.length>0) msg+=".\n"+resp.message;
                    if(resp.errmsg!== undefined && resp.errmsg.length>0) msg+=".\n"+resp.errmsg;

                    if(resp.status===1){
                        if(document.getElementById("productV1Id") !== null && document.getElementById("productV2Id") !== null) 
                            createPagesThroughApi(product,resp.productId,resp.templateId,msg,resp.pageId);
                        else createPagesThroughApi(product,resp.productId,resp.templateId,msg,"");
                    }else {
                        hideLoader();
                        bootNotifyError(msg);
                    }
                });
            }
        }
        else if(nextTreatment == "upload") {
            $('#modal-new-product').modal('hide')
            $('#modal-new-product-upload').modal('show');
        }
        else if(nextTreatment == "icecat") {
            $('#modal-new-product').modal('hide')
            $('#modal-new-product-icecat').modal('show');
        }
    }

    function validateInputs(){
        var inputs = document.querySelectorAll('.validate');
        inputs.forEach(function(input) {
            if (input.value.trim() === '') {
                input.classList.add('is-invalid');
            }else {
                input.classList.remove('is-invalid');
            }
        });

        return document.querySelectorAll('.is-invalid').length>0?false:true;
    }

    function gotToPageEditorScreen(productId){
        $.ajax({
            url:'commercialProductsAjax.jsp',
            data: {
                requestType: "getPageForProduct",
                productId:productId,
            }
        })  
        .done(function (resp){
            if(resp.status===1) location.href = '<%=com.etn.beans.app.GlobalParm.getParm("PAGES_APP_URL")%>admin/structuredPageEditor.jsp?id='+resp.pageId+'&folderId='+'<%=escapeCoteValue(pagesFolderForProducts+"")%>';
        });
    }

    function emptyProductModal(){
        var modal = document.getElementById('addProductTypeModal');
        if(document.getElementById('productV1Id')) document.getElementById('productV1Id').remove();
        
        if(document.getElementById('productV2Id')) document.getElementById('productV2Id').remove();

        modal.querySelectorAll('input').forEach(function(input) {
            input.value = '';
        });
        var form = modal.querySelector('form');
        if (form) form.reset();

        if(document.getElementById('productId')!==null) document.getElementById('productId').remove();

        document.getElementById('manualCreation').style.display = 'none';
        document.getElementById('uploadCreation').style.display = 'none';
        document.getElementById('icecatCreation').style.display = 'none';
    }
</script>