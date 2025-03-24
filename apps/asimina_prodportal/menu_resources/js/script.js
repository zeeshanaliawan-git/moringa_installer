/*
version 1.7.1
Mobile menu is now not taking whole height instead it is as long as the list item inside it. The close toolbar stick to the bottom of the menu.
If mobile menu has more items and than mobile height, menu takes whole height but does not exceed it. So the Close bar for menu stick to the end of mobile bottom.
On document ready I move sitetype-bar inside mobile menu so it can automatically stick blow the mobile menu.
Handled langbar for mobile view. Cloned to mobile menu.
*/
/*Not useing o-active class on some parts because o-active is being used by bootstrap and it gives orange background to elements*/
var megamenuActive = false;
var isDesktop;
var isDevelopment = false; //If turned to false, all console.log will not work.


    var header = {};
// All console.log should go through this funciton so they can be disabled on production version to avoid data and code leak. See variable "isDevelopment" to false in Production Server.
function clog(message) {
    if (isDevelopment) console.log(message);
}

//Prevents default functionality of a tag or element and stops the bubbling of an event.
function prevent(e) {
    // e.preventDefault();
    e.stopPropagation();
}

// Checks if current screen is Desktop level screen or mobile. Tablets comes under Desktop screen as well
function isDesktopCheck() {
    if (___portaljquery(window).width() >= 768) {
        isDesktop = true;
    }
    if (___portaljquery(window).width() < 768) {
        isDesktop = false;
    }
}

/*Close/hide all megamenus on desktop screen*/
function closeAllFirstLevel() {
    header.firstLevelLI.find(".o-megamenu").removeClass('o-active');
    header.firstLevelLI.removeClass('o-active');
}


/* Close/Hide all sublevel menus items for mobile screen */
function closeAllSecondLevel() {
    clog("closeAllSecondLevel");
    ___portaljquery(".etn-orange-portal-- .o-nav li.o-has-childs .o-megamenu .o-container ul li.o-menu-heading.o-has-childs~li:not(.o-menu-heading)")
        .hide('fast');
}

//Calculates max-height of Mega Menu. Will only work on mobile screen that is less than 767px width of screen.
function megamenuHeight() {
    var viewportheight, viewportwidth;
    // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight

    if (typeof window.innerWidth != 'undefined') {
        viewportwidth = window.innerWidth,
            viewportheight = window.innerHeight
    }
    // IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)
    else if (typeof document.documentElement != 'undefined' &&
        typeof document.documentElement.clientWidth !=
        'undefined' && document.documentElement.clientWidth != 0) {
        viewportwidth = document.documentElement.clientWidth,
            viewportheight = document.documentElement.clientHeight
    }
    // older versions of IE
    else {
        viewportwidth = document.getElementsByTagName('body')[0].clientWidth,
            viewportheight = document.getElementsByTagName('body')[0].clientHeight
    }
    var windowHeight = viewportheight;
    var windowWdidth = viewportwidth;
    var navHeaderHeight = ___portaljquery(".etn-orange-portal-- #o-secondtopmenu").innerHeight();
    var topHeaderHeight = ___portaljquery(".etn-orange-portal-- .o-topbar").innerHeight();
    var sidebarHeaderHeight = ___portaljquery(".etn-orange-portal-- .o-sitetype-bar.o-extra-bar").innerHeight();
    var toolbarHeaderHeight = ___portaljquery(".etn-orange-portal-- nav.o-main>.o-toolbar").innerHeight();
    if (isDesktop) {
        var closebarHeight = ___portaljquery('.etn-orange-portal-- .o-megamenu > .o-toolbar').height();
        var megaMenuHeightDesktop = windowHeight - navHeaderHeight - topHeaderHeight - closebarHeight - 4;
        return megaMenuHeightDesktop;
    }
    if (!isDesktop) {
        // closebarHeight = ___portaljquery('.etn-orange-portal-- .o-megamenu > .o-toolbar').height();
        var megaMenuHeightMobile = windowHeight - navHeaderHeight - toolbarHeaderHeight - sidebarHeaderHeight;
        return megaMenuHeightMobile;
    }
}

//Applies full with as that of screen to the class .o-full-screen-width
function applyFullWidth() {
    var screenWidth = ___portaljquery(window).width();
    ___portaljquery(".o-full-screen-width").width(screenWidth);
}

//Toggles (Open/Close) Mega Menu
function mobileMenuToggle(e) {
    prevent(e);
    header.mainNavigation.toggleClass("o-active");
}

//Opens the mega menu
function megaMenuOpen(e) {
    prevent(e);
    header.mainNavigation.addClass("o-active");
}

//Closes the mega menu
function megaMenuClose(e) {
    prevent(e);
    header.mainNavigation.removeClass("o-active");
}

//Setting width of slider to the width of screen for mobiles
if (___portaljquery(window).width() <= 959) {
    ___portaljquery(".etn-orange-portal-- .view-sliders.view-id-sliders .view-content>.slide").width(___portaljquery(window).width());
}

/* Document Ready */
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
___portaljquery(document).ready(function() {
    //Selectors List
    /*■ */ header.self = ___portaljquery("#etn-mosse-header");
    /*└── */ header.topHeader = ___portaljquery("#etn-mosse-header .o-topbar");
    /*└── */ header.topHeader.navigation = ___portaljquery("#etn-mosse-header .o-topbar>.o-nav");
    /*└── */ header.mainHeader = ___portaljquery("#etn-mosse-header #o-secondtopmenu");
    /* └── */ header.logo = ___portaljquery("#etn-mosse-header #o-secondtopmenu .o-logo");
    /* └── */ header.mainNavigation = ___portaljquery("#etn-mosse-header #o-secondtopmenu nav.o-main");
    /*   └── */ header.mobileMenuButton = ___portaljquery("#etn-mosse-header #o-secondtopmenu #mobile-menu-bt");
    /*     └── */ header.megaMenu = ___portaljquery("#etn-mosse-header #o-secondtopmenu nav.o-main>ul>li .o-megamenu");
    /*       └── */ header.desktopMenuCloseButton = ___portaljquery("#etn-mosse-header #o-secondtopmenu nav.o-main>ul>li .o-megamenu .o-toolbar a");
    /*   └── */ header.mobileMenuCloseButton = ___portaljquery("#etn-mosse-header #o-secondtopmenu nav.o-main>.o-toolbar a");
    /* */ header.menuCloseButton = ___portaljquery("#etn-mosse-header #o-secondtopmenu .o-toolbar a"); //Any close button will close the entire megamenu along with children
    /*   └── */ header.firstLevelLI = ___portaljquery("#etn-mosse-header #o-secondtopmenu nav.o-main>ul>li");

    //Copies the content of .o-sitetype-bar into megamenu to compensate the mobile mega menu UI.
    // header.topHeader.find('.o-container').append('<div id="login-cart-section"><div class="login-section"></div><div class="cart-section"></div></div>');
    // header.topHeader.find('.o-container #login-cart-section').clone().addClass('o-visible-xs-block').insertBefore('nav.o-main'); //lang-bar cloning happening here

    header.self.find('.o-lang-bar').removeClass('o-visible-sm-block').clone().appendTo(header.mainNavigation); //lang-bar cloning happening here
    header.self.find('.o-sitetype-bar').removeClass('o-visible-sm-block').clone().appendTo(header.mainNavigation); //sitetype-bar cloning happening here
    header.mainNavigation.find('>.o-toolbar.o-visible-xs-block').appendTo(header.mainNavigation); //Re-adding toolbar to menu so it can appear after o-sitetype-bar rather than before
    header.mainNavigation.find('>.o-sitetype-bar').removeAttr('style'); //removing style from o-sitetype-bar so other logics can operate on the element easily.
    header.mainHeader.find('#search-bt').clone().prependTo('#mobile-menu-right .search-section');
    header.topHeader.addClass('o-hidden-xs');
    ___portaljquery('footer.etn-orange-portal-- .portal-col-5 li:first-child').each(function(){
        if(!___portaljquery(this).is(':empty')) {___portaljquery(this).append('<span class=\'expand\'style=\'display:none;\'></span>'); }
        if(___portaljquery(this).is(':empty')) {___portaljquery(this).hide();}
    });
    ////////////////////////////////////

    //Checking if current screen is desktop
    isDesktopCheck();

    //
    //UNIVERSAL
    ////////////////////
    header.topHeader.navigation.find('li').filter(':not(.o-pull-right)').addClass('o-visible-sm-block o-visible-md-block o-visible-lg-block');
    // Mobile Menu button will toggle active class on main navigation. On desktop it will have not effect but on mobile this will open the menu.
    header.mobileMenuButton.on("click touch", function(e) {
        clog('Mobile menu button clicked ');
        mobileMenuToggle(e);
    });

    /*Clicknig li link on Main Menu opens the MEGAMENU */
    // Clicking on first level Li's on main navigaiton will open its megamenu on desktop or respective children on mobile screen.
    /* /////////////////////////////////////////////////////////////////////////////////////////// */
    header.firstLevelLI.click(function(e) {
        megaMenuOpen(e);
        applyFullWidth();
        closeAllFirstLevel();
        ___portaljquery(this).addClass("o-active");
        ___portaljquery(this).find('.o-megamenu').addClass("o-active");
        ___portaljquery('.etn-orange-portal-- .o-megamenu > .o-container').css("max-height", megamenuHeight());
        clog("Megamenu opening on Desktop");
        megamenuActive = true;
    });
    /* Closes Megamenu when user clicks outside the menu */
    /* /////////////////////////////////////////////////////////////////////////////////////////// */
    ___portaljquery(document).on("click", function(e) {
        if (megamenuActive) {
            megaMenuClose(e);
            closeAllFirstLevel();
            megamenuActive = false;
        }
    });
    /*Click on Cross Button will close the Megamenu or menu on mobile*/
    /* /////////////////////////////////////////////////////////////////////////////////////////// */
    header.menuCloseButton.on("click touch", function(e) {
            clog('Close menu button clicked');
            mobileMenuToggle(e);
            closeAllFirstLevel();
            megamenuActive = false;
    });
    // Iteration to check if link has childs or child menus and adding .has-childs class if a link does
        // Main level iteration
        ___portaljquery.each(header.firstLevelLI, function(i, v) {
            clog(i);
            if (___portaljquery(this).find("ul").length > 0) {
                ___portaljquery(this).addClass("o-has-childs");
            }
        });

    //DESKTOP
    ////////////////
    if (isDesktop) {
        applyFullWidth();

        /* Clicknig link on TOPBAR opens the Dropdown On Desktop */
        /* /////////////////////////////////////////////////////////////////////////////////////////// */
        ___portaljquery(".etn-orange-portal-- .o-topbar .o-nav>li").click(function() {
            if (___portaljquery(this).hasClass("o-active")) {
                ___portaljquery(this).removeClass("o-active");
            } else {
                ___portaljquery(this).addClass("o-active");
            }
        });
            var rightPosition = (window.innerWidth-___portaljquery('.o-container').innerWidth())/2;
            ___portaljquery('.o-login-cart-section').css('right',rightPosition);
    }
    // MOBILE
    ///////////////
    if (!isDesktop) {
        // Making sure the link sections in footer are not hidden(display:none) and then onclick they will expand to their child links

        // ___portaljquery(".etn-orange-portal-- .o-extra-bar").attr("style", "display: none !important");
        ___portaljquery("footer.etn-orange-portal-- .portal-col-5 li:first-child>span.expand").show().on("click touch", function(e) {
            prevent(e);
            ___portaljquery(this).parent().parent().hasClass("o-expanded") ? ___portaljquery(this).parent().parent().removeClass("o-expanded") : ___portaljquery(this).parent().parent().addClass("o-expanded");
        });
        // Setting height for UL in megamenu under mobile screen
        ___portaljquery(".etn-orange-portal-- nav.o-main ul.o-nav.o-nav-pills").css("max-height", megamenuHeight());


        // Submenu level iteration
        ___portaljquery.each(___portaljquery(".etn-orange-portal-- .o-nav li.o-has-childs .o-megamenu .o-container ul li"), function(i, v) {
            if (___portaljquery(this).length > 0) {
                if (___portaljquery(this).hasClass('o-menu-heading')) {
                    ___portaljquery(this).addClass("o-has-childs");
                }
            }
        });

        // Clicking on li in Megamenu links will expand the sub-menus or lis
        ___portaljquery(".etn-orange-portal-- nav.o-main>ul>li.o-has-childs>a").on("click", function(e) {
            // closeAllFirstLevel();
            prevent(e);
            if (___portaljquery(this).parent().find(".o-megamenu").hasClass("o-active")) {
                ___portaljquery(this).parent().find(".o-megamenu").hide("fast").removeClass("o-active");
            } else {
                closeAllFirstLevel();
                ___portaljquery(this).parent().addClass("o-active");
                ___portaljquery(this).parent().find(".o-megamenu").addClass("o-active").show("fast");
            }
        });

        //Click to expand or collapse 3rd Level List Items
        ___portaljquery(".etn-orange-portal-- nav.o-main>ul>li.o-has-childs ul li.o-menu-heading.o-has-childs").on("click", function(e) {
            prevent(e);
            if (___portaljquery(this).parent().find("li:not(.o-menu-heading)").is(":visible")) {
                ___portaljquery(this).parent().find("li:not(.o-menu-heading)").hide("fast");
            } else {
                closeAllSecondLevel();
                ___portaljquery(this).parent().find("li:not(.o-menu-heading)").show("fast");
            }
        });
        ___portaljquery(".etn-orange-portal-- .o-nav li.o-has-childs .o-megamenu a.___portalmenulink").on("click touch", function(e) {
            e.stopPropagation();
        });

        //Menu and Search section appears on clicking on Menu Button while watching from mobile
        // ,.etn-orange-portal-- .o-navbar .o-container .o-search-input-wrapper

        // ___portaljquery(".etn-orange-portal-- nav.o-main .o-mobile-menu-bt").on("click touch", function(e) {prevent(e);
        //     clog("Main menu has class active: "+___portaljquery(".etn-orange-portal-- nav.o-main").hasClass("o-active"));
        //     if (___portaljquery(".etn-orange-portal-- nav.o-main").hasClass("o-active")) {
        //          // ___portaljquery(".etn-orange-portal-- nav.o-main ul").hide("fast");
        //          ___portaljquery(".etn-orange-portal-- .o-extra-bar").attr("style","display: none !important");
        //          ___portaljquery(".etn-orange-portal-- nav.o-main").removeClass("o-active");
        //          ___portaljquery(".etn-orange-portal-- nav.o-main>ul,.etn-orange-portal-- .o-navbar .o-container .o-search-input-wrapper").removeClass("o-active").hide();
        //          clog("Main Menu closing");
        //          closeAllFirstLevel();
        //      } else if (!___portaljquery(".etn-orange-portal-- nav.o-main").hasClass("o-active")) {
        //          // ___portaljquery(".etn-orange-portal-- nav.o-main ul").show("fast");
        //          ___portaljquery(".etn-orange-portal-- .o-extra-bar").attr("style","display: block !important");
        //          ___portaljquery(".etn-orange-portal-- nav.o-main").addClass("o-active");
        //          ___portaljquery(".etn-orange-portal-- nav.o-main>ul,.etn-orange-portal-- .o-navbar .o-container .o-search-input-wrapper").show().addClass("o-active");
        //          clog("Main Menu opening");
        //      }
        //  });
        /*Close menu button on mobiles*/

        //  ___portaljquery(".etn-orange-portal-- nav.o-main>.o-toolbar.o-black a").on("click touch", function(e) {
        //      prevent(e);
        //     ___portaljquery(".etn-orange-portal-- nav.o-main ul").removeClass("o-active");
        //     ___portaljquery(".etn-orange-portal-- nav.o-main").removeClass("o-active");
        //     ___portaljquery(".etn-orange-portal-- nav.o-main>ul,.etn-orange-portal-- .o-navbar .o-container .o-search-input-wrapper").removeClass("o-active").hide();
        //     closeAllFirstLevel();
        //     closeAllSecondLevel();
        // });
    }
    // ON RESIZE
    ///////////////
    var resizeTimer;
    var resizeInterval = 500; // Check if resizing has stopped after half second.
    ___portaljquery(window).resize(function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            // UNIVERSAL
            // //////////
            isDesktopCheck();
            clog("Window width:" + ___portaljquery(window).width() + "document width:" + ___portaljquery(document).width());
            var screenWidth = ___portaljquery(window).width();
            ___portaljquery(".o-full-screen-width").width(screenWidth);
            // ___portaljquery('.o-login-cart-section').width(___portaljquery('.o-container').width());
            clog("Windows resized");

            // MOBILE
            ////////////
            /*Setting height for menu*/
            if (!isDesktop) {
                // ___portaljquery(".etn-orange-portal-- .o-extra-bar").attr("style", "display: none !important");
                ___portaljquery(".etn-orange-portal-- nav.o-main ul.o-nav.o-nav-pills").css("max-height", megamenuHeight());
                ___portaljquery("footer.etn-orange-portal-- .portal-col-5 li:first-child>span.expand").show();
                ___portaljquery('.o-login-cart-section').removeAttr('style');
                ___portaljquery("footer.etn-orange-portal-- .portal-col-5 li:first-child>span.expand").show().on("click touch", function(e) {
                    prevent(e);
                    ___portaljquery(this).parent().parent().hasClass("o-expanded") ? ___portaljquery(this).parent().parent().removeClass("o-expanded") : ___portaljquery(this).parent().parent().addClass("o-expanded");
                });
            }
            if (isDesktop) {
                // ___portaljquery(".etn-orange-portal-- .o-extra-bar").attr("style", "display:none !important");
                var rightPosition = (window.innerWidth-___portaljquery('.o-container').innerWidth())/2;
                ___portaljquery('.o-login-cart-section').css('right',rightPosition);
                ___portaljquery(".etn-orange-portal-- nav.o-main ul.o-nav.o-nav-pills").height('auto');
                ___portaljquery('.etn-orange-portal-- .o-megamenu > .o-container').css("max-height", megamenuHeight());
            }
        }, resizeInterval);
    });

    /*SEARCH Input field and close clear button appears on clicking on Search Button no navbar */
    /* /////////////////////////////////////////////////////////////////////////////////////////// */
    ___portaljquery(".etn-orange-portal-- a.o-search-bt").click(function(e) {
        prevent(e);
        if (___portaljquery(".etn-orange-portal-- .o-navbar .o-container .o-search-input-wrapper").hasClass("o-active")) {
            ___portaljquery(".etn-orange-portal-- .o-navbar .o-container .o-search-input-wrapper").removeClass("o-active");
        } else {
            ___portaljquery(".etn-orange-portal-- .o-navbar .o-container .o-search-input-wrapper").addClass("o-active");
        }
    });
    /* Clear the search field */
    /* /////////////////////////////////////////////////////////////////////////////////////////// */
    ___portaljquery(".etn-orange-portal-- .o-clear-it").click(function() {
        ___portaljquery('.etn-orange-portal-- .o-navbar .o-container .o-search-input-wrapper input').val("");
        ___portaljquery(this).removeClass("o-active");
    });


});