jQuery(document).ready(function() {
    //Getting the width of screen and applying it to screenWidth varibable later to element styles
    var screenWidth = jQuery(window).width();
    jQuery(".o-full-screen-width").width(screenWidth);

    //Menu and Search section appears on clicking on Menu Button while watching from mobile
    jQuery(".--portal-- nav.o-main .o-mobile-menu-bt").click(function() {
        if (jQuery(".--portal-- nav.o-main ul,.--portal-- .o-navbar .o-container .o-search-input-wrapper").hasClass("o-active")) {
            jQuery(".--portal-- nav.o-main ul,.--portal-- .o-navbar .o-container .o-search-input-wrapper").removeClass("o-active");
        } else {
            jQuery(".--portal-- nav.o-main ul,.--portal-- .o-navbar .o-container .o-search-input-wrapper").addClass("o-active");
        }
    });



    jQuery(".--portal-- .o-navbar .o-container .o-search-input-wrapper input").on("keyup change paste",function(){

       console.log("input changed with value: "+jQuery(this).val());
        if(jQuery(this).val() == ""){
            jQuery(this).next("img.o-close-it").removeClass("o-active");
            
        }
        else{
            jQuery(this).next("img.o-close-it").addClass("o-active");
            
        }
    });



    //Search Input field and close clear button appears on clicking on Search Button no navbar
    jQuery(".--portal-- a.o-search-bt").click(function(e) {
        e.preventDefault();
        e.stopPropagation();
        if (jQuery(".--portal-- .o-navbar .o-container .o-search-input-wrapper").hasClass("o-active")) {
            jQuery(".--portal-- .o-navbar .o-container .o-search-input-wrapper").removeClass("o-active");
        } else {
            jQuery(".--portal-- .o-navbar .o-container .o-search-input-wrapper").addClass("o-active");
        }

    });

    jQuery(".--portal-- nav.o-main>ul>li").click(function(e) {
        jQuery(this).find(".o-megamenu").addClass("o-active");
    });

    jQuery(".--portal-- .o-clear-it").click(function() {
        jQuery('.--portal-- .o-navbar .o-container .o-search-input-wrapper input').val("");
        jQuery(this).removeClass("o-active");
    });
});
jQuery(document).resize(function() {
    var screenWidth = jQuery(window).width();
    jQuery(".o-full-screen-width").width(screenWidth);
});
