//globalnamespaces
window.etn = window.etn || {};
etn.asimina = etn.asimina || {};

//etn.asimina.util. We can add more function later on using the same covention;
(function (util){
    util.randomString = function(length){
        if(!length){
            length = 5;
        }
        var text = '';
        var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        for(var i=0; i < length; i++){
            text += possible.charAt(Math.floor(Math.random() * possible.length));
        }
        return text;
    };

    util.createElement = function(tagName,attr,css,html){
        var el = document.createElement(tagName);
        if(attr){
            $(el).attr(attr);
        }
        if(css){
            $(el).css(css);
        }
        if(html){
            $(el).html(html);
        }
        return el;
    };

    util.getCollapse = function(collapseId,label){

        var button = util.createElement("button",
                                {"type":"button","class":"btn btn-link btn-lg btn-block text-left text-light","data-toggle":"collapse","data-target":"#" + collapseId,"role":"button","aria-expanded":"false","aria-controls":collapseId},
                                null,label);
        var cardBody = util.createElement("div",{class:'card-body'});
        var collapse = util.createElement("div",{"class":"collapse border-0 show","id":collapseId});
        $(collapse).append(cardBody);
        return {button: button, div: collapse,body: cardBody};
    };

    util.getFormRow = function(label,fields){
        var row = document.createElement("div");
        $(row).addClass("form-group row");
        if(fields.isArray){
            $(row).append('<label for="' + $(fields[0]).attr("id") + '" class="col-sm-3 col-form-label">' + label + '</label>');
        }else{
            $(row).append('<label for="' + $(fields).attr("id") + '" class="col-sm-3 col-form-label">' + label + '</label>');
        }
        var col2 = $('<div class="col-sm-9"/>');
        $(row).append(col2);
        if(Array.isArray(fields)){
        	var inputGroup = $('<div class="input-group"/>');
            col2.append(inputGroup);
            fields.forEach(function(f){
                inputGroup.append(f);
                col2.append("<div class='invalid-feedback'/>");
            });
        }else{
            col2.append(fields);
            col2.append("<div class='invalid-feedback'/>");
        }
        return row;
    };

    util.scrollTo = function(el){
        $([document.documentElement, document.body]).animate({
            scrollTop: $(el).offset().top
        }, 1000);
    };

    util.onSectionUpDown = function(input, addPosition, sectionDiv){

        var positionInput = $(input).parents('.btn-group:first')
                                .find("input.sectionOrderInput:first");

        util.onChangeSectionOrder(positionInput, addPosition, sectionDiv);
    }

    util.onChangeSectionOrder = function(input, addPosition, secDiv){

        input = $(input);
        var sectionDiv = input.parents("." + secDiv + ":first");

        try{
            var newPosition = parseInt(input.val().trim());
            if(isNaN(newPosition)){
                throw "skip it";
            }

            if(newPosition < 1 ){
                newPosition = 1;
            }

            if(typeof addPosition !== 'undefined'){
                newPosition = newPosition + addPosition;
            }

            var existingSections = sectionDiv.find('.bloc_section_btn')
            var inputSectionBtn = input.parents(".bloc_section_btn:first");
            if(newPosition > existingSections.length){
                newPosition = existingSections.length
            }
            else if(newPosition < 1){
                newPosition = 1;
            }

            var curPosition = 0;
            existingSections.each(function(index, el) {
                if(inputSectionBtn.is($(el))){
                    curPosition = (index+1);
                }
            });

            if(newPosition == curPosition){
                throw "skip it";
            }

            var inputSectionContent = inputSectionBtn.next();
            var inserted = false;

            existingSections.each(function(index, el) {
                if( newPosition == (index+1) ){


                    if(newPosition < curPosition){

                        $(el).before(inputSectionBtn);
                        $(el).before(inputSectionContent);
                    }
                    else{

                        $(el).next().after(inputSectionContent);
                        $(el).next().after(inputSectionBtn);
                    }
                    inserted = true;
                    return false;
                }

            });

            if(!inserted){
                var lastSec = existingSections.last().next();
                lastSec.after(inputSectionContent);
                lastSec.after(inputSectionBtn);
            }

            var id = $(inputSectionContent).find(".ckeditor_field").attr("id");

            if(id.length > 0){

                CKEDITOR.instances[id].destroy();
                util.initCkeditor(id);
            }

        }
        catch(ex){
            //do nothing
        }

        util.setDuplicableSectionOrder(sectionDiv);

    }

    util.setDuplicableSectionOrder = function(sectionDiv){

        var existingSections = sectionDiv.find('.bloc_section_btn');

        existingSections.each(function(index, el) {
            var curSec = $(el);
            curSec.find('input.sectionOrderInput').val(index+1);
        });
    }

    util.onKeyDownSectionOrder = function(event){

        var keyCode = event.keyCode;
        if(keyCode == 13){
            //enter
            $(event.target).trigger('blur');
        }
    }

    util.initCkeditor = function(textarea){
    	var ckeditorInstance = CKEDITOR.replace(textarea);
        ckeditorInstance.config.filebrowserImageBrowseUrl=PAGES_APP_URL+'admin/imageBrowser.jsp?popup=1';
        ckeditorInstance.config.extraPlugins= ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'];
        ckeditorInstance.config.colorButton_enableMore = true;
        ckeditorInstance.config.colorButton_enableAutomatic = false;
        ckeditorInstance.config.colorButton_colors = '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14';
        ckeditorInstance.on("instanceReady",function(evt) {
            //console.log("ckeditor ready "+ evt.editor.name);
        });
        ckeditorInstance.on("blur",function(evt){
            //console.log("ckeditor blur called " + evt.editor.name );
            //console.log(evt);
            evt.editor.updateElement();
            $(evt.editor.element.$).triggerHandler('change');
        });

        return ckeditorInstance;
    }

}(etn.asimina.util = etn.asimina.util || {}));

(function( constants ) {

    var _data = {};

    constants.get = function(group,parentKey){
        if(!parentKey)parentKey = "";
        return _data[group][parentKey];
    }

    constants.init = function(data){
        _data = data;
    };
}( etn.asimina.constants = etn.asimina.constants || {} ));


(function(page){
    var _callStack = {};
    var _isFunctionRegistered = false;

    page.ready = function(){
        var callOrder,readyFunction;
        if(typeof arguments[0] === "function"){
            callOrder = 0;
            readyFunction = arguments[0];
        }else if(!isNaN(arguments[0]) && typeof arguments[1] === "function"){
            callOrder = arguments[0];
            readyFunction = arguments[1];
        }
        if(!_callStack[callOrder]){
            _callStack[callOrder] = [];
        }
        _callStack[callOrder].push(readyFunction);


        if(!_isFunctionRegistered){
            $(document).ready(function(e){
                Object.keys(_callStack).sort().forEach(function(key){
                    _callStack[key].forEach(function(f){
                        f.call(e);
                    });
                });
            });
            _isFunctionRegistered = true;
        }
    };
}(etn.asimina.page = etn.asimina.page || {}));

(function( tabs , util) {

    tabs.deleteTab = function(){
        var btn = $(this);
        var btnGroup = btn.parent();
        var collapseId = btnGroup.find("button[data-toggle=collapse]:first").attr('href');
        $(collapseId).remove();
        btnGroup.remove();
    };

    var tabView = function(tabId,divParent,languageId,tabData){
    	var count = tabs.getNextCount(languageId);
        var collapse = util.getCollapse("productTabs" + tabId,"Tab " + count);


        var btnGroup = util.createElement("div",{"class":"card-header btn-group col-12 p-0 bloc_section_btn"});

        var deleteTabBtn = util.createElement("button",
                                {"type":"button","class":"btn btn-danger mb-2"},
                                null,feather.icons['x'].toSvg());

        var upArrow = util.createElement("span",
                            {"type":"button","class":"mb-2 btn btn-secondary duplicableOnly","multilingual":"ignore","onclick":"etn.asimina.util.onSectionUpDown(this, -1, 'asimina-tab-zone-lang-" + languageId + "')"},
                            null, feather.icons['chevron-up'].toSvg());

        var sortSpan = util.createElement("span", {"type":"button","class":"mb-2 btn btn-secondary duplicableOnly"});
        var sortTextField = util.createElement("input", {"type":"text","class":"sectionOrderInput text-center rounded",
                            "value":"","onkeyup":"allowNumberOnly(this)","multilingual":"ignore","onkeydown":"etn.asimina.util.onKeyDownSectionOrder(event)","onchange":"etn.asimina.util.onChangeSectionOrder(this,0,'asimina-tab-zone-lang-" + languageId + "')"},
                            {"width":"40px"},null);


        var downArrow = util.createElement("span",
                            {"type":"button","class":"mb-2 btn btn-secondary duplicableOnly","multilingual":"ignore","onclick":"etn.asimina.util.onSectionUpDown(this, 1, 'asimina-tab-zone-lang-" + languageId + "')"},
                            null, feather.icons['chevron-down'].toSvg());

        sortSpan.append(sortTextField);

        $(btnGroup).append(collapse.button);
        $(btnGroup).append(upArrow);
        $(btnGroup).append(sortSpan);
        $(btnGroup).append(downArrow);
        $(btnGroup).append(deleteTabBtn);

        $(deleteTabBtn).on('click',tabs.deleteTab);

        $(divParent).append(btnGroup);
        $(divParent).append(collapse.div);

        var name = util.createElement("input",{"class":"form-control","type":"text","multilingual":"ignore","name":"product_tab_name_lang_" + languageId});
        if(tabData && tabData.name){
            $(name).val(tabData.name);
        }
        $(collapse.div).append(util.getFormRow("Tab name",name));

        var content = util.createElement("textarea",{"id":"product_tab_contentarea_"+tabId, "class":"form-control ckeditor_field","rows":"2","multilingual":"ignore","name":"product_tab_content_lang_" + languageId});
        if(tabData && tabData.content){
            $(content).html(tabData.content);
        }

        $(collapse.div).append(util.getFormRow("Tab content",content));

        var ckeditorInstance = util.initCkeditor(content);

    };

    var _tabs = {};
    // var _count = 0;
    var _count = {};

    tabs.getNextCount = function(languageId){
    	if(typeof _count[languageId] == 'undefined'){
    		_count[languageId] = 0;
    	}

    	_count[languageId] = _count[languageId] + 1;

    	return _count[languageId];
    };

    tabs.add = function(divParent,languageId,tabData){
        var tabId = util.randomString();
        var view = new tabView(tabId,divParent,languageId,tabData);
        _tabs[tabId] = view;
        return tabId;
    };
}( etn.asimina.product_tabs = etn.asimina.product_tabs || {} ,etn.asimina.util ));


(function( blocks , util) {

    blocks.deleteBlock = function(){
        var btn = $(this);
        var btnGroup = btn.parent();
        var collapseId = btnGroup.find("button[data-toggle=collapse]:first").attr('href');
        $(collapseId).remove();
        btnGroup.remove();
    };

    var blockView = function(blockId,divParent,languageId,blockData){
        var collapse = util.getCollapse("productDescription" + blockId,"Block " + (_count[languageId] + 1));

        var btnGroup = util.createElement("div",{"class":"card-header btn-group col-12 p-0 bloc_section_btn"});

        var deleteBlockBtn = util.createElement("button",
                                {"type":"button","class":"btn btn-danger mb-2"},
                                null,feather.icons['x'].toSvg());

        var upArrow = util.createElement("span",
                            {"type":"button","class":"mb-2 btn btn-secondary duplicableOnly","multilingual":"ignore","onclick":"etn.asimina.util.onSectionUpDown(this, -1, 'asimina-essential-zone-lang-" + languageId + "')"},
                            null, feather.icons['chevron-up'].toSvg());

        var sortSpan = util.createElement("span", {"type":"button","class":"mb-2 btn btn-secondary duplicableOnly"});
        var sortTextField = util.createElement("input", {"type":"text","class":"sectionOrderInput text-center rounded",
                            "value":"","onkeyup":"allowNumberOnly(this)","onkeydown":"etn.asimina.util.onKeyDownSectionOrder(event)","multilingual":"ignore","onchange":"etn.asimina.util.onChangeSectionOrder(this,0,'asimina-essential-zone-lang-" + languageId + "')"},
                            {"width":"40px"},null);


        var downArrow = util.createElement("span",
                            {"type":"button","class":"mb-2 btn btn-secondary duplicableOnly","multilingual":"ignore","onclick":"etn.asimina.util.onSectionUpDown(this, 1, 'asimina-essential-zone-lang-" + languageId + "')"},
                            null, feather.icons['chevron-down'].toSvg());

        sortSpan.append(sortTextField);

        $(btnGroup).append(collapse.button);
        $(btnGroup).append(upArrow);
        $(btnGroup).append(sortSpan);
        $(btnGroup).append(downArrow);
        $(btnGroup).append(deleteBlockBtn);

        $(divParent).append(btnGroup);
        $(divParent).append(collapse.div);

        $(deleteBlockBtn).on('click',blocks.deleteBlock);

        var text = util.createElement("textarea",{"class":"form-control ckeditor_field","rows":"2","multilingual":"ignore","name":"description_essential_block_text_lang_" + languageId, "id" : util.randomString()});
        $(collapse.div).append(util.getFormRow("Text",text));

        if(blockData){
            if(blockData.blockText) $(text).html(blockData.blockText);
            etn.asimina.images2.add("description_essential_block_image_lang_" + languageId,collapse.div,blockData,"Image");
        }else{
            etn.asimina.images2.add("description_essential_block_image_lang_" + languageId,collapse.div,null,"Image");
        }

        var ckeditorInstance = util.initCkeditor(text);


    };

    var _blocks = {};
    var _count = {};
    blocks.add = function(divParent,languageId,blockData){
        if( typeof _count[languageId] == 'undefined'){
            _count[languageId] = 0;
        }
        var blockId = util.randomString();
        var view = new blockView(blockId,divParent,languageId,blockData);
        _blocks[blockId] = view;
        _count[languageId] = _count[languageId] + 1;
        return blockId;
    };

}( etn.asimina.description_blocks = etn.asimina.description_blocks || {} ,etn.asimina.util ));

//this creates a block of images and manages it through out the page
(function( images ) {

    function createElement(tagName,attr,css,html){
        return etn.asimina.util.createElement(tagName,attr,css,html);
    }


    var imageView = function(id,name,parent,imageData,label){


        function getDefaultImage(){
            return etn.asimina.images2.getDefaultImage();
        }

        function getFileExtension(fileName){
            var parts = fileName.split('.');
            return parts[parts.length - 1];
        }

        function isValidFileType(fileName){
            var extension = getFileExtension(fileName);
            switch (extension.toLowerCase()) {
                case 'jpg':
                case 'gif':
                case 'bmp':
                case 'png':
                    //etc
                    return true;
            }
            return false;
        }

        function addImage(name,data){
            $(imageTag).attr("src",data);
            $(fieldImage).val(data);
            $(fieldName).val(name);
        }



        var divMain = createElement("div",{"class":"form-group row"});
        $(divMain).append('<label for="staticEmail" class="col-sm-3 col-form-label">' + label + '</label>');
        $(divMain).append('<div class="col-sm-9"><div class="card"><div class="card-body text-center"></div><div class="card-footer"></div></div></div>');

        var anchorImage = createElement("a");
        var imageTag = createElement("img",{"class":"card-image-top","src":getDefaultImage()},{"max-width":"200px","max-height":"200px"});
        $(anchorImage).append(imageTag);
        $(divMain).find("div.card-body").append(anchorImage);

        var fieldImage = createElement("input",{"type":"hidden","id":"imageData" + name + id,"name":name + "Data"});
        var fieldName = createElement("input",{"type":"hidden","id":"imageName" + name + id,"name":name + "Name"});
        $(divMain).append(fieldImage);
        $(divMain).append(fieldName);

        var buttonLoadImage = createElement("button",{"type":"button","class":"btn btn-link","id":"loadImageButton" + id},false,'Load Image <span class="oi oi-data-transfer-upload" aria-hidden="true"></span>');
        $(divMain).find("div.card-footer").append(buttonLoadImage);
        $(buttonLoadImage).click(function(e){
            var inputFile = createElement("input",{"type":"file"},{"display":"none"});
            $(divMain).find("div.card-footer").append(inputFile);
            $(inputFile).change(function(e){
                var file = this.files[0];
                if(!file.name){
                    alert("Please provide a file");
                }else if(file.size > 5242880){//5MB
                    alert("Please provide a file smaller than 5MB");
                }else if(!isValidFileType(file.name)){//File Type
                    alert("File type not supported. Please upload a DOC,DOCX,PPT,PPTX,XLS,XLSX,PDF,JPG,BMP,GIF,PNG file.");
                }else{
                    var reader = new FileReader();
                    reader.readAsDataURL(file);
                    reader.onload = function () {
                        addImage(file.name,reader.result);
                    };
                    reader.onerror = function (error) {
                        console.log('Error: ', error);
                    };
                }
                $(inputFile).remove();
            });
            $(inputFile).trigger("click");
        });

        var anchorDeleteImage = createElement("a",{"class":"btn btn-link text-danger"},false,'Delete Image <span class="oi oi-x" aria-hidden="true"> </span>');
        $(anchorDeleteImage).click(function(e){
            $(imageTag).attr("src",getDefaultImage());
            $(fieldImage).val("");
            $(fieldName).val("");
        });
        $(divMain).find("div.card-footer").append(anchorDeleteImage);

        var fieldLabel = createElement("input",{"placeholder":"Alt text","class":"form-control input-sm pull-right","style":"width: 200px;","name":name + "Label","id":"imageLabel" + name + id,"value":"","type":"text","multilingual":"ignore"});
        $(divMain).find("div.card-footer").append(fieldLabel);

        $(parent).append(divMain);
        if(imageData && imageData.image){
            addImage(imageData.actualFileName,imageData.image);
            $(fieldLabel).val(imageData.label);
        }
    };

    var _allImages = {};
    var _data = {};

    function getParentId(divParent){
        var parentId = $(divParent).attr("data-image-parent-id");
        if(!parentId){
            parentId = etn.asimina.util.randomString();
            $(divParent).attr("data-image-parent-id",parentId);
            _data[parentId] = [];
        }
        return parentId;
    }

    function addImage(parentId,name,divParent,imageData,label){
        if(!label){
            label = "Image " + (_data[parentId].length + 1);
        }
        var imageId = etn.asimina.util.randomString();
        var view = new imageView(imageId,name,divParent,imageData,label);
        _allImages[imageId] = view
        _data[parentId].push(view);
        return imageId;
    }

    images.add = function(name,divParent,imageData,label){
        var parentId = getParentId(divParent);
        return addImage(parentId,name,divParent,imageData,label);
    };

    images.addEmpty = function(name,divParent,count){
        var parentId = getParentId(divParent);
        var remaining = count - _data[parentId].length;
        for(var i=0; i < remaining; i++){
            addImage(parentId,name,divParent);
        }
    };

}( etn.asimina.images = etn.asimina.images || {} ));

//AA
//this creates a block of images and manages it through out the page
// v2
(function( images ) {

    function createElement(tagName,attr,css,html){
        return etn.asimina.util.createElement(tagName,attr,css,html);
    }

    function getDefaultImage(){
        return "data:image/png;base64,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";
    }

    images.getDefaultImage = getDefaultImage;

    var imageView = function(isNew,id,name,parent,imageData,label){

        function getFileExtension(fileName){
            var parts = fileName.split('.');
            return parts[parts.length - 1];
        }

        function isValidFileType(fileName){
            var extension = getFileExtension(fileName);
            switch (extension.toLowerCase()) {
                case 'jpg':
                case 'gif':
                case 'bmp':
                case 'png':
                    //etc
                    return true;
            }
            return false;
        }

        function addImage(name,data){
            $(imageTag).attr("src",data);
            $(fieldImage).val(data);
            $(fieldName).val(name);
        }



        var divMain = $(createElement("div",{"class":"form-group row"}));
        divMain.append('<label for="" class="col-sm-3 col-form-label">' + label + '</label>');
        divMain.append('<div class="col-sm-9"><div class="card image_card"><div class="card-body text-center image_body"></div><div class="card-footer image_footer"><div class="form-group row mb-0"><div</div></div></div></div></div>');

        var imageTag = createElement("img",{"class":"card-image-top","src":getDefaultImage()},{"max-width":"200px","max-height":"200px"});
        divMain.find("div.card-body").append(imageTag);

        // var fieldImage = createElement("input",{"type":"hidden","id":"imageData" + name + id,"name":name + "Data"});
        // divMain.append(fieldImage);
        var fieldName = createElement("input",{"type":"hidden","id":"imageName" + name + id,"name":name + "Name", "class" : "image_value"});
        divMain.find('.image_card').append(fieldName);

        var formGroupRow = $('<div class="form-group row mb-0">');
        divMain.find("div.card-footer").append(formGroupRow);

        var buttonLoadImage = createElement("button",{"type":"button","class":"btn btn-link","id":"loadImageButton" + id, "onclick" : "loadFieldImage(this)"},false,'Load Image');
        formGroupRow.append($('<div class="col-6">').append(buttonLoadImage));

        var buttonDeleteImage = createElement("button",{"type":"button","class":"btn btn-link text-danger","id":"loadImageButton" + id},false,'Delete Image');
        formGroupRow.append($('<div class="col-6">').append(buttonDeleteImage));

        $(buttonDeleteImage).click(function(e){
           clearFieldImage(this, getDefaultImage());
        });
        var newImageClass = "";
        if(isNew)	newImageClass  = " unsaved";
        var fieldLabel = createElement("input",{"placeholder":"Alt text","class":"form-control image_alt input-sm pull-right"+newImageClass,"style":"width: 200px;","name":name + "Label","id":"imageLabel" + name + id,"value":"","type":"text","multilingual":"ignore"});
        formGroupRow.append($('<div class="col-12">').append(fieldLabel));
        $(parent).append(divMain);
        if(imageData && imageData.fileName){
        	window.fieldImageDiv = divMain.find('.image_card:first');

            selectFieldImage({
                name    : imageData.fileName,
                label   : imageData.label,
            });
        }
        else {
        	if(isNew){
	        	// <Manufacturer> <product name> <storage> <color>
	         	var lang =  name.charAt(name.length-1);
	    		var l_name = "";
	    		var brandName = "";
	    		if($('#brand_name').length>0) brandName += $('#brand_name').val().trim();
	        	var productName = $('#lang_'+lang+'_name').val().trim();
	        	if(brandName.length>0)	l_name += brandName;
	        	if(productName.length>0){
	        		if(l_name.length>0) l_name += " ";
	        		l_name += productName;
	        	}
	        	$(fieldLabel).val(l_name);
        	}
        }
    };

    var _allImages = {};
    var _data = {};

    function getParentId(divParent){
        var parentId = $(divParent).attr("data-image-parent-id");
        if(!parentId){
            parentId = etn.asimina.util.randomString();
            $(divParent).attr("data-image-parent-id",parentId);
            _data[parentId] = [];
        }
        return parentId;
    }

    function addImage(isNew,parentId,name,divParent,imageData,label){
        if(!label){
            label = "Image " + (_data[parentId].length + 1);
        }
        var imageId = etn.asimina.util.randomString();
        var view = new imageView(isNew,imageId,name,divParent,imageData,label);
        _allImages[imageId] = view
        _data[parentId].push(view);
        return imageId;
    }

    images.add = function(name,divParent,imageData,label){
        var parentId = getParentId(divParent);
        return addImage(false,parentId,name,divParent,imageData,label);
    };

    images.addEmpty = function(name,divParent,count,isNew){
        var parentId = getParentId(divParent);
        var remaining = count - _data[parentId].length;
        for(var i=0; i < remaining; i++){
            addImage(isNew,parentId,name,divParent);
        }
    };

}( etn.asimina.images2 = etn.asimina.images2 || {} ));

(function( langtabs ) {
    var _options = {};
    var _languages = [];
    var _currentIndex = 0;
    var _selectors = ["input[type='text']","input[type=checkbox]","textarea","select","div.asimina-multilingual-block","span"];
    var _firstAnchor;

    function createElement(tagName,attr,css,html){
        return etn.asimina.util.createElement(tagName,attr,css,html);
    }

    function getId(index){
        if(typeof index === 'undefined'){
            index = _currentIndex;
        }
        return _languages[index].languageId;
    }

    function changeLanguage(){
        $("div.multilingual-section").trigger( "etn.asimina.language.change", [ _currentIndex, _languages[_currentIndex], _languages]);
        _selectors.forEach(function(s){

            if(_currentIndex === 0){
                $('#meta_tag_button').show();
            }else{
                $('#meta_tag_button').hide();
            }
            //show but disable fields
            var setDisabled = !(_currentIndex === 0);
            $("div.multilingual-section").find(s).not("[multilingual='ignore']").prop("disabled", setDisabled);

            var selector = s + "[multilingual='true']";
            $("div.multilingual-section").find(selector).each(function(i,o){
                var id = $(o).attr("id");
                var name = $(o).attr("name");
                if(id){
                    for(var i=0; i < _languages.length; i++){
                        id = id.replace(/lang_[0-9]*/g,"lang_" + getId(i));
                        $("#" + id).prop("disabled",false);
                        if(i === _currentIndex){
                            $("#" + id).show();
                        }else{
                            $("#" + id).hide();
                        }
                    }
                }
                else if(name){
                    for(var i=0; i < _languages.length; i++){
                        name = name.replace(/lang_[0-9]*/g,"lang_" + getId(i));
                        $("input[name="+ name+"]").prop("disabled",false);
                           if(i === _currentIndex){
                            $("input[name="+ name+"]").each(function(index, el) {
                              $(el).show();
                            });
                        }else{
                            $("input[name="+ name+"]").each(function(index, el) {
                              $(el).hide();
                            });
                        }
                    }
                }
            });

            etn.asimina.util.setDuplicableSectionOrder($(".asimina-essential-zone-lang-" + _languages[_currentIndex].languageId + ":first"));
            etn.asimina.util.setDuplicableSectionOrder($(".asimina-tab-zone-lang-" + _languages[_currentIndex].languageId + ":first"));
        });
    }


    function setup(){

        var ul = createElement("ul",{"class":"nav nav-tabs","role":"tablist"});

        for(var i=0; i < _languages.length; i++){
            var li = createElement("li",{"class":"nav-item"});
            var a = createElement("a",{"class":"nav-link","id":"home-tab","data-toggle":"tab","href":"#home","role":"tab","aria-controls":"home","aria-selected":"false","data-index":i,"data-language-id":_languages[i].languageId},null,_languages[i].language);
            if(i === 0){
                $(a).addClass("active");
                $(a).attr("aria-selected","true");
                _firstAnchor = a;
            }
            $(a).click(function(e){
                _currentIndex = parseInt($(this).attr("data-index"));
                changeLanguage();
            });
            $(li).html(a);
            $(ul).append(li);
        }
        $(ul).insertBefore("div.multilingual-section");

        var divContent = createElement("div",{"class":"tab-content p-3"});
        var divPane = createElement("div",{"class":"tab-pane fade show active"});
        $(divContent).html(divPane);

        $(divContent).insertBefore("div.multilingual-section");

        $("div.multilingual-section").detach().appendTo(divPane);

        $("div.multilingual-section").closest("form").submit(function(e){
            //since the fields are disabled therefore they are not sent to the server and nothing is saved.
            langtabs.selectFirstLang();
        });

    }

    langtabs.init = function(languages,selectors,options){
        _languages = languages;
        _selectors = _selectors.concat(selectors);
        _options = $.extend(_options,options);
        setup();
        //makeFields();
    };

    langtabs.langs = function(){
        return _languages;
    };

    langtabs.index = function(){
        return _currentIndex;
    };

    langtabs.language = function(){
        return _languages[_currentIndex];
    };

    langtabs.languageId = function(){
        return _languages[_currentIndex].languageId
    };

    langtabs.selectFirstLang = function(){
        if(_firstAnchor){
            $(_firstAnchor).trigger("click");
        }
    }

}( etn.asimina.langtabs = etn.asimina.langtabs || {} ));
//etn.asimina.variants this if for the product variants
(function( variants ) {
    //private variant class that holds all the logic for variant
    var variantView = function(id,selector,variantData,index,isPriceTaxIncluded,taxPercentage,constants){

        function getFormRow(label,fields){
            return etn.asimina.util.getFormRow(label,fields);
        }

        function getHeadingText(name){
           return "Variant " + (index + 1) + (name?": " + name : "");
        }

        function createElement(tagName,attr,css,html,lang){
            if(lang){
                var suffix = "_lang_" + lang.languageId;
                attr["id"] = attr["id"] + suffix;
                attr["name"] = attr["name"] + suffix;
            }
            return etn.asimina.util.createElement(tagName,attr,css,html);
        }

        function getTextField(name,lang){
            return createElement("input",{"class":"form-control","type":"text","id":name + id,"name":name },null,null,lang);
        }

        function getRequiredTextField(name,lang){
            return createElement("input",{"class":"form-control","type":"text","id":name + id,"name":name,"required":"required"},null,null,lang);
        }

        function getSelect(name,options){
            var field = createElement("select",{"class":"custom-select","id":name + id,"name":name});
            setOptions(field,options);
            return field;
        }

        function getRequiredSelect(name,options){
            var field = createElement("select",{"class":"custom-select","id":name + id,"name":name, "required":"required"});
            setOptions(field,options);
            return field;
        }

        function setOptions(field,options){
            if(Array.isArray(options)){
                options.forEach(function(o){
                    $(field).append("<option value='" + o.key + "'>" + o.value + "</option>");
                });
            }
        }

        function getCatalogAttributeOptions(catalogAttributeId){
            var attribValues = [];
            $.each(_options.catalogAttributes, function(i,obj){
                if(obj.id === catalogAttributeId){
                    attribValues = obj.values;
                    return false;
                }
            });

            var options = [];
            options.push({ key : '0', value : '(none)'});
            $.each(attribValues,function(i, value){
                options.push({key : value.id, value : value.attributeValue});
            });
            return options;
        }

        function getCatalogAttributeSelect(catalogAttributeId){
            return getRequiredSelect("variantCatalogAttribute" + catalogAttributeId,getCatalogAttributeOptions(catalogAttributeId));
        }



        function getDetail(lang,key){
            var value = "";
            if(variantData && variantData.details && variantData.details.length){
                variantData.details.forEach(function(detail){
                    if(detail.languageId === lang.languageId){
                        value =  detail[key];
                        return;
                    }
                });
            }
            return value;
        }

        function getValue(key){
            var value = "";
            if(variantData && variantData[key]){
                return value = variantData[key];
            }
            return value;
        }

        function getAttributeValue(catalogAttributeId){
            var value = "";
            if(variantData && variantData.attributes && variantData.attributes.length){
                variantData.attributes.forEach(function(a){
                    if(a.catalogAttributeId === catalogAttributeId){
                        value = a.catalogAttributeValueId;
                        return;
                    }
                });
            }
            return value;
        }

        function setPriceAfterTax(price){
            if(!price || isNaN(parseFloat(price)) ){
                $(fieldPriceAfterTax).val("");
            }else{
                if(isPriceTaxIncluded){
                    $(fieldPriceAfterTax).val(price);
                }else{
                    var priceAfterTax = parseFloat(price);
                    priceAfterTax = (1 + (taxPercentage/100)) * priceAfterTax;
                    $(fieldPriceAfterTax).val(priceAfterTax.toFixed(2));
                }
            }
        }

        function getImageName(languageId){
            return "variantImage" + id + "_lang_" + languageId;
        }

        function deleteVariant(){
            var btn = $(this);
            var btnGroup = btn.parent();
            var collapseId = btnGroup.find("button[data-toggle=collapse]:first").attr('href');
            $(collapseId).remove();
            btnGroup.remove();
        }

        var cardHeading = createElement("div",{"class":"card-header btn-group col-12 variantHeading bloc_section_btn p-0 bg-success","role":"group","aria-label":"Basic example"},{"padding-left":"0px","padding-right":"0px"});

        var buttonHeading = createElement("button",
                                            {"class":"btn btn-link btn-lg btn-block text-left text-white","type":"button","data-toggle":"collapse","data-target":"#collapse" + id,"role":"button","aria-expanded":"false","aria-controls":"collapse" + id},
                                            null,getHeadingText());

        var deleteVariantBtn = createElement("button",
                                {"type":"button","class":"btn btn-danger"},
                                null,feather.icons['x'].toSvg());

        var upArrow = createElement("span",
                            {"type":"button","class":"btn btn-secondary duplicableOnly","multilingual":"ignore","onclick":"etn.asimina.util.onSectionUpDown(this, -1, 'asimina-variant-zone')"},
                            null, feather.icons['chevron-up'].toSvg());

        var sortSpan = createElement("span", {"type":"button","class":"btn btn-secondary duplicableOnly"});
        var sortTextField = createElement("input", {"type":"text","class":"sectionOrderInput text-center rounded",
                            "value":"","onkeyup":"allowNumberOnly(this)","onkeydown":"etn.asimina.util.onKeyDownSectionOrder(event)","multilingual":"ignore","onchange":"etn.asimina.util.onChangeSectionOrder(this,0,'asimina-variant-zone')"},
                            {"width":"40px"},null);


        var downArrow = createElement("span",
                            {"type":"button","class":"btn btn-secondary duplicableOnly","multilingual":"ignore","onclick":"etn.asimina.util.onSectionUpDown(this, 1, 'asimina-variant-zone')"},
                            null, feather.icons['chevron-down'].toSvg());

        sortSpan.append(sortTextField);

        $(deleteVariantBtn).on('click',deleteVariant);

        $(cardHeading).append(buttonHeading);
        $(cardHeading).append(upArrow);
        $(cardHeading).append(sortSpan);
        $(cardHeading).append(downArrow);
        $(cardHeading).append(deleteVariantBtn);

        var fieldDefault = createElement("input",{"type":"radio","id":"variantDefaultRadio" + id,"name":"variantDefaultRadio","aria-label":"Radio button for following text input"});
        $(fieldDefault).click(function(e){
            $("input[name='variantDefault']").val("0");
            $("#variantDefault" + id).val("1");
        });
        var fieldDefaultHidden = createElement("input",{"type":"hidden","id":"variantDefault" + id,"name":"variantDefault","value":"0"});
        if("1" === getValue("isDefault")){
            $(fieldDefault).prop("checked",true);
            $(fieldDefaultHidden).val("1");
        }

        $(cardHeading).append('<div class="input-group-text"/>');
        $(cardHeading).find("div.input-group-text").append(fieldDefault);
        $(cardHeading).find("div.input-group-text").append(fieldDefaultHidden);
        var card = createElement("div",{"class":"card mb-2","id":id})
        var cardBody = createElement("div",{"class":"card-body collapse mb-2","id":'collapse'+id})
        var cardCollapse = createElement("div",{"class":"collapse border-0","id":"collapse" + id});

        var fieldStock = createElement("input",{"type":"hidden","id":"variantStock" + id,"name":"variantStock"});
        $(cardBody).append(fieldStock);

        var isSaved = '0';
        if(variantData)
        	isSaved = '1';
    	var fieldStock = createElement("input",{"type":"hidden","id":"variantSaved" + id,"name":"variantSaved","value":""+isSaved});
        $(cardBody).append(fieldStock);

        var fieldId = createElement("input",{"type":"hidden","id":"variantId" + id,"name":"variantId","value":id});
        $(cardBody).append(fieldId);

        var langs = etn.asimina.langtabs.langs();

        var catalogAtrributeFields = {};

        _options.catalogAttributes.forEach(function(a){
            var field = getCatalogAttributeSelect(a.id);
            $(field).val(getAttributeValue(a.id));
            catalogAtrributeFields[a.id] = field;
            $(cardBody).append(getFormRow(a.name,field));
            $(field).change(function(){
	            if(!variantData){
	            	var brandName = "";
	            	if($('#brand_name').length>0) brandName +=  $('#brand_name').val().trim();
	        		var productName = "";
	        		var v_name = "";
	        		var sku_name = "";

	            	for(var i=0; i<langs.length; i++){
		            	var productName =  $('#lang_'+(i+1)+'_name').val().trim();
	            		v_name = "";
	        			v_name += brandName;
	        			if(productName.length>0){
	        				if(v_name.length>0)v_name += " ";
	        				v_name += productName;
	        			}
			        	_options.catalogAttributes.forEach(function(at){
			        		var attVal = $('#variantCatalogAttribute'+at.id+id+' option:selected').text();
			        		if(attVal.length>0 && attVal != '(none)'){
			        			if(v_name.length>0) v_name += " ";
			        			v_name += attVal;
			        		}
			        	});
	            		$('#variantName'+id+"_lang_"+(i+1)).val(v_name);
	            		if(i == 0){
		            		var headCollapse = $('#variantName'+id+"_lang_"+(i+1)).closest('.collapse').prev();
		            		var varNum =  headCollapse.find('input.sectionOrderInput').first().val();
		            		headCollapse.find('button').first().html("Variant "+varNum+": "+v_name);
	            		}
		            	$(field).parent().parent().parent().find('#divVariantImage'+id+'_lang_'+(i+1)).find('.image_alt').each(function(elem){
		            		$(this).val(v_name);
		            	});
	            		// $('#variantImage'+id+'_lang_'+(i+1)+'Label').val(v_name.replace(/_/g," "));
			        	if(i == 0) sku_name += v_name.replace(/ /g,"_");
	            	}
	            	$('#variantSKU'+id).val(sku_name.replace(/[^\w\s]/gi, ''));
            		$('#variantSKU'+id).next().html("");
            		$('#variantSKU'+id).removeClass("is-invalid");
    	        }
			});
        });
        var fieldNames = [];
        for(var i=0; i < langs.length; i++){
            var fieldName = getTextField("variantName",langs[i]);
            if(i === 0){
                $(fieldName).attr("required","required");
                $(fieldName).attr("multilingual","true");
                $(fieldName).on("input",function(e){
                    $(buttonHeading).html(getHeadingText($(this).val()));
                });
                $(fieldName).on("change",function(e){
                	if($('#brand_name').length <= 0) {
                		if(getDetail(langs[i],"name") == "" ){
	                		$('#variantSKU'+id).val($('#variantName'+id+'_lang_1').val().trim().replace(/ /g,"_").replace(/[^\w\s]/gi, ''));
                		}
                	}
                });
                //set the heading if variant name exists
                $(buttonHeading).html(getHeadingText(getDetail(langs[i],"name")));
            }else{
                $(fieldName).hide();
            }
            if(getDetail(langs[i],"name") == "" ){

				//new variant: suggest name  <Manufacturer> <product name> <storage> <color>
            	var v_name = "";
        		var brandName = "";
        		if($('#brand_name').length>0) brandName += $('#brand_name').val().trim();
            	var productName = $('#lang_'+langs[i].languageId+'_name').val().trim();
            	v_name += brandName;

            	if(productName.length>0){
            		if(v_name.length>0) v_name += " ";
            		v_name += productName;
            	}
            	$(fieldName).val(v_name);
            	if(langs[i].languageId == 1 )
                	$(buttonHeading).html(getHeadingText(v_name));
        		// $(fieldName).closest('.collapse').prev().find('button').first().html(v_name);
            }
            else
            	$(fieldName).val(getDetail(langs[i],"name"));
            fieldNames.push(fieldName);
        }
        $(cardBody).append(getFormRow("Variant name",fieldNames));

        var fieldSKU = getRequiredTextField("variantSKU");
        if(getValue("sku") === ""){
    		var sku_name = "";
        	var brandName = "";
	       	if($('#brand_name').length>0) brandName += $('#brand_name').val().trim();
        	var productName = $('#lang_1_name').val().trim();
        	sku_name += brandName;
        	if(productName.length>0){
        		if(sku_name.length>0) sku_name += "_";
        		sku_name += productName;
        	}
    		$(fieldSKU).val(sku_name.replace(/ /g,"_").replace(/[^\w\s]/gi, ''));
        }
        else
        	$(fieldSKU).val(getValue("sku"));
        $(cardBody).append(getFormRow("SKU",fieldSKU));

        $(fieldSKU).blur(function(e){
            if($(fieldSKU).val()){
                $.ajax({
                    url: 'product_check_sku.jsp',
                    data: {
                        "variant_id":(variantData && variantData.variantId) ? variantData.variantId : "",
                        "sku":$(fieldSKU).val()}
                })
                .done(function(resp) {
                    if(resp){
                        data = JSON.parse(resp);
                        if(data.numberOfRecords > 0){
                            $(fieldSKU).next().html("This SKU already exists");
                            $(fieldSKU).addClass("is-invalid");
                        }else{
                            $(fieldSKU).removeClass("is-invalid");
                        }
                    }
                })
                .fail(function() {
                	if(window.isSavingProduct === true ){
                		console.log('isSavingProduct');
                		return;
                	}
                	else{
                    	alert("Error in contacting server.");
                	}
                })
                .always(function() {

                });
            }else{
                if($(fieldSKU).next().html() === "This SKU already exists"){
                    $(fieldSKU).next().html("");
                }
            }
        });

        var fieldActive = getRequiredSelect("variantActive",[{"key":"0","value":"No"},{"key":"1","value":"Yes"}]);
        $(fieldActive).val(getValue("isActive")=="1"?"1":"0");
        $(cardBody).append(getFormRow("Activated",fieldActive));

        if(constants) {

            var fieldSticker = getRequiredSelect("variantSticker",constants);
            var stickerValue = "";

            constants.forEach(function(constant){

                if(getValue("sticker") == constant["key"])
                    $(fieldSticker).val(constant["key"]);
            });

            $(cardBody).append(getFormRow("Sticker",fieldSticker));

        }


        if(_options.catalogType === "offer"){
            var fieldMainFeatures = [];
            for(var i=0; i < langs.length; i++){
                var lang = langs[i];

                var divMainFeature = createElement("div",{"class":"asimina-multilingual-block","multilingual":"true",id:"divVariantMainFeatures" + id,name : "divVariantMainFeatures"},null,null,lang);

                var variantMainFeature = createElement("textarea",{"id": "variantMainFeatures" + id,"name":"variantMainFeatures","class":"form-control ckeditor_field","rows":"3"},null,null,lang);

                if(i === 0){
                    $(variantMainFeature).attr("multilingual","true");
                }else{
                    $(divMainFeature).hide();
                }
                $(variantMainFeature).val(getDetail(lang,"mainFeatures"));

                $(divMainFeature).append(variantMainFeature);
                fieldMainFeatures.push(divMainFeature);
            };
            $(cardBody).append(getFormRow("Variant main features",fieldMainFeatures));
            $.each(fieldMainFeatures, function(index, field) {

            	var text = $(field).find("textarea").get(0);
				var ckeditorInstance = etn.asimina.util.initCkeditor(text);

            });
        }else{
            langs.forEach(function(lang){
                $(cardBody).append(createElement("input",{"id": "variantMainFeatures" + id,"name":"variantMainFeatures","type":"hidden","class":""},null,null,lang));
            });
        }


        var priceCollapse = etn.asimina.util.getCollapse("collapsePrice" + id,"Price Details");

        var fieldIsShowPrice = createElement("input",{"type":"hidden","id":"variantIsShowPrice" + id,"name":"variantIsShowPrice","value":"1"});
        var checkboxIsShowPrice = createElement("input",{"type":"checkbox","id":"variantIsShowPriceCheckbox" + id,"name":"variantIsShowPriceCheckbox","value":"1"});

        $(checkboxIsShowPrice).on("click",function(){
            var isChecked = $(this).prop("checked");
            if(isChecked){
                $("#variantIsShowPrice"+id).val("1");
                $("#variantPrice"+id).prop("readonly",false);
            }
            else{
                $("#variantIsShowPrice"+id).val("0");
                $("#variantPrice"+id).prop("readonly",true);
            }
        });



        var showPriceDiv = $("<div class='input-group-prepend'>")
                            .append($("<div class='input-group-text'>")
                                .append(fieldIsShowPrice)
                                .append(checkboxIsShowPrice));

        var fieldPrice = getTextField("variantPrice");
        $(fieldPrice).val(getValue("price"));
        $(fieldPrice).on("input",function(e){
            allowFloatOnly(this);
            setPriceAfterTax($(this).val());
        });
        var fieldPriceAfterTax = getTextField("variantPriceAfterTax");
        $(fieldPriceAfterTax).prop("disabled",true)
            .attr("multilingual","ignore")
            .addClass('variantPriceAfterTax');
        //set price after tax
        setPriceAfterTax(getValue("price"));

        var fieldFrequency = getSelect("variantFrequency",etn.asimina.constants.get("product_variant_frequency"));
        $(fieldFrequency).addClass('offer_postpaid_show');

        var frequencyVal = getValue("frequency");
        if(frequencyVal !== ""){
            $(fieldFrequency).val(frequencyVal);
        }

        if( getValue("isShowPrice") == "0" ){
            $(fieldIsShowPrice).val("0");
            $(checkboxIsShowPrice).prop("checked", false);
            $(fieldPrice).prop("readonly",true);
        }
        else{
            $(fieldIsShowPrice).val("1");
            $(checkboxIsShowPrice).prop("checked", true);
            $(fieldPrice).prop("readonly",false);
        }

        $(priceCollapse.body).append(getFormRow("Display / Price / price after tax<span class='offer_postpaid_show' > / frequency</span>",[showPriceDiv,fieldPrice,fieldPriceAfterTax,fieldFrequency]));


        var fieldCommitment = getSelect("variantCommitment",etn.asimina.constants.get("product_variant_commitment",/*(fieldFrequency).val()*/'month'));
        var commitmentVal = getValue("commitment");
        if(commitmentVal  !== ""){
            $(fieldCommitment).val(commitmentVal);
        }
        var commitmentRow = getFormRow("Commitment",fieldCommitment);
        $(commitmentRow).addClass('offer_postpaid_show');
        $(priceCollapse.body).append(commitmentRow);

//        $(fieldFrequency).change(function(e){
//            $(fieldCommitment).html("");
//            setOptions(fieldCommitment,etn.asimina.constants.get("product_variant_commitment",$(fieldFrequency).val()));
//        });
        let priceCard = etn.asimina.util.createElement("div",{class:'card mb-2',title:'price details'});
        let priceCardHeader = etn.asimina.util.createElement("div",{class:'card-header bg-primary p-0'});
        $(priceCard).append(priceCardHeader);
        $(priceCardHeader).append(priceCollapse.button);
        $(priceCard).append(priceCollapse.div);
        $(cardBody).append(priceCard);

        var actionButtonCollapse = etn.asimina.util.getCollapse("collapseActionButton" + id,"Action Button");

        for(var i=0; i < langs.length; i++){
            var divActionButton = createElement("div",{"class":"asimina-multilingual-block","multilingual":"true",id:"divVariantActionButton" + id + "_lang_" + langs[i].languageId}); //we need to give ID to this DIV so that the multilingual control can work.
            if(i > 0){
                $(divActionButton).hide();
            }

            var variantButtonDesktopLabel = createElement("input",{"id": "variantButtonDesktopLabel" + id , "name":"variantButtonDesktopLabel", "class":"form-control "},null,null,langs[i]);
            var variantButtonDesktopUrl = createElement("input",{"id": "variantButtonDesktopUrl" + id, "name":"variantButtonDesktopUrl", "class":"form-control "},null,null,langs[i]);
            var variantButtonMobileLabel = createElement("input",{"id": "variantButtonMobileLabel" + id, "name":"variantButtonMobileLabel", "class":"form-control "},null,null,langs[i]);
            var variantButtonMobileUrl = createElement("input",{"id": "variantButtonMobileUrl" + id, "name":"variantButtonMobileUrl", "class":"form-control "},null,null,langs[i]);

            // var variantButtonDesktopUrlGenerator = createElement("button",{"type":"button", "id": "variantButtonDesktopUrlGenerator", "name":"variantButtonDesktopUrlGenerator","class":"btn btn-success ", "onclick":"actionUrlGenerator('variantButtonDesktopUrl" + id +"_lang_" + langs[i].languageId + "')"},null,null,langs[i]);
            // var variantButtonMobileUrlGenerator = createElement("button",{"type":"button", "id": "variantButtonMobileUrlGenerator", "name":"variantButtonMobileUrlGenerator","class":"btn btn-success ", "onclick":"actionUrlGenerator('variantButtonMobileUrl" + id +"_lang_" + langs[i].languageId + "')"},null,null,langs[i]);

            $(variantButtonDesktopLabel).val(getDetail(langs[i], "actionButtonDesktop"));
            $(variantButtonDesktopUrl).val(getDetail(langs[i], "actionButtonDesktopUrl"));
            $(variantButtonMobileLabel).val(getDetail(langs[i], "actionButtonMobile"));
            $(variantButtonMobileUrl).val(getDetail(langs[i], "actionButtonMobileUrl"));

            var variantButtonDesktopLabelGroup = $("<div class='input-group pb-2'><div class='input-group-prepend'><span class='input-group-text'>Label</span></div></div>");
            variantButtonDesktopLabelGroup.append(variantButtonDesktopLabel);

            var variantButtonMobileLabelGroup = $("<div class='input-group pb-2'><div class='input-group-prepend'><span class='input-group-text'>Label</span></div></div>");
            variantButtonMobileLabelGroup.append(variantButtonMobileLabel);


            $(divActionButton).append(getFormRow("Button desktop / URL",[variantButtonDesktopLabelGroup, variantButtonDesktopUrl]));
            $(divActionButton).append(getFormRow("Button mobile / URL",[variantButtonMobileLabelGroup, variantButtonMobileUrl]));

            var urlGenOpts = {
                showOpenType : true,
                allowEmptyValue : true,
				langId : langs[i].languageId
            };
            var gen1 = etn.initUrlGenerator(variantButtonDesktopUrl, window.URL_GEN_AJAX_URL, urlGenOpts);
            $(variantButtonDesktopUrl).data('url-generator',gen1);
            gen1.getOpenTypeSelect().attr("multilingual",'ignore');

            var gen2 = etn.initUrlGenerator(variantButtonMobileUrl, window.URL_GEN_AJAX_URL, urlGenOpts);
            $(variantButtonMobileUrl).data('url-generator',gen2);
            gen2.getOpenTypeSelect().attr("multilingual",'ignore');

            var OPENTYPE_VALID_VALUES = ["same_window", "new_tab", "new_window"];
            var desktopOpenType = getDetail(langs[i],"actionButtonDesktopUrlOpentype");
            if(OPENTYPE_VALID_VALUES.indexOf(desktopOpenType) >= 0){
            	gen1.getOpenTypeSelect().val(desktopOpenType);
            }
            var mobileOpenType = getDetail(langs[i],"actionButtonMobileUrlOpentype");
            if(OPENTYPE_VALID_VALUES.indexOf(mobileOpenType) >= 0){
            	gen2.getOpenTypeSelect().val(mobileOpenType);
            }

            $(actionButtonCollapse.body).append(divActionButton);
        }

        let actionCard = etn.asimina.util.createElement("div",{class:'card mb-2'});
        let actionCardHeader = etn.asimina.util.createElement("div",{class:'card-header bg-primary p-0'});
        $(actionCard).append(actionCardHeader);
        $(actionCardHeader).append(actionButtonCollapse.button);
        $(actionCard).append(actionButtonCollapse.div);

        $(cardBody).append(actionCard);

        if(variants.getProductType() === "product" || variants.getProductType() === "video"){

            var imagesCollapse = etn.asimina.util.getCollapse("collapseImages" + id,"Images");
            var divImages = {};
            for(var i=0; i < langs.length; i++){
                var divImage = createElement("div",{"class":"asimina-multilingual-block","multilingual":"true",id:"divVariantImage" + id + "_lang_" + langs[i].languageId});//we need to give ID to this DIV so that the multilingual control can work.
                if(i > 0){
                    $(divImage).hide();
                }
                $(imagesCollapse.body).append(divImage);
                divImages[langs[i].languageId] = divImage;
            }

            if(variantData){
                variantData.resources.forEach(function(resource){
                    if(resource.type === "image"){
                        var languageId = resource.languageId;
                        if(languageId && divImages[languageId]){
                            etn.asimina.images2.add(getImageName(languageId),divImages[languageId],resource);
                        }
                    }
                });
            }


            Object.keys(divImages).forEach(function(languageId){
            	if(variantData)
        			etn.asimina.images2.addEmpty(getImageName(languageId),divImages[languageId],3,false);
            	else
            		etn.asimina.images2.addEmpty(getImageName(languageId),divImages[languageId],3,true);
            }); //adds the remaining image blocks upto 3

            if(variants.getProductType() === "video"){
                var fieldVideos = {};
                langs.forEach(function(lang){
                    var fieldVideo = getTextField("variantVideo",lang);
                    $(fieldVideo).attr("multilingual","ignore");
                    $(divImages[lang.languageId]).append(getFormRow("Video URL",fieldVideo));
                    fieldVideos[lang.languageId] = fieldVideo;
                });//add the video fields in the same div so that it can hide and show based on language

                if(variantData){
                    variantData.resources.forEach(function(resource){
                        if(resource.type === "video"){
                            var languageId = resource.languageId;
                            if(languageId && fieldVideos[languageId]){
                                $(fieldVideos[languageId]).val(resource.path);
                            }
                        }
                    });
                }
            }
            let imagesCard = etn.asimina.util.createElement("div",{class:'card mb-2'});
            let imagesCardHeader = etn.asimina.util.createElement("div",{class:'card-header bg-primary p-0'});
            $(imagesCardHeader).append(imagesCollapse.button);
            $(imagesCard).append(imagesCardHeader);
            $(imagesCard).append(imagesCollapse.div);

            // $(cardBody).append(imagesCollapse.button);
            $(cardBody).append(imagesCard);

        }
        $(cardCollapse).append(cardBody);
        $(card).append(cardHeading);
        $(card).append(cardBody);
        $(selector).append(card);

        this.updateCatalogAttributeValues = function(catalogAttributeId){
            if(catalogAtrributeFields[catalogAttributeId]){
                var val = $(catalogAtrributeFields[catalogAttributeId]).val();
                var options = getCatalogAttributeOptions(catalogAttributeId);
                $(catalogAtrributeFields[catalogAttributeId]).html("");
                setOptions(catalogAtrributeFields[catalogAttributeId],options);
                $(catalogAtrributeFields[catalogAttributeId]).val(val);
            }
        }

        this.validate = function(){
            return true;
        };
    };

    //Private Property
    var _data = {};
    var _count = 0;
    var _options = {
        "parent" : "#collapseVariants",
        "catalogAttributes" : []
    };


    variants.getProductType = function(){
        return $('#product_type').val();
    }

    variants.onProductTypeChange = function(){
        if(variants.getProductType() === "offer_postpaid"){
            $('.offer_postpaid_show').show();
            $('.variantPriceAfterTax').removeClass('rounded-right');
        }
        else{
            $('.variantPriceAfterTax').addClass('rounded-right');
            $('.offer_postpaid_show').hide();
        }
    }

    function _add(variantData, constants){
        var id = etn.asimina.util.randomString();

        if (variantData && variantData.variantId) {
            id = variantData.variantId;
        }
        _data[id] = new variantView(id,_options.parent,variantData,_count,
            _options.isPriceTaxIncluded,_options.taxPercentage, constants);
        _count++;
        variants.onProductTypeChange();
        return id;
    }
    //Public Method
    variants.add = function(variantData, constants) {
        return _add(variantData, constants);
    };

    variants.addCatalogAttribute = function(id,name, values){
        _options.catalogAttributes.push({id:id, name:name, values: values});
    };

    variants.init = function(options){
        _options = $.extend(_options,options);
    };

    variants.addAll = function(allVariants, constants){
        allVariants.forEach(function(v){
            _add(v, constants);
        });
    };

    variants.updateCatalogAttributeValues = function(catalogAttributeId){
        for(var id in _data){
            _data[id].updateCatalogAttributeValues(catalogAttributeId);
        }
    };

    variants.validate = function(){
        var isValid = true;
        for(var id in _data){
            if(!_data[id].validate()){
                isValid = false;
            }
        }
        return isValid;
    };
}( etn.asimina.variants = etn.asimina.variants || {} ));
