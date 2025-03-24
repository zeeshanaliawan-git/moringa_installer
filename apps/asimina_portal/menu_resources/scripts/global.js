var timeouts = [];
function clearTimeouts(){
	for (var i = 0; i < timeouts.length; i++) {
	    clearTimeout(timeouts[i]);
	}
	timeouts = [];
}

$('#secondtopmenucontent > nav > ul > li').hover(
	function(){
		if($(window).width() >= 768){
			clearTimeouts();
			$('#secondtopmenucontent > nav > ul > li > div').removeClass('open');
			$('#secondtopmenucontent > nav > ul > li').removeClass('color_orange');

			$(this).addClass('color_orange');
			$(this).children('div').addClass('open');
		}
	},
	function(){
		if($(window).width() >= 768){
			timeouts.push(
				setTimeout(
				  	function(){
						$('#secondtopmenucontent > nav > ul > li > div').removeClass('open');
						$('#secondtopmenucontent > nav > ul > li').removeClass('color_orange');
				  	},
				  	15000
				)
			);
		}
	}
);

$('#secondtopmenucontent > nav > ul > li:nth-child(1) > div').hover(
	function(){
		clearTimeouts();
	},
	function(){
	}
);

function closeMenu(){
	clearTimeouts();
	$('#secondtopmenucontent > nav > ul > li > div').removeClass('open');
	$('#secondtopmenucontent > nav > ul > li').removeClass('color_orange');
}

function openMenu320(){
	if(!$('#secondtopmenucontent > nav').hasClass('open')){
		$('#secondtopmenucontent > div.search_dropdown').addClass('open');
		$('#secondtopmenucontent > div.search > img').attr('src', 'img/search.png');
		$('#secondtopmenucontent > nav').addClass('open');
	}else{
		closeMenu320();
	}
}

function closeMenu320(){
	$('#secondtopmenucontent > nav').removeClass('open');
	if($('#secondtopmenu > #secondtopmenucontent > div.search_dropdown').hasClass('open')){
		dropdown_search();
	}
}

function dropdown_search(){
	if($(window).width() < 960){
		// if(!$('#secondtopmenucontent > nav').hasClass('open')){
			if($('#secondtopmenucontent > div.search_dropdown').hasClass('open')){
				$('#secondtopmenucontent > div.search_dropdown').removeClass('open');
				$('#secondtopmenucontent > div.search.color_black.f16 > img').attr('src', 'img/search.png');
			}else{
				$('#secondtopmenucontent > div.search_dropdown').addClass('open');
				$('#secondtopmenucontent > div.search.color_black.f16 > img').attr('src', 'img/search_orange.png');
			}
		//}
	}
}
$('#secondtopmenucontent > div.search_dropdown > input').keyup(function() {
	checkIfSearchInputIsFilled();
});

function checkIfSearchInputIsFilled(){
	if($('#secondtopmenucontent > div.search_dropdown > input').val() != ""){
		$('#secondtopmenucontent > div.search_dropdown > input').addClass('filled');	
	}else{
		$('#secondtopmenucontent > div.search_dropdown > input').removeClass('filled');
	}
}

function clearSearchInput(){
	$('#secondtopmenucontent > div.search_dropdown > input').val('');
	$('#secondtopmenucontent > div.search_dropdown > input').removeClass('filled');

}

function openContextualMenu(){
	var img = $('div#thirdtopmenu > div > div > img');
	if($('div.contextual_menu').hasClass('open')){
		$('div.contextual_menu').removeClass('open');
		$('div#thirdtopmenu').removeClass('open');
		// img.attr('src', 'img/arrow_down.png');
	}else{
		$('div#thirdtopmenu').addClass('open');
		// img.attr('src', 'img/arrow_up_orange.png');
		$('div.contextual_menu').addClass('open');
	}
}

function closeContextualMenu(){
	var img = $('div#thirdtopmenu > div > div > img');
	$('div.contextual_menu').removeClass('open');
	$('div#thirdtopmenu').removeClass('open');
	// img.attr('src', 'img/arrow_down.png');
}


function openContextualMenuItem(p){
	var index = $(p).parent().parent().index() + 1;
	if($('div.contextual_menu > div > ul > li:nth-child(' + index + ')').hasClass('selected')){
		$('div.contextual_menu > div > ul > li:nth-child(' + index + ')').removeClass('selected');
	}else{
		$('div.contextual_menu > div > ul > li').removeClass('selected');
		$('div.contextual_menu > div > ul > li:nth-child(' + index + ')').addClass('selected');
	}
}


function openGlobalMenuItem(p){
	var index = $(p).parent().parent().index() + 1;
	if($('#secondtopmenu > #secondtopmenucontent > nav > ul > li > div > div.maxwidth > ul > li:nth-child(' + index + ')').hasClass('selected')){
		$('#secondtopmenu > #secondtopmenucontent > nav > ul > li > div > div.maxwidth > ul > li:nth-child(' + index + ')').removeClass('selected');
	}else{
		$('#secondtopmenu > #secondtopmenucontent > nav > ul > li > div > div.maxwidth > ul > li').removeClass('selected');
		$('#secondtopmenu > #secondtopmenucontent > nav > ul > li > div > div.maxwidth > ul > li:nth-child(' + index + ')').addClass('selected');
	}
}

/*close menus when mouse click outside it*/

$(document).click(function(event) {
	if(!$('#thirdtopmenu > div.service > div:first-of-type > img:first-of-type').is(event.target) && !$('#thirdtopmenu > .contextual_menu').is(event.target) && $('#thirdtopmenu > .contextual_menu').has(event.target).length === 0 && $('#thirdtopmenu').hasClass('open')){
		closeContextualMenu();
	}
	if(!$('#secondtopmenu > #secondtopmenucontent > div.search_dropdown').is(event.target) && !$('#secondtopmenu > #secondtopmenucontent > div.search_dropdown > *').is(event.target) && !$('#secondtopmenu > #secondtopmenucontent > nav > img').is(event.target) && !$('#secondtopmenucontent > nav').is(event.target) && $('#secondtopmenucontent > nav').has(event.target).length === 0 && ($('#secondtopmenu > #secondtopmenucontent > nav').hasClass('open') || $('#secondtopmenu > #secondtopmenucontent > nav > ul > li > div').hasClass('open'))){
		closeMenu();
		closeMenu320();
	}

    //if(!isDescendant($('#thirdtopmenu > .contextual_menu'), $(event.target)) && !isDescendant($('#secondtopmenucontent > nav'), $(event.target))) {
    // if(!isChildOf($(event.target), $('#thirdtopmenu > .contextual_menu')) && !isChildOf($(event.target), $('#secondtopmenucontent > nav'))) {
    // 	console.log('element inside menu');
    //     if($('#thirdtopmenu').hasClass('open')) {
    //         //closeContextualMenu();
    //     }
    // }        
});
