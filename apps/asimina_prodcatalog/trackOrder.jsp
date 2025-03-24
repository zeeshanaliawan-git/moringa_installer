<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.net.*, com.etn.beans.app.GlobalParm, javax.servlet.http.Cookie, java.math.BigDecimal, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.util.Base64"%>

<%@ include file="WEB-INF/include/lib_msg.jsp"%>
<%@ include file="common.jsp"%>
<%
	String _error_msg = "Some error occurred";
%>

<%
    String siteid = parseNull(request.getParameter("sid"));

    String _lang = parseNull(request.getParameter("lang"));
    if(_lang.equals("")) _lang = com.etn.asimina.util.SiteHelper.getSiteLangs(Etn,siteid).get(0).getCode();
	
	set_lang(_lang, request, Etn);

    String prefix = getProductColumnsPrefix(Etn, request, _lang);
    Set rsshop = Etn.execute("select * from shop_parameters where site_id = " +  escape.cote(siteid) );
    rsshop.next();
    String order_tracking = parseNull(rsshop.value(prefix + "order_tracking"));
%>
<!DOCTYPE html>
<html lang="<%=com.etn.asimina.util.UIHelper.escapeCoteValue(_lang)%>" >
  <head>
    <link rel="stylesheet" href="css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="css/orangeIcons.min.css">
    <link rel="stylesheet" href="css/boosted450.css">
    
    <script src="js/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="<%=GlobalParm.getParm("EXTERNAL_CATALOG_LINK")%>js/nocache/product.js"></script>


<script>
    $(document).ready(function(){

        $("#submit_button").on("click", function(event){

            event.preventDefault();
            if(validateFields()) {
                trackOrder('<%=GlobalParm.getParm("CART_URL")%>');
            }

        });
            
        $( "input" ).focusout(function() {
            $(this).nextAll().remove();
            if(this.value=="" && $(this).prop("required")){

                $(this).css("border","2px solid #cd3c14");                  
                if($(this).attr("type")=="email") $(this).after("<div class=\"___req_fields invalid-feedback\" style=\"display:block\"><%=libelle_msg(Etn, request, "L'email est requis.")%></div>");
                else $(this).after("<div class=\"___req_fields invalid-feedback\" style=\"display:block\"><%=libelle_msg(Etn, request, "Le numéro de commande est requis.")%></div>");

            }
            else if($(this).attr("type")=="email" && !validateEmail($(this).val())){

                $(this).css("border","2px solid #cd3c14");
                $(this).after("<div class=\"___valid_email invalid-feedback\" style=\"display:block\"><%=libelle_msg(Etn, request, "L'email/téléphone est invalide.")%></div>");

            }
            else if($(this).attr("type")=="text" && !validateNumber($(this).val())){

                $(this).css("border","2px solid #cd3c14");
                $(this).after("<div class=\"___valid_email invalid-feedback\" style=\"display:block\"><%=libelle_msg(Etn, request, "Le format du numéro de commande n'est pas valide.")%></div>");

            }
            else{
                $(this).css("border","2px solid #ccc");
            }
        });

    });
    
    function validateFields(){ 
        let counter = 0;
        $("#trackForm input").each(function(){
            $(this).nextAll().remove();
            if(this.value=="" && $(this).prop("required")){

                $(this).css("border","2px solid #cd3c14");                  
                if($(this).attr("type")=="email") {
                    $(this).after("<div class=\"___req_fields invalid-feedback\" style=\"display:block\"><%=libelle_msg(Etn, request, "L'email est requis.")%></div>");
                }
                else {
                    $(this).after("<div class=\"___req_fields invalid-feedback\" style=\"display:block\"><%=libelle_msg(Etn, request, "Le numéro de commande est requis.")%></div>");
                }
                counter++;
            }
            else if($(this).attr("type")=="email" && !validateEmail($(this).val())){

                $(this).css("border","2px solid #cd3c14");
                $(this).after("<div class=\"___valid_email invalid-feedback\" style=\"display:block\"><%=libelle_msg(Etn, request, "L'email/téléphone est invalide.")%></div>");
                counter++;
            }
            else if($(this).attr("type")=="text" && !validateNumber($(this).val())){

                $(this).css("border","2px solid #cd3c14");
                $(this).after("<div class=\"___valid_email invalid-feedback\" style=\"display:block\"><%=libelle_msg(Etn, request, "Le format du numéro de commande n'est pas valide.")%></div>");
                counter++;
            }
            else{
                $(this).css("border","2px solid #ccc");
            }
        });
        if(counter>0){
            return false;
        }
        else{
            return true;
        }
    }

    function validateNumber(email){

        var pattern = /^[0-9]*$/;

        return $.trim(email).match(pattern) ? true : false;
    }

    function validateEmail(email){
        var pattern2 = /^[0-9-+]+$/;
        var pattern = /^([\w-\.\']+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;

        let validatePattern = $.trim(email).match(pattern)? true : false;
        if(!validatePattern){
            validatePattern = $.trim(email).match(pattern2)? true : false;
        }

        return validatePattern;
    }
    
</script>
    <style>
        html{
            line-height: 100% !important;
            overflow-x: hidden;
        }
        .container{
            max-width:960px;
        }
        .etn-orange-portal-- mark, .etn-orange-portal-- .o-mark{
            padding: 0 !important;
        }
        @media(max-width:768px){
            button.submit_button{
                padding: 8px 6px;
            }
        }
        body {
            margin: 0;
            font-family: HelvNeueOrange,"Helvetica Neue",Helvetica,Arial,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol";
            font-size: 1rem !important;
            font-weight: 400;
            line-height: 1.25;
            color: #000;
            text-align: left;
            background-color: #fff;
        }
        .o-glyphicon-info-sign.text-info{
            cursor: pointer;
        }
        .tiny_modal {
            position: absolute;
            background-color: #eee;
            padding: 15px !important;
            left: -93px;
            top: 40px;
            z-index: 999;
            border-radius: 4px;
            display: none;
            box-shadow: 0 0 5px 0 rgba(0,0,0,0.3);
            min-width: 200px;
        }
        .tiny_modal::before {
            content: "";
            position: absolute;
            top: -11px;
            left: calc(50% - 10px);
            width: 20px;
            height: 20px;
            background-color: inherit;
            transform: rotate(45deg);
        }
        .tiny_modal.active{
            display: block;
        }
        a#showmorelink{
            color:#000;padding:5px;text-decoration: underline;
        }
        a#showmorelink:hover{
            color: rgb(241, 110, 0);
        }
        .portal-cart{
            font-size: 16px;
            line-height: 20px;
        }
        .etn-orange-portal-- .etnhf-container h1{
            font-size: 4em;
            /* font-weight: bold; */
            margin-top: 30px;
            /* margin-bottom: 30px; */
            padding-bottom: 15px;
            /* border-bottom: 2px solid #ccc; */
        }
        .btn{
            padding: .5em 1.125em;
            font-size: 1em;
            font-weight: bold !important;
        }
        .btn.btn-primary{
            color: #fff;
        }
        .btn-primary:not(:disabled):not(.disabled).active, .btn-primary:not(:disabled):not(.disabled):active, .btn-warning:not(:disabled):not(.disabled).active, .btn-warning:not(:disabled):not(.disabled):active, .show > .btn-primary.dropdown-toggle, .show > .btn-warning.dropdown-toggle {
            color: #000 !important;
            border-color: #000 !important;

        }
        .custom-control {
            min-height: 1.25em !important;
            padding-left: 1.875em !important  ;
            /* margin-bottom: .625em !important; */
        }
        .custom-control-label::before {
            width: 1.25em;
            height: 1.25em;
            /* top: 10px; */
        }
        .custom-control-label::after {
            width: 1.25em;
            height: 1.25em;
            background-size: 1em;
            /* top: 10px; */
        }
        .etn-orange-portal-- label,
        label{
            font-weight: 400;
        }
        .custom-control-inline {
            margin-right: 1.25rem !important;

        }
        .o-error .custom-control-label::before{
            border-color: red;
        }
        .etn-orange-portal-- .o-form-horizontal .o-control-label{
            text-align: left;
        }
        .etn-orange-portal-- nav{
            width: auto ;
            height: auto ;
            float: none;
            margin: 0;
        }
        .o-control-label{
            font-weight: bold !important;
        }
        .btn{
            padding: .5em 1.125em;
            font-size: 1em;
            font-weight: bold !important;
        }
        .btn.btn-primary{
            color: #fff;
        }
        button.btn.btn-dark,
        a.btn.btn-dark{
            color: #fff ;
        }
        button.btn.btn-dark:hover{
            color: #000;
        }
        @media(max-width:768px){
            body{
            padding: 0 !important;
            }
            .etn-orange-portal-- h1{
                font-size: 27px !important;
            }
            .etn-orange-portal-- h2{
                font-size: 27px !important;
            }
            .option .custom-control{
                width: 190px;
            }
            .price{
                float: left;
            }
            #back-button{
                padding: 10px 0;
                background: none;
                border: none;
                color: #000;
                font-size: 0.9em;
            }
        }
        .popover{
            font-size: 1em;
            text-align: center;
            width: 400px;
        }
        .etn-orange-portal-- h2{
            margin-bottom: 30px;
            margin-top: 30px;
        }
            .icon-search{
            position: relative;
            }
            .icon-search:before{
            position: absolute;
            left: 0;
            z-index: 999;
            font-size: 18px;
            padding: 10px;
            }

    </style>
</head>
<body class="etn-orange-portal--">
    <div class="etnhf-container" style="font-size: 16px; display:none; padding: 30px 0;border-bottom: 2px solid black;border-top: 2px solid black;margin-top: 30px;">
        <div class="o-col-sm-12" style=" font-weight: bold;">
            <%=libelle_msg(Etn, request, "Désolé, aucune correspondance trouvée.")%>
        </div>
    </div>
    <section> 
        <form id="trackForm" action="" method="POST" class="o-form-horizontal" role="form">
            <div class="container my-5"> 
                <div class="row" id="orderError" style="display: none;"> 
                    <div class="col-md-9">       
                        <div class="alert alert-danger" role="alert">
                            <span class="alert-icon">
                                <span class="sr-only">Danger</span>
                            </span>
                            <p><%=libelle_msg(Etn, request, "Désolé, aucune correspondance trouvée.")%></p>
                        </div>
                    </div> 
                </div> 
                <div class="row"> 
                    <div class="col-md-9"> 
                        <h1>
                            <%=libelle_msg(Etn, request, "Suivi de commande")%>
                        </h1> 
                        <p class="authTeaser">
                            <%=libelle_msg(Etn, request, "Retrouvez en ligne les détails de votre commande Orange.")%> 
                        </p> 
                    </div> 
                </div> 
                <div class="row"> 
                    <div class="col-md-9"> 
                        <p class="authTeaser">
                            <%=libelle_msg(Etn, request, "Saisissez votre adresse email ou numéro de téléphone utilisée pour la commande ainsi que votre numéro de commande.")%>
                        </p> 
                        <div class="form-group"> 
                            <label for="email" class="is-required">
                                <%=libelle_msg(Etn, request, "Adresse e-mail/Numéro de téléphone")%>
                            </label> 
                            <input required id="email" name="email" type="email" class="form-control">
                            <div class="invalid-feedback"></div> 
                        </div> 
                        <div class="form-group"> 
                            <label for="orderId" class="is-required">
                                <%=libelle_msg(Etn, request, "Numéro de commande")%> 
                            </label>
                            <input required id="orderId" name="orderId" type="text" class="form-control">
                            <div class="invalid-feedback"></div> 
                        </div> 
                        <p class="login-submit"> 
                            <input type="button" id="submit_button" class="btn btn-primary" value="<%=libelle_msg(Etn, request, "Voir ma commande")%>"> 
                        </p> 
                    </div> 
                </div> 
            </div> 
        </form>
    </section>

</body>

</html>