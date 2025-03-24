function initializeVariants(postData, contextPath){
    $.ajax({
        url : portalUrl+'calls/variantdetails.jsp',
        type: 'post',
        data: postData,
        dataType: 'json',
        success : function(json)
        {
            //alert($(".TerminauxDetailsChoice").attr("data-details"));
            //$("#TerminauxDetailsChoice").attr("data-details",JSON.stringify(json));
            variantsData = json;
            //$("#TerminauxDetailsPreview-default").attr("data-details",JSON.stringify(json));
            generateVariantsHtml(variantsData, contextPath);
            variantsData.splice(-1,1);
            //init();SvgLoader
            $(document).trigger("SvgLoader.init");
            //$(document).trigger("SvgLoader.load");
            //alert("here");
            if($("#TerminauxInformations-specifications > ul").children().length<3) $(".TerminauxInformations-seeMoreBtn").hide();
            $("#TerminauxInformations-specifications").find('ul').addClass('TerminauxInformations-specifications');
            initAttributes();
        },
        error : function()
        {
                console.log("Error while communicating with the server");
        }
    });
}

function initAttributes(){            
    bindEvents();    
    toggleAttributes();
    $(".attributes .isActive").each(function () {
        setColorName($(this));
    });
}

function bindEvents(){
    $(".ColorCircle").on("click", function () {
        if (!$(this).hasClass("disabled")) {
            var color = $(this).attr("data-value");

            if (color) {
                setActiveColor($(this));
                $(document).trigger("setImagesFromVariant");//setImagesFromVariant();
                toggleAttributes();
            }
        }
    });
    $(".TerminauxDetailsChoice-stockage .item").on("click", function () {
        if (!$(this).hasClass("disabled")) {
            var storage = $(this).attr("data-value");

            if (storage) {
                setActiveStorage($(this));
                $(document).trigger("setImagesFromVariant");//setImagesFromVariant();
                toggleAttributes();
            }
        }
    });
    $('.custom-select.attributes').on("change", function () {       
        $(this).find(".active").removeClass("active");
        var val = $(this).val();
        if(val!=""){            
            $(this).find(":selected").addClass("active");
        }
        //alert(val);
        $(document).trigger("setImagesFromVariant");//setImagesFromVariant();
        toggleAttributes();
        
    });
    $('input[type="radio"][name="customRadio"]').on("change", function () {
        var val = $(this).val();

        if (val === "with") {
            $(".forfait-mobile-without").removeClass("active");
            $(".forfait-mobile-with").addClass("active");
            $(".prix-mobile-sans-forfait").hide();
            $(".prix-mobile-avec-forfait").show();
        } else if (val === "without") {
            $(".forfait-mobile-with").removeClass("active");
            $(".forfait-mobile-without").addClass("active");
            $(".prix-mobile-avec-forfait").hide();
            $(".prix-mobile-sans-forfait").show();
        }
    });
    $(".forfait-mobile-with").on("click", function () {
        var increment = $(this).attr("data-increment"); // console.log(increment);

        $(".forfait-mobile-without").removeClass("active");
        $(".forfait-mobile-with").addClass("active"); // $("input#customRadio1").attr("checked", "checked");

        $('label[for="customRadio1-' + increment + '"]').trigger("click");
        $('.prix-mobile-sans-forfait').hide();
        $(".prix-mobile-avec-forfait").show();
    });
    $(".forfait-mobile-without").on("click", function () {
        var increment = $(this).attr("data-increment"); // console.log(increment);

        $(".forfait-mobile-with").removeClass("active");
        $(".forfait-mobile-without").addClass("active"); // $("input#customRadio2").attr("checked", "checked");

        $('label[for="customRadio2-' + increment + '"]').trigger("click");
        $(".prix-mobile-avec-forfait").hide();
        $(".prix-mobile-sans-forfait").show();
    });
    $(".TerminauxInformations-seeMoreBtn").on("click", function () {
        $("#TerminauxInformations-specifications > ul > li").css({
            display: "list-item"
        });
        $(this).hide();
    });
    
    $(".TerminauxDetailsChoice-alertSubscription > form").on("submit", function (e) {
        e.preventDefault();
        var email = $(this).find('input[type="email"]').val().toString();

        if (validateEmail(email)) {
            var postData = {
                        product_id: product_uuid,
                        email: email,
                        muid: ______muid,
                        variant_id: $(this).parent().attr("data-linkedvariant")
                    };
                    jQuery.ajax({
			url : cartUrl+'cart/saveStockEmail.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            showSuccess(email);
			}
                    });
        }
      });
}

function validateEmail(email) {
    var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}

function showSuccess(email) {
    $(".TerminauxDetailsChoice-alertSubscription-input").hide();
    $(".TerminauxDetailsChoice-alertSubscription-submit").hide();
    $(".TerminauxDetailsChoice-alertSubscription-success").show();
    $(".TerminauxDetailsChoice-alertSubscription-success-content > span").text(email);
}

function setActiveColor(el) {
    if(el.hasClass("isActive")) el.removeClass("isActive");
    else{
        el.siblings().removeClass("isActive");
        el.addClass("isActive");
    }
    setColorName(el);
}

function setActiveStorage(el) {
    if(el.hasClass("active")) el.removeClass("active");
    else{
        el.siblings().removeClass("active");
        el.addClass("active");
    }
}
    
function setColorName(el) {
    if (el.hasClass("isActive")) {
        $("#colorSpan_"+el.attr("data-attribute")).text(el.attr("data-name"));
    } else {
        //colorName = $(".ColorCircle.isActive").attr("data-name");
        $("#colorSpan_"+el.attr("data-attribute")).text("");
    }

    
}

function toggleAttributes(){
    $(".attribute").removeClass("disabled");
    $(".attribute").prop("disabled", false);
    var selectedAttributes = [];
    //$(".attribute").removeClass("warning");
    $(".attributes .active, .attributes .isActive").each(function () { // for each active attribute, disable some others.
        var attribute = $(this).attr("data-attribute");
        var value = $(this).attr("data-value");
        selectedAttributes.push({
            "attribute" : attribute,
            "value" : value
        });
        $(".attributes").each(function (index) {
            //console.log(index);
            //if(index==0) continue;
            var cat_attrib_id = $(this).attr("data-attribute");
            if(/*index!=0&&*/cat_attrib_id!=attribute){ // no need to enable/disable the same attribute based on itself .. ALSO SKIPS EMPTY VALUE IN SELECT
                $(this).find(".attribute").each(function () {
                    var enableAttribute = false;
                    var attributeStock = false;
                    for(var i = 0; i < variantsData.length; i++){
                        var tempArray = variantsData[i].attributes;
                        for(var j=0; j<tempArray.length; j++){
                            if(tempArray[j].attribute==attribute&&tempArray[j].value==value){
                                for(var k=0; k<tempArray.length; k++){
                                    if(tempArray[k].attribute==$(this).attr("data-attribute") && tempArray[k].value==$(this).attr("data-value") && variantsData[i].inStock){
                                        attributeStock = true;
                                    }
                                    if(tempArray[k].attribute==$(this).attr("data-attribute") && tempArray[k].value==$(this).attr("data-value")){
                                        enableAttribute = true;
                                    }
                                }
                            }
                        }
                    }
                    if(!attributeStock){
                        //$(this).addClass("warning");
                    }
                    if(!enableAttribute){
                        $(this).addClass("disabled");
                        $(this).prop("disabled", true);
                    }
                });
                /*if($(this).find(".attribute:not(.disabled)").length==1){
                    $(this).find(".attribute:not(.disabled)").addClass("isActive");
                }*/
            }
            
        });
        $(".attributes").each(function (index) {
            var cat_attrib_id = $(this).attr("data-attribute");
            var unselected = true;
            for(var i=0; i<selectedAttributes.length; i++){
                if(cat_attrib_id==selectedAttributes[i].attribute) unselected = true;
            }
            if(unselected){
                $(this).find(".attribute").each(function () {
                    var enableAttribute = false;
                    for(var i = 0; i < variantsData.length; i++){
                        var tempObject = variantsData[i].attributesObject;
                        if(tempObject["attribute_"+cat_attrib_id]==cat_attrib_id+"_"+$(this).attr("data-value")){
                            var selectedCombo = true;
                            for(var j=0; j<selectedAttributes.length; j++){
                                if(selectedAttributes[j].attribute!=cat_attrib_id&&tempObject["attribute_"+selectedAttributes[j].attribute]!=selectedAttributes[j].attribute+"_"+selectedAttributes[j].value) selectedCombo = false;
                            }
                            if(selectedCombo) enableAttribute = true;
                        }
                    }
                    
                    if(!enableAttribute){
                        $(this).addClass("disabled");
                        $(this).prop("disabled", true);
                    }
                });
            }
        });
    });    
    
    setPriceBlock();
}

function getSelectedVariantId(){
    var selectedVariantId = "";
    if($(".attributes .active, .attributes .isActive").length == $(".attributes").length){ // means all attributes selected        
        
        for(var i = 0; i < variantsData.length; i++){
            var tempArray = variantsData[i].attributes;
            var isSelectedVariant = true;
            $(".attributes .active, .attributes .isActive").each(function (index) {
                var attribute = $(this).attr("data-attribute");
                var value = $(this).attr("data-value");
                if(value!=tempArray[index].value) isSelectedVariant = false;
            });
            if(isSelectedVariant){
                selectedVariantId = variantsData[i].id;
                break;
            }
        }    
        
    }
    return selectedVariantId;
}

function setPriceBlock() {
    var selectedVariantId = getSelectedVariantId();
    if(selectedVariantId == "") selectedVariantId = "0";
    // CAS OU IL Y A AU MOINS UNE COULEUR ET PAS DE STOCKAGE
    $(".TerminauxDetailsChoice > #variantHtmlContainer > .price").each(function (index) {
        if ($(this).attr("data-linkedvariant") === selectedVariantId) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
    $(".TerminauxDetailsChoice-alertSubscription").each(function (index) {
        if ($(this).attr("data-linkedvariant") === selectedVariantId) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
    $(".pageStyle-btn-forfait").each(function (index) {
        if ($(this).attr("data-linkedvariant") === selectedVariantId) {
            $(this).show();
            if($(this).hasClass("action-btn-desktop")) $(this).addClass("d-md-block");
        } else {
            $(this).hide();
            if($(this).hasClass("action-btn-desktop")) $(this).removeClass("d-md-block");
        }
    });
    $(".TerminauxDetailsChoice-discounts-gifts-wrapper").each(function (index) {
        if ($(this).attr("data-linkedvariant") === selectedVariantId) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
    
    $(".TerminauxInformations-mainTab").html($("#TerminauxInformations-mainTab_"+selectedVariantId).html());
    $(document).trigger("flashCounter.init");
    
    /*if(selectedVariantId == ""){
        $(".default-variant").show();
        $(".pageStyle-btn-forfait").prop("disabled", true);
        $(".TerminauxDetailsChoice-alertSubscription-submit").prop("disabled", true);
    }
    else{
        $(".pageStyle-btn-forfait").prop("disabled", false);
        $(".TerminauxDetailsChoice-alertSubscription-submit").prop("disabled", false);
    }*/
      
}
    
/*function setImagesFromVariant() {
    var selectedVariantId = getSelectedVariantId();
    var imagesData = $(".TerminauxDetailsPreview-default").attr("data-details");
    imagesData = JSON.parse(imagesData);
    var imagesArray;
    $.each(imagesData, function (i, val) {
        if (selectedVariantId === val.id) {
            imagesArray = val.images;
            return false;
        }
    });

    if ((typeof imagesArray === "undefined" || imagesArray.length == 0) && imagesData.length > 0) {
        imagesArray = imagesData[0].images;
    }

    //TerminauxDetailsPreview.createSliderFromImages(imagesArray);
}*/



    function addToCart(id){
        $.ajax({
            url : portalUrl+'calls/updatecart.jsp',
            type: 'post',
            data: {
                id: id
            },
            dataType: 'json',
            success : function(json)
            {
                //console.log(":"+json.status+":")
                if(json.status == "SUCCESS"){

                    $('<form method="POST" action="' + cartUrl + 'cart/cart.jsp'+'"><input type="hidden" name="muid" value="'+______muid+'" ></form>').appendTo('body').submit();
                }
            },
            error : function()
            {
                    console.log("Error while communicating with the server");
            }
        });
    }

