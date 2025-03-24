// $(document).ready(function() {
// 	if($( document ).width() < 753){
// 		$('#container > div:nth-child(1) > div > div.boutique > img:nth-child(3)').attr('src', 'img/shop/menu_icon_white.png');
// 	}
// });


// function openBoutique(img){
// 	if($('div.service > nav').hasClass('open')){
// 		$('div.service > nav').removeClass('open');
// 		$('div.service > nav').css( 'max-height', '0px');
// 		$('#container > div:nth-child(1) > div > div.shortcuts').css( 'max-height', '0px');
// 		if($( document ).width() < 768){
// 			img.attr('src', 'img/shop/menu_icon_white.png');
// 			setTimeout( function(){
//       			$('#container > div.maxwidth > div.service > div.boutique').css( 'position', 'initial');
//       			$('#container').css( 'margin-top', '36px');
//       		},1100);
// 		}else{
// 			img.attr('src', 'img/arrow_down.png');
// 		}
// 	}else{
// 		$('div.service > nav').addClass('open');
// 		$('div.service > nav').css( 'max-height', '2000px');
// 		$('#container > div:nth-child(1) > div > div.shortcuts').css( 'max-height', '2000px');
// 		img.attr('src', 'img/arrow_up_orange.png');
// 		if($( document ).width() < 768){
// 			$('#container > div.maxwidth > div.service > div.boutique').css( 'position', 'fixed');
//       			$('#container').css( 'margin-top', '86px');
// 		}
// 	}
// }

function openMoney(img){
	if($('div.money > ul').hasClass('open')){
		$('div.money > ul').removeClass('open');
		$('div.money > ul').css( 'max-height', '0px');
		$('div.money > div.close').css( 'max-height', '0px');
		$('#container > div:nth-child(8) > div > a > img').attr('src', 'img/shop/arrow_down_white.png');
	}else{
		$('div.money > ul').addClass('open');
		$('div.money > ul').css( 'max-height', '2000px');
		$('div.money > div.close').css( 'max-height', '2000px');
		$('#container > div:nth-child(8) > div > a > img').attr('src', 'img/shop/arrow_up_white.png');
	}
}

// function openSubBoutique(img){
// 	if(img.parent().hasClass('open')){
// 		img.parent().removeClass('open');
// 		$('div.service > nav > ul > li:nth-child(3) > ul').css( 'max-height', '0px');
// 		img.attr('src', 'img/shop/arrow_down_grey.png');
// 	}else{
// 		img.parent().addClass('open');
// 		$('div.service > nav > ul > li:nth-child(3) > ul').css( 'max-height', '2000px');
// 		img.attr('src', 'img/shop/arrow_up_orange.png');
// 	}
// }