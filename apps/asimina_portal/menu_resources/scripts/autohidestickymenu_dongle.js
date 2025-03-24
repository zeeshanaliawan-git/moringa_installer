;( function( $, window, document, undefined )
{
	'use strict';

	var elSelector		= '#topmenu',
		$element		= $( elSelector );
	var elSelector2		= '#secondtopmenu',
		$element2		= $( elSelector2 );
	var elSelector3		= '#thirdtopmenu',
		$element3		= $( elSelector3 );

	if( !$element.length ) return true;

	var elHeight		= 0,
		elHeight2		= 0,
		elHeight3		= 0,
		elTop			= 0,
		elTop2			= 0,
		elTop3			= 0,
		$document		= $( document ),
		dHeight			= 0,
		$window			= $( window ),
		wHeight			= 0,
		wScrollCurrent	= 0,
		wScrollBefore	= 0,
		wScrollDiff		= 0;

	$window.on( 'scroll', function()
	{
		elHeight		= $element.outerHeight();
		elHeight2		= $element2.outerHeight();
		elHeight3		= $element3.outerHeight();
		dHeight			= $document.height();
		wHeight			= $window.height();
		wScrollCurrent	= $window.scrollTop();
		wScrollDiff		= wScrollBefore - wScrollCurrent;
		elTop			= parseInt( $element.css( 'top' ) ) + wScrollDiff;
		elTop2			= parseInt( $element2.css( 'top' ) ) + wScrollDiff;
		elTop3			= parseInt( $element3.css( 'top' ) ) + wScrollDiff;

		if( wScrollCurrent <= 0 ){ // scrolled to the very top; element sticks to the top

			$element.css( 'top', 0 );
			if($('#thirdtopmenu').hasClass('shadow')){
				$('#thirdtopmenu').removeClass('shadow');
			}

		}else if( wScrollDiff > 0 ){ // scrolled up; element slides in

			$element.css( 'top', elTop > 0 ? 0 : elTop );
			$element2.css( 'top', elTop2 > $element.height() ? $element.height() : elTop2 );
			$element3.css( 'top', elTop3 > $element.height() + $element2.height() ? $element.height() + $element2.height() : elTop3 );
			
			$('#thirdtopmenu').removeClass('bgblack');

		}else if( wScrollDiff < 0 ){ // scrolled down
			closeContextualMenu();
			closeMenu();
			closeMenu320();

			if($('#thirdtopmenu').hasClass('open')){
				$('#thirdtopmenu').removeClass('shadow');
			}else{
				$('#thirdtopmenu').addClass('shadow');
			}
			//if(wScrollCurrent <= $('.dongle').offset().top - $element3.height() - $element2.height() - $element.height() + 10){}else{
			if(wScrollCurrent <= 0){}else{


				$element.css( 'top', Math.abs( elTop ) > elHeight ? -elHeight : elTop );

				$element2.css( 'top', Math.abs( elTop2 ) > elHeight2 ? -elHeight2 : elTop2 );

				if($element3.css('top') <= 0 ){
				}else{
					$element3.css('top', Math.abs( elTop3 ) > elTop3 ? 0 : elTop2 + elHeight2 );
				}
				if($element3.css('top') == "0px"){
					$('#thirdtopmenu').addClass('bgblack');
				}

				// if($element2.css('top') <= 0 ){
				// }else{
				// 	$element2.css('top', Math.abs( elTop ) > elHeight ? 0 : elTop + elHeight );
				// }

				// $element3.css('top', Math.abs( elTop3 ) > elHeight + elHeight2 ? -elHeight3 : elTop3);
				// closeContextualMenu();
			}

		}

		if($element.css('top') == '-' + $element.height() + 'px'){
			$('#topmenu').addClass('scrolled');
		}else{
			$('#topmenu').removeClass('scrolled');
		}

		wScrollBefore = wScrollCurrent;
	});

})( jQuery, window, document );
// function openMenu(){
// 	var elSelector = '#secondtopmenu', $element = $( elSelector );
// 	$element.css( 'top', $('#topmenucontent').height() );
// 	$('#topmenu').removeClass('scrolled');
// 	$('#secondtopmenucontent div input[type="text"]').focus();
// }

	