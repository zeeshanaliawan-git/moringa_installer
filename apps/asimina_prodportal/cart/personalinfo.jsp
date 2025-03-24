<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.asimina.cart.*, com.etn.asimina.util.*,org.json.*"%>

<%@ include file="lib_msg.jsp"%>

<%@ include file="common.jsp"%>
<%@ include file="../common2.jsp"%>
<%@ include file="../common.jsp"%>
<%@ include file="priceformatter.jsp"%>

<%
    int stepNumber = 1; 
	String _error_msg = "Some error occurred while processing cart";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "funnel";

	String ___muuid = CartHelper.getCartMenuUuid(request);
	String session_id = CartHelper.getCartSessionId(request);
        
%>
<%@ include file="../logofooter.jsp"%>
<%	
	Cart cart = CartHelper.loadCart(Etn, request, session_id, ___loadedsiteid, ___muuid, true);
	if(cart.isEmpty())
	{		
		response.sendRedirect(cart.getError(CartError.EMPTY_CART).getReturnUrl());
		return;
	}	
	if(cart.hasError())
	{		
		response.sendRedirect(com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"cart.jsp?muid="+___muuid);
		return;
	}	

	//reset session token in db for next screen
    String uuidSessionToken = CartHelper.setSessionToken(Etn, cart);

    String email = "";
    String name = "";
    String surname = "";
    String salutation = "";
    String nationality = "";
    String identityId = "";
    String identityType = "";
    String infoSup1 = "";
    String contactPhoneNumber1 = "";
    String newPhoneNumber = "";
    String baline1 = "";
    String baline2 = "";
    String batowncity = "";
    String bapostalCode = "";
    String country = "";
    String identityPhoto = "";
    String identityPhotoFileName = "";
    String newsletter = "";
	
	String client_id = "";
	boolean logged = false;
	String client_uuid = "";	
	Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	if(client != null)
	{
		logged = true;
		client_id = client.getProperty("id");
		client_uuid = client.getProperty("client_uuid");

        email = client.getProperty("email");
        name = client.getProperty("name");
        surname = client.getProperty("surname");
        contactPhoneNumber1 = client.getProperty("mobile_number");
        Set rsOrder = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("SHOP_DB")+".orders where client_id="+escape.cote(client_id)+" order by id desc limit 1");
        if(rsOrder.next())
		{
            name = rsOrder.value("name");
            surname = rsOrder.value("surnames");
            salutation = rsOrder.value("salutation");
            identityId = rsOrder.value("identityId");
            identityType = rsOrder.value("identityType");
            contactPhoneNumber1 = rsOrder.value("contactPhoneNumber1");
            newPhoneNumber = rsOrder.value("newPhoneNumber");
            baline1 = rsOrder.value("baline1");
            baline2 = rsOrder.value("baline2");
            batowncity = rsOrder.value("batowncity");
            bapostalCode = rsOrder.value("bapostalCode");
            country = rsOrder.value("country");
            identityPhoto = rsOrder.value("identityPhoto");
            if(identityPhoto.length()>0)
			{
                Set rsFile = Etn.execute("select file_name from files where file_uuid="+escape.cote(identityPhoto));
                if(rsFile.next())
				{
                    identityPhotoFileName = rsFile.value(0);
                }
            }
            newsletter = rsOrder.value("newsletter");
        }
    }
    
	email = parseNull(cart.getProperty("email"));
	name = parseNull(cart.getProperty("name"));
	surname = parseNull(cart.getProperty("surnames"));
	salutation = parseNull(cart.getProperty("salutation"));
	identityId = parseNull(cart.getProperty("identityId"));
	identityType = parseNull(cart.getProperty("identityType"));
	contactPhoneNumber1 = parseNull(cart.getProperty("contactPhoneNumber1"));
	newPhoneNumber = parseNull(cart.getProperty("newPhoneNumber"));
	baline1 = parseNull(cart.getProperty("baline1"));
	baline2 = parseNull(cart.getProperty("baline2"));
	batowncity = parseNull(cart.getProperty("batowncity"));
	bapostalCode = parseNull(cart.getProperty("bapostalCode"));
	country = parseNull(cart.getProperty("country"));
	identityPhoto = parseNull(cart.getProperty("identityPhoto"));
	if(identityPhoto.length()>0)
	{
		Set rsFile = Etn.execute("select file_name from files where file_uuid="+escape.cote(identityPhoto));
		if(rsFile.next())
		{
			identityPhotoFileName = rsFile.value(0);
		}
	}
	newsletter = parseNull(cart.getProperty("newsletter"));
    
    Set rsDomain = Etn.execute("Select domain from sites where id = " + escape.cote(_menuRs.value("site_id")));
    rsDomain.next();
    Map<String, String> gtmScriptCode = getGtmScriptCodeForCart(Etn, _menuRs.value("id"), rsDomain.value(0)+com.etn.beans.app.GlobalParm.getParm("CART_EXTERNAL_LINK")+"checkout.jsp", "funnel", "", "", "",client_uuid,"","",(logged?"yes":"no"), "");
	
	String __cartmenuid = _menuRs.value("id");
	
    int tunnelSteps = 1;
    
	//set the step name here as it is required for further verifications
	Etn.executeCmd("update cart set cart_step = "+escape.cote(CartHelper.Steps.PERSONAL_INFO)+" where id = "+escape.cote(cart.getProperty("id")));
    
%>
<!DOCTYPE html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
  <head>
      <%=parseNull(gtmScriptCode.get("SCRIPT_SNIPPET"))%>
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css">
<%=_headhtml%>
    
<style>
   .btn-delete-image:hover svg path,
   .btn-delete-image:active svg path
    {
    fill: #fff;
    }
      
      .etnhf-gray-footer{
          display: none;
      }
.custom-file-input:lang(en)~.custom-file-label::after {
    content: ""; 
}	  
	  
	  
.loading2{
	  overflow: hidden;
	  position: relative;
  }
  
.loading2::after{
	  content: "";
	  overflow: hidden;
	  display : block;
	  position:   absolute;
	  z-index:    99999;
	  top:        0;
	  left:       0;
	  height:     100%;
	  width:      100%;
	  background: rgba( 255, 255, 255, .8 )
				  url('../img/spinner.gif')
				  50% 50%
				  no-repeat;
  
}
  
body.loading2::after{
	position: fixed;
}
  
.loading2 > .loading2msg{
	  position: absolute;
	  top : 55%;
	  width : 100%;
	  text-align: center;
	  z-index: 9999999;
}
body.loading2 > .loading2msg{
	position: fixed;
}	  
</style>
    

</head>
<body class="etn-orange-portal-- isWithoutMenu">
<%=parseNull(gtmScriptCode.get("NOSCRIPT_SNIPPET"))%>
<%=_headerHtml%>


<%@ include file="stepbar.jsp"%>
    
    
<div class="container">
    <h2 class="TunnelMainTitle"><%=libelle_msg(Etn, request, "Informations personnelles")%></h2>

    <div class="row">
        <div class="col-12 col-lg-6">

            <form id="infoForm" class="TunnelForm" action="<%=(isKycRequired)? "kyc.jsp":"deliv.jsp" %>" method="post"  data-messages='{"required":"<%=escapeCoteValue(libelle_msg(Etn, request, "Ce champ est requis."))%>", "regex":"<%=escapeCoteValue(libelle_msg(Etn, request, "Ce champ est non valide."))%>", "confirm":"<%=escapeCoteValue(libelle_msg(Etn, request, "Veuillez saisir deux fois la même valeur."))%>"}'>
                <input type="hidden" name="session_token" value="<%=escapeCoteValue(uuidSessionToken)%>">
                <div class="accordion TunnelAccordion" id="accordionExample">
                    <div class="card TunnelForm-step" data-tunnel-step="<%=tunnelSteps++%>">
                        <h3 id="headingOne" class="card-header mb-0">
                            <button class="JS-TunnelForm-stepButton TunnelForm-stepButton btn btn-link" type="button" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                                <span><%=libelle_msg(Etn, request, "Coordonnées")%></span><span class="TunnelForm-sectionIconValid" data-svg="/src/assets/icons/icon-valid.svg"></span>
                                <span class="TunnelForm-sectionIconInvalid" data-svg="/src/assets/icons/icon-alert.svg"></span>
                            </button>
                        </h3>
                        <div id="collapseOne" class="collapse show" aria-labelledby="headingOne" data-parent="#accordionExample">
                            <div class="card-body mt-2 ml-2">
                                <div class="form-group mb-2">
                                    <div class="d-block font-weight-bold mb-2"><%=libelle_msg(Etn, request, "Civilité")%> <span class="TunnelForm-asterisk"></span></div>
                                    <div class="custom-control custom-radio custom-control-inline">
                                        <input type="radio" id="customRadioInline1" name="salutation" value="M" <%=(salutation.equals("M")?"checked":"")%> class="custom-control-input isPristine" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "La civilité est requise."))%>">
                                        <label class="custom-control-label" for="customRadioInline1"><%=libelle_msg(Etn, request, "M.")%></label>
                                    </div>
                                    <div class="custom-control custom-radio custom-control-inline">
                                        <input type="radio" id="customRadioInline2" name="salutation" value="Mme" <%=(salutation.equals("Mme")?"checked":"")%> class="custom-control-input isPristine" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "La civilité est requise."))%>">
                                        <label class="custom-control-label" for="customRadioInline2"><%=libelle_msg(Etn, request, "Mme")%></label>
                                    </div>
                                    <div class="invalid-feedback mt-1 mb-3"><%=libelle_msg(Etn, request, "Veuillez choisir une civilité")%></div>
                                </div>

                                <div class="form-group">
                                    <label for="name" class="is-required"><%=libelle_msg(Etn, request, "Nom")%></label>
                                    <input type="text" class="form-control isPristine" id="surnames" name="surnames" value="<%=escapeCoteValue(surname)%>" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le nom est requis."))%>" data-regex="/^[a-zA-Z éèêëô]+$/" data-regex-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le nom n'est pas valide."))%>">
                                    <div class="invalid-feedback"></div>
                                </div>

                                <div class="form-group">
                                    <label for="surnames" class="is-required"><%=libelle_msg(Etn, request, "Prénom")%></label>
                                    <input type="text" class="form-control isPristine" id="name" name="name" value="<%=escapeCoteValue(name)%>" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le prénom est requis."))%>" data-regex="/^[a-zA-Z éèêëô]+$/" data-regex-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le prénom n'est pas valide."))%>">
                                    <div class="invalid-feedback"></div>
                                </div>

                                <div class="form-group">
                                    <label for="identityType" class="is-required"><%=libelle_msg(Etn, request, "Type de la pièce d'identité")%></label><br>
                                    <select class="custom-select isPristine" id="identityType" name="identityType" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Veuillez choisir un type."))%>">
                                        <option disabled=""><%=libelle_msg(Etn, request, "Choisissez un type")%></option>
                                        <option <%=(identityType.equals("Passeport")?"selected":"")%> value="Passeport"><%=libelle_msg(Etn, request, "Passeport")%></option>
                                        <option <%=(identityType.equals("ID")?"selected":"")%> value="ID"><%=libelle_msg(Etn, request, "Carte d'identité")%></option>
                                        <option <%=(identityType.equals("Resident Card")?"selected":"")%> value="Resident Card"><%=libelle_msg(Etn, request, "Carte de résident")%></option>
                                    </select>
                                    <div class="invalid-feedback"></div>
                                </div>

                                <div class="form-group">
                                    <label for="identityId" class="is-required"><%=libelle_msg(Etn, request, "Numéro de pièce d'identité")%></label><br>
                                    <div class="input-group mb-3">
                                        <input type="text" class="form-control isPristine" aria-label="" id="identityId" name="identityId" value="<%=escapeCoteValue(identityId)%>" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro est requis."))%>">
<!--                                        <div class="input-group-append">
                                            <span class="TunnelForm-tooltip" data-toggle="tooltip" data-placement="top" title="" data-original-title="Tooltip on top" data-svg="/src/assets/icons/icon-assistance.svg"></span>
                                        </div>-->
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="is-required"><%=libelle_msg(Etn, request, "Photo de la pièce d’identité")%></label>
                                    <div class="input-group mb-3">
                                    <%if(identityPhoto.length()>0){%>
                                        <div class="custom-file identityPhoto d-none">
                                            <input type="file" class="custom-file-input isPristine" id="identityPhoto" accept="image/jpeg,image/png,image/gif,image/svg+xml,image/bmp,image/tiff,application/pdf" name="identityPhoto" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "La photo est requise."))%>">
                                            <label class="custom-file-label" for="identityPhoto"></label>
                                        </div>
                                        <input type="text" class="form-control existingIdentityPhoto" value="<%=escapeCoteValue(identityPhotoFileName)%>" readonly="">
                                        <input type="hidden" name="existingIdentityPhoto" value="<%=escapeCoteValue(identityPhoto)%>" readonly="">
                                        <div class="input-group-append">
                                            <button type="button" class="btn btn-secondary btn-delete-image" onclick="removeIdentityPhoto(this);">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 1000 1000">
                                                <defs>
                                                    <style>
                                                    .cls-1 {
                                                        fill-rule: evenodd;
                                                    }
                                                    </style>
                                                </defs>
                                                <path id="Delete" class="cls-1" d="M817.493,676.165a49.977,49.977,0,0,1,0,70.664l-70.664,70.664a49.977,49.977,0,0,1-70.664,0L499.5,640.828,322.835,817.493a49.977,49.977,0,0,1-70.664,0l-70.664-70.664a49.977,49.977,0,0,1,0-70.664L358.172,499.5,181.507,322.835a49.977,49.977,0,0,1,0-70.664l70.664-70.664a49.977,49.977,0,0,1,70.664,0L499.5,358.172,676.165,181.507a49.977,49.977,0,0,1,70.664,0l70.664,70.664a49.977,49.977,0,0,1,0,70.664L640.828,499.5Z"/>
                                            </svg>
                                            </button>
                                            <span class="TunnelForm-tooltip" data-toggle="tooltip" data-placement="top" title="" data-original-title="Tooltip on top" data-svg="/src/assets/icons/icon-assistance.svg"></span>
                                        </div>
                                        
                                    <%} else {%>
                                        <div class="custom-file">
                                            <input type="file" class="custom-file-input isPristine" id="identityPhoto" accept="image/jpeg,image/png,image/gif,image/svg+xml,image/bmp,image/tiff,application/pdf" name="identityPhoto" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "La photo est requise."))%>">
                                            <label class="custom-file-label" for="identityPhoto"></label>
                                        </div>
                                        <div class="input-group-append">
                                            <span class="TunnelForm-tooltip" data-toggle="tooltip" data-placement="top" title="" data-original-title="Tooltip on top" data-svg="/src/assets/icons/icon-assistance.svg"></span>
                                        </div>
                                    <%}%>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="form-group mt-4">
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input isPristine" id="customCheck1" <%=(identityPhoto.length()>0?"checked":"")%> required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Présentation de la pièce d'identité requise"))%>">
                                        <label class="custom-control-label" for="customCheck1"><%=libelle_msg(Etn, request, "Je note que je dois présenter une pièce d'identité lors de la livraison")%></label>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="form-group mt-4 mb-4">
                                    <button type="button" class="btn btn-info JS-TunnelForm-nextBtn funnel-data-layer "
                                        data-dl_event='standard_click' data-dl_event_category='contact_informations' data-dl_event_action='button_click' data-dl_event_label='continue' ><%=libelle_msg(Etn, request, "Continuer")%></button>
                                </div>

                            </div>
                        </div>
                    </div>
                    
                    <div class="card isPristine TunnelForm-step" data-tunnel-step="<%=tunnelSteps++%>">
                        <h3 class="card-header mb-0" id="headingTwo">
                            <button class="JS-TunnelForm-stepButton TunnelForm-stepButton btn btn-link collapsed" type="button" data-toggle="collapse" data-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                                <span><%=libelle_msg(Etn, request, "Contacts")%></span><span class="TunnelForm-sectionIconValid" data-svg="/src/assets/icons/icon-valid.svg"></span>
                                <span class="TunnelForm-sectionIconInvalid" data-svg="/src/assets/icons/icon-alert.svg"></span>
                            </button>
                        </h3>
                        <div id="collapseTwo" class="collapse" aria-labelledby="headingTwo" data-parent="#accordionExample">
                            <div class="card-body mt-2 ml-2">

                                <div class="TunnelForm-infoBlock">
                                    <%=libelle_msg(Etn, request, "Veillez à bien indiquer votre numéro de téléphone. Nous vous appellerons pour confirmer cette commande.")%>
                                </div>

                                <div class="form-group">
                                    <label for="contactPhoneNumber1" class="is-required"><%=libelle_msg(Etn, request, "Numéro de téléphone")%></label>
                                    <input type="tel" class="form-control isPristine" id="contactPhoneNumber1" name="contactPhoneNumber1" value="<%=escapeCoteValue(contactPhoneNumber1)%>" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro est requis."))%>" data-regex="/^((\+)\d{2,3}|0)[1-9](\d{2}){4}$/" data-regex-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le numéro de téléphone doit avoir un format sous la forme 0XXXXXXXXX."))%>">
                                    <div class="invalid-feedback"></div>
                                </div>

                                <div class="form-group">
                                    <label for="email" class="is-required"><%=libelle_msg(Etn, request, "Adresse email")%></label>
                                    <input type="email" class="form-control isPristine" id="email" name="email" required="" value="<%=escapeCoteValue(email)%>" <%=(!client_id.equals("")&&email.length()>0?"readonly":"")%> data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "L'email est requis."))%>" data-regex="/^[A-Za-z0-9._-]+@[A-Za-z0-9._-]+\.[A-Za-z]{2,6}$/" data-regex-error="<%=escapeCoteValue(libelle_msg(Etn, request, "L'email n'est pas valide."))%>">
                                    <div class="invalid-feedback"></div>
                                </div>
                                <%if(client_id.equals("")){%>
                                <div class="form-group">
                                    <label for="emailConfirmation" class="is-required"><%=libelle_msg(Etn, request, "Confirmer votre adresse email")%></label>
                                    <input type="email" autocomplete="off" class="form-control isPristine" id="emailConfirmation" name="emailConfirmation" required="" value="<%=escapeCoteValue(email)%>" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "L'email est requis."))%>" data-regex="/^[A-Za-z0-9._-]+@[A-Za-z0-9._-]+\.[A-Za-z]{2,6}$/" data-regex-error="<%=libelle_msg(Etn, request, "L'email n'est pas valide.")%>" data-confirm="#email" data-confirm-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Les deux adresses saisies sont différentes."))%>">
                                    <div class="invalid-feedback"></div>
                                </div>
                                <%}%>
                                <div class="form-group mt-4">
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="newsletterCheckbox" <%=(newsletter.equals("1")?"checked":"")%>>
                                        <input id="newsletter" name="newsletter" type="hidden" value="0" />
                                        <label class="custom-control-label" for="newsletterCheckbox"><%=libelle_msg(Etn, request, "Je souhaite recevoir la newsletter Orange")%></label>
                                    </div>
                                </div>

                                <div class="form-group mt-4 mb-4">
                                    <button type="button" class="btn btn-info JS-TunnelForm-nextBtn funnel-data-layer"
                                        data-dl_event='standard_click' data-dl_event_category='contacts' data-dl_event_action='button_click' data-dl_event_label='continue' ><%=libelle_msg(Etn, request, "Continuer")%></button>
                                </div>

                            </div>
                        </div>
                    </div>
                    <div class="card isPristine TunnelForm-step" data-tunnel-step="<%=tunnelSteps++%>">
                        <h3 class="card-header mb-0" id="headingThree">
                            <button class="JS-TunnelForm-stepButton TunnelForm-stepButton btn btn-link collapsed" type="button" data-toggle="collapse" data-target="#collapseThree" aria-expanded="false" aria-controls="collapseThree">
                                <span><%=libelle_msg(Etn, request, "Numéro Orange")%></span>
                                <span class="TunnelForm-sectionIconValid" data-svg="/src/assets/icons/icon-valid.svg"></span>
                                <span class="TunnelForm-sectionIconInvalid" data-svg="/src/assets/icons/icon-alert.svg"></span>
                            </button>
                        </h3>
                        <div id="collapseThree" class="collapse" aria-labelledby="headingThree" data-parent="#accordionExample">
                            <div class="card-body mt-2 ml-2">

                                <div class="form-group">
                                    <label for="newPhoneNumber"><%=libelle_msg(Etn, request, "Orange vous propose")%></label><br>
                                    <select class="custom-select" id="newPhoneNumber" name="newPhoneNumber">
                                        <option <%=(newPhoneNumber.equals("0123456789")?"selected":"")%> value="0123456789">01 2345 6789</option>
                                        <option <%=(newPhoneNumber.equals("0123456884")?"selected":"")%> value="0123456884">01 2345 6884</option>
                                        <option <%=(newPhoneNumber.equals("0123456992")?"selected":"")%> value="0123456992">01 2345 6992</option>
                                        <option <%=(newPhoneNumber.equals("0123457990")?"selected":"")%> value="0123457990">01 2345 7990</option>
                                    </select>
                                </div>

                                <div class="form-group mt-4 mb-4">
                                    <button type="button" class="btn btn-info JS-TunnelForm-nextBtn funnel-data-layer"
                                        data-dl_event='standard_click' data-dl_event_category='orange_numbers' data-dl_event_action='button_click' data-dl_event_label='continue' ><%=libelle_msg(Etn, request, "Continuer")%></button>
                                </div>

                            </div>
                        </div>
                    </div>
                    <div class="card isPristine TunnelForm-step" data-tunnel-step="<%=tunnelSteps++%>">
                        <h3 class="card-header mb-0" id="headingFour">
                            <button class="JS-TunnelForm-stepButton TunnelForm-stepButton btn btn-link collapsed" type="button" data-toggle="collapse" data-target="#collapseFour" aria-expanded="false" aria-controls="collapseFour">
                                <span><%=libelle_msg(Etn, request, "Adresse de facturation")%></span>
                                <span class="TunnelForm-sectionIconValid" data-svg="/src/assets/icons/icon-valid.svg"></span><span class="TunnelForm-sectionIconInvalid" data-svg="/src/assets/icons/icon-alert.svg"></span>
                            </button>
                        </h3>
                        <div id="collapseFour" class="collapse" aria-labelledby="headingFour" data-parent="#accordionExample">
                            <div class="card-body mt-2 ml-2">

                                <div class="form-group">
                                    <label for="baline1" class="is-required"><%=libelle_msg(Etn, request, "Adresse")%></label>
                                    <textarea class="form-control isPristine" id="baline1" name="baline1" rows="3" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "L'adresse est requise."))%>"><%=baline1%></textarea>
                                    <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Adresse non valide")%></div>
                                </div>

                                <div class="form-group">
                                    <label for="baline2"><%=libelle_msg(Etn, request, "Complément d'adresse")%></label>
                                    <input type="text" class="form-control" id="baline2" name="baline2" value="<%=escapeCoteValue(baline2)%>">
                                    <div class="invalid-feedback"></div>
                                </div>

                                <div class="form-group">
                                    <label for="bapostalCode" class="is-required"><%=libelle_msg(Etn, request, "Code postal")%></label>
                                    <input type="text" class="form-control isPristine" id="bapostalCode" name="bapostalCode" value="<%=escapeCoteValue(bapostalCode)%>" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le code postal est requis."))%>">
                                    <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Code postal non valide")%></div>
                                </div>

                                <div class="form-group">
                                    <label for="batowncity" class="is-required"><%=libelle_msg(Etn, request, "Ville")%></label>
                                    <input type="text" class="form-control isPristine" id="batowncity" name="batowncity" value="<%=escapeCoteValue(batowncity)%>" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "La ville est requise."))%>">
                                    <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Ville non valide")%></div>
                                </div>

                                <div class="form-group">
                                    <label for="country" class="is-required"><%=libelle_msg(Etn, request, "Pays")%></label>
                                    <input type="text" class="form-control isPristine" id="country" name="country" value="<%=escapeCoteValue(country)%>" required="" data-required-error="<%=escapeCoteValue(libelle_msg(Etn, request, "Le pays est requis."))%>">
                                    <div class="invalid-feedback"><%=libelle_msg(Etn, request, "Pays non valide")%></div>
                                </div>

                                <div class="form-group mt-4 mb-4">
                                    <button type="button" class="btn btn-primary JS-TunnelForm-nextBtn" onclick="trackNextButtonClick()"><%=libelle_msg(Etn, request, "Suivant")%></button>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>

            </form>

        </div>
        <div class="StickySidebar col-12 col-lg-4 offset-lg-2" data-sticky-options='{"startTrigger": 20}'>
            <div class="StickySidebar-content OrderSummary">
                <jsp:include page="../calls/getRecap.jsp">
                    <jsp:param name="site_id" value="<%=escapeCoteValue(___loadedsiteid)%>"/>
                    <jsp:param name="lang" value="<%=escapeCoteValue(_lang)%>"/>
                    <jsp:param name="menu_id" value="<%=escapeCoteValue(__cartmenuid)%>"/>
                </jsp:include>
            </div>
        </div>                    
    </div>

</div>
 <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/jquery.min.js" ></script>
 <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/search-bundle.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/tunnel-bundle.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/focus-visible.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/popper.min.js" ></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/jquery.tablesorter.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/swiper.min.js"></script>
    <script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/boosted.js" ></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bs-custom-file-input.min.js"></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/TweenMax.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/nouislider.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/algoliasearch.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/mobile-detect.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/sticky-sidebar.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/ResizeSensor.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/newui/bundle.js"></script>

<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/moment.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js//moment-with-locales.min.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/vue.js"></script>


<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cart.js"></script>
<script src="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>js/cookie.js"></script>
<script>
  moment.locale('fr');
</script>

<!-- TODO : @Lilian Permet de personnaliser la fonction de conversion des prix en string vers float selon les pays -->
<script>
  window.orange_customFormatPrice = {
    products: function (item) { // Use  window.searchAlgoliaConfig.indices keys to define specific price format
      return item.prix + " Euros"; // Use real aglgolia properties index to format price
    }
  }
</script>
    <%=_footerHtml%>
    <%=_endscriptshtml%>
<script>
    var datalayerCommonVariables = {
        funnel_name: 'funnel',
        funnel_step: 'Step 2',
        funnel_step_name: 'Personal Information',
        product_line: 'n/a',
        order_type: 'Acquisition'
    };
    $(document).ready(function(){
        document.title = "<%=libelle_msg(Etn, request, "Informations personnelles")%> | "+document.title;
        pageTrackingWithProducts();
        
        trackSectionLoad("1");

        $('.TunnelForm-step').on('shown.bs.collapse', function (e) {
            var dataCurrentStep = $(this).attr('data-tunnel-step');
            trackSectionLoad(dataCurrentStep);
        });

        $(document).on("click",".funnel-data-layer",function(){
            //var __dlcontent = new Object();
            
            if(typeof dataLayer !== 'undefined' && dataLayer != null) 
            {
                var newDlObj = cloneObject(_etn_dl_obj);
                if(this.dataset.dl_event) newDlObj.event = this.dataset.dl_event;
                if(this.dataset.dl_event_category) newDlObj.event_category = this.dataset.dl_event_category;
                if(this.dataset.dl_event_action) newDlObj.event_action = this.dataset.dl_event_action;
                if(this.dataset.dl_event_label) newDlObj.event_label = this.dataset.dl_event_label;

//                for(var key in datalayerCommonVariables){
//                    newDlObj[key] = datalayerCommonVariables[key];
//                }
                dataLayer.push(newDlObj);
            }

        });	
    });
    
    function trackNextButtonClick(){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            newDlObj.event = "standard_click";
            newDlObj.event_category = "billing_address";
            newDlObj.event_action = "button_click";
            newDlObj.event_label = "next";

//            for(var key in datalayerCommonVariables){
//                newDlObj[key] = datalayerCommonVariables[key];
//            }
            dataLayer.push(newDlObj);
        }
    }
    
    function trackSectionLoad(section){
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var eventLabel = {
                "1" : "contact_informations",
                "2" : "contacts",
                "3" : "orange_numbers",
                "4" : "billing_address"
            };
            var newDlObj = cloneObject(_etn_dl_obj);

            var tempObject = {
                    event: "standard_click",
                    event_action: "load",
                    event_category: "funnel_step2",
                    event_label: eventLabel[section]}; // event tracking

            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }

//            for(var key in datalayerCommonVariables){
//                newDlObj[key] = datalayerCommonVariables[key];
//            }
            dataLayer.push(newDlObj);   
        }
    }

    function pageTrackingWithProducts(){        
        if(typeof dataLayer !== 'undefined' && dataLayer != null) 
        {
            var newDlObj = cloneObject(_etn_dl_obj);
            var tempObject = {
                page_name: 'personnal_informations'
            }; // page tracking 
            
            for(var key in tempObject){
                newDlObj[key] = tempObject[key];
            }
            
            for(var key in datalayerCommonVariables){
                newDlObj[key] = datalayerCommonVariables[key];
            }
            
            var productsObject = objectFromArray(refitKeysArray(recapDatalayerProducts));
            for(var key in productsObject){
                newDlObj[key] = productsObject[key];
            }
            dataLayer.push(newDlObj);           
            
            tempObject = {"event": "checkout",
                            event_action: "",
                            event_category: "",
                            event_label: "","ecommerce": {"checkout": {"actionField": {"step": 2, "option": "Personal Information"}, "products": recapDatalayerProducts}}};; // ecommerce tracking
            
            for(var key in datalayerCommonVariables){
                tempObject[key] = datalayerCommonVariables[key];
            }
            dataLayer.push(tempObject);   
        }
    }
    let file;
    function removeIdentityPhoto(button){
        $('.identityPhoto').removeClass('d-none');
        $(button).hide();
        $('.existingIdentityPhoto').hide();
        $('#identityPhoto').attr("required", true);
        file={};
    }

    document.querySelectorAll("#identityPhoto").forEach((inputElement) => {
        inputElement.addEventListener("change", (e) => {
            if (inputElement.files.length) {
                file=inputElement.files[0]
            }
        });

    });

	function showLoader(msg, ele){

		if(typeof ele === "undefined") ele = $('body');

		ele.addClass('loading2');

		$(ele).find('div.loading2msg').remove();
		var msgEle = $('<div>').addClass('loading2msg');
		$(ele).append(msgEle);

		if(typeof msg !== 'undefined'){
			msgEle.html(msg);
		}
		else{
			msgEle.html("");
		}

	}

	function hideLoader(){
		$('.loading2').removeClass('loading2');
	}

    function uploadData(formData){
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
                    $('#infoForm').submit();
                }
                else{
                    alert(resp.message);
                }
            })
            .fail(function(resp) {
                alert("Error in contacting server.Please try again.");
            })
            .always(function() {
				hideLoader();
            });
    }
    
    function updateCheckout(){
        if($("#newsletterCheckbox").is(":checked")) $("#newsletter").val("1");
        else $("#newsletter").val("0");

        var form = $('#infoForm');
        var formData = new FormData(form.get(0));

		showLoader();
        if(file){
            if (file.size  >= <%=com.etn.beans.app.GlobalParm.getParm("client_image_max_size")%>) {
                const blobURL = window.URL.createObjectURL(file);
                const img = new Image();
                img.src = blobURL;
                img.onload = function () {
                    window.URL.revokeObjectURL(blobURL);
                    const canvas = document.createElement('canvas');
                    const [newWidth, newHeight] =calculateSize(img, 2048);
                    canvas.width = newWidth;
                    canvas.height = newHeight;
                    const ctx = canvas.getContext('2d');
                    ctx.drawImage(img, 0, 0, newWidth, newHeight);

                    canvas.toBlob(
                        (blob) => {
                            file = new File([blob], file.name);
                            if (file.size  > <%=com.etn.beans.app.GlobalParm.getParm("client_image_max_size")%>) {
                                let tunlBtn1 = $('#headingOne').children().eq(0);
                                let tunlBtn4 = $('#headingFour').children().eq(0);

                                tunlBtn4.attr("aria-expanded","false")
                                tunlBtn4.addClass('collapsed');
                                tunlBtn1.attr("aria-expanded","true")
                                tunlBtn1.removeClass('collapsed');

                                $('#collapseFour').removeClass('show');
                                $('#collapseOne').addClass('show');

                                $('.identityPhoto').removeClass('d-none');
                                $('.existingIdentityPhoto').hide();
                                $('#identityPhoto').attr("required", true);

                                alert("<%=libelle_msg(Etn, request, "Image is too large. Choose another image.")%>");
                            }else{
                                formData.delete('identityPhoto');
                                formData.append("identityPhoto",file);
								uploadData(formData);
							}
                        },
                        "image/jpeg",
                        <%=com.etn.beans.app.GlobalParm.getParm("client_image_quality")%>
                    );
                };
            }else{
                uploadData(formData)
            }
        }else{
            uploadData(formData)
        }
		hideLoader();
    }

    function calculateSize(img, size) {
		let width = img.width;
		let height = img.height;
		let aspectRatio = width/height;
		if (width > height && width > size) {		
			width = size;
			height = width/aspectRatio;
		} else if(height > size) {
			height = size;
			width = height * aspectRatio;
		}
		return [width, height];
	}
    </script>

  </body>
</html>
