/*!
 * strength.js
 * Original author: @aaronlumsden
 * Further changes, comments: @aaronlumsden
 * Licensed under the MIT license
 */
;(function ( $, window, document, undefined ) {

    var pluginName = "strength",
        defaults = {
            strengthClass: 'strength',
            strengthMeterClass: 'strength_meter',
            strengthButtonClass: 'button_strength',
            strengthButtonText: 'Show Password',
            strengthButtonTextToggle: 'Hide Password'
        };

       // $('<style>body { background-color: red; color: white; }</style>').appendTo('head');

    function Plugin( element, options ) {
        this.element = element;
        this.$elem = $(this.element);
        this.options = $.extend( {}, defaults, options );
        this._defaults = defaults;
        this._name = pluginName;
        this.init();
    }

    Plugin.prototype = {

        init: function() {


            var characters = 0;
            var capitalletters = 0;
            var loweletters = 0;
            var number = 0;
            var special = 0;

            var upperCase= new RegExp('[A-Z]');
            var lowerCase= new RegExp('[a-z]');
            var numbers = new RegExp('[0-9]');
            var specialchars = new RegExp('([!,%,&,@,#,$,^,*,?,_,~])');
            
            var tooltipId = this.options.tooltipId;
            var isTooltip = false;
            var tooltipDiv = null;
            var thisElem = this.$elem;
            
            var initTooltips = function () {
                if (tooltipId) {
                    isTooltip = true;
                    tooltipDiv = $('#' + tooltipId);
                    $($(thisElem).parent()).tooltip({
                        items : 'input',
                        position: {
                            my: "left top",
                            at: "right+5 top",
                            collision: "flip fit",
                            of : $(thisElem).parent()
                        },
                        content: function () {
                            return $(tooltipDiv).html();
                        }
//                        , open: function () {
//                            $('#email2').val('tooltip shown');
//                        },
//                        create: function () {
//                            $('#email2').val('created');
//                        }
//                        ,hide: {
//                            duration: 100000 
//                        }
                    }).off(' mouseover mouseout'); 
                }
            };
            
            if(tooltipId && !isTooltip){
                initTooltips();
            }

            function GetPercentage(a, b) {
                return ((b / a) * 100);
            }

            function check_strength(thisval,thisid){
//                if(isTooltip){
//                    $($(thisElem).parent()).find('input').tooltip("close");  
//                }
                if (thisval.length >= 8) { characters = 1; } else { characters = 0; };
                if (thisval.match(upperCase)) { capitalletters = 1} else { capitalletters = 0; };
                if (thisval.match(lowerCase)) { loweletters = 1}  else { loweletters = 0; };
                if (thisval.match(numbers)) { number = 1}  else { number = 0; };

                var total = characters + capitalletters + loweletters + number + special;
                var totalpercent = GetPercentage(7, total).toFixed(0);
                get_total(total,thisid);
//                if(isTooltip){
//                     $($(thisElem).parent()).find('input').tooltip("open");   
//                }
            }

            function get_total(total,thisid){

                var thismeter = $('div[data-meter="'+thisid+'"]');
                if(total == 0){
                      thismeter.removeClass();
                }else if (total <= 1) {
                   thismeter.removeClass();
                   thismeter.addClass('veryweak');
                } else if (total == 2){
                    thismeter.removeClass();
                   thismeter.addClass('weak');
                } else if(total == 3){
                    thismeter.removeClass();
                   thismeter.addClass('medium');

                } else {
                     thismeter.removeClass();
                   thismeter.addClass('strong');
;                } 
                //for tooltip , by AliAdnan
                if(isTooltip){
                    var tContent = $('.ui-tooltip-content');
                    tContent.find('.tick').hide();
                    tooltipDiv.find('.tick').hide();
                    if(total < 1 || characters == 0){
                        //zero
                        tContent.find('.redtick').show();
                        tContent.find('.passStrength').text("Trop court");
                        tooltipDiv.find('.redtick').show();
                        tooltipDiv.find('.passStrength').text("Trop court");
                    }
                    else if(total >=1 && total <= 3){
                        //medium
                        tContent.find('.greentick').show();
                        tContent.find('.passStrength').text("Faible mais valide");
                        tooltipDiv.find('.greentick').show();
                        tooltipDiv.find('.passStrength').text("Faible mais valide");
                    }
                    else{
                        //full
                        tContent.find('.greentick').show();
                        tContent.find('.passStrength').html("Elev&eacute;");
                        tooltipDiv.find('.greentick').show();
                        tooltipDiv.find('.passStrength').html("Elev&eacute;");
                    }
                }
            }





            var isShown = false;
            var strengthButtonText = this.options.strengthButtonText;
            var strengthButtonTextToggle = this.options.strengthButtonTextToggle;


            thisid = this.$elem.attr('id');
            
            this.$elem.addClass(this.options.strengthClass).attr('data-password',thisid).after('<input style="display:none" class="'+this.options.strengthClass+'" data-password="'+thisid+'" type="text" name="" value=""><a data-password-button="'+thisid+'" href="" class="'+this.options.strengthButtonClass+'">'+this.options.strengthButtonText+'</a><div class="'+this.options.strengthMeterClass+'"><div data-meter="'+thisid+'"><p></p></div></div>');
             
            this.$elem.bind('keyup keydown', function(event) {
                thisval = $('#'+thisid).val();
                $('input[type="text"][data-password="'+thisid+'"]').val(thisval);
                check_strength(thisval,thisid);
                
            });

             $('input[type="text"][data-password="'+thisid+'"]').bind('keyup keydown', function(event) {
                thisval = $('input[type="text"][data-password="'+thisid+'"]').val();
                //console.log(thisval);
                $('input[type="password"][data-password="'+thisid+'"]').val(thisval);
                check_strength(thisval,thisid);
                
            });



            $(document.body).on('click', '.'+this.options.strengthButtonClass, function(e) {
                e.preventDefault();

               thisclass = 'hide_'+$(this).attr('class');




                if (isShown) {
                    $('input[type="text"][data-password="'+thisid+'"]').hide();
                    $('input[type="password"][data-password="'+thisid+'"]').show().focus();
                    $('a[data-password-button="'+thisid+'"]').removeClass(thisclass).html(strengthButtonText);
                    isShown = false;

                } else {
                    $('input[type="text"][data-password="'+thisid+'"]').show().focus();
                    $('input[type="password"][data-password="'+thisid+'"]').hide();
                    $('a[data-password-button="'+thisid+'"]').addClass(thisclass).html(strengthButtonTextToggle);
                    isShown = true;
   
                }


               
            });


         
            
        },

        yourOtherFunction: function(el, options) {
            // some logic
        }
    };

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName, new Plugin( this, options ));
            }
        });
    };

})( jQuery, window, document );


