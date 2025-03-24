<!-- This jsp for including in structured content list and editor screens  -->
<%@ include file="checkPublishLogin.jsp"%>
<script type="text/javascript">

    function onPublishUnpublish(action,isLogin){

        var contentIdsCheck = window.contentsTable.rows({ selected: true } ).nodes().to$();
        contentIdsCheck = contentIdsCheck.find('.idCheck.content');

        var structureType = (typeof $ch.structureType !== 'undefined')?$ch.structureType:"page";

        if(contentIdsCheck.length == 0){
            bootNotify("No "+$ch.structureType+" selected");
        }
        else{

            if(typeof isLogin == 'undefined' || !isLogin){
                checkPublishLogin(action);
            }
            else{

                var msg = "" + contentIdsCheck.length + " "+structureType+"s selected.\n";
                msg += "Are you sure you want to "+action+" these "+structureType+"s?";
                bootConfirm(msg,function(result){
                    if(result){
                        var contentIds = [];
                        contentIdsCheck.each(function(index, el) {
                            contentIds.push($(el).val());
                        });
                        publishUnpublishContents(contentIds, action);
                    }
                });

            }
        }
    }

    function publishUnpublishContents(contentIds, action){
        showLoader();
        $.ajax({
            url: 'structuredContentsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : action + 'Contents',
                contentIds : contentIds.join(','),
            },
        })
        .done(function(resp) {
            if(resp.status === 1){
                bootNotify(resp.message);
                refreshPublishUnpublishStatus(action,resp.status);
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