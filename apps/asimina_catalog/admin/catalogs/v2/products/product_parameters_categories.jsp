<!-- Add Category Modal -->
        <div class="modal fade" id="addCategoryModal" tabindex="-1" aria-labelledby="addCategoryModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-slideout modal-md" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title" id="addCategoryModalLabel">Add a category</h2>
                        <button type="button" class="close" onclick="emptyCategoryModal()" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="card mb-2">
                            <div class="card-header bg-secondary" data-toggle="collapse" href="#globalInfoCategoryCollapse" role="button" aria-expanded="true" aria-controls="globalInfoCategoryCollapse">
                                <strong>Category</strong>
                            </div>
                            <div class="collapse show pt-3" id="globalInfoCategoryCollapse">
                                <div class="card-body">
                                    <div class="form-group row">
                                        <label class="col-sm-3 col-form-label">Name</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control validateCategory" name="categoryName" value="" maxlength="100" required="required">
                                            <div class="invalid-feedback">
                                                Category name cannot be empty.
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div><!--  collapse -->
                        </div>
                    </div>
                    <div class="modal-footer" id="saveCategories">
                        <button type="button" class="btn btn-secondary" onclick="emptyCategoryModal()">Close</button>
                        <button type="button" class="btn btn-primary" onclick="saveCategory('0')">Save</button>
                    </div>
                </div>
            </div>
        </div>

<script type="text/javascript">

    function openCategoryModal(parentId,level,name,id){
        emptyCategoryModal();
        let parentDiv = document.getElementById('globalInfoCategoryCollapse');
        let cardBodyDiv = parentDiv.querySelector('.card-body');

        if(name.length>0) cardBodyDiv.querySelector('input[name="categoryName"]').value=name;
        if(id.length>0) appendInput(cardBodyDiv,id,"categoryId");
        
        appendInput(cardBodyDiv,parentId,"parentCategoryId");
        appendInput(cardBodyDiv,level,"categoryLevel");
        $('#addCategoryModal').modal('show');
    }

    function appendInput(cardBodyDiv, val, id){
        let newInput = document.createElement('input');
        newInput.type = 'text';
        newInput.hidden = true;
        newInput.className = 'form-control';
        newInput.name = id;
        newInput.value = val;
        
        cardBodyDiv.appendChild(newInput);
    }

    function emptyCategoryModal(){
        const parentDiv = document.getElementById('globalInfoCategoryCollapse');
        const cardBodyDiv = parentDiv.querySelector('.card-body');
        
        cardBodyDiv.querySelector('input[name="categoryName"]').value="";

        const hiddenInputs = cardBodyDiv.querySelectorAll('input[hidden]');
        hiddenInputs.forEach(input => {
            input.parentNode.removeChild(input);
        });

        $('#addCategoryModal').modal('hide');
    }

    function drawCategoriesHtml(){
        $.ajax({
            url: 'product_parameters_ajax.jsp',
            type: 'GET',
            dataType: 'json',
            data: {
                requestType: 'getCategories',
            },
        })
        .done(function(resp) {
            if (resp.status == 1) {

                let categories = resp.data.categories;
                for(let i=0;i<categories.length;i++){
                    const categoriesTable = document.getElementById(`categoriesTable`);
                    categoriesTable.innerHTML += returnCategoryHtml(categories[i],"","");
                }
            }
            else {
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in accessing server.");
        });
    }

    function deleteCategory(categoryId){
        bootConfirm("Category and its subcategories will be deleted. Are you sure you want to delete?", function(result) {
            if (result){
                $.ajax({
                    url: 'product_parameters_ajax.jsp',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        requestType: 'deleteCategories',
                        categoryId:categoryId,
                    },
                })
                .done(function(resp) {
                    if (resp.status == 1) {
                        reloadCategoryTable();
                    }
                    else {
                        bootNotifyError(resp.message);
                    }
                })
                .fail(function() {
                    bootNotifyError("Error in accessing server.");
                });
            }
        });
    }

    function returnCategoryHtml(catJson,parentClass,indentSpan){
        let html="";
        html += `<tr class="treegrid-${catJson.id} treegrid-collapsed ${(parentClass.length>0)? parentClass+" treegrid-expanded": ''}" id="category_${catJson.id}" ${(parentClass.length>0)? 'style="display: none;"': ''}>`;
        
        if(catJson.sub_categories != undefined && catJson.sub_categories.length > 0){
            html+=`<td>${indentSpan}<span class="treegrid-expander treegrid-expander-collapsed" onclick="expandGrid(this)"></span>${catJson.name}</td>`;
        }else{
            html+=`<td>${indentSpan+catJson.name}</td>`;
        }

        let nextLevel = parseInt(catJson.level) +1;

        html+=`<td class="text-right">
                <button type="button" class="btn btn-sm btn-primary" onclick="openCategoryModal('${catJson.parent_id}','${catJson.level}','${catJson.name}','${catJson.id}')"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-edit"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
                <button type="button" class="btn btn-sm btn-primary" onclick="openCategoryModal('${catJson.id}','${nextLevel}','','')"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-plus"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg></button>
                <button type="button" class="btn btn-sm btn-danger" onclick="deleteCategory('${catJson.id}')"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-trash-2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></button>
            </td>
        </tr>`;
        if(catJson.sub_categories != undefined && catJson.sub_categories.length > 0){
            indentSpan += `<span class="treegrid-indent"></span>`;
            for(let i=0;i<catJson.sub_categories.length;i++){
                html+=returnCategoryHtml(catJson.sub_categories[i],`treegrid-parent-${catJson.id}`,indentSpan);
            }
        }
        return html;
    }

    function hideAllExpanded(cls,level){
        let finalCls = cls.split("-")[0]+"-parent-"+cls.split("-")[1];

        $("."+finalCls).each(function (i,e){
            if($(e).is(":visible")){
                $(e).closest("tr").removeClass("treegrid-expanded");

                $(e).find("span.treegrid-expander").removeClass("treegrid-expander-expanded");
                $(e).find("span.treegrid-expander").addClass("treegrid-expander-collapsed");
                $(e).hide();
                hideAllExpanded($(e).attr('class').split(" ")[0],level+1);
            }
            else{
                if(level===0){
                    $(e).closest("tr").addClass("treegrid-expanded");
                    $(e).show();
                }
            }
        });
    }

    function expandGrid(ele){
        if($(ele).hasClass("treegrid-expander-collapsed")) {
            $(ele).removeClass("treegrid-expander-collapsed");
            $(ele).addClass("treegrid-expander-expanded");
        }else if($(ele).hasClass("treegrid-expander-expanded")){
            $(ele).addClass("treegrid-expander-collapsed");
            $(ele).removeClass("treegrid-expander-expanded");
        }
        hideAllExpanded($(ele).closest("tr").attr('class').split(" ")[0],0);
    }

    function getCategoryJson(){
        var parentDiv = document.getElementById("globalInfoCategoryCollapse");
        let saveJson={};
        saveJson["categoryName"] = parentDiv.querySelector('input[name="categoryName"]').value;
        saveJson["parentCategoryId"] = parentDiv.querySelector('input[name="parentCategoryId"]').value;
        
        if(parentDiv.querySelector('input[name="categoryId"]')!=null){
            saveJson["categoryId"] = parentDiv.querySelector('input[name="categoryId"]').value;
            saveJson["saveType"] = "update";
        }else{
            saveJson["saveType"] = "create";
        }
        
        saveJson["categoryLevel"] = parentDiv.querySelector('input[name="categoryLevel"]').value;
        return saveJson;
    }

    function saveCategory(){
        if(validateInputs("validateCategory")){
            let catgJson = getCategoryJson();
            $.ajax({
                url: 'product_parameters_ajax.jsp',
                type: 'POST',
                dataType: 'json',
                data: {
                    requestType: 'saveCategory',
                    category:JSON.stringify(catgJson),
                },
            })
            .done(function(resp) {
                if (resp.status == 1) {
                    if(catgJson.saveType=="create"){
                        const input = document.getElementById("addCategoryModal").querySelector(`input[name="categoryName"]`);
                        if (input) {
                            input.value = '';
                        }
                    }
                    reloadCategoryTable();
                }
                else {
                    bootNotifyError(resp.message);
                }
            })
            .fail(function() {
                bootNotifyError("Error in accessing server.");
            });
        }
    }

    function reloadCategoryTable(){
        document.getElementById("categoriesTable").innerHTML = "";
        drawCategoriesHtml();
    }

</script>