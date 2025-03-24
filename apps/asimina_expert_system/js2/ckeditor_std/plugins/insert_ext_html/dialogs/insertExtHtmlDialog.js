
CKEDITOR.dialog.add( 'insertExtHtmlDialog', function ( editor ) {
	var config = editor.config;


	var urlObjectList = [];
	if(typeof config.insertExtHtmlUrlObjList !== 'undefined' &&
		 config.insertExtHtmlUrlObjList.hasOwnProperty('length') ){

		for (var i = 0; i < config.insertExtHtmlUrlObjList.length; i++) {
			var obj = config.insertExtHtmlUrlObjList[i];

			if(obj.hasOwnProperty('url') && obj.hasOwnProperty('label')){
				urlObjectList.push(obj);
			}
		}
	}

	var closeButton = CKEDITOR.dialog.cancelButton(editor);
	closeButton.title = closeButton.label = "Close";
    return {
        title: 'Insert External Template',
        minWidth: 300,
        minHeight: 200,
        contents: [
            {
                id: 'tab-1',
                label: '1st Tab',
                elements: [
                    // UI elements of the first tab will be defined here.
                ]
            }
        ],
        buttons: [
        	closeButton
        ]
    };
});