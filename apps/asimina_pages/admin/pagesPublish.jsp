<!-- This jsp for including in page list and editor screens  -->
<%@ include file="checkPublishLogin.jsp"%>
<!-- Modal -->
<%-- <div class="modal fade" id="modalPublishPages" tabindex="-1" role="dialog" >
    <div class="modal-dialog" role="document">
        <div class="modal-content" >
            <form class="formPublishPages" action="" onSubmit="return false" novalidate="">
                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="form-group row">
                            <div class="col publishMessage">

                            </div>
                            <div class="col-1">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label  class="col-sm-3 col-form-label">
                                <span class="text-capitalize actionName">Publish</span>
                            </label>
                            <div class="col-sm-9">
                                <button type="button" class="btn btn-primary publishNowBtn">Now</button>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label  class="col-sm-3 col-form-label">
                                <span class="text-capitalize actionName">Publish</span> on
                            </label>
                            <div class="col-sm-9">
                                <div class="input-group">
                                    <input type="text" class="form-control" name="publishTime" value="">
                                    <div class="input-group-append">
                                        <button class="btn btn-primary  rounded-right publishOnBtn" type="button">OK</button>
                                    </div>
                                    <div class="invalid-feedback">Please specify date and time</div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal --> --%>



<script type="text/javascript">

    // $(function() {

    //     var publishTimeField = $('#modalPublishPages input[name=publishTime]');

    //     initDatetimeFields(publishTimeField, null, null, "date_time");

    //     publishTimeField.on('change',function(){
    //         if($(this).val().trim().length > 0){
    //             $(this).removeClass('is-invalid');
    //         }
    //     });

    // });


    // function showPublishPagesModal(message, action, callback){
    //     var modal = $('#modalPublishPages');

    //     modal.find('.actionName').text(action);

    //     modal.find('.publishMessage').text(message);

    //     modal.find(".publishNowBtn").off('click')
    //     .click(function(){
    //         var publishTime = "now";
    //         modal.modal('hide');
    //         callback(publishTime);
    //     });

    //     var publishTimeField = modal.find('input[name=publishTime]');
    //     publishTimeField.val("");

    //     modal.find(".publishOnBtn").off('click')
    //     .click(function(){
    //         var publishTime = publishTimeField.val().trim();

    //         if(publishTime.length === 0){
    //             publishTimeField.addClass('is-invalid');
    //             return false;
    //         }

    //         modal.modal('hide');
    //         callback(publishTime);
    //     });

    //     modal.modal('show');
    // }

    function onPublishUnpublish(action,isLogin, checkedPagesElemList){
        var PAGE_FREEMARKER = '<%=Constant.PAGE_TYPE_FREEMARKER%>';
        var PAGE_STRUCTURED = '<%=Constant.PAGE_TYPE_STRUCTURED%>';
        var PAGE_REACT = '<%=Constant.PAGE_TYPE_REACT%>';

        var folderType =  $('#folderType').val();
        var itemType = "page"
        if(folderType == "<%=Constant.FOLDER_TYPE_STORE%>"){
            itemType = "store";
        }

        var pagesChecked = checkedPagesElemList;
        if(!checkedPagesElemList){
            pagesChecked = window.pagesTable.rows( { selected: true } ).nodes().to$();
            pagesChecked = pagesChecked.find('.idCheck.'+PAGE_FREEMARKER+', .idCheck.'+PAGE_STRUCTURED+' , .idCheck.'+PAGE_REACT);
        }

        if(pagesChecked.length == 0){
            bootNotify("No "+itemType+" selected");
        } else{

            if(typeof isLogin == 'undefined' || !isLogin){
                checkPublishLogin(action);
            }
            else{

                var pages = [];
                pagesChecked.each(function(index, el) {
                    if($(el).hasClass(PAGE_FREEMARKER)){
                        pages.push({id:$(el).val(), type: PAGE_FREEMARKER});
                    }else if($(el).hasClass(PAGE_STRUCTURED)){
                        pages.push({id:$(el).val(), type:PAGE_STRUCTURED});
                    } else if($(el).hasClass(PAGE_REACT)){
                        pages.push({id:$(el).val(), type:PAGE_REACT});
                    }
                });
                publishUnpublishPages(pages, action, "now");

                // var msg = "" + pagesChecked.length + " "+itemType+"(s) selected.\n";
                // msg += "Are you sure you want to "+action+" these "+itemType+"(s)?";

                // showPublishPagesModal(msg, action, function(publishTime){
                //     var pages = [];
                //     pagesChecked.each(function(index, el) {
                //         if($(el).hasClass(PAGE_FREEMARKER)){
                //             pages.push({id:$(el).val(), type: PAGE_FREEMARKER});
                //         }else if($(el).hasClass(PAGE_STRUCTURED)){
                //             pages.push({id:$(el).val(), type:PAGE_STRUCTURED});
                //         } else if($(el).hasClass(PAGE_REACT)){
                //             pages.push({id:$(el).val(), type:PAGE_REACT});
                //         }
                //     });
                //     console.log(pages);
                //     console.log(action);
                //     console.log(publishTime);
                //     publishUnpublishPages(pages, action, publishTime);
                // });

            }
        }
    }

    function publishUnpublishPages(pages, action, publishTime){
        showLoader();
        $.ajax({
            url: 'publishUnpublishPagesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : action + 'Pages',
                pages : JSON.stringify(pages),
                publishTime : publishTime,
                folderType : $('#folderType').val()
            },
        })
        .done(function(resp) {
            if(resp.status === 1){
                bootNotify(resp.message);
                if(typeof refreshDataTable !== 'undefined'){
                    refreshDataTable();
                }

                if(typeof refreshPublishUnpublishStatus !== 'undefined'){
                    refreshPublishUnpublishStatus(action, resp.status);
                }
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }
</script>