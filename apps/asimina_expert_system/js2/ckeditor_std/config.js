/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here.
	// For complete reference see:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config

	//special case to allow empty i tags (for font awesome)
	CKEDITOR.dtd.$removeEmpty['i'] = false;

	//allowing all html elements and attribute
	//their standard parent-child restrictions will still be applied
	//e.g.  <div> can have <p> as child, but <p> cannot have <div>
	config.allowedContent = {
	    $1: {
	        // Use the ability to specify elements as an object.
	        elements: CKEDITOR.dtd,
	        attributes: true,
	        styles: true,
	        classes: true
	    }
	};
	config.disallowedContent = 'script; *[on*]';

	config.extraPlugins = 'font';
	// config.extraPlugins += ',devtools'; //debug

	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
		{ name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },
		{ name: 'editing',     groups: [ 'find', 'selection', 'spellchecker' ] },
		{ name: 'forms', groups: [ 'forms' ] },
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'paragraph',   groups: [ 'list', 'indent', 'blocks', 'align', 'bidi','paragraph' ] },
		{ name: 'links' },
		{ name: 'insert' },
		'/',
		{ name: 'styles', groups: [ 'styles' ] },
		{ name: 'colors', groups: [ 'colors' ] },
		// { name: 'tools', groups: [ 'tools' ] },
		// { name: 'others', groups: [ 'others' ] },
		{ name: 'document',	   groups: [ 'mode'] },
		{ name: 'about' }
	];

	// Remove some buttons provided by the standard plugins, which are
	// not needed in the Standard(s) toolbar.
	config.removeButtons = 'About,Maximize,Save,NewPage,Preview,Print,PageBreak,Iframe,Flash,Language,CreateDiv'; //'Underline,Subscript,Superscript';

	// Set the most common block elements.
	config.format_tags = 'p;h1;h2;h3;pre';

	// Simplify the dialog windows.
	config.removeDialogTabs = 'image:advanced;link:advanced';

	//config.extraPlugins = 'devtools';

	//Customize color panel
	config.colorButton_colors = '000000,FFFFFF,D6D6D6,8F8F8F,595959,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200';
	
	config.disableNativeSpellChecker = false;
};
