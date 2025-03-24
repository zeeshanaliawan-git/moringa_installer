CKEDITOR.dialog.add( 'insert_ext_html_dialog', function( editor ) {


    return {
        title: 'Edit Dynamic Content',
        minWidth: 200,
        minHeight: 100,

        contents: [
            {
                id: 'tab1',
                elements: [
                    {
                        id: 'resize',
                        type: 'select',
                        label: 'Fit to cantainer ?',
                        items: [
                            [ 'No', 'none' ],
                            [ 'Width only', 'width'],
                            [ 'Height only', 'height'],
                            [ 'Both width & height', 'both' ]
                        ],
                        default : 'none',

                        setup: function( widget ) {
                            this.setValue( widget.data.resize );
                        },
                        commit: function( widget ) {
                            widget.setData( 'resize', this.getValue() );
                        }
                    }
                ]
            }
        ]
    };
} );