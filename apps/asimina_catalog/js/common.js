function showAutocompleteList(tags,input,event,allTags,generateTags,selectValue,paymentOrDeliveryMethodId,deliveryMethodSubVal,isDeliveryMethod) {
    var autocompleteList = input.nextElementSibling;
    if(autocompleteList==null)
    {
        autocompleteList=document.createElement("ul");
        autocompleteList.classList.add("autocomplete-items","p-0","w-100");
        autocompleteList.style.listStyleType="none";
        autocompleteList.style.borderTop="none";
        autocompleteList.style.border="1px solid #ddd";
    }
    else{
        autocompleteList.innerHTML="";
    }

    tags.forEach(function(tag) {
        const suggestion = document.createElement('li');
        var newText;
        if(generateTags) newText = tag.label.toLowerCase();
        if(typeof tag == "string") newText = tag;
        else newText = tag.value || tag.label;

        suggestion.innerHTML = `<a style="cursor:pointer;" title="${newText}" >${newText}</a>`;

        suggestion.addEventListener('mousedown', function(e) {
            if(generateTags==true){
                addTagGeneric(tag, event.target,allTags,selectValue,paymentOrDeliveryMethodId,deliveryMethodSubVal,isDeliveryMethod);
                input.value = '';
            }else{
                input.value = e.target.querySelector("a").innerHTML.trim();
            }
            autocompleteList.outerHTML="";
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

function setupAutocomplete(input,allTags,generateTags) {
    input.addEventListener('input', function(event) {
        const term = event.target.value.toLowerCase();
        if(term.length<1){
            const parent = input.closest(".form-group");
            if(parent.querySelector(".autocomplete-items")){
                parent.querySelector(".autocomplete-items").outerHTML = "";
                return;
            }
        }
        const filteredTags = allTags.filter(function(tag) {
            if(generateTags)
                return tag.label.toLowerCase().includes(term);
            if(typeof tag == "string")
                return tag.toLowerCase().includes(term);
            return tag.value.toLowerCase().includes(term);
        });
        showAutocompleteList(filteredTags,input,event,allTags,generateTags);
    });
    
    input.addEventListener("keydown",function(event){
        var ulTag = event.target.nextElementSibling;
        if(event.key==="ArrowDown"){
          var li = ulTag.querySelector(".autocomplete-item-highlight");
          if(li){
            var sibling = li.nextSibling;
            if(sibling) {
              li.classList.remove("autocomplete-item-highlight");
              ulTag.scrollTop = (sibling.offsetTop);
              sibling.classList.add("autocomplete-item-highlight");
            }
          }else{
            if(ulTag.querySelector("li"))
              li = ulTag.querySelector("li").classList.add("autocomplete-item-highlight");
          }
        }else if(event.key==="ArrowUp"){
          var li = ulTag.querySelector(".autocomplete-item-highlight");
          if(li){
            var sibling = li.previousSibling;
            if(sibling) {
              li.classList.remove("autocomplete-item-highlight");
              ulTag.scrollTop = (sibling.offsetTop );
              sibling.classList.add("autocomplete-item-highlight")
            };
          }
        }
        else if(event.key === "Escape"){
          ulTag.outerHTML="";
        }
        else if(event.key === "Enter"){
          var li = ulTag.querySelector(".autocomplete-item-highlight");
          if(li) {
            if(generateTags){
                addTagGeneric(li.querySelector("a").innerHTML.trim(), event.target,allTags);
                event.target.value = "";
            }
            else
                event.target.value = li.querySelector("a").innerHTML.trim();
        }
        ulTag.outerHTML="";
        }
    });

    input.addEventListener("blur",function(event){
        var ulTag = event.target.nextElementSibling;
        if(ulTag)
        {
          ulTag.outerHTML="";
        }
    });
}
  

function initTagAutocomplete(input, isRequired,allTags,generateTags) {
    Array.from(input).forEach((e)=>{
        setupAutocomplete(e,allTags,generateTags);
        if (isRequired === true) {
            e.classList.add('requiredInput');
        }    
    });
}

function getTagsDivGeneric(input) {
    input = $(input);
    var tagsDiv = input.parent().parent().find(".tagsDiv:first");
    if (tagsDiv.length == 0) {
        tagsDiv = input.parent().parent().parent().find(".tagsDiv:first");
    }
    return tagsDiv;
}

function addTagGeneric(tag, input,allTags,selectValue,paymentOrDeliveryMethodId,deliveryMethodSubVal,isDeliveryMethod) {
    if (typeof tag == 'string') {
        var tagFound = false;
        $.each(allTags, function(index, curTag) {
            if (tag === curTag.label.toLowerCase()) {
                tag = curTag;
                tagFound = true;
                return false;
            }
        });

        if (!tagFound) {
            return false;
        }
    }

    if (!tagExistsGeneric(tag, input)) {
        input = $(input);
        let tagsDiv = getTagsDivGeneric(input.closest(".form-group"));
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
                removeTag(this);
                updateTagsRequiredGeneric($(this).closest(".tagsDiv").parent().parent().find("input.tagInputField"));
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

        if(selectValue){
            if(isDeliveryMethod){
                pill.find("a").append(`<input type='hidden' class='tagValue' name='excluded_delivery_method' value='${paymentOrDeliveryMethodId}'>`);
                pill.find("a").append(`<input type='hidden' class='tagValue' name='excluded_delivery_method_sub' value='${deliveryMethodSubVal}'>`);
                pill.find("a").append(`<input type='hidden' class='tagValue' name='delivery_excluded_product_type' value='${selectValue}'>`);
                pill.find("a").append(`<input type='hidden' class='tagValue' name='delivery_excluded_product_value' value='${tag.id}'>`);
            }else{
                pill.find("a").append(`<input type='hidden' class='tagValue' name='excluded_payment_method' value='${paymentOrDeliveryMethodId}'>`);
                pill.find("a").append(`<input type='hidden' class='tagValue' name='excluded_product_type' value='${selectValue}'>`);
                pill.find("a").append(`<input type='hidden' class='tagValue' name='excluded_product_value' value='${tag.id}'>`);
            }
        }else{
            pill.find("a").append(`<input type='hidden' class='tagValue' name='tagValue' value='${tag.id}'>`);
        }
        
        let pillClone = pill.clone();
        pillClone.find("a").remove();
        pillClone.addClass("py-2");

        tagsDiv.append(pill);
		$("._secondaryTagsDiv").append(pillClone);
        feather.replace();
    }

    updateTagsRequiredGeneric(input);
}

function tagExistsGeneric(tag, input) {
    input = $(input);
    var tagsDiv = getTagsDivGeneric(input);
    var doesTagExist = false;
    tagsDiv.find("input[name=tagValue]").each(function(i, ele) {
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
        }
        else {
            input.get(0).setCustomValidity("required");
        }
    }
}

function showLoader(msg, ele){

    if(typeof ele === "undefined") ele = $('body');

    ele.addClass('loading2');

    $(ele).find('div.loading2msg').remove();
    var msgEle = $('<div>').addClass('loading2msg');
    $(ele).append(msgEle);

    if(typeof msg !== 'undefined'){
        msgEle.html(msg);
    }
    else{
        msgEle.html("");
    }

}

function hideLoader(){
    $('.loading2').removeClass('loading2');
}

function show(z)
{
	var s = "" ;

	w = open("_blank","aide",'height=360,width=400,top=100,left=140,scrollbars=yes,resizable');
	w.document.open();

 	for( var i in z )
		{
			s = "";
				c = ("" + i).charAt(0);
				if(c < '0' || c > '9' )
						s += " <font color=blue>" + i + "</font>->" + eval( "z." +i) ;
				else
						s += " " + i + "-> void ptr ";
				s += "<br>";
				w.document.write(s);
	}
	w.document.close();
	return(false);
}

function isdoublevalue(e)
{
	var unicode = e.charCode ? e.charCode : e.keyCode;

	if(unicode == 46)
	{
	      	var targ;
		if (e.target) targ = e.target;
		else if (e.srcElement) targ = e.srcElement;
		if(targ.value.indexOf(".") > -1) return false;
		return true;
	}

	if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57))
	{
       	return false;
	}

}

function isvalidimage(fname)
{
	if($.trim(fname) == '') return false;
	var ext = $.trim(fname);
	if(ext.indexOf(".") > -1) ext = ext.substring(ext.lastIndexOf(".") + 1);
	else return false;

	if(ext.toLowerCase() != "png" && ext.toLowerCase() != "jpg" && ext.toLowerCase() != "jpeg" && ext.toLowerCase() != "tif" && ext.toLowerCase() != "gif")
		return false;
	return true;
}

function getContextPath(){
	var l = ""+location.pathname;
	l = l.substring(1);
	var i = l.indexOf("/");
	l = l.substring(0,i);
	return("/"+l+"/");
}


function allowNumberOnly(ele){
    $(ele).val($(ele).val().replace(/[^\d]/g,''));
}

function allowFloatOnly(ele){
    var val = $(ele).val().replace(/[^\d.,]/g,'');
    //keep only one decimal point, remove extras
    if(val.indexOf(".")>=0){
        var valArr = val.split(".");
        val = valArr[0] + "." + valArr.splice(1).join("");
    }
    if(val.indexOf(",")>=0){
        var valArr = val.split(",");
        val = valArr[0] + "." + valArr.splice(1).join("");
    }
    $(ele).val(val);
}

function formatNumber(ele, precision){
	var val = $(ele).val();

	if(precision >= 0 && parseFloat(val)){
		val = parseFloat(val).toFixed(precision);
		$(ele).val(val);
	}
}


// simple replace all for javascript for simple strings
//  if searchTerm has regexp special characters
//  use escapeRegExp(str) function to escape it before calling
function strReplaceAll(str , searchTerm, replacement){

    return str.replace(new RegExp(searchTerm, 'g'), replacement);
}

function escapeRegExp(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); // $& means the whole matched string
}

function bootConfirm(message, callback) {
    //callback(result) , where result = true/false

    bootbox.confirm({
        size: 'small',
        animate: false,
        message: message,
        callback: callback
    });
}

function bootAlert(message, callback) {
    //NOTE: unlike builtin "alert()" this does not stop execution
    //for workaround, you can use callback
    //callback(result) , where result = true/false

    bootbox.alert({
        size: 'small',
        animate: false,
        message: message,
        callback: callback
    });
}

/*
  toast-like , growl-like notification
  which auto close after some time
*/

function bootNotifyError(msg){
  bootNotify(msg, "danger");
}

function bootNotify(msg, type) {

    if (typeof type == 'undefined') {
        type = "success";
    }
    var settings = {
        type: type,
        delay: 2000,
        placement: {
            from: "top",
            align: "center"
        },
        offset : {
            y : 10,
        },
        z_index : 1500,//to show above bootstrap modal
    };

    $.notify(msg, settings);
}

function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}


//----
// for media library images
// field image loader functions, used in templateEditor and blocEditor
let popup;
let chkInterval;
function loadFieldImageV2(button,isEdit){
    if(!window.PAGES_APP_URL){
		console.error("PAGES_APP_URL not defined");
		return false;
	}

    button = $(button);
    let imageCard = button.closest(".image_card");
    let cardBody = imageCard.find('.card-body');
    let uiStateMediaDefault = $(`<span class="ui-state-media-default mx-1" style="padding:0px;display: inline-block;">
        <div class="bloc-edit-media">
            <button type="button" class="btn btn-primary mx-1" style="margin-right: .10rem;" onclick='loadFieldImageV2(this,true)'><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg></button>
            <button type="button" class="btn btn-danger mx-1" style="margin-right: .1rem;" onclick='clearFieldImageV2(this)' ><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="css-i6dzq1"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg></button>
        </div>
        <div class="bloc-edit-media-bgnd" style="height:100%; width:100%; min-width:145px; min-height:145px; position:absolute; left:0; top:0">&nbsp;</div>
        <input type="hidden" name="image_value" class="image_value" />
        <input type="hidden" name="image_alt" class="image_alt" />
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

    var mediaLibraryUrl = window.PAGES_APP_URL + "admin/mediaLibrary.jsp?popup=1";

    popup = window.open(mediaLibraryUrl, "mediaLibrary", prop);
    popup.isImageFieldV2 = true;
    popup.focus();   
    chkInterval = setInterval(checkIfPopUpWinClosed,1000); 
}

function checkIfPopUpWinClosed(){
    if(popup.closed)
    {
        if(window.fieldImageDivV2.find(".image_value").val().length == 0){
            window.fieldImageDivV2.remove();
        }
        
        let imgCard = (window.fieldImageDivV2.find(".image_card").length>0)? window.fieldImageDivV2.find(".image_card") : window.fieldImageDivV2.closest(".image_card");

        let totalImages = imgCard.find(".image_value").length;
        let imagesLimit = imgCard.data("img-limit");
        
        if(totalImages <= imagesLimit)
            imgCard.closest(".row").find(".img-count").text(totalImages);
            if(totalImages == imagesLimit){
                let mediaDefault = imgCard.find(".ui-state-media-default:last");
                mediaDefault.find(".load-img").hide();
                mediaDefault.find(".no-img").show();
            }
        else{
            window.fieldImageDivV2.remove();
        }
        clearInterval(chkInterval); 
    }
}

function selectFieldImageV2(imgObj){

	if(!window.MEDIA_LIBRARY_IMAGE_URL_PREPEND){
		window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = '';
	}

    var name = imgObj.name;
    var label = imgObj.label;
    var altName = imgObj.altName;
    var image_value = window.fieldImageDivV2.find('.image_value:first');
    image_value.val(name);
    if(window.IS_PRODUCT_SCREEN) window.fieldImageDivV2.find('.image_value:first').attr("name","atrIcon");

    if(name.length > 0){
    	window.fieldImageDivV2.find('.card-image-top:first').attr('src', window.MEDIA_LIBRARY_IMAGE_URL_PREPEND + name );
    }else{
        window.fieldImageDivV2.find('.bloc-edit-media:first').find(".btn-danger").trigger("click");
    }

    var image_alt = window.fieldImageDivV2.find('.image_alt:first');

    if(image_alt.length > 0)
    if(image_alt.val().length == 0){
        if(altName && altName.length>0){
            image_alt.val(altName);
        }else{
            image_alt.val(label);
        }
    }
    
    let imgCard = window.fieldImageDivV2.find(".image_card");
    if(imgCard.length == 0) imgCard = window.fieldImageDivV2.closest(".image_card");

    imgCard.closest(".row").find(".img-count").text(imgCard.find(".image_value").length);
    if(imgCard.data("img-limit") > imgCard.find(".image_value").length) {
        imgCard.find(".ui-state-media-default:last").find(".load-img").show();
        imgCard.find(".ui-state-media-default:last").find(".no-img").hide();
    }else if(imgCard.data("img-limit") <= imgCard.find(".image_value").length)
    {
        imgCard.find(".ui-state-media-default:last").find(".load-img").hide();
        imgCard.find(".ui-state-media-default:last").find(".no-img").show();
    }
    
    updateFieldImageRequiredStatusV2(window.fieldImageDivV2);
}

function updateFieldImageRequiredStatusV2(imageDiv){
	var image_value = imageDiv.find('.image_value:first');
	if(image_value.hasClass('requiredInput')){
		if(image_value.val().trim() === ""){
			imageDiv.addClass('border-danger');
			// imageDiv.find('.image_alt').get(0).setCustomValidity("required");
		}
		else{
			imageDiv.removeClass('border-danger');
			// imageDiv.find('.image_alt').get(0).setCustomValidity("");
		}
	}
}

function clearFieldImageV2(button){
    button = $(button);
    let row = button.closest(".row");
    var imageDiv = button.parents('.ui-state-media-default:first');
    imageDiv.remove();
    let imgCard = row.find(".image_card");
    if(imgCard.length == 0) imgCard = row.closest(".image_card");
    imgCard.find(".img-count").text(imgCard.find(".image_value").length);
    if(imgCard.data("img-limit") > imgCard.find(".image_value").length)
    {
        imgCard.find(".ui-state-media-default:last").find(".load-img").show();
        imgCard.find(".ui-state-media-default:last").find(".no-img").hide();   
    }
    // updateFieldImageRequiredStatusV2(imageDiv);
}


function loadFieldImage(button){

	if(!window.PAGES_APP_URL){
		console.error("PAGES_APP_URL not defined");
		return false;
	}

    button = $(button);
    window.fieldImageDiv = button.parents('.image_card:first');

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

    var mediaLibraryUrl = window.PAGES_APP_URL + "/admin/mediaLibrary.jsp?popup=1";

    var win = window.open(mediaLibraryUrl, "mediaLibrary", prop);
    win.focus();
}

function selectFieldImage(imgObj){

	if(!window.MEDIA_LIBRARY_IMAGE_URL_PREPEND){
		window.MEDIA_LIBRARY_IMAGE_URL_PREPEND = '';
	}

    var name = imgObj.name;
    var label = imgObj.label;
    var altName = imgObj.altName;

    var image_value = window.fieldImageDiv.find('.image_value');
    image_value.val(name).trigger('change');

    if(name.length > 0){
    	window.fieldImageDiv.find('.image_body img').attr('src', window.MEDIA_LIBRARY_IMAGE_URL_PREPEND + name );
    }

    var image_alt = window.fieldImageDiv.find('.image_alt:first');
    if(image_alt.val().length == 0){
        if(altName && altName.length>0){
            image_alt.val(altName);
            image_alt.focus();
        }else{
            image_alt.val(label);
            image_alt.focus();
        }
    }

    updateFieldImageRequiredStatus(window.fieldImageDiv);
}

function clearFieldImage(button, defaultImgSrc){
	if(typeof defaultImgSrc === 'undefined'){
		defaultImgSrc = '';
	}
    button = $(button);
    var imageDiv = button.parents('.image_card:first');

    imageDiv.find('[name=image_value],[name=image_alt]').val('');
    imageDiv.find('input.image_value,input.image_alt').val('');
    imageDiv.find('.image_body img').attr('src', defaultImgSrc);
    updateFieldImageRequiredStatus(imageDiv);
}

function updateFieldImageRequiredStatus(imageDiv){

	if(!imageDiv.hasClass('image_card')){
		imageDiv = imageDiv.find('.image_card:first');
	}

	var image_value = imageDiv.find('.image_value');
	if(image_value.hasClass('requiredInput')){
		if(image_value.val().trim() === ""){
			imageDiv.addClass('border-danger');
			imageDiv.find('.image_alt').get(0).setCustomValidity("required");
		}
		else{
			imageDiv.removeClass('border-danger');
			imageDiv.find('.image_alt').get(0).setCustomValidity("");
		}
	}
}

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
            .replace('--','-');
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
        //only convert to lower case if new page i.e. pageId = ""
        var pageId = input.parents("form:first").find("[name=pageId]").val();
        toLower = (pageId === "");
    }

    if (toLower === true) {
        input.val(input.val().toLowerCase());
    }
}

