 CKEDITOR.plugins.add( 'insert_ext_html', {
    icons : 'insertexthtml',
    init: function( editor ) {

    	var pThis = this;
        var config = editor.config;

		var urlObjectList = [];
		if(typeof config.insertExtHtmlUrlList !== 'undefined' &&
		 config.insertExtHtmlUrlList.hasOwnProperty('length') ){

			for (var i = 0; i < config.insertExtHtmlUrlList.length; i++) {
				var obj = config.insertExtHtmlUrlList[i];

				if(obj.hasOwnProperty('url') && obj.hasOwnProperty('label')){
					urlObjectList.push(obj);
				}
			}
		}

		// CKEDITOR.dialog.add( 'insertExtHtmlDialog', pThis.path + 'dialogs/insertExtHtmlDialog.js' );
		//editor.addCommand( 'insertExtHtml', new CKEDITOR.dialogCommand( 'insertExtHtmlDialog' ) );

		var insertContent = function(content){
			editor.insertHtml( content );
		};

		var insertContentRef = CKEDITOR.tools.addFunction(insertContent);


		editor.addCommand( 'insertExtHtml_openUrl', {
			modes: {
				wysiwyg : 1,
				source : 1
			},
		    exec: function( editor, url, label ) {
		    	if(typeof label == 'undefined'){
		    		label = encodeURI(url);
		    	}

		    	if(url.indexOf("?") < 0){
		    		url += "?";
		    	}
		    	url += "&fn="+insertContentRef;

				var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
				prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
				prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
				var win = window.open(url, label, prop);
				win.focus();

//				window.open(url, label);
		        //editor.insertHtml( content );
		    }
		});

		var items = [];
	    for (var i = 0; i < urlObjectList.length; i++) {
	    	var urlObj = urlObjectList[i];

	    	var onClickFunc = (function(url,label){
	    		return function(){
	            	editor.execCommand( 'insertExtHtml_openUrl', url,label );
	            };
	    	})(urlObj.url, urlObj.label);

	    	items.push([
    		'urlObj_'+i,
        	{
	            label: urlObj.label,
	            icon: pThis.path + 'icons/insertexthtml.png',
	            group: 'insertExtHtmlGroup',
	            order: 1,
	            onClick : onClickFunc
	        }
	    ]);
	    }

        editor.addMenuGroup( 'insertExtHtmlGroup' );
        for (var i = 0; i < items.length; i++) {
        	editor.addMenuItem( items[i][0], items[i][1] );
        }

		editor.ui.add( 'InsertExtHtmlButton', CKEDITOR.UI_MENUBUTTON, {
			label : 'Insert External Template',
           	icon: pThis.path + 'icons/insertexthtml.png',
           	onMenu: function() {
               var active = {};

               // Make all items active.
               for (var j = 0; j < items.length; j++) {
               		active[ items[j][0] ] = CKEDITOR.TRISTATE_OFF;
               }

               return active;
           }
		});

		//add dynamic content widget

		var WIDGET_CLASS = 'dynamic-content';

		 CKEDITOR.dialog.add( 'insert_ext_html_dialog', pThis.path + 'dialogs/insert_ext_html_dialog.js' );

		editor.widgets.add( 'insert_ext_html_widget', {
			// button : 'create dynamic content box',
			template:
		                '<div class="'+WIDGET_CLASS+'">' +
		                    'dynamic contents...' +
		                '</div>',

		    editables:  {
		    				content: {
		                        selector: '.'+WIDGET_CLASS
		                        // ,allowedContent: 'br strong em'
		                    }
		                },

		    dialog : 'insert_ext_html_dialog',

		    // allowedContent: 'div(!dynamic-content);',

		    requiredContent: 'div('+WIDGET_CLASS+')',

		    upcast: function( element ) {
		        return element.name == 'div' && element.hasClass( WIDGET_CLASS );
		    },

		    //init, set widget data from dom of widget template
		    init : function(){
		    	var type = '';
		    	if(this.element.hasClass('dynamic-content-dashlet')){
		    		type = 'dashlet';
		    	}
		    	else if(this.element.hasClass('dynamic-content-product')){
		    		type = 'product';
		    	}
		    	else if(this.element.hasClass('dynamic-content-hubpage')){
		    		type = 'hubpage';
		    	}

		    	this.setData('type',type);

		    	if(type === 'dashlet'){
			    	var resize = this.element.getAttribute('data-resize');
			    	//alert(resize);
			    	this.setData('resize',resize);
			    }
		    },
		    //called every time widget.data is changed using .setData()
		    data: function() {

		    	if(this.data.type === 'dashlet'){
		    		this.element.setAttribute('data-resize',this.data.resize);
		    	}

		    }

		} );



    }//end init function
});