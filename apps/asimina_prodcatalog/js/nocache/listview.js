var promoSortCounter = 0;

function initializeDevices(path, postData, defaultSort) {
  $.ajax({
    url: path + 'calls/getprices.jsp',
    type: 'post',
    data: postData,
    dataType: 'json',
    success: function (json) {
      var products = json.products;

      var product = '';
      var updatedPrice = '';
      var updatedPriceUnformatted = '';
      var promotionPercentage = '';

      var flashSaleDurationdData = [];
      var flashSaleQuantityData = [];
      var regularPromotionData = [];
      var withoutPromotionData = [];
      var outOfStockPromotionData = [];

      var _currency = json.defaultcurrency;

      for (var k = 0; k < products.length; k++) {
        product = products[k];
        updatedPrice = '';
        promotionPercentage = product['promotionPercentage'];

        if (product['tax_exclusive'] === true && k === 0) {
          $('#pricestaxincludediv').hide();
          $('#pricestaxexclusivediv').show();
          $('#pricestaxlabeldiv').show();
        } else if (k === 0) {
          $('#pricestaxexclusivediv').hide();
          $('#pricestaxincludediv').show();
          $('#pricestaxlabeldiv').show();
        }

        if (
          product['attributeValues']['sarhead(watt/kg)'] != undefined &&
          product['attributeValues']['sarhead(watt/kg)'] != ''
        )
          $('#product' + product['id'])
            .find('.TerminauxItem-das')
            .html(
              'DAS : ' +
                product['attributeValues']['sarhead(watt/kg)'] +
                ' W/Kg'
            );

        var firstTab = $('#product' + product['id']).find('.Tab:first');

  		if(product['comeswith'].length > 0){
        		let htmlString ='<div class="TerminauxItem-payback"> <div class="TerminauxItem-payback-colL"></div><div class="TerminauxItem-payback-colR"></div></div>';
        		$("#productcomewith_"+product['id']).show();
  			$("#productcomewith_"+product['id']).find('.TerminauxItem-payback-colR')[0].innerHTML = product['comeswith'][0].title;
        
        		for(let i=1;i<product['comeswith'].length;i++){ 
          			$("#productcomewith_"+product['id']).append(htmlString);
          			$(`#productcomewith_${product['id']} .TerminauxItem-payback .TerminauxItem-payback-colR`)[i].innerText =  product['comeswith'][i].title;
      
        		}
  		}
        if (isEcommerceEnabled && !product['inStock']) {
          if (product['showBasket'] != '0') {
            $(firstTab).removeClass();
            $(firstTab).addClass('Tab');
            $(firstTab).addClass(getSticker('out_of_stock'));

            $(firstTab)
              .find('.Tab-left-offer')
              .html(json.translations['out_of_stock']);
            $(firstTab).find('.Tab-icon').css('display', 'none');
          }

          if (
            !(
              Object.entries(product['promotion']).length === 0 &&
              product['promotion'].constructor === Object
            )
          ) {
            updatedPrice = product['minPriceFrom'];
            updatedPriceUnformatted = product['minPriceFromUnformatted'];
          } else {
            updatedPrice = product['originalPriceFrom'];
            updatedPriceUnformatted = product['originalPriceFromUnformatted'];
          }

          outOfStockPromotionData.push({
            id: product['id'],
            promoDiff: promotionPercentage,
          });
        } else {
          if (
            !(
              Object.entries(product['promotion']).length === 0 &&
              product['promotion'].constructor === Object
            )
          ) {
            updatedPrice = product['minPriceFrom'];
            updatedPriceUnformatted = product['minPriceFromUnformatted'];

            $('#product' + product['id'])
              .find('.TerminauxItem-price-crossed')
              .html('<del>' + product['originalPriceFrom'] + '</del>');

            $(firstTab).removeClass();
            $(firstTab).addClass('Tab');
            $(firstTab).addClass(
              getSticker(product['promotion']['flash_sale'])
            );

            if (product['promotion']['flash_sale'] === 'no') {
              $(firstTab)
                .find('.Tab-left-offer')
                .html(json.translations['promotion']);
              $(firstTab).find('.Tab-icon').css('display', 'none');

              regularPromotionData.push({
                id: product['id'],
                promoDiff: promotionPercentage,
              });
            } else if (
              product['promotion']['flash_sale'] === 'quantity' ||
              product['promotion']['flash_sale'] === 'time'
            ) {
              $(firstTab)
                .find('.Tab-left-offer')
                .html(json.translations['flash_sale']);
              $(firstTab).find('.Tab-icon').css('display', 'block');

              if (product['promotion']['flash_sale'] === 'quantity') {
                flashSaleQuantityData.push({
                  id: product['id'],
                  promoDiff: promotionPercentage,
                });
              } else if (product['promotion']['flash_sale'] === 'time') {
                flashSaleDurationdData.push({
                  id: product['id'],
                  promoDiff: promotionPercentage,
                });
              }
            }

            //                        $("#product"+product["id"]).attr("data-dl_promotion_type",getPromotionType(product['promotion']['flash_sale']));

            if (
              product['promotion']['flash_sale'] == 'time' &&
              product['promotion']['end_date'] != '0000-00-00 00:00:00'
            ) {
              $('#product' + product['id'])
                .find('.promotion-sale-active')
                .css('display', 'block');
              $('#product' + product['id'])
                .find('.promotion-sale-active')
                .find('.Counter')
                .attr(
                  'data-timestamp',
                  Math.round(
                    new Date(product['promotion']['end_date']).getTime() / 1000
                  )
                );
              //$(document).trigger('flashCounter.init');
            } else if (product['promotion']['flash_sale'] == 'quantity') {
              if (undefined !== json['flashSaleQuantity_' + product['id']])
                flashSaleQuantity =
                  "<div class='Tab-additional promotion-flash-sale-quantity'>" +
                  json['flashSaleQuantity_' + product['id']] +
                  '</div>';

              $('#product' + product['id'])
                .find('.promotion-sale-active')
                .css('display', 'block');
              $('#product' + product['id'])
                .find('.promotion-sale-active')
                .html(flashSaleQuantity);
            }
          } else {
            withoutPromotionData.push({
              id: product['id'],
              promoDiff: promotionPercentage,
            });

            updatedPrice = product['originalPriceFrom'];
            updatedPriceUnformatted = product['originalPriceFromUnformatted'];

            $(firstTab).removeClass();
            $(firstTab).addClass('Tab');

            if (product['variantStickerColor'].length > 0) {
              $(firstTab).attr(
                'style',
                'border-bottom: 2px solid ' + product['variantStickerColor']
              );
              $(firstTab)
                .find('.Tab-left')
                .attr(
                  'style',
                  'background-color: ' + product['variantStickerColor']
                );
            }

            if (
              product['variantSticker'] !== 'none' &&
              product['variantSticker'].length > 0
            ) {
/*
              if (product['variantSticker'] === 'web') {
                $(firstTab)
                  .find('.Tab-left-offer')
                  .html(json.translations['web']);
              } else if (product['variantSticker'] === 'orange') {
                $(firstTab)
                  .find('.Tab-left-offer')
                  .html(json.translations['orange']);
              } else if (product['variantSticker'] === 'new') {
                alert("new")
                $(firstTab)
                  .find('.Tab-left-offer')
                  .html(json.translations['new']);
              } else {
*/

                $(firstTab)
                  .find('.Tab-left-offer')
                  .html(json.translations[product['variantSticker']]);
//              }
            } else {
              $(firstTab).addClass(getSticker(''));
              $(firstTab).find('.Tab-left-offer').html('');
            }
          }
        }

        if (product['isShowPrice']) {

			if(product["isVariantPricesDiffer"] == "1"){
				$('#product' + product['id'])
	        	.find('.TerminauxItem-price-title')
	            .html(json.translations['starting_from']);
        	}else{
				$('#product' + product['id'])
	        	.find('.TerminauxItem-price-title')
	            .html(json.translations['price_only']);
        	}
          $('#product' + product['id'])
            .find('.TerminauxItem-price-amount')
            .html(updatedPrice);
        } else {
          $('#product' + product['id'])
            .find('.TerminauxItem-price')
            .addClass('d-none');
        }

        updateDevicePrices(product['id'], updatedPriceUnformatted);

        addProductImpressionAttributes(
          product,
          json.extra_product_impression_attrs,
          json.langJSONPrefix
        );
      }

      if (flashSaleDurationdData.length > 0) {
        flashSaleDurationdData.sort(function (a, b) {
          return b.promoDiff - a.promoDiff;
        });
      }

      if (flashSaleQuantityData.length > 0) {
        flashSaleQuantityData.sort(function (a, b) {
          return b.promoDiff - a.promoDiff;
        });
      }

      if (regularPromotionData.length > 0) {
        regularPromotionData.sort(function (a, b) {
          return b.promoDiff - a.promoDiff;
        });
      }

      if (withoutPromotionData.length > 0) {
        withoutPromotionData.sort(function (a, b) {
          return b.promoDiff - a.promoDiff;
        });
      }

      promotionSortSeq(flashSaleDurationdData);
      promotionSortSeq(flashSaleQuantityData);
      promotionSortSeq(regularPromotionData);
      promotionSortSeq(withoutPromotionData);
      promotionSortSeq(outOfStockPromotionData);

      var productUpdatedMinPrice = Math.floor(json.productUpdatedMinPrice);
      var productUpdatedMaxPrice = Math.ceil(json.productUpdatedMaxPrice);

      $('#inputPriceMin').val(productUpdatedMinPrice);
      $('#inputPriceMax').val(productUpdatedMaxPrice);

//      var j = 1;
//      $('.etn-products-list').each(function () {
//        $(this).attr('data-pi_position', j++);
//      });

      $(document).trigger('SvgLoader.init');
      $(document).trigger('TerminauxListe.initNoUiSlider');

      sortDevices(defaultSort);
      pushProductsImpression(_currency);
	  $(document).trigger('flashCounter.init');
    },
    error: function () {
      console.log('Error while communicating with the server');
    },
  });
}

function promotionSortSeq(promotionDevice) {
  for (var i in promotionDevice) {
    //console.log(promotionDevice[i].id);
    updateDevicePromotionOrder(promotionDevice[i].id);
  }
}

function initializeOffers(path, postData) {
  $.ajax({
    url: path + 'calls/getprices.jsp',
    type: 'post',
    data: postData,
    dataType: 'json',
    success: function (json) {
      var products = json.products;
      var product = '';
      var flashSaleQuantity = '';

      var _currency = json.defaultcurrency;

      for (var k = 0; k < products.length; k++) {
        product = products[k];

        if (product['tax_exclusive'] === true && k === 0) {
          $('#pricestaxincludediv').hide();
          $('#pricestaxexclusivediv').show();
          $('#pricestaxlabeldiv').show();
        } else if (k === 0) {
          $('#pricestaxexclusivediv').hide();
          $('#pricestaxincludediv').show();
          $('#pricestaxlabeldiv').show();
        }

        if (product['isShowPrice']) {
          if (
            !(
              Object.entries(product['promotion']).length === 0 &&
              product['promotion'].constructor === Object
            )
          ) {
            $('#product' + product['id'])
              .find('.OffreItem-price')
              .find('.underline')
              .html(product['originalPriceFrom'] + '<br/>');

            var firstTab = $('#product' + product['id']).find('.Tab:first');
            $(firstTab).removeClass();
            $(firstTab).addClass('Tab');

            if (product['promotion']['flash_sale'] !== 'quantity')
              $(firstTab).addClass(
                getSticker(product['promotion']['flash_sale'])
              );
            else $(firstTab).addClass(getSticker(''));

            if (product['promotion']['flash_sale'] === 'no') {
              $(firstTab)
                .find('.Tab-left-offer')
                .html(json.translations['promotion']);
              $(firstTab).find('.Tab-icon').css('display', 'none');
            } else if (product['promotion']['flash_sale'] === 'time') {
              $(firstTab)
                .find('.Tab-left-offer')
                .html(json.translations['flash_sale']);
              $(firstTab).find('.Tab-icon').css('display', 'block');
            }
          } else {
            var firstTab = $('#product' + product['id']).find('.Tab:first');

            $(firstTab).removeClass();
            $(firstTab).addClass('Tab');

            if (product['variantStickerColor'].length > 0) {
              $(firstTab).attr(
                'style',
                'border-bottom: 2px solid ' + product['variantStickerColor']
              );
              $(firstTab)
                .find('.Tab-left')
                .attr(
                  'style',
                  'background-color: ' + product['variantStickerColor']
                );
            }

            if (
              product['variantSticker'] !== 'none' &&
              product['variantSticker'].length > 0
            ) {
/*
              if (product['variantSticker'] === 'web') {
                $(firstTab)
                  .find('.Tab-left-offer')
                  .html(json.translations['web']);
              } else if (product['variantSticker'] === 'orange') {
                $(firstTab)
                  .find('.Tab-left-offer')
                  .html(json.translations['orange']);
              } else if (product['variantSticker'] === 'new') {
                $(firstTab)
                  .find('.Tab-left-offer')
                  .html(json.translations['new']);
              } else {
*/

                $(firstTab)
                  .find('.Tab-left-offer')
                  .html(json.translations[product['variantSticker']]);

//              }

            } else {
              $(firstTab).addClass(getSticker(''));
              $(firstTab).find('.Tab-left-offer').html('');
            }
          }

          if (
            Object.entries(product['promotion']).length === 0 &&
            product['promotion'].constructor === Object
          ) {
            $('#product' + product['id'])
              .find('.OffreItem-price')
              .find('.pageStyle-boldOrange')
              .html(product['originalPriceFrom']);

            if (product['productType'] !== 'offer_postpaid')
              $('#product' + product['id'])
                .find('.OffreItem-price')
                .find('.little')
                .html('');
          } else {
            $('#product' + product['id'])
              .find('.OffreItem-price')
              .find('.pageStyle-boldOrange')
              .html(product['minPriceFrom']);

            if (
              product['minPriceFrom'] == 'Gratuit' ||
              product['minPriceFrom'] == 'free'
            )
              $('#product' + product['id'])
                .find('.OffreItem-price')
                .find('.little')
                .html('');
          }
        } else {
          $('#product' + product['id'])
            .find('.OffreItem-price')
            .addClass('d-none');
        }

        if (
          !(
            Object.entries(product['promotion']).length === 0 &&
            product['promotion'].constructor === Object
          )
        ) {
          //                    $("#product"+product["id"]).attr("data-dl_promotion_type", getPromotionType(product['promotion']['flash_sale']));

          if (
            product['promotion']['flash_sale'] == 'time' &&
            product['promotion']['end_date'] != '0000-00-00 00:00:00'
          ) {
            $('#product' + product['id'])
              .find('.promotion-sale-active')
              .find('.Counter')
              .attr(
                'data-timestamp',
                Math.round(
                  new Date(product['promotion']['end_date']).getTime() / 1000
                )
              );
            $('#product' + product['id'])
              .find('.promotion-sale-active')
              .css('display', 'block');
          }
        }

        if (product['productType'] == 'offer_postpaid') {
          if (product['variant_commitment'] > 0) {
            $('#product' + product['id'])
              .find('#offreItem-commitment')
              .html(
                json.translations['commitment'] +
                  ' ' +
                  product['variant_commitment'] +
                  ' ' +
                  json.translations['month']
              );
          } else {
            $('#product' + product['id'])
              .find('#offreItem-commitment')
              .html(json.translations['without_engagement']);
          }
        }

        addProductImpressionAttributes(
          product,
          json.extra_product_impression_attrs,
          json.langJSONPrefix
        );
      }

      $(document).trigger('flashCounter.init');
      $(document).trigger('SvgLoader.init');

      var j = 1;
      $('.etn-offers-list').each(function () {
        $(this).attr('data-pi_position', j++);
      });

      pushProductsImpression(_currency);
    },
    error: function () {
      console.log('Error while communicating with the server');
    },
  });
}

function addProductImpressionAttributes(product, extra_attrs, langJSONPrefix) {
  //add all product impression attributes
  var obj = $('#product' + product['id']);
  //console.log(product["id"] + " : : " + obj.length);
  if (obj.length > 0) {
    obj.attr('data-pi_category', product['productImpressionCategory']);
    obj.attr('data-pi_brand', product['brandName']);
    obj.attr('data-pi_id', product['sku']);
    obj.attr('data-pi_name', product[langJSONPrefix + 'Name']);
    obj.attr('data-pi_variant', product['minPriceVariantName']);
    obj.attr('data-pi_price', product['minDlPrice']);

    for (var key in product.extraImpressionAttrs) {
      obj.attr('data-extra_' + key, product.extraImpressionAttrs[key]);
    }
    //after setting all attributes check if attributes coming in dimensionX, dimensionXX, metricXX exists in html then add these attributes as well

    for (var key in extra_attrs) {
      if ($(obj)[0].hasAttribute(extra_attrs[key]))
        obj.attr('data-pi_' + key, obj.attr(extra_attrs[key]));
      else obj.attr('data-pi_' + key, '');
    }
  }
}

function pushProductsImpression(_currency) {
  if (typeof dataLayer !== 'undefined' && dataLayer != null) {
    var productImpression = new Object();
    var ecommerceObj = new Object();
    ecommerceObj.currencyCode = _currency;
    productImpression.ecommerce = ecommerceObj;

    var products = [];
    $('.etn-dl-product-impression').each(function () {
      var product = new Object();

      for (var i = 0; i < this.attributes.length; i++) {
        if ((this.attributes[i].nodeName + '').indexOf('data-pi_') > -1) {
          var _dlc = this.attributes[i].nodeName.substring('data-pi_'.length);
          product[_dlc] = this.attributes[i].value;
        }
      }
      product.list = 'Search Results';

      products.push(product);
    });
    ecommerceObj.impressions = products;
    productImpression.event_action = '';
    productImpression.event_category = '';
    productImpression.event_label = '';

    dataLayer.push(productImpression);
  }
}

function initializeOfferDetail(path, postData, contextPath) {
  return new Promise((resolve,reject)=>{
  $.ajax({
    url: path + 'calls/getvariantprices.jsp',
    type: 'post',
    data: postData,
    dataType: 'json',
    success: function (json) {
      var variants = json.variants;
      var variant = '';
      var promotion = '';
      var updatedPrice = '';
      var additionalFee = '';
      var flashSaleQuantity = '';
      var warningHtml = '';
      var discountCardHtml = '';
      var comewith = '';
      var associatedProductHtml = '';
      var associatedProductLightBoxHtml = '';
      var originalPriceNumber = 0;
      var discountedPriceNumber = 0;

      for (var k = 0; k < variants.length; k++) {
        variant = variants[k];
        promotion = variant['promotion'];
        additionalFee = variant['additionalFee'];
        comewith = variant['comewith'];
        warningHtml = '';

        var obj = $('#pvariant_' + variant['id']);
        if (obj.length > 0) {
          if (variant.is_default == true) obj.addClass('etn-default-variant');
        }

        if (variant['tax_exclusive'] === true && k === 0) {
          $('#pricestaxincludediv').hide();
          $('#pricestaxexclusivediv').show();
        } else if (k === 0) {
          $('#pricestaxexclusivediv').hide();
          $('#pricestaxincludediv').show();
        }

        originalPriceNumber = parseInt(
          variant['originalPriceFrom'].replace(/\,/g, '')
        );
        discountedPriceNumber = parseInt(
          variant['minPriceFrom'].replace(/\,/g, '')
        );

        if (
          !(
            Object.entries(promotion).length === 0 &&
            promotion.constructor === Object
          )
        )
          updatedPrice = variant['minPriceFrom'];
        else updatedPrice = variant['originalPriceFrom'];

        if (updatedPrice != 'Gratuit' && updatedPrice != 'free') {

          var currFreqSpan = '<span>' + variant['currency_frequency'];
          if (variant['productType'] == 'offer_postpaid') {
            currFreqSpan += '/' + json.translations['month'];
          }
          currFreqSpan += '</span>';

          if(variant['currencyPosition'] == "before"){
            updatedPrice = currFreqSpan +" "+ updatedPrice;
          } else{
            updatedPrice += " "+ currFreqSpan;
          }
        }

        if (variant['isShowPrice'] == '1') {
          $('#pvariant_' + variant['id'])
            .find('.OffreVariation-price')
            .html(updatedPrice);
        } else if (variant['isShowPrice'] == '0') {
          $('#pvariant_' + variant['id'])
            .find('.OffreVariation-price')
            .html(json.translations['price_display_label']);
        }

        if (k == 0 && variant['isShowPrice'] == '1')
          $('.OffreVariation-forfait')
            .find('.pageStyle-boldOrange')
            .html(updatedPrice);
        else if (k == 0 && variant['isShowPrice'] == '0')
          $('.OffreVariation-forfait')
            .find('.pageStyle-boldOrange')
            .html(json.translations['price_display_label']);

        updatedPrice = '';

        if (
          !(
            Object.entries(promotion).length === 0 &&
            promotion.constructor === Object
          )
        ) {
          //                    $("#pvariant_"+variant["id"]).attr("data-dl_promotion_type", getPromotionType(promotion['flash_sale']));
          //                    $(".etn-data-layer").attr("data-dl_promotion_type", getPromotionType(promotion['flash_sale']));

          if (promotion['duration'].length > 0 && promotion['duration'] > 0) {
            updatedPrice +=
              'Pendant ' +
              promotion['duration'] +
              ' ' +
              json.translations['month'] +
              ' ';
          }
        }

        if (variant['productType'] == 'offer_postpaid')
          updatedPrice += json.translations['then'] + ' ';
        else if (variant['productType'] == 'offer_prepaid')
          updatedPrice += json.translations['instead_of'] + ' ';

        var firstTab = $('#pvariant_' + variant['id']).find('.Tab:first');
        var firstTabDefault = $('.Offre-buttons').find('.Tab:first');

        if (
          !(
            Object.entries(promotion).length === 0 &&
            promotion.constructor === Object
          )
        ) {
          updatedPrice +=
            variant['originalPriceFrom'] + ' ' + variant['currency_frequency'];

          if (variant['productType'] == 'offer_postpaid') {
            updatedPrice += '/' + json.translations['month'];
          }

          if (variant['isShowPrice'] == '1') {
            $('#pvariant_' + variant['id'])
              .find('.OffreVariation-engagement')
              .html(updatedPrice);
          } else if (variant['isShowPrice'] == '0') {
            $('#pvariant_' + variant['id'])
              .find('.OffreVariation-engagement')
              .html('');
          }

          if (k == 0)
            $('.OffreVariation-forfait').find('.engagement').html(updatedPrice);

          if (
            promotion['flash_sale'] == 'time' &&
            promotion['end_date'] != '0000-00-00 00:00:00'
          ) {
            $('#pvariant_' + variant['id'])
              .find('.promotion-sale-active')
              .find('.Counter')
              .attr(
                'data-timestamp',
                Math.round(new Date(promotion['end_date']).getTime() / 1000)
              );
            $('#pvariant_' + variant['id'])
              .find('.promotion-sale-active')
              .css('display', 'block');

            if (k == 0) {
              $('.Offre-detail')
                .find('.promotion-sale-active')
                .find('.Counter')
                .attr(
                  'data-timestamp',
                  Math.round(new Date(promotion['end_date']).getTime() / 1000)
                );
              $('.Offre-detail')
                .find('.promotion-sale-active')
                .css('display', 'block');
            }
          }

          $(firstTab).removeClass();
          $(firstTab).addClass('Tab');

          if (promotion['flash_sale'] !== 'quantity') {
            $(firstTab).addClass(getSticker(promotion['flash_sale']));
            if (k == 0)
              $(firstTabDefault).addClass(getSticker(promotion['flash_sale']));
          } else {
            if (k == 0) {
              $(firstTab).addClass(getSticker(''));

              $(firstTabDefault).removeClass();
              $(firstTabDefault).addClass('Tab');
              $(firstTabDefault).addClass(getSticker(''));
            }
          }

          if (promotion['flash_sale'] === 'no') {
            $(firstTab)
              .find('.Tab-left-offer')
              .html(json.translations['promotion']);
            $(firstTab).find('.Tab-icon').css('display', 'none');

            if (k == 0) {
              $(firstTabDefault)
                .find('.Tab-left-offer')
                .html(json.translations['promotion']);
              $(firstTabDefault).find('.Tab-icon').css('display', 'none');
            }
          } else if (promotion['flash_sale'] === 'time') {
            $(firstTab)
              .find('.Tab-left-offer')
              .html(json.translations['flash_sale']);
            $(firstTab).find('.Tab-icon').css('display', 'block');

            if (k == 0) {
              $(firstTabDefault)
                .find('.Tab-left-offer')
                .html(json.translations['flash_sale']);
              $(firstTabDefault).find('.Tab-icon').css('display', 'block');
            }
          }

          //                    $("#pvariant_"+variant["id"]).attr("data-dl_promotion_type",getPromotionType(promotion['flash_sale']));
          $('#pvariant_' + variant['id'])
            .find('.OffreVariation-header')
            .removeClass('OffreVariation-isNouveau');
          $('#pvariant_' + variant['id'])
            .find('.OffreVariation-header')
            .addClass('OffreVariation-isFlash');

          if (
            promotion['flash_sale'] == 'time' &&
            promotion['end_date'] != '0000-00-00 00:00:00'
          ) {
            $('#pvariant_' + variant['id'])
              .find('.promotion-sale-active')
              .css('display', 'block');
            $('#pvariant_' + variant['id'])
              .find('.promotion-sale-active')
              .find('.Counter')
              .attr(
                'data-timestamp',
                Math.round(
                  new Date(variant['promotion']['end_date']).getTime() / 1000
                )
              );
          }

          discountCardHtml += "<div style='display: ";

          if (k == 0) discountCardHtml += 'block;';
          else discountCardHtml += 'none;';

          var __eventLabel = '';
          if (promotion['flash_sale'] != 'no')
            __eventLabel = json.translations['flash_sale'];
          else __eventLabel = json.translations['promo'];
          __eventLabel += ' : ' + promotion['title'];

          discountCardHtml +=
            "' class='DiscountCard etn-data-layer-event' data-dl_event_category='promo' data-dl_event_action='tab_click' data-dl_event_label='" +
            __eventLabel.replace('"', '&#34;').replace("'", '&#39;') +
            "'><div class='DiscountCard-header collapsed' data-toggle='collapse' data-target='#DiscountCard_" +
            variant['id'] +
            "' aria-expanded='false'><div class='DiscountCard-colLeft'><div class='DiscountCard-title'>";

          if (promotion['flash_sale'] != 'no') {
            discountCardHtml += json.translations['flash_sale'] + ' : ';
          } else {
            discountCardHtml += json.translations['promo'] + ' : ';
          }

          var amountCurrency =
            promotion['title'] + "</div><div class='DiscountCard-subtitle'>";

          discountCardHtml += amountCurrency
            .replace('<amount>', originalPriceNumber - discountedPriceNumber)
            .replace('<currency>', variant['currency_frequency']);

          if (promotion['promotion_start_date'] != '')
            discountCardHtml += json.translations['start_date'].replace(
              '<start_date>',
              promotion['promotion_start_date']
            );

          if (promotion['promotion_end_date'] != '')
            discountCardHtml +=
              ' ' +
              json.translations['end_date'].replace(
                '<end_date>',
                promotion['promotion_end_date']
              );

          discountCardHtml += '</div>';

          if (
            promotion['flash_sale'] == 'time' &&
            promotion['end_date'] != '0000-00-00 00:00:00'
          ) {
            discountCardHtml +=
              '<div class="DiscountCard-subtitle"><div class="Counter" data-timestamp="' +
              Math.round(new Date(promotion['end_date']).getTime() / 1000) +
              '"><div class="Counter-display Counter-days">00</div>' +
              '<div class="Counter-separator">:</div><div class="Counter-display Counter-hours">00</div>' +
              '<div class="Counter-separator">:</div><div class="Counter-display Counter-minutes">00</div>' +
              '<div class="Counter-separator">:</div><div class="Counter-display Counter-seconds">00</div>' +
              '<div class="Counter-hline"></div></div></div>';
          }

          discountCardHtml +=
            '</div><div class="DiscountCard-colRight"><span><svg width="30px" height="30px" viewBox="0 0 30 30" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd"><polygon fill="#000000" points="8 11 15.5002121 19 23 11.0002263 23 11"></polygon></g></svg></span></div></div>';
          discountCardHtml +=
            "<div class='DiscountCard-body collapse' id='DiscountCard_" +
            variant['id'] +
            "'><div class='collapse-content'>" +
            promotion['description'] +
            '</div></div></div>';

          $('.discount_card_mv').html(discountCardHtml);
        } else {
          $(firstTab).removeClass();
          $(firstTab).addClass('Tab');

          if (variant['variantStickerColor'].length > 0) {
            $(firstTab).attr(
              'style',
              'border-bottom: 2px solid ' + variant['variantStickerColor']
            );
            $(firstTab)
              .find('.Tab-left')
              .attr(
                'style',
                'background-color: ' + variant['variantStickerColor']
              );
          }

          if (k == 0) {
            $(firstTabDefault).removeClass();
            $(firstTabDefault).addClass('Tab');

            if (variant['variantStickerColor'].length > 0) {
              $(firstTabDefault).attr(
                'style',
                'border-bottom: 2px solid ' + variant['variantStickerColor']
              );
              $(firstTabDefault)
                .find('.Tab-left')
                .attr(
                  'style',
                  'background-color: ' + variant['variantStickerColor']
                );
            }
          }
/*
          if (variant['sticker'] === 'web' || variant['sticker'] === 'orange') {
            $('#pvariant_' + variant['id'])
              .find('.OffreVariation-header')
              .addClass('OffreVariation-isFlash');
          } else {
            $('#pvariant_' + variant['id'])
              .find('.OffreVariation-header')
              .removeClass('OffreVariation-isFlash');
            $('#pvariant_' + variant['id'])
              .find('.OffreVariation-header')
              .addClass('OffreVariation-isNouveau');
          }
*/
          if (variant['sticker'] !== 'none' && variant['sticker'].length > 0) {
            $(firstTab).find('.Tab-icon').css('display', 'none');

            if (k == 0)
              $(firstTabDefault).find('.Tab-icon').css('display', 'none');
/*
            if (variant['sticker'] === 'web') {
              $(firstTab)
                .find('.Tab-left-offer')
                .html(json.translations['web']);
              if (k == 0)
                $(firstTabDefault)
                  .find('.Tab-left-offer')
                  .html(json.translations['web']);
            } else if (variant['sticker'] === 'orange') {
              $(firstTab)
                .find('.Tab-left-offer')
                .html(json.translations['orange']);
              if (k == 0)
                $(firstTabDefault)
                  .find('.Tab-left-offer')
                  .html(json.translations['orange']);
            } else if (variant['sticker'] === 'new') {
              $(firstTab)
                .find('.Tab-left-offer')
                .html(json.translations['new']);
              if (k == 0)
                $(firstTabDefault)
                  .find('.Tab-left-offer')
                  .html(json.translations['new']);
            } else {
*/

              $(firstTab)
                .find('.Tab-left-offer')
                .html(json.translations[variant['sticker']]);
              if (k == 0)
                $(firstTabDefault)
                  .find('.Tab-left-offer')
                  .html(json.translations[variant['sticker']]);


//            }
          } else {
            $(firstTab).addClass(getSticker(''));
            $(firstTab).find('.Tab-left-offer').html('');

            if (k == 0) {
              $(firstTabDefault).addClass(getSticker(''));
              $(firstTabDefault).find('.Tab-left-offer').html('');
            }
          }
        }

        if (variant['productType'] == 'offer_postpaid') {
          if (variant['commitment'] > 0) {
            $('#pvariant_' + variant['id'])
              .find('.commitment')
              .html(variant['commitment'] + ' ' + json.translations['month']);
          } else if (variant['commitment'] == 0) {
            $('#pvariant_' + variant['id'])
              .find('.OffreVariation-titre')
              .find('.pageStyle-bold-sans')
              .removeClass('d-none');
            $('#pvariant_' + variant['id'])
              .find('.OffreVariation-titre')
              .find('.pageStyle-bold-sans')
              .next()
              .css('text-transform', '');
          }

          if (k == 0 && json.variants.length > 1) {
            $('.OffreVariation-forfait')
              .find('.pageStyle-bold')
              .removeClass('d-none');

            if (variant['commitment'] == 0) {
              $('.OffreVariation-forfait')
                .find('.pageStyle-bold-sans')
                .removeClass('d-none');
              $('.OffreVariation-forfait')
                .find('.pageStyle-bold-sans')
                .next()
                .css('text-transform', '');
            } else
              $('.OffreVariation-forfait')
                .find('.commitment')
                .html(variant['commitment'] + ' ' + json.translations['month']);
          }
        }

        if (variant['productType'] == 'offer_prepaid') {
          $('#pvariant_' + variant['id'])
            .find('.OffreVariation-titre')
            .find('.pageStyle-bold-sans')
            .removeClass('d-none');
          $('#pvariant_' + variant['id'])
            .find('.OffreVariation-titre')
            .find('.pageStyle-bold-sans')
            .next()
            .css('text-transform', '');
          $('.OffreVariation-forfait')
            .find('.pageStyle-bold')
            .removeClass('d-none');
          $('.OffreVariation-forfait')
            .find('.pageStyle-bold-sans')
            .removeClass('d-none');
          $('.OffreVariation-forfait')
            .find('.pageStyle-bold-sans')
            .next()
            .css('text-transform', '');
        }

        $('#pvariant_' + variant['id'])
          .find('.OffreVariation-titre')
          .find('.pageStyle-bold')
          .removeClass('d-none');

        for (var i = 0; i < additionalFee.length; i++) {
          warningHtml += '<div class="Warning-title">';
          warningHtml +=
            '<span data-svg="' +
            contextPath +
            '/assets/icons/icon-info.svg"></span> ' +
            additionalFee[i].name +
            '</div>';
          warningHtml += '<div class="Warning-content">';
          warningHtml += additionalFee[i].description + ' </div><br/>';
        }

        if (warningHtml.length > 0) {
          $('#pvariant_' + variant['id'])
            .find('.warning-additional-fee')
            .html(warningHtml);
          $('#pvariant_' + variant['id'])
            .find('.warning-additional-fee')
            .addClass('Warning');

          if (k == 0) {
            $('.OffreVariation-forfait')
              .find('.warning-additional-fee')
              .html(warningHtml);
            $('.OffreVariation-forfait')
              .find('.warning-additional-fee')
              .addClass('Warning');
          }
        } else {
          if (json.variants.length == 1) {
            $('.OffreVariation-forfait').css('border', '0');
            $('.OffreVariation-forfait').next().css('margin-top', '8px');
          }
        }

        $('#pvariant_' + variant['id']).attr(
          'sticker-color',
          variant['variantStickerColor']
        );

        var count = k + 1;

        for (var j = 0; j < comewith.length; j++) {
          var typeText =
            comewith[j].comewith == 'gift'
              ? json.translations['offer']
              : json.translations['include'];

          associatedProductHtml +=
            "<div id='AssociatedProduct_" + variant['id'] + "'";

          if (k == 0) associatedProductHtml += "style='display: block;'";
          else associatedProductHtml += "style='display: none;'";

          associatedProductHtml +=
            "class='AssociatedProduct-container etn-data-layer-event AssociatedProduct_" +
            variant['id'] +
            "' data-dl_event_category='come-withs' data-dl_event_action='link_click' data-dl_event_label='" +
            comewith[j].title.replace('"', '&#34;').replace("'", '&#39;') +
            "' >";
          associatedProductHtml += "<div class='Tab Tab-yellow'>";
          associatedProductHtml += "<div class='Tab-left'>";
          associatedProductHtml +=
            typeText + "<div class='Tab-triangle'></div>";
          associatedProductHtml += "</div><div class='Tab-right'></div></div>";

          associatedProductHtml +=
            "<div class='AssociatedProduct' data-toggle='modal' data-target='#blocAssociatedProductLightbox" +
            count +
            '_' +
            j +
            "'>";
          associatedProductHtml += "<div class='photo'>";
          associatedProductHtml +=
            "<img style='max-width:70px !important; max-height:auto !important' src='" +
            comewith[j].imageUrl +
            "' alt=''>";
          associatedProductHtml += '</div>';
          associatedProductHtml += "<div class='texte'>";
          associatedProductHtml +=
            "<div class='pageStyle-bold'>" + typeText + '</div>';
          associatedProductHtml += '<div>' + comewith[j].title + '</div>';
          associatedProductHtml += '</div></div></div>';

          associatedProductLightBoxHtml +=
            "<div class='modal fade BlocAssociatedProductLightbox' id='blocAssociatedProductLightbox" +
            count +
            '_' +
            j +
            "' tabindex='-1' role='dialog' aria-labelledby='blocAssociatedProductLightboxTitle' aria-hidden='true'>";
          associatedProductLightBoxHtml +=
            "<div class='modal-dialog modal-dialog-centered' role='document'>";
          associatedProductLightBoxHtml += "<div class='modal-content'>";
          associatedProductLightBoxHtml +=
            "<div class='BlocAssociatedProductLightbox-innerWrapper'>";
          associatedProductLightBoxHtml +=
            "<div class='BlocAssociatedProductLightbox-image'>";
          associatedProductLightBoxHtml +=
            "<img src='" + comewith[j].imageUrl + "' alt=''>";
          associatedProductLightBoxHtml += '</div>';
          associatedProductLightBoxHtml +=
            "<div class='BlocAssociatedProductLightbox-texte'>";
          associatedProductLightBoxHtml +=
            '<h2>' + comewith[j].productName + '</h2>';
          associatedProductLightBoxHtml += "<div class='pageStyle-bold'>";
          associatedProductLightBoxHtml += comewith[j].title;
          associatedProductLightBoxHtml += '</div>';
          associatedProductLightBoxHtml += '<div>';
          associatedProductLightBoxHtml += comewith[j].description;
          associatedProductLightBoxHtml += '</div></div>';
          associatedProductLightBoxHtml +=
            "<div class='BlocAssociatedProductLightbox-close text-right'>";
          associatedProductLightBoxHtml +=
            "<img src='" +
            contextPath +
            "/assets/icons/icon-close.svg' alt=''></div>";
          associatedProductLightBoxHtml += '</div></div></div></div>';
        }

        if (associatedProductHtml.length > 0) {
          $('.AssociatedProductComewith').html(associatedProductHtml);
          $('#associatedProductLightBoxContainer').append(
            associatedProductLightBoxHtml
          );
        }

        addVariantImpressionAttributes(
          variant,
          json.extra_product_impression_attrs,
          json.langJSONPrefix
        );
      }

      pushDefaultVariantImpression();

      $(document).trigger('flashCounter.init');
      $(document).trigger('SvgLoader.init');
      resolve(true);
    },
    error: function () {
      console.log('Error while communicating with the server');
      reject(false);
    },
  });
});
}

function pushDefaultVariantImpression() {
  if (typeof dataLayer !== 'undefined' && dataLayer != null) {
    var that = null;
    if ($('.etn-default-variant').length > 0) {
      that = $('.etn-default-variant')[0];
    } else {
      that = $('.etn-offer-variants')[0];
    }

    var detail = new Object();
    detail.actionField = { list: $(that).attr('data-pi_category') };

    var product = new Object();
    for (var i = 0; i < that.attributes.length; i++) {
      if ((that.attributes[i].nodeName + '').indexOf('data-pi_') > -1) {
        var _dlc = that.attributes[i].nodeName.substring('data-pi_'.length);
        product[_dlc] = that.attributes[i].value;
      }
    }
    var products = [];
    products.push(product);

    detail.products = products;

    var ecommerceObj = new Object();
    ecommerceObj.detail = detail;

    var productImpression = new Object();
    productImpression.ecommerce = ecommerceObj;
    productImpression.event_action = '';
    productImpression.event_category = '';
    productImpression.event_label = '';

    dataLayer.push(productImpression);
  }
}

function addVariantImpressionAttributes(variant, extra_attrs, langJSONPrefix) {
  var obj = $('#pvariant_' + variant['id']);
  if (obj.length > 0) {
    obj.attr('data-pi_category', variant['productImpressionCategory']);
    obj.attr('data-pi_brand', variant['brandName']);
    obj.attr('data-pi_id', variant['sku']);
    obj.attr('data-pi_name', variant['productName']);
    obj.attr('data-pi_variant', variant['variantName']);
    obj.attr('data-pi_price', variant['minDlPrice']);

    for (var key in variant.extraImpressionAttrs) {
      obj.attr('data-extra_' + key, variant.extraImpressionAttrs[key]);
    }
    //after setting all attributes check if attributes coming in dimensionX, dimensionXX, metricXX exists in html then add these attributes as well

    for (var key in extra_attrs) {
      if ($(obj)[0].hasAttribute(extra_attrs[key]))
        obj.attr('data-pi_' + key, obj.attr(extra_attrs[key]));
      else obj.attr('data-pi_' + key, '');
    }
  }
}

function confirmOffer(portalPath, cartPath, id) {
  $.ajax({
    url: portalPath + 'calls/updatecart.jsp',
    type: 'post',
    data: {
      id: id,
      muid: ______muid,
    },
    dataType: 'json',
    success: function (json) {
      if (json.status == 'SUCCESS') {
        $(
          '<form method="GET" action="' +
            cartPath +
            'cart/cart.jsp' +
            '"><input type="hidden" name="muid" value="' +
            ______muid +
            '" ></form>'
        )
          .appendTo('body')
          .submit();
      }
    },
    error: function () {
      console.log('Error while communicating with the server');
    },
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

function getSticker(sticker) {
  if (sticker === 'no' || sticker === 'time' || sticker === 'quantity')
    return 'Tab-orange';
  else if (sticker === 'web' || sticker === 'orange') return 'Tab-yellow';
  else if (sticker === 'new') return 'Tab-blue';
  else if (sticker === 'out_of_stock') return 'Tab-red';

  return 'Tab-Hidden';
}

function getPromotionType(flashSale) {
  if (flashSale === 'no') return 'promotion';
  else if (flashSale === 'quantity') return 'flash_sale_quantity';
  else if (flashSale === 'time') return 'flash_sale_time';
}

function addToCart(id) {
  $.ajax({
    url: portalUrl + 'calls/updatecart.jsp',
    type: 'post',
    data: {
      id: id,
      muid: ______muid,
    },
    dataType: 'json',
    success: function (json) {
      //console.log(":"+json.status+":")
      if (json.status == 'SUCCESS') {
        $('#addModal').modal('toggle');

        if (typeof dataLayer !== 'undefined' && dataLayer != null) {
          var productImpression = new Object();
          productImpression.event = 'addToCart';

          var ecommerceObj = new Object();
          var addObj = new Object();

          var products = [];
          var that = $('#pvariant_' + id)[0];
          var product = new Object();

          for (var i = 0; i < that.attributes.length; i++) {
            if ((that.attributes[i].nodeName + '').indexOf('data-pi_') > -1) {
              var _dlc = that.attributes[i].nodeName.substring(
                'data-pi_'.length
              );
              product[_dlc] = that.attributes[i].value;
            }
          }
          products.push(product);
          addObj.products = products;

          ecommerceObj.add = addObj;
          productImpression.ecommerce = ecommerceObj;
          productImpression.event_action = '';
          productImpression.event_category = '';
          productImpression.event_label = '';

          dataLayer.push(productImpression);
        }
      } else {
        bootbox.alert({ message: json.reason, closeButton: false });
      }
    },
    error: function () {
      console.log('Error while communicating with the server');
    },
  });
}

function proceedToCart(cartUrl) {
  window.location.href = cartUrl + 'cart/cart.jsp?muid=' + ______muid;
}

function continueShopping(obj) {
	let myreferrer = document.referrer;
	let iscartpagereferrer = false;
	if(typeof myreferrer !== 'undefined' && myreferrer.indexOf("cart.jsp") > -1) iscartpagereferrer = true;
	
	let myreferrerhost = document.referrer.split('/')[2];
	let myhost = location.hostname;
	let curl = $(obj).data("continue_url");
	if(typeof curl !== 'undefined' && curl != "")
	{
		window.location.href = curl;	
	}
	else if(typeof myreferrerhost !== 'undefined' && myreferrerhost == myhost && iscartpagereferrer == false)
	{
		window.location.href = myreferrer;
	}
	else
	{
		if(typeof __loadcart === 'function') __loadcart();
		else if(typeof asimina.cf.cart !== 'undefined' && typeof asimina.cf.cart.load === 'function') asimina.cf.cart.load();
	}
}