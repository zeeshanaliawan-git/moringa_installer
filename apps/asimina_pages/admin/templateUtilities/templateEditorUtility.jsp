<script type="text/javascript">
    function splitDates(ele) {
        let startDate = ele.querySelector("[name=date_value_start]");
        let endDate = ele.querySelector("[name=date_value_end]");
        if(startDate != null) {
            let tmp = startDate.value.split("to");
            if(tmp.length > 1) {
                startDate.value = tmp[0].trim();
                endDate.value = tmp[1].trim();
            }
        }
    }

    function queryselect(ele){
        if ($(ele).is(":checked")) {
            $(ele).parent().parent().find("#fieldValueDiv").find(".selectValueList").hide();
            $(ele).parent().parent().find("#fieldValueDiv").append($("#query-select").html());
        } else{
            $(ele).parent().parent().find("#fieldValueDiv").find(".query-select").remove();
            $(ele).parent().parent().find("#fieldValueDiv").find(".selectValueList").show();
        }
    }

    function queryselectfield(ele) {
        var querySelector = $(ele).closest(".query-select");
        var queryOption = $(ele).val();
        if(queryOption == "free"){
            querySelector.find("#value-label-select").hide();
            querySelector.find(".freeQuery").show();
        }else {
            querySelector.find(".freeQuery").hide();
            var valueLabelSelect = querySelector.find("#value-label-select");
            valueLabelSelect.find("[name=select-field-for-value]").children().not(":first").remove();
            valueLabelSelect.find("[name=select-field-for-label]").children().not(":first").remove();
            var columns;

            if(queryOption == "catalogs")  columns = $ch.catalogsCol;
            else if(queryOption == "page") columns = $ch.contentCol;
            else if(queryOption == "content") columns = $ch.contentCol;
            else if(queryOption == "blocs") columns = $ch.pagesCol;
            else if(queryOption == "freemarker_pages") columns = $ch.blocsCol;

            $.each(columns,function(idx,val) {
                var option = $("<option>").attr("value",val).text(val);
                valueLabelSelect.find("[name=select-field-for-value]").append(option.clone(true));
                valueLabelSelect.find("[name=select-field-for-label]").append(option.clone(true));
            });
            valueLabelSelect.show();
        }
    }

    function onClickGoBack(url) {
        checkPageChanged();
        goBack(url);
    }

    function checkPageChanged() {
        if ($ch.savedData != JSON.stringify(getDataForSave())) $ch.pageChanged = true;
        else $ch.pageChanged = false;
    }

    function openTemplateResources(id) {
        checkPageChanged();
        if ($ch.pageChanged) {
            bootConfirm("Unsaved changes will be lost. Are you sure?", function(result) {
                if (result) window.location.href = "templateResources.jsp?id=" + id;
            });
        } else window.location.href = "templateResources.jsp?id=" + id;
    }

    function getAceEditorValue(ele){
        if (ele.length > 0) {
            var aceEditor = ace.edit(ele[0]);
            return aceEditor.getSession().getValue();
        }
        return "";
    }

    function setAceEditorValue(ele,value,isCss){
        if (ele.length > 0) {
            var aceEditor = ace.edit(ele[0],(isCss)? cssOpts:javascriptOpts);
            aceEditor.getSession().setValue(value);
            aceEditor.setFontSize(15);
            ele[0].style.minHeight="100px";
        }
    }

    function appendAceEditor(form){
        form.find(".js-editor:last").after($("#custom-js-editor").html());
        setAceEditorValue(form.find(".js-editor:last").find(".ace-editor-js"),"");
        if(form.find(".js-editor").length>1) form.find(".js-editor-remove").show();
    }

    function removeJSEditor(form){
        if(form.find(".js-editor").length>1) form.find(".js-editor:last").remove();
        if(form.find(".js-editor").length<=1) form.find(".js-editor-remove").hide();
    }

    function onChangeNbItems(select) {
        var tagInputField =  $(select.closest("form").querySelector('.tagInputField'));
        nb_items = $(select.closest("form").querySelector('[name=nb_items]'));

        if (select.value == '0') {
            nb_items.prop('readonly', false).val(0).prop('readonly', true);
        } else {
            nb_items.prop('readonly', false).val(1);
            var tagsDiv = getTagsDivGeneric(tagInputField);
            var tagsNode  = tagsDiv.find(".tagButton");
            if(tagsNode.length>1){
                var firstTagNode = tagsNode[0];
                tagsDiv.html("");
                tagsDiv.append(firstTagNode);
            }
        }
        tagInputField.data("data-nb-items",select.value);
    }

    function onKeyPressNBItems(nbItemInput){
        allowNumberOnly(nbItemInput);
        
        var tagInputField =  $(nbItemInput.closest("form").querySelector('.tagInputField'));
        if(nbItemInput.value != "" && tagInputField.length > 0){
            tagInputField =  $(tagInputField);
            tagInputField.data("data-nb-items",nbItemInput.value);
            if(nbItemInput.value !=0){ // unlimited case
                var tagsDiv = getTagsDivGeneric(tagInputField);
                var tagsNode  = tagsDiv.find(".tagButton");
                if(tagsNode.length > nbItemInput.value){
                    for(var i=0; i<(tagsNode.length-nbItemInput.value); i++){
                        tagsDiv.children('.tagButton').eq(tagsNode.length-(i+1)).remove();
                    }
                }
            }
        }
    }

    function isDuplicateCustomId(customId, list, dataKey, dataValue) {
        var isDuplicate = false;
        var items = $(list).find('> li');

        items.each(function(index, li) {
            li = $(li);
            if (li.data('custom_id') == customId && li.data(dataKey) != dataValue) {
                isDuplicate = true;
            }
        });
        return isDuplicate;
    }

    function addSelectValue(btn, valueItem) {
        btn = $(btn);
        var addListItem = btn.parents('li.add:first');
        var listItem = $('#selectFieldValueTemplate > li:first').clone(true);
        addListItem.before(listItem);

        if (valueItem) {
            if(valueItem[0]==="one_shot") listItem.find('[name=option_value]').prop('readonly', true);
            listItem.find('[name=option_value]').val(valueItem[0]);
            listItem.find('[name=option_label]').val(valueItem[1]);
        }
    }

    function deleteElementGeneric(ele, parentSelector, doConfirm) {
        if (doConfirm) {
            if (!confirm("are you sure?")) return false;
        }
        $(ele).parents(parentSelector).remove();
    }

    function onNameChange(name) {
        name = $(name);
        var form = name.parents('form:first');
        customId = form.find('[name=custom_id]');

        if (name.val().trim().length > 0 && customId.length > 0 && customId.prop('readonly') == false) {
            customId.val(name.val().trim()).trigger('keyup');
        }
    }

    function debounce(func, delay) {
        let debounceTimer;
        return function() {
            const context = this;
            const args = arguments;
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => func.apply(context, args), delay);
        };
    }

    async function onKeyUpExistingFieldSearch(input) {
        var val = $(input).val();
        try{
            var listItems = $('#existingFieldsList > li');

            if (val.trim().length==0){ 
                listItems.show();
                await loadExistingFieldData("",true);
                $("#loader").hide();

            } else if(val.trim().length>2){
                await loadExistingFieldData(val,true);
                $("#loader").hide();

                listItems = $('#existingFieldsList > li');
                val = val.trim().toLowerCase();
                $.each(listItems, function(index, li) {
                    li = $(li);
                    if (li.find('.name').text().toLowerCase().indexOf(val) >= 0
                        || li.find('.custom_id').text().toLowerCase().indexOf(val) >= 0
                        || li.find('.field_type').text().toLowerCase().indexOf(val) >= 0) {
                        li.show();
                    } else li.hide();
                });
            }
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    function onChangeDateTypeFormat() {
        var form = $('#formAddEditField');

        var dateType = form.find('[name=date_type]').val();
        var dateFormat = form.find('[name=date_format]').val();
        
        if (dateType == 'period' && dateFormat == 'time') form.find('.dateEndDateDiv').show();
        else form.find('.dateEndDateDiv').hide();

        let langIds = form.find('[name=langueIds]');
        for(let i=0;i<langIds.length;i++) {
            let _htmlDiv = $("#fieldDefValueDiv_"+$(langIds[i]).val());
            var dateInputStart = _htmlDiv.find('[name=date_value_start]');
            var dateInputEnd = _htmlDiv.find('[name=date_value_end]');

            initDatetimeFields(dateInputStart, dateInputEnd, dateType, dateFormat);	

            if (dateType == 'period' && dateFormat != 'time') {
                if(dateInputStart.val().length > 0){
                    if(!dateInputStart.val().includes(" to ")) dateInputStart.val(`\${dateInputStart.val()} to \${dateInputEnd.val()}`);
                }
                dateInputEnd.val("");
            }
        }
    }

    function initUrlFieldInput(input) {
        if (!etn || !etn.initUrlGenerator) {
            return false;
        }
        var urlGenOpts = {
            showOpenType: true,
            allowEmptyValue: true
        };
        var gen = etn.initUrlGenerator(input, window.URL_GEN_AJAX_URL, urlGenOpts);
        $(input).data('url-generator', gen);
    }

    function loadStructuredCatalogTypes(catalogSelect, catalogValue, fieldType){
        var templateType = '';
        if( fieldType === "view_structured_contents") templateType = "structured_content";
        else if( fieldType === "view_structured_pages") templateType = "structured_page";

        // showLoader();
        $.ajax({
            url: 'blocTemplatesAjax.jsp',
            type: 'POST',
            dataType: 'json',
            data: {
                requestType: 'getTemplatesByType',
                type : templateType
            },
        })
        .done(function(resp) {
            if (resp.status == 1) {
                var options = "";
                resp.data.templates.forEach(function(item){
                    options += '<option value="'+item.custom_id+'">'+ item.name + ' ('+item.custom_id +')'+'</option>';
                });

                catalogSelect.append(options);
                if(catalogValue.length > 0 && catalogSelect.find('option[value='+catalogValue+']').length > 0){
                    catalogSelect.val(catalogValue);
                }
            } else alert(resp.message);
        })
        .fail(function() {
            alert("Error in accessing server.");
        })
        .always(function() {
            // hideLoader();
        });
    }

    function initTagsFolderSelect(){
        let tagsDiv = document.getElementById("tagsList");
        let totalChild = tagsDiv.children.length;
        let selectElement;

        var originalSelect = document.getElementById('tags_folder_list_0');
        selectElement = originalSelect.cloneNode(true);
        selectElement.id = 'tags_folder_list_'+totalChild;
        selectElement.classList.add("mt-3");
        selectElement.options[0].selected=true;
        tagsDiv.appendChild(selectElement);
        handleEventListnerOnSelect(selectElement,totalChild);
    }

    function handleEventListnerOnSelect(select,totalChild){
        select.addEventListener('change', function() {
            if(document.getElementById("tags_folder_list_"+(totalChild+1))==null && select.value.length>0){
                initTagsFolderSelect();
            }
            selectedFolders[totalChild]=select.value;
            reloadTags();
        });
    }

    function resetSelectFields(){
        let selectFields = document.getElementById("tagsList").children;
        while(selectFields.length>1){
            selectFields[1].remove();
        }

        for(let i =0;i<$(".tagInputField").length;i++){
            removeAllTagsGeneric($(".tagInputField")[i]);
        }
    }

    function reloadTags(){
        let inputElements = $(".tagInputField");
        for(let i =0;i<inputElements.length;i++){
            $(inputElements[i]).data("folders-id",selectedFolders.join(","));
            initTagAutocomplete(inputElements[i]);
        }
    }

    function isJsonObjectEmpty(obj) {
        return Object.keys(obj).length === 0 && obj.constructor === Object;
    }

    function getFieldSpecificDataJson(fieldSpecificData){
        let field_specific_data;
        try{
            field_specific_data = JSON.parse(fieldSpecificData);
        }catch(ex){
            field_specific_data = {};
        }
        return field_specific_data;
    }

    function getDataFromJson(json,defaultData,key){
        if(!isJsonObjectEmpty(json) && key in json) return json[key];
        else return defaultData;
    }

    function duplicateElement(form,elementName, count) {
        let originalElement = form.find('[name="' + elementName + '"]').first();
        if (originalElement.length > 0) {
            for (let i = 0; i < count; i++) {
                let clonedElement = originalElement.clone();
                originalElement.parent().append(clonedElement);
            }
        }
    }

    function checkSelectForDuplicate(element, eleName) {

        element = $(element);
        let nextSibling = element.next('[name="' + eleName + '"]');
        let selectElements = element.parent().find("[name='"+eleName+"']").not("[value=''],[value='all']");
        element.removeClass("is-invalid");
        let cardBody = element.closest(".card-body");        
        
        if(element.val()!=="all"){
            if (selectElements.length > 0)
            {
                let arr = [];
                selectElements.each(function(idx,el){
                    if(arr.includes($(el).val()) && $(el).val() !== ""){
                        bootNotifyError($(el).find("option[value='" + $(el).val() +"']").text()+" Already selected");
                        $(el).addClass("is-invalid");
                        return;
                    }
                    arr.push($(el).val());
                });

                if(element.hasClass("is-invalid")) return;
            }
            if (nextSibling.length <= 0 && element.val().length > 0) element.after(element.clone());

            cardBody.find(".default_value_templates option:not([value=''], [value='all'])").remove();

            if(cardBody.find('.default_value_templates').find("option[value='" + element.val() +"']").length == 0 ){
                selectElements.each(function(idx, el){
                    if($(el).val() == "") return;
                    cardBody.find('.default_value_templates').append($(el).find("option[value='" + $(el).val() +"']").clone());
                });
            }
            
        } else { 
            cardBody.find(".default_value_templates option:not([value=''], [value='all'])").remove();
            element.siblings('select[name="' + eleName + '"]').remove();

            element.find("option:not([value=''], [value='all'])").each(function(idx,ele){
                cardBody.find('.default_value_templates').append($(ele).clone());
            });
        }

        let arr=[];
        cardBody.find("[name='field_specific_selected_templates']:not([value=''], [value='all'])").each(function(idx,el){
            arr.push($(el).val());
        }); 

        getBlocsLists(arr).then(blocs => {
            populateListToAutocomplete(cardBody.find("input.asm-autocomplete-field"),blocs);
            cardBody.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
            cardBody.find("input.asm-autocomplete-field").val("");
        }).catch(error => {
            console.error(error);
        }); 
        
    }

    function populateListToAutocomplete(ele,list) {
        $(ele).data("autocomplete-list",list);
    }

    function loadAutoComplete(ele){ 
        autocompleteGeneric(ele);
    }
</script>