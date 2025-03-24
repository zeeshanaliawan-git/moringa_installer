		var globalEnable = false;
                var logged = false;

                function addToCart(id, cookieName, path, isTarif){
                    if(globalEnable){
                        $("#errorDiv").hide();
                    }
                    else{
                        $("#errorDiv").show();
                        return;
                    }
                    var productsArray;            
                    if(getDecodedCookie(cookieName) == ""){
                        productsArray = [];			
                    }
                    else {
                        productsArray = JSON.parse(getDecodedCookie(cookieName));
                        //if(products.indexOf(id)==-1) products+=","+id;
                    }
                    
                    var attributes = [];
                    $( ".attributes" ).each(function() {
                        attributes.push($( this ).val());
                    });

                    attributes.sort(function(a, b){
                        a = a.substring(0,a.indexOf("_"));
                        b = b.substring(0,b.indexOf("_"));
                        return parseInt(a)-parseInt(b);
                    });
                    
                    var installment_plan = ($("input[name=installment_plan]").length?$("input[name=installment_plan]:checked").val():"");
                    var installment_plan_logged = installment_plan; // as for postpaid, will always be same as no one time payment.
                    /*($("input[name=installment_plan_logged]").length?$("input[name=installment_plan_logged]:checked").val():"");
                    if(logged) installment_plan = installment_plan_logged;
                    else installment_plan_logged = installment_plan;*/
                    var timestamp = Date.now()+"";
                    
                    var product = {};
                    var pushProduct = true; // to stop the push when only quantity is updated.
                    
                    if($( ".product_relations" ).length==0){ // does not apply for products having related products for now.
                        productsArray.forEach(function(item,i) {
                            if(item.id==id && item.attributes+""==attributes+"" && item.related_id=="" && item.installment_plan==installment_plan && item.installment_plan_logged==installment_plan_logged && item.qty!=10){
                                pushProduct = false;
                                return false;
                            }
                        });
                    }
                    if(pushProduct){
                        product = {
                            id: id,
                            qty: "1",
                            attributes: attributes,
                            installment_plan: installment_plan,
                            installment_plan_logged: installment_plan_logged,
                            related_id: "",
                            timestamp: timestamp
                        };
//                    if (productsArray.some(function(e) e.id == id)) {
//                        productsArray.push(product);
//                    } else {
//                        productsArray.push(product);
//                    }
                        productsArray.push(product);
                    }
                    
                    
                    $( ".product_relations" ).each(function() {
                        var related_id = $( this ).val();
                        var attributes = [];
                        $( ".attributes_"+related_id ).each(function() {
                            attributes.push($( this ).val());
                        });

                        attributes.sort(function(a, b){
                            a = a.substring(0,a.indexOf("_"));
                            b = b.substring(0,b.indexOf("_"));
                            return parseInt(a)-parseInt(b);
                        });

                        product = {
                            id: related_id,
                            qty: $("#quantity").val(),
                            attributes: attributes,
                            installment_plan: "",
                            installment_plan_logged: "",
                            related_id: id+timestamp,
                            parent_price: $( "#parent_price_"+related_id ).val()
                        };
                        productsArray.push(product);
                    });
                    setEncodedCookie(cookieName, JSON.stringify(productsArray),7);
                    var menuCookieName = cookieName.replace("CartItems","")+"MenuUuid";
                    setEncodedCookie(menuCookieName, ______muid,7);
                    //setCookie("cartItems", products,7);
                    cartDialog();
                    //$('<form method="POST" action="'+path+'cart/cart.jsp'+'"><input type="hidden" name="muid" value="'+______muid+'" ></form>').appendTo('body').submit();
                    //window.location=path+"cart/cart.jsp?menuid="+______menuid;
                }
                
                function loadPostpaidPrices(path, postData, enable){
                    jQuery.ajax({
			url : path+'cart/loadPostpaidPrices.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            $("#installment_container").html($.trim(data));
                            
                            $('.toggleInfo').click(function(e){
                              e.preventDefault();
                              $(this).next('p').toggle('fast');
                              $(this).find('span.o-glyphicon').toggleClass('o-glyphicon-triangle-top o-glyphicon-triangle-bottom');
                            });
                            $('input[type=radio][name=installment_plan]').change(function() {
                                updatePrice();
                            });
                            updatePrice();
                            
			}
                    });
                }
                
                function showLoggedSpecs(path){
                    $.ajax({
                        url : path+'pages/checklogin.jsp',
                        type: 'post',
                        dataType: 'json',
                        success : function(json)
                        {
                            $(".specs_all").show();
                            if(json.loggedin == '1') 
                            {
                                $(".specs_logged_customer").show();
                                $("#tabhead_summary").show();
                                $(".o-tab-content").removeClass("show");
                                $("#summarytab").addClass("show");
                                //$(".specs_logged_supplier").show();
                            }
                            else{
                                //$('#login-popup').toggleClass('active');
                            }
                        },
                        error : function()
                        {
                                alert("Error while communicating with the server");
                        }
                    });
                }
                
                function showHideLogged(path){
                    $.ajax({
                        url : path+'pages/checklogin.jsp',
                        type: 'post',
                        dataType: 'json',
                        success : function(json)
                        {
                            if(json.loggedin == '1') 
                            {
                                logged = true;
//                                $(".logged").show();
//                                $(".not_logged").hide();
                                $("#user").val(json.login);
                                $("#questions_user").val(json.login);
                                $(".not_logged").removeClass("active");
                                $(".logged").addClass("active");
                                if(allow_comments!=0 ){
                                    $("#tabhead_comments").show();
                                    if(!$("#summarytab").hasClass("show")){
                                        $(".o-tab-content").removeClass("show");
                                        $("#commentstab").addClass("show");
                                    }                                    
                                }
                                if(allow_questions!=0 ){
                                    $("#tabhead_questions").show();
                                    if(!$("#summarytab").hasClass("show")&&!$("#commentstab").hasClass("show")){
                                        $(".o-tab-content").removeClass("show");
                                        $("#questionstab").addClass("show");
                                    }                                    
                                }
                                
				
                            }
                            else{ 
                                logged = false;                               
//                                $(".logged").hide();
//                                $(".not_logged").show();
                                $(".logged").removeClass("active");
                                $(".not_logged").addClass("active");                                
                                if(allow_comments>1){
                                    $("#tabhead_comments").show();
                                    if(!$("#summarytab").hasClass("show")){
                                        $(".o-tab-content").removeClass("show");
                                        $("#commentstab").addClass("show");
                                    }                                        
                                }                               
                                if(allow_questions>1){
                                    $("#tabhead_questions").show();
                                    if(!$("#summarytab").hasClass("show")&&!$("#commentstab").hasClass("show")){
                                        $(".o-tab-content").removeClass("show");
                                        $("#questionstab").addClass("show");
                                    }                                    
                                }
                            }
                        },
                        error : function()
                        {
                            alert("Error while communicating with the server");
                        }
                    });
                }
                
                function loadComments(id, path, num, next_prev){  
                    if(next_prev&&(num<1||num>totalPages)) return;                          
                    
                    currentCommentsPage = num;
                    var postData = {
                            product_id: id, //uuid
                            num: num
                    };                
                    jQuery.ajax({
			url : path+'cart/loadComments.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            $("#comments_container").html($.trim(data));
                            loadPagination();
                            
                            if(num==1) $("#prevCommentsPage").addClass("o-disabled");
                            else $("#prevCommentsPage").removeClass("o-disabled");

                            if(num>=totalPages) $("#nextCommentsPage").addClass("o-disabled");
                            else $("#nextCommentsPage").removeClass("o-disabled");  
                            $(".commentsPagination").removeClass("active");
                            $(".commentsPagination").removeClass("o-active");
                            $("#commentsPagination"+num).addClass("active");
                            $("#commentsPagination"+num).addClass("o-active");
			}
                    });
                }
                
                function onSaveComments(id, path, message){
                    if($("#user").val()==""||$("#comments").val()==""){
                        if($("#comments").val()!=""){
                            alert(message);
                        }
                        //alert("Please Enter User Name for Comments!");
                        return;
                    }
                     
                    var postData = {
                        product_id: id,
                        comments: $("#comments").val(),
                        user: $("#user").val()
                    };
                    jQuery.ajax({
			url : path+'cart/saveComments.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            //if(currentCommentsPage==0) currentCommentsPage=1;
                            loadComments(id, path, currentCommentsPage, false);
                            $("#comments").val("");
			}
                    });
                }                    
                
                function loadPagination(){
                    totalPages = parseInt($("#total_pages").val());
                    if(totalPages<1) $("#pagination_container").hide();
                    else $("#pagination_container").show();
                    var html="<li id='prevCommentsPage'><a href='javascript:gotoPage(currentCommentsPage-1, true)' aria-label='Previous'><span aria-hidden='true'>&laquo;</span></a></li>";
                    for(var i = 1; i<=totalPages; i++){
                        html+="<li id='commentsPagination"+i+"' class='commentsPagination'><a href='javascript:gotoPage("+i+", false)'>"+i+"</a></li>";
                    }
                    html+="<li id='nextCommentsPage'><a href='javascript:gotoPage(currentCommentsPage+1, true)' aria-label='Next'><span aria-hidden='true'>&raquo;</span></a></li>";
                    $("#pagination_container").html(html);
                }
                
                function loadQuestions(id, path, num, next_prev){  
                    if(next_prev&&(num<1||num>totalQuestionsPages)) return;                          
                    
                    currentQuestionsPage = num;
                    var postData = {
                            product_id: id,
                            num: num
                    };                
                    jQuery.ajax({
			url : path+'cart/loadQuestions.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            $("#questions_container").html($.trim(data));
                            loadQuestionsPagination();
                            
                            if(num==1) $("#prevQuestionsPage").addClass("o-disabled");
                            else $("#prevQuestionsPage").removeClass("o-disabled");

                            if(num>=totalQuestionsPages) $("#nextQuestionsPage").addClass("o-disabled");
                            else $("#nextQuestionsPage").removeClass("o-disabled");  
                            $(".questionsPagination").removeClass("active");
                            $(".questionsPagination").removeClass("o-active");
                            $("#questionsPagination"+num).addClass("active");
                            $("#questionsPagination"+num).addClass("o-active");
			}
                    });
                }
                
                function onSaveQuestions(id, path, message){
                    if($("#questions_user").val()==""||$("#questions").val()==""){
                        if($("#questions").val()!=""){
                            alert(message);
                        }
                        return;
                    }
                     
                    var postData = {
                        product_id: id,
                        questions: $("#questions").val(),
                        user: $("#questions_user").val(),
                        muid: ______muid
                    };
                    jQuery.ajax({
			url : path+'cart/saveQuestions.jsp',
			type: 'POST',
			data: postData,
			success : function(data)
			{
                            loadQuestions(id, path, currentQuestionsPage, false);
                            $("#questions").val("");
			}
                    });
                }                    
                
                function loadQuestionsPagination(){
                    totalQuestionsPages = parseInt($("#questions_total_pages").val());
                    if(totalQuestionsPages<1) $("#questions_pagination_container").hide();
                    else $("#questions_pagination_container").show();
                    var html="<li id='prevQuestionsPage'><a href='javascript:gotoPageQuestions(currentQuestionsPage-1, true)' aria-label='Previous'><span aria-hidden='true'>&laquo;</span></a></li>";
                    for(var i = 1; i<=totalQuestionsPages; i++){
                        html+="<li id='questionsPagination"+i+"' class='questionsPagination'><a href='javascript:gotoPageQuestions("+i+", false)'>"+i+"</a></li>";
                    }
                    html+="<li id='nextQuestionsPage'><a href='javascript:gotoPageQuestions(currentQuestionsPage+1, true)' aria-label='Next'><span aria-hidden='true'>&raquo;</span></a></li>";
                    $("#questions_pagination_container").html(html);
                }
                
                function trackOrder(path){
                    $('#trackForm').attr('action', path+'cart/trackingInfo.jsp?muid='+______muid);
                    isValidOrder(path);
                    //$("#trackForm").submit();$("input[name=installment_plan]");$("input[name=installment_plan]");
                    
                }
                
                
                
                function isValidOrder(path){
                    $.ajax({
                        url : path+'pages/checklogin.jsp',
                        type: 'post',
                        dataType: 'json',
                        success : function(json)
                        {
                            if(json.valid == '1') 
                            {
                                $('<form method="POST" action="'+path+'cart/trackingInfo.jsp'+'"><input type="hidden" name="muid" value="'+______muid+'" ><input type="hidden" name="email" value="'+$("input[name=email]").val()+'" ><input type="hidden" name="orderId" value="'+$("input[name=orderId]").val()+'" ></form>').appendTo('body').submit();			
                            }
                            else{ 
                                $("#orderError").show();
                            }
                        },
                        error : function()
                        {
                            alert("Error while communicating with the server");
                        }
                    });
                }