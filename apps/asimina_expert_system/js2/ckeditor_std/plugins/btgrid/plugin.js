(function(){
  CKEDITOR.plugins.add('btgrid', {
      lang: 'en',
      requires: 'widget,dialog',
      icons: 'btgrid',
      init: function(editor) {
       var maxGridColumns = 12;
       var lang = editor.lang.btgrid;

       CKEDITOR.dialog.add('btgrid',  this.path + 'dialogs/btgrid.js');

       editor.addContentsCss( this.path + 'styles/editor.css');
       // Add widget
       editor.widgets.add('btgrid',
         {
           allowedContent: 'div(!btgrid);div(!row,!row-*);div(!col-*-*);div(!content)',
           requiredContent: 'div(btgrid)',
           parts: {
             btgrid: 'div.btgrid',
           },
           editables: {
             content: '',
           },
           template:
                   '<div class="btgrid">' +
                   '</div>',
           button: lang.createBtGrid,
           dialog: 'btgrid',
           defaults: {
            //  colCount: 2,
            // rowCount: 1
          },
          // Before init.
           upcast: function(element) {
             return element.name == 'div' && element.hasClass('btgrid');
           },
           // initialize
           // Init function is useful after copy paste rebuild.
           init: function() {
             var rowNumber= 1;
             var rowCount = this.element.getChildCount();
             for (rowNumber; rowNumber <= rowCount;rowNumber++) {
               this.createEditable(maxGridColumns, rowNumber);
             }
           },
           // Prepare data
           data: function() {
             if (this.data.colCount && this.element.getChildCount() < 1) {
               var colCount = this.data.colCount;
               var rowCount = this.data.rowCount;
               var row = this.parts['btgrid'];
               for (var i= 1;i <= rowCount;i++) {
                 this.createGrid(colCount, row, i);
               }
             }
           },
           //Helper functions.
           // Create grid
           //updated by AA
           createGrid: function(colCount, row, rowNumber) {
              var content = '<div class="row row-' + rowNumber + '">';
              var colSize = maxGridColumns/colCount;
              var colSizeArr = ["xs", "sm", "md", "lg"];

              for (var i = 1; i <= colCount; i++) {
                var colClasses = "";

                for (var j = 0; j < colSizeArr.length; j++) {
                  colClasses += " col-"+colSizeArr[j]+ "-" + colSize;
                }

                content = content + '<div class="col ' + colClasses + '">' +
                                   //'  <div class="content">' +
                                   '   <p>Col ' + i + ' </p>' +
                                   //'  </div>' +
                                   '</div>';
             }
             content =content + '</div>';
             row.appendHtml(content);
             this.createEditable(colCount, rowNumber);
           },
           // Create editable.
           createEditable: function(colCount,rowNumber) {
             for (var i = 1; i <= colCount; i++) {
               this.initEditable( 'content'+ rowNumber + i, {
                  selector: '.row-'+ rowNumber +' > div.col:nth-child('+ i +') ' //updated by AA

                  //selector: '.row-'+ rowNumber +' > div:nth-child('+ i +') div.content'
                } );
              }
            }
          }
        );
      }
    }
  );

})();
