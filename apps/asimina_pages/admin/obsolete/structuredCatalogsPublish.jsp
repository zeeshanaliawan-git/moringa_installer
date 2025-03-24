<!-- This jsp for including in structured catalog list and editor screens  -->
<%@ include file="checkPublishLogin.jsp"%>
<script type="text/javascript">

    function onPublishUnpublish(action,isLogin){

        var catalogIdsCheck = window.catalogsTable.rows( { selected: true } ).nodes().to$();
        catalogIdsCheck = catalogIdsCheck.find('.idCheck');

        if(catalogIdsCheck.length == 0){
            bootNotify("No catalog selected");
        }
        else{

            if(typeof isLogin == 'undefined' || !isLogin){
                checkPublishLogin(action);
            }
            else{

                var msg = "" + catalogIdsCheck.length + " catalogs selected.\n";
                msg += "Are you sure you want to "+action+" these catalogs?";
                bootConfirm(msg,function(result){
                    if(result){
                        var catalogIds = [];
                        catalogIdsCheck.each(function(index, el) {
                            catalogIds.push($(el).val());
                        });
                        publishUnpublishCatalogs(catalogIds, action);
                    }
                });

            }
        }
    }

    function publishUnpublishCatalogs(catalogIds, action){
        showLoader();
        $.ajax({
            url: 'structuredCatalogsAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : action + 'Catalogs',
                catalogIds : catalogIds.join(','),
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