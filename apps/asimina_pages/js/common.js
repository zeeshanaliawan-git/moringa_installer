//for global variables

function showLoader(msg, ele) {

    if (typeof ele === "undefined") {
        ele = $('body');
    }

    ele.addClass('loading2');

    $(ele).find('div.loading2msg').remove();
    var msgEle = $('<div>').addClass('loading2msg');
    $(ele).append(msgEle);

    if (typeof msg !== 'undefined') {
        msgEle.html(msg);
    }
    else {
        msgEle.html("");
    }

}

function hideLoader() {
    $('.loading2').removeClass('loading2');
}


// simple replace all for javascript for simple strings
//  if searchTerm has regexp special characters
//  use escapeRegExp(str) function to escape it before calling
function strReplaceAll(str, searchTerm, replacement) {

    return str.replace(new RegExp(searchTerm, 'g'), replacement);
}

function escapeRegExp(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); // $& means the whole matched string
}

function escapeDot(str) {
    return strReplaceAll(str, escapeRegExp("."), "\\.");
}

function bootConfirm(message, callback) {
    //callback(result) , where result = true/false

    if(message === null){
        return;
    }
    else if(message.length === 0){
        // stupid bootbox gives exception for empty message
        message = " ";
    }

    bootbox.confirm({
        size: 'small',
        animate: false,
        message: message,
        callback: callback
    });
}

function bootAlert(message, callback, pSize) {
    //NOTE: unlike builtin "alert()" this does not stop execution
    //for workaround, you can use callback
    //callback(result) , where result = true/false

    var size = 'small';
    if (typeof pSize == 'string') {
        size = pSize;
    }

    if(message === null){
        return;
    }
    else if(message.length === 0){
        // stupid bootbox gives exception for empty message
        message = " ";
    }

    bootbox.alert({
        size: size,
        animate: false,
        message: message,
        callback: callback
    });
}

/*
 toast-like , growl-like notification
 which auto close after some time
 */
function bootNotifyError(msg) {
    bootNotify(msg, "danger");
}

function bootNotify(msg, type) {

    if (typeof type == 'undefined') {
        type = "success";
    }

    $.notify({
        message: msg
    },{
        type: type,
        delay: 2000,
        placement: {
            from: "top",
            align: "center"
        },
        offset: {
            y: 10,
        },
        z_index: 1500
    });
}

$ch.pageChanged = false;
function goBack(url, confirm) {
    if (confirm === true || $ch.pageChanged) {
        bootConfirm("your unsaved changes will be lost. are you sure?", function(result) {
            if (result) {
                window.location = url;
                // window.history.back();
            }
        });
    }
    else {
        window.location = url;
        // window.history.back();
    }
}

function getMoment(datetimeStr) {
    return moment(datetimeStr, "DD/MM/YYYY HH:mm:ss");
}



var MAX_FILE_SIZES = {
    "default": 2 * 1024 * 1024, //2 MB in bytes
    "other": 10 * 1024 * 1024, //10 MB in bytes
    "video": 50 * 1024 * 1024, //50 MB in bytes
};

var ALLOWED_TYPES = [];
ALLOWED_TYPES['img'] = ["jpeg", "jpg", "png", "gif", "jpe", "bmp", "tif", "tiff", "dib", "svg", "ico","webp"];
ALLOWED_TYPES['css'] = ["css"];
ALLOWED_TYPES['js'] = ["js"];
ALLOWED_TYPES['fonts'] = ["ttf", "eot", "otf", "svg", "woff", "woff2"];
ALLOWED_TYPES['other'] = ["pdf", "xls", "xlsx", "doc", "docx", "ppt", "pptx", "json", "csv"];
ALLOWED_TYPES['video'] = ["avi", "mov", "mp4", "webm", "flv", "wmv"];
ALLOWED_TYPES['jsx'] = ["jsx","js"];
function validateFileUpload(input, requestType, isRequired) {
    var numFiles = input.get(0).files.length;
    var errorMsg = "";
    var allowedTypes = ALLOWED_TYPES[requestType];

    var maxFileSize = MAX_FILE_SIZES["default"];
    if (typeof MAX_FILE_SIZES[requestType] != 'undefined') {
        maxFileSize = MAX_FILE_SIZES[requestType];
    }

    if (typeof isRequired === 'undefined') {
        isRequired = true;
    }

    if (numFiles > 0) {
        var file = input.get(0).files[0];
        var fileName = file.name;
        var fileType = fileName.substring(fileName.lastIndexOf('.') + 1);
        fileType = fileType.toLowerCase();

        if (numFiles > 1) {
            errorMsg = "Error: Cannot upload more than 1 file. Please select only 1 file.";
        }
        else if (typeof allowedTypes == 'undefined' || allowedTypes.indexOf(fileType) < 0) {
            var fileTypeCaption = "";
            if (requestType === 'img') {
                fileTypeCaption = "image";
            }
            errorMsg = "Error: Unsupported file type. Please select a valid " + fileTypeCaption + " file.";
        }
        else if (file.size > maxFileSize) {
            var maxInMBs = maxFileSize / (1024 * 1024);
            errorMsg = "Error: File size cannot be more than " + maxInMBs + " MB for this type.";
        }

    }
    else if (isRequired) {
        errorMsg = "Error: No file selected.";
    }
    else {
        // no error
    }

    return errorMsg;
}

function onKeyUpFileName(ele){
    $(ele).val($(ele).val().replace(/[^a-zA-Z0-9._\- ]/g,'').replace(/\.+/g,'.'));
}

function showAutocompleteListGeneric(lst,input) {
    var autocompleteList = $(input).closest(".asm-autocomplete").find(".autocomplete-items");
    if(autocompleteList == null || autocompleteList.length == 0 )
    {
        autocompleteList = $("<ul></ul>");
        autocompleteList.addClass("autocomplete-items");
        autocompleteList.css("list-style-type","none");
    }
    else{
        autocompleteList.html("");
    }

    $.each(lst, function(index, obj) {
        const suggestion = $("<li>");
        if(obj.hasOwnProperty("label"))
            suggestion.html(`<a style="cursor:pointer;" value="${obj.label}" ${obj.hasOwnProperty("id")? `data-id="${obj.id}"`: ``}>${obj.label}</a>`);
        else
            suggestion.html(`<a style="cursor:pointer;" value="${obj}">${obj}</a>`);
    
        $(autocompleteList).append(suggestion);
    
        var parent = $(input).closest(".asm-autocomplete");
        var oldAutocompleteList = parent.find('.autocomplete-items');
        if (oldAutocompleteList.length > 0) {
            oldAutocompleteList.remove();
        }
        parent.append(autocompleteList);
    });
}

function autocompleteGeneric(input){
    $(input).on('input', function(event) {
        let inputField = $(this);
        let list = inputField.data("autocomplete-list");
        var sibling = inputField.next("input");
        if(sibling.length > 0) sibling.val("");
        if(list == undefined) return;
        const term = inputField.val().toLowerCase();        
        if(term.length<=1){
            const parent = inputField.closest(".asm-autocomplete");
            if(parent.find(".autocomplete-items")){
                var item = parent.find(".autocomplete-items");
                item.remove();
                return;
            }
        }
                
        var filteredTags = $.grep(list, function(obj) {
            if (obj.hasOwnProperty("label")) {
                return obj.label.toLowerCase().includes(term);
            } else {
                return obj.toLowerCase().includes(term);
            }
        });
        
        showAutocompleteListGeneric(filteredTags,input);
    });

    $(input).on("keydown", function(e) {
        
        if(e.key === "Enter") {
            let inputField = $(this);
            let ele = $(inputField).closest(".asm-autocomplete").find("li.autocomplete-item-highlight");
            if(ele.length > 0) {
                $(inputField).val(ele.find("a").attr("value"));
                var sibling = $(inputField).next("input");
                if(sibling.length > 0)  $(sibling).val(ele.find("a").attr('data-id'));
                const parent = $(inputField).closest(".asm-autocomplete");
                parent.find(".autocomplete-items").empty();
            }
        }
        if(e.key === "Esc") $(inputField).closest(".asm-autocomplete").find(".autocomplete-items").empty();
        if (!(e.key === "ArrowUp" || e.key === "ArrowDown")) return;    
        let $currentItem = $(e.target).closest(".asm-autocomplete").find("li.autocomplete-item-highlight");

        if ($currentItem.length > 0) {
            if (e.key === "ArrowDown") {
                if ($currentItem.next().length > 0) {
                    $currentItem.removeClass("autocomplete-item-highlight");
                    $currentItem.next().addClass("autocomplete-item-highlight");
                }
            } else if (e.key === "ArrowUp") {
                if ($currentItem.prev().length > 0) {
                    $currentItem.removeClass("autocomplete-item-highlight");
                    $currentItem.prev().addClass("autocomplete-item-highlight");
                }
            }
        } else {
            let $autocompleteList = $(e.target).closest(".asm-autocomplete").find("li");
    
            if (e.key === "ArrowDown" && $autocompleteList.length > 0) {
                $autocompleteList.first().addClass("autocomplete-item-highlight");
            } else if (e.key === "ArrowUp" && $autocompleteList.length > 0) {
                $autocompleteList.last().addClass("autocomplete-item-highlight");
            }
        }
    });

    $(document).on('click', '.autocomplete-items li', function(event) {
        const suggestion = $(event.currentTarget).find("a").attr('value');
        let input = $(event.currentTarget).parent().parent().find(".bloc-name");
        $(input).val(suggestion);
        try{
            $(input).trigger('change');
        }catch(e){

        }
        var sibling = $(input).next("input");        
        if(sibling.length > 0)  $(sibling).val($(event.currentTarget).find("a").attr('data-id'));
        const parent = $(input).closest(".asm-autocomplete");
        parent.find(".autocomplete-items").empty();
    });
}

function showAutocompleteList(tags,input,event) {
    var autocompleteList = input.parentElement.querySelector(".autocomplete-items");
    if(autocompleteList==null)
    {
        autocompleteList=document.createElement("ul");
        autocompleteList.classList.add("autocomplete-items");
        autocompleteList.style.listStyleType="none";
    }
    else{
        autocompleteList.innerHTML="";
    }
    tags.forEach(function(tag) {
        const suggestion = document.createElement('li');
    
        const newText = tag.label.replace(
            new RegExp(event.target.value, 'gi'),
            '<span class="ui-state-highlight">$&</span>'
        );

        suggestion.innerHTML = `<a style="cursor:pointer;">${newText}</a>`;

        suggestion.addEventListener('click', function() {
            addTagGeneric(tag, event.target);
            input.value = '';
            autocompleteList.innerHTML = '';
        });
        
        autocompleteList.appendChild(suggestion);
        const parent = input.parentElement;
        const oldAutocompleteList = parent.querySelector('.autocomplete-items');
        if (oldAutocompleteList) {
            parent.removeChild(oldAutocompleteList);
        }
        parent.appendChild(autocompleteList);
    });
}

function removeFromList(input){
    input.innerHTML="";
}

function setupAutocomplete(input) {
    input.addEventListener('input', function(event) {
        const term = event.target.value.toLowerCase();
        if(term.length<1){
            const parent = input.parentElement;
            if(parent.querySelector(".autocomplete-items")){
                parent.removeChild(parent.querySelector(".autocomplete-items"));
                return;
            }
        }
        const filteredTags = window.allTagsList.filter(function(tag) {
            return tag.label.toLowerCase().includes(term);
        });
        showAutocompleteList(filteredTags,input,event);
    });
}
  

function initTagAutocomplete(input, isRequired) {
    let folderIds = $(input).data("folders-id");
    if(folderIds==undefined || folderIds==null){
        foldersId="all";
    }
    $.ajax({
        url: 'blocTemplatesAjax.jsp',
        type: 'POST',
        dataType: 'json',
        data: {
            requestType: 'getAllTagsJson',
            folderIds : folderIds,
        },
    })
    .done(function(resp) {
        if (resp.status == 1) {
            window.allTagsList = resp.data.tags;
        }
    });
    Array.from(input).forEach((e)=>{
        setupAutocomplete(e);
        if (isRequired === true) {
            e.classList.add('requiredInput');
        }    
    });
}

function getTagsDivGeneric(input) {
    input = $(input);
    var tagsDiv = input.parent().find(".tagsDiv:first");
    if (tagsDiv.length == 0) {
        tagsDiv = input.parent().parent().find(".tagsDiv:first");
    }
    return tagsDiv;
}

function removeTag(ele)
{   
    let tag = $(ele).closest("span.badge-tag");
    tag.remove();
}

function makeTagDivs(tag, input,isNewProductTag,langIndex){
    let tagsDiv = getTagsDivGeneric(input.parent().parent());
    let nbItems = input.data("data-nb-items");
    if(nbItems && nbItems != 0){
        if(tagsDiv.find("span.badge-tag").length >= nbItems){
            return;
        }
    }

    let _tagpillid = `_tagpill${tagsDiv.find("span.badge-tag").length}`;
    
    let pill = $('<span></span>', { class: 'badge badge-pill badge-dark badge-tag mb-2 mr-2'});
    pill.attr("data-tag_pillid",_tagpillid);
    
    pill.append($(`<a></a>`,{ 
            class:'badge badge-pill badge-white ml-2', 
            html: '<i data-feather="x" style="color:#f16e00"></i>'
        }).on("click",function(){
            let input = $(this).closest(".tagsDiv").parent().parent().find("input.tagInputField");
            if(isNewProductTag){
                let langContentDivs = $ch.langContentDivs;
                langContentDivs.each(function (indexLang, langContent) {
                    let currentLangId = $(langContent).attr("data-lang-id");
                    let tagInput = $(`#langTabContent_${currentLangId}`).find(`input[name="${$(input).attr("name")}"]`);
                    if($(input).attr("name").includes("variant")) tagInput = getLangTagField(input,currentLangId);
                        
                    removeTag(tagInput.parent().siblings(".tagsDiv").find(`span[data-tag_pillid="${_tagpillid}"]`).find("input[type='hidden']"));
                    updateTagsRequiredGeneric(tagInput);
                });
            }else{
                removeTag(this);
                updateTagsRequiredGeneric(input);
            }
    }));

    let tagContent = tag.label.split("/");
    if(tagContent.length>1){
        let folderSpan = $(`<span></span>`,{class: "badge-folder pr-1"});
        folderSpan.text(tagContent[0]+" /");
        pill.find("a").first().before(folderSpan);
        pill.find("a").first().before(tagContent[1]);        
    }
    else{
        pill.find("a").first().before(tagContent);
    }
    
    pill.find("a").first().append(`<input type='hidden' class='tagValue' name='tagValue' value='${tag.id}'>`);
    let pillClone = pill.clone();
    pillClone.find("a").remove();
    pillClone.addClass("py-2");
    
    if(langIndex > 0) { 
        pill.find("a").addClass("d-none");
        pill.find("i").remove();
        pill.addClass("py-2 px-2");
    }
    tagsDiv.append(pill);
    $("._secondaryTagsDiv").append(pillClone);
    feather.replace();
}

function addTagGeneric(tag, input) {

    if (typeof tag == 'string') {
        var tagFound = false;
        $.each(window.allTagsList, function(index, curTag) {
            if (tag === curTag.id) {
                tag = curTag;
                tagFound = true;
                return false;
            }
        });

        if (!tagFound) return false;
    }
    
    let inputName = $(input).attr("name");
    if(inputName==="product_general_informations.product_general_informations_tags" || inputName==="product_variants_variant_x.product_variants_variant_x_tags"){
        var langContentDivs = $ch.langContentDivs;

        langContentDivs.each(function (indexLang, langContent) {
            let currentLangId = $(langContent).attr("data-lang-id");
            let tagInput = $("#langTabContent_" + currentLangId).find("input[name='" + inputName + "']");
            if(inputName.includes("variant")) tagInput = getLangTagField(input,currentLangId);

            if (!tagExistsGeneric(tag, tagInput)) {
                makeTagDivs(tag, tagInput,true,indexLang);
            }
            updateTagsRequiredGeneric(tagInput);
        });
    }else{
        if (!tagExistsGeneric(tag, input)) makeTagDivs(tag, $(input));
        updateTagsRequiredGeneric(input);
    }
}

function getLangTagField(input,currentLangId){
    let inputName = $(input).attr("name");
    let sectionNum = $(input).parent().parent().parent().parent().parent().attr("id").split(".")[2].split("_")[5];
    return $(`[id='langContent_${currentLangId}.section_product_variants_1.section_product_variants_variant_x_${sectionNum}']`).find(`input[name='${inputName}']`);
}

function tagExistsGeneric(tag, input) {
    input = $(input);
    var tagsDiv = getTagsDivGeneric(input);

    var doesTagExist = false;
    tagsDiv.find("input.tagValue").each(function(i, ele) {
        if ($(ele).val() === tag.id) {
            doesTagExist = true;
            return false;
        }
    });
    return doesTagExist;
}

function removeAllTagsGeneric(input) {
    input = $(input);
    var tagsDiv = getTagsDivGeneric(input);

    tagsDiv.html('');
    $("._secondaryTagsDiv").html('');
    updateTagsRequiredGeneric(input);
}


function updateTagsRequiredGeneric(input) {
    input = $(input);
    if (input.hasClass('requiredInput')) {
        var tagsDiv = getTagsDivGeneric(input);
        var tagsCount = tagsDiv.find('input.tagValue').length;
        if (tagsCount > 0) {
            input.get(0).setCustomValidity("");
        } else {
            input.get(0).setCustomValidity("required");
        }
    }
}


//----
// for media library images
// field image loader functions, used in templateEditor and blocEditor

let popup;
let chkInterval;

function loadFieldImageV2(button,isEdit,fieldId,mediaType){
    button = $(button);
    let imageLangId = button.data("langId");
    let imageCard = button.closest(".image_card");
    let cardBody = imageCard.find('.card-body');
    let uiStateMediaDefault = $(`<span class="ui-state-media-default mx-1" style="padding:0px;display: inline-block;">
        <div class="bloc-edit-media">
            <button type="button" class="btn btn-primary mx-1" style="margin-right: .10rem;" onclick='loadFieldImageV2(this,true,"${fieldId? fieldId : "image"}")'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
            <button type="button" class="btn btn-danger mx-1" style="margin-right: .1rem;" onclick='clearFieldImageV2(this)'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></button>
        </div>
        <div class="bloc-edit-media-bgnd" style="height:100%; width:100%; min-width:145px; min-height:145px; position:absolute; left:0; top:0">&nbsp;</div>
        <input type="hidden" name="${fieldId? fieldId : "image"}_value${imageLangId? "_"+imageLangId : ""}" class="image_value" />
        <input type="hidden" name="${fieldId? fieldId : "image"}_alt${imageLangId? "_"+imageLangId : ""}" class="image_alt" />
        <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="">
    </span>`);

    if(!isEdit) uiStateMediaDefault.insertBefore(cardBody.find(".ui-state-media-default:last"));
    window.fieldImageDivV2 = (!isEdit)? uiStateMediaDefault : button.closest(".ui-state-media-default");

    var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
    prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
    var winWidth = $(window).width() - 200;
    if( winWidth < 1000 ) {
        winWidth = 1000;
    }
    var winHeight = $(window).height() - 400;
    if( winHeight < 600 ) {
      winHeight = 600;
    }
    prop += ",width="+winWidth + ",height=" + winHeight;

    let fileTypes = "img,video";
    if(mediaType == "video") fileTypes = "video";
    else if(mediaType == "img") fileTypes = "img";

    var mediaLibraryUrl = "mediaLibrary.jsp?popup=1" + (fileTypes.length > 0 ? "&fileTypes="+fileTypes : "");
    popup = window.open(mediaLibraryUrl, "mediaLibrary", prop);
    popup.isImageFieldV2 = true;
    popup.focus();   
    chkInterval = setInterval(checkIfPopUpWinClosed,1000); 
}

function checkIfPopUpWinClosed()
{
    if(popup.closed)
    {   
        
        if(window.fieldImageDivV2.find("input.image_value").val().length == 0){
            window.fieldImageDivV2.remove();
        }
        
        let imageCard = (window.fieldImageDivV2.find(".image_card").length>0)? window.fieldImageDivV2.find(".image_card") : window.fieldImageDivV2.closest(".image_card");
        let imgLimit = (imageCard.data("img-limit")? imageCard.data("img-limit") : 1);
        if(imageCard.find("input.image_value").length <= imgLimit){
            imageCard.closest(".row").find(".img-count").text(imageCard.find("input.image_value").length);
            if(imageCard.find("input.image_value").length >= imgLimit){
                let mediaDefault = imageCard.find(".ui-state-media-default:last");
                mediaDefault.find(".load-img").hide();
                mediaDefault.find(".no-img").show();
            }            
        }
        else{
            window.fieldImageDivV2.remove();
        }
        clearInterval(chkInterval); 
    }
}

function createThumbnail(imgfield, videoSrc) {
    console.log(videoSrc);
    
    let video = $('<video />').attr('src', videoSrc)[0]; 

    let canvas = $('<canvas id="myCanvas"></canvas>').hide();
    let context; 

    $('body').append(canvas);

    $(video).on('loadedmetadata', function() {
        canvas.attr({
            width: video.videoWidth,
            height: video.videoHeight
        });
        
        let midTime = video.duration / 2;
        video.currentTime = midTime;
    });

    $(video).on('loadeddata', function() {
        context = canvas[0].getContext('2d');
        context.drawImage(video, 0, 0, canvas.width(), canvas.height());
        let thumbnailData = canvas[0].toDataURL('image/png');
        imgfield.attr('src', thumbnailData);
        $(canvas).remove(); 
        video.remove(); 
    }, { once: true });

    video.load();
}

function selectFieldImageV2(imgObj,fieldId,mediaType,toAdd)
{
	if(!window.MEDIA_LIBRARY_IMAGE_URL_PREPEND)
    {
		window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = '';
	}

    let imgCard = window.fieldImageDivV2.find(".image_card");
    if(imgCard.length == 0) imgCard = window.fieldImageDivV2.closest(".image_card");
    
    if(imgCard.find(".ui-state-media-default").not(":last").length == 0 || toAdd) {
        
        let uiStateMediaDefault = $(`<span class="ui-state-media-default mx-1" style="padding:0px;display: inline-block;">
            <div class="bloc-edit-media">
                <button type="button" class="btn btn-primary mx-1" style="margin-right: .10rem;" onclick='loadFieldImageV2(this,true,"${fieldId? fieldId : "image"}")'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
                <button type="button" class="btn btn-danger mx-1" style="margin-right: .1rem;" onclick='clearFieldImageV2(this)'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></button>
            </div>
            <div class="bloc-edit-media-bgnd" style="height:100%; width:100%; min-width:145px; min-height:145px; position:absolute; left:0; top:0">&nbsp;</div>
            <input type="hidden" name="${fieldId? fieldId : "image"}_value" class="image_value" />
            <input type="hidden" name="${fieldId? fieldId : "image"}_alt" class="image_alt" />
            <img class="card-image-top" style="margin:2px 0px 2px 0px;width:145px;height:145px; object-fit:cover;" src="">
        </span>`);
    
        uiStateMediaDefault.insertBefore(imgCard.find(".ui-state-media-default:last"));
    }

    let uiStateMediaDefault = imgCard.find('input.image_value:last').closest(".ui-state-media-default");
    var name = imgObj.name;
    var label = imgObj.label;
    var altName = imgObj.altName;
    var image_value = uiStateMediaDefault.find("input.image_value");
    var dimension = imgObj.dimension;
    image_value.val(name);
    
    if(name.length > 0)
    {
        if(!mediaType || mediaType == "image"){
            if(dimension && dimension.length>0){
                uiStateMediaDefault.find('img.card-image-top').attr('src', window.IMAGE_URL_PREPEND+dimension+"/" + name);
            }else{
                uiStateMediaDefault.find('img.card-image-top').attr('src', window.IMAGE_URL_PREPEND + name);
            }
        }else {
            createThumbnail(uiStateMediaDefault.find('img.card-image-top'),window.MEDIA_LIBRARY_UPLOADS_URL+"/"+mediaType.toLowerCase()+"/"+ name);
        }
    }
        
    var image_alt = uiStateMediaDefault.find('input.image_alt');
    if(image_alt.length > 0)  
    if(image_alt.val().length == 0)
    {
        if(altName && altName.length>0){
            image_alt.val(altName);
        }else{
            image_alt.val(label);
        }
    }    

    $.each(imgCard.find("input.image_value[value='']"),function(idx,el){ $(el).closest(".ui-state-media-default").remove() });    

    imgCard.closest(".row").find(".img-count").text(imgCard.find("input.image_value").length);
    if(imgCard.data("img-limit") > imgCard.find("input.image_value").length) {
        imgCard.find(".ui-state-media-default:last").find(".load-img").show();
        imgCard.find(".ui-state-media-default:last").find(".no-img").hide();
    }else if(imgCard.data("img-limit") <= imgCard.find("input.image_value").length)
    {
        imgCard.find(".ui-state-media-default:last").find(".load-img").hide();
        imgCard.find(".ui-state-media-default:last").find(".no-img").show();
    }
    
    updateFieldImageRequiredStatusV2(window.fieldImageDivV2,toAdd);
}

function clearFieldImageV2(button){
    button = $(button);
    let row = button.closest(".row");
    var imageDiv = button.closest('.ui-state-media-default');    
    imageDiv.remove();    
    row.find(".img-count").text(row.find("input.image_value").length);
    let imgCard = row.find(".image_card");
    if(imgCard.length == 0) imgCard = row.closest(".image_card");

    if(imgCard.data("img-limit") > imgCard.find("input.image_value").length)
    {
        imgCard.find(".ui-state-media-default:last").find(".load-img").show();
        imgCard.find(".ui-state-media-default:last").find(".no-img").hide();   
    }
    updateFieldImageRequiredStatusV2(imageDiv);
}

function loadFieldImage(button) {
    button = $(button);
    window.fieldImageDiv = button.parents('.image_card:first');

    var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
    prop += "scrollbars=yes, menubar=no, location=no, statusbar=no";
    var winWidth = $(window).width() - 200;
    if (winWidth < 1000) {
        winWidth = 1000;
    }
    var winHeight = $(window).height() - 400;
    if (winHeight < 600) {
        winHeight = 600;
    }
    prop += ",width=" + winWidth + ",height=" + winHeight;

    var win = window.open('mediaLibrary.jsp?popup=1', "mediaLibrary", prop);
    win.focus();
}

function selectFieldImage(imgObj) {

    var name = imgObj.name;
    var label = imgObj.label;
    var altName = imgObj.altName;
    var dimension = imgObj.dimension;

    var image_value = window.fieldImageDiv.find('.image_value');
    image_value.val(name).trigger('change');

    if (name.length > 0) {
        if(dimension && dimension.length>0){
            window.fieldImageDiv.find('.image_body img').attr('src', window.IMAGE_URL_PREPEND+dimension+"/" + name);
        }else{
            window.fieldImageDiv.find('.image_body img').attr('src', window.IMAGE_URL_PREPEND + name);
        }
    }

    var image_alt = window.fieldImageDiv.find('.image_alt:first');
    if (image_alt.val().length == 0) {
        if(altName && altName.length>0){
            image_alt.val(altName);
            // image_alt.focus();
        }else{
            image_alt.val(label);
            // image_alt.focus();
        }
    }

    updateFieldImageRequiredStatus(window.fieldImageDiv);
}

function clearFieldImage(button) {
    button = $(button);
    var imageDiv = button.parents('.image_card:first');

    imageDiv.find('[name=image_value],[name=image_alt]').val('');
    imageDiv.find('input.image_value,input.image_alt').val('');
    imageDiv.find('.image_body img').attr('src', '');
    updateFieldImageRequiredStatus(imageDiv);
}

function updateFieldImageRequiredStatus(imageDiv,isCreateing) {

    if (!imageDiv.hasClass('image_card')) {
        imageDiv = imageDiv.find('.image_card:first');
    }

    var image_value = imageDiv.find('.image_value');
    if (image_value.hasClass('requiredInput')) {
        if (image_value.val().trim() === "") {
            if(!isCreateing) imageDiv.addClass('border-danger');
            imageDiv.find('.image_alt').get(0).setCustomValidity("required");
        }
        else {
            imageDiv.removeClass('border-danger');
            imageDiv.find('.image_alt').get(0).setCustomValidity("");
        }
    }
}

function updateFieldImageRequiredStatusV2(imageDiv,isCreating) {
    if (!imageDiv.hasClass('image_card')) {
        imageDiv = imageDiv.find('.image_card:first');
    }

    var image_value = imageDiv.find('input.image_value');
    if (imageDiv.hasClass('requiredInput')) {
        if (image_value.length > 0){
            if (image_value.val().trim() === "") {
                if(!isCreating) {
                    imageDiv.addClass('border-danger');    
                }
            }
            else {
                imageDiv.removeClass('border-danger');                
            }
        }
        else {
            if(!isCreating){ 
                imageDiv.addClass('border-danger');    
            }
        }
    }
}

function setImageFormField(imgObj, imgValueInput){
    var imageDiv = imgValueInput.parents('.image_card:first');
    if(imageDiv.length > 0){
        window.fieldImageDiv = imageDiv;
        selectFieldImage(imgObj);
    }
}

//----
// field file loader functions, used in templateEditor and blocEditor,structuredEditor

function loadFieldFileV2(button) {
    button = $(button);
    window.fieldFileDivV2 = button.parents('.file_card:first');

    var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
    prop += "scrollbars=yes, menubar=no, location=no, statusbar=no";
    var winWidth = $(window).width() - 200;
    if (winWidth < 1000) {
        winWidth = 1000;
    }
    var winHeight = $(window).height() - 400;
    if (winHeight < 600) {
        winHeight = 600;
    }
    prop += ",width=" + winWidth + ",height=" + winHeight;

    var win = window.open('mediaLibrary.jsp?popup=1&fileTypes=other', "mediaLibrary", prop);
    win.focus();
}

function selectFieldFileV2(imgObj) {

    var name = imgObj.name;

    window.fieldFileDivV2.find('input.file_value').val(name).trigger('change');
}

function clearFieldFileV2(button) {
    button = $(button);
    var fileDiv = button.parents('.file_card:first');

    fileDiv.find('input.file_value').val('');
}


function loadFieldFile(button) {
    button = $(button);
    window.fieldFileDiv = button.parents('.file_card:first');

    var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
    prop += "scrollbars=yes, menubar=no, location=no, statusbar=no";
    var winWidth = $(window).width() - 200;
    if (winWidth < 1000) {
        winWidth = 1000;
    }
    var winHeight = $(window).height() - 400;
    if (winHeight < 600) {
        winHeight = 600;
    }
    prop += ",width=" + winWidth + ",height=" + winHeight;

    var win = window.open('mediaLibrary.jsp?popup=1&fileTypes=other,video', "mediaLibrary", prop);
    win.focus();
}

function selectFieldFile(imgObj) {

    var name = imgObj.name;

    window.fieldFileDiv.find('input.file_value').val(name).trigger('change');
}

function clearFieldFile(button) {
    button = $(button);
    var fileDiv = button.parents('.file_card:first');

    fileDiv.find('input.file_value').val('');
}


//----
// "date" field functions , used in templateEditor and blocEditor, etc
function formatBlockDate(dateInput, dateFormat){
    if(dateInput.val().trim().length>0){
        if(dateFormat == "date_time"){
            var date = moment(dateInput.val(),  "YYYY-MM-DD HH:mm",true);
            if(date.isValid()){
                return dateInput.val(date.format(getDateTimeFormat(dateFormat)));
            }
        }else if(dateFormat == "date")
        {
            date = moment(dateInput.val(),  "YYYY-MM-DD",true);
            if(date.isValid()){
                return dateInput.val(date.format(getDateTimeFormat(dateFormat)));
            }
        }else{
            date = moment(dateInput.val(),  "HH:mm",true);
            if(date.isValid()){
                if(dateFormat != "time")
                    return dateInput.val("");
                else
                    return dateInput.val(date.format(getDateTimeFormat(dateFormat)));
            }else{
                return dateInput.val("");
            }
        }
    }
}

function getDateTimeFormat(formatDateInWords){
    if(formatDateInWords == "date_time"){
        return "YYYY-MM-DD HH:mm";
    }else if (formatDateInWords == "date"){
        return "YYYY-MM-DD";
    }else if(formatDateInWords == "time"){
        return "HH:mm"
    }
}

function initDatetimeFields(dateInputStart, dateInputEnd, dateType, dateFormat) {
    const isDateEndValid = (typeof dateInputEnd !== 'undefined' && dateInputEnd !== null);
    dateInputStart = jQuery(dateInputStart);
    formatBlockDate(dateInputStart, dateFormat);
    const originalStartDateValue = dateInputStart.val();
    dateInputStart.flatpickr().destroy();
    dateInputStart.data('validated', false);

    if (isDateEndValid) {
        dateInputEnd = jQuery(dateInputEnd);
        formatBlockDate(dateInputEnd, dateFormat);
        dateInputEnd.flatpickr().destroy();
        dateInputEnd.data('validated', false);
    }

    var options = {
        step: 1, 
        defaultSelect: false,
        allowInput:true,
        scrollMonth: true,
        scrollInput: false,
        enableTime : true,
        time_24hr : true,
        minuteIncrement : 5,    
        onGenerate: function(curTime, $input) {

            var clearBtn = $(this).find('.clearBtn');
            if (clearBtn.length == 0) {
                var homeButton = $(this).find('.xdsoft_today_button');
                homeButton.addClass('clearBtn')
                    .text('clear')
                    .click(function() {
                        $($input).val('');
                    });
            }

            if (!$($input).data('validated')) {
                $($input).data('validated', true);
                jQuery($input).flatpickr('validate');
            }
        },
    };


    if (dateFormat == 'date_time') {
        options.dateFormat = 'Y-m-d H:i';
    }
    else if(dateFormat == 'time') {
        options.dateFormat = 'H:i';
        options.noCalendar = true;
    }
    else {
        options.dateFormat = 'Y-m-d';
        options.enableTime = false;
    }

    if(dateType == 'period' && dateFormat !== 'time'){
        options.mode = 'range';
   }

    if(originalStartDateValue.length>0) options.defaultDate = originalStartDateValue;
    dateInputStart.flatpickr(options);

    if (isDateEndValid) {
        const originalEndDateValue = dateInputEnd.val();
        if(originalEndDateValue.length>0) options.defaultDate = originalEndDateValue;
        dateInputEnd.flatpickr(options);
    }
}


//----
// "date"
$ch.aceEditorsList = [];
$ch.templateFieldsList = [];
function initAceEditor(editorId, extraOptions){

    if(typeof $ch.aceLangTools === 'undefined'){
        //first time initialization
        $ch.aceLangTools = ace.require("ace/ext/language_tools");
        var templateFieldsCompleter = {
            getCompletions: function(editor, session, pos, prefix, callback) {

                if($ch.templateFieldsList.length == 0){
                    callback(null, []);
                    return;
                }

                // callback(null, wordList.map(function(ea) {
                //             return {
                //                 name: ea.word,
                //                 value: ea.word,
                //                 score: ea.score,
                //                 meta: "rhyme"
                //             }
                //         }));
                callback(null, $ch.templateFieldsList);
            }
        };
        $ch.aceLangTools.addCompleter(templateFieldsCompleter);
    }

    var aceCommonOptions = {
        minLines: 10,
        showPrintMargin : false,
        autoScrollEditorIntoView: true,

        enableBasicAutocompletion : true,
        enableLiveAutocompletion : true,
        enableSnippets : true,

        // maxLines: 30,
        // theme : "ace/theme/github",
    };


    var aceOptions = $.extend(extraOptions, aceCommonOptions);
    var editor = ace.edit(editorId, aceOptions);
    $ch.aceEditorsList.push(editor);

    return editor;
}

function setAceEditorTheme(theme){
    if(theme == 'light'){
        theme = 'ace/theme/textmate';
    }
    else{
        theme = 'ace/theme/monokai';
    }

    $ch.aceEditorsList.forEach(function(editor){
        editor.setTheme(theme);
    });
}

function showAceEditorSettings(){
    var visibleEditor = null;
    $ch.aceEditorsList.forEach(function(editor) {
        if($(editor.container).is(':visible')){
            visibleEditor = editor;
        }
    });

    if(visibleEditor != null){
        visibleEditor.execCommand('showSettingsMenu');
    }
}

function copyInputToClipboard(inputSelector) {
    var input = $(inputSelector);
    if(input.length == 0) return;
    input = input.get(0);
    input.select();
    input.setSelectionRange(0, 99999); /* For mobile devices */
    /* Copy the text inside the text field */
    navigator.clipboard.writeText(input.value);
    // input.blur();
}


// used in bloc and structured contents/pages to focus on
// required or invalid fields of templates
function focusOnErrorField(errorFields, container) {
    //open collapse parents to make visible and focus first invalid field
    var focusErrorField = function(curEl) {
        curEl = $(curEl);
        if (curEl.is(':visible')) {
            curEl.focus();
        }
        else {
            var scrollOffset = (curEl.parents('.fieldDiv:first').offset().top - 50.0);
            container.scrollTop(scrollOffset);
        }

    };

    $(errorFields).each(function(index, el) {
        el = $(el);
        var collapseParents = el.parents('.collapse');

        if (index == 0) {
            focusErrorField(el);

            if (collapseParents.length > 0) {
                collapseParents.on('shown.bs.collapse', function() {
                    $(this).off('shown.bs.collapse');
                    focusErrorField(errorFields[0]);
                });
            }
        }

        if (collapseParents.length > 0) {
            collapseParents.collapse('show');
        }
    });
}

// add on keyup="allowNumberOnly(this)"
function allowNumberOnly(ele) {
    $(ele).val($(ele).val().replace(/[^\d]/g, ''));
}

// Usage:
// add on keyup="allowFloatOnly(this)"
// add on onblur or onchange ="allowFloatOnly(this, true)"
function allowFloatOnly(ele, useParseFloat) {
    var val = $(ele).val().replace(/[^\d.,]/g, '');
    if($(ele).val().indexOf("-")==0){
        val="-"+val;
    }
    //keep only one decimal point, remove extras
    if (val.indexOf(".") >= 0) {
        var valArr = val.split(".");
        val = valArr[0] + "." + valArr.splice(1).join("");
    }
    if (val.indexOf(",") >= 0) {
        var valArr = val.split(",");
        val = valArr[0] + "." + valArr.splice(1).join("");
    }

    if (typeof useParseFloat !== 'undefined') {
        var floatVal = parseFloat(val);
        if (isNaN(floatVal)) {
            val = ""
        }
        else {
            val = floatVal;
        }
    }

    $(ele).val(val);
}

// add on keyup="allowAphabetsOnly(this)"
function allowAphabetsOnly(ele) {
    $(ele).val($(ele).val().replace(/[^a-zA-Z]/g, ''));
}

// add on keyup="allowAphaNumericOnly(this)"
function allowAphaNumericOnly(ele) {
    $(ele).val($(ele).val().replace(/[^a-zA-Z0-9]/g, ''));
}

// for url generator

function openUrlGenerator(inputId) {
    var generatorUrl = window.CATALOG_ROOT + 'admin/urlgenerator.jsp?isprod=1&fid=' + inputId;

    var win = window.open(generatorUrl, generatorUrl);
    win.focus();
}

function seturl(id, url) {
    url = url.substring(url.indexOf('//') + 2);
    url = url.substring(url.indexOf('/'));
    $('#' + id).val(url);
}


function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

function onKeyupCustomId(input) {
    var val = $(input).val();

    // custom id cannot start with number
    // it causes problems in bloc freemarker processing
    // remove starting number
    var startWithDigitRegex = new RegExp(/^\d/);
    while (startWithDigitRegex.test(val)) {
        val = val.substring(1);
    }

    val = val.replace(/\s+/g, "_").replace(/[^a-zA-Z0-9_]/g, '').toLowerCase();

    //custom id should not end with _<number>
    while (true) {
        if (val.lastIndexOf("_") >= 0) {
            var testStr = val.substring(val.lastIndexOf("_"));
            if (/_[\d]+$/g.test(testStr)) {
                val = val.substring(0, val.lastIndexOf("_"));
            }
            else {
                break;
            }
        }
        else {
            break;
        }
    }

    $(input).val(val);
}

// for pages path field
function onPathKeyup(input, toLower) {
    input = $(input);

    var start = input.get(0).selectionStart;
    var end = input.get(0).selectionEnd;

    var val = input.val();
    var initLength = val.length;
    val = val.trimLeft()
        .replace(/\s/g, "-")
        .replace(/[^a-zA-Z0-9\/-]/g, '')
        .replace('/-', '/')
        .replace('--', '-');
    if (val.startsWith("-")) {
        val = val.substring(1);
    }
    input.val(val);
    pathToLowerCase(input, toLower);
    //preserving cursor position
    var curLength = input.val().length;
    if (curLength != initLength) {
        var lengthDiff = initLength - curLength;
        input.get(0).setSelectionRange(start - lengthDiff, end - lengthDiff);
    }
    else {
        input.get(0).setSelectionRange(start, end);
    }
}

// for pages path field
function onPathBlur(input, toLower) {
    input = $(input);
    var val = input.val();

    if (val.startsWith("/")) {
        val = val.substring(1);
    }
    if (val.endsWith("/")) {
        val = val.substring(0, val.length - 1);
    }
    input.val(val);
    pathToLowerCase(input, toLower);
}

function pathToLowerCase(input, toLower) {

    input = $(input);
    if (typeof toLower === 'undefined') {
        // Now we convert to Lower for new, copy and edit
        // // (before)only convert to lower case if new page i.e. pageId = ""
        // // var pageId = input.parents("form:first").find("[name=pageId]").val();
        // // toLower = (pageId === "");
        toLower = true;
    }

    if (toLower === true) {
        input.val(input.val().toLowerCase());
    }
}


function updateFieldCounter(field) {
    field = $(field);
    field.parent().find('.fieldCounter').text(field.val().length);
}

function isalphanumeric(val) {
    if (val.match((/[^0-9\A-Z\a-z]/g)))
        return false;
    else
        return true;
}

function isJsonString(str) {
    try {
        JSON.parse(str);
    }
    catch (e) {
        return false;
    }
    return true;
}

function deleteParent(ele, parentSelector){
    if(typeof parentSelector === 'undefined' || parentSelector.length == 0){
        $(ele).parent().remove();
    }
    else{
        $(ele).parents(parentSelector).remove();
    }
}

//----------------
// function to pretty print a json
function jsonPrettyPrint( json, addPreTag, openWindow ) {
    var styleMap = {
        pre     : "outline: 1px solid #ccc; padding: 5px; margin: 5px;",
        string  : "color: green;",
        number  : "color: darkorange;",
        boolean : "color: blue;",
        null    : "color: magenta;",
        key     : "color: red;",
    };

    var retVal = typeof json === 'string' ? JSON.parse(json): json;
    retVal = JSON.stringify(retVal, null, 2)
    retVal = retVal.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    var regex = /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g;
    retVal =  retVal.replace(regex, function (match) {
        var cls = 'number';
        if (/^"/.test(match)) {
            if (/:$/.test(match)) {
                cls = 'key';
            } else {
                cls = 'string';
            }
        } else if (/true|false/.test(match)) {
            cls = 'boolean';
        } else if (/null/.test(match)) {
            cls = 'null';
        }

        return '<span class="' + cls + '" style="' + styleMap[cls] + '" >' + match + '</span>';

    });

    if(typeof addPreTag !== 'undefined' && addPreTag ){
        retVal =  '<pre style="' + styleMap['pre'] + '" >' + retVal + '</pre>';
    }

    if(typeof openWindow !== 'undefined' && openWindow ){
         var w = window.open(null,'jsonPrettyPrint');
         var html = "<head><title>JsonPrettyPrint</title></head><body>"+retVal+"</body>";
         w.document.writeln(html);
    }

    return retVal;

}

function loadFoldersList(folderSelect, folderType) {
    $.ajax({
        url : 'foldersAjax.jsp', type : 'POST', dataType : 'json',
        data : {
            requestType : 'getListForViews',
            folderType : folderType
        },
    })
    .done(function (resp) {
        if (resp.status == 1) {
            var foldersList = resp.data.folders;
            folderSelect = $(folderSelect);
            if (folderSelect.length > 0) {

                folderSelect.html('<option value="">-- list of folders --</option>');
                folderSelect.append('<option value="0">Root (Base folder)</option>')
                var lastConcatPath = "";
                var lastOptGroupEle = null;
                $.each(foldersList, function (index, curFolder) {

                    var label = curFolder.name;
                    var option = $('<option>').text(curFolder.name)
                    .attr('value', curFolder.id)
                    .attr('data-template', curFolder.template_custom_id);

                    if (curFolder.concat_path.length === 0) {
                        folderSelect.append(option);
                    }
                    else {
                        if (curFolder.concat_path != lastConcatPath) {
                            lastOptGroupEle = $('<optgroup class="bg-secondary" >')
                            .attr('label', curFolder.concat_path + "/");
                            lastConcatPath = curFolder.concat_path;
                            folderSelect.append(lastOptGroupEle);
                        }
                        option.text("> " + option.text());
                        lastOptGroupEle.append(option);
                    }
                });
            }
        }
        else {
            bootAlert(resp.message);
        }
    })
    .always(function () {
        // hideLoader();
    });
}

function loadProductFoldersList(productFoldersSelect, productFoldersCatalogSelect) {
    $.ajax({
        url : 'foldersAjax.jsp', type : 'POST', dataType : 'json',
        data : {
            requestType : 'getProductFoldersListForViews',
        },
    })
    .done(function (resp) {
        if (resp.status == 1) {
            $ch.product_folders = resp.data.folders;
            var productSelect = $(productFoldersSelect);
            var catalogSelect = $(productFoldersCatalogSelect);
            if (productSelect.length > 0 && catalogSelect.length > 0) {
                productSelect.html('<option value="">-- list of folders --</option>');
                catalogSelect.html('<option value="">-- list of folders --</option>');

                var foldersList = resp.data.folders;
                //here assuming the list is sorted by  catalog_type, concat_path, name
                var lastCatalogType = "";
                var lastConcatPath = "";
                var lastOptGroupEle;
                $.each(foldersList, function (index, curFolder) {
                    var option = $('<option>').text(curFolder.name).attr('value', curFolder.uuid);

                    if (lastCatalogType !== curFolder.catalog_type) {
                        lastCatalogType = curFolder.catalog_type;
                        var optGroup = $('<optgroup class="bg-secondary" >').attr('label', curFolder.catalog_type);
                        productSelect.append(optGroup);
                        catalogSelect.append(optGroup.clone());
                    }

                    if (curFolder.concat_path.length === 0) {
                        productSelect.find(">optgroup:last").append(option);
                        catalogSelect.find(">optgroup:last").append(option.clone());
                    }
                    else {
                        // here 2nd or 3rd level folders  are only added to product view filter
                        if (curFolder.concat_path != lastConcatPath) {
                            lastOptGroupEle = $('<optgroup class="bg-secondary">')
                                .attr('label', "    " + curFolder.concat_path + "/");
                            lastConcatPath = curFolder.concat_path;
                            productSelect.find(">optgroup:last").append(lastOptGroupEle);
                        }
                        lastOptGroupEle.append(option);
                    }


                });

            }
        }
        else {
            alert(resp.message);
        }
    })
    .always(function() {
        // hideLoader();
    });

}