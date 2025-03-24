<div class="TunnelBreadcrumb">
    <div class="container-lg">
        <div class="TunnelBreadcrumb-wrapper">
            <div class="TunnelBreadcrumb-step TunnelBreadcrumb-step-cart  isVisited" onclick="gotoStep('cart.jsp')" style="cursor:pointer">
                <div class="TunnelBreadcrumb-circle">
                    <span class="TunnelBreadcrumb-svg"
                                  data-svg="/src/assets/icons/icon-shopping.svg"></span>
                </div>
            </div>
            <% int stepCount=1; boolean isKycRequired = CartHelper.isKycRequired(Etn, ___loadedsiteid);%>
            <div class="TunnelBreadcrumb-step TunnelBreadcrumb-step-informations <%=(stepNumber==stepCount?"isCurrent isVisited":(stepNumber>stepCount?"isVisited":""))%>" <%=(stepNumber>stepCount++?"onclick=\"gotoStep('checkout.jsp')\" style=\"cursor:pointer\"":"")%>>
                <div class="TunnelBreadcrumb-circle">
                    <span class="TunnelBreadcrumb-svg"
                                  data-svg="/src/assets/icons/icon-my-account.svg"></span>
                </div>
            </div>
            <% if(isKycRequired){%>
                <div class="TunnelBreadcrumb-step TunnelBreadcrumb-step-kyc <%=(stepNumber==stepCount?"isCurrent isVisited":(stepNumber>stepCount?"isVisited":""))%>" <%=(stepNumber>stepCount++?"onclick=\"gotoStep('kyc.jsp')\" style=\"cursor:pointer\"":"")%> >
                    <div class="TunnelBreadcrumb-circle">
                        <span class="TunnelBreadcrumb-svg"
                                    data-svg="/src/assets/icons/icon-kyc.svg"></span>
                    </div>
                </div>
            <%}%>
            <div class="TunnelBreadcrumb-step TunnelBreadcrumb-step-delivery <%=(stepNumber==stepCount?"isCurrent isVisited":(stepNumber>stepCount?"isVisited":""))%> " <%=(stepNumber>stepCount++?"onclick=\"gotoStep('deliv.jsp')\" style=\"cursor:pointer\"":"")%>>
                <div class="TunnelBreadcrumb-circle">
                    <span class="TunnelBreadcrumb-svg"
                                  data-svg="/src/assets/icons/icon-fast-delivery.svg"></span>
                </div>
            </div>
            <div class="TunnelBreadcrumb-step TunnelBreadcrumb-step-payment <%=(stepNumber==stepCount?"isCurrent isVisited":(stepNumber>stepCount?"isVisited":""))%> " <%=(stepNumber>stepCount++?"onclick=\"gotoStep('payment.jsp')\" style=\"cursor:pointer\"":"")%>>
                <div class="TunnelBreadcrumb-circle">
                   <span class="TunnelBreadcrumb-svg"
                                  data-svg="/src/assets/icons/icon-money.svg"></span>
                </div>
            </div>
        </div>
    </div>
</div>
                

<div id="exitModal" class="ModalValidator BasketModal TunnelExitModal modal fade" tabindex="-1" role="dialog"
     aria-labelledby="myModalLabel1"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header mb-3">
                <button type="button" class="btn close TunnelExitModal-closeBtn" data-dismiss="modal">
                    <span class="sr-only"><%=libelle_msg(Etn, request, "Close")%></span>
                </button>
            </div>
            <div class="modal-body">
                    <form class="ModalValidator-form"
                          data-messages='{"required":"<%=escapeCoteValue(libelle_msg(Etn, request, "Ce champ est requis."))%>", "regex":"<%=escapeCoteValue(libelle_msg(Etn, request, "Ce champ est non valide."))%>", "confirm":"<%=escapeCoteValue(libelle_msg(Etn, request, "Veuillez saisir deux fois la m�me valeur."))%>"}'>

                        <div class="TunnelExitModal-title h2">
                            <span data-svg="/src/assets/icons/icon-info.svg"></span>
                            <p><strong><%=libelle_msg(Etn, request, "Vous �tes sur le point de quitter votre commande.")%></strong></p>
                        </div>

                        <p><%=libelle_msg(Etn, request, "Renseignez votre email ci-dessous si vous souhaitez sauvegarder votre panier.")%></p>

                        <div class="form-group">
                            <label for="keepEmail" class="is-required"><%=libelle_msg(Etn, request, "Email")%></label>
                            <input type="email" data-regex="/^[a-z0-9._-]+@[a-z0-9._-]+\.[a-z]{2,6}$/"
                                   data-regex-error="L'email n'est pas valide." class="form-control" id="keepEmail"
                                   name="keepEmail" required>
                            <input type="hidden" name="sendKeepEmail" value="1" />
                            <input type="hidden" name="keepEmailMuid" value="<%=escapeCoteValue(___muuid)%>" />
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="BasketModal-actions BasketModal-section">
                            <button type="button" onclick="quitWithoutSaving()" class="btn btn-secondary JS-TunnelExit-changePage"
                                    data-dismiss="modal"><%=libelle_msg(Etn, request, "Quitter sans sauvegarder")%>
                            </button>
                            <button type="button" onclick="saveKeepEmail(this)"
                                    class="btn btn-primary ModalValidator-confirmButton TunnelExitModal-saveBtn"
                                    disabled><%=libelle_msg(Etn, request, "Sauvegarder et quitter")%>
                            </button>
                        </div>

                    </form>

            </div>
        </div>
    </div>
</div>
<script>
    function gotoStep(step){
        if(typeof datalayerCommonVariables !== "undefined"){
            if(typeof dataLayer !== 'undefined' && dataLayer != null) 
            {
                var eventLabel = {
                    "cart.jsp" : "cart",
                    "checkout.jsp" : "personnal_informations",
                    <% if(isKycRequired){%>
                    "kyc.jsp" : "kyc",
                    <%}%>
                    "deliv.jsp" : "delivery",
                    "payment.jsp" : "payment"
                };
                var newDlObj = cloneObject(_etn_dl_obj);

                var tempObject = {
                        event: "standard_click",
                        event_action: "button_click",
                        event_category: "funnel_header",
                        event_label: eventLabel[step]}; // event tracking

                for(var key in tempObject){
                    newDlObj[key] = tempObject[key];
                }

//                for(var key in datalayerCommonVariables){
//                    newDlObj[key] = datalayerCommonVariables[key];
//                }
                dataLayer.push(newDlObj);   
            }
        }
        if(step=="cart.jsp") $('<form method="GET" action="<%=com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")%>'+step+'"><input type="hidden" name="muid" value="'+______muid+'" ></form>').appendTo('body').submit();
        else $('<form method="POST" action="<%=com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")%>'+step+'"><input type="hidden" name="muid" value="'+______muid+'" ><input type="hidden" name="session_token" value="'+$('input[name=session_token]').val()+'" ></form>').appendTo('body').submit();
    }
    
    function tunnelExitInit(){
        $('.TunnelHeader-brand').on('click', function (e) {
            e.preventDefault(); $("#exitModal").modal('toggle');
            if(typeof datalayerCommonVariables !== "undefined"){ 
                if(typeof dataLayer !== 'undefined' && dataLayer != null) 
                {
                    var newDlObj = cloneObject(_etn_dl_obj);

                    var tempObject = {
                        page_name: 'popin_quit_order'
                    }; // page tracking 

                    for(var key in tempObject){
                        newDlObj[key] = tempObject[key];
                    }

                    for(var key in datalayerCommonVariables){
                        newDlObj[key] = datalayerCommonVariables[key];
                    }
                    dataLayer.push(newDlObj);   
                }
            }
            
        });
    }
    
    function quitFunnelTracking(isSave){
        if(typeof datalayerCommonVariables !== "undefined"){
            if(typeof dataLayer !== 'undefined' && dataLayer != null) 
            {
                var newDlObj = cloneObject(_etn_dl_obj);
                
                var tempObject = {
                    event: "standard_click",
                    event_action: "button_click",
                    event_category: "popin_quit_order",
                    event_label: (isSave?"save":"leave")}; // event tracking

                for(var key in tempObject){
                    newDlObj[key] = tempObject[key];
                }

//                for(var key in datalayerCommonVariables){
//                    newDlObj[key] = datalayerCommonVariables[key];
//                }
                dataLayer.push(newDlObj);           

                tempObject = {"event": (isSave?"saveAndQuit":"quitWithoutSaving"),
                                event_action: "",
                                event_category: "",
                                event_label: "","ecommerce": {"quit": {"actionField": {"step": <%=stepNumber+1%>, "option": datalayerCommonVariables.funnel_step_name}, "products": recapDatalayerProducts}}};; // ecommerce tracking

                for(var key in datalayerCommonVariables){
                    tempObject[key] = datalayerCommonVariables[key];
                }
                dataLayer.push(tempObject);   
            }
        }
    }
    
    function quitWithoutSaving(){
        quitFunnelTracking(false);
        __gotoPortalHome();
    }
    
    function saveKeepEmail(button){
        quitFunnelTracking(true);
        var form = $(button).closest('form');
        //alert(form.serialize());
        var formData = new FormData(form.get(0));
        $.ajax({
            type :  'POST',
            url :   '<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>calls/updatecheckout.jsp',
            data :  formData,
            dataType : "json",
            cache : false,
            contentType: false,
            processData: false
        })
        .done(function(resp) {
            if(resp.status == 1){
                __gotoPortalHome();
            }
            else{
                alert(resp.message);
            }
        })
        .fail(function(resp) {
             alert("Error in contacting server.Please try again.");
        })
        .always(function() {
            //hideLoader();
        });
    }
    
    
</script>