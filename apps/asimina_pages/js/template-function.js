
    // ready function
    $(function () {

        $ch.TEMPLATE_SECTION = $('#template_section').html();
        $ch.TEMPLATE_ADD_SECTION = $('#template_add_section').html();
        $ch.TEMPLATE_ADD_FIELD = $('#template_add_field').html();

        loadProductFoldersList($('select.productFoldersSelect'), $('select.productFoldersCatalogSelect') );
        loadFoldersList($('select.pagesFolderSelect'), folderTypePages);
        loadFoldersList($('select.contentFolderSelect'), folderTypeContents);

        $(document).on('click',".remove-bloc",function(){
            let inputGroup = $(this).closest(".input-group");
            inputGroup.find("select").val("").trigger("change");
            inputGroup.find("input").val("");
            inputGroup.find("input.bloc-name").trigger("input");
        });
        
        $(document).on('click',".add-bloc",function(){
            $("#modalAddEditBloc").find(".savePlaceBtn").hide();
            $ch.blocField = $(this).closest(".input-group");    
            $ch.blocField.find("ul.autocomplete-items").remove();
            openAddEditBloc(this,$(this).closest(".input-group").find(".bloc-name").val());
        });

        $(document).on('click',".edit-bloc",function(){
            $("#modalAddEditBloc").find(".savePlaceBtn").hide();
            $ch.blocField = $(this).closest(".input-group");    
            $ch.blocField.find("ul.autocomplete-items").remove();
            openAddEditBloc(this);
        });
    });

    function generateSectionContainer(secCode, parentContainer, langId,attributes,specification) {
        var sectionId = 'section_' + secCode.custom_id;

        if (parentContainer.hasClass('bloc_section')) {
            //its a nested section
            var parentId = parentContainer.attr('id');
            sectionId = parentId + "." + sectionId;
        }

        var sectionDiv = $('<div>');
        sectionDiv.addClass(sectionId);
        sectionDiv.addClass("card mb-2");
        sectionDiv.attr('id', sectionId);
        sectionDiv.data('section-data', secCode);
        sectionDiv.data('lang-id', langId);
        sectionDiv.addClass('sectionDiv');
        sectionDiv.addClass('mb-2');

        if(secCode.display!=undefined && secCode.display==="0"){
            sectionDiv.addClass('d-none');
        }

        parentContainer.append(sectionDiv);

        var isUnlimited = (secCode.nb_items != 1);

        var loopCount = secCode.nb_items;
        if (isUnlimited) {
            loopCount = 0;
        }

        var sectionLastId = 0;
        for (var secIndex = 0; secIndex < loopCount; secIndex++) {
            var curSecId = sectionId + '_' + (secIndex + 1);
            var showDelete = false;
            if (isUnlimited && secIndex >= 0) {
                showDelete = true;
            }
            generateSection(sectionDiv, curSecId, secCode, showDelete, langId,attributes,specification);
            sectionLastId = (secIndex + 1);
        }

        sectionDiv.attr('section-last-id', sectionLastId);
        if (isUnlimited) {
            //add button
            var btnHtml = strReplaceAll($ch.TEMPLATE_ADD_SECTION, '#SECTION_ID#', sectionId);
            btnHtml = strReplaceAll(btnHtml, '#SECTION_NAME#', secCode.name);

            if(attributes) btnHtml = strReplaceAll(btnHtml, '#ATTRIBUTES#', btoa(JSON.stringify(attributes)));
            if(specification) btnHtml = strReplaceAll(btnHtml, '#SPECIFICATION#', btoa(JSON.stringify(specification)));
            
            sectionDiv.append(btnHtml);
            setDuplicableSectionOrder(sectionDiv);
        } else {
            sectionDiv.find('.duplicableOnly').remove();
        }
        $("select[name='product_specifications.product_specifications_x_spec_select']").hide();

        
        return sectionDiv;
    }

    function updateAutocompleteList(input,filteredWords) {
        var autocompleteList = input.nextElementSibling;
        autocompleteList.innerHTML = '';
        if (filteredWords.length === 0) {
            autocompleteList.style.display = 'none';
            return;
        }

        filteredWords.forEach(word => {
            const listItem = document.createElement('li');
            listItem.style.cursor = 'pointer';
            listItem.style.borderBottom = '1px solid #ddd';
            listItem.textContent = word;
            listItem.addEventListener('mousedown', function () {
                input.value = word;
                autocompleteList.style.display = 'none';
            });
            autocompleteList.appendChild(listItem);
        });

        autocompleteList.style.display = 'block';
        autocompleteList.style.zIndex = '9999';
        autocompleteList.style.backgroundColor = '#fff';
    }

    function addEventToSection(secHtml) {
        $(secHtml).find(".selectDiv").on("input",".autocomplete_input",function(){
            let value = $(this).val();
            let selectDiv = $(this).closest('.selectDiv');
            let autocompleteList = selectDiv.find(".autocomplete-items");
            if(value.length>1){
                autocompleteList.show();
                autocompleteList.find("li").each(function(idx,element){
                    if(element.textContent.toLowerCase().includes(value.toLowerCase())) $(element).show();
                    else $(element).hide();
                });
            }else{
                autocompleteList.hide();
            }
        });

        $(secHtml).find(".selectDiv").on('mousedown','.autocomplete-item',function(){
            $(this).closest('.selectDiv').find('.autocomplete_input').val($(this).text());
            $(this).closest('.selectDiv').find('select').val($(this).attr('value'));
        });

        $(secHtml).find(".selectDiv").on('blur','.autocomplete_input',function(){
            $(this).closest('.selectDiv').find(".autocomplete-items").hide();
        });
        
        $(secHtml).find('.uniqueId').on('blur',function(){
            let ele = $(this);
            if($(ele).prop("readonly")) return;
            
            let templateId = $('[name="template_id"]').val();
            let blocId = $('#addEditBlocForm').find('input[name="blocId"]').val();

            if(blocId === undefined || blocId === null || blocId.length === 0){
                blocId="";
            }

            if(ele.val().length>0){
                ele.val().replace("$",'');

                var uniqueIds = [];
                $('.langTemplateForm > div:first').find(".uniqueId").each(function (index, el) {
                    var uniqueId = $(el).val().trim();
                    if (uniqueId.length > 0 && uniqueIds.indexOf(uniqueId) < 0) {
                        uniqueIds.push(uniqueId);
                    }
                });

                $.ajax({
                    url: 'blocsAjax.jsp',
                    dataType: 'json',
                    data: {
                        requestType : "checkUniqueId",
                        id : uniqueIds.join('$'),
                        templateId: templateId,
                        blocId : blocId,
                        pageType : "blocs",
                    },
                })
                .done(function(resp) {
                    let value = "";
                    let className = "";
                    if(resp.status == '0'){
                        value = "";
                        bootNotifyError("Id is not unique.");
                    }else{
                        value = ele.val();
                    }
                    let langId = ele.closest(".langContent").data("langId");
                    $ch.langContentDivs.each(function(idx,langContentDiv){
                        if(langId == $(langContentDiv).data("langId")) return;
                        let sectionId = ele.closest(".bloc_section").attr("id").replace("blocLangContent_"+langId,"blocLangContent_"+$(langContentDiv).data("langId"));
                        try {
                            let section = $(langContentDiv).find("[id='"+sectionId+"']");
                            let element = section.find("[name='"+ele.attr("name")+"']");
                            element.val(value);
                            section.find('[type=text],select').first().trigger('change');
                            if(className.length>0) element.addClass("is-invalid");    
                            else element.removeClass("is-invalid");    
                        } catch (error) {
                            return;
                        }
                    });
                });

            }else {
                let langId = ele.closest(".langContent").data("langId");
                $ch.langContentDivs.each(function(idx,langContentDiv){
                    let sectionId = ele.closest(".bloc_section").attr("id").replace("blocLangContent_"+langId,"blocLangContent_"+$(langContentDiv).data("langId"));
                    try {
                        let element = $(langContentDiv).find("[id='"+sectionId+"']").find("[name='"+ele.attr("name")+"']");
                        element.val(ele.val());
                    } catch (error) {
                        return;
                    }
                });
            }
        });
    }

    function setUniqueId(secHtml,langContentDivs) {
        let langId = secHtml.closest(".langContent").data("langId");
        langContentDivs.each(function(idx,langContentDiv){
            
            if(langId == $(langContentDiv).data("langId")) return;
            
            let sectionId = secHtml.attr("id").replace("blocLangContent_"+langId,"blocLangContent_"+$(langContentDiv).data("langId"));
            try {
                let section = $(langContentDiv).find("[id='"+sectionId+"']");
                section.find(".uniqueId").each(function(idx,field){
                    if($(field).val().length>1)
                        secHtml.find("[name='"+$(field).attr("name")+"']").val($(field).val());
                });
                section.find('[type=text],select').first().trigger('change');
            } catch (error) {
                return;
            }
        });
    }

    function getSectionCleanName(section) {
        let sectionList = section.split(".");
        let returnSection = "";
        for(let i=1;i<sectionList.length;i++) {
            if(returnSection.length>0){
                returnSection+=".";
            }
            returnSection += sectionList[i].substring(sectionList[i].indexOf('_') + 1, sectionList[i].length);
        }
        return returnSection;
    }

    function generateSection(container, sectionId, secCode, showDelete, langId,attributes,specification) {
        var secHtml = strReplaceAll($ch.TEMPLATE_SECTION,
                "#SECTION_ID#", sectionId);
        secHtml = strReplaceAll(secHtml, "#SECTION_NAME#", secCode.name);
        
        if(secCode.description !== undefined && secCode.description.length >0)
            secHtml = strReplaceAll(secHtml, "#SECTION_DESCRIPTION#", "<a href='javascript:void(0)' class='custom-tooltip' data-toggle='tooltip' title='"+secCode.description+"'><svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-info'><circle cx='12' cy='12' r='10'/><line x1='12' y1='16' x2='12' y2='12'/><line x1='12' y1='8' x2='12.01' y2='8'/></svg></a>");
        else
            secHtml = strReplaceAll(secHtml, "#SECTION_DESCRIPTION#","");

        secHtml = strReplaceAll(secHtml, "#SHOW_DELETE#", showDelete ? 'true' : '');
        
        if(secCode.is_collapse != undefined && secCode.is_collapse==="0"){
            secHtml = strReplaceAll(secHtml, "#IS_COLLAPSE#", "show");
        }else{
            secHtml = strReplaceAll(secHtml, "#IS_COLLAPSE#", "");
        }
        
        var isDuplicableSection = (secCode.nb_items != 1);
        var sectionColor = isDuplicableSection ? "success" : "secondary";
        secHtml = strReplaceAll(secHtml, "#COLOR#", sectionColor);
        
        if(bulkModificationScreen && isDuplicableSection){
            let sectionIdForCheck = getSectionCleanName(sectionId);
            
            let appendHtml = '<select class="form-select" data-value="'+sectionIdForCheck+'" name="append_to_section_'+langId+'">'+
                '<option value="true">Append</option>'+
                '<option value="false" selected>Not Append</option>'+
            '</select>';
            secHtml = strReplaceAll(secHtml, "#BULK_MODIFY_CHECK#",appendHtml);
        }else{
            secHtml = strReplaceAll(secHtml, "#BULK_MODIFY_CHECK#",'');
        }

        secHtml = $(secHtml);

        var addSectionDiv = container.find('>.add_section');
        if (addSectionDiv.length == 0) {
            container.append(secHtml);
        }
        else {
            addSectionDiv.before(secHtml);
        }


        var sectionEle = $('#' + escapeDot(sectionId));
        if (sectionEle.length > 0) {
            sectionEle.data('custom_id', secCode.custom_id);
            generateFields(sectionEle, secCode.fields, langId,attributes,specification);
        }

        if (isDuplicableSection) {
            //for duplicable section, set section title from field value
            var sectionTitleField = sectionEle.find('[type=text],select').first();
            setUniqueId(secHtml.last(),$ch.langContentDivs);
            addEventToSection(sectionEle);
            if (sectionTitleField.length > 0) {
                sectionTitleField.change(function(event) {
                    var field = $(this);
                    try {
                        var fieldSectionDiv = field.parents(".bloc_section:first");
                        var sectionId = fieldSectionDiv.attr('id');

                        var sectionBtnDiv = $('#section_btn_' + escapeDot(sectionId));
                        if (sectionBtnDiv.length > 0) {
                            var sectionTitle = field.val().trim();
                            if (sectionTitle.length > 0) {
                                sectionTitle = ": " + sectionTitle;
                            }
                            sectionBtnDiv.find('.section_title').text(sectionTitle);
                        }
                    }
                    catch (ex) {

                    }
                });

                sectionTitleField.trigger('change');
            }
        }

        $.each(secCode.sections, function(nestedIndex, nestedSecCode) {
            var nestedSectionDiv = generateSectionContainer(nestedSecCode, sectionEle, langId,attributes,specification);
        });
        setTimeout(addSectionJsAndCss(secCode,sectionId,sectionEle),2000);
    }

    function generateFields(sectionEle, fields, langId,attributes,specification) {
        var sectionIdPrefix = sectionEle.data('custom_id') + '.';
        for (var i = 0; i < fields.length; i++) {
            var fieldData = fields[i];
            var fieldId = sectionIdPrefix + fieldData.custom_id;
            
            var fieldContainerDiv = $('<div>');
            fieldContainerDiv.addClass(fieldId);
            fieldContainerDiv.attr('id', fieldId);
            fieldContainerDiv.data('field-data', fieldData);
            fieldContainerDiv.data('lang-id', langId);
            fieldContainerDiv.addClass('fieldContainerDiv');
            fieldContainerDiv.addClass('mb-2');

            if(fieldData.display!=undefined && fieldData.display==="0"){
                fieldContainerDiv.addClass('d-none');
            }

            sectionEle.append(fieldContainerDiv);

            var isUnlimited = (fieldData.nb_items != 1);
            var loopCount = fieldData.nb_items;

            if (isUnlimited) loopCount = 1;

            let newFieldType = false;
            for (var fieldIndex = 0; fieldIndex < loopCount; fieldIndex++) {
                var curFieldId = fieldId;

                var showDelete = false;
                if (isUnlimited && fieldIndex > 0) showDelete = true;

                if(curFieldId == "product_variants_variant_x.product_variants_variant_x_attributes" || curFieldId == "product_general_informations.product_attributes"){
                    newFieldType = true;
                    for(let i=0;i<attributes.length;i++){
                        if(attributes[i]){
                            generateField(fieldContainerDiv, curFieldId, fieldData, false, langId,attributes[i],'attr');
                        }
                    }
                }else if(curFieldId =="product_variants_variant_x_specifications.product_variants_variant_x_specifications_x_spec" || curFieldId =="product_specifications.product_specifications_x_spec"){
                    newFieldType = true;
                    let specs = specification.specs;
                    for(let i=0;i<specs.length;i++){
                        generateField(fieldContainerDiv, curFieldId, fieldData, false, langId,specs[i],'spec');
                    }
                }else{
                    generateField(fieldContainerDiv, curFieldId, fieldData, showDelete, langId);
                }
            }

            if (isUnlimited && fieldData.type != "tag" && fieldData.type !== "image" && !newFieldType) {
                //add button
                var btnHtml = strReplaceAll($ch.TEMPLATE_ADD_FIELD, '#FIELD_ID#', fieldId);
                fieldContainerDiv.append(btnHtml);
            }
        }
    }

    window.ckeditorInitialized = {};

	function getLangData(fieldData, langId) {
		if(fieldData.lang_data)
		{
			for(let i=0;i<fieldData.lang_data.length;i++)
			{
				if(fieldData.lang_data[i].langue_id == langId) return fieldData.lang_data[i];
			}
		}
		else return null;
	}

    let arrTrigger = [];
    let triggerFlag = false;

    function addSectionJsAndCss(secCode,sectionId,sectionEle){
        if(secCode.js_code !== undefined && secCode.js_code.length>0) {
            const scriptElement = document.createElement('script');
            scriptElement.type = 'text/javascript';
            $.each(JSON.parse(secCode.js_code), function(index, val) {
                if(val[0].length == 0 ) return;
                if(val[1].length == 0 ) return;
                if(val[0]!=='ready')
                    scriptElement.textContent += `$(\'div[id=\"`+sectionId+`\"]\').on(\'`+val[0]+`\', function() {`+decodeURIComponent(val[1])+` if(!triggerFlag && \'`+val[0]+`\' == \'change\' && !arrTrigger.some(tmp => tmp.id == \'`+sectionId+`\')) arrTrigger.push({id:\"`+sectionId+`\",on:\"`+val[0]+`\",isSection:true,isSelect:false,langId:$(this).closest(".langContent").data("langId")})}); `;
                else
                    scriptElement.textContent += `$(function(){$(\'div[id=\"`+sectionId+`\"]\').each(function() {`+decodeURIComponent(val[1])+`}); });`;
            });
            document.body.appendChild(scriptElement);
        }

        if (secCode.css_code !== undefined && secCode.css_code.length > 0) {
            sectionEle.attr("style",secCode.css_code.replaceAll(`"`,``).replaceAll(",",";").replaceAll("\n"," "));
        }
    }

    function triggerChange()
    {
        triggerFlag = true;
        
        arrTrigger.forEach(function(item,idx,arr){
            if(item.isSection)
                $(`div[id='\${item.id}']`).trigger('change');
            else{
                if (item.isSelect) {
                    $(`[data-name='\${item.id}']`).each(function () {
                        if ($(this).closest(".langContent").data("langid") == item.langId) {
                            $(this).trigger('change');
                        }
                    });
                } else {
                    $(`[name='\${item.id}']`).each(function () {
                        if ($(this).closest(".langContent").data("langid") == item.langId) {
                            $(this).trigger('change');
                        }
                    });
                };
            }
        });

        triggerFlag = false;
        arrTrigger = [];
    }

    function addJsAndCss(eleType,eleData,eleDiv,fieldId){
        return new Promise((resolve,reject) =>{
            if(eleData.js_code == undefined || eleData.css_code == undefined){ reject(); return;}
            if(eleData.js_code !== undefined && eleData.js_code.length>0) {
                const scriptElement = document.createElement('script');
                scriptElement.type = 'text/javascript';

                $.each(JSON.parse(eleData.js_code), function(index, val) {
                    if(val[0].length==0) return;
                    if(eleData.select_type !== 'select' && eleType === "select"){
                        if(val[0]!=='ready')
                            scriptElement.textContent += `$(\"[data-name=\'`+fieldId+`\']\").on(\'`+val[0]+`\', function() {`+decodeURIComponent(val[1])+` if(!triggerFlag && \'`+val[0]+`\' == \'change\' && !arrTrigger.some(tmp => tmp.id == \'`+fieldId+`\')) arrTrigger.push({id:\"`+fieldId+`\",on:\"`+val[0]+`\",isSection:false, isSelect:true, langId: $(this).closest(".langContent").data("langId")}); }); `;
                        else
                            scriptElement.textContent += `$(function(){$(\"[data-name=\'`+fieldId+`\']\").each(function() {`+decodeURIComponent(val[1])+`});});`;
                    }else{
                        if(val[0]!=='ready')
                            scriptElement.textContent += `
                                $(\'[name=\"`+fieldId+`\"]\').on(\'`+val[0]+`\', function() {`+decodeURIComponent(val[1])+` if(!triggerFlag && \'`+val[0]+`\' == \'change\' && !arrTrigger.some(tmp => tmp.id == \'`+fieldId+`\')) arrTrigger.push({id:\"`+fieldId+`\",on:\"`+val[0]+`\",isSection:false, isSelect:false ,langId: $(this).closest(".langContent").data("langId") }); });
                            `;
                        else
                            scriptElement.textContent += `$(function(){
                                $(\'[name=\"`+fieldId+`\"]\').each(function() {`+decodeURIComponent(val[1])+`});});
                            `;
                    }
                    
                });

                if(scriptElement.textContent.length > 0 ){
                    $(eleDiv).append(scriptElement);   
                }
            }

            if (eleData.css_code !== undefined && eleData.css_code.length>0) {
                let fieldTypeElement = eleDiv.find(`[name="`+fieldId+`"]`);
                if(eleData.select_type !== 'select' && eleType === "select"){
                    fieldTypeElement = eleDiv.find(`.autocomplete_input`);
                }
                fieldTypeElement.attr("style",eleData.css_code.replaceAll(`"`,``).replaceAll(",",";").replaceAll("\n"," "));
                resolve();
            }
        });
    }

    function getUniqueNumber(){
        const now = new Date();
        const year = now.getFullYear();
        const month = (now.getMonth() + 1).toString().padStart(2, '0');
        const day = now.getDate().toString().padStart(2, '0');
        const hours = now.getHours().toString().padStart(2, '0');
        const minutes = now.getMinutes().toString().padStart(2, '0');
        const seconds = now.getSeconds().toString().padStart(2, '0');

        let randomNum = year+month+day+hours+minutes+seconds+(Math.floor(Math.random() * (10000 - 1 + 1)) + 1);
        return randomNum;
    }

    function handleSelectOptions(fieldData, fieldDiv, selectInput, selectOptions) {
        if (fieldData.select_type === "select") {
            fieldDiv.find('.selectDiv').find(".autocomplete_input").hide();
            selectInput.show();
            $.each(JSON.parse(selectOptions), function (index, val) {
                selectInput.append('<option value="' + val[0] + '" >' + val[1] + '</option>');
            });
        } else {
            fieldDiv.find('.selectDiv').find(".autocomplete_input").show();
            selectInput.hide();
            var optionsLines = fieldDiv.find('ul');
            $.each(JSON.parse(selectOptions), function (index, val) {
                selectInput.append('<option value="' + val[0] + '" >' + val[1] + '</option>');
                optionsLines.append('<li class="autocomplete-item" value="' + val[0] + '" >' + val[1] + '</li>');
            });
        }
    }

    function getBlocsLists(tmpIds) {
        return new Promise((resolve, reject) => {
            $.ajax({
                url: 'blocTemplatesAjax.jsp',
                type: 'POST',
                dataType: 'json',
                data: {
                    requestType: 'getTemplatesBlocs',
                    templateIds: tmpIds,
                },
            }).done(function(resp) {
                if (resp.status == 1) {
                    resolve(resp.data.blocs);
                } else {
                    reject("Error: Invalid response status");
                }
            }).fail(function() {
                reject("Error in accessing server.");
            });
        });
    }

    function getBlocsTemplates(selectField,getAll) {
        let tmpIds = [];
        if(getAll)
            $(selectField).find("option").each(function(){
                if(!($(this).val() == "all" || $(this).val().trim() == "")) tmpIds.push($(this).val());
            });
        else tmpIds.push($(selectField).val());
        return tmpIds;
    }

    function waitForElement(selector,callback)
    {
        const interval = setInterval(() => {
            if ($(selector).is(':visible')) {
                clearInterval(interval);
                callback($(selector));
            }
        }, 100);
    }

    function handleBlocButtons(fieldDiv,caller,blocId,templateId,templateName)
    {
        waitForElement(fieldDiv,(e)=>{
        if(caller == "add"){
            fieldDiv.find(".add-bloc")
            .data({
                caller: caller,
                templateId: templateId,
                template: templateName,
                templateType: "bloc"
            })
            .show();
            fieldDiv.find(".edit-bloc").hide();
        }
        else if(caller == "edit"){ 
            fieldDiv.find(".edit-bloc")
            .data({
                caller: caller,
                blocId: blocId,
                templateId: templateId,
                template: templateName
            })
            .show();
            fieldDiv.find(".add-bloc").hide();
            }else {
                fieldDiv.find("button.edit-bloc,button.add-bloc,button.remove-bloc").hide();
        }
        });
        
    }

    function handleBlocField(fieldDiv, fieldId , blocId, blocName,templateId, templates)
    {
        let blocIdField = fieldDiv.find(`input[name='${fieldId}_bloc_id']`);
        let blocNameField = fieldDiv.find(`input[name='${fieldId}_bloc_name']`);
        blocIdField.val(blocId);
        blocNameField.val(blocName);

        const template = $.grep(templates, function(template) {
            return template.id === templateId;
        });
        
        handleBlocButtons(fieldDiv,"edit",blocId,templateId,template[0].label);
    }

    function generateField(container, fieldId, fieldData, showDelete, langId,fieldSpecs,newFieldType) {
        return new Promise((resolve,reject) => {
            let isEdit = false;
            if(document.getElementById("modalAddEditBloc") && document.getElementById("modalAddEditBloc").querySelector('.modal-title').textContent.startsWith("Edit")){
                isEdit = true;
            }

            var fieldType = fieldData.type;
            var isRequired = (fieldData.is_required == "1");
            var templateSelector = '#template_section_field_' + fieldType;

            if( fieldType.startsWith('view_') ){
                templateSelector = '#template_section_field_view_generic';

                if(fieldType == "view_commercial_products"){
                    $(templateSelector).find('.active_promotion_filter_row').show();
                } else{
                    $(templateSelector).find('.active_promotion_filter_row').hide();
                }

                if(fieldType == "view_commercial_products" || fieldType == "view_structured_contents" || fieldType == "view_structured_pages"){
                    $(templateSelector).find('.load_sub_folders').show();
                } else{
                    $(templateSelector).find('.load_sub_folders').hide();
                }
            }                

            var fieldTemplate = $(templateSelector);
            if (fieldTemplate.length == 0) {
                reject();
                return;
            }
            var fieldHtml = fieldTemplate.html();
            
            fieldHtml = strReplaceAll(fieldHtml,"#FIELD_ID#", fieldId);
            fieldHtml = strReplaceAll(fieldHtml,"#LANG_ID#", langId);
            
            if(fieldSpecs){
                if(newFieldType=="attr") fieldHtml = strReplaceAll(fieldHtml,"#FIELD_NAME#", fieldData.name+fieldSpecs.name);
                
                if(newFieldType=="spec") {
                    fieldHtml = strReplaceAll(fieldHtml,"#FIELD_NAME#", fieldSpecs.specLabel);
                    fieldHtml = strReplaceAll(fieldHtml,"#FIELD_ID_LABEL_INDEXED#", fieldId+"_index");
                    fieldHtml = strReplaceAll(fieldHtml,"#FIELD_ID_LABEL#", fieldId+"_label");
                    fieldHtml = strReplaceAll(fieldHtml,"#FIELD_ID_SELECT#", fieldId+"_select");
                } else fieldHtml = strReplaceAll(fieldHtml,"#FIELD_NAME#", fieldData.name);
            }else{
                fieldHtml = strReplaceAll(fieldHtml,"#FIELD_NAME#", fieldData.name);
            }
            if(fieldData.description.length>0) fieldHtml = strReplaceAll(fieldHtml,"#FIELD_DESCRIPTION#", fieldData.description);
            else fieldHtml = strReplaceAll(fieldHtml,"title=\"#FIELD_DESCRIPTION#\"", "");

            fieldHtml = strReplaceAll(fieldHtml,"#FIELD_VALUE#", fieldData.default_value);
            fieldHtml = strReplaceAll(fieldHtml,"#SHOW_DELETE#", showDelete ? 'true' : '');

            if(bulkModificationScreen && fieldData.nb_items != 1){
                let appendHtml = '<select class="form-select" data-value="'+fieldId+'" name="append_to_section_'+langId+'">'+
                    '<option value="true">Append</option>'+
                    '<option value="false" selected>Not Append</option>'+
                '</select>';
                fieldHtml = strReplaceAll(fieldHtml, "#BULK_MODIFY_CHECK#",appendHtml);
            }else{
                fieldHtml = strReplaceAll(fieldHtml, "#BULK_MODIFY_CHECK#",'');
            }

            var fieldDiv = $(fieldHtml);
            if(fieldData.display == "0") fieldDiv.hide();
            else fieldDiv.show();

            if (!showDelete) fieldDiv.find('.deleteBtn').remove();

            fieldDiv.addClass('fieldDiv');
            fieldDiv.attr("fieldType", fieldType);
            fieldDiv.attr("fieldVal", fieldData.value);

            var addFieldDiv = container.find('>.add_field');
            if (addFieldDiv.length == 0) container.append(fieldDiv);
            else addFieldDiv.before(fieldDiv);

            var requiredInput = null;
            var langData = getLangData(fieldData, langId);
            
            if (fieldType == "text") {
                var _defaultVal = "";
                var _placeholder = "";

                if(langData) {
                    _defaultVal = langData.default_value;
                    _placeholder = langData.placeholder;
                }

                var textInput = fieldDiv.find('input.textInput');

                if(fieldData.modifiable !=undefined && (fieldData.modifiable==="never" || (fieldData.modifiable==="create" && isEdit))){
                    textInput.attr('readonly', true);
                }
                if(fieldData.reg_exp !=undefined && fieldData.reg_exp.length>0){
                    textInput.attr('pattern', decodeURIComponent(fieldData.reg_exp));
                }

                if(fieldId==="product_general_informations.product_general_informations_product_id" && productId.length>0) textInput.val(productId);
                else if(fieldId==="product_general_informations.product_general_informations_product_uuid" && productUuid.length>0) textInput.val(productUuid);
                else textInput.val(_defaultVal).attr('placeholder', _placeholder);

                if(fieldData.unique_type !=undefined && fieldData.unique_type==="auto"){
                    textInput.val(uuidv4());
                    textInput.addClass("uniqueId");
                }else if(fieldData.unique_type !=undefined && fieldData.unique_type==="custom"){
                    textInput.val('');
                    textInput.addClass("uniqueId");
                }
                
                if($ch.bulkModificationMode == true) textInput.prop("disabled", true);
                requiredInput = textInput;
            } else if (fieldType == "bloc") {
                var _defaultVal = "";
                var _placeholder = "";
                
                let blocId = "";
                let blocName = "";
                let templateId = "";
                let templateName = "";
                let templates = [];

                if(langData) {
                    try{
                        _defaultVal = JSON.parse(langData.default_value);
                        blocId = _defaultVal.bloc_id;
                        blocName = _defaultVal.bloc_name;
                        templateId = _defaultVal.template_id;
                        templates = _defaultVal.templates;
                    }catch(ex){}
                    _placeholder = _defaultVal.placeholder;
                }
                
                let tmpArr = [];

                $.each(_defaultVal.templates,function(idx, tmp){
                    if(tmp.id == templateId) templateName = tmp.template_name;
                    if(templateId == "all") tmpArr.push(tmp.id);
                    let option = $("<option>").attr("value",tmp.id).text(tmp.template_name);
                    fieldDiv.find("select[name='"+fieldId+"_template']").append(option);
                    tmp.label = tmp.template_name;    
                });

                fieldDiv.find(`select[name='${fieldId}_template']`).on("change",function(e) {
                    let inputGroup = $(e.target).closest(".input-group");
                    inputGroup.find(".autocomplete-items").remove();
                    inputGroup.find("input").val("");
                    
                    let tempIds = getBlocsTemplates($(e.target),$(e.target).val() == "all");

                    getBlocsLists(tempIds).then(blocs => {
                        populateListToAutocomplete(inputGroup.find("input.asm-autocomplete-field"),blocs);
                        if(tempIds == "all" || tempIds == "") inputGroup.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                    }).catch(error => {
                        console.error(error);
                    });
                    
                });                

                fieldDiv.find("input.bloc-name").on('input keydown',function(e){
                    let field = $(e.target);
                    let inputGroup = field.closest(".input-group");
                    let templateId = inputGroup.find(".bloc-templates").val();
                    let templateName = inputGroup.find(`.bloc-templates option[value='${templateId}']`).text();
                    let isEditable = false;
                    let bId = "";
                    if(field.val().length <= 1){
                        inputGroup.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                        inputGroup.find(".autocomplete-items").remove();
                        return;
                    }

                    if(e.key == "Enter" && !e.trigger) {
                        bId = inputGroup.find("li.autocomplete-item-highlight a").data("id");
                        inputGroup.find("input.bloc-id").val(bId);
                        inputGroup.find("input.bloc-name").val(inputGroup.find("li.autocomplete-item-highlight a").attr("value"));
                    }

                    $.each(field.data("autocompleteList"),function(idx, tmp){
                        if(field.val().toLowerCase() == tmp.label.toLowerCase()) {
                            templateName = tmp.template;
                            templateId = tmp.template_id;
                            bId = tmp.id;
                            isEditable = true;
                            return;
                        }
                    });
                    
                    if(!isEditable && !e.trigger) {
                        field.next("input").val("");
                        inputGroup.find(".remove-bloc").show();
                        handleBlocButtons(inputGroup,"add",null,templateId,templateName);
                    }else if(e.key == "Enter" && isEditable) {
                        e.preventDefault();
                        inputGroup.find(".remove-bloc").show();
                        handleBlocButtons(inputGroup,"edit",bId,templateId,templateName);
                        field.next("input").val(bId);
                        inputGroup.find(".autocomplete-items").remove();
                    }

                    if(templateId == "all" || templateId == ""){
                        inputGroup.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                    }
                });

                fieldDiv.on("click",".autocomplete-items li",function(e){
                    let inputGroup = $(e.target).closest(".input-group");
                    inputGroup.find(".remove-bloc").show();
                    if(inputGroup.find("select.bloc-templates").val() == "all" || inputGroup.find("select.bloc-templates").val() == "") inputGroup.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                    else handleBlocButtons(inputGroup,"edit", $(e.target).prop("tagName") == "A" ? $(e.target).data("id") : $(e.target).find("a").data("id"),inputGroup.find(".bloc-templates").val(),inputGroup.find(`.bloc-templates option[value='${inputGroup.find(".bloc-templates").val()}']`).text());
                }); 

                if(fieldDiv.find(`select[name='${fieldId}_template'] option[value='${templateId}']`).length > 0)
                fieldDiv.find(`select[name='${fieldId}_template']`).val(templateId);
                loadAutoComplete(fieldDiv.find("input.asm-autocomplete-field"));
                fieldDiv.find(`select[name='${fieldId}_template']`).trigger("change");

                setTimeout(() => {
                    handleBlocField(fieldDiv,fieldId, blocId, blocName,templateId,templates);
                    if(templateId == "all" || templateId == "") fieldDiv.find(".edit-bloc,.add-bloc,.remove-bloc").hide();
                }, 500);               

                if(fieldData.modifiable !=undefined && (fieldData.modifiable==="never" || (fieldData.modifiable==="create" && isEdit))) textInput.attr('readonly', true)
                if($ch.bulkModificationMode == true) textInput.prop("disabled", true);
                requiredInput = textInput;
            } else if (fieldType == "number") {

                var _defaultVal = "";
                var _placeholder = "";

                if(langData) {
                    _defaultVal = langData.default_value;
                    _placeholder = langData.placeholder;
                }

                var textInput = fieldDiv.find('input.textInput');

                if(fieldData.modifiable !=undefined && (fieldData.modifiable==="never" || (fieldData.modifiable==="create" && isEdit))) textInput.attr('readonly', true)
                
                if(fieldData.reg_exp !=undefined &&  fieldData.reg_exp.length) textInput.attr('pattern', decodeURIComponent(fieldData.reg_exp));

                textInput.val(_defaultVal).attr('placeholder', _placeholder);

                if(fieldData.unique_type !=undefined && fieldData.unique_type==="auto"){
                    textInput.val(getUniqueNumber());
                    textInput.addClass("uniqueId");
                }else if(fieldData.unique_type !=undefined && fieldData.unique_type==="custom"){
                    textInput.val('');
                    textInput.addClass("uniqueId");
                }

                if($ch.bulkModificationMode == true) textInput.prop("disabled", true);
                requiredInput = textInput;
            } else if (fieldType == "multiline_text") {

                var _defaultVal = "";
                var _placeholder = "";

                if(langData)
                {
                    _defaultVal = langData.default_value;
                    _placeholder = langData.placeholder;
                }

                var textareaInput = fieldDiv.find('textarea:first').attr('placeholder', _placeholder).text(_defaultVal);
                requiredInput = textareaInput;

                if(fieldData.modifiable !=undefined && (fieldData.modifiable==="never" || (fieldData.modifiable==="create" && isEdit))){
                    textareaInput.attr('readonly', true)
                }
                if(fieldData.reg_exp !=undefined && fieldData.reg_exp.length>0){
                    textareaInput.attr('pattern', decodeURIComponent(fieldData.reg_exp));
                }

                if($ch.bulkModificationMode == true) textareaInput.prop("disabled", true);
            } else if (fieldType == "text_formatted") {

                var _defaultVal = "";

                if(langData) _defaultVal = langData.default_value;
                var textareaInput = fieldDiv.find('textarea:first').text(_defaultVal);

                if(fieldData.modifiable !=undefined && (fieldData.modifiable==="never" || (fieldData.modifiable==="create" && isEdit))){
                    textareaInput.attr('readonly', true)
                }
                if(fieldData.reg_exp !=undefined && fieldData.reg_exp.length>0){
                    textareaInput.attr('pattern', decodeURIComponent(fieldData.reg_exp));
                }
                
                if($ch.bulkModificationMode == true) textareaInput.prop("disabled", true);
                if (isRequired) {
                    //not checking required on change event of ckeditor as it slows down very much
                    textareaInput.addClass('requiredInput').on('checkRequired', function(event) {
                        if ($(this).val().trim().length === 0) {

                            this.setCustomValidity("required");
                            $(this).parents('.ckeditorContainer:first').addClass('border border-danger').css('padding', '1px');
                        }
                        else {
                            this.setCustomValidity("");
                            $(this).parents('.ckeditorContainer:first').removeClass('border border-danger')
                                    .css('padding', null);
                        }
                    });
                }
            } else if (fieldType == "select") {
                let selectOptions = fieldData.value;
                let selectInput = fieldDiv.find('select');
                
                if(fieldData.is_query==="1"){
                    let qry = { [fieldData.query_type]: fieldData.value };
                    getSelectData(qry)
                        .then((val)=>{
                            handleSelectOptions(fieldData,fieldDiv,selectInput, JSON.stringify(val));
                            selectOptions= val;
                        }).catch((error) => {
                            console.error('Field generation encountered an error:', error);
                        });
                    
                    
                }else handleSelectOptions(fieldData,fieldDiv,selectInput, selectOptions);
                
                var _defaultVal = "";

                if(langData) _defaultVal = langData.default_value;
                if(fieldId==="product_general_informations.product_general_informations_price_frequency" || fieldId==="product_variants_variant_x.product_variants_variant_x_price_frequency"){
                    _defaultVal="one_shot";
                }
                if(fieldId==="product_general_informations.product_general_informations_price_display" || fieldId==="product_variants_variant_x.product_variants_variant_x_price_display"){
                    _defaultVal="1";
                }

                selectInput.val(_defaultVal);
                requiredInput = selectInput;
                if($ch.bulkModificationMode == true) selectInput.prop("disabled", true);
            } else if (fieldType == "product_attribute") {
                    let selectInput = fieldDiv.find('select');
                    fieldDiv.find('.selectDiv').find(".autocomplete_input").hide();
                    selectInput.show();
                    if(fieldSpecs){
                        let selectOptions = fieldSpecs.values;
                        $.each(selectOptions, function (index, val) {
                            let atrVal = {"name":fieldSpecs.name,"label":val.label,"type":fieldSpecs.type,"value":val.value,"unit":fieldSpecs.unit,"icon":fieldSpecs.icon};
                            selectInput.append('<option value="' + btoa(JSON.stringify(atrVal)) + '" >' + val.label + '</option>');
                        });
                    }
                    requiredInput = selectInput;
                    if($ch.bulkModificationMode == true) selectInput.prop("disabled", true);
            } else if (fieldType == "product_specification") {
                fieldDiv.find('input.specValue').val(fieldSpecs.specValue);
                fieldDiv.find('input.is_indexed').val(fieldSpecs.is_indexed);
                var textInput = fieldDiv.find('input.textInput');
                if($ch.bulkModificationMode == true) textInput.prop("disabled", true);
                requiredInput = textInput;
            } else if (fieldType == "image") {
                var _defaultVal = "";
                if(langData)
                {
                    _defaultVal = langData.default_value;
                }

                var defValue = _defaultVal.split(",");
                if (isRequired) {
                    fieldDiv.find('.image_card').addClass('requiredInput');
                }
                if (defValue.length == 2) {
                    fieldDiv.find(".img-limit").text((fieldData.nb_items > 0)? fieldData.nb_items: "unlimited");
                    fieldDiv.find(".image_card").data("img-limit",(fieldData.nb_items > 0)? fieldData.nb_items: 999);

                    let imgFolder = "cropped/"+fieldData.value;
                    if(fieldData.value.toLowerCase() == "free"){
                        imgFolder="";
                    }

                    window.fieldImageDivV2 = fieldDiv;

                    selectFieldImageV2({
                        name: defValue[0],
                        label: defValue[1],
                        dimension:imgFolder,
                    },fieldId,null,true);
                    
                }
                else {
                    updateFieldImageRequiredStatusV2(fieldDiv,true);
                }
                if($ch.bulkModificationMode == true) fieldDiv.find('.load-img-btn').prop("disabled", true);
            } else if (fieldType == "file") {

                var _defaultVal = "";

                if(langData)
                {
                    _defaultVal = langData.default_value;
                }

                var fileInput = fieldDiv.find('.file_value').val(_defaultVal)
                        .focus(function(event) {
                            $(this).trigger('blur');
                        });
                requiredInput = fileInput;
                if($ch.bulkModificationMode == true) fieldDiv.find('.file-select-btn').prop("disabled", true);
            } else if (fieldType == "boolean") {
                
                var checkInput = fieldDiv.find('input.booleanInput');
                var valueObj = JSON.parse(fieldData.value);
                var specificFieldType = JSON.parse(fieldData.field_specific_data);
                
                if(specificFieldType.type == "switch") {
                    checkInput.addClass("c-switch-input");
                    let label = $("<label>").addClass("c-switch c-switch-label c-switch-dark c-switch-lg");
                    label.append(checkInput);
                    label.append($("<span>").addClass("c-switch-slider").attr("data-checked",valueObj.on).attr("data-unchecked",valueObj.off));
                    fieldDiv.find(".field-boolean").append(label);
                    fieldDiv.find(".input-group").remove();

                }

                checkInput.data('valueOn', valueObj.on);
                checkInput.data('valueOff', valueObj.off);

                var _defaultVal = "";

                if(langData)
                {
                    _defaultVal = langData.default_value;
                }

                if (_defaultVal == '1') {
                    checkInput.prop("checked", true);
                }

                checkInput.triggerHandler('change');
                if($ch.bulkModificationMode == true) checkInput.prop("disabled", true);
            } else if (fieldType == "tag") {
                var tagInputField = fieldDiv.find('input.tagInputField');
                tagInputField.data("data-nb-items",fieldData.nb_items);
                tagInputField.data("folders-id",fieldData.value);
                tagInputField.on('focus', function() {
                    initTagAutocomplete(tagInputField, isRequired);
                });
                initTagAutocomplete(tagInputField, isRequired);

                var _defaultVal = "";
                if(langData) _defaultVal = langData.default_value;

                try {
                    var defaultTagsList = JSON.parse(_defaultVal);
                    if (Array.isArray(defaultTagsList)) {
                        $.each(defaultTagsList, function(index, tag) {
                            addTagGeneric(tag, tagInputField);
                        });
                    }
                } catch (ex) {}
                
                if(isRequired) updateTagsRequiredGeneric(tagInputField);
                if($ch.bulkModificationMode == true) tagInputField.prop("disabled", true);
            } else if (fieldType == "date") {
                try {
                    var _defaultVal = "";

                    if(langData)
                    {
                        _defaultVal = langData.default_value;
                    }

                    var dateData = JSON.parse(fieldData.value);
                    var dateType = dateData.date_type;
                    var dateFormat = dateData.date_format;

                    var dateInputStart = fieldDiv.find(".date_field_start:first");
                    var dateInputEnd = fieldDiv.find(".date_field_end:first");

                    initDatetimeFields(dateInputStart, dateInputEnd, dateType, dateFormat);
                    if (dateType == 'period') {
                        try {
                            var dateDefValue = JSON.parse(_defaultVal);
                            if(dateDefValue[0].length>0 && dateDefValue[1].length>0)
                                dateInputStart.val(`\${dateDefValue[0]} to \${dateDefValue[1]}`);
                            else
                                dateInputStart.val(`\${dateDefValue[0]}`);

                            dateInputEnd.val(dateDefValue[1]);
                        } catch (exx) {}

                        requiredInput = [dateInputStart.get(0), dateInputEnd.get(0)];
                        if($ch.bulkModificationMode == true)
                        {
                            dateInputStart.prop("disabled", true);
                            dateInputEnd.prop("disabled", true);
                        }
                        if(dateType !== 'time') fieldDiv.find(".dateEndDiv").hide();
                    }
                    else {
                        fieldDiv.find(".dateEndDiv").hide();
                        fieldDiv.find(".dateStartDiv").addClass('mb-0');
                        fieldDiv.find('input.date_field').attr('placeholder', '');

                        try {
                            var dateDefValue = JSON.parse(_defaultVal);
                            dateInputStart.val(dateDefValue[0]);
                        } catch (exx) {}

                        dateInputEnd.val('');
                        requiredInput = dateInputStart;
                        if($ch.bulkModificationMode == true)
                        {
                            dateInputStart.prop("disabled", true);
                            dateInputEnd.prop("disabled", true);
                        }
                    }

                }
                catch (ex) {
                }
            } else if (fieldType == "URL") {
                var _defaultVal = "";
                if(langData) _defaultVal = langData.default_value;

                var urlInput = fieldDiv.find("input.urlInput");
                var urlValue = "";
                var urlOpenType = "";
                // var urlLabel = "";
                var field_specific_data = "";
                try{
                    var defValue = JSON.parse(_defaultVal);
                    field_specific_data = JSON.parse(fieldData.field_specific_data);
                    
                    if(defValue[0]!=undefined){
                        urlValue = defValue[0];
                        urlOpenType = defValue[1];

                    }else urlValue = _defaultVal;
                } catch (ex) {
                    //for backward compatible, where only url string was stored as value
                    urlValue = _defaultVal;
                }

                urlInput.val(urlValue).attr('placeholder', fieldData.placeholder);

                initUrlFieldInput(urlInput);
                if (urlOpenType.length > 0) urlInput.data('url-generator').setOpenType(urlOpenType);

                requiredInput = urlInput;
                if($ch.bulkModificationMode == true) urlInput.prop("disabled", true);
                
                if(field_specific_data.type == "url & label") {
                    fieldDiv.find(".urlGenTooltip").text("Label - URL");
                    let urlLabel = $("<input>").addClass("urlGenLabel form-control");
                    urlLabel.insertAfter(fieldDiv.find(".urlGenTooltip"));
                    urlLabel.val((defValue[2]!= undefined)? defValue[2]: "");                        
                }
            } else if (fieldType.startsWith("view_")) {
                var folderSelect = fieldDiv.find("select[name=folder]:first");
                initViewField(fieldType, fieldDiv, fieldData);
                requiredInput = folderSelect;
            }

            if (isRequired) {
                fieldDiv.find('label').append('<span class="text-danger">&nbsp;*</span>');
                if (requiredInput !== null) $(requiredInput).attr('required', 'required');
            }

            addJsAndCss(fieldType,fieldData,fieldDiv,fieldId).then(() => resolve()).catch((error) => {
                reject();
            });
        });
    }

    function changeFieldSpec(selectElement) {
        var parentOfParent = selectElement.closest('.input-group');
        var specInput = parentOfParent.querySelector('input[name="product_variants_variant_x_specifications.product_variants_variant_x_specifications_x_spec"]');
        if (selectElement.value === 'custom') {
            specInput.style.display = 'block';
        } else {
            var fieldDiv = selectElement.closest('.fieldDiv');
            var allFieldDivs = fieldDiv.parentNode.querySelectorAll('.fieldDiv');
            var fieldDivIndex = Array.from(allFieldDivs).indexOf(fieldDiv);

            var form = selectElement.closest('form');
            var specValToCopy = form.querySelector('div').id+".section_product_variants_1.section_product_variants_variant_x";
            var targetDiv = document.getElementById(specValToCopy);
            if (targetDiv) {
                var inputElements = targetDiv.querySelectorAll('input.copyToOthervariantsSpec');
        
                if (inputElements.length > 0) {
                    specInput.value= inputElements[fieldDivIndex].value;
                }
            }
            specInput.style.display = 'none';
        }
    }

    function uuidv4() {
        const timestamp = new Date().getTime().toString(16);
        const uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
            .replace(/[xy]/g, function (c) {
                const r = Math.random() * 16 | 0, 
                    v = c === 'x' ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
        return uuid.replace('xxxx', timestamp);
    }

    function getSelectData(params){
        return new Promise((resolve,reject) => {
            $.ajax({
                url: 'blocsAjax.jsp',
                dataType: 'json',
                data: {
                    requestType : "getSelectData",
                    params : JSON.stringify(params),
                    site_id : siteId,
                },
            })
            .always(function(resp) {
                if(resp.status == 1){
                    resolve(resp.data.resp);
                }else reject();
            });
        })
    
    }

    function addSection(btn, sectionId,attribute,specification,notCreateLangSections) {

        let orignalSpecData = specification;
        let orignalAttrData = attribute;
        try{
            attribute = JSON.parse(atob(attribute));
        }catch(e){
            attribute = "";
        }

        try{
            specification = JSON.parse(atob(specification));
        }catch(e){
            specification = "";
        }
        
        btn = $(btn);
        var sectionDiv = $('#' + escapeDot(sectionId));

        var sectionId = sectionDiv.attr('id');
        var secData = sectionDiv.data('section-data');
        if(secData){
            var langId = sectionDiv.data('lang-id');
            var maxSectionCount = secData.nb_items;

            var existingSections = sectionDiv.find('>.bloc_section');

            if (maxSectionCount > 0 && existingSections.length >= maxSectionCount) {
                $(btn).prop('disabled', true);
            }
            else {

                var lastSectionNum = sectionDiv.attr('section-last-id');

                var nextSectionNum = parseInt(lastSectionNum) + 1;
                var curSecId = sectionId + '_' + nextSectionNum;

                generateSection(sectionDiv, curSecId, secData, true, langId,attribute,specification);
                sectionDiv.attr('section-last-id', nextSectionNum);

                if (maxSectionCount > 0 && (existingSections.length + 1) >= maxSectionCount) {
                    $(btn).prop('disabled', true);
                }
                if (!$ch.loadingBlocData) {
                    var curSectionDiv = $('#' + escapeDot(curSecId));
                    if (curSectionDiv.length > 0) {
                        curSectionDiv.find(".ckeditorField").ckeditor({
                            filebrowserImageBrowseUrl : "imageBrowser.jsp?popup=1",
                            extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
                            colorButton_enableMore : true,
                            colorButton_enableAutomatic : false,
                            allowedContent: true,
                            colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
                        }, onFieldCkeditorReady);
                    }
                }
                
                let newSectionId = "langContent_"+langId+".section_product_variants_1.section_product_variants_variant_x";
                
                if(sectionId==newSectionId && !notCreateLangSections){
                    var langContentDivs = $ch.langContentDivs;
                    langContentDivs.each(function (indexLang, langContent) {
                        let currentLangId = $(langContent).attr("data-lang-id");
                        if(indexLang==0){
                            addClassToInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_ean',nextSectionNum);
                            addClassToInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_sku',nextSectionNum);
                            addClassToInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_price_price',nextSectionNum);
                            addClassToInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_price_frequency',nextSectionNum);
                            addClassToInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_attributes',nextSectionNum);
                        }else{
                            let otherLangSectionId = "langContent_"+currentLangId+".section_product_variants_1.section_product_variants_variant_x";

                            if(callLangDetails) addSection(btn, otherLangSectionId,orignalAttrData,orignalSpecData,true);
                            
                            const elements = document.getElementById(otherLangSectionId);
                            if(elements){
                                elements.querySelectorAll(".duplicableOnly").forEach(element => {
                                    element.remove();
                                });
                            }

                            disableOtherlangInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_ean');
                            disableOtherlangInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_sku');
                            disableOtherlangInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_price_price');
                            disableOtherlangInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_price_frequency');
                            disableOtherlangInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_tags');
                            disableOtherlangInputs(currentLangId,'product_variants_variant_x.product_variants_variant_x_attributes');
                        } 
                    });
                }
            }

            setDuplicableSectionOrder(sectionDiv);
        }
        callLangDetails = true;
    }

    function deleteSingleSection(event, sectionId,langId,removeOtherLangSections){
        if(!removeOtherLangSections){
            var container;
            event.stopPropagation();
            var button = $(event.target);
            container = button.parents(".template_container:first");
            var curSection = container.find('.' + escapeDot(sectionId));
            //here curSection is both btn and content
            var sectionDiv = curSection.parents('.sectionDiv:first');

            if (!confirm("Are you sure?")) return false;
            curSection.remove();

            var secData = sectionDiv.data('section-data');
            var maxSectionCount = secData.nb_items;

            var existingSections = sectionDiv.find('>.bloc_section');
            if (maxSectionCount == 0 || existingSections.length < maxSectionCount) {
                sectionDiv.find('>.add_section .addSectionBtn').prop('disabled', false);
            }
        }else{
            document.getElementById(sectionId).remove();
            document.getElementById("section_btn_"+sectionId).remove();
        }
    }

    function deleteSection(event, sectionId) {
        if(sectionId.startsWith("langContent_1.section_product_variants_1.section_product_variants_variant_x_")){
            var langContentDivs = $ch.langContentDivs;
            langContentDivs.each(function (indexLang, langContent) {
                let currentLangId = $(langContent).attr("data-lang-id");
                sectionId = "langContent_"+currentLangId+".section_product_variants_1."+sectionId.split(".")[2];
                deleteSingleSection(event,sectionId,currentLangId,true);
            });

            langContentDivs.each(function (indexLang, langContent) {
                let currentLangId = $(langContent).attr("data-lang-id");
                var divElement = $('#langContent_'+currentLangId+'\\.section_product_variants_1\\.section_product_variants_variant_x');

                setDuplicableSectionOrder(divElement);
            });
        }
        else deleteSingleSection(event, sectionId);
    }

    function toggleSection(sectionId) {
        $('#' + escapeDot(sectionId)).collapse('toggle');
    }

    function addField(btn) {
        btn = $(btn);

        var fieldContainerDiv = btn.parents('.fieldContainerDiv:first');
        var fieldData = fieldContainerDiv.data('field-data');
        var fieldId = fieldContainerDiv.attr('id');
        var langId = fieldContainerDiv.data('lang-id');
        var existingFields = fieldContainerDiv.find('.fieldDiv');
        var maxFields = fieldData.nb_items;

        if (maxFields == 0 || maxFields > existingFields.length) {
            var curFieldId = fieldId;
            generateField(fieldContainerDiv, curFieldId, fieldData, true, langId).then(() => {
                console.log('Field generation completed successfully.');
            }).catch((error) => {
                console.error('Field generation encountered an error:', error);
            });
        }

        existingFields = fieldContainerDiv.find('.fieldDiv');
        if (maxFields > 0 && maxFields <= existingFields.length) {
            btn.prop('disabled', true);
        }

        if (!$ch.loadingBlocData) {
            fieldContainerDiv.find(".ckeditorField").ckeditor({
                filebrowserImageBrowseUrl : 'imageBrowser.jsp?popup=1',
                extraPlugins: ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'],
                colorButton_enableMore : true,
                colorButton_enableAutomatic : false,
                allowedContent: true,
                colorButton_colors : '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14',
            }, onFieldCkeditorReady);
        }
    }

    function deleteField(event, btn) {
        event.stopPropagation();

        if (!confirm("Are you sure?")) {
            return false;
        }
        btn = $(btn);

        var fieldContainerDiv = btn.parents('.fieldContainerDiv:first');
        btn.parents('.fieldDiv:first').remove();

        var fieldData = fieldContainerDiv.data('field-data');
        var existingFields = fieldContainerDiv.find('.fieldDiv');
        var maxFields = fieldData.nb_items;

        if (maxFields > 0 && maxFields > existingFields.length) {
            var addFieldButton = fieldContainerDiv.find('.add_field button');
            addFieldButton.prop('disabled', false);
        }
    }

    function generateTemplateData(container) {
        var templateDataObj = {};
        var sectionDivList = container.find('> .sectionDiv');

        $.each(sectionDivList, function(secIndex, sectionDiv) {
            generateSectionContainerData(sectionDiv, templateDataObj);
        });
        return templateDataObj;
    }

    function generateSectionContainerData(sectionDiv, parentDataObj) {
        sectionDiv = $(sectionDiv);

        var sectionCode = sectionDiv.data('section-data');
        var sectionId = sectionCode.custom_id;
        var secDataList = [];
        var sectionDataList = sectionDiv.find('> .bloc_section');
		var sectionHtmlId = sectionDataList.attr("id");

		if($ch.bulkModificationMode === true && sectionDataList.find(".bloc_section").length > 0) validBulkModifSections.push(sectionHtmlId);
        $.each(sectionDataList, function(secDataIndex, secDataDiv) {
            secDataDiv = $(secDataDiv);
            var secDataObj = generateSectionData(sectionCode, secDataDiv, secDataIndex, sectionHtmlId);
			secDataList.push(secDataObj);
        });

		if($ch.bulkModificationMode === true && validBulkModifSections.includes(sectionHtmlId)) parentDataObj[sectionId] = secDataList;
		else if($ch.bulkModificationMode === false)  parentDataObj[sectionId] = secDataList;
    }

	function getFieldData(fieldDiv, fieldCode, fieldName, fieldId, fieldType) {
		fieldDiv = $(fieldDiv);
		var fieldValue = '';

		if (fieldType == "image") {
            fieldValue = [];
            $.each(fieldDiv.find(".ui-state-media-default").not(":last"),function(idx,el){
                fieldValue.push({
                    value: $(el).find('[name=' + escapeDot(fieldName) + '_value]').val(),
                    alt: $(el).find('[name=' + escapeDot(fieldName) + '_alt]').val(),
                });
            });
            if(fieldCode.is_required == "1") {
                updateFieldImageRequiredStatusV2(fieldDiv);
            }
		} else if (fieldType == "boolean") {
			var fieldInput = fieldDiv.find('[name=' + escapeDot(fieldName) + ']');
			if (fieldInput.is(":checked")) fieldValue = fieldInput.data('valueOn');
			else fieldValue = fieldInput.data('valueOff');
		} else if (fieldType == "tag") {
			fieldValue = [];
			fieldDiv.find('input.tagValue').each(function(index, input) {
				var val = $(input).val().trim();
				if (val.length > 0) fieldValue.push(val);
			});
		} else if(fieldType == "bloc") {
            fieldValue = {
                    template_id : fieldDiv.find("select[name='"+escapeDot(fieldName)+"_template']").val().trim(),
                    bloc_name : fieldDiv.find("input[name='"+escapeDot(fieldName)+"_bloc_name']").val().trim(),
                    bloc_id : fieldDiv.find("input[name='"+escapeDot(fieldName)+"_bloc_id']").val().trim(),
                };            
        } else if (fieldType == "date") {
			fieldValue = [
				fieldDiv.find('[name=' + escapeDot(fieldName) + '_start]').val(),
				fieldDiv.find('[name=' + escapeDot(fieldName) + '_end]').val(),
			];
		} else if (fieldType == "URL") {
			var urlInput = fieldDiv.find('[name=' + escapeDot(fieldName) + ']');
			fieldValue = {
				value : urlInput.val(),
				openType : urlInput.data('url-generator').getOpenType(),
			};
            if (fieldCode.field_specific_data && JSON.parse(fieldCode.field_specific_data).type == "url & label") {
                fieldValue["label"] = fieldDiv.find(".urlGenLabel").val();
            } 
		} else if (fieldType.startsWith("view_")) {
			fieldValue = {
				catalogs : [],
				sortBy : [],
				filterBy : []
			};

            if(fieldType == "view_commercial_products"){
                fieldValue["promotionFilter"] = 0
                fieldDiv.find('.viewPromotionFilterDiv [name=promotionFilterCheckbox]').each(function (index, checkbox) {
                    if($(checkbox).is(':checked')) fieldValue["promotionFilter"] = 1
                });
            }
            if(fieldType == "view_commercial_products" || fieldType == "view_structured_contents" || fieldType == "view_structured_pages"){
                fieldValue["subFolder"] = 0
                fieldDiv.find('.loadSubFoldersFileter [name=subFoldersCheckbox]').each(function (index, checkbox) {
                    if($(checkbox).is(':checked')) fieldValue["subFolder"] = 1
                });
            }

			fieldDiv.find('.viewFolderSelect [name=folder]').each(function (index, select) {
				if ($(select).val() !== null && $(select).val() !== "") {
					fieldValue.catalogs.push($(select).val());
				}
			});

			fieldDiv.find('.viewSortBySelect').each(function (index, el) {
				el = $(el);
				var column = el.find('[name=sortByColumn]').val();
				var direction = el.find('[name=sortByDirection]').val();
				fieldValue.sortBy.push([column, direction]);
			});

			fieldDiv.find('.viewFilterBySelect').each(function (index, el) {
				el = $(el);
				var column = el.find('[name=filterByColumn]').val();
				var operator = el.find('[name=filterByOperator]').val();
				var value = el.find('[name=filterByValue]').val();
				fieldValue.filterBy.push({
					column : column,
					operator : operator,
					value : value
				});
			});
		} else if (fieldType == "product_attribute") {
            let selectedEle = fieldDiv.find('[name=' + escapeDot(fieldName) + ']').find('option:selected'); 
            try{
                fieldValue = JSON.parse(atob(selectedEle.val()));
                fieldValue.label=selectedEle.text();
            }catch(e){
                fieldValue = "";
            }
        } else if (fieldType == "product_specification") {
            try{
                var jsonData = {
                    value: fieldDiv.find('[name=' + escapeDot(fieldName) + '_label]').val(),
                    label: fieldDiv.find('label:first').text().trim(),
                    spec_value: fieldDiv.find('[name=' + escapeDot(fieldName) + ']').val(),
                    selectValue: fieldDiv.find('[name=' + escapeDot(fieldName) + '_select]').val(),
                    is_indexed: fieldDiv.find('[name=' + escapeDot(fieldName) + '_index]').val()
                };
                fieldValue = jsonData;
            }catch(e){
                fieldValue = "{}";
            }
        }
		else fieldValue = fieldDiv.find('[name=' + escapeDot(fieldName) + ']').val();

		return fieldValue;
	}

    function generateSectionData(sectionCode, secDataDiv, secDataIndex, sectionHtmlId) {
        var sectionDataObj = {};
        var fieldContainerList = secDataDiv.find('> .fieldContainerDiv');

        $.each(fieldContainerList, function(fieldContIndex, fieldContainerDiv) {
            fieldContainerDiv = $(fieldContainerDiv);

            var fieldCode = fieldContainerDiv.data('field-data');
            var fieldNamePrefix = fieldContainerDiv.attr('id');
            var fieldId = fieldCode.custom_id;
            var fieldType = fieldCode.type;
            var fieldValuesList = [];
            var fieldDivList = fieldContainerDiv.find('.fieldDiv');
			let _addField = false;
            $.each(fieldDivList, function(fieldDivIndex, fieldDiv) {
                fieldDiv = $(fieldDiv);

				if($ch.bulkModificationMode === true && fieldDiv.find("input.bulkEditChkbox").is(":checked") == true){
                    if(fieldType !== "image") fieldValuesList.push(getFieldData(fieldDiv, fieldCode, fieldNamePrefix, fieldId, fieldType));
                    else fieldValuesList = getFieldData(fieldDiv, fieldCode, fieldNamePrefix, fieldId, fieldType);
					_addField = true;
				} else if($ch.bulkModificationMode === false) {
                    if(fieldType !== "image") fieldValuesList.push(getFieldData(fieldDiv, fieldCode, fieldNamePrefix, fieldId, fieldType));
                    else fieldValuesList = getFieldData(fieldDiv, fieldCode, fieldNamePrefix, fieldId, fieldType);
					_addField = true;
				}
            });
            if(_addField)
			{
				sectionDataObj[fieldId] = fieldValuesList;
				if($ch.bulkModificationMode === true) validBulkModifSections.push(sectionHtmlId);
			}
        });

        //process nested section data
        var nestedSectionDivList = secDataDiv.find('> .sectionDiv');
        $.each(nestedSectionDivList, function(nestedSecIndex, nestedSectionDiv) {

            generateSectionContainerData(nestedSectionDiv, sectionDataObj);

        });

        return sectionDataObj;
    }

    function fillBlocData(templateDataObj, sectionDiv,productName) {
        var secCode = sectionDiv.data('section-data');
        var sectionId = secCode.custom_id;
        var sectionDataList = templateDataObj[sectionId];

        if (!sectionDataList) {
            document.querySelectorAll("input[name='main_information.system_product_name']").forEach(input => {
                input.value = productName;
            });
            return false;
        }

        var maxSectionCount = secCode.nb_items;
        var isSectionUnlimited = (secCode.nb_items != 1);

        if (isSectionUnlimited) {
            maxSectionCount = sectionDataList.length;

            if (secCode.nb_items > 1 && maxSectionCount > secCode.nb_items) maxSectionCount = secCode.nb_items;
            var existingSecCount = sectionDiv.find('>.bloc_section').length;
            if (maxSectionCount > existingSecCount) {
                var addSecButton = sectionDiv.find('>.add_section button');
                $.each(Array(maxSectionCount - existingSecCount), function(index, val) {
                    callLangDetails = false;
                    addSecButton.trigger('click');
                });
            }
        }

        var existingSectionDivs = sectionDiv.find('>.bloc_section');

        for (var secCount = 0; secCount < maxSectionCount; secCount++) {
            if (secCount >= sectionDataList.length) {
                break;
            }

            var sectionDataObj = sectionDataList[secCount];
            var curSectionDiv = $(existingSectionDivs.get(secCount));
            var fieldContainerList = curSectionDiv.find('>.fieldContainerDiv');

            $.each(fieldContainerList, function(index, fieldContainerDiv) {
                fieldContainerDiv = $(fieldContainerDiv);

                var fieldCode = fieldContainerDiv.data('field-data');
                var fieldId = fieldCode.custom_id;
                var fieldDataList = sectionDataObj[fieldId];

                if (!fieldDataList) return true;

                var fieldType = fieldCode.type;
                var select_type = fieldCode.select_type;
                var maxFieldCount = fieldCode.nb_items;
                
                if(fieldDataList.length == 0 && fieldType === "image") {
                    fieldDataList.push("");
                }

                var isFieldUnlimited = (fieldCode.nb_items != 1);

                if (isFieldUnlimited) {
                    maxFieldCount = fieldDataList.length;

                    if (fieldCode.nb_items > 1 && maxFieldCount > fieldCode.nb_items) {
                        maxFieldCount = fieldCode.nb_items;
                    }

                    var existingFieldCount = fieldContainerDiv.find('.fieldDiv').length;
                    if (maxFieldCount > existingFieldCount) {
                        var addFieldButton = fieldContainerDiv.find('.add_field button');
                        $.each(Array(maxFieldCount - existingFieldCount), function(index, val) {
                            addFieldButton.trigger('click');
                        });
                    }
                }
                

                for (var fieldCount = 0; fieldCount < maxFieldCount; fieldCount++) {
                    if (fieldCount >= fieldDataList.length) {
                        break;
                    }

                    var fieldDataValue = fieldDataList[fieldCount];
                    if (fieldDataValue == null || typeof fieldDataValue == 'undefined') {
                        continue;
                    }
                    var fieldDiv = $(fieldContainerDiv.find('.fieldDiv').get(fieldCount));

                    var fieldName = sectionId + "." + fieldId;
                    if (fieldType == "image") {
                        window.fieldImageDivV2 = fieldDiv;
                        if(fieldDataList.length > 0) window.fieldImageDivV2.find(".ui-state-media-default").not(":last").remove();
                        $.each(fieldDataList, function(idx,val) {
                        var imageObj = {
                                name: (val.hasOwnProperty("value"))? val.value : "",
                                label: (val.hasOwnProperty("alt"))? val.alt : "" ,
                                alt: (val.hasOwnProperty("alt"))? val.alt : "" 
                        };                        
                            
                            selectFieldImageV2(imageObj,fieldName,JSON.parse(fieldCode.field_specific_data)["type"],true);
                        });
                        

                    } else if(fieldType == "select"){
                        fieldDiv.find('[name='+escapeDot(fieldName)+']').val(fieldDataValue);
                        if(select_type == 'search'){
                            $.each(fieldDiv.find(".autocomplete-items").find("li"),function(idx,element){
                                if(element.getAttribute('value') === fieldDataValue) {
                                    fieldDiv.find('[data-name='+escapeDot(fieldName)+']').val(element.textContent);
                                }
                            });
                        }
                    } else if (fieldType == "file") {
                        fieldDiv.find('[name=' + escapeDot(fieldName) + '],input.file_value').val(fieldDataValue);
                    } else if (fieldType == "boolean") {
                        var fieldInput = fieldDiv.find('[name=' + escapeDot(fieldName) + ']');
                        if (fieldDataValue == fieldInput.data('valueOn')) fieldInput.prop('checked', true);
                        else fieldInput.prop('checked', false);
                        fieldInput.triggerHandler('change');
                    } else if (fieldType == "bloc") {
                        if(fieldDiv.find(`select.bloc-templates option[value='${fieldDataValue.template_id}']`).length > 0){
                        fieldDiv.find('select.bloc-templates').val(fieldDataValue.template_id).trigger("change");
                        setTimeout(function() {
                            fieldDiv.find('input.bloc-name').val(fieldDataValue.bloc_name).trigger($.Event("keydown", { key: "Enter", keyCode: 13, which: 13, trigger: true }));
                                //fieldDiv.find('input.bloc-id').val(fieldDataValue.bloc_id);
                        },500);
                        }
                    } else if (fieldType == "tag") {
                        var fieldInput = fieldDiv.find('[name=' + escapeDot(fieldName) + ']');

                        removeAllTagsGeneric(fieldInput);
                        $.each(fieldDataValue, function(index, tag) {
                            addTagGeneric(tag, fieldInput);
                        });
                    } else if (fieldType == "date") {
                        
                        var dateStart = fieldDataValue[0];
                        var dateEnd = fieldDataValue[1];

                        var dateInputStart =  fieldDiv.find('[name="' + escapeDot(fieldName) + '_start"]');
                        dateInputStart.val(dateStart);
                        var dateInputEnd = fieldDiv.find('[name="' + escapeDot(fieldName) + '_end"]');
                        dateInputEnd.val(dateEnd);

                        var dateFormat = JSON.parse(fieldCode.value).date_format;

                        if(dateStart.length>0) formatBlockDate(dateInputStart, dateFormat)
                        
                        if (dateEnd.length > 0) formatBlockDate(dateInputEnd, dateFormat)
                    } else if (fieldType == "number") {
                        fieldDiv.find('[name=' + escapeDot(fieldName) + ']').val(fieldDataValue)
                        .triggerHandler('blur');
                    } else if (fieldType == "URL") {
                        var urlInput = fieldDiv.find('[name=' + escapeDot(fieldName) + ']');
                        var urlLabel = fieldDiv.find('input.urlGenLabel');
                        var urlValue = "";
                        var urlType = JSON.parse(fieldCode.field_specific_data)["type"];
                        var urlOpenType = "";                        

                        if (typeof fieldDataValue === "object") {
                            urlValue = fieldDataValue.value;
                            urlOpenType = fieldDataValue.openType;
                            if(urlType == "url & label" && urlLabel.length > 0) urlLabel.val(fieldDataValue.label);
                        }
                        else {
                            urlValue = fieldDataValue;
                        }
                        urlInput.val(urlValue).triggerHandler('blur');
                        if (urlOpenType.length > 0) {
                            urlInput.data('url-generator').setOpenType(urlOpenType);
                        }
                    } else if (fieldType.startsWith("view_")) {
                        if(fieldType == "view_commercial_products") {
                            if(fieldDataValue.promotionFilter == 1){
                                fieldDiv.find('.viewPromotionFilterDiv [name=promotionFilterCheckbox]').prop('checked', true);
                            } else{
                                fieldDiv.find('.viewPromotionFilterDiv [name=promotionFilterCheckbox]').prop('checked', false);
                            }
                        }
                        if(fieldType == "view_commercial_products" || fieldType == "view_structured_contents" || fieldType == "view_structured_pages"){
                            if(fieldDataValue.subFolder == 1){
                                fieldDiv.find('.loadSubFoldersFileter [name=subFoldersCheckbox]').prop('checked', true);
                            } else{
                                fieldDiv.find('.loadSubFoldersFileter [name=subFoldersCheckbox]').prop('checked', false);
                            }
                        }

                        var addFolderBtn = fieldDiv.find('.addFolderBtn');
                        fieldDataValue.catalogs.forEach(function (curCatalog, i) {
                            if (i > 0) addFolderBtn.trigger('click');
                            fieldDiv.find('.viewFolderSelect [name=folder]:last').val(curCatalog).trigger('change');
                        });

                        var addSortByBtn = fieldDiv.find('.addSortByBtn');
                        fieldDataValue.sortBy.forEach(function (curSortBy, i) {
                            if (Array.isArray(curSortBy) && curSortBy.length >= 2) {
                                if (i > 0) addSortByBtn.trigger('click');
                                fieldDiv.find('.viewSortBySelect:last [name=sortByColumn]').val(curSortBy[0]);
                                fieldDiv.find('.viewSortBySelect:last [name=sortByDirection]').val(curSortBy[1]);
                            }
                        });

                        var addFilterByBtn = fieldDiv.find('.addFilterByBtn');
                        fieldDataValue.filterBy.forEach(function (curFilterBy, i) {
                            addFilterByBtn.trigger('click');
                            var viewFilterBySelect = fieldDiv.find('.viewFilterBySelect:last');
                            viewFilterBySelect.find('[name=filterByColumn]').val(curFilterBy.column);
                            viewFilterBySelect.find('[name=filterByOperator]').val(curFilterBy.operator);
                            viewFilterBySelect.find('[name=filterByValue]').val(curFilterBy.value);
                        });

                    } else if (fieldType.startsWith("product_attribute")) {
                        let atrVal = {"name":fieldDataValue.name,"label":fieldDataValue.label,"type":fieldDataValue.type,"value":fieldDataValue.value,"unit":fieldDataValue.unit,"icon":fieldDataValue.icon};
                        fieldDiv.find('[name=' + escapeDot(fieldName) + ']').val(btoa(JSON.stringify(atrVal)));
                    }else if (fieldType == "product_specification") {
                        let value = fieldDiv.find('[name=' + escapeDot(fieldName) + '_label]').val();
                        let label = fieldDiv.find('label:first').text().trim();
                        if(fieldDataValue.label == label && fieldDataValue.value==value) {
                            fieldDiv.find('[name=' + escapeDot(fieldName) + ']').val(fieldDataValue.spec_value);
                            fieldDiv.find('[name=' + escapeDot(fieldName) + '_select]').val(fieldDataValue.selectValue);

                            if(fieldDataValue.selectValue=="default"){
                                fieldDiv.find('[name=' + escapeDot(fieldName) + ']').hide();
                            }
                        }
                    } else {
                        fieldDiv.find('[name=' + escapeDot(fieldName) + ']').val(fieldDataValue);
                    }

                }//for fieldCount
            });

            if (isSectionUnlimited) curSectionDiv.find('[type=text],select').first().trigger('change');

            var nestedSections = curSectionDiv.find('>.sectionDiv');
            $.each(nestedSections, function(nestedIndex, nestedSectionDiv) {
                fillBlocData(sectionDataObj, $(nestedSectionDiv),productName);
            });
        }//for secCount
    }

    function onFieldCkeditorReady(evt) {
        var collapseButton = $('#' + escapeDot(this.id) + "_toolbar_collapser");
        var editor = this.ui.editor;
        var relatedElement = $(editor.element.$);
        if (collapseButton.length > 0) {
            this.ui.editor.on('focus', function() {
                if (collapseButton.hasClass('cke_toolbox_collapser_min')) collapseButton.triggerHandler('click');

                if (!ckeditorInitialized[this.name]) {
                    var modal = $('#modalAddEditBloc');
                    modal.find('.modal-dialog').animate({scrollTop: 0}, 0);
                    ckeditorInitialized[this.name] = true;
                    $('#blocNameField').focus().blur();
                }
            });

            collapseButton.trigger('click');
        }
        hideLoader();
    }

    function onFieldBooleanChange(field) {
        field = $(field);
        if (field.is(':checked')) field.parent().find('.fieldValue').text(field.data('valueOn'));
        else field.parent().find('.fieldValue').text(field.data('valueOff'));
    }

    function initUrlFieldInput(input, options) {
        if (!etn || !etn.initUrlGenerator) return false;

        var urlGenOpts = {
            showOpenType: true,
            allowEmptyValue: true
        };

        if(typeof options == 'object') urlGenOpts = $.extend(urlGenOpts, options);

        var gen = etn.initUrlGenerator(input, window.URL_GEN_AJAX_URL, urlGenOpts);

        input = $(input);
        input.data('url-generator', gen);

        //adjust delete button inside input group
        var urlFieldDiv = input.parents('.urlField:first');
        var urlDeleteBtn = urlFieldDiv.find('.deleteBtn');
        urlDeleteBtn.insertBefore(gen.errorMsg);

    }

    // deprecated
    function openUrlGenerator2(btn) {
        btn = $(btn);
        var parentDiv = btn.parents('.urlField:first');
        var input = parentDiv.find('input[type=text]:first');

        var urlFieldId = 'curUrlField';
        while ($('#' + escapeDot(urlFieldId)).length > 0) {
            $('#' + escapeDot(urlFieldId)).attr('id', null);
        }
        input.attr('id', urlFieldId);
        openUrlGenerator(urlFieldId);
    }

    function setDuplicableSectionOrder(sectionDiv) {
        var existingSections = sectionDiv.find('>.bloc_section_btn');
        var existingSectionsMain = sectionDiv.find('>.bloc_section');
        existingSections.each(function(index, el) {
            var curSec = $(el);
            curSec.find('input.sectionOrderInput').val(index + 1);
            
            var selectElements = $(existingSectionsMain[index]).find('#product_variants_variant_x_specifications\\.product_variants_variant_x_specifications_x_spec').find('select');
            if (selectElements.length) {
                selectElements.each(function() {
                    if(index==0) {
                        $(this).val('custom');
                        $(this).hide();
                        $(this).parent()
                        .siblings('input[name="product_variants_variant_x_specifications.product_variants_variant_x_specifications_x_spec"]')
                        .addClass('copyToOthervariantsSpec')
                        .on('blur', function() {
                            
                            var inputValue = $(this).val();
                            var inputIndex = $(this).closest('div[id="product_variants_variant_x_specifications.product_variants_variant_x_specifications_x_spec"]')
                                .find('input[name="product_variants_variant_x_specifications.product_variants_variant_x_specifications_x_spec"]')
                                .index(this);
            
                            var form = $(this).closest('form')[0];
                            var specValToCopy = form.querySelector('div').id+".section_product_variants_1.section_product_variants_variant_x";
                            var targetDiv = document.getElementById(specValToCopy);

                            var allDivs = $(targetDiv).find('div#product_variants_variant_x_specifications\\.product_variants_variant_x_specifications_x_spec');
                            allDivs.each(function() {
                                var inputs = $(this).find('input[name="product_variants_variant_x_specifications.product_variants_variant_x_specifications_x_spec"]');
                                var selects = $(this).find('select[name="product_variants_variant_x_specifications.product_variants_variant_x_specifications_x_spec_select"]');
                                
                                if( $(selects[inputIndex]).val() !=="custom") $(inputs[inputIndex]).val(inputValue);
                            });

                        });
                        
                    }else {
                        $(this).show();
                        $(this).val('default');

                        $(this).parent()
                        .siblings('input[name="product_variants_variant_x_specifications.product_variants_variant_x_specifications_x_spec"]')
                        .hide()
                        .removeClass('copyToOthervariantsSpec')
                        .off('blur');

                        changeFieldSpec(this);
                    }
                });
            
            }
        });
    }

    function onKeyDownSectionOrder(event) {
        var keyCode = event.keyCode;
        if (keyCode == 13) $(event.target).trigger('blur');
    }

    function onSectionUpDown(input, addPosition) {
        var positionInput = $(input).parents('.btn-group:first').find("input.sectionOrderInput:first");
        onChangeSectionOrder(positionInput, addPosition);
    }

    function onChangeSectionOrder(input, addPosition) {
        input = $(input);
        var sectionDiv = input.parents(".sectionDiv:first");
        try {
            var newPosition = parseInt(input.val().trim());

            if (isNaN(newPosition)) {
                throw "skip it";
            }

            if (newPosition < 1) newPosition = 1;

            if (typeof addPosition !== 'undefined') newPosition = newPosition + addPosition;

            var existingSections = sectionDiv.find('>.bloc_section_btn')
            var inputSectionBtn = input.parents(".bloc_section_btn:first");

            if (newPosition > existingSections.length) newPosition = existingSections.length
            else if (newPosition < 1) newPosition = 1;

            var curPosition = 0;
            existingSections.each(function(index, el) {
                if (inputSectionBtn.is($(el))) curPosition = (index + 1);
            });

            if (newPosition == curPosition) {
                throw "skip it";
            }

            var inputSectionContent = inputSectionBtn.next();
            var inserted = false;

            existingSections.each(function(index, el) {
                if (newPosition == (index + 1)) {
                    if (newPosition < curPosition) {
                        $(el).before(inputSectionBtn);
                        $(el).before(inputSectionContent);
                    }
                    else {
                        $(el).next().after(inputSectionContent);
                        $(el).next().after(inputSectionBtn);
                    }
                    inserted = true;
                    return false;
                }

            });
            if (!inserted) {
                var lastSec = existingSections.last().next();
                lastSec.after(inputSectionContent);
                lastSec.after(inputSectionBtn);
            }

        } catch (ex) {
            //do nothing
        }
        setDuplicableSectionOrder(sectionDiv);
    }

    function initViewField(fieldType, fieldDiv, fieldData) {
        var folderSelect = fieldDiv.find(".viewFolderSelect select[name=folder]");
        var sortBySelect = fieldDiv.find(".viewSortBySelect select[name=sortByColumn]");
        var filterBySelect = fieldDiv.find(".viewFilterByTemplate select[name=filterByColumn]");

        var fieldTemplate = $('#template_view_columns_' + fieldType);
        var templateSelect = fieldTemplate.find("select[name=folder]");
        folderSelect.html(templateSelect.html()).addClass(templateSelect.attr('class'));

        sortBySelect.html(fieldTemplate.find("select[name=sortByColumn]").html());
        filterBySelect.html(fieldTemplate.find("select[name=filterByColumn]").html());
    }

    function addViewFolder(btn) {
        btn = $(btn);
        var folderSelect = btn.parents(".viewField:first").find(".viewFolderSelect:first");

        var folderClone = folderSelect.clone(true);
        folderSelect.parent().append(folderClone);
        var deleteBtn = $('<button type="button" class="btn btn-danger rounded-right deleteParentBtn"><span aria-hidden="true">&times;</span></button>');
        deleteBtn.click(function () {
            deleteParent(this, '.viewFolderSelect:first');
        });
        folderClone.find('.invalid-feedback').before($('<div class="input-group-append"></div>').append(deleteBtn));

        folderClone.find('[name=folder]').removeClass('rounded-right')
        .attr('required', 'required').trigger('change');
    }

    function addViewSortBy(btn) {
        btn = $(btn);
        var sortBySelect = btn.parents(".viewField:first").find(".viewSortBySelect:first");

        var cloneSelect = sortBySelect.clone(true);
        var deleteBtn = $('<button type="button" class="btn btn-danger deleteParentBtn"><span aria-hidden="true">&times;</span></button>');
        deleteBtn.click(function () {
            deleteParent(this, '.viewSortBySelect:first');
        });
        cloneSelect.append($('<div class="input-group-append"></div>').append(deleteBtn));

        sortBySelect.parent().append(cloneSelect);
    }

    function addViewFilterBy(btn) {

        var filterBySelect = btn.closest(".viewField").querySelector(".viewFilterByTemplate");

        var cloneSelect = filterBySelect.cloneNode(true);
        cloneSelect.classList.remove('viewFilterByTemplate');
        cloneSelect.classList.remove('d-none');
        cloneSelect.classList.add('viewFilterBySelect');
        var filterInput = cloneSelect.querySelector('input[name=filterByValue]');

        filterInput.addEventListener("blur",function(event){
            var autocompleteList = event.target.nextElementSibling;
            autocompleteList.style.display="none";
        });

        filterInput.addEventListener('input', function(event) {
        var searchTerm = event.target.value;
        var filterCol = event.target.closest('.viewFilterBySelect').querySelector('select[name=filterByColumn]').value;
        var viewType = event.target.closest('.fieldDiv').getAttribute("fieldType");
        var templateVal = event.target.closest('.fieldDiv').getAttribute("fieldVal");
        if(filterCol === "f.name" || filterCol == "p.name" || filterCol == "p.lang_"+langId1+"_name"){
            showLoader();
            $.ajax({
                url: 'blocsAjax.jsp',
                dataType: 'json',
                data: {
                    requestType : "viewsFilterSeach",
                    searchQuery : searchTerm,
                    filterCol,
                    viewType,
                    templateVal,
                },
            })
            .done(function(resp) {
                if(resp.status == '1'){
                    var searchData = resp.data.searchResults.map(function(obj, idx) {
                        obj.label = obj.name;
                        return obj;
                    });
                    updateAutocompleteList(event.target,searchData);
                }
                else{
                    bootNotifyError(resp.message);
                    updateAutocompleteList(event.target,[]);
                }
            })
            .fail(function() {
                bootNotifyError("Error in accessing server.");
                updateAutocompleteList(event.target,[]);
            })
            .always(function() {
                hideLoader();
            });
        }
        });
        cloneSelect.querySelector('input[name=filterByValue]').addEventListener('keydown', function(event) {
            if (event.key === "Enter") {
                event.preventDefault();
                event.target.blur();
            }
        });

        filterBySelect.parentNode.appendChild(cloneSelect);
    }

    function onChangeViewFolderSelect(select) {
        select = $(select);
        //null check to handle jquery < v3.x
        if (select.is(':required') && (select.val() === null || select.val() === "")) {
            select.addClass('is-invalid');
        }
        else select.removeClass('is-invalid');
    }

	function editField(event, obj, typ) {
		if(typ === 'text') $editField = $(obj).parent().find("input.textInput");
		else if(typ === 'number') $editField = $(obj).parent().find("input.textInput");
		else if(typ === 'url') $editField = $(obj).parent().find("input.urlInput");
		else if(typ === 'tag') $editField = $(obj).parent().find("input.tagInputField");
		else if(typ === 'multiline_text') $editField = $(obj).parent().find("textarea.multilineInput");
		else if(typ === 'text_formatted') $editField = $(obj).parent().find("textarea.ckeditorField");
		else if(typ === 'select') $editField = $(obj).parent().find("select.selectInput");
		else if(typ === 'boolean') $editField = $(obj).parent().find("input.booleanInput");
		else if(typ === 'date'){
			$editField = $(obj).parent().find("input.date_field_start");
			$editField2 = $(obj).parent().find("input.date_field_end");
		}
		else if(typ === 'image') $editField = $(obj).parent().find(".load-img-btn");
		else if(typ === 'file') $editField = $(obj).parent().find(".file-select-btn");

		if($(obj).is(":checked")) {
			$editField.prop("disabled", false);
			if(typeof $editField2 !== 'undefined') $editField2.prop("disabled", false);
		}else {
			$editField.prop("disabled", true);
			if(typeof $editField2 !== 'undefined') $editField2.prop("disabled", true);
		}
	}