function initializeDevices(path, postData){

    $.ajax({
        url : path+'calls/getprices.jsp',
        type: 'post',
        data: postData,
        dataType: 'json',
        success : function(json)
        {

            var products = json;

            var numberOfProducts = json.length;
            var product = ""; 
            var updatedPrice = "";
            var updatedPriceUnformatted = "";

            for(var k=0; k<numberOfProducts-1; k++){

                product = products[k];

                if(product["attributeValues"]["sarhead(watt/kg)"] != undefined && product["attributeValues"]["sarhead(watt/kg)"] != "") 
                    $("#product"+product["id"]).find(".TerminauxItem-das").html("DAS : " + product["attributeValues"]["sarhead(watt/kg)"] + " W/Kg");

                var firstTab = $("#product"+product["id"]).find(".Tab:first");

                if(isEcommerceEnabled && !product['inStock']){

                    $(firstTab).removeClass();
                    $(firstTab).addClass("Tab");
                    $(firstTab).addClass(getSticker("out_of_stock"));

                    $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["outOfStock"]);
                    $(firstTab).find(".Tab-icon").css("display","none");

                } else {

                    if(!(Object.entries(product['promotion']).length === 0 && product['promotion'].constructor === Object)){

                        updatedPrice = product["minPriceFrom"];
                        updatedPriceUnformatted = product["minPriceFromUnformatted"];

                        $("#product"+product["id"]).find(".TerminauxItem-price-crossed").html("<del>" + product["originalPriceFrom"] + "</del>");

                        $(firstTab).removeClass();
                        $(firstTab).addClass("Tab");
                        $(firstTab).addClass(getSticker(product['promotion']['flash_sale']));

                        if(product['promotion']['flash_sale'] === "no"){

                            $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["Promotion"]);
                            $(firstTab).find(".Tab-icon").css("display","none");

                        } else if(product['promotion']['flash_sale'] === "quantity" || product['promotion']['flash_sale'] === "time"){

                            $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["FlashSale"]);
                            $(firstTab).find(".Tab-icon").css("display","block");
                        }

                        $("#product"+product["id"]).attr("data-dl_promotion_type",getPromotionType(product['promotion']['flash_sale']));

                        if(product['promotion']['flash_sale'] == "time" && product['promotion']['end_date'] != "0000-00-00 00:00:00"){

                            $("#product"+product["id"]).find(".promotion-sale-active").css("display", "block");
                            $("#product"+product["id"]).find(".promotion-sale-active").find(".Counter").attr("data-timestamp",Math.round((new Date(product['promotion']['end_date'])).getTime() / 1000))
                            $(document).trigger("flashCounter.init");

                        } else if(product['promotion']['flash_sale'] == "quantity"){
                            
                            if(undefined !== products[numberOfProducts-1]["flashSaleQuantity_"+product["id"]])
                                flashSaleQuantity = "<div class='Tab-additional promotion-flash-sale-quantity'>" + products[numberOfProducts-1]["flashSaleQuantity_"+product["id"]] + "</div>";

                            $("#product"+product["id"]).find(".promotion-sale-active").css("display", "block");
                            $("#product"+product["id"]).find(".promotion-sale-active").html(flashSaleQuantity);
                        }

                    } else {

                        updatedPrice = product["originalPriceFrom"];
                        updatedPriceUnformatted = product["originalPriceFromUnformatted"];

                        $(firstTab).removeClass();
                        $(firstTab).addClass("Tab");
                        $(firstTab).addClass(getSticker(product['variantSticker']));

                        if(product['variantSticker'] !== 'none' && product['variantSticker'].length > 0){

                            if(product['variantSticker'] === "web"){

                                $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["webExclusive"]);

                            } else if(product['variantSticker'] === "orange"){

                                $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["orangeExclusive"]);

                            } else if(product['variantSticker'] === "new"){

                                $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["new"]);
                            }

                        } else {
     
                            $(firstTab).addClass(getSticker(""));
                            $(firstTab).find(".Tab-left-offer").html("");
                        }
                    }
                }
               
                if(product["isShowPrice"]){

                    $("#product"+product["id"]).find(".TerminauxItem-price-amount").html(updatedPrice);

                } else {

                    $("#product"+product["id"]).find(".TerminauxItem-price").addClass("d-none");
                }
                
                updateDevicePrices(product["id"], updatedPriceUnformatted);
            }

            var productUpdatedMinPrice = Math.floor(products[numberOfProducts-1]["productUpdatedMinPrice"]);
            var productUpdatedMaxPrice = Math.ceil(products[numberOfProducts-1]["productUpdatedMaxPrice"]);

            $("#inputPriceMin").val(productUpdatedMinPrice);
            $("#inputPriceMax").val(productUpdatedMaxPrice);

            $(document).trigger("SvgLoader.init");
            ___portaljquery(document).trigger("TerminauxListeHeader.initNoUiSlider");

        },
        error : function()
        {
                console.log("Error while communicating with the server");
        }
    });
};
       

function initializeOffers(path, postData){

    $.ajax({
        url : path+'calls/getprices.jsp',
        type: 'post',
        data: postData,
        dataType: 'json',
        success : function(json)
        {
            var products = json;
            var numberOfProducts = json.length;
            var product = "";
            var flashSaleQuantity = "";

            for(var k=0; k<numberOfProducts-1; k++){

                product = products[k];

                if(product["isShowPrice"]){

                    if(!(Object.entries(product['promotion']).length === 0 && product['promotion'].constructor === Object)){

                        $("#product"+product["id"]).find(".OffreItem-price").find(".underline").html(product["originalPriceFrom"]+"<br/>");

                        var firstTab = $("#product"+product["id"]).find(".Tab:first");
                        $(firstTab).removeClass();
                        $(firstTab).addClass("Tab");

                        if(product['promotion']['flash_sale'] !== "quantity") 
                            $(firstTab).addClass(getSticker(product['promotion']['flash_sale']));
                        else
                            $(firstTab).addClass(getSticker(""));

                        if(product['promotion']['flash_sale'] === "no"){

                            $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["Promotion"]);
                            $(firstTab).find(".Tab-icon").css("display","none");

                        } else if(product['promotion']['flash_sale'] === "time"){

                            $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["FlashSale"]);
                            $(firstTab).find(".Tab-icon").css("display","block");
                        }

                    } else {

                        var firstTab = $("#product"+product["id"]).find(".Tab:first");

                        $(firstTab).removeClass();
                        $(firstTab).addClass("Tab");
                        $(firstTab).addClass(getSticker(product['variantSticker']));

                        if(product['variantSticker'] !== 'none' && product['variantSticker'].length > 0){

                            if(product['variantSticker'] === "web"){

                                $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["webExclusive"]);

                            } else if(product['variantSticker'] === "orange"){

                                $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["orangeExclusive"]);

                            } else if(product['variantSticker'] === "new"){

                                $(firstTab).find(".Tab-left-offer").html(products[numberOfProducts-1]["new"]);
                            }

                        } else {
     
                            $(firstTab).addClass(getSticker(""));
                            $(firstTab).find(".Tab-left-offer").html("");
                        }
                    }

                    if(Object.entries(product['promotion']).length === 0 && product['promotion'].constructor === Object){

                        $("#product"+product["id"]).find(".OffreItem-price").find(".pageStyle-boldOrange").html(product["originalPriceFrom"]);

                        if(product["productType"] !== "offer_postpaid")
                            $("#product"+product["id"]).find(".OffreItem-price").find(".little").html("");

                    }else{

                        $("#product"+product["id"]).find(".OffreItem-price").find(".pageStyle-boldOrange").html(product["minPriceFrom"]);

                        if(product["minPriceFrom"] == "Gratuit" || product["minPriceFrom"] == "free")
                            $("#product"+product["id"]).find(".OffreItem-price").find(".little").html("");

                    }
                } else {

                        $("#product"+product["id"]).find(".OffreItem-price").addClass("d-none");
                }


                if(!(Object.entries(product['promotion']).length === 0 && product['promotion'].constructor === Object)){

                    $("#product"+product["id"]).attr("data-dl_promotion_type", getPromotionType(product['promotion']['flash_sale']));

                    if(product['promotion']['flash_sale'] == "time" && product['promotion']['end_date'] != "0000-00-00 00:00:00"){

                        $("#product"+product["id"]).find(".promotion-sale-active").find(".Counter").attr("data-timestamp",Math.round((new Date(product['promotion']['end_date'])).getTime() / 1000));
                        $("#product"+product["id"]).find(".promotion-sale-active").css("display", "block");
                    }
                }

                if(product["productType"] == "offer_postpaid"){

                    if(product['variant_commitment'] > 0){

                        $("#product"+product['id']).find("#offreItem-commitment").html(products[numberOfProducts-1]["Commitment"] + " " + product['variant_commitment'] + " " + products[numberOfProducts-1]["month(s)"]);
                    } else {

                        $("#product"+product['id']).find("#offreItem-commitment").html(products[numberOfProducts-1]["Without engagement"]);
                    }
                }
            }

            $(document).trigger("flashCounter.init");
            $(document).trigger("SvgLoader.init");

        },
        error : function()
        {
                console.log("Error while communicating with the server");
        }
    });
};

function initializeOfferDetail(path, postData, contextPath){

    $.ajax({
        url : path+'calls/getvariantprices.jsp',
        type: 'post',
        data: postData,
        dataType: 'json',
        success : function(json)
        {
            var variants = json;
            var numberOfVariants = json.length;
            var variant = "";
            var promotion = "";
            var updatedPrice = "";
            var additionalFee = "";
            var flashSaleQuantity = "";
            var warningHtml = "";
            var discountCardHtml = "";
            var comewith = "";
            var associatedProductHtml = "";
            var associatedProductLightBoxHtml = "";
            var originalPriceNumber = 0;
            var discountedPriceNumber = 0;

            for(var k=0; k<numberOfVariants-1; k++){

                variant = variants[k];
                promotion = variant['promotion'];
                additionalFee = variant['additionalFee'];
                comewith = variant['comewith'];
                warningHtml = "";

                originalPriceNumber = parseInt(variant["originalPriceFrom"].replace(/\,/g,''));
                discountedPriceNumber = parseInt(variant["minPriceFrom"].replace(/\,/g,''));

                if(!(Object.entries(promotion).length === 0 && promotion.constructor === Object))
                    updatedPrice = variant["minPriceFrom"];
                else 
                    updatedPrice = variant["originalPriceFrom"];

                if(updatedPrice != "Gratuit" && updatedPrice != "free"){

                    updatedPrice += " <span> " + variant["currency_frequency"];

                    if(variant["productType"] == "offer_postpaid"){

                        updatedPrice += "/" + variants[numberOfVariants-1]["month"];
                    }

                    updatedPrice += "</span>";
                }

                if(variant["isShowPrice"] == "1"){

                    $("#pvariant_"+variant["id"]).find(".OffreVariation-price").html(updatedPrice);

                } else if(variant["isShowPrice"] == "0"){

                    $("#pvariant_"+variant["id"]).find(".OffreVariation-price").html(variants[numberOfVariants-1]["priceDisplayLabel"]);
                }

                if(k==0 && variant["isShowPrice"] == "1") 
                    $(".OffreVariation-forfait").find(".pageStyle-boldOrange").html(updatedPrice);
                else if(variant["isShowPrice"] == "0")
                    $(".OffreVariation-forfait").find(".pageStyle-boldOrange").html(variants[numberOfVariants-1]["priceDisplayLabel"]);

                updatedPrice = "";

                if(!(Object.entries(promotion).length === 0 && promotion.constructor === Object)){


                    $("#pvariant_"+variant["id"]).attr("data-dl_promotion_type", getPromotionType(promotion['flash_sale']));
                    $(".etn-data-layer").attr("data-dl_promotion_type", getPromotionType(promotion['flash_sale']));

                    if(promotion['duration'].length > 0 && promotion['duration'] > 0){

                        updatedPrice += "Pendant " + promotion['duration'] + " " + variants[numberOfVariants-1]["month(s)"] + " ";
                    }
                }

                if(variant["productType"] == "offer_postpaid") 
                    updatedPrice += variants[numberOfVariants-1]["then"] + " ";
                else if(variant["productType"] == "offer_prepaid")
                    updatedPrice += variants[numberOfVariants-1]["instead of"] + " ";

                var firstTab = $("#pvariant_"+variant["id"]).find(".Tab:first");
                var firstTabDefault = $(".Offre-buttons").find(".Tab:first");

                if(!(Object.entries(promotion).length === 0 && promotion.constructor === Object)){

                    updatedPrice += variant["originalPriceFrom"] + " " + variant["currency_frequency"] 

                    if(variant["productType"] == "offer_postpaid"){

                        updatedPrice += "/" + variants[numberOfVariants-1]["month"];
                    }

                    if(variant["isShowPrice"] == "1"){

                        $("#pvariant_"+variant["id"]).find(".OffreVariation-engagement").html(updatedPrice);

                    } else if(variant["isShowPrice"] == "0"){

                        $("#pvariant_"+variant["id"]).find(".OffreVariation-engagement").html("");
                    }

                    if(k==0) 
                        $(".OffreVariation-forfait").find(".engagement").html(updatedPrice);

                    if(promotion['flash_sale'] == "time" && promotion['end_date'] != "0000-00-00 00:00:00"){

                        $("#pvariant_"+variant["id"]).find(".promotion-sale-active").find(".Counter").attr("data-timestamp",Math.round((new Date(promotion['end_date'])).getTime() / 1000))
                        $("#pvariant_"+variant["id"]).find(".promotion-sale-active").css("display", "block");

                        if(k==0) {

                            $(".Offre-detail").find(".promotion-sale-active").find(".Counter").attr("data-timestamp",Math.round((new Date(promotion['end_date'])).getTime() / 1000));
                            $(".Offre-detail").find(".promotion-sale-active").css("display", "block");
                        }
                    }

                    $(firstTab).removeClass();
                    $(firstTab).addClass("Tab");

                    if(promotion['flash_sale'] !== "quantity"){

                        $(firstTab).addClass(getSticker(promotion['flash_sale']));
                        if(k==0) $(firstTabDefault).addClass(getSticker(promotion['flash_sale']));
                    }
                    else{

                        if(k==0){

                            $(firstTab).addClass(getSticker(""));

                            $(firstTabDefault).removeClass();
                            $(firstTabDefault).addClass("Tab");
                            $(firstTabDefault).addClass(getSticker(""));
                        }
                    }

                    if(promotion['flash_sale'] === "no"){

                        $(firstTab).find(".Tab-left-offer").html(variants[numberOfVariants-1]["Promotion"]);
                        $(firstTab).find(".Tab-icon").css("display","none");

                        if(k==0) {

                            $(firstTabDefault).find(".Tab-left-offer").html(variants[numberOfVariants-1]["Promotion"]);
                            $(firstTabDefault).find(".Tab-icon").css("display","none");
                        }

                    } else if(promotion['flash_sale'] === "time"){

                        $(firstTab).find(".Tab-left-offer").html(variants[numberOfVariants-1]["FlashSale"]);
                        $(firstTab).find(".Tab-icon").css("display","block");

                        if(k==0) {
    
                            $(firstTabDefault).find(".Tab-left-offer").html(variants[numberOfVariants-1]["FlashSale"]);
                            $(firstTabDefault).find(".Tab-icon").css("display","block");
                        }
                    }


                    $("#pvariant_"+variant["id"]).attr("data-dl_promotion_type",getPromotionType(promotion['flash_sale']));
                    $("#pvariant_"+variant["id"]).find(".OffreVariation-header").removeClass("OffreVariation-isNouveau");
                    $("#pvariant_"+variant["id"]).find(".OffreVariation-header").addClass("OffreVariation-isFlash");

                    if(promotion['flash_sale'] == "time" && promotion['end_date'] != "0000-00-00 00:00:00"){

                        $("#pvariant_"+variant["id"]).find(".promotion-sale-active").css("display", "block");
                        $("#pvariant_"+variant["id"]).find(".promotion-sale-active").find(".Counter").attr("data-timestamp",Math.round((new Date(variant['promotion']['end_date'])).getTime() / 1000))

                    }

                    discountCardHtml += "<div style='display: ";

                    if(k==0) discountCardHtml += "block;";
                    else discountCardHtml += 'none;'

                    discountCardHtml += "' class='DiscountCard'><div class='DiscountCard-header collapsed' data-toggle='collapse' data-target='#DiscountCard_" + variant["id"] + "' aria-expanded='false'><div class='DiscountCard-colLeft'><div class='DiscountCard-title'>";

                    if(promotion['flash_sale'] != "no"){
                        discountCardHtml += variants[numberOfVariants-1]["FlashSale"] + " : ";
                    }
                    else{
                        discountCardHtml += variants[numberOfVariants-1]["promo"] + " : ";
                    } 

                    var amountCurrency = promotion["title"] + "</div><div class='DiscountCard-subtitle'>";

                    discountCardHtml += amountCurrency.replace("<amount>", (originalPriceNumber-discountedPriceNumber)).replace("<currency>", variant["currency_frequency"]);

                    if(promotion['promotion_start_date'] != "") 
                        discountCardHtml += variants[numberOfVariants-1]["start_date"].replace("<start_date>", promotion['promotion_start_date']);

                    if(promotion['promotion_end_date'] != "") 
                        discountCardHtml += " " + variants[numberOfVariants-1]["end_date"].replace("<end_date>", promotion['promotion_end_date']);
                    
                    discountCardHtml+="</div>";
                    
                    if(promotion['flash_sale'] == "time" && promotion['end_date'] != "0000-00-00 00:00:00"){                        
                        
                        discountCardHtml+="<div class=\"DiscountCard-subtitle\"><div class=\"Counter\" data-timestamp=\""+Math.round((new Date(promotion['end_date'])).getTime() / 1000)+"\"><div class=\"Counter-display Counter-days\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-hours\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-minutes\">00</div>"
                        +"<div class=\"Counter-separator\">:</div><div class=\"Counter-display Counter-seconds\">00</div>"
                        +"<div class=\"Counter-hline\"></div></div></div>";
                    }

                    discountCardHtml+='</div><div class="DiscountCard-colRight"><span><svg width="30px" height="30px" viewBox="0 0 30 30" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"><polygon fill="#000000" points="8 11 15.5002121 19 23 11.0002263 23 11"></polygon></g></svg></span></div></div>';
                    discountCardHtml+="<div class='DiscountCard-body collapse' id='DiscountCard_" + variant["id"] + "'><div class='collapse-content'>" + promotion['description']+"</div></div></div>"; 

                    $(".discount_card_mv").html(discountCardHtml);

                } else {


                    $(firstTab).removeClass();
                    $(firstTab).addClass("Tab");
                    $(firstTab).addClass(getSticker(variant['sticker']));

                    if(k==0){

                        $(firstTabDefault).removeClass();
                        $(firstTabDefault).addClass("Tab");
                        $(firstTabDefault).addClass(getSticker(variant['sticker']));
                    }


                    $("#pvariant_"+variant["id"]).find(".OffreVariation-header").removeClass("OffreVariation-isFlash");
                    $("#pvariant_"+variant["id"]).find(".OffreVariation-header").addClass("OffreVariation-isNouveau");

                    if(variant['sticker'] !== 'none' && variant['sticker'].length > 0){

                        $(firstTab).find(".Tab-icon").css("display","none");

                        if(k==0) $(firstTabDefault).find(".Tab-icon").css("display","none");

                        if(variant['sticker'] === "web"){

                            $(firstTab).find(".Tab-left-offer").html(variants[numberOfVariants-1]["webExclusive"]);
                            if(k==0) $(firstTabDefault).find(".Tab-left-offer").html(variants[numberOfVariants-1]["webExclusive"]);

                        } else if(variant['sticker'] === "orange"){

                            $(firstTab).find(".Tab-left-offer").html(variants[numberOfVariants-1]["orangeExclusive"]);
                            if(k==0) $(firstTabDefault).find(".Tab-left-offer").html(variants[numberOfVariants-1]["orangeExclusive"]);

                        } else if(variant['sticker'] === "new"){

                            $(firstTab).find(".Tab-left-offer").html(variants[numberOfVariants-1]["new"]);
                            if(k==0) $(firstTabDefault).find(".Tab-left-offer").html(variants[numberOfVariants-1]["new"]);
                        }

                    } else {
 
                        $(firstTab).addClass(getSticker(""));
                        $(firstTab).find(".Tab-left-offer").html("");

                        if(k==0) {

                            $(firstTabDefault).addClass(getSticker(""));
                            $(firstTabDefault).find(".Tab-left-offer").html("");
                        }
                    }
                }

                if(variant["productType"] == "offer_postpaid"){

                    if(variant['commitment'] > 0){

                        $("#pvariant_"+variant["id"]).find(".commitment").html(variant['commitment']+" " + variants[numberOfVariants-1]["month(s)"]);

                    } else if(variant['commitment'] == 0){

                        $("#pvariant_"+variant["id"]).find(".OffreVariation-titre").find(".pageStyle-bold-sans").removeClass("d-none");
                    }

                    if(k==0 && numberOfVariants > 1){

                        $(".OffreVariation-forfait").find(".pageStyle-bold").removeClass("d-none");

                        if(variant['commitment'] == 0)
                            $(".OffreVariation-forfait").find(".pageStyle-bold-sans").removeClass("d-none");
                        else
                            $(".OffreVariation-forfait").find(".commitment").html(variant['commitment']+" " + variants[numberOfVariants-1]["month(s)"]);
                    }
                }


                if(variant["productType"] == "offer_prepaid"){

                    $("#pvariant_"+variant["id"]).find(".OffreVariation-titre").find(".pageStyle-bold-sans").removeClass("d-none");
                    $(".OffreVariation-forfait").find(".pageStyle-bold").removeClass("d-none"); 
                    $(".OffreVariation-forfait").find(".pageStyle-bold-sans").removeClass("d-none");
                }

                $("#pvariant_"+variant["id"]).find(".OffreVariation-titre").find(".pageStyle-bold").removeClass("d-none");

                for(var i=0; i < additionalFee.length; i++){

                    warningHtml += '<div class="Warning-title">';
                    warningHtml += '<span data-svg="' + contextPath + '/assets/icons/icon-info.svg"></span> ' + additionalFee[i].name + '</div>';
                    warningHtml += '<div class="Warning-content">';
                    warningHtml += additionalFee[i].description + ' </div><br/>';

                }


                if(warningHtml.length > 0){

                    $("#pvariant_"+variant["id"]).find(".warning-additional-fee").html(warningHtml);
                    $("#pvariant_"+variant["id"]).find(".warning-additional-fee").addClass("Warning");

                    if(k==0) {

                        $(".OffreVariation-forfait").find(".warning-additional-fee").html(warningHtml);
                        $(".OffreVariation-forfait").find(".warning-additional-fee").addClass("Warning");
                    }
                } else {

                    if((numberOfVariants-1) == 1){

                        $(".OffreVariation-forfait").css("border", "0");
                        $(".OffreVariation-forfait").next().css("margin-top", "8px");

                    }
                }

                var count = k+1;
                for(var j = 0; j < comewith.length; j++){

                    var typeText = ( comewith[j].type == "gift" ? variants[numberOfVariants-1]["offer"] : variants[numberOfVariants-1]["include"] );

                    associatedProductHtml += "<div id='AssociatedProduct_" + variant["id"] + "'";
                    
                    if(k==0) associatedProductHtml += "style='display: block;'";
                    else associatedProductHtml += "style='display: none;'";

                    associatedProductHtml += "class='AssociatedProduct-container'>";
                    associatedProductHtml += "<div class='Tab Tab-yellow'>";
                    associatedProductHtml += "<div class='Tab-left'>";
                    associatedProductHtml += typeText + "<div class='Tab-triangle'></div>";
                    associatedProductHtml += "</div><div class='Tab-right'></div></div>";

                    associatedProductHtml += "<div class='AssociatedProduct' data-toggle='modal' data-target='#blocAssociatedProductLightbox" + count + "_" + j + "'>";
                    associatedProductHtml += "<div class='photo'>";
                    associatedProductHtml += "<img src='" + comewith[j].imageUrl + "' alt=''>";
                    associatedProductHtml += "</div>";
                    associatedProductHtml += "<div class='texte'>";
                    associatedProductHtml += "<div class='pageStyle-bold'>" + typeText + "</div>";
                    associatedProductHtml += "<div>" + comewith[j].title + "</div>";
                    associatedProductHtml += "</div></div></div>";
                    
                    associatedProductLightBoxHtml += "<div class='modal fade BlocAssociatedProductLightbox' id='blocAssociatedProductLightbox" + count + "_" + j + "' tabindex='-1' role='dialog' aria-labelledby='blocAssociatedProductLightboxTitle' aria-hidden='true'>";
                    associatedProductLightBoxHtml += "<div class='modal-dialog modal-dialog-centered' role='document'>";
                    associatedProductLightBoxHtml += "<div class='modal-content'>";
                    associatedProductLightBoxHtml += "<div class='BlocAssociatedProductLightbox-innerWrapper'>";
                    associatedProductLightBoxHtml += "<div class='BlocAssociatedProductLightbox-image'>";
                    associatedProductLightBoxHtml += "<img src='" + comewith[j].imageUrl + "' alt=''>";
                    associatedProductLightBoxHtml += "</div>";
                    associatedProductLightBoxHtml += "<div class='BlocAssociatedProductLightbox-texte'>";
                    associatedProductLightBoxHtml += "<h1>" + comewith[j].productName + "</h1>";
                    associatedProductLightBoxHtml += "<div class='pageStyle-bold'>";
                    associatedProductLightBoxHtml += comewith[j].title;
                    associatedProductLightBoxHtml += "</div>";
                    associatedProductLightBoxHtml += "<div>";
                    associatedProductLightBoxHtml += comewith[j].description;
                    associatedProductLightBoxHtml += "</div></div>";
                    associatedProductLightBoxHtml += "<div class='BlocAssociatedProductLightbox-close text-right'>";
                    associatedProductLightBoxHtml += "<img src='" + contextPath + "/assets/icons/icon-close.svg' alt=''></div>";
                    associatedProductLightBoxHtml += "</div></div></div></div>";
                }

                if(associatedProductHtml.length > 0){

                    $(".AssociatedProductComewith").html(associatedProductHtml);
                    $("#associatedProductLightBoxContainer").append(associatedProductLightBoxHtml);
                }
            }

            $(document).trigger("flashCounter.init");
            $(document).trigger("SvgLoader.init");
        },
        error : function()
        {
                console.log("Error while communicating with the server");
        }
    });
};
       


function confirmOffer(portalPath, cartPath, id){

    $.ajax({
        url : portalPath+'calls/updatecart.jsp',
        type: 'post',
        data: {
            id: id
        },
        dataType: 'json',
        success : function(json)
        {
            if(json.status == "SUCCESS"){

                $('<form method="POST" action="' + cartPath + 'cart/cart.jsp'+'"><input type="hidden" name="muid" value="'+______muid+'" ></form>').appendTo('body').submit();
            }
        },
        error : function()
        {
                console.log("Error while communicating with the server");
        }
    });
}

/*
function searchProductCart(path, ids, catAttrIds, attrValues){

    $.ajax({
        url : path+'calls/searchproducts.jsp',
        type: 'post',
        data: {
            productids : ids,
            cat_attr_ids : catAttrIds,
            attr_values : attrValues
        },
        dataType: 'json',
        success : function(json)
        {       
            fillSearchProducts(json)
        },
        error : function()
        {
                alert("Error while communicating with the server");
        }
    });
}
*/

function getSticker(sticker){

    if(sticker === "no" || sticker === "time" || sticker === "quantity")
        return "Tab-orange";
    else if(sticker === "web" || sticker === "orange")
        return "Tab-yellow"
    else if(sticker === "new")
        return "Tab-blue";
    else if(sticker === "out_of_stock")
        return "Tab-red";

    return "Tab-Hidden";

}

function getPromotionType(flashSale){

    if(flashSale === "no")
        return "promotion";
    else if(flashSale === "quantity")
        return "flash_sale_quantity";
    else if(flashSale === "time")
        return "flash_sale_time";

}
